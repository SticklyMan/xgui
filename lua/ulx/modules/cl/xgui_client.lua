--GUI for ULX -- by Stickly Man!

local function xgui_init()
	--Data storing relevant information retrieved from server.
	xgui_data = { bans = {}, users = {}, adverts = {}, gimps = {}, maps = {}, votemaps = {}, gamemodes = {} }
	xgui_hasLoaded = false
	xgui_doModules = true
	
	--Set up a table for storing third party modules
	xgui_modules = { tab = {} }
	
	--Used to set which panel has the keyboard focus
	xgui_textpanel=nil

	--Call for server data
	RunConsoleCommand( "xgui", "getdata" )
	
	--Initiate the base window
	xgui_base = vgui.Create( "DPropertySheet" )
	xgui_base:SetVisible( false )
	xgui_base:SetPos( ScrW()/2 - 300, ScrH()/2 - 200 )
	xgui_base:SetSize( 600, 400 )
	
	--Create an offscreen place to parent modules that the player can't access
	xgui_null = vgui.Create( "DPanel" )
	xgui_null:SetPos( -10, -10 )
	xgui_null:SetVisible( false )
	xgui_null:SetSize( 0, 0 )
	
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

function xgui_processModules()
	xgui_base:SetMouseInputEnabled( true )
	for _, v in pairs( xgui_modules.tab ) do
		if v.xbutton == nil then
			v.xbutton = x_makesysbutton{ x=565, y=5, w=20, btype="close", parent=v.panel }
			v.xbutton.DoClick = function()
				xgui_hide()
			end
		end
		if v.access ~= nil then
			if LocalPlayer():query( v.access ) then
				xgui_base:AddSheet( v.name, v.panel, v.icon, false, false, v.tooltip )
			else
				v.panel:SetParent( xgui_null )
			end
		else
			xgui_base:AddSheet( v.name, v.panel, v.icon, false, false, v.tooltip )
		end
	end
	
	--Overrides the tabs' click command to realign the panel onto the window when clicked.. DPanels DO NOT like being MakePopup()'d
	for _, v in pairs( xgui_base.Items ) do
		v.Tab.OnMousePressed = function( self, mcode )
			self:GetPropertySheet():SetActiveTab( self )
			for _, v in pairs( xgui_base.Items ) do
				if ( v.Tab == self ) then
					ULib.queueFunctionCall( v.Panel.SetPos, v.Panel, ScrW()/2 - 295, ScrH()/2 - 173 )
				end
			end
		end
	end
end

--If the player's group is changed, reprocess the XGUI modules for permissions
function xgui_PermissionsChanged( ply )
	if ply == LocalPlayer() then
		Msg( "Reprocessing XGUI modules- Player's permissions changed\n" )
		xgui_data = { bans = {}, users = {}, adverts = {}, gimps = {}, maps = {}, votemaps = {}, gamemodes = {} } --Clear the local server data
		RunConsoleCommand( "xgui", "getdata" ) --Grab new server data
		if xgui_base:IsVisible() then --If XGUI was opened, show the data recieving screen
			xgui_hide()
			if xgui_isInstalled then  --We don't want to prevent XGUI from opening while in offline mode.
				xgui_hasLoaded = false
			end
			xgui_show()
		end
		xgui_base:Clear() --We need to remove the tabs in the GUI
		xgui_processModules()
	end
end

--Load control interpretations for Ulib argument types
function ULib.cmds.BaseArg.x_getcontrol( arg )
	return x_makelabel{ label="Not Supported", color=Color( 255,255,255,255 ) }
end

function ULib.cmds.NumArg.x_getcontrol( arg )
	return x_makeslider{ min=arg.min, max=arg.max, value=arg.default, label=arg.hint or "NumArg" }
end

function ULib.cmds.StringArg.x_getcontrol( arg )
	if arg.completes == nil then
		return x_maketextbox{ text=arg.hint or "StringArg", focuscontrol=true }
	else
		xgui_temp = x_makemultichoice{ text=arg.hint or "StringArg" }
		for _, v in ipairs( arg.completes ) do
			xgui_temp:AddChoice( v )
		end
		return xgui_temp
	end
end

function ULib.cmds.PlayerArg.x_getcontrol( arg )
	xgui_temp = x_makemultichoice{}
	for k, v in pairs( player.GetAll() ) do
		xgui_temp:AddChoice( v:Nick() )
	end
	return xgui_temp
