--Sandbox settings module for ULX GUI -- by Stickly Man!
--Defines limits and sbox_ specific settings for the sandbox gamemode.

local sbox_settings = x_makeXpanel{ parent=xgui.null }

table.insert( xgui.modules.gamemode, { name="Sandbox", panel=sbox_settings, icon="gui/silkicons/wrench", tooltip=nil, access="xgui_gmsettings" } )