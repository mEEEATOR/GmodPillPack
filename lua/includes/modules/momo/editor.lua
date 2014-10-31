if SERVER then AddCSLuaFile() return end


--
-- prop_generic is the base for all other properties. 
-- All the business should be done in :Setup using inline functions.
-- So when you derive from this class - you should ideally only override Setup.
--

local PANEL = {}

function PANEL:Init()

end

function PANEL:Setup( vars )
	self:Clear()

	if vars.options then //use select
		local combo = vgui.Create( "DComboBox", self )
		combo:Dock( FILL )
		combo:DockMargin( 0, 1, 2, 2 )
		//combo:SetValue(vars.options[1])

		for id, thing in pairs( vars.options or {} ) do
			combo:AddChoice(thing)
		end
		
		self.IsEditing = function( self )
			return combo:IsMenuOpen()
		end
		
		self.SetValue = function( self, val )
			combo:ChooseOption(val)
		end
		
		combo.OnSelect = function( _, id, val, data )
			self:ValueChanged( data, true )
		end
		
		combo.Paint = function( combo, w, h )
			if self:IsEditing() or self:GetRow():IsHovered() or self:GetRow():IsChildHovered( 6 ) then
				DComboBox.Paint( combo, w, h )
			end
		end
	elseif vars.type=="number" then
		local ctrl = self:Add( "DNumSlider" )
		ctrl:Dock(FILL)
		ctrl:SetDecimals(3)

		-- Apply vars
		ctrl:SetMin(vars.min or -100000)
		ctrl:SetMax(vars.max or 100000)

		-- The label needs mouse input so we can scratch
		self:GetRow().Label:SetMouseInputEnabled( true )
		-- Take the scratch and place it on the Row's label
		ctrl.Scratch:SetParent( self:GetRow().Label )
		-- Hide the numslider's label
		ctrl.Label:SetVisible( false )
		-- Move the text area to the left
		ctrl.TextArea:Dock( LEFT )
		-- Add a margin onto the slider - so it's not right up the side
		ctrl.Slider:DockMargin( 0, 3, 8, 3 )

		-- Return true if we're editing
		self.IsEditing = function( self )
			return ctrl:IsEditing()
		end

		-- Set the value
		self.SetValue = function(self,val)
			ctrl:SetValue(val) 
		end

		-- Alert row that value changed
		ctrl.OnValueChanged = function(ctrl,newval)
			self:ValueChanged(newval)
		end

		self.Paint = function()
			-- PERFORMANCE !!!
			ctrl.Slider:SetVisible( self:IsEditing() || self:GetRow():IsChildHovered( 6 ) )
		end
	elseif vars.type=="string" then
		local text = self:Add( "DTextEntry" )
		text:SetDrawBackground(false)
		text:Dock(FILL)

		self.IsEditing = function(self)
			return text:IsEditing()
		end

		self.SetValue = function(self,val)
			text:SetText(util.TypeToString(val)) 
		end

		text.OnValueChange = function(text,newval)
			self:ValueChanged(newval)
		end
	elseif vars.type=="boolean" then
		local checkbox = self:Add("DCheckBox")
		checkbox:SetPos(0,2)

		self.IsEditing = function( self )
			return false
		end

		self.SetValue = function(self,val)
			checkbox:SetValue(val)
		end

		checkbox.OnChange = function(_,newval)
			self:ValueChanged(newval)
			if !newval then self.m_pRow:Hide() end

			self.m_pRow:GetParent():InvalidateLayout(true)
			self.m_pRow:GetParent():GetParent():InvalidateLayout()

		end

		/*self.m_pRow.PerformLayout = function(row)
			row:SetTall(checkbox.m_bValue and 0 or 20)
			row.Label:SetWide(row:GetWide() * 0.45)
			print(checkbox.m_bValue)
			print("LAYOUT!")
		end*/
	else
		self.IsEditing = function( self )
			return false
		end

		self.SetValue = function(self,val)
			
		end
	end
end

derma.DefineControl( "DProperty_Momo", "", PANEL, "DProperty_Generic" )


concommand.Add("momo_editor",function()
	/*local editor_src = [[
<html>
	<head>
		<style>
			html {
				background-color: white;
				border: 8px solid #111;
				border-top-width: 32px;
				font-family: arial;
				-webkit-user-select: none;
				
				box-sizing: border-box;
				height: 100%;
				padding: 0;
				overflow: hidden;
			}
			body {
				height: 100%;
				margin: 0;
			}
			button#exit {
				width: 60px;
				height: 20px;
				font-weight: bold;
				position: absolute;
				right: 8px;
				top: 0;
				color: white;
				background-color: #BA3F3F;
				border: none;
			}
			button#exit:hover {
				background-color: #FF3D3D;
			}
			h1 {
				color: #ccc;
				text-align: center;
				font-size: 24px;
				position: absolute;
				width: 100%;
				//top: 2px;
				//left: -8px;
				margin: 0;
			}
			div#component-picker {
				border-right: 2px solid black;
				width: 250px;
				height: 100%;
				background-color: #ccc;
			}
			div#component-picker h2 {
				height: 50px;
				width: 100%;
				color: lime;
			}
			div#content {
				width: 100%;
				height: 100%;
				background-color: red;
			}
		</style>
	</head>
	<body>
		<h1>DAT EDITOR</h1>
		<button id="exit" onclick="momo_editor.exit()">X</button>
		<div id="component-picker">
			<h2>asdf</h2>

		</div>
	</body>
</html>
	]]*/

	//local editor = vgui.Create("DHTML")
	//local editor = vgui.Create("DProperties")
	//editor:SetPos(50,50)
	//editor:SetSize(ScrW()-100,ScrH()-100)
	//editor:SetHTML(editor_src)
	//editor:MakePopup()
	//editor:AddFunction("momo_editor","exit",function() editor:Remove() end)
	local test_name = "sample"

	local test_form = {
		spawnable={
			_class="spawnable",
			name="I am a sample!",
			category="momo",
			random_skin=true,
			z=true
		},
		core={
			_class="core-physical",
			collision_shape = "model",
			material = "flesh",
			mass = 20
		},
		zzzz={
			_class="subtype"
		}
	}

	local comp_defs = momo._components

	local window = vgui.Create( "DFrame" )
	window:SetSize( 600, 400 )
	window:SetTitle('Editing Form "'..test_name..'".')
	window:Center()
	window:SetSizable( true )
	window:MakePopup()

	local control = window:Add( "DProperties" )
	control:Dock( FILL )

	for comp,tab in pairs(test_form) do
		if !isnumber(comp) then
			local catname = comp.." ["..tab._class.."]"
			local def  = comp_defs[tab._class]
			control:GetCategory(catname,true).Header:SetToolTip(def.info) //TODO! Iterate over schema instead of the table we are given
			for k,schema in pairs(def.schema) do
				if !isnumber(k) then
					local row = control:CreateRow(catname,k)
					row:Setup("Momo",schema)
					row:SetValue(tab[k])
					row:SetToolTip(schema.info)
				end
			end
		end
	end
end)