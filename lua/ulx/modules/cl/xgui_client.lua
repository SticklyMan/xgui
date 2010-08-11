--GUI for ULX -- by Stickly Man!
xgui = {}
--Set up a table for storing third party modules and information
xgui.modules = { tab={}, setting={}, svsetting={} }
--Set up various hooks modules can "hook" into. 
xgui.hook = { onUnban={}, onProcessModules={}, onOpen={}, sbans={}, bans={}, users={}, adverts={}, gimps={}, maps={}, votemaps={}, gamemodes={}, sboxlimits={} }

local function xgui_init( authedply )
	if authedply ~= LocalPlayer() then return end
	
	--Check if the server has XGUI installed
	RunConsoleCommand( "_xgui", "getInstalled" )

	--Data storing relevant information retrieved from server.
	xgui.data = { sbans = {}, bans = {}, users = {}, adverts = {}, gimps = {}, gamemodes = {}, sboxlimits = {} }
	
	--Initiate the base window (see xgui_helpers.lua for code)
	xgui.base = x_makeXGUIbase{}

	--Create the bottom infobar
	xgui.infobar = x_makepanel{ x=10, y=399, w=580, h=20, parent=xgui.base }
	xgui.infobar.color = Color(100,255,255,128)
	xgui.infobar:NoClipping( true )
	xgui.infobar.Paint = function( self )
		draw.RoundedBoxEx( 4, 0, 1, 580, 20, xgui.infobar.color, false, false, true, true )
	end
	x_makelabel{ x=5, y=-10, label="\nXGUI - A GUI for ULX  |  by Stickly Man!  |  ver 10.08.10  |  ULX ver SVN  |  ULib ver SVN", textcolor=color_black, parent=xgui.infobar }:NoClipping( true )
	--ulx.getVersion(), ULib.VERSION
	xgui.thetime = x_makelabel{ x=515, y=-10, label="", textcolor=color_black, parent=xgui.infobar }
	xgui.thetime:NoClipping( true )
	xgui.thetime.check = function()
		xgui.thetime:SetText( os.date( "\n%I:%M:%S %p" ) )
		xgui.thetime:SizeToContents()
		timer.Simple( 1, xgui.thetime.check )
	end
	xgui.thetime.check()
	
	--Create an offscreen place to parent modules that the player can't access
	xgui.null = x_makepanel{ x=-10, y=-10, w=0, h=0 }
	xgui.null:SetVisible( false )
	
	--Load modules
	Msg( "\n///////////////////////////////////////\n" )
	Msg( "//  ULX GUI -- Made by Stickly Man!  //\n" )
	Msg( "///////////////////////////////////////\n" )
	Msg( "// Loading GUI Modules...            //\n" )
	for _, file in ipairs( file.FindInLua( "ulx/xgui/*.lua" ) ) do
		include( "ulx/xgui/" .. file )
		Msg( "//   " .. file .. string.rep( " ", 32 - file:len() ) .. "//\n" )
	end
	Msg( "// Loading Setting Modules...        //\n" )	
	for _, file in ipairs( file.FindInLua( "ulx/xgui/settings/*.lua" ) ) do
		include( "ulx/xgui/settings/" .. file )
		Msg( "//   " .. file .. string.rep( " ", 32 - file:len() ) .. "//\n" )
	end
	Msg( "// Loading Gamemode Module(s)...     //\n" )
	if ULib.isSandbox() and gmod.GetGamemode().Name ~= "Sandbox" then -- If the gamemode sandbox-derived (but not sandbox, that will get added later), then add the sandbox Module
		include( "ulx/xgui/gamemodes/sandbox.lua" )
		Msg( "//   sandbox.lua                     //\n" )
	end
	for _, file in ipairs( file.FindInLua( "ulx/xgui/gamemodes/*.lua" ) ) do
		if string.lower( file ) == string.lower( gmod.GetGamemode().Name .. ".lua" ) then
			include( "ulx/xgui/gamemodes/" .. file )
			Msg( "//   " .. file .. string.rep( " ", 32 - file:len() ) .. "//\n" )
			break
		end
		Msg( "//   No module found!                //\n" )
	end
	Msg( "// Modules Loaded!                   //\n" )
	Msg( "///////////////////////////////////////\n\n" )
	
	--TODO: Load XGUI saved settings and whatnot here?
	--Temporary settings table
	xgui.settings = { moduleOrder = { "Cmds", "Groups", "Maps", "Settings", "Bans" }, settingOrder = { "Sandbox", "Server", "XGUI" } }
	
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
end
hook.Add( "UCLAuthed", "InitXGUI", xgui_init, 20 )

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
				module.xbutton = x_makesysbutton{ x=565, y=5, w=20, btype="close", parent=module.panel }
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
	for _, func in ipairs( xgui.hook["onProcessModules" ] ) do func() end
	
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
		Msg( "Reprocessing XGUI modules- Player's permissions changed\n" )
		xgui.processModules( xgui.base:IsVisible() )
		RunConsoleCommand( "xgui", "getdata" ) --Grab new server data
	end
