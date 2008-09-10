--[[-------------------------------------------------------------------------
  Copyright (c) 2006, Trond A Ekseth
  Copyright (c) 2008, Adrian L Lange
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

      * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials provided
        with the distribution.
      * Neither the name of pMinimap nor the names of its contributors
        may be used to endorse or promote products derived from this
        software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
---------------------------------------------------------------------------]]


function GetMinimapShape() return 'SQUARE' end

local addon = CreateFrame('Frame', 'pMinimap', Minimap)
local frames = {
	MinimapBorder,
	MinimapBorderTop,
	MinimapToggleButton,
	MinimapZoomIn,
	MinimapZoomOut,
	MinimapZoneText,
	MinimapZoneTextButton,
	MiniMapTrackingBackground,
	MiniMapBattlefieldBorder,
	MiniMapMeetingStoneFrame,
	MiniMapVoiceChatFrame,
	MiniMapWorldMapButton,
	MiniMapMailBorder,
	MiniMapMailIcon,
	BattlegroundShine,
	GameTimeFrame,
}

function addon.PLAYER_LOGIN(self)
	local db = _G.pMinimapDB

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript('OnMouseWheel', function(self, dir)
		if(dir > 0) then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end)

	if(select(4, GetBuildInfo()) >= 3e4) then
		MiniMapTrackingIconOverlay:SetAlpha(0)
		MiniMapTrackingButtonBorder:Hide()
	else
		MiniMapTrackingBorder:Hide()
	end
	MiniMapTrackingIcon:SetTexCoord(0.065, 0.935, 0.065, 0.935)
	MiniMapTracking:SetParent(Minimap)
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint('TOPLEFT', -2, 2)

	MiniMapBattlefieldFrame:SetParent(Minimap)
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint('TOPRIGHT', -2, -2)

	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint('TOP')
	MiniMapMailFrame:SetHeight(8)

	MiniMapMailText = MiniMapMailFrame:CreateFontString(nil, 'OVERLAY')
	MiniMapMailText:SetFont('Interface\\AddOns\\pMinimap\\font.ttf', 13, 'OUTLINE')
	MiniMapMailText:SetPoint('BOTTOM', 0, 2)
	MiniMapMailText:SetText('New Mail!')
	MiniMapMailText:SetTextColor(1, 1, 1)

	MinimapNorthTag:SetAlpha(0)
	MiniMapMeetingStoneFrame:SetAlpha(0)

	Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')
	Minimap:SetFrameStrata('LOW')

	self:SetFrameStrata('BACKGROUND')
	self:SetAllPoints(Minimap)
	self:SetBackdrop({bgFile = 'Interface\\ChatFrame\\ChatFrameBackground', insets = {top = -1, left = -1, bottom = -1, right = -1}})
	self:SetBackdropColor(0, 0, 0, 0)

	if(db.backdrop) then
		self:SetBackdropColor(0, 0, 0, 1)

		if(db.durability) then
			self:RegisterEvent('UPDATE_INVENTORY_ALERTS')
			DurabilityFrame:SetAlpha(0)
		end
	end

	for i,obj in pairs(frames) do obj:Hide() end
end

function addon.UPDATE_INVENTORY_ALERTS(self)
	local maxStatus = 0
	for id in pairs(INVENTORY_ALERT_STATUS_SLOTS) do
		local status = GetInventoryAlertStatus(id)
		if(status > maxStatus) then
			maxStatus = status
		end
	end

	local color = INVENTORY_ALERT_COLORS[maxStatus]
	if(color) then
		self:SetBackdropColor(color.r, color.g, color.b, 1)
	else
		self:SetBackdropColor(0, 0, 0, 1)
	end
end

addon:SetScript('OnEvent', function(self, event, ...) self[event](self) end)
addon:RegisterEvent('PLAYER_LOGIN')