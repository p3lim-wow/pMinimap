local function CreateOptions(self, db)
	local title, sub = self:MakeTitleTextAndSubText('pMinimap', 'These options allow you to customize the looks of pMinimap.')

	self:MakeToggle(
		'name', 'Toggle Minimap locked state',
		'description', 'Set whether Minimap is locked or not',
		'default', true,
		'current', true,
		'setFunc', function(x)
			pMinimap:EnableMouse(x)
			if(x) then
				local p,_,r,x,y = pMinimap:GetPoint()
				db.point[1], db.point[3], db.point[4], db.point[5] = p, r, x, y
				pMinimap:SetAlpha(0)
			else
				pMinimap:SetAlpha(1)
			end
		end
	):SetPoint('TOPLEFT', sub, 'BOTTOMLEFT', 0, -16)

	self:MakeSlider(
		'name', 'Minimap Scale',
		'description', 'Drag to change the minimap scale',
		'default', 0.9,
		'minText', '0.5', 'maxText', '2.5',
		'minValue', 0.5, 'maxValue', 2.5,
		'step', 0.1,
		'current', db.scale,
		'setFunc', function(x)
			db.scale = x
			Minimap:SetScale(x)
			pMinimap:SetWidth(Minimap:GetWidth() * x)
			pMinimap:SetHeight(Minimap:GetHeight() * x)
		end,
		'currentTextFunc', function(num)
			return format('%.1f', num)
		end
	):SetPoint('TOPLEFT', sub, 'BOTTOMLEFT', 0, -56)

	self:MakeToggle(
		'name', 'Toggle durability recoloring',
		'description', 'Set whether backdrop is recolored by durability or not',
		'default', true,
		'current', db.durability,
		'setFunc', function(x)
			db.durability = x
			if(x) then
				pMinimap:RegisterEvent('UPDATE_INVENTORY_ALERTS')
				pMinimap.UPDATE_INVENTORY_ALERTS()
				DurabilityFrame:SetAlpha(0)
			else
				pMinimap:UnregisterEvent('UPDATE_INVENTORY_ALERTS')
				Minimap:SetBackdropColor(unpack(db.colors))
				DurabilityFrame:SetAlpha(1)
			end
		end
	):SetPoint('TOPLEFT', sub, 'BOTTOMLEFT', 0, -86)

	self:MakeSlider(
		'name', 'Backdrop offset',
		'description', 'Drag to change the backdrop border size',
		'default', 1,
		'minText', '0', 'maxText', '10',
		'minValue', 0, 'maxValue', 10,
		'step', 1,
		'current', db.offset,
		'setFunc', function(x)
			db.offset = x
			Minimap:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = - x, left = - x, bottom = - x, right = - x}})
			Minimap:SetBackdropColor(unpack(db.colors))
		end,
		'currentTextFunc', function(num)
			return num
		end
	):SetPoint('TOPLEFT', sub, 'BOTTOMLEFT', 0, -126)

	self:MakeColorPicker(
		'name', 'Custom color',
		'description', 'Click to set custom backdrop color',
		'hasAlpha', true,
		'defaultR', 0,
		'defaultG', 0,
		'defaultB', 0,
		'defaultA', 1,
		'getFunc', function() return unpack(db.colors) end,
		'setFunc', function(r, g, b, a)
			db.colors[1], db.colors[2], db.colors[3], db.colors[4] = r, g, b, a
			Minimap:SetBackdropColor(unpack(db.colors))
		end
	):SetPoint('TOPLEFT', sub, 'BOTTOMLEFT', 0, -156)
end
	
function pMinimap:PLAYER_ENTERING_WORLD(event)
	local db = pMinimapDB or {point = {'TOPRIGHT', 'UIParent', 'TOPRIGHT', -15, -15}, scale = 0.9, offset = 1, colors = {0, 0, 0, 1}, durability = true}

	LibStub('LibSimpleOptions-1.0').AddOptionsPanel('pMinimap', function(self) CreateOptions(self, db) end)
	LibStub('LibSimpleOptions-1.0').AddSlashCommand('pMinimap', '/pminimap', '/pmm')

	self:UnregisterEvent(event)

	pMinimapDB = db
end