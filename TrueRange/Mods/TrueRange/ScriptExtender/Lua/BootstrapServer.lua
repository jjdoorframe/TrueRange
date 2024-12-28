Ext.Require("Shared/RangeModUtils.lua")
Ext.Require("Server/RangeEntityUpdater.lua")

Ext.Events.ResetCompleted:Subscribe(ReloadStats)

Ext.Vars.RegisterModVariable(ModuleUUID, "CachedSetting", {
    Server = true
})