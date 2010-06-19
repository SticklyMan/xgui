--Bans module for ULX GUI -- by Stickly Man!
--Manages banned users and shows ban details

local xgui_bans = x_makeXpanel{ parent=xgui.null }
xgui_bans.showperma = x_makecheckbox{ x=445, y=10, value=1, label="Show Permabans", textcolor=color_black, parent=xgui_bans }
function xgui_bans.showperma:OnChange()
	xgui_bans.updateBans( )
end

xgui_bans.banlist = x_makelistview{ x=5, y=30, w=580, h=315, multiselect=false, parent=xgui_bans }
	xgui_bans.banlist:AddColumn( "Name/SteamID" )
	xgui_bans.banlist:AddColumn( "Banned By" )
	xgui_bans.banlist:AddColumn( "Unban Date" )
	xgui_bans.banlist:AddColumn( "Reason" )
xgui_bans.banlist.DoDoubleClick = function()
	xgui_bans.ShowBanDetailsWindow( xgui_bans.banlist:GetLine( xgui_bans.banlist:GetSelectedLine() ):GetValue( 5 ) )
end
xgui_bans.banlist.OnRowRightClick = function()
	local menu = DermaMenu()
	local xgui_temp = xgui_bans.banlist:GetLine( xgui_bans.banlist:GetSelectedLine() )
	menu:AddOption( "Details...", function() xgui_bans.ShowBanDetailsWindow( xgui_temp:GetValue( 5 ) ) end )
	menu:AddOption( "Update Name...", function() xgui_bans.UpdateBannameWindow( xgui_temp:GetValue( 5 ) ) end )
	menu:AddOption( "Update Reason...", function() xgui_bans.UpdateBanreasonWindow( xgui_temp:GetValue( 5 ) ) end )
	menu:AddOption( "Remove", function() xgui_bans.RemoveBan( xgui_temp:GetValue( 5 ) ) end )
	menu:Open()
end

x_makelabel{ x=200, y=10, label="Right-click on a ban for more options", parent=xgui_bans, textcolor=color_black }
xgui_bans.freezeban = x_makecheckbox{ x=140, y=348, label="Use Freezeban", tooltip="Freezes a player you have selected for banning while editing ban information (length, reason)", value=1, parent=xgui_bans, textcolor=color_black}
x_makebutton{ x=5, y=345, w=130, label="Add Ban...", parent=xgui_bans }.DoClick = function()
	local menu = DermaMenu()
	for k, v in ipairs( player.GetAll() ) do	
		menu:AddOption( v:Nick(), function() xgui_bans.ShowBanWindow( v:Nick(), v:SteamID() ) end )
	end
	menu:AddSpacer()
	menu:AddOption( "Ban by STEAMID...", function() xgui_bans.ShowBanWindow() end )
	menu:Open()
