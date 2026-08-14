//everything a hit needs to know about itself
/strike
	var/mob/attacker
	var/mob/defender
	var/val = 0
	var/unarmed = 0
	var/sword = 0
	var/second = 0
	var/third = 0
	var/tmult = 0
	var/spirit = 0
	var/destructive = 0
	var/autohit = 0
	var/lifesteal = 0
	var/special = 0
	var/element = null
	var/melee = 0
	var/pierce = 0
	var/list/dmgTypes = null
	var/critEff = 1
	var/blockEff = 1
	var/critBonus = 0
	var/tmp/critChance = 0
	var/tmp/didCrit = 0
	var/tmp/didBlock = 0
	var/tmp/dealt = 0 //final damage after everything - what the hooks see
	New(mob/a, mob/d, v)
		attacker = a
		defender = d
		val = v
	proc/resolve()
		return attacker.ResolveStrike(src)

//point for saga/race mechanics, register from your own file, keep out of the core
/strikeHook
	var/stage = "post" //"crit" fires on critical hits, "post" fires after every resolved strike
	proc/fire(strike/S)

var/list/strikeHooksCrit
var/list/strikeHooksPost
/proc/fireStrikeHooks(stage, strike/S)
	if(!strikeHooksPost)
		strikeHooksCrit = list()
		strikeHooksPost = list()
		for(var/T in subtypesof(/strikeHook))
			var/strikeHook/H = new T
			if(H.stage == "crit")
				strikeHooksCrit += H
			else
				strikeHooksPost += H
	for(var/strikeHook/H as anything in (stage == "crit" ? strikeHooksCrit : strikeHooksPost))
		H.fire(S)

