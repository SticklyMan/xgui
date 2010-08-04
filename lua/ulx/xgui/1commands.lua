--Commands module (formerly players module) v2 for ULX GUI -- by Stickly Man!
--Handles all user-based commands, such as kick, slay, ban, etc.

local cmds = x_makeXpanel{ parent=xgui.null }
cmds.selcmd = nil
cmds.mask = x_makepanel{ x=160, y=30, w=425, h=335, parent=cmds }
cmds.argslist = x_makepanellist{ w=170, h=335, parent=cmds.mask }
cmds.argslist:SetVisible( false )
cmds.plist = x_makelistview{ w=250, h=335, multiselect=true, parent=cmds.mask }
cmds.plist:SetVisible( false )
cmds.plist:AddColumn( "Name" )
cmds.plist:AddColumn( "Group" )
cmds.plist.OnRowSelected = function( self, LineID, Line ) --TODO: Double-click defaults?
	if cmds.lockply then return end
	if cmds.doAnim:Active() then
		cmds.doAnim.Finished = true
		cmds.doAnim:Run() --Give it a chance to process the finished code
	end
	
	local x,y = cmds.plist:GetPos()
	if x >= 0 then -- A strange check, but it prevents animation glitches
		if cmds.argslist:IsVisible() == false then
			cmds.argslist:animate( ULib.cmds.translatedCmds[cmds.selcmd], false )
		end
	end
end
cmds.cmds = x_makepanellist{ x=5, y=30, w=150, h=335, parent=cmds, padding=1, spacing=1 }
cmds.setselected = function( selcat, LineID )
	if selcat.Lines[LineID]:GetColumnText(2) == cmds.selcmd then return end
	
	for _, cat in pairs( cmds.cmd_cats ) do
		if cat ~= selcat then
			cat:ClearSelection()
		end
	end
	cmds.selcmd = selcat.Lines[LineID]:GetColumnText(2)
	local cmd = ULib.cmds.translatedCmds[cmds.selcmd]
	if cmd.args[2] then
		expectingPlayers = ( cmd.args[2].type == ULib.cmds.PlayersArg ) or ( cmd.args[2].type == ULib.cmds.PlayerArg )
	else
		expectingPlayers = false
	end	
	if cmds.plist:IsVisible() then
		if cmds.argslist:IsVisible() then
			cmds.lockply = true --Lock player selection (to prevent animation glitches)
			if expectingPlayers then
				--Hide argslist, Hide/Reshow playerlist.
				cmds.doAnim:Start( xgui.base:GetFadeTime()/2, { panel=cmds.argslist, startpos=255, distance=-175, endfunc=function()
					cmds.argslist:SetVisible( false )
					cmds.doAnim:Start( xgui.base:GetFadeTime()/2, { panel=cmds.plist, startpos=0, distance=-250, endfunc=function()
						cmds.refreshPlist( cmd.args[2], 1 )
						cmds.lockply = nil
						cmds.doAnim:Start( xgui.base:GetFadeTime()/2, { panel=cmds.plist, startpos=-250, distance=250 } )  end } )  end } )
			else
				--Hide argslist, Hide Player List, Show Args List
				cmds.doAnim:Start( xgui.base:GetFadeTime()/2, { panel=cmds.argslist, startpos=255, distance=-175, endfunc=function()
					cmds.argslist:SetVisible( false )
					cmds.doAnim:Start( xgui.base:GetFadeTime()/2, { panel=cmds.plist, startpos=0, distance=-250, endfunc=function()
						cmds.plist:SetVisible( false )
						cmds.lockply = nil
						cmds.argslist:animate( cmd, true, nil, 2 )  end } )  end } )
						
			end
		else
			if expectingPlayers then
				--Hide/Reshow playerlist.
				cmds.doAnim:Start( xgui.base:GetFadeTime()/1.5, { panel=cmds.plist, startpos=0, distance=-250, endfunc=function()
					cmds.refreshPlist( cmd.args[2], 1 )
					cmds.lockply = nil
					cmds.doAnim:Start( xgui.base:GetFadeTime()/1.5, { panel=cmds.plist, startpos=-250, distance=250 } )  end } )
			else
				--Hide Player List. Show Args List
				cmds.doAnim:Start( xgui.base:GetFadeTime()/1.5, { panel=cmds.plist, startpos=0, distance=-250, endfunc=function()
					cmds.plist:SetVisible( false )
					cmds.argslist:animate( cmd, true, nil, 1.5 )  end } )
			end
		end
	else
		if cmds.argslist:IsVisible() then
			if expectingPlayers then
				--Hide Args list, Show player list
				cmds.doAnim:Start( xgui.base:GetFadeTime()/1.5, { panel=cmds.argslist, startpos=0, distance=-170, endfunc=function()
					cmds.argslist:SetVisible( false )
					cmds.lockply = nil
					cmds.plist:animate( cmd, nil, 1.5 )  end } )
			else
				--Hide/Reshow argslist.
				cmds.doAnim:Start( xgui.base:GetFadeTime()/1.5, { panel=cmds.argslist, startpos=0, distance=-170, endfunc=function()
					cmds.refreshArgslist( cmd )
					cmds.doAnim:Start( xgui.base:GetFadeTime()/1.5, { panel=cmds.argslist, startpos=-170, distance=170 } )  end } )
			end
		else
			if expectingPlayers then
				--Show Players List
				cmds.lockply = nil
				cmds.plist:animate( cmd )
			else
				--Show Args List
				cmds.argslist:animate( cmd, true )
			end
		end
	end
