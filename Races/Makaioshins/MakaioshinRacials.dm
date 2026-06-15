/*/obj/Skills/Buffs/SlotlessBuffs/Falldown_Mode/Makaioshin
	passives = list("HellPower" = 0.1, "AngerAdaptiveForce" = 0.25, "TechniqueMastery" = 2, "Juggernaut" = 0.5, "FakePeace" = -1, "Incomplete"=-1)
	Cooldown = -1
	TimerLimit = 0
	BuffName = "Falldown Mode"
	name = "Falldown Mode"
	IconLock='GenesicR.dmi'
	IconLockBlend=BLEND_MULTIPLY
	LockX=-32
	LockY=-32
	HealthThreshold = 0.0001
	var/current_charges = 1
	var/last_charge_gain = 0
/*	var/list/trueFormPerAsc = list( 1 = list("AngerAdaptiveForce" = 0.1, "TechniqueMastery" = 2, "Juggernaut" = 1, "Hellrisen" = 0.25, , "FakePeace" = -1, "Incomplete"=-0.75), \
									2 = list("AngerAdaptiveForce" = 0.2,"TechniqueMastery" = 3, "FluidForm" = 1, "Juggernaut" = 1.5, "Hellrisen" = 0.5, , "FakePeace" = -1, "Incomplete"=-0.5), \
									3 = list("AngerAdaptiveForce" = 0.25,"TechniqueMastery" = 4, "FluidForm" = 1.5, "Juggernaut" = 2,"Hellrisen" = 0.5, , "FakePeace" = -1, "Incomplete"=-0.25), \
									4 = list("AngerAdaptiveForce" = 0.5,"TechniqueMastery" = 6, "FluidForm" = 2, "Juggernaut" = 2,"Hellrisen" = 0.5, , "FakePeace" = -1))*/
	ActiveMessage = "has resolved their contradictory nature!"// Darkness and light, once wandering through creation, gather together and open the door to their truth! <b>Become as one, [usr.name] and [usr.TrueName]!</b></i>"

	adjust(mob/p)
	//	for(var/passive in trueFormPerAsc[p.AscensionsAcquired])
	//		passives[passive] = trueFormPerAsc[p.AscensionsAcquired][passive]
		if(p.AscensionsAcquired==1)
			passives =list("AngerAdaptiveForce" = 0.1, "TechniqueMastery" = 2, "Juggernaut" = 1, "HellRisen" = 0.25, , "FakePeace" = -1, "Incomplete"=-0.75)
		if(p.AscensionsAcquired==2)
			passives = list("AngerAdaptiveForce" = 0.2,"TechniqueMastery" = 3, "FluidForm" = 1, "Juggernaut" = 1.5, "HellRisen" = 0.5, , "FakePeace" = -1, "Incomplete"=-0.5)
		if(p.AscensionsAcquired==3)
			passives = list("AngerAdaptiveForce" = 0.25,"TechniqueMastery" = 4, "FluidForm" = 1.5, "Juggernaut" = 2,"HellRisen" = 0.5, , "FakePeace" = -1, "Incomplete"=-0.25)
		if(p.AscensionsAcquired==4)
			passives = list("AngerAdaptiveForce" = 0.5,"TechniqueMastery" = 6, "FluidForm" = 2, "Juggernaut" = 2,"HellRisen" = 0.5, , "FakePeace" = -1)
		var/hellpowerdif = 1 - p.passive_handler.Get("HellPower")
		if(hellpowerdif < 0)
			hellpowerdif = 0
		passives["HellPower"] = hellpowerdif
	verb/Falldown_Mode()
		set category = "Skills"
		adjust(usr)
		if(!usr.BuffOn(src))
			if(current_charges - 1 < 0)
				usr << "You have ran out of true form charges..."
				return
			adjust(usr)
			var/yesno = input(usr, "Are you sure?") in list("Yes", "No")
			if(yesno == "Yes")
				current_charges--
				usr << "You have [current_charges] charges of true form left."
			else
				return 0
		ActiveMessage = "has resolved their contradictory nature! Darkness and light, once wandering through creation, gather together and open the door to  truth! <b>Become as one, [usr.name] and [usr.TrueName]!</b></i>"
		src.Trigger(usr)*/

// Satan Mode skills
/obj/Skills/AutoHit/Purgatorial_Flame
	Area="Arc"
	Distance=5
	StrOffense=1
	ForOffense=1
	DamageMult=0.7
	RoundMovement=0
	ComboMaster=1
	Rounds=10
	Cooldown=120
	EnergyCost=2
	Icon='shadowfire.dmi'
	IconX=0
	IconY=0
	Size=1.5
	HitSparkIcon='shadowfire.dmi'
	HitSparkX=0
	HitSparkY=0
	HitSparkTurns=1
	HitSparkSize=1
	HitSparkDispersion=1
	TurfStrike=1
	EnergyCost=1
	Instinct=1
	ActiveMessage="leaves hellish flames in their wake!"
	proc/getArcTurfs(mob/user)
		var/list/turfs = list()
		var/turf/forward = get_turf(user)
		if(!forward) return turfs
		var/left_dir = turn(user.dir, 90)
		var/right_dir = turn(user.dir, -90)
		for(var/f = 0; f <= Distance; f++)
			if(f > 0)
				forward = get_step(forward, user.dir)
			if(!forward) break
			turfs |= forward
			var/turf/left_turf = forward
			var/turf/right_turf = forward
			var/limit = (f == 0) ? 1 : f
			for(var/s = 1; s <= limit; s++)
				left_turf = get_step(left_turf, left_dir)
				if(left_turf) turfs |= left_turf
				right_turf = get_step(right_turf, right_dir)
				if(right_turf) turfs |= right_turf
		return turfs
	verb/Purgatorial_Flame()
		set name="Purgatorial Flame"
		set category="Skills"
		if(usr.transActive != 2 || !istype(usr.race, /race/makaioshin))
			usr << "You must be in Satan Mode to use this!"
			return
		adjust(usr)
		var/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/Hellstorm/H = new
		H.icon_to_use = 'shadowfire.dmi'
		H.states_to_use = list("","1")
		H.adjust(usr)
		for(var/turf/T in getArcTurfs(usr))
			T.applyEffect(H, 500, usr)
		usr.Activate(src)

