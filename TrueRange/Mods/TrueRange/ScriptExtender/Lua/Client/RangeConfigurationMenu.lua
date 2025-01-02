---@param treeParent ExtuiTabItem
function CreateRefTable(treeParent, useFeet)
    local mainTable = treeParent:AddTable("mainTable", 1)
    mainTable.SizingStretchProp = true

    local topTable = treeParent:AddTable("topTable", 2)
    topTable:SetColor("TableHeaderBg", ToVec4(69, 49, 33, 0.8))
    topTable.SizingStretchProp = true

    local mainRow = topTable:AddRow()
    local weaponHeaderTable = mainRow:AddCell():AddTable("topTable", 1)
    weaponHeaderTable.SizingStretchProp = true
    local weaponRow = weaponHeaderTable:AddRow()
    weaponRow.Headers = true
    MakeTextCentered(weaponRow, GetString("Weapon"))
    local weaponRow2 = weaponHeaderTable:AddRow()
    weaponRow2.Headers = true
    weaponRow2:AddCell():AddText(" ")

    local weaponTable = weaponHeaderTable:AddRow():AddCell():AddTable("topTable", 1)
    weaponTable.SizingStretchProp = true
    weaponTable.BordersInnerH = true

    local rulesTable = mainRow:AddCell():AddTable("rulesTable", 2)
    rulesTable.SizingStretchSame = true

    local rulesHeader = rulesTable:AddRow()
    rulesHeader.Headers = true
    MakeTextCentered(rulesHeader, GetString("RulesBg"))
    MakeTextCentered(rulesHeader, GetString("RulesRaw"))

    local splitRow = rulesTable:AddRow()

    local bgTable = splitRow:AddCell():AddTable("bgTable", 2)
    bgTable.BordersInnerH = true
    bgTable.SizingStretchSame = true

    local bgHeader = bgTable:AddRow()
    bgHeader.Headers = true
    MakeTextCentered(bgHeader, GetString("Normal"))
    MakeTextCentered(bgHeader, GetString("Long"))

    local rawTable = splitRow:AddCell():AddTable("rawTable", 2)
    rawTable.BordersInnerH = true
    rawTable.SizingStretchSame = true

    local rawHeader = rawTable:AddRow()
    rawHeader.Headers = true
    MakeTextCentered(rawHeader, GetString("Normal"))
    MakeTextCentered(rawHeader, GetString("Long"))

    local rangeIndex = useFeet == true and 2 or 1
    local rangeText = useFeet == true and GetString("ft") or GetString("m")

    for _, mod in ipairs(CommonRanges) do
        if mod.Name == "Base" or (mod.ModUUID ~= nil and Ext.Mod.IsModLoaded(mod.ModUUID) == true) then
            for _, weapon in ipairs(mod.Data) do
                local namePrefix = mod.Name == "Base" and "" or "(" .. GetString(mod.Name) .. ") "
                weaponTable:AddRow():AddCell():AddText(namePrefix .. GetString(weapon.Name))

                local bgRow = bgTable:AddRow()
                MakeTextCentered(bgRow, weapon.NormalBg[rangeIndex] .. " " .. rangeText)
                MakeTextCentered(bgRow, weapon.LongBg[rangeIndex] .. " " .. rangeText)
        
                local rawRow = rawTable:AddRow()
                MakeTextCentered(rawRow, weapon.NormalRaw[rangeIndex] .. " " .. rangeText)
                MakeTextCentered(rawRow, weapon.LongRaw[rangeIndex] .. " " .. rangeText)
            end
        end
    end
end

---@param treeParent ExtuiTreeParent
function RangeTab(treeParent)
    if WidgetRefs.RangeTab ~= nil then
        return
    end

    WidgetRefs.RangeTab = treeParent

    if Config == nil then
        LoadConfig()
    end

    local refTable = treeParent:AddTable("RefTable", 1)
    refTable:SetStyle("CellPadding", 0)

    local mainCell = refTable:AddRow():AddCell()

    MakeTitle(mainCell, "ChooseRuleset")

    local currentOption = Config.Ruleset
    local currentIndex
    local foundOption = false
    local optionStrings = {}

    for i, option in ipairs(ConfigOptions.Keys) do
        table.insert(optionStrings, GetString(ConfigOptions.Keys[i]))

        if option == currentOption then
            foundOption = true
            currentIndex = i
        end
    end

    if foundOption == false then
        currentIndex = 1
    end

    local combo = mainCell:AddCombo(" ")
    local tooltip = combo:Tooltip():AddText(GetString(ConfigOptions.Strings[currentIndex]))
    combo.Options = optionStrings
    combo.SelectedIndex = currentIndex - 1
    combo.OnChange = function(c)
        currentIndex = c.SelectedIndex + 1
        Config.Ruleset = ConfigOptions.Keys[currentIndex]
        SaveConfig()
        tooltip:Destroy()
        tooltip = combo:Tooltip():AddText(GetString(ConfigOptions.Strings[currentIndex]))
        SettingChanged()
    end

    MakeTitle(mainCell, "RangedAttacks")

    local refText = mainCell:AddText(GetString("RefText"))
    refText.TextWrapPos = 0
    mainCell:AddNewLine()

    mainCell:AddText(GetString("DistanceNote"))

    local refTableGroup = mainCell:AddGroup("RefTableGroup")
    WidgetRefs.TableGroup = refTableGroup

    local tabBar = refTableGroup:AddTabBar("TabBar")
    local feetTab = tabBar:AddTabItem(GetString("feet"))
    local metersTab = tabBar:AddTabItem(GetString("meters"))

    CreateRefTable(feetTab, true)
    CreateRefTable(metersTab, false)
end

if Ext.Mod.IsModLoaded("755a8a72-407f-4f0d-9a33-274ac0f0b53d") == true then
    LoadConfig()

    if WidgetRefs == nil then
        WidgetRefs = {}
    end

    Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, Ext.Loca.GetTranslatedString("h3996d2b36b9a4d3fa94ff19a147bb148e6eb"), RangeTab)
end
