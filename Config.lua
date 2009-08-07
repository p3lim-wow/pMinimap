local SharedMedia = LibStub('LibSharedMedia-3.0')

local group, slider, dropdown, checkbox = LibStub('tekKonfig-Group'), LibStub('tekKonfig-Slider'), LibStub('tekKonfig-Dropdown'), LibStub('tekKonfig-Checkbox')

local function updateStrings()
	MiniMapMailText:SetFont(SharedMedia:Fetch('font', pMinimap.db.font), pMinimap.db.fontsize, pMinimap.db.fontflag)
	MinimapZoneText:SetFont(SharedMedia:Fetch('font', pMinimap.db.font), pMinimap.db.fontsize, pMinimap.db.fontflag)
	MinimapCoordinatesText:SetFont(SharedMedia:Fetch('font', pMinimap.db.font), pMinimap.db.fontsize, pMinimap.db.fontflag)
end

local function dropStrata(orig)
	local info = UIDropDownMenu_CreateInfo()
	info.func = function(self)
		pMinimap.db.strata = self.value
		Minimap:SetFrameStrata(self.value)
		orig.text:SetText(self.value)
	end

	for k, v in next, {'DIALOG', 'HIGH', 'MEDIUM', 'LOW', 'BACKGROUND'} do
		info.text = v
		info.value = v
		UIDropDownMenu_AddButton(info)
	end
end

local function dropZone(orig)
	local info = UIDropDownMenu_CreateInfo()
	info.func = function(self)
		pMinimap.db.zonepoint = self.value
		MinimapZoneTextButton:ClearAllPoints()
		MinimapZoneTextButton:SetPoint(self.value == 'TOP' and 'BOTTOM' or 'TOP', Minimap, self.value, 0, pMinimap.db.zoneoffset)
		orig.text:SetText(self.value)
	end

	for k, v in next, {'TOP', 'BOTTOM'} do
		info.text = v
		info.value = v
		UIDropDownMenu_AddButton(info)
	end
end

local function dropFont(orig)
	local info = UIDropDownMenu_CreateInfo()
	info.func = function(self)
		pMinimap.db.font = self.value
		orig.text:SetText(self.value)
		updateStrings()
	end

	for k, v in next, SharedMedia:List('font') do
		info.text = v
		info.value = v
		UIDropDownMenu_AddButton(info)
	end
end

local function dropFontflag(orig)
	local info = UIDropDownMenu_CreateInfo()
	info.func = function(self)
		pMinimap.db.fontflag = self.value
		updateStrings()
		orig.text:SetText(self.value)
	end

	for k, v in next, {OUTLINE = 'Normal Outline', THICKOUTLINE = 'Thick Outline', MONOCHROME = 'Monochrome', NONE = 'None'} do
		info.text = v
		info.value = k
		UIDropDownMenu_AddButton(info)
	end
end

