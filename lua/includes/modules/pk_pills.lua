AddCSLuaFile()

//Module starts here...
module("pk_pills",package.seeall)
version="1.1.1"

//
//Load files
//

file.CreateDir("pill_config")

local restrictions= ("\n"):Explode(file.Read("pill_config/restrictions.txt") or "")

local locked_perma={}
local locked_game={}

for k,v in pairs(util.KeyValuesToTable(file.Read("pill_config/permalocked.txt") or "")) do
	locked_perma[string.upper(k)] = v
end

//
//Pack Registration
//

local packString = ""
local packs={}
local currentPack

function packStart(name,id,icon)
	currentPack={}
	currentPack.name=name
	currentPack.icon=icon||"icon16/pill.png"
	currentPack.headers={}
	currentPack.items={}
	table.insert(packs,currentPack)

	packString=packString..id.." "
	if SERVER then RunConsoleCommand("pk_pill_packs",packString) end
end

function packRequireGame(name,id)
	if CLIENT then //Assume server owners are not stupid.
		for _,v in pairs(engine.GetGames()) do
			if (v.depot==id) then
				if !v.mounted then
					if v.installed then
						table.insert(currentPack.headers,{type="pill-info",heading="Warning!",color="#C9B995",text=[[
							This pack requires content from the game ]]..name..[[, which appears to be installed but not mounted.
							You can mount the game using the gamepad icon in the bottom right corner of the main menu.
							You may need to restart the map or rejoin the server for this to work.
						]]})
					elseif v.owned then
						table.insert(currentPack.headers,{type="pill-info",heading="Warning!",color="#C9B395",text=[[
							This pack requires content from the game ]]..name..[[, which you appear to own but is not installed.
							If you have issues with missing models or textures, install the game through Steam, then mount it through Gmod's main menu.
						]]})
					else
						table.insert(currentPack.headers,{type="pill-info",heading="Warning!",color="#C99595",text=[[
							This pack requires content from the game ]]..name..[[, which you do not appear to own.
							You can buy it on Steam. If you <i>obtained</i> the content through other means, you can close this message.
						]]})
					end
				end
			end
		end
	end
end

if SERVER then var_downloads= CreateConVar("pk_pill_downloader","",{FCVAR_ARCHIVE}) end
function packFinalize()
	if CLIENT then return end

	if var_downloads:GetString()=="fastdl" or var_downloads:GetString()=="fastdl-icons" then
		for _,p in pairs(currentPack.items) do
			resource.AddFile("materials/pills/"..p.name..".png")
		end
	end
end

function addFiles(files)
	if CLIENT then return end

	if var_downloads:GetString()=="fastdl" or var_downloads:GetString()=="fastdl-noicons" then
		for _,f in pairs(files) do
			resource.AddFile(f)
		end
	end
end

function addIcons(icons)
	if CLIENT then return end

	if var_downloads:GetString()=="fastdl" or var_downloads:GetString()=="fastdl-icons" then
		for _,i in pairs(icons) do
			resource.AddFile("materials/entities/"..i..".png")
		end
	end
end

function addWorkshop(id)
	if CLIENT then return end

	if var_downloads:GetString()=="workshop" then
		resource.AddWorkshop(id)
	end
end

function hasPack(name)
	return table.HasValue(string.Explode(" ",packString), name)
end

//
//PILL TABLE REGISTRATION
//

local forms={}
local me_map={}

function register(name,t)
	if t.printName then
		table.insert(currentPack.items,{type="pill",name=name,printName=t.printName})
	end

	if t.me then
		me_map[t.me]=name
	end

	if (t.sounds) then
		for _,s in pairs(t.sounds) do
			if (isstring(s)) then
				util.PrecacheSound(s)
			elseif (istable(s)) then
				for k,s2 in pairs(s) do
					if s2==false then
						s[k]=nil
					else
						util.PrecacheSound(s2)
					end
				end
			end
		end
	end

	forms[name]=t
end

local function fixParent(name)
	local t = forms[name]
	local t_parent = forms[t.parent]
	if t_parent.parent then
		fixParent(t.parent)
	end
	t_parent = forms[t.parent]
	if t_parent then
		t_parent = table.Copy(t_parent)
		forms[name]=table.Merge(t_parent,t)
		t.parent=nil
	else
		print("Tried to inherit pill from non-existant '"..t.parent.."'. Make sure you register the parent first.")
	end
end

function getPillTable(typ)
	return forms[typ]
end

hook.Add("Initialize","pk_pill_finalize",function()
	for n,t in pairs(forms) do
		if t.parent then
			fixParent(n)
		end
	end
end)

//
//Player to Pill Entity Mapping
//

//local playerMap={}

function mapEnt(ply,ent)
	//playerMap[ply]=ent
	ply.pk_pill_ent=ent
	//print("m",ply.pk_pill_ent)
end

