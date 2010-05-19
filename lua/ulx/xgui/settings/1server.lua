--Server settings module for ULX GUI -- by Stickly Man!
--Modify server and ULX based settings.

local server_settings = x_makeXpanel{ parent=xgui.null }


x_makecheckbox{ x=10, y=10, label="Enable Voice Chat", convar="rep_sv_voiceenable", parent=server_settings, textcolor=color_black }
x_makecheckbox{ x=10, y=30, label="Enable Alltalk", convar="rep_sv_alltalk", parent=server_settings, textcolor=color_black }
x_makecheckbox{ x=10, y=50, label="Disable AI", convar="rep_ai_disabled", parent=server_settings, textcolor=color_black }
x_makecheckbox{ x=10, y=70, label="AI Ignore Players", convar="rep_ai_ignoreplayers", parent=server_settings, textcolor=color_black }
if SinglePlayer() then
	x_makecheckbox{ x=10, y=90, label="Keep AI Ragdolls", convar="rep_ai_keepragdolls", parent=server_settings, textcolor=color_black }
end
x_makeslider{ x=10, y=110, w=125, label="sv_gravity", min=-1000, max=1000, convar="rep_sv_gravity", parent=server_settings, textcolor=color_black }
x_makeslider{ x=10, y=150, w=125, label="phys_timescale", min=0, max=4, decimal=2, convar="rep_phys_timescale", parent=server_settings, textcolor=color_black }

x_makepanellist{ x=5, y=190, w=145, h=142, parent=server_settings }
x_makecheckbox{ x=10, y=195, label="Show MOTD", convar="ulx_cl_showMotd", parent=server_settings }
x_makeslider{ x=10, y=215, w=125, label="Chat Spam Time", min=0, max=5, decimal=1, convar="ulx_cl_chattime", parent=server_settings }
x_makebutton{ x=10, y=255, w=125, height=20, label="Set Welcome Message...", parent=server_settings }.DoClick = function()
	local wm = x_makeframepopup{ label="Set Welcome Message", w=400, h=60 }
	wm.text = x_maketextbox{ x=10, y=30, w=380, h=20, text=GetConVar( "ulx_welcomemessage" ):GetString(), parent=wm }
	wm.text.OnEnter = function()
		RunConsoleCommand( "ulx", "welcomemessage", xgui_wm_text:GetValue() )
		wm:Remove()
	end
end

--------------------------Gimps----------------------------		
x_makebutton{ x=10, y=280, h=20, w=125, label="Manage Gimp Sayings...", parent=server_settings }.DoClick = function()
	if server_settings.gimp and server_settings.gimp:IsVisible() then return end
	
	server_settings.gimp = x_makeframepopup{ label="Manage Gimp Sayings", w=295, h=235 }
	
	server_settings.gimp.textbox = x_maketextbox{ x=5, y=30, w=235, h=20, parent=server_settings.gimp }
	server_settings.gimp.textbox.OnEnter = function()
		if server_settings.gimp.textbox:GetValue() then
			RunConsoleCommand( "xgui", "addGimp", server_settings.gimp.textbox:GetValue() )
			server_settings.gimp.textbox:SetText( "" )
		end
	end
	server_settings.gimp.textbox.OnGetFocus = function( self )
		server_settings.gimp.button:SetText( "Add" )
		self:SelectAllText()
	end
	
	server_settings.gimp.button = x_makebutton{ x=240, y=30, w=50, label="Add", parent=server_settings.gimp }
	server_settings.gimp.button.DoClick = function( self )
		if self:GetValue() == "Add" then
			server_settings.gimp.textbox.OnEnter()
		elseif server_settings.gimp.list:GetSelectedLine() then
			RunConsoleCommand( "xgui", "removeGimp", server_settings.gimp.list:GetSelected()[1]:GetColumnText(1) )
		end
	end
	
	server_settings.gimp.list = x_makelistview{ x=5, y=50, w=285, h=180, multiselect=false, headerheight=0, parent=server_settings.gimp }
	server_settings.gimp.list:AddColumn( "Gimp Sayings" )
	server_settings.gimp.list.OnRowSelected = function()
		server_settings.gimp.button:SetText( "Remove" )
	end
	
	server_settings.updateGimps()
end

function server_settings.updateGimps()
	if server_settings.gimp and server_settings.gimp:IsVisible() then
		server_settings.gimp.list:Clear()
		for k, v in pairs( xgui.data.gimps ) do
			server_settings.gimp.list:AddLine( v )
		end
	end
end

