obj/Items/var
	IsZanpakuto = 0
	IsShihakusho = 0

obj/Items/Sword/Medium/Legendary/Shinigami/Zanpakuto
	name = "Zanpakutō"
	icon = 'Goemon Katana Unsheathed.dmi'
	pixel_x = -16
	pixel_y = -16
	Ascended = 2
	Destructable = 0
	Stealable = 0
	ShatterTier = 0
	PermEquip = 1
	IsZanpakuto = 1
	Saga = "Shinigami"
	Cost = 0
	Unobtainable = 1

	ObjectUse(mob/Players/User = usr)
		if(!suffix && !User.InShinigamiForm)
			User << "Your Zanpakutō can only be equipped through Shinigami Form."
			return
		..()
