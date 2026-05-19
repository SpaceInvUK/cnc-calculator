# CNC Calculator

Single-file FAST CNC calculator for Doors and Panneling.

## Open The App

Main file:

- `Cnc Calculator UI Test.html`

If this repository is published with GitHub Pages, open:

```text
https://<github-user>.github.io/<repo-name>/Cnc%20Calculator%20UI%20Test.html
```

Local test server:

```powershell
cd "C:\Users\ednei\Documents\CNC App"
python -m http.server 8765 --bind 127.0.0.1
```

Then open:

```text
http://127.0.0.1:8765/Cnc%20Calculator%20UI%20Test.html
```

## Important Files

- `Cnc Calculator UI Test.html` - active development/test app.
- `CNC Calculator Handoff - regras e pendencias.txt` - full original handoff with all broad app rules and pending items.
- `docs/PANNELING_IMPLEMENTATION_2026-05-19.md` - what was changed in this pass, current Panneling rules, QA notes, and GitHub instructions.

## Hard Rules

- Keep the tab spelling as `Panneling`.
- Do not touch `Cnc Calculator 1.0.html` unless explicitly requested.
- Do not deploy to Netlify unless explicitly requested.
- Keep this app as a single-file HTML app unless a later task explicitly asks for a build system.
- Preserve 7mm sheet margin and 7mm spacing between nested parts.

## Latest Panneling Work

Implemented in `Cnc Calculator UI Test.html`:

- Added per-wall `Panel Orientation`.
- Vertical wall orientation makes all panels in that wall vertical.
- Vertical wall panels default to regular shape.
- Individual vertical panels are still supported from Part Dimensions.
- Vertical panels use max width `1206mm`.
- Vertical panels use exact height `3000mm` unless manually overridden.
- Vertical panels start with 2 shaker rows per column.
- The bottom shaker row matches the horizontal shaker size where possible.
- Adjacent vertical panels share a straight half-frame joint, so two touching verticals form the full frame between them.
- Removed visible `lower` and `combined` panel labels.
- Horizontal lower/residual panels are named normally as `P3`, `P4`, etc.
- Horizontal merge is limited to `2400mm`.
- Window default height is now `1100mm`.
- Auto window X is placed away from an enabled door when possible.
- Wall preview, sheet/nesting preview, and generated placement labels use the same `Wall N - P...` naming.
- UI density was reduced with smaller, more professional controls.

## Validation Done

- Inline script syntax check passed through Node.
- Browser QA was run through a local static server because automated `file://` reloads can be blocked.
- Tested 3 walls and 4 walls.
- Tested full-wall vertical orientation.
- Tested one isolated vertical panel.
- Tested irregular shape ON/OFF for an individual vertical panel.
- Tested door and window enabled together.
- Tested window default height and auto placement away from the door.
- Tested shaker Auto and Locked modes.
- Tested Calculate Price.

Known unrelated issue:

- QR generation can log `QR library is not loaded`. That was not part of this Panneling pass.

## Publish To GitHub

This folder is prepared as a Git repository. To publish:

```powershell
gh auth login
gh repo create cnc-calculator --private --source . --remote origin --push
```

To make the HTML open directly in the browser from GitHub:

1. Open the GitHub repository.
2. Go to `Settings` -> `Pages`.
3. Set source to `Deploy from a branch`.
4. Select branch `main` and folder `/root`.
5. Open the Pages URL with `/Cnc%20Calculator%20UI%20Test.html` at the end.
