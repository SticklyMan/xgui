--Server stuff for the GUI for ULX --by Stickly Man!
Msg( "///////////////////////////////\n" )
Msg( "// ULX GUI -- by Stickly Man //\n" )
Msg( "///////////////////////////////\n" )
Msg( "// Adding GUI Modules..      //\n" )

local xgui_module_files = file.FindInLua( "ulx/modules/cl/gui_modules/*.lua" )

for _, file in ipairs( xgui_module_files ) do
	AddCSLuaFile( "ulx/modules/cl/gui_modules/" .. file )
	Msg( "//  " .. file .. string.rep( " ", 25 - file:len() ) .. "//\n" )
end

Msg( "// GUI Modules Added!        //\n" )
Msg( "///////////////////////////////\n" )

--Chat command for people who loove chat commands!
function xgui_chatCommand( ply )
	ply:SendLua( "xgui_show()" )
end
ULib.addSayCommand(	"!xgui", xgui_chatCommand, "ulx" )

--XGUI specific Accesses
ULib.ucl.registerAccess( "xgui_gmsettings", "superadmin", "Allows changing of gamemode-specific settings on the settings tab in XGUI." )
ULib.ucl.registerAccess( "xgui_svsettings", "superadmin", "Allows changing of server-specific settings on the settings tab in XGUI." )
ULib.ucl.registerAccess( "xgui_ulxsettings", "superadmin", "Allows changing of ULX-specific settings on the settings tab in XGUI." )
ULib.ucl.registerAccess( "xgui_managegroups", "superadmin", "Allows managing of groups, users, and access strings via the groups tab in XGUI." )
ULib.ucl.registerAccess( "xgui_managebans", "superadmin", "Allows addition, removal, and viewing of bans in XGUI." )

--Here we will use ULib to replicate the server settings so that anyone with access can change them (not just listen server host or rcon!)
ULib.replicatedWritableCvar( "sbox_noclip", "sbox_cl_noclip", GetConVarNumber( "sbox_noclip" ), false, false, "xgui_gmsettings" )
ULib.replicatedWritableCvar( "sbox_godmode", "sbox_cl_godmode", GetConVarNumber( "sbox_godmode" ), false, false, "xgui_gmsettings" )
ULib.replicatedWritableCvar( "sbox_plpldamage", "sbox_cl_plpldamage", GetConVarNumber( "sbox_plpldamage" ), false, false, "xgui_gmsettings" )
ULib.replicatedWritableCvar( "sbox_weapons", "sbox_cl_weapons", GetConVarNumber( "sbox_weapons" ), false, false, "xgui_gmsettings" )

ULib.replicatedWritableCvar( "sv_voiceenable", "sv_cl_voiceenable", GetConVarNumber( "sv_voiceenable" ), false, false, "xgui_svsettings" )
ULib.replicatedWritableCvar( "sv_alltalk", "sv_cl_alltalk", GetConVarNumber( "sv_alltalk" ), false, false, "xgui_svsettings" )
ULib.replicatedWritableCvar( "ai_disabled", "ai_cl_disabled", GetConVarNumber( "ai_disabled" ), false, false, "xgui_svsettings" )
ULib.replicatedWritableCvar( "ai_keepragdolls", "ai_cl_keepragdolls", GetConVarNumber( "ai_keepragdolls" ), false, false, "xgui_svsettings" )
ULib.replicatedWritableCvar( "ai_ignoreplayers", "ai_cl_ignoreplayers", GetConVarNumber( "ai_ignoreplayers" ), false, false, "xgui_svsettings" )
ULib.replicatedWritableCvar( "sv_gravity", "sv_cl_gravity", GetConVarNumber( "sv_gravity" ), false, false, "xgui_svsettings" )
ULib.replicatedWritableCvar( "phys_timescale", "phys_cl_timescale", GetConVarNumber( "phys_timescale" ), false, false, "xgui_svsettings" )
ULib.replicatedWritableCvar( "physgun_limited", "cl_physgun_limited", GetConVarNumber( "physgun_limited" ), false, false, "xgui_svsettings" )

