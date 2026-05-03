#define GLOBAL_LEAK_REDUCTION 1.2
#define isplayer(x) istype(x,/mob/Players)

// Was previously in MajinAscensions.dm
/mob/proc/prompt(message, title, list/options)
	if(!islist(options)) return null
	return input(src, message, title) in options

/globalTracker/var/DEBUFF_EFFECTIVENESS = 0.004

/mob/var/AbsorbingDamage = 0
/mob/var/transGod = 0
/mob/var/tmp/DevilTriggerSinDamageBonus = 0
/mob/var/tmp/DevilTriggerSlothBonus = 0
/mob/var/tmp/DevilTriggerEnvyMirrorPending = 0
/mob/var/tmp/LastSlothTick = 0
/mob/var/tmp/list/tmp_removed_ssj_forms = list()
/mob/var/list/removed_ssj_forms = list()

mob
	proc

		AscAvailable()
			src.potential_ascend(Silent=1)
			if(race.ascensions.len==0) return
			//If a prompt is already open from a prior call (e.g. spammed Meditate),
			//bail — otherwise race subclass onAscension overrides re-apply their passive Increase() calls
			//each time we re-enter before the parent's pickingChoice guard is reached.
			for(var/ascension/pending in race.ascensions)
				if(pending.pickingChoice) return
			for(var/a in race.ascensions)
				var/ascension/asc = a//applied is checked in checkAscensionUnlock; it does not need to be checked for here
				if(!asc.checkAscensionUnlock(src,Potential)) continue
				asc.onAscension(src)
				while(asc.pickingChoice) sleep(world.tick_lag)//wait for the choice before continuing

		CheckRevert()
			for(var/a in race.ascensions)
				var/ascension/asc = a
				asc.revertAscension(src)

		DamageSelf(var/val, trueDmg)
			if(val < 0)
				val = 0.015
			if(src.Health-val<=src.AngerPoint*(1-src.HealthCut))
				if(!src.Anger&&!src.HasCalmAnger()&&!src.HasNoAnger()&&!src.AngerCD&&!src.HasLunarAnger())
					src.Anger()
					val/=src.AngerMax
			if(src.VaizardHealth)
				src.VaizardHealth-=val
				if(src.VaizardHealth<=0)
					if(src.ActiveBuff)
						if(src.ActiveBuff.VaizardShatter)
							src.ActiveBuff.Trigger(src)
					if(src.SpecialBuff)
						if(src.SpecialBuff.VaizardShatter)
							src.SpecialBuff.Trigger(src)
					for(var/sb in SlotlessBuffs)
						var/obj/Skills/Buffs/SlotlessBuffs/b = SlotlessBuffs[sb]
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
			if(src.BioArmor)
				src.BioArmor-=val
				if(src.BioArmor<=0)
					val=(-1)*src.BioArmor
					src.BioArmor=0
				else
					val=0
			var/persistence = passive_handler["Persistence"]
			if(passive_handler["Determination(Orange)"]||passive_handler["Determination(White)"])
				persistence+=ManaAmount/20
			if(prob(persistence * glob.PERSISTENCE_CHANCE_SELF)&&!HasInjuryImmune())
				if(glob.PERSISTENCE_DIVIDES_DAMAGE)
					var/clamped = clamp(persistence, glob.PRESISTENCE_DIVISOR_MIN, glob.PRESISTENCE_DIVISOR_MAX)
					WoundSelf(val/clamped)
				else
					WoundSelf(val)
				if(glob.PERSISTENCE_NEGATES_DAMAGE)
					val = 0
			src.Health-=val
			if(src.CursedWounds())
				src.WoundSelf(val)
			if(src.Health<=0&&!src.KO)
				if(src.passive_handler.Get("Color of Courage")&& src.Health>glob.TRIPLEHELIX_MAX_NEG_HP)
					return
				if(src.Burn&&src.Poison)
					src.Unconscious(null, "succumbing to terrible pain!")
				if(src.Burn&&!src.Poison)
					src.Unconscious(null, "getting burned out!")
				if(src.Poison&&!src.Burn)
					src.Unconscious(null, "succumbing to poison!")
				if(!src.Burn&&!src.Poison)
					src.Unconscious()
		DoDamage(var/mob/defender, var/val, var/UnarmedAttack=0, var/SwordAttack=0, var/SecondStrike, var/ThirdStrike, var/AsuraStrike, var/TrueMult=0, var/SpiritAttack=0, var/Destructive=0, Autohit = FALSE, innateLifeSteal = FALSE)
			#if DEBUG_DAMAGE
			log2text("Damage", "Start DoDamage", "damageDebugs.txt", src.ckey)
			log2text("Damage", val, "damageDebugs.txt", src.ckey)
			#endif
			val = newDoDamage(defender, val, UnarmedAttack, SwordAttack, SecondStrike, ThirdStrike, AsuraStrike, TrueMult, SpiritAttack, Destructive, Autohit)
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

			if(val==0)
				DEBUGMSG("val is 0 so we're ending dodamage now")
				return 0;

			if(src.isLunaticMode())
				src.InflictLunacy(val, defender);

			fieldAndDefense(defender, UnarmedAttack, SwordAttack, SpiritAttack, val)

			if(defender.passive_handler["Determination(Purple)"] || defender.passive_handler["Determination(White)"])
				defender.HealMana(defender.SagaLevel / 60, 1)
				if(defender.ManaAmount>=100 && defender.RebirthHeroType=="Cyan"&&!defender.passive_handler["Determination(White)"])
					defender.passive_handler.Set("Determination(Green)", 1)
					defender.passive_handler.Set("Determination(Purple)", 0)
					defender<<"Your SOUL color shifts to green!"
			if(src.HasSoftStyle())
				defender.GainFatigue(val*clamp(glob.SOFT_STYLE_RATIO*src.GetSoftStyle(), 0.0001, 0.5))
			if(src.HasHardStyle())
				if(!src.CursedWounds())
					src.DealWounds(defender, val*clamp(glob.HARD_STYLE_RATIO*src.GetHardStyle(), 0.0001, 0.75))
			if(src.HasCyberStigma())
				if(defender.CyberCancel||defender.Mechanized)
					defender.LoseMana(val*max(defender.Mechanized,defender.CyberCancel)*src.GetCyberStigma())

			if(defender.passive_handler["Dim Mak"]>0)
				defender.passive_handler.Increase("Dim Mak", val)
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
					if(defender.passive_handler.Get("Determination(Black)"))
						val/=4
					else
						val=0

			if(defender.BioArmor)
				defender.BioArmor-=val
				if(defender.BioArmor<0)
					val=(-1)*defender.BioArmor
					defender.BioArmor=0
				else
					val=0

			if(defender.Health-val<=defender.AngerPoint*(1-defender.HealthCut))
				if(!defender.Anger&&!defender.HasCalmAnger()&&!defender.HasNoAnger()&&!defender.AngerCD&&!defender.HasLunarAnger())
					defender.Anger()
					val/=defender.AngerMax

			if(defender.passive_handler.Get("Persistence")&&!defender.HasInjuryImmune()||defender.passive_handler.Get("Determination(Orange)")&&!defender.HasInjuryImmune()||defender.passive_handler.Get("Determination(Orange)")&&!defender.HasInjuryImmune())
				if(FightingSeriously(src,defender))
					var/desp = clamp(passive_handler.Get("Persistence"), 0.1, glob.MAX_PERSISTENCE_CALCULATED)
					if(defender.passive_handler["Determination(Orange)"]||defender.passive_handler["Determination(White)"])
						desp+=ManaAmount/20
					if(prob(desp)*glob.PERSISTENCE_CHANCE)
						desp = clamp(desp, 1, glob.PRESISTENCE_DIVISOR_MAX)
						if(glob.PERSISTENCE_NEGATES_DAMAGE)
							defender.WoundSelf(val/sqrt(1+desp))//Take all damage as wounds
						else
							WoundSelf(val)
						val=0//but no health damage.

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


			if(getBackSide(src, defender, passive_handler["Fault Finder"]) && passive_handler["Backshot"])
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
				defender.LoseHealth(final_damage)

			// Overwatch CombatLog hook — record the hit on both sides for admin review.
			if(val > 0)
				src.RecordCombatEvent("Hit [defender] for [round(val,0.1)]")
				defender.RecordCombatEvent("Hit by [src] for [round(val,0.1)]")

			src.ApplyFrenzyCombatHooks(defender, max(0, val), UnarmedAttack, SwordAttack, SpiritAttack)

			if(defender.Flying)
				var/obj/Items/check = defender.EquippedFlyingDevice()
				if(istype(check))
					check.ObjectUse(defender)
					defender << "You are knocked off your flying device!"



			if(UnarmedAttack || SwordAttack || SpiritAttack)
				var/Motivation=1+passive_handler.Get("Motivation")
				if(src.StyleBuff && canGainTension())
					src.gainTension(val);
				if(defender && defender.StyleBuff && defender.canGainTension())
					defender.gainTension((val*Motivation)*glob.DEFENDER_TENSION_REDUCER);

			var/leakVal = val/GLOBAL_LEAK_REDUCTION
			if(passive_handler.Get("Corruption"))
				gainCorruption(val * 1.5 * glob.CORRUPTION_GAIN)
			if(defender.passive_handler.Get("Corruption"))
				gainCorruption(val * 0.75 * glob.CORRUPTION_GAIN)

			if(src.HasEnergyLeak())
				src.LoseEnergy(src.GetEnergyLeak()*0.25*leakVal)
			if(defender.HasEnergyLeak())
				defender.LoseEnergy((defender.GetEnergyLeak()*0.25*leakVal)/4)

			if(src.HasFatigueLeak())
				src.GainFatigue(src.GetFatigueLeak()*0.25*leakVal)
			if(defender.HasFatigueLeak())
				defender.GainFatigue((src.GetFatigueLeak()*0.25*leakVal)/4)

			if(src.HasManaLeak())
				src.LoseMana(src.GetManaLeak()*0.25*leakVal, 1)
			if(defender.HasManaLeak())
				defender.LoseMana((defender.GetManaLeak()*0.25*leakVal)/4, 1)

			if(src.HasBleedHit())
				src.WoundSelf(src.GetBleedHit()*0.15*leakVal)
			if(src.HasBurnHit())
				src.AddBurn(src.GetBurnHit()*0.15*leakVal, src)
			if(src.passive_handler.Get("Ashen One"))
				src.AddBurn(passive_handler.Get("Kindling"), src)

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
			if(src.HasMaimStrike()&&FightingSeriously(src, 0))
				if(val>(6*glob.WorldDamageMult/src.GetMaimStrike())&&defender.Maimed<4 && world.realtime > MaimCooldown+Day(0.75))
					defender.Maimed+=1
					defender.recordMaim(src, "Combat")
					OMsg(defender, "<font color='red'><font size=+2><b>[src] maimed [defender] with a brutal attack!</b></font size></font color>")
				else if(val>(3*glob.WorldDamageMult/src.GetMaimStrike())&&defender.Tail)
					defender.Tail=0
					OMsg(defender, "<font color='red'><font size=+2><b>[src] took off [defender]'s tail!</b></font size></font color>")
			if(passive_handler.Get("Gluttony") && FightingSeriously(src, 0))
				var/amount = val * (passive_handler.Get("Gluttony") * SpecialBuff:hungerMult)
				defender.LoseMana(amount/2)
				defender.LoseCapacity(amount/2)
				SpecialBuff:eatEnergies(amount * 10)
				defender.TotalFatigue+=amount/2
				Update_Stat_Labels()

			if(FightingSeriously(src, defender) && src.isRace(/race/demi_fiend))
				for(var/obj/Items/Magatama/M in src)
					if(M.suffix == "*Equipped*" && M.mastery < 100)
						M.gainMastery(val * 0.002)

			if(passive_handler.Get("CorruptAffected"))
				if(demon)
					demon.applyDebuffs(defender, src)


			var/soulfire = GetSoulFire();
			if(soulfire)
				if(!(defender.CyberCancel || defender.Mechanized))
					defender.LoseCapacity(val*soulfire*glob.SOUL_FIRE_FATIGUE_RATIO)
				defender.LoseMana(val*(soulfire*glob.SOUL_FIRE_MANA_RATIO))
				defender.TotalFatigue+=(val*soulfire*glob.SOUL_FIRE_FATIGUE_RATIO)

			if(defender.CheckSlotless("Protega"))
				src.LoseHealth(val/10)
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


			if(defender.Health<=defender.AngerPoint*(1-src.HealthCut)&&defender.passive_handler.Get("Defiance")&&!defender.CheckSlotless("Great Ape"))
				if(defender.Anger)
					defender.DefianceCalcs(val, src)
			if(defender.passive_handler["Shonen"]&&defender.Target)
				if(defender.Health < defender.Target.Health && Health < 50 + 5 * defender.AscensionsAcquired)
					defender.ShonenCounter+=(val * (defender.AscensionsAcquired/40)) * 1 + (defender.passive_handler["Shonen"]/5)
					if(defender.ShonenCounter>=glob.SHONENCOUNTERLIMIT)
						defender.ShonenCounter=1
						if(!defender.ShonenAnnounce)
							defender << "This is your...Moment! (No App)"
							var/obj/Skills/Buffs/s = defender.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Racial/Human/Deus_Ex_Machina)
							if(!defender.BuffOn(s))
								s.Trigger(defender, TRUE)
							defender.ShonenAnnounce=1
			if(passive_handler["Shonen"]&&defender==Target)
				if(Health < Target.Health && Health < 50 + 5 * AscensionsAcquired)
					ShonenCounter+=(val * (AscensionsAcquired/40)) * 1 + (passive_handler["Shonen"]/5)
					if(ShonenCounter>=glob.SHONENCOUNTERLIMIT)
						ShonenCounter=1
						if(!ShonenAnnounce)
							src << "This is your...Moment! (No App)"
							var/obj/Skills/Buffs/s = findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Racial/Human/Deus_Ex_Machina)
							if(!BuffOn(s))
								s.Trigger(src, TRUE)
							ShonenAnnounce=1

			if(defender.HasAdaptation()&&src==defender.Target||src.HasAdaptation()&&defender==src.Target)
				if(defender.HasAdaptation()&&!defender.CheckSlotless("Great Ape"))
					defender.AdaptationTarget=src
					var/ticks = defender.passive_handler.Get("Adaptation")
					defender.AdaptationCounter+=( val*(defender.AscensionsAcquired/40) ) * 1 + (ticks/5)
					if(defender.AdaptationCounter>=1)
						defender.AdaptationCounter=1
						if(!defender.AdaptationAnnounce)
							defender << "<b>You've adapted to your target's style!</b>"
							defender.AdaptationAnnounce=1
				if(src.HasAdaptation()&&!CheckSlotless("Great Ape"))
					src.AdaptationTarget=defender
					var/ticks = passive_handler.Get("Adaptation")
					src.AdaptationCounter+=(val*(src.AscensionsAcquired/40)) * 1 + (ticks/5)
					if(src.AdaptationCounter>=1)
						src.AdaptationCounter=1
						if(!src.AdaptationAnnounce)
							src << "<b>You've adapted to your target's style!</b>"
							src.AdaptationAnnounce=1
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

			// WEREWOLF HUNGER MECHANIC
			if(src.Secret == "Werewolf" && CheckSlotless("New Moon Form"))
				var/SecretInformation/Werewolf/s = src.secretDatum
				s.addHunger(val)
				Update_Stat_Labels()
			//END WEREWOLF HUNGER MECHANIC

			if(hasSecret("Eldritch"))
				var/SecretInformation/Eldritch/s = src.secretDatum
				s.addMadness(src,val*(s.getMadnessLimit(src)/100))
				Update_Stat_Labels()

			if(defender.hasSecret("Eldritch"))
				var/SecretInformation/Eldritch/s = defender.secretDatum
				s.addMadness(defender,val*(s.getMadnessLimit(defender)/100))
				defender.Update_Stat_Labels()

			if(src.HasLifeSteal() || innateLifeSteal)
				var/CursedBlood=0
				var/NoBlood=0
				NoBlood=defender.CyberCancel
				if(defender.isRace(ANDROID)||defender.isRace(ELDRITCH)||defender.Secret=="Zombie"||defender.Dead)
					NoBlood=1
				var/Effectiveness=1
				if(NoBlood>0)
					Effectiveness-=(Effectiveness*NoBlood)
				if(defender.ActiveBuff && defender.ActiveBuff.BuffName == "Life Fiber Synchronize")
					Effectiveness += min(0,4 - defender.SagaLevel)
				if(defender.passive_handler.Get("MeltyBlood") && NoBlood<1)
					CursedBlood=1
					Effectiveness += defender.passive_handler.Get("MeltyBlood")
					src.AddBurn(val*Effectiveness)
					val/=2
				if(defender.passive_handler.Get("VenomBlood"))
					CursedBlood=1
					Effectiveness+= defender.passive_handler.Get("VenomBlood")
					src.AddPoison(val*Effectiveness,defender)
				if(defender.Secret=="Ripple")
					src.AddBurn(val*Effectiveness*defender.secretDatum.currentTier)
					val/=defender.secretDatum.currentTier
				if(!CursedBlood)
					var/amtHeal = val*(src.GetLifeSteal() + innateLifeSteal)*Effectiveness/100;
					amtHeal*=1*((100-src.LifeStolen)/100)
					src.HealHealth(amtHeal)
					if(defender.passive_handler.Get("The Inkstone") && src.LifeStolen>=50)
						if(!src.passive_handler.Get("The Power of Stories"))
							OMsg(src, "<b><font size=+3> [src] erupts with tremendous power, having stolen enough life from the Narrative to temporarily match it!")
							src.passive_handler.Increase("The Power of Stories", 1)
					src.LifeStolen+=amtHeal/2
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

			if(dainsleifDrawn&&passive_handler.Get("CursedSheath")) // dainsleif passive
				cursedSheathValue += val
				cursedSheathValue = clamp(0, cursedSheathValue, SagaLevel*50)

			// Devil Summoner racial on-hit passives
			if(src.demon_racial_femme_active)
				src.DemonFemmeCharmCheck(defender)
			if(src.demon_racial_snake_active)
				src.DemonSnakePoisonCheck(defender)

			if(src.HasErosion())
				var/Erosion = (src.GetErosion()/4)
				var/MPow=defender.Power_Multiplier/8
				var/BPCap=MPow*Erosion
				var/MStr=defender.GetStrMult()
				var/StrCap=MStr*Erosion
				var/MEnd=defender.GetEndMult()
				var/EndCap=MEnd*Erosion
				var/MSpd=defender.GetSpdMult()
				var/SpdCap=MSpd*Erosion
				var/MFor=defender.GetForMult()
				var/ForCap=MFor*Erosion
				var/MOff=defender.GetOffMult()
				var/OffCap=MOff*Erosion
				var/MDef=defender.GetDefMult()
				var/DefCap=MDef*Erosion
				var/MRecov=defender.GetRecovMult()
				var/RecovCap=MRecov*Erosion
				if(MPow>0)
					defender.PowerEroded+=(BPCap/45)*val
					if(defender.PowerEroded>BPCap)
						defender.PowerEroded=BPCap
				if(MStr>=1)
					defender.StrEroded+=(StrCap/45)*val
					if(defender.StrEroded>StrCap)
						defender.StrEroded=StrCap
				if(MEnd>=1)
					defender.EndEroded+=(EndCap/45)*val
					if(defender.EndEroded>EndCap)
						defender.EndEroded=EndCap
				if(MSpd>=1)
					defender.SpdEroded+=(SpdCap/45)*val
					if(defender.SpdEroded>SpdCap)
						defender.SpdEroded=SpdCap
				if(MFor>=1)
					defender.ForEroded+=(ForCap/45)*val
					if(defender.ForEroded>ForCap)
						defender.ForEroded=ForCap
				if(MOff>=1)
					defender.OffEroded+=(OffCap/45)*val
					if(defender.OffEroded>OffCap)
						defender.OffEroded=OffCap
				if(MDef>=1)
					defender.DefEroded+=(DefCap/45)*val
					if(defender.DefEroded>DefCap)
						defender.DefEroded=DefCap
				if(MRecov>=1)
					defender.RecovEroded+=(RecovCap/45)*val
					if(defender.RecovEroded>RecovCap)
						defender.RecovEroded=RecovCap


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
						src.StrStolen+=(((MStr-1)*0.025*Effective)*val)
						if(src.StrStolen>(MStr-1))
							src.StrStolen=(MStr-1)
				if(MEnd>1)
					if(src.EndStolen<(MEnd-1))
						src.EndStolen+=(((MEnd-1)*0.025*Effective)*val)
						if(src.EndStolen>(MEnd-1))
							src.EndStolen=(MEnd-1)
				if(MSpd>1)
					if(src.SpdStolen<(MSpd-1))
						src.SpdStolen+=(((MSpd-1)*0.025*Effective)*val)
						if(src.SpdStolen>(MSpd-1))
							src.SpdStolen=(MSpd-1)
				if(MFor>1)
					if(src.ForStolen<(MFor-1))
						src.ForStolen+=(((MFor-1)*0.025*Effective)*val)
						if(src.ForStolen>(MFor-1))
							src.ForStolen=(MFor-1)
				if(MOff>1)
					if(src.OffStolen<(MOff-1))
						src.OffStolen+=(((MOff-1)*0.025*Effective)*val)
						if(src.OffStolen>(MOff-1))
							src.OffStolen=(MOff-1)
				if(MDef>1)
					if(src.DefStolen<(MDef-1))
						src.DefStolen+=(((MDef-1)*0.025*Effective)*val)
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
							WoundsInflicted=val/(1+GetEnd(glob.CURSED_WOUNDS_RATE))
						else
							WoundsInflicted=val/defender.GetEnd(glob.CURSED_WOUNDS_RATE)
				else if(src.HasPurity()&&defender.IsEvil()||HasPurity()&&HasBeyondPurity())
					WoundsInflicted=val
				else if(s||st)
					if(((s&&s.Element=="Silver")||(st&&st.Element=="Silver"))&&defender.IsEvil())
						WoundsInflicted=val/defender.GetEnd(glob.CURSED_WOUNDS_RATE)
					else if(src.SwordWounds())
						if(defender.GetEnd(0.5) < 2)
							WoundsInflicted=val/clamp((1 + defender.GetEnd(0.5))/max(GetSwordDamage(s),0.01), 1, 15)
						else
							WoundsInflicted= val / clamp(defender.GetEnd(0.5)/max(GetSwordDamage(s),0.01), 1, 15)
					else
						if(defender.GetEnd(0.5) < 2)
							WoundsInflicted=val/clamp(1 + defender.GetEnd(0.5), 1, 15)
						else
							WoundsInflicted=val/clamp(defender.GetEnd(0.5), 1, 15)
				else
					if(defender.GetEnd(0.5) < 2)
						WoundsInflicted=val/clamp(1 + defender.GetEnd(0.5), 1, 15)
					else
						WoundsInflicted=val/clamp(defender.GetEnd(0.5), 1, 15)
				if(WoundsInflicted<0)
					WoundsInflicted=0.001
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
				return


			if(defender.KO && istype(defender, /mob/Player/AI))
				var/mob/Player/AI/a = defender
				if(!a.ai_owner)
					a.Death(src, null)
					if(src.Frozen)
						src.Frozen=0
					return
			if(defender.Health<=0&&!defender.KO)
				defender.Unconscious(src)
			else if(defender.KO&&src.Lethal)
				if(istype(EquippedSword(), /obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin))
					if(defender.client)
						var/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin/bor=EquippedSword()
						bor.onKill(src, defender)
				if(src.isRace(DEMON)||src.oozaru_type=="Demonic"&&src.transActive)
					defender<<"Your soul has been irrevocably corrupted, a peaceful afterlife eternally torn from you."
					defender.Damned=1
				defender.Death(src, null)
			if(src.passive_handler.Get("Certain Progress"))
				if(val<0.1)
					val=0.1
			if(defender.passive_handler.Get("Certain Progress"))
				if(val>1)
					val=1
			if(passive_handler.Get("Absolute Despair"))
				if(val<0.1)
					val=0.1
			if(defender.passive_handler.Get("The Inkstone")&&defender.passive_handler.Get("Absolute Despair"))
				if(prob(2)&& defender.BioArmor)
					OMsg(src, "<b><font color='green'><font size=+1>[src] lands a decisive strike! A crack in [defender]'s armor appears!</font color></font size></b>")
					defender.BioArmor*=0.995
					defender.BioArmor-=5
					if(defender.BioArmor<0)
						defender.BioArmor=0
			if(passive_handler.Get("Ultimate Desperation"))
				val=0
				defender.Health/=10
			if(defender.passive_handler.Get("Ultimate Defense"))
				if(prob(95))
					val=0.05
			return val

		DealWounds(var/mob/defender, var/val, var/FromSelf=0)
			if(defender.CyberCancel)
				val*=(1-defender.CyberCancel)
			if(defender.BioArmor)
				return
			if(defender.HasCeramicPlating()||defender.HasPlatedWeights())
				if(defender.HasPlatedWeights())
					if(!defender.HasInjuryImmune())
						defender.TotalInjury+=val/2
					else
						defender.TotalInjury+=(val/2) * clamp(1 - defender.GetInjuryImmune(), 0, 0.99)
				else
					var/obj/Items/Plating/P=defender.EquippedPlating()
					if(P.PlatedHealth>0)
						P.PlatedHealth-=val
						if(P.PlatedHealth<0)
							if(!defender.HasInjuryImmune())
								defender.TotalInjury+=(P.PlatedHealth*(-1))
							P.PlatedHealth=0
						if(P.PlatedHealth<=0)
							defender << "<font size=+1>Your ceramic plating has been shattered!</font size>"
						P.suffix="*Broken*"
						del P
			else
				var/woundTaken = val;
				if(defender.HasInjuryImmune())
					woundTaken *= (1 - defender.GetInjuryImmune());
				defender.TotalInjury += woundTaken;

				if(!isLunaticMode() && hasSecret("Eldritch") && !FromSelf)//Attacker gains blood stock from wounds dealt
					var/SecretInformation/Eldritch/e = src.secretDatum;
					e.addBloodStock(src, woundTaken);

			if(defender.TotalInjury>=99)
				defender.TotalInjury=99
			defender.MaxHealth()
		WoundSelf(var/val)
			if(src.BioArmor && val != 0)
				src.DamageSelf(val)
				return
			// if(src.isRace(MAJIN))
			// 	val*=0.25
			if(!src.HasInjuryImmune())
				src.TotalInjury+=val
			if(src.TotalInjury>=99)
				src.TotalInjury=99
			if(src.TotalInjury==50)
				src << "<font size=+1>You are extremely wounded!</font size>"
			if(src.TotalInjury< 0)
				TotalInjury = 0
			src.MaxHealth()
		LoseHealth(var/val)
			src.Health-=val
			src.MaxHealth()
			// Apply Demon Devil Trigger Sadist/Masochist effects based on damage taken
			applySinBonusFromTakenDamage(val)
			// Any damage taken counts as "activity" and should reset Sloth stacking
			DevilTriggerSlothBonus = 0
			LastSlothTick = world.time
			var/Absorb = passive_handler.Get("AbsorbingDamage")
			if(passive_handler["Grit"])
				AdjustGrit("add", val*glob.racials.GRITMULT)
			if(Absorb)
				AbsorbingDamage += val
			if(isRace(MAJIN))
				if(majinPassive != null)
					majinPassive.tryDropBlob(src)
		LoseEnergy(var/val, _static = FALSE)
			if(src.FusionPowered)
				return
			if(!_static)
				val/=1+src.GetKiControlMastery()
		//		val*=(src.Power_Multiplier
				if(src.GetPowerUpRatio()>1)
					var/PUSpike=1
					if(passive_handler.Get("PUSpike"))
						PUSpike=max(1, passive_handler.Get("PUSpike")/100)

					var/PowerUpPercent=GetPowerUpRatio()-1
					if(src.HasMovementMastery()>=1) // this run timed a 0 somehow
						PowerUpPercent/=1+(src.GetMovementMastery()/8)

					PowerUpPercent/=PUSpike
					if(passive_handler.Get("DrainlessPUSpike")||passive_handler.Get("DoubleHelix"))
						PowerUpPercent=0
					val*=(1+(PowerUpPercent/src.PUDrainReduction))

			//	if(src.Kaioken)
			//		if(src.Anger)
			//			val*=src.Anger
				/* if(src.PotionCD)
					val*=1.25
					*/
			var/PrideDrain
			if(passive_handler.Get("Pride"))
				PrideDrain=(100-Health)*0.01
				if(PrideDrain>1)
					PrideDrain=1
				if(PrideDrain<0.01)
					PrideDrain=0.01
				val*=PrideDrain
				if(src.Health>=85&&!passive_handler.Get("PowerStressed"))
					val*=0
			// Light Mender mage passive: 50% of energy spent is converted to mana on
			// every spend. Hook fires HERE — after all the reduction multipliers
			// (KiControlMastery, PowerUpPercent, PotionCD, PrideDrain) so the refund
			// tracks what ACTUALLY gets paid, not the raw caller request. Otherwise
			// a mage with KiControlMastery would refund more mana than they actually
			// paid in energy, which is a free-resource exploit. Element-agnostic
			// (mage-body passive, not Light-only) matching the Session 25/26/27/28
			// mage-body convention. HealMana is safe — no PotionCD divider, just
			// ManaAmount += val with MaxMana() clamp at _JinxUtility.dm:1014. The
			// `val > 0` guard prevents the PrideDrain val*=0 path or any other
			// zero-out from triggering a no-op HealMana call.
			if(val > 0 && src.hasMagePassive(/mage_passive/light/Mender))
				src.HealMana(val * 0.5)
			src.Energy-=val
			if(src.Energy<0)
				src.Energy=0
			if(src.Energy<=10 && src.HasHealthPU() && src.PowerControl>100)
				src.PowerControl=100
				src << "You lose your gathered power..."
				src.Auraz("Remove")
				src<<"You are too tired to power up."
				src.PoweringUp=0
			src.GainFatigue(val/glob.FATIGUEDIVIDE)
		GainFatigue(var/val)
			if(src.FusionPowered)
				return
			// Space Linearity mage passive: incoming Fatigue gain is reduced to 50%.
			// Doc literal: "Fatigue gain / Capacity loss at 50% rate (each additional
			// selection: 33%, 25%, ...)". Currently bound to flat 0.5 because
			// hasMagePassive is count-blind — same single-tier limitation as Session
			// 25/26 hooks. Halving the input val before the rest of the pipeline is
			// mathematically equivalent to halving at the end (every downstream
			// mutator is multiplicative), but reads cleaner as "Linearity halves the
			// fatigue you would have taken".
			if(src.hasMagePassive(/mage_passive/space/Linearity))
				val *= 0.5
			val/=1+src.GetKiControlMastery()
			val*=src.EnergyExpenditure//*src.Power_Multiplier
			if(src.GetPowerUpRatio()>1 && !src.GatesActive)
				var/PowerUpPercent=GetPowerUpRatio()-1
				if(src.HasMovementMastery())
					PowerUpPercent/=1+(src.GetMovementMastery()/8)
				var/PUSpike=1
				if(passive_handler.Get("PUSpike"))
					PUSpike=max(1, passive_handler.Get("PUSpike")/100)
				if(passive_handler.Get("DrainlessPUSpike")||passive_handler.Get("DoubleHelix"))
					PowerUpPercent=0

				val*=(1+(PowerUpPercent/src.PUDrainReduction))
				val/=PUSpike
	//		if(src.Kaioken)
	//			if(src.Anger)
	//				val*=src.Anger
			/* if(src.PotionCD)
				val*=1.25
			*/
			// if(src.isRace(MAJIN))
			// 	val*=0.25
			if(!src.HasFatigueImmune())
				src.TotalFatigue+=val
			if(src.TotalFatigue>99)
				src.TotalFatigue=99
			src.MaxEnergy()
		LoseMana(var/val, var/Override=0)
			val*=src.EnergyExpenditure*src.Power_Multiplier
			if(src.HasDrainlessMana()&&!Override)
				return//Nope.
			/* if(src.PotionCD)
				val*=1.25
			*/
			src.ManaAmount-=val
			if(src.ManaAmount<=0)
				src.ManaAmount=0
		LoseCapacity(var/val)
			// Space Linearity mage passive: Capacity loss is reduced to 50%. Pairs
			// with the GainFatigue hook above — both halves of the doc line "Fatigue
			// gain / Capacity loss at 50% rate" are now wired. Single-tier flat 0.5
			// for the same reason as the Fatigue hook. Halving before the
			// GetManaCapMult divider is order-equivalent to halving after.
			if(src.hasMagePassive(/mage_passive/space/Linearity))
				val *= 0.5
			val/=src.GetManaCapMult()
			/* if(src.PotionCD)
				val*=1.25
				*/
			src.TotalCapacity+=val
			if(src.TotalCapacity>=100)
				src.TotalCapacity=100
		HealHealth(val, _isEcho=0)
			if(src.GetEffectiveShearForStackingEffects())
				if(src.HasShearImmunity())
					val=val
					src.Sheared=0
				if(src.HasHellPower())
					if(src.Sheared > 0)
						src.Sheared-=val/(2/src.GetHellPower())
						if(src.Sheared<0)
							val+=(-1)*src.Sheared
							src.Sheared=0
						else
							val=val*0.5
					else if(!src.IsDarkDragonPlayer() && src.Frenzy > 0)
						val=val*0.5
				else
					if(src.Sheared > 0)
						src.Sheared-=val
						if(src.Sheared<0)
							val=(-1)*src.Sheared
							src.Sheared=0
						else
							val=val/4
					else if(!src.IsDarkDragonPlayer() && src.Frenzy > 0)
						val=val/4
			if(icon_state == "Meditate")
				src.Tension=max(0, Tension-(val*1.5))
			if(passive_handler["Staked"])
				val = 0
			if(src.AwakeningSkillUsed==1)
				val = 0
			if(src.VaizardHealth&&!src.passive_handler.Get("HealThroughTempHP"))
				val = 0
			if(src.CelestialAscension=="Demon" && src.transActive>=5)
				if(src.transUnlocked<6)
					val = 0
			val *= getAngelicInfusionMult();//returns 1 if no angelicinfusion
			src.Health+=val
			src.MaxHealth()
			// Light Warden: delayed heal retrigger. Each selection of the Warden mage
			// passive schedules three echo heals at 50% / 25% / 12.5% of the final
			// post-processed val. The echoes are fresh HealHealth calls gated on
			// _isEcho so the retrigger chain terminates after one pass — no recursion
			// on the echo side. Seed is post-Shear / post-PotionCD / post-Staked /
			// post-Awakening / post-Vaizard val so zero-heal paths correctly produce
			// zero echoes, and shear-reduced heals echo off the reduced amount. Delays
			// (1s / 2s / 3s) are a design choice — the doc does not specify a window,
			// but short delays keep the echo legible as a payoff on the original heal.
			if(!_isEcho && val > 0 && src.hasMagePassive(/mage_passive/light/Warden))
				var/echo_seed = val
				spawn(10)
					if(src)
						src.HealHealth(echo_seed * 0.5, 1)
				spawn(20)
					if(src)
						src.HealHealth(echo_seed * 0.25, 1)
				spawn(30)
					if(src)
						src.HealHealth(echo_seed * 0.125, 1)
		HealEnergy(var/val, var/StableHeal=0)
			if(!src.FusionPowered&&!StableHeal)
				val/=src.GetPowerUpRatio()
				val/=src.EnergyExpenditure*src.Power_Multiplier
			if(src.passive_handler.Get("EnergyLeak")>1)
				val *= 0.5
			src.Energy+=val
			if(Energy<0)
				Energy=0
			src.MaxEnergy()
		HealMana(var/val, var/StableHeal=0)
			if(is_arcane_beast) // Are these still in the game?
				val *= max(1,GetManaCapMult())
			if(src.passive_handler.Get("Unrelenting Wrath"))
				val = 0
			if(src.passive_handler.Get("ManaLeak")>=0.25&&src.icon_state!="Meditate")
				val *= 0.1
			src.ManaAmount+=val
			src.MaxMana()
		HealWounds(var/val, var/StableHeal=0)
			if(src.GetEffectiveShearForStackingEffects())
				if(src.HasShearImmunity())
					val=val
					src.Sheared=0
				if(src.Sheared > 0)
					src.Sheared-=val
					if(src.Sheared<0)
						val=(-1)*src.Sheared
						src.Sheared=0
					else
						val=val/2
				else if(!src.IsDarkDragonPlayer() && src.Frenzy > 0)
					val=val/2
			src.TotalInjury-=val
			if(src.TotalInjury < 0)
				src.TotalInjury=0
			src.MaxHealth()
		HealFatigue(var/val, var/StableHeal=0)
			if(!src.FusionPowered&&!StableHeal)
				val*=1/src.GetPowerUpRatio()
			src.TotalFatigue-=val
			if(src.TotalFatigue < 0)
				src.TotalFatigue=0
			src.MaxEnergy()
		HealCapacity(var/val, var/StableHeal=0)
			src.TotalCapacity-=val
			if(src.TotalCapacity<=0)
				src.TotalCapacity=0
			src.MaxMana()
		MaxHealth()
			var/HasWounds=1
			if(src.HasUnstoppable()||src.Secret=="Zombie")
				HasWounds=0
			var/KeyHealth=100-(src.TotalInjury*HasWounds)
			var/Sub
			var/Cut
			if(src.HealthCut)
				Sub=KeyHealth*src.HealthCut
				Cut=KeyHealth-Sub
				if(src.Health > Cut)
					src.Health=Cut
			if(src.Health > KeyHealth)
				src.Health=KeyHealth
		MaxEnergy()
			var/HasFatigue=1
			if(src.HasUnstoppable()||src.Secret=="Zombie")
				HasFatigue=0
			if(src.passive_handler.Get("Anaerobic"))
				HasFatigue=0.7/(src.passive_handler.Get("Anaerobic"))
			var/KeyEnergy=100-(src.TotalFatigue*HasFatigue)
			var/Sub
			var/Cut
			if(src.EnergyCut)
				Sub=KeyEnergy*src.EnergyCut
				Cut=KeyEnergy-Sub
				if(src.Energy > Cut)
					src.Energy=Cut
			if(src.Energy > KeyEnergy)
				src.Energy=KeyEnergy
		MaxMana()
			if(diedFromSenjutsuOverload())
				return
			if(Secret == "Senjutsu" && SlotlessBuffs["Senjutsu Focus"])
				ManaMax =  100 + (25 * (secretDatum.currentTier))
				ManaMax *= MANAOVERLOADMULT
				// at current tier 5, mana max is 225

			var/KeyMana=src.ManaMax
			if(src.TotalCapacity&&!src.HasMechanized())
				KeyMana-=src.TotalCapacity
			if(src.HasManaCapMult())
				KeyMana*=src.GetManaCapMult()
			var/Sub
			var/Cut
			if(src.ManaCut)
				Sub=KeyMana*src.ManaCut
				Cut=KeyMana-Sub
				if(src.ManaAmount > Cut)
					src.ManaAmount=Cut
			if(Secret == "Senjutsu" && SlotlessBuffs["Senjutsu Focus"])
				KeyMana += secretDatum.currentTier * 25
			if(src.ManaAmount > KeyMana)
				src.ManaAmount=KeyMana
		MaxOxygen()
			var/KeyOxygen=src.OxygenMax
			if(SenseRobbed>=2)
				KeyOxygen/=src.SenseRobbed
			if(src.Oxygen>KeyOxygen)
				src.Oxygen-=1
		Calm(var/Pacified=0)
			if(passive_handler.Get("EndlessAnger"))
				return
			if(!Pacified)src.OMessage(10,"<font color=white><i>[src] becomes calm.","<font color=silver>[src]([src.key]) becomes calm.")
			src.DefianceCounter=0
			src.Anger=0
			race.onCalm(src)
			src.AngerCD=5
			if(src.oozaru_type=="Demonic")
				src.AngerCD=0 //hopefully this won't affect anything other than their buff not reapplying anger when the last stage deactivates
		HealAllCutTax()
			AddHealthCut(-1);
			AddEnergyCut(-1);
			AddManaCut(-1);
			SubStrTax(100);
			AddStrCut(-100);
			SubEndTax(100);
			AddEndCut(-100);
			SubSpdTax(100);
			AddSpdTax(-100);
			SubForTax(100);
			AddForCut(-100);
			SubOffTax(100);
			AddOffCut(-100)
			SubDefTax(100);
			AddDefCut(-100)
			SubRecovTax(100);
			AddRecovCut(-100);
		AddHealthCut(Val)
			HealthCut = clamp(HealthCut+Val, 0, 1);
			if(HealthCut>=1) src.Death(null, "exhausting their life force!", SuperDead=1, NoRemains=1);
		AddEnergyCut(Val)
			EnergyCut = clamp(EnergyCut+Val, 0, 1);
			if(EnergyCut>=1) src.Death(null, "exhausting their life force!", SuperDead=1, NoRemains=1);
		AddManaCut(Val)
			ManaCut = clamp(ManaCut+Val, 0, 1);//This one doesn't kill
		AddOmniTax(Val)
			AddStrTax(Val)
			AddForTax(Val)
			AddEndTax(Val)
			AddOffTax(Val)
			AddDefTax(Val)
			AddSpdTax(Val)
		AddStrTax(Val)
			if(src.HasTaxThreshold())
				if(src.StrTax>=src.GetTaxThreshold())
					src.StrTax=src.GetTaxThreshold()
					src.AddStrCut(0.1*Val)
					return
			StrTax = clamp(StrTax+Val, 0, 1);
		SubStrTax(Val, Forced=0)
			if(src.Satiated&&!Drunk||Forced)
				Val*=4
			StrTax = clamp(StrTax-Val, 0, 1);
		AddStrCut(Val)
			StrCut = clamp(StrCut+Val, 0, 1);
		AddEndTax(Val)
			if(src.HasTaxThreshold())
				if(src.EndTax>=src.GetTaxThreshold())
					src.EndTax=src.GetTaxThreshold()
					src.AddEndCut(0.1*Val)
					return
			EndTax=clamp(EndTax+Val, 0, 1);
		SubEndTax(Val, Forced=0)
			if(src.Satiated&&!Drunk||Forced)
				Val*=4
			EndTax=clamp(EndTax-Val, 0, 1);
		AddEndCut(Val)
			EndCut=clamp(EndCut+Val, 0, 1);
		AddSpdTax(Val)
			if(src.HasTaxThreshold())
				if(src.SpdTax>=src.GetTaxThreshold())
					src.SpdTax=src.GetTaxThreshold()
					src.AddSpdCut(0.1*Val)
					return
			SpdTax=clamp(SpdTax+Val, 0, 1);
		SubSpdTax(Val, Forced=0)
			if(src.Satiated&&!Drunk||Forced)
				Val*=4
			SpdTax=clamp(SpdTax-Val, 0, 1)
		AddSpdCut(Val)
			SpdCut=clamp(SpdCut+Val, 0, 1);
		AddForTax(Val)
			if(src.HasTaxThreshold())
				if(src.ForTax>=src.GetTaxThreshold())
					src.ForTax=src.GetTaxThreshold()
					src.AddForCut(0.1*Val)
					return
			ForTax=clamp(ForTax+Val, 0, 1);
		SubForTax(Val, Forced=0)
			if(src.Satiated&&!Drunk||Forced)
				Val*=4
			ForTax=clamp(ForTax-Val, 0, 1);
		AddForCut(Val)
			ForCut=clamp(ForCut+Val, 0, 1);
		AddOffTax(Val)
			if(src.HasTaxThreshold())
				if(src.OffTax>=src.GetTaxThreshold())
					src.OffTax=src.GetTaxThreshold()
					src.AddOffCut(0.1*Val)
					return
			OffTax=clamp(OffTax+Val, 0, 1);
		SubOffTax(Val, Forced=0)
			if(src.Satiated&&!Drunk||Forced)
				Val*=4
			OffTax=clamp(OffTax-Val, 0, 1);
		AddOffCut(Val)
			OffCut=clamp(OffCut+Val, 0, 1);
		AddDefTax(Val)
			if(src.HasTaxThreshold())
				if(src.DefTax>=src.GetTaxThreshold())
					src.DefTax=src.GetTaxThreshold()
					src.AddDefCut(0.1*Val)
					return
			DefTax=clamp(DefTax+Val, 0, 1);
		SubDefTax(Val, Forced=0)
			if(src.Satiated&&!Drunk||Forced)
				Val*=4
			DefTax=clamp(DefTax+Val, 0, 1);
		AddDefCut(Val)
			DefCut=clamp(DefCut+Val, 0, 1);
		AddRecovTax(Val)
			if(src.HasTaxThreshold())
				if(src.RecovTax>=src.GetTaxThreshold())
					src.RecovTax=src.GetTaxThreshold()
					src.AddRecovCut(0.1*Val)
					return
			RecovTax = clamp(RecovTax+Val, 0, 1);
		SubRecovTax(var/Val, var/Forced=0)
			if(src.Satiated&&!Drunk||Forced)
				Val*=4
			RecovTax = clamp(RecovTax-Val, 0, 1);
		AddRecovCut(var/Val)
			RecovCut=clamp(RecovCut+Val, 0, 1);
		// forgive the sin below, im not replacing basestat() in all the codebase
		getEnhanced(statName)
			var/enhance = vars["Enhanced[statName]"] * 0.3
			if(isRace(ANDROID)||CyberneticMainframe)
				enhance = vars["Enhanced[statName]"] * 0.6
			if(Target && ismob(Target))
				// Rusting: when target carries the Rusting passive (mystic/hybrid styles)
				// and the player is poisoned, debuff the player's enhance-chip stat by an
				// amount that scales with both poison stacks and target's Rusting tier.
				// Prior version had three bugs: (1) read self's Rusting instead of target's,
				// which zeroed enhance for everyone without their own Rusting source;
				// (2) formula scaled the multiplier UP with bigger Rusting/Poison, so high
				// tiers debuffed less; (3) at extreme stacks the multiplier exceeded 1 and
				// the debuff flipped into a buff. Rewritten as a clamped 1-x reduction.
				var/targetRusting = Target.passive_handler["Rusting"]
				if(targetRusting && Poison >= 1)
					var/rustReduction = (Poison * glob.RUSTING_RATE * targetRusting) / 100
					enhance *= max(0, 1 - rustReduction)
			return enhance
		BaseStr()
			var/enhanced = getEnhanced("Strength")
			return ((src.StrMod+src.StrAscension+(enhanced)))*StrChaos
		BaseFor()
			var/enhanced = getEnhanced("Force")
			return ((src.ForMod+src.ForAscension+(enhanced)))*ForChaos
		BaseEnd()
			var/enhanced = getEnhanced("Endurance")
			return ((src.EndMod+src.EndAscension+(enhanced)))*EndChaos
		BaseSpd()
			var/enhanced = getEnhanced("Speed")
			return ((src.SpdMod+src.SpdAscension+(enhanced)))*SpdChaos
		BaseOff()
			var/enhanced = getEnhanced("Aggression")
			return ((src.OffMod+src.OffAscension+(enhanced)))*OffChaos
		BaseDef()
			var/enhanced = getEnhanced("Reflexes")
			return ((src.DefMod+src.DefAscension+(enhanced)))*DefChaos

		BaseRecov()
			return (src.RecovMod+src.RecovAscension)*RecovChaos
		HandleEldritchTax()
			var/TaxVal=glob.racials.FULL_MANIFESTATION_TAX/glob.racials.FULL_MANIFESTATION_TAX_DIVISOR
			if(passive_handler.Get("Full Manifestation")&&AscensionsAcquired<5)
				TaxVal *= (6-AscensionsAcquired)*0.3

			if(passive_handler.Get("Full Manifestation")&&AscensionsAcquired>=5)
				TaxVal=0
			AddOmniTax(TaxVal)
		isInDemonDevilTrigger()
			if(!isRace(DEMON)) return FALSE
			if(!transActive || !race || !race.transformations || transActive > race.transformations.len) return FALSE
			var/transformation/current = race.transformations[transActive]
			if(!istype(current, /transformation/demon/devil_trigger)) return FALSE
			return TRUE

		// Used by the Devil Arm icon-swap path. Demon-only sins / disguise stay
		// gated by isInDemonDevilTrigger; this one also covers makaioshin forms.
		isInDevilTriggerLikeForm()
			if(!transActive || !race || !race.transformations || transActive > race.transformations.len) return FALSE
			var/transformation/current = race.transformations[transActive]
			if(istype(current, /transformation/demon/devil_trigger)) return TRUE
			if(istype(current, /transformation/makaioshin/falldown_mode)) return TRUE
			if(istype(current, /transformation/makaioshin/satan_mode)) return TRUE
			return FALSE

		resetDevilTriggerSinBonuses()
			DevilTriggerSinDamageBonus = 0
			DevilTriggerSlothBonus = 0
			LastSlothTick = 0
			if(DevilTriggerEnvyMirrorPending && passive_handler)
				if(passive_handler.Get("MirrorStats") > 0)
					passive_handler.Decrease("MirrorStats", 1)
				if(passive_handler.Get("MirrorStats") < 0)
					passive_handler.Set("MirrorStats", 0)
				DevilTriggerEnvyMirrorPending = 0
			// Deactivate the shockwave buff when Devil Trigger ends
			var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sloth_Factor/sf = FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sloth_Factor)
			if(sf && sf.SlotlessOn)
				sf.Trigger(src, TRUE)

		getDevilTriggerSinBonusMult()
			if(!isInDemonDevilTrigger())
				resetDevilTriggerSinBonuses()
				return 0

			var/mult = 0
			var/pride_bonus = 0
			var/lustPart = 0
			var/greedPart = 0
			var/sinDmgPart = 0
			var/slothPart = 0

			// EnvyFactor
			if(passive_handler && passive_handler.Get("EnvyFactor"))
				if(!passive_handler.Get("MirrorStats"))
					passive_handler.Set("MirrorStats", 1)
					DevilTriggerEnvyMirrorPending = 1

			// LustFactor
			if(passive_handler && passive_handler.Get("LustFactor"))
				var/targets = getTargetingMeCount()
				if(targets > 0)
					lustPart = 0.02 * passive_handler.Get("LustFactor") * targets

			// GreedFactor
			if(passive_handler && passive_handler.Get("GreedFactor"))
				var/money = 0
				for(var/obj/Money/m in src.contents)
					money = m.Level
				if(money > 0)
					greedPart = max(0, money / glob.racials.GOLD_DRAGON_FORMULA) * passive_handler.Get("GreedFactor")

			// Sadist / Masochist / GluttonyFactor (feast -> DevilTriggerSinDamageBonus)
			if(DevilTriggerSinDamageBonus > 0)
				sinDmgPart = DevilTriggerSinDamageBonus

			// SlothFactor
			if(DevilTriggerSlothBonus > 0)
				slothPart = DevilTriggerSlothBonus

			// PrideFactor (uncapped; other sin bonuses stay capped at 3 unless Limited Rank-Up)
			if(passive_handler && passive_handler.Get("PrideFactor") && Target && istype(Target, /mob/Players))
				var/healthDiff = Health - Target:Health
				if(healthDiff > 0)
					var/steps = round(healthDiff / 10)
					if(steps > 0)
						pride_bonus = 0.25 * steps * passive_handler.Get("PrideFactor")
						if(passive_handler.Get("Limited Rank-Up"))
							pride_bonus *= 3

			//these aren't actually multipliers btw teehee, they are additive. They started out as multiplicative but I changed my mind after the fact
			if(passive_handler && passive_handler.Get("Limited Rank-Up"))
				mult = lustPart + greedPart + sinDmgPart + slothPart
			else
				mult = lustPart + greedPart + sinDmgPart + slothPart
				if(mult < 0)
					mult = 0
				if(mult > 3)
					mult = 3

			if(mult < 0)
				mult = 0

			mult += pride_bonus

			if(passive_handler && passive_handler.Get("PrideFactor") && mult < 1.5)
				mult = 1.5

			return mult

		getTargetingMeCount()
			var/count = 0
			for(var/mob/Players/P in players)
				if(P != src && P.Target == src)
					count++
			return count

		// adist/Masochist effects
		applySinBonusFromDealtDamage(var/amount)
			if(amount <= 0) return
			if(!isInDemonDevilTrigger()) return

			var/rate = 0.01

			if(passive_handler && passive_handler.Get("Sadist"))
				var/inc = amount * rate
				DevilTriggerSinDamageBonus += inc

			if(passive_handler && passive_handler.Get("Masochist"))
				var/dec = amount * rate * 0.5
				DevilTriggerSinDamageBonus -= dec

			if(DevilTriggerSinDamageBonus < 0)
				DevilTriggerSinDamageBonus = 0

		applySinBonusFromTakenDamage(var/amount)
			if(amount <= 0) return
			if(!isInDemonDevilTrigger()) return

			var/rate = 0.01

			if(passive_handler && passive_handler.Get("Sadist"))
				var/dec = amount * rate * 0.5
				DevilTriggerSinDamageBonus -= dec

			if(passive_handler && passive_handler.Get("Masochist"))
				var/inc = amount * rate
				DevilTriggerSinDamageBonus += inc

			if(DevilTriggerSinDamageBonus < 0)
				DevilTriggerSinDamageBonus = 0

		// Sloth movement
		resetSlothTracking()
			DevilTriggerSlothBonus = 0
			LastSlothTick = world.time
			// Deactivate the shockwave buff when the demon moves
			var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sloth_Factor/sf = FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sloth_Factor)
			if(sf && sf.SlotlessOn)
				sf.Trigger(src, TRUE)

		updateSlothSinBonus()
			if(!isInDemonDevilTrigger()) return
			if(!passive_handler || !passive_handler.Get("SlothFactor")) return
			if(PureRPMode)
				LastSlothTick = world.time
				return

			if(!LastSlothTick)
				LastSlothTick = world.time
				return

			var/ticksSince = world.time - LastSlothTick

			// About 5 seconds before it kicks in?
			if(ticksSince < 50) return

			var/inc = 1 / 10 * passive_handler.Get("SlothFactor")
			DevilTriggerSlothBonus += inc
			LastSlothTick = world.time

			// Activate the Sloth_Factor shockwave buff once the bonus is running
			var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sloth_Factor/sf = findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Sloth_Factor)
			// Recovery: SlotlessOn saved as 1 but loop died (e.g. after relog)
			if(sf.SlotlessOn && !sf.waveLoopRunning)
				sf.startWaveLoop(src)
			else if(!sf.SlotlessOn)
				sf.Trigger(src, TRUE)

		GetStrMult()
			return src.StrMultTotal
		GetForMult()
			return src.ForMultTotal
		GetEndMult()
			return src.EndMultTotal
		GetSpdMult()
			return src.SpdMultTotal
		GetOffMult()
			return src.OffMultTotal
		GetDefMult()
			return src.DefMultTotal
		GetRecovMult()
			return src.RecovMultTotal
		GetStrTransMult()
			var/STM=src.StrTransMult+src.passive_handler.Get("MagnifiedStr")
			return STM
		GetForTransMult()
			var/FTM=src.ForTransMult+src.passive_handler.Get("MagnifiedFor")
			return FTM
		GetEndTransMult()
			var/ETM=src.EndTransMult+src.passive_handler.Get("MagnifiedEnd")
			return ETM
		GetSpdTransMult()
			var/SpTM=src.SpdTransMult+src.passive_handler.Get("MagnifiedSpd")
			return SpTM
		GetOffTransMult()
			var/OTM=src.OffTransMult+src.passive_handler.Get("MagnifiedOff")
			return OTM
		GetDefTransMult()
			var/DTM=src.DefTransMult+src.passive_handler.Get("MagnifiedDef")
			return DTM


		GetMA(stat)
			if(StyleBuff)
				var/MA = StyleBuff.vars["Style[stat]"]-1
				if(Target)
					if((Target.passive_handler["Musoken"] && equippedSword) && stat == "Off")
						if(passive_handler["Musoken"])
							MA /= 2
						else
							MA = 0
				if(passive_handler["StyleMastery"])
					MA *= 1 + (passive_handler["StyleMastery"]/glob.STYLE_MASTERY_DIVISOR)
				if(Secret=="Zombie" && stat in list("Str","For", "Off","Def"))
					MA+=0.1
				if((Secret=="Werewolf"&&(!CheckSlotless("Half Moon Form"))) && stat in list("Str", "Off"))
					MA+=0.1
				if(Secret=="Haki")
					if(secretDatum.secretVariable["HakiSpecialization"]=="Armament")
						if(stat=="Str")
							MA += 0.1 * secretDatum.currentTier
						else if(stat=="Off"||stat=="Def")
							MA += 0.05 * secretDatum.currentTier
					if(secretDatum.secretVariable["HakiSpecialization"]=="Observation")
						if(stat=="Off"||stat=="Def")
							MA += 0.1 * secretDatum.currentTier
					if(stat in list("End","For"))
						MA += 0.05 * secretDatum.currentTier
				return MA
			return 0


		GetStr(var/Mult=1)
			var/Str=src.StrMod
			var/EldritchMod=0
