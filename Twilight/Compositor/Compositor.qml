pragma Singleton

import QtQuick
import Quickshell
import "backends"

// What a shell needs to know about the compositor it runs under, the same for
// every compositor: workspaces, the focused window and output, the keyboard
// layout. The backend is picked from the environment.
//
// A backend is an object with `active`, the properties below and the
// functions below; add one by writing it in backends/ and listing it here.
Singleton {
    id: root

    // "niri", or "" when the compositor isn't one we know.
    readonly property string name: Quickshell.env("NIRI_SOCKET") ? "niri" : ""

    readonly property var backend: name === "niri" ? niri : null

    // [{ id, idx, name, output, active, focused, urgent, hasWindows }], by idx.
    readonly property var workspaces: backend?.workspaces ?? []
    // { id, title, appId }, or null when no window has focus.
    readonly property var focusedWindow: backend?.focusedWindow ?? null
    // Name of the output with the focus, "" when unknown.
    readonly property string focusedOutput: backend?.focusedOutput ?? ""
    // Short name of the keyboard layout ("EN") and its place in the list.
    readonly property string layout: backend?.layout ?? ""
    readonly property int layoutIdx: backend?.layoutIdx ?? 0

    function focusWorkspace(idx) {
        backend?.focusWorkspace(idx);
    }

    function workspaceUp() {
        backend?.workspaceUp();
    }

    function workspaceDown() {
        backend?.workspaceDown();
    }

    function nextLayout() {
        backend?.nextLayout();
    }

    Niri {
        id: niri

        active: root.name === "niri"
    }
}
