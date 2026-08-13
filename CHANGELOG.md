# Changelog

Versions are `<major>.<lotro update>.<release>`. The middle number is the LOTRO content update the
build targets, and the last number counts fixes and changes within it, resetting when either of the
numbers above it moves. The leading number moves only for a major overhaul of the plugin itself.

## [4.49.3] - 2026-08-13

### Changed
- An item's label no longer replaces its name. Rows show the name the game itself prints, with the label underneath it in small text as a short description — "Blighted Shoulder-guards of the Endless Flame" with "Runekeeper shoulders red" below it — in the loot popup and the loot browser alike
- Item links and chat alerts read as the real item name too, so a drop you paste into fellowship chat names the thing everyone else sees
- Searching still finds an item by its description, in either window, so whichever of the two names you know gets you to the row
- Chat parsing no longer runs every one of the plugin's ~600 chest patterns against every line the game prints. Each pattern implies literal text a matching line must contain, so the lines are looked up by that text and only the handful of patterns that could possibly match are run — the same matches in the same order, for about a thirtieth of the work
- Reading a loot line stopped searching for the item name with a pattern. The link markup in front of the name is a hundred-odd bytes on the form the game uses for something in your bags, and matching lazily through it cost more than everything else in the loot path put together
- The loot buffer is a ring rather than a list rebuilt on every drop. A six-man run filled and re-copied a 200-entry table for every item anybody picked up, at exactly the moment the client was busiest
- A chest line that records nothing no longer saves the whole log file and rebuilds the window. Saving copies every character's lockouts twice over, and it was running on matches that had changed nothing at all
- With the window closed, a chest no longer rebuilds a table nobody is looking at. The rebuild is banked and paid when the window opens, so what is on screen is never stale
- The window's own lookups ask for one instance's chests instead of filtering all of them, once per tier per instance per redraw
- Drop chances are worked out once per item per chest instead of on every redraw, so typing in the popup's search box no longer re-reads the chest's whole loot table for every row on every keystroke

## [4.49.2] - 2026-08-12

### Changed
- The loot browser lists every item once per chest. The game's tables list an item once per roll it can come out of, so the same cloak appeared eight times at eight different rates and none of them told you how likely the cloak actually was
- Every row now leads with the chance the item drops *at all* from that chest, with the individual rates printed behind it — the only figure that can be compared between an item that comes out of one roll and an item that comes out of six
- A small bar beside that figure, so a page of sub-1% items can be sorted by eye instead of read digit by digit
- The browser opens on the highest tier rather than the lowest, and changing tier keeps you on the boss you were reading
- The browser shows one chest at a time. The bosses of an instance share most of their loot, so listing them together was the same rows over again, and no rate on the page meant anything until you had found which boss you were under
- Every count in the browser counts items now instead of table rows — the sidebar used to say 308 beside a table showing 91
- The loot popup separates what dropped into Starred, Yours and Fellowship
- Anything you starred leads the popup, including when somebody else won it — and that case has its own colour now, so it can never be read as your own loot
- Every popup row carries the item's drop chance, the same figure the browser gives, and anything under 2% is coloured so a rare hit reads as rare
- The popup lists the rarest drop first inside each section, instead of grouping by item type
- The boss chips say how much each chest gave, and "Full run" is now "Run · 11" — a count worth pressing

### Removed
- The folding group rows in the browser, with their icon strips and "+19". Every item in the pool is now listed once and priced, so there is nothing left for a fold to hide
- The Slot column, which the loot tables never filled. Its width pays for the drop rates beside it

## [4.49.1] - 2026-08-10

