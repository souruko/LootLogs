# LootLogs

A Lord of the Rings Online plugin that tracks per-character loot lockouts across instances. When you open a loot chest, LootLogs automatically records the lockout and shows a countdown to the next reset.

**Version:** 0.0.0  
**Author:** Souru

---

## Features

- Automatically detects lockouts by watching chat for chest messages — no manual input required
- Tracks lockouts across all characters on your account
- Shows time remaining until reset (as a countdown, a date stamp, or a relative label like "Today" / "Tomorrow")
- Supports daily, tri-weekly (Mon/Thu/Sat), and weekly (Thursday) reset schedules
- Sidebar lets you browse by content pack, instance, character, or server
- Custom List to pin specific events you care about across characters
- QuickLaunch icon with a badge showing how many new lockouts were recorded this session
- Localised UI in English, German, and French (auto-detected from game language)

---

## Covered Content

| Content Pack | Level | Instances |
|---|---|---|
| War of Three Peaks | 140 | Shakalush the Stair Battle, Amdân Dammul the Bloody Threshold, The Fall of Khazad-dûm |
| Fate of Gundabad | 140 | Assault on Dhúrstrok, Den of Pughlak, The Hiddenhoard of Abnankâra |
| Corsairs of Umbar | 150 | The Isle of Storms, Depths of Mâkhda Khorbo |

Tiers tracked per instance vary — Solo, T1, T2, T3, and T4 where applicable.

---

## Installation

1. Download or clone this repository into your LOTRO plugins folder:
   ```
   Documents\The Lord of the Rings Online\plugins\LootLogs\
   ```
2. Launch LOTRO and load the plugin in the chat box:
   ```
   /plugins load LootLogs
   ```
3. To unload after an update:
   ```
   /plugins unload LootLogs
   ```

---

## Usage

### QuickLaunch icon

A small icon appears on screen when the plugin loads. You can drag it anywhere.

- **Right-click** — toggle the main window open/closed; clears the badge count
- **Left-click + drag** — reposition the icon

A red badge appears on the icon and counts up each time a new lockout is recorded during the current session.

### Main window

The window has a two-panel layout:

**Sidebar (left)** — browse by:
- *Content* — navigate content pack → instance → see all boss lockouts for that instance
- *Characters* — select a character to see all their recorded lockouts
- A search box filters the list as you type

**Content view (right)** — shows boss rows for the current selection. Each row displays:
- Boss name and tier
- Lockout status (`Done`, partial progress, or a completion count)
- Time until reset

Click a tier header to add or remove it from your **Custom List**.

### Quickslot command

You can add `/raid locks` (English), `/schlachtzug sperren` (German), or `/raid verrouillé` (French) as an in-game quickslot command to open the window from your toolbar.

---

## Settings

Open via the gear icon in the main window header. Available options:

| Setting | Description |
|---|---|
| Print Alerts | Print a chat message when a lockout is recorded |
| Print Welcome | Print a welcome message on plugin load |
| Show Custom List | Show the Custom List entry in the sidebar |
| Show Servers | Show the server grouping in the Characters tab |
| Show Badge | Show the lockout count badge on the QuickLaunch icon |
| Timezone (UTC offset) | Your UTC offset, used to calculate reset times correctly (default: +1) |
| Time Display | How reset times are shown: countdown (`13h 54m`), date stamp (`Wed 24.06`), or relative label (`Tomorrow`) |
| Display Language | Override the UI language (English / Deutsch / Français) |
| Server | Set which LOTRO server your character is on |

---

## Adding New Content

All game data lives in `Logs/English.lua` (and the corresponding `German.lua` / `French.lua` files). To add a new instance:

1. Add an entry to `_G.Content` if it is a new content pack.
2. Add an entry to `_G.Instances` referencing the `content` index.
3. Add entries to `_G.Events` for each boss chest — set `match` to the exact substring that appears in the chest message, `reset` to the correct schedule, and `tier` to the tier label.

Reset schedules:
- `Daily` — resets every day at 3:00 UTC
- `TriWeek` — resets Monday, Thursday, Saturday at 3:00 UTC
- `Weekly` — resets every Thursday at 3:00 UTC

---

## Servers

LootLogs recognises the following LOTRO servers: Orcrist [EU], Grond [EU], Sting, Peregrin [RP], Meriadoc [EU-RP], Glamdring, Angmar, Mordor [EU].

---

## License

Personal use. Not affiliated with Standing Stone Games or Middle-earth Enterprises.
