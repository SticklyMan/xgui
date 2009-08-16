--Groups module for ULX GUI -- by Stickly Man!
--Manages groups and players within groups

function xgui_tab_group()
	xgui_group = x_makeXpanel( t )
-----------
	x_makelabel{ x=5, y=10, label="Groups", parent=xgui_group, textcolor=Color( 0, 0, 0, 255 ) }
-----------
	xgui_group_list = x_makelistview{ x=5, y=30, w=125, h=125, multiselect=false, parent=xgui_group, headerheight=0 }
	xgui_group_list:AddColumn( "" )
	xgui_group_list:AddLine( "superadmin" )
	xgui_group_list:AddLine( "admin" )
	xgui_group_list:AddLine( "donator" )
	xgui_group_list:AddLine( "operator" )
	xgui_group_list:AddLine( "Gold Platinum Member" )	
	xgui_group_list:AddLine( "user" )
	xgui_group_list.OnRowSelected = function()
		xgui_group_name:SetText( xgui_group_list:GetSelected()[1]:GetColumnText(1) )
	end

	x_makebutton{ x=5, y=155, w=20, h=20, label="+", parent=xgui_group }.DoClick = function()
		xgui_group_list:AddLine( "New Group" )
	end
	
	x_makebutton{ x=25, y=155, w=20, h=20, label="-", parent=xgui_group }.DoClick = function()
		if xgui_group_list:GetSelectedLine() then
			if xgui_group_list:GetSelected()[1]:GetColumnText(1) ~= "superadmin" then
				Derma_Query( "Are you sure you would like to remove the \"" .. xgui_group_list:GetSelected()[1]:GetColumnText(1) .. "\" group?", "XGUI WARNING", 
					   "Remove", function() xgui_group_list:RemoveLine( xgui_group_list:GetSelectedLine() ) end,
					   "Cancel", function() end )
			else
				Derma_Message( "You are not allowed to remove the superadmin group!", "XGUI NOTICE" )
			end
		end
	end
	
	xgui_group_name = x_maketextbox{ x=45, y=155, w=85, focuscontrol=true, parent=xgui_group }
	xgui_group_name.OnEnter = function()
		if xgui_group_list:GetSelected()[1]:GetColumnText(1) ~= "superadmin" then
			if xgui_group_name:GetValue() ~= "" then
				xgui_group_list:GetSelected()[1]:SetValue( 1, xgui_group_name:GetValue() )
			else
				Derma_Message( "Group name cannot be blank!", "XGUI NOTICE" )
			end
		else
			Derma_Message( "You are not allowed to rename the superadmin group!", "XGUI NOTICE" )
		end
	end
