TTOM.defaults = {
	x = "32",
	y = "-32",
	anchor = "TOPLEFT"
}

local function createFontString(parent, text, size, style)
	local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fs:SetText(text)
	return fs
end

local function createEditBox(parent, key, text)
	local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	eb:SetSize(100, 20)
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

local function createDropDown(parent, init)
	local dd = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
	UIDropDownMenu_SetWidth(dd, 120)
	UIDropDownMenu_Initialize(dd, init)
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
	end
	init(frame, level, menuList)
	EventRegistry:RegisterCallback("TTOM.OnReset", function()
		init(frame, level, menuList)
		UIDropDownMenu_SetText(frame, TTOMDB.anchor)
	end)
end

function TTOM:InitializeOptions()
	self.options = CreateFrame("Frame")
	self.options.name = TTOM.notes
	InterfaceOptions_AddCategory(self.options)

	local xEdit = createEditBox(self.options, "x", TTOMDB.x)
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
				xEdit:SetTextColor(1, .5, .5, 1)
			end
		end
	end)

	local xLabel = createFontString(self.options, "X Offset", 16)
	xLabel:SetPoint("LEFT", xEdit, "RIGHT", 16, 0)

	local yEdit = createEditBox(self.options, "y", TTOMDB.y)
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
				yEdit:SetTextColor(1, .5, .5, 1)
			end
		end
	end)

	local yLabel = createFontString(self.options, "Y Offset", 16)
	yLabel:SetPoint("LEFT", yEdit, "RIGHT", 16, 0)

	local anchor = createDropDown(self.options, menuInit)
	anchor:SetPoint("TOPLEFT", yEdit, "BOTTOMLEFT", -20, -16)
	UIDropDownMenu_SetText(anchor, TTOMDB.anchor)

	local anchorLabel = createFontString(self.options, "Anchor", 16)
	anchorLabel:SetPoint("LEFT", anchor, "RIGHT", 0, 0)

	local reset = createButton(self.options, "Reset")
	reset:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 16, -16)
	reset:SetScript("OnClick", function()
		TTOMDB = CopyTable(TTOM.defaults)
		EventRegistry:TriggerEvent("TTOM.OnReset")
	end)
end
