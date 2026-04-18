-- 💬 TTOM: Attach tooltip to mouse, with anchor and offset.

local addonName = ...

local frame = CreateFrame("Frame")

local category
local defaults = { x = 32, y = -32, anchor = "TOPLEFT", combat = true, fade = true, force = false }
local isTrackingTooltip = false

local function UpdateTooltipPosition(tooltip, force)
	local cursorX, cursorY = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()

	local x = (cursorX / scale) + (TTOMDB.x or defaults.x)
	local y = (cursorY / scale) + (TTOMDB.y or defaults.y)

	if force and tooltip:GetOwner() == _G["OPieVisualElementsProxy"] then
		tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	end

	tooltip:ClearAllPoints()
	tooltip:SetPoint(TTOMDB.anchor, UIParent, "BOTTOMLEFT", x, y)
end

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local name = ...
		if name ~= addonName then return end

		TTOMDB = TTOMDB or {}
		for key, value in pairs(defaults) do
			if TTOMDB[key] == nil then
				TTOMDB[key] = value
			end
		end

		InitializeOptions()

		local function ShouldTrackTooltip()
			return not InCombatLockdown() or (TTOMDB and TTOMDB.combat)
		end

		hooksecurefunc(GameTooltip, "FadeOut", function(tooltip)
			if TTOMDB and not TTOMDB.fade then
				tooltip:Hide()
			end
		end)

		hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip)
			isTrackingTooltip = false
			if not ShouldTrackTooltip() then return end
			if not TTOMDB.force and tooltip:GetOwner() == _G["OPieVisualElementsProxy"] then return end
			isTrackingTooltip = true
			UpdateTooltipPosition(tooltip, TTOMDB.force)
		end)

		GameTooltip:HookScript("OnUpdate", function(tooltip)
			if not ShouldTrackTooltip() then
				isTrackingTooltip = false
				return
			end
			if TTOMDB and TTOMDB.force and tooltip:GetOwner() == _G["OPieVisualElementsProxy"] then
				isTrackingTooltip = true
				UpdateTooltipPosition(tooltip, true)
				return
			end
			if isTrackingTooltip then
				UpdateTooltipPosition(tooltip)
			end
		end)

		GameTooltip:HookScript("OnHide", function()
			isTrackingTooltip = false
		end)

		self:UnregisterEvent(event)
	end
end)

function InitializeOptions()
	category = Settings.RegisterVerticalLayoutCategory(addonName)

	local sliderOptions = Settings.CreateSliderOptions(-200, 200, 4)
	sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
		return string.format("%d", value)
	end)

	Settings.CreateSlider(category,
		Settings.RegisterAddOnSetting(category, "TTOM_X", "x", TTOMDB, Settings.VarType.Number, "X Offset", defaults.x),
		sliderOptions, "Horizontal offset from cursor position")

	Settings.CreateSlider(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Y", "y", TTOMDB, Settings.VarType.Number, "Y Offset", defaults.y),
		sliderOptions, "Vertical offset from cursor position")

	Settings.CreateDropdown(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Anchor", "anchor", TTOMDB, Settings.VarType.String, "Anchor Point", defaults.anchor),
		function()
			local container = Settings.CreateControlTextContainer()
			container:Add("TOPLEFT", "Top Left")
			container:Add("TOP", "Top")
			container:Add("TOPRIGHT", "Top Right")
			container:Add("LEFT", "Left")
			container:Add("CENTER", "Center")
			container:Add("RIGHT", "Right")
			container:Add("BOTTOMLEFT", "Bottom Left")
			container:Add("BOTTOM", "Bottom")
			container:Add("BOTTOMRIGHT", "Bottom Right")
			return container:GetData()
		end, "Tooltip anchor point relative to cursor")

	Settings.CreateCheckbox(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Combat", "combat", TTOMDB, Settings.VarType.Boolean, "Enable in combat", defaults.combat),
		"Enabled in combat.")

	Settings.CreateCheckbox(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Fade", "fade", TTOMDB, Settings.VarType.Boolean, "Enable fade", defaults.fade),
		"Fade tooltip.")

	Settings.CreateCheckbox(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Force", "force", TTOMDB, Settings.VarType.Boolean, "Force override", defaults.force),
		"Force tooltip follow.")

	Settings.RegisterAddOnCategory(category)
end

function TTOM_Settings()
	if not InCombatLockdown() then
		Settings.OpenToCategory(category:GetID())
	end
end

SLASH_TTOM1 = "/ttom"
SLASH_TTOM2 = "/tooltiponmouse"
SlashCmdList["TTOM"] = TTOM_Settings
