
local LibConfig = LibStub('LibConfig-1.0')
local LibSharedMedia = LibStub('LibSharedMedia-3.0')

local pMinimap = CreateFrame('Frame')
pMinimap:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
pMinimap:RegisterEvent('PLAYER_LOGIN')
pMinimap:RegisterEvent('PLAYER_LOGOUT')

local DB, UNLOCKED
local PLAYER = GetRealmName() .. ' - ' .. UnitName('player')
local DEFAULTS = {
	minimap = {
		scale = 0.9,
		level = 2,
		strata = 'BACKGROUND',
		borderSize = 1,
		borderColors = {0, 0, 0, 1},
		position = 'TOPRIGHT\031-15\031-15',
	},
	objects = {
		Zone = {shown = false, point = 'TOP'},
		Difficulty = {shown = false, point = 'BOTTOM'},
		Battlefield = {shown = true, point = 'TOPRIGHT'},
		Dungeon = {shown = true, point = 'TOPRIGHT'},
		Tracking = {shown = true, point = 'TOPLEFT'},
		Clock = {shown = true, point = 'BOTTOM'},
		Mail = {shown = true, point = 'BOTTOMRIGHT'},
	},
	font = {
		index = 2,
		size = 12,
		shadow = 'OUTLINE',
		monochrome = false,
	},
}

local OBJECTS = {
	Zone = 'MinimapZoneTextButton',
	Difficulty = 'MiniMapInstanceDifficulty',
	Battlefield = 'MiniMapBattlefieldFrame',
	Dungeon = 'MiniMapLFGFrame',
	Tracking = 'MiniMapTracking',
	Clock = 'TimeManagerClockButton',
	Mail = 'MiniMapMailFrame',
}

function UpdateObjects()
	for name, setting in pairs(DB.objects) do
		local object = _G[OBJECTS[name]]

		if(setting.shown) then
			object:SetAlpha(1)
			object:EnableMouse(true)
		else
			object:SetAlpha(0)
			object:EnableMouse(false)
		end

		object:ClearAllPoints()
		object:SetPoint(setting.point)
	end
end

function UpdateCore()
	Minimap:SetScale(DB.minimap.scale)
	Minimap:SetFrameStrata(DB.minimap.strata)
	Minimap:SetFrameLevel(DB.minimap.level)

	local size = DB.minimap.borderSize
	Minimap:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {left = -size, right = -size, top = -size, bottom = -size}})
	Minimap:SetBackdropColor(unpack(DB.minimap.borderColors))
end

function UpdateFont()
	local fonts = LibSharedMedia:List('font')
	local font, size = LibSharedMedia:Fetch('font', fonts[DB.font.index]), DB.font.size
	local flag = DB.font.shadow .. (DB.font.monochrome and 'MONOCHROME' or '')

	MinimapZoneText:SetFont(font, size, flag)
	TimeManagerClockTicker:SetFont(font, size, flag)
end

function UpdatePosition(save)
	if(save) then
		local point, _, _, x, y = Minimap:GetPoint()
		DB.minimap.position = string.format('%s\031%d\031%d', point, x, y)
	else
		local point, x, y = string.split('\031', DB.minimap.position)
		Minimap:ClearAllPoints()
		Minimap:SetPoint(point, UIParent, point, x, y)
	end
end

