# LootLogs

**Version:** 4.49.3 | **Author:** Souru

LootLogs is a Lord of the Rings Online plugin that automatically tracks your loot lockouts across instances and characters. When you open a chest in a raid or instance, LootLogs detects the chat message and records the lockout — no manual input needed. A countdown shows exactly when each lockout resets.

### Getting started

After loading the plugin, a small **QuickLaunch icon** appears on screen. Right-click it to open the main window. You can drag the icon anywhere on screen.

The main window has two panels:
- **Sidebar (left)** — browse lockouts by Content, Instance, or Character. Use the search box to filter.
- **Content view (right)** — shows each boss/event with its tier, lockout status, and time until reset.

To open the window from a quickslot, add `/raid locks` (EN), `/schlachtzug sperren` (DE), or `/raid verrouillé` (FR) as an in-game command.

### Important: set your timezone

Reset times are calculated from **UTC+0**. Go to **Settings** (gear icon in the window header) and set your **Timezone (UTC offset)** to your local UTC offset — otherwise countdown times will be off. The default is UTC+1.

### What gets tracked

Lockouts are recorded per character and stored account-wide, so you can see all your alts in one place. Use the **Characters** tab in the sidebar to switch between them. The **Custom List** lets you pin specific events across all characters for a quick overview.

---

## Features

- Automatically detects lockouts by watching chat for chest messages — no manual input required
- Tracks lockouts across all characters on your account
- Shows time remaining until reset (as a countdown, a date stamp, or a relative label like "Today" / "Tomorrow")
- Supports daily, tri-weekly (Mon/Thu/Sat), and weekly (Thursday) reset schedules
- Sidebar lets you browse by content pack, instance, character, or server
- Custom List to pin specific events you care about across characters
- QuickLaunch icon with a badge showing how many new lockouts were recorded this session
- A **loot popup** when a chest is opened, listing what dropped and who got it
- A **loot browser** with the drop database per boss and tier, your own observed rates, and a wishlist
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
| Show Loot Popup | Show the loot popup when a chest is opened |
| Popup only for wishlist | Only pop up when something you starred drops |
| Loot window after chest | How long after the chest message a loot line still counts as that chest's (default 4s) |
| Display Language | Override the UI language (English / Deutsch / Français) |
| Server | Set which LOTRO server your character is on |

---

## Loot Drops

When you open a chest, LootLogs reads the loot lines that follow it and shows a **loot popup**:
what dropped, who in the fellowship got it, with your own loot highlighted. Chips along the top
switch between the bosses of the run, or show the whole run at once.

The popup is deliberately quiet. It only lists drops the database marks as worth showing, so
barter currency and filler stay out of it, and a chest that drops nothing notable opens no
window at all.

The **loot browser** — the chest icon in the window header, or `/lootlogs drops` — lists the
database itself: content pack → instance → boss on the left, and for the selected tier a table
of every catalogued item with its drop chance, your own measured rate beside it, and a star to
add it to your wishlist. The wishlist is shared across all your characters; what you have
already collected is per character, and the **Still needed** filter uses it. Search finds an
item across every instance, which answers "where does this drop".

Measured rates always show their sample size, and are greyed until you have opened that chest
ten times — a one-of-one drop reading "100%" next to a database value of 12% is worse than no
number at all.

### Keep loot messages visible

LootLogs can only see what the chat system sends it. **Loot messages must stay enabled in at
least one chat tab**, or the plugin never receives them and nothing is recorded. Standard chat
timestamps are fine either way.

### Commands

| Command | What it does |
|---|---|
| `/lootlogs` | List the available commands (`/ll` also works) |
| `/lootlogs drops` | Open or close the loot browser |
| `/lootlogs loot` | Reopen the popup for the last chest you opened |

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
