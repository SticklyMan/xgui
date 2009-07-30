--Settings module for ULX GUI -- by Stickly Man!
--Allows changing of various settings

function xgui_tab_settings()
	xgui_settings = vgui.Create( "DPanel" )
------------
	xgui_settings.Paint = function()
		surface.SetDrawColor( 191, 191, 191, 255 )
		surface.DrawRect( 0, 0, 590, 390 )
	end
------------
	local xgset_general = x_makepanelist{ x=10, y=30, w=190, h=330, spacing=1, padding=0, parent=xgui_settings, autosize=false }
		local xgset_general_cat1 = x_makepanelist{ autosize=true }
			xgset_general_cat1:AddItem( x_makecheckbox{ label="Enable Noclip", convar="sbox_noclip" } )
			xgset_general_cat1:AddItem( x_makecheckbox{ label="Enable Godmode", convar="sbox_godmode" } )
			xgset_general_cat1:AddItem( x_makecheckbox{ label="Enable PvP Damage", convar="sbox_plpldamage" } )
		xgset_general:AddItem( x_makecat{ label="Gamemode Settings", contents=xgset_general_cat1, parent=xgset_general } )

		
		local xgset_general_cat2 = x_makepanelist{ autosize=true }
			xgset_general_cat2:AddItem( x_makecheckbox{ label="Enable Script Enforcer", convar="sv_scriptenforcer", tooltip="Forces clients to have the same scripts as the server" } )
			xgset_general_cat2:AddItem( x_makecheckbox{ label="Enable Voice Chat", convar="sv_voiceenable", tooltip="Enable voice chatting" } )
			xgset_general_cat2:AddItem( x_makecheckbox{ label="Enable Alltalk", convar="sv_alltalk", tooltip="Players talk to everyone instead of just team" } )
				local xgset_password_button = x_makebutton{ label="Set server password...", w=190, h=20, parent=xgset_general_cat2 }
				xgset_password_button.DoClick = function()
					local xgset_pw = x_makeframepopup{ label="Set Server Password", w=400, h=60 }
					local xgset_pw_text = x_maketextbox{ x=10, y=30, w=380, h=20, parent=xgset_pw }
					xgset_pw_text.OnEnter = function()
						RunConsoleCommand( "ulx", "rcon", "sv_password", unpack( string.Explode(" ", xgset_pw_text:GetValue() ) ) )
						xgset_pw:Remove()
					end
				end
			xgset_general_cat2:AddItem( xgset_password_button )
		xgset_general:AddItem( x_makecat{ label="Server Settings", contents=xgset_general_cat2, parent=xgset_general } )
		
		
		local xgset_general_cat3 = x_makepanelist{ autosize=true }
			xgset_general_cat3:AddItem( x_makecheckbox{ label="Disable AI", convar="ai_disabled", tooltip="Disables AI movement and thinking" } )
			xgset_general_cat3:AddItem( x_makecheckbox{ label="Keep AI Ragdolls", convar="ai_keepragdolls", tooltip="When an AI dies, it will leave behind a ragdoll" } )
			xgset_general_cat3:AddItem( x_makecheckbox{ label="AI Ignore Players", convar="ai_ignoreplayers", tooltip="AI will ignore players" } )
			xgset_general_cat3:AddItem( x_makeslider{ label="sv_gravity", min=-1000, max=1000, convar="sv_gravity", tooltip="Changes the gravity. Default 600" } )
			xgset_general_cat3:AddItem( x_makeslider{ label="phys_timescale", min=0, max=4, decimal=2, convar="phys_timescale", tooltip="Changes the timescale of the physics. Default is 1" } )
			
		xgset_general:AddItem( x_makecat{ label="Misc Settings", contents=xgset_general_cat3, parent=xgset_general } )
