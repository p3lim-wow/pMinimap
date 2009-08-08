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

	for k, v in next, {'OUTLINE', 'THICKOUTLINE', 'MONOCHROME', 'NONE'} do
		info.text = v
		info.value = v
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

	local scale, scaletext = slider.new(self, format('Scale: %.2f', pMinimap.db.scale), 0.5, 2.5, 'TOPLEFT', group1, 15, -15)
	scale:SetValueStep(0.01)
	scale:SetValue(pMinimap.db.scale)
	scale:SetScript('OnValueChanged', function(self, value)
		pMinimap.db.scale = value
		scaletext:SetFormattedText('Scale: %.2f', value)
		Minimap:SetScale(value)
	end)

	local level, leveltext = slider.new(self, 'Framelevel: '..pMinimap.db.level, 1, 15, 'TOPLEFT', scale, 'BOTTOMLEFT', 0, -30)
	level:SetValueStep(1)
	level:SetValue(pMinimap.db.level)
	level:SetScript('OnValueChanged', function(self, value)
		pMinimap.db.level = value
		leveltext:SetFormattedText('Framelevel: %d', value)
		pMinimap:SetFrameLevel(value)
	end)

	local strata, stratatext = dropdown.new(self, 'Framestrata', 'LEFT', scale, 'RIGHT', 40, 0)
	strata.text = stratatext
	strata.text:SetText(pMinimap.db.strata)
	UIDropDownMenu_Initialize(strata, dropStrata)

	local lock = checkbox.new(self, 22, 'Locked', 'LEFT', level, 'RIGHT', 45, 0)
	lock:SetChecked(not pMinimap.unlocked)
	lock:SetScript('OnClick', function()
		pMinimap.unlocked = not pMinimap.unlocked

		if(pMinimap.unlocked) then
			Minimap:SetBackdropColor(0, 1, 0, 0.5)
		else
			Minimap:SetBackdropColor(unpack(pMinimap.db.bordercolors))
		end
	end)

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

		if(pMinimap.db.clock) then
			TimeManagerClockButton:ClearAllPoints()
			TimeManagerClockButton:SetPoint(pMinimap.db.coordinates and 'BOTTOMLEFT' or 'BOTTOM', Minimap)
		end
	end)

	local coordinatesdecimals, cdtext = slider.new(self, 'Coord Decimals: '..pMinimap.db.coordinatesdecimals, 0, 3, 'TOPRIGHT', group2, -15, -15)
	coordinatesdecimals:SetValueStep(1)
	coordinatesdecimals:SetValue(pMinimap.db.coordinatesdecimals)
	coordinatesdecimals:SetScript('OnValueChanged', function(self, value)
		pMinimap.db.coordinatesdecimals = value
		cdtext:SetFormattedText('Coord Decimals: %d', value)
	end)

	local clock = checkbox.new(self, 22, 'Clock', 'TOPLEFT', coordinates, 'BOTTOMLEFT', 0, -10)
	clock:SetChecked(pMinimap.db.clock)
	clock:SetScript('OnClick', function()
		pMinimap.db.clock = not pMinimap.db.clock

		if(pMinimap.db.clock) then
			if(not pMinimap:IsEventRegistered('CALENDAR_UPDATE_PENDING_INVITES')) then
				pMinimap:Clock()
			else
				TimeManagerClockButton:ClearAllPoints()
				TimeManagerClockButton:SetPoint(pMinimap.db.coordinates and 'BOTTOMLEFT' or 'BOTTOM', Minimap)
				TimeManagerClockButton:Show()
			end
		else
			TimeManagerClockButton:Hide()
		end

		if(pMinimap.db.coordinates) then
			MinimapCoordinates:ClearAllPoints()
			MinimapCoordinates:SetPoint(pMinimap.db.clock and 'BOTTOMRIGHT' or 'BOTTOM')
		end
	end)

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

	local durability = checkbox.new(self, 22, 'Durability', 'LEFT', mail, 'RIGHT', 110, 0)
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

	local borderoffset, borderoffsettext = slider.new(self, 'Thickness: '..pMinimap.db.borderoffset, 0, 10, 'TOPLEFT', group3, 15, -15)
	borderoffset:SetValueStep(1/2)
	borderoffset:SetValue(pMinimap.db.borderoffset)
	borderoffset:SetScript('OnValueChanged', function(self, value)
		pMinimap.db.borderoffset = value
		borderoffsettext:SetFormattedText('Thickness: %.1f', value)
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

	local zoneoffset, zoneoffsettext = slider.new(self, 'Zone Offset: '..pMinimap.db.zoneoffset, -25, 25, 'TOPRIGHT', group4, -15, -15)
	zoneoffset:SetValueStep(1)
	zoneoffset:SetValue(pMinimap.db.zoneoffset)
	zoneoffset:SetScript('OnValueChanged', function(self, value)
		pMinimap.db.zoneoffset = value
		zoneoffsettext:SetFormattedText('Zone Offset: %d', value)
		MinimapZoneTextButton:ClearAllPoints()
		MinimapZoneTextButton:SetPoint(pMinimap.db.zonepoint == 'TOP' and 'BOTTOM' or 'TOP', Minimap, pMinimap.db.zonepoint, 0, value)
	end)

	local group5 = group.new(self, 'Fonts', 'TOPLEFT', group4, 'BOTTOMLEFT', 0, -20)
	group5:SetHeight(110)
	group5:SetWidth(370)

	local font, fonttext, fontcontainer = dropdown.new(self, 'Font', 'TOPLEFT', group5, 10, -4)
	font:SetWidth(180)
	font.text = fonttext
	font.text:SetText(pMinimap.db.font)
	UIDropDownMenu_Initialize(font, dropFont)

	local fontflag, fontflagtext = dropdown.new(self, 'Font Flag', 'BOTTOMLEFT', group5, 10, 4)
	fontflag:SetWidth(180)
	fontflag.text = fontflagtext
	fontflag.text:SetText(pMinimap.db.fontflag)
	UIDropDownMenu_Initialize(fontflag, dropFontflag)

	local fontsize, fontsizetext = slider.new(self, 'Font Size'..pMinimap.db.fontsize, 5, 18, 'TOPRIGHT', group5, -15, -15)
	fontsize:SetValueStep(1)
	fontsize:SetValue(pMinimap.db.fontsize)
	fontsize:SetScript('OnValueChanged', function(self, value)
		pMinimap.db.fontsize = value
		fontsizetext:SetFormattedText('Font Size: %d', value)
		updateStrings()
	end)

	self:SetScript('OnShow', nil)
end)

InterfaceOptions_AddCategory(addon)
