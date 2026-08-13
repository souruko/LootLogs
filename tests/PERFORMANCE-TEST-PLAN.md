# Performance shakedown

Test plan for the chat-parsing rewrite (`4.49.3`).

One commit changed how the plugin reads chat. `tests/run.lua` proves the parsing logic is
unchanged; it cannot touch a single thing that needs the game client. This is what only a
person with the game open can check, in the order that costs the least to reach.

## What should have got faster

| Measured on                | Before   | After   | Factor |
| -------------------------- | -------- | ------- | ------ |
| An ordinary chat line      | 200 µs   | 5.9 µs  | 34×    |
| A loot line                | 10.8 µs  | 2.1 µs  | 5×     |
| Mixed run traffic          | 103 µs   | 3.6 µs  | 29×    |

Bench figures from a desktop Lua 5.1 against the plugin's own data files, not client
measurements. The client gives you no profiler, so in game the test is perceptual and it has
exactly one setting worth judging: **a six-man run where everyone is looting trash at once**.
That is where the old code spent its time, and if the frame rate still dips there, the change
did not land.

## Already proven — do not retest by hand

From the plugin root, with any desktop Lua 5.1:

    lua5.1 tests/run.lua

Run this first. If it fails, stop: nothing below will tell you anything useful.

- **The event index dispatches exactly what the old linear scan did.** Compared across 3,521
  messages generated from every pattern in the real event table, with optional parts absent and
  present, standalone and mid-line. This is the check that matters most, and it is the reason
  nobody has to loot 585 chests by hand.
- **Required-literal extraction** against every pattern construct the data uses — wildcards,
  character classes, escaped brackets, sets, and each quantifier.
- **The instance index** returns precisely each instance's own events, ascending.
- **The loot buffer at its cap**, including the compaction path, verified to sit at exactly 200
  entries rather than passing vacuously.
- **Everything that already passed** — attribution windows, stack and level parsing, popup
  ordering and blocks, item links, chat announcements.

### What the suite structurally cannot reach

There is no Turbine outside the client, so nothing that builds a control, opens a window,
resolves an item icon, or writes saved data is covered by a single one of those assertions.
Every check below exists because it lives in that gap.

## In the client

Phases are ordered by what they cost to reach, and each assumes the ones above it passed. Every
check says how a failure announces itself — that is the important part, because most of these
fail quietly.

Three severities are used:

- **Blocker** — if this fails, stop; nothing else is meaningful.
- **Fails silently** — no error, no message. You only notice by checking the expected result.
- **Visible** — a Lua error, or obviously wrong output.

---

### Phase 1 — It loads and it opens

*2 minutes.*

#### The plugin starts · Blocker

- **Do:** unload and load LootLogs from the Plugin Manager.
- **Expect:** the usual welcome summary of your current lockouts prints to chat.
- **If not:** a Lua error naming `EventIndex` or `Main` — the new module failed to import.

#### The window opens and closes · Blocker

- **Do:** click the quick-launch icon. Click it again.
- **Expect:** the window appears with your content, then hides.
- **If not:** nothing happens, or an error mentioning `SetVisible`. This commit overrides that
  method to flush deferred rebuilds, and it is **the one change with no automated coverage and a
  hard-failure mode**. If it breaks, it breaks here and it breaks loudly.

---

### Phase 2 — The deferred rebuild

*5 minutes, needs one chest.*

#### A chest recorded while the window is shut · Fails silently

- **Do:** close the window. Loot any chest. Open the window.
- **Expect:** the lockout you just earned is there.
- **If not:** stale content missing the chest — the rebuild was banked and never paid.

#### Behind the settings panel · Fails silently

- **Do:** open the window, switch to Settings, change the time display, switch back.
- **Expect:** the content view returns showing the new format.
- **If not:** the old format persists. The settings panel hides the view, so its updates defer
  down the same path.

#### Font size and theme changes · Visible

- **Do:** change Font Size, then the colour theme.
- **Expect:** all windows rebuild and come back correct, quick-launch badge included.
- **If not:** this path reconstructs the window and runs the overridden `SetVisible` again — a
  second exposure for the phase 1 risk.

---

### Phase 3 — Chests are still recognised

*One instance. The core regression.*

This phase is what the whole commit risks. A chest whose pattern the index no longer reaches is
**never reported and never logged** — there is no error, and you would find out weeks later when
a lockout you were sure you had spent came back empty.

#### A chest logs a lockout · Fails silently

- **Do:** run any instance and loot its chest.
- **Expect:** the alert line in chat — instance, boss, tier, value, time remaining — and the
  lockout in the window.
- **If not:** silence. The index did not reach that event's pattern.

#### Accented chest names · Fails silently

- **Do:** prefer an instance whose name carries accents — Thrâng, Storvâgûn, Anâkhi Ensemble,
  Aratûg, Pagru-kirít, Mûr Ghala.
- **Expect:** recorded exactly as any other chest.
- **If not:** the index keys on raw bytes, so multi-byte names should be fine — but they are the
  class most likely to expose a boundary bug, which is why they are worth choosing deliberately.

#### Quest and progress trackers · Fails silently

