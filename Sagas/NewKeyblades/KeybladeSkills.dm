//autohits
obj
	Skills
//t1
		AutoHit
			var/UpgradedKeybladeSkill=0
			Sonic_Blade
				NeedsSword=1
				Area="Strike"
				PassThrough=1
				Distance=4
				AdaptRate=1
				DamageMult=1.5
				Rush=3
				ControlledRush=1
				Cooldown=30
				EnergyCost=2
				DelayTime=1.5
				Rounds=3
				MaxCharges=3
				Charges=3
				ChargeRefresh=30
				ActiveMessage="dashes forward repeatedly with a jousting strike!"
				adjust(mob/P)
					if(src.UpgradedKeybladeSkill)
						src.Cooldown=30
						src.Distance=7
						src.Rush=7
						DelayTime=2
						src.Rounds=5
						DamageMult=2
						MaxCharges=3
						Charges=3
						ChargeRefresh=15
				verb/Sonic_Blade()
					set category="Skills"
					adjust(usr)
					usr.Activate(src)
			Strike_Raid
				NeedsSword=1
				Area="Wave"
				Distance=7
				AdaptRate=1
				HitSparkIcon='Hit Effect Pearl.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=3
				TurfStrike=1
				Slow=1
				DamageMult=3
				Cooldown=45
				EnergyCost=3
				ActiveMessage="throws their Keyblade forward!"
				adjust(mob/P)
					if(src.UpgradedKeybladeSkill)
						src.Cooldown=30
						DamageMult=4
						DelayTime=1
						Rounds=3
				verb/Strike_Raid()
					set category="Skills"
					adjust(usr)
					usr.Activate(src)
			Magnet_Burst
				SagaSignature=1;
				SignatureTechnique=1
				Area="Circle"
				Distance=5
				AdaptRate = 1
				GuardBreak=1
				DamageMult=1
				PullIn=8
				Cooldown=45
				Shockwaves=3
				Shockwave=4
				BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Staggered"
				SpecialAttack=1
				Stunner=3
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				ActiveMessage="draws in everyone nearby with a burst of magnetism!"
				adjust(mob/P)
					if(src.UpgradedKeybladeSkill)
						src.Cooldown=30
						Distance=8
						DamageMult=5
				verb/Magnet_Burst()
					set category="Skills"
					usr.Activate(src)
//t2
			Ripple_Drive
				Area="Circle"
				Distance=5
				AdaptRate = 1
				GuardBreak=1
				DamageMult=6
				Knockback=15
				Cooldown=45
				Shockwaves=3
				Shockwave=4
				BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Staggered"
				SpecialAttack=1
				Stunner=3
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				ActiveMessage="unleashes a damaging aura around nearby enemies!"
				EnergyCost=5
				adjust(mob/P)
					if(src.UpgradedKeybladeSkill)
						src.Cooldown=30
						src.Distance=7
						src.DamageMult=9
						src.Knockback=20
						src.Shockwaves=4
						src.Stunner=5
				verb/Ripple_Drive()
					set category="Skills"
					adjust(usr)
					usr.Activate(src)
//t3
			Fire_Surge
				Area="Circle"
				PassThrough=0
				Distance=4
				AdaptRate=1
				NoPierce=1
				DamageMult=9
				Rush=6
				ControlledRush=0
				Cooldown=60
				EnergyCost=2
				ActiveMessage="dashes forward, surrounded by flames!"
				adjust(mob/P)
					if(src.UpgradedKeybladeSkill)
						src.Cooldown=45
						src.Distance=6
						src.DamageMult=12
						src.Rush=8
				verb/Fire_Surge()
					set category="Skills"
					adjust(usr)
					usr.Activate(src)
			Thunder_Surge
				Area="Circle"
				PassThrough=0
				Distance=4
				AdaptRate=1
				NoPierce=1
				DamageMult=9
				Rush=6
				ControlledRush=0
				Cooldown=60
				EnergyCost=2
				ActiveMessage="dashes forward, surrounded by lightning!"
				adjust(mob/P)
					if(src.UpgradedKeybladeSkill)
						src.Cooldown=45
						src.Distance=6
						src.DamageMult=12
						src.Rush=8
				verb/Thunder_Surge()
					set category="Skills"
					adjust(usr)
					usr.Activate(src)
