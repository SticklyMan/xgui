--Server based ULX settings modules for the server_settings tab for XGUI -- by Stickly Man!
--These are added automatically into the category list in the settings -> server tab, and then sorted alphabetically.

-------------------------Admin Votemaps--------------------------
local plist = xlib.makepanellist{ w=285, h=327, parent=xgui.null }
plist:AddItem( xlib.makelabel{ label="Admin Votemap Settings" } )
plist:AddItem( xlib.makeslider{ label="Ratio of votes needed to accept a mapchange", min=0, max=1, decimal=2, repconvar="ulx_cl_votemap2Successratio" } )
plist:AddItem( xlib.makeslider{ label="Minimum votes for a successful mapchange", min=0, max=10, repconvar="ulx_cl_votemap2Minvotes" } )
table.insert( xgui.modules.svsetting, { name="ULX Admin Votemaps", panel=plist, access=nil } )

-----------------------------Adverts-----------------------------
local adverts = xlib.makepanel{ w=285, h=327, parent=xgui.null }
adverts.Paint = function( self )
	draw.RoundedBox( 4, 0, 0, 285, 327, Color( 111, 111, 111, 255 ) )	
end
adverts.tree = xlib.maketree{ x=5, y=5, w=120, h=296, parent=adverts }
adverts.tree.DoClick = function( self, node )
	if node.data then
		adverts.updatebutton:SetDisabled( false )
		adverts.message:SetText( node.data.message )
		adverts.time:SetValue( node.data.rpt )
		if node:GetParentNode() == adverts.tree then
			adverts.group:ChooseOptionID( 1 )
		else
			adverts.group:SetText( node:GetParentNode().Label:GetValue() )
		end
		if node.data.color then
			adverts.csay:SetExpanded( true )
			adverts.csay:InvalidateLayout()
			adverts.display:SetValue( node.data.len )
			RunConsoleCommand( "colour_r", node.data.color.r )
			RunConsoleCommand( "colour_g", node.data.color.g )
			RunConsoleCommand( "colour_b", node.data.color.b )
		else
			adverts.csay:SetExpanded( false )
			adverts.csay:InvalidateLayout()
		end
	else
		adverts.updatebutton:SetDisabled( true )
	end
end
adverts.tree.DoRightClick = function( self, node )
	self:SetSelectedItem( node )
	local menu = DermaMenu()
	if node.data == nil then
		menu:AddOption( "Rename Group...", function() xgui.base.RenameAdvert( node.Label:GetValue() ) end )
	end
	menu:AddOption( "Delete", function() adverts.removeAdvert( node ) end )
	menu:Open()
end
adverts.message = xlib.maketextbox{ x=130, y=5, w=150, h=20, text="Enter a message...", parent=adverts, selectall=true }
adverts.time = xlib.makeslider{ x=130, y=30, w=150, label="Repeat Time (seconds)", value=60, min=1, max=1000, tooltip="Time in seconds till the advert is shown/repeated.", parent=adverts }
adverts.group = xlib.makemultichoice{ x=130, y=70, w=150, parent=adverts, tooltip="Pick an existing advert or group to make adverts appear sequentially." }
xlib.makelabel{ x=138, y=117, label="^-Creates a CSay advert-^", parent=adverts }
local panel = xlib.makepanellist{ h=185, spacing=4, parent=adverts, autosize=false }
adverts.display = xlib.makeslider{ label="Display Time (seconds)", min=1, max=60, value=10, tooltip="The time in seconds the CSay advert is displayed", adverts }
panel:AddItem( adverts.display )
panel:AddItem( xlib.makecolorpicker{ removealpha=true } )
adverts.csay = xlib.makecat{ x=130, y=95, w=150, label="CSay Advert Options", contents=panel, parent=adverts, expanded=false }
xlib.makebutton{ x=192, y=304, w=88, label="Create", parent=adverts }.DoClick = function()
	local group = nil
	local new = false
	if adverts.group:GetValue() ~= "<No Group>" then 
		for k, v in pairs( adverts.tree.Items ) do
			if v.Label:GetValue() == adverts.group:GetValue() then
				group = v.group
				if v.data then --Making a new group with an existing advert
					new = true
				end
			end
		end
	end
	if adverts.csay:GetExpanded() == true then
		RunConsoleCommand( "xgui", "addAdvert", tostring( new ), type( group ), adverts.message:GetValue(), ( adverts.time:GetValue() < 0.1 ) and 0.1 or adverts.time:GetValue(), group or "", GetConVarNumber( "colour_r" ), GetConVarNumber( "colour_g" ), GetConVarNumber( "colour_b" ), 255, adverts.display:GetValue() )
	else
		RunConsoleCommand( "xgui", "addAdvert", tostring( new ), type( group ), adverts.message:GetValue(), ( adverts.time:GetValue() < 0.1 ) and 0.1 or adverts.time:GetValue(), group or "" )
	end
