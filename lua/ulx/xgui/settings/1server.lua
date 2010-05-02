--Server settings module for ULX GUI -- by Stickly Man!
--Modify server and ULX based settings.

local server_settings = x_makeXpanel{ parent=xgui.null }

table.insert( xgui.modules.setting, { name="Server", panel=server_settings, icon="gui/silkicons/wrench", tooltip=nil, access="xgui_svsettings" } )