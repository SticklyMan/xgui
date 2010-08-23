--Groups/Players module V2 for ULX GUI -- by Stickly Man!
--Manages groups and players within groups, teams, and permissions/restrictions

local groups = x_makeXpanel{ parent=xgui.null }
groups.list = x_makemultichoice{ x=5, y=5, w=175, parent=groups }
function groups.list:populate( isGroupManagement )
	local prev_sel = self:GetValue()
	if prev_sel == "" then prev_sel = "Select a group..." end
	self:Clear()
	if isGroupManagement then 
		for _, v in ipairs( xgui.data.groups ) do
			self:AddChoice( v )
		end
		self:AddChoice( "--*" )
		self:AddChoice( "Manage Groups..." )
		self:SetText( groups.lastOpenGroup or prev_sel )
		if groups.lastOpenGroup then
			if ULib.ucl.groups[groups.lastOpenGroup] then --Group still exists
				groups.getGroupData( groups.lastOpenGroup )
			else
				groups.pnlG1:Close()
				groups.animQueue_call()
				self:SetText( "Select a group..." )
			end
		end
	else
		for _, v in ipairs( player.GetAll() ) do
			self:AddChoice( v:Nick() .. " - " .. v:GetUserGroup() )
		end
		self:SetText( "Select Player..." )
	end
end
groups.list.OnSelect = function( self, index, value, data )
	if value ~= "Manage Groups..." then
		if value ~= groups.lastOpenGroup then
			groups.lastOpenGroup = value
			groups.pnlG1:Open( value )
		end
	else
		groups.lastOpenGroup = nil
		groups.pnlG2:Open()
	end
end
groups.isGroupManagement = true
groups.lastOpenGroup = nil

--[[groups.mode = x_makebutton{ x=180, y=5, w=150, label="Switch to player management", parent=groups }
groups.mode.DoClick = function( self )
	groups.isGroupManagement = not groups.isGroupManagement
	self:SetText( groups.isGroupManagement and "Switch to player management" or "Switch to group management"  )
	groups.list:populate( groups.isGroupManagement )
end]]--
groups.clippanela = x_makepanel{ x=5, y=30, w=580, h=335, parent=groups }
groups.clippanela.Paint = function( self ) end
groups.clippanelb = x_makepanel{ x=175, y=30, w=410, h=335, visible=false, parent=groups }
groups.clippanelb.Paint = function( self ) end

------Groups Panel 1 (Users, Teams)
groups.pnlG1 = x_makepanel{ w=170, h=335, parent=groups.clippanela }
groups.pnlG1:SetVisible( false )
function groups.pnlG1:Open( group )
	if self:IsVisible() then --Is open, lets close it first.
		self:Close()
	elseif groups.pnlG2:IsVisible() then
		groups.pnlG2:closeAnim()
	end
	self:openAnim( group )
	groups.animQueue_call()
end
function groups.pnlG1:Close()
	if groups.pnlG3:IsVisible() then
		groups.pnlG3:closeAnim()
	end
	if groups.pnlG4:IsVisible() then
		groups.pnlG4:Close()
	end
	self:closeAnim()
end
x_makelabel{ x=5, y=5, label="Users in group:", parent=groups.pnlG1, textcolor=color_black }
groups.players = x_makelistview{ x=5, y=20, w=160, h=190, parent=groups.pnlG1 }
groups.players:AddColumn( "Name" )
groups.players.OnRowSelected = function( self, LineID, Line )
	groups.cplayer:SetDisabled( false )
end
groups.aplayer = x_makebutton{ x=5, y=210, w=80, label="Add...", parent=groups.pnlG1 }
groups.aplayer.DoClick = function()
	local menu = DermaMenu()
	for k, v in ipairs( player.GetAll() ) do
		if v:GetUserGroup() ~= groups.list:GetValue() then
			menu:AddOption( v:Nick() .. "  |  " .. v:GetUserGroup(), function() groups.changeUserGroup( v:SteamID(), groups.list:GetValue() ) end )
		end
	end
	menu:AddSpacer()
	for ID, v in pairs( xgui.data.users ) do
		if v.group ~= groups.list:GetValue() and not groups.isOnline( ID ) then
			menu:AddOption( ( v.name or ID ) .. "  |  " .. v.group, function() groups.changeUserGroup( ID, groups.list:GetValue() ) end )
		end
	end
	menu:AddSpacer()
	menu:AddOption( "Add by SteamID...", function() groups.addBySteamID( groups.list:GetValue() ) end )
	menu:Open()
