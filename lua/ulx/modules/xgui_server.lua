--Server stuff for the GUI for ULX --by Stickly Man!

xgui = {}

Msg( "///////////////////////////////\n" )
Msg( "// ULX GUI -- by Stickly Man //\n" )
Msg( "///////////////////////////////\n" )
Msg( "// Adding GUI Modules..      //\n" )
for _, file in ipairs( file.FindInLua( "ulx/xgui/*.lua" ) ) do
	AddCSLuaFile( "ulx/xgui/" .. file )
	Msg( "//  " .. file .. string.rep( " ", 25 - file:len() ) .. "//\n" )
end

Msg( "// Adding Setting Modules..  //\n" )
for _, file in ipairs( file.FindInLua( "ulx/xgui/settings/*.lua" ) ) do
	AddCSLuaFile( "ulx/xgui/settings/" .. file )
	Msg( "//  " .. file .. string.rep( " ", 25 - file:len() ) .. "//\n" )
end

Msg( "// Adding Gamemode Modules.. //\n" )
for _, file in ipairs( file.FindInLua( "ulx/xgui/gamemodes/*.lua" ) ) do
	AddCSLuaFile( "ulx/xgui/gamemodes/" .. file )
	Msg( "//  " .. file .. string.rep( " ", 25 - file:len() ) .. "//\n" )
end
Msg( "// XGUI modules added!       //\n" )
Msg( "///////////////////////////////\n" )

--This is for servers with scriptenforcer enabled.
--It will force scriptenforcer to allow these files to be included on the client where they weren't included by default.
AddCSLuaFile( "menu/progressbar.lua" )
AddCSLuaFile( "sandbox/gamemode/spawnmenu/controls/CtrlColor.lua" )

