--GUI for ULX -- by Stickly Man!
ULib.queueFunctionCall( function()
	 
	--Data storing relevant information retrieved from server.
	xgui_data = {}
	xgui_hasLoaded = false

	--Used to set which panel has the keyboard focus
	xgui_textpanel=nil

	--Call for server data
	RunConsoleCommand( "xgui", "getdata" )

	--Initiate the base window
	xgui_base = vgui.Create( "DPropertySheet" )
	xgui_base:SetVisible( false )
	xgui_base:SetPos( ScrW()/2 - 300, ScrH()/2 - 200 )
	xgui_base:SetSize( 600, 400 )
	xgui_base:SetMouseInputEnabled( true )

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

	--Overrides the tabs click command to realign the panel onto the window when clicked.. DPanels DO NOT like being MakePopup()'d
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
end )

function xgui_show()
	--Makes sure XGUI is initialized fully...
	if xgui_hasLoaded == true then
		--Positions the initial panel back onto the frame (Curse you MakePopup()!!!)
		--Also calls the refresh function on each module.
		for _,obj in ipairs(xgui_base.Items) do
			obj.Panel:XGUI_Refresh()
			if obj.Tab == xgui_base:GetActiveTab() then
				ULib.queueFunctionCall( obj.Panel.SetPos, obj.Panel, ScrW()/2 - 295, ScrH()/2 - 173 )
			end
		end
		
		gui.EnableScreenClicker( true )
		RestoreCursorPosition( )
		xgui_base:SetVisible( true )
	else
		--...Otherwise show a nice little messagebox telling the user to wait a bit.
		if not xgui_waitbox then
			xgui_waitbox = x_makeframepopup{ label="XGUI is receiving data!", w=200, h=60, nopopup=true, showclose=false }
			x_makelabel{ label="Please wait a moment...", x=10, y=30, parent=xgui_waitbox }
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
	if not xgui_base:IsVisible() && xgui_waitbox == nil then
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
		RunConsoleCommand( "_xgui", unpack( args ) )
	end
end
concommand.Add( "xgui", xgui_cmd )