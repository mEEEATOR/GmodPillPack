/*
 *	DO NOT USE THIS YET. IT IS NOT READY TO BE USED FOR ANYTHING.
 */

AddCSLuaFile()
module("momo",package.seeall)
_VERSION=0

include("momo/compat.lua")
include("momo/tf2lib.lua")
include("momo/console.lua")
include("momo/editor.lua")

_components={}
function registerComponent(compProto)
	if !compProto.name or type(compProto.name)!="string" then error("Attempted to register MoMo component with missing/invalid name!") end
	if !compProto.info or type(compProto.info)!="string" then error("Attempted to register MoMo component with missing/invalid info!") end
	if !compProto.schema or type(compProto.schema)!="table" then error("Attempted to register MoMo component with missing/invalid schema!") end
	_components[compProto.name]=compProto
end

/*Prevalidation:
	confirm id is set
	confirm parent is set to a valid type
	set abstract if not set
*/

local function validateForm(formTable)
	local id
	local extable = {}
	for k,v in pairs(formTable) do
		if type(v)=="table" then
			local compTable = v
			local compName = compTable[1]
			if !compName or type(compName)!="string" then return "Component #"..k.." has a missing/invalid type!" end
			if !_components[compName] then return 'Attempted to use nonexistent component type "'..compName..'"!' end
			
			local defTable = _components[compName]

			if defTable.exgroup then
				if extable[defTable.exgroup] then
					return 'Components "'..compName..'" and "'..extable[defTable.exgroup]..'" cannot be used together!'
				else
					extable[defTable.exgroup]=compName
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
		elseif type(v)=="string" then
			if id then
				return "Multiple IDs have been set."
			end
			id = v
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

function processCommand(cmd,ply)
	/*
		CREATE
			NAMESPACE name [data]
				-Namespace already exists!
				-Can't create read-only namespace!
				>If data, create forms in non-inheritance breaking order.
			FORM namespace name parent [data]
				-Namespace does not exist!
				-Can't create form in read-only namespace!
				-Form already exists!
				-Parent does not exist!
				>If data, create components.
			COMPONENT namespace form name type [data]
				>Namespace does not exist!
				>Can't create non-configurable component in read-only namespace!
				>Form does not exist!
				>Component already exists!
				>Validation failure! (LIST ERRORS)
		DELETE
			NAMESPACE name
				>Namespace does not exist!
				>Can't delete read-only namespace!
			FORM namespace name
				>Namespace does not exist!
				>Can't delete form in read-only namespace!
				>Form does not exist!
			COMPONENT namespace form name
				>Namespace does not exist!
				>Can't delete non-configurable component in read-only namespace!
				>Form does not exist!
				>Component does not exist!
			PROPERTY namespace form component name
				>Namespace does not exist!
				>Can't delete property in non-configurable component in read-only namespace!
				>Form does not exist!
				>Component does not exist!
				>Property does not exist!
				>Property is not optional and is not shadowing a parent property.
		RENAME
			NAMESPACE
				>Source namespace does not exist!
				>Destination namespace already exists!
				>Can't rename read-only namespace!
			FORM
				>Source component does not exist!
				>Destination component already exists!
				>Can't rename component in read-only namespace!
			COMPONENT
		SET namespace form component property value

		always return an accept/deny 
	*/
end

_forms={}
//Returns a TABLE of errors!
/*
function registerFragment(fragment,ply) // ply=actor
	// namespace.form.component.property
	local errors={}
	local function add_error(lvl,name,desc)
		table.Insert(errors,{lvl=lvl,name=name,desc=desc})
	end

	local function base_check(lvl,name,v)
		if CLIENT then return end
		local failed

		if tonumber(name) then
			add_error(lvl,name,"has a purely numeric name. This is not allowed!")
			failed=true
		end

		if string.find(name,"_\\.") then
			add_error(lvl,name,"has a name with illegal characters. Underscores and periods are not allowed!")
			failed=true
		end

		if !istable(v) then
			add_error(lvl,name,"is not a table!")
			failed=true
		end

		return failed
	end

	if SERVER then
		if false then /*can edit forms* /
			return {lvl="generic",desc="Whatever the damn thing returned!"}
		end

		if !istable(fragment) then
			return {lvl="generic",desc="The fragment is not even a table. What the hell?"}
		end
	end

	for ns_name,ns in pairs(fragment) do
		if base_check("namespace",ns_name,ns) then
			fragment[ns_name]=nil
			continue
		end

		local readonly = SERVER and string.byte(ns_name)==95

		if ns._config then
			if readonly then
				ns._config=nil
				add_error("namespace",ns_name,"is readonly. Its configuration cannot be changed!")
			elseif CLIENT then
				if ns._config.icon or ns._config.printName then
					//Signal menu
				end
			end
		end

		for form_name,form in pairs(ns) do
			if form_name=="_config" then
				continue
			elseif base_check("form",form_name,ns) then
				fragment[ns_name]=nil
				continue
			end

			local parent = form._parent
			if parent then
				//seek parent in _forms. If it doesn't exist, 
			end
		end





	end
end
*/
//

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