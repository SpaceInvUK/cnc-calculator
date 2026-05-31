-- VECTRIC LUA SCRIPT
-- Fast CNC - DXF To Sheets By Layer
--
-- Moves imported DXF geometry from one large layout sheet into real VCarve sheets.
-- Sheet boundaries are detected only on user configured boundary layers.

require "strict"

g_version = "0.3b"
g_title = "Fast CNC DXF to Sheet by Layer"
g_gadget_name = "FastCncDxfToSheetByLayer"

g_options = {
  sheetLayerNames = "SHEET,CNC_SHEET",
  minSheetSize = 500.0,
  tolerance = 0.5,
  previewOnly = false
}

function Trim(value)
  return string.gsub(value or "", "^%s*(.-)%s*$", "%1")
end

function FormatNumber(value)
  return string.format("%.3f", value or 0)
end

function SaveDefaults(options)
  local registry = Registry(g_gadget_name)
  registry:SetString("sheetLayerNames", options.sheetLayerNames)
  registry:SetDouble("minSheetSize", options.minSheetSize)
  registry:SetDouble("tolerance", options.tolerance)
  registry:SetBool("previewOnlyV2", options.previewOnly)
end

function LoadDefaults(options)
  local registry = Registry(g_gadget_name)
  options.sheetLayerNames = registry:GetString("sheetLayerNames", options.sheetLayerNames)
  options.minSheetSize = registry:GetDouble("minSheetSize", options.minSheetSize)
  options.tolerance = registry:GetDouble("tolerance", options.tolerance)
  options.previewOnly = registry:GetBool("previewOnlyV2", options.previewOnly)
end

function BuildLayerNameSet(layer_names)
  local set = {}
  local count = 0

  for name in string.gmatch(layer_names or "", "([^,;]+)") do
    local clean_name = Trim(name)
    if clean_name ~= "" then
      set[string.upper(clean_name)] = true
      count = count + 1
    end
  end

  return set, count
end

function UpdateOptionsFromDialog(dialog, options)
  local layer_names = Trim(dialog:GetTextField("SheetLayerNamesEdit"))
  if layer_names == "" then
    MessageBox("Enter at least one sheet boundary layer name.")
    return false
  end

  local min_size = tonumber(dialog:GetTextField("MinSheetSizeEdit"))
  if min_size == nil or min_size <= 0 then
    MessageBox("Minimum sheet size must be a positive number.")
    return false
  end

  local tolerance = tonumber(dialog:GetTextField("ToleranceEdit"))
  if tolerance == nil or tolerance < 0 then
    MessageBox("Tolerance must be zero or a positive number.")
    return false
  end

  options.sheetLayerNames = layer_names
  options.minSheetSize = min_size
  options.tolerance = tolerance
  options.previewOnly = dialog:GetCheckBox("PreviewOnlyCheck")

  return true
end

function IsSameSheet(object, sheet_id)
  return luaUUID(object.SheetId):IsEqual(luaUUID(sheet_id))
end

function IsSheetBoundaryLayer(layer, sheet_layer_names)
  return sheet_layer_names[string.upper(layer.Name)] == true
end

function IsUsableBounds(bounds, min_size)
  if bounds == nil or bounds.IsInvalid then
    return false
  end

  return bounds.XLength >= min_size and bounds.YLength >= min_size
end

function CollectOriginalSheetObjects(job, original_sheet_id)
  local layer_manager = job.LayerManager
  local objects = {}

  local layer_pos = layer_manager:GetHeadPosition()
  while layer_pos ~= nil do
    local layer
    layer, layer_pos = layer_manager:GetNext(layer_pos)

    if not layer.IsSystemLayer then
      local object_pos = layer:GetHeadPosition()
      while object_pos ~= nil do
        local object
        object, object_pos = layer:GetNext(object_pos)

        if IsSameSheet(object, original_sheet_id) then
          local bounds = object:GetBoundingBox()
          if bounds ~= nil and not bounds.IsInvalid then
            table.insert(objects, {
              object = object,
              layer = layer,
              bounds = bounds
            })
          end
        end
      end
    end
  end

  return objects
