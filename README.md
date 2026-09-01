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
ln -s "$(pwd)" ~/.config/omarchy/plugins/costafot.vrr-status
omarchy bar put costafot.vrr-status --section right
omarchy restart shell
```

Requires `jq` (used to merge the two `hyprctl -j` reads into one result).

## License

MIT
