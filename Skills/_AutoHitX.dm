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
				var/aaa = p.Activate(src)
				return aaa
			Distance=1//Unless otherwise stated, assume it's a one tile attack of varying style.
			var/DistanceAround //this is only used for AroundTarget type techs.
			var
				Cleansing = 0
				ManaDrain = 0
				HitSelf = 0
				Snaring
				SnaringOverlay
				NoPierce=0//If this is flagged it will make a technique terminate after hitting something.
				CorruptionGain = 0
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
				StepsDamage//Every step adds this value to damage mult.
				Knockback//Does the technique knockback?  If so, how far?
				while_warping = FALSE
				//Cooldown

				//These four can be used in any combination.
				StrOffense//Uses STR for damage.
				ForOffense//Uses FOR for damage.
				EndDefense=1//Uses End for reduction.
				Area//variable to define what kind of hitzone to use.
				ChargeTech//Denotes if there is a charge
				ChargeTime//How much time it takes to move.
				ChargeFlight//superman tackle
				WindUp//Charge for this number of seconds.
				Slow//Makes it so that there is a pause in the movement of autohitters (The technique does not instantly hit all of its related tiles)
				ApplySlow = 0
				Icon//Displays icon when used.
				IconX//Offsets.
				IconY
				IconZ
				Falling//should pixel_z animate towards 0?
				IconUnder=0
				IconTime=5//Duration of effect.
				Size//Makes icon bigger.
				ObjIcon//Makes autohit objects take on the appearance of the icon vars instead of the user.
				NoOverlay//Skip overlay code
				//These blend colors into the overlay
				IconRed=0
				IconGreen=0
				IconBlue=0


				Deluge//Makes water drown you
				Stasis//Makes you unable to do anything but can't be damaged.

				Rounds//Triggers multiple skillshots.
				RoundMovement=1//If this is 0, lock movement while using rounds.
				currentRounds
				DelayTime=1//time between attacks...
				NoLock//Doesn't lock autohitting.
				NoAttackLock

				Bang//defines if it causes an explosion on hit
				Bolt//shoot some lightning at motherfuckers
				BoltOffset //make lightning go scatter
				Scratch//scratch effects
				Punt//punch effects

				Divide//Great divide effect.
				TurfErupt//makes a boom
				TurfEruptOffset=0//affects the offset of booms
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
				WindupCustom//Allows for complete writing of text.
				ActiveMessage//Text for using the tech.
				ActiveColor=rgb(255,0,0)//Holds a hex value for color
				ActiveCustom//Allows for complete writing of text.

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

				//These variables are used to apply ki blade-like effects.
				TempStrOff
				TempForOff
				TempEndDef
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
				DarkCharge//evil sword technique FX

				Wander//At the end of the autohit's life, wander in random directions for this number of moves.
				Rush//Drives the user forward before deploying autohit.
				RushDelay=1
				ControlledRush//as above but you actually know where you're going
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

				ForceCost = 0

				PullIn

				GoldScatter

				DefTax
				OffTax
			skillDescription()
				..()
				if(StrOffense)
					description += "Strength Damage %: [StrOffense*100]\n"
				if(ForOffense)
					description += "Force Damage %: [ForOffense*100]\n"
				if(EndDefense<1)
					description += "Endurance Ignoring: [1-EndDefense]%\n"
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
//NPC attacks
			Venom_Sting
				Area="Target"
				Distance=2
				DamageMult=1
				StrOffense=1
				EndDefense=1
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
				ForOffense=1
				EndDefense=1
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
				StrOffense=1
				ForOffense=1
				EndDefense=0.75
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
				AdaptRate=2
				DamageMult=2
				Area="Target"
				Distance=10
				TurfErupt=2
				TurfEruptOffset=3
				EndDefense=0.75
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
				StrOffense=1
				DamageMult=1
				AbyssMod=3
				HolyMod=3
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
				StrOffense=2
				Crushing=100
				EnergySteal=15
				DamageMult=4
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
				StrOffense=1
				ForOffense=1
				DamageMult=3
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
				DamageMult=1
				StrOffense=1
				EndDefense=1
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
				DamageMult=3
				StrOffense=1
				EndDefense=1
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
				DamageMult=1.5
				StrOffense=1
				EndDefense=1
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
				DamageMult=5
				StrOffense=1
				EndDefense=1
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
				StrOffense=1
				Distance=7
				DelayTime=7
				Rounds=7
				DamageMult=0.8
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
				StrOffense=1
				Distance=7
				Rounds=7
				DamageMult=0.8
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
				DamageMult=0.6
				Rounds=10
				StrOffense=0.5
				ForOffense=0.5
				EndDefense=1
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
				DamageMult=3
				StrOffense=1
				EndDefense=0.75
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
				DamageMult=2
				Rounds=2
				StrOffense=1
				EndDefense=0.75
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
				IconTime=10
				Cooldown=4

			Flowing_Slash_Follow_Up
				Area="Strike"
				NoLock=1
				NoAttackLock=1
				Distance=10
				Instinct=4
				Size=2
				DamageMult=12
				StrOffense=1
				EndDefense=1
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
				DamageMult=4.5
				Rounds=3
				ComboMaster = 1
				StrOffense=1
				EndDefense=1
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
				IconTime=10
				Cooldown=4
			Shunshin_Massacre
				Area="Target"
				NoLock=1
				NoAttackLock=1
				Distance=10
				Instinct=4
				DamageMult=1.8
				Rounds=5
				DelayTime=30
				GuardBreak=1
				StrOffense=1
				EndDefense=1
				PassThrough=1
				ActiveMessage="rips through their opponent with rapid godspeed slashes!"
				HitSparkIcon='Slash - Zan.dmi'
				HitSparkX=-16
				HitSparkY=-16
				HitSparkSize=2
				HitSparkTurns=1
				HitSparkLife=10
				IconTime=10
				Cooldown=4
			Stop_Effect
				Area="Around Target"
				NoLock=1
				NoAttackLock=1
				Distance=15
				DistanceAround=5
				Stunner=5
				DamageMult=4
				StrOffense=0
				ForOffense=1
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
				DamageMult=3
				StrOffense=1
				ForOffense=1
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
				DamageMult=10
				StrOffense=1
				ForOffense=1
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
				StrOffense=1
				DamageMult=0.5
				Rounds=10
				ChargeTech=1
				ChargeTime=1
				Knockback=1
				Cooldown=4
				Size=1
				Instinct=1
			Dancing_Blade_Effect
				Area="Circle"
				StrOffense=1
				DamageMult=0.5
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
				StrOffense=1
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				Size=1
				DamageMult=0.5
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
				StrOffense=0.5
				ForOffense=0.5
				DamageMult=1
				Distance=2
				Launcher=1
				NoAttackLock=1
				NoLock=1
				Cooldown=4
////Keyblade
			FeverPitch
				Area="Arc"
				NoLock=1
				StrOffense=1
				DamageMult=4
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
				StrOffense=1
				DamageMult=1
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
				ForOffense=1
				DamageMult=0.4
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
				DamageMult=0.2
				Knockback=1
				Rounds=25
				StrOffense=1
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
				StrOffense=1
				ForOffense=1
				NoLock=1
				NoAttackLock=1
				DamageMult=5
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
				StrOffense=1
				ForOffense=1
				NoAttackLock=1
				ComboMaster=1
				DamageMult=10
				Distance=6
				Flash=1
				Rush=15
				Instinct=2
				ControlledRush=1
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
				StrOffense=1
				ForOffense=1
				EndDefense=0.5
				DamageMult=2.5
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
				StrOffense=1
				ForOffense=1
				RoundMovement=1
				DamageMult=0.2
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
				StrOffense=1
				ForOffense=1
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
				AdaptRate = 1
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
				StrOffense=0
				ForOffense=1
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
				Knockback=1
				Slow=1
				Area="Wave"
				ActiveMessage="bursts out with tendrils of symbiotic matter!"
				StrOffense = 0.5
				ForOffense = 0.5
				Cooldown = 60
				DamageMult= 4
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
				StrOffense=1
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
				StrOffense=1
				Knockback=1
				HitSparkIcon='BLANK.dmi'
				Slow=4
				DamageMult=4
				NoOverlay=1
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
				StrOffense=0
				ForOffense=1
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
			Rabid_Retaliation
				Area="Arc"
				StrOffense=1
				DamageMult=1
				Rounds=15
				Knockback=1
				Size=1
				Crippling=2
				ActiveMessage="retaliates with bestial ferocity!"
				HitSparkIcon='WolfFF.dmi'
				HitSparkX=0
				HitSparkY=0
				HitSparkTurns=1
				HitSparkSize=1.2
			Attractive_Force
				Area="Circle"
				Distance=15
				StrOffense=1
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
				StrOffense=1
				Knockback=1
				HitSparkIcon='BLANK.dmi'
				Slow=1
				DamageMult=2
				NoOverlay=1
				ObjIcon=1
				Icon='SekiZou.dmi'
				IconX=-48
				IconY=-48
				Size=1
//Racial
			AntennaBeam
				Area="Strike"
				ForOffense=1
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
				StrOffense=1
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
				UnarmedOnly=1
				Area="Arc"
				StrOffense=1
				DamageMult=3.5
				Rush=5
				ControlledRush=1
				Rounds=3
				ComboMaster=1
				RoundMovement=0
				NoAttackLock=1
				NoLock=1
				Cooldown=90
				Icon='Nest Slash.dmi'
				IconX=-16
				IconY=-16
				Size=2
				Distance=2
				EnergyCost=5
				Launcher=2
				Instinct=1
				ActiveMessage="delivers a series of flowing kicks!"
				adjust(mob/p)
				verb/Lightning_Kicks()
					set category="Skills"
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
					usr.Activate(src)
				verb/Disable_Innovate()
					set category = "Other"
					disableInnovation(usr)
			Flying_Kick
				NewCost = TIER_3_COST
				NewCopyable = 4
				SkillCost=80
				Copyable=3
				UnarmedOnly=1
				Area="Arc"
				Distance=2
				StrOffense=1
				Rush=8
				Jump=1
				ControlledRush=1
				DamageMult=6
				Knockback=1
				Shattering = 15
				GuardBreak=1
				Icon='Nest Slash.dmi'
				IconX=-16
				IconY=-16
				Size=2
				Cooldown=90
				EnergyCost=4
				ActiveMessage="goes flying through the air to deliver a graceful kick!"
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
				StrOffense=1
				DamageMult=1
				Rounds=10
				ChargeTech=1
				ChargeTime=1
				Knockback=1
				Cooldown=120
				Size=1
				EnergyCost=1
				Instinct=1
				ActiveMessage="charges forward with their arm held out!"
				verb/Clothesline()
					set category="Skills"
					usr.Activate(src)
			Spinning_Clothesline
				SkillCost=TIER_4_COST
				Copyable=5
				UnarmedOnly=1
				Area="Circle"
				ComboMaster=1
				StrOffense=1
				DamageMult=0.55
				Rounds=20
				Launcher=2
				Cooldown=120
				Size=2
				Icon='Tornado.dmi'
				IconX=-8
				IconY=-8
				EnergyCost=2.5
				Instinct=1
				ActiveMessage="spins like a top, crushing anyone caught in their range!"
				adjust(mob/p)
					if(p.isInnovative(HUMAN, "Unarmed") && !isInnovationDisable(p))
						Size = 4
						Rounds= 10 + (p.Potential/10)
						DamageMult = 1 + (p.Potential/100)
						PullIn = 6
					else
						Size = 2
						Rounds= 20
						DamageMult = 0.55
						PullIn = 0
				verb/Spinning_Clothesline()
					set category="Skills"
					adjust(usr)
					usr.Activate(src)
				verb/Disable_Innovate()
					set category = "Other"
					disableInnovation(usr)
			Bullrush
				SkillCost=TIER_4_COST
				Copyable=5
				UnarmedOnly=1
				Area="Circle"
				StrOffense=1
				DamageMult=1.25
				ComboMaster = 1
				GrabMaster = 1
				Stunner=3
				Grapple=1
				Rounds=11
				ChargeTech=1
				ChargeTime=1
				Knockback=1
				Cooldown=120
				WindUp=0.25
				WindupMessage="lowers their head..."
				Size=1
				EnergyCost=1
				ActiveMessage="charges forward, plowing through everyone in their path!"
				verb/Bullrush()
					set category="Skills"
					usr.Activate(src)
			Hyper_Crash
				SkillCost=TIER_4_COST
				Copyable=5
				Area="Wide Wave"
				UnarmedOnly = 1
				StrOffense=1
				Distance=10
				Knockback=10
				PassThrough=1
				PreShockwave=1
				PostShockwave=0
				Shockwave=2
				Shockwaves=2
				DamageMult=11
				WindUp=0.1
				WindupMessage="crouches into a starting position..."
				ActiveMessage="blasts forward with a super-sonic dash!"
				Cooldown=120
				adjust(mob/p)
					if(p.isInnovative(HUMAN, "Unarmed") && !isInnovationDisable(p))
						Area="Around Target"
						NoLock=1
						NoAttackLock=1
						StrOffense=1
						DamageMult=1 + p.Potential/200
						Distance=5
						DistanceAround=4
						Rounds=10
						TurfErupt=1.25
						TurfEruptOffset=6
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
					else
						Area="Wide Wave"
						NoLock=0
						NoAttackLock=0
						StrOffense=1
						DamageMult=11
						Distance=10
						DistanceAround=0
						Rounds=0
						TurfErupt=0
						TurfEruptOffset=0
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
				verb/Hyper_Crash()
					set category="Skills"
					adjust(usr)
					usr.Activate(src)
				verb/Disable_Innovate()
					set category = "Other"
					disableInnovation(usr)
			Dropkick_Surprise
				SkillCost=TIER_4_COST
				UnarmedOnly = 1
				Copyable=5
				Area="Target"
				StrOffense=1
				Distance=5
				PassThrough=1
				DamageMult=11
				Knockback=5
				Jump=1
				WindUp=0.25
				WindupMessage="leaps into the air!"
				ActiveMessage="crashes into their opponent with a dropkick!"
				Cooldown=120
				verb/Dropkick_Surprise()
					set category="Skills"
					usr.Activate(src)

