# Paneling Implementation Notes - 2026-05-19

This document records the latest geometry/UI pass made in `Cnc Calculator UI Test.html`.

## Scope

Only the active test file was changed:

- `Cnc Calculator UI Test.html`

Files intentionally not changed:

- `Cnc Calculator 1.0.html`

No Netlify deploy was performed.

## Paneling Geometry Rules

- The tab name stays `Paneling`.
- Wall is only a reference; panels are the physical pieces cut on sheets.
- Wall preview, nesting/sheet preview, labels, and DXF data must use the same physical panel geometry.
- Panel names must stay consistent everywhere:
  - `Wall 1 - P1`
  - `Wall 1 - P2V`
  - `Wall 2 - P3`
- `V` means vertical physical panel.
- 7mm sheet margin must remain.
- 7mm spacing between nested parts must remain.
- Manual placement/rotation overrides must remain per physical panel instance.

## Wall Panel Orientation

A per-wall `Panel Orientation` control was added in Wall Setup.

- Default wall size is now `5200mm x 3200mm`.
- `H` keeps the wall using horizontal panels by default.
- `V` makes all cut panels for that wall vertical.
- Vertical wall orientation affects only that wall.
- Other walls are not changed.
- Vertical wall orientation defaults to regular shape.
- Rows are locked to the vertical rule: 2 shaker rows per column.
- Columns remain based on the shaker/column logic and available width.

## Individual Vertical Panels

Individual panels can still be changed to vertical from Part Dimensions.

- This changes only the selected panel instance.
- It does not turn all panels in the wall vertical.
- Individual vertical panels can use irregular shape ON/OFF.
- Irregular shape still creates the stepped side-frame outline where needed.
- When two vertical panels touch each other, their shared side is a straight half-frame joint.
- With an `80mm` frame, that shared vertical-to-vertical side is `40mm` on each panel so the two panels together make the full `80mm` visual frame.
- A vertical side that touches a lower horizontal/residual panel can still use the stepped irregular outline.
- A vertical side that ends the wall returns to the normal full side frame.

## Vertical Panel Dimensions

Vertical panels now use:

- Maximum width: `1206mm`.
- Default height: exactly `3000mm`.
- Manual physical height override is still allowed.
- Regular vertical panels do not default to a stepped outline.
- Individual vertical irregular panels can use the stepped outline.

## Vertical Shaker Rules

Vertical panels start with 2 shaker rows per column.

- Bottom shaker row tries to match the horizontal shaker size.
- Top shaker row takes the remaining opening height.
- The frame is still respected.
- Locked shaker mode still affects the target shaker size.
- Auto shaker mode still balances based on the existing Paneling logic.
- When a vertical panel cannot fit all source shaker columns inside the `1206mm` limit, the panel must shrink by using fewer columns instead of scaling the shaker widths down.
- In practice this means a vertical panel may use 1 or 2 columns so the remaining horizontal panels can keep the same shaker width pattern.
- Vertical panel shaker width uses the dominant horizontal/job shaker width, not the smaller leftover edge shaker.
- The lower vertical shaker row uses the horizontal panel shaker height, so it aligns with horizontal panels.

## Horizontal Residual / Merge Rules

Visible labels `lower` and `combined` were removed.

- Residual horizontal pieces are named as normal physical panels: `P3`, `P4`, etc.
- Adjacent horizontal pieces merge when they touch and the merged physical width is at most `2400mm`.
- If a horizontal span cannot be covered by one allowed piece, the app creates more panels instead of labeling a fake combined/lower piece.

## Window Rules Added

- Window default height is now `1100mm`.
- If Door and Window are both enabled and Window X is blank, the window is automatically placed away from the door when space allows.
- Window X is still editable.
- Window bottom remains editable.

## UI Density Pass

The Paneling/selected-piece editing areas were made more compact:

- Smaller button text.
- Smaller but readable input text.
- Tighter spacing.
- Reduced panel/editor padding.
- More professional compact wall rows.

## QA Performed

Browser QA was run through:

```text
http://127.0.0.1:8765/Cnc%20Calculator%20UI%20Test.html
```

because automated `file://` reload can be blocked by the browser automation policy.

Tested:

- 3 walls.
- 4 walls.
- One full wall set to vertical orientation.
- One isolated panel set to vertical.
- Individual vertical irregular shape ON/OFF.
- Door enabled.
- Window enabled.
- Window default `1100mm`.
- Window auto X away from door.
- Shaker Auto mode.
- Shaker Locked mode.
- Calculate Price.
- Label consistency in wall preview and nesting.
- No visible `lower` or `combined` label.
- Adjacent vertical-to-vertical geometry was checked with a controlled two-panel layout: the shared side stayed a straight half-frame joint with no step inset.
- Vertical-to-horizontal geometry was checked with the same controlled layout: the horizontal-facing side kept the stepped `40mm` inset when frame is `80mm`.

## Known Unrelated Issue

During Calculate Price, the page can log:

```text
QR library is not loaded
```

That error existed outside this Paneling geometry pass and was not changed here.

## GitHub Pages

After pushing this repository to GitHub, enable Pages from branch `main` and folder `/root`.

Then open:

```text
https://<github-user>.github.io/<repo-name>/Cnc%20Calculator%20UI%20Test.html
```
