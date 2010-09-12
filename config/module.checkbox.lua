local _, ns = ...

local NORMAL = [=[Interface\Buttons\UI-CheckBox-Up]=]
local PUSHED = [=[Interface\Buttons\UI-CheckBox-Down]=]
local CHECKED = [=[Interface\Buttons\UI-CheckBox-Check]=]
local HIGHLIGHT = [=[Interface\Buttons\UI-CheckBox-Highlight]=]

function ns.checkbox(parent, str, ...)
	local button = CreateFrame('CheckButton', nil, parent)
	button:SetPoint(...)
	button:SetSize(26, 26)
	button:SetHitRectInsets(0, -100, 0, 0)

	button:SetNormalTexture(NORMAL)
	button:SetPushedTexture(PUSHED)
	button:SetCheckedTexture(CHECKED)
	button:SetHighlightTexture(HIGHLIGHT)

	local label = button:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	label:SetPoint('LEFT', button, 'RIGHT', 0, 1)
	label:SetText(str)

	return button
end
