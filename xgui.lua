--Server stuff for the GUI for ULX --  by Stickly Man!

Msg( "///////////////////////////////\n" )
Msg( "// ULX GUI -- by Stickly Man //\n" )
Msg( "///////////////////////////////\n" )
Msg( "//   Adding GUI Modules..    //\n" )

local xgui_module_files = file.FindInLua( "ulx/modules/cl/gui_modules/*.lua" )

for _, file in ipairs( xgui_module_files ) do
	AddCSLuaFile( "ulx/modules/cl/gui_modules/" .. file )
	Msg( "//  MODULE: " .. file .. string.rep( " ", 17 - file:len() ) .. "//\n" )
end

Msg( "//   GUI Modules Added!      //\n" )
Msg( "///////////////////////////////\n" )

local function getAdmins( ply )
	local status
	for k, v in pairs( ULib.ucl.users ) do
		umsg.Start( "xgui_admin", ply )
		umsg.String( k )
		umsg.String( table.concat( v.groups ) )
		for a, b in pairs( player.GetAll() ) do
			if b:SteamID() == v.id then
				status = "Online"
				break
			else
				status = "Unavailable"
			end
		end
		umsg.String( status )
		umsg.End()
	end
end
ULib.concommand( "xgui_requestadmins", getAdmins )