/*			if(src.EldritchPacted)
				switch(src.ReflectedPactType)
					if("Devotion")
						EldritchMod=0.5
					if("Power")
						EldritchMod=1
					if("Knowledge")
						EldritchMod=0
					if("Ambition")
						EldritchMod=0
					if("Survival")
						EldritchMod=0.25*/
			Str+=EldritchMod
			var/EffectiveAsc=src.StrAscension
			if(passive_handler.Get("Half Manifestation"))
				EffectiveAsc+=src.HandleManifestation("Str")
			if(passive_handler.Get("SpiralPowerUnlocked"))
				var/SP=passive_handler.Get("SpiralPowerUnlocked")
				EffectiveAsc+=src.HandleSpiralUnlock("Str", SP)

			Str+=EffectiveAsc
			//stat ascensions gained through racial or saga improvements
			var/enhanced = getEnhanced("Strength")
			Str+=src.EnhancedStrength ? enhanced : 0
			//cyber stats boosters.
			//gain double value when Overdive is active, unless the user is Android (then only +50%)
			Str*=src.StrChaos
			//tarot shit
			if(passive_handler.Get("Piloting")&&findMecha())
				Str = getMechStat(findMecha(), Str)
			if(src.StrReplace)
				Str=StrReplace
			//when you want to ignore all of the above for some reason
			Str+=StrAdded
			Str+=src.GetEquippedWeaponStatAdd("Str")
			if(src.HasManaStats())
				Str += getManaStatsBoon()
			if(HasShonenPower())
				var/spPower = GetShonenPower() > 0 ? GetShonenPower() : 0
				Str += (0.1*spPower) * Str
			var/hellPower = src.GetHellPower()
			if(hellPower == 2)
				Str += (hellPower/2) * Str
			else
				Str += (0.2 * hellPower) * Str
			var/zenkaiPower=src.GetZenkaiPower()
			if(zenkaiPower == 2)
				Str += (zenkaiPower/2) * Str
			else
				Str += (0.2 * zenkaiPower) * Str
			// get 25% bonus to strength for each hell power
			var/Mod=1
			var/strMult = StrMultTotal
			if(Secret == "Heavenly Restriction")
				if(secretDatum?:hasImprovement("Strength"))
					strMult += round(clamp(1 + secretDatum?:getBoon(src, "Strength") / 8, 1, 8), 0.1)
			if(passive_handler.Get("KillerInstinct") && Health <= 50)
				strMult += GetKillerInstinct()
			if(KaiokenBP > 1)
				strMult += KaiokenBP-0.8
			Mod+=(strMult-1)
			if(src.KamuiBuffLock)
				Mod+=0.75
			if(src.Saga=="Eight Gates")
				Mod+=0.01*GatesActive
			if(src.passive_handler["LegendarySaiyan"]==1)
				if(src.Tension>=50&&src.Tension<src.getMaxTensionValue())
					Mod+=0.01*(src.Tension/10)
				else if(src.Tension>=src.getMaxTensionValue())
					Mod+=1
			// if(src.isRace(HUMAN))
			// 	if(src.AscensionsAcquired)
			// 		Mod+=(src.AscensionsAcquired/20)
			if(src.CheckSlotless("What Must Be Done"))
				if(SlotlessBuffs["What Must Be Done"])
					if(SlotlessBuffs["What Must Be Done"].Password)
						Mod+=min(0.5, SlotlessBuffs["What Must Be Done"].Mastery/10)
			if(src.InfinityModule)
				var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/ki = src.FindSkill(/obj/Skills/Buffs/ActiveBuffs/Ki_Control)
				if(ki && "Str" in ki.selectedStats)
					Mult += (AscensionsAcquired/10) * ki.StrMult
			if(glob.racials.DEVIL_ARM_STAT_MULTS)
				if(src.CheckSlotless("Devil Arm")&&!src.SpecialBuff)
					Mod+=(0.1 * AscensionsAcquired)
			if(src.StrStolen)
				Mod+=src.StrStolen*0.5
			Mod += (scalingEldritchPower() / 10);
			var/BM=src.HasBuffMastery()
			if(BM)
				if(Mod<=glob.BUFF_MASTERY_LOWTHRESHOLD)
					Mod*=(1+(BM*glob.BUFF_MASTERY_LOWMULT))
				else if(Mod>=glob.BUFF_MASTER_HIGHTHRESHOLD)
					Mod*=(1+(BM*glob.BUFF_MASTERY_HIGHMULT))
			if(src.Burn)
				if(passive_handler.Get("BurningShot"))
					if(src.Burn>0&&src.Burn<=25)
						Mod+=0.25*passive_handler.Get("BurningShot")
					else if(src.Burn>25&&src.Burn<=75)
						Mod+=0.5*passive_handler.Get("BurningShot")
					else
						Mod+=0.75*passive_handler.Get("BurningShot")
			if(Momentum)
				Mod *= getMomentumMult();

			if(src.CheckSlotless("Genesic Brave")||src.CheckSpecial("King of Braves")) //okay take two
				if(glob.KOB_GETS_STATS_LOW_LIFE)
					var/threshold = 25 * (1 - src.HealthCut)
					if(src.Health <= threshold)
						var/hp_safe = max(src.Health, 0.001) //this takes either health, or 0.001 to avoid negative values for the first stage
						var/base_bonus = min(10 / hp_safe, 1) //This is based on the old formula! This one was fine I was just being r[censored]. This means KoB get their full low hp buff at 10%.
						Mod += base_bonus

					if(src.passive_handler.Get("Color of Courage") && src.Health < 0) //This uses the NEW formula where the extra bonus caps at 1 at [TRIPLEHELIX_MAX_NEG_HP]
						var/minhp = glob.TRIPLEHELIX_MAX_NEG_HP
						if(minhp >= 0)
							minhp = -1 //Makes sure this can't be a Positive value so you don't get the opposite issue as the first stage
						var/den2 = 0 - minhp //normalization of range
						if(den2 <= 0)
							den2 = 1
						var/t2 = (0 - src.Health) / den2
						t2 = max(0, min(t2, 1))
						var/extra_max_bonus = 1.0
						Mod += extra_max_bonus * t2 //No cap this time, you get the "full bonus" once you get your ass knocked down, which essentially means you keep getting stronger as you near knockdown

			if(src.StrEroded)
				Mod-=src.StrEroded

			if(Secret == "Werewolf" && CheckSlotless("Full Moon Form"))
				Mod += 1 * (secretDatum?:getHungerBoon())
			var/adaptive = passive_handler.Get("AngerAdaptiveForce")
			if(adaptive && (src.HasCalmAnger() || passive_handler.Get("EndlessAnger") || Anger))
				if(BaseStr() > BaseFor())
					Mod += clamp(adaptive,0.1,1)
				if(BaseStr() == BaseFor())
					// lol
					Mod += clamp(adaptive/2,0.05, 0.5)
			if(passive_handler["Rebel Heart"])
				var/h = (((missingHealth())/glob.REBELHEARTMOD) * passive_handler["Rebel Heart"])/10
				Mod+=h
			if(passive_handler.Get("TensionPowered"))
				Mod+=(passive_handler.Get("TensionPowered")/4)
			if(passive_handler.Get("TensionPowered")&&transActive>=2)
				Mod+=(passive_handler.Get("TensionPowered")/4)
			if(passive_handler.Get("TensionPowered")&&transActive>=4)
				Mod+=(passive_handler.Get("TensionPowered")/2)
				if(isRace(HUMAN))
					Mod+=(passive_handler.Get("TensionPowered")/2)
			if(src.RebirthHeroPath=="Red" && src.SagaLevel>=3)
				Mod *= 1+ (src.HealthAnnounce10/5)
			if(Secret == "Shin" && CheckSlotless("Mang Resonance"))
				Mod += GetMangStats() // you can find this proc in Secrets\Shin\buff.dm
			if(src.StyleRating > 0)
				Mod += 0.1 * src.StyleRating * src.getStyleBonusMult()
			// Demon Devil Trigger sins bonus
			Mod += getDevilTriggerSinBonusMult()
			Mod += getMazokuSinBonusMult()
			if(IsDarkDragonPlayer() && Frenzy > 0)
				Mod += 0.5 * (min(Frenzy, glob.DEBUFF_STACK_MAX) / glob.DEBUFF_STACK_MAX)
			if(src.passive_handler.Get("Longing")&&src.Target)
				if(Target.GetPowerUpRatio()>=Target.Power_Multiplier)
					Str*=clamp(1+((Target.GetPowerUpRatio()-1)/glob.LONGING_DIVISOR),1, glob.LONGING_MAX_CLAMP)
				else if(Target.Power_Multiplier>=Target.GetPowerUpRatio())
					Str*=clamp(1+((Target.Power_Multiplier-1)/glob.LONGING_DIVISOR),1, glob.LONGING_MAX_CLAMP)
				else
					Str*=1
			var/STM=GetStrTransMult()
			Str*=STM
			Str*=Mod
			Str*=Mult
			if(src.HasMirrorStats())
				if(src.Target&&src.Target!=src&&!src.Target.HasMirrorStats()&&istype(src.Target, /mob/Players)&&!Target.passive_handler.Get("To Govern Strength"))
					Str=src.Target.GetStr()
			var/TotalTax
			if(src.StrTax)
				TotalTax+=src.StrTax
			if(src.StrCut)
				TotalTax+=src.StrCut
			if(HasUnbreakable())
				TotalTax*=1-GetUnbreakable()
			if(TotalTax>=1)
				TotalTax=0.9
			var/Sub=Str*TotalTax
			Str-=Sub
			Str+=src.GetMA("Str")
			if(src.HasAdaptation())
				if(src.AdaptationCounter!=0&&!CheckSlotless("Great Ape"))
					if(src.Target&&src.AdaptationTarget==src.Target)
						Str+=(src.Target.GetMA("End")*0.5*src.AdaptationCounter)
			if(Secret == "Heavenly Restriction")
				if(secretDatum?:hasRestriction("Strength") && Str > 1)
					Str = 1
			if(Str<0.1)
				Str=0.1
			return Str

		GetFor(var/Mult=1)
			var/For=src.ForMod
			var/EldritchMod=0
