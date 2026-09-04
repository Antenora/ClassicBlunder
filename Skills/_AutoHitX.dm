mob
	var
		tmp/AutoHitting//You can't autohit while you autohit.

obj
	Skills
		proc/disableInnovation(mob/p)
			var/list/current = p.client.getPref("disableInnovate")
			if(current[name])
				current[name] = !current[name]
			else
				current[name] = TRUE
			p.client.setPref("disableInnovate", current)
			p << "Your [name]'s innovation has been [current[name] ? "disable" : "enabled"]"
		proc/isInnovationDisable(mob/p)
			var/list/disabled_list = p.client.getPref("disableInnovate")
			if(disabled_list[name])
				return TRUE
			else
				return FALSE
		var/list/scalingValues = list()
		var/list/obj/Skills/possible_skills = list()
		proc/adjust(mob/p)
		AutoHit
			proc/Trigger(mob/p)
				adjust(p)
				if(Using || cooldown_remaining)
					return FALSE
				var/aaa = p.Activate(src, noGCD = TRUE)
				return aaa
			Distance=1//Unless otherwise stated, assume it's a one tile attack of varying style.
			var/DistanceAround //this is only used for AroundTarget type techs.
			var
				EndsGetsuga = 0
				UsesinForce = 0
				Cleansing = 0
				ManaDrain = 0
				HitSelf = 0
				Snaring
				SnaringOverlay
				NoPierce=0//If this is flagged it will make a technique terminate after hitting something.
				CorruptionGain = 0
				AngelMagicCompatible
				ApplyJudged
				ApplySentenced
				UnarmedOnly
				StanceNeeded
				ABuffNeeded
				SBuffNeeded
				GateNeeded
				FoxFire
				//ClassNeeded
				IgnoreAlreadyHit = FALSE
				Duration
				Persistent
				DamageMult=1//Damage on top of whatever stat calculations.
				FixedDamage=0//If set, target loses exactly this much HP (no formula, no modifiers).
				StepsDamage//Every step adds this value to damage mult.
				Knockback//Does the technique knockback?  If so, how far?
				while_warping = FALSE
				//
				HealthRecovery
				HealthRecoveryValue
				//Cooldown

				// Executing: scaling % damage increase per 1 Injury on the target
				Executing = 0

				//These four can be used in any combination.
				Area//variable to define what kind of hitzone to use.
				ChargeTech//Denotes if there is a charge
				ChargeTime//How much time it takes to move.
				ChargeFlight//superman tackle
				WindUp//Charge for this number of seconds.
				IgnoreWindUpReduction=0// keeps WindUp fixed and ignores reduction effects
				Slow//Makes it so that there is a pause in the movement of autohitters (The technique does not instantly hit all of its related tiles)
				Icon//Displays icon when used.
				IconX//Offsets.
				IconY
				IconZ
				Falling//should pixel_z animate towards 0?
				IconUnder=0
				Size//Makes icon bigger.
				ObjIcon//Makes autohit objects take on the appearance of the icon vars instead of the user.
				//These blend colors into the overlay
				IconRed=0
				IconGreen=0
				IconBlue=0


				Deluge//Makes water drown you
				Stasis//Makes you unable to do anything but can't be damaged.

				Rounds//Triggers multiple skillshots.
				RoundMovement=1//If this is 0, lock movement while using rounds.
				RecoveryLock=0
				DelayTime=1//time between attacks...
				NoLock//Doesn't lock autohitting.
				NoAttackLock

				Bang//defines if it causes an explosion on hit
				Bolt//shoot some lightning at motherfuckers
				BoltOffset //make lightning go scatter
				Erupt//spawns VFX below target erupting upward
				EruptOffset=0
				Scratch//scratch effects
				Punt//punch effects

				Divide//Great divide effect.
				TurfErupt//makes a boom
				TurfEruptOffset=0//affects the offset of booms
				TurfIce
				TurfIceOffset=0
				TurfFog
				TurfFogOffset=0
				TurfDirt//makes a boom
				TurfDirtOffset=0//affects the offset of dust
				TurfStrike
				TurfReplace//overlays this icon
				TurfShift//animates an image of another turf over existing
				TurfShiftLayer
				TurfShiftDuration=30
				TurfShiftDurationSpawn=10
				TurfShiftDurationDespawn=10
				TurfShiftState =""
				TurfShiftX = 0
				TurfShiftY = 0
				Flash//Taiyoken effect

				WindupIcon=0
				WindupIconSize=1
				WindupIconUnder=0
				WindupIconX=0
				WindupIconY=0
				WindupMessage//Text for when the tech is triggered but not executed yet.
				WindupColor=rgb(255, 153, 51)//Holds a hex value for color
				ActiveMessage//Text for using the tech.
				ActiveColor=rgb(255,0,0)//Holds a hex value for color

				HitSparkIcon//This holds the icon for a hitspark that will last as long as the autohit is being played out.
				HitSparkX=0
				HitSparkY=0
				HitSparkSize=1//The icon is scaled by this value.
				HitSparkTurns=0//Does it turn?  1 for yes, 0 for no.
				HitSparkCount=1
				HitSparkDispersion=8
				HitSparkDelay=1
				HitSparkLife=10

				FlickAttack//flicks the attack state.
				FlickSpin//flicks the KB state.
				Jump//jumps in the air
				Float//jumps in the air for a while longer

				PreShockwave//Does it happen before the attack?
				PreShockwaveDelay=0//Does it delay the attack itself?
				Shockwaves//How many rounds of shockwaves?
				Shockwave//How powerful of shockwaves? (reduces through numerous iterations)
				ShockIcon='fevKiai.dmi'//but you could make your own i guess...?
				ShockBlend=1//blend mode of shockwave
				ShockDiminish=2
				ShockTime=12
				PostShockwave=1//or after?

				Quaking//Makes the screen go shaka shaka.
				Earthshaking//as above but even if you miss
				PreQuake//gives people the jitters in windup

				//FocusShift
				var/FocusShifter
				var/FocusShiftType = "None"
				var/FocusShiftBoost = 1.5
				var/FocusShiftTimer = 10

				SpecialAttack=0//ignores all of the above
				Dunker
				Destroyer
				ComboMaster//Does not lose damage against stunned and / or launched people.
				GuardBreak//Can't be dodged, blocked or reversaled.
				CanBeDodged//AIS can trigger and avoid these
				CanBeBlocked//You can whiff on these techniques

				PassThrough//teleport to the last autohit position.
				PassTo//place an afterimage next to damaged parties
				StopAtTarget//Stop at target for passthrough

				Thunderstorm//Make thunderstorm FX; value holds the range. - TODO: Remove with a lengthy turfshift with some kind of delayed animation?
				Gravity//Gravity FX; value holds the range. - TODO: Rework a good deal, remove with TurfShifts where possible
				Ice//Ice FX; value holds the range. - TODO: Remove, replace as above
				Hurricane//lock someone in a wind tunnel
				HurricaneDelay=1

				Wander//At the end of the autohit's life, wander in random directions for this number of moves.
				Rush//Drives the user forward before deploying autohit.
				RushDelay=1
				ControlledRush//as above but you actually know where you're going
				RushAfterImages//Spawns coolerFlashImage afterimages each step during rush
				RushAIBlue
				RushAIOrange
				RushNoFlight//Skips setting icon_state to Flight during rush
				MortalBlow//Makes you deal a mortal wound in midcombat.
				WarpAway//Toss them into a hole

				RipplePower=1//Holds a value for ripple empowerment

				ExtendMemory//So people cannot cheese their spirit sword into unlimited distance

				//these fucks just old old fucks
				OldHitSpark
				OldHitSparkX
				OldHitSparkY
				OldHitSparkTurns
				OldHitSparkSize

				RagingDemonAnimation = FALSE
				Executor // increase damage by x*10% while the enemy is under 25%, increased by 2x when they are under 5%

				Primordial // deal x % more per 1 missing health

				SpeedStrike
				GrabMaster = FALSE

				PullIn

				GoldScatter

				DefTax
				OffTax

				NeedsHealth

				DirectWounds//Deals (this value) of wound % per hit.
				FrenzyDebuff

				KeepQueue = FALSE

			skillDescription()
				..()
				if(StrScaling)
					description += "Strength Damage %: [StrScaling*100]\n"
				if(ForScaling)
					description += "Force Damage %: [ForScaling*100]\n"
				if(EndEffectiveness<1)
					description += "Endurance Ignoring: [1-EndEffectiveness]%\n"
				if(DamageMult)
					description += "DamageMult: [DamageMult]\n"
				if(UnarmedOnly)
					description += "Unarmed Only.\n"
				if(Knockback)
					description += "Knockbacks [Knockback] tiles.\n"
				if(Area)
					description += "Hitbox Type: [Area]\n"
				if(WindUp)
					description += "Windup time: [WindUp] seconds.\n"
				if(Rounds)
					description += "Has [Rounds] rounds.\n"
				if(ComboMaster)
					description += "Ignores Stun/Launch damage loss.\n"
				if(GuardBreak)
					description += "Can't be dodged, whiff, or reversaled.\n"
				if(!CanBeDodged)
					description += "Can't be dodged.\n"
				if(!CanBeBlocked)
					description += "Can't whiff.\n"
				if(Rush)
					description += "Rushes forward [Rush] tiles"
				if(ControlledRush)
					description +=" in a controlled manner.\n"
				if(Rush&&!ControlledRush)
					description += ".\n"
				if(Executor)
					description += "Executor: [Executor] stacks."
				if(SpeedStrike)
					description += "Has [SpeedStrike] stacks of Speed Strike.\n"
				if(GrabMaster)
					description += "Doesn't lose damage from grabbing opponent while in use.\n"
				if(PullIn)
					description += "Pulls all people nearby in [PullIn] tiles.\n"
				if(FocusShifter)
					var/typeSelected
					var/autoSelectedType
					if(StrScaling > ForScaling)
						autoSelectedType = "FOR"
					else
						autoSelectedType = "STR"
					if(FocusShiftType != "None")
						typeSelected = FocusShiftType
					else
						typeSelected = autoSelectedType
					description += "Activates Focus Shift: [typeSelected] Autohits/Queue/Projectiles deal x[FocusShiftBoost] damage for [FocusShiftTimer] secs."
//NPC attacks
			Venom_Sting
				Area="Target"
				Distance=2
				DamageMult=1
				StrScaling=1
				EndEffectiveness=1
				Toxic=2
				ActiveMessage="lashes out with their venomous sting!"
				HitSparkIcon='Hit Effect Wind.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=2
				HitSparkTurns=0
				Cooldown=30

			Sticky_Spray
				Area="Wave"
				Distance=3
				ForScaling=1
				EndEffectiveness=1
				Crippling=2
				ActiveMessage="sprays some sticky silk!"
				Slow=0.5
				HitSparkIcon='Slash.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=1.5
				HitSparkTurns=1
				TurfStrike=4
				Cooldown=30

			Mush_Bonk
				Area="Wave"
				Distance=5
				StrScaling=1
				ForScaling=1
				EndEffectiveness=0.75
				DamageMult=5
				Shattering=10
				ActiveMessage="bonks their head on the ground to rupture it!"
				Slow=0.5
				HitSparkIcon='Hit Effect Wind.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=2
				HitSparkTurns=0
				TurfStrike=3
				Cooldown=30


//Auto^2hits

			Heavenly_Dragon_Violet_Ponds_Annihilation_of_the_Nine_Realms
				NoLock=1
				NoAttackLock=1
				DamageMult=2
				Area="Target"
				Distance=10
				TurfErupt=2
				TurfEruptOffset=3
				EndEffectiveness=0.75
				Knockback=10
				PassThrough=1
				ActiveMessage="blasts through their opponent with a destructive punch!"
				HitSparkIcon='Hit Effect Wind.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=3
				HitSparkTurns=0
				HitSparkLife=7
				Cooldown=4
				Earthshaking=15
			The_Heavenly_Demons_Fist_That_Cleaves_Through_Heaven_And_Divides_The_Sea
				Area="Around Target"
				NoLock=1
				NoAttackLock=1
				StrScaling=1
				DamageMult = T2_DMG_MULT / 2 / 10;
				Distance=5
				DistanceAround=4
				Rounds=10
				TurfErupt=1.25
				TurfEruptOffset=6
				IgnoreAlreadyHit=1
				ComboMaster=1
				Stunner=2
				Icon='Ki Fist Sprite.dmi'
				Size=3
				IconX=-30
				IconY=0
				Falling=1//animates towards pixel_z=0 while it is displayed
				ActiveMessage=""
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				Instinct=1
				Cooldown=4
				Earthshaking=45

			Chi_Punch
				UnarmedOnly=1
				Area="Circle"
				StrScaling=2
				Crushing=100
				EnergySteal=15
				DamageMult= T2_DMG_MULT / 2;
				ComboMaster=1
				TurfDirt=1
				Distance=5
				Knockback=10
				FlickAttack=1
				ShockIcon='KenShockwave.dmi'
				Shockwave=5
				Shockwaves=1
				PostShockwave=1
				PreShockwave=0
				Cooldown=4
				WindUp=0.01
				Earthshaking=20
				Instinct=1
				WindupMessage="channels Chi into their fist..."
				ActiveMessage="slams their fist into their enemy!"

			Explosive_Finish
				StrScaling=1
				ForScaling=1
				DamageMult = T2_DMG_MULT / 2;
				Area="Circle"
				Distance=4
				TurfErupt=2
				TurfEruptOffset=3
				Slow=1
				Knockback=10
				ActiveMessage="detonates the energy held within their weapon!"
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				Cooldown=4
				Earthshaking=15

			Cat_Claw_Rush
				Area="Arc"
				NoLock=1
				NoAttackLock=1
				Distance=1
				DamageMult = T2_DMG_MULT / 2 / 10;
				StrScaling=1
				EndEffectiveness=1
				Knockback=1
				Rounds=10
				ChargeTech=1
				ChargeTime=0.75
				ActiveMessage="chases their enemy down with raking cat claws!"
				HitSparkIcon='WolfFF.dmi'
				HitSparkX=0
				HitSparkY=0
				HitSparkTurns=1
				HitSparkDispersion=14
				HitSparkLife=7
				Cooldown=4
			Shatter_Shell
				Area="Target"
				NoLock=1
				NoAttackLock=1
				Distance=2
				DamageMult= T2_DMG_MULT / 2;
				StrScaling=1
				EndEffectiveness=1
				Knockback=10
				PassThrough=1
				ActiveMessage="blasts through their opponent with a destructive punch!"
				HitSparkIcon='Hit Effect Wind.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=3
				HitSparkTurns=0
				HitSparkLife=7
				Cooldown=4
			Blooming_Moon
				Area="Cross"
				NoLock=1
				NoAttackLock=1
				Distance=2
				Rounds=5
				Instinct=1
				DamageMult = T2_DMG_MULT / 2 / 5;
				StrScaling=1
				EndEffectiveness=1
				ActiveMessage="blossoms with a webwork of bladeplay!"
				HitSparkIcon='Slash - Zan.dmi'
				HitSparkX=-16
				HitSparkY=-16
				HitSparkSize=1
				HitSparkTurns=1
				HitSparkLife=7
				TurfStrike=3
				Cooldown=4
			Strongest_Fist
				Area="Wide Wave"
				NoLock=1
				NoAttackLock=1
				Distance=5
				DistanceAround=5
				DamageMult = T2_DMG_MULT / 2;
				StrScaling=1
				EndEffectiveness=1
				Knockback=10
				ActiveMessage="follows up with an enormously destructive punch!!"
				HitSparkIcon='Hit Effect Divine.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=3
				HitSparkTurns=0
				HitSparkLife=7
				TurfStrike=1
				TurfShift='Dirt1.dmi'
				TurfShiftDuration=30
				Cooldown=4
			Drunken_Crash
				NoLock=1
				NoAttackLock=1
				Area="Wave"
				StrScaling=1
				Distance=7
				DelayTime=7
				Rounds=7
				DamageMult = T2_DMG_MULT / 2 / 7;
				PassThrough=1
				GuardBreak=1
				ActiveMessage="begins to stumble through the battlefield like a drunken hobo!"
				HitSparkIcon='Hit Effect Oath.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=0
				HitSparkSize=1
				HitSparkCount=2
				HitSparkDispersion=16
				TurfStrike=1
				Instinct=1
				Cooldown=4
			Galaxy_Clothesline
				NoLock=1
				NoAttackLock=1
				Area="Circle"
				StrScaling=1
				Distance=7
				Rounds=7
				DamageMult = T2_DMG_MULT / 2 / 7;
				ChargeTech=1
				ChargeTime=0.5
				Knockback=1
				GuardBreak=1
				ActiveMessage="crashes through all in their path with a galactic clothesline!"
				HitSparkIcon='Hit Effect Oath.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=0
				HitSparkSize=1
				HitSparkCount=2
				HitSparkDispersion=16
				TurfStrike=1
				Instinct=1
				Cooldown=4
			Blitz_Rush
				Area="Circle"
				NoLock=1
				NoAttackLock=1
				RoundMovement=1
				Distance=2
				DamageMult= T2_DMG_MULT / 2 / 10;
				Rounds=10
				StrScaling=0.5
				ForScaling=0.5
				EndEffectiveness=1
				Paralyzing=5
				ActiveMessage="continues their momentum with a rush of strikes!!"
				HitSparkIcon='Hit Effect Oath.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=3
				HitSparkTurns=0
				HitSparkLife=7
				Cooldown=4
			Divide_Effect
				Area="Arc"
				NoLock=1
				NoAttackLock=1
				Distance=5
				Instinct=1
				DamageMult = T2_DMG_MULT / 2;
				StrScaling=1
				EndEffectiveness=0.75
				ActiveMessage="ruptures the ground with their mega-powerful slash!"
				HitSparkIcon='Slash.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=1
				HitSparkTurns=1
				HitSparkLife=7
				HitSparkSize=3
				TurfStrike=3
				TurfShift='Dirt1.dmi'
				TurfShiftDuration=30
				Cooldown=4
			Comet_Spear
				Area="Arc"
				NoLock=1
				NoAttackLock=1
				RoundMovement=0
				Distance=8
				Instinct=4
				DamageMult= T2_DMG_MULT / 2 / 2;
				Rounds=2
				StrScaling=1
				EndEffectiveness=0.75
				TurfErupt=2
				TurfEruptOffset=3
				Earthshaking = 15
				ActiveMessage="unleashes a swing of pure strength forward!"
				HitSparkIcon='Slash - Zan.dmi'
				HitSparkX=-16
				HitSparkY=-16
				HitSparkSize=1
				HitSparkTurns=1
				HitSparkLife=10
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				Cooldown=4

			Flowing_Slash_Follow_Up
				Area="Strike"
				NoLock=1
				NoAttackLock=1
				Distance=10
				Instinct=4
				Size=2
				DamageMult= T2_DMG_MULT / 2;
				StrScaling=1
				EndEffectiveness=1
				ActiveMessage="lashes out with an elegant singular strike!"
				HitSparkIcon='Slash - Zan.dmi'
				HitSparkX=-16
				HitSparkY=-16
				HitSparkSize=1
				HitSparkTurns=0
				HitSparkLife=7
				HitSparkSize=3
				TurfStrike=1
				TurfShift='Dirt1.dmi'
				TurfShiftDuration=30
				Cooldown=4
			Whirlwind_Handstand
				Area="Circle"
				NoLock=1
				NoAttackLock=1
				RoundMovement=0
				Distance=1
				Instinct=4
				DamageMult = T2_DMG_MULT / 2 / 3;
				Rounds=3
				ComboMaster = 1
				StrScaling=1
				EndEffectiveness=1
				WindUp=0.5
				CanBeDodged=0
				WindupMessage="sets themselves into a handstand..."
				ActiveMessage="lets their legs rip like a top!!"
				HitSparkIcon='Slash - Zan.dmi'
				HitSparkX=-16
				HitSparkY=-16
				HitSparkSize=1
				HitSparkTurns=1
				HitSparkLife=10
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				Cooldown=4
			Stop_Effect
				Area="Around Target"
				NoLock=1
				NoAttackLock=1
				Distance=15
				DistanceAround=5
				Stunner=5
				DamageMult= T2_DMG_MULT / 2;
				StrScaling=0
				ForScaling=1
				GuardBreak=1
				SpecialAttack=1
				Crippling=5
				HitSparkIcon='Magic Time circle.dmi'
				HitSparkX=0
				HitSparkY=0
				HitSparkDispersion=0
				TurfShift='Gravity.dmi'
				TurfShiftLayer=MOB_LAYER+1
				TurfShiftDuration=0
				TurfShiftDurationSpawn=3
				TurfShiftDurationDespawn=7
				Cooldown=4
				Instinct=1
			Dark_Blast
				Area="Around Target"
				NoLock=1
				NoAttackLock=1
				Distance=5
				DistanceAround=4
				Knockback=15
				DamageMult= T2_DMG_MULT / 2;
				StrScaling=1
				ForScaling=1
				GuardBreak=1
				SpecialAttack=1
				Crippling=5
				TurfShift='Gravity.dmi'
				TurfShiftLayer=MOB_LAYER+1
				TurfShiftDuration=0
				TurfShiftDurationSpawn=3
				TurfShiftDurationDespawn=7
				Cooldown=4
				Instinct=1
			Soul_Blast
				Area="Around Target"
				NoLock=1
				NoAttackLock=1
				Distance=5
				DistanceAround=4
				Knockback=15
				DamageMult = T2_DMG_MULT / 2;
				StrScaling=1
				ForScaling=1
				GuardBreak=1
				SpecialAttack=1
				Crippling=5
				TurfShift='Gravity.dmi'
				TurfShiftLayer=MOB_LAYER+1
				TurfShiftDuration=0
				TurfShiftDurationSpawn=3
				TurfShiftDurationDespawn=7
				Cooldown=4
				Instinct=1
			Clothesline_Effect
				Area="Circle"
				StrScaling=1
				DamageMult= T2_DMG_MULT / 2 / 10;
				Rounds=10
				ChargeTech=1
				ChargeTime=1
				Knockback=1
				Cooldown=4
				Size=1
				Instinct=1
			Dancing_Blade_Effect
				Area="Circle"
				StrScaling=1
				DamageMult = T2_DMG_MULT / 2 / 15;
				Rounds=15
				RoundMovement=1
				Size=2
				Distance=2
				Instinct=1
				Icon='MagicWish.dmi'
				IconX=-8
				IconY=-8
				HitSparkIcon='Hit Effect Divine.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=0.5
				HitSparkTurns=0
				Cooldown=4
				Instinct=1
			Tatsumaki_Effect
				UnarmedOnly=1
				NoLock=1
				NoAttackLock=1
				Area="Circle"
				StrScaling=1
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				Size=1
				DamageMult = T2_DMG_MULT / 2 / 10;
				ManaCost=0
				Rounds=10
				ChargeTech=1
				ChargeTime=0.75
				ActiveMessage="lifts themselves into the air with the speed of endless rapid kicks!"
				Cooldown=4
				Instinct=1
			Knockoff_Wave
				Area="Circle"
				SpecialAttack=1
				GuardBreak=1
				StrScaling=0.5
				ForScaling=0.5
				DamageMult = T2_DMG_MULT;
				Distance=2
				Launcher=1
				NoAttackLock=1
				NoLock=1
				Cooldown=4
////Keyblade
			FeverPitch
				Area="Arc"
				NoLock=1
				StrScaling=1
				DamageMult = T2_DMG_MULT / 2;
				Distance=5
				Instinct=1
				TurfStrike=1
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=2
				HitSparkTurns=0
				ActiveMessage="swings their blade, sending out an arc of energy!"
				Cooldown=4
				NoAttackLock=1
				NoLock=1
			FatalMode
				Area="Circle"
				StrScaling=1
				DamageMult= T2_DMG_MULT / 2 / 5;
				Rounds=5
				Distance=5
				Slow=1
				FlickAttack=1
				Instinct=1
				ComboMaster=1
				ShockIcon='KenShockwaveGold.dmi'
				Shockwave=4
				Shockwaves=1
				PostShockwave=0
				PreShockwave=1
				HitSparkIcon='Hit Effect Ripple.dmi'
				ActiveMessage="slams their blade into the ground!"
				Cooldown=4
				NoAttackLock=1
				NoLock=1
			MagicWish
				Area="Circle"
				ForScaling=1
				DamageMult= T2_DMG_MULT / 2 / 15;
				Rounds=15
				RoundMovement=1
				Size=2
				Distance=2
				Instinct=1
				Icon='MagicWish.dmi'
				IconX=-8
				IconY=-8
				HitSparkIcon='Hit Effect Divine.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=0.5
				HitSparkTurns=0
				ActiveMessage="spins in a dance-like fashion!"
				Cooldown=4
				NoAttackLock=1
				NoLock=1
			CycloneCharge
				Area="Circle"
				Distance=1
				DamageMult = T2_DMG_MULT / 2 / 25;
				Knockback=1
				Rounds=25
				StrScaling=1
				ChargeTech=1
				ChargeTime=1
				Instinct=1
				Icon='Tornado.dmi'
				IconX=-8
				IconY=-8
				ActiveMessage="bursts forward while spinning rapidly!"
				//Doesn't get a verb because it is cast from melee.
				NoAttackLock=1
				NoLock=1
				Cooldown=4

			Atomic_Crush
				Area="Circle"
				StrScaling=1
				ForScaling=1
				NoLock=1
				NoAttackLock=1
				DamageMult = T2_DMG_MULT / 2;
				Distance=7
				Instinct=2
				Jump=2
				GuardBreak=1
				ActiveMessage="follows up with an atom-splitting high kick!"
				Slow=0.5
				HitSparkIcon='fevExplosion - Susanoo.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=0
				Cooldown=4

			Tensho_Juji_Ho
				Area="Wave"
				StrScaling=1
				ForScaling=1
				NoAttackLock=1
				ComboMaster=1
				DamageMult = T2_DMG_MULT / 2;
				Distance=6
				Flash=1
				Rush=15
				Instinct=2
				ControlledRush=0
				WindUp=0.5
				ShockIcon='KenShockwaveGold.dmi'
				Shockwave=4
				Shockwaves=1
				PostShockwave=0
				PreShockwave=1
				WindupIcon='Ripple Radiance.dmi'
				WindupIconUnder=1
				WindupIconX=-32
				WindupIconY=-32
				WindupIconSize=1
				GuardBreak=1
				PassThrough=1
				Knockback=0
				ActiveMessage="launches into a powerful aerial attack and glides through their opponents defenses!"
				HitSparkIcon='Slash.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkCount=10
				HitSparkTurns=1
				HitSparkDispersion=16
				HitSparkDelay=1
				Cooldown=4

			WingbladeFlash
				Area="Circle"
				StrScaling=1
				ForScaling=1
				EndEffectiveness=0.5
				DamageMult = T2_DMG_MULT / 2;
				Jump=2
				Knockback=5
				Distance=4
				Flash=3
				SpecialAttack=1
				Instinct=1
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				TurfShift='BrightDay2.dmi'
				TurfShiftLayer=EFFECTS_LAYER
				TurfShiftDuration=-10
				TurfShiftDurationSpawn=0
				TurfShiftDurationDespawn=5
				ActiveMessage="stabs their light blades into the ground, causing them to erupt into a bright flash!"
				NoAttackLock=1
				NoLock=1
				Cooldown=4
				//Doesn't get a verb because it is cast from melee.
				Cooldown=4
			BladeChargeRave
				Area="Circle"
				NeedsSword=1
				StrScaling=1
				ForScaling=1
				RoundMovement=1
				DamageMult = T2_DMG_MULT / 2 / 20;
				Rounds=20
				WindUp=0.5
				WindupMessage="engorges their energy blade with a massive amount of magic!"
				Size=2
				Distance=2
				Instinct=1
				Icon='BladeCharge.dmi'
				IconX=-32
				IconY=-32
				HitSparkIcon='Slash - Zero.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=1.5
				HitSparkTurns=1
				ActiveMessage="tears through their surroundings with a series of reckless swings!"
				//Doesn't get a verb because it is cast from melee.
				Cooldown=4

////Vampirism
			CallBlood
				Distance=10
				WindupMessage="reaches out to the blood in their prey's body..."
				DamageMult=1
				StrScaling=1
				ForScaling=1
				ActiveMessage="rips the blood right out of their enemy's body!"
				Area="Target"
				GuardBreak=1
				//No longer has verb because is set by reverse dash
			Shadow_Tendril_Strike
				Distance=10
				Knockback=1
				Slow=1
				Area="Target"
				ActiveMessage="bursts out with tendrils of shadow!"
				DamageMult=0.5
				TurfStrike=3
				HitSparkIcon='Slash - Vampire.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=1
				HitSparkTurns=1
				New(mob/p )
					if(p)
						DamageMult = 2.5 + (0.5 * p.AscensionsAcquired)
					. = ..()

			Shadow_Tendril_Wave
				Distance=10
				Knockback=1
				Slow=1
				Area="Wave"
				ActiveMessage="bursts out with tendrils of shadow!"
				StrScaling=0
				ForScaling=1
				DamageMult=1.5
				GuardBreak=1
				TurfStrike=3
				HitSparkIcon='Slash - Vampire.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=1
				HitSparkTurns=1
				//no verb because is set by throw

			Symbiote_Tendril_Wave
				Distance=10
				Knockback=5
				Slow=10
				Area="Wave"
				ActiveMessage="bursts out with tendrils of symbiotic matter!"
				StrScaling = 1
				Cooldown = 60
				DamageMult= 7
				GuardBreak=1
				TurfStrike=3
				HitSparkIcon='Slash - Vampire.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=1
				HitSparkTurns=1
				verb/Symbiote_Tendril_Wave()
					set category = "Skills"
					usr.Activate(src)

			Myriad_Truths
				Area="Circle"
				ComboMaster=1
				Distance=4
				StrScaling=1
				DamageMult=5.5
				Cooldown=120
				Knockback=20
				Size=1
				HitSparkIcon='BLANK.dmi'
				Bolt = 2
				Paralyzing=4
				HitSparkX=0
				HitSparkY=0
				Shockwaves=3
				Shockwave=1
				EnergyCost=3
				SpecialAttack=1
				Earthshaking=15
				ActiveMessage="reveals the truth of the world!"
				verb/Myriad_Truths()
					set category="Skills"
					usr.Activate(src)
			Devils_Advocate
				NoAttackLock=1
				Area="Wave"
				Distance=7
				StrScaling=1
				Knockback=1
				HitSparkIcon='BLANK.dmi'
				Slow=4
				DamageMult=4
				ObjIcon=1
				Icon='SekiZou.dmi'
				IconX=-48
				IconY=-48
				Size=1
				Stunner = 2
				Cooldown = 60
				verb/Devils_Advocate()
					set name = "Devil's Advocate"
					set category="Skills"
					usr.Activate(src)
////Lycanthropia
			Howl
				Area="Circle"
				Distance=15
				StrScaling=0
				ForScaling=1
				DamageMult=0
				Shockwaves=4
				Shockwave=5
				PreShockwave=1
				PostShockwave=0
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				Stunner=2
				Crippling=15
				ShockIcon='DarkKiai.dmi'
				ActiveMessage="unleashes a terrifying howl!"
			Attractive_Force
				Area="Circle"
				Distance=15
				StrScaling=1
				DamageMult=0.5
				Shockwaves=4
				Shockwave=5
				PreShockwave=1
				PostShockwave=0
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				PullIn = 5
				Crippling=7
				ShockIcon='DarkKiai.dmi'
				ActiveMessage="'s unnatural presence forces the world to pull closer!"
//No Verbs
			AirSmash
				NoAttackLock=1
				Area="Wave"
				Distance=5
				StrScaling=1
				Knockback=1
				HitSparkIcon='BLANK.dmi'
				Slow=1
				DamageMult=2
				ObjIcon=1
				Icon='SekiZou.dmi'
				IconX=-48
				IconY=-48
				Size=1
//Racial
			AntennaBeam
				Area="Strike"
				ForScaling=1
				DamageMult=1
				GuardBreak=1
				Stunner=2
				Distance=3
				Knockback=0
				Size=6
				Icon='Antenna Beam.dmi'
				HitSparkIcon='BLANK.dmi'
				Cooldown=150
				ActiveMessage="shoots out crackling energy from their antennas!!!"
				verb/Antenna_Beam()
					set category="Skills"
					usr.Activate(src)

//Skill Tree

////UNARMED
//T1 is in Queues.

