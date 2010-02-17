--Groups module for ULX GUI -- by Stickly Man!
--Manages groups and players within groups

local xgui_restrict_color = Color( 255, 255, 255, 0 )
xgui_group = x_makeXpanel( )
xgui_group.DefaultPaint = xgui_group.Paint
xgui_group.Paint = function( self )
	self:DefaultPaint()
	draw.RoundedBox( 6, 135, 5, 450, 360, xgui_restrict_color )	
end

x_makelabel{ x=5, y=10, label="Groups", parent=xgui_group, textcolor=Color( 0, 0, 0, 255 ) }
x_makelabel{ x=140, y=10, label="Command Access", parent=xgui_group, textcolor=Color( 0, 0, 0, 255 ) }
x_makelabel{ x=290, y=10, w=135, label="Restrictions", parent=xgui_group, textcolor=Color( 0, 0, 0, 255 ) }
x_makelabel{ x=435, y=10, label="Other Access", parent=xgui_group, textcolor=Color( 0, 0, 0, 255 ) }

xgui_access_plist = x_makepanellist{ x=140, y=30, w=145, h=330, padding=1, spacing=1, parent=xgui_group }
	xgui_access_list = x_makelistview{ multiselect=true, headerheight=0 }
	xgui_access_list:AddColumn( "" )
	xgui_access_list:AddColumn( "" ):SetFixedWidth( 10 )
	xgui_inhaccess_list = x_makelistview{ multiselect=false, headerheight=0 }
	xgui_inhaccess_list:AddColumn( "" )
	xgui_inhaccess_list:AddColumn( "" ):SetFixedWidth( 10 )
xgui_access_plist:AddItem( x_makecat{ label="Allowed", contents=xgui_access_list } )
xgui_access_plist:AddItem( x_makecat{ label="Inherited", contents=xgui_inhaccess_list } )

xgui_inhaccess_plist = x_makepanellist{ x=435, y=30, w=145, h=330, padding=1, spacing=1, parent=xgui_group }
	xgui_access_otherlist = x_makelistview{ multiselect = true, headerheight=0 }
	xgui_access_otherlist:AddColumn( "" )
	xgui_inhaccess_otherlist = x_makelistview{ multiselect = false, headerheight=0 }
	xgui_inhaccess_otherlist:AddColumn( "" )
xgui_inhaccess_plist:AddItem( x_makecat{ label="Allowed", contents=xgui_access_otherlist } )
xgui_inhaccess_plist:AddItem( x_makecat{ label="Inherited", contents=xgui_inhaccess_otherlist } )

xgui_restrictions = x_makepanellist{ x=290, y=30, w=140, h=330, padding=1, spacing=1, parent=xgui_group }

xgui_group_list = x_makelistview{ x=5, y=30, w=130, h=115, multiselect=false, parent=xgui_group, headerheight=0 }
xgui_group_list:AddColumn( "" )
xgui_group_list.OnRowSelected = function()
	local group = xgui_group_list:GetSelected()[1]:GetColumnText(1)
	
	xgui_restrict_color = Color( 100, 170, 220, 255 )
	xgui_group_name:SetText( group )
	
	xgui_adduserbtn:SetDisabled( group == "user" )
	xgui_groupremove:SetDisabled( group == "user" )
	if ULib.ucl.groups[group].inherit_from ~= nil then
		xgui_group_inherit:SetText( ULib.ucl.groups[group].inherit_from )
	else
		xgui_group_inherit:SetText( "user" )
	end
	xgui_getGroupsUsers()
	xgui_getGroupAccess( group )
end

xgui_groupadd = x_makebutton{ x=5, y=145, w=20, h=20, label="+", parent=xgui_group }
xgui_groupadd.DoClick = function()
	local function newgroup( count )
		local checkname
		if count == 0 then
			checkname = "newgroup"
		else 
			checkname = "newgroup" .. count
		end
		if xgui_group_list:GetLineByColumnText( checkname, 1 ) == nil then
				RunConsoleCommand( "ulx", "addgroup", checkname )
		else
			newgroup( count+1 )
		end
	end
	newgroup( 0 )