/*			if(src.EldritchPacted)
				switch(src.ReflectedPactType)
					if("Devotion")
						EldritchMod=0.5
					if("Power")
						EldritchMod=0
					if("Knowledge")
						EldritchMod=1
					if("Ambition")
						EldritchMod=0.25
					if("Survival")
						EldritchMod=0*/
			For+=EldritchMod
			var/EffectiveAsc=src.ForAscension
			if(passive_handler.Get("Half Manifestation"))
				EffectiveAsc+=src.HandleManifestation("For")
			if(passive_handler.Get("SpiralPowerUnlocked"))
				var/SP=passive_handler.Get("SpiralPowerUnlocked")
				EffectiveAsc+=src.HandleSpiralUnlock("For", SP)

			For+=EffectiveAsc
			var/enhanced = getEnhanced("Force")
			For+=src.EnhancedForce ? enhanced : 0
			For*=src.ForChaos
			if(src.ForReplace)
				For=ForReplace
			For+=ForAdded
			For+=src.GetEquippedWeaponStatAdd("For")
			if(UsingHotnCold())
				if(StyleBuff?:hotCold>0)
					For+=StyleBuff?:hotCold/glob.HOTNCOLD_STAT_DIVISOR
			if(HasShonenPower())
				var/spPower = GetShonenPower() > 0 ? GetShonenPower() : 0
				For += (0.1*spPower) * For
			var/hellPower = src.GetHellPower()
			if(hellPower == 2)
				For += (hellPower/2) * For
			else
				For += (0.2 * hellPower) * For
			var/zenkaiPower=src.GetZenkaiPower()
			if(zenkaiPower == 2)
				For += (zenkaiPower/2) * For
			else
				For += (0.2 * zenkaiPower) * For
			if(passive_handler.Get("Piloting")&&findMecha())
				For = getMechStat(findMecha(), For)
			if(src.HasManaStats())
				For += getManaStatsBoon()


			var/Mod=1
			var/forMult = ForMultTotal
			if(passive_handler.Get("KillerInstinct") && Health <= 75)
				forMult += GetKillerInstinct()
			if(Secret == "Heavenly Restriction")
				if(secretDatum?:hasImprovement("Force"))
					forMult += round(clamp(1 + secretDatum?:getBoon(src, "Force") / 8, 1, 8), 0.1)
			if(KaiokenBP > 1)
				forMult += KaiokenBP-0.8
			Mod+=(forMult-1)
			if(src.passive_handler["LegendarySaiyan"]==1)
				if(src.Tension>=50&&src.Tension<src.getMaxTensionValue())
					Mod+=0.01*(src.Tension/10)
				else if(src.Tension>=src.getMaxTensionValue())
					Mod+=1
			// if(src.isRace(HUMAN))
			// 	if(src.AscensionsAcquired)
			// 		Mod+=(src.AscensionsAcquired/20)
			if(src.CheckSlotless("What Must Be Done"))
				if(SlotlessBuffs["What Must Be Done"])
					if(SlotlessBuffs["What Must Be Done"].Password)
						Mod+=min(0.5, SlotlessBuffs["What Must Be Done"].Mastery/10)
			if(src.InfinityModule)
				var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/ki = src.FindSkill(/obj/Skills/Buffs/ActiveBuffs/Ki_Control)
				if(ki && "For" in ki.selectedStats)
					Mult += (AscensionsAcquired/10) * ki.ForMult//Mult += round(glob.progress.totalPotentialToDate,5) / 150 * ki.ForMult
			// if((isRace(SAIYAN) || isRace(HALFSAIYAN))&&transActive&&!src.SpecialBuff)
			// 	if(src.race.transformations[transActive].mastery==100)
			// 		Mod+=0.1
			if(glob.racials.DEVIL_ARM_STAT_MULTS)
				if(src.CheckSlotless("Devil Arm")&&!src.SpecialBuff)
					Mod+=(0.1 * AscensionsAcquired)
			if(src.ForStolen)
				Mod+=src.ForStolen*0.5
			Mod += (scalingEldritchPower() / 10);
			var/BM=src.HasBuffMastery()
			if(BM)
				if(Mod<=glob.BUFF_MASTERY_LOWTHRESHOLD)
					Mod*=(1+(BM*glob.BUFF_MASTERY_LOWMULT))
				else if(Mod>=glob.BUFF_MASTER_HIGHTHRESHOLD)
					Mod*=(1+(BM*glob.BUFF_MASTERY_HIGHMULT))
			if(src.Burn)
				if(src.passive_handler.Get("BurningShot"))
					if(src.Burn>0&&src.Burn<=25)
						Mod+=0.25*src.passive_handler.Get("BurningShot")
					else if(src.Burn>25&&src.Burn<=75)
						Mod+=0.5*src.passive_handler.Get("BurningShot")
					else
						Mod+=0.75*src.passive_handler.Get("BurningShot")

			if(src.CheckSlotless("Genesic Brave")||src.CheckSpecial("King of Braves")) //okay take two
				if(glob.KOB_GETS_STATS_LOW_LIFE)
					var/threshold = 25 * (1 - src.HealthCut)
					if(src.Health <= threshold)
						var/hp_safe = max(src.Health, 0.001) //this takes either health, or 0.001 to avoid negative values for the first stage
						var/base_bonus = min(10 / hp_safe, 1) //This is based on the old formula! This one was fine I was just being r[censored]. This means KoB get their full low hp buff at 10%.
						Mod += base_bonus

					if(src.passive_handler.Get("Color of Courage") && src.Health < 0) //This uses the NEW formula where the extra bonus caps at 1 at [TRIPLEHELIX_MAX_NEG_HP]
						var/minhp = glob.TRIPLEHELIX_MAX_NEG_HP
						if(minhp >= 0)
							minhp = -1 //Makes sure this can't be a Positive value so you don't get the opposite issue as the first stage
						var/den2 = 0 - minhp //normalization of range
						if(den2 <= 0)
							den2 = 1
						var/t2 = (0 - src.Health) / den2
						t2 = max(0, min(t2, 1))
						var/extra_max_bonus = 1.0
						Mod += extra_max_bonus * t2 //No cap this time, you get the "full bonus" once you get your ass knocked down, which essentially means you keep getting stronger as you near knockdown

			if(passive_handler["Rebel Heart"])
				var/h = (((missingHealth())/glob.REBELHEARTMOD) * passive_handler["Rebel Heart"])/10
				Mod+=h
			if(src.ForEroded)
				Mod-=src.ForEroded

			// Demon Devil Trigger sins bonus (additive)
			Mod += getDevilTriggerSinBonusMult()
			Mod += getMazokuSinBonusMult()

			var/adaptive = passive_handler.Get("AngerAdaptiveForce")
			if(adaptive && (src.HasCalmAnger() || passive_handler.Get("EndlessAnger") || Anger))
				if(BaseFor() > BaseStr())
					Mod += clamp(adaptive,0.1,1)
				if(BaseFor() == BaseStr())
					// lol
					Mod += clamp(adaptive/2,0.05, 0.5)
			if(passive_handler.Get("TensionPowered"))
				Mod+=(passive_handler.Get("TensionPowered")/4)
			if(passive_handler.Get("TensionPowered")&&transActive>=2)
				Mod+=(passive_handler.Get("TensionPowered")/4)
			if(passive_handler.Get("TensionPowered")&&transActive>=4)
				Mod+=(passive_handler.Get("TensionPowered")/2)
				if(isRace(HUMAN))
					Mod+=(passive_handler.Get("TensionPowered")/2)
			if(src.RebirthHeroPath=="Red" && src.SagaLevel>=3)
				Mod *= 1+ (src.HealthAnnounce10/5)
			if(Secret == "Shin" && CheckSlotless("Mang Resonance"))
				Mod += GetMangStats() // you can find this proc in Secrets\Shin\buff.dm
			if(src.StyleRating > 0)
				Mod += 0.1 * src.StyleRating * src.getStyleBonusMult()
			if(src.passive_handler.Get("Longing")&&src.Target)
				if(Target.GetPowerUpRatio()>=Target.Power_Multiplier)
					For*=clamp(1+((Target.GetPowerUpRatio()-1)/glob.LONGING_DIVISOR),1, glob.LONGING_MAX_CLAMP)
				else if(Target.Power_Multiplier>=Target.GetPowerUpRatio())
					For*=clamp(1+((Target.Power_Multiplier-1)/glob.LONGING_DIVISOR),1, glob.LONGING_MAX_CLAMP)
				else
					For*=1
			var/FTM=GetForTransMult()
			For*=FTM
			For*=Mod
			For*=Mult
			if(src.HasMirrorStats())
				if(src.Target&&src.Target!=src&&!src.Target.HasMirrorStats()&&istype(src.Target, /mob/Players)&&!Target.passive_handler.Get("To Govern Strength"))
					For=src.Target.GetFor()
			var/TotalTax
			if(src.ForTax)
				TotalTax+=src.ForTax
			if(src.ForCut)
				TotalTax+=src.ForCut
			if(HasUnbreakable())
				TotalTax*=1-GetUnbreakable()
			if(TotalTax>=1)
				TotalTax=0.9
			var/Sub=For*TotalTax
			For-=Sub
			For+=src.GetMA("For")
			// if(src.UsingYinYang()&&src.Target&&src.Target!=src&&!src.Target.UsingYinYang()&&istype(src.Target, /mob/Players))
			// 	For+=src.Target.GetMA("End")*0.5
			// else
			if(src.HasAdaptation())
				if(src.AdaptationCounter!=0&&!CheckSlotless("Great Ape"))
					if(src.Target&&src.AdaptationTarget==src.Target)
						For+=(src.Target.GetMA("End")*0.5*src.AdaptationCounter)
			if(Secret == "Heavenly Restriction")
				if(secretDatum?:hasRestriction("Force") && For > 1)
					For = 1
			if(For<0.1)
				For=0.1
			return For

		GetEnd(var/Mult=1)
			var/End=src.EndMod
			var/EldritchMod=0