//T2 has damage mult 2.5 - 3.5
			Focus_Punch
				SkillCost=80
				Copyable=2
				UnarmedOnly=1
				FlickAttack=1
				Area="Strike"
				ComboMaster=1
				Distance=1
				StrScaling=1
				DamageMult=4
				Cooldown=60
				EnergyCost=2
				Knockback=15
				PreShockwave=1
				PreShockwaveDelay=2
				PostShockwave=0
				Shockwaves=2
				Shockwave=0.5
				ShockIcon='KenShockwaveFocus.dmi'
				ShockBlend=2
				ShockDiminish=1.15
				ShockTime=4
				Earthshaking=10
				Instinct=1
				ActiveMessage="focuses their entire power into a devastating strike!"
				verb/Focus_Punch()
					set category="Skills"
					usr.Activate(src)
			Lightning_Kicks
				NewCost = TIER_3_COST
				NewCopyable = 4
				SkillCost=80
				Copyable=3
				AlwaysAnnounceCooldown = 1
				UnarmedOnly=1
				Area="Arc"
				StrScaling=1
				DamageMult=1.7
				Rush=5
				ControlledRush=0
				Rounds=3
				ComboMaster=1
				RoundMovement=0
				NoAttackLock=1
				NoLock=1
				MenuIcon="LightningKick"
				Cooldown=12
				Icon='Nest Slash.dmi'
				IconX=-16
				IconY=-16
				Size=2
				Distance=2
				EnergyCost=3
				Launcher=2
				Instinct=1
				ActiveMessage="delivers a series of flowing kicks!"
				TurfStrike=1
				TurfShift='Dirt1.dmi'
				TurfShiftDuration=3
				DelayTime=3
				MashExtend=1
				adjust(mob/p)
				verb/Lightning_Kicks()
					set category="Skills"
					if(src.flurry_live > world.time)
						var/mob/ext = usr
						var/ecost = src.mash_extends + 1
						if(ext.Energy < ecost)
							ext << "<font color='red'>You're too drained to keep the flurry going!</font>"
							return
						ext.LoseEnergy(ecost)
						ext.GainFatigue(ecost)
						src.mash_extends++
						src.mash_pending++
						return
					var/can_fire = !(Using || cooldown_remaining)
					if(!altered)
						if(usr.isInnovative(HUMAN, "Unarmed"))
							if(!isInnovationDisable(usr))
								if(!Using && usr.Energy >= 5)
									if(!locate(/obj/Skills/Projectile/Kick_Blast, usr))
										usr.AddSkill(new/obj/Skills/Projectile/Kick_Blast)
									var/obj/Skills/Projectile/Kick_Blast/kb = usr.FindSkill(/obj/Skills/Projectile/Kick_Blast)
									kb.adjust(usr)
									usr.UseProjectile(kb)
								else
									return
						else if(usr.isInnovative(CELESTIAL, "Any") && !isInnovationDisable(usr))
							can_fire = !(Using || cooldown_remaining)
							if(usr.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/DarkMagic) && can_fire && usr.Energy >= 5)
								if(!locate(/obj/Skills/Projectile/Magic/DarkMagic/Abyssal_Sphere) in usr)
									usr.AddSkill(new/obj/Skills/Projectile/Magic/DarkMagic/Abyssal_Sphere)
								var/obj/Skills/Projectile/Magic/DarkMagic/Abyssal_Sphere/ap = usr.FindSkill(/obj/Skills/Projectile/Magic/DarkMagic/Abyssal_Sphere)
								ap.adjust(usr)
								usr.UseProjectile(ap)
							if(usr.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/Corruption) && can_fire)
								src.CorruptionDebuff = 1
							else
								src.CorruptionDebuff = 0
					usr.Activate(src)
					applyDemonInnovationEffect(usr, can_fire)
				verb/Disable_Innovate()
					set category = "Other"
					set hidden = 1
					disableInnovation(usr)
			Flying_Kick
				NewCost = TIER_3_COST
				NewCopyable = 4
				SkillCost=80
				Copyable=3
				UnarmedOnly=1
				Area="Arc"
				Distance=2
				StrScaling=1
				Rush=8
				Jump=1
				ControlledRush=0
				RushBounce=1
				DamageMult=5.0
				MenuIcon="FlyingKick"
				Knockback=1
				Icon='Nest Slash.dmi'
				IconX=-16
				IconY=-16
				Size=2
				Cooldown=12
				EnergyCost=3
				ActiveMessage="goes flying through the air to deliver a graceful kick!"
				TurfStrike=1
				TurfShift='Dirt1.dmi'
				TurfShiftDuration=3
				verb/Flying_Kick()
					set category="Skills"
					usr.Activate(src)

//T3 is in Grapples.

//T4 has damage mult 4 - 6.
			Clothesline
				SkillCost=TIER_4_COST
				Copyable=4
				UnarmedOnly=1
				Area="Circle"
				StrScaling=1
				DamageMult=1
				Rounds=10
				ChargeTech=1
				ChargeTime=1
				Knockback=1
				Cooldown=60
				Size=1
				EnergyCost=1
				Instinct=1
				ActiveMessage="charges forward with their arm held out!"
				verb/Clothesline()
					set category="Skills"
					usr.Activate(src)
			Spinning_Clothesline
				Size = 4
				SkillCost=TIER_4_COST
				Copyable=5
				AlwaysAnnounceCooldown = 1
				UnarmedOnly=1
				MenuIcon="SpinningClothesline"
				Area="Circle"
				ComboMaster=1
				StrScaling=1
				DamageMult=0.35
				Rounds=20
				RoundMovement=0
				RushProjImmune=20
				Launcher=2
				Cooldown=18
				Size=2
				Icon='Tornado.dmi'
				IconX=-8
				IconY=-8
				EnergyCost=5
				Instinct=1
				ActiveMessage="spins like a top, crushing anyone caught in their range!"
				TurfShift='Dirt1.dmi'
				TurfShiftDuration=3
				adjust(mob/p)
					if(p.isInnovative(HUMAN, "Unarmed") && !isInnovationDisable(p))
						Rounds= 10
						DamageMult = (1 + (p.Potential/100)) * 0.64
						PullIn = 6
						Shearing = 0
						TurfShift = 0
						TurfShiftDuration = 0
					else if(p.isInnovative(CELESTIAL, "Any") && !isInnovationDisable(p) && p.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/DarkMagic))
						Rounds = 10
						DamageMult = (1 + (p.Potential/100)) * 0.64
						PullIn = 6
						Shearing = 2 + (p.Potential/20)
						TurfShift = 'blackflameaura.dmi'
						TurfShiftDuration = 3
					else
						Size = 2
						Rounds= 20
						DamageMult = 0.35
						PullIn = 0
						Shearing = 0
						TurfShift = 0
						TurfShiftDuration = 0
					if(p.isInnovative(CELESTIAL, "Any") && !isInnovationDisable(p) && p.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/Corruption))
						CorruptionDebuff = 1
					else
						CorruptionDebuff = 0
				verb/Spinning_Clothesline()
					set category="Skills"
					var/can_fire = !(Using || cooldown_remaining)
					usr.Activate(src)
					applyDemonInnovationEffect(usr, can_fire)
				verb/Disable_Innovate()
					set category = "Other"
					set hidden = 1
					disableInnovation(usr)
			Bullrush
				RushCarry=1
				SkillCost=TIER_4_COST
				Copyable=5
				UnarmedOnly=1
				Area="Circle"
				StrScaling=1
				DamageMult=0.55
				ComboMaster = 1
				GrabMaster = 1
				Grapple=1
				Rounds=11
				ChargeTech=1
				ChargeTime=1
				Knockback=1
				MenuIcon="Bullrush"
				Cooldown=18
				WindUp=0.25
				WindupMessage="lowers their head..."
				Size=1
				EnergyCost=5
				ActiveMessage="charges forward, plowing through everyone in their path!"
				TurfStrike=1
				TurfShift='Dirt1.dmi'
				TurfShiftDuration=3
				verb/Bullrush()
					set category="Skills"
					usr.Activate(src)
			Hyper_Crash
				SkillCost=TIER_4_COST
				Copyable=5
				AlwaysAnnounceCooldown = 1
				Area="Wide Wave"
				UnarmedOnly = 1
				StrScaling=1
				Distance=10
				MenuIcon="HyperCrash"
				Knockback=10
				PassThrough=1
				PreShockwave=1
				PostShockwave=0
				Shockwave=2
				Shockwaves=2
				DamageMult=6.75
				WindUp=0.1
				WindupMessage="crouches into a starting position..."
				ActiveMessage="blasts forward with a super-sonic dash!"
				TurfStrike=1
				TurfShift='Dirt1.dmi'
				TurfShiftDuration=3
				Cooldown=18
				EnergyCost=5
				adjust(mob/p)
					if(p.isInnovative(HUMAN, "Unarmed") && !isInnovationDisable(p))
						Area="Around Target"
						NoLock=1
						NoAttackLock=1
						StrScaling=1
						DamageMult=(1 + p.Potential/200) * 0.61
						Distance=5
						DistanceAround=4
						Rounds=4
						TurfErupt=1.25
						TurfEruptOffset=6
						TurfShift=0
						TurfShiftDuration=0
						IgnoreAlreadyHit=1
						ComboMaster=1
						Launcher=3
						Icon='Ki Fist Sprite.dmi'
						Size=3
						IconX=-30
						IconY=0
						Falling=1//animates towards pixel_z=0 while it is displayed
						HitSparkIcon='BLANK.dmi'
						WindUp=0
						HitSparkX=0
						HitSparkY=0
						Instinct=1
						Earthshaking=25
						Shearing=0
					else if(p.isInnovative(CELESTIAL, "Any") && !isInnovationDisable(p) && p.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/DarkMagic))
						Area="Around Target"
						NoLock=1
						NoAttackLock=1
						StrScaling=1
						DamageMult=(1 + p.Potential/200) * 0.61
						Distance=5
						DistanceAround=4
						Rounds=4
						TurfErupt=1.25
						TurfEruptOffset=6
						TurfShift='blackflameaura.dmi'
						TurfShiftDuration=3
						IgnoreAlreadyHit=1
						ComboMaster=1
						Launcher=3
						Icon='Ki Fist Sprite.dmi'
						Size=3
						IconX=-30
						IconY=0
						Falling=1//animates towards pixel_z=0 while it is displayed
						HitSparkIcon='Hit Effect Dark.dmi'
						WindUp=0
						HitSparkX=-32
						HitSparkY=-32
						Instinct=1
						Earthshaking=25
						Shearing=3 + round(p.Potential/30)
					else
						Area="Wide Wave"
						NoLock=0
						NoAttackLock=0
						StrScaling=1
						DamageMult=6.75
						Distance=10
						DistanceAround=0
						Rounds=0
						TurfErupt=0
						TurfEruptOffset=0
						TurfShift=0
						TurfShiftDuration=0
						IgnoreAlreadyHit=0
						ComboMaster=0
						Launcher=0
						Icon=null
						Size=initial(Size)
						IconX=0
						IconY=0
						Falling=1//animates towards pixel_z=0 while it is displayed
						HitSparkIcon=null
						WindUp=0
						HitSparkX=0
						HitSparkY=0
						Instinct=0
						Earthshaking=0
						Shearing=0
					if(p.isInnovative(CELESTIAL, "Any") && !isInnovationDisable(p) && p.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/Corruption))
						CorruptionDebuff = 1
					else
						CorruptionDebuff = 0
				verb/Hyper_Crash()
					set category="Skills"
					var/can_fire = !(Using || cooldown_remaining)
					usr.Activate(src)
					applyDemonInnovationEffect(usr, can_fire)
				verb/Disable_Innovate()
					set category = "Other"
					set hidden = 1
					disableInnovation(usr)
			Dropkick_Surprise
				SkillCost=TIER_4_COST
				UnarmedOnly = 1
				Copyable=5
				Area="Target"
				StrScaling=1
				MenuIcon="DropkickSurprise"
				Distance=5
				PassThrough=1
				DamageMult=7.5
				Knockback=5
				Jump=1
				WindUp=0.25
				WindupMessage="leaps into the air!"
				ActiveMessage="crashes into their opponent with a dropkick!"
				TurfStrike=1
				TurfShift='Dirt1.dmi'
				TurfShiftDuration=3
				Cooldown=18
				EnergyCost=5
				NoGCD=1
				NoAttackLock=1
				verb/Dropkick_Surprise()
					set category="Skills"
					if(!usr.is_dashing)
						usr << "<font color='red'>You can only use [src] while moving at speed!</font>"
						return
					usr.Activate(src)

//T5 (Sig 1) has damage mult 5, usually

			Cast_Fist
				SignatureTechnique=1
				UnarmedOnly=1
				Area="Circle"
				StrScaling=1
				DamageMult=4
				MenuIcon="CastFist"
				TurfDirt=1
				TurfShift='Dirt1.dmi'
				TurfShiftDuration=40
				Distance=8
				//Size=3
				Knockback=10
				ShockIcon='KenShockwave.dmi'
				Shockwave=5
				Shockwaves=1
				PassThrough=1
				Launcher=5
				PostShockwave=1
				PreShockwave=0
				//BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Muscle_Expand"
				//FollowUp="/obj/Skills/Queue/Warping_Fist"
				//FollowUpDelay=2
				Cooldown=12
				EnergyCost=3
				WindUp=1
				Earthshaking=20
				Instinct=1
				WindupMessage="rises their fist, ready to cast a spell..."
				ActiveMessage="punches the ground!"
				verb/Cast_Fist()
					set category="Skills"
					if(usr.Activate(src) && src.Using)
						var/mob/caster = usr
						spawn(10)
							if(!caster || !caster.loc)
								return
							var/turf/epi = get_turf(caster)
							if(epi)
								for(var/turf/t in Turf_Circle(epi, src.Distance))
									if(!t.density)
										new /obj/leftOver/MudField(t, caster)
									CHECK_TICK

			Wolf_Fang_Fist
				SignatureTechnique=1
				UnarmedOnly=1
				Area="Circle"
				StrScaling=1
				WoundRider=0.1
				DamageMult=0.5
				IgnoreAlreadyHit=TRUE
				Rounds=10
				MenuIcon="WolfFangFist"
				Stunner=0.5
				Launcher=2
				ComboMaster=1
				ChargeTech=1
				GrabMaster = 1
				ChargeTime=1.5
				Grapple=1
				Cooldown=12
				// Size=1
				EnergyCost=3
				TurfShift='Dirt1.dmi'
				TurfShiftDurationSpawn = 1
				TurfShiftDuration = 5
				TurfShiftDurationDespawn = 4
				ActiveMessage="rushes while attacking with the ferocity of a wolf!"
				HitSparkIcon='WolfFF.dmi'
				HitSparkX=0
				HitSparkY=0
				HitSparkTurns=1
				HitSparkDispersion=14
				HitSparkLife=7
				Instinct=1
				verb/Wolf_Fang_Fist()
					set category="Skills"
					usr.Activate(src)

			Nova_Strike
				SignatureTechnique=1
				UnarmedOnly=1
				Area="Circle"
				DamageMult=0.45
				ComboMaster=1
				MenuIcon="NovaStrike"
				Rounds=10
				ChargeTech=1
				ChargeFlight=1
				ChargeTime=0.75
				Grapple=1
				Stunner=0.5
				Launcher=1
				GrabMaster=1
				RushProjImmune=8
				Cooldown=12
				Size=1
				EnergyCost=3
				Icon='Novabolt.dmi'
				IconX=-33
				IconY=-33
				Instinct=1
				ActiveMessage="blasts forward surrounded by a veil of energy!"
				verb/Nova_Strike()
					set category="Skills"
					usr.Activate(src)

			One_Inch_Punch
				SignatureTechnique=1
				UnarmedOnly=1
				FlickAttack=1
				Area="Arc"
				StrScaling=2
				DamageMult=6.25
				GuardBreak=1
				ComboMaster=1

				NoGCD = 1

				RushDelay=0.1
				ControlledRush=0
				Knockback=0
				MenuIcon="OneInchPunch"
				Earthshaking=15
				PreShockwave=1
				PreShockwaveDelay=1
				PostShockwave=1
				Shockwaves=4
				Shockwave=0.5
				ShockIcon='KenShockwaveFocus.dmi'
				ShockBlend=2
				ShockDiminish=1.15
				ShockTime=4
				WindUp=0
				WindupMessage="extends their arm towards the opponent, reaching them with the tips of their fingers..."
				ActiveMessage="curls up their fingers into a fist and delivers a crushing blow!!!"
				EnergyCost=4
				Cooldown=15
				verb/One_Inch_Punch()
					set category="Skills"
					if(!usr.Target || get_dist(usr, usr.Target) > 1)
						usr << "<font color='red'>You must be adjacent to your target.</font>"
						return
					usr.Activate(src)

//T6 (Sig 2) has damage mult 7.5, usually

			Lariat
				SignatureTechnique=2
				Area="Circle"
				DamageMult=1.75
				Rounds=10
				ComboMaster=1
				ChargeTech=1
				MenuIcon="Lariat"
				ChargeTime=0.5
				Grapple=1
				GrabMaster = 1
				Stunner=1
				RushCarry=1
				Cooldown=45
				Size=2
				EnergyCost=10
				// GuardBreak=1
				SpecialAttack=1
				Rush=5
				ControlledRush=0
				Instinct=1
				Icon='Glowing Electricity.dmi'
				ActiveMessage="is covered in lightning as they charge forward!"
				verb/Lariat()
					set category="Skills"
					usr.Activate(src)

			Hyper_Tornado
				SignatureTechnique=2
				Area="Wave"
				StrScaling=1
				ForScaling=1
				DamageMult=13.25
				ComboMaster=1
				ControlledRush=0
				Rush=7
				MenuIcon="HyperTornado"
				Instinct=2
				Knockback=15
				Cooldown=45
				HitSparkIcon='Hit Effect.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=0.8
				HitSparkCount=20
				HitSparkDispersion=24
				HitSparkDelay=1
				Hurricane="/obj/Skills/Projectile/Tornado"
				HurricaneDelay=0.1
				EnergyCost=10
				WindUp=0.25
				GuardBreak=1
				Instinct=1
				WindupMessage="spins rapidly, invoking a tornado that whisks their target!"
				ActiveMessage="bursts forward to deliver a storm of rapid strikes!!"
				verb/Hyper_Tornado()
					set category="Skills"
					usr.Activate(src)

//T7 is always a style or a special buff.


////UNIVERSAL
//T1 is in Projectiles

//T2 has damage mult 2 - 3.5. Some are in Queues.
			Warp_Storm
				Area="Circle"
				Distance=2
				SpecialAttack=1
				ComboMaster=1
				Rounds=5
				DamageMult=0.1//1 damage mult is from the projectile itself.
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				HitSparkIcon='Slash - Zero.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				RoundMovement=0
				//This is set from Warp Strike.
			Warp_Bomb
				Area="Circle"
				Distance=3
				SpecialAttack=1
				ComboMaster=1
				Rounds=3
				DamageMult=0.7
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				HitSparkIcon='Slash - Zero.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				RoundMovement=0
//T3 is in Projectiles - Beams.

			Destruction_Wave
				SkillCost=TIER_4_COST
				Copyable=4
				EnergyCost=5
				Area="Wave"
				FlickAttack=1
				Distance=5
				ForScaling=1
				DamageMult=11
				Launcher=2
				NoLock=1
				NoAttackLock=1
				TurfErupt=2
				TurfEruptOffset=0
				Slow=1
				Size=1
				HitSparkX=0
				HitSparkY=0
				SpecialAttack=1
				Earthshaking=10
				Cooldown=120
				ActiveMessage="releases a burst of power with a wave of their hand!"
				verb/Destruction_Wave()
					set category="Skills"
					usr.Activate(src)
			Breaker_Wave
				Knockback=15
				SkillCost=TIER_4_COST
				Copyable=5
				EnergyCost=5
				Area="Wide Wave"
				FlickAttack=1
				Distance=15
				MenuIcon="BreakerWave"
				ForScaling=1
				DamageMult=7.5
				Scorching = 10
				TurfErupt=2
				TurfEruptOffset=0
				Slow=1
				Size=2
				HitSparkX=0
				HitSparkY=0
				SpecialAttack=1
				Earthshaking=10
				WindUp=0.2
				ComboMaster = 1
				WindupMessage="focuses their power into a palm..."
				ActiveMessage="unleashes an obliterating wave of power from their hand!"
				Cooldown=18
				verb/Breaker_Wave()
					set category="Skills"
					usr.Activate(src)
			Blazing_Storm
				SkillCost=TIER_4_COST
				Copyable=5
				StrScaling=0
				MenuIcon="BlazingStorm"
				ForScaling=1
				Rounds=10
				DamageMult=0.8
				Area="Around Target"
				FollowTarget=1
				FlickAttack=1
				Distance=15
				DistanceAround=3
				Divide=1
				TurfErupt=2
				TurfEruptOffset=6
				WindUp=0.2
				ComboMaster = 1
				WindupIcon='Ultima Arm.dmi'
				WindupIconSize=1.5
				Launcher=5
				WindupMessage="draws in a large amount of ki..."
				ActiveMessage="unleashes an explosive wave of power directly at their enemy!"
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				Cooldown=18
				EnergyCost=5
				Earthshaking=15
				verb/Blazing_Storm()
					set category="Skills"
					usr.Activate(src)
			Ghost_Wave
				SkillCost=TIER_4_COST
				Copyable=5
				EnergyCost=5
				Area="Wave"
				FlickAttack=1
				Distance=5
				ForScaling=1
				NoLock=1
				NoAttackLock=1
				MenuIcon="GhostWave"
				ControlledRush=0
				Rounds=3
				DamageMult=3.05
				ComboMaster=1
				Launcher=4
				TurfErupt=2
				TurfEruptOffset=0
				Slow=1
				Size=1
				HitSparkX=0
				HitSparkY=0
				SpecialAttack=1
				Earthshaking=5
				ActiveMessage="blinks forward before unleashing a wave of power at point-blank range!"
				Cooldown=18
				verb/Ghost_Wave()
					set category="Skills"
					var/mob/c = usr
					if(!src.Using && !src.cooldown_remaining && !c.GCDBlocked(src) && c.CanUseSkill(src) && c.last_autohit + glob.MACROCHECKTIME <= world.time && !(c.Secret=="Heavenly Restriction" && c.secretDatum?:hasRestriction("Autohits")))
						VanishImage(c)
						for(var/i = 1 to 3)
							var/turf/t = get_step(c, c.dir)
							if(!t || t.density)
								break
							var/gblocked = 0
							for(var/atom/movable/o in t)
								if(o.density && o != c)
									gblocked = 1
									break
							if(gblocked)
								break
							c.loc = t
						c.step_x = 0
						c.step_y = 0
					c.Activate(src)
			Power_Pillar
				SkillCost=TIER_4_COST
				Copyable=5
				EnergyCost=5
				Area="Circle"
				FlickAttack=1
				Distance=3
				RoundMovement=0
				Rounds=1
				MenuIcon="PowerPillar"
				ForScaling=1
				DamageMult=6.5
				NoAttackLock=1
				NoLock=1
				Launcher=4
				ComboMaster = 1
				TurfErupt=2
				TurfEruptOffset=0
				Size=1
				HitSparkX=0
				HitSparkY=0
				SpecialAttack=1
				Earthshaking=5
				WindUp=0.5
				WindupMessage="grows still..."
				ActiveMessage="crushes those nearby with their spiritual aura!!"
				Cooldown=18
				verb/Power_Pillar()
					set category="Skills"
					var/mob/caster = usr
					var/mob/T = caster.Target
					var/can_fire = !(Using || cooldown_remaining)
					caster.Activate(src)
					if(can_fire && T && ismob(T))
						spawn(8)
							if(!Using || !T || T.KO)
								return
							var/turf/c = get_turf(T)
							if(!c || !caster || caster.z != c.z)
								return
							var/back = get_dir(caster, T)
							if(!back)
								back = T.dir
							back = DisplayedCardinal(back, 0)
							var/turf/base = get_step(c, back)
							if(!base)
								return
							var/d = turn(back, 90)
							for(var/i = -1, i <= 1, i++)
								var/turf/t2 = (i == 0) ? base : get_step(base, (i < 0) ? d : turn(d, 180))
								if(!t2 || t2.density)
									continue
								var/blocked = 0
								for(var/mob/o in t2)
									if(o.density)
										blocked = 1
										break
								if(!blocked)
									new /obj/SkillPillar(t2)





////SHIT AINT USED
			Pinpoint_Blast


//General app

///Sword
			Shining_Sword_Slash
				SignatureTechnique=1
				NeedsSword=1
				Area="Circle"
				Distance=2
				Size=2
				StrScaling=0.75
				ForScaling=0.25
				DamageMult=1.45
				DelayTime=0.25
				Rounds=3
				MenuIcon="ShiningSwordSlash"
				PreShockwave=1
				PreShockwaveDelay=1
				PostShockwave=0
				Shockwaves=2
				Shockwave=0.5
				ShockIcon='KenShockwaveFocus.dmi'
				ShockBlend=2
				ShockDiminish=1.15
				ShockTime=4
				GuardBreak=1
				ComboMaster=1
				Flash=2
				Rush=5
				ControlledRush=0
				HitSparkIcon='Slash - Future.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkCount=7
				HitSparkDispersion=4
				Launcher=4
				DelayedLauncher=1
				Cooldown=12
				EnergyCost=3
				Instinct=1
				ActiveMessage="delivers swift justice with a flurry of slashes!"
				verb/Shining_Sword_Slash()
					set category="Skills"
					usr.Activate(src)
			Massacre
				SignatureTechnique=1
				NeedsSword=1
				Area="Circle"
				StrScaling=1
				NoLock=1
				Distance=5
				DamageMult=1.8
				Rounds=5
				MenuIcon="Massacre"
				Knockback=15
				WindUp=0.5
				ComboMaster=1;
				GuardBreak=1;
				WindupMessage="sheathes their blade..."
				ActiveMessage="cuts through any and all around them in the flash of an eye!"
				HitSparkIcon='JudgmentCut.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=2
				HitSparkCount=1
				HitSparkDispersion=16
				BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/AchillesHeel"
				TurfStrike=1
				Cooldown=15
				EnergyCost=4
				Instinct=1
				verb/Massacre()
					set category="Skills"
					usr.Activate(src)
			Slam_Wave
				SignatureTechnique=1
				NeedsSword=1
				Area="Wider Wave"
				StrScaling=1.25
				DamageMult=4.75
				TurfDirt=1
				Distance=12
				Jump=1
				MenuIcon="SlamWave"
				Knockback=10
				FlickAttack=2
				GuardBreak=1
				ComboMaster=1;
				ShockIcon='KenShockwave.dmi'
				Shockwave=1
				Shockwaves=1
				PostShockwave=1
				HitSparkIcon='BLANK.dmi'
				Cooldown=12
				EnergyCost=3
				Earthshaking=1
				Speed=1
				WindUp=0
				Instinct=1
				ActiveMessage="leaps in the air before falling back down, weapon-first!"
				var/tmp/LeapArmed=0
				verb/Slam_Wave()
					set category="Skills"
					if(src.Using || src.cooldown_remaining)
						usr << "<font color='red'>[src] is on cooldown.</font>"
						return
					if(LeapArmed > world.time)
						LeapArmed = 0
						usr.Activate(src)
					else
						LeapArmed = world.time + 50
						usr << "<b>Click a tile within 6 tiles to leap there and slam, or press again to slam in place. (5s)</b>"

			Zantetsuken
				SignatureTechnique=2
				NeedsSword=1
				ExecuteMortal=25
				Distance=15
				MenuIcon="Zantetsuken"
				Gravity=5
				WindUp=1
				WindupMessage="prepares to deliver a peerless slash..."
				DamageMult=13.75
				StrScaling=1
				EndEffectiveness=0.5
				ActiveMessage="slashes through their enemy in the blink of an eye, aiming to mortally wound them!"
				Area="Target"
				GuardBreak=1
				ComboMaster=1;
				PassThrough=1
				MortalBlow=1
				HitSparkIcon='Slash - Zan.dmi'
				HitSparkX=-16
				HitSparkY=-16
				HitSparkTurns=1
				HitSparkSize=3
				Cooldown=45
				EnergyCost=10
				Instinct=1
				verb/Zantetsuken()
					set category="Skills"
					usr.Activate(src)
			Shadow_Cut
				SignatureTechnique=2
				NeedsSword=1
				Area="Strike"
				PassStrikes=1
				StrScaling=1
				Distance=7
				DelayTime=2
				Rounds=7
				IgnoreAlreadyHit = 1
				DamageMult=4.25
				MenuIcon="ShadowCut"
				Knockback=10
				SpeedStrike = 2
				PassThrough=1
				GuardBreak=1
				ComboMaster=1;
				WindUp=0.1
				WindupMessage="sheathes their blade..."
				ActiveMessage="begins to step through the battlefield like a passing shadow!"
				HitSparkIcon='JudgmentCut.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=1
				HitSparkCount=2
				HitSparkDelay=2
				HitSparkDispersion=16
				TurfStrike=1
				Cooldown=45
				EnergyCost=10
				Instinct=1
				verb/Shadow_Cut()
					set category="Skills"
					usr.Activate(src)
			Thousand_Man_Slayer//Give this to (scrubbed)
				SignatureTechnique=2
				PreRequisite=list("/obj/Skills/AutoHit/Massacre")
				NeedsSword=1
				Area="Circle"
				StrScaling=1
				MenuIcon="ThousandManSlayer"
				SpeedStrike=2;
				Distance=7
				PassTo=1
				KillCounter=1
				DamageMult=27.25
				adjust(mob/p)
					if(world.time - kill_stamp > 900)
						kill_stacks = 0
					DamageMult = 27.25 * (1 + 0.0875 * kill_stacks)
					Size = 1 + 0.25 * kill_stacks
				WindUp=1
				GuardBreak=1
				ComboMaster=1;
				Knockback=25
				WindupMessage="lays a hand on their sheathed blade, concentrating for a moment..."
				ActiveMessage="blasts through surrounding foes with what appears to be a single strike!!"
				Cooldown=60
				EnergyCost=12
				verb/Thousand_Man_Slayer()
					set category="Skills"
					usr.Activate(src)
			Mugetsu
				SpecialAttack=1
				SBuffNeeded="Final Getsuga Tenshou"
				Area="Arc"
				Distance=30
				DamageMult=36.75
				StrScaling=1
				ForScaling=1
				Cooldown=-1
				EnergyCost=12
				TurfStrike=1
				TurfShiftLayer=EFFECTS_LAYER
				TurfShiftDuration=-10
				TurfShiftDurationSpawn=0
				TurfShiftDurationDespawn=5
				TurfShift='Gravity.dmi'
				Rush = 7
				ControlledRush = 1
				Divide=1
				Destructive=1
				GuardBreak=1//Can't be dodged or blocked
				WindUp=0.25
				WindupMessage="gathers darkness in form of a sword in their grasp..."
				ActiveMessage="releases an all-consuming wave of darkness!"
				verb/Mugetsu()
					set category="Skills"
					usr.Activate(src)
					spawn(100)
						if(usr.CheckSpecial("Final Getsuga Tenshou"))
							for(var/obj/Skills/Buffs/SpecialBuffs/Sword/Final_Getsuga_Tenshou/FGT in usr)
								usr.UseBuff(FGT)
								del FGT
						for(var/obj/Skills/AutoHit/Mugetsu/MGT in usr)
							del MGT

			Imperial_Wrath
				Area="Circle"
				Distance=10
				GuardBreak=1
				DamageMult=1
				Knockback=20
				Cooldown=150
				Shockwaves=3
				Shockwave=4
				SpecialAttack=1
				Stunner=3
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				EnergyCost=5
///Special

			Kiai
				SignatureTechnique=1
				Area="Circle"
				Distance=10
				GuardBreak=1
				DamageMult=2.55
				MenuIcon="Kiai"
				Knockback=15
				Cooldown=10
				Shockwaves=3
				Shockwave=4
				BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Staggered"
				SpecialAttack=1
				Stunner=0.5
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				ActiveMessage="unleashes a wave of ki!"
				EnergyCost=2
				verb/Kiai()
					set category="Skills"
					usr.Activate(src)

			Taiyoken
				SignatureTechnique=1
				AllOutAttack=1
				Area="Circle"
				Distance=10
				DamageMult = 3.15
				Flash=30
				MenuIcon="Taiyoken"
				WindUp=0.75
				WindupIcon='BLANK.dmi'
				WindupMessage="brings their hands to their face..."
				SpecialAttack=1
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				TurfShift='BrightDay2.dmi'
				TurfShiftLayer=EFFECTS_LAYER
				TurfShiftDuration=-10
				TurfShiftDurationSpawn=0
				TurfShiftDurationDespawn=5
				BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Blinded"
				ActiveMessage="converts their ki to a wave of blinding light!"
				Cooldown=12
				EnergyCost=3
				verb/Taiyoken()
					set category="Skills"
					usr.Activate(src)
			Chidori
				Area="Strike"
				SignatureTechnique=1
				Rush=20
				SpecialAttack=1
				MenuIcon="Chidori"
				CanBeDodged=0
				CanBeBlocked=1
				ComboMaster=1
				DamageMult=7
				Paralyzing=2
				Knockback=0
				WindUp=1
				WindupIcon='Chidori.dmi'
				WindupMessage="begins charging lightning into their palm!"
				ActiveMessage="rushes in with terrifying piercing force!"
				Icon='Chidori.dmi'
				HitSparkIcon='Hit Effect Vampire.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=1
				Cooldown=15
				EnergyCost=4
				Instinct=1
				proc/reset2default()
					Area="Strike"
					Rush=20
					SpecialAttack=1
					CanBeDodged=0
					CanBeBlocked=1
					DamageMult=7
					Knockback=0
					WindUp=1
					WindupIcon='Chidori.dmi'
					WindupMessage="begins charging lightning into their palm!"
					ActiveMessage="rushes in with terrifying piercing force!"
					Icon='Chidori.dmi'
					HitSparkIcon='Hit Effect Vampire.dmi'
					HitSparkX=-32
					HitSparkY=-32
					HitSparkSize=1
					EnergyCost=4
					Instinct=1
					Rounds = 0
					ChargeTech = 0
					ChargeTime = 0
					TurfShift=null
					TurfShiftDuration=0
					TurfShiftDurationSpawn = 0
					TurfShiftDurationDespawn = 0
					name = "Chidori"
				adjust(mob/p)
					if(p.isInnovative(HUMAN, "Any") && !isInnovationDisable(p) && p.Class == "Heroic")
						name = "Lightning Blade"
						Area = "Circle"

						ChargeTime = 1.5 - (p.Potential/100)
						ChargeTech = 1
						WindUp = 2.5 - (p.Potential/100)
						Rush = 2
						Rounds = 30
						TurfShift='Glowing Electricity.dmi'
						TurfShiftDuration=6
						TurfShiftDurationSpawn = 1
						TurfShiftDurationDespawn = 5
						Grapple = 1
						GrabMaster = 1
						DamageMult = 0.08
						Quaking = 10
						GrabTrigger = "/obj/Skills/Grapple/Lightning_Blade"
						WindupMessage="begins charging an excessive amount of lightning in their palm!"
						ActiveMessage="rushes in with the sound of one thousand chirping birds following!"
						BuffSelf = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Over_Exerted
					else
						reset2default()
				verb/Chidori()
					set category="Skills"
					if(usr.Saga=="Sharingan")
						src.ControlledRush=1
					adjust(usr)
					var/can_fire = !(Using || cooldown_remaining)
					if(can_fire && !usr.GCDBlocked(src))
						usr.rush_vuln_until = world.time + 25
					usr.Activate(src)
			The_Seventh_Super_Explosive_Wave
				SignatureTechnique=4
				StrScaling=0
				ForScaling=1
				GrabMaster=1
				Grapple=1
				ComboMaster=1
				DamageMult=36
				Area="Circle"
				Distance=20
				TurfErupt=2
				TurfEruptOffset=3
				Slow=1
				WindUp=1
				WindupIcon='Ripple Radiance.dmi'
				WindupIconUnder=1
				WindupIconX=-32
				WindupIconY=-32
				WindupIconSize=1.3
				Divide=1
				PullIn=25
				WindupMessage="prepares to seal their opponent's fate..."
				ActiveMessage="unleashes an eruption of malevolence."
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				Cooldown=300
				Earthshaking=15
				PreQuake=1
				verb/The_Seventh_Super_Explosive_Wave()
					set category="Skills"
					usr.Activate(src)
			Super_Explosive_Wave
				SignatureTechnique=1
				StrScaling=0
				ForScaling=1
				DamageMult=6
				Area="Circle"
				Distance=8
				TurfErupt=2
				TurfEruptOffset=3
				Slow=1
				WindUp=1
				MenuIcon="SuperExplosiveWave"
				WindupIcon='Ripple Radiance.dmi'
				WindupIconUnder=1
				WindupIconX=-32
				WindupIconY=-32
				WindupIconSize=1.3
				Divide=1
				PullIn=25
				WindupMessage="draws in a large amount of ki..."
				ActiveMessage="unleashes an explosive wave of power!"
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				Cooldown=15
				EnergyCost=4

				Earthshaking=15
				PreQuake=1
				verb/Super_Explosive_Wave()
					set category="Skills"
					usr.Activate(src)
			Kikoho
				SignatureTechnique=1
				AllOutAttack=1
				StrScaling=0
				ForScaling=1
				MenuIcon="Kikoho"
				DamageMult=5.5
				WoundCost=5
				ComboMaster=1
				Area="Around Target"
				Distance=15
				DistanceAround=4
				Divide=1
				Launcher=2
				GuardBreak=1
				WindUp=1.5
				WindupIcon='Ripple Radiance.dmi'
				WindupIconUnder=1
				WindupIconX=-32
				WindupIconY=-32
				WindupIconSize=1
				WindupMessage="begins drawing on their life force..."
				ActiveMessage="unleashes an explosive wave of power directly at their enemy!"
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				PreShockwave=1
				PreShockwaveDelay=2
				PostShockwave=0
				Shockwaves=2
				Shockwave=0.5
				ShockIcon='KenShockwaveGold.dmi'
				ShockBlend=2
				ShockDiminish=1.15
				ShockTime=4
				TurfShift='Lightning.dmi'
				TurfShiftLayer=6
				TurfShiftDuration=-10
				TurfShiftDurationSpawn=0
				TurfShiftDurationDespawn=5
				TurfErupt=2
				Cooldown=12
				Earthshaking=15
				GuardBreak=1
				Instinct=1
				DirectWounds=5
				SquareArea=1
				proc/set2default()
					AllOutAttack=1
					StrScaling=0
					ForScaling=1
					DamageMult=5.5
					WoundCost=5
					ComboMaster=1
					Area="Around Target"
					Distance=15
					DistanceAround=4
					Divide=1
					Launcher=2
					GuardBreak=1
					WindUp=1.5
					WindupIcon='Ripple Radiance.dmi'
					WindupIconUnder=1
					WindupIconX=-32
					WindupIconY=-32
					WindupIconSize=1
					WindupMessage="begins drawing on their life force..."
					ActiveMessage="unleashes an explosive wave of power directly at their enemy!"
					HitSparkIcon='BLANK.dmi'
					HitSparkX=0
					HitSparkY=0
					PreShockwave=1
					PreShockwaveDelay=2
					PostShockwave=0
					Shockwaves=2
					Shockwave=0.5
					ShockIcon='KenShockwaveGold.dmi'
					ShockBlend=2
					ShockDiminish=1.15
					ShockTime=4
					TurfShift='Lightning.dmi'
					TurfShiftLayer=6
					TurfShiftDuration=-10
					TurfShiftDurationSpawn=0
					TurfShiftDurationDespawn=5
					TurfErupt=2
					Cooldown=12
					Earthshaking=15
					GuardBreak=1
					Instinct=1
					DirectWounds=5
				adjust(mob/p)
					var/asc= p.AscensionsAcquired
					if(p.isInnovative(HUMAN, "Any") && !isInnovationDisable(p) && p.Class == "Heroic")
						AllOutAttack=1
						StrScaling=1
						ForScaling=1
						DamageMult=5.5 + (asc*0.5)
						WoundCost=5 + asc
						ComboMaster=1
						Area="Around Target"
						Distance=15
						DistanceAround=4
						Divide=1
						Launcher=2
						GuardBreak=1
						WindUp=1.5
						WindupIcon='Ripple Radiance.dmi'
						WindupIconUnder=1
						WindupIconX=-32
						WindupIconY=-32
						WindupIconSize=1
						WindupMessage="begins drawing on their life force..."
						ActiveMessage="unleashes an explosive wave of power directly at their enemy!"
						HitSparkIcon='BLANK.dmi'
						HitSparkX=0
						HitSparkY=0
						PreShockwave=1
						PreShockwaveDelay=2
						PostShockwave=0
						Shockwaves=2
						Shockwave=0.5
						ShockIcon='KenShockwaveGold.dmi'
						ShockBlend=2
						ShockDiminish=1.15
						ShockTime=4
						TurfShift='Lightning.dmi'
						TurfShiftLayer=6
						TurfShiftDuration=-10
						TurfShiftDurationSpawn=0
						TurfShiftDurationDespawn=5
						TurfErupt=2
						Cooldown=12 + asc
						CooldownStatic=1
						Earthshaking=15
						GuardBreak=1
						Instinct=1
						DirectWounds=5 + asc
					else
						set2default()
				verb/Kikoho()
					set category="Skills"
					src.StrScaling= usr.TotalInjury > 25 ? (usr.TotalInjury/100) : 0;
					adjust(usr)
					usr.Activate(src)

			Shin_Kikoho
				PreRequisite=list("/obj/Skills/AutoHit/Kikoho")
				SignatureTechnique=2
				AllOutAttack=1
				StrScaling=0
				ForScaling=1
				Launcher=2
				WoundCost=6.2
				DamageMult=19.75
				DelayTime = 5
				ComboMaster=1
				Cooldown=45
				Area="Around Target"
				MenuIcon="ShinKikoho"
				Distance=15
				DistanceAround=4
				Divide=1
				WindUp=0.1
				WindupIcon='Ripple Radiance.dmi'
				WindupIconUnder=1
				WindupIconX=-32
				WindupIconY=-32
				WindupIconSize=1.2
				Float=6
				ActiveMessage="recklessly unleashes an explosive wave of power directly at their enemy!"
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				PreShockwave=1
				PreShockwaveDelay=2
				PostShockwave=0
				Shockwaves=2
				Shockwave=0.8
				ShockIcon='KenShockwaveGold.dmi'
				ShockBlend=2
				ShockDiminish=1.15
				ShockTime=4
				TurfShift='Lightning.dmi'
				TurfShiftLayer=6
				TurfShiftDuration=-10
				TurfShiftDurationSpawn=0
				TurfShiftDurationDespawn=5
				TurfErupt=2
				Earthshaking=15
				GuardBreak=1
				Instinct=1
				DirectWounds=6.2;
				SquareArea=1
				verb/Shin_Kikoho()
					set category="Skills"
					src.StrScaling= usr.TotalInjury > 25 ? (usr.TotalInjury/50) : 0;
					if(world.time >= chain_until)
						recast_count = 0
					if(recast_count > 0 && world.time < chain_until)
						Using = 0
						cooldown_remaining = 0
					WoundCost = 6.2 * (1 + recast_count)
					DirectWounds = WoundCost
					if(usr.Activate(src))
						recast_count++
						chain_until = world.time + 30