end

xgui_groupremove = x_makebutton{ x=25, y=145, w=20, h=20, label="-", parent=xgui_group }
xgui_groupremove.DoClick = function()
	if xgui_group_list:GetSelectedLine() then
		if xgui_group_list:GetSelected()[1]:GetColumnText(1) ~= "superadmin" then
			Derma_Query( "Are you sure you would like to remove the \"" .. xgui_group_list:GetSelected()[1]:GetColumnText(1) .. "\" group?", "XGUI WARNING", 
					"Remove", function()
						RunConsoleCommand( "ulx", "removegroup", xgui_group_list:GetSelected()[1]:GetColumnText(1) ) end,
					"Cancel", function() end )
		else
			Derma_Query( "Removng superadmin is generally a bad idea. Are you sure you would like to remove it?", "XGUI WARNING", 
					"Remove", function() 
						RunConsoleCommand( "ulx", "removegroup", xgui_group_list:GetSelected()[1]:GetColumnText(1) ) end,
					"Cancel", function() end )
		end
	end
end
		
xgui_group_name = x_maketextbox{ x=45, y=145, w=90, focuscontrol=true, parent=xgui_group }
xgui_group_name.OnEnter = function()
	if xgui_group_list:GetSelectedLine() then
		if xgui_group_list:GetSelected()[1]:GetColumnText(1) ~= "user" then
			if xgui_group_name:GetValue() ~= "" then
				if xgui_group_list:GetSelected()[1]:GetColumnText(1) ~= "superadmin" then
					if xgui_group_list:GetLineByColumnText( xgui_group_name:GetValue(), 1 ) == nil then
						RunConsoleCommand( "ulx", "renamegroup", xgui_group_list:GetSelected()[1]:GetColumnText(1), string.lower( xgui_group_name:GetValue() ) )
						hook.Call( "xgui_OnRenameGroup", GAMEMODE, xgui_group_list:GetSelected()[1]:GetColumnText(1), string.lower( xgui_group_name:GetValue() ) )
					else
						Derma_Message( "A group by that name already exists!", "XGUI NOTICE" )
					end
				else
					Derma_Query( "Renaming superadmin is generally a bad idea. Are you sure you would like to rename it?", "XGUI WARNING", 
							"Rename", function() 
								if xgui_group_list:GetLineByColumnText( xgui_group_name:GetValue(), 1 ) == nil then
									RunConsoleCommand( "ulx", "renamegroup", xgui_group_list:GetSelected()[1]:GetColumnText(1), string.lower( xgui_group_name:GetValue() ) )
								else
									Derma_Message( "A group by that name already exists!", "XGUI NOTICE" )
								end
							end, 
							"Cancel", function() xgui_group_name:SetText( "superadmin" ) end )
				end
			else
				Derma_Message( "Group name cannot be blank!", "XGUI NOTICE" )
			end
		else
			Derma_Message( "You are not allowed to rename the group \"user\"!", "XGUI NOTICE" )
			xgui_group_name:SetText( "user" )
		end
	end
end

x_makelabel{ x=5, y=168, label="Inherits", parent=xgui_group, textcolor=Color( 0, 0, 0, 255 ) }
x_makelabel{ x=5, y=188, label="Users in group", parent=xgui_group, textcolor=Color( 0, 0, 0, 255 ) }
xgui_group_inherit = x_makemultichoice{ x=45, y=165, w=90, parent=xgui_group }
xgui_group_inherit.OnSelect = function()
	if xgui_group_list:GetSelectedLine() then
		if xgui_group_list:GetSelected()[1]:GetColumnText(1) ~= "user" then
			if xgui_group_inherit:GetValue() ~= "<none>" then
				RunConsoleCommand( "xgui", "setinheritance", xgui_group_list:GetSelected()[1]:GetColumnText(1), xgui_group_inherit:GetValue() )
			else
				RunConsoleCommand( "xgui", "setinheritance", xgui_group_list:GetSelected()[1]:GetColumnText(1), ULib.ACCESS_ALL )
			end
		else
			Derma_Message( "You are not allowed to change inheritance of the group \"user\"!", "XGUI NOTICE" )
		end
	end