end
xlib.makebutton{ x=5, y=304, w=88, label="Remove", parent=adverts }.DoClick = function( node )
	adverts.removeAdvert( adverts.tree:GetSelectedItem() )
end
adverts.updatebutton = xlib.makebutton{ x=98, y=304, w=89, label="Update", parent=adverts, disabled=true }
adverts.updatebutton.DoClick = function( node )
	local node = adverts.tree:GetSelectedItem()
	if adverts.csay:GetExpanded() == true then
		RunConsoleCommand( "xgui", "updateAdvert", type( node.group ), node.group, node.number, adverts.message:GetValue(), ( adverts.time:GetValue() < 0.1 ) and 0.1 or adverts.time:GetValue(), adverts.display:GetValue(), GetConVarNumber( "colour_r" ), GetConVarNumber( "colour_g" ), GetConVarNumber( "colour_b" ) )
	else
		RunConsoleCommand( "xgui", "updateAdvert", type( node.group ), node.group, node.number, adverts.message:GetValue(), ( adverts.time:GetValue() < 0.1 ) and 0.1 or adverts.time:GetValue() )
	end
end
function adverts.removeAdvert( node )
	if node then
		Derma_Query( "Are you sure you want to delete this " .. ( node.data and "advert?" or "advert group?" ), "XGUI WARNING", 
		"Delete", function() 
			if node.data then --Remove a single advert
				RunConsoleCommand( "xgui", "removeAdvert", node.group, node.number, type( node.group ) )
			else --Remove an advert group
				RunConsoleCommand( "xgui", "removeAdvertGroup", node.group, type( node.group ) )
			end
		end, "Cancel", function() end )
	end
end
function xgui.base.RenameAdvert( old, isNew )
	local advertRename
	if isNew then
		advertRename = xlib.makeframe{ label="Set Name of New Advert Group", w=400, h=80, showclose=false, skin=xgui.settings.skin }
	else
		advertRename = xlib.makeframe{ label="Set Name of Advert Group - " .. old, w=400, h=80, showclose=true, skin=xgui.settings.skin }
	end
	advertRename.text = xlib.maketextbox{ x=10, y=30, w=380, h=20, text=old, parent=advertRename }
	advertRename.text.OnEnter = function( self )
		RunConsoleCommand( "xgui", "renameAdvertGroup", old, isNew and "true" or "false", unpack( string.Explode( " ", self:GetValue() ) ) )
		advertRename:Remove()
	end
	xlib.makebutton{ x=175, y=55, w=50, label="OK", parent=advertRename }.DoClick = function()
		advertRename.text:OnEnter()
	end
