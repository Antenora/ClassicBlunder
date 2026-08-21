/mob/proc/isMountainheart()
    if(!isRace(WILDER)) return 0;
    if(Class != "Mountainheart") return 0;
    return 1;

/mob/proc/AdjustGrit(option, val)
    var/maxGrit = 20 + (20 * AscensionsAcquired)
    switch(option)
        if("add")
            if(passive_handler["Grit"] + val <= maxGrit)
                passive_handler.Increase("Grit", round(val, 0.1))
        if("sub")
            if(passive_handler["Grit"] - val >= 1)
                passive_handler.Decrease("Grit", round(val, 0.1))
        if("reset")
            passive_handler["Grit"] = 1

// TRUE if any active source still grants Grit. Used after a Grit-bearing buff
// turns off to decide whether combat-accumulated Grit should persist or get
// cleared. Sources: Beastkin Heart racial baseline, plus any active buff
// (Active/Special/Stance/Style/Slotless) that lists "Grit" in its passives.
/mob/proc/hasActiveGritSource()
    if(isRace(WILDER) && istype(race, /race/wilder))
        var/race/wilder/bk = race
        if(bk.Racial == "Mountainheart")
            return TRUE
    if(ActiveBuff && BuffOn(ActiveBuff) && ActiveBuff.passives && ("Grit" in ActiveBuff.passives))
        return TRUE
    if(SpecialBuff && BuffOn(SpecialBuff) && SpecialBuff.passives && ("Grit" in SpecialBuff.passives))
        return TRUE
    if(StanceBuff && BuffOn(StanceBuff) && StanceBuff.passives && ("Grit" in StanceBuff.passives))
        return TRUE
    if(StyleBuff && BuffOn(StyleBuff) && StyleBuff.passives && ("Grit" in StyleBuff.passives))
        return TRUE
    if(SlotlessBuffs && SlotlessBuffs.len)
        for(var/b in SlotlessBuffs)
            var/obj/Skills/Buffs/SlotlessBuffs/sb = SlotlessBuffs[b]
            if(sb && sb.passives && ("Grit" in sb.passives))
                return TRUE
    return FALSE

/obj/Skills/Buffs/SlotlessBuffs/Racial/Wilder/The_Grit
	BuffName = "The Grit"
	Cooldown = -1
	NeedsHealth = 50
	ActiveMessage = "channels their grit and prepares for the next attack!"
	ResourceCost = list("Grit", 999) // consumes all grit on use
	adjust(mob/p)
		var/currentGrit = p.passive_handler["Grit"]
		currentGrit/=10
		VaizardHealth = 10+ currentGrit
	verb/The_Grit()
		set category = "Skills"
		if(!usr.BuffOn(src)) adjust(usr)
		Trigger(usr)



/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastkin/Thrill_of_the_Hunt
	AlwaysOn = 1
	NeedsPassword = 1
	TimerLimit = 30
	Crippling = 15
	passives = list("Afterimages" = 2, "Crippling" = 5)
    //passives were kill: brutalize
	adjust(mob/p)
		Crippling= 5 + 5 * p.AscensionsAcquired
		passives = list("Godspeed" = p.AscensionsAcquired,  "Afterimages" = 2, "Crippling" = 5 + 5 * p.AscensionsAcquired)


/obj/Skills/AutoHit/Haymaker
    Copyable=0
    NeedsSword=0
    Area="Arc"
    DamageMult=2
    Cooldown=5
    Distance=2
    Size=1
    FlickAttack=1
    ShockIcon='KenShockwave.dmi'
    Shockwave=2
    Shockwaves=1
    PostShockwave=1
    PreShockwave=0
    WindUp=0.25
    Earthshaking=20
    Instinct=1
    Icon='roundhouse.dmi'
    IconX=-16
    IconY=-16
    HitSparkIcon='Hit Effect.dmi'
    HitSparkX=-32
    HitSparkY=-32
    HitSparkTurns=1
    HitSparkSize=1.5
    HitSparkDispersion=1
    TurfStrike=1
    TurfShift='Dirt1.dmi'
    TurfShiftDuration=1
    ActiveMessage="unleashes a vacuum powered slash!"
    adjust(mob/p, dmg)
        var/asc = p.AscensionsAcquired
        DamageMult = dmg * 0.5 + (0.25*asc)
        Size = 3 + (1*asc)
        Distance = 4 + (1*asc)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wilder/Heart_of_the_Half_Beast
    TooMuchHealth = 30
    NeedsHealth = 10
    UnrestrictedBuff=1
    Cooldown=-1
    CooldownStatic=1
    CooldownScaling=1
    HealthHeal = 0.5
    StableHeal = 1
    TimerLimit = 10
    ActiveMessage="'s heart begins to pump into overdrive!"
    OffMessage="'s heart can't keep up..."
    proc/getRegenRate(mob/p)
        var/amt = clamp(10+(p.AscensionsAcquired*5), 10, 25);//ranges from 10 to 25
        var/timer = clamp(10-max(0, p.AscensionsAcquired-1), 5, 10);//Ranges from 10 to 5
        HealthHeal = amt / timer;
        WoundHeal = HealthHeal / 2;
        if(p.AscensionsAcquired>=6) timer *= 2;
        TimerLimit = timer;
    Trigger(mob/User, Override)
        if(!User.BuffOn(src)) getRegenRate(User)
        ..()

