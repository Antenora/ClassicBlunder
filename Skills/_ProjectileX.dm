

obj
	Skills
		var/NewCost // we will do this the hard way.
		var/NewCopyable // sigh
		Projectile
			proc
				EdgeOfMapProjectile()
					var/turf/t=get_step(src, src.dir)
					if(!t)
						return 1
					if(t.x==0||t.y==0||t.z==0)
						return 1
					if(t)
						if(istype(t, /turf/Special/Blank))
							return 1
					return 0
			adjust(mob/p)
			proc/Trigger(mob/p, Override = 0)
				adjust(p)
				if(Using || cooldown_remaining)
					return FALSE
				var/aaa = p.UseProjectile(src)
				return aaa
			layer=EFFECTS_LAYER
			Distance=10
			Cooldown=0.5
			Speed=0.5
			pixel_x=0
			pixel_y=0
			var
				CorruptionGain

				FoxFire
				while_warping = FALSE
				DistanceMax//This will keep the largest possible distance
				DistanceVariance=0//if you want the things to sometimes blow up early
				Area="Blast"//What type of projectile?  Blast...
				FlickBlast=1
				ProjSize//Area of the projectile
				Radius=0//hits everything in a range...
				Homing
				HyperHoming//With this, it won't count dense objects that aren't its target as things to explode on
				HomingCharge
				HomingChargeSpent
				HomingDelay=3
				LosesHoming
				Static

				UnarmedOnly
				StaffOnly
				StanceNeeded
				ABuffNeeded
				SBuffNeeded
				GateNeeded

				//AllOutAttack//Don't care about the drain, FINISHING MOVE...
				//HealthCost
				//WoundCost
				//EnergyCost
				//FatigueCost
				//ManaCost
				//CapacityCost
				MaimCost//Add this number of maims when completed.
				//MaimStrike// if Damage exceeds 25 / this number, maim the target

				DamageMult=1
				AccMult=1
				Deflectable=1//what do u think?
				Dodgeable=1//will replace instinct definition, since it's specific for projectiles
				Knockback//KB this many tiles on hit
				MiniDivide=0
				Divide=0
				Trail//does it leave a trail of any kind while moving?
				TrailX=0
				TrailY=0
				TrailDuration=5
				TrailSize=1
				TrailVariance=0
				Explode=0//again, what do u think?
				ExplodeIcon //set this and explode icon changes.
				Striking=0//Normal hitspark
				Slashing=0//Slash hitspark
				Charge
				tmp/Charging//Used to keep track of which beam you're using
				ChargeRate=1//How much faster a certain beam charges
				BeamTime=1200//If you want the beam to have a limited duration, used this.  0 means unlimited
				BeamTimeUsed//keeps track of how long you've used it for.
				Immediate//no charge beams
				ChainBeam//back and forth
				//IconChargeOverhead
				FadeOut=0 //makes the projectile fade out at x tiles to its end
				StrRate=0
				ForRate=1

				EndRate=1

				//icon
				//pixel x
				//pixel y
				IconLock='Blast - Basic.dmi'
				LockX=0
				LockY=0
				IconSize=1//Makes icons larger.
				IconSizeGrowTo=0//Icon size will slowly grow to this value
				IconVariance//modfies how the icon appears on generation of projectile
				Variation=8//pixelx/y offsets randomly
				Deviation//unlike variation, this actually affects where the projectile generates

				Blasts=1//Multiple blasts happen at once.
				BlastsShot=0//only used for continuous
				Delay=1//Amount of time between blasts.
				Stream//A series of blasts, which will be used as a beam.
				Continuous//Is the attack a continuous effect?
				ContinuousOn//Have you started the attack?
				MultiShot=0//Can be fired multiple times before going on CD.
				MultiShots=0//How many times have been fired.

				MultiHit//Single projectile hits multiple times.
				MaxMultiHit//just used to keep track of if a technique has hit yet

				//Homing Finisher, Hellzone Grenade, Checkmate, etc
				ZoneAttack//Use this to tell the computer to make it a zone attack.
				ZoneAttackX=10//How wide the area that a projectile can be created is, in both directions from the user.
				ZoneAttackY=10//How tall the area that a projectile can be created is, in both directions from the user.
				Hover//Make projectiles hover for this value before converging.
				FireFromEnemy=1//With this, the zone will be centered on the enemy you're targeting.
				FireFromSelf=0//With this, the zone will be centered on you.
				StormFall//Only go down.
				Piercing//passthrough
				PiercingBang//explode when it passes through. purely visual
				AttackReplace//triggers on melee attack facing nothing
				Cluster//I'M
				ClusterBit=0
				ClusterCount//BEING
				ClusterAdjust=1//[slightly]
				ClusterDelay//CRAY
				RandomPath//yolo directions
				Devour//eat other shit
				Stasis//icicle
				Feint//zoom!
				MortalBlow
				WarpUser//distinct from feint because this only warps if the projectile connects @___@
				CounterShot//if you're bopped when charging, this will make the technique fire first

				Buster=0//if its a buster type technique, this determines the charge rate
				BusterDamage//this determines the max damage from charging
				BusterHits//this determines the max multihit from charging
				BusterRadius//if the charge is max, this is used as radius
				BusterAccuracy//this determines the max acc from charging
				BusterSize//if the charge is max, this size is used instead
				BusterStream//if the charge is max, this stream is used instead

				//these are used if theyre initialized
				TempDamage
				TempHits
				TempRadius
				TempAccuracy
				TempSize
				TempStream

				//Instinct//Ignore AIS/WS
				Instant//Fire all projectiles at once

				ChargeMessage//A message to display while charging
				ChargeIcon
				ChargeIconUnder=0
				ChargeIconX=0
				ChargeIconY=0
				ChargeColor=rgb(255, 153, 51)
				TurfShift//shit that occurs on chargeup

				TurfShiftEnd //Turf Shift that occurs when the projectile ends
				TurfShiftEndSize //Circular size.

				ActiveMessage//A message to display when fired
				ActiveColor=rgb(255,0,0)

				GoldScatter
				Snaring
			skillDescription()
				..()
				if(MaimCost)
					description += "MaimCost: [MaimCost]\n"
				if(StrRate)
					description += "Strength Damage %: [StrRate*100]\n"
				if(ForRate)
					description += "Force Damage %: [ForRate*100]\n"
				if(EndRate<1)
					description += "Endurance Ignoring: [1-EndRate]%\n"
				if(Blasts)
					description += "Fires [Blasts] blast(s).\n"
				if(MultiShot)
					description += "Can be fired [MultiShot] times in a row.\n"
				if(MultiHit)
					description += "Will hit [MultiHit] times in a row if it can.\n"
				if(ZoneAttack)
					description += "Will fire blasts to hover in a [ZoneAttackX]x[ZoneAttackY] area.\n"
				if(Buster)
					description += "Charges up before firing: At max: [BusterDamage] damage. [BusterHits] hits. [BusterRadius] radius. [BusterAccuracy] accuracy. [BusterSize] size. [BusterStream] blasts.\n"
//Autoblasts
			Comet_Spear
				Distance=15
				DamageMult = 2
				EndRate = 1
				Dodgeable=-1
				AccMult = 5
				Speed=1
				Cooldown=4
				IconLock='Caladbolg.dmi'
				IconSize=1
				LockX=-36
				LockY=-36
				Variation=0
				ZoneAttack=1
				ZoneAttackX=2
				ZoneAttackY=2
				Homing=1
				HyperHoming=1
				Radius=1
				Variation=0
				Hover=1
				ActiveMessage="tosses their spear!"



			Oni_Giri
				AttackReplace=1
				Blasts=3
				IconLock='Air Render.dmi'
				DamageMult=0.5
				StrRate=1
				ForRate=0
				MultiHit=3
				Knockback=0.05
				KBMult
				AccMult = 1.175
				Distance=30
				IconSize=1.5
				Variation=8
				ZoneAttack=1
				ZoneAttackX=1
				ZoneAttackY=1
				FireFromSelf=1
				FireFromEnemy=0
				Radius=1
			Devil_Divide
				AttackReplace=1
				Blasts=1
				IconLock='BLANK.dmi'
				Radius=2
				Distance=50
				StrRate=1
				ForRate=0
				Charge=1
				DamageMult=0.75
				MultiHit=10
				HyperHoming=1
				AccMult = 1.25
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
			Hadoken_Effect
				AttackReplace=1
				Blasts=1
				IconLock='Hadoken.dmi'
				IconSize=3
				Radius=2
				Speed=0.5
				Distance=50
				AdaptRate=1
				DamageMult=1.8
				Knockback=2
				MultiHit=10
				HyperHoming=1
				AccMult = 1.25
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
				Instinct=1
////General
			DancingBlast
				AttackReplace=1
				Blasts=1
				HomingCharge=1
				RandomPath=1
				IconLock='Dancing.dmi'
				DamageMult=0.25
				AccMult=0.75
				Distance=30
				IconSize=0.5
				Variation=8
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
			Fire_Storm
				AttackReplace=1
				Blasts=1
				HomingCharge=1
				RandomPath=1
				IconLock='FireBlast.dmi'
				DamageMult=0.33
				AdaptRate=1.5
				Scorching=2
				AccMult = 1.175
				Distance=30
				IconSize=0.5
				Variation=8
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
			Phoenix_Flares
				Blasts=10
				HomingCharge=1
				RandomPath=1
				IconLock='FireBlast.dmi'
				DamageMult=0.5
				StrRate=0.5
				ForRate=0.5
				Scorching=2
				AccMult=0.75
				Distance=30
				IconSize=0.5
				Variation=8
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=0
				FireFromEnemy=1
			DancingBlast2
			RushBlast
				AttackReplace=1
				Blasts=1
				Speed=1
				Instinct=1
				Distance=10
				DamageMult=0.3
				Radius=1
				Piercing=1
				AdaptRate=1
				AccMult=30
				Knockback=3
				Explode=1
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
				Dodgeable=0
				Deflectable=0
				IconLock='Lightning.dmi'
				Variation=0
				GrowingLife=1
				IconSizeGrowTo=2
			BurstBlast
				AttackReplace=1
				Blasts=1
				Distance=7
				DamageMult=0.25
				AdaptRate=1
				AccMult=30
				Dodgeable=0
				Speed=0
				Knockback=0
				Deflectable=0
				Piercing=1
				IconLock='BLANK.dmi'
				Trail='Trail - Death.dmi'
				TrailSize=1.4
				Variation=4
			Thundara
				Copyable=0
				ZoneAttack=1
				Distance=16
				Blasts=1
				Charge=1
				DamageMult=0.2
				AccMult=1.5
				ForRate=1
				Homing=1
				Explode=1
				ZoneAttackX=8
				ZoneAttackY=8
				Deflectable = 1
				ForRate=1
				Hover=5
				IconLock='lighting_proj.dmi'
				LockX=-12
				LockY=-12
				IconSize=0.5
				Variation=8
				Cooldown=15
				adjust(mob/p)
					DamageMult = 0.05 + p.getTotalMagicLevel()/150 + p.Potential/200
					Blasts = clamp(p.getTotalMagicLevel() + p.Potential/25, 3, 15)


			Blizzara
				Distance=8
				AccMult=1.3
				DamageMult=0.1
				Blasts=10
				Delay=0.25
				Speed = 2
				Stream=-1
				Cooldown=15
				Deflectable = 1
				Homing=1
				LosesHoming=3
				IconLock='SnowBurst2.dmi'
				IconSize=0.7
				Variation=64
				adjust(mob/p)
					DamageMult = 2 + p.getTotalMagicLevel()/10 + p.Potential/25
					Blasts = 10 + clamp(p.getTotalMagicLevel() + p.Potential/10, 5, 30)
					DamageMult/=Blasts

			Kick_Blast
				Copyable=0
				Distance=12
				DamageMult=0.5
				AccMult = 1.25
				Radius=1
				Homing=1
				HomingCharge=3
				HomingDelay=1
				FireFromSelf=1
				FireFromEnemy=0
				MultiHit=2
				Knockback=0
				Cooldown=15
				IconSize=1
				Variation=0
				IconLock='Air Render.dmi'
				adjust(mob/p)
					DamageMult = 0.3 + p.Potential /100
					Blasts = 1 + (round(p.Potential / 25))



			Murder_Music
				AttackReplace=1
				ZoneAttack=1
				Distance=30
				StrRate=1
				ForRate=1
				Crippling=0.5
				Blasts=5
				DamageMult=0.5
				HyperHoming=1
				AccMult=2
				Homing=1
				HomingCharge=3
				HomingDelay=1
				Striking=1
				Instinct=1
				ZoneAttackX=5
				ZoneAttackY=5
				FireFromEnemy=0
				FireFromSelf=1
				Hover=5
				IconLock='CheckmateKnives.dmi'
				Variation=8
				FlickBlast=0
				Cooldown=4
			Warsong
				AttackReplace=1
				Distance=30
				StrRate=1
				ForRate=1
				Crippling=1
				Blasts=1
				DamageMult=0.75
				HyperHoming=1
				AccMult=2
				Homing=1
				HomingCharge=1
				HomingDelay=5
				Piercing=1
				Striking=1
				Instinct=1
				IconLock='Arrow - Flare.dmi'
				IconSize=1
				Trail='Trail - Flare.dmi'
				TrailSize=1
				Variation=4
				FlickBlast=0
			Warsong_Finale
				Distance=50
				ZoneAttack=1
				ZoneAttackX=10
				ZoneAttackY=10
				FireFromSelf=0
				FireFromEnemy=1
				Hover=10
				StrRate=1
				ForRate=1
				Blasts=20
				DamageMult=0.5
				HyperHoming=1
				AccMult = 1.25
				Homing=1
				HomingCharge=3
				HomingDelay=5
				Piercing=1
				Striking=1
				Instinct=1
				IconLock='Arrow - Flare.dmi'
				IconSize=1
				Trail='Trail - Flare.dmi'
				TrailSize=1
				Variation=4
				FlickBlast=0
			East_Gust
				IconLock='Boosting Winds.dmi'
				IconSize=2
				Dodgeable=-1
				Radius=1
				Striking=1
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
				Variation=0
				StrRate=1
				ForRate=1
				EndRate=1
				Knockback=1
				MultiHit=5
				DamageMult=0.5
				AccMult = 1.25
				Deflectable=0
				Distance=10
				Instinct=2
			Hundred_Knives
			Senbon
			Cluster_Bits
				ClusterBit=1
				Distance=30
				Radius=0
				DamageMult=1
				RandomPath=1
				HomingCharge=1
				HyperHoming=1
				AccMult=1
				Explode=1
				Variation=0
				IconLock='Blast - Basic.dmi'
			Kienzan_Bits
				ClusterBit=1
				Distance=50
				DamageMult=5
				Deflectable=0
				IconLock='Kienzan.dmi'
				LockX=0
				LockY=0
				RandomPath=1
				HomingCharge=1
				LosesHoming=10
				Slashing=1
				Piercing=1
				Variation=0
				MaimStrike=1.25//If damage > 20%, maim target
			Chemical_Bits
				ClusterBit=1
				Distance=10
				DamageMult=1
				Speed=2
				Deflectable=0
				IconLock='PoisonGas.dmi'
				LockX=-16
				LockY=-16
				IconSize=1.5
				IconVariance=4
				RandomPath=2
				Piercing=1
				HomingCharge=1
				LosesHoming=3
				Variation=0
				Toxic=1

////Keyblade
			Wisdom_Form_Blast
				Radius=0
				DamageMult=1
				AttackReplace=1
				AccMult=1
				Blasts=5
				IconLock='Dancing.dmi'
				Variation=6
				Cooldown = 2
				//No verb because it is created manually.
			Rock_Bits
				Distance=30
				Radius=0
				DamageMult=1
				ZoneAttack=1
				ZoneAttackX=3
				ZoneAttackY=3
				FireFromSelf=0
				FireFromEnemy=1
				HomingCharge=1
				HyperHoming=1
				Speed=2
				AccMult = 1.175
				IconLock='Boulder Normal.dmi'
				IconSize=0.25
				LockX=-36
				LockY=-36
				Variation=8
				Striking=1
				StrRate=1
				ForRate=0
////Magic Shit
			Aether_Arrow
				Radius=0
				DamageMult=1
				AccMult=1
				StrRate=0.5
				ForRate=0.5
				EndRate=1
				Distance=30
				AttackReplace=1
				Striking=1
				Blasts=5
				IconLock='Arrow - Spirit.dmi'
				Variation=48
				Radius=1
				Cooldown = 2
			Sagittarius_Arrow
				DamageMult=1
				AccMult=1
				StrRate=0.5
				ForRate=0.5
				EndRate=1
				Distance=30
				AttackReplace=1
				Striking=1
				Blasts=5
				IconLock='LightImpulse.dmi'
				LockX=-32
				LockY=-32
				Trail='LightImpulseTrail.dmi'
				TrailDuration=1
				TrailSize=0.75
				Cooldown = 2
			Staff_Projectile
				Radius=0
				DamageMult=1
				AccMult=1
				ForRate=1
				EndRate=1
				Distance=30
				AttackReplace=1
				Striking=1
				Blasts=2
				IconLock='Blast - Small.dmi'
				Variation=48
				Radius=1
				Cooldown = 4
			Fenrir
				NoTransplant=1
				Cooldown=60
				Distance=100
				DamageMult=0.2
				Blasts=40
				Dodgeable=-1
				Stunner=1
				Knockback=1
				Delay=0.5
				IconLock='Blast - Rapid.dmi'
				IconSize=0.5
				Variation=8
				Striking=1
				Charge=1
				ChargeMessage="invokes Bolverk's Zero Gun form: Fenrir!"
				verb/Fenrir()
					set category="Skills"
					set name="Zero Gun: Fenrir"
					usr.UseProjectile(src)
			Thor
				NoTransplant=1
				Cooldown=150
				Distance=150
				DamageMult=5.5
				Blasts=1
				Radius=1
				Dodgeable=0
				Homing=1
				LosesHoming=3
				Variation=0
				Knockback=10
				Explode=3
				IconLock='MissileSmall.dmi'
				IconSize=2
				Charge=1
				ChargeMessage="invokes Bolverk's Zero Gun form: Thor!"
				verb/Thor()
					set category="Skills"
					set name="Zero Gun: Thor"
					usr.UseProjectile(src)
////Cybernetics
			Machine_Gun_Burst
				DamageMult=0.55
				Radius=1
				AttackReplace=1
				AccMult=1
				Blasts=10
				IconLock='BlastTracer.dmi'
				Variation=48
			Homing_Ray_Missiles
				AttackReplace=1
				Variation=8
				RandomPath=1
				Delay=0
				Distance=40
				Explode=2
				DamageMult=3.5
				AccMult=1
				Blasts=2
				LosesHoming=3
				HomingCharge=1
				IconLock='MissileSmall.dmi'
				IconSize=2
			Plasma_Cannon
				AttackReplace=1
				Radius=1
				Distance=50
				DamageMult=4
				AccMult = 1.15
				Speed=0
				Piercing=1
				Variation=0
				Trail='TrailFire.dmi'
				TrailSize=2
			Cyberize
				Rocket_Punch
					Distance=10
					DamageMult=9
					AccMult = 1.25
					Knockback=5
					Deflectable=1
					StrRate=1
					ForRate=1
					EndRate=1
					Homing=1
					Explode=2
					IconLock='RocketPunch.dmi'
					IconSize=0.3
					Variation=0
					Cooldown=120
					ManaCost=5
					verb/Rocket_Punch()
						set category="Skills"
						usr.UseProjectile(src)
			Gear
				Plasma_Blaster
					DamageMult=1
					StrRate=0.5
					ForRate=0.5
					EndRate=1
					Distance=20
					Knockback=2
					IconLock='Blast - Charged.dmi'
					LockX=-12
					LockY=-12
					IconSize=0.3
					Variation=0
					Cooldown=5
					verb/Plasma_Blaster()
						set category="Skills"
						usr.UseProjectile(src)
				Plasma_Rifle
					Variation=8
					IconLock='BlastTracer.dmi'
					Blasts=5
					Distance=30
					DamageMult=0.15
					AdaptRate=1
					EndRate=1
					AccMult=0.33
					Paralyzing=0.2
					Homing=1
					LosesHoming=3
					MultiShot=3
					Cooldown=5
					verb/Plasma_Rifle()
						set category="Skills"
						usr.UseProjectile(src)
				Plasma_Gatling
					Continuous=1
					Charge=1.5
					Variation=8
					IconLock='BlastTracer.dmi'
					Distance=30
					DamageMult=0.2
					AdaptRate=1
					EndRate=1
					AccMult=0.2
					Paralyzing=0.3
					Blasts=30
					Cooldown=60
					ChargeMessage="revs up their Plasma Gatling!!"
					verb/Plasma_Gatling()
						set category="Skills"
						usr.UseProjectile(src)
				Missile_Launcher
					ZoneAttack=1
					ZoneAttackX=2
					ZoneAttackY=2
					FireFromSelf=1
					FireFromEnemy=0
					RandomPath=1
					Delay=1
					Distance=40
					Explode=1
					DamageMult=0.35
					StrRate=0.5
					ForRate=0.5
					EndRate=1
					AccMult=2
					Blasts=20
					LosesHoming=3
					HomingCharge=10
					IconLock='MissileSmall.dmi'
					IconSize=0.9
					Variation=8
					Cooldown=60
					verb/Missile_Launcher()
						set category="Skills"
						usr.UseProjectile(src)
				Chemical_Mortar
					Variation=0
					Cooldown=60
					Distance=200
					Explode=3
					DamageMult=4.5
					StrRate=0.5
					ForRate=0.5
					EndRate=1
					AccMult = 1.15
					LosesHoming=3
					HomingCharge=10
					IconLock='MissileSmall.dmi'
					IconSize=1.5
					Cluster=new/obj/Skills/Projectile/Chemical_Bits
					ClusterCount=4
					ClusterAdjust=0
					Toxic=4
					verb/Chemical_Mortar()
						set category="Skills"
						usr.UseProjectile(src)
				Integrated
					Integrated=1
					Integrated_Plasma_Blaster
						DamageMult=1
						StrRate=0.5
						ForRate=0.5
						EndRate=1
						Distance=20
						Knockback=2
						IconLock='Blast - Charged.dmi'
						LockX=-12
						LockY=-12
						IconSize=0.3
						Variation=0
						Cooldown=5
						verb/Plasma_Blaster()
							set category="Skills"
							usr.UseProjectile(src)
					Integrated_Plasma_Rifle
						Variation=8
						IconLock='BlastTracer.dmi'
						Blasts=5
						Distance=30
						DamageMult=0.3
						AdaptRate=1
						EndRate=1
						AccMult=0.2
						Paralyzing=0.2
						Homing=1
						LosesHoming=3
						MultiShot=3
						Cooldown=5
						verb/Plasma_Rifle()
							set category="Skills"
							usr.UseProjectile(src)
					Integrated_Plasma_Gatling
						Continuous=1
						Charge=1.5
						Delay=0.5
						Variation=8
						IconLock='BlastTracer.dmi'
						DamageMult=0.2
						AdaptRate=1
						EndRate=1
						AccMult=0.3
						Paralyzing=0.2
						Cooldown=60
						Blasts=30
						ChargeMessage="revs up their Plasma Gatling!!"
						verb/Plasma_Gatling()
							set category="Skills"
							usr.UseProjectile(src)
					Integrated_Missile_Launcher
						Variation=8
						Cooldown=60
						ZoneAttack=1
						ZoneAttackX=2
						ZoneAttackY=2
						FireFromSelf=1
						FireFromEnemy=0
						RandomPath=1
						Delay=1
						Distance=40
						Explode=1
						DamageMult=0.35
						StrRate=0.5
						ForRate=0.5
						EndRate=1
						AccMult=2
						Blasts=20
						LosesHoming=3
						HomingCharge=10
						IconLock='MissileSmall.dmi'
						IconSize=0.9
						verb/Missile_Launcher()
							set category="Skills"
							usr.UseProjectile(src)
					Integrated_Chemical_Mortar
						Variation=0
						Cooldown=60
						Distance=200
						Explode=3
						DamageMult=4.5
						StrRate=0.5
						ForRate=0.5
						EndRate=1
						AccMult = 1.15
						LosesHoming=3
						HomingCharge=10
						IconLock='MissileSmall.dmi'
						IconSize=1.5
						Cluster=new/obj/Skills/Projectile/Chemical_Bits
						ClusterCount=4
						ClusterAdjust=0
						Toxic=4
						verb/Chemical_Mortar()
							set category="Skills"
							usr.UseProjectile(src)
				Installed
					Giga_Laser
						ManaCost=15
						Charge = 1.5
						Delay = 0.5
						Distance = 40
						Explode = 1
						DamageMult = 6.5
						StrRate = 0.25
						ForRate = 0.75
						EndRate = 0.65
						AccMult = 1.5
						Cooldown = 120
						IconLock='BlastTracer.dmi'
						HomingCharge = 10
						LosesHoming = 3
						verb/Giga_Laser()
							set category="Mecha"
							usr.UseProjectile(src)

					Missle_Onslaught
						ManaCost=3
						Variation=8
						Cooldown=30
						ZoneAttack=1
						ZoneAttackX=5
						ZoneAttackY=5
						FireFromSelf=1
						FireFromEnemy=0
						RandomPath=1
						Speed = 1.25
						Distance=15
						Explode=1
						DamageMult=0.35
						StrRate=0.5
						ForRate=0.5
						EndRate=1
						AccMult=2
						Blasts=20
						Delay=0
						// LosesHoming=3
						// HomingCharge=10
						IconLock='MissileSmall.dmi'
						IconSize=0.85
						verb/Missile_Onslaught()
							set category="Mecha"
							usr.UseProjectile(src)
					Laser_Circus
						ManaCost=6
						Cooldown=45
						ZoneAttack=1
						ZoneAttackX=8
						ZoneAttackY=8
						FireFromEnemy=0
						FireFromSelf=1
						RandomPath=1
						Speed = 0.75
						Distance=30
						DamageMult=0.3
						StrRate=0.35
						ForRate=0.65
						EndRate=0.75
						AccMult = 1.15
						Blasts=25
						Delay=0
						IconLock='BlastTracer.dmi'
						IconSize=0.5
						verb/Laser_Circus()
							set category="Mecha"
							usr.UseProjectile(src)




					Installed_Plasma_Gatling
						ManaCost=5
						Continuous=1
						Charge=0.5
						Delay=0.5
						Variation=8
						IconLock='BlastTracer.dmi'
						DamageMult=0.2
						StrRate=0.5
						ForRate=0.5
						EndRate=1
						AccMult=0.75
						Paralyzing=0.2
						Cooldown=90
						Blasts=30
						ChargeMessage="revs up their Plasma Gatling!!"
						verb/Plasma_Gatling()
							set category="Mecha"
							usr.UseProjectile(src)
					Installed_Missile_Launcher
						ManaCost=10
						Variation=8
						Cooldown=60
						ZoneAttack=1
						ZoneAttackX=2
						ZoneAttackY=2
						FireFromSelf=1
						FireFromEnemy=0
						RandomPath=1
						Delay=1
						Distance=40
						Explode=1
						DamageMult=0.35
						StrRate=0.5
						ForRate=0.5
						EndRate=1
						AccMult=2
						Blasts=20
						LosesHoming=3
						HomingCharge=10
						IconLock='MissileSmall.dmi'
						IconSize=0.9
						verb/Missile_Launcher()
							set category="Mecha"
							usr.UseProjectile(src)


