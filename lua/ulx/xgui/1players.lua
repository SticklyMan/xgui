--Players module for ULX GUI -- by Stickly Man!
--Handles all user-based commands, such as kick, slay, ban, etc.

local xgui_player = x_makeXpanel{ parent=xgui.null }

xgui_player.pmessage = x_maketextbox{ x=5, y=345, w=335, parent=xgui_player, text="Send a private message to selected players...", focuscontrol=true }
xgui_player.pmessage.OnEnter = function()
	if xgui_player.list:GetSelectedLine() then
		for _, v in pairs( xgui_player.list:GetSelected() ) do
			if LocalPlayer():Nick() ~= v:GetColumnText(1) then
				RunConsoleCommand( "ulx", "psay", v:GetColumnText(1), unpack( string.Explode( " ", xgui_player.pmessage:GetValue() ) ) )
			end
		end
		xgui_player.pmessage:SetText( "Send a private message to selected players..." )
	end
end

xgui_player.list = x_makelistview{ x=5, y=30, w=335, h=315, multiselect=true, parent=xgui_player }
xgui_player.list:AddColumn( "Name" )
xgui_player.list:AddColumn( "Group" )

xgui_player.commands = x_makepanellist{ x=345, y=30, w=90, h=335, parent=xgui_player, padding=1, spacing=1 }
xgui_player.argspot = x_makepanellist{ x=440, y=30, w=145, h=335, parent=xgui_player }

xgui_player.cmd_cats = {}

function xgui_player.setselected( selcat )
	for _, cat in pairs( xgui_player.cmd_cats ) do
		if cat ~= selcat then
			cat:ClearSelection()
		end
	end
	function xgui_player.list:OnRowSelected() end
	xgui_player.argspot:Remove()
	xgui_player.plylabel = x_makelabel{ parent=xgui_player }
	
	local xgui_temp = false
	xgui_player.argspot = x_makepanellist{ x=440, y=30, w=145, h=335, parent=xgui_player }
	local cmd = ULib.cmds.translatedCmds[selcat:GetSelected()[1]:GetColumnText(2)]
	local argnum = 1
	for _, arg in ipairs( cmd.args ) do
		if arg.type.invisible ~= true and arg.invisible ~= true then
			if arg.type == ULib.cmds.PlayerArg and xgui_temp == false then
				xgui_temp = true
				xgui_player.argspot:AddItem( xgui_player.plylabel )
				function xgui_player.list:OnRowSelected()
					if xgui_player.list:GetSelected()[1] ~= nil then
						xgui_player.plylabel:SetText( xgui_player.list:GetSelected()[1]:GetColumnText(1) )
					else 
						xgui_player.plylabel:SetText( "No player selected!" )
					end
				end
				xgui_player.list:OnRowSelected()
			elseif arg.type == ULib.cmds.PlayersArg and xgui_temp == false then
				xgui_temp = true
				xgui_player.argspot:AddItem( xgui_player.plylabel )
				function xgui_player.list:OnRowSelected()
					xgui_player.plylabel:SetText( "" )
					for _, arg in ipairs( xgui_player.list:GetSelected() ) do
						xgui_player.plylabel:SetText( xgui_player.plylabel:GetValue() .. arg:GetColumnText(1) .. "," )
					end
					xgui_player.plylabel:SetText( string.sub( xgui_player.plylabel:GetValue(), 0, string.len( xgui_player.plylabel:GetValue() ) - 1 ) )
					if xgui_player.plylabel:GetValue() == "" then xgui_player.plylabel:SetText( "No player(s) selected!" ) end
				end
				xgui_player.list:OnRowSelected()
			else
				xgui_player.argspot:AddItem( arg.type.x_getcontrol( arg, argnum ) )
			end
			argnum = argnum + 1
		end
	end
	local xgui_temp = x_makebutton{ label=cmd.cmd }
	xgui_temp.DoClick = function()
		local buildcmd = cmd.cmd
		for i=1,#xgui_player.argspot.Items - 2 do
			buildcmd = buildcmd .. " \"" .. xgui_player.argspot.Items[i]:GetValue() .. "\""
		end
		LocalPlayer():ConCommand( buildcmd )
	end
	xgui_player.argspot:AddItem( xgui_temp )
	if cmd.opposite ~= nil then
		local xgui_temp = x_makebutton{ label=cmd.opposite }
		xgui_temp.DoClick = function()
			local buildcmd = cmd.opposite
			for i=1,#xgui_player.argspot.Items - 2 do
				buildcmd = buildcmd .. " \"" .. xgui_player.argspot.Items[i]:GetValue() .. "\""
			end
			LocalPlayer():ConCommand( buildcmd )
		end
		xgui_player.argspot:AddItem( xgui_temp )
	end
	xgui_player.argspot:AddItem( x_makelabel{ label=cmd.helpStr } )
