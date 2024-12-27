DebuggingEnabled = false

PassivesRef = {
    TR_LongbowRange = true,
    TR_HeavyCrossbowRange = true,
    TR_ShortbowRange = true,
    TR_HandCrossbowRange = true,
    TR_DartRange = true
}

WeaponBoosts = {
    BG3 = "IF(not TR_LongRangeCheckOriginal(context.Source)):Disadvantage(AttackRoll)",
    DnD5e = "IF(not TR_LongRangeCheck(context.Source)):Disadvantage(AttackRoll)"
}

WeaponPassives = {
    WPN_Dart = "TR_DartRange",
    WPN_Sling = "TR_HandCrossbowRange",
    WPN_HandCrossbow = "TR_HandCrossbowRange",
    WPN_LightCrossbow = "TR_ShortbowRange",
    WPN_Shortbow = "TR_ShortbowRange",
    WPN_HeavyCrossbow = "TR_HeavyCrossbowRange",
    WPN_Longbow = "TR_LongbowRange"
}

---@param message string
---@vararg any
function Log(message, ...)
    if DebuggingEnabled then
        local formattedMessage = string.format(message, ...)
        Ext.Utils.Print("[True Range] " .. formattedMessage)
    end
end

-- Reloads stats files at runtime
-- Only enabled with debugging
function ReloadStats()
    if DebuggingEnabled then
        local path = "Public/TrueRange/Stats/Generated/Data/"
        local stats = {"WeaponRanges.txt", "WeaponPassives.txt"}

        for _, filename in pairs(stats) do
            local filePath = string.format("%s%s", path, filename)

            if string.len(filename) > 0 then
                Log("RELOADING %s", filePath)
                Ext.Stats.LoadStatsFile(filePath, false)
            else
                Log("Invalid file: %s", filePath)
            end
        end
    end
end

---@param fileName string
---@param data any
function Dump(fileName, data)
    if DebuggingEnabled then
        local file = "Dumps/" .. fileName .. ".json"
        Ext.IO.SaveFile(file, Ext.DumpExport(data))
        Log("%s successfully dumped", file)
    end
end

---@param time integer
---@param call function
---@vararg any
function SetTimer(time, call, ...)
    local startTime = Ext.Utils.MonotonicTime()
    local event
    local args = {...}
    event = Ext.Events.Tick:Subscribe(function()

        if Ext.Utils.MonotonicTime() - startTime >= time then
            call(table.unpack(args))
            Ext.Events.Tick:Unsubscribe(event)
        end
    end)

    return event
end

function SaveConfig()
    local newConfig = Ext.Json.Stringify(Config)

    local saveStatus = pcall(Ext.IO.SaveFile, "TrueRange/Settings.json", newConfig)

    if not saveStatus then
        Log("CONFIG: Failed to save config file")
    else
        Log("CONFIG: Config file saved successfully")
    end
end

function LoadConfig()
    Config = {
        Options = "DnD5e or BG3 - Please choose one and put it into Ruleset field.",
	    Ruleset = "DnD5e"
    }

    ConfigOptions = {
        Keys = {"DnD5e", "BG3"},
        Strings = {"Ruleset5e", "RulesetBG3"}
    }

    local status, fileContent = pcall(Ext.IO.LoadFile, "TrueRange/Settings.json")

    if not status or not fileContent then
        SaveConfig()
        Log("CONFIG: Couldn't load config. Using defaults")
    else
        local parseStatus, result = pcall(Ext.Json.Parse, fileContent)

        if not parseStatus then
            Log("CONFIG: Failed to parse JSON")
        else
            Config = result
        end
    end
end