local _, ns = ...

local LSM = LibStub('LibSharedMedia-3.0')
local OBJECTS = {
	Zone = 'MinimapZoneTextButton',
	Difficulty = 'MiniMapInstanceDifficulty',
	Battlefield = 'MiniMapBattlefieldFrame',
	Dungeon = 'MiniMapLFGFrame',
	Tracking = 'MiniMapTracking',
	Clock = 'TimeManagerClockButton',
	Mail = 'MiniMapMailFrame',
}

function ns.UpdateObjects()
	for name, setting in pairs(pMinimapDB.objects) do
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

function ns.UpdateCore()
	Minimap:SetScale(pMinimapDB.minimap.scale)
	Minimap:SetFrameStrata(pMinimapDB.minimap.strata)
	Minimap:SetFrameLevel(pMinimapDB.minimap.level)

	local size = pMinimapDB.minimap.borderSize
	Minimap:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {left = -size, right = -size, top = -size, bottom = -size}})
	Minimap:SetBackdropColor(unpack(pMinimapDB.minimap.borderColors))
end

function ns.UpdateFont()
	local font, size = LSM:Fetch('font', pMinimapDB.font.name), pMinimapDB.font.size
	local flag = pMinimapDB.font.shadow .. (pMinimapDB.font.monochrome and 'MONOCHROME' or '')

	MinimapZoneText:SetFont(font, size, flag)
	TimeManagerClockTicker:SetFont(font, size, flag)
end


local function AddConfig(name, func)
	local group = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
	group.name = name
	group:SetScript('OnShow', func)
	group:HookScript('OnShow', function(self) self:SetScript('OnShow', nil) end)

	if(name ~= 'pMinimap') then
		group.parent = 'pMinimap'
		group.addonname = 'pMinimap'
	end

	InterfaceOptions_AddCategory(group)
end

AddConfig('pMinimap', function(self)
	local scale = ns.slider(self, 'Scale', '%.1f', pMinimapDB.minimap.scale, 0.5, 2.5, 0.1, 'TOPLEFT', 30, -30)
	scale:HookScript('OnValueChanged', function(frame, value)
		pMinimapDB.minimap.scale = value
		ns.UpdateCore()
	end)

	local level = ns.slider(self, 'Frame Level', '%d', pMinimapDB.minimap.level, 0, 10, 1, 'TOPRIGHT', -30, -30)
	level:HookScript('OnValueChanged', function(frame, value)
		pMinimapDB.minimap.level = value
		ns.UpdateCore()
	end)

	local strata = ns.dropdown(self, 'Frame Strata', pMinimapDB.minimap.strata, {'HIGH', 'MEDIUM', 'LOW', 'BACKGROUND'},
		function(self)
			pMinimapDB.minimap.strata = self.value
			ns.UpdateCore()
		end)
	strata:SetPoint('TOPRIGHT', -10, -80)

	local background1 = self:CreateTexture(nil, 'BACKGROUND')
	background1:SetPoint('TOPLEFT', scale, -20, 20)
	background1:SetPoint('BOTTOMRIGHT', strata, 0, -5)
	background1:SetTexture(0, 0, 0, 0.5)

	local borderSize = ns.slider(self, 'Border Thickness', '%d', pMinimapDB.minimap.borderSize, 0, 10, 1, 'LEFT', 30, 0)
	borderSize:HookScript('OnValueChanged', function(frame, value)
		pMinimapDB.minimap.borderSize = value
		ns.UpdateCore()
	end)

	local borderColor = ns.palette(self, 'Border Color', pMinimapDB.minimap.borderColors, 'RIGHT', -130, 0)

	local background2 = self:CreateTexture(nil, 'BACKGROUND')
	background2:SetPoint('TOPLEFT', borderSize, -20, 20)
	background2:SetPoint('BOTTOMRIGHT', borderColor, 120, -20)
	background2:SetTexture(0, 0, 0, 0.5)
	
	ns.dropdown(self, 'Font', pMinimapDB.font.name, LSM:List('font'), 
		function(self)
			pMinimapDB.font.name = self.value
			ns.UpdateFont()
		end
	):SetPoint('BOTTOMLEFT', 10, 20)

	local size = ns.slider(self, 'Font Size', '%d', pMinimapDB.font.size, 6, 36, 1, 'BOTTOMLEFT', 30, 80)
	size:HookScript('OnValueChanged', function(frame, value)
		pMinimapDB.font.size = value
		ns.UpdateFont()
	end)

	local shadow = ns.dropdown(self, 'Font Shadow', pMinimapDB.font.shadow, {'OUTLINE', 'THICKOUTLINE', 'NONE'},
		function(self)
			pMinimapDB.font.shadow = self.value
			ns.UpdateFont()
		end)
	shadow:SetPoint('BOTTOMRIGHT', -10, 20)

	local monochrome = ns.checkbox(self, 'Monochrome', 'BOTTOMRIGHT', -140, 75)
	monochrome:SetChecked(pMinimapDB.font.monochrome)
	monochrome:SetScript('OnClick', function()
		pMinimapDB.font.monochrome = not pMinimapDB.font.monochrome
		ns.UpdateFont()
	end)

	local background3 = self:CreateTexture(nil, 'BACKGROUND')
	background3:SetPoint('TOPLEFT', size, -20, 20)
	background3:SetPoint('BOTTOMRIGHT', shadow, 0, -5)
	background3:SetTexture(0, 0, 0, 0.5)
end)

AddConfig('Objects', function(self)
	local points = {'TOPLEFT', 'TOP', 'TOPRIGHT', 'LEFT', 'CENTER', 'RIGHT', 'BOTTOMLEFT', 'BOTTOM', 'BOTTOMRIGHT'}
	local offset = 25

	for name, setting in pairs(pMinimapDB.objects) do 
		local shown = ns.checkbox(self, name, 'TOPLEFT', 25, -offset)
		shown:SetChecked(setting.shown)
		shown:SetScript('OnClick', function()
			setting.shown = not setting.shown
			ns.UpdateObjects()
		end)
		
		local position = ns.dropdown(self, name..' Position', setting.point, points,
			function(self)
				setting.point = self.value
				ns.UpdateObjects()
			end)
		position:SetPoint('TOPRIGHT', -10, -offset)

		local background = self:CreateTexture(nil, 'BACKGROUND')
		background:SetPoint('TOPLEFT', shown, -15, 15)
		background:SetPoint('BOTTOMRIGHT', position)
		background:SetTexture(0, 0, 0, 0.4)

		offset = offset + 60
	end
end)