//t4
			Raging_Storm
				NeedsSword=1
				Area="Circle"
				AdaptRate=1
				Cooldown = 75
				DamageMult=1.5
				Rounds=20
				ComboMaster=1
				Size=2
				EnergyCost=5
				Icon='TornadoPhoenix.dmi'
				IconX=-8
				IconY=-8
				HitSparkIcon='Slash - Zan.dmi'
				HitSparkX=-16
				HitSparkY=-16
				HitSparkTurns=1
				HitSparkSize=1
				HitSparkDispersion=1
				TurfStrike=1
				ActiveMessage="surrounds themselves in fire!"
				adjust(mob/P)
					if(src.UpgradedKeybladeSkill)
						src.Cooldown=60
						src.DamageMult=2
						src.Rounds=25
						src.Size=3
				verb/Raging_Storm()
					set category="Skills"
					adjust(usr)
					usr.Activate(src)
			Salvation
				AdaptRate=1
				DamageMult=12
				Area="Circle"
				Distance=8
				Slow=1
				WindUp=1
				WindupIcon='Ripple Radiance.dmi'
				WindupIconUnder=1
				WindupIconX=-32
				WindupIconY=-32
				WindupIconSize=1.3
				HealthRecovery=1
				HealthRecoveryValue=5
				WindupMessage="draws in a large amount of light..."
				ActiveMessage="unleashes a bright flash of light!"
				HitSparkIcon='BLANK.dmi'
				HitSparkX=0
				HitSparkY=0
				TurfStrike=1
				TurfShift='StarPixel.dmi'
				TurfShiftDuration=3
				Cooldown=75
				adjust(mob/P)
					if(src.UpgradedKeybladeSkill)
						src.Cooldown=60
						src.DamageMult=16
						src.Distance=10
						src.HealthRecoveryValue=8
				verb/Salvation()
					set category="Skills"
					adjust(usr)
					usr.Activate(src)
			Ragnarok
				NeedsSword=1
				Area="Arc"
				AdaptRate=1
				DamageMult=2.25
				Rush=5
				ControlledRush=1
				Rounds=5
				ComboMaster=1
				RoundMovement=1
				NoAttackLock=1
				NoLock=1
				Cooldown=60
				Icon='Nest Slash.dmi'
				IconX=-16
				IconY=-16
				Size=2
				Distance=2
				EnergyCost=5
				Launcher=2
				Instinct=1
				ActiveMessage="unleashes a flurry of strikes!"
				FollowUp="/obj/Skills/AutoHit/Ragnarok_Blast"
				adjust(mob/P)
					if(src.UpgradedKeybladeSkill)
						src.Cooldown=45
						src.DamageMult=3
						src.Rush=7
						src.Rounds=7
				verb/Ragnarok()
					set category="Skills"
					adjust(usr)
					usr.Activate(src)
			Ragnarok_Blast
				NeedsSword=1
				Area="Around Target"
				Distance=12
				DistanceAround=5
				AdaptRate=1
				Knockback=0
				ComboMaster=1
				HitSparkIcon='Hit Effect Pearl.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=3
				TurfStrike=1
				Slow=3
				Rounds=5
				Size=3
				DamageMult=2
				ActiveMessage="thrusts their blade forward, magic exploding from the tip of the blade!"
			ExplosionFollowup
				Area="Circle"
				AdaptRate=1
				DamageMult=9
				Shattering=1
				Size=2
				Icon='SweepingKick.dmi'
				IconX=-32
				IconY=-32
				EnergyCost=2
				Shockwaves=3
				Shockwave=4
				ShockIcon='KenShockwave.dmi'
				ActiveMessage="releases the explosive energy within their Keyblade!"
			Magic
				Ultima
					ElementalClass="Ultima"
					SpellElement="Ultima"
					SignatureName="Ultima"
					Area="Target"
					Distance=7
					DamageMult=30
					ComboMaster=1
					WindUp=3
					ManaCost=30
					Cooldown=360
					HitSparkIcon='Hit Effect Satsui.dmi'
					HitSparkX=-32
					HitSparkY=-32
					HitSparkTurns=1
					HitSparkSize=5
					HitSparkCount=10
					HitSparkDispersion=1
					ForOffense=1
					AdaptRate=1
					SpecialAttack=1
					WindupMessage="invokes: <font size=+1>ULTIMA!!!</font size>"
					adjust(mob/p)
						DamageMult = initial(DamageMult)
					verb/Ultima()
						set category="Skills"
						adjust(usr)
						usr.Activate(src)
		Queue
			var/UpgradedKeybladeSkill=0
			Stun_Impact
				DamageMult=6
				AccuracyMult = 1.25
				Duration=10
				Cooldown=60
				Instinct=4
				Stunner=3
				PushOut=3
				PushOutWaves=2
				HitMessage="releases the energy they gathered into their Keyblade!"
				ActiveMessage="gathers energy into their Keyblade!"
				adjust(mob/P)
					if(src.UpgradedKeybladeSkill)
						src.Cooldown=45
						src.DamageMult=8
						src.Stunner=5
						src.PushOutWaves=3
						src.Instinct=6
				verb/Stun_Impact()
					set category="Skills"
					adjust(usr)
					usr.SetQueue(src)
			Explosion
				DamageMult=1
				AccuracyMult = 1.5
				Cooldown=60
				Instinct=5
				FollowUp="/obj/Skills/AutoHit/ExplosionFollowup"
				HitMessage="strikes with their Keyblade, as it glows brightly..."
				adjust(mob/P)
					if(src.UpgradedKeybladeSkill)
						src.Cooldown=45
						src.AccuracyMult=1.75
						src.Instinct=7
						for(var/obj/Skills/AutoHit/ExplosionFollowup/EF in P)
							EF.DamageMult=12
							EF.Shockwaves=4
				verb/Explosion()
					set category="Skills"
					adjust(usr)
					usr.SetQueue(src)

		Buffs
			SlotlessBuffs
				Keyblade_Armor
					MakesArmor=1
					ArmorAscension=1
					ArmorUnbreakable=1
					ArmorIcon='LancelotArmor.dmi'
					ArmorClass="Light"
					passives = list()
					var/list/SwordPassives = list("BlurringStrikes" = 1, "Brutalize" = 2, "TechniqueMastery" = 3)
					var/list/ShieldPassives = list("CallousedHands" = 0.15, "Juggernaut" = 1)
					var/list/StaffPassives = list("ManaGeneration" = 1, "QuickCast" = 1)
					adjust(mob/p)
						var/ImaginaryBonus=0
						if(p.Class=="Imaginary")
							ImaginaryBonus=0.15*p.AscensionsAcquired
						if(p.KeybladeType=="Sword")
							StrMult=1.25 + ImaginaryBonus
							OffMult=1.25 + ImaginaryBonus
							SpdMult=1.5 + ImaginaryBonus
							passives=SwordPassives
						if(p.KeybladeType=="Shield")
							EndMult=1.5 + ImaginaryBonus
							DefMult=1.5 + ImaginaryBonus
							passives=ShieldPassives
						if(p.KeybladeType=="Staff")
							ForMult=1.5 + ImaginaryBonus
							OffMult=1.5 + ImaginaryBonus
							passives=StaffPassives
					verb/Keyblade_Armor()
						set category="Skills"
						if(!usr.BuffOn(src))
							adjust(usr)
						src.Trigger(usr)
				SyncBlade
					ActiveMessage="draws forth a second Keyblade!"
					OffMessage="releases their Keyblade back to the light..."
					ABuffNeeded=list("Keyblade")
					MakesSecondSword=1
					FlashDraw=1
					MagicSword=1
					SwordClass="Wooden"
					SwordAscension=2
					SwordName="Keyblade"
					PULock=1
					swordHasHistory=1
					passives = list("MagicSword" = 1, "DoubleStrike" = 3)
					Cooldown=30
					verb/SyncBlade()
						set category="Skills"
						if(!usr.BuffOn(src))
							passives = list("MagicSword" = 1, "DoubleStrike" = 3)
							src.SwordXSecond=-32
							src.SwordYSecond=-32
							if(usr.SyncAttached=="Ultima Weapon")
								src.SwordXSecond=-36
								src.SwordYSecond=-36

							if(usr.SyncAttached=="Moogle O Glory"||usr.SyncAttached=="Prismatic Dreams"||usr.SyncAttached=="Ebony Slumber")
								src.SwordXSecond=-64
								src.SwordYSecond=-64
							if(usr.CheckActive("Keyblade"))
								if(!src.Using)
									src.SwordClassSecond=GetKeychainClass(usr.SyncAttached)
									src.SwordDamageSecond=GetKeychainDamage(usr.SyncAttached)
									src.SwordAccuracySecond=GetKeychainAccuracy(usr.SyncAttached)
									src.SwordDelaySecond=GetKeychainDelay(usr.SyncAttached)
									src.SwordElementSecond=GetKeychainElement(usr.SyncAttached)
									src.SwordIconSecond=GetKeychainIconReversed(usr.SyncAttached)
									passives+=GetKeybladePassives(usr.SyncAttached)
						src.Trigger(usr)