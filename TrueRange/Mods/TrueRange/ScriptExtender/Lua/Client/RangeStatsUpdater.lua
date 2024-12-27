---@param weapon StatsObject
---@return string | boolean
function AddWeaponsToTable(weapon)
    if weapon == nil then
        return false
    end

    if WeaponPassives[weapon.Name] then
        CachedWeapons[weapon.Name] = weapon.Name
        return weapon.Name
    end

    if weapon.Using and weapon.Using ~= "" then
        local usingWeapon = Ext.Stats.Get(weapon.Using)

        if usingWeapon then
            local result = AddWeaponsToTable(usingWeapon)

            if result then
                CachedWeapons[weapon.Name] = result
                return result
            end
        end
    end

    return false
end

function UpdateWeapons()
    if Config == nil then
        LoadConfig()
    end

    CachedWeapons = {}
    local weapons = Ext.Stats.GetStats("Weapon")

    for _, name in ipairs(weapons) do
        local weapon = Ext.Stats.Get(name)
        AddWeaponsToTable(weapon)
    end

    for weapon, parent in pairs(CachedWeapons) do
        local stats = Ext.Stats.Get(weapon)
        local passive = WeaponPassives[parent]

        if stats then
            local originalString = tostring(stats.PassivesOnEquip:gsub("%s*$", ""))

            if not string.find(originalString, passive) then
                if originalString:sub(-1) ~= ";" then
                    originalString = originalString .. ";"
                end
    
                stats.PassivesOnEquip = originalString .. passive
                stats:Sync()
            end
        end
    end
end

function UpdateBoosts()
    if Config == nil then
        LoadConfig()
    end

    local boost = WeaponBoosts[Config.Ruleset]

    for passive, _ in pairs(PassivesRef) do
        local stats = Ext.Stats.Get(passive)
        stats.Boosts = boost
        stats:Sync()
    end
end

function SettingChanged()
    UpdateBoosts()

    local function DelayMessage()
        Ext.Net.PostMessageToServer("TrueRange_UpdateEntities", "")
    end

    SetTimer(100, DelayMessage)
end

Ext.Events.StatsLoaded:Subscribe(function()
    UpdateBoosts()
    UpdateWeapons()
end)

WeaponBoosts = {
    BG3 = "IF(TR_LongRangeCheckOriginal(context.Source) == false):Disadvantage(AttackRoll)",
    DnD5e = "IF(TR_LongRangeCheck(context.Source) == false):Disadvantage(AttackRoll)"
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
