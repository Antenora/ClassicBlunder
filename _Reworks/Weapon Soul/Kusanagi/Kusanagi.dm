obj/Items/Sword/Medium/Legendary/WeaponSoul/Sword_of_Faith // Kusanagi
	name="Sword of Faith"
	icon='KusanagibutSharper.dmi'
	pixel_x=-16
	pixel_y=-16
	passives = list("MagicSword" = 1, "ManaSteal" = 2, "WindRelease" = 1)
	MagicSword=1
	TierTechniques=list(null, null, null, null, null, "/obj/Skills/Buffs/SlotlessBuffs/Totsuka_no_Tsurugi")

obj/Skills/AutoHit/Gale_Slash
	NeedsSword = 1
	Area="Circle"
	Distance=2
	StrOffense=1
	DamageMult=2
	ManaDrain = 2
	Launcher=1
	NoLock=1
	NoAttackLock=1
	Cooldown=30
	Size=2
	Rounds=5
	Icon='SweepingKick.dmi'
	IconX=-32
	IconY=-32
	EnergyCost=1
	CanBeDodged=1
	Knockback = 5
	ActiveMessage="lets loose a sweeping gale of wind around them!"
	adjust(mob/p)
		DamageMult = 0.5 + (p.SagaLevel/4)
		Launcher = 0.5 + (p.SagaLevel/2)
	verb/Gale_Slash()
		set category="Skills"
		adjust(usr)
		usr.Activate(src)

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Kusanagi
	name = "Heavenly Regalia: The Three Treasures"
	StrMult=1.3
	OffMult=1.3
	DefMult=1.3
	passives = list("WindRelease" = 1, "ManaSteal" = 3)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s three divine treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their imperial luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)