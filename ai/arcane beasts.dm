
var/ArcaneRealmZ = 0 //No arcane realm this wipe



//Combo replaces arcane bullet.
//High damage, but alerts opponent to react.



obj/Arcane/ArcaneFocal //These are used for Arcane Traverse. I will eventually add more interactions to them. Like, using a dimensional generator by one will cause it to link to the arcane.
	Grabbable=0
	Savable=1
	Destructable=0
	icon = 'Icons/Effects/SparkleArcane.dmi'
	alpha=25
	density=0
	invisibility=1
	var/list/signature_restricted = list()
	var/identifier
	New()
		..()
		name = pick("Arcane Focal","Arcane Anomaly","Magic Anomaly","Strange Anomaly","Sparkly Spot")
		identifier = rand(1000,9999)
		transform = matrix() * 2

obj/Skills/AutoHit/Arcane_Artillery

obj/Skills/Projectile/Arcane_Cluster
	name = "Arcane Cluster"
	Distance=50
	DamageMult=1
	AccMult=25
	Radius=0
	Charge=2
	Knockback=1
	Explode=1
	Radius=1
	Blasts=6
	Delay=2
	Cooldown=120
	Instinct=1
	Hover=10
	ZoneAttack=1
	ZoneAttackX=3
	ZoneAttackY=3
	FireFromSelf=0
	FireFromEnemy=1
	HomingCharge=1
	LosesHoming=3
	IconLock='Icons/Blasts/Blast13.dmi'
	Variation=12
	IconSize=2

obj/Skills/Projectile/Arcane_Burst
	Copyable=0
	IconLock='Icons/Blasts/Blast13.dmi'
	IconSize=1
	LockX=0
	LockY=0
	Trail='SparkleBlue.dmi'
	TrailDuration=1
	FadeOut=5
	TrailSize=1.3
	Blasts=25
	DamageMult=0.5
	AccMult=5
	RandomPath=1
	Instinct=2
	Deflectable=0
	Delay=0
	Charge=0.5
	Piercing=0
	Knockback=0
	Radius=2
	Hover=2
	ZoneAttack=1
	ZoneAttackX=3
	ZoneAttackY=3
	FireFromSelf=1
	FireFromEnemy=0
	ForRate=1
	EndRate=1
	Distance=20

obj/Skills/Projectile/Beams/Arcane_Bullet
	Copyable=0
	name = "Arcane Bullet"
	Area="Blast"
	Distance=15
	DamageMult=3
	AccMult=3
	Radius=1
	Speed=0
	Knockback=0
	Deflectable=0
	IconLock='ArcaneBullet.dmi'
	IconSize=1
	Trail='Trail - ArcaneBullet.dmi'
	TrailSize=1
	Cooldown=30
	EnergyCost=0.01
	Variation=4

obj/Skills/Projectile/Arcane_Blast
	Copyable=0
	name = "Arcane Blast"
	Distance=15
	DamageMult=0.5
	AccMult=6
	MultiShot=0
	EnergyCost=1

	Homing=1
	LosesHoming=2
	HomingDelay=3
	HomingCharge=6

	IconLock='Blast21.dmi'
	Cooldown=5
	Charge=1
	IconChargeOverhead=1
	IconSizeGrowTo=1
	Speed=1


obj/Skills/Projectile/Arcane_Landmine
	Copyable=0
	name = "Arcane Landmine"
	DamageMult=3
	Knockback=5
	Radius=1
	AccMult=50
	Deflectable=0
	Static=1
	Distance=100
	IconLock='Icons/Blasts/Blast13.dmi'
	LockX=0
	LockY=0
	FireFromSelf=1
	FireFromEnemy=0
	Cooldown=0
	Explode=2
	EnergyCost=0

obj/Skills/Projectile/Arcane_Spray
	name = "Arcane Spray"
	Copyable=0
	DamageMult=0.5
	AccMult=2
	MultiShot=0
	EnergyCost=1
	Homing=1
	LosesHoming=15
	IconLock='Icons/Blasts/Blast21.dmi'
	Cooldown=0
	Variation=8
	HomingCharge=0
	RandomPath=1
	Distance=30
	IconSize=0.5
	Speed=1




obj/Skills/Buffs/SlotlessBuffs/Autonomous/NymphBuff
	Copyable=0
	NeedsHealth=100
	passives = list("MovingCharge" = 1)
	MovingCharge=1
	TextColor="#adf0ff"
	Cooldown=1
	ActiveMessage="glows with wonderous, arcane energies."

obj/Skills/Buffs/SlotlessBuffs/ArcaneRejection
	Copyable=0
	name = "Arcane Rejection"
	MaimCost=1
	WoundCost=50
	ExplosiveFinish=4
	TimerLimit=1
	ActiveMessage="violently rejects crest implanted in their body. Their arcane energies react violently, destroying the crest inside of them in a violent explosion!"


//Player Skills