------------
	local xgset_ULX = x_makepanelist{ x=200, y=30, w=190, h=330, spacing=1, padding=0, parent=xgui_settings, autosize=false }
		local xgset_ULX_cat1 = x_makepanelist{ autosize=true }
			xgset_ULX_cat1:AddItem( x_makecheckbox{ label="Show MOTD", convar="ulx_cl_showMotd", tooltip="Shows the Message of the Day when players join" } )
			xgset_ULX_cat1:AddItem( x_makeslider{ label="Chat Spam Time", min=0, max=5, decimal=1, convar="ulx_cl_chattime", tooltip="Amount of time in seconds before a player can send another message. Prevents Spam. Default is 1.5" } )
				local xgset_welcomemessage_button = x_makebutton{ height=20, label="Set Welcome Message..." }
				xgset_welcomemessage_button.DoClick = function()
					local xgset_wm = x_makeframepopup{ label="Set Welcome Message", w=400, h=60 }
					local xgset_wm_text = x_maketextbox{ x=10, y=30, w=380, h=20, parent=xgset_wm }
					xgset_wm_text:SetText( GetConVar( "ulx_welcomemessage" ):GetString() )
					xgset_wm_text.OnEnter = function()
						RunConsoleCommand( "ulx", "rcon", "ulx_welcomemessage", unpack( string.Explode( " ", xgset_wm_text:GetValue() ) ) )
						xgset_wm:Remove()
					end
				end
			xgset_ULX_cat1:AddItem( xgset_welcomemessage_button )
				local xgset_gimp_button = x_makebutton{ h=20, label="Manage Gimp Sayings..."}
				xgset_gimp_button.DoClick = function()
					local xgset_gimp = x_makeframepopup{ label="Manage Gimp Sayings", w=250, h=200 }
					xgset_gimp_list = x_makelistview{ x=10, y=35, w=230, h=135, multiselect=false, parent=xgset_gimp }
					xgset_gimp_list:AddColumn( "Gimp Sayings" )
					x_makebutton{ x=10, y=170, w=115, h=20, label="Add...", parent=xgset_gimp }.DoClick = function()
						local xgset_gimp_add = x_makeframepopup{ label="Add a gimp saying", w=400, h=60 }
						local xgset_gimp_textbox = x_maketextbox{ x=10, y=30, w=380, h=20, parent=xgset_gimp_add }
						xgset_gimp_textbox.OnEnter = function()
							if xgset_gimp_textbox:GetValue()then
								RunConsoleCommand( "ulx", "addGimpSay", unpack( string.Explode(" ", xgset_gimp_textbox:GetValue() ) ) )
								xgset_gimp_list:AddLine( xgset_gimp_textbox:GetValue() )
								xgset_gimp_add:Remove()
							end
						end
					end
					x_makebutton{ x=125, y=170, w=115, h=20, label="Remove", parent=xgset_gimp }.DoClick = function()
						if xgset_gimp_list:GetSelectedLine()then
							RunConsoleCommand( "xgui_removeGimp", xgset_gimp_list:GetSelected()[1]:GetColumnText( 1 ) )
							xgset_gimp_list:RemoveLine( xgset_gimp_list:GetSelectedLine() )
						end
					end
					RunConsoleCommand( "xgui_requestgimps" )
				end
			xgset_ULX_cat1:AddItem( xgset_gimp_button )

			local xgset_advert_button = x_makebutton{ h=20, label="Manage Adverts..." }
				xgset_advert_button.DoClick = function()
					local xgset_advert = x_makeframepopup{ label="Manage Adverts", w=260, h=220 }
					local xgset_advert_text = x_maketextbox{ x=10, y=170, w=220, h=20, parent=xgset_advert, text="No Advert Selected", enableinput=false }
					
					local xgset_advert_colorbox = x_makepanel{ x=230, y=170, w=20, h=20, parent=xgset_advert }
					local xgset_advert_color = Color( 0, 0, 0, 255 )
					xgset_advert_colorbox.Paint = function()
						surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
						if xgset_advert_list:GetSelectedLine()then
							if xgset_advert_list:GetSelected()[1]:GetColumnText( 6 ) ~= "" then
								surface.SetDrawColor( xgset_advert_list:GetSelected()[1]:GetColumnText( 6 ) )
							end
						end
						surface.DrawRect( 0, 0, 20, 20 )
					end

					xgset_advert_list = x_makelistview{ x=10, y=35, w=240, h=135, multiselect=false, parent=xgset_advert }
					xgset_advert_list:AddColumn( "G:N" )
					xgset_advert_list:AddColumn( "Rep" )
					xgset_advert_list:AddColumn( "Disp" )
					xgset_advert_list:AddColumn( "Csay?" )
					xgset_advert_list.OnRowSelected = function()
						xgset_advert_text:SetText( xgset_advert_list:GetSelected()[1]:GetColumnText( 5 ) )
					end

					x_makebutton{ x=10, y=190, w=120, h=20, label="Add...", parent=xgset_advert }.DoClick = function()
						local xgset_add_advert = x_makeframepopup{ label="Add an advert", w=260, h=280, parent=xgset_advert }
						local xgset_add_list = x_makepanelist{ x=10, y=30, w=240, h=240, parent=xgset_add_advert, autosize=false }
						
						xgset_add_list:AddItem( x_makelabel{ label="Message:" } )
						local xgset_message = x_maketextbox{ }
							xgset_add_list:AddItem( xgset_message )
						local xgset_repeat = x_makeslider{ label="Repeat Time", value=0.1, min=0.1, max=1000, decimal=1, tooltip="Time in seconds till the advert is shown again" }
							xgset_add_list:AddItem( xgset_repeat )
						xgset_add_list:AddItem( x_makelabel{ label="Group:" } )
						local xgset_group = x_maketextbox{ tooltip="Optional - Specify a group name to link multiple adverts so they display one after the other" }
							xgset_add_list:AddItem( xgset_group )
						local xgset_is_csay = x_makecheckbox{ label="CSay Advert", tooltip="A CSay advert will appear in the center of the screen, and can have a color. Otherwise it will show in the chat window" , xgset_add_advert }
							xgset_add_list:AddItem( xgset_is_csay )
						
						xgset_add_csay = x_makepanelist{ autosize=true }
						local xgset_display = x_makeslider{ label="Display Time", value=0.1, min=0.1, max=60, decimal=1, tooltip="The time in seconds the CSay advert is displayed", xgset_add_advert }
							xgset_add_csay:AddItem( xgset_display )
						xgset_add_csay:AddItem( x_makecolorpicker{ } )	
						
						local xgset_make_advert = x_makebutton{ label="Create Advert" }
						xgset_make_advert.DoClick = function()
							if xgset_is_csay:GetChecked() ~= true then
								RunConsoleCommand( "ulx", "addAdvert", xgset_message:GetValue(), xgset_repeat:GetValue(), xgset_group:GetValue() )
							else
								RunConsoleCommand( "ulx", "addCsayAdvert", xgset_message:GetValue(), GetConVarNumber( "colour_r" ), GetConVarNumber( "colour_g" ), GetConVarNumber( "colour_b" ), xgset_repeat:GetValue(), xgset_display:GetValue(), xgset_group:GetValue() )
							end	
							xgset_advert_list:Clear()
							RunConsoleCommand( "xgui_requestadverts" )
						end
						xgset_add_list:AddItem( xgset_make_advert )
						xgset_add_list:AddItem( x_makecat{ label="CSay Settings", contents=xgset_add_csay } )
					end
					x_makebutton{ x=130, y=190, w=120, h=20, label="Remove", parent=xgset_advert }.DoClick = function()
						if xgset_advert_list:GetSelectedLine()then
							local xgui_temp = string.Explode( ":",xgset_advert_list:GetSelected()[1]:GetColumnText( 1 ) )
							RunConsoleCommand( "xgui_removeadvert", xgui_temp[1], xgui_temp[2] )
							xgset_advert_list:Clear()
							RunConsoleCommand( "xgui_requestadverts" )
						end
					end
					
					RunConsoleCommand( "xgui_requestadverts" )
				end
			xgset_ULX_cat1:AddItem( xgset_advert_button )
			
		xgset_ULX:AddItem( x_makecat{ label="ULX Settings", contents=xgset_ULX_cat1 } )
		
		local xgset_ULX_cat2 = x_makepanelist{ autosize=true }
			xgset_ULX_cat2:AddItem( x_makeslider{ label="Votekick Success Ratio", min=0, max=1, decimal=2, convar="ulx_cl_votekickSuccessratio", tooltip="Ratio of votes needed to consider a votekick successful.Votes for kick / Total players" } )
			xgset_ULX_cat2:AddItem( x_makeslider{ label="Votekick Minimum Votes", min=0, max=10, convar="ulx_cl_votekickMinvotes", tooltip="Minimum number of votes needed to kick someone using votekick" } )
			xgset_ULX_cat2:AddItem( x_makeslider{ label="Voteban Success Ratio", min=0, max=1, decimal=2, convar="ulx_cl_votebanSuccessratio", tooltip="Ratio of votes needed to consider a voteban successful.Votes for ban / Total players" } )
			xgset_ULX_cat2:AddItem( x_makeslider{ label="Voteban Minimum Votes", min=0, max=10, convar="ulx_cl_votebanMinvotes", tooltip="Minimum number of votes needed to ban someone using votekick" } )
			xgset_ULX_cat2:AddItem( x_makecheckbox{ label="Echo Votes", convar="ulx_cl_voteEcho", tooltip="Display players choices on votes" } )
		xgset_ULX:AddItem( x_makecat{ label="Vote Settings", contents=xgset_ULX_cat2 } )

		local xgset_ULX_cat3 = x_makepanelist{ autosize=true }
			xgset_ULX_cat3:AddItem( x_makecheckbox{ label="Enable Logging", convar="ulx_cl_logFile", tooltip="Enable logging of ULX actions to a file" } )
			xgset_ULX_cat3:AddItem( x_makecheckbox{ label="Log Chat", convar="ulx_cl_logChat", tooltip="Enable logging of Chat" } )
			xgset_ULX_cat3:AddItem( x_makecheckbox{ label="Log Player Events", convar="ulx_cl_logEvents", tooltip="Enable logging of player connects, disconnects, deaths, etc" } )
			xgset_ULX_cat3:AddItem( x_makecheckbox{ label="Log Spawns", convar="ulx_cl_logSpawns", tooltip="Enable logging of spawns of props, effects, etc" } )
			xgset_ULX_cat3:AddItem( x_makeslider{ label="Echo Events", min=0, max=2, convar="ulx_cl_logEcho", tooltip="Display a message to all players when an admin command is used. The privacy of the admin is based on the value. 0 - Off, 1 - Anonymous, 2 - Full" } )
			xgset_ULX_cat3:AddItem( x_makeslider{ label="Echo Spawns", min=0, max=2, convar="ulx_cl_logSpawnsEcho", tooltip="Display a console message when an object is spawned. 0 - Off, 1 - Admins Only, 2 - Everyone" } )
		xgset_ULX:AddItem( x_makecat{ label="Logging Settings", contents=xgset_ULX_cat3 } )
		
		local xgset_ULX_cat4 = x_makepanelist{ autosize=true }
			xgset_ULX_cat4:AddItem( x_makeslider{ label = "Number of Reserved Slots", min=0, max=GetConVarNumber( "sv_maxplayers" ), convar="ulx_cl_rslots" } )
			xgset_ULX_cat4:AddItem( x_makeslider{ label = "Reserved Slots Mode", min=0, max=3, convar="ulx_cl_rslotsMode", tooltip="0 - Off\n1 - Keep # of slots reserved for admins, admins fill slots\n2 - Keep # of slots reserved for admins, admins don't fill slots, they'll be freed when a player leaves\n3 - Always keep 1 slot open for admins, kick the user with the shortest connection time if an admin joins\nFor more information on reserved slots, check out the ulx server.ini file" } )
			xgset_ULX_cat4:AddItem( x_makecheckbox{ label= "Reserved Slots Visible", convar="ulx_cl_rslotsVisible", tooltip="When enabled, if there are no regular player slots available in your server, it will appear that the server is full.\nThe major downside to this is that admins can't connect to the server using the 'find server' dialog.\nInstead, they have to go to console and use the command 'connect <ip>'" } )
		xgset_ULX:AddItem( x_makecat{ label="Reserved Slots", contents=xgset_ULX_cat4 } )