-------------------------Adverts---------------------------
x_makebutton{ x=10, y=305, h=20, w=125, label="Manage Adverts...", parent=server_settings }.DoClick = function()
	if server_settings.advert and server_settings.advert:IsVisible() then return end
	
	server_settings.advert = x_makeframepopup{ label="Manage Adverts", w=325, h=330 }
	server_settings.advert.tree = x_maketree{ x=5, y=30, w=120, h=295, parent=server_settings.advert }
	server_settings.advert.tree.DoClick = function( )
		local node = server_settings.advert.tree:GetSelectedItem()
		if node.data then
			server_settings.advert.message:SetText( node.data.message )
			server_settings.advert.time:SetValue( node.data.rpt )
			if node:GetParentNode() == server_settings.advert.tree then
				server_settings.advert.group:ChooseOptionID( 1 )
			else
				server_settings.advert.group:SetText( node:GetParentNode().Label:GetValue() )
			end
			if node.data.color then
				server_settings.advert.csay:SetExpanded( true )
				server_settings.advert.csay:InvalidateLayout()
				server_settings.advert.display:SetValue( node.data.len )
				RunConsoleCommand( "colour_r", node.data.color.r )
				RunConsoleCommand( "colour_g", node.data.color.g )
				RunConsoleCommand( "colour_b", node.data.color.b )
				RunConsoleCommand( "colour_a", node.data.color.a )
			else
				server_settings.advert.csay:SetExpanded( false )
				server_settings.advert.csay:InvalidateLayout()
			end
		end
	end
	
	server_settings.advert.message = x_maketextbox{ x=130, y=30, w=190, h=20, text="Enter a message...", parent=server_settings.advert }
	server_settings.advert.message.OnGetFocus = function( self )
		self:SelectAllText()
	end
	
	server_settings.advert.time = x_makeslider{ x=130, y=55, w=190, label="Wait Time (seconds)", value=60, min=1, max=1000, tooltip="Time in seconds till the advert is shown", parent=server_settings.advert }
	server_settings.advert.group = x_makemultichoice{ x=130, y=95, w=190, parent=server_settings.advert, tooltip="Pick an existing advert or group to make adverts appear sequentially." }
	
	x_makelabel{ x=135, y=142, label="^-Expand to create a CSay advert-^", parent=server_settings.advert }
	
	local csay_items = x_makepanellist{ w=190, h=160, spacing=4, parent=server_settings.advert, autosize=false }
	server_settings.advert.display = x_makeslider{ label="Display Time (seconds)", min=1, max=60, value=10, tooltip="The time in seconds the CSay advert is displayed", server_settings.advert }
		csay_items:AddItem( server_settings.advert.display )
	csay_items:AddItem( x_makecolorpicker{} )
	server_settings.advert.csay = x_makecat{ x=130, y=120, w=190, h=160, label="CSay Advert Options", contents=csay_items, parent=server_settings.advert, expanded=false }
	
	x_makebutton{ x=160, y=305, w=60, label="Add", parent=server_settings.advert }.DoClick = function()
		local xgui_temp = nil
		if server_settings.advert.group:GetValue() ~= "<No Group/New Group>" then 
			for k, v in pairs( server_settings.advert.tree.Items ) do
				if v.Label:GetValue() == server_settings.advert.group:GetValue() then
					xgui_temp = v.group
				end
			end
		end
		if server_settings.advert.csay:GetExpanded() == true then
			RunConsoleCommand( "xgui", "addAdvert", type( xgui_temp ), server_settings.advert.message:GetValue(), server_settings.advert.time:GetValue(), xgui_temp or "", GetConVarNumber( "colour_r" ), GetConVarNumber( "colour_g" ), GetConVarNumber( "colour_b" ), GetConVarNumber( "colour_a" ), server_settings.advert.display:GetValue() )
		else
			RunConsoleCommand( "xgui", "addAdvert", type( xgui_temp ), server_settings.advert.message:GetValue(), server_settings.advert.time:GetValue(), xgui_temp or "" )
		end	
	end
	
	x_makebutton{ x=230, y=305, w=60, label="Remove", parent=server_settings.advert }.DoClick = function()
		local node = server_settings.advert.tree:GetSelectedItem()
		if node and node.data then
			local xgui_temp = node.group
			if node:GetParentNode() ~= server_settings.advert.tree then
				xgui_temp = node:GetParentNode().group
			end
			RunConsoleCommand( "xgui", "removeAdvert", xgui_temp, node.data.message, type( node.group ) )
		end
	end
	
	server_settings.updateAdverts()
end

server_settings.updateAdverts = function()
	if server_settings.advert and server_settings.advert:IsVisible() then 
		server_settings.advert.tree:Clear()
		server_settings.advert.group:Clear()
		server_settings.advert.group:AddChoice( "<No Group/New Group>" )
		server_settings.advert.group:ChooseOptionID( 1 )
		for group, adverts in pairs( xgui.data.adverts ) do
			if #adverts > 1 then --Check if it's a group or a single advert
				local xgui_temp = server_settings.advert.tree:AddNode( group )
				server_settings.advert.group:AddChoice( group )
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
				local node = server_settings.advert.tree:AddNode( adverts[1].message )
				server_settings.advert.group:AddChoice( adverts[1].message )
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

local plist = x_makepanellist{ x=145, y=5, w=210, h=327, parent=server_settings }
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
plist:AddItem( x_makeslider{ label="Votemap2 Minimum Votes", min=0, max=10, convar="ulx_cl_votemap2Minvotes" } ) -- TODO: Screw sliders, do two numberwangs: one percentage of votes, the other #min votes

table.insert( xgui.modules.setting, { name="Server", panel=server_settings, icon="gui/silkicons/application", tooltip=nil, access="xgui_svsettings" } )
table.insert( xgui.hook["adverts"], server_settings.updateAdverts )
table.insert( xgui.hook["gimps"], server_settings.updateGimps )