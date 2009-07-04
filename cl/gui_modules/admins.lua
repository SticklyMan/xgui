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
	xgad_admin_list = vgui.Create( "DListView", xgui_admin )
	xgad_admin_list:SetPos( 10,30 )
	xgad_admin_list:SetSize( 280,265 )
	xgad_admin_list:SetMultiSelect( false )
	xgad_admin_list:AddColumn( "Name" )
	xgad_admin_list:AddColumn( "Groups" )
	xgad_admin_list:AddColumn( "Status" )
	xgad_admin_list.OnRowSelected = function()
		
		xgad_player_list:ClearSelection()
		
	end
-----------
	xgad_player_list = vgui.Create( "DListView", xgui_admin )
	xgad_player_list:SetPos( 300,30 )
	xgad_player_list:SetSize( 280,265 )
	xgad_player_list:SetMultiSelect( false )
	xgad_player_list:AddColumn( "Name" )
	xgad_player_list:AddColumn( "Groups" )
	xgad_player_list.OnRowSelected = function()
	
		xgad_admin_list:ClearSelection()
		
	end
	
	for k, v in pairs( player.GetAll() ) do
		if not v:IsAdmin() then
				xgad_player_list:AddLine( v:Nick(), table.concat( v:GetGroups() ) )
		end
	end
-----------
	local xgad_pm = vgui.Create( "DButton", xgui_admin )
	xgad_pm:SetSize( 280,20 )
	xgad_pm:SetPos( 10, 295 )
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
	xgad_dm_button:SetPos( 10, 340 )
	xgad_dm_button:SetText( "Display a message on the screen..." )
	xgad_dm_button.DoClick = function()
				
		local xgad_dm = vgui.Create( "DFrame" )
		xgad_dm:SetPos( ScrW()/2 - 200, ScrH()/2 - 30 )
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
	xgad_tm_button:SetPos( 10, 315 )
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
	xgad_lua_button:SetPos( 300, 295 )
	xgad_lua_button:SetText( "Assign selected player to group..." )
	xgad_lua_button.DoClick = function()
		if xgad_player_list:GetSelectedLine() ~= nil or xgad_admin_list:GetSelectedLine() ~= nil then
			
			local xgad_add_admin = vgui.Create( "DFrame" )
			xgad_add_admin:SetPos( ScrW()/2 - 100, ScrH()/2 - 50 )
			xgad_add_admin:SetSize( 200, 100 )
			if xgad_player_list:GetSelectedLine() ~= nil then
				xgad_add_admin:SetTitle( "Assign " .. xgad_player_list:GetSelected()[1]:GetColumnText(1) )
			else
				xgad_add_admin:SetTitle( "Assign " .. xgad_admin_list:GetSelected()[1]:GetColumnText(1) )
			end
			xgad_add_admin:MakePopup()
			xgad_add_admin.PaintOver = function()
				surface.SetTextColor( 0, 0, 0, 255 )
				surface.SetTextPos( 10, 30 )
				surface.DrawText( "Group" )
				surface.SetTextPos( 10, 53 )
				surface.DrawText( "Immunity" )
			end
			
			local xgad_add_group = vgui.Create( "DButton", xgad_add_admin )
			xgad_add_group:SetPos( 65,27 )
			xgad_add_group:SetSize( 125,20 )
			xgad_add_group:SetText( "Select..." )
			xgad_add_group.DoClick = function()
				xgad_list_groups = DermaMenu()
				xgad_list_groups:SetParent( xgad_add_admin )
				for k, v in pairs( ULib.ucl.groups ) do
					xgad_list_groups:AddOption( k, function() xgad_add_group:SetText(k) end )
				end
				xgad_list_groups:Open()
			end

			local xgad_add_immunity = vgui.Create( "DCheckBox", xgad_add_admin )
			xgad_add_immunity:SetPos( 65, 55 )
			
			local xgad_add_ok = vgui.Create( "DButton", xgad_add_admin )
			xgad_add_ok:SetPos( 75, 73 )
			xgad_add_ok:SetSize( 50, 20 )
			xgad_add_ok:SetText( "OK" )
			xgad_add_ok.DoClick = function()
			if xgad_player_list:GetSelectedLine() ~= nil then
				if xgad_add_group:GetValue() ~= "user" then
					RunConsoleCommand( "ulx", "adduser", xgad_player_list:GetSelected()[1]:GetColumnText(1), xgad_add_group:GetValue(), xgad_add_immunity:GetValue() )
				else
					RunConsoleCommand( "ulx", "removeuser", xgad_admin_list:GetSelected()[1]:GetColumnText(1) )
				end
			else
				if xgad_add_group:GetValue() ~= "user" then
					if xgad_admin_list:GetSelected()[1]:GetColumnText(3) == "Online" then
						RunConsoleCommand( "ulx", "adduser", xgad_admin_list:GetSelected()[1]:GetColumnText(1), xgad_add_group:GetValue(), xgad_add_immunity:GetValue() )
					else
						RunConsoleCommand( "ulx", "adduserid", xgad_admin_list:GetSelected()[1]:GetColumnText(1), xgad_add_group:GetValue(), xgad_admin_list:GetSelected()[1]:GetColumnText(4), xgad_add_immunity:GetValue() )
					end
				else
				
					RunConsoleCommand( "ulx", "removeuser", xgad_admin_list:GetSelected()[1]:GetColumnText(1) )
				end
			end
			xgad_add_admin:Remove()
			xgui_refresh()
			end
		end
	end
