# omarchy-vrr-status

Omarchy shell bar widget showing the live state of Hyprland's variable
refresh rate (`misc:vrr`).

A monitor icon sits in the bar: dim while VRR is off or merely armed, lit
while the panel is actually being driven variably. The tooltip spells out
the current mode:

- **VRR off** — panel at fixed refresh (`misc:vrr = 0`)
- **VRR always on** (`misc:vrr = 1`)
- **VRR armed for fullscreen** (`misc:vrr = 2`, nothing fullscreen)
- **VRR engaged — \<class\> fullscreen** (`misc:vrr = 2` with a fullscreen window)

It is event-driven — no polling. The widget re-reads `misc:vrr` on
Hyprland's `fullscreen`, `activewindow`, and `configreloaded` events, which
covers both manual changes and daemons that flip VRR at runtime (it was
built as the dashboard for a `vrr-auto` daemon that enables VRR only while
a game is fullscreen). Clicking the icon forces a re-read.

## Install

```bash
omarchy plugin add https://github.com/CostaFot/omarchy-vrr-status --enable
```

Remove it again with `omarchy plugin remove costafot.vrr-status`.

For hacking on it, symlink a checkout instead:

```bash
ln -s "$(pwd)" ~/.config/omarchy/plugins/costafot.vrr-status
omarchy bar put costafot.vrr-status --section right
omarchy restart shell
```

Requires `jq` (used to merge the two `hyprctl -j` reads into one result).

## The vrr-auto daemon

The repo also ships [`vrr-auto`](vrr-auto), the daemon the widget was built
around. Some panels (here: a Gigabyte M32Q on NVIDIA) visibly flicker under
VRR at video frame rates — a fullscreen 24–60fps video drags the refresh
rate to the bottom of the FreeSync range and bounces it on every overlay
redraw. Games running high-fps don't have that problem, so the daemon gets
you both: keep `misc:vrr = 0` as your config baseline, and it flips VRR on
only while a fullscreen window matches a game-class regex (`steam_app_*`
for Proton titles, plus native classes like `dota2`; override with the
`VRR_GAME_CLASS` env var). It sends a `notify-send` toast on every switch,
listens on Hyprland's event socket (no polling), and re-asserts its state
after config reloads.

Install: copy (or symlink) `vrr-auto` somewhere on your `PATH` and launch
it from your Hyprland autostart, e.g. in `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start(os.getenv("HOME") .. "/.local/bin/vrr-auto")
```

Needs `socat` and `jq`. Note: on Omarchy's Lua-configured Hyprland,
`hyprctl keyword` is rejected — the daemon uses
`hyprctl eval 'hl.config({ misc = { vrr = N } })'` instead.

## License

MIT
