#!/usr/bin/env python3
"""CSV -> Logs/Drops/<Language>.lua, for the class-filtered exports.

    python3 tools/csv_to_drops.py LootTables/folly.csv LootTables/follySoftLock.csv
    python3 tools/csv_to_drops.py --write LootTables/folly.csv LootTables/follySoftLock.csv

The row taxonomy, the shared group-id map and the probability fold are the loot-browser rework's
data contract (docs/csv-to-drops.md in the design handover, which is not in this tree), checked
against the reference parser that shipped with it. What that contract says, in one line: fold an
item's several chances as 1 - PI(1 - p), per lock kind, and never merge favoured with common.

WHY IT LIVES HERE. The exports are two files per raid now (favoured and soft-lock) and they carry
the class filter, so the fold has to happen before the Lua is written rather than in the window.
The CSVs themselves stay in LootTables/, which is gitignored.

WITHOUT --write NOTHING IS TOUCHED: the validation runs, the chest-log entries are printed as a
diff against Logs/English.lua, and a non-zero exit means one of the six checks in the spec failed.
"""

import argparse
import csv
import re
import sys
from collections import OrderedDict

# The Turbine class ids the drops file keys on. Names are localised and the file must stay
# re-keyable across languages, so the CSV's name is only ever a lookup into this table.
CLASS_IDS = OrderedDict([
    ("Beorning",    "Turbine.Gameplay.Class.Beorning"),
    ("Brawler",     "Turbine.Gameplay.Class.Brawler"),
    ("Burglar",     "Turbine.Gameplay.Class.Burglar"),
    ("Captain",     "Turbine.Gameplay.Class.Captain"),
    ("Champion",    "Turbine.Gameplay.Class.Champion"),
    ("Guardian",    "Turbine.Gameplay.Class.Guardian"),
    ("Hunter",      "Turbine.Gameplay.Class.Hunter"),
    ("Lore-master", "Turbine.Gameplay.Class.LoreMaster"),
    ("Mariner",     "Turbine.Gameplay.Class.Mariner"),
    ("Minstrel",    "Turbine.Gameplay.Class.Minstrel"),
    ("Rune-keeper", "Turbine.Gameplay.Class.RuneKeeper"),
    ("Warden",      "Turbine.Gameplay.Class.Warden"),
])
CLASSES = list(CLASS_IDS)

# A chest name is not a boss name and cannot be made into one by rule, so this is hand-kept --
# one line per boss -- and an unknown chest is a hard failure rather than an invented name.
BOSS_ALIASES = {
    "Badharál's Grotesque Egg":  "Badharál",
    "Maukhorn's Chest":          "Maukhorn",
    "The Legion's Chest":        "The Legion",
    "Zamâktar the Putrescent":   "Zamâktar the Putrescent",
}

TABLE_NAMES = re.compile(r"^(FilteredTrophyTable\d*|TrophyList_Override|TreasureList)$")
LEVEL_RANGE = re.compile(r"^\d+-\d+$")

DROPS_FILE = "Logs/Drops/{}.lua"
EVENTS_FILE = "Logs/{}.lua"
LANGUAGES = ("English", "German", "French")


# ----------------------------------------------------------------------------------------------
# the CSV


def read_csv(path):
    with open(path, encoding="utf-8", newline="") as handle:
        return [row for row in csv.reader(handle) if any(field.strip() for field in row)]


def normalise(raw):
    """The name as chat prints it: no quantity prefix, no ", Lvl NNN" suffix.

    _G.LootDrops.Normalise's rule, and it has to stay that rule -- the drops file is keyed on
    what the parser will produce from a chat line, and nothing else.
    """
    match = re.match(r"^(\d[\d,.]*)\s+(.+)$", raw)
    if match:
        raw = match.group(2)
    match = re.match(r"^(.*), Lvl (\d+)$", raw)
    return match.group(1) if match else raw


