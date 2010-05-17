--XGUI settings module for ULX GUI -- by Stickly Man!
--Modify XGUI-based settings.

local xgui_settings = x_makeXpanel{ parent=xgui.null }
x_makebutton{ x=10, y=10, w=150, label="Refresh Server Data...", parent=xgui_settings }.DoClick=function()
	if xgui.isInstalled then  --We can't be in offline mode to do this
		RunConsoleCommand( "xgui", "getdata" )
	end
end
x_makeslider{ x=10, y=35, w=150, label="Fade transition time", min=0.01, max=2, value=xgui.base:GetFadeTime(), decimal=2, parent=xgui_settings, textcolor=color_black }.OnValueChanged = function( self, val )
	if tonumber( val ) < 0.01 then 
		self:SetValue( 0.01 ) 
	else
		xgui.base:SetFadeTime( tonumber( val ) )
		for k, v in pairs( xgui.modules.tab ) do
			if v.name == "Settings" then
				v.panel.tabs:SetFadeTime( tonumber( val ) )
			end
		end
	end
end
table.insert( xgui.modules.setting, { name="XGUI", panel=xgui_settings, icon="gui/silkicons/page_white_wrench", tooltip=nil, access=nil } )