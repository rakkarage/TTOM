function TTOM:InitializeOptions()
	local category, layout = Settings.RegisterVerticalLayoutCategory(TTOM.name)
	TTOM.category = category
	Settings.RegisterAddOnCategory(category)

	local sliderOptions = Settings.CreateSliderOptions(-64, 64, 8)
	sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
		return string.format("%d", value)
	end)

	Settings.CreateSlider(category,
		Settings.RegisterAddOnSetting(category, "X", "x", TTOMDB, Settings.VarType.Number, "X Offset", TTOM.defaults.x),
		sliderOptions, "Horizontal offset from cursor position")

	Settings.CreateSlider(category,
		Settings.RegisterAddOnSetting(category, "Y", "y", TTOMDB, Settings.VarType.Number, "Y Offset", TTOM.defaults.y),
		sliderOptions, "Vertical offset from cursor position")

	Settings.CreateDropdown(category,
		Settings.RegisterAddOnSetting(category, "Anchor", "anchor", TTOMDB, Settings.VarType.String, "Anchor Point", TTOM.defaults.anchor),
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
		Settings.RegisterAddOnSetting(category, "Combat", "combat", TTOMDB, Settings.VarType.Boolean, "Allow in combat", TTOM.defaults.combat))
end