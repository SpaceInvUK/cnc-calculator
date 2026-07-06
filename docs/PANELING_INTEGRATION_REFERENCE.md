# Paneling Integration Reference

Status: current rules from `origin/main` on 2026-07-07.

Scope: material family/MDF, material pricing, Door Setup, Paneling, panel shakers, side rules, openings, offsets, nesting, DXF, and the integration points between doors and panels.

This file is a technical reference for future changes. It describes what the app currently does and where each rule lives.

## Source Of Truth

- Official app: `Cnc Calculator UI Test.html`
- Mirror app: `CNC Calculator 1.0.html`
- Broad rules document: `FAST_CNC_APP_REGRAS_COMPLETAS.md`
- Paneling older notes: `docs/PANELING_IMPLEMENTATION_2026-05-19.md`
- Paneling older rules: `docs/PANELING_RULES_2026-05-20.md`

When code and older docs conflict, the HTML app is the source of truth.

## Main Code Map

Material and pricing:

- `materialOptions`: full material list shown in Material/Pricing.
- `thicknessMap`: valid thicknesses per material.
- `basePrices`: default 8x4 sheet price table by material and thickness.
- `suggestedCost(material, thickness, size)`: default material cost lookup and sheet-size scaling.
- `suggestedCncServiceCost(block)`: default CNC service charge.
- `effectiveCncServiceCost(block)`: CNC total with extra processes, drilling, and offset/pocket pricing.
- `getCncFamily(material)`: maps a material into the CNC service family.
- `applyPocketMaterialDefault(block)`: chooses the preferred material when offset/pocketing is enabled and material was not manually overridden.

Sheet and nesting:

- `SHEET_SIZES`: available sheet sizes.
- `sheetGap(sizeKey)`: default sheet spacing.
- `sheetDefaultConfig(sizeKey)`: default nesting width, height, usable height, spacing, label, and watermark.
- `sheetRuntimeSize(...)` and `sheetRuntimeGap(...)`: runtime sheet size and spacing after manual overrides.
- `placePartOnSheet(...)`: placement/nesting output.

Door/profile/insert:

- `DOOR_TYPE_OPTIONS`: Flat, Traditional, Flushback, Reeded.
- `profileTemplateRule(type)`: imported DXF profile rule lookup.
- `inferProfileRuleFromTemplate(template)`: profile rule inference from a DXF template.
- `doorConstructionRule(type)`: decides whether a door is single, traditional, or flushback insert.
- `secondaryInsertKind(type)`: insert kind for generated secondary blocks.
- `buildSecondaryBlocks()`: creates secondary insert/beading blocks for non-panel blocks.
- `sourcePartCavities(...)`: calculates the cavities/inserts for a door source part.

Paneling:

- `firstPanelBlock()`: shared panel block source.
- `PANEL_RULE_SIZE_KEYS`: editable side-rule size fields.
- `defaultPanelRuleSize(...)`: default side-rule size logic.
- `panelRuleSizeOverride(...)`: side-rule manual override logic.
- `panelWallLayoutForPart(...)`: wall and panel layout.
- `panelPhysicalSectionsForPart(...)`: generated physical panel sections.
- `panelAxisShakerSizes(...)`: row/column shaker sizing.
- `panelPlacementDataForPhysicalItem(...)`: geometry used by previews, nesting, and DXF.
- `panelOpeningRectsForPlacement(...)`: opening subtraction for doors, windows, objects.
- `expandBlockParts(block)`: expands a paneling block into real cuttable parts.

## Material Family And MDF Rules

The app has a long material list, but CNC service pricing is grouped into two families:

- `Birch`: Birch, Birch Plywood, Hardwood Plywood, Softwood Plywood, Marine Plywood, Poplar Plywood, Phenolic-coated Plywood, Solid Oak Panels, Solid Pine Panels, Solid Beech Panels, Bamboo Panels.
- `MDF`: every other material, including all MDF variants, chipboard, HDF, OSB, melamine, laminated, veneered boards, and Other.

Current MDF-related materials:

