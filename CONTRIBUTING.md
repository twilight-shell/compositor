# Contributing to compositor

Thank you for helping. The guide for every repository of the organization is [here](https://github.com/twilight-shell/.github/blob/main/CONTRIBUTING.md): how to propose a change, the commit messages, the checks and the code style. What follows is what is particular to this repository.

## Working on it

- **What it needs:** nothing from the other components.
- **Tests:** there is no test for the screen: run it and look, and say in the pull request what you tried and on which compositor.
- **Before sending:** run the checks of the guide (`ci/run-tests.sh`, `check-settings.sh`, `check-depends.sh`, `check-install.sh` from the `.github` repository) and add a line to `CHANGELOG.md` under `## Unreleased`.

## Good to know

- To support another compositor, add a backend with the same properties and functions as `Niri.qml` and let `Compositor.qml` pick it. Keep the shape of the data the same: `workspaces` is a list of `{ id, idx, name, output, active, focused, urgent, hasWindows }`.
- Nothing here imports `Twilight.Core`; keep it that way.

For security problems, please don't open an issue: see [SECURITY.md](https://github.com/twilight-shell/.github/blob/main/SECURITY.md).