////Racial
			Poison_Gas
				ElementalClass="Poison"
				StrScaling=0.5
				ForScaling=0.5
				EndEffectiveness=0.5
				DamageMult=1.5
				NoLock=1
				NoAttackLock=1
				SpecialAttack=1
				GuardBreak=1
				Area="Circle"
				Distance=1
				Wander=10
				Toxic=5
				ActiveMessage="releases a noxious sweat!"
				ObjIcon=1
				Icon='PoisonGas.dmi'
				IconX=-16
				IconY=-16
				Size=1.5
				Cooldown=90
				Rounds=40
				DelayTime=5
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				verb/Poison_Gas()
					set category="Skills"
					usr.Activate(src)
			Great_Deluge
				ElementalClass="Water"
				ForScaling=1
				StrScaling=0
				Area="Circle"
				TurfReplace='PlainWater.dmi'
				Distance=20
				WindUp=2
				DamageMult=15
				SpecialAttack=1
				HitSparkIcon='Hit Effect Pearl.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=6
				TurfStrike=1
				WindupMessage="calls upon the waters of the world..."
				ActiveMessage="crushes the area with a massive downpour of water!"
				Slow=1
				NoLock=1
				Deluge=3000
				Cooldown=10800
				verb/Great_Deluge()
					set category="Skills"
					usr.Activate(src)
			Gwych_Dymestl
				ElementalClass="Wind"
				ForScaling=1
				StrScaling=0
				Area="Around Target"
				DistanceAround
				CanBeDodged=1
				Distance=20
				DistanceAround=15
				DamageMult=2
				WindUp=2
				DelayTime=70
				Rounds=40
				Slow=3
				Paralyzing=5
				SpecialAttack=1
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				WindupMessage="conjures ominous clouds to hang in the sky..."
				ActiveMessage="unleashes a grand thunderstorm!!"
				Thunderstorm=20
				Bolt=1
				NoLock=1
				Cooldown=10800
				verb/Grand_Dymestl()
					set name="Gwych Dymestyl"
					set category="Skills"
					usr.Activate(src)

////Magic
			Magic
				MagicNeeded=1
				Blizzard
					ElementalClass="Water"
					SpellElement="Water"
					SkillCost=TIER_2_COST
					Copyable=2
					Area="Wave"
					Distance=6
					Freezing=2
					Slow=1
					DamageMult=3
					SpecialAttack=1
					StrScaling=0
					ForScaling=1
					FlickAttack=1
					CanBeDodged=1
					CanBeBlocked=0
					HitSparkIcon='SnowBurst2.dmi'
					HitSparkTurns=0
					HitSparkSize=1
					HitSparkDispersion=8
					TurfStrike=1
					ManaCost=3
					Cooldown=45
					ActiveMessage="invokes: <font size=+1>BLIZZARD!</font size>"
					adjust(mob/p)
						if(!altered)
							if(p.isInnovative(KEYBLADE_MAGIC, "Any") && !isInnovationDisable(p) || p.KeybladeType=="Staff" && !isInnovationDisable(p))
								Rounds=round(p.getTotalMagicLevel()/5)
								Knockback=1
								Distance= 6 + round(p.getTotalMagicLevel()/5)
								Slow = 3 + p.Potential/10
								NoLock=1
								NoAttackLock=1
								Freezing = 2 + p.Potential/10
								ManaCost = round(p.getTotalMagicLevel()/3) + 3
								Slow=0.25
								ActiveMessage="invokes a powerful: <font size=+1>BLIZZARD!</font size>"
							else
								Rounds=initial(Rounds)
								Knockback=0
								Distance= 6
								Slow = 1
								Freezing = 2
								ManaCost = 3
					verb/Disable_Innovate()
						set category = "Other"
						set hidden = 1
						disableInnovation(usr)
					verb/Blizzard()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)
				Blizzara
					ElementalClass="Water"
					SpellElement="Water"
					SkillCost=TIER_2_COST
					Copyable=3
					Area="Wide Wave"
					Distance=6
					Freezing=4
					Slow=1
					DamageMult=6
					SpecialAttack=1
					StrScaling=0
					ForScaling=1
					CanBeDodged=1
					CanBeBlocked=0
					HitSparkIcon='SnowBurst2.dmi'
					HitSparkSize=1
					HitSparkDispersion=16
					TurfStrike=3
					ManaCost=6
					Cooldown=45
					ActiveMessage="invokes: <font size=+1>BLIZZARA!</font size>"
					verb/Disable_Innovate()
						set category = "Other"
						set hidden = 1
						disableInnovation(usr)
					adjust(mob/p)
						// make it cast a projectile that is like hell zone grenade
						if(!altered)
							if(!isInnovationDisable(p) && p.isInnovative(KEYBLADE_MAGIC, "Any") || p.KeybladeType=="Staff" && !isInnovationDisable(p))
								if(!Using && usr.ManaAmount >= 11)
									if(!locate(/obj/Skills/Projectile/Blizzara, usr))
										usr.AddSkill(new/obj/Skills/Projectile/Blizzara)
									var/obj/Skills/Projectile/Blizzara/bli = usr.FindSkill(/obj/Skills/Projectile/Blizzara)
									bli.adjust(usr)
									usr.UseProjectile(bli)
									usr.ManaAmount-=5
									NoLock=1
									NoAttackLock=1
									Area="Around Target"
									Distance=10
									DistanceAround=3
									Rounds = clamp(p.getTotalMagicLevel()/5, 1, 4)
									DamageMult = 1 + p.Potential/25 + p.getTotalMagicLevel()/10
									DamageMult= clamp(DamageMult/Rounds, 0.001, 15)
									ActiveMessage="invokes a powerful: <font size=+1>BLIZZARA!</font size>"

								else
									return
							else
								Area="Wide Wave"
								Distance=6
								DistanceAround=0
								Rounds = initial(Rounds)
								DamageMult = 6
					verb/Blizzara()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)
				Blizzaga
					ElementalClass="Water"
					SpellElement="Water"
					SkillCost=TIER_2_COST
					Copyable=4
					Area="Circle"
					Distance=6
					Freezing=6
					Slow=1
					DamageMult=8
					SpecialAttack=1
					StrScaling=0
					ForScaling=1
					CanBeDodged=1
					CanBeBlocked=0
					HitSparkIcon='SnowBurst2.dmi'
					HitSparkSize=1
					HitSparkDispersion=4
					TurfStrike=3
					ManaCost=9
					Cooldown=45
					ActiveMessage="invokes: <font size=+1>BLIZZAGA!</font size>"
					verb/Disable_Innovate()
						set category = "Other"
						set hidden = 1
						disableInnovation(usr)
					adjust(mob/p)
						if(!altered)
							if(p.isInnovative(KEYBLADE_MAGIC, "Any") && !isInnovationDisable(p) || p.KeybladeType=="Staff" && !isInnovationDisable(p))
							//	Rounds = 3 + p.Potential/25
								Distance = 7
								Freezing = 6 + p.getTotalMagicLevel()
								DamageMult = 5 + p.getTotalMagicLevel()/5 + p.Potential/25
								ForScaling=0
								NoLock=1
							//	NoAttackLock=1
							//	DamageMult/=Rounds
								ManaCost = 10
								ActiveMessage="invokes a powerful: <font size=+1>BLIZZAGA!</font size>"
							else
								Rounds=initial(Rounds)
								Knockback=0
								Distance= 6
								DamageMult=8
								ForScaling=1
								Freezing = 6
								ManaCost = 9
					verb/Blizzaga()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)

				Thunder
					ElementalClass="Wind"
					SpellElement="Wind"
					FlickAttack=1
					SkillCost=TIER_2_COST
					Copyable=2
					Distance=6
					Area="Target"
					ForScaling=1
					DamageMult=6
					Paralyzing=5
					Size=1
					Bolt=2
					HitSparkIcon='BLANK.dmi'
					HitSparkX=0
					HitSparkY=0
					WindUp=1
					ManaCost=3
					SpecialAttack=1
					CanBeDodged=1
					CanBeBlocked=0
					Cooldown=45
					WindupMessage="invokes: <font size=+1>THUNDER!</font size>"
					verb/Disable_Innovate()
						set category = "Other"
						set hidden = 1
						disableInnovation(usr)
					adjust(mob/p)
						if(!altered)
							if(p.isInnovative(KEYBLADE_MAGIC, "Any") && !isInnovationDisable(p) || p.KeybladeType=="Staff" && !isInnovationDisable(p))
								var/asc = p.AscensionsAcquired
								var/magicLevel = p.getTotalMagicLevel()
								Rush=5
								ControlledRush=1
								Distance = 8
								Bolt=2
								Size=0.5
								WindUp=0.25
								Rounds= max(1, round(magicLevel/5) + asc)
								DamageMult = clamp(magicLevel/3 + asc * 2, 4, 12)/(Rounds/2)
								ManaCost = 5
								NoAttackLock=1
								ActiveMessage="invokes a powerful: <font size=+1>THUNDER!</font size>"
							else
								Rush=0
								ControlledRush=0
								Distance = 6
								Size=1
								WindUp=1
								Rounds= initial(Rounds)
								DamageMult=4
								ManaCost = 3
					verb/Thunder()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)
				Thundara
					ElementalClass="Wind"
					SpellElement="Wind"
					FlickAttack=1
					SkillCost=TIER_2_COST
					Copyable=3
					Area="Circle"
					Distance=8
					Paralyzing=8
					Bolt=2
					WindUp=1
					DamageMult=7
					SpecialAttack=1
					ForScaling=1
					CanBeDodged=1
					CanBeBlocked=0
					ManaCost=5
					Cooldown=45
					WindupMessage="invokes: <font size=+1>THUNDARA!</font size>"
					verb/Disable_Innovate()
						set category = "Other"
						set hidden = 1
						disableInnovation(usr)
					adjust(mob/p)
						DamageMult = initial(DamageMult)
						// make it cast a projectile that is like hell zone grenade
						ManaCost = 5
						if(!altered)
							if(p.isInnovative(KEYBLADE_MAGIC, "Any") && !isInnovationDisable(p) || p.KeybladeType=="Staff" && !isInnovationDisable(p))
								if(!Using && usr.ManaAmount >= 10)
									if(!locate(/obj/Skills/Projectile/Thundara, usr))
										usr.AddSkill(new/obj/Skills/Projectile/Thundara)
									var/obj/Skills/Projectile/Thundara/th = usr.FindSkill(/obj/Skills/Projectile/Thundara)
									th.adjust(usr)
									usr.UseProjectile(th)
									DamageMult=5
									Rounds=2
									NoAttackLock=1
									ActiveMessage="invokes a powerful: <font size=+1>THUNDARA!</font size>"
								else
									return

					verb/Thundara()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)
				Thundaga
					ElementalClass="Wind"
					SpellElement="Wind"
					FlickAttack=1
					SkillCost=TIER_2_COST
					Copyable=4
					Area="Around Target"
					Distance=10
					DistanceAround=7
					Paralyzing=4
					Bolt=2
					BoltOffset=1
					WindUp=1
					DamageMult=4
					Rounds=5
					SpecialAttack=1
					ForScaling=1
					CanBeDodged=0
					CanBeBlocked=1
					ManaCost=10
					Cooldown=45
					WindupMessage="invokes: <font size=+1>THUNDAGA!</font size>"
					verb/Disable_Innovate()
						set category = "Other"
						set hidden = 1
						disableInnovation(usr)
					adjust(mob/p)
						if(!altered)
							if(p.isInnovative(KEYBLADE_MAGIC, "Any") && !isInnovationDisable(p) || p.KeybladeType=="Staff" && !isInnovationDisable(p))
								Rounds = 20
								DamageMult = 0.375
								Icon='VR Cloud.png'
								IconX=-13
								Size = 8
								Cooldown = 90
								NoLock=1
								NoAttackLock=1
								WindUp=2
								Thunderstorm=7
								ManaCost = 7.5
								ActiveMessage="invokes a powerful: <font size=+1>THUNDAGA!</font size>"
							else
								DamageMult=1.5
								Rounds=5
								Icon=null
								IconX=0
								Size = initial(Size)
								Cooldown = 45
								NoLock=0
								NoAttackLock=0
								WindUp=1
								Thunderstorm=0
								ManaCost = 10
					verb/Thundaga()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)

				Magnet
					ElementalClass="Dark"
					SpellElement="Space"
					FlickAttack=1
					SkillCost=TIER_4_COST
					Copyable=4
					StrScaling=0
					ForScaling=1
					DamageMult=0.66
					Area="Around Target"
					SpecialAttack=1
					NoLock=1
					NoAttackLock=1
					Distance=15
					DistanceAround=3
					Rounds=15
					DelayTime=2
					Launcher=3
					CanBeDodged=1
					CanBeBlocked=0
					Icon='LightningBolt.dmi'
					Size=0.5
					IconX=-33
					IconY=-33
					ActiveMessage="invokes: <font size=+1>MAGNET!</font size>"
					Cooldown=120
					ManaCost=10
					adjust(mob/p)
						DamageMult = initial(DamageMult)
					verb/Magnet()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)
				Gravity
					ElementalClass="Dark"
					SpellElement="Space"
					SkillCost=TIER_4_COST
					Copyable=5
					Area="Around Target"
					Distance=15
					DistanceAround=4
					WindUp=0.5
					GuardBreak=1
					SpecialAttack=1
					NoLock=1
					NoAttackLock=1
					StrScaling=0
					ForScaling=1
					DamageMult=11
					Rounds=1
					DelayTime=2
					Launcher=1
					Crippling=20
					TurfShift='Gravity.dmi'
					TurfShiftLayer=MOB_LAYER+1
					TurfShiftDuration=0
					TurfShiftDurationSpawn=3
					TurfShiftDurationDespawn=7
					WindupMessage="invokes: <font size=+1>GRAVITY!</font size>"
					Cooldown=120
					ManaCost=15
					adjust(mob/p)
						DamageMult = initial(DamageMult)
					verb/Gravity()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)

				Flare
					ElementalClass="Fire"
					SpellElement="Fire"
					SkillCost=TIER_4_COST
					Copyable=6
					Area="Around Target"
					Distance=15
					DistanceAround=7
					DamageMult=12
					ManaCost=20
					Cooldown=60
					EndEffectiveness=0.5
					GuardBreak=1
					Slow=0.5
					DelayTime=1
					HitSparkIcon='Hit Effect Ripple.dmi'
					HitSparkX=-32
					HitSparkY=-32
					HitSparkTurns=1
					HitSparkSize=2
					HitSparkCount=1
					HitSparkDispersion=24
					TurfStrike=1
					WindUp=0.5
					WindupIcon='Cure.dmi'
					WindupMessage="invokes: <font size=+1>FLARE!</font size>"
					ForScaling=1
					EndEffectiveness=1
					SpecialAttack=1
					Instinct=1
					adjust(mob/p)
						DamageMult = initial(DamageMult)
					verb/Flare()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)


				Magnetga
					ElementalClass="Dark"
					SpellElement="Space"
					SagaSignature=1
					SignatureTechnique=1
					SignatureName="Advanced Space Magic"
					FlickAttack=1
					StrScaling=0
					ForScaling=1
					DamageMult=0.7
					Area="Around Target"
					SpecialAttack=1
					NoLock=1
					NoAttackLock=1
					Distance=30
					DistanceAround=4
					Rounds=20
					DelayTime=2
					MenuIcon="Magnetga"
					WindUp=0.5
					Launcher=4
					Icon='LightningBolt.dmi'
					Size=0.8
					IconX=-33
					IconY=-33
					WindupMessage="invokes: <font size=+1>MAGNETGA!</font size>"
					ActiveMessage="creates a powerful orb of magnetism, drawing their opponents towards the sky!"
					Cooldown=180
					ManaCost=25
					adjust(mob/p)
						DamageMult = initial(DamageMult)
					verb/Magnetga()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)
				Graviga
					ElementalClass="Dark"
					SpellElement="Space"
					SagaSignature=1
					SignatureTechnique=1
					SignatureName="Advanced Space Magic"
					Area="Circle"
					Distance=8
					WindUp=1
					MenuIcon="Graviga"
					NoLock=1
					NoAttackLock=1
					GuardBreak=1
					SpecialAttack=1
					StrScaling=0
					ForScaling=1
					DamageMult=12
					Cooldown=180
					ManaCost=25
					Crippling=3
					TurfShift='Gravity.dmi'
					TurfShiftLayer=MOB_LAYER+1
					TurfShiftDuration=0
					TurfShiftDurationSpawn=3
					TurfShiftDurationDespawn=7
					WindupMessage="invokes: <font size=+1>GRAVIGA!</font size>"
					adjust(mob/p)
						DamageMult = initial(DamageMult)
					verb/Graviga()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)

				Holy
					ElementalClass="Light"
					SpellElement="Light"
					SagaSignature=1
					SignatureTechnique=2
					SignatureName="Holy Magic"
					Area="Target"
					Distance=7
					Purity=1
					MenuIcon="Holy"
					DamageMult=18
					WindUp=1
					ManaCost=30
					Cooldown=180
					HitSparkIcon='Hit Effect Pearl.dmi'
					HitSparkX=-32
					HitSparkY=-32
					HitSparkTurns=1
					HitSparkSize=5
					HitSparkCount=10
					HitSparkDispersion=1
					ForScaling=1
					SpecialAttack=1
					WindupMessage="invokes: <font size=+1>HOLY!</font size>"
					adjust(mob/p)
						DamageMult = initial(DamageMult)
					verb/Holy()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)





/// MAGIC AUTO HIT SIGS T1

////SWORD
//T1 has damage mult 1.5 - 2.5

			Tipper
				SkillCost=40
				Copyable=1
				NeedsSword=1
				FlickAttack=1
				Area="Strike"
				Distance=2
				StrScaling=1
				NoPierce=1
				Knockback=15
				DamageMult=2.5
				StepsDamage=1
				Cooldown=30
				EnergyCost=1
				ActiveMessage="thrusts their sword forward!"
				verb/Tipper()
					set category="Skills"
					usr.Activate(src)


//T2

//T3 is in Grapples.

//T4 is in Projectiles too.

			Flash_Cut
				SkillCost=160
				Copyable=4
				NeedsSword=1
				Area="Circle"
				GuardBreak=1
				StrScaling=1
				Distance=1
				Rush=10
				ControlledRush=0
				PassThrough=1
				DamageMult=10
				WindUp=1
				WindupMessage="sheathes their blade..."
				ActiveMessage="erupts with a burst of godspeed, reaching their target in an instant!"
				Cooldown=120
				PassThrough=1
				PreShockwave=1
				PostShockwave=0
				Shockwave=2
				Shockwaves=2
				HitSparkIcon='Slash.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=1
				HitSparkDispersion=1
				Earthshaking=10
				verb/Flash_Cut()
					set category="Skills"
					usr.Activate(src)
			Jet_Slice
				SkillCost=TIER_4_COST
				Copyable=5
				AlwaysAnnounceCooldown = 1
				NeedsSword=1
				Area="Target"
				GuardBreak=1
				StrScaling=1
				DamageMult=8.5
				Distance=10
				PassThrough=1
				PreShockwave=1
				PostShockwave=1
				Shockwave=2
				Shockwaves=2
				ActiveMessage="flickers behind their opponent for an instantaneous slash!"
				Cooldown=18
				EnergyCost=5
				verb/Disable_Innovate()
					set category = "Other"
					set hidden = 1
					disableInnovation(usr)
				adjust(mob/p)
					if(p.isInnovative(HUMAN, "Sword") && !isInnovationDisable(p))
						var/pot = p.Potential
						Area="Wave"
						ComboMaster=1
						GuardBreak=1
						StrScaling=1
						PassThrough=1
						PreShockwave=1
						PostShockwave=0
						Shockwave=2
						Shockwaves=2
						DamageMult= (5 + (pot/100)) * 0.71
						Rounds = 2
						Stunner=1
						Distance= 4 + (round(pot/10))
						HitSparkIcon='Slash.dmi'
						HitSparkX=-32
						HitSparkY=-32
						HitSparkTurns=1
						HitSparkSize=1
						HitSparkDispersion=1
						TurfStrike=1
						TurfShift='Dark.dmi'
						TurfShiftDuration=3
					else if(p.isInnovative(CELESTIAL, "Any") && !isInnovationDisable(p) && p.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/DarkMagic))
						var/pot = p.Potential
						Area="Wave"
						ComboMaster=1
						GuardBreak=1
						StrScaling=1
						PassThrough=1
						PreShockwave=1
						PostShockwave=0
						Shockwave=2
						Shockwaves=2
						DamageMult= (5 + (pot/100)) * 0.71
						Rounds = 2
						Stunner=1
						Distance= 4 + (round(pot/10))
						HitSparkIcon='Slash - Hellfire.dmi'
						HitSparkX=-32
						HitSparkY=-32
						HitSparkTurns=1
						HitSparkSize=1
						HitSparkDispersion=1
						TurfStrike=1
						TurfShift='blackflameaura.dmi'
						TurfShiftDuration=3
					else
						Area="Target"
						ComboMaster=0
						GuardBreak=1
						StrScaling=1
						PassThrough=1
						PreShockwave=1
						PostShockwave=1
						Shockwave=2
						Shockwaves=2
						DamageMult=8.5
						Rounds = 0
						Stunner=0
						Distance= 10
						HitSparkIcon=0
						HitSparkX=0
						HitSparkY=0
						HitSparkTurns=0
						HitSparkSize=0
						HitSparkDispersion=0
						TurfStrike=0
						TurfShift=0
						TurfShiftDuration=0
					if(p.isInnovative(CELESTIAL, "Any") && !isInnovationDisable(p) && p.isDemonMagicCasting(/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/Corruption))
						CorruptionDebuff = 1
					else
						CorruptionDebuff = 0
				verb/Jet_Slicer()
					set category="Skills"
					var/mob/caster = usr
					var/can_fire = !(Using || cooldown_remaining)
					var/turf/origin = get_turf(caster)
					var/osx = caster.step_x
					var/osy = caster.step_y
					caster.Activate(src)
					applyDemonInnovationEffect(caster, can_fire)
					if(can_fire)
						spawn(4)
							if(!Using || !caster || caster.KO || caster.Stunned || caster.Launched || caster.Suspended || caster.Stasis)
								return
							if(!origin || origin.density || caster.z != origin.z)
								return
							caster.loc = origin
							caster.step_x = osx
							caster.step_y = osy
			Crowd_Cutter
				RushTally=0.2
				SkillCost=TIER_3_COST
				Copyable=5
				NeedsSword=1
				Area="Wide Wave"
				StrScaling=1
				Distance=10
				PassThrough=1
				PreShockwave=1
				PostShockwave=0
				Shockwave=2
				Shockwaves=2
				DamageMult=4.0
				WindUp=0.5
				WindupMessage="sheathes their blade..."
				ActiveMessage="blasts through all opposition in a blink of an eye!"
				HitSparkIcon='Slash.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=1
				HitSparkDispersion=1
				TurfStrike=1
				TurfShift='Dirt1.dmi'
				TurfShiftDuration=3
				Cooldown=12
				EnergyCost=3
				Instinct=1
				verb/Crowd_Cutter()
					set category="Skills"
					usr.Activate(src)
			Holy_Justice
				SkillCost=TIER_4_COST
				Copyable=5
				NeedsSword=1
				Area="Around Target"
				DamageMult=0.35
				Distance=5
				DistanceAround=3
				EnergyCost=5
				Rounds=20
				TurfErupt=1.25
				TurfEruptOffset=6
				DelayTime=1
				ComboMaster = 1
				Icon='SwordHugeHolyJustice.dmi'
				Size=0.5
				IconX=-159
				IconY=0
				Falling=1//animates towards pixel_z=0 while it is displayed
				ActiveMessage="plunges a phantom blade down for holy justice!"
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				Cooldown=18
				Instinct=1
				Silencing=1
				verb/Holy_Justice()
					set category="Skills"
					usr.Activate(src)
			Doom_of_Damocles
				SkillCost=TIER_4_COST
				Copyable=5
				NeedsSword=1
				Area="Around Target"
				DamageMult=8.5
				Distance=5
				DistanceAround=3
				EnergyCost=5
				TurfErupt=1.25
				TurfEruptOffset=6
				DelayTime=1
				ComboMaster = 1
				Icon='SwordHugeDoomofDamocles.dmi'
				Size=0.5
				IconX=-159
				IconY=0
				Falling=1//animates towards pixel_z=0 while it is displayed
				ActiveMessage="plunges an ethereal sword down for a cruel execution!"
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				Cooldown=18
				Instinct=1
				var/tmp/doom_pending = 0
				verb/Doom_of_Damocles()
					set category="Skills"
					var/mob/caster = usr
					if(Using || cooldown_remaining)
						caster << "<font color='red'>[name] is on cooldown.</font>"
						return
					if(doom_pending)
						return
					var/mob/T = caster.Target
					if(!T || !ismob(T) || T == caster)
						caster << "<font color='red'>You need a target to hang the blade over.</font>"
						return
					if(get_dist(caster, T) > Distance + 3)
						caster << "<font color='red'>They are too far away.</font>"
						return
					if(caster.GCDBlocked(src))
						return
					caster.StartGCD(src)
					doom_pending = 1
					OMsg(caster, "<b>An ethereal blade hangs over [T] - it falls the moment they act!</b>")
					var/obj/Effects/HE = new(null, 'SwordHugeDoomofDamocles.dmi', -159, 24, 0, 1, 40)
					HE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
					HE.Target = T
					T.vis_contents += HE
					var/cast_time = world.time
					spawn()
						var/triggered = 0
						while(world.time < cast_time + 40)
							if(!caster || caster.KO || !T || T.KO || T.Health <= 0)
								doom_pending = 0
								return
							if(T.last_skill_fire_time > cast_time)
								triggered = 1
								break
							sleep(2)
						doom_pending = 0
						if(triggered)
							var/mob/oldT = caster.Target
							caster.Target = T
							var/ng = src.NoGCD
							src.NoGCD = 1
							if(!caster.Activate(src, noGCD=TRUE))
								src.Cooldown(1, null, caster)
							src.NoGCD = ng
							caster.Target = oldT
						else
							OMsg(caster, "<b>The blade over [T] fades away.</b>")
							var/ng = src.NoGCD
							src.NoGCD = 1
							src.Cooldown(1, null, caster)
							src.NoGCD = ng



