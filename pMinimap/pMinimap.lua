pMinimap = CreateFrame('Frame', 'pMinimap', UIParent)
pMinimap:SetScript('OnEvent', function(self, event, ...) if(self[event]) then return self[event](self, event, ...) end end)
pMinimap:RegisterEvent('ADDON_LOADED')

InterfaceOptionsDisplayPanelShowClock_SetFunc('1')
InterfaceOptionsDisplayPanelShowClock_SetFunc = function() end

for _, check in pairs{InterfaceOptionsDisplayPanelShowClock} do
	local f = check:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	f:SetPoint('TOPLEFT', check, 0, 10)
	f:SetText('|cff00ff33OVERRID BY PMINIMAP!|r')

	check:Disable()
	check.Enable = function() end
end

local orig = Minimap_Update
function Minimap_Update(...) orig(...) MinimapZoneText:SetAlpha(0) end

function pMinimap:ADDON_LOADED(event)
	pMinimapDB2 = pMinimapDB2 or {unlocked = false, scale = 0.9, offset = 1, dura = true, coords = false, clock = true, subzone = false, level = 2, strata = 'BACKGROUND', font = 'Interface\\AddOns\\pMinimap\\font.ttf', fontsize = 13, fontflag = 'OUTLINE', colors = {0, 0, 0, 1}}
	pMinimapDB2.unlocked = false

	MinimapZoneText:ClearAllPoints()
	MinimapZoneText:SetPoint('TOP', Minimap, 0, 15)
	MinimapZoneText:SetFont(pMinimapDB2.font, pMinimapDB2.fontsize, pMinimapDB2.fontflag)
	MinimapZoneText:SetDrawLayer('OVERLAY')
	MinimapZoneText:SetParent(Minimap)
	MinimapZoneText:SetAlpha(0)
	MinimapZoneTextButton:Hide()

	Minimap:SetScript('OnEnter', function() if(pMinimapDB2.subzone) then MinimapZoneText:SetAlpha(1) end end)
	Minimap:SetScript('OnLeave', function() if(pMinimapDB2.subzone) then UIFrameFadeOut(MinimapZoneText, 1.5) end end)	

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
	MiniMapTrackingButtonBorder:SetTexture('')
	MiniMapTrackingButton:SetHighlightTexture('')
	MiniMapTrackingIconOverlay:SetTexture('')
	MiniMapTrackingIcon:SetTexCoord(0.065, 0.935, 0.065, 0.935)
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
	MiniMapMailText:SetFont(pMinimapDB2.font, pMinimapDB2.fontsize, pMinimapDB2.fontflag)
	MiniMapMailText:SetPoint('BOTTOM', 0, 2)
	MiniMapMailText:SetText('New Mail!')
	MiniMapMailText:SetTextColor(1, 1, 1)

	MinimapBorder:SetTexture('')
	MinimapBorderTop:Hide()
	MinimapToggleButton:Hide()

	GameTimeFrame:Hide()
	MiniMapWorldMapButton:Hide()
	MiniMapMeetingStoneFrame:SetAlpha(0)
	MiniMapVoiceChatFrame:Hide()
	MiniMapVoiceChatFrame.Show = function() end
	MinimapNorthTag:SetAlpha(0)

	MinimapCluster:SetMovable(true)

	Minimap:SetScale(pMinimapDB2.scale)
	Minimap:SetFrameLevel(pMinimapDB2.level)
	Minimap:SetFrameStrata(pMinimapDB2.strata)
	Minimap:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	Minimap:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = - pMinimapDB2.offset, left = - pMinimapDB2.offset, bottom = - pMinimapDB2.offset, right = - pMinimapDB2.offset}})
	Minimap:SetBackdropColor(unpack(pMinimapDB2.colors))
	Minimap:RegisterForDrag('LeftButton')
	Minimap:SetScript('OnDragStop', function() if(pMinimapDB2.unlocked) then MinimapCluster:StopMovingOrSizing() end end)
	Minimap:SetScript('OnDragStart', function()
		if(pMinimapDB2.unlocked) then
			MinimapCluster:ClearAllPoints()
			MinimapCluster:StartMoving()
		end
	end)

	if(pMinimapDB2.dura and not IsAddOnLoaded('pMinimap_Durability')) then LoadAddOn('pMinimap_Durability') end
	if(pMinimapDB2.coords and not IsAddOnLoaded('pMinimap_Coords')) then LoadAddOn('pMinimap_Coords') end
	if(pMinimapDB2.clock and not IsAddOnLoaded('pMinimap_Clock')) then LoadAddOn('pMinimap_Clock') end
	if(not pMinimapDB2.clock) then TimeManagerClockButton:Hide() end

	pMinimap:UnregisterEvent(event)
end

SlashCmdList['PMMC'] = function(str)
	if(str:find('reset')) then
		Minimap:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
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