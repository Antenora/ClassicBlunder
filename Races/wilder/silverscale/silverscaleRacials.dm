/mob/proc/isSilverscale()
    if(!isRace(WILDER)) return 0;
    if(Class != "Silverscale") return 0;
    return 1;

/obj/Skills/Buffs/SlotlessBuffs/Racial/Blend_In
    Invisible = 22
    ActiveMessage = "blends into their surroundings"
    verb/Blend_In()
        set category = "Utility"
        Trigger(usr)

/obj/Skills/Projectile/Racial/Fox_Fire_Barrage
    FoxFire = 2
    Homing = 1
    Distance=30
    DamageMult=2.5
    Burning = 10
    Blasts=3
    AccMult=2
    Homing=1
    HomingCharge=1
    HomingDelay=1
    EnergyCost=8
    Delay=5
    Speed=1.5
    IconChargeOverhead=1
    IconLock = 'Elec Ball Blue.dmi'
    Cooldown = 60
    adjust(mob/p)
        FoxFire = 2 + p.AscensionsAcquired
        Blasts= 3 * max(1, p.AscensionsAcquired);
        DamageMult= 2.5 + (p.AscensionsAcquired * 0.25)
    verb/Fox_Fire_Barrage()
        set category = "Skills"
        adjust(usr)
        usr.UseProjectile(src)

/obj/Skills/AutoHit/Mist_Form
    Area="Circle"
    ComboMaster=1
    DamageMult=0.025
    Rounds=10
    Cooldown=180
    NoLock = 1
    NoAttackLock = 1
    Size=3
    NeedsSword = 0
    UnarmedOnly = 0
    Icon='mist.dmi'
    HitSparkIcon = 'Hit_Effect_Oath_2.dmi'
    BuffSelf=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Mist_Form
    HitSparkX = -32
    HitSparkY = -32
    Instinct=5
    ActiveMessage="turns into mist!"
    ManaCost = 10
    adjust(mob/p)
        Rounds = 10 + (5 * p.AscensionsAcquired)
        Cooldown = 180 - (15 * p.AscensionsAcquired)
        ManaCost = 10 + (2.5 * p.AscensionsAcquired)
    verb/Mist_Form()
        set category = "Skills"
        adjust(usr)
        usr.Activate(src)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Mist_Form
    IconReplace = 1
    icon = 'mist.dmi'
    IconTransform = 'mist.dmi'
    Cooldown = 60
    TimerLimit = 10
    adjust(mob/p)
        passives = list("Godspeed" = 1 + p.AscensionsAcquired, "Deflection" = 0.5 + (p.AscensionsAcquired/2), "Reversal" = 0.1 + (p.AscensionsAcquired*0.1))
        TimerLimit = 5 + (5*p.AscensionsAcquired)
        if(p.passive_handler["SpiritForm"])
            passives = list("Godspeed" = 3 + p.AscensionsAcquired, "BulletKill" = 1, "Deflection" = 1 + (p.AscensionsAcquired/2), "Reversal" = 0.15 + (p.AscensionsAcquired*0.15))
            TimerLimit = 10 + (5*p.AscensionsAcquired)

/obj/Skills/AutoHit/Oceanic_Wrath
    ElementalClass="Water"
    SpecialAttack=1
    DamageMult=15
    Chilling=150
    Stasis=5
    TurfShift='IceGround.dmi'
    Distance=15
    WindUp=0.5
    WindupMessage="places a cold hand against the ground..."
    ActiveMessage="freezes the area with a destructive chill!"
    Cooldown=90
    Area="Circle"
    adjust(mob/p)
        var/asc = p.AscensionsAcquired;
        DamageMult = 6 + (1.5 * asc)
        Cooldown = 60 - (5 * asc)
        Distance = 10 + (5 * asc)
        Stasis = 5 + (2.5 * asc)
    verb/Oceanic_Wrath()
        set category="Skills"
        adjust(usr);
        usr.Activate(src)
