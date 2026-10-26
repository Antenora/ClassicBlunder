obj/Skills/Buffs/var/MakesGun = 0
obj/Skills/Buffs/var/GunPath

/mob/Players/UseBuff(var/obj/Skills/Buffs/B, var/Override, noGCD = FALSE)
	if(B && B.MakesGun && !Override && !BuffOn(B))
		if(EquippedSword() || EquippedStaff())
			src << "You cannot form a bow while holding a blade."
			return 0
		if(EquippedGun())
			src << "You already have a gun equipped."
			return 0
		if(GetCategoryCount("Gear") >= INV_CATEGORY_CAP)
			src << "<font color=#ff6464>You can't hold any more gear (30 max), free a slot to conjure this.</font>"
			return 0
	return ..()

/mob/Players/AllSkillsAdd(var/obj/Skills/Buffs/B)
	. = ..()
	if(B && B.MakesGun && ispath(B.GunPath, /obj/Items/Gun))
		GunConjure(B)
	if(istype(B, /obj/Skills/Buffs/SpecialBuffs/Spirit_Weapon))
		QuincyConvergenceLoop()

/mob/Players/AllSkillsRemove(obj/Skills/Buffs/B)
	. = ..()
	if(B && B.MakesGun)
		GunDispel()

/mob/Players/Logout()
	for(var/obj/Skills/Buffs/b in src)
		if(b.Using && b.MakesGun)
			b.Trigger(src, 1)
	..()

/mob/proc/GunConjure(obj/Skills/Buffs/B)
	if(src.QuincyWeaponItem)
		GunDispel()
	var/p = B.GunPath
	var/obj/Items/Gun/G = new p(src)
	G.Unobtainable = 1
	G.Stealable = 0
	G.Destructable = 0
	G.Savable = 0
	G.ConjureShape(src)
	if(G.GunEquipRefused(src))
		del G
		return
	G.GunAlignEquip(src)
	G.PermEquip = 1
	src.QuincyWeaponItem = G
	if(src.client)
		src.client.RefreshAmmoHUD()

/mob/proc/GunDispel()
	var/obj/Items/Gun/G = src.QuincyWeaponItem
	src.QuincyWeaponItem = null
	if(!G)
		return
	G.PermEquip = 0
	if(G.suffix && G.loc == src)
		G.GunAlignEquip(src)
	del G

obj/Items/Gun/proc/ConjureShape(mob/p)
	return

obj/Items/Gun/Quincy
	name = "Spirit Weapon"
	desc = "A weapon of gathered Reishi. Each shot is drawn from the wielder's own Mana; it is never loaded."
	Class = "Light"
	icon = 'Icons/Technology/Gear/Blaster.dmi'
	EquipIcon = 'Icons/Technology/Gear/Blaster.dmi'
	pixel_x = 0
	pixel_y = 0
	MagSize = 1
	Loaded = 0
	Caliber = null
	energy_gun = 1
	energy_per_shot = 0
	heat_per_shot = 0
	mech_only = 0
	BulletIcon = 'Icons/Blasts/LightStrike.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	Unobtainable = 1
	Stealable = 0
	Destructable = 0
	Savable = 0

obj/Items/Gun/Quincy/Heilig_Bogen
	name = "Heilig Bogen"
	icon = 'Icons/Buffs/SagaBuffs/Aether/Aether Bow.dmi'
	EquipIcon = 'Icons/Buffs/SagaBuffs/Aether/Aether Bow.dmi'
	ModelDamage = 1

obj/Items/Gun/Quincy/Reishi_Pistol
	name = "Reishi Pistol"
	ModelDamage = 0.75

obj/Items/Gun/Quincy/Reishi_Pistol/New()
	GunClass = QuincyGunClass(/obj/Items/Gun/Automatic)
	..()

/proc/QuincyGunClass(path)
	var/obj/Items/Gun/G = path
	return initial(G.GunClass)

obj/Items/Gun/Quincy/EnergyShots()
	var/mob/m = src.loc
	if(!ismob(m))
		return 0
	return m.ManaAmount >= QUINCY_PFEIL_MANA ? 1 : 0

obj/Items/Gun/Quincy/EnergyReset()
	Loaded = EnergyShots()
	MagSize = 1

obj/Items/Gun/Quincy/ConjureShape(mob/p)
	if(!p)
		return
	var/spd = 1
	var/dmg = 1
	switch(p.QuincyWeaponClass)
		if("Short")
			spd = 1.15
			dmg = 0.9
		if("Long")
			spd = 0.85
			dmg = 1.15
		if("Pistol")
			GunClass = QuincyGunClass(/obj/Items/Gun/Handgun)
		if("Repeater")
			GunClass = QuincyGunClass(/obj/Items/Gun/Automatic)
			dmg = 0.75
	dmg *= 1 + 0.1 * (max(1, p.QuincyLevel) - 1)
	if(istype(src, /obj/Items/Gun/Quincy/Reishi_Pistol) && p.QuincyGloveMastery >= QUINCY_GLOVE_MASTERY)
		dmg *= 1.2
	ModelSpeed = spd
	ModelDamage = dmg
	setStatLine()
	EnergyReset()

