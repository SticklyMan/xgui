--Server settings module for ULX GUI -- by Stickly Man!
--A settings module for modifying server and ULX based settings. Also has the base code for loading the server settings modules.

local server_settings = xlib.makepanel{ parent=xgui.null }

--------------------------GMOD Settings--------------------------
xlib.makecheckbox{ x=10, y=10, label="Enable Voice Chat", repconvar="rep_sv_voiceenable", parent=server_settings, textcolor=color_black }
xlib.makecheckbox{ x=10, y=30, label="Enable Alltalk", repconvar="rep_sv_alltalk", parent=server_settings, textcolor=color_black }
xlib.makecheckbox{ x=10, y=50, label="Disable AI", repconvar="rep_ai_disabled", parent=server_settings, textcolor=color_black }
xlib.makecheckbox{ x=10, y=70, label="AI Ignore Players", repconvar="rep_ai_ignoreplayers", parent=server_settings, textcolor=color_black }
local offset = 0
if SinglePlayer() then
	offset = 20
	xlib.makecheckbox{ x=10, y=90, label="Keep AI Ragdolls", repconvar="rep_ai_keepragdolls", parent=server_settings, textcolor=color_black }
end
xlib.makeslider{ x=10, y=90+offset, w=125, label="sv_gravity", min=-1000, max=1000, repconvar="rep_sv_gravity", parent=server_settings, textcolor=color_black }
xlib.makeslider{ x=10, y=130+offset, w=125, label="phys_timescale", min=0, max=4, decimal=2, repconvar="rep_phys_timescale", parent=server_settings, textcolor=color_black }

------------------------ULX Category Menu------------------------
server_settings.panel = xlib.makepanel{ x=300, y=5, w=285, h=327, parent=server_settings }

server_settings.catList = xlib.makelistview{ x=145, y=5, w=150, h=327, parent=server_settings }
server_settings.catList:AddColumn( "Server Settings" )
server_settings.catList.Columns[1].DoClick = function() end
server_settings.catList.OnRowSelected=function()
	local nPanel = xgui.modules.svsetting[server_settings.catList:GetSelected()[1]:GetValue(2)].panel
	if nPanel ~= server_settings.curPanel then
		nPanel:SetZPos( 0 )
		xlib.addToAnimQueue( "pnlSlide", { panel=nPanel, startx=-295, starty=0, endx=0, endy=0, setvisible=true } )
		if server_settings.curPanel then
			server_settings.curPanel:SetZPos( -1 )
			xlib.addToAnimQueue( ULib.queueFunctionCall, server_settings.curPanel.SetVisible, server_settings.curPanel, false )
		end
		if nPanel.afterOpened then xlib.addToAnimQueue( nPanel.afterOpened ) end
		xlib.animQueue_start()
		server_settings.curPanel = nPanel
	end
	if nPanel.onOpen then nPanel.onOpen() end --If the panel has it, call a function when it's opened
end

--Process modular settings (Mostly loaded from sv_ulx.lua)
function server_settings.processModules()
	server_settings.curPanel = nil
	server_settings.catList:Clear()
	for i, module in ipairs( xgui.modules.svsetting ) do
		if not module.access then
			module.panel:SetParent( server_settings.panel )
			module.panel:SetVisible( false )
			server_settings.catList:AddLine( module.name, i )
		elseif LocalPlayer():query( module.access ) then
			module.panel:SetParent( server_settings.panel )
			module.panel:SetVisible( false )
			server_settings.catList:AddLine( module.name, i )
		end
	end
	server_settings.catList:SortByColumn( 1, false )
end
server_settings.processModules()

table.insert( xgui.modules.setting, { name="Server", panel=server_settings, icon="gui/silkicons/application", tooltip=nil, access="xgui_svsettings" } )
table.insert( xgui.hook["onProcessModules"], server_settings.processModules )