obj/Items/Sword/Medium/Legendary/WeaponSoul/Sword_of_Glory//Caledfwlch
	name="Sword of Glory"
	icon='Caledfwlch.dmi'
	pixel_x=-31
	pixel_y=-30
	var/caledLight = TRUE
	var/caledFinal = FALSE
	Ascended = 6
	Destructable=0
	ShatterTier=0
	Element="Light"

// it gets excalibur

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Caledfwlch
	name = "Heavenly Regalia: The King"
	StrMult=1.5
	EndMult=1.5
	passives = list("CriticalBlock" = 0.25, "Juggernaut" = 0.5, "Reversal" = 0.5)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="resonates their royal treasures: Heavenly Regalia!"
	OffMessage="'s treasures loses their royal luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)

obj/Skills/Queue/Excalibur
	SagaSignature=1
	ActiveMessage="gathers holy energy within her blade..."
	HitMessage="unleashes the holy energy with a swing of her blade!"
	NeedsSword=1
	ABuffNeeded="Soul Resonance"
	PushOut=1
	PushOutWaves=1
	PushOutIcon='KenShockwaveGold.dmi'
	DamageMult=0.53
	AccuracyMult=1.5
	KBMult=1
	Duration=6
	Instinct=1
	Projectile="/obj/Skills/Projectile/ExcaliburProjectile"
	Delayer=0.25//add 1 damage mult every second that this is queued but hasnt been punched yet
	Warp=0
	Cooldown=8 // This is probably a 60 second c/d move on a 30 second c/d.
	EnergyCost=2
	IconLock='ExcaliTrail.dmi'
	verb/Excalibur()
		set category="Skills"
		usr.SetQueue(src)

obj/Skills/Projectile/ExcaliburProjectile
	IconLock='Excaliblast.dmi'
	IconSize=0.5
	Dodgeable=-1
	Radius=1
	Striking=0
	ZoneAttack=1
	ZoneAttackX=0
	ZoneAttackY=0
	FireFromSelf=1
	FireFromEnemy=0
	Speed=0.5
	Variation=0
	StrScaling=1
	ForScaling=1
	EndEffectiveness=1
	Knockback=1
	Trail='ExcaliTrail.dmi'
	MultiHit=8
	DamageMult=2
	AccMult=1.5
	Deflectable=0
	Distance=20
	Instinct=1
	LockY=-46
	LockX=-32

obj/Skills/AutoHit/True_Excalibur
	NeedsSword=1
	ABuffNeeded="Soul Resonance"
	EnergyCost=5
	Area="Arc"
	Distance=10
	DelayTime=2
	ComboMaster=1
	CursedWounds=1
	Quaking=8
	Divide=1
	PreShockwave=1
	Shockwaves=1
	Shockwave=1
	ShockIcon='fevKiaiDS.dmi'
	Speed=0.5
	NoForcedWhiff=1
	Instinct=3
	DamageMult=3.65
	Stunner=2
	Launcher=6
	Rounds=2
	Knockback=30
	RoundMovement=0
	StrScaling=1
	EndEffectiveness=0.75
	ForScaling=1
	Cooldown=25
	HitSparkIcon='Hit Effect Excal.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=7
	TurfShift='Excalitrail.dmi'
	TurfStrike=1
	Shearing=15
	Slow=1
	WindUp=1
	WindupIcon='Ripple Radiance.dmi'
	WindupIconUnder=1
	WindupIconX=-32
	WindupIconY=-32
	GuardBreak=1//Can't be dodged or blocked
	WindupMessage="raises their blade overhead as holy energy takes shape around them..."
	ActiveMessage="releases a holy slash that mows the area before them in a wave of light!"
	verb/True_Excalibur()
		set category="Skills"
		usr.Activate(src)