function unmapEnt(ply,ent)
	/*if playerMap[ply]==ent then
		playerMap[ply]=nil
	elseif IsValid(playerMap[ply]) then
		return playerMap[ply].formTable.type
	end*/
	//print("u",ply.pk_pill_ent)

	if ply.pk_pill_ent==ent then
		ply.pk_pill_ent=nil
	elseif IsValid(ply.pk_pill_ent) then
		return ply.pk_pill_ent.formTable.type
	end
end

function getMappedEnt(ply)
	//print("g",ply.pk_pill_ent)
	//return playerMap[ply]
	return ply.pk_pill_ent
end

//
//Darkrp stuff
//

local function init_darkrp()
	if !DarkRP.createJob then error("No DarkRP job creation function!") end
	local TEAM_PILL = DarkRP.createJob("Pill Merchant", {
		color = Color(80, 40, 120, 255),
		model = "models/player/soldier_stripped.mdl",
		description = [[This guy sells pills.]],
		weapons = {},
		command = "pillmerchant",
		max = 2,
		salary = GAMEMODE.Config.normalsalary,
		admin = 0,
		vote = false
	})

	for name,tbl in pairs(forms) do
		if !tbl.printName or darkrp_costs[name]==-1 then continue end

		local mdl=tbl.model
		if !mdl then
			local opts = tbl.options&&tbl.options()
			if opts then
				mdl=opts[1].model
			end
		end
		if !mdl then mdl = "models/props_junk/watermelon01.mdl" end

		DarkRP.createEntity(tbl.printName.." Pill", {
			ent = "pill_worldent",
			model = mdl,
			price = darkrp_costs[name] or 1000,
			max = 10,
			cmd = "buypill_"..name,
			pill = name,
			allowed = {TEAM_PILL}
		})
	end
end

if SERVER then
	hook.Add("Initialize","pk_pill_init_darkrp",function()
		if DarkRP then
			if !file.Exists("pill_config/darkrp_costs.txt","DATA") then
				darkrp_costs={}
				for n,t in pairs(forms) do
					if t.userSpawn or !t.printName then continue end
					darkrp_costs[n]=t.default_rp_cost||-1
				end
				file.Write("pill_config/darkrp_costs.txt",util.TableToKeyValues(darkrp_costs))
			else
				local readfile = file.Read("pill_config/darkrp_costs.txt")
				if readfile=="DISABLE" then return end

				darkrp_costs = util.KeyValuesToTable(file.Read("pill_config/darkrp_costs.txt"))
			end

			init_darkrp(darkrp_costs)
		end
	end)
else
	net.Receive("pk_pill_init_darkrp", function( len, pl )
		darkrp_costs = net.ReadTable()
		init_darkrp(darkrp_costs)
	end)
end

//
//Concommands, Convars, etc.
//

if SERVER then
	CreateConVar("pk_pill_packs","",{FCVAR_NOTIFY,FCVAR_NOT_CONNECTED},"This is a list of the registered pill packs. Don't change it.")
	CreateConVar("pk_pill_version",version,{FCVAR_NOTIFY,FCVAR_NOT_CONNECTED},"This is the version of the pill pack. Don't change it.")
	var_adminonly= CreateConVar("pk_pill_adminonly",game.IsDedicated() and 1 or 0,{FCVAR_NOTIFY,FCVAR_ARCHIVE})

	concommand.Add("pk_pill_apply", function(ply,cmd,args,str)
		apply(ply,args[1],"user",tonumber(args[2]))
	end)
	
	concommand.Add("pk_pill_restore", function(ply,cmd,args,str)
		restore(ply)
	end)
	
	concommand.Add("pk_pill_restore_force", function(ply,cmd,args,str)
		if not ply:IsAdmin() then return end
		restore(ply,true)
	end)

	concommand.Add("pk_pill_spawnent", function(ply,cmd,args,str)
		if not ply:IsAdmin() then return end
		local tr = ply:GetEyeTrace()
		local e = ents.Create("pill_worldent")
		e:SetPos(tr.HitPos+tr.HitNormal*5)
		e:SetPillForm(args[1])
		e:Spawn()
	end)
	
	concommand.Add("pk_pill_restrict", function(ply,cmd,args,str)
		if not ply:IsSuperAdmin() then return end
		local pill = args[1]
		local a = args[2]
		
		if a=="on" then
			if !table.HasValue(restrictions,pill) then table.insert(restrictions,pill) end
		elseif a=="off" then
			table.RemoveByValue(restrictions,pill)
		end
		
		file.Write("pill_config/restrictions.txt",("\n"):Implode(restrictions))
		
		net.Start("pk_pill_restrict")
		net.WriteTable(restrictions)
		net.Broadcast()
	end)
	
	concommand.Add("pk_pill_morphgun_select", function(ply,cmd,args,str)
		if not ply:IsAdmin() then return end
		local pill = args[1]
		
		local wep = ply:GetWeapon("pill_wep_morphgun")
		if not IsValid(wep) then
			wep = ply:Give("pill_wep_morphgun")
		end
		
		if not IsValid(wep) then return end
		
		ply:SelectWeapon("pill_wep_morphgun")
		
		wep:SetForm(pill)
	end)