end

function FindSheetBoundaries(objects, sheet_layer_names, options)
  local sheets = {}

  for index, item in ipairs(objects) do
    if IsSheetBoundaryLayer(item.layer, sheet_layer_names) and IsUsableBounds(item.bounds, options.minSheetSize) then
      table.insert(sheets, {
        object = item.object,
        layer = item.layer,
        bounds = item.bounds,
        source_index = index
      })
    end
  end

  table.sort(sheets, function(a, b)
    local ay = a.bounds.MinY
    local by = b.bounds.MinY
    if math.abs(ay - by) > options.tolerance then
      return ay < by
    end
    return a.bounds.MinX < b.bounds.MinX
  end)

  return sheets
end

function SizeLabelInFeet(width, height, in_mm)
  local long_side = math.max(width, height)
  local short_side = math.min(width, height)
  local long_feet = 0
  local short_feet = 0

  if in_mm then
    long_feet = long_side / 304.8
    short_feet = short_side / 304.8
  else
    long_feet = long_side / 12.0
    short_feet = short_side / 12.0
  end

  local long_label = math.floor(long_feet + 0.5)
  local short_label = math.floor(short_feet + 0.5)

  if long_label < 1 or short_label < 1 then
    return FormatNumber(width) .. "X" .. FormatNumber(height)
  end

  return tostring(long_label) .. "X" .. tostring(short_label)
end

function CreateOutputSheet(sheet_manager, source_sheet_id, sheet_info, sheet_number, in_mm, thickness)
  sheet_manager.ActiveSheetId = source_sheet_id

  local width = sheet_info.bounds.XLength
  local height = sheet_info.bounds.YLength
  local base_name = SizeLabelInFeet(width, height, in_mm)
  local sheet_name = base_name .. " - " .. string.format("%02d", sheet_number)
  local new_sheet_id = sheet_manager:CreateNewSheet(sheet_name)

  sheet_manager:ResizeSheet(new_sheet_id, width, height, thickness, false)

  return new_sheet_id, sheet_name
end

function FindObjectsInsideSheet(objects, sheet_bounds, tolerance)
  local inside = {}

  for _, item in ipairs(objects) do
    local centre = item.bounds.Center
    if sheet_bounds:IsInsideOrOn(centre, tolerance) then
      table.insert(inside, item)
    end
  end

  return inside
end

function MoveObjectsToSheet(job, objects, sheet_id, sheet_bounds)
  local move_vector = Vector2D(-sheet_bounds.MinX, -sheet_bounds.MinY)
  local move_matrix = TranslationMatrix2D(move_vector)
  local moved_count = 0
  local skipped_transform_count = 0

  for _, item in ipairs(objects) do
    local object = item.object

    if object:CanTransform(1) then
      object:Transform(move_matrix)
      object:InvalidateBounds()
      moved_count = moved_count + 1
    else
      skipped_transform_count = skipped_transform_count + 1
    end

    job:MoveObjectToSheet(object, sheet_id)
  end

  return moved_count, skipped_transform_count
end