class Parser:
    """The state machine of docs/csv-to-drops.md §1, over both files.

    The group map is shared on purpose: the soft-lock file references groups whose members are
    listed only in the favoured file, so the favoured file is parsed first.
    """

    def __init__(self):
        self.group_members = {}
        self.entries = []
        self.chests = OrderedDict()
        self.warnings = []

    def parse(self, rows, source):
        chest = table = classes = level = group = None
        members = None

        def emit(item, pool):
            if item.get("guaranteed"):
                probability = 1.0
            elif item.get("direct") is not None:
                probability = item["direct"]
            elif pool is not None:
                probability = pool["chance"] * (item["share"] / 100.0)
            else:
                probability = None
            self.entries.append({
                "chest": chest["name"], "source": source, "table": table,
                "classes": classes, "level": level,
                "item": normalise(item["name"]), "qty": item["qty"], "id": item["id"],
                "p": probability,
                "pool": pool["chance"] if pool else None,
                "share": item.get("share"),
            })

        def close_group():
            if group and members:
                self.group_members[group["id"]] = members

        def open_group(group_id, chance):
            nonlocal group, members
            close_group()
            group = {"id": group_id, "chance": chance}
            members = []
            known = self.group_members.get(group_id)
            if known is not None:
                # a bare re-occurrence: the same members, rolled at a new chance
                for member in known:
                    emit(member, group)
                members = None

        def drop_group():
            nonlocal group, members
            close_group()
            group, members = None, None

        for fields in rows:
            # the field COUNT is part of the taxonomy -- a five-field item row is a direct drop
            # and a six-field one is a share of a group -- so it is read before the padding
            width = len(fields)
            row_id, icon, name, quantity, chance, share = (fields + [""] * 6)[:6]

            if quantity.startswith("Lock:") or quantity.startswith("Soft:"):
                drop_group()
                chest = self.chest_header(row_id, icon, name, quantity, source)
                table = classes = level = None
                continue

            if chest is None:
                continue

            if icon == "" and TABLE_NAMES.match(name):
                drop_group()
                table, classes, level = name, None, None
                continue

            if icon == "" and name == "" and chance != "":
                open_group(row_id, float(chance))
                continue

            if icon == "" and width <= 3:
                if name == "":
                    drop_group()                                   # an empty table for this chest
                    continue
                if re.match(r"^[\d.]+$", name):
                    open_group(row_id, float(name))                 # the TreasureList group form
                    continue
                drop_group()                                        # a class / level filter
                parts = name.split(",")
                levels = [p for p in parts if LEVEL_RANGE.match(p)]
                named = [p for p in parts if p in CLASS_IDS]
                unknown = [p for p in parts if p not in CLASS_IDS and not LEVEL_RANGE.match(p)]
                if unknown:
                    self.warnings.append("unknown filter term(s) %s in %r"
                                         % (", ".join(unknown), name))
                classes = named or None
                level = levels[-1] if levels else None
                continue

            item = {"id": row_id, "name": name, "icon": icon,
                    "qty": int(quantity) if quantity.strip().isdigit() else 1}
            if width >= 6 and share != "":
                item["weight"], item["share"] = float(chance), float(share)
            elif width == 5 and chance != "":
                item["direct"] = float(chance)
            else:
                item["guaranteed"] = True

            if "share" in item:
                if group is None:
                    self.warnings.append("weighted item outside a group: %s" % item["name"])
                    continue
                if members is not None:
                    members.append(item)
                emit(item, group)
            else:
                emit(item, None)

        close_group()

    def chest_header(self, row_id, days, name, lock, source):
        match = re.match(r"^(.*) - Tier (\d+)$", name)
        if match is None:
            die("chest %r has no tier suffix" % name)
        base, tier = match.group(1), "T" + match.group(2)
        # NEVER INVENT A BOSS NAME. A chest name is not one and cannot be made into one by rule,
        # so an unknown chest stops the export rather than producing a file that reads plausibly
        # and names the wrong boss.
        if base not in BOSS_ALIASES:
            die("no boss name for chest %r -- add it to BOSS_ALIASES, never guess one" % base)
        chest = self.chests.get(name)
        if chest is None:
            chest = {"name": name, "boss": BOSS_ALIASES[base], "tier": tier,
                     "days": days.replace("Days:", ""), "locks": {},
                     "order": len(self.chests) + 1, "id": row_id}
            self.chests[name] = chest
        chest["locks"][source] = int(lock.split(":")[1])
        return chest


# ----------------------------------------------------------------------------------------------
# the fold


