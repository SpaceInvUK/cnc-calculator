-- VECTRIC LUA SCRIPT
-- Fast CNC - Apply User Template To Sheets
--
-- Loads the user's Vectric ToolpathTemplate. In a multi-sheet job VCarve shows
-- its own "apply to all sheets?" prompt; answer Yes and VCarve applies the
-- template to every sheet (exactly like the Toolpaths menu does).

require "strict"

g_version = "1.6"
g_title = "Fast CNC Apply Toolpath To All Sheets"
g_gadget_name = "FastCncApplyToolpathToAllSheets"

g_options = {
  templatePath = "",
  windowWidth = 720,
  windowHeight = 360
}

function Trim(value)
  return string.gsub(value or "", "^%s*(.-)%s*$", "%1")
end

function HtmlEscape(value)
  local text = tostring(value or "")
  text = string.gsub(text, "&", "&amp;")
  text = string.gsub(text, "<", "&lt;")
  text = string.gsub(text, ">", "&gt;")
  text = string.gsub(text, '"', "&quot;")
  return text
end

function FileExists(path)
  local file = io.open(path, "rb")
  if file == nil then return false end
  file:close()
  return true
end

function SaveDefaults(options)
  local registry = Registry(g_gadget_name)
  registry:SetString("templatePath", options.templatePath)
  registry:SetInt("windowWidth", options.windowWidth)
  registry:SetInt("windowHeight", options.windowHeight)
end

function LoadDefaults(options)
  local registry = Registry(g_gadget_name)
  options.templatePath = registry:GetString("templatePath", options.templatePath)
  local width = registry:GetInt("windowWidth", options.windowWidth)
  local height = registry:GetInt("windowHeight", options.windowHeight)
  if width >= 520 then options.windowWidth = width end
  if height >= 300 then options.windowHeight = height end
end

function UpdateOptionsFromDialog(dialog, options)
  options.windowWidth = dialog.WindowWidth
  options.windowHeight = dialog.WindowHeight
  return true
end

function CountToolpaths(toolpath_manager)
  local n = 0
  pcall(function() n = toolpath_manager.Count end)
  return n
end

function CountVisibleToolpaths(toolpath_manager)
  local n = 0
  pcall(function() n = toolpath_manager.NumVisibleToolpaths end)
  return n
end

function TurnOnAllToolpaths(toolpath_manager)
  local ok, err = pcall(function()
    toolpath_manager:SetAllToolpathsVisibility(true)
  end)

  if ok then
    return true, ""
  end

  return false, tostring(err or "")
end

function TurnOnAllToolpathsForEverySheet(job, toolpath_manager)
  local layer_manager = job.LayerManager
  local sheet_manager = job.SheetManager
  local num_sheets = 0
  local original_layer_index = nil
  local original_sheet_index = nil
  local original_sheet_id = nil
  local attempts = 0
  local failures = 0
  local errors = {}

  pcall(function() num_sheets = layer_manager.NumberOfSheets end)
  if num_sheets == nil or num_sheets <= 0 then
    pcall(function() num_sheets = sheet_manager.NumberOfSheets end)
  end
  if num_sheets == nil or num_sheets <= 0 then
    num_sheets = 1
  end

  pcall(function() original_layer_index = layer_manager.ActiveSheetIndex end)
  pcall(function() original_sheet_index = sheet_manager.ActiveSheetIndex end)
  pcall(function() original_sheet_id = sheet_manager.ActiveSheetId end)

  for sheet_index = 0, num_sheets - 1 do
    pcall(function() layer_manager.ActiveSheetIndex = sheet_index end)
    pcall(function() sheet_manager.ActiveSheetIndex = sheet_index end)
    pcall(function() job:Refresh2DView() end)

    attempts = attempts + 1
    local ok, err = TurnOnAllToolpaths(toolpath_manager)
    if not ok then
      failures = failures + 1
      table.insert(errors, "Sheet index " .. sheet_index .. ": " .. err)
    end
  end

  -- One final global call after the sheet loop catches the current tree filter.
  attempts = attempts + 1
  local final_ok, final_err = TurnOnAllToolpaths(toolpath_manager)
  if not final_ok then
    failures = failures + 1
    table.insert(errors, "Final pass: " .. final_err)
  end

  if original_layer_index ~= nil then
    pcall(function() layer_manager.ActiveSheetIndex = original_layer_index end)
  end
  if original_sheet_index ~= nil then
    pcall(function() sheet_manager.ActiveSheetIndex = original_sheet_index end)
  end
  if original_sheet_id ~= nil then
    pcall(function() sheet_manager.ActiveSheetId = original_sheet_id end)
  end

  return attempts, failures, table.concat(errors, "<br>")