end
groups.cplayer = x_makebutton{ x=85, y=210, w=80, label="Change...", disabled=true, parent=groups.pnlG1 }
groups.cplayer.DoClick = function()
	if groups.players:GetSelectedLine() then
		local ID = groups.players:GetSelected()[1]:GetColumnText(2)
		local menu = DermaMenu()
		for k, _ in pairs( ULib.ucl.groups ) do
			if k ~= "user" and k ~= groups.list:GetValue() then
				menu:AddOption( k, function() groups.changeUserGroup( ID, k ) end )
			end
		end
		menu:AddSpacer()
		menu:AddOption( "Remove User", function() groups.changeUserGroup( ID, "user" ) end )
		menu:Open()
	end
end
x_makelabel{ x=5, y=240, label="Team:", parent=groups.pnlG1, textcolor=color_black }
groups.teams = x_makemultichoice{ x=5, y=255, w=160, parent=groups.pnlG1 }
groups.teams.OnSelect = function( self, index, value, data )
	if value == "<None>" then value = "" end
	RunConsoleCommand( "xgui", "changeGroupTeam", groups.list:GetValue(), value )
end
x_makebutton{ x=5, y=275, w=160, label="Manage Teams >>", parent=groups.pnlG1 }.DoClick = function()
	groups.pnlG3:Open()
end
x_makebutton{ x=5, y=310, w=160, label="Manage Permissions >>", parent=groups.pnlG1 }.DoClick = function()
	groups.pnlG4:Open()
end

------Groups Panel 2 (Group Management)
groups.pnlG2 = x_makepanel{ w=350, h=200, parent=groups.clippanela }
groups.pnlG2:SetVisible( false )
groups.glist = x_makelistview{ x=5, y=5, h=170, w=130, headerheight=0, parent=groups.pnlG2 }
groups.glist:AddColumn( "Groups" )
groups.glist.populate = function( self )
	local previous_group = nil
	local prev_inherit = groups.ginherit:GetValue()
	if groups.glist:GetSelectedLine() then previous_group = groups.glist:GetSelected()[1]:GetColumnText(1) end
	self:Clear()
	groups.ginherit:Clear()
	groups.ginherit:SetText( prev_inherit )
	for _, v in ipairs( xgui.data.groups ) do
		local l = self:AddLine( v )
		groups.ginherit:AddChoice( v )
		if v == previous_group then
			previous_group = true
			self:SelectItem( l )
		end
	end
	if previous_group and previous_group ~= true then
		groups.newgroup.DoClick()
	end
end
groups.glist.OnRowSelected = function( self, LineID, Line )
	local group = Line:GetColumnText(1)
	groups.gname:SetValue( group )
	groups.ginherit:SetText( ULib.ucl.groups[group].inherit_from or "user" )
	if group ~= "user" then
		groups.gdelete:SetDisabled( false )
	else
		groups.gdelete:SetDisabled( true )
	end
	groups.newgroup:SetDisabled( false )
	groups.gupdate:SetText( "Update" )
end
groups.newgroup = x_makebutton{ x=5, y=175, w=130, disabled=true, label="Create New...", parent=groups.pnlG2 }
groups.newgroup.DoClick = function()
	groups.gname:SetText( "new_group" )
	groups.ginherit:SetText( "user" )
	groups.glist:ClearSelection()
	groups.gdelete:SetDisabled( true )
	groups.newgroup:SetDisabled( true )
	groups.gupdate:SetText( "Create" )
