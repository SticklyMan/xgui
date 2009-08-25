--Maps module for ULX GUI -- by Stickly Man!
--Lists maps on server, allows for map voting, changing levels, etc.

xgui_gamemodes = {}
table.insert( xgui_gamemodes, "<default>" )

xgui_maps = x_makeXpanel( )

x_makelabel{ x=10, y=10, label="Server Maps", parent=xgui_maps, textcolor=Color( 0, 0, 0, 255 ) }
x_makelabel{ x=10, y=348, label="Gamemode:", parent=xgui_maps, textcolor=Color( 0, 0, 0, 255 ) }
xgui_cur_map = x_makelabel{ x=185, y=225, label="No Map Selected", parent=xgui_maps, textcolor=Color( 0, 0, 0, 255 ) }

xgui_maps_list = x_makelistview{ x=5, y=30, w=175, h=315, multiselect=true, parent=xgui_maps, headerheight=0 } --Remember to enable/disable multiselect based on admin status?
xgui_maps_list:AddColumn( "Map Name" )
xgui_maps_list.OnRowSelected = function()
	if ( file.Exists( "../materials/maps/" .. xgui_maps_list:GetSelected()[1]:GetColumnText(1) .. ".vmt" ) ) then 
		xgui_maps_disp:SetImage( "maps/" .. xgui_maps_list:GetSelected()[1]:GetColumnText(1) )
	else 
		xgui_maps_disp:SetImage( "maps/noicon.vmt" )
	end
	xgui_cur_map:SetText( xgui_maps_list:GetSelected()[1]:GetColumnText(1) )
	xgui_cur_map:SizeToContents()
end

xgui_maps_disp = vgui.Create( "DImage", xgui_maps )
xgui_maps_disp:SetPos( 185, 30 )
xgui_maps_disp:SetImage( "maps/noicon.vmt" )
xgui_maps_disp:SetSize( 192, 192 )

xgui_maps_thumb = vgui.Create( "DImage", xgui_maps )
xgui_maps_thumb:SetDrawOnTop( true )
xgui_maps_thumb:SetSize( 96, 96 )
xgui_maps_thumb.Think = function( self )
	local x, y = gui.MousePos()
	local px, py = xgui_maps:GetPos()
	x = x - px
	y = y - py - 96
	x = math.Clamp( x, 0, 640 )
	y = math.Clamp( y, 0, 480 )
	self:SetPos( x , y )
end

xgui_select_gamemode = x_makemultichoice{ x=70, y=345, w=110, h=20, parent=xgui_maps }

local xgui_votemap1 = x_makebutton{ x=185, y=245, w=192, h=20, label="Vote to play this map!", parent=xgui_maps }
xgui_votemap1.DoClick = function()
	if xgui_cur_map:GetValue() ~= "No Map Selected" then
		RunConsoleCommand( "ulx", "votemap", xgui_cur_map )
	end
end

local xgui_votemap2 = x_makebutton{ x=185, y=270, w=192, h=20, label="Server-wide vote of selected map(s)", parent=xgui_maps }
xgui_votemap2.DoClick = function()
	if xgui_cur_map:GetValue() ~= "No Map Selected" then
		local xgui_temp = {}
		for k, v in ipairs( xgui_maps_list:GetSelected() ) do
			table.insert( xgui_temp, xgui_maps_list:GetSelected()[k]:GetColumnText(1))
		end
		RunConsoleCommand( "ulx", "votemap2", unpack( xgui_temp ) )
	end
end

local xgui_changemap = x_makebutton{ x=185, y=295, w=192, h=20, label="Force changelevel to this map", parent=xgui_maps }
xgui_changemap.DoClick = function()
	if xgui_cur_map:GetValue() ~= "No Map Selected" then
		if xgui_select_gamemode:GetValue() == "<default>" then
			RunConsoleCommand( "ulx", "map", xgui_cur_map:GetValue() )
		else
			RunConsoleCommand( "ulx", "map", xgui_cur_map:GetValue(), xgui_select_gamemode:GetValue() )
		end
	end
end

local xgui_veto = x_makebutton{ x=185, y=320, w=192, label="Veto a map vote", parent=xgui_maps }
xgui_veto.DoClick = function()
	RunConsoleCommand( "ulx", "veto" )
end

xgui_maps.XGUI_Refresh = function()
	xgui_select_gamemode:Clear()
	xgui_select_gamemode:AddChoice( "<default>" )
	xgui_select_gamemode:SetText( "<default>" )
	for _, v in ipairs( xgui_data.gamemodes ) do
		xgui_select_gamemode:AddChoice( v )
	end
	
	xgui_maps_list:Clear()
	for _,v in ipairs( xgui_data.votemaps ) do
		xgui_maps_list:AddLine( v )
	end
	
	for k, v in pairs( xgui_maps_list.Lines ) do
		function v:OnCursorEntered()
			if ( file.Exists( "../materials/maps/" .. self:GetColumnText( 1 ) .. ".vmt" ) ) then
				xgui_maps_thumb:SetVisible( true )
				xgui_maps_thumb:SetImage( "../materials/maps/" .. self:GetColumnText( 1 ) .. ".vmt" )
			else
				xgui_maps_thumb:SetVisible( false )
			end
		end
		function v:OnCursorExited()
			xgui_maps_thumb:SetVisible( false )
		end
	end
end

xgui_base:AddSheet( "Maps", xgui_maps, "gui/silkicons/world", false, false )