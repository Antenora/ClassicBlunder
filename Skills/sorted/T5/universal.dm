/obj/Skills/Projectile/Cataclysmic_Orb
	SkillCost=TIER_5_COST
	Copyable=6
	EnergyCost=20
	Speed = 2
	Distance=20
	Blasts=30
	Charge=1
	DamageMult=1
	ComboMaster=1
	Stunner= 3
	Instinct=1
	AccMult=2
	Homing=3
	Explode=1
	ZoneAttack=1
	ZoneAttackX=8
	ZoneAttackY=8
	IconLock='Plasma.dmi'
	LockX=0
	LockY=0
	Hover=10
	Variation=0
	Cooldown = 150
	ActiveMessage="Kicks up a Barrage of Orbs, creating an inescapable trap!"
	verb/Cataclysmic_Orb()
		set category="Skills"
		usr.UseProjectile(src)

/obj/Skills/Projectile/Desperado_Blaster
	SkillCost = TIER_5_COST
	Copyable = 6
	DamageMult = 6
	Distance = 20
	Explode = 1
	AccMult = 2
	Speed = 1
	Instinct = 1
	Cooldown = 75
	Variation = 0
	IconLock = 'Blast1.dmi'
	LockX = 0
	LockY = 0
	ActiveMessage = "unleashes a relentless barrage with the Desperado Blaster!"

	HeldSkill = TRUE
	InfiniteHold = TRUE
	FireRate = 1

	ignoreBetterAim = TRUE

	var/tmp/spin_dir = 0

	OnHeldStart(mob/p)
		spin_dir = p.dir
		p.dir_locked = TRUE
		OMsg(p, "<b>[p] [src.ActiveMessage]</b>")

	OnHeldTick(mob/p)
		var/left_dir  = turn(spin_dir, 45)
		var/right_dir = turn(spin_dir, -45)
		p.Blast(src, p, 0, 'Blast1.dmi', spin_dir)
		p.Blast(src, p, 0, 'Blast1.dmi', left_dir)
		p.Blast(src, p, 0, 'Blast1.dmi', right_dir)
		spin_dir = turn(spin_dir, 45)
		p.dir = spin_dir

	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		p.dir_locked = FALSE
		src.Cooldown(1, null, p)

	OnHeldFizzle(mob/p)
		p.dir_locked = FALSE

	verb/Desperado_Blaster()
		set category = "Skills"
		usr.BeginHeldSkill(src)

/obj/Skills/AutoHit/Kurohitsugi
	name = "Kurohitsugi"
	Area = "Around Target"
	Distance = 999
	DistanceAround=6
	DamageMult = 5
	AdaptRate = 1
	EndDefense = 0.75
	Copyable=6
	Cooldown = 360
	ComboMaster = 1
	GuardBreak = 1
	NoLock = 1
	NoAttackLock = 1
	IconTime = 4
//	TextColor="red"
	var/ChantNumber=0
	ActiveMessage = "starts chanting..."

	HeldSkill = TRUE
	InfiniteHold = TRUE
	FireRate = 15
	Earthshaking=15
	TurfShift='Gravity.dmi'
	TurfShiftLayer=MOB_LAYER+1
	TurfShiftDuration=0
	TurfShiftDurationSpawn=3
	TurfShiftDurationDespawn=7
	Shockwaves=6
	Shockwave=1
	PostShockwave=1
	ShockIcon='KenShockwavePurple.dmi'
	HitSparkIcon='KenShockwavePurple.dmi'
	HitSparkX=-96
	HitSparkY=-96
	HitSparkTurns=1
	HitSparkSize=1
	HitSparkDispersion=1
	TurfStrike=1

	var/tmp/spin_dir = 0

	OnHeldStart(mob/p)

	OnHeldTick(mob/p)
		if(ChantNumber==0)
			src.ActiveMessage="chants: <b>The oozing crest of corruption...</b>"
			src.DamageMult=15
		if(ChantNumber==1)
			src.ActiveMessage="chants: <b>The arrogant vessel of madness!</b>"
			src.DamageMult=15
		if(ChantNumber==2)
			src.ActiveMessage="chants: <b>Deny the seething urge to let things stun and flicker...</b>"
			src.DamageMult=17
		if(ChantNumber==3)
			src.ActiveMessage="chants: <b>Disrupt the sleep!</b>"
			src.DamageMult=23
		if(ChantNumber==4)
			src.ActiveMessage="chants: <b>The crawling princess of iron...</b>"
			src.DamageMult=30
		if(ChantNumber==5)
			src.ActiveMessage="chants: <b>...the eternally self-destructing doll of mud!</b>"
			src.DamageMult=35
		if(ChantNumber==6)
			src.ActiveMessage="chants: <b>UNITE!</b>"
			src.DamageMult=40
			p.ActionLocked=1
		if(ChantNumber==7)
			src.ActiveMessage="chants: <b>REPULSE!</b>"
			src.DamageMult=45
		if(ChantNumber==8)
			src.ActiveMessage="chants: <b>FILL THE EARTH, AND KNOW YOUR OWN POWERLESSNESS!</b>"
			src.DamageMult=60
		if(ChantNumber==9)
			src.ActiveMessage="chants: <b>HADO NUMBER 90...</b>"
			src.DamageMult=300
		if(ChantNumber<=9)
			OMsg(p, "<b><font color='[p.Text_Color]'>[p] [src.ActiveMessage]</b>")
		ChantNumber+=1


	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		src.ChantNumber=0
		src.ActiveMessage="chants: <b><font size = +3>KUROHITSUGI!</font size></b>"
		p.Activate(src, ignoreCuck=TRUE, ignoreAttackLock=TRUE)
		src.Cooldown(1, null, p)
		ActiveMessage = "starts chanting..."
		p.ActionLocked=0

	OnHeldFizzle(mob/p)
		src.ChantNumber=0
		ActiveMessage = "starts chanting..."
		p.ActionLocked=0

	verb/Kurohitsugi()
		set category = "Skills"
		usr.BeginHeldSkill(src)