- MDF
- Standard MDF
- Moisture-Resistant MDF (MR MDF)
- Fire-Rated MDF (FR MDF)
- Veneered MDF (Oak, Walnut, Ash)
- Black MDF (Valchromat)
- Tricoya (Exterior-grade MDF)
- MDF Hidrofugo Plus

Current MDF thickness options:

- 3mm
- 6mm
- 9mm
- 12mm
- 15mm
- 18mm
- 22mm
- 25mm
- 30mm

Current MDF 8x4 material base prices:

- MDF: 3mm 15, 6mm 25, 9mm 35, 12mm 40, 15mm 45, 18mm 55, 22mm 65, 25mm 75, 30mm 15.
- Standard MDF: same as MDF.
- Moisture-Resistant MDF (MR MDF): 3mm 25, 6mm 35, 9mm 45, 12mm 50, 15mm 55, 18mm 65, 22mm 75, 25mm 85, 30mm 25.
- MDF Hidrofugo Plus: same as MR MDF.
- Fire-Rated MDF: 3mm 30, 6mm 40, 9mm 50, 12mm 60, 15mm 70, 18mm 80, 22mm 90, 25mm 100, 30mm 30.
- Veneered MDF: 3mm 35, 6mm 45, 9mm 55, 12mm 65, 15mm 75, 18mm 85, 22mm 95, 25mm 105, 30mm 35.
- Black MDF: 3mm 40, 6mm 50, 9mm 60, 12mm 70, 15mm 80, 18mm 90, 22mm 100, 25mm 110, 30mm 40.
- Tricoya: 3mm 50, 6mm 60, 9mm 70, 12mm 80, 15mm 90, 18mm 100, 22mm 110, 25mm 120, 30mm 50.

Material pricing rules:

- A saved material price override wins first.
- A Material Pricing book override wins before default tables.
- If the selected size is not 8x4, a known sheet price scales by sheet area unless an exact size price exists.
- If no table value exists, the fallback uses 75 for 10x4 and scales from that.
- Material Price is meant to be global for the file when edited in Material Pricing.

CNC service pricing rules:

- Auto-generated secondary blocks default to 65.
- Manual blocks with 18mm or 22mm default to 85.
- Other manual blocks use the `cncPriceTables.small` table for the material family (`MDF` or `Birch`).
- Extra Processes add 10 percent per unit.
- Drillings add 5 percent.
- Offset/pocket metrics add their own pricing percentage through `pocketingMetricsForPricing(block)`.

Offset/pocket material default:

- If offset/pocketing is enabled and the user has not manually overridden the material, the app prefers `MDF Hidrofugo Plus`.
- If `MDF Hidrofugo Plus` is unavailable, it falls back to `Moisture-Resistant MDF (MR MDF)`.
- If the current thickness is not available on the preferred material, the first available thickness is selected.
- After this auto-selection, manual user changes should be respected through the manual override flag.

## Sheet Size And Nesting Rules

Current sheet size table:

- `8x4`: 2440 x 1220
- `10x4`: 3050 x 1220
- `10x5`: 3050 x 1525
- `jumbo`: 2875 x 2700

Default spacing:

- Jumbo uses 13mm.
- Every other sheet size uses 7mm.

Nesting fields:

- Sheet Size shows the selected Material/Pricing size.
- Width is the nesting sheet width in mm.
- Height is the nesting sheet height in mm.
- Spacing is the spacing/margin used in nesting.

Manual nesting overrides:

- If the user types a nesting width, that width must be used for nesting and previews.
- If the user types a nesting height, that height must be used for nesting and previews.
- If the user types a nesting spacing, that spacing must be used for nesting and margins.
- The drawn sheet and captions must use the runtime size, not the default size, after an override.

## Door Setup Rules

Door Setup controls the profile behavior for door blocks.

Door types:

- Flat: no shaker/profile geometry.
- Traditional: frame and cavity geometry without the flushback secondary insert behavior.
- Flushback: uses flushback insert construction.
- Reeded: uses flushback insert construction plus reeded insert settings.
- Imported DXF template: may define a profile rule with frame, back frame, material thickness, offsets, and front/back behavior.

