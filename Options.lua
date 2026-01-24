local function createFontString(parent, text)
	local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fs:SetText(text)
	return fs
end

local function createEditBox(parent, text, key)
	local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	eb:SetSize(90, 20)
	eb:SetText(text)
	eb:SetCursorPosition(0)
	eb:SetAutoFocus(false)
	eb:SetScript("OnEnterPressed", function(self) eb:ClearFocus() end)
	eb:SetScript("OnEscapePressed", function(self) eb:ClearFocus() end)
	EventRegistry:RegisterCallback("TTOM.OnReset", function()
		eb:SetText(TTOMDB[key])
		eb:SetTextColor(1, 1, 1, 1)
	end)
	return eb
end

local function createCheckbox(parent, text, key)
	local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
	cb.Text:SetText(text)
	cb:SetChecked(TTOMDB[key])
	cb:SetScript("OnClick", function(self)
		TTOMDB[key] = self:GetChecked()
	end)
	EventRegistry:RegisterCallback("TTOM.OnReset", function()
		cb:SetChecked(TTOMDB[key])
	end)
	return cb
end

local function getNumber(editBox, current)
	local number = current
	local text = editBox:GetText()
	if tonumber(text) then
		number = text
		editBox:SetTextColor(1, 1, 1, 1)
	else
		editBox:SetTextColor(1, 0.5, 0.5, 1)
	end
	return number
end

local function createButton(parent, text)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetSize(100, 40)
	b:SetText(text)
	return b
end

local function createDropDown(parent)
	local dd = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")

	local selectedValue = TTOMDB.anchor

	local function IsSelected(value)
		return value == selectedValue
	end

	local function SetSelected(value)
		selectedValue = value
		TTOMDB.anchor = value
		dd:SetText(value)
	end

	EventRegistry:RegisterCallback("TTOM.OnReset", function()
		selectedValue = TTOMDB.anchor
		dd:SetText(selectedValue)
	end)

	MenuUtil.CreateRadioMenu(dd,
		IsSelected,
		SetSelected,
		{ "TOPLEFT", "TOPLEFT" },
		{ "TOPRIGHT", "TOPRIGHT" },
		{ "BOTTOMLEFT", "BOTTOMLEFT" },
		{ "BOTTOMRIGHT", "BOTTOMRIGHT" },
		{ "TOP", "TOP" },
		{ "BOTTOM", "BOTTOM" },
		{ "LEFT", "LEFT" },
		{ "RIGHT", "RIGHT" },
		{ "CENTER", "CENTER" }
	)
	return dd
end

function TTOM:InitializeOptions()
	self.options = CreateFrame("Frame")
	self.options.name = TTOM.title
	TTOM.category = Settings.RegisterCanvasLayoutCategory(self.options, TTOM.title)
	Settings.RegisterAddOnCategory(TTOM.category)

	local xEdit, yEdit
	xEdit = createEditBox(self.options, TTOMDB.x, "x")
	xEdit:SetPoint("TOPLEFT", 16, -16)
	xEdit:SetScript("OnTabPressed", function(self) yEdit:SetFocus() end)
	xEdit:SetScript("OnTextChanged", function(self, user)
		if user then TTOMDB.x = getNumber(xEdit, TTOMDB.x) end
	end)

	local xLabel = createFontString(self.options, "X Offset")
	xLabel:SetPoint("LEFT", xEdit, "RIGHT", 16, 0)

	yEdit = createEditBox(self.options, TTOMDB.y, "y")
	yEdit:SetPoint("TOPLEFT", xEdit, "BOTTOMLEFT", 0, -16)
	yEdit:SetScript("OnTabPressed", function(self) xEdit:SetFocus() end)
	yEdit:SetScript("OnTextChanged", function(self, user)
		if user then TTOMDB.y = getNumber(yEdit, TTOMDB.y) end
	end)

	local yLabel = createFontString(self.options, "Y Offset")
	yLabel:SetPoint("LEFT", yEdit, "RIGHT", 16, 0)

	local anchor = createDropDown(self.options)
	anchor:SetPoint("TOPLEFT", yEdit, "BOTTOMLEFT", -5, -16)

	local anchorLabel = createFontString(self.options, "Anchor")
	anchorLabel:SetPoint("LEFT", anchor, "RIGHT", 10, 0)

	local combatCheck = createCheckbox(self.options, "Follow Mouse in Combat", "combat")
	combatCheck:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 5, -16)

	local reset = createButton(self.options, "Reset")
	reset:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 16, -16)
	reset:SetScript("OnClick", function()
		TTOMDB = CopyTable(TTOM.defaults)
		EventRegistry:TriggerEvent("TTOM.OnReset")
	end)
end