/*			if(src.EldritchPacted)
				switch(src.ReflectedPactType)
					if("Devotion")
						EldritchMod=0.5
					if("Power")
						EldritchMod=0.25
					if("Knowledge")
						EldritchMod=0.25
					if("Ambition")
						EldritchMod=0
					if("Survival")
						EldritchMod=1*/
			End+=EldritchMod
			var/EffectiveAsc=src.EndAscension
			if(passive_handler.Get("Half Manifestation"))
				EffectiveAsc+=src.HandleManifestation("End")
			if(passive_handler.Get("SpiralPowerUnlocked"))
				var/SP=passive_handler.Get("SpiralPowerUnlocked")
				EffectiveAsc+=src.HandleSpiralUnlock("End", SP)

			End+=EffectiveAsc
			var/enhanced = getEnhanced("Endurance")
			End+=EnhancedEndurance ? enhanced : 0
			End*=src.EndChaos
			if(src.EndReplace)
				End=EndReplace
			if(passive_handler.Get("Piloting")&&findMecha())
				End = getMechStat(findMecha(), End)

			if(passive_handler.Get("DemonicDurability") && (Anger||HasCalmAnger()))
				if(!passive_handler.Get("CancelDemonicDura"))
					End += End * (glob.DEMONIC_DURA_BASE * passive_handler.Get("DemonicDurability"))
			if(passive_handler.Get("LunarDurability") && (Anger||HasCalmAnger()))
				End*=AngerMax
			if(CheckSlotless("The Grit") && (Anger||HasCalmAnger()))
				End += End * (glob.DEMONIC_DURA_BASE)
			End+=EndAdded
			End+=src.GetEquippedWeaponStatAdd("End")
			if(UsingHotnCold())
				if(StyleBuff?:hotCold<0)
					End+=abs(StyleBuff?:hotCold)/glob.HOTNCOLD_STAT_DIVISOR
			if(src.HasManaStats())
				End += getManaStatsBoon()/2
			if(passive_handler["Wrathful Tenacity"] && (Anger || HasCalmAnger()))
				End += GetStr() * (passive_handler["Wrathful Tenacity"])
			var/Mod=1
			Mod+=(src.EndMultTotal-1)
			if(src.KamuiBuffLock)
				Mod+=0.75
			// if(src.isRace(HUMAN))
			// 	if(src.AscensionsAcquired)
			// 		Mod+=(src.AscensionsAcquired/20)
			if(src.CheckSlotless("What Must Be Done"))
				if(SlotlessBuffs["What Must Be Done"])
					if(SlotlessBuffs["What Must Be Done"].Password)
						Mod+=min(0.5, SlotlessBuffs["What Must Be Done"].Mastery/10)
			if(src.InfinityModule)
				var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/ki = src.FindSkill(/obj/Skills/Buffs/ActiveBuffs/Ki_Control)
				if(ki && "End" in ki.selectedStats)
					Mult += (AscensionsAcquired/10) * ki.EndMult
			// if((isRace(SAIYAN) || isRace(HALFSAIYAN))&&transActive&&!src.SpecialBuff)
			// 	if(src.race.transformations[transActive].mastery==100)
			// 		Mod+=0.1
			if(src.passive_handler["LegendarySaiyan"]==1)
				if(src.Tension>=50&&src.Tension<src.getMaxTensionValue())
					Mod+=0.01*(src.Tension/10)
				else if(src.Tension>=src.getMaxTensionValue())
					Mod+=1
			if(glob.racials.DEVIL_ARM_STAT_MULTS)
				if(src.CheckSlotless("Devil Arm")&&!src.SpecialBuff)
					Mod+=(0.05 * AscensionsAcquired)
			if(src.EndStolen)
				Mod+=src.EndStolen*0.5
			if(Secret == "Heavenly Restriction")
				if(secretDatum?:hasImprovement("Endurance"))
					Mod += round(clamp(1 + secretDatum?:getBoon(src, "Endurance") / 8, 1, 8), 0.1)
			Mod += (scalingEldritchPower() / 10);
			var/BM=src.HasBuffMastery()
			if(BM)
				if(Mod<=glob.BUFF_MASTERY_LOWTHRESHOLD)
					Mod*=(1+(BM*glob.BUFF_MASTERY_LOWMULT))
				else if(Mod>=glob.BUFF_MASTER_HIGHTHRESHOLD)
					Mod*=(1+(BM*glob.BUFF_MASTERY_HIGHMULT))

			if(src.CheckSlotless("Genesic Brave")||src.CheckSpecial("King of Braves")) //okay take two
				if(glob.KOB_GETS_STATS_LOW_LIFE)
					var/threshold = 25 * (1 - src.HealthCut)
					if(src.Health <= threshold)
						var/hp_safe = max(src.Health, 0.001) //this takes either health, or 0.001 to avoid negative values for the first stage
						var/base_bonus = min(10 / hp_safe, 1) //This is based on the old formula! This one was fine I was just being r[censored]. This means KoB get their full low hp buff at 10%.
						Mod += base_bonus

					if(src.passive_handler.Get("Color of Courage") && src.Health < 0) //This uses the NEW formula where the extra bonus caps at 1 at [TRIPLEHELIX_MAX_NEG_HP]
						var/minhp = glob.TRIPLEHELIX_MAX_NEG_HP
						if(minhp >= 0)
							minhp = -1 //Makes sure this can't be a Positive value so you don't get the opposite issue as the first stage
						var/den2 = 0 - minhp //normalization of range
						if(den2 <= 0)
							den2 = 1
						var/t2 = (0 - src.Health) / den2
						t2 = max(0, min(t2, 1))
						var/extra_max_bonus = 1.0
						Mod += extra_max_bonus * t2 //No cap this time, you get the "full bonus" once you get your ass knocked down, which essentially means you keep getting stronger as you near knockdown

			if(passive_handler["Rebel Heart"])
				var/h = (((missingHealth())/glob.REBELHEARTMOD) * passive_handler["Rebel Heart"])/10
				Mod+=h
			if(HardenAccumulated) Mod *= getHardenMult();
			if(src.Shatter)
				if(!src.HasDebuffResistance()>=1)
					var/debuffRev = src.GetDebuffReversal();
					if(debuffRev)
						Mod*=1 + Shatter * glob.DEBUFF_EFFECTIVENESS * debuffRev;
					else
						Mod*=1 - Shatter * glob.DEBUFF_EFFECTIVENESS
			if(src.EndEroded)
				Mod-=src.EndEroded
			if(passive_handler.Get("TensionPowered")&&transActive>=3)
				Mod+=passive_handler.Get("TensionPowered")/2
			if(passive_handler.Get("TensionPowered")&&transActive>=4)
				Mod+=passive_handler.Get("TensionPowered")/2
				if(isRace(HUMAN))
					Mod+=(passive_handler.Get("TensionPowered")/2)
			if(passive_handler.Get("Determination(Green)")||passive_handler.Get("Determination(White)"))
				Mod+=(0.02*ManaAmount)
			if(src.RebirthHeroPath=="Red" && src.SagaLevel>=3)
				Mod *= 1+ (src.HealthAnnounce10/5)
			if(src.StyleRating > 0)
				Mod += 0.1 * src.StyleRating * src.getStyleBonusMult()
			if(src.passive_handler.Get("Longing")&&src.Target)
				if(Target.Anger>1&&Anger<=1&&!src.passive_handler.Get("LunarWrath")&&!src.Target.passive_handler.Get("LunarWrath"))
					End*=1+((Target.Anger-1)/glob.LONGING_DIVISOR)
				else
					End*=1
			var/ETM=GetEndTransMult()
			End*=ETM
			End*=Mod
			End*=Mult
			if(src.HasMirrorStats())
				if(src.Target&&src.Target!=src&&!src.Target.HasMirrorStats()&&istype(src.Target, /mob/Players)&&!Target.passive_handler.Get("To Govern Strength"))
					End=src.Target.GetEnd()
			var/TotalTax
			if(src.EndTax)
				TotalTax+=src.EndTax
			if(src.EndCut)
				TotalTax+=src.EndCut
			if(HasUnbreakable())
				TotalTax*=1-GetUnbreakable()
			if(TotalTax>=1)
				TotalTax=0.9
			var/Sub=End*TotalTax
			End-=Sub
			End+=src.GetMA("End")
			if(src.HasAdaptation())
				if(src.AdaptationCounter!=0&&!CheckSlotless("Great Ape"))
					if(src.Target&&src.AdaptationTarget==src.Target)
						End+=(((src.Target.GetMA("Str")+src.Target.GetMA("For"))*0.5)*src.AdaptationCounter)
			if(Secret == "Heavenly Restriction")
				if(secretDatum?:hasRestriction("Endurance") && End > 1)
					End = 1
			if(End<0.1)
				End=0.1
			return End

		GetSpd(Mult=1)
			var/Spd=src.SpdMod
			var/EldritchMod=0