obj/Skills/Buffs/SlotlessBuffs/Arcane_Surge
	Copyable=0
	ManaStats=0.5
	TooLittleMana=25
	ManaThreshold=10
	ManaLeak=2
	Cooldown=5

	TextColor="#adf0ff"
	KenWave=1
	KenWaveIcon='SparkleBlue.dmi'

	FlashChange=1

	KenWaveSize=3
	KenWaveX=105
	KenWaveY=105

	ManaGlow=rgb(100,150,200)
	ManaGlowSize=4


	ActiveMessage="surges with arcane power!"
	OffMessage="seals their arcane surge..."

	Arcane_Gravitation //Mobility
		name = "Arcane Gravitation" //WIND RUNNERS
		SuperDash=1 //Compound Gravity.
		Skimming=1 //The lashings make these boiz fly.
		Pursuer=1 //Is mobile af
		passives = list("SuperDash" = 1, "Skimming" = 1, "Pursuer" = 1, "ManaStats" = 0.5)
		SpdMult=1.4
		DefMult=1.3
		OffMult=1.3
		verb/Arcane_Surge()
			set category="Skills"
			if(!usr.is_arcane_beast) return
			ManaGlow = usr.is_arcane_beast.aura_color
			if(usr.is_arcane_beast)
				if(usr.is_arcane_beast.Mastery>=3)
					passives = list("SuperDash" = 1, "Skimming" = 2, "Pursuer" = 1, "SoftStyle" = 0.5)
					Skimming=2
					SoftStyle=0.5 //Wear the opponent down
				if(usr.is_arcane_beast.Mastery>=4)
					passives = list("SuperDash" = 1, "Skimming" = 1, "Pursuer" = 1, "SoftStyle" = 0.5, "ManaStats" = 1)
					ManaStats=1
			src.Trigger(usr)

	Arcane_Transmutation // EXPLOOOSION
		name = "Arcane Transmutation"
		//Will also convert elemental status effects + poison into small trickles of energy. or not
		Siphon=2.5 //Transformation. Converts matter/particiles into energy.
		QuickCast=1
		passives = list("Siphon" = 2.5, "QuickCast" = 1)
		ForMult=1.4
		OffMult=1.3
		EndMult=1.3

		verb/Arcane_Surge()
			set category = "Skills"
			if(!usr.is_arcane_beast) return
			ManaGlow = usr.is_arcane_beast.aura_color
			if(usr.is_arcane_beast)
				if(usr.is_arcane_beast.Mastery>=3)
					passives = list("Siphon" = 2.5, "MovingCharge" = 1, "QuickCast" = 2, "ManaStats" = 0.5)
					MovingCharge=1
					QuickCast=2
				if(usr.is_arcane_beast.Mastery>=4)
					passives = list("Siphon" = 2.5, "MovingCharge" = 1, "QuickCast" = 2, "ManaStats" = 1)
					ManaStats=1
			src.Trigger(usr)

	Arcane_Empowerment
		name = "Arcane Empowerment"
		passives = list("PureReduction" = 1, "Juggernaut" = 1, "Hardening" = 2, "ManaStats" = 0.5, "SpiritHand" = 2)
		PureReduction=1
		Juggernaut=1
		Hardening=2

		StrMult=1.2
		ForMult=1.2
		EndMult=1.3
		OffMult=1.3
		verb/Arcane_Surge()
			set category = "Skills"
			if(!usr.is_arcane_beast) return
			ManaGlow = usr.is_arcane_beast.aura_color
			if(usr.is_arcane_beast)
				if(usr.is_arcane_beast.Mastery>=3)
					passives["PureReduction"] = 2
					passives["HardStyle"] = 0.5
					PureReduction=2
					HardStyle=0.5
				if(usr.is_arcane_beast.Mastery>=4)
					passives["ManaStats"] = 1
					ManaStats=1
			src.Trigger(usr)


obj/Skills/Buffs/SpecialBuffs/Bond_Keeper
	name = "Bond Keeper"
	Copyable=0
	PowerMult=1.5
	EnergyMult=1.5
	RegenMult=1.25
	RecovMult=1.25
	OverClock=0.2
	NeedsHealth=75
	FlashChange=1
	ActiveMessage="gives mind, body, heart, and soul to their bond!"
	OffMessage="diminshes their willpower..."
	verb/Bond_Keeper()
		set category="Skills"
		src.Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/Arcane_Burst //potential posebuff. not used atm, but may trigger off of the arcane beast burning the fuck out of their mana.
	name = "Arcane Burst"
	passives = list("Instinct" = 1, "Flow" = 1, "TechniqueMastery" = 10)
	Instinct=1
	Flow=1
	TechniqueMastery=10
	ManaThreshold = 100

obj/Skills/Buffs/SlotlessBuffs/Bond_Savior //Nymph power
	name = "Bond Savior"
	PowerMult=2
	FlashChange=1
	KenWave=1
	KenWaveSize=1
	KenWaveBlend=2
	KenWaveIcon='Trance.dmi'
	KenWaveX=25
	KenWaveY=25
	ActiveMessage="fulfills their commitment to the Bond Keeper, and stands beside them as an equal!"
	OffMessage="diminshes their power..."

obj/Skills/Buffs/SlotlessBuffs/
	Nympharum_Armament//t2
		name = "Nympharum Armament"
		Copyable=0
		MakesSword=1
		FlashDraw=1
		SwordName="Spirit Sword"
		SwordIcon='Icons/Buffs/nympharum sword.dmi'
		SwordX=-32
		SwordY=-32
		passives = list("SpiritSword" = 0.25, "SwordAscension" = 1, "MagicSword" = 1)
		MagicSword=1
		SwordUnbreakable=1 //SHARDBLADES CANNOT BE SHATTERED
		SwordAscension=1
		TextColor="#adf0ff"
		ActiveMessage="draws an arcane weapon from mist!"
		OffMessage="disperses their arcane weapon into mist!"
		verb/Transfigure_Nympharum_Armament()
			set category="Utility"
			var/Choice
			if(!usr.BuffOn(src))
				var/Lock=alert(usr, "Do you wish to alter the icon used?", "Weapon Icon", "No", "Yes")
				if(Lock=="Yes")
					src.SwordIcon=input(usr, "What icon will your Spirit Sword use?", "Spirit Sword Icon") as icon|null
					src.SwordX=input(usr, "Pixel X offset.", "Spirit Sword Icon") as num
					src.SwordY=input(usr, "Pixel Y offset.", "Spirit Sword Icon") as num

				Choice=input(usr, "What class of weapon do you want your Nympharum Armament to be?", "Transfigure Nympharum Armament") in list("Light", "Medium", "Heavy")
				switch(Choice)
					if("Light")
						src.SwordClass="Light"
					if("Medium")
						src.SwordClass="Medium"
					if("Heavy")
						src.SwordClass="Heavy"
				usr << "Spirit Sword class set as [Choice]!"
			else
				usr << "You can't set this while using Nympharum Armament."
		verb/Nympharum_Armament()
			set category="Skills"
			if(usr.is_arcane_beast)
				Mastery = usr.is_arcane_beast.Mastery
				passives["SwordAscension"] = min(2, (usr.AscensionsUnlocked * 0.5))
			else
				return
			src.Trigger(usr)

obj/Skills/AutoHit/Gravity_Lunge
	Copyable=0
	ManaCost=15
	NeedsSword=1
	Area="Circle"
	StrOffense=1
	EndDefense=1
	DamageMult=1
	GuardBreak=1
	ChargeTech=1
	Rounds=10
	DelayTime=0.5
	ChargeTime=0
	Instinct=2
	ChargeFlight=1
	Knockback=1
	WindUp=0.5
	Cooldown=160
	Size=1
	Rush=3
	ControlledRush=1
	Hurricane="/obj/Skills/Projectile/GravityTornado"
	HurricaneDelay=0.5
	WindUp=0.1
	WindupIcon=2
	ActiveMessage="compounds their gravity, twirling and swooping through the air in a whirlwind!"
	verb/Gravity_Lunge()
		set category="Skills"
		usr.Activate(src)

obj/Skills/Projectile/GravityTornado
	Copyable=0
	FlickBlast=0
	AttackReplace=1
	Distance=10
	DamageMult=0.25
	FadeOut=10
	Instinct=1
	Deflectable=0
	Radius=1
	ZoneAttack=1
	ZoneAttackX=0
	ZoneAttackY=0
	FireFromSelf=1
	FireFromEnemy=0
	Knockback=0
	Piercing=1
	Launcher=1
	IconLock='Icons/Effects/TornadoCancer.dmi'
	IconSize=3
	LockX=-8
	LockY=-8