//SHIT AINT USED
			SpinRave
				SkillCost=80
				Copyable=3
				NeedsSword=1
				Area="Circle"
				StrScaling=1
				DamageMult=5
				Cooldown=120
				Knockback=20
				Size=2
				Distance=2
				RoundMovement=0
				WindUp=0.5
				WindupMessage="charges a massive amount of energy into their blade...!"
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				EnergyCost=5
				ActiveMessage="spins their blade with destructive force!"
				verb/Spin_Rave()
					set category="Skills"
					usr.Activate(src)
			TornadoRave
				SkillCost=60
				Copyable=4
				PreRequisite=list("/obj/Skills/AutoHit/SpinRave")
				LockOut=list("/obj/Skills/AutoHit/ArkBrave")
				NeedsSword=1
				Area="Circle"
				StrScaling=1
				DamageMult=1
				Cooldown=240
				Knockback=1
				Rounds=7
				Size=2
				Distance=2
				RoundMovement=0
				WindUp=0.5
				WindupMessage="focuses the power of wind into their blade!!"
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				EnergyCost=10
				Shocking=1
				Instinct=1
				ActiveMessage="unleashes a tornado of strikes!"
				verb/Tornado_Rave()
					set category="Skills"
					usr.Activate(src)
			RecklessCharge
				SkillCost=30
				Copyable=3
				NeedsSword=1
				Area="Arc"
				StrScaling=1
				DamageMult=0.5
				Rounds=10
				ChargeTech=1
				ChargeTime=1
				Knockback=1
				Cooldown=140
				Size=1
				Icon='reckless.dmi'
				IconX=-16
				IconY=-16
				EnergyCost=1
				Instinct=1
				ActiveMessage="charges forward while performing countless slashing attacks!"
				verb/Reckless_Charge()
					set category="Skills"
					usr.Activate(src)
			BloodRush
				SkillCost=60
				Copyable=4
				NeedsSword=1
				Area="Arc"
				StrScaling=1
				DamageMult=0.5
				LifeSteal=150
				WindUp=1
				WindupIcon='StormArmor.dmi'
				Rounds=10
				ChargeTech=1
				ChargeTime=1
				Knockback=1
				Cooldown=380
				Size=1
				Icon='reckless.dmi'
				IconX=-16
				IconY=-16
				WindupMessage="infuses their blade with bloodthirst..."
				ActiveMessage="carves through all in their path!"
				verb/Blood_Rush()
					set category="Skills"
					usr.Activate(src)
			SoulCharge
				SkillCost=60
				Copyable=4
				NeedsSword=1
				Area="Arc"
				StrScaling=1
				DamageMult=0.5
				EnergySteal=300
				WindUp=0.5
				WindupIcon='Overdrive.dmi'
				Rounds=15
				ChargeTech=1
				ChargeTime=1
				Knockback=1
				Cooldown=380
				Size=1
				Icon='reckless.dmi'
				IconX=-16
				IconY=-16
				WindupMessage="enchants their weapon with inspiration..."
				ActiveMessage="slices through every opponent in their path!"
				verb/Soul_Charge()
					set category="Skills"
					usr.Activate(src)
			HolyJudgment
				SkillCost=80
				Copyable=5
				NeedsSword=1
				Area="Circle"
				StrScaling=1
				DamageMult=0.5
				Cooldown=300
				Rounds=30
				Size=1
				EnergyCost=10
				Icon='CircleWind.dmi'
				IconX=-32
				IconY=-32
				ActiveMessage="spins for holy justice!"
				verb/Holy_Judgment()
					set category="Skills"
					usr.Activate(src)
			DarkPurge
				SkillCost=80
				Copyable=5
				NeedsSword=1
				Area="Circle"
				StrScaling=1
				DamageMult=0.4
				Cooldown=300
				Rounds=30
				Size=1
				EnergyCost=10
				Icon='CircleWind.dmi'
				IconX=-32
				IconY=-32
				ActiveMessage="spins for cruel vengence!"
				verb/Dark_Purge()
					set category="Skills"
					usr.Activate(src)
			FlashCutter
			CrowdCutter
			JetSlicer

//Tier S

///Eight Gates
			Night_Guy
				Destructive=1

///Saint Seiya
			Pegasus_Meteor_Fist//t5
				CosmoPowered=1
				FlickAttack=1
				Area="Wave"
				StrScaling=1
				DamageMult=11
				Launcher=1
				Distance=4
				Rush=10
				RushDelay=0.5
				ControlledRush=0
				GuardBreak=1
				PassThrough=1
				Knockback=0
				Cooldown=150
				WindUp=1
				WindupIcon=1
				WindupMessage="extends their arms and draws out the Pegasus constellation..."
				ActiveMessage="unleashes the god-defying barrage of Pegasus!"
				HitSparkIcon='Hit Effect Pegasus.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=0.8
				HitSparkCount=20
				HitSparkDispersion=24
				HitSparkDelay=1
				verb/Pegasus_Ryusei_Ken()
					set category="Skills"
					usr.Activate(src)
			Unicorn_Gallop//t5
				CosmoPowered=1
				FlickAttack=1
				Area="Wave"
				StrScaling=1
				DamageMult=11
				Launcher=1
				Distance=4
				Rush=10
				RushDelay=0.5
				ControlledRush=0
				GuardBreak=1
				PassThrough=1
				Knockback=0
				SpeedStrike = 1
				Cooldown=150
				WindUp=1
				WindupIcon=1
				WindupMessage="extends their arms and draws out the Unicorn constellation..."
				ActiveMessage="unleashes the god-defying barrage of the Unicorn with their legs!"
				HitSparkIcon='Hit Effect Pegasus.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=0.8
				HitSparkCount=20
				HitSparkDispersion=24
				HitSparkDelay=1
				verb/Unicorn_Gallop()
					set category="Skills"
					usr.Activate(src)
			Enraged_Dragon_Force
				CosmoPowered=1
			Aurora_Thunder_Attack
				CosmoPowered=1
				FlickAttack=1
				Area="Wave"
				ForScaling=1
				DamageMult=11
				Freezing=1
				Stasis=10
				Distance=12
				Slow=1
				GuardBreak=1
				Knockback=0.000001
				Cooldown=150
				WindUp=0.1
				WindupIcon=1
				WindupMessage="strikes towards the sky, filling the area with frigid aura!"
				PreShockwave=1
				PreShockwaveDelay=9
				Shockwaves=3
				Shockwave=5
				ShockIcon='fevKiaiG.dmi'
				PostShockwave=0
				ActiveMessage="unleashes a freezing blast of Swan's power!"
				HitSparkIcon='Hit Effect Pearl.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=5
				HitSparkDispersion=1
				TurfStrike=1
				TurfShift='IceGround.dmi'
				TurfShiftDuration=180
				verb/Aurora_Thunder_Attack()
					set category="Skills"
					usr.Activate(src)
			Phoenix_Rising_Wing
				CosmoPowered=1
				FlickAttack=1
				Area="Wave"
				GuardBreak=1
				DamageMult=11
				Scorching=1
				Knockback=1
				Distance=15
				StrScaling=1
				ForScaling=1
				WindUp=0.5

				Rush = 10
				ControlledRush = 0
				WindupIcon=1
				Slow=1
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=0
				HitSparkSize=0.8
				HitSparkCount=1
				HitSparkDelay=1
				HitSparkDispersion=16
				Hurricane="/obj/Skills/Projectile/Phoenix_Wing"
				HurricaneDelay=0.5
				Cooldown=150
				WindupMessage="conjures scorching winds around their arms..."
				ActiveMessage="unleashes the destructive wingbeat of a Phoenix!"
				verb/Phoenix_Rising_Wing()
					set name="Houyoku Tenshou"
					set category="Skills"
					usr.Activate(src)
			Mighty_Horn
				CosmoPowered = 1
				CanBeDodged = 0
				FlickAttack=1
				Area = "Wave"
				Stunner=3
				DamageMult=11
				Cooldown=120
				StrScaling=1
				ForScaling=0
				Cooldown=120
				UnarmedOnly=1
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=0
				HitSparkSize=0.8
				HitSparkCount=1
				HitSparkDelay=1
				HitSparkDispersion=16
				WindupMessage="'s horn blazes with Cosmos!"
				ActiveMessage="launches forwards to impale their opponents upon their horn!"
				verb/Mighty_Horn()
					set name="Mighty Unicorn Horn"
					set category="Skills"
					usr.Activate(src)
////Gold Cloth
			Starlight_Extinction
				CosmoPowered=1
				FlickAttack=2
				SpecialAttack=1
				Area="Target"
				GuardBreak=1
				WarpAway=4
				DamageMult=16
				Distance=5
				StrScaling=0
				ForScaling=1
				WindUp=2
				WindupIcon=1
				HitSparkIcon='AvalonLight.dmi'
				HitSparkX=-67
				HitSparkY=-3
				HitSparkSize=1
				HitSparkTurns=0
				HitSparkDelay=0
				HitSparkLife=50
				HitSparkDispersion=0
				Shockwaves=2
				Shockwave=1
				PreShockwave=1
				PostShockwave=0
				ShockIcon='KenShockwaveGold.dmi'
				ShockTime=4
				ShockBlend=2
				Cooldown=-1
				WindupMessage="focuses their telekinetic Cosmo to bend space to their whim..."
				ActiveMessage="casts their target away!"
				verb/Starlight_Extinction()
					set category="Skills"
					usr.Activate(src)
			Another_Dimension
				CosmoPowered=1
				FlickAttack=2
				SpecialAttack=1
				Area="Arc"
				GuardBreak=1
				WarpAway=1
				DamageMult=16
				Distance=7
				StrScaling=0
				ForScaling=1
				WindUp=1.5
				WindupIcon=1
				HitSparkIcon='Dimension Aura.dmi'
				HitSparkX=0
				HitSparkY=0
				HitSparkTurns=0
				HitSparkSize=2
				HitSparkCount=5
				HitSparkDelay=1
				HitSparkDispersion=32
				TurfShift='StarPixel.dmi'
				Cooldown=-1
				WindupMessage="focuses their Cosmo to disturb the dimensions..."
				ActiveMessage="opens up a rift to another world!"
				verb/Another_Dimension()
					set name="Another Dimension"
					set category="Skills"
					usr.Activate(src)
			Praesepe_Underworld_Waves
				CosmoPowered=1
				Area="Target"
				Distance=15
				StrScaling=0
				ForScaling=1
				DamageMult=15
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				GuardBreak=1
				WarpAway=3
				Shockwaves=6
				Shockwave=1
				PreShockwave=1
				PostShockwave=0
				ShockIcon='KenShockwaveGod.dmi'
				ShockTime=24
				ShockBlend=2
				WindUp=1
				WindupIcon=1
				WindupMessage="focuses their Cosmo into a wave of otherworldly energy..."
				ActiveMessage="casts out the souls of their targets into the antechamber of Underworld!"
				Cooldown=-1
				verb/Praesepe_Underworld_Waves()
					set name="Sekishiki Meikai Ha"
					set category="Skills"
					usr.Activate(src)
			Lightning_Plasma_Burst
				CosmoPowered=1
				FlickAttack=2
				Distance=8
				Slow=1
				Launcher=1
				Stunner=3
				Rounds=5
				RoundMovement=0
				DelayTime=1
				Area="Arc"
				StrScaling=1
				ForScaling=1
				DamageMult=11
				GuardBreak=1
				TurfStrike=1
				HitSparkIcon='LightningPlasma.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=1
				HitSparkTurns=1
				HitSparkCount=2
				HitSparkDelay=2
				HitSparkDispersion=32
				Cooldown=150
				WindUp=1
				WindupIcon=1
				Rush=3
				ControlledRush=0
				WindupMessage="focuses Cosmo into their fist..."
				ActiveMessage="unleashes billion strikes in a second, creating a cage of light!"
				verb/Lightning_Plasma_Burst()
					set name="Lightning Plasma (Burst)"
					set category="Skills"
					usr.Activate(src)
			Demon_Pacifier
				CosmoPowered=1
				GodPowered=0.25
				RoundMovement=0
				SpecialAttack=1
				Area="Circle"
				GuardBreak=1
				DamageMult=11
				Distance=6
				Knockback=10
				DelayTime=5
				StrScaling=0
				ForScaling=1
				WindUp=1
				WindupIcon=1
				PreShockwave=1
				Shockwaves=3
				Shockwave=5
				ShockIcon='fevKiaiDS.dmi'
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=0
				HitSparkSize=0.8
				HitSparkCount=20
				HitSparkDelay=1
				HitSparkDispersion=16
				WindupMessage="utters a mantra, focusing their Cosmo..."
				ActiveMessage="presents their full majesty to the unworthy!"
				Cooldown=150
				verb/Demon_Pacifier()
					set category="Skills"
					set name="Tenma Kofuku"
					if(usr.SagaLevel<5 && usr.HealthPct()>15 && !usr.InjuryAnnounce)
						usr << "You can't use this technique except when in a dire pinch!"
						return
					usr.Activate(src)
			Heavenly_Ring_Dance
				CosmoPowered=1
				NoAttackLock=1
				SpecialAttack=1
				Area="Target"
				GuardBreak=1
				DamageMult=7
				Distance=10
				Knockback=15
				StrScaling=0
				ForScaling=1
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=0
				HitSparkSize=1
				HitSparkCount=30
				HitSparkDelay=1
				HitSparkDispersion=32
				ActiveMessage="banishes their opponent from their presence!"
			Heavenly_Ring_Dance_Burst
				CosmoPowered=1
				NoAttackLock=1
				SpecialAttack=1
				Area="Circle"
				GuardBreak=1
				DamageMult=10
				Distance=6
				Stunner=4
				Knockback=15
				StrScaling=0
				ForScaling=1
				WindUp=1
				WindupIcon=1
				PreShockwave=1
				PostShockwave=0
				Shockwaves=1
				Shockwave=5
				ShockIcon='KenShockwaveGold.dmi'
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=0
				HitSparkSize=1
				HitSparkCount=30
				HitSparkDelay=1
				HitSparkDispersion=32
				ActiveMessage="cripples and banishes the unworthy from their presence!"
			Restriction
				CosmoPowered=1
				SpecialAttack=1
				Area="Circle"
				Distance=15
				StrScaling=0
				ForScaling=1
				DamageMult=12
				Shockwaves=4
				Shockwave=5
				PreShockwave=1
				PostShockwave=0
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				Stunner=2
				Crippling=15
				ShockIcon='KenShockwaveBloodlust.dmi'
				ShockTime=24
				ShockBlend=2
				WindUp=1
				WindupIcon=1
				WindupMessage="focuses their Cosmo into a wave of pure intimidation..."
				ActiveMessage="wraps their victims in their threatening Cosmo, paralyzing their bodies."
				Cooldown=150
				verb/Restriction()
					set category="Skills"
					usr.Activate(src)
			Sacred_Sword_Excalibur
				CosmoPowered=1
				GodPowered=0.25
				NeedsSword=1
				Area="Wave"
				TurfShift='Seiken2.dmi'
				TurfShiftLayer=4
				TurfShiftDuration=10
				TurfShiftDurationSpawn=-5
				TurfShiftDurationDespawn=10
				GuardBreak=1
				DamageMult=15
				MaimStrike=5
				Distance=10
				Cooldown=-1
				StrScaling=1
				ForScaling=1
				SpecialAttack=1
				Slow=0
				StopAtTarget=0
				WindUp=1
				WindupIcon=1
				WindupMessage="focuses their Cosmo as they slowly raise their arm..."
				ActiveMessage="unleashes the power of the Legendary Exalibur, parting everything before them!"
				verb/Sacred_Sword_Excalibur()
					set category="Skills"
					if(usr.SagaLevel<5 && usr.HealthPct()>15 && !usr.InjuryAnnounce)
						usr << "You can't use this technique except when in a dire pinch!"
						return
					usr.Activate(src)
			Ice_Coffin
				CosmoPowered=1
				SpecialAttack=1
				Distance=10
				Area="Target"
				GuardBreak=1
				DamageMult=5
				StrScaling=1
				Stasis=30
				HitSparkIcon='Hit Effect Pearl.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=5
				HitSparkCount=9
				HitSparkDispersion=1
				WindUp=1
				WindupIcon=1
				WindupMessage="focuses Cosmo at the tip of their finger..."
				ActiveMessage="encases their target in a coffin of unbreakable ice!"
				Cooldown=150
				verb/Ice_Coffin()
					set category="Skills"
					usr.Activate(src)
			Bloody_Rose
				CosmoPowered=1
				SpecialAttack=1
				Distance=30
				Area="Target"
				GuardBreak=1
				DamageMult=0
				ForScaling=1
				HitSparkIcon='Hit Effect Pearl.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=0.5
				HitSparkDispersion=0
				WindUp=1
				WindupIcon=1
				MortalBlow=1
				WindupMessage="focuses their Cosmo on a brilliantly white rose..."
				ActiveMessage="casts the rose at their target, unavoidably stabbing their heart!"
				Cooldown=-1
				verb/Bloody_Rose()
					set category="Skills"
					usr.Activate(src)

///King of Braves
			Hell_And_Heaven
				Area="Circle"
				DamageMult=2.7
				Rounds=10
				ChargeTech=1
				StrScaling=1
				ForScaling=1
				Rush=10
				SpecialAttack=1
				Hurricane="/obj/Skills/Projectile/King_of_Braves/Brave_Tornado"
				GuardBreak=1
				ComboMaster=1
				Grapple=1
				GrabTrigger="/obj/Skills/Grapple/Erupting_Burning_Finger/Removeable"
				Knockback=1
				WindUp=1
				GrabMaster=1
				WindupIcon='GaoGaoFists.dmi'
				WindupMessage="begins gathering the forces of Destruction and Creation in their hands!"
				ActiveMessage="rushes in for the certain kill!"
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkDispersion=1
				HitSparkTurns=1
				HitSparkSize=1
				HitSparkCount=1
				Cooldown=-1
				EnergyCost=12
				verb/Hell_And_Heaven()
					set category="Skills"
					if(usr.SagaLevel>5)
						src.DamageMult=3.6
						src.ControlledRush=0
						WindupMessage="combines the forces of Destruction and Creation with absolute control!"
					usr.Activate(src)
			Goldion_Hammer
				StrScaling=1
				ForScaling=1
				DamageMult=33.75
				Area="Circle"
				Distance=5
				TurfErupt=2
				TurfEruptOffset=3
				Slow=1
				WindUp=2
				WindupIcon='GGG_Hammer.dmi'
				WindupIconX=-16
				WindupIconY=-16
				Divide=1
				Knockback=25
				WindupMessage="spawns in a hammer of immense size!"
				ActiveMessage="unleashes a single hammer strike that devastates everything nearby!"
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				Cooldown=-1
				EnergyCost=12
				Earthshaking=15
				verb/Goldion_Hammer()
					set category="Skills"
					usr.Activate(src)


///Sharingan
			Sharingan_Genjutsu
				Area="Arc"
				DamageMult=2
				Distance=10
				DelayTime=0
				Stunner=2
				EnergyCost = 2
				HitSparkIcon='BLANK.dmi'
				ActiveMessage="'s tomoes slowly spin as they trap their opponent into a genjutsu!"
				Cooldown=90
				BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/MSDebuff/Genjutsu"
				adjust(mob/p)
					if(!altered)
						DamageMult = 2 + p.SagaLevel * 1.5
						Cooldown = clamp(90 - (p.SagaLevel * 10), 30, 90)
						Stunner = round(2 + (p.SagaLevel/3))
				verb/Genjutsu()
					set name = "Sharingan: Genjutsu"
					set category="Skills"
					adjust(usr)
					usr.Activate(src)
			Tsukiyomi
				Area="Arc"
				ForScaling=1
				DamageMult=18
				Distance=10
				AllOutAttack=1
				DelayTime=0
				OffTax = 0.02
				DefTax = 0.02
				GuardBreak=1
				Stunner=6
				Shattering = 50
				EnergyCost = 30
				HitSparkIcon='BLANK.dmi'
				ActiveMessage="aims to trap their opponent in a powerful illusion with a single glance!"
				Cooldown=-1
				BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/MSDebuff/Seishinkai_to_Yami"
				verb/Tsukiyomi()
					set category="Skills"
					if(usr.SagaLevel>=5)
						OffTax = 0
						DefTax = 0
					usr.Activate(src)
			Amaterasu
				StrScaling=1
				ForScaling=1
				DamageMult=13
				Scorching=1
				Toxic=1
				Area="Around Target"
				OffTax = 0.01
				DefTax = 0.01
				CanBeBlocked=0
				CanBeDodged=0
				Distance=7
				DistanceAround=3
				HitSparkIcon='Hit Effect Dark.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=4
				HitSparkCount=4
				HitSparkDispersion=4
				TurfStrike=1
				TurfShift='amaterasu.dmi'
				TurfShiftDuration=90
				Cooldown=200
				WoundCost=15
				BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/MSDebuff/Busshitsukai_to_Hikari"
				ActiveMessage="aims to incinerate their opponents in an ebony pyre!"
				adjust(mob/p)
					var/sagaLevel = p.SagaLevel
					if(altered) return
					if(p.SagaLevel>=5)
						OffTax = 0
						DefTax = 0
					DarknessFlame = 0.25 + (sagaLevel/8)
					Scorching = 8 + sagaLevel
					Toxic = 8 + sagaLevel
					DamageMult = 4 + (sagaLevel*2)
					WoundCost = 25 - sagaLevel * 2
				verb/Amaterasu()
					set category="Skills"
					if(usr.SagaLevel>=5)
						WoundCost=0
						EnergyCost=20
					usr.Activate(src)
			Amaterasu2
				StrScaling=0
				ForScaling=1
				DamageMult=12
				Scorching=5
				Toxic=5
				Area="Around Target"
				OffTax = 0.02
				DefTax = 0.02
				CanBeBlocked=0
				CanBeDodged=0
				Distance=7
				DistanceAround=2
				HitSparkIcon='Hit Effect Dark.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=4
				HitSparkCount=4
				HitSparkDispersion=4
				TurfStrike=1
				TurfShift='amaterasu.dmi'
				TurfShiftDuration=90
				Cooldown=180
				WoundCost=10
				BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/MSDebuff/Busshitsukai_to_Hikari"
				ActiveMessage="aims to incinerate their opponents in an ebony pyre!"
				adjust(mob/p)
					var/sagaLevel = p.SagaLevel
					if(altered) return
					if(p.SagaLevel>=5)
						OffTax = 0
						DefTax = 0
					DarknessFlame = 1 + (sagaLevel/8)
					Scorching = 10 + sagaLevel
					Toxic = 10 + sagaLevel
					DamageMult = 4 + (sagaLevel*2)
					WoundCost = 18 - sagaLevel * 1.5
				verb/Amaterasu()
					set category="Skills"
					if(usr.SagaLevel>=5)
						WoundCost=0
						EnergyCost=20
					usr.Activate(src)

///Ansatsuken
			Tatsumaki
				UnarmedOnly=1
				Area="Circle"
				StrScaling=1
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				Cooldown=40
				Size=1
				Rush=3
				ControlledRush=0
				IgnoreAlreadyHit=1
				// CanBeBlocked=0
				// CanBeDodged=0
				ComboMaster=1
				StyleNeeded="Ansatsuken"
				proc/alter(mob/player)
					ManaCost = 0
					var/damage = 1 + (2 * player.SagaLevel)
					var/path = player.AnsatsukenPath == "Tatsumaki" ? 1 : 0
					var/rounds = 3
					var/cooldown = 40
					var/launch = 0
					Size = 2
					if(path)
						cooldown = 30
						damage = 2 + (2.5 * player.SagaLevel)
						rounds = 3
						Size = 3
					DamageMult = damage
					Cooldown = cooldown
					Rounds = rounds
					Launcher = launch
				verb/Tatsumaki()
					set category="Skills"
					alter(usr)
					ChargeTech = 1
					ChargeTime=0.75
					usr.Activate(src)
			EX_Tatsumaki
				UnarmedOnly=1
				Area="Circle"
				StrScaling=1
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				Cooldown=150
				ManaCost = 25
				Size=4
				Rush=3
				ControlledRush=3
				IgnoreAlreadyHit=1
				// CanBeBlocked=0
				// CanBeDodged=0
				ComboMaster=1
				ChargeTech = 1
				ChargeTime=0.5
				ActiveMessage="rises high in the air with a terrifying whirlwind of kicks!!"
				StyleNeeded="Ansatsuken"
				adjust(mob/p)
					if(p.AnsatsukenPath == "Tatsumaki")
						Launcher = 3
						Rounds = 8
						DamageMult = 3 + (1.5 * p.SagaLevel)
						Cooldown = 150 - (15 * p.SagaLevel)
					else
						Launcher = 0
						Rounds = 6
						DamageMult = 2 + (1 * p.SagaLevel)
						Cooldown = 150 - (15 * p.SagaLevel)


				verb/EX_Tatsumaki()
					set category="Skills"
					adjust(usr)
					usr.Activate(src)
			ShinkuTatsumaki
				UnarmedOnly=1
				Area="Circle"
				StrScaling=1
				DamageMult=0.8
				Crippling=1
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				Rounds=20
				Cooldown=200
				Size=4
				Distance=3
				ManaCost=75
				Rush=5
				ControlledRush=0
				Launcher=3
				ComboMaster=1
				StyleNeeded="Ansatsuken"
				ActiveMessage="ascends peerlessly, carried on a divine tornado of kicks!!!"
				verb/Shinku_Tatsumaki()
					set category="Skills"
					set name="Shinku-Tatsumaki"
					usr.Activate(src)
			Demon_Armageddon
				UnarmedOnly=1
				Area="Circle"
				StrScaling=1
				Crippling=1
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				Size=2
				Cooldown=10800
				Size=1
				Rush=3
				ControlledRush=0
				Launcher=2
				ComboMaster=1
				StyleNeeded="Ansatsuken"
				verb/Demon_Armageddon()
					set category="Skills"
					set name="Demon Armageddon"
					usr.Activate(src)
			Raging_Demon // Shun goku Satsu, but revamped
				Area="Target"
				SpecialAttack=1
				ComboMaster=1
				Launcher=5
				DamageMult = 1
				Rounds = 16
				StepsDamage = 0.05
				StrScaling=1
				Distance = 10
				Rush=5
				RushDelay=2
				ControlledRush=0
				GuardBreak=1
				PassThrough=1
				Cooldown=-10
				WindUp=1.5
				WindupIcon='BijuuInitial.dmi'
				WindupIconUnder=1
				WindupIconX=-32
				WindupIconY=-32
				WindupMessage="radiates murderous intent!"
				Gravity=5
				HitSparkIcon='Hit Effect Satsui.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=1
				HitSparkCount=2
				HitSparkDispersion=24
				HitSparkDelay=1
				RagingDemonAnimation = 1
				Executor = 10
				proc/update(mob/p)
					var/sagaLevel = p.SagaLevel
					StepsDamage = 0.01 * sagaLevel
					Distance = 5 + sagaLevel
					WindUp = 2 - (sagaLevel*0.2)
					StrScaling = 1 + (sagaLevel * 0.05)

				verb/Raging_Demon()
					set category="Skills"
					set name="Raging Demon"
					update(usr)
					usr.Activate(src)
			Shun_Goku_Satsu
				Area="Target"
				SpecialAttack=1
				StrScaling=1
				DamageMult=7.5
				Distance=5
				Rush=5
				RushDelay=2
				ControlledRush=0
				GuardBreak=1
				FlickAttack=1
				PassThrough=1
				Knockback=0
				Cooldown=1
				WindUp=0.1
				WindupIcon='BijuuInitial.dmi'
				WindupIconUnder=1
				WindupIconX=-32
				WindupIconY=-32
				WindupMessage="radiates murderous intent!"
				ActiveMessage="slides towards their opponent and unleashes a demonic 16-hit combination!!!!"
				HitSparkIcon='Hit Effect Satsui.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=1
				HitSparkCount=16
				HitSparkDispersion=24
				HitSparkDelay=1
				Gravity=5

			Life_Fiber_Weave
				NeedsSword=1
				Area="Arc"
				Distance=3
				StrScaling=1
				DamageMult=0.55
				Shearing = 5
				RoundMovement=0
				ComboMaster=1
				Rounds=10
				Cooldown=15
				EnergyCost=2
				Icon='Nest Slash.dmi'
				IconX=-16
				IconY=-16
				Size=1.5
				HitSparkIcon='SparkleRed.dmi'
				HitSparkTurns=1
				HitSparkSize=1.2
				HitSparkDispersion=1
				TurfStrike=1
				EnergyCost=3
				Instinct=1
				ActiveMessage="flourishes their blade to cut loose a flood of red fibers!"
				verb/Life_Fiber_Weave()
					set name="Life Fiber Weave"
					set category="Skills"
					usr.Activate(src)

//Cybernetics and enchantment
			Gear
				Incinerator
					Area="Wave"
					TurfErupt=1
					GuardBreak=1
					DamageMult=4.5
					Scorching=4
					Distance=10
					Cooldown=60
					StrScaling=0.5
					ForScaling=0.5
					Slow=1
					HitSparkIcon='BLANK.dmi'
					verb/Incinerator()
						set category="Skills"
						usr.Activate(src)
				Freeze_Ray
					Area="Strike"
					HitSparkIcon='Hit Effect Pearl.dmi'
					HitSparkX=-32
					HitSparkY=-32
					HitSparkTurns=1
					HitSparkSize=5
					TurfStrike=1
					TurfShift='IceGround.dmi'
					TurfShiftDuration=180
					GuardBreak=1
					DamageMult=4.5
					Freezing=10
					Stasis=20
					Distance=10
					Cooldown=60
					StrScaling=0.5
					ForScaling=0.5
					Slow=1
					verb/Freeze_Ray()
						set category="Skills"
						usr.Activate(src)
				Integrated
					Integrated=1
					Integrated_Incinerator
						Area="Wave"
						TurfErupt=1
						GuardBreak=1
						DamageMult=4.5
						Scorching=4
						Distance=10
						Cooldown=60
						StrScaling=0.5
						ForScaling=0.5
						Slow=1
						HitSparkIcon='BLANK.dmi'
						verb/Incinerator()
							set category="Skills"
							usr.Activate(src)
					Integrated_Freeze_Ray
						Area="Strike"
						HitSparkIcon='Hit Effect Pearl.dmi'
						HitSparkX=-32
						HitSparkY=-32
						HitSparkTurns=1
						HitSparkSize=5
						TurfStrike=1
						TurfShift='IceGround.dmi'
						TurfShiftDuration=180
						GuardBreak=1
						DamageMult=4.5
						Freezing=10
						Stasis=20
						Distance=10
						Cooldown=60
						StrScaling=0.5
						ForScaling=0.5
						Slow=1
						verb/Freeze_Ray()
							set category="Skills"
							usr.Activate(src)
///Cybernetics
			Cyberize
				Machine_Gun_Flurry
					Area="Circle"
					Distance=1
					StrScaling=1
					ManaCost=2
					DamageMult=0.9
					Launcher = 2
					ComboMaster=1
					Rounds=10
					Rush=25
					ControlledRush=0
					Cooldown=60
					HitSparkIcon='Hit Effect Ripple.dmi'
					HitSparkX=-32
					HitSparkY=-32
					HitSparkTurns=1
					HitSparkSize=0.6
					HitSparkCount=10
					HitSparkDispersion=24
					HitSparkDelay=1
					ActiveMessage="burns their battery to attack in a cybernetic flurry!"
					verb/Machine_Gun_Flurry()
						set category="Skills"
						usr.Activate(src)

///Enchantment

////Nox
			FrostBite
				NoTransplant=1
				Area="Arc"
				ControlledRush=0
				Rush=7
				Distance=1
				StrScaling=0.5
				ForScaling=0.5
				DamageMult=5
				HitSparkIcon='Hit Effect Pearl.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=5
				HitSparkCount=5
				HitSparkDispersion=1
				HitSparkDelay=1
				Cooldown=30
				ActiveMessage="thrusts their hand forward to freeze all within their grasp!"
				Freezing=20
				Stasis=2
				ManaCost=5
				verb/Frost_Bite()
					set category="Skills"
					usr.Activate(src)
			OpticBarrel
				NoTransplant=1
				Area="Target"
				Distance=5
				Cooldown=20
				ForScaling=1
				DamageMult=3
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=1
				HitSparkCount=5
				HitSparkDispersion=1
				HitSparkDelay=1
				ActiveMessage="yells: OPTIC BARREL!"
				ManaCost=5;
				verb/Optic_Barrel()
					set category="Skills"
					usr.Activate(src)
////General
			Giga_Slave
				NoTransplant=1
				ForScaling=1
				SpecialAttack=1
				DamageMult=40
				Area="Around Target"
				Distance=30
				DistanceAround=12
				WindupMessage="begins invoking an all-consuming force of destruction..."
				WindUp=3
				ActiveMessage="unleashes a massive wave of chaotic energies upon their foes!!"
				ManaCost=100
				CapacityCost=80
				Cooldown=10800
				MortalBlow=2
				GuardBreak=1//Can't be dodged or blocked
				Destructive=2
				HitSparkIcon='Hit Effect Dark.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=4
				HitSparkCount=4
				HitSparkDispersion=4
				TurfStrike=1
				TurfShiftLayer=EFFECTS_LAYER
				TurfShiftDuration=-10
				TurfShiftDurationSpawn=0
				TurfShiftDurationDespawn=5
				TurfShift='Gravity.dmi'
				verb/Giga_Slave()
					set category="Skills"
					usr.Activate(src)




