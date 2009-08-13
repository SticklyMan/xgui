--Players module for ULX GUI -- by Stickly Man!
--Handles all user-based commands, such as kick, slay, ban, etc.

function xgui_tab_player()
	xgui_player = vgui.Create( "DPanel" )
-----------
	xgpl_player_list = x_makelistview{ x=10, y=30, w=250, h=320, multiselect=false, parent=xgui_player }
	xgpl_player_list:AddColumn( "Name" )
	xgpl_player_list:AddColumn( "Groups" )
-----------

	local xgpl_pm = x_makebutton{ label="Send player a private message..." }
	xgpl_pm.DoClick = function()
		
		if xgpl_player_list:GetSelectedLine() then
		
			local xgpl_temp_player = xgpl_player_list:GetSelected()[1]:GetColumnText( 1 )
			local xgui_pm = x_makeframepopup{ label="Send a message to " .. xgpl_temp_player, w=400, h=60 }
			local xgui_pm_text = x_maketextbox{ x=10, y=30, w=380, h=20, parent=xgui_pm }
			xgui_pm_text.OnEnter = function()
					
				RunConsoleCommand( "ulx", "psay", xgpl_temp_player, unpack( string.Explode( " ", xgui_pm_text:GetValue() ) ) )
				xgui_pm:Remove()
			end
		end
	end
-----------
	local xgpl_vote = x_makebutton{ label="Start a public vote..." }
	xgpl_vote.DoClick = function()
	
	end
-----------
	xgpl_commands = x_makepanelist{ x=265, y=30, w=90, h=320, parent=xgui_player, padding=1, spacing=1 }

	xgpl_commands_group1 = x_makelistview{ headerheight=0, multiselect=false, h=136 } --17*#oflines
	xgpl_commands_group1.OnRowSelected = function() xgpl_setcontrols( xgpl_commands_group1:GetSelected()[1]:GetColumnText(1), 1 ) end
		xgpl_commands_group1:AddColumn( "" )
		xgpl_commands_group1:AddLine( "Ban" )
		xgpl_commands_group1:AddLine( "Cexec" )
		xgpl_commands_group1:AddLine( "Commands" )
		xgpl_commands_group1:AddLine( "Kick" )
		xgpl_commands_group1:AddLine( "Spectate" )
		xgpl_commands_group1:AddLine( "Tools" )
		xgpl_commands_group1:AddLine( "Voteban" )
		xgpl_commands_group1:AddLine( "Votekick" )
	xgpl_commands:AddItem( x_makecat{ label="Utilities", contents=xgpl_commands_group1 } )
	
	xgpl_commands_group2 = x_makelistview{ headerheight=0, multiselect=false, h=272 }
	xgpl_commands_group2.OnRowSelected = function() xgpl_setcontrols( xgpl_commands_group2:GetSelected()[1]:GetColumnText(1), 2 ) end
		xgpl_commands_group2:AddColumn( "" )
		xgpl_commands_group2:AddLine( "Armor" )
		xgpl_commands_group2:AddLine( "Blind" )
		xgpl_commands_group2:AddLine( "Cloak" )
		xgpl_commands_group2:AddLine( "Freeze" )
		xgpl_commands_group2:AddLine( "Ghost" )
		xgpl_commands_group2:AddLine( "God" )
		xgpl_commands_group2:AddLine( "HP" )
		xgpl_commands_group2:AddLine( "Ignite" )
		xgpl_commands_group2:AddLine( "Jail" )
		xgpl_commands_group2:AddLine( "Maul" )
		xgpl_commands_group2:AddLine( "Ragdoll" )
		xgpl_commands_group2:AddLine( "Slap" )
		xgpl_commands_group2:AddLine( "Slay" )
		xgpl_commands_group2:AddLine( "SSlay" )
		xgpl_commands_group2:AddLine( "Strip" )
		xgpl_commands_group2:AddLine( "Whip" )
	xgpl_commands:AddItem( x_makecat{ label="Fun", contents=xgpl_commands_group2 } )
	
	xgpl_commands_group3 = x_makelistview{ headerheight=0, multiselect=false, h=85 }
	xgpl_commands_group3.OnRowSelected = function() xgpl_setcontrols( xgpl_commands_group3:GetSelected()[1]:GetColumnText(1), 3 ) end
		xgpl_commands_group3:AddColumn( "" )
		xgpl_commands_group3:AddLine( "Gag" )
		xgpl_commands_group3:AddLine( "Gimp" )
		xgpl_commands_group3:AddLine( "Mute" )
		xgpl_commands_group3:AddLine( "PM" )
		xgpl_commands_group3:AddLine( "Vote" )
	xgpl_commands:AddItem( x_makecat{ label="Chat", contents=xgpl_commands_group3 } )

	xgpl_commands_group4 = x_makelistview{ headerheight=0, multiselect=false, h=85 }
	xgpl_commands_group4.OnRowSelected = function() xgpl_setcontrols( xgpl_commands_group4:GetSelected()[1]:GetColumnText(1), 4 ) end
		xgpl_commands_group4:AddColumn( "" )
		xgpl_commands_group4:AddLine( "Bring" )
		xgpl_commands_group4:AddLine( "Goto" )
		xgpl_commands_group4:AddLine( "Noclip" )
		xgpl_commands_group4:AddLine( "Send" )
		xgpl_commands_group4:AddLine( "Teleport" )
	xgpl_commands:AddItem( x_makecat{ label="Movement", contents=xgpl_commands_group4 } )
------------
	xgpl_player_list:Clear()
	for k, v in pairs( player.GetAll() ) do	
		xgpl_player_list:AddLine( v:Nick(), table.concat( v:GetGroups() ) )
	end
	xgui_base:AddSheet( "Players", xgui_player, "gui/silkicons/group", false, false )
end

xgui_modules[1]=xgui_tab_player

function xgpl_setcontrols( command, group )
	if group ~= 1 then xgpl_commands_group1:ClearSelection() end
	if group ~= 2 then xgpl_commands_group2:ClearSelection() end
	if group ~= 3 then xgpl_commands_group3:ClearSelection() end
	if group ~= 4 then xgpl_commands_group4:ClearSelection() end
end