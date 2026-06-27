# CNC Calculator

Single-file FAST CNC calculator for Doors and Panneling.

## Current Codex Cloud Version

Use this branch in Codex Cloud:

- `main`

Current official calculator version:

- Version: `1.0`
- Source-of-truth page path: `Cnc Calculator UI Test.html`
- Local mirror for clarity: `CNC Calculator 1.0.html`
- Published URL: `https://spaceinvuk.github.io/cnc-calculator/Cnc%20Calculator%20UI%20Test.html`

`Cnc Calculator UI Test.html` is kept because that is the GitHub Pages URL already used in production. `CNC Calculator 1.0.html` is kept as an identical local mirror so the current version is obvious when working from the folder.

The earlier handoff branch was `codex/update-calculator-1-0`, but the latest calculator work is intended to continue from `main`.

See `AGENTS.md` and `docs/CODEX_CLOUD_HANDOFF_2026-05-27.md` before continuing work in Codex Cloud or on another PC.

## Open The App

Main file:

- `Cnc Calculator UI Test.html`

If this repository is published with GitHub Pages, open:

```text
https://spaceinvuk.github.io/cnc-calculator/Cnc%20Calculator%20UI%20Test.html
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

- `Cnc Calculator UI Test.html` - official version 1.0 app and GitHub Pages entry point.
- `CNC Calculator 1.0.html` - identical local mirror of the official version 1.0 app.
- `prototypes/panels-new-design/index.html` - separate Panels New Design prototype.
- `prototypes/order-entry/index.html` - separate Order Entry prototype.
- `prototypes/order-entry/beta.html` - related Order Entry beta prototype.
- `order-entry-beta.html` - root compatibility copy for the original Order Entry beta GitHub Pages URL.
- `CNC Calculator Handoff - regras e pendencias.txt` - full original handoff with all broad app rules and pending items.
- `docs/PANNELING_IMPLEMENTATION_2026-05-19.md` - what was changed in this pass, current Panneling rules, QA notes, and GitHub instructions.
- `docs/PANNELING_RULES_2026-05-20.md` - current confirmed Panneling rules after the latest annotation review.

## Backup

The current 1.0 file was backed up locally outside the repository:

```text
C:\Users\ednei\Documents\CNC App Backups\FAST CNC Calculator 1.0 - GitHub Pages backup - 2026-06-14.html
```

Backup note with the source URL and SHA256:

```text
C:\Users\ednei\Documents\CNC App Backups\FAST CNC Calculator 1.0 - backup note - 2026-06-14.txt
```

## Hard Rules

- Keep the tab spelling as `Panneling`.
- Treat `Cnc Calculator UI Test.html` as the official 1.0 entry point unless the user explicitly switches versions.
- Keep `CNC Calculator 1.0.html` synchronized when the user asks for the current 1.0 file to be updated.
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
- Windows that cut into the horizontal panel zone now create a dedicated lower panel across the full window width.
- Wall preview, sheet/nesting preview, and generated placement labels use the same `Wall N - P...` naming.
- Custom Room names prefix wall/panel labels, for example `Kitchen Wall 1 - P2`.
- UI density was reduced with smaller, more professional controls.
- Rooms can now carry up to 50 walls each.
- Panneling shakers are now controlled per wall and per panel, with auto sizing around 350mm.
- If a requested shaker count cannot physically fit inside the max panel width, the app raises it to the smallest count that fits.
- Per-panel shaker overrides now update wall preview, nesting/sheet preview, and generated cavity geometry for that selected physical panel.
- Horizontal/vertical panel heights are editable without changing frame width.
- Per-wall panel height controls drive generated panels even when the source part still has an older saved height.
- Walls support multiple Door, Window, and Empty openings.
- Empty spaces remove panel coverage from that wall span.
- Vertical wall orientation fills the wall with vertical panels using the 1206mm max-width rule.
- Skirting default is 225mm; the dashed guide is wall-preview only, and shaker openings start at skirting plus frame.
- Panneling sheet counts and sheet captions are per Room instead of grouping matching rooms together.

## Validation Done

- Inline script syntax check passed through Node.
- Local static server responded successfully on port `8765`.
- Automated browser reload of the existing `file://` tab can be blocked, so visual QA should be done from the local server URL when needed.
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
