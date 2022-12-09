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

local function createDropDown(parent, initFunc)
	local dd = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
	UIDropDownMenu_SetWidth(dd, 90)
	UIDropDownMenu_Initialize(dd, initFunc)
	return dd
end

local function menuInit(frame, level, menuList)
	local function init(frame, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		info.func = function(self, arg1, arg2, checked)
			if arg1 == 1 then TTOMDB.anchor = "TOPLEFT"
			elseif arg1 == 2 then TTOMDB.anchor = "TOPRIGHT"
			elseif arg1 == 3 then TTOMDB.anchor = "BOTTOMLEFT"
			elseif arg1 == 4 then TTOMDB.anchor = "BOTTOMRIGHT"
			elseif arg1 == 5 then TTOMDB.anchor = "TOP"
			elseif arg1 == 6 then TTOMDB.anchor = "BOTTOM"
			elseif arg1 == 7 then TTOMDB.anchor = "LEFT"
			elseif arg1 == 8 then TTOMDB.anchor = "RIGHT"
			elseif arg1 == 9 then TTOMDB.anchor = "CENTER"
			end
			UIDropDownMenu_SetText(frame, TTOMDB.anchor)
		end
		info.text, info.checked, info.arg1 = "TOPLEFT", TTOMDB.anchor == "TOPLEFT", 1
		UIDropDownMenu_AddButton(info)
		info.text, info.checked, info.arg1 = "TOPRIGHT", TTOMDB.anchor == "TOPRIGHT", 2
		UIDropDownMenu_AddButton(info)
		info.text, info.checked, info.arg1 = "BOTTOMLEFT", TTOMDB.anchor == "BOTTOMLEFT", 3
		UIDropDownMenu_AddButton(info)
		info.text, info.checked, info.arg1 = "BOTTOMRIGHT", TTOMDB.anchor == "BOTTOMRIGHT", 4
		UIDropDownMenu_AddButton(info)
		info.text, info.checked, info.arg1 = "TOP", TTOMDB.anchor == "TOP", 5
		UIDropDownMenu_AddButton(info)
		info.text, info.checked, info.arg1 = "BOTTOM", TTOMDB.anchor == "BOTTOM", 6
		UIDropDownMenu_AddButton(info)
		info.text, info.checked, info.arg1 = "LEFT", TTOMDB.anchor == "LEFT", 7
		UIDropDownMenu_AddButton(info)
		info.text, info.checked, info.arg1 = "RIGHT", TTOMDB.anchor == "RIGHT", 8
		UIDropDownMenu_AddButton(info)
		info.text, info.checked, info.arg1 = "CENTER", TTOMDB.anchor == "CENTER", 9
		UIDropDownMenu_AddButton(info)
		UIDropDownMenu_SetText(frame, TTOMDB.anchor)
	end
	init(frame, level, menuList)
	EventRegistry:RegisterCallback("TTOM.OnReset", function()
		init(frame, level, menuList)
	end)
end

function TTOM:InitializeOptions()
	self.options = CreateFrame("Frame")
	self.options.name = TTOM.notes
	InterfaceOptions_AddCategory(self.options)

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

	local anchor = createDropDown(self.options, menuInit)
	anchor:SetPoint("TOPLEFT", yEdit, "BOTTOMLEFT", -20, -16)

	local anchorLabel = createFontString(self.options, "Anchor")
	anchorLabel:SetPoint("LEFT", anchor, "RIGHT", 0, 0)

	local reset = createButton(self.options, "Reset")
	reset:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 16, -16)
	reset:SetScript("OnClick", function()
		TTOMDB = CopyTable(TTOM.defaults)
		EventRegistry:TriggerEvent("TTOM.OnReset")
	end)
end