mob
	proc
		Activate(var/obj/Skills/AutoHit/Z, ignoreCuck = FALSE, ignoreAttackLock = FALSE, noGCD = FALSE)
			set waitfor = FALSE
			. = TRUE
			if(HeldSkillBlocksAction(Z)) return FALSE
			if(!noGCD && GCDBlocked(Z)) return FALSE
			if(!ignoreCuck)
				if(last_autohit + glob.MACROCHECKTIME > world.time)
					return FALSE
			if(src.passive_handler.Get("Silenced"))
				src << "You can't use [Z] you are silenced!"
				return 0
			if(src.Airborne)
				return FALSE
			if(src.OnMagicalVehicle())
				src << "<font color='red'>You can't use skills while on a magical vehicle!</font>"
				return FALSE
			if(src.passive_handler.Get("HotHundred") || src.passive_handler.Get("Warping") || (src.AttackQueue && src.AttackQueue.Combo))
				Z.while_warping = TRUE
			else
				Z.while_warping = FALSE
			if(Z.Using)//Skill is on cooldown.
				return FALSE
			if(istype(Z, /obj/Skills/AutoHit/I_Want_To_Be_Like_You))
				if(!src.demonDevilTriggerSinMastery())
					src << "You cannot access this power yet."
					return FALSE
			if(!Z.heavenlyRestrictionIgnore && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Autohits"))
				return FALSE
			if(!Z.heavenlyRestrictionIgnore && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("All Skills"))
				return FALSE
			if(!Z.heavenlyRestrictionIgnore && Z.NeedsSword && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Armed Skills"))
				return FALSE
			if(!Z.heavenlyRestrictionIgnore && Z.UnarmedOnly && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Unarmed Skills"))
				return FALSE
			if(!ignoreAttackLock && !src.CanAttack(1.5)&&!Z.NoAttackLock)
				return FALSE
			if(Flying)
				var/obj/Items/check = EquippedFlyingDevice()
				if(istype(check))
					check.ObjectUse(src)
					src << "You are knocked off your flying device!"
			if(Z.Sealed)
				src << "You can't use [Z] it is Sealed!"
				return FALSE
			if(Z.AssociatedGear)
				if(!Z.AssociatedGear.InfiniteUses)
					if(Z.Integrated)
						if(Z.AssociatedGear.IntegratedUses<=0)
							src << "[Z] doesn't have enough power to function!"
							if(src.ManaAmount>=10)
								src << "Your [Z] automatically draws on new power to reload!"
								src.LoseMana(10)
								Z.AssociatedGear.IntegratedUses=Z.AssociatedGear.IntegratedMaxUses
							return FALSE
					else
						if(Z.AssociatedGear.Uses<=0)
							src << "[Z] doesn't have enough power to function!"
							return FALSE
			if(Z.MagicNeeded&&!src.HasLimitlessMagic())
				if(src.HasMechanized()&&src.HasLimitlessMagic()!=1)
					src << "You lack the ability to use magic!"
					return FALSE
				if(src.HasMagicTaken())
					src << "Your mana circuits are too damaged to use magic! (until [time2text(src.MagicTaken, "DDD MMM DD hh:mm:ss")])"
					return FALSE
				if(Z.Copyable>=3||!Z.Copyable)
					if(!src.HasSpellFocus(Z))
						src << "You need a spell focus to use [Z]."
						return FALSE
			Z.adjust(src)
			if(Z.GuardBreak)
				Z.CanBeBlocked=0
				Z.CanBeDodged=0
			else
				if(!Z.CanBeBlocked&&!Z.CanBeDodged)
					if(Z.Area=="Circle"||Z.Area=="Arc")
						Z.CanBeBlocked=1
						Z.CanBeDodged=0
					else//Not circle
						Z.CanBeBlocked=0
						Z.CanBeDodged=1
			if(Z.Area=="Target"||Z.Area=="Around Target")
				if(!src.Target)
					src << "You need a target to use [Z]!"
					return FALSE
				if(src.Target==src)
					src << "You can't target yourself while using [Z]!"
					return FALSE
				if(src.Target.z!=src.z)
					src << "Stop trying to hit [src.Target] from a different dimension!"
					return FALSE
				if(!Z.Rush)//This one doesn't apply to rushes.
					if(get_dist(src, Target) > Z.Distance)
						src << "They're not in range!"
						return FALSE
				if(Z.IsSnowgrave)
					var/savefilefound=file("Saves/Players/[src.Target.ckey]")
					fcopy(savefilefound,"Frozen/Players/[src.Target.ckey]")
					Log("Admin","<font color=blue>[ExtractInfo(src)] put [ExtractInfo(src.Target)] into Stasis with Snowgrave.")
					OMsg(10,"[src.Target] is frozen solid, severing their connection with the world.","<font color=red>[src]([src.key]) faded from existence.")
					fdel("Saves/Players/[src.Target.ckey]")
					del src.Target
					src.RebirthHeroType="Yellow"
					src<<"You have been set along the Path of Tragedy."
					for(var/obj/Skills/AutoHit/Snowgrave/SG in src)
						del SG
				if(Z.HahaWhoops)
					var/disarm_f = GetDisarmedAutoHitDamageFactor(Z)
					if(prob(50))
						src.Target.HealHealth(Z.DamageMult * disarm_f)
						for(var/mob/E in hearers(12,src))
							E<<"<font color=[src.Text_Color]>[src] says: haha whoops."
					else
						src.Target.DoDamage(src.Target, Z.DamageMult * disarm_f)
						for(var/mob/E in hearers(12,src))
							E<<"<font color=[src.Text_Color]>[src] says: Nailed it."
					return
				if(Z.HealthRecovery)
					src.HealHealth(Z.HealthRecoveryValue)
				if(Z.type == /obj/Skills/AutoHit/I_Want_To_Be_Like_You)
					var/iwtl_cd = src.passive_handler && src.passive_handler.Get("Limited Rank-Up") ? 30 : 45
					if(src.Target == src)
						src << "You have nothing to be envious of."
						Z.Cooldown(iwtl_cd)
						return FALSE
					var/last_used = src.Target.last_autohit_used
					if(!last_used || last_used == /obj/Skills/AutoHit/I_Want_To_Be_Like_You)
						src << "You have nothing to be envious of."
						Z.Cooldown(iwtl_cd)
						return FALSE
					var/obj/Skills/AutoHit/copied = new last_used
					src.Activate(copied, TRUE)
					Z.Cooldown(iwtl_cd)
					return FALSE
			if(Z.NeedsHealth)
				if(src.HealthPct()>Z.NeedsHealth*(1-src.HealthCut))
					src << "You can't use [Z] before you're below [Z.NeedsHealth*(1-src.HealthCut)]% health!"
					return FALSE
			if(Z.NeedsSword)
				var/obj/Items/Sword/s=src.EquippedSword()
				if(!s)
					if(!src.HasBladeFisting() && !src.UsingBattleMage())
						src << "You need a sword equipped to use [Z]!"
						return FALSE
			if(Z.ResourceCost)
				var/resourceName = Z.ResourceCost[1]
				var/storage = 0
				var/cost = Z.ResourceCost[2]
				if(resourceName in vars) //AHAHAHA!
					// the cost associated exists
					storage = vars[resourceName]
				else
					if(passive_handler[resourceName])
						storage = passive_handler[resourceName]
				if(cost == 999)
					cost = storage
				else if(cost == 0.5)
					cost = storage/2
				else
					if(storage - cost < 0)
						src << " you need more [resourceName]"
						return FALSE
			if(Z.UnarmedOnly)
				var/obj/Items/Sword/s=src.EquippedSword()
				if(s)
					if(!HasBladeFisting())
						src << "You can't have a sword equipped when using [Z]!  It's an unarmed technique!"
						return FALSE
				if(src.UsingBattleMage())
					src << "You can't use unarmed techniques while using Battle Mage!"
					return FALSE
			if(Z.ABuffNeeded)
				if(!src.ActiveBuff||src.ActiveBuff.BuffName!=Z.ABuffNeeded)
					src << "You have to be in [Z.ABuffNeeded] state to use this!"
					return FALSE
			if(Z.SBuffNeeded)
				if(!src.SpecialBuff||src.SpecialBuff.BuffName!=Z.SBuffNeeded)
					src << "You have to be in [Z.SBuffNeeded] state to use this!"
					return FALSE
			if(Z.StanceNeeded)
				if(src.StanceActive!=Z.StanceNeeded)
					src << "You have to be in [Z.StanceNeeded] stance to use this!"
					return FALSE
			if(Z.StyleNeeded)
				if(src.StyleActive!=Z.StyleNeeded)
					src << "You have to be using [Z.StyleNeeded] style to use this!"
					return FALSE
			if(Z.GateNeeded)
				if(src.GatesActive<Z.GateNeeded)
					src << "You have to open at least Gate [Z.GateNeeded] to use this skill!"
					return FALSE
			if(Z.ClassNeeded)
				var/obj/Items/Sword/s=src.EquippedSword()
				if(s.Class!=Z.ClassNeeded && (istype(Z.ClassNeeded, /list) && !(s.Class in Z.ClassNeeded)))
					src << "You need a [istype(Z.ClassNeeded, /list) ? Z.ClassNeeded[1] : Z.ClassNeeded]-class weapon to use this technique."
					return FALSE
			if(Z.HealthCost)
				if(src.HealthPct()<Z.HealthCost*glob.WorldDamageMult&&!Z.AllOutAttack)
					return FALSE
			if(Z.EnergyCost)
				var/drain = passive_handler["Drained"] ? Z.EnergyCost * (1 + passive_handler["Drained"]/10) : Z.EnergyCost
				if(src.Energy<drain&&!Z.AllOutAttack)
					if(!src.CheckSpecial("One Hundred Percent Power")&&!src.CheckSpecial("Fifth Form")&&!CheckActive("Eight Gates"))
						return FALSE
			if(Z.IsSpell && !src.SpellPreCast(Z))
				return FALSE
			if(Z.ManaCost && !src.HasDrainlessMana() && !Z.AllOutAttack)
				var/drain = Z.ManaCost
				drain *= src.ChakraCostMult(Z) * src.SpellCostMult(Z)
				if(drain <= 0)
					drain = 0.5
				if(!src.TomeSpell(Z))
					if(src.ManaAmount<drain)
						src << "You don't have enough mana to activate [Z]."
						return FALSE
				else
					if(src.ManaAmount<drain*(1-(0.45*src.TomeSpell(Z))))
						src << "You don't have enough mana to activate [Z]."
						return FALSE

			if(Z.FocusShifter)
				src.ActivateFocusShift(Z.FocusShiftType, Z.FocusShiftBoost, Z.FocusShiftTimer, Z.FocusStatIdentity())
			if(Z.CorruptionCost)
				if(Corruption - Z.CorruptionCost < 0)
					src << "You don't have enough Corruption to activate [Z]"
					return FALSE
			if(Z.HitSparkIcon)
				src.HitSparkIcon=Z.HitSparkIcon
				src.HitSparkX=Z.HitSparkX
				src.HitSparkY=Z.HitSparkY
				src.HitSparkTurns=Z.HitSparkTurns
				src.HitSparkSize=Z.HitSparkSize
				src.HitSparkCount=Z.HitSparkCount
				src.HitSparkDispersion=Z.HitSparkDispersion
				src.HitSparkDelay=Z.HitSparkDelay
				src.HitSparkLife=Z.HitSparkLife
			Z.ExtendMemory=0
			if(Z.UnarmedOnly&&passive_handler["Gum Gum"])
				Z.ExtendMemory=passive_handler["Gum Gum"]
				Z.Distance+=Z.ExtendMemory
				Z.Size+=Z.ExtendMemory
			if(Z.NeedsSword&&src.HasExtend())
				Z.ExtendMemory=src.GetExtend()
				Z.Distance+=Z.ExtendMemory//Increase distance for this shot...
				Z.Size+=Z.ExtendMemory
			if(src.RippleActive())
				var/BreathCost=Z.DamageMult*10
				if(Z.Rounds)
					BreathCost*=sqrt(Z.Rounds)
				if(src.Oxygen>BreathCost)
					Z.RipplePower*=(1+(0.25*src.GetRipple()*max(1,src.PoseEnhancement*2)))
					Z.DamageMult*=Z.RipplePower
					src.Oxygen-=BreathCost/4
				else if(src.Oxygen >= src.OxygenMax*0.3)
					Z.RipplePower*=(1+(0.125*src.GetRipple()*max(1,src.PoseEnhancement*2)))
					Z.DamageMult*=Z.RipplePower
					src.Oxygen-=BreathCost/6
				else
					src.Oxygen-=BreathCost/8
			if(Z.EndsGetsuga)
				var/obj/Skills/Buffs/SpecialBuffs/A = src.findOrAddSkill(/obj/Skills/Buffs/SpecialBuffs/Sword/Getsuga_Tenshou_Clad)
				var/baseDamageMult = initial(Z.DamageMult)
				Z.DamageMult = baseDamageMult + ((60 - A.Timer) / 5.45)
				if(src.Oxygen<=0)
					src.Oxygen=0
			if(Z.OffTax)
				src.AddOffTax(Z.OffTax)
			if(Z.DefTax)
				src.AddDefTax(Z.DefTax)
			if(!Z.NoLock)
				src.AutoHitting=1
			var/turf/TrgLoc
			last_autohit = world.time
			if(Z.type != /obj/Skills/AutoHit/I_Want_To_Be_Like_You)
				last_autohit_used = Z.type
			if(Z.Area=="Around Target"||Z.Area=="Target")
				TrgLoc=src.Target.loc
			if(Z.CustomCharge)
				OMsg(src, "[Z.CustomCharge]")
			else
				if(Z.WindupMessage)
					OMsg(src, "<b><font color='[Z.WindupColor]'>[src] [Z.WindupMessage]</font color></b>")
					if(Z.PlatinumMad)
						for(var/mob/E in hearers(12,src))
							E << output("<font color=[src.Text_Color]>[src.name]: <b>GOD FUCKING DAMN IIIIIIIIIIIIIIIIT!</b></font>", "output")
			if(src.TomeSpell(Z))
				Z.Cooldown(1, null, src)
			else
				Z.Cooldown(1, null, src)
			if(Z.RushProjImmune)
				src.proj_immune_until = world.time + Z.RushProjImmune
			if(Z.RushTally)
				Z.rush_passed_mobs = list()
			if(Z.Copyable)
				var/copy = Z.Copyable
				spawn() for(var/mob/m in view(40, src))
					if(m.CheckSpecial("A - The Almighty"))
						var/insightLevel = m.AscensionsAcquired+25 || 1
						var/techTier = Z.Copyable
						if(insightLevel < techTier)
							continue
						if(m.client && m.client.address == src.client.address)
							continue
						if(!locate(Z.type, m))
							var/obj/Skills/copiedSkill = new Z.type
							m.AddSkill(copiedSkill)
							copiedSkill.Copied = TRUE
							copiedSkill.copiedBy = "The Almighty"
							m << "You understand the nature of the [Z] technique you've just viewed."
				spawn() for(var/mob/m in view(10, src))
					if(m.CheckSpecial("Sharingan"))
						var/copyLevel = getSharCopyLevel(m.SagaLevel)
						if(Z.NewCopyable)
							copy = Z.NewCopyable
						else
							copy = Z.Copyable
						if(copyLevel < copy)
							continue
						if(client&&m.client&&m.client.address==src.client.address)
							continue
						if(!locate(Z.type, m))
							var/obj/Skills/copiedSkill = new Z.type
							m.AddSkill(copiedSkill)
							copiedSkill.Copied = TRUE
							copiedSkill.copiedBy = "Sharingan"
							m << "Your Sharingan analyzes and stores the [Z] technique you've just viewed."
				spawn()
					for(var/obj/Items/Tech/Security_Camera/SC in view(10, src))
						if(Z.PreRequisite.len<1)
							SC.ObservedTechniques["[Z.type]"]=Z.Copyable
			if(Z.PassThrough)
				if(Z.Area=="Strike")
					Z.StopAtTarget=1
			if(Z.FollowUp)
				spawn(Z.FollowUpDelay)
					throwFollowUp(Z.FollowUp)
			if(Z.BuffSelf)
				spawn(Z.BuffSelfDelay)
					src.buffSelf(Z.BuffSelf)
			var/missed = 0 //If the target is out of range at the end of a windup.
			if(Z.WindUp)
				src.Grab_Release()
				if(Z.Float)
					if(!src.pixel_z)
						spawn()
							Jump(src, FloatTime=Z.Float)
						sleep(3)
				if(Z.WindUp>=2)
					src.WindingUp=2
				else
					src.WindingUp=1
				if(Z.WindupIcon)
					if(Z.WindupIcon!=1)
						spawn()
							LeaveImage(src, Z.WindupIcon, Z.WindupIconX, Z.WindupIconY, 0, Z.WindupIconSize, Z.WindupIconUnder, Z.WindUp*10)
					else
						if(!src.AuraLocked&&!src.HasKiControl())
							src.Auraz("Add")
						else
							KenShockwave(src,icon='KenShockwaveFocus.dmi',Size=0.3, Blend=2, Time=2)
						spawn(Z.WindUp*10)
							if(!src.AuraLocked&&!src.HasKiControl())
								src.Auraz("Remove")
				if(Z.Hurricane)
					var/obj/Skills/s = findOrAddSkill(text2path(Z.Hurricane))
					spawn(Z.HurricaneDelay*10)
						src.dir=get_dir(src,src.Target)
						src.UseProjectile(s, noGCD = TRUE)
				else
					spawn()src.WindupGlow(src)
				if(Z.Float||Z.Ice||Z.Thunderstorm||Z.Gravity)
					src.Frozen=1
					if(Z.Float)
						spawn(Z.Float*10)
							src.Frozen=0
					if(Z.Ice)
						spawn()
							for(var/turf/T in Turf_Circle(src.Target, Z.Ice))
								spawn(rand(4,8))new/turf/Ice1(locate(T.x, T.y, T.z))
								spawn(rand(4,8))Destroy(T)
							spawn(10)
								src.Frozen=0
					if(Z.Thunderstorm)
						spawn()
							for(var/turf/t in Turf_Circle(src.Target, Z.Thunderstorm))
								sleep(-1)
								TurfShift('Night.dmi', t, 600, src, MOB_LAYER+1)
								spawn(5)
									sleep(-1)
									TurfShift('Rain.dmi', t, 590, src, MOB_LAYER+0.5)
							spawn(10)
								src.Frozen=0
					if(Z.Gravity)
						spawn()
							var/image/i
							var/turf/adjustedT
							for(var/turf/t in Turf_Circle(src.Target, Z.Gravity))
								if(t.x == Target.x && t.y == Target.y)
									adjustedT = t
								sleep(-1)
								TurfShift('Gravity.dmi', adjustedT, 30, src, MOB_LAYER+1)
							spawn(35)
								if(Z.RagingDemonAnimation)
									i = image('ragingDemonEffect.dmi', Target)
									i.color = rgb(138, 0, 0)
									i.pixel_x = -100
									i.pixel_y = -110
									i.layer = 99
									i.alpha = 155
									Target.vis_contents+=i
							spawn(40)
								if(Z.RagingDemonAnimation)
									Target.vis_contents -= i
									i.loc = null
									del i
								src.Frozen=0
				if(src.HasQuickCast() && !Z.IgnoreWindUpReduction)
					if(Z.PreQuake)
						spawn()
							src.Quake(Second(Z.WindUp/src.GetQuickCast()))
					sleep(Second(Z.WindUp/src.GetQuickCast()))
				else
					if(Z.PreQuake)
						spawn()
							src.Quake(Second(Z.WindUp))
					sleep(Second(Z.WindUp))
				src.WindingUp=0

				if(Z.Area=="Target"||Z.Area=="Around Target")
					if(!src.Target)
						missed=1
					if(src.Target==src)
						missed=1
					if(src.Target.z!=src.z)
						missed=1
					if(!Z.Rush)//This one doesn't apply to rushes.
						if(get_dist(src, Target) > Z.Distance)
							missed=1

			if(Z.CustomActive)
				OMsg(src, "[Z.CustomActive]")
			else
				if(Z.ActiveMessage)
					OMsg(src, "<b><font color='[Z.ActiveColor]'>[src] [Z.ActiveMessage]</font color></b>")
					if(Z.PlatinumMad)
						world<<"<font color=[src.Text_Color]>[src.name]</font>: <font color=red><b>FUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUCK!</b></font>"
			if(passive_handler["AirBend"] && can_use_style_effect("AirBend"))
				flick("KB", Target)
				step_away(Target, src)
				last_style_effect = world.time
			if(src.AttackQueue && !src.AttackQueue.FollowUp && !Z.KeepQueue)
				src << "<b>You drop [src.AttackQueue.name] from your queue.</b>"
				src.QueueOverlayRemove()
				src.ClearQueue()
			if(!Z.Rounds)
				Z.Rounds=1
			if(Z.Rounds<3&&!Z.ChargeTech)
				Z.DelayTime=5
			if(!Z.RoundMovement&&Z.Rounds>1)
				src.Frozen=2

			var/datum/ink_family/ink_fam = new /datum/ink_family(src, Z)
			src.ink_cast = ink_fam
			if(Z.Icon || (Z.Shockwave && (Z.PreShockwave || Z.PostShockwave)))
				ink_fam.cast_art = 1
			if(Z.PreShockwave)
				if(Z.Shockwave)
					spawn()
						var/ShockSize=Z.Shockwave
						if(Z.Shockwaves<1)
							Z.Shockwaves=1
						for(var/wav=Z.Shockwaves, wav>0, wav--)
							var/obj/Effects/KenShockwave/ink_ring = KenShockwave(src, icon=Z.ShockIcon, Size=ShockSize, Blend=Z.ShockBlend, Time=Z.ShockTime)
							if(ink_fam)
								ink_fam.RegisterRing(ink_ring, null, ink_fam.NewGroup())
							ShockSize/=Z.ShockDiminish
				if(Z.PreShockwaveDelay)
					sleep(Z.PreShockwaveDelay)
			if(Z.Icon)
				var/icon/i=Z.Icon
				if(Z.IconRed||Z.IconGreen||Z.IconBlue)
					i+=rgb(Z.IconRed, Z.IconGreen, Z.IconBlue)
				var/Time
				if(Z.ChargeTime)
					Time=Z.ChargeTime
				else
					Time=Z.DelayTime
				if(ink_fam)
					var/ink_time = Z.Rounds*max(1,Time)
					var/ink_size = (Z.Size ? Z.Size : 1) * (src.CheckSlotless("Great Ape") ? 3 : 1)
					if(Z.Area=="Around Target")
						if(TrgLoc)
							var/ink_tpx = src.Target ? src.Target.pixel_x : 0
							var/ink_tpy = src.Target ? src.Target.pixel_y : 0
							var/ink_tpz = src.Target ? src.Target.pixel_z : 0
							ink_fam.RegisterImage(Z.Icon, null, TrgLoc, ink_tpx+Z.IconX, ink_tpy+Z.IconY, Z.Falling ? ink_tpz+16+(32*Z.Rounds/10) : ink_tpz+48, Z.Size ? Z.Size : 1, ink_time, SOUTH, Z.Falling, null, ink_fam.NewGroup())
					else if(!Z.Persistent)
						ink_fam.RegisterImage(Z.Icon, src, null, Z.IconX, Z.IconY, Z.IconZ, ink_size, ink_time, src.dir, 0, null, ink_fam.NewGroup())
				if(Z.Area=="Around Target")
					spawn()
						if(Z.Falling)
							LeaveDescendingImage(User=0, Image=i, PX=src.Target.pixel_x+Z.IconX, PY=src.Target.pixel_y+Z.IconY, PZ=src.Target.pixel_z+16+(32*Z.Rounds/10), Size=Z.Size, Under=Z.IconUnder, Time=(Z.Rounds*max(1,Time)), AltLoc=TrgLoc)
						else
							LeaveImage(User=0, Image=i, PX=src.Target.pixel_x+Z.IconX, PY=src.Target.pixel_y+Z.IconY, PZ=src.Target.pixel_z+48, Size=Z.Size, Under=Z.IconUnder, Time=(Z.Rounds*max(1,Time)), AltLoc=TrgLoc)
				else
					if(Z.Persistent)
						spawn()LeaveImage(User=null, Image=i, PX=src.pixel_x+Z.IconX, PY=src.pixel_y+Z.IconY, PZ=src.pixel_z+Z.IconZ, Size=Z.Size, Under=Z.IconUnder, Time=Z.Duration, AltLoc=TrgLoc)
					else
						spawn()LeaveImage(User=src, Image=i, PX=src.pixel_x+Z.IconX, PY=src.pixel_y+Z.IconY, PZ=src.pixel_z+Z.IconZ, Size=Z.Size, Under=Z.IconUnder, Time=(Z.Rounds*max(1,Time)), AltLoc=0)


			if(Z.Jump)
				if(Z.Jump==1)
					spawn()
						Jump(src)
					sleep(3)
				if(Z.Jump==2)
					spawn()
						Jump(src)
					sleep(5)

			var/Delay=0
			var/DelayRelease=0
			if(Z.Rush)
				src.is_dashing++
				src.WindingUp=1
				Z.rush_bounced = 0
				if(Z.RushTally)
					Z.rush_passed_mobs = list()
				var/GO=Z.Rush
				if(passive_handler["Wolf Spirit"])
					GO=Z.Rush*2
				if(!Z.RushNoFlight)
					src.icon_state="Flight"
				if(Z.RushDelay<1)
					VanishImage(src)
				var/pm = PmActive()
				var/pm_px = Z.RushDelay > 0 ? round(32 / Z.RushDelay) : glob.PM_DASH_MAX_PX
				var/rush_stuck = 0 //a walled dash debits 0 px forever, count dead ticks
				if(HasFastRush())
					Z.RushDelay = min(glob.RUSH_DELAY_MIN, Z.RushDelay / HasFastRush())
				var/obj/AutoHitter/ink_rush = ink_fam ? ink_fam.RushStart() : null
				var/ink_ox = InkWorldX()
				var/ink_oy = InkWorldY()
				while(GO>0)
					if(!Z.RushBounce && src.Target && (Z.ControlledRush || HasControlledRush())) // HasControlledRush is in _BinaryChecks.dm
					//	var/travel_angle = GetAngle(src, src.Target)
						if(length(src.filters) < 1)
							AppearanceOn()
						if(src.filters["trail"]) //dash smear
							var/travel_angle = GetAngle(src, src.Target)
							var/smear = 6 / max(Z.RushDelay, 0.5) //RushDelay 0 would divide by zero
							animate(src.filters["trail"], x=sin(travel_angle)*smear, y=cos(travel_angle)*smear, time=Z.RushDelay)
						var/moved = 0
						if(pm) //one glided step per tick
							moved = src.PmDashStep(src.Target, pm_px)
						else
							step_towards(src,src.Target)
						if(ink_rush)
							ink_rush.dir = src.dir
							InkRushSweep(ink_rush, ink_ox, ink_oy)
						ink_ox = InkWorldX()
						ink_oy = InkWorldY()
						if(Z.RushAfterImages)
							coolerFlashImage(src, Z.RushAfterImages)
						if(Z.RushAIBlue)
							blueFlashImage(src, Z.RushAIBlue)
						if(Z.RushAIOrange)
							orangeFlashImage(src, Z.RushAIOrange)
						if(get_dist(src,src.Target)<=1)
							GO=0
							src.dir=get_dir(src,src.Target)
							if(src.Target.Knockbacked)
								src.Target.Knockbacked=0
								src.Target.Frozen=1
								spawn(3)
									src.Target.Frozen=0
						if(pm && !moved && ++rush_stuck >= 2)
							GO = 0 //blocked rush still has to end
						else if(moved)
							rush_stuck = 0
						GO-=(pm ? moved/32 : 1)*world.tick_lag //debit actual px moved
						if(GO > 0)
							DelayRelease+=Z.RushDelay // HasFastRush is in _BinaryChecks.dm
							if(DelayRelease>=1)
								DelayRelease--
								sleep(1)
					else
						if(length(src.filters) < 1)
							AppearanceOn()
						if(src.filters["trail"])
							var/travel_angle = dir2angle(src.dir)
							var/smear = 6 / max(Z.RushDelay, 0.5)
							animate(src.filters["trail"], x=sin(travel_angle)*smear, y=cos(travel_angle)*smear, time=Z.RushDelay)
						var/moved = 0
						if(Z.RushCarry)
							for(var/mob/cm in get_step(src, src.dir))
								if(cm == src || cm.KO || cm.Stasis || cm.Knockbacked)
									continue
								step(cm, src.dir)
						if(Z.RushTally)
							for(var/mob/pmb in view(1, src))
								if(pmb != src && !pmb.KO)
									Z.rush_passed_mobs |= pmb
						if(pm) //one glided step per tick
							moved = src.PmDashStep(null, pm_px)
						else
							step(src,src.dir)
						if(ink_rush)
							ink_rush.dir = src.dir
							InkRushSweep(ink_rush, ink_ox, ink_oy)
						ink_ox = InkWorldX()
						ink_oy = InkWorldY()
						if(Z.RushAfterImages)
							coolerFlashImage(src, Z.RushAfterImages)
						if(Z.RushAIBlue)
							blueFlashImage(src, Z.RushAIBlue)
						if(Z.RushAIOrange)
							orangeFlashImage(src, Z.RushAIOrange)
						if(Z.Area=="Strike"||Z.Area=="Arc"||Z.Area=="Cone")
							for(var/atom/a in get_step(src,dir))
								if(a==src)
									continue
								if(Z.RushCarry && ismob(a))
									continue
								if(a.density)
									if(Z.RushBounce && !Z.rush_bounced)
										Z.rush_bounced = 1
										rush_stuck = 0
										if(!src.RushWallCling())
											GO=0
									else
										GO=0
						else
							for(var/atom/a in view(1,src))
								if(a==src)
									continue
								if(Z.RushCarry && ismob(a))
									continue
								if(a.density)
									GO=0
						if(pm && !moved && ++rush_stuck >= 2)
							if(Z.RushBounce && !Z.rush_bounced)
								Z.rush_bounced = 1
								rush_stuck = 0
								if(!src.RushWallCling())
									GO = 0
							else
								GO = 0 //blocked rush still has to end
						else if(moved)
							rush_stuck = 0
						GO-= (pm ? moved/32 : 1)*world.tick_lag //debit actual px moved
						if(GO > 0)
							if(pm)
								sleep(world.tick_lag)
							else
								DelayRelease+=Z.RushDelay
								if(DelayRelease>=1)
									DelayRelease--
									sleep(1)
				src.is_dashing--
				if(is_dashing<0)
					is_dashing=0
				src.WindingUp=0
				if(src.filters["trail"]) //only the trail filter has x/y to reset
					animate(src.filters["trail"], x=0, y=0)
				if(src.passive_handler.Get("Prismatic"))
					src.RainbowGlowStuff(TRUE)
				src.icon_state=""
			if(Z.FlickAttack==1)
				flick("Attack",src)
			var/RoundCount=Z.Rounds
			if(Z.RoundsFromPool && Z.IsSpell && Z.Consumes && Z.Consumes.len && src.Target && ismob(src.Target))
				var/mob/_rpt = src.Target
				var/_took = src.SpendSpellPools(Z, _rpt)
				if(!Z.consumed_targets) Z.consumed_targets = list()
				Z.consumed_targets |= _rpt
				Z.rounds_pool_took = _took
				RoundCount = min(Z.RoundsFromPoolMax, RoundCount + round(_took / Z.RoundsFromPool))
			if(Z.MagicNeeded&&src.HasDualCast())
				RoundCount*= 1+ src.HasDualCast()
				RoundCount = floor(RoundCount)
			if(Z.SequenceStrokes > 1)
				RoundCount *= Z.SequenceStrokes
			if(Z.FinaleDouble)
				Z.strokes_landed = 0
				Z.finale_rounds = RoundCount
			if(Z.MashExtend)
				Z.mash_pending = 0
				Z.mash_extends = 0
				Z.flurry_live = world.time + 15
			while(RoundCount>0)
				src.ink_cast = ink_fam
				//if(!src.Target) break
				if(Z.SequenceStrokes > 1 && (src.KO || src.Stunned || src.Stasis))
					break
				if(Z.Earthshaking)
					spawn()
						src.Quake(Z.Earthshaking)
				if(Z.FlickSpin)
					flick("KB",src)
				else if(Z.FlickAttack==2)
					src.icon_state="Attack"
				else if(Z.FlickAttack==3)
					if(RoundCount % 2)
						src.icon_state="Attack"
					else
						src.icon_state=""
				if(Z.FollowTarget && src.Target)
					TrgLoc = src.Target.loc
				if(Z.PassStrikes && src.Target && src.Target != src && !src.Target.KO && src.Target.z == src.z && get_dist(src, src.Target) <= Z.Distance + 1)
					var/pdx = src.x - src.Target.x
					var/pdy = src.y - src.Target.y
					var/pside
					if(abs(pdx) >= abs(pdy))
						pside = (pdx >= 0) ? EAST : WEST
					else
						pside = (pdy >= 0) ? NORTH : SOUTH
					if(RoundCount % 2)
						pside = turn(pside, 180)
					var/turf/pt = get_step(src.Target, pside)
					var/pblocked = !pt || pt.density
					if(!pblocked)
						for(var/atom/movable/pa in pt)
							if(pa.density && pa != src && pa != src.Target)
								pblocked = 1
								break
					if(!pblocked)
						src.loc = pt
						src.step_x = 0
						src.step_y = 0
						coolerFlashImage(src, 1)
					var/fdx = src.Target.x - src.x
					var/fdy = src.Target.y - src.y
					if(abs(fdx) >= abs(fdy))
						src.dir = (fdx >= 0) ? EAST : WEST
					else
						src.dir = (fdy >= 0) ? NORTH : SOUTH
				if(Z.EraseProjectiles)
					var/atom/ecenter = (src.Target && src.Target.z == src.z) ? src.Target : src
					for(var/obj/Skills/Projectile/_Projectile/ep in view(max(Z.DistanceAround, 3), ecenter))
						if(ep.Owner == src || ep.Killed || !ep.loc)
							continue
						if(ep.Owner && src.inParty(ep.Owner.ckey))
							continue
						if(ep.beam_owner)
							ep.beam_owner.Die()
						else if(ep.Area == "Beam")
							ep.Killed = 1
							ep.Distance = 0
							ep.clash_lock = null
							ep.clash_victor = 0
							ep.clash_pierce = null
							ep.endLife()
						else
							ep.Killed = 1
							ep.ProjectileFinish()
						if(Z.IsSpell)
							src.PayEventRefund(Z, "erase", 1)
				if(Z.IsSpell)
					Z.OnRound(src, RoundCount)
				switch(Z.Area)
					if("Strike")
						src.Strike(Z)
					if("Arc")
						src.Arc(Z)
					if("Cone")
						src.Cone(Z)
					if("Cross")
						src.Cardinal(Z)
					if("Wave")
						src.Wave(Z)
					if("Wide Wave")
						src.WideWave(Z)
					if("Wider Wave")
						src.WiderWave(Z)
					if("Circle")
						if(Z.Persistent)
							src.Persistent(Z, Z.Duration)
						else
							src.Circle(Z)
					if("Target")
						if(Target)
							if(get_dist(src, Target) > Z.Distance)
							// if(src.x+Z.Distance<src.Target.x||src.x-Z.Distance>src.Target.x||src.y+Z.Distance<src.Target.y||src.y-Z.Distance>src.Target.y)
								missed=1
							src.Target(src.Target, Z, missed ? TrgLoc : null)
						else
							missed = 1
						if(missed) src << "[Z] missed because your target is out of range."
					if("Around Target")
						src.AroundTarget(null, Z, TrgLoc)
				if(Z.Persistent)
					src.Persistent(Z, Z.Duration)
				if(Z.ChargeTime)
					Delay=Z.ChargeTime
				else
					Delay=Z.DelayTime
				if(Z.PostShockwave)
					if(Z.Shockwave)
						spawn()
							var/ShockSize=Z.Shockwave
							if(Z.Shockwaves<1)
								Z.Shockwaves=1
							for(var/wav=Z.Shockwaves, wav>0, wav--)
								var/obj/Effects/KenShockwave/ink_ring = KenShockwave(src, icon=Z.ShockIcon, Size=ShockSize, Blend=Z.ShockBlend, Time=Z.ShockTime)
								if(ink_fam)
									ink_fam.RegisterRing(ink_ring, null, ink_fam.NewGroup())
								ShockSize/=2
				if(Z.ChargeTech)
					src.Frozen=1
					if(Z.ChargeFlight)
						src.icon_state="Flight"
					DelayRelease+=Delay
					if(DelayRelease>=1)
						DelayRelease--
						sleep(1)
					if(Z.RushCarry)
						for(var/mob/cm in get_step(src, src.dir))
							if(cm == src || cm.KO || cm.Stasis || cm.Knockbacked)
								continue
							step(cm, src.dir)
					if(Z.RushTally && Z.rush_passed_mobs)
						for(var/mob/pmb in view(1, src))
							if(pmb != src && !pmb.KO)
								Z.rush_passed_mobs |= pmb
					if(PmActive()) //glided full-tile step
						src.PmDashStep(null, 32)
					else
						step(src, src.dir)
				else
					sleep(Delay)
				RoundCount--
				if(Z.MashExtend && Z.mash_pending > 0)
					RoundCount += Z.mash_pending
					Z.mash_pending = 0
					Z.flurry_live = world.time + 15
				if(Z.MashExtend && RoundCount <= 0)
					while(world.time < Z.flurry_live && Z.mash_pending <= 0 && !src.KO && !src.Stunned && !(src.Stasis > 0))
						sleep(1)
					if(Z.mash_pending > 0)
						RoundCount += Z.mash_pending
						Z.mash_pending = 0
						Z.flurry_live = world.time + 15
			if(Z.RecoveryLock > 0)
				sleep(Z.RecoveryLock)
			src.ClearTech(Z)

		ClearTech(var/obj/Skills/AutoHit/Z)//Used to resolve any variable conflicts at the end of an autohit
			if(src.ink_cast && src.ink_cast.Z == Z)
				if(src.ink_cast.rush_root)
					src.ink_cast.RushEnd()
				src.ink_cast = null
			if(Z.IsSpell)
				Z.OnRoundsDone(src)
			if(Z.MashExtend)
				Z.flurry_live = 0
				Z.mash_pending = 0
			var/CostMultiplier=1
			var/obj/Items/Sword/sord=src.EquippedSword()
			var/obj/Items/Enchantment/Staff/staf=src.EquippedStaff()
			var/obj/Items/Armor/WearingArmor=src.EquippedArmor()
			if(Z.NeedsSword&&sord)
				CostMultiplier/=src.GetSwordDelay(sord)
			if(Z.SpecialAttack&&staf)
				CostMultiplier/=src.GetStaffDrain(staf)
			if(src.UsingBattleMage()&&Z.NeedsSword)
				CostMultiplier/=src.GetStaffDrain(staf)
			if(WearingArmor)
				CostMultiplier/=src.GetArmorDelay(WearingArmor)
			else if(Z.SpecialAttack&&sord&&sord.MagicSword)
				CostMultiplier*=src.GetSwordDelay(sord)
			if(src.Frozen!=3)
				src.Frozen=0
			if(Z.EndsGetsuga)
				var/obj/Skills/Buffs/SpecialBuffs/A = src.findOrAddSkill(/obj/Skills/Buffs/SpecialBuffs/Sword/Getsuga_Tenshou_Clad)
				A.Trigger(src, 1)
				src << "The power of Getsuga fades from your weapon."
				Z.DamageMult = initial(Z.DamageMult)
			if(Z.UsesinForce)
				Z.DamageMult += (src.inForceAmp() / 100)
				src.passive_handler.Set("AlphainForce", 0)
			if(Z.ChargeFlight)
				src.icon_state=""
			if(Z.HitSparkIcon)
				src.HitSparkIcon=null
				src.HitSparkX=null
				src.HitSparkY=null
				src.HitSparkTurns=null
				src.HitSparkSize=null
				src.HitSparkCount=null
				src.HitSparkDispersion=null
				src.HitSparkDelay=null
				src.HitSparkLife=null
			if(Z.HealthCost)
				src.DoDamage(src, src.PctToHP(Z.HealthCost*CostMultiplier*glob.WorldDamageMult))
			if(Z.PlatinumMad)
				src.DoDamage(src, src.PctToHP(9001))
			if(Z.WoundCost)
				src.WoundSelf(Z.WoundCost*CostMultiplier*glob.WorldDamageMult)
			if(Z.EnergyCost)
				var/drain = passive_handler["Drained"] ? Z.EnergyCost * (1 + passive_handler["Drained"]/10) : Z.EnergyCost
				src.LoseEnergy(drain*CostMultiplier)
			if(Z.FatigueCost)
				src.GainFatigue(Z.FatigueCost*CostMultiplier)
			if(Z.ManaCost)
				var/drain = Z.ManaCost
				drain *= src.ChakraCostMult(Z) * src.SpellCostMult(Z)
				if(drain <= 0)
					drain = 0.5
				if(Z.ManaCostAll)
					drain = src.ManaAmount
					src.LoseMana(drain, 1)
				else if(!src.TomeSpell(Z))
					src.LoseMana(drain*CostMultiplier)
				else
					src.LoseMana(drain*CostMultiplier*(1-(0.45*src.TomeSpell(Z))))
				if(Z.CorruptionGain)
					var/gain = drain*CostMultiplier / 1.5
					gainCorruption(gain * glob.CORRUPTION_GAIN)
			if(Z.CorruptionCost)
				gainCorruption(-Z.CorruptionCost)

			if(Z.CapacityCost)
				src.LoseCapacity(Z.CapacityCost*CostMultiplier)
			if(Z.UnarmedOnly&&passive_handler["Gum Gum"])
				Z.Distance-=Z.ExtendMemory
				Z.Size-=Z.ExtendMemory
			if(Z.NeedsSword&&Z.ExtendMemory)
				Z.Distance-=Z.ExtendMemory//...then take the distance away.
				Z.Size-=Z.ExtendMemory
			if(Z.RoundMovement&&Z.Rounds>1)
				src.Frozen=0
			if(Z.Attracting)
				src.Attracting-=Z.Attracting
			if(src.RippleActive())
				Z.DamageMult/=Z.RipplePower
				Z.RipplePower=1
			if(Z.OldHitSpark)
				Z.HitSparkIcon=Z.OldHitSpark
				Z.HitSparkX=Z.OldHitSparkX
				Z.HitSparkY=Z.OldHitSparkY
				Z.HitSparkTurns=Z.OldHitSparkTurns
				Z.HitSparkSize=Z.OldHitSparkSize
				Z.OldHitSpark=0
				Z.OldHitSparkX=0
				Z.OldHitSparkY=0
				Z.OldHitSparkTurns=0
				Z.OldHitSparkSize=0
			if(!Z.NoLock)
				src.AutoHitting=0
			if(Z.FlickSpin||Z.FlickAttack)
				src.icon_state=""
			if(Z.GrabTrigger)
				var/path=text2path(Z.GrabTrigger)
				if(!locate(path, src))
					src.AddSkill(new path)
				src.Grab_Update()
				if(src.Grab)
					for(var/obj/Skills/g in src.Skills)
						if(g.type == path)
							throwSkill(g)
							break
			if(Z.AssociatedGear)
				if(!Z.AssociatedGear.InfiniteUses)
					if(Z.Integrated)
						Z.AssociatedGear.IntegratedUses--
						if(Z.AssociatedGear.IntegratedUses<=0)
							src << "Your [Z] is out of power!"
							if(src.ManaAmount>=10)
								src << "Your [Z] automatically draws on new power to reload!"
								src.LoseMana(10)
								Z.AssociatedGear.IntegratedUses=Z.AssociatedGear.IntegratedMaxUses
					else
						Z.AssociatedGear.Uses--
						if(Z.AssociatedGear.Uses<=0)
							src << "[Z] is out of power!"



mob
	proc
		Persistent(var/obj/Skills/AutoHit/AH, duration)
			new/obj/AutoHitter(owner = src, Z = AH, life = duration, circle = 1, TrgLoc = src.loc)



		AutoHitter(var/arc, var/wav, var/car, var/circ, var/mob/targ, var/obj/Skills/AutoHit/z, var/turf/trfloc=null)
			if(src.dir == SOUTHEAST || src.dir==NORTHEAST)
				src.dir=EAST
			if(src.dir==SOUTHWEST || src.dir==NORTHWEST)
				src.dir=WEST
			return new/obj/AutoHitter(owner=src, arcing=arc, wave=wav, card=car, circle=circ, target=targ, Z=z, TrgLoc=trfloc)

		Strike(var/obj/Skills/AutoHit/Z)
			src.AutoHitter(0, 0, 0, 0, null, Z)

		Arc(var/obj/Skills/AutoHit/Z)
			src.AutoHitter(1, 0, 0, 0, null, Z)

		Cone(var/obj/Skills/AutoHit/Z)
			src.AutoHitter(round(Z.Distance/5), 0, 0, 0, null, Z)

		Wave(var/obj/Skills/AutoHit/Z)
			src.AutoHitter(0, 1, 0, 0, null, Z)

		WideWave(var/obj/Skills/AutoHit/Z)
			src.AutoHitter(0, 2, 0, 0, null, Z)

		WiderWave(var/obj/Skills/AutoHit/Z)
			src.AutoHitter(0, 3, 0, 0, null, Z)

		Cardinal(var/obj/Skills/AutoHit/Z)
			src.AutoHitter(0, 0, 1, 0, null, Z)

		Circle(var/obj/Skills/AutoHit/Z)
			return src.AutoHitter(0, 0, 0, 1, null, Z)

		Target(var/mob/trg, var/obj/Skills/AutoHit/Z, var/turf/MissedLoc)
			if(!MissedLoc)
				src.AutoHitter(0, 0, 0, 0, trg, Z)
			else
				src.AutoHitter(0, 0, 0, 0, targ=null, z=Z, trfloc=MissedLoc)

		AroundTarget(var/mob/trg, var/obj/Skills/AutoHit/Z, var/turf/TrgLoc)
			src.AutoHitter(0, 0, 0, 1, null, Z, TrgLoc)
obj
	AutoHitter
		density=1//It has to be dense to properly register contact.
		Destructable=0//Can't be explode
		var

			//Distance//Active count of tiles left to move.
			DistanceMax//Maximum amount; kept track of for arc purposes.
			NoPierce//It dies when it hits something
			IgnoreAlreadyHit = FALSE
			toDeath
			Duration
			Persistent = FALSE
			CorruptionGain
			Snaring
			SnaringOverlay
			Disarm=0
			Cleansing = 0
			ManaDrain
			FoxFire
			hitSelf = 0
			AngelMagicCompatible
			ApplyJudged
			ApplySentenced
			ElementalClass
			FixedDamage=0

			GuardBreak//mirror of the skill flag - pierces the guard system's DR

			Arcing//Triggers offshoots on every step that expand outwards.  Higher than 1 means that every X steps the range will widen.
			ArcingCount=0//Number of times arcing has been triggered.  Informs the game how many tiles to send the offshoots.
			Wave//Triggers offshoots that extend this number of steps on every step.
			Cardinal//Triggers offshoots in 4 directions.
			CardinalTriggered//Binary that makes sure crosses don't cross.
			Circle//Affects a circle
			mob/Target//Instantly hits this person
			turf/TargetLoc//Hits around this location

			ObjIcon//get an icon from the other obj
			Damage//This is the amount of damage a skill will do if all stats and power are equal.
			StepsDamage=0
			StepsTaken=0//A variable for easy recording
			list/DamageSteps=list()//This is a variable that allows damage to scale based on the steps taken by the projectile.  Think Tipper.
			while_warping = FALSE
			StrDmg//Does it factor in strength?
			ForDmg//Does it factor in force?
			//Mark both for hybrid.
			EndRes//Does endurance make it do less damage?
			SpellElement//If set, this autohitter is a magic spell of that element. Used to gate magic-only damage hooks like Casting passives.

			Knockback//Number of KB tiles.
			ChargeTech//Is this a charge move?  Does it carry the enemy with it?  This only affects KB, it doesn't trigger any other charging behavior.
			ComboMaster // it dont lose damage against stunned/launched nerds
			Dunker
			Destroyer
			UnarmedTech
			SwordTech
			SpecialAttack

			Stunner
			Deluge
			Stasis
			Destructive

			Bang
			Bolt
			BoltOffset
			Scratch
			Punt

			Grapple//IT GRAPPLES
			Launcher//LAUNCHERRR
			DelayedLauncher

			Divide
			TurfReplace
			TurfErupt
			TurfEruptOffset
			TurfIce
			TurfIceOffset
			TurfFog
			TurfFogOffset
			Erupt
			EruptOffset
			TurfDirt
			TurfDirtOffset
			TurfStrike
			TurfShift
			TurfShiftLayer
			TurfShiftDuration
			TurfShiftDurationSpawn
			TurfShiftDurationDespawn
			TurfShiftState
			TurfShiftX
			TurfShiftY
			Flash

			BlindImmuneDuration

			Slow//Autohit doesn't hit instantly
			ApplySlow
			NerveOverload
			CriticalParalyze
			CriticalSpark
			Whirlwind
			TrueToxic
			Rust
			TurfMud
			Reinforcement
			TurfBurn
			CanBeBlocked
			CanBeDodged

			PassThrough
			StopAtTarget
			Stopped//Use this to make sure you don't need to keep moving
			PassTo

			Wander//roam for this number of moves.
			WanderSize
			MortalBlow
			WarpAway
			CosmoPowered

			LifeSteal
			EnergySteal
			MagicNeeded
			DelayTime
			ChargeTime
			RagingDemonAnimation = FALSE
			Executor
			Executing
			Primordial
			SpeedStrike

			Scorching
			Chilling
			Freezing
			Drenching
			Soaking
			Crushing
			Burning
			Shattering
			Toxic
			Paralyzing
			Exposing
			Shredding
			Crippling
			Shocking
			Poisoning
			FrenzyDebuff
			Combustion
			IceAge
			Doom
			CooldownDrag

			grabNerf = 0
			BuffAffected = 0
			buffAffectedType = 0
			buffAffectedCompare = 0
			buffAffectedBoon = 0
			CorruptionDebuff = 0

			PullIn

			GoldScatter

			Shearing

			parentRounds = 1
			tmp/list/AlreadyHit
			tmp/list/autohitChildren
			tmp/obj/AutoHitter/AHOwner

			FollowUp
			BuffSelf
			FollowUpDelay

			DirectWounds

			/// Set for all autohits built from a skill, used for on-hit hooks (currently just Enuma Elish).
			var/obj/Skills/AutoHit/FromSkill
			var/finale_tallied = 0

		Update()
			..()


		New(var/mob/owner, var/arcing=0, var/wave=0, var/card=0, var/circle=0, var/mob/target, var/obj/Skills/AutoHit/Z, var/turf/TrgLoc, life = 500, dormant = 0)
			set waitfor = FALSE
			if(!owner)
				loc = null
				return
			AlreadyHit = list()
			autohitChildren = list()
			src.IgnoreAlreadyHit = Z.IgnoreAlreadyHit
			toDeath = life
			src.Owner=owner
			src.FromSkill = Z
			parentRounds = Z.Rounds

			if(owner.Grab && !Z.GrabMaster)
				grabNerf = 1
			src.Arcing=arcing
			src.Wave=wave
			src.Cardinal=card
			src.Circle=circle
			Cleansing = Z.Cleansing
			src.CorruptionGain = Z.CorruptionGain
			hitSelf = Z.HitSelf
			if(Z.Persistent)
				src.Persistent = 1
			src.DistanceMax=Z.Distance
			if(TrgLoc)
				src.TargetLoc=TrgLoc
				src.DistanceMax=Z.DistanceAround
			src.Target=target
			src.NoPierce=Z.NoPierce
			FollowUp = Z.FollowUp
			FollowUpDelay = Z.FollowUpDelay
			BuffSelf = Z.BuffSelf
			src.Damage=Z.DamageMult * owner.GetDisarmedAutoHitDamageFactor(Z)
			src.StepsDamage=Z.StepsDamage
			src.MagicNeeded=Z.MagicNeeded
			if(Z.while_warping)
				Damage /= glob.WHILEWARPINGNERF
				Z.while_warping = FALSE
			src.StrDmg=Z.StrScaling
			src.ForDmg=Z.ForScaling
			src.SpellElement=Z.SpellElement
			src.ElementalClass=Z.ElementalClass
			src.EndRes=Z.EndEffectiveness
			FoxFire = Z.FoxFire
			ManaDrain = Z.ManaDrain
			Snaring=Z.Snaring
			SnaringOverlay=Z.SnaringOverlay
			src.Executor = Z.Executor
			src.Primordial = Z.Primordial
			src.RagingDemonAnimation = Z.RagingDemonAnimation
			src.GoldScatter = Z.GoldScatter
			src.AngelMagicCompatible = Z.AngelMagicCompatible
			src.ApplyJudged = Z.ApplyJudged
			src.ApplySentenced = Z.ApplySentenced
			src.FixedDamage = Z.FixedDamage
			src.Knockback=Z.Knockback
			src.ChargeTech=Z.ChargeTech
			src.UnarmedTech=Z.UnarmedOnly
			src.SwordTech=Z.NeedsSword
			src.Executing=Z.Executing
			src.SpecialAttack=Z.SpecialAttack
			if(src.SpecialAttack || Z.SpellElement || Z.MagicNeeded || _fx_lit_paths["[Z.type]"] || FxAutoHitIsDark(Z))
				if(owner && owner._fx_pulse_t != world.time) //multi-round casts pulse once per tick
					owner._fx_pulse_t = world.time
					if(FxAutoHitIsDark(Z))
						FxDarkPulse(get_turf(owner), 1.6) //dark casts darken, not flash
					else
						FxLightPulse(get_turf(owner), 1.6, FxAutoHitColor(Z))
			src.Deluge=Z.Deluge
			src.Stunner=Z.Stunner
			src.Destructive=Z.Destructive
			src.Shearing = Z.Shearing
			src.Doom = Z.Doom
			src.Bang=Z.Bang
			src.Bolt=Z.Bolt
			src.BoltOffset=Z.BoltOffset
			src.Erupt=Z.Erupt
			src.EruptOffset=Z.EruptOffset
			src.Scratch=Z.Scratch
			src.Punt=Z.Punt
			src.Divide=Z.Divide
			CooldownDrag = Z.CooldownDrag
			src.TurfErupt=Z.TurfErupt
			src.TurfEruptOffset=Z.TurfEruptOffset
			src.TurfIce=Z.TurfIce
			src.TurfIceOffset=Z.TurfIceOffset
			src.TurfFog=Z.TurfFog
			src.TurfFogOffset=Z.TurfFogOffset
			src.TurfDirt=Z.TurfDirt
			src.TurfDirtOffset=Z.TurfDirtOffset
			src.TurfStrike=Z.TurfStrike
			src.TurfReplace=Z.TurfReplace
			src.TurfShift=Z.TurfShift
			src.TurfShiftLayer=Z.TurfShiftLayer
			src.TurfShiftDuration=Z.TurfShiftDuration
			src.TurfShiftDurationSpawn=Z.TurfShiftDurationSpawn
			src.TurfShiftDurationDespawn=Z.TurfShiftDurationDespawn
			TurfShiftState = Z.TurfShiftState
			TurfShiftX = Z.TurfShiftX
			TurfShiftY = Z.TurfShiftY

			src.Flash=Z.Flash
			src.BlindImmuneDuration=Z.Cooldown
			src.ComboMaster=Z.ComboMaster
			Dunker = Z.Dunker
			Destroyer = Z.Destroyer
			src.CanBeBlocked=Z.CanBeBlocked
			src.CanBeDodged=Z.CanBeDodged
			src.GuardBreak=Z.GuardBreak
			src.ImpactFrame=Z.ImpactFrame
			src.Slow=Z.Slow
			src.ApplySlow = Z.ApplySlow
			src.NerveOverload = Z.NerveOverload
			src.CriticalParalyze = Z.CriticalParalyze
			src.CriticalSpark = Z.CriticalSpark
			src.Whirlwind = Z.Whirlwind
			src.TrueToxic = Z.TrueToxic
			src.Rust = Z.Rust
			src.TurfMud = Z.TurfMud
			src.Reinforcement = Z.Reinforcement
			src.TurfBurn = Z.TurfBurn
			src.PassThrough=Z.PassThrough//This does not get assigned to other types because it will always follow the primary autohit, not the offshoots.
			src.PassTo=Z.PassTo
			src.StopAtTarget=Z.StopAtTarget
			src.Wander=Z.Wander
			src.SpeedStrike = Z.SpeedStrike
			if(src.Wander)
				src.WanderSize=Z.Size
			src.Stasis=Z.Stasis
			src.MortalBlow=Z.MortalBlow
			src.WarpAway=Z.WarpAway
			if(Z.GodPowered)
				src.Owner.transcend(Z.GodPowered)
			src.CosmoPowered=Z.CosmoPowered
			src.Launcher=Z.Launcher
			src.DelayedLauncher=Z.DelayedLauncher
			src.Grapple=Z.Grapple
			src.LifeSteal=Z.LifeSteal
			src.EnergySteal=Z.EnergySteal
			src.DelayTime=Z.DelayTime
			src.ChargeTime=Z.ChargeTime
			src.BuffAffected=Z.BuffAffected
			src.buffAffectedType  = Z.buffAffectedType
			src.buffAffectedCompare = Z.buffAffectedCompare
			src.buffAffectedBoon = Z.buffAffectedBoon
			src.CorruptionDebuff = Z.CorruptionDebuff
			PullIn = Z.PullIn
			if(Z.Burning)
				src.Burning+=Z.Burning
			if(Z.Scorching)
				src.Scorching+=Z.Scorching
			if(Z.Chilling)
				src.Chilling+=Z.Chilling
			if(Z.Freezing)
				src.Freezing+=Z.Freezing
			if(Z.Drenching)
				src.Drenching+=Z.Drenching
			if(Z.Soaking)
				src.Soaking+=Z.Soaking
			if(Z.Crushing)
				src.Crushing+=Z.Crushing
			if(Z.Shattering)
				src.Shattering+=Z.Shattering
			if(Z.Shocking)
				src.Shocking+=Z.Shocking
			if(Z.Paralyzing)
				src.Paralyzing+=Z.Paralyzing
			if(Z.Exposing)
				src.Exposing+=Z.Exposing
			if(Z.Shredding)
				src.Shredding+=Z.Shredding
			if(Z.Poisoning)
				src.Poisoning+=Z.Poisoning
			if(Z.Combustion)
				src.Combustion = Z.Combustion
			if(Z.IceAge)
				src.IceAge = Z.IceAge
			if(Z.Disarm)
				src.Disarm = Z.Disarm
			if(Z.Toxic)
				src.Toxic+=Z.Toxic
			if(Z.Crippling)
				src.Crippling+=Z.Crippling
			if(Z.FrenzyDebuff)
				src.FrenzyDebuff = Z.FrenzyDebuff
			if(Z.DirectWounds)
				src.DirectWounds=Z.DirectWounds;
			if(Z.ObjIcon)
				src.ObjIcon=Z.ObjIcon
				var/icon/i=Z.Icon
				if(Z.IconRed||Z.IconGreen||Z.IconBlue)
					i+=rgb(Z.IconRed, Z.IconGreen, Z.IconBlue)
				src.icon=i

				src.pixel_x=Z.IconX
				src.pixel_y=Z.IconY
				src.transform*=Z.Size
			var/ShiftOdds=(owner.passive_handler.Get("Unreality")*100)
			if(owner.passive_handler.Get("Half Manifestation"))
				if(prob(ShiftOdds))
					Z.HitSparkIcon='Slash - Vampire.dmi'
					Z.HitSparkX=-32
					Z.HitSparkY=-32
					Z.HitSparkTurns=1
					Z.HitSparkSize=1
					Z.HitSparkDispersion=1
					Z.TurfStrike=1
					Z.TurfShift=owner.EldritchTrail
					Z.TurfShiftDuration=3
					if(prob(50) && owner.passive_handler.Get("Full Manifestation"))
						DarknessFlash(owner)
					Z.ActiveMessage="<font color='red'><font size=+1><b>You cannot grasp the true form of [owner]'s attack...</font color></font size></b>"

			InkJoinFamily(owner, Z)
			if(dormant)
				ink_dormant = 1
				density = 0
				src.dir = src.Owner.dir
				return
			src.dir=src.Owner.dir
			src.loc=src.Owner.loc
			src.Distance=src.DistanceMax

			src.UsesPixelCollision = TRUE
			if(src.UsesPixelCollision)
				src.AH_SetupPixel(Z)

			ticking_generic += src

			src.Life()
			sleep(life)
			if(!Persistent)
				endLife()
		Bump(var/mob/m)
			if(istype(m, /mob))
				if(!hitSelf&&m!=src.Owner&&m.density)
					spawn()
						src.Damage(m)
						if(src.NoPierce)
							endLife()
							return
				if(!Persistent)
					if(!UsesPixelCollision)
						src.loc=m.loc
		Update()
			if(Persistent)
				if(UsesPixelCollision)
					AH_ZoneStrike(src.TargetLoc, Distance, los=FALSE) //Persistent never had LOS
				else
					for(var/turf/t in range( Distance, src.TargetLoc))
						for(var/mob/m in t.contents)
							if(!hitSelf&&m==src.Owner)
								continue
							else
								src.Damage(m)
			if(toDeath-- <= 25)
				animate(src, alpha = 0, time = 20)
				endLife()

		proc/endLife()
			set waitfor = FALSE
			try
				if(src.PassThrough)
					if(!src.Stopped)
						if(Owner)
							AfterImage(src.Owner)
							if(src.Target)//For targetted autohits...
								if(src.StopAtTarget)//Front
									if(Owner)
										src.Owner.loc=get_step(src.Owner.Target, src.Owner.Target.dir)
										if(PmActive())//track the target's mid-tile sprite
											src.Owner.step_x=src.Owner.Target.step_x
											src.Owner.step_y=src.Owner.Target.step_y
										src.Owner.dir=get_dir(src.Owner, src.Owner.Target)//facing them
								else
									if(Owner)
										src.Owner.loc=get_step(src.Owner.Target, turn(src.Owner.Target.dir, 180))//Appear behind the fucker
										if(PmActive())
											src.Owner.step_x=src.Owner.Target.step_x
											src.Owner.step_y=src.Owner.Target.step_y
										src.Owner.dir=turn(get_dir(src.Owner, src.Owner.Target), 180)//facing away
							else
								if(Owner)
									src.Owner.loc=src.loc
									if(PmActive())//land on the strike's mid-tile endpoint, not its tile origin
										src.Owner.step_x=src.step_x
										src.Owner.step_y=src.step_y
			catch()
			if(ink_family && ink_family.HoldsRoot(src))
				ink_hold = 1
				ink_family.roots |= src
				return
			InkTeardown()
		proc
			Damage(var/mob/m)
				if(m && Owner && m in Owner.ai_followers)
					return
				if(!m.passive_handler)
					return
				if(!IgnoreAlreadyHit)
					var/weHitThemAlready = FALSE
					for(var/hitted in AlreadyHit)
						if(m == hitted)
							weHitThemAlready = TRUE
					if(AHOwner)
						for(var/hitted in AHOwner.AlreadyHit)
							if(hitted == m)
								weHitThemAlready = TRUE
					if(!weHitThemAlready)
						for(var/obj/AutoHitter/ah in autohitChildren)
							for(var/hitted in ah.AlreadyHit)
								if(m == hitted)
									weHitThemAlready = TRUE
									break
					if(weHitThemAlready)
						return
				var/obj/AutoHitter/root = AHOwner ? AHOwner : src //first hit marks the whole cast so offshoot siblings cant double-hit
				root.AlreadyHit |= m
				for(var/obj/AutoHitter/ah in root.autohitChildren)
					ah.AlreadyHit |= m
				// Mirror Reflection from Kusanagi
				var/mirror_reflect = FALSE
				if(m.mirror_parry_active)
					m.mirror_parry_active = FALSE
					KenShockwave(m, icon='Icons/Effects/KenShockwave.dmi', Size=1.5, Blend=2, Time=8)
					return
				if(m.mirror_reflect_active)
					m.mirror_reflect_active = FALSE
					mirror_reflect = TRUE
				if(istype(Owner, /mob/Player/AI) && m != Owner)
					var/mob/Player/AI/a = Owner
					if(!a.ai_team_fire && a.AllianceCheck(m))
						return
				if(src.StopAtTarget)
					AfterImage(src.Owner)
					src.Owner.loc=get_step(m, get_dir(m, src.Owner))
					if(PmActive())//land on the hit mob's sprite, not its tile origin
						src.Owner.step_x=m.step_x
						src.Owner.step_y=m.step_y
					src.Stopped=1
				if(src.PassTo)
					AfterImageA(src.Owner, forceloc=get_step(m, get_dir(m, src.Owner)))
				// grabNerf = Owner.Grab && ! ? 1 : 0
				//world<<"GrabNerf: [grabNerf]"
				var/FinalDmg
				var/powerDif = Owner.Power/m.Power
				if(glob.CLAMP_POWER)
					if(!Owner.ignoresPowerClamp(m))
						powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
				#if DEBUG_AUTOHIT
				Owner.log2text("powerDif - Auto Hit", powerDif, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
				#endif
				var/atk = 0
				var/fIdnt = FromSkill.FocusStatIdentity()
				var/strScale = Owner.FocusShiftScaling(fIdnt, "STR", FromSkill.StrScaling)
				var/forScale = Owner.FocusShiftScaling(fIdnt, "FOR", FromSkill.ForScaling)
				var/str = strScale ? Owner.GetStr(strScale) : 0
				var/force = forScale ? Owner.GetFor(forScale) : 0
				atk = (FromSkill.BaseStatOverride(Owner) || Owner.getStatDmg2(autohit = TRUE)) + str + force + (FromSkill.SpdScaling ? Owner.GetSpd(FromSkill.SpdScaling) : 0) + (FromSkill.OffScaling ? Owner.GetOff(FromSkill.OffScaling) : 0) + (FromSkill.DefScaling ? Owner.GetDef(FromSkill.DefScaling) : 0) + (FromSkill.EndScaling ? Owner.GetEnd(FromSkill.EndScaling) : 0)
				DEBUGMSG("atk final is: [atk]")
				var/dmgMulti = Damage
				#if DEBUG_AUTOHIT
				Owner.log2text("atk - Auto Hit", atk, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
				#endif
				var/def = m.getEndStat(1) * EndRes
				if(def<0)
					def=0.01
				if(atk<1)
					atk=1

				#if DEBUG_AUTOHIT
				Owner.log2text("def - Auto Hit", def, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
				#endif
				// powerDif += Owner.getIntimDMGReduction(m)
				#if DEBUG_AUTOHIT
				Owner.log2text("powerDif - Auto Hit", powerDif, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
				#endif
				FinalDmg = strikeCoreDamage(powerDif, atk, def)
				#if DEBUG_AUTOHIT
				Owner.log2text("FinalDmg(before dmgRoll) - Auto Hit", FinalDmg, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
				#endif
				DEBUGMSG("FinalDmg is: [FinalDmg]")
				FinalDmg *= dmgMulti
				FinalDmg *= Owner.strikeJudgmentMult()
				if(m.HasGiantForm())
					FinalDmg *= glob.GIANT_FORM_DMG_MULT
				DEBUGMSG("FinalDmg (After roll/multi) is: [FinalDmg]")
				if(Owner.Secret=="Heavenly Restriction" && Owner.secretDatum?:hasImprovement("Autohits"))
					FinalDmg *= clamp(Owner.secretDatum?:getBoon(Owner,"Autohits"), 1, 10)
				#if DEBUG_AUTOHIT
				Owner.log2text("FinalDmg - Auto Hit", FinalDmg, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
				#endif
				var/Precision = 1 + ((Damage*parentRounds)/10)
				var/itemMods = list(0,0,0)
				if(src.SwordTech&&!src.SpecialAttack)
					var/obj/Items/Sword/s=src.Owner.EquippedSword()
					var/obj/Items/Enchantment/st=src.Owner.EquippedStaff()
					itemMods = Owner.getItemDamage(list(s,FALSE,FALSE,st), 0, Precision, FALSE, FALSE, TRUE, FALSE )
				if(SpecialAttack)
					var/obj/Items/Sword/s=src.Owner.EquippedSword()
					var/obj/Items/Enchantment/st=src.Owner.EquippedStaff()
					itemMods = Owner.getItemDamage(list(s,FALSE,FALSE,st), 0, Precision, FALSE, FALSE, TRUE, TRUE)
				if(itemMods[3])
					#if DEBUG_AUTOHIT
					Owner.log2text("Item Damage - Auto Hit", itemMods[3], "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
					#endif
					FinalDmg *= itemMods[3]
					#if DEBUG_AUTOHIT
					Owner.log2text("FinalDmg - Auto Hit", "After Item Damage", "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
					Owner.log2text("FinalDmg - Auto Hit", FinalDmg, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
					#endif
				if(itemMods[2])
					Precision *= itemMods[2]

				if(GoldScatter||Owner.CheckSlotless("Hoarders Riches"))
					for(var/obj/Money/money in m.contents)
						if(money.Level>0)
							var/newX = m.x + rand(-3, 3)
							var/newY = m.y + rand(-3, 3)
							for(var/i = 0, i < 10, i++)
								var/turf/t = locate(newX,newY,m.z)
								if(t.density)
									if(i == 9) break
									newX = m.x + rand(-3, 3)
									newY = m.y + rand(-3, 3)
									continue
								else
									break
							var/obj/gold/gold = new()
							gold.createPile(m, src.Owner, newX, newY, m.z)
					m << "You feel a need to go collect your coins before they're stolen!"

				if(src.SpeedStrike>0)
					FinalDmg *= clamp(sqrt(1+((Owner.GetSpd()+glob.LIGHT_ATTACK_SPEED_STAT_BASE)*(src.SpeedStrike/glob.SPEEDSTRIKEDIVISOR))),1,3)
				FinalDmg *= m.ccProrationMult(Owner, includeSuspended = 1, skillCM = ComboMaster, dunk = (Dunker||Destroyer))
				if(m.Stunned && Destroyer)
					FinalDmg *= 1 + (Destroyer/10)
				var/obj/Items/Armor/HittingArmor=m.EquippedArmor()
				var/obj/Items/Armor/WearingArmor=src.Owner.EquippedArmor()
				if(HittingArmor)//Reduced damage
					var/dmgEffective = m.GetArmorDamage(HittingArmor)
					if(Owner.UsingHalfSword())
						dmgEffective -= Owner.UsingHalfSword() * glob.HALF_SWORD_ARMOR_REDUCTION
					if(dmgEffective>0)
						FinalDmg -=  FinalDmg * dmgEffective/10
					else
						FinalDmg += FinalDmg * abs(dmgEffective/10)
					Owner.log2text("FinalDmg - Auto Hit", "After HittingArmor", "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
					Owner.log2text("FinalDmg - Auto Hit", FinalDmg, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
				if(Owner.UsingHalfSword() && !HittingArmor)
					FinalDmg += FinalDmg * (Owner.UsingHalfSword()/glob.HALF_SWORD_UNARMOURED_DIVISOR)

				if(WearingArmor)//Reduced delay and accuracy
					Precision*=src.Owner.GetArmorAccuracy(WearingArmor)

				if(src.CanBeBlocked||m.passive_handler.Get("YataNoKagami"))
					if(Accuracy_Formula(src.Owner, m, AccMult=Precision, BaseChance=glob.WorldDefaultAcc, IgnoreNoDodge=0) == WHIFF)
						if(!src.Owner.NoWhiff())
							var/obj/Items/Sword/s = Owner.EquippedSword()
							DEBUGMSG("WHIFFED [FinalDmg] be4")
							if(s)
								FinalDmg/=max(1,(glob.AUTOHIT_WHIFF_DAMAGE*(1/Owner.GetSwordAccuracy(s))))
							else
								FinalDmg/=glob.AUTOHIT_WHIFF_DAMAGE
							DEBUGMSG("WHIFFED [FinalDmg]")

				if(src.Owner.inParty(m.ckey))
					FinalDmg *= glob.PARTY_DAMAGE_NERF
					if(src.Owner.passive_handler.Get("TeamFighter"))
						FinalDmg /= 1+src.Owner.passive_handler.Get("TeamFighter")

				if(src.Owner.party && src.Owner.passive_handler.Get("TeamHater"))
					if(m in src.Owner.party.members)
						FinalDmg *= 1+src.Owner.passive_handler.Get("TeamHater")

				FinalDmg*= glob.AUTOHIT_GLOBAL_DAMAGE
				DEBUGMSG("after glob mod: [FinalDmg]")

				if(Owner.Attunement == "Fox Fire")
					var/heal = FinalDmg * ( (1 + Owner.AscensionsAcquired + (FoxFire))/10)
					m.LoseEnergy(heal/2)
					m.LoseMana(heal/2)
					Owner.HealEnergy(heal/2)
					Owner.HealMana(heal/2)
				if(m.HasDeflection()&&!src.CanBeDodged)
					if(m.CheckSlotless("Deflector Shield"))
						if(!m.Shielding)
							m.Shielding=1
							spawn()
								m.ForceField()
					FinalDmg*=max(1-(glob.DEFLECTION_DAMAGE_MULT*m.GetDeflection()),0.3)
					DEBUGMSG("after Deflection: [FinalDmg]")

				var/list/Elements = list()
				if(Scorching||Burning)
					Elements |= "Fire"
				if(Drenching||Soaking)
					Elements |= "Water"
				if(Chilling||Freezing)
					Elements |= "Ice"
				if(Crushing||Shattering)
					Elements |= "Earth"
				if(Exposing||Shredding)
					Elements |= "Wind"
				if(Shocking||Paralyzing)
					Elements |= "Lightning"
				if(Toxic||Poisoning)
					Elements |= "Poison"

				ElementalCheck(Owner, m, 0, bonusElements = Elements)

				var/pre_slowed = m.Slow > 0 || m.Crippled > 0 || (m.passive_handler && m.passive_handler["Snared"])
				if(Crippling)
					m.AddCrippling(Crippling, Owner)
				if(Shearing)
					m.AddShearing(Shearing, Owner)
				if(Doom)
					m.AddDoom(Doom, Owner)
				if(FrenzyDebuff)
					m.AddFrenzy(FrenzyDebuff, Owner)

				if(Cleansing && src.Owner.shouldCleanse(m))
					m.CleanseDebuff(Cleansing*10);

				if(FromSkill && FromSkill.Silencing)
					applySilence(m, FromSkill.Silencing * 10)
				if(FromSkill && FromSkill.EnergyBurn)
					m.LoseEnergy(FromSkill.EnergyBurn)
					if(FromSkill.DrainToSelf && Owner)
						Owner.HealEnergy(FromSkill.EnergyBurn)
				if(FromSkill && FromSkill.CursedWounds)
					applyCursedWounds(m, FromSkill.CursedWounds * 10)

				if(src.CosmoPowered)
					if(!src.Owner.SpecialBuff)
						FinalDmg*=TrueDamage(1+(src.Owner.SenseUnlocked-5))
				if(src.Executor)
					var/additonal = src.Executor * 0.1
					if(m.HealthPct()<=5)
						additonal *= 2
					if(m.HealthPct() <=25)
						FinalDmg *= 1 + additonal
				if(FromSkill && FromSkill.BonusVsStunned && m.Stunned)
					FinalDmg *= 1 + FromSkill.BonusVsStunned
				if(FromSkill && FromSkill.BonusVsSlowed && pre_slowed)
					FinalDmg *= 1 + FromSkill.BonusVsSlowed
				if(FromSkill && FromSkill.RushTally && FromSkill.rush_passed_mobs && FromSkill.rush_passed_mobs.len)
					FinalDmg *= 1 + FromSkill.RushTally * FromSkill.rush_passed_mobs.len
				if(FromSkill && FromSkill.RushTally && FromSkill.rush_passed_mobs)
					FromSkill.rush_passed_mobs |= m
				if(FromSkill && FromSkill.SequenceStrokes > 1)
					FinalDmg /= FromSkill.SequenceStrokes
				if(Primordial)
					var/additonal = Primordial
					var/missingHealth = 100-m.HealthPct()
					FinalDmg *= 1 + (((additonal*glob.PRIMORDIAL_EFFECTIVENESS) * missingHealth)/100)
				if(Owner && ismob(m) && src.FromSkill)
					m.NoteSkillHit(Owner, src.FromSkill:type)
					if(src.FromSkill:PhantomMark)
						m.phantom_mark_by = Owner
						m.phantom_mark_until = world.time + 40
						m.phantom_mark_damage = src.FromSkill:PhantomMark
						applyPhantomMarkFX(m, 40)
				if(ApplySlow)
					m.AddSlow(ApplySlow, Owner)
				if(NerveOverload)
					m.AddShock(NerveOverload, Owner)
				if(CriticalParalyze && prob(CriticalParalyze))
					Stun(m, 2)
				if(CooldownDrag)
					m.addCooldownDrag(CooldownDrag, Owner)
				if(CriticalSpark && prob(CriticalSpark))
					FinalDmg *= 1.5
					animate(m, color = "#fff757")
					animate(m, color = m.MobColor, time = 5)
				if(Whirlwind && prob(Whirlwind))
					m.Knockback(2, Owner, Direction=pick(NORTH, SOUTH, EAST, WEST))
				if(TrueToxic)
					m.AddPoison(TrueToxic, Owner)
				if(Rust)
					m.AddShearing(Rust, Owner)
				if(TurfMud)
					m.AddSlow(TurfMud, Owner)
				if(Reinforcement && Owner)
					Owner.HealHealth(Reinforcement/20)
				var/_spellConsumed = 0
				if(FromSkill && FromSkill.IsSpell && Owner)
					_spellConsumed = Owner.OnSpellHit(FromSkill, m, src)
				if(TurfBurn && !_spellConsumed)
					m.AddBurn(TurfBurn, Owner, (FromSkill && FromSkill.IsSpell) ? 1 : 0)
				if(grabNerf)
					FinalDmg *= glob.AUTOHIT_GRAB_NERF
					DEBUGMSG("after grabNerf: [FinalDmg]")
				if(FromSkill && FromSkill.FinaleDouble && FromSkill.finale_rounds > 1)
					if(!finale_tallied)
						finale_tallied = 1
						FromSkill.strokes_landed++
					if(FromSkill.strokes_landed >= FromSkill.finale_rounds)
						FinalDmg *= 2
				if(FromSkill && FromSkill.KillCounter)
					if(world.time - FromSkill.kill_stamp > 900)
						FromSkill.kill_stacks = 0
					if(FromSkill.kill_stacks < 4)
						FromSkill.kill_stacks++
					FromSkill.kill_stamp = world.time
//TODO: Remove a whole lot of those
				if(src.Bang)
					Bang(m.loc, src.Bang, PX=(PmActive() ? m.step_x : 0), PY=(PmActive() ? m.step_y : 0), color_override = FxAutoHitTint(src.FromSkill))
				if(src.Scratch)
					Scratch(m)
				if(src.Punt)
					Hit_Effect(m, Size=src.Punt)
				if(Snaring)
					m.applySnare(Snaring, SnaringOverlay)
				//EFFECTS HERE

				if(src.CanBeDodged||m.passive_handler.Get("YataNoKagami"))
					var/loc=m.loc
					if(m.AttackQueue&&(m.AttackQueue.Counter||m.AttackQueue.CounterTemp))
						m.dir=get_dir(m, src.Owner)
						if(m.UsingAnsatsuken())
							m.HealMana(m.SagaLevel*5)
						if(m.SagaLevel>1&&m.Saga=="Path of a Hero: Rebirth")
							if(m.passive_handler["Determination(Purple)"]||m.passive_handler["Determination(White)"])
								m.HealMana(m.SagaLevel*3, 1)
								if(m.ManaAmount>=100 && (m.RebirthHeroType=="Cyan"||!m.passive_handler["Determination(White)"]))
									m.passive_handler.Set("Determination(Green)", 1)
									m.passive_handler.Set("Determination(Purple)", 0)
									m<<"Your SOUL color shifts to green!"
							if(m.passive_handler["Determination"])
								m.HealMana(m.SagaLevel*1.25)
							else
								m.HealMana(m.SagaLevel*5)
						if(m.CanAttack())
							var/counter_mult = Damage
							m.Melee1(counter_mult,2,0,0,null,null,0,0,2,1)
					if(Accuracy_Formula(src.Owner, m, AccMult=Precision, BaseChance=glob.WorldDefaultAcc, IgnoreNoDodge=0) == MISS)
						DEBUGMSG("LOL AUTOHITS CAN MISS ? [FinalDmg]")
						FinalDmg /= glob.AUTOHIT_MISS_DAMAGE
						DEBUGMSG("after FR")

					if(m.aisArmed())
						if(!src.TurfStrike)
							spawn()
								src.Owner.HitEffect(loc, src.UnarmedTech, src.SwordTech)
							if(src.ImpactFrame)
								FxHeavyImpact(m, src)
						StunClear(m)
						AfterImageStrike(m, src.Owner,1)
						m.aisConsume()
						return

				if(src.MortalBlow)
					if(src.MortalBlow<0)
						m.MortallyWounded+=4
					else
						if((prob(glob.MORTAL_BLOW_CHANCE * MortalBlow) || (FromSkill && FromSkill.ExecuteMortal && m.HealthPct() < FromSkill.ExecuteMortal)) && !m.MortallyWounded)
							var/mortalDmg = m.Health * 0.05 // 5% of current
							m.LoseHealth(mortalDmg)
							m.WoundSelf(m.HPToPct(mortalDmg))
							m.MortallyWounded += 1
							OMsg(m, "<b><font color=#ff0000>[src] has dealt a mortal blow to [m]!</font></b>")
						if(src.MortalBlow>1)
							if(m.Immortal)
								m.Immortal=0
				var/extraKnock=0
				if(m.Launched && Dunker)
					m.Dunked = Dunker
					extraKnock = 1 + (2 * Dunker)
					FinalDmg *= 1 + (Dunker/10)
					flick("KB", Owner)
					spawn()
						LaunchEnd(m)
				DEBUGMSG("FINAL TOTAL DAMAGE DEALT before do damage! [FinalDmg]")
				var/skipPureDamage = 0
				if(Owner && FromSkill)
					if(Owner.HasPurity()||FromSkill.Purity)
						var/found=0
						if(Owner.HasHolyMod())
							if(m.IsEvil())
								found=1
						if(!found)
							skipPureDamage = 1
				var/list/specDmgTypes = null
				if(!skipPureDamage && Owner && FromSkill)
					specDmgTypes = buildSpecDmgTypes(FromSkill.SlayerMod)
				if(src.AngelMagicCompatible && m.passive_handler.Get("Judged"))
					FinalDmg *= 1.25
				var/reversalChance = m.GetAutoReversal()
				// Diminishing returns
				var/reversalProcChance = 0
				if(reversalChance > 0)
					reversalProcChance = (reversalChance / (reversalChance + 2)) * 100
				if(prob(min(reversalProcChance, 100)))
					if(m.HasAutoReversal())
						if(!src.SpecialAttack)
							var/reversalAcc = Accuracy_Formula(src.Owner, m, AccMult=Precision, BaseChance=glob.WorldDefaultAcc, IgnoreNoDodge=1)
							if(reversalAcc == HIT || reversalAcc == WHIFF)
								/*if(m.hasMagmicShield())
									Stun(Owner, 3, FALSE);
									m.MagmicShieldOff();*/
								if(src.Damage>0.1)
									KenShockwave(m, icon='KenShockwave.dmi', Size=0.6, Time=3)
									m.Knockback(src.Knockback+(reversalChance*2.5) , src.Owner, Direction=get_dir(m, src.Owner))
								var/reversalDmg = FinalDmg * glob.AUTOHIT_REVERSAL_DAMAGE_FRAC / max(1, src.parentRounds)
								var/strike/RS = new(m, src.Owner, reversalDmg)
								RS.unarmed = src.UnarmedTech
								RS.sword = src.SwordTech
								RS.spirit = src.SpecialAttack
								RS.autohit = 1
								RS.resolve()
								if(src.Bang)
									Bang(src.Owner.loc, src.Bang, PX=(PmActive() ? src.Owner.step_x : 0), PY=(PmActive() ? src.Owner.step_y : 0), color_override = FxAutoHitTint(src.FromSkill))
								if(src.Scratch)
									Scratch(src.Owner)
								if(src.Bolt)
									LightningBolt(src.Owner, src.Bolt, src.BoltOffset)
								if(src.Punt)
									Hit_Effect(src.Owner, Size=src.Punt)
								src.Owner.HitEffect(src.Owner, src.UnarmedTech, src.SwordTech)
								if(reversalAcc == WHIFF)
									OMsg(m, "[m] redirected most of the force of the attack back at [src.Owner]!")
									m << "You redirected most of the force of the attack back at [src.Owner]!"
								if(reversalAcc == HIT)
									OMsg(m, "[m] redirected the force of the attack back at [src.Owner]!")
									m << "You redirected the force of the attack back at [src.Owner]!"
									return
				if(src.DirectWounds)
					src.Owner.DealWounds(m, m.PctToHP(src.DirectWounds));
				if((SpellElement == "Water" || SpellElement == "Ice") && m.passive_handler.Get("ChillAbsorb"))
					m.HealHealth(FinalDmg * (0.1 * m.passive_handler.Get("ChillAbsorb")))
					return
				if(SpellElement == "Lightning" && m.passive_handler.Get("ShockAbsorb"))
					m.HealHealth(FinalDmg * (0.1 * m.passive_handler.Get("ShockAbsorb")))
					return
				if(SpellElement == "Wind" && m.passive_handler.Get("WindAbsorb"))
					m.HealHealth(FinalDmg * (0.1 * m.passive_handler.Get("WindAbsorb")))
					return
				var/damageDealt
				if(skipPureDamage)
					damageDealt = 0
				else if(src.FixedDamage)
					var/fixedAmt = src.FixedDamage
					if(specDmgTypes)
						fixedAmt *= 1 + Owner.attackModifiers(m, specDmgTypes)
					var/DefReduction=sqrt(m.BaseDef())
					fixedAmt/=DefReduction
					m.LoseHealth(m.PctToHP(fixedAmt))
					damageDealt = fixedAmt
					if(m.Health <= 0 && !m.KO)
						m.Unconscious(src.Owner)
				else
					if(src.Combustion)
						src.Owner.passive_handler.Increase("Combustion", src.Combustion)
					if(src.IceAge)
						src.Owner.passive_handler.Increase("IceAge", src.IceAge)
					if(mirror_reflect && Owner)
						KenShockwave(m, icon='Icons/Effects/KenShockwave.dmi', Size=1.5, Blend=2, Time=8)
						flick("Attack", Owner)
						var/strike/MS = new(Owner, Owner, FinalDmg)
						MS.unarmed = src.UnarmedTech
						MS.sword = src.SwordTech
						MS.destructive = src.Destructive
						MS.autohit = 1
						MS.resolve()
						return
					var/_elemResist = m.getElementResistFor(src.SpellElement, src.ElementalClass)
					if(_elemResist != 1)
						FinalDmg *= _elemResist
					if(FromSkill && FromSkill.IsSpell && Owner)
						FinalDmg *= Owner.SpellHitMult(FromSkill, m)
					// Executing is +1% damage per 1 Injury on the target
					if(src.Executing && m)
						FinalDmg *= 1 + (0.01 * src.Executing * m.TotalInjury)
					if(m.isCommitted())
						CounterHitReward(src.Owner, m, min(FinalDmg, 14))
					var/strike/S = new(src.Owner, m, FinalDmg)
					S.unarmed = src.UnarmedTech
					S.sword = src.SwordTech
					S.destructive = src.Destructive
					S.lifesteal = LifeSteal
					S.autohit = 1
					S.special = src.SpecialAttack
					S.element = src.SpellElement
					S.pierce = src.GuardBreak
					S.critEff = FromSkill.CritEffectiveness
					S.blockEff = FromSkill.BlockEffectiveness
					S.critBonus = FromSkill.CritChanceBonus
					S.dmgTypes = specDmgTypes
					damageDealt = S.resolve()
					if(damageDealt > 0 && FromSkill && FromSkill.WoundRider && Owner && ismob(m))
						Owner.DealWounds(m, damageDealt * FromSkill.WoundRider)
					m.ccCountHit(1)
					if(src.Combustion && m)
						var/combThresh = src.Owner.passive_handler["Combustion"]
						if(combThresh <= 80)
							if(m.Burn >= combThresh)
								m.implodeDebuff(combThresh, "Burn")
						else
							if(m.Burn >= 80)
								m.implodeDebuff(combThresh, "Burn")
					if(src.IceAge && m)
						var/iceThresh = src.Owner.passive_handler["IceAge"]
						if(m.Slow >= iceThresh)
							m.implodeDebuff(iceThresh, "Chill")
					if(src.Combustion)
						src.Owner.passive_handler.Decrease("Combustion", src.Combustion)
					if(src.IceAge)
						src.Owner.passive_handler.Decrease("IceAge", src.IceAge)
					if(src.Disarm && m)
						src.Owner.DisarmTarget(m)
				DEBUGMSG("FINAL TOTAL DAMAGE DEALT! [damageDealt]")
				if(!damageDealt)
					damageDealt = 0

				if(istype(FromSkill, /obj/Skills/AutoHit/Enuma_Elish) && damageDealt)
					var/obj/Skills/AutoHit/Enuma_Elish/ee = FromSkill
					ee.EnumaElishOnHit(Owner, m, damageDealt)

				if(ManaDrain)
					m.LoseMana(ManaDrain)
					src.Owner.HealMana(ManaDrain)

				if(CorruptionGain && !skipPureDamage)
					Owner.gainCorruption((FinalDmg * 2) * glob.CORRUPTION_GAIN)
				if(src.ApplyJudged)
					m.applyJudged(120)
				if(src.ApplySentenced)
					m.applySentenced(60)
				if(src.Owner.UsingAnsatsuken())
					src.Owner.HealMana(src.Owner.SagaLevel)
				if(src.Owner.SagaLevel>1&&src.Owner.Saga=="Path of a Hero: Rebirth")
					if(src.Owner.passive_handler["Determination"])
						src.Owner.HealMana(src.Owner.SagaLevel/4)
					else
						src.Owner.HealMana(src.Owner.SagaLevel)

				if(src.Owner.HitSparkIcon!='BLANK.dmi')
					if(m&&m.Health>0&&src.Launcher&&src.DelayedLauncher)

						src.Owner.Frozen=3
						var/Time=src.Launcher
						var/Delay=src.Owner.HitSparkCount*src.Owner.HitSparkDelay
						spawn()
							LaunchEffect(src.Owner, m, Time, Delay)
					if(!src.TurfStrike)
						spawn()
							if(Owner)
								src.Owner.HitEffect(m, src.UnarmedTech, src.SwordTech)
						if(src.ImpactFrame)
							FxHeavyImpact(m, src)

				if(src.Grapple)
					if(!src.Owner.Grab)
						src.Owner.Grab_Mob(m, Forced=1)
				if(src.Knockback||extraKnock)
					if(src.ChargeTech)
						if(m!=src.Owner.Grab)
							var delay
							if(ChargeTime || DelayTime) delay = ChargeTime ? (src.ChargeTime*world.tick_lag) : DelayTime
							src.Owner.Knockback(src.Knockback, m, Direction=src.Owner.dir, Forced=1, override_speed=delay)
					else
						if(src.UnarmedTech)
							KenShockwave(m, Size=min(src.Knockback*max(2*(!src.Owner.HasNullTarget() ? src.Owner.GetGodKi() : 0),1)*GoCrand(0.04,0.4),0.2),PixelX=pick(-12,-8,8,12),PixelY=pick(-12,-8,8,12))
						if(m!=src.Owner.Grab)
							src.Owner.Knockback(src.Knockback+extraKnock, m, get_dir(src.Owner, m), extraKnock)

				if(src.Stunner)
					Stun(m, src.Stunner+src.Owner.GetStunningStrike())
					if(src.Stunner>5)
						m << "Your mind is under attack!"
						if(m.client)
							animate(m.client, color = list(-1,-1,-1, -1,-1,-1, -1,-1,-1, 1,1,1), time = 5)
							m.TsukiyomiTime=6
				if(src.Flash)
					if(!m.BlindImmune)
						m.Darkness(src.Flash*(10*world.tick_lag))
						m.RemoveTarget()
						m.Grab_Release()
						m.BlindImmune=world.time+(src.BlindImmuneDuration-1)

				if(Shearing)
					m.AddShearing(Shearing,src.Owner)

				if(src.Stasis)
					m.SetStasis(src.Stasis*world.tick_lag)

				if(src.Launcher&&!src.DelayedLauncher)
					var/Time=src.Launcher
					spawn()
						LaunchEffect(src.Owner, m, Time)

				if(src.WarpAway)
					WarpEffect(m, src.WarpAway)




				if(BuffAffected)

					var/path
					var/obj/Skills/Buffs/S
					var/AlreadyBuffed
					if(islist(BuffAffected))
						var/compare = buffAffectedCompare
						var/type = buffAffectedType
						if(compare)
							var/result = Owner.compareVariable(m, type, buffAffectedBoon)
							path = text2path(BuffAffected[result])
						else
							path = text2path(pick(BuffAffected))
					else if(istext(BuffAffected))
						path = text2path(BuffAffected)
					else
						path = BuffAffected
					S = new path
					if(m.SlotlessBuffs[S.BuffName])
						AlreadyBuffed = 1
					if(!AlreadyBuffed)
						var/buffFound=0
						for(var/obj/Skills/theBuff in m)
							if(theBuff.type == S.type)
								buffFound = 1
								var/list/nonoVars = list("client", "key", "loc", "x", "y", "z", "type", "locs", "parent_type", "verbs", "vars", "contents", "Transform", "appearance")
								for(var/x in theBuff.vars - nonoVars)
									if(x in nonoVars)
										continue // not possible?
									S.vars[x] = theBuff.vars[x]
								theBuff.adjust(Owner)
								break
						if(!buffFound)
							S.adjust(Owner)
							m.AddSkill(S)
						S.Password = m.name

				if(CorruptionDebuff)
					var/obj/Skills/Buffs/SlotlessBuffs/Ruin/ruin = m.SlotlessBuffs["Ruin"]
					if(!ruin)
						ruin = new/obj/Skills/Buffs/SlotlessBuffs/Ruin()
					ruin.applyStack(m)




			Life()
				if(src.loc == null) return
				if(AHOwner && AHOwner.UsesPixelCollision && !UsesPixelCollision)
					AH_InheritPixel(AHOwner) //offshoots skip the Z constructor
				if(ink_melee)
					InkMeleeStrike()
				if(PullIn && Owner)
					Owner.ApplyPullInArea(PullIn, PullIn)
				if(src.Circle)
					if(src.TargetLoc)
						if(src.Slow&&src.Distance>1)
							src.Owner.Frozen=1
							for(var/Rounds=1, Rounds<=src.DistanceMax, Rounds++)
								InkNewGroup()
								if(src.StepsDamage&&Rounds>1)
									src.Damage+=src.StepsDamage//add growing damage
								if(src.DistanceMax>=3 && !(FromSkill && FromSkill.SquareArea))//Greater than 3 distance, use circle
									for(var/turf/t in Turf_Circle(src.TargetLoc, Rounds))
										if(src.Divide)
											Destroy(t, 9001)
										if(src.TurfReplace)
											var/image/i=image(icon=src.TurfReplace)
											t.overlays+=i
											if(src.Deluge)
												t.effects+=i
												t.Deluged=1
												t.timeToDeath=Deluge
												t.ownerOfEffect=Owner
												ticking_turfs+=t

										if(src.TurfShift)
											sleep(-1)
											TurfShift(src.TurfShift,t, src.TurfShiftDuration,src.Owner, src.TurfShiftLayer, src.TurfShiftDurationSpawn, src.TurfShiftDurationDespawn, TurfShiftState,TurfShiftX, TurfShiftY)
										if(!UsesPixelCollision)
											for(var/mob/m in t.contents)
												if(!hitSelf&&m==src.Owner)
													continue
												src.Damage(m)
									if(UsesPixelCollision)
										AH_ZoneStrike(src.TargetLoc, Rounds, los=FALSE) //legacy Turf_Circle had no LOS
									for(var/turf/t in Turf_Circle_Edge(src.TargetLoc, Rounds))
										if(src.TurfErupt)
											InkBang(Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4))
										if(src.TurfIce)
											InkBang(Bang(t, Size=src.TurfIce, Offset=src.TurfIceOffset, Vanish=4, icon_override='SnowBurst2.dmi'))
										if(src.TurfFog)
											InkBang(Bang(t, Size=src.TurfFog, Offset=src.TurfFogOffset, Vanish=5, icon_override='FogBreath.dmi'))
										if(src.TurfDirt)
											Dust(t)
										if(src.TurfStrike)
											InkStrikeAt(t)
								else//Less than 3 distance, use square.
									if(src.TurfErupt)
										for(var/turf/t in view(Rounds, src.TargetLoc))
											if(t in view(Rounds-1, src.TargetLoc))
												continue
											InkBang(Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4))
									if(src.TurfIce)
										for(var/turf/t in view(Rounds, src.TargetLoc))
											if(t in view(Rounds-1, src.TargetLoc))
												continue
											InkBang(Bang(t, Size=src.TurfIce, Offset=src.TurfIceOffset, Vanish=4, icon_override='SnowBurst2.dmi'))
									if(src.TurfFog)
										for(var/turf/t in view(Rounds, src.TargetLoc))
											if(t in view(Rounds-1, src.TargetLoc))
												continue
											InkBang(Bang(t, Size=src.TurfFog, Offset=src.TurfFogOffset, Vanish=5, icon_override='FogBreath.dmi'))
									if(src.TurfDirt)
										for(var/turf/t in view(Rounds, src.TargetLoc))
											if(t in view(Rounds-1, src.TargetLoc))
												continue
											Dust(t)
									if(src.TurfStrike)
										for(var/turf/t in view(Rounds, src.TargetLoc))
											if(t in view(Rounds-1, src.TargetLoc))
												continue
											InkStrikeAt(t)
									if(src.Divide)
										for(var/turf/t in view(Rounds, src.TargetLoc))
											if(t in view(Rounds-1, src.TargetLoc))//Don't doublehit people
												continue
											Destroy(t, 9001)
									if(src.TurfReplace)
										for(var/turf/t in view(Rounds, src.TargetLoc))
											if(t in view(Rounds-1, src.TargetLoc))
												continue
											var/image/i=image(icon=src.TurfReplace)
											t.overlays+=i
											if(src.Deluge)
												t.effects+=i
												t.Deluged=1
												t.timeToDeath=Deluge
												t.ownerOfEffect=Owner
												ticking_turfs+=t
									if(src.TurfShift)
										for(var/turf/t in view(Rounds, src.TargetLoc))
											if(t in view(Rounds-1, src.TargetLoc))
												continue
											sleep(-1)
											TurfShift(src.TurfShift,t, src.TurfShiftDuration,src.Owner, src.TurfShiftLayer, src.TurfShiftDurationSpawn, src.TurfShiftDurationDespawn, TurfShiftState,TurfShiftX, TurfShiftY)
									if(UsesPixelCollision)
										AH_ZoneStrike(src.TargetLoc, Rounds, annulus=TRUE, los=!(FromSkill && FromSkill.SquareArea), square=(FromSkill && FromSkill.SquareArea))
									else
										for(var/mob/m in view(Rounds, src.TargetLoc))
											if(m in view(Rounds-1, src.TargetLoc))//Don't doublehit people
												continue
											if(!hitSelf&&m==src.Owner)
												continue
											src.Damage(m)
								sleep(src.Slow*world.tick_lag)
							src.Owner.Frozen=0
						else
							if(src.DistanceMax>=3 && !(FromSkill && FromSkill.SquareArea))//If greater than 3 distance...
								InkNewGroup()
								if(src.TurfErupt)
									for(var/turf/t in Turf_Circle_Edge(src.TargetLoc, src.Distance))
										sleep(-1)
										InkBang(Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4))
								if(src.TurfIce)
									for(var/turf/t in Turf_Circle_Edge(src.TargetLoc, src.Distance))
										sleep(-1)
										InkBang(Bang(t, Size=src.TurfIce, Offset=src.TurfIceOffset, Vanish=4, icon_override='SnowBurst2.dmi'))
								if(src.TurfFog)
									for(var/turf/t in Turf_Circle_Edge(src.TargetLoc, src.Distance))
										sleep(-1)
										InkBang(Bang(t, Size=src.TurfFog, Offset=src.TurfFogOffset, Vanish=5, icon_override='FogBreath.dmi'))
								if(src.TurfDirt)
									for(var/turf/t in Turf_Circle_Edge(src.TargetLoc, src.Distance))
										sleep(-1)
										Dust(t)
								if(src.TurfStrike)
									for(var/turf/t in Turf_Circle_Edge(src.TargetLoc, src.Distance))
										sleep(-1)
										InkStrikeAt(t)
								if(src.Divide)
									for(var/turf/t in Turf_Circle(src.TargetLoc, src.Distance))
										sleep(-1)
										Destroy(t, 9001)
								if(src.TurfReplace)
									for(var/turf/t in Turf_Circle(src.TargetLoc, src.Distance))
										var/image/i=image(icon=src.TurfReplace)
										t.overlays+=i
										if(src.Deluge)
											t.effects+=i
											t.Deluged=1
											t.timeToDeath=Deluge
											t.ownerOfEffect=Owner
											ticking_turfs+=t
								if(src.TurfShift)
									var/dist = Distance
									if(Persistent)
										dist /= 2
										dist = round(dist)
									for(var/turf/t in Turf_Circle(src.TargetLoc, dist))
										sleep(-1)
										TurfShift(src.TurfShift,t, src.TurfShiftDuration,src.Owner, src.TurfShiftLayer, src.TurfShiftDurationSpawn, src.TurfShiftDurationDespawn, TurfShiftState,TurfShiftX, TurfShiftY)
								if(UsesPixelCollision)
									AH_ZoneStrike(src.TargetLoc, src.Distance, los=FALSE) //legacy Turf_Circle had no LOS
								else
									for(var/turf/t in Turf_Circle(src.TargetLoc, src.Distance))
										sleep(-1)
										for(var/mob/m in t)
											if(!hitSelf && src.Owner == m) continue
											src.Damage(m)
							else//If less than 3 distance...
								InkNewGroup()
								if(src.TurfErupt)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.TargetLoc) : view(src.Distance, src.TargetLoc)))
										InkBang(Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4))
								if(src.TurfIce)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.TargetLoc) : view(src.Distance, src.TargetLoc)))
										InkBang(Bang(t, Size=src.TurfIce, Offset=src.TurfIceOffset, Vanish=4, icon_override='SnowBurst2.dmi'))
								if(src.TurfFog)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.TargetLoc) : view(src.Distance, src.TargetLoc)))
										InkBang(Bang(t, Size=src.TurfFog, Offset=src.TurfFogOffset, Vanish=5, icon_override='FogBreath.dmi'))
								if(src.TurfDirt)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.TargetLoc) : view(src.Distance, src.TargetLoc)))
										Dust(t)
								if(src.TurfStrike)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.TargetLoc) : view(src.Distance, src.TargetLoc)))
										InkStrikeAt(t)
								if(src.Divide)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.TargetLoc) : view(src.Distance, src.TargetLoc)))
										Destroy(t, 9001)
								if(src.TurfReplace)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.TargetLoc) : view(src.Distance, src.TargetLoc)))
										var/image/i=image(icon=src.TurfReplace)
										t.overlays+=i
										if(src.Deluge)
											t.effects+=i
											t.Deluged=1
											t.timeToDeath=Deluge
											t.ownerOfEffect=Owner
											ticking_turfs+=t
								if(src.TurfShift)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.TargetLoc) : view(src.Distance, src.TargetLoc)))
										sleep(-1)
										TurfShift(src.TurfShift,t, src.TurfShiftDuration,src.Owner, src.TurfShiftLayer, src.TurfShiftDurationSpawn, src.TurfShiftDurationDespawn, TurfShiftState,TurfShiftX, TurfShiftY)
								if(UsesPixelCollision)
									AH_ZoneStrike(src.TargetLoc, src.Distance, los=!(FromSkill && FromSkill.SquareArea), square=(FromSkill && FromSkill.SquareArea))
								else
									for(var/mob/m in view(src.Distance, src.TargetLoc))
										if(!hitSelf && src.Owner == m) continue
										src.Damage(m)
						goto Kill
					else

						//TODO: make hellstorm work here
						if(src.Slow&&src.Distance>1)
							src.Owner.Frozen=1
							for(var/Rounds=1, Rounds<=src.DistanceMax, Rounds++)
								InkNewGroup()
								if(src.StepsDamage&&Rounds>1)
									src.Damage+=src.StepsDamage//add growing damage
								if(src.DistanceMax>=3 && !(FromSkill && FromSkill.SquareArea))//Greater than 3 distance, use circle
									for(var/turf/t in Turf_Circle(src.Owner, Rounds))
										if(src.Divide)
											Destroy(t, 9001)
										if(src.TurfReplace)
											var/image/i=image(icon=src.TurfReplace)
											t.overlays+=i
											if(src.Deluge)
												t.effects+=i
												t.Deluged=1
												t.timeToDeath=Deluge
												t.ownerOfEffect=Owner
												ticking_turfs+=t
										if(src.TurfShift)
											sleep(-1)
											TurfShift(src.TurfShift,t, src.TurfShiftDuration,src.Owner, src.TurfShiftLayer, src.TurfShiftDurationSpawn, src.TurfShiftDurationDespawn, TurfShiftState,TurfShiftX, TurfShiftY)
										if(!UsesPixelCollision)
											for(var/mob/m in t.contents)
												if(!hitSelf&&m==src.Owner)
													continue
												src.Damage(m)
									if(UsesPixelCollision)
										AH_ZoneStrike(src.Owner, Rounds, los=FALSE) //legacy Turf_Circle had no LOS
									for(var/turf/t in Turf_Circle_Edge(src.Owner, Rounds))
										if(src.TurfErupt)
											InkBang(Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4))
										if(src.TurfIce)
											InkBang(Bang(t, Size=src.TurfIce, Offset=src.TurfIceOffset, Vanish=4, icon_override='SnowBurst2.dmi'))
										if(src.TurfFog)
											InkBang(Bang(t, Size=src.TurfFog, Offset=src.TurfFogOffset, Vanish=5, icon_override='FogBreath.dmi'))
										if(src.TurfDirt)
											Dust(t)
										if(src.TurfStrike)
											InkStrikeAt(t)
								else//Less than 3 distance, use square.
									if(src.TurfErupt)
										for(var/turf/t in view(Rounds, src.Owner))
											if(t in view(Rounds-1, src.Owner))
												continue
											InkBang(Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4))
									if(src.TurfIce)
										for(var/turf/t in view(Rounds, src.Owner))
											if(t in view(Rounds-1, src.Owner))
												continue
											InkBang(Bang(t, Size=src.TurfIce, Offset=src.TurfIceOffset, Vanish=4, icon_override='SnowBurst2.dmi'))
									if(src.TurfFog)
										for(var/turf/t in view(Rounds, src.Owner))
											if(t in view(Rounds-1, src.Owner))
												continue
											InkBang(Bang(t, Size=src.TurfFog, Offset=src.TurfFogOffset, Vanish=5, icon_override='FogBreath.dmi'))
									if(src.TurfDirt)
										for(var/turf/t in view(Rounds, src.Owner))
											if(t in view(Rounds-1, src.Owner))
												continue
											Dust(t)
									if(src.TurfStrike)
										for(var/turf/t in view(Rounds, src.Owner))
											if(t in view(Rounds-1, src.Owner))
												continue
											InkStrikeAt(t)
									if(src.Divide)
										for(var/turf/t in view(Rounds, src.Owner))
											if(t in view(Rounds-1, src.Owner))//Don't doublehit people
												continue
											Destroy(t, 9001)
									if(src.TurfReplace)
										for(var/turf/t in view(Rounds, src.Owner))
											if(t in view(Rounds-1, src.Owner))
												continue
											var/image/i=image(icon=src.TurfReplace)
											t.overlays+=i
											if(src.Deluge)
												t.effects+=i
												t.Deluged=1
												t.timeToDeath=Deluge
												t.ownerOfEffect=Owner
												ticking_turfs+=t
									if(src.TurfShift)
										for(var/turf/t in view(Rounds, src.Owner))
											if(t in view(Rounds-1, src.Owner))
												continue
											sleep(-1)
											TurfShift(src.TurfShift,t, src.TurfShiftDuration,src.Owner, src.TurfShiftLayer, src.TurfShiftDurationSpawn, src.TurfShiftDurationDespawn, TurfShiftState,TurfShiftX, TurfShiftY)
									if(UsesPixelCollision)
										AH_ZoneStrike(src.Owner, Rounds, annulus=TRUE, los=!(FromSkill && FromSkill.SquareArea), square=(FromSkill && FromSkill.SquareArea))
									else
										for(var/mob/m in view(Rounds, src.Owner))
											if(m in view(Rounds-1, src.Owner))//Don't doublehit people
												continue
											if(!hitSelf&&m==src.Owner)
												continue
											src.Damage(m)
								sleep(src.Slow*world.tick_lag)
							src.Owner.Frozen=0
						else
							if(src.DistanceMax>=3 && !(FromSkill && FromSkill.SquareArea))//If greater than 3 distance...
								InkNewGroup()
								if(src.TurfErupt)
									for(var/turf/t in Turf_Circle_Edge(src.Owner, src.Distance))
										sleep(-1)
										InkBang(Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4))
								if(src.TurfIce)
									for(var/turf/t in Turf_Circle_Edge(src.Owner, src.Distance))
										sleep(-1)
										InkBang(Bang(t, Size=src.TurfIce, Offset=src.TurfIceOffset, Vanish=4, icon_override='SnowBurst2.dmi'))
								if(src.TurfFog)
									for(var/turf/t in Turf_Circle_Edge(src.Owner, src.Distance))
										sleep(-1)
										InkBang(Bang(t, Size=src.TurfFog, Offset=src.TurfFogOffset, Vanish=5, icon_override='FogBreath.dmi'))
								if(src.TurfDirt)
									for(var/turf/t in Turf_Circle_Edge(src.Owner, src.Distance))
										sleep(-1)
										Dust(t)
								if(src.TurfStrike)
									for(var/turf/t in Turf_Circle_Edge(src.Owner, src.Distance))
										sleep(-1)
										InkStrikeAt(t)
								if(src.Divide)
									for(var/turf/t in Turf_Circle(src.Owner, src.Distance))
										sleep(-1)
										Destroy(t, 9001)
								if(src.TurfReplace)
									for(var/turf/t in Turf_Circle(src.Owner, src.Distance))
										sleep(-1)
										var/image/i=image(icon=src.TurfReplace)
										t.overlays+=i
										if(src.Deluge)
											t.effects+=i
											t.Deluged=1
											t.timeToDeath=Deluge
											t.ownerOfEffect=Owner
											ticking_turfs+=t
								if(src.TurfShift)
									for(var/turf/t in Turf_Circle(src.Owner, src.Distance))
										sleep(-1)
										TurfShift(src.TurfShift,t, src.TurfShiftDuration,src.Owner, src.TurfShiftLayer, src.TurfShiftDurationSpawn, src.TurfShiftDurationDespawn, TurfShiftState,TurfShiftX, TurfShiftY)
								if(UsesPixelCollision)
									AH_ZoneStrike(src.Owner, src.Distance, los=FALSE) //legacy Turf_Circle had no LOS
								else
									for(var/turf/t in Turf_Circle(src.Owner, src.Distance))
										sleep(-1)
										for(var/mob/m in t)
											if(!hitSelf && src.Owner == m) continue
											src.Damage(m)
							else//If less than 3 distance...
								InkNewGroup()
								if(src.TurfErupt)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.Owner) : view(src.Distance, src.Owner)))
										InkBang(Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4))
								if(src.TurfIce)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.Owner) : view(src.Distance, src.Owner)))
										InkBang(Bang(t, Size=src.TurfIce, Offset=src.TurfIceOffset, Vanish=4, icon_override='SnowBurst2.dmi'))
								if(src.TurfFog)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.Owner) : view(src.Distance, src.Owner)))
										InkBang(Bang(t, Size=src.TurfFog, Offset=src.TurfFogOffset, Vanish=5, icon_override='FogBreath.dmi'))
								if(src.TurfDirt)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.Owner) : view(src.Distance, src.Owner)))
										Dust(t)
								if(src.TurfStrike)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.Owner) : view(src.Distance, src.Owner)))
										InkStrikeAt(t)
								if(src.Divide)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.Owner) : view(src.Distance, src.Owner)))
										Destroy(t, 9001)
								if(src.TurfReplace)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.Owner) : view(src.Distance, src.Owner)))
										var/image/i=image(icon=src.TurfReplace)
										t.overlays+=i
										if(src.Deluge)
											t.effects+=i
											t.Deluged=1
											t.timeToDeath=Deluge
											t.ownerOfEffect=Owner
											ticking_turfs+=t
								if(src.TurfShift)
									for(var/turf/t in ((FromSkill && FromSkill.SquareArea) ? range(src.Distance, src.Owner) : view(src.Distance, src.Owner)))
										sleep(-1)
										TurfShift(src.TurfShift,t, src.TurfShiftDuration,src.Owner, src.TurfShiftLayer, src.TurfShiftDurationSpawn, src.TurfShiftDurationDespawn, TurfShiftState,TurfShiftX, TurfShiftY)
								if(UsesPixelCollision)
									AH_ZoneStrike(src.Owner, src.Distance, los=!(FromSkill && FromSkill.SquareArea), square=(FromSkill && FromSkill.SquareArea))
								else
									for(var/mob/m in view(src.Distance, src.Owner))
										if(!hitSelf&&src.Owner==m) continue
										src.Damage(m)
						goto Kill
				if(src.Target)
					if(src.Slow)
						src.Owner.Frozen=1
						sleep(src.Slow*world.tick_lag)
						InkTargetStrike(src.Owner.Target)
						src.Owner.Frozen=0
					else
						InkTargetStrike(src.Target)
					goto Kill
				while(src.Distance>0)
					if(src.Cardinal)
						if(!src.CardinalTriggered)
							new/obj/AutoHitter/CrossOffshoot(src, 1)//Left
							new/obj/AutoHitter/CrossOffshoot(src, 2)//Back
							new/obj/AutoHitter/CrossOffshoot(src, 0)//Right
							src.CardinalTriggered=1
					if(UsesPixelCollision)
						AH_PixelStep()
					else
						step(src, src.dir)
					if(src.StepsDamage&&src.StepsTaken>=1)
						src.Damage+=src.StepsDamage//add growing damage
					src.Distance--
					src.StepsTaken++
					InkNewGroup()
					var/tsx = (PmActive() ? src.step_x : 0) //offset turf VFX to the mid-tile sprite
					var/tsy = (PmActive() ? src.step_y : 0)
					if(src.TurfErupt)
						InkBang(Bang(src.loc, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4, PX=tsx, PY=tsy))
					if(src.TurfIce)
						InkBang(Bang(src.loc, Size=src.TurfIce, Offset=src.TurfIceOffset, Vanish=4, PX=tsx, PY=tsy, icon_override='SnowBurst2.dmi'))
					if(src.TurfFog)
						InkBang(Bang(src.loc, Size=src.TurfFog, Offset=src.TurfFogOffset, Vanish=5, PX=tsx, PY=tsy, icon_override='FogBreath.dmi'))
					if(src.TurfDirt)
						Dust(src.loc)
					if(src.TurfStrike)
						InkStrikeAt(src.loc, tsx, tsy)
					if(src.Divide)
						Destroy(src.loc, 9001)
					if(src.TurfReplace)
						var/image/i=image(icon=src.TurfReplace)
						var/turf/t=src.loc
						t.overlays+=i
						spawn(6000)
							t.overlays-=i
					if(src.TurfShift)
						sleep(-1)
						TurfShift(src.TurfShift, src.loc, src.TurfShiftDuration, src.Owner, src.TurfShiftLayer, src.TurfShiftDurationSpawn,src.TurfShiftDurationDespawn , TurfShiftState, TurfShiftX, TurfShiftY)

					if(src.Arcing)
						var/Arc=0
						if(src.Arcing>1)
							if(src.Distance%src.Arcing==0)
								Arc=1
						else
							Arc=1
						if(Arc==1)
							src.ArcingCount++
						if(src.ArcingCount>0)
							new/obj/AutoHitter/ArcOffshoot(src, 1, 0)//Left
							new/obj/AutoHitter/ArcOffshoot(src, 0, 0)//Right
						if(src.Distance==src.DistanceMax-1)//first step of arcs
							new/obj/AutoHitter/ArcOffshoot(src, 1, 1)//hit them sides boi
							new/obj/AutoHitter/ArcOffshoot(src, 0, 1)
					if(src.Wave)
						new/obj/AutoHitter/WaveOffshoot(src, 1)
						new/obj/AutoHitter/WaveOffshoot(src, 0)
					sleep(src.Slow*world.tick_lag)
				if(RagingDemonAnimation)
					world.log<<"we get here"
				Kill//Label
				spawn()
					if(src.Wander)
						walk_rand(src, 5)
						animate(src, transform=matrix()*src.WanderSize, time=src.Wander*5)
						sleep(src.Wander*5)
					if(!Persistent)
						endLife()
		ArcOffshoot
			Arcing=0
			var
				Side//1 for left, 0 for right

			New(var/obj/AutoHitter/AH, var/side, var/FromMob=0)
				AHOwner = AH
				src.Owner=AH.Owner
				src.Side=side
				AlreadyHit = list()
				autohitChildren = list()
				AH.autohitChildren += src
				if(src.Side)
					if(src.Owner.dir!=NORTHEAST&&src.Owner.dir!=NORTHWEST&&src.Owner.dir!=SOUTHEAST&&src.Owner.dir!=SOUTHWEST)
						src.dir=turn(AH.dir, -90)
					else
						src.dir=turn(AH.dir, -45)
				else
					if(src.Owner.dir!=NORTHEAST&&src.Owner.dir!=NORTHWEST&&src.Owner.dir!=SOUTHEAST&&src.Owner.dir!=SOUTHWEST)
						src.dir=turn(AH.dir, 90)
					else
						src.dir=turn(AH.dir, 45)

				src.DistanceMax=AH.ArcingCount
				src.Distance=src.DistanceMax

				src.Damage=AH.Damage
				src.FromSkill=AH.FromSkill
				src.StrDmg=AH.StrDmg
				src.ForDmg=AH.ForDmg
				src.SpellElement=AH.SpellElement
				src.EndRes=AH.EndRes
				src.Knockback=AH.Knockback
				src.ChargeTech=AH.ChargeTech
				src.UnarmedTech=AH.UnarmedTech
				src.SwordTech=AH.SwordTech
