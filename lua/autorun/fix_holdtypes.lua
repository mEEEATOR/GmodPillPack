--This is a hacky fix to the SWEP holdtype bug

--Periodically disable this file so we can see if garry got his shit together

if CLIENT then return end

hook.Add("Initialize","holdtype_grry_plz_fix",function()
	local metaTable = FindMetaTable("Weapon")
	local baseTable = weapons.Get("weapon_base")

	local oldGetter = metaTable.GetHoldType
	local oldSetter = baseTable.SetWeaponHoldType

	metaTable.GetHoldType = function(self)
		return self.__holdtype_grry_plz_fix or oldGetter(self)
	end
	metaTable.SetWeaponHoldType = function(self,holdtype)
		self.__holdtype_grry_plz_fix=holdtype
				
		oldSetter(self,holdtype)
	end
end)
