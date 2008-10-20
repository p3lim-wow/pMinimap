pMinimap = CreateFrame('Frame', 'pMinimap', UIParent)
pMinimap:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
pMinimap:RegisterEvent('ADDON_LOADED')

function pMinimap.ADDON_LOADED(self, event, name)
	if(name ~= 'pMinimap') then return end
	local db = _G.pMinimapDB or {point = {'TOPRIGHT', UIParent, 'TOPRIGHT', -15, -15}, scale = 0.9, offset = 1, colors = {0, 0, 0}, durability = true, coords = false}

	MinimapBorder:SetTexture()
	MinimapBorderTop:Hide()
	MinimapToggleButton:Hide()

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

	MinimapZoneText:Hide()
	MinimapZoneTextButton:Hide()

	MiniMapTrackingButtonBorder:SetTexture()
	MiniMapTrackingBackground:Hide()
	MiniMapTrackingIconOverlay:SetAlpha(0)
	MiniMapTrackingIcon:SetTexCoord(0.065, 0.935, 0.065, 0.935)
	MiniMapTracking:SetParent(Minimap)
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint('TOPLEFT', -2, 2)

	BattlegroundShine:Hide()
	MiniMapBattlefieldBorder:SetTexture()
	MiniMapBattlefieldFrame:SetParent(Minimap)
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint('TOPRIGHT', -2, -2)

	MiniMapMailBorder:SetTexture()
	MiniMapMailIcon:Hide()
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint('TOP')
	MiniMapMailFrame:SetHeight(8)

	MiniMapMailText = MiniMapMailFrame:CreateFontString(nil, 'OVERLAY')
	MiniMapMailText:SetFont([=[Interface\AddOns\pMinimap\font.ttf]=], 13, 'OUTLINE')
	MiniMapMailText:SetPoint('BOTTOM', 0, 2)
	MiniMapMailText:SetText('New Mail!')
	MiniMapMailText:SetTextColor(1, 1, 1)

	GameTimeFrame:Hide()
	MiniMapWorldMapButton:Hide()
	MiniMapVoiceChatFrame:Hide()
	MiniMapMeetingStoneFrame:Hide()
	MiniMapMeetingStoneFrame:SetAlpha(0)
	MinimapNorthTag:SetAlpha(0)

	self:SetPoint(unpack(db.point))
	self:SetWidth(Minimap:GetWidth() * db.scale)
	self:SetHeight(Minimap:GetHeight() * db.scale)
	self:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=]})
	self:SetBackdropColor(0, 1, 0, 0.5)
	self:SetAlpha(0)
	self:SetMovable(true)
	self:EnableMouse(false)
	self:SetScript('OnMouseDown', function() self:StartMoving() end)
	self:SetScript('OnMouseUp', function() self:StopMovingOrSizing() end)

	Minimap:ClearAllPoints()
	Minimap:SetPoint('CENTER', self)
	Minimap:SetScale(db.scale)
	Minimap:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	Minimap:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = - db.offset, left = - db.offset, bottom = - db.offset, right = - db.offset}})
	Minimap:SetBackdropColor(unpack(db.colors))

	if(db.durability) then
		if(not IsAddOnLoaded('pMinimap_Durability')) then
			LoadAddOn('pMinimap_Durability')
		end
	end

	if(db.coords) then
		if(not IsAddOnLoaded('pMinimap_Coords')) then
			LoadAddOn('pMinimap_Coords')
		end
	end

	if(GetCVar('showClock') == '1') then
		if(not IsAddOnLoaded('pMinimap_Clock')) then
			LoadAddOn('pMinimap_Clock')
		end
	end

	self:UnregisterEvent(event)
end

SlashCmdList['PMMC'] = function()
	if(not IsAddOnLoaded('pMinimap_Config')) then
		LoadAddOn('pMinimap_Config')
	end
	InterfaceOptionsFrame_OpenToCategory('pMinimap')
end
SLASH_PMMC1 = '/pminimap'
SLASH_PMMC2 = '/pmm'

-- http://www.wowwiki.com/GetMinimapShape
function GetMinimapShape() return 'SQUARE' end