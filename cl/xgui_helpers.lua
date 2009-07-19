--XGUI helpers  -- by Stickly Man!
--A bunch of functions to help with creating Derma elements-- Makes code look somewhat nicer!

--[[ Table Variables Quick Reference
STRINGS:
label - used for text near a control
tooltip - used to show info when a mouse is hovering over a control
convar - used to link a control to a convar
text - set the text in a textbox

NUMBERS:
x, y, w, h - x,y position, width, and height of control
min, max, decimal - used with a slider, sets the minimum and maximum value, and the number of decimal places to use.
spacing, padding - used with panellist, determines how much spacing there is between controls, and their distance from the edge of the panel
value = sets the value of a slider/numberwang

OTHER:
parent - the panel on which the control will be affixed
contents - for a category, this will be the panellist of controls in the category
color - sets a color (only used with colorpicker for now)

BOOL:
multiselect - Allow multiple selects
autosize - Used with the panel list, it will size the panel based on its contents
enableinput - Used with textbox, will enable/disable input
--]]

function x_makeslider( t )
	local xgui_temp = vgui.Create( "DNumSlider", t.parent )
	xgui_temp:SetText( t.label or "" )
	xgui_temp:SetMinMax( t.min, t.max )
	xgui_temp:SetDecimals( t.decimal or 0 )
	xgui_temp:SetConVar( t.convar )
	xgui_temp:SetTooltip( t.tooltip )
	xgui_temp:SetPos( t.x, t.y )
	xgui_temp:SetWidth( t.w )
	xgui_temp:SizeToContents()
	if t.value ~= nil then xgui_temp:SetValue( t.value ) end
	return xgui_temp
end

function x_makecheckbox( t )
	local xgui_temp = vgui.Create( "DCheckBoxLabel", t.parent )
	xgui_temp:SetPos( t.x, t.y )
	xgui_temp:SetText( t.label or "" )
	xgui_temp:SizeToContents()
	if t.convar ~= nil then xgui_temp:SetConVar( t.convar ) end
	if t.tooltip ~= nil then xgui_temp:SetTooltip( t.tooltip ) end
	return xgui_temp
end

function x_makelabel( t )
	local xgui_temp = vgui.Create( "DLabel", t.parent )
	xgui_temp:SetPos( t.x, t.y )
	xgui_temp:SetText( t.label or "" )
	xgui_temp:SizeToContents()
	return xgui_temp
end

function x_makepanelist( t )
	local xgui_temp = vgui.Create( "DPanelList", t.parent )
	xgui_temp:SetPos( t.x, t.y )
	xgui_temp:SetSize( t.w, t.h )
	xgui_temp:SetSpacing( t.spacing or 5 )
	xgui_temp:SetPadding( t.padding or 5 )
	xgui_temp:EnableVerticalScrollbar( true )
	xgui_temp:SetAutoSize( t.autosize )
	return xgui_temp
end

function x_makebutton( t )
	local xgui_temp = vgui.Create( "DButton", t.parent )
	xgui_temp:SetSize( t.w, t.h or 20 )
	xgui_temp:SetPos( t.x, t.y )
	xgui_temp:SetText( t.label or "" )
	return xgui_temp
end

function x_makeframepopup( t )
	local xgui_temp = vgui.Create( "DFrame", t.parent )
	xgui_temp:SetSize( t.w, t.h )
	xgui_temp:Center()
	xgui_temp:SetTitle( t.label or "" )
	xgui_temp:MakePopup()
	return xgui_temp
end

function x_maketextbox( t )
	local xgui_temp = vgui.Create( "DTextEntry", t.parent )
	xgui_temp:SetPos( t.x, t.y )
	xgui_temp:SetWide( t.w )
	if t.h == nil then t.h = 20 end
	xgui_temp:SetTall( t.h )
	xgui_temp:SetEnterAllowed( true )
	if t.text ~= nil then xgui_temp:SetText( t.text ) end
	if t.enableinput ~= nil then xgui_temp:SetEnabled( t.enableinput ) end
	xgui_temp:SetToolTip( t.tooltip )
	return xgui_temp
end

function x_makelistview( t )
	local xgui_temp = vgui.Create( "DListView", t.parent )
	xgui_temp:SetPos( t.x, t.y )
	xgui_temp:SetSize( t.w, t.h )
	xgui_temp:SetMultiSelect( t.multiselect )
	return xgui_temp
end

function x_makecat( t )
	local xgui_temp = vgui.Create( "DCollapsibleCategory", t.parent )
	xgui_temp:SetSize( 200, 50 )
	xgui_temp:SetLabel( t.label or "" )
	xgui_temp:SetContents( t.contents )
	return xgui_temp
end

function x_makepanel( t )
	local xgui_temp = vgui.Create( "DPanel", t.parent )
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
	xgui_temp:SetConVar( t.convar )
	return xgui_temp
end

--A simple color picker
function x_makecolorpicker( t )
	local xgui_temp = vgui.Create( "CtrlColor", parent )
		xgui_temp:SetConVarR( "colour_r" )
		xgui_temp:SetConVarG( "colour_g" )
		xgui_temp:SetConVarB( "colour_b" )
		xgui_temp:SetConVarA( "colour_a" )
		xgui_temp:SetPos( t.x, t.y )
		xgui_temp:SetSize( t.w, t.h )
	return xgui_temp
end