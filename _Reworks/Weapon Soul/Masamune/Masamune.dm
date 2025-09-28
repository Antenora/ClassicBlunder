obj/Items/Sword/Light/Legendary/WeaponSoul/Sword_of_Purity//Masamune
	name="Sword of Purity"
	icon='Masamune.dmi'
	passives = list("Purity" = 1)

obj/Skills/AutoHit/Divine_Cleansing
	NeedsSword = 1
	Area="Circle"
	StrOffense=1
	HitSelf = TRUE
	DamageMult=4
	Cleansing = 3
	Cooldown=30
	Rounds=5
	Distance = 5
	RoundMovement=1
	Size = 5
	Icon='SweepingKick.dmi'
	IconX=-32
	IconY=-32
	FlickSpin=1
	EnergyCost=1
	ActiveMessage="cuts through debilitation with the power of Masamune's purity!"
	adjust(mob/p)
		DamageMult = 4 + p.SagaLevel
		Size = 5 + p.SagaLevel
	verb/Divine_Cleansing()
		set category="Skills"
		adjust(usr)
		usr.Activate(src)

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Masamune
	name = "Heavenly Regalia: Blessed Blade"
	StrMult=1.3
	OffMult=1.3
	DefMult=1.3
	passives = list("BeyondPurity" = 1, "PureReduction" = 4) // may god have mercy on my soul
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s soothing treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their healing luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)