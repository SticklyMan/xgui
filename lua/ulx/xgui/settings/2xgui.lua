--XGUI settings module for ULX GUI -- by Stickly Man!
--Modify XGUI-based settings.

local xgui_settings = x_makeXpanel{ parent=xgui.null }

table.insert( xgui.modules.setting, { name="XGUI", panel=xgui_settings, icon="gui/silkicons/page_white_wrench", tooltip=nil, access=nil } )