------------
	local xgui_lua_button = x_makebutton{ x=300, y=295, w=280, h=20, label="Assign selected player to group...", parent=xgui_group }
	xgui_lua_button.DoClick = function()
		if xgui_player_list:GetSelectedLine()or xgui_admin_list:GetSelectedLine()then
			local xgui_add_admin = x_makeframepopup{ label="_", w=200, h=100 }
			if xgui_player_list:GetSelectedLine()then
				xgui_add_admin:SetTitle( "Assign " .. xgui_player_list:GetSelected()[1]:GetColumnText(1) )
			else
				xgui_add_admin:SetTitle( "Assign " .. xgui_admin_list:GetSelected()[1]:GetColumnText(1) )
			end
			x_makelabel{ x=10, y=30, label="Group", parent=xgui_add_admin }
			x_makelabel{ x=10, y=53, label="Immunity", parent=xgui_add_admin }
			
			local xgui_add_group = x_makemultichoice{ x=65, y=28, w=125, h=20, text="Select...", parent=xgui_add_admin }
			for k, v in pairs( ULib.ucl.groups ) do
				xgui_add_group:AddChoice( k )
			end

			local xgui_add_immunity = x_makecheckbox{ x=65, y=55, parent=xgui_add_admin }			
			local xgui_add_ok = x_makebutton{ x=75, y=73, w=50, h=20, label="OK", parent=xgui_add_admin }
			xgui_add_ok.DoClick = function()
				print( xgui_add_group:GetText() )
				if xgui_player_list:GetSelectedLine() then
					if xgui_add_group:GetText() ~= "user" then
						RunConsoleCommand( "ulx", "adduser", xgui_player_list:GetSelected()[1]:GetColumnText(1), xgui_add_group:GetText(), xgui_add_immunity:GetValue() )
					else
						RunConsoleCommand( "ulx", "removeuser", xgui_admin_list:GetSelected()[1]:GetColumnText(1) )
					end
				else
					if xgui_add_group:GetText() ~= "user" then
						if xgui_admin_list:GetSelected()[1]:GetColumnText(3) == "Online" then
							RunConsoleCommand( "ulx", "adduser", xgui_admin_list:GetSelected()[1]:GetColumnText(1), xgui_add_group:GetText(), xgui_add_immunity:GetValue() )
						else
							RunConsoleCommand( "ulx", "adduserid", xgui_admin_list:GetSelected()[1]:GetColumnText(1), xgui_add_group:GetText(), xgui_admin_list:GetSelected()[1]:GetColumnText(4), xgui_add_immunity:GetValue() )
						end
					else
					
						RunConsoleCommand( "ulx", "removeuser", xgui_admin_list:GetSelected()[1]:GetColumnText(1) )
					end
				end
				xgui_add_admin:Remove()
				xgui_refresh()
			end
		end
	end
------------
	local xgui_add_button = x_makebutton{ x=300, y=315, w=280, h=20, label="Assign Player's Group by SteamID...", parent=xgui_group }
	xgui_add_button.DoClick = function()
	
		local xgui_add_admin = x_makeframepopup{ label="Add an Admin", w=200, h=150 }
		x_makelabel{ x=10, y=30, label="Name", parent=xgui_add_admin }
		x_makelabel{ x=10, y=53, label="SteamID", parent=xgui_add_admin }
		x_makelabel{ x=10, y=76, label="Group", parent=xgui_add_admin }
		x_makelabel{ x=10, y=99, label="Immunity", parent=xgui_add_admin }
		
		local xgui_add_group = x_makemultichoice{ x=65, y=73, w=125, h=20, text="Select...", parent=xgui_add_admin }
		for k, v in pairs( ULib.ucl.groups ) do
			xgui_add_group:AddChoice( k )
		end

		local xgui_add_name = x_maketextbox{ x=65, y=27, w=125, h=20, parent=xgui_add_admin }
		local xgui_add_userID = x_maketextbox{ x=65, y=50, w=125, h=20, parent=xgui_add_admin }
		local xgui_add_immunity = x_makecheckbox{ x=65, y=100, parent=xgui_add_admin }
		
		local xgui_add_ok = x_makebutton{ x=75, y=123, w=50, h=20, label="OK", parent=xgui_add_admin }
		xgui_add_ok.DoClick = function()
			if xgui_add_group:GetValue() ~= "user" then
				RunConsoleCommand( "ulx", "adduserid", xgui_add_name:GetValue(), xgui_add_group:GetValue(), xgui_add_userID:GetValue(), xgui_add_immunity:GetValue() )
			else
				RunConsoleCommand( "ulx", "removeuser", xgui_add_name:GetValue() )
			end
			xgui_add_admin:Remove()
			xgui_refresh()
		end
	end	
------------

	RunConsoleCommand( "xgui_requestadmins" )
	xgui_base:AddSheet( "Groups", xgui_group, "gui/silkicons/user", false, false )
end

local function xgui_admin_RecieveAdmin( um )
	if xgui_base:IsVisible() then
		xgui_admin_list:AddLine( um:ReadString(), um:ReadString(), um:ReadString(), um:ReadString() )
	end
end
usermessage.Hook( "xgui_admin", xgui_admin_RecieveAdmin )

xgui_modules[2]=xgui_tab_group