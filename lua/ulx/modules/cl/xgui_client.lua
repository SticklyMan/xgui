--GUI for ULX -- by Stickly Man!
xgui = {}
--Set up a table for storing third party modules and information
xgui.modules = { tab={}, setting={}, svsetting={} }
--Set up various hooks modules can "hook" into. 
xgui.hook = { onUnban={}, updateBan={}, onProcessModules={}, onOpen={}, sbans={}, bans={}, users={}, adverts={}, gimps={}, maps={}, votemaps={}, sboxlimits={}, teams={}, playermodels={}, accesses={} }

local function xgui_init( authedply )
	if authedply ~= LocalPlayer() then return end
	
	--Check if the server has XGUI installed
	RunConsoleCommand( "_xgui", "getInstalled" )

	--Data storing relevant information retrieved from server.
	xgui.data = { sbans={}, bans={}, users={}, adverts={}, gimps={}, gamemodes={}, sboxlimits={}, teams={}, playermodels={}, accesses={} }
	
	--Set up XGUI clientside settings, load settings from file if it exists
	xgui.settings = {}
	if file.Exists( "ulx/xgui_settings.txt" ) then
		local input = file.Read( "ulx/xgui_settings.txt" )
		input = input:match( "^.-\n(.*)$" )
		xgui.settings = ULib.parseKeyValues( input )
	end
	--Set default settings if they didn't get loaded
	if not xgui.settings.moduleOrder then xgui.settings.moduleOrder = { "Cmds", "Groups", "Maps", "Settings", "Bans" } end
	if not xgui.settings.settingOrder then xgui.settings.settingOrder = { "Sandbox", "Server", "XGUI" } end
	if not xgui.settings.animTime then xgui.settings.animTime = 0.2 else xgui.settings.animTime = tonumber( xgui.settings.animTime ) end
	if not xgui.settings.infoColor then xgui.settings.infoColor = Color(100,255,255,128) end
	if not xgui.settings.showLoadMsgs then xgui.settings.showLoadMsgs = true else xgui.settings.showLoadMsgs = tobool( xgui.settings.showLoadMsgs ) end
	if not xgui.settings.skin then xgui.settings.skin = "Default" end	
	
	--Initiate the base window (see xgui_helpers.lua for code)
	xgui.base = x_makeXGUIbase{}

	--Create the bottom infobar
	xgui.infobar = xlib.makepanel{ x=10, y=399, w=580, h=20, parent=xgui.base }
	xgui.infobar:NoClipping( true )
	xgui.infobar.Paint = function( self )
		draw.RoundedBoxEx( 4, 0, 1, 580, 20, xgui.settings.infoColor, false, false, true, true )
	end
	xlib.makelabel{ x=5, y=-10, label="\nXGUI - A GUI for ULX  |  by Stickly Man!  |  ver 10.09.23  |  ULX ver SVN  |  ULib ver SVN", textcolor=color_black, parent=xgui.infobar }:NoClipping( true )
	--xlib.makelabel{ x=5, y=-10, label="\nXGUI - A GUI for ULX  |  by Stickly Man!  |  ver 10.09.23  |  ULX ver " .. ulx.getVersion() .. "  |  ULib ver " .. ULib.VERSION, textcolor=color_black, parent=xgui.infobar }:NoClipping( true )
	xgui.thetime = xlib.makelabel{ x=515, y=-10, label="", textcolor=color_black, parent=xgui.infobar }
	xgui.thetime:NoClipping( true )
	xgui.thetime.check = function()
		xgui.thetime:SetText( os.date( "\n%I:%M:%S %p" ) )
		xgui.thetime:SizeToContents()
		timer.Simple( 1, xgui.thetime.check )
	end
	xgui.thetime.check()
	
	--Create an offscreen place to parent modules that the player can't access
	xgui.null = xlib.makepanel{ x=-10, y=-10, w=0, h=0 }
	xgui.null:SetVisible( false )
	
	--Load modules
	local sm = xgui.settings.showLoadMsgs
	if sm then
		Msg( "\n///////////////////////////////////////\n" )
		Msg( "//  ULX GUI -- Made by Stickly Man!  //\n" )
		Msg( "///////////////////////////////////////\n" )
		Msg( "// Loading GUI Modules...            //\n" )
	end
	for _, file in ipairs( file.FindInLua( "ulx/xgui/*.lua" ) ) do
		include( "ulx/xgui/" .. file )
		if sm then Msg( "//   " .. file .. string.rep( " ", 32 - file:len() ) .. "//\n" ) end
	end
	if sm then Msg( "// Loading Setting Modules...        //\n" ) end
	for _, file in ipairs( file.FindInLua( "ulx/xgui/settings/*.lua" ) ) do
		include( "ulx/xgui/settings/" .. file )
		if sm then Msg( "//   " .. file .. string.rep( " ", 32 - file:len() ) .. "//\n" ) end
	end
	if sm then Msg( "// Loading Gamemode Module(s)...     //\n" ) end
	if ULib.isSandbox() and GAMEMODE.FolderName ~= "sandbox" then -- If the gamemode sandbox-derived (but not sandbox, that will get added later), then add the sandbox Module
		include( "ulx/xgui/gamemodes/sandbox.lua" )
		if sm then Msg( "//   sandbox.lua                     //\n" ) end
	end
	for _, file in ipairs( file.FindInLua( "ulx/xgui/gamemodes/*.lua" ) ) do
		if string.lower( file ) == string.lower( GAMEMODE.FolderName .. ".lua" ) then
			include( "ulx/xgui/gamemodes/" .. file )
			if sm then Msg( "//   " .. file .. string.rep( " ", 32 - file:len() ) .. "//\n" ) end
			break
		end
		if sm then Msg( "//   No module found!                //\n" ) end
	end
	if sm then Msg( "// Modules Loaded!                   //\n" ) end
	if sm then Msg( "///////////////////////////////////////\n\n" ) end
	
	--Find any existing modules that aren't listed in the requested order.
	local function checkModulesOrder( moduleTable, sortTable )
		for _, m in ipairs( moduleTable ) do
			local notlisted = true
			for _, existing in ipairs( sortTable ) do
				if m.name == existing then
					notlisted = false
					break
				end
			end
			if notlisted then
				table.insert( sortTable, m.name )
			end
		end
	end
	checkModulesOrder( xgui.modules.tab, xgui.settings.moduleOrder )
	checkModulesOrder( xgui.modules.setting, xgui.settings.settingOrder )
	
	--Hold off adding the hook to reprocess modules on re-authentication to prevent being called on first auth.
	ULib.queueFunctionCall( hook.Add, "UCLAuthed", "XGUI_PermissionsChanged", xgui.PermissionsChanged )
	
	hook.Remove( "UCLAuthed", "InitXGUI" )
	xgui.initialized = true
	
	xgui.processModules()
