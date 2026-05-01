obj/Items/Sword/Heavy/Legendary/WeaponSoul/Blade_of_Chaos
	name="Blade of Chaos"
	icon='SoulEdge.dmi'
	ExtraClass=1
	Ascended=6
	passives = list("Extend" = 1)
	Destructable=0
	ShatterTier=0

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
		DamageMult = 5 + p.SagaLevel
		WindUp = 1 - p.SagaLevel/10
	verb/Soul_Drain()
		set category="Skills"
		adjust(usr)
		usr.Activate(src)

obj/Skills/AutoHit/Dark_Reconquista
	NeedsSword=1
	Copyable=2
	Area="Wave"
	ComboMaster=1
	Distance=2
	StrOffense=1
	EndDefense=1
	DamageMult=10
	HitSparkIcon='Slash - Vampire.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=1.5
	HitSparkDispersion=1
	TurfStrike=2
	TurfShift='Dirt1.dmi'
	TurfShiftDuration=3
	EnergyCost=3
	Cooldown=45
	ActiveMessage="draws back Soul Edge and drives it forward in a devastating, soul-rending slash!"
	HeldSkill=TRUE
	ChargePeriod=3
	SweetSpot=1.5
	SweetSpotBenefit=3
	ChargeOverlay='DarkShock.dmi'
	ChargeWaveIcon='KenShockwaveBloodlust.dmi'
	ChargeWaveBlend=2

	adjust(mob/p)
		DamageMult = 10 + p.SagaLevel

	OnHeldRelease(mob/p, var/benefit)
		adjust(p)
		DamageMult *= benefit
		p.Activate(src)

	verb/Dark_Reconquista()
		set category="Skills"
		usr.BeginHeldSkill(src)

/obj/Effects/TriumphWave
	icon = 'KenShockwavePurple.dmi'
	pixel_x = -105
	pixel_y = -105
	Grabbable = 0
	mouse_opacity = 0
	layer = EFFECTS_LAYER
	var/max_size = 4.0
	var/wave_lifetime = 30
	var/mob/Players/owner
	var/DamageMult = 1
	var/StrOffense = 1
	var/EndRes = 1
	var/list/hitList = list()

	New()
		animate(src)
		transform = matrix() * 0.1
		alpha = 255
		spawn(0)
			hitDetectLoop()

	proc/hitDetectLoop()
		set waitfor = FALSE
		var/start_time = world.time
		var/prev_radius_tiles = 0.0
		var/list/outsideSet = list()
		while(src)
			var/tick_begin = world.time
			if(!owner || !owner.loc) break
			if(owner.PureRPMode)
				sleep(1)
				start_time += (world.time - tick_begin)
				continue

			var/elapsed = world.time - start_time
			if(elapsed >= wave_lifetime)
				EffectFinish()
				break

			var/t = elapsed / wave_lifetime
			var/scale = 0.1 + (max_size - 0.1) * t
			var/curr_radius_tiles = (scale * 121.0) / 32.0
			src.transform = matrix() * scale
			src.alpha = round(255 * (1 - t))

			for(var/mob/Players/P in players)
				if(!P.client) continue
				if(P == owner) continue
				if(P.z != owner.z) continue
				if(owner.inParty(P.ckey)) continue

				var/dx = P.x - owner.x
				var/dy = P.y - owner.y
				var/dist = sqrt(dx * dx + dy * dy)

				if(dist > curr_radius_tiles)
					if(!(P in outsideSet))
						outsideSet += P
				else
					if(P in outsideSet)
						outsideSet -= P
						if(!(P in hitList))
							if(dist > prev_radius_tiles)
								hitList += P
								dealWaveDamage(P)

			prev_radius_tiles = curr_radius_tiles
			sleep(1)

	proc/dealWaveDamage(mob/Players/target)
		if(!owner || !target) return
		if(owner.PureRPMode) return

		var/powerDif = owner.Power / target.Power
		if(glob.CLAMP_POWER && !owner.ignoresPowerClamp())
			powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)

		var/atk = owner.GetStr(StrOffense)
		if(atk <= 0) atk = 0.01

		var/def = target.getEndStat(1) * EndRes
		if(def <= 0) def = 0.01

		var/FinalDmg = (clamp(powerDif, 0.1, 100000) ** glob.DMG_POWER_EXPONENT) * \
		               (glob.CONSTANT_DAMAGE_EXPONENT + glob.AUTOHIT_EFFECTIVNESS) ** \
		               -(def ** glob.DMG_END_EXPONENT / atk ** glob.DMG_STR_EXPONENT)
		FinalDmg *= DamageMult
		FinalDmg *= owner.GetDamageMod()
		FinalDmg *= glob.AUTOHIT_GLOBAL_DAMAGE

		if(FinalDmg <= 0) return
		target.LoseHealth(FinalDmg)

		var/obj/Effects/HE = new(null, 'fevExplosion - Hellfire.dmi', -32, -32, 0, 1, 8)
		HE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		HE.Target = target
		target.vis_contents += HE