- **Do:** advance anything counted — missions, tasks, a guild's daily orders.
- **Expect:** the tracker updates with its `(12/45)` figure.
- **If not:** these patterns hold digit classes, so their required literal is only the prefix
  before the count. Different shape from a chest name, worth its own check.

#### It survives a reload · Visible

- **Do:** reload the plugin after recording something.
- **Expect:** the lockout is still listed.
- **If not:** saving now happens only when a match actually records something. If a lockout
  vanishes on reload, that early return skipped a write it should have made.

---

### Phase 4 — Loot lines

*10 minutes, mostly free.*

Most of this needs no lockout at all. `/lootlogs loot demo` fills the popup from the real
catalogue, which exercises ordering, drop chances, links, icons and the search box without
spending a run.

#### Both link forms parse · Visible

- **Do:** loot something catalogued into your bags, and have a fellow win something catalogued.
- **Expect:** both appear with the right name and looter — yours under Yours, theirs under
  Fellowship.
- **If not:** the two forms wrap the name in different markup. Finding the brackets by hand is
  the change; a missing row means one form is no longer read.

#### Stacks and grouped counts · Visible

- **Do:** loot a stack, ideally one over a thousand — `[1,000 Ancient Script]`.
- **Expect:** the quantity is recorded and the name still resolves to the catalogued item.
- **If not:** the name would read as uncatalogued and drop out silently.

#### Currency is not loot · Visible

- **Do:** pick up coin — `You looted 95 silver pieces…`
- **Expect:** nothing recorded, no popup. It shares the channel but has no bracketed name.
- **If not:** a junk row in the popup means the bracket test is matching something it shouldn't.

#### Icons and tooltips still resolve · Visible

- **Do:** `/lootlogs loot demo`, then hover the rows.
- **Expect:** real icons and real tooltips, including for gear nobody owns.
- **If not:** item ids are now pulled through a gated lookup. Blank icons mean the gate is
  rejecting lines that do carry an id.

#### Two chests back to back · Fails silently

- **Do:** loot two chests within a few seconds of each other.
- **Expect:** two separate chests in the run, each holding its own drops.
- **If not:** loot attributed twice, or to the wrong chest. The buffer's claim tracking is what
  prevents this and it moved.

---

### Phase 5 — Under load, the actual point

*One six-man run.*

#### Six people looting at once · Visible

- **Do:** a full group run, with everyone picking up trash. Do not filter your loot channels for
  this one.
- **Expect:** no stutter while the loot spam runs. This is the scenario the whole commit was
  written for — it is also the one that drives the buffer past its 200-entry cap and through
  compaction.
- **If not:** if it still hitches, the bench gains are not reaching the client and the change
  needs re-measuring rather than shipping.

#### Attribution survives the volume · Fails silently

- **Do:** after the chest resolves, read the popup.
- **Expect:** your drops under Yours, the group's under Fellowship, starred items on top,
  nothing missing and nothing counted twice.
- **If not:** heavy volume is exactly where the ring buffer compacts. A drop lost here is lost
  quietly.

---

### Phase 6 — The windows read the same

*10 minutes, compare by eye.*

Six helpers that walked the whole event table now read one instance's own list. The output
should be identical — take a screenshot before switching branches if you want to be sure.

#### Every view still draws · Visible

- **Do:** open a content pack, an instance, a character, and the pinned list.
- **Expect:** tier bands, boss columns, carry-over markers and the sidebar tier squares
  unchanged.
- **If not:** a missing tier or column means an instance's event list is coming back short.

#### Reset captions · Fails silently

- **Do:** read a tier band's schedule — `weekly · Thu 03:00`.
- **Expect:** the same schedule you saw before.
- **If not:** this used to take whichever event the table happened to yield first and is now
  deterministic. If a tier's events ever disagreed on schedule, the caption can legitimately
  change — worth one look to confirm which.

#### Browser and popup search · Visible

- **Do:** `/lootlogs drops`, switch tier and boss. Then type in the popup's search box.
- **Expect:** percentages and sample counts unchanged; typing keeps up.
- **If not:** drop chances are now cached per item per chest. A wrong figure means the cache is
  keyed too loosely.

## If something is wrong

| Symptom                              | Most likely cause                                       | Where to look             |
| ------------------------------------ | ------------------------------------------------------- | ------------------------- |
| A chest records nothing, no error    | Its required literal is wrong or too specific           | `Utils/EventIndex.lua`    |
| Window won't open                    | The `SetVisible` override can't reach the base method   | `UI/Window/Base.lua`      |
| Window opens showing stale content   | A deferred rebuild is never flushed                     | `UI/Window/ContentView.lua` |
| Lockout lost after a reload          | The early return skipped a save                         | `ProcessMatch.lua`        |
| Drops missing or double-counted      | Ring buffer head or compaction                          | `LootDrops.lua`           |
| Wrong drop percentage                | The entries cache                                       | `LootDrops.lua`           |

The work is one commit, so backing it out is one command, and nothing else on the branch depends
on it.

If a chest turns out to be unreachable, the fix is almost never to abandon the index — add that
event to the fallback list in `Utils/EventIndex.lua`, which is checked against every line exactly
as the old code was. Correctness first, speed for the other 584.
