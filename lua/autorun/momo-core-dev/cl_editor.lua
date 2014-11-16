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

	local is_deleted=false
	local set_deleted
	
	local setVal
	local getVal

	local ctrl

	local left_margin=0
	if vars.optional then
		local btn_optional = self:Add("DImageButton")
		btn_optional:SetImage("icon16/delete.png")
		btn_optional:SizeToContents()
		btn_optional:SetPos(0,1)
		btn_optional:SetToolTip("Delete Optional Property")
		btn_optional.DoClick = function()
			set_deleted(!is_deleted)
			if is_deleted then
				self:ValueChanged(nil,true) //TODO! THIS IS IMPORTANT! MUST SET TO -FALSE- IF INHERITED!
			else
				if ctrl then self:ValueChanged(getVal(),true) end
			end
		end

		local label_optional = self:Add("DLabel")
		label_optional:SetText("[Deleted]")
		label_optional:SetTextColor(Color(255,0,0))
		label_optional:SizeToContents()
		label_optional:Dock(FILL)
		label_optional:DockMargin(32, 0, 0, 0)
		label_optional:SetVisible(false)

		set_deleted = function(d)
			if is_deleted==d then return end

			if d then
				momo2.print("Delete!")
				btn_optional:SetImage("icon16/add.png")
				btn_optional:SetToolTip("Add Optional Property")
			else
				momo2.print("Add!")
				btn_optional:SetImage("icon16/delete.png")
				btn_optional:SetToolTip("Delete Optional Property")
			end

			if ctrl then
				ctrl:SetVisible(!d)
				if ctrl.Scratch then
					ctrl.Scratch:SetVisible(!d)
					//PrintTable(getmetatable(ctrl.Scratch))
				end
			end
			label_optional:SetVisible(d)

			is_deleted=d
		end

		left_margin=left_margin+16
	end

	if vars.options then //use select
		ctrl = self:Add("DComboBox")
		ctrl:Dock(FILL)
		ctrl:DockMargin(left_margin, 1, 2, 2)

		for id, thing in pairs( vars.options or {} ) do
			ctrl:AddChoice(thing)
		end
		
		self.IsEditing = function( self )
			return ctrl:IsMenuOpen()
		end
		
		setVal = function(val)
			ctrl:ChooseOption(val)
		end

		getVal = function()
			return ctrl:GetText()
		end
		
		ctrl.OnSelect = function( _, id, val, data )
			self:ValueChanged( val, true )
		end
		
		ctrl.Paint = function( combo, w, h )
			if self:IsEditing() or self:GetRow():IsHovered() or self:GetRow():IsChildHovered( 6 ) then
				DComboBox.Paint( combo, w, h )
			end
		end
	elseif vars.type=="number" then
		ctrl = self:Add( "DNumSlider" )
		ctrl:Dock(FILL)
		ctrl:DockMargin(left_margin, 0,0,0)
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

		ctrl:SetValue(vars.min or 0)

		-- Return true if we're editing
		self.IsEditing = function( self )
			return ctrl:IsEditing()
		end

		-- Set the value
		setVal = function(val)
			ctrl:SetValue(val) 
		end

		getVal = function()
			return ctrl:GetValue()
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
		ctrl = self:Add( "DTextEntry" )
		ctrl:SetDrawBackground(false)
		ctrl:Dock(FILL)
		ctrl:DockMargin(left_margin, 0,0,0)

		self.IsEditing = function(self)
			return ctrl:IsEditing()
		end

		setVal = function(val)
			ctrl:SetText(util.TypeToString(val)) 
		end

		getVal = function()
			return ctrl:GetValue()
		end

		ctrl.OnValueChange = function(text,newval)
			self:ValueChanged(newval)
		end
	elseif vars.type=="boolean" then
		ctrl = self:Add("DCheckBox")
		ctrl:SetPos(left_margin,2)

		self.IsEditing = function( self )
			return ctrl:IsEditing()
		end

		setVal = function(val)
			ctrl:SetValue(val)
		end

		getVal = function()
			return ctrl.m_bValue
		end

		ctrl.OnChange = function(_,newval)
			self:ValueChanged(newval)
			/*
			if !newval then self.m_pRow:Hide() end

			self.m_pRow:GetParent():InvalidateLayout(true)
			self.m_pRow:GetParent():GetParent():InvalidateLayout()
			*/
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

		setVal = function(val)
			
		end

		getVal = function()

		end
	end

	self.SetValue = function( self, val )
		if vars.optional and !val then
			set_deleted(true)
		else
			if vars.optional then
				set_deleted(false)
			end

			setVal(val)
		end
	end

	self.GetValue = function(self)
		if is_deleted then return nil end
		return getVal()
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
		[0]={
			_class="spawnable",
			_name="dingus",
			name="I am a sample!",
			category="momo",
			random_skin=true,
			z=true
		},
		[1]={
			_class="core-physical",
			_name="dingus",
			collision_shape = "model",
			material = "flesh",
			mass = 20
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
		local catname = tab._name.." ["..tab._class.."]"
		local cdef  = comp_defs[tab._class]
		if !cdef then momo2.print("Editor could not find definition for '"..tab._class.."'!") continue end
		local catpanel = control:GetCategory(catname,true)
		catpanel.Header:SetToolTip(cdef.info) //TODO! Iterate over schema instead of the table we are given
		
		local btn_delete = catpanel.Header:Add("DImageButton")
		btn_delete:SetImage("icon16/cancel.png")
		btn_delete:SizeToContents()
		btn_delete:SetPos(570,4)
		btn_delete:SetToolTip("Delete Component")

		//If not inherited...
		local btn_rename = catpanel.Header:Add("DImageButton")
		btn_rename:SetImage("icon16/textfield_rename.png")
		btn_rename:SizeToContents()
		btn_rename:SetPos(550,4)
		btn_rename:SetToolTip("Rename Component")

		local function reflowCat()
			local catpanel = control:GetCategory(catname)
			for k,rowpanel in pairs(catpanel.Rows) do
				if cdef.schema[k].visible then
					print(k)
					local show = cdef.schema[k].visible(tab)
					if show!=rowpanel:IsVisible() then
						rowpanel:SetVisible(show)
						catpanel.Container:InvalidateLayout(true)
						catpanel:InvalidateLayout()
						if show then
							tab[k]=rowpanel:GetValue()
						else
							tab[k]=nil
						end
					end
				end
			end
		end

		for k,schema in pairs(cdef.schema) do
			if !isnumber(k) then
				local row = control:CreateRow(catname,k)
				row:Setup("Momo",schema)
				row.GetValue=function(self)
					if IsValid(self.Inner) then
						return self.Inner:GetValue() //TODO
					end
				end

				if tab[k] then
					row:SetValue(tab[k]) //OR DEFAULT VALUE
				end
				row:SetToolTip(schema.info)
				row.DataChanged = function(_,val)
					print("=>MODIFIED")
					row.last_value = tab[k]
					tab[k]=val
					reflowCat()
					PrintTable(test_form)
				end
			end
		end

		reflowCat()
	end
end)