def fold(rates):
    """1 - Π(1 - p). NEVER the sum (a six-pool item would pass 100%), never the max."""
    remaining, known = 1.0, False
    for rate in rates:
        if rate["p"] is not None:
            known = True
            remaining *= (1.0 - rate["p"])
    return round(1.0 - remaining, 6) if known else None


def rows_per_class(entries):
    """chest -> class -> item -> the row the browser draws, one per item per class."""
    chests = OrderedDict()

    for entry in entries:
        for name in (entry["classes"] or CLASSES):
            byclass = chests.setdefault(entry["chest"], OrderedDict())
            items = byclass.setdefault(name, OrderedDict())
            row = items.get(entry["item"])
            if row is None:
                row = {"item": entry["item"], "qty": entry["qty"], "id": entry["id"],
                       "fav": [], "com": [], "tables": [], "classRow": False}
                items[entry["item"]] = row
            rate = {"p": entry["p"], "pool": entry["pool"], "share": entry["share"],
                    "table": entry["table"]}
            row["fav" if entry["source"] == "favoured" else "com"].append(rate)
            row["qty"] = max(row["qty"], entry["qty"])
            if entry["table"] not in row["tables"]:
                row["tables"].append(entry["table"])
            if entry["classes"]:
                row["classRow"] = True

    for byclass in chests.values():
        for items in byclass.values():
            for row in items.values():
                for kind in ("fav", "com"):
                    rates = row[kind]
                    row[kind] = None if not rates else {
                        "chance": fold(rates),
                        "rolls": len(rates),
                        "rates": sorted(rates, key=lambda r: -(r["p"] or 0)),
                    }

    return chests


def lead(row):
    """What the row sorts and displays on: the favoured figure, else the common one."""
    for kind in ("fav", "com"):
        if row[kind] and row[kind]["chance"] is not None:
            return row[kind]["chance"]
    return None


def split_shared(byclass):
    """Rows every class gets, once; the rest under their class.

    THE FILE SIZE RULE. A row that reads the same for all twelve classes is emitted once into
    `any`; anything else is emitted under each class that has it, and never in both places.
    """
    counts = {}
    for name, items in byclass.items():
        for item, row in items.items():
            counts.setdefault(item, []).append((name, row))

    shared, per_class = OrderedDict(), OrderedDict((name, []) for name in byclass)

    for item, seen in counts.items():
        signatures = {signature(row) for _, row in seen}
        if len(seen) == len(byclass) and len(signatures) == 1:
            shared[item] = seen[0][1]
        else:
            for name, row in seen:
                per_class[name].append(row)

    return list(shared.values()), per_class


def signature(row):
    def pack(kind):
        if not row[kind]:
            return None
        return (row[kind]["chance"], row[kind]["rolls"],
                tuple((r["p"], r["pool"], r["share"], r["table"]) for r in row[kind]["rates"]))
    return (row["qty"], row["id"], row["classRow"], tuple(row["tables"]),
            pack("fav"), pack("com"))


def by_chance(rows):
    """Likeliest first -- the order the browser wants, so the guaranteed rows lead."""
    return sorted(rows, key=lambda r: (
        -((r["fav"] or {}).get("chance") or 0),
        -((r["com"] or {}).get("chance") or 0),
        r["item"]))


# ----------------------------------------------------------------------------------------------
# the existing files


def read_events(language):
    """index -> the _G.Events row, by `match`, which is the key the chests are found by."""
    events = {}
    with open(EVENTS_FILE.format(language), encoding="utf-8") as handle:
        for line in handle:
            head = re.match(r"^\s*\[(\d+)\]\s*=\s*\{(.*)$", line)
            if head is None:
                continue
            body = head.group(2)
            match = re.search(r'match\s*=\s*"((?:[^"\\]|\\.)*)"', body)
            name = re.search(r'name\s*=\s*"((?:[^"\\]|\\.)*)"', body)
            if match is None:
                continue
            events[int(head.group(1))] = {
                "match": match.group(1),
                "name": name.group(1) if name else None,
                "instance": int(re.search(r"instance\s*=\s*(\d+)", body).group(1))
                            if re.search(r"instance\s*=\s*(\d+)", body) else None,
                "tier": (re.search(r'tier\s*=\s*"([^"]*)"', body) or [None, None])[1],
                "order": int(re.search(r"order\s*=\s*(\d+)", body).group(1))
                         if re.search(r"order\s*=\s*(\d+)", body) else None,
                "line": line.rstrip("\n"),
            }
    return events