/mob/Players/GunChargedShot(obj/Items/Gun/g)
	if(istype(g, /obj/Items/Gun/Quincy))
		LoseMana(QUINCY_PFEIL_MANA)
		g.EnergyReset()
		return
	return ..()

/mob/Players/GunBatteryReload(obj/Items/Gun/G)
	if(istype(G, /obj/Items/Gun/Quincy))
		src << "Reishi is drawn, not loaded."
		return 0
	return ..()

/mob/Players/GunStampPassives(obj/Skills/Projectile/S, obj/Items/Gun/g, bloom = 0)
	..()
	if(S && istype(g, /obj/Items/Gun/Quincy/Heilig_Bogen) && QuincyGloveMastery >= QUINCY_GLOVE_MASTERY)
		S.Blasts = 3

/obj/Skills/Buffs/SpecialBuffs/Spirit_Weapon
	name = "Spirit Weapon"
	BuffName = "Spirit Weapon"
	Cooldown = 10
	passives = list("Reishi Convergence" = 1)
	ActiveMessage = "gathers the Reishi around them into a weapon!"
	OffMessage = "lets the Reishi disperse."

	adjust(mob/p)
		MakesGun = 0
		GunPath = null
		MakesSword = 0
		MakesSecondSword = 0
		passives = list("Reishi Convergence" = 1)
		switch(p.QuincyWeapon)
			if("Bow")
				MakesGun = 1
				GunPath = /obj/Items/Gun/Quincy/Heilig_Bogen
				BuffName = "Heilig Bogen"
			if("Gun")
				MakesGun = 1
				GunPath = /obj/Items/Gun/Quincy/Reishi_Pistol
				BuffName = "Reishi Pistol"
			if("Sword")
				MakesSword = 1
				SwordIcon = 'Icons/Buffs/SagaBuffs/Aether/Aether Blade.dmi'
				SwordX = -32
				SwordY = -32
				SwordName = "Reishi Saber"
				BuffName = "Reishi Saber"
				switch(p.QuincyWeaponClass)
					if("Longsword")
						SwordClass = "Medium"
					else
						SwordClass = "Light"
				if(p.QuincyWeaponClass == "Claws")
					MakesSecondSword = 1
					SwordClassSecond = "Light"
					SwordNameSecond = "Reishi Saber"
					SwordIconSecond = 'Icons/Buffs/SagaBuffs/Aether/Aether Blade.dmi'
					SwordXSecond = -32
					SwordYSecond = -32

	verb/Spirit_Weapon()
		set name = "Spirit Weapon"
		set category = "Skills"
		var/seal = text2path("/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Quincy_Seal")
		if(seal && locate(seal) in usr)
			usr << "Your body has sealed itself off from the Reishi."
			return
		if(!usr.BuffOn(src))
			adjust(usr)
		src.Trigger(usr)

	verb/Transfigure_Spirit_Weapon()
		set category = "Character Custom"
		set hidden = 1
		if(usr.BuffOn(src))
			usr << "You can't reshape your weapon while it is drawn."
			return
		if(usr.QuincyLevel >= 4)
			usr << "Your weapon has settled into its final shape."
			return
		var/list/opts = QuincyWeaponClasses(usr.QuincyWeapon)
		if(!opts.len)
			return
		var/pick = Ask(usr, "What shape does your Spirit Weapon take?", "Transfigure Spirit Weapon", null, "pick", opts, 1)
		if(isnull(pick))
			return
		usr.QuincyWeaponClass = pick
		usr << "Your Spirit Weapon now takes the [pick] shape."

/obj/Skills/Projectile/Quincy

/obj/Skills/Projectile/Quincy/Heilig_Pfeil_Blade
	name = "Heilig Pfeil"
	Blasts = 1
	Delay = 1
	DamageMult = 0.8
	Distance = 10
	Speed = 0.3
	Cooldown = 4
	ManaCost = 2
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	Variation = 2
	SBuffNeeded = "Reishi Saber"
	ActiveMessage = "looses a volley of Heilig Pfeil from their blade!"

	adjust(mob/p)
		var/lvl = max(1, p.QuincyLevel)
		DamageMult = 0.8 * (1 + 0.1 * (lvl - 1))
		Blasts = p.QuincyGloveMastery >= QUINCY_GLOVE_MASTERY ? 6 : 1

	verb/Heilig_Pfeil()
		set name = "Heilig Pfeil"
		set category = "Skills"
		adjust(usr)
		usr.UseProjectile(src)