end
function adverts.updateAdverts()
	adverts.updatebutton:SetDisabled( true )
	adverts.tree:Clear()
	adverts.group:Clear()
	adverts.group:AddChoice( "<No Group>" )
	adverts.group:ChooseOptionID( 1 )
	for group, advertgroup in pairs( xgui.data.adverts ) do
		if #advertgroup > 1 then --Check if it's a group or a single advert
			local xgui_temp = adverts.tree:AddNode( group )
			adverts.group:AddChoice( group )
			xgui_temp.Icon:SetImage( "gui/silkicons/folder_go" )
			xgui_temp.group = group
			for advert, data in ipairs( advertgroup ) do
				local node = xgui_temp:AddNode( data.message )
				node.data = data
				node.group = group
				node.number = advert
				node:SetTooltip( data.message )
				if data.color then 
					node.Icon:SetImage( "gui/silkicons/application_view_tile" )
				else
					node.Icon:SetImage( "gui/silkicons/application_view_detail" )
				end
			end
		else
			local node = adverts.tree:AddNode( advertgroup[1].message )
			adverts.group:AddChoice( advertgroup[1].message )
			node.data = advertgroup[1]
			node.group = group
			node.number = 1
			node:SetTooltip( advertgroup[1].message )
			if advertgroup[1].color then
				node.Icon:SetImage( "gui/silkicons/application_view_tile" )
			else
				node.Icon:SetImage( "gui/silkicons/application_view_detail" )
			end
		end
	end
	adverts.tree:InvalidateLayout()
end
function adverts.onOpen()
	ULib.queueFunctionCall( adverts.tree.InvalidateLayout, adverts.tree )
end
table.insert( xgui.hook["adverts"], adverts.updateAdverts )
table.insert( xgui.modules.svsetting, { name="ULX Adverts", panel=adverts, access=nil } )

------------------------------Echo-------------------------------
local plist = xlib.makepanellist{ w=285, h=327, parent=xgui.null }
plist:AddItem( xlib.makelabel{ label="Command/Event Echo Settings" } )
plist:AddItem( xlib.makecheckbox{ label="Echo players vote choices", repconvar="ulx_cl_voteEcho" } )
plist:AddItem( xlib.makemultichoice{ repconvar="ulx_cl_logEcho", isNumberConvar=true, choices={ "Do not echo admin commands", "Echo admin commands anonymously", "Echo commands and identify admin" } } )
plist:AddItem( xlib.makemultichoice{ repconvar="ulx_cl_logSpawnsEcho", isNumberConvar=true, choices={ "Do not echo spawns", "Echo spawns to admins only", "Echo spawns to everyone" } } )
table.insert( xgui.modules.svsetting, { name="ULX Command/Event Echos", panel=plist, access=nil } )

------------------------General Settings-------------------------
local plist = xlib.makepanellist{ w=285, h=327, parent=xgui.null }
plist:AddItem( xlib.makelabel{ label="General ULX Settings" } )
plist:AddItem( xlib.makeslider{ label="Chat spam time", min=0, max=5, decimal=1, repconvar="ulx_cl_chattime" } )
plist:AddItem( xlib.makelabel{ label="\nMOTD Settings" } )
--Very custom convar handling for ulx_cl_shotMotd
plist.motdEnabled = xlib.makecheckbox{ label="Show MOTD when players join" }
function plist.motdEnabled:Toggle() self.Button:DoClick() end
plist.motdEnabled.Button.DoClick = function( self )
	self:Toggle()
	local bVal = self:GetChecked()
	if bVal == true then
		if plist.motdURLEnabled:GetChecked() then
			RunConsoleCommand( "ulx_cl_showMotd", plist.motdURLText:GetValue() )
		else
			RunConsoleCommand( "ulx_cl_showMotd", "1" )
		end
	else
		RunConsoleCommand( "ulx_cl_showMotd", "0" )
	end
end
plist.motdURLEnabled = xlib.makecheckbox{ label="Get MOTD from URL instead of motd.txt:" }

function plist.motdURLEnabled:Toggle() self.Button:DoClick() end
plist.motdURLEnabled.Button.DoClick = function( self )
	self:Toggle()
	local bVal = self:GetChecked()
	if bVal == true then
		if plist.motdURLText:GetValue() ~= "" then
			RunConsoleCommand( "ulx_cl_showMotd", plist.motdURLText:GetValue() )
		end
		plist.motdURLText:SetDisabled( false )
	else
		RunConsoleCommand( "ulx_cl_showMotd", "1" )
		plist.motdURLText:SetDisabled( true )
	end
end
plist.motdURLText = xlib.maketextbox{ selectall=true }
function plist.motdURLText:UpdateConvarValue()
	if plist.motdURLText:GetValue() ~= "" then
		RunConsoleCommand( "ulx_cl_showMotd", self:GetValue() )
	end
