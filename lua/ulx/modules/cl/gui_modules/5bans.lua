--Bans module for ULX GUI -- by Stickly Man!
--Manages banned users and shows ban details

xgui_bans = x_makeXpanel{ parent=xgui_null }
xgui_banlist = x_makelistview{ x=5, y=30, w=580, h=315, multiselect=false, parent=xgui_bans }
	xgui_banlist:AddColumn( "Name/SteamID" )
	xgui_banlist:AddColumn( "Banned By" )
	xgui_banlist:AddColumn( "Unban Date" )
	xgui_banlist:AddColumn( "Reason" )
xgui_banlist.DoDoubleClick = function()
	xgui_bans.ShowBanDetailsWindow( xgui_banlist:GetLine( xgui_banlist:GetSelectedLine() ):GetValue( 5 ) )
end
xgui_banlist.OnRowRightClick = function()
	xgui_bans_menu = DermaMenu()
	local xgui_temp = xgui_banlist:GetLine( xgui_banlist:GetSelectedLine() )
	xgui_bans_menu:AddOption( "Details...", function() xgui_bans.ShowBanDetailsWindow( xgui_temp:GetValue( 5 ) ) end )
	xgui_bans_menu:AddOption( "Update Name...", function() xgui_bans.UpdateBannameWindow( xgui_temp:GetValue( 5 ) ) end )
	xgui_bans_menu:AddOption( "Remove", function() xgui_bans.RemoveBan( xgui_temp:GetValue( 5 ) ) end )
	xgui_bans_menu:Open()
end

x_makebutton{ x=5, y=345, w=130, label="Add Ban...", parent=xgui_bans }.DoClick = function()
	xgui_bans_addlist = DermaMenu()
	for k, v in pairs( player.GetAll() ) do	
		xgui_bans_addlist:AddOption( v:Nick(), function() xgui_bans.ShowBanWindow( v:Nick(), v:SteamID() ) end )
	end
	xgui_bans_addlist:AddSpacer()
	xgui_bans_addlist:AddOption( "Ban by STEAMID...", function() xgui_bans.ShowBanWindow() end )
	xgui_bans_addlist:Open()
end
x_makebutton{ x=320, y=345, w=130, label="Remove Ban", parent=xgui_bans }.DoClick = function()
	local xgui_temp = xgui_banlist:GetLine( xgui_banlist:GetSelectedLine() )
	if xgui_temp ~= nil then
		xgui_bans.RemoveBan( xgui_temp:GetValue( 5 ) )
	end
end
x_makebutton{ x=455, y=345, w=130, label="Details...", parent=xgui_bans }.DoClick = function()
	local xgui_temp = xgui_banlist:GetLine( xgui_banlist:GetSelectedLine() )
	if xgui_temp ~= nil then
		xgui_bans.ShowBanDetailsWindow( xgui_temp:GetValue( 5 ) )
	end
end

function xgui_bans.RemoveBan( ID )
	Derma_Query( "Are you sure you would like to unban " .. ( xgui_data.bans[ID].name or "<Unknown>" ) .. " - " .. ID .. "?", "XGUI WARNING", 
		"Remove", function()
			RunConsoleCommand( "ulx", "unban", ID ) end,
		"Cancel", function() end )
end

function xgui_bans.UpdateBannameWindow( ID )
	local xgui_updateBanName = x_makeframepopup{ w=400, h=60, label="Update Name of Banned Player " .. ( xgui_data.bans[ID].name or "<Unknown>" ) .. " - " .. ID }
	local xgui_newBanName = x_maketextbox{ x=10, y=30, w=380, h=20, text=xgui_data.bans[ID].name, parent=xgui_updateBanName }
	xgui_newBanName.OnEnter = function()
		RunConsoleCommand( "xgui", "updateBanName", ID, ( xgui_newBanName:GetValue() ~= "" and xgui_newBanName:GetValue() or nil ) )
		xgui_updateBanName:Remove()
	end
end