//T5 (Sig 1) has damage mult 5, usually

			Cast_Fist
				SignatureTechnique=1
				UnarmedOnly=1
				Area="Cone"
				StrOffense=1
				DamageMult=6
				TurfDirt=1
				Distance=5
				Size=3
				Knockback=10
				ShockIcon='KenShockwave.dmi'
				Shockwave=5
				Shockwaves=1
				PassThrough=1
				Launcher=5
				PostShockwave=1
				PreShockwave=0
				BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Muscle_Expand"
				FollowUp="/obj/Skills/Queue/Warping_Fist"
				FollowUpDelay=2
				Cooldown=150
				WindUp=1
				Earthshaking=20
				Instinct=1
				WindupMessage="rises their fist, ready to cast a spell..."
				ActiveMessage="punches the ground!"
				verb/Cast_Fist()
					set category="Skills"
					usr.Activate(src)

			Wolf_Fang_Fist
				SignatureTechnique=1
				UnarmedOnly=1
				Area="Circle"
				StrOffense=1
				DamageMult=1
				IgnoreAlreadyHit=TRUE
				Rounds=10
				Stunner=0.5
				Launcher=2
				ComboMaster=1
				ChargeTech=1
				GrabMaster = 1
				ChargeTime=1.5
				Grapple=1
				Cooldown=160
				// Size=1
				EnergyCost=5
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
				AdaptRate = 1
				DamageMult=1.3
				ComboMaster=1
				Rounds=10
				ChargeTech=1
				ChargeFlight=1
				ChargeTime=0.75
				Grapple=1
				Stunner=1
				Launcher=1
				GrabMaster=1
				Cooldown=150
				Size=1
				EnergyCost=13
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
				Area="Strike"
				StrOffense=2
				DamageMult=7
				GuardBreak=1

				Destroyer = 5 // make it do more dmg if tht guy is stunned or launched, ig this is dunker for stuns
				Dunker = 3

				Rush=1
				RushDelay=0.1
				ControlledRush=1
				Knockback=0
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
				WindUp=0.5
				WindupMessage="extends their arm towards the opponent, reaching them with the tips of their fingers..."
				ActiveMessage="curls up their fingers into a fist and delivers a crushing blow!!!"
				EnergyCost=5
				Cooldown=150
				verb/One_Inch_Punch()
					set category="Skills"
					usr.Activate(src)

//T6 (Sig 2) has damage mult 7.5, usually

			Lariat
				SignatureTechnique=2
				Area="Circle"
				AdaptRate=1.5
				DamageMult=1.5
				Rounds=10
				ComboMaster=1
				ChargeTech=1
				ChargeTime=0.5
				Grapple=1
				GrabMaster = 1
				Stunner=3
				Cooldown=180
				Size=2
				EnergyCost=10
				// GuardBreak=1
				SpecialAttack=1
				Rush=5
				ControlledRush=1
				Instinct=1
				Icon='Glowing Electricity.dmi'
				ActiveMessage="is covered in lightning as they charge forward!"
				verb/Lariat()
					set category="Skills"
					usr.Activate(src)

			Hyper_Tornado
				SignatureTechnique=2
				Area="Wave"
				StrOffense=1
				ForOffense=1
				DamageMult=8
				ComboMaster=1
				ControlledRush=1
				Rush=7
				Instinct=2
				Knockback=15
				Cooldown=180
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
				AdaptRate=1
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
				AdaptRate=1
				SpecialAttack=1
				ComboMaster=1
				Rounds=3
				DamageMult=1
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
				ForOffense=1
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
				SkillCost=TIER_4_COST
				Copyable=5
				EnergyCost=10
				Area="Wide Wave"
				FlickAttack=1
				Distance=15
				ForOffense=1
				DamageMult=11
				Scorching = 10
				Stunner=3
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
				Cooldown=120
				verb/Breaker_Wave()
					set category="Skills"
					usr.Activate(src)
			Blazing_Storm
				SkillCost=TIER_4_COST
				Copyable=5
				StrOffense=0
				ForOffense=1
				Rounds=10
				DamageMult=1.1
				Area="Around Target"
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
				Cooldown=120
				EnergyCost=10
				Earthshaking=15
				verb/Blazing_Storm()
					set category="Skills"
					usr.Activate(src)
			Ghost_Wave
				SkillCost=TIER_4_COST
				Copyable=5
				EnergyCost=10
				Area="Wave"
				FlickAttack=1
				Distance=3
				ForOffense=1
				Rush=8
				NoLock=1
				NoAttackLock=1
				ControlledRush=1
				Rounds=3
				DamageMult=4
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
				Cooldown=120
				verb/Ghost_Wave()
					set category="Skills"
					usr.Activate(src)
			Power_Pillar
				SkillCost=160
				Copyable=5
				EnergyCost=10
				Area="Circle"
				FlickAttack=1
				Distance=3
				RoundMovement=0
				Rounds=5
				ForOffense=1
				DamageMult=3.2
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
				Cooldown=120
				verb/Power_Pillar()
					set category="Skills"
					usr.Activate(src)





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
				StrOffense=1
				CanBeDodged = 0
				CanBeBlocked = 0
				DamageMult=8
				DelayTime=0.25
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
				Rush=5
				ControlledRush=1
				HitSparkIcon='Slash - Future.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkCount=7
				HitSparkDispersion=4
				Launcher=4
				DelayedLauncher=1
				Cooldown=150
				EnergyCost=5
				Instinct=1
				ActiveMessage="delivers swift justice with a flurry of slashes!"
				verb/Shining_Sword_Slash()
					set category="Skills"
					usr.Activate(src)
			Massacre
				SignatureTechnique=1
				NeedsSword=1
				Area="Circle"
				StrOffense=1
				Distance=5
				DamageMult=6
				Knockback=15
				WindUp=0.5
				Slow=1
				Stunner=2
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
				Cooldown=150
				EnergyCost=5
				Instinct=1
				verb/Massacre()
					set category="Skills"
					usr.Activate(src)
			Slam_Wave
				SignatureTechnique=1
				NeedsSword=1
				Area="Wider Wave"
				StrOffense=1
				DamageMult=10
				TurfDirt=1
				Distance=12
				Jump=1
				Knockback=10
				FlickAttack=2
				GuardBreak=1
				ShockIcon='KenShockwave.dmi'
				Shockwave=1
				Shockwaves=1
				PostShockwave=1
				HitSparkIcon='BLANK.dmi'
				Cooldown=150
				EnergyCost=5
				Earthshaking=1
				Speed=1.5
				WindUp=0
				Instinct=1
				ActiveMessage="leaps in the air before falling back down, weapon-first!"
				verb/Slam_Wave()
					set category="Skills"
					usr.Activate(src)

			Zantetsuken
				SignatureTechnique=2
				NeedsSword=1
				Distance=15
				Gravity=5
				WindUp=1
				WindupMessage="prepares to deliver a peerless slash..."
				DamageMult=10
				StrOffense=1
				ActiveMessage="slashes through their enemy in the blink of an eye, aiming to mortally wound them!"
				Area="Target"
				GuardBreak=1
				PassThrough=1
				MortalBlow=1
				HitSparkIcon='Slash - Zan.dmi'
				HitSparkX=-16
				HitSparkY=-16
				HitSparkTurns=1
				HitSparkSize=3
				Cooldown=-1
				EnergyCost=15
				Instinct=1
				verb/Zantetsuken()
					set category="Skills"
					usr.Activate(src)
			Shadow_Cut
				SignatureTechnique=2
				NeedsSword=1
				Area="Wider Wave"
				StrOffense=1
				Distance=7
				DelayTime=2
				Rounds=7
				IgnoreAlreadyHit = 1
				DamageMult=2
				Knockback=10
				SpeedStrike = 1
				PassThrough=1
				GuardBreak=1
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
				Cooldown=180
				EnergyCost=5
				Instinct=1
				verb/Shadow_Cut()
					set category="Skills"
					usr.Activate(src)
			Thousand_Man_Slayer//Give this to (scrubbed)
				SignatureTechnique=2
				PreRequisite=list("/obj/Skills/AutoHit/Massacre")
				NeedsSword=1
				Area="Circle"
				StrOffense=1
				Distance=7
				PassTo=1
				DamageMult=16.5
				WindUp=1
				GuardBreak=1
				Knockback=25
				WindupMessage="lays a hand on their sheathed blade, concentrating for a moment..."
				ActiveMessage="blasts through surrounding foes with what appears to be a single strike!!"
				Cooldown=180
				EnergyCost=15
				verb/Thousand_Man_Slayer()
					set category="Skills"
					usr.Activate(src)
			Force_Stasis
				Area="Target"
				ForOffense=1
				Stunner=2.5
				Distance=5
				DamageMult=2.5
				WindUp=1
				WindupMessage="lifts their hand up, concentrating on the force..."
				ActiveMessage="succesfully casts a statsis upon their target!!"
				Cooldown=120
				ForceCost=10
				verb/Force_Stasis()
					set category="Skills"
					usr.Activate(src)
			Mugetsu
				SpecialAttack=1
				SBuffNeeded="Final Getsuga Tenshou"
				Area="Arc"
				Distance=30
				DamageMult=50
				StrOffense=1
				ForOffense=1
				Cooldown=-1
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
				AdaptRate = 1
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
				AdaptRate = 1
				GuardBreak=1
				DamageMult=8
				Knockback=15
				Cooldown=150
				Shockwaves=3
				Shockwave=4
				BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Staggered"
				SpecialAttack=1
				Stunner=3
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				ActiveMessage="unleashes a wave of ki!"
				EnergyCost=5
				verb/Kiai()
					set category="Skills"
					usr.Activate(src)

			Taiyoken
				SignatureTechnique=1
				AllOutAttack=1
				Area="Circle"
				Distance=10
				AdaptRate = 1
				DamageMult = 4
				Flash=30
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
				Cooldown=150
				EnergyCost=5
				verb/Taiyoken()
					set category="Skills"
					usr.Activate(src)
			Chidori
				Area="Strike"
				SignatureTechnique=1
				AdaptRate=1
				Rush=20
				SpecialAttack=1
				CanBeDodged=0
				CanBeBlocked=1
				DamageMult=11
				Stunner=3
				MortalBlow=1
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
				Cooldown=150
				EnergyCost=8
				Instinct=1
				proc/reset2default()
					Area="Strike"
					AdaptRate=1
					Rush=20
					SpecialAttack=1
					CanBeDodged=0
					CanBeBlocked=1
					DamageMult=11
					Stunner=3
					MortalBlow=1
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
					EnergyCost=8
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
					if(p.isInnovative(HUMAN, "Any") && !isInnovationDisable(p))
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
						DamageMult = 0.1
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
					usr.Activate(src)
			Super_Explosive_Wave
				SignatureTechnique=1
				StrOffense=0
				ForOffense=1
				DamageMult=12
				Area="Circle"
				Distance=8
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
				WindupMessage="draws in a large amount of ki..."
				ActiveMessage="unleashes an explosive wave of power!"
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				Cooldown=150

				Earthshaking=15
				PreQuake=1
				verb/Super_Explosive_Wave()
					set category="Skills"
					usr.Activate(src)
			Kikoho
				SignatureTechnique=1
				AllOutAttack=1
				StrOffense=0
				ForOffense=1
				DamageMult=13
				WoundCost=3
				ComboMaster=1
				Area="Around Target"
				Distance=15
				DistanceAround=4
				Divide=1
				Launcher=1
				GuardBreak=1
				Stunner=0.5
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
				Cooldown=150
				Earthshaking=15
				GuardBreak=1
				Crippling=3
				Instinct=1
				verb/Kikoho()
					set category="Skills"
					usr.Activate(src)

			Shin_Kikoho
				PreRequisite=list("/obj/Skills/AutoHit/Kikoho")
				SignatureTechnique=2
				AllOutAttack=1
				StrOffense=0
				ForOffense=1
				Launcher=1
				WoundCost=20
				DamageMult=12
				Rounds=4
				DelayTime = 5
				ComboMaster=1
				Cooldown=180
				Area="Around Target"
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
				Crippling=3
				Instinct=1
				verb/Shin_Kikoho()
					set category="Skills"
					usr.Activate(src)

