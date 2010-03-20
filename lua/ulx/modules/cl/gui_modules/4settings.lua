--Settings module for ULX GUI -- by Stickly Man!
--Allows changing of various settings

xgui_settings = x_makeXpanel{ parent=xgui_null }

local xgui_general = x_makepanellist{ x=5, y=30, w=190, h=335, spacing=1, padding=0, parent=xgui_settings, autosize=false }

---------------------------Gamemode (Sandbox) Settings---------------------------
	local xgui_general_cat1 = x_makepanellist{ autosize=true }
		xgui_general_cat1:AddItem( x_makecheckbox{ label="Enable Noclip", convar="sbox_cl_noclip" } )
		xgui_general_cat1:AddItem( x_makecheckbox{ label="Enable Godmode", convar="sbox_cl_godmode" } )
		xgui_general_cat1:AddItem( x_makecheckbox{ label="Disable PvP Damage", convar="sbox_cl_plpldamage" } )
		xgui_general_cat1:AddItem( x_makecheckbox{ label="Spawn With Weapons", convar="sbox_cl_weapons" } )
		xgui_general_cat1:AddItem( x_makecheckbox{ label="Limited Physgun", convar="cl_physgun_limited" } )
	xgui_general:AddItem( x_makecat{ label="Gamemode Settings", contents=xgui_general_cat1, parent=xgui_general, expanded=false } )
	
---------------------------Server Settings---------------------------	
	local xgui_general_cat2 = x_makepanellist{ autosize=true }
		xgui_general_cat2:AddItem( x_makecheckbox{ label="Enable Voice Chat", convar="sv_cl_voiceenable", tooltip="Enable voice chatting" } )
		xgui_general_cat2:AddItem( x_makecheckbox{ label="Enable Alltalk", convar="sv_cl_alltalk", tooltip="Players talk to everyone instead of just team" } )
		local xgui_password_button = x_makebutton{ label="Change Server Password...", w=190, h=20, parent=xgui_general_cat2 }
		xgui_password_button.DoClick = function()
			local xgui_pw = x_makeframepopup{ label="Change Server Password", w=400, h=60 }
			local xgui_pw_text = x_maketextbox{ x=10, y=30, w=380, h=20, parent=xgui_pw }
			xgui_pw_text.OnEnter = function()
				RunConsoleCommand( "ulx", "rcon", "sv_password", unpack( string.Explode(" ", xgui_pw_text:GetValue() ) ) )
				xgui_pw:Remove()
			end
		end
		xgui_general_cat2:AddItem( xgui_password_button )
	xgui_general:AddItem( x_makecat{ label="Server Settings", contents=xgui_general_cat2, parent=xgui_general, expanded=false } )

---------------------------Misc Settings---------------------------
	local xgui_general_cat3 = x_makepanellist{ autosize=true }
		xgui_general_cat3:AddItem( x_makecheckbox{ label="Disable AI", convar="ai_cl_disabled", tooltip="Disables AI movement and thinking" } )
		if SinglePlayer() then  
			xgui_general_cat3:AddItem( x_makecheckbox{ label="Keep AI Ragdolls", convar="ai_cl_keepragdolls", tooltip="When an AI dies, it will leave behind a ragdoll" } )
		end
		xgui_general_cat3:AddItem( x_makecheckbox{ label="AI Ignore Players", convar="ai_cl_ignoreplayers", tooltip="AI will ignore players" } )
		xgui_general_cat3:AddItem( x_makeslider{ label="sv_gravity", min=-1000, max=1000, convar="sv_cl_gravity", tooltip="Changes the gravity. Default 600" } )
		xgui_general_cat3:AddItem( x_makeslider{ label="phys_timescale", min=0, max=4, decimal=2, convar="phys_cl_timescale", tooltip="Changes the timescale of the physics. Default is 1" } )
	xgui_general:AddItem( x_makecat{ label="Misc Settings", contents=xgui_general_cat3, parent=xgui_general, expanded=false } )

