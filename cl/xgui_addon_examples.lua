--Here is the base for the code needed to integrate your gui with ULX
--Function 1 is the function in which all your gui controls are created. Please note that your GUI controls must be parented to 'parent'
local function function1( parent )
	--Using xgui_helpers, this will make a simple label parented to the xgui menu.
	--Also note that you have a 570x330 area to work with
	x_makelabel{ label="I am an Addon!", textcolor=Color( 0, 0, 0, 255 ), parent=parent }
end
--Function 2 is the function called by the hook. The hook is called by XGUI when all the addons are loaded, to prevent some addons being loaded before xgui is created, etc.
local function function2()
	--This is the main function to send your function containing GUI controls to XGUI, along with some other relavent information.
	xgui_add_addon{ func=function1, name="Addon_Name", author="Author", version="Version", description="Description" }
end
hook.Add( "xgui_addon", "xgui_addon_test", function2 )


--Here is another example:
local function my_cool_addon( parent )
	--You may make your Derma and VGUI controls as you wish, you don't have to use the xgui_helper functions (so you don't have to recode your entire GUI)
	local mca_blah = x_makepanelist{ x=10, y=10, w=200, h=100, parent=parent }
	mca_blah:AddItem( x_makeslider{ max=100, label="The slider of DOOM!", decimal=2 } )
	mca_blah:AddItem( x_makecheckbox{ label="Save the whales?" } )
	x_makecolorpicker{ x=250, y=20, w=200, h=200, parent=parent }
	x_makebutton{ x=170, y=150, w=100, h=20, label="Recieve Bacon", parent=parent }
end

local function my_cool_addon_XGUI()
	xgui_add_addon{ func=my_cool_addon, name="My Cool Addon!", author="Stickly Man!", version="0.9", description="A whole lotta nothing, really..." }
end
hook.Add( "xgui_addon", "my_cool_addon_show", my_cool_addon_XGUI )