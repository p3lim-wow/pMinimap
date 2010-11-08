local LibConfig = LibStub:NewLibrary('LibConfig-1.0', 40000.1)

local panels, lib, args = {}, {}, {}
LibConfig.panels = panels
LibConfig.lib = lib

local function getArgs(...)
	wipe(args)
	for index = 1, select('#', ...), 2 do
		local k, v = select(index, ...)
		args[k] = v
	end

	return args
end

do
	-- XXX: fix/control
	local function _okay(self)
		for control in pairs(self.controls) do
			control.oldValue = control.value
			if(control.okayFunc) then
				control.okayFunc()
			end
		end
	end

	-- XXX: fix/control
	local function _cancel(self)
		for control in pairs(self.controls) do
			control.value = control.oldValue
			control.setValue(control)
			if(control.cancelFunc) then
				control.cancelFunc()
			end
		end
	end

	-- XXX: fix/control
	local function _default(self)
		for control in pairs(self.controls) do
			control.value = control.default
			control.setValue(control)
			if(control.defaultFunc) then
				control.defaultFunc()
			end
		end
	end

	function LibConfig.AddConfig(name, parent, func, globalName)
		if(parent) then
			globalName = parent .. 'Config' .. name
		else
			globalName = name .. 'Configa'
		end

		local group = CreateFrame('Frame', globalName, InterfaceOptionsFramePanelContainer)
		group.name = name
		group.parent = parent
		group.addonname = parent

		group.controls = {}
		group.okay = _okay
		group.cancel = _cancel
		group.default = _default

		group:SetScript('OnShow', func)
		group:HookScript('OnShow', function(self)
			self:SetScript('OnShow', nil)
		end)

		InterfaceOptions_AddCategory(group)

		panels[group] = true
		for type, func in pairs(lib) do
			group[type] = func
		end

		return group
	end

	function LibConfig.AddCommand(name, ...)
		for index = 1, select('#', ...) do
			_G['SLASH_'.. name .. index] = select(index, ...)
		end
		
		SlashCmdList[name] = function()
			InterfaceOptionsFrame_OpenToCategory(name)
		end
	end
end

do
	local function _onClick(self)
		self.setFunc(self.value)
		self:SetChecked(self.value)
	end

	local function _onClickWrapper(self)
		self.value = not self.value
		_onClick(self)
	end

	function lib:CreateCheckBox(...)
		local args = getArgs(...)
		local i, globalName = 0
		repeat
			i = i + 1
			globalName = self:GetName() .. 'CheckButton' .. i
		until not _G[globalName]

		local object = CreateFrame('CheckButton', globalName, self, 'InterfaceOptionsCheckButtonTemplate')
		local text = _G[globalName .. 'Text']
		text:SetText(args.name)
		object:SetHitRectInsets(0, - text:GetWidth() - 1, 0, 0)
		object:SetScript('OnClick', _onClickWrapper)

		object.default = args.default
		object.value = args.getFunc()
		object.oldValue = object.value or object.default

		object.getFunc = args.getFunc
		object.setFunc = args.setFunc
		object.okayFunc = args.okayFunc
		object.cancelFunc = args.cancelFunc
		object.defaultFunc = args.defaultFunc

		object:SetChecked(args.getFunc())
		object.setValue = _onClick
		self.controls[object] = true
		return object
	end
end

do
	local function dummy() end

	local function _onClick(self)
		self.setFunc()
	end

	function lib:CreateButton(...)
		local args = getArgs(...)
		local i, globalName = 0
		repeat
			i = i + 1
			globalName = self:GetName() .. 'Button' .. i
		until not _G[globalName]

		local object = CreateFrame('Button', globalName, self, 'UIPanelButtonTemplate2')
		object:SetSize(90, 22)
		object:SetScript('OnClick', _onClick)
		object:SetText(args.name)

		object.setFunc = args.setFunc
		object.getFunc = dummy

		object.setValue = dummy
		self.controls[object] = true
		return object
	end
end