### Added
- Traceries now count as one thing. Everyone gets one from a chest but the name is class-specific, so the popup lists "Tracery" once per person instead of six differently-named rare drops, and the browser shows one row whose measured rate is how often a tracery drops at all
- Armour categories fold instead. "Fallen armour" is one row in the browser carrying the category's chance, and clicking it opens the list of pieces underneath — and when a piece actually drops, the popup names the piece, not the category
- Pagru-kirít is catalogued from the game's own loot tables: all three chests on Solo, Tier 1, Tier 2 and Tier 3, 1,369 drops with an exact chance on every one. Not estimates and not community figures — the rates the server actually rolls
- Nearly every one of those carries its item id, so the browser and the popup show real icons and real tooltips throughout, and every item is a clickable link
- Each roll a chest makes is its own foldable row showing that roll's chance, with what it can give underneath. A chest makes several, so an item can appear more than once — Badge of Forgotten Rank at Sudûgul Tier 3 drops on its own 70% of the time *and* comes up inside another roll, and those are two separate chances, not one
- Rolls from a repeat run are marked as such, so the second table a chest uses once its lock is spent is not mistaken for a duplicate of the first
- Groups can be given a real name. The loot tables export them as "Group 1" through "Group 11", and a `label` in the group declaration renames one wherever it appears without touching the rows underneath it
- The loot browser's Item column has a search button of its own. Click the magnifier in the column header and type where you are already looking, instead of reaching back to the box beside the tree — the two are the same search, so whichever you type in, both show it
- Searching narrows what you are looking at rather than sending you somewhere else: it filters the chest and tier you have open, and typing filters rows that are already drawn instead of rebuilding the table on every keystroke, so it keeps up with you
- A search that matches something inside a group shows the group as well. A folded "Fallen Armour" is the only row standing in for the pieces underneath it, so searching for a helm still finds the chest that drops it
- Every item the plugin names is a proper item link now — in the popup, in the loot browser and in chat. Bracketed and clickable, the same as the ones the game prints, so you can examine a drop or link it to your fellowship straight from the window

### Changed
- A grouped row in the loot browser now looks like the heading it is. It used to borrow the first item of the group — that item's icon, that item's colour, and a link that examined it — so a row meaning "any piece of this set" looked exactly like one pair of gloves. It now sits on a band of its own with a fixed group mark where the art was, and its name is plain text rather than an item link, because that name is a category and answers to no item
- Wishlisted drops sort to the top of the loot popup, above your own loot. The window opens on its own and is read in a second — the one thing it should never do is put what you have been waiting for below the fold
- The loot popup has a ceiling now. It grows to fit what dropped up to eight rows and then scrolls, instead of running off the screen when a chest gives out a lot — it opens on its own, so it should never be the biggest thing on screen
- Item icons no longer carry a stack count. They used to be drawn as quickslots, which paint how many you happen to be carrying over the art — a number that means nothing next to a drop chance about the world. The icon is now just the item's picture, and the tooltip comes from the name link beside it
- Looting a chest no longer lists every drop in chat as well as in the popup — the game already prints each loot line itself, so chat now gets one summary line and the popup does the rest. The full list still goes to chat when no popup opens, so a chest is never silently unreported

### Fixed
- Window titles are no longer cut off. "Loot Browser" lost its last letters to a title bar that never sized its text to the bar
- Running the same instance twice no longer mixes the two together: entering starts a fresh run, so the popup's boss chips show this clear's loot and not the previous one's
- Stacks of a thousand or more are counted correctly — a "1,000" stack was read as a single item, and its name was not recognised at all

## [4.49.0] - 2026-08-09

### Added
- A loot popup opens when you loot a chest, listing what dropped and who in the fellowship got it, with your own loot marked and the rows grouped by looter
- Chips along the top of the popup switch between the bosses of the run, or show everything looted so far in one list
- The popup stays quiet on purpose: only drops worth your attention appear in it, barter currency and filler stay out, and a chest that drops nothing notable opens no window at all
- A loot browser, from the new chest icon in the window header or `/lootlogs drops` — every known drop per boss and tier, its chance, your own measured rate beside it, and a star to add it to your wishlist
- Your wishlist is shared across all your characters, while what you have already collected is tracked per character, and a "Still needed" filter hides what this one already has
- Items in both windows show their real icon and the game's own tooltip
- Search in the loot browser looks across every instance, so it answers "where does this drop"
- Commands: `/lootlogs` (or `/ll`) for the list, `/lootlogs drops` for the browser, `/lootlogs loot` to reopen the last chest's popup

### Notes
- Measured drop rates always show how many times you have opened that chest, and stay greyed until ten opens — a one-off "100%" next to a listed 12% is worse than no number
- Loot messages must stay switched on in at least one chat tab, or the plugin never sees them and nothing is recorded

## [3.49.2] - 2026-08-08

### Changed
- Instance names in the Pinned view now stand clearly apart from the tiers beneath them: each instance starts a new block with a gap above it and a brighter bar, and its tiers are stepped in underneath
- A thin line under every tier row stops two tiers listed back to back from running together
- Character names line up under the tier they belong to
- The star on the Pinned tab and in the legend along the bottom is smaller, so it reads as a mark rather than a button

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
