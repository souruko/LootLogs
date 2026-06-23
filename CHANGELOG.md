# Changelog

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