end
function plist.motdURLText:OnEnter() self:UpdateConvarValue() end
function plist.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
	if cl_cvar == "ulx_cl_showMotd" then
		if tonumber( new_val ) == nil then --MOTD is enabled and set to a URL 
			plist.motdEnabled:SetValue( 1 )
			plist.motdURLEnabled:SetValue( 1 )
			plist.motdURLEnabled:SetDisabled( false )
			plist.motdURLText:SetValue( new_val )
			plist.motdURLText:SetDisabled( false )
		else
			plist.motdEnabled:SetValue( new_val )
			if new_val == "1" then
				plist.motdURLEnabled:SetValue( 0 )
				plist.motdURLEnabled:SetDisabled( false )
				plist.motdURLText:SetDisabled( true )
			elseif new_val == "0" then
				plist.motdURLEnabled:SetDisabled( true )
				plist.motdURLText:SetDisabled( true )
			end
		end
	end
end
plist.afterOpened = function()
	if plist.motdURLEnabled:GetDisabled() then
		ULib.queueFunctionCall( plist.motdURLEnabled.SetDisabled, plist.motdURLEnabled, true ) --Since the DCheckBox doesn't properly show itself as Disabled on startup, we have to set it here.
	end
end
hook.Add( "ULibReplicatedCvarChanged", "XGUI_ulx_cl_showMotd", plist.ConVarUpdated )
plist:AddItem( plist.motdEnabled )
plist:AddItem( plist.motdURLEnabled )
plist:AddItem( plist.motdURLText )
plist:AddItem( xlib.makelabel{ label="\nWelcome Message:" } )
plist:AddItem( xlib.maketextbox{ repconvar="ulx_cl_welcomemessage", selectall=true } )
plist:AddItem( xlib.makelabel{ label="Allowed variables: %curmap%, %host%" } )
table.insert( xgui.modules.svsetting, { name="ULX General Settings", panel=plist, access=nil } )

------------------------------Gimps------------------------------
local gimps = xlib.makepanel{ w=285, h=327, parent=xgui.null }
gimps.textbox = xlib.maketextbox{ w=235, h=20, parent=gimps, selectall=true }
gimps.textbox.OnEnter = function( self )
	if self:GetValue() then
		RunConsoleCommand( "xgui", "addGimp", self:GetValue() )
		self:SetText( "" )
	end
end
gimps.textbox.OnGetFocus = function( self )
	gimps.button:SetText( "Add" )
	self:SelectAllText()
	xgui.anchor:SetKeyboardInputEnabled( true )
end
gimps.button = xlib.makebutton{ x=235, w=50, label="Add", parent=gimps }
gimps.button.DoClick = function( self )
	if self:GetValue() == "Add" then
		gimps.textbox:OnEnter()
	elseif gimps.list:GetSelectedLine() then
		RunConsoleCommand( "xgui", "removeGimp", gimps.list:GetSelected()[1]:GetColumnText(1) )
	end
end
gimps.list = xlib.makelistview{ y=20, w=285, h=307, multiselect=false, headerheight=0, parent=gimps }
gimps.list:AddColumn( "Gimp Sayings" )
gimps.list.OnRowSelected = function()
	gimps.button:SetText( "Remove" )
end
gimps.updateGimps = function()
	gimps.list:Clear()
	for k, v in pairs( xgui.data.gimps ) do
		gimps.list:AddLine( v )
	end
end
table.insert( xgui.hook["gimps"], gimps.updateGimps )
table.insert( xgui.modules.svsetting, { name="ULX Gimps", panel=gimps, access=nil } )