mob
	proc
		DoDamage(mob/defender, val)
			var/strike/S = new(src, defender, val)
			return ResolveStrike(S)
		ResolveStrike(strike/S)
			var/mob/defender = S.defender
			var/val = S.val
			var/UnarmedAttack = S.unarmed
			var/SwordAttack = S.sword
			var/SecondStrike = S.second
			var/ThirdStrike = S.third
			var/TrueMult = S.tmult
			var/SpiritAttack = S.spirit
			var/Destructive = S.destructive
			var/Autohit = S.autohit
			var/innateLifeSteal = S.lifesteal
			var/atkSpecialFlag = S.special
			var/atkSpellElem = S.element
			var/atkMeleePipe = S.melee
			var/PierceGuard = S.pierce
			#if DEBUG_DAMAGE
			log2text("Damage", "Start DoDamage", "damageDebugs.txt", src.ckey)
			log2text("Damage", val, "damageDebugs.txt", src.ckey)
			#endif
			val = newDoDamage(defender, val, UnarmedAttack, SwordAttack, SecondStrike, ThirdStrike, TrueMult, SpiritAttack, Destructive, Autohit, dmgTypes = S.dmgTypes, S = S)
			if(defender == src)
				return val //DamageSelf already handled it - the tail is for hitting OTHER people
			DEBUGMSG("val after newDoDamage [val]")
			// Devil Summoner: Knight/Paladin/Hero Soul redirects part of the damage to the active demon
			if(defender && defender.demon_active && defender.demon_soul_dmg_pct > 0 && istype(defender.demon_active, /mob/Player/AI/Demon))
				var/mob/Player/AI/Demon/_ds_d = defender.demon_active
				if(_ds_d && _ds_d.demon_hp > 0 && src != _ds_d)
					var/orig_val = val
					val = round(val * (1 - defender.demon_soul_dmg_pct))
					var/demon_takes = max(1, round(orig_val * defender.demon_soul_transfer_pct))
					_ds_d.demon_hp = max(0, _ds_d.demon_hp - demon_takes)
					var/datum/party_demon/_ds_pd = _ds_d.DemonGetPartyDemon()
					if(_ds_pd) _ds_pd.current_hp = _ds_d.demon_hp
					if(defender.client)
						defender << "<font color='#aaccff'>[_ds_d.name] absorbs [demon_takes] damage in your stead!</font>"
					if(_ds_d.demon_hp <= 0)
						_ds_d.DemonDespawn()
			if(src.HasPurity())//If damager is pure
				var/found=0//Assume you haven't found a proper target
				if(defender.IsEvil()||src.HasBeyondPurity())
					DEBUGMSG("[defender] is evil or [src] has beyond purity")
					found=1
				if(!found)//If you don't find what you're supposed to hunt
					DEBUGMSG("[src] is attacking a pure target and so value is set to 0")
					val = 0;
			if(defender && defender.passive_handler["RoyalGuarding"])
				var/obj/Skills/Buffs/SlotlessBuffs/RoyalGuard/RG = locate(/obj/Skills/Buffs/SlotlessBuffs/RoyalGuard) in defender.contents
				if(RG)
					defender << "<font color= 'green'>ATTACK PARRIED!</font>"
					RG.SuccessfulParry = 2
					var/masteryMult = 1 + ((RG.Mastery - 1) / 100)
					var/meterGain = max((val * masteryMult) * glob.ROYAL_GUARD_CHARGE_MULT , 1)
					RG.RoyalMeter = min(RG.RoyalMeter + meterGain, 100+(RG.Mastery-1))
					val = 0
					defender.client.updateRGMeter()
			//guard: front-arc DR + meter chip + corner carry. behind/pierce/self skip it
			if(defender && val > 0 && src != defender)
				if(defender.IsGuarding() && !PierceGuard && !getBackSide(src, defender))
					defender.GuardMeter += glob.GUARD_METER_FLAT + val * glob.GUARD_METER_SCALE
					val *= (1 - glob.GUARD_DR)
					defender.PmDashStep(src, glob.GUARD_PUSHBACK_PX, away = 1)
					if(defender.GuardMeter >= glob.GUARD_METER_MAX)
						defender.GuardStop(broken = 1)
						src.FlourishArm()
				else if(defender.IsGuardBroken())
					val *= glob.GUARD_BREAK_DMG_AMP
			//charging through hits: three's the limit
			if(defender && defender.IsChargingEnergy() && val > 0 && src != defender)
				defender.charge_hits_taken++
				if(defender.charge_hits_taken >= glob.CHARGE_BREAK_HITS)
					defender.ChargeStop()
					defender.charge_lockout_until = world.time + glob.TIMING_WINDOW
			if(val==0)
				DEBUGMSG("val is 0 so we're ending dodamage now")
				return 0;

			if(src != defender)
				var/reflectMakarakarn = defender.demon_makarakarn_until > world.time && (atkSpecialFlag || atkSpellElem)
				var/reflectTetrakarn  = defender.demon_tetrakarn_until > world.time && atkMeleePipe
				if(reflectMakarakarn || reflectTetrakarn)
					var/reflected = val
					var/barrier = reflectTetrakarn ? "Tetrakarn" : "Makarakarn"
					OMsg(defender, "<font color='#88ddff'>[defender]'s [barrier] reflects the attack back at [src]!</font>")
					src.LoseHealth(reflected)
					return 0

			if(src.isLunaticMode())
				src.InflictLunacy(val, defender);

			fieldAndDefense(defender, UnarmedAttack, SwordAttack, SpiritAttack, val)

			defender.determinationSoulRegen()
			if(src.HasSoftStyle())
				defender.GainFatigue(val*clamp(glob.SOFT_STYLE_RATIO*src.GetSoftStyle(), 0.0001, 0.5))
			if(src.HasHardStyle())
				if(!src.CursedWounds())
					src.DealWounds(defender, val*clamp(glob.HARD_STYLE_RATIO*src.GetHardStyle(), 0.0001, 0.75))
			if(src.HasCyberStigma())
				if(defender.CyberCancel||defender.Mechanized)
					defender.LoseMana(val*max(defender.Mechanized,defender.CyberCancel)*src.GetCyberStigma())

			if(defender.passive_handler["Dim Mak"]>0)
				defender.passive_handler.Increase("Dim Mak", val/2)
			handlePostDamage(defender)
			if(defender.VaizardHealth)
				if(glob.SYMBIOTE_DMG_TEST && CheckSlotless("Symbiote Infection"))
					val *= glob.SYMBIOTE_DMG_TEST
				defender.VaizardHealth-=val
				if(defender.VaizardHealth<=0)
					if(defender.ActiveBuff)
						if(defender.ActiveBuff.VaizardShatter)
							defender.ActiveBuff.Trigger(defender)
					if(defender.SpecialBuff)
						if(defender.SpecialBuff.VaizardShatter)
							defender.SpecialBuff.Trigger(defender)
					for(var/sb in defender.SlotlessBuffs)
						var/obj/Skills/Buffs/SlotlessBuffs/b = defender.SlotlessBuffs[sb]
						if(b)
							if(b.VaizardShatter)
								b.Trigger(defender)
					if(defender.VaizardHealth<0)
						val=((-1)*defender.VaizardHealth)
						defender.VaizardHealth=0
				else
					var/PD=src.passive_handler.Get("Piercing") //don't make this over 1. if anyone makes it over 1 i will kill them. hell, if anyone makes it equal to 1 i will also kill you. i swear to go. unless it's me, then it's okay. d
					if(src.passive_handler.Get("Determination(Black)"))
						val/=4
					else if(src.passive_handler.Get("Piercing"))
						val*=PD
					else
						val=0

			if(defender.BioArmor)
				defender.BioArmor-=val
				if(defender.BioArmor<0)
					val=(-1)*defender.BioArmor
					defender.BioArmor=0
				else
					val=0

			if(defender.AngerAdvance(val))
				val/=defender.AngerMax

			if((defender.passive_handler.Get("Persistence") || defender.hasDeterminationDesperation()) && !defender.HasInjuryImmune())
				if(FightingSeriously(src,defender))
					//a slice of every hit lands as wounds instead of health - no more coin flips
					var/desp = clamp(defender.passive_handler.Get("Persistence"), 0.1, glob.MAX_PERSISTENCE_CALCULATED)
					desp += defender.getDeterminationPersistenceBonus()
					var/woundShare = min(desp*glob.PERSISTENCE_CHANCE, 100) / 100
					var/despDiv = clamp(desp, 1, glob.PRESISTENCE_DIVISOR_MAX)
					defender.WoundSelf((val*woundShare)/sqrt(1+despDiv))
					val *= (1 - woundShare)

			if(defender.KO&&!src.Lethal)
				val=0

			if(defender.CheckSpecial("Kamui Unite") && defender.passive_handler.Get("GodKi") < 1)
				if(defender.Health<=10)
					defender.TotalInjury=0
					defender.TotalFatigue=0
					defender.Health += (50 * (1 - defender.passive_handler.Get("GodKi")))
					defender.Energy += (50 * (1 - defender.passive_handler.Get("GodKi")))
					defender.BPPoison=1
					defender.passive_handler.Increase("GodKi", 0.25)
					OMsg(defender, "<font color='red'><font size=+2>[defender] stitches themselves back together with life fibers!</font size></font color>")


			if(istype(defender, /mob/Player/AI))

				var/mob/Player/AI/aa = defender
				if(!istype(src, /mob/Player/AI))
					if(aa.ai_hostility >= 1)
						if(aa.inloop == FALSE && !(aa in ticking_ai) && !(aa in companion_ais))
							ticking_ai.Add(aa)
						aa.SetTarget(src)
						aa.ai_state = "Chase"
						aa.last_activity = world.time

			if(defender.CheckSlotless("Crystal Wall"))
				src.LoseHealth(val)
				return 0;


			if(getBackSide(src, defender) && passive_handler["Backshot"])
				val *= 1 + (passive_handler["Backshot"]/10)



			if(passive_handler["CoolingDown"])
				StyleBuff?:hotCold = clamp(StyleBuff?:hotCold - val * glob.HOTNCOLD_MODIFIER, -100, 100)
			else if(passive_handler["HeatingUp"])
				StyleBuff?:hotCold  = clamp(StyleBuff?:hotCold + val * glob.HOTNCOLD_MODIFIER, -100, 100)
			if(passive_handler["Grit"])
				AdjustGrit("add", val*glob.racials.GRITMULT)
			if(passive_handler["BlindingVenom"] && can_use_style_effect("BlindingVenom"))
				if(client)
					var/dur = passive_handler["BlindingVenom"]*glob.VENOMBLINDMULT
					defender.flash(dur, rgb(137, 0, 161), 2)
					defender.drunkeffect(dur)
					defender.RemoveTarget()
					defender.Grab_Release()
					last_style_effect = world.time


			if(val > 0 && src.passive_handler.Get("Certain Progress"))
				if(val<0.1)
					val=0.1
			if(defender.passive_handler.Get("Certain Progress"))
				if(val>1)
					val=1
			if(val > 0 && passive_handler.Get("AbsoluteDespair"))
				if(val<0.1)
					val=0.1
			var/tmpval = val
			if(defender.key=="Vuffa" && defender.findVuffa())
				if(defender.findVuffa().vuffaMoment)
					tmpval*=1000000
					if(defender.findVuffa().vuffaMessage)
						OMsg(defender, "<font color='[rgb(255, 0, 0)]'>[defender.findVuffa().vuffaMessage]</font color>")
					else
						OMsg(src, "<font color='[rgb(255, 0, 0)]'>[defender] takes a critical hit! They take [tmpval] damage!</font color>")
				DEBUGMSG("this was a voof hit and the dmg is: [tmpval]")
				var/final_vuffa_damage = max(0,tmpval)
				defender.LoseHealth(final_vuffa_damage)
			else
				DEBUGMSG("this is the damage actually dealt: [val]")
				var/final_damage = max(0,val)
				defender.LoseHealth(final_damage);
				if(defender.passive_handler.Get("LustFactor")) defender.applySinBonusFromTakenDamage(final_damage);
				if(passive_handler.Get("LustFactor")) applySinBonusFromDealtDamage(final_damage);
				if(passive_handler.Get("WarmingUp")) applyWarmingUpFromDealtDamage(final_damage)
				if(defender.passive_handler.Get("WarmingUp")) defender.applyWarmingUpFromTakenDamage(final_damage)
				if(passive_handler.Get("SlothFactor"))
					DevilTriggerSlothBonus = 0
					LastSlothTick = world.time
				if(defender.passive_handler.Get("SlothFactor"))
					defender.DevilTriggerSlothBonus = 0
					defender.LastSlothTick = world.time

			if(S.didCrit)
				S.dealt = val
				fireStrikeHooks("crit", S)

			// Overwatch CombatLog hook — record the hit on both sides for admin review.
			if(val > 0)
				src.RecordCombatEvent("Hit [defender] for [round(val,0.1)]")
				defender.RecordCombatEvent("Hit by [src] for [round(val,0.1)]")

			ApplyFrenzyCombatHooks(defender, max(0, val), UnarmedAttack, SwordAttack, SpiritAttack)

			if(defender.Flying)
				var/obj/Items/check = defender.EquippedFlyingDevice()
				if(istype(check))
					check.ObjectUse(defender)
					defender << "You are knocked off your flying device!"



			if(UnarmedAttack || SwordAttack || SpiritAttack || Autohit)
				var/Motivation=1+defender.passive_handler.Get("Motivation")
				if(src.StyleBuff && canGainTension())
					if(!SecondStrike)
						src.gainTension(val);
				if(defender && defender.StyleBuff && defender.canGainTension())
					if(!SecondStrike)
						defender.gainTension((val*Motivation)*glob.DEFENDER_TENSION_REDUCER);
						if(defender.Health<src.Health && defender.passive_handler.Get("SpiralPowerUnlocked"))
							defender.gainTension((val*Motivation*2)*glob.DEFENDER_TENSION_REDUCER);
			if(passive_handler.Get("Corruption"))
				gainCorruption(val * 1.5 * glob.CORRUPTION_GAIN)
			if(defender.passive_handler.Get("Corruption"))
				defender.gainCorruption(val * 0.75 * glob.CORRUPTION_GAIN)

			if(defender.HasEnergyLeak())
				defender.LoseEnergy(defender.GetEnergyLeak()*glob.LEAK_DEFENDER_RATE*val)

			if(src.HasFatigueLeak())
				src.GainFatigue(src.GetFatigueLeak()*glob.LEAK_ATTACKER_RATE*val)
			if(defender.HasFatigueLeak())
				defender.GainFatigue(defender.GetFatigueLeak()*glob.LEAK_DEFENDER_RATE*val)

			if(src.HasManaLeak())
				src.LoseMana(src.GetManaLeak()*glob.LEAK_ATTACKER_RATE*val, 1)
			if(defender.HasManaLeak())
				defender.LoseMana(defender.GetManaLeak()*glob.LEAK_DEFENDER_RATE*val, 1)

			if(src.HasBleedHit())
				src.WoundSelf(src.GetBleedHit()*glob.RECOIL_RATE*val)
			if(src.HasBurnHit())
				src.AddBurn(src.GetBurnHit()*glob.RECOIL_RATE*val, src)
			if(src.passive_handler.Get("Ashen One"))
				src.AddBurn(passive_handler.Get("Kindling"), src)
			if(src.Kaioken)
				src.HandleKaiokenTax()
			//If you are burned and have debuff reversal, smack fire into the other fighter
			var/debuffRev = src.GetDebuffReversal();
			if(src.Burn && debuffRev)
				defender.AddBurn(src.Burn/50*debuffRev, src);
			//Same for poison
			if(src.Poison && debuffRev)
				defender.AddPoison(src.Poison/50*debuffRev, src);


			var/mortalStrike = GetMortalStrike()
			if(mortalStrike > 0  && FightingSeriously(src, 0))
				if(val > clamp(6 / mortalStrike, 3, 20) && prob(25 * mortalStrike))
					if(!defender.MortallyWounded) // the last time, plus the timer
						defender.MortallyWounded += 1
						var/dmg = defender.Health * 0.15
						defender.LoseHealth(dmg)
						defender.WoundSelf(dmg)
						OMsg(defender, "<font color='red'><font size=+2><b>[src] mortally wounded [defender] with a devistating attack!</b></font size></font color>")
			if(passive_handler.Get("Gluttony") && FightingSeriously(src, 0))
				var/amount = val * (passive_handler.Get("Gluttony") * SpecialBuff:hungerMult)
				defender.LoseMana(amount/2)
				defender.LoseCapacity(amount/2)
				SpecialBuff:eatEnergies(amount * 10)
				defender.TotalFatigue+=amount/2
				Update_Stat_Labels()




			var/soulfire = GetSoulFire();
			if(soulfire)
				if(!(defender.CyberCancel || defender.Mechanized))
					defender.LoseCapacity(val*soulfire*glob.SOUL_FIRE_FATIGUE_RATIO)
				defender.LoseMana(val*(soulfire*glob.SOUL_FIRE_MANA_RATIO))
				defender.TotalFatigue+=(val*soulfire*glob.SOUL_FIRE_FATIGUE_RATIO)

			if(defender.CheckSlotless("Protega"))
				src.LoseHealth(val/10)
			if(painShared)
				applyPainSharedDamage(val)
			if(defender.passive_handler.Get("MeltyBlood"))
				if(defender.Health<50*(1-src.HealthCut))
					if(FightingSeriously(src,0))
						if(!defender.MeltyMessage)
							defender.MeltyMessage=1
							OMsg(defender, "<font color='red'>[defender]'s blood burns through all it comes in contact with!</font>")
						src.AddBurn(val * (1 + defender.passive_handler.Get("MeltyBlood")), defender)
			if(defender.passive_handler.Get("VenomBlood"))
				if(defender.Health<50*(1-src.HealthCut))
					if(FightingSeriously(src,0))
						if(!defender.VenomMessage)
							defender.VenomMessage+=1
							OMsg(defender, "<font color='red'>[defender]'s toxic blood sprays out!</font>")
						src.AddPoison(val* (1 + defender.passive_handler.Get("VenomBlood")), defender)



			// ADD HERE THE FUCKING FUTURE DIARY SHIT
			if(src.HasWeaponBreaker()||defender.Saga=="Unlimited Blade Works")
				if((defender.HasSword()||defender.HasStaff()||defender.HasArmor())&&(UnarmedAttack||SwordAttack))
					var/obj/Items/Sword/s=defender.EquippedSword()
					var/obj/Items/Enchantment/Staff/st=defender.EquippedStaff()
					var/obj/Items/Armor/ar=defender.EquippedArmor()
					// Equip
					var/shatterTier = defender.GetShatterTier(s) // isn't even used i think
					var/addWeaponBreaker = 0
					if(AttackQueue&&AttackQueue.WeaponBreaker)
						addWeaponBreaker += AttackQueue.WeaponBreaker
					var/breakTicks = ((GetWeaponBreaker()+addWeaponBreaker) / glob.WEAPON_BREAKER_DIVISOR) * glob.WEAPON_BREAKER_EFFECTIVENESS
					var/duraBoon = glob.WEAPON_ASC_DURA_BOON // SWORD DURA VARS
					var/duraBase = 1 // SWORD DURA VARS
					// Breaker Vars
					var/SwordQuality
					var/StaffQuality
					var/ArmorQuality

					if(s)
						SwordQuality=min(s.Ascended+defender.GetSwordAscension(),6)
					if(st)
						StaffQuality=min(st.Ascended+defender.GetStaffAscension(),6)
					if(ar)
						ArmorQuality=min(ar.Ascended+defender.GetArmorAscension(),6)

					if(defender.UsingKendo()&&defender.HasSword())
						if(s.Class=="Wooden")
							SwordQuality+=1
						if(src.StyleActive=="Shinzan")
							SwordQuality+=3
						if(SwordQuality > 7)
							SwordQuality=7



					if(s)
						if(s.Destructable)
							s.startBreaking(val, breakTicks+shatterTier / ((duraBoon * SwordQuality) + duraBase), defender, src, "sword")
					if(st)
						if(st.Destructable)
							st.startBreaking(val, breakTicks / ((duraBoon * StaffQuality) + duraBase), defender, src, "staff")
					if(ar)
						if(ar.Destructable)
							ar.startBreaking(val, breakTicks / ((duraBoon * ArmorQuality) + duraBase), defender, src, "armor")

					if(defender.EquippedSecondSword())
						var/obj/Items/Sword/s2=defender.EquippedSecondSword()
						var/Sword2Quality=min(s2.Ascended+defender.GetSwordAscension(),6)
						if(s2&&s2.Destructable)
							s.startBreaking(val, breakTicks / ((duraBoon * Sword2Quality) + duraBase), defender, src, "sword")
					if(defender.EquippedThirdSword())
						var/obj/Items/Sword/s3=defender.EquippedThirdSword()
						var/Sword3Quality=min(s3.Ascended+defender.GetSwordAscension(),6)
						if(s3&&s3.Destructable)
							s.startBreaking(val, breakTicks / ((duraBoon * Sword3Quality) + duraBase), defender, src, "sword")

			if(defender.HasLifeGeneration())
				defender.HealHealth(defender.GetLifeGeneration()/glob.LIFE_GEN_DIVISOR * val)
				if(defender.Health>=100-100*defender.HealthCut-defender.TotalInjury)
					defender.HealWounds((defender.GetLifeGeneration() / glob.LIFE_GEN_DIVISOR * glob.WOUND_RECOVERY_REDUCTION * val))
			if(HasEnergyGeneration())
				var/gen = GetEnergyGeneration()/glob.ENERGY_GEN_DIVISOR;
				HealEnergy(gen);
				HealFatigue(gen/2);
			if(HasManaGeneration())
				HealMana(src.GetManaGeneration()/glob.MANA_GEN_DIVISOR);
			if(defender.DownToEarth)
				var/gen=5/glob.ENERGY_GEN_DIVISOR;
				HealEnergy(gen);
				HealFatigue(gen/2);
				HealMana(5/glob.MANA_GEN_DIVISOR);

			if(src.ActiveBuff&&src.CheckActive("Keyblade")&&!src.SpecialBuff)
				src.ManaAmount+=(0.25*src.SagaLevel)
			if(defender.ActiveBuff&&defender.CheckActive("Keyblade")&&!defender.SpecialBuff)
				defender.ManaAmount+=(0.25*defender.SagaLevel)

			if(src.HasHellPower()&&!src.transActive())
				src.HealMana(1)
			if(defender.HasHellPower()&&!src.transActive())
				defender.HealMana(1)

			if(src.SlotlessBuffs)
				if(src.CheckSlotless("Frost End"))
					if(SwordAttack&&defender.Stunned)
						defender.overlays+='IceCoffin.dmi'
				if(src.CheckSlotless("AntiForm"))
					src.ManaAmount-=1
					if(src.ManaAmount<0)
						ManaAmount=0
				if(defender.CheckSlotless("OverSoul")&&defender.BoundLegend=="Caledfwlch")
					if(!defender.Shielding)
						defender.Shielding=1
						spawn()
							defender.AvalonField()

			if(src.HasSoulSteal())
				var/Amt=val*src.GetSoulSteal()
				var/Cap=15*src.GetSoulSteal()
				src.VaizardHealth+=Amt
				if(src.VaizardHealth>Cap)
					src.VaizardHealth=Cap



			if(src.HasLifeSteal()&&!SecondStrike || innateLifeSteal&&!SecondStrike)
				var/CursedBlood=0
				var/NoBlood=0
				NoBlood=defender.CyberCancel
				if(defender.isRace(ANDROID)||defender.isRace(ELDRITCH)||defender.Secret=="Zombie"||defender.Dead)
					NoBlood=1
				var/Effectiveness=1
				if(NoBlood>0)
					Effectiveness-=(Effectiveness*NoBlood)
				if(defender.ActiveBuff && defender.ActiveBuff.BuffName == "Life Fiber Synchronize")
					Effectiveness = max(0, Effectiveness + min(0,4 - defender.SagaLevel))
				if(defender.passive_handler.Get("MeltyBlood") && NoBlood<1)
					CursedBlood=1
					Effectiveness += defender.passive_handler.Get("MeltyBlood")
					src.AddBurn(val*Effectiveness)
					val/=2
				if(defender.passive_handler.Get("VenomBlood"))
					CursedBlood=1
					Effectiveness+= defender.passive_handler.Get("VenomBlood")
					src.AddPoison(val*Effectiveness,defender)
				if(defender.Secret=="Hamon")
					src.AddBurn(val*Effectiveness*defender.secretDatum.currentTier)
					val/=max(1,defender.secretDatum.currentTier)
				if(!CursedBlood)
					var/amtHeal = val*(src.GetLifeSteal() + innateLifeSteal)*Effectiveness/100;
					if(src.passive_handler.Get("Undying Rage"))
						src.LifeStolen=0
					amtHeal*=1*((100-src.LifeStolen)/100)
					src.HealHealth(amtHeal)
					if(defender.passive_handler.Get("The Inkstone") && src.LifeStolen>=50)
						if(!src.passive_handler.Get("The Power of Stories"))
							OMsg(src, "<b><font size=+3> [src] erupts with tremendous power, having stolen enough life from the Narrative to temporarily match it!")
							src.passive_handler.Increase("The Power of Stories", 1)
					src.LifeStolen+=amtHeal/2
					if(passive_handler.Get("TrueAbsorb") && src.LifeStolen>=25)
						src.LifeStolen=25
					if(src.LifeStolen>=95)
						src.LifeStolen=95
					DEBUGMSG("[amtHeal] was healed by life steal");
					if(src.Health>=(100-100*src.HealthCut-src.TotalInjury))
						src.HealWounds(val*(src.GetLifeSteal() + innateLifeSteal)*Effectiveness / 100 * glob.WOUND_RECOVERY_REDUCTION)
			if(src.HasLifeStealTrue())
				defender.AddHealthCut(val/200)
				if(defender.HealthCut>=0.15)
					defender.HealthCut=0.15
				src.HealthCut-=(val/100)
				if(src.HealthCut<=0)
					src.HealthCut=0
			if(src.HasEnergySteal())
				src.HealEnergy(val*(src.GetEnergySteal() / 100))
				defender.LoseEnergy(val*(src.GetEnergySteal() / 100))
			if(HasManaSteal())
				var/value = val * (GetManaSteal() / 100)
				HealMana(value)
				defender.LoseMana(value)



			if(src.HasErosion())
				var/Erosion = (src.GetErosion()/4)
				var/MPow=defender.Power_Multiplier/8
				var/BPCap=Erosion
				var/MStr=defender.GetStrMult()
				var/StrCap=Erosion
				var/MEnd=defender.GetEndMult()
				var/EndCap=Erosion
				var/MSpd=defender.GetSpdMult()
				var/SpdCap=Erosion
				var/MFor=defender.GetForMult()
				var/ForCap=Erosion
				var/MOff=defender.GetOffMult()
				var/OffCap=Erosion
				var/MDef=defender.GetDefMult()
				var/DefCap=Erosion
				var/MRecov=defender.GetRecovMult()
				var/RecovCap=Erosion
				if(MPow>0)
					defender.PowerEroded+=(BPCap/glob.EROSION_RATE_DIVISOR)*val
					if(defender.PowerEroded>BPCap)
						defender.PowerEroded=BPCap
				if(MStr>=1)
					defender.StrEroded+=(StrCap/glob.EROSION_RATE_DIVISOR)*val
					if(defender.StrEroded>StrCap)
						defender.StrEroded=StrCap
				if(MEnd>=1)
					defender.EndEroded+=(EndCap/glob.EROSION_RATE_DIVISOR)*val
					if(defender.EndEroded>EndCap)
						defender.EndEroded=EndCap
				if(MSpd>=1)
					defender.SpdEroded+=(SpdCap/glob.EROSION_RATE_DIVISOR)*val
					if(defender.SpdEroded>SpdCap)
						defender.SpdEroded=SpdCap
				if(MFor>=1)
					defender.ForEroded+=(ForCap/glob.EROSION_RATE_DIVISOR)*val
					if(defender.ForEroded>ForCap)
						defender.ForEroded=ForCap
				if(MOff>=1)
					defender.OffEroded+=(OffCap/glob.EROSION_RATE_DIVISOR)*val
					if(defender.OffEroded>OffCap)
						defender.OffEroded=OffCap
				if(MDef>=1)
					defender.DefEroded+=(DefCap/glob.EROSION_RATE_DIVISOR)*val
					if(defender.DefEroded>DefCap)
						defender.DefEroded=DefCap
				if(MRecov>=1)
					defender.RecovEroded+=(RecovCap/glob.EROSION_RATE_DIVISOR)*val
					if(defender.RecovEroded>RecovCap)
						defender.RecovEroded=RecovCap


			//covers the six core stats. Power/Recov theft has no plumbing - deliberate
			if(passive_handler.Get("StealsStats")||src.ElementalOffense=="Void")
				var/Effective=1
				if(passive_handler.Get("StealsStats"))
					Effective*=passive_handler.Get("StealsStats")
				var/MStr=defender.GetStrMult()
				var/MEnd=defender.GetEndMult()
				var/MSpd=defender.GetSpdMult()
				var/MFor=defender.GetForMult()
				var/MOff=defender.GetOffMult()
				var/MDef=defender.GetDefMult()
				if(MStr>1)
					if(src.StrStolen<(MStr-1))
						src.StrStolen+=(((MStr-1)*glob.STAT_STEAL_RATE*Effective)*val)
						if(src.StrStolen>(MStr-1))
							src.StrStolen=(MStr-1)
				if(MEnd>1)
					if(src.EndStolen<(MEnd-1))
						src.EndStolen+=(((MEnd-1)*glob.STAT_STEAL_RATE*Effective)*val)
						if(src.EndStolen>(MEnd-1))
							src.EndStolen=(MEnd-1)
				if(MSpd>1)
					if(src.SpdStolen<(MSpd-1))
						src.SpdStolen+=(((MSpd-1)*glob.STAT_STEAL_RATE*Effective)*val)
						if(src.SpdStolen>(MSpd-1))
							src.SpdStolen=(MSpd-1)
				if(MFor>1)
					if(src.ForStolen<(MFor-1))
						src.ForStolen+=(((MFor-1)*glob.STAT_STEAL_RATE*Effective)*val)
						if(src.ForStolen>(MFor-1))
							src.ForStolen=(MFor-1)
				if(MOff>1)
					if(src.OffStolen<(MOff-1))
						src.OffStolen+=(((MOff-1)*glob.STAT_STEAL_RATE*Effective)*val)
						if(src.OffStolen>(MOff-1))
							src.OffStolen=(MOff-1)
				if(MDef>1)
					if(src.DefStolen<(MDef-1))
						src.DefStolen+=(((MDef-1)*glob.STAT_STEAL_RATE*Effective)*val)
						if(src.DefStolen>(MDef-1))
							src.DefStolen=(MDef-1)

			if(FightingSeriously(src,0))
				var/WoundsInflicted
				var/obj/Items/Sword/s=src.EquippedSword()
				var/obj/Items/Enchantment/Staff/st=src.EquippedStaff()
				if(src.CursedWounds())
					if(defender.UsingMuken())
						WoundsInflicted=val/defender.GetEnd()
					else
						if(defender.GetEnd(glob.CURSED_WOUNDS_RATE) < 2)
							WoundsInflicted=val/(1+defender.GetEnd(glob.CURSED_WOUNDS_RATE)) // was reading the attacker's End
						else
							WoundsInflicted=val/defender.GetEnd(glob.CURSED_WOUNDS_RATE)
				else if(src.HasPurity()&&defender.IsEvil()||HasPurity()&&HasBeyondPurity())
					WoundsInflicted=val
				else if(s||st)
					if(((s&&s.Element=="Silver")||(st&&st.Element=="Silver"))&&defender.IsEvil())
						WoundsInflicted=val/defender.GetEnd(glob.CURSED_WOUNDS_RATE)
					else if(src.SwordWounds())
						WoundsInflicted = val * glob.WOUND_RATE * (1 + GetSwordDamage(s)*glob.SWORD_WOUND_SCALE) * (glob.STRIKE_MITIGATION_K/(glob.STRIKE_MITIGATION_K + defender.GetEnd(1)))
					else
						WoundsInflicted = val * glob.WOUND_RATE * (glob.STRIKE_MITIGATION_K/(glob.STRIKE_MITIGATION_K + defender.GetEnd(1)))
				else
					WoundsInflicted = val * glob.WOUND_RATE * (glob.STRIKE_MITIGATION_K/(glob.STRIKE_MITIGATION_K + defender.GetEnd(1)))
				if(WoundsInflicted<0)
					WoundsInflicted=0
				if(WoundsInflicted > val)
				//	world.log << "[src] vs [defender] wonds([WoundsInflicted]) inflict was over val([val])"
					WoundsInflicted = val
				src.DealWounds(defender, WoundsInflicted)

			if(isplayer(defender))
				defender:move_speed = defender.MovementSpeed()
			if(isplayer(src))
				src:move_speed = MovementSpeed()

			if(defender.Health<=0&&Destructive>0)
				defender.Death(src, "being completely obliterated!", SuperDead=1, NoRemains=2)
				S.dealt = val
				fireStrikeHooks("post", S)
				return val


			if(defender.KO && istype(defender, /mob/Player/AI))
				var/mob/Player/AI/a = defender
				if(!a.ai_owner)
					a.Death(src, null)
					if(src.Frozen)
						src.Frozen=0
					S.dealt = val
					fireStrikeHooks("post", S)
					return val
			if(defender.Health<=0&&!defender.KO)
				defender.Unconscious(src)
				if(passive_handler.Get("Twisted Sentimentality") && defender.client)
					defender.client.PlaySwoon()
					defender.Maimed+=1
					defender.recordMaim(src, "Combat")
					OMsg(defender, "<font color='red'><font size=+2><b>[defender] got maimed by [src] and couldn't fight anymore...</b></font size></font color>")
			else if(defender.KO&&src.Lethal)
				if(istype(EquippedSword(), /obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin))
					if(defender.client)
						var/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin/bor=EquippedSword()
						bor.onKill(src, defender)
				if(src.isRace(DEMON)||src.oozaru_type=="Demonic"&&src.transActive)
					defender<<"Your soul has been irrevocably corrupted, a peaceful afterlife eternally torn from you."
					defender.Damned=1
				defender.Death(src, null)
			if(defender.passive_handler.Get("The Inkstone")&&defender.passive_handler.Get("AbsoluteDespair"))
				if(prob(2)&& defender.BioArmor)
					OMsg(src, "<b><font color='green'><font size=+1>[src] lands a decisive strike! A crack in [defender]'s armor appears!</font color></font size></b>")
					defender.BioArmor*=0.995
					defender.BioArmor-=5
					if(defender.BioArmor<0)
						defender.BioArmor=0




			S.dealt = val
			fireStrikeHooks("post", S)

			return val

