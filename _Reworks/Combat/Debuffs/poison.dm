#define MAX_POISON_DAMAGE 0.06
#define BASE_BURN_DAMAGE 0.06
#define BURN_STACK_DIVISOR 25
#define BURN_NERF 1
#define POISON_STACKS_DIVISOR 100
#define POISON_NERF 1
#define BASE_BLEED_DAMAGE 0.06
#define BLEED_STACK_DIVISOR 25
#define BLEED_NERF 1





globalTracker/var/maxPoisonDamage = MAX_POISON_DAMAGE
globalTracker/var/PoisonStackDivisor = POISON_STACKS_DIVISOR
globalTracker/var/PoisonNerf = POISON_NERF
globalTracker/var/maxBurnDamage = BASE_BURN_DAMAGE
globalTracker/var/BurnStackDivisor = BURN_STACK_DIVISOR
globalTracker/var/BurnNerf = BURN_NERF
globalTracker/var/maxBleedDamage = BASE_BLEED_DAMAGE
globalTracker/var/BleedStackDivisor = BLEED_STACK_DIVISOR
globalTracker/var/BleedNerf = BLEED_NERF
//TODO AFTER WIPE: move frenzy here? or split these to their own pages
globalTracker/var/DEBUFF_STACK_RESISTANCE = 100
globalTracker/var/HELLFIRE_VALUE_MOD = 2
globalTracker/var/MAX_DEBUFF_CLAMP = 0.05
globalTracker/var/LOWER_DEBUFF_CLAMP = 0.001

/mob/proc/getDebuffDamage(typeOfDebuff)
	var/stackDivisor = glob.vars["[typeOfDebuff]StackDivisor"]
	var/nerf = glob.vars["[typeOfDebuff]Nerf"]
	var/base = glob.vars["max[typeOfDebuff]Damage"]
	var/debuff = src.vars["[typeOfDebuff]"]
	// For Poison, silent stacks don't deal tick damage
	if(typeOfDebuff == "Poison" && src.SilentPoisonAmount > 0 && src.Poison > 0)
		debuff = max(0, debuff - src.SilentPoisonAmount)
		if(debuff <= 0)
			return 0
	// For Burn, Erupting Blows stacks don't deal tick damage
	if(typeOfDebuff == "Burn" && src.SilentBurnAmount > 0 && src.Burn > 0)
		debuff = max(0, debuff - src.SilentBurnAmount)
		if(debuff <= 0)
			return 0
	var/damage = (base * (debuff/stackDivisor)) * nerf
	switch(typeOfDebuff)
		if("Burn")
			if(Cooled)
				damage = damage / 2
		if("Poison")
			if(Antivenomed)
				damage = damage / 2
		if("Frenzy")
			if(IsDarkDragonPlayer())
				return 0

	return clamp(damage, glob.LOWER_DEBUFF_CLAMP, glob.MAX_DEBUFF_CLAMP)

/mob/proc/doDebuffDamage(typeOfDebuff)
	var/dmg = getDebuffDamage(typeOfDebuff)
	if(dmg < 0)
		world.log << "[src] Debuff Damage is negative [dmg], [typeOfDebuff]"
		dmg = 0.001
	var/desp = clamp(passive_handler.Get("Persistence"), 0.1, glob.MAX_PERSISTENCE_CALCULATED)
	if(prob(desp)*(glob.PERSISTENCE_CHANCE * 2)&&!src.HasInjuryImmune())
		desp = clamp(desp, 1, glob.PRESISTENCE_DIVISOR_MAX)
		if(glob.PERSISTENCE_NEGATES_DAMAGE)
			src.WoundSelf(dmg/desp)//Take all damage as wounds
		else
			WoundSelf(dmg)
		dmg=0//but no health damage.
	// anger will not reduce debuff damage
	if(VaizardHealth)
		reduceVaiHealth(dmg)
	if(BioArmor)
		reduceBioArmor(dmg)
	if(typeOfDebuff == "Burn" && (passive_handler.Get("FireAbsorb") || CheckSlotless("Heat of Passion") && Health <= 15 ))
		dmg = 0
	switch(typeOfDebuff)
		if("Burn")
			if(glob.TRACKING_BURNING)
				currentBurn+=dmg
		if("Poison")
			if(glob.TRACKING_POISON)
				currentPoi+=dmg
	if(!src.GetDebuffReversal())
		if(typeOfDebuff == "Frenzy" && Health <= 0)
			dmg = 0
		Health-=dmg
		if(typeOfDebuff == "Frenzy" && !IsDarkDragonPlayer() && dmg > 0)
			WoundSelf(dmg * 0.5)
	if(Health<=0 && !KO)
		if(src.passive_handler.Get("Color of Courage")&& src.Health>glob.TRIPLEHELIX_MAX_NEG_HP)
			return
		if(typeOfDebuff == "Poison")
			Unconscious(null, "succumbing to Poison!")
		if(typeOfDebuff == "Burn")
			Unconscious(null, "burning up!")
		if(typeOfDebuff == "Frenzy")
			Unconscious(null, "succumbing to Frenzy!")
		if(typeOfDebuff == "Bleed")
			Unconscious(null, "bleeding out!")
	if(typeOfDebuff == "Frenzy")
		if(IsDarkDragonPlayer()) reduceDebuffStacks(typeOfDebuff)
		return
	reduceDebuffStacks(typeOfDebuff)

