--Settings module for ULX GUI -- by Stickly Man!
--Allows changing of various settings

xgui_settings = x_makeXpanel( )

local xgui_general = x_makepanellist{ x=5, y=30, w=190, h=335, spacing=1, padding=0, parent=xgui_settings, autosize=false }
	local xgui_general_cat1 = x_makepanellist{ autosize=true }
		xgui_general_cat1:AddItem( x_makecheckbox{ label="Enable Noclip", convar="sbox_cl_noclip" } )
		xgui_general_cat1:AddItem( x_makecheckbox{ label="Enable Godmode", convar="sbox_cl_godmode" } )
		xgui_general_cat1:AddItem( x_makecheckbox{ label="Enable PvP Damage", convar="sbox_cl_plpldamage" } )
	xgui_general:AddItem( x_makecat{ label="Gamemode Settings", contents=xgui_general_cat1, parent=xgui_general, expanded=false } )
	
	local xgui_general_cat2 = x_makepanellist{ autosize=true }
		xgui_general_cat2:AddItem( x_makecheckbox{ label="Enable Voice Chat", convar="sv_cl_voiceenable", tooltip="Enable voice chatting" } )
		xgui_general_cat2:AddItem( x_makecheckbox{ label="Enable Alltalk", convar="sv_cl_alltalk", tooltip="Players talk to everyone instead of just team" } )
		local xgui_password_button = x_makebutton{ label="Set server password...", w=190, h=20, parent=xgui_general_cat2 }
		xgui_password_button.DoClick = function()
			local xgui_pw = x_makeframepopup{ label="Set Server Password", w=400, h=60 }
			local xgui_pw_text = x_maketextbox{ x=10, y=30, w=380, h=20, parent=xgui_pw }
			xgui_pw_text.OnEnter = function()
				RunConsoleCommand( "ulx", "rcon", "sv_password", unpack( string.Explode(" ", xgui_pw_text:GetValue() ) ) )
				xgui_pw:Remove()
			end
		end
		xgui_general_cat2:AddItem( xgui_password_button )
	xgui_general:AddItem( x_makecat{ label="Server Settings", contents=xgui_general_cat2, parent=xgui_general, expanded=false } )
	
	local xgui_general_cat3 = x_makepanellist{ autosize=true }
		xgui_general_cat3:AddItem( x_makecheckbox{ label="Disable AI", convar="ai_cl_disabled", tooltip="Disables AI movement and thinking" } )
		xgui_general_cat3:AddItem( x_makecheckbox{ label="Keep AI Ragdolls", convar="ai_cl_keepragdolls", tooltip="When an AI dies, it will leave behind a ragdoll" } )
		xgui_general_cat3:AddItem( x_makecheckbox{ label="AI Ignore Players", convar="ai_cl_ignoreplayers", tooltip="AI will ignore players" } )
		xgui_general_cat3:AddItem( x_makeslider{ label="sv_gravity", min=-1000, max=1000, convar="sv_cl_gravity", tooltip="Changes the gravity. Default 600" } )
		xgui_general_cat3:AddItem( x_makeslider{ label="phys_timescale", min=0, max=4, decimal=2, convar="phys_cl_timescale", tooltip="Changes the timescale of the physics. Default is 1" } )
	xgui_general:AddItem( x_makecat{ label="Misc Settings", contents=xgui_general_cat3, parent=xgui_general, expanded=false } )