---------------------------ULX Settings---------------------------
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
				RunConsoleCommand( "ulx", "welcomemessage", xgui_wm_text:GetValue() )
				xgui_wm:Remove()
			end
		end
		xgui_ULX_cat1:AddItem( xgui_welcomemessage_button )
		
---------------------------Gimps---------------------------		
		local xgui_gimp_button = x_makebutton{ h=20, label="Manage Gimp Sayings..."}
		xgui_gimp_button.DoClick = function()
			if xgui_gimp and xgui_gimp:IsVisible() then return end
			
			xgui_gimp = x_makeframepopup{ label="Manage Gimp Sayings", w=295, h=235 }
			
			local xgui_gimp_textbox = x_maketextbox{ x=5, y=30, w=235, h=20, parent=xgui_gimp }
			xgui_gimp_textbox.OnEnter = function()
				if xgui_gimp_textbox:GetValue() then
					RunConsoleCommand( "xgui", "addGimp", xgui_gimp_textbox:GetValue() )
					xgui_gimp_textbox:SetText( "" )
				end
			end
			xgui_gimp_textbox.OnGetFocus = function( self )
				xgui_gimp_button:SetText( "Add" )
				self:SelectAllText()
			end
			
			xgui_gimp_button = x_makebutton{ x=240, y=30, w=50, label="Add", parent=xgui_gimp }
			xgui_gimp_button.DoClick = function( self )
				if self:GetValue() == "Add" then
					xgui_gimp_textbox.OnEnter()
				elseif xgui_gimp_list:GetSelectedLine() then
					RunConsoleCommand( "xgui", "removeGimp", xgui_gimp_list:GetSelected()[1]:GetColumnText(1) )
				end
			end
			
			xgui_gimp_list = x_makelistview{ x=5, y=50, w=285, h=180, multiselect=false, headerheight=0, parent=xgui_gimp }
			xgui_gimp_list:AddColumn( "Gimp Sayings" )
			xgui_gimp_list.OnRowSelected = function()
				xgui_gimp_button:SetText( "Remove" )
			end
			
			xgui_settings.XGUI_Refresh( "gimps" )
		end
		xgui_ULX_cat1:AddItem( xgui_gimp_button )
		
