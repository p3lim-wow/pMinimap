local locked = true
local LibSimpleOptions = LibStub('LibSimpleOptions-1.0')

local function Options(self, anchor, db)
	local title, subText = self:MakeTitleTextAndSubText('pMinimap', 'These options allow you to change the position of pMinimap')
	local lock = self:MakeToggle(
		'name', 'Toggle Minimap Locked State',
		'description', 'Set whether Minimap is locked or not',
		'default', true,
		'current', locked,
		'setFunc', function(value)
			locked = value
			if(value) then
				local p1, p, p2, x, y = anchor:GetPoint()
				db.point[1] = p1
				db.point[3] = p2
				db.point[4] = x
				db.point[5] = y
				anchor:SetAlpha(0)
				anchor:EnableMouse(false)
			else
				anchor:SetAlpha(1)
				anchor:EnableMouse(true)
			end
		end)
	lock:SetPoint('TOPLEFT', subText, 'BOTTOMLEFT', 0, -8)

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
		'currentTextFunc', function(num)
			return ('%.1f'):format(num)
		end)
	scale:SetPoint('TOPLEFT', lock, 'BOTTOMLEFT', 0, -16)

	local dura = self:MakeToggle(
		'name', 'Toggle Durability',
		'description', 'Set whether backdrop is recolored by durability or not',
		'default', true,
		'current', db.durability,
		'setFunc', function(value)
			self:Refresh()
			db.durability = value
			if(db.backdrop) then
				if(value) then
					pMinimap:RegisterEvent('UPDATE_INVENTORY_ALERTS')
					pMinimap.UPDATE_INVENTORY_ALERTS()
					DurabilityFrame:SetAlpha(0)
				else
					pMinimap:UnregisterEvent('UPDATE_INVENTORY_ALERTS')
					Minimap:SetBackdropColor(unpack(db.colors))
					DurabilityFrame:SetAlpha(1)
				end
			end
		end)
	dura:SetPoint('TOPLEFT', scale, 'BOTTOMLEFT', 0, -8)

	local offset = self:MakeSlider(
		'name', 'Backdrop offset',
		'description', 'Drag to change the bg border size',
		'minText', '-1',
		'maxText', '10',
		'minValue', -1,
		'maxValue', 10,
		'step', 1,
		'default', 1,
		'current', db.offset,
		'setFunc', function(value)
			db.offset = value
			Minimap:SetBackdrop({bgFile = [[Interface\ChatFrame\ChatFrameBackground]], insets = {top = - db.offset, left = - db.offset, bottom = - db.offset, right = - db.offset}})
			Minimap:SetBackdropColor(unpack(db.colors))
		end,
		'currentTextFunc', function(num)
			return ('%.0f'):format(num)
		end)
	offset:SetPoint('TOPLEFT', dura, 'BOTTOMLEFT', 0, -16)

	local color = self:MakeColorPicker(
		'name', "Custom Color",
		'description', "Set custom bg color with a palette",
		'hasAlpha', true,
		'defaultR', 0,
		'defaultG', 0,
		'defaultB', 0,
		'defaultA', 1,
		'getFunc', function() return unpack(db.colors) end,
		'setFunc', function(r, g, b, a)
			db.colors[1] = r
			db.colors[2] = g
			db.colors[3] = b
			db.colors[4] = a
			Minimap:SetBackdropColor(unpack(db.colors))
		end)
	color:SetPoint("TOPLEFT", offset, "BOTTOMLEFT", 0, -8)
end

function pMinimap:PLAYER_ENTERING_WORLD()
	local db = pMinimapDB or {point = {'TOPRIGHT', 'UIParent', 'TOPRIGHT', -15, -15}, scale = 0.9, offset = 1, colors = {0, 0, 0, 1}, durability = true}

	LibSimpleOptions.AddOptionsPanel('pMinimap', function(self) Options(self, pMinimap, db) end)
	LibSimpleOptions.AddSlashCommand('pMinimap', '/pminimap', '/pmm')

	pMinimapDB = db
end