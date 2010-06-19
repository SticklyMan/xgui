--XGUI helpers  -- by Stickly Man!
--A bunch of functions to help with creating Derma elements-- Makes code look somewhat nicer!

--[[ Table Variables Quick Reference
STRINGS:
label - used for text near a control
tooltip - used to show info when a mouse is hovering over a control
convar - used to link a control to a convar (Using Garry's Method)
repconvar - used to more efficiently link a control to a convar (Must be a ULib replicated convar, though)
text - set the text in a textbox
access - ULX access string used to determine whether the control is enabled or disabled
saccess - ULX access string used to determine if the control is visible
btype - Used to set the symbol on a DSysButton. Valid choices are close, grip, down, up, updown, tick, right, left, question, and none.

NUMBERS:
x, y, w, h - position, width, and height of control
min, max, decimal - used with a slider, sets the minimum and maximum value, and the number of decimal places to use. Also used with a DProgressBar
spacing, padding - used with panellist, determines how much spacing there is between controls, and their distance from the edge of the panel
value - sets the value of a slider/numberwang
headerheight - sets height of a DListView header

OTHER:
parent - the panel on which the control will be affixed
contents - for a category, this will be the panellist of controls in the category
textcolor - sets the text color
choices - table with list of strings to add to a MultiChoice

BOOL:
multiselect - Allow multiple selects
autosize - Used with the panel list, it will size the panel based on its contents
enableinput - Used with textbox/multichoice, will enable/disable input
vscroll, hscroll - Enables/disabels vertical and horizontal scrollbars
focuscontrol - Determines whether to specify special functions for xgui.base's keyboard focus handling stuff
expanded - Determines whether or not a category is expanded when it is created
nopopup - Used only with makeframepopup, will set whether the frame pops up or not
showclose - Determines whether to show X button on makeframepopup
percent - If true, progressbar will show as a %
disabled - Used with controls to determine if it is disabled.
]]--

local function xgui_helpers()
	function x_makecheckbox( t )
		local xgui_temp = vgui.Create( "DCheckBoxLabel", t.parent )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetText( t.label or "" )
		xgui_temp:SizeToContents()
		xgui_temp:SetValue( t.value or 0 )
		if t.convar then xgui_temp:SetConVar( t.convar ) end
		if t.textcolor then xgui_temp:SetTextColor( t.textcolor ) end
		if t.tooltip then xgui_temp:SetTooltip( t.tooltip ) end
		--Replicated Convar Updating
		if t.repconvar then
			if GetConVar( t.repconvar ) == nil then
				CreateConVar( t.repconvar, 0 ) --Replicated cvar hasn't been created via ULib. Create a temporary one to prevent errors
			end
			xgui_temp:SetValue( GetConVar( t.repconvar ):GetBool() )
			function xgui_temp.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
				if cl_cvar == t.repconvar then
					xgui_temp:SetValue( new_val )
				end
			end
			hook.Add( "ULibReplicatedCvarChanged", "XGUI_" .. t.repconvar, xgui_temp.ConVarUpdated )
			function xgui_temp:OnChange( bVal )
				RunConsoleCommand( t.repconvar, tostring( bVal and 1 or 0 ) )
			end
			xgui_temp.Think = function() end --Override think functions to remove Garry's convar check to (hopefully) speed things up
			xgui_temp.ConVarNumberThink = function() end
			xgui_temp.ConVarStringThink = function() end
			xgui_temp.ConVarChanged = function() end
		end
		return xgui_temp
	end

	function x_makelabel( t )
		local xgui_temp = vgui.Create( "DLabel", t.parent )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetText( t.label or "" )
		xgui_temp:SizeToContents()
		xgui_temp:SetToolTip( t.tooltip )
		if t.font then xgui_temp:SetFont( t.font ) end
		if t.w then xgui_temp:SetWidth( t.w ) end
		if t.h then xgui_temp:SetHeight( t.h ) end
		if t.textcolor then xgui_temp:SetTextColor( t.textcolor ) end
		return xgui_temp
	end

	function x_makepanellist( t )
		local xgui_temp = vgui.Create( "DPanelList", t.parent )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetSize( t.w, t.h )
		xgui_temp:SetSpacing( t.spacing or 5 )
		xgui_temp:SetPadding( t.padding or 5 )
		xgui_temp:EnableVerticalScrollbar( t.vscroll or true )
		xgui_temp:EnableHorizontal( t.hscroll or false )
		xgui_temp:SetAutoSize( t.autosize )
		return xgui_temp
	end

	function x_makebutton( t )
		local xgui_temp = vgui.Create( "DButton", t.parent )
		xgui_temp:SetSize( t.w, t.h or 20 )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetText( t.label or "" )
		xgui_temp:SetDisabled( t.disabled )
		return xgui_temp
	end	
	
	function x_makesysbutton( t )
		local xgui_temp = vgui.Create( "DSysButton", t.parent )
		xgui_temp:SetType( t.btype )
		xgui_temp:SetSize( t.w, t.h or 20 )
		xgui_temp:SetPos( t.x, t.y )
		return xgui_temp
	end
	
	function x_makeframepopup( t )
		local xgui_temp = vgui.Create( "DFrame", t.parent )
		xgui_temp:SetSize( t.w, t.h )
		xgui_temp:SetPos( t.x or ScrW()/2-t.w/2, t.y or ScrH()/2-t.h/2 )
		xgui_temp:SetTitle( t.label or "" )
		if t.draggable ~= nil then xgui_temp:SetDraggable( t.draggable ) end
		if t.nopopup ~= true then xgui_temp:MakePopup() end
		if t.showclose ~= nil then xgui_temp:ShowCloseButton( t.showclose ) end
		if t.alwaysontop ~= nil then xgui_temp:SetDrawOnTop( t.alwaysontop ) end
		return xgui_temp
	end

	function x_maketextbox( t )
		local xgui_temp = vgui.Create( "DTextEntry", t.parent )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetWide( t.w )
		xgui_temp:SetTall( t.h or 20 )
		xgui_temp:SetEnterAllowed( true )
		if t.convar then xgui_temp:SetConVar( t.convar ) end
		if t.text then xgui_temp:SetText( t.text ) end
		if t.enableinput then xgui_temp:SetEnabled( t.enableinput ) end
		xgui_temp:SetToolTip( t.tooltip )
		
		--For XGUI keyboard focus handling
		if ( t.focuscontrol == true ) then
			xgui_temp.OnGetFocus = function( self )
				self:SelectAllText()
				xgui.base:SetKeyboardInputEnabled( true )
			end
			xgui_temp.OnLoseFocus = function( self )
				xgui.base:SetKeyboardInputEnabled( false )
				self:UpdateConvarValue()
			end
		end
		--Replicated Convar Updating
		if t.repconvar then
			if GetConVar( t.repconvar ) == nil then
				CreateConVar( t.repconvar, 0 ) --Replicated cvar hasn't been created via ULib. Create a temporary one to prevent errors
			end
			xgui_temp:SetValue( GetConVar( t.repconvar ):GetString() )
			function xgui_temp.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
				if cl_cvar == t.repconvar then
					xgui_temp:SetValue( new_val )
				end
			end
			hook.Add( "ULibReplicatedCvarChanged", "XGUI_" .. t.repconvar, xgui_temp.ConVarUpdated )
			function xgui_temp:OnEnter()
				RunConsoleCommand( t.repconvar, self:GetValue() )
			end
			xgui_temp.Think = function() end --Override think functions to remove Garry's convar check to (hopefully) speed things up
			xgui_temp.ConVarNumberThink = function() end
			xgui_temp.ConVarStringThink = function() end
			xgui_temp.ConVarChanged = function() end
		end
		return xgui_temp
	end

	function x_makelistview( t )
		local xgui_temp = vgui.Create( "DListView", t.parent )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetSize( t.w, t.h )
		xgui_temp:SetMultiSelect( t.multiselect )
		xgui_temp:SetHeaderHeight( t.headerheight or 20 )
		return xgui_temp
	end

	function x_makecat( t )
		local xgui_temp = vgui.Create( "DCollapsibleCategory", t.parent )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetSize( t.w, t.h )
		xgui_temp:SetLabel( t.label or "" )
		xgui_temp:SetContents( t.contents )
		if t.expanded ~= nil then xgui_temp:SetExpanded( t.expanded ) end
		return xgui_temp
	end

	function x_makepanel( t )
		local xgui_temp = vgui.Create( "DPanel", t.parent )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetSize( t.w, t.h )
		return xgui_temp
	end

	function x_makeXpanel( t )
		xgui_temp = vgui.Create( "DPanel_XGUI", t.parent )
		xgui_temp:MakePopup()
		xgui_temp:SetKeyboardInputEnabled( false )
		xgui_temp:SetMouseInputEnabled( true )
		xgui_temp.IsXPanel = true
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetSize( t.w, t.h )
		return xgui_temp
	end
	
	function x_makenumber( t )
		local xgui_temp = vgui.Create( "DNumberWang", t.parent )
		xgui_temp:SetMinMax( t.min or 0, t.max or 100 )
		xgui_temp:SetDecimals( t.decimal or 0 )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetWidth( t.w )
		xgui_temp:SizeToContents()
		xgui_temp:SetValue( t.value )
		if t.convar then xgui_temp:SetConVar( t.convar ) end
		return xgui_temp
	end

	function x_makemultichoice( t )
		local xgui_temp = vgui.Create( "DMultiChoice", t.parent )
		xgui_temp:SetText( t.text or "" )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetSize( t.w, t.h or 20 )
		xgui_temp:SetEditable( t.enableinput )
		if ( t.focuscontrol == true ) then
			xgui_temp.DropButton.OnMousePressed = function( button, mcode ) 
				xgui_temp:OpenMenu( xgui_temp.DropButton )
				xgui.base:SetKeyboardInputEnabled( false )
			end
			xgui_temp.TextEntry.OnMousePressed = function( self )
				self:SelectAllText()
				xgui.base:SetKeyboardInputEnabled( true )
			end
			xgui_temp.TextEntry.OnLoseFocus = function( self )
				xgui.base:SetKeyboardInputEnabled( false )
				self:UpdateConvarValue()
			end
		end
		xgui_temp:SetToolTip( t.tooltip )
		if t.choices then
			for i, v in ipairs( t.choices ) do
				xgui_temp:AddChoice( v )
			end
		end
		--Replicated Convar Updating
		if t.repconvar then
			if GetConVar( t.repconvar ) == nil then
				CreateConVar( t.repconvar, 0 ) --Replicated cvar hasn't been created via ULib. Create a temporary one to prevent errors
			end
			if t.isNumberConvar then --This is for convar settings stored via numbers (like ulx_rslotsMode)
				local cvar = GetConVar( t.repconvar ):GetInt()
				if cvar + 1 <= #xgui_temp.Choices then
					xgui_temp:ChooseOptionID( cvar + 1 )
				else
					xgui_temp:SetText( "Invalid Convar Value" )
				end
				function xgui_temp.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
					if cl_cvar == t.repconvar then
						if new_val + 1 <= #xgui_temp.Choices then
							xgui_temp:ChooseOptionID( new_val + 1 )
						else
							xgui_temp:SetText( "Invalid Convar Value" )
						end
					end
				end
				hook.Add( "ULibReplicatedCvarChanged", "XGUI_" .. t.repconvar, xgui_temp.ConVarUpdated )
				function xgui_temp:OnSelect( index )
					RunConsoleCommand( t.repconvar, tostring( index - 1 ) )
				end
			else  --Otherwise, use each choice as a string for the convar
				xgui_temp:SetText( GetConVar( t.repconvar ):GetString() )
				function xgui_temp.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
					if cl_cvar == t.repconvar then
						xgui_temp:SetText( new_val )
					end
				end
				hook.Add( "ULibReplicatedCvarChanged", "XGUI_" .. t.repconvar, xgui_temp.ConVarUpdated )
				function xgui_temp:OnSelect( index, value )
					RunConsoleCommand( t.repconvar, value )
				end
			end
		end
		return xgui_temp
	end

	function x_makecombobox( t )
		local xgui_temp = vgui.Create( "DComboBox", t.parent )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetSize( t.w, t.h )
		xgui_temp:SetAutoSize( t.autosize )
		return xgui_temp
	end
	
	function x_maketree( t )
		local xgui_temp = vgui.Create( "DTree", t.parent )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetSize( t.w, t.h )
		return xgui_temp
	end
	
	--If we aren't in the sandbox gamemode, then "CtrlColor" isn't included-- Don't see anything wrong with including it here!
	if gmod.GetGamemode().Name ~= "Sandbox" then
		include( 'sandbox/gamemode/spawnmenu/controls/CtrlColor.lua' )
	end
	--Color picker used in Garry's menus
	function x_makecolorpicker( t )
		local xgui_temp = vgui.Create( "CtrlColor", t.parent )
			if t.removealpha == true then
				--Remove the alpha numberwang, also align the rgb numberwangs on the bottom
				xgui_temp.txtA:Remove()
				xgui_temp.SetConVarA = nil
				function xgui_temp:PerformLayout()
					local y = 0
					self:SetTall( 135 )
					self.Mixer:SetSize( 148, 100 )
					self.Mixer:AlignTop( 5 )
					self.Mixer:AlignLeft( 5 )
					self.txtR:SizeToContents()
					self.txtG:SizeToContents()
					self.txtB:SizeToContents()
					self.txtR:AlignLeft( 5 )
					self.txtR:AlignBottom( 5 )
						self.txtG:CopyBounds( self.txtR )
						self.txtG:CenterHorizontal( 0.5 )
							self.txtB:CopyBounds( self.txtG )
							self.txtB:AlignRight( 5 )
				end
				xgui_temp.Mixer:Remove()
				--Remove the default mixer and replace with a mixer without the alpha bar
				xgui_temp.Mixer = vgui.Create( "XGUIColorMixerNoAlpha", xgui_temp )
			end
			xgui_temp:SetConVarR( "colour_r" )
			xgui_temp:SetConVarG( "colour_g" )
			xgui_temp:SetConVarB( "colour_b" )
			if not t.removealpha then
				xgui_temp:SetConVarA( "colour_a" )
			end
			xgui_temp:SetPos( t.x, t.y )
			xgui_temp:SetSize( t.w, t.h )
		return xgui_temp
	end
	
	--Includes Garry's ever-so-awesome progress bar!
	include( "menu/ProgressBar.lua" )
	function x_makeprogressbar( t )
		xgui_temp = vgui.Create( "DProgressBar", t.parent )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetSize( t.w or 100, t.h or 20 )
		xgui_temp:SetMin( t.min or 0 )
		xgui_temp:SetMax( t.max or 100 )
		xgui_temp:SetValue( t.value or 0 )
		if t.percent then
			xgui_temp.m_bLabelAsPercentage = true 
			xgui_temp:UpdateText()
		end
		return xgui_temp
	end
	
	--Garry's DTree:Clear() function doesn't exist.. let's make one
	function DTree:Clear()
		for item, node in pairs( self.Items ) do
			node:Remove()
			self.Items[item] = nil
		end
		self.m_pSelectedItem = nil
		self:InvalidateLayout()
	end
	
	--A quick function to get the value of a DMultiChoice (I like consistency)
	function DMultiChoice:GetValue()
		return self.TextEntry:GetValue()
	end
	
	function DCheckBoxLabel:GetValue()
		return self:GetChecked()
	end

	--Get a line in a DListView by searching for a column value ( outID determines whether to return the line object, or the ID )
	function DListView:GetLineByColumnText( search, column, outID )
		for ID, line in pairs( self.Lines ) do
			if line:GetColumnText( column ) == search then
				if outID == true then
					return ID
				else
					return line
				end
			end
		end
	end
	
	--Clears all of the tabs in a DPropertySheet, parents removed panels to xgui.null.
	function DPropertySheet:Clear()
		for _, Sheet in ipairs( self.Items ) do
			Sheet.Panel:SetParent( xgui.null )
			Sheet.Tab:Remove()
		end
		self.m_pActiveTab = nil
		self:SetActiveTab( nil )
		self.tabScroller.Panels = {}
		self.Items = {}
	end

	--------------------------------------------------
	--Here is slightly modified Derma code specific to XGUI's base.
	--------------------------------------------------
	function x_makeXGUIbase()
		local xgui_base = vgui.Create( "DPropertySheet" )
		xgui_base:SetVisible( false )
		xgui_base:SetPos( ScrW()/2 - 300, ScrH()/2 - 200 )
		xgui_base:SetSize( 600, 400 )
		xgui_base:SetFadeTime( .2 )
		--(The following is a direct copy of Garry's code, minus the comments. Any added comments were changes relating to XGUI)
		function xgui_base:PerformLayout()
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
				--If we're using XPanels (which are modified Popuped Frames) instead of regular panels, this will set the position to the correct location.
				if ActivePanel.IsXPanel then
					ActivePanel:SetPos( ScrW()/2 - 295, ScrH()/2 - 173 )
				end
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
		--(End Garry's code block)
		
		--Modify the animation since transparent frames on top of each other don't look right.
		function xgui_base:CrossFade( anim, delta, data )
			local old = data.OldTab:GetPanel()
			local new = data.NewTab:GetPanel()

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
		xgui_base.animFade = Derma_Anim( "Fade", xgui_base, xgui_base.CrossFade )
		
		--Fade in/out effect when opening/closing XGUI!
		function xgui_base:FadeIn( anim, delta, panel )
			if ( anim.Started ) then
				panel:SetAlpha( 0 )
			end
			panel:SetAlpha( delta*255 )
			panel:GetActiveTab():GetPanel():SetAlpha( delta*255 )
		end
		xgui_base.animFadeIn = Derma_Anim( "Fade", xgui_base, xgui_base.FadeIn )
		
		function xgui_base:FadeOut( anim, delta, panel )
			if ( anim.Finished ) then
				panel:SetAlpha( 255 )
				panel:SetVisible( false )
			end
			panel:SetAlpha( 255-( delta*255 ) )
			panel:GetActiveTab():GetPanel():SetAlpha( 255-( delta*255 ) )
		end
		xgui_base.animFadeOut = Derma_Anim( "Fade", xgui_base, xgui_base.FadeOut )

		function xgui_base:Think()
			self.animFade:Run()
			self.animFadeIn:Run()
			self.animFadeOut:Run()
		end

		return xgui_base
	end
	
	--------------------------------------------------
	--Megiddo and I are sick of number sliders and their spam of updating convars. Lets modify the NumSlider so that it only sets the value when the mouse is released! (And allows for textbox input)
	--------------------------------------------------
	function x_makeslider( t )
		local xgui_temp = vgui.Create( "DNumSlider", t.parent )
		if t.fixclip == nil or t.fixclip == true then --Fixes clipping errors on the Knob by default, but disables it if specified.
			xgui_temp.Slider.Knob:SetSize( 13, 13 )
			xgui_temp.Slider.Knob:SetPos( 0, 0 )
			xgui_temp.Slider.Knob:NoClipping( false )
		end
		xgui_temp:SetText( t.label or "" )
		xgui_temp:SetMinMax( t.min or 0, t.max or 100 )
		xgui_temp:SetDecimals( t.decimal or 0 )
		if t.convar then xgui_temp:SetConVar( t.convar ) end
		xgui_temp:SetTooltip( t.tooltip )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetWidth( t.w )
		xgui_temp:SizeToContents()
		xgui_temp.Label:SetTextColor( t.textcolor )
		if t.value then xgui_temp:SetValue( t.value ) end
		
		--Keyboard focus stuff
		xgui_temp.Wang.TextEntry.OnGetFocus = function()
			xgui.base:SetKeyboardInputEnabled( true )
		end
		xgui_temp.Wang.TextEntry.OnLoseFocus = function( self )
			self:UpdateConvarValue()
			xgui_temp.Wang:SetValue( xgui_temp.Wang.TextEntry:GetValue() )
			xgui.base:SetKeyboardInputEnabled( false )
		end	
		
		--Slider update stuff (Most of this code is copied from the default DNumSlider)
		xgui_temp.Slider.TranslateValues = function( self, x, y )
			--Store the value and update the textbox to the new value
			xgui_temp_x = x
			local val = xgui_temp.Wang.m_numMin + ( ( xgui_temp.Wang.m_numMax - xgui_temp.Wang.m_numMin ) * x )
			if xgui_temp.Wang.m_iDecimals == 0 then
				val = Format( "%i", val )
			else
				val = Format( "%." .. xgui_temp.Wang.m_iDecimals .. "f", val )
				-- Trim trailing 0's and .'s 0 this gets rid of .00 etc
				val = string.TrimRight( val, "0" )
				val = string.TrimRight( val, "." )
			end
			xgui_temp.Wang.TextEntry:SetText( val )
			return x, y
		end
		xgui_temp.Slider.OnMouseReleased = function( self, mcode )
			xgui_temp.Slider:SetDragging( false )
			xgui_temp.Slider:MouseCapture( false )
			--Update the actual value to the value we stored earlier
			xgui_temp.Wang:SetFraction( xgui_temp_x )
		end
		
		--This makes it so the value doesnt change while you're typing in the textbox
		xgui_temp.Wang.TextEntry.OnTextChanged = function() end
		
		--NumberWang update stuff(Most of this code is copied from the default DNumberWang)
		xgui_temp.Wang.OnCursorMoved = function( self, x, y )
			if ( not self.Dragging ) then return end
			local fVal = self:GetFloatValue()
			local y = gui.MouseY()
			local Diff = y - self.HoldPos
			local Sensitivity = math.abs(Diff) * 0.025
			Sensitivity = Sensitivity / ( self:GetDecimals() + 1 )
			fVal = math.Clamp( fVal + Diff * Sensitivity, self.m_numMin, self.m_numMax )
			self:SetFloatValue( fVal )
			local x, y = self.Wanger:LocalToScreen( self.Wanger:GetWide() * 0.5, 0 )
			input.SetCursorPos( x, self.HoldPos )
			--Instead of updating the value, we're going to store it for later
			xgui_temp_fVal = fVal
			
			if ( ValidPanel( self.IndicatorT ) ) then self.IndicatorT:InvalidateLayout() end
			if ( ValidPanel( self.IndicatorB ) ) then self.IndicatorB:InvalidateLayout() end
			
			--Since we arent updating the value, we need to manually set the value of the textbox. YAY!!
			val = tonumber( fVal )
			val = val or 0
			if ( self.m_iDecimals == 0 ) then
				val = Format( "%i", val )
			elseif ( val ~= 0 ) then
				val = Format( "%."..self.m_iDecimals.."f", val )
				val = string.TrimRight( val, "0" )		
				val = string.TrimRight( val, "." )
			end
			self.TextEntry:SetText( val )
		end
		
		xgui_temp.Wang.OnMouseReleased = function( self, mousecode )
			if ( self.Dragging ) then
				self:EndWang()
				self:SetValue( xgui_temp_fVal )
			return end
		end
		--Replicated Convar Updating
		if t.repconvar then
			if GetConVar( t.repconvar ) == nil then
				CreateConVar( t.repconvar, 0 ) --Replicated cvar hasn't been created via ULib. Create a temporary one to prevent errors
			end
			xgui_temp:SetValue( GetConVar( t.repconvar ):GetFloat() )
			function xgui_temp.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
				if cl_cvar == t.repconvar then
					xgui_temp:SetValue( new_val )
				end
			end
			hook.Add( "ULibReplicatedCvarChanged", "XGUI_" .. t.repconvar, xgui_temp.ConVarUpdated )
			function xgui_temp:OnValueChanged( val )
				RunConsoleCommand( t.repconvar, tostring( val ) )
			end
			xgui_temp.Wang.TextEntry.ConVarStringThink = function() end --Override think functions to remove Garry's convar check to (hopefully) speed things up
			xgui_temp.ConVarNumberThink = function() end
			xgui_temp.ConVarStringThink = function() end
			xgui_temp.ConVarChanged = function() end
		end
		return xgui_temp
	end
	
	--------------------------------------
	--Used for the colorpicker above, this is Garry's DColorMixer with the alpha bar removed
	--------------------------------------
	local PANEL = {}

	AccessorFunc( PANEL, "m_ConVarR", 				"ConVarR" )
	AccessorFunc( PANEL, "m_ConVarG", 				"ConVarG" )
	AccessorFunc( PANEL, "m_ConVarB", 				"ConVarB" )
	AccessorFunc( PANEL, "m_fSpacer", 				"Spacer" )

	function PANEL:Init()
		self.RGBBar = vgui.Create( "DRGBBar", self )
		self.RGBBar.OnColorChange = function( ctrl, color ) self:SetBaseColor( color ) end
		self.ColorCube = vgui.Create( "DColorCube", self )
		self.ColorCube.OnUserChanged = function( ctrl ) self:ColorCubeChanged( ctrl ) end
		self:SetColor( Color( 255, 100, 100, 255 ) )
		self:SetSpacer( 3 )
	end

	function PANEL:PerformLayout()
		local SideBoxSize = self:GetTall() * 0.15
		self.RGBBar:SetWide( SideBoxSize )
		self.RGBBar:StretchToParent( 0, 0, nil, 0 )
		self.ColorCube:MoveRightOf( self.RGBBar, 5 )
		self.ColorCube:StretchToParent( nil, 0, SideBoxSize + self.m_fSpacer, 0 )
	end

	function PANEL:SetBaseColor( color )
		self.RGBBar:SetColor( color )
		self.ColorCube:SetBaseRGB( color )
		self:UpdateConVars( self.ColorCube:GetRGB() )
	end

	function PANEL:SetColor( color )
		self.ColorCube:SetColor( color )
		self.RGBBar:SetColor( color )
	end
	
	function PANEL:Paint() end
	
	function PANEL:UpdateConVar( strName, strKey, color )
		if ( !strName ) then return end
		RunConsoleCommand( strName, tostring( color[ strKey ] ) )
	end

	function PANEL:UpdateConVars( color )
		self.NextConVarCheck = SysTime() + 0.1
		self:UpdateConVar( self.m_ConVarR, 'r', color )
		self:UpdateConVar( self.m_ConVarG, 'g', color )
		self:UpdateConVar( self.m_ConVarB, 'b', color )
	end

	function PANEL:ColorCubeChanged( cube )
		self:UpdateConVars( self:GetColor() )
	end

	function PANEL:GetColor()
		local color = self.ColorCube:GetRGB()
		color.a = 255
		return color
	end

	function PANEL:Think()
		--Don't update the convars while we're changing them!
		if ( self.ColorCube:GetDragging() ) then return end
		self:DoConVarThink( self.m_ConVarR, 'r' )
		self:DoConVarThink( self.m_ConVarG, 'g' )
		self:DoConVarThink( self.m_ConVarB, 'b' )
	end

	function PANEL:DoConVarThink( convar, key )
		if ( !convar ) then return end
		local fValue = GetConVarNumber( convar )
		local fOldValue = self[ 'ConVarOld'..convar ]
		if ( fOldValue && fValue == fOldValue ) then return end
		self[ 'ConVarOld'..convar ] = fValue
		local r = GetConVarNumber( self.m_ConVarR )
		local g = GetConVarNumber( self.m_ConVarG )
		local b = GetConVarNumber( self.m_ConVarB )
		local color = Color( r, g, b, 255 )
		self:SetColor( color )	
	end
	vgui.Register( "XGUIColorMixerNoAlpha", PANEL, "DPanel" )
	
	-----------------------------------------
	--A stripped-down customized DPanel allowing for textbox input!
	-----------------------------------------
	local PANEL = {}
	AccessorFunc( PANEL, "m_bPaintBackground", "PaintBackground" )
	Derma_Hook( PANEL, "Paint", "Paint", "Panel" )
	Derma_Hook( PANEL, "ApplySchemeSettings", "Scheme", "Panel" )

	function PANEL:Init()
			self:SetPaintBackground( true )
	end

	derma.DefineControl( "DPanel_XGUI", "", PANEL, "EditablePanel" )
	
	
	----------------------------------------
	--ULIB XGUI helpers
	----------------------------------------
	
	--Helper function to parse access tag for a particular argument
	function getTagArgNum( tag, argnum )
		return tag and string.Explode( " ", tag )[argnum]
	end

	--Load control interpretations for Ulib argument types
	function ULib.cmds.BaseArg.x_getcontrol( arg, argnum )
		return x_makelabel{ label="Not Supported" }
	end
	
	function ULib.cmds.NumArg.x_getcontrol( arg, argnum )
		local access, tag = LocalPlayer():query( arg.cmd )
		local restrictions = {}
		ULib.cmds.NumArg.processRestrictions( restrictions, arg, getTagArgNum( tag, argnum ) )
		
		local defvalue = arg.min
		if table.HasValue( arg, ULib.cmds.optional ) then defvalue = arg.default end
		
		local maxvalue = restrictions.max
		if restrictions.max == nil and defvalue > 100 then maxvalue = defvalue end
		
		return x_makeslider{ min=restrictions.min, max=maxvalue, value=defvalue, label=arg.hint or "NumArg" }
	end
	
	function ULib.cmds.StringArg.x_getcontrol( arg, argnum )
		local access, tag = LocalPlayer():query( arg.cmd )
		local restrictions = {}
		ULib.cmds.StringArg.processRestrictions( restrictions, arg, getTagArgNum( tag, argnum ) )
		
		local is_restricted_to_completes = table.HasValue( arg, ULib.cmds.restrictToCompletes ) -- Program-level restriction (IE, ulx map)
			or restrictions.playerLevelRestriction -- The player's tag specifies only certain strings
		
		if is_restricted_to_completes then
			xgui_temp = x_makemultichoice{ text=arg.hint or "StringArg" }
			for _, v in ipairs( restrictions.restrictedCompletes ) do
				xgui_temp:AddChoice( v )
			end
			return xgui_temp
		elseif restrictions.restrictedCompletes then
			-- This is where there needs to be both a drop down AND an input box
			local temp = x_makemultichoice{ text=arg.hint, choices=restrictions.restrictedCompletes, enableinput=true, focuscontrol=true }
			temp.TextEntry.OnEnter = function( self )
				self:GetParent():OnEnter()
			end
			return temp
		else
			return x_maketextbox{ text=arg.hint or "StringArg", focuscontrol=true }
		end
	end
	
	function ULib.cmds.PlayerArg.x_getcontrol( arg, argnum )
		local access, tag = LocalPlayer():query( arg.cmd )
		local restrictions = {}
		ULib.cmds.PlayerArg.processRestrictions( restrictions, LocalPlayer(), arg, getTagArgNum( tag, argnum ) )
		
		xgui_temp = x_makemultichoice{ text=arg.hint }
		local targets = restrictions.restrictedTargets
		if targets == false then -- No one allowed
			targets = {} -- TODO STICK: Do you want to do something more clever here? This just locks the control...
		elseif targets == nil then -- Everyone allowed
			targets = player.GetAll()
		end
		
		for _, ply in ipairs( targets ) do
			xgui_temp:AddChoice( ply:Nick() )
		end
		return xgui_temp
	end
	
	function ULib.cmds.CallingPlayerArg.x_getcontrol( arg, argnum )
		return x_makelabel{ label=arg.hint or "CallingPlayer" }
	end
	
	function ULib.cmds.BoolArg.x_getcontrol( arg, argnum )
		-- There are actually not any restrictions possible on a boolarg...
		return x_makecheckbox{ label=arg.hint or "BoolArg" }
	end
end

hook.Add( "ULibLocalPlayerReady", "InitHelpers", xgui_helpers, -20 )