end
x_makelabel{ x=145, y=8, label="Name:", textcolor=color_black, parent=groups.pnlG2 }
x_makelabel{ x=145, y=33, label="Inherits from:", textcolor=color_black, parent=groups.pnlG2 }
groups.gname = x_maketextbox{ x=180, y=5, w=165, text="new_group", focuscontrol=true, parent=groups.pnlG2 }
groups.ginherit = x_makemultichoice{ x=215, y=30, w=130, text="user", parent=groups.pnlG2 }
groups.gupdate = x_makebutton{ x=140, y=175, w=100, label="Create", parent=groups.pnlG2 }
groups.gupdate.DoClick = function( self )
	if self:GetValue() == "Update" then --Sanity check, make sure we're not trying to create a new group accidentally
		local oldname = groups.glist:GetSelected()[1]:GetColumnText(1)
		local oldinheritance = ULib.ucl.groups[oldname].inherit_from
		local newinheritance = groups.ginherit:GetValue()
		
		if newinheritance == "user" then newinheritance = nil end
		
		if groups.gname:GetValue() ~= oldname then
			if oldname == "superadmin" or oldname == "admin" then
				Derma_Query( "Renaming the " .. oldname .. " group is generally a bad idea, and it could break some plugins. Are you sure?", "XGUI WARNING", 
					"Rename to " .. groups.gname:GetValue(), function()
						RunConsoleCommand( "ulx", "renamegroup", oldname, groups.gname:GetValue() )
						oldname = groups.gname:GetValue() end,
					"Cancel", function() end )
			else
				RunConsoleCommand( "ulx", "renamegroup", oldname, groups.gname:GetValue() )
				oldname = groups.gname:GetValue()
			end
		end
		
		if newinheritance ~= oldinheritance then
			if newinheritance == nil then
				ULib.queueFunctionCall( RunConsoleCommand, "xgui", "setinheritance", oldname, ULib.ACCESS_ALL )
			else
				ULib.queueFunctionCall( RunConsoleCommand, "xgui", "setinheritance", oldname, newinheritance )
			end
		end
	else
		RunConsoleCommand( "ulx", "addgroup", groups.gname:GetValue(), groups.ginherit:GetValue() )
	end
end
groups.gdelete = x_makebutton{ x=245, y=175, w=100, label="Delete", disabled=true, parent=groups.pnlG2 }
groups.gdelete.DoClick = function()
	local group = groups.gname:GetValue()
	if group == "superadmin" or group == "admin" then
		Derma_Query( "Removing the " .. group .. " group is generally a bad idea, and it could break some plugins. Are you sure?", "XGUI WARNING", 
			"Remove", function()
				RunConsoleCommand( "ulx", "removegroup", group ) end,
			"Cancel", function() end )
	else
		Derma_Query( "Are you sure you would like to remove the \"" .. group .. "\" group?", "XGUI WARNING", 
			"Remove", function()
				RunConsoleCommand( "ulx", "removegroup", group ) end,
			"Cancel", function() end )
	end
end
function groups.pnlG2:Open()
	if not self:IsVisible() then			
		if groups.pnlG1:IsVisible() then
			groups.pnlG1:Close()
		end
		self:openAnim()
		groups.animQueue_call()
	end
end

------Groups Panel 3 (Teams Management)
groups.pnlG3 = x_makepanel{ y=130, w=405, h=205, parent=groups.clippanelb }
groups.pnlG3:SetVisible( false )
function groups.pnlG3:Open()
	if not self:IsVisible() then
		if groups.pnlG4:IsVisible() then
			groups.pnlG4:Close()
		end
		self:openAnim()
		groups.animQueue_call()
	end
