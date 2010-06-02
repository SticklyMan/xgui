--Players module v2 for ULX GUI -- by Stickly Man!
--Handles all user-based commands, such as kick, slay, ban, etc.

local player = x_makeXpanel{ parent=xgui.null }

table.insert( xgui.modules.tab, { name="Players", panel=player, icon="gui/silkicons/user", tooltip=nil, access=nil } )