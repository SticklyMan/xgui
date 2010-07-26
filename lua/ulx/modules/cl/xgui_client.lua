--GUI for ULX -- by Stickly Man!
xgui = {}
--Set up a table for storing third party modules and information
xgui.modules = { tab={}, gamemode={}, setting={}, svsetting={} }
--Set up various hooks modules can "hook" into. 
xgui.hook = { onUnban={}, onProcessModules={}, onOpen={}, sbans={}, bans={}, users={}, adverts={}, gimps={}, maps={}, votemaps={}, gamemodes={}, sboxlimits={}, file_structure={} }

local function xgui_init()
	--Check if the server has XGUI installed
	RunConsoleCommand( "_xgui", "getInstalled" )

	--Data storing relevant information retrieved from server.
	xgui.data = { sbans = {}, bans = {}, users = {}, adverts = {}, gimps = {}, maps = {}, gamemodes = {}, sboxlimits = {} }
	
	--Initiate the base window (see xgui_helpers.lua for code)
	xgui.base = x_makeXGUIbase{}

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
	
	--Hold off adding the hook to reprocess modules on re-authentication to prevent being called on first auth.
	ULib.queueFunctionCall( hook.Add, "UCLAuthed", "XGUI_PermissionsChanged", xgui.PermissionsChanged )
end
hook.Add( "ULibLocalPlayerReady", "InitXGUI", xgui_init, 20 )

function xgui.processModules( wasvisible, activetab )
	local settings = nil
	xgui.base:Clear() --We need to remove any existing tabs in the GUI
	for k, v in pairs( xgui.modules.tab ) do
		if v.xbutton == nil then
			v.xbutton = x_makesysbutton{ x=565, y=5, w=20, btype="close", parent=v.panel }
			v.xbutton.DoClick = function()
				xgui.hide()
			end
		end
		if v.access then
			if LocalPlayer():query( v.access ) then
				xgui.base:AddSheet( v.name, v.panel, v.icon, false, false, v.tooltip )
				xgui.modules.tab[k].tabpanel = xgui.base.Items[#xgui.base.Items].Tab
			else
				xgui.modules.tab[k].tabpanel = nil
				v.panel:SetParent( xgui.null )
			end
		else
			xgui.base:AddSheet( v.name, v.panel, v.icon, false, false, v.tooltip )
			xgui.modules.tab[k].tabpanel = xgui.base.Items[#xgui.base.Items].Tab
		end
		if v.name == "Settings" then --Find the settings module to link other modules
			settings = v.panel.tabs
		end
	end
	
	settings:Clear() --Clear out settings tabs for reprocessing
	--Start by adding the gamemode module, if it exists
	for k, v in pairs( xgui.modules.gamemode ) do
		if v.access then
			if LocalPlayer():query( v.access ) then
				settings:AddSheet( v.name, v.panel, v.icon, false, false, v.tooltip )
				xgui.modules.setting[k].tabpanel = settings.Items[#settings.Items].Tab
			else
				xgui.modules.setting[k].tabpanel = nil
				v.panel:SetParent( xgui.null )
			end
		else
			settings:AddSheet( v.name, v.panel, v.icon, false, false, v.tooltip )
			xgui.modules.tab[k].tabpanel = settings.Items[#settings.Items].Tab
		end
	end
	
	--Now add the rest of the settings modules
	for k, v in pairs( xgui.modules.setting ) do
		if v.access then
			if LocalPlayer():query( v.access ) then
				settings:AddSheet( v.name, v.panel, v.icon, false, false, v.tooltip )
				xgui.modules.setting[k].tabpanel = settings.Items[#settings.Items].Tab
			else
				xgui.modules.setting[k].tabpanel = nil
				v.panel:SetParent( xgui.null )
			end
		else
			settings:AddSheet( v.name, v.panel, v.icon, false, false, v.tooltip )
			xgui.modules.tab[k].tabpanel = settings.Items[#settings.Items].Tab
		end
	end
	
	--Call any functions that requested to be called when permissions change
	for _, func in ipairs( xgui.hook["onProcessModules" ] ) do func() end
	
	if activetab then
		for k, v in ipairs( xgui.modules.tab ) do
			if v.name == table.concat( activetab, " " ) and v.panel:GetParent() ~= xgui.null then 
				if wasvisible then xgui.show( activetab ) end
				return
			end
		end
		--If the code here executes, that means the previous active tab is now hidden, so we set the active tab to the Players tab (which should always be visible)
		if wasvisible then 
			xgui.base:SetActiveTab( xgui.modules.tab[1].tabpanel )
			xgui.base.animFade:Start( xgui.base:GetFadeTime(), { OldTab = xgui.base.m_pActiveTab, NewTab = xgui.base.m_pActiveTab } ) --Rerun the fade animation so it shows up properly
		else
			xgui.base:SetActiveTab( xgui.modules.tab[1].tabpanel )
		end
	end
end

--If the player's group is changed, reprocess the XGUI modules for permissions
function xgui.PermissionsChanged( ply )
	if ply == LocalPlayer() then
		Msg( "Reprocessing XGUI modules- Player's permissions changed\n" )
		local activetab = nil
		if xgui.base:GetActiveTab() then
			activetab = string.Explode( " ", xgui.base:GetActiveTab():GetValue() )
		end
		xgui.processModules( xgui.base:IsVisible(), activetab )
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
			RunConsoleCommand( "xgui", "dataComplete" )
			xgui.receivingdata = false
			xgui.chunkbox:Remove()
			xgui.chunkbox = nil
		end
	end
end

--Function called when data chunk is recieved from server
function xgui.getChunk( data, curtable )
	xgui.chunkbox:Progress( curtable )
	--We need seperate cases for these to prevent data getting out-of-order (adverts), while supporting chunk'd tables
	if curtable == "bans" then
		for k, v in pairs( data ) do
			xgui.data[curtable][k] = v
		end
	elseif curtable == "sbans" then
		for k, v in ipairs( data ) do
			table.insert( xgui.data[curtable], v )
		end
	elseif curtable == "votemaps" then --Since ULX uses autocomplete for it's votemap list, we need to update it's table of votemaps
		ulx.populateClVotemaps( data )
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
		RunConsoleCommand( "xgui", "dataComplete" )
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