obj/Skills/Queue/ExcaliburMorgan
	SagaSignature=1
	ActiveMessage="forces corrupted miasma through her blade..."
	HitMessage="unleashes the corrupted miasma with a swing of her blade!"
	NeedsSword=1
	ABuffNeeded="Soul Resonance"
	PushOut=1
	PushOutWaves=1
	PushOutIcon='KenShockwavePurple.dmi'
	DamageMult=5
	AccuracyMult=1
	KBMult=1
	Duration=6
	Instinct=1
	Projectile="/obj/Skills/Projectile/ExcaliburMProjectile"
	Delayer = 0.33
	Warp=0
	Cooldown=30
	EnergyCost=10
	IconLock='ExcaliTrail.dmi'
	verb/ExcaliburMorgan()
		set name="Excalibur Morgan"
		set category="Skills"
		usr.SetQueue(src)

obj/Skills/Projectile/ExcaliburMProjectile
	IconLock='DExcaliblast.dmi'
	IconSize=0.5
	Dodgeable=-1
	Radius=1
	Striking=0
	ZoneAttack=1
	ZoneAttackX=0
	ZoneAttackY=0
	FireFromSelf=1
	FireFromEnemy=0
	Speed=1
	Variation=0
	StrScaling=1
	ForScaling=1
	EndEffectiveness=1
	Knockback=1
	Trail='ExcaliTrail.dmi'
	MultiHit=8
	DamageMult=0.35
	AccMult=1.5
	Deflectable=0
	Distance=20
	Instinct=1
	LockY=-46
	LockX=-32

obj/Skills/AutoHit/False_Excalibur
	NeedsSword=1
	ABuffNeeded="Soul Resonance"
	EnergyCost=35
	Area="Arc"
	Distance=10
	DelayTime=2
	ComboMaster=1
	CursedWounds=1
	Quaking=10
	Divide=1
	PreShockwave=1
	Shockwaves=1
	Shockwave=1
	ShockIcon='DarkKiai.dmi'
	Speed=0.5
	NoForcedWhiff=1
	Instinct=3
	DamageMult=10
	Stunner=5
	Launcher=6
	Rounds=2
	Knockback=30
	RoundMovement=0
	StrScaling=1
	EndEffectiveness=0.75
	ForScaling=1
	Cooldown=90
	HitSparkIcon='Hit Effect Excal.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=7
	TurfShift='Excalitrail.dmi'
	TurfStrike=1
	Shearing=15
	Slow=1
	WindUp=1
	WindupIcon='Amazing Super Changeling Aura.dmi'
	WindupIconUnder=0
	WindupIconX=-32
	WindupIconY=0
	GuardBreak=1//Can't be dodged or blocked
	WindupMessage="raises their blade overhead as corrupted miasma heeds their call..."
	ActiveMessage="releases an unholy strike that mows the area before them in a torrent of darkness!"
	verb/False_Excalibur()
		set category="Skills"
		usr.Activate(src)

/*obj/Skills/Projectile/Weapon_Soul
	Excalibur
		IconLock='Excaliblast.dmi'
		ActiveMessage = "lets loose a slash full of Promised Victory: Excalibur!"
		LockX=-50
		LockY=-50
		DamageMult=1
		AccMult=25
		MultiHit=6
		Knockback=1
		Radius=3
		ZoneAttack=1
		ZoneAttackX=0
		ZoneAttackY=0
		FireFromSelf=1
		FireFromEnemy=0
		Explode=3
		StrScaling=1
		ForScaling=1
		EndEffectiveness=1
		Trail='ExcaliTrail.dmi'
		TrailDuration=1
		Dodgeable=-1
		Deflectable=-1
		Distance=100
		Cooldown = 60
		adjust(mob/p)
			DamageMult = 4 + p.SagaLevel
			Radius = 3 + p.SagaLevel
			IconSize = 1 + p.SagaLevel
			Homing = 1 + p.SagaLevel
			LosesHoming = 1 + p.SagaLevel
		verb/Excalibur()
			set category = "Skills"
			adjust(usr)
			usr.UseProjectile(src)

	Excalibur_Morgan
		IconLock='DExcaliblast.dmi'
		ActiveMessage = "lets loose a slash full of Promised Victory: Excalibur Morgan!"
		LockX=-50
		LockY=-50
		DamageMult=0.25
		AccMult=25
		MultiHit=25
		Trail='Trail - Scorpio.dmi'
		TrailDuration=1
		Knockback=1
		Radius=3
		ZoneAttack=1
		ZoneAttackX=0
		ZoneAttackY=0
		FireFromSelf=1
		FireFromEnemy=0
		Explode=3
		StrScaling=1
		ForScaling=1
		EndEffectiveness=1
		Dodgeable=-1
		Deflectable=-1
		Distance=100
		Cooldown = 90
		adjust(mob/p)
			DamageMult = 6 + p.SagaLevel
			Radius = 3 + p.SagaLevel
			IconSize = 1 + p.SagaLevel
			Homing = 1 + p.SagaLevel
			LosesHoming = 1 + p.SagaLevel
		verb/Excalibur_Morgan()
			set category = "Skills"
			adjust(usr)
			usr.UseProjectile(src)*/

