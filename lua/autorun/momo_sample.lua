AddCSLuaFile()
require("momo")

momo.registerComponent{
	name="spawnable",
	info="Makes the form accessable through the spawnmenu.",
	exflag="spawnable",
	schema={
		name={
			type="string",
			info="Name shown in spawnmenu."
		},
		category={
			type="string",
			info="The spawnmenu category to find this form in."
		},
		random_skin={
			type="boolean",
			info="If true, sub-types of this form will be selected at random.",
			optional=true
		}
	}
}

momo.registerComponent{
	name="subtype",
	info="Makes this form act as a subtype of another form.",
	exflag="spawnable",
	schema={
		of={
			type="string",
			info="The form we are a skin of."
		}
	}
}

momo.registerComponent{
	name="core-physical",
	info="This is the physical morph core component.",
	exflag="core",
	schema={
		collision_shape={
			type="string",
			info="The shape this form will use for collisions.",
			options={"model","sphere","box","custom_mesh"}
		},
		collision_radius={
			type="number",
			info="Radius of the collision sphere.",
			visible=function(compTable)
				if compTable.collision_shape=="sphere" then return true end
			end,
			min=1,
			max=1000
		},
		collision_dimensions={
			type="Vector",
			info="Dimensions of the collision box.",
			visible=function(compTable)
				if compTable.collision_shape=="box" then return true end
			end,
			mincomp=2,
			maxcomp=2000
		},
		collision_offset={
			type="Vector",
			info="Offset of the collision box.",
			optional=true,
			visible=function(compTable)
				if compTable.collision_shape=="box" then return true end
			end,
			mincomp=-1000,
			maxcomp=1000
		},
		material={
			type="string",
			info="The physical material of the form.",
			optional=true
		},
		mass={
			type="number",
			info="The mass of the form.",
			optional=true,
			min=1,
			max=10000
		}
	}
}

momo.registerForm{
	id="sample",
	{
		"spawnable", 
		name="I am a sample!",
		category="momo"
	},
	{
		"core-physical",
		collision_shape = "model",
		material = "flesh",
		mass = 20
	}
}