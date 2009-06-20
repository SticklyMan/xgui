--Admins module for ULX GUI -- by Stickly Man!
--Shows all admins in server and their online/offline status, allows adding/removing admins

function xgui_tab_admin()
	xgui_admin = vgui.Create( "DPanel" )
-----------
	xgui_admin.Paint = function()
		surface.SetDrawColor( 191, 191, 191, 255 )
		surface.DrawRect( 0, 0, 590, 390 )
		surface.SetTextColor( 0, 0, 0, 255 )
		surface.SetTextPos( 10, 10 )
		surface.DrawText( "Server Admins" )
		surface.SetTextPos( 300, 10 )
		surface.DrawText( "Non-Admin Players" )
	end
-----------
	xgad_admin_list = vgui.Create( "DListView" )
	xgad_admin_list:SetParent( xgui_admin )
	xgad_admin_list:SetPos( 10,30 )
	xgad_admin_list:SetSize( 280,250 )
	xgad_admin_list:AddColumn( "Name" )
	xgad_admin_list:AddColumn( "Groups" )
	xgad_admin_list:AddColumn( "Status" )
-----------
	local xgad_player_list = vgui.Create( "DListView" )
	xgad_player_list:SetParent( xgui_admin )
	xgad_player_list:SetPos( 300,30 )
	xgad_player_list:SetSize( 280,250 )
	xgad_player_list:AddColumn( "Name" )
	xgad_player_list:AddColumn( "Groups" )
	
	for k, v in pairs( player.GetAll() ) do
		if not v:IsAdmin() then
				xgad_player_list:AddLine( v:Nick(), table.concat( v:GetGroups() ) )
		end
	end
-----------
	local xgad_pm = vgui.Create( "DButton", xgui_admin )
	xgad_pm:SetSize( 280,20 )
	xgad_pm:SetPos( 10, 280 )
	xgad_pm:SetText( "Send online admins a private message..." )
	xgad_pm.DoClick = function()
				
		local xgui_pm = vgui.Create( "DFrame" )
		xgui_pm:SetPos( ScrW()/2 - 200, ScrH()/2 - 30 )
		xgui_pm:SetSize( 400, 60 )
		xgui_pm:SetTitle( "Send a message to online admins" )
		xgui_pm:MakePopup()
		
		local xgui_pm_text = vgui.Create( "DTextEntry", xgui_pm )
		xgui_pm_text:SetPos( 10, 30 )
		xgui_pm_text:SetTall( 20 )
		xgui_pm_text:SetWide( 380 )
		xgui_pm_text:SetEnterAllowed( true )
		xgui_pm_text.OnEnter = function()
			
			RunConsoleCommand( "ulx", "asay", unpack( string.Explode(" ", xgui_pm_text:GetValue() ) ) )
			xgui_pm:Remove()
				
		end
				
	end	
-----------
	local xgad_dm_button = vgui.Create( "DButton", xgui_admin )
	xgad_dm_button:SetSize( 280, 20 )
	xgad_dm_button:SetPos( 300, 280 )
	xgad_dm_button:SetText( "Display a message on the screen..." )
	xgad_dm_button.DoClick = function()
				
		local xgad_dm = vgui.Create( "DFrame" )
		xgad_dm:SetPos( ScrW()/2 - 200, ScrH()/2 - 30 )
		xgad_dm:SetSize( 400, 60 )
		xgad_dm:SetTitle( "Display a message on the screen" )
		xgad_dm:MakePopup()
		
		local xgui_dm_text = vgui.Create( "DTextEntry", xgad_dm )
		xgui_dm_text:SetPos( 10, 30 )
		xgui_dm_text:SetTall( 20 )
		xgui_dm_text:SetWide( 380 )
		xgui_dm_text:SetEnterAllowed( true )
		xgui_dm_text.OnEnter = function()
			
			RunConsoleCommand( "ulx", "csay", unpack( string.Explode(" ", xgui_dm_text:GetValue() ) ) )
			xgad_dm:Remove()
				
		end	
	end
------------
	local xgad_tm_button = vgui.Create( "DButton", xgui_admin )
	xgad_tm_button:SetSize( 280, 20 )
	xgad_tm_button:SetPos( 300, 300 )
	xgad_tm_button:SetText( "Send a text message to all users..." )
	xgad_tm_button.DoClick = function()
				
		local xgad_tm = vgui.Create( "DFrame" )
		xgad_tm:SetPos( ScrW()/2 - 200, ScrH()/2 - 30 )
		xgad_tm:SetSize( 400, 60 )
		xgad_tm:SetTitle( "Send a text message to all users" )
		xgad_tm:MakePopup()
		
		local xgad_tm_text = vgui.Create( "DTextEntry", xgad_tm )
		xgad_tm_text:SetPos( 10, 30 )
		xgad_tm_text:SetTall( 20 )
		xgad_tm_text:SetWide( 380 )
		xgad_tm_text:SetEnterAllowed( true )
		xgad_tm_text.OnEnter = function()
			
			RunConsoleCommand( "ulx", "tsay", unpack( string.Explode(" ", xgad_tm_text:GetValue() ) ) )
			xgad_tm:Remove()
				
		end	
	end	
