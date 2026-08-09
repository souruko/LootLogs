--=================================================================================================
--= Loot drops data (English)
--= ===============================================================================================
--= Keyed by _G.Events index, so a chest's loot table is a direct lookup from the index
--= ProcessMatch already produced. Because _G.Events has one entry per (boss, tier) pair,
--= per-tier drop chances come for free -- there is no nested tier table here.
--=
--= item    : the NORMALISED base name, exactly as it appears in chat, WITHOUT a "3 " quantity
--=           prefix and WITHOUT a ", Lvl NNN" suffix
--= plural  : OPTIONAL. The spelling used when more than one drops at once. Stacks arrive as
--=           "[3 Damaged Mûrai Artifacts]" against a singular "[Damaged Mûrai Artifact]", and
--=           the plural falls on the head noun -- "Badges of Forgotten Rank", not "Badge of
--=           Forgotten Ranks" -- so it cannot be derived by rule, and the rule would be
--=           language-specific anyway. Write it out. Only stackables need one.
--= label   : OPTIONAL. What to CALL the item on screen, replacing the client's own name
--=           everywhere it is shown -- the popup, the browser and the chest alert:
--=
--=               { item = "Blighted Shoulder-guards of Shadows",
--=                 label = "Burglar Red Shoulders", ... }
--=
--=           Display only. `item` stays the key: matching, the wishlist and every observed
--=           rate are keyed on the name the client prints, because that is the only thing
--=           chat gives us to match against. Renaming the key would break the lookup the
--=           moment someone edited the label.
--=
--=           The browser's search finds an item under EITHER name, since whoever is searching
--=           knows it by one of them and cannot tell which this build stores.
--= quality : OPTIONAL. "incomparable" | "rare" | "uncommon" | "common". Absent means unknown;
--=           the UI falls back to its plain text colour rather than inventing a rarity.
--= slot    : OPTIONAL free text, shown in the browser's slot column.
--= chance  : OPTIONAL, 0..1 for THIS event, i.e. this boss at this tier. ABSENT MEANS
--=           "known to drop, rate not established" and the browser shows that as unknown --
--=           it must never be shown as 0%.
--= popup   : OPTIONAL. true means this drop is worth interrupting the player for, and it is
--=           the ONLY thing the loot popup shows. Barter currency and other filler stays out
--=           of it. A chest whose drops are all unflagged opens no popup at all.
--=
--=           This is a DISPLAY filter and nothing else: LootStats still counts every
--=           catalogued drop, so the observed rates in the browser stay honest whatever is
--=           flagged here. The browser lists everything regardless.
--= id      : OPTIONAL, and the most valuable field here after the name. It is the item id, and
--=           it is what draws the row's REAL ICON AND TOOLTIP: a quickslot shortcut built as
--=           "0x0000000000000000,0x<id>" resolves even for an item nobody owns.
--=
--=           Chat hands the id over for items you do NOT hold -- other people's loot, and your
--=           own while it is still (pending). For anything else, drag the item onto a row's
--=           quickslot and read the id off the line it prints.
--=
--=           A row without one still works; it just shows an empty slot instead of an icon.
--=
--= The keys are shared with German.lua and French.lua -- those files translate the item
--= NAMES only and must never re-key.
--=
--= AUTHORING: this table is INPUT to LootLogs, which reads it and never writes it. A separate
--= plugin will produce these files; what is here now is a hand-built seed in the format that
--= plugin should emit. Nothing in LootLogs scans, harvests or backfills any of it -- a missing
--= id shows an empty slot, a missing item is ignored, and both are fixed by authoring, not by
--= the reader guessing.
--=
--= PROVENANCE: everything below was observed through the M0 chat probe on a single six-man
--= Pagru-kirít T1 run (docs/design/loot-drops/reference/, Loot_20260808_3.txt). Six looters is
--= six samples, which is enough to say WHAT drops and not enough to say how often. Hence the
--= 6/6 items carry a chance and the singletons deliberately do not.
--=================================================================================================

_G.Drops = {

    -- Pagru-kirít, the Garden of Corpses (instance 51) -----------------------------------------

    -- T1
    [546] = {   -- Kishâsu
        { item = "Enhancement Rune +1", quality = "incomparable", slot = "Consumable",
          chance = 1.00, id = 0x700713ED, popup = true },         -- 6/6 looters, one run
        { item = "Ornate Conscript's Necklace", slot = "Neck", popup = true },

        -- barter currency: catalogued so it is counted, kept out of the popup
        { item = "Damaged Mûrai Artifact", plural = "Damaged Mûrai Artifacts",
          slot = "Barter", id = 0x70070C07 },
        { item = "Toll Copper", slot = "Barter", id = 0x700749E9 },
        { item = "Silver Serpent", plural = "Silver Serpents", slot = "Barter",
          id = 0x70073138 },
    },

    [545] = {   -- Khardâmu
        { item = "Enhancement Rune +1", quality = "incomparable", slot = "Consumable",
          chance = 1.00, id = 0x700713ED, popup = true },         -- 6/6 looters, one run
        { item = "Decorated Coffer of Ancient Script", slot = "Misc", popup = true },

        { item = "Damaged Mûrai Artifact", plural = "Damaged Mûrai Artifacts",
          slot = "Barter", id = 0x70070C07 },
        { item = "Toll Copper", slot = "Barter", id = 0x700749E9 },
    },

    [544] = {   -- Sudûgul -- the last boss, and the only one that dropped gear
        { item = "Ordâkhai Merchant's Shoulder-guard", slot = "Shoulder", popup = true },
        { item = "Ordâkhai Scout's Boots", slot = "Feet", popup = true },
        { item = "Umbari Veteran's Shoulder-guards", slot = "Shoulder", popup = true },
        { item = "Sun-kissed Essence Box", slot = "Misc", id = 0x700713D5, popup = true },

        -- legendary item traceries; they share the chest with the gear
        { item = "Area Effect Attack Criticals", slot = "Tracery", id = 0x70071235,
          popup = true },
        { item = "Call to Ioreth Cooldown & Critical Multiplier Bonus", slot = "Tracery",
          id = 0x70070EF1, popup = true },
        { item = "Perfect Recovery", slot = "Tracery", id = 0x7007128A, popup = true },
        { item = "Rallying Cry Healing", slot = "Tracery", popup = true },
        { item = "Ranged Healing Extension", slot = "Tracery", id = 0x700712B6,
          popup = true },
        { item = "Thrust Damage", slot = "Tracery", popup = true },

        { item = "Silver Serpent", plural = "Silver Serpents", slot = "Barter",
          chance = 1.00, id = 0x70073138 },                       -- 6/6 looters, one run
    },

    -- Solo, T2 and T3 for this instance (549-547, 543-541, 540-538) are not catalogued yet.
    -- An absent key simply means no popup and no browser rows for that chest.

}
