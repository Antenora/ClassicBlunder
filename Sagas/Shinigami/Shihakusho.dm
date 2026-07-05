obj/Items/Armor/Mobile_Armor/Shinigami_Shihakusho
	name = "Shihakushō"
	icon = 'Icons/Armor/Shinigami Vest.dmi'
	Ascended = 2
	Destructable = 0
	ShatterTier = 0
	PermEquip = 1
	Stealable = 0
	IsShihakusho = 1
	Saga = "Shinigami"
	Cost = 0
	Unobtainable = 1

	New()
		..()
		src.icon = 'Icons/Armor/Shinigami Vest.dmi'

	ObjectUse(mob/Players/User = usr)
		if(!suffix && !User.InShinigamiForm)
			User << "Your Shihakushō can only be equipped through Shinigami Form."
			return
		..()

obj/Items/Armor/Balanced_Armor/Shinigami_Shihakusho
	name = "Shihakushō"
	icon = 'Icons/Armor/Shinigami Vest.dmi'
	Ascended = 2
	Destructable = 0
	ShatterTier = 0
	PermEquip = 1
	IsShihakusho = 1
	Saga = "Shinigami"
	Cost = 0
	Unobtainable = 1

	New()
		..()
		src.icon = 'Icons/Armor/Shinigami Vest.dmi'

	ObjectUse(mob/Players/User = usr)
		if(!suffix && !User.InShinigamiForm)
			User << "Your Shihakushō can only be equipped through Shinigami Form."
			return
		..()

obj/Items/Armor/Plated_Armor/Shinigami_Shihakusho
	name = "Shihakushō"
	icon = 'Icons/Armor/Shinigami Vest.dmi'
	Ascended = 2
	Destructable = 0
	ShatterTier = 0
	PermEquip = 1
	IsShihakusho = 1
	Saga = "Shinigami"
	Cost = 0
	Unobtainable = 1

	New()
		..()
		src.icon = 'Icons/Armor/Shinigami Vest.dmi'

	ObjectUse(mob/Players/User = usr)
		if(!suffix && !User.InShinigamiForm)
			User << "Your Shihakushō can only be equipped through Shinigami Form."
			return
		..()