//Skill Tree

////UNIVERSAL
//T1 has damage mult 1.5 - 2.5
			Blast
				SkillCost=40
				Copyable=1
				Distance=15
				DamageMult=0.5
				AccMult=2
				MultiShot=3
				EnergyCost=1
				Homing=1
				LosesHoming=3
				IconLock='Blast - Basic.dmi'
				Cooldown=30
				verb/Blast()
					set category="Skills"
					usr.UseProjectile(src)
			Rapid_Barrage
				NewCost = TIER_3_COST
				NewCopyable = 4
				SkillCost=40
				Copyable=2
				Distance=20
				AccMult=0.7
				DamageMult=0.3
				Blasts=25
				Delay=0.75
				Stream=-1
				EnergyCost=8
				Cooldown=90
				Deflectable = 1
				Homing=1
				LosesHoming=3
				IconLock='Blast - Rapid.dmi'
				IconSize=0.7
				Variation=16
				verb/Rapid_Barrage()
					set category="Skills"
					usr.UseProjectile(src)
			Straight_Siege
				NewCost = TIER_2_COST
				NewCopyable = 3
				SkillCost=40
				Copyable=2
				Distance=15
				AccMult=0.75
				DamageMult=0.2
				Speed = 0.75
				Knockback=0
				Blasts=23
				Continuous=1
				EnergyCost=7
				IconLock='Blast - Small.dmi'
				Cooldown=60
				Variation=24
				verb/Straight_Siege()
					set category="Skills"
					usr.UseProjectile(src)
			Flare_Wave
				SkillCost=TIER_1_COST
				Copyable=2
				Distance=25
				DamageMult=1.25
				Knockback=3
				Radius=2
				Homing=4
				LosesHoming=2
				MultiShot=3
				EnergyCost=3
				IconLock='Excaliblast.dmi'
				LockX=-50
				LockY=-50
				IconSize=0.5
				Cooldown=30
				Variation=0
				verb/Flare_Wave()
					set category="Skills"
					usr.UseProjectile(src)
			Death_Beam
				SkillCost=TIER_1_COST
				Copyable=2
				Distance=20
				DamageMult=4
				AccMult=2
				Crippling=3
				Speed=0
				Knockback=0.001
				Deflectable=1
				IconLock='DeathBeam.dmi'
				IconSize=1
				Trail='Trail - Death.dmi'
				TrailSize=1
				Cooldown=30
				EnergyCost=1
				Variation=4
				verb/Death_Beam()
					set category="Skills"
					usr.UseProjectile(src)

			Charge
				SkillCost=40
				Copyable=1
				Distance=30
				DamageMult=3
				AccMult = 1.15
				Homing=1
				Explode=1
				LosesHoming=3
				Charge=0.25
				EnergyCost=4
				Cooldown=30
				IconLock='Blast - Charged.dmi'
				LockX=-12
				LockY=-12
				IconSize=0.7
				Variation=0
				verb/Charge()
					set category="Skills"
					usr.UseProjectile(src)
			Spirit_Ball
				NewCost = TIER_3_COST
				NewCopyable = 4
				SkillCost=40
				Copyable=2
				Distance=30
				DamageMult=2
				Blasts=3
				AccMult=2
				Launcher=4
				Piercing=1
				Striking=1
				Homing=1
				HomingCharge=1
				HomingDelay=0.5
				EnergyCost=8
				Delay=3
				Speed=1
				IconChargeOverhead=1
				Explode=1
				Cooldown=90
				IconLock='Plasma2.dmi'
				Variation=0
				verb/Spirit_Ball()
					set category="Skills"
					usr.UseProjectile(src)
			Crash_Burst
				NewCost = TIER_3_COST
				NewCopyable = 4
				SkillCost=40
				Copyable=2
				ZoneAttack=1
				EnergyCost=8
				Distance=20
				Blasts=20
				Charge=1
				DamageMult=0.15
				AccMult=0.8
				Homing=1
				Explode=1
				ZoneAttackX=5
				ZoneAttackY=5
				Deflectable = 1
				Hover=10
				IconLock='Blast - Charged.dmi'
				LockX=-12
				LockY=-12
				IconSize=0.75
				Variation=4
				Cooldown=90
				verb/Crash_Burst()
					set category="Skills"
					usr.UseProjectile(src)
			Dragon_Nova
				SkillCost=TIER_1_COST
				Copyable=2
				Distance=50
				DamageMult=1
				MultiHit=3
				AccMult=25
				Radius=2
				Charge=0.5
				Knockback=1
				Explode=2
				EnergyCost=3
				Cooldown=30
				IconLock='Supernova.dmi'
				LockX=-158
				LockY=-169
				IconChargeOverhead=1
				IconSize=0.01
				IconSizeGrowTo=0.2
				Variation=0
				verb/Dragon_Nova()
					set category="Skills"
					usr.UseProjectile(src)
			Kienzan
				SkillCost=TIER_1_COST
				Copyable=2
				Distance=50
				DamageMult=1.5 // this shit ass, if u land it u deserve to do damage
				EnergyCost=5
				Deflectable=0
				Charge=0.5
				IconChargeOverhead=1
				IconLock='Kienzan.dmi'
				LockX=0
				LockY=0
				IconSize=0.1
				IconSizeGrowTo=2
				Cooldown=30
				Slashing=1
				Piercing=1
				Variation=0
				MortalBlow=0.25//If damage > 12.5%, maim
				verb/Kienzan()
					set category="Skills"
					usr.UseProjectile(src)
			Sudden_Storm
				NewCost = TIER_3_COST
				NewCopyable = 4
				SkillCost=90
				Copyable=3
				Blasts=10
				HomingCharge=1
				RandomPath=1
				IconLock='Dancing.dmi'
				DamageMult=0.55
				AccMult = 1.15
				Distance=25
				IconSize=0.5
				Variation=8
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				HyperHoming=1
				FireFromSelf=1
				FireFromEnemy=0
				Cooldown=90
				EnergyCost=5
				verb/Sudden_Storm()
					set category="Skills"
					usr.UseProjectile(src)
			Warp_Strike
				NewCost = TIER_1_COST
				NewCopyable = 2
				SkillCost=TIER_1_COST
				Copyable=3
				Charge=0.5
				HomingCharge=2
				IconLock='Blast2.dmi'
				Variation=4
				Distance=20
				Stunner=1.5
				Deflectable = FALSE
				DamageMult=1.25
				WarpUser=1
				FollowUp="/obj/Skills/AutoHit/Warp_Storm"
				FollowUpDelay=-1
				Cooldown=30
				EnergyCost=5
				verb/Warp_Strike()
					set category="Skills"
					usr.UseProjectile(src)
			Energy_Bomb
				SkillCost=80
				Copyable=2
				DamageMult=5
				Knockback=5
				Radius=1
				AccMult=50
				Deflectable=0
				Static=1
				Distance=100
				IconSize=1.5
				IconLock='Blast31.dmi'
				LockX=0
				LockY=0
				FireFromSelf=1
				FireFromEnemy=0
				Cooldown=60
				Explode=2
				EnergyCost=2.5
				verb/Energy_Bomb()
					set category="Skills"
					usr.UseProjectile(src)
			Energy_Minefield
				NewCost = TIER_1_COST
				NewCopyable = 2
				SkillCost=80
				Copyable=3
				Blasts=12
				DamageMult=0.33
				Radius=1
				AccMult=3
				Deflectable=0
				Static=1
				Distance=100
				IconLock='Blast31.dmi'
				LockX=0
				LockY=0
				ZoneAttack=1
				ZoneAttackX=8
				ZoneAttackY=8
				Hover=24
				FireFromSelf=0
				FireFromEnemy=1
				Cooldown=30
				Explode=1
				EnergyCost=6
				verb/Energy_Minefield()
					set category="Skills"
					if(!Using)
						FireFromEnemy = 0
						FireFromSelf = 1
						ZoneAttackX=4
						ZoneAttackY=4
					usr.UseProjectile(src)
				verb/Energy_Minefield_Target()
					set category="Skills"
					if(!Using)
						FireFromEnemy = 1
						FireFromSelf = 0
						ZoneAttackX=5
						ZoneAttackY=5
					usr.UseProjectile(src)
			Tracking_Bomb
				NewCost = TIER_3_COST
				NewCopyable = 4
				SkillCost=80
				Copyable=3
				DamageMult=6
				Knockback=5
				Radius=1
				AccMult=50
				Deflectable=0
				Speed=1.5
				RandomPath=2
				LosesHoming=9
				HomingCharge=100
				Distance=100
				IconLock='Blast31.dmi'
				LockX=0
				LockY=0
				IconChargeOverhead=1
				IconSize=3
				IconSizeGrowTo=1
				Cooldown=90
				Explode=3
				EnergyCost=5
				verb/Tracking_Bomb()
					set category="Skills"
					usr.UseProjectile(src)
			Stealth_Bomb
				SkillCost=TIER_2_COST
				Copyable=3
				DamageMult=6.5
				Knockback=3
				Radius=1
				AccMult=50
				Deflectable=0
				Speed=1
				Static=1
				Distance=100
				IconLock='BLANK.dmi'
				LockX=0
				LockY=0
				IconChargeOverhead=1
				IconSize=3
				IconSizeGrowTo=1
				Cooldown=60
				Explode=3
				EnergyCost=5
				verb/Stealth_Bomb()
					set category="Skills"
					usr.UseProjectile(src)
			Pillar_Bomb
				SkillCost=TIER_2_COST
				Copyable=3
				Launcher=3
				DamageMult=6.5
				Knockback=0
				AccMult=50
				Deflectable=0
				Static=1
				Radius=1
				Distance=100
				IconLock='Blast23.dmi'
				LockX=0
				LockY=0
				IconChargeOverhead=1
				IconSize=3
				IconSizeGrowTo=1
				Cooldown=60
				Explode=2
				EnergyCost=5
				verb/Pillar_Bomb()
					set category="Skills"
					usr.UseProjectile(src)

//T3 is further down, in Beams.

//T4 gets damage mult 4 - 6.
			SmallLemonThing //BIG SHOT mechanic coming sooner or later
				Buster=0//rate that blast charges
				DamageMult=1
				BusterDamage=0//max damage when fully charged
				MultiHit=3
				BusterRadius=1//max radius from charging
				AccMult=2.5
				BusterAccuracy=10
				BusterSize=2//purely aesthetic
				Knockback=0
			//	Explode=2
				EnergyCost=0.1
				Cooldown=120
				IconLock='Blast12.dmi'
				LockX=0
				LockY=0
				Variation=0
				verb/SmallLemonThing()
					set category="Skills"
					usr.UseProjectile(src)
			Power_Buster
				Copyable=4
				SkillCost=TIER_4_COST
				Buster=0//rate that blast charges
				DamageMult=4
				BusterDamage=0//max damage when fully charged
				MultiHit=3
				BusterRadius=1//max radius from charging
				AccMult=2.5
				BusterAccuracy=10
				BusterSize=2//purely aesthetic
				Knockback=1
				Explode=2
				EnergyCost=2.5
				Cooldown=120
				IconLock='Blast12.dmi'
				LockX=0
				LockY=0
				Variation=0
				verb/Power_Buster()
					set category="Skills"
					usr.UseProjectile(src)
			Burst_Buster
				Copyable=5
				SkillCost=TIER_4_COST
				Charge=0.2
				DamageMult=1
				AccMult=1.25
				Radius=1
				BusterRadius=2
				Stream=2
				BusterStream=3
				Blasts=10
				Explode=1
				EnergyCost=5
				Cooldown=120
				IconLock='Blast10.dmi'
				LockX=0
				LockY=0
				Variation=32
				verb/Burst_Buster()
					set category="Skills"
					usr.UseProjectile(src)
			Warp_Buster
				Copyable=5
				SkillCost=TIER_4_COST
				Charge=2
				Homing=1
				HyperHoming=1
				Knockback=1
				DamageMult=10
				MultiHit=1
				AccMult=2.5
				Explode=2
				EnergyCost=8
				Cooldown=120
				FollowUp="/obj/Skills/AutoHit/Warp_Bomb"
				FollowUpDelay=-1
				IconLock='Blast12.dmi'
				LockX=0
				LockY=0
				Variation=0
				Feint=1
				verb/Warp_Buster()
					set category="Skills"
					usr.UseProjectile(src)
			Scatter_Burst
				Copyable=5
				SkillCost=TIER_4_COST
				Blasts=12
				DamageMult=0.5
				AccMult=0.5
				Stream=4
				RandomPath=1
				IconLock='Dancing.dmi'
				FireFromSelf=1
				ZoneAttackX=8
				ZoneAttackY=8
				ZoneAttack=1
				LockX=0
				LockY=0
				Variation=16
				Cooldown=120
				verb/Scatter_Burst()
					set category="Skills"
					usr.UseProjectile(src)
			Counter_Buster
				Copyable=5
				SkillCost=TIER_4_COST
				Buster=0.5//rate that blast charges
				BusterDamage=1//max damage when fully charged
				BusterHits=10//multihits when fully charged
				BusterRadius=1//max radius from charging
				BusterAccuracy=10
				BusterSize=2//purely aesthetic
				Knockback=1
				DamageMult=2
				MultiHit=5
				Instinct=1
				AccMult=2.5
				Explode=2
				EnergyCost=2.5
				Cooldown=120
				IconLock='Blast28.dmi'
				LockX=0
				LockY=0
				Variation=0
				CounterShot=1//makes things fire when you're bopped
				verb/Counter_Buster()
					set category="Skills"
					usr.UseProjectile(src)

//T5 (Sig 1) has damage mult 5, usually.

			Cluster_Bomb
				Distance=5
				DamageMult=5
				AccMult = 1.15
				Charge=1
				EnergyCost=1
				Cooldown=30
				RandomPath=1
				Cluster=new/obj/Skills/Projectile/Cluster_Bits
				ClusterCount=5
				verb/Cluster_Bomb()
					set category="Skills"
					usr.UseProjectile(src)
			Buster_Barrage
				SignatureTechnique=1
				Distance=15
				AccMult=2
				DamageMult=0.5
				EnergyCost=15
				Cooldown=120
				Explode=1
				Homing=1
				Knockback=1
				Charge=1
				Delay=0.85
				IconLock='Blast - Rapid.dmi'
				Stream=-1
				Deflectable = 1
				Homing=1
				LosesHoming=3
				Blasts=23
				Continuous=1
				Variation=24
				verb/Buster_Barrage()
					set category="Skills"
					usr.UseProjectile(src)

			Makosen
				SignatureTechnique=1
				Distance=50
				DamageMult=12.5
				AccMult = 1.15
				Blasts=1
				EnergyCost=15
				Cooldown=60
				Radius=2
				Charge=2
				Explode=1
				Homing=1
				Knockback=1
				LosesHoming=0
				Speed=0.8
				Delay=1.45
				IconLock='Blast - Rapid.dmi'
				IconSize=3.4
				verb/Makosen()
					set category="Skills"
					usr.UseProjectile(src)
			Jecht_Shot
				SignatureTechnique=1

				StrRate=0.3
				ForRate=0.7
				EndRate=1
				Distance=15
				DamageMult=2
				Blasts=2
				AccMult = 1.15
				Homing=1
				HomingDelay=2
				HomingCharge=4
				EnergyCost=6
				Charge=1
				Piercing=1
				Dodgeable=1
				Deflectable=1
				Launcher=1
				MultiHit=4
				IconChargeOverhead=1
				Cooldown=150
				Variation=0
				verb/Jecht_Shot()
					set category="Skills"
					usr.UseProjectile(src)
			Death_Saucer
				SignatureTechnique=1
				Blasts=4
				Delay=2.25
				Speed=1.45
				Crippling=1
				Distance=50
				DamageMult=3.5
				EnergyCost=25
				Deflectable=0
				AccMult=0.75
				Homing=1
				HomingCharge=14
				LosesHoming=3
				Charge=2
				IconChargeOverhead=1
				IconLock='Saucer.dmi'
				LockX=0
				LockY=0
				IconSize=0.1
				IconSizeGrowTo=1.25
				Cooldown=150
				Slashing=1
				Piercing=0
				Variation=0
				Dodgeable=0
				verb/Death_Saucer()
					set category="Skills"
					usr.UseProjectile(src)
			Blaster_Shell
				SignatureTechnique=1
				Distance=25
				DamageMult= 4.5
				AccMult = 1.15
				Dodgeable=0
				Instinct=1
				MultiShot=3
				EnergyCost=1
				Knockback=1
				Homing=1
				IconLock='BlasterShell2.dmi'
				LockX=-12
				LockY=-12
				IconSize=0.6
				Variation=8
				Cooldown=150
				verb/Blaster_Shell()
					set category="Skills"
					usr.UseProjectile(src)
			Spirit_Gun
				SignatureTechnique=1
				Distance=50
				DamageMult=4.5
				AccMult=25
				Explode=3
				Knockback=1
				Radius=1
				Dodgeable=0
				Deflectable=0
				AllOutAttack=1
				Charge=0.25
				StrRate=1.2
				ForRate=1.2
				EndRate=1
				IconLock='SpiritGun2.dmi'
				LockX=-12
				LockY=-12
				Variation=0
				Cooldown=150
				verb/Spirit_Gun()
					set category="Skills"
					src.EnergyCost=usr.Energy
					FatigueCost=EnergyCost/5
					src.MultiHit=round(src.EnergyCost/10)
					src.DamageMult=round(4.5 + EnergyCost/10) / MultiHit
					usr.UseProjectile(src)

			Spirit_Gun_Mega
				PreRequisite=list("/obj/Skills/Projectile/Spirit_Gun")
				SignatureTechnique=2
				FatigueCost=80
				Distance=50
				DamageMult=6
				AccMult=25
				Explode=5
				Knockback=1
				Radius=2
				Dodgeable=0
				Deflectable=0
				AllOutAttack=1
				Charge=0.25
				StrRate=1
				ForRate=1
				EndRate=1
				IconLock='SpiritGun2.dmi'
				IconSize=2
				LockX=-12
				LockY=-12
				Variation=0
				Cooldown=180
				verb/Spirit_Gun_Mega()
					set category="Skills"
					src.MultiHit=round(FatigueCost/4)
					src.DamageMult=0.01+(FatigueCost/90)
					usr.UseProjectile(src)
			Sekiha_Tenkyoken
				SignatureTechnique=2
				Charge=1
				Distance=50
				DamageMult=1.6
				AccMult=30
				MultiHit=10
				Knockback=1
				StrRate=1
				ForRate=1
				EndRate=1
				Explode=2
				Radius=1
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
				Dodgeable=-1
				IconLock='SYO!.dmi'
				Trail='Hit Effect Ripple.dmi'
				TrailX=-32
				TrailY=-32
				Variation=0
				Cooldown=180
				Instinct=1
				EnergyCost=5
				verb/Sekiha_Tenkyoken()
					set category="Skills"
					usr.UseProjectile(src)
			Big_Bang_Attack
				SignatureTechnique=2
				Homing=1
				HyperHoming=1
				Charge=1.5
				Dodgeable=-1
				Distance=50
				DamageMult=1.5
				AccMult=30
				MultiHit=10
				Knockback=1
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
				Explode=3
				Variation=0
				IconLock='Plasma1.dmi'
				IconSize=0.5
				IconChargeOverhead=1/32
				IconSizeGrowTo=1.5
				Cooldown=180
				Instinct=2
				EnergyCost=10
				verb/Big_Bang_Attack()
					set category="Skills"
					usr.UseProjectile(src)
			Omega_Blaster
				SignatureTechnique=2
				Charge=1.5
				Distance=200
				GrowingLife=1
				IconSizeGrowTo=1
				IconSize=0.3
				IconLock='OmegaBlaster.dmi'
				LockX=-33
				LockY=-33
				Radius=1
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
				Dodgeable=-1
				Knockback=1
				DamageMult=1.6
				AccMult=30
				MultiHit=10
				Explode=5
				Variation=0
				Cooldown=180
				Instinct=2
				EnergyCost=10
				verb/Omega_Blaster()
					set category="Skills"
					usr.UseProjectile(src)
			Genki_Dama
				Dodgeable=-1
				Distance=100
				IconSize=0.05
				Deflectable=0
				Cooldown=-1
				Knockback=1
				Homing=1
				HyperHoming=1
				Destructive=1
				StrRate=0.5
				ForRate=0.5
				EndRate=1
				IconLock='SupernovaBlue.dmi'
				LockX=-158
				LockY=-169
				Variation=0
				ZoneAttack=1
				ZoneAttackX=0
				FireFromSelf=1
				FireFromEnemy=0
				verb/Genki_Dama()
					set category="Skills"
					src.Charge=5*src.Mastery
					src.IconChargeOverhead=(1/32)*(src.Mastery**4)
					src.IconSizeGrowTo=0.125*(src.Mastery**2)
					src.DamageMult=2.5*src.Mastery
					src.MultiHit=5*src.Mastery
					src.Radius=1*(src.Mastery-1)
					src.ZoneAttackY=round(2.5*src.Mastery)
					src.Explode=1*(src.Mastery**2)
					HolyMod = 3*Mastery
					usr.UseProjectile(src)
			Death_Ball
				SignatureTechnique=2
				Dodgeable=-1
				Distance=150
				Deflectable=1
				Cooldown=180
				Knockback=1
				Homing=1
				HyperHoming=1
				AdaptRate=1
				EndRate=1
				IconLock='deathball2.dmi'
				IconSize=0.1
				IconSizeGrowTo=0.5
				LockX=-33
				LockY=-33
				Variation=0
				Charge=2
				IconChargeOverhead=1
				DamageMult=1.5
				AccMult=25
				MultiHit=10
				Radius=1
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
				Explode=4
				Instinct=2
				EnergyCost=10
				verb/Death_Ball()
					set category="Skills"
					usr.UseProjectile(src)
			Supernova
				PreRequisite=list("/obj/Skills/Projectile/Death_Ball")
				SignatureTechnique=2
				Dodgeable=-1
				Distance=150
				Deflectable=1
				Cooldown=180
				Knockback=1
				Homing=1
				HyperHoming=1
				AdaptRate=1
				EndRate=1
				IconLock='Supernova.dmi'
				IconSize=0.1
				IconSizeGrowTo=1
				LockX=-158
				LockY=-169
				Variation=0
				Charge=3
				IconChargeOverhead=1
				DamageMult=1.75
				AccMult=25
				MultiHit=10
				Radius=2
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
				Explode=5
				Instinct=2
				EnergyCost=25
				verb/Supernova()
					set category="Skills"
					usr.UseProjectile(src)

			A_Pound_of_Gold
				Distance=20
				DamageMult=6
				AccMult = 1.5
				Knockback=5
				EnergyCost=3
				Cooldown=120
				Homing=1
				IconLock='GoldPile.dmi'
				IconSize=0.35
				LockX=-32
				LockY=-32
				Variation=0
				GoldScatter = 1

				verb/A_Pound_of_Gold()
					set category="Skills"
					usr.UseProjectile(src)

			Goblin_Greed
				Distance=20
				DamageMult=6
				AccMult = 1.15
				Knockback=5
				EnergyCost=3
				Cooldown=120
				Homing=1
				IconLock='GoldPile.dmi'
				IconSize=0.35
				LockX=-32
				LockY=-32
				Variation=0
				GoldScatter = 1

				verb/Goblin_Greed()
					set category="Skills"
					usr.UseProjectile(src)

