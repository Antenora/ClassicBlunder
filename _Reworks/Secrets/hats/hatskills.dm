// DEBUG //
/*
/mob/verb/giveGoeticskills()
	AddSkill(new/obj/Skills/Queue/Goetic_Special)
	AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Hats/SufferInHellWithNoHoes)
	AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Hats/Liberation)
	AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Hats/HeraldOfTheConstellation)
	AddSkill(new/obj/Skills/Projectile/Hats/Elven_Barrage)
//	AddSkill(new/obj/Skills/Companion/GIGASpiritMechSummon)

*/


// GOETIC //
////////////////////////////////
///////////////////////////////

/obj/Skills/Queue/Goetic_Special
	name = "PlaceHolder"
	ActiveMessage = "PlaceHolder"
	DamageMult = 1.25
	AccuracyMult = 10
	KBMult = 0.00001
	KBAdd = 1
	Combo = 16
	Warp=3
	Duration=5
	Cooldown=-1
	Decider=1
	CursedWounds = 1 // this won't work, it'd have to attach to a passive
	// NeedsSword=1
	EnergyCost=5
	HitSparkIcon='Slash - Vampire.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=1.1
	HitStep=/obj/Skills/Queue/Goetic_Special2
	verb/Goetic_Special()
		set category="Skills"
		usr.SetQueue(src)
/obj/Skills/Queue/Goetic_Special2
	name = "PlaceHolder"
	ActiveMessage = "PlaceHolder"
	DamageMult = 13
	AccuracyMult = 10
	KBMult = 5
	Warp = 6
	Duration = 6
	Decider = 1
	Instinct = 4
	EnergyCost = 13
	IconLock = 'UltraInstinctSpark.dmi'
	HitSparkIcon='Slash - Vampire.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns = 0
	HitSparkSize = 2
	verb/Goetic_Special()
		set category="Skills"
		usr.SetQueue(src)

#define GOETIC_HELL_X 100
#define GOETIC_HELL_Y 100
#define GOETIC_HELL_Z 12

/obj/Skills/Buffs/SlotlessBuffs/Hats/SufferInHellWithNoHoes
	WarpZone=1
	WarpX = GOETIC_HELL_X
	WarpY = GOETIC_HELL_Y
	WarpZ = GOETIC_HELL_Z
	Duel=1
	CastingTime=2
	Range=10
	KenWaveIcon='KenShockwaveBloodlust.dmi'
	TurfShift='LavaTile.dmi'
	Cooldown=-1
	SendBack = TRUE
	ActiveMessage="placeholder"
	OffMessage="closses the rift in reality, sealing off their hellish abyss."
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/HatDebuff/AbyssWalker // check back and make this applytoTarget actually works
	verb/SufferInHellWithNoHoes()
		set category="Skills"
		if(usr.Target==usr || !usr.Target)
			usr << "Can't target [usr.Target == usr ? " yourself" : " nothing"]."
			return
		if(src.WarpTarget)
			var/found=0
			for(var/mob/Players/m in players)
				if(m==src.WarpTarget)
					usr.SetTarget(m)
					found=1
			if(!found)
				usr << "You can't seal the target inside the divide."
				return
		ActiveMessage = "tears open the depths of hell, dragging [usr.Target] into the hellish abyss..."
		src.Trigger(usr)


/obj/Skills/Buffs/SlotlessBuffs/HatDebuff/AbyssWalker
	InstantAffect = 1
	TimerLimit = 60
	strAdd = -0.25
	endAdd = -0.25
	forAdd = -0.25
	passives = list("PureDamage" = -1, "PureReduction" = -1)
	ActiveMessage = "is trapped in the depths of hell."
	OffMessage = "escapes the depths of hell."
	IconLock = 'SparkleFire.dmi'


// STELLAR //
////////////////////////////////
///////////////////////////////

// add turfs to the global loop, remove them after the timer is up so that they are changed back to normal
// apply an imaage over the prebvious turfs

/obj/Skills/Buffs
	var/spaceMaker/makSpace
	// this could be a list instead




/obj/Skills/Buffs/SlotlessBuffs/Hats/Liberation
	makSpace = new/spaceMaker/Constellation
	passives = list("Constellation" = 1) // enables u to defeat being drained by ur tiles
	// funnily enough this passive would make u heal from any1 elses tiles, which is bad
	// but afaik they aren't gonna do that so

	ActiveMessage = "summons the power of the stars."
	OffMessage = "loses the power of the stars."
	TimerLimit = 140
	Cooldown = -1 // ? not sure what they want
	verb/Liberation()
		set category="Skills"
		if(!usr.BuffOn(src) && !cooldown_remaining)
			makSpace.makeSpace(usr, "Stellar")
		src.Trigger(usr)


/obj/Skills/Buffs/SlotlessBuffs/Hats/HeraldOfTheConstellation
	// we silver surfer now
	ArmorClass = "Light"
	ArmorElement = "Chaos"
	ArmorAscension = 3
	passives = list("SpiritPower" = 2, "MovementMastery" = 10, "DebuffResistance" = 1, "Godspeed" = 2)
	ForMult = 1.25
	EndMult = 1.1
	StrMult = 1.25
	OffMult = 1.25
	DefMult = 1
	// ArmorIcon = blah
	ActiveMessage = "silver surfer moment"
	OffMessage = "silver surfer moment over"
	adjust(mob/p)
		if(altered) return
		ForMult = 1.25 + (p.Potential*0.05)
		EndMult = 1.1 + (p.Potential*0.05)
		StrMult = 1.25 + (p.Potential*0.05)
		OffMult = 1.25 + (p.Potential*0.05)
		DefMult = 1 + (p.Potential*0.05)
		passives = list("SpiritPower" = p.Potential/25, "MovementMastery" = p.Potential/3, "DebuffResistance" = 1, "Godspeed" = p.Potential/15)
		// they r ending at 50 pot, so we imagine that 50 is the new 100
	verb/HeraldOfTheConstellation()
		set category="Skills"
		if(!usr.BuffOn(src))
			adjust(usr)
		src.Trigger(usr)

// ELVEN


/obj/Skills/Projectile/Hats/Elven_Barrage
	Copyable = FALSE
	Blasts = 1 // alter this on the fly
	DamageMult = 1 // alter this on the fly
	Radius = 1 // ? dont know what this does given it shouldn't do this
	AccMult = 2
	Deflectable = 0
	Static = 1
	Distance = 100
	IconLock = 'Blast31.dmi'
	LockX = 0
	LockY = 0
	ZoneAttack = 1
	ZoneAttackX = 1 // alter this on the fly
	ZoneAttackY = 1 // alter this on the fly
	Hover = 14
	FireFromSelf = 1
	Cooldown = 120
	Explode = 2
	EnergyCost = 15
	adjust(mob/p)
		var/mastery = p.Potential
		var/level = p.secretDatum.currentTier
		Blasts = round(15 + (level + mastery / 10),1)
		DamageMult = 31 / Blasts
		ZoneAttackX = 7 + round(level + mastery / 15,1)
		ZoneAttackY = 7 + round(level + mastery / 15,1)
	verb/Elven_Barrage()
		set category="Skills"
		adjust(usr)
		usr.UseProjectile(src)