function pMinimap:PLAYER_LOGIN()
	pMinimapProfiles = pMinimapProfiles or {}
	DB = pMinimapProfiles[PLAYER] or DEFAULTS

	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	Minimap:EnableMouseWheel()
	Minimap:SetScript('OnMouseWheel', function(self, direction)
		if(direction > 0) then
			MinimapZoomIn:Click()
		else
			MinimapZoomOut:Click()
		end
	end)

	Minimap:SetMovable(true)
	Minimap:SetClampedToScreen()
	Minimap:RegisterForDrag('LeftButton')
	Minimap:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	Minimap:SetScript('OnDragStart', function(self)
		if(not UNLOCKED) then return end
		self:StartMoving()
	end)
	Minimap:SetScript('OnDragStop', function(self)
		if(not UNLOCKED) then return end
		self:StopMovingOrSizing()
	end)

	MinimapCluster:EnableMouse(false)
	MinimapBorder:SetTexture(nil)
	MinimapBorderTop:Hide()
	MinimapNorthTag:SetAlpha(0)
	MiniMapWorldMapButton:Hide()
	GameTimeFrame:Hide()

	MiniMapTracking:SetParent(Minimap)
	MiniMapTrackingBackground:Hide()
	MiniMapTrackingButtonBorder:SetTexture(nil)
	MiniMapTrackingButton:SetHighlightTexture(nil)
	MiniMapTrackingIconOverlay:SetTexture(nil)
	MiniMapTrackingIcon:SetTexCoord(0.065, 0.935, 0.065, 0.935)

	MiniMapLFGFrame:SetParent(Minimap)
	MiniMapLFGFrame:SetHighlightTexture(nil)
	MiniMapLFGFrameBorder:Hide()
	LFDSearchStatus:SetClampedToScreen(true)

	MiniMapBattlefieldFrame:SetParent(Minimap)
	MiniMapBattlefieldBorder:SetTexture(nil)
	BattlegroundShine:Hide()

	MiniMapMailIcon:SetTexture([=[Interface\Minimap\Tracking\Mailbox]=])
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailBorder:SetTexture(nil)

	MinimapZoneTextButton:SetParent(Minimap)
	MinimapZoneText:SetShadowOffset(0, 0)

	TimeManager_LoadUI()
	TimeManagerClockButton:GetRegions():Hide()
	TimeManagerClockButton:SetSize(40, 14)
	TimeManagerClockTicker:SetPoint('CENTER', TimeManagerClockButton)
	TimeManagerClockTicker:SetShadowOffset(0, 0)

	UNLOCKED = false
	UpdatePosition()
	UpdateObjects()
	UpdateCore()
	UpdateFont()
end

function pMinimap:PLAYER_LOGOUT()
	pMinimapProfiles = pMinimapProfiles or {}
	pMinimapProfiles[PLAYER] = DB
end

-- http://wowwiki.com/GetMinimapShape
function GetMinimapShape()
	return 'SQUARE'
end


