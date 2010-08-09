--XGUI settings module for ULX GUI -- by Stickly Man!
--Modify XGUI-based settings.

local xgui_settings = x_makeXpanel{ parent=xgui.null }
x_makebutton{ x=10, y=10, w=150, label="Refresh XGUI/Server Data", parent=xgui_settings }.DoClick=function()
	if xgui.isInstalled then  --We can't be in offline mode to do this
		xgui.PermissionsChanged( LocalPlayer() )
	end
end
x_makeslider{ x=10, y=35, w=150, label="Fade transition time", min=0.01, max=2, value=xgui.base:GetFadeTime(), decimal=2, parent=xgui_settings, textcolor=color_black }.OnValueChanged = function( self, val )
	if tonumber( val ) < 0.01 then 
		self:SetValue( 0.01 ) 
	else
		xgui.base:SetFadeTime( tonumber( val ) )
		for k, v in pairs( xgui.modules.tab ) do
			if v.name == "Settings" then
				xgui.settings_tabs:SetFadeTime( tonumber( val ) )
			end
		end
	end
end
x_makelabel{ x=10, y=77, label="Infobar color:", textcolor=color_black, parent=xgui_settings }
xgui_settings.infocolor = x_makecolorpicker{ x=10, y=95, w=180, h=150, focuscontrol=true, parent=xgui_settings }
RunConsoleCommand( "colour_r", xgui.infobar.color.r )
RunConsoleCommand( "colour_g", xgui.infobar.color.g )
RunConsoleCommand( "colour_b", xgui.infobar.color.b )
RunConsoleCommand( "colour_a", xgui.infobar.color.a )
xgui_settings.infocolor.Mixer.UpdateConVars = function( self, color )
	self.NextConVarCheck = SysTime() + 0.1
	xgui.infobar.color = color
	self:UpdateConVar( self.m_ConVarR, 'r', color )
	self:UpdateConVar( self.m_ConVarG, 'g', color )
	self:UpdateConVar( self.m_ConVarB, 'b', color )
	self:UpdateConVar( self.m_ConVarA, 'a', color )
end
xgui_settings.infocolor.Mixer.AlphaBar.OnChange = function( ctrl, alpha )
	xgui_settings.infocolor.Mixer:SetColorAlpha( alpha )
	xgui.infobar.color = { r=xgui.infobar.color.r, g=xgui.infobar.color.g, b=xgui.infobar.color.b, a=alpha }
end

table.insert( xgui.modules.setting, { name="XGUI", panel=xgui_settings, icon="gui/silkicons/page_white_wrench", tooltip=nil, access=nil } )