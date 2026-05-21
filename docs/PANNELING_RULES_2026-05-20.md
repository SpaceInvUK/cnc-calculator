# Panneling Rules - 2026-05-20

This document records the current confirmed Panneling rules for the active app:

- Active file: `Cnc Calculator UI Test.html`.
- Do not touch `Cnc Calculator 1.0.html` unless explicitly requested.
- Do not deploy to Netlify unless explicitly requested in that session.
- Panneling spelling stays as-is.

## Rooms And Walls

- A Room can contain up to 50 walls.
- Each Room has its own walls, panel setup, previews, nesting, and sheets.
- Default wall size is 5200mm wide by 3200mm high.
- Each wall can have its own width and height.
- Each wall can choose panel orientation: horizontal or vertical.
- A vertical wall orientation must fill the wall automatically with vertical panels.
- Changing one wall must not change another wall.

## Panel Size Rules

- Horizontal cut panels use a maximum width of 2400mm.
- Vertical cut panels use a maximum width of 1206mm.
- Vertical cut panels keep the standard height of 3000mm unless edited.
- Wall height can be 3200mm while vertical panels remain 3000mm.
- Horizontal panel height and vertical panel height are editable from Panneling controls and per wall.
- Per-wall horizontal panel height must drive the generated wall panels immediately, even if the source part still has an older saved height.
- The frame size still controls rail/stile/frame width; panel height controls do not change frame width.

## Shaker Rules

- Global shaker quantity was removed from Panel Setup.
- Automatic wall shakers target approximately 350mm wide.
- Shaker count can be overridden per wall.
- Shaker count can still be overridden per physical panel in Part Dimensions.
- A physical panel shaker override must change the wall preview, nesting/sheet preview, and DXF/cavity geometry for that selected physical panel.
- If the user requests fewer or more shakers, the app must distribute that count across the wall/panel.
- If a requested shaker count would force a physical cut panel past its max width, the max-width rule takes priority and the app increases to the smallest count that can fit.
- Main shakers should stay consistent within the wall where possible.
- Edge shakers may grow/shrink near wall ends, doors, windows, empty spaces, corners, and columns.
- Vertical panels may use more than one shaker column if the physical panel width allows it.

## Openings

- Each wall can have multiple openings.
- Opening types: Door, Window, Empty.
- Empty defaults to 2000mm wide by 2000mm high.
- Door defaults to 900mm wide by 2100mm high.
- Window defaults to 1200mm wide by 1100mm high, with 900mm bottom height from the floor.
- Openings must not overlap or touch each other; keep at least a frame-size gap when auto-positioning.
- Door and Empty remove panel coverage from that wall span.
- Window remains a cutout in the panel geometry.
- When a window starts below the normal horizontal panel top, create a separate lower panel under the full window width.
- The lower window panel height follows the window bottom height for now.
- Horizontal panels touching a lower window panel use half-frame joints on the window-facing side.
- Opening names are editable.

## Skirting

- Skirting default is 225mm.
- With frame 80mm and skirting 225mm, the dashed skirting guide line is 225mm from the floor.
- The lower shaker opening starts at skirting height plus frame height; with 225mm skirting and 80mm frame, the shaker starts at 305mm.
- The skirting guide line is a wall preview guide only.
- The skirting guide line must not be drawn on nesting/sheet pieces or DXF output.

## Naming And Output

- Wall preview, nesting/sheet preview, labels, and DXF names must match.
- Names use `Wall N - P1`, `Wall N - P2V`, etc.
- If a Room has a custom name, labels use that prefix, for example `Kitchen Wall 1 - P1`.
- Sheet counts and sheet captions are per Room in Panneling mode.
- Do not show `lower combined` labels.
- If horizontal pieces merge physically, keep normal panel names such as `P3`, `P4`.

## Resolved Conflicts

- Old 10-wall limit is replaced by 50 walls per Room.
- Vertical max width remains 1206mm, not 1200mm.
- Vertical panel standard height remains 3000mm even when wall height is 3200mm.
- Horizontal max panel width is 2400mm.
- Frame controls remain frame controls; new height fields are panel height controls, not frame height controls.

## Latest QA Fixes

- Panneling Material & Pricing is full width in panel mode so Wall Setup has room to breathe.
- Wall Setup rows are compact and put Door, Window, and Empty actions beneath the wall size/orientation controls.
- Full-wall vertical orientation must not leave empty gaps inside generated vertical sections.
- Irregular Shape is stored per selected physical panel instance, including residual/secondary vertical pieces.
