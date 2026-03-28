TTOM = CreateFrame("Frame")
TTOM.name = "TTOM"
TTOM.defaults = { x = 32, y = -32, anchor = "TOPLEFT", combat = true }

local usingDefaultAnchor = false

function TTOM:OnEvent(event, ...)
	if self[event] then
		self[event](self, event, ...)
	end
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

		hooksecurefunc(GameTooltip, "SetOwner", function(self, owner, anchor)
			if anchor ~= "ANCHOR_NONE" then
				usingDefaultAnchor = false
			end
		end)

		GameTooltip:HookScript("OnUpdate", function(self)
			if not usingDefaultAnchor then return end
			if InCombatLockdown() and not TTOMDB.combat then return end
			TTOM:UpdateTooltipPosition(self)
		end)

		GameTooltip:HookScript("OnHide", function(self)
			usingDefaultAnchor = false
		end)

		self:UnregisterEvent(event)
	end
end

function TTOM:UpdateTooltipPosition(tooltip)
	local cursorX, cursorY = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	local x = cursorX / scale + (tonumber(TTOMDB.x) or 32)
	local y = cursorY / scale + (tonumber(TTOMDB.y) or -32)
	tooltip:ClearAllPoints()
	tooltip:SetPoint(TTOMDB.anchor, UIParent, "BOTTOMLEFT", x, y)
end

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	if not TTOMDB then return end
	usingDefaultAnchor = true
	if InCombatLockdown() and not TTOMDB.combat then return end
	TTOM:UpdateTooltipPosition(tooltip)
end)

function TTOM_Settings()
	if not InCombatLockdown() then
		Settings.OpenToCategory(TTOM.category:GetID())
	end
end

function TTOM_AddonCompartmentClick(addonName, buttonName, menuButtonFrame)
	if addonName == "TTOM" then
		TTOM_Settings()
	end
end

SLASH_TTOM1 = "/ttom"
SLASH_TTOM2 = "/tooltiponmouse"
SlashCmdList["TTOM"] = TTOM_Settings

function TTOM:InitializeOptions()
	local category = Settings.RegisterVerticalLayoutCategory(TTOM.name)
	TTOM.category = category
	Settings.RegisterAddOnCategory(category)

	local sliderOptions = Settings.CreateSliderOptions(-200, 200, 4)
	sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
		return string.format("%d", value)
	end)

	Settings.CreateSlider(category,
		Settings.RegisterAddOnSetting(category, "TTOM_X", "x", TTOMDB, Settings.VarType.Number, "X Offset",
			TTOM.defaults.x), sliderOptions, "Horizontal offset from cursor position")

	Settings.CreateSlider(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Y", "y", TTOMDB, Settings.VarType.Number, "Y Offset",
			TTOM.defaults.y), sliderOptions, "Vertical offset from cursor position")

	Settings.CreateDropdown(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Anchor", "anchor", TTOMDB, Settings.VarType.String, "Anchor Point",
			TTOM.defaults.anchor),
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
		end, "Tooltip anchor point relative to cursor")

	Settings.CreateCheckbox(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Combat", "combat", TTOMDB, Settings.VarType.Boolean,
			"Allow in combat", TTOM.defaults.combat))
end
