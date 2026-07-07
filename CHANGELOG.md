# Changelog

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
