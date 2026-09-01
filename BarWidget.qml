import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "costafot.vrr-status"

  // misc:vrr as Hyprland reports it: 0 off, 1 always on, 2 fullscreen-only.
  property int vrrMode: 0
  // Class of the active window while it is fullscreen; VRR follows it in mode 2.
  property string fullscreenClass: ""

  // A query already in flight was started before this event, so it may read the
  // value the change replaced. Remember the request and re-run once it lands.
  property bool refreshPending: false

  function refresh() {
    if (queryProc.running) {
      refreshPending = true
      return
    }
    refreshPending = false
    queryProc.running = true
  }

  Component.onCompleted: refresh()

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (!event || !event.name) return
      const name = String(event.name)
      // vrr-auto flips misc:vrr on exactly these events, and a config reload
      // re-applies whatever monitors.lua says.
      if (name === "fullscreen" || name === "activewindow" || name === "configreloaded")
        root.refresh()
    }
  }

  Process {
    id: queryProc
    command: ["sh", "-c",
      "win=$(hyprctl -j activewindow 2>/dev/null); [ -n \"$win\" ] || win='{}'; " +
      "hyprctl -j getoption misc:vrr | jq -c --argjson win \"$win\" " +
      "'{vrr: (.int // 0), cls: ($win.class // \"\"), fs: ($win.fullscreen // 0)}'"]
    onRunningChanged: if (!running && root.refreshPending) root.refresh()
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        let state
        try {
          state = JSON.parse(text || "{}")
        } catch (e) {
          return
        }
        if (state.vrr === undefined) return
        root.vrrMode = state.vrr
        root.fullscreenClass = state.fs === 2 ? String(state.cls) : ""
      }
    }
  }

  // "Engaged" = the panel is actually being driven variably right now, not
  // merely allowed to be: mode 1 always is, mode 2 only under a fullscreen window.
  readonly property bool engaged: vrrMode === 1 || (vrrMode === 2 && fullscreenClass !== "")

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰍹"
    active: root.engaged
    opacity: root.engaged ? 1 : 0.45
    tooltipText: root.vrrMode === 0
      ? "VRR off — panel at fixed refresh"
      : root.vrrMode === 1
        ? "VRR always on"
        : root.engaged
          ? "VRR engaged — " + root.fullscreenClass + " fullscreen"
          : "VRR armed for fullscreen"
    onPressed: function () {
      root.refresh()
    }
  }
}
