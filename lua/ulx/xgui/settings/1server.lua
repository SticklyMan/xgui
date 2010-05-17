--Server settings module for ULX GUI -- by Stickly Man!
--Modify server and ULX based settings.

local server_settings = x_makeXpanel{ parent=xgui.null }

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
x_maketextbox{ x=10, y=170+offset, w=125, parent=xgui_player, text="Change Password...", focuscontrol=true, parent=server_settings }.OnEnter = function( self )
	RunConsoleCommand( "ulx", "rcon", "sv_password", unpack( string.Explode(" ", self:GetValue() ) ) )
	self:SetText( "Change Password..." )
end

table.insert( xgui.modules.setting, { name="Server", panel=server_settings, icon="gui/silkicons/application", tooltip=nil, access="xgui_svsettings" } )