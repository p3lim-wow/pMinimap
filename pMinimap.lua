local _, ns = ...

pMinimap = CreateFrame('Frame', 'pMinimap', Minimap)
pMinimap:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
pMinimap:RegisterEvent('ADDON_LOADED')

local DEFAULTS = {
	minimap = {
		scale = 0.9,
		level = 2,
		strata = 'BACKGROUND',
		borderSize = 1,
		borderColors = {0, 0, 0, 1},
	},
	objects = {
		Zone = {point = 'TOP', shown = false},
		Difficulty = {point = 'BOTTOM', shown = false},
		Battlefield = {point = 'TOPRIGHT', shown = true},
		Dungeon = {point = 'TOPRIGHT', shown = true},
		Tracking = {point = 'TOPLEFT', shown = true},
		Clock = {point = 'BOTTOM', shown = true},
		Mail = {point = 'BOTTOMRIGHT', shown = true},
	},
	font = {
		name = LibStub('LibSharedMedia-3.0'):GetDefault('font'),
		size = 12,
		shadow = 'OUTLINE',
		monochrome = false,
	},
}

function pMinimap:ADDON_LOADED(addon)
	if(addon ~= 'pMinimap') then return end
	pMinimapDB = pMinimapDB or DEFAULTS

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

	Minimap:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
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

	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailBorder:SetTexture(nil)

	MinimapZoneTextButton:SetParent(Minimap)
	MinimapZoneText:SetShadowOffset(0, 0)

	if(not IsAddOnLoaded('Blizzard_TimeManager')) then
		LoadAddOn('Blizzard_TimeManager')
	end

	TimeManagerClockButton:GetRegions():Hide()
	TimeManagerClockButton:SetSize(40, 14)
	TimeManagerClockTicker:SetPoint('CENTER', TimeManagerClockButton)
	TimeManagerClockTicker:SetShadowOffset(0, 0)

	ns.UpdateObjects()
	ns.UpdateCore()
	ns.UpdateFont()

	SLASH_pMinimap1 = '/pmm'
	SLASH_pMinimap2 = '/pminimap'
	SlashCmdList.pMinimap = function()
		InterfaceOptionsFrame_OpenToCategory('pMinimap')
	end
end

-- http://wowwiki.com/GetMinimapShape
function GetMinimapShape()
	return 'SQUARE'
end