end
xgui_bans.sbanButton = x_makebutton{ x=455, y=345, w=130, label="View Source Bans...", parent=xgui_bans, disabled=#xgui.data.sbans > 0 and false or true }
xgui_bans.sbanButton.DoClick = function()
	if xgui_bans.sbanWindow and xgui_bans.sbanWindow:IsVisible() then return end
	xgui_bans.sbanWindow = x_makeframepopup{ w=160, h=400, label="Bans in banned_users.cfg", alwaysontop=true }
	xgui_bans.sbanWindow.bans = x_makelistview{ x=5, y=50, w=150, h=323, headerheight=0, parent=xgui_bans.sbanWindow }
	xgui_bans.sbanWindow.bans:AddColumn( "" )
	x_makelabel{ x=5, y=32, label="100 per page", parent=xgui_bans.sbanWindow }
	x_makesysbutton{ x=80, y=30, w=20, btype="left", parent=xgui_bans.sbanWindow }.DoClick = function()
		local xgui_temp = (tonumber( xgui_bans.sbanWindow.sbanPage:GetValue() - 1 ) > 0 ) and xgui_bans.sbanWindow.sbanPage:GetValue() - 1 or nil
		if xgui_temp then 
			xgui_bans.sbanWindow.gotoPage( xgui_temp )
			xgui_bans.sbanWindow.sbanPage:SetText( xgui_temp )
		end
	end
	x_makesysbutton{ x=100, y=30, w=20, btype="right", parent=xgui_bans.sbanWindow }.DoClick = function()
		local xgui_temp = (tonumber( xgui_bans.sbanWindow.sbanPage:GetValue() + 1 ) <= #xgui_bans.sbanWindow.sbanPage.Choices ) and xgui_bans.sbanWindow.sbanPage:GetValue() + 1 or nil
		if xgui_temp then 
			xgui_bans.sbanWindow.gotoPage( xgui_temp )
			xgui_bans.sbanWindow.sbanPage:SetText( xgui_temp )
		end
	end
	xgui_bans.sbanWindow.sbanPage = x_makemultichoice{x=120, y=30, w=35, text="1", parent=xgui_bans.sbanWindow}
	function xgui_bans.sbanWindow.sbanPage:OnSelect()
		xgui_bans.sbanWindow.gotoPage( tonumber( self:GetValue() ) )
	end
	x_makebutton{ x=5, y=373, w=75, label="Delete", parent=xgui_bans.sbanWindow }.DoClick = function()
		if xgui_bans.sbanWindow.bans:GetSelectedLine() then
			xgui_bans.RemoveBan( xgui_bans.sbanWindow.bans:GetSelected()[1]:GetColumnText(1), true )
		end
	end
	x_makebutton{ x=80, y=373, w=75, label="Add Details...", parent=xgui_bans.sbanWindow }.DoClick = function()
		if xgui_bans.sbanWindow.bans:GetSelectedLine() then
			xgui_bans.ShowBanWindow( nil, xgui_bans.sbanWindow.bans:GetSelected()[1]:GetColumnText(1), true )
		end
	end

	function xgui_bans.sbanWindow.gotoPage( pageno )
		xgui_bans.sbanWindow.bans:Clear()
		for i,ID in ipairs( xgui.data.sbans ) do
			if i > ( pageno-1 )*100 and i <= ( pageno )*100 then
				xgui_bans.sbanWindow.bans:AddLine( ID )
			end
		end
		xgui_bans.sbanWindow.sbanPage:SetText( pageno )
	end

	function xgui_bans.populateSBans( page )
		table.sort( xgui.data.sbans )
		xgui_bans.sbanWindow.sbanPage:Clear()
		for i=1,#xgui.data.sbans,100 do
			xgui_bans.sbanWindow.sbanPage:AddChoice( tostring(math.floor((i+100)/100)) )
		end
		if page then
			xgui_bans.sbanWindow.gotoPage( page )
		end
	end
	xgui_bans.populateSBans( 1 )
end

function xgui_bans.RemoveBan( ID, noName )
	local xgui_temp = "<Unknown>"
	if not noName then xgui_temp = xgui.data.bans[ID].name or "<Unknown>" end
	Derma_Query( "Are you sure you would like to unban " .. xgui_temp .. " - " .. ID .. "?", "XGUI WARNING", 
		"Remove", function()
			RunConsoleCommand( "ulx", "unban", ID ) end,
		"Cancel", function() end )
end

function xgui_bans.UpdateBannameWindow( ID )
	local xgui_updateBanName = x_makeframepopup{ w=400, h=60, label="Update Name of Banned Player " .. ( xgui.data.bans[ID].name or "<Unknown>" ) .. " - " .. ID, alwaysontop=true }
	local xgui_newBanName = x_maketextbox{ x=10, y=30, w=380, h=20, text=xgui.data.bans[ID].name, parent=xgui_updateBanName }
	xgui_newBanName.OnEnter = function()
		RunConsoleCommand( "xgui", "updateBanName", ID, ( xgui_newBanName:GetValue() ~= "" and xgui_newBanName:GetValue() or nil ) )
		xgui_updateBanName:Remove()
	end
end

function xgui_bans.UpdateBanreasonWindow( ID )
	local xgui_updateBanReason = x_makeframepopup{ w=400, h=60, label="Update Reason of Banned Player " .. ( xgui.data.bans[ID].name or "<Unknown>" ) .. " - " .. ID, alwaysontop=true }
	local xgui_newBanReason = x_maketextbox{ x=10, y=30, w=380, h=20, text=xgui.data.bans[ID].reason, parent=xgui_updateBanReason }
	xgui_newBanReason.OnEnter = function()
		RunConsoleCommand( "xgui", "updateBanReason", ID, ( xgui_newBanReason:GetValue() ~= "" and xgui_newBanReason:GetValue() or nil ) )
		xgui_updateBanReason:Remove()
	end
end

function xgui_bans.ShowBanDetailsWindow( ID )
	local xgui_detailswindow = x_makeframepopup{ label="Ban Details", w=285, h=240, alwaysontop=true }
	local name = x_makelabel{ x=50, y=30, label="Name:", parent=xgui_detailswindow }
	x_makelabel{ x=36, y=50, label="SteamID:", parent=xgui_detailswindow }
	x_makelabel{ x=33, y=70, label="Ban Date:", parent=xgui_detailswindow }
	x_makelabel{ x=20, y=90, label="Unban Date:", parent=xgui_detailswindow }
	x_makelabel{ x=10, y=110, label="Length of Ban:", parent=xgui_detailswindow }
	x_makelabel{ x=33, y=130, label="Time Left:", parent=xgui_detailswindow }
	x_makelabel{ x=26, y=150, label="Banned By:", parent=xgui_detailswindow }
	x_makelabel{ x=41, y=185, label="Reason:", parent=xgui_detailswindow }
	x_makelabel{ x=90, y=30, label=( xgui_temp and xgui.data.bans[ID].name or "<Unknown>" ), parent=xgui_detailswindow }
	x_makelabel{ x=90, y=50, label=ID, parent=xgui_detailswindow }
	if xgui.data.bans[ID].time then x_makelabel{ x=90, y=70, label=os.date( "%b %d, %Y - %I:%M:%S %p", xgui.data.bans[ID].time ), parent=xgui_detailswindow } end
	x_makelabel{ x=90, y=90, label=( tonumber( xgui.data.bans[ID].unban ) == 0 and "Never" or os.date( "%b %d, %Y - %I:%M:%S %p", xgui.data.bans[ID].unban ) ), parent=xgui_detailswindow }
	x_makelabel{ x=90, y=110, label=( tonumber( xgui.data.bans[ID].unban ) == 0 and "Permanent" or xgui_ConvertTime( xgui.data.bans[ID].unban - xgui.data.bans[ID].time ) ), parent=xgui_detailswindow }
	local timeleft = x_makelabel{ x=90, y=130, label=( tonumber( xgui.data.bans[ID].unban ) == 0 and "N/A" or xgui_ConvertTime( xgui.data.bans[ID].unban - os.time() ) ), parent=xgui_detailswindow }
	if xgui.data.bans[ID].admin then x_makelabel{ x=90, y=150, label=string.gsub( xgui.data.bans[ID].admin, "%(STEAM_%w:%w:%w*%)", "" ), parent=xgui_detailswindow } end
	if xgui.data.bans[ID].admin then x_makelabel{ x=90, y=165, label=string.match( xgui.data.bans[ID].admin, "%(STEAM_%w:%w:%w*%)" ), parent=xgui_detailswindow } end
	x_makelabel{ x=90, y=185, label=xgui.data.bans[ID].reason, parent=xgui_detailswindow }
	x_makebutton{ x=5, y=210, w=89, label="Edit Name...", parent=xgui_detailswindow }.DoClick = function() xgui_bans.UpdateBannameWindow( ID ) xgui_detailswindow:Remove() end
	x_makebutton{ x=99, y=210, w=88, label="Edit Reason...", parent=xgui_detailswindow }.DoClick = function() xgui_bans.UpdateBanreasonWindow( ID ) xgui_detailswindow:Remove() end
	x_makebutton{ x=192, y=210, w=88, label="Unban", parent=xgui_detailswindow }.DoClick = function() xgui_bans.RemoveBan( ID ) xgui_detailswindow:Remove() end
	
	if timeleft:GetValue() ~= "N/A" then
		function xgui_detailswindow.OnTimer()
			if xgui_detailswindow:IsVisible() and xgui.data.bans[ID] then
				timeleft:SetText( xgui_ConvertTime( xgui.data.bans[ID].unban - os.time() ) )
				if ( xgui.data.bans[ID].unban - os.time() ) <= 0 then 
					xgui_detailswindow:Remove()
				end
				timer.Simple( 1, xgui_detailswindow.OnTimer )
			end
		end
		xgui_detailswindow.OnTimer()
	end
end

function xgui_bans.ShowBanWindow( ply, ID, isUpdate )
	if xgui_bans.freezeban:GetChecked() == true and ply then
		RunConsoleCommand( "ulx", "freeze", ply )
	end
	local xgui_banwindow = x_makeframepopup{ label="Ban Player", w=285, h=180, alwaysontop=true }
		x_makelabel{ x=37, y=33, label="Name:", parent=xgui_banwindow }
		x_makelabel{ x=23, y=58, label="SteamID:", parent=xgui_banwindow }
		x_makelabel{ x=28, y=83, label="Reason:", parent=xgui_banwindow }
		x_makelabel{ x=10, y=108, label="Ban Length:", parent=xgui_banwindow }
		local name = x_maketextbox{ x=75, y=30, w=200, parent=xgui_banwindow }
		local steamID = x_maketextbox{ x=75, y=55, w=200, parent=xgui_banwindow }
		local reason = x_maketextbox{ x=75, y=80, w=200, parent=xgui_banwindow }
		local time = x_makeslider{ x=75, y=105, w=200, value=0, min=0, max=360, decimal=0, parent=xgui_banwindow }
		local interval = x_makemultichoice{x=75, y=105, w=75, text="Permanent", parent=xgui_banwindow}
		interval:AddChoice( "Permanent" )
		interval:AddChoice( "Minutes" )
		interval:AddChoice( "Hours" )
		interval:AddChoice( "Days" )
		interval:AddChoice( "Years" )
		x_makebutton{ x=93, y=150, w=100, label="Ban!", parent=xgui_banwindow }.DoClick = function()
			RunConsoleCommand( "_xgui", "restrictData", "true" ) --Lots of ulx commands are about to be called, this will prevent the server from sending the updated data multiple times.
			if isUpdate then
				RunConsoleCommand( "ulx", "unban", steamID:GetValue() )
			end
			local calctime = time:GetValue()
			if interval:GetValue() == "Permanent" then calctime = calctime*0
			elseif interval:GetValue() == "Hours" then calctime = calctime*60
			elseif interval:GetValue() == "Days" then calctime = calctime*1440
			elseif interval:GetValue() == "Years" then calctime = calctime*525600 end
			--If the player is online, ban them by their name so it saves the players name...
			for k, v in ipairs( player.GetAll() ) do
				if v:SteamID() == steamID:GetValue() or v:Nick() == name:GetValue() then
					RunConsoleCommand( "ulx", "ban", v:Nick(), calctime, reason:GetValue() )
					RunConsoleCommand( "_xgui", "restrictData", "false" )
					xgui_banwindow:Remove()
					return
				end
			end
			--...Otherwise ban by their ID (if valid), then call a function to set the banID name if specified.
			if string.match( steamID:GetValue(), "STEAM_%w:%w:%w*" ) then
				RunConsoleCommand( "ulx", "banid", steamID:GetValue(), calctime, reason:GetValue() )
				RunConsoleCommand( "xgui", "updateBanName", steamID:GetValue(), ( name:GetValue() ~= "" and name:GetValue() or nil ) )
				RunConsoleCommand( "_xgui", "restrictData", "false" )
				xgui_banwindow:Remove()
			end
		end
		
		if ply then name:SetText( ply ) end
		if ID then steamID:SetText( ID ) else steamID:SetText( "STEAM_0:" ) end
end

--If the user requests to sort by unban date, tell the listview to sort by column 6 (unban date in seconds) for better sort accuracy
xgui_bans.banlist.Columns[3].DoClick = function( self )
	self:GetParent():SortByColumn( 6, self:GetDescending() )
	self:SetDescending( !self:GetDescending() )
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

function xgui_bans.banRemoved( banid )
	for ID,_ in pairs( xgui.data.bans ) do
		if ID == banid then 
			xgui.data.bans[ID] = nil
			xgui_bans.updateBans()
			return
		end
	end
	for i,ID in ipairs( xgui.data.sbans ) do
		if ID == banid then
			table.remove( xgui.data.sbans, i )
			if xgui_bans.sbanWindow and xgui_bans.sbanWindow:IsVisible() then
				xgui_bans.populateSBans( tonumber( xgui_bans.sbanWindow.sbanPage:GetValue() ) )
			end
			return
		end
	end
end

function xgui_bans.populate( bantable )
	for steamID, baninfo in pairs( bantable ) do
		if not ( xgui_bans.showperma:GetChecked() == false and tonumber( baninfo.unban ) == 0 ) then
			if tonumber( baninfo.unban ) ~= 0 and baninfo.unban - os.time() <= 0 then RunConsoleCommand( "xgui", "refreshBans" ) end
			local xgui_tempadmin = ( baninfo.admin ) and string.gsub( baninfo.admin, "%(STEAM_%w:%w:%w*%)", "" ) or ""
			xgui_bans.banlist:AddLine( baninfo.name or steamID, xgui_tempadmin, (( tonumber( baninfo.unban ) ~= 0 ) and os.date( "%c", baninfo.unban )) or "Never", baninfo.reason, steamID, tonumber( baninfo.unban ) )
		end
	end
end

function xgui_bans.checkTimes()
	for ID, data in pairs( xgui.data.bans ) do
		if tonumber( data.unban ) ~= 0 and tonumber( data.unban ) < os.time() then
			RunConsoleCommand( "xgui", "refreshBans" )
		end
	end
end

function xgui_bans.updateBans( chunk )
	--(For large banlists) Since XGUI sends the bantables in chunks, we can make use of this and process each chunk as they come
	--If chunk is a table, then it contains a new chunk of data, so we should process it. If chunk is "clear", then clear the banlist for new chunks that will arrive soon.
	--Otherwise, do a refresh of the bantable.
	if type( chunk ) == "table" then
		xgui_bans.populate( chunk )
	elseif chunk == "clear" then
		xgui_bans.banlist:Clear()
	else
		xgui_bans.banlist:Clear()
		xgui_bans.populate( xgui.data.bans )
	end
end

function xgui_bans.updateSBans( chunk )
	if #xgui.data.sbans > 0 then
		xgui_bans.sbanButton:SetDisabled( false )
	end
	if xgui_bans.sbanWindow and xgui_bans.sbanWindow:IsVisible() then
		xgui_bans.populateSBans( tonumber( xgui_bans.sbanWindow.sbanPage:GetValue() ) )
	end
end

table.insert( xgui.modules.tab, { name="Bans", panel=xgui_bans, icon="gui/silkicons/exclamation", tooltip=nil, access="xgui_managebans" } )
table.insert( xgui.hook["bans"], xgui_bans.updateBans )
table.insert( xgui.hook["sbans"], xgui_bans.updateSBans )
table.insert( xgui.hook["onUnban"], xgui_bans.banRemoved )
table.insert( xgui.hook["onOpen"], xgui_bans.checkTimes )