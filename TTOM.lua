-- 💬 TTOM: Attach tooltip to mouse, with anchor and offset.

local addonName, ns = ...

ns.TTOM = CreateFrame("Frame")
local TTOM = ns.TTOM
TTOM.name = addonName

TTOM.defaults = { x = 32, y = -32, anchor = "TOPLEFT", combat = true, fade = true, force = false }
TTOM.isTrackingTooltip = false

function TTOM:UpdateTooltipPosition(tooltip, force)
	local db = TTOMDB
	if not db then return end

	local cursorX, cursorY = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()

	local x = (cursorX / scale) + (db.x or self.defaults.x)
	local y = (cursorY / scale) + (db.y or self.defaults.y)

	if force and tooltip:GetOwner() == _G["OPieVisualElementsProxy"] then
		tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	end

	tooltip:ClearAllPoints()
	tooltip:SetPoint(db.anchor, UIParent, "BOTTOMLEFT", x, y)
end

function TTOM:OnEvent(event, ...)
	if self[event] then self[event](self, event, ...) end
end

function TTOM:ADDON_LOADED(event, name)
	if name == self.name then
		TTOMDB = TTOMDB or {}
		for key, value in pairs(self.defaults) do
			if TTOMDB[key] == nil then
				TTOMDB[key] = value
			end
		end

		self:InitializeOptions()

		local function ShouldTrackTooltip()
			return not InCombatLockdown() or (TTOMDB and TTOMDB.combat)
		end

		hooksecurefunc(GameTooltip, "FadeOut", function(tooltip)
			if TTOMDB and not TTOMDB.fade then
				tooltip:Hide()
			end
		end)

		hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, _)
			local db = TTOMDB
			if not ShouldTrackTooltip() then
				TTOM.isTrackingTooltip = false
				return
			end
			TTOM.isTrackingTooltip = true
			self:UpdateTooltipPosition(tooltip, db.force)
		end)

		GameTooltip:HookScript("OnUpdate", function(tooltip)
			local db = TTOMDB
			if db and db.force and tooltip:IsShown() then
				TTOM.isTrackingTooltip = true
				TTOM:UpdateTooltipPosition(tooltip, true)
			elseif not ShouldTrackTooltip() then
				TTOM.isTrackingTooltip = false
			elseif TTOM.isTrackingTooltip then
				self:UpdateTooltipPosition(tooltip)
			end
		end)

		GameTooltip:HookScript("OnHide", function()
			TTOM.isTrackingTooltip = false
		end)

		self:UnregisterEvent(event)
	end
end

TTOM:SetScript("OnEvent", TTOM.OnEvent)
TTOM:RegisterEvent("ADDON_LOADED")

function TTOM:InitializeOptions()
	local category = Settings.RegisterVerticalLayoutCategory(self.name)
	self.category = category

	local sliderOptions = Settings.CreateSliderOptions(-200, 200, 4)
	sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
		return string.format("%d", value)
	end)

	Settings.CreateSlider(category,
		Settings.RegisterAddOnSetting(category, "TTOM_X", "x", TTOMDB, Settings.VarType.Number, "X Offset", self.defaults.x),
		sliderOptions, "Horizontal offset from cursor position")

	Settings.CreateSlider(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Y", "y", TTOMDB, Settings.VarType.Number, "Y Offset", self.defaults.y),
		sliderOptions, "Vertical offset from cursor position")

	Settings.CreateDropdown(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Anchor", "anchor", TTOMDB, Settings.VarType.String, "Anchor Point", self.defaults.anchor),
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
		Settings.RegisterAddOnSetting(category, "TTOM_Combat", "combat", TTOMDB, Settings.VarType.Boolean, "Enable in combat", self.defaults.combat),
		"Enabled in combat.")

	Settings.CreateCheckbox(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Fade", "fade", TTOMDB, Settings.VarType.Boolean, "Enable fade", self.defaults.fade),
		"Fade tooltip.")

	Settings.CreateCheckbox(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Force", "force", TTOMDB, Settings.VarType.Boolean, "Force override", self.defaults.force),
		"Force tooltip follow.")

	Settings.RegisterAddOnCategory(category)
end

function TTOM_Settings()
	if not InCombatLockdown() then
		Settings.OpenToCategory(TTOM.category:GetID())
	end
end

SLASH_TTOM1 = "/ttom"
SLASH_TTOM2 = "/tooltiponmouse"
SlashCmdList["TTOM"] = TTOM_Settings