////Racial
			Oceanic_Wrath
				ElementalClass="Water"
				ForOffense=1.5
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
				verb/Oceanic_Wrath()
					set category="Skills"
					if(!altered)
						DamageMult = 6 + (1.5 * usr.AscensionsAcquired)
						Cooldown = 60 - (5 * usr.AscensionsAcquired)
						Distance = 10 + (5 * usr.AscensionsAcquired)
						Stasis = 5 + (2.5 * usr.AscensionsAcquired)
						ForOffense = 1 + (0.25 * usr.AscensionsAcquired)
					usr.Activate(src)


			Fire_Breath
				ElementalClass="Fire"
				StrOffense=1
				ForOffense=1
				SpecialAttack=1
				GuardBreak=0
				DamageMult=15
				Scorching=30
				TurfErupt=1
				WindUp=0.5
				WindupMessage="breathes deeply..."
				ActiveMessage="lets loose an enormous breath infused with fire!"
				Cooldown=90
				Distance=30
				Slow=1
				Area="Arc"
				verb/Fire_Breath()
					set category="Skills"
					if(!altered)
						DamageMult = 3 + (1.5 * usr.AscensionsAcquired)
						Cooldown = 60 - (5 * usr.AscensionsAcquired)
						Distance = 6 + (3 * usr.AscensionsAcquired)
						ForOffense = 0.3 + (0.1 * usr.AscensionsAcquired)
						StrOffense = 0.3 + (0.1 * usr.AscensionsAcquired)
					usr.Activate(src)
			Poison_Gas
				ElementalClass="Poison"
				StrOffense=0.5
				ForOffense=0.5
				EndDefense=0.5
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
				ForOffense=1
				StrOffense=0
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
				ForOffense=1
				StrOffense=0
				Area="Around Target"
				DistanceAround
				CanBeDodged=1
				Distance=20
				DistanceAround=15
				DamageMult=0.5
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
					SkillCost=TIER_2_COST
					Copyable=2
					Area="Wave"
					Distance=6
					Freezing=2
					Slow=1
					DamageMult=3
					SpecialAttack=1
					StrOffense=0
					ForOffense=1
					FlickAttack=1
					CanBeDodged=1
					CanBeBlocked=0
					HitSparkIcon='SnowBurst2.dmi'
					HitSparkTurns=0
					HitSparkSize=1
					HitSparkDispersion=8
					TurfStrike=1
					ManaCost=3
					Cooldown=60
					ActiveMessage="invokes: <font size=+1>BLIZZARD!</font size>"
					adjust(mob/p)
						if(!altered)
							if(p.isInnovative(ELF, "Any") && !isInnovationDisable(p))
								Rounds=round(p.getTotalMagicLevel()/5)
								Knockback=1
								Distance= 6 + round(p.getTotalMagicLevel()/5)
								Slow = 3 + p.Potential/10
								NoLock=1
								NoAttackLock=1
								Freezing = 2 + p.Potential/10
								ManaCost = round(p.getTotalMagicLevel()/3) + 3
								Slow=0.25
							else
								Rounds=initial(Rounds)
								Knockback=0
								Distance= 6
								Slow = 1
								Freezing = 2
								ManaCost = 3
					verb/Disable_Innovate()
						set category = "Other"
						disableInnovation(usr)
					verb/Blizzard()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)
				Blizzara
					ElementalClass="Water"
					SkillCost=TIER_2_COST
					Copyable=3
					PreRequisite=list("/obj/Skills/AutoHit/Magic/Blizzard")
					Area="Wide Wave"
					Distance=6
					Freezing=4
					Slow=1
					DamageMult=6
					SpecialAttack=1
					StrOffense=0
					ForOffense=1
					CanBeDodged=1
					CanBeBlocked=0
					HitSparkIcon='SnowBurst2.dmi'
					HitSparkSize=1
					HitSparkDispersion=16
					TurfStrike=3
					ManaCost=6
					Cooldown=60
					ActiveMessage="invokes: <font size=+1>BLIZZARA!</font size>"
					verb/Disable_Innovate()
						set category = "Other"
						disableInnovation(usr)
					adjust(mob/p)
						// make it cast a projectile that is like hell zone grenade
						if(!altered)
							if(!isInnovationDisable(p) && p.isInnovative(ELF, "Any"))
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
					SkillCost=TIER_2_COST
					Copyable=4
					PreRequisite=list("/obj/Skills/AutoHit/Magic/Blizzara")
					Area="Circle"
					Distance=6
					Freezing=6
					Slow=1
					DamageMult=8
					SpecialAttack=1
					StrOffense=0
					ForOffense=1
					CanBeDodged=1
					CanBeBlocked=0
					HitSparkIcon='SnowBurst2.dmi'
					HitSparkSize=1
					HitSparkDispersion=16
					TurfStrike=3
					ManaCost=9
					Cooldown=60
					ActiveMessage="invokes: <font size=+1>BLIZZAGA!</font size>"
					verb/Disable_Innovate()
						set category = "Other"
						disableInnovation(usr)
					adjust(mob/p)
						if(!altered)
							if(p.isInnovative(ELF, "Any") && !isInnovationDisable(p))
								Rounds = 3 + p.Potential/25
								Distance = 4 + p.getTotalMagicLevel()/2 + p.Potential/25
								Freezing = 6 + p.getTotalMagicLevel()
								AdaptRate = 1
								DamageMult = 5 + p.getTotalMagicLevel()/5 + p.Potential/25
								ForOffense=0
								NoLock=1
								NoAttackLock=1
								DamageMult/=Rounds
								ManaCost = 10
							else
								Rounds=initial(Rounds)
								Knockback=0
								Distance= 6
								DamageMult=8
								ForOffense=1
								AdaptRate=0
								Freezing = 6
								ManaCost = 9
					verb/Blizzaga()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)

				Thunder
					ElementalClass="Wind"
					FlickAttack=1
					SkillCost=TIER_2_COST
					Copyable=2
					Distance=6
					Area="Target"
					ForOffense=1
					DamageMult=4
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
					Cooldown=60
					WindupMessage="invokes: <font size=+1>THUNDER!</font size>"
					verb/Disable_Innovate()
						set category = "Other"
						disableInnovation(usr)
					adjust(mob/p)
						if(!altered)
							if(p.isInnovative(ELF, "Any") && !isInnovationDisable(p))
								var/asc = p.AscensionsAcquired
								var/magicLevel = p.getTotalMagicLevel()
								Rush=5
								ControlledRush=1
								Distance = 8
								Bolt=2
								Size=0.5
								WindUp=0.25
								Rounds= round(magicLevel/5) + asc
								DamageMult = clamp(magicLevel/3 + asc * 2, 4, 12)
								ManaCost *= DamageMult/4
								DamageMult /= (Rounds)
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
					FlickAttack=1
					SkillCost=TIER_2_COST
					Copyable=3
					PreRequisite=list("/obj/Skills/AutoHit/Magic/Thunder")
					Area="Circle"
					Distance=8
					Paralyzing=8
					Bolt=2
					WindUp=1
					DamageMult=6
					SpecialAttack=1
					ForOffense=1
					CanBeDodged=1
					CanBeBlocked=0
					ManaCost=5
					Cooldown=60
					WindupMessage="invokes: <font size=+1>THUNDARA!</font size>"
					verb/Disable_Innovate()
						set category = "Other"
						disableInnovation(usr)
					adjust(mob/p)
						// make it cast a projectile that is like hell zone grenade
						ManaCost = 5
						if(!altered)
							if(p.isInnovative(ELF, "Any") && !isInnovationDisable(p))
								if(!Using && usr.ManaAmount >= 10)
									if(!locate(/obj/Skills/Projectile/Thundara, usr))
										usr.AddSkill(new/obj/Skills/Projectile/Thundara)
									var/obj/Skills/Projectile/Thundara/th = usr.FindSkill(/obj/Skills/Projectile/Thundara)
									th.adjust(usr)
									usr.UseProjectile(th)
									DamageMult=4
									usr.ManaAmount-=5
								else
									return

					verb/Thundara()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)
				Thundaga
					ElementalClass="Wind"
					FlickAttack=1
					SkillCost=TIER_2_COST
					Copyable=4
					PreRequisite=list("/obj/Skills/AutoHit/Magic/Thundara")
					Area="Around Target"
					Distance=10
					DistanceAround=7
					Paralyzing=4
					Bolt=2
					BoltOffset=1
					WindUp=1
					DamageMult=2
					Rounds=5
					SpecialAttack=1
					ForOffense=1
					CanBeDodged=0
					CanBeBlocked=1
					ManaCost=10
					Cooldown=60
					WindupMessage="invokes: <font size=+1>THUNDAGA!</font size>"
					verb/Disable_Innovate()
						set category = "Other"
						disableInnovation(usr)
					adjust(mob/p)
						if(!altered)
							if(p.isInnovative(ELF, "Any") && !isInnovationDisable(p))
								Rounds = 200
								DamageMult = 0.05
								Icon='VR Cloud.png'
								IconX=-13
								Size = 8
								Cooldown = 90
								NoLock=1
								NoAttackLock=1
								WindUp=2
								Thunderstorm=7
								ManaCost = 7.5
							else
								DamageMult=2
								Rounds=5
								Icon=null
								IconX=0
								Size = initial(Size)
								Cooldown = 60
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
					ElementalClass="Earth"
					FlickAttack=1
					SkillCost=TIER_4_COST
					Copyable=4
					StrOffense=0
					ForOffense=1
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
					verb/Magnet()
						set category="Skills"
						usr.Activate(src)
				Gravity
					ElementalClass="Earth"
					SkillCost=TIER_4_COST
					Copyable=5
					PreRequisite=list("/obj/Skills/AutoHit/Magic/Magnet")
					Area="Around Target"
					Distance=15
					DistanceAround=4
					WindUp=0.5
					GuardBreak=1
					SpecialAttack=1
					NoLock=1
					NoAttackLock=1
					StrOffense=0
					ForOffense=1
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
					verb/Gravity()
						set category="Skills"
						usr.Activate(src)
				Stop
					ElementalClass="Earth"
					SkillCost=TIER_4_COST
					Copyable=6
					PreRequisite=list("/obj/Skills/AutoHit/Magic/Gravity")
					Area="Around Target"
					Distance=15
					DistanceAround=5
					WindUp=1
					Stunner=5
					DamageMult=4
					StrOffense=0
					ForOffense=1
					GuardBreak=1
					SpecialAttack=1
					NoLock=1
					NoAttackLock=1
					Launcher=1
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
					Cooldown=120
					ManaCost=20
					WindupMessage="invokes: <font size=+1>STOP!</font size>"
					verb/Stop()
						set category="Skills"
						usr.Activate(src)

				Flare
					ElementalClass="Fire"
					SkillCost=TIER_4_COST
					Copyable=6
					PreRequisite=list("/obj/Skills/Projectile/Magic/Meteor")
					Area="Around Target"
					Distance=15
					DistanceAround=7
					DamageMult=8
					ManaCost=20
					Cooldown=120
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
					ForOffense=1
					EndDefense=1
					SpecialAttack=1
					Instinct=1
					verb/Flare()
						set category="Skills"
						usr.Activate(src)


				Magnetga
					ElementalClass="Earth"
					SagaSignature=1
					SignatureTechnique=1
					SignatureName="Advanced Space Magic"
					PreRequisite=list("/obj/Skills/AutoHit/Magic/Stop")
					FlickAttack=1
					StrOffense=0
					ForOffense=1
					DamageMult=0.7
					Area="Around Target"
					SpecialAttack=1
					NoLock=1
					NoAttackLock=1
					Distance=30
					DistanceAround=4
					Rounds=20
					DelayTime=2
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
					verb/Magnetga()
						set category="Skills"
						usr.Activate(src)
				Graviga
					ElementalClass="Earth"
					SagaSignature=1
					SignatureTechnique=1
					SignatureName="Advanced Space Magic"
					PreRequisite=list("/obj/Skills/AutoHit/Magic/Stop")
					Area="Circle"
					Distance=8
					WindUp=1
					NoLock=1
					NoAttackLock=1
					GuardBreak=1
					SpecialAttack=1
					StrOffense=0
					ForOffense=1
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
					verb/Graviga()
						set category="Skills"
						usr.Activate(src)
				Stopga
					ElementalClass="Earth"
					SagaSignature=1
					SignatureTechnique=1
					SignatureName="Advanced Space Magic"
					PreRequisite=list("/obj/Skills/AutoHit/Magic/Stop")
					Area="Circle"
					Distance=10
					Stunner=5
					DamageMult=0
					StrOffense=0
					ForOffense=1
					GuardBreak=1
					NoLock=1
					NoAttackLock=1
					SpecialAttack=1
					HitSparkIcon='Magic Time circle.dmi'
					HitSparkX=0
					HitSparkY=0
					HitSparkDispersion=0
					Cooldown=180
					ManaCost=30
					WindupMessage="invokes: <font size=+1>STOPGA!</font size>"
					verb/Stopga()
						set category="Skills"
						usr.Activate(src)

				Holy
					ElementalClass="Water"
					SagaSignature=1
					SignatureTechnique=2
					SignatureName="Holy Magic"
					Area="Target"
					Distance=7
					HolyMod=20
					Purity=1
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
					ForOffense=1
					SpecialAttack=1
					WindupMessage="invokes: <font size=+1>HOLY!</font size>"
					verb/Holy()
						set category="Skills"
						usr.Activate(src)

				Thousand_Thunderbolts
				Snowstorm_of_Darkness
				Light_Eater
				Cage_of_Time

				Ultima
					SignatureTechnique=4
					Destructive=1


/// MAGIC AUTO HIT SIGS T1
				Burning_Circle

					Area="Around Target"
					SignatureTechnique=1
					ForOffense=1
					Distance = 10
					HitSparkIcon='Hit Effect Pearl.dmi'
					HitSparkX=-32
					HitSparkY=-32
					IconX=-120
					IconY=-80
					HitSparkTurns=1
					HitSparkSize=5
					HitSparkCount=10
					HitSparkDispersion=1
					Cooldown=60
					DistanceAround=3
					Rounds=20
					TurfErupt=1.25
					TurfEruptOffset=6
					DelayTime=1
					Stunner=3
					Icon='Demon Gate.dmi'
					Size=1
					Falling=1//animates towards pixel_z=0 while it is displayed
					ActiveMessage="casts upon their burning passion to emplace a circle of hell around their foe!"
					HitSparkIcon='BLANK.dmi'
					HitSparkX=0
					HitSparkY=0
					Cooldown=120
					verb/Burning_Circle()
						set category="Skills"
						usr.Activate(src)