do
	local function _value(self)
		UIDropDownMenu_SetSelectedValue(self, self.value)
		self.setFunc(self.value)
	end

	local function _valueWrapper(button, self, value)
		self.value = value
		_value(self)
	end

	local function _menu(self)
		for value, text in pairs(self.values) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = text
			info.value = value
			info.checked = self.value == value
			info.func = _valueWrapper
			info.arg1 = self
			info.arg2 = value
			UIDropDownMenu_AddButton(info)
		end
	end

	function lib:CreateDropDown(...)
		local args = getArgs(...)
		local i, globalName = 0
		repeat
			i = i + 1
			globalName = self:GetName() .. 'DropDown' .. i
		until not _G[globalName]

		local object = CreateFrame('Frame', globalName, self, 'UIDropDownMenuTemplate')
		object:EnableMouse(true)

		local label = object:CreateFontString(nil, 'BACKGROUND', 'GameFontNormal')
		label:SetPoint('BOTTOMLEFT', object, 'TOPLEFT', 16, 3)
		label:SetText(args.name)

		object.values = args.values
		object.default = args.default
		object.value = args.getFunc()
		object.oldValue = object.value or object.default

		object.getFunc = args.getFunc
		object.setFunc = args.setFunc
		object.okayFunc = args.okayFunc
		object.cancelFunc = args.cancelFunc
		object.defaultFunc = args.defaultFunc

		UIDropDownMenu_SetWidth(object, args.width or 130)
		UIDropDownMenu_Initialize(object, _menu)
		UIDropDownMenu_SetSelectedValue(object, args.getFunc())

		object.setValue = _value
		self.controls[object] = true
		return object
	end
end

do
	local _backdrop = {
		bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		tile = true, edgeSize = 1, tileSize = 5,
	}

	local function _value(self)
		self.setFunc(self.value)
		_G[self:GetName() .. 'EditBox']:SetText(self.currentTextFunc(self.value))
	end

	local function _onValueChanged(self)
		self.value = self:GetValue()
		_value(self)
	end

	local function _onEnterPressed(self)
		local object = self:GetParent()
		local value = tonumber(self:GetText())
		local min, max = object:GetMinMaxValues()

		if(value and (value <= max and value >= min)) then
			object.value = value
		end

		_value(object)
	end

	local function _onEnter(self)
		self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
	end

	local function _onLeave(self)
		self:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
	end

	function lib:CreateSlider(...)
		local args = getArgs(...)
		local i, globalName = 0
		repeat
			i = i + 1
			globalName = self:GetName() .. 'Slider' .. i
		until not _G[globalName]

		local object = CreateFrame('Slider', globalName, self, 'OptionsSliderTemplate')
		object.currentTextFunc = args.currentTextFunc
		object.default = args.default
		object.value = args.getFunc()
		object.oldValue = object.value or object.default

		object.getFunc = args.getFunc
		object.setFunc = args.setFunc
		object.okayFunc = args.okayFunc
		object.cancelFunc = args.cancelFunc
		object.defaultFunc = args.defaultFunc

		object:SetScript('OnValueChanged', _onValueChanged)
		object:SetMinMaxValues(args.minValue, args.maxValue)
		object:SetValueStep(args.step)

		_G[globalName .. 'Text']:SetText(args.name)
		_G[globalName .. 'High']:SetText(tostring(args.maxValue))
		_G[globalName .. 'Low']:SetText(tostring(args.minValue))

		local editbox = CreateFrame('EditBox', globalName .. 'EditBox', object)
		editbox:SetPoint('TOP', object, 'BOTTOM')
		editbox:SetSize(40, 14)
		editbox:SetAutoFocus(false)
		editbox:SetFontObject(GameFontHighlightSmall)
		editbox:SetBackdrop(_backdrop)
		editbox:SetBackdropColor(0, 0, 0, 0.5)
		editbox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
		editbox:EnableMouse(true)
		editbox:SetScript('OnEnter', _onEnter)
		editbox:SetScript('OnLeave', _onLeave)
		editbox:SetScript('OnEnterPressed', _onEnterPressed)
		editbox:SetScript('OnEscapePressed', editbox.ClearFocus)
		editbox:SetJustifyH('CENTER')
		editbox:SetText(args.currentTextFunc(args.getFunc()))

		object:SetValue(args.getFunc())
		object.setValue = _value
		self.controls[object] = true
		return object
	end
