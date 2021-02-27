--[[
	All content by jojos38
	You are not allowed to or use this code without jojos38 permission
--]]


-- =================== VARIABLES ===================
local M = {}
local presetsPath = "presets"
local configFolderPath = "mods/sirenmod/config"
-- =================== VARIABLES ===================



-- Called from js ui app
local function getPresets()
	local presetsList = FS:findFilesByRootPattern(presetsPath, '*.json', -1, true, false)
	return presetsList
end



-- Called from js ui app
local function saveConfig(configPath)
	local currVeh = be:getPlayerVehicle(0)
	if not currVeh then return end
	local currConfig = split(currVeh:getField('partConfig', ''), "/")

	-- Create config folder if it doesn't exists
	if not FS:directoryExists(configFolderPath) then FS:directoryCreate(configFolderPath) end
		
	-- Create vehicle folder if it doesn't exists
	local vehicleConfigFolder = configFolderPath.."/"..currConfig[2]
	if not FS:directoryExists(vehicleConfigFolder) then FS:directoryCreate(vehicleConfigFolder) end
	
	-- Write the json file
	local configFile = vehicleConfigFolder.."/"..currConfig[3]..".json"
	jsonWriteFile(configFile, {config=configPath})
end



-- Called from js ui app
local function usePreset(presetPath)
	local currVeh = be:getPlayerVehicle(0)
	if not currVeh then return end
	currVeh:queueLuaCommand("configManagerVE.loadPreset('"..presetPath.."')")
end



local function onUiChangedState(state)
	if state == "menu.mainmenu" then
		if not extensions.core_input_actions.getActions().s_siren then
			Lua:requestReload()
		end
	end
end



M.usePreset			= usePreset
M.saveConfig 		= saveConfig
M.getPresets 		= getPresets
M.onUiChangedState 			= onUiChangedState



return M