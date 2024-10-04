--[[
	All content by jojos38
	You are not allowed to or use this code without jojos38 permission
--]]


-- =================== VARIABLES ===================
local M = {}
-- =================== VARIABLES ===================



local function onUiChangedState(state)
	if state == "menu.mainmenu" then
		if not extensions.core_input_actions.getActiveActions().s_siren then
			Lua:requestReload()
		end
	end
end



M.onUiChangedState 			= onUiChangedState



return M