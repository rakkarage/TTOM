TTOM = CreateFrame("Frame")
TTOM.name = "TTOM"
TTOM.defaults = { x = 32, y = -32, anchor = "TOPLEFT", combat = true }
TTOM.tooltips = {}

function TTOM:OnEvent(event, ...)
	self[event](self, event, ...)
end

TTOM:SetScript("OnEvent", TTOM.OnEvent)
TTOM:RegisterEvent("ADDON_LOADED")

function TTOM:ADDON_LOADED(event, name)
	if name == TTOM.name then
		TTOMDB = TTOMDB or {}
		for key, value in pairs(self.defaults) do
			if TTOMDB[key] == nil then
				TTOMDB[key] = value
			end
		end
		self:InitializeOptions()
		self:UnregisterEvent(event)
	end
end

local function TTOM_UpdateTooltip(tooltip)
	if not tooltip.update then return end
	if not TTOMDB.combat and InCombatLockdown() then return end
	
	local success, x, y = pcall(function()
		local w = tooltip:GetWidth()
		local h = tooltip:GetHeight()
		local scale = UIParent:GetEffectiveScale()
		local cursorX, cursorY = GetCursorPosition()
		local x = cursorX / scale + (tonumber(TTOMDB.x) or 32)
		local y = cursorY / scale + (tonumber(TTOMDB.y) or -32)
		
		local anchor = TTOMDB.anchor
		if anchor == "TOPLEFT" then
			y = y - h
		elseif anchor == "TOPRIGHT" then
			x = x - w
			y = y - h
		elseif anchor == "BOTTOMRIGHT" then
			x = x - w
		elseif anchor == "TOP" then
			x = x - w / 2
			y = y - h
		elseif anchor == "BOTTOM" then
			x = x - w / 2
		elseif anchor == "LEFT" then
			y = y - h / 2
		elseif anchor == "RIGHT" then
			x = x - w
			y = y - h / 2
		elseif anchor == "CENTER" then
			x = x - w / 2
			y = y - h / 2
		end
		
		return x, y
	end)
	if not success then return end
	
	tooltip:ClearAllPoints()
	tooltip:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
end

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	if not TTOMDB.combat and InCombatLockdown() then return end

	tooltip.update = pcall(function()
		if parent and parent.unit then
			tooltip:SetOwner(parent, "ANCHOR_PRESERVE")
		else
			tooltip:SetOwner(parent, "ANCHOR_CURSOR")
		end
	end)

	TTOM_UpdateTooltip(tooltip)

	if tooltip.update and not TTOM.tooltips[tooltip] then
		TTOM.tooltips[tooltip] = true
		tooltip:HookScript("OnUpdate", TTOM_UpdateTooltip)
		tooltip:HookScript("OnHide", function()
			tooltip.update = false
		end)
	end
end)

SLASH_TTOM1 = "/ttom"
SLASH_TTOM2 = "/tooltiponmouse"
SlashCmdList["TTOM"] = function(msg, editFrame, noOutput)
	TTOM_Settings()
end

function TTOM_AddonCompartmentClick(addonName, buttonName, menuButtonFrame)
	if addonName == "TTOM" then
		TTOM_Settings()
	end
end

function TTOM_Settings()
	if not InCombatLockdown() then
		Settings.OpenToCategory(TTOM.category:GetID())
	else
		print("TTOM: Cannot open settings while in combat!")
	end
end
