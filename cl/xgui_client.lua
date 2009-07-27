--GUI for ULX -- by Stickly Man!

--Table storing the functions to show modules
xgui_modules={}

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
	
	for k, ShowModule in pairs( xgui_modules ) do
		ShowModule()
	end
	
	if xgui_lasttab then
		xgui_base:SetActiveTab( xgui_base.Items[xgui_lasttab]["Tab"] )
	end 
end


function xgui_hide()
		--Easiest way to find the index of the active tab, since just using GetActiveTab causes strange problems
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

concommand.Add( "xgui_show", xgui_show )
concommand.Add( "xgui_hide", xgui_hide )
concommand.Add( "+xgui", xgui_show )
concommand.Add( "-xgui", xgui_hide )
concommand.Add( "xgui_toggle", xgui_toggle )