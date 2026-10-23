# twilight-shell/compositor

[![ci](https://github.com/twilight-shell/compositor/actions/workflows/ci.yml/badge.svg)](https://github.com/twilight-shell/compositor/actions/workflows/ci.yml)

What a shell needs to know about the Wayland compositor it runs under, the same
for every compositor: workspaces, the focused window and output, the keyboard
layout. Components import it instead of talking to a compositor themselves.

```qml
import Twilight.Compositor

Text { text: Compositor.focusedWindow?.title ?? "empty sky" }
Text { text: Compositor.layout }                       // "EN"
Repeater { model: Compositor.workspaces; /* ... */ }
```

| | |
|---|---|
| `name` | The compositor: `"niri"`, or `""` when it isn't one we know. |
| `workspaces` | `[{ id, idx, name, output, active, focused, urgent, hasWindows }]`, ordered by `idx`. |
| `focusedWindow` | `{ id, title, appId }`, or `null`. |
| `focusedOutput` | Name of the output with the focus, `""` when unknown. |
| `layout`, `layoutIdx` | Short name of the keyboard layout and its place in the list. |
| `focusWorkspace(idx)`, `workspaceUp()`, `workspaceDown()`, `nextLayout()` | Actions. |

Nothing here throws on an unknown compositor: the properties stay empty and the
actions do nothing, so a component still starts, just without workspaces.

## Compositors

| | |
|---|---|
| niri | yes |

The backend is picked from the environment (`NIRI_SOCKET` for niri).

### Adding a compositor

A backend is a file in `Twilight/Compositor/backends/` with the properties and
functions of `Niri.qml`: `active`, `workspaces`, `focusedWindow`, `focusedOutput`,
`layout`, `layoutIdx`, `focusWorkspace`, `workspaceUp`, `workspaceDown` and
`nextLayout`. It translates what the compositor reports into the shapes in the
table above, so components never see a compositor's own names. Then list it in
`Compositor.qml`: detect it in `name` and add it to `backend`.

## Installing

Needs [Quickshell](https://quickshell.org) 0.3 or newer.

```sh
sudo make install                       # to /usr/lib/qt6/qml/Twilight/Compositor
make install PREFIX=~/.local QMLDIR=~/.local/lib/qt6/qml
```

If the module isn't in a directory Qt searches, point `QML_IMPORT_PATH` at its
parent.

## Contributing

Contributions are welcome: see [CONTRIBUTING.md](CONTRIBUTING.md). Agents and the like: [AGENTS.md](AGENTS.md).

## License

MIT, see `LICENSE`.
