--Groups module for ULX GUI -- by Stickly Man!
--Manages groups and players within groups

xgui_group = x_makeXpanel( )

x_makelabel{ x=5, y=10, label="Groups", parent=xgui_group, textcolor=Color( 0, 0, 0, 255 ) }

xgui_group_list = x_makelistview{ x=5, y=30, w=125, h=125, multiselect=false, parent=xgui_group, headerheight=0 }
xgui_group_list:AddColumn( "" )
xgui_group_list.OnRowSelected = function()
	xgui_group_name:SetText( xgui_group_list:GetSelected()[1]:GetColumnText(1) )
	if ULib.ucl.groups[xgui_group_list:GetSelected()[1]:GetColumnText(1)].inherit_from ~= nil then
		xgui_group_inherit:SetText( ULib.ucl.groups[xgui_group_list:GetSelected()[1]:GetColumnText(1)].inherit_from )
	else
		xgui_group_inherit:SetText( "<none>" )
	end
end

x_makebutton{ x=5, y=155, w=20, h=20, label="+", parent=xgui_group }.DoClick = function()
	RunConsoleCommand( "ulx", "addgroup", "new group" )
	xgui_group.XGUI_Refresh()
end

x_makebutton{ x=25, y=155, w=20, h=20, label="-", parent=xgui_group }.DoClick = function()
	if xgui_group_list:GetSelectedLine() then
		if xgui_group_list:GetSelected()[1]:GetColumnText(1) ~= "user" then
			if xgui_group_list:GetSelected()[1]:GetColumnText(1) ~= "superadmin" then
				Derma_Query( "Are you sure you would like to remove the \"" .. xgui_group_list:GetSelected()[1]:GetColumnText(1) .. "\" group?", "XGUI WARNING", 
					   "Remove", function() RunConsoleCommand( "ulx", "removegroup", xgui_group_list:GetSelected()[1]:GetColumnText(1) ) xgui_group.XGUI_Refresh() end,
					   "Cancel", function() end )
			else
				Derma_Query( "Removng superadmin is generally a bad idea. Are you sure you would like to remove it?", "XGUI WARNING", 
					   "Remove", function() RunConsoleCommand( "ulx", "removegroup", xgui_group_list:GetSelected()[1]:GetColumnText(1) ) xgui_group.XGUI_Refresh() end,
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
					RunConsoleCommand( "ulx", "renamegroup", xgui_group_list:GetSelected()[1]:GetColumnText(1), xgui_group_name:GetValue() ) xgui_group.XGUI_Refresh()
				else
					Derma_Query( "Renaming superadmin is generally a bad idea. Are you sure you would like to rename it?", "XGUI WARNING", 
						   "Rename", function() RunConsoleCommand( "ulx", "renamegroup", xgui_group_list:GetSelected()[1]:GetColumnText(1), xgui_group_name:GetValue() ) xgui_group.XGUI_Refresh() end,
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
			if xgui_group_inherit:GetText() ~= "<none>" then
				RunConsoleCommand( "xgui_setinh", xgui_group_list:GetSelected()[1]:GetColumnText(1), xgui_group_inherit:GetText() )
			else
				RunConsoleCommand( "xgui_setinh", xgui_group_list:GetSelected()[1]:GetColumnText(1) )
			end
			xgui_group.XGUI_Refresh()
		else
			Derma_Message( "You are not allowed to change inheritance of the group \"user\"!", "XGUI NOTICE" )
		end
	end
end

xgui_base:AddSheet( "Groups", xgui_group, "gui/silkicons/group", false, false )

xgui_group.XGUI_Refresh = function()
	timer.Simple( 0.05, function()
		xgui_group_list:Clear()
		xgui_group_inherit:Clear()
		xgui_group_inherit:SetText( "<none>" )
		xgui_group_inherit:AddChoice( "<none>" )
		for k, _ in pairs( ULib.ucl.groups ) do
			xgui_group_list:AddLine( k )
			xgui_group_inherit:AddChoice( k )
		end
	end )
end