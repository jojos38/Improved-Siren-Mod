--[[
	All content by jojos38
	You are not allowed to or use this code without jojos38 permission
--]]


-- =================== VARIABLES ===================
local M = {}
local id = 0
local config
local vehSounds
local soundsPath = "art/sound/"

local lastHorn = 0
local lastSiren = 0
local lastConfig = nil
local lastWarning = 0
local lastRumbler1 = 0
local lastRumbler2 = 0
local lastChaseMode = 0
local lastHoldSiren = 0
local lastManualSiren = 0
local wasSirenToggled = 0
local lastPlayerSeated
local soundVolumeMultiplier = 1.75

local fadeRatio = 50 -- Higher = faster fade
local fadeInTable = {}
local fadeOutTable = {}

-- local manualSirenPitch = 0
-- local manualSirenIncreaseRatio = 0.010
-- local manualSirenDecreaseRatio = 0.001

local beep = obj:createSFXSource2(soundsPath.."default_sounds/beep.wav",    "AudioDefault3D", "beep", v.data.refNodes[0].ref, 0)
local click = obj:createSFXSource2(soundsPath.."default_sounds/click.wav",    "AudioDefault3D", "click", v.data.refNodes[0].ref, 0)
-- =================== VARIABLES ===================



-- ========================================= SOME FUNCTIONS =========================================
local function useConfig(tmpConfig)
	config = tmpConfig

	-- Prepare a set of default sounds in the event one of the sound file is missing
	local s = config.sounds
	if not FS:fileExists(soundsPath..s.siren.sound)    then config.sounds.siren.sound    = "default_sounds/default_siren.wav"    end
	if not FS:fileExists(soundsPath..s.rumbler1.sound) then config.sounds.rumbler1.sound = "default_sounds/default_rumbler1.wav" end
	if not FS:fileExists(soundsPath..s.rumbler2.sound) then config.sounds.rumbler2.sound = "default_sounds/default_rumbler2.wav" end
	if not FS:fileExists(soundsPath..s.horn.sound) 	   then config.sounds.horn.sound     = "default_sounds/default_horn.wav"     end
	if not FS:fileExists(soundsPath..s.warning.sound)  then config.sounds.warning.sound  = "default_sounds/default_warning.wav"  end

	-- Checking files
	if not vehSounds then vehSounds = {} end
	for soundName, soundData in pairs(config.sounds) do
		if vehSounds[soundName] then obj:deleteSFXSource(vehSounds[soundName].id) print("old sound removed from memory") end
		print("Loading sound "..soundData.sound)
		vehSounds[soundName] = {
			name = soundName,
			id = obj:createSFXSource2(soundsPath..soundData.sound,    "AudioDefaultLoop3D", soundName..obj:getID()..id, v.data.refNodes[0].ref, 0),
			volume = soundData.volume * soundVolumeMultiplier
		}
		id = id + 1 -- The id is used because two sounds with same name won't work, even if the old one was deleted
	end
end

local function toggleSound(soundData, toggle)
	if not soundData then return end
	local soundID = soundData.id
	if toggle == true or toggle == 1 then
		obj:cutSFX(soundID)
		obj:setVolume(soundID, 0)
		obj:playSFX(soundID)
		fadeInTable[soundData.name] = 0
		fadeOutTable[soundData.name] = nil
		-- print("Turned on "..snd.name)
	else
		fadeOutTable[soundData.name] = soundData.volume
		fadeInTable[soundData.name] = nil
		-- print("Turned off "..snd.name)
	end
end

local function fadeOut(dt)
	for soundName, volume in pairs(fadeOutTable) do
		local soundID = vehSounds[soundName].id
		local newVolume = volume - dt * fadeRatio
		if newVolume < 0 then
			newVolume = 0
			obj:stopSFX(soundID)
			fadeOutTable[soundName] = nil
		else
			fadeOutTable[soundName] = newVolume
		end
		obj:setVolume(soundID, newVolume)
	end
end

local function fadeIn(dt)
	for soundName, volume in pairs(fadeInTable) do
		local sound = vehSounds[soundName]
		local soundID = sound.id
		local newVolume = volume + dt * fadeRatio
		if newVolume > sound.volume then
			newVolume = sound.volume
			fadeInTable[soundName] = nil
		else
			fadeInTable[soundName] = newVolume
		end
		obj:setVolume(soundID, newVolume)
	end
