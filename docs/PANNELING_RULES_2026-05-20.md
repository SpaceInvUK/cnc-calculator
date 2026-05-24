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
- Part Dimensions has an Auto button per panel to return that physical panel to the automatic wall shaker calculation.
- If the user requests fewer or more shakers, the app must distribute that count across the wall/panel.
- If a requested shaker count would force a physical cut panel past its max width, the max-width rule takes priority and the app increases to the smallest count that can fit.
- Main shakers should stay consistent within the wall where possible.
- Edge shakers may grow/shrink near wall ends, doors, windows, object spaces, corners, and columns.
- Vertical panels may use more than one shaker column if the physical panel width allows it.

## Openings

- Each wall can have multiple openings.
- Opening types: Door, Window, Object.
- Object uses the internal legacy type `empty` for quote compatibility, but the user-facing label is Object.
- Object defaults to 2000mm wide by 2000mm high.
- Door defaults to 900mm wide by 2100mm high.
- Window defaults to 1200mm wide by 1100mm high, with 900mm bottom height from the floor.
- Openings must not overlap or touch each other; keep at least a frame-size gap when auto-positioning.
- Adding or editing one opening must not move existing openings. If the new/current opening collides, show the collision on that opening instead of silently moving doors, windows, or objects.
- Opening X can be measured from the left or right side of the wall with a From L/R control.
- Door and Object remove panel coverage from that wall span.
- Window remains a cutout in the panel geometry.
- When a window starts below the normal horizontal panel top, create a separate lower panel under the full window width.
- The lower window panel height follows the window bottom height for now.
- The lower window panel stays separate and horizontal.
- Horizontal panels touching a lower window panel use half-frame joints on the window-facing side.
- Window side panels continue past the lower-window line by the Window Sill Height, then step inward by half the frame so the physical joint is real.
- Object itself has no panel coverage, but if Object stops below the vertical panel line, create a cap panel above it.
- Object cap panel height is based on the vertical panel height: cap height = V Panel H - Object bottom - Object height.
- Object cap panel width covers the Object width plus half the frame on each side when space allows, clamped by the wall or neighboring openings.
- Object cap panel side frames use half-frame joints. Example: frame 80mm means 40mm on each side.
- If the Object cap panel is taller than about 1200mm, it may become one or more vertical panels, but it still must align to the same top line as the neighboring panels.
- Object side panels keep full frame beside the Object, then step inward by half-frame above the Object to join the cap panel.
- Opening names are editable.
- Doors, windows, and objects can be selected from the wall preview and removed with Delete/Backspace.
- Legacy quote files that store doors/windows in old `wallDoor*` / `wallWindow*` fields must be converted into editable `wallOpenings` on load so those openings can be deleted.
- Clicking an opening in the wall preview gives it keyboard focus so Delete/Backspace removes it even when the previous focus was an input.
- Opening labels in the wall preview show the opening width and height inside the opening with lighter text.
- Window sill height is a Panneling setting. Default is 22mm. Window-side panel joints use this setting as the rule basis for the lower sill/joint area.

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
- Numeric labels preserve decimals where the user entered decimals; do not round 385.6mm to 386mm.
- Numeric labels must not strip integer zeros. Example: 3500mm must stay 3500mm, not 35mm.

## Side Rules

- Side rules can be set per physical panel side from the wall preview, not only per whole wall.
- Hover/click the left or right side of a physical panel to choose Normal, Joint, Vertical Joint, Corner, Column, or Door.
- Panel-side overrides must flow into the wall preview, nesting/sheet preview, and generated panel geometry.

## Keyboard Controls

- In wall and panoramic previews, ArrowUp turns the selected wall panel vertical.
- In wall and panoramic previews, ArrowDown turns the selected wall panel horizontal.
- ArrowLeft and ArrowRight select the previous or next physical panel and can cross to another wall in the same Room.
- These arrow controls apply only to wall panels, not Door, Window, or Object openings.
- Sheet/nesting rotation keeps the 9 and 0 keys. Wall previews do not use 9/0 for orientation.

## Back Side Pocketing

- Back side pocketing is shown in the calculator and print/PDF output by default.
- The View menu can hide or show Back Side Pocketing output.
- Back side pocketing sheets stay red and labeled `Back side pocketing`.
- Back side pocketing layouts must never overlap pieces.
- Double-sided pocketing increases the pocketing charge compared with front-only pocketing.

## Resolved Conflicts

- Old 10-wall limit is replaced by 50 walls per Room.
- Vertical max width remains 1206mm, not 1200mm.
- Vertical panel standard height remains 3000mm even when wall height is 3200mm.
- Horizontal max panel width is 2400mm.
- Frame controls remain frame controls; new height fields are panel height controls, not frame height controls.

## Latest QA Fixes

- Panneling Material & Pricing is full width in panel mode so Wall Setup has room to breathe.
- Wall Setup rows are compact and put Door, Window, and Object actions beneath the wall size/orientation controls.
- Full-wall vertical orientation must not leave empty gaps inside generated vertical sections.
- Irregular Shape is stored per selected physical panel instance, including residual/secondary vertical pieces.
- Manual sheet placements are locked, then the remaining parts are tightened around them to reduce large unused gaps without overlapping.
- Wall previews scale shorter walls narrower than wider walls so small walls are easier to read.
- Sheet previews no longer draw the temporary opening cutout overlay on panel parts; actual cavity geometry still comes from the shared panel geometry functions.
- Number inputs keep the cursor position while typing; spinner arrows can step by 1mm while typed decimals remain valid.
- The `X From` L/R toggle sits beside the `X From` label, with the distance input below it.
- Wall/panoramic preview shaker cavities and labels do not block clicking the physical panel underneath.
- Arrow-key panel orientation keeps the selected physical panel active after the wall regenerates vertical/residual pieces.
- Part Dimensions helper text is kept short; nesting margin/rotation notes live near the sheets.
- Panoramic headers use the room name and wall count only, without redundant "panels shown in green" copy.
- Room tint colors use sober greens, browns, warm grays, and moss tones; no pink, purple, baby blue, or yellow room themes.
- Object cap panels and window lower panels remain horizontal; they must not inherit a vertical override from a neighboring/generated panel.
