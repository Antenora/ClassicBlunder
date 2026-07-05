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
    if(isRace(BEASTKIN) && istype(race, /race/beastkin))
        var/race/beastkin/bk = race
        if(bk.Racial == "Heart of The Beastkin")
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

/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/The_Grit
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

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Heart_of_the_Half_Beast
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
    Trigger(mob/User, Override)
        getRegenRate(User)
        ..()