end

function cmds.refreshPlist( arg, argnum )
	cmds.plist:Clear()
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
		cmds.plist:AddLine( ply:Nick(), ply:GetUserGroup() )
	end
	cmds.plist:SetMultiSelect( arg.type == ULib.cmds.PlayersArg )
end

function cmds.refreshArgslist( cmd )
	cmds.argslist:Clear()
	local argnum = 0
	local curitem
	for _, arg in ipairs( cmd.args ) do
		argnum = argnum + 1
		if not ( argnum == 2 ) then
			if arg.type.invisible ~= true and arg.invisible ~= true then
				curitem = arg
				cmds.argslist:AddItem( arg.type.x_getcontrol( arg, argnum ) )
			end
		end
	end
	if curitem and curitem.repeat_min then --This command repeats!
		local panel = x_makepanel{ h=20 }
		panel.numItems = 0
		for i=2,curitem.repeat_min do --Start at 2 because the first one is already there
			cmds.argslist:AddItem( curitem.type.x_getcontrol( curitem, argnum ) )
			panel.numItems = panel.numItems + 1
		end
		panel.argnum = argnum
		panel.xguiIgnore = true
		panel.arg = curitem
		panel.insertPos = #cmds.argslist.Items + 1
		panel.button = x_makebutton{ label="Add", w=80, parent=panel }
		panel.button.DoClick = function( self )
			local parent = self:GetParent()
			table.insert( cmds.argslist.Items, parent.insertPos, parent.arg.type.x_getcontrol( parent.arg, parent.argnum ) )
			cmds.argslist.Items[parent.insertPos]:SetParent( cmds.argslist.pnlCanvas )
			cmds.argslist:InvalidateLayout()
			panel.numItems = panel.numItems + 1
			parent.insertPos = parent.insertPos + 1
			if parent.arg.repeat_max and panel.numItems >= parent.arg.repeat_max - 1 then self:SetDisabled( true ) end
			if panel.button2:GetDisabled() then panel.button2:SetDisabled( false ) end
		end
		panel.button2 = x_makebutton{ label="Remove", x=80, w=80, disabled=true, parent=panel }
		panel.button2.DoClick = function( self )
			local parent = self:GetParent()
			cmds.argslist.Items[parent.insertPos-1]:Remove()
			table.remove( cmds.argslist.Items, parent.insertPos - 1 )
			cmds.argslist:InvalidateLayout()
			panel.numItems = panel.numItems - 1
			parent.insertPos = parent.insertPos - 1
			if panel.numItems < parent.arg.repeat_min then self:SetDisabled( true ) end
			if panel.button:GetDisabled() then panel.button:SetDisabled( false ) end
		end
		cmds.argslist:AddItem( panel )
	elseif curitem and curitem.type == ULib.cmds.NumArg then
		cmds.argslist.Items[#cmds.argslist.Items].Wang.TextEntry.OnEnter = function( self )
			cmds.buildcmd( cmd.cmd )
		end
	elseif curitem and curitem.type == ULib.cmds.StringArg then
		cmds.argslist.Items[#cmds.argslist.Items].OnEnter = function( self )
			cmds.buildcmd( cmd.cmd )
		end
	end
	local xgui_temp = x_makebutton{ label=cmd.cmd }
	xgui_temp.xguiIgnore = true
	xgui_temp.DoClick = function()
		cmds.buildcmd( cmd.cmd )
	end
	cmds.argslist:AddItem( xgui_temp )
	if cmd.opposite then
		local xgui_temp = x_makebutton{ label=cmd.opposite }
		xgui_temp.DoClick = function()
			cmds.buildcmd( cmd.opposite )
		end
		xgui_temp.xguiIgnore = true
		cmds.argslist:AddItem( xgui_temp )
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
		cmds.argslist:AddItem( xgui_temp )
	end
end

function cmds.buildcmd( cmd )
	local cmd = string.Explode( " ", cmd )
	if cmds.plist:IsVisible() then
		local plys = {}
		for _, arg in ipairs( cmds.plist:GetSelected() ) do
			table.insert( plys, arg:GetColumnText(1) )
			table.insert( plys, "," )
		end
		table.remove( plys ) --Removes the final comma
		table.insert( cmd, table.concat( plys ) )
	end
	
	for _, arg in ipairs( cmds.argslist.Items ) do
		if not arg.xguiIgnore then
			table.insert( cmd, arg:GetValue() )
		end
	end
	RunConsoleCommand( unpack( cmd ) )
end

--------------
--ANIMATIONS--
--------------
function cmds:slideAnim( anim, delta, data )
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
cmds.doAnim = Derma_Anim( "Fade", cmds.doAnim, cmds.slideAnim )

function cmds:Think()
		cmds.doAnim:Run()
end

function cmds.plist:animate( cmd, func, factor )
	if not factor then
		factor = 1
	end
	self:SetPos( -250, 0 )
	self:SetVisible( true )
	cmds.refreshPlist( cmd.args[2], 1 )
	cmds.doAnim:Start( xgui.base:GetFadeTime()/factor, { panel=cmds.plist, startpos=-250, distance=250, endfunc=func } )
end

function cmds.argslist:animate( cmd, pos, func, factor )
	if not factor then
		factor = 1
	end
	self:SetVisible( true )
	cmds.refreshArgslist( cmd )
	if pos then --Left Side
		self:SetPos( -170, 0 )
		cmds.doAnim:Start( xgui.base:GetFadeTime()/factor, { panel=cmds.argslist, startpos=-170, distance=170, endfunc=func } )
	else --Right side
		self:SetPos( 80, 0 )
		cmds.doAnim:Start( xgui.base:GetFadeTime()/factor, { panel=cmds.argslist, startpos=80, distance=175, endfunc=func } )
	end
end

cmds.refresh = function()
	cmds.cmds:Clear()
	cmds.cmd_cats = {}
	cmds.expandedcat = nil
	cmds.selcmd = nil
	cmds.argslist:SetVisible( false )
	cmds.plist:SetVisible( false )
	
	for cmd, data in pairs( ULib.cmds.translatedCmds ) do
		if data.opposite ~= cmd && ULib.ucl.query( LocalPlayer(), cmd ) then
			local catname = data.category
			if catname == nil or catname == "" then catname = "Uncategorized" end
			if not cmds.cmd_cats[catname] then
				--Make a new category
				cmds.cmd_cats[catname] = x_makelistview{ headerheight=0, multiselect=false, h=136 }
				cmds.cmd_cats[catname].OnRowSelected = function( self, LineID ) cmds.setselected( self, LineID ) end
				cmds.cmd_cats[catname]:AddColumn( "" )
				local cat = x_makecat{ label=catname, contents=cmds.cmd_cats[catname], expanded=false }
				function cat.Header:OnMousePressed( mcode )
					if ( mcode == MOUSE_LEFT ) then
						self:GetParent():Toggle()
						if cmds.expandedcat then
							if cmds.expandedcat ~= self:GetParent() then
								cmds.expandedcat:Toggle()
							else
								cmds.expandedcat = nil
								return
							end
						end
						cmds.expandedcat = self:GetParent()
						return 
					end
					return self:GetParent():OnMousePressed( mcode )
				end
				cmds.cmds:AddItem( cat )
			end
			cmds.cmd_cats[catname]:AddLine( string.gsub( cmd, "ulx ", "" ), cmd )
		end
	end
	table.sort( cmds.cmds.Items, function( a,b ) return a.Header:GetValue() < b.Header:GetValue() end )
	for _, cat in pairs( cmds.cmd_cats ) do
		cat:SortByColumn( 1 )
		cat:SetHeight( 17*#cat:GetLines() )
	end
end
cmds.refresh()

hook.Add( "UCLChanged", "xgui_RefreshPlayerCmds", cmds.refresh )
table.insert( xgui.modules.tab, { name="Cmds", panel=cmds, icon="gui/silkicons/user", tooltip=nil, access=nil } )