/obj/Skills/Projectile/Beams/Divine_Atonement
	DamageMult=20
	ChargeRate=2
	Dodgeable=0
	Distance=30
	BeamTime=60
	Knockback=1
	IconLock='BeamDodon.dmi'
	Cooldown=150
	EnergyCost=5
	ExcludeFacingDir=1
	InstantDamageChance=1
	ChargeMessage="begins channeling Divine Atonement..."
	ActiveMessage="unleashes Divine Atonement!"
	verb/Divine_Atonement()
		set category="Skills"
		if(usr.transActive != 2 || !istype(usr.race, /race/makaioshin))
			usr << "You must be in Satan Mode to use this!"
			return
		usr.UseProjectile(src)

// Shared 300-second cooldown across all Chaos skills when triggered via combo.
// Makaioshins with Limited Rank-Up use individual per-skill cooldowns instead.
/mob/proc/cooldownChaosSkillSingle(obj/Skills/s)
	if(s)
		s.Cooldown(1, 3000, src)

/mob/proc/cooldownAllChaosSkills()
	var/list/chaosTypes = list(
		/obj/Skills/AutoHit/Chaos_Degrade,
		/obj/Skills/Buffs/SlotlessBuffs/Chaos_Soldier,
		/obj/Skills/Buffs/SlotlessBuffs/Chaos_Control
	)
	for(var/t in chaosTypes)
		var/obj/Skills/s = locate(t) in src
		if(s)
			s.Cooldown(1, 3000, src)

/obj/Skills/Buffs/SlotlessBuffs/Chaos_Control
	BuffName = "Chaos Control"
	name = "Chaos Control"
	Cooldown = 300
	Mastery = 1
	desc = "Freeze time for everyone in view with no exceptions."
	var/tmp/list/frozen_mobs

/obj/Skills/AutoHit/Chaos_Degrade
	Area = "Target"
	Distance = 10
	Cooldown = 300
	FixedDamage = 10
	DamageMult = 25
	StrOffense = 1
	EndDefense = 1
	GuardBreak = 1
	ActiveMessage = "corrodes their target's existence with chaos!"

/obj/Skills/Buffs/SlotlessBuffs/Chaos_Soldier
	BuffName = "Chaos Soldier"
	name = "Chaos Soldier"
	Cooldown = 300
	TimerLimit = 120
	StrMult = 1.2
	ForMult = 1.2
	SpdMult = 1.2
	OffMult = 1.2
	DefMult = 1.2
	EndMult = 1.2
	VaizardHealth = 10
	passives = list()
	ActiveMessage = "unleashes the power of their duality! One soul invites the light! One soul guides the darkness! Between the souls of light and darkness, the light of chaos is created!"
	OffMessage = "releases the power of chaos."

/*/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles //weaker versions for Makaioshins and Celestials
	Selfless_State
		Copyable=0
		passives = list("Flow" = 1, "Deflection" = 1, "SoftStyle" = 1)
		StyleSpd=1.15
		StyleDef=1.15
		BladeFisting=1
		SignatureTechnique=1
		StyleActive="Selfless State"
		verb/Selfless_State()
			set hidden=1
			src.Trigger(usr)
	Incomplete_Ultra_Instinct
		Copyable=0
		passives = list("Deflection" = 1, "SoftStyle" = 1, "Flow" = 2, "Instinct" = 1, "CounterMaster" = 1)
		StyleSpd=1.25
		StyleOff=1.15
		StyleDef=1.25
		BladeFisting=1
		SignatureTechnique=2
		StyleActive="Ultra Instinct (In-Training)"
		verb/Incomplete_Ultra_Instinct()
			set hidden=1
			src.Trigger(usr)
	Ultra_Instinct
		Copyable=0
		passives = list("Deflection" = 1, "SoftStyle" = 1, "Flow" = 2, "Instinct" = 2, "CounterMaster" = 2, "Godspeed" = 1)
		StyleSpd=1.3
		StyleOff=1.35
		StyleDef=1.35
		SignatureTechnique=3
		BladeFisting=1
		StyleActive="Ultra Instinct (Complete)"
		verb/Ultra_Instinct()
			set hidden=1
			src.Trigger(usr)
	Perfected_Ultra_Instinct
		Copyable=0
		passives = list("Deflection" = 1, "SoftStyle" = 1, "LikeWater" = 4, "Flow" = 3, "Instinct" = 3, "CounterMaster" = 3, "Godspeed" = 1)
		StyleSpd=1.5
		StyleOff=1.5
		StyleDef=1.5
		SignatureTechnique=4
		BladeFisting=1
		StyleActive="Perfected Ultra Instinct"
		verb/Perfected_Ultra_Instinct()
			set hidden=1
			src.Trigger(usr)*/
