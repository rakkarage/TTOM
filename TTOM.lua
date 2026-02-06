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

local anchorOffsets = {
	TOPLEFT     = function(w, h) return 0, -h end,
	TOPRIGHT    = function(w, h) return -w, -h end,
	BOTTOMLEFT  = function(w, h) return 0, 0 end,
	BOTTOMRIGHT = function(w, h) return -w, 0 end,
	TOP         = function(w, h) return -w/2, -h end,
	BOTTOM      = function(w, h) return -w/2, 0 end,
	LEFT        = function(w, h) return 0, -h/2 end,
	RIGHT       = function(w, h) return -w, -h/2 end,
	CENTER      = function(w, h) return -w/2, -h/2 end,
}

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
		local offsetFunc = anchorOffsets[TTOMDB.anchor] or anchorOffsets.TOPLEFT
		local offsetX, offsetY = offsetFunc(w, h)
		x = x + offsetX
		y = y + offsetY

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

function TTOM:InitializeOptions()
	local category, layout = Settings.RegisterVerticalLayoutCategory(TTOM.name)
	TTOM.category = category
	Settings.RegisterAddOnCategory(category)

	local sliderOptions = Settings.CreateSliderOptions(-64, 64, 8)
	sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
		return string.format("%d", value)
	end)

	Settings.CreateSlider(category,
		Settings.RegisterAddOnSetting(category, "TTOM_X", "x", TTOMDB, Settings.VarType.Number, "X Offset", TTOM.defaults.x),
		sliderOptions, "Horizontal offset from cursor position")

	Settings.CreateSlider(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Y", "y", TTOMDB, Settings.VarType.Number, "Y Offset", TTOM.defaults.y),
		sliderOptions, "Vertical offset from cursor position")

	Settings.CreateDropdown(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Anchor", "anchor", TTOMDB, Settings.VarType.String, "Anchor Point", TTOM.defaults.anchor),
		function()
			local container = Settings.CreateControlTextContainer()
			for anchor, text in pairs({
				TOPLEFT = "Top Left", TOPRIGHT = "Top Right",
				BOTTOMLEFT = "Bottom Left", BOTTOMRIGHT = "Bottom Right",
				TOP = "Top", BOTTOM = "Bottom",
				LEFT = "Left", RIGHT = "Right",
				CENTER = "Center"
			}) do container:Add(anchor, text) end
			return container:GetData()
		end,
		"Tooltip anchor point relative to cursor")

	Settings.CreateCheckbox(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Combat", "combat", TTOMDB, Settings.VarType.Boolean, "Allow in combat", TTOM.defaults.combat))
end