/obj/Skills/Queue/Racial/Wilder/Savagery
	BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Ripped"
	DamageMult = 1.5
	Dominator = 2
	Finisher = 2
	AccuracyMult = 1.5
	HitMessage = "tears into their enemy!"
	HitSparkIcon = 'MasterSlash.dmi'
	HitSparkX=-16
	HitSparkY=-16
	EnergyCost = 2.5
	Cooldown = 45
	adjust(mob/p)
		DamageMult = 1.5 + (p.AscensionsAcquired * 0.25)
		Dominator = 2 + (p.AscensionsAcquired * 0.5)
		Finisher = 2 + (p.AscensionsAcquired * 0.5)
		Cooldown = 45 - (p.AscensionsAcquired * 5)

	verb/Savagery()
		set category = "Skills"
		if(!Using) adjust(usr)
		usr.SetQueue(src)


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Ripped // TODO: make the buffedaffected attackQ work correctly n make this scale
	TimerLimit = 15
	passives = list("PureReduction" = -0.5)
	adjust(mob/p)
		passives = list("PureReduction" = -0.5 - (0.25 * p.AscensionsAcquired)) // this is calling owner'a sc, which im aware of but fuck it
		TimerLimit = 15 + (5 * p.AscensionsAcquired)
	ActiveMessage = "'s body is ripped to shreds!"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Rattled
    NeedsPassword = 1
    Cooldown = 4
    AlwaysOn = 1
    CrippleAffected = 3
    EndMult = 0.9
    DefMult = 0.4
    SpdMult = 0.3
    passives = list("PureReduction" =  -1, "Godspeed" = -3)
    TimerLimit = 20

/obj/Skills/AutoHit/Mountain_Roar
    Area="Circle"
    DamageMult=0.1
    Rounds=1
    TurfDirt=1
    TurfErupt=1
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
    BuffAffected ="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Rattled"
    adjust(mob/p)
        var/asc = p.AscensionsAcquired
        Stunner = 2 + asc
        Distance = 2 + asc
        DamageMult = 0.5 + asc;
        
    verb/Mountain_Roar()
        set category="Skills"
        adjust(usr)
        usr.Activate(src)

/obj/Skills/Projectile/Shard_Storm
    ElementalClass = "Earth"
    Distance=20
    DamageMult=2.5
    Blasts=10
    Stream=1
    Radius=1
    MultiHit=2
    Knockback=1
    Striking=1
    Cooldown=160
    Shattering=5
    Delay=1
    IconLock='Crystal.dmi'
    Variation=24
    adjust(mob/p)
        var/asc = usr.AscensionsAcquired;
        Blasts = 6 + asc;
        DamageMult = 2.5 + (asc * 1.5);
        Radius = clamp(asc, 1, 5);
        Shattering = 2 + clamp(asc*2, 0.5, 2.5);
        DamageMult = DamageMult / Blasts;
        Cooldown = 60 - ( 5 * asc);
    verb/Shard_Storm()
        set category="Skills"
        adjust(usr);
        usr.UseProjectile(src)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage/Dragons_Tenacity
    ActiveMessage = "forms a draconic shell!!"
    OffMessage = "loses their draconic shell..."
    adjust(mob/p)
        if(altered) return
        var/asc = p.AscensionsAcquired
        ..(p);
        ElementalOffense = "Earth"
        ElementalDefense = "Earth"
        endAdd = 0.15 * asc
        passives = list("PureReduction" = asc+1, "BlockChance" = (5*(asc+1)), "CriticalBlock" = (0.1*(asc+1)),\
                        "Harden" = 2 + (asc/2))
        //passives were kill: harden
    Trigger(mob/User, Override = FALSE)
        if(!User.BuffOn(src)) adjust(User)
        ..()