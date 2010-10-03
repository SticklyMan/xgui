--Settings module v2 for ULX GUI -- by Stickly Man!
--Allows changing of various settings

local settings = xlib.makepanel{ x=5, y=27, parent=xgui.null }

xgui.settings_tabs = vgui.Create( "DPropertySheet", settings )
xgui.settings_tabs:SetSize( 600, 368 )
xgui.settings_tabs:SetPos( -5, 6 )

function xgui.settings_tabs:SetActiveTab( active, ignoreAnim )
	if ( self.m_pActiveTab == active ) then return end
	if ( self.m_pActiveTab ) then
		if not ignoreAnim then
			xlib.addToAnimQueue( "pnlFade", { panelOut=self.m_pActiveTab:GetPanel(), panelIn=active:GetPanel() } )
		else
			--Run this when module permissions have changed.
			xlib.addToAnimQueue( "pnlFade", { panelOut=nil, panelIn=active:GetPanel() }, 0 )
		end
		xlib.animQueue_start()
	end
	self.m_pActiveTab = active
	self:InvalidateLayout()
end

local func = xgui.settings_tabs.PerformLayout
xgui.settings_tabs.PerformLayout = function( self ) func( self ) self.tabScroller:SetPos( 10, 0 ) end

table.insert( xgui.modules.tab, { name="Settings", panel=settings, icon="gui/silkicons/wrench", tooltip=nil, access=nil } )