/obj/Skills/AutoHit/Ocean_Roar
    Area="Circle"
    ElementalClass="Water"
    DamageMult=0.1
    Rounds=1
    TurfDirt=1
    ShockIcon='KenShockwave.dmi'
    Shockwave=4
    Shockwaves=1
    PostShockwave=1
    PreShockwave=0
    Cooldown=-1
    Earthshaking=20
    Instinct=1
    WindupMessage="ROARRRR"
    ActiveMessage="ROARRRSSS"
    ComboMaster = 1
    NoLock = 1
    WindUp=0.25
    WindupMessage="brings forth the rain..."
    ActiveMessage="swarms the area with a flood!"
    TurfReplace='PlainWater.dmi'
    SpecialAttack=1
    HitSparkIcon='Hit Effect Pearl.dmi'
    HitSparkX=-32
    HitSparkY=-32
    HitSparkTurns=1
    HitSparkSize=1
    TurfStrike=1
    adjust(mob/p)
        var/asc = p.AscensionsAcquired
        Distance = 10 + (asc * 2)
        PullIn = Distance + (4 * asc)
        Deluge = (300 + (300 * asc)) // 30 seconds + 30 each as
        DamageMult = 12 + (asc * 2)
        
    verb/Ocean_Roar()
        set category="Skills"
        adjust(usr)
        usr.Activate(src)

// when buff is on and you entere  tile, attempt to surround the block in water
// if the block is already effected or the surrounding ones are, back out
// passive 'Ocean Bringer"
//
// make dragon roar pull in and flood the area with water

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage/Slithereen_Crush
	passives = list("Ocean Bringer" = 1) // 1 tile around
	ActiveMessage = "brings the ocean to the land!"
	OffMessage = "returns the land to its former form..."
	adjust(mob/p)
		var/asc = p.AscensionsAcquired
		forAdd = 0.15 * asc
		passives = list("Ocean Bringer" = 0.25 + (round(asc/4)), "AbsoluteZero" = 1,  \
	    "VoidField" = asc * 2, "Godspeed" = asc)
        //passives were kill: likewater, fluidform, flow
		ElementalOffense = "Water"
		ElementalDefense = "Water"
	Trigger(mob/User, Override = FALSE)
		if(!User.BuffOn(src))
			adjust(User)
		..()

/mob/Players/proc/HasOceanBringer()
	if(passive_handler.Get("Ocean Bringer") && Health<=15)
		return 1
	return 0

/turf/Cross(O)
	. = ..()
	if(ismob(O))
		var/mob/Players/p = O
		if(!p.client || !p.passive_handler) return
		if(p.HasOceanBringer())
			// start here
			if(hasOceanEffect(p)) return
			applyOceanEffect(p)

/turf/proc/applyLeftOver(mob/p, leftover, time2death)
	effects+=leftover
	Deluged=1
	timeToDeath = time2death
	ownerOfEffect=p
	ticking_turfs+=src

/turf/proc/applyOceanEffect(mob/p)
	for(var/turf/t in Turf_Circle(p,p.passive_handler.Get("Ocean Bringer"))) // look at all tiles in the range
		var/image/i=image(icon='PlainWater.dmi', loc = t)
		i.layer = MOB_LAYER-0.1
		i.mouse_opacity = 0
		animate(i, alpha=0)
		world << i
		t.effects+=i
		animate(i, alpha = 255, time = 2)
		t.Deluged=1
		t.timeToDeath = 150
		t.ownerOfEffect=p
		ticking_turfs+=t

/turf/proc/hasOceanEffect(mob/p)
	for(var/turf/t in Turf_Circle(p,p.passive_handler.Get("Ocean Bringer"))) // look at all tiles in the range
		if(t.Deluged)
			continue
		return 0 // if any aren't effected
	return 1 // they are all inflicted