local addon = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
addon.name = 'pMinimap'
addon:Hide()
addon:SetScript('OnShow', function(self)
	local title, subtitle = LibStub('tekKonfig-Heading').new(self, self.name, 'Here you will be able to change various settings')

	local group1 = group.new(self, 'Minimap', 'TOPLEFT', subtitle, 'BOTTOMLEFT')
	group1:SetHeight(120)
	group1:SetWidth(370)

	local scale = slider.new(self, 'Scale', 0.5, 2.5, 'TOPLEFT', group1, 15, -15)
	scale:SetValueStep(0.01)
	scale:SetValue(pMinimap.db.scale)
	scale:SetScript('OnValueChanged', function(self, value)
		pMinimap.db.scale = value
		Minimap:SetScale(value)
	end)

	local level = slider.new(self, 'Framelevel', 1, 15, 'TOPLEFT', scale, 'BOTTOMLEFT', 0, -20)
	level:SetValue(pMinimap.db.level)
	level:SetScript('OnValueChanged', function(self, value)
		pMinimap.db.level = value
		pMinimap:SetFrameLevel(value)
	end)

	local strata, stratatext = dropdown.new(self, 'Framestrata', 'LEFT', scale, 'RIGHT', 40, 0)
	strata.text = stratatext
	strata.text:SetText(pMinimap.db.strata)
	UIDropDownMenu_Initialize(strata, dropStrata)

	local group2 = group.new(self, 'Modules', 'TOPLEFT', group1, 'BOTTOMLEFT', 0, -20)
	group2:SetHeight(105)
	group2:SetWidth(370)

	local coordinates = checkbox.new(self, 22, 'Coordinates', 'TOPLEFT', group2, 10, -10)
	coordinates:SetChecked(pMinimap.db.coordinates)
	coordinates:SetScript('OnClick', function()
		pMinimap.db.coordinates = not pMinimap.db.coordinates

		if(pMinimap.db.coordinates) then
			MinimapCoordinates:Show()
			MinimapCoordinates:ClearAllPoints()
			MinimapCoordinates:SetPoint(pMinimap.db.clock and 'BOTTOMRIGHT' or 'BOTTOM')
		else
			MinimapCoordinates:Hide()
		end
	end)

	local coordinatesdecimals = slider.new(self, 'Coordinates Decimals', 0, 3, 'TOPRIGHT', group2, -15, -15)
	coordinatesdecimals:SetValue(pMinimap.db.coordinatesdecimals)
	coordinatesdecimals:SetScript('OnValueChanged', function(self, value)
		pMinimap.db.coordinatesdecimals = value
	end)

	local clock = checkbox.new(self, 22, 'Clock (Disabled)', 'TOPLEFT', coordinates, 'BOTTOMLEFT', 0, -10)
	clock:SetChecked(pMinimap.db.clock)
	clock:Disable()

	local mail = checkbox.new(self, 22, 'Mail', 'TOPLEFT', clock, 'BOTTOMLEFT', 0, -10)
	mail:SetChecked(pMinimap.db.mail)
	mail:SetScript('OnClick', function()
		pMinimap.db.mail = not pMinimap.db.mail

		if(pMinimap.db.mail) then
			MiniMapMailIcon:Hide()
			MiniMapMailText:Show()
		else
			MiniMapMailIcon:Show()
			MiniMapMailText:Hide()
		end
	end)

	local durability = checkbox.new(self, 22, 'Durability', 'LEFT', mail, 'RIGHT', 80, 0)
	durability:SetChecked(pMinimap.db.durability)
	durability:SetScript('OnClick', function()
		pMinimap.db.durability = not pMinimap.db.durability

		if(pMinimap.db.durability) then
			DurabilityFrame:SetAlpha(0)
			pMinimap:RegisterEvent('UPDATE_INVENTORY_ALERTS')
			pMinimap:UPDATE_INVENTORY_ALERTS()
		else
			DurabilityFrame:SetAlpha(1)
			pMinimap:UnregisterEvent('UPDATE_INVENTORY_ALERTS')
			Minimap:SetBackdropColor(unpack(pMinimap.db.bordercolors))
		end
	end)

	local group3 = group.new(self, 'Background', 'TOPLEFT', group2, 'BOTTOMLEFT', 0, -20)
	group3:SetHeight(60)
	group3:SetWidth(370)

	local borderoffset = slider.new(self, 'Thickness', 0, 10, 'TOPLEFT', group3, 15, -15)
	borderoffset:SetValueStep(1/2)
	borderoffset:SetValue(pMinimap.db.borderoffset)
	borderoffset:SetScript('OnValueChanged', function(self, value)
		pMinimap.db.borderoffset = value
		Minimap:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -value, bottom = -value, left = -value, right = -value}})
		Minimap:SetBackdropColor(unpack(pMinimap.db.bordercolors))
	end)

	local group4 = group.new(self, 'Zone', 'TOPLEFT', group3, 'BOTTOMLEFT', 0, -20)
	group4:SetHeight(95)
	group4:SetWidth(370)

	local zone = checkbox.new(self, 22, 'Zone Toggle', 'TOPLEFT', group4, 10, -10)
	zone:SetChecked(pMinimap.db.zone)
	zone:SetScript('OnClick', function()
		pMinimap.db.zone = not pMinimap.db.zone

		if(pMinimap.db.zone) then
			MinimapZoneTextButton:Show()
		else
			MinimapZoneTextButton:Hide()
		end
	end)

	local zonepoint, zonepointtext = dropdown.new(self, 'Zone Point', 'TOPLEFT', zone, 'BOTTOMLEFT')
	zonepoint.text = zonepointtext
	zonepoint.text:SetText(pMinimap.db.zonepoint)
	UIDropDownMenu_Initialize(zonepoint, dropZone)

	local zoneoffset = slider.new(self, 'Zone Offset', -25, 25, 'TOPRIGHT', group4, -15, -15)
	zoneoffset:SetValueStep(1/2)
	zoneoffset:SetValue(pMinimap.db.zoneoffset)
	zoneoffset:SetScript('OnValueChanged', function(self, value)
		pMinimap.db.zoneoffset = value
		MinimapZoneTextButton:ClearAllPoints()
		MinimapZoneTextButton:SetPoints(pMinimap.db.zonepoint == 'TOP' and 'BOTTOM' or 'TOP', Minimap, pMinimap.db.zonepoint, 0, value)
	end)

	local group5 = group.new(self, 'Fonts', 'TOPLEFT', group4, 'BOTTOMLEFT', 0, -20)
	group5:SetHeight(110)
	group5:SetWidth(370)

	local font, fonttext = dropdown.new(self, 'Font', 'TOPLEFT', group5, 10, -4)
	font.text = fonttext
	font.text:SetText(pMinimap.db.font)
	UIDropDownMenu_Initialize(font, dropFont)

	local fontflag, fontflagtext = dropdown.new(self, 'Font Flag', 'BOTTOMLEFT', group5, 10, 4)
	fontflag.text = fontflagtext
	fontflag.text:SetText(pMinimap.db.fontflag)
	UIDropDownMenu_Initialize(fontflag, dropFontflag)

	local fontsize = slider.new(self, 'Font Size', 5, 18, 'TOPRIGHT', group5, -15, -15)
	fontsize:SetValue(pMinimap.db.fontsize)
	fontsize:SetScript('OnValueChanged', function(self, value)
		pMinimap.db.fontsize = value
		updateStrings()
	end)

	self:SetScript('OnShow', nil)
end)

InterfaceOptions_AddCategory(addon)