def read_drops_blocks(language):
    """The drops file split into its per-event blocks, so only the chests re-exported change."""
    with open(DROPS_FILE.format(language), encoding="utf-8") as handle:
        lines = handle.readlines()

    blocks, order, start, index = {}, [], None, None
    for number, line in enumerate(lines):
        head = re.match(r"^    \[(\d+)\] = \{", line)
        if head is not None:
            start, index = number, int(head.group(1))
        elif line.rstrip("\n") == "    }," and start is not None:
            blocks[index] = (start, number)
            order.append(index)
            start = None
    return lines, blocks, order


def read_item_metadata(lines, blocks):
    """What the CSV cannot supply -- plural, label, quality, slot, category -- kept by item name.

    LOSING THE LABELS WOULD COST THE BROWSER ITS SUB-LINE, so the previous file is read rather
    than overwritten blind. Merged on the item NAME, which is the key everything else uses too.
    """
    metadata = {}
    for index, (start, end) in blocks.items():
        text = "".join(lines[start:end])
        for row in re.finditer(r"\{ item = (.*?)\},", text, re.S):
            body = row.group(1)
            name = re.match(r'"((?:[^"\\]|\\.)*)"', body)
            if name is None:
                continue
            keep = metadata.setdefault(normalise(name.group(1)), {})
            for field in ("plural", "label", "quality", "slot"):
                found = re.search(field + r'\s*=\s*"((?:[^"\\]|\\.)*)"', body)
                if found is not None and field not in keep:
                    keep[field] = found.group(1)
            found = re.search(r"id\s*=\s*(0x[0-9A-Fa-f]+)", body)
            if found is not None and "id" not in keep:
                keep["id"] = found.group(1)
            if re.search(r"popup\s*=\s*false", body) and "popup" not in keep:
                keep["popup"] = False
    return metadata


# ----------------------------------------------------------------------------------------------
# writing the Lua


def quote(text):
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"') + '"'


def number(value):
    if value is None:
        return "nil"
    if value == int(value):
        return "%.1f" % value
    return ("%.6f" % value).rstrip("0")


def pack_lua(pack):
    if pack is None:
        return None
    # A nil field is left out rather than written: `pool` and `share` are absent on every
    # direct and guaranteed roll, and spelling them out cost the file a quarter of its size.
    def rate_lua(rate):
        fields = ["p = %s" % number(rate["p"])]
        if rate["pool"] is not None:
            fields.append("pool = %s" % number(rate["pool"]))
        if rate["share"] is not None:
            fields.append("share = %s" % number(rate["share"]))
        if rate["table"]:
            fields.append("table = %s" % quote(rate["table"]))
        return "{ %s }" % ", ".join(fields)

    rates = ", ".join(rate_lua(rate) for rate in pack["rates"])
    return "{ chance = %s, rolls = %d, rates = { %s } }" % (
        number(pack["chance"]), pack["rolls"], rates)


def row_lua(row, metadata, indent):
    """One row, merged with what the previous file knew that the CSV cannot say."""
    name, keep = row["item"], metadata.get(row["item"])

    # A NAME CHAT CANNOT PRINT IS A CATEGORY, NOT AN ITEM -- the "?? " convention the drops file
    # header describes. The export has exactly one ("Tracery", the generic reward), and the
    # previous file is what says so: it catalogued it under "?? Tracery". Emitting it under the
    # bare word would make it the lookup key for a line the client never writes.
    if keep is None and metadata.get("?? " + name) is not None:
        name = "?? " + name
        keep = metadata[name]
        row = dict(row, category=True)

    keep = keep or {}
    pad = " " * indent
    out = ['%s{ item = %s, qty = %d,' % (pad, quote(name), row["qty"])]

    identity = keep.get("id") or ("0x%08X" % int(row["id"]) if row["id"] else None)
    fields = ['id = %s' % (identity or "nil")]
    for field in ("plural", "label", "quality", "slot"):
        if keep.get(field):
            fields.append("%s = %s" % (field, quote(keep[field])))
    fields.append("popup = %s" % ("false" if keep.get("popup") is False else "true"))
    if row.get("category"):
        fields.append("category = true")
    if row["classRow"]:
        fields.append("classRow = true")
    out.append("%s  %s," % (pad, ", ".join(fields)))

    for kind in ("fav", "com"):
        lua = pack_lua(row[kind])
        if lua is not None:
            out.append("%s  %s = %s," % (pad, kind, lua))

    out.append("%s  tables = { %s } }," % (
        pad, ", ".join(quote(name) for name in row["tables"] if name)))
    return "\n".join(out)