// Automatic followup AutoHit triggered when Triumph's sweet spot is hit.
/obj/Skills/AutoHit/Reconquista_Triumph_Strike
	Area = "Circle"
	AdaptRate = 1
	StrOffense = 1
	DamageMult = 2.5
	ComboMaster = 1
	Rounds = 10
	ChargeTech = 1
	ChargeFlight = 1
	ChargeTime = 0.75
	Grapple = 1
	GrabMaster = 1
	Stunner = 1
	Launcher = 1
	Cooldown = 1
	Size = 1
	EnergyCost = 5
	Instinct = 1
	Icon='DarkPortal.dmi'
	IconX=-35
	IconY=-35
	ActiveMessage = "drives Soul Edge home with a conquering lunge!"

/obj/Skills/AutoHit/Dark_Reconquista_Triumph
	name = "Triumph"
	NeedsSword = 1
	Copyable = 2
	StrOffense = 1
	EndDefense = 1
	Cooldown = 120
	EnergyCost = 3
	HeldSkill = TRUE
	ChargePeriod = 3
	SweetSpot = 2
	SweetSpotBenefit = 4
	ChargeOverlay = 'DarkShock.dmi'
	ChargeWaveIcon = 'KenShockwaveBloodlust.dmi'
	ChargeWaveBlend = 2

	OnHeldRelease(mob/p, var/benefit, var/sweet_spot_hit = FALSE)
		var/obj/Effects/TriumphWave/wave = new(p.loc)
		wave.owner = p
		wave.DamageMult = (15 + p.SagaLevel) * benefit
		wave.StrOffense = 1
		wave.EndRes = 1
		if(sweet_spot_hit)
			p.throwFollowUp(/obj/Skills/AutoHit/Reconquista_Triumph_Strike)

	verb/Triumph()
		set category = "Skills"
		usr.BeginHeldSkill(src)

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Soul_Edge
	name = "Heavenly Regalia: Chaos Armament"
	StrMult=1.3
	OffMult=1.3
	EndMult=1.3
	passives = list("DemonicDurability" = 3, "Instinct" = 4, "Momentum" = 2, "EnhancedSmell" = 1, "EnhancedHearing" = 1)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s chaotic treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their chaotic luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)
/obj/Skills/Buffs/NuStyle/SwordStyle //slightly weaker than t2. maybe make it scaling???
	Stained_Memories
		StyleActive="Stained Memories"
		passives = list("CallousedHands" = 0.1, "Shearing" = 2)
		StyleEnd=1.25
		StyleStr=1.25
		Finisher="/obj/Skills/Queue/Finisher/Rook_Splitter"
		adjust(mob/p)
			StyleStr = 1.05 + (0.05 * p.SagaLevel)
			StyleEnd = 1.05 + (0.05 * p.SagaLevel)
			passives["CallousedHands"] = 0.1 + (0.05* p.SagaLevel)
			passives["Shearing"] = 2+p.SagaLevel
		verb/Stained_Memories()
			set hidden=1
			adjust(usr)
			Trigger(usr)
/obj/Skills/Queue/Finisher
	Rook_Splitter
		DamageMult=8
		HitSparkIcon='Slash - Zan.dmi'
		HitSparkX=-32
		HitSparkY=-32
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Grim_Lord"
		HitMessage = "crushes the very world with the might of Soul Edge!"
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher
	Grim_Lord
		StrMult=1.3
		EndMult=1.3
		passives = list("DemonicDurability" = 1, "AngerAdaptiveForce" = 0.5, "CallousedHands" = 0.15)
