# Changelog

Versions are `3.<lotro update>.<release>`. The leading 3 is fixed, the middle number is the LOTRO
content update the build targets, and the last number counts fixes and changes within it.

## [3.49.1] - 2026-07-31

### Changed
- The plugin now always starts with its window closed — open it from the quickslot icon when you want it

## [3.49.0] - 2026-07-30

### Added
- Each instance in the sidebar now shows a row of small squares, one per tier, telling you at a glance where the character you're playing still has runs left
- Boss names are always visible as column headers instead of appearing only when you hover a value; hover a name to see it in full
- Values are now coloured chips — "2 common", "1 favour", a tick for done — with a legend along the bottom explaining them
- Tier rows say when they reset in plain words, like "weekly · Thu 03:00"
- The character you're logged in as is marked everywhere: a CURRENT tag in the sidebar and a highlighted name in every table
- Reset countdowns turn amber in their last three days
- Trackers that carry over instead of resetting when you don't finish them are now marked
- Instances in a content pack, and packs and instances in the character view, can be collapsed; a collapsed instance shows a one-line summary with its next reset
- Settings can now clear the logs of the character you're playing
- Font Size setting with three steps, so the smaller labels can be made readable; rows and columns grow with the text

### Changed
- The window has been redrawn from scratch: its own slim frame, a compact title bar, and panels that match across every view
- The settings gear and the quickslot moved into the title bar, and the footer bar and its clock are gone
- Custom List is now called Pinned and shares a single row of tabs with Content and Characters
- Searching expands matching groups on its own and shows how many matches each one holds
- Instances with five or more chests switch to a narrower table with short codes so every chest still fits
- Locked and done are now the same chip — you can't run either, so they no longer look different
- Instances you've never touched sink to the bottom of a content pack instead of sitting in the middle
- Settings is laid out in two columns, and every theme has its own row with a colour preview
- The Rivendell theme was recoloured to match the Gibberish options panel
- The character buttons now read "clear logs" and "delete" instead of "clr" and "del"
- All icons redrawn

### Fixed
- The Print Alerts setting did nothing at all — switching it off now genuinely stops the alerts, and the setting is no longer labelled with its internal name
- Class icons were invisible and cut off; they now show properly in the sidebar and in every header
- Long boss names no longer run over each other in the column headers

## [3.0.13] - 2026-07-27

### Changed
- Character and per-character instance rows now show one compact line per tier with all boss/quest values side by side (hover a value to see which boss/quest it belongs to), instead of a separate line per boss

### Fixed
- Quicklaunch notification badge no longer stretches or shifts out of place — it now stays a fixed size and correctly positioned on the icon
- Instance completion messages (favoured/common/locked chest states) are now matched correctly on French and German clients instead of only on English ones

## [3.0.12] - 2026-07-24

### Added
- Quicklaunch icon size setting (Settings → Display) to resize the draggable quicklaunch button and its badge, 30–80px in 5px steps

## [3.0.11] - 2026-07-24

### Fixed
- Login recalculation of extended lockouts (bosses with `onlyResetIfDone` that weren't completed) now correctly flags the log as changed so the recalculated `timeOfDeath` is actually saved

## [3.0.10] - 2026-07-23

### Added
- On login, lockouts that were extended instead of cleared (bosses with `onlyResetIfDone` that weren't completed) are now reported in a separate `extended` alert section showing the new time remaining

### Changed
- Plugin renamed from `LootLogsBeta` to `LootLogs` for release
- Welcome message on login is now grouped by instance then by tier; tiers whose bosses share a single reset schedule (`Solo`, `T1`–`T5`, `T3+`) are collapsed into one summary line instead of one line per boss
- Reset alerts on login are now grouped the same way (by character, instance, and tier) instead of printing one line per boss
- Hovering a boss value in an instance's character row now shows the boss name in the content header instead of a floating tooltip

### Fixed
- Instance character rows no longer stop rendering boss value columns partway through the row when an earlier boss had no logged value (a `nil` placeholder was breaking `ipairs` iteration over the row's values)
- `LootLogs.plugincompendium` descriptor updated to point at `LootLogs.plugin` instead of the removed `LootLogsBeta.plugin`
- Fixed several syntax errors in `Logs/German.lua` (`==` used instead of `=`, and a handful of table entries truncated mid-line) that would crash the plugin on German clients
- Remaining untranslated English instance names in the German log corrected (Hurum Kâna caves, Nagakhêdi, Abnankâra, Sarch Vorn, Caras Gelebren)

## [3.0.9] - 2026-07-19

### Changed
- On plugin load, the selection is now fixed: if the custom list is enabled and has at least one instance/tier selected, the custom list view is selected; otherwise the current character is selected

## [3.0.8] - 2026-07-19

### Changed
- Characters listed in a boss row are now sorted with completed (`"Done"`) characters first, followed by the remaining characters, each group alphabetically

## [3.0.7] - 2026-07-14

### Fixed
- Character entries loaded from older save formats without a `logs` sub-table no longer crash on startup; missing `logs` fields are now initialized to `{}` immediately after load
- German match strings for Doom of Caras Gelebren T3 corrected to translated German chest names (`Großes/Größeres Geschenk der Mírdain`)
- German match strings for Umbar weeklies, Missions, and Delvings progress events had their `Abgeschlossen:.` prefix removed so they now match the actual in-game completion message format
- Filter input box in the sidebar now has a 4 px left margin so it no longer overlaps the sidebar border

### Changed
- Characters who have completed a boss (value `"Done"`) are now shown with underline formatting in the boss row character list

## [3.0.6] - 2026-07-09

### Fixed
- `FindCurrentCharacter()` now compares server as well as name, so same-named characters on different servers are no longer treated as the same character
- Legacy character entries without a server field are matched by name only and have their server backfilled on first login

## [3.0.5] - 2026-07-07

### Added
- Euro-safe save/load for German and French clients: all save files are written twice (normal and `_Euro` variant where numeric keys and values are serialised as strings), and DE/FR clients load from the `_Euro` file to avoid locale-specific decimal-separator corruption

### Changed
- Boss rows in the content view now wrap characters across multiple lines (3 per line) instead of truncating at 3 with a `···` tooltip, so all locked-out characters are always visible

## [3.0.4] - 2026-07-01

### Fixed
- Collapse all button now works when the custom list tab is active; it collapses based on whichever tab (Characters or Content) was last selected

### Changed
- Custom list is now saved per server (`DataScope.Server`) instead of per account, so each server maintains its own independent custom list

## [3.0.3] - 2026-06-27

### Changed
- Welcome message now includes the loot value alongside each active lockout entry
- Welcome message spacing streamlined for consistency

## [3.0.2] - 2026-06-25

### Changed
- Reset alerts on login are now sorted by content view order (instance descending, tier descending, boss order ascending, character name ascending) instead of random iteration order
- Reset alerts now print under a `LootLogs — resets` header to visually separate them from the active-lockouts welcome message
- Character names in reset alerts and the "resets" header label are now shown in red to distinguish them from the welcome section

## [3.0.1] - 2026-06-23

### Added
- Characters in the sidebar are now sorted by level (descending) then alphabetically by name within each server group and in the flat character list

### Changed
- Wulf theme updated to hot pink / neon pink color palette
- Tier column in boss tier rows widened for improved layout
- `FormatTimeSpan` exposed as a global function for consistent use across modules

### Fixed
- Log reset logic now conditionally calculates death time based on `onlyResetIfDone` flag instead of always resetting
- Various English log entry corrections
- Badge clearing in QuickLaunch mouse event handling streamlined
