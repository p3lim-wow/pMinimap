pMinimap = CreateFrame('Frame', 'pMinimap', UIParent)
pMinimap:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
pMinimap:RegisterEvent('ADDON_LOADED')

local LSM = LibStub('LibSharedMedia-3.0')

local onUpdate, onClickClock, onClickCoord, onMouseWheel
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
	smfont = 'Visitor TT1',
	fontsize = 13,
	fontflag = 'OUTLINE',
	colors = {0, 0, 0, 1},
	zone = false,
	zonePoint = 'TOP',
	zoneOffset = 8,
}

do
	local total = 0.25
	function onUpdate(self, elapsed)
		if(total) then
			total = total - elapsed
			if(total <= 0) then
				total = 0.25

				local x, y = GetPlayerMapPosition('player')
				if(x ~= 0 and y ~= 0 and not IsInInstance()) then
					self.Text:SetFormattedText('%.0f,%.0f', x * 100, y * 100)
				else
					self.Text:SetText()
				end
			end
		end
	end

	function onClickClock(self, button)
		if(button == 'RightButton') then
			ToggleCalendar()
		else
			if(self.alarmFiring) then
				PlaySound('igMainMenuQuit')
				TimeManager_TurnOffAlarm()
			else
				ToggleTimeManager()
			end
		end
	end

	function onClickCoord(self, button)
		if(button == 'RightButton') then
			ToggleBattlefieldMinimap()
		else
			ToggleFrame(WorldMapFrame)
		end
	end

	function onMouseWheel(self, dir)
		if(dir > 0) then
			MinimapZoomIn:Click()
		else
			MinimapZoomOut:Click()
		end
	end
end


local function slashHandler(str)
	if(str == 'reset') then
		pMinimapDB = {}
		print('|cffff8080pMinimap:|r Savedvariables is now reset. You should reload/relog to affect changes.')
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

local function optionsPanel(self)
	if(not IsAddOnLoaded('pMinimap_Config')) then
		LoadAddOn('pMinimap_Config')
	end
	self:SetScript('OnShow', nil)

	InterfaceOptionsDisplayPanelShowClock:Disable()
	InterfaceOptionsDisplayPanelShowClock:Hide()
end

local function Initialize(self)
	Minimap:EnableMouseWheel()
	Minimap:SetScript('OnMouseWheel', onMouseWheel)
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()

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

	MiniMapMailBorder:SetTexture('')
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint('TOP', 0, -4)
	MiniMapMailFrame:SetHeight(8)

	MiniMapMailText = MiniMapMailFrame:CreateFontString(nil, 'OVERLAY')
	MiniMapMailText:SetFont(LSM:Fetch('font', self.db.smfont), self.db.fontsize, self.db.fontflag)
	MiniMapMailText:SetPoint('BOTTOM', 0, 2)
	MiniMapMailText:SetText('New Mail!')
	MiniMapMailText:SetTextColor(1, 1, 1)

	MinimapZoneTextButton:SetParent(Minimap)
	MinimapZoneTextButton:ClearAllPoints()
	MinimapZoneTextButton:SetPoint(self.db.zonePoint == 'BOTTOM' and 'TOP' or 'BOTTOM', Minimap, self.db.zonePoint, 0, self.db.zoneOffset)
	MinimapZoneTextButton:SetWidth(Minimap:GetWidth() * 1.5)

	MinimapZoneText:ClearAllPoints()
	MinimapZoneText:SetAllPoints(MinimapZoneTextButton)
	MinimapZoneText:SetFont(LSM:Fetch('font', self.db.smfont), self.db.fontsize, self.db.fontflag)
	MinimapZoneText:SetShadowOffset(0, 0)

	MinimapBorder:SetTexture('')
	MinimapBorderTop:Hide()
	MinimapToggleButton:Hide()

	GameTimeFrame:Hide()
	MiniMapWorldMapButton:Hide()
	MiniMapMeetingStoneFrame:SetAlpha(0)
	MiniMapVoiceChatFrame:Hide()
	MiniMapVoiceChatFrame.Show = MiniMapVoiceChatFrame.Hide
	MinimapNorthTag:SetAlpha(0)

	Minimap:SetScale(self.db.scale)
	Minimap:SetFrameLevel(self.db.level)
	Minimap:SetFrameStrata(self.db.strata)
	Minimap:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	Minimap:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = - self.db.offset, left = - self.db.offset, bottom = - self.db.offset, right = - self.db.offset}})
	Minimap:SetBackdropColor(unpack(self.db.colors))

	MinimapCluster:EnableMouse(false)
	Minimap:SetMovable(true)
	Minimap:RegisterForDrag('LeftButton')
	Minimap:SetScript('OnDragStop', function() if(pMinimapDB.unlocked) then Minimap:StopMovingOrSizing() end end)
	Minimap:SetScript('OnDragStart', function() if(pMinimapDB.unlocked) then Minimap:StartMoving() end end)

	if(not self.db.zone) then
		MinimapZoneTextButton:Hide()
	end

	if(self.db.dura) then
		DurabilityFrame:SetAlpha(0)

		self:RegisterEvent('UPDATE_INVENTORY_ALERTS')
		self.UPDATE_INVENTORY_ALERTS()
	end

	if(self.db.coords) then
		self:CreateCoords()
	end

	if(self.db.clock) then
		self:CreateClock()
	else
		TimeManagerClockButton:Hide()
	end

	if(self.db.mail) then
		MiniMapMailIcon:Hide()
	else
		MiniMapMailText:Hide()
	end