def block_lua(index, event, chest, shared, per_class, metadata):
    pad = "    "
    out = ["%s[%d] = {   -- %s %s" % (pad, index, chest["boss"], chest["tier"])]
    out.append('%s    chest = %s,' % (pad, quote(chest["name"])))
    out.append('%s    reset = %s,' % (pad, quote(chest["days"])))
    out.append("%s    lock  = { favoured = %s, common = %s }," % (
        pad, chest["locks"].get("favoured", "nil"), chest["locks"].get("common", "nil")))
    out.append("")
    out.append("%s    -- every class gets these" % pad)
    out.append("%s    any = {" % pad)
    for row in by_chance(shared):
        out.append(row_lua(row, metadata, 8 + 4))
    out.append("%s    }," % pad)
    out.append("")
    out.append("%s    -- keyed by Turbine class id: a row is written under the class that can" % pad)
    out.append("%s    -- get it and never copied into `any`, which is what keeps this file one" % pad)
    out.append("%s    -- chest rather than twelve near-copies of one" % pad)
    out.append("%s    classes = {" % pad)
    for name in CLASSES:
        rows = by_chance(per_class.get(name, []))
        if not rows:
            continue
        out.append("%s        [%s] = {" % (pad, CLASS_IDS[name]))
        for row in rows:
            out.append(row_lua(row, metadata, 12 + 4))
        out.append("%s        }," % pad)
    out.append("%s    }," % pad)
    out.append("%s}," % pad)
    return "\n".join(out) + "\n"


# ----------------------------------------------------------------------------------------------
# the chest log entries (docs/csv-to-drops.md §2)


def chest_log_line(chest, event, index):
    """What _G.Events would say for this chest, so the log entries can be checked, not typed."""
    return ('    [%s] = { name = "%s", match = "%s", instance = %s, tier = "%s", order = %s, '
            'type = _G.EventTypes.Completions, reset = { days = Weekly, time = 8 }, '
            'onlyResetIfDone = false },'
            % (index if index is not None else "?", chest["boss"],
               chest["name"].replace(" - ", " . "),
               event["instance"] if event else "?", chest["tier"],
               event["order"] if event else "?"))


# ----------------------------------------------------------------------------------------------


def prune_groups(lines):
    """Drop the _G.DropGroups declarations no row names any more.

    A re-exported chest loses its groups -- the class filter is what they stood in for -- and a
    declaration with no members is exactly what the tests call a typo: it reads as a group whose
    rows were renamed out from under it.
    """
    text = "".join(lines)
    named = set(re.findall(r'group = "((?:[^"\\]|\\.)*)"', text))

    kept = []
    for line in lines:
        declared = re.match(r'^\s*\["((?:[^"\\]|\\.)*)"\]\s*=\s*\{\s*mode', line)
        if declared is not None and declared.group(1) not in named:
            continue
        kept.append(line)

    return kept


FAILURES = []


def fail(message):
    """A validation failure: reported, collected, and a non-zero exit at the end."""
    print("FAIL  " + message, file=sys.stderr)
    FAILURES.append(message)