//				src.Electrifying=AH.Electrifying
				src.Deluge=AH.Deluge
				src.Stunner=AH.Stunner
				src.Destructive=AH.Destructive
				src.FrenzyDebuff=AH.FrenzyDebuff
				src.Bang=AH.Bang
				src.Bolt=AH.Bolt
				src.Scratch=AH.Scratch
				src.Divide=AH.Divide
				src.TurfReplace=AH.TurfReplace
				src.TurfShift=AH.TurfShift
				src.TurfShiftLayer=AH.TurfShiftLayer
				src.TurfShiftDuration=AH.TurfShiftDuration
				src.TurfShiftDurationSpawn=AH.TurfShiftDurationSpawn
				src.TurfShiftDurationDespawn=AH.TurfShiftDurationDespawn
				src.TurfShiftState=AH.TurfShiftState
				src.TurfShiftX=AH.TurfShiftX
				src.TurfShiftY=AH.TurfShiftY
				src.TurfErupt=AH.TurfErupt
				src.TurfEruptOffset=AH.TurfEruptOffset
				src.TurfIce=AH.TurfIce
				src.TurfIceOffset=AH.TurfIceOffset
				src.TurfFog=AH.TurfFog
				src.TurfFogOffset=AH.TurfFogOffset
				src.TurfDirt=AH.TurfDirt
				src.TurfDirtOffset=AH.TurfDirtOffset
				src.TurfStrike=AH.TurfStrike
				src.CanBeBlocked=AH.CanBeBlocked
				src.CanBeDodged=AH.CanBeDodged
				src.Wander=AH.Wander
				src.WanderSize=AH.WanderSize
				src.Stasis=AH.Stasis
				src.MortalBlow=AH.MortalBlow
				src.WarpAway=AH.WarpAway
				src.Launcher=AH.Launcher
				src.DelayedLauncher=AH.DelayedLauncher

				if(AH.ObjIcon)
					src.ObjIcon=AH.ObjIcon
					src.icon=AH.icon
					src.pixel_x=AH.pixel_x
					src.pixel_y=AH.pixel_y

				src.loc=AH.loc
				if(FromMob)//only called on first step of arc
					src.loc=src.Owner.loc

				src.Life()
		WaveOffshoot
			Arcing=0
			var
				Side//1 for left, 0 for right
			New(var/obj/AutoHitter/AH, var/side)
				AHOwner = AH
				src.Owner=AH.Owner
				AlreadyHit = list()
				autohitChildren = list()
				AH.autohitChildren += src
				src.Side=side
				if(src.Side)
					src.dir=turn(AH.dir, -90)
				else
					src.dir=turn(AH.dir, 90)
				src.DistanceMax=AH.Wave
				src.Distance=src.DistanceMax

				src.Damage= AH.Damage / glob.AUTOHIT_WAVE_OFFSHOOT_DAMAGE_DIVISOR
				src.FromSkill=AH.FromSkill
				src.StrDmg=AH.StrDmg
				src.ForDmg=AH.ForDmg
				src.SpellElement=AH.SpellElement
				src.EndRes=AH.EndRes
				src.Knockback=AH.Knockback
				src.ChargeTech=AH.ChargeTech
				src.UnarmedTech=AH.UnarmedTech
				src.SwordTech=AH.SwordTech
				src.Deluge=AH.Deluge
				src.Stunner=AH.Stunner
				src.Destructive=AH.Destructive
				src.FrenzyDebuff=AH.FrenzyDebuff
				src.Bang=AH.Bang
				src.Bolt=AH.Bolt
				src.Scratch=AH.Scratch
				src.Divide=AH.Divide
				src.TurfReplace=AH.TurfReplace
				src.TurfShift=AH.TurfShift
				src.TurfShiftLayer=AH.TurfShiftLayer
				src.TurfShiftDuration=AH.TurfShiftDuration
				src.TurfShiftDurationSpawn=AH.TurfShiftDurationSpawn
				src.TurfShiftDurationDespawn=AH.TurfShiftDurationDespawn
				src.TurfShiftState=AH.TurfShiftState
				src.TurfShiftX=AH.TurfShiftX
				src.TurfShiftY=AH.TurfShiftY
				src.TurfErupt=AH.TurfErupt
				src.TurfEruptOffset=AH.TurfEruptOffset
				src.TurfIce=AH.TurfIce
				src.TurfIceOffset=AH.TurfIceOffset
				src.TurfFog=AH.TurfFog
				src.TurfFogOffset=AH.TurfFogOffset
				src.TurfDirt=AH.TurfDirt
				src.TurfDirtOffset=AH.TurfDirtOffset
				src.TurfStrike=AH.TurfStrike
				src.CanBeBlocked=AH.CanBeBlocked
				src.CanBeDodged=AH.CanBeDodged
				src.Wander=AH.Wander
				src.WanderSize=AH.WanderSize
				src.Stasis=AH.Stasis
				src.MortalBlow=AH.MortalBlow
				src.WarpAway=AH.WarpAway
				src.Launcher=AH.Launcher
				src.DelayedLauncher=AH.DelayedLauncher

				if(AH.ObjIcon)
					src.ObjIcon=AH.ObjIcon
					src.icon=AH.icon
					src.pixel_x=AH.pixel_x
					src.pixel_y=AH.pixel_y

				src.loc=AH.loc

				src.Life()
		CrossOffshoot
			Cardinal=0
			var
				Side//1 for left, 2 for back, 0 for right.
			New(var/obj/AutoHitter/AH, var/side)
				AHOwner = AH
				src.Owner=AH.Owner
				AlreadyHit = list()
				autohitChildren = list()
				AH.autohitChildren += src
				src.Side=side
				if(src.Side==1)
					src.dir=turn(AH.dir, -90)
				else if(src.Side==2)
					src.dir=turn(AH.dir, -180)
				else
					src.dir=turn(AH.dir, 90)
				src.DistanceMax=AH.DistanceMax
				src.Distance=src.DistanceMax

				src.Damage=AH.Damage
				src.FromSkill=AH.FromSkill
				src.StepsDamage=AH.StepsDamage
				src.StrDmg=AH.StrDmg
				src.ForDmg=AH.ForDmg
				src.SpellElement=AH.SpellElement
				src.EndRes=AH.EndRes
				src.Knockback=AH.Knockback
				src.ChargeTech=AH.ChargeTech
				src.UnarmedTech=AH.UnarmedTech
				src.SwordTech=AH.SwordTech
				src.Stunner=AH.Stunner
				src.Deluge=AH.Deluge
				src.Destructive=AH.Destructive
				src.FrenzyDebuff=AH.FrenzyDebuff
				src.Bang=AH.Bang
				src.Bolt=AH.Bolt
				src.Scratch=AH.Scratch
				src.Divide=AH.Divide
				src.TurfReplace=AH.TurfReplace
				src.TurfShift=AH.TurfShift
				src.TurfShiftLayer=AH.TurfShiftLayer
				src.TurfShiftDuration=AH.TurfShiftDuration
				src.TurfShiftDurationSpawn=AH.TurfShiftDurationSpawn
				src.TurfShiftDurationDespawn=AH.TurfShiftDurationDespawn
				src.TurfShiftState=AH.TurfShiftState
				src.TurfShiftX=AH.TurfShiftX
				src.TurfShiftY=AH.TurfShiftY
				src.TurfErupt=AH.TurfErupt
				src.TurfEruptOffset=AH.TurfEruptOffset
				src.TurfDirt=AH.TurfDirt
				src.TurfDirtOffset=AH.TurfDirtOffset
				src.TurfStrike=AH.TurfStrike
				src.CanBeBlocked=AH.CanBeBlocked
				src.CanBeDodged=AH.CanBeDodged
				src.Slow=AH.Slow
				src.Wander=AH.Wander
				src.Stasis=AH.Stasis
				src.MortalBlow=AH.MortalBlow
				src.WarpAway=AH.WarpAway
				src.Launcher=AH.Launcher
				src.DelayedLauncher=AH.DelayedLauncher


				if(AH.ObjIcon)
					src.ObjIcon=AH.ObjIcon
					src.icon=AH.icon
					src.pixel_x=AH.pixel_x
					src.pixel_y=AH.pixel_y

				src.loc=AH.loc

				src.Life()

