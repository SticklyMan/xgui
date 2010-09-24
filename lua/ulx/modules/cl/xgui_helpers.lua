--xgui_helpers -- by Stickly Man!
--A set of generic functions to help with various XGUI-related things.

local function xgui_helpers()
	-----------------
	--Derma Additions   --These shouldn't break anything, since these functions don't exist.
	-----------------
	
	--A quick function to get the value of a DMultiChoice (I like consistency)
	function DMultiChoice:GetValue()
		return self.TextEntry:GetValue()
	end
	
	function DCheckBoxLabel:GetValue()
		return self:GetChecked()
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
	
	--Clears a DTree.
	function DTree:Clear()
		for item, node in pairs( self.Items ) do
			node:Remove()
			self.Items[item] = nil
		end
		self.m_pSelectedItem = nil
		self:InvalidateLayout()
	end
	
	--This function is used to replace the current animation:Start() function to allow for animation times of 0.
	function x_anim_Start( self, Length, Data )
		if ( Length == 0 ) then
			self.Finished = true
			self.EndTime = SysTime() + Length - 1
			self.Length = 1
		else
			self.EndTime = SysTime() + Length
			self.Length = Length
			self.Finished = nil
		end
		self.Started = true
		self.StartTime = SysTime()
		self.Running = true
		self.Data = Data
	end
	
	
	----------------------------------
	--Code specific to  the XGUI base.
	----------------------------------
	function x_makeXGUIbase()
		local xgui_base = vgui.Create( "DPropertySheet" )
		xgui_base:SetVisible( false )
		xgui_base:SetPos( ScrW()/2 - 300, ScrH()/2 - 200 )
		xgui_base:SetSize( 600, 400 )
		xgui_base:SetFadeTime( xgui.settings.animTime )
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
		
		--Modify the animation since transparent frames on top of each other don't render correctly.
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
			
			if ( anim.Finished ) then
				print( "Finished!", old:GetAlpha(), new:GetAlpha() )
				old:SetVisible( false )
				new:SetVisible( true )
				old:SetAlpha( 0 )
				new:SetAlpha( 255 )
			end
		end
		xgui_base.animFade = Derma_Anim( "Fade", xgui_base, xgui_base.CrossFade )
		xgui_base.animFade.Start = x_anim_Start
		
		--Fade in/out effect when opening/closing XGUI!
		function xgui_base:FadeIn( anim, delta, panel )
			if ( anim.Started ) then
				panel:SetAlpha( 0 )
			end
			panel:SetAlpha( delta*255 )
			panel:GetActiveTab():GetPanel():SetAlpha( delta*255 )
			if ( anim.Finished ) then
				panel:SetAlpha( 255 )
			end
		end
		xgui_base.animFadeIn = Derma_Anim( "Fade", xgui_base, xgui_base.FadeIn )
		xgui_base.animFadeIn.Start = x_anim_Start
		
		function xgui_base:FadeOut( anim, delta, panel )
			panel:SetAlpha( 255-( delta*255 ) )
			panel:GetActiveTab():GetPanel():SetAlpha( 255-( delta*255 ) )
			
			if ( anim.Finished ) then
				panel:SetAlpha( 255 )
				panel:SetVisible( false )
				RememberCursorPosition()
				gui.EnableScreenClicker( false )
			end
		end
		xgui_base.animFadeOut = Derma_Anim( "Fade", xgui_base, xgui_base.FadeOut )
		xgui_base.animFadeOut.Start = x_anim_Start

		function xgui_base:Think()
			self.animFade:Run()
			self.animFadeIn:Run()
			self.animFadeOut:Run()
		end
	
		return xgui_base
	end
	
	
	-------------------
	--ULIB XGUI helpers
	-------------------
	--Helper function to parse access tag for a particular argument
	function getTagArgNum( tag, argnum )
		return tag and string.Explode( " ", tag )[argnum]
	end

	--Load control interpretations for ULib argument types
	function ULib.cmds.BaseArg.x_getcontrol( arg, argnum )
		return xlib.makelabel{ label="Not Supported" }
	end
	
	function ULib.cmds.NumArg.x_getcontrol( arg, argnum )
		local access, tag = LocalPlayer():query( arg.cmd )
		local restrictions = {}
		ULib.cmds.NumArg.processRestrictions( restrictions, arg, getTagArgNum( tag, argnum ) )
		
		local defvalue = arg.min
		if table.HasValue( arg, ULib.cmds.optional ) then defvalue = arg.default end
		
		local maxvalue = restrictions.max
		if restrictions.max == nil and defvalue > 100 then maxvalue = defvalue end
		
		return xlib.makeslider{ min=restrictions.min, max=maxvalue, value=defvalue, label=arg.hint or "NumArg" }
	end
	
	function ULib.cmds.StringArg.x_getcontrol( arg, argnum )
		local access, tag = LocalPlayer():query( arg.cmd )
		local restrictions = {}
		ULib.cmds.StringArg.processRestrictions( restrictions, arg, getTagArgNum( tag, argnum ) )
		
		local is_restricted_to_completes = table.HasValue( arg, ULib.cmds.restrictToCompletes ) -- Program-level restriction (IE, ulx map)
			or restrictions.playerLevelRestriction -- The player's tag specifies only certain strings
		
		if is_restricted_to_completes then
			xgui_temp = xlib.makemultichoice{ text=arg.hint or "StringArg" }
			for _, v in ipairs( restrictions.restrictedCompletes ) do
				xgui_temp:AddChoice( v )
			end
			return xgui_temp
		elseif restrictions.restrictedCompletes then
			-- This is where there needs to be both a drop down AND an input box
			local temp = xlib.makemultichoice{ text=arg.hint, choices=restrictions.restrictedCompletes, enableinput=true, focuscontrol=true }
			temp.TextEntry.OnEnter = function( self )
				self:GetParent():OnEnter()
			end
			return temp
		else
			return xlib.maketextbox{ text=arg.hint or "StringArg", focuscontrol=true }
		end
	end
	
	function ULib.cmds.PlayerArg.x_getcontrol( arg, argnum )
		local access, tag = LocalPlayer():query( arg.cmd )
		local restrictions = {}
		ULib.cmds.PlayerArg.processRestrictions( restrictions, LocalPlayer(), arg, getTagArgNum( tag, argnum ) )
		
		xgui_temp = xlib.makemultichoice{ text=arg.hint }
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
		return xlib.makelabel{ label=arg.hint or "CallingPlayer" }
	end
	
	function ULib.cmds.BoolArg.x_getcontrol( arg, argnum )
		-- There are actually not any restrictions possible on a boolarg...
		return xlib.makecheckbox{ label=arg.hint or "BoolArg" }
	end
end

hook.Add( "ULibLocalPlayerReady", "InitXguiHelpers", xgui_helpers, -15 )