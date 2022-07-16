local DATA_VERSION = 1
local mod = CreateFrame("Frame")

function _GetInstanceInfo()
    local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
    return {
        ["name"] = name,
        ["instanceType"] = instanceType,
        ["difficultyID"] = difficultyID,
        ["difficultyName"] = difficultyName,
        ["maxPlayers"] = maxPlayers,
        ["dynamicDifficulty"] = dynamicDifficulty,
        ["isDynamic"] = isDynamic,
        ["instanceID"] = instanceID,
        ["instanceGroupSize"] = instanceGroupSize,
        ["LfgDungeonID"] = LfgDungeonID,
        ["ENCOUNTERS"] = {}
    }
end

function mod:Event_ENCOUNTER_START(encounterID, encounterName, difficultyID, groupSize)
    local info = _GetInstanceInfo()
    print(("ENCOUNTER_START: %s (%s)"):format(encounterName, encounterID))

    -- Ensure instance data is there
    mod:Event_ZONE_CHANGED_NEW_AREA()

    dxe_data_gatherer.data.instances[info.instanceID].difficultyID[info.difficultyID].ENCOUNTERS[encounterID] = {
        ["encounterID"] = encounterID,
        ["encounterName"] = encounterName,
        ["difficultyID"] = difficultyID,
        ["groupSize"] = groupSize
    }
end

function mod:Event_ENCOUNTER_END(encounterID, encounterName, difficultyID, groupSize, success)
    print(("ENCOUNTER_END: %s (%s): %s"):format(tostring(encounterName), tostring(encounterID), tostring(success)))
end

function mod:Event_ZONE_CHANGED_NEW_AREA()
    local info = _GetInstanceInfo()

    if dxe_data_gatherer.data.instances == nil then dxe_data_gatherer.data.instances = {} end

    if dxe_data_gatherer.data.instances[info.instanceID] == nil then
        dxe_data_gatherer.data.instances[info.instanceID] = {["difficultyID"] = {}}
    end
    if dxe_data_gatherer.data.instances[info.instanceID].difficultyID[info.difficultyID] == nil then
        dxe_data_gatherer.data.instances[info.instanceID].difficultyID[info.difficultyID] = info
    end
end

function mod:Event_ADDON_LOADED(name)
    if name == "DXE-DataGatherer" then
        if dxe_data_gatherer == nil then
            print("DXE-DataGatherer database initialized.")
            dxe_data_gatherer = {}
        elseif dxe_data_gatherer.version == nil or dxe_data_gatherer.version ~= DATA_VERSION then
            print("DXE-DataGatherer database wiped due to format version update.")
            dxe_data_gatherer = {}
        else
            print("DXE-DataGatherer database loaded.")
        end

        local version, build, date, tocversion = GetBuildInfo()
        dxe_data_gatherer.version = DATA_VERSION
        dxe_data_gatherer.locale = GetLocale()
        dxe_data_gatherer.game_version = {
            ["version"] = version,
            ["build"] = build,
            ["date"] = date,
            ["tocversion"] = tocversion
        }
        if dxe_data_gatherer.data == nil then dxe_data_gatherer.data = {} end
    end
end

mod:SetScript("OnEvent",function(self,event,...) self["Event_" .. event](self,...) end)
mod:RegisterEvent("ADDON_LOADED")
mod:RegisterEvent("ENCOUNTER_START")
mod:RegisterEvent("ENCOUNTER_END")
mod:RegisterEvent("ZONE_CHANGED_NEW_AREA")

function DXE_DataGatherer_ResetDatabase()
    print("Wipe DXE-DataGatherer database due to user request.")
    dxe_data_gatherer = {}
    mod:Event_ADDON_LOADED("DXE-DataGatherer")
end
