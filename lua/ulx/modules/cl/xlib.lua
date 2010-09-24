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
		if t.tooltip then pnl:SetTooltip( t.tooltip ) end
		if t.disabled then pnl:SetDisabled( t.disabled ) end
		--Replicated Convar Updating
		if t.repconvar then
			if GetConVar( t.repconvar ) == nil then
				CreateConVar( t.repconvar, 0 ) --Replicated cvar hasn't been created via ULib. Create a temporary one to prevent errors
			end
			pnl:SetValue( GetConVar( t.repconvar ):GetBool() )
			function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
				if cl_cvar == t.repconvar then
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
		pnl:SizeToContents()
		pnl:SetToolTip( t.tooltip )
		if t.font then pnl:SetFont( t.font ) end
		if t.w then pnl:SetWidth( t.w ) end
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
	
	function xlib.makeframepopup( t )
		local pnl = vgui.Create( "DFrame", t.parent )
		pnl:SetSize( t.w, t.h )
		pnl:SetPos( t.x or ScrW()/2-t.w/2, t.y or ScrH()/2-t.h/2 )
		pnl:SetTitle( t.label or "" )
		if t.draggable ~= nil then pnl:SetDraggable( t.draggable ) end
		if t.nopopup ~= true then pnl:MakePopup() end
		if t.showclose ~= nil then pnl:ShowCloseButton( t.showclose ) end
		if t.alwaysontop ~= nil then pnl:SetDrawOnTop( t.alwaysontop ) end
		if t.skin then pnl:SetSkin( t.skin ) end
		return pnl
	end

	function xlib.maketextbox( t )
		local pnl = vgui.Create( "DTextEntry", t.parent )
		pnl:SetPos( t.x, t.y )
		pnl:SetWide( t.w )
		pnl:SetTall( t.h or 20 )
		pnl:SetEnterAllowed( true )
		pnl.enabled = true
		if t.convar then pnl:SetConVar( t.convar ) end
		if t.text then pnl:SetText( t.text ) end
		if t.enableinput then pnl:SetEnabled( t.enableinput ) end
		pnl:SetToolTip( t.tooltip )
		
		function pnl:SetDisabled( val ) --Do some funky stuff to simulate enabling/disabling of a textbox
			pnl.enabled = not val
			pnl:SetEnabled( not val )
			pnl:SetPaintBackgroundEnabled( val )
		end
		
		--For XGUI keyboard focus handling
		if ( t.focuscontrol == true ) then
			pnl.OnGetFocus = function( self )
				if self.enabled == true then
					self:SelectAllText()
					xgui.base:SetKeyboardInputEnabled( true )
				end
			end
			pnl.OnLoseFocus = function( self )
				xgui.base:SetKeyboardInputEnabled( false )
				self:UpdateConvarValue()
			end
		end
		--Replicated Convar Updating
		if t.repconvar then
			if GetConVar( t.repconvar ) == nil then
				CreateConVar( t.repconvar, 0 ) --Replicated cvar hasn't been created via ULib. Create a temporary one to prevent errors
			end
			pnl:SetValue( GetConVar( t.repconvar ):GetString() )
			function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
				if cl_cvar == t.repconvar then
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
		pnl:SetKeyboardInputEnabled( false )
		pnl:SetMouseInputEnabled( true )
		pnl.IsXPanel = true
		pnl:SetPos( t.x, t.y )
		pnl:SetSize( t.w, t.h )
		return pnl
	end
	
	function xlib.makenumberwang( t )
		local pnl = vgui.Create( "DNumberWang", t.parent )
		pnl:SetMinMax( t.min or 0, t.max or 100 )
		pnl:SetDecimals( t.decimal or 0 )
		pnl:SetPos( t.x, t.y )
		pnl:SetWidth( t.w )
		pnl:SizeToContents()
		pnl:SetValue( t.value )
		if t.convar then pnl:SetConVar( t.convar ) end
		return pnl
	end

	function xlib.makemultichoice( t )
		local pnl = vgui.Create( "DMultiChoice", t.parent )
		pnl:SetText( t.text or "" )
		pnl:SetPos( t.x, t.y )
		pnl:SetSize( t.w, t.h or 20 )
		pnl:SetEditable( t.enableinput )

		if ( t.focuscontrol == true ) then
			pnl.DropButton.OnMousePressed = function( button, mcode ) 
				xgui.base:SetKeyboardInputEnabled( false )
				pnl:OpenMenu( pnl.DropButton )
			end
			pnl.TextEntry.OnMousePressed = function( self )
				self:SelectAllText()
				xgui.base:SetKeyboardInputEnabled( true )
			end
			pnl.TextEntry.OnLoseFocus = function( self )
				xgui.base:SetKeyboardInputEnabled( false )
				self:UpdateConvarValue()
			end
		end
		pnl:SetToolTip( t.tooltip )
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
			if GetConVar( t.repconvar ) == nil then
				CreateConVar( t.repconvar, 0 ) --Replicated cvar hasn't been created via ULib. Create a temporary one to prevent errors
			end
			if t.isNumberConvar then --This is for convar settings stored via numbers (like ulx_rslotsMode)
				if t.numOffset == nil then t.numOffset = 1 end
				local cvar = GetConVar( t.repconvar ):GetInt()
				if cvar + t.numOffset <= #pnl.Choices and cvar + t.numOffset > 0 then
					pnl:ChooseOptionID( cvar + t.numOffset )
				else
					pnl:SetText( "Invalid Convar Value" )
				end
				function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
					if cl_cvar == t.repconvar then
						if new_val + t.numOffset <= #pnl.Choices and new_val + t.numOffset > 0 then
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
					if cl_cvar == t.repconvar then
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

	function xlib.makecombobox( t )
		local pnl = vgui.Create( "DComboBox", t.parent )
		pnl:SetPos( t.x, t.y )
		pnl:SetSize( t.w, t.h )
		pnl:SetAutoSize( t.autosize )
		return pnl
	end
	
	function xlib.maketree( t )
		local pnl = vgui.Create( "DTree", t.parent )
		pnl:SetPos( t.x, t.y )
		pnl:SetSize( t.w, t.h )
		return pnl
	end
	
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
			if t.focuscontrol then
				pnl.txtR.TextEntry.OnGetFocus = function( self )
					self:SelectAllText()
					xgui.base:SetKeyboardInputEnabled( true )
				end
				pnl.txtR.TextEntry.OnLoseFocus = function( self )
					xgui.base:SetKeyboardInputEnabled( false )
					self:UpdateConvarValue()
				end
				pnl.txtG.TextEntry.OnGetFocus = function( self )
					self:SelectAllText()
					xgui.base:SetKeyboardInputEnabled( true )
				end
				pnl.txtG.TextEntry.OnLoseFocus = function( self )
					xgui.base:SetKeyboardInputEnabled( false )
					self:UpdateConvarValue()
				end
				pnl.txtB.TextEntry.OnGetFocus = function( self )
					self:SelectAllText()
					xgui.base:SetKeyboardInputEnabled( true )
				end
				pnl.txtB.TextEntry.OnLoseFocus = function( self )
					xgui.base:SetKeyboardInputEnabled( false )
					self:UpdateConvarValue()
				end
				if pnl.txtA then
					pnl.txtA.TextEntry.OnGetFocus = function( self )
						self:SelectAllText()
						xgui.base:SetKeyboardInputEnabled( true )
					end
					pnl.txtA.TextEntry.OnLoseFocus = function( self )
						xgui.base:SetKeyboardInputEnabled( false )
						self:UpdateConvarValue()
					end
				end
			end
			pnl:SetPos( t.x, t.y )
			pnl:SetSize( t.w, t.h )
		return pnl
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
		pnl:SetTooltip( t.tooltip )
		pnl:SetPos( t.x, t.y )
		pnl:SetWidth( t.w )
		pnl:SizeToContents()
		pnl.Label:SetTextColor( t.textcolor )
		if t.value then pnl:SetValue( t.value ) end
		
		--Keyboard focus stuff
		pnl.Wang.TextEntry.OnGetFocus = function()
			xgui.base:SetKeyboardInputEnabled( true )
		end
		pnl.Wang.TextEntry.OnLoseFocus = function( self )
			self:UpdateConvarValue()
			pnl.Wang:SetValue( pnl.Wang.TextEntry:GetValue() )
			xgui.base:SetKeyboardInputEnabled( false )
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
			if GetConVar( t.repconvar ) == nil then
				CreateConVar( t.repconvar, 0 ) --Replicated cvar hasn't been created via ULib. Create a temporary one to prevent errors
			end
			pnl:SetValue( GetConVar( t.repconvar ):GetFloat() )
			function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
				if cl_cvar == t.repconvar then
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