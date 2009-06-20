--Server stuff for the GUI for ULX --  by Stickly Man!
--Used to send server data to clients

local function getAdmins()
	local status
	for k, v in pairs( ULib.ucl.users ) do
		umsg.Start( "xgui_admin" )
		umsg.String( k )
		umsg.String( table.concat( v.groups ) )
		for a, b in pairs( player.GetAll() ) do
			if b:SteamID() == v.id then
					status = "Online"
				else
					status = "Unavailable"
				end
			end
		umsg.String( status )
		umsg.End()
	end
end
ULib.concommand( "xgui_requestadmins", getAdmins )