------------
	local xgad_lua_button = vgui.Create( "DButton", xgui_admin )
	xgad_lua_button:SetSize( 280, 20 )
	xgad_lua_button:SetPos( 10, 300 )
	xgad_lua_button:SetText( "Run a Lua command on the server..." )
	xgad_lua_button.DoClick = function()
				
		local xgad_lua = vgui.Create( "DFrame" )
		xgad_lua:SetPos( ScrW()/2 - 200, ScrH()/2 - 30 )
		xgad_lua:SetSize( 400, 60 )
		xgad_lua:SetTitle( "Run a Lua command on the server" )
		xgad_lua:MakePopup()
		
		local xgad_lua_text = vgui.Create( "DTextEntry", xgad_lua )
		xgad_lua_text:SetPos( 10, 30 )
		xgad_lua_text:SetTall( 20 )
		xgad_lua_text:SetWide( 380 )
		xgad_lua_text:SetEnterAllowed( true )
		xgad_lua_text.OnEnter = function()
			
			RunConsoleCommand( "ulx", "luarun", unpack( string.Explode(" ", xgad_lua_text:GetValue() ) ) )
			xgad_lua:Remove()
				
		end	
	end	
------------
	local xgad_rcon_button = vgui.Create( "DButton", xgui_admin )
	xgad_rcon_button:SetSize( 280, 20 )
	xgad_rcon_button:SetPos( 10, 320 )
	xgad_rcon_button:SetText( "Send a console command to the server..." )
	xgad_rcon_button.DoClick = function()
				
		local xgad_tm = vgui.Create( "DFrame" )
		xgad_tm:SetPos( ScrW()/2 - 200, ScrH()/2 - 30 )
		xgad_tm:SetSize( 400, 60 )
		xgad_tm:SetTitle( "Send a console command to the server" )
		xgad_tm:MakePopup()
		
		local xgad_tm_text = vgui.Create( "DTextEntry", xgad_tm )
		xgad_tm_text:SetPos( 10, 30 )
		xgad_tm_text:SetTall( 20 )
		xgad_tm_text:SetWide( 380 )
		xgad_tm_text:SetEnterAllowed( true )
		xgad_tm_text.OnEnter = function()
			
			RunConsoleCommand( "ulx", "rcon", unpack( string.Explode(" ", xgad_tm_text:GetValue() ) ) )
			xgad_tm:Remove()
				
		end	
	end	
------------
	local xgad_add_button = vgui.Create( "DButton", xgui_admin )
	xgad_add_button:SetPos( 300,320 )
	xgad_add_button:SetSize( 280, 20 )
	xgad_add_button:SetText( "Add selected or other player as admin..." )
	xgad_add_button.DoClick = function()
	
		local xgad_add_admin = vgui.Create( "DFrame" )
		xgad_add_admin:SetPos( ScrW()/2 - 200, ScrH()/2 - 30 )
		xgad_add_admin:SetSize( 200, 150 )
		xgad_add_admin:SetTitle( "Add an Admin" )
		xgad_add_admin:MakePopup()
		xgad_add_admin.PaintOver = function()
			surface.SetTextColor( 0, 0, 0, 255 )
			surface.SetTextPos( 10, 30 )
			surface.DrawText( "Name" )
			surface.SetTextPos( 10, 53 )
			surface.DrawText( "SteamID" )
			surface.SetTextPos( 10, 76 )
			surface.DrawText( "Group" )
			surface.SetTextPos( 10, 99 )
			surface.DrawText( "Password" )
		end
		
		local xgad_add_group = vgui.Create( "DButton", xgad_add_admin )
		xgad_add_group:SetPos( 65,73 )
		xgad_add_group:SetSize( 125,20 )
		xgad_add_group:SetText( "Select..." )
		xgad_add_group.DoClick = function()
			xgad_list_groups = DermaMenu()
			xgad_list_groups:SetParent( xgad_add_admin )
			xgad_list_groups:SetPos( 475,247 )
			for k, v in pairs( ULib.ucl.groups ) do
				xgad_list_groups:AddOption( k, function() xgad_add_group:SetText(k) end )
			end
			xgad_list_groups:Open()
		end

		local xgad_add_name = vgui.Create( "DTextEntry", xgad_add_admin )
		xgad_add_name:SetPos( 65, 27 )
		xgad_add_name:SetTall( 20 )
		xgad_add_name:SetWide( 125 )

		local xgad_add_userID = vgui.Create( "DTextEntry", xgad_add_admin )
		xgad_add_userID:SetPos( 65, 50 )
		xgad_add_userID:SetTall( 20 )
		xgad_add_userID:SetWide( 125 )

		local xgad_add_pw = vgui.Create( "DTextEntry", xgad_add_admin )
		xgad_add_pw:SetPos( 65, 96 )
		xgad_add_pw:SetTall( 20 )
		xgad_add_pw:SetWide( 125 )
		
		local xgad_add_ok = vgui.Create( "DButton", xgad_add_admin )
		xgad_add_ok:SetPos( 75, 123 )
		xgad_add_ok:SetSize( 50, 20 )
		xgad_add_ok:SetText( "OK" )
		xgad_add_ok.DoClick = function()
		
		end
	end	
------------

	xgui_base:AddSheet( "Admins", xgui_admin, "gui/silkicons/user", false, false )
end

local function xgui_admin_RecieveAdmin( um )
	if xgui_base:IsVisible() then
		xgad_admin_list:AddLine( um:ReadString(), um:ReadString(), um:ReadString() )
	end
end
usermessage.Hook( "xgui_admin", xgui_admin_RecieveAdmin )

xgui_modules[2]=xgui_tab_admin