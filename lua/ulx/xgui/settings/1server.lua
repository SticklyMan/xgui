--Server settings module for ULX GUI -- by Stickly Man!
--Modify server and ULX based settings.

local server_settings = x_makeXpanel{ parent=xgui.null }

--------------------------GMOD Settings--------------------------
x_makecheckbox{ x=10, y=10, label="Enable Voice Chat", repconvar="rep_sv_voiceenable", parent=server_settings, textcolor=color_black }
x_makecheckbox{ x=10, y=30, label="Enable Alltalk", repconvar="rep_sv_alltalk", parent=server_settings, textcolor=color_black }
x_makecheckbox{ x=10, y=50, label="Disable AI", repconvar="rep_ai_disabled", parent=server_settings, textcolor=color_black }
x_makecheckbox{ x=10, y=70, label="AI Ignore Players", repconvar="rep_ai_ignoreplayers", parent=server_settings, textcolor=color_black }
local offset = 0
if SinglePlayer() then
	offset = 20
	x_makecheckbox{ x=10, y=90, label="Keep AI Ragdolls", repconvar="rep_ai_keepragdolls", parent=server_settings, textcolor=color_black }
end
x_makeslider{ x=10, y=90+offset, w=125, label="sv_gravity", min=-1000, max=1000, repconvar="rep_sv_gravity", parent=server_settings, textcolor=color_black }
x_makeslider{ x=10, y=130+offset, w=125, label="phys_timescale", min=0, max=4, decimal=2, repconvar="rep_phys_timescale", parent=server_settings, textcolor=color_black }

--------------------------Log Settings---------------------------
local plist = x_makepanellist{ w=285, h=327, parent=xgui.null }
plist:AddItem( x_makecheckbox{ label="Enable Logging to Files", repconvar="ulx_cl_logFile" } )
plist:AddItem( x_makecheckbox{ label="Log Chat", repconvar="ulx_cl_logChat", tooltip="Enable logging of Chat" } )
plist:AddItem( x_makecheckbox{ label="Log Player Events (Connects, Deaths, etc.)", repconvar="ulx_cl_logEvents" } )
plist:AddItem( x_makecheckbox{ label="Log Spawns (Props, Effects, Ragdolls, etc.)", repconvar="ulx_cl_logSpawns" } )
plist:AddItem( x_makelabel{ label="Save log files to this directory:" } )
local logdirbutton = x_makebutton{}
logdirbutton:SetText( GetConVar( "ulx_cl_logDir" ):GetString() )
function logdirbutton.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
	if cl_cvar == "ulx_cl_logDir" then
		logdirbutton:SetText( new_val )
	end
end
hook.Add( "ULibReplicatedCvarChanged", "XGUI_ulx_cl_logDir", logdirbutton.ConVarUpdated )
plist:AddItem( logdirbutton )
table.insert( xgui.modules.svsetting, { name="ULX Logs", panel=plist, access=nil } )

-------------------------Player Votemaps-------------------------
local plist = x_makepanellist{ w=285, h=327, parent=xgui.null }
plist:AddItem( x_makecheckbox{ label="Enable Player Votemaps", repconvar="ulx_cl_votemapEnabled" } )
plist:AddItem( x_makeslider{ label="Minimum time before any player can vote for a map.", min=0, max=300, repconvar="ulx_cl_votemapMintime" } )
plist:AddItem( x_makeslider{ label="Time a user must wait before they can change their vote.", min=0, max=60, decimal=1, repconvar="ulx_cl_votemapWaitTime" } )
plist:AddItem( x_makeslider{ label="Ratio of votes needed for mapchange to be successful.", min=0, max=1, decimal=2, repconvar="ulx_cl_votemapSuccessratio" } )
plist:AddItem( x_makeslider{ label="Minimum number of votes needed for mapchange to be successful.", min=0, max=10, repconvar="ulx_cl_votemapMinvotes" } )
plist:AddItem( x_makeslider{ label="Time in seconds an admin has to veto a successful vote. (0 to disable)", min=0, max=300, repconvar="ulx_cl_votemapVetotime" } )
table.insert( xgui.modules.svsetting, { name="ULX Player Votemaps", panel=plist, access=nil } )