//SHIT THAT AINT USED
			Feint_Shot//this boi currently isnt used
				/*SkillCost=4
				Copyable=
				PreRequisite=list("/obj/Skills/Projectile/Charge")
				LockOut=list("/obj/Skills/Projectile/Crash_Burst", "/obj/Skills/Projectile/Dragon_Nova", "/obj/Skills/Queue/Counter_Cannon")
				Copyable=2*/
				Distance=30
				DamageMult=0.5
				MultiHit=4
				Knockback=1
				AccMult = 1.175
				Explode=1
				Charge=0.2
				EnergyCost=3
				Cooldown=30
				Feint=1
				IconLock='Blast - Charged.dmi'
				LockX=-12
				LockY=-12
				IconSize=0.5
				Variation=0
				verb/Feint_Shot()
					set category="Skills"
					usr.UseProjectile(src)
			Counter_Cannon_Shot
				Distance=30
				DamageMult=0.4
				MultiHit=5
				AccMult = 1.175
				Explode=1
				IconLock='Blast - Charged.dmi'
				LockX=-12
				LockY=-12
				IconSize=0.7
				Variation=0
			Crusher_Ball
				SkillCost=80
				Copyable=5
				Distance=40
				DamageMult=5
				AccMult=1
				Launcher=1
				Piercing=1
				Striking=1.5
				Homing=1
				HomingCharge=1
				HomingDelay=4
				EnergyCost=10
				Charge=0.5
				IconChargeOverhead=1
				Explode=2
				Cooldown=200
				IconLock='Blast31.dmi'
				Variation=0
				verb/Crusher_Ball()
					set category="Skills"
					usr.UseProjectile(src)
			Chasing_Bullet
				SkillCost=80
				Copyable=5
				Distance=40
				DamageMult=5
				AccMult=2
				Speed=2
				Launcher=0
				Piercing=0
				Homing=1
				LosesHoming=10
				HomingCharge=10
				EnergyCost=8
				Charge=1
				IconChargeOverhead=1
				Explode=2
				Cooldown=200
				IconLock='Plasma0.dmi'
				IconSize=1.5
				Variation=0
				verb/Chasing_Bullet()
					set category="Skills"
					usr.UseProjectile(src)
			Consecutive_Kienzan
				SkillCost=80
				Copyable=5
				Blasts=3
				Distance=50
				DamageMult=6
				EnergyCost=30
				Deflectable=0
				Charge=0.5
				Delay=2
				IconChargeOverhead=1
				IconLock='Kienzan.dmi'
				LockX=0
				LockY=0
				IconSize=0.1
				IconSizeGrowTo=1.5
				Cooldown=450
				Slashing=1
				Piercing=1
				Variation=0
				MaimStrike=2//If damage > 12.5%, maim
				verb/Consecutive_Kienzan()
					set category="Skills"
					usr.UseProjectile(src)
			Split_Slicer
				SkillCost=80
				Copyable=5
				Distance=7
				DamageMult=6
				EnergyCost=30
				Deflectable=0
				Charge=1
				IconChargeOverhead=1
				IconLock='Kienzan.dmi'
				LockX=0
				LockY=0
				IconSize=0.1
				IconSizeGrowTo=1
				Cooldown=300
				Slashing=1
				Piercing=1
				Cluster=new/obj/Skills/Projectile/Kienzan_Bits
				ClusterCount=2
				Variation=0
				MaimStrike=1.25//If damage > 20, maim
				verb/Split_Slicer()
					set category="Skills"
					usr.UseProjectile(src)

//General App
			MegiddoMeteor
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				IconLock='Boulder Normal2.dmi'
				LockX=-36
				LockY=-36
				FireFromEnemy=1
				HyperHoming=1
				Homing=1
				Radius=1
				DamageMult=10
				Scorching=10
				Shattering=10
				Distance=200
				Variation=0
				StrRate=1
				ForRate=0
				EndRate=1
				Explode=2
				Dodgeable=-1
				Hover=20
				//No verb because set by queue

////Unarmed
			KinshasaProjectile
				IconLock='Boosting Winds.dmi'
				IconSize=1
				Dodgeable=-1
				Radius=1
				Striking=1
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
				Variation=0
				StrRate=1
				EndRate=1
				Knockback=10
				MultiHit=4
				DamageMult=0.15
				AccMult = 1.25
				Deflectable=1
				Distance=10
				Instinct=2

			GaleStrikeProjectile
				IconLock='Boosting Winds.dmi'
				IconSize=2
				Dodgeable=-1
				Radius=1
				Striking=1
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
				Variation=0
				StrRate=1
				ForRate=0
				EndRate=0.75
				Knockback=1
				MultiHit=8
				DamageMult=2
				AccMult = 1.25
				Deflectable=0
				Distance=10
				Instinct=2
				//No verb becuase this is set from a Queue.
			Flash_Fist_Crush
				UnarmedOnly=1
				SignatureTechnique=2
				StrRate=1
				ForRate=0
				Radius=1
				Distance=20
				DamageMult=17
				Dodgeable=-1
				Deflectable=-1
				Speed=0
				Knockback=0
				Striking=1
				MortalBlow=0.35
				IconLock='FlashFist.dmi'
				Trail='FlashFist.dmi'
				Cooldown=-1
				EnergyCost=25
				Variation=0
				verb/Flash_Fist_Crush()
					set category="Skills"
					usr.UseProjectile(src)
			Void_Dragon_Fist
				UnarmedOnly=1
				SignatureTechnique=2
				StrRate=1
				ForRate=1
				DamageMult=1.55
				Speed=0
				Dodgeable=-1
				Deflectable=-1
				Distance=10
				Blasts=10
				Delay=1
				Radius=1
				Knockback=2
				Striking=1
				IconLock='VDF-Burst.dmi'
				IconSize=1
				Trail='VDF-Trail.dmi'
				TrailSize=1
				Variation=24
				Cooldown=180
				EnergyCost=2
				ActiveMessage="unleashes an instant flurry of hypersonic blows!"
				verb/Void_Dragon_Fist()
					set category="Skills"
					usr.UseProjectile(src)
			AsaKujaku
				Distance=5
				DamageMult=0.5
				AccMult = 1.175
				Stream=2
				Radius=1
				Piercing=1
				RandomPath=1
				Scorching=1
				Dodgeable=-1
				Deflectable=-1
				StrRate=1
				ForRate=0
				EndRate=1
				Deflectable=0
				IconLock='FireBlast.dmi'
				IconSize=1
				Variation=8
				Cooldown=0
			Evening_Elephant
				GateNeeded=8
				MultiShot=5
				MultiHit=5
				IconLock='SekiZou.dmi'
				IconSize=0.75
				LockX=-50
				LockY=-50
				Trail='SekiZou.dmi'
				TrailSize=0.75
				TrailX=-50
				TrailY=-50
				DamageMult=25
				AccMult = 5
				Speed=0
				Radius=1
				Dodgeable=-1
				Deflectable=-1
				Feint=1
				Launcher=1
				StrRate=4
				ForRate=0
				EndRate=0.0001
				Knockback=10
				Variation=0
				Distance=20
				Cooldown=-1
				verb/Evening_Elephant()
					set category="Skills"
					usr.UseProjectile(src)

////Sword

			Tornado
				FlickBlast=0
				AttackReplace=1
				Distance=15
				DamageMult=8
				Dodgeable=0
				Deflectable=0
				Instinct=2
				Radius=1
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
				Knockback=0
				Piercing=1
				Launcher=3
				IconLock='TornadoDirected.dmi'
				IconSize=3
				LockX=-8
				LockY=-8
				Variation=0
				Trail='TornadoDirected.dmi'
				TrailDuration=20
				TrailSize=3
				TrailX=-8
				TrailY=-8



//Tier 1


			Rasenshuriken
				Charge=3
				ChargeMessage="focuses their chakra into a spiraling sphere!"
				ActiveMessage="releases their chakra into a spiraling sphere!"
				Distance=50
				DamageMult=1.5
				MultiHit=10
				AccMult = 1.25
				Explode=4
				Knockback=1
				Radius=3
				Homing = 3
				Dodgeable=1
				Deflectable=0
				StrRate=1.25
				ForRate=1
				EndRate=0.75
				IconLock='SpiritGun2.dmi'
				IconSize=0.5
				IconSizeGrowTo=1.5
				Variation=0
				Cooldown=-1
				Shearing=6
				MortalBlow=0.1
				verb/Rasenshuriken()
					set category="Skills"
					usr.UseProjectile(src)



//Tier S

///Saint Seiya
			Pegasus_Comet_Fist
				CosmoPowered=1
				Distance=50
				DamageMult=1.1
				AccMult=20
				MultiHit=10
				Knockback=1
				Charge=0.1
				StrRate=1
				EndRate=1
				IconLock='SpiritGun2.dmi'
				IconSize=0.8
				LockX=-12
				LockY=-12
				Variation=0
				ChargeIcon=1
				Striking=1
				Radius=1
				Dodgeable=0
				Deflectable=-1
				ChargeMessage="focuses their Cosmo in a form of a majestic steed!"
				ActiveMessage="unleashes a comet strike soaring with Pegasus' power!"
				Cooldown=150
				verb/Pegasus_Comet_Fist()
					set category="Skills"
					set name="Pegasus Suisei Ken"
					usr.UseProjectile(src)
			Diamond_Dust
				CosmoPowered=1
				Distance=20
				Deflectable=-1
				Charge=0.5
				DamageMult=1.1
				AccMult = 1.15
				Freezing=1
				Blasts=10
				Stream=2
				Piercing=1
				Striking=1
				IconLock='SnowBurst.dmi'
				Variation=18
				ChargeIcon=1
				ChargeMessage="focuses their Cosmo in a form of a graceful fowl!"
				ActiveMessage="unleashes a burst of frigid crystal rivaling Swan's beauty!"
				Cooldown=150
				verb/Diamond_Dust()
					set category="Skills"
					usr.UseProjectile(src)
			Diamond_Dust_Storm
				CosmoPowered=1
				Distance=20
				Deflectable=-1
				Charge=0.1
				DamageMult=1.1
				AccMult = 1.15
				Freezing=1
				AbsoluteZero=1
				Blasts=10
				Stream=2
				Radius=1
				Piercing=1
				Striking=1
				IconLock='SnowBurst.dmi'
				IconSize=1.25
				Variation=18
				ChargeIcon=1
				ChargeMessage="focuses their Cosmo into a storm of diamond dust!"
				ActiveMessage="unleashes a burst of frigid crystal at the point of absolute zero!"
				Cooldown=150
				verb/Diamond_Dust_Storm()
					set category="Skills"
					set name="Diamond Dust"
					usr.UseProjectile(src)
			Nebula_Stream
				CosmoPowered=1
				UnarmedOnly=1
				FlickBlast=0
				AttackReplace=1
				Distance=15
				DamageMult=14
				Dodgeable=0
				Deflectable=0
				Charge=0.5
				Radius=1
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
				Knockback=0
				Piercing=1
				Launcher=3
				IconLock='TornadoNebula.dmi'
				IconSize=3
				LockX=-8
				LockY=-8
				Variation=0
				Trail='TornadoNebula.dmi'
				TrailDuration=20
				TrailSize=3
				TrailX=-8
				TrailY=-8
				ChargeIcon=1
				ChargeMessage="spirals their Cosmo into a galaxian tempest!"
				ActiveMessage="releases their restrained Cosmo into a burst of magnetic wind!"
				Cooldown=150
				verb/Nebula_Stream()
					set category="Skills"
					usr.UseProjectile(src)
			Phoenix_Feathers
				Distance=15
				DamageMult=1.8
				MultiShot=5
				Piercing=1
				Striking=1
				Homing=1
				LosesHoming=3
				IconLock='BlastTracer.dmi'
				Cooldown=30
				verb/Phoenix_Feather()
					set category="Skills"
					usr.UseProjectile(src)
			Phoenix_Wing
				CosmoPowered=1
				FlickBlast=0
				AttackReplace=1
				Distance=15
				DamageMult=2.5
				Dodgeable=0
				Deflectable=-1
				Radius=1
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
				Knockback=0
				Piercing=1
				Launcher=2
				IconLock='TornadoPhoenix.dmi'
				IconSize=3
				LockX=-8
				LockY=-8
				Variation=0
				Trail='TornadoPhoenix.dmi'
				TrailDuration=20
				TrailSize=3
				TrailX=-8
				TrailY=-8
////Gold Cloth
			Stardust_Revolution
				CosmoPowered=1
				GodPowered=0.25
				Blasts=50
				Distance=50
				DamageMult=0.25
				Radius=1
				Charge=0.5
				Delay=1
				ChargeIcon=1
				Hover=2
				ZoneAttack=1
				ZoneAttackX=2
				ZoneAttackY=2
				FireFromSelf=1
				FireFromEnemy=0
				Deflectable=-1
				Piercing=1
				Striking=1
				Dodgeable=0
				Cooldown=150
				IconLock='Blast - Charged.dmi'
				LockX=-12
				LockY=-12
				IconSize=0.4
				Trail='Hit Effect Ripple.dmi'
				TrailDuration=1
				TrailX=-32
				TrailY=-32
				Variation=16
				ChargeMessage="strains their Cosmo to bend dimensions..."
				ActiveMessage="unleashes a storm of stardust channeled from the depths of space!"
				verb/Stardust_Revolution()
					set category="Skills"
					if(usr.SagaLevel<5 && usr.Health>15 && !usr.InjuryAnnounce)
						usr << "You can't use this technique except when in a dire pinch!"
						return
					usr.UseProjectile(src)
			Galaxian_Explosion
				CosmoPowered=1
				GodPowered=0.25
				Blasts=10
				Distance=14
				DistanceVariance=1
				MultiHit=5
				DamageMult=0.9
				Explode=2
				Charge=2
				Delay=2
				ChargeIcon=1
				ZoneAttack=1
				ZoneAttackX=1
				ZoneAttackY=1
				FireFromSelf=1
				FireFromEnemy=0
				Deflectable=0
				HomingCharge=1
				HomingDelay=3
				HyperHoming=1
				TurfShift='StarPixel.dmi'
				Knockback=1
				RandomPath=1
				Radius=1
				Dodgeable=-1
				Deflectable=-1
				Cooldown=150
				IconLock='PlanetBurst.dmi'
				IconVariance=6
				IconSize=0.6
				LockX=-32
				LockY=-32
				Variation=16
				ChargeMessage="expands their Cosmo to an immense size..."
				ActiveMessage="unleashes an eruption of power on galactic scale!"
				verb/Galaxian_Explosion()
					set category="Skills"
					if(usr.SagaLevel<5 && usr.Health>15 && !usr.InjuryAnnounce)
						usr << "You can't use this technique except when in a dire pinch!"
						return
					usr.UseProjectile(src)
			Praesepe_Demonic_Blue_Flames
				CosmoPowered=1
				GodPowered=0.25
				Blasts=10
				Distance=20
				DamageMult=1.1
				Charge=1
				Delay=2
				ChargeIcon=1
				ZoneAttack=1
				ZoneAttackX=1
				ZoneAttackY=1
				FireFromSelf=1
				FireFromEnemy=0
				Deflectable=0
				HomingCharge=4
				HomingDelay=2
				HyperHoming=1
				Piercing=1
				SoulFire=10
				Dodgeable=-1
				Deflectable=-1
				Cooldown=150
				IconLock='CrossbowBolt.dmi'
				LockX=-32
				LockY=-32
				Trail='SparkleBlue.dmi'
				TrailDuration=1
				TrailSize=0.5
				Variation=16
				ChargeMessage="ignites their Cosmo into a burial pyre..."
				ActiveMessage="unleashes a cloud of will-o-wisps, flames that burn soul itself!"
				verb/Praesepe_Demonic_Blue_Flames()
					set category="Skills"
					set name="Sekishiki Kisoen"
					if(usr.SagaLevel<5 && usr.Health>15 && !usr.InjuryAnnounce)
						usr << "You can't use this technique except when in a dire pinch!"
						return
					usr.UseProjectile(src)
			Lightning_Bolt
				CosmoPowered=1
				Distance=100
				MultiHit=10
				DamageMult=1.1
				Knockback=1
				Radius=1
				Dodgeable=-1
				Deflectable=-1
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
				StrRate=1
				ForRate=1
				IconLock='LightningBolt2.dmi'
				LockX=-33
				LockY=-33
				IconChargeOverhead=(1/32)
				IconSize=1
				IconSizeGrowTo=0.5
				Variation=0
				Striking=1
				ChargeMessage="focuses their Cosmo into a bolt of plasma!"
				ActiveMessage="tears through space with a thunderous roaring blow!"
				Cooldown=150
				verb/Lightning_Bolt()
					set category="Skills"
					set name="Lightning Bolt"
					usr.UseProjectile(src)
			Libra_Slash
				AttackReplace=1
				IconLock='Excaliblast.dmi'
				IconSize=0.6
				LockX=-50
				LockY=-50
				DamageMult=0.4
				AccMult=25
				MultiHit=10
				Knockback=1
				Radius=1
				Dodgeable=0
				ZoneAttack=1
				ZoneAttackX=0
				ZoneAttackY=0
				FireFromSelf=1
				FireFromEnemy=0
				StrRate=1
				ForRate=1
				EndRate=1
				Distance=15
			Scarlet_Needle
				CosmoPowered=1
				GodPowered=0.25
				MultiShot=4
				Area="Blast"
				StrRate=0
				ForRate=1
				Distance=20
				DamageMult=3
				Dodgeable=-1
				Deflectable=-1
				Speed=0
				Knockback=0
				Piercing=1
				Striking=1
				Crippling=1
				Excruciating=0.5
				IconLock='Trail - Scorpio.dmi'
				Trail='Trail - Scorpio.dmi'
				ActiveMessage="launches a piercing sting at their opponents!"
				Cooldown=150
				Variation=8
				verb/Scarlet_Needle()
					set category="Skills"
					if(usr.SagaLevel<5 && usr.Health>15 && !usr.InjuryAnnounce)
						usr << "You can't use this technique except when in a dire pinch!"
						return
					usr.UseProjectile(src)
			Sacred_Sword
				CosmoPowered=1
				Distance=40
				DamageMult=2.75
				AccMult = 1.175
				Piercing=1
				Striking=1
				Homing=1
				HyperHoming=1
				HomingCharge=10
				MultiHit = 4
				Dodgeable=-1
				Deflectable=-1
				Charge=0.5
				ChargeIcon=1
				Cooldown=150
				IconLock='BLANK.dmi'
				Variation=0
				Trail='Seiken2.dmi'
				ActiveMessage="trails a path of slicing Cosmo chasing down the opponent!"
				verb/Sacred_Sword()
					set category="Skills"
					usr.UseProjectile(src)
			Royal_Demon_Rose
				CosmoPowered=1
				GodPowered=0.25
				Blasts=20
				Distance=20
				DamageMult=0.55
				Charge=1
				Delay=1
				ChargeIcon=1
				ZoneAttack=1
				ZoneAttackX=1
				ZoneAttackY=1
				FireFromSelf=1
				FireFromEnemy=0
				Deflectable=0
				Homing=1
				HyperHoming=1
				Piercing=1
				Striking=1
				Excruciating=0.1
				Cooldown=150
				IconLock='RosePetals.dmi'
				LockX=-32
				LockY=-32
				Trail='RosePetals.dmi'
				TrailX=-32
				TrailY=-32
				TrailDuration=1
				TrailSize=0.5
				Variation=8
				ActiveMessage="casts a handful of poisonous crimson roses at their target!"
				verb/Royal_Demon_Rose()
					set category="Skills"
					if(usr.SagaLevel<5 && usr.Health>15 && !usr.InjuryAnnounce)
						usr << "You can't use this technique except when in a dire pinch!"
						return
					usr.UseProjectile(src)
			Light_Impulse
				CosmoPowered=1
				GodPowered=0.25
				Distance=20
				DamageMult=16
				ChargeIcon=1
				ZoneAttack=1
				ZoneAttackX=1
				ZoneAttackY=1
				FireFromSelf=1
				FireFromEnemy=0
				Deflectable=0
				Homing=1
				HyperHoming=1
				Piercing=1
				Striking=1
				Cooldown=150
				Radius = 3
				IconLock='LightImpulse.dmi'
				LockX=-32
				LockY=-32
				Trail='LightImpulseTrail.dmi'
				TrailX=-32
				TrailY=-32
				TrailDuration=1
				TrailSize=1
				Variation=8
				Charge = 1
				IconChargeOverhead=1
				IconSize=0.01
				IconSizeGrowTo=2
				ActiveMessage="roars their Cosmos across their wings into a brilliant display of light towards their enemy!"
				verb/Light_Impulse()
					set category="Skills"
					if(usr.SagaLevel<5 && usr.Health>15 && !usr.InjuryAnnounce)
						usr << "You can't use this technique except when in a dire pinch!"
						return
					usr.UseProjectile(src)
			Infinity_Break
				CosmoPowered=1
				Blasts = 250 //i see no way this could go wrong !
				Distance=20
				DamageMult=0.1
				ZoneAttack=1
				ZoneAttackX=4
				ZoneAttackY=4
				FireFromSelf=1
				FireFromEnemy=0
				Deflectable=0
				Homing=8
				HyperHoming=1
				Piercing=1
				Striking=1
				Cooldown=200
				Radius = 1
				IconLock='LightImpulse.dmi'
				LockX=-32
				LockY=-32
				Trail='LightImpulseTrail.dmi'
				TrailDuration=1
				TrailSize=0.75
				ActiveMessage="begins firing off countless darts of Cosmos-infused light!"
				verb/Infinity_Break()
					set category="Skills"
					usr.UseProjectile(src)