def die(message):
    """A structural one: nothing after it would be worth reading, so it stops here."""
    print("FAIL  " + message, file=sys.stderr)
    raise SystemExit(1)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("favoured", help="the loot-table CSV (Lock:N rows)")
    parser.add_argument("common", help="the soft-lock CSV (Soft:N rows)")
    parser.add_argument("--write", action="store_true",
                        help="splice the result into Logs/Drops/English.lua")
    parser.add_argument("--language", default="English")
    args = parser.parse_args()

    state = Parser()
    state.parse(read_csv(args.favoured), "favoured")     # favoured FIRST: it defines the groups
    state.parse(read_csv(args.common), "common")

    chests = rows_per_class(state.entries)

    events = read_events(args.language)
    by_match = {event["match"]: index for index, event in events.items()}

    lines, blocks, order = read_drops_blocks(args.language)
    metadata = read_item_metadata(lines, blocks)

    # ---- check 1: every bare group id resolved to members ------------------------------------
    for warning in state.warnings:
        fail("group/filter warning: " + warning)

    # ---- check 4: chest <-> event index -------------------------------------------------------
    written = {}
    for name, chest in state.chests.items():
        index = by_match.get(name.replace(" - ", " . "))
        if index is None:
            fail("chest %r has no event index in %s" % (name, EVENTS_FILE.format(args.language)))
            continue
        written[index] = chest

    for index in sorted(written):
        if index not in blocks:
            fail("event %d is not a block in %s" % (index, DROPS_FILE.format(args.language)))

    # ---- build --------------------------------------------------------------------------------
    rendered = {}
    for index, chest in sorted(written.items()):
        byclass = chests[chest["name"]]
        shared, per_class = split_shared(byclass)
        rendered[index] = block_lua(index, events[index], chest, shared, per_class, metadata)

        # ---- checks 2 and 3, on what is actually written --------------------------------------
        for row in list(shared) + [r for rows in per_class.values() for r in rows]:
            for kind in ("fav", "com"):
                pack = row[kind]
                if pack is None:
                    continue
                if pack["chance"] is not None and (pack["chance"] > 1.0 or pack["chance"] == 0):
                    fail("%s %s %s is %s" % (chest["name"], row["item"], kind, pack["chance"]))
                if pack["rolls"] != len(pack["rates"]):
                    fail("%s %s %s rolls != rates" % (chest["name"], row["item"], kind))

        # ---- check 6: the count the browser must agree with -----------------------------------
        for name in ("Warden", "Lore-master"):
            drawn = len(shared) + len(per_class.get(name, []))
            folded = len(byclass.get(name, {}))
            if drawn != folded:
                fail("%s %s: %d rows drawn, %d items folded" % (chest["name"], name, drawn, folded))

    # ---- check 5: the three language files share their index set ------------------------------
    english = set(read_drops_blocks("English")[1])
    for language in LANGUAGES[1:]:
        indices = set(read_drops_blocks(language)[1])
        if not indices:
            print("note: %s is awaiting translation (empty _G.Drops), index check skipped"
                  % language)
        elif indices != english:
            fail("%s indexes %s, English indexes %s"
                 % (language, sorted(indices - english), sorted(english - indices)))

    # ---- report --------------------------------------------------------------------------------
    print("\nchests")
    for index, chest in sorted(written.items()):
        byclass = chests[chest["name"]]
        shared, per_class = split_shared(byclass)
        print("  [%d] %-12s %-3s  any %-3d  Warden %-3d (%d rows)  Lore-master %-3d (%d rows)"
              % (index, chest["boss"], chest["tier"], len(shared),
                 len(byclass.get("Warden", {})), len(shared) + len(per_class.get("Warden", [])),
                 len(byclass.get("Lore-master", {})),
                 len(shared) + len(per_class.get("Lore-master", []))))

    print("\nchest log entries (docs/csv-to-drops.md §2) -- diff against %s"
          % EVENTS_FILE.format(args.language))
    for name, chest in state.chests.items():
        index = by_match.get(name.replace(" - ", " . "))
        event = events.get(index)
        generated = chest_log_line(chest, event, index)
        if event is None:
            print("  +  " + generated.strip())
        elif event["name"] != chest["boss"]:
            print("  ~  [%d] name is %r here, %r in the log" % (index, chest["boss"], event["name"]))

    if FAILURES:
        print("\n%d validation failure(s)" % len(FAILURES), file=sys.stderr)
        return 1

    if args.write:
        out = []
        last = 0
        for index in order:
            start, end = blocks[index]
            if index not in rendered:
                continue
            out.extend(lines[last:start])
            out.append(rendered[index])
            last = end + 1
        out.extend(lines[last:])
        out = prune_groups(out)
        with open(DROPS_FILE.format(args.language), "w", encoding="utf-8") as handle:
            handle.write("".join(out))
        print("\nwrote %s" % DROPS_FILE.format(args.language))
    else:
        print("\nnothing written -- pass --write to splice %s"
              % DROPS_FILE.format(args.language))

    return 0


if __name__ == "__main__":
    sys.exit(main())
