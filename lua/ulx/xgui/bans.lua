--Bans module for ULX GUI -- by Stickly Man!
--Manages banned users and shows ban details

local xgui_bans = xlib.makepanel{ parent=xgui.null }
xgui_bans.isPopulating = 0
xgui_bans.showperma = xlib.makecheckbox{ x=445, y=10, value=1, label="Show Permabans", textcolor=color_black, parent=xgui_bans }
function xgui_bans.showperma:OnChange()
	xgui_bans.updateBans( )
end

xgui_bans.banlist = xlib.makelistview{ x=5, y=30, w=580, h=315, multiselect=false, parent=xgui_bans }
	xgui_bans.banlist:AddColumn( "Name/SteamID" )
	xgui_bans.banlist:AddColumn( "Banned By" )
	xgui_bans.banlist:AddColumn( "Unban Date" )
	xgui_bans.banlist:AddColumn( "Reason" )
xgui_bans.banlist.DoDoubleClick = function()
	xgui_bans.ShowBanDetailsWindow( xgui_bans.banlist:GetLine( xgui_bans.banlist:GetSelectedLine() ):GetValue( 5 ) )
end
xgui_bans.banlist.OnRowRightClick = function( self, LineID, line )
	local menu = DermaMenu()
	menu:AddOption( "Details...", function() xgui_bans.ShowBanDetailsWindow( line:GetValue( 5 ) ) end )
	menu:AddOption( "Update Name...", function() xgui_bans.UpdateBannameWindow( line:GetValue( 5 ) ) end )
	menu:AddOption( "Update Reason...", function() xgui_bans.UpdateBanreasonWindow( line:GetValue( 5 ) ) end )
	menu:AddOption( "Remove", function() xgui_bans.RemoveBan( line:GetValue( 5 ) ) end )
	menu:Open()
end

xlib.makelabel{ x=200, y=10, label="Right-click on a ban for more options", parent=xgui_bans, textcolor=color_black }
xgui_bans.freezeban = xlib.makecheckbox{ x=140, y=348, label="Use Freezeban", tooltip="Freezes a player you have selected for banning while editing ban information (!fban in chat)", value=1, parent=xgui_bans, textcolor=color_black}
xlib.makebutton{ x=5, y=345, w=130, label="Add Ban...", parent=xgui_bans }.DoClick = function()
	local menu = DermaMenu()
	for k, v in ipairs( player.GetAll() ) do	
		menu:AddOption( v:Nick(), function() xgui.ShowBanWindow( v:Nick(), v:SteamID(), xgui_bans.freezeban:GetChecked() ) end )
	end
	menu:AddSpacer()
	menu:AddOption( "Ban by STEAMID...", function() xgui.ShowBanWindow() end )
	menu:Open()