end

function ULib.cmds.CallingPlayerArg.x_getcontrol( arg )
	return x_makelabel{ label=arg.hint or "CallingPlayer" }
end

function ULib.cmds.BoolArg.x_getcontrol( arg )
	return x_makecheckbox{ label=arg.hint or "BoolArg" }
end

function xgui_isNotInstalled()
	--First, determine if the check variable hasn't been set from the server
	if xgui_isInstalled == nil then
		if xgui_waitbox then xgui_waitbox:Remove() end
		xgui_data.votemaps = ulx.maps
		gui.EnableScreenClicker( true )
		RestoreCursorPosition( )
		xgui_notinstalled = x_makeframepopup{ label="Warning!", w=350, h=90, nopopup=true, showclose=false }
		x_makelabel{ label="XGUI is not installed on this server! XGUI will now run in offline mode.", x=10, y=30, parent=xgui_notinstalled }
		x_makelabel{ label="Some features may not work, and information will be missing.", x=10, y=45, parent=xgui_notinstalled }
		x_makebutton{ x=155, y=60, w=40, label="OK", parent=xgui_notinstalled }.DoClick = function()
			xgui_hasLoaded = true
			xgui_temptimer = nil
			xgui_show()
			xgui_notinstalled:Remove()
			xgui_notinstalled = nil
		end
	end
end

function xgui_show()
	--Makes sure XGUI is initialized fully...
	if xgui_hasLoaded == true then
		--If the modules haven't been processed yet, process them.
		if xgui_doModules then
			xgui_processModules()
			xgui_doModules = nil
		end
		--Positions the initial panel back onto the frame (Curse you MakePopup()!!!)
		--Also calls the refresh function on each module.
		for _,obj in ipairs(xgui_base.Items) do
			obj.Panel:XGUI_Refresh()
			if obj.Tab == xgui_base:GetActiveTab() then
				ULib.queueFunctionCall( function() xgui_base:SetVisible( true ) end )
				ULib.queueFunctionCall( obj.Panel.SetPos, obj.Panel, ScrW()/2 - 295, ScrH()/2 - 173 )
			end
		end
		gui.EnableScreenClicker( true )
		RestoreCursorPosition( )
	else
		--...Otherwise show a nice little messagebox telling the user to wait a bit.
		if not xgui_waitbox and not xgui_notinstalled then
			xgui_waitbox = x_makeframepopup{ label="XGUI is receiving data!", w=200, h=60, nopopup=true, showclose=false }
			x_makelabel{ label="Please wait a moment...", x=10, y=30, parent=xgui_waitbox }
			
			--Create a 5 second timer to test if the server has XGUI
			if xgui_temptimer == nil and xgui_isInstalled == nil then
				xgui_temptimer = timer.Simple( 5, xgui_isNotInstalled )
			end
		end
	end
end

function xgui_hide()
	RememberCursorPosition()
	gui.EnableScreenClicker( false )
	xgui_base:SetVisible( false )
	if xgui_waitbox then 
		xgui_waitbox:Remove()
		xgui_waitbox = nil
	end
end

function xgui_toggle()
	if xgui_notinstalled then return end
	if xgui_base == nil then  --Offline mode, or something went horribly wrong.
		xgui_show()
		return
	end
	if not xgui_base:IsVisible() and xgui_waitbox == nil then
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

--Function called when data is recieved from server
function xgui_RecieveData( data_in )
	for k, v in pairs( data_in ) do
		xgui_data[k] = v
	end
	xgui_hasLoaded = true
	if xgui_waitbox then
		xgui_show()
		xgui_waitbox:Remove()
		xgui_waitbox = nil
	end
end

function xgui_cmd( ply, func, args )
	if args[1] == "show" then xgui_show()
	elseif args[1] == "hide" or args[1] == "close" then xgui_hide()
	elseif args[1] == nil or args[1] == "toggle" then xgui_toggle()
	else
		--Since the command arg passed isn't for a clientside function, we'll send it to the server
		if xgui_isInstalled ~= nil or xgui_hasLoaded == false then  --First check and make sure we're not in offline mode or if XGUI hasn't been initialized.
			RunConsoleCommand( "_xgui", unpack( args ) )
		end
	end
end
concommand.Add( "xgui", xgui_cmd )