else
	var_thirdperson= CreateConVar("pk_pill_thirdperson",1,FCVAR_ARCHIVE) //THIS IS WHERE IT SHOULD BE
end


//
//Spawnmenu
//

if CLIENT then
	local icon_restricted = Material( "icon16/lock.png")

	spawnmenu.AddContentType("pill", function(container,obj)
		if (!obj.name) then return end
		if (!obj.printName) then return end

		local icon = vgui.Create("ContentIcon", container)
		icon:SetContentType("pill")
		//icon:SetSpawnName(forms[obj.name].printName||obj.name)
		icon:SetName(obj.printName)
		icon:SetMaterial("pills/"..obj.name..".png")
		//icon:SetAdminOnly(obj.admin)
		//icon:SetColor(Color(205, 92, 92, 255))
		//icon:SetColor(Color(255, 0, 0, 255))
		icon.DoClick = function()
			RunConsoleCommand("pk_pill_apply", obj.name)
			--surface.PlaySound( "ui/buttonclickrelease.wav" )
		end
		icon.OpenMenu = function(icon)
			local menu = DermaMenu()
			local formTable = getPillTable(obj.name)
			
			menu:AddOption("Copy Type to Clipboard", function() SetClipboardText(obj.name) end):SetImage("icon16/page_copy.png")
			if (formTable.options) then
				menu:AddOption("Use with Skin...", function()
					local pickerWindow = vgui.Create( "DFrame" )
					pickerWindow:SetSize(606, 400)
					pickerWindow:Center()
					pickerWindow:SetTitle("Pill Skin Picker")
					pickerWindow:SetVisible( true )
					pickerWindow:SetDraggable( true )
					pickerWindow:ShowCloseButton( true )
					pickerWindow:MakePopup()

					local picker = vgui.Create( "DPanelSelect" , pickerWindow )
					picker:SetPos(0,24)
					picker:SetSize(606,376)

					for n,opt in pairs(formTable.options()) do
						local mdl = opt.icon or opt.model or formTable.model
						local skin = opt.skin or formTable.skin or 0

						local icon = vgui.Create( "SpawnIcon")
						icon:SetModel(mdl,skin)
						icon:SetSize(64,64)
						icon:SetTooltip(mdl)

						function icon:OnMousePressed(code)
							if code==MOUSE_LEFT then
								RunConsoleCommand("pk_pill_apply", obj.name, n)
								pickerWindow:Close()
							end
						end

						picker:AddPanel(icon)
					end
				end):SetImage("icon16/palette.png")
			end
			
			if LocalPlayer():IsAdmin() then
				menu:AddSpacer()
				if !formTable.userSpawn then
					menu:AddOption("Spawn to World",function() RunConsoleCommand("pk_pill_spawnent",obj.name) end):SetImage("icon16/pill_go.png")
					menu:AddOption("Use with Morphgun",function() RunConsoleCommand("pk_pill_morphgun_select",obj.name) end):SetImage("icon16/lightning_go.png")
				end
				
				if LocalPlayer():IsSuperAdmin() then
					if table.HasValue(restrictions,obj.name) then
						menu:AddOption("Remove Restriction",function() RunConsoleCommand("pk_pill_restrict",obj.name,"off") end):SetImage("icon16/lock_delete.png")
					else
						menu:AddOption("Restrict to Admins",function() RunConsoleCommand("pk_pill_restrict",obj.name,"on") end):SetImage("icon16/lock_add.png")
					end
				end
			end
			
			--menu:AddOption( "Spawn Using Toolgun", function() RunConsoleCommand( "gmod_tool", "creator" ) RunConsoleCommand( "creator_type", "0" ) RunConsoleCommand( "creator_name", obj.spawnname ) end )
			
			--menu:AddOption( "Delete", function() icon:Remove() hook.Run( "SpawnlistContentChanged", icon ) end )
			menu:Open()
		end
		icon.PaintOver = function(self,w,h)
			if table.HasValue(restrictions,obj.name) then
				surface.SetMaterial(icon_restricted)
				surface.DrawTexturedRect(self.Border + 8, self.Border + 8, 16, 16)
			end
		end

		if (IsValid( container)) then
			container:Add(icon)
		end

		return icon
	end)


	spawnmenu.AddContentType("pill-info", function(container,obj)
		if (!obj.text) then return end

		local html = vgui.Create("DHTML",container)
		html:SetSize(256,256)
		html:SetAllowLua(true)
		html:SetHTML("<style>body {background-color: "..(obj.color||"gray").."; font-family: ariel; border: 6px double black; margin: 0; padding: 6px;} b {font-size: 20px; margin: 0;}</style><b>"..(obj.heading||"").."</b> "..obj.text.."<hr><button onclick=\"console.log('RUNLUA:SELF:Remove()')\">Close</button>")
		if (IsValid( container)) then
			container:Add(html)
		end

		return html
	end)
	

	spawnmenu.AddCreationTab("Pills", function()
		local ctrl = vgui.Create("SpawnmenuContentPanel")
		
		local function makeHTMLnode(node,url)
			local html
			
			node.DoPopulate = function(self)
				-- If we've already populated it - forget it.
				if (self.SpawnPanel) then return end

				-- Create the container panel
				self.SpawnPanel = vgui.Create("DHTML", ctrl)
				self.SpawnPanel:SetVisible(false)
				self.SpawnPanel:OpenURL(url)
				self.SpawnPanel:SetAllowLua( true )
			end

			node.DoClick = function(self)
				self:DoPopulate()
				ctrl:SwitchPanel(self.SpawnPanel)
				self.SpawnPanel:Dock(NODOCK)
			end
		end

		local tree = ctrl.ContentNavBar.Tree

		local node_home = tree:AddNode("Home","icon16/application.png")
		
		makeHTMLnode(node_home,"https://dl.dropboxusercontent.com/u/118688241/ppp/home.html")
		
		local node_help = node_home:AddNode("Help","icon16/help.png")
		
		makeHTMLnode(node_help,"https://dl.dropboxusercontent.com/u/118688241/ppp/help.html")
		node_help:DoPopulate()
		help_panel = node_help.SpawnPanel
		
		local node_settings = node_home:AddNode("Settings","icon16/cog.png")

		node_settings.DoPopulate = function(self)
			-- If we've already populated it - forget it.
			if (self.SpawnPanel) then return end

			-- Create the container panel
			self.SpawnPanel = vgui.Create("DPanel", ctrl)
			self.SpawnPanel:SetVisible(false)

			local checkbox = vgui.Create("DCheckBoxLabel",self.SpawnPanel)
			checkbox:SetPos(20, 20)
			checkbox:SetText("Thirdperson")
			checkbox:SetTextColor(Color(0,0,0))
			checkbox:SetConVar("pk_pill_thirdperson")
			checkbox:SizeToContents()
		end

		node_settings.DoClick = function(self)
			self:DoPopulate()
			ctrl:SwitchPanel(self.SpawnPanel)
		end
		
		local node_bug = node_home:AddNode("Report a Bug","icon16/exclamation.png")
		
		makeHTMLnode(node_bug,"https://dl.dropboxusercontent.com/u/118688241/ppp/bugreport.html")
		node_bug:DoPopulate()
		node_bug.SpawnPanel:QueueJavascript("setAddons("..util.TableToJSON(engine.GetAddons())..")")

		local node_morphs = tree:AddNode("Categories","icon16/folder.png")

		for _,pack in pairs(packs) do
			local node = node_morphs:AddNode(pack.name, pack.icon)

			node.DoPopulate = function(self)
				-- If we've already populated it - forget it.
				if (self.SpawnPanel) then return end

				-- Create the container panel
				self.SpawnPanel = vgui.Create("ContentContainer", ctrl)
				self.SpawnPanel:SetVisible(false)
				self.SpawnPanel:SetTriggerSpawnlistChange(false)

				//warnings
				for _,item in pairs(pack.headers) do
					spawnmenu.CreateContentIcon(item.type, self.SpawnPanel, item)
				end
				//icons
				for _,item in SortedPairsByMemberValue(pack.items,"printName") do
					spawnmenu.CreateContentIcon(item.type, self.SpawnPanel, item)
				end
			end

			-- If we click on the node populate it and switch to it.
			node.DoClick = function(self)
				self:DoPopulate()
				ctrl:SwitchPanel(self.SpawnPanel)
			end
		end

		node_home:InternalDoClick()
		node_home:SetExpanded(true)
		node_morphs:SetExpanded(true)

		return ctrl
	end,"icon16/pill.png",60)
