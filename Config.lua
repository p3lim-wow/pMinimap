local SharedMedia = LibStub('LibSharedMedia-3.0')

local group, slider, dropdown, checkbox = LibStub('tekKonfig-Group'), LibStub('tekKonfig-Slider'), LibStub('tekKonfig-Dropdown'), LibStub('tekKonfig-Checkbox')

local function updateStrings()
	MiniMapMailText:SetFont(SharedMedia:Fetch('font', pMinimapDB.font), pMinimapDB.fontsize, pMinimapDB.fontflag)
	MinimapZoneText:SetFont(SharedMedia:Fetch('font', pMinimapDB.font), pMinimapDB.fontsize, pMinimapDB.fontflag)
	MinimapCoordinatesText:SetFont(SharedMedia:Fetch('font', pMinimapDB.font), pMinimapDB.fontsize, pMinimapDB.fontflag)
end

local function dropStrata(orig)
	local info = UIDropDownMenu_CreateInfo()
	info.func = function(self)
		pMinimapDB.strata = self.value
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
		pMinimapDB.zonepoint = self.value
		MinimapZoneTextButton:ClearAllPoints()
		MinimapZoneTextButton:SetPoint(self.value == 'TOP' and 'BOTTOM' or 'TOP', Minimap, self.value, 0, pMinimapDB.zoneoffset)
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
		pMinimapDB.font = self.value
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
		pMinimapDB.fontflag = self.value
		updateStrings()
		orig.text:SetText(self.value)
	end

	for k, v in next, {'OUTLINE', 'THICKOUTLINE', 'MONOCHROME', 'NONE'} do
		info.text = v
		info.value = v
		UIDropDownMenu_AddButton(info)
	end
end

local config = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
config.name = 'pMinimap'
config:Hide()
config:SetScript('OnShow', function(self)
	local title, subtitle = LibStub('tekKonfig-Heading').new(self, self.name, GetAddOnMetadata(self.name, 'Notes'))

	self:SetScript('OnShow', nil)
end)

local minimapgroup = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
minimapgroup.name = 'Minimap'
minimapgroup.parent = config.name
minimapgroup.addonname = config.name
minimapgroup:SetScript('OnShow', function(self)
	local scale, scaletext = slider.new(self, format('Scale: %.2f', pMinimapDB.scale), 0.5, 2.5, 'TOPLEFT', self, 15, -15)
	scale:SetValueStep(0.01)
	scale:SetValue(pMinimapDB.scale)
	scale:SetScript('OnValueChanged', function(self, value)
		pMinimapDB.scale = value
		scaletext:SetFormattedText('Scale: %.2f', value)
		Minimap:SetScale(value)
	end)

	local level, leveltext = slider.new(self, 'Framelevel: '..pMinimapDB.level, 1, 15, 'TOPLEFT', scale, 'BOTTOMLEFT', 0, -30)
	level:SetValueStep(1)
	level:SetValue(pMinimapDB.level)
	level:SetScript('OnValueChanged', function(self, value)
		pMinimapDB.level = value
		leveltext:SetFormattedText('Framelevel: %d', value)
		pMinimap:SetFrameLevel(value)
	end)

	local strata, stratatext = dropdown.new(self, 'Framestrata', 'LEFT', scale, 'RIGHT', 40, 0)
	strata.text = stratatext
	strata.text:SetText(pMinimapDB.strata)
	UIDropDownMenu_Initialize(strata, dropStrata)

	local lock = checkbox.new(self, 22, 'Locked', 'LEFT', level, 'RIGHT', 45, 0)
	lock:SetChecked(not pMinimap.unlocked)
	lock:SetScript('OnClick', function()
		pMinimap.unlocked = not pMinimap.unlocked

		if(pMinimap.unlocked) then
			Minimap:SetBackdropColor(0, 1, 0, 0.5)
		else
			Minimap:SetBackdropColor(unpack(pMinimapDB.bordercolors))
		end
	end)

	self:SetScript('OnShow', nil)
end)

