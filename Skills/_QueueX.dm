//queue-layer state
mob/var/tmp
	queue_tell_aura = 0
	queue_counter_until = 0

obj
	Skills
		Queue//Queued skills like GET DUNKED and Axekick.
			CritEffectiveness=1
			var/Duration=5//This is how long the queue remains up for.
			var/UnarmedOnly=0//Can't use this with a sword.
			//var/ClassNeeded//Requires a sword class.
			var/TextColor
			var/ActiveMessage//Displays on using the skill, if it exists.
			var/HitMessage//Displays on hitting with the skill, if it exists.
			var/MissMessage//Displays on missing with the skill, if it exists.
			var/DamageMult//obvs
			var/AccuracyMult//obvs
			var/MultiHit//hits multiple times before turning off.
			var/HitsUsed//Keeps a tally of how many hits have been used.
			var/KBAdd//Adds knockback
			var/KBMult//Multiplies knockback.
			var/Recoil/*If this is set, it will mark the attackers recoil damage.*/
			var/Finisher//Passive that makes damage scale.
			var/Opener//Passive that makes damage higher when health is higher.
			var/Decider//Passive that makes damage higher when health is near the middle.
			var/Dominator//win harder
			var/Determinator//turn a loss into a win
			var/Delayer//alliteration, but. this is a charge punch that does more damage when theres more time elapsed between queueing and bonking!!
			var/DelayerTime//+1 every second queue is queued. Mult this by Delayer when the attack finally gets thrown.
			var/Counter//guess
			var/CounterTemp//from coutnermaster
			var/NoWhiff //guess
			var/tmp/unparryable = 0
			var/tmp/energy_free = 0
			var/PrecisionStrike//attack only what you want to
			var/SpeedStrike/*Passive that multiplies damage by speed mod.  1 = 0.5 speed, 2 = full speed.*/
			var/SweepStrike/*Passive that multiplies damage by enemy's speed.  Reverse Speed Strike!*/
			var/DrawIn/*Passive that draws people in.  DrawIn value = the amount of tiles drawn in.*/
			var/PushOut//Passive that pushes people away. PushOut value = the amount of tiles pushed away.
			var/PushOutWaves=1
			var/PushOutIcon='fevKiai.dmi'
			var/ComboMessaged//If the combo has displayed a message, flag this
			var/Combo//Value of combo is how many times it hits.
			var/ComboPerformed=0//Tracks number of hits done.
			var/list/ComboHitMessages=list()//X="message to be displayed"
			var/Rapid//Make Combos happen sooner
			var/InstantStrikes //the fasses of fass attacks
			var/InstantStrikesPerformed=0
			var/InstantStrikesDelay//when fass is too fass
			var/Warp//If this is ticked, it homes onto people.
			var/NoWarp
			var/SpecialEffect//shinies
			var/SpecialEffectRange=3//shinies big or smol
			var/RozanEffect//super launcher
			var/ShoryukenEffect//Do the shoryuken effect!
			var/GoshoryukenEffect
			var/Explosive//Makes explosions, duh.
			var/Shining//Makes shock effects.
			var/IconLock='BLANK.dmi'
			var/IconLockUnder=0
			var/LockX=0
			var/LockY=0

			//ALL THREE OF THESE TAKE AN OBJECT TYPE.
			var/Step //sequential attacks for hits or misses
			var/HitStep //sequential attacks only if you hit
			var/MissStep //sequential attacks only if you miss

			//These three are all just binaries to determine what to do when you clear your queue and there's a step tech.
			var/Missed=0//Flagged for when attacks miss
			var/Hit=0//Flagged for when attacks hit
			var/RanOut=0//Flagged for when attacks just run out of time


			var/Dunker //Multiplies launched foes damage by this value.

			var/Projectile//holds the projectile type and decides if there is a projectile at all
			var/ProjectileCount=1//Fires the given projectile multiple times
			var/ProjectileCDBypass//sets CD to 0
			var/ProjectileBeam//Double tap for beams

//			var/GrabTrigger//adds and activates a grapple
			var/StanceNeeded
			var/ABuffNeeded
			var/SBuffNeeded
			var/GateNeeded

			//FocusShift
			var/FocusShifter
			var/FocusShiftType = "None"
			var/FocusShiftBoost = 1.5
			var/FocusShiftTimer = 10

			var/Quaking //Makes screen go shakka shakka
			var/WarpAway




			var/ManaGain

			//Instinct //Ignore AIS/WS
			var/WeaponBreaker //WHAT DO U THINK?!
			var/MortalBlow //WHHHHHHHHHHHAAAAAAAAAA-

			var/HitSparkIcon//you
			var/HitSparkX//know
			var/HitSparkY//how
			var/HitSparkSize//it
			var/HitSparkTurns//do
			var/HitSparkDispersion=8
			var/NeedsHealth


			var/RipplePower=1//used to make ripple go higher
			var/WaveHit=0//Applies BYOND wave filter briefly on the hit target

			var/Ooze


			skillDescription()
				..()
				if(DamageMult)
					description += "Damage Mult: [DamageMult]\n"
				if(AccuracyMult)
					description += "Accuracy Mult: [AccuracyMult]\n"
				if(MultiHit)
					description += "Multihit: [MultiHit] hits.\n"
				if(KBAdd)
					description += "Bonus Knockback [KBAdd] tiles.\n"
				if(KBMult)
					description += "Knockback Mult [KBMult]x\n"
				if(Recoil)
					description += "Recoil: [Recoil]\n"
				if(Finisher)
					description += "Finisher: [Finisher]\n"
				if(Opener)
					description += "Opener: [Opener]\n"
				if(Decider)
					description += "Decider: [Decider]\n"
				if(Dominator)
					description += "Dominator: [Dominator]\n"
				if(Dunker)
					description += "Dunker: [Dunker]\n"
				if(Counter)
					description += "Counter: [Counter]\n"
				if(SpeedStrike)
					description += "Speedstrike: [SpeedStrike]\n"
				if(DrawIn)
					description += "Draws in: [DrawIn] tiles.\n"
				if(PushOut)
					description += "Pushes away: [PushOut] tiles.\n"
				if(Combo)
					description += "Combos: [Combo] times.\n"
				if(InstantStrikes)
					description += "Delivers [InstantStrikes] blows at once.\n"
				if(Warp)
					description += "Warping.\n"
				if(Step||HitStep)
					description += "Follow-up Attack: [Step] [HitStep]"
				if(Projectile)
					description += "Fires: [Projectile], [ProjectileCount] times."


//Autoqueues

