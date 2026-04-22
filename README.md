# sketchybar config

My personal [sketchybar](https://github.com/FelixKratz/SketchyBar) setup for macOS. Transparent floating bar with [AeroSpace](https://github.com/nikitabobko/AeroSpace) workspace indicators and a Things3 Pomodoro widget.

---

## Layout

```
[mode] [ws1] [ws2] … [ws n] | [things3 todo]        [docker] [bat] [vol] [date/time]
←————————————————— left ————————————————————        ——————————————— right ——————————→
```

### Left side

| Item | Description |
|---|---|
| `aerospace_mode` | Current AeroSpace mode — hidden when in the default `main` mode |
| `space.<id>` | One item per workspace; shows app icons for open windows; clicking switches to that workspace |
| `\|` separator | Visual divider between workspaces and content widgets |
| `things3` | Things3 Today widget + Pomodoro timer (see below) |

### Right side

| Item | Description |
|---|---|
| `calendar` | Date and time, refreshes every 30 s |
| `volume` | System output volume with SF Symbol icons; reacts to `volume_change` events |
| `battery` | Percentage + charging state via `pmset`; updates every 2 min or on power-source change |
| `docker` | Shows `󰡨` when the Docker daemon is running, hidden otherwise; polls every 5 s |

---

## Things3 + Pomodoro

The `things3` widget shows the first incomplete todo from your Things3 **Today** list and lets you run a 20-minute Pomodoro timer against it without leaving the bar.

### Display states

| State | Icon | Label |
|---|---|---|
| Idle — todo loaded | `󰄱` | `Buy oat milk` |
| Timer running | `⏱` | `19:42 – Buy oat milk` |
| Timer paused | `⏸` | `14:07 – Buy oat milk` |
| Timer expired | `⏰` | `00:00 – Buy oat milk` |
| No todos today | `󰄱` | `No todos today` |

### Mouse controls

| Button | Action |
|---|---|
| **Left click** | Open Things3 → Today view |
| **Right click** | Start timer · Pause · Resume (cycles) |
| **Middle click** | Clear / reset the timer |

Every click also **immediately refreshes** the todo from Things3 before acting. If the current todo was completed or cancelled since the last poll, the widget silently advances to the next one and resets the timer.

### Automatic todo rotation

The plugin polls Things3 every **5 minutes** in the background. When the first open todo in Today changes (completed, cancelled, or re-ordered), the timer resets and the new todo appears.

### How it works

The widget is driven by two scripts:

- **`plugins/things3.sh`** — runs every second (`update_freq=1`). Reads state from `/tmp`, calls the `things` CLI only when the 5-minute cache is stale, then updates the bar label.
- **`plugins/things3_click.sh`** — called on any mouse click. Refreshes the todo first, then dispatches on `$BUTTON`.

State is persisted in five temp files under `/tmp/`:

| File | Content |
|---|---|
| `sbar_things3_timer` | Unix timestamp when the timer started (`0` = not running) |
| `sbar_things3_paused` | Remaining seconds at the moment of pause (`0` = not paused) |
| `sbar_things3_uuid` | UUID of the currently displayed todo |
| `sbar_things3_title` | Cached title of the currently displayed todo |
| `sbar_things3_check` | Unix timestamp of the last `things today` query |

Pause/resume works by storing the remaining seconds on pause, then reconstructing a synthetic `TIMER_START = NOW − (1200 − remaining)` on resume so the countdown math stays correct without a separate elapsed counter.

---

## Dependencies

| Tool | Install |
|---|---|
| [sketchybar](https://github.com/FelixKratz/SketchyBar) | `brew install FelixKratz/formulae/sketchybar` |
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | `brew install --cask aerospace` |
| [Things3](https://culturedcode.com/things/) | Mac App Store |
| [things3-cli](https://github.com/ossianhempel/things3-cli) | `brew install things3-cli` |
| [jq](https://jqlang.github.io/jq/) | `brew install jq` |
| [Hack Nerd Font](https://www.nerdfonts.com/) | `brew install --cask font-hack-nerd-font` |
| [BetterDisplay CLI](https://github.com/waydabber/BetterDisplay) *(optional)* | Used for external display volume fallback |

---

## Reload

```bash
sketchybar --reload
```

Enable hotloading (auto-reload on file change):

```bash
sketchybar --hotload true
```

This is already set in `sketchybarrc` so it activates on every full reload.

---

## Structure

```
.
├── sketchybarrc          # Entry point — sources all config files
├── bar.sh                # Global bar geometry and appearance
├── colors.sh             # Colour palette (multiple themes, one active)
├── defaults.sh           # Default item properties + custom event declarations
├── items/                # Item declarations (add + initial set)
│   ├── spaces.sh         # AeroSpace workspace indicators + separator
│   ├── things3.sh        # Things3 / Pomodoro item
│   ├── calendar.sh
│   ├── volume.sh
│   ├── battery.sh
│   └── docker.sh
└── plugins/              # Runtime scripts invoked by sketchybar
    ├── aerospace.sh      # Workspace state (icons, focus highlight, hover)
    ├── aerospace_mode.sh # AeroSpace mode indicator visibility
    ├── things3.sh        # Things3 display + Pomodoro countdown
    ├── things3_click.sh  # Click handler (open / start / pause / clear)
    ├── calendar.sh
    ├── volume.sh
    ├── battery.sh
    └── docker.sh
```

---

## Theming

Colours are defined in `colors.sh`. Several palettes are included and commented out — swap the active block to change the look. The current scheme is a **transparent floating bar** (`BAR_COLOR=0x00000000`) with white accents.

Other included palettes: Miasma, Gruvbox, Nord, Teal, Purple, Red, Blue, Green, Orange, Yellow.
