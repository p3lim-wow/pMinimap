pMinimap = CreateFrame('Frame', 'pMinimap', UIParent)
pMinimap:SetScript('OnEvent', function(self, event, ...) if(self[event]) then return self[event](self, event, ...) end end)
pMinimap:RegisterEvent('ADDON_LOADED')

local defaults = {
	coords = false,
	clock = true,
	durabi = true,
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

InterfaceOptionsDisplayPanelShowClock_SetFunc('1')
InterfaceOptionsDisplayPanelShowClock_SetFunc = function() end

for _, check in pairs{InterfaceOptionsDisplayPanelShowClock} do
	local f = check:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	f:SetPoint('TOPLEFT', check, 0, 10)
	f:SetText('|cff00ff33OVERRID BY PMINIMAP!|r')

	check:Disable()
	check.Enable = function() end
end

function pMinimap:ADDON_LOADED(event, addon)
	if(addon ~= 'pMinimap') then return end

	pMinimapDB = pMinimapDB or {}
	for k,v in pairs(defaults) do
		if(type(pMinimapDB[k]) == 'nil') then
			pMinimapDB[k] = v
		end
	end

	pMinimapDB.unlocked = false
	self:UnregisterEvent(event)

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

	MiniMapMailText = MiniMapMailFrame:CreateFontString(nil, 'OVERLAY')
	MiniMapMailText:SetFont(pMinimapDB.font, pMinimapDB.fontsize, pMinimapDB.fontflag)
	MiniMapMailText:SetPoint('BOTTOM', 0, 2)
	MiniMapMailText:SetText('New Mail!')
	MiniMapMailText:SetTextColor(1, 1, 1)

	MinimapBorder:SetTexture('')
	MinimapBorderTop:Hide()
	MinimapToggleButton:Hide()

	GameTimeFrame:Hide()
	MinimapZoneTextButton:Hide()
	MiniMapWorldMapButton:Hide()
	MiniMapMeetingStoneFrame:SetAlpha(0)
	MiniMapVoiceChatFrame:Hide()
	MiniMapVoiceChatFrame.Show = function() end
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

	if(pMinimapDB.dura and not IsAddOnLoaded('pMinimap_Durability')) then LoadAddOn('pMinimap_Durability') end
	if(pMinimapDB.coords and not IsAddOnLoaded('pMinimap_Coords')) then LoadAddOn('pMinimap_Coords') end
	if(pMinimapDB.clock and not IsAddOnLoaded('pMinimap_Clock')) then LoadAddOn('pMinimap_Clock') end
	if(not pMinimapDB.clock) then TimeManagerClockButton:Hide() end
	if(not pMinimapDB.mail) then
		MiniMapMailFrame:UnregisterEvent('UPDATE_PENDING_MAIL')
		MiniMapMailFrame:Hide()
	end

	local f = CreateFrame('Frame', nil, InterfaceOptionsFrame)
	f:SetScript('OnShow', function(self) LoadAddOn('OmniCC_Options') self:SetScript('OnShow', nil) end)
end

CreateFrame('Frame', nil, InterfaceOptionsFrame):SetScript('OnShow', function(self)
if(not IsAddOnLoaded('pMinimap_Config')) then LoadAddOn('pMinimap_Config') end self:SetScript('OnShow', nil) end)

SlashCmdList.PMMC = function(str)
	if(str == 'reset') then
		pMinimapDB = {}
		print('|cffff6000p|rMinimap: |cff0090ffSavedvariables is now reset.|r')
	elseif(str == 'refresh') then
		Minimap:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
		print('|cffff6000p|rMinimap: |cff0090ffMinimap mask is now refreshed.|r')
	else
		if(not IsAddOnLoaded('pMinimap_Config')) then
			LoadAddOn('pMinimap_Config')
		end
		InterfaceOptionsFrame_OpenToCategory('pMinimap')
	end
end
SLASH_PMMC1 = '/pminimap'
SLASH_PMMC2 = '/pmm'

-- http://www.wowwiki.com/GetMinimapShape
function GetMinimapShape() return 'SQUARE' end