end


function pMinimap:CreateClock()
	TimeManager_LoadUI()

	TimeManagerClockButton:SetWidth(40)
	TimeManagerClockButton:SetHeight(14)
	TimeManagerClockButton:ClearAllPoints()
	TimeManagerClockButton:SetPoint(self.db.coords and 'BOTTOMLEFT' or 'BOTTOM', Minimap)
	TimeManagerClockButton:GetRegions():Hide()
	TimeManagerClockButton:Show()
	TimeManagerClockButton:SetScript('OnClick', onClickClock)

	TimeManagerClockTicker:SetPoint('CENTER', TimeManagerClockButton)
	TimeManagerClockTicker:SetFont(LSM:Fetch('font', self.db.smfont), self.db.fontsize, self.db.fontflag)
	TimeManagerClockTicker:SetShadowOffset(0, 0)

	TimeManagerAlarmFiredTexture.Show = function() TimeManagerClockTicker:SetTextColor(1, 0, 0) end
	TimeManagerAlarmFiredTexture.Hide = function() TimeManagerClockTicker:SetTextColor(1, 1, 1) end

	self:RegisterEvent('CALENDAR_UPDATE_PENDING_INVITES')
	self.CALENDAR_UPDATE_PENDING_INVITES()

	self.RunClock = true
end

function pMinimap:CreateCoords()
	self.Coord = CreateFrame('Button', nil, Minimap)
	self.Coord:SetPoint(self.db.clock and 'BOTTOMRIGHT' or 'BOTTOM', Minimap)
	self.Coord:SetWidth(40)
	self.Coord:SetHeight(14)
	self.Coord:RegisterForClicks('AnyUp')

	self.Coord.Text = self.Coord:CreateFontString(nil, 'OVERLAY')
	self.Coord.Text:SetPoint('CENTER', self.Coord)
	self.Coord.Text:SetFont(LSM:Fetch('font', self.db.smfont), self.db.fontsize, self.db.fontflag)
	self.Coord.Text:SetTextColor(1, 1, 1)

	self.Coord:SetScript('OnClick', onClickCoord)
	self.Coord:SetScript('OnUpdate', onUpdate)

	self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
end


function pMinimap:ADDON_LOADED(event, addon)
	if(addon ~= 'pMinimap') then return end

	CreateFrame('Frame', nil, InterfaceOptionsFrame):SetScript('OnShow', optionsPanel)
	LSM:Register('font', 'Visitor TT1', [=[Interface\AddOns\pMinimap\font.ttf]=])

	SLASH_PMINIMAP1 = '/pmm'
	SLASH_PMINIMAP2 = '/pminimap'
	SlashCmdList.PMINIMAP = slashHandler

	pMinimapDB = setmetatable(pMinimapDB or {}, {__index = defaults})
	pMinimapDB.unlocked = false

	self.db = pMinimapDB
	self:UnregisterEvent(event)

	InterfaceOptionsDisplayPanelShowClock.setFunc('1')
	InterfaceOptionsDisplayPanelShowClock.setFunc = function() end

	Initialize(self)
end

function pMinimap:CALENDAR_UPDATE_PENDING_INVITES()
	if(CalendarGetNumPendingInvites() ~= 0) then
		TimeManagerClockTicker:SetTextColor(0, 1, 0)
	else
		TimeManagerClockTicker:SetTextColor(1, 1, 1)
	end
end

function pMinimap:ZONE_CHANGED_NEW_AREA()
	SetMapToCurrentZone()
end

function pMinimap:UPDATE_INVENTORY_ALERTS()
	local highstatus = 0
	for i in next, INVENTORY_ALERT_STATUS_SLOTS do
		local status = GetInventoryAlertStatus(i)
		if(status > highstatus) then
			highstatus = status
		end
	end

	local color = INVENTORY_ALERT_COLORS[highstatus]
	if(color) then
		Minimap:SetBackdropColor(color.r, color.g, color.b)
	else
		Minimap:SetBackdropColor(unpack(pMinimapDB.colors))
	end
end


-- http://www.wowwiki.com/GetMinimapShape
function GetMinimapShape() return 'SQUARE' end