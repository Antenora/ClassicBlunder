obj
	Skills
		Queue//Queued skills like GET DUNKED and Axekick.
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
			var/KBDelayed//KBs after the move is finished
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
			var/PrecisionStrike//attack only what you want to
			var/SpeedStrike/*Passive that multiplies damage by speed mod.  1 = 0.5 speed, 2 = full speed.*/
			var/SweepStrike/*Passive that multiplies damage by enemy's speed.  Reverse Speed Strike!*/
			var/DrawIn/*Passive that draws people in.  DrawIn value = the amount of tiles drawn in.*/
			var/PushOut//Passive that pushes people away. PushOut value = the amount of tiles pushed away.
			var/PushOutWaves=1
			var/PushOutIcon='fevKiai.dmi'
			var/Punt
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
			var/Bolt//Makes lightning drop effect.
			var/Darkness//Makes darkness tiles.
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


			var/Quaking //Makes screen go shakka shakka
			var/WarpAway



			var/SpiritStrike //Targets End with Force
			var/HybridStrike //For+Str
			var/SpiritHand //Sunlight stance
			var/SpiritSword //duh
			var/KiBlade //duh
			var/PridefulRage

			var/ManaGain

			//Instinct //Ignore AIS/WS
			var/Steady //It do what steady do.
			var/WeaponBreaker //WHAT DO U THINK?!
			var/MortalBlow //WHHHHHHHHHHHAAAAAAAAAA-

			var/HitSparkIcon//you
			var/HitSparkX//know
			var/HitSparkY//how
			var/HitSparkSize//it
			var/HitSparkTurns//do
			var/HitSparkDispersion=8


			var/RipplePower=1//used to make ripple go higher
			var/DrainBlood=0// This is used for vampire grab + toss, makes them gain bloodpower
			var/ForceCost = 0

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
			Finisher
				Duration=5
				Instinct=4
				DamageMult=1
				AccuracyMult=20
				KBMult=0.001
				Decider=1
				Instinct=4
				Finisher=1
				Rapid=1
				Warp=3
				PushOut=2
				PushOutWaves=3
				PushOutIcon='fevKiai.dmi'
				BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Generic_Finisher"
				HitMessage="strikes their opponent with a powerful blow!"
				Generic_Finisher
					name="Finishing Blow"

				Cycle_of_Samsara
					adjust(mob/p)
						switch(Mastery)
							if(0)
								BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Samsara/Naraka"
							if(1)
								BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Samsara/Preta"
							if(2)
								BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Samsara/Tiryag"
							if(3)
								BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Samsara/Asura"
							if(4)
								BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Samsara/Mansuya"
							if(5)
								BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Samsara/Deva"
							if(6)
								BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Samsara/Buddha"
							if(7)
								BuffSelf=null
					Warp = 10
					Instinct = 2
					PushOut=1
					PushOutWaves=1
					Decider = 4
					DamageMult=1
					KBAdd = 0.01
					InstantStrikes=4

				Iron_Fortress
					Shattering=20
					DamageMult=3
					FollowUp="/obj/Skills/AutoHit/Shatter_Shell"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Turtle_Martial_Mastery"
					HitMessage="slams the full weight of their body into the opponent in a shoulder check!"
				Fire_Dancer
					DamageMult=2
					KBAdd=5
					KBMult=2
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Crane_Martial_Mastery"
					FollowUp="/obj/Skills/Projectile/Phoenix_Flares"
					HitMessage="turns on their heel, sending the enemy skyward with a reverse rising kick!"
				Dragon_Falls
					DamageMult=1.5
					Grapple=1
					KBMult=0.001
					FollowUp="/obj/Skills/Grapple/Snake_Fang_Bites"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Snake_Martial_Mastery"
					HitMessage="swings low and hooks the opponent into the air by the neck!"
				Hungry_Fang
					Stunner=1
					DamageMult=2.5
					FollowUp="/obj/Skills/AutoHit/Cat_Claw_Rush"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Cat_Martial_Mastery"
					HitMessage="delivers a brutal overhand swipe with a raking claw!"

				//t1 signature styles
				Eight_Trigrams
					Combo=8
					DamageMult=0.75
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Ki_Flow_Mastery"
					HitMessage="spins around their victim, striking endless pressure points in succession!"
				Rising_Wind
					KBMult=2
					KBAdd=10
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Body_Mastery"
					HitMessage="carries their opponent through a brutal haymaker!"
					FollowUp="/obj/Skills/AutoHit/Strongest_Fist"
				Rolling_Sobat
					Warp=5
					Paralyzing=10
					Crippling=10
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Rush_Mastery"
					HitMessage="cuts in with a smooth rolling kick to the side!"
					FollowUp="/obj/Skills/AutoHit/Blitz_Rush"

				//t2 signature styles
				Tetsuzankou
					DamageMult=3
					SoftStyle=2
					FollowUp="/obj/Skills/AutoHit/Drunken_Crash"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Drunken_Mastery"
					HitMessage="slides in with unnatural grace, delivering a bone crushing shoulder check!"
				Galactica_Phantom
					DamageMult=3
					HardStyle=2
					HitMessage="launches an earth-shattering, explosive clothesline!"
					FollowUp="/obj/Skills/AutoHit/Galaxy_Clothesline"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Strength_Mastery"
				Spiral_Fang
					DamageMult=2.5
					HardStyle=1.5
					HitMessage="drives their opponent into the ground with a twisting slam attack!"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Dire_Empowerment"
				Astral_Shot
					DamageMult=2.5
					HitMessage="lands a brutal orbital kick, draining some of the victim's life from the impact!"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Astral_Empowerment"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Astral_Drain"
				Immortal_Change
					Paralyzing=50
					Scorching=50
					Freezing=50
					Crushing=50
					HitMessage="unleashes a sphere of pure elemental chaos around them, and rams it into their foe!"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Chaos_Empowerment"
				Maiden_Masher
					DamageMult=3
					HitMessage="unleashes their wrath on the opponent, engulfing them in an explosive wave of dark flame!"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Devil_Luck"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Devil_Fire"
				
				Morbid_Angel
					DamageMult=3
					Launcher=3
					HitMessage="leaps onto their enemy's shoulders, gouging their throat with deadly venom!"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Death_Mastery"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Bio_Break"

				//t1 sig styles
				Ray_Divider
					DamageMult=2
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Forced_Mechanize"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Cyber_Crusher"
					HitMessage="launches a magic-powered strike that magnetically charges the enemy!"
				Badlands
					DamageMult=2
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Toxic_Crash"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Venom_Break"
					HitMessage="digs their venom deep into the flesh of their victim, forcing them to suffer..."
				Crimson_Star_Road
					DamageMult=2
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Corona_Splash"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Solar_Break"
					HitMessage="slides coolly past the opponent, before a string of explosions lights them up!"
				Surprise_Rose
					DamageMult=2
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Stillness"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Anger_Break"
					HitMessage="leaps towards the opponent, mocking them with repeated stomps from above!"

				Challenge
					Warp=10
					DamageMult = 2
					KBMult=0.001
					Instinct = 1
					FollowUp="/obj/Skills/Queue/Finisher/Duel"
					HitMessage="darts at their enemy!"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Champion_Pride"

				Mist_Finer
					Warp=10
					FollowUp="/obj/Skills/Queue/Finisher/Drawing_Mist"
					HitMessage="strikes out with such speed and precision that their blade disappears!"
				Drawing_Mist
					Warp=10
					DamageMult=3
					SpeedStrike=4
					HitMessage="draws their blade back in from the dispersed mist!"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Off_Balance"
					BuffSelf=0
				Vicious_Moon
					Counter=1
					Stunner=2
					FollowUp="/obj/Skills/AutoHit/Blooming_Moon"
					HitMessage="carves a crescent through their foolish victim!"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Attack_Break"
					BuffSelf=0
				Soul_Survivor
					Warp=10
					Instinct=1
					KBMult=0.001
					FollowUp="/obj/Skills/AutoHit/Divide_Effect"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Overwhelmed"
					HitMessage="carves through the earth, destroying everything between them and their foe!"
					BuffSelf=0
				Hammer_Fall
					Counter=1
					Grapple=1
					KBMult=0.001
					FollowUp="/obj/Skills/Grapple/Hammer_Crush"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Debilitated"
					HitMessage="presses their powerful grip around both sides of the helpless foe!"
					BuffSelf=0

				//tier 1 sig styles

				Behemoth_Typhoon
					Steady = 4
					WeaponBreaker = 2
					Crushing = 20
					Finisher = 1
					DamageMult = 1
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Arena_Champion"
					HitMessage="flies forward in a whirlwind of piercing blades!"
					FollowUp="/obj/Skills/AutoHit/Giga_Impact"
				Geo_de_Ray
					DamageMult=2
					Warp=10
					Crippling=10
					SpeedStrike=1
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Dual_Break"
					HitMessage="flies forward in a whirlwind of piercing blades!"
					FollowUp="/obj/Skills/Queue/Finisher/Dual_Flurry"
					BuffSelf=0
				Dual_Flurry
					Combo=20
					DamageMult=0.5
					PushOutWaves=0
					HitMessage="rips through their opponent with countless slashes!"
					IconLock='CircleWind.dmi'
					LockX=-32
					LockY=-32
					BuffSelf=0
				Ichimonji
					DamageMult=2
					KBMult=0.0001
					FollowUp="/obj/Skills/AutoHit/Flowing_Slash_Follow_Up"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Technique_Break"
					HitMessage="'s step is fluid and calm, landing a single, staggering overhead strike!"
					BuffSelf=0
				Flying_Barcelona
					Warp=10
					Grapple=1
					KBMult=0.001
					GrabTrigger="/obj/Skills/Grapple/Sword/Butterfly_Souffle"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Desiccated"
					HitMessage="soars through the air to their opponent with blade out, seizing them from a blind spot!"
					BuffSelf=0
				Manji_Flip
					Warp=10
					Launcher=5
					DamageMult=3
					FollowUp="/obj/Skills/AutoHit/Whirlwind_Handstand"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Feral_Fear"
					HitMessage="performs an uncanny acrobatic strike, rocketing their foe upwards!"
					BuffSelf=0

				//t2 sig style
				Shield_Vault
					Warp = 20 // just jump to tht guy
					Stunner = 5
					InstantStrikes = 4
					HitMessage="leaps onto their target with their shield before delivering an onslaught of slashes with their spear!"
					FollowUp="/obj/Skills/AutoHit/Comet_Spear"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Mortal_Will"
					DamageMult = 1


				Ogre_Cutter
					DamageMult=5
					Warp=10
					Crippling=20
					HitMessage="carves out with all three blades, leaving devastation in their wake!"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Tri_Break"
					FollowUp="/obj/Skills/Projectile/Oni_Giri"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Trinity_Mastery"
				Crimson_Fountain
					DamageMult=5
					KBMult=2
					Shearing=20
					FollowUp="/obj/Skills/Projectile/Devil_Divide"
					HitMessage="drives their bare fist into the enemy's chest, then hurls them away like trash!"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Impaled"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Maim_Mastery"
				Sacred_Edge
					DamageMult=3
					SpiritStrike=3
					HitMessage="drives a colossal shard of concentrated mana into the foe point-blank!"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Mana_Break"
					BuffSelf=0
				Absolute_Truth
					DamageMult=1
					Warp=10
					FollowUp="/obj/Skills/AutoHit/Stop_Effect"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Evasion_Negation"
					HitMessage="drives their staff into the ground, letting out a pulse of sealing force!"
					BuffSelf=0


				Shield_Bash
					DamageMult=3
					KBAdd = 5
					Stunner = 5
					Crippling = 50

					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Bashing"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Stumbling"
					HitMessage="bashes their shield against their target, sending them stumbling!"

				Berserker_Claw
					DamageMult=3
					Warp=10
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Bestial_Accuracy"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Locked_On"
					HitMessage="is gone in an instant, appearing behind their target for a vicious attack!"
				Evac_Toss
					DamageMult=2
					Counter=1
					Launcher=2
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Martial_Flow"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Disoriented"
					HitMessage="uses their opponent's momentum, effortlessly launching them skyward!"
				Armor_Piercer
					DamageMult=3
					WeaponBreaker=1.5
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Anti_Material_Augment"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Broken_Bones"
					HitMessage="tears through the enemy's defense with a driving body blow!"
				Riot_Stamp
					DamageMult=1.5
					KBMult=2
					KBAdd=5
					Launcher=2
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Speed_Break"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Slow_Motion"
					HitMessage="hops back, then leaps in to stomp their opponent into the floor!"

				//t1 sig styles
				Impact_Palm
					KBAdd=10
					DamageMult=1.5
					SpiritStrike=1
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Sure_Shot"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Traced"
					HitMessage="breaks their enemy's defenses by shattering their aura with a swift energized palm!"
				Superbia
					KBMult=0.01
					Crippling=10
					DamageMult=1.5
					SpiritStrike=1
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Seeking_Spirits"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Traced"
					HitMessage="'s fist surge with power as they plunge into the enemy's aura, halting them in place!"
				Turn_of_Fortune
					DamageMult=3
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Ineffective_Fate"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Fortunate_Fate"
					HitMessage="gracefully spins around their foe's flank, landing precision strikes along the way!"
				Chemical_Love
					DamageMult=2
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Speed_of_Sound"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Shattered"
					HitMessage="'s perfect chord sends a razor-sharp soundwave through the opponent's body!"

				//t2 sig style
				Raioken
					InstantStrikes=10
					InstantStrikesDelay=1
					DamageMult=0.25
					HitMessage="unleashes a barrage of countless fists!"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Flash_Cry"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Slow_Motion"
				Karaniyam
					DamageMult=2.5
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/What_Must_Be_Done"
					HitMessage="chants a line of prayer!"
				Bicycle_Kick
					DamageMult=2.5
					HitMessage="spikes their opponent into the air before battering them with rapid kicks!"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Self_Mastery"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Self_Shattered"
				Centifoila
					InstantStrikes=10
					InstantStrikesDelay=1
					DamageMult=0.25
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Dance_Mastery"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Ineffective_Fate"

				//t3 sig style
				Pressure_Point
					Stunner=3
					Launcher=3
					DamageMult=2
					HitMessage="locks their opponent's body up by striking a pressure point in their chest!"
					FollowUp="/obj/Skills/Queue/Hokuto_Hyakuretsu_Ken"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/North_Strength"

				Imperial_Assessment
					NoWhiff=1
					NoForcedWhiff=1
					CursedWounds=1
					DamageMult=3
					Grapple=1
					HitMessage="takes a measure of their opponent, before discarding them as worthless!"
					BuffSelf=0
					FollowUp="/obj/Skills/Grapple/Imperial_Disgust"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Useless"

				Over_The_Horizon
					DamageMult=2
					Launcher=3
					HitMessage="shoots their opponent into the sky on a sudden whirlwind! They're on someone else's turf now!"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/East_Strength"

				Atomic_Split
					DamageMult=3
					Crippling=10
					HitMessage="punts their opponent up into the air!"
					FollowUp="/obj/Skills/AutoHit/Atomic_Crush"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Radioactive"
					BuffSelf=0

				Ashura_Kai
					DamageMult=1
					PureDamage=5
					InstantStrikes=10
					InstantStrikesDelay=1.5
					HitSparkIcon='Slash - Ragna.dmi'
					HitSparkX=-32
					HitSparkY=-32
					HitSparkTurns=1
					HitMessage="expresses the mastery of a war god by casting innumerable strikes in an instant!"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/War_God"

				Journey_End
					DamageMult=1
					KBMult=0.001
					Crippling=20
					HitMessage="delivers a perfectly smooth blow to the enemy's sternum ... But that's not all ..."
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Flowing_River"

				Death_Rattle
					DamageMult=1
					KBMult=0.001
					Crippling=20
					HitMessage="pauses in their rhythm ... The silence seems to stretch forever."
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Moelach_Weezing"
					FollowUp="/obj/Skills/Projectile/Warsong_Finale"
					BuffSelf=0

				Skyward_Strike
					Stunner=3
					Launcher=3
					DamageMult=2
					KBAdd=5
					KBMult=0.000001
					HitMessage="sends their opponent airbourne with an upwards strike!"
					FollowUp="/obj/Skills/AutoHit/Tensho_Juji_Ho"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/South_Break"
					BuffSelf=0

				//Ansatsuken Finisher
				Isshin
					DamageMult=3
					Counter=1
					Stunner=5
					KBMult=4
					KBAdd=5
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Hado_Kakusei"
					FollowUp="/obj/Skills/Projectile/Hadoken_Effect"
				
				Shin_Shoryuken
					StyleNeeded="Ansatsuken"
					HitMessage="shouts '<b>SHIN...</b>' as they strike their opponent with a rising blow!!!"
					DamageMult=4
					AccuracyMult = 1.25
					KBMult=0.00001
					PushOut=3
					AllOutAttack=1
					Instinct=4
					Stunner=3
					Duration=10
					Rapid=1
					HitStep=/obj/Skills/Queue/Finisher/Shin_Shoryuken2


				Shin_Shoryuken2
					StyleNeeded="Ansatsuken"
					HitMessage="shouts '<b>SHORYUKEN!</b>' as they spike their opponent into the heavens with a divine uppercut!!!"
					DamageMult=6
					AccuracyMult = 1.25
					KBMult=0.00001
					Duration=5
					Warp=5
					Instinct=4
					Launcher=3
					ShoryukenEffect=2
					Shattering=30
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Heat_Rush"

				Shoryureppa1
					DamageMult=7
					name="Shoryureppa"
					HitStep=/obj/Skills/Queue/Finisher/Shoryureppa2
					ShoryukenEffect=0.5
					AccuracyMult=20
					HitMessage=0
				Shoryureppa2
					DamageMult=7
					name="Shoryureppa"
					ShoryukenEffect=2
					Shattering=30
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Heat_Rush"
				Shippu_Jinraikyaku
					DamageMult=2
					PushOutWaves=0
					PushOut=0
					Combo=4
					Rapid=1
					HitStep=/obj/Skills/Queue/Finisher/Shippu_Jinraikyaku2
					BuffSelf=0
					HitMessage=0
				Shippu_Jinraikyaku2
					DamageMult=4
					Rapid=1
					FollowUp="/obj/Skills/AutoHit/Tatsumaki_Effect"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Violent_Personality"

				Rakan_Dantojin
					DamageMult=2
					AccuracyMult=20
					FollowUp="/obj/Skills/AutoHit/Shun_Goku_Satsu"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Violent_Personality"


				//Hiten Finisher
				Flash_Strike
					DamageMult=3
					Counter=1
					Warp=10
					SpeedStrike=2
					SlayerMod=2
					FollowUp="/obj/Skills/AutoHit/Shunshin_Massacre"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Shunshin"
				True_Flash_Strike
					DamageMult=2.5
					Counter=1
					Warp=10
					SpeedStrike=2
					SlayerMod=3
					FollowUp="/obj/Skills/AutoHit/Shunshin_Massacre"
					BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Godspeed_Assaulted"
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Shunshin_Shin"

				//Keyblade Finishers
				Fever_Pitch
					KBAdd=2
					Launcher=2
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Fever_Pitch"
					FollowUp="/obj/Skills/AutoHit/FeverPitch"
					HitMessage="drives their heart into a fever pitch!"
				Fatal_Mode
					KBMult=0.001
					Stunner=2
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Fatal_Mode"
					FollowUp="/obj/Skills/AutoHit/FatalMode"
					HitMessage="embraces the inevitability of a fatality!"
				Magic_Wish
					InstantStrikes=5
					InstantStrikesDelay=2
					PrecisionStrike=2
					DamageMult=0.25
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Magic_Wish"
					FollowUp="/obj/Skills/AutoHit/MagicWish"
					HitMessage="hopes upon a magic wish!"
				Fire_Storm
					Projectile="/obj/Skills/Projectile/Fire_Storm"
					ProjectileCount=10
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Fire_Storm"
					HitMessage="casts down a fire storm!"
				Diamond_Dust
					PrecisionStrike=3
					InstantStrikes=5
					InstantStrikesDelay=2
					DamageMult=0.2
					Freezing=10
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Diamond_Dust"
					HitMessage="twirls with diamond dust!"
				Thunderbolt
					Warp=10
					SpeedStrike=2
					Paralyzing=10
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Thunderbolt"
					HitMessage="lashes out quicker than a thunderbolt!"

				Wing_Blade
					Warp=10
					SpeedStrike=4
					Launcher=2
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Wing_Blade"
					FollowUp="/obj/Skills/AutoHit/WingbladeFlash"
					HitMessage="reveals a marvelous light!"
				Cyclone
					Warp=10
					SpeedStrike=4
					Launcher=2
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Cyclone"
					FollowUp="/obj/Skills/AutoHit/CycloneCharge"
					HitMessage="spins forward in a high-tension cyclone!"

				Rock_Breaker
					Stunner=5
					DamageMult=0.25
					Combo=10
					Projectile=/obj/Skills/Projectile/Rock_Bits
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Rock_Breaker"
					HitMessage="barrages their enemy with bone-breaking rocks!"
				Dark_Impulse
					Stunner=5
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Dark_Impulse"
					FollowUp="/obj/Skills/AutoHit/Dark_Blast"
					HitMessage="unleashes a point-blank blast of darkness!"
				Ghost_Drive
					SpiritHand=1
					SpiritStrike=1
					PridefulRage=1
					Combo=10
					DamageMult=0.1
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Ghost_Drive"
					HitMessage="phases through every defense like a ghost!"
				Blade_Charge
					SpiritHand=1
					SpiritStrike=1
					PridefulRage=1
					Crippling=10
					KBMult=0.001
					BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Blade_Charge"
					FollowUp="/obj/Skills/AutoHit/BladeChargeRave"
					HitMessage="hyper charges their keyblade with mana!"



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
				Warp=5
				KBAdd=5
				KBMult=0.00001
				HitSparkIcon='Hit Effect.dmi'
				HitSparkX=-32
				HitSparkY=-32
				ActiveMessage="smashes their fist into their opponents face!" //WA TA