local xgui_ULX = x_makepanellist{ x=200, y=30, w=190, h=335, spacing=1, padding=0, parent=xgui_settings, autosize=false }
	local xgui_ULX_cat1 = x_makepanellist{ autosize=true }
		xgui_ULX_cat1:AddItem( x_makecheckbox{ label="Show MOTD", convar="ulx_cl_showMotd", tooltip="Shows the Message of the Day when players join" } )
		xgui_ULX_cat1:AddItem( x_makeslider{ label="Chat Spam Time", min=0, max=5, decimal=1, convar="ulx_cl_chattime", tooltip="Amount of time in seconds before a player can send another message. Prevents Spam. Default is 1.5" } )
		local xgui_welcomemessage_button = x_makebutton{ height=20, label="Set Welcome Message..." }
		xgui_welcomemessage_button.DoClick = function()
			local xgui_wm = x_makeframepopup{ label="Set Welcome Message", w=400, h=60 }
			local xgui_wm_text = x_maketextbox{ x=10, y=30, w=380, h=20, parent=xgui_wm }
			xgui_wm_text:SetText( GetConVar( "ulx_welcomemessage" ):GetString() )
			xgui_wm_text.OnEnter = function()
				RunConsoleCommand( "ulx", "rcon", "ulx_welcomemessage", unpack( string.Explode( " ", xgui_wm_text:GetValue() ) ) )
				xgui_wm:Remove()
			end
		end
		xgui_ULX_cat1:AddItem( xgui_welcomemessage_button )
		
		local xgui_gimp_button = x_makebutton{ h=20, label="Manage Gimp Sayings..."}
		xgui_gimp_button.DoClick = function()
			local xgui_gimp = x_makeframepopup{ label="Manage Gimp Sayings", w=250, h=200 }
			xgui_gimp_list = x_makelistview{ x=10, y=35, w=230, h=135, multiselect=false, parent=xgui_gimp }
			xgui_gimp_list:AddColumn( "Gimp Sayings" )
			x_makebutton{ x=10, y=170, w=115, h=20, label="Add...", parent=xgui_gimp }.DoClick = function()
				local xgui_gimp_add = x_makeframepopup{ label="Add a gimp saying", w=400, h=60 }
				local xgui_gimp_textbox = x_maketextbox{ x=10, y=30, w=380, h=20, parent=xgui_gimp_add }
				xgui_gimp_textbox.OnEnter = function()
					if xgui_gimp_textbox:GetValue()then
						RunConsoleCommand( "ulx", "addGimpSay", unpack( string.Explode(" ", xgui_gimp_textbox:GetValue() ) ) )
						xgui_gimp_list:AddLine( xgui_gimp_textbox:GetValue() )
						xgui_gimp_add:Remove()
					end
				end
			end
			x_makebutton{ x=125, y=170, w=115, h=20, label="Remove", parent=xgui_gimp }.DoClick = function()
				if xgui_gimp_list:GetSelectedLine()then
					RunConsoleCommand( "xgui", "removeGimp", xgui_gimp_list:GetSelected()[1]:GetColumnText( 1 ) )
					xgui_gimp_list:RemoveLine( xgui_gimp_list:GetSelectedLine() )
				end
			end
			
			for k, v in pairs( xgui_data.gimps ) do
				xgui_gimp_list:AddLine( v )
			end
		end
		xgui_ULX_cat1:AddItem( xgui_gimp_button )

		local xgui_advert_button = x_makebutton{ h=20, label="Manage Adverts..." }
		xgui_advert_button.DoClick = function()
			local xgui_advert = x_makeframepopup{ label="Manage Adverts", w=280, h=335 }
			xgui_advert_list = x_makelistview{ x=5, y=30, w=75, h=260, multiselect=false, parent=xgui_advert }
			xgui_advert_list:AddColumn( "Group : #" )
			xgui_advert_list.OnRowSelected = function()
				local i = xgui_advert_list:GetSelected()[1]:GetColumnText(2)
				xgui_message:SetText( xgui_data.adverts[i].message )
				xgui_repeat:SetValue( xgui_data.adverts[i].rpt )
				xgui_group:SetText( xgui_data.adverts[i].groupname )
				if xgui_data.adverts[i].color ~= nil then
					xgui_is_csay:SetValue( true )
					xgui_display:SetValue( xgui_data.adverts[i].len )
					RunConsoleCommand( "colour_r", xgui_data.adverts[i].color.r )
					RunConsoleCommand( "colour_g", xgui_data.adverts[i].color.g )
					RunConsoleCommand( "colour_b", xgui_data.adverts[i].color.b )
					RunConsoleCommand( "colour_a", xgui_data.adverts[i].color.a )
				else
					xgui_is_csay:SetValue( false )
				end
				xgui_is_csay:InvalidateLayout()
			end
			x_makebutton{ x=5, y=290, w=55, label="Add", parent=xgui_advert }.DoClick = function()
				if xgui_is_csay:GetChecked() ~= true then
					RunConsoleCommand( "ulx", "addAdvert", xgui_message:GetValue(), xgui_repeat:GetValue(), xgui_group:GetValue() )
				else
					RunConsoleCommand( "ulx", "addCsayAdvert", xgui_message:GetValue(), GetConVarNumber( "colour_r" ), GetConVarNumber( "colour_g" ), GetConVarNumber( "colour_b" ), xgui_repeat:GetValue(), xgui_display:GetValue(), xgui_group:GetValue() )
				end	
				xgui_advert_list:Clear()
			end
			x_makebutton{ x=5, y=310, w=75, label="Remove", parent=xgui_advert }.DoClick = function()
				if xgui_advert_list:GetSelectedLine() then
					local xgui_temp = string.Explode( ":",xgui_advert_list:GetSelected()[1]:GetColumnText( 1 ) )
					RunConsoleCommand( "xgui", "removeadvert", xgui_temp[1], xgui_temp[2] )
					xgui_advert_list:Clear()
				end
			end
			local xgui_advert_colorbox = x_makepanel{ x=60, y=290, w=20, h=20, parent=xgui_advert }
			xgui_advert_colorbox.Paint = function()
				surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
				if xgui_advert_list:GetSelectedLine() then
					if xgui_data.adverts[xgui_advert_list:GetSelected()[1]:GetColumnText(2)].color ~= nil then
						surface.SetDrawColor( Color( GetConVarNumber( "colour_r" ), GetConVarNumber( "colour_g" ), GetConVarNumber( "colour_b" ), GetConVarNumber( "colour_a" ) ) )
					end
				end
				surface.DrawRect( 0, 0, 20, 20 )
			end
			xgui_add_list = x_makepanellist{ x=85, y=30, w=190, h=300, spacing=4, parent=xgui_advert, autosize=false }
			xgui_add_list:AddItem( x_makelabel{ label="Message:" } )
			xgui_message = x_maketextbox{ }
				xgui_add_list:AddItem( xgui_message )
			xgui_repeat = x_makeslider{ label="Repeat Time", value=60, min=0.1, max=1000, decimal=1, tooltip="Time in seconds till the advert is shown again" }
				xgui_add_list:AddItem( xgui_repeat )
			xgui_add_list:AddItem( x_makelabel{ label="Group: (optional)" } )
			xgui_group = x_maketextbox{ tooltip="Optional - Specify a group name to link multiple adverts so they display one after the other" }
				xgui_add_list:AddItem( xgui_group )
			xgui_is_csay = x_makecheckbox{ label="CSay Advert", tooltip="A CSay advert will appear in the center of the screen, and can have a color. Otherwise it will show in the chat window" }
				xgui_add_list:AddItem( xgui_is_csay )
			xgui_display = x_makeslider{ label="Display Time", value=0.1, min=0.1, max=60, decimal=1, tooltip="The time in seconds the CSay advert is displayed", xgui_advert }
				xgui_add_list:AddItem( xgui_display )
			xgui_add_list:AddItem( x_makecolorpicker{} )
			for k, v in pairs( xgui_data.adverts ) do
				xgui_advert_list:AddLine( v.groupname .. ":" .. v.num, k )
			end
		end
		xgui_ULX_cat1:AddItem( xgui_advert_button )
		
	xgui_ULX:AddItem( x_makecat{ label="ULX Settings", contents=xgui_ULX_cat1, expanded=false } )
	
	local xgui_ULX_cat2 = x_makepanellist{ autosize=true }
		xgui_ULX_cat2:AddItem( x_makeslider{ label="Votekick Success Ratio", min=0, max=1, decimal=2, convar="ulx_cl_votekickSuccessratio", tooltip="Ratio of votes needed to consider a votekick successful.Votes for kick / Total players" } )
		xgui_ULX_cat2:AddItem( x_makeslider{ label="Votekick Minimum Votes", min=0, max=10, convar="ulx_cl_votekickMinvotes", tooltip="Minimum number of votes needed to kick someone using votekick" } )
		xgui_ULX_cat2:AddItem( x_makeslider{ label="Voteban Success Ratio", min=0, max=1, decimal=2, convar="ulx_cl_votebanSuccessratio", tooltip="Ratio of votes needed to consider a voteban successful.Votes for ban / Total players" } )
		xgui_ULX_cat2:AddItem( x_makeslider{ label="Voteban Minimum Votes", min=0, max=10, convar="ulx_cl_votebanMinvotes", tooltip="Minimum number of votes needed to ban someone using votekick" } )
		xgui_ULX_cat2:AddItem( x_makecheckbox{ label="Echo Votes", convar="ulx_cl_voteEcho", tooltip="Display players choices on votes" } )
		xgui_ULX_cat2:AddItem( x_makecheckbox{ label="Enable Player Votemaps", convar="ulx_cl_votemapEnabled" } )
		xgui_ULX_cat2:AddItem( x_makeslider{ label="Votemap Minimum Time", 	min=0, max=300,convar="ulx_cl_votemapMintime", tooltip="Time in minutes after a map change before a votemap can be started" } )
		xgui_ULX_cat2:AddItem( x_makeslider{ label="Votemap Wait Time", 	min=0, max=60, 	decimal=1, convar="ulx_cl_votemapWaitTime", tooltip="Time in minutes after voting for a map before you can change your vote" } )
		xgui_ULX_cat2:AddItem( x_makeslider{ label="Votemap Success Ratio", min=0, max=1, 	decimal=2, convar="ulx_cl_votemapSuccessratio", tooltip="Ratio of votes needed to consider a vote successful.Votes for map / Total players" } )
		xgui_ULX_cat2:AddItem( x_makeslider{ label="Votemap Minimum Votes", min=0, max=10, convar="ulx_cl_votemapMinvotes", tooltip="Minimum number of votes needed to change a level" } )
		xgui_ULX_cat2:AddItem( x_makeslider{ label="Votemap Veto Time",		min=0, max=300, convar="ulx_cl_votemapVetotime", tooltip="Time in seconds after a map change before an admin can veto the mapchange" } )
		xgui_ULX_cat2:AddItem( x_makelabel{ label="Server-wide Votemap Settings" } )
		xgui_ULX_cat2:AddItem( x_makeslider{ label="Votemap2 Success Ratio", min=0, max=1, 	decimal=2, convar="ulx_cl_votemap2Successratio", tooltip="Ratio of votes needed to consider a vote successful.Votes for map / Total players" } )
		xgui_ULX_cat2:AddItem( x_makeslider{ label="Votemap2 Minimum Votes", min=0, max=10, convar="ulx_cl_votemap2Minvotes", tooltip="Minimum number of votes needed to change a level" } )
	xgui_ULX:AddItem( x_makecat{ label="Vote Settings", contents=xgui_ULX_cat2, expanded=false } )

	local xgui_ULX_cat3 = x_makepanellist{ autosize=true }
		xgui_ULX_cat3:AddItem( x_makecheckbox{ label="Enable Logging", convar="ulx_cl_logFile", tooltip="Enable logging of ULX actions to a file" } )
		xgui_ULX_cat3:AddItem( x_makecheckbox{ label="Log Chat", convar="ulx_cl_logChat", tooltip="Enable logging of Chat" } )
		xgui_ULX_cat3:AddItem( x_makecheckbox{ label="Log Player Events", convar="ulx_cl_logEvents", tooltip="Enable logging of player connects, disconnects, deaths, etc" } )
		xgui_ULX_cat3:AddItem( x_makecheckbox{ label="Log Spawns", convar="ulx_cl_logSpawns", tooltip="Enable logging of spawns of props, effects, etc" } )
		
		xgui_ULX_cat3:AddItem( x_makelabel{ label="Echo Events", tooltip="Display a message to all players when an admin command is used. You can choose whether to show the name of the admin or keep it anonymous." } )
		xgui_ULX_cat3:AddItem( x_makemultichoice{ convar="ulx_cl_logEcho", convardata={ "0 - Off", "1 - Anonymous", "2 - Full" } } )
		xgui_ULX_cat3:AddItem( x_makelabel{ label="Echo Spawns", tooltip="Display a console message when an object is spawned. 0 - Off, 1 - Admins Only, 2 - Everyone" } )
		xgui_ULX_cat3:AddItem( x_makemultichoice{ convar="ulx_cl_logSpawnsEcho", convardata={ "0 - Off", "1 - Admins Only", "2 - Everyone" } } )
	xgui_ULX:AddItem( x_makecat{ label="Logging Settings", contents=xgui_ULX_cat3, expanded=false } )
	
	local xgui_ULX_cat4 = x_makepanellist{ autosize=true }
		xgui_ULX_cat4:AddItem( x_makeslider{ label="Number of Reserved Slots", min=0, max=GetConVarNumber( "sv_maxplayers" ), convar="ulx_cl_rslots" } )
		xgui_ULX_cat4:AddItem( x_makelabel{ label="Reserved Slots Mode", tooltip="0 - Off\n1 - Keep # of slots reserved for admins, admins fill slots\n2 - Keep # of slots reserved for admins, admins don't fill slots, they'll be freed when a player leaves\n3 - Always keep 1 slot open for admins, kick the user with the shortest connection time if an admin joins\nFor more information on reserved slots, check out the ulx server.ini file" } )
		xgui_ULX_cat4:AddItem( x_makemultichoice{ convar="ulx_cl_rslotsMode", convardata={ "0 - Off", "1 - Admins fill slots", "2 - Admins don't fill slots", "3 - Admins kick newest player" } } )
		xgui_ULX_cat4:AddItem( x_makecheckbox{ label="Reserved Slots Visible", convar="ulx_cl_rslotsVisible", tooltip="When enabled, if there are no regular player slots available in your server, it will appear that the server is full.\nThe major downside to this is that admins can't connect to the server using the 'find server' dialog.\nInstead, they have to go to console and use the command 'connect <ip>'" } )
	xgui_ULX:AddItem( x_makecat{ label="Reserved Slots", contents=xgui_ULX_cat4, expanded=false } )

