local _, ns = ...

local GLUE = [=[Interface\Glues\CharacterCreate\CharacterCreate-LabelFrame]=]
local NORMAL = [=[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Up]=]
local PUSHED = [=[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Down]=]
local HIGHLIGHT = [=[Interface\Buttons\UI-Common-MouseHilight]=]

function ns.dropdown(parent, str, default, values, func)
	local container = CreateFrame('Button', nil, parent)
	container:SetSize(180, 30)

	local frame = CreateFrame('Frame', 'pMinimapDropDown'..str, parent, 'UIDropDownMenuTemplate')
	frame:SetPoint('TOPLEFT', container)
	frame:EnableMouse(true)

	UIDropDownMenu_SetWidth(frame, 130)
	UIDropDownMenu_Initialize(frame, function()
		local info = UIDropDownMenu_CreateInfo()
		info.notCheckable = true
		info.func = function(self)
			_G[frame:GetName()..'Text']:SetText(self.value)
			func(self)
		end

		for _, value in pairs(values) do
			info.text = value
			info.value = value
			UIDropDownMenu_AddButton(info)
		end
	end)

	local label = container:CreateFontString(nil, 'BACKGROUND', 'GameFontNormalSmall')
	label:SetPoint('BOTTOM', container, 'TOP')
	label:SetText(str)

	_G['pMinimapDropDown'..str..'Text']:SetText(default)

	return container
end