end

//
//NW Strings
//

if SERVER then
	util.AddNetworkString("pk_pill_filtercam")
	util.AddNetworkString("pk_pill_restrict")
	util.AddNetworkString("pk_pill_morphsound")
	util.AddNetworkString("pk_pill_init_darkrp")
else
	net.Receive( "pk_pill_filtercam", function( len, pl )
		local pill = net.ReadEntity()
		local filtered = net.ReadEntity()

		if IsValid(pill) and IsValid(filtered) then
			table.insert(pill.camTraceFilter,filtered)
		end
	end)
	
	net.Receive( "pk_pill_restrict", function( len, pl )
		restrictions = net.ReadTable()
	end)
	
	local snd_pillSet=Sound("Friends/friend_online.wav")
	local snd_pillFail=Sound("buttons/button2.wav")
	
	net.Receive("pk_pill_morphsound", function( len, pl )
		local success = net.ReadBit()
		if success==1 then
			//LocalPlayer():GetViewEntity():EmitSound(snd_pillSet)
			surface.PlaySound(snd_pillSet)
		else
			//LocalPlayer():GetViewEntity():EmitSound(snd_pillFail)
			surface.PlaySound(snd_pillFail)
		end
	end)
end

//
//Apply/Restore
//

if SERVER then
	--[[
		Modes:
		DEFAULT - Force, but don't change locking settings
		user - Obey restrictions
		force - force, change locking settings
		lock-life - force until death
		lock-map - force until map restart
		lock-perma - force forever
	]]
	
	function apply(ply,name,mode,option)
		if CLIENT then return end
		--restrict
		--[[if !ply:IsAdmin() then
			ply:ChatPrint("Pills are temporarily restricted.")
			return
		end]]--
		t =forms[name]

		if !t and name!="me" then
			print("Player '"..ply:Name().."' attempted to use nonexistent pill '"..name.."'.")
			ply:PrintMessage(HUD_PRINTCONSOLE,"Attempted to use nonexistent pill '"..name.."'.")
			return
		end

		local old = getMappedEnt(ply)
		
		if !ply:Alive() and !IsValid(old) then
			ply:ChatPrint("You are DEAD! Dead people can't use pills!")
			return
		end
		
		local locked
		local overridePos
		local overrideAng
		
		if name=="me" then
			 local pillname = me_map[ply:SteamID()]
			 if !pillname then
			 	ply:ChatPrint("Nope.")
			 	return
			 end
			 name=pillname
			 t =forms[name]
		elseif mode=="user" then --restriction logic
			local success=true
			
			if !t.printName then
				ply:ChatPrint("You cannot use this pill directly.")
				success=false
			end

			if var_adminonly:GetBool() then
				if not ply:IsAdmin() then
					ply:ChatPrint("Pills are restricted to Admins.")
					success=false
				end
			end
			
			if success then
				if table.HasValue(restrictions,name) then
					if not ply:IsAdmin() then
						ply:ChatPrint("You must be an Admin to use this pill.")
						success=false
					end
				end
			end
			
			if IsValid(old) and old.locked then
				if locked_perma[ply:SteamID()] then
					ply:ChatPrint("You are locked in your current pill -- FOREVER!")
				elseif locked_game[ply:SteamID()] then
					ply:ChatPrint("You are locked in your current pill until the map changes.")
				else
					ply:ChatPrint("You are locked in your current pill until you die.")
				end
				success=false
			end

			if t.type == "phys" and t.userSpawn then
				local tr
				if IsValid(old)&&old.formTable.type=="phys" then
					tr = util.QuickTrace(old:GetPos(),ply:EyeAngles():Forward()*99999,old)
				else
					tr = ply:GetEyeTrace()
				end

				if t.userSpawn.type=="ceiling" then
					if tr.HitNormal.z<-.8 and !tr.HitSky then
						overridePos = tr.HitPos+tr.HitNormal*(t.userSpawn.offset or 0)
					else
						success=false
						ply:ChatPrint("You need to be looking at a ceiling to use this pill.")
					end
				elseif t.userSpawn.type=="wall" then
					if !tr.HitSky then
						overridePos = tr.HitPos+tr.HitNormal*(t.userSpawn.offset or 0)
						overrideAng = tr.HitNormal:Angle()
						if t.userSpawn.ang then
							overrideAng=overrideAng+t.userSpawn.ang
						end
					else
						success=false
						ply:ChatPrint("You need to be looking at a wall to use this pill.")
					end
				end
			end
			
			net.Start("pk_pill_morphsound")
			net.WriteBit(success)
			net.Send(ply)
			
			if not success then return end
		elseif mode!=nil then --anything that can change locks
			if mode=="lock-map" then
				locked_game[ply:SteamID()]=name
			else
				locked_game[ply:SteamID()]=nil
			end
			
			if mode=="lock-perma" then
				locked_perma[ply:SteamID()]=name
			else
				locked_perma[ply:SteamID()]=nil
			end
			file.Write("pill_config/permalocked.txt",util.TableToKeyValues(locked_perma,"permalocked"))
			
			if mode != "force" then locked=true end
		end
		
		local e

		if t.type == "phys" then
			e = ents.Create("pill_ent_phys")
			if overridePos then
				e:SetPos(overridePos)
			elseif old&&old.formTable&&old.formTable.type=="phys" then
				e:SetPos(old:LocalToWorld(t.spawnOffset||Vector(0,0,60)))
			else
				e:SetPos(ply:LocalToWorld(t.spawnOffset||Vector(0,0,60)))
			end

			if overrideAng then
				e:SetAngles(overrideAng)
			else
				local angs=ply:EyeAngles()
				angs.p=0
				e:SetAngles(angs)
			end
		elseif t.type == "ply" then
			e = ents.Create("pill_ent_costume")
			if old&&old.formTable.type=="phys" then
				local angs = ply:EyeAngles()
				ply:Spawn()
				ply:SetEyeAngles(angs)
				
				ply:SetPos(old:GetPos())
			end
		else
			ply:ChatPrint("WARNING: Attempted to use invalid pill type.")
			return
		end
		
		local oldvel
		if IsValid(old) and old.formTable.type=="phys" then
			local phys = old:GetPhysicsObject()
			oldvel= IsValid(phys) and phys:GetVelocity() or Vector(0,0,0)
		else
			oldvel=ply:GetVelocity()
		end

		--Remove old AFTER we had a chance to set the new
		if IsValid(old) then
			old:Remove()
		//else
		//	old=nil
		end

		//if IsValid(e) then

		e:SetPillForm(name)
		e:SetPillUser(ply)
		e.locked=locked
		e.option=option
		
		e:Spawn()
		e:Activate()
		/*
		if !ply.pill_oldplayerclass then
			ply.pill_oldplayerclass = player_manager.GetPlayerClass(ply)
		end
		player_manager.SetPlayerClass(ply,"player_pill")
		*/
		if mode=="user" then
			if t.type=="ply" then
				ply:SetLocalVelocity(oldvel)
			else
				local phys = e:GetPhysicsObject()
				if IsValid(phys) then phys:SetVelocity(oldvel) end
			end
		end
		
		if mode!="user" or t.type!="ply" then
			ply:SetLocalVelocity(Vector(0,0,0))
		end

		/*if !IsValid(ply.pill_cam) then
			ply.pill_cam = ents.Create("pill_cam")
			ply.pill_cam:SetOwner(ply)
			ply.pill_cam:Spawn()
		end*/

		return e
		//end
	end

	local driveModes={}

	function getDrive(typ)
		return driveModes[typ]
	end
	
	function registerDrive(name,t)
		driveModes[name]=t
	end