/mob
	var
		tmp/Suspended = null
		tmp/ActionLocked = null
		tmp/judgement_cut_chain_active = FALSE
		tmp/judgement_cut_bonus_value = 1
		tmp/judgement_cut_bonus_chain_count = 0
		tmp/judgement_cut_bonus_end_time = 0

/obj/Skills/AutoHit/Judgement_Cut
	SkillCost=TIER_5_COST
	name = "Judgement Cut"
	Area = "Target"
	NeedsSword=1
	Distance = 8
	DamageMult = 7.75
	StrScaling = 1
	EndEffectiveness = 1
	Copyable=6
	Cooldown = 30
	EnergyCost = 8
	ComboMaster = 1
	GuardBreak = 1
	NoLock = 1
	NoAttackLock = 1
	ChargeWaveIcon   = 'BLANK.dmi'
	ActiveMessage = "tears through space with a Judgement Cut!"

	HeldSkill = TRUE
	ChargePeriod = 3
	SweetSpot = 1.5
	SweetSpotBenefit = 1.5

	var/tmp/chain_active = FALSE
	var/tmp/chain_count = 0
	var/tmp/mob/chain_user = null
	var/tmp/mob/chain_target = null
	var/tmp/initial_charge_period = 3
	var/tmp/saved_cooldown = 30
	var/tmp/reengage_deadline = 0
	var/tmp/window_loop_running = FALSE
	var/tmp/overlay_loop_running = FALSE

	proc/RollSweetSpot()
		var/min_ss = 3
		var/period_ticks = round(ChargePeriod * 10)
		var/window_ticks = max(1, round(SweetSpotWindow * 10))
		var/max_ss = max(min_ss, period_ticks - window_ticks)
		return rand(min_ss, max_ss) / 10

	proc/StartChain(mob/user, mob/target)
		chain_active = TRUE
		chain_user = user
		chain_target = target
		chain_count = 0
		DamageMult = 7.75
		ChargePeriod = initial_charge_period
		SweetSpotWindow = 0.3
		SweetSpot = RollSweetSpot()
		user.judgement_cut_chain_active = TRUE
		saved_cooldown = Cooldown > 0 ? Cooldown : initial(Cooldown)
		Cooldown = 0
		if(!overlay_loop_running)
			overlay_loop_running = TRUE
			spawn() SlashOverlayLoop()

	proc/EndChain(var/apply_cooldown = TRUE)
		if(!chain_active) return
		var/mob/user = chain_user
		chain_active = FALSE
		window_loop_running = FALSE
		if(user)
			user.judgement_cut_chain_active = FALSE
		chain_user = null
		chain_target = null
		chain_count = 0
		DamageMult = initial(DamageMult)
		ChargePeriod = initial_charge_period
		SweetSpotWindow = 0.3
		SweetSpot = initial_charge_period / 2
		Cooldown = saved_cooldown > 0 ? saved_cooldown : initial(Cooldown)
		if(user)
			Using = 0
			cooldown_remaining = 0
			cooldown_start = 0
			if(apply_cooldown)
				src.Cooldown(1, null, user)

	proc/SlashOverlayLoop()
		while(chain_active)
			if(!chain_target || chain_target.KO || chain_target.Stasis > 0 || chain_target.Health <= 0)
				if(chain_user && chain_user.held_skill == src)
					chain_user.FizzleHeldSkill(src)
				else
					EndChain()
				break
			if(chain_user && chain_user.held_skill == src)
				var/obj/Effects/HE = new(null, 'Slash - Future.dmi', -32, -32, 0, 1, 6)
				HE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
				HE.transform = matrix().Turn(rand(0, 359))
				HE.Target = chain_target
				chain_target.vis_contents += HE
			sleep(1)
		overlay_loop_running = FALSE

	proc/ScheduleReengageWindow(mob/user)
		if(window_loop_running) return
		window_loop_running = TRUE
		reengage_deadline = world.time + 10
		while(world.time < reengage_deadline)
			if(!chain_active)
				window_loop_running = FALSE
				return
			if(user.Stunned || user.Suspended || user.Launched || user.Stasis > 0 || user.KO)
				window_loop_running = FALSE
				EndChain()
				return
			if(!chain_target || chain_target.KO || chain_target.Stasis > 0 || chain_target.Health <= 0)
				window_loop_running = FALSE
				EndChain()
				return
			// hold has started again.
			if(user.held_skill == src)
				window_loop_running = FALSE
				reengage_deadline = world.time + 10
				return
			sleep(1)
		// Window expired
		if(chain_active && (!user.held_skill || user.held_skill != src))
			window_loop_running = FALSE
			EndChain()

	OnHeldRelease(mob/p, var/benefit, var/sweet_spot_hit = FALSE)
		if(!chain_active) return
		if(!sweet_spot_hit)
			EndChain()
			return
		if(!chain_target || chain_target.KO || chain_target.Stasis > 0 || chain_target.Health <= 0)
			EndChain()
			return
		chain_count++
		DamageMult = 7.75 * min(1.2 ** (chain_count - 1), 2.5)
		p.Target = chain_target
		p.Activate(src, ignoreCuck=TRUE, ignoreAttackLock=TRUE, noGCD=TRUE)
		p.judgement_cut_bonus_value = min(1.2 ** (chain_count - 1), 2.5)
		p.judgement_cut_bonus_chain_count = chain_count
		p.judgement_cut_bonus_end_time = world.time + 30
		ChargePeriod = max(0.6, initial_charge_period - (chain_count * 0.3))
		SweetSpotWindow = max(0.1, ChargePeriod * 0.1)
		SweetSpot = RollSweetSpot()
		p.held_skill_last_release = 0
		spawn() ScheduleReengageWindow(p)

	OnHeldFizzle(mob/p)
		if(chain_active)
			EndChain()
		// Safety net
		if(p)
			p.judgement_cut_chain_active = FALSE

	verb/Judgement_Cut()
		set category = "Skills"
		var/mob/p = usr
		if(!chain_active && cooldown_remaining)
			p << "<font color='red'>[name] is on cooldown.</font>"
			return
		if(!chain_active)
			if(!p.Target || p.Target == p || !ismob(p.Target))
				p << "<font color='red'>You need a target.</font>"
				return
			var/mob/T = p.Target
			if(T.KO || T.Stasis > 0 || T.Health <= 0)
				p << "<font color='red'>Invalid target.</font>"
				return
			if(get_dist(p, T) > Distance)
				p << "<font color='red'>Target is out of range.</font>"
				return
			StartChain(p, T)
		else
			if(world.time > reengage_deadline)
				EndChain()
				return
		p.BeginHeldSkill(src)
		if(p.held_skill != src && chain_active && chain_user == p)
			EndChain(apply_cooldown = FALSE)