local modulesgroup = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
modulesgroup.name = 'Modules'
modulesgroup.parent = config.name
modulesgroup.addonname = config.name
modulesgroup:SetScript('OnShow', function(self)
	local coordinates = checkbox.new(self, 22, 'Coordinates', 'TOPLEFT', self, 10, -10)
	coordinates:SetChecked(pMinimapDB.coordinates)
	coordinates:SetScript('OnClick', function()
		pMinimapDB.coordinates = not pMinimapDB.coordinates

		if(pMinimapDB.coordinates) then
			MinimapCoordinates:Show()
			MinimapCoordinates:ClearAllPoints()
			MinimapCoordinates:SetPoint(pMinimapDB.clock and 'BOTTOMRIGHT' or 'BOTTOM')
		else
			MinimapCoordinates:Hide()
		end

		if(pMinimapDB.clock) then
			TimeManagerClockButton:ClearAllPoints()
			TimeManagerClockButton:SetPoint(pMinimapDB.coordinates and 'BOTTOMLEFT' or 'BOTTOM', Minimap)
		end
	end)

	local coordinatesdecimals, cdtext = slider.new(self, 'Coord Decimals: '..pMinimapDB.coordinatesdecimals, 0, 3, 'TOPRIGHT', self, -15, -15)
	coordinatesdecimals:SetValueStep(1)
	coordinatesdecimals:SetValue(pMinimapDB.coordinatesdecimals)
	coordinatesdecimals:SetScript('OnValueChanged', function(self, value)
		pMinimapDB.coordinatesdecimals = value
		cdtext:SetFormattedText('Coord Decimals: %d', value)
	end)

	local clock = checkbox.new(self, 22, 'Clock', 'TOPLEFT', coordinates, 'BOTTOMLEFT', 0, -10)
	clock:SetChecked(pMinimapDB.clock)
	clock:SetScript('OnClick', function()
		pMinimapDB.clock = not pMinimapDB.clock

		if(pMinimapDB.clock) then
			if(not pMinimap:IsEventRegistered('CALENDAR_UPDATE_PENDING_INVITES')) then
				pMinimap:Clock()
			else
				TimeManagerClockButton:ClearAllPoints()
				TimeManagerClockButton:SetPoint(pMinimapDB.coordinates and 'BOTTOMLEFT' or 'BOTTOM', Minimap)
				TimeManagerClockButton:Show()
			end
		else
			TimeManagerClockButton:Hide()
		end

		if(pMinimapDB.coordinates) then
			MinimapCoordinates:ClearAllPoints()
			MinimapCoordinates:SetPoint(pMinimapDB.clock and 'BOTTOMRIGHT' or 'BOTTOM')
		end
	end)

	local mail = checkbox.new(self, 22, 'Mail', 'TOPLEFT', clock, 'BOTTOMLEFT', 0, -10)
	mail:SetChecked(pMinimapDB.mail)
	mail:SetScript('OnClick', function()
		pMinimapDB.mail = not pMinimapDB.mail

		if(pMinimapDB.mail) then
			MiniMapMailIcon:Hide()
			MiniMapMailText:Show()
		else
			MiniMapMailIcon:Show()
			MiniMapMailText:Hide()
		end
	end)

	local durability = checkbox.new(self, 22, 'Durability', 'LEFT', mail, 'RIGHT', 110, 0)
	durability:SetChecked(pMinimapDB.durability)
	durability:SetScript('OnClick', function()
		pMinimapDB.durability = not pMinimapDB.durability

		if(pMinimapDB.durability) then
			DurabilityFrame:SetAlpha(0)
			pMinimap:RegisterEvent('UPDATE_INVENTORY_ALERTS')
			pMinimap:UPDATE_INVENTORY_ALERTS()
		else
			DurabilityFrame:SetAlpha(1)
			pMinimap:UnregisterEvent('UPDATE_INVENTORY_ALERTS')
			Minimap:SetBackdropColor(unpack(pMinimapDB.bordercolors))
		end
	end)

	self:SetScript('OnShow', nil)
end)

