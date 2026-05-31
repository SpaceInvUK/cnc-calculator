-- VECTRIC LUA SCRIPT
-- Fast CNC - Save All Sheets Toolpaths
--
-- Saves the already-created toolpaths in the current job, grouped by sheet.

require "strict"

g_version = "0.3c"
g_title = "Fast CNC Save All Sheets Toolpaths"
g_gadget_name = "FastCncSaveAllSheetsToolpaths"
g_default_post = "PEGASUS (Syntec) (mm) ATC (*.nc)"

g_options = {
  outputFolder = "C:\\Users\\ednei\\Downloads\\Vcarve\\CNC_Output",
  postName = g_default_post,
  windowWidth = 760,
  windowHeight = 420
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

function HtmlEscapeLines(value)
  local text = tostring(value or "")
  local lines = {}

  for line in string.gmatch(text, "([^\n]+)") do
    table.insert(lines, HtmlEscape(line))
  end

  if #lines == 0 then
    return ""
  end

  return table.concat(lines, "<br>")
end

function SanitizeFileName(value)
  local text = Trim(value)
  text = string.gsub(text, "[\\/:*?\"<>|]", "_")
  text = string.gsub(text, "%s+", "_")
  text = string.gsub(text, "_+", "_")
  text = string.gsub(text, "^_+", "")
  text = string.gsub(text, "_+$", "")
  if text == "" then
    text = "Sheet"
  end
  return text
end

function JoinPath(folder, file_name)
  if string.sub(folder, -1) == "\\" or string.sub(folder, -1) == "/" then
    return folder .. file_name
  end
  return folder .. "\\" .. file_name
end

function GetFolderFromPath(path)
  local text = Trim(path)
  local folder = string.match(text, "^(.*)[\\/][^\\/]*$")

  if folder == nil or folder == "" then
    return text
  end

  return folder
end

function SaveDefaults(options)
  local registry = Registry(g_gadget_name)
  registry:SetString("outputFolder", options.outputFolder)
  registry:SetString("postName", options.postName)
  registry:SetInt("windowWidth", options.windowWidth)
  registry:SetInt("windowHeight", options.windowHeight)
end

function LoadDefaults(options)
  local registry = Registry(g_gadget_name)
  options.outputFolder = registry:GetString("outputFolder", options.outputFolder)
  options.postName = registry:GetString("postName", options.postName)

  local width = registry:GetInt("windowWidth", options.windowWidth)
  local height = registry:GetInt("windowHeight", options.windowHeight)
  if width >= 520 then
    options.windowWidth = width
  end
  if height >= 320 then
    options.windowHeight = height
  end
end

function UpdateOptionsFromDialog(dialog, options)
  options.windowWidth = dialog.WindowWidth
  options.windowHeight = dialog.WindowHeight
  local label_folder = Trim(dialog:GetLabelField("OutputFolderLabel"))
  if label_folder ~= "" then
    options.outputFolder = label_folder
  end
  options.postName = dialog:GetDropDownListValue("PostNameSelector")

  if options.outputFolder == "" then
    MessageBox("Choose an output folder.")
    return false
  end

  if options.postName == "" then
    MessageBox("Choose a post processor.")
    return false
  end

  return true
end

function OnDirectoryPicker_ChooseOutputFolderButton(dialog)
  local output_folder = Trim(dialog:GetLabelField("OutputFolderLabel"))
  if output_folder ~= "" then
    g_options.outputFolder = output_folder
  end

  SaveDefaults(g_options)

  return true
end

function PopulatePostDropDownList(dialog, drop_down_html_id, default_post)
  local toolpath_saver = ToolpathSaver()
  local selected_post = default_post

  if selected_post == "" then
    local default_pp = toolpath_saver.DefaultPost
    if default_pp ~= nil then
      selected_post = default_pp.Name
    end
  end

  dialog:AddDropDownList(drop_down_html_id, selected_post)

  local num_posts = toolpath_saver:GetNumPosts()
  local post_index = 0
  while post_index < num_posts do
    local post = toolpath_saver:GetPostAtIndex(post_index)
    dialog:AddDropDownListValue(drop_down_html_id, post.Name)
    post_index = post_index + 1
  end
end

function GetPostOrDefault(toolpath_saver, post_name)
  local post = toolpath_saver:GetPostWithName(post_name)
  if post ~= nil then
    return post
  end

  post = toolpath_saver:GetPostWithName(g_default_post)
  if post ~= nil then
    return post
  end

  return nil
end

function GetSheetName(job, sheet_index)
  if sheet_index == nil or sheet_index < 0 then
    return "Unassigned"
  end

  local sheet_manager = job.SheetManager
  if sheet_manager ~= nil and sheet_manager.GetSheetIds ~= nil then
    local ok, sheet_name = pcall(function()
      local sheet_ids = sheet_manager:GetSheetIds()
      local index = 0
      for id in sheet_ids do
        if index == sheet_index then
          return sheet_manager:GetSheetName(id)
        end
        index = index + 1
      end
      return nil
    end)

    if ok and sheet_name ~= nil and sheet_name ~= "" then
      return sheet_name
    end
  end

  return "Sheet " .. tostring(sheet_index + 1)
end

function GetSheetInfos(job)
  local sheet_infos = {}
  local sheet_manager = job.SheetManager
  local num_sheets = 1
  local sheet_ids_by_index = {}

  if sheet_manager ~= nil then
    pcall(function()
      num_sheets = sheet_manager.NumberOfSheets
    end)

    if num_sheets == nil or num_sheets < 1 then
      num_sheets = 1
    end

    pcall(function()
      local sheet_ids = sheet_manager:GetSheetIds()
      local index = 0
      for id in sheet_ids do
        sheet_ids_by_index[index] = id
        index = index + 1
      end
    end)
  end

  for sheet_index = 0, num_sheets - 1 do
    local sheet_name = nil

    if sheet_manager ~= nil and sheet_ids_by_index[sheet_index] ~= nil then
      pcall(function()
        sheet_name = sheet_manager:GetSheetName(sheet_ids_by_index[sheet_index])
      end)
    end

    if sheet_name == nil or sheet_name == "" then
      sheet_name = "Sheet " .. tostring(sheet_index + 1)
    end

    table.insert(sheet_infos, {
      index = sheet_index,
      name = sheet_name
    })
  end

  return sheet_infos
end

function GetToolpathSheetIndex(toolpath)
  local sheet_index = -1

  pcall(function()
    if toolpath.HasActiveSheetIndex then
      sheet_index = toolpath.ActiveSheetIndex
    end
  end)

  if sheet_index == nil then
    sheet_index = -1
  end

  return sheet_index
end

function CollectToolpathList(toolpath_manager)
  local toolpaths = {}
  local pos = toolpath_manager:GetHeadPosition()

  while pos ~= nil do
    local toolpath
    toolpath, pos = toolpath_manager:GetNext(pos)

    if toolpath ~= nil then
      table.insert(toolpaths, {
        toolpath = toolpath,
        name = toolpath.Name,
        sheetIndex = GetToolpathSheetIndex(toolpath)
      })
    end
  end

  return toolpaths
end

function AddToolpathGroup(groups, keys, key, sheet_index, sheet_name, toolpath_items)
  if groups[key] == nil then
    groups[key] = {
      sheetIndex = sheet_index,
      sheetName = sheet_name,
      toolpaths = {},
      names = {}
    }
    table.insert(keys, key)
  end

  for _, item in ipairs(toolpath_items) do
    table.insert(groups[key].toolpaths, item.toolpath)
    table.insert(groups[key].names, item.name)
  end
end

function CollectToolpathsByRecordedSheet(job, toolpath_items)
  local groups = {}
  local keys = {}
  local assigned_count = 0
  local unassigned_count = 0

  for _, item in ipairs(toolpath_items) do
    local sheet_index = item.sheetIndex
    local key = tostring(sheet_index)

    if sheet_index >= 0 then
      assigned_count = assigned_count + 1
    else
      unassigned_count = unassigned_count + 1
    end

    AddToolpathGroup(
      groups,
      keys,
      key,
      sheet_index,
      GetSheetName(job, sheet_index),
      { item }
    )
  end

  table.sort(keys, function(a, b)
    return groups[a].sheetIndex < groups[b].sheetIndex
  end)

  return groups, keys, assigned_count, unassigned_count
end

function SameToolpathName(a, b)
  return Trim(a or "") == Trim(b or "")
end

function ToolpathNamesRepeatInSheetBlocks(toolpath_items, num_sheets, per_sheet_count)
  for sheet_index = 1, num_sheets - 1 do
    for item_index = 1, per_sheet_count do
      local base_name = toolpath_items[item_index].name
      local other_name = toolpath_items[(sheet_index * per_sheet_count) + item_index].name
      if not SameToolpathName(base_name, other_name) then
        return false
      end
    end
  end

  return true
end

function ToolpathNamesRepeatByOperation(toolpath_items, num_sheets, per_sheet_count)
  for op_index = 0, per_sheet_count - 1 do
    local base_name = toolpath_items[(op_index * num_sheets) + 1].name
    for sheet_index = 1, num_sheets - 1 do
      local other_name = toolpath_items[(op_index * num_sheets) + sheet_index + 1].name
      if not SameToolpathName(base_name, other_name) then
        return false
      end
    end
  end

  return true
end

function CollectToolpathsByToolpathOrder(toolpath_items, sheet_infos)
  local groups = {}
  local keys = {}
  local num_sheets = #sheet_infos
  local total_count = #toolpath_items

  if num_sheets <= 1 then
    AddToolpathGroup(groups, keys, "0", 0, sheet_infos[1].name, toolpath_items)
    return groups, keys, "Single sheet"
  end

  if math.fmod(total_count, num_sheets) ~= 0 then
    for item_index, item in ipairs(toolpath_items) do
      AddToolpathGroup(
        groups,
        keys,
        "Toolpath" .. tostring(item_index),
        -1,
        "Toolpath " .. string.format("%02d", item_index),
        { item }
      )
    end

    return groups, keys, "Fallback: one CNC file per toolpath because " .. total_count ..
      " toolpaths cannot be divided evenly across " .. num_sheets .. " sheets"
  end

  local per_sheet_count = total_count / num_sheets
  local sheet_blocks = ToolpathNamesRepeatInSheetBlocks(toolpath_items, num_sheets, per_sheet_count)
  local operation_blocks = ToolpathNamesRepeatByOperation(toolpath_items, num_sheets, per_sheet_count)

  if sheet_blocks then
    for sheet_pos, sheet_info in ipairs(sheet_infos) do
      local items = {}
      local start_index = ((sheet_pos - 1) * per_sheet_count) + 1
      local end_index = start_index + per_sheet_count - 1

      for item_index = start_index, end_index do
        table.insert(items, toolpath_items[item_index])
      end

      AddToolpathGroup(groups, keys, tostring(sheet_info.index), sheet_info.index, sheet_info.name, items)
    end

    return groups, keys, "Toolpath order: repeated sheet blocks (" .. per_sheet_count .. " per sheet)"
  end

  if operation_blocks then
    for sheet_pos, sheet_info in ipairs(sheet_infos) do
      local items = {}

      for op_index = 0, per_sheet_count - 1 do
        table.insert(items, toolpath_items[(op_index * num_sheets) + sheet_pos])
      end

      AddToolpathGroup(groups, keys, tostring(sheet_info.index), sheet_info.index, sheet_info.name, items)
    end

    return groups, keys, "Toolpath order: repeated operation blocks (" .. per_sheet_count .. " per sheet)"
  end

  for sheet_pos, sheet_info in ipairs(sheet_infos) do
    local items = {}
    local start_index = ((sheet_pos - 1) * per_sheet_count) + 1
    local end_index = start_index + per_sheet_count - 1

    for item_index = start_index, end_index do
      table.insert(items, toolpath_items[item_index])
    end

    AddToolpathGroup(groups, keys, tostring(sheet_info.index), sheet_info.index, sheet_info.name, items)
  end

  return groups, keys, "Fallback: sequential groups (" .. per_sheet_count .. " per sheet)"
end

function CollectToolpathsBySheet(job, toolpath_manager)
  local toolpath_items = CollectToolpathList(toolpath_manager)
  local sheet_infos = GetSheetInfos(job)
  local groups, keys, assigned_count, unassigned_count =
    CollectToolpathsByRecordedSheet(job, toolpath_items)

  if #sheet_infos <= 1 or (assigned_count > 0 and unassigned_count == 0) then
    return groups, keys, #toolpath_items, "VCarve sheet index"
  end

  local strategy
  groups, keys, strategy = CollectToolpathsByToolpathOrder(toolpath_items, sheet_infos)
  return groups, keys, #toolpath_items, strategy
end

function DoToolpathsUseSameTool(toolpaths)
  local tool = nil

  for _, toolpath in ipairs(toolpaths) do
    if tool == nil then
      tool = toolpath.Tool
    elseif not tool:IsCompatibleTool(toolpath.Tool) then
      return false
    end
  end

  return true
end

function SaveSingleToolpath(toolpath, output_folder, post, file_base, sequence_index)
  local toolpath_saver = ToolpathSaver()
  toolpath_saver:AddToolpath(toolpath)

  local sequence_text = ""
  if sequence_index ~= nil then
    sequence_text = "_" .. string.format("%02d", sequence_index)
  end

  local output_file = file_base .. sequence_text .. "_" .. SanitizeFileName(toolpath.Name) .. "." .. post.Extension
  local output_path = JoinPath(output_folder, output_file)
  local success = toolpath_saver:SaveToolpaths(post, output_path, false)

  return success, output_path
end

function SaveToolpathGroup(toolpaths, output_folder, post, file_base)
  local toolpath_saver = ToolpathSaver()

  for _, toolpath in ipairs(toolpaths) do
    toolpath_saver:AddToolpath(toolpath)
  end

  local output_file = file_base .. "." .. post.Extension
  local output_path = JoinPath(output_folder, output_file)
  local success = toolpath_saver:SaveToolpaths(post, output_path, false)

  return success, output_path, toolpath_saver.NumberOfToolpaths
end

function SaveAllSheets(dialog)
  if not UpdateOptionsFromDialog(dialog, g_options) then
    return false
  end

  local job = VectricJob()
  if not job.Exists then
    MessageBox("No job open.")
    return false
  end

  local toolpath_manager = ToolpathManager()
  if toolpath_manager.IsEmpty then
    MessageBox("No toolpaths found in this job.")
    return false
  end

  local toolpath_saver = ToolpathSaver()
  local post = GetPostOrDefault(toolpath_saver, g_options.postName)
  if post == nil then
    MessageBox("Post processor not found:\n\n" .. g_options.postName)
    return false
  end
  g_options.postName = post.Name

  local groups, keys, total_toolpaths, grouping_strategy = CollectToolpathsBySheet(job, toolpath_manager)
  if total_toolpaths == 0 then
    MessageBox("No toolpaths found in this job.")
    return false
  end

  local results = {
    postName = post.Name,
    postExtension = post.Extension,
    supportsToolchange = post.SupportsToolchange,
    groupingStrategy = grouping_strategy,
    outputFolder = g_options.outputFolder,
    totalToolpaths = total_toolpaths,
    savedFiles = 0,
    failedFiles = 0,
    rows = {}
  }

  for _, key in ipairs(keys) do
    local group = groups[key]
    local sheet_name = group.sheetName or GetSheetName(job, group.sheetIndex)
    local sheet_number
    if group.sheetIndex >= 0 then
      sheet_number = group.sheetIndex + 1
    else
      sheet_number = 0
    end

    local file_base
    if sheet_number > 0 then
      file_base = "Sheet" .. string.format("%02d", sheet_number) .. "_" .. SanitizeFileName(sheet_name)
    else
      file_base = SanitizeFileName(sheet_name)
      if file_base == "Unassigned" then
        file_base = "Unassigned_Toolpaths"
      end
    end

    local same_tool = DoToolpathsUseSameTool(group.toolpaths)

    if post.SupportsToolchange or same_tool then
      local success, output_path, count = SaveToolpathGroup(group.toolpaths, g_options.outputFolder, post, file_base)
      if success then
        results.savedFiles = results.savedFiles + 1
        table.insert(results.rows, {
          sheetName = sheet_name,
          toolpathCount = #group.toolpaths,
          fileCount = 1,
          status = "SAVED",
          output = output_path
        })
      elseif #group.toolpaths > 1 then
        local saved_for_sheet = 0
        local failed_for_sheet = 0
        local output_lines = {}

        for toolpath_index, toolpath in ipairs(group.toolpaths) do
          local single_success, single_output_path =
            SaveSingleToolpath(toolpath, g_options.outputFolder, post, file_base, toolpath_index)

          if single_success then
            saved_for_sheet = saved_for_sheet + 1
            results.savedFiles = results.savedFiles + 1
          else
            failed_for_sheet = failed_for_sheet + 1
            results.failedFiles = results.failedFiles + 1
          end

          table.insert(output_lines, single_output_path)
        end

        table.insert(results.rows, {
          sheetName = sheet_name,
          toolpathCount = #group.toolpaths,
          fileCount = saved_for_sheet + failed_for_sheet,
          status = "Group failed; saved " .. saved_for_sheet .. ", failed " .. failed_for_sheet,
          output = table.concat(output_lines, "\n")
        })
      else
        results.failedFiles = results.failedFiles + 1
        table.insert(results.rows, {
          sheetName = sheet_name,
          toolpathCount = #group.toolpaths,
          fileCount = 1,
          status = "FAILED",
          output = output_path
        })
      end
    else
      local saved_for_sheet = 0
      local failed_for_sheet = 0
      local output_lines = {}

      for _, toolpath in ipairs(group.toolpaths) do
        local success, output_path = SaveSingleToolpath(toolpath, g_options.outputFolder, post, file_base, saved_for_sheet + failed_for_sheet + 1)
        if success then
          saved_for_sheet = saved_for_sheet + 1
          results.savedFiles = results.savedFiles + 1
        else
          failed_for_sheet = failed_for_sheet + 1
          results.failedFiles = results.failedFiles + 1
        end
        table.insert(output_lines, output_path)
      end

      table.insert(results.rows, {
        sheetName = sheet_name,
        toolpathCount = #group.toolpaths,
        fileCount = saved_for_sheet + failed_for_sheet,
        status = "Saved " .. saved_for_sheet .. ", failed " .. failed_for_sheet,
        output = table.concat(output_lines, "\n")
      })
    end
  end

  SaveDefaults(g_options)
  DisplayStatusReport(job, results)
  return true
end

function DisplayDialog(script_path)
  local html_path = "file:" .. script_path .. "\\Fast CNC Save All Sheets Toolpaths.htm"
  local dialog = HTML_Dialog(false, html_path, g_options.windowWidth, g_options.windowHeight, g_title)

  dialog:AddLabelField("GadgetTitle", g_title)
  dialog:AddLabelField("GadgetVersion", g_version)
  dialog:AddLabelField("OutputFolderLabel", g_options.outputFolder)
  dialog:AddDirectoryPicker("ChooseOutputFolderButton", "OutputFolderLabel", false)
  PopulatePostDropDownList(dialog, "PostNameSelector", g_options.postName)

  if not dialog:ShowDialog() then
    return false
  end

  return SaveAllSheets(dialog)
end

function DisplayStatusReport(job, results)
  local page_html = g_ReportHeaderHtml

  page_html = page_html .. "<p><b>Job:</b> " .. HtmlEscape(job.Name) .. "</p>"
  page_html = page_html .. "<p><b>Post:</b> " .. HtmlEscape(results.postName) .. "</p>"
  page_html = page_html .. "<p><b>Output folder:</b> " .. HtmlEscape(results.outputFolder) .. "</p>"
  page_html = page_html .. "<table class=\"report\">"
  page_html = page_html .. "<tr><td>Total toolpaths</td><td>" .. results.totalToolpaths .. "</td></tr>"
  page_html = page_html .. "<tr><td>Grouping</td><td>" .. HtmlEscape(results.groupingStrategy) .. "</td></tr>"
  page_html = page_html .. "<tr><td>Post supports toolchange</td><td>" .. tostring(results.supportsToolchange) .. "</td></tr>"
  page_html = page_html .. "<tr><td>Saved files</td><td>" .. results.savedFiles .. "</td></tr>"
  page_html = page_html .. "<tr><td>Failed files</td><td>" .. results.failedFiles .. "</td></tr>"
  page_html = page_html .. "</table>"

  page_html = page_html .. "<table class=\"report\">"
  page_html = page_html .. "<tr><th>Sheet</th><th>Toolpaths</th><th>Files</th><th>Status</th><th>Output</th></tr>"

  for _, row in ipairs(results.rows) do
    page_html = page_html ..
      "<tr><td>" .. HtmlEscape(row.sheetName) ..
      "</td><td>" .. row.toolpathCount ..
      "</td><td>" .. row.fileCount ..
      "</td><td>" .. HtmlEscape(row.status) ..
      "</td><td>" .. HtmlEscapeLines(row.output) ..
      "</td></tr>"
  end

  page_html = page_html .. "</table>"
  page_html = page_html .. g_ReportFooterHtml

  local dialog = HTML_Dialog(true, page_html, g_options.windowWidth, g_options.windowHeight, g_title .. " - Status Report")
  dialog:ShowDialog()
end

function main(script_path)
  local job = VectricJob()
  if not job.Exists then
    MessageBox("No job open.")
    return false
  end

  LoadDefaults(g_options)
  DisplayDialog(script_path)
  return true
end

g_ReportHeaderHtml = [[
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
  "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>Fast CNC Save All Sheets Toolpaths Status</title>
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
      margin-bottom: 10px;
      width: 100%;
    }
    .report td,
    .report th {
      border: 1px solid #d1d5db;
      padding: 6px 8px;
      text-align: left;
      vertical-align: top;
    }
  </style>
</head>
<body>
  <h1>Fast CNC Save All Sheets Toolpaths Status</h1>
]]

g_ReportFooterHtml = [[
</body>
</html>
]]
