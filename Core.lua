TTOM = CreateFrame("Frame")
TTOM.name = "TTOM"
TTOM.notes = "ToolTip On Mouse"
TTOM.tooltips = {}

function TTOM:OnEvent(event, ...)
	self[event](self, event, ...)
end
TTOM:SetScript("OnEvent", TTOM.OnEvent)
TTOM:RegisterEvent("ADDON_LOADED")

function TTOM:ADDON_LOADED(event, name)
	if name == TTOM.name then
		TTOMDB = TTOMDB or {}
		self.db = TTOMDB
		for k, v in pairs(self.defaults) do
			if self.db[k] == nil then
				self.db[k] = v
			end
		end
		self:InitializeOptions()
		self:UnregisterEvent(event)
	end
end

local function updateTooltip(tooltip)
	local mX, mY, oX, oY = 0, 0, 0, 0
	local point = "BOTTOMLEFT"
	oX, oY = TTOMDB.x, TTOMDB.y
	local scale = UIParent:GetEffectiveScale()
	mX, mY = GetCursorPosition()
	mX, mY = mX / scale, mY / scale
	local anchor = string.upper(TTOMDB.anchor)
	if anchor == "TOPLEFT" then
		mY = mY - tooltip:GetHeight()
	elseif anchor == "TOPRIGHT" then
		mX = mX - tooltip:GetWidth()
		mY = mY - tooltip:GetHeight()
	elseif anchor == "BOTTOMRIGHT" then
		mX = mX - tooltip:GetWidth()
	elseif anchor == "TOP" then
		mX = mX - tooltip:GetWidth() / 2
		mY = mY - tooltip:GetHeight()
	elseif anchor == "BOTTOM" then
		mX = mX - tooltip:GetWidth() / 2
	elseif anchor == "LEFT" then
		mY = mY - tooltip:GetHeight() / 2
	elseif anchor == "RIGHT" then
		mX = mX - tooltip:GetWidth()
		mY = mY - tooltip:GetHeight() / 2
	elseif anchor == "CENTER" then
		mX = mX - tooltip:GetWidth() / 2
		mY = mY - tooltip:GetHeight() / 2
	end
	tooltip:ClearAllPoints()
	tooltip:SetPoint(point, "UIParent", point, oX + mX, oY + mY)
end

function GameTooltip_SetDefaultAnchor(tooltip, parent, ...)
	if not parent then
		parent = GetMouseFocus()
	end
	if not parent or (parent.GetName and parent:GetName() == "WorldFrame") then
		parent = UIParent
	end
	if parent.unit then
		tooltip:SetOwner(parent, "ANCHOR_PRESERVE")
	else
		tooltip:SetOwner(parent, "ANCHOR_CURSOR")
	end
	updateTooltip(tooltip)
	if not TTOM.tooltips[tostring(tooltip)] then
		TTOM.tooltips[tostring(tooltip)] = true
		tooltip:HookScript("OnUpdate", updateTooltip)
	end
end

SLASH_TTOM1 = "/ttom"
SLASH_TTOM2 = "/tooltiponmouse"
SlashCmdList["TTOM"] = function(msg, editFrame, noOutput)
	InterfaceOptionsFrame_OpenToCategory(TTOM.notes)
end
