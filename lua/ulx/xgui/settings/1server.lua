--Server settings module for ULX GUI -- by Stickly Man!
--Modify server and ULX based settings.

local server_settings = x_makeXpanel{ parent=xgui.null }

--------------------------GMOD Settings--------------------------
x_makecheckbox{ x=10, y=10, label="Enable Voice Chat", convar="rep_sv_voiceenable", parent=server_settings, textcolor=color_black }
x_makecheckbox{ x=10, y=30, label="Enable Alltalk", convar="rep_sv_alltalk", parent=server_settings, textcolor=color_black }
x_makecheckbox{ x=10, y=50, label="Disable AI", convar="rep_ai_disabled", parent=server_settings, textcolor=color_black }
x_makecheckbox{ x=10, y=70, label="AI Ignore Players", convar="rep_ai_ignoreplayers", parent=server_settings, textcolor=color_black }
local offset = 0
if SinglePlayer() then
	offset = 20
	x_makecheckbox{ x=10, y=90, label="Keep AI Ragdolls", convar="rep_ai_keepragdolls", parent=server_settings, textcolor=color_black }
end
x_makeslider{ x=10, y=90+offset, w=125, label="sv_gravity", min=-1000, max=1000, convar="rep_sv_gravity", parent=server_settings, textcolor=color_black }
x_makeslider{ x=10, y=130+offset, w=125, label="phys_timescale", min=0, max=4, decimal=2, convar="rep_phys_timescale", parent=server_settings, textcolor=color_black }

------------------------ULX Category Menu------------------------
server_settings.categories = {}
server_settings.curPanel = nil
server_settings.panel = x_makepanel{ x=300, y=5, w=285, h=327, parent=server_settings }

server_settings.catList = x_makelistview{ x=145, y=5, w=150, h=327, parent=server_settings }
server_settings.catList:AddColumn( "ULX Settings" )
server_settings.catList.OnRowSelected=function()
	local nPanel = server_settings.categories[server_settings.catList:GetSelected()[1]:GetValue(2)]
	server_settings.panel.slideAnim:Start( xgui.base:GetFadeTime(), { NewPanel = nPanel, OldPanel = server_settings.curPanel } )
end
--Frame animations!
function server_settings.panel:slideFunc( anim, delta, data )
		if ( anim.Started ) then
			data.NewPanel:SetPos( -295, 0 )
			data.NewPanel:SetVisible( true )
		end
		if ( anim.Finished ) then
			data.NewPanel:SetPos( 0, 0 )
			server_settings.curPanel = data.NewPanel
		end
		if data.OldPanel then 
			if ( anim.Finished ) then
				data.OldPanel:SetVisible( false )
			end
			local ox, oy = data.OldPanel:GetPos()
			data.OldPanel:SetPos( ox, 327*math.sin( delta*math.pi/2 ) )
		end

		local nx, ny = data.NewPanel:GetPos()
		data.NewPanel:SetPos( -295 + (295*math.sin( delta*math.pi/2 )), ny )
end
server_settings.panel.slideAnim = Derma_Anim( "Fade", server_settings.panel, server_settings.panel.slideFunc )
function server_settings.panel:Think()
		self.slideAnim:Run()
end

--------------------------Log Settings---------------------------
local plist = x_makepanellist{ w=285, h=327, parent=server_settings.panel }
plist:AddItem( x_makecheckbox{ label="Enable Logging", convar="ulx_cl_logFile", tooltip="Enable logging of ULX actions to a file" } )
plist:AddItem( x_makecheckbox{ label="Log Chat", convar="ulx_cl_logChat", tooltip="Enable logging of Chat" } )
plist:AddItem( x_makecheckbox{ label="Log Player Events", convar="ulx_cl_logEvents", tooltip="Enable logging of player connects, disconnects, deaths, etc" } )
plist:AddItem( x_makecheckbox{ label="Log Spawns", convar="ulx_cl_logSpawns", tooltip="Enable logging of spawns of props, effects, etc" } )
plist:SetVisible( false )
server_settings.catList:AddLine( "Logs", table.insert( server_settings.categories, plist ) )

local plist = x_makepanellist{ w=285, h=327, parent=server_settings.panel }
plist:AddItem( x_makeslider{ label="Votekick Success Ratio", min=0, max=1, decimal=2, convar="ulx_cl_votekickSuccessratio" } )
plist:AddItem( x_makeslider{ label="Votekick Minimum Votes", min=0, max=10, convar="ulx_cl_votekickMinvotes" } )
plist:AddItem( x_makeslider{ label="Voteban Success Ratio", min=0, max=1, decimal=2, convar="ulx_cl_votebanSuccessratio" } )
plist:AddItem( x_makeslider{ label="Voteban Minimum Votes", min=0, max=10, convar="ulx_cl_votebanMinvotes" } )
plist:AddItem( x_makecheckbox{ label="Echo Votes", convar="ulx_cl_voteEcho" } )
plist:AddItem( x_makecheckbox{ label="Enable Player Votemaps", convar="ulx_cl_votemapEnabled" } )
plist:AddItem( x_makeslider{ label="Votemap Minimum Time", 	min=0, max=300,convar="ulx_cl_votemapMintime" } )
plist:AddItem( x_makeslider{ label="Votemap Wait Time", 	min=0, max=60, 	decimal=1, convar="ulx_cl_votemapWaitTime" } )
plist:AddItem( x_makeslider{ label="Votemap Success Ratio", min=0, max=1, 	decimal=2, convar="ulx_cl_votemapSuccessratio" } )
plist:AddItem( x_makeslider{ label="Votemap Minimum Votes", min=0, max=10, convar="ulx_cl_votemapMinvotes" } )
plist:AddItem( x_makeslider{ label="Votemap Veto Time",		min=0, max=300, convar="ulx_cl_votemapVetotime" } )
plist:AddItem( x_makelabel{ label="Server-wide Votemap Settings" } )
plist:AddItem( x_makeslider{ label="Votemap2 Success Ratio", min=0, max=1, 	decimal=2, convar="ulx_cl_votemap2Successratio" } )
plist:AddItem( x_makeslider{ label="Votemap2 Minimum Votes", min=0, max=10, convar="ulx_cl_votemap2Minvotes" } )
plist:SetVisible( false )
server_settings.catList:AddLine( "Votesettings", table.insert( server_settings.categories, plist ) )

table.insert( xgui.modules.setting, { name="Server", panel=server_settings, icon="gui/silkicons/application", tooltip=nil, access="xgui_svsettings" } )
--table.insert( xgui.hook["adverts"], server_settings.updateAdverts )
--table.insert( xgui.hook["gimps"], server_settings.updateGimps )