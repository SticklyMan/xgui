--Maps module for ULX GUI -- by Stickly Man!
--Lists maps on server, allows for map voting, changing levels, etc.

function xgui_tab_maps()
	xgui_maps = vgui.Create( "DPanel" )
-----------
	xgmp_maps_list = vgui.Create( "DListView", xgui_maps )
	xgmp_maps_list:SetPos( 10,30 )
	xgmp_maps_list:SetSize( 280,265 )
	--xgmp_maps_list:SetMultiSelect( false )  --Remember to enable/disable multiselect based on admin status..
	xgmp_maps_list:AddColumn( "Map Name" )
-----------
	
	xgui_base:AddSheet( "Maps", xgui_maps, "gui/silkicons/world", false, false )
end

xgui_modules[3]=xgui_tab_maps