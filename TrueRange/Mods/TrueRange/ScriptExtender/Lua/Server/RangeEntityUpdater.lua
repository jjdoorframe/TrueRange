--- Reequip weapons to reapply passives because they get cached
function UpdateEntities()
    local entities = Ext.Entity.GetAllEntitiesWithComponent("PassiveContainer")
    local equipTable = {}

    for _, entity in pairs(entities) do
        local characterGuid = entity.Uuid.EntityUuid
        local passives = entity.PassiveContainer.Passives

        for _, passiveEntity in ipairs(passives) do
            local ref = passiveEntity.Passive
            if ref ~= nil and PassivesRef[ref.PassiveId] then
                local itemGuid = ref.Source.Uuid.EntityUuid
                equipTable[characterGuid] = itemGuid
                Osi.Unequip(characterGuid, itemGuid)
            end
        end
    end

    local function Equip()
        for characterGuid, itemGuid in pairs(equipTable) do
            Osi.Equip(characterGuid, itemGuid, 0, 0, 0)
        end
    end

    -- It takes longer than a frame for a passive applied from equipment to be removed from entity
    SetTimer(10, Equip)

    Log("Updated entities")
end

function SavePersitence()
    if CachedRuleset ~= nil then
        Ext.Vars.GetModVariables(ModuleUUID).CachedSetting = CachedRuleset
    end
end


Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function()
    if Config ~= nil and CachedRuleset ~= nil and Config.Ruleset ~= CachedRuleset then
        UpdateEntities()
    end
end)


Ext.RegisterNetListener("TrueRange_OnSettingChanged", function(call, payload)
    UpdateEntities()

    if payload ~= nil then
        CachedRuleset = payload
        SavePersitence()
    end
end)

Ext.Events.SessionLoaded:Subscribe(function()
    local modvars = Ext.Vars.GetModVariables(ModuleUUID)
    LoadConfig()

    if CachedRuleset == nil then
        if modvars and modvars.CachedSetting then
            CachedRuleset = modvars.CachedSetting
        elseif Config and Config.Ruleset then
            CachedRuleset = Config.Ruleset
        end
    end

    SavePersitence()
end)