/mob/proc/reduceDebuffStacks(typeOfDebuff)
	var/boon = 0
	var/base = clamp(vars["[typeOfDebuff]"] / glob.BASE_DEBUFF_REDUCTION_DIVISOR, glob.BASE_DEBUFF_REDUCTION_DIVISOR_LOWER,glob.BASE_DEBUFF_REDUCTION_DIVISOR_UPPER)
	// Devil Summoner Element racial
	var/ddr = passive_handler.Get("DebuffDurationReduction")
	if(ddr > 0)
		base *= (1 + ddr)
	switch(typeOfDebuff)
		if("Burn")
			if(Cooled)
				base = 1.5
			if(Burn>0)
				var/reduction = base * (1+ (GetDebuffResistance() / 4))
				// Reduce Erupting Blows stacks proportionally
				if(src.SilentBurnAmount > 0)
					var/silentFrac = min(1.0, src.SilentBurnAmount / Burn)
					src.SilentBurnAmount = max(0, src.SilentBurnAmount - (reduction * silentFrac))
				Burn -= reduction
			if(Burn<0)
				Burn = 0
				src.SilentBurnAmount = 0
		if("Poison")
			boon += passive_handler.Get("VenomResistance")
			if(Antivenomed)
				base = 1.25
			if(Poison>0)
				var/reduction = base * (1 + (GetDebuffResistance() / 4) + boon)
				// Reduce silent stacks proportionally
				if(src.SilentPoisonAmount > 0)
					var/silentFrac = min(1.0, src.SilentPoisonAmount / Poison)
					src.SilentPoisonAmount = max(0, src.SilentPoisonAmount - (reduction * silentFrac))
				Poison -= reduction
				if(BlindingVenom && client)
					if(!client.client_plane_master) // 3 checks lol ! maybe move this to new noob!
						client.client_plane_master = new()
						client.screen += client.client_plane_master
					client.client_plane_master.filters = filter(type="blur", size=BlindingVenom*(Poison/150))
			if(Poison<=0)
				Poison = 0
				src.SilentPoisonAmount = 0
				if(BlindingVenom)
					BlindingVenom=0
					if(client.client_plane_master)
						client.client_plane_master.filters = null
		if("Frenzy")
			if(!IsDarkDragonPlayer()) return
			var/reduction = base * (1 + (GetDebuffResistance() / 4))
			if(Frenzy) Frenzy = clamp(Frenzy - (reduction/10), 0, 100);
		if("Bleed")
			var/reduction = base * (1 + (GetDebuffResistance() / 4));
			if(Bleed) Bleed = clamp(Bleed - reduction, 0, 100);
			if(KatenBleedLock) Bleed = max(KatenBleedLock, Bleed);

/mob/var/tmp/last_implode
mob/proc/implodeDebuff(n, type)
	var/DefReduction=sqrt(GetDef())
	n/=DefReduction
	if(last_implode + glob.IMPLODE_CD < world.time)
		switch(type)
			if("Burn")
				var/obj/Effects/Bang/b = new()
				b.Target = src
				vis_contents += b
				Health -= Health * (n/glob.IMPLODE_DIVISOR) * 1.25
				Burn = 0
				SilentBurnAmount = 0
			if("Chill")
				var/obj/Effects/Freeze/b = new(overwrite_alpha = 255)
				b.Target = src
				vis_contents += b
				Stun(src, 4)
				Health -= Health * (n/glob.IMPLODE_DIVISOR)
				Slow = 0
			if("Shatter")
				var/obj/Effects/Bang/b = new()
				b.Target = src
				vis_contents += b
				Health -= Health * (n/glob.IMPLODE_DIVISOR)
				Shatter = 0
				var/def_penalty = DefMultTotal * 0.1
				DefMultTotal -= def_penalty
				spawn(100)
					if(src)
						src.DefMultTotal += def_penalty


		last_implode = world.time



// COPY PASTED CODE BELOW //
/mob/proc/reduceBioArmor(val)
	src.BioArmor-=val
	if(src.BioArmor<=0)
		val=(-1)*src.BioArmor
		src.BioArmor=0
	else
		val=0
/mob/proc/reduceVaiHealth(val)
	src.VaizardHealth-=val
	if(src.VaizardHealth<=0)
		if(src.ActiveBuff)
			if(src.ActiveBuff.VaizardShatter)
				src.ActiveBuff.Trigger(src)
		if(src.SpecialBuff)
			if(src.SpecialBuff.VaizardShatter)
				src.SpecialBuff.Trigger(src)
		for(var/sb in src.SlotlessBuffs)
			var/obj/Skills/Buffs/b = SlotlessBuffs[sb]
			if(b)
				if(b.VaizardShatter)
					b.Trigger(src)
		if(src.VaizardHealth<0)
			val=((-1)*src.VaizardHealth)
			src.VaizardHealth=0
		else
			val=0
	else
		val=0

