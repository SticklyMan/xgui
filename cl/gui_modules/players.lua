--Players module for ULX GUI -- by Stickly Man!
--Handles all user-based commands, such as kick, slay, ban, etc.

function xgui_tab_player()
	xgui_player = x_makeXpanel( t )
------------
	xgui_rcon = x_maketextbox{ x=5, y=345, w=335, parent=xgui_player, text="Enter an RCON command...", focuscontrol=true }
	xgui_rcon.OnEnter = function()
		RunConsoleCommand( "ulx", "rcon", unpack( string.Explode(" ", xgui_rcon:GetValue() ) ) )
		xgui_rcon:SetText( "Enter an RCON command..." )
	end
-----------
	xgui_player_list = x_makelistview{ x=5, y=30, w=335, h=315, multiselect=false, parent=xgui_player }
	xgui_player_list:AddColumn( "Name" )
	xgui_player_list:AddColumn( "Group" )
-----------

	local xgui_pm = x_makebutton{ label="Send player a private message..." }
	xgui_pm.DoClick = function()
		
		if xgui_player_list:GetSelectedLine() then
		
			local xgui_temp_player = xgui_player_list:GetSelected()[1]:GetColumnText( 1 )
			local xgui_pm = x_makeframepopup{ label="Send a message to " .. xgui_temp_player, w=400, h=60 }
			local xgui_pm_text = x_maketextbox{ x=10, y=30, w=380, h=20, parent=xgui_pm }
			xgui_pm_text.OnEnter = function()
					
				RunConsoleCommand( "ulx", "psay", xgui_temp_player, unpack( string.Explode( " ", xgui_pm_text:GetValue() ) ) )
				xgui_pm:Remove()
			end
		end
	end
-----------
	local xgui_vote = x_makebutton{ label="Start a public vote..." }
	xgui_vote.DoClick = function()
	
	end
-----------
	xgui_commands = x_makepanelist{ x=345, y=30, w=90, h=335, parent=xgui_player, padding=1, spacing=1 }

	xgui_commands_group1 = x_makelistview{ headerheight=0, multiselect=false, h=136 }
	xgui_commands_group1.OnRowSelected = function() xgui_setcontrols( xgui_commands_group1:GetSelected()[1]:GetColumnText(1), 1 ) end
		xgui_commands_group1:AddColumn( "" )
		xgui_commands_group1:AddLine( "Assign Group" )
		xgui_commands_group1:AddLine( "Ban" )
		xgui_commands_group1:AddLine( "Cexec" )
		xgui_commands_group1:AddLine( "Commands" )
		xgui_commands_group1:AddLine( "Kick" )
		xgui_commands_group1:AddLine( "Spectate" )
		xgui_commands_group1:AddLine( "Voteban" )
		xgui_commands_group1:AddLine( "Votekick" )
		xgui_commands_group1:SetHeight( 17*#xgui_commands_group1:GetLines() )
	xgui_commands:AddItem( x_makecat{ label="Utilities", contents=xgui_commands_group1 } )
	
	xgui_commands_group2 = x_makelistview{ headerheight=0, multiselect=false }
	xgui_commands_group2.OnRowSelected = function() xgui_setcontrols( xgui_commands_group2:GetSelected()[1]:GetColumnText(1), 2 ) end
		xgui_commands_group2:AddColumn( "" )
		xgui_commands_group2:AddLine( "Armor" )
		xgui_commands_group2:AddLine( "Blind" )
		xgui_commands_group2:AddLine( "Cloak" )
		xgui_commands_group2:AddLine( "Freeze" )
		xgui_commands_group2:AddLine( "Ghost" )
		xgui_commands_group2:AddLine( "God" )
		xgui_commands_group2:AddLine( "HP" )
		xgui_commands_group2:AddLine( "Ignite" )
		xgui_commands_group2:AddLine( "Jail" )
		xgui_commands_group2:AddLine( "Maul" )
		xgui_commands_group2:AddLine( "Ragdoll" )
		xgui_commands_group2:AddLine( "Slap" )
		xgui_commands_group2:AddLine( "Slay" )
		xgui_commands_group2:AddLine( "SSlay" )
		xgui_commands_group2:AddLine( "Strip" )
		xgui_commands_group2:AddLine( "Whip" )
		xgui_commands_group2:SetHeight( 17*#xgui_commands_group2:GetLines() )
	xgui_commands:AddItem( x_makecat{ label="Fun", contents=xgui_commands_group2 } )
	
	xgui_commands_group3 = x_makelistview{ headerheight=0, multiselect=false, h=85 }
	xgui_commands_group3.OnRowSelected = function() xgui_setcontrols( xgui_commands_group3:GetSelected()[1]:GetColumnText(1), 3 ) end
		xgui_commands_group3:AddColumn( "" )
		xgui_commands_group3:AddLine( "Admin Msg" )
		xgui_commands_group3:AddLine( "Gag" )
		xgui_commands_group3:AddLine( "Gimp" )
		xgui_commands_group3:AddLine( "Mute" )
		xgui_commands_group3:AddLine( "Private Msg" )
		xgui_commands_group3:AddLine( "Screen Msg" )
		xgui_commands_group3:AddLine( "Text Msg" )
		xgui_commands_group3:AddLine( "Vote" )
		xgui_commands_group3:SetHeight( 17*#xgui_commands_group3:GetLines() )
	xgui_commands:AddItem( x_makecat{ label="Chat", contents=xgui_commands_group3 } )

	xgui_commands_group4 = x_makelistview{ headerheight=0, multiselect=false, h=85 }
	xgui_commands_group4.OnRowSelected = function() xgui_setcontrols( xgui_commands_group4:GetSelected()[1]:GetColumnText(1), 4 ) end
		xgui_commands_group4:AddColumn( "" )
		xgui_commands_group4:AddLine( "Bring" )
		xgui_commands_group4:AddLine( "Goto" )
		xgui_commands_group4:AddLine( "Noclip" )
		xgui_commands_group4:AddLine( "Send" )
		xgui_commands_group4:AddLine( "Teleport" )
		xgui_commands_group4:SetHeight( 17*#xgui_commands_group4:GetLines() )
	xgui_commands:AddItem( x_makecat{ label="Movement", contents=xgui_commands_group4 } )
------------
	xgui_player_list:Clear()
	for k, v in pairs( player.GetAll() ) do	
		xgui_player_list:AddLine( v:Nick(), v:GetUserGroup() )
	end
	xgui_base:AddSheet( "Players", xgui_player, "gui/silkicons/group", false, false )
end

xgui_modules[1]=xgui_tab_player

function xgui_setcontrols( command, group )
	if group ~= 1 then xgui_commands_group1:ClearSelection() end
	if group ~= 2 then xgui_commands_group2:ClearSelection() end
	if group ~= 3 then xgui_commands_group3:ClearSelection() end
	if group ~= 4 then xgui_commands_group4:ClearSelection() end
end