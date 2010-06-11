--Players module v2 for ULX GUI -- by Stickly Man!
--Handles all user-based commands, such as kick, slay, ban, etc.

local player = x_makeXpanel{ parent=xgui.null }
player.cmds = x_makepanellist{ x=5, y=30, w=150, h=335, parent=player, padding=1, spacing=1 }
player.setselected = function( selcat )
	for _, cat in pairs( player.cmd_cats ) do
		if cat ~= selcat then
			cat:ClearSelection()
		end
	end
	local cmd = selcat.Lines[LineID]:GetColumnText(2)
end

player.refresh = function()
	player.cmds:Clear()
	player.cmd_cats = {}
	
	for cmd, data in pairs( ULib.cmds.translatedCmds ) do
		if data.opposite ~= cmd && ULib.ucl.query( LocalPlayer(), cmd ) then
			local catname = data.category
			if catname == nil or catname == "" then catname = "Uncategorized" end
			if not player.cmd_cats[catname] then
				--Make a new category
				player.cmd_cats[catname] = x_makelistview{ headerheight=0, multiselect=false, h=136 }
				player.cmd_cats[catname].OnRowSelected = function( self, row ) player.setselected( self, row ) end
				player.cmd_cats[catname]:AddColumn( "" )
				player.cmds:AddItem( x_makecat{ label=catname, contents=player.cmd_cats[catname], expanded=false } )
			end
			player.cmd_cats[catname]:AddLine( string.gsub( cmd, "ulx ", "" ), cmd )
		end
	end
	table.sort( player.cmds.Items, function( a,b ) return a.Header:GetValue() < b.Header:GetValue() end )
	for _, cat in pairs( player.cmd_cats ) do
		cat:SortByColumn( 1 )
		cat:SetHeight( 17*#cat:GetLines() )
	end
end

table.insert( xgui.hook["onOpen"], player.refresh ) --TODO: This shouldn't have to be called each time the players tab is opened
hook.Add( "UCLChanged", "xgui_RefreshPlayerCmds", player.refresh )
table.insert( xgui.modules.tab, { name="Players", panel=player, icon="gui/silkicons/user", tooltip=nil, access=nil } )