-------------------------Admin Votemaps--------------------------
local plist = x_makepanellist{ w=285, h=327, parent=xgui.null }
plist:AddItem( x_makelabel{ label="Server-wide Votemap Settings" } )
plist:AddItem( x_makeslider{ label="Votemap2 Success Ratio", min=0, max=1, 	decimal=2, repconvar="ulx_cl_votemap2Successratio" } )
plist:AddItem( x_makeslider{ label="Votemap2 Minimum Votes", min=0, max=10, repconvar="ulx_cl_votemap2Minvotes" } )
table.insert( xgui.modules.svsetting, { name="ULX Admin Votemaps", panel=plist, access=nil } )

------------------------Votekick/Voteban-------------------------
local plist = x_makepanellist{ w=285, h=327, parent=xgui.null }
plist:AddItem( x_makeslider{ label="Votekick Success Ratio", min=0, max=1, decimal=2, repconvar="ulx_cl_votekickSuccessratio" } )
plist:AddItem( x_makeslider{ label="Votekick Minimum Votes", min=0, max=10, repconvar="ulx_cl_votekickMinvotes" } )
plist:AddItem( x_makeslider{ label="Voteban Success Ratio", min=0, max=1, decimal=2, repconvar="ulx_cl_votebanSuccessratio" } )
plist:AddItem( x_makeslider{ label="Voteban Minimum Votes", min=0, max=10, repconvar="ulx_cl_votebanMinvotes" } )
plist:AddItem( x_makecheckbox{ label="Echo Votes", repconvar="ulx_cl_voteEcho" } )
table.insert( xgui.modules.svsetting, { name="ULX Votekick/Voteban", panel=plist, access=nil } )

------------------------------Echo-------------------------------
local plist = x_makepanellist{ w=285, h=327, parent=xgui.null }
plist:AddItem( x_makemultichoice{ repconvar="ulx_cl_logEcho", isNumberConvar=true, choices={ "Echo Admin Commands Disabled", "Echo Admin Commands Anonymously", "Echo Admin Commands" } } )
plist:AddItem( x_makemultichoice{ repconvar="ulx_cl_logSpawnsEcho", isNumberConvar=true, choices={ "Echo Spawns Disabled", "Echo Spawns to Admins", "Echo Spawns to Everyone" } } )
table.insert( xgui.modules.svsetting, { name="ULX Log Echo", panel=plist, access=nil } )

------------------------ULX Category Menu------------------------
server_settings.curPanel = nil
server_settings.panel = x_makepanel{ x=300, y=5, w=285, h=327, parent=server_settings }

server_settings.catList = x_makelistview{ x=145, y=5, w=150, h=327, parent=server_settings }
server_settings.catList:AddColumn( "Server Settings" )
server_settings.catList.Columns[1].DoClick = function() end
server_settings.catList.OnRowSelected=function()
	local nPanel = xgui.modules.svsetting[server_settings.catList:GetSelected()[1]:GetValue(2)].panel
	if nPanel ~= server_settings.curPanel then
		if server_settings.panel.slideAnim:Active() then
			server_settings.panel.slideAnim:Stop()
		end
		server_settings.panel.slideAnim:Start( xgui.base:GetFadeTime(), { NewPanel = nPanel, OldPanel = server_settings.curPanel } )
		server_settings.curPanel = nPanel
	end
end
--Frame animations!
function server_settings.panel:slideFunc( anim, delta, data )
		if ( anim.Started ) then
			data.NewPanel:SetPos( -295, 0 )
			data.NewPanel:SetVisible( true )
			data.NewPanel:SetZPos( 255 )
			if data.OldPanel then data.OldPanel:SetZPos( 0 ) end
		end
		if ( anim.Finished ) then
			data.NewPanel:SetPos( 0, 0 )
			if data.OldPanel then 
				data.OldPanel:SetVisible( false )
			end
		end
		
		if data.OldPanel then data.OldPanel:SetPos( 0, 327*math.sin( delta*math.pi/2 ) ) end
		data.NewPanel:SetPos( -295 + (295*math.sin( delta*math.pi/2 )), 0 )
end
server_settings.panel.slideAnim = Derma_Anim( "Fade", server_settings.panel, server_settings.panel.slideFunc )
function server_settings.panel:Think()
		self.slideAnim:Run()
end
--Process modular settings
function server_settings.processModules()
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
--table.insert( xgui.hook["adverts"], server_settings.updateAdverts )
--table.insert( xgui.hook["gimps"], server_settings.updateGimps )