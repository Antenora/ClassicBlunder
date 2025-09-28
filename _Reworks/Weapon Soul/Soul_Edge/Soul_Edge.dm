obj/Items/Sword/Heavy/Legendary/WeaponSoul/Blade_of_Chaos
	name="Blade of Chaos"
	icon='SoulEdge.dmi'
	ExtraClass=1

obj/Skills/AutoHit/Soul_Drain
	NeedsSword=1
	Distance=10
	DistanceAround=6
	Gravity=5
	WindUp=1
	WindupMessage="channels the chaos of Soul Edge...."
	DamageMult=3
	StrOffense=1
	ActiveMessage="unleashes a tidal wave of chaos into the area!"
	Area="Around Target"
	GuardBreak=1
	PassThrough=1
	MortalBlow=0.25
	HitSparkIcon = null
	TurfStrike=1
	TurfShiftLayer=EFFECTS_LAYER
	TurfShiftDuration=-10
	TurfShiftDurationSpawn=0
	TurfShiftDurationDespawn=5
	TurfShift='Gravity.dmi'
	Cooldown=30
	EnergyCost=15
	Instinct=1
	adjust(mob/p)
		DamageMult = 3 + p.SagaLevel
		WindUp = 1 - p.SagaLevel/10
	verb/Soul_Drain()
		set category="Skills"
		adjust(usr)
		usr.Activate(src)

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Soul_Edge
	name = "Heavenly Regalia: Chaos Armament"
	StrMult=1.3
	OffMult=1.3
	EndMult=1.3
	passives = list("DemonicDurability" = 2, "Instinct" = 2, "EnhancedSmell" = 1, "EnhancedHearing" = 1, "Flicker" = 2)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s chaotic treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their chaotic luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)