---------------------------Adverts---------------------------
		local xgui_advert_button = x_makebutton{ h=20, label="Manage Adverts..." }
		xgui_advert_button.DoClick = function()
			if xgui_advert and xgui_advert:IsVisible() then return end
			
			xgui_advert = x_makeframepopup{ label="Manage Adverts", w=325, h=330 }
			xgui_advert_tree = x_maketree{ x=5, y=30, w=120, h=295, parent = xgui_advert }
			xgui_advert_tree.DoClick = function( )
				local node = xgui_advert_tree:GetSelectedItem()
				if node.data then
					xgui_advert_message:SetText( node.data.message )
					xgui_advert_time:SetValue( node.data.rpt )
					if node:GetParentNode() == xgui_advert_tree then
						xgui_advert_group:ChooseOptionID( 1 )
					else
						xgui_advert_group:SetText( node:GetParentNode().Label:GetValue() )
					end
					if node.data.color then
						xgui_csay:SetExpanded( true )
						xgui_csay:InvalidateLayout()
						xgui_display:SetValue( node.data.len )
						RunConsoleCommand( "colour_r", node.data.color.r )
						RunConsoleCommand( "colour_g", node.data.color.g )
						RunConsoleCommand( "colour_b", node.data.color.b )
						RunConsoleCommand( "colour_a", node.data.color.a )
					else
						xgui_csay:SetExpanded( false )
						xgui_csay:InvalidateLayout()
					end
				end
			end
			
			xgui_advert_message = x_maketextbox{ x=130, y=30, w=190, h=20, text="Enter a message...", parent=xgui_advert }
			xgui_advert_message.OnGetFocus = function( self )
				self:SelectAllText()
			end
			
			xgui_advert_time = x_makeslider{ x=130, y=55, w=190, label="Wait Time (seconds)", value=60, min=1, max=1000, tooltip="Time in seconds till the advert is shown", parent=xgui_advert }
			xgui_advert_group = x_makemultichoice{ x=130, y=95, w=190, parent=xgui_advert, tooltip="Pick an existing advert or group to make adverts appear sequentially." }
			
			x_makelabel{ x=135, y=142, label="^-Expand to create a CSay advert-^", parent=xgui_advert }
			
			xgui_csay_items = x_makepanellist{ w=190, h=160, spacing=4, parent=xgui_advert, autosize=false }
			xgui_display = x_makeslider{ label="Display Time (seconds)", min=1, max=60, value=10, tooltip="The time in seconds the CSay advert is displayed", xgui_advert }
				xgui_csay_items:AddItem( xgui_display )
			xgui_csay_items:AddItem( x_makecolorpicker{} )
			xgui_csay = x_makecat{ x=130, y=120, w=190, h=160, label="CSay Advert Options", contents=xgui_csay_items, parent=xgui_advert, expanded=false }
			
			x_makebutton{ x=160, y=305, w=60, label="Add", parent=xgui_advert }.DoClick = function()
				if xgui_advert_group:GetValue() == "<No Group/New Group>" then 
					xgui_temp = nil
				else
					for k, v in pairs( xgui_advert_tree.Items ) do
						if v.Label:GetValue() == xgui_advert_group:GetValue() then
							xgui_temp = v.group
						end
					end
				end
				if xgui_csay:GetExpanded() == true then
					RunConsoleCommand( "xgui", "addAdvert", type( xgui_temp ), xgui_advert_message:GetValue(), xgui_advert_time:GetValue(), xgui_temp or "", GetConVarNumber( "colour_r" ), GetConVarNumber( "colour_g" ), GetConVarNumber( "colour_b" ), GetConVarNumber( "colour_a" ), xgui_display:GetValue() )
				else
					RunConsoleCommand( "xgui", "addAdvert", type( xgui_temp ), xgui_advert_message:GetValue(), xgui_advert_time:GetValue(), xgui_temp or "" )
				end	
			end
			
			x_makebutton{ x=230, y=305, w=60, label="Remove", parent=xgui_advert }.DoClick = function()
				local node = xgui_advert_tree:GetSelectedItem()
				if node and node.data then
					local xgui_temp = node.group
					if node:GetParentNode() ~= xgui_advert_tree then
						xgui_temp = node:GetParentNode().group
					end
					RunConsoleCommand( "xgui", "removeAdvert", xgui_temp, node.data.message, type( node.group ) )
				end
			end
			
			xgui_settings.XGUI_Refresh( "adverts" )
		end
		xgui_ULX_cat1:AddItem( xgui_advert_button )
		
	xgui_ULX:AddItem( x_makecat{ label="ULX Settings", contents=xgui_ULX_cat1, expanded=false } )
	
---------------------------Vote Settings---------------------------
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

---------------------------Log Settings---------------------------
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

---------------------------Reserved Slots Settings---------------------------	
	local xgui_ULX_cat4 = x_makepanellist{ autosize=true }
		xgui_ULX_cat4:AddItem( x_makeslider{ label="Number of Reserved Slots", min=0, max=GetConVarNumber( "sv_maxplayers" ), convar="ulx_cl_rslots" } )
		xgui_ULX_cat4:AddItem( x_makelabel{ label="Reserved Slots Mode", tooltip="0 - Off\n1 - Keep # of slots reserved for admins, admins fill slots\n2 - Keep # of slots reserved for admins, admins don't fill slots, they'll be freed when a player leaves\n3 - Always keep 1 slot open for admins, kick the user with the shortest connection time if an admin joins\nFor more information on reserved slots, check out the ulx server.ini file" } )
		xgui_ULX_cat4:AddItem( x_makemultichoice{ convar="ulx_cl_rslotsMode", convardata={ "0 - Off", "1 - Admins fill slots", "2 - Admins don't fill slots", "3 - Admins kick newest player" } } )
		xgui_ULX_cat4:AddItem( x_makecheckbox{ label="Reserved Slots Visible", convar="ulx_cl_rslotsVisible", tooltip="When enabled, if there are no regular player slots available in your server, it will appear that the server is full.\nThe major downside to this is that admins can't connect to the server using the 'find server' dialog.\nInstead, they have to go to console and use the command 'connect <ip>'" } )
	xgui_ULX:AddItem( x_makecat{ label="Reserved Slots", contents=xgui_ULX_cat4, expanded=false } )

