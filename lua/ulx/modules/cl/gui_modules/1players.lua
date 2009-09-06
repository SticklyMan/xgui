--Players module for ULX GUI -- by Stickly Man!
--Handles all user-based commands, such as kick, slay, ban, etc.

xgui_player = x_makeXpanel( )

xgui_rcon = x_maketextbox{ x=5, y=345, w=335, parent=xgui_player, text="Enter an RCON command...", focuscontrol=true }
xgui_rcon.OnEnter = function()
	RunConsoleCommand( "ulx", "rcon", unpack( string.Explode( " ", xgui_rcon:GetValue() ) ) )
	xgui_rcon:SetText( "Enter an RCON command..." )
end

xgui_player_list = x_makelistview{ x=5, y=30, w=335, h=315, multiselect=false, parent=xgui_player }
xgui_player_list:AddColumn( "Name" )
xgui_player_list:AddColumn( "Group" )

xgui_commands = x_makepanellist{ x=345, y=30, w=90, h=335, parent=xgui_player, padding=1, spacing=1 }
xgui_argspot = x_makepanellist{ x=440, y=30, w=145, h=335, parent=xgui_player }

local xgui_command_cats = {}

xgui_player.XGUI_Refresh = function()
	xgui_player_list:Clear()
	for k, v in pairs( player.GetAll() ) do	
		xgui_player_list:AddLine( v:Nick(), v:GetUserGroup() )
	end
	
	for _, cat in pairs( xgui_command_cats ) do
		cat:Clear()
	end
	for cmd, data in pairs( translatedCmds ) do
		local catname = data.catagory
		if catname == nil or catname == "" then catname = "Uncategorized" end
		if !xgui_command_cats[catname] then
			--Make a new category
			xgui_command_cats[catname] = x_makelistview{ headerheight=0, multiselect=false, h=136 }
			xgui_command_cats[catname].OnRowSelected = function( self ) xgui_setselected( self ) end
			xgui_command_cats[catname]:AddColumn( "" )
			xgui_commands:AddItem( x_makecat{ label=catname, contents=xgui_command_cats[catname] } )
		end
		xgui_command_cats[catname]:AddLine( cmd )
	end
	for _, cat in pairs( xgui_command_cats ) do
		cat:SetHeight( 17*#cat:GetLines() )
	end
end

function xgui_setselected( selcat )
	for _, cat in pairs( xgui_command_cats ) do
		if cat ~= selcat then
			cat:ClearSelection()
		end
	end
	xgui_argspot:Remove()
	xgui_argspot = x_makepanellist{ x=440, y=30, w=145, h=335, parent=xgui_player }
	for _, v in ipairs(	translatedCmds[selcat:GetSelected()[1]:GetColumnText(1)].args ) do
		xgui_argspot:AddItem( v.type.x_getcontrol() )
	end
end

xgui_base:AddSheet( "Players", xgui_player, "gui/silkicons/user", false, false )