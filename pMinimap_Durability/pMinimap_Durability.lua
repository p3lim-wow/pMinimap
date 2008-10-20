function pMinimap.UPDATE_INVENTORY_ALERTS()	local db = pMinimapDB or {colors = {0, 0, 0, 1}}	local maxStatus = 0	for id in pairs(INVENTORY_ALERT_STATUS_SLOTS) do		local status = GetInventoryAlertStatus(id)		if(status > maxStatus) then			maxStatus = status		end	end	local color = INVENTORY_ALERT_COLORS[maxStatus]	if(color) then		Minimap:SetBackdropColor(color.r, color.g, color.b)	else		Minimap:SetBackdropColor(unpack(db.colors))	endendpMinimap:RegisterEvent('UPDATE_INVENTORY_ALERTS')pMinimap.UPDATE_INVENTORY_ALERTS()DurabilityFrame:SetAlpha(0)