end

--set breakout to true to break out of any locks
--returns true if the player was using a pill
--shared because it goes in the noclip function, I guess

function restore(ply,breakout)
	local ent = getMappedEnt(ply)
	if IsValid(ent) then
		if SERVER then
			if ent.locked and not breakout then
				if locked_perma[ply:SteamID()] then
					ply:ChatPrint("You are locked in your current pill -- FOREVER!")
				elseif locked_game[ply:SteamID()] then
					ply:ChatPrint("You are locked in your current pill until the map changes.")
				else
					ply:ChatPrint("You are locked in your current pill until you die.")
				end
			else
				/*if ply.pill_oldplayerclass then
					player_manager.SetPlayerClass(ply,ply.pill_oldplayerclass)
					ply.pill_oldplayerclass=nil
				end*/
			
				ent.notDead=true
				ent:Remove()
			end
			
			if not breakout then
				net.Start("pk_pill_morphsound")
				net.WriteBit(ent.notDead)
				net.Send(ply)
			else
				locked_game[ply:SteamID()]=nil
				locked_perma[ply:SteamID()]=nil
				file.Write("pill_config/permalocked.txt",util.TableToKeyValues(locked_perma,"permalocked"))
			end
		end
		return true
	//else
	//	return false
	end
end

//
//DAS HOOKS
//