////General



			Hokuto_Hyakuretsu_Ken //Hundred Crack Fist
				DamageMult=0.1
				Warp=5
				KBAdd=0
				KBMult=0.00001
				Combo=25
				Launcher=1
				CursedWounds=1
				Rapid=1
				Instinct=4
				HitSparkIcon='Hit Effect.dmi'
				HitSparkX=-32
				HitSparkY=-32
				FollowUp="/obj/Skills/Queue/Hagan_Ken"
				ActiveMessage="performs rapid fire strikes!" //ATATATATATATATATATA
			East_Rush
				DamageMult=2
				KBAdd=0
				KBMult=0.001
				Rapid=1
				Projectile=/obj/Skills/Projectile/East_Gust


			Hagan_Ken
				DamageMult=2.5
				Finisher=1
				CursedWounds=1
				Dunker=1 //Just flashy to end the combo. No extra damage.
				NoGCD=1
				Warp=5
				KBAdd=5
				KBMult=0.00001
				HitSparkIcon='Hit Effect.dmi'
				HitSparkX=-32
				HitSparkY=-32
				ActiveMessage="smashes their fist into their opponents face!" //WA TA
////Keyblade
			//(2026.25.02 I need to refactor or remake all the variants of Heavy Strike code for readability - Hadoje)
			Heavy_Strike
				Duration=5
				DamageMult=2
				AccuracyMult=1
				KBAdd=5
				KBMult=3
				Cooldown=15
				verb/Heavy_Strike()
					set category="Skills"
					set hidden = 1
					if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Heavy Strike"))
						return
					if(usr.IsGuarding())
						usr.AlphaCounter()	//heavy strike while guarding = the shove, never a queue
						return
					if(usr.AttackQueue)
						return // prevent heavy strike from overriding
					if(usr.passive_handler["Heavy Strike"]&&!usr.ForceHeavyStrike)
						switch(usr.passive_handler["Heavy Strike"])
							if("Wrestling")
								Grapple = 1
								KBAdd =0
								KBMult = 0
								DamageMult = 4
								AccuracyMult = 2
								HitMessage = "puts his hands on em'."
								Duration=7
								Cooldown = 20
							if("Inferno")
								FollowUp = "/obj/Skills/AutoHit/Hyper_Inferno"
							if("HellfireInferno")
								FollowUp = "/obj/Skills/AutoHit/HellfireInferno"
							if("ChaosBlaster")
								FollowUp = "/obj/Skills/AutoHit/ChaosBlaster"
							if("GetsugaClad")
								FollowUp = "/obj/Skills/AutoHit/Getsuga_Followthrough"
							if("Warp Strike")
								var/obj/Skills/Projectile/Warp_Strike_MasterOfArms/P = usr.FindSkill(/obj/Skills/Projectile/Warp_Strike_MasterOfArms)
								if(!P)
									usr << "You need to be in Master of Arms to use Warp Strike!"
									return
								if(P.Using || P.cooldown_remaining)
									return
								if(!usr.Target || usr.Target == usr)
									usr << "You need a target to use Warp Strike!"
									return
								var/obj/Items/Sword/sword = usr.EquippedSword()
								var/obj/Items/Enchantment/Staff/staff = usr.EquippedStaff()
								if(!sword && !staff)
									usr << "You need a weapon equipped to use Warp Strike!"
									return
								// FlashChange: weapon "disappears" as it's thrown
								animate(usr, color=list(1,0,0, 0,1,0, 0,0,1, 1,1,1), time=1)
								spawn(1)
									if(usr)
										animate(usr, color=list(1,0,0, 0,1,0, 0,0,1, 0,0,0), time=1)
								P.IconLock = sword ? sword.icon : staff.icon
								P.adjust(usr)
								usr.WarpStrikeHidingWeapon = 1
								usr.AppearanceOff()
								usr.AppearanceOn()
								usr.warp_strike_saved_loc = get_turf(usr)
								if(!usr.UseProjectile(P))
									usr.WarpStrikeHidingWeapon = 0
									usr.AppearanceOff()
									usr.AppearanceOn()
									usr.warp_strike_saved_loc = null
								return

					else
						// reset all
						Grapple = 0
						FollowUp = null

					var/obj/Skills/Queue/Secret_Heavy_Strike/hs = usr.getSpecialHeavyStrike();
					if(hs)
						if(hs.Using || Using) return;//if heavy strike or secret heavy strike is on cooldown, stop
						hs.adjust(usr);
						usr.SetQueue(hs);
					else if(usr.canNormalHeavyStrike()) usr.SetQueue(src);

			Meteor_Mash
				name="Meteor Mash"
				DamageMult=1
				AccuracyMult = 1.1
				Duration=5
				Scorching=1
				Shattering=1
				KBAdd=1
				Cooldown=150
				ManaCost=10
				Combo=5
				HitSparkIcon='fevExplosion.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=1.2
				verb/Meteor_Mash()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)
			Steam_Driver
				name="Steam Driver"
				DamageMult=1
				AccuracyMult = 1.1
				Duration=5
				Scorching=1
				Freezing=1
				KBAdd=1
				Cooldown=150
				ManaCost=10
				Combo=5
				HitSparkIcon='fevExplosion - Steam.dmi'
				HitSparkX=-32
				HitSparkY=-32
				verb/Steam_Driver()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)
			Crystal_Crumbling
				name="Crystal Crumbling"
				DamageMult=1
				AccuracyMult = 1.1
				Duration=5
				Shattering=1
				Freezing=1
				KBAdd=1
				Cooldown=150
				ManaCost=10
				Combo=5
				PushOutIcon='SnowBurst2.dmi'
				PushOut=3
				PushOutWaves=1
				verb/Crystal_Crumbling()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)
			Cyclone_Kicks
				name="Cyclone Kicks"
				DamageMult=1
				AccuracyMult = 1.1
				Duration=5
				Freezing=1
				Paralyzing=1
				KBAdd=1
				Cooldown=150
				ManaCost=10
				Combo=5
				PushOutIcon='fevKiaiG.dmi'
				PushOut=1
				PushOutWaves=1
				verb/Cyclone_Kicks()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)

			Blaze_Burst
				name="Blaze Burst"
				DamageMult=2
				AccuracyMult = 1.1
				Duration=5
				Scorching=3
				KBAdd=5
				Cooldown=90
				ManaCost=5
				HitSparkIcon='fevExplosion.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=0.8
				verb/Blaze_Burst()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)

			Winter_Shock
				name="Winter Shock"
				DamageMult=2
				AccuracyMult = 1.1
				Duration=5
				Freezing=3
				KBMult=2
				Cooldown=90
				ManaCost=5
				HitSparkIcon='Hit Effect Divine.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=1.1
				verb/Winter_Shock()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)

			Terra_Crack
				name="Terra Crack"
				DamageMult=2
				AccuracyMult = 1.1
				Duration=5
				Shattering=3
				KBAdd=10
				Cooldown=90
				ManaCost=5
				PushOutIcon='DarkKiai.dmi'
				PushOutWaves=3
				PushOut=1
				HitSparkIcon='BLANK.dmi'
				verb/Terra_Crack()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)

			Aero_Slash
				name="Aero Slash"
				DamageMult=2
				AccuracyMult = 1.1
				Duration=5
				Paralyzing=3
				KBMult=1.5
				Cooldown=90
				ManaCost=5
				HitSparkIcon='Slash - Power.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=0.8
				HitSparkTurns=1
				verb/Aero_Slash()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)

			Sharpnel_Scatter
				name="Shrapnel Scatter"
				DamageMult=1
				AccuracyMult = 1.1
				Duration=5
				Shattering=1
				Paralyzing=1
				KBAdd=1
				Cooldown=150
				ManaCost=10
				Combo=5
				HitSparkIcon='Hit Effect Satsui.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=1.4
				verb/Sharpnel_Scatter()
					set category="Skills"
					set hidden = 1
					set name="Shrapnel Scatter"
					usr.SetQueue(src)
			Desert_Wind
				name="Desert Wind"
				DamageMult=1
				AccuracyMult = 1.1
				Duration=5
				Scorching=1
				Paralyzing=1
				KBAdd=1
				Cooldown=150
				ManaCost=10
				Combo=5
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=1.3
				verb/Desert_Wind()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)

			Uppercut
				SkillCost=40
				Copyable=1
				HitMessage="delivers a vicious uppercut!!"
				DamageMult=2
				AccuracyMult = 1.1
				Duration=5
				KBMult=0.00001
				Cooldown=30
				UnarmedOnly=1
				Launcher=2
				EnergyCost=1.5
				name="Uppercut"
				verb/Uppercut()
					set category="Skills"
					set hidden = 1
					set name="Uppercut"
					usr.SetQueue(src)

			Super_Dragon_Fist
				UnarmedOnly=1
				DamageMult=18
				AccuracyMult = 1.25
				Duration=10
				KBMult=0.0001
				Cooldown=180
				UnarmedOnly=1
				Instinct=5
				Stunner=5
				Projectile="/obj/Skills/Projectile/Beams/Big/Super_Dragon_Beam"
				ProjectileBeam=1
				HitMessage="throws a crippling punch into the opponent's midsection!"
				ActiveMessage="is surrounded by the ki of a full fledged dragon!!"
				verb/Super_Dragon_Fist()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)

			Dancing_Lights
				SkillCost=80
				Copyable=2
				DamageMult=1.2
				AccuracyMult = 1.15
				Duration=5
				Projectile="/obj/Skills/Projectile/DancingBlast"
				Cooldown=60
				Combo=4
				EnergyCost=2
				IconLock='DancingLight.dmi'
				HitSparkIcon='Hit Effect Divine.dmi'
				HitSparkX=-32
				HitSparkY=-32
				verb/Dancing_Lights()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)

			Counter_Cannon
				SkillCost=40
				Copyable=2
				PreRequisite=list("/obj/Skills/Projectile/Charge")
				LockOut=list("/obj/Skills/Projectile/Crash_Burst", "/obj/Skills/Projectile/Feint_Shot", "/obj/Skills/Projectile/Dragon_Nova")
				DamageMult=1
				AccuracyMult=1
				Duration=5
				Projectile="/obj/Skills/Projectile/Counter_Cannon_Shot"
				Cooldown=30
				EnergyCost=3
				IconLock='DancingLight.dmi'
				HitSparkIcon='Hit Effect Divine.dmi'
				HitSparkX=-32
				HitSparkY=-32
				ActiveMessage="takes a defensive stance while charging a blast!"
				verb/Counter_Cannon()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)

			Camelia_Dance
				SkillCost=20
				Copyable=2
				ActiveMessage="prepares a flurry of thrusts!"
				DamageMult=1.5
				AccuracyMult = 1.1
				Duration=10
				Cooldown=60
				NeedsSword=1
				InstantStrikes=3
				InstantStrikesDelay=1
				EnergyCost=1
				verb/Camelia_Dance()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)

			Swallow_Reversal
				SkillCost=80
				Copyable=2
				ActiveMessage="enters a graceful stance!"
				DamageMult=1.4
				AccuracyMult = 1.15
				KBMult=0.00001
				SpeedStrike=1
				InstantStrikes=3
				InstantStrikesDelay=0
				Warp=2
				Duration=5
				Cooldown=60
				NeedsSword=1
				EnergyCost=3
				verb/Swallow_Reversal()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)



