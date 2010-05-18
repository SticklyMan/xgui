--Settings module v2 for ULX GUI -- by Stickly Man!
--Allows changing of various settings

local xgui_settings2 = x_makepanel{ x=5, y=27, parent=xgui.null }

xgui_settings2.tabs = vgui.Create( "DPropertySheet", xgui_settings2 )
xgui_settings2.tabs:SetSize( 600, 368 )
xgui_settings2.tabs.CheckAlpha = true
xgui_settings2.tabs:SetFadeTime( xgui.base:GetFadeTime() )

function xgui_settings2.tabs:PerformLayout()
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

function xgui_settings2.tabs:CrossFade( anim, delta, data )
		local old = data.OldTab:GetPanel()
		local new = data.NewTab:GetPanel()
		
		if ( anim.Started ) then
			self.CheckAlpha = false
		end
		if ( anim.Finished ) then
			self.CheckAlpha = true
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
	end
xgui_settings2.tabs.animFade = Derma_Anim( "Fade", xgui_settings2.tabs, xgui_settings2.tabs.CrossFade )

function xgui_settings2.tabs:Think()
	xgui_settings2.tabs:SetFadeTime( xgui.base:GetFadeTime() )
	self.animFade:Run()
	if self.CheckAlpha then
		self:GetActiveTab():GetPanel():SetAlpha( self:GetParent():GetAlpha() )
	end
end

table.insert( xgui.modules.tab, { name="Settings", panel=xgui_settings2, icon="gui/silkicons/wrench", tooltip=nil, access=nil } )