end

xgui_group_users = x_makelistview{ x=5, y=205, w=130, h=140, multiselect=false, parent=xgui_group, headerheight=0 }
xgui_group_users:AddColumn( "" )
xgui_group_users.OnRowSelected = function( )
	xgui_restrict_color = Color( 255, 128, 0, 255 )
	xgui_changeuserbtn:SetDisabled( false )
	xgui_getUserAccess( xgui_group_users:GetSelected()[1]:GetColumnText(1) )
end

xgui_adduserbtn = x_makebutton{ x=5, y=345, w=65, label="Add..", parent=xgui_group }
xgui_adduserbtn.DoClick = function()
	xgui_list_players = DermaMenu()
	for k, v in pairs( player.GetAll() ) do	
		if v:GetUserGroup() ~= xgui_group_list:GetSelected()[1]:GetColumnText(1) then
			xgui_list_players:AddOption( v:Nick() .. " - " .. v:GetUserGroup(), function()
							RunConsoleCommand( "ulx", "adduser", v:Nick(), xgui_group_list:GetSelected()[1]:GetColumnText(1) )
							for ID, ply in pairs( xgui_data.users ) do
								if ply.name == v:Nick() then
									xgui_data.users[ID].group = xgui_group_list:GetSelected()[1]:GetColumnText(1)
								end
							end
							xgui_getGroupsUsers()
							end)
		end
	end
	xgui_list_players:AddSpacer()
	
	for ID, user in pairs( xgui_data.users ) do
		if not IsOnline( ID ) and user.group ~= xgui_group_list:GetSelected()[1]:GetColumnText(1) then
			xgui_list_players:AddOption( user.name .. " - " .. user.group, function()
				RunConsoleCommand( "ulx", "adduserid", ID,  xgui_group_list:GetSelected()[1]:GetColumnText(1) )
				xgui_data.users[ID].group = xgui_group_list:GetSelected()[1]:GetColumnText(1)
				xgui_getGroupsUsers()
				end)
		end
	end
	xgui_list_players:AddSpacer()
	xgui_list_players:AddOption( "Add by SteamID...", function()
				local xgui_adduid = x_makeframepopup{ label="Add ID to group " .. xgui_group_list:GetSelected()[1]:GetColumnText(1), w=150, h=80 }
				local xgui_theid = x_maketextbox{ x=5, y=30, w=140, parent=xgui_adduid, text="Enter STEAMID..." }
				x_makebutton{ x=55, y=55, w=40, label="Add", parent=xgui_adduid }.DoClick = function()
					RunConsoleCommand( "ulx", "adduserid", "\"" .. xgui_theid:GetValue() .. "\"", xgui_group_list:GetSelected()[1]:GetColumnText(1) )
					xgui_data.users[xgui_theid:GetValue()].group = xgui_group_list:GetSelected()[1]:GetColumnText(1)
					xgui_getGroupsUsers()
				end
				end)
	xgui_list_players:Open()
end