function ProcessDxfToSheets(dialog)
  if not UpdateOptionsFromDialog(dialog, g_options) then
    return false
  end

  local sheet_layer_names, layer_name_count = BuildLayerNameSet(g_options.sheetLayerNames)
  if layer_name_count == 0 then
    MessageBox("Enter at least one sheet boundary layer name.")
    return false
  end

  local job = VectricJob()
  if not job.Exists then
    MessageBox("No job open.")
    return false
  end

  local material = MaterialBlock()
  local sheet_manager = job.SheetManager
  local original_sheet_id = sheet_manager.ActiveSheetId
  local original_objects = CollectOriginalSheetObjects(job, original_sheet_id)
  local sheet_boundaries = FindSheetBoundaries(original_objects, sheet_layer_names, g_options)

  if #sheet_boundaries == 0 then
    MessageBox("No sheet rectangles found on the configured boundary layer names.")
    return false
  end

  local created_ids = {}
  local detail_report = ""
  local total_moved = 0
  local total_skipped = 0

  for sheet_index, sheet_info in ipairs(sheet_boundaries) do
    local objects_inside = FindObjectsInsideSheet(original_objects, sheet_info.bounds, g_options.tolerance)
    local sheet_name = SizeLabelInFeet(sheet_info.bounds.XLength, sheet_info.bounds.YLength, job.InMM) ..
      " - " ..
      string.format("%02d", sheet_index)
    local moved_count = #objects_inside
    local skipped_count = 0

    if not g_options.previewOnly then
      local new_sheet_id
      new_sheet_id, sheet_name = CreateOutputSheet(
        sheet_manager,
        original_sheet_id,
        sheet_info,
        sheet_index,
        job.InMM,
        material.Thickness
      )

      table.insert(created_ids, new_sheet_id)

      moved_count, skipped_count = MoveObjectsToSheet(
        job,
        objects_inside,
        new_sheet_id,
        sheet_info.bounds
      )
    end

    total_moved = total_moved + moved_count
    total_skipped = total_skipped + skipped_count

    detail_report = detail_report ..
      sheet_name ..
      "  " ..
      FormatNumber(sheet_info.bounds.XLength) ..
      " x " ..
      FormatNumber(sheet_info.bounds.YLength) ..
      "  objects: " ..
      tostring(#objects_inside) ..
      "\n"
  end

  if #created_ids > 0 then
    sheet_manager.ActiveSheetId = created_ids[1]
  else
    sheet_manager.ActiveSheetId = original_sheet_id
  end

  job:Refresh2DView()

  SaveDefaults(g_options)

  local report = ""
  if g_options.previewOnly then
    report =
      "DXF to sheets preview complete.\n\n" ..
      "Sheets found: " ..
      tostring(#sheet_boundaries) ..
      "\nObjects that would be moved: " ..
      tostring(total_moved) ..
      "\n\nPreview only is ON. No sheets were created and no objects were moved.\n\n" ..
      detail_report
  else
    report =
      "DXF to sheets complete.\n\n" ..
      "Sheets created: " ..
      tostring(#sheet_boundaries) ..
      "\nObjects moved to new sheets: " ..
      tostring(total_moved) ..
      "\n\nOriginal layout objects were moved into the generated sheets."
  end

  if (not g_options.previewOnly) and total_skipped > 0 then
    report = report ..
      "\nObjects moved but not transformed: " ..
      tostring(total_skipped) ..
      "\n\nThese objects could not be moved by transform. Check them before toolpathing."
  end

  MessageBox(report)
  return true
end

function DisplayDialog(script_path)
  local html_path = "file:" .. script_path .. "\\Fast CNC DXF to Sheet by Layer.htm"
  local dialog = HTML_Dialog(false, html_path, 640, 360, g_title)

  dialog:AddLabelField("GadgetTitle", g_title)
  dialog:AddLabelField("GadgetVersion", g_version)
  dialog:AddTextField("SheetLayerNamesEdit", g_options.sheetLayerNames)
  dialog:AddTextField("MinSheetSizeEdit", FormatNumber(g_options.minSheetSize))
  dialog:AddTextField("ToleranceEdit", FormatNumber(g_options.tolerance))
  dialog:AddCheckBox("PreviewOnlyCheck", g_options.previewOnly)

  if not dialog:ShowDialog() then
    return false
  end

  return ProcessDxfToSheets(dialog)
end

function main(script_path)
  local job = VectricJob()

  if not job.Exists then
    DisplayMessageBox("Open or import the DXF into a VCarve job before running this gadget.")
    return false
  end

  LoadDefaults(g_options)

  return DisplayDialog(script_path)
end