//Knowledge
			Anesthetic_Strike
				ActiveMessage="prepares a needle!"
				HitMessage="jabs the needle and deploys the anesthetic into their target!"
				MissMessage="fumbles with the needle and wastes the anesthetic!"
				DamageMult=1
				AccuracyMult=1
				Duration=3
				//doesn't get a verb because it is set from the tech item


			Symbiote_Hammer
				DamageMult=8
				AccuracyMult = 1.2
				Duration=10
				Cooldown=90
				Instinct=2
				KBAdd=3
				Stunner=1
				Shearing = 10
				Crippling = 10
				HitMessage="'s symbiotic hammer swings dead center into their enemy!"
				ActiveMessage="'s symbiotic mass takes the shape of a hammer!"
				verb/Symbiote_Hammer()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)

//General app

			Ragna_Blade
				NoTransplant=1
				DamageMult=20
				AccuracyMult = 1.25
				WeaponBreaker=100
				Shearing=10
				Crippling=10
				Instinct=4
				MortalBlow=0.5
				IconLock='Ragna Blade.dmi'
				LockX=-32
				LockY=-32
				Duration=-1 //Durationless
				HitSparkIcon='Slash - Ragna.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=5
				ActiveMessage="draws upon the might of the primodial Chaos!"
				HitMessage="slashes through reality itself!"
				Cooldown=10800
				verb/Ragna_Blade()
					set category="Skills"
					set hidden = 1
					src.MultiHit=round(usr.ManaAmount/100,1)
					src.ManaCost=max(80, usr.ManaAmount)
					usr.SetQueue(src)

			Bad_Luck
				name="Bad Luck"
				DamageMult=4
				AccuracyMult = 1.1
				Duration=5
				Cooldown=30
				EnergyCost=3
				HitMessage="whacks their enemy with their instrument with a triumphant twang!!"
				verb/Bad_Luck()
					set category="Skills"
					set hidden = 1
					usr.SetQueue(src)


mob
	proc
		SetQueue(var/obj/Skills/Queue/Q, noGCD = FALSE)
			if(src.HeldSkillBlocksAction(Q)) return
			if(src.Guarding) return
			if(!noGCD && GCDBlocked(Q)) return
			if(src.passive_handler.Get("Silenced"))
				src << "You can't use [Q] you are silenced!"
				return 0
			if(src.Airborne)
				return
			if(Q.Using)
				return//Can't use if on cooldown
			if(istype(Q, /obj/Skills/Queue/Heavy_Strike) && src.passive_handler["Heavy Strike"] == "Warp Strike")
				var/obj/Skills/Projectile/Warp_Strike_MasterOfArms/P = src.FindSkill(/obj/Skills/Projectile/Warp_Strike_MasterOfArms)
				if(!P)
					src << "You need to be in Master of Arms to use Warp Strike!"
					return
				if(P.Using || P.cooldown_remaining)
					return
				if(!src.Target || src.Target == src)
					src << "You need a target to use Warp Strike!"
					return
				var/obj/Items/Sword/sword = src.EquippedSword()
				var/obj/Items/Enchantment/Staff/staff = src.EquippedStaff()
				if(!sword && !staff)
					src << "You need a weapon equipped to use Warp Strike!"
					return
				animate(src, color=list(1,0,0, 0,1,0, 0,0,1, 1,1,1), time=1)
				spawn(1)
					if(src)
						animate(src, color=list(1,0,0, 0,1,0, 0,0,1, 0,0,0), time=1)
				P.IconLock = sword ? sword.icon : staff.icon
				P.adjust(src)
				src.WarpStrikeHidingWeapon = 1
				src.AppearanceOff()
				src.AppearanceOn()
				src.warp_strike_saved_loc = get_turf(src)
				if(!src.UseProjectile(P, noGCD = TRUE))
					src.WarpStrikeHidingWeapon = 0
					src.AppearanceOff()
					src.AppearanceOn()
					src.warp_strike_saved_loc = null
				return
			if(!Q.heavenlyRestrictionIgnore&&Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Queues"))
				return
			if(!Q.heavenlyRestrictionIgnore&&Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("All Skills"))
				return
			if(!Q.heavenlyRestrictionIgnore&&Q.NeedsSword && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Armed Skills"))
				return
			if(!Q.heavenlyRestrictionIgnore&&Q.UnarmedOnly && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Unarmed Skills"))
				return
			if(Q.StanceNeeded)
				if(src.StanceActive!=Q.StanceNeeded)
					src << "You have to be in [Q.StanceNeeded] stance to use this!"
					return
			if(Q.StyleNeeded)
				if(src.StyleActive!=Q.StyleNeeded && !src.CheckSlotless(Q.StyleNeeded))
					src << "You have to be using [Q.StyleNeeded] style to use this!"
					return
			if(Q.ABuffNeeded)
				if(!src.ActiveBuff||src.ActiveBuff.BuffName!=Q.ABuffNeeded)
					src << "You have to be in [Q.ABuffNeeded] state!"
					return
			if(Q.SBuffNeeded)
				if(!src.SpecialBuff||src.SpecialBuff.BuffName!=Q.SBuffNeeded)
					src << "You have to be in [Q.SBuffNeeded] state!"
					return

			if(Q.GateNeeded)
				if(!src.CheckActive("Eight Gates"))
					src << "You need to open your Eight Gates to use [Q]!"
					return
				if(src.GatesActive<Q.GateNeeded)
					src << "You have to open at least Gate [Q.GateNeeded] to use this skill!"
					return
			if(Q.FocusShifter)
				src.ActivateFocusShift(Q.FocusShiftType, Q.FocusShiftBoost, Q.FocusShiftTimer, Q.FocusStatIdentity())
			if(Q.NeedsHealth)
				if(src.HealthPct()>Q.NeedsHealth*(1-src.HealthCut))
					src << "You can't use [Q] before you're below [Q.NeedsHealth*(1-src.HealthCut)]% health!"
					return
			if(Q.MagicNeeded&&!src.HasLimitlessMagic())
				if(src.HasMechanized()&&src.HasLimitlessMagic()!=1)
					src << "You lack the ability to use magic!"
					return
				if(src.HasMagicTaken())
					src << "Your mana circuits are too damaged to use magic! (until [time2text(src.MagicTaken, "DDD MMM DD hh:mm:ss")])"
					return;
				if(Q.Copyable>=3||!Q.Copyable)
					if(src.Saga!="Persona"&&src.Saga!="Magic Knight"&&!src.is_arcane_beast)
						var/obj/Items/Enchantment/Staff/st=src.EquippedStaff()
						//var/obj/Items/Enchantment/Magic_Crest/mc=src.EquippedCrest()
						var/obj/Items/Sword/sord=src.EquippedSword()
						if(!st&&!(CrestSpell(Q))&&(!sord||sord&&!sord.MagicSword))
							src << "You need a spell focus to use [Q]."
							return
			if(Q.NeedsSword||Q.UnarmedOnly)
				var/obj/Items/Sword/s=src.EquippedSword()
				if(Q.NeedsSword)
					if((!s && !HasBladeFisting()) && !src.UsingBattleMage())
						src << "You must have a sword equipped to use this technique."
						return
				if(Q.UnarmedOnly)//Has Sword AND UnarmedOnly.
					if(!HasBladeFisting() && s)
						src << "You can't have a sword equipped to use this technique."
						return
					if(src.UsingBattleMage())
						src << "You can't use unarmed techniques while using Battle Mage!"
						return
				if(Q.ClassNeeded)
					if(s.Class!=Q.ClassNeeded)
						src << "You need a [Q.ClassNeeded]-class weapon to use this technique."
						return
			if(Q.NeedsGun)
				if(!src.EquippedGun())
					src << "You must have a gun equipped to use this technique."
					return
			if(Q.NoGun || !Q.NeedsGun)
				if(src.EquippedGun())
					src << "You can't queue a strike with a gun equipped."
					return
			if(Q.HealthCost)
				if(src.HealthPct()<Q.HealthCost*glob.WorldDamageMult&&!Q.AllOutAttack)
					return
			if(Q.EnergyCost)
				var/drain = passive_handler["Drained"] ? Q.EnergyCost * (1 + passive_handler["Drained"]/10) : Q.EnergyCost
				if(src.Energy<drain&&!Q.AllOutAttack&&!RiposteReady())
					if(!src.CheckSpecial("One Hundred Percent Power")&&!src.CheckSpecial("Fifth Form")&&!CheckActive("Eight Gates"))
						return
			if(Q.ManaCost && !src.HasDrainlessMana() && !Q.AllOutAttack)
				var/drain = Q.ManaCost
				drain *= src.ChakraCostMult(Q)
				if(drain <= 0)
					drain = 0.5
				if(!src.TomeSpell(Q))
					if(src.ManaAmount<drain)
						src << "You don't have enough mana to activate [Q]."
						return
				else
					if(src.ManaAmount<drain*(1-(0.45*src.TomeSpell(Q))))
						src << "You don't have enough mana to activate [Q]."
						return
			if(Q.AssociatedGear)
				if(!Q.AssociatedGear.InfiniteUses)
					if(Q.Integrated)
						if(Q.AssociatedGear.IntegratedUses<=0)
							src << "Your [Q] has run out of power!"
							if(src.ManaAmount>10)
								src.LoseMana(10)
								src << "Your [Q] automatically replenishes itself!"
								Q.AssociatedGear.IntegratedUses=Q.AssociatedGear.IntegratedMaxUses
							return
					else
						if(Q.AssociatedGear.Uses<=0)
							src << "[Q] doesn't have enough power to function!"
							return
			if(Q.Combo)
				if(src.Target==null)
					src << "You need a target to use [Q]!"
					return
				if(src.Target==src)
					src << "You can't target yourself with [Q]!"
					return
			if(src.Beaming > 0.5)
				return
			if(src.AttackQueue)
				src << "<b>You drop [src.AttackQueue.name] from your queue.</b>"
				src.QueueOverlayRemove()
				src.ClearQueue()
			if(src.RippleActive())
				var/BreathCost=1*Q.DamageMult
				if(Q.InstantStrikes)
					BreathCost*=Q.InstantStrikes
				if(src.Oxygen>=BreathCost)
					Q.RipplePower*=(1+(0.25*src.GetRipple()*max(1,src.PoseEnhancement*2)))
					Q.DamageMult*=Q.RipplePower
					Q.AccuracyMult*=Q.RipplePower
					src.Oxygen-=BreathCost/4
				else if(src.Oxygen>=src.OxygenMax*0.3)
					Q.RipplePower*=(1+(0.125*src.GetRipple()*max(1,src.PoseEnhancement*2)))
					Q.DamageMult*=Q.RipplePower
					Q.AccuracyMult*=Q.RipplePower
					src.Oxygen-=BreathCost/6
				else
					src.Oxygen-=BreathCost/8
				if(src.Oxygen<=0)
					src.Oxygen=0
			if(Q.Copyable)
				spawn() for(var/mob/m in view(10, src))
					if(m.CheckSpecial("Sharingan"))
						var/copy = Q.Copyable
						var/copyLevel = getSharCopyLevel(m.SagaLevel)
						if(Q.NewCopyable)
							copy = Q.NewCopyable
						else
							copy = Q.Copyable
						if(copyLevel < copy)
							continue
						if(m.client&&m.client.address==src.client.address)
							continue
						if(!locate(Q.type, m))
							var/obj/Skills/copiedSkill = new Q.type
							m.AddSkill(copiedSkill)
							copiedSkill.Copied = TRUE
							copiedSkill.copiedBy = "Sharingan"
							m << "Your Sharingan analyzes and stores the [Q] technique you've just viewed."
				spawn()
					for(var/obj/Items/Tech/Security_Camera/SC in view(10, src))
						if(IsList(Q.PreRequisite))
							SC.ObservedTechniques["[Q.type]"]=Q.Copyable

			if(Q.Counter)
				KenShockwave(src,icon='KenShockwaveBloodlust.dmi',Size=0.4, Blend=2, Time=2)
			if(!Q.Combo && src.HasCounterMaster() && CounterMasterTimer <= 0)
				Q.CounterTemp = 0.1 * src.HasCounterMaster()
				KenShockwave(src,icon='KenShockwaveBloodlust.dmi',Size=0.3, Blend=2, Time=2)
				CounterMasterTimer = max(1, 25 - (src.HasCounterMaster()*5))
			if(Q.QueueWindup)
				OMsg(src, "<b>[src] winds up [Q.name]...</b>")
				src.WindingUp = 1
				sleep(Q.QueueWindup)
				src.WindingUp = 0
				if(src.KO || src.Stunned || src.Suspended || src.Stasis > 0)
					return
			src.AttackQueue=Q
			RiposteConsume(Q)
			if(Q.CCImmuneCast)
				src.cc_immune_until = world.time + Q.CCImmuneCast
			if(Q.WeaveDodge)
				src.pre_weave_sdtl = src.SureDodgeTimerLimit
				src.SureDodgeTimerLimit = Q.WeaveDodge
				src.SureDodgeTimer = Q.WeaveDodge
			if(Q.DashScaling)
				src.last_combo_warp_dist = 0
			src.queue_counter_until = world.time + min(glob.TIMING_WINDOW + src.HasCounterMaster()*glob.QUEUE_COUNTER_CM_BONUS, glob.QUEUE_COUNTER_MAX)
			src.AttackQueue.RanOut=0
			src.AttackQueue.Hit=0
			src.AttackQueue.Missed=0
			if(src.AttackQueue.MultiHit)
				src.AttackQueue.HitsUsed=0
			src << "<font color=#ff0000>You queue up a [Q.name]!</font>"
			if(src.AttackQueue.GrabTrigger)
				var/path=text2path(src.AttackQueue.GrabTrigger)
				if(path && !locate(path, src))
					src.AddSkill(new path)
			src.QueuedActivationMessage()
			src.QueueOverlayAdd()
			if(src.TomeSpell(Q))
				Q.Cooldown()
			else
				Q.Cooldown()

			if(Q.Duration >= 0)
				spawn(Q.Duration*10)//After the duration...
					if(AttackQueue&&src.AttackQueue==Q)
						if(src.AttackQueue.ComboPerformed<1&&src.AttackQueue.InstantStrikesPerformed<1)
							src.AttackQueue.RanOut=1
							src.AttackQueue.Hit=0
							src.AttackQueue.Missed=0
							src.ClearQueue()
							src << "<font color=#ff0000>You drop [Q.name]!</font>"
		QueuedDamage(var/mob/P)
			var/Damage=1
			// this acts as a multiplier, so something like a 5 damage mult will result in insane numbers
			DEBUGMSG("START DAMAGE: [Damage]")
			if(AttackQueue.Finisher && P.HealthPct() < 50)
				var/missing = abs(P.HealthPct()-50)
				var/extra = missing * (glob.FINISHERDMG * AttackQueue.Finisher)
				Damage+=extra // glob (0.5% * finisher) extra damage for every health under 50 )
			DEBUGMSG("NEW DAMAGE AFTER FINISHER: [Damage]")
			if(AttackQueue.Opener && P.HealthPct() > 50)
				var/missing = abs(50-P.HealthPct())
				var/extra = missing * (glob.OPENERDMG * AttackQueue.Opener)
				Damage+=extra
			DEBUGMSG("NEW DAMAGE AFTER OPENER: [Damage]")
			if(src.AttackQueue.Decider)
				var/deciderDmg = glob.DECIDERDMG * AttackQueue.Decider // the extra amount of damage to do in the case everyiong = 1
				var/healthcloseness = abs(HealthPct() - P.HealthPct())/100
				deciderDmg *= (1 - healthcloseness)
				if(deciderDmg > 0)
					Damage+=deciderDmg
			DEBUGMSG("NEW DAMAGE AFTER DECIDER: [Damage]")
			if(AttackQueue.Dominator)
				if(HealthPct()>P.HealthPct())
					var/ratio = clamp(HealthPct() / P.HealthPct(), 1, 4)
					if(ratio > 0)
						Damage += (ratio-1) * ( AttackQueue.Dominator / 4)
			DEBUGMSG("NEW DAMAGE AFTER DOMINATOR: [Damage]")
			if(AttackQueue.Determinator)
				if(HealthPct()<P.HealthPct()&&Health!=0)
					var/ratio = clamp( P.HealthPct() / HealthPct(), 1, 4)
					if(ratio > 0)
						Damage+= (ratio-1) * (AttackQueue.Determinator / 4)
			DEBUGMSG("NEW DAMAGE AFTER DETERMINATOR: [Damage]")
			if(src.AttackQueue.Delayer)
				var/addDamage = src.AttackQueue.Delayer*src.AttackQueue.DelayerTime
				Damage+=(addDamage)
			DEBUGMSG("NEW DAMAGE AFTER DELAYER: [Damage]")
			if(src.AttackQueue.SpeedStrike>0)
				Damage *= clamp(sqrt( ( 1+ ( src.GetSpd()+glob.LIGHT_ATTACK_SPEED_STAT_BASE)*( src.AttackQueue.SpeedStrike/glob.SPEEDSTRIKEDIVISOR ) ) ),1 ,3)
			DEBUGMSG("NEW DAMAGE AFTER SPEEDSTRIKE: [Damage]")
			if(src.AttackQueue.SweepStrike>0)
				Damage *= clamp(sqrt(( 1+ (P.GetSpd()+glob.LIGHT_ATTACK_SPEED_STAT_BASE)*(src.AttackQueue.SweepStrike/glob.SWEEPSTRIKEDIVISOR))),1 ,3)
			DEBUGMSG("NEW DAMAGE AFTER SWEEPSTRIKE: [Damage]")
			if(src.AttackQueue.GodPowered)
				src.transcend(src.AttackQueue.GodPowered)
			if(AttackQueue.HarderTheyFall && P.BioArmor)
				Damage +=  P.BioArmor / glob.HARDER_THEY_FALL_BIO_DIVISOR // i want to make the ticks matter, but cant formulate an idea how
			if(AttackQueue.HarderTheyFall && P.VaizardHealth)
				Damage += P.VaizardHealth / glob.HARDER_THEY_FALL_VAI_DIVISOR // i want to make the ticks matter, but cant formulate an idea how
			DEBUGMSG("NEW DAMAGE AFTER HARDERTHEYFALL: [Damage]")
			if(src.AttackQueue.CosmoPowered)
				if(!src.SpecialBuff)
					Damage+=(0.5+(src.SenseUnlocked-4))
			if(Damage<1)
				Damage = 1
			if(src.AttackQueue.DashScaling && src.AttackQueue.Warp)
				Damage *= 0.7 + 0.6 * min(src.last_combo_warp_dist / src.AttackQueue.Warp, 1)
			if(src.AttackQueue.CrescendoRider)
				Damage *= 1 + 0.02 * src.AttackQueue.ComboPerformed
			if(src.AttackQueue.StoredPain)
				if(world.time - src.pain_stamp > 50)
					src.pain_amount = 0
				Damage *= min(0.5 + (src.pain_amount / 30) * 0.8, 1.3)
			if(src.AttackQueue.DamageMult>=0)
				var/dmgMult = src.AttackQueue.DamageMult * GetDisarmedQueueDamageFactor(src.AttackQueue)
				if(passive_handler["Fa Jin"] && canFaJin())
					dmgMult+= passive_handler["Fa Jin"] * glob.FA_JIN_BASE_DMG_ADD
				DEBUGMSG("NEW DAMAGE AFTER FA JIN (FINAL DAMAGE): [Damage]")
				Damage*=dmgMult
			if(Damage>0 && glob.GLOBAL_QUEUE_DAMAGE > 0)
				Damage *= glob.GLOBAL_QUEUE_DAMAGE

			return Damage
		QueuedAccuracy()
			var/Accuracy=1
			if(src.AttackQueue.AccuracyMult)
				Accuracy=src.AttackQueue.AccuracyMult
			//Maybe there will be accuracy passives...But not now.
			return Accuracy
		QueuedKBAdd()
			var/KB=0
			if(src.AttackQueue.KBAdd)
				KB+=src.AttackQueue.KBAdd
			if(passive_handler["Fa Jin"] && canFaJin())
				KB+= passive_handler["Fa Jin"] * glob.FA_JIN_BASE_KB_ADD
			//One day, passives.
			return KB
		QueuedKBMult()
			var/Mult=1
			if(src.AttackQueue.KBMult)
				Mult*=src.AttackQueue.KBMult
			//One day, passives.
			return Mult
		QueuedActivationMessage()
			if(src.AttackQueue.CustomCharge)
				OMsg(src, SkillActivationMsg(src.AttackQueue, "[src.AttackQueue.CustomCharge]"))
			else
				if(src.AttackQueue.ActiveMessage)
					if(src.AttackQueue.TextColor)
						src.OMessage(10, SkillActivationMsg(src.AttackQueue, "<font color='[src.AttackQueue.TextColor]'><b>[src] [src.AttackQueue.ActiveMessage]</b></font color>"), "[src]([src.key]) queued [src.AttackQueue].")
					else
						src.OMessage(10, SkillActivationMsg(src.AttackQueue, "<font color='[rgb(255,153,51)]'><b>[src] [src.AttackQueue.ActiveMessage]</b></font>"), "[src]([src.key]) queued [src.AttackQueue].")
			if(src.AttackQueue.Recoil)
				src.RecoilDamage=src.AttackQueue.Recoil
			if(src.AttackQueue.Combo)
				src.AttackQueue.ComboPerformed=0
			if(src.AttackQueue.BankedRelease)
				src.AttackQueue.bank_stacks=0
		QueuedHitMessage(var/mob/P)
			if(!AttackQueue) return
			src.AttackQueue.Hit=1
			src.AttackQueue.Missed=0
			src.AttackQueue.RanOut=0
			if(istype(src.AttackQueue, /obj/Skills/Queue/Judgment_Cut_End) && P && !P.ActionLocked)
				P.ActionLocked = 1
				src.ActionLocked = 1
				var/mob/who = P
				var/mob/U = src
				// Heh
				spawn(10)
					if(U && who)
						U.dir = turn(get_dir(U, who), 180)
				var/obj/Skills/AutoHit/Judgment_Cut_End/AH = locate() in src
				var/release_delay = AH ? (AH.WindUp * 10 + 10) : 40
				spawn(release_delay)
					if(who && who.ActionLocked)
						who.ActionLocked = null
					if(U && U.ActionLocked)
						U.ActionLocked = null
			if(canFaJin())
				last_fa_jin = world.time
				fa_jin_effect()
				FaJinEmpowered(P)
			if(istype(src.AttackQueue, /obj/Skills/Queue/Shoryuken))
				if(src.AttackQueue.ShoryukenEffect==2)
					OMsg(src, "[src] yells: SHORYUKEN!", "[src] used Shoryuken.")
			if(src.AttackQueue.CustomActive)
				if(src.AttackQueue.Combo||src.AttackQueue.InstantStrikes)
					if(!src.AttackQueue.ComboMessaged)
						OMsg(src, "[src.AttackQueue.CustomActive]")
						src.AttackQueue.ComboMessaged=1
				else
					OMsg(src, "[src.AttackQueue.CustomActive]")
			else
				if(src.AttackQueue.HitMessage)
					if(src.AttackQueue.Combo||src.AttackQueue.InstantStrikes)
						if(!src.AttackQueue.ComboMessaged)
							if(src.AttackQueue.TextColor)
								src.OMessage(10, "<font color='[src.AttackQueue.TextColor]'><b>[src] [src.AttackQueue.HitMessage]</b></font color>", "[src]([src.key]) hit with [src.AttackQueue].")
							else
								src.OMessage(10, "<font color='red'><b>[src] [src.AttackQueue.HitMessage]</b></font color>", "[src]([src.key]) hit with [src.AttackQueue].")
							src.AttackQueue.ComboMessaged=1
					else
						if(src.AttackQueue.TextColor)
							src.OMessage(10, "<font color='[src.AttackQueue.TextColor]'><b>[src] [src.AttackQueue.HitMessage]</b></font color>", "[src]([src.key]) hit with [src.AttackQueue].")
						else
							src.OMessage(10, "<font color='red'><b>[src] [src.AttackQueue.HitMessage]</b></font color>", "[src]([src.key]) hit with [src.AttackQueue].")
			if(src.AttackQueue.DashScaling && src.AttackQueue.Warp && src.last_combo_warp_dist >= src.AttackQueue.Warp - 1)
				Stun(P, 0.3)
			if(src.AttackQueue.Stunner)
				Stun(P, src.AttackQueue.Stunner+src.GetStunningStrike())
				if(src.AttackQueue.Stunner>5)
					P << "Your mind is under attack!"
					if(P.client)
						animate(P.client, color = list(-1,-1,-1, -1,-1,-1, -1,-1,-1, 1,1,1), time = 5)
					P.TsukiyomiTime=src.AttackQueue.Stunner+1
			if(src.AttackQueue.RozanEffect)
				var/Time=src.AttackQueue.RozanEffect
				spawn()src.Quake(8)
				RozanEffect(src, P, Time)
			if(src.AttackQueue.ShoryukenEffect)
				var/Time=src.AttackQueue.ShoryukenEffect
				spawn()src.Quake(8)
				ShoryukenEffect(src, P, Time)
			if(src.AttackQueue.GoshoryukenEffect)
				var/Time=src.AttackQueue.GoshoryukenEffect
				spawn()src.Quake(8)
				GoshoryukenEffect(src, P, Time)

			if(src.AttackQueue.BuffAffected)
				var/path=text2path(src.AttackQueue.BuffAffected)
				var/obj/Skills/Buffs/S = P.findOrAddSkill(path)
				S.Password=P.name

			if(src.AttackQueue.Projectile && !src.AttackQueue.BankedRelease)
				var/path=text2path(src.AttackQueue.Projectile)
				var/x=src.AttackQueue.ProjectileCount
				if(!locate(path, src))
					src.AddSkill(new path)
				for(var/obj/Skills/Projectile/p in src)
					if(istype(p, path))
						for(x, x>0, x--)
							if(src.AttackQueue.ProjectileCDBypass||src.AttackQueue.ProjectileCount>1)
								p.Using=0
							if(!p.AttackReplace)
								p.AttackReplace=1
							src.UseProjectile(p, noGCD = TRUE)
							if(src.AttackQueue.ProjectileBeam&&!p.Immediate)
								src.UseProjectile(p, noGCD = TRUE)//Double tap for beaming
							sleep(1)
						break


		QueuedMissMessage()
			if(!AttackQueue) return
			src.AttackQueue.Missed=1
			src.AttackQueue.Hit=0
			src.AttackQueue.RanOut=0
			if(canFaJin())
				last_fa_jin = world.time
				fa_jin_effect()
			if(src.AttackQueue.CustomOff)
				OMsg(src, "[src.AttackQueue.CustomOff]")
			else
				if(src.AttackQueue.MissMessage)
					src.OMessage(10, "<font color='yellow'><b>[src] [src.AttackQueue.MissMessage]</b></font color>", "[src]([src.key]) missed with [src.AttackQueue].")
			if(src.AttackQueue.Projectile && !src.AttackQueue.BankedRelease)
				var/path=text2path(src.AttackQueue.Projectile)
				if(!locate(path, src))
					src.AddSkill(new path)
				for(var/obj/Skills/Projectile/p in src)
					if(istype(p, path))
						for(var/x=src.AttackQueue.ProjectileCount, x>0, x--)
							if(src.AttackQueue.ProjectileCDBypass||src.AttackQueue.ProjectileCount>1)
								p.Using=0
							if(!p.AttackReplace)
								p.AttackReplace=1
							src.UseProjectile(p, noGCD = TRUE)
							if(src.AttackQueue.ProjectileBeam&&!p.Immediate)
								src.UseProjectile(p, noGCD = TRUE)//Double tap for beaming
							sleep(1)
						break
			if(src.AttackQueue.MultiHit)
				src.AttackQueue.HitsUsed++
				if(src.AttackQueue.HitsUsed>=src.AttackQueue.MultiHit)
					src.ClearQueue()
			else
				src.ClearQueue()

		ClearQueue()
			src.QueueOverlayRemove()
			if(src.AttackQueue.WeaveDodge)
				src.SureDodgeTimerLimit = src.pre_weave_sdtl
				src.pre_weave_sdtl = 0
				if(!src.SureDodgeTimerLimit)
					src.SureDodgeTimer = 0
					src.SureDodge = 0
			if(src.AttackQueue.BankedRelease)
				src.AttackQueue.bank_stacks = 0
			src.AttackQueue.CounterTemp=0
			src.AttackQueue.DelayerTime=0
			if(src.AttackQueue.ComboMessaged)
				src.AttackQueue.ComboMessaged=0
			if(src.AttackQueue.InstantStrikes)
				src.AttackQueue.InstantStrikesPerformed=0
				src.AttackQueue.NoWarp=0
			if(src.AttackQueue.Combo)
				src.AttackQueue.ComboPerformed=0
			if(src.AttackQueue.RipplePower>1)
				src.AttackQueue.DamageMult/=src.AttackQueue.RipplePower
				src.AttackQueue.AccuracyMult/=src.AttackQueue.RipplePower
				src.AttackQueue.RipplePower=1
			if(src.AttackQueue.HealthCost)
				src.DoDamage(src, src.PctToHP(TrueDamage(src.AttackQueue.HealthCost*glob.WorldDamageMult)))
			if(src.AttackQueue.WoundCost)
				src.WoundSelf(src.AttackQueue.WoundCost*glob.WorldDamageMult)
			if(src.AttackQueue.EnergyCost && !src.AttackQueue.energy_free)
				var/drain = passive_handler["Drained"] ? src.AttackQueue.EnergyCost * (1 + passive_handler["Drained"]/10) : src.AttackQueue.EnergyCost
				src.LoseEnergy(drain)
			if(src.AttackQueue.FatigueCost)
				src.GainFatigue(src.AttackQueue.FatigueCost)

			if(src.AttackQueue.ManaGain)
				src.HealMana(AttackQueue.ManaGain)
			if(src.AttackQueue.ManaCost)
				var/drain = AttackQueue.ManaCost
				drain *= src.ChakraCostMult(src.AttackQueue)
				if(drain <= 0)
					drain = 0.5
				if(src.TomeSpell(src.AttackQueue))
					src.LoseMana(drain*(1-(0.45*src.TomeSpell(src.AttackQueue))))
				else
					src.LoseMana(drain)
			if(src.AttackQueue.AssociatedGear)
				if(!src.AttackQueue.AssociatedGear.InfiniteUses)
					if(src.AttackQueue.Integrated)
						src.AttackQueue.AssociatedGear.IntegratedUses--
						if(src.AttackQueue.AssociatedGear.IntegratedUses<=0)
							src << "Your [src.AttackQueue] is out of power!"
							if(src.ManaAmount>=10)
								src << "Your [src.AttackQueue] automatically draws on new power to reload!"
								src.LoseMana(10)
								src.AttackQueue.AssociatedGear.IntegratedUses=src.AttackQueue.AssociatedGear.IntegratedMaxUses
					else
						src.AttackQueue.AssociatedGear.Uses--
						if(src.AttackQueue.AssociatedGear.Uses<=0)
							src << "[src.AttackQueue] is out of power!"
			if(src.AttackQueue.Hit)
				if(src.AttackQueue.GrabTrigger)
					var/grabPath = src.AttackQueue.GrabTrigger
					for(var/obj/Skills/Grapple/g in src.Skills)
						if(g.type==text2path(grabPath))
							g.Activate(src, TRUE)
				if(src.AttackQueue.FollowUp)
					spawn(AttackQueue.FollowUpDelay) // EWWWW
						throwFollowUp(AttackQueue.FollowUp)

			if(src.AttackQueue.BuffSelf)
				buffSelf(AttackQueue.BuffSelf)
			if(!src.AttackQueue.Step&&!src.AttackQueue.MissStep&&!src.AttackQueue.HitStep)
				src.AttackQueue=null
			else
				if(!src.AttackQueue.Hit&&!src.AttackQueue.RanOut&&src.AttackQueue.Missed)
					if(src.AttackQueue.MissStep)
						var/obj/Skills/Queue/S=new src.AttackQueue.MissStep
						src.AttackQueue=null
						src.SetQueue(S, TRUE)
						return
				else if(!src.AttackQueue.RanOut&&!src.AttackQueue.Missed&&src.AttackQueue.Hit)
					if(src.AttackQueue.HitStep)
						if(src.AttackQueue.ChainBlockStop && src.AttackQueue.chain_victim && src.AttackQueue.chain_victim.IsGuarding())
							src.AttackQueue=null
							return
						var/obj/Skills/Queue/S=new src.AttackQueue.HitStep
						S.adjust(src)
						src.AttackQueue=null
						src.SetQueue(S, TRUE)
						return
				else if(!src.AttackQueue.RanOut&&(src.AttackQueue.Missed||src.AttackQueue.Hit))
					var/obj/Skills/Queue/S=new src.AttackQueue.Step
					src.AttackQueue=null//But this triggers either way so long as you didn't just run out of time.
					src.SetQueue(S, TRUE)
					return

				src.AttackQueue=null


		QueueOverlayAdd()
			src.FlashQueueArm()
			//tell
			if(src.AttackQueue.IconLock == 'BLANK.dmi')
				src.queue_tell_aura = 1	//remove
				if(!src.AuraLocked&&!src.HasKiControl())
					src.Auraz("Add")
				else
					KenShockwave(src,icon='KenShockwaveFocus.dmi',Size=0.3, Blend=2, Time=2)
				return
			if(src.AttackQueue.IconLock)
				if(src.AttackQueue.IconLock!=1)
					if(src.AttackQueue.IconLockUnder)
						src.underlays+=image(icon=src.AttackQueue.IconLock, pixel_x=src.AttackQueue.LockX, pixel_y=src.AttackQueue.LockY)
					else
						src.overlays+=image(icon=src.AttackQueue.IconLock, pixel_x=src.AttackQueue.LockX, pixel_y=src.AttackQueue.LockY)
				else
					if(!src.AuraLocked&&!src.HasKiControl())
						src.Auraz("Add")
					else
						KenShockwave(src,icon='KenShockwaveFocus.dmi',Size=0.3, Blend=2, Time=2)
		QueueOverlayRemove()
			src.FlashQueueArmEnd()
			if(src.queue_tell_aura)
				src.queue_tell_aura = 0
				if(!src.AuraLocked&&!src.HasKiControl())
					src.Auraz("Remove")
				return
			if(src.AttackQueue.IconLock)
				if(src.AttackQueue.IconLock!=1)
					if(src.AttackQueue.IconLockUnder)
						src.underlays-=image(icon=src.AttackQueue.IconLock, pixel_x=src.AttackQueue.LockX, pixel_y=src.AttackQueue.LockY)
					else
						src.overlays-=image(icon=src.AttackQueue.IconLock, pixel_x=src.AttackQueue.LockX, pixel_y=src.AttackQueue.LockY)
				else
					if(!src.AuraLocked&&!src.HasKiControl())
						src.Auraz("Remove")