xgui_changeuserbtn = x_makebutton{ x=70, y=345, w=65, label="Change..", parent=xgui_group }
xgui_changeuserbtn.DoClick = function()
	xgui_list_groups = DermaMenu()
	for k, v in pairs( ULib.ucl.groups ) do
		if k ~= xgui_group_list:GetSelected()[1]:GetColumnText(1) and k ~= "user" then
			if xgui_group_users:GetSelected()[1]:GetColumnText(2) ~= "" and not IsOnline( xgui_group_users:GetSelected()[1]:GetColumnText(1), true ) then
				xgui_list_groups:AddOption( k, function() 
										LocalPlayer():ConCommand( "ulx adduserid \"" .. xgui_group_users:GetSelected()[1]:GetColumnText(2) .. "\" " .. k )
										xgui_data.users[xgui_group_users:GetSelected()[1]:GetColumnText(2)].group = k
										xgui_getGroupsUsers()
										end )
			else
				xgui_list_groups:AddOption( k, function() 
										local name = xgui_group_users:GetSelected()[1]:GetColumnText(1)
										RunConsoleCommand( "ulx", "adduser", name, k )
										for ID, ply in pairs( xgui_data.users ) do
											if ply.name == name then 
												xgui_data.users[ID].group = k
											end
										end
										xgui_getGroupsUsers()
										end )
			end
		end
	end
	xgui_list_groups:AddSpacer()
	xgui_list_groups:AddOption( "Remove User", function() 
						name = xgui_group_users:GetSelected()[1]:GetColumnText(1)
						if IsOnline( name, true ) then
							RunConsoleCommand( "ulx", "removeuser", name )
						else
							for ID, user in pairs( xgui_data.users ) do
								if user.name == name then RunConsoleCommand( "ulx", "removeuser", user.name ) end
							end
						end
						xgui_data.users[xgui_group_users:GetSelected()[1]:GetColumnText(2)] = nil
						xgui_getGroupsUsers()
						end )
	xgui_list_groups:Open()
end

xgui_base:AddSheet( "Groups", xgui_group, "gui/silkicons/group", false, false )

xgui_group.XGUI_Refresh = function()
	xgui_restrict_color = Color( 255, 255, 255, 0 )
	RunConsoleCommand( "xgui", "getdata", "users" )
	xgui_group_list:Clear()
	xgui_group_users:Clear()
	xgui_group_name:SetText( "" )
	xgui_group_inherit:Clear()
	xgui_group_inherit:SetText( "user" )
	xgui_clearInh()
	xgui_SortGroups( ULib.ucl.getInheritanceTree() )
	xgui_changeuserbtn:SetDisabled( true )
	xgui_adduserbtn:SetDisabled( true )
	xgui_groupremove:SetDisabled( true )
	xgui_layoutLists()
end
hook.Add( "UCLCHANGED", "XGUI_updategroups", xgui_group.XGUI_Refresh )

function xgui_SortGroups( t )
	for k, v in pairs( t ) do
		xgui_SortGroups( v )
	end
	for k, v in pairs( t ) do
		xgui_group_list:AddLine( k )
		xgui_group_inherit:AddChoice( k )
	end
end

function xgui_getGroupsUsers()
	xgui_group_users:Clear()
	xgui_changeuserbtn:SetDisabled( true )
	if xgui_group_list:GetSelected()[1]:GetColumnText(1) ~= "user" then
		for ID, user in pairs( xgui_data.users ) do
			if user.group == xgui_group_list:GetSelected()[1]:GetColumnText(1) then
				if user.name == nil or user.name == "" then user.name = ID end
				xgui_group_users:AddLine( user.name, ID ).Paint = function( self )
					local Col = nil
					if ( self:IsSelected() ) then
							Col = Color( 255, 128, 0, 255 )
					elseif ( self.Hovered ) then
							Col = Color( 70, 70, 70, 255 )
					elseif ( self.m_bAlt ) then
							Col = Color( 55, 55, 55, 255 )
					else
							return
					end
					surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
					surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
				end
			end
		end
	else
		for k, v in pairs( player.GetAll() ) do
			if v:GetUserGroup() == "user" then
				xgui_group_users:AddLine( v:Nick() ).Paint = function( self )
					local Col = nil
					if ( self:IsSelected() ) then
							Col = Color( 255, 128, 0, 255 )
					elseif ( self.Hovered ) then
							Col = Color( 70, 70, 70, 255 )
					elseif ( self.m_bAlt ) then
							Col = Color( 55, 55, 55, 255 )
					else
							return
					end
					surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
					surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
				end
			end
		end
	end
