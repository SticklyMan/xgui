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
	xgmp_maps_list = x_makelistview{ x=10, y=30, w=175, h=310, multiselect=true, parent=xgui_maps } --Remember to enable/disable multiselect based on admin status?
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
	local xgmp_select_gamemode = x_makebutton{ x=70, y=340, w=115, h=20, label="<default>", parent=xgui_maps }
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
	local xgmp_votemap1 = x_makebutton{ x=195, y=245, w=192, h=20, label="Vote to play this map!", parent=xgui_maps }
	xgmp_votemap1.DoClick = function()
		if xgmp_cur_map ~= "No Map Selected" then
			RunConsoleCommand( "ulx", "votemap", xgmp_cur_map )
		end
	end
------------
	local xgmp_votemap2 = x_makebutton{ x=195, y=270, w=192, h=20, label="Server-wide vote of selected map(s)", parent=xgui_maps }
	xgmp_votemap2.DoClick = function()
		if xgmp_cur_map ~= "No Map Selected" then
			local xgmp_temp = {}
			for k, v in ipairs( xgmp_maps_list:GetSelected() ) do
				table.insert( xgmp_temp, xgmp_maps_list:GetSelected()[k]:GetColumnText(1))
			end
			RunConsoleCommand( "ulx", "votemap2", unpack( xgmp_temp ) )
		end
	end
------------
	local xgmp_changemap = x_makebutton{ x=195, y=295, w=192, h=20, label="Force changelevel to this map", parent=xgui_maps }
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
	local xgmp_veto = x_makebutton{ x=195, y=320, w=192, h=20, label="Veto a map vote", parent=xgui_maps }
	xgmp_veto.DoClick = function()
		RunConsoleCommand( "ulx", "veto" )
	end
------------
	local xgmp_settings_votemap = x_makepanelist{ x=395, y=30, w=185, h=50, parent=xgui_maps, autosize=true }
	
	xgmp_settings_votemap:AddItem( x_makecheckbox{ label="Enable Player Votemaps", convar="ulx_votemapEnabled" } )
	xgmp_settings_votemap:AddItem( x_makeslider{ label="Minimum Time", 	min=0, max=300,  convar="ulx_votemapMintime", tooltip="Time in minutes after a map change before a votemap can be started" } )
	xgmp_settings_votemap:AddItem( x_makeslider{ label="Wait Time", 	min=0, max=60, 	decimal=1, convar="ulx_votemapWaitTime", tooltip="Time in minutes after voting for a map before you can change your vote" } )
	xgmp_settings_votemap:AddItem( x_makeslider{ label="Success Ratio", min=0, max=1, 	decimal=2, convar="ulx_votemapSuccessratio", tooltip="Ratio of votes needed to consider a vote successful.  Votes for map / Total players" } )
	xgmp_settings_votemap:AddItem( x_makeslider{ label="Minimum Votes", min=0, max=10, convar="ulx_votemapMinvotes", tooltip="Minimum number of votes needed to change a level" } )
	xgmp_settings_votemap:AddItem( x_makeslider{ label="Veto Time",		min=0, max=300, convar="ulx_votemapVetotime", tooltip="Time in seconds after a map change before an admin can veto the mapchange" } )
	xgmp_settings_votemap:AddItem( x_makelabel{ label="Server-wide Votemap Settings" } )
	xgmp_settings_votemap:AddItem( x_makeslider{ label="Success Ratio", min=0, max=1, 	decimal=2, convar="ulx_votemap2Successratio", tooltip="Ratio of votes needed to consider a vote successful.  Votes for map / Total players" } )
	xgmp_settings_votemap:AddItem( x_makeslider{ label="Minimum Votes", min=0, max=10, convar="ulx_votemap2Minvotes", tooltip="Minimum number of votes needed to change a level" } )
	
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