LibConfig.AddConfig('pMinimap', nil, function(self)
	self:CreateSlider(
		'name', 'Scale', 'step', 0.1,
		'minValue', 0.5, 'maxValue', 2.5,
		'default', DEFAULTS.minimap.scale,
		'currentTextFunc', function(value) return string.format('%.1f', value) end,
		'getFunc', function() return DB.minimap.scale end,
		'setFunc', function(value) DB.minimap.scale = value; UpdateCore() end
	):SetPoint('TOPLEFT', 30, -30)

	self:CreateCheckBox(
		'name', 'Unlock',
		'default', false,
		'getFunc', function() return UNLOCKED end,
		'setFunc', function() UNLOCKED = not UNLOCKED end,
		'okayFunc', function() UpdatePosition(true) end,
		'cancelFunc', function() UpdatePosition() end,
		'defaultFunc', function() DB.minimap.position = DEFAULTS.minimap.position; UpdatePosition() end
	):SetPoint('TOPLEFT', 30, -80)

	self:CreateSlider(
		'name', 'Frame Level', 'step', 1,
		'minValue', 0, 'maxValue', 10,
		'default', DEFAULTS.minimap.level,
		'currentTextFunc', function(value) return value end,
		'getFunc', function() return DB.minimap.level end,
		'setFunc', function(value) DB.minimap.level = value; UpdateCore() end
	):SetPoint('TOPRIGHT', -30, -30)

	self:CreateDropDown(
		'name', 'Frame Strata',
		'default', DEFAULTS.minimap.strata,
		'getFunc', function() return DB.minimap.strata end,
		'setFunc', function(value) DB.minimap.strata = value; UpdateCore() end,
		'values', {HIGH = 'High', MEDIUM = 'Medium', LOW = 'Low', BACKGROUND = 'Background'}
	):SetPoint('TOPRIGHT', -10, -80)

	self:CreateSlider(
		'name', 'Border Thickness', 'step', 1,
		'minValue', 0, 'maxValue', 10,
		'default', DEFAULTS.minimap.borderSize,
		'currentTextFunc', function(value) return value end,
		'getFunc', function() return DB.minimap.borderSize end,
		'setFunc', function(value) DB.minimap.borderSize = value; UpdateCore() end
	):SetPoint('LEFT', 30, 0)

	self:CreatePalette(
		'name', 'Border Color', 'hasAlpha', true,
		'default', DEFAULTS.minimap.borderColors,
		'getFunc', function() return unpack(DB.minimap.borderColors) end,
		'setFunc', function(r, g, b, a) DB.minimap.borderColors = {r, g, b, a}; UpdateCore() end
	):SetPoint('RIGHT', -130, 0)

	self:CreateDropDown(
		'name', 'Font',
		'default', DEFAULTS.font.index,
		'getFunc', function() return DB.font.index end,
		'setFunc', function(value) DB.font.index = value; UpdateFont() end,
		'values', LibSharedMedia:List('font')
	):SetPoint('BOTTOMLEFT', 10, 20)

	self:CreateSlider(
		'name', 'Font Size', 'step', 1,
		'minValue', 6, 'maxValue', 36,
		'default', DEFAULTS.font.size,
		'currentTextFunc', function(value) return value end,
		'getFunc', function() return DB.font.size end,
		'setFunc', function(value) DB.font.size = value; UpdateFont() end
	):SetPoint('BOTTOMLEFT', 30, 80)

	self:CreateDropDown(
		'name', 'Font Shadow',
		'default', DEFAULTS.font.shadow,
		'getFunc', function() return DB.font.shadow end,
		'setFunc', function(value) DB.font.shadow = value; UpdateFont() end,
		'values', {OUTLINE = 'Outline', THICKOUTLINE = 'Thick Outline', NONE = 'None'}
	):SetPoint('BOTTOMRIGHT', -10, 20)

	self:CreateCheckBox(
		'name', 'Monochrome',
		'default', DEFAULTS.font.monochrome,
		'getFunc', function() return DB.font.monochrome end,
		'setFunc', function(value) DB.font.monochrome = value; UpdateFont() end
	):SetPoint('BOTTOMRIGHT', -140, 75)
end)

LibConfig.AddConfig('Objects', 'pMinimap', function(self)
	local points = {TOPLEFT = 'Top Left', TOP = 'Top', TOPRIGHT = 'Top Right', LEFT = 'Left', RIGHT = 'Right', BOTTOMLEFT = 'Bottom Left', BOTTOM = 'Bottom', BOTTOMRIGHT = 'Bottom Right'}
	local offset = 25

	for name, default in pairs(DEFAULTS.objects) do
		self:CreateCheckBox(
			'name', name,
			'default', default.shown,
			'getFunc', function() local o = DB.objects[name]; return o.shown end,
			'setFunc', function(value) local o = DB.objects[name]; o.shown = value; DB.objects[name] = o; UpdateObjects() end
		):SetPoint('TOPLEFT', 25, -offset)

		self:CreateDropDown(
			'name', name..' Position',
			'default', default.point,
			'getFunc', function() local o = DB.objects[name]; return o.point end,
			'setFunc', function(value) local o = DB.objects[name]; o.point = value; DB.objects[name] = o; UpdateObjects() end,
			'values', points
		):SetPoint('TOPRIGHT', -10, -offset)

		offset = offset + 60
	end
end)

LibConfig.AddCommand('pMinimap', '/pmm', '/pminimap')