/*			if(src.EldritchPacted)
				switch(src.ReflectedPactType)
					if("Devotion")
						EldritchMod=0.5
					if("Power")
						EldritchMod=0.25
					if("Knowledge")
						EldritchMod=0.25
					if("Ambition")
						EldritchMod=1
					if("Survival")
						EldritchMod=0*/
			Spd+=EldritchMod
			var/EffectiveAsc=src.SpdAscension
			if(passive_handler.Get("Half Manifestation"))
				EffectiveAsc+=src.HandleManifestation("Spd")
			if(passive_handler.Get("SpiralPowerUnlocked"))
				var/SP=passive_handler.Get("SpiralPowerUnlocked")
				EffectiveAsc+=src.HandleSpiralUnlock("Spd", SP)

			Spd+=EffectiveAsc
			var/enhanced = getEnhanced("Speed")
			Spd+=EnhancedSpeed ? enhanced : 0
			Spd*=src.SpdChaos

			if(src.SpdReplace)
				Spd=SpdReplace
			if(passive_handler.Get("Piloting")&&findMecha())
				Spd = getMechStat(findMecha(), Spd)
			Spd+=SpdAdded
			Spd+=src.GetEquippedWeaponStatAdd("Spd")
			if(UsingHotnCold())
				if(StyleBuff?:hotCold<0)
					Spd-=abs(StyleBuff?:hotCold)/glob.HOTNCOLD_STAT_DIVISOR
				else
					Spd+=abs(StyleBuff?:hotCold)/glob.HOTNCOLD_STAT_DIVISOR
			if(src.HasManaStats())
				Spd += getManaStatsBoon()
			var/Mod=1
			Mod+=(src.SpdMultTotal-1)
			if(KaiokenBP > 1)
				Mod += KaiokenBP-0.5
			if(src.KamuiBuffLock)
				Mod+=0.75
			if(Saga&&src.Saga=="Eight Gates")
				Mod+=0.01*GatesActive
			if(passive_handler["Determination(Red)"]||passive_handler["Determination(Yellow)"]||passive_handler.Get("Determination(White)"))
				Mod+=(0.025*ManaAmount)
			if(Secret == "Heavenly Restriction")
				if(secretDatum?:hasImprovement("Speed"))
					Mod += round(clamp(1 + secretDatum?:getBoon(src, "Speed") / 8, 1, 8), 0.1)
			if(src.CheckSlotless("What Must Be Done"))
				if(SlotlessBuffs["What Must Be Done"].Password)
					Mod+=min(0.5, SlotlessBuffs["What Must Be Done"].Mastery/10)
			if(src.InfinityModule)
				var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/ki = src.FindSkill(/obj/Skills/Buffs/ActiveBuffs/Ki_Control)
				if(ki && "Spd" in ki.selectedStats)
					Mult += (AscensionsAcquired/10) * ki.SpdMult
			// if((isRace(SAIYAN) || isRace(HALFSAIYAN))&&transActive&&!src.SpecialBuff)
			// 	if(src.race.transformations[transActive].mastery==100)
			// 		Mod+=0.1
			if(glob.racials.DEVIL_ARM_STAT_MULTS)
				if(src.CheckSlotless("Devil Arm")&&!src.SpecialBuff)
					Mod+=(0.05 * AscensionsAcquired)

			if(src.SpdStolen)
				Mod+=src.SpdStolen*0.5
			if(FuryAccumulated) Mod *= src.getFuryMult();
			Mod += (scalingEldritchPower() / 10);
			var/BM=src.HasBuffMastery()
			if(passive_handler["Rebel Heart"])
				var/h = (((missingHealth())/glob.REBELHEARTMOD) * passive_handler["Rebel Heart"])/10
				Mod+=h
			if(BM)
				if(Mod<=glob.BUFF_MASTERY_LOWTHRESHOLD)
					Mod*=(1+(BM*glob.BUFF_MASTERY_LOWMULT))
				else if(Mod>=glob.BUFF_MASTER_HIGHTHRESHOLD)
					Mod*=(1+(BM*glob.BUFF_MASTERY_HIGHMULT))
			if(passive_handler.Get("BurningShot"))
				if(src.Burn)
					if(src.Burn>0&&src.Burn<=25)
						Mod+=0.25*src.passive_handler.Get("BurningShot")
					else if(src.Burn>25&&src.Burn<=75)
						Mod+=0.5*src.passive_handler.Get("BurningShot")
					else
						Mod+=0.75*src.passive_handler.Get("BurningShot")
			if(src.Slow)
				if(!src.HasDebuffResistance()>=1)
					var/debuffRev = src.GetDebuffReversal();
					if(debuffRev)
						Mod*= 1 + (Slow * glob.DEBUFF_EFFECTIVENESS * debuffRev);
					else
						Mod*= 1 - (Slow * glob.DEBUFF_EFFECTIVENESS)
			if(src.SpdEroded)
				Mod-=src.SpdEroded

			if(Secret && Secret == "Werewolf" && CheckSlotless("Full Moon Form"))
				Mod += 1 * (secretDatum?:getHungerBoon())
			if(passive_handler.Get("TensionPowered"))
				Mod+=((passive_handler.Get("TensionPowered")*2))
			if(src.RebirthHeroPath=="Red" && src.SagaLevel>=3)
				Mod *= 1+ (src.HealthAnnounce10/10)
			if(Secret == "Shin" && CheckSlotless("Mang Resonance"))
				Mod += GetMangStats() // you can find this proc in Secrets\Shin\buff.dm
			if(src.StyleRating > 0)
				Mod += 0.1 * src.StyleRating * src.getStyleBonusMult()
			// Demon Devil Trigger sins bonus
			Mod += getDevilTriggerSinBonusMult()
			Mod += getMazokuSinBonusMult()
			if(IsDarkDragonPlayer() && Frenzy > 0)
				Mod += 0.5 * (min(Frenzy, glob.DEBUFF_STACK_MAX) / glob.DEBUFF_STACK_MAX)
			var/SpTM=GetSpdTransMult()
			Spd*=SpTM
			Spd*=Mod
			Spd*=Mult
			if(src.HasMirrorStats())
				if(src.Target&&src.Target!=src&&!src.Target.HasMirrorStats()&&istype(src.Target, /mob/Players)&&!Target.passive_handler.Get("To Govern Strength"))
					Spd=src.Target.GetSpd()
			var/TotalTax
			if(src.SpdTax)
				TotalTax+=src.SpdTax
			if(src.SpdCut)
				TotalTax+=src.SpdCut
			if(HasUnbreakable())
				TotalTax*=1-GetUnbreakable()
			if(TotalTax>=1)
				TotalTax=0.9
			var/Sub=Spd*TotalTax
			Spd-=Sub
			Spd+=src.GetMA("Spd")
			// if(src.UsingYinYang()&&src.Target&&src.Target!=src&&!src.Target.UsingYinYang()&&istype(src.Target, /mob/Players))
			// 	Spd+=src.Target.GetMA("Spd")*0.5
			// else
			if(src.HasAdaptation())
				if(src.AdaptationCounter!=0&&!CheckSlotless("Great Ape"))
					if(src.Target&&src.AdaptationTarget==src.Target)
						Spd+=(src.Target.GetMA("Spd")*0.5*src.AdaptationCounter)
			if(Secret == "Heavenly Restriction")
				if(secretDatum?:hasRestriction("Speed") && Speed > 1)
					Speed = 1
			if(Spd<0.1)
				Spd=0.1
			return Spd

		GetOff(var/Mult=1)
			var/Off=src.OffMod
			var/EldritchMod=0
/*			if(src.EldritchPacted)
				switch(src.ReflectedPactType)
					if("Devotion")
						EldritchMod=0.5
					if("Power")
						EldritchMod=0.5
					if("Knowledge")
						EldritchMod=0.5
					if("Ambition")
						EldritchMod=0
					if("Survival")
						EldritchMod=0*/
			Off+=EldritchMod
			var/EffectiveAsc=src.OffAscension
			if(passive_handler.Get("Half Manifestation"))
				EffectiveAsc+=src.HandleManifestation("Off")
			if(passive_handler.Get("SpiralPowerUnlocked"))
				var/SP=passive_handler.Get("SpiralPowerUnlocked")
				EffectiveAsc+=src.HandleSpiralUnlock("Off", SP)

			Off+=EffectiveAsc
			var/enhanced = getEnhanced("Aggression")
			Off+=EnhancedAggression ? enhanced : 0
			Off*=src.OffChaos
			if(passive_handler.Get("Piloting")&&findMecha())
				Off = getMechStat(findMecha(), Off)
			Off+=OffAdded
			Off+=src.GetEquippedWeaponStatAdd("Off")
			var/Mod=1
			Mod+=(src.OffMultTotal-1)
			// if(src.isRace(HUMAN))
			// 	if(src.AscensionsAcquired)
			// 		Mod+=(src.AscensionsAcquired/20)
			if(Secret == "Heavenly Restriction")
				if(secretDatum?:hasImprovement("Offense"))
					Mod += round(clamp(1 + secretDatum?:getBoon(src, "Offense") / 8, 1, 8), 0.1)
			if(src.OffStolen)
				Mod+=src.OffStolen*0.5
			var/BM=src.HasBuffMastery()
			if(BM)
				if(Mod<=glob.BUFF_MASTERY_LOWTHRESHOLD)
					Mod*=(1+(BM*glob.BUFF_MASTERY_LOWMULT))
				else if(Mod>=glob.BUFF_MASTER_HIGHTHRESHOLD)
					Mod*=(1+(BM*glob.BUFF_MASTERY_HIGHMULT))
			if(passive_handler.Get("BurningShot"))
				if(src.Burn)
					if(src.Burn>0&&src.Burn<=25)
						Mod+=0.25*passive_handler.Get("BurningShot")
					else if(src.Burn>25&&src.Burn<=75)
						Mod+=0.5*passive_handler.Get("BurningShot")
					else
						Mod+=0.75*passive_handler.Get("BurningShot")
			if(src.Shock)
				if(!src.HasDebuffResistance()>=1)
					var/debuffRev = src.GetDebuffReversal();
					if(debuffRev)
						Mod*=1 + (Shock * glob.DEBUFF_EFFECTIVENESS * debuffRev);
					else
						Mod*= 1 - (Shock * glob.DEBUFF_EFFECTIVENESS)
			if(passive_handler["Rebel Heart"])
				var/h = (((missingHealth())/glob.REBELHEARTMOD) * passive_handler["Rebel Heart"])/10
				Mod+=h
			if(src.OffEroded)
				Mod-=src.OffEroded
			if(passive_handler.Get("TensionPowered")&&transActive>=2)
				Mod+=passive_handler.Get("TensionPowered")
			if(Secret == "Shin" && CheckSlotless("Mang Resonance"))
				Mod += GetMangStats() // you can find this proc in Secrets\Shin\buff.dm
			if(src.StyleRating > 0)
				Mod += 0.1 * src.StyleRating * src.getStyleBonusMult()
			// Demon Devil Trigger sins bonus
			Mod += getDevilTriggerSinBonusMult()
			Mod += getMazokuSinBonusMult()
			if(IsDarkDragonPlayer() && Frenzy > 0)
				Mod += 0.5 * (min(Frenzy, glob.DEBUFF_STACK_MAX) / glob.DEBUFF_STACK_MAX)
			var/OTM=GetOffTransMult()
			if(src.passive_handler.Get("Longing")&&src.Target)
				if(Target.GetPowerUpRatio()>=Target.Power_Multiplier)
					Off*=clamp(1+((Target.GetPowerUpRatio()-1)/glob.LONGING_DIVISOR),1, glob.LONGING_MAX_CLAMP)
				else if(Target.Power_Multiplier>=Target.GetPowerUpRatio())
					Off*=clamp(1+((Target.Power_Multiplier-1)/glob.LONGING_DIVISOR),1, glob.LONGING_MAX_CLAMP)
				else
					Off*=1
			Off*=OTM
			Off*=Mod
			Off*=Mult
			if(src.HasMirrorStats())
				if(src.Target&&src.Target!=src&&!src.Target.HasMirrorStats()&&istype(src.Target, /mob/Players)&&!Target.passive_handler.Get("To Govern Strength"))
					Off=src.Target.GetOff()
			var/TotalTax
			if(src.OffTax)
				TotalTax+=src.OffTax
			if(src.OffCut)
				TotalTax+=src.OffCut
			if(HasUnbreakable())
				TotalTax*=1-GetUnbreakable()
			if(TotalTax>=1)
				TotalTax=0.9
			var/Sub=Off*TotalTax
			Off-=Sub
			Off+=src.GetMA("Off")
			// if(src.UsingYinYang()&&src.Target&&src.Target!=src&&!src.Target.UsingYinYang()&&istype(src.Target, /mob/Players))
			// 	Off+=src.Target.GetMA("Def")*0.5
			// else
			if(src.HasAdaptation())
				if(src.AdaptationCounter!=0&&!CheckSlotless("Great Ape"))
					if(src.Target&&src.AdaptationTarget==src.Target)
						Off+=(src.Target.GetMA("Def")*0.5*src.AdaptationCounter)
			if(Secret == "Heavenly Restriction")
				if(secretDatum?:hasRestriction("Offense") && Off > 1)
					Off = 1
			if(Off<0.1)
				Off=0.1
			return Off

		GetDef(var/Mult=1)
			var/Def=src.DefMod
			var/EldritchMod=0