end

local function clickTone(value)
	if electrics.values.isPolice == 1 then
		sounds.playSoundOnceFollowNode("click", v.data.refNodes[0].ref, 0.45, 1)
		if value == 1 then sounds.playSoundOnceFollowNode("beep", v.data.refNodes[0].ref, 0.4, 1) end
	end
end

local function check(element)
	if electrics.values.sChaseMode == 0 then
		if playerInfo.firstPlayerSeated then -- For BeamMP
			ui_message("Enable chase mode or turn on lightbar to toggle the "..element, 3, 0, 1)
		end
		return false
	else
		return true
	end
end
-- ========================================= SOME FUNCTIONS =========================================



-- =================================== KEYS EVENTS ===================================
local function chaseMode(value, filtertype)
	clickTone((electrics.values.sChaseMode + 1) % 2)
	electrics.values.sChaseMode = (electrics.values.sChaseMode + 1) % 2
end

local function sirenToggle(value, filtertype)
	clickTone((electrics.values.sSiren + 1) % 2)
	local e = electrics.values
	if not check("siren") then return end
	-- If rumblers or warning were of then we directly set siren to on
	if e.sRumbler1 == 1 or e.sRumbler2 == 1 or e.sWarning == 1 then
		e.sRumbler1 = 0
		e.sRumbler2 = 0
		e.sWarning = 0
	end
	electrics.values.sSiren = (electrics.values.sSiren + 1) % 2
	local tmp = electrics.values.sSiren
	if tmp == 2 then tmp = 1 end
end

local function rumblerToggle(value, filtertype, rumblerNumber)
	clickTone(value)
	local e = electrics.values
	if not check("rumbler") then return end
	local otherRumblerNumber = (rumblerNumber % 2) + 1
	-- Turn of siren if it's on
	e.sSiren = 0
	e.sWarning = 0
	-- Turn off the other rumbler if it was on
	if e["sRumbler"..otherRumblerNumber] == 1 then
		e["sRumbler"..otherRumblerNumber] = 0
	end
	e["sRumbler"..rumblerNumber] = (e["sRumbler"..rumblerNumber] + 1) % 2
end

local function rumblerHold(value, filtertype, rumblerNumber)
	clickTone(value)
	local otherRumblerNumber = (rumblerNumber % 2) + 1
	-- If other rumbler is already pressed then return
	if electrics.values["sRumbler"..otherRumblerNumber] == 1 then return end
	-- If the siren was on, set it back to on
	if wasSirenToggled == true then electrics.values.sSiren = 1 end
	-- If the siren is on
	if electrics.values.sSiren == 1 and not wasSirenToggled then
		wasSirenToggled = true
		electrics.values.sSiren = 0
	else
		wasSirenToggled = false
	end
	electrics.values["sRumbler"..rumblerNumber] = value -- Set the rumbler to the input value, simple
end

local function warningToggle(value, filtertype)
	clickTone(value)
	local e = electrics.values
	if not check("warning") then return end
	e.sRumbler1 = 0
	e.sRumbler2 = 0
	e.sSiren = 0
	e.sWarning = (e.sWarning + 1) % 2
end

local function warningHold(value, filtetype)
	clickTone(value)
	electrics.values.sWarning = value
end

local function policeHorn(value, filtertype)
	electrics.values.sHorn = value
end

local function sirenHold(value, filtertype)
	clickTone(value)
	if electrics.values.sSiren ~= 1 then
		electrics.values.sHoldSiren = value
	end
end
-- =================================== KEYS EVENTS ===================================



local function updateApp()
	if playerInfo.firstPlayerSeated == false then return end
	local e = electrics.values
	local data = {
		sHorn = e.sHorn,
		sSiren = e.sSiren == 1 or e.sHoldSiren,
		sWarning = e.sWarning,
		sRumbler1 = e.sRumbler1,
		sRumbler2 = e.sRumbler2,
		sChaseMode = e.sChaseMode
	}
	guihooks.trigger('updateSirenmodApp', data)