end
groups.teamlist = x_makelistview{ x=5, y=5, w=100, h=155, headerheight=0, parent=groups.pnlG3 }
groups.teamlist:AddColumn( "Teams" )
groups.teamlist.OnRowSelected = function( self, LineID, Line )
	local team = Line:GetColumnText(1)
	groups.teamdelete:SetDisabled( false )
	groups.upbtn:SetDisabled( LineID == 1 )
	groups.downbtn:SetDisabled( LineID == #self.Lines )
	groups.teammodadd:SetDisabled( false )
	
	local lastmod = groups.teammodifiers:GetSelectedLine() and groups.teammodifiers:GetSelected()[1]:GetColumnText(1)
	groups.teammodifiers:Clear()
	for _, chteam in pairs( xgui.data.teams ) do
		if chteam.name == team then
			for k, v in pairs( chteam ) do
				if k ~= "index" and k ~= "order" and k ~= "groups" then
					local value = v
					if k == "color" then
						value = v.r .. " " .. v.g .. " " .. v.b
					end
					local l = groups.teammodifiers:AddLine( k, value, type( value ) )
					if k == lastmod then
						groups.teammodifiers:SelectItem( l )
						lastmod = true
					end
				end
			end
			break
		end
	end
	if lastmod == true then --A row was found and selected
		groups.teammodremove:SetDisabled( false )
	else
		groups.teammodremove:SetDisabled( true )
	end
	groups.teammodifiers:SortByColumn( 1, false )
	if not groups.teammodifiers:GetSelectedLine() then
		groups.teammodspace:Clear()
	end
end

x_makebutton{ x=5, y=160, w=80, label="Create New", parent=groups.pnlG3 }.DoClick = function()
	for _, v in ipairs( xgui.data.teams ) do
		if v.name == "New_Team" then return end
	end
	RunConsoleCommand( "xgui", "createTeam", "New_Team", 255, 255, 255 )
end
groups.teamdelete = x_makebutton{ x=5, y=180, w=80, label="Delete", disabled=true, parent=groups.pnlG3 }
groups.teamdelete.DoClick = function()
	local team = groups.teamlist:GetSelected()[1]:GetColumnText(1)
	Derma_Query( "Are you sure you would like to remove the \"" .. team .. "\" team?", "XGUI WARNING",
		"Remove", function() RunConsoleCommand( "xgui", "removeTeam", team ) end,
		"Cancel", function() end )
end
groups.upbtn = x_makesysbutton{ x=85, y=160, w=20, btype="up", disabled=true, parent=groups.pnlG3 }
groups.upbtn.DoClick = function()
	groups.upbtn:SetDisabled( true )
	local lineID = groups.teamlist:GetSelectedLine()
	RunConsoleCommand( "xgui", "updateTeamValue",  groups.teamlist.Lines[lineID]:GetColumnText(1), "order", lineID-1 )
	RunConsoleCommand( "xgui", "updateTeamValue",  groups.teamlist.Lines[lineID-1]:GetColumnText(1), "order", lineID, "true" )
end
groups.downbtn = x_makesysbutton{ x=85, y=180, w=20, btype="down", disabled=true, parent=groups.pnlG3 }
groups.downbtn.DoClick = function()
	groups.downbtn:SetDisabled( true )
	local lineID = groups.teamlist:GetSelectedLine()
	RunConsoleCommand( "xgui", "updateTeamValue",  groups.teamlist.Lines[lineID]:GetColumnText(1), "order", lineID+1 )
	RunConsoleCommand( "xgui", "updateTeamValue",  groups.teamlist.Lines[lineID+1]:GetColumnText(1), "order", lineID, "true" )
end
groups.teammodifiers = x_makelistview{ x=110, y=5, h=175, w=150, parent=groups.pnlG3 }
groups.teammodifiers:AddColumn( "Modifiers" ).DoClick = function() end
groups.teammodifiers:AddColumn( "Value" ).DoClick = function() end
groups.teammodifiers.OnRowSelected = function( self, LineID, Line )
	groups.teammodremove:SetDisabled( Line:GetColumnText(1) == "name" or Line:GetColumnText(1) == "color" )
	groups.teammodspace:Clear()
	local ctrl
	local applybtn = x_makebutton{ label="Apply" }
	if Line:GetColumnText(3) ~= "number" then
		if Line:GetColumnText(1) == "name" then
			ctrl = x_maketextbox{ focuscontrol=true, text=Line:GetColumnText(2) }
			ctrl.OnEnter = function()
				applybtn.DoClick()
			end
			groups.teammodspace:AddItem( ctrl )
		elseif Line:GetColumnText(1) == "color" then
			ctrl = x_makecolorpicker{ focuscontrol=true, removealpha=true }
			local tempcolor = string.Explode( " ", Line:GetColumnText(2) )
			ULib.queueFunctionCall( RunConsoleCommand, "colour_r", tempcolor[1] )
			ULib.queueFunctionCall( RunConsoleCommand, "colour_g", tempcolor[2] )
			ULib.queueFunctionCall( RunConsoleCommand, "colour_b", tempcolor[3] )
			groups.teammodspace:AddItem( ctrl )
		elseif Line:GetColumnText(1) == "model" then
			ctrl = x_maketextbox{ focuscontrol=true, text=Line:GetColumnText(2) }
			ctrl.OnEnter = function( self )
				applybtn.DoClick()
				for i, v in ipairs( groups.modelList.Items ) do
					if v.name == self:GetValue() or v.model == self:GetValue() then
						groups.modelList:SelectPanel( v )
						break
					end
				end
			end
			groups.teammodspace:AddItem( ctrl )
			groups.setTeamModel = function( name ) --This func is called when any of the spawnicons in the playerlist are pressed.
				ctrl:SetText( name )
				applybtn.DoClick()
			end
			for _, item in pairs( groups.modelList.Items ) do
				if Line:GetColumnText(2) == item.name or Line:GetColumnText(2) == item.model then
					groups.modelList:SelectPanel( item )
					break
				end
			end
			groups.teammodspace:AddItem( groups.modelList )
		end
	else
		ctrl = x_makeslider{ min=0, max=2000, decimal=1, textcolor=color_black, value=tonumber( Line:GetColumnText(2) ), label=Line:GetColumnText(1) }
		ctrl.Wang.TextEntry.OnEnter = function( self )
			applybtn.DoClick()
		end
		groups.teammodspace:AddItem( ctrl )
	end
	applybtn.DoClick = function()
		if Line:GetColumnText(1) == "color" then
			RunConsoleCommand( "xgui", "updateTeamValue", groups.teamlist:GetSelected()[1]:GetColumnText(1), Line:GetColumnText(1), GetConVarNumber( "colour_r" ), GetConVarNumber( "colour_g" ), GetConVarNumber( "colour_b" ) )
		else
			if Line:GetColumnText(1) == "name" then --Check if a team by this name already exists!
				for _, v in ipairs( xgui.data.teams ) do
					if v.name == ctrl:GetValue() then return end
				end
			end
			RunConsoleCommand( "xgui", "updateTeamValue", groups.teamlist:GetSelected()[1]:GetColumnText(1), Line:GetColumnText(1), ctrl:GetValue() )
		end
	end
	if Line:GetColumnText(1) ~= "model" then groups.teammodspace:AddItem( applybtn ) end
end

groups.teammodadd = x_makebutton{ x=110, y=180, w=75, label="Add..", disabled=true, parent=groups.pnlG3 }
groups.teammodadd.DoClick = function()
	local team = groups.teamlist:GetSelected()[1]:GetColumnText(1)
	local teamdata
	for i, v in pairs( xgui.data.teams ) do
		if v.name == team then teamdata = v end
	end
	local allowed = { 
		armor = 0,
		crouchedWalkSpeed = 0.6,
		deaths = 0,
		duckSpeed = 0.3,
		frags = 0,
		gravity = 1,
		health = 100,
		jumpPower = 160,
		maxHealth = 100,
		maxSpeed = 250,
		model = "kleiner",
		runSpeed = 500,
		stepSize = 18,
		unDuckSpeed = 0.2,
		walkSpeed = 250 }
	
	local allowedSorted = {}
    for k,_ in pairs(allowed) do table.insert(allowedSorted, k) end
    table.sort( allowedSorted, function( a,b ) return string.lower( a ) < string.lower( b ) end )

	local menu = DermaMenu()
	for _, allowedname in pairs( allowedSorted ) do
		local add = true
		for name, data in pairs( teamdata ) do
			if name == allowedname then
				add = false
				break
			end
		end
		if add then 
			menu:AddOption( allowedname, function() RunConsoleCommand( "xgui", "updateTeamValue", team, allowedname, allowed[allowedname] ) end )
		end
	end
	menu:Open()
end
groups.teammodremove = x_makebutton{ x=185, y=180, w=75, label="Remove", disabled=true, parent=groups.pnlG3 }
groups.teammodremove.DoClick = function()
	local team = groups.teamlist:GetSelected()[1]:GetColumnText(1)
	local modifier = groups.teammodifiers:GetSelected()[1]:GetColumnText(1)
	RunConsoleCommand( "xgui", "updateTeamValue", team, modifier, "" )
end
groups.teammodspace = x_makepanellist{ x=265, y=5, w=140, h=195, padding=1, parent=groups.pnlG3 }
groups.teammodspace.Paint = function() end

------Groups Panel 4 (Access Management)
groups.pnlG4 = x_makepanel{ y=130, w=200, h=335, parent=groups.clippanelb }
groups.pnlG4:SetVisible( false )
function groups.pnlG4:Open()
	if not self:IsVisible() then
		if groups.pnlG3:IsVisible() then
			groups.pnlG3:closeAnim()
		end
		self:openAnim()
		groups.animQueue_call()
	end
end
function groups.pnlG4:Close()
	self.closeAnim()
end
x_makelabel{ x=5, y=5, label="Has access to:  (Disabled = inherited)", textcolor=color_black, parent=groups.pnlG4 }
groups.accesses = x_makepanellist{ x=5, y=20, w=190, h=310, padding=1, spacing=1, parent=groups.pnlG4 }
function groups.populateAccesses()
	if ULib.ucl.groups[groups.list:GetValue()] then
		local group = groups.list:GetValue()
		for _, line in pairs( groups.access_lines ) do
			line.Columns[2]:SetDisabled( false )
			line.Columns[2]:SetValue( false )
			line.Columns[1]:SetTextColor( Color( 255,255,255,90 ) )
		end
		for _, grouphas in ipairs( ULib.ucl.groups[group].allow ) do
			if groups.access_lines[grouphas] then
				groups.access_lines[grouphas].Columns[2]:SetValue( true )
				groups.access_lines[grouphas].Columns[1]:SetTextColor( Color( 255,255,255,255 ) )
			end
		end
		if ULib.ucl.groups[group].inherit_from then
			groups.popuplateInheritedAccesses( ULib.ucl.groups[group].inherit_from )
		end
	end
end

function groups.popuplateInheritedAccesses( group )
	for _, grouphas in ipairs( ULib.ucl.groups[group].allow ) do
		if groups.access_lines[grouphas] then
			groups.access_lines[grouphas].Columns[2]:SetValue( true )
			groups.access_lines[grouphas].Columns[1]:SetTextColor( Color( 255,255,255,255 ) )
			groups.access_lines[grouphas].Columns[2]:SetDisabled( true )
		end
	end
	if ULib.ucl.groups[group].inherit_from then
		groups.popuplateInheritedAccesses( ULib.ucl.groups[group].inherit_from )
	end
end

---Data refresh/GUI functions
function groups.SortGroups( t )
	for k, v in pairs( t ) do
		groups.SortGroups( v )
		table.insert( xgui.data.groups, k )
	end
end

function groups.getGroupData( group )
	groups.refreshPlayerList( group )
	groups.populateAccesses()
	if group == "user" then
		groups.aplayer:SetDisabled( true )
	else
		groups.aplayer:SetDisabled( false )
	end
	groups.teams:SetText( groups.getGroupsTeam( groups.list:GetValue() ) )
end

function groups.refreshPlayerList( group )
	groups.players:Clear()
	groups.cplayer:SetDisabled( true )
	if group ~= "user" then
		for ID, user in pairs( xgui.data.users ) do
			if user.group == group then
				if user.name == nil or user.name == "" then user.name = ID end
				groups.players:AddLine( user.name, ID )
			end
		end
	else
		for k, v in ipairs( player.GetAll() ) do
			if v:GetUserGroup() == "user" then
				groups.players:AddLine( v:Nick(), v:SteamID() )
			end
		end
	end
end

function groups.updateTeams()
	local last_selected = groups.teamlist:GetSelectedLine() and groups.teamlist:GetSelected()[1]:GetColumnText(1)	
	groups.teams:Clear()
	groups.teams:AddChoice( "<None>" )
	groups.teams:AddChoice( "--*" )
	groups.teamlist:Clear()
	local updateLine = nil
	for k, v in pairs( xgui.data.teams ) do
		groups.teams:AddChoice( v.name )
		local l = groups.teamlist:AddLine( v.name )
		if v.name == last_selected then
			updateLine = l
		end
	end
	if updateLine then
		groups.teamlist:SelectItem( updateLine )
	else
		groups.teammodifiers:Clear()
		groups.teammodspace:Clear()
		groups.upbtn:SetDisabled( true )
		groups.downbtn:SetDisabled( true )
		groups.teamdelete:SetDisabled( true )
	end	
	groups.teams:SetText( groups.getGroupsTeam( groups.list:GetValue() ) )
end

function groups.updateUsers()
	xgui.data.groups = {}
	groups.SortGroups( ULib.ucl.getInheritanceTree() )
	groups.list:populate( groups.isGroupManagement )
	groups.glist:populate()
end

--Misc. functions
function groups.addBySteamID( group )
	local frame = x_makeframepopup{ label="Add ID to group " .. group, w=190, h=60, alwaysontop=true }
	x_maketextbox{ x=5, y=30, w=180, parent=frame, focuscontrol=true, text="Enter STEAMID..." }.OnEnterPressed = function( self )
		if ULib.isValidSteamID( self:GetValue() ) then
			RunConsoleCommand( "ulx", "adduserid", self:GetValue(), group )
		end
	end
end

function groups.changeUserGroup( SteamID, group )
	if group == "user" then
		RunConsoleCommand( "ulx", "removeuserid", SteamID, group )
	else
		RunConsoleCommand( "ulx", "adduserid", SteamID, group )
	end
end

function groups.isOnline( steamID )
	for _, v in ipairs( player.GetAll() ) do
		if v:SteamID() == steamID then
			return true
		end
	end
	return false
end

function groups.getGroupsTeam( check_group )
	--Since ULX doesn't refresh its groups data to clients when team stuff changes, we have to go the long way round to get the info.
	for _, team in ipairs( xgui.data.teams ) do
		for _, group in ipairs( team.groups ) do
			if group == check_group then
				return team.name
			end
		end
	end
	return "<None>"
end
groups.updateTeams()

function groups.updateAccessPanel()
	groups.accesses:Clear()
	groups.access_cats = {}
	groups.access_lines = {}

	local function processAccess( access, data )
		if data.cat == nil then data.cat = "Uncategorized" end
		
		if not groups.access_cats[data.cat] then
			--Make a new category
			local list = x_makelistview{ headerheight=0, multiselect=false, h=136 }
			list:AddColumn( "Tag" )
			local col = list:AddColumn( "Checkbox" )
			col:SetMaxWidth( 15 )
			col:SetMinWidth( 15 )
			list.OnRowSelected = function( self, LineID ) groups.accessSelected( self, LineID ) end
			--Hijack the DataLayout function to manually set the position of the checkboxes.
			local tempfunc = list.DataLayout
			list.DataLayout = function( list )
				local rety = tempfunc( list )
				for _, Line in ipairs( list.Lines ) do
					local x,y = Line:GetColumnText(2):GetPos()
					Line:GetColumnText(2):SetPos( x, y+1 )
				end
				return rety
			end
			groups.access_cats[data.cat] = list
			local cat = x_makecat{ label=data.cat, contents=list, expanded=false }
			groups.accesses:AddItem( cat )
			function cat.Header:OnMousePressed( mcode )
				if ( mcode == MOUSE_LEFT ) then
					self:GetParent():Toggle()
					--Since derma is special, we can't disable buttons unless they've been drawn on the screen once.
					--When a category is opened, it will first check if we've reset values for this cat, and if it hasn't, it will refresh them after a frame.
					if not cat.wasFirstDrawn then
						cat.wasFirstDrawn = true
						ULib.queueFunctionCall( groups.populateAccesses )
					end
				end
				return self:GetParent():OnMousePressed( mcode )
			end
		end
		local checkbox = x_makecheckbox{}
		checkbox.Button.DoClick = function( self )
			groups.accessChanged( access, not self:GetChecked() )
		end
		local line = groups.access_cats[data.cat]:AddLine( access, checkbox )
		line:SetToolTip( data.hStr )
		groups.access_lines[access] = line
	end
	
	for access, data in pairs( xgui.data.accesses ) do	
		ULib.queueFunctionCall( processAccess, access, data )
	end
	--Why so many queueFunctionCalls? Mainly to prevent large lags when performing a bunch of derma AddLine()s at once. queueFunctionCall will spread the load for each line, usually one per frame.
	--This results in the possibility of the end user seeing lines appearing as he's looking at the menus, but I believe that < 1 second of lines appearing is better than 150+ms of freeze time.
	
	local function finalSort()
		table.sort( groups.accesses.Items, function( a,b ) return a.Header:GetValue() < b.Header:GetValue() end )
		for _, cat in pairs( groups.access_cats ) do
			cat:SortByColumn( 1 )
			cat:SetHeight( 17*#cat:GetLines() )
		end
		groups.accesses:InvalidateLayout()
		groups.populateAccesses()
	end
	ULib.queueFunctionCall( finalSort )
end

function groups.accessChanged( access, newVal )
	if newVal == true then
		RunConsoleCommand( "ulx", "groupallow", groups.list:GetValue(), access )
	else
		RunConsoleCommand( "ulx", "groupdeny", groups.list:GetValue(), access )
	end
end

function groups.accessSelected( catlist, LineID )
	for _, cat in pairs( groups.access_cats ) do
		if cat ~= catlist then
			cat:ClearSelection()
		end
	end	
end

groups.modelList = vgui.Create( "DPanelSelect", xgui.null )
groups.modelList:SetHeight( 168 )
function groups.updateModelPanel()
	groups.modelList:Clear()
	local modelsSorted = {}
    for k,_ in pairs( xgui.data.playermodels ) do table.insert( modelsSorted, k ) end
    table.sort( modelsSorted, function( a,b ) return string.lower( a ) < string.lower( b ) end )
	
	for _, name in ipairs( modelsSorted ) do
		ULib.queueFunctionCall( groups.addToModelPanel, name )
	end
end
function groups.setTeamModel( model ) end --Create a dummy function that will be created with proper settings later.
function groups.addToModelPanel( name )
	local icon = vgui.Create( "SpawnIcon", xgui.null )
	icon:SetModel( xgui.data.playermodels[name] )
	icon:SetSize( 64, 64 )
	icon:SetTooltip( name )
	icon.name = name
	icon.model = xgui.data.playermodels[name]
	icon.DoClick = function( self ) groups.modelList:SelectPanel( self ) groups.setTeamModel( icon.name ) end
	groups.modelList:AddItem( icon )
end


hook.Add( "UCLChanged", "xgui_RefreshGroupPermissions", groups.populateAccesses )
table.insert( xgui.hook["teams"], groups.updateTeams )
table.insert( xgui.hook["users"], groups.updateUsers )
table.insert( xgui.hook["accesses"], groups.updateAccessPanel )
table.insert( xgui.hook["playermodels"], groups.updateModelPanel )
table.insert( xgui.modules.tab, { name="Groups", panel=groups, icon="gui/silkicons/group", tooltip=nil, access="xgui_managegroups" } )


--------------
--ANIMATIONS--
--------------
function groups:slideAnim( anim, delta, data )
	--data.panel, data.startx, data.starty, data.endx, data.endy, data.setvisible
	data.panel:SetPos( data.startx+((data.endx-data.startx)*delta), data.starty+((data.endy-data.starty)*delta) )

	if ( anim.Started ) then
		if data.setvisible == true then
			data.panel:SetVisible( true )
		end
		data.panel:SetPos( data.startx, data.starty )
	elseif ( anim.Finished ) then
		data.panel:SetPos( data.endx, data.endy )
		if data.setvisible == false then
			data.panel:SetVisible( false )
		end
		groups.animQueue_call()
	end
end
groups.doAnim = Derma_Anim( "Fade", groups.doAnim, groups.slideAnim )

function groups:Think()
	groups.doAnim:Run()
end

---Individual Panel animations
groups.pnlG1.openAnim = function( self, group )
	table.insert( groups.animQueue, function() groups.getGroupData( group ) groups.animQueue_call() end )
	table.insert( groups.animQueue, function() groups.doAnim:Start( xgui.base:GetFadeTime(), { panel=groups.pnlG1, startx=0, starty=-335, endx=0, endy=0, setvisible=true } ) end )
end
groups.pnlG1.closeAnim = function( self )
	table.insert( groups.animQueue, function() groups.doAnim:Start( xgui.base:GetFadeTime(), { panel=groups.pnlG1, startx=0, starty=0, endx=0, endy=-335, setvisible=false } ) end )
end

groups.pnlG2.openAnim = function( self )
	table.insert( groups.animQueue, function() groups.doAnim:Start( xgui.base:GetFadeTime(), { panel=groups.pnlG2, startx=0, starty=-200, endx=0, endy=0, setvisible=true } ) end )
end
groups.pnlG2.closeAnim = function( self )
	table.insert( groups.animQueue, function() groups.doAnim:Start( xgui.base:GetFadeTime(), { panel=groups.pnlG2, startx=0, starty=0, endx=0, endy=-200, setvisible=false } ) end )
end

groups.pnlG3.openAnim = function( self )
	table.insert( groups.animQueue, function() groups.clippanelb:SetVisible( true ) groups.animQueue_call() end )
	table.insert( groups.animQueue, function() groups.doAnim:Start( xgui.base:GetFadeTime(), { panel=groups.pnlG3, startx=-410, starty=130, endx=5, endy=130, setvisible=true } ) end )
end
groups.pnlG3.closeAnim = function( self )
	table.insert( groups.animQueue, function() groups.doAnim:Start( xgui.base:GetFadeTime(), { panel=groups.pnlG3, startx=5, starty=130, endx=-410, endy=130, setvisible=false } ) end )
	table.insert( groups.animQueue, function() groups.clippanelb:SetVisible( false ) groups.animQueue_call() end )
end

groups.pnlG4.openAnim = function( self )
	table.insert( groups.animQueue, function() groups.clippanelb:SetVisible( true ) groups.animQueue_call() end )
	table.insert( groups.animQueue, function() groups.doAnim:Start( xgui.base:GetFadeTime(), { panel=groups.pnlG4, startx=-210, starty=0, endx=5, endy=0, setvisible=true } ) end )
end
groups.pnlG4.closeAnim = function( self )
	table.insert( groups.animQueue, function() groups.doAnim:Start( xgui.base:GetFadeTime(), { panel=groups.pnlG4, startx=5, starty=0, endx=-210, endy=0, setvisible=false } ) end )
	table.insert( groups.animQueue, function() groups.clippanelb:SetVisible( false ) groups.animQueue_call() end )
end

---Animation queue stuff
groups.animQueue = {}
groups.animQueue_call = function()
	if #groups.animQueue > 0 then
		local func = groups.animQueue[1]
		table.remove( groups.animQueue, 1 )
		--ULib.queueFunctionCall( func )
		timer.Simple( 0, func ) --Delay calling the function for a frame
	end
end