/*			if(src.EldritchPacted)
				switch(src.ReflectedPactType)
					if("Devotion")
						EldritchMod=0.5
					if("Power")
						EldritchMod=0
					if("Knowledge")
						EldritchMod=0
					if("Ambition")
						EldritchMod=0.5
					if("Survival")
						EldritchMod=0.5*/
			Def+=EldritchMod
			var/EffectiveAsc=src.DefAscension
			if(passive_handler.Get("Half Manifestation"))
				EffectiveAsc+=src.HandleManifestation("Def")
			if(passive_handler.Get("SpiralPowerUnlocked"))
				var/SP=passive_handler.Get("SpiralPowerUnlocked")
				EffectiveAsc+=src.HandleSpiralUnlock("Def", SP)

			Def+=EffectiveAsc
			var/enhanced = getEnhanced("Reflexes")
			Def+=EnhancedReflexes ? enhanced : 0
			Def*=src.DefChaos
			if(passive_handler.Get("Piloting")&&findMecha())
				if(PilotingProwess>=7)
					Def = getMechStat(findMecha(), Def) * 0.25
				else
					Def = 0.25


			Def+=DefAdded
			Def+=src.GetEquippedWeaponStatAdd("Def")
			var/Mod=1
			Mod+=(src.DefMultTotal-1)
			// if(src.isRace(HUMAN))
			// 	if(src.AscensionsAcquired)
			// 		Mod+=(src.AscensionsAcquired/20)
			if(Secret == "Heavenly Restriction")
				if(secretDatum?:hasImprovement("Defense"))
					Mod += round(clamp(1 + secretDatum?:getBoon(src, "Defense") / 8, 1, 8), 0.1)
			if(src.DefStolen)
				Mod+=src.DefStolen*0.5
			var/BM=src.HasBuffMastery()
			if(BM)
				if(Mod<=glob.BUFF_MASTERY_LOWTHRESHOLD)
					Mod*=(1+(BM*glob.BUFF_MASTERY_LOWMULT))
				else if(Mod>=glob.BUFF_MASTER_HIGHTHRESHOLD)
					Mod*=(1+(BM*glob.BUFF_MASTERY_HIGHMULT))
			if(passive_handler.Get("BurningShot"))
				if(src.Burn)
					if(src.Burn>0&&src.Burn<=25)
						Mod+=0.25*passive_handler.Get("BurningShot")
					else if(src.Burn>25&&src.Burn<=75)
						Mod+=0.5*passive_handler.Get("BurningShot")
					else
						Mod+=0.75*passive_handler.Get("BurningShot")
			if(src.Shock)
				if(!src.HasDebuffResistance()>=1)
					var/debuffRev = src.GetDebuffReversal();
					if(debuffRev)
						Mod*=1 + (Shock * glob.DEBUFF_EFFECTIVENESS * debuffRev);
					else
						Mod*=1 - (Shock * glob.DEBUFF_EFFECTIVENESS)
			if(passive_handler["Rebel Heart"])
				var/h = (((missingHealth())/glob.REBELHEARTMOD) * passive_handler["Rebel Heart"])/10
				Mod+=h
			if(src.DefEroded)
				Mod-=src.DefEroded
			if(passive_handler.Get("TensionPowered")&&transActive>=2)
				Mod+=passive_handler.Get("TensionPowered")
			if(src.StyleRating > 0)
				Mod += 0.1 * src.StyleRating * src.getStyleBonusMult()
			// Demon Devil Trigger sins bonus
			Mod += getDevilTriggerSinBonusMult()
			Mod += getMazokuSinBonusMult()
			var/DTM=GetDefTransMult()
			if(src.passive_handler.Get("Longing")&&src.Target)
				if(Target.Anger>1&&Anger<=1&&!src.Target.passive_handler.Get("LunarWrath"))
					Def*=1+((Target.Anger-1)/glob.LONGING_DIVISOR)//clamp(1+((Target.Power_Multiplier-1)/glob.LONGING_DIVISOR),1, glob.LONGING_MAX_CLAMP)
				else
					Def*=1
			Def*=DTM
			Def*=Mod
			Def*=Mult
			if(src.HasMirrorStats())
				if(src.Target&&src.Target!=src&&!src.Target.HasMirrorStats()&&istype(src.Target, /mob/Players)&&!Target.passive_handler.Get("To Govern Strength"))
					Def=src.Target.GetDef()
			var/TotalTax
			if(src.DefTax)
				TotalTax+=src.DefTax
			if(src.DefCut)
				TotalTax+=src.DefCut
			if(HasUnbreakable())
				TotalTax*=1-GetUnbreakable()
			if(TotalTax>=1)
				TotalTax=0.9
			var/Sub=Def*TotalTax
			Def-=Sub
			Def+=src.GetMA("Def")
			// if(src.UsingYinYang()&&src.Target&&src.Target!=src&&!src.Target.UsingYinYang()&&istype(src.Target, /mob/Players))
			// 	Def+=src.Target.GetMA("Off")*0.5
			// else
			if(src.HasAdaptation())
				if(src.AdaptationCounter!=0&&!CheckSlotless("Great Ape"))
					if(src.Target&&src.AdaptationTarget==src.Target)
						Def+=(src.Target.GetMA("Off")*0.5*src.AdaptationCounter)
			if(Secret == "Heavenly Restriction")
				if(secretDatum?:hasRestriction("Defense") && Def > 1)
					Def = 1
			if(Def<0.1)
				Def=0.1
			return Def

		GetRecov(var/Mult=1)
			var/Recov=src.RecovMod
			Recov+=src.RecovAscension
			if(src.RecovReplace)
				Recov=src.RecovReplace
			if(src.HasHellPower()||(src.Secret=="Werewolf"&&(!src.CheckSlotless("Half Moon Form")))||src.HasZenkaiPower())
				if(Recov<2)
					Recov=2
			if(src.isRace(MAJIN))
				Recov=2

			var/Mod=1
			if(src.HasManaStats())
				var/manaStatPerc = GetManaStats() // 0.1 per tick
				var/maxStatBoon = 1
				var/baseBoon = 0.25
				var/manaMissing = (ManaAmount / ManaMax)
				var/bonus = baseBoon * manaMissing * manaStatPerc >= maxStatBoon ? maxStatBoon : baseBoon * manaMissing * manaStatPerc
				Mod += bonus

			Mod+=(src.RecovMultTotal-1)
			var/BM=src.HasBuffMastery()
			if(BM)
				if(Mod<=glob.BUFF_MASTERY_LOWTHRESHOLD)
					Mod*=(1+(BM*glob.BUFF_MASTERY_LOWMULT))
				else if(Mod>=glob.BUFF_MASTER_HIGHTHRESHOLD)
					Mod*=(1+(BM*glob.BUFF_MASTERY_HIGHMULT))
			if(src.CheckSlotless("Genesic Brave")||src.CheckSpecial("King of Braves"))
				if(glob.KOB_GETS_STATS_LOW_LIFE)
					if(src.Health<=25*(1-src.HealthCut))
						var/thisVar = 10/Health < 0 ? 0.1 : 10/Health
						Mod+=thisVar
			if(src.RecovEroded)
				Mod-=src.RecovEroded

			Recov*=Mod
			Recov*=Mult
			Recov*=src.RecovChaos
			if(src.isRace(NAMEKIAN)&&src.transActive())
				if(Recov<2)
					Recov=2
			if(src.RippleActive())
				Recov*=max(min(src.Oxygen/src.OxygenMax,1.5),0.5)
			var/TotalTax
			if(src.RecovTax)
				TotalTax+=src.RecovTax
			if(src.RecovCut)
				TotalTax+=src.RecovCut
			if(HasUnbreakable())
				TotalTax*=1-GetUnbreakable()
			if(TotalTax>=1)
				TotalTax=0.9
			var/Sub=Recov*TotalTax
			Recov-=Sub
			if(Recov<0.1)
				Recov=0.1
			return Recov


		NewAnger(var/num, var/Override=0)
			if(!Override)
				if(src.AngerMax < num)
					src.AngerMax = num
			else
				src.AngerMax=num
		AngerMult(var/num)
			src.AngerMax=1+((src.AngerMax-1)*num)
		AngerDiv(var/num)
			src.AngerMax=1+((src.AngerMax-1)/num)
		LunarWrathAnger()
			if(src.ManaAmount>=50 && src.passive_handler.Get("LunarWrath"))
				src.AngerMax=1+(src.ManaAmount/100)
			if(src.passive_handler.Get("Unrelenting Wrath"))
				src.AngerMax=5
			else
				src.AngerMax=1
		WeirdAngerStuff() //additive anger that won't be affected by mult
			var/AngerTotal
			if(src.passive_handler.Get("Red Hot Rage"))
				AngerTotal+=((src.PowerControl-100)/100)+(passive_handler.Get("PUSpike")/100)
				if(AngerTotal>=500)
					var/obj/Skills/s = src.findOrAddSkill(/obj/Skills/AutoHit/Platinum_Mad)
					src.Activate(s)
					spawn(100)
						del s
			if(src.passive_handler.Get("Determination(Black)"))
				AngerTotal+=(50*src.SagaLevel)-src.Health
			else
				AngerTotal=0
			src.AngerAdd=AngerTotal

		GetBPM()
			return (src.potential_power_mult)
		BPMult(var/num)
			src.Base*=num
		BPDiv(var/num)
			src.Base/=num
		TransMastery(var/num)
			return race.transformations[num].mastery
		transActive()
			return transActive
		TransAuraFound()
			if(src.transActive())
				if(src.transActive()==1)
					if(src.Form1Aura)
						return 1
				if(src.transActive()==2)
					if(src.Form2Aura)
						return 1
				if(src.transActive()==3)
					if(src.Form3Aura)
						return 1
				if(src.transActive()==4)
					if(src.Form4Aura)
						return 1
			return 0
		transActiveDown()
			transActive--
		MakeSword(var/obj/Items/Sword/s, var/damage, var/acc, var/icon/i=null, var/px=0, var/py=0)
			s.DamageEffectiveness=damage
			s.AccuracyEffectiveness=acc
			s.AlignEquip(src)
			if(i)
				s.icon=i
				s.pixel_x=px
				s.pixel_y=py
			s.AlignEquip(src)
		ArmorShatter()
			var/obj/Items/Armor/ar=src.EquippedArmor()
			OMsg(src, "[src]'s armor has shattered!!")
			if(src.StyleBuff)
				if(src.StyleBuff.NeedsArmor||src.StyleBuff.MakesArmor)
					src.StyleBuff.Trigger(src, Override=1)
					if(src.StyleBuff.MakesArmor)
						del(ar)
			if(src.ActiveBuff)
				if(src.ActiveBuff.NeedsArmor||src.ActiveBuff.MakesArmor)
					src.ActiveBuff.Trigger(src, Override=1)
					if(src.ActiveBuff.MakesArmor)
						del(ar)
			if(src.SpecialBuff)
				if(src.SpecialBuff.NeedsArmor||src.SpecialBuff.MakesArmor)
					src.SpecialBuff.Trigger(src, Override=1)
					if(src.SpecialBuff.MakesArmor)
						del(ar)
			for(var/b in SlotlessBuffs)
				var/obj/Skills/Buffs/SlotlessBuffs/sb = SlotlessBuffs[b]
				if(sb)
					if(sb.NeedsArmor||sb.MakesArmor)
						sb.Trigger(src, Override=1)
						if(sb.MakesArmor)
							del(ar)
			if(ar)
				ar.ObjectUse(User=src)
				spawn(10)
					ar.suffix="*Broken*"
					ar.Broken=1
		StaffShatter()
			var/obj/Items/Enchantment/Staff/st=src.EquippedStaff()
			OMsg(src, "[src]'s staff has shattered!!")
			if(src.StyleBuff)
				if(src.StyleBuff.NeedsStaff||src.StyleBuff.MakesStaff)
					src.StyleBuff.Trigger(src, Override=1)
					if(src.StyleBuff.MakesStaff)
						del(st)
			if(src.ActiveBuff)
				if(src.ActiveBuff.NeedsStaff||src.ActiveBuff.MakesStaff)
					src.ActiveBuff.Trigger(src, Override=1)
					if(src.ActiveBuff.MakesStaff)
						del(st)
			if(src.SpecialBuff)
				if(src.SpecialBuff.NeedsStaff||src.SpecialBuff.MakesStaff)
					src.SpecialBuff.Trigger(src, Override=1)
					if(src.SpecialBuff.MakesStaff)
						del(st)
			for(var/b in SlotlessBuffs)
				var/obj/Skills/Buffs/SlotlessBuffs/sb = SlotlessBuffs[b]
				if(sb)
					if(sb.NeedsStaff||sb.MakesStaff)
						sb.Trigger(src, Override=1)
						if(sb.MakesStaff)
							del(st)
			if(st)
				st.ObjectUse(User=src)
				spawn(10)
					st.suffix="*Broken*"
					st.Broken=1
		SwordShatter(var/obj/Items/Sword/PassedSword=null)
			var/obj/Items/Sword/s
			if(PassedSword)
				s=PassedSword
			else
				s=src.EquippedSword()
			src.OMessage(10, "[src]'s sword has shattered!!", "[src]([src.key]) got their sword broken.")
			if(src.StyleBuff)
				if(src.StyleBuff.NeedsSword||src.StyleBuff.MakesSword)
					if(StyleBuff.MakesSword||StyleBuff.NeedsSword&&!passive_handler["Sword Master"])
						src.StyleBuff.Trigger(src, Override=1)
					if(src.StyleBuff.MakesSword)
						del(s)
					else
			if(src.ActiveBuff)
				if(src.ActiveBuff.NeedsSword||src.ActiveBuff.MakesSword)
					if(ActiveBuff.MakesSword||ActiveBuff.NeedsSword&&!passive_handler["Sword Master"])
						ActiveBuff.Trigger(src, Override=1)
					if(src.ActiveBuff.MakesSword)
						del(s)
			if(src.SpecialBuff)
				if(src.SpecialBuff.NeedsSword||src.SpecialBuff.MakesSword)
					if(SpecialBuff.MakesSword||SpecialBuff.NeedsSword&&!passive_handler["Sword Master"])
						src.SpecialBuff.Trigger(src, Override=1)
					if(src.SpecialBuff.MakesSword)
						del(s)
			for(var/b in SlotlessBuffs)
				var/obj/Skills/Buffs/SlotlessBuffs/sb = SlotlessBuffs[b]
				if(sb)
					if(sb.NeedsSword||sb.MakesSword)
						if(sb.MakesSword||sb.NeedsSword&&!passive_handler["Sword Master"])
							sb.Trigger(src, Override=1)
						if(sb.MakesSword)
							del(s)
			if(s)
				if(s.suffix=="*Equipped*")
					s.ObjectUse(User=src)
				else//this is in case the sword was dual / triple wielded
					var/obj/Items/Sword/ActualSword=src.EquippedSword()
					ActualSword.ObjectUse(User=src)
				if(length(s.Techniques)>0)
					for(var/obj/Skills/skill in Skills)
						if(skill.AssociatedGear==s)
							if(istype(/obj/Skills/Buffs, skill))
								var/obj/Skills/Buffs/Buff = skill
								if(Buff && BuffOn(Buff))
									Buff.Trigger(src, Override=1)
							del skill
				spawn(10)
					s.suffix="*Broken*"//unequip that bitch
					s.Broken=1//can't be worn (for nyow)
					s.onBroken()
					if(s.Glass)
						OMsg(src, "[src]'s glass weaponry shatters into a million pieces!")
						if(!s.HighFrequency)
							del s
						else if(!s.HighFrequency)
							OMsg(src, "But luckily, the hilt remains!")
					if(s.Conjured)
						OMsg(src, "[src]'s conjured weapontry shatters into arcane mist!")
						del s

		IsGrabbed()
			for(var/mob/Players/M in players)
				if(M.Grab==src)
					return M
			return 0

		StandardBiology()
			if(src.XenoBiology())
				return 0
			else
				return 1
			return 0
		XenoBiology()//might be useful for some anti-monster/anti-inhuman style later
			if(passive_handler.Get("Xenobiology"))
				return 1
			if(hasEldritchRacial()) return 1;
			return 0

		IsGood()
			if(hasEldritchPower()) return 0;
			var/list/EvilRaces=list(DEMON, DRAGON)
			var/list/EvilSecrets=list("Vampire", "Werewolf", "Zombie")
			//these are all bad.
			var/good = 0
			var/evil = 0
			if(src.passive_handler.Get("Emptiness"))
				return FALSE
			if(src.HasMaki())
				evil = 1
			if(!HasHolyMod())
				for(var/evilRaceName in EvilRaces)
					if(isRace(evilRaceName))
						evil = 1
						break
				if(src.Secret in EvilSecrets)
					evil = 1
				if(src.HasAbyssMod())
					evil = 1
			if(src.ShinjinAscension=="Makai")
				evil = 1
			if(src.HasHellPower())
				evil = 1
			if(istype(src, /mob/Player/AI))
				evil = 1
			//these are all good.
			if(src.ShinjinAscension=="Kai")
				good = 1
			if(src.HasHolyMod() && !src.HasAbyssMod())
				good = 1
			if(src.Secret=="Ripple")
				good = 1
			if(src.GetSpiritPower()>=1)
				good = 1

			if(passive_handler.Get("Illusion"))
				if(evil)
					good = 1
					evil = 0
				else if(good)
					good = 0
					evil = 1
			if(isRace(MAKAIOSHIN))
				return TRUE
			if(good)
				return TRUE
			if(evil)
				return FALSE
			if(src.HasMaouKi())
				return FALSE
			return 0
		IsEvil()
			if(hasEldritchPower()) return 0;
			var/list/EvilRaces=list(DEMON, DRAGON)
			var/list/EvilSecrets=list("Vampire", "Werewolf", "Zombie")
			var/good = 0
			var/evil = 0
			if(src.passive_handler.Get("Emptiness"))
				return FALSE
			//these are all good.
			if(src.ShinjinAscension=="Kai")
				good = 1
			if(src.HasHolyMod() && !src.HasAbyssMod())
				good = 1
			if(src.GetSpiritPower()>=1)
				good = 1
			//these are all bad.
			if(src.HasMaki())
				evil = 1
			if(KeybladeColor=="Darkness")
				evil = 1
			for(var/race in EvilRaces)
				if(isRace(race))
					evil = 1
			if(src.Secret in EvilSecrets)
				evil = 1
			if(src.ShinjinAscension=="Makai")
				evil = 1
			if(src.HasHellPower())
				evil = 1
			if(src.HasAbyssMod())
				evil = 1
			if(istype(src, /mob/Player/AI))
				evil = 1
			if(src.NoDeath && !hasEldritchPower())
				evil = 1
			if(passive_handler.Get("Illusion"))
				if(good)
					good = 0
					evil = 1
				else if(evil)
					good = 1
					evil = 0
			if(isRace(MAKAIOSHIN))
				return TRUE
			if(good)
				return FALSE
			if(evil)
				return TRUE
			if(src.HasMaouKi())
				return FALSE
			return 0

		HolyDamage(var/mob/P, var/Forced=0)//Stick this in the DoDamage proc.
			//To get to this proc, you have to already have holy damage
			// holy strength when the attacker has no HolyMod passive.
			var/HolyDamageValue = Forced ? Forced : src.GetHolyMod()
			if(P.CheckSlotless("Devil Arm") && !P.isRace(DEMON) && !P.isRace(MAKAIOSHIN))
				if(!Forced)
					return HolyDamageValue
				else
					return HolyDamageValue
			if(P.UsingMuken())
				if(!Forced)
					return (-1)*src.GetHolyMod()
				else
					return (-1)*Forced
			else if(P.IsEvil() || HasBeyondPurity())
				if(!Forced)
					return HolyDamageValue
				else
					return HolyDamageValue
			else if(src.GetSpiritPower()>=0.25)
				if(!Forced)
					var/spiritPower = (GetSpiritPower() / 2)
					return max(HolyDamageValue*spiritPower, 1)
				else
					return HolyDamageValue
			else
				return 1
		AbyssDamage(mob/P, Forced=0)//Stick this in the DoDamage proc.
			//yadda yadda gotta have abyss
			// abyss strength when the attacker has no AbyssMod passive.
			var/AbyssDamageValue = Forced ? Forced : src.GetAbyssMod()
			if(P.UsingMuken())
				return (-1)*AbyssDamageValue
			if(HasMaouKi())
				return 2*src.GetAbyssMod()
			else if(P.IsGood())
				return AbyssDamageValue
			else if(GetSpiritPower()>=0.25)
				var/spiritPower = (GetSpiritPower() / 2)
				return clamp(AbyssDamageValue*spiritPower, 0.001, 10)
			return 0.001

		SpiritShift()
			var/SFStr=src.BaseFor()+(glob.SPIRIT_FORM_BASE_RATE*src.AscensionsAcquired*(src.BaseStr()-src.BaseFor()))
			var/SFFor=src.BaseStr()
			src.StrReplace=SFStr
			src.ForReplace=SFFor
		SpiritShiftBack()
			src.StrReplace=0
			src.ForReplace=0

		Flux()
			var/list/Chaos=list(0.6, 0.7, 0.7, 0.8, 0.8, 0.8, 0.9, 0.9, 0.9, 0.9, 1, 1, 1, 1, 1, 1.1, 1.1, 1.1, 1.1, 1.2, 1.2, 1.2, 1.3, 1.3, 1.4)
			src.StrChaos*=pick(Chaos)
			src.EndChaos*=pick(Chaos)
			src.SpdChaos*=pick(Chaos)
			src.ForChaos*=pick(Chaos)
			src.OffChaos*=pick(Chaos)
			src.DefChaos*=pick(Chaos)
			src.RecovChaos*=pick(Chaos)
			src.RecovChaos*=pick(Chaos)
		UnFlux()
			src.StrChaos=1
			src.EndChaos=1
			src.SpdChaos=1
			src.ForChaos=1
			src.OffChaos=1
			src.DefChaos=1
			src.RecovChaos=1
			src.RecovChaos=1

		SetHitSpark(var/icon, var/x1=0, var/y1=0, var/turn=0, var/size=1)
			src.BuffHitSparkIcon=icon
			src.BuffHitSparkX=x1
			src.BuffHitSparkY=y1
			src.BuffHitSparkTurns=turn
			src.BuffHitSparkSize=size
		ClearHitSpark()
			src.BuffHitSparkIcon=null
			src.BuffHitSparkX=0
			src.BuffHitSparkY=0
			src.BuffHitSparkTurns=0
			src.BuffHitSparkSize=1

		TakeMoney(var/Value)
			for(var/obj/Money/defender in src)
				defender.Level-=Value
				defender.name="[Commas(round(defender.Level))] [glob.progress.MoneyName]"
		TakeMineral(val)
			for(var/obj/Items/mineral/m in src)
				m.Reduce(val)
				m.name = "[Commas(round(m.value))] Mana Bits"
		GiveMoney(var/Value)
			for(var/obj/Money/defender in src)
				defender.Level+=Value
				defender.name="[Commas(round(defender.Level))] [glob.progress.MoneyName]"
				defender.checkDuplicate(src)
			src << "You've gained [Commas(round(Value))] [glob.progress.MoneyName]."
		GiveMineral(val)
			var/found=0;
			for(var/obj/Items/mineral/m in src)
				m.Add(val);
				found=1;
				break;
			if(!found)
				var/obj/Items/mineral/m = new();
				m.Add(val);
				src.contents += m;
		TakeManaCapacity(var/Value, ignorePhiloStone = FALSE)
			var/Remaining=Value
			if(!ignorePhiloStone)
				for(var/obj/Magic_Circle/MC in range(3, src))
					if(!MC.Locked)
						Remaining*=0.9
					else
						if(MC.Creator==src.ckey)
							Remaining*=0.75
					break
				for(var/obj/Items/Enchantment/PhilosopherStone/PS in src)
					if(!PS.ToggleUse) continue
					if(Remaining==PS.CurrentCapacity)
						Remaining=0
						PS.CurrentCapacity=0
					else if(Remaining>PS.CurrentCapacity)
						Remaining-=PS.CurrentCapacity
						PS.CurrentCapacity=0
					else if(PS.CurrentCapacity>Remaining)
						PS.CurrentCapacity-=Remaining
						Remaining=0
					if(0>=PS.CurrentCapacity) if(istype(PS, /obj/Items/Enchantment/PhilosopherStone/Magicite))
						src << "You burn out the mana in one of your magicite stones, causing it to crumble."
						contents-=PS
						PS.loc = null //garbage collection
						for(var/atom/a in PS.contents) PS.contents-=a //incase they sealed it i guess
					PS.desc="A philosopher's stone is the result of a sapient being transmuted into pure mana.  They regenerate capacity.<br>Your [PS] has [PS.CurrentCapacity] / [PS.MaxCapacity] capacity generated."
					if(Remaining==0)
						break
			if(Remaining>0)
				src.LoseCapacity(Remaining)
				//This proc only gets called if it has already been checked that someone has enough to pay...So nothing else should be necessary.
		DropMoney(var/Value)
			var/obj/Money/defender=new
			defender.Level=Value
			defender.name="[Commas(round(defender.Level))] [glob.progress.MoneyName]"
			defender.loc=get_step(src, src.dir)
			defender.MoneyCreator=src.key
			for(var/obj/Money/m2 in src)
				defender.icon=m2.icon
			src.TakeMoney(defender.Level)

		TriggerBinding()
			if(Binding&&src.z!=src.Binding[3])
				OMsg(src, "[src]'s binding pulls their body back to their sealed dimension!")
				src.loc=locate(Binding[1], Binding[2], Binding[3])
				OMsg(src, "[src] suddenly appears as a result of their binding!")

		SetStasis(var/StasisTime)
			StasisTime*=glob.STASIS_LENGTH_MODIFIER
			if(src.HasDebuffResistance())
				StasisTime/=min(1.5,passive_handler["DebuffResistance"])
			src.Stasis=StasisTime
			if(!src.StasisFrozen)
				src.StasisEffect("Form")
		RemoveStasis()
			src.Stasis=0
			if(src.StasisFrozen)
				src.StasisEffect("Thaw")
			if(src.StasisSpace)
				src.density=1
				src.Grabbable=1
				src.Incorporeal=0
				src.invisibility=0
				src.StasisSpace=0
				animate(src.client, color = null, time = 5)

		GatesMessage(var/NewGate)
			if(NewGate==1)
				if(src.GatesActive<1)
					OMsg(src, "[src] opens the First Gate: Gate of Opening!")
					return
			if(NewGate==2)
				if(src.GatesActive<2)
					OMsg(src, "[src] opens the Second Gate: Gate of Healing!")
					return
			if(NewGate==3)
				if(src.GatesActive<3)
					OMsg(src, "[src] opens the Third Gate: Gate of Life!")
					src.Quake(5)
					return
			if(NewGate==4)
				if(src.GatesActive<4)
					OMsg(src, "[src] opens the Fourth Gate: Gate of Pain!")
					src.Quake(5)
					return
			if(NewGate==5)
				if(src.GatesActive<5)
					OMsg(src, "[src] opens the Fifth Gate: Gate of Limit!")
					src.Quake(5)
					return
			if(NewGate==6)
				if(src.GatesActive<6)
					OMsg(src, "[src] opens the Sixth Gate: Gate of View!")
					src.Quake(10)
					return
			if(NewGate==7)
				if(src.GatesActive<7)
					OMsg(src, "[src] opens the Seventh Gate: Gate of Wonder!")
					src.Quake(10)
					return
			if(NewGate==8)
				if(src.GatesActive<8 && !Gate8Used)
					OMsg(src, "[src] opens the Eighth Gate: Gate of Death!")
					src.Quake(20)
					Gate8Used=1
					return

		AddCyberCancel(var/val)
			src.CyberCancel+=val
			if(!isRace(ANDROID))
				if(src.CyberCancel>0.75)
					src.CyberCancel=0.75
		RemoveCyberCancel(var/val)
			src.CyberCancel-=val
			if(src.CyberCancel<0)
				src.CyberCancel=0
			if(isRace(ANDROID))
				src.AddCyberCancel(1)
		SetCyberCancel()
			src.CyberCancel=0
			src.SetEnhanceChipCancel()
			src.SetMilitaryFrameCancel()
			src.SetConversionModuleCancel()
			if(src.CyberizeMod)
				if(src.CyberizeMod>=1)
					src.CyberCancel=0
				else if(src.CyberizeMod<1&&src.CyberizeMod>0)
					src.CyberCancel=src.CyberCancel-(src.CyberCancel*src.CyberizeMod)//remove portion of nerfs
			if(src.CyberCancel>0)
				src.Mechanized=1
			if(isRace(ANDROID))
				src.CyberCancel=1
				src.Mechanized=1
		SetEnhanceChipCancel()
			if(src.EnhanceChips)
				var/ChipCancel=0
				var/Percent=src.EnhanceChips/4
				ChipCancel=(0.25*Percent)
				if(ChipCancel>0.25)//idk how this would happen...
					ChipCancel=0.25
				src.AddCyberCancel(ChipCancel)
		SetMilitaryFrameCancel()
			if(src.HasMilitaryFrame())
				src.AddCyberCancel(0.25)
		SetConversionModuleCancel()
			var/Conversions=src.HasConversionModules()
			if(Conversions)
				var/Percent=Conversions/10
				var/ConversionCancel=(0.25*Percent)
				if(ConversionCancel>0.25)
					ConversionCancel=0.25
				src.AddCyberCancel(ConversionCancel)
		GetAndroidIntegrated()
			var/Count=0
			for(var/obj/Skills/S in src)
				if(istype(S, /obj/Skills/Buffs/SlotlessBuffs/Gear/Integrated))
					Count++
					continue
				if(istype(S, /obj/Skills/Queue/Gear/Integrated))
					Count++
					continue
				if(istype(S, /obj/Skills/Projectile/Gear/Integrated))
					Count++
					continue
				if(istype(S, /obj/Skills/AutoHit/Gear/Integrated))
					Count++
					continue
			if(Count>=3+(usr.AscensionsAcquired*2))
				src << "You already have the full number of integrated gears possible!"
				return 3+(usr.AscensionsAcquired*2)
			return Count

		ForceCancelBeam()
			if(Beaming)
				for(var/obj/Skills/Projectile/p in src)
					if(p.Charging)
						BeamStop(p)
						if(p.ChargeIcon)
							src.Chargez("Remove", image(icon=p.ChargeIcon, pixel_x=p.ChargeIconX, pixel_y=p.ChargeIconY))
						else
							src.Chargez("Remove")
					p.Charging=0
					src.Beaming=0
					src.BeamCharging=0
		ForceCancelBuster()
			if(BusterTech)
				if(BusterTech.Charging)
					BusterTech.Charging=0
					if(BusterTech.ChargeIcon)
						src.Chargez("Remove", image(icon=BusterTech.ChargeIcon, pixel_x=BusterTech.ChargeIconX, pixel_y=BusterTech.ChargeIconY))
					else
						src.Chargez("Remove")
					src.BusterCharging=0
					src.BusterTech=0
		ReturnProfile(var/FormNum)
			var/Return
			var/ProfileValue=src.vars["Form[FormNum]Profile"]
			if(ProfileValue)//if they have a profile set to the form
				Return=ProfileValue
			else
				Return=src.Profile
			return Return
		AddSkill(var/obj/Skills/S, var/AlreadyHere=0)
			if(!S)
				return
			if(S.type in typesof(/obj/Skills/Queue))
				src.Queues.Add(S)
			else if(S.type in typesof(/obj/Skills/AutoHit))
				src.AutoHits.Add(S)
			else if(S.type in typesof(/obj/Skills/Projectile))
				src.Projectiles.Add(S)
			else if(S.type in typesof(/obj/Skills/Buffs))
				src.Buffs.Add(S)
			src.Skills.Add(S)
			if(!AlreadyHere)
				src.contents.Add(S)
		DeleteSkill(var/obj/Skills/s, trueDel = TRUE)
			if(s in src.Queues)
				src.Queues.Remove(s)
			if(s in src.AutoHits)
				src.AutoHits.Remove(s)
			if(s in src.Projectiles)
				src.Projectiles.Remove(s)
			if(s in src.Buffs)
				src.Buffs.Remove(s)
			if(s in src.Skills)
				src.Skills.Remove(s)
			if(s in src.contents)
				src.contents.Remove(s)
			if(s in src.SlotlessBuffs)
				src.SlotlessBuffs.Remove(s)
			if(trueDel)
				del s
		AddItem(var/obj/Items/I, var/AlreadyHere=0)
			if(!AlreadyHere)
				src.contents+=I
		AddUnlockedTechnology(var/x)
			if(x in list("Weapons", "Armor", "Weighted Clothing", "Smelting", "Locksmithing"))
				src.ForgingUnlocked++
				if(ForgingUnlocked>=5)
					src.ForgingUnlocked=5
			if(x in list("Molecular Technology", "Light Alloys", "Shock Absorbers", "Advanced Plating", "Modular Weaponry"))
				src.RepairAndConversionUnlocked++
				if(RepairAndConversionUnlocked>=5)
					src.RepairAndConversionUnlocked=5
			if(x in list("Medkits", "Fast Acting Medicine", "Enhancers", "Anesthetics", "Automated Dispensers"))
				src.MedicineUnlocked++
				if(MedicineUnlocked>=5)
					src.MedicineUnlocked=5
			if(x in list("Regenerator Tanks", "Prosthetic Limbs", "Genetic Manipulation", "Regenerative Medicine", "Revival Protocol"))
				src.ImprovedMedicalTechnologyUnlocked++
				if(ImprovedMedicalTechnologyUnlocked>=5)
					src.ImprovedMedicalTechnologyUnlocked=5
			if(x in list("Wide Area Transmissions", "Espionage Equipment", "Surveilance", "Drones", "Local Range Devices"))
				src.TelecommunicationsUnlocked++
				if(TelecommunicationsUnlocked>=5)
					src.TelecommunicationsUnlocked=5
			if(x in list("Scouters", "Obfuscation Equipment", "Satellite Surveilance", "Combat Scanning", "EM Wave Projectors"))
				src.AdvancedTransmissionTechnologyUnlocked++
				if(AdvancedTransmissionTechnologyUnlocked>=5)
					src.AdvancedTransmissionTechnologyUnlocked=5
			if(x in list("Hazard Suits", "Force Shielding", "Jet Propulsion", "Power Generators"))
				src.EngineeringUnlocked++
				if(EngineeringUnlocked>=5)
					src.EngineeringUnlocked=5
			if(x in list("Android Creation", "Conversion Modules", "Enhancement Chips", "Involuntary Implantation"))
				src.CyberEngineeringUnlocked++
				if(CyberEngineeringUnlocked>=5)
					src.CyberEngineeringUnlocked=5
			if(x in list("Assault Weaponry", "Missile Weaponry", "Melee Weaponry", "Thermal Weaponry", "Blast Shielding"))
				src.MilitaryTechnologyUnlocked++
				if(MilitaryTechnologyUnlocked>=5)
					src.MilitaryTechnologyUnlocked=5
			if(x in list("Powered Armor Specialization", "Armorpiercing Weaponry", "Impact Weaponry", "Hydraulic Weaponry"))
				src.MilitaryEngineeringUnlocked++
				if(MilitaryEngineeringUnlocked>=5)
					src.MilitaryEngineeringUnlocked=5

			if(x in list("Healing Herbs", "Refreshment Herbs", "Magic Herbs", "Toxic Herbs", "Philter Herbs"))
				src.AlchemyUnlocked++
			if(x in list("Stimulant Herbs", "Relaxant Herbs", "Numbing Herbs", "Distillation Process", "Mutagenic Herbs"))
				src.ImprovedAlchemyUnlocked++
			if(x in list("Spell Focii", "Artifact Manufacturing", "Magical Communication", "Magical Vehicles", "Warding Glyphs"))
				src.ToolEnchantmentUnlocked++
			if(x in list("Tome Cleansing", "Tome Security", "Tome Translation", "Tome Binding", "Tome Excerpts"))
				src.TomeCreationUnlocked++
			if(x in list("Turf Sealing", "Object Sealing", "Power Sealing", "Mobility Sealing", "Command Sealing"))
				src.SealingMagicUnlocked++
			if(x in list("Teleportation", "Retrieval", "Bilocation", "Dimensional Manipulation", "Dimensional Restriction"))
				src.SpaceMagicUnlocked++
			if(x in list("Transmigration", "Lifespan Extension", "Temporal Displacement", "Temporal Acceleration", "Temporal Rewinding"))
				src.TimeMagicUnlocked++

			src.knowledgeTracker.learnedKnowledge.Add(x)
		LoseLifespan(var/val)
			var/Remaining=val
			if(Remaining>0)
				if(src.ModifyFinal>(-1))
					if(src.ModifyFinal-Remaining<(-1))//if there's not enough life left in this stage
						Remaining=abs(-1)-abs(src.ModifyFinal)
						src.ModifyFinal=-1
					else//if there is enough life left
						src.ModifyFinal-=Remaining
						Remaining=0
			if(Remaining>0)
				if(src.ModifyLate>(-1))
					if(src.ModifyLate-Remaining<(-1))//if there's not enough life left in this stage
						Remaining=abs(-1)-abs(src.ModifyLate)
						src.ModifyLate=-1
					else//if there is enough life left
						src.ModifyLate-=Remaining
						Remaining=0
			if(Remaining>0)
				if(src.ModifyPrime>(-2))
					if(src.ModifyPrime-Remaining<(-2))//if there's not enough life left in this stage
						Remaining=abs(-2)-abs(src.ModifyPrime)
						src.ModifyPrime=-2
					else//if there is enough life left
						src.ModifyPrime-=Remaining
						Remaining=0
			if(Remaining>0)
				if(src.ModifyEarly>(-1))
					if(src.ModifyEarly-Remaining<(-1))//if there's not enough life left in this stage
						Remaining=abs(-1)-abs(src.ModifyEarly)
						src.ModifyEarly=-1
					else//if there is enough life left
						src.ModifyEarly-=Remaining
						Remaining=0
			if(Remaining>0)
				src.EraDeathTrigger=1
				src.Death(null, "exhausting their remaining lifespan!", SuperDead=10)
		MakeWarper(var/_x, var/_y, var/_z)
			var/obj/Special/Teleporter2/q=new(src.loc)
			var/obj/Special/Teleporter2/q2=new(locate(_x, _y, _z))
			q.Savable=1
			q.Destructable=0
			q.gotoX=_x
			q.gotoY=_y
			q.gotoZ=_z
			q.AssociatedWarper=q2
			q2.Savable=1
			q2.Destructable=0
			q2.gotoX=q.x
			q2.gotoY=q.y
			q2.gotoZ=q.z
			q2.AssociatedWarper=q
			global.Turfs+=q
			global.Turfs+=q2
			Log("Admin","[ExtractInfo(usr)] made a warper at [usr.x],[usr.y],[usr.z] to warp to [_x],[_y],[_z]!")
		DashTo(mob/Trg, MaxDistance=24, Delay=0.75, Clashable=0)
			var/DelayRelease=0
			src.Frozen=1
			src.icon_state="Flight"
			MaxDistance*=world.tick_lag
			if(Delay < 0.1) Delay = 0.1
	//		var/blur_filter = filter(type="angular_blur", x=0, y=0, size=1)
	//		filters += blur_filter
			while(MaxDistance>0)