end



-- Everything is made in updateGFX trough electrics.values for BeamMP compatibility
local function updateGFX(dt)
	-- Get electrics and check
	local e = electrics.values
	if not e then return end	
	
	-- If a new config appears then we load it
	if e.sConfig ~= lastConfig then
		useConfig(e.sConfig)
		lastConfig = e.sConfig
	end

	-- Update the app depending of the driven vehicle
	if playerInfo.firstPlayerSeated ~= lastPlayerSeated then
		updateApp()
		lastPlayerSeated = playerInfo.firstPlayerSeated
	end

	-- If it is not a vehicle police and / or doesn't have any preset, don't use the mod
	if e.isPolice == 0 then
		if e.sChaseMode == 1 then
			if playerInfo.firstPlayerSeated then -- For BeamMP
				ui_message("To use the siren you need to select a preset using the Siren Presets app", 4, 0, 1)
			end
			e.sChaseMode = 0
			return
		end
		return
	end
	
	-- If the sounds aren't loaded yet we wait
	if not vehSounds then return end

	fadeIn(dt)
	fadeOut(dt)

	-- Prevent chase mode from being enabled if using default lightbar from the game
	if e.lightbar == 2 and e.sChaseMode == 1 then
		e.sChaseMode = 0
	end

	-- Chase mode management
	if e.sChaseMode ~= lastChaseMode then
		if e.sChaseMode == 1 then
			electrics.set_lightbar_signal(1)
		else
			e.sSiren = 0
			e.sRumbler1 = 0
			e.sRumbler2 = 0
			e.sWarning = 0
			-- We only turn off the lightbar if it was on 1 because 2 is game's default
			if e.lightbar == 1 then electrics.set_lightbar_signal(0) end
		end
		updateApp()
	end

	-- Siren
	if e.sSiren ~= lastSiren and e.sHoldSiren == 0 then
		toggleSound(vehSounds.siren, e.sSiren)
		updateApp()
	end

	-- Hold siren
	-- We use different variable for hold siren so that it works even lightbar off
	if e.sHoldSiren ~= lastHoldSiren then
		toggleSound(vehSounds.siren, e.sHoldSiren)
		updateApp()
	end

	-- Horn
	if e.sHorn ~= lastHorn then
		toggleSound(vehSounds.horn, e.sHorn)
		updateApp()
	end

	-- Rumblers
	if e.sRumbler1 ~= lastRumbler1 then
		toggleSound(vehSounds.rumbler1, e.sRumbler1)
		updateApp()
	end

	if e.sRumbler2 ~= lastRumbler2 then
		toggleSound(vehSounds.rumbler2, e.sRumbler2)
		updateApp()
	end
	
	-- Warning
	if e.sWarning ~= lastWarning then
		toggleSound(vehSounds.warning, e.sWarning)
		updateApp()
	end

	-- Also enable chase mode with game's default lightbar key
	if e.lightbar == 1 and lastChaseMode == 0 then e.sChaseMode = 1 updateApp() end

	lastHorn = e.sHorn
	lastSiren = e.sSiren
	lastWarning = e.sWarning
	lastRumbler1 = e.sRumbler1
	lastRumbler2 = e.sRumbler2
	lastChaseMode = e.sChaseMode
	lastHoldSiren = e.sHoldSiren
end



local function onExtensionLoaded()
	local e = electrics.values
	e.sHorn = 0
	e.sSiren = 0
	e.sWarning = 0
	e.sRumbler1 = 0
	e.sRumbler2 = 0
	e.sHoldSiren = 0
	e.sChaseMode = 0
end



local function onReset()
	onExtensionLoaded()
end



-- Functions
M.onExtensionLoaded = onExtensionLoaded
M.updateGFX 		= updateGFX
M.useConfig 		= useConfig
M.onReset 			= onReset
-- Inputs events
M.chaseMode 		= chaseMode
M.sirenHold			= sirenHold
M.sirenToggle		= sirenToggle
M.rumblerToggle   	= rumblerToggle
M.rumblerHold 		= rumblerHold
M.warningToggle 	= warningToggle
M.warningHold 		= warningHold
M.policeHorn 		= policeHorn



return M