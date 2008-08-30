local _G = getfenv(0)
local LibSimpleOptions = LibStub('LibSimpleOptions-1.0')

local function Options(self, anchor, db)
	local title, subText = self:MakeTitleTextAndSubText('pMinimap', 'These options allow you to change the position of pMinimap')

	local lock = self:MakeToggle(
		'name', 'Toggle Minimap Locked State',
		'description', 'Set whether Minimap is locked or not',
		'default', true,
		'current', db.locked,
		'setFunc', function(value)
			db.locked = value
			if(value) then
				local p1, p, p2, x, y = anchor:GetPoint()
				db.p1 = p1
				db.p2 = p2
				db.x = x
				db.y = y
				anchor:SetAlpha(0)
				anchor:SetMovable(value)
				anchor:SetFrameStrata('BACKGROUND')
			else
				anchor:SetAlpha(1)
				anchor:SetMovable(value)
				anchor:SetFrameStrata('DIALOG')
			end
		end)
	lock:SetPoint('TOPLEFT', subText, 'BOTTOMLEFT', 0, -8)

	local reset = self:MakeButton(
		'name', 'Reset Position',
		'description', 'Reset Minimap position to default',
		'func', function()
			db.p1 = 'TOPRIGHT'
			db.p2 = 'TOPRIGHT'
			db.x = -15
			db.y = -15
			db.locked = true
			anchor:ClearAllPoints()
			anchor:SetPoint(db.p1, UIParent, db.p2, db.x, db.y)
			self:Refresh()
		end)
	reset:SetPoint('TOPLEFT', lock, 'BOTTOMLEFT', 0, -8)

	local scale = self:MakeSlider(
		'name', 'Minimap Scale',
		'description', 'Drag to change the Minimap scale',
		'minText', '0.4',
		'maxText', '2.4',
		'minValue', 0.4,
		'maxValue', 2.4,
		'step', 0.1,
		'default', 0.9,
		'current', db.scale,
		'setFunc', function(value)
			db.scale = value
			Minimap:SetScale(value)
			anchor:SetWidth(Minimap:GetWidth() * value)
			anchor:SetHeight(Minimap:GetHeight() * value)
		end,
		'currentTextFunc', function(num) return ('%.1f'):format(num) end)
	scale:SetPoint('TOPLEFT', reset, 'BOTTOMLEFT', 0, -16)

	local dura = self:MakeToggle(
		'name', 'Toggle Durability',
		'description', 'Set whether backdrop is recolored by durability or not',
		'default', true,
		'current', db.durability,
		'setFunc', function(value)
			db.durability = value
			if(value) then
				pMinimap:RegisterEvent('UPDATE_INVENTORY_ALERTS')
				DurabilityFrame:SetAlpha(0)
			else
				pMinimap:UnregisterEvent('UPDATE_INVENTORY_ALERTS')
				pMinimap:SetBackdropColor(0, 0, 0)
				DurabilityFrame:SetAlpha(1)
			end
		end)
	dura:SetPoint('TOPLEFT', scale, 'BOTTOMLEFT', 0, -8)
end

local function OnEvent(self, name)
	if(name == 'pMinimap') then
		local db = _G.pMinimapDB
		if(not db) then
			db = { p1 = 'TOPRIGHT', p2 = 'TOPRIGHT', x = -15, y = -15, scale = 0.9, locked = true, durability = true }
			_G.pMinimapDB = db
		end

		db.locked = true

		local anchor = CreateFrame('Frame', nil, UIParent)
		anchor:SetFrameStrata('BACKGROUND')
		anchor:SetWidth(Minimap:GetWidth() * db.scale)
		anchor:SetHeight(Minimap:GetHeight() * db.scale)
		anchor:SetAlpha(0)
		anchor:SetBackdrop({bgFile='Interface\\ChatFrame\\ChatFrameBackground'})
		anchor:SetBackdropColor(0, 1, 0, 0.5)
		anchor:SetScript('OnMouseDown', function(self) self:StartMoving() end)
		anchor:SetScript('OnMouseUp', function(self) self:StopMovingOrSizing() end)
		anchor:SetPoint(db.p1, UIParent, db.p2, db.x, db.y)
		anchor:EnableMouse(db.locked and false or true)

		Minimap:ClearAllPoints()
		Minimap:SetPoint('CENTER', anchor)
		Minimap:SetScale(db.scale)

		LibSimpleOptions.AddOptionsPanel('pMinimap', function(self) Options(self, anchor, db) end)
		LibSimpleOptions.AddSlashCommand('pMinimap', '/pminimap', '/pmm')

		self:UnregisterEvent('ADDON_LOADED')
	end
end

local event = CreateFrame('Frame')
event:RegisterEvent('ADDON_LOADED')
event:SetScript('OnEvent', function(self, event, ...) OnEvent(self, ...) end)