/obj/Skills/Buffs/SpecialBuffs/Spirit_Weapon/adjust(mob/p)
	..()
	if(p && p.SchriftNeeded("T") && p.QuincyVollstandigOnNow())
		MakesGun = 0
		GunPath = null
		MakesSword = 1
		MakesSecondSword = 1
		SwordName = "Lightning Sword"
		SwordNameSecond = "Lightning Sword"
		SwordIcon = 'Icons/Buffs/SagaBuffs/Aether/Aether Blade.dmi'
		SwordIconSecond = 'Icons/Buffs/SagaBuffs/Aether/Aether Blade.dmi'
		SwordX = -32
		SwordY = -32
		SwordXSecond = -32
		SwordYSecond = -32
		SwordClass = "Light"
		SwordClassSecond = "Light"
