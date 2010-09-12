local _, ns = ...

local SWATCH = [=[Interface\ChatFrame\ChatFrameColorSwatch]=]
local CHECKERS = [=[Tileset\Generic\Checkers]=]

local function OnClick(self)
	HideUIPanel(ColorPickerFrame)

	local origR, origG, origB, origA = unpack(pMinimapDB.minimap.borderColors)
	ColorPickerFrame:SetFrameStrata('FULLSCREEN_DIALOG')
	ColorPickerFrame.func = function()
		local r, g, b = ColorPickerFrame:GetColorRGB()
		local a = 1 - OpacitySliderFrame:GetValue()
		self.swatch:SetVertexColor(r, g, b, a)
		pMinimapDB.minimap.borderColors = {r, g, b, a}
		ns.UpdateCore()
	end

	ColorPickerFrame.hasOpacity = true
	ColorPickerFrame.opacityFunc = function()
		local r, g, b = ColorPickerFrame:GetColorRGB()
		local a = 1 - OpacitySliderFrame:GetValue()
		self.swatch:SetVertexColor(r, g, b, a)
		pMinimapDB.minimap.borderColors = {r, g, b, a}
		ns.UpdateCore()
	end

	ColorPickerFrame.cancelFunc = function()
		self.swatch:SetVertexColor(origR, origG, origB, origA)
		pMinimapDB.minimap.borderColors = {origR, origG, origB, origA}
		ns.UpdateCore()
	end

	ColorPickerFrame.opacity = 1 - origA
	ColorPickerFrame:SetColorRGB(origR, origG, origB)
	ShowUIPanel(ColorPickerFrame)
end

function ns.palette(parent, str, default, ...)
	local container = CreateFrame('Button', nil, parent)
	container:SetPoint(...)
	container:SetSize(22, 22)
	container:SetHitRectInsets(0, -100, 0, 0)
	container:SetScript('OnClick', OnClick)
	container:EnableMouse(true)

	local swatch = container:CreateTexture(nil, 'OVERLAY')
	swatch:SetAllPoints()
	swatch:SetTexture(SWATCH)
	swatch:SetVertexColor(unpack(default))
	container.swatch = swatch

	local background = container:CreateTexture(nil, 'BACKGROUND')
	background:SetPoint('CENTER')
	background:SetSize(18, 18)
	background:SetTexture(1, 1, 1)

	local checkers = container:CreateTexture(nil, 'BACKGROUND')
	checkers:SetPoint('CENTER')
	checkers:SetSize(17, 17)
	checkers:SetTexture(CHECKERS)
	checkers:SetTexCoord(0.25, 0, 0.5, 0.25)
	checkers:SetDesaturated(true)
	checkers:SetVertexColor(1, 1, 1, 0.75)

	local label = container:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
	label:SetPoint('LEFT', swatch, 'RIGHT', 2, 0)
	label:SetHeight(24)
	label:SetJustifyH('LEFT')
	label:SetText(str)

	return container
end
