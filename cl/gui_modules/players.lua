--Players module for ULX GUI -- by Stickly Man!
--Handles all user-based commands, such as kick, slay, ban, etc.

local function xgui_tab_player()
	xgui_player = vgui.Create( "DPanel" )
-----------
	xgui_player.Paint = function()
		surface.SetDrawColor( 191, 191, 191, 255 )
		surface.DrawRect( 0, 0, 590, 390 )
	end
-----------
	xgpl_player_list = x_makelistview{ x=10, y=30, w=380, h=320, multiselect=false, parent=xgui_player }
	xgpl_player_list:AddColumn( "Name" )
	xgpl_player_list:AddColumn( "Groups" )
-----------
	local xgpl_pm = x_makebutton{ x=10, y=330, w=200, h=20, label="Send player a private message...", parent=xgui_player }
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
	xgpl_commands = x_makepanelist{ x=400, y=30, w=180, h=320, parent=xgui_player }
	//xgpl_commands_cat1 = 
------------
	xgpl_player_list:Clear()
	for k, v in pairs( player.GetAll() ) do	
		xgpl_player_list:AddLine( v:Nick(), table.concat( v:GetGroups() ) )
	end
	xgui_base:AddSheet( "Players", xgui_player, "gui/silkicons/group", false, false )
end

xgui_modules[1]=xgui_tab_player