AddCSLuaFile()

local function printFunc(msg)
	MsgC(Color(200,200,200),"[")
	MsgC(Color(100,255,50),"MoMo")
	MsgC(Color(200,200,200),"]")
	Msg(" ",msg,"\n")
end

local function handleFiles(base)
	local files, _ = file.Find(base.."*","LUA")

	for _,file in pairs(files) do
		if string.StartWith(file,"sv_") then
			if SERVER then
				include(base..file)
			end
		elseif string.StartWith(file,"cl_") then
			if SERVER then
				AddCSLuaFile(base..file)
			else
				include(base..file)
			end
		else
			if SERVER then
				AddCSLuaFile(base..file)
			end
			include(base..file)
		end
	end
end

local _, dirs = file.Find("autorun/*","LUA")
local load_id

for _,dir in pairs(dirs) do
	if string.StartWith(dir,"momo-core-") then
		local lib_id = string.sub(dir,11)
		if tonumber(lib_id) then
			lib_id = tonumber(lib_id)
			if !load_id or lib_id>load_id then
				load_id=lib_id
			end
		elseif lib_id == "dev" then
			load_id="dev"
			break
		end
	end
end

if load_id then
	printFunc("Loading core library... ("..load_id..")")
	momo2={print=printFunc,_VERSION=load_id}
	handleFiles("autorun/momo-core-"..load_id.."/")
else
	printFunc("Failed to load core library!")
end