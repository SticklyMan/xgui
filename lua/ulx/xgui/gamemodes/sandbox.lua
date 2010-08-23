--Sandbox settings module for ULX GUI -- by Stickly Man!
--Defines limits and sbox_ specific settings for the sandbox gamemode.

local sbox_settings = x_makeXpanel{ parent=xgui.null }

x_makecheckbox{ x=10, y=10, label="Enable Noclip", repconvar="rep_sbox_noclip", parent=sbox_settings, textcolor=color_black }
x_makecheckbox{ x=10, y=30, label="Enable Godmode", repconvar="rep_sbox_godmode", parent=sbox_settings, textcolor=color_black }
x_makecheckbox{ x=10, y=50, label="Disable PvP Damage", repconvar="rep_sbox_plpldamage", parent=sbox_settings, textcolor=color_black }
x_makecheckbox{ x=10, y=70, label="Spawn With Weapons", repconvar="rep_sbox_weapons", parent=sbox_settings, textcolor=color_black }
x_makecheckbox{ x=10, y=90, label="Limited Physgun", repconvar="rep_physgun_limited", parent=sbox_settings, textcolor=color_black }
x_makelabel{ x=5, y=216, label="The limits on the right were\nretrieved from an online list\nat ulyssesmod.net. If there\nare any limits that need to\nbe added, or if you feel that\na maximum slider value\nshould be changed, then\nplease email me at:\nsticklyman@ulyssesmod.net.", parent=sbox_settings, textcolor=color_black }
sbox_settings.plist = x_makepanellist{ x=145, y=5, h=327, w=440, spacing=1, padding=2, parent=sbox_settings }

function sbox_settings.processLimits()
	sbox_settings.plist:Clear()
	for g, limits in ipairs( xgui.data.sboxlimits ) do
		if #limits > 0 then
			local panel = x_makepanel{ h=5+math.ceil( #limits/2 )*45 }
			local i=0
			for _, cvar in ipairs( limits ) do
				local cvardata = string.Explode( " ", cvar ) --Split the cvarname and max slider value number
				ULib.queueFunctionCall( x_makeslider, { x=5+(i%2*210), y=5+math.floor(i/2)*45, w=200, h=45, label="Max " .. cvardata[1]:sub(9), min=0, max=cvardata[2], repconvar="rep_"..cvardata[1], parent=panel, textcolor=color_white } )
				i = i + 1
			end
			sbox_settings.plist:AddItem( x_makecat{ label=limits.title .. " (" .. #limits .. " limit" .. ((#limits > 1) and "s" or "") .. ")", contents=panel, expanded=( g==1 ) } )
		end
	end
end

table.insert( xgui.modules.setting, { name="Sandbox", panel=sbox_settings, icon="gui/silkicons/box", tooltip=nil, access="xgui_gmsettings" } )
table.insert( xgui.hook["sboxlimits"], sbox_settings.processLimits )