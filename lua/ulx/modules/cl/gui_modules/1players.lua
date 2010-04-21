--Players module for ULX GUI -- by Stickly Man!
--Handles all user-based commands, such as kick, slay, ban, etc.

xgui_player = x_makeXpanel{ parent=xgui_null }

xgui_pmessage = x_maketextbox{ x=5, y=345, w=335, parent=xgui_player, text="Send a private message to selected players...", focuscontrol=true }
xgui_pmessage.OnEnter = function()
	if xgui_player_list:GetSelectedLine() then
		for _, v in pairs( xgui_player_list:GetSelected() ) do
			if LocalPlayer():Nick() ~= v:GetColumnText(1) then
				RunConsoleCommand( "ulx", "psay", v:GetColumnText(1), unpack( string.Explode( " ", xgui_pmessage:GetValue() ) ) )
			end
		end
		xgui_pmessage:SetText( "Send a private message to selected players..." )
	end
end

xgui_player_list = x_makelistview{ x=5, y=30, w=335, h=315, multiselect=true, parent=xgui_player }
xgui_player_list:AddColumn( "Name" )
xgui_player_list:AddColumn( "Group" )

xgui_commands = x_makepanellist{ x=345, y=30, w=90, h=335, parent=xgui_player, padding=1, spacing=1 }
xgui_argspot = x_makepanellist{ x=440, y=30, w=145, h=335, parent=xgui_player }

local xgui_command_cats = {}

--Load control interpretations for Ulib argument types
function ULib.cmds.BaseArg.x_getcontrol( arg )
	return x_makelabel{ label="Not Supported", color=Color( 255,255,255,255 ) }
end

function ULib.cmds.NumArg.x_getcontrol( arg )
	return x_makeslider{ min=arg.min, max=arg.max, value=arg.default, label=arg.hint or "NumArg" }
end

function ULib.cmds.StringArg.x_getcontrol( arg )
	if arg.completes == nil then
		return x_maketextbox{ text=arg.hint or "StringArg", focuscontrol=true }
	else
		xgui_temp = x_makemultichoice{ text=arg.hint or "StringArg" }
		for _, v in ipairs( arg.completes ) do
			xgui_temp:AddChoice( v )
		end
		return xgui_temp
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

function xgui_setselected( selcat )
	for _, cat in pairs( xgui_command_cats ) do
		if cat ~= selcat then
			cat:ClearSelection()
		end
	end
	function xgui_player_list:OnRowSelected() end
	xgui_argspot:Remove()
	xgui_label = x_makelabel{ parent=xgui_player }
	
	local xgui_temp = false
	xgui_argspot = x_makepanellist{ x=440, y=30, w=145, h=335, parent=xgui_player }
	local cmd = ULib.cmds.translatedCmds[selcat:GetSelected()[1]:GetColumnText(2)]
	for _, arg in ipairs( cmd.args ) do
		if arg.type.invisible ~= true and arg.invisible ~= true then
			if arg.type == ULib.cmds.PlayerArg and xgui_temp == false then
				xgui_temp = true
				xgui_argspot:AddItem( xgui_label )
				function xgui_player_list:OnRowSelected()
					if xgui_player_list:GetSelected()[1] ~= nil then
						xgui_label:SetText( xgui_player_list:GetSelected()[1]:GetColumnText(1) )
					else 
						xgui_label:SetText( "No player selected!" )
					end
				end
				xgui_player_list:OnRowSelected()
			elseif arg.type == ULib.cmds.PlayersArg and xgui_temp == false then
				xgui_temp = true
				xgui_argspot:AddItem( xgui_label )
				function xgui_player_list:OnRowSelected()
					xgui_label:SetText( "" )
					for _, arg in ipairs( xgui_player_list:GetSelected() ) do
						xgui_label:SetText( xgui_label:GetValue() .. arg:GetColumnText(1) .. "," )
					end
					xgui_label:SetText( string.sub( xgui_label:GetValue(), 0, string.len( xgui_label:GetValue() ) - 1 ) )
					if xgui_label:GetValue() == "" then xgui_label:SetText( "No player(s) selected!" ) end
				end
				xgui_player_list:OnRowSelected()
			else
				xgui_argspot:AddItem( arg.type.x_getcontrol( arg ) )
			end
		end
	end
	xgui_temp = x_makebutton{ label=cmd.cmd }
	xgui_temp.DoClick = function()
		local buildcmd = cmd.cmd
		for i=1,#xgui_argspot.Items - 2 do
			buildcmd = buildcmd .. " \"" .. xgui_argspot.Items[i]:GetValue() .. "\""
		end
		LocalPlayer():ConCommand( buildcmd )
	end
	xgui_argspot:AddItem( xgui_temp )
	if cmd.opposite ~= nil then
		xgui_temp = x_makebutton{ label=cmd.opposite }
		xgui_temp.DoClick = function()
			local buildcmd = cmd.opposite
			for i=1,#xgui_argspot.Items - 2 do
				buildcmd = buildcmd .. " \"" .. xgui_argspot.Items[i]:GetValue() .. "\""
			end
			LocalPlayer():ConCommand( buildcmd )
		end
		xgui_argspot:AddItem( xgui_temp )
	end
	xgui_argspot:AddItem( x_makelabel{ label=cmd.helpStr } )
end

xgui_player.xRefresh = function()
	xgui_commands:Clear()
	xgui_command_cats = {}
	
	for cmd, data in pairs( ULib.cmds.translatedCmds ) do
		if data.opposite ~= cmd && ULib.ucl.query( LocalPlayer(), cmd ) then
			local catname = data.category
			if catname == nil or catname == "" then catname = "Uncategorized" end
			if !xgui_command_cats[catname] then
				--Make a new category
				xgui_command_cats[catname] = x_makelistview{ headerheight=0, multiselect=false, h=136 }
				xgui_command_cats[catname].OnRowSelected = function( self ) xgui_setselected( self ) end
				xgui_command_cats[catname]:AddColumn( "" )
				xgui_commands:AddItem( x_makecat{ label=catname, contents=xgui_command_cats[catname] } )
			end
			xgui_command_cats[catname]:AddLine( string.gsub( cmd, "ulx ", "" ), cmd )
		end
	end
	for _, cat in pairs( xgui_command_cats ) do
		cat:SetHeight( 17*#cat:GetLines() )
	end
	
	local selected = xgui_player_list:GetSelected()
	xgui_player_list:Clear()
	for k, v in pairs( player.GetAll() ) do	
		xgui_player_list:AddLine( v:Nick(), v:GetUserGroup() )
	end
	for _, line in pairs( selected ) do
		xgui_player_list:SelectItem( xgui_player_list:GetLineByColumnText( line:GetColumnText(1), 1, false ) )
	end
end

table.insert( xgui_modules.tab, { name="Players", panel=xgui_player, icon="gui/silkicons/user", tooltip=nil, access=nil } )
table.insert( xgui_modules.hook["onOpen"], xgui_player.xRefresh )