function xgui.init()
	
	--Chat commands for people who loooove chat commands!
	local function xgui_chatCommand( ply, func, args )
		ULib.clientRPC( ply, "xgui.show", args )
	end
	ULib.addSayCommand(	"!xgui", xgui_chatCommand, "ulx help" )
	ULib.addSayCommand(	"!menu", xgui_chatCommand, "ulx help" )
	
	local function xgui_banWindowChat( ply, func, args )
		if args[1] and args[1] ~= "" then
			local target = ULib.getUser( args[1] )
			if target then
				ULib.clientRPC( ply, "xgui.ShowBanWindow", target:Nick(), target:SteamID(), false )
			end
		else
			ULib.clientRPC( ply, "xgui.ShowBanWindow" )
		end
	end
	ULib.addSayCommand(	"!xban", xgui_banWindowChat, "ulx ban" )

	local function xgui_banWindowChatFreeze( ply, func, args )
		if args[1] and args[1] ~= "" then
			local target = ULib.getUser( args[1] )
			if target then
				ULib.clientRPC( ply, "xgui.ShowBanWindow", target:Nick(), target:SteamID(), true )
			end
		else
			ULib.clientRPC( ply, "xgui.ShowBanWindow" )
		end
	end
	ULib.addSayCommand(	"!fban", xgui_banWindowChatFreeze, "ulx ban" )

	--XGUI specific Accesses
	ULib.ucl.registerAccess( "xgui_gmsettings", "superadmin", "Allows changing of gamemode-specific settings on the settings tab in XGUI.", "XGUI" )
	ULib.ucl.registerAccess( "xgui_svsettings", "superadmin", "Allows changing of server and ULX-specific settings on the settings tab in XGUI.", "XGUI" )
	ULib.ucl.registerAccess( "xgui_managegroups", "superadmin", "Allows managing of groups, users, and access strings via the groups tab in XGUI.", "XGUI" )
	ULib.ucl.registerAccess( "xgui_managebans", "superadmin", "Allows addition, removal, and viewing of bans in XGUI.", "XGUI" )

	--Here we will use ULib to replicate the server settings so that anyone with access can change them (not just listen server host or rcon!)
	ULib.replicatedWritableCvar( "sv_voiceenable", "rep_sv_voiceenable", GetConVarNumber( "sv_voiceenable" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "sv_alltalk", "rep_sv_alltalk", GetConVarNumber( "sv_alltalk" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "ai_disabled", "rep_ai_disabled", GetConVarNumber( "ai_disabled" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "ai_keepragdolls", "rep_ai_keepragdolls", GetConVarNumber( "ai_keepragdolls" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "ai_ignoreplayers", "rep_ai_ignoreplayers", GetConVarNumber( "ai_ignoreplayers" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "sv_gravity", "rep_sv_gravity", GetConVarNumber( "sv_gravity" ), false, false, "xgui_svsettings" )
	ULib.replicatedWritableCvar( "phys_timescale", "rep_phys_timescale", GetConVarNumber( "phys_timescale" ), false, false, "xgui_svsettings" )

	--Sandbox stuff
	ULib.replicatedWritableCvar( "physgun_limited", "rep_physgun_limited", GetConVarNumber( "physgun_limited" ), false, false, "xgui_gmsettings" )
	ULib.replicatedWritableCvar( "sbox_noclip", "rep_sbox_noclip", GetConVarNumber( "sbox_noclip" ), false, false, "xgui_gmsettings" )
	ULib.replicatedWritableCvar( "sbox_godmode", "rep_sbox_godmode", GetConVarNumber( "sbox_godmode" ), false, false, "xgui_gmsettings" )
	ULib.replicatedWritableCvar( "sbox_plpldamage", "rep_sbox_plpldamage", GetConVarNumber( "sbox_plpldamage" ), false, false, "xgui_gmsettings" )
	ULib.replicatedWritableCvar( "sbox_weapons", "rep_sbox_weapons", GetConVarNumber( "sbox_weapons" ), false, false, "xgui_gmsettings" )

	--Get the list of known Sandbox Cvar Limits
	function xgui.cvarcallback( contents, size )
		if size < 2900 then --This means that we probably got a 404 or other HTTP error, in other words, the server is down!
			xgui.cvarFileStatus = 0
		else
			file.Write( "ulx/sbox_limits.txt", contents )
			xgui.cvarFileStatus = 1
		end
	end
	http.Get( "http://ulyssesmod.net/xgui/sbox_cvars.txt", "", xgui.cvarcallback )


	--Process the list of known Sandbox Cvar Limits and check if they exist
	function xgui.processCvars()
		xgui.sboxLimits = {}
		if ULib.isSandbox() then
			local curgroup
			local f = file.Read( "ulx/sbox_limits.txt" )
			local lines = string.Explode( "\n", f )
			for i,v in ipairs( lines ) do
				if v:sub( 1,1 ) ~= ";" then
					if v:sub( 1,1 ) == "|" then
						curgroup = table.insert( xgui.sboxLimits, {} )
						xgui.sboxLimits[curgroup].title = v:sub( 2 )
					else
						local data = string.Explode( " ", v ) --Split Convar name from max limit
						if ConVarExists( data[1] ) then
							--We need to create a replicated cvar so the clients can manipulate/view them:
							ULib.replicatedWritableCvar( data[1], "rep_" .. data[1], GetConVarNumber( data[1] ), false, false, "xgui_gmsettings" )
							--Add to the list of cvars to send to the client
							table.insert( xgui.sboxLimits[curgroup], v )
						end
					end
				end
			end
			if xgui.sendLimits then
				for _, v in ipairs( player.GetAll() ) do
					xgui.sendData( v, {[1]="sboxlimits"} )
				end
				xgui.sendLimits = nil
			end
		end
		hook.Remove( "ULibLocalPlayerReady", "xgui_processCvars" )
	end
	hook.Add( "ULibLocalPlayerReady", "xgui_processCvars", xgui.processCvars )
	
	function xgui.splitbans()
		xgui.sourcebans = {}
		xgui.ulxbans = {}
		for k, v in pairs( ULib.bans ) do
			if v.time == nil then
				xgui.sourcebans[k] = v
			else
				xgui.ulxbans[k] = v
			end
		end
	end
	
	--Duplicate ULX's UTeam table (required for how Megiddo stores team data within the groups data)
	xgui.teams = table.Copy( ulx.teams )
	
	--Load empty teams saved by XGUI (if any)
	if file.Exists( "ulx/empty_teams.txt" ) then
		local input = file.Read( "ulx/empty_teams.txt" )
		input = input:match( "^.-\n(.*)$" )
		local emptyteams = ULib.parseKeyValues( input )
		for _, teamdata in ipairs( emptyteams ) do
			table.insert( xgui.teams, teamdata.order, teamdata )
		end
	end
	
	--Check and make sure the teams have an order
	function xgui.setTeamsOrder()
		for i, v in ipairs( xgui.teams ) do
			v.order = i --Assign based on their index, which should be in order set by the file
		end
	end
	
	--Uteam doesn't load the shortname for playermodels, so to make it easier for the GUI, check for model paths and see if we can use a shortname instead.
	for _, v in ipairs( xgui.teams ) do
		if v.model then
			for shortname,modelpath in pairs( player_manager.AllValidModels() ) do
				if v.model == modelpath then v.model = shortname break end
			end
		end
	end
	
	--Combine access data into one table.
	xgui.accesses = {}
	for k, v in pairs( ULib.ucl.accessStrings ) do
		xgui.accesses[k] = {}
		xgui.accesses[k].hStr = v
	end
	for k, v in pairs( ULib.ucl.accessCategories ) do
		xgui.accesses[k].cat = v
	end
	
	xgui.DATA_TYPES = { "votemaps", "sboxlimits", "adverts", "gimps", "users", "teams", "accesses", "bans", "sbans", "playermodels" } 
	
	--Function hub! All server functions can be called via concommand xgui!
	function xgui.cmd( ply, func, args )
		local branch=args[1]
		table.remove( args, 1 )
		if branch == "getdata" then xgui.sendData( ply, args )
		elseif branch == "setinheritance" then xgui.setInheritance( ply, args )
		elseif branch == "addGimp" then xgui.addGimp( ply, args )
		elseif branch == "removeGimp" then xgui.removeGimp( ply, args )
		elseif branch == "addAdvert" then xgui.addAdvert( ply, args )
		elseif branch == "removeAdvert" then xgui.removeAdvert( ply, args )
		elseif branch == "removeAdvertGroup" then xgui.removeAdvertGroup( ply, args )
		elseif branch == "renameAdvertGroup" then xgui.renameAdvertGroup( ply, args )
		elseif branch == "updateAdvert" then xgui.updateAdvert( ply, args )
		elseif branch == "addVotemaps" then xgui.addVotemaps( ply, args )
		elseif branch == "removeVotemaps" then xgui.removeVotemaps( ply, args )
		elseif branch == "getVetoState" then xgui.getVetoState( ply, args )
		elseif branch == "updateBan" then xgui.updateBan( ply, args )
		elseif branch == "refreshBans" then ULib.refreshBans() xgui.ULXCommandCalled( nil, "ulx banid" )
		elseif branch == "updateTeamValue" then xgui.updateTeamValue( ply, args )
		elseif branch == "createTeam" then xgui.createTeam( ply, args )
		elseif branch == "removeTeam" then xgui.removeTeam( ply, args )
		elseif branch == "changeGroupTeam" then xgui.changeGroupTeam( ply, args )
		elseif branch == "getInstalled" then ply:SendLua( "xgui.getInstalled()" ) xgui.sendData( ply, {} ) --Lets the client know that the server has XGUI, then begins sending data
		elseif branch == "dataComplete" then xgui.chunksFinished( ply )
		end
	end
	concommand.Add( "_xgui", xgui.cmd )
	
	xgui.activeUsers = {}  --Set up a table to list users who are actively transferring data
	function xgui.sendData( ply, args, extdata )
		--If no args are specified, then update everything!
		if #args == 0 then 
			args = xgui.DATA_TYPES
		end

		--Perform a check to make see if the client is already being sent data OR data sending is currently restricted.
		--If it is, then add the new values to be updated to the players "queue" (if they aren't already there)
		if xgui.activeUsers[ply] ~= nil then
			for _,arg in ipairs(args) do
				local exists = false
				for _,existingArg in ipairs(xgui.activeUsers[ply]) do
					if arg == existingArg then exists=true break end
				end
				if exists ~= true then table.insert( xgui.activeUsers[ply], arg ) end
			end
			return
		end

		local chunks = {}
		for _, u in ipairs( args ) do
			if u == "votemaps" then --Update Votemaps
				local t = {}
				for _, v in ipairs( ulx.votemaps ) do
					table.insert( t, v )
				end
				table.insert( chunks, { t, "votemaps" } )
			elseif u == "gimps" then --Update GimpSays
				if ply:query( "xgui_svsettings" ) then
					table.insert( chunks, { ulx.gimpSays, "gimps" } )
				end
			elseif u == "adverts" then --Update Adverts
				if ply:query( "xgui_svsettings" ) then
					table.insert( chunks, { ulx.adverts, "adverts" } )
				end
			elseif u == "users" then --Update Users
				if ply:query( "xgui_managegroups" ) then
					table.insert( chunks, { ULib.ucl.users, "users" } )
				end
			elseif u == "sboxlimits" then --Update Sandbox Cvar Limits
				if ply:query( "xgui_gmsettings" ) then
					if xgui.sboxLimits ~= nil then
						if ULib.isSandbox() then
							table.insert( chunks, { xgui.sboxLimits, "sboxlimits" } )
						end
					else
						xgui.sendLimits = true --The sboxlimits haven't arrived yet, raise a flag for them to be sent when they do.
					end
				end
			elseif u == "playermodels" then
				if ply:query( "xgui_managegroups" ) then
					table.insert( chunks, { player_manager.AllValidModels(), "playermodels" } )
				end
			elseif u == "teams" then --Update XGUI's team info.
				if ply:query( "xgui_managegroups" ) then
					table.insert( chunks, { xgui.teams, "teams" } )
				end
				elseif u == "accesses" then --Update ULib's Access String information
				if ply:query( "xgui_managegroups" ) then
					table.insert( chunks, { xgui.accesses, "accesses" } )
				end
			elseif u == "bans" then --Update ULX Bans
				if ply:query( "xgui_managebans" ) then
					--Send 25 bans per chunk
					local i = 1
					local t = {}
					for ID, data in pairs( xgui.ulxbans ) do
						t[ID] = data
						i = i + 1
						if i > 25 then 
							table.insert( chunks, { t, "bans" } )
							t = {}
							i = 1
						end
					end
					table.insert( chunks, { t, "bans" } )
				end
			elseif u == "sbans" then --Update SOURCE Bans
				if ply:query( "xgui_managebans" ) then
					--Send 25 sbans per chunk
					--Since source doesn't save any bans that have a timelimit, the only valuable information we need per ban is the STEAMID.
					local i = 1
					local t = {}
					for ID, _ in pairs( xgui.sourcebans ) do
						table.insert( t, ID )
						i = i + 1
						if i > 25 then 
							table.insert( chunks, { t, "sbans" } )
							t = {}
							i = 1
						end
					end
					table.insert( chunks, { t, "sbans" } )
				end
			end
		end
		if #chunks ~= 0 then xgui.doChunks( ply, chunks, args ) end
	end

	function xgui.doChunks( ply, chunks, args )
		ply:SendLua( "xgui.expectChunks(" .. #chunks .. ", {\"" .. table.concat( args, "\", \"" ) .. "\"})" )
		xgui.activeUsers[ply] = {}
		for cur, chunk in ipairs( chunks ) do
			ULib.queueFunctionCall( ULib.clientRPC, ply, "xgui.getChunk", chunk[1], chunk[2] )
		end
	end

	function xgui.chunksFinished( ply )
		if #xgui.activeUsers[ply] > 0 then --Data has been requested while the player was already transferring data
			local temp = xgui.activeUsers[ply]
			xgui.activeUsers[ply] = nil
			xgui.sendData( ply, temp )
		else
			xgui.activeUsers[ply] = nil
		end
	end

	function xgui.setInheritance( ply, args )
		if ply:query( "ulx addgroup" ) then
			--Check for cycles
			local group = ULib.ucl.groupInheritsFrom( args[2] )
			while group do
				if group == args[1] or args[1] == args[2] then
					ply:SendLua( "Derma_Message( \"Cyclical inheritance detected! You cannot inherit from something you're inheriting to!\", \"XGUI NOTICE\" )" )
					ply:SendLua( "xgui_group_inherit:SetText(\"<none>\")" )
					return
				end
				group = ULib.ucl.groupInheritsFrom( group )
			end
			ULib.ucl.setGroupInheritance( args[1], args[2] )
		end
	end

	function xgui.addGimp( ply, args )
		if ply:query( "xgui_svsettings" ) then
			ulx.addGimpSay( args[1] )
			for _, v in ipairs( player.GetAll() ) do
				if v:query( "xgui_svsettings" ) then
					xgui.sendData( v, {[1]="gimps"} )
				end
			end
			xgui.saveGimps()
		end
	end

	function xgui.removeGimp( ply, args )
		if ply:query( "xgui_svsettings" ) then
			for a, b in ipairs( ulx.gimpSays ) do
				if b == args[1] then
					table.remove( ulx.gimpSays, a )
					for _, v in ipairs( player.GetAll() ) do
						if v:query( "xgui_svsettings" ) then
							xgui.sendData( v, {[1]="gimps"} )
						end
					end
					xgui.saveGimps()
					return nil
				end
			end
		end
	end

	function xgui.saveGimps()
		local orig_file = file.Read( "ulx/gimps.txt" )
		local comment = xgui.getCommentHeader( orig_file )

		local new_file = comment

		for i, gimpSay in ipairs( ulx.gimpSays ) do
			new_file = new_file .. gimpSay .. "\n"
		end
		
		file.Write( "ulx/gimps.txt", new_file )
	end

	function xgui.saveAdverts()
		local orig_file = file.Read( "ulx/adverts.txt" )
		local comment = xgui.getCommentHeader( orig_file )
		local new_file = comment
		
		for group_name, group_data in pairs( ulx.adverts ) do
			local output = ""
			for i, data in ipairs( group_data ) do
				if not data.color then -- Must be a tsay advert
					output = output .. string.format( '%q %q\n', data.message, data.rpt )
				else -- Must be a csay advert
					output = output .. string.format( '%q\n{\n\t"red" %q\n\t"green" %q\n\t"blue" %q\n\t"time_on_screen" %q\n\t"time" %q\n}\n',
						data.message, data.color.r, data.color.g, data.color.b, data.len, data.rpt )
				end
			end
			
			if type( group_name ) ~= "number" then
				output = string.format( "%q\n{\n\t%s}\n", group_name, output:gsub( "\n", "\n\t" ) )
			end
			new_file = new_file .. output		
		end
		
		file.Write( "ulx/adverts.txt", new_file )
	end

	function xgui.renameAdvertGroup( ply, args )
		if ply:query( "xgui_svsettings" ) then
			local old = args[1]
			local isNewGroup = tobool( args[2] )
			table.remove( args, 1 )
			table.remove( args, 1 )
			local new = table.concat( args, " " )
			if ulx.adverts[old] then
				if not ulx.adverts[new] then
					for k, v in pairs( ulx.adverts[old] ) do
						ulx.addAdvert( v.message, v.rpt, new, v.color, v.len )
					end
					xgui.removeAdvertGroup( ply, { old, type( k ) } )
				end
			end
		end
	end

	function xgui.addAdvert( ply, args )
		if ply:query( "xgui_svsettings" ) then
			local group = nil
			if tobool( args[1] ) then --If a new group is being created, then run special code, otherwise just add the new advert
				local i = 1
				while ulx.adverts["Group " .. i] do i=i+1 end
				group = "Group " .. i
				local old = ( args[2] == "number" ) and tonumber( args[5] ) or args[5]
				for k, v in pairs( ulx.adverts[old] ) do
					ulx.addAdvert( v.message, v.rpt, group, v.color, v.len )
				end
				xgui.removeAdvertGroup( ply, { old, args[2] }, true )
				--Open the clientside messagebox to rename the new group
				if args[2] == "number" then  --Sometimes single adverts have a groupname applied to them from an old group. If one exists, display that for the suggested name.
					ply:SendLua( "xgui.base.RenameAdvert( \"" .. group .. "\", true )" )
				else
					ply:SendLua( "xgui.base.RenameAdvert( \"" .. old .. "\", true )" )
				end
			else
				if args[5] ~= "" then
					group = ( args[2] == "number" ) and tonumber( args[5] ) or args[5]
				end
			end
			local color = ( args[6]~=nil ) and { r = tonumber( args[6] ), g = tonumber( args[7] ), b = tonumber( args[8] ), a = tonumber( args[9] ) } or nil
			ulx.addAdvert( args[3], tonumber( args[4] ), group, color, tonumber( args[10] ) )
			for _, v in ipairs( player.GetAll() ) do
				xgui.sendData( v, {[1]="adverts"} )
			end
			xgui.saveAdverts()
		end
	end

	function xgui.removeAdvertGroup( ply, args, hold )
		if ply:query( "xgui_svsettings" ) then
			local group = ( args[2] == "number" ) and tonumber( args[1] ) or args[1]
			for i=#ulx.adverts[group],1,-1 do
				xgui.removeAdvert( ply, { group, i, args[2] }, true )
			end
			if not hold then
				for _, v in ipairs( player.GetAll() ) do
					xgui.sendData( v, {[1]="adverts"} )
				end
				xgui.saveAdverts()
			end
		end
	end

	function xgui.updateAdvert( ply, args )
		if ply:query( "xgui_svsettings" ) then
			local group = ( args[1] == "number" ) and tonumber( args[2] ) or args[2]
			local number = tonumber( args[3] )
			local advert = ulx.adverts[group][number]
			advert.message = args[4]
			advert.rpt = tonumber( args[5] )
			advert.len = tonumber( args[6] )
			if args[7] then
				advert.color = { a=255, r=tonumber( args[7] ), g=tonumber( args[8] ), b=tonumber( args[9] ) }
			else
				advert.color = nil
			end
			for _, v in ipairs( player.GetAll() ) do
				xgui.sendData( v, {[1]="adverts"} )
			end
			xgui.saveAdverts()
		end
	end

	function xgui.removeAdvert( ply, args, hold )
		if ply:query( "xgui_svsettings" ) then
			local group = ( args[3] == "number" ) and tonumber( args[1] ) or args[1]
			local number = tonumber( args[2] )
			if number == #ulx.adverts[group] then
				ulx.adverts[group].removed_last = true
			end
			table.remove( ulx.adverts[group], number )
			if #ulx.adverts[group] == 0 then --Remove the existing group if no other adverts exist
				ulx.adverts[group] = nil
				timer.Remove( "ULXAdvert" .. type( group ) .. group )
			end
			if not hold then
				for _, v in ipairs( player.GetAll() ) do
					xgui.sendData( v, {[1]="adverts"} )
				end
				xgui.saveAdverts()
			end
		end
	end

	function xgui.addVotemaps( ply, args )
		if ply:query( "xgui_svsettings" ) then
			for _, votemap in ipairs( args ) do
				table.insert( ulx.votemaps, votemap )
			end
		end
		for _, v in ipairs( player.GetAll() ) do
			xgui.sendData( v, {[1]="votemaps"} )
		end
		xgui.saveVotemaps( GetConVar( "ulx_votemapMapmode" ):GetInt() )
	end

	function xgui.removeVotemaps( ply, args )
		if ply:query( "xgui_svsettings" ) then
			for _, votemap in ipairs( args ) do
				for i, map in ipairs( ulx.votemaps ) do
					if map == votemap then
						table.remove( ulx.votemaps, i )
						break
					end
				end
			end
		end
		for _, v in ipairs( player.GetAll() ) do
			xgui.sendData( v, {[1]="votemaps"} )
		end
		xgui.saveVotemaps( GetConVar( "ulx_votemapMapmode" ):GetInt() )
	end

	function xgui.saveVotemaps( mapmode )
		local orig_file = file.Read( "ulx/votemaps.txt" )
		local comment = xgui.getCommentHeader( orig_file )
		local new_file = comment

		if mapmode == 1 then --Use all maps EXCEPT what's specified in votemaps.txt
			for _, map in ipairs( ulx.maps ) do
				if not table.HasValue( ulx.votemaps, map ) then
					new_file = new_file .. map .. "\n"
				end
			end
		elseif mapmode == 2 then --Use only the maps specified in votemaps.txt
			for _, map in ipairs( ulx.votemaps ) do
				new_file = new_file .. map .. "\n"
			end
		else 
			Msg( "XGUI: Could not save votemaps- Invalid or nonexistent ulx_votemapMapmode cvar!\n" ) --Don't error here, it breaks the hook X|
			return
		end
		
		file.Write( "ulx/votemaps.txt", new_file )
	end
	
	function xgui.getVetoState( ply, args )
		if ply:query( "ulx veto" ) then
			local enabled = "false"
			if ulx.timedVeto then enabled = "true" end
			ply:SendLua( "xgui.updateVetoButton( " .. enabled .. ")" )
		end
	end
	
	function xgui.updateVetoState()
		for _, v in ipairs( player.GetAll() ) do
			xgui.getVetoState( v )
		end
	end
	hook.Add( "ULXVetoChanged", "XGUI_ServerCatchVeto", xgui.updateVetoState )
	
	function xgui.removeTeam( ply, args )
		if ply:query( "xgui_managegroups" ) then
			for i, v in ipairs( xgui.teams ) do
				if v.name == args[1] then
					for _,group in ipairs( v.groups ) do --Unassign groups in team being deleted
						xgui.changeGroupTeam( ply, { group, "" }, true )
					end
					table.remove( xgui.teams, i )
					xgui.setTeamsOrder()
					xgui.refreshTeams()
					break
				end
			end
		end
	end
	
	function xgui.createTeam( ply, args )
		if ply:query( "xgui_managegroups" ) then
			--Check and make sure the team doesn't exist first
			local exists = false
			for i, v in ipairs( xgui.teams ) do
				if v.name == args[1] then
					exists = true
				end
			end
			if not exists then
				local team = {}
				team.name = args[1]
				team.color = Color( args[2], args[3], args[4], 255 )
				team.order = #xgui.teams+1
				team.groups = {}
				table.insert( xgui.teams, team )
				xgui.refreshTeams()
			end
		end
	end
	
	function xgui.changeGroupTeam( ply, args, norefresh )
		if ply:query( "xgui_managegroups" ) then
			local group = args[1]
			local newteam = args[2]
			local resettable = {}
			for _,teamdata in ipairs( xgui.teams ) do
				for i,groupname in ipairs( teamdata.groups ) do
					if group == groupname then --Found the previous team the group belonged to, remove it now!
						table.remove( teamdata.groups, i )
						--Grab old modifier info while we're here
						for modifier, _ in pairs( teamdata ) do
							if modifier ~= "order" and modifier ~= "index" and modifier ~= "groups" and modifier ~= "name" and modifier ~= "color" then
								table.insert( resettable, modifier )
							end
						end						
						break
					end
				end
				if teamdata.name == newteam then --If the team requested was found, then add it to the new team.
					table.insert( teamdata.groups, group )
				end
			end
			--Reset modifiers for affected players, then let UTeam set the new modifiers
			xgui.resetTeamValue( group, resettable )
			if not norefresh then
				xgui.refreshTeams()
			end
		end
	end
	
	function xgui.updateTeamValue( ply, args )
		if ply:query( "xgui_managegroups" ) then
			args[3] = tonumber( args[3] ) or args[3] --If args[3] is a number, turn it into one.
			for k, v in ipairs( xgui.teams ) do
				if v.name == args[1] then
					if args[2] == "color" then
						v.color = { r=tonumber(args[3]), g=tonumber(args[4]), b=tonumber(args[5]), a=255 }
					else
						if args[3] ~= "" then
							v[args[2]] = args[3]
						else
							v[args[2]] = nil
							--Set the players back to the original value
							for _, group in ipairs( v.groups ) do
								xgui.resetTeamValue( group, { args[2] } )
							end
						end
					end
					--Check for order updates, only refresh the teams when args[4] flag is set to prevent multiple data sendings
					if v[args[2]] ~= "order" or args[4] == "true" then
						xgui.refreshTeams()
					end
					break
				end
			end
		end
	end
	
	function xgui.refreshTeams()
		ulx.teams = table.Copy( xgui.teams )
		ulx.saveTeams() --Let ULX reprocess the teams (Empty/new teams would be lost here)
		ulx.refreshTeams()
		table.sort( xgui.teams, function(a, b) return a.order < b.order end ) --Sort table by order.
		for _, v in ipairs( player.GetAll() ) do
			xgui.sendData( v, {[1]="teams"} )
		end
		--Save any teams that don't have a group assigned to it to a special file. (They'll be removed on changelevel if we don't)
		local emptyteams = {}
		for _, teamdata in ipairs( xgui.teams ) do
			if #teamdata.groups == 0 then
				table.insert( emptyteams, teamdata )
			end
		end
		if #emptyteams > 0 then
			local output = "//This file stores teams that do not have any groups assigned to it (Since ULX would discard them). Do not edit this file!\n"
			output = output .. ULib.makeKeyValues( emptyteams )
			file.Write( "ulx/empty_teams.txt", output )
		else
			if file.Exists( "ulx/empty_teams.txt" ) then
				file.Delete( "ulx/empty_teams.txt" )
			end
		end
	end
	
	xgui.teamDefaults = { 
		armor = 0,
		crouchedWalkSpeed = 0.6,
		deaths = 0,
		duckSpeed = 0.3,
		frags = 0,
		gravity = 1,
		health = 100,
		jumpPower = 160,
		maxHealth = 100,
		maxSpeed = 250,
		model = "kleiner",
		runSpeed = 500,
		stepSize = 18,
		unDuckSpeed = 0.2,
		walkSpeed = 250 }

	--This function will locate all players affected by team modifier(s) being unset (or team being changed)
	--and will reset any related modifiers to their defaults.
	function xgui.resetTeamValue( group, values )
		for _, ply in ipairs( player.GetAll() ) do
			if ply:GetUserGroup() == group then 
				for _, modifier in ipairs( values ) do
					--Code from UTeam
					ply[ "Set" .. modifier:sub( 1, 1 ):upper() .. modifier:sub( 2 ) ]( ply, xgui.teamDefaults[modifier] )
				end
			end
		end
	end
	
	function xgui.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
		if cl_cvar == "ulx_cl_votemapMapmode" then
			xgui.saveVotemaps( tonumber( new_val ) )
		end
	end
	hook.Add( "ULibReplicatedCvarChanged", "XGUI_ServerCatchCvar", xgui.ConVarUpdated )
	
	--Create timers that will automatically refresh clent's banlists when a users ban runs out. Polls hourly.
	function xgui.unbanTimer()
		timer.Simple( 3600, xgui.unbanTimer )
		for ID, data in pairs( xgui.ulxbans ) do
			if tonumber( data.unban ) ~= 0 then
				if tonumber( data.unban ) - os.time() <= 3600 then
					if not timer.IsTimer( "xgui_unban" .. ID ) then
						timer.Create( "xgui_unban" .. ID, tonumber( data.unban ) - os.time(), 1, function() timer.Destroy( "xgui_unban" .. ID ) ULib.refreshBans() xgui.ULXCommandCalled( nil, "ulx banid" ) end )
					end
				end
			end
		end
	end

	function xgui.updateBan( ply, args )
		if ply:query( "ulx ban" ) or ply:query( "ulx banid" ) then
			local steamID = args[1]
			if not ULib.bans[steamID] then return end
			if args[5] == "true" then --Is a sourceban conversion
				xgui.ULXCommandCalled( nil, "ulx unban", { nil, steamID } ) --Call this to update the players' source ban lists.
			end
			local bantime = tonumber( args[2] )
			if bantime == nil then
				if ULib.bans[steamID].unban ~= 0 then
					bantime = (ULib.bans[steamID].unban - ULib.bans[steamID].time)/60
				else
					bantime = 0
				end
			end
			local reason = args[3]
			if reason == "" then
				reason = ULib.bans[steamID].reason
			end
			local name = args[4]
			if name == "" then
				name = ULib.bans[steamID].name
			end
			ULib.addBan( steamID, bantime, reason, name, ply )
			xgui.ULXCommandCalled( nil, "ulx ban" )
		end
	end

	--This will check for ULX functions and delegate appropriate actions based on which commands were called
	--Ex. When someone uses ulx ban, call the clients to refresh the appropriate data
	function xgui.ULXCommandCalled( ply, cmdName, args )
		-- Recheck the bans if a ban was removed
		if cmdName == "ulx unban" then xgui.splitbans() end
		
		--Resend data based on commands called
		for _, v in ipairs( player.GetAll() ) do
			if cmdName == "ulx unban" then
				if v:query( "xgui_managebans" ) then
					ULib.clientRPC( v, "xgui.callRefresh", "onUnban", args[2] )
					if timer.IsTimer( "xgui_unban" .. args[2] ) then
						timer.Destroy( "xgui_unban" .. args[2] )
					end
				end
			elseif cmdName == "ulx addgroup" or cmdName == "ulx removegroup" or cmdName == "ulx renamegroup" or cmdName == "ulx adduser" or cmdName == "ulx adduserid" or cmdName == "ulx removeuser" then
				if v ~= args[2] then  --The affected player is already regrabbing the data
					xgui.sendData( v, {[1]="users"} )
				end
			end
		end
	end
	hook.Add( "ULibPostTranslatedCommand", "XGUI_HookULXCommand", xgui.ULXCommandCalled )
	
	--Hijack the addBan function to send new ban information to players.
	local banfunc = ULib.addBan
	ULib.addBan = function( steamid, time, reason, name, admin )
		banfunc( steamid, time, reason, name, admin )
		xgui.splitbans()
		xgui.unbanTimer()
		for _, v in ipairs( player.GetAll() ) do
			if v:query( "xgui_managebans" ) then
				ULib.clientRPC( v, "xgui.callRefresh", "updateBan", { [steamid] = ULib.bans[steamid] } )
			end
		end
	end
	
	--Hijack the renameGroup and removeGroup ULib functions to properly update team information when these are called.
	local tempfunc = ULib.ucl.renameGroup
	ULib.ucl.renameGroup = function( orig, new )
		for _, teamdata in ipairs( xgui.teams ) do
			for i, groupname in ipairs( teamdata.groups ) do
				if groupname == orig then
					teamdata.groups[i] = new
				end
				break
			end
		end
		tempfunc( orig, new )
		xgui.refreshTeams()
	end
	
	local otherfunc = ULib.ucl.removeGroup
	ULib.ucl.removeGroup = function( name )
		for _, teamdata in ipairs( xgui.teams ) do
			for i, groupname in ipairs( teamdata.groups ) do
				if groupname == name then
					table.remove( teamdata.groups, i )
				end
				break
			end
		end
		otherfunc( name )
		xgui.refreshTeams()
	end
	
	--Misc Stuff
	function xgui.getCommentHeader( data, comment_char )
		comment_char = comment_char or ";"
		local lines = ULib.explode( "\n", data )
		local end_comment_line = 0
		for _, line in ipairs( lines ) do
			local trimmed = line:Trim()
			if trimmed == "" or trimmed:sub( 1, 1 ) == comment_char then
				end_comment_line = end_comment_line + 1
			else
				break
			end
		end

		local comment = table.concat( lines, "\n", 1, end_comment_line )
		if comment ~= "" then comment = comment .. "\n" end
		return comment
	end

	xgui.splitbans() --Once the functions are loaded, call functions that need to be run
	xgui.unbanTimer() --(Prevents XGUI from being partially loaded in case of an error)
	xgui.setTeamsOrder()
end
--Init the code after ULX is done loading, to prevent strange errors
hook.Add( ulx.HOOK_ULXDONELOADING, "XGUI_InitServer", xgui.init )