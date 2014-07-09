AddCSLuaFile()
require("momo")

local pill = {
	id="sample",
	parent="", //The parent. Parsed before validation.
	abstract=true, //Can not create instance of form, spawnable component will be ignored.
	{
		"spawnable", 
		name="I am a sample!",
		category="momo",
		skin_of=nil, //Makes the form act as a skin of another pill.
		random_skin= nil, //If true, spawn with a random skin.
	},
	{
		"core-physical", //Validation fails if no collision setting is found or if multiple are found
		collision_box = nil, //Makes the form use an AABB for collisions.
		collision_box_offset = nil, //Optional offset for collision box. Validation fails if not using collision box.
		collision_radius = nil, //Radius of collision sphere.
		collision_use_model = nil, //Use model for collisions. If no model component found, fail validation.
		collision_custom_mesh = nil, //Use a custom mesh for collisions. Not sure how.
		material = "flesh", //Optionally override physical material.
		mass = 20 //Optionally override mass.
	},
	{
		"view", //If no view component, use default origin/dist.
		origin = nil,
		distance = nil
	}
}