////Weapon Soul
			Weapon_Soul
				Holy_Slash
					IconLock='Excaliblast.dmi'
					LockX=-50
					LockY=-50
					DamageMult=0.08
					AccMult=25
					MultiHit=100
					Knockback=1
					Radius=1
					ZoneAttack=1
					ZoneAttackX=0
					ZoneAttackY=0
					FireFromSelf=1
					FireFromEnemy=0
					Explode=3
					StrRate=1
					ForRate=1
					EndRate=1
					Dodgeable=-1
					Deflectable=-1
					HolyMod=10
					Distance=100
					//No verb because set from queue
				Darkness_Slash
					IconLock='DExcaliblast.dmi'
					LockX=-50
					LockY=-50
					DamageMult=0.08
					AccMult=25
					MultiHit=100
					Knockback=1
					Radius=1
					ZoneAttack=1
					ZoneAttackX=0
					ZoneAttackY=0
					FireFromSelf=1
					FireFromEnemy=0
					Explode=3
					StrRate=1
					ForRate=1
					EndRate=1
					Dodgeable=-1
					Deflectable=-1
					Distance=100
					//No verb because set from queue.

////KoB
			King_of_Braves
				Broken_Magnum//t5
					Distance=25
					DamageMult=2.2
					AccMult = 1.25
					MultiHit=5
					Knockback=1
					Charge=0
					StrRate=1
					ForRate=1
					EndRate=1
					Explode=1
					IconLock='SYO!.dmi'
					IconSize=0.75
					Variation=0
					Cooldown=150
					SBuffNeeded="Broken Brave"
					verb/Broken_Magnum()
						set category="Skills"
						if(usr.SpecialBuff)
							if(usr.SpecialBuff.BuffName!="Genesic Brave"&&src.SBuffNeeded!="Broken Brave")
								src.SBuffNeeded="Broken Brave"
							else if(usr.SpecialBuff.BuffName=="Genesic Brave")
								src.SBuffNeeded="Genesic Brave"
						usr.UseProjectile(src)
				Broken_Phantom
					Distance=25
					DamageMult=2.4
					AccMult = 1.25
					Deflectable=-1
					MultiHit=5
					Knockback=1
					Charge=0.5
					StrRate=1
					ForRate=1
					EndRate=1
					Explode=2
					Homing=1
					IconLock='SYO!.dmi'
					IconSize=0.75
					Variation=0
					Cooldown=180
					SBuffNeeded="Broken Brave"
					verb/Broken_Phantom()
						set category="Skills"
						if(usr.SpecialBuff)
							if(usr.SpecialBuff.BuffName!="Genesic Brave"&&src.SBuffNeeded!="Broken Brave")
								src.SBuffNeeded="Broken Brave"
							else if(usr.SpecialBuff.BuffName=="Genesic Brave")
								src.SBuffNeeded="Genesic Brave"
						usr.UseProjectile(src)
				Brave_Tornado
					FlickBlast=0
					AttackReplace=1
					Distance=15
					DamageMult=5
					Dodgeable=-1
					Deflectable=-1
					Radius=1
					ZoneAttack=1
					ZoneAttackX=0
					ZoneAttackY=0
					FireFromSelf=1
					FireFromEnemy=0
					Knockback=0
					Piercing=1
					Launcher=2
					Cooldown=150
					IconLock='TornadoDirectedBrave-A.dmi'
					IconSize=3
					LockX=-8
					LockY=-8
					Variation=0
					Trail='TornadoDirectedBrave-A.dmi'
					TrailDuration=30
					TrailSize=3
					TrailX=-8
					TrailY=-8

////Ansatsuken
			Ansatsuken

				StrRate=1
				ForRate=1
				EndRate=1
				AccMult = 1.25
				Striking=1
				IconLock='Hadoken.dmi'
				LockX=-4
				LockY=-4
				HyperHoming=1
				Variation=0
				StyleNeeded="Ansatsuken"
				Instinct=1
				proc/ResetVars()
					StrRate = initial(StrRate)
					ForRate = initial(ForRate)
					EndRate = initial(EndRate)
					AccMult = initial(AccMult)
					Striking = initial(Striking)
					HyperHoming = initial(HyperHoming)
					Variation = initial(Variation)
					Instinct = initial(Instinct)
					DamageMult = initial(DamageMult)
					Distance = initial(Distance)
					MultiHit = initial(MultiHit)
					Knockback = initial(Knockback)
					Cooldown = initial(Cooldown)
					IconSize = initial(IconSize)
					Radius = initial(Radius)
					Stunner = initial(Stunner)
					ManaCost = initial(ManaCost)
				proc/activate(mob/player)

				Denjin_Hadoken
					Cooldown = -1
					SBuffNeeded="Denjin Renki"
					Paralyzing=1
					ActiveMessage = "Denjin...HADOKEN!"
					activate(mob/player)
						var/sagaLevel = player.SagaLevel
						var/damage = clamp(5*(sagaLevel/2), 5, 15)
						var/ansatsukenPath = player.AnsatsukenPath == "Hadoken" ? 1 : 0
						var/distance = 40
						var/charge = 0.1
						var/manaCost = 0
						var/radius = 3
						var/multiHit = 1
						var/iconSize = 2
						var/stunner = 2
						if(ansatsukenPath)
							charge = 0.05
							damage =  clamp(5.5*(sagaLevel/2), 5.5, 20)
							radius = 5
							iconSize = 3
							stunner = 3
						DamageMult = damage
						Distance = distance
						Charge = charge
						ManaCost = manaCost
						Radius = radius
						MultiHit = multiHit
						IconSize = iconSize
						Stunner = stunner
					verb/Denjin_Hadoken()
						set category="Skills"
						if(usr.SpecialBuff && usr.SpecialBuff.BuffName=="Denjin Renki")
							ResetVars()
							activate(usr)
							ZoneAttack=0
							ZoneAttackX=0
							ZoneAttackY=0
							FireFromSelf=1
							FireFromEnemy=0
							usr.UseProjectile(src)
				Hadoken
					Cooldown=40
					ActiveMessage = "HADOKEN!"
					activate(mob/player)
						var/cooldown = 30
						var/sagaLevel = player.SagaLevel
						var/damage = 1.5 + 1 * sagaLevel
						var/ansatsukenPath = player.AnsatsukenPath == "Hadoken" ? 1 : 0
						var/distance = 30
						var/charge = 0.25
						var/iconSize = 1
						var/stunner = 0
						Knockback = 2
						if(ansatsukenPath)
							cooldown -= 5
							damage = 2 + 1.5 * sagaLevel
							Knockback = 3
						if(player.AnsatsukenAscension == "Satsui" && src.IconLock == 'Hadoken.dmi')
							src.IconLock = 'Hadoken - Satsui.dmi'
						DamageMult = damage
						Distance = distance
						Charge = charge
						MultiHit = 5
						IconSize = iconSize
						Radius = 1
						Stunner = stunner
						Cooldown = cooldown
					verb/Hadoken()
						set category="Skills"
						ResetVars()
						activate(usr)
						ZoneAttack=0
						ZoneAttackX=0
						ZoneAttackY=0
						FireFromSelf=1
						FireFromEnemy=0
						usr.UseProjectile(src)

				Hadoken_EX
					DamageMult = 3
					MultiHit = 3
					Stunner = 2
					Radius = 1
					IconSize = 1.25
					Dodgeable=0
					Cooldown = 150
					adjust(mob/p)
						Charge=1.5
						Distance = 20
						Knockback = 4
						DamageMult = 2 + (1 * p.SagaLevel)
						MultiHit = 3 + (1.5*p.SagaLevel)
						DamageMult/=MultiHit
						Radius = 1
						IconSize = 1.25
						if(p.AnsatsukenPath == "Hadoken")
							Charge = 1
							DamageMult = 3 + (1.5 * p.SagaLevel)
							DamageMult/=MultiHit
							Radius = 2
							IconSize = 2
							Distance = 25
					verb/EX_Hadoken()
						set category = "Skills"
						adjust(usr)
						usr.UseProjectile(src)
				Shinku_Hadoken
					Distance=40
					Charge=0.5
					ManaCost=100
					DamageMult=1
					Shearing=1
					AccMult=50
					MultiHit=15
					HyperHoming=1
					Dodgeable=-1
					Deflectable=-1
					Knockback=1
					Cooldown=180
					IconSize=3
					Radius=1
					Homing=1
					ZoneAttack=1
					ZoneAttackX=0
					ZoneAttackY=0
					FireFromSelf=1
					FireFromEnemy=0
					Striking=1
					verb/Shinku_Hadoken()
						set category="Skills"
						set name="Shinku-Hadoken"
						if(usr.AnsatsukenAscension=="Satsui" && src.IconLock=='Hadoken.dmi')
							IconLock='Hadoken - Satsui.dmi'
						usr.UseProjectile(src)
				Tenma_Gozanku
					Distance=40
					Blasts=5
					Charge=1
					ManaCost=50
					DamageMult=4
					MultiHit=5
					Knockback=1
					IconSize=2
					Dodgeable=-1
					Deflectable=-1
					Radius=1
					Delay=1
					ZoneAttack=1
					ZoneAttackX=0
					ZoneAttackY=0
					FireFromSelf=1
					FireFromEnemy=0
					Variation=16
					IconLock='Hadoken - Satsui.dmi'
					verb/Tenma_Gozanku()
						set category="Skills"
						set name="Tenma-Gozanku"
						usr.UseProjectile(src)

			Zone_Attacks

				ZoneAttack=1

				RockBreakerCoffin
					Homing=0
					Speed=1
					Charge=0
					Delay=1
					FatigueCost=0
					DamageMult=2
					Distance=0
					Cluster=new/obj/Skills/Projectile/Rock_Bits
					ClusterCount=10
					Hover=30
					Blasts=3
					ZoneAttackX=3
					ZoneAttackY=3
					FireFromSelf=1
					FireFromEnemy=0
					IconLock='Boulder Normal2.dmi'
					LockX=-36
					LockY=-36
					IconSize=0.5
					ActiveMessage="invokes three mighty boulders from the ground and smashes them apart!"
					//No verb because it is set from melee
				Hellzone_Grenade
					SignatureTechnique=1
					EnergyCost=15
					Speed = 0.25
					Distance=20
					Blasts=15
					Charge=1
					DamageMult=0.7
					Instinct=1
					AccMult=2
					Homing=3
					Explode=1
					ZoneAttackX=3
					ZoneAttackY=3
					Hover=7
					Variation=0
					Cooldown = 180
					verb/Hellzone_Grenade()
						set category="Skills"
						usr.UseProjectile(src)
				Homing_Finisher
					SignatureTechnique=2
					EnergyCost=50
					Blasts=25
					Charge=2
					DamageMult=0.6
					Instinct=1
					AccMult=2
					Explode=1
					Distance=100
					ZoneAttackX=10
					ZoneAttackY=10
					Hover=10
					Variation=0
					Cooldown=180
					verb/Homing_Finisher()
						set category="Skills"
						usr.UseProjectile(src)
				Global_Devastation
					IconLock='Meteor.dmi'
					LockX=0
					LockY=0
					IconSize=1
					ManaCost=100
					Distance=50
					DamageMult=0.5
					Dodgeable=-1
					Speed=3
					Variation=0
					ZoneAttack=1
					ZoneAttackX=10
					ZoneAttackY=10
					Homing=1
					LosesHoming=5
					HyperHoming=1
					FireFromEnemy=1
					Radius=1
					Shattering=10
					Scorching=10
					Hover=1
					Blasts=100
					Hover=5
					Explode=3
					AccMult = 1.175
					Cooldown=6000
					ActiveMessage="channels the flames of creation to cause a meteor storm!"
					verb/Global_Devastation()
						set category="Skills"
						usr.UseProjectile(src)

				Shattered_Heaven
					Blasts=1
					Speed=1
					Distance=240
					StormFall=30
					DamageMult=30
					AccMult=30
					Radius=5
					Explode=10
					Dodgeable=-1
					HyperHoming=1
					Striking=1
					FireFromEnemy=1
					ZoneAttackX=0
					ZoneAttackY=0
					IconLock='Boulder Normal2.dmi'
					IconSize=3
					LockX=-36
					LockY=-36
					Trail='SekiZou.dmi'
					TrailSize=5
					TrailDuration=3
					TrailX=-50
					TrailY=-50
					Variation=0

				Caladbolg
					Distance=50
					DamageMult=8.5
					Dodgeable=-1
					AccMult = 1.175
					Speed=2
					ManaCost=15
					Cooldown=120
					IconLock='Caladbolg.dmi'
					IconSize=1
					LockX=-36
					LockY=-36
					Variation=0
					ZoneAttack=1
					ZoneAttackX=6
					ZoneAttackY=6
					Homing=1
					LosesHoming=100
					HyperHoming=1
					Radius=1
					Shattering=10
					Scorching=10
					Variation=0
					Explode=2
					Hover=1
					ActiveMessage="projects the Spiraled Sword into the shape of a an arrow: <b>Caladbolg II</b>!"
					verb/Caladbolg_II()
						set category="Skills"
						if(!usr.getAriaCount())
							usr << "You can't project without your circuits active!"
							return
						ManaCost = usr.getUBWCost(2)
						DamageMult = clamp(4,(usr.getAriaCount()*2.5), 30)
						if(usr.getAriaCount() >= 4)
							Dodgeable = -1
						else
							Dodgeable = 1
						usr.UseProjectile(src)

				Gae_Bolg
					Distance=50
					DamageMult=8.5
					Dodgeable=-1
					AccMult = 1.175
					Speed=4
					Instinct = 4
					ManaCost=15
					Cooldown=120
					IconLock='Gae Bolg Projectile.dmi'
					IconSize=1
					LockX=-36
					LockY=-36
					Variation=0
					ZoneAttack=1
					ZoneAttackX=6
					ZoneAttackY=6
					Trail = 'Trail - Scorpio.dmi'
					Homing=1
					LosesHoming=100
					HyperHoming=1
					Radius=1
					Shattering=10
					Scorching=10
					Variation=0
					Explode=2
					Charge=3
					ChargeMessage="suddenly pours off mana like a fountain, the red spear in their grasp glinting menacingly as they lift it over their shoulder..."
					ActiveMessage="reverses casualty as the glowing red spear aims straight for their target's heart!!"
					proc/alter(mob/player)
						DamageMult = clamp(2,1.5*player.getAriaCount(),8)

			Magic
				MagicNeeded=1
				Fire
					ElementalClass="Fire"
					SkillCost=TIER_2_COST
					Copyable=2
					DamageMult=1
					AccMult=2
					Homing=1
					Scorching=1
					Explode=1
					MultiShot=4
					Deflectable=1
					ManaCost=1
					Cooldown=60
					IconLock='Fireball.dmi'
					ActiveMessage="invokes: <font size=+1>FIRE!</font size>"
					verb/Fire()
						set category = "Skills"
						usr.UseProjectile(src)

				Fira
					ElementalClass="Fire"
					SkillCost=TIER_2_COST
					Copyable=3
					PreRequisite=list("/obj/Skills/Projectile/Magic/Fire")
					DamageMult=4
					AccMult=2
					IconSize=2
					Homing=1
					Scorching=1
					Knockback=3
					Explode=2
					Charge=1
					ManaCost=5
					Cooldown=60
					IconLock='Fireball.dmi'
					ActiveMessage="invokes: <font size=+1>FIRA!</font size>"
					verb/Fira()
						set category="Skills"
						usr.UseProjectile(src)
				Firaga
					ElementalClass="Fire"
					SkillCost=TIER_2_COST
					Copyable=4
					PreRequisite=list("/obj/Skills/Projectile/Magic/Fira")
					DamageMult=2
					AccMult = 1.15
					IconSize=1.5
					Homing=1
					Scorching=1
					Explode=1.5
					Distance=20
					Knockback=1
					Blasts=3
					Charge=2
					ManaCost=7
					Cooldown=60
					IconLock='Fireball.dmi'
					ActiveMessage="invokes: <font size=+1>FIRAGA!</font size>"
					verb/Firaga()
						set category="Skills"
						usr.UseProjectile(src)


				Disintegrate
					ElementalClass="Fire"
					SkillCost=TIER_4_COST
					Copyable=5
					Distance=50
					DamageMult=6
					Radius=1
					Piercing=1
					PiercingBang=1
					AccMult = 1.175
					EndRate = 0.5
					Dodgeable=-1
					Deflectable=-1
					Speed=0
					ManaCost=15
					Cooldown=120
					IconLock='BLANK.dmi'
					Trail='Trail - Plasma.dmi'
					Variation=0
					ActiveMessage="invokes: <font size=+1>ERASE!</font size>"
					verb/Disable_Innovate()
						set category = "Other"
						disableInnovation(usr)
					adjust(mob/p)
						var/asc = p.AscensionsAcquired
						if(!altered)
							if(p.isInnovative(ELF, "Any") && !isInnovationDisable(p))
								if(p.passive_handler.Get("HotHundred") || p.passive_handler.Get("Warping"))
									EndRate = 0.5
									Radius=1
									MultiShot=0
									Distance = 50
									DamageMult=6
								else
									EndRate = 0.25
									Radius = 2
									MultiShot = 2 + asc
									Distance = 5
									DamageMult = 3 + asc
									DamageMult /= MultiShot
							else
								EndRate = 0.5
								Radius=1
								MultiShot=0
								Distance = 50
								DamageMult=6


					verb/Disintegrate()
						set category="Skills"
						adjust(usr)
						usr.UseProjectile(src)
				Meteor
					ElementalClass="Fire"
					SkillCost=TIER_4_COST
					Copyable=5
					PreRequisite=list("/obj/Skills/Projectile/Magic/Disintegrate")
					Distance=50
					DamageMult=11
					Dodgeable=-1
					AccMult = 1.175
					Speed=2
					ManaCost=15
					Cooldown=120
					IconLock='Boulder Normal.dmi'
					IconSize=1
					LockX=-36
					LockY=-36
					Variation=0
					ZoneAttack=1
					ZoneAttackX=6
					ZoneAttackY=6
					Homing=1
					LosesHoming=100
					HyperHoming=1
					FireFromEnemy=1
					Radius=1
					Shattering=10
					Scorching=10
					Variation=0
					Explode=2
					Hover=1
					ActiveMessage="invokes: <font size=+1>METEO!</font size>"
					verb/Disable_Innovate()
						set category = "Other"
						disableInnovation(usr)
					adjust(mob/p)
						if(!altered)
							if(p.isInnovative(ELF, "Any") && !isInnovationDisable(p))
								var/asc = p.AscensionsAcquired
								ManaCost = clamp(p.ManaAmount, 15,100)
								Blasts = ManaCost/(4+asc)
								ZoneAttack=1
								ZoneAttackX=18
								ZoneAttackY=18
								Homing=1
								LosesHoming=75
								HyperHoming=1
								Speed=1.25
								IconSize=randValue(0.8,1.5)
								DamageMult = 9 + (asc)
								DamageMult/=Blasts
							else
								ManaCost=15
								Blasts = 0
								ZoneAttack=1
								ZoneAttackX=6
								ZoneAttackY=6
								Homing=1
								LosesHoming=100
								HyperHoming=1
								Speed=2
								IconSize=1
								DamageMult=11
					verb/Meteor()
						set category="Skills"
						adjust(usr)
						usr.UseProjectile(src)


				Uber_Shots
					Cooldown=150
					AccMult=25
					Distance=50
					ManaCost=15
					Charge=1
					Dodgeable=0
					Deflectable=0
					Variation=0
					Titan_Slayer
						Knockback=1
						DamageMult=1
						Piercing=1
						Stunner=3
						Cooldown=600
						Paralyzing=1
						IconChargeOverhead=(1/32)
						IconSize=1
						IconSizeGrowTo=2
						Dodgeable=-1
						IconLock='LightStrike.dmi'
						LockX=-19
						LockY=-17
						verb/Titan_Slayer()
							set category="Skills"
							usr.UseProjectile(src)
					Sunlight_Spear//Holy
						ElementalClass="Wind"
						SignatureTechnique=2
						HolyMod=5
						DamageMult=15
						Piercing=1
						Paralyzing=1
						Scorching=1
						Radius=1
						IconChargeOverhead=(1/32)
						IconSize=0.5
						IconSizeGrowTo=1
						Dodgeable=0
						IconLock='SunlightSpear.dmi'
						LockX=-19
						LockY=-17
						PiercingBang=1
						ExplodeIcon='Icons/Effects/Electric.dmi'
						verb/Sunlight_Spear()
							set category="Skills"
							usr.UseProjectile(src)
					Hellfire_Nova
						ElementalClass="Fire"
						SignatureTechnique=1
						SignatureName="Advanced Fire Magic"
						Distance=50
						DamageMult=4
						MultiHit=5
						Instinct=2
						Radius=1
						Knockback=10
						Explode=2
						Scorching=3
						Toxic=3
						Cooldown=150
						IconLock='Hellnova.dmi'
						LockX=-158
						LockY=-169
						IconChargeOverhead=2
						IconSize=0.01
						IconSizeGrowTo=0.2
						Variation=0
						verb/Hellfire_Nova()
							set category="Skills"
							usr.UseProjectile(src)


			Sword
				NeedsSword=1
				StrRate=1
				ForRate=0
				EndRate=1
				Slashing=1
				ChargeIcon='BLANK.dmi'
				ChargeMessage="grips the handle of their blade strongly!"

				TougaHyoujin
					NoTransplant=1
					Distance=30
					DamageMult=5//big boi damage that was from multihits
					Knockback=1
					Dodgeable=0
					Freezing=5
					Stasis=1
					Cooldown=60
					IconLock='Air Render.dmi'
					Radius=2
					IconSize=2
					Charge=1
					ChargeMessage="evokes the power of Yukianesa into a freezing slash!"
					verb/Touga_Hyoujin()
						set category="Skills"
						usr.UseProjectile(src)

				KokujinShippu
					NoTransplant=1
					name="Void Formation: Gale"
					Distance=30
					DamageMult=1
					MultiHit=5
					Knockback=1
					Dodgeable=0
					Cooldown=60
					IconLock='Air Render.dmi'
					Radius=2
					IconSize=3
					StrRate=1
					Charge=0.5
					ActiveMessage="aims to rend their opponents apart with <b>Kokujin: SHIPPU</b>!"
					verb/Kokujin_Shippu()
						set category="Skills"
						set name="Void Formation: Gale"
						usr.UseProjectile(src)

				AirRender
					SkillCost=10
					Copyable=1
					Distance=10
					DamageMult=0.2
					MultiShot=5
					EnergyCost=0.5
					Cooldown=5
					IconLock='Air Render.dmi'
					verb/Air_Render()
						set category="Skills"
						usr.UseProjectile(src)
				UnerringSlice
					SkillCost=20
					Copyable=2
					Distance=10
					DamageMult=0.5
					Radius=1
					MultiShot=3
					EnergyCost=1
					Cooldown=5
					IconLock='Air Render.dmi'
					IconSize=1.5
					verb/Unerring_Slice()
						set category="Skills"
						usr.UseProjectile(src)
				BoundlessCut
					SkillCost=20
					Copyable=2
					Distance=10
					DamageMult=0.2
					MultiShot=5
					Piercing=1
					EnergyCost=1
					IconLock='Air Render.dmi'
					EndRate=1
					Cooldown=0.5
					verb/Boundless_Cut()
						set category="Skills"
						usr.UseProjectile(src)

				Scathing_Breeze
					SkillCost=160
					Copyable=4
					Distance=20
					DamageMult=1.8
					AccMult = 1.25
					Radius=1
					ZoneAttack=1
					ZoneAttackX=0
					ZoneAttackY=0
					FireFromSelf=1
					FireFromEnemy=0
					MultiHit=5
					Knockback=1
					Charge=0.5
					EnergyCost=2
					Cooldown=120
					IconSize=2
					Variation=0
					IconLock='Air Render.dmi'
					verb/Scathing_Breeze()
						set category="Skills"
						usr.UseProjectile(src)
				Wind_Scar
					SkillCost=160
					Copyable=5
					Distance=120
					DamageMult=0.85
					AccMult = 1.5
					Radius=1
					ZoneAttack=1
					ZoneAttackX=0
					ZoneAttackY=0
					FireFromSelf=1
					FireFromEnemy=0
					Blasts=5
					Delay=1
					MultiHit=3
					Knockback=1
					Charge=1
					EnergyCost=5
					Cooldown=120
					IconSize=2
					Variation=8
					IconLock='Air Render.dmi'
					verb/Wind_Scar()
						set category="Skills"
						usr.UseProjectile(src)
				Backlash_Wave
					SkillCost=160
					Copyable=5
					Distance=30
					DamageMult=1.1
					AccMult = 1.5
					Radius=1
					ZoneAttack=1
					ZoneAttackX=0
					ZoneAttackY=0
					FireFromSelf=1
					FireFromEnemy=0
					MultiHit=10
					Devour=1
					Knockback=1
					EnergyCost=3
					Cooldown=120
					IconLock='TornadoDirected.dmi'
					IconSize=2
					LockX=-8
					LockY=-8
					Variation=0
					Trail='TornadoDirected.dmi'
					TrailSize=2
					TrailX=-8
					TrailY=-8
					verb/Backlash_Wave()
						set category="Skills"
						usr.UseProjectile(src)
				Air_Carve
					SkillCost=160
					Copyable=5
					Distance=20
					DamageMult=2.2
					AccMult = 1.5
					MultiShot=5
					Knockback=1
					EnergyCost=3
					Cooldown=120
					Homing=1
					IconLock='Scarring Breeze.dmi'
					IconSize=0.35
					LockX=-32
					LockY=-32
					Variation=0
					verb/Air_Carve()
						set category="Skills"
						usr.UseProjectile(src)
				Phantom_Howl
					SkillCost=160
					Copyable=5
					Distance=20
					DamageMult=2.2
					AccMult = 1.25
					Radius=1
					ZoneAttack=1
					ZoneAttackX=0
					ZoneAttackY=0
					FireFromSelf=1
					FireFromEnemy=0
					MultiHit=5
					Knockback=1
					Charge=0.5
					EnergyCost=2
					Cooldown=120
					IconSize=2
					Variation=0
					IconLock='Air Render.dmi'
					Feint=1
					verb/Phantom_Howl()
						set category="Skills"
						usr.UseProjectile(src)

				Hiten_Mitsurugi
					StyleNeeded="Hiten Mitsurugi"
					Earth_Dragon_Flash
						name="Doryusen"
						Distance=5
						AccMult = 1.175
						DamageMult=2
						Blasts=5
						Radius=1
						Slashing=0
						Striking=1
						Crushing=2
						Crippling=2
						EnergyCost=5
						Cooldown=90
						Stream=2
						IconLock='Boulder Normal2.dmi'
						IconSize=0.2
						LockX=-36
						LockY=-36
						Variation=12
						verb/Doryusen()
							set category="Skills"
							usr.UseProjectile(src)
				Bard
					StrRate=1
					ForRate=1
					EndRate=1
					IconLock='Soundwave.dmi'
					LockX=0
					LockY=0
					Slashing=0
					Bardic_Riff
						Distance=15
						DamageMult=1
						MultiShot=5
						Homing=1
						EnergyCost=0.5
						Explode=1
						Cooldown=30
						verb/Bardic_Riff()
							set category="Skills"
							usr.UseProjectile(src)
					Bardic_Scream
						Distance=30
						DamageMult=1.15
						AccMult=2
						Radius=1
						MultiHit=5
						Knockback=1
						Charge=1
						EnergyCost=5
						Explode=1
						Cooldown=60
						IconSize=2
						Variation=0
						ChargeMessage="clears their throat..."
						ActiveMessage="lets loose with a bardic wail!!"
						verb/Bardic_Scream()
							set category="Skills"
							usr.UseProjectile(src)

			Beams
				Area="Beam"
				Variation=0
				IconLock='Beam14.dmi'
				IconSize=1
				AccMult = 1.175
				Knockback=1
				Deflectable=-1
				Distance=50
				density=0
				BeamTime=50
				//Racial ish if it ever works
				MysticAttack
					density=1
					StrRate=1
					ForRate=0
					DamageMult=1
					AccMult=2
					BeamTime=5
					Distance=5
					Immediate=1
					ChainBeam=1
					Striking=1
					Cooldown=90
					IconLock='namekarm.dmi'
					verb/Mystic_Attack()
						set category="Skills"
						if(usr.Beaming==2)
							return
						usr.UseProjectile(src)
				//relic
				BeamPunchProjectile
					DamageMult=1
					Dodgeable=0
					Knockback=2
					BeamTime=20
					Distance=20
					IconLock='Beam21.dmi'

