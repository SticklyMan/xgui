--GUI for ULX -- by Stickly Man!

local function xgui_init()
	--Check if the server has XGUI installed
	RunConsoleCommand( "_xgui", "getInstalled" )

	--Data storing relevant information retrieved from server.
	xgui_data = { sbans = {}, bans = {}, users = {}, adverts = {}, gimps = {}, maps = {}, votemaps = {}, gamemodes = {} }
	--Set up a table for storing third party modules and information
	xgui_modules = { tab = {} }
	--Set up various hooks modules can "hook" into. 
	xgui_modules.hook = { onUnban={}, onOpen = {}, sbans = {}, bans = {}, users = {}, adverts = {}, gimps = {}, maps = {}, votemaps = {}, gamemodes = {} }

	--Used to set which panel has the keyboard focus
	xgui_textpanel=nil

	--Call for server data (Give it a bit of time to recieve the installed var from the server)
	RunConsoleCommand( "_xgui", "getdata" )
	
	--Initiate the base window (see xgui_helpers.lua for code)
	xgui_base = x_makeXGUIbase()

	--Create an offscreen place to parent modules that the player can't access
	xgui_null = x_makepanel{ x=-10, y=-10, w=0, h=0 }
	xgui_null:SetVisible( false )
	
	--Load modules
	Msg( "\n///////////////////////////////////////\n" )
	Msg( "//  ULX GUI -- Made by Stickly Man!  //\n" )
	Msg( "///////////////////////////////////////\n" )
	Msg( "//  Loading/Initializing modules...  //\n" )
	for _, file in ipairs( file.FindInLua( "ulx/modules/cl/gui_modules/*.lua" ) ) do
		include( "ulx/modules/cl/gui_modules/" .. file )
		Msg( "//   " .. file .. string.rep( " ", 32 - file:len() ) .. "//\n" )
	end
	Msg( "//  Modules Loaded!                  //\n" )
	Msg( "///////////////////////////////////////\n\n" )
	
	--Hold off adding the hook to reprocess modules on re-authentication to prevent being called on first auth.
	ULib.queueFunctionCall( hook.Add, "UCLAuthed", "XGUI_PermissionsChanged", xgui_PermissionsChanged )
end
hook.Add( "ULibLocalPlayerReady", "InitXGUI", xgui_init, 20 )
--hook.Add( "PlayerInitialSpawn", "InitXGUI", xgui_init, 20 )

