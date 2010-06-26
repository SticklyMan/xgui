--Players module v2 for ULX GUI -- by Stickly Man!
--Handles all user-based commands, such as kick, slay, ban, etc.

local players = x_makeXpanel{ parent=xgui.null }
players.selcmd = nil
players.mask = x_makepanel{ x=160, y=30, w=425, h=335, parent=players }
players.argslist = x_makepanellist{ w=170, h=335, parent=players.mask }
players.argslist:SetVisible( false )
players.plist = x_makelistview{ w=250, h=335, multiselect=true, parent=players.mask }
players.plist:SetVisible( false )
players.plist:AddColumn( "Name" )
players.plist:AddColumn( "Group" )
players.plist.OnRowSelected = function( self, LineID, Line ) --TODO: Double-click defaults?
	if players.lockply then return end
	if players.doAnim:Active() then
		players.doAnim.Finished = true
		players.doAnim:Run() --Give it a chance to process the finished code
	end
	
	local x,y = players.plist:GetPos()
	if x >= 0 then -- A strange check, but it prevents animation glitches
		if players.argslist:IsVisible() == false then
			players.argslist:animate( ULib.cmds.translatedCmds[players.selcmd], false )
		end
	end
end
players.cmds = x_makepanellist{ x=5, y=30, w=150, h=335, parent=players, padding=1, spacing=1 }
players.setselected = function( selcat, LineID )
	if selcat.Lines[LineID]:GetColumnText(2) == players.selcmd then return end
	
	for _, cat in pairs( players.cmd_cats ) do
		if cat ~= selcat then
			cat:ClearSelection()
		end
	end
	players.selcmd = selcat.Lines[LineID]:GetColumnText(2)
	local cmd = ULib.cmds.translatedCmds[players.selcmd]
	if cmd.args[2] then
		expectingPlayers = ( cmd.args[2].type == ULib.cmds.PlayersArg ) or ( cmd.args[2].type == ULib.cmds.PlayerArg )
	else
		expectingPlayers = false
	end	
	if players.plist:IsVisible() then
		if players.argslist:IsVisible() then
			players.lockply = true --Lock player selection (to prevent animation glitches)
			if expectingPlayers then
				--Hide argslist, Hide/Reshow playerlist.
				players.doAnim:Start( xgui.base:GetFadeTime()/2, { panel=players.argslist, startpos=255, distance=-175, endfunc=function()
					players.argslist:SetVisible( false )
					players.doAnim:Start( xgui.base:GetFadeTime()/2, { panel=players.plist, startpos=0, distance=-250, endfunc=function()
						players.refreshPlist( cmd.args[2], 1 )
						players.lockply = nil
						players.doAnim:Start( xgui.base:GetFadeTime()/2, { panel=players.plist, startpos=-250, distance=250 } )  end } )  end } )
			else
				--Hide argslist, Hide Player List, Show Args List
				players.doAnim:Start( xgui.base:GetFadeTime()/2, { panel=players.argslist, startpos=255, distance=-175, endfunc=function()
					players.argslist:SetVisible( false )
					players.doAnim:Start( xgui.base:GetFadeTime()/2, { panel=players.plist, startpos=0, distance=-250, endfunc=function()
						players.plist:SetVisible( false )
						players.lockply = nil
						players.argslist:animate( cmd, true, nil, 2 )  end } )  end } )
						
			end
		else
			if expectingPlayers then
				--Hide/Reshow playerlist.
				players.doAnim:Start( xgui.base:GetFadeTime()/1.5, { panel=players.plist, startpos=0, distance=-250, endfunc=function()
					players.refreshPlist( cmd.args[2], 1 )
					players.lockply = nil
					players.doAnim:Start( xgui.base:GetFadeTime()/1.5, { panel=players.plist, startpos=-250, distance=250 } )  end } )
			else
				--Hide Player List. Show Args List
				players.doAnim:Start( xgui.base:GetFadeTime()/1.5, { panel=players.plist, startpos=0, distance=-250, endfunc=function()
					players.plist:SetVisible( false )
					players.argslist:animate( cmd, true, nil, 1.5 )  end } )
			end
		end
	else
		if players.argslist:IsVisible() then
			if expectingPlayers then
				--Hide Args list, Show player list
				players.doAnim:Start( xgui.base:GetFadeTime()/1.5, { panel=players.argslist, startpos=0, distance=-170, endfunc=function()
					players.argslist:SetVisible( false )
					players.lockply = nil
					players.plist:animate( cmd, nil, 1.5 )  end } )
			else
				--Hide/Reshow argslist.
				players.doAnim:Start( xgui.base:GetFadeTime()/1.5, { panel=players.argslist, startpos=0, distance=-170, endfunc=function()
					players.refreshArgslist( cmd )
					players.doAnim:Start( xgui.base:GetFadeTime()/1.5, { panel=players.argslist, startpos=-170, distance=170 } )  end } )
			end
		else
			if expectingPlayers then
				--Show Players List
				players.lockply = nil
				players.plist:animate( cmd )
			else
				--Show Args List
				players.argslist:animate( cmd, true )
			end
		end
	end