local xgui_GUI = x_makepanellist{ x=395, y=30, w=190, h=200, spacing=1, padding=0, parent=xgui_settings, autosize=false }
	local xgui_GUI_cat1 = x_makepanellist{ autosize=true }
		xgui_GUI_cat1:AddItem( x_makecheckbox{ label="Use XGUI to save settings", tooltip="This doesn't do anything yet" } )
		xgui_GUI_cat1:AddItem( x_makecheckbox{ label="Disable Tooltips", tooltip="This doesn't do anything yet" } )
		xgui_GUI_cat1:AddItem( x_makecheckbox{ label="Send map thumbnails to clients", tooltip="This doesn't do anything yet" } )
		xgui_button_refresh = x_makebutton{ label="Refresh Server Data.." }
		xgui_button_refresh.DoClick=function()
			xgui_hide()
			xgui_hasLoaded = false
			RunConsoleCommand( "xgui", "getdata" )
			xgui_show()
		end
		xgui_GUI_cat1:AddItem( xgui_button_refresh )
	xgui_GUI:AddItem( x_makecat{ label="XGUI Settings", contents=xgui_GUI_cat1, expanded=true } )
	
xgui_settings.XGUI_Refresh = function() end

xgui_base:AddSheet( "Settings", xgui_settings, "gui/silkicons/wrench", false, false )