--Server stuff for the GUI for ULX --  by Stickly Man!
--Used to send server data to clients

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