function xgui_processModules( xgui_wasvisible )
	if xgui_wasvisible then xgui_hide() end
	xgui_base:Clear() --We need to remove any existing tabs in the GUI
	for k, v in pairs( xgui_modules.tab ) do
		if v.xbutton == nil then
			v.xbutton = x_makesysbutton{ x=565, y=5, w=20, btype="close", parent=v.panel }
			v.xbutton.DoClick = function()
				xgui_hide()
			end
		end
		if v.access ~= nil then
			if LocalPlayer():query( v.access ) then
				xgui_base:AddSheet( v.name, v.panel, v.icon, false, false, v.tooltip )
				xgui_modules.tab[k].tabpanel = xgui_base.Items[#xgui_base.Items].Tab
			else
				xgui_modules.tab[k].tabpanel = nil
				v.panel:SetParent( xgui_null )
			end
		else
			xgui_base:AddSheet( v.name, v.panel, v.icon, false, false, v.tooltip )
			xgui_modules.tab[k].tabpanel = xgui_base.Items[#xgui_base.Items].Tab
		end
	end
	if xgui_wasvisible then xgui_show() end
end

--If the player's group is changed, reprocess the XGUI modules for permissions
function xgui_PermissionsChanged( ply )
	if ply == LocalPlayer() then
		Msg( "Reprocessing XGUI modules- Player's permissions changed\n" )
		RunConsoleCommand( "xgui", "getdata" ) --Grab new server data
		xgui_processModules( xgui_base:IsVisible() )
	end
end

function xgui_isNotInstalled( tabname )
	xgui_wait = x_makeframepopup{ label="XGUI", w=235, h=50, nopopup=true, showclose=false }
	xgui_wait.tabname = tabname
	x_makelabel{ label="Waiting for server confimation... (5 seconds)", x=10, y=30, parent=xgui_wait }
	timer.Simple( 5, function( tabname )
		if xgui_isInstalled == nil then
			xgui_wait:Remove()
			xgui_wait = nil
			xgui_data.votemaps = ulx.maps
			gui.EnableScreenClicker( true )
			RestoreCursorPosition( )
			xgui_notinstalled = x_makeframepopup{ label="Warning!", w=350, h=90, nopopup=true, showclose=false }
			x_makelabel{ label="XGUI is not installed on this server! XGUI will now run in offline mode.", x=10, y=30, parent=xgui_notinstalled }
			x_makelabel{ label="Some features may not work, and information will be missing.", x=10, y=45, parent=xgui_notinstalled }
			x_makebutton{ x=155, y=63, w=40, label="OK", parent=xgui_notinstalled }.DoClick = function()
				xgui_notinstalled:Remove()
				xgui_show( tabname )
			end
		end
	end)
end

function xgui_show( tabname )
	--Check if XGUI is not installed, display the warning if hasn't been shown yet.
	if xgui_wait then return end
	if xgui_isInstalled == nil and xgui_notinstalled == nil then
		xgui_isNotInstalled( tabname ) 
		return
	end
	
	--Process modules if XGUI has no tabs!
	if #xgui_base.Items == 0 then xgui_processModules() end
	
	--Sets the active tab to tabname if it was specified
	if tabname then
		--In case the string name had spaces, it sent the whole argument table. Convert it to a string here!
		tabname = table.concat( tabname, " " )
		for _, v in ipairs( xgui_modules.tab ) do
			if string.lower( v.name ) == string.lower( tabname ) then
				xgui_base:SetActiveTab( v.tabpanel )
			end
		end
	end
	
	--Calls the functions requesting to hook when XGUI is opened
	if xgui_modules.hook["onOpen"] then
		for _, func in ipairs( xgui_modules.hook["onOpen"] ) do func() end
	end
	xgui_base:SetVisible( true )
	gui.EnableScreenClicker( true )
	RestoreCursorPosition( )
	
	if xgui_receivingdata then xgui_chunkbox:SetVisible( true ) end
end

function xgui_hide()
	RememberCursorPosition()
	gui.EnableScreenClicker( false )
	xgui_base:SetVisible( false )
	if xgui_receivingdata then xgui_chunkbox:SetVisible( false ) end
end

function xgui_toggle()
	if xgui_base and not xgui_base:IsVisible() then
		xgui_show()
	else
		xgui_hide()
	end
end

function xgui_SetKeyboard( panel )
	for _,obj in ipairs( xgui_base.Items ) do
		if ( obj.Tab == xgui_base:GetActiveTab() ) then
			xgui_textpanel = panel
			obj.Panel:SetKeyboardInputEnabled( true )
			hook.Add( "VGUIMousePressed", "XGUI_Checkmouse", xgui_CheckMousePos )
		end
	end
end

function xgui_CheckMousePos( panel, mcode )
	if mcode == MOUSE_LEFT then
		if ( panel ~= xgui_textpanel ) then
			xgui_ReleaseKeyboard()
		end
	end
end

function xgui_ReleaseKeyboard()
	for _,obj in ipairs(xgui_base.Items) do
		if ( obj.Tab == xgui_base:GetActiveTab() ) then
			obj.Panel:SetKeyboardInputEnabled( false )
			hook.Remove( "VGUIMousePressed", "XGUI_Checkmouse" )
		end
	end
end

--Called by server when data is ready to recieve
function xgui_expectChunks( numofchunks, updated )
	xgui_receivingdata = true
	xgui_chunkbox = x_makeframepopup{ label="XGUI is receiving data!", w=200, h=60, y=ScrH()/2-265, nopopup=true, draggable=false, showclose=false }
	xgui_chunkbox.max = numofchunks
	xgui_chunkbox.progress = x_makeprogressbar{ x=10, y=30, w=180, h=20, min=0, max=numofchunks, percent=true, parent=xgui_chunkbox }
	xgui_chunkbox.progress.Label:SetText( "Waiting for server" .. " - " .. xgui_chunkbox.progress.Label:GetValue() )
	xgui_chunkbox.progress:PerformLayout()
	xgui_chunkbox:SetVisible( xgui_base:IsVisible() )
	--Clear the tables that are going to be updated
	for _, v in ipairs( updated ) do
		xgui_data[v] = {}
		--Since bans are sent in chunks, this clears the bantable (since its refresh function won't clear it when it processes a chunk)
		if v == "bans" then 
			if xgui_banlist then xgui_banlist:Clear() end
		end
	end
	
	function xgui_chunkbox:Progress( curtable, count )
		self.progress:SetValue( count )
		self.progress.Label:SetText( curtable .. " - " .. self.progress.Label:GetValue() )
		self.progress:PerformLayout()
		if count == xgui_chunkbox.max then
			RunConsoleCommand( "xgui", "dataComplete" )
			xgui_receivingdata = false
			xgui_chunkbox:Remove()
			xgui_chunkbox = nil
		end
	end
end

--As long as we're not sending data, force a check on the server to see if there's more data to send.
function xgui_forceDataCheck()
	if not xgui_chunkbox then
		RunConsoleCommand( "xgui", "dataComplete" )
	end
end

function xgui_getInstalled()
	xgui_isInstalled = true
	if xgui_wait then
		local tab = xgui_wait.tabname
		xgui_wait:Remove()
		xgui_wait = nil
		xgui_show( tab )
	end
end

--Function called when data chunk is recieved from server
function xgui_getChunk( data, curtable, count )
	xgui_chunkbox:Progress( curtable, count )
	for k, v in pairs( data ) do
		if type(k) == "number" then
			table.insert( xgui_data[curtable], v )
		else
			xgui_data[curtable][k] = v
		end
	end
	xgui_callRefresh( curtable, data )
end

function xgui_callRefresh( cmd, data )
	--Run any functions that request to be called when "curtable" is updated
	---Since bans are split into chunks, send the chunktable for updating.
	if cmd == "bans" or cmd == "sbans" or cmd == "onUnban" then
		for _, func in ipairs( xgui_modules.hook[cmd] ) do func( data ) end
	else
		for _, func in ipairs( xgui_modules.hook[cmd] ) do func() end
	end
end

function xgui_cmd( ply, func, args )
	if args[1] == "show" then table.remove( args, 1 )  xgui_show( args )
	elseif args[1] == "hide" or args[1] == "close" then xgui_hide()
	elseif args[1] == nil or args[1] == "toggle" then xgui_toggle()
	else
		--Since the command arg passed isn't for a clientside function, we'll send it to the server
		if xgui_isInstalled then --First check that it's installed
			RunConsoleCommand( "_xgui", unpack( args ) )
		end
	end
end
concommand.Add( "xgui", xgui_cmd )