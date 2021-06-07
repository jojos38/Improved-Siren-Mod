--[[
	All content by jojos38
	You are not allowed to or use this code without jojos38 permission
--]]


-- =================== VARIABLES ===================
local M = {}
local presetsPath = "presets"
local configFolderPath = "mods/sirenmod/config"
-- =================== VARIABLES ===================



local function getVehicleConfigPart()
	return v.config.partConfigFilename:gsub("vehicles/", "")
end



local function getVehiclePreset()
	local vehConfig = getVehicleConfigPart()
	local currConfig = split(vehConfig, "/")
	-- 1 -> vehicles
	-- 2 -> vehicle name
	-- 3 -> vehicle config
	
	-- Get vehicle config file
	if not currConfig[1] or not currConfig[2] then print("Current vehicle is not compatible with Improved Siren Mod") return end
	local configFilePath = configFolderPath.."/"..currConfig[1].."/"..currConfig[2]..".json"
	local configFile = jsonReadFile(configFilePath)
	
	-- If not config file then check for default folder
	if not configFile then
		print("No preset found for "..vehConfig.." checking for a default configuration")
		local defaultConfigFilepath = "default_configs/"..currConfig[1].."/"..currConfig[2]..".json"
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
		return jsonReadFile(presetsPath.."/.Empty.json")
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
	local currConfig = split(getVehicleConfigPart(), "/")
	-- Create config folder if it doesn't exists
	if not FS:directoryExists(configFolderPath) then
		print("Creating "..configFolderPath.." folder")
		-- Workaround because FS:directoryCreate doesn't exist in VElua
		obj:queueGameEngineLua("FS:directoryCreate('"..configFolderPath.."') be:getObjectByID("..obj:getID().."):queueLuaCommand(\"configManagerVE.saveConfig('"..configPath.."')\")")
		return
	end
		
	-- Create vehicle folder if it doesn't exists
	local vehicleConfigFolder = configFolderPath.."/"..currConfig[1]
	if not FS:directoryExists(vehicleConfigFolder) then
		print("Creating "..vehicleConfigFolder.." folder")
		-- Workaround because FS:directoryCreate doesn't exist in VElua
		obj:queueGameEngineLua("FS:directoryCreate('"..vehicleConfigFolder.."') be:getObjectByID("..obj:getID().."):queueLuaCommand(\"configManagerVE.saveConfig('"..configPath.."')\")")
		return
	end
	
	-- Write the json file
	local configFile = vehicleConfigFolder.."/"..currConfig[2]..".json"
	jsonWriteFile(configFile, {config=configPath})
end



local function onExtensionLoaded()
	electrics.values.sConfig = getVehiclePreset()
	dump(getVehiclePreset())
end



M.getPreset 		= getPreset
M.saveConfig 		= saveConfig
M.loadPreset 		= loadPreset
M.onExtensionLoaded	= onExtensionLoaded



return M
