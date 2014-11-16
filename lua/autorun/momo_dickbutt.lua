require("momo")
AddCSLuaFile()

momo.registerComponent{
	name="spawnable",
	info="Makes the form accessable through the spawnmenu.",
	exgroup="spawnable",
	schema={
		supertype={
			type="string",
			info="The form we are a sub-type of."
		},
		name={
			type="string",
			info="Name shown in spawnmenu."
		},
		random_subtype={
			type="boolean",
			info="If true, sub-types of this form will be selected at random."
		}
	}
}
/*
momo.registerComponent{
	name="subtype",
	info="Makes this form act as a subtype of another form.",
	exgroup="spawnable",
	schema={
		of={
			type="string",
			info="The form we are a skin of. Defaults to the parent.",
			optional=true
		}
	}
}
*/
momo.registerComponent{
	name="core-physical",
	info="This is the physical morph core component.",
	exgroup="core",
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
	"sample",
	spawnable={
		"spawnable", 
		name="I am a sample!",
		category="momo"
	},
	core={
		"core-physical",
		collision_shape = "model",
		material = "flesh",
		mass = 20
	}
}

/*
local jsonrep = util.TableToJSON{
	"sample",
	spawnable={ //names are needed so we can merge stuff
		"spawnable", 
		name="I am a sample!",
		category="momo"
	},
	core={
		"core-physical",
		collision_shape = "model",
		material = "flesh",
		mass = 20
	},
	teemo="deleted"
}

print(jsonrep)

PrintTable(util.JSONToTable(jsonrep))*/