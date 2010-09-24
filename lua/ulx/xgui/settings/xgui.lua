--XGUI settings module for ULX GUI -- by Stickly Man!
--Modify XGUI-based settings.

local xgui_settings = xlib.makeXpanel{ parent=xgui.null }
xlib.makebutton{ x=10, y=10, w=150, label="Refresh XGUI Modules", parent=xgui_settings }.DoClick=function()
	xgui.PermissionsChanged( LocalPlayer() )
end
xlib.makebutton{ x=10, y=30, w=150, label="Refresh Server Data", parent=xgui_settings }.DoClick=function( self )
	if xgui.isInstalled then  --We can't be in offline mode to do this
		self:SetDisabled( true )
		RunConsoleCommand( "xgui", "getdata" )
		timer.Simple( 5, function() self:SetDisabled( false ) end )
	end
end
xlib.makeslider{ x=10, y=55, w=150, label="Anim transition time", max=2, value=xgui.settings.animTime, decimal=2, parent=xgui_settings, textcolor=color_black }.OnValueChanged = function( self, val )
	val = tonumber( val )
	if val < 0 then 
		self:SetValue( 0 ) 
	else
		xgui.settings.animTime = val
		xgui.base:SetFadeTime( val )
		xgui.settings_tabs:SetFadeTime( val )
	end
end
xlib.makecheckbox{ x=10, y=97, w=150, label="Show Startup Messages", value=xgui.settings.showLoadMsgs, parent=xgui_settings, textcolor=color_black }.OnChange = function( self, bVal )
	xgui.settings.showLoadMsgs = bVal
end
xlib.makelabel{ x=10, y=117, label="Infobar color:", textcolor=color_black, parent=xgui_settings }
xgui_settings.infocolor = xlib.makecolorpicker{ x=10, y=135, w=180, h=150, focuscontrol=true, parent=xgui_settings }
RunConsoleCommand( "colour_r", xgui.settings.infoColor.r )
RunConsoleCommand( "colour_g", xgui.settings.infoColor.g )
RunConsoleCommand( "colour_b", xgui.settings.infoColor.b )
RunConsoleCommand( "colour_a", xgui.settings.infoColor.a )
xgui_settings.infocolor.Mixer.UpdateConVars = function( self, color )
	self.NextConVarCheck = SysTime() + 0.1
	xgui.settings.infoColor = color
	self:UpdateConVar( self.m_ConVarR, 'r', color )
	self:UpdateConVar( self.m_ConVarG, 'g', color )
	self:UpdateConVar( self.m_ConVarB, 'b', color )
	self:UpdateConVar( self.m_ConVarA, 'a', color )
end
xgui_settings.infocolor.Mixer.AlphaBar.OnChange = function( ctrl, alpha )
	xgui_settings.infocolor.Mixer:SetColorAlpha( alpha )
	xgui.settings.infoColor = { r=xgui.settings.infoColor.r, g=xgui.settings.infoColor.g, b=xgui.settings.infoColor.b, a=alpha }
end
xlib.makebutton{ x=10, y=295, w=150, label="Save Clientside Settings", parent=xgui_settings }.DoClick=function()
	xgui.saveClientSettings()
end

----------------
--SKIN MANAGER--
----------------
--Include the extra skins in case nothing else has included them.
for _, file in ipairs( file.FindInLua( "skins/*.lua" ) ) do
	include( "skins/" .. file )
end
xlib.makelabel{ x=10, y=253, label="Derma Theme:", textcolor=color_black, parent=xgui_settings }
xgui_settings.skinselect = xlib.makemultichoice{ x=10, y=270, w=150, parent=xgui_settings }
if not derma.SkinList[xgui.settings.skin] then
	xgui.settings.skin = "Default"
	xgui_settings.skinselect:SetText( derma.SkinList.Default.PrintName )
else
	xgui_settings.skinselect:SetText( derma.SkinList[xgui.settings.skin].PrintName )
end
xgui.base.refreshSkin = true
xgui_settings.skinselect.OnSelect = function( self, index, value, data )
	xgui.settings.skin = data
	xgui.base:SetSkin( data )
end
for skin, skindata in pairs( derma.SkinList ) do
	xgui_settings.skinselect:AddChoice( skindata.PrintName, skin )
end

table.insert( xgui.modules.setting, { name="XGUI", panel=xgui_settings, icon="gui/silkicons/page_white_wrench", tooltip=nil, access=nil } )