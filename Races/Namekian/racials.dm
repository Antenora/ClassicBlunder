/obj/Skills/Projectile/Namekian

/obj/Skills/Projectile/Namekian/Mystic_Attack
	name = "Mystic Attack"
	desc = "Stretch an arm out to seize a foe up to six tiles away, drag them to your side and daze them."
	Copyable = 0
	DamageMult = 0.5
	Distance = 6
	Cooldown = 20
	EnergyCost = 2
	Stunner = 0.8
	Knockback = 0
	Variation = 0
	Homing = 0
	OnMobHit = "/proc/NamekMysticAttackHit"
	ActiveMessage = "stretches out an arm to seize their foe!"
	var/MysticIcon = 'namekarm.dmi'
	var/MysticIconState = "head"
	var/MysticLockX = 0
	var/MysticLockY = 0

	New()
		..()
		IconLock = icon(MysticIcon, MysticIconState)
		LockX = MysticLockX
		LockY = MysticLockY

	verb/Mystic_Attack()
		set name = "Mystic Attack"
		set category = "Skills"
		usr.UseProjectile(src)

/proc/NamekMysticAttackHit(mob/target, obj/Skills/Projectile/_Projectile/proj)
	if(!ismob(target) || !proj)
		return
	var/mob/owner = proj.Owner
	if(!ismob(owner) || owner == target || target.KO || target.Dead)
		return
	var/d = get_dist(owner, target)
	if(d > 1)
		target.PullToward(owner, d - 1, 1)

/obj/Skills/AutoHit/Namekian

/obj/Skills/AutoHit/Namekian/Antenna_Beam
	name = "Antenna Beam"
	desc = "Fire a crackling bolt of lightning from your antennae that stuns the first foe within three tiles."
	Copyable = 0
	Area = "Strike"
	Distance = 3
	ForScaling = 1
	DamageMult = 0.4
	Stunner = 0.5
	Knockback = 0
	Cooldown = 25
	EnergyCost = 1
	Icon = 'Antenna Beam.dmi'
	Size = 6
	HitSparkIcon = 'BLANK.dmi'
	ActiveMessage = "fires crackling lightning from their antennae!"

	verb/Antenna_Beam()
		set name = "Antenna Beam"
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/Projectile/Namekian/Mouth_Energy_Wave
	name = "Mouth Energy Wave"
	desc = "Spit a quick, thin beam of ki from your mouth with no charge."
	Copyable = 0
	DamageMult = 0.8
	Distance = 12
	Cooldown = 10
	EnergyCost = 1
	Knockback = 0
	Variation = 0
	IconLock = 'Blast - Small.dmi'
	ActiveMessage = "spits a thin beam of ki from their mouth!"
	var/ChouMakouhouDamage = 1.4

	adjust(mob/p)
		if(p && p.Class == NAMEK_CLAN_DEMON && p.AscensionsAcquired >= 1)
			DamageMult = ChouMakouhouDamage
			Piercing = 1
		else
			DamageMult = initial(DamageMult)
			Piercing = initial(Piercing)

	verb/Mouth_Energy_Wave()
		set name = "Mouth Energy Wave"
		set category = "Skills"
		adjust(usr)
		usr.UseProjectile(src)

/proc/NamekHeartText(mob/m)
	if(!ismob(m))
		return ""
	return m.IsEvil() ? "an evil heart" : "a good heart"

/mob/Players/Examined(mob/user)
	..()
	if(ismob(user) && user != src && user.NamekIsNamek())
		user << "<font color=#77cc77>You sense [NamekHeartText(src)] in [src].</font>"

/mob/proc/NamekSoundMult()
	if(!NamekIsNamek())
		return 1
	if(istype(src.SpecialBuff, /obj/Skills/Buffs/SpecialBuffs/Namekian_Giant_Form))
		return NAMEK_SOUND_GIANT_MULT
	return NAMEK_SOUND_MULT

mob
	proc
		inParty(keyLooking)
			if(isRace(CHANGELING) && Anger) return null
			if(party)
				for(var/mob/Players/p in party.members)
					if(p.ckey == keyLooking)
						return p
			return null

proc
	findPlayer(keyLooking)
		for(var/mob/Players/p in players)
			if(p.ckey == keyLooking)
				return p