end

function xgui.isNotInstalled( tabname )
	xgui.wait = x_makeframepopup{ label="XGUI", w=235, h=50, nopopup=true, showclose=false }
	xgui.wait.tabname = tabname
	x_makelabel{ label="Waiting for server confimation... (5 seconds)", x=10, y=30, parent=xgui.wait }
	timer.Simple( 5, function( tabname )
		if xgui.isInstalled == nil then
			xgui.wait:Remove()
			xgui.wait = nil
			gui.EnableScreenClicker( true )
			RestoreCursorPosition( )
			xgui.notinstalled = x_makeframepopup{ label="Warning!", w=350, h=90, nopopup=true, showclose=false }
			x_makelabel{ label="XGUI is not installed on this server! XGUI will now run in offline mode.", x=10, y=30, parent=xgui.notinstalled }
			x_makelabel{ label="Some features may not work, and information will be missing.", x=10, y=45, parent=xgui.notinstalled }
			x_makebutton{ x=155, y=63, w=40, label="OK", parent=xgui.notinstalled }.DoClick = function()
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
	
	if not ULib.ucl.authed[LocalPlayer():UniqueID()] then 
		local xgui_temp = x_makeframepopup{ label="XGUI Error!", w=250, h=90, showclose=true }
		x_makelabel{ label="Your ULX player has not been Authed!", x=10, y=30, parent=xgui_temp }
		x_makelabel{ label="Please wait a couple seconds and try again.", x=10, y=45, parent=xgui_temp }
		x_makebutton{ x=50, y=63, w=60, label="Try Again", parent=xgui_temp }.DoClick = function()
			xgui_temp:Remove()
			xgui.show( tabname )
		end
		x_makebutton{ x=140, y=63, w=60, label="Close", parent=xgui_temp }.DoClick = function()
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
	
	--Calls the functions requesting to hook when XGUI is opened
	if xgui.hook["onOpen"] then
		for _, func in ipairs( xgui.hook["onOpen"] ) do func() end
	end
end

function xgui.hide()
	RememberCursorPosition()
	gui.EnableScreenClicker( false )
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
	xgui.chunkbox = x_makeframepopup{ label="XGUI is receiving data!", w=200, h=60, y=ScrH()/2-265, nopopup=true, draggable=false, showclose=false }
	xgui.chunkbox.max = numofchunks
	xgui.chunkbox.progress = x_makeprogressbar{ x=10, y=30, w=180, h=20, min=0, max=numofchunks, percent=true, parent=xgui.chunkbox }
	xgui.chunkbox.progress.Label:SetText( "Waiting for server" .. " - " .. xgui.chunkbox.progress.Label:GetValue() )
	xgui.chunkbox.progress:PerformLayout()
	xgui.chunkbox:SetVisible( xgui.base:IsVisible() )
	--Clear the tables that are going to be updated
	for _, v in ipairs( updated ) do
		xgui.data[v] = {}
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
		self.progress:PerformLayout()
		if self.progress:GetValue() == xgui.chunkbox.max then
			RunConsoleCommand( "_xgui", "dataComplete" )
			xgui.receivingdata = false
			xgui.chunkbox:Remove()
			xgui.chunkbox = nil
		end
	end
end

--Function called when data chunk is recieved from server
function xgui.getChunk( data, curtable )
	xgui.chunkbox:Progress( curtable )
	if curtable == "bans" then
		for k, v in pairs( data ) do
			xgui.data[curtable][k] = v
		end
	elseif curtable == "sbans" then
		for k, v in ipairs( data ) do
			table.insert( xgui.data[curtable], v )
		end
	elseif curtable == "votemaps" then --Since ULX uses autocomplete for it's votemap list, we need to update its table of votemaps
		ulx.populateClVotemaps( data )
		xgui.data[curtable] = nil
	else
		xgui.data[curtable] = data
	end
	xgui.callRefresh( curtable, data )
end

function xgui.callRefresh( cmd, data )
	--Run any functions that request to be called when "curtable" is updated
	---Since bans are split into chunks, send the chunktable for updating.
	if cmd == "bans" or cmd == "sbans" or cmd == "onUnban" then
		for _, func in ipairs( xgui.hook[cmd] ) do func( data ) end
	else
		for _, func in ipairs( xgui.hook[cmd] ) do func() end
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