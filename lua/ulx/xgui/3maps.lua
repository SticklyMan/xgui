--Maps module for ULX GUI -- by Stickly Man!
--Lists maps on server, allows for map voting, changing levels, etc.

xgui_gamemodes = { "<default>" }

local xgui_maps = x_makeXpanel{ parent=xgui.null }

x_makelabel{ x=10, y=10, label="Server Maps", parent=xgui_maps, textcolor=color_black }
x_makelabel{ x=10, y=348, label="Gamemode:", parent=xgui_maps, textcolor=color_black }
xgui_maps.curmap = x_makelabel{ x=185, y=225, label="No Map Selected", parent=xgui_maps, textcolor=color_black }

xgui_maps.list = x_makelistview{ x=5, y=30, w=175, h=315, multiselect=true, parent=xgui_maps, headerheight=0 } --Remember to enable/disable multiselect based on admin status?
xgui_maps.list:AddColumn( "Map Name" )
xgui_maps.list.OnRowSelected = function()
	if ( file.Exists( "../materials/maps/" .. xgui_maps.list:GetSelected()[1]:GetColumnText(1) .. ".vmt" ) ) then 
		xgui_maps.disp:SetImage( "maps/" .. xgui_maps.list:GetSelected()[1]:GetColumnText(1) )
	else 
		xgui_maps.disp:SetImage( "maps/noicon.vmt" )
	end
	xgui_maps.curmap:SetText( xgui_maps.list:GetSelected()[1]:GetColumnText(1) )
	xgui_maps.curmap:SizeToContents()
end

xgui_maps.disp = vgui.Create( "DImage", xgui_maps )
xgui_maps.disp:SetPos( 185, 30 )
xgui_maps.disp:SetImage( "maps/noicon.vmt" )
xgui_maps.disp:SetSize( 192, 192 )

xgui_maps.gamemode = x_makemultichoice{ x=70, y=345, w=110, h=20, parent=xgui_maps }

x_makebutton{ x=185, y=245, w=192, h=20, label="Vote to play this map!", parent=xgui_maps }.DoClick = function()
	if xgui_maps.curmap:GetValue() ~= "No Map Selected" then
		RunConsoleCommand( "ulx", "votemap", xgui_maps.curmap:GetValue() )
	end
end

x_makebutton{ x=185, y=270, w=192, h=20, label="Server-wide vote of selected map(s)", parent=xgui_maps }.DoClick = function()
	if xgui_maps.curmap:GetValue() ~= "No Map Selected" then
		local xgui_temp = {}
		for k, v in ipairs( xgui_maps.list:GetSelected() ) do
			table.insert( xgui_temp, xgui_maps.list:GetSelected()[k]:GetColumnText(1))
		end
		RunConsoleCommand( "ulx", "votemap2", unpack( xgui_temp ) )
	end
end

x_makebutton{ x=185, y=295, w=192, h=20, label="Force changelevel to this map", parent=xgui_maps }.DoClick = function()
	if xgui_maps.curmap:GetValue() ~= "No Map Selected" then
		if xgui_maps.gamemode:GetValue() == "<default>" then
			RunConsoleCommand( "ulx", "map", xgui_maps.curmap:GetValue() )
		else
			RunConsoleCommand( "ulx", "map", xgui_maps.curmap:GetValue(), xgui_maps.gamemode:GetValue() )
		end
	end
end

x_makebutton{ x=185, y=320, w=192, label="Veto a map vote", parent=xgui_maps }.DoClick = function()
	RunConsoleCommand( "ulx", "veto" )
end

xgui_maps.updateMaps = function()
	xgui_maps.list:Clear()
	for _,v in ipairs( xgui.data.votemaps ) do
		xgui_maps.list:AddLine( v )
	end
end

xgui_maps.updateGamemodes = function()
	xgui_maps.gamemode:Clear()
	xgui_maps.gamemode:AddChoice( "<default>" )
	xgui_maps.gamemode:SetText( "<default>" )
	for _, v in ipairs( xgui.data.gamemodes ) do
		xgui_maps.gamemode:AddChoice( v )
	end
end

table.insert( xgui.modules.tab, { name="Maps", panel=xgui_maps, icon="gui/silkicons/world", tooltip=nil, access=nil } )
table.insert( xgui.hook["votemaps"], xgui_maps.updateMaps )
table.insert( xgui.hook["gamemodes"], xgui_maps.updateGamemodes )