import QtQuick
import Quickshell
import Quickshell.Io

// niri, kept in sync through `niri msg --json event-stream`. Every backend
// has the same properties and functions as this one; see Compositor.qml.
Scope {
    id: root

    // Whether to follow the compositor at all.
    property bool active: false

    property var workspaces: []
    property var focusedWindow: null
    property string focusedOutput: ""
    property var layouts: []
    property int layoutIdx: 0
    readonly property string layout: shortLayoutName(layouts[layoutIdx] ?? "")

    // niri's own records, as they arrive.
    property var rawWorkspaces: []
    property var rawWindows: ({})
    property int focusedWindowId: -1

    function focusWorkspace(idx) {
        action("focus-workspace", String(idx));
    }

    function workspaceUp() {
        action("focus-workspace-up");
    }

    function workspaceDown() {
        action("focus-workspace-down");
    }

    function nextLayout() {
        action("switch-layout", "next");
    }

    function action(...args) {
        Quickshell.execDetached(["niri", "msg", "action", ...args]);
    }

    function shortLayoutName(name) {
        const known = { "English (US)": "EN", "Russian": "RU" };
        return known[name] ?? name.slice(0, 2).toUpperCase();
    }

    function publishWorkspaces() {
        workspaces = rawWorkspaces.map(ws => ({
            id: ws.id,
            idx: ws.idx,
            name: ws.name ?? "",
            output: ws.output ?? "",
            active: ws.is_active,
            focused: ws.is_focused,
            urgent: ws.is_urgent,
            hasWindows: ws.active_window_id !== null && ws.active_window_id !== undefined
        }));
        focusedOutput = rawWorkspaces.find(ws => ws.is_focused)?.output ?? "";
    }

    function publishWindow() {
        const w = rawWindows[focusedWindowId];
        focusedWindow = w ? { id: w.id, title: w.title ?? "", appId: w.app_id ?? "" } : null;
    }

    function handle(ev) {
        if (ev.WorkspacesChanged) {
            rawWorkspaces = ev.WorkspacesChanged.workspaces.sort((a, b) => a.idx - b.idx);
            publishWorkspaces();
        } else if (ev.WorkspaceActivated) {
            const { id, focused } = ev.WorkspaceActivated;
            const output = rawWorkspaces.find(ws => ws.id === id)?.output;
            rawWorkspaces = rawWorkspaces.map(ws => Object.assign({}, ws, {
                is_active: ws.output === output ? ws.id === id : ws.is_active,
                is_focused: focused ? ws.id === id : ws.is_focused
            }));
            publishWorkspaces();
        } else if (ev.WorkspaceActiveWindowChanged) {
            const { workspace_id, active_window_id } = ev.WorkspaceActiveWindowChanged;
            rawWorkspaces = rawWorkspaces.map(ws => ws.id === workspace_id
                ? Object.assign({}, ws, { active_window_id })
                : ws);
            publishWorkspaces();
        } else if (ev.WorkspaceUrgencyChanged) {
            const { id, urgent } = ev.WorkspaceUrgencyChanged;
            rawWorkspaces = rawWorkspaces.map(ws => ws.id === id
                ? Object.assign({}, ws, { is_urgent: urgent })
                : ws);
            publishWorkspaces();
        } else if (ev.WindowsChanged) {
            const map = {};
            for (const w of ev.WindowsChanged.windows) {
                map[w.id] = w;
                if (w.is_focused)
                    focusedWindowId = w.id;
            }
            rawWindows = map;
            publishWindow();
        } else if (ev.WindowOpenedOrChanged) {
            const w = ev.WindowOpenedOrChanged.window;
            rawWindows = Object.assign({}, rawWindows, { [w.id]: w });
            if (w.is_focused)
                focusedWindowId = w.id;
            publishWindow();
        } else if (ev.WindowClosed) {
            const map = Object.assign({}, rawWindows);
            delete map[ev.WindowClosed.id];
            rawWindows = map;
            publishWindow();
        } else if (ev.WindowFocusChanged) {
            focusedWindowId = ev.WindowFocusChanged.id ?? -1;
            publishWindow();
        } else if (ev.KeyboardLayoutsChanged) {
            layouts = ev.KeyboardLayoutsChanged.keyboard_layouts.names;
            layoutIdx = ev.KeyboardLayoutsChanged.keyboard_layouts.current_idx;
        } else if (ev.KeyboardLayoutSwitched) {
            layoutIdx = ev.KeyboardLayoutSwitched.idx;
        }
    }

    Process {
        id: stream

        running: root.active
        command: ["niri", "msg", "--json", "event-stream"]

        stdout: SplitParser {
            onRead: line => {
                try {
                    root.handle(JSON.parse(line));
                } catch (e) {
                    console.warn("niri: bad event:", e);
                }
            }
        }

        // niri restarted or the socket dropped: reconnect.
        onExited: if (root.active) reconnect.start()
    }

    Timer {
        id: reconnect

        interval: 1000
        onTriggered: stream.running = root.active
    }
}
