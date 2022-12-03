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
	EventRegistry:RegisterCallback("TTOM.OnReset", function()
		eb:SetText(TTOMDB[key])
	end)
	return eb
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
			TTOMDB.anchor = self.text
			UIDropDownMenu_SetText(frame, TTOMDB.anchor)
		end
		info.text, info.checked = "TOPLEFT", TTOMDB.anchor == "TOPLEFT"
		UIDropDownMenu_AddButton(info)
		info.text, info.checked = "TOPRIGHT", TTOMDB.anchor == "TOPRIGHT"
		UIDropDownMenu_AddButton(info)
		info.text, info.checked = "BOTTOMLEFT", TTOMDB.anchor == "BOTTOMLEFT"
		UIDropDownMenu_AddButton(info)
		info.text, info.checked = "BOTTOMRIGHT", TTOMDB.anchor == "BOTTOMRIGHT"
		UIDropDownMenu_AddButton(info)
		info.text, info.checked = "TOP", TTOMDB.anchor == "TOP"
		UIDropDownMenu_AddButton(info)
		info.text, info.checked = "BOTTOM", TTOMDB.anchor == "BOTTOM"
		UIDropDownMenu_AddButton(info)
		info.text, info.checked = "LEFT", TTOMDB.anchor == "LEFT"
		UIDropDownMenu_AddButton(info)
		info.text, info.checked = "RIGHT", TTOMDB.anchor == "RIGHT"
		UIDropDownMenu_AddButton(info)
		info.text, info.checked = "CENTER", TTOMDB.anchor == "CENTER"
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

	local xEdit = createEditBox(self.options, TTOMDB.x, "x")
	xEdit:SetPoint("TOPLEFT", 16, -16)
	xEdit:HookScript("OnEnterPressed", function(self) xEdit:ClearFocus() end)
	xEdit:HookScript("OnEscapePressed", function(self) xEdit:ClearFocus() end)
	xEdit:HookScript("OnTextChanged", function(self, user)
		if user then
			local text = self:GetText()
			if tonumber(text) then
				TTOMDB.x = text
				xEdit:SetTextColor(1, 1, 1, 1)
			else
				xEdit:SetTextColor(1, 0.5, 0.5, 1)
			end
		end
	end)

	local xLabel = createFontString(self.options, "X Offset")
	xLabel:SetPoint("LEFT", xEdit, "RIGHT", 16, 0)

	local yEdit = createEditBox(self.options, TTOMDB.y, "y")
	yEdit:SetPoint("TOPLEFT", xEdit, "BOTTOMLEFT", 0, -16)
	yEdit:HookScript("OnEnterPressed", function(self) yEdit:ClearFocus() end)
	yEdit:HookScript("OnEscapePressed", function(self) yEdit:ClearFocus() end)
	yEdit:HookScript("OnTextChanged", function(self, user)
		if user then
			local text = self:GetText()
			if tonumber(text) then
				TTOMDB.y = text
				yEdit:SetTextColor(1, 1, 1, 1)
			else
				yEdit:SetTextColor(1, 0.5, 0.5, 1)
			end
		end
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
