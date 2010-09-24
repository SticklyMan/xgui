--Server settings module for ULX GUI -- by Stickly Man!
--Modify server and ULX based settings.

local server_settings = xlib.makeXpanel{ parent=xgui.null }

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
		if server_settings.panel.slideAnim:Active() then
			server_settings.panel.slideAnim.Finished = true
			server_settings.panel.slideAnim:Run() --Give it a chance to process the finished code
		end
		server_settings.panel.slideAnim:Start( xgui.base:GetFadeTime(), { NewPanel = nPanel, OldPanel = server_settings.curPanel } )
		server_settings.curPanel = nPanel
	end
	if nPanel.onOpen then nPanel.onOpen() end --If the panel has it, call a function when it's opened
end
--Frame animations!
function server_settings.panel:slideFunc( anim, delta, data )
		if ( anim.Started ) then
			data.NewPanel:SetPos( -295, 0 )
			data.NewPanel:SetVisible( true )
			data.NewPanel:SetZPos( 255 )
			if data.OldPanel then data.OldPanel:SetZPos( 0 ) end
			if data.NewPanel.OnOpened then data.NewPanel.OnOpened() end
		end
		
		if data.OldPanel then data.OldPanel:SetPos( 0, 327*math.sin( delta*math.pi/2 ) ) end
		data.NewPanel:SetPos( -295 + (295*math.sin( delta*math.pi/2 )), 0 )
		
		if ( anim.Finished ) then
			data.NewPanel:SetPos( 0, 0 )
			if data.OldPanel then 
				data.OldPanel:SetVisible( false )
			end
		end
end
server_settings.panel.slideAnim = Derma_Anim( "Fade", server_settings.panel, server_settings.panel.slideFunc )
server_settings.panel.slideAnim.Start = x_anim_Start
function server_settings.panel:Think()
		self.slideAnim:Run()
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