end

-- Collect the toolpaths that LoadToolpathTemplate just appended (everything past
-- start_index). We do NOT rename them: VCarve already names them and, when you
-- answer Yes to its apply-to-all-sheets prompt, spreads them across every sheet
-- itself. Returns their ids; pushes their names into names_out for the report.
function CollectNewToolpaths(toolpath_manager, start_index, names_out)
  local ids = {}
  local index = 0
  local pos = toolpath_manager:GetHeadPosition()

  -- skip the toolpaths that already existed before the template load
  while pos ~= nil and index < start_index do
    local _skip
    _skip, pos = toolpath_manager:GetNext(pos)
    index = index + 1
  end

  -- collect the newly added toolpaths (names left untouched)
  while pos ~= nil do
    local toolpath
    toolpath, pos = toolpath_manager:GetNext(pos)
    if toolpath ~= nil then
      table.insert(ids, toolpath.Id)
      if names_out ~= nil then
        table.insert(names_out, toolpath.Name)
      end
    end
  end

  return ids
end


function LoadTemplate(dialog)
  if not UpdateOptionsFromDialog(dialog, g_options) then
    return false
  end

  local job = VectricJob()
  if not job.Exists then
    MessageBox("No job open.")
    return false
  end

  local toolpath_manager = ToolpathManager()
  local count_before = CountToolpaths(toolpath_manager)
  local visible_before = CountVisibleToolpaths(toolpath_manager)

  -- Call LoadToolpathTemplate EXACTLY ONCE. In a multi-sheet job VCarve shows its
  -- own "apply to all sheets?" prompt; answer Yes and it applies the template to
  -- every sheet and calculates them -- exactly like the Toolpaths menu.
  --
  -- DO NOT loop over sheets or rename toolpaths. Looping makes VCarve re-apply to
  -- all sheets on every pass (the 150-duplicate explosion) and re-prefixes the
  -- already-renamed paths into S2-S1-, S3-S2-S1-, ... That was the v1.2 mess.
  if not toolpath_manager:LoadToolpathTemplate(g_options.templatePath) then
    MessageBox("Failed to load template:\n\n" .. g_options.templatePath)
    return false
  end

  local count_after = CountToolpaths(toolpath_manager)
  local visibility_attempts, visibility_failures, visibility_error =
    TurnOnAllToolpathsForEverySheet(job, toolpath_manager)
  local visible_after = CountVisibleToolpaths(toolpath_manager)

  local results = {
    count_before = count_before,
    count_after  = count_after,
    visible_before = visible_before,
    visible_after = visible_after,
    visibility_attempts = visibility_attempts,
    visibility_failures = visibility_failures,
    visibility_error = visibility_error,
    added        = math.max(0, count_after - count_before),
    names        = {}
  }

  -- Collect the new toolpath names for the report only. We deliberately do NOT
  -- recalculate. VCarve's apply-to-all-sheets ALREADY calculated every sheet
  -- correctly. Calling RecalculateToolpath from Lua recalcs each toolpath against
  -- the CURRENTLY ACTIVE sheet, so toolpaths that belong to other sheets lose
  -- their vector selection and come back EMPTY -- that was the "only sheet 1 is
  -- correct, sheets 2-5 are empty groups" bug.
  CollectNewToolpaths(toolpath_manager, count_before, results.names)

  job:Refresh2DView()
  SaveDefaults(g_options)
  DisplayStatusReport(job, results)

  return true
end

function DisplayDialog(script_path)
  local html_path = "file:" .. script_path .. "\\Fast CNC Apply Toolpath To All Sheets.htm"
  local dialog = HTML_Dialog(false, html_path, g_options.windowWidth, g_options.windowHeight, g_title)

  dialog:AddLabelField("GadgetTitle", g_title)
  dialog:AddLabelField("GadgetVersion", g_version)
  dialog:AddLabelField("TemplatePathLabel", g_options.templatePath)

  if not dialog:ShowDialog() then
    return false
  end

  return LoadTemplate(dialog)