--Function hub! All server functions can be called via concommand xgui!
function xgui_cmd( ply, func, args )
	--Lets the client know that the server has XGUI
	ply:SendLua( "xgui_isInstalled = true" )
	
	local branch=args[1]
	table.remove( args, 1 )
	if branch == "getdata" then xgui_sendData( ply, args )
	elseif branch == "setinheritance" then xgui_setInheritance( ply, args )
	elseif branch == "addGimp" then xgui_addGimp( ply, args )
	elseif branch == "removeGimp" then xgui_removeGimp( ply, args )
	elseif branch == "addAdvert" then xgui_addAdvert( ply, args )
	elseif branch == "removeAdvert" then xgui_removeAdvert( ply, args )
	elseif branch == "removeUserID" then xgui_removeUserID( ply, args )
	elseif branch == "updateBanName" then xgui_UpdateBanName( ply, args )
	elseif branch == "refreshBans" then ULib.refreshBans() xgui_ULXCommandCalled( nil, "ulx banid" )
	end
end
concommand.Add( "_xgui", xgui_cmd )

function xgui_sendData( ply, args )
	local xgui_data = {}
	
	--Prevents opening menu while data is being sent!
	ply:SendLua( "xgui_hasLoaded = false" )
	
	--If no args are specified, then update everything!
	if #args == 0 then args = { "gamemodes", "votemaps", "maps", "gimps", "adverts", "users", "bans" } end
	for _, u in ipairs( args ) do
		if u == "gamemodes" then --Update Gamemodes 
			xgui_data.gamemodes = {}
			local dirs = file.FindDir( "../gamemodes/*" )
			for _, dir in pairs( dirs ) do
				if file.Exists( "../gamemodes/" .. dir .. "/info.txt" ) and not util.tobool( util.KeyValuesToTable( file.Read( "../gamemodes/" .. dir .. "/info.txt" ) ).hide ) then
					table.insert( xgui_data.gamemodes, dir )
				end
			end
		elseif u == "votemaps" then --Update Votemaps
			xgui_data.votemaps = {}
			for _, v in pairs( ulx.votemaps ) do
				table.insert( xgui_data.votemaps, v )
			end
		elseif u == "maps" then --Update Full List of Server Maps
			if ply:query( "ulx map" ) or ply:query( "ulx_cl_votemapEnabled" ) then
				xgui_data.maps = ulx.maps
			end
		elseif u == "gimps" then --Update GimpSays
			if ply:query( "xgui_ulxsettings" ) then
				xgui_data.gimps = ulx.gimpSays
			end
		elseif u == "adverts" then --Update Adverts
			if ply:query( "xgui_ulxsettings" ) then
				xgui_data.adverts = ulx.adverts
			end
		elseif u == "users" then --Update Users
			if ply:query( "xgui_managegroups" ) then
				xgui_data.users = ULib.ucl.users
			end
		elseif u == "bans" then --Update Bans
			if ply:query( "xgui_managebans" ) then
				xgui_data.bans = ULib.bans
			end
		end
	end
	--ULIb will quickly and easily send the data to the client!
	ULib.clientRPC( ply, "xgui_RecieveData", xgui_data )
end

function xgui_setInheritance( ply, args )
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

function xgui_addGimp( ply, args )
	if ply:query( "xgui_ulxsettings" ) then
		ulx.addGimpSay( args[1] )
		for _, v in pairs( player.GetAll() ) do
			if v:query( "xgui_ulxsettings" ) then
				ULib.clientRPC( v, "xgui_settings.XGUI_Refresh", "gimps", ulx.gimpSays )
			end
		end
	end
end

