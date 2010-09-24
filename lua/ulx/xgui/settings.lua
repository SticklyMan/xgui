--Settings module v2 for ULX GUI -- by Stickly Man!
--Allows changing of various settings

local settings = xlib.makepanel{ x=5, y=27, parent=xgui.null }

xgui.settings_tabs = vgui.Create( "DPropertySheet", settings )
xgui.settings_tabs:SetSize( 600, 368 )
xgui.settings_tabs.CheckAlpha = true
xgui.settings_tabs:SetFadeTime( xgui.settings.animTime )

function xgui.settings_tabs:PerformLayout()
	self:SetPos( 0, 5 )
	local ActiveTab = self:GetActiveTab()
	local Padding = self:GetPadding()
	if (!ActiveTab) then return end
	ActiveTab:InvalidateLayout( true )
	self.tabScroller:StretchToParent( Padding, 0, Padding, nil )
	self.tabScroller:SetTall( ActiveTab:GetTall() )
	self.tabScroller:InvalidateLayout( true )
	for k, v in pairs( self.Items ) do
		v.Tab:GetPanel():SetVisible( false )
		v.Tab:SetZPos( 100 - k )
		v.Tab:ApplySchemeSettings()
	end
	if ( ActiveTab ) then
		local ActivePanel = ActiveTab:GetPanel()
		ActivePanel:SetVisible( true )
		--Since we're using Frames instead of panels, this will set the position to the correct location.
		ActivePanel:SetPos( ScrW()/2 - 295, ScrH()/2 - 141 )
		if ( !ActivePanel.NoStretchX ) then
			ActivePanel:SetWide( self:GetWide() - Padding * 2 )
		else
			ActivePanel:CenterHorizontal()
		end
		if ( !ActivePanel.NoStretchY ) then
			ActivePanel:SetTall( self:GetTall() - ActiveTab:GetTall() - Padding * 2 )
		else
			ActivePanel:CenterVertical()
		end
		ActivePanel:InvalidateLayout()
		ActiveTab:SetZPos( 100 )
	end
	self.animFade:Run()
end

function xgui.settings_tabs:CrossFade( anim, delta, data )
		local old = data.OldTab:GetPanel()
		local new = data.NewTab:GetPanel()
		
		if ( anim.Started ) then
			self.CheckAlpha = false
		end
		
		if ( delta < 0.5 ) then
			old:SetVisible( true )
			new:SetVisible( false )
			old:SetAlpha( 255-( 255*( delta*2 ) ) )
		else
			old:SetVisible( false )
			new:SetVisible( true )
			new:SetAlpha( 255*( ( delta-0.5 )*2 ) )
		end
		if ( anim.Finished ) then
			old:SetVisible( false )
			new:SetVisible( true )
			new:SetAlpha( 255 )
			self.CheckAlpha = true
		end
	end
xgui.settings_tabs.animFade = Derma_Anim( "Fade", xgui.settings_tabs, xgui.settings_tabs.CrossFade )
xgui.settings_tabs.animFade.Start = x_anim_Start

function xgui.settings_tabs:Think()
	self.animFade:Run()
	if self.CheckAlpha then
		self:GetActiveTab():GetPanel():SetAlpha( self:GetParent():GetAlpha() )
	end
end

table.insert( xgui.modules.tab, { name="Settings", panel=settings, icon="gui/silkicons/wrench", tooltip=nil, access=nil } )