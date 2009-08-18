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

AddCSLuaFile( "ulx/modules/cl/xgui_helpers.lua" )

local function getGimps( ply )
	for _, v in ipairs( ulx.gimpSays ) do
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
	for groupname, advertgroup in pairs( ulx.adverts ) do 
		for num, advert in pairs( advertgroup ) do
			umsg.Start( "xgui_advert" , ply )
				ULib.umsgSend( advert )
				ULib.umsgSend( groupname )
				ULib.umsgSend( num )
			umsg.End()
		end
	end
end
ULib.concommand( "xgui_requestadverts", getAdverts )

local function removeAdvert( ply, func, args )
	for groupname, advertgroup in pairs( ulx.adverts ) do
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
ULib.concommand( "xgui_removeadvert", removeAdvert )


--New functions! The older ones above may and probably will be removed.
local function SendData( ply, func, args )
	local xgui_data = {}
	
	--Gamemodes
	xgui_data.gamemodes = {}
	local dirs = file.FindDir( "../gamemodes/*" )
	for _, dir in pairs( dirs ) do
		if file.Exists( "../gamemodes/" .. dir .. "/info.txt" ) and not util.tobool( util.KeyValuesToTable( file.Read( "../gamemodes/" .. dir .. "/info.txt" ) ).hide ) then
			table.insert( xgui_data.gamemodes, dir )
		end
	end
	
	--Votemaps
	xgui_data.votemaps = {}
	for _, v in pairs( ulx.votemaps ) do
		table.insert( xgui_data.votemaps, v )
	end
	
	--All maps (requires access to change level, or enable/disable votemaps)
	if ply:query( "ulx map" ) or ply:query( "ulx_cl_votemapEnabled" ) then
		xgui_data.maps = ulx.maps
	end
	
	--ULIb will send the data to the client, quickly and easily!
	ULib.clientRPC( ply, "xgui_RecieveData", xgui_data )
end
ULib.concommand( "xgui_getdata", SendData )

local function blargh( ply, func, args )
	ULib.ucl.setGroupInheritance( args[1], args[2] )
end
ULib.concommand( "xgui_setinh", blargh )