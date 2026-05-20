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
- The frame size still controls rail/stile/frame width; panel height controls do not change frame width.

## Shaker Rules

- Global shaker quantity was removed from Panel Setup.
- Automatic wall shakers target approximately 350mm wide.
- Shaker count can be overridden per wall.
- Shaker count can still be overridden per physical panel in Part Dimensions.
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
- Opening names are editable.

## Skirting

- Skirting default remains 305mm.
- With frame 80mm and skirting 305mm, the dashed skirting guide line is 225mm from the floor.
- The skirting guide line is a wall preview guide only.
- The skirting guide line must not be drawn on nesting/sheet pieces or DXF output.

## Naming And Output

- Wall preview, nesting/sheet preview, labels, and DXF names must match.
- Names use `Wall N - P1`, `Wall N - P2V`, etc.
- Do not show `lower combined` labels.
- If horizontal pieces merge physically, keep normal panel names such as `P3`, `P4`.

## Resolved Conflicts

- Old 10-wall limit is replaced by 50 walls per Room.
- Vertical max width remains 1206mm, not 1200mm.
- Vertical panel standard height remains 3000mm even when wall height is 3200mm.
- Horizontal max panel width is 2400mm.
- Frame controls remain frame controls; new height fields are panel height controls, not frame height controls.