function xgui_bans.ShowBanDetailsWindow( ID )
	local xgui_detailswindow = x_makeframepopup{ label="Ban Details", w=285, h=240 }
	local name = x_makelabel{ x=50, y=30, label="Name:", parent=xgui_detailswindow }
	x_makelabel{ x=36, y=50, label="SteamID:", parent=xgui_detailswindow }
	x_makelabel{ x=33, y=70, label="Ban Date:", parent=xgui_detailswindow }
	x_makelabel{ x=20, y=90, label="Unban Date:", parent=xgui_detailswindow }
	x_makelabel{ x=10, y=110, label="Length of Ban:", parent=xgui_detailswindow }
	x_makelabel{ x=33, y=130, label="Time Left:", parent=xgui_detailswindow }
	x_makelabel{ x=26, y=150, label="Banned By:", parent=xgui_detailswindow }
	x_makelabel{ x=41, y=185, label="Reason:", parent=xgui_detailswindow }
	x_makelabel{ x=90, y=30, label=( xgui_temp and xgui_data.bans[ID].name or "<Unknown>" ), parent=xgui_detailswindow }
	x_makelabel{ x=90, y=50, label=ID, parent=xgui_detailswindow }
	if xgui_data.bans[ID].time then x_makelabel{ x=90, y=70, label=os.date( "%b %d, %Y - %I:%M:%S %p", xgui_data.bans[ID].time ), parent=xgui_detailswindow } end
	x_makelabel{ x=90, y=90, label=( tonumber( xgui_data.bans[ID].unban ) == 0 and "Never" or os.date( "%b %d, %Y - %I:%M:%S %p", xgui_data.bans[ID].unban ) ), parent=xgui_detailswindow }
	x_makelabel{ x=90, y=110, label=( tonumber( xgui_data.bans[ID].unban ) == 0 and "Permanent" or xgui_ConvertTime( xgui_data.bans[ID].unban - xgui_data.bans[ID].time ) ), parent=xgui_detailswindow }
	local timeleft = x_makelabel{ x=90, y=130, label=( tonumber( xgui_data.bans[ID].unban ) == 0 and "N/A" or xgui_ConvertTime( xgui_data.bans[ID].unban - os.time() ) ), parent=xgui_detailswindow }
	if xgui_data.bans[ID].admin then x_makelabel{ x=90, y=150, label=string.gsub( xgui_data.bans[ID].admin, "%(STEAM_%w:%w:%w*%)", "" ), parent=xgui_detailswindow } end
	if xgui_data.bans[ID].admin then x_makelabel{ x=90, y=165, label=string.match( xgui_data.bans[ID].admin, "%(STEAM_%w:%w:%w*%)" ), parent=xgui_detailswindow } end
	x_makelabel{ x=90, y=185, label=xgui_data.bans[ID].reason, parent=xgui_detailswindow }
	x_makebutton{ x=40, y=210, w=90, label="Update Name...", parent=xgui_detailswindow }.DoClick = function() xgui_bans.UpdateBannameWindow( ID ) xgui_detailswindow:Remove() end
	x_makebutton{ x=155, y=210, w=90, label="Close", parent=xgui_detailswindow }.DoClick = function() xgui_detailswindow:Remove() end
	
	if timeleft:GetValue() ~= "N/A" then
		function xgui_detailswindow.OnTimer()
			if xgui_detailswindow:IsVisible() and xgui_data.bans[ID] then
				timeleft:SetText( xgui_ConvertTime( xgui_data.bans[ID].unban - os.time() ) )
				if ( xgui_data.bans[ID].unban - os.time() ) <= 0 then 
					RunConsoleCommand( "xgui", "refreshBans" )
					xgui_detailswindow:Remove()
				end
				timer.Simple( 1, xgui_detailswindow.OnTimer )
			end
		end
		xgui_detailswindow.OnTimer()
	end
end