end

do
	local function _value(self)
		local r, g, b, a = unpack(self.value)
		if(not self.hasAlpha) then
			a = 1
		else
			self.info.opacity = a
		end

		self.info.r, self.info.g, self.info.b = r, g, b

		self.color:SetTexture(r, g, b, a)
		self.value = {r, g, b, a}
		self.setFunc(r, g, b, a)
	end

	local function _onClick(self)
		OpenColorPicker(self.info)
	end

	local function _swatchFunc(self)
		local r, g, b = ColorPickerFrame:GetColorRGB()
		local a = 1 - OpacitySliderFrame:GetValue()

		self.value = {r, g, b, a}
		_value(self)
	end

	local function _cancelFunc(self)
		local prev = ColorPickerFrame.previousValues
		local r, g, b, a = prev.r, prev.g, prev.b, 1 - prev.opacity

		self.value = {r, g, b, a}
		_value(self)
	end

	function lib:CreatePalette(...)
		local args = getArgs(...)
		local i, globalName = 0
		repeat
			i = i + 1
			globalName = self:GetName() .. 'Palette' .. i
		until not _G[globalName]

		local object = CreateFrame('Button', globalName, self)
		object:SetScript('OnClick', _onClick)
		object:RegisterForClicks('LeftButtonUp')
		object:SetSize(26, 26)

		local label = object:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
		label:SetPoint('LEFT', object, 'RIGHT', 0, 1)
		label:SetText(args.name)
		object:SetHitRectInsets(0, - label:GetWidth() - 1, 0, 0)

		local currentR, currentG, currentB, currentA = args.getFunc()
		object.hasAlpha = args.hasAlpha
		object.default = {unpack(args.default)}
		object.value = {currentR, currentG, currentB, defaultA}
		object.oldValue = object.value or object.default

		object.getFunc = args.getFunc
		object.setFunc = args.setFunc
		object.okayFunc = args.okayFunc
		object.cancelFunc = args.cancelFunc
		object.defaultFunc = args.defaultFunc

		local color = object:CreateTexture(nil, 'ARTWORK')
		color:SetPoint('CENTER')
		color:SetSize(14, 14)
		color:SetTexture(currentR, currentG, currentB, currentA)

		local background = object:CreateTexture(nil, 'BORDER')
		background:SetPoint('CENTER')
		background:SetSize(14, 14)
		background:SetTexture([=[Tileset\Generic\Checkers]=])
		background:SetTexCoord(0, 0.5, 0, 0.5)

		local border = object:CreateTexture(nil, 'BACKGROUND')
		border:SetAllPoints()
		border:SetTexture([=[Interface\ChatFrame\ChatFrameColorSwatch]=])

		local function swatchFunc_wrapper()
			_swatchFunc(object)
		end

		local function cancelFunc_wrapper()
			_cancelFunc(object)
		end

		object.color = color
		object.info = {
			swatchFunc = swatchFunc_wrapper,
			cancelFunc = cancelFunc_wrapper,
			hasOpacity = args.hasAlpha,
			r = currentR,
			g = currentG,
			b = currentB,
		}

		if(not args.hasAlpha) then
			args.defaultA = 1
			args.currentA = 1
		else
			object.info.opacityFunc = swatchFunc_wrapper
			object.info.opacity = 1 - currentA
		end

		object.setValue = _value
		self.controls[object] = true
		return object
	end
end

-- XXX: fix/control
function lib:Refresh()
	for control in pairs(self.controls) do
		control.value = control.getFunc()
		control.setValue(control)
	end
end

for name, func in pairs(lib) do
	LibConfig[name] = func

--	for panel in pairs(panels) do
--		panel[name] = func
--	end
end
