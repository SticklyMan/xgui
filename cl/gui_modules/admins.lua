--Admins module for ULX GUI -- by Stickly Man!
--Shows all admins in server and their online/offline status, allows adding/removing admins

function xgui_tab_admin()
	xgui_admin = x_makeXpanel( t )
-----------
	x_makelabel{ x=300, y=10, label="Non-Admin Players", parent=xgui_admin, textcolor=Color( 0, 0, 0, 255 ) }
	x_makelabel{ x=10, y=10, label="Server Admins", parent=xgui_admin, textcolor=Color( 0, 0, 0, 255 ) }
-----------
	xgad_admin_list = x_makelistview{ x=10, y=30, w=280, h=265, multiselect=false, parent=xgui_admin }
	xgad_admin_list:AddColumn( "Name" )
	xgad_admin_list:AddColumn( "Group" )
	xgad_admin_list:AddColumn( "Status" )
	xgad_admin_list.OnRowSelected = function()
		xgad_player_list:ClearSelection()
	end
-----------
	xgad_player_list = x_makelistview{ x=300, y=30, w=280, h=265, multiselect=false, parent=xgui_admin }
	xgad_player_list:AddColumn( "Name" )
	xgad_player_list:AddColumn( "Group" )
	xgad_player_list.OnRowSelected = function()
		xgad_admin_list:ClearSelection()
	end
	
	for k, v in pairs( player.GetAll() ) do
		if not v:IsAdmin() then
				xgad_player_list:AddLine( v:Nick(), v:GetUserGroup() )
		end
	end
-----------
	local xgad_pm = x_makebutton{ x=10, y=295, w=280, h=20, label="Send online admins a private message...", parent=xgui_admin }
	xgad_pm.DoClick = function()
				
		local xgui_pm = x_makeframepopup{ label="Send a message to online admins", w=400, h=60}
		local xgui_pm_text = x_maketextbox{x=10, y=30, w=380, h=20, parent=xgui_pm}
		xgui_pm_text.OnEnter = function()
			
			RunConsoleCommand( "ulx", "asay", unpack( string.Explode(" ", xgui_pm_text:GetValue() ) ) )
			xgui_pm:Remove()
				
		end
				
	end	
-----------
	local xgad_dm_button = x_makebutton{ x=10, y=340, w=280, h=20, label="Display a message on the screen...", parent=xgui_admin }
	xgad_dm_button.DoClick = function()
				
		local xgad_dm = x_makeframepopup{label="Display a message on the screen", w=400, h=60}
		local xgui_dm_text = x_maketextbox{x=10, y=30, w=380, h=20, parent=xgad_dm}
		xgui_dm_text.OnEnter = function()
			
			RunConsoleCommand( "ulx", "csay", unpack( string.Explode(" ", xgui_dm_text:GetValue() ) ) )
			xgad_dm:Remove()
				
		end
	end
------------
	local xgad_tm_button = x_makebutton{ x=10, y=315, w=280, h=20, label="Send a text message to all users...", parent=xgui_admin }
	xgad_tm_button.DoClick = function()
				
		local xgad_tm = x_makeframepopup{ label="Send a text message to all users", w=400, h=60 }
		local xgad_tm_text = x_maketextbox{ x=10, y=30, w=380, h=20, parent=xgad_tm }
		xgad_tm_text.OnEnter = function()
			
			RunConsoleCommand( "ulx", "tsay", unpack( string.Explode(" ", xgad_tm_text:GetValue() ) ) )
			xgad_tm:Remove()
				
		end
	end