////UNIVERSAL
//T1 is up above
//T2 is up above
//T3 has damage mult 3 - 5.
				Ray
					SkillCost=120
					Copyable=3
					Distance=30
					DamageMult=1
					ChargeRate=1.5
					Knockback=1
					BeamTime=20
					IconLock='Beam8.dmi'
					Cooldown=90
					EnergyCost=1
					verb/Ray()
						set category="Skills"
						usr.UseProjectile(src)
				Eraser_Gun
					NewCost = TIER_2_COST
					NewCopyable = 3
					SkillCost=120
					Copyable=4
					Distance=50
					DamageMult=1
					ChargeRate=2
					Knockback=1
					BeamTime=50
					IconLock='Beam20.dmi'
					Cooldown=60
					EnergyCost=1.5
					verb/Eraser_Gun()
						set category="Skills"
						usr.UseProjectile(src)
				Shine_Ray
					NewCost = TIER_2_COST
					NewCopyable = 3
					SkillCost=120
					Copyable=4
					Distance=15
					DamageMult=7
					ChargeRate=0
					Knockback=0
					BeamTime=20
					IconLock='Beam8.dmi'
					Cooldown=60
					EnergyCost=1.5
					Immediate=1
					verb/Shine_Ray()
						set category="Skills"
						usr.UseProjectile(src)
				Gamma_Ray
					NewCost = TIER_2_COST
					NewCopyable = 3
					SkillCost=120
					Copyable=4
					DamageMult=0.75
					ChargeRate=5
					Distance=50
					Knockback=1
					BeamTime=20
					IconLock='Beam17Dark.dmi'
					Cooldown=60
					EnergyCost=1.5
					verb/Gamma_Ray()
						set category="Skills"
						usr.UseProjectile(src)
				Piercer_Ray
					NewCost = TIER_2_COST
					NewCopyable = 3
					SkillCost=120
					Copyable=4
					DamageMult=7
					Distance=50
					ChargeRate=1
					Knockback=0
					BeamTime=30
					IconLock='Makkankosappo.dmi'
					Cooldown=60
					EnergyCost=1.5
					Piercing=1
					Instinct=1
					verb/Piercer()
						set category="Skills"
						usr.UseProjectile(src)
//T4 is above and also in Autohits.

//T5 has damage mult 5, usually.
				The_Original_Kamehameha
					AdaptRate = 1
					DamageMult=2
					ChargeRate = 8
					Dodgeable = 0
					IconLock='BeamKHH.dmi'
					Instinct=4
					Knockback=2
					BeamTime=12
					Distance=30
					Immediate=1
				Kamehameha//Well rounded
					SignatureTechnique=1
					AdaptRate=1
					DamageMult=12
					ChargeRate=2
					Dodgeable=0
					IconLock='BeamKHH.dmi'
					Cooldown=150
					EnergyCost=5
					Instinct=1
					verb/Kamehameha()
						set category="Skills"
						usr.UseProjectile(src)
				Motionless_Kamehameha//Well rounded
					PreRequisite=list("/obj/Skills/Projectile/Beams/Kamehameha")
					SignatureTechnique=1
					AdaptRate=1
					DamageMult=16
					Immediate=1
					Dodgeable=0
					IconLock='BeamKHH.dmi'
					Cooldown=150
					EnergyCost=5
					Instinct=1
					verb/Motionless_Kamehameha()
						set category="Skills"
						usr.UseProjectile(src)

				Galic_Gun
					SignatureTechnique=1
					AdaptRate=1
					DamageMult=5
					ChargeRate=1.5
					Dodgeable=0
					IconLock='BeamGG.dmi'
					Cooldown=150
					EnergyCost=5
					Instinct=1
					verb/Galic_Gun()
						set category="Skills"
						usr.UseProjectile(src)
				Final_Crash
					PreRequisite=list("/obj/Skills/Projectile/Beams/Galic_Gun")
					SignatureTechnique=1
					DamageMult=5
					Immediate=1
					Dodgeable=0
					IconLock='BeamGG.dmi'
					Cooldown=150
					EnergyCost=5
					Instinct=1
					verb/Final_Crash()
						set category="Skills"
						usr.UseProjectile(src)

				Dodompa//Penetrate, high charge and low distance
					SignatureTechnique=1
					DamageMult=5
					ChargeRate=4
					EndRate=0.75
					Dodgeable=0
					Distance=10
					IconLock='BeamDodon.dmi'
					Cooldown=150
					EnergyCost=5
					Instinct=1
					verb/Dodompa()
						set category="Skills"
						usr.UseProjectile(src)
				Killer_Shine
					PreRequisite=list("/obj/Skills/Projectile/Beams/Dodompa")
					SignatureTechnique=1
					DamageMult=5
					ChargeRate=0
					EndRate=0.75
					Dodgeable=0
					Distance=10
					IconLock='BeamDodon.dmi'
					Cooldown=150
					EnergyCost=7.5
					Instinct=1
					Immediate=1
					verb/Killer_Shine()
						set category="Skills"
						usr.UseProjectile(src)
//T6 will be in Big Beams.

//FUSION TECH
				Galic_Kamehameha
					DamageMult=8
					ChargeRate=3
					IconLock='BeamGKH.dmi'
					ChargeIcon=1
					EnergyCost=15
					Cooldown=300
					Instinct=2
					verb/Galic_Kamehameha()
						set category="Skills"
						usr.UseProjectile(src)
//TIER S
//SAINT SEIYA
				Saint_Seiya
					Soaring_Mountain_Dragon
						AttackReplace=1
						CosmoPowered=0
						AdaptRate=1
						EndRate=0.25
						DamageMult=21
						MultiHit=4
						BeamTime=7
						Immediate=1
						Dodgeable=0
						Piercing=0
						Striking=0
						Knockback=3
						Distance=20
						IconLock='Rozan_Beam.dmi'
						IconSize=1
						LockX=0
						LockY=0
						ChargeIcon=1
						ChargeMessage="focuses their Cosmo in a form of a fierce beast!"
						ActiveMessage="unleashes the power of the Dragon with a straight strike!"
						Cooldown=150
						verb/Soaring_Mountain_Dragon()
							set category="Skills"
							set name="Rozan Ryu Hishou"
							usr.UseProjectile(src)
					Soaring_Dragon_Lord
						CosmoPowered=0
						StrRate=1
						EndRate=0.25
						DamageMult=21
						BeamTime=15
						Dodgeable=0
						Deflectable=0
						Immediate=1
						Piercing=1
						Striking=1
						Knockback=1
						Distance=50
						IconLock='Rozan_Beam.dmi'
						IconSize=1
						LockX=0
						LockY=0
						ChargeIcon=1
						ChargeMessage="focuses their Cosmo in a form of a fierce beast!"
						ActiveMessage="unleashes the power of the Dragon with a straight strike!"
						Cooldown=150
						verb/Soaring_Dragon_Lord()
							set category="Skills"
							set name="Rozan Ryu Hishou"
							usr.UseProjectile(src)
					Nebula_Chain
						NeedsSword=1
						density=1
						StrRate=0.75
						ForRate=0.75
						DamageMult=6
						Speed=1
						AccMult = 1.15
						Crippling = 5
						BeamTime=7
						Distance=7
						Immediate=1
						ChainBeam=1
						Striking=1
						IconLock='Chain.dmi'
						ActiveMessage="unleashes their Nebula Chain to keep their foes away!"
						Cooldown=30
						verb/Nebula_Chain()
							set category="Skills"
							if(usr.Beaming==4)
								return
							usr.UseProjectile(src)
				Big
					AllOutAttack=1
					Radius=1
					Dodgeable=-1
					Knockback=1
					Super_Dodompa//Penetrate, high charge and low distance
						PreRequisite=list("/obj/Skills/Projectile/Beams/Dodompa")
						SignatureTechnique=2
						DamageMult=8
						ChargeRate=5
						Distance=15
						IconLock='BeamDodon.dmi'
						IconSize=1.5
						Cooldown=180
						EnergyCost=10
						verb/Super_Dodompa()
							set category="Skills"
							usr.UseProjectile(src)

					Super_Kamehameha
						PreRequisite=list("/obj/Skills/Projectile/Beams/Kamehameha")
						StrRate = 1
						ForRate = 0
						SignatureTechnique=2
						DamageMult=8
						ChargeRate=3
						Distance=60
						IconLock='BeamKHH.dmi'
						IconSize=2
						Cooldown=180
						BeamTime=50
						EnergyCost=10
						verb/Super_Kamehameha()
							set category="Skills"
							usr.UseProjectile(src)
					True_Kamehameha
						AttackReplace=1
						StrRate = 1
						ForRate = 0
						DamageMult=9
						Distance=60
						IconLock='BeamKHH.dmi'
						IconSize=2
						EnergyCost=15
						Cooldown=0
						BeamTime=1

					Final_Flash
						SignatureTechnique=2
						DamageMult=8
						ChargeRate=2
						Distance=60
						IconLock='BeamDodon.dmi'
						IconSize=2
						EnergyCost=20
						Cooldown=180
						BeamTime=50
						verb/Final_Flash()
							set category="Skills"
							usr.UseProjectile(src)
					Final_Shine
						DamageMult=9
						Distance=60
						IconLock='BeamFS.dmi'
						IconSize=2
						EnergyCost=15
						Cooldown=0
						BeamTime=50

					Super_Dragon_Beam
						AttackReplace=1
						StrRate=1
						ForRate=1
						DamageMult=12
						BeamTime=50
						Immediate=1
						Knockback=1
						Piercing=1
						Stunner=1
						Distance=150
						IconLock='DragonFist.dmi'
						IconSize=1
						LockX=-16
						LockY=-16

//FUSION TECHS
					Final_Kamehameha
						DamageMult=15
						ChargeRate=4
						Distance=150
						IconLock='BeamKHH.dmi'
						IconSize=2
						ChargeIcon=1
						EnergyCost=30
						Cooldown=360
						verb/Final_Kamehameha()
							set category="Skills"
							usr.UseProjectile(src)

					Big_Bang_Kamehameha
						AttackReplace=1
						Area="Blast"
						Charge=1
						DamageMult=16
						Speed=0
						Knockback=30
						Piercing=1
						Variation=0
						IconLock='SupernovaBlue.dmi'
						IconSize=0.05
						LockX=-158
						LockY=-169
						IconChargeOverhead=1/32
						IconSizeGrowTo=0.3
						Trail='TrailBBK.dmi'
						TrailSize=1
						Cooldown=360
						verb/Big_Bang_Kamehameha()
							set category="Skills"
							usr.UseProjectile(src)

					Saint_Seiya
						Aurora_Execution
							CosmoPowered=1
							GodPowered=0.25
							Stream=2
							EndRate=1
							DamageMult=10
							ChargeRate=2.5
							Knockback=0
							Radius=0
							Piercing=1
							AbsoluteZero=1
							Stunner=4
							Freezing=4
							Distance=50
							BeamTime=50
							IconLock='SnowBurst.dmi'
							IconSize=1
							IconVariance=1
							LockX=0
							LockY=0
							Variation=16
							ChargeIcon='AquariusPot.dmi'
							ChargeIconX=-8
							ChargeIconY=14
							ChargeMessage="raises their arms and locks their hands above their head..."
							ActiveMessage="unleashes the power of Aquarius, flooding their opponent with absolute zero cold!"
							Cooldown=150
							verb/Aurora_Execution()
								set category="Skills"
								if(usr.SagaLevel<5 && usr.Health>15 && !usr.InjuryAnnounce)
									usr << "You can't use this technique except when in a dire pinch!"
									return
								usr.UseProjectile(src)
						Beam_of_Libra
							UnarmedOnly=1
							GodPowered=0.25
							DamageMult=9
							StrRate=1
							ForRate=0
							EndRate=1
							Dodgeable=-1
							Radius=1
							density=1
							ChainBeam=1
							Striking=1
							Immediate=1
							Distance=3
							BeamTime=3
							Knockback=1
							ActiveMessage="uses the three-pronged staff to deliver a light-speed thrust!"
							IconLock='ChainLibra.dmi'
							Cooldown=150
							verb/Beam_of_Libra()
								set category="Skills"
								usr.UseProjectile(src)
					Weapon_Soul
						Excalibur
							DamageMult=9
							ChargeRate=5
							StrRate=1
							ForRate=1
							EndRate=1
							Distance=40
							Dodgeable=-1
							Deflectable=-1
							ManaCost=5
							ABuffNeeded="Soul Resonance"
							Cooldown=-1
							verb/Excalibur()
								set category="Skills"
								usr.UseProjectile(src)
					Jagan
						Dragon_of_the_Darkness_Flame
							DamageMult=7
							ChargeRate=3
							StrRate=1
							ForRate=1
							EndRate=1
							Distance=40
							Dodgeable=-1
							WoundCost=5
							MaimCost=1
							IconSize=1.5
							Scorching=1
							Toxic=1
							IconLock='DOTDF-Beam.dmi'
							LockX=0//these are
							LockY=0//fkcuk
							Cooldown=300
							verb/Dragon_of_the_Darkness_Flame()
								set category="Skills"
								usr.UseProjectile(src)
					Vaizard
						Cero
							DamageMult=6
							ChargeRate=3
							Cooldown=300
							ManaCost=2
							Distance=40
							IconLock='Cero2.dmi'
							IconSize=2
							LockX=0
							LockY=0
							SBuffNeeded="Vaizard Mask"
							verb/Cero()
								set category="Skills"
								usr.UseProjectile(src)
					Eight_Gates
						Daytime_Tiger
							UnarmedOnly=1
							DamageMult=4
							StrRate=1
							ForRate=0
							EndRate=1
							BeamTime=10
							Immediate=1
							GateNeeded=7
							Distance=60
							Dodgeable=-1
							Deflectable=-1
							IconLock='BeamBig8.dmi'
							LockX=-16
							LockY=-16
							Cooldown=10800
							verb/Daytime_Tiger()
								set category="Skills"
								usr.UseProjectile(src)
					Ansatsuken
						Denjin_Hadookie
							ManaCost=100
							UnarmedOnly=1
							DamageMult=6
							ChargeRate=3
							StrRate=1
							ForRate=1
							EndRate=1
							Distance=60
							Dodgeable=-1
							Deflectable=-1
							BeamTime=50
							IconLock='BeamBig5.dmi'
							LockX=-16
							LockY=-16
							Cooldown=-1
							SBuffNeeded="Denjin Renki"
							Paralyzing=1
							verb/Denjin_Hadookie()
								set category="Skills"
								usr<<"Why? lol"


////Racials
				Static_Stream
					Dodgeable=0
					BeamTime=5
					Immediate=1
					DamageMult=5
					Distance=20
					Paralyzing=2
					Cooldown=90
					StrRate=0.5
					EndRate=1
					ForRate=0.5
					IconLock='LightningWave.dmi'
					verb/Static_Stream()
						set category="Skills"
						usr.UseProjectile(src)
				Ice_Dragon
					Dodgeable=0
					BeamTime=5
					Immediate=1
					DamageMult=5
					Distance=20
					Freezing=0.2
					Cooldown=90
					IconLock='Ice Beam.dmi'
					IconSize=1
					LockX=0
					LockY=0
					verb/Ice_Dragon()
						set category="Skills"
						usr.UseProjectile(src)
			Shard_Storm
				StrRate=1
				EndRate=1
				ForRate=0
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
				verb/Shard_Storm()
					set category="Skills"
					if(!altered)
						Blasts = 6 + (usr.AscensionsAcquired)
						DamageMult = 2.5 + (usr.AscensionsAcquired * 1.5)
						Radius = clamp(usr.AscensionsAcquired, 1, 5)
						Shattering = 2 + clamp(usr.AscensionsAcquired*2, 0.5, 2.5)
						DamageMult = DamageMult/Blasts
						Cooldown = 60 - ( 5 * usr.AscensionsAcquired)
					usr.UseProjectile(src)

