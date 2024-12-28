--- Recursively add weapons to a table with references to their parent stats
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

    -- Self inheritence in mods (and Honour module) removes references in Using fields
    if weapon["Proficiency Group"] then
        local proficiencies = weapon["Proficiency Group"]

        for _, proficiency in ipairs(proficiencies) do
            if WeaponProficiencies[proficiency] then
                local result = WeaponProficiencies[proficiency]
                CachedWeapons[weapon.Name] = result
                return result
            end
        end
    end

    return false
end

--- Add PassivedOnEquip to every ranged weapon
function UpdateWeapons()
    if Config == nil then
        LoadConfig()
    end

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
                Log("Updating weapon: %s", weapon)

                if originalString:sub(-1) ~= ";" and originalString ~= "" then
                    originalString = originalString .. ";"
                end

                stats.PassivesOnEquip = originalString .. passive
                stats:Sync()
            end
        end
    end
end

--- Update passives with boosts depending on ruleset setting
function UpdateBoosts()
    if Config == nil then
        LoadConfig()
    end

    local boost = WeaponBoosts[Config.Ruleset]

    for passive, _ in pairs(PassivesRef) do
        local stats = Ext.Stats.Get(passive)
        stats.Boosts = boost
        stats:Sync()

        Log("Updated passive: %s", passive)
    end
end

function SettingChanged()
    UpdateBoosts()

    local function DelayMessage()
        Ext.Net.PostMessageToServer("TrueRange_OnSettingChanged", Config.Ruleset)
    end

    SetTimer(100, DelayMessage)
end

Ext.Events.StatsLoaded:Subscribe(function()
    if CachedWeapons == nil then
        CachedWeapons = {}
    end

    UpdateWeapons()
    UpdateBoosts()
end)