------------
	local xgad_lua_button = x_makebutton{ x=300, y=295, w=280, h=20, label="Assign selected player to group...", parent=xgui_admin }
	xgad_lua_button.DoClick = function()
		if xgad_player_list:GetSelectedLine()or xgad_admin_list:GetSelectedLine()then
			local xgad_add_admin = x_makeframepopup{ label="_", w=200, h=100 }
			if xgad_player_list:GetSelectedLine()then
				xgad_add_admin:SetTitle( "Assign " .. xgad_player_list:GetSelected()[1]:GetColumnText(1) )
			else
				xgad_add_admin:SetTitle( "Assign " .. xgad_admin_list:GetSelected()[1]:GetColumnText(1) )
			end
			x_makelabel{ x=10, y=30, label="Group", parent=xgad_add_admin }
			x_makelabel{ x=10, y=53, label="Immunity", parent=xgad_add_admin }
			
			local xgad_add_group = x_makemultichoice{ x=65, y=28, w=125, h=20, text="Select...", parent=xgad_add_admin }
			for k, v in pairs( ULib.ucl.groups ) do
				xgad_add_group:AddChoice( k )
			end

			local xgad_add_immunity = x_makecheckbox{ x=65, y=55, parent=xgad_add_admin }			
			local xgad_add_ok = x_makebutton{ x=75, y=73, w=50, h=20, label="OK", parent=xgad_add_admin }
			xgad_add_ok.DoClick = function()
				print( xgad_add_group:GetText() )
				if xgad_player_list:GetSelectedLine()then
					if xgad_add_group:GetText() ~= "user" then
						RunConsoleCommand( "ulx", "adduser", xgad_player_list:GetSelected()[1]:GetColumnText(1), xgad_add_group:GetText(), xgad_add_immunity:GetValue() )
					else
						RunConsoleCommand( "ulx", "removeuser", xgad_admin_list:GetSelected()[1]:GetColumnText(1) )
					end
				else
					if xgad_add_group:GetText() ~= "user" then
						if xgad_admin_list:GetSelected()[1]:GetColumnText(3) == "Online" then
							RunConsoleCommand( "ulx", "adduser", xgad_admin_list:GetSelected()[1]:GetColumnText(1), xgad_add_group:GetText(), xgad_add_immunity:GetValue() )
						else
							RunConsoleCommand( "ulx", "adduserid", xgad_admin_list:GetSelected()[1]:GetColumnText(1), xgad_add_group:GetText(), xgad_admin_list:GetSelected()[1]:GetColumnText(4), xgad_add_immunity:GetValue() )
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
	local xgad_rcon_button = x_makebutton{ x=300, y=340, w=280, h=20, label="Send a console command to the server...", parent=xgui_admin }
	xgad_rcon_button.DoClick = function()
				
		local xgad_tm = x_makeframepopup{ label="Send a console command to the server", w=400, h=60 }
		local xgad_tm_text = x_maketextbox{ x=10, y=30, w=380, h=20, parent=xgad_tm }
		xgad_tm_text.OnEnter = function()
			
			RunConsoleCommand( "ulx", "rcon", unpack( string.Explode(" ", xgad_tm_text:GetValue() ) ) )
			xgad_tm:Remove()
				
		end	
	end	
------------
	local xgad_add_button = x_makebutton{ x=300, y=315, w=280, h=20, label="Assign Player's Group by SteamID...", parent=xgui_admin }
	xgad_add_button.DoClick = function()
	
		local xgad_add_admin = x_makeframepopup{ label="Add an Admin", w=200, h=150 }
		x_makelabel{ x=10, y=30, label="Name", parent=xgad_add_admin }
		x_makelabel{ x=10, y=53, label="SteamID", parent=xgad_add_admin }
		x_makelabel{ x=10, y=76, label="Group", parent=xgad_add_admin }
		x_makelabel{ x=10, y=99, label="Immunity", parent=xgad_add_admin }
		
		local xgad_add_group = x_makemultichoice{ x=65, y=73, w=125, h=20, text="Select...", parent=xgad_add_admin }
		for k, v in pairs( ULib.ucl.groups ) do
			xgad_add_group:AddChoice( k )
		end

		local xgad_add_name = x_maketextbox{ x=65, y=27, w=125, h=20, parent=xgad_add_admin }
		local xgad_add_userID = x_maketextbox{ x=65, y=50, w=125, h=20, parent=xgad_add_admin }
		local xgad_add_immunity = x_makecheckbox{ x=65, y=100, parent=xgad_add_admin }
		
		local xgad_add_ok = x_makebutton{ x=75, y=123, w=50, h=20, label="OK", parent=xgad_add_admin }
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