local backgroundgroup = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
backgroundgroup.name = 'Background'
backgroundgroup.parent = config.name
backgroundgroup.addonname = config.name
backgroundgroup:SetScript('OnShow', function(self)
	local borderoffset, borderoffsettext = slider.new(self, 'Thickness: '..pMinimapDB.borderoffset, 0, 10, 'TOPLEFT', self, 15, -15)
	borderoffset:SetValueStep(1/2)
	borderoffset:SetValue(pMinimapDB.borderoffset)
	borderoffset:SetScript('OnValueChanged', function(self, value)
		pMinimapDB.borderoffset = value
		borderoffsettext:SetFormattedText('Thickness: %.1f', value)
		Minimap:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -value, bottom = -value, left = -value, right = -value}})
		Minimap:SetBackdropColor(unpack(pMinimapDB.bordercolors))
	end)

	-- todo: color palette

	self:SetScript('OnShow', nil)
end)

local zonegroup = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
zonegroup.name = 'Zone'
zonegroup.parent = config.name
zonegroup.addonname = config.name
zonegroup:SetScript('OnShow', function(self)
	local zone = checkbox.new(self, 22, 'Zone Toggle', 'TOPLEFT', self, 10, -10)
	zone:SetChecked(pMinimapDB.zone)
	zone:SetScript('OnClick', function()
		pMinimapDB.zone = not pMinimapDB.zone

		if(pMinimapDB.zone) then
			MinimapZoneTextButton:Show()
		else
			MinimapZoneTextButton:Hide()
		end
	end)

	local zonepoint, zonepointtext = dropdown.new(self, 'Zone Point', 'TOPLEFT', zone, 'BOTTOMLEFT')
	zonepoint.text = zonepointtext
	zonepoint.text:SetText(pMinimapDB.zonepoint)
	UIDropDownMenu_Initialize(zonepoint, dropZone)

	local zoneoffset, zoneoffsettext = slider.new(self, 'Zone Offset: '..pMinimapDB.zoneoffset, -25, 25, 'TOPRIGHT', self, -15, -15)
	zoneoffset:SetValueStep(1)
	zoneoffset:SetValue(pMinimapDB.zoneoffset)
	zoneoffset:SetScript('OnValueChanged', function(self, value)
		pMinimapDB.zoneoffset = value
		zoneoffsettext:SetFormattedText('Zone Offset: %d', value)
		MinimapZoneTextButton:ClearAllPoints()
		MinimapZoneTextButton:SetPoint(pMinimapDB.zonepoint == 'TOP' and 'BOTTOM' or 'TOP', Minimap, pMinimapDB.zonepoint, 0, value)
	end)

	self:SetScript('OnShow', nil)
end)

local fontsgroup = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
fontsgroup.name = 'Fonts'
fontsgroup.parent = config.name
fontsgroup.addonname = config.name
fontsgroup:SetScript('OnShow', function(self)
	local font, fonttext, fontcontainer = dropdown.new(self, 'Font', 'TOPLEFT', self, 10, -4)
	font:SetWidth(180)
	font.text = fonttext
	font.text:SetText(pMinimapDB.font)
	UIDropDownMenu_Initialize(font, dropFont)

	local fontflag, fontflagtext = dropdown.new(self, 'Font Flag', 'BOTTOMLEFT', self, 10, 4)
	fontflag:SetWidth(180)
	fontflag.text = fontflagtext
	fontflag.text:SetText(pMinimapDB.fontflag)
	UIDropDownMenu_Initialize(fontflag, dropFontflag)

	local fontsize, fontsizetext = slider.new(self, 'Font Size'..pMinimapDB.fontsize, 5, 18, 'TOPRIGHT', self, -15, -15)
	fontsize:SetValueStep(1)
	fontsize:SetValue(pMinimapDB.fontsize)
	fontsize:SetScript('OnValueChanged', function(self, value)
		pMinimapDB.fontsize = value
		fontsizetext:SetFormattedText('Font Size: %d', value)
		updateStrings()
	end)

	self:SetScript('OnShow', nil)
end)

InterfaceOptions_AddCategory(config)
InterfaceOptions_AddCategory(minimapgroup)
InterfaceOptions_AddCategory(modulesgroup)
InterfaceOptions_AddCategory(backgroundgroup)
InterfaceOptions_AddCategory(zonegroup)
InterfaceOptions_AddCategory(fontsgroup)
