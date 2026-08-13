--=================================================================================================
--= Loot drops data (French)
--= ===============================================================================================
--= Awaiting translation — M5 of the Loot Drops feature (docs/design/loot-drops/).
--=
--= Item names are what the client prints in chat, so they are language-specific and this file
--= cannot simply copy English.lua. The KEYS are event indices and are shared across all three
--= files: translate the item names, never re-key.
--=
--= An empty table is the correct interim state, not a stub to be worked around. It means the
--= loot feature is inert on a French client -- no popup, no browser rows, no errors -- rather
--= than matching English names against French chat and silently recording nothing.
--=
--= This file is INPUT to LootLogs, produced by the separate cataloguing plugin. See
--= Logs/Drops/English.lua for the row format, including the optional `plural` field that
--= stacked drops need and the `label` that describes an item under its name on screen.
--=================================================================================================

_G.Drops = {}