if SERVER then
	hook.Add("KeyPress","pk_pill_keypress",function(ply,key)
		local ent = getMappedEnt(ply)
		if IsValid(ent) then
			ent:DoKeyPress(ply,key)
		end
	end)

	hook.Add("PlayerSwitchFlashlight","pk_pill_flashlight",function(ply,on)
		local ent = getMappedEnt(ply)
		if IsValid(ent)&&on then
			if ent.formTable.flashlight then
				ent.formTable.flashlight(ply,ent)
			end
			return false
		end
	end)

	hook.Add("SetupPlayerVisibility","pk_pill_pvs",function(ply)
		if IsValid(getMappedEnt(ply))&&getMappedEnt(ply).formTable.type=="phys" then
			AddOriginToPVS(getMappedEnt(ply):GetPos())
		end
	end)

	hook.Add("PlayerDeathThink","pk_pill_nospawn",function(ply)
		if getMappedEnt(ply) then return false end
	end)

	hook.Add("DoAnimationEvent","pk_pill_triggerAnims",function(ply,event,data)
		if IsValid(getMappedEnt(ply)) && getMappedEnt(ply).formTable.type=="ply" then
			if event==PLAYERANIMEVENT_JUMP then
				getMappedEnt(ply):PillAnim("jump")
				getMappedEnt(ply):DoJump()
			end
			if event==PLAYERANIMEVENT_ATTACK_PRIMARY then
				getMappedEnt(ply):PillGesture("attack")
			end
			if event==PLAYERANIMEVENT_ATTACK_SECONDARY then
				getMappedEnt(ply):PillGesture("attack2")
			end
			if event==PLAYERANIMEVENT_RELOAD then
				getMappedEnt(ply):PillGesture("reload")
			end
		end
	end)

	hook.Add("OnPlayerHitGround","pk_pill_hitground",function(ply)
		local ent = getMappedEnt(ply)
		if IsValid(ent) then
			if ent.formTable.land then
				ent.formTable.land(ply,ent)
				ent:PillSound("land")
			end
			if ent.formTable.noFallDamage or ent.formTable.type=="phys" then
				return true
			end
		end
	end)

	hook.Add("DoPlayerDeath","pk_pill_death",function(ply)
		if IsValid(getMappedEnt(ply)) then
			if SERVER then getMappedEnt(ply):PillDie() end
			return false
		end
	end)

	hook.Add("PlayerCanPickupWeapon","pk_pill_pickupWeapon",function(ply,wep)
		if IsValid(getMappedEnt(ply)) then
			if getMappedEnt(ply).formTable.type=="ply" then
				if getMappedEnt(ply).formTable.validHoldTypes&&table.HasValue(getMappedEnt(ply).formTable.validHoldTypes,wep:GetHoldType()) then
					return true
				end
				return false
			else
				return false
			end
		end
	end)

	hook.Add("PlayerFootstep", "pk_pill_step", function(ply,pos,foot,snd,vol,filter)
		local ent = getMappedEnt(ply)
		if IsValid(ent) then
			if ent.formTable.type=="phys" or ent.formTable.muteSteps then
				return true
			else
				return ent:PillSound("step",pos)
			end
		end
	end)
	
	hook.Add("PlayerInitialSpawn", "pk_pill_transmit_restrictions", function(ply)
		net.Start("pk_pill_restrict")
		net.WriteTable(restrictions)
		net.Send(ply)

		if darkrp_costs then
			net.Start("pk_pill_init_darkrp")
			net.WriteTable(darkrp_costs)
			net.Send(ply)
		end
	end)
	
	hook.Add("PlayerSpawn", "pk_pill_force_on_spawn", function(ply)
		local forcedType = locked_perma[ply:SteamID()] or locked_game[ply:SteamID()]
		if forcedType then
			local e = apply(ply,forcedType)
			if IsValid(e) then e.locked=true end
			return
		end
	end)

	//For compatibility with player resizer and God knows what else
	hook.Add("SetPlayerSpeed", "pk_pill_speed_enforcer", function(ply,walk,run)
		if IsValid(getMappedEnt(ply)) then
			return false
		end
	end)

	/*hook.Add("PlayerStepSoundTime", "pk_pill_step_time", function(ply,type,walking)    MEH!!
		local ent = playerMap[ply]
		if IsValid(ent) then
			//if ent.formTable.stepSize then
				
			//end
			return 100
		end
	end)*/