end
hook.Add( "UCLAuthed", "InitXGUI", xgui_init, 20 )

function xgui.saveClientSettings()
	local output = "// This file stores clientside settings for XGUI.\n"
	output = output .. ULib.makeKeyValues( xgui.settings )
	file.Write( "ulx/xgui_settings.txt", output )
end

function xgui.checkModuleExists( modulename, moduletable )
	for k, v in ipairs( moduletable ) do
		if v.name == modulename then
			return k
		end
	end
	return false
end

function xgui.processModules( wasvisible )
	--Temporarily "disable" animations
	local tempfadetime = xgui.base:GetFadeTime()
	xgui.base:SetFadeTime( 0.0000001 )
	xgui.settings_tabs:SetFadeTime( 0.0000001 )
	
	local activetab = nil
	if xgui.base:GetActiveTab() then
		activetab = xgui.base:GetActiveTab():GetValue()
	end
	
	local activesettingstab = nil
	if xgui.settings_tabs:GetActiveTab() then
		activesettingstab = xgui.settings_tabs:GetActiveTab():GetValue()
	end
	
	xgui.base:Clear() --We need to remove any existing tabs in the GUI
	for _, modname in ipairs( xgui.settings.moduleOrder ) do
		local module = xgui.checkModuleExists( modname, xgui.modules.tab )
		if module then
			module = xgui.modules.tab[module]
			if module.xbutton == nil then
				module.xbutton = xlib.makesysbutton{ x=565, y=5, w=20, btype="close", parent=module.panel }
				module.xbutton.DoClick = function()
					xgui.hide()
				end
			end
			if module.access then
				if LocalPlayer():query( module.access ) then
					xgui.base:AddSheet( module.name, module.panel, module.icon, false, false, module.tooltip )
					module.tabpanel = xgui.base.Items[#xgui.base.Items].Tab
				else
					module.tabpanel = nil
					module.panel:SetParent( xgui.null )
				end
			else
				xgui.base:AddSheet( module.name, module.panel, module.icon, false, false, module.tooltip )
				module.tabpanel = xgui.base.Items[#xgui.base.Items].Tab
			end
		end
	end
	
	xgui.settings_tabs:Clear() --Clear out settings tabs for reprocessing
	for _, modname in ipairs( xgui.settings.settingOrder ) do
		local module = xgui.checkModuleExists( modname, xgui.modules.setting )
		if module then
			module = xgui.modules.setting[module]
			if module.access then
				if LocalPlayer():query( module.access ) then
					xgui.settings_tabs:AddSheet( module.name, module.panel, module.icon, false, false, module.tooltip )
					module.tabpanel = xgui.settings_tabs.Items[#xgui.settings_tabs.Items].Tab
				else
					module.tabpanel = nil
					module.panel:SetParent( xgui.null )
				end
			else
				xgui.settings_tabs:AddSheet( module.name, module.panel, module.icon, false, false, module.tooltip )
				module.tabpanel = xgui.settings_tabs.Items[#xgui.settings_tabs.Items].Tab
			end
		end
	end
	
	--Call any functions that requested to be called when permissions change
	xgui.callRefresh( "onProcessModules" )
	
	if activesettingstab then
		if xgui.settings_tabs:GetActiveTab():GetValue() ~= activesettingstab then
			for k, v in ipairs( xgui.modules.setting ) do
				if v.name == activesettingstab and v.panel:GetParent() ~= xgui.null then 
					xgui.settings_tabs:SetActiveTab( v.tabpanel )
					break
				end
			end
		end
		xgui.settings_tabs.animFade:Run()
	end

	if activetab then
		if xgui.base:GetActiveTab():GetValue() ~= activetab then --Don't do anything if it's already on the correct tab.
			for k, v in ipairs( xgui.modules.tab ) do
				if v.name == activetab and v.panel:GetParent() ~= xgui.null then 
					if wasvisible then xgui.show( activetab ) end
					xgui.base:SetFadeTime( tempfadetime )
					xgui.settings_tabs:SetFadeTime( tempfadetime )
					return
				end
			end
			--If the code here executes, that means the previous active tab is now hidden, so we set the active tab to the first tab
			xgui.base:SetActiveTab( xgui.base.Items[1].Tab )
			if wasvisible then
				xgui.base.animFade:Start( xgui.base:GetFadeTime(), { OldTab = xgui.base.m_pActiveTab, NewTab = xgui.base.m_pActiveTab } ) --Rerun the fade animation so it shows up properly
			end
		end
	end
	xgui.base:SetFadeTime( tempfadetime )
	xgui.settings_tabs:SetFadeTime( tempfadetime )
end

--If the player's group is changed, reprocess the XGUI modules for permissions
function xgui.PermissionsChanged( ply )
	if ply == LocalPlayer() then
		xgui.processModules( xgui.base:IsVisible() )
		
		--Figure out what data "types" need updating
		--Exclude the votemaps and gamemodes, since they're available to everybody anyways
		local getstring = {}
		if LocalPlayer():query( "xgui_svsettings" ) then
			if table.Count( xgui.data.gimps ) == 0 then table.insert( getstring, "gimps" ) end
			if table.Count( xgui.data.adverts ) == 0 then table.insert( getstring, "adverts" ) end
		else
			xgui.data.gimps = {}
			xgui.data.adverts = {}
		end
		if LocalPlayer():query( "xgui_managegroups" ) then
			if table.Count( xgui.data.users ) == 0 then table.insert( getstring, "users" ) end
			if table.Count( xgui.data.teams ) == 0 then table.insert( getstring, "teams" ) end
			if table.Count( xgui.data.playermodels ) == 0 then table.insert( getstring, "playermodels" ) end
			if table.Count( xgui.data.accesses ) == 0 then table.insert( getstring, "accesses" ) end
		else
			xgui.data.users = {}
			xgui.data.teams = {}
			xgui.data.playermodels = {}
			xgui.data.accesses = {}
		end
		if LocalPlayer():query( "xgui_managebans" ) then
			if table.Count( xgui.data.bans ) == 0 then table.insert( getstring, "bans" ) end
			if table.Count( xgui.data.sbans ) == 0 then table.insert( getstring, "sbans" ) end
		else
			xgui.data.bans = {}
			xgui.data.sbans = {}
		end
		if LocalPlayer():query( "xgui_gmsettings" ) then
			if table.Count( xgui.data.sboxlimits ) == 0 then table.insert( getstring, "sboxlimits" ) end
		else
			xgui.data.sboxlimits = {}
		end
		if #getstring > 0 then
			RunConsoleCommand( "xgui", "getdata", unpack( getstring ) )
		end
	end
end

function xgui.isNotInstalled( tabname )
	xgui.wait = xlib.makeframepopup{ label="XGUI", w=235, h=50, nopopup=true, showclose=false, skin=xgui.settings.skin }
	xgui.wait.tabname = tabname
	xlib.makelabel{ label="Waiting for server confimation... (5 seconds)", x=10, y=30, parent=xgui.wait }
	timer.Simple( 5, function( tabname )
		if xgui.isInstalled == nil then
			xgui.wait:Remove()
			xgui.wait = nil
			gui.EnableScreenClicker( true )
			RestoreCursorPosition( )
			xgui.notinstalled = xlib.makeframepopup{ label="Warning!", w=350, h=90, nopopup=true, showclose=false, skin=xgui.settings.skin }
			xlib.makelabel{ label="XGUI is not installed on this server! XGUI will now run in offline mode.", x=10, y=30, parent=xgui.notinstalled }
			xlib.makelabel{ label="Some features may not work, and information will be missing.", x=10, y=45, parent=xgui.notinstalled }
			xlib.makebutton{ x=155, y=63, w=40, label="OK", parent=xgui.notinstalled }.DoClick = function()
				xgui.notinstalled:Remove()
				xgui.show( tabname )
			end
		end
	end)
end

function xgui.show( tabname )
	if not xgui.initialized then return end
	
	--Check if XGUI is not installed, display the warning if hasn't been shown yet.
	if xgui.wait then return end
	if xgui.isInstalled == nil and xgui.notinstalled == nil then
		xgui.isNotInstalled( tabname )
		return
	end
	
	if not SinglePlayer() and not ULib.ucl.authed[LocalPlayer():UniqueID()] then 
		local xgui_temp = xlib.makeframepopup{ label="XGUI Error!", w=250, h=90, showclose=true, skin=xgui.settings.skin }
		xlib.makelabel{ label="Your ULX player has not been Authed!", x=10, y=30, parent=xgui_temp }
		xlib.makelabel{ label="Please wait a couple seconds and try again.", x=10, y=45, parent=xgui_temp }
		xlib.makebutton{ x=50, y=63, w=60, label="Try Again", parent=xgui_temp }.DoClick = function()
			xgui_temp:Remove()
			xgui.show( tabname )
		end
		xlib.makebutton{ x=140, y=63, w=60, label="Close", parent=xgui_temp }.DoClick = function()
			xgui_temp:Remove()
		end
		return
	end
	
	--Process modules if XGUI has no tabs!
	if #xgui.base.Items == 0 then xgui.processModules() end
	
	--Sets the active tab to tabname if it was specified
	if tabname then
		--In case the string name had spaces, it sent the whole argument table. Convert it to a string here!
		if type( tabname ) == "table" then
			tabname = table.concat( tabname, " " )
		end
		for _, v in ipairs( xgui.modules.tab ) do
			if string.lower( v.name ) == string.lower( tabname ) then
				xgui.base:SetActiveTab( v.tabpanel )
				if xgui.base:IsVisible() then return end
				break
			end
		end
	end
	
	gui.EnableScreenClicker( true )
	RestoreCursorPosition()
	xgui.base:SetVisible( true )
	if xgui.receivingdata then xgui.chunkbox:SetVisible( true ) end
	xgui.base.animFadeIn:Start( xgui.base:GetFadeTime(), xgui.base )
	
	if xgui.base.refreshSkin then
		xgui.base:SetSkin( xgui.settings.skin )	
		xgui.base.refreshSkin = nil
	end
	
	--Calls the functions requesting to hook when XGUI is opened
	if xgui.hook["onOpen"] then
		xgui.callRefresh( "onOpen" )
	end
end

function xgui.hide()
	xgui.base.animFadeOut:Start( xgui.base:GetFadeTime(), xgui.base )
end

function xgui.toggle()
	if xgui.base and not xgui.base:IsVisible() then
		xgui.show()
	else
		xgui.hide()
	end
end

--Called by server when data is ready to recieve
function xgui.expectChunks( numofchunks, updated )
	xgui.receivingdata = true
	
	if xgui.chunkbox then
		xgui.chunkbox:Remove()
		xgui.flushQueue( "chunkbox" ) --Remove the queue entry that would remove the chunkbox
	end
	
	xgui.chunkbox = xlib.makeframepopup{ label="XGUI is receiving data!", w=200, h=60, y=ScrH()/2-265, nopopup=true, draggable=false, showclose=false, skin=xgui.settings.skin }
	xgui.chunkbox.max = numofchunks
	xgui.chunkbox.progress = xlib.makeprogressbar{ x=10, y=30, w=180, h=20, min=0, max=numofchunks, percent=true, parent=xgui.chunkbox }
	xgui.chunkbox.progress.Label:SetText( "Waiting for server" .. " - " .. xgui.chunkbox.progress.Label:GetValue() )
	xgui.chunkbox.progress:PerformLayout()
	xgui.chunkbox:SetVisible( xgui.base:IsVisible() )
	function xgui.chunkbox:CloseFunc()
		xgui.receivingdata = false
		self:Remove()
		self = nil 
	end
	--Clear the tables that are going to be updated
	for _, v in ipairs( updated ) do
		xgui.data[v] = {}
		xgui.flushQueue( v ) --Flush any current clientside processing stuff from previous chunk retrievals.
		--Since bans are sent in chunks, lets call the functions that rely on ban changes with a "clear" command.
		if v == "bans" then 
			xgui.callRefresh( "bans", "clear" )
		elseif v == "sbans" then
			xgui.callRefresh( "sbans", "clear" )
		end
	end
	function xgui.chunkbox:Think()
		self:SetAlpha( xgui.base:GetAlpha() )
	end
	
	function xgui.chunkbox:Progress( curtable )
		self.progress:SetValue( self.progress:GetValue() + 1 )
		self.progress.Label:SetText( curtable .. " - " .. self.progress.Label:GetValue() )
		if self.progress:GetValue() == xgui.chunkbox.max then
			self.progress.Label:SetText( "Waiting for clientside processing" )	
			xgui.queueFunctionCall( xgui.chunkbox.CloseFunc, "chunkbox", xgui.chunkbox )
			RunConsoleCommand( "_xgui", "dataComplete" )
		end
		self.progress:PerformLayout()
	end
end

--Function called when data chunk is recieved from server
function xgui.getChunk( data, curtable )
	if curtable == "votemaps" then --Since ULX uses autocomplete for it's votemap list, we need to update its table of votemaps
		ulx.populateClVotemaps( data )
	else
		table.Merge( xgui.data[curtable], data )
	end
	xgui.callRefresh( curtable, data )
	xgui.chunkbox:Progress( curtable )
end

function xgui.callRefresh( cmd, data )
	--Run any functions that request to be called when "curtable" is updated
	for _, func in ipairs( xgui.hook[cmd] ) do func( data ) end
end

--This is essentially a straight copy of Megiddo's queueFunctionCall; Since XGUI tends to use it quite a lot, I decided to keep it seperate to prevent delays in ULib's stuff
--I also now get to add a method of flushing the queue based on a tag in the event that new data needs to be updated.
local stack = {}
local think_enabled = false
local function onThink()
	if not think_enabled then
		if hook.isInHook( "Think" ) then
			think_enabled = true
		end
	end
	
	local num = #stack
	if num > 0 then
		for i=1,3 do --Run 3 lines per frame
			if stack[1] ~= nil then
				local b, e = pcall( stack[ 1 ].fn, unpack( stack[ 1 ], 1, stack[ 1 ].n ) )
				if not b then
					ErrorNoHalt( "ULib queue error: " .. tostring( e ) .. "\n" )
				end
			end
		table.remove( stack, 1 ) -- Remove the first inserted item. This is FIFO
		end
	else
		hook.Remove( "Think", "XGUIQueueThink" )
	end
end

function xgui.queueFunctionCall( fn, tag, ... )
	if type( fn ) ~= "function" then
		error( "queueFunctionCall received a bad function", 2 )
		return
	end

	table.insert( stack, { fn=fn, tag=tag, n=select( "#", ... ), ... } )
	hook.Add( "Think", "XGUIQueueThink", onThink, -20 )
end

function xgui.flushQueue( tag )
	local removeIndecies = {}
	for i, fncall in ipairs( stack ) do
		if fncall.tag == tag then
			table.insert( removeIndecies, i )
		end
	end
	for i=#removeIndecies,1,-1 do --Remove the queue functions backwards to prevent desynchronization of pairs
		table.remove( stack, removeIndecies[i] )
	end
end

--As long as we're not sending data, force a check on the server to see if there's more data to send.
function xgui.forceDataCheck()
	if not xgui.chunkbox then
		RunConsoleCommand( "_xgui", "dataComplete" )
	end
end

function xgui.getInstalled()
	xgui.isInstalled = true
	if xgui.wait then
		local tab = xgui.wait.tabname
		xgui.wait:Remove()
		xgui.wait = nil
		xgui.show( tab )
	end
end

function xgui.cmd( ply, func, args )
	if args[1] == "show" then table.remove( args, 1 )  xgui.show( args )
	elseif args[1] == "hide" or args[1] == "close" then xgui.hide()
	elseif args[1] == nil or args[1] == "toggle" then xgui.toggle()
	else
		--Since the command arg passed isn't for a clientside function, we'll send it to the server
		if xgui.isInstalled then --First check that it's installed
			RunConsoleCommand( "_xgui", unpack( args ) )
		end
	end
end
concommand.Add( "xgui", xgui.cmd )