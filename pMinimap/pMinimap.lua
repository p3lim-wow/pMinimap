pMinimap = CreateFrame('Frame', 'pMinimap', UIParent)
pMinimap:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
pMinimap:RegisterEvent('ADDON_LOADED')

pMinimap.Loader = CreateFrame('Frame', nil, InterfaceOptionsFrame)
pMinimap.Loader:SetScript('OnShow', function(self) if(not IsAddOnLoaded('pMinimap_Config')) then LoadAddOn('pMinimap_Config') end self:SetScript('OnShow', nil) end)

local total = 0
local defaults = {
	coords = false,
	clock = true,
	dura = true,
	mail = true,
	subzone = false,
	unlocked = false,
	scale = 0.9,
	offset = 1,
	level = 2,
	strata = 'BACKGROUND',
	font = 'Interface\\AddOns\\pMinimap\\font.ttf',
	fontsize = 13,
	fontflag = 'OUTLINE',
	colors = {0, 0, 0, 1},
}


function pMinimap:DisableBlizzard()
	for k,v in pairs({InterfaceOptionsDisplayPanelShowClock}) do
		local warning = v:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
		warning:SetPoint('TOPLEFT', v, 0, 10)
		warning:SetText('|cff00ff33OVERRID BY PMINIMAP!|r')

		v:Disable()
		v.Enable = v.Disable
	end

	InterfaceOptionsDisplayPanelShowClock.setFunc('1')
	InterfaceOptionsDisplayPanelShowClock.setFunc = function() end
end

function pMinimap:LoadDefaults()
	pMinimapDB = pMinimapDB or {}
	for k,v in pairs(defaults) do
		if(type(pMinimapDB[k]) == 'nil') then
			pMinimapDB[k] = v
		end
	end
end


function pMinimap:CreateClock()
	if(not IsAddOnLoaded('Blizzard_TimeManager')) then LoadAddOn('Blizzard_TimeManager') end

	TimeManagerClockButton:SetWidth(40)
	TimeManagerClockButton:SetHeight(14)
	TimeManagerClockButton:ClearAllPoints()
	TimeManagerClockButton:SetPoint(pMinimapDB.coords and 'BOTTOMLEFT' or 'BOTTOM', Minimap)
	TimeManagerClockButton:GetRegions():Hide()
	TimeManagerClockButton:Show()
	TimeManagerClockButton:SetScript('OnClick', function(self, button)
		if(self.alarmFiring) then
			PlaySound('igMainMenuQuit')
			TimeManager_TurnOffAlarm()
		else
			if(button == 'RightButton') then
				if(not IsAddOnLoaded('Blizzard_Calendar')) then LoadAddOn('Blizzard_Calendar') end
				ToggleCalendar()
			else
				ToggleTimeManager()
			end
		end
	end)

	TimeManagerClockTicker:SetPoint('CENTER', TimeManagerClockButton)
	TimeManagerClockTicker:SetFont(pMinimapDB.font, pMinimapDB.fontsize, pMinimapDB.fontflag)

	TimeManagerAlarmFiredTexture.Show = function() TimeManagerClockTicker:SetTextColor(1, 0, 0) end
	TimeManagerAlarmFiredTexture.Hide = function() TimeManagerClockTicker:SetTextColor(1, 1, 1) end

	GameTimeCalendarInvitesTexture.Show = function() TimeManagerClockTicker:SetTextColor(0, 1, 0) end
	GameTimeCalendarInvitesTexture.Show = function() TimeManagerClockTicker:SetTextColor(1, 1, 1) end
end

function pMinimap:CreateCoords()
	self.Coord = CreateFrame('Button', nil, Minimap)
	self.Coord:SetPoint(pMinimapDB.clock and 'BOTTOMRIGHT' or 'BOTTOM', Minimap)
	self.Coord:SetWidth(40)
	self.Coord:SetHeight(14)
	self.Coord:RegisterForClicks('AnyUp')

	self.Coord.Text = self.Coord:CreateFontString(nil, 'OVERLAY')
	self.Coord.Text:SetPoint('CENTER', self.Coord)
	self.Coord.Text:SetFont(pMinimapDB.font, pMinimapDB.fontsize, pMinimapDB.fontflag)
	self.Coord.Text:SetTextColor(1, 1, 1)

	self.Coord:SetScript('OnClick', function() ToggleFrame(WorldMapFrame) end)
	self.Coord:SetScript('OnUpdate', function(self, elapsed)
		total = total + elapsed

		if(total > 0.25) then
			if(IsInInstance()) then
				self.Text:SetText()
			else
				local x, y = GetPlayerMapPosition('player')
				self.Text:SetFormattedText('%.0f,%.0f', x * 100, y * 100)
			end
			total = 0
		end
	end)
end


function pMinimap:ZONE_CHANGED_NEW_AREA()
	SetMapToCurrentZone()
end