------------
	local xgad_rcon_button = vgui.Create( "DButton", xgui_admin )
	xgad_rcon_button:SetSize( 280, 20 )
	xgad_rcon_button:SetPos( 300, 340 )
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
	xgad_add_button:SetPos( 300,315 )
	xgad_add_button:SetSize( 280, 20 )
	xgad_add_button:SetText( "Assign Player's Group by SteamID..." )
	xgad_add_button.DoClick = function()
	
		local xgad_add_admin = vgui.Create( "DFrame" )
		xgad_add_admin:SetPos( ScrW()/2 - 100, ScrH()/2 - 75 )
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
			surface.DrawText( "Immunity" )
		end
		
		local xgad_add_group = vgui.Create( "DButton", xgad_add_admin )
		xgad_add_group:SetPos( 65,73 )
		xgad_add_group:SetSize( 125,20 )
		xgad_add_group:SetText( "Select..." )
		xgad_add_group.DoClick = function()
			xgad_list_groups = DermaMenu()
			xgad_list_groups:SetParent( xgad_add_admin )
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

		local xgad_add_immunity = vgui.Create( "DCheckBox", xgad_add_admin )
		xgad_add_immunity:SetPos( 65, 100 )
		
		local xgad_add_ok = vgui.Create( "DButton", xgad_add_admin )
		xgad_add_ok:SetPos( 75, 123 )
		xgad_add_ok:SetSize( 50, 20 )
		xgad_add_ok:SetText( "OK" )
		xgad_add_ok.DoClick = function()
			if xgad_add_group:GetValue() ~= "user" then
				RunConsoleCommand( "ulx", "adduserid", xgad_add_name:GetValue(), xgad_add_group:GetValue(), xgad_add_userID:GetValue(), xgad_add_immunity:GetValue() )
			else
				RunConsoleCommand( "ulx", "removeuser", xgad_add_name:GetValue() )
			end
			xgad_add_admin:Remove()
			xgui_refresh()
		end
	end	
------------

	xgui_base:AddSheet( "Admins", xgui_admin, "gui/silkicons/user", false, false )
end

local function xgui_admin_RecieveAdmin( um )
	if xgui_base:IsVisible() then
		xgad_admin_list:AddLine( um:ReadString(), um:ReadString(), um:ReadString(), um:ReadString() )
	end
end
usermessage.Hook( "xgui_admin", xgui_admin_RecieveAdmin )

xgui_modules[2]=xgui_tab_admin