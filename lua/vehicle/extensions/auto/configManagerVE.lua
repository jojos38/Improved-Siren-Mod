--[[
	All content by jojos38
	You are not allowed to or use this code without jojos38 permission
--]]


-- =================== VARIABLES ===================
local M = {}
local presetsPath = "presets"
local configFolderPath = "mods/sirenmod/config"
-- =================== VARIABLES ===================


local function getVehiclePreset()
	local vehConfig = v.config.partConfigFilename
	local currConfig = split(vehConfig, "/")
	-- 1 -> vehicles
	-- 2 -> vehicle name
	-- 3 -> vehicle config
	
	-- Get vehicle config file
	local configFilePath = configFolderPath.."/"..currConfig[2].."/"..currConfig[3]..".json"
	local configFile = jsonReadFile(configFilePath)
	
	-- If not config file then check for default folder
	if not configFile then
		print("No preset found for "..vehConfig.." checking for a default configuration")
		local defaultConfigFilepath = "default_configs/"..currConfig[2].."/"..currConfig[3]..".json"
		configFile = jsonReadFile(defaultConfigFilepath)
	end
	
	-- Get the preset from the config file
	if configFile then
		print("Loading preset "..configFile.config.." for vehicle "..vehConfig)
		electrics.values.isPolice = true -- enable the mod for this vehicle
		return jsonReadFile(configFile.config)
	else		
		print("No preset found for "..vehConfig.." disabling mod for this vehicle")
		electrics.values.isPolice = false -- Disable the mod for this vehicle
		return jsonReadFile(presetsPath.."/.Default.json")
	end
end



-- Called from Javascript ui app
local function loadPreset(presetPath)
	local preset = jsonReadFile(presetPath)
	if not preset then print("Preset not found "..presetPath.." using default preset") end
	electrics.values.isPolice = true -- enable the mod for this vehicle
	electrics.values.sConfig = preset or jsonReadFile(presetsPath.."/Default.json")
end



-- Called from Javascript ui app
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



local function onExtensionLoaded()
	electrics.values.sConfig = getVehiclePreset()
end



M.getPreset = getPreset
M.loadPreset = loadPreset
M.onExtensionLoaded		= onExtensionLoaded



return M