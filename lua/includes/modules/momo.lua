AddCSLuaFile()
module("momo",package.seeall)
_VERSION=0

//Convars
CreateConVar("momo_version",_VERSION,{FCVAR_NOTIFY,FCVAR_NOT_CONNECTED},"MoMo version number.")

include("momo/compat.lua")

local components={}
function registerComponent(compTable)
	if !compTable.name or type(compTable.name)!="string" then error("Attempted to register MoMo component with missing/invalid name!") end
	if !compTable.info or type(compTable.info)!="string" then error("Attempted to register MoMo component with missing/invalid info!") end
	if !compTable.schema or type(compTable.schema)!="table" then error("Attempted to register MoMo component with missing/invalid schema!") end
	components[compTable.name]=compTable
end

/*Prevalidation:
	confirm id is set
	confirm parent is set to a valid type
	set abstract if not set
*/

local function validateForm(formTable)
	local extable = {}
	for k,v in pairs(formTable) do
		if type(k)=="number" then
			local compTable = v
			local compName = compTable[1]
			if !compName or type(compName)!="string" then return "Component #"..k.." has a missing/invalid type!" end
			if !components[compName] then return 'Attempted to use nonexistent component type "'..compName..'"!' end
			
			local defTable = components[compName]

			if defTable.exflag then
				if extable[defTable.exflag] then
					return 'Components "'..compName..'" and "'..extable[defTable.exflag]..'" cannot be used together!'
				else
					extable[defTable.exflag]=compName
				end
			end

			for k,propDef in pairs(defTable.schema) do
				local compError
				local optional = propDef.optional or (propDef.visible and not propDef.visible(compTable))

				local propValue = compTable[k]
				if propValue then
					if propDef.type and propDef.type!=type(propValue) then
						compError="must be a "..propDef.type
					elseif propDef.options and !table.HasValue(propDef.options,propValue) then
						compError="is not set to a valid option"
					elseif propDef.min and propValue<propDef.min then
						compError="is less than the minimum of "..propDef.min
					elseif propDef.max and propValue>propDef.max then
						compError="is greater than the maximum of "..propDef.max
					elseif propDef.mincomp and (propValue.x<propDef.mincomp or propValue.y<propDef.mincomp or propValue.z<propDef.mincomp) then
						compError="has a component value less than the minimum of "..propDef.mincomp
					elseif propDef.maxcomp and (propValue.x>propDef.maxcomp or propValue.y>propDef.maxcomp or propValue.z>propDef.maxcomp) then
						compError="has a component value greater than the maximum of "..propDef.maxcomp
					end
				elseif !optional then
					compError="must be set"
				end

				if compError then
					return 'Problem with component "'..compName..'": Property "'..k..'" '..compError..'!'
				end
			end

			//check agaist schema!
		end
	end
end



/*
local function validate_numeric(schema_table,obj)
	if obj._min then
		if f<obj._min then return false end
	end

	if obj._max then
		if f<obj._max then return false end
	end
end

local schema_types = {}

schema_types["int"]={
	validate=function(schema_table,obj)
		local i,f = math.modf(obj)
		if f!=0 then return false end
		
		return validate_numeric(schema_table,obj)
	end
}
*/

function registerForm(formTable)
	if CLIENT then return end
	//Force abstract to false if not true
	//Set metatable from parent
	//Do schema validation
	//Do custom validation?
	//Call register hooks
	//Register!
	local validate_error = validateForm(formTable)
	if validate_error then
		--print("Validation failed! "..validate_error)
	else
		--print("Validation successful!")
	end
end