/obj/Skills/Buffs/NuStyle/SwordStyle //slightly weaker than t2. maybe make it scaling???
	Knight_Of_Camelot
		StyleActive="Knight of Camelot"
		passives = list("Harden" = 0.5)
		StyleEnd=1.25
		StyleStr=1.25
		Finisher="/obj/Skills/Queue/Finisher/Rook_Splitter"
		adjust(mob/p)
			StyleStr = 1.05 + (0.05 * p.SagaLevel)
			StyleEnd = 1.05 + (0.05 * p.SagaLevel)
			passives["Harden"] = 0.25*p.SagaLevel
		verb/Knight_Of_Camelot()
			set hidden=1
			adjust(usr)
			Trigger(usr)

/obj/Skills/Queue/Finisher
	Right_To_Rule
		DamageMult=8
		HitSparkIcon='Slash - Zan.dmi'
		HitSparkX=-32
		HitSparkY=-32
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Kingmaker"
		HitMessage = "shows their foe why they are King!"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher
	King_Of_Camelot
		StrMult=1.3
		ForMult=1.3
		passives = list()

/mob/Players/verb
	Excalignment()
		set name = "Excalibur Alignment"
		set category = "Roleplay"
		set hidden = 1
		if(!(world.time > src.verb_delay)) return
		usr.verb_delay=world.time+1
		if(usr.ActiveBuff || usr.SpecialBuff || usr.SlotlessBuffs.len>0)
			usr << "Turn off all buffs before using this!"
			return
		for(var/obj/Items/Sword/Medium/Legendary/WeaponSoul/Sword_of_Glory/excalibur in usr.contents)
			if(excalibur.caledFinal == TRUE)
				usr << "You have made up your mind. You won't change your path again."
				return
			if(excalibur.caledLight == TRUE)
				if(alert("Are you finally tired of endlessly serving others? Are you ready to fight for only yourself?"))
					DeleteSkill(new/obj/Skills/AutoHit/True_Excalibur)
					DeleteSkill(new/obj/Skills/Queue/Excalibur)
					AddSkill(new/obj/Skills/AutoHit/False_Excalibur)
					AddSkill(new/obj/Skills/Queue/ExcaliburMorgan)
					excalibur.caledLight = FALSE
					excalibur.Element = "Dark"
					excalibur.caledFinal = TRUE
					excalibur.icon= 'Caledfwlch Morgan.dmi'
					usr << "You have been permanently corrupted into a ruler who destroys and ruins!"
					return
			else if(excalibur.caledLight == FALSE)
				if(alert("Don't you hear their cries and see their tears? Won't you fight for their salvation?"))
					DeleteSkill(new/obj/Skills/AutoHit/False_Excalibur)
					DeleteSkill(new/obj/Skills/Queue/ExcaliburMorgan)
					AddSkill(new/obj/Skills/AutoHit/True_Excalibur)
					AddSkill(new/obj/Skills/Queue/Excalibur)
					excalibur.caledLight = TRUE
					excalibur.Element = "Light"
					excalibur.caledFinal = TRUE
					excalibur.icon= 'Caledfwlch.dmi'
					usr << "You have been eternally purified into a ruler who protects and shelters!"
			else
				usr << "Something went wrong. Contact an admin."
				return