RangeOrder = {
    "Dart",
    "Sling",
    "HandCrossbow",
    "LightCrossbow",
    "Shortbow",
    "HeavyCrossbow",
    "Longbow"
}

RangeRef = {
    Meters = {
        Dart = {
            NormalRaw = 6,
            LongRaw = 18,
            NormalBg = 12,
            LongBg = 30,
        },
        Sling = {
            NormalRaw = 9,
            LongRaw = 36,
            NormalBg = 14,
            LongBg = 30,
        },
        HandCrossbow = {
            NormalRaw = 9,
            LongRaw = 36,
            NormalBg = 14,
            LongBg = 30,
        },
        LightCrossbow = {
            NormalRaw = 24,
            LongRaw = 97,
            NormalBg = 18,
            LongBg = 30,
        },
        Shortbow = {
            NormalRaw = 24,
            LongRaw = 97,
            NormalBg = 18,
            LongBg = 30,
        },
        HeavyCrossbow = {
            NormalRaw = 30,
            LongRaw = 121,
            NormalBg = 22,
            LongBg = 30,
        },
        Longbow = {
            NormalRaw = 45,
            LongRaw = 182,
            NormalBg = 25,
            LongBg = 30,
        }
    },
    Feet = {
        Dart = {
            NormalRaw = 20,
            LongRaw = 60,
            NormalBg = 40,
            LongBg = 100,
        },
        Sling = {
            NormalRaw = 30,
            LongRaw = 120,
            NormalBg = 46,
            LongBg = 100,
        },
        HandCrossbow = {
            NormalRaw = 30,
            LongRaw = 120,
            NormalBg = 46,
            LongBg = 100,
        },
        LightCrossbow = {
            NormalRaw = 80,
            LongRaw = 320,
            NormalBg = 59,
            LongBg = 100,
        },
        Shortbow = {
            NormalRaw = 80,
            LongRaw = 320,
            NormalBg = 59,
            LongBg = 100,
        },
        HeavyCrossbow = {
            NormalRaw = 100,
            LongRaw = 400,
            NormalBg = 72,
            LongBg = 100,
        },
        Longbow = {
            NormalRaw = 150,
            LongRaw = 600,
            NormalBg = 82,
            LongBg = 100,
        }
    }
}

function Scale()
    return Ext.IMGUI.GetViewportSize()[2] / 2160
end

--- Create a centered title and optional subtitle with separators at the top and bottom
---@param treeParent ExtuiTreeParent
---@param text1 string
---@param text2? string
function MakeTitle(treeParent, text1, text2)
    local separator1 = treeParent:AddSeparatorText(" ")
    separator1:SetStyle("SeparatorTextAlign", 1)
    separator1:SetStyle("SeparatorTextPadding", -10)
    separator1:SetStyle("SeparatorTextBorderSize", 10)

    if StringTable[text1] then
        text1 = GetString(text1)
    end

    local separatorText1 = treeParent:AddSeparatorText(text1)
    separatorText1:SetStyle("SeparatorTextBorderSize", 0)
    separatorText1:SetStyle("SeparatorTextPadding", 0)

    if text2 ~= nil then
        if StringTable[text2] then
            text2 = GetString(text2)
        end

        local separatorText2 = treeParent:AddSeparatorText(text2)
        separatorText2:SetStyle("SeparatorTextBorderSize", 0)
        separatorText2:SetStyle("SeparatorTextPadding", 0)
    end

    local separator2 = treeParent:AddSeparatorText(" ")
    separator2:SetStyle("SeparatorTextAlign", 1)
    separator2:SetStyle("SeparatorTextPadding", -10)
    separator2:SetStyle("SeparatorTextBorderSize", 10)
end

---@param key string
function GetString(key)
    local stringOut = key

    stringOut = Ext.Loca.GetTranslatedString(StringTable[key])

    if stringOut == "" then
        stringOut = key
    end

    return stringOut
end

---@param handle string
---@param maxLength integer
---@param skipNewLine? boolean
function WrapText(handle, maxLength, skipNewLine)
    local text = GetString(handle)
    local wrappedLines = {}

    local paragraphs = {}

    for paragraph in text:gmatch("[^\n]+") do
        table.insert(paragraphs, paragraph)
    end

    for _, paragraph in ipairs(paragraphs) do
        local currentLine = ""
        for word in paragraph:gmatch("%S+") do
            if #currentLine + #word + 1 <= maxLength then
                if currentLine ~= "" then
                    currentLine = currentLine .. " "
                end
                currentLine = currentLine .. word
            else
                table.insert(wrappedLines, currentLine)
                currentLine = word
            end
        end

        if currentLine ~= "" then
            table.insert(wrappedLines, currentLine)
        end

        if skipNewLine ~= true then
            table.insert(wrappedLines, "")
        end
    end

    if #wrappedLines > 0 and wrappedLines[#wrappedLines] == "" then
        table.remove(wrappedLines, #wrappedLines)
    end

    return table.concat(wrappedLines, "\n")
end

---@param r number
---@param g number
---@param b number
---@param a number
---@return number[]
function ToVec4(r, g, b, a)
    return {r / 255, g / 255, b / 255, a}
end

--- Created centered text in a new cell of a table row
---@param treeParent ExtuiTableRow
---@param text1 string
---@param text2? string
function MakeTextCentered(treeParent, text1, text2)
    local cell = treeParent:AddCell()
    local textTitle1 = cell:AddSeparatorText(GetString(text1))
    textTitle1:SetStyle("SeparatorTextBorderSize", 0)
    textTitle1:SetStyle("SeparatorTextPadding", 0)

    if text2 ~= nil then
        local textTitle2 = cell:AddSeparatorText(GetString(text2))
        textTitle2:SetStyle("SeparatorTextBorderSize", 0)
        textTitle2:SetStyle("SeparatorTextPadding", 0)
    end
end