/obj/Skills/AutoHit/Wave
	var/WaveIcon = 'KenShockwave.dmi'
	var/WaveMaxSize = 4
	var/WaveLifetime = 20
	var/WaveRampUp = 0 //damage ramps from nothing point blank to full at 75% radius
	var/WaveMeleeExclusion = 0 //point blank doesn't get clipped at all
	var/WaveHitBurstIcon = 'fevExplosion - Hellfire.dmi'
	proc/spawnWave(mob/Players/user)
		var/obj/Effects/SkillWave/W = new(user.loc)
		W.owner = user
		W.icon = WaveIcon
		W.max_size = WaveMaxSize
		W.wave_lifetime = WaveLifetime
		W.rampUp = WaveRampUp
		W.meleeExclusion = WaveMeleeExclusion
		W.HitBurstIcon = WaveHitBurstIcon
		W.DamageMult = DamageMult
		W.StrScaling = StrScaling
		W.ForScaling = ForScaling
		W.EndScaling = EndScaling
		W.EndEffectiveness = EndEffectiveness
		W.CritEffectiveness = CritEffectiveness
		W.BlockEffectiveness = BlockEffectiveness
		W.CritChanceBonus = CritChanceBonus
		W.SpdScaling = SpdScaling
		W.OffScaling = OffScaling
		W.DefScaling = DefScaling
		W.UsesStr = UsesStr
		W.UsesFor = UsesFor
		W.UsesSpd = UsesSpd
		W.UsesEnd = UsesEnd
		W.UsesDef = UsesDef
		W.UsesOff = UsesOff
		W.dmgTypes = buildSpecDmgTypes(SlayerMod)
		return W

/obj/Effects/SkillWave
	icon = 'KenShockwave.dmi'
	pixel_x = -105
	pixel_y = -105
	Grabbable = 0
	mouse_opacity = 0
	layer = EFFECTS_LAYER
	var/max_size = 4
	var/wave_lifetime = 20
	var/rampUp = 0
	var/meleeExclusion = 0
	var/HitBurstIcon = 'fevExplosion - Hellfire.dmi'
	var/DamageMult = 1
	var/StrScaling = 0
	var/ForScaling = 0
	var/EndScaling = 0
	var/EndEffectiveness = 1
	var/CritEffectiveness = 0
	var/BlockEffectiveness = 1
	var/CritChanceBonus = 0
	var/SpdScaling = 0
	var/OffScaling = 0
	var/DefScaling = 0
	var/UsesStr = 0
	var/UsesFor = 0
	var/UsesSpd = 0
	var/UsesEnd = 0
	var/UsesDef = 0
	var/UsesOff = 0
	proc/BaseStatOverride(mob/M)
		if(UsesStr) return M.GetStr(1)
		if(UsesFor) return M.GetFor(1)
		if(UsesSpd) return M.GetSpd(1)
		if(UsesEnd) return M.GetEnd(1)
		if(UsesDef) return M.GetDef(1)
		if(UsesOff) return M.GetOff(1)
		return 0
	proc/FocusStatIdentity()
		if(UsesStr) return "STR"
		if(UsesFor) return "FOR"
		if(UsesSpd || UsesEnd || UsesDef || UsesOff) return null
		return "STR"
	var/tmp/mob/Players/owner
	var/tmp/list/hitList = list()
	var/tmp/list/dmgTypes = null
	var/tmp/datum/fxink/wave_ink

	New()
		animate(src)
		transform = matrix() * 0.1
		alpha = 255
		spawn(0)
			hitDetectLoop()

	proc/hitDetectLoop()
		set waitfor = FALSE
		var/start_time = world.time
		while(src)
			var/tick_begin = world.time
			if(!owner || !owner.loc) break
			if(owner.PureRPMode)
				sleep(1)
				start_time += (world.time - tick_begin)
				continue
			var/elapsed = world.time - start_time
			if(elapsed >= wave_lifetime)
				EffectFinish()
				break
			var/t = elapsed / wave_lifetime
			var/scale = 0.1 + (max_size - 0.1) * t
			src.transform = matrix() * scale
			src.alpha = round(255 * (1 - t))
			if(!wave_ink)
				wave_ink = FxInkManualRing(icon)
			wave_ink.mscale = scale
			wave_ink.malpha = src.alpha
			wave_ink.cx = 1 + (x-1)*32 + step_x + pixel_x + wave_ink.cw/2
			wave_ink.cy = 1 + (y-1)*32 + step_y + pixel_y + wave_ink.ch/2
			if(src.alpha >= FxInkAlphaMin())
				for(var/mob/Players/P in players)
					if(!P.client) continue
					if(P == owner) continue
					if(P.z != owner.z) continue
					if(!P.density) continue
					if(owner.inParty(P.ckey)) continue
					if(P in hitList) continue
					var/dx = P.x - owner.x
					var/dy = P.y - owner.y
					if(meleeExclusion && max(abs(dx), abs(dy)) <= 1) continue
					if(!wave_ink.Hits(P, elapsed, BodyInkProbe(P))) continue
					hitList += P
					dealWaveDamage(P, sqrt(dx*dx + dy*dy))
			sleep(1)

	proc/dealWaveDamage(mob/Players/target, dist_tiles)
		if(!owner || !target) return
		if(owner.PureRPMode) return
		var/powerDif = owner.Power / target.Power
		if(glob.CLAMP_POWER && !owner.ignoresPowerClamp(target))
			powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
		var/wIdnt = FocusStatIdentity()
		var/wStr = owner.FocusShiftScaling(wIdnt, "STR", StrScaling)
		var/wFor = owner.FocusShiftScaling(wIdnt, "FOR", ForScaling)
		var/atk = (BaseStatOverride(owner) || owner.getStatDmg2(autohit = TRUE)) + (wStr ? owner.GetStr(wStr) : 0) + (wFor ? owner.GetFor(wFor) : 0) + (SpdScaling ? owner.GetSpd(SpdScaling) : 0) + (OffScaling ? owner.GetOff(OffScaling) : 0) + (DefScaling ? owner.GetDef(DefScaling) : 0) + (EndScaling ? owner.GetEnd(EndScaling) : 0)
		var/def = target.getEndStat(1) * EndEffectiveness
		var/FinalDmg = strikeCoreDamage(powerDif, atk, def)
		FinalDmg *= DamageMult
		if(rampUp)
			var/full_at = ((max_size * 121.0) / 32.0) * 0.75
			var/denom = full_at - 1
			if(denom <= 0) denom = 0.01
			FinalDmg *= clamp((dist_tiles - 1) / denom, 0, 1)
		FinalDmg *= owner.strikeJudgmentMult()
		FinalDmg *= glob.AUTOHIT_GLOBAL_DAMAGE
		if(FinalDmg <= 0) return
		var/prevAutoHit = owner.AutoHitting
		owner.AutoHitting = TRUE
		var/strike/S = new(owner, target, FinalDmg)
		S.autohit = 1
		S.dmgTypes = dmgTypes
		S.critEff = CritEffectiveness
		S.blockEff = BlockEffectiveness
		S.critBonus = CritChanceBonus
		S.resolve()
		owner.AutoHitting = prevAutoHit
		if(HitBurstIcon)
			var/obj/Effects/HE = new(null, HitBurstIcon, -32, -32, 0, 1, 8)
			HE.appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			HE.Target = target
			target.vis_contents += HE
