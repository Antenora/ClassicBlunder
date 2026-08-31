obj/Items/Sword/Heavy/Legendary/WeaponSoul/Sword_of_Hope//Durendal
	name="Sword of Hope"
	icon='Durendal.dmi'
	passives = list("ShockwaveBlows" = 1, "ArmorPeeling" = 1)
	Ascended=6
	Destructable=0
	ShatterTier=0

obj/Skills/AutoHit/Shockwave_Blows
	Area="Circle"
	Distance=5
	GuardBreak=1
	DamageMult=1.2
	Knockback=2
	Cooldown=3
	Shockwaves=1
	Shockwave=3
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	ActiveMessage="swings their blade hard enough to make the air ripple!"
	EnergyCost=1

obj/Skills/AutoHit/DurendalPressure
	NoAttackLock=1
	NeedsSword=1
	Area="Wave"
	Distance=4
	StrScaling=1
	Knockback=1
	HitSparkIcon='Hit Effect Divine.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=5
	TurfStrike=1
	Slow=1
	DamageMult=4.5//First step is 1 damage
	StepsDamage=1//fourth step is 5 damage
	ActiveMessage="whiffs their swing, causing a powerful wave of pressure!"
	Cooldown = 10
	EnergyCost=2

obj/Skills/AutoHit/Great_Divide
	NeedsSword=1
	ABuffNeeded="Soul Resonance"
	EnergyCost=25
	Area="Arc"
	Distance=10
	DamageMult=15
	StrScaling=1
	EndEffectiveness=1
	ForScaling=0
	Cooldown=-1
	HitSparkIcon='Hit Effect Divine.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=7
	TurfStrike=1
	Divide=1
	Slow=1
	WindUp=1
	GuardBreak=1//Can't be dodged or blocked
	WindupMessage="draws their blade back for a colossal swing..."
	ActiveMessage="releases a gigaton slash that parts the earth like butter!"
	verb/Great_Divide()
		set category="Skills"
		usr.Activate(src)

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Durendal
	name = "Heavenly Regalia: The Saint"
	StrMult=1.3
	EndMult=1.3
	DefMult=1.3
	passives = list("ShockwaveBlows" = 1, "HolyMod" = 2)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s legendary weapon and horn ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their Saintly luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)

/obj/Skills/Buffs/NuStyle/SwordStyle //slightly weaker than t2. maybe make it scaling???
	Saintlike_Behavior
		StyleActive="Saintlike Behavior"
		passives = list("HolyMod" = 1)
		StyleStr=1.25
		StyleEnd=1.25
		Finisher="/obj/Skills/Queue/Finisher/Heavenly_Judgement"
		adjust(mob/p)
			StyleStr = 1.05 + (0.05 * p.SagaLevel)
			StyleEnd = 1.05 + (0.05 * p.SagaLevel)
			passives["HolyMod"] = 1 + (p.SagaLevel)
		verb/Saintlike_Behavior()
			set hidden=1
			adjust(usr)
			Trigger(usr)
/obj/Skills/Queue/Finisher
	Heavenly_Judgement
		DamageMult=3
		HitSparkIcon='Slash - Zan.dmi'
		HitSparkX=-32
		HitSparkY=-32
		InstantStrikes=5
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Divine_Messenger"
		HitMessage = "subjects their foe to Heavenly Judgement!"
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher
	Divine_Messenger
		StrMult=1.3
		EndMult=1.3
		passives = list("HolyMod" = 2, "Juggernaut" = 1, "EvilResist" = 2)