---------------------------XGUI Settings---------------------------
local xgui_GUI = x_makepanellist{ x=395, y=30, w=190, h=200, spacing=1, padding=0, parent=xgui_settings, autosize=false }
	local xgui_GUI_cat1 = x_makepanellist{ autosize=true }
		xgui_GUI_cat1:AddItem( x_makecheckbox{ label="Use XGUI to save settings", tooltip="This doesn't do anything yet" } )
		xgui_GUI_cat1:AddItem( x_makecheckbox{ label="Disable Tooltips", tooltip="This doesn't do anything yet" } )
		xgui_GUI_cat1:AddItem( x_makecheckbox{ label="Send map thumbnails to clients", tooltip="This doesn't do anything yet" } )
		xgui_button_refresh = x_makebutton{ label="Refresh Server Data.." }
		xgui_button_refresh.DoClick=function()
			if xgui_isInstalled then  --We can't be in offline mode to do this
				xgui_hide()
				xgui_hasLoaded = false
				RunConsoleCommand( "xgui", "getdata" )
				xgui_show()
			end
		end
		xgui_GUI_cat1:AddItem( xgui_button_refresh )
	xgui_GUI:AddItem( x_makecat{ label="XGUI Settings", contents=xgui_GUI_cat1, expanded=true } )
	
xgui_settings.XGUI_Refresh = function( arg, data )
	if type( arg ) == "string" then
		if arg == "gimps" then
			if type( data ) == "table" then
				xgui_data.gimps = data
			end
			if xgui_gimp and xgui_gimp:IsVisible() then
				xgui_gimp_list:Clear()
				for k, v in pairs( xgui_data.gimps ) do
					xgui_gimp_list:AddLine( v )
				end
			end
		elseif arg == "adverts" then
			if type( data ) == "table" then
				xgui_data.adverts = data
			end
			if xgui_advert then 
				xgui_advert_tree:Clear()
				xgui_advert_group:Clear()
				xgui_advert_group:AddChoice( "<No Group/New Group>" )
				xgui_advert_group:ChooseOptionID( 1 )
				for group, adverts in pairs( xgui_data.adverts ) do
					if #adverts > 1 then --Check if it's a group or a single advert
						local xgui_temp = xgui_advert_tree:AddNode( group )
						xgui_advert_group:AddChoice( group )
						xgui_temp.Icon:SetImage( "gui/silkicons/folder_go" )
						xgui_temp.group = group
						for advert, data in pairs( adverts ) do
							local node = xgui_temp:AddNode( data.message )
							node.data = data
							node:SetTooltip( data.message )
							if data.color then 
								node.Icon:SetImage( "gui/silkicons/application_view_tile" )
							else
								node.Icon:SetImage( "gui/silkicons/application_view_detail" )
							end
						end
					else
						local node = xgui_advert_tree:AddNode( adverts[1].message )
						xgui_advert_group:AddChoice( adverts[1].message )
						node.data = adverts[1]
						node.group = group
						node:SetTooltip( adverts[1].message )
						if adverts[1].color then
							node.Icon:SetImage( "gui/silkicons/application_view_tile" )
						else
							node.Icon:SetImage( "gui/silkicons/application_view_detail" )
						end
					end
				end
			end
		end
	end
end

table.insert( xgui_modules.tab, { name="Settings", panel=xgui_settings, icon="gui/silkicons/wrench", tooltip=nil, access=nil } )