end

function xgui_getGroupAccess( objname )
	xgui_clearInh()
	for name, access in pairs( ULib.ucl.groups[objname].allow ) do
		if type(name) == "number" then  --Determine if this command does not have restrictions
			if ULib.cmds.translatedCmds[access] then --Check if its a command or other access string
				xgui_access_list:AddLine( access )
			else
				xgui_access_otherlist:AddLine( access )
			end
		else
			xgui_access_list:AddLine( name, "R", access )
		end
		--Loop through the inherited groups
		while ( ULib.ucl.groups[objname].inherit_from ~= nil ) do
			objname = ULib.ucl.groups[objname].inherit_from
			for name, access in pairs( ULib.ucl.groups[objname].allow ) do
				if type(name) == "number" then  --Determine if this command does not have restrictions
					if ULib.cmds.translatedCmds[access] then --Check if its a command or other access string
						xgui_inhaccess_list:AddLine( access )
					else
						xgui_inhaccess_otherlist:AddLine( access )
					end
				else
					xgui_inhaccess_list:AddLine( name, "R", access )
				end
			end
		end
	end
	xgui_layoutLists()
end

function xgui_getUserAccess( objname )
	xgui_clearInh()
	local group = nil
	for ID, ply in pairs( xgui_data.users ) do
		if ply.name == objname then
			objname = ID
			group = ply.group
		end
	end
	for name, access in pairs( xgui_data.users[objname].allow ) do
		if type(name) == "number" then  --Determine if this command does not have restrictions
			if ULib.cmds.translatedCmds[access] then --Check if its a command or other access string
				xgui_access_list:AddLine( access )
			else
				xgui_access_otherlist:AddLine( access )
			end
		else
			xgui_access_list:AddLine( name, "R", access )
		end
	end
	while ( ULib.ucl.groups[group].inherit_from ~= nil ) do
		for name, access in pairs( ULib.ucl.groups[group].allow ) do
			if type(name) == "number" then  --Determine if this command does not have restrictions
				if ULib.cmds.translatedCmds[access] then --Check if its a command or other access string
					xgui_inhaccess_list:AddLine( access )
				else
					xgui_inhaccess_otherlist:AddLine( access )
				end
			else
				xgui_inhaccess_list:AddLine( name, "R", access )
			end
		end
		group = ULib.ucl.groups[group].inherit_from
	end
	xgui_layoutLists()
end

function xgui_layoutLists()
	xgui_inhaccess_otherlist:SetHeight( 17*#xgui_inhaccess_otherlist:GetLines() )
	xgui_access_otherlist:SetHeight( 17*#xgui_access_otherlist:GetLines() )
	xgui_access_list:SetHeight( 17*#xgui_access_list:GetLines() )
	xgui_inhaccess_list:SetHeight( 17*#xgui_inhaccess_list:GetLines() )
	xgui_access_plist:PerformLayout()
	xgui_inhaccess_plist:PerformLayout()
	xgui_access_list:SortByColumn( 1 )
	xgui_inhaccess_list:SortByColumn( 1 )
end

function xgui_clearInh()
	xgui_access_list:Clear()
	xgui_inhaccess_list:Clear()
	xgui_inhaccess_otherlist:Clear()
	xgui_access_otherlist:Clear()
end

function IsOnline( ID, checkName )
	if not checkName then
		for _, v in pairs( player.GetAll() ) do
			if xgui_data.users[ID].name == v:Nick() then
				return true
			end
		end
	else
		for _, v in pairs( player.GetAll() ) do
			if ID == v:Nick() then
				return true
			end
		end
	end
	return false
end