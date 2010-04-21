--TODO: THIS EXAMPLE IS OUTDATED SINCE LATEST DATA TRANSFER CHANGES!!

--Here are some examples on how to add modules and stuff to XGUI!

--Your lua file should be placed in the gui_modules folder (or replicated folderpath)
--Don't start your filename with a number (please?), that's used to set the order of the default tabs.
--Any added tabs will be in alphabetical order.

--------------
--Module Tab--
--------------

--Step 1: Create a panel (or Xpanel if you want to use TextEntries!), and set it's parent to xgui_null. It will parent itself to xgui_base later (unless something goes horribly wrong)
module_tab = x_makeXpanel{ parent=xgui_null }

--Step 2: Create your controls, functions, and Derma stuff, making sure to parent it to your panel  
--You don't have to use the x_makestuff from the xgui_helpers if you don't want to.. They're just a lot easier and cleaner!
local addon_listostuff = x_makepanellist{ x=10, y=10, w=200, h=100, parent=module_tab }
addon_listostuff:AddItem( x_makeslider{ max=666, label="The slider of DOOM!", decimal=2 } )
addon_listostuff:AddItem( x_makecheckbox{ label="Save the whales?" } )
x_makecolorpicker{ x=250, y=20, w=200, h=200, parent=module_tab }
x_makebutton{ x=170, y=150, w=100, h=20, label="Refresh", parent=module_tab }.DoClick = function()
	module_tab.XGUI_Refresh()
end
local addon_playerlist = x_makecombobox{ x=10, y=150, w=100, h=200, parent=module_tab }
--If you're using an Xpanel, Be sure to set focuscontrol to true to allow XGUI to handle keyboard focus of your textbox!!
x_maketextbox{ x=200, y=200, w=125, parent=module_tab, text="This is a textbox.", focuscontrol=true }.OnEnter = function( self )
	Derma_Message( "You typed \"" .. self:GetValue() .. "\".", "LOOKOUT!" )
end

--Step 3: Make a Refresh function to update controls and data that will be called every time XGUI is opened, (Or when you call/hook it-- see the button in the code above)
--THIS FUNCTION SHOULD EXIST EVEN IF YOU DON'T PUT ANYTHING IN IT!
--IT MUST HAVE THE SAME NAMESPACE AS YOUR PANEL, AND MUST BE NAMED XGUI_REFRESH.
module_tab.XGUI_Refresh = function()
	addon_playerlist:Clear()
	for _, v in pairs( player.GetAll() ) do
		addon_playerlist:AddItem( v:Nick() )
	end
	addon_playerlist:AddItem( "The Slider is at.." )
	addon_playerlist:AddItem( addon_listostuff:GetItems()[1]:GetValue() )
end

--Step 4: Insert your module into the XGUI module table and set the Title, Panel with your controls, Icon, and optional Tooltip and access string required to view the module.
table.insert( xgui_modules.tab, { name="Test Module", panel=module_tab, icon="gui/silkicons/group", tooltip=nil, access=nil } )

---------------------
--Useful references--
---------------------
--[[
You can look up the following ULX data (If the user has permission)

xgui_data.gamemodes	- A list of gamemodes installed on the server
xgui_data.votemaps	- A list of votemaps (also the only maps visible to non-admins via maps menu)
xgui_data.maps		- A list of every map on the server (Must have access to ulx map or access to enable/disable votemaps (ulx_cl_votemapEnabled))
xgui_data.gimps		- A list of gimpsays (Must have access to xgui_ulxsettings)
xgui_data.adverts	- A list of adverts and data (Must have access to xgui_ulxsettings)
xgui_data.users		- A list of all users in groups by STEAMID, along with any restrictions (Must have access to xgui_managegroups)
xgui_data.bans		- A list of bans and information (Must have access to xgui_managebans

If needed, you can resend server data to the client by RunConsoleCommand( "xgui", "getdata", ... ) where ... is the categories you would like to update (leaving it blank updates everything)
e.g: RunConsoleCommand( "xgui", "getdata", "votemaps", "gamemodes" )
]]--