obj/Skills/Projectile/Arcane_Discharge
	Copyable=0
	ManaCost=5
	IconLock='Icons/Blasts/ArcaneDischarge.dmi'
	IconSize=1
	LockX=0
	LockY=0
	Trail='SparkleBlue.dmi'
	TrailDuration=1
	FadeOut=5
	TrailSize=1.3
	Blasts=7
	Homing=1
	HomingCharge=2
	LosesHoming=3
	DamageMult=1
	AccMult=2
	Instinct=2
	Deflectable=0
	Delay=1
	Charge=0.5
	Explode=1
	ExplodeIcon = 'Icons/Effects/Hit Effect Oath.dmi'
	Knockback=0
	Radius=1
	Hover=1
	ZoneAttack=1
	ZoneAttackX=1
	ZoneAttackY=1
	FireFromSelf=1
	FireFromEnemy=0
	ForRate=1
	EndRate=1
	Distance=10
	Cooldown=60
	ActiveMessage="discharges arcane energies in a vibrant wave!"
	verb/Discharge()
		set category = "Skills"
		usr.UseProjectile(src)


obj/Skills/AutoHit/Lesser_Division
	Copyable=0
	ManaCost=10
	Area="Around Target"
	Distance=15
	DistanceAround=3
	Divide=1
	WindUp=0
	Slow=1
	DamageMult=10
	WindUp=1
	SpecialAttack=1
	StrOffense=0
	ForOffense=1
	EndDefense=1
	GuardBreak=1
	Knockback=5
	Instinct=2
	TurfErupt=1
	TurfEruptOffset=6
	HitSparkIcon='Icons/Effects/Arcane Division.dmi'
	HitSparkX=-16
	HitSparkY=-16
	HitSparkSize=1
	HitSparkDispersion=16
	TurfStrike=3
	Earthshaking=5
	Cooldown=300
	WindupMessage="focuses their arcane power..."
	WindupMessage="performs division, causing particles in the area infront of them to combust!"
	verb/Lesser_Division()
		set category="Skills"
		usr.Activate(src)


obj/Skills/Queue/Echoing_Blows
	Copyable=0
	ManaCost=5
	DamageMult=1
	AccuracyMult=3
	Warp=3
	KBAdd=1
	KBMult=0.00001
	Combo=3
	Rapid=0
	Instinct=1
	HitSparkIcon='Hit Effect Pearl.dmi'
	HitSparkSize=2
	HitSparkX=-32
	HitSparkY=-32
	InstantStrikes=2
	InstantStrikesDelay=1
	Duration=5
	Crippling=1
	Cooldown=60
	TextColor="#adf0ff"
	ActiveMessage="surges their arcane energies, their fists striking with echoing might!"
	verb/Echoing_Blows()
		set category="Skills"
		usr.SetQueue(src)

obj/Skills/AutoHit/Overpower
	Copyable=0
	ManaCost=10
	Area="Wide Wave"
	Distance=5
	StrOffense=1
	EndDefense=1
	DamageMult=10
	Knockback=15
	Cooldown=300
	GuardBreak=1
	SpecialAttack=1
	WindUp=0.5
	TurfErupt=1
	Stunner=3
	Crippling=5
	Earthshaking=10
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	WindupMessage="focuses their arcane power..."
	ActiveMessage="roars furiously, erupting the area infront of them with a surge of arcane power!"
	verb/Overpower()
		set category="Skills"
		usr.Activate(src)

//T3 Super Moves

obj/Skills/Queue/Oath_Bringer
	ManaCost=20
	DamageMult=1
	AccuracyMult=20
	Warp=5
	KBAdd=0
	KBMult=0.00001
	Quaking=5
	Instinct=4

	PushOut=3
	PushOutWaves=2
	PushOutIcon='KenShockwaveDivine.dmi'

	HitSparkIcon='Icons/Effects/Hit Effect Oath.dmi'
	HitSparkX=-16
	HitSparkY=-16
	HitSparkSize=1
	Duration=10

	Cooldown=900

	ActiveMessage="brings forth the full power of their all their oaths!"
	verb/Oath_Bringer() //Verb will be removed later.
		set category = "Skills"
		Activate(usr)

	proc/Activate(mob/m)
		if(!m) return
		usr=m
		if(locate(/obj/Skills/Buffs/SlotlessBuffs/Arcane_Surge/Arcane_Gravitation) in m)
			HitStep=/obj/Skills/Queue/Arcane_Whirlwind_Strike
			Projectile="/obj/Skills/Projectile/Arcane_Whirlwind"
			Launcher=1
			DamageMult=4
		else if(locate(/obj/Skills/Buffs/SlotlessBuffs/Arcane_Surge/Arcane_Transmutation) in m)
			for(var/turf/t in Turf_Circle(m, 10))
				sleep(-1)
				TurfShift('Icons/Turfs/GalSpace.dmi', t, 50, m, MOB_LAYER-0.5, state="[rand(1,25)]")
			KenShockwave(m, icon='KenShockwaveDivine.dmi', Size=6, Blend=2, Time=15)
			HitStep=null
			Projectile="/obj/Skills/Projectile/Arcane_Singularity"
			Launcher=1
			DamageMult=2
		else if(locate(/obj/Skills/Buffs/SlotlessBuffs/Arcane_Surge/Arcane_Empowerment) in m)
			Projectile=null
			HitStep=/obj/Skills/Queue/Arcane_Fist
			Launcher=0
			DamageMult=4
		m.SetQueue(src)

obj/Skills/Projectile/Arcane_Whirlwind
	name = "Arcane Whirlwind"
	Distance=50
	DamageMult=0.05
	MultiHit=100
	Radius=4
	AccMult=50
	Deflectable=0
	Static=1
	Launcher=1
	AccMult=25
	Radius=6
	Cooldown=1
	Instinct=4
	FireFromSelf=1
	FireFromEnemy=0
	IconLock='Icons/Effects/Tornado.dmi'
	LockX=-8
	LockY=-8
	IconSize=8
	Striking=1

obj/Skills/Queue/Arcane_Whirlwind_Strike
	DamageMult=2
	AccuracyMult=1.5
	HitStep=/obj/Skills/Queue/Arcane_Whirlwind_Strike
	Duration=10
	Warp=2
	EnergyCost=5
	KBAdd=0
	KBMult=0.00001
	ManaCost=15
	Instinct=2

	HitSparkIcon='Icons/Effects/Hit Effect Oath.dmi'
	HitSparkX=-16
	HitSparkY=-16
	HitSparkSize=1

