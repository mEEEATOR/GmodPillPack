AddCSLuaFile()

module("momo",package.seeall)
_VERSION="Alpha-0"

//Convars
CreateConVar("momo_version",_VERSION,{FCVAR_NOTIFY,FCVAR_NOT_CONNECTED},"[Modular Morph Mod] Version name and number.")

function registerForm(formTable)
	//Force abstract to false if not true
	//Set metatable from parent
	//Do schema validation
	//Do custom validation?
	//Call register hooks
	//Register!
end