end
xgui_bans.sbanButton = xlib.makebutton{ x=455, y=345, w=130, label="View Source Bans...", parent=xgui_bans, disabled=#xgui.data.sbans > 0 and false or true }
xgui_bans.sbanButton.DoClick = function()
	if xgui_bans.sbanWindow and xgui_bans.sbanWindow:IsVisible() then return end
	xgui_bans.sbanWindow = xlib.makeframe{ w=160, h=400, label="Bans in banned_users.cfg", skin=xgui.settings.skin }
	xgui_bans.sbanWindow.bans = xlib.makelistview{ x=5, y=50, w=150, h=323, headerheight=0, parent=xgui_bans.sbanWindow }
	xgui_bans.sbanWindow.bans:AddColumn( "" )
	xlib.makelabel{ x=5, y=32, label="100 per page", parent=xgui_bans.sbanWindow }
	xlib.makesysbutton{ x=80, y=30, w=20, btype="left", parent=xgui_bans.sbanWindow }.DoClick = function()
		local xgui_temp = (tonumber( xgui_bans.sbanWindow.sbanPage:GetValue() - 1 ) > 0 ) and xgui_bans.sbanWindow.sbanPage:GetValue() - 1 or nil
		if xgui_temp then 
			xgui_bans.sbanWindow.gotoPage( xgui_temp )
			xgui_bans.sbanWindow.sbanPage:SetText( xgui_temp )
		end
	end
	xlib.makesysbutton{ x=100, y=30, w=20, btype="right", parent=xgui_bans.sbanWindow }.DoClick = function()
		local xgui_temp = (tonumber( xgui_bans.sbanWindow.sbanPage:GetValue() + 1 ) <= #xgui_bans.sbanWindow.sbanPage.Choices ) and xgui_bans.sbanWindow.sbanPage:GetValue() + 1 or nil
		if xgui_temp then 
			xgui_bans.sbanWindow.gotoPage( xgui_temp )
			xgui_bans.sbanWindow.sbanPage:SetText( xgui_temp )
		end
	end
	xgui_bans.sbanWindow.sbanPage = xlib.makemultichoice{x=120, y=30, w=35, text="1", parent=xgui_bans.sbanWindow}
	function xgui_bans.sbanWindow.sbanPage:OnSelect()
		xgui_bans.sbanWindow.gotoPage( tonumber( self:GetValue() ) )
	end
	xlib.makebutton{ x=5, y=373, w=75, label="Delete", parent=xgui_bans.sbanWindow }.DoClick = function()
		if xgui_bans.sbanWindow.bans:GetSelectedLine() then
			xgui_bans.RemoveBan( xgui_bans.sbanWindow.bans:GetSelected()[1]:GetColumnText(1), true )
		end
	end
	xlib.makebutton{ x=80, y=373, w=75, label="Add Details...", parent=xgui_bans.sbanWindow }.DoClick = function()
		if xgui_bans.sbanWindow.bans:GetSelectedLine() then
			xgui.ShowBanWindow( nil, xgui_bans.sbanWindow.bans:GetSelected()[1]:GetColumnText(1), nil, true )
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
	local xgui_updateBanName = xlib.makeframe{ w=400, h=60, label="Update Name of Banned Player " .. ( xgui.data.bans[ID].name or "<Unknown>" ) .. " - " .. ID, skin=xgui.settings.skin }
	local xgui_newBanName = xlib.maketextbox{ x=10, y=30, w=380, h=20, text=xgui.data.bans[ID].name, parent=xgui_updateBanName }
	xgui_newBanName.OnEnter = function()
		RunConsoleCommand( "xgui", "updateBan", ID, "", "", xgui_newBanName:GetValue() )
		xgui_updateBanName:Remove()
	end
end

function xgui_bans.UpdateBanreasonWindow( ID )
	local xgui_updateBanReason = xlib.makeframe{ w=300, h=80, label="Update Reason of Banned Player " .. ( xgui.data.bans[ID].name or "<Unknown>" ) .. " - " .. ID, skin=xgui.settings.skin }
	local xgui_newBanReason = xlib.makemultichoice{ x=10, y=30, w=280, text=xgui.data.bans[ID].reason, parent=xgui_updateBanReason, enableinput=true, selectall=true, choices=ULib.cmds.translatedCmds["ulx ban"].args[4].completes }
	xlib.makebutton{ x=125, y=55, w=50, label="OK", parent=xgui_updateBanReason }.DoClick = function()
		RunConsoleCommand( "xgui", "updateBan", ID, "", xgui_newBanReason:GetValue(), "" )
		xgui_updateBanReason:Remove()
	end
end

function xgui_bans.ShowBanDetailsWindow( ID )
	local xgui_detailswindow = xlib.makeframe{ label="Ban Details", w=285, h=295, skin=xgui.settings.skin }
	local name = xlib.makelabel{ x=50, y=30, label="Name:", parent=xgui_detailswindow }
	xlib.makelabel{ x=36, y=50, label="SteamID:", parent=xgui_detailswindow }
	xlib.makelabel{ x=33, y=70, label="Ban Date:", parent=xgui_detailswindow }
	xlib.makelabel{ x=20, y=90, label="Unban Date:", parent=xgui_detailswindow }
	xlib.makelabel{ x=10, y=110, label="Length of Ban:", parent=xgui_detailswindow }
	xlib.makelabel{ x=33, y=130, label="Time Left:", parent=xgui_detailswindow }
	xlib.makelabel{ x=26, y=150, label="Banned By:", parent=xgui_detailswindow }
	xlib.makelabel{ x=41, y=185, label="Reason:", parent=xgui_detailswindow }
	xlib.makelabel{ x=13, y=205, label="Last Updated:", parent=xgui_detailswindow }
	xlib.makelabel{ x=21, y=225, label="Updated by:", parent=xgui_detailswindow }
	xlib.makelabel{ x=90, y=30, label=( xgui.data.bans[ID].name or "<Unknown>" ), parent=xgui_detailswindow }
	xlib.makelabel{ x=90, y=50, label=ID, parent=xgui_detailswindow }
	if xgui.data.bans[ID].time then xlib.makelabel{ x=90, y=70, label=os.date( "%b %d, %Y - %I:%M:%S %p", xgui.data.bans[ID].time ), parent=xgui_detailswindow } end
	xlib.makelabel{ x=90, y=90, label=( tonumber( xgui.data.bans[ID].unban ) == 0 and "Never" or os.date( "%b %d, %Y - %I:%M:%S %p", xgui.data.bans[ID].unban ) ), parent=xgui_detailswindow }
	xlib.makelabel{ x=90, y=110, label=( tonumber( xgui.data.bans[ID].unban ) == 0 and "Permanent" or xgui.ConvertTime( xgui.data.bans[ID].unban - xgui.data.bans[ID].time ) ), parent=xgui_detailswindow }
	local timeleft = xlib.makelabel{ x=90, y=130, label=( tonumber( xgui.data.bans[ID].unban ) == 0 and "N/A" or xgui.ConvertTime( xgui.data.bans[ID].unban - os.time() ) ), parent=xgui_detailswindow }
	if xgui.data.bans[ID].admin then xlib.makelabel{ x=90, y=150, label=string.gsub( xgui.data.bans[ID].admin, "%(STEAM_%w:%w:%w*%)", "" ), parent=xgui_detailswindow } end
	if xgui.data.bans[ID].admin then xlib.makelabel{ x=90, y=165, label=string.match( xgui.data.bans[ID].admin, "%(STEAM_%w:%w:%w*%)" ), parent=xgui_detailswindow } end
	xlib.makelabel{ x=90, y=185, label=xgui.data.bans[ID].reason, parent=xgui_detailswindow }
	xlib.makelabel{ x=90, y=205, label=( ( xgui.data.bans[ID].modified_time == nil ) and "Never" or os.date( "%b %d, %Y - %I:%M:%S %p", xgui.data.bans[ID].modified_time ) ), parent=xgui_detailswindow }
	if xgui.data.bans[ID].modified_admin then xlib.makelabel{ x=90, y=225, label=string.gsub( xgui.data.bans[ID].modified_admin, "%(STEAM_%w:%w:%w*%)", "" ), parent=xgui_detailswindow } end
	if xgui.data.bans[ID].modified_admin then xlib.makelabel{ x=90, y=240, label=string.match( xgui.data.bans[ID].modified_admin, "%(STEAM_%w:%w:%w*%)" ), parent=xgui_detailswindow } end
	xlib.makebutton{ x=5, y=265, w=89, label="Edit Name...", parent=xgui_detailswindow }.DoClick = function() xgui_bans.UpdateBannameWindow( ID ) xgui_detailswindow:Remove() end
	xlib.makebutton{ x=99, y=265, w=88, label="Edit Reason...", parent=xgui_detailswindow }.DoClick = function() xgui_bans.UpdateBanreasonWindow( ID ) xgui_detailswindow:Remove() end
	xlib.makebutton{ x=192, y=265, w=88, label="Unban", parent=xgui_detailswindow }.DoClick = function() xgui_bans.RemoveBan( ID ) xgui_detailswindow:Remove() end
	
	if timeleft:GetValue() ~= "N/A" then
		function xgui_detailswindow.OnTimer()
			if xgui_detailswindow:IsVisible() then
				if not xgui.data.bans[ID] then
					xgui_detailswindow:Remove()
					return
				end
				local bantime = xgui.data.bans[ID].unban - os.time()
				if bantime <= 0 then
					timeleft:SetText( xgui.ConvertTime( 0 ) .. "      (Waiting for server)" )
				else
					timeleft:SetText( xgui.ConvertTime( bantime ) )
				end
				timeleft:SizeToContents()
				timer.Simple( 1, xgui_detailswindow.OnTimer )
			end
		end
		xgui_detailswindow.OnTimer()
	end
end

function xgui.ShowBanWindow( ply, ID, doFreeze, isUpdate )
	if LocalPlayer():query( "ulx ban" ) then
		local xgui_banwindow = xlib.makeframe{ label="Ban Player", w=285, h=180, showclose=false, skin=xgui.settings.skin }
		xlib.makelabel{ x=37, y=33, label="Name:", parent=xgui_banwindow }
		xlib.makelabel{ x=23, y=58, label="SteamID:", parent=xgui_banwindow }
		xlib.makelabel{ x=28, y=83, label="Reason:", parent=xgui_banwindow }
		xlib.makelabel{ x=10, y=108, label="Ban Length:", parent=xgui_banwindow }
		local name
		if not isUpdate then
			name = xlib.makemultichoice{ x=75, y=30, w=200, parent=xgui_banwindow, enableinput=true, selectall=true }
			for k,v in pairs( player.GetAll() ) do
				name:AddChoice( v:Nick(), v:SteamID() )
			end
			name.OnSelect = function( self, index, value, data )
				self.steamIDbox:SetText( data )
			end
		else
			name = xlib.maketextbox{ x=75, y=30, w=200, parent=xgui_banwindow, selectall=true }
		end
		local steamID = xlib.maketextbox{ x=75, y=55, w=200, selectall=true, parent=xgui_banwindow }
		name.steamIDbox = steamID --Make a pointer to the steamID textbox so it can change the value easily without referencing a global variable
		if isUpdate then
			steamID:SetDisabled( true )
		end
		local reason = xlib.makemultichoice{ x=75, y=80, w=200, parent=xgui_banwindow, enableinput=true, selectall=true, choices=ULib.cmds.translatedCmds["ulx ban"].args[4].completes }
		local time = xlib.makeslider{ x=75, y=105, w=200, value=0, min=0, max=360, decimal=0, disabled=true, parent=xgui_banwindow }
		local interval = xlib.makemultichoice{ x=75, y=105, w=75, text="Permanent", parent=xgui_banwindow }
		interval:AddChoice( "Permanent" )
		interval:AddChoice( "Minutes" )
		interval:AddChoice( "Hours" )
		interval:AddChoice( "Days" )
		interval:AddChoice( "Years" )
		interval.OnSelect = function( self, index, value, data )
			if value == "Permanent" then
				time:SetDisabled( true )
			else
				time:SetDisabled( false )
			end
		end
		if doFreeze and ply then
			RunConsoleCommand( "ulx", "freeze", ply )
			steamID:SetDisabled( true )
			name:SetDisabled( true )
		end
		xlib.makebutton{ x=165, y=150, w=75, label="Cancel", parent=xgui_banwindow }.DoClick = function()
			if doFreeze and ply then
				RunConsoleCommand( "ulx", "unfreeze", ply )
			end
			xgui_banwindow:Remove()
		end
		xlib.makebutton{ x=45, y=150, w=75, label="Ban!", parent=xgui_banwindow }.DoClick = function()
			local calctime = time:GetValue()
			if interval:GetValue() == "Permanent" then calctime = calctime*0
			elseif interval:GetValue() == "Hours" then calctime = calctime*60
			elseif interval:GetValue() == "Days" then calctime = calctime*1440
			elseif interval:GetValue() == "Years" then calctime = calctime*525600 end
			
			if isUpdate then
				RunConsoleCommand( "xgui", "updateBan", steamID:GetValue(), calctime, reason:GetValue(), name:GetValue(), "true" )
				xgui_banwindow:Remove()
				return
			end
			
			if ULib.isValidSteamID( steamID:GetValue() ) then
				local isOnline = false
				for k, v in ipairs( player.GetAll() ) do
					if v:SteamID() == steamID:GetValue() then
						isOnline = true
						break
					end
				end
				RunConsoleCommand( "ulx", "banid", steamID:GetValue(), calctime, reason:GetValue() )
				if not isOnline then
					RunConsoleCommand( "xgui", "updateBan", steamID:GetValue(), "", "", ( name:GetValue() ~= "" and name:GetValue() or nil ) )
				end
				xgui_banwindow:Remove()
			else
				for k, v in ipairs( player.GetAll() ) do
					if v:Nick() == name:GetValue() then
						RunConsoleCommand( "ulx", "ban", v:Nick(), calctime, reason:GetValue() )
						xgui_banwindow:Remove()
						break
					end
					Derma_Message( "Invalid SteamID or player name!" )
				end				
			end
		end
		
		if ply then name:SetText( ply ) end
		if ID then steamID:SetText( ID ) else steamID:SetText( "STEAM_0:" ) end
	end
end

--If the user requests to sort by unban date, tell the listview to sort by column 6 (unban date in seconds) for better sort accuracy
xgui_bans.banlist.Columns[3].DoClick = function( self )
	self:GetParent():SortByColumn( 6, self:GetDescending() )
	self:SetDescending( !self:GetDescending() )
end

function xgui.ConvertTime( seconds )
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

function xgui_bans.banUpdated( bantable )
	for SteamID, data in pairs( bantable ) do
		if xgui.data.bans[SteamID] then
			for i, v in ipairs( xgui_bans.banlist.Lines ) do
				if v.Columns[5]:GetValue() == SteamID then
					v:SetColumnText( 1, data.name or SteamID )
					v:SetColumnText( 2, data.admin and string.gsub( data.admin, "%(STEAM_%w:%w:%w*%)", "" ) or "" )
					v:SetColumnText( 3, (( tonumber( data.unban ) ~= 0 ) and os.date( "%c", data.unban )) or "Never" )
					v:SetColumnText( 4, data.reason )
					v:SetColumnText( 5, SteamID )
					v:SetColumnText( 6, tonumber( data.unban ) )
					break
				end				
			end
		else
			xgui_bans.populate( bantable )
		end
		xgui.data.bans[SteamID] = data
	end
end

function xgui_bans.populate( bantable )
	xgui_bans.showperma:SetDisabled( true )
	xgui_bans.isPopulating = xgui_bans.isPopulating + 1
	for steamID, baninfo in pairs( bantable ) do
		if not ( xgui_bans.showperma:GetChecked() == false and tonumber( baninfo.unban ) == 0 ) then
			xgui.queueFunctionCall( xgui_bans.addbanline, "bans", baninfo, steamID ) --Queue this via xgui.queueFunctionCall to prevent lag
		end
	end
	xgui.queueFunctionCall( function() xgui_bans.isPopulating = xgui_bans.isPopulating - 1 
										if xgui_bans.isPopulating == 0 then xgui_bans.showperma:SetDisabled( false ) end end, nil )
end

function xgui_bans.addbanline( baninfo, steamID )
	xgui_bans.banlist:AddLine(	baninfo.name or steamID,
								( baninfo.admin ) and string.gsub( baninfo.admin, "%(STEAM_%w:%w:%w*%)", "" ) or "",
								(( tonumber( baninfo.unban ) ~= 0 ) and os.date( "%c", baninfo.unban )) or "Never",
								baninfo.reason,
								steamID,
								tonumber( baninfo.unban ) )
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
table.insert( xgui.hook["updateBan"], xgui_bans.banUpdated )