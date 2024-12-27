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
end


Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function()
    UpdateEntities()
end)


Ext.RegisterNetListener("TrueRange_UpdateEntities", function()
    UpdateEntities()
end)