function xgui_removeGimp( ply, args )
	if ply:query( "xgui_ulxsettings" ) then
		for a, b in ipairs( ulx.gimpSays ) do
			if b == args[1] then
				table.remove( ulx.gimpSays, a )
				for _, v in pairs( player.GetAll() ) do
					if v:query( "xgui_ulxsettings" ) then
						ULib.clientRPC( v, "xgui_settings.XGUI_Refresh", "gimps", ulx.gimpSays )
					end
				end
				return nil
			end
		end
	end
end

function xgui_addAdvert( ply, args )
	if ply:query( "xgui_ulxsettings" ) then
		if args[4] == "" then args[4] = nil end
		if args[1] == "number" then -- Ungrouped advert, Make a new group and move the ungrouped advert into it
			local i = 1
			while ulx.adverts["Group " .. i] ~= nil do
				i=i+1
			end
			ulx.adverts["Group " .. i] = { {} }
			for k, v in pairs( ulx.adverts[tonumber( args[4] )][1] ) do
				ulx.adverts["Group " .. i][1][k] = v
			end
			table.remove( ulx.adverts, tonumber( args[4] ) )
			timer.Remove( "ULXAdvert" .. "number" .. tonumber( args[4] ) )
			args[4] = "Group " .. i
		end
		if args[5] == nil then
			ulx.addAdvert( args[2], tonumber( args[3] ), args[4] )
		else
			ulx.addAdvert( args[2], tonumber( args[3] ), args[4], { r = tonumber( args[5] ), g = tonumber( args[6] ), b = tonumber( args[7] ), a = tonumber( args[8] ) }, tonumber( args[9] ) )
		end
		for _, v in pairs( player.GetAll() ) do
			if v:query( "xgui_ulxsettings" ) then
				ULib.clientRPC( v, "xgui_settings.XGUI_Refresh", "adverts", ulx.adverts )
			end
		end
		return nil
	end
end

function xgui_removeAdvert( ply, args ) --node.group, node.data.message, type( node.group )
	if ply:query( "xgui_ulxsettings" ) then
		if args[3] == "number" then args[1] = tonumber( args[1] ) end
		for groupname, advertgroup in pairs( ulx.adverts ) do
			for num, data in pairs( advertgroup ) do
				if groupname == args[1] and data.message == args[2] then
					table.remove( advertgroup, num )
					if next( advertgroup ) == nil then
						ulx.adverts[groupname] = nil
						timer.Remove( "ULXAdvert" .. type( groupname ) .. groupname )
					end
					for _, v in pairs( player.GetAll() ) do
						if v:query( "xgui_ulxsettings" ) then
							ULib.clientRPC( v, "xgui_settings.XGUI_Refresh", "adverts", ulx.adverts )
						end
					end
					return nil
				end
			end
		end
	end
end

function xgui_UpdateBanName( ply, args )
	if ply:query( "xgui_managebans" ) then 
		for ID, baninfo in pairs( ULib.bans ) do
			if ID == args[1] then
				baninfo.name = args[2]
				--Save the banfile
				file.Write( ULib.BANS_FILE, ULib.makeKeyValues( ULib.bans ) )
				--Call our function to refresh ban data for players
				xgui_ULXCommandCalled( nil, "ulx banid" )
			end
		end
	end
end

--This will check for ULX functions and delegate appropriate actions based on which commands were called
--Ex. When someone uses ulx ban, call the clients to refresh the appropriate data
function xgui_ULXCommandCalled( ply, cmdName, args )
	if cmdName == "ulx ban" or cmdName == "ulx banid" or cmdName == "ulx unban" then
		for _, v in pairs( player.GetAll() ) do
			if v:query( "xgui_managebans" ) then
				ULib.clientRPC( v, "xgui_bans.XGUI_Refresh", ULib.bans )
			end
		end
	end
end
hook.Add( "ULibPostTranslatedCommand", "XGUI_HookULXCommand", xgui_ULXCommandCalled )