obj/Items/Sword/Medium/Legendary/WeaponSoul/Sword_of_Faith // Kusanagi
	name="Sword of Faith"
	icon='KusanagibutSharper.dmi'
	pixel_x=-16
	pixel_y=-16
	passives = list("MagicSword" = 1, "QuickCast" = 3, "MovingCharge" = 1)
	ShatterTier=0
	Destructable=0
	Ascended=6
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
	HeldSkill=TRUE
	ChargePeriod=2
	SweetSpot=1
	SweetSpotBenefit=5
	ChargeWaveIcon='KenShockwave.dmi'
	ChargeWaveBlend=2

	adjust(mob/p)
		DamageMult = 3 + (p.SagaLevel/2)
		Launcher = 0.5 + (p.SagaLevel/2)

	OnHeldRelease(mob/p, var/benefit)
		adjust(p)
		DamageMult *= benefit
		Launcher *= benefit
		p.Activate(src)

	verb/Gale_Slash()
		set category="Skills"
		usr.BeginHeldSkill(src)

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Kusanagi
	name = "Heavenly Regalia: The Three Treasures"
	StrMult=1.3
	ForMult=1.3
	SpdMult=1.3
	passives = list("WindRelease" = 3, "Flicker" = 2, "Pursuer" = 2, "HybridStrike" = 1)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s three divine treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their imperial luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)
/obj/Skills/Buffs/NuStyle/SwordStyle
	Imperial_Heritage
		StyleActive="Imperial Heritage"
		passives = list("SpiritSword" = 0.5, "ManaStats" = 0.5, "ManaSteal" = 0.5) //Probably needs to scale with asc. (this was gonna be spirit sword and hybrid strike lmao)
		StyleStr=1.25
		StyleFor=1.25
		Finisher="/obj/Skills/Queue/Finisher/Storms_Of_Susanoo"
		adjust(mob/p)
			StyleStr = 1.05 + (0.05 * p.SagaLevel)
			StyleFor = 1.05 + (0.05 * p.SagaLevel)
			passives["SpiritSword"] = 0.5 + (0.1* p.SagaLevel)
			passives["ManaStats"] = 0.5*p.SagaLevel
			passives["ManaSteal"] = 0.5 + (0.1* p.SagaLevel)
		verb/Imperial_Heritage()
			set hidden=1
			adjust(usr)
			Trigger(usr)
/obj/Skills/Queue/Finisher
	Storms_Of_Susanoo
		DamageMult=2
		HitSparkIcon='Slash - Zan.dmi'
		HitSparkX=-32
		HitSparkY=-32
		InstantStrikes=5
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Divine_Rain"
		HitMessage = "delivers a Divine storm upon their foe!"
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher
	Divine_Rain
		StrMult=1.3
		ForMult=1.3
		passives = list("Godspeed" = 1, "BlurringStrikes" = 0.5, "DualCast" = 1)
