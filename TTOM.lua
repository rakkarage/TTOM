-- TTOM: Moves tooltips to cursor position

local addonName, ns = ...

ns.TTOM = CreateFrame("Frame")
local TTOM = ns.TTOM
TTOM.name = addonName

TTOM.defaults = { x = 32, y = -32, anchor = "TOPLEFT", combat = true, fade = true }
TTOM.isTrackingTooltip = false

function TTOM:UpdateTooltipPosition(tooltip)
	local db = TTOMDB
	if not db then return end

	local cursorX, cursorY = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()

	local x = (cursorX / scale) + (db.x or self.defaults.x)
	local y = (cursorY / scale) + (db.y or self.defaults.y)

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

		hooksecurefunc(GameTooltip, "FadeOut", function(tooltip)
			if TTOMDB and not TTOMDB.fade then tooltip:Hide() end
		end)

		hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
			if InCombatLockdown() and not (TTOMDB and TTOMDB.combat) then
				TTOM.isTrackingTooltip = false
				return
			end
			if parent == _G["OPieVisualElementsProxy"] then
				TTOM.isTrackingTooltip = false
				return
			end
			TTOM.isTrackingTooltip = true
			self:UpdateTooltipPosition(tooltip)
		end)

		GameTooltip:HookScript("OnUpdate", function(tooltip)
			if not TTOM.isTrackingTooltip then return end
			if InCombatLockdown() and not (TTOMDB and TTOMDB.combat) then
				TTOM.isTrackingTooltip = false
				return
			end
			self:UpdateTooltipPosition(tooltip)
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
			local anchors = {
				{ "TOPLEFT",     "Top Left" },
				{ "TOP",         "Top" },
				{ "TOPRIGHT",    "Top Right" },

				{ "LEFT",        "Left" },
				{ "CENTER",      "Center" },
				{ "RIGHT",       "Right" },

				{ "BOTTOMLEFT",  "Bottom Left" },
				{ "BOTTOM",      "Bottom" },
				{ "BOTTOMRIGHT", "Bottom Right" },
			}
			for _, entry in ipairs(anchors) do
				container:Add(entry[1], entry[2])
			end
			return container:GetData()
		end, "Tooltip anchor point relative to cursor")

	Settings.CreateCheckbox(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Combat", "combat", TTOMDB, Settings.VarType.Boolean, "Enable in combat", self.defaults.combat),
		"Enabled in combat.")

	Settings.CreateCheckbox(category,
		Settings.RegisterAddOnSetting(category, "TTOM_Fade", "fade", TTOMDB, Settings.VarType.Boolean, "Enable fade", self.defaults.fade),
		"Fade tooltip.")

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