//				var/travel_angle = GetAngle(src, Trg)
//				animate(filters[filters.len], x=sin(travel_angle)*(6/Delay), y=cos(travel_angle)*(6/Delay), time=Delay)
				step_towards(src,Trg)
				if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Dragon Dash"))
					KenShockwave(src, icon='KenShockwave.dmi', Size=secretDatum?:getBoon(src, "Dragon Dash"), Blend=2, Time=3)
				if(Trg in oview(1, src))
					MaxDistance=0
					Delay=0
					src.dir=get_dir(src,Trg)
					if(Trg.Knockbacked)
						src.NextAttack=0
						Trg.StopKB()
						if(Clashable || Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Dragon Dash"))
							for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Clash_Defensive/DC in Trg)
								if(!Trg.BuffOn(DC))
									var/pursuerBoon = Trg.HasPursuer()
									DC.TimerLimit = 3 + clamp(0.25 * pursuerBoon, 0.001, glob.MAX_PURSUER_BOON)
									DC.Trigger(Trg)
							for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Clash/DC in src)
								if(!src.BuffOn(DC))
									var/pursuerBoon = HasPursuer()
									DC.TimerLimit = 3 + clamp(0.25 * pursuerBoon, 0.001, glob.MAX_PURSUER_BOON)
									if(isRace(MAKYO) && ActiveBuff)
										DC.passives["Star Surge"] = 1
										DC.passives["Steady"] = 2
										DC.TimerLimit = 1.5 + clamp(0.5 * pursuerBoon, 0.001, glob.MAX_PURSUER_BOON)
									DC.Trigger(src)
					break
				else
					MaxDistance-=world.tick_lag
					DelayRelease+=Delay*world.tick_lag
					if(DelayRelease>=1)
						DelayRelease--
						sleep(1*world.tick_lag)
	//		filters -= blur_filter
			src.Frozen=0
			if(src.is_dashing>0)
				src.is_dashing--
			if(src.is_dashing<0)
				src.is_dashing=0
			src.icon_state=""
			//animate(src.filters[filters.len], x=0, y=0)
			src.dir=get_dir(src,Trg)
		Reincarnate()
			src.Savable=0
			if(istype(src, /mob/Players))
				fdel("Saves/Players/[src.ckey]")
			src.RPPCurrent=src.RPPSpent+src.RPPSpendable
			src.RPPTotal+=src.RPPCurrent
			OMsg(src, "[src] fades away slowly, ready to begin a new life...", "[src] reincarnated.")
			animate(src,alpha=0,time=600)
			spawn(600)
				del(src)

		CountStyles(var/Tier=0)
			var/Count=0
			if(!Tier)
				Log("Admin", "[ExtractInfo(src)] tried to count signatures without specifying a tier.")
				return
			for(var/obj/Skills/Buffs/NuStyle/s in src.Skills)
				if(s.SignatureTechnique==Tier)
					Count++
					continue
			return Count
		CountSigs(var/Tier=0)
			var/Count=0
			var/list/combo_check=list()
			if(!Tier)
				Log("Admin", "[ExtractInfo(src)] tried to count signatures without specifying a tier.")
				return
			for(var/obj/Skills/s in src.Skills)
				if(istype(s, /obj/Skills/Buffs/NuStyle))
					continue
				if(s.SignatureTechnique==Tier)
					if("[s.type]" in combo_check)
						continue
					for(var/list/l in SigCombos)
						if("[s.type]" in l)
							combo_check += l
							break

					Count++
					continue
			return Count

		SagaAscend(var/mod, var/val)
			src.SagaAscension["[mod]"]+=val
			src.vars["[mod]Ascension"]+=val
		SagaStat(var/mod)
			return src.SagaAscension["[mod]"]
		SagaThreshold(var/mod, var/threshold)
			var/current=src.SagaStat(mod)
			if(current < threshold)
				src.SagaAscend(mod, threshold-current)
		req_pot(var/val)
			if(src.Potential>=val)
				return 1
			return 0
		req_rpp(var/val)
			if(src.RPPSpendable+src.RPPSpent>=val)
				return 1
			return 0
		req_styles(var/val, var/tier)
			if(src.CountStyles(tier)<=val)
				return 1
			return 0
		req_sigs(var/val, var/tier)
			if(src.CountSigs(tier)<=val)
				return 1
			return 0
		styles_available(var/tier)
			for(var/obj/Skills/Buffs/NuStyle/s in src)
				StyleUnlock(s)
			var/list/styles_available=list()
			styles_available.Add(src.SignatureStyles)
			styles_available.Remove(src.SignatureSelected)
			if(styles_available.len>0)
				for(var/x in styles_available)
					var/path=styles_available[x]
					if(isnull(path))
						continue

					var/obj/Skills/s=new path
					if(s.SignatureTechnique==tier)
						return 1
					else
						del s
						continue
			else
				return 0
		// THIS IS WHERE POTENTIAL CHECKING IS!!
		PotentialSkillCheck()
			if(!locate(/obj/Skills/Zanzoken, src))
				if(src.req_pot(1))
					src << "You develop the ability to move faster than the eye can see due to your experience fighting!"
					src.AddSkill(new/obj/Skills/Zanzoken)
			if(!locate(/obj/Skills/Power_Control, src))
				if(src.req_pot(1))
					src << "You develop the ability to fluctuate your power due to your experience fighting!"
					src.AddSkill(new/obj/Skills/Power_Control)
					if(!locate(/obj/Skills/Buffs/ActiveBuffs/Ki_Control, src))
						src.PoweredFormSetup()
			if(!locate(/obj/Skills/Utility/Sense, src))
				if(src.req_pot(1))
					src << "You develop the ability to sense power due to your experience fighting!"
					src.AddSkill(new/obj/Skills/Utility/Sense)

			if(!src.SignatureCheck)
				return
			if(src.Saga)
				if(src.Potential<glob.progress.SAGA_T2_POT && SagaLevel>=1) // t2
					return
				if(src.Potential<glob.progress.SAGA_T3_POT && src.SagaLevel>=2) // t3
					return
				if(src.SagaLevel>=3&&!src.SagaAdminPermission)
					return
				src.saga_up_self()
				return
			if(src.Potential>=glob.progress.T2_STYLES[1]&&src.passive_handler.Get("True Inheritor"))
				if(!locate(/obj/Skills/Buffs/NuStyle/Legendary/Legacy_Of_The_Fabled_King, src))
					src.AddSkill(new/obj/Skills/Buffs/NuStyle/Legendary/Legacy_Of_The_Fabled_King)
			if(src.Potential>=glob.progress.T2_STYLES[2]&&src.passive_handler.Get("True Inheritor"))
				if(!locate(/obj/Skills/Buffs/NuStyle/Legendary/True_Fist_Of_The_Fabled_King, src))
					src.AddSkill(new/obj/Skills/Buffs/NuStyle/Legendary/True_Fist_Of_The_Fabled_King)
			if(src.Potential>=65&&src.passive_handler.Get("True Inheritor"))
				if(!locate(/obj/Skills/Buffs/NuStyle/Legendary/True_Fist_Of_The_Fabled_King, src))
					src.AddSkill(new/obj/Skills/Buffs/NuStyle/Legendary/Fist_Of_The_King_Of_Tomorrow)
					src.AddSkill(new/obj/Skills/Buffs/NuStyle/Legendary/Apotheosis_Of_The_Fabled_King)

			if(styles_available(1) && src.Potential>=glob.progress.T1_STYLES[1] && src.req_styles(0, 1))
				DevelopSignature(src, 1, "Style")
			if(styles_available(1) && src.Potential>=glob.progress.T1_STYLES[2] && src.req_styles(1, 1))
				DevelopSignature(src, 1, "Style")
			if(styles_available(2) && src.Potential>=glob.progress.T2_STYLES[1] && src.req_styles(0, 2))
				DevelopSignature(src, 2, "Style")
			if(styles_available(2) && src.Potential>=glob.progress.T2_STYLES[2] && src.req_styles(1, 2))
				DevelopSignature(src, 2, "Style")
			if(src.CyberneticMainframe)
				return
			// if(styles_available(3) && src.Potential>=glob.progress.T3_STYLES[1] && src.req_styles(0, 3))
			// 	DevelopSignature(src, 3, "Style")
			if(src.req_pot(glob.progress.T1_SIGS[1]) && src.req_sigs(0, 1))
				DevelopSignature(src, 1, "Signature")
			if(src.req_pot(glob.progress.T1_SIGS[2]) && src.req_sigs(1, 1))
				DevelopSignature(src, 1, "Signature")

			if(src.req_pot(glob.progress.T2_SIGS[1]) && src.req_sigs(0, 2))
				DevelopSignature(src, 2, "Signature")
			if(src.req_pot(glob.progress.T1_SIGS[3]) && src.req_sigs(2, 1))
				DevelopSignature(src, 1, "Signature")

			if(src.req_pot(glob.progress.T2_SIGS[2]) && src.req_sigs(1, 2))
				DevelopSignature(src, 2, "Signature")

		YeetSignatures()
			for(var/obj/Skills/s in src.Skills)
				if(s.SignatureTechnique)
					if(!s.SagaSignature)
						if(!(s.CyberSignature && src.CyberneticMainframe))
							if(!src.BuffOn(s))
								src << "[s] has been removed as it is not one of your saga signatures."
								del s

		MovementChargeBuildUp(var/Mult=1)
			//this ticks per second
			//partial charges are not able to be used
			//30 seconds will result in full charges
			if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Zanzoken"))
				return

			if(glob.USE_SPEED_IN_ZANZO_RECHARGE)
				Mult *= clamp(GetSpd()**glob.ZANZO_SPEED_EXPONENT, glob.ZANZO_SPEED_LOWEST_CLAMP, glob.ZANZO_SPEED_HIGHEST_CLAMP)
			var/flick=src.HasFlicker()
			if(flick)
				Mult*=clamp(1+(flick/glob.ZANZO_FLICKER_DIVISOR),glob.ZANZO_FLICKER_LOWEST_CLAMP, glob.ZANZO_FLICKER_HIGHEST_CLAMP)
			if(src.AfterImageStrike)
				return
			var/max_charges = GetMaxMovementCharges()
			var/taper_basis = max(max_charges, 3)
			var/add = (glob.ZANZO_FLICKER_BASE_GAIN-(max(0.01,MovementCharges)/taper_basis)/10)*Mult
			src.MovementCharges+=add
			if(src.MovementCharges>max_charges)
				src.MovementCharges=max_charges
			if(client&&client.hud_ids["Zanzoken"])
				var/alteration = -36 + (36 * (MovementCharges - round(MovementCharges)))
			//	world<<add
				client.hud_ids["Zanzoken"].Update(alteration, round(MovementCharges))
		GetRPPMult()
			var/Return=src.RPPMult
			Return*=src.ConditionRPPMult()
			if(src.TarotFate=="The Hermit")
				Return*=1.5
			return Return
		ConditionRPPMult()
			var/Return=1
			if(src.ParasiteCrest())
				Return*=2
			return Return
		Base()
			var/base = src.Base * BASE_MOD
			return base

		get_potential()
			var/Return=src.Potential

			if(src.HasPowerReplacement())
				var/Replace=src.GetPowerReplacement()
				if(Replace>Return)
					Return=Replace

			if(src.potential_trans)
				if(src.potential_trans > Return)
					Return=src.potential_trans

			if(passive_handler.Get("Transformation Power")) // add straight potential
				Return+=passive_handler.Get("Transformation Power")

			if(isRace(SHINJIN))//one determines the other
				if(src.ShinjinAscension=="Kai")
					var/NoFite=2
					if(src.AscensionsAcquired>0)
						NoFite=1
					src.passive_handler.Set("GodKi", src.Potential/(100*NoFite))
				if(src.ShinjinAscension=="Makai")
					src.passive_handler.Set("GodKi", src.Potential/100)
			//TODO: ALTER SHINJIN GODKI POTENTIAL THING

			return Return

		GetMaxMovementCharges()
			var/amount = 3
			if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Zanzoken"))
				amount = 0
			if(passive_handler.Get("Sekizou"))
				amount = 5
			if(passive_handler.Get("EmptyFlashStep"))
				amount += GetSwordAscension()
			amount += getDenkoSekka() * glob.DENKO_SEKKA_CHARGE_PER_LEVEL
			amount = min(amount, 10)
			return amount

		transcend(var/val)
			if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Transcendant, src))
				var/obj/Skills/Buffs/b=new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Transcendant
				b.GodKi=val
				src.AddSkill(b)
		SecretToss(var/obj/Skills/Grapple/Toss/Z)
			if(src.RippleActive())
				for(var/obj/Skills/Buffs/SlotlessBuffs/Ripple/Life_Magnetism_Overdrive/H in src)
					H.Trigger(src)
				src.Oxygen+=(src.OxygenMax)*0.25
				if(src.Oxygen>=(src.OxygenMax)*2)
					src.Oxygen=(src.OxygenMax)*2
				Z.Cooldown(3)
				return
			if(src.Secret=="Vampire")
				// if(!src.PoseEnhancement)
				// 	src.Activate(new/obj/Skills/AutoHit/Shadow_Tendril_Strike)
				// else
				// 	src.Activate(new/obj/Skills/AutoHit/Shadow_Tendril_Wave)
				// Z.Cooldown()
				return
			if(src.Secret=="Werewolf")
				src.Activate(new/obj/Skills/AutoHit/Howl)
				Z.Cooldown(3)
				return
			if(hasEldritchPower())
				src.Activate(new/obj/Skills/AutoHit/Shadow_Tendril_Strike(p = src))
				Z.Cooldown()
				return
			if(src.Secret=="Haki")
				src.AddHaki("Armament")
				if(!src.CheckSlotless("Haki Armament"))
					for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armament/H in src)
						H.Trigger(src)
				if(src.CheckSlotless("Haki Observation"))
					for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Observation/H in src)
						H.Trigger(src)
				Z.Cooldown(3)
				if(!src.CheckSlotless("Haki Shield")&&!src.CheckSlotless("Haki Shield Lite"))
					if(src.secretDatum.secretVariable["HakiSpecialization"]=="Armament")
						for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Shield/H in src)
							H.Trigger(src)
					else
						for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Shield_Lite/H in src)
							H.Trigger(src)

