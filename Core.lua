TTOM = CreateFrame("Frame")
TTOM.name = "TTOM"
TTOM.title = "ToolTip On Mouse"
TTOM.defaults = { x = "32", y = "-32", anchor = "TOPLEFT", combat = true }
TTOM.tooltips = {}

function TTOM:OnEvent(event, ...)
	self[event](self, event, ...)
end

TTOM:SetScript("OnEvent", TTOM.OnEvent)
TTOM:RegisterEvent("ADDON_LOADED")

function TTOM:ADDON_LOADED(event, name)
	if name == TTOM.name then
		TTOMDB = TTOMDB or {}
		for key, value in pairs(self.defaults) do
			if not TTOMDB[key] then
				TTOMDB[key] = value
			end
		end
		self:InitializeOptions()
		self:UnregisterEvent(event)
	end
end

local function updateTooltip(tooltip)
	if not tooltip.update then return end

	if not TTOMDB.combat and InCombatLockdown() then
		tooltip:ClearAllPoints()
		tooltip:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -CONTAINER_OFFSET_X, CONTAINER_OFFSET_Y)
		return
	end

	local scale = UIParent:GetEffectiveScale()
	local mX, mY = GetCursorPosition()
	mX, mY = mX / scale + TTOMDB.x, mY / scale + TTOMDB.y
	if TTOMDB.anchor == "TOPLEFT" then
		mY = mY - tooltip:GetHeight()
	elseif TTOMDB.anchor == "TOPRIGHT" then
		mX = mX - tooltip:GetWidth()
		mY = mY - tooltip:GetHeight()
	elseif TTOMDB.anchor == "BOTTOMRIGHT" then
		mX = mX - tooltip:GetWidth()
	elseif TTOMDB.anchor == "TOP" then
		mX = mX - tooltip:GetWidth() / 2
		mY = mY - tooltip:GetHeight()
	elseif TTOMDB.anchor == "BOTTOM" then
		mX = mX - tooltip:GetWidth() / 2
	elseif TTOMDB.anchor == "LEFT" then
		mY = mY - tooltip:GetHeight() / 2
	elseif TTOMDB.anchor == "RIGHT" then
		mX = mX - tooltip:GetWidth()
		mY = mY - tooltip:GetHeight() / 2
	elseif TTOMDB.anchor == "CENTER" then
		mX = mX - tooltip:GetWidth() / 2
		mY = mY - tooltip:GetHeight() / 2
	end
	tooltip:ClearAllPoints()
	tooltip:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", mX, mY)
end

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	if parent.unit then
		tooltip:SetOwner(parent, "ANCHOR_PRESERVE")
	else
		tooltip:SetOwner(parent, "ANCHOR_CURSOR")
	end
	updateTooltip(tooltip)
	tooltip.update = true
	if not TTOM.tooltips[tostring(tooltip)] then
		TTOM.tooltips[tostring(tooltip)] = true
		tooltip:HookScript("OnUpdate", updateTooltip)
		tooltip:HookScript("OnHide", function()
			tooltip.update = false
		end)
	end
end)

SLASH_TTOM1 = "/ttom"
SLASH_TTOM2 = "/tooltiponmouse"
SlashCmdList["TTOM"] = function(msg, editFrame, noOutput)
	Settings.OpenToCategory(TTOM.category:GetID())
end
