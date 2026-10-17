/obj/Skills/Buffs/SpecialBuffs/Spirit_Weapon/adjust(mob/p)
	..()
	if(p && p.SchriftNeeded("X"))
		MakesSword = 0
		MakesSecondSword = 0
		MakesGun = 1
		GunPath = /obj/Items/Gun/Quincy/Diagramm
		BuffName = "Diagramm"