------------
	local xgset_GUI = x_makepanelist{ x=390, y=30, w=190, h=200, spacing=1, padding=0, parent=xgui_settings, autosize=false }
		local xgset_GUI_cat1 = x_makepanelist{ autosize=true }
			xgset_GUI_cat1:AddItem( x_makecheckbox{ label= "Use XGUI to save settings", tooltip="This doesn't do anything yet" } )
			xgset_GUI_cat1:AddItem( x_makecheckbox{ label= "Disable Tooltips", tooltip="This doesn't do anything yet" } )
			xgset_GUI_cat1:AddItem( x_makecheckbox{ label= "Send map thumbnails to clients", tooltip="This doesn't do anything yet" } )
		xgset_GUI:AddItem( x_makecat{ label="XGUI Settings", contents=xgset_GUI_cat1 } )
	xgui_base:AddSheet( "Settings", xgui_settings, "gui/silkicons/wrench", false, false )
end

xgui_modules[4]=xgui_tab_settings

local function xgset_gimp_rcv( um )
	if xgset_gimp_list:IsVisible() then
		xgset_gimp_list:AddLine( um:ReadString() )
	end
end
usermessage.Hook( "xgui_gimp", xgset_gimp_rcv )

local function xgset_advert_rcv( um )
	if xgset_advert_list:IsVisible() then
		local advert = ULib.umsgRcv( um )
		local isCsay = "No"
		if advert.color then
			isCsay = "Yes"
		end
		xgset_advert_list:AddLine( ULib.umsgRcv( um ) .. ":" .. ULib.umsgRcv( um ), advert.rpt, advert.len, isCsay, advert.message, advert.color )
	end
end
usermessage.Hook( "xgui_advert", xgset_advert_rcv )

/*

Disabled Tools?
ulx_toolallow
ulx_tooldeny*/