/mob/Admin4/verb/ChangeWipeStartHour(n as num)
	adjustWipeStartTime(n)

#define MAX_WIPE_DAYS 360
#define ANIT_LAG_NUM 100


proc
	adjustWipeStartTime(n as num)
		// n = hour to start
		var/wipeStartHour = time2text(glob.progress.WipeStart, "hh", "EST")
		wipeStartHour = text2num(wipeStartHour)
		var/zeroHour = glob.progress.WipeStart - (wipeStartHour HOURS)
		var/newWipeStart = zeroHour + (n HOURS)
		glob.progress.WipeStart = newWipeStart

	DaysOfWipe()
		if(!glob)
			// no glob?
			world.log << "No glob found in DaysOfWipe()!"
			return
		if(!glob.progress)
			// no progress?
			world.log << "No progress found in DaysOfWipe()!"
			return
		var/day = 24 HOURS
		var/days = floor((world.realtime / day) - (glob.progress.WipeStart / day))
		if(days>glob.progress.DaysOfWipe)
			glob.progress.DaysOfWipe=round(days)
			glob.progress.incrementTotal()
		// glob.RPPStarting=(glob.RPPDaily)*glob.progress.DaysOfWipe
		if(glob.progress.DaysOfWipe>MAX_WIPE_DAYS)
			glob.progress.DaysOfWipe = MAX_WIPE_DAYS
		return glob.progress.DaysOfWipe
	Today()
		return world.realtime-world.timeofday
	Yesterday()
		return Today() - Day(1)

proc
	IsList(var/val)
		if(istype(val, /list))
			return 1
		return 0
proc
	StaticDamage(var/Val, var/Stat1, var/Stat2)
		return ((Val/Stat1)/(Val/Stat2))


proc
	TrueDamage(Damage)
		return Damage
	ProjectileDamage(Damage) // This is Power * Damage Mult
		return Damage*glob.PROJ_DAMAGE_MULT
	CounterDamage(Damage)
		return clamp(Damage,0.25,5)

var/list/general_magic_database = list()
var/list/general_weaponry_database = list()
proc
	BuildGeneralMagicDatabase() // This is a list of generally obtainable magics. For now, it's just used for Crimson grimoire.
		// Guard: SkillTree is populated by MakeSkillTreeList which runs from BootWorld("Load").
		// This proc must be called AFTER MakeSkillTreeList, otherwise SkillTree is null/empty.
		if(!SkillTree || !islist(SkillTree))
			return
		general_magic_database = list()
		if(islist(SkillTree["MagicT1"])) general_magic_database += SkillTree["MagicT1"]
		if(islist(SkillTree["MagicT2"])) general_magic_database += SkillTree["MagicT2"]
		if(islist(SkillTree["MagicT3"])) general_magic_database += SkillTree["MagicT3"]
		if(islist(SkillTree["MagicT4"])) general_magic_database += SkillTree["MagicT4"]
		general_magic_database = general_magic_database.Copy() //Makes it so we don't reference vars in the SkillTree variable.

		for(var/index in general_magic_database) //remove all spell cost references for now.
			general_magic_database[index] = null

		//Now a layer of confirmation for the abilities in here.
		var/obj/Skills/s
		for(var/index in general_magic_database)
			s = text2path(index)
			if(!s) continue
			s = new s
			if(s && istype(s))
				if(!s.MagicNeeded)
					general_magic_database -= index

	BuildGeneralWeaponryDatabase()
		var/list/weaponry_queues = list()
		weaponry_queues += "/obj/Skills/Queue/Gear/Integrated/Integrated_Pile_Bunker"
		weaponry_queues += "/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Fist"
		weaponry_queues += "/obj/Skills/Queue/Gear/Integrated/Integrated_Power_Claw"
		weaponry_queues += "/obj/Skills/Queue/Gear/Integrated/Integrated_Hook_Grip_Claw"
		weaponry_queues += "/obj/Skills/Queue/Cyberize/Taser_Strike"

		var/list/weaponry_autohits = list()
		weaponry_autohits += "/obj/Skills/AutoHit/Gear/Integrated/Integrated_Incinerator"
		weaponry_autohits += "/obj/Skills/AutoHit/Cyberize/Machine_Gun_Flurry"

		var/list/weaponry_projectiles = list()
		weaponry_projectiles += "/obj/Skills/Projectile/Machine_Gun_Burst"
		weaponry_projectiles += "/obj/Skills/Projectile/Homing_Ray_Missiles"
		weaponry_projectiles += "/obj/Skills/Projectile/Plasma_Cannon"
		weaponry_projectiles += "/obj/Skills/Projectile/Gear/Integrated/Integrated_Missile_Launcher"
		weaponry_projectiles += "/obj/Skills/Projectile/Gear/Integrated/Integrated_Chemical_Mortar"
		weaponry_projectiles += "/obj/Skills/Projectile/Cyberize/Rocket_Punch"

		general_weaponry_database = list()
		general_weaponry_database += weaponry_queues
		general_weaponry_database += weaponry_autohits
		general_weaponry_database += weaponry_projectiles