Door construction:

- `traditional` returns `traditional`.
- `flushback` and `reeded` return `flushback-insert`.
- Imported templates can return their own construction, normally `profile` or `single`.
- Door types that create inserts can create secondary generated insert blocks.

Frame and back frame:

- Standard block frame uses `frameSize`.
- Back face uses `backFrameSize`, falling back to the front frame if not set.
- Profile templates can set `frame` and `backFrame`.
- If a profile template is front and back, the app uses `pocketSideMode: front-back`.

Grain direction:

- The block-level Grain Direction control is inherited by parts unless the part overrides it.
- Generated insert parts inherit the source part grain direction.
- When an insert is generated from a door that has grain direction on, the insert must keep the same grain side/orientation as the source door cavity.

Beading/Biding:

- Text can trigger beading/glass behavior.
- Beading creates secondary generated beading parts instead of normal insert parts.
- Beading uses its own frame, clearance, thickness, and rounded-corner behavior.

## Offset Rules

The app now labels pocketing lines as Offset lines.

Offset line mapping:

- Offset A: layer `OFFSET_A`, UI color `#b45309`, DXF color 30.
- Offset B: layer `OFFSET_B`, UI color `#dc2626`, DXF color 1.
- Offset C: layer `OFFSET_C`, UI color `#2563eb`, DXF color 5.
- Offset D: layer `OFFSET_D`, UI color `#7c3aed`, DXF color 210.
- Offset E: layer `OFFSET_E`, UI color `#0f766e`, DXF color 94.
- Offset F: layer `OFFSET_F`, UI color `#f97316`, DXF color 30.
- Offset G: layer `OFFSET_G`, UI color `#a16207`, DXF color 32.

Offset behavior:

- Offset A is enabled by default when offset/pocketing is enabled.
- Offset B through G are off by default unless a template/rule enables them.
- Offset values allow decimals through `step="0.1"`.
- Offsets are measured inward from the inner frame edge toward the center.
- Each line can have rounded corners independently.
- Front/Front+Back controls whether the offset geometry applies to one face or both faces.

Template-driven offsets:

- Imported profile DXFs can infer ordered pocket/offset steps.
- The ordered steps map to Offset A, Offset B, Offset C, etc.
- If the template says front and back, the part should automatically use front/back offset behavior.

## Paneling Setup Rules

Paneling is a separate calculator mode, but it shares many concepts with Door Setup.

Paneling hierarchy:

- A paneling block represents the material/pricing source for paneling.
- A paneling block can contain rooms.
- Each room contains walls.
- Each wall creates physical panel sections.
- Each physical section becomes a cuttable part for nesting, DXF, and drawings.

Paneling setup is intended to be shared:

- The shared Panel Shaker Setup applies to every shaker in every panel, room, and wall unless a per-wall or per-panel override exists.
- This is different from editing every room separately.
- The shared setup should be the first place to look when paneling output differs across rooms.

Paneling profile type:

- Paneling has a `panelGlobalShakerType` control with Flat, Traditional, Flushback, Reeded, and imported templates.
- The paneling profile type is the panel equivalent of Door Type.
- In paneling expansion, `panelGlobalShakerType` is normalized and used as `panelDoorType`.
- If the paneling type has an imported profile rule, paneling uses that rule for frame, back frame, material thickness, and offset lines.
- If there is no profile rule, paneling falls back to the panel frame size.

Important difference from normal doors:

- `buildSecondaryBlocks()` intentionally skips panel blocks.
- That means Paneling currently applies profile/shaker/offset geometry directly onto generated physical panel pieces.
- It does not create a separate auto-generated insert block for paneling inserts the same way Door Setup can create secondary insert blocks.
- If future work requires separate panel insert materials, that needs a deliberate new integration rule.

## Panel Size Defaults

Current panel constants:

- Minimum shaker size: 150mm.
- Maximum shaker size: 700mm.
- Vertical panel max width: 1206mm.
- Vertical panel default height: 3000mm.
- Horizontal default width reference: 2400mm.
- Horizontal panel default height: 1030mm.
- Horizontal merge max width: 2400mm.
- Skirting default height: 225mm.
- Object top vertical threshold: 1200mm.

