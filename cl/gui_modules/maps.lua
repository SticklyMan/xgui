--Maps module for ULX GUI -- by Stickly Man!
--Lists maps on server, allows for map voting, changing levels, etc.
local xgmp_gamemodes = {}
local xgmp_cur_map = "No Map Selected"

function xgui_tab_maps()
	xgui_maps = vgui.Create( "DPanel" )
-----------
	xgui_maps.Paint = function()
		surface.SetDrawColor( 191, 191, 191, 255 )
		surface.DrawRect( 0, 0, 590, 390 )
		surface.SetTextColor( 0, 0, 0, 255 )
		surface.SetTextPos( 10, 10 )
		surface.DrawText( "Server Maps" )
		surface.SetTextPos( 195, 225 )
		surface.DrawText( xgmp_cur_map )
	end
-----------
	xgmp_maps_list = vgui.Create( "DListView", xgui_maps )
	xgmp_maps_list:SetPos( 10,30 )
	xgmp_maps_list:SetSize( 175,310 )
	--xgmp_maps_list:SetMultiSelect( false )  --Remember to enable/disable multiselect based on admin status..
	xgmp_maps_list:AddColumn( "Map Name" )
	xgmp_maps_list.OnRowSelected = function()
	 	if ( file.Exists( "../materials/maps/" .. xgmp_maps_list:GetSelected()[1]:GetColumnText(1) .. ".vmt" ) ) then 
			xgmp_maps_disp:SetImage( "maps/" .. xgmp_maps_list:GetSelected()[1]:GetColumnText(1) )
 		else 
 			xgmp_maps_disp:SetImage( "maps/noicon.vmt" )
 		end
		xgmp_cur_map = xgmp_maps_list:GetSelected()[1]:GetColumnText(1)
	end
-----------
	xgmp_maps_disp = vgui.Create( "DImage", xgui_maps )
	xgmp_maps_disp:SetPos( 195, 30 )
	xgmp_maps_disp:SetImage( "maps/noicon.vmt" )
	xgmp_maps_disp:SetSize( 192, 192 )
-----------
	local xgmp_select_gamemode = vgui.Create( "DButton", xgui_maps ) -- having issues, will fix later
	xgmp_select_gamemode:SetPos( 10,340 )
	xgmp_select_gamemode:SetSize( 175,20 )
	xgmp_select_gamemode:SetText( "<default>" )
	xgmp_select_gamemode.DoClick = function()
		xgmp_list_gamemodes = DermaMenu()
		xgmp_list_gamemodes:SetParent( xgui_maps )
		table.sort( xgmp_gamemodes )
		for _, v in ipairs( xgmp_gamemodes ) do
			xgmp_list_gamemodes:AddOption( v, function() xgmp_select_gamemode:SetText( v ) end )
		end
		xgmp_list_gamemodes:Open()
	end
-----------
	local xgmp_votemap1 = vgui.Create( "DButton", xgui_maps )
	xgmp_votemap1:SetSize( 192, 20 )
	xgmp_votemap1:SetPos( 195, 245 )
	xgmp_votemap1:SetText( "Vote to play this map!" )
	xgmp_votemap1.DoClick = function()
		if xgmp_cur_map ~= "No Map Selected" then
			RunConsoleCommand( "ulx", "votemap", xgmp_cur_map )
		end
	end
------------
	local xgmp_votemap2 = vgui.Create( "DButton", xgui_maps )
	xgmp_votemap2:SetSize( 192, 20 )
	xgmp_votemap2:SetPos( 195, 270 )
	xgmp_votemap2:SetText( "Server-wide vote of selected map(s)" )
	xgmp_votemap2.DoClick = function()
		if xgmp_cur_map ~= "No Map Selected" then
			local xgmp_temp = {}
			for k, v in ipairs(xgmp_maps_list:GetSelected()) do
				table.insert( xgmp_temp, xgmp_maps_list:GetSelected()[k]:GetColumnText(1))
			end
			RunConsoleCommand( "ulx", "votemap2", unpack( xgmp_temp ) )
		end
	end
------------
	local xgmp_changemap = vgui.Create( "DButton", xgui_maps )
	xgmp_changemap:SetSize( 192, 20 )
	xgmp_changemap:SetPos( 195, 295 )
	xgmp_changemap:SetText( "Force changelevel to this map" )
	xgmp_changemap.DoClick = function()
		if xgmp_cur_map ~= "No Map Selected" then
			if xgmp_select_gamemode:GetValue() == "<default>" then
				RunConsoleCommand( "ulx", "map", xgmp_cur_map )
			else
				RunConsoleCommand( "ulx", "map", xgmp_cur_map, xgmp_select_gamemode:GetValue() )
			end
		end
	end
------------
	local xgmp_veto = vgui.Create( "DButton", xgui_maps )
	xgmp_veto:SetSize( 192, 20 )
	xgmp_veto:SetPos( 195, 320 )
	xgmp_veto:SetText( "Veto a map vote" )
	xgmp_veto.DoClick = function()
		RunConsoleCommand( "ulx", "veto" )
	end
------------
	for _, v in pairs( ulx.maps ) do
		//Filters out any pointless levels
		if ( !string.find( v, "background" ) && !string.find( v, "^test_" ) && !string.find( v, "^styleguide" ) && !string.find( v, "^devtest" ) && !string.find( v, "intro" ) ) then 
			xgmp_maps_list:AddLine( v )
		end
	end
	
	RunConsoleCommand( "xgui_requestgamemodes" )
	xgui_base:AddSheet( "Maps", xgui_maps, "gui/silkicons/world", false, false )
end

local function xgui_gamemode_recieve( um )
	table.insert( xgmp_gamemodes, um:ReadString() )
end
usermessage.Hook( "xgui_gamemode_rcv", xgui_gamemode_recieve )

local function xgui_gamemode_clear( um )
	xgmp_gamemodes = {}
	table.insert( xgmp_gamemodes, "<default>" )
end
usermessage.Hook( "xgui_gamemode_clr", xgui_gamemode_clear )

xgui_modules[3]=xgui_tab_maps