end

--Helper function to parse access tag for a particular argument
function getTagArgNum( tag, argnum )
    return tag and string.Explode( " ", tag )[argnum]
end

--Load control interpretations for Ulib argument types
function ULib.cmds.BaseArg.x_getcontrol( arg, argnum )
	return x_makelabel{ label="Not Supported" }
end
function ULib.cmds.NumArg.x_getcontrol( arg, argnum )
	local access, tag = LocalPlayer():query( arg.cmd )
	local restrictions = {}
	ULib.cmds.NumArg.processRestrictions( restrictions, arg, getTagArgNum( tag, argnum ) )
	return x_makeslider{ min=restrictions.min, max=restrictions.max, value=arg.default, label=arg.hint or "NumArg" }
end
function ULib.cmds.StringArg.x_getcontrol( arg, argnum )
	local access, tag = LocalPlayer():query( arg.cmd )
	local restrictions = {}
	ULib.cmds.StringArg.processRestrictions( restrictions, arg, getTagArgNum( tag, argnum ) )
	
	local is_restricted_to_completes = table.HasValue( arg, ULib.cmds.restrictToCompletes ) -- Program-level restriction (IE, ulx map)
	    or restrictions.playerLevelRestriction -- The player's tag specifies only certain strings
	
	if is_restricted_to_completes then
		xgui_temp = x_makemultichoice{ text=arg.hint or "StringArg" }
		for _, v in ipairs( restrictions.restrictedCompletes ) do
			xgui_temp:AddChoice( v )
		end
		return xgui_temp
	elseif restrictions.restrictedCompletes then
		-- This is where there needs to be both a drop down AND an input box
		return x_makelabel{ label="Stickly needs to do this part! (" ..
			table.concat( restrictions.restrictedCompletes, "," ) .. ")", textcolor=Color( 255, 0, 0, 255 ) }
	else
		return x_maketextbox{ text=arg.hint or "StringArg", focuscontrol=true }
	end
end
function ULib.cmds.PlayerArg.x_getcontrol( arg )
	xgui_temp = x_makemultichoice{}
	for k, v in pairs( player.GetAll() ) do
		xgui_temp:AddChoice( v:Nick() )
	end
	return xgui_temp
end
function ULib.cmds.CallingPlayerArg.x_getcontrol( arg )
	return x_makelabel{ label=arg.hint or "CallingPlayer" }
end
function ULib.cmds.BoolArg.x_getcontrol( arg )
	return x_makecheckbox{ label=arg.hint or "BoolArg" }
end

xgui_player.plist_refresh = function()
	xgui_player.commands:Clear()
	xgui_player.cmd_cats = {}
	
	for cmd, data in pairs( ULib.cmds.translatedCmds ) do
		if data.opposite ~= cmd && ULib.ucl.query( LocalPlayer(), cmd ) then
			local catname = data.category
			if catname == nil or catname == "" then catname = "Uncategorized" end
			if !xgui_player.cmd_cats[catname] then
				--Make a new category
				xgui_player.cmd_cats[catname] = x_makelistview{ headerheight=0, multiselect=false, h=136 }
				xgui_player.cmd_cats[catname].OnRowSelected = function( self ) xgui_player.setselected( self ) end
				xgui_player.cmd_cats[catname]:AddColumn( "" )
				xgui_player.commands:AddItem( x_makecat{ label=catname, contents=xgui_player.cmd_cats[catname] } )
			end
			xgui_player.cmd_cats[catname]:AddLine( string.gsub( cmd, "ulx ", "" ), cmd )
		end
	end
	for _, cat in pairs( xgui_player.cmd_cats ) do
		cat:SetHeight( 17*#cat:GetLines() )
	end
	
	local selected = xgui_player.list:GetSelected()
	xgui_player.list:Clear()
	for k, v in pairs( player.GetAll() ) do	
		xgui_player.list:AddLine( v:Nick(), v:GetUserGroup() )
	end
	for _, line in pairs( selected ) do
		xgui_player.list:SelectItem( xgui_player.list:GetLineByColumnText( line:GetColumnText(1), 1, false ) )
	end
end

table.insert( xgui.modules.tab, { name="Players", panel=xgui_player, icon="gui/silkicons/user", tooltip=nil, access=nil } )
table.insert( xgui.hook["onOpen"], xgui_player.plist_refresh )