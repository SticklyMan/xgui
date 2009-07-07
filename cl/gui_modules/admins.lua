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
	xgad_admin_list = x_makelistview( 10, 30, 280, 265, false, xgui_admin )
	xgad_admin_list:AddColumn( "Name" )
	xgad_admin_list:AddColumn( "Groups" )
	xgad_admin_list:AddColumn( "Status" )
	xgad_admin_list.OnRowSelected = function()
		
		xgad_player_list:ClearSelection()
		
	end
-----------
	xgad_player_list = x_makelistview( 300, 30, 280, 265, false, xgui_admin )
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
	local xgad_pm = x_makebutton( "Send online admins a private message...", 10, 295, 280, 20, xgui_admin )
	xgad_pm.DoClick = function()
				
		local xgui_pm = x_makeframepopup( "Send a message to online admins", 400, 60 )
		local xgui_pm_text = x_maketextbox( 10, 30, 380, 20, xgui_pm )
		xgui_pm_text.OnEnter = function()
			
			RunConsoleCommand( "ulx", "asay", unpack( string.Explode(" ", xgui_pm_text:GetValue() ) ) )
			xgui_pm:Remove()
				
		end
				
	end	
-----------
	local xgad_dm_button = x_makebutton( "Display a message on the screen...", 10, 340, 280, 20, xgui_admin )
	xgad_dm_button.DoClick = function()
				
		local xgad_dm = x_makeframepopup( "Display a message on the screen", 400, 60 )
		local xgui_dm_text = x_maketextbox( 10, 30, 380, 20, xgad_dm )
		xgui_dm_text.OnEnter = function()
			
			RunConsoleCommand( "ulx", "csay", unpack( string.Explode(" ", xgui_dm_text:GetValue() ) ) )
			xgad_dm:Remove()
				
		end
	end
------------
	local xgad_tm_button = x_makebutton( "Send a text message to all users...", 10, 315, 280, 20, xgui_admin )
	xgad_tm_button.DoClick = function()
				
		local xgad_tm = x_makeframepopup( "Send a text message to all users", 400, 60 )
		local xgad_tm_text = x_maketextbox( 10, 30, 380, 20, xgui_tm )
		xgad_tm_text.OnEnter = function()
			
			RunConsoleCommand( "ulx", "tsay", unpack( string.Explode(" ", xgad_tm_text:GetValue() ) ) )
			xgad_tm:Remove()
				
		end
	end
------------
	local xgad_lua_button = x_makebutton( "Assign selected player to group...", 300, 295, 280, 20, xgui_admin )
	xgad_lua_button.DoClick = function()
		if xgad_player_list:GetSelectedLine() ~= nil or xgad_admin_list:GetSelectedLine() ~= nil then
			if xgad_player_list:GetSelectedLine() ~= nil then
				local xgad_add_admin = x_makeframepopup( "Assign " .. xgad_player_list:GetSelected()[1]:GetColumnText(1), 200, 100 )
			else
				local xgad_add_admin = x_makeframepopup( "Assign " .. xgad_admin_list:GetSelected()[1]:GetColumnText(1), 200, 100 )
			end
			xgad_add_admin.PaintOver = function()
				surface.SetTextColor( 0, 0, 0, 255 )
				surface.SetTextPos( 10, 30 )
				surface.DrawText( "Group" )
				surface.SetTextPos( 10, 53 )
				surface.DrawText( "Immunity" )
			end
			
			local xgad_add_group = x_makebutton( "Select...", 65, 27, 125, 20, xgad_add_admin )
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
			
			local xgad_add_ok = x_makebutton( "OK", 75, 73, 50, 20, xgad_add_admin )
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
	local xgad_rcon_button = x_makebutton( "Send a console command to the server...", 300, 340, 280, 20, xgui_admin )
	xgad_rcon_button.DoClick = function()
				
		local xgad_tm = x_makeframepopup( "Send a console command to the server", 400, 60 )
		local xgad_tm_text = x_maketextbox( 10, 30, 380, 20, xgad_tm )
		xgad_tm_text.OnEnter = function()
			
			RunConsoleCommand( "ulx", "rcon", unpack( string.Explode(" ", xgad_tm_text:GetValue() ) ) )
			xgad_tm:Remove()
				
		end	
	end	
------------
	local xgad_add_button = x_makebutton( "Assign Player's Group by SteamID...", 300, 315, 280, 20, xgui_admin )
	xgad_add_button.DoClick = function()
	
		local xgad_add_admin = x_makeframepopup( "Add an Admin", 200, 150 )
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
		
		local xgad_add_group = x_makebutton( "Select...", 65, 73, 125, 20, xgad_add_admin )
		xgad_add_group.DoClick = function()
			xgad_list_groups = DermaMenu()
			xgad_list_groups:SetParent( xgad_add_admin )
			for k, v in pairs( ULib.ucl.groups ) do
				xgad_list_groups:AddOption( k, function() xgad_add_group:SetText(k) end )
			end
			xgad_list_groups:Open()
		end

		local xgad_add_name = x_maketextbox( 65, 27, 125, 20, xgad_add_admin )
		local xgad_add_userID = x_maketextbox( 65, 50, 125, 20, xgui_add_admin )
		local xgad_add_immunity = vgui.Create( "DCheckBox", xgad_add_admin )
		xgad_add_immunity:SetPos( 65, 100 )
		
		local xgad_add_ok = x_makebutton( "OK", 75, 123, 50, 20, xgad_add_admin )
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

	RunConsoleCommand( "xgui_requestadmins" )
	xgui_base:AddSheet( "Admins", xgui_admin, "gui/silkicons/user", false, false )
end

local function xgui_admin_RecieveAdmin( um )
	if xgui_base:IsVisible() then
		xgad_admin_list:AddLine( um:ReadString(), um:ReadString(), um:ReadString(), um:ReadString() )
	end
end
usermessage.Hook( "xgui_admin", xgui_admin_RecieveAdmin )

xgui_modules[2]=xgui_tab_admin