end

function players.refreshPlist( arg, argnum )
	players.plist:Clear()
	local access, tag = LocalPlayer():query( arg.cmd )
	local restrictions = {}
	ULib.cmds.PlayerArg.processRestrictions( restrictions, LocalPlayer(), arg, getTagArgNum( tag, argnum ) )

	local targets = restrictions.restrictedTargets
	if targets == false then -- No one allowed
		targets = {}
	elseif targets == nil then -- Everyone allowed
		targets = player.GetAll()
	end

	for _, ply in ipairs( targets ) do
		players.plist:AddLine( ply:Nick(), ply:GetUserGroup() )
	end
	players.plist:SetMultiSelect( arg.type == ULib.cmds.PlayersArg )
end

function players.refreshArgslist( cmd )
	players.argslist:Clear()
	local argnum = 0
	local curitem
	for _, arg in ipairs( cmd.args ) do
		argnum = argnum + 1
		if not ( argnum == 2 and arg.type == ULib.cmds.PlayersArg or arg.type == ULib.cmds.PlayerArg ) then
			if arg.type.invisible ~= true and arg.invisible ~= true then
				curitem = arg
				players.argslist:AddItem( arg.type.x_getcontrol( arg, argnum ) )
			end
		end
	end
	if curitem and curitem.repeat_min then --This command repeats!
		for i=2,curitem.repeat_min do --Start at 2 because the first one is already there
			players.argslist:AddItem( curitem.type.x_getcontrol( curitem, argnum ) )
		end
		local button = x_makebutton{ label="Add another choice...", parent=players.argslist.pnlCanvas }
		button.argnum = argnum
		button.xguiIgnore = true
		button.arg = curitem
		button.DoClick = function( self )
			table.insert( players.argslist.Items, self.insertPos, self.arg.type.x_getcontrol( self.arg, self.argnum ) )
			players.argslist.Items[self.insertPos]:SetParent( players.argslist.pnlCanvas )
			players.argslist:InvalidateLayout()
			self.insertPos = self.insertPos + 1
		end
		button.insertPos = #players.argslist.Items + 1
		players.argslist:AddItem( button )
	elseif curitem and curitem.type == ULib.cmds.NumArg then
		players.argslist.Items[#players.argslist.Items].Wang.TextEntry.OnEnter = function( self )
			players.buildcmd( cmd.cmd )
		end
	elseif curitem and curitem.type == ULib.cmds.StringArg then
		players.argslist.Items[#players.argslist.Items].OnEnter = function( self )
			players.buildcmd( cmd.cmd )
		end
	end
	local xgui_temp = x_makebutton{ label=cmd.cmd }
	xgui_temp.xguiIgnore = true
	xgui_temp.DoClick = function()
		players.buildcmd( cmd.cmd )
	end
	players.argslist:AddItem( xgui_temp )
	if cmd.opposite then
		local xgui_temp = x_makebutton{ label=cmd.opposite }
		xgui_temp.DoClick = function()
			players.buildcmd( cmd.opposite )
		end
		xgui_temp.xguiIgnore = true
		players.argslist:AddItem( xgui_temp )
	end
	if cmd.helpStr then --If the command has a string for help
		local labelstr = {}
		local i = 0
		local marker = 0
		while marker+26 < string.len(cmd.helpStr) do
			i=marker+26
			while string.sub(cmd.helpStr, i, i ) ~= " " do
				i=i-1
			end
			table.insert( labelstr, string.sub( cmd.helpStr, marker, i ) )
			table.insert( labelstr, "\n" )
			marker = i+1
		end
		table.insert( labelstr, string.sub( cmd.helpStr, marker ) )
		local xgui_temp = x_makelabel{ label=table.concat( labelstr ), font="DefaultFixed" }
		xgui_temp.xguiIgnore = true
		players.argslist:AddItem( xgui_temp )
	end
end

function players.buildcmd( cmd )
	local cmd = string.Explode( " ", cmd )
	if players.plist:IsVisible() then
		local plys = {}
		for _, arg in ipairs( players.plist:GetSelected() ) do
			table.insert( plys, arg:GetColumnText(1) )
			table.insert( plys, "," )
		end
		table.remove( plys ) --Removes the final comma
		table.insert( cmd, table.concat( plys ) )
	end
	
	for _, arg in ipairs( players.argslist.Items ) do
		if not arg.xguiIgnore then
			table.insert( cmd, arg:GetValue() )
		end
	end
	PrintTable( cmd )
	RunConsoleCommand( unpack( cmd ) )
end

--------------
--ANIMATIONS--
--------------
function players:slideAnim( anim, delta, data )
	--data.panel, data.startpos, data.distance, data.endfunc
	data.panel:SetPos( data.startpos + ( data.distance*delta ), 0 )
	
	if ( anim.Started ) then
		data.panel:SetPos( data.startpos, 0 )
	elseif ( anim.Finished ) then
		data.panel:SetPos( data.startpos+data.distance, 0 )
		if data.endfunc then
			data.endfunc()
		end
	end
end
players.doAnim = Derma_Anim( "Fade", players.doAnim, players.slideAnim )

function players:Think()
		players.doAnim:Run()
end

function players.plist:animate( cmd, func, factor )
	if not factor then
		factor = 1
	end
	self:SetPos( -250, 0 )
	self:SetVisible( true )
	players.refreshPlist( cmd.args[2], 1 )
	players.doAnim:Start( xgui.base:GetFadeTime()/factor, { panel=players.plist, startpos=-250, distance=250, endfunc=func } )
end

function players.argslist:animate( cmd, pos, func, factor )
	if not factor then
		factor = 1
	end
	self:SetVisible( true )
	players.refreshArgslist( cmd )
	if pos then --Left Side
		self:SetPos( -170, 0 )
		players.doAnim:Start( xgui.base:GetFadeTime()/factor, { panel=players.argslist, startpos=-170, distance=170, endfunc=func } )
	else --Right side
		self:SetPos( 80, 0 )
		players.doAnim:Start( xgui.base:GetFadeTime()/factor, { panel=players.argslist, startpos=80, distance=175, endfunc=func } )
	end
end

players.refresh = function()
	players.cmds:Clear()
	players.cmd_cats = {}
	players.expandedcat = nil
	players.selcmd = nil
	players.argslist:SetVisible( false )
	players.plist:SetVisible( false )
	
	for cmd, data in pairs( ULib.cmds.translatedCmds ) do
		if data.opposite ~= cmd && ULib.ucl.query( LocalPlayer(), cmd ) then
			local catname = data.category
			if catname == nil or catname == "" then catname = "Uncategorized" end
			if not players.cmd_cats[catname] then
				--Make a new category
				players.cmd_cats[catname] = x_makelistview{ headerheight=0, multiselect=false, h=136 }
				players.cmd_cats[catname].OnRowSelected = function( self, LineID ) players.setselected( self, LineID ) end
				players.cmd_cats[catname]:AddColumn( "" )
				local cat = x_makecat{ label=catname, contents=players.cmd_cats[catname], expanded=false }
				function cat.Header:OnMousePressed( mcode )
					if ( mcode == MOUSE_LEFT ) then
						self:GetParent():Toggle()
						if players.expandedcat then
							if players.expandedcat ~= self:GetParent() then
								players.expandedcat:Toggle()
							else
								players.expandedcat = nil
								return
							end
						end
						players.expandedcat = self:GetParent()
						return 
					end
					return self:GetParent():OnMousePressed( mcode )
				end
				players.cmds:AddItem( cat )
			end
			players.cmd_cats[catname]:AddLine( string.gsub( cmd, "ulx ", "" ), cmd )
		end
	end
	table.sort( players.cmds.Items, function( a,b ) return a.Header:GetValue() < b.Header:GetValue() end )
	for _, cat in pairs( players.cmd_cats ) do
		cat:SortByColumn( 1 )
		cat:SetHeight( 17*#cat:GetLines() )
	end
end

table.insert( xgui.hook["onOpen"], players.refresh ) --TODO: This shouldn't have to be called each time the players tab is opened
hook.Add( "UCLChanged", "xgui_RefreshPlayerCmds", players.refresh )
table.insert( xgui.modules.tab, { name="Players", panel=players, icon="gui/silkicons/user", tooltip=nil, access=nil } )