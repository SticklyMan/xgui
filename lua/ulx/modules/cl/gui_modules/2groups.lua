--Groups module for ULX GUI -- by Stickly Man!
--Manages groups and players within groups

xgui_group = x_makeXpanel( )

x_makelabel{ x=5, y=10, label="Groups", parent=xgui_group, textcolor=Color( 0, 0, 0, 255 ) }
x_makelabel{ x=135, y=10, label="Allowed Access", parent=xgui_group, textcolor=Color( 0, 0, 0, 255 ) }
x_makelabel{ x=265, y=10, label="Inherited Access", parent=xgui_group, textcolor=Color( 0, 0, 0, 255 ) }

xgui_access_list = x_makelistview{ x=135, y=30, w=125, h=250, multiselect=true, parent=xgui_group, headerheight=0 }
xgui_access_list:AddColumn( "" )
xgui_inhaccess_list = x_makelistview{ x=265, y=30, w=125, h=250, multiselect=false, parent=xgui_group, headerheight=0 } 
xgui_inhaccess_list:AddColumn( "" )

xgui_group_list = x_makelistview{ x=5, y=30, w=125, h=125, multiselect=false, parent=xgui_group, headerheight=0 }
xgui_group_list:AddColumn( "" )
xgui_group_list.OnRowSelected = function()
	xgui_access_list:Clear()
	xgui_inhaccess_list:Clear()
	local group = xgui_group_list:GetSelected()[1]:GetColumnText(1)
	xgui_group_name:SetText( group )
	if ULib.ucl.groups[group].inherit_from ~= nil then
		xgui_group_inherit:SetText( ULib.ucl.groups[group].inherit_from )
	else
		xgui_group_inherit:SetText( "user" )
	end
	for _, access in ipairs( ULib.ucl.groups[group].allow ) do
		xgui_access_list:AddLine( access )
	end
	while ( ULib.ucl.groups[group].inherit_from ~= nil ) do
		group = ULib.ucl.groups[group].inherit_from
		for _, access in ipairs( ULib.ucl.groups[group].allow ) do
			xgui_inhaccess_list:AddLine( access )
		end
	end
end

x_makebutton{ x=5, y=155, w=20, h=20, label="+", parent=xgui_group }.DoClick = function()
	local function newgroup( count )
		local checkname
		if count == 0 then
			checkname = "new group"
		else 
			checkname = "new group" .. count
		end
		if xgui_group_list:GetLineByColumnText( checkname, 1 ) == nil then
				RunConsoleCommand( "ulx", "addgroup", checkname )
		else
			newgroup( count+1 )
		end
	end
	newgroup( 0 )
end

x_makebutton{ x=25, y=155, w=20, h=20, label="-", parent=xgui_group }.DoClick = function()
	if xgui_group_list:GetSelectedLine() then
		if xgui_group_list:GetSelected()[1]:GetColumnText(1) ~= "user" then
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
		else
			Derma_Message( "You are not allowed to remove the group \"user\"!", "XGUI NOTICE" )
		end
	end
end

xgui_group_name = x_maketextbox{ x=45, y=155, w=85, focuscontrol=true, parent=xgui_group }
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

x_makelabel{ x=5, y=178, label="Inherits", parent=xgui_group, textcolor=Color( 0, 0, 0, 255 ) }
xgui_group_inherit = x_makemultichoice{ x=45, y=175, w=85, parent=xgui_group }
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

xgui_base:AddSheet( "Groups", xgui_group, "gui/silkicons/group", false, false )

xgui_group.XGUI_Refresh = function()
	xgui_group_list:Clear()
	xgui_group_name:SetText( "" )
	xgui_group_inherit:Clear()
	xgui_group_inherit:SetText( "user" )
	xgui_SortGroups( ULib.ucl.getInheritanceTree() )
end
hook.Add( ULib.HOOK_UCLCHANGED, "XGUI_updategroups", xgui_group.XGUI_Refresh )

function xgui_SortGroups( t )
	for k, v in pairs( t ) do
		xgui_SortGroups( v )
	end
	for k, v in pairs( t ) do
		xgui_group_list:AddLine( k )
		xgui_group_inherit:AddChoice( k )
	end
end