Panel section behavior:

- Horizontal paneling uses horizontal panels and can merge spans up to 2400mm.
- Vertical paneling fills the wall with vertical panels using the 1206mm max-width rule.
- Individual physical panels can be edited after generation.
- Older saved source values can be overridden by per-wall and per-panel controls.

## Shaker Rows, Columns, And Sizes

Auto mode:

- The app balances shaker sizes automatically.
- The target shaker size is around 350mm.
- The app respects the minimum and maximum shaker size limits.
- If the requested shaker count does not physically fit, the app raises the count to the smallest count that fits.

Locked/manual mode:

- The user can force row/column counts.
- The user can force shaker size.
- Forced values should still respect physical limits where possible.

Horizontal panels:

- Horizontal panel height defaults to 1030mm.
- Horizontal panels can use panel-specific row and column controls.
- Horizontal shaker rows and columns should drive both preview and generated cavities.

Vertical panels:

- Vertical panel height defaults to 3000mm.
- Vertical panels use max width 1206mm.
- Vertical panels start with 2 shaker rows in Auto.
- The bottom row tries to match the horizontal shaker height where possible.
- The top row uses the remaining height.
- Vertical panel row/column controls must affect the generated physical panel, the nesting preview, and the DXF.

Panel over object:

- Object/opening behavior can create panels over objects.
- Panel-over-object needs its own bottom-to-bottom-shaker offset rule.
- Increasing that bottom offset should shrink the shaker space above it.
- Panels over objects should not show the skirting guide as if skirting existed inside that object panel.

## Side Rules

The side-rule UI is editable by rule type, not by only Top/Right/Bottom/Left in setup.

Rule types:

- Normal
- Joint
- Vertical Joint
- Door
- Corner
- Column

Default size logic:

- Normal: frame size.
- Joint: half frame size.
- Vertical Joint: 0.
- Door: door allowance.
- Corner: frame size + material thickness.
- Column: frame size + material thickness.

Editable storage keys:

- Normal: `panelRuleNormalSize`
- Joint: `panelRuleJointSize`
- Vertical Joint: `panelRuleVerticalJointSize`
- Door: `panelRuleDoorSize`
- Corner: `panelRuleCornerSize`
- Column: `panelRuleColumnSize`

Per-piece side editing:

- Setup should expose the rule sizes.
- Piece editing still needs side assignment for Top, Right, Bottom, Left.
- The side assignment decides which rule applies on each physical side.
- The rule size decides the numeric frame/spacing used by that side.

## Openings: Door, Window, Object

Paneling walls can contain openings.

Opening categories:

- Door
- Window
- Object/Empty opening

Door behavior:

- A door removes panel coverage from the wall span.
- Door allowance can drive side-rule sizing.
- Door opening geometry must be respected by wall preview, nesting, and DXF.

Window behavior:

- A window is a cutout/opening.
- A window can create a lower panel under the window.
- Window lower panel behavior should use the same physical panel geometry in preview, nesting, and DXF.

Object behavior:

- Object/empty space removes panel coverage.
- Object top panels can be generated above the object.
- Object top panels need correct shaker geometry, not plain rectangles.
- Skirting guide should not exist inside panels over objects.

## Generated Parts And Naming

Paneling generated parts should keep enough metadata to remain traceable:

- room name
- wall index/name
- physical panel index
- panel direction
- wall section index
- panel row/column sizes
- side rules
- openings
- profile rule
- frame and back frame
- offset lines
- grain direction
- source block and source part links

Labels should use the wall/panel naming pattern:

- `Room Name Wall N - P...`
- If there is no custom room name, use `Wall N - P...`

The same generated part identity should be used by:

- wall preview
- nesting preview
- print drawings
- label map
- A4 labels
- CNC labels
- DXF part text
- DXF part number

## Door To Panel Integration

The intended integration model:

