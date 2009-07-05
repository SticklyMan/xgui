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
	xgpl_player_list = vgui.Create( "DListView" )
	xgpl_player_list:SetParent( xgui_player )
	xgpl_player_list:SetPos( 10,30 )
	xgpl_player_list:SetSize( 200,300 )
	xgpl_player_list:SetMultiSelect( false )
	xgpl_player_list:AddColumn( "Name" )
	xgpl_player_list:AddColumn( "Groups" )
-----------
	local xgpl_pm = vgui.Create( "DButton", xgui_player )
	xgpl_pm:SetSize( 200,20 )
	xgpl_pm:SetPos( 10, 330 )
	xgpl_pm:SetText( "Send player a private message..." )
	xgpl_pm.DoClick = function()
		
		if xgpl_player_list:GetSelectedLine() ~= nil then
		
			local xgpl_temp_player = xgpl_player_list:GetSelected()[1]:GetColumnText(1)
			
			local xgui_pm = vgui.Create( "DFrame" )
			xgui_pm:SetSize( 400, 60 )
			xgui_pm:Center()
			xgui_pm:SetTitle( "Send a message to " .. xgpl_temp_player )
			xgui_pm:MakePopup()
			
			local xgui_pm_text = vgui.Create( "DTextEntry", xgui_pm )
			xgui_pm_text:SetPos( 10, 30 )
			xgui_pm_text:SetTall( 20 )
			xgui_pm_text:SetWide( 380 )
			xgui_pm_text:SetEnterAllowed( true )
			xgui_pm_text.OnEnter = function()
					
				RunConsoleCommand( "ulx", "psay", xgpl_temp_player, unpack( string.Explode( " ", xgui_pm_text:GetValue() ) ) )
				xgui_pm:Remove()
			end
		end
	end
-----------
	xgpl_player_list:Clear()
	for k, v in pairs( player.GetAll() ) do	
		xgpl_player_list:AddLine( v:Nick(), table.concat( v:GetGroups() ) )
	end
	xgui_base:AddSheet( "Players", xgui_player, "gui/silkicons/group", false, false )
end

xgui_modules[1]=xgui_tab_player