function pMinimap:UPDATE_INVENTORY_ALERTS()
	local maxStatus = 0
	for id in pairs(INVENTORY_ALERT_STATUS_SLOTS) do
		local status = GetInventoryAlertStatus(id)
		if(status > maxStatus) then
			maxStatus = status
		end
	end

	local color = INVENTORY_ALERT_COLORS[maxStatus]
	if(color) then
		Minimap:SetBackdropColor(color.r, color.g, color.b)
	else
		Minimap:SetBackdropColor(unpack(pMinimapDB.colors))
	end
end

function pMinimap:ADDON_LOADED(event, addon)
	if(addon ~= 'pMinimap') then return end

	self:UnregisterEvent(event)	
	self:DisableBlizzard()
	self:LoadDefaults()

	pMinimapDB.unlocked = false

	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	Minimap:EnableMouseWheel()
	Minimap:SetScript('OnMouseWheel', function(self, dir)
		if(dir > 0) then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end)

	MiniMapTrackingBackground:Hide()
	MiniMapTrackingButton:SetHighlightTexture('')
	MiniMapTrackingButtonBorder:SetTexture('')
	MiniMapTrackingIcon:SetTexCoord(0.065, 0.935, 0.065, 0.935)
	MiniMapTrackingIconOverlay:SetTexture('')
	MiniMapTracking:SetParent(Minimap)
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint('TOPLEFT', -2, 2)

	BattlegroundShine:Hide()
	MiniMapBattlefieldBorder:SetTexture('')
	MiniMapBattlefieldFrame:SetParent(Minimap)
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint('TOPRIGHT', -2, -2)

	MiniMapMailIcon:Hide()
	MiniMapMailBorder:SetTexture('')
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint('TOP')
	MiniMapMailFrame:SetHeight(8)

	self.Mail = MiniMapMailFrame:CreateFontString(nil, 'OVERLAY')
	self.Mail:SetFont(pMinimapDB.font, pMinimapDB.fontsize, pMinimapDB.fontflag)
	self.Mail:SetPoint('BOTTOM', 0, 2)
	self.Mail:SetText('New Mail!')
	self.Mail:SetTextColor(1, 1, 1)

	MinimapBorder:SetTexture('')
	MinimapBorderTop:Hide()
	MinimapToggleButton:Hide()

	GameTimeFrame:Hide()
	MinimapZoneTextButton:Hide()
	MiniMapWorldMapButton:Hide()
	MiniMapMeetingStoneFrame:SetAlpha(0)
	MiniMapVoiceChatFrame:Hide()
	MiniMapVoiceChatFrame.Show = MiniMapVoiceChatFrame.Hide
	MinimapNorthTag:SetAlpha(0)

	Minimap:SetScale(pMinimapDB.scale)
	Minimap:SetFrameLevel(pMinimapDB.level)
	Minimap:SetFrameStrata(pMinimapDB.strata)
	Minimap:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	Minimap:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = - pMinimapDB.offset, left = - pMinimapDB.offset, bottom = - pMinimapDB.offset, right = - pMinimapDB.offset}})
	Minimap:SetBackdropColor(unpack(pMinimapDB.colors))

	MinimapCluster:EnableMouse(false)
	Minimap:SetMovable(true)
	Minimap:RegisterForDrag('LeftButton')
	Minimap:SetScript('OnDragStop', function() if(pMinimapDB.unlocked) then Minimap:StopMovingOrSizing() end end)
	Minimap:SetScript('OnDragStart', function()
		if(pMinimapDB.unlocked) then
			Minimap:ClearAllPoints()
			Minimap:StartMoving()
		end
	end)

	if(pMinimapDB.dura) then
		DurabilityFrame:SetAlpha(0)

		self:RegisterEvent('UPDATE_INVENTORY_ALERTS')
		self.UPDATE_INVENTORY_ALERTS()
	end

	if(pMinimapDB.coords) then
		self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
		self:CreateCoords()
		self.RunCoords = true
	end

	if(pMinimapDB.clock) then
		self:CreateClock()
		self.RunClock = true
	else
		TimeManagerClockButton:Hide()
	end

	if(not pMinimapDB.mail) then
		MiniMapMailFrame:UnregisterEvent('UPDATE_PENDING_MAIL')
		MiniMapMailFrame:Hide()
	end
end


SLASH_PMMC1 = '/pmm'
SLASH_PMMC2 = '/pminimap'
SlashCmdList.PMMC = function(str)
	if(str == 'reset') then
		pMinimapDB = {}
		pMinimap:LoadDefaults()
		print('|cffff8080pMinimap:|r Savedvariables is now reset.')
	elseif(str == 'refresh') then
		Minimap:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
		print('|cffff8080pMinimap:|r Minimap mask is now refreshed.')
	else
		if(not IsAddOnLoaded('pMinimap_Config')) then
			LoadAddOn('pMinimap_Config')
		end
		InterfaceOptionsFrame_OpenToCategory('pMinimap')
	end
end


-- http://www.wowwiki.com/GetMinimapShape
function GetMinimapShape() return 'SQUARE' end