//Moonlight Greatsword
				Moonlight_Wave
					ForRate=1.5
					Blasts=1
					DamageMult=5
					AccMult=1
					IconLock="MoonWave.dmi"
					Variation=6
					Cooldown=10
					AttackReplace=1



mob
	proc
		UseProjectile(var/obj/Skills/Projectile/Z)
			. = TRUE
			if(src.passive_handler.Get("Silenced"))
				src << "You can't use [Z] you are silenced!"
				return FALSE
			if(src.passive_handler.Get("HotHundred") || src.passive_handler.Get("Warping") || (src.AttackQueue && src.AttackQueue.Combo))
				Z.while_warping = TRUE
			else
				Z.while_warping = FALSE
			if(src.Stasis)
				return FALSE
			if(!Z.heavenlyRestrictionIgnore&&Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Projectiles"))
				return FALSE
			if(!Z.heavenlyRestrictionIgnore&&Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("All Skills"))
				return FALSE
			if(!Z.heavenlyRestrictionIgnore&&Z.NeedsSword && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Armed Skills"))
				return FALSE
			if(!Z.heavenlyRestrictionIgnore&&Z.UnarmedOnly && Secret=="Heavenly Restriction" && secretDatum?:hasRestriction("Unarmed Skills"))
				return FALSE
			if(Z.Sealed)
				src << "You can't use [Z] it is sealed!"
				return FALSE
			var/obj/Items/check = EquippedFlyingDevice()
			if(istype(check))
				check.ObjectUse(src)
				src << "You are knocked off your flying device!"
			if(Z.Continuous&&Z.ContinuousOn)
				Z.ContinuousOn=0

				src.ContinuousAttacking=0
				if(src.TomeSpell(Z))
					Z.Cooldown()
				else
					Z.Cooldown()
			if(Z.MagicNeeded&&!src.HasLimitlessMagic())
				// find people in a zone, if the person in the zone has counterspell up and is not in the party, then return and go on cooldown
				for(var/mob/x in orange(5, src))
					if(x in party)
						continue
					if(x.client)
						if(x.passive_handler.Get("CounterSpell"))
							if(x.Target==src)
								src << "Your [Z] was countered!"
								Z.Cooldown()
								return 0
				if(src.HasMechanized()&&src.HasLimitlessMagic()!=1)
					src << "You lack the ability to use magic!"
					return
				if(Z.Copyable>=3||!Z.Copyable)
					if(passive_handler.Get("Disarmed"))
						src << "You are disarmed you can't use [Z]."
						return
					if(!src.HasSpellFocus(Z))
						src << "You need a spell focus to use [Z]."
						return 0
			if(Z.AssociatedGear)
				if(!Z.AssociatedGear.InfiniteUses)
					if(Z.Integrated)
						if(Z.AssociatedGear.IntegratedUses<=0)
							usr << "Your [Z] is out of power!"
							if(src.ManaAmount>10)
								src << "Your integrated [Z] automatically replinishes its power!"
								src.LoseMana(10)
								Z.AssociatedGear.IntegratedUses=Z.AssociatedGear.IntegratedMaxUses
							return 0
					else
						if(Z.AssociatedGear.Uses<=0)
							usr << "Your [Z] is out of power!"
							return 0
			if(!Z.Charging)//Only beams get this exception
				if(!src.CanAttack(3)&&!Z.AttackReplace)
					return 0
				if(Z.Using)
					return 0
				if(Z.ZoneAttack&&Z.FireFromEnemy)
					if(!src.Target)
						src << "You need a target to use this."
						return FALSE
					if(src.z!=src.Target.z)
						src << "You have to be on the same z-plane to use this technique."
						return FALSE
					if(src.Target.x>src.x+50||src.Target.x<src.x-50||src.Target.y>src.y+50||src.Target.y<src.y-50)
						src << "They're out of range..."
						return FALSE
					if(src.Target==src)
						src << "You can't target yourself to use this."
						return FALSE
				if(Z.MultiShots==0)
					if(!Z.AllOutAttack)
						if(Z.HealthCost)
							if(src.Health<Z.HealthCost*glob.WorldDamageMult)
								return 0
						if(Z.WoundCost)
							if(src.TotalInjury+Z.WoundCost*glob.WorldDamageMult>99)
								return 0
						if(Z.EnergyCost)
							var/drain = passive_handler["Drained"] ? Z.EnergyCost * (1 + passive_handler["Drained"]/10) : Z.EnergyCost
							if(src.Energy<drain)
								if(!src.CheckSpecial("One Hundred Percent Power")&&!src.CheckSpecial("Fifth Form")&&!CheckActive("Eight Gates"))
									return 0
						if(Z.FatigueCost)
							if(src.TotalFatigue+Z.FatigueCost>99)
								return 0
						if(Z.ManaCost && !src.HasDrainlessMana())
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
						if(Z.CapacityCost)
							if(src.TotalCapacity+Z.CapacityCost>99)
								return
						if(Z.CorruptionCost)
							if(Corruption - Z.CorruptionCost < 0)
								src << "You don't have enough Corruption to activate [Z]"
								return FALSE

			if(Z.NeedsSword)
				if(passive_handler.Get("Disarmed"))
					src << "You are disarmed you can't use [Z]."
					return

				if(!src.EquippedSword())
					if(passive_handler.Get("Disarmed") && HasBladeFisting())
						src << "You are disarmed you can't use [Z]."
						return
					if(!src.HasBladeFisting()&& !src.UsingBattleMage())
						src << "You need a sword to use this technique!"
						return

			if(Z.UnarmedOnly)
				if(src.EquippedSword())
					if(!src.HasBladeFisting())
						src << "You can't use a sword with this technique!"
						return
				if(src.UsingBattleMage())
					src << "You can't use unarmed moves while using Battle Mage!"
					return
			if(Z.StaffOnly)
				var/obj/Items/Sword/s=src.EquippedSword()
				var/Pass=0
				if(src.EquippedStaff())
					Pass=1
				if(s)
					if(s.MagicSword)
						Pass=1
				if(passive_handler.Get("Disarmed"))
					src << "You are disarmed you can't use [Z]."
					return
				if(!Pass)
					src << "You need a staff to use this technique!"
					return
			if(Z.StanceNeeded)
				if(src.StanceActive!=Z.StanceNeeded)
					src << "You have to be in [Z.StanceNeeded] stance to use this!"
					return
			if(Z.StyleNeeded)
				if(src.StyleActive!=Z.StyleNeeded)
					src << "You have to be using [Z.StyleNeeded] style to use this!"
					return
			if(Z.ABuffNeeded)
				if(!src.ActiveBuff||src.ActiveBuff.BuffName!=Z.ABuffNeeded)
					src << "You have to be in [Z.ABuffNeeded] state!"
					return
			if(Z.SBuffNeeded)
				if(Z.SBuffNeeded==-1)
					if(src.SpecialBuff)
						src << "You need to shed your special empowerments!"
						return
				else
					if(!src.SpecialBuff||src.SpecialBuff.BuffName!=Z.SBuffNeeded)
						src << "You have to be in [Z.SBuffNeeded] state!"
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
			if(passive_handler["WaveDancer"])
				if(can_use_style_effect("WaveDancer")) // could tie this simply to the ability. but w/e
					// we throw here
					var/obj/Skills/AutoHit/Water_Wave/ww = FindSkill(/obj/Skills/AutoHit/Water_Wave)
					if(!ww)
						ww = new()
						AddSkill(ww)
					Activate(ww)
					last_style_effect = world.time
			if(passive_handler["BloodEruption"] && Target)
				if(can_use_style_effect("BloodEruption"))
					var/be = passive_handler["BloodEruption"]
					for(var/turf/T in Turf_Circle(Target, be))
						if(!T.density)
							CHECK_TICK
							var/obj/leftOver/Blood/b = new(T, src, be)
							T.applyLeftOver(src, b, b.lifetime)
					last_style_effect = world.time
			if(Z.StormFall)
				Z.Homing=0//You can't home if you're just going down, down, in an earlier round...
			if(Z.Blasts<1)
				Z.Blasts=1
			if(Z.Area=="Blast"&&(!Z.Continuous))
				if(Z.MultiShot)
					Z.MultiShots++
					if(Z.MultiShots>=Z.MultiShot)
						Z.MultiShots=0
						if(src.TomeSpell(Z))
							Z.Cooldown()
						else
							Z.Cooldown(p = src)
				else
					if(src.TomeSpell(Z))
						Z.Cooldown()
					else
						Z.Cooldown(p = src)
			if(Z.Copyable)
				spawn() for(var/mob/m in view(10, src))
					if(m.CheckSpecial("Sharingan"))
						var/copy = Z.Copyable
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
						if(m.client&&m.client.address==src.client.address)
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

			if(Z.Charge)
				if(Z.TurfShift)
					for(var/turf/t in Turf_Circle(src, Z.Distance/2))
						sleep(-1)
						TurfShift(Z.TurfShift, t, (Z.Delay*Z.Blasts), src)
				if(!Z.IconChargeOverhead)
					if(Z.CustomCharge)
						OMsg(src, "[Z.CustomCharge]")
					else
						if(Z.ChargeMessage)
							OMsg(src, "<b><font color='[Z.ChargeColor]'>[src] [Z.ChargeMessage]</font color></b>")
					src.Beaming=0.5
					if(!Z.ChargeIcon)
						src.Chargez("Add")
						if(src.HasQuickCast())
							sleep(10*Z.Charge/src.GetQuickCast()*(1+(src.GetKiControlMastery()*0.1)))
						else
							sleep(10*Z.Charge*(1+(src.GetKiControlMastery()*0.1)))
						src.Chargez("Remove")
					else
						if(Z.ChargeIcon!=1)
							if(Z.ChargeIconUnder)
								src.Chargez("Add", image(icon=Z.ChargeIcon, pixel_x=Z.ChargeIconX, pixel_y=Z.ChargeIconY), 1)
							else
								src.Chargez("Add", image(icon=Z.ChargeIcon, pixel_x=Z.ChargeIconX, pixel_y=Z.ChargeIconY), 0)
							if(src.HasQuickCast())
								sleep(10*Z.Charge/src.GetQuickCast()*(1+(src.GetKiControlMastery()*0.1)))
							else
								sleep(10*Z.Charge*(1+(src.GetKiControlMastery()*0.1)))
							src.Chargez("Remove", image(icon=Z.ChargeIcon, pixel_x=Z.ChargeIconX, pixel_y=Z.ChargeIconY))
						else
							if(!src.AuraLocked&&!src.HasKiControl())
								src.Auraz("Add")
							else
								KenShockwave(src,icon='KenShockwaveFocus.dmi',Size=0.3, Blend=2, Time=2)
							if(src.HasQuickCast())
								sleep(10*Z.Charge/src.GetQuickCast()*(1+(src.GetKiControlMastery()*0.1)))
							else
								sleep(10*Z.Charge*(1+(src.GetKiControlMastery()*0.1)))

							if(!src.AuraLocked&&!src.HasKiControl())
								src.Auraz("Remove")
					src.Beaming=0
			if(Z.Continuous)
				if(Z.CustomActive)
					OMsg(src, "[Z.CustomActive]")
				else
					if(Z.ActiveMessage)
						OMsg(src, "<b><font color='[Z.ActiveColor]'>[src] [Z.ActiveMessage]</font color></b>")
			var/atom/Origin=src//This is the mob or turf that an attack will come from.
			var/obj/Items/Enchantment/Staff/staf=src.EquippedStaff()
			var/obj/Items/Sword/sord=src.EquippedSword()
			var/obj/Items/Armor/armr = src.EquippedArmor()
			var/Drain
			if(staf)
				Drain=src.GetStaffDrain(staf)
			else if(sord&&sord.MagicSword)
				Drain=src.GetSwordDelay(sord)
			else
				Drain=1
			if(armr)
				Drain/=src.GetArmorDelay(armr)
			if(Z.Buster&&Z.Area=="Beam")
				src << "[Z] has been flagged as a buster technique as well as a beam. These two traits are not meant to be combined."
				return
			if(Z.Buster)
				if(!Z.Charging)
					src.BusterCharging=1
					src.BusterTech=Z
					Z.Charging=1

					if(Z.ChargeIcon)
						src.Chargez("Add", image(icon=Z.ChargeIcon, pixel_x=Z.ChargeIconX, pixel_y=Z.ChargeIconY))
					else
						src.Chargez("Add")

					if(Z.CustomCharge)
						OMsg(src, "[Z.CustomCharge]")
					else
						if(Z.ChargeMessage)
							OMsg(src, "<b><font color='[Z.ChargeColor]'>[src] [Z.ChargeMessage]</font color></b>")

				else if(Z.Charging)
					Z.Charging=0
					if(Z.ChargeIcon)
						src.Chargez("Remove", image(icon=Z.ChargeIcon, pixel_x=Z.ChargeIconX, pixel_y=Z.ChargeIconY))
					else
						src.Chargez("Remove")

					if(Z.CustomActive)
						OMsg(src, "[Z.CustomActive]")
					else
						if(Z.ActiveMessage)
							OMsg(src, "<b><font color='[Z.ActiveColor]'>[src] [Z.ActiveMessage]</font color></b>")

					if(src.BusterCharging==100)//100% charge only!!
						Z.TempRadius=Z.BusterRadius
						Z.TempSize=Z.BusterSize
						Z.TempStream=Z.BusterStream
					//these will always be used
					// Z.TempDamage=Z.DamageMult+((Z.BusterDamage-Z.DamageMult) * (src.BusterCharging/100))
					// Z.TempHits=round(Z.MultiHit+(Z.BusterHits-Z.MultiHit) * (src.BusterCharging/100))
					// Z.TempAccuracy=Z.AccMult+((Z.BusterAccuracy-Z.AccMult) * (src.BusterCharging/100))

					src.BusterTech=null
					src.BusterCharging=0

			if(Z.Area=="Beam")
				if(src.AttackQueue && (src.AttackQueue.Counter + src.AttackQueue.CounterTemp))
					src << "<b>You drop [src.AttackQueue.name] from your queue.</b>"
					src.QueueOverlayRemove()
					src.ClearQueue()
				if(!Z.Charging&&!src.Beaming&&!Z.Immediate)
					src.BeamCharge(Z)
					if(Z.CustomCharge)
						OMsg(src, "[Z.CustomCharge]")
					else
						if(Z.ChargeMessage)
							OMsg(src, "<b><font color='[Z.ChargeColor]'>[src] [Z.ChargeMessage]</font color></b>")
				else if(Z.Charging&&src.Beaming==1||Z.Immediate&&!src.Beaming)
					if(Z.Immediate)
						Z.Charging=1
						src.BeamCharging=1
					if(Z.BeamTime)
						Z.BeamTimeUsed=0
					src.Beaming=2
					if(Z.ChargeIcon)
						src.Chargez("Remove", image(icon=Z.ChargeIcon, pixel_x=Z.ChargeIconX, pixel_y=Z.ChargeIconY))
					else
						src.Chargez("Remove")
					if(Z.CustomActive)
						OMsg(src, "[Z.CustomActive]")
					else
						if(Z.ActiveMessage)
							OMsg(src, "<b><font color='[Z.ActiveColor]'>[src] [Z.ActiveMessage]</font color></b>")
					if(Z.FlickBlast)
						src.icon_state="Blast"
					while(src.Beaming==2)
						src.Blast(Z, Origin)
						var/StreamEffective=Z.Stream
						if(Z.TempStream)
							StreamEffective=Z.TempStream
						for(var/s=StreamEffective-1, s>0, s--)
							src.Blast(Z, Origin)//Higher levels of stream shoot more blasts.
						sleep(Z.Speed)
						if(Z.BeamTime)
							Z.BeamTimeUsed++
						if(src.KO||src.Knockbacked||Z.ManaCost&&src.ManaAmount<=0||Z.EnergyCost&&src.Energy<=5||(Z.BeamTime>0&&Z.BeamTimeUsed>=Z.BeamTime))
							src.UseProjectile(Z)
					src.BeamCharging=0
				else if(src.Beaming==2)
					src.BeamStop(Z)
					if(Z.EnergyCost)
						var/drain = passive_handler["Drained"] ? Z.EnergyCost * (1 + passive_handler["Drained"]/10) : Z.EnergyCost
						src.LoseEnergy((drain)/Drain)
					if(Z.ManaCost)
						var/drain = src.passive_handler.Get("MasterfulCasting") ? Z.ManaCost - (Z.ManaCost * (passive_handler.Get("MasterfulCasting") * 0.3)) : Z.ManaCost
						if(drain <= 0)
							drain = 0.5
						if(src.TomeSpell(Z))
							src.LoseMana(drain*(1-(0.45*src.TomeSpell(Z)))/Drain)
						else
							src.LoseMana(drain/Drain)
			if(Z.Stream&&Z.Area=="Blast")
				src.Beaming=2
				spawn(10)
					src.Beaming=0
				if(Z.FlickBlast)
					src.icon_state="Blast"
			if(Z.Continuous)
				if(!Z.ContinuousOn)
					Z.ContinuousOn=1
					src.ContinuousAttacking=1
					Z.BlastsShot=0
			if(Z.Area=="Blast" && (!Z.Buster||(Z.Buster&&Z.Charging==0)))
				var/BlastCount=Z.Blasts
				if(Z.MagicNeeded&&src.HasDualCast())
					BlastCount *= 1 + src.HasDualCast()
					BlastCount = floor(BlastCount)
				for(var/i=0, i<BlastCount, i++)
					BlastAgain
				//	if(!src.Target) break
					if(Z.Homing||Z.LosesHoming)
						if(Target)
							src.dir=get_dir(src,src.Target)
					if(Z.Feint&&src.Target&&src.Target!=src)
						AfterImage(src)
						src.Comboz(src.Target)
						src.dir=get_dir(src,src.Target)
					if(Z.ZoneAttack)
						var/LocateAttempts=0
						Relocate
						if(Z.FireFromEnemy && Target)
							Origin=locate(src.Target.x+rand((-1*Z.ZoneAttackX),Z.ZoneAttackX), src.Target.y+rand((-1*Z.ZoneAttackY),Z.ZoneAttackY), src.z)
						else if(Z.FireFromSelf)
							Origin=locate(src.x+rand((-1*Z.ZoneAttackX),Z.ZoneAttackX), src.y+rand((-1*Z.ZoneAttackY),Z.ZoneAttackY), src.z)
						if(!istype(Origin,/turf))
							LocateAttempts++
							if(LocateAttempts<5)
								goto Relocate
					if(i==0)
						src.Blast(Z, Origin, GivesMessage=1)
					else
						src.Blast(Z, Origin, GivesMessage=0)
					if(Z.Stream)
						var/StreamEffective=Z.Stream
						if(Z.TempStream)
							StreamEffective=Z.TempStream
						for(var/s=StreamEffective-1, s>0, s--)
							src.Blast(Z, Origin)//Higher levels of stream shoot more blasts.
					if(Z.Continuous)
						if(Z.ContinuousOn)
							if(Z.EnergyCost)
								var/drain = passive_handler["Drained"] ? Z.EnergyCost * (1 + passive_handler["Drained"]/10) : Z.EnergyCost
								src.LoseEnergy(drain/10/Drain)
							if(Z.ManaCost)
								if(Z.ManaCost)
									var/drain = src.passive_handler.Get("MasterfulCasting") ? Z.ManaCost - (Z.ManaCost * (passive_handler.Get("MasterfulCasting") * 0.3)) : Z.ManaCost
									if(drain <= 0)
										drain = 0.5
									if(src.TomeSpell(Z))
										src.LoseMana(drain*(1-(0.45*src.TomeSpell(Z)))/10/Drain)
									else
										src.LoseMana(drain/10/Drain)
							if(Z.AssociatedGear)
								if(Z.Integrated)
									Z.AssociatedGear.IntegratedUses--
									if(Z.AssociatedGear.IntegratedUses<1)
										Z.ContinuousOn=0
										if(Z.AssociatedGear.InfiniteUses)
											Z.AssociatedGear.IntegratedUses=Z.AssociatedGear.IntegratedMaxUses
										else if(src.ManaAmount>=10)
											src << "Your [Z] automatically replenishes itself!"
											src.LoseMana(10)
											Z.AssociatedGear.IntegratedUses=Z.AssociatedGear.IntegratedMaxUses
								else
									Z.AssociatedGear.Uses--
									if(Z.AssociatedGear.Uses<1)
										Z.ContinuousOn=0
										if(Z.AssociatedGear.InfiniteUses)
											Z.AssociatedGear.Uses=Z.AssociatedGear.MaxUses
							if(Z.Blasts)
								Z.BlastsShot++
							if(src.KO||Z.ManaCost>=src.ManaAmount||Z.EnergyCost>=src.Energy||Z.BlastsShot>=Z.Blasts)
								src.UseProjectile(Z)//turn off
							else
								flick("Blast", src)
								src.ContinuousAttacking=1
							sleep(1)
							goto BlastAgain
					if(!Z.Stream)
						if(Z.FlickBlast)
							flick("Blast", src)
					if(BlastCount>1&&!Z.Instant)
						sleep(Z.Delay)
			if(Z.Stream&&Z.Area=="Blast")
				src.Beaming=0
				src.icon_state=""
			if(Z.MultiShots==0)
				if(Z.Area!="Beam")
					if(Z.TempDamage)
						Z.TempDamage=0
					if(Z.TempAccuracy)
						Z.TempAccuracy=0
					if(Z.TempRadius)
						Z.TempRadius=0
					if(Z.TempHits)
						Z.TempHits=0
					if(Z.TempStream)
						Z.TempStream=0
					if(Z.TempSize)
						Z.TempSize=0
					if(Z.HealthCost)
						src.DoDamage(src, Z.HealthCost*glob.WorldDamageMult/Drain)
					if(Z.WoundCost)
						src.WoundSelf(Z.WoundCost*glob.WorldDamageMult/Drain)
					if(Z.EnergyCost)
						var/drain = passive_handler["Drained"] ? Z.EnergyCost * (1 + passive_handler["Drained"]/10) : Z.EnergyCost
						src.LoseEnergy(drain/Drain)
					if(Z.FatigueCost)
						src.GainFatigue(Z.FatigueCost/Drain)
					if(Z.ManaCost)
						var/drain = src.passive_handler.Get("MasterfulCasting") ? Z.ManaCost - (Z.ManaCost * (passive_handler.Get("MasterfulCasting") * 0.3)) : Z.ManaCost
						if(drain <= 0)
							drain = 0.5
						if(src.TomeSpell(Z))
							src.LoseMana(drain*(1-(0.45*src.TomeSpell(Z)))/Drain)
						else
							src.LoseMana(drain/Drain)
						if(Z.CorruptionGain)
							gainCorruption((drain) * glob.CORRUPTION_GAIN)
					if(Z.CorruptionCost)
						gainCorruption(-Z.CorruptionCost)
					if(Z.CapacityCost)
						src.LoseCapacity(Z.CapacityCost/Drain)
					if(Z.MaimCost)
						src.Maimed+=Z.MaimCost
						src << "You have been maimed by using the overwhelming power of [Z]!"
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
				else
					if(Z.Charging==0&&src.BeamCharging==0)
						if(Z.HealthCost)
							src.DoDamage(src, Z.HealthCost*glob.WorldDamageMult/Drain)
						if(Z.WoundCost)
							src.WoundSelf(Z.WoundCost*glob.WorldDamageMult/Drain)
						if(Z.EnergyCost)
							var/drain = passive_handler["Drained"] ? Z.EnergyCost * (1 + passive_handler["Drained"]/10) : Z.EnergyCost
							src.LoseEnergy(drain/Drain)
						if(Z.FatigueCost)
							src.GainFatigue(Z.FatigueCost/Drain)
						if(Z.ManaCost)
							var/drain = src.passive_handler.Get("MasterfulCasting") ? Z.ManaCost - (Z.ManaCost * (passive_handler.Get("MasterfulCasting") * 0.3)) : Z.ManaCost
							if(drain <= 0)
								drain = 0.5
							if(src.TomeSpell(Z))
								src.LoseMana(drain*(1-(0.45*src.TomeSpell(Z)))/Drain)
							else
								src.LoseMana(drain/Drain)
						if(Z.CapacityCost)
							src.LoseCapacity(Z.CapacityCost/Drain)
						if(Z.MaimCost)
							src.Maimed+=Z.MaimCost
							src << "You have been maimed by using the overwhelming power of [Z]!"
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

		Blast(var/obj/Skills/Projectile/Z, var/atom/Origin, var/GivesMessage, var/IconUsed)
			new/obj/Skills/Projectile/_Projectile(src, Z, Origin, src.BeamCharging, GivesMessage, IconUsed)


mob/var/tmp/list/active_projectiles = list()
obj
	Skills
		Projectile
			_Projectile//This is the type of the object that actually has an icon and bumps into things.
				var
					Damage//The actual value of the damage
					KillDelay//handles when the projectile is deleted
					Backfire//can the projectile hit the user after certain conditions have been met?
					Killed=0
					VariationX
					VariationY
					list/AlreadyHit
					BeamCharge
					BreathCost
				Savable=0
				density=1
				Grabbable=0
				Health=1#INF
				MultiTrail = 0
				New(var/mob/m, var/obj/Skills/Projectile/Z, var/atom/Origin, var/BeamCharging=0.5, var/GivesMessage, var/IconUsed=0)
					if(m==null||Origin==null)
						endLife()
					AlreadyHit = list()
					animate_movement=SLIDE_STEPS
					if(BeamCharging<0.5)
						BeamCharging=0.5
					src.Owner=m
					if(Owner)
						Owner.active_projectiles |= src
					if(istype(Origin, /turf))
						if(!Z.IconChargeOverhead&&!Z.HyperHoming&&!Z.Continuous&&!Z.ClusterBit)
							src.loc=src.Owner.loc
							walk_to(src,Origin,0,0,32)
						else
							src.loc=Origin
					else
						src.loc=get_step(Origin, Origin.dir)
					src.density=Z.density
					src.Area=Z.Area
					src.DistanceMax=Z.Distance
					src.Distance=Z.Distance
					FoxFire = Z.FoxFire
					if(Z.ChainBeam)
						src.Distance=Z.Distance-Z.BeamTimeUsed
						src.KillDelay=Z.BeamTimeUsed
					if(Z.DistanceVariance)
						src.Distance=round(Z.Distance*GoCrand(0.8,1.2))
					src.Radius=Z.Radius
					if(Z.TempRadius)
						src.Radius=Z.TempRadius
					if(Z.Bounce)
						Bounce = Z.Bounce
						TotalBounce = Z.TotalBounce
						CurrentBounce = 0
					src.HomingCharge=Z.HomingCharge
					src.HomingChargeSpent=0
					src.HomingDelay=Z.HomingDelay
					src.LosesHoming=Z.LosesHoming
					src.DamageMult=Z.DamageMult
					if(Z.TempDamage)
						src.DamageMult=Z.TempDamage
					if(Z.while_warping)
						DamageMult /= glob.WHILEWARPINGNERF
						Z.while_warping = FALSE
					src.AccMult=Z.AccMult
					if(Z.TempAccuracy)
						src.AccMult=Z.TempAccuracy
					Snaring = Z.Snaring
					src.ChargeRate=Z.ChargeRate
					src.ChargeMessage=Z.ChargeMessage
					src.CustomCharge=Z.CustomCharge
					src.ChargeColor=Z.ChargeColor
					src.ActiveMessage=Z.ActiveMessage
					src.CustomActive=Z.CustomActive
					src.ActiveColor=Z.ActiveColor
					src.Deflectable=Z.Deflectable
					src.Dodgeable=Z.Dodgeable
					src.Speed=Z.Speed
					src.Static=Z.Static
					src.StrRate=Z.StrRate
					src.ForRate=Z.ForRate
					src.EndRate=Z.EndRate
					src.MaxMultiHit=Z.MultiHit
					src.MultiHit=Z.MultiHit
					if(Z.TempHits)
						src.MaxMultiHit=Z.TempHits
						src.MultiHit=Z.TempHits
					src.Stunner=Z.Stunner
					src.Launcher=Z.Launcher
					src.Knockback=Z.Knockback
					src.MiniDivide=Z.MiniDivide
					src.CorruptionGain = Z.CorruptionGain
					src.Divide=Z.Divide
					src.Trail=Z.Trail
					src.MultiTrail=Z.MultiTrail
					src.Shearing = Z.Shearing
					src.Crippling = Z.Crippling
					src.TrailX=Z.TrailX
					src.TrailY=Z.TrailY
					src.TrailSize=Z.TrailSize
					src.TrailDuration=Z.TrailDuration
					src.TrailVariance=Z.TrailVariance
					src.Explode=Z.Explode
					src.ExplodeIcon=Z.ExplodeIcon
					src.Striking=Z.Striking
					src.Slashing=Z.Slashing
					src.Piercing=Z.Piercing
					src.PiercingBang=Z.PiercingBang
					src.Cluster=Z.Cluster
					src.ClusterCount=Z.ClusterCount
					src.ClusterAdjust=Z.ClusterAdjust
					src.ClusterDelay=Z.ClusterDelay
					src.Stream=Z.Stream
					src.Burning=Z.Burning
					src.Scorching=Z.Scorching
					src.Chilling=Z.Chilling
					src.Freezing=Z.Freezing
					src.Crushing=Z.Crushing
					src.Shattering=Z.Shattering
					src.Shocking=Z.Shocking
					src.Paralyzing=Z.Paralyzing
					src.Poisoning=Z.Poisoning
					src.Toxic=Z.Toxic
					src.HolyMod=Z.HolyMod
					src.AbyssMod=Z.AbyssMod
					src.SlayerMod=Z.SlayerMod
					src.Devour=Z.Devour
					src.SoulFire=Z.SoulFire
					src.Stasis=Z.Stasis
					src.StormFall=Z.StormFall
					src.Excruciating=Z.Excruciating
					src.MaimStrike=Z.MaimStrike
					src.MortalBlow=Z.MortalBlow
					src.Destructive=Z.Destructive
					src.FollowUp=Z.FollowUp
					src.FollowUpDelay=Z.FollowUpDelay
					src.WarpUser=Z.WarpUser
					src.Backfire=0
					src.FadeOut=Z.FadeOut
					src.GoldScatter = Z.GoldScatter
					BeamCharge = BeamCharging
					var/OldVary=Z.Variation
					if(Z.TempStream)
						Z.Variation/=Z.Stream
						Z.Variation*=Z.TempStream
					src.VariationX=rand((-1*Z.Variation), Z.Variation)
					src.VariationY=rand((-1*Z.Variation), Z.Variation)
					Z.Variation=OldVary
					src.TurfShiftEnd = Z.TurfShiftEnd
					src.TurfShiftEndSize = Z.TurfShiftEndSize
					if(Z.Homing)
						if(src.Owner.Target!=src.Owner)
							src.Homing=src.Owner.Target
					else
						if(src.Owner.HasBetterAim()&&src.Owner.Target!=src.Owner)
							src.Homing=src.Owner.Target
							src.LosesHoming=src.Owner.GetBetterAim()
					src.HyperHoming=Z.HyperHoming
					if(Z.StormFall)
						src.pixel_z=8*Z.StormFall
					if(!IconUsed)
						src.icon=Z.IconLock
						src.pixel_x=Z.LockX
						src.pixel_y=Z.LockY
						if(Z.IconVariance)
							src.icon_state="[rand(1,Z.IconVariance)]"
							src.transform*=GoCrand(0.75,1.25)
						if(Z.takeAppearance)
							appearance = m.appearance
					else
						src.icon=IconUsed
						src.pixel_x=Z.LockX
						src.pixel_y=Z.LockY
					if(Z.IconSize!=1)
						if(Z.TempSize)
							src.transform*=Z.TempSize
						else
							src.transform*=Z.IconSize

					if(src.Owner.HasRipple())
						BreathCost=1*src.DamageMult
						if(Z.AttackReplace==1)
							BreathCost=0.2
						if(src.DamageMult<=1||src.Area=="Beam")
							BreathCost/=20
						src.Owner.Oxygen-=BreathCost
						if(src.Owner.Oxygen<=0)
							src.Owner.Oxygen=0

					if(Z.IconChargeOverhead)//Raise it above ya head like ya just dont caaaahhh
						src.Owner.Beaming=0.5
						var/T
						if(src.Owner.HasQuickCast())
							T=10*Z.Charge/src.Owner.GetQuickCast()*(1/(src.Owner.GetRecov()**(1/2)))
						else
							T=10*Z.Charge*(1/(src.Owner.GetRecov()**(1/2)))
						if(src.CustomCharge)
							OMsg(src.Owner, "[src.CustomCharge]")
						else
							if(src.ChargeMessage)
								OMsg(src.Owner, "<b><font color='[src.ChargeColor]'>[src.Owner] [src.ChargeMessage]</font color></b>")
						src.loc=locate(src.Owner.x, src.Owner.y, src.Owner.z)
						if(Z.IconSizeGrowTo)
							spawn()animate(src, transform=matrix()*Z.IconSizeGrowTo, pixel_z=((Z.IconChargeOverhead*32)-1), time=T, easing=CUBIC_EASING)
						else
							src.pixel_z=(Z.IconChargeOverhead*32)-1
						sleep(T)
						if(src.Owner && src)
							src.Owner.Beaming=0
							src.dir=src.Owner.dir
					if(src.CustomActive&&GivesMessage&&!Z.Continuous)
						OMsg(src.Owner, "[src.CustomActive]")
					else
						if(src.ActiveMessage&&GivesMessage&&!Z.Continuous&&!(Z.MultiShots))
							OMsg(src.Owner, "<b><font color='[src.ActiveColor]'>[src.Owner] [src.ActiveMessage]</font color></b>")
					spawn()
						if(Z.Hover || Hover)
							if(Z.Hover) sleep(Z.Hover)
							else sleep(Hover)
						if(Z.Variation)
							animate(src, pixel_x=src.pixel_x+src.VariationX, pixel_y=src.pixel_y+src.VariationY, time=3)
						walk(src,0)
						if(Z.RandomPath)
							src.RandomPath=Z.RandomPath
							src.dir=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH)
						else if(Z.StormFall)
							src.dir=SOUTH
						else if(Owner)
							src.dir=src.Owner.dir
						if(src.pixel_z>0&&!src.StormFall)
							spawn()
								animate(src,pixel_z=0, time=2)
						if(Z.GrowingLife)
							spawn()
								animate(src,transform=matrix()*Z.IconSizeGrowTo, time=10, easing=CUBIC_EASING)
						if(Z.takeAppearance)
							appearance = m.appearance
						src.Life()
					if(FollowUp)
						if(FollowUpDelay != -1)
							spawn(FollowUpDelay)
								Owner.throwFollowUp(FollowUp)
					if(BuffSelf)
						Owner.buffSelf(BuffSelf)
				Bump(var/atom/a)
					a.onBumped(src)
					Hit(a)
					..()
				proc/endLife()
					try
						Distance = 0
						animate(src)
						if(Homing)
							Homing = null
						if(Owner)
							Owner.active_projectiles -= src
							Owner = null
						loc = null
						for(var/i in vis_contents)
							vis_contents -= i
						for(var/obj/i in vis_locs)
							i.vis_contents -= src
						AlreadyHit = null
						overlays = null
						underlays = null
						filters = null
						transform = null
						AssociatedLegend = null
						AssociatedGear = null
						loc = null
					catch()
					sleep(50)
					del src
				proc/Hit(atom/a, MultDamage=1)
					if(istype(a, /obj/Skills/Projectile/_Projectile))
						if(a.Owner==src.Owner)
							src.loc=a.loc
							return
						else
							if(src.Area=="Beam")
								src.BeamGraphics()
								if(a:Area=="Beam")
									if(src.Owner)
										spawn()
											if(src.Owner)
												src.Owner.Earthquake()
									spawn()
										if(prob(1*src.DamageMult))
											KenShockwave(src,Size=GoCrand(src.DamageMult, 2*src.DamageMult))
							if(src.Devour&&!a:Devour)
								src.Damage+=a:Damage
								a:Damage=0
							else if(a:Devour&&!src.Devour)
								a:Damage+=src.Damage
								src.Damage=0
							else
								src.Damage-=a:Damage

							if(src.Damage<=0)
								ProjectileFinish()
								return
					else if(istype(a, /mob))
						var/mob/m = a
						if(Owner && Owner in m.ai_followers)
							return 1
						if(istype(Owner, /mob/Player/AI) && Owner != m)
							var/mob/Player/AI/ai = Owner
							if(!ai.ai_team_fire && ai.AllianceCheck(m))
								return 1

						if(src.HyperHoming&&src.Homing)
							if(a!=src.Owner.Target)
								if(forcedTarget)
									src.loc = forcedTarget?:loc
								else
									src.loc=a.loc
									return
						if(a==src.Owner&&!src.Backfire)
							src.loc=a.loc
							return
						if(!src.Radius&&src.loc!=a.loc)
							src.loc=a.loc
							return

						if(src.Area=="Beam")
							src.BeamGraphics()

						if(src.Area!="Beam")
							if(a:HasBulletKill()&&a:dir==turn(src.dir, 180))
								var/obj/o=new/obj/Effects/Slash()
								o.loc=src.loc
								src.Killed=1
								ProjectileFinish()
								return

						if(a:EnergyAssimilators&&a:dir==turn(src.dir, 180))
							a:HealMana(1)
							src.Killed=1
							ProjectileFinish()
							return

						var/accmult = AccMult
						var/obj/Items/Enchantment/Staff/staf=Owner.EquippedStaff()
						var/obj/Items/Sword/sord=Owner.EquippedSword()
						var/list/itemMods = list(0,0,0)
						var/issord = FALSE
						var/isproj = FALSE
						if(src.NeedsSword)
							if(sord)
								issord = TRUE
						else
							if(sord&&sord.MagicSword)
								issord = TRUE
							else if(staf)
								isproj = TRUE
						itemMods = Owner.getItemDamage(list(sord,FALSE,FALSE,staf), 0, AccMult, FALSE, FALSE, issord, isproj )
						if(itemMods[2]>0)
							accmult *= itemMods[2]
						if(!a:Stasis)
							var/mob/p = a
							if(p.passive_handler["Neo"]&&!p.HasNoDodge()&&src.Dodgeable>0)
								var/dir=get_dir(src,a)
								if(prob(p.passive_handler["Neo"]*glob.NEO_DODGERATE))
									src.loc = a.loc
									StunClear(a)
									AfterImageStrike(a, src.Owner)
									if(src.Homing)
										src.dir=dir
										src.Homing=0
										if(src.Area!="Beam")
											src.Backfire=1
									return
							if(m.HasFlow()&&!m.HasNoDodge()&&src.Dodgeable>0)
								if(prob(getFlowCalc(Owner, m )) )
									var/dir=get_dir(src,a)
									AfterImage(a)
									if(src.Area=="Beam")
										for(var/obj/Skills/Projectile/Beams/Z in src.Owner)
											if(Z.Charging)
												src.Owner.BeamStop(Z)

									if(istype(src.Owner, /mob/Player/AI/Nympharum))
										return //Flow should work against them. But it's awkward to warp to them.
									a:Move(get_step(src.Owner,turn(dir,pick(-45,45,-90,90,180))))
									StunClear(a)
									WildSense(a, src.Owner,0)
									if(src.Homing)
										src.dir=dir
										src.Homing=0
										if(src.Area!="Beam")
											src.Backfire=1
									if(a:CheckSlotless("Combat CPU"))
										a:LoseMana(1)
									return
							if(a:AfterImageStrike&&src.Dodgeable>0)
								var/dir=get_dir(src,a)
								a:AfterImageStrike-=1
								if(a:AfterImageStrike<0)
									a:AfterImageStrike=0
								if(!m.HasNoDodge())
									AfterImage(a)
									if(src.Area=="Beam")
										for(var/obj/Skills/Projectile/Beams/Z in src.Owner)
											if(Z.Charging)
												src.Owner.BeamStop(Z)
									a:Move(get_step(src.Owner,turn(dir,pick(-45,45,-90,90,180))))
									StunClear(a)
									WildSense(a, src.Owner,1)
								else
									StunClear(a)
									spawn()
										Jump(a)
								if(src.Homing)
									src.dir=dir
									src.Homing=0
									if(src.Area!="Beam")
										src.Backfire=1
								return


							if(src.Owner.HasRipple())
								if(src.Owner.Oxygen>=BreathCost)
									var/RipplePower=(1+(0.25*src.Owner.GetRipple()*max(1,src.Owner.PoseEnhancement*2)))
									accmult*=RipplePower
								else if(src.Owner.Oxygen>=src.Owner.OxygenMax*0.3)
									var/RipplePower=(1+(0.125*src.Owner.GetRipple()*max(1,src.Owner.PoseEnhancement*2)))
									accmult*=RipplePower
							if(Accuracy_Formula(src.Owner, a, accmult*(src.MultiHit+1), BaseChance=glob.WorldDefaultAcc, Backfire=src.Backfire) == MISS &&!a:KO&&!src.Radius&&src.Dodgeable>=0)
								src.loc = a.loc
								var/dir=get_dir(src,a)
								if(src.Area!="Beam")
									spawn()Prediction(a)
									if(src.Homing)
										src.dir=dir
										src.Homing=0
										src.Backfire=1
								else
									AfterImage(a)
									for(var/obj/Skills/Projectile/Beams/Z in src.Owner)
										if(Z.Charging)
											src.Owner.BeamStop(Z)
									var/turf/W=locate(a:x+pick(-3,-2,-1,1,2,3),a:y+pick(-3,-2,-1,1,2,3),a:z)
									if(W)
										if(istype(W,/turf/Special/Blank))
											return
										if(!W.density)
											for(var/atom/x in W)
												if(x.density)
													return
											if(W.density)
												return
										a:Move(W)
								return
							else
								var/Deflect=0
								/*var/defIntim = m.GetIntimidation()
								var/atkIntim = Owner.GetIntimidation()
								var/atkIntimIgnore = Owner.GetIntimidationIgnore(m)
								var/defIntimIgnore = m.GetIntimidationIgnore(Owner)
								// the difference between the two intims
								var/Rate = ( atkIntim - (atkIntim * (defIntimIgnore))) - (defIntim - (defIntim * (atkIntimIgnore))) * 0.75
								if(Rate < 0)
									Rate = abs(Rate)/10*/
								if(src.Deflectable&&!a:KO)
									if(Owner.passive_handler["Magmic"] && Owner.SlotlessBuffs["Magmic Shield"])
										Deflect = 1
										Owner.SlotlessBuffs["Magmic Shield"].Trigger(Owner, TRUE)
									if(a:HasDeflection())
										if(!Deflection_Formula(src.Owner, a, (accmult /** Rate*/ * ( min(0.1,1 - (src.MultiHit * 0.025) ) ) /(1+a:GetDeflection())), BaseChance=(glob.WorldDefaultAcc), Backfire=src.Backfire))
											Deflect=1
									else
										if(!Deflection_Formula(src.Owner, a, accmult /** Rate*/ * min(0.1,1 - (src.MultiHit * 0.025)), BaseChance=(glob.WorldDefaultAcc), Backfire=src.Backfire))
											Deflect=1
									if(Deflect)
										var/list/Dirs=list(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH)
										Dirs.Remove(src.dir)
										Dirs.Remove(turn(a:dir,180))
										src.dir=pick(Dirs)
										if(a:CheckSlotless("Deflector Shield"))
											if(!a:Shielding)
												a:Shielding=1
												spawn()
													a:ForceField()
										else if(!a:CheckSlotless("Ki Shield"))
											flick("Attack", a)
										if(src.Homing)
											src.dir=get_dir(src, src.Homing)
											src.Homing=0
										if(!src.HomingCharge)
											src.Owner=a
											src.Distance=src.DistanceMax
										else
											if(src.Area!="Beam")
												src.Backfire=1
										if(a:UsingAnsatsuken())
											a:HealMana(a:SagaLevel)
										if(a:SagaLevel>1&&a:Saga=="Path of a Hero: Rebirth")
											if(a:passive_handler["Determination"])
												a:HealMana(a:SagaLevel / 4)
											else
												a:HealMana(a:SagaLevel)
										return
								else
									if(a:HasDeflection())
										if(a:CheckSlotless("Deflector Shield"))
											if(!a:Shielding)
												a:Shielding=1
												spawn()
													a:ForceField()
										Damage*=max(1-(0.25*a:GetDeflection()),0.25)
									else if(!Deflection_Formula(src.Owner, a, accmult*(src.MultiHit+1)/**(max(atkIntim, 1)/max(defIntim,1))*/, BaseChance=(100-glob.WorldWhiffRate), Backfire=src.Backfire))
										Damage*=0.5



						if(GodPowered)
							src.Owner.transcend(GodPowered)
						if(CosmoPowered)
							if(!src.Owner.SpecialBuff)
								src.DamageMult*=1+(src.Owner.SenseUnlocked-5)
						var/str = StrRate ? Owner.GetStr(StrRate) : 0
						var/force = ForRate ? Owner.GetFor(ForRate) : 0
						if(AdaptRate)
							if(Owner.GetStr(1) > Owner.GetFor(1))
								str = Owner.GetStr(AdaptRate)
							else
								force = Owner.GetStr(AdaptRate)
						var/powerDif = Owner.Power / a:Power
						// + Owner.getIntimDMGReduction(m)
						if(glob.CLAMP_POWER)
							if(!Owner.ignoresPowerClamp())
								powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
						var/atk = 0
						if(Owner.isSuperCharged(Owner))
							EndRate -=  clamp(glob.SUPERCHARGERATE * Owner.passive_handler["SuperCharge"], 0, 1)
							Owner.StyleBuff.last_super_charge = world.time
						if(Owner.passive_handler["Atomizer"])
							EndRate = clamp(EndRate - (EndRate * (Owner.passive_handler["Atomizer"] * glob.ATOMIZERRATE)), 0.0001, 2)
						var/def = a:getEndStat(1) * EndRate
						if(src.Owner.UsingPridefulRage())
							if(Owner.passive_handler.Get("PridefulRage") >= 2)
								def = 1
							else
								def = clamp(a:GetEnd(EndRate)/2, 1, a:GetEnd(EndRate))
						if(force)
							atk += force
						if(str)
							atk += str
						if(atk<1)
							atk=1
						if(glob.DMG_CALC_2)
							Damage = (powerDif**glob.DMG_POWER_EXPONENT) * (glob.CONSTANT_DAMAGE_EXPONENT+glob.PROJECTILE_EFFECTIVNESS) ** -(def**glob.DMG_END_EXPONENT / atk**glob.DMG_STR_EXPONENT)
						else
							Damage = ((atk * powerDif)*glob.CONSTANT_DAMAGE_EXPONENT)** -( def / atk)
						#if DEBUG_PROJECTILE
						Owner.log2text("PROJ Damage after", Damage, "damageDebugs.txt", Owner.ckey)
						#endif
						Damage *= DamageMult
						#if DEBUG_PROJECTILE
						Owner.log2text("PROJ Damage after mult", Damage, "damageDebugs.txt", Owner.ckey)
						#endif
						Damage = ProjectileDamage(Damage)
						#if DEBUG_PROJECTILE
						Owner.log2text("PROJ Damage final", Damage, "damageDebugs.txt", Owner.ckey)
						#endif
						if(Bounce)
							Damage *= max(1-glob.BOUNCE_REDUCTION * CurrentBounce, 0.25)
						if(src.Owner.HasRipple())
							if(src.Owner.Oxygen>=BreathCost)
								var/RipplePower=(1+(0.25*src.Owner.GetRipple()*max(1,src.Owner.PoseEnhancement*2)))
								Damage*=RipplePower
							else if(src.Owner.Oxygen>=src.Owner.OxygenMax*0.3)
								var/RipplePower=(1+(0.125*src.Owner.GetRipple()*max(1,src.Owner.PoseEnhancement*2)))
								Damage*=RipplePower
							#if DEBUG_PROJECTILE
							Owner.log2text("PROJ Damage RIPPLE", Damage, "damageDebugs.txt", Owner.ckey)
							#endif
						if(itemMods[3]>0)
							#if DEBUG_PROJECTILE
							Owner.log2text("item damage1", itemMods[3], "damageDebugs.txt", Owner.ckey)
							#endif
							Damage *= (itemMods[3])
							#if DEBUG_PROJECTILE
							Owner.log2text("item damage2", Damage, "damageDebugs.txt", Owner.ckey)
							#endif
						if(src.Area=="Beam")
							src.Damage*=(BeamCharge)
							BeamCharge = max(Immediate ? 1 : 0.5, BeamCharge - 0.2)
							src.Damage*=GoCrand(0.75,1)
							src.AccMult*=5

						var/EffectiveDamage=Damage
						if(a:Launched||a:Stunned)
							EffectiveDamage *= glob.CCDamageModifier

						if(GoldScatter||Owner.CheckSlotless("Hoarders Riches"))
							for(var/obj/Money/money in a.contents)
								if(money.Level>0)
									var/newX = a.x + rand(-3, 3)
									var/newY = a.y + rand(-3, 3)
									for(var/i = 0, i < 10; i++)
										var/turf/t = locate(newX,newY,a.z)
										if(t.density)
											if(i == 9) break
											newX = a.x + rand(-3, 3)
											newY = a.y + rand(-3, 3)
											continue
										else
											break
									var/obj/gold/gold = new()
									gold.createPile(m, src.Owner, newX, newY, m.z)
									a << "You feel a need to go collect your coins before they're stolen!"

						if(Crippling)
							a:AddCrippling(Crippling, src.Owner)
						if(Shearing)
							a:AddShearing(Shearing, src.Owner)
						if(Owner.Attunement == "Fox Fire")
							var/heal = EffectiveDamage * ( (1 + Owner.AscensionsAcquired + (FoxFire))/10)
							a:LoseEnergy(heal/2)
							a:LoseMana(heal/2)
							Owner.HealEnergy(heal/2)
							Owner.HealMana(heal/2)
						if(a:passive_handler.Get("Siphon")&&src.ForRate)
							var/Heal=EffectiveDamage*(a:passive_handler.Get("Siphon")/10)*src.ForRate//Energy siphon is a value from 0.1 to 1 which reduces damage and heals energy.
							EffectiveDamage-=Heal//negated
							a:HealEnergy(Heal)//and transfered into energy.
						if(src.Burning&&!src.Owner.HasBurning())
							EffectiveDamage*=max(1,ProjectileDamage(ElementalCheck(src.Owner, a, bonusElements=list("Fire"), damageOnly = 1))/10)
						if(src.Scorching&&!src.Owner.HasScorching())
							EffectiveDamage*=max(1,ProjectileDamage(ElementalCheck(src.Owner, a, 1, bonusElements=list("Fire"), damageOnly = 1))/10)//Forces debuff
						if(src.Chilling&&!src.Owner.HasChilling())
							EffectiveDamage*=max(1,ProjectileDamage(ElementalCheck(src.Owner, a, bonusElements=list("Water"), damageOnly = 1))/10)
						if(src.Freezing&&!src.Owner.HasFreezing())
							EffectiveDamage*=max(1,ProjectileDamage(ElementalCheck(src.Owner, a, 1, bonusElements=list("Water"), damageOnly = 1))/10)//Forces debuff
						if(src.Crushing&&!src.Owner.HasCrushing())
							EffectiveDamage*=max(1,ProjectileDamage(ElementalCheck(src.Owner, a, bonusElements=list("Earth"), damageOnly = 1))/10)
						if(src.Shattering&&!src.Owner.HasShattering())
							EffectiveDamage*=max(1,ProjectileDamage(ElementalCheck(src.Owner, a, 1, bonusElements=list("Earth"), damageOnly = 1))/10)//Forces debuff
						if(src.Shocking&&!src.Owner.HasShocking())
							EffectiveDamage*=max(1,ProjectileDamage(ElementalCheck(src.Owner, a, bonusElements=list("Wind"), damageOnly = 1))/10)
						if(src.Paralyzing&&!src.Owner.HasParalyzing())
							EffectiveDamage*=max(1,ProjectileDamage(ElementalCheck(src.Owner, a, 1, bonusElements=list("Wind"), damageOnly = 1))/10)//Forces debuff
						if(src.Poisoning&&!src.Owner.HasPoisoning())
							EffectiveDamage*=max(1,ProjectileDamage(ElementalCheck(src.Owner, a, bonusElements=list("Poison"), damageOnly = 1))/10)
						if(src.Toxic&&!src.Owner.HasToxic())
							EffectiveDamage*=max(1,ProjectileDamage(ElementalCheck(src.Owner, a, 1, bonusElements=list("Poison"), damageOnly = 1))/10)//Forces debuff
						var/bonusElement = list()
						if(Burning||Scorching)
							bonusElement |= "Fire"
						if(Chilling||Freezing)
							bonusElement |= "Water"
						if(Crushing||Shattering)
							bonusElement |= "Earth"
						if(Paralyzing||Shocking)
							bonusElement |= "Wind"
						if(Toxic||Poisoning)
							bonusElement |= "Poison"

						ElementalCheck(src.Owner, a, onlyTheseElements=bonusElement)

						if(src.Owner.inParty(m.ckey))
							EffectiveDamage *= glob.PARTY_DAMAGE_NERF
							if(src.Owner.passive_handler.Get("TeamFighter"))
								EffectiveDamage /= 1+src.Owner.passive_handler.Get("TeamFighter")
						if(src.Owner.party && src.Owner.passive_handler.Get("TeamHater"))
							if(m in src.Owner.party.members)
								EffectiveDamage *= 1+src.Owner.passive_handler.Get("TeamHater")
						if(src.Owner.HasPurity()||src.Purity)//If damager is pure
							var/found=0//Assume you haven't found a proper target
							if(src.Owner.HasBeyondPurity()||src.BeyondPurity)//if you can say fuck off to purity...
								if(src.Owner.HasHolyMod()||src.HolyMod)
									if(a:IsGood())//good things still heal good people
										found=1
								if(found)
									goto SkipDamage
							else
								if(src.Owner.HasHolyMod()||src.HolyMod)//Holy things
									if(a:IsEvil())//Kill evil things
										found=1
								if(!found)//If you don't find what you're supposed to hunt
									goto SkipDamage
						if(src.HolyMod)
							EffectiveDamage*=1+src.Owner.HolyDamage(a, Forced=src.HolyMod)/glob.HOLY_DAMAGE_DIVISOR
						if(src.AbyssMod)
							EffectiveDamage*=1+src.Owner.AbyssDamage(a, Forced=src.AbyssMod)/glob.ABYSS_DAMAGE_DIVISOR
						if(src.SlayerMod)
							EffectiveDamage*=1+src.Owner.SlayerDamage(a, Forced=src.SlayerMod)/glob.SLAYER_DAMAGE_DIVISOR
						if(src.WarpUser)
							src.Owner.Comboz(a)
						if(istype(src.Owner, /mob/Player/AI))
							if(istype(a, /mob/Player/AI))
								for(var/x in src.Owner:ai_alliances)
									if(x in a:ai_alliances)
										EffectiveDamage=0
										break//cancel allied damage
						if(EffectiveDamage>0)
							if(src.MortalBlow)

								if(prob(glob.MORTAL_BLOW_CHANCE * MortalBlow) && !m.MortallyWounded)
									var/mortalDmg = m.Health * 0.05 // 5% of current
									m.LoseHealth(mortalDmg)
									m.WoundSelf(mortalDmg)
									m.MortallyWounded += 1
									OMsg(m, "<b><font color=#ff0000>[src] has dealt a mortal blow to [m]!</font></b>")

							if(src.Area=="Beam")
								src.Owner.DoDamage(a, (EffectiveDamage/glob.GLOBAL_BEAM_DAMAGE_DIVISOR), SpiritAttack=1, Destructive=src.Destructive)
								if(src.Owner.UsingAnsatsuken())
									src.Owner.HealMana(src.Owner.SagaLevel/8)
								if(src.Owner.SagaLevel>1&&src.Owner.Saga=="Path of a Hero: Rebirth")
									if(src.Owner.passive_handler["Determination"])
										src.Owner.HealMana(src.Owner.SagaLevel/32)
									else
										src.Owner.HealMana(src.Owner.SagaLevel/8)
							else
								if(MultDamage > 1) EffectiveDamage *= MultDamage
								// if not (piercing and theres a mob and they are already hit by key and that value is over or equal multihit+1)
								if(!(Piercing && m && (AlreadyHit["[m.ckey]"] >= MultiHit + 1)) || Bounce)
									if(!AlreadyHit["[m.ckey]"]) AlreadyHit["[m.ckey]"] = 0
									//EffectiveDamage *= clamp((1 - (0.1 *AlreadyHit["[m.ckey]"])), 0.1, 1)

									src.Owner.DoDamage(a, EffectiveDamage, SpiritAttack=1, Destructive=src.Destructive)
									if(CorruptionGain)
										Owner.gainCorruption((EffectiveDamage * 1.5) * glob.CORRUPTION_GAIN)
									if(m)
										AlreadyHit["[m.ckey]"]++
									if(Piercing && PiercingBang)
										Bang(src.loc, Size=src.PiercingBang, Offset=0, PX=src.VariationX, PY=src.VariationY, icon_override = ExplodeIcon)
								if(src.Owner.UsingAnsatsuken())
									src.Owner.HealMana(src.Owner.SagaLevel/15)
								if(src.Owner.SagaLevel>1&&src.Owner.Saga=="Path of a Hero: Rebirth")
									if(src.Owner.passive_handler["Determination"])
										src.Owner.HealMana(src.Owner.SagaLevel/60)
									else
										src.Owner.HealMana(src.Owner.SagaLevel/15)

							if(a:SenseRobbed<a:SenseUnlocked&&src.Excruciating)
								a:SenseRobbed+=src.Excruciating
								if(a:SenseRobbed>5)
									a:SenseRobbed=5
								if(a:SenseRobbed==1)
									RecoverImage(a)
									a << "You've been stripped of your sense of touch! You find it harder to move!"
								else if(a:SenseRobbed==2)
									RecoverImage(a)
									a << "You've been stripped of your sense of smell! You find it harder to breathe!"
								else if(a:SenseRobbed==3)
									RecoverImage(a)
									a << "You've been stripped of your sense of taste! You find it harder to speak!"
								else if(a:SenseRobbed==4)
									RecoverImage(a)
									a << "You've been stripped of your sense of hearing! You find it harder to hear!"
								else if(a:SenseRobbed==5)
									RecoverImage(a)
									a << "You've been stripped of your sense of sight! You find it harder to see!"
									animate(a:client, color = list(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1), time = 5)
							src.Backfire=0

						if(src.Owner.Grab||a:Grab)
							src.Owner.Grab_Release()
							a:Grab_Release()
						SkipDamage
						if(Snaring)
							m.applySnare(Snaring, 'root.dmi')
						if(src.Stunner)
							Stun(a, src.Stunner+src.Owner.GetStunningStrike())
							if(src.Stunner>=5)
								a << "Your mind is under attack!"
								animate(a:client, color = list(-1,-1,-1, -1,-1,-1, -1,-1,-1, 1,1,1), time = 5)
								spawn(10*(src.Stunner-1))
									animate(a:client, color = null, time = 5)
						if(src.Launcher)
							spawn()
								LaunchEffect(src.Owner, a, Launcher )
						if(src.Stasis&&!a:StasisFrozen)
							a:SetStasis(src.Stasis.world.tick_lag)

						if(src.Striking)
							src.Owner.HitEffect(a)
							if(src.DamageMult>=0.4)
								KenShockwave(a, Size=max((src.DamageMult+src.Knockback+src.Owner.Intimidation/50)*max(2*src.Owner.GetGodKi(),1)*GoCrand(0.04,0.4),0.2),PixelX=src.VariationX,PixelY=src.VariationY)
						if(src.Slashing)
							Slash(a, src.Owner.EquippedSword())

						if(FollowUp)
							if(FollowUpDelay == -1)
								Owner.throwFollowUp(FollowUp)

						if(src.Knockback)
							if(src.Area=="Beam")
								var/KB=src.Knockback*EffectiveDamage*glob.WorldDamageMult
								src.Owner.Knockback(KB, a, src.dir, Forced=0.5, Ki=1, override_speed=src.Speed)
							else
								if(src.MultiHit)
									if(!a:Knockbacked)
										src.Owner.Knockback(1*src.MultiHit, a, src.dir, Forced=2, Ki=1, override_speed=src.Speed)
									else
										src.Owner.Knockback(1, a, src.dir, Ki=1, Forced=2, override_speed=src.Speed)
								else
									src.Owner.Knockback(src.Knockback, a, src.dir, Ki=1)
						//						NoKB

						if(!src.Piercing)
							if(src.MultiHit)
								src.MultiHit--
								src.Distance++
								if(src.MultiHit<0)
									src.MultiHit=0
									ProjectileFinish()
									return
							else
								if(Bounce && CurrentBounce++ < TotalBounce)
									forcedTarget = findNextTarget(a, Owner)
									if(forcedTarget == 0)
										ProjectileFinish()
								else
									ProjectileFinish()
								return
						else
							if(src.Homing)
								var/list/Dirs=list(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH)
								Dirs.Remove(turn(src.dir, 135))
								Dirs.Remove(turn(src.dir, 180))
								Dirs.Remove(turn(src.dir, 225))
								src.dir=pick(Dirs)
								src.Homing=0
					else
						if(isobj(a))
							if(a:Destructable)
								if(src.Dodgeable<0||src.MiniDivide||src.Divide)
									del a
									return
						else if(isturf(a))
							if(src.HyperHoming&&src.Homing||src.HomingCharge&&!src.Homing||src.MiniDivide)
								src.loc=a
								return
							else if(src.Divide)
								return
							else
								ProjectileFinish()
								return
						else
							ProjectileFinish()
							return
				Move()
					if(src.EdgeOfMapProjectile())
						ProjectileFinish()
						return
					if(src.MiniDivide)
						if(istype(src.loc, /turf))
							Destroy(src.loc, 9001)
					if(src.Divide)
						for(var/turf/t in view(src.Divide, src))
							Destroy(t, 9001)
					if(src.Trail)
						if(src.MultiTrail)
							WaveTrail(src.Trail, src.VariationX+src.TrailX, src.VariationY+src.TrailY, src.dir, src.loc, src.TrailDuration, src.TrailSize)
						else
							LeaveTrail(src.Trail, src.VariationX+src.TrailX, src.VariationY+src.TrailY, src.dir, src.loc, src.TrailDuration, src.TrailSize)

					src.Distance--
					..()
				var/tmp/mob/forcedTarget
				proc/findNextTarget(mob/p, mob/o)
					for(var/mob/a in view(Bounce, p))
						if(a == p || a == o || a.PureRPMode || a.Stasis || o.inParty(a.ckey))
							continue
						return a
					return 0
				proc/ProjectileFinish() //This function should allow the garbage collector to take care of projectiles. For this to work, make sure all references TOWARD the projectile are cleansed.
					//Or it will persist even in the void
					walk(src, 0)
					if(0 > Distance) return
					Distance=-1

					if(!Killed && (MultiHit > 0) && Area != "Beam")
						for(var/mob/m in view(max(1, Radius), src))
							Hit(m, MultDamage = MultiHit)

					if(Owner)
						Owner.Frozen = 0
					if(src.TurfShiftEnd)
						if(src.TurfShiftEndSize)
							for(var/turf/t in Turf_Circle(src, TurfShiftEndSize))
								TurfShift(TurfShiftEnd, t, 10+Delay, src, OBJ_LAYER+0.01)

					if(src.Trail)
						if(src.MultiTrail)
							WaveTrail(src.Trail, src.VariationX+src.TrailX, src.VariationY+src.TrailY, src.dir, src.loc, src.TrailDuration, src.TrailSize)
						else
							LeaveTrail(src.Trail, src.VariationX+src.TrailX, src.VariationY+src.TrailY, src.dir, src.loc, src.TrailDuration, src.TrailSize)
					if(!src.Killed && src.Owner)
						if(src.Explode)
							Bang(src.loc, Size=src.Explode, Offset=0, PX=src.VariationX, PY=src.VariationY, icon_override = ExplodeIcon)
						if(src.Cluster)
							for(var/c=src.ClusterCount, c>0, c--)
								if(src.ClusterAdjust)
									src.Owner.Blast(src.Cluster, src.loc, 0, src.icon)
								else
									src.Owner.Blast(src.Cluster, src.loc, 0)
								sleep(src.ClusterDelay)
						if(!src.MaxMultiHit&&!src.Piercing&&!src.Striking&&!src.Slashing&&!src.Explode&&!src.Cluster&&src.Area!="Beam")
							if(!src.Trail)
								Bang(src.loc, Size=0.5, Offset=0, PX=src.VariationX, PY=src.VariationY)
							else
								Bang(src.loc, Size=0.5, Offset=0, PX=src.VariationX+src.TrailX, PY=src.VariationY+src.TrailY)
					endLife()
				proc
					Life()
						Cooldown=-1 //Keeps active projectiles from moving onto the player during their movements.
						while(src.Distance>0)
							if(src.Area=="Beam")
								src.BeamGraphics()
							if(src.EdgeOfMapProjectile())
								Distance=0
								break
							if(src.Homing)
								if(!src.Owner.Target)
									Distance=0
								if(forcedTarget)
									Homing = forcedTarget
								if(src.LosesHoming)
									var/Time=src.LosesHoming
									spawn(Time)
										if(src.RandomPath)
											var/list/Dirs=list(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH)
											Dirs.Remove(turn(src.dir, 135))
											Dirs.Remove(turn(src.dir, 180))
											Dirs.Remove(turn(src.dir, 225))
											src.dir=pick(Dirs)
										src.Homing=0
										src.LosesHoming=Time
									src.LosesHoming=0
								if(!src.Backfire)
									spawn(30)
										src.Backfire=1
							if(src.HomingCharge&&!src.Homing&&!src.HomingChargeSpent)
								src.HomingCharge-=1
								src.HomingChargeSpent=1
								spawn(src.HomingDelay)
									if(src.Owner)
										if(src.Owner.Target&&src.Owner.Target!=src.Owner)
											src.Homing=src.Owner.Target
										src.Distance=src.DistanceMax
										src.HomingChargeSpent=0
							if(src.HyperHoming&&src.Homing||src.HomingCharge&&!src.Homing)
								if(src.Owner)

									if(src.Owner.Target&&ismob(src.Owner.Target))
										var/target = src.Owner.Target
										if(forcedTarget)
											target = forcedTarget
										if(target in view(src.Radius, src))
											src.Bump(target)
							else
								for(var/atom/a in view(src.Radius, src))
									if(src.StormFall&&a.pixel_z!=src.pixel_z)
										continue
									if(a==src.Owner&&!src.Backfire)
										continue
									if(a.Owner==src.Owner)
										continue
									if(a==src)
										continue
									if(istype(a, /mob)&&a.density)
										src.Bump(a)
									else
										if(a.density)
											if(src.loc==a||src.loc==a.loc)
												src.Bump(a)
								for(var/obj/Skills/Projectile/_Projectile/p in view(src.Radius, src))
									if(p.Owner==src.Owner)
										continue
									if(p==src)
										continue
									src.Bump(p)
							sleep(src.Speed)
							if(FadeOut && FadeOut>=Distance)
								animate(src, alpha=0, time=max(1,FadeOut*Speed), flags=ANIMATION_PARALLEL)
								FadeOut=0

							if(0>=Distance)
								break
							if(src.Area!="Beam")
								if(src.Homing)
									src.dir=get_dir(src, src.Homing)
								else
									if(src.RandomPath==2)
										var/ODir=src.dir
										while(src.dir==ODir)
											src.dir=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH)
								if(!src.Static&&!src.StormFall)
									step(src, src.dir)
								else//for statics
									src.Distance--
									if(src.StormFall)
										animate(src, pixel_z=-1, flags=ANIMATION_RELATIVE)
							if(src.Area=="Beam")
								walk(src, src.dir, src.Speed)
						if(Owner) Owner.active_projectiles -= src
						ProjectileFinish()
						return

