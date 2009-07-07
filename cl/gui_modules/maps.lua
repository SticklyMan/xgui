--Maps module for ULX GUI -- by Stickly Man!
--Lists maps on server, allows for map voting, changing levels, etc.

local xgmp_cur_map
local xgmp_gamemodes

function xgui_tab_maps()
	xgmp_cur_map = "No Map Selected"
	xgmp_gamemodes = {}
	table.insert( xgmp_gamemodes, "<default>" )
	
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
		surface.SetTextPos( 10, 343 )
		surface.DrawText( "Gamemode:" )
	end
-----------
	xgmp_maps_list = x_makelistview( 10, 30, 175, 310, true, xgui_maps ) --Remember to enable/disable multiselect based on admin status?
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
	local xgmp_select_gamemode = x_makebutton( "<default>", 70, 340, 115, 20, xgui_maps )
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
	local xgmp_votemap1 = x_makebutton( "Vote to play this map!", 195, 245, 192, 20, xgui_maps )
	xgmp_votemap1.DoClick = function()
		if xgmp_cur_map ~= "No Map Selected" then
			RunConsoleCommand( "ulx", "votemap", xgmp_cur_map )
		end
	end
------------
	local xgmp_votemap2 = x_makebutton( "Server-wide vote of selected map(s)", 195, 270, 192, 20, xgui_maps )
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
	local xgmp_changemap = x_makebutton( "Force changelevel to this map", 195, 295, 192, 20, xgui_maps )
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
	local xgmp_veto = x_makebutton( "Veto a map vote", 195, 320, 192, 20, xgui_maps )
	xgmp_veto.DoClick = function()
		RunConsoleCommand( "ulx", "veto" )
	end
------------
	local xgmp_settings_votemap = x_makepanelist( 395, 30, 185, 50, 5, 5, xgui_maps )
	
	xgmp_settings_votemap:AddItem( x_makecheckbox( 0, 0, "Enable Player Votemaps", "ulx_votemapEnabled" ) )
	xgmp_settings_votemap:AddItem( x_makeslider( "Minimum Time", 0, 300, 0, "ulx_votemapMintime", "Time in minutes after a map change before a votemap can be started" ) )
	xgmp_settings_votemap:AddItem( x_makeslider( "Wait Time", 0, 60, 1, "ulx_votemapWaitTime", "Time in minutes after voting for a map before you can change your vote" ) )
	xgmp_settings_votemap:AddItem( x_makeslider( "Success Ratio", 0, 1, 2, "ulx_votemapSuccessratio", "Ratio of votes needed to consider a vote successful.  Votes for map / Total players" ) )
	xgmp_settings_votemap:AddItem( x_makeslider( "Minimum Votes", 0, 10, 0, "ulx_votemapMinvotes", "Minimum number of votes needed to change a level" ) )
	xgmp_settings_votemap:AddItem( x_makeslider( "Veto Time", 0, 300, 0, "ulx_votemapVetotime", "Time in seconds after a map change before an admin can veto the mapchange" ) )
	xgmp_settings_votemap:AddItem( x_makelabel( "Server-wide Votemap Settings" ) )
	xgmp_settings_votemap:AddItem( x_makeslider( "Success Ratio", 0, 1, 2, "ulx_votemap2Successratio", "Ratio of votes needed to consider a vote successful.  Votes for map / Total players" ) )
	xgmp_settings_votemap:AddItem( x_makeslider( "Minimum Votes", 0, 10, 0, "ulx_votemap2Minvotes", "Minimum number of votes needed to change a level" ) )
	
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

xgui_modules[3]=xgui_tab_maps