////SWORD
//T1 has damage mult 1.5 - 2.5

			Tipper
				SkillCost=40
				Copyable=1
				NeedsSword=1
				FlickAttack=1
				Area="Strike"
				Distance=2
				StrOffense=1
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
				StrOffense=1
				Distance=1
				Rush=10
				ControlledRush=1
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
				NeedsSword=1
				Area="Target"
				GuardBreak=1
				StrOffense=1
				DamageMult=12
				Distance=10
				PassThrough=1
				PreShockwave=1
				PostShockwave=1
				Shockwave=2
				Shockwaves=2
				ActiveMessage="flickers behind their opponent for an instantaneous slash!"
				Cooldown=120
				EnergyCost=10
				verb/Disable_Innovate()
					set category = "Other"
					disableInnovation(usr)
				adjust(mob/p)
					if(p.isInnovative(HUMAN, "Sword") && !isInnovationDisable(p))
						var/pot = p.Potential
						Area="Wave"
						ComboMaster=1
						GuardBreak=1
						StrOffense=1
						PassThrough=1
						PreShockwave=1
						PostShockwave=0
						Shockwave=2
						Shockwaves=2
						DamageMult= 5 + (pot/100)
						Rounds = 2
						Stunner=2
						Distance= 4 + (round(pot/10))
						Rounds = 2
						HitSparkIcon='Slash.dmi'
						HitSparkX=-32
						HitSparkY=-32
						HitSparkTurns=1
						HitSparkSize=1
						HitSparkDispersion=1
						TurfStrike=1
						TurfShift='Dark.dmi'
						TurfShiftDuration=3
					else
						Area="Target"
						ComboMaster=0
						GuardBreak=1
						StrOffense=1
						PassThrough=1
						PreShockwave=1
						PostShockwave=1
						Shockwave=2
						Shockwaves=2
						DamageMult=12
						Rounds = 0
						Stunner=0
						Distance= 10
						Rounds = 0
						HitSparkIcon=0
						HitSparkX=0
						HitSparkY=0
						HitSparkTurns=0
						HitSparkSize=0
						HitSparkDispersion=0
						TurfStrike=0
						TurfShift=0
						TurfShiftDuration=0
				verb/Jet_Slicer()
					set category="Skills"
					adjust(usr)
					usr.Activate(src)
			Crowd_Cutter
				SkillCost=TIER_4_COST
				Copyable=5
				NeedsSword=1
				Area="Wide Wave"
				StrOffense=1
				Distance=10
				PassThrough=1
				PreShockwave=1
				PostShockwave=0
				Shockwave=2
				Shockwaves=2
				DamageMult=12
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
				Cooldown=120
				Instinct=1
				verb/Crowd_Cutter()
					set category="Skills"
					usr.Activate(src)
			Holy_Justice
				SkillCost=TIER_4_COST
				Copyable=5
				NeedsSword=1
				Area="Around Target"
				AdaptRate=1.5
				DamageMult=0.5
				HolyMod=2.5
				Distance=5
				DistanceAround=3
				Rounds=20
				TurfErupt=1.25
				TurfEruptOffset=6
				DelayTime=1
				Stunner=3
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
				Cooldown=120
				Instinct=1
				verb/Holy_Justice()
					set category="Skills"
					usr.Activate(src)
			Doom_of_Damocles
				SkillCost=TIER_4_COST
				Copyable=5
				NeedsSword=1
				Area="Around Target"
				AdaptRate=1.5
				DamageMult=0.5
				AbyssMod=2.5
				Distance=5
				DistanceAround=3
				Rounds=20
				TurfErupt=1.25
				TurfEruptOffset=6
				DelayTime=1
				Stunner=3
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
				Cooldown=120
				Instinct=1
				verb/Doom_of_Damocles()
					set category="Skills"
					usr.Activate(src)



//SHIT AINT USED
			SpinRave
				SkillCost=80
				Copyable=3
				NeedsSword=1
				Area="Circle"
				StrOffense=1
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
				StrOffense=1
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
				StrOffense=1
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
				StrOffense=1
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
				StrOffense=1
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
				StrOffense=1
				HolyMod=5
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
				StrOffense=1
				AbyssMod=5
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
				StrOffense=1
				DamageMult=11
				Launcher=1
				Distance=4
				Rush=10
				RushDelay=0.5
				ControlledRush=1
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
				StrOffense=1
				DamageMult=11
				Launcher=1
				Distance=4
				Rush=10
				RushDelay=0.5
				ControlledRush=1
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
				ForOffense=1
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
				StrOffense=1
				ForOffense=1
				WindUp=0.5

				Rush = 10
				ControlledRush = 1
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
				StrOffense=1
				ForOffense=0
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
				StrOffense=0
				ForOffense=1
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
				StrOffense=0
				ForOffense=1
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
				StrOffense=0
				ForOffense=1
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
				StrOffense=1
				ForOffense=1
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
				ControlledRush=1
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
				HolyMod=20
				Distance=6
				Knockback=10
				DelayTime=5
				StrOffense=0
				ForOffense=1
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
					if(usr.SagaLevel<5 && usr.Health>15 && !usr.InjuryAnnounce)
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
				StrOffense=0
				ForOffense=1
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
				StrOffense=0
				ForOffense=1
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
				StrOffense=0
				ForOffense=1
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
				StrOffense=1
				ForOffense=1
				SpecialAttack=1
				Slow=0
				StopAtTarget=0
				WindUp=1
				WindupIcon=1
				WindupMessage="focuses their Cosmo as they slowly raise their arm..."
				ActiveMessage="unleashes the power of the Legendary Exalibur, parting everything before them!"
				verb/Sacred_Sword_Excalibur()
					set category="Skills"
					if(usr.SagaLevel<5 && usr.Health>15 && !usr.InjuryAnnounce)
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
				StrOffense=1
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
				ForOffense=1
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
				DamageMult=2
				Rounds=10
				ChargeTech=1
				StrOffense=1
				ForOffense=1
				Rush=10
				SpecialAttack=1
				Hurricane="/obj/Skills/Projectile/King_of_Braves/Brave_Tornado"
				GuardBreak=1
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
				verb/Hell_And_Heaven()
					set category="Skills"
					if(usr.SagaLevel>5)
						src.DamageMult=3
						src.ControlledRush=1
						WindupMessage="combines the forces of Destruction and Creation with absolute control!"
					usr.Activate(src)
			Goldion_Hammer
				StrOffense=1
				ForOffense=1
				DamageMult=21
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
				Earthshaking=15
				verb/Goldion_Hammer()
					set category="Skills"
					usr.Activate(src)


///Sharingan
			Sharingan_Genjutsu
				Area="Arc"
				AdaptRate = 1
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
				ForOffense=1
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
				StrOffense=1
				ForOffense=1
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
				StrOffense=0
				ForOffense=1
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

///Hiten
			Sonic_Sheath
				name="Ryumeisen"
				Area="Circle"
				StrOffense=1
				StyleNeeded="Hiten Mitsurugi"
				DamageMult=10
				Distance=7
				GuardBreak = 1
				PassThrough=1
				Stunner=5
				PreShockwave=1
				Shockwave=5
				Shockwaves=5
				PostShockwave=0
				Cooldown=180
				NoLock=1
				NoAttackLock=1
				HitSparkIcon='BLANK.dmi'
				ActiveMessage="sheathes their sword with stunning authority!"
				verb/Ryumeisen()
					set category="Skills"
					usr.Activate(src)
			NestedSlash
				name="Ryusousen"
				StyleNeeded="Hiten Mitsurugi"
				Area="Arc"
				StrOffense=1
				DamageMult = 3
				Launcher = 2
				ComboMaster = 1
				EnergyCost=2
				Rush=3
				ControlledRush=1
				Cooldown=60
				Icon='Nest Slash.dmi'
				IconTime=0.7
				IconX=-16
				IconY=-16
				Size=0.8
				HitSparkIcon='Slash.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=0.8
				HitSparkTurns=1
				HitSparkCount=10
				NoLock=1
				NoAttackLock=1
				ActiveMessage="throws countless sword strikes in an endless flurry!"
				verb/Ryusousen()
					set category="Skills"
					usr.Activate(src)
			CoiledSlash
				name="Ryukansen"
				NeedsSword=1
				StyleNeeded="Hiten Mitsurugi"
				Area="Wave"
				StrOffense=1
				DamageMult=5
				ChargeTech=1
				SpeedStrike = 2
				Crippling = 50
				PassThrough = 1
				ChargeTime=0
				DelayTime=0
				Cooldown=60
				Distance = 3
				Size=1
				Rounds=6
				Icon='Air Slash.dmi'
				IconX=-8
				IconY=-8
				HitSparkIcon='Slash.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkSize=0.8
				HitSparkTurns=1
				TurfStrike=1
				EnergyCost=2
				NoLock=1
				NoAttackLock=1
				ActiveMessage="bursts forward, performing a whirling slash!"
				verb/Ryukansen()
					set category="Skills"
					usr.Activate(src)

///Ansatsuken
			Tatsumaki
				UnarmedOnly=1
				Area="Circle"
				StrOffense=1
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				Cooldown=40
				Size=1
				Rush=3
				ControlledRush=1
				IgnoreAlreadyHit=1
				// CanBeBlocked=0
				// CanBeDodged=0
				ComboMaster=1
				StyleNeeded="Ansatsuken"
				proc/alter(mob/player)
					ManaCost = 0
					var/damage = clamp(0.6 + 0.3 * (usr.SagaLevel/2), 0.3, 3)
					var/path = player.AnsatsukenPath == "Tatsumaki" ? 1 : 0
					var/rounds = 3
					var/cooldown = 40
					var/launch = 0
					if(path)
						cooldown = 30
						damage = clamp(0.6 + 0.5 * (usr.SagaLevel/2), 0.3, 5)
						rounds = 3
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
				StrOffense=1
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				Cooldown=150
				Size=2
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
						DamageMult = 1 + (0.2 *p.SagaLevel)
						Cooldown = 150 - (15 * p.SagaLevel)
					else
						Launcher = 0
						Rounds = 6
						DamageMult = 0.7 + (0.15 *p.SagaLevel)
						Cooldown = 150 - (15 * p.SagaLevel)


				verb/EX_Tatsumaki()
					set category="Skills"
					adjust(usr)
					usr.Activate(src)
			ShinkuTatsumaki
				UnarmedOnly=1
				Area="Circle"
				StrOffense=1
				DamageMult=0.8
				Crippling=1
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				Rounds=20
				Cooldown=200
				Size=3
				Distance=3
				ManaCost=75
				Rush=5
				ControlledRush=1
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
				StrOffense=1
				Crippling=1
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				Size=2
				Cooldown=10800
				Size=1
				Rush=3
				ControlledRush=1
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
				StrOffense=1
				Distance = 10
				Rush=5
				RushDelay=2
				ControlledRush=1
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
					StrOffense = 1 + (sagaLevel * 0.05)

				verb/Raging_Demon()
					set category="Skills"
					set name="Raging Demon"
					update(usr)
					usr.Activate(src)
			Shun_Goku_Satsu
				Area="Target"
				SpecialAttack=1
				StrOffense=1
				DamageMult=7.5
				HolyMod=10
				Distance=5
				Rush=5
				RushDelay=2
				ControlledRush=1
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
				StrOffense=1
				DamageMult=0.8
				Shearing = 5
				RoundMovement=0
				ComboMaster=1
				Rounds=10
				Cooldown=60
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
				EnergyCost=1
				Instinct=1
				ActiveMessage="flourishes their blade to cut loose a flood of red fibers!"
				verb/Life_Fiber_Weave()
					set name="Life Fiber Weave"
					set category="Skills"
					usr.Activate(src)