--------------------------Log Settings---------------------------
local plist = xlib.makepanellist{ w=285, h=327, parent=xgui.null }
plist:AddItem( xlib.makelabel{ label="Logging Settings" } )
plist:AddItem( xlib.makecheckbox{ label="Enable Logging to Files", repconvar="ulx_cl_logFile" } )
plist:AddItem( xlib.makecheckbox{ label="Log Chat", repconvar="ulx_cl_logChat" } )
plist:AddItem( xlib.makecheckbox{ label="Log Player Events (Connects, Deaths, etc.)", repconvar="ulx_cl_logEvents" } )
plist:AddItem( xlib.makecheckbox{ label="Log Spawns (Props, Effects, Ragdolls, etc.)", repconvar="ulx_cl_logSpawns" } )
plist:AddItem( xlib.makelabel{ label="Save log files to this directory:" } )
local logdirbutton = xlib.makebutton{}
if GetConVar( "ulx_cl_logDir" ) == nil then
	CreateConVar( "ulx_cl_logDir", 0 ) --Replicated cvar hasn't been created via ULib. Create a temporary one to prevent errors
else
	logdirbutton:SetText( "data/" .. GetConVar( "ulx_cl_logDir" ):GetString() )
end
function logdirbutton.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
	if cl_cvar == "ulx_cl_logDir" then
		logdirbutton:SetText( "data/" .. new_val )
	end
end
hook.Add( "ULibReplicatedCvarChanged", "XGUI_ulx_cl_logDir", logdirbutton.ConVarUpdated )
plist:AddItem( logdirbutton )
table.insert( xgui.modules.svsetting, { name="ULX Logs", panel=plist, access=nil } )

---------------------Player Votemap Settings---------------------
local plist = xlib.makepanellist{ w=285, h=327, parent=xgui.null }
plist:AddItem( xlib.makelabel{ label="Player Votemap Settings" } )
plist:AddItem( xlib.makecheckbox{ label="Enable Player Votemaps", repconvar="ulx_cl_votemapEnabled" } )
plist:AddItem( xlib.makeslider{ label="Time (min) before a user can vote for a map", min=0, max=300, repconvar="ulx_cl_votemapMintime" } )
plist:AddItem( xlib.makeslider{ label="Time (min) until a user can change their vote", min=0, max=60, decimal=1, repconvar="ulx_cl_votemapWaitTime" } )
plist:AddItem( xlib.makeslider{ label="Ratio of votes needed to accept mapchange", min=0, max=1, decimal=2, repconvar="ulx_cl_votemapSuccessratio" } )
plist:AddItem( xlib.makeslider{ label="Minimum votes for a successful mapchange", min=0, max=10, repconvar="ulx_cl_votemapMinvotes" } )
plist:AddItem( xlib.makeslider{ label="Time (sec) for an admin to veto a mapchange", min=0, max=300, repconvar="ulx_cl_votemapVetotime" } )
table.insert( xgui.modules.svsetting, { name="ULX Player Votemap Settings", panel=plist, access=nil } )

-----------------------Player Votemap List-----------------------
local panel = xlib.makepanel{ w=285, h=327, parent=xgui.null }
panel.Paint = function( self )
	draw.RoundedBox( 4, 0, 0, 285, 327, Color( 111, 111, 111, 255 ) )	
end
xlib.makelabel{ label="Allowed Votemaps", x=5, y=3, parent=panel }
xlib.makelabel{ label="Excluded Votemaps", x=150, y=3, parent=panel }
panel.votemaps = xlib.makelistview{ y=20, w=140, h=267, multiselect=true, headerheight=0, parent=panel }
panel.votemaps:AddColumn( "" )
panel.votemaps.OnRowSelected = function()
	panel.add:SetDisabled( true )
	panel.remove:SetDisabled( false )
	panel.remainingmaps:ClearSelection()
end
panel.remainingmaps = xlib.makelistview{ x=145, y=20, w=140, h=267, multiselect=true, headerheight=0, parent=panel }
panel.remainingmaps:AddColumn( "" )
panel.remainingmaps.OnRowSelected = function()
	panel.add:SetDisabled( false )
	panel.remove:SetDisabled( true )
	panel.votemaps:ClearSelection()
end
panel.remove = xlib.makebutton{ y=287, w=140, label="Remove -->", disabled=true, parent=panel }
panel.remove.DoClick = function()
	panel.remove:SetDisabled( true )
	local temp = {}
	for _, v in ipairs( panel.votemaps:GetSelected() ) do
		table.insert( temp, v:GetColumnText(1) )
	end
	RunConsoleCommand( "xgui", "removeVotemaps", unpack( temp ) )