obj/Skills/Projectile/Arcane_Singularity
	name = "Arcane Singularity"
	Distance=50
	DamageMult=0.1
	MultiHit=50
	Radius=4
	AccMult=50
	Deflectable=0
	Static=1
	Striking=1
	Launcher=1
	AccMult=25
	Radius=6
	Cooldown=1
	Instinct=4
	FireFromSelf=1
	FireFromEnemy=0
	IconLock='Icons/Blasts/Singularity.dmi'
	LockX = -64
	LockY = -64
	IconSize=2
	Striking=1
	Cluster=new/obj/Skills/Projectile/Arcane_Micro_Singularity
	ClusterCount=5
	Devour = 1 //Singularities Eat Shit

obj/Skills/Projectile/Arcane_Micro_Singularity
	name = "Arcane Singularity"
	Distance=100
	DamageMult=1.5
	MultiHit=4
	Instinct=4
	AccMult=25
	Explode=1
	Delay=10
	ExplodeIcon = 'Icons/Effects/Hit Effect Oath.dmi'
	FadeOut=5
	Knockback=5
	Radius=1
	Instinct=4
	RandomPath=1
	HomingCharge=1
	HyperHoming=1
	IconLock='Icons/Blasts/Singularity.dmi'
	LockX = -64
	LockY = -64
	IconSize=0.5
	Trail = 'Icons/Turfs/GalSpace.dmi'
	TrailSize=2
	TurfShiftEnd = 'Icons/Turfs/GalSpace.dmi'
	TurfShiftEndSize = 3
	Striking=1
	Devour = 1 //Mini Singularities Also Eat Shit


obj/Skills/Queue/Arcane_Fist
	DamageMult=3
	AccuracyMult=2
	HitStep=/obj/Skills/Queue/Arcane_Fist
	Duration=10
	Warp=2
	EnergyCost=5
	KBAdd=0
	KBMult=0.00001
	ManaCost=15
	Instinct=2
	Projectile = "/obj/Skills/Projectile/Arcane_Fist_Discharge"

	PushOut=2
	PushOutWaves=1
	PushOutIcon='KenShockwaveDivine.dmi'
	HitSparkIcon='Icons/Effects/Hit Effect Oath.dmi'
	HitSparkX=-16
	HitSparkY=-16
	HitSparkSize=1

obj/Skills/Projectile/Arcane_Fist_Discharge
	Copyable=0
	IconLock='Icons/Blasts/ArcaneDischarge.dmi'
	IconSize=2
	LockX=0
	LockY=0
	Trail='SparkleBlue.dmi'
	TrailDuration=1
	FadeOut=4
	Speed=1
	TrailSize=2
	DamageMult=1
	MultiHit=4
	Knockback=1
	AccMult=10
	Instinct=2
	Deflectable=0
	Striking=1
	Radius=1
	ForRate=0
	StrRate=1
	EndRate=1
	Distance=4

obj/Skills/Projectile/Heavy_Discharge
	Copyable=0
	IconLock='Icons/Blasts/ArcaneDischarge.dmi'
	IconSize=2
	LockX=0
	LockY=0
	Trail='SparkleBlue.dmi'
	TrailDuration=1
	FadeOut=4
	Speed=1
	TrailSize=2
	DamageMult=0.5
	MultiHit=4
	Knockback=1
	AccMult=10
	Instinct=2
	Deflectable=0
	Striking=1
	Radius=1
	ForRate=1
	StrRate=1
	EndRate=1
	Distance=4

obj/Skills/Projectile/Arcane_Explosion

obj/Skills/Arcane_Regrowth
	Copyable=0
	var/last_click
	Cooldown=160
	verb/Regrowth()
		set category="Skills"
		if(!usr.is_arcane_beast)
			usr << "Due to a lack of a bond, you no longer have access to Regrowth."
			del(src)

		if(world.realtime > last_click + 20)
			last_click = world.realtime
			usr << "Utilizing Regrowth is a costly process for an Arcane Beast. Use it again to initiate within the next 2 seconds as confirmation."
		else
			usr.SkillX("Regrowth",src)



mob/var/tmp/obj/Skills/Companion/arcane_follower/is_arcane_beast
obj/Skills/Companion/arcane_follower
	name = "Nympharum"
	companion_icon=null
	companion_name = "Nympharum"
	Mastery=1

	var
		text_color = rgb(150,150,150)
		message_support_fire = "I have your back /owner!"
		message_reverse_dash = "As we practiced /owner! Disengage Manuever!"
		message_dragon_dash = "We'll strike together /owner!"
		message_mana_heal = "Let me help you /owner!"

		dash_effect = 'Icons/Effects/SparkleBlue.dmi'
		enable_walk_effect = 1
		aura_color = rgb(50,50,255)

		next_summon_time = 0
		bond_damage = 0 //does nothing yet.

		//mastery related vars
		bond_element

		mana_glow //Activates with surges.

		disallow_combat=0 //Can toggle to make a nymph unable to fight.

		StaffClass //useless
		MasterySet = 0

		bondkeeper_icon = 'Icons/Characters/Special/NymphSavior.dmi'
		bondkeeper_icon_x = 0
		bondkeeper_icon_y = 0

		savior_charge //Builds up while posing
		list/savior_charges = list()

	CustomizeCompanion()
		set category="Companion"
		set name = "Customize: Companion"

		var/list/options = list("Set Nympharum Icon","Set Nympharum Name","Set Aura Color","Set IC Color","Set Walk Effect Icon","Combat Messages")
		if(locate(/obj/Skills/Buffs/SpecialBuffs/Bond_Keeper) in usr)
			options += "Bond Keeper Icon"

		options += "Cancel"
		switch(input("What would you like to do?") in options)
			if("Set Nympharum Icon")
				var/icon/i = input("What would you like to set your companion's icon to?") as icon|null
				if(i)
					companion_icon = i
					usr << "Companion Icon Set"
			if("Set Nympharum Name")
				var new_name = input("What would you like to set your companion's name to?","Companion Name",companion_name) as text|null
				if(new_name)
					companion_name = new_name
			if("Set Aura Color")
				var/new_color = input("What color?") as color | null
				if(new_color)
					aura_color = new_color
					usr << "You've set your Companion's aura color to [text_color]"
			if("Set IC Color")
				var/new_color = input("What color?") as color | null
				if(new_color)
					text_color = new_color
					usr << "You've set your Companion's text color to [text_color]"
			if("Set Walk Effect Icon")
				var/icon/i = input("What icon would you like to set it to?") as icon | null
				if(i)
					dash_effect = i
				else
					switch(input("Would you like to reset your dash effect icon?") in list("Yes","No"))
						if("Yes") dash_effect = initial(dash_effect)

			if("Combat Messages")
				var category = input("Which category would you like to add/remove from?") in list("Support Fire","Reverse Dash","Dragon Dash") | null
				if(category)
					switch(category)
						if("Support Fire") message_support_fire = input("Support Fire Message","Support Fire Message", message_support_fire) as text
						if("Reverse Dash") message_reverse_dash = input("Reverse Dash Message","Reverse Dash Message", message_reverse_dash) as text
						if("Dragon Dash") message_dragon_dash = input("Dragon Dash Message","Dragon Dash Message", message_dragon_dash) as text
			if("Bond Keeper Icon")
				var/new_icon = input("What would you like to set your Nympharum's Bond Keeper icon to?") as icon|null
				if(new_icon)
					bondkeeper_icon = new_icon
					bondkeeper_icon_x = input("X offset?") as num
					bondkeeper_icon_y = input("Y offset?") as num

	verb/Companion_Say(var/message as text)
		set category = "Companion"
		set name = "Say Nympharum"
		if(message)
			for(var/mob/Player/AI/Nympharum/a in usr.ai_followers)
				a.AISay(message)
				return

	verb/Companion_Roleplay()
		set category = "Companion"
		set name = "Emote Nympharum"
		for(var/mob/Player/AI/Nympharum/a in usr.ai_followers)
			var/image/em=new('Emoting.dmi')
			em.appearance_flags=66
			em.layer=EFFECTS_LAYER
			a.overlays+=em
			var/T=input("Emotes here!")as message|null
			if(T==null)
				a.overlays-=em
				return
			for(var/mob/Players/E in (hearers(15,a) |  hearers(15,usr)))
				E << output("<font color=[text_color]>*[a.name]<font color=yellow>[E.Controlz(usr)] [html_decode(T)]*", "output")
				E << output("<font color=[text_color]>*[a.name]<font color=yellow>[E.Controlz(usr)] [html_decode(T)]*", "icchat")
				if(E.BeingObserved.len>0)
					for(var/mob/m in E.BeingObserved)
						m<<output("<b>(OBSERVE)</b><font color=[text_color]>*[a][E.Controlz(usr)]  [html_decode(T)]*", "icchat")
						m<<output("<b>(OBSERVE)</b><font color=[text_color]>*[a][E.Controlz(usr)]  [html_decode(T)]*", "output")
				if(E==usr)
					spawn()Log(E.ChatLog(),"<font color=#CC3300>*[a]([usr.key]) [html_decode(T)]*")