mob
	proc
		BeamCharge(var/obj/Skills/Projectile/Z)
			set waitfor=0
			src.Beaming=1
			src.BeamCharging=0.5
			if(Z.ChargeIcon)
				if(Z.ChargeIconUnder)
					src.Chargez("Add", image(icon=Z.ChargeIcon, pixel_x=Z.ChargeIconX, pixel_y=Z.ChargeIconY), 1)
				else
					src.Chargez("Add", image(icon=Z.ChargeIcon, pixel_x=Z.ChargeIconX, pixel_y=Z.ChargeIconY), 0)
			else
				src.Chargez("Add")
			Z.Charging=1
		BeamStop(var/obj/Skills/Projectile/Z)
			set waitfor=0
			src.icon_state=""
			src.Beaming=0
			Z.Charging=0
			if(src.TomeSpell(Z))
				Z.Cooldown()
			else
				Z.Cooldown()
obj
	Skills
		Projectile
			proc
				BeamGraphics()
					src.animate_movement=NO_STEPS
					if(src.Stream)
						return
					if(src.Owner in view(1, src))//Haven't stepped yet.
						src.icon_state="origin"
						src.layer=5
					else
						var/Found=0
						for(var/mob/m in get_step(src, src.dir))
							Found=1
						for(var/obj/Skills/Projectile/p in get_step(src, src.dir))
							if(p.Owner==src.Owner)
								continue
							Found=1
						if(Found==1&&src.Distance&&!src.Piercing)
							src.icon_state="struggle"
							src.layer=5
						else
							src.layer=4
							src.icon_state="head"
							if(locate(src.type, get_step(src, src.dir)))
								src.icon_state="tail"
							if(!locate(src.type, get_step(src, turn(src.dir, 180))))
								src.icon_state="end"
								src.layer=5