///Weapon Soul
			Great_Divide
				NeedsSword=1
				ABuffNeeded="Soul Resonance"
				EnergyCost=25
				Area="Arc"
				Distance=10
				DamageMult=15
				StrOffense=1
				EndDefense=1
				ForOffense=0
				Cooldown=-1
				HitSparkIcon='Hit Effect Divine.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=7
				TurfStrike=1
				Divide=1
				Slow=1
				WindUp=1
				GuardBreak=1//Can't be dodged or blocked
				WindupMessage="draws their blade back for a colossal swing..."
				ActiveMessage="releases a gigaton slash that parts the earth like butter!"
				verb/Great_Divide()
					set category="Skills"
					usr.Activate(src)
			DurendalPressure
				NoAttackLock=1
				NeedsSword=1
				Area="Wave"
				Distance=4
				StrOffense=1
				Knockback=1
				HitSparkIcon='Hit Effect Divine.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=5
				TurfStrike=1
				Slow=1
				DamageMult=2//First step is 1 damage
				StepsDamage=1//fourth step is 5 damage
				ActiveMessage="whiffs their swing, causing a powerful wave of pressure!"
				Cooldown = 10

			Crystal_Tomb
				NeedsSword=1
				ABuffNeeded="Soul Resonance"
				Distance=10
				WindUp=1
				WindupMessage="channels an oath of just order into Soul Calibur..."
				Area="Around Target"
				DistanceAround=7
				GuardBreak=1
				TurfStrike=1
				TurfShift='IceGround.dmi'
				TurfShiftDuration=500
				DamageMult=10
				HolyMod=10
				Purity=1
				StrOffense=1
				ActiveMessage="encases their target in a tomb of soul-infused crystal!  They are forced into perfect stasis!"
				Stasis=50
				HitSparkIcon='Hit Effect Pearl.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=5
				HitSparkCount=9
				HitSparkDispersion=1
				Cooldown=-1
				verb/Crystal_Tomb()
					set category="Skills"
					usr.Activate(src)

			War_God_Descent
				NeedsSword=1
				ABuffNeeded="Soul Resonance"
				Distance=15
				Gravity=5
				WindUp=3
				WindupMessage="prepares to cut through the very space around them in defiance of everything..."
				DamageMult = 4
				StrOffense=1
				Stunner = 3
				ActiveMessage="slashes through the very concept of space, breaking reality to force their desires onto the world with the might of War!"
				Area="Target"
				GuardBreak=1
				PassThrough=1
				MortalBlow=2
				Shattering = 70
				Shocking = 70
				Crippling = 40
				HitSparkIcon='Slash - Zan.dmi'
				HitSparkX=-16
				HitSparkY=-16
				HitSparkTurns=1
				HitSparkSize=3
				Cooldown= 60
				EnergyCost=15
				Instinct=1
				verb/WarGodDescent()
					set name = "War God's Descent"
					set category="Skills"
					usr.Activate(src)
			Deathbringer
				NeedsSword=1
				ABuffNeeded="Soul Resonance"
				Distance=50
				WindUp=2
				WindupMessage="evokes the power of death..."
				DamageMult=15
				StrOffense=1
				ActiveMessage="slashes through their enemy in the blink of an eye, mortally wounding them!"
				Area="Target"
				GuardBreak=1
				StopAtTarget=1
				MortalBlow=2
				PostShockwave=0
				PreShockwave=1
				Shockwave=5
				Shockwaves=3
				ShockIcon='DarkKiai.dmi'
				HitSparkIcon='Slash - Hellfire.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=2
				Cooldown=180
				verb/Deathbringer()
					set category="Skills"
					usr.Activate(src)
			/*True_Excalibur
				NeedsSword=1
				ABuffNeeded="Soul Resonance"
				EnergyCost=25
				Area="Arc"
				Distance=20
				DelayTime=2
				ComboMaster=1
				CursedWounds=1
				HolyMod=4
				Earthshaking=8
				Divide=1
				PreShockwave=1
				Shockwaves=1
				Shockwave=1
				ShockIcon='fevKiaiDS.dmi'
				Speed=0.5
				NoForcedWhiff=1
				Instinct=3
				DamageMult=9
				Stunner=5
				Launcher=6
				Rounds=10
				RoundMovement=0
				StrOffense=1
				EndDefense=0.75
				ForOffense=1
				Cooldown=-1
				//HitSparkIcon='Hit Effect Excal.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=7
				TurfShift='Excalitrail.dmi'
				TurfStrike=1
				Shearing=15
				Slow=1
				WindUp=1
				WindupIcon='Ripple Radiance.dmi'
				WindupIconUnder=1
				WindupIconX=-32
				WindupIconY=-32
				GuardBreak=1//Can't be dodged or blocked
				WindupMessage="raises their blade overhead as holy energy takes shape around them..."
				ActiveMessage="releases a holy slash that mows the area before them in a wave of light!"
				verb/True_Excalibur()
					set category="Skills"
					usr.Activate(src)*/

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
					StrOffense=0.5
					ForOffense=0.5
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
					StrOffense=0.5
					ForOffense=0.5
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
						StrOffense=0.5
						ForOffense=0.5
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
						StrOffense=0.5
						ForOffense=0.5
						Slow=1
						verb/Freeze_Ray()
							set category="Skills"
							usr.Activate(src)
///Cybernetics
			Cyberize
				Machine_Gun_Flurry
					Area="Circle"
					Distance=1
					StrOffense=1
					ManaCost=2
					DamageMult=0.9
					Launcher = 2
					ComboMaster=1
					Rounds=10
					Rush=25
					ControlledRush=1
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
				Area="Strike"
				ControlledRush=1
				Rush=3
				Distance=1
				StrOffense=1
				ForOffense=0.5
				DamageMult=4.5
				HitSparkIcon='Hit Effect Pearl.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=5
				HitSparkCount=5
				HitSparkDispersion=1
				HitSparkDelay=1
				Cooldown=60
				ActiveMessage="thrusts their hand forward to freeze all within their grasp!"
				Freezing=20
				Stasis=10
				verb/Frost_Bite()
					set category="Skills"
					usr.Activate(src)
			OpticBarrel
				NoTransplant=1
				Area="Target"
				Distance=5
				Cooldown=20
				ForOffense=1
				DamageMult=2
				HitSparkIcon='Hit Effect Ripple.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=1
				HitSparkCount=5
				HitSparkDispersion=1
				HitSparkDelay=1
				ActiveMessage="yells: OPTIC BARREL!"
				verb/Optic_Barrel()
					set category="Skills"
					usr.Activate(src)
