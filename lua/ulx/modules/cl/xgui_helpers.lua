--XGUI helpers  -- by Stickly Man!
--A bunch of functions to help with creating Derma elements-- Makes code look somewhat nicer!

--[[ Table Variables Quick Reference
STRINGS:
label - used for text near a control
tooltip - used to show info when a mouse is hovering over a control
convar - used to link a control to a convar
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
convarcontents - table storing additional information used with convars ( e.g, multichoice contents and functions )

BOOL:
multiselect - Allow multiple selects
autosize - Used with the panel list, it will size the panel based on its contents
enableinput - Used with textbox/multichoice, will enable/disable input
vscroll, hscroll - Enables/disabels vertical and horizontal scrollbars
focuscontrol - Determines whether to specify special functions for xgui_base's keyboard focus handling stuff
expanded - Determines whether or not a category is expanded when it is created
nopopup - Used only with makeframepopup, will set whether the frame pops up or not
showclose - Determines whether to show X button on makeframepopup
percent - If true, progressbar will show as a %
disabled - Used with controls (as of now, only buttons) to determine if it is disabled.
]]--

local function xgui_helpers()
	function x_makecheckbox( t )
		local xgui_temp = vgui.Create( "DCheckBoxLabel", t.parent )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetText( t.label or "" )
		xgui_temp:SizeToContents()
		xgui_temp:SetValue( t.value or 0 )
		xgui_temp:SetConVar( t.convar )
		if t.textcolor then xgui_temp:SetTextColor( t.textcolor ) end
		if t.tooltip then xgui_temp:SetTooltip( t.tooltip ) end
		return xgui_temp
	end

	function x_makelabel( t )
		local xgui_temp = vgui.Create( "DLabel", t.parent )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetText( t.label or "" )
		xgui_temp:SizeToContents()
		xgui_temp:SetToolTip( t.tooltip )
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
		return xgui_temp
	end

	function x_maketextbox( t )
		local xgui_temp = vgui.Create( "DTextEntry", t.parent )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetWide( t.w )
		xgui_temp:SetTall( t.h or 20 )
		xgui_temp:SetEnterAllowed( true )
		if t.text then xgui_temp:SetText( t.text ) end
		if t.enableinput ~= nil then xgui_temp:SetEnabled( t.enableinput ) end
		xgui_temp:SetToolTip( t.tooltip )
		
		--For XGUI keyboard focus handling
		if ( t.focuscontrol == true ) then
			xgui_temp.OnGetFocus = function( self )
				self:SelectAllText()
				xgui_SetKeyboard( self )
			end
			xgui_temp.OnLoseFocus = function( self )
				xgui_ReleaseKeyboard()
				self:UpdateConvarValue()
			end
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
		xgui_temp:SetConVar( t.convar )
		return xgui_temp
	end

	function x_makemultichoice( t )
		local xgui_temp = vgui.Create( "DMultiChoice", t.parent )
		xgui_temp:SetText( t.text or "" )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetSize( t.w, t.h or 20 )
		xgui_temp:SetEditable( t.enableinput )
		xgui_temp:SetToolTip( t.tooltip )
		if t.convar then
			--Special code for setting convars
			for i, v in ipairs( t.convardata ) do
				xgui_temp:AddChoice( v )
			end
			xgui_temp.OnSelect = function( self )
				RunConsoleCommand( t.convar, tonumber(string.sub( self:GetValue(), 1, 2 ) ) )
			end
			xgui_temp:SetText( t.convardata[ GetConVarNumber( t.convar )+1 ] )
		
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
			xgui_temp:SetConVarR( "colour_r" )
			xgui_temp:SetConVarG( "colour_g" )
			xgui_temp:SetConVarB( "colour_b" )
			xgui_temp:SetConVarA( "colour_a" )
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
		if t.percent then xgui_temp:LabelAsPecentage() end -- Uh oh, Garry misspelled percentage, watch for this if it gets fixed!
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

	--A function for DMultiChoice that will remove a given option
	function DMultiChoice:RemoveChoice( choice )
		for i, v in ipairs( self.Choices ) do
			if v == choice then
				table.remove( self.Choices, i )
				return
			end
		end
	end

	--Get a line in a DListView by searching for a column value ( ID determines whether to return the line object, or the ID )
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
	
	--Clears all of the tabs in a DPropertySheet, parents removed panels to xgui_null.
	function DPropertySheet:Clear()
		for _, Sheet in ipairs( self.Items ) do
			Sheet.Panel:SetParent( xgui_null )
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
		xgui_base:SetFadeTime( .12 )
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
				--Since we're using Frames instead of panels, this will set the position to the correct location.
				ActivePanel:SetPos( ScrW()/2 - 295, ScrH()/2 - 173 )
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
		
		return xgui_base
	end
	--------------------------------------------------
	--Megiddo and I are sick of number sliders and their spam of updating convars. Lets modify the NumSlider so that it only sets the convar when the mouse is released! (And allows for textbox input)
	--------------------------------------------------
	function x_makeslider( t )
		local xgui_temp = vgui.Create( "DNumSlider", t.parent )
		xgui_temp:SetText( t.label or "" )
		xgui_temp:SetMinMax( t.min or 0, t.max or 100 )
		xgui_temp:SetDecimals( t.decimal or 0 )
		xgui_temp:SetConVar( t.convar )
		xgui_temp:SetTooltip( t.tooltip )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetWidth( t.w )
		xgui_temp:SizeToContents()
		if t.value then xgui_temp:SetValue( t.value ) end
		
		--Keyboard focus stuff
		xgui_temp.Wang.TextEntry.OnGetFocus = function()
			xgui_SetKeyboard()
		end
		xgui_temp.Wang.TextEntry.OnLoseFocus = function( self )
			self:UpdateConvarValue()
			xgui_temp.Wang:SetValue( xgui_temp.Wang.TextEntry:GetValue() )
			xgui_ReleaseKeyboard()
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
		
		return xgui_temp
	end

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
end

hook.Add( "ULibLocalPlayerReady", "InitHelpers", xgui_helpers, -20 )