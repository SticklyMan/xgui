--GUI for ULX -- by Stickly Man!

--Table storing the functions to show modules
xgui_modules={}

--Used to set which panel has the keyboard focus
xgui_textpanel=nil

--Creates instance to avoid returning nil problems later
xgui_base = vgui.Create( "DPropertySheet" )
xgui_base:Remove()

--Includes the helpful Derma functions!
include ( "ulx/modules/cl/xgui_helpers.lua" )

Msg( "\n///////////////////////////////////////\n" )
Msg( "//  ULX GUI -- Made by Stickly Man!  //\n" )
Msg( "///////////////////////////////////////\n" )
Msg( "//  Loading/Initializing modules...  //\n" )

local xgui_module_files = file.FindInLua( "ulx/modules/cl/gui_modules/*.lua" )

for _, file in ipairs( xgui_module_files ) do
	include( "ulx/modules/cl/gui_modules/" .. file )
	Msg( "//  Added module: " .. file .. string.rep( " ", 19 - file:len() ) .. "//\n" )
end

Msg( "//  Modules Loaded!                  //\n" )
Msg( "///////////////////////////////////////\n\n" )

function xgui_show()

	gui.EnableScreenClicker( true )
	RestoreCursorPosition( )
	xgui_base = vgui.Create( "DPropertySheet" )
	xgui_base:SetPos( ScrW()/2 - 300, ScrH()/2 - 200 )
	xgui_base:SetSize( 600, 400 )
	xgui_base:SetMouseInputEnabled( true )
	for k, ShowModule in pairs( xgui_modules ) do
		ShowModule()
	end
	
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
		
	if xgui_lasttab then
		xgui_base:SetActiveTab( xgui_base.Items[xgui_lasttab]["Tab"] )
	end
	
	for _,obj in ipairs(xgui_base.Items) do
		if obj.Tab == xgui_base:GetActiveTab() then
			ULib.queueFunctionCall( obj.Panel.SetPos, obj.Panel, ScrW()/2 - 295, ScrH()/2 - 173 )
		end
	end

end


function xgui_hide()
		--Easiest way to find the index of the active tab
		for x,obj in ipairs(xgui_base.Items) do
			if obj.Tab == xgui_base:GetActiveTab() then
				xgui_lasttab = x
			end
		end
		
		RememberCursorPosition()
		gui.EnableScreenClicker( false )
		xgui_base:Remove()
end

function xgui_toggle()
	if !xgui_base:IsVisible() then
		xgui_show()
	else
		xgui_hide()
	end
end

function xgui_refresh()
	xgui_hide()
	xgui_show()
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

concommand.Add( "xgui_show", xgui_show )
concommand.Add( "xgui_hide", xgui_hide )
concommand.Add( "+xgui", xgui_show )
concommand.Add( "-xgui", xgui_hide )
concommand.Add( "xgui_toggle", xgui_toggle )