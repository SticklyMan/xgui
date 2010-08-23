--XGUI settings module for ULX GUI -- by Stickly Man!
--Modify XGUI-based settings.

local xgui_settings = x_makeXpanel{ parent=xgui.null }
x_makebutton{ x=10, y=10, w=150, label="Refresh XGUI Modules", parent=xgui_settings }.DoClick=function()
	xgui.PermissionsChanged( LocalPlayer() )
end
x_makebutton{ x=10, y=30, w=150, label="Refresh Server Data", parent=xgui_settings }.DoClick=function( self )
	if xgui.isInstalled then  --We can't be in offline mode to do this
		self:SetDisabled( true )
		RunConsoleCommand( "xgui", "getdata" )
		timer.Simple( 5, function() self:SetDisabled( false ) end )
	end
end
x_makeslider{ x=10, y=55, w=150, label="Anim transition time", min=0.01, max=2, value=xgui.settings.animTime, decimal=2, parent=xgui_settings, textcolor=color_black }.OnValueChanged = function( self, val )
	val = tonumber( val )
	if val < 0.01 then 
		self:SetValue( 0.01 ) 
	else
		xgui.settings.animTime = val
		xgui.base:SetFadeTime( val )
		xgui.settings_tabs:SetFadeTime( val )
	end
end
x_makecheckbox{ x=10, y=97, w=150, label="Show Startup Messages", value=xgui.settings.showLoadMsgs, parent=xgui_settings, textcolor=color_black }.OnChange = function( self, bVal )
	xgui.settings.showLoadMsgs = bVal
end
x_makelabel{ x=10, y=117, label="Infobar color:", textcolor=color_black, parent=xgui_settings }
xgui_settings.infocolor = x_makecolorpicker{ x=10, y=135, w=180, h=150, focuscontrol=true, parent=xgui_settings }
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
x_makebutton{ x=10, y=250, w=150, label="Save Clientside Settings", parent=xgui_settings }.DoClick=function()
	xgui.saveClientSettings()
end

table.insert( xgui.modules.setting, { name="XGUI", panel=xgui_settings, icon="gui/silkicons/page_white_wrench", tooltip=nil, access=nil } )