else //CLIENT HOOKS
	hook.Add("HUDPaint","pk_pill_hud",function()
		local ent = getMappedEnt(LocalPlayer())
		if IsValid(ent) then
			/*if (ent.formTable.health) then
				local hpMax=ent.formTable.health
				local hpCurrent=ent:GetPillHealth()
				draw.RoundedBox(6,40,ScrH()-80,184,50,Color(0,0,0,255))
				if !ent.formTable.onlyTakesExplosiveDamage then
					if hpCurrent>hpMax then
						surface.SetDrawColor(Color(255,0,0))
						surface.DrawRect(42,ScrH()-68,180,20)
					else
						draw.RoundedBox(6,42,ScrH()-78,math.Clamp(hpCurrent/hpMax*180,12,180),46,Color(255,60,40,255))
					end
					draw.SimpleText("Health: "..math.Round(hpCurrent).."/"..hpMax, "ChatFont", 130, ScrH() - 65, Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
				else
					draw.RoundedBox(6,42,ScrH()-78,math.max(hpCurrent/hpMax*180,12),46,Color(255,100,40,255))
					draw.SimpleText("Hits Left: "..hpCurrent.."/"..hpMax, "ChatFont", 130, ScrH() - 65, Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
				end
			end*/

			if ent.formTable.type=="phys"&&ent.formTable.aim&&ent.formTable.aim.attachment&&(!ent.formTable.aim.usesSecondaryEnt||IsValid(ent:GetPillAimEnt())) then
				local aimEnt=(ent.GetPillAimEnt&&IsValid(ent:GetPillAimEnt())&&ent:GetPillAimEnt())||ent

				local attachment = aimEnt:GetAttachment(aimEnt:LookupAttachment(ent.formTable.aim.attachment))
				local dir
				if ent.formTable.aim.simple or !attachment then
					dir = LocalPlayer():EyeAngles():Forward()
				else
					dir = attachment.Ang:Forward()
				end

				local start= ent.formTable.aim.overrideStart&&ent:LocalToWorld(ent.formTable.aim.overrideStart)||attachment.Pos

				local tr = util.QuickTrace(start,dir*99999, aimEnt)

				local screenPos = tr.HitPos:ToScreen()

				local chColor=Color(160,220,50)
				if IsValid(tr.Entity)&&(tr.Entity:IsPlayer() || tr.Entity:IsNPC() || tr.Entity:GetClass() == "pill_ent_phys") then
					chColor=Color(255,0,0)
				end

				if screenPos.visible then
					draw.TexturedQuad({
						texture = surface.GetTextureID("sprites/hud/v_crosshair1"),
						color = chColor,
						x = screenPos.x-20,
						y = screenPos.y-20,
						w = 40,
						h = 40
					})
				end
			end
		end
		
		//nametags
		if IsValid(LocalPlayer()) then
			local trent = LocalPlayer():GetEyeTraceNoCursor().Entity
			if (IsValid(trent)&&trent:GetClass()=="pill_ent_phys") then
				local pillowner = trent:GetPillUser()
				if IsValid(pillowner) && pillowner!=LocalPlayer() then
					draw.SimpleText(pillowner:GetName(),"ChatFont", ScrW() / 2, ScrH() /2, team.GetColor(pillowner:Team()),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
					if trent:GetPillHealth()>0 then
						draw.SimpleText(trent:GetPillHealth().." HP","ChatFont", ScrW() / 2, ScrH() /2 + 20, team.GetColor(pillowner:Team()),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
					end
				end
			end
		end
	end)

	hook.Add("Initialize","pk_pill_cam_setup",function()
		local oldCalcView = GAMEMODE.CalcView

		function GAMEMODE:CalcView(ply, pos, angles, fov)
			//print(ply:GetViewEntity())

		//hook.Add("CalcView","pk_pill_cam",function(ply, pos, angles, fov)
			local ent = getMappedEnt(LocalPlayer())
			if (IsValid(ent) and ply:GetViewEntity()==ply) then
				//print("v")
				local startpos
				if ent.formTable.type=="phys" then
					startpos = ent:LocalToWorld(ent.formTable.camera&&ent.formTable.camera.offset||Vector(0,0,0))
				else
					startpos=pos
				end

				if var_thirdperson:GetBool() then
					local dist
					if ent.formTable.type=="phys"&&ent.formTable.camera&&ent.formTable.camera.distFromSize then
						dist = ent:BoundingRadius()*5
					else
						dist = ent.formTable.camera&&ent.formTable.camera.dist||100
					end

					local offset = LocalToWorld(Vector(-dist,0,dist/5),Angle(0,0,0),Vector(0,0,0),angles)
					local tr = util.TraceHull({
						start=startpos,
						endpos=startpos+offset,
						filter=ent.camTraceFilter,
						mins=Vector(-5,-5,-5),
						maxs=Vector(5,5,5),
						mask=MASK_VISIBLE
					})
					//PrintTable(ent.camTraceFilter)
					local view = {}
					view.origin = tr.HitPos
					view.angles = angles//(ent.GoodEyeTrace&&(pillEnt:GoodEyeTrace().HitPos-tr.HitPos):Angle())||angles
					view.fov = fov
					view.vm_origin = view.origin+view.angles:Forward()*-500
					return view
				else
					local view = {}
					view.origin = startpos
					view.angles = angles
					view.fov = fov
					return view
				end
			end
			return oldCalcView(self, ply, pos, angles, fov)
		end
	end)

	/*
	Just use the default HUD from now on
	hook.Add("HUDShouldDraw", "pk_pill_hideHud", function(name)
		if (getMappedEnt(LocalPlayer()) && name == "CHudHealth") then
			return false
		end
	end)
	--Causes issues with other players being drawn over their puppets
	hook.Add("ShouldDrawLocalPlayer","pk_pill_thirdperson",function() //only really used for viewmodel... betr ways?
		if getMappedEnt(LocalPlayer()) then
			return true
		end
	end)
	--[[hook.Add("CalcViewModelView","pk_pill_thirdperson",function(wep,mdl,oldpos,oldang,pos,ang)
		if playerMap[LocalPlayer()] && var_thirdperson:GetBool() then
			return pos-Vector(0,0,100),ang
		end
	end)*/
	
	--Just throw this in somewhere else?
	
	/*hook.Add("PopulateToolMenu","pk_pill_createMenu",function()
		spawnmenu.AddToolMenuOption("Options","Parakeet's Pill Pack","pk_pill_menu_settings","Settings","","",function(panel)
			local checkbox = vgui.Create("DCheckBoxLabel")
			checkbox:SetParent(panel)
			checkbox:SetPos(10, 30)
			checkbox:SetText("Thirdperson")
			checkbox:SetTextColor(Color(0,0,0))
			checkbox:SetConVar("pk_pill_thirdperson")
			checkbox:SizeToContents()
		end)
	end)*/
end

//Shared hooks
hook.Add("PlayerNoClip", "pk_pill_noclip", function(ply)
	if restore(ply) then return false end
end)

hook.Add("PhysgunPickup","pk_pill_nograb", function(ply,ent)
	if ent:GetClass()=="pill_ent_phys" then
		if ply:IsAdmin() then return true else return false end
	end
end)

//Includes
if SERVER then include("i/sv_ai.lua") end
include("i/vox.lua")
include("i/util.lua")

//DONE!
print("PILL CORE LOADED")