//					spawn()TempLog(E.ChatLog(),"<font color=#CC3300>*[a]([usr.key]) [html_decode(T)]*")
				else
					Log(E.ChatLog(),"<font color=red>*[usr]([usr.key]) [html_decode(T)]*")
				for(var/obj/Items/Enchantment/Arcane_Mask/EyeCheck in E)
					if(EyeCheck.suffix)
						for(var/mob/Players/OrbCheck in world)
							for(var/obj/Items/Enchantment/ArcanicOrb/FinalCheck in OrbCheck)
								if(EyeCheck.LinkTag in FinalCheck.LinkedMasks)
									if(FinalCheck.Active)
										OrbCheck << output("[FinalCheck](viewing [E]):<font color=[text_color]>*[a.name]<font color=yellow> [html_decode(T)]*", "output")
										OrbCheck << output("[FinalCheck](viewing [E]):<font color=[text_color]>*[a.name]<font color=yellow> [html_decode(T)]*", "icchat") //Outputs to the Orb owner the emote.
			a.Say_Spark()
			if(a.AFKTimer==0)
				a.overlays-=usr.AFKIcon

			a.overlays-=em
	Companion_Summon()
		set src in usr
		if(Using) return
		Using=1


		if(bond_damage >= 3)
			usr << "You have betrayed the bond too many times. It abruptly severs, ripping your body apart in the process and causing extreme irreversable damage!"
			usr.AddHealthCut(0.5)
			usr.AddEnergyCut(0.5)
			usr.AddManaCut(0.5)
			usr.AddStrCut(0.5)
			usr.AddEndCut(0.5)
			usr.AddSpdCut(0.5)
			usr.AddForCut(0.5)
			usr.AddOffCut(0.5)
			usr.AddDefCut(0.5)
			usr.AddRecovCut(0.5)
			usr.is_arcane_beast = 0
			for(var/mob/Player/AI/Nympharum/aa in usr.ai_followers)
				aa.EndLife(1)
			del src



		var has_f_out
		for(var/mob/Player/AI/Nympharum/a in usr.ai_followers)
			animate(a, alpha=0, time=10)
			usr.ai_followers-=a
			spawn(10)
				del(a)
			has_f_out=1
		if(has_f_out)
			Using=0
			return

		if(!(world.realtime) > next_summon_time)
			usr << "The strain on your bond prevents you from summoning [companion_name] right now. You will need to wait until you're less tired."
			Using=0
			return

		if(!companion_icon) companion_icon = pick('Icons/NPCS/Arcane/SpriteB.dmi','Icons/NPCS/Arcane/SpriteC.dmi','Icons/NPCS/Arcane/SpriteG.dmi','Icons/NPCS/Arcane/SpriteR.dmi','Icons/NPCS/Arcane/SpriteY.dmi')
		if(!companion_name) companion_name = "Nympharum"

		if(Mastery != MasterySet)
			if(bond_damage)
				usr << "The damage to your bond prevents it from progressing. You must find a way to heal it."
			else
				MasterySet = Mastery
				switch(Mastery)
					if(1) //T1
						usr << "You've developed a basic bond with a Nympharum, changing your body permanently. You're ascribed to the Will of the Arcane Realm's; to preserve mind, body and spirit, to maintain the purity of magic."
						usr.Spiritual=1 //All Arcane Beasts are Spiritual
						usr.passive_handler.Increase("ManaCapMult", 0.25)
						usr.contents += new/obj/Skills/Buffs/SlotlessBuffs/Nympharum_Armament
						usr << "Your Nympharum Companion is capable of manifesting its body into a powerful weapon to aid in channeling magics and battle!"
						usr.contents += new/obj/Skills/Arcane_Regrowth
						usr << "You've learned how to perform Regrowth, which allows Arcane Beasts to recover from deadly wounds and even limb loss! Defeating the necessity of medical science completely. Regrowth is extremely costly to use, making it unsuitable for combat."

					if(2) //T2
						usr << "The growth of your bond focuses itself toward your own power. To further yourself, your [companion_name] introduces you to the beginning steps of becoming one with the vast arcane."
						usr << "In doing this, you begin developing your first Arcane Surge. To manipulate forces, to reform forces, or to become a force yourself."
						//Obtains Regrowth, which undoes maims and wounds at the cost of magic capacity.
						var/which
						while(!which)
							switch(input("Which Surge would you like to develop?") in list("Gravitation","Transmutation","Empowerment"))
								if("Gravitation")
									switch(alert("Gravitation allows one to manipulate forces of gravity, primarily one's own. Those who practice the Gravitation surge make the skies their own, striking their opponents with swiftness and grace.",,"Accept","Decline"))
										if("Accept")
											which="Gravitation"
								if("Transmutation")
									switch(alert("Transmutation is oriented toward dividing and reworkng matter and force. Those who practice Transmutation are individuals who are in control, bending essence to their will.",,"Accept","Decline"))
										if("Accept")
											which="Transmutation"
								if("Empowerment")
									switch(alert("Empowerment is simplistic in nature, to infuse oneself with power to better their feats. Those who practice Empowerment have chosen a simplistic path, yet one that is just as effective as the other two.",,"Accept","Decline"))
										if("Accept")
											which="Empowerment"

						switch(which)
							if("Gravitation")
								usr.contents += new/obj/Skills/Buffs/SlotlessBuffs/Arcane_Surge/Arcane_Gravitation
								usr.contents += new/obj/Skills/AutoHit/Gravity_Lunge
								usr.contents += new/obj/Skills/Telekinesis
							if("Transmutation")
								usr.contents += new/obj/Skills/Buffs/SlotlessBuffs/Arcane_Surge/Arcane_Transmutation
								usr.contents += new/obj/Skills/AutoHit/Lesser_Division
								usr.contents += new/obj/Skills/Projectile/Arcane_Discharge
								usr.contents += new/obj/Skills/Utility/Make_Equipment
							if("Empowerment")
								usr.contents += new/obj/Skills/Buffs/SlotlessBuffs/Arcane_Surge/Arcane_Empowerment
								usr.contents += new/obj/Skills/Queue/Echoing_Blows
								usr.contents += new/obj/Skills/AutoHit/Overpower

						usr.passive_handler.Increase("ManaCapMult", 0.25)
					if(3) //T3
						usr << "Your bond with your [src.companion_name] deepens. The fulfillment of your oath and bond empowers you yourself, while you obtain mastery over the power of the Arcane Surge."
						usr.passive_handler.Increase("ManaCapMult", 0.5)
					/*	var/which
						if(locate(/obj/Skills/Buffs/SlotlessBuffs/Arcane_Surge/Arcane_Gravitation) in usr) which = "Gravitation"
						else if(locate(/obj/Skills/Buffs/SlotlessBuffs/Arcane_Surge/Arcane_Transmutation) in usr) which = "Transmutation"
						else if(locate(/obj/Skills/Buffs/SlotlessBuffs/Arcane_Surge/Arcane_Empowerment) in usr) which = "Empowerment"
						*/
						usr << "Your bond with [src.companion_name] shines brilliant. [src.companion_name] names you a Bond Keeper."
						usr.contents += new/obj/Skills/Buffs/SpecialBuffs/Bond_Keeper
						usr << "When the time comes, [src.companion_name] will stand as your equal and your power will unify."

					if(4) //T4 Powered
						usr << "Your bond with your [src.companion_name] deepens."
						usr.passive_handler.Increase("ManaCapMult", 1)
		usr.is_arcane_beast=src




		for(var/x = 1 to ai_count)

			var/mob/Player/AI/Nympharum/a = new
			a.alpha=0
			a.loc = locate(usr.x,usr.y,usr.z)
			animate(a, alpha=255, time=10)
			a.ai_owner = usr
			a.ai_follow=1
			a.ai_hostility=0
			a.icon = companion_icon
			a.name = companion_name



			a.StrMod = 1
			a.ForMod = 3 + Mastery/2
			a.EndMod = 1
			a.SpdMod = 5
			a.OffMod = 3 + Mastery/2
			a.DefMod = 3 + Mastery/2
			a.RecovMod = 2 + Mastery
			a.Intimidation = 10 + (Mastery*20)
			a.Timeless = 1
			a.ai_spammer = 10
			a.Potential = usr.Potential + 10
			a.Text_Color = text_color
			a.nymph_mastery=Mastery
			usr.ai_followers +=a
			a.ai_alliances = list()
			a.ai_alliances += usr.ckey
			a.message_support_fire = message_support_fire
			a.message_reverse_dash = message_reverse_dash
			a.message_dragon_dash = message_dragon_dash
			a.message_mana_heal = message_mana_heal
			a.contents += new/obj/Skills/Projectile/Beams/Arcane_Bullet
			a.contents += new/obj/Skills/Projectile/Arcane_Cluster
			a.contents += new/obj/Skills/Projectile/Arcane_Blast
			a.contents += new/obj/Skills/Projectile/Arcane_Landmine
			a.contents += new/obj/Skills/Projectile/Arcane_Spray
			a.contents += new/obj/Skills/Projectile/Arcane_Burst
			a.contents += new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/NymphBuff
			a.contents += new/obj/Skills/Buffs/SlotlessBuffs/Bond_Savior

			a.next_mana_heal = world.time + 100
			a.density = 0
			for(var/index in companion_techniques)
				var/path=text2path("[index]")
				var/obj/Skills/o =new path
				if(!locate(o, a))
					a.contents+=o
			a.AIGain()

			a.filters += filter(type="drop_shadow",x=0,y=0,\
				size=6,offset=1,color=aura_color)
			a.glow_filter = a.filters[a.filters.len]

			animate(a.glow_filter, offset=0, size=10, time=30, loop=-1)

		Using=0

		var/obj/Items/Enchantment/Magic_Crest/mc = usr.EquippedCrest()
		if(mc)
			var/obj/Skills/Buffs/SlotlessBuffs/ArcaneRejection/a = new
			contents += a
			a.Trigger(usr)
			bond_damage++
			for(var/obj/Skills/s in usr.contents)
				if(s.MagicNeeded&&s.ManaCost)
					if(s.CrestGranted)
						del s
			del mc
			spawn(10)
				del a
			for(var/mob/Player/AI/Nympharum/aa in usr.ai_followers)
				var/message = "screams out in raw agony as their and [usr]'s bond is damaged!"
				for(var/mob/Players/E in (hearers(15,aa) |  hearers(15,usr)))
					E << output("<font color=[text_color]>*[aa.name]<font color=yellow>[message]*", "output")
					E << output("<font color=[text_color]>*[aa.name]<font color=yellow>[message]*", "icchat")



	//Overrides


