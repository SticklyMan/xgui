--XLIB -- by Stickly Man!
--A library of helper functions used by XGUI for creating derma controls with a single line of code.

--Currently a bit disorganized and unstandardized, (just put in things as I needed them). I'm hoping to fix that soon.
--Also has a few ties into XGUI for keyboard focus stuff.

local function xlib_init()
	xlib = {}

	function xlib.makecheckbox( t )
		local pnl = vgui.Create( "DCheckBoxLabel", t.parent )
		pnl:SetPos( t.x, t.y )
		pnl:SetText( t.label or "" )
		pnl:SizeToContents()
		pnl:SetValue( t.value or 0 )
		if t.convar then pnl:SetConVar( t.convar ) end
		if t.textcolor then pnl:SetTextColor( t.textcolor ) end
		if not t.tooltipwidth then t.tooltipwidth = 250 end
		if t.tooltip then
			if t.tooltipwidth ~= 0 then
				t.tooltip = xlib.wordWrap( t.tooltip, t.tooltipwidth, "MenuItem" )
			end
			pnl:SetToolTip( t.tooltip )
		end
		if t.disabled then pnl:SetDisabled( t.disabled ) end
		--Replicated Convar Updating
		if t.repconvar then
			xlib.checkRepCvarCreated( t.repconvar )
			pnl:SetValue( GetConVar( t.repconvar ):GetBool() )
			function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
				if cl_cvar == t.repconvar:lower() then
					pnl:SetValue( new_val )
				end
			end
			hook.Add( "ULibReplicatedCvarChanged", "XLIB_" .. t.repconvar, pnl.ConVarUpdated )
			function pnl:OnChange( bVal )
				RunConsoleCommand( t.repconvar, tostring( bVal and 1 or 0 ) )
			end
			pnl.Think = function() end --Override think functions to remove Garry's convar check to (hopefully) speed things up
			pnl.ConVarNumberThink = function() end
			pnl.ConVarStringThink = function() end
			pnl.ConVarChanged = function() end
		end
		return pnl
	end

	function xlib.makelabel( t )
		local pnl = vgui.Create( "DLabel", t.parent )
		pnl:SetPos( t.x, t.y )
		pnl:SetText( t.label or "" )
		if not t.tooltipwidth then t.tooltipwidth = 250 end
		if t.tooltip then
			if t.tooltipwidth ~= 0 then
				t.tooltip = xlib.wordWrap( t.tooltip, t.tooltipwidth, "MenuItem" )
			end
			pnl:SetToolTip( t.tooltip )
			pnl:SetMouseInputEnabled( true )
		end

		if t.font then pnl:SetFont( t.font ) end
		pnl:SizeToContents()
		if t.w then
			pnl:SetWidth( t.w )
			if t.wordwrap then
				pnl:SetText( xlib.wordWrap( t.label, t.w, t.font or "default" ) )
			end
		end
		if t.h then pnl:SetHeight( t.h ) end
		if t.textcolor then pnl:SetTextColor( t.textcolor ) end
		return pnl
	end

	function xlib.makepanellist( t )
		local pnl = vgui.Create( "DPanelList", t.parent )
		pnl:SetPos( t.x, t.y )
		pnl:SetSize( t.w, t.h )
		pnl:SetSpacing( t.spacing or 5 )
		pnl:SetPadding( t.padding or 5 )
		pnl:EnableVerticalScrollbar( t.vscroll or true )
		pnl:EnableHorizontal( t.hscroll or false )
		pnl:SetAutoSize( t.autosize )
		return pnl
	end

	function xlib.makebutton( t )
		local pnl = vgui.Create( "DButton", t.parent )
		pnl:SetSize( t.w, t.h or 20 )
		pnl:SetPos( t.x, t.y )
		pnl:SetText( t.label or "" )
		pnl:SetDisabled( t.disabled )
		return pnl
	end

	function xlib.makesysbutton( t )
		local pnl = vgui.Create( "DSysButton", t.parent )
		pnl:SetType( t.btype )
		pnl:SetSize( t.w, t.h or 20 )
		pnl:SetPos( t.x, t.y )
		pnl:SetDisabled( t.disabled )
		return pnl
	end

	function xlib.makeframe( t )
		local pnl = vgui.Create( "DFrame", t.parent )
		pnl:SetSize( t.w, t.h )
		pnl:SetPos( t.x or ScrW()/2-t.w/2, t.y or ScrH()/2-t.h/2 )
		pnl:SetTitle( t.label or "" )
		if t.draggable ~= nil then pnl:SetDraggable( t.draggable ) end
		if t.nopopup ~= true then pnl:MakePopup() end
		if t.showclose ~= nil then pnl:ShowCloseButton( t.showclose ) end
		if t.skin then pnl:SetSkin( t.skin ) end
		return pnl
	end

	function xlib.maketextbox( t )
		local pnl = vgui.Create( "DTextEntry", t.parent )
		pnl:SetPos( t.x, t.y )
		pnl:SetWide( t.w )
		pnl:SetTall( t.h or 20 )
		pnl:SetEnterAllowed( true )
		if t.convar then pnl:SetConVar( t.convar ) end
		if t.text then pnl:SetText( t.text ) end
		if t.enableinput then pnl:SetEnabled( t.enableinput ) end
		pnl.selectAll = t.selectall
		if not t.tooltipwidth then t.tooltipwidth = 250 end
		if t.tooltip then
			if t.tooltipwidth ~= 0 then
				t.tooltip = xlib.wordWrap( t.tooltip, t.tooltipwidth, "MenuItem" )
			end
			pnl:SetToolTip( t.tooltip )
		end

		pnl.enabled = true
		function pnl:SetDisabled( val ) --Do some funky stuff to simulate enabling/disabling of a textbox
			pnl.enabled = not val
			pnl:SetEnabled( not val )
			pnl:SetPaintBackgroundEnabled( val )
		end

		--Replicated Convar Updating
		if t.repconvar then
			xlib.checkRepCvarCreated( t.repconvar )
			pnl:SetValue( GetConVar( t.repconvar ):GetString() )
			function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
				if cl_cvar == t.repconvar:lower() then
					pnl:SetValue( new_val )
				end
			end
			hook.Add( "ULibReplicatedCvarChanged", "XLIB_" .. t.repconvar, pnl.ConVarUpdated )
			function pnl:UpdateConvarValue()
				RunConsoleCommand( t.repconvar, self:GetValue() )
			end
			function pnl:OnEnter()
				RunConsoleCommand( t.repconvar, self:GetValue() )
			end
			pnl.Think = function() end --Override think functions to remove Garry's convar check to (hopefully) speed things up
			pnl.ConVarNumberThink = function() end
			pnl.ConVarStringThink = function() end
			pnl.ConVarChanged = function() end
		end
		return pnl
	end

	function xlib.makelistview( t )
		local pnl = vgui.Create( "DListView", t.parent )
		pnl:SetPos( t.x, t.y )
		pnl:SetSize( t.w, t.h )
		pnl:SetMultiSelect( t.multiselect )
		pnl:SetHeaderHeight( t.headerheight or 20 )
		return pnl
	end

	function xlib.makecat( t )
		local pnl = vgui.Create( "DCollapsibleCategory", t.parent )
		pnl:SetPos( t.x, t.y )
		pnl:SetSize( t.w, t.h )
		pnl:SetLabel( t.label or "" )
		pnl:SetContents( t.contents )
		if t.expanded ~= nil then pnl:SetExpanded( t.expanded ) end
		if t.checkbox then
			pnl.checkBox = vgui.Create( "DCheckBox", pnl.Header )
			pnl.checkBox:SetPos( t.w-18, 5 )
			pnl.checkBox:SetChecked( pnl:GetExpanded() )
			function pnl.checkBox:DoClick()
				self:Toggle()
				pnl:Toggle()
			end
			function pnl.Header:OnMousePressed( mcode )
				if ( mcode == MOUSE_LEFT ) then
					self:GetParent():Toggle()
					self:GetParent().checkBox:Toggle()
				return end
				return self:GetParent():OnMousePressed( mcode )
			end
		end

		function pnl:SetOpen( bVal )
			if not self:GetExpanded() and bVal then
				pnl.Header:OnMousePressed( MOUSE_LEFT ) --Call the mouse function so it properly toggles the checkbox state (if it exists)
			elseif self:GetExpanded() and not bVal then
				pnl.Header:OnMousePressed( MOUSE_LEFT )
			end
		end

		return pnl
	end

	function xlib.makepanel( t )
		local pnl = vgui.Create( "DPanel", t.parent )
		pnl:SetPos( t.x, t.y )
		pnl:SetSize( t.w, t.h )
		if t.visible ~= nil then pnl:SetVisible( t.visible ) end
		return pnl
	end

	function xlib.makeXpanel( t )
		pnl = vgui.Create( "DPanel_XLIB", t.parent )
		pnl:MakePopup()
		pnl:SetPos( t.x, t.y )
		pnl:SetSize( t.w, t.h )
		return pnl
	end

	function xlib.makemultichoice( t )
		local pnl = vgui.Create( "DMultiChoice", t.parent )
		pnl:SetText( t.text or "" )
		pnl:SetPos( t.x, t.y )
		pnl:SetSize( t.w, t.h or 20 )
		pnl.TextEntry.selectAll = t.selectall
		pnl:SetEditable( t.enableinput or false )

		if ( t.enableinput == true ) then
			pnl.DropButton.OnMousePressed = function( button, mcode )
				hook.Call( "OnTextEntryLoseFocus", nil, pnl.TextEntry )
				pnl:OpenMenu( pnl.DropButton )
			end
			pnl.TextEntry.OnMousePressed = function( self )
				hook.Call( "OnTextEntryGetFocus", nil, self )
			end
			pnl.TextEntry.OnLoseFocus = function( self )
				hook.Call( "OnTextEntryLoseFocus", nil, self )
				self:UpdateConvarValue()
			end
		end

		if not t.tooltipwidth then t.tooltipwidth = 250 end
		if t.tooltip then
			if t.tooltipwidth ~= 0 then
				t.tooltip = xlib.wordWrap( t.tooltip, t.tooltipwidth, "MenuItem" )
			end
			pnl:SetToolTip( t.tooltip )
		end

		if t.choices then
			for i, v in ipairs( t.choices ) do
				pnl:AddChoice( v )
			end
		end

		pnl.enabled = true
		function pnl:SetDisabled( val ) --Do some funky stuff to simulate enabling/disabling of a textbox
			self.enabled = not val
			self.TextEntry:SetEnabled( not val )
			self.TextEntry:SetPaintBackgroundEnabled( val )
			self.DropButton:SetDisabled( val )
			self.DropButton:SetMouseInputEnabled( not val )
			self:SetMouseInputEnabled( not val )
		end
		if t.disabled then pnl:SetDisabled( t.disabled ) end

		--Add support for Spacers
		function pnl:OpenMenu( pControlOpener ) --Garrys function with no comments, just adding a few things.
			if ( pControlOpener ) then
				if ( pControlOpener == self.TextEntry ) then
					return
				end
			end
			if ( #self.Choices == 0 ) then return end
			if ( self.Menu ) then
				self.Menu:Remove()
				self.Menu = nil
				return
			end
			self.Menu = DermaMenu()
				for k, v in pairs( self.Choices ) do
					if v == "--*" then --This is the string to determine where to add the spacer
						self.Menu:AddSpacer()
					else
						self.Menu:AddOption( v, function() self:ChooseOption( v, k ) end )
					end
				end
				local x, y = self:LocalToScreen( 0, self:GetTall() )
				self.Menu:SetMinimumWidth( self:GetWide() )
				self.Menu:Open( x, y, false, self )
			ULib.queueFunctionCall( self.RequestFocus, self ) --Force the menu to request focus when opened, to prevent the menu being open, but the focus being to the controls behind it.
		end

		--Replicated Convar Updating
		if t.repconvar then
			xlib.checkRepCvarCreated( t.repconvar )
			if t.isNumberConvar then --This is for convar settings stored via numbers (like ulx_rslotsMode)
				if t.numOffset == nil then t.numOffset = 1 end
				local cvar = GetConVar( t.repconvar ):GetInt()
				if tonumber( new_val ) and cvar + t.numOffset <= #pnl.Choices and cvar + t.numOffset > 0 then
					pnl:ChooseOptionID( cvar + t.numOffset )
				else
					pnl:SetText( "Invalid Convar Value" )
				end
				function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
					if cl_cvar == t.repconvar:lower() then
						if tonumber( new_val ) and new_val + t.numOffset <= #pnl.Choices and new_val + t.numOffset > 0 then
							pnl:ChooseOptionID( new_val + t.numOffset )
						else
							pnl:SetText( "Invalid Convar Value" )
						end
					end
				end
				hook.Add( "ULibReplicatedCvarChanged", "XLIB_" .. t.repconvar, pnl.ConVarUpdated )
				function pnl:OnSelect( index )
					RunConsoleCommand( t.repconvar, tostring( index - t.numOffset ) )
				end
			else  --Otherwise, use each choice as a string for the convar
				pnl:SetText( GetConVar( t.repconvar ):GetString() )
				function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
					if cl_cvar == t.repconvar:lower() then
						pnl:SetText( new_val )
					end
				end
				hook.Add( "ULibReplicatedCvarChanged", "XLIB_" .. t.repconvar, pnl.ConVarUpdated )
				function pnl:OnSelect( index, value )
					RunConsoleCommand( t.repconvar, value )
				end
			end
		end
		return pnl
	end

	function xlib.maketree( t )
		local pnl = vgui.Create( "DTree", t.parent )
		pnl:SetPos( t.x, t.y )
		pnl:SetSize( t.w, t.h )
		return pnl
	end

	--TODO: Remove this when using not garry's color thingy
	CreateClientConVar( "colour_r", 0, false, false )
	CreateClientConVar( "colour_g", 0, false, false )
	CreateClientConVar( "colour_b", 0, false, false )
	CreateClientConVar( "colour_a", 0, false, false )
	
	--If we aren't in the sandbox gamemode, then "CtrlColor" isn't included-- Don't see anything wrong with including it here!
	if gmod.GetGamemode().Name ~= "Sandbox" then
		include( 'sandbox/gamemode/spawnmenu/controls/CtrlColor.lua' )
	end
	--Color picker used in Garry's menus
	function xlib.makecolorpicker( t )
		local pnl = vgui.Create( "CtrlColor", t.parent )
			if t.removealpha == true then
				--Remove the alpha numberwang, also align the rgb numberwangs on the bottom
				pnl.txtA:Remove()
				pnl.SetConVarA = nil
				function pnl:PerformLayout()
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
				pnl.Mixer:Remove()
				--Remove the default mixer and replace with a mixer without the alpha bar
				pnl.Mixer = vgui.Create( "XLIBColorMixerNoAlpha", pnl )
			end
			if not t.ignorecvars then
				pnl:SetConVarR( "colour_r" )
				pnl:SetConVarG( "colour_g" )
				pnl:SetConVarB( "colour_b" )
			end
			if not t.removealpha then
				pnl:SetConVarA( "colour_a" )
			end

			pnl:SetPos( t.x, t.y )
			pnl:SetSize( t.w, t.h )
		return pnl
	end

	--Thanks to Megiddo for this code! :D
	function xlib.wordWrap( text, width, font )
		surface.SetFont( font )
		local output = ""
		local pos_start, pos_end = 1, 1
		while true do
			local begin, stop = text:find( "%s+", pos_end + 1 )
			if begin == nil then
				output = output .. text:sub( pos_start ):Trim()
				break
			elseif (surface.GetTextSize( text:sub( pos_start, begin ):Trim() ) > width and pos_end - pos_start > 0) then
				output = output .. text:sub( pos_start, pos_end ):Trim() .. "\n"
				pos_start = pos_end + 1
			end
			pos_end = stop
		end
		return output
	end
	
	--Includes Garry's ever-so-awesome progress bar!
	include( "menu/ProgressBar.lua" )
	function xlib.makeprogressbar( t )
		pnl = vgui.Create( "DProgressBar", t.parent )
		pnl:SetPos( t.x, t.y )
		pnl:SetSize( t.w or 100, t.h or 20 )
		pnl:SetMin( t.min or 0 )
		pnl:SetMax( t.max or 100 )
		pnl:SetValue( t.value or 0 )
		if t.percent then
			pnl.m_bLabelAsPercentage = true
			pnl:UpdateText()
		end
		return pnl
	end

	function xlib.checkRepCvarCreated( cvar )
		if GetConVar( cvar ) == nil then
			CreateClientConVar( cvar:lower(), 0, false, false ) --Replicated cvar hasn't been created via ULib. Create a temporary one to prevent errors
		end
	end

	--------------------------------------------------
	--Megiddo and I are sick of number sliders and their spam of updating convars. Lets modify the NumSlider so that it only sets the value when the mouse is released! (And allows for textbox input)
	--------------------------------------------------
	function xlib.makeslider( t )
		local pnl = vgui.Create( "DNumSlider", t.parent )
		if t.fixclip == nil or t.fixclip == true then --Fixes clipping errors on the Knob by default, but disables it if specified.
			pnl.Slider.Knob:SetSize( 13, 13 )
			pnl.Slider.Knob:SetPos( 0, 0 )
			pnl.Slider.Knob:NoClipping( false )
		end
		pnl:SetText( t.label or "" )
		pnl:SetMinMax( t.min or 0, t.max or 100 )
		pnl:SetDecimals( t.decimal or 0 )
		if t.convar then pnl:SetConVar( t.convar ) end
		if not t.tooltipwidth then t.tooltipwidth = 250 end
		if t.tooltip then
			if t.tooltipwidth ~= 0 then
				t.tooltip = xlib.wordWrap( t.tooltip, t.tooltipwidth, "MenuItem" )
			end
			pnl:SetToolTip( t.tooltip )
		end
		pnl:SetPos( t.x, t.y )
		pnl:SetWidth( t.w )
		pnl:SizeToContents()
		pnl.Label:SetTextColor( t.textcolor )
		pnl.Wang.TextEntry.selectAll = t.selectall
		if t.value then pnl:SetValue( t.value ) end

		pnl.Wang.TextEntry.OnLoseFocus = function( self )
			hook.Call( "OnTextEntryLoseFocus", nil, self )
			self:UpdateConvarValue()
			pnl.Wang:SetValue( pnl.Wang.TextEntry:GetValue() )
		end

		--Slider update stuff (Most of this code is copied from the default DNumSlider)
		pnl.Slider.TranslateValues = function( self, x, y )
			--Store the value and update the textbox to the new value
			pnl_x = x
			local val = pnl.Wang.m_numMin + ( ( pnl.Wang.m_numMax - pnl.Wang.m_numMin ) * x )
			if pnl.Wang.m_iDecimals == 0 then
				val = Format( "%i", val )
			else
				val = Format( "%." .. pnl.Wang.m_iDecimals .. "f", val )
				-- Trim trailing 0's and .'s 0 this gets rid of .00 etc
				val = string.TrimRight( val, "0" )
				val = string.TrimRight( val, "." )
			end
			pnl.Wang.TextEntry:SetText( val )
			return x, y
		end
		pnl.Slider.OnMouseReleased = function( self, mcode )
			pnl.Slider:SetDragging( false )
			pnl.Slider:MouseCapture( false )
			--Update the actual value to the value we stored earlier
			pnl.Wang:SetFraction( pnl_x )
		end

		--This makes it so the value doesnt change while you're typing in the textbox
		pnl.Wang.TextEntry.OnTextChanged = function() end

		--NumberWang update stuff(Most of this code is copied from the default DNumberWang)
		pnl.Wang.OnCursorMoved = function( self, x, y )
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
			pnl_fVal = fVal

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

		pnl.Wang.OnMouseReleased = function( self, mousecode )
			if ( self.Dragging ) then
				self:EndWang()
				self:SetValue( pnl_fVal )
			return end
		end

		pnl.enabled = true
		pnl.SetDisabled = function( self, bval )
			self.enabled = not bval
			self:SetMouseInputEnabled( not bval )
			self.Slider.Knob:SetVisible( not bval )
			self.Wang.TextEntry:SetPaintBackgroundEnabled( bval )
		end
		if t.disabled then pnl:SetDisabled( t.disabled ) end

		--Replicated Convar Updating
		if t.repconvar then
			xlib.checkRepCvarCreated( t.repconvar )
			pnl:SetValue( GetConVar( t.repconvar ):GetFloat() )
			function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
				if cl_cvar == t.repconvar:lower() then
					pnl:SetValue( new_val )
				end
			end
			hook.Add( "ULibReplicatedCvarChanged", "XLIB_" .. t.repconvar, pnl.ConVarUpdated )
			function pnl:OnValueChanged( val )
				RunConsoleCommand( t.repconvar, tostring( val ) )
			end
			pnl.Wang.TextEntry.ConVarStringThink = function() end --Override think functions to remove Garry's convar check to (hopefully) speed things up
			pnl.ConVarNumberThink = function() end
			pnl.ConVarStringThink = function() end
			pnl.ConVarChanged = function() end
		end
		return pnl
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
	vgui.Register( "XLIBColorMixerNoAlpha", PANEL, "DPanel" )


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

	derma.DefineControl( "DPanel_XLIB", "", PANEL, "EditablePanel" )
end

hook.Add( "ULibLocalPlayerReady", "InitXLIB", xlib_init, -20 )