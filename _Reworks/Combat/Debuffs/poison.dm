#define MAX_POISON_DAMAGE 0.06
#define BASE_BURN_DAMAGE 0.06
#define BURN_STACK_DIVISOR 25
#define BURN_NERF 1
#define POISON_STACKS_DIVISOR 100
#define POISON_NERF 1





globalTracker/var/maxPoisonDamage = MAX_POISON_DAMAGE
globalTracker/var/PoisonStackDivisor = POISON_STACKS_DIVISOR
globalTracker/var/PoisonNerf = POISON_NERF
globalTracker/var/maxBurnDamage = BASE_BURN_DAMAGE
globalTracker/var/BurnStackDivisor = BURN_STACK_DIVISOR
globalTracker/var/BurnNerf = BURN_NERF
globalTracker/var/DEBUFF_STACK_RESISTANCE = 100
globalTracker/var/HELLFIRE_VALUE_MOD = 2
globalTracker/var/MAX_DEBUFF_CLAMP = 0.1
globalTracker/var/LOWER_DEBUFF_CLAMP = 0.001

/mob/proc/getDebuffDamage(typeOfDebuff)
	var/stackDivisor = glob.vars["[typeOfDebuff]StackDivisor"]
	var/nerf = glob.vars["[typeOfDebuff]Nerf"]
	var/base = glob.vars["max[typeOfDebuff]Damage"]
	var/debuff = src.vars["[typeOfDebuff]"]
	var/damage = (base * (debuff/stackDivisor)) * nerf
	switch(typeOfDebuff)
		if("Burn")
			if(Cooled)
				damage = damage / 2
		if("Poison")
			if(Antivenomed)
				damage = damage / 2
		
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
	Health-=dmg
	if(Health<=0 && !KO)
		if(typeOfDebuff == "Poison")
			Unconscious(null, "succumbing to Poison!")
		if(typeOfDebuff == "Burn")
			Unconscious(null, "burning up!")
	reduceDebuffStacks(typeOfDebuff)


/mob/proc/reduceDebuffStacks(typeOfDebuff)
	var/boon = 0
	var/base = clamp(vars["[typeOfDebuff]"] / glob.BASE_DEBUFF_REDUCTION_DIVISOR, glob.BASE_DEBUFF_REDUCTION_DIVISOR_LOWER,glob.BASE_DEBUFF_REDUCTION_DIVISOR_UPPER)
	switch(typeOfDebuff)
		if("Burn")
			if(Cooled)
				base = 1.5
			if(Burn>0)
				Burn -= base + ((GetEnd(0.15)+GetStr(0.15)) * (1+ (GetDebuffResistance() / 4))  )
			if(Burn<0)
				Burn = 0
		if("Poison")
			boon += passive_handler.Get("VenomResistance")
			if(Antivenomed)
				base = 1.25
			if(Poison>0)
				Poison -= base + (GetEnd(0.15) * (1 + (GetDebuffResistance() / 4)+boon))
				if(BlindingVenom && client)
					if(!client.client_plane_master) // 3 checks lol ! maybe move this to new noob!
						client.client_plane_master = new()
						client.screen += client.client_plane_master
					client.client_plane_master.filters = filter(type="blur", size=BlindingVenom*(Poison/150))
			if(Poison<=0)
				Poison = 0
				if(BlindingVenom)
					BlindingVenom=0
					if(client.client_plane_master)
						client.client_plane_master.filters = null
				
/mob/var/tmp/last_implode
mob/proc/implodeDebuff(n, type)
	if(last_implode + glob.IMPLODE_CD < world.time)
		switch(type)
			if("Burn")
				// fevExplosion
				var/obj/Effects/Bang/b = new()
				b.Target = src
				vis_contents += b
				Health -= Health * (n/glob.IMPLODE_DIVISOR)
				Burn = 0
			if("Chill")
				var/obj/Effects/Freeze/b = new(overwrite_alpha = 255)
				b.Target = src
				vis_contents += b
				if(StunImmune)
					StunImmune = 0
				Stun(src, 4)
				passive_handler.Set("Shellshocked", 1)
				Slow = 0


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