- Door Setup and Panel Shaker Setup share the same profile concepts.
- A Door Type selected in Panel Shaker Setup should use the same profile/template rule as Door Setup.
- Imported DXF templates should not be redrawn from a default example shape.
- Imported templates should be interpreted from their own DXF geometry.
- Template name should come from the file/template name.
- Template frame, back frame, material thickness, front/back behavior, and offsets should be respected automatically.
- The user can still manually override values after the automatic template setup.

Current implementation note:

- Door blocks can create secondary insert blocks.
- Panel blocks currently do not create secondary insert blocks.
- Panel blocks apply the profile/cavity/offset geometry directly to generated physical panel pieces.
- If panel inserts need separate material takeoff, that is a missing integration feature and should be added carefully.

## DXF Rules

DXF output must match what nesting shows.

For paneling:

- Every visible/generated panel line in nesting must also appear in the DXF.
- Panels above objects must not become plain rectangles in DXF.
- Shaker lines must be generated from the same panel placement data used by the sheet preview.
- Panel side rules must be reflected in the generated geometry.
- Offset layers must use the Offset A-G layer names and matching DXF colors.
- Part number must be separate from normal text.
- Part size and label text must fit inside each part.
- Text orientation should follow each part shape.
- Offcut text belongs to the offcut layer.
- Offcut border lines should not duplicate sheet boundary lines or duplicate adjacent offcut lines.

For templates:

- Do not create a fake layer just for the profile preview if that layer does not belong in the source DXF.
- Do not alter the source template shape.
- A template preview can show dimensions, arrows, thickness, frame, back frame, offsets, and front/back behavior, but those annotations are view-only.

## Print And Labels Integration

Paneling identity should carry through printing:

- Print drawings should show the same panel/shaker geometry as nesting.
- Print labels map should use the same global part numbers as nesting and DXF.
- A4 labels should use the same global part numbers as label map.
- CNC labels should use the same part text, dimensions, sheet number, FSC/client/date fields, and QR code rules where they fit.

Label priority:

- Legibility wins over QR code.
- Text must stay inside the label or piece.
- If the label is vertical, text should rotate/follow the label.
- The QR code must not touch or break the label border.

## Known Integration Gaps To Watch

Paneling insert material:

- Paneling currently does not create separate auto-generated insert blocks.
- If flushback/reeded paneling should create real insert material lines, this is still incomplete.

Panel over object:

- The rules are sensitive because object panels can look correct in nesting but still become wrong if DXF uses a simpler rectangle path.
- Always test a wall with an object and panels above it after changing this area.

Side-rule UI:

- Setup rule sizes and per-piece side assignment are two different concepts.
- Do not remove per-side assignment from the piece editor.

Nesting defaults:

- Jumbo default must stay 2875 x 2700 with 13mm spacing unless the user overrides the nesting fields.
- 8x4 default must stay 2440 x 1220 with 7mm spacing unless overridden.

Template profiles:

- A template must keep its own profile shape.
- Rivington and Allestree-like templates should not be forced into the same default shape.
- Front/back templates should drive front/back offsets and preferred material behavior.

## Minimum QA After Paneling Changes

Before accepting a future paneling change, test these cases:

- Door block with Flat, Traditional, Flushback, Reeded.
- Door block with an imported DXF template.
- Paneling block with Flat.
- Paneling block with Traditional.
- Paneling block with Flushback or an imported template.
- Horizontal wall with door opening.
- Horizontal wall with window opening and lower panel.
- Horizontal wall with object/opening and panel above object.
- Vertical wall with several vertical panels.
- One individual vertical panel override.
- Jumbo selected in Material/Pricing, then Smart Takeoff/nesting.
- Manual nesting width/height/spacing override.
- DXF export for paneling with shakers and offsets.
- Print drawings, label map, A4 labels, and CNC labels.

## Change Rule For Future Work

When changing paneling, keep this order:

1. Update data/rules first.
2. Update generated physical panel geometry.
3. Update preview rendering.
4. Update nesting placement.
5. Update DXF export.
6. Update print/label output.
7. Update this document and the broad rules document if the behavior changed.

The main risk in this app is fixing a visual preview while leaving DXF, labels, or pricing behind. Treat generated physical parts as the shared contract.
