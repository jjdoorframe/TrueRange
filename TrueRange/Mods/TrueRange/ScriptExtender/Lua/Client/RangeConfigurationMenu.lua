StringTable = {
    Ruleset5e = "h0fc7a2caf074440ba135372d046ee9af714a",
    RulesetBG3 = "h17bd4c2427d04f37b37919b1a81cd76db334",
    RangedAttacks = "hc136639122dd472eafee3c5e0f81cdaf444f",
    Weapon = "ha02696ea6b1e4c7c8d1b06b72bc732887d8e",
    RulesRaw = "hbf3387ef7c174b3d8281a9c16de832f39d2c",
    RulesBg = "h4ef5c2fcea564a34980ace626bbd7b11539b",
    Sling = "h22a63f4f1e774043bc612429dea6f6ec7be2",
    HandCrossbow = "h02467c46df18405e96fe5a9ba8e523d3g3f1",
    LightCrossbow = "h5eca325a16fc406181e7496625053927f443",
    Shortbow = "ha83b1a402a7e471887569d044c31f106ddbb",
    HeavyCrossbow = "h91fe8bc2fdd54676a90754a24ba58867fe8f",
    Longbow = "hbee2c13d89554007ba468e05479862b67809",
    Normal = "h18cd1524352e40b2a15d7b93271d079379fe",
    Long = "h49eefe4b8c2144a8a9e036c8aca2a8b24768",
    RefText = "h659ae2256cd24c2f99da84094a1f7f492b45",
    meters = "hbfd736c577484956a9d4bd1b651befacbc2e",
    feet = "hcc48fc6b517944c191106eab6386f0cc85af",
    ChooseRuleset = "h82de8f22180041e38221c57fef68d95df66e",
    DnD5e = "h06ebc2174ce3473097a51944ea049b0b1564",
    BG3 = "h4edf64fadacd4e3785f5765c318ee9aa6d07",
    ft = "h883212c652684c7989e07c769aab655ee6b4",
    m = "h6cf3b86b512547fc9554d34af24c4a0b3cgb",
}

---@param treeParent ExtuiTabItem
function CreateRefTable(treeParent, useFeet)
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

    for _, name in ipairs(RangeOrder) do
        weaponTable:AddRow():AddCell():AddText(GetString(name))
    end

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
    

    local rangeData = useFeet == true and RangeRef.Feet or RangeRef.Meters
    local rangeText = useFeet == true and GetString("ft") or GetString("m")

    for _, weapon in pairs(RangeOrder) do
        local data = rangeData[weapon]

        local bgRow = bgTable:AddRow()
        MakeTextCentered(bgRow, data.NormalBg .. " " .. rangeText)
        MakeTextCentered(bgRow, data.LongBg .. " " .. rangeText)

        local rawRow = rawTable:AddRow()
        MakeTextCentered(rawRow, data.NormalRaw .. " " .. rangeText)
        MakeTextCentered(rawRow, data.LongRaw .. " " .. rangeText)
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
    refTable.ColumnDefs[1] = {
        Width = 1190 * Scale(),
        WidthFixed = true
    }

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

    mainCell:AddText(WrapText("RefText", 89))
    mainCell:AddNewLine()

    mainCell:AddText("Note: BG3 has a maximum range cap for all attacks and spells at 30m / 100ft!")

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