mob/Player/AI/Nympharum
	var
		nymph_mastery
		next_mana_heal

	var/list
		message_support_fire = list("Let me help you /owner!","I got your back /owner!")
		message_reverse_dash = list("As we practiced /owner!")
		message_dragon_dash = list("We'll strike together /owner!")
		message_mana_heal = list("Let me help you /owner!")

	proc/NymphCry(var/message, var/yell)
		message = replacetext(message, "/owner","[ai_owner]")
		message = replacetext(message, "/target","[ai_owner.Target]")
		if(yell)
			AIYell(message)
		else
			AISay(message)

	var/step_no = 0
	var/prev_location

	var/glow_filter

	var/owner_prev_loc

	var/bond_savior
	var/savior_charge //Builds up while posing
	var/list/charge_visuals = list()
	proc/BuildSaviorCharge()
		var/obj/o = new
		o.icon = 'Icons/Effects/Arcane Heal.dmi'
		ai_owner.vis_contents += o
		flick("mana",o)
		spawn(13)
			ai_owner.vis_contents -= o
		if(100 >= ai_owner.ManaAmount) //have to burn hard to accumulate charges.
			savior_charge = min(3, savior_charge++) // Savior Charges don't do anything right now but they might be used to trigger the slotless buff.

	Update()
		set waitfor=0
		if(!ai_owner || !ai_owner.is_arcane_beast)
			EndLife(0)
			return
		if(src.Health<=0 || src.KO)
			if(!src.KO) Unconscious(null,"?!?!")

		bond_savior=0//Retick it every tick. This changes several ways the AI loop is handled and we shouldn't repeatedly call CheckSlotless(). We just have to do it once.
		if(ai_owner.CheckSpecial("Bond Keeper"))
			bond_savior=1
			if(!CheckSlotless("Bond Savior"))
				for(var/obj/Skills/Buffs/SlotlessBuffs/Bond_Savior/b in src)
					b.Trigger(src)

				animate(src, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))

				icon = ai_owner.is_arcane_beast.bondkeeper_icon
				pixel_x = ai_owner.is_arcane_beast.bondkeeper_icon_x
				pixel_y = ai_owner.is_arcane_beast.bondkeeper_icon_y

				animate(src, color = null, time=20)

				for(var/obj/Skills/Projectile/p in src)
					switch(p.name)
						if("Arcane Blast")
							p.DamageMult=1
							p.AccMult=10
							p.Instinct=1
							p.HomingCharge=8
							p.Cooldown=4
							p.IconLock = 'Icons/Blasts/Blast4.dmi'
						if("Arcane Spray")
							p.DamageMult=1
							p.LosesHoming=30
							p.AccMult=5
							p.IconSize=1
				ai_spammer = 20
				passive_handler.Set("TechniqueMastery", 20)

		else //Toggle Off
			if(CheckSlotless("Bond Savior"))
				for(var/obj/Skills/Buffs/SlotlessBuffs/Bond_Savior/b in src)
					b.Trigger(src)

				pixel_x = 0
				pixel_y = 0
				icon = ai_owner.is_arcane_beast.companion_icon
				for(var/obj/Skills/Projectile/p in src)
					if(p.name in list("Arcane Blast", "Arcane Spray"))
						var/newtype = new p.type
						del p
						contents += newtype

				ai_spammer = 10
				// TechniqueMastery = 1

		if(src.Health != 100 || src.Energy != 100 || src.ManaAmount != 100)
			if(world.time >= ai_next_gainloop)
				AIGain()
				ai_next_gainloop = world.time + 10
		else
			if(world.time >= ai_next_gainloop)
				AIGain()
				ai_next_gainloop = world.time + 100

		if(play_action)
			play_action.Update(src)
			return

		if(src.KO)
			if(src.KOTimer > 2) KOTimer=2
			return
		if(ai_stall)
			ai_stall--
			return
		var/ai_state_switch

		if(ai_owner.is_arcane_beast.enable_walk_effect && src.loc != src.prev_location)
			prev_location = loc
			step_no++
			if(step_no >= 2)
				step_no = 0
				var/image/i = image(ai_owner.is_arcane_beast.dash_effect, loc=src.loc)
				i.alpha = 200
				viewers(src) << i
				animate(i, alpha=0, time=10)
				spawn(10) del i

		if(ai_owner)
			if(ai_owner.is_arcane_beast.disallow_combat)
				if(ai_state =="combat")
					ai_state = "Idle"

			if(ai_owner.PureRPMode || ai_owner.KO)
				ai_state_switch = ai_state
				ai_state = "Idle"
			else
				if(ai_owner.loc != owner_prev_loc)
					if(ai_owner.CheckSlotless("Arcane Transmutation"))
						if(owner_prev_loc != ai_owner.loc)
							owner_prev_loc = ai_owner.loc
							var/image/i = image(ai_owner.is_arcane_beast.dash_effect, loc=ai_owner.loc)
							i.alpha = 200
							viewers(ai_owner) << i
							animate(i, alpha=0, time=10)
							spawn(10) del i

			if(get_dist(src, ai_owner) >= 12)
				loc=ai_owner.loc
		density = 0
		switch(ai_state)
			if("Idle")
				//If the Nympharum is told to hold position.
				if(return_position || (hold_position && get_dist(src, hold_position <= max_hold_distance)))
					if(hold_position) return_position = null

					if(!(next_move - world.time >= world.tick_lag / 10))

						ai_prev_position = loc
						step_to(src, (hold_position ? hold_position : return_position), max_hold_distance)
						var delay = MovementSpeed()
						next_move = world.time + delay
						glide_size = 32 / delay * world.tick_lag
						if(return_position && get_dist(src, return_position) <=3)
							return return_position = null
				else
					//Otherwise, stay with the player owner.
					ai_trapped_check = 0
					if(ai_follow && ai_owner && ai_owner.icon_state != "Meditate")
						if(icon_state == "Meditate")
							icon_state = ""
						if(!ai_owner)
							EndLife(0)
							return

						if(!(next_move - world.time >= world.tick_lag / 10))
							src.density=0
							if(ai_owner.z != src.z)
								loc = locate(ai_owner.x, ai_owner.y,ai_owner.z)
							var delay = ai_owner.MovementSpeed()/1.5
							next_move = world.time + delay
							glide_size = 32 / delay * world.tick_lag
							if(get_dist(src, src.ai_owner)>=10)
								step_to(src, src.ai_owner, 2)
								next_move = world.time+2
							if(bond_savior) //When bond savior is active. The Nympharum does not stand behind the player. It stands beside them!
								var/turf/clockwise = get_step(ai_owner, turn(ai_owner.dir, 90))
								if(!clockwise || clockwise.density) clockwise = ai_owner

								var/turf/counter_clockwise = get_step(ai_owner, turn(ai_owner.dir, -90))
								if(!counter_clockwise || counter_clockwise.density) counter_clockwise = ai_owner

								if(src.loc != clockwise && src.loc != counter_clockwise)
									if(get_dist(src, clockwise) <= get_dist(src, counter_clockwise))
										step_to(src, clockwise, 0)
									else
										step_to(src, counter_clockwise, 0)
							else
								step_to(src, src.ai_owner, 1)
							if(loc == ai_owner.loc) step_away(src, src.ai_owner)
							if(get_dist(src, ai_owner) <= 1) dir = ai_owner.dir

					else if(Health != 100 || (ai_owner && ai_owner.icon_state =="Meditate"))
						icon_state = "Meditate"
						if(ai_stall == 0)
							ai_stall = 10
					else if(ai_wander)
						ai_state = "wander"

			if("combat")
				if(world.time < ai_delayed) return
				if(Launched || Stunned || icon_state=="KB")
					return
				if(icon_state == "Meditate")
					icon_state = ""

				SetTarget(ai_owner.Target) //Nymphs target their owners target.

				if(Target && get_dist(src, Target) >= ai_vision * 2)
					RemoveTarget()

				if(Target && Target.KO)
					var prev_target = Target
					if(istype(Target, /mob/Player/AI))
						var/mob/Player/AI/a = Target
						if(a.ai_owner)
							RemoveTarget()
							if(prob(40))
								SetTarget(a.ai_owner)

							else for(var/mob/m in a.ai_followers)
								if(!m.KO)
									SetTarget(m)
									break
							if(!Target)
								SetTarget(a.ai_owner)

					if(Target == prev_target)
						RemoveTarget()
						ai_state = "Idle"

				if(Target && Beaming||BusterTech)
					dir = angle2cardinal(GetAngle(src, Target))

				//Movement
				if(!ai_movement_type)
					var/obj/Skills/use
					if(Target && prob(ai_accuracy))
						if(bond_savior && (world.time > ai_next_skill) && world.time >= (next_move))


							var/list/queueables = list()
							var/list/autohits = list()
							var/list/projectiles = list()

							for(var/obj/Skills/s in src)
								if(s.Using) continue
								if(istype(s, /obj/Skills/Projectile))
									var/obj/Skills/Projectile/pp = s
									if(!pp.Static)
										projectiles += s
								else if(istype(s, /obj/Skills/AutoHit))
									autohits += s
								else if(istype(s, /obj/Skills/Queue))
									queueables += s

							var timer_add
							if(world.time > ai_next_projectile && projectiles.len)
								if(get_dist(src, src.Target) >= 1)


									var/list/projectile_options = list()
									if(bond_savior)
										for(var/obj/Skills/Projectile/p in projectiles)
											if(p.name in list("Arcane Cluster"))
												projectile_options += p
									if( x==Target.x || y==Target.y )
										for(var/obj/Skills/Projectile/p in projectiles)
											if(p.Using) continue
											if(p.name in list("Arcane Bullet"))
												projectile_options += p
									if(!projectile_options.len)
										for(var/obj/Skills/Projectile/p in projectiles)
											if(p.Using) continue
											if(p.name in list("Arcane Blast"))
												projectile_options += p

									var/obj/Skills/Projectile/p
									if(projectile_options.len)
										p = pick(projectile_options)


									if(p)
										dir = angle2cardinal(GetAngle(src, Target))
										UseProjectile(p)
										switch(p.name)
											if("Arcane Bullet")
												if(prob(25)) NymphCry(message_support_fire,yell=1)
										use = p
										timer_add = 15 * use.Copyable
										if(!timer_add) timer_add = 15*5
										ai_next_projectile = (world.time+timer_add)/ai_spammer


							if(use) ai_next_skill = world.time + (use.Copyable ? use.Copyable * 5 : 50)


					if(world.time >= next_move && !use && Move_Requirements())
						density = 0
						if(target_position)
							step_to(src, src.target_position)
						else if(!hold_position)
							if(ai_owner.z != src.z)
								loc = locate(ai_owner.x, ai_owner.y,ai_owner.z)
							next_move = world.time + ai_owner.MovementSpeed()/1.3
							if(get_dist(src, src.ai_owner)>=10)
								step_to(src, src.ai_owner, 2)
								next_move = world.time+2

							if(bond_savior) //STAND BESIDE! Get the closest position to the players side and step to it.
								var/turf/clockwise = get_step(ai_owner, turn(ai_owner.dir, 90))
								if(clockwise && !clockwise.density) clockwise = get_step(clockwise, turn(ai_owner.dir, 90))
								else clockwise = ai_owner.loc

								var/turf/counter_clockwise = get_step(ai_owner, turn(ai_owner.dir, -90))
								if(counter_clockwise && !counter_clockwise.density) counter_clockwise = get_step(counter_clockwise, turn(ai_owner.dir, -90))
								else counter_clockwise = ai_owner.loc

								if(src.loc != clockwise && src.loc != counter_clockwise)
									if(get_dist(src, clockwise) <= get_dist(src, counter_clockwise))
										if(clockwise == ai_owner.loc)
											step_to(src, clockwise, 2)
										else
											step_to(src, clockwise, 0)
									else
										if(counter_clockwise == ai_owner.loc)
											step_to(src, counter_clockwise, 2)
										else
											step_to(src, counter_clockwise, 0)
							else
								step_to(src, src.ai_owner, 2)


		if(ai_state_switch) ai_state = ai_state_switch

	AIGain()
		set waitfor=0
		density=0
		Health = 100
		Energy = 100
		ManaAmount = 100
		TotalInjury = 0
		TotalInjury = 0
		density=0
		if(!ai_owner)
			EndLife()
			return
		else if(ai_owner.PureRPMode)
			return
		if(src.KO&&src.icon_state!="KO")
			src.icon_state="KO"

		if(world.time >= last_powercheck+100)
			AIAvailablePower()

		if(src.KOTimer)
			src.Conscious()
			src.KOTimer=0



	AIAvailablePower()
		set waitfor=0
		usr = src
		Power = ai_owner.Power
		Power = ai_owner.Power

		if(ai_owner.is_arcane_beast.bond_damage)
			Power *= 1 - (0.25 * ai_owner.is_arcane_beast.bond_damage)

		if(!bond_savior && ai_owner.CheckSlotless("Nympharum Armament"))
			Power = ai_owner.Power * 0.8

mob/Player/AI/Nympharum/Allow_Move(D)
	if(!Move_Requirements())
		return
	for(var/mob/P in range(1,usr)) if(P.Grab==usr)
		view(P)<<"[usr] breaks free of [P]!"
		P.Grab_Release()
	return 1