////General
			Giga_Slave
				NoTransplant=1
				ForOffense=1
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
		Activate(var/obj/Skills/AutoHit/Z, ignoreCuck = FALSE)
			set waitfor = FALSE
			. = TRUE
			if(glob.CUCK_MACROSTRINGS && !ignoreCuck)
				if(last_autohit + glob.MACROCHECKTIME > world.time)
					return FALSE
			if(src.passive_handler.Get("Silenced"))
				src << "You can't use [Z] you are silenced!"
				return 0
			if(src.passive_handler.Get("HotHundred") || src.passive_handler.Get("Warping") || (src.AttackQueue && src.AttackQueue.Combo))
				Z.while_warping = TRUE
			else
				Z.while_warping = FALSE
			if(Z.Using)//Skill is on cooldown.
				return FALSE
			if(!Z.heavenlyRestrictionIgnore && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Autohits"))
				return FALSE
			if(!Z.heavenlyRestrictionIgnore && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("All Skills"))
				return FALSE
			if(!Z.heavenlyRestrictionIgnore && Z.NeedsSword && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Armed Skills"))
				return FALSE
			if(!Z.heavenlyRestrictionIgnore && Z.UnarmedOnly && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Unarmed Skills"))
				return FALSE
			if(!src.CanAttack(1.5)&&!Z.NoAttackLock)
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
					return
				if(Z.Copyable>=3||!Z.Copyable)
					if(passive_handler.Get("Disarmed"))
						src << "You are disarmed you can't use [Z]."
						return
					if(!src.HasSpellFocus(Z))
						src << "You need a spell focus to use [Z]."
						return
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
				if(Target && Target.passive_handler.Get("CounterSpell"))
					for(var/obj/Skills/Buffs/SlotlessBuffs/Magic/Counterspell/s in Target)
						if(s.Using)
							s.Trigger(Target, Override = 1)
					OMsg(Target, "[Target]'s counterspell nullified [Z]")
					Z.Cooldown()
					return
			if(Z.NeedsSword)
				var/obj/Items/Sword/s=src.EquippedSword()
				if(passive_handler.Get("Disarmed") && s)
					src << "You are disarmed you can't use [Z]."
					return
				if(!s)
					if(passive_handler.Get("Disarmed") && HasBladeFisting())
						src << "You are disarmed you can't use [Z]."
						return
					if(!src.HasBladeFisting() && !src.UsingBattleMage())
						src << "You need a sword equipped to use [Z]!"
						return
			if(Z.UnarmedOnly)
				var/obj/Items/Sword/s=src.EquippedSword()
				if(s)
					if(!HasBladeFisting())
						src << "You can't have a sword equipped when using [Z]!  It's an unarmed technique!"
						return
				if(src.UsingBattleMage())
					src << "You can't use unarmed techniques while using Battle Mage!"
					return
			if(Z.ABuffNeeded)
				if(!src.ActiveBuff||src.ActiveBuff.BuffName!=Z.ABuffNeeded)
					src << "You have to be in [Z.ABuffNeeded] state to use this!"
					return
			if(Z.SBuffNeeded)
				if(!src.SpecialBuff||src.SpecialBuff.BuffName!=Z.SBuffNeeded)
					src << "You have to be in [Z.SBuffNeeded] state to use this!"
					return
			if(Z.StanceNeeded)
				if(src.StanceActive!=Z.StanceNeeded)
					src << "You have to be in [Z.StanceNeeded] stance to use this!"
					return
			if(Z.StyleNeeded)
				if(src.StyleActive!=Z.StyleNeeded)
					src << "You have to be using [Z.StyleNeeded] style to use this!"
					return
			if(Z.GateNeeded)
				if(src.GatesActive<Z.GateNeeded)
					src << "You have to open at least Gate [Z.GateNeeded] to use this skill!"
					return
			if(Z.ClassNeeded)
				var/obj/Items/Sword/s=src.EquippedSword()
				if(s.Class!=Z.ClassNeeded && (istype(Z.ClassNeeded, /list) && !(s.Class in Z.ClassNeeded)))
					src << "You need a [istype(Z.ClassNeeded, /list) ? Z.ClassNeeded[1] : Z.ClassNeeded]-class weapon to use this technique."
					return
			if(!Z.StrOffense&&!Z.ForOffense && !Z.AdaptRate)
				src << "[Z] is bugged and doesn't know how to calculate damage."
				return
			if(Z.HealthCost)
				if(src.Health<Z.HealthCost*glob.WorldDamageMult&&!Z.AllOutAttack)
					return
			if(Z.ForceCost)
				if(src.ForceBar<Z.ForceCost&&!Z.AllOutAttack)
					return
			if(Z.EnergyCost)
				var/drain = passive_handler["Drained"] ? Z.EnergyCost * (1 + passive_handler["Drained"]/10) : Z.EnergyCost
				if(src.Energy<drain&&!Z.AllOutAttack)
					if(!src.CheckSpecial("One Hundred Percent Power")&&!src.CheckSpecial("Fifth Form")&&!CheckActive("Eight Gates"))
						return
			if(Z.ManaCost && !src.HasDrainlessMana() && !Z.AllOutAttack)
				var/drain = src.passive_handler.Get("MasterfulCasting") ? Z.ManaCost - (Z.ManaCost * (passive_handler.Get("MasterfulCasting") * 0.3)) : Z.ManaCost
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
			if(src.HasRipple())
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
			if(Z.Area=="Around Target"||Z.Area=="Target")
				TrgLoc=src.Target.loc
				if(Target.passive_handler.Get("CounterSpell"))
					for(var/obj/Skills/Buffs/SlotlessBuffs/Magic/Counterspell/s in Target)
						if(s.Using)
							s.Trigger(Target, Override = 1)
					OMsg(Target, "[Target]'s counterspell nullified [Z]")
					Z.Cooldown()
					return
			if(Z.CustomCharge)
				OMsg(src, "[Z.CustomCharge]")
			else
				if(Z.WindupMessage)
					OMsg(src, "<b><font color='[Z.WindupColor]'>[src] [Z.WindupMessage]</font color></b>")
			if(src.TomeSpell(Z))
				Z.Cooldown()
			else
				Z.Cooldown()
			if(Z.Copyable)
				var/copy = Z.Copyable
				spawn() for(var/mob/m in view(10, src))
					if(m.CheckSpecial("Sharingan"))
						var/copyLevel = getSharCopyLevel(m.SagaLevel)
						if(Z.NewCopyable)
							copy = Z.NewCopyable
						else
							copy = Z.Copyable
						if(glob.SHAR_COPY_EQUAL_OR_LOWER)
							if(copyLevel < copy)
								continue
						else
							if(copyLevel <= copy)
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
						src.UseProjectile(s)
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
				if(src.HasQuickCast())
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
						if(get_dist(src, Target) > Distance)
							missed=1

			if(Z.CustomActive)
				OMsg(src, "[Z.CustomActive]")
			else
				if(Z.ActiveMessage)
					OMsg(src, "<b><font color='[Z.ActiveColor]'>[src] [Z.ActiveMessage]</font color></b>")
			if(passive_handler["AirBend"] && can_use_style_effect("AirBend"))
				flick("KB", Target)
				step_away(Target, src)
				last_style_effect = world.time
			if(!Z.SpecialAttack)
				if(src.UsingSpiritStrike())
					Z.TempStrOff=0
					Z.TempForOff=1
				if(Z.NeedsSword&&src.HasSpiritSword())
					Z.TempStrOff=1*src.GetSpiritSword()
					Z.TempForOff=1*src.GetSpiritSword()
				else if(src.HasHybridStrike())
					if(Z.TempStrOff && !Z.TempForOff)
						Z.TempForOff = GetHybridStrike() // get the value of hybrid strike
					else if(!Z.TempStrOff && Z.TempForOff)
						Z.TempStrOff = GetHybridStrike() // get the value of hybrid strike
					else if(!Z.TempStrOff && !Z.TempForOff)
						Z.TempForOff = 1
						Z.TempStrOff = GetHybridStrike()

				else
					Z.TempStrOff=1
					Z.TempForOff=0
			if(src.AttackQueue && !src.AttackQueue.FollowUp)
				src << "<b>You drop [src.AttackQueue.name] from your queue.</b>"
				src.QueueOverlayRemove()
				src.ClearQueue()
			if(!Z.Rounds)
				Z.Rounds=1
			if(Z.Rounds<3&&!Z.ChargeTech)
				Z.DelayTime=5
			if(!Z.RoundMovement&&Z.Rounds>1)
				src.Frozen=2

			if(Z.PreShockwave)
				if(Z.Shockwave)
					spawn()
						var/ShockSize=Z.Shockwave
						if(Z.Shockwaves<1)
							Z.Shockwaves=1
						for(var/wav=Z.Shockwaves, wav>0, wav--)
							KenShockwave(src, icon=Z.ShockIcon, Size=ShockSize, Blend=Z.ShockBlend, Time=Z.ShockTime)
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
				if(Z.Area=="Around Target")
					spawn()
						if(Z.Falling)
							LeaveDescendingImage(User=0, Image=i, PX=src.Target.pixel_x+Z.IconX, PY=src.Target.pixel_y+Z.IconY, PZ=src.Target.pixel_z+16+(32*Z.Rounds/10), Size=Z.Size, Under=Z.IconUnder, Time=(Z.Rounds-1*max(1,Time)), AltLoc=TrgLoc)
						else
							LeaveImage(User=0, Image=i, PX=src.Target.pixel_x+Z.IconX, PY=src.Target.pixel_y+Z.IconY, PZ=src.Target.pixel_z+48, Size=Z.Size, Under=Z.IconUnder, Time=(Z.Rounds-1*max(1,Time)), AltLoc=TrgLoc)
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
				var/GO=Z.Rush
				src.icon_state="Flight"
				if(Z.RushDelay<1)
					VanishImage(src)
				while(GO>0)
					if(Z.ControlledRush&&src.Target)
					//	var/travel_angle = GetAngle(src, src.Target)
						if(length(src.filters) < 1)
							AppearanceOn()

						//animate(src.filters[length(src.filters)], x=sin(travel_angle)*(6/Z.RushDelay), y=cos(travel_angle)*(6/Z.RushDelay), time=Z.RushDelay)
						step_towards(src,src.Target)
						if(get_dist(src,src.Target)==1)
							GO=0
							src.dir=get_dir(src,src.Target)
							if(src.Target.Knockbacked)
								src.Target.Knockbacked=0
								src.Target.Frozen=1
								spawn(3)
									src.Target.Frozen=0
						GO-=world.tick_lag
						if(GO > 0)
							DelayRelease+=Z.RushDelay
							if(DelayRelease>=1)
								DelayRelease--
								sleep(1)
					else
						//var/travel_angle = dir2angle(src.dir)
						if(length(src.filters) < 1)
							AppearanceOn()
						//animate(src.filters[filters.len], x=sin(travel_angle)*(6/Z.RushDelay), y=cos(travel_angle)*(6/Z.RushDelay), time=Z.RushDelay)
						step(src,src.dir)
						if(Z.Area=="Strike"||Z.Area=="Arc"||Z.Area=="Cone")
							for(var/atom/a in get_step(src,dir))
								if(a==src)
									continue
								if(a.density)
									GO=0
						else
							for(var/atom/a in view(1,src))
								if(a==src)
									continue
								if(a.density)
									GO=0
						GO-= world.tick_lag
						if(GO > 0)
							DelayRelease+=Z.RushDelay
							if(DelayRelease>=1)
								DelayRelease--
								sleep(1)
				src.is_dashing--
				if(is_dashing<0)
					is_dashing=0
				src.WindingUp=0
				animate(src.filters[filters.len], x=0, y=0)
				src.icon_state=""
			if(Z.FlickAttack==1)
				flick("Attack",src)
			var/RoundCount=Z.Rounds
			if(Z.MagicNeeded&&src.HasDualCast())
				RoundCount*= 1+ src.HasDualCast()
				RoundCount = floor(RoundCount)
			while(RoundCount>0)
				//if(!src.Target) break
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
							if(get_dist(src, Target) > Distance)
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
								KenShockwave(src, icon=Z.ShockIcon, Size=ShockSize, Blend=Z.ShockBlend, Time=Z.ShockTime)
								ShockSize/=2
				if(Z.ChargeTech)
					src.Frozen=1
					if(Z.ChargeFlight)
						src.icon_state="Flight"
					DelayRelease+=Delay
					if(DelayRelease>=1)
						DelayRelease--
						sleep(1)
					step(src, src.dir)
				else
					sleep(Delay)
				RoundCount--
			src.ClearTech(Z)

		ClearTech(var/obj/Skills/AutoHit/Z)//Used to resolve any variable conflicts at the end of an autohit
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
				src.DoDamage(src, Z.HealthCost*CostMultiplier*glob.WorldDamageMult)
			if(Z.WoundCost)
				src.WoundSelf(Z.WoundCost*CostMultiplier*glob.WorldDamageMult)
			if(Z.EnergyCost)
				var/drain = passive_handler["Drained"] ? Z.EnergyCost * (1 + passive_handler["Drained"]/10) : Z.EnergyCost
				src.LoseEnergy(drain*CostMultiplier)
			if(Z.ForceCost)
				src.LoseForce(Z.ForceCost*CostMultiplier)
			if(Z.FatigueCost)
				src.GainFatigue(Z.FatigueCost*CostMultiplier)
			if(Z.ManaCost)
				var/drain = src.passive_handler.Get("MasterfulCasting") ? Z.ManaCost - (Z.ManaCost * (passive_handler.Get("MasterfulCasting") * 0.3)) : Z.ManaCost
				if(drain <= 0)
					drain = 0.5
				if(!src.TomeSpell(Z))
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
			Z.TempStrOff=0
			Z.TempForOff=0
			Z.TempEndDef=0
			if(Z.RoundMovement&&Z.Rounds>1)
				src.Frozen=0
			if(Z.Attracting)
				src.Attracting-=Z.Attracting
			if(src.HasRipple())
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
			Cleansing = 0
			ManaDrain
			FoxFire
			hitSelf = 0

			Arcing//Triggers offshoots on every step that expand outwards.  Higher than 1 means that every X steps the range will widen.
			ArcingCount=0//Number of times arcing has been triggered.  Informs the game how many tiles to send the offshoots.
			Wave//Triggers offshoots that extend this number of steps on every step.
			Cardinal//Triggers offshoots in 4 directions.
			CardinalTriggered//Binary that makes sure crosses don't cross.
			Circle//Affects a circle
			mob/Target//Instantly hits this person
			turf/TargetLoc//Hits around this location

			ObjIcon//get an icon from the other obj
			currentRounds
			Damage//This is the amount of damage a skill will do if all stats and power are equal.
			StepsDamage=0
			StepsTaken=0//A variable for easy recording
			list/DamageSteps=list()//This is a variable that allows damage to scale based on the steps taken by the projectile.  Think Tipper.
			while_warping = FALSE
			StrDmg//Does it factor in strength?
			ForDmg//Does it factor in force?
			//Mark both for hybrid.
			EndRes//Does endurance make it do less damage?

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

			Slow//Autohit doesn't hit instantly
			ApplySlow
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
			Primordial
			SpeedStrike
			AdaptDmg

			Scorching
			Chilling
			Freezing
			Crushing
			Burning
			Shattering
			Toxic
			Paralyzing
			Crippling
			Shocking
			Poisoning

			grabNerf = 0
			BuffAffected = 0
			buffAffectedType = 0
			buffAffectedCompare = 0
			buffAffectedBoon = 0

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

		Update()
			..()


		New(var/mob/owner, var/arcing=0, var/wave=0, var/card=0, var/circle=0, var/mob/target, var/obj/Skills/AutoHit/Z, var/turf/TrgLoc, life = 500)
			set waitfor = FALSE
			if(!owner)
				loc = null
				return
			AlreadyHit = list()
			autohitChildren = list()
			src.IgnoreAlreadyHit = Z.IgnoreAlreadyHit
			toDeath = life
			src.Owner=owner
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
				bound_height = 32 * Distance
				bound_width = 32 * Distance
			src.DistanceMax=Z.Distance
			if(TrgLoc)
				src.TargetLoc=TrgLoc
				src.DistanceMax=Z.DistanceAround
			src.Target=target
			src.NoPierce=Z.NoPierce
			FollowUp = Z.FollowUp
			FollowUpDelay = Z.FollowUpDelay
			BuffSelf = Z.BuffSelf
			src.Damage=Z.DamageMult
			src.StepsDamage=Z.StepsDamage
			src.MagicNeeded=Z.MagicNeeded
			if(Z.while_warping)
				Damage /= glob.WHILEWARPINGNERF
				Z.while_warping = FALSE
			if(Z.TempStrOff && !Z.StrOffense)
				src.StrDmg=Z.TempStrOff
			else
				src.StrDmg=Z.StrOffense
			if(Z.TempForOff && !Z.ForOffense)
				src.ForDmg=Z.TempForOff
			else
				src.ForDmg=Z.ForOffense
			if(Z.TempEndDef && !Z.EndDefense)
				src.EndRes=Z.TempEndDef
			else
				src.EndRes=Z.EndDefense
			if(Z.AdaptRate)
				AdaptDmg = Z.AdaptRate
			FoxFire = Z.FoxFire
			ManaDrain = Z.ManaDrain
			Snaring=Z.Snaring
			SnaringOverlay=Z.SnaringOverlay
			src.Executor = Z.Executor
			src.Primordial = Z.Primordial
			src.RagingDemonAnimation = Z.RagingDemonAnimation
			src.GoldScatter = Z.GoldScatter
			src.Knockback=Z.Knockback
			src.ChargeTech=Z.ChargeTech
			src.UnarmedTech=Z.UnarmedOnly
			src.SwordTech=Z.NeedsSword
			src.SpecialAttack=Z.SpecialAttack
			src.Deluge=Z.Deluge
			src.Stunner=Z.Stunner
			src.Destructive=Z.Destructive
			src.Shearing = Z.Shearing
			src.Bang=Z.Bang
			src.Bolt=Z.Bolt
			src.BoltOffset=Z.BoltOffset
			src.Scratch=Z.Scratch
			src.Punt=Z.Punt
			src.Divide=Z.Divide
			src.TurfErupt=Z.TurfErupt
			src.TurfEruptOffset=Z.TurfEruptOffset
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
			src.ComboMaster=Z.ComboMaster
			Dunker = Z.Dunker
			Destroyer = Z.Destroyer
			src.CanBeBlocked=Z.CanBeBlocked
			src.CanBeDodged=Z.CanBeDodged
			src.Slow=Z.Slow
			src.ApplySlow = Z.ApplySlow
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
			PullIn = Z.PullIn
			if(Z.Burning)
				src.Burning+=Z.Burning
			if(Z.Scorching)
				src.Scorching+=Z.Scorching
			if(Z.Chilling)
				src.Chilling+=Z.Chilling
			if(Z.Freezing)
				src.Freezing+=Z.Freezing
			if(Z.Crushing)
				src.Crushing+=Z.Crushing
			if(Z.Shattering)
				src.Shattering+=Z.Shattering
			if(Z.Shocking)
				src.Shocking+=Z.Shocking
			if(Z.Paralyzing)
				src.Paralyzing+=Z.Paralyzing
			if(Z.Poisoning)
				src.Poisoning+=Z.Poisoning
			if(Z.Toxic)
				src.Toxic+=Z.Toxic
			if(Z.Crippling)
				src.Crippling+=Z.Crippling
			if(Z.ObjIcon)
				src.ObjIcon=Z.ObjIcon
				var/icon/i=Z.Icon
				if(Z.IconRed||Z.IconGreen||Z.IconBlue)
					i+=rgb(Z.IconRed, Z.IconGreen, Z.IconBlue)
				src.icon=i

				src.pixel_x=Z.IconX
				src.pixel_y=Z.IconY
				src.transform*=Z.Size


			src.dir=src.Owner.dir
			src.loc=src.Owner.loc
			src.Distance=src.DistanceMax

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
					src.loc=m.loc
		Update()
			if(Persistent)
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
										src.Owner.dir=get_dir(src.Owner, src.Owner.Target)//facing them
								else
									if(Owner)
										src.Owner.loc=get_step(src.Owner.Target, turn(src.Owner.Target.dir, 180))//Appear behind the fucker
										src.Owner.dir=turn(get_dir(src.Owner, src.Owner.Target), 180)//facing away
							else
								if(Owner)
									src.Owner.loc=src.loc
			catch()
			walk(src,0)
			animate(src)
			if(AHOwner)
				AHOwner.autohitChildren -= src
			AHOwner = null
			AlreadyHit = null
			autohitChildren = null
			Owner = null
			ticking_generic -= src
			loc = null
			sleep(10)
			del src
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
				AlreadyHit |= m
				for(var/obj/AutoHitter/ah in autohitChildren)
					ah.AlreadyHit |= m
				if(istype(Owner, /mob/Player/AI) && m != Owner)
					var/mob/Player/AI/a = Owner
					if(!a.ai_team_fire && a.AllianceCheck(m))
						return
				if(src.StopAtTarget)
					AfterImage(src.Owner)
					src.Owner.loc=get_step(m, get_dir(m, src.Owner))
					src.Stopped=1
				if(src.PassTo)
					AfterImageA(src.Owner, forceloc=get_step(m, get_dir(m, src.Owner)))
				if(src.MagicNeeded)
					if(m.passive_handler.Get("CounterSpell"))
						OMsg(m, "[m]'s counterspell negates the spells damage!")
						return
				// grabNerf = Owner.Grab && ! ? 1 : 0
				//world<<"GrabNerf: [grabNerf]"
				var/FinalDmg
				var/powerDif = Owner.Power/m.Power
				if(glob.CLAMP_POWER)
					if(!Owner.ignoresPowerClamp())
						powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
				#if DEBUG_AUTOHIT
				Owner.log2text("powerDif - Auto Hit", powerDif, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
				#endif
				var/atk = 0
				if(AdaptDmg)
					if(Owner.GetStr(1) > Owner.GetFor(1))
						StrDmg = AdaptDmg
					else
						ForDmg = AdaptDmg
				if(ForDmg && !StrDmg)
					atk = Owner.GetFor(ForDmg)
				else if(StrDmg && !ForDmg)
					atk = Owner.getStatDmg2() * StrDmg
				else if(StrDmg && ForDmg)
					if(glob.AUTOHIT_HYBRID_AS_MULT)
						atk = Owner.GetStr(StrDmg) *1 + (Owner.GetFor(ForDmg)/10)
					else
						atk = Owner.GetStr(StrDmg) + (Owner.GetFor(ForDmg))
				else
					Owner << "Your auto hit could not calculate the damage it just did!! Report this !!"
				DEBUGMSG("atk final is: [atk]")
				var/dmgMulti = Damage
				if(Owner.HasSpiritFlow())
					var/sf = Owner.GetSpiritFlow() / glob.SPIRIT_FLOW_DIVISOR
					atk += Owner.GetFor(sf)
				DEBUGMSG("atk final (post spiritflow) is: [atk]")
				#if DEBUG_AUTOHIT
				Owner.log2text("atk - Auto Hit", atk, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
				#endif
				var/dmgRoll = Owner.GetDamageMod()
				DEBUGMSG("dmgRoll is: [dmgRoll]")
				#if DEBUG_AUTOHIT
				Owner.log2text("dmg roll - Auto Hit", dmgRoll, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
				#endif
				if(m.HasGiantForm())
					var/mod = glob.upper_damage_roll / 6
					dmgRoll = Owner.GetDamageMod(0, -mod)
					#if DEBUG_AUTOHIT
					Owner.log2text("dmg roll - Auto Hit", "After GiantForm", "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
					Owner.log2text("dmg roll - Auto Hit", dmgRoll, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
					#endif
				var/def = m.getEndStat(1) * EndRes
				if(def<0)
					def=0.01
				if(m.HasPridefulRage())
					if(m.isRace(SAIYAN))
						if(Owner.passive_handler.Get("PridefulRage") >= 2)
							def = 1
						else
							def = clamp(def/2, 1, def)

				if(Owner.HasPridefulRage())
					if(Owner.passive_handler.Get("PridefulRage") >= 2)
						def = 1
					else
						def = clamp(def/2, 1, def)
				#if DEBUG_AUTOHIT
				Owner.log2text("def - Auto Hit", def, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
				#endif
				// powerDif += Owner.getIntimDMGReduction(m)
				#if DEBUG_AUTOHIT
				Owner.log2text("powerDif - Auto Hit", powerDif, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
				#endif
				FinalDmg = (clamp(powerDif,0.1,100000)**glob.DMG_POWER_EXPONENT) * (glob.CONSTANT_DAMAGE_EXPONENT+glob.AUTOHIT_EFFECTIVNESS) ** -(def**glob.DMG_END_EXPONENT / atk**glob.DMG_STR_EXPONENT)
				#if DEBUG_AUTOHIT
				Owner.log2text("FinalDmg(before dmgRoll) - Auto Hit", FinalDmg, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
				#endif
				DEBUGMSG("FinalDmg is: [FinalDmg]")
				FinalDmg *= dmgMulti
				FinalDmg *= dmgRoll
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
							for(var/i = 0, i < 10; i++)
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
					FinalDmg *= clamp(sqrt(1+((Owner.GetSpd())*(src.SpeedStrike/glob.SPEEDSTRIKEDIVISOR))),1,3)
				if(Owner.UsingFencing())
					FinalDmg *= clamp(sqrt(1+((Owner.GetSpd())*(Owner.UsingFencing()/glob.SPEEDSTRIKEDIVISOR))),1,3)
				if((m.Launched||m.Stunned))
					if(!(ComboMaster || Owner.HasComboMaster() || Dunker || Destroyer))
						FinalDmg *= glob.CCDamageModifier
						Owner.log2text("FinalDmg - Auto Hit", "After ComboMaster", "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
						Owner.log2text("FinalDmg - Auto Hit", FinalDmg, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
					if(m.Stunned && Destroyer)
						FinalDmg *= 1 + (Destroyer/10)
				var/obj/Items/Armor/HittingArmor=m.EquippedArmor()
				var/obj/Items/Armor/WearingArmor=src.Owner.EquippedArmor()
				if(HittingArmor)//Reduced damage
					var/dmgEffective = m.GetArmorDamage(HittingArmor)
					if(Owner.passive_handler["Half-Sword"])
						dmgEffective -= Owner.passive_handler["Half-Sword"] * glob.HALF_SWORD_ARMOR_REDUCTION
					if(dmgEffective>0)
						FinalDmg -=  FinalDmg * dmgEffective/10
					else
						FinalDmg += FinalDmg * abs(dmgEffective/10)
					Owner.log2text("FinalDmg - Auto Hit", "After HittingArmor", "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
					Owner.log2text("FinalDmg - Auto Hit", FinalDmg, "damageDebugs.txt", "[Owner.ckey]/[Owner.name]")
				if(Owner.passive_handler["Half-Sword"] && !HittingArmor)
					FinalDmg += FinalDmg * (Owner.passive_handler["Half-Sword"]/glob.HALF_SWORD_UNARMOURED_DIVISOR)

				if(WearingArmor)//Reduced delay and accuracy
					Precision*=src.Owner.GetArmorAccuracy(WearingArmor)
				var/reversalChance = m.GetAutoReversal()
				if(prob(reversalChance * 100) && currentRounds == 1)
					if(m.HasAutoReversal())
						if(!src.SpecialAttack||m.passive_handler.Get("TotalReversal"))
							if(Accuracy_Formula(src.Owner, m, AccMult=Precision, BaseChance=glob.WorldDefaultAcc, IgnoreNoDodge=1) == (HIT || WHIFF))
								if(m.passive_handler["Magmic"] && m.SlotlessBuffs["Magmic Shield"])
									m.SlotlessBuffs["Magmic Shield"].Trigger(m, TRUE)
								if(src.Damage>0.1)
									KenShockwave(m, icon='KenShockwave.dmi', Size=dmgRoll, Time=3)
									m.Knockback(src.Knockback+(reversalChance*2.5) , src.Owner, Direction=get_dir(m, src.Owner))
								m.DoDamage(src.Owner, (FinalDmg/5), UnarmedAttack=src.UnarmedTech, SwordAttack=src.SwordTech, SpiritAttack=src.SpecialAttack, Autohit = TRUE)
								if(src.Bang)
									Bang(src.Owner.loc, src.Bang)
								if(src.Scratch)
									Scratch(src.Owner)
								if(src.Bolt)
									LightningBolt(src.Owner, src.Bolt, src.BoltOffset)
								if(src.Punt)
									Hit_Effect(src.Owner, Size=src.Punt)
								src.Owner.HitEffect(src.Owner, src.UnarmedTech, src.SwordTech)
								return

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

				if(!src.CanBeBlocked&&!src.CanBeDodged)
					FinalDmg *= glob.AUTOHIT_GLOBAL_DAMAGE
				else
					FinalDmg*=1.5
				DEBUGMSG("after glob mod: [FinalDmg]")

				if(m.passive_handler.Get("Siphon")&&src.ForDmg)
					var/Heal = (FinalDmg * (m.passive_handler.Get("Siphon")/ 10)) * ForDmg
					FinalDmg-=Heal //negated
					m.HealEnergy(Heal)
				if(Owner.Attunement == "Fox Fire")
					var/heal = FinalDmg * ( (1 + Owner.AscensionsAcquired + (FoxFire))/10)
					m:LoseEnergy(heal/2)
					m:LoseMana(heal/2)
					Owner.HealEnergy(heal/2)
					Owner.HealMana(heal/2)
				if(m.HasDeflection()&&!src.CanBeDodged)
					if(m.CheckSlotless("Deflector Shield"))
						if(!m.Shielding)
							m.Shielding=1
							spawn()
								m.ForceField()
					FinalDmg*=max(1-(0.25*m.GetDeflection()),0.3)
					DEBUGMSG("after Deflection: [FinalDmg]")

				if(m.HasBlastShielding()&&!src.CanBeDodged)
					FinalDmg/=2**3
					DEBUGMSG("after BlastShielding: [FinalDmg]")

				var/list/Elements = list()
				if(Scorching||Burning)
					Elements |= "Fire"
				if(Chilling||Freezing)
					Elements |= "Water"
				if(Crushing||Shattering)
					Elements |= "Earth"
				if(Shocking||Paralyzing)
					Elements |= "Wind"
				if(Toxic||Poisoning)
					Elements |= "Poison"

				ElementalCheck(Owner, m, 0, bonusElements = Elements)

				if(Crippling)
					m.AddCrippling(Crippling, Owner)
				if(Shearing)
					m.AddShearing(Shearing, Owner)

				if(Cleansing && m in src.Owner.party)
					m.Slow -= Cleansing*10
					if(m.Slow < 0)
						m.Slow = 0
					m.Crippled -= Cleansing*10
					if(m.Crippled < 0)
						m.Crippled = 0
					m.Burn -= Cleansing*10
					if(m.Burn < 0)
						m.Burn = 0
					m.Poison -= Cleansing*10
					if(m.Poison < 0)
						m.Poison = 0
					m.Shatter -= Cleansing*10
					if(m.Shatter < 0)
						m.Shatter = 0
					m.Shock -= Cleansing*10
					if(m.Shock < 0)
						m.Shock = 0
					m.Sheared -= Cleansing*10
					if(m.Sheared < 0)
						m.Sheared = 0

				// if(src.CosmoPowered)
				//  	if(!src.Owner.SpecialBuff)
				//  		FinalDmg*=TrueDamage(1+(src.Owner.SenseUnlocked-5))
				if(src.Executor)
					var/additonal = src.Executor * 0.1
					if(m.Health<=5)
						additonal *= 2
					if(m.Health <=25)
						FinalDmg *= 1 + additonal
				if(Primordial)
					var/additonal = Primordial
					var/missingHealth = 100-m.Health
					FinalDmg *= 1 + ((additonal * missingHealth)/100)
				if(ApplySlow)
					m.AddSlow(ApplySlow, Owner)
				if(grabNerf)
					FinalDmg *= glob.AUTOHIT_GRAB_NERF
					DEBUGMSG("after grabNerf: [FinalDmg]")
//TODO: Remove a whole lot of those
				if(src.Bang)
					Bang(m.loc, src.Bang)
				if(src.Scratch)
					Scratch(m)
				if(src.Bolt)
					LightningBolt(m, src.Bolt, src.BoltOffset)
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
							if(m.passive_handler["Determination"])
								m.HealMana(m.SagaLevel*1.25)
							else
								m.HealMana(m.SagaLevel*5)
						if(m.CanAttack())
							m.Melee1(Damage,2,0,0,null,null,0,0,2,1)
					if(m.HasFlow())
						if(prob(getFlowCalc(Owner, m)))
							if(!src.TurfStrike)
								spawn()
									src.Owner.HitEffect(loc, src.UnarmedTech, src.SwordTech)
							StunClear(m)
							AfterImageStrike(m, src.Owner,0)
							return

					if(Accuracy_Formula(src.Owner, m, AccMult=Precision, BaseChance=glob.WorldDefaultAcc, IgnoreNoDodge=0) == MISS)
						DEBUGMSG("LOL AUTOHITS CAN MISS ? [Damage]")
						Damage /= glob.AUTOHIT_MISS_DAMAGE
						DEBUGMSG("after FR")

					if(m.AfterImageStrike)
						if(!src.TurfStrike)
							spawn()
								src.Owner.HitEffect(loc, src.UnarmedTech, src.SwordTech)
						StunClear(m)
						AfterImageStrike(m, src.Owner,1)
						m.AfterImageStrike-=1
						if(m.AfterImageStrike<0)
							m.AfterImageStrike=0
							for(var/obj/Skills/Zanzoken/z in src)
								z.Cooldown()//freeze that after image shieet
						return

				if(src.MortalBlow)
					if(src.MortalBlow<0)
						m.MortallyWounded+=4
					else
						if(prob(glob.MORTAL_BLOW_CHANCE * MortalBlow) && !m.MortallyWounded)
							var/mortalDmg = m.Health * 0.05 // 5% of current
							m.LoseHealth(mortalDmg)
							m.WoundSelf(mortalDmg)
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
				var/damageDealt = src.Owner.DoDamage(m, FinalDmg, src.UnarmedTech, src.SwordTech, Destructive=src.Destructive, innateLifeSteal = LifeSteal, Autohit = TRUE)
				DEBUGMSG("FINAL TOTAL DAMAGE DEALT! [damageDealt]")
				if(!damageDealt)
					damageDealt = 0

				if(ManaDrain)
					m.LoseMana(ManaDrain)
					src.Owner.HealMana(ManaDrain)

				if(CorruptionGain)
					Owner.gainCorruption((FinalDmg * 2) * glob.CORRUPTION_GAIN)
				if(src.Owner.UsingAnsatsuken())
					src.Owner.HealMana(src.Owner.SagaLevel)
				if(src.Owner.SagaLevel>1&src.Owner.Saga=="Path of a Hero: Rebirth")
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
							KenShockwave(m, Size=min((src.Knockback+src.Owner.Intimidation/50)*max(2*src.Owner.GetGodKi(),1)*GoCrand(0.04,0.4),0.2),PixelX=pick(-12,-8,8,12),PixelY=pick(-12,-8,8,12))
						if(m!=src.Owner.Grab)
							src.Owner.Knockback(src.Knockback+extraKnock, m, get_dir(src.Owner, m), extraKnock)

				if(PullIn)
					src.Owner.Knockback(PullIn, m, Direction=get_dir(m, Owner))

				if(src.Stunner)
					Stun(m, src.Stunner+src.Owner.GetStunningStrike())
					if(src.Stunner>5)
						m << "Your mind is under attack!"
						if(m.client)
							animate(m.client, color = list(-1,-1,-1, -1,-1,-1, -1,-1,-1, 1,1,1), time = 5)
							m.TsukiyomiTime=6
				if(src.Flash)
					m.Blind(src.Flash*(10*world.tick_lag))
					m.RemoveTarget()
					m.Grab_Release()

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





			Life()
				if(src.loc == null) return
				if(src.Circle)
					if(src.TargetLoc)
						if(src.Slow&&src.Distance>1)
							src.Owner.Frozen=1
							for(var/Rounds=1, Rounds<=src.DistanceMax, Rounds++)
								if(src.StepsDamage&&Rounds>1)
									src.Damage+=src.StepsDamage//add growing damage
								if(src.DistanceMax>=3)//Greater than 3 distance, use circle
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
										for(var/mob/m in t.contents)
											if(!hitSelf&&m==src.Owner)
												continue
											src.Damage(m)
									for(var/turf/t in Turf_Circle_Edge(src.TargetLoc, Rounds))
										if(src.TurfErupt)
											Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4)
										if(src.TurfDirt)
											Dust(t)
										if(src.TurfStrike)
											spawn()
												for(var/s=src.TurfStrike, s>0, s--)
													if(Owner)
														src.Owner.HitEffect(t, src.UnarmedTech, src.SwordTech)
														sleep(1)
								else//Less than 3 distance, use square.
									if(src.TurfErupt)
										for(var/turf/t in view(Rounds, src.TargetLoc))
											if(t in view(Rounds, src.TargetLoc))
												continue
											Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4)
									if(src.TurfDirt)
										for(var/turf/t in view(Rounds, src.TargetLoc))
											if(t in view(Rounds, src.TargetLoc))
												continue
											Dust(t)
									if(src.TurfStrike)
										for(var/turf/t in view(Rounds, src.TargetLoc))
											if(t in view(Rounds, src.TargetLoc))
												continue
											spawn()
												for(var/s=src.TurfStrike, s>0, s--)
													if(Owner)
														src.Owner.HitEffect(t, src.UnarmedTech, src.SwordTech)
														sleep(1)
									if(src.Divide)
										for(var/turf/t in view(Rounds, src.TargetLoc))
											if(t in view(Rounds, src.TargetLoc))//Don't doublehit people
												continue
											Destroy(t, 9001)
									if(src.TurfReplace)
										for(var/turf/t in view(Rounds, src.TargetLoc))
											if(t in view(Rounds, src.TargetLoc))
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
											if(t in view(Rounds, src.TargetLoc))
												continue
											sleep(-1)
											TurfShift(src.TurfShift,t, src.TurfShiftDuration,src.Owner, src.TurfShiftLayer, src.TurfShiftDurationSpawn, src.TurfShiftDurationDespawn, TurfShiftState,TurfShiftX, TurfShiftY)
									for(var/mob/m in view(Rounds, src.TargetLoc))
										if(m in view(Rounds-1, src.TargetLoc))//Don't doublehit people
											continue
										if(!hitSelf&&m==src.Owner)
											continue
										src.Damage(m)
								sleep(src.Slow*world.tick_lag)
							src.Owner.Frozen=0
						else
							if(src.DistanceMax>=3)//If greater than 3 distance...
								if(src.TurfErupt)
									for(var/turf/t in Turf_Circle_Edge(src.TargetLoc, src.Distance))
										sleep(-1)
										Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4)
								if(src.TurfDirt)
									for(var/turf/t in Turf_Circle_Edge(src.TargetLoc, src.Distance))
										sleep(-1)
										Dust(t)
								if(src.TurfStrike)
									for(var/turf/t in Turf_Circle_Edge(src.TargetLoc, src.Distance))
										sleep(-1)
										spawn()
											for(var/s=src.TurfStrike, s>0, s--)
												if(Owner)
													src.Owner.HitEffect(t, src.UnarmedTech, src.SwordTech)
													sleep(1)
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
								for(var/turf/t in Turf_Circle(src.TargetLoc, src.Distance))
									sleep(-1)
									for(var/mob/m in t)
										if(!hitSelf&&src.Owner!=m)
											src.Damage(m)
							else//If less than 3 distance...
								if(src.TurfErupt)
									for(var/turf/t in view(src.Distance, src.TargetLoc))
										Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4)
								if(src.TurfDirt)
									for(var/turf/t in view(src.Distance, src.TargetLoc))
										Dust(t)
								if(src.TurfStrike)
									for(var/turf/t in view(src.Distance, src.TargetLoc))
										spawn()
											for(var/s=src.TurfStrike, s>0, s--)
												if(Owner)
													src.Owner.HitEffect(t, src.UnarmedTech, src.SwordTech)
													sleep(1)
								if(src.Divide)
									for(var/turf/t in view(src.Distance, src.TargetLoc))
										Destroy(t, 9001)
								if(src.TurfReplace)
									for(var/turf/t in view(src.Distance, src.TargetLoc))
										var/image/i=image(icon=src.TurfReplace)
										t.overlays+=i
										if(src.Deluge)
											t.effects+=i
											t.Deluged=1
											t.timeToDeath=Deluge
											t.ownerOfEffect=Owner
											ticking_turfs+=t
								if(src.TurfShift)
									for(var/turf/t in view(src.Distance, src.TargetLoc))
										sleep(-1)
										TurfShift(src.TurfShift,t, src.TurfShiftDuration,src.Owner, src.TurfShiftLayer, src.TurfShiftDurationSpawn, src.TurfShiftDurationDespawn, TurfShiftState,TurfShiftX, TurfShiftY)
								for(var/mob/m in view(src.Distance, src.TargetLoc))
									if(!hitSelf&&src.Owner!=m)
										src.Damage(m)
						goto Kill
					else

						//TODO: make hellstorm work here
						if(src.Slow&&src.Distance>1)
							src.Owner.Frozen=1
							for(var/Rounds=1, Rounds<=src.DistanceMax, Rounds++)
								currentRounds = Rounds
								if(src.StepsDamage&&Rounds>1)
									src.Damage+=src.StepsDamage//add growing damage
								if(src.DistanceMax>=3)//Greater than 3 distance, use circle
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
										for(var/mob/m in t.contents)
											if(!hitSelf&&m==src.Owner)
												continue
											src.Damage(m)
									for(var/turf/t in Turf_Circle_Edge(src.Owner, Rounds))
										if(src.TurfErupt)
											Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4)
										if(src.TurfDirt)
											Dust(t)
										if(src.TurfStrike)
											spawn()
												for(var/s=src.TurfStrike, s>0, s--)
													if(Owner)
														src.Owner.HitEffect(t, src.UnarmedTech, src.SwordTech)
														sleep(1)
								else//Less than 3 distance, use square.
									if(src.TurfErupt)
										for(var/turf/t in view(Rounds, src.Owner))
											if(t in view(Rounds, src.Owner))
												continue
											Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4)
									if(src.TurfDirt)
										for(var/turf/t in view(Rounds, src.Owner))
											if(t in view(Rounds, src.Owner))
												continue
											Dust(t)
									if(src.TurfStrike)
										for(var/turf/t in view(Rounds, src.Owner))
											if(t in view(Rounds, src.Owner))
												continue
											spawn()
												for(var/s=src.TurfStrike, s>0, s--)
													if(Owner)
														src.Owner.HitEffect(t, src.UnarmedTech, src.SwordTech)
														sleep(1)
									if(src.Divide)
										for(var/turf/t in view(Rounds, src.Owner))
											if(t in view(Rounds, src.Owner))//Don't doublehit people
												continue
											Destroy(t, 9001)
									if(src.TurfReplace)
										for(var/turf/t in view(Rounds, src.Owner))
											if(t in view(Rounds, src.Owner))
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
											if(t in view(Rounds, src.Owner))
												continue
											sleep(-1)
											TurfShift(src.TurfShift,t, src.TurfShiftDuration,src.Owner, src.TurfShiftLayer, src.TurfShiftDurationSpawn, src.TurfShiftDurationDespawn, TurfShiftState,TurfShiftX, TurfShiftY)
									for(var/mob/m in view(Rounds, src.Owner))
										if(m in view(Rounds-1, src.Owner))//Don't doublehit people
											continue
										if(!hitSelf&&m==src.Owner)
											continue
										src.Damage(m)
								sleep(src.Slow*world.tick_lag)
							src.Owner.Frozen=0
						else
							if(src.DistanceMax>=3)//If greater than 3 distance...
								if(src.TurfErupt)
									for(var/turf/t in Turf_Circle_Edge(src.Owner, src.Distance))
										sleep(-1)
										Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4)
								if(src.TurfDirt)
									for(var/turf/t in Turf_Circle_Edge(src.Owner, src.Distance))
										sleep(-1)
										Dust(t)
								if(src.TurfStrike)
									for(var/turf/t in Turf_Circle_Edge(src.Owner, src.Distance))
										sleep(-1)
										spawn()
											for(var/s=src.TurfStrike, s>0, s--)
												if(Owner)
													src.Owner.HitEffect(t, src.UnarmedTech, src.SwordTech)
													sleep(1)
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
								for(var/turf/t in Turf_Circle(src.Owner, src.Distance))
									sleep(-1)
									for(var/mob/m in t)
										if(!hitSelf&&src.Owner!=m)
											src.Damage(m)
							else//If less than 3 distance...
								if(src.TurfErupt)
									for(var/turf/t in view(src.Distance, src.Owner))
										Bang(t, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4)
								if(src.TurfDirt)
									for(var/turf/t in view(src.Distance, src.Owner))
										Dust(t)
								if(src.TurfStrike)
									for(var/turf/t in view(src.Distance, src.Owner))
										spawn()
											for(var/s=src.TurfStrike, s>0, s--)
												if(Owner)
													src.Owner.HitEffect(t, src.UnarmedTech, src.SwordTech)
													sleep(1)
								if(src.Divide)
									for(var/turf/t in view(src.Distance, src.Owner))
										Destroy(t, 9001)
								if(src.TurfReplace)
									for(var/turf/t in view(src.Distance, src.Owner))
										var/image/i=image(icon=src.TurfReplace)
										t.overlays+=i
										if(src.Deluge)
											t.effects+=i
											t.Deluged=1
											t.timeToDeath=Deluge
											t.ownerOfEffect=Owner
											ticking_turfs+=t
								if(src.TurfShift)
									for(var/turf/t in view(src.Distance, src.Owner))
										sleep(-1)
										TurfShift(src.TurfShift,t, src.TurfShiftDuration,src.Owner, src.TurfShiftLayer, src.TurfShiftDurationSpawn, src.TurfShiftDurationDespawn, TurfShiftState,TurfShiftX, TurfShiftY)
								for(var/mob/m in view(src.Distance, src.Owner))
									if(!hitSelf&&src.Owner!=m)
										src.Damage(m)
						goto Kill
				if(src.Target)
					if(src.Slow)
						src.Owner.Frozen=1
						sleep(src.Slow*world.tick_lag)
						src.Damage(src.Owner.Target)
						src.Owner.Frozen=0
					else
						src.Damage(src.Target)
					goto Kill
				while(src.Distance>0)
					if(src.Cardinal)
						if(!src.CardinalTriggered)
							new/obj/AutoHitter/CrossOffshoot(src, 1)//Left
							new/obj/AutoHitter/CrossOffshoot(src, 2)//Back
							new/obj/AutoHitter/CrossOffshoot(src, 0)//Right
							src.CardinalTriggered=1
					step(src, src.dir)
					if(src.StepsDamage&&src.StepsTaken>=1)
						src.Damage+=src.StepsDamage//add growing damage
					src.Distance--
					src.StepsTaken++
					if(src.TurfErupt)
						Bang(src.loc, Size=src.TurfErupt, Offset=src.TurfEruptOffset, Vanish=4)
					if(src.TurfDirt)
						Dust(src.loc)
					if(src.TurfStrike)
						spawn()
							for(var/s=src.TurfStrike, s>0, s--)
								if(!src.Owner)
									break
								src.Owner.HitEffect(src.loc, src.UnarmedTech, src.SwordTech)
								sleep(1)
							if(!Owner)
								break
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
				src.StrDmg=AH.StrDmg
				src.ForDmg=AH.ForDmg
				src.EndRes=AH.EndRes
				src.Knockback=AH.Knockback
				src.ChargeTech=AH.ChargeTech
				src.UnarmedTech=AH.UnarmedTech
				src.SwordTech=AH.SwordTech
//				src.Electrifying=AH.Electrifying
				src.Deluge=AH.Deluge
				src.Stunner=AH.Stunner
				src.Destructive=AH.Destructive
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
				src.StrDmg=AH.StrDmg
				src.ForDmg=AH.ForDmg
				src.EndRes=AH.EndRes
				src.Knockback=AH.Knockback
				src.ChargeTech=AH.ChargeTech
				src.UnarmedTech=AH.UnarmedTech
				src.SwordTech=AH.SwordTech
				src.Deluge=AH.Deluge
				src.Stunner=AH.Stunner
				src.Destructive=AH.Destructive
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
				src.StepsDamage=AH.StepsDamage
				src.StrDmg=AH.StrDmg
				src.ForDmg=AH.ForDmg
				src.EndRes=AH.EndRes
				src.Knockback=AH.Knockback
				src.ChargeTech=AH.ChargeTech
				src.UnarmedTech=AH.UnarmedTech
				src.SwordTech=AH.SwordTech
				src.Stunner=AH.Stunner
				src.Deluge=AH.Deluge
				src.Destructive=AH.Destructive
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