end

function DisplayStatusReport(job, results)
  local page_html = g_ReportHeaderHtml

  page_html = page_html .. "<p><b>Job:</b> " .. HtmlEscape(job.Name) .. "</p>"
  page_html = page_html .. "<p><b>Template:</b> " .. HtmlEscape(g_options.templatePath) .. "</p>"
  page_html = page_html .. "<table class=\"report\">"
  page_html = page_html .. "<tr><td>Toolpaths before</td><td>" .. results.count_before .. "</td></tr>"
  page_html = page_html .. "<tr><td>Toolpaths after</td><td>" .. results.count_after .. "</td></tr>"
  page_html = page_html .. "<tr><td>New toolpaths added</td><td>" .. results.added .. "</td></tr>"
  page_html = page_html .. "<tr><td>Visible before</td><td>" .. results.visible_before .. "</td></tr>"
  page_html = page_html .. "<tr><td>Visible after auto-on</td><td>" .. results.visible_after .. "</td></tr>"
  page_html = page_html .. "<tr><td>Auto-on passes</td><td>" .. results.visibility_attempts .. "</td></tr>"
  page_html = page_html .. "<tr><td>Calculation</td><td>Done by VCarve during apply-to-all-sheets</td></tr>"
  if results.visibility_failures == 0 then
    page_html = page_html .. "<tr><td>Toolpath visibility</td><td>All sheet passes completed without Lua errors.</td></tr>"
  else
    page_html = page_html .. "<tr><td>Toolpath visibility</td><td>Failures: " .. results.visibility_failures .. "<br>" .. HtmlEscape(results.visibility_error) .. "</td></tr>"
  end

  if #results.names > 0 then
    page_html = page_html .. "<tr><td>Toolpaths added (" .. #results.names .. ")</td><td>"
    for i, name in ipairs(results.names) do
      if i > 1 then page_html = page_html .. "<br>" end
      page_html = page_html .. HtmlEscape(name)
    end
    page_html = page_html .. "</td></tr>"
  end

  local status
  if results.added == 0 then
    status = "Template loaded. All visible toolpath checkboxes were turned on automatically."
  else
    status = "OK: template loaded. When VCarve asked to apply to all sheets and you chose Yes, it was applied to every sheet. All toolpath checkboxes were turned on automatically."
  end

  page_html = page_html .. "<tr><td>Status</td><td>" .. HtmlEscape(status) .. "</td></tr>"
  page_html = page_html .. "</table>"
  page_html = page_html .. g_ReportFooterHtml

  local dialog = HTML_Dialog(
    true, page_html,
    g_options.windowWidth, g_options.windowHeight,
    g_title .. " - Status Report"
  )
  dialog:ShowDialog()
end

function main(script_path)
  local job = VectricJob()
  if not job.Exists then
    MessageBox("No job open.")
    return false
  end

  LoadDefaults(g_options)

  local fd = FileDialog()
  if not fd:FileOpen(
    "ToolpathTemplate",
    g_options.templatePath,
    "Toolpath Templates (*.ToolpathTemplate)|*.ToolpathTemplate|"
  ) then
    return false
  end
  g_options.templatePath = fd.PathName

  DisplayDialog(script_path)
  return true
end

g_ReportHeaderHtml = [[
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
  "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>Fast CNC Apply Toolpath To All Sheets Status</title>
  <style type="text/css">
    body {
      background-color: #f3f4f6;
      color: #111111;
      font-family: Arial, Helvetica, sans-serif;
      font-size: 11px;
      margin: 12px;
    }
    h1 {
      font-size: 17px;
      margin: 0 0 8px 0;
    }
    .report {
      background-color: #ffffff;
      border-collapse: collapse;
      width: 100%;
    }
    .report td {
      border: 1px solid #d1d5db;
      padding: 6px 8px;
      vertical-align: top;
    }
  </style>
</head>
<body>
  <h1>Toolpath Template Status</h1>
]]

g_ReportFooterHtml = [[
</body>
</html>
]]
