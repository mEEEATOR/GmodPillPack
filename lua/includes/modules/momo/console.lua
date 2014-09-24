AddCSLuaFile()

//Convars
momo.convars = {}

momo.convars.version = CreateConVar("momo_version",momo._VERSION,FCVAR_NOT_CONNECTED,"Morph Mod version number. READ ONLY!")

//Admin vars
momo.convars.admin_restrict = CreateConVar("momo_admin_restrict",game.IsDedicated() and 1 or 0,FCVAR_REPLICATED+FCVAR_NOTIFY,"Restrict morphing to admins.")

momo.convars.admin_neverfreeze = CreateConVar("momo_admin_neverfreeze",0,FCVAR_REPLICATED,"Never freeze movement when morphed.")
momo.convars.admin_anyweapons = CreateConVar("momo_admin_anyweapons",0,FCVAR_REPLICATED,"Allow use of any weapon when morphed.")


//Client vars
if CLIENT then
	momo.convars.cl_thirdperson = CreateClientConVar("momo_cl_thirdperson",1)
	momo.convars.cl_hidehud = CreateClientConVar("momo_cl_hidehud",0)
end

//Admin var setter command.
if SERVER then
	local function admin_set(ply,cmd,args)
		if !ply:IsSuperAdmin() then
			ply:PrintMessage(HUD_PRINTCONSOLE,"You must be a super admin to use this command.")
			return
		end

		local var = args[1]
		local value = args[2]

		if !var then
			ply:PrintMessage(HUD_PRINTCONSOLE,"Please supply a valid convar name. Do not include 'momo_admin_'.")
			return
		elseif !ConVarExists("momo_admin_"..var) then
			ply:PrintMessage(HUD_PRINTCONSOLE,"Convar 'momo_admin_"..var.."' does not exist. Please supply a valid convar name. Do not include 'momo_admin_'.")
			return
		end

		if !value then
			ply:PrintMessage(HUD_PRINTCONSOLE,"Please supply a value to set the convar to.")
			return
		end

		RunConsoleCommand("momo_admin_"..var,value)
		print(">>momo admin setter ran")
	end

	concommand.Add("momo_admin_set",admin_set,nil,"Helper command for setting Morph Mod admin convars. Available to super admins.")
end

//Deprecated commands and convars.
concommand.Add("pk_pill_adminonly",function(ply,cmd,args)
	RunConsoleCommand("momo_admin_restrict",args[1])
	print("THE CONVAR 'pk_pill_adminonly' IS DEPRECATED! USE 'momo_admin_restrict'!")
end,nil,"DEPRECATED! USE 'momo_admin_restrict'!",FCVAR_SERVER_CAN_EXECUTE)