# AGENTS.md — Sketchybar Configuration Guide

## Overview

This is a Bash-based macOS menu bar configuration for [sketchybar](https://felixkratz.github.io/SketchyBar/). The codebase follows a **dual-layer architecture**:

- **`items/`** — Item declarations (bar structure, appearance, event subscriptions)
- **`plugins/`** — Runtime scripts (data fetching, UI updates on events/timers)

**Entry point:** `sketchybarrc` sources all config files and triggers initial bar setup.

Local reference docs live in `docs/` — see the sections below for a summary of each.

---

## Build / Reload Commands

There is no formal build process. To reload after edits:

```bash
sketchybar --reload
```

To enable automatic hotloading (reloads on any file change in the config dir):

```bash
sketchybar --hotload true
```

Run the bar with verbose output for debugging:

```bash
sketchybar
```

---

## Directory Structure

| Dir | Purpose |
|---|---|
| `items/` | Item declarations — each file creates one bar item via `sketchybar --add item ...` |
| `plugins/` | Runtime scripts — invoked by sketchybar on events/timers; fetch data and update items |
| `plugins/sketchymenu/` | App menu integration (JXA, AppleScript, click dispatch) |
| `helpers/` | Shared utilities (icon maps, data tables) |
| `backup_*/` | Snapshots of working configs (do not modify) |
| `docs/` | Local copy of the official sketchybar documentation |

---

## Sketchybar Concepts (from `docs/`)

### Bar (`docs/config/Bar.md`)

Global bar properties are set via:

```bash
sketchybar --bar <setting>=<value> ...
```

Key settings: `color`, `position` (`top`/`bottom`), `height`, `margin`, `corner_radius`, `blur_radius`, `padding_left`, `padding_right`, `display`, `hidden`, `topmost`, `sticky`, `shadow`.

Colors use `argb_hex` format: `0xAARRGGBB`.

### Items (`docs/config/Items.md`)

Items are the building blocks of the bar — each has an icon and a label.

```bash
sketchybar --add item <name> <position>   # position: left, right, center, q, e
sketchybar --set <name> <property>=<value> ...
sketchybar --default <property>=<value> ... # applies to all subsequent items
```

Property groups: **geometry** (`drawing`, `space`, `display`, `width`, `padding_*`, `y_offset`), **icon**, **label**, **scripting** (`script`, `click_script`, `update_freq`, `updates`), **background**, **image**, **shadow**, **text**.

Item manipulation: `--reorder`, `--move <name> before/after <ref>`, `--clone`, `--rename`, `--remove`.

### Events & Scripting (`docs/config/Events.md`)

```bash
sketchybar --subscribe <name> <event> ...
```

Built-in events: `front_app_switched`, `space_change`, `space_windows_change`, `display_change`, `volume_change`, `brightness_change`, `power_source_change`, `wifi_change`, `media_change`, `system_will_sleep`, `system_woke`, `mouse.entered`, `mouse.exited`, `mouse.clicked`, `mouse.scrolled`, and their `.global` variants.

Scripts receive `$NAME`, `$SENDER`, `$CONFIG_DIR`. Click scripts also get `$BUTTON` and `$MODIFIER`. Scroll scripts get `$SCROLL_DELTA`. All scripts are killed after 60 s.

Custom events:

```bash
sketchybar --add event <name> [<NSDistributedNotificationName>]
sketchybar --trigger <event> [<envvar>=<value> ...]
sketchybar --update   # force-run all scripts (use only at init, not inside item scripts)
```

### Components (`docs/config/Components.md`)

Special item types with extra capabilities:

| Component | Add syntax | Notes |
|---|---|---|
| `graph` | `--add graph <name> <position> <width>` | Push data with `--push <name> <float 0-1>` |
| `space` | `--add space <name> <position>` | Gets `$SELECTED`, `$SID`, `$DID` in script |
| `bracket` | `--add bracket <name> <member> ...` | Groups items under a shared background |
| `alias` | `--add alias <app_name> <position>` | Mirrors a native macOS menu bar item |
| `slider` | `--add slider <name> <position> <width>` | Draggable progression indicator; gets `$PERCENTAGE` on click |

### Popup Menus (`docs/config/Popup.md`)

Every item has a popup. Show it by setting `popup.drawing=on`. Add items to a popup by setting their position to `popup.<parent_name>`.

```bash
sketchybar --set <name> popup.drawing=on \
                        popup.background.color=0xff1e1e2e \
                        popup.corner_radius=9
```

### Animations (`docs/config/Animations.md`)

Animate any `argb_hex` / integer transition:

```bash
sketchybar --animate <curve> <duration> --set <name> <property>=<value>
```

Curves: `linear`, `quadratic`, `tanh`, `sin`, `exp`, `circ`. Duration is frame count at 60 Hz. Chain animations by passing multiple values for the same property in one call.

### Querying (`docs/config/Querying.md`)

```bash
sketchybar --query bar
sketchybar --query <item_name>
sketchybar --query defaults
sketchybar --query events
sketchybar --query default_menu_items
sketchybar --query displays
```

### Types (`docs/config/Types.md`)

| Type | Values |
|---|---|
| `<boolean>` | `on`, `off`, `yes`, `no`, `true`, `false`, `1`, `0`, `toggle` |
| `<argb_hex>` | `0xAARRGGBB` (alpha, red, green, blue) |
| `<path>` | Absolute file path |
| `<string>` | Any UTF-8 string |
| `<float>` | Floating point number |
| `<positive_integer list>` | Comma-separated positive integers |

Boolean properties can be negated: `!on`. Color channels can be set individually, e.g. `color.alpha=0.5`.

### Tips & Tricks (`docs/config/Tricks.md`)

- **Batch commands** — chain multiple `--bar`/`--add`/`--set`/`--subscribe` in one `sketchybar` call to reduce redraws and startup time.
- **Bash arrays** — use `bar=(height=32 ...)` and `sketchybar --bar "${bar[@]}"` for cleaner config.
- **Icons** — default font is Hack Nerd Font; also supports SF Symbols (`brew install --cask sf-symbols`).
- **Multiple bars** — symlink the `sketchybar` binary under a new name; its config lives in `~/.config/<name>/`.
- **Performance** — use event-driven scripting over polling; set `updates=when_shown` for off-screen items; avoid aliases for apps that aren't always running.

---

## Known Quirks & Vestigial Code

1. **`icons.sh` dual-section bug** — Lines ~134+ contain a second shebang and duplicate icon definitions. Ignore the second section; use only the first `ICON_*` definitions.

2. **`icon_map_fn.sh` missing shebang** — This file has no shebang line but is invoked as a script. It relies on the calling shell being bash-compatible. Consider adding `#!/bin/bash` if it causes issues.

3. **`settings.sh` is mostly unused** — It was designed as a richer abstraction layer (dark/light mode switching, complete bar/default/popup arrays) but the active config bypasses it. It is sourced only by `items/network_rates.sh`. Do not delete it, but do not expand its use.

4. **Commented-out items in `sketchybarrc`** — Many item sources are commented out (`front_app`, `cpu`, `wifi`, `caffeinate`). They are functional; uncomment to activate.

5. **`media_change` event deprecated on macOS 26.0** — Do not rely on it for new now-playing integrations.

---

## Active Items

Currently enabled in `sketchybarrc`:

| Item | Plugin | Purpose |
|---|---|---|
| `spaces` | `aerospace.sh` | Workspace indicators (Aerospace) |
| `now_playing` | `now_playing.sh` | Music player status (MPD/Spotify/Apple Music) |
| `calendar` | `calendar.sh` | Date/time widget |
| `volume` | `volume.sh` | Audio level indicator |
| `battery` | `battery.sh` | Battery percentage |
| `docker` | `docker.sh` | Docker daemon status |

To activate additional items, uncomment the corresponding `source` line in `sketchybarrc`.

---

## Testing a Plugin Directly

To manually test a plugin without reloading the entire bar:

```bash
export CONFIG_DIR="$HOME/.config/sketchybar"
export PLUGIN_DIR="$CONFIG_DIR/plugins"
export NAME="now_playing"  # Set the item name

# Run the plugin script
"$PLUGIN_DIR/now_playing.sh"
```

This simulates how sketchybar invokes the script and allows debugging.
