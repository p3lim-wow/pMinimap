local _, ns = ...

local THUMB = [=[Interface\Buttons\UI-SliderBar-Button-Horizontal]=]
local SLIDER = {
	bgFile = [=[Interface\Buttons\UI-SliderBar-Background]=],
	edgeFile = [=[Interface\Buttons\UI-SliderBar-Border]=],
	edgeSize = 8, tile = true, tileSize = 8,
	insets = {left = 3, right = 3, top = 6, bottom = 6},
}

local EDITBOX = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	tile = true, edgeSize = 1, tileSize = 5,
}

local function OnEnterPressed(self)
	local value = tonumber(self:GetText())
	if(value) then
		PlaySound('igMainMenuOptionCheckBoxOn')
		self:GetParent():SetValue(value)
	end
end

local function OnEnter(self)
	self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
end

local function OnLeave(self)
	self:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
end

function ns.slider(parent, str, formatting, cur, min, max, step, ...)
	local slider = CreateFrame('Slider', nil, parent)
	slider:SetPoint(...)
	slider:SetSize(144, 16)
	slider:SetBackdrop(SLIDER)
	slider:SetThumbTexture(THUMB)
	slider:SetOrientation('HORIZONTAL')
	slider:SetMinMaxValues(min, max)
	slider:SetValueStep(step)
	slider:SetValue(cur)

	local left = slider:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	left:SetPoint('TOPLEFT', slider, 'BOTTOMLEFT', -4, 3)
	left:SetText(min)

	local right = slider:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	right:SetPoint('TOPRIGHT', slider, 'BOTTOMRIGHT', 4, 3)
	right:SetText(max)

	local label = slider:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	label:SetPoint('BOTTOM', slider, 'TOP')
	label:SetText(str)

	local editbox = CreateFrame('EditBox', nil, slider)
	editbox:SetPoint('TOP', slider, 'BOTTOM')
	editbox:SetSize(40, 14)
	editbox:SetAutoFocus(false)
	editbox:SetFontObject(GameFontHighlightSmall)
	editbox:SetBackdrop(EDITBOX)
	editbox:SetBackdropColor(0, 0, 0, 0.5)
	editbox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
	editbox:EnableMouse(true)
	editbox:SetScript('OnEnter', OnEnter)
	editbox:SetScript('OnLeave', OnLeave)
	editbox:SetScript('OnEnterPressed', OnEnterPressed)
	editbox:SetScript('OnEscapePressed', editbox.ClearFocus)
	editbox:SetJustifyH('CENTER')
	editbox:SetText(string.format(formatting, cur))
	
	slider:SetScript('OnValueChanged', function(self, value)
		editbox:SetText(string.format(formatting, value))
	end)

	return slider
end
