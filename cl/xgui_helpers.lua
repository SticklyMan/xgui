--XGUI helpers  -- by Stickly Man!
--A bunch of functions to help with creating Derma elements-- Makes all the other code look nicer

function x_makeslider( label, min, max, decimal, convar, tooltip )
	local xgui_temp = vgui.Create( "DNumSlider" )
	xgui_temp:SetText( label )
	xgui_temp:SizeToContents()
	xgui_temp:SetMin( min )
	xgui_temp:SetMax( max )
	xgui_temp:SetDecimals( decimal )
	xgui_temp:SetConVar( convar )
	xgui_temp:SetTooltip( tooltip )
	return xgui_temp
end

function x_makecheckbox( x, y, label, convar, tooltip, parent )
	local xgui_temp = vgui.Create( "DCheckBoxLabel", parent )
	xgui_temp:SetPos( x, y )
	xgui_temp:SetText( label )
	xgui_temp:SizeToContents()
	if convar ~= nil then xgui_temp:SetConVar( convar ) end
	if tooltip ~= nil then xgui_temp:SetTooltip( tooltip ) end
	return xgui_temp
end

function x_makelabel( label, x, y, parent )
	local xgui_temp = vgui.Create( "DLabel", parent )
	xgui_temp:SetPos( x, y )
	xgui_temp:SetText( label )
	xgui_temp:SizeToContents()
	return xgui_temp
end

function x_makepanelist( x, y, w, h, spacing, padding, parent )
	local xgui_temp = vgui.Create( "DPanelList", parent )
	xgui_temp:SetPos( x,y )
	xgui_temp:SetSize( w, h )
	xgui_temp:SetSpacing( spacing )
	xgui_temp:SetPadding( padding )
	xgui_temp:EnableVerticalScrollbar( true )
	xgui_temp:SetAutoSize( true )
	return xgui_temp
end

function x_makebutton( label, x, y, w, h, parent )
	local xgui_temp = vgui.Create( "DButton", parent )
	xgui_temp:SetSize( w, h )
	xgui_temp:SetPos( x, y )
	xgui_temp:SetText( label )
	return xgui_temp
end

function x_makeframepopup( label, w, h )
	local xgui_temp = vgui.Create( "DFrame" )
	xgui_pm:SetSize( w, h )
	xgui_pm:Center()
	xgui_pm:SetTitle( label )
	xgui_pm:MakePopup()
	return xgui_temp
end