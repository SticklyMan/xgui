--Server stuff for the GUI for ULX --by Stickly Man!
require("datastream")

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

--Here we will use ULib to replicate the server settins so that anyone with access can change them (not just listen server host or rcon!)
ULib.ucl.registerAccess( "xgui_changeserversettings", "superadmin", "Allows changing of gamemode and server-specific settings on the settings tab." )
ULib.replicatedWritableCvar( "sbox_noclip", "sbox_cl_noclip", GetConVarNumber( "sbox_noclip" ), false, false, "xgui_changeserversettings" )
ULib.replicatedWritableCvar( "sbox_godmode", "sbox_cl_godmode", GetConVarNumber( "sbox_godmode" ), false, false, "xgui_changeserversettings" )
ULib.replicatedWritableCvar( "sbox_plpldamage", "sbox_cl_plpldamage", GetConVarNumber( "sbox_plpldamage" ), false, false, "xgui_changeserversettings" )
ULib.replicatedWritableCvar( "sv_voiceenable", "sv_cl_voiceenable", GetConVarNumber( "sv_voiceenable" ), false, false, "xgui_changeserversettings" )
ULib.replicatedWritableCvar( "sv_alltalk", "sv_cl_alltalk", GetConVarNumber( "sv_alltalk" ), false, false, "xgui_changeserversettings" )
ULib.replicatedWritableCvar( "ai_disabled", "ai_cl_disabled", GetConVarNumber( "ai_disabled" ), false, false, "xgui_changeserversettings" )
ULib.replicatedWritableCvar( "ai_keepragdolls", "ai_cl_keepragdolls", GetConVarNumber( "ai_keepragdolls" ), false, false, "xgui_changeserversettings" )
ULib.replicatedWritableCvar( "ai_ignoreplayers", "ai_cl_ignoreplayers", GetConVarNumber( "ai_ignoreplayers" ), false, false, "xgui_changeserversettings" )
ULib.replicatedWritableCvar( "sv_gravity", "sv_cl_gravity", GetConVarNumber( "sv_gravity" ), false, false, "xgui_changeserversettings" )
ULib.replicatedWritableCvar( "phys_timescale", "phys_cl_timescale", GetConVarNumber( "phys_timescale" ), false, false, "xgui_changeserversettings" )

--Function hub! All server functions can be called via concommand xgui!
function xgui_cmd( ply, handler, id, encoded, decoded )
	args = decoded
	local branch=args[1]
	table.remove( args, 1 )
	if branch == "getdata" then xgui_sendData( ply, args ) else
	if branch == "setinheritance" then xgui_setInheritance( ply, args ) else
	if branch == "removeGimp" then xgui_removeGimp( ply, args ) else
	if branch == "removeAdvert" then xgui_removeAdvert( ply, args ) else
		ply:SendLua( "print( \"XGUI: Command not found!\" )" )
	end end end end --Yay ends!
end
datastream.Hook( "XGUI", xgui_cmd )

function xgui_sendData( ply, args )
	local xgui_data = {}
	
	--Prevents opening menu while data is being sent!
	ply:SendLua( "xgui_hasLoaded = false" )
	
	--If no args are specified, then update everything!
	if #args == 0 then args = { "gamemodes", "votemaps", "maps", "gimps", "adverts" } end
	for _, u in ipairs( args ) do
		if u == "gamemodes" then
			xgui_data.gamemodes = {}
			local dirs = file.FindDir( "../gamemodes/*" )
			for _, dir in pairs( dirs ) do
				if file.Exists( "../gamemodes/" .. dir .. "/info.txt" ) and not util.tobool( util.KeyValuesToTable( file.Read( "../gamemodes/" .. dir .. "/info.txt" ) ).hide ) then
					table.insert( xgui_data.gamemodes, dir )
				end
			end
		end
		
		if u == "votemaps" then
			xgui_data.votemaps = {}
			for _, v in pairs( ulx.votemaps ) do
				table.insert( xgui_data.votemaps, v )
			end
		end
		
		if u == "maps" then
			if ply:query( "ulx map" ) or ply:query( "ulx_cl_votemapEnabled" ) then
				xgui_data.maps = ulx.maps
			end
		end
		
		if u == "gimps" then
			xgui_data.gimps = ulx.gimpSays
		end
		
		if u == "adverts" then
			xgui_data.adverts = {}
			for groupname, advertgroup in pairs( ulx.adverts ) do 
				for num, advert in pairs( advertgroup ) do
					local temp = advert
					temp.groupname = groupname
					temp.num = num
					table.insert( xgui_data.adverts, temp )
				end
			end
		end
	end
	--ULIb will easily send the data to the client!
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

function xgui_removeGimp( ply, args )
	local gi = debug.getinfo( ulx.cc_addGimpSay )
	for i=1, gi.nups do
		local k, v = debug.getupvalue( ulx.cc_addGimpSay, i )
		if k == "gimpSays" then
			for a, b in ipairs( v ) do
				if b == args[1] then
					table.remove( v, a )
					return nil
				end
			end
		end
	end
end

function xgui_removeAdvert( ply, args )
	for groupname, advertgroup in pairs( ulx.adverts ) do
		for num, _ in pairs( advertgroup ) do
			if tostring( groupname ) == args[1] and tostring( num ) == args[2] then
				table.remove( advertgroup, num )
				if next( advertgroup ) == nil then
					adverts.groupname = nil
					timer.Remove( "ULXAdvert" .. type( groupname ) .. groupname )
				end
				return nil
			end
		end
	end
end