end
panel.add = xlib.makebutton{ x=145, y=287, w=140, label="<-- Add", disabled=true, parent=panel }
panel.add.DoClick = function()
	panel.add:SetDisabled( true )
	local temp = {}
	for _, v in ipairs( panel.remainingmaps:GetSelected() ) do
		table.insert( temp, v:GetColumnText(1) )
	end
	RunConsoleCommand( "xgui", "addVotemaps", unpack( temp ) )
end
panel.votemapmode = xlib.makemultichoice{ y=307, w=285, repconvar="ulx_cl_votemapMapmode", isNumberConvar=true, numOffset=0, choices={ "Include new maps by default", "Exclude new maps by default" }, parent=panel }
panel.updateList = function()
	if #ulx.maps ~= 0 then
		panel.votemaps:Clear()
		panel.remainingmaps:Clear()
		panel.add:SetDisabled( true )
		panel.remove:SetDisabled( true )
		for _, v in ipairs( ulx.maps ) do
			if table.HasValue( ulx.votemaps, v ) then
				panel.votemaps:AddLine( v )
			else
				panel.remainingmaps:AddLine( v )
			end
		end
	end
end
table.insert( xgui.hook["votemaps"], panel.updateList )
table.insert( xgui.modules.svsetting, { name="ULX Player Votemap List", panel=panel, access=nil } )

-------------------------Reserved Slots--------------------------
local plist = xlib.makepanellist{ w=285, h=327, parent=xgui.null }
plist:AddItem( xlib.makelabel{ label="Reserved Slots Settings" } )
plist:AddItem( xlib.makemultichoice{ repconvar="ulx_cl_rslotsMode", isNumberConvar=true, choices={ "0 - Reserved slots disabled", "1 - Admins fill slots", "2 - Admins don't fill slots", "3 - Admins kick newest player" } } )
plist:AddItem( xlib.makeslider{ label="Number of Reserved Slots", min=0, max=GetConVarNumber( "sv_maxplayers" ), repconvar="ulx_cl_rslots" } )
plist:AddItem( xlib.makecheckbox{ label="Reserved Slots Visible", repconvar="ulx_cl_rslotsVisible" } )
plist:AddItem( xlib.makelabel{ label="Reserved slots mode info:\n1 - Set a certain number of slots reserved for admins--\n     As admins join, they will fill up these slots.\n2 - Same as #1, but admins will not fill the slots-- they'll\n     be freed when players leave.\n3 - Always keep 1 slot open for admins, and, if full, kick\n     the user with the shortest connection time when an\n     admin joins, thus keeping 1 slot open.\n\nReserved Slots Visible:\n     When enabled, if there are no regular player slots\n     available in your server, it will appear that the server\n     is full. The major downside to this is that admins can't\n     connect to the server using the 'find server' dialog.\n     Instead, they have to go to console and use the\n     command 'connect <ip>'" } )
table.insert( xgui.modules.svsetting, { name="ULX Reserved Slots", panel=plist, access=nil } )

------------------------Votekick/Voteban-------------------------
local plist = xlib.makepanellist{ w=285, h=327, parent=xgui.null }
plist:AddItem( xlib.makelabel{ label="Votekick Settings" } )
plist:AddItem( xlib.makeslider{ label="Ratio of votes needed to accept votekick", min=0, max=1, decimal=2, repconvar="ulx_cl_votekickSuccessratio" } )
plist:AddItem( xlib.makeslider{ label="Minimum votes required for a successful votekick", min=0, max=10, repconvar="ulx_cl_votekickMinvotes" } )
plist:AddItem( xlib.makelabel{ label="\nVoteban Settings" } )
plist:AddItem( xlib.makeslider{ label="Ratio of votes needed to accept voteban", min=0, max=1, decimal=2, repconvar="ulx_cl_votebanSuccessratio" } )
plist:AddItem( xlib.makeslider{ label="Minimum votes required for a successful voteban", min=0, max=10, repconvar="ulx_cl_votebanMinvotes" } )
table.insert( xgui.modules.svsetting, { name="ULX Votekick/Voteban", panel=plist, access=nil } )