function xgui_bans.ShowBanWindow( ply, ID )
	xgui_banwindow = x_makeframepopup{ label="Ban Player", w=285, h=180 }
		x_makelabel{ x=37, y=33, label="Name:", parent=xgui_banwindow }
		x_makelabel{ x=23, y=58, label="SteamID:", parent=xgui_banwindow }
		x_makelabel{ x=28, y=83, label="Reason:", parent=xgui_banwindow }
		x_makelabel{ x=10, y=108, label="Ban Length:", parent=xgui_banwindow }
		local name = x_maketextbox{ x=75, y=30, w=200, parent=xgui_banwindow }
		local steamID = x_maketextbox{ x=75, y=55, w=200, parent=xgui_banwindow }
		local reason = x_maketextbox{ x=75, y=80, w=200, parent=xgui_banwindow }
		local time = x_makeslider{ x=75, y=105, w=200, label="Hours, 0 for permaban", value=0, min=0, max=184, decimal=1, parent=xgui_banwindow }
		x_makebutton{ x=93, y=150, w=100, label="Ban!", parent=xgui_banwindow }.DoClick = function()
			--If the player is online, ban them by their name so it saves the players name...
			for k, v in pairs( player.GetAll() ) do
				if v:SteamID() == steamID:GetValue() or v:Nick() == name:GetValue() then
					RunConsoleCommand( "ulx", "ban", v:Nick(), time:GetValue()*60, reason:GetValue() )
					xgui_banwindow:Remove()
					return
				end
			end
			--...Otherwise ban by their ID (if valid), then call a function to set the banID name if specified.
			if string.match( steamID:GetValue(), "STEAM_%w:%w:%w*" ) ~= nil then
				RunConsoleCommand( "ulx", "banid", steamID:GetValue(), time:GetValue()*60, reason:GetValue() )
				RunConsoleCommand( "xgui", "updateBanName", steamID:GetValue(), ( name:GetValue() ~= "" and name:GetValue() or nil ) )
				xgui_banwindow:Remove()
			end
		end
		
		if ply then name:SetText( ply ) end
		if ID then steamID:SetText( ID ) else steamID:SetText( "STEAM_0:" ) end
end

--If the user requests to sort by unban date, tell the listview to sort by column 6 (unban date in seconds) for better sort accuracy
xgui_banlist.Columns[3].DoClick = function( self )
	self:GetParent():SortByColumn( 6, self:GetDescending() )
	self:SetDescending( !self:GetDescending() )
end

function xgui_bans.XGUI_Refresh( banData )
	if type( banData ) == "table" then xgui_data.bans = banData end
	xgui_banlist:Clear()
	for steamID, baninfo in pairs( xgui_data.bans ) do
			if tonumber( baninfo.unban ) ~= 0 and baninfo.unban - os.time() <= 0 then RunConsoleCommand( "xgui", "refreshBans" ) end
			local xgui_tempadmin = ( baninfo.admin ~= nil ) and string.gsub( baninfo.admin, "%(STEAM_%w:%w:%w*%)", "" ) or ""
			xgui_banlist:AddLine( baninfo.name or steamID, xgui_tempadmin, (( tonumber( baninfo.unban ) ~= 0 ) and os.date( "%c", baninfo.unban )) or "Never", baninfo.reason, steamID, tonumber( baninfo.unban ) )
	end
end

function xgui_ConvertTime( seconds )
	--Convert number of seconds remaining to something more legible (Thanks JamminR!)
	local years = math.floor( seconds / 31536000 )
	seconds = seconds - ( years * 31536000 )
	local days = math.floor( seconds / 86400 )
	seconds = seconds - ( days * 86400 )
	local hours = math.floor( seconds/3600 )
	seconds = seconds - ( hours * 3600 )
	local minutes = math.floor( seconds/60 )
	seconds = seconds - ( minutes * 60 )
	local xgui_temp = ""
	if years ~= 0 then xgui_temp = xgui_temp .. years .. " year" .. ( ( years > 1 ) and "s, " or ", " ) end
	if days ~= 0 then xgui_temp = xgui_temp .. days .. " day" .. ( ( days > 1 ) and "s, " or ", " ) end
	xgui_temp = xgui_temp .. ( ( hours < 10 ) and "0" or "" ) .. hours .. ":"
	xgui_temp = xgui_temp .. ( ( minutes < 10 ) and "0" or "" ) .. minutes .. ":"
	return xgui_temp .. ( ( seconds < 10 and "0" or "" ) .. seconds )
end

table.insert( xgui_modules.tab, { name="Bans", panel=xgui_bans, icon="gui/silkicons/exclamation", tooltip=nil, access="xgui_managebans" } )