////Keyblade

			Heavy_Strike
				Duration=5
				DamageMult=2
				AccuracyMult=1
				KBAdd=5
				KBMult=3
				Cooldown=15
				verb/Heavy_Strike()
					set category="Skills"
					if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasRestriction("Heavy Strike"))
						return
					var/maxTension = 100
					if(usr.passive_handler.Get("Conductor"))
						maxTension = max(glob.MIN_TENSION, 100 - usr.passive_handler.Get("Conductor"))
					if(usr.Tension>=maxTension)
						if(usr.HasTensionLock())
							return
						if(usr.AttackQueue)
							return
						usr.Tension=0
						if(usr.StyleBuff.Finisher)//if the style has a unique finisher
							var/path = usr.StyleBuff.Finisher
							if(!ispath(usr.StyleBuff.Finisher))
								path=text2path(usr.StyleBuff.Finisher)
							var/obj/Skills/Queue/q
							if(!locate(path, usr))
								q = new path
								usr.AddSkill(q)//give it an object type to allow for customizations
							else
								q = usr.FindSkill(path)
							q.adjust(usr)
							// for(var/obj/Skills/Queue/q in usr.Queues)
							// 	if(q.type==path)
							usr.SetQueue(q)
						else
							usr.SetQueue(new/obj/Skills/Queue/Finisher/Generic_Finisher)
						return
					else
						if(usr.AttackQueue)
							return // prevent heavy strike from overriding

						if(usr.passive_handler["Heavy Strike"])
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
									
						else
							// reset all
							Grapple = 0
							FollowUp = null


						if(!usr.Secret && !usr.HasWitchCraft() || usr.Secret == "Goetic Virtue" || usr.Secret == "Stellar Constellation" || usr.Secret == "Elven Sanctuary" || usr.Secret == "Eldritch" && !usr.CheckSlotless("True Form") || usr.Secret == "Jagan" ||usr.Secret=="Necromancy"||usr.Secret=="Ripple"&&!usr.HasRipple()||usr.Secret=="Senjutsu"&&!usr.CheckSlotless("Senjutsu Focus") || usr.Secret =="Heavenly Restriction" && !usr.secretDatum?:hasImprovement("Heavy Strike"))//Just default Heavy Strike
							src.name="Heavy Strike"
							src.DamageMult=2
							src.AccuracyMult=1
							Duration=5
							src.KBAdd=5
							src.KBMult=3
							src.Cooldown=15
							src.ActiveMessage=0
							src.HitMessage=0
							src.Ooze = 0
							src.CursedWounds=0
							src.Scorching=0
							src.Freezing=0
							src.Paralyzing=0
							src.Shattering=0
							src.Toxic=0
							src.Combo=0
							src.Warp=0
							src.Rapid=0
							src.LifeSteal=0
							src.Crippling=0
							src.Grapple=0
							Dunker = 0
							Launcher = 0
							PushOutWaves = 0
							PushOut = 0
							src.NoForcedWhiff=0
							src.IconLock='BLANK.dmi'
							src.HitSparkIcon=null
							src.HitSparkX=0
							src.HitSparkY=0
							src.HitSparkTurns=0
							src.HitSparkSize=1
							usr.SetQueue(src)
							return//and that's the end
						if(usr.Secret=="Heavenly Restriction" && usr.secretDatum?:hasImprovement("Heavy Strike"))
							src.name="Heavy Strike"
							src.DamageMult= 2 + usr.secretDatum?:getBoon(usr, "Heavy Strike")
							PushOutWaves = usr.secretDatum?:getBoon(usr, "Heavy Strike")
							PushOut = usr.secretDatum?:getBoon(usr, "Heavy Strike")
							src.AccuracyMult = 1 + usr.secretDatum?:getBoon(usr, "Heavy Strike")
							src.KBAdd = 5 + usr.secretDatum?:getBoon(usr, "Heavy Strike")
							src.KBMult= 1 + usr.secretDatum?:getBoon(usr, "Heavy Strike")
							src.Cooldown=15
							src.ActiveMessage=0
							src.HitMessage=0
							src.Ooze = 0
							src.CursedWounds=0
							src.Scorching=0
							src.Freezing=0
							src.Paralyzing=0
							src.Shattering=0
							src.Toxic=0
							src.Combo=0
							src.Warp=0
							src.Rapid=0
							src.LifeSteal=0
							src.Crippling=0
							src.Grapple=0
							src.NoForcedWhiff=0
							src.IconLock='BLANK.dmi'
							src.HitSparkIcon=null
							src.HitSparkX=0
							src.HitSparkY=0
							src.HitSparkTurns=0
							src.HitSparkSize=1
							Dunker = 0
							Launcher = 0
							if(usr.Target.Launched)
								Dunker = usr.secretDatum?:getBoon(usr, "Heavy Strike")
							else
								Launcher = usr.secretDatum?:getBoon(usr, "Heavy Strike")
							usr.SetQueue(src)
						if(usr.Secret == "Eldritch" && usr.CheckSlotless("True Form"))
							src.name="Maleific Strike"
							src.DamageMult=3
							src.AccuracyMult = 3
							src.KBAdd=2
							src.KBMult=1.5
							src.Ooze = 1
							src.Cooldown=30
							src.ActiveMessage="leaks some of their malefic presence onto the world!"
							src.HitMessage=0
							src.Scorching=3 + (2*usr.AscensionsAcquired)
							src.Freezing=3 + (2*usr.AscensionsAcquired)
							src.Paralyzing=3 + (2*usr.AscensionsAcquired)
							src.Shattering=3 + (2*usr.AscensionsAcquired)
							src.CursedWounds=0
							src.Toxic=3 + (2*usr.AscensionsAcquired)
							src.Combo=0
							src.Warp=0
							src.Rapid=0
							src.LifeSteal=0
							src.Crippling=0
							src.Grapple=0
							src.NoForcedWhiff=0
							src.IconLock='BLANK.dmi'
							src.HitSparkIcon=null
							src.HitSparkX=0
							src.HitSparkY=0
							src.HitSparkTurns=0
							src.HitSparkSize=1
							usr.SetQueue(src)
						if(usr.Secret=="Senjutsu"&&usr.CheckSlotless("Senjutsu Focus"))
							src.name="Sage Energy Strike"
							src.DamageMult=2
							src.AccuracyMult = 1.1
							src.KBAdd=5
							src.KBMult=3
							src.Cooldown=30
							src.ActiveMessage="focuses natural energy in their fist!"
							src.HitMessage=0
							src.Scorching=3
							src.Freezing=3
							src.Paralyzing=3
							src.Shattering=3
							src.CursedWounds=0
							src.Ooze = 0
							src.Toxic=0
							src.Combo=0
							src.Warp=0
							src.Rapid=0
							src.LifeSteal=0
							src.Crippling=0
							src.Grapple=0
							src.NoForcedWhiff=0
							src.IconLock='BLANK.dmi'
							src.HitSparkIcon=null
							src.HitSparkX=0
							src.HitSparkY=0
							src.HitSparkTurns=0
							src.HitSparkSize=1
							usr.SetQueue(src)
						if(usr.Secret=="Haki")
							usr.AddHaki("Armament")
							if(!usr.CheckSlotless("Haki Armament"))
								for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Armament/H in usr)
									H.Trigger(usr)
							if(usr.CheckSlotless("Haki Observation"))
								for(var/obj/Skills/Buffs/SlotlessBuffs/Haki/Haki_Observation/H in usr)
									H.Trigger(usr)
							if(usr.secretDatum.secretVariable["HakiSpecialization"]=="Armament")
								src.name="Buso: Koka"
								src.DamageMult = 1 + usr.secretDatum.currentTier
								src.AccuracyMult = 1.15
								src.KBAdd=10
								src.KBMult=3
								src.Cooldown=20
								src.ActiveMessage="has their arms darken in preparation for a devastating attack!"
								src.Paralyzing=0
								src.Toxic=0
								src.Scorching=0
								src.Ooze = 0
								src.Freezing=0
								src.Shattering=0
								src.Combo=0
								src.CursedWounds=0
								src.Warp=0
								src.Rapid=0
								src.LifeSteal=0
								src.Crippling=0
								src.Grapple=0
								src.NoForcedWhiff=1
								src.HitSparkIcon=0
								src.HitSparkX=0
								src.HitSparkY=0
								src.HitSparkTurns=0
								src.HitSparkSize=2
								src.IconLock='BusoKoka.dmi'
								usr.SetQueue(src)
								return
							else
								src.name="Armament Strike"
								src.DamageMult=2
								src.AccuracyMult = 1.15
								src.KBAdd=5
								src.KBMult=3
								src.Cooldown=20
								src.ActiveMessage="focuses their will into their fist!"
								src.Paralyzing=0
								src.Toxic=0
								src.Scorching=0
								src.Freezing=0
								src.Shattering=0
								src.Ooze = 0
								src.Combo=0
								src.CursedWounds=0
								src.Warp=0
								src.Rapid=0
								src.LifeSteal=0
								src.Crippling=0
								src.Grapple=0
								src.NoForcedWhiff=1
								src.HitSparkIcon=0
								src.HitSparkX=0
								src.HitSparkY=0
								src.HitSparkTurns=0
								src.HitSparkSize=1
								src.IconLock='BLANK.dmi'
								usr.SetQueue(src)
								return
						if(usr.Secret=="Ripple"&&usr.HasRipple())
							if(usr.SwordWounds()||usr.Harden)//no barrage for swords
								src.name="Ripple Overdrive"
								src.DamageMult=2
								src.AccuracyMult = 1.15
								src.KBAdd=5
								src.KBMult=3
								src.Cooldown=30
								src.HitMessage="channels the Ripple through metal: <b>Metal Silver Overdrive!!</b>"
								src.Paralyzing=0
								src.Toxic=0
								src.Scorching=0
								src.Freezing=0
								src.Shattering=0
								src.CursedWounds=0
								src.Ooze = 0
								src.Combo=0
								src.Warp=2
								src.Rapid=0
								src.LifeSteal=0
								src.Crippling=0
								src.Grapple=0
								src.NoForcedWhiff=0
								src.IconLock='Ultima Arm.dmi'
								src.HitSparkIcon=0
								src.HitSparkX=0
								src.HitSparkY=0
								src.HitSparkTurns=0
								src.HitSparkSize=1
								usr.SetQueue(src)
								return
							if(prob(20))//always check for the barrage
								src.name="Ripple Overdrive"
								src.DamageMult=1
								src.AccuracyMult = 1.15
								src.KBAdd=1
								src.KBMult=1
								src.Cooldown=30
								src.HitMessage="channels the Ripple for multiple powerful hits: <b>OVERDRIVE BARRAGE!!</b>"
								src.Scorching=0
								src.Freezing=0
								src.Paralyzing=0
								src.Ooze = 0
								src.Toxic=0
								src.Shattering=0
								src.CursedWounds=0
								src.Combo=5
								src.Warp=5
								src.Rapid=0
								src.LifeSteal=0
								src.Crippling=0
								src.Grapple=0
								src.NoForcedWhiff=0
								src.IconLock='Ripple Arms.dmi'
								src.HitSparkIcon=0
								src.HitSparkX=0
								src.HitSparkY=0
								src.HitSparkTurns=0
								src.HitSparkSize=1
								usr.SetQueue(src)
								return
							if(usr.ElementalOffense=="Water"||usr.Swim)
								src.name="Ripple Overdrive"
								src.DamageMult=2
								src.AccuracyMult = 1.15
								src.KBAdd=5
								src.KBMult=3
								src.Cooldown=20
								src.HitMessage="channels the Ripple through water: <b>Turquoise Blue Overdrive!!</b>"
								src.Scorching=0
								src.Freezing=10
								src.Paralyzing=0
								src.Toxic=0
								src.Shattering=0
								src.CursedWounds=0
								src.Combo=0
								src.Warp=0
								src.Rapid=0
								src.LifeSteal=0
								src.Crippling=0
								src.Grapple=0
								src.NoForcedWhiff=0
								src.IconLock='Ultima Arm.dmi'
								src.HitSparkIcon=0
								src.HitSparkX=0
								src.HitSparkY=0
								src.HitSparkTurns=0
								src.HitSparkSize=1
								usr.SetQueue(src)
								return
							if(usr.ElementalOffense=="Fire"||usr.Burn)
								src.name="Ripple Overdrive"
								src.DamageMult=3
								src.AccuracyMult = 1.1
								src.KBAdd=5
								src.KBMult=3
								src.Cooldown=20
								src.HitMessage="channels the Ripple into fire: <b>Scarlet Overdrive!!</b>"
								src.Scorching=10
								src.Freezing=0
								src.Paralyzing=0
								src.Toxic=0
								src.Shattering=0
								src.CursedWounds=0
								src.Combo=0
								src.Ooze = 0
								src.Warp=0
								src.Rapid=0
								src.LifeSteal=0
								src.Crippling=0
								src.Grapple=0
								src.NoForcedWhiff=0
								src.IconLock='Ultima Arm.dmi'
								src.HitSparkIcon=0
								src.HitSparkX=0
								src.HitSparkY=0
								src.HitSparkTurns=0
								src.HitSparkSize=1
								usr.SetQueue(src)
								return
							if(usr.ElementalOffense=="Wind"||usr.Flying)
								src.name="Ripple Overdrive"
								src.DamageMult=2
								src.AccuracyMult = 1.15
								src.KBAdd=5
								src.KBMult=3
								src.Cooldown=20
								src.HitMessage="channels the Ripple through a spinning kick: <b>Tornado Overdrive!!</b>"
								src.Scorching=0
								src.Freezing=0
								src.Paralyzing=10
								src.CursedWounds=0
								src.Ooze = 0
								src.Toxic=0
								src.Combo=0
								src.Warp=3
								src.Rapid=1
								src.LifeSteal=0
								src.Crippling=0
								src.Grapple=0
								src.NoForcedWhiff=0
								src.IconLock='Ultima Arm.dmi'
								src.HitSparkIcon=0
								src.HitSparkX=0
								src.HitSparkY=0
								src.HitSparkTurns=0
								src.HitSparkSize=1
								usr.SetQueue(src)
								return
							if(usr.ElementalOffense=="Earth")
								src.name="Ripple Overdrive"
								src.DamageMult=3
								src.AccuracyMult = 1.1
								src.KBAdd=10
								src.KBMult=5
								src.Cooldown=20
								src.HitMessage="channels the Ripple through solid rock: <b>Sendo Ripple Overdrive!!</b>"
								src.Scorching=0
								src.Freezing=0
								src.Paralyzing=0
								src.Toxic=0
								src.Shattering=10
								src.CursedWounds=0
								src.Combo=0
								src.Warp=0
								src.Rapid=0
								src.Ooze = 0
								src.LifeSteal=0
								src.Crippling=0
								src.Grapple=0
								src.NoForcedWhiff=0
								src.IconLock='Ultima Arm.dmi'
								src.HitSparkIcon=0
								src.HitSparkX=0
								src.HitSparkY=0
								src.HitSparkTurns=0
								src.HitSparkSize=1
								usr.SetQueue(src)
								return
							//But if all those fail, use this
							src.name="Ripple Overdrive"
							src.DamageMult=1
							src.AccuracyMult = 1.15
							src.KBAdd=5
							src.KBMult=3
							src.Cooldown=20
							src.HitMessage="channels the Ripple through their strikes: <b>Ripple Overdrive!!</b>"
							src.Scorching=0
							src.Freezing=0
							src.Paralyzing=0
							src.Toxic=0
							src.Ooze = 0
							src.CursedWounds=0
							src.Combo=0
							src.Warp=0
							src.Rapid=0
							src.LifeSteal=0
							src.Crippling=0
							src.Grapple=0
							src.NoForcedWhiff=0
							src.IconLock='Ultima Arm.dmi'
							src.HitSparkIcon=0
							src.HitSparkX=0
							src.HitSparkY=0
							src.HitSparkTurns=0
							src.HitSparkSize=1
							usr.SetQueue(src)
							return
						if(usr.Secret=="Vampire")
							if(!usr.PoseEnhancement)
								src.name="Vampiric Strike"
								src.DamageMult=2
								src.AccuracyMult = 1.1
								src.KBAdd=0
								src.KBMult=0.0001
								src.Cooldown=20
								src.HitMessage="rips out their opponent's life force with a powerful strike!"
								src.Scorching=0
								src.Freezing=0
								src.Paralyzing=0
								src.Toxic=0
								src.CursedWounds=0
								src.Combo=0
								src.Warp=0
								src.Ooze = 0
								src.Rapid=0
								src.LifeSteal=100
								src.Crippling=0
								src.Grapple=0
								src.NoForcedWhiff=0
								src.IconLock='BLANK.dmi'
								src.HitSparkIcon='Hit Effect Vampire.dmi'
								src.HitSparkX=-32
								src.HitSparkY=-32
								src.HitSparkTurns=0
								src.HitSparkSize=1
								usr.SetQueue(src)
								return
							else
								src.name="Vampiric Strike"
								src.DamageMult=3
								src.AccuracyMult = 1.15
								src.KBAdd=5
								src.KBMult=0.0001
								src.Cooldown=20
								src.HitMessage="rips their opponent to shreds!"
								src.Scorching=0
								src.Freezing=0
								src.Paralyzing=0
								src.Ooze = 0
								src.Toxic=0
								src.CursedWounds=0
								src.Combo=0
								src.Warp=0
								src.Rapid=0
								src.LifeSteal=100
								src.Crippling=0
								src.Grapple=0
								src.NoForcedWhiff=0
								src.IconLock='BLANK.dmi'
								src.HitSparkIcon='Slash - Vampire.dmi'
								src.HitSparkX=-32
								src.HitSparkY=-32
								src.HitSparkTurns=1
								src.HitSparkSize=2
								usr.SetQueue(src)
						if(usr.Secret=="Werewolf")
							src.name="Rip and Tear"
							src.DamageMult=2
							src.AccuracyMult = 1.1
							src.KBAdd=0
							src.KBMult=5
							src.Cooldown=20
							src.HitMessage="digs their claws into their opponent, dealing crippling wounds!"
							src.Scorching=0
							src.Freezing=0
							src.Paralyzing=0
							src.Toxic=0
							src.CursedWounds=0
							src.Combo=0
							src.Warp=0
							src.Rapid=0
							src.Ooze = 0
							src.LifeSteal=0
							src.Crippling=3
							src.Grapple=0
							src.NoForcedWhiff=0
							src.IconLock='BLANK.dmi'
							src.HitSparkIcon='WolfFF.dmi'
							src.HitSparkX=0
							src.HitSparkY=0
							src.HitSparkTurns=1
							src.HitSparkSize=2
							usr.SetQueue(src)
							return
						if(usr.StyleActive == "Witch" && usr.HasWitchCraft())
							src.ActiveMessage="weaves their hands towards the central mass of their enemies!"
							src.name = "Soulsap Strike"
							src.DamageMult=1.5
							src.AccuracyMult = 1.15
							src.KBAdd=0
							src.KBMult=1
							src.Cooldown=20
							src.HitMessage= "grasps hold of their opponents soul -- Sapping away it's energy!"
							src.Scorching=0
							src.Freezing=1
							src.Paralyzing=0
							src.CursedWounds=5
							src.Decider = 1
							src.Combo=0
							src.Warp=2
							src.Rapid=0
							src.Crippling=15
							src.NoForcedWhiff=0
							src.IconLock='BLANK.dmi'
							src.HitSparkIcon='Icons/NSE/spells/debuff/holywaterflow.dmi'
							src.HitSparkX=-32
							src.HitSparkY=-32
							src.HitSparkTurns=1
							src.HitSparkSize=1
							usr.SetQueue(src)
							return
						if(usr.Secret=="Zombie")
							src.name="Death Grasp"
							src.DamageMult=2.5
							src.AccuracyMult = 1.15
							src.KBAdd=0
							src.KBMult=1
							src.Cooldown=20
							src.HitMessage="grasps hold of their opponent with necrotic energy!"
							src.Scorching=0
							src.Freezing=0
							src.Paralyzing=0
							src.Toxic= 25
							src.Shearing = 25
							src.Ooze = 0
							src.CursedWounds=1
							src.Decider = 1
							src.Combo=0
							src.Warp=0
							src.Rapid=0
							src.LifeSteal=0
							src.Crippling=15
							src.Grapple=1
							src.NoForcedWhiff=0
							src.IconLock='BLANK.dmi'
							src.HitSparkIcon='Hit Effect Wind.dmi'
							src.HitSparkX=-32
							src.HitSparkY=-32
							src.HitSparkTurns=1
							src.HitSparkSize=1
							usr.SetQueue(src)
							return

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
					usr.SetQueue(src)



//Knowledge
			Anesthetic_Strike
				ActiveMessage="prepares a needle!"
				HitMessage="jabs the needle and deploys the anesthetic into their target!"
				MissMessage="fumbles with the needle and wastes the anesthetic!"
				DamageMult=1
				AccuracyMult=1
				Duration=3
				Pacifying=60
				//doesn't get a verb because it is set from the tech item


			Symbiote_Hammer
				DamageMult=6
				AccuracyMult = 1.1
				Duration=10
				Cooldown=120
				Instinct=2
				Stunner=1
				Shearing = 5
				Crippling = 5
				HitMessage="'s symbiotic hammer swings dead center into their enemy!"
				ActiveMessage="'s symbiotic mass takes the shape of a hammer!"
				verb/Symbiote_Hammer()
					set category="Skills"
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
				SpiritStrike=1
				PridefulRage=1
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
					src.MultiHit=round(usr.ManaAmount/100,1)
					src.ManaCost=max(80, usr.ManaAmount)
					usr.SetQueue(src)

			Bad_Luck
				name="Bad Luck"
				HybridStrike=1
				DamageMult=4
				AccuracyMult = 1.1
				Duration=5
				Cooldown=30
				EnergyCost=3
				HitMessage="whacks their enemy with their instrument with a triumphant twang!!"
				verb/Bad_Luck()
					set category="Skills"
					usr.SetQueue(src)


mob
	proc
		SetQueue(var/obj/Skills/Queue/Q)
			if(src.passive_handler.Get("Silenced"))
				src << "You can't use [Q] you are silenced!"
				return 0
			if(Q.Using)
				return//Can't use if on cooldown
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
				if(src.StyleActive!=Q.StyleNeeded)
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
			if(Q.MagicNeeded&&!src.HasLimitlessMagic())
				if(src.HasMechanized()&&src.HasLimitlessMagic()!=1)
					src << "You lack the ability to use magic!"
					return
				if(Q.Copyable>=3||!Q.Copyable)
					if(src.Saga!="Persona"&&src.Saga!="Magic Knight"&&!src.is_arcane_beast)
						var/obj/Items/Enchantment/Staff/st=src.EquippedStaff()
						//var/obj/Items/Enchantment/Magic_Crest/mc=src.EquippedCrest()
						var/obj/Items/Sword/sord=src.EquippedSword()
						if(passive_handler.Get("Disarmed"))
							src << "You are disarmed you can't use [Q]."
							return
						if(!st&&!(CrestSpell(Q))&&(!sord||sord&&!sord.MagicSword))
							src << "You need a spell focus to use [Q]."
							return
			if(Q.NeedsSword||Q.UnarmedOnly)
				var/obj/Items/Sword/s=src.EquippedSword()
				if(Q.NeedsSword)
					if(passive_handler.Get("Disarmed"))
						src << "You are disarmed you can't use [Q]."
						return
					if(passive_handler.Get("Disarmed") && HasSwordPunching())
						src << "You are disarmed you can't use [Q]."
						return
					if((!s && !HasSwordPunching()) && !src.UsingBattleMage())
						src << "You must have a sword equipped to use this technique."
						return
				if(Q.UnarmedOnly)//Has Sword AND UnarmedOnly.
					if(!HasSwordPunching() && s)
						src << "You can't have a sword equipped to use this technique."
						return
					if(src.UsingBattleMage())
						src << "You can't use unarmed techniques while using Battle Mage!"
						return
				if(Q.ClassNeeded)
					if(s.Class!=Q.ClassNeeded)
						src << "You need a [Q.ClassNeeded]-class weapon to use this technique."
						return
			if(Q.HealthCost)
				if(src.Health<Q.HealthCost*glob.WorldDamageMult&&!Q.AllOutAttack)
					return
			if(Q.EnergyCost)
				var/drain = passive_handler["Drained"] ? Q.EnergyCost * (1 + passive_handler["Drained"]/10) : Q.EnergyCost
				if(src.Energy<drain&&!Q.AllOutAttack)
					if(!src.CheckSpecial("One Hundred Percent Power")&&!src.CheckSpecial("Fifth Form")&&!CheckActive("Eight Gates"))
						return
			if(Q.ManaCost && !src.HasDrainlessMana() && !Q.AllOutAttack)
				var/drain = src.passive_handler.Get("MasterfulCasting") ? Q.ManaCost - (Q.ManaCost * (passive_handler.Get("MasterfulCasting") * 0.3)) : Q.ManaCost
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
			if(src.HasRipple())
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
						if(glob.SHAR_COPY_EQUAL_OR_LOWER)
							if(copyLevel < copy)
								continue
						else
							if(copyLevel <= copy)
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
				Q.CounterTemp = 0.25 * src.GetCounterMaster()
				KenShockwave(src,icon='KenShockwaveBloodlust.dmi',Size=0.3, Blend=2, Time=2)
				CounterMasterTimer = max(1, 25 - (src.HasCounterMaster()*5))
			src.AttackQueue=Q
			src.AttackQueue.RanOut=0
			src.AttackQueue.Hit=0
			src.AttackQueue.Missed=0
			if(src.AttackQueue.MultiHit)
				src.AttackQueue.HitsUsed=0
			src << "<font color=#ff0000>You queue up a [Q.name]!</font>"
			if(src.AttackQueue.GrabTrigger)
				var/path=text2path(src.AttackQueue.GrabTrigger)
				if(!locate(path, src))
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
			if(AttackQueue.Finisher && P.Health < 50)
				var/missing = abs(P.Health-50)
				var/extra = missing * (glob.FINISHERDMG * AttackQueue.Finisher)
				Damage+=extra // glob (0.5% * finisher) extra damage for every health under 50 )
			DEBUGMSG("NEW DAMAGE AFTER FINISHER: [Damage]")
			if(AttackQueue.Opener && P.Health > 50)
				var/missing = abs(50-P.Health)
				var/extra = missing * (glob.OPENERDMG * AttackQueue.Opener)
				Damage+=extra
			DEBUGMSG("NEW DAMAGE AFTER OPENER: [Damage]")
			if(src.AttackQueue.Decider)
				var/deciderDmg = glob.DECIDERDMG * AttackQueue.Decider // the extra amount of damage to do in the case everyiong = 1
				var/healthcloseness = abs(Health - P.Health)/100
				deciderDmg *= (1 - healthcloseness)
				if(deciderDmg > 0)
					Damage+=deciderDmg
			DEBUGMSG("NEW DAMAGE AFTER DECIDER: [Damage]")
			if(AttackQueue.Dominator)
				if(Health>P.Health)
					var/ratio = clamp(Health / P.Health, 1, 4)
					if(ratio > 0)
						Damage += (ratio-1) * ( AttackQueue.Dominator / 4)
			DEBUGMSG("NEW DAMAGE AFTER DOMINATOR: [Damage]")
			if(AttackQueue.Determinator)
				if(Health<P.Health&&Health!=0)
					var/ratio = clamp( P.Health / Health, 1, 4)
					if(ratio > 0)
						Damage+= (ratio-1) * (AttackQueue.Determinator / 4)
			DEBUGMSG("NEW DAMAGE AFTER DETERMINATOR: [Damage]")
			if(src.AttackQueue.Delayer)
				var/addDamage = src.AttackQueue.Delayer*src.AttackQueue.DelayerTime
				Damage+=(addDamage)
			DEBUGMSG("NEW DAMAGE AFTER DELAYER: [Damage]")
			if(src.AttackQueue.SpeedStrike>0)
				Damage *= clamp(sqrt( ( 1+ ( src.GetSpd())*( src.AttackQueue.SpeedStrike/glob.SPEEDSTRIKEDIVISOR ) ) ),1 ,3)
			DEBUGMSG("NEW DAMAGE AFTER SPEEDSTRIKE: [Damage]")
			if(src.AttackQueue.SweepStrike>0)
				Damage *= clamp(sqrt(( 1+ (P.GetSpd())*(src.AttackQueue.SweepStrike/glob.SWEEPSTRIKEDIVISOR))),1 ,3)
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
			if(src.AttackQueue.DamageMult>=0)
				var/dmgMult = src.AttackQueue.DamageMult
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
				OMsg(src, "[src.AttackQueue.CustomCharge]")
			else
				if(src.AttackQueue.ActiveMessage)
					if(src.AttackQueue.TextColor)
						src.OMessage(10, "<font color='[src.AttackQueue.TextColor]'><b>[src] [src.AttackQueue.ActiveMessage]</b></font color>", "[src]([src.key]) queued [src.AttackQueue].")
					else
						src.OMessage(10, "<font color='[rgb(255,153,51)]'><b>[src] [src.AttackQueue.ActiveMessage]</b></font>", "[src]([src.key]) queued [src.AttackQueue].")
			if(src.AttackQueue.Recoil)
				src.RecoilDamage=src.AttackQueue.Recoil
			if(src.AttackQueue.Combo)
				src.AttackQueue.ComboPerformed=0
		QueuedHitMessage(var/mob/P)
			if(!AttackQueue) return
			src.AttackQueue.Hit=1
			src.AttackQueue.Missed=0
			src.AttackQueue.RanOut=0
			if(canFaJin())
				last_fa_jin = world.time
				fa_jin_effect()
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
			if(src.AttackQueue.Stunner)
				Stun(P, src.AttackQueue.Stunner+src.GetStunningStrike())
				if(src.AttackQueue.Stunner>5)
					P << "Your mind is under attack!"
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
				if(istype(S, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Death_Mark))
					S.adjust(StyleBuff.SignatureTechnique * 15, StyleBuff.SignatureTechnique)

			if(src.AttackQueue.Projectile)
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
							src.UseProjectile(p)
							if(src.AttackQueue.ProjectileBeam&&!p.Immediate)
								src.UseProjectile(p)//Double tap for beaming
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
			if(src.AttackQueue.Projectile)
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
							src.UseProjectile(p)
							if(src.AttackQueue.ProjectileBeam&&!p.Immediate)
								src.UseProjectile(p)//Double tap for beaming
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
				src.DoDamage(src, TrueDamage(src.AttackQueue.HealthCost*glob.WorldDamageMult))
			if(src.AttackQueue.WoundCost)
				src.WoundSelf(src.AttackQueue.WoundCost*glob.WorldDamageMult)
			if(src.AttackQueue.EnergyCost)
				var/drain = passive_handler["Drained"] ? src.AttackQueue.EnergyCost * (1 + passive_handler["Drained"]/10) : src.AttackQueue.EnergyCost
				src.LoseEnergy(drain)
			if(src.AttackQueue.ForceCost)
				src.LoseForce(src.AttackQueue.ForceCost)
			if(src.AttackQueue.FatigueCost)
				src.GainFatigue(src.AttackQueue.FatigueCost)
				
			if(src.AttackQueue.ManaGain)
				src.HealMana(AttackQueue.ManaGain)
			if(src.AttackQueue.ManaCost)
				var/drain = src.passive_handler.Get("MasterfulCasting") ? AttackQueue.ManaCost - (AttackQueue.ManaCost * (passive_handler.Get("MasterfulCasting") * 0.3)) : AttackQueue.ManaCost
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
							g.Activate(src)
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
						src.SetQueue(S)
						return
				else if(!src.AttackQueue.RanOut&&!src.AttackQueue.Missed&&src.AttackQueue.Hit)
					if(src.AttackQueue.HitStep)
						var/obj/Skills/Queue/S=new src.AttackQueue.HitStep
						S.adjust(src)
						src.AttackQueue=null
						src.SetQueue(S)
						return
				else if(!src.AttackQueue.RanOut&&(src.AttackQueue.Missed||src.AttackQueue.Hit))
					var/obj/Skills/Queue/S=new src.AttackQueue.Step
					src.AttackQueue=null//But this triggers either way so long as you didn't just run out of time.
					src.SetQueue(S)
					return
				src.AttackQueue=null


		QueueOverlayAdd()
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
			if(src.AttackQueue.IconLock)
				if(src.AttackQueue.IconLock!=1)
					if(src.AttackQueue.IconLockUnder)
						src.underlays-=image(icon=src.AttackQueue.IconLock, pixel_x=src.AttackQueue.LockX, pixel_y=src.AttackQueue.LockY)
					else
						src.overlays-=image(icon=src.AttackQueue.IconLock, pixel_x=src.AttackQueue.LockX, pixel_y=src.AttackQueue.LockY)
				else
					if(!src.AuraLocked&&!src.HasKiControl())
						src.Auraz("Remove")