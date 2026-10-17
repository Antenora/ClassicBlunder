/obj/Skills/Buffs/SpecialBuffs/Spirit_Weapon/adjust(mob/p)
	..()
	if(p && p.SchriftNeeded("I"))
		MakesGun = 0
		GunPath = null
		MakesSword = 1
		SwordIcon = 'Icons/Buffs/SagaBuffs/Aether/Aether Blade.dmi'
		SwordX = -32
		SwordY = -32
		SwordName = "Reishi Claw"
		SwordClass = "Light"
		MakesSecondSword = 1
		SwordClassSecond = "Light"
		SwordNameSecond = "Reishi Claw"
		SwordIconSecond = 'Icons/Buffs/SagaBuffs/Aether/Aether Blade.dmi'
		SwordXSecond = -32
		SwordYSecond = -32
		BuffName = "Reishi Saber"
