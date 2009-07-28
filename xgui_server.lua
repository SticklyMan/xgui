--Server stuff for the GUI for ULX --by Stickly Man!

Msg( "///////////////////////////////\n" )
Msg( "// ULX GUI -- by Stickly Man //\n" )
Msg( "///////////////////////////////\n" )
Msg( "// Adding GUI Modules..      //\n" )

local xgui_module_files = file.FindInLua( "ulx/modules/cl/gui_modules/*.lua" )

for _, file in ipairs( xgui_module_files ) do
	AddCSLuaFile( "ulx/modules/cl/gui_modules/" .. file )
	Msg( "//  MODULE: " .. file .. string.rep( " ", 17 - file:len() ) .. "//\n" )
end

Msg( "// GUI Modules Added!        //\n" )
Msg( "///////////////////////////////\n" )

AddCSLuaFile( "ulx/modules/cl/xgui_helpers.lua" )

local function getAdmins( ply )
	local status
	local name
	for k, v in pairs( ULib.ucl.users ) do
		status = "Unavailable"
		name = k
		for a, b in pairs( player.GetAll() ) do
			if b:SteamID() == v.id then
				status = "Online"
				name = b:Nick()
				break
			end
		end
			
		umsg.Start( "xgui_admin", ply )
			umsg.String( name )
			umsg.String( table.concat( v.groups ) )
			umsg.String( status )
			umsg.String( v.id )
		umsg.End()
	end
end
ULib.concommand( "xgui_requestadmins", getAdmins )

local function getGamemodes( ply )
	local dirs = file.FindDir( "../gamemodes/*" )
		for _, dir in ipairs( dirs ) do
			if file.Exists( "../gamemodes/" .. dir .. "/info.txt" ) and not util.tobool( util.KeyValuesToTable( file.Read( "../gamemodes/" .. dir .. "/info.txt" ) ).hide ) then
				umsg.Start( "xgui_gamemode_rcv", ply )
					umsg.String( dir )
				umsg.End()
			end
		end
end
ULib.concommand( "xgui_requestgamemodes", getGamemodes )

local function getGimps( ply )
	local gimps = {}
	--Special thanks to Megiddo for this bit of code
	local gi = debug.getinfo( ulx.cc_addGimpSay )
	for i=1, gi.nups do
		local k, v = debug.getupvalue( ulx.cc_addGimpSay, i )
		if k == "gimpSays" then
			gimps = v
		end
	end
	for _, v in ipairs( gimps ) do
		umsg.Start( "xgui_gimp", ply )
		umsg.String( v )
		umsg.End()
	end
end
ULib.concommand( "xgui_requestgimps", getGimps )

local function removeGimp( ply, func, args )
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
ULib.concommand( "xgui_removegimp", removeGimp )

local function getAdverts( ply )
	local gi = debug.getinfo( ulx.addAdvert )
	for i=1, gi.nups do
		local tablename, adverts = debug.getupvalue( ulx.addAdvert, i )
		if tablename == "adverts" then
			for groupname, advertgroup in pairs( adverts ) do 
				for num, advert in pairs( advertgroup ) do
					umsg.Start( "xgui_advert" , ply )
						ULib.umsgSend( advert )
						ULib.umsgSend( groupname )
						ULib.umsgSend( num )
					umsg.End()
				end
			end
		end
	end	
end
ULib.concommand( "xgui_requestadverts", getAdverts )

local function removeAdvert( ply, func, args )
	local gi = debug.getinfo( ulx.addAdvert )
	for i=1, gi.nups do
		local tablename, adverts = debug.getupvalue( ulx.addAdvert, i )
		if tablename == "adverts" then
			for groupname, advertgroup in pairs( adverts ) do
				for num, _ in pairs( advertgroup ) do
					if tostring( groupname ) == args[1] and tostring( num ) == args[2] then
						table.remove( advertgroup, num )
						if next( advertgroup ) == nil then
							print( "ULXAdvert" .. type( groupname ) .. groupname )
							adverts.groupname = nil
							timer.Remove( "ULXAdvert" .. type( groupname ) .. groupname )
						end
						return nil
					end
				end
			end
		end
	end
end
ULib.concommand( "xgui_removeadvert", removeAdvert )