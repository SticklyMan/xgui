--Addons tab for ULX GUI -- by Stickly Man!
--Allows ULX modules to add their own controls to the GUI

xgui_addon_list = {}

function xgui_tab_addons()
	xgui_addons = vgui.Create( "DPanel" )
------------
	xgui_addon_panel = x_makepanel{ x=10, y=30, w=570, h=330, parent=xgui_addons }
	xgui_addon_select = x_makemultichoice{ x=10, y=10, w=150, h=20, parent=xgui_addons, text="Select an Addon..." }
	xgui_addon_label = x_makelabel{ label="", x=170, y=13, parent=xgui_addons, textcolor=Color( 0, 0, 0, 255 ) }
	
	function xgui_addon_select:OnSelect(index,value,data)
		xgui_addon_panel:Remove()
		xgui_addon_panel = x_makepanel{ x=10, y=30, w=570, h=330, parent=xgui_addons }
		xgui_addon_list[value].func( xgui_addon_panel )
		xgui_addon_label:SetText( "By: " .. xgui_addon_list[value].author .. " | " .. xgui_addon_list[value].version .. " | " .. xgui_addon_list[value].description )
		xgui_addon_label:SizeToContents()
	end
		
	for k, _ in pairs( xgui_addon_list ) do
		xgui_addon_select:AddChoice( k )
	end
	
	xgui_base:AddSheet( "Addons", xgui_addons, "gui/silkicons/plugin", false, false )
end

xgui_modules[5]=xgui_tab_addons


--Call this function in your addon to integrate it with XGUI!
function xgui_add_addon( t )
	xgui_addon_list[t.name] = { func=t.func, author=t.author, version=t.version, description=t.description }
end

--Waits a bit, then requests 
timer.Simple( FrameTime() * 0.5, hook.Call, "xgui_addon" )