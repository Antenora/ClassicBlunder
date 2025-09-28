mob
	verb
		Skill_Descriptions()
			set category = "Other"
			var/which = input(usr,"Which skill would you like to see the description for?","Skill Description") as null|anything in usr.Skills
			if(!which) return
			var/obj/Skills/s = which
			s.skillDescription()
			var/text = s.description
			usr << "<center>[text]</center>"

obj/Skills
	Level=100
	var/CorruptionCost
	var/Copied = FALSE
	var/Sealed = FALSE
	var/Temporary = FALSE
	var/description
	var/AdaptRate
	var/MultiTrail = 0
	var/SignatureTechnique
	var/SignatureName //lets you label things by a string other than the object name e.g. "Advanced White Magic"
	var/SagaSignature=0 //lets sagas keep the signature

	var/Cooldown
	var/CooldownStatic=0
	var/CooldownScaling=0
	var/CooldownScalingCounter=0
	var/Mastery=1
	var/BeamUsing
	var/BuffUsing
	var/SkillCost=1
	var/RevNum = 0

	var/sicon
	var/sicon_state
	var/list/Learn=new

	var/ZanzoAmount=0

	var/PureDamage=0
	var/PureReduction=0

	var/list/PreRequisite=list() //Used for skill tree shit.
	var/list/LockOut=list() //Also used for skill tree shit.
	var/Copyable //Used to avoid dealing with skill tree shit.
	var/CooldownNote //Displayed on cooldown!!

	var/StyleNeeded

	var/MagicNeeded  //lock people who aren't magic enough out from using this

	var/NoSword
	var/NeedsSword
	var/ClassNeeded

	var/NoStaff
	var/NeedsStaff
	var/StaffClassNeeded //just in case

	var/Instinct  //Penetrate AIS and WS
	var/NoForcedWhiff  //Super anti whiff
	var/MaimStrike  //if it does 25+ damage, maim.

	var/DeathField  //get this NONstatic amount of wounds just for slapping someone.
	var/VoidField  //get this NONstatic amount of fatigue just for slapping someone.
	var/SoftStyle
	var/HardStyle
	var/CyberStigma //Like Soft/Hard Styles, but for cybernetics

	var/LifeStealTrue //Applies health cuts and heals your health cuts
	var/SoulSteal //Adds stolen health to vaizard health.
	var/LifeSteal
	var/LifeGeneration
	var/EnergySteal
	var/EnergyGeneration
	var/ManaSteal
	var/ManaGeneration

	var/NoDodge //can always touch this
	var/NoMiss //cant stop touching that

	var/HealthCost=0 //Cost of health; pretty much just used for kikohohohoho.
	var/WoundCost=0 //ya...
	var/HeavyStrain=0 //as above, though it may include some other finishers
	var/EnergyCost=0 //Cost of energy.
	var/FatigueCost=0 //Cost of fatigue.  Additional to energy.
	var/ManaCost=0
	var/CapacityCost=0
	var/IconChargeOverhead //Hovers a blast above the user's head instead of doing charge animation.
	var/GrowingLife //Projectiles grows during its active time
	var/AllOutAttack //Allows you to use energy you don't have to complete the tech.

	 //Elemental shit.
	var/Burning=0 //makes burning chance roll
	var/Scorching=0 //just adds fucking burns
	var/Chilling=0 //slow chance
	var/Freezing=0 //Add slow
	var/Crushing=0 //shatter chance
	var/Shattering=0 //add shatter
	var/Shocking=0 //shock chance
	var/Paralyzing=0 //add shock
	var/Poisoning //poison chance
	var/Toxic //poison add
	var/Purity //You can only hurt what you're meant to
	var/BeyondPurity //nvm
	var/HolyMod //holy dmg
	var/AbyssMod //unholy dmg
	var/SlayerMod //mortal dmg
	var/ShonenPower  // become MC
	var/SpiritPower //become medium
	var/Mythical //become giant
	var/HellPower //become satan
	var/Disorienting  //rolls for confuse
	var/Confusing  //adds confuse
	var/Stunner=0 //Stuns for this amount of time
	var/Shearing //Debuffs regen
	var/Crippling //Cripples movement
	var/Excruciating //fucks up senses
	var/Attracting //Makes you follow someone, probably.
	var/Terrifying //Makes them chicken out instead!
	var/Pacifying  //Divides power by AngerMax for this length of time
	var/Enraging  //Triggers anger for this amount of time
	var/CursedWounds
	var/SoulFire
	var/DarknessFlame  //It does darkness flame things!
	var/AbsoluteZero  //It does absolute zero things!
	var/CosmoPowered
	var/GodPowered  //this makes the technique add Transcendant buff and use GodPowered as god ki.
	var/Destructive
	var/DashMaster  //spam ddash. should be limited.

	var/DoubleStrike
	var/TripleStrike


	 //only projectiles have this function rn
	var/FollowUp = null //holds a text path of a skill that will be triggered...
	var/FollowUpDelay = 0  //after waiting this amt of time
	var/ThrowOnCounter
	var/Controlling //Love potion effects TODO: Remove/discontinue for...
	var/BuffSelf
	var/BuffAffected

	 //we street fighter now vars
	var/Grapple //IT GRAPPLES
	var/GrabTrigger=0
	var/Launcher //IT LAUNCHES
	var/DelayedLauncher //...but it waits first

	 //Gear vars
	var/Integrated //If this is flagged, it will autoreload using some mana.
	var/obj/Items/AssociatedLegend //holds the object thats related to the skills
	var/obj/Items/Gear/AssociatedGear //holds the object that has uses
	var/CrestGranted //Flagged as 1 for skills which have only been granted via crest.  This takes them away when the crest is removed.
	var/NoTransplant //dont let people crest these spells
	var/ElementalClass //Styles can flag this and allow skills in the same class to be used regardless of tome/crest presence.  Can be a list too.

	 //words words words
	var/CustomActive //Totally Custom
	var/CustomOff //totally custom
	var/CustomCharge //totally custom

	var/HeavyHitter
	var/HeavyOnly
	var/copiedBy

	var/heavenlyRestrictionIgnore = FALSE

	proc
		skillDescription()
			description = "[src.name]\n"
			if(Cooldown!=-1)
				description += "Cooldown: [Cooldown] seconds.\n"
			else
				description += "Cooldown: On Meditate.\n"
			if(Launcher)
				description += "Launcher: [Launcher]\n"
			if(Stunner)
				description += "Stunner: [Stunner]\n"
			if(FollowUp)
				description += "Follow Up Move: [FollowUp]\n"
			if(Grapple)
				description += "Grapples.\n"
			if(Burning || Scorching || Chilling || Freezing || Crushing || Shattering || Shocking || Paralyzing || Poisoning || Toxic || Shearing || Crippling)
				description += "Elemental Effects: "
				if(Burning)
					description += "Burning, "
				if(Scorching)
					description += "Scorching, "
				if(Chilling)
					description += "Chilling, "
				if(Freezing)
					description += "Freezing, "
				if(Crushing)
					description += "Crushing, "
				if(Shattering)
					description += "Shattering, "
				if(Shocking)
					description += "Shocking, "
				if(Paralyzing)
					description += "Paralyzing, "
				if(Poisoning)
					description += "Poisoning, "
				if(Toxic)
					description += "Toxic, "
				if(Shearing)
					description += "Shearing, "
				if(Crippling)
					description += "Crippling, "
				description = replacetext(description, ", ", -1, -3)
				description += "\n"

				if(NeedsSword)
					description += "Requires Sword.\n"
				if(HeavyOnly)
					description += "Heavy Sword Only.\n"
				if(NoSword)
					description += "Unarmed Only.\n"
				if(BuffSelf)
					description += "Applies a buff to self: [BuffSelf]\n"
				if(BuffAffected)
					description += "Applies a buff to effected: [BuffAffected]\n"

				if(HealthCost)
					description += "Health Cost: [HealthCost]\n"
				if(WoundCost)
					description += "Wound Cost: [WoundCost]\n"
				if(EnergyCost)
					description += "Energy Cost: [EnergyCost]\n"
				if(FatigueCost)
					description += "Fatigue Cost: [FatigueCost]\n"
				if(ManaCost)
					description += "Mana Cost: [ManaCost]\n"
				if(CapacityCost)
					description += "Capacity Cost: [CapacityCost]\n"
				if(Instinct)
					description += "Instinct: [Instinct]\n"

	icon='Skillz.dmi'
	var/Teachable

	var/delay = 0
	verb/Set_Cooldown_Note()
		set src in usr
		set category="Other"
		var/Note=input(usr, "What do you want to be displayed after [src] comes off cooldown?", "Cooldown Note") as message|null
		src.CooldownNote=Note
		usr << "[src]'s cooldown note set to: ([src.CooldownNote])"

	proc/delayTimer()
		delay = 1
		sleep(5)
		delay = 0


	Target_Clear
		desc="Clear your target."
		verb/Clear_Target()
			set category="Skills"
			set hidden=1
			if(usr.Target)
				usr.RemoveTarget()
				usr << "<font color='red'>Target cleared.</font color>"

	Target_Switch
		desc="Switch targets."
		Cooldown=5
		verb/Target_Switch()
			set category="Skills"
			if(!src.Using)
				usr.TargetSkillX("TargetSwitch", src)

	Aerial_Payback
		name="Aerial Payback"
		Cooldown=40
		CooldownStatic=1
		Learn=list("energyreq"=10000,"difficulty"=50000)
		desc="Cancel knockback and dash towards your target!"
		Level=100
	Aerial_Recovery
		name="Aerial Recovery"
		Cooldown=20
		CooldownStatic=1
		Learn=list("energyreq"=10000,"difficulty"=50000)
		desc="Cancel knockback!"
	Dragon_Dash
		Cooldown=30
		CooldownStatic=1
		Learn=list("energyreq"=10000,"difficulty"=50000)
		desc="Dash towards your target!"
		Level=100
		verb/DragonDash()
			set name="Dragon Dash"
			set category="Skills"
			if(usr.HasDashMaster())
				src.Using=0
			if(usr.Knockback)
				for(var/obj/Skills/Aerial_Payback/x in usr.Skills)
					if(!x.Using)
						usr.SkillX("Aerial Payback",x)
			else
				usr.SkillX("DragonDash",src)

	Reverse_Dash
		Cooldown=30
		CooldownStatic=1
		Learn=list("energyreq"=10000,"difficulty"=50000)
		desc="Quickly dash away!"
		Level=100
		var/tmp/AntiMash=0
		verb/ReverseDash()
			set name="Reverse Dash"
			set category="Skills"
			if(AntiMash) return
			if(usr.HasDashMaster())
				src.Using=0
			if(usr.Knockback)
				for(var/obj/Skills/Aerial_Recovery/x in usr)
					if(!x.Using)
						usr.SkillX("Aerial Recovery",x)
			else
				for(var/obj/Skills/Reverse_Dash/x in usr)
					if(!x.Using)
						usr.SkillX("ReverseDash",src,1)
			src.AntiMash=1
			spawn(1)
				src.AntiMash=0

	Grab
		Cooldown=5
		CooldownStatic=1
		verb/Grab()
			set category="Skills"
			set name="Grab"
			usr:key1=0
			usr:key2=0
			usr:key3=0
			usr:key4=0
			usr.SkillX("Grab",src)

	Power_Recovery
		desc="Gather your bearings."

	Power_Control
		SkillCost=200
		Level=100
		icon='Skillz.dmi'
		icon_state="PC"
		sicon='Glow.dmi'
		pixel_x=-32
		pixel_y=-32
		desc="Allows you to highten or lower your energy level."
		verb/Power_Up()
			set category="Skills"
			usr.SkillX("PowerUp",src)
		verb/Power_Down()
			set category="Skills"
			usr.SkillX("PowerDown",src)

	Telekinesis
		Cooldown=120
		var/tmp/Choosing=0
		desc = "Do a telekinetic flip (and other tricks)."
		verb
			Lift_and_Hold()
				set category="Skills"
				set hidden=1
				if(!usr.CanAttack()) return
				if(!src.Using)
					var/mob/Tgt
					if(usr.Target)
						Tgt=usr.Target
					if(Tgt&&Tgt in oview())
						Tgt.Flying=1
						Tgt.Frozen=1
						Flight(Tgt)
						src.Cooldown(0.75)
						spawn(rand(10,20))
							Tgt.Frozen=0
							Tgt.Flying=0
			Lift_and_Throw()
				set category="Skills"
				set hidden=1
				if(!usr.CanAttack()) return
				if(!src.Using)
					var/mob/Tgt
					if(usr.Target)
						Tgt=usr.Target
					if(Tgt&&Tgt in view(10, usr))
						Tgt.Flying=1
						Tgt.Frozen=1
						Flight(Tgt)
						src.Cooldown()
						spawn(rand(20,30))
							usr.Knockback(10,Tgt,Forced=1)
							Tgt.Frozen=0
							Tgt.Flying=0
			Pull()
				set category="Skills"
				set hidden=1
				if(!usr.CanAttack())return
				if(!src.Using)
					var/mob/Tgt
					var/Distance=20
					if(usr.Target)
						Tgt=usr.Target
					if(Tgt&&Tgt in view(15, usr))
						src.Cooldown(0.5)
						Tgt.Knockbacked=1
						while(Using&&Distance>0)
							Tgt.icon_state="KB"
							step_to(Tgt,usr)
							if(get_dist(usr,Tgt)==1)
								Distance=0
							Distance-=1
							sleep(1)
						Tgt.Knockbacked=0
						Tgt.icon_state=""
			Push()
				set category="Skills"
				set hidden=1
				if(!usr.CanAttack()) return
				if(!src.Using)
					var/mob/Tgt
					if(usr.Target)
						Tgt=usr.Target
					if(Tgt&&Tgt in view(15, usr))
						src.Cooldown(0.5)
						usr.Knockback(20,Tgt,Direction=get_dir(usr,Tgt),Forced=1)
			Throw_Around()
				set category="Skills"
				set hidden=1
				if(!usr.CanAttack()) return
				if(!src.Using)
					var/mob/Tgt
					if(usr.Target)
						Tgt=usr.Target
					if(Tgt&&Tgt in view(15, usr))
						src.Cooldown()
						Tgt.Frozen=1
						spawn(40)
							Tgt.Frozen=0
						Tgt.Knockback(5,Tgt,Direction=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH),Forced=1)
						sleep(8)
						Tgt.Knockback(5,Tgt,Direction=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH),Forced=1)
						sleep(8)
						Tgt.Knockback(5,Tgt,Direction=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH),Forced=1)
						sleep(8)
						Tgt.Knockback(5,Tgt,Direction=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH),Forced=1)
						sleep(8)
						Tgt.Knockback(5,Tgt,Direction=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH),Forced=1)
						sleep(8)
						Tgt.Knockback(5,Tgt,Direction=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH),Forced=1)
			Blast_Away()
				set category="Skills"
				set hidden=1
				if(!usr.CanAttack()) return
				if(!src.Using)
					src.Cooldown(2)
					for(var/mob/m in view(10, usr))
						if(m==usr)
							continue
						spawn()
							m.Frozen=1
							m.Flying=1
							Flight(m)
							spawn(rand(20,30))
								usr.Knockback(20,m,Direction=get_dir(usr,m),Forced=1)
								m.Frozen=0
								m.Flying=0
			Telekinesis()
				set category="Skills"
				if(!src:Choosing)
					src:Choosing=1
					var/Choice=input(usr, "What telekinetic power are you using?", "Improved Telekinesis") in list("Lift and Hold", "Lift and Throw", "Pull", "Push", "Throw Around", "Blast Away", "Cancel")
					switch(Choice)
						if("Lift and Hold")
							if(!usr.CanAttack()) return
							if(!src.Using)
								var/mob/Tgt
								if(usr.Target)
									Tgt=usr.Target
								if(Tgt&&Tgt in oview())
									Tgt.Flying=1
									Tgt.Frozen=1
									Flight(Tgt)
									src.Cooldown(0.75)
									spawn(30)
										Tgt.Frozen=0
										Tgt.Flying=0
						if("Lift and Throw")
							if(!usr.CanAttack()) return
							if(!src.Using)
								var/mob/Tgt
								if(usr.Target)
									Tgt=usr.Target
								if(Tgt&&Tgt in view(15, usr))
									Tgt.Flying=1
									Tgt.Frozen=1
									Flight(Tgt)
									src.Cooldown()
									spawn(rand(10,20))
										usr.Knockback(10,Tgt,Forced=1)
										Tgt.Frozen=0
										Tgt.Flying=0
						if("Pull")
							if(!usr.CanAttack())return
							if(!src.Using)
								var/mob/Tgt
								var/Distance=20
								if(usr.Target)
									Tgt=usr.Target
								if(Tgt&&Tgt in view(15, usr))
									src.Cooldown(0.5)
									Tgt.Knockbacked=1
									while(Using&&Distance>0)
										Tgt.icon_state="KB"
										step_to(Tgt,usr)
										if(get_dist(usr,Tgt)==1)
											Distance=0
										Distance-=1
										sleep(1)
									Tgt.Knockbacked=0
									Tgt.icon_state=""
						if("Push")
							if(!usr.CanAttack()) return
							if(!src.Using)
								var/mob/Tgt
								if(usr.Target)
									Tgt=usr.Target
								if(Tgt&&Tgt in view(15, usr))
									src.Cooldown(0.5)
									usr.Knockback(20,Tgt,Direction=get_dir(usr,Tgt),Forced=1)
						if("Throw Around")
							if(!usr.CanAttack()) return
							if(!src.Using)
								var/mob/Tgt
								if(usr.Target)
									Tgt=usr.Target
								if(Tgt&&Tgt in view(15, usr))
									src.Cooldown()
									Tgt.Frozen=1
									spawn(40)
										Tgt.Frozen=0
									Tgt.Knockback(5,Tgt,Direction=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH),Forced=1)
									sleep(8)
									Tgt.Knockback(5,Tgt,Direction=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH),Forced=1)
									sleep(8)
									Tgt.Knockback(5,Tgt,Direction=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH),Forced=1)
									sleep(8)
									Tgt.Knockback(5,Tgt,Direction=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH),Forced=1)
									sleep(8)
									Tgt.Knockback(5,Tgt,Direction=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH),Forced=1)
									sleep(8)
									Tgt.Knockback(5,Tgt,Direction=pick(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST, SOUTH),Forced=1)
						if("Blast Away")
							if(!usr.CanAttack()) return
							if(!src.Using)
								src.Cooldown(2)
								for(var/mob/m in view(10, usr))
									if(m==usr)
										continue
									spawn()
										m.Frozen=1
										m.Flying=1
										Flight(m)
										spawn(rand(20,30))
											usr.Knockback(20,m,Direction=get_dir(usr,m),Forced=1)
											m.Frozen=0
											m.Flying=0
					src:Choosing=0

	Absorb
		Teachable=0
		Cooldown=30
		icon_state=""
		desc="Allows you to absorb people for their power."
		verb/Absorb()
			set category="Skills"
			usr.SkillX("Absorb",src)

	Clairvoyance
		Teachable=0
		Level=0
		desc="Enhances senses greatly."
		verb/Clairvoyance()
			set category="Skills"
			set name="Clairvoyance"
			usr.SkillX("Clairvoyance",src)

	Reincarnation
		Cooldown=-1
		desc="End their existence."
		verb/Finalize_Fate()
			var/mob/Target=usr.Target
			set category="Skills"
			if(src.Using)
				return
			src.Using=1
			switch(input(usr,"Force [Target] to pass on?") in list("No","Yes"))
				if("Yes")
					if(usr.HasGodKi()&&!Target.HasGodKi())
						if(Target.Dead)
							if(Target.Savable&&!Target.KeepBody)
								if(Target.HasEnlightenment())
									Target.KeepBody=1
								if(Target.HasHellPower())
									if(prob(25))
										Target.KeepBody=1
								if(Target.KeepBody)
									OMsg(Target, "[Target] resists the invocation through regaining their physical body!", "[Target] resisted reincarnation.")
									return
								else
									Target.Reincarnate()
									OMsg(usr, "[usr] forces [Target] to pass into a new existence!", "[usr] REINCARNATED [Target].")
					else
						OMsg(usr, "[Target] resists the godly energies of [usr]!", "[usr] failed to REINCARNATE [Target].")
			src.Using=0
	Destruction
		Cooldown=-1
		desc="End their existence."
		verb/Hakai()
			var/mob/Target=usr.Target
			set category="Skills"
			switch(input(usr,"Delete [Target]?") in list("No","Yes"))
				if("Yes")
					usr<<"No."
					return
					spawn()RecoverImage(Target)
					spawn(2)RecoverImage(Target)
					spawn(4)RecoverImage(Target)
					if(usr.Power*(usr.GetGodKi()**3)>Target.Power*min(Target.GetGodKi()**3,1)||Target.KO)
						Target.Savable=0
						if(istype(Target, /mob/Players))
							fdel("Saves/Players/[Target.ckey]")
						animate(Target,alpha=0,time=30)
						spawn(30)
							del(Target)
						OMsg(usr, "[usr] destroys the existence of [Target]!", "[usr] DESTROYED [Target].")
					else
						OMsg(usr, "[Target] resists the destructive energies of [usr]!", "[usr] failed to DESTROY [Target].")

	Soul_Contract
		var
			ContractKey
			SummonX=0
			SummonY=0
			SummonZ=0
			TeleportX=0
			TeleportY=0
			TeleportZ=0
			Teleported=0
			Summoned=0
			Powerz
		Teachable=0
		Level=100
		icon_state="Majin"
		desc="You've been contracted by a powerful entity.."


	Fly
		icon_state="Fly"
		desc="This allows you to fly while it constantly drains your energy."
		verb/Fly()
			set category="Skills"
			usr.SkillX("Fly",src)
			sleep()

	Meditate
		Learn=list("energyreq"=1000,"difficulty"=2)
		icon_state="Meditate"
		desc="Meditation allows you to recover energy faster then standing, as well as Health and Mana. You are far more likely to be hit in Meditation."
		verb/Meditation()
			set category="Skills"
			if(usr.ActiveZanzo)
				usr.ActiveZanzo=0
			for(var/obj/Skills/Zanzoken/z in usr)
				z.ZanzoAmount=0
			usr.SkillX("Meditate",src)
			sleep(10)

	False_Moon
		Cooldown=-1
		desc="Create a false moon."
		verb/FalseMoon()
			set name="False Moon"
			set category="Skills"
			usr.SkillX("FalseMoon",src)

	Celestial_Invocation
		Cooldown=86400
		CooldownStatic=1
		desc="Call upon a cursed star."
		verb/Celestial_Invocation()
			set name="Celestial Invocation"
			set category="Skills"
			usr.SkillX("CallStar",src)

	Give_Power
		Cooldown=600
		Level=100

		SignatureTechnique=2
		PreRequisite = list("/obj/Skills/Utility/Send_Energy")
		desc="Transfers your power to another."
		SkillCost=50
		verb/GivePower()
			set name="Give Power"
			set category="Skills"
			usr.SkillX("GivePower",src)






	Zanzoken
		SkillCost=50
		Level=100
		Cooldown=10
		CooldownStatic=1
		desc="Allows you to move at high velocities."
		icon_state="Zanzoken"
		name="After Image Strike"
		var/ZanzoDistance
		var/ZanzoArea
		verb/Zanzoken()
			set category="Skills"
			if(usr.MovementCharges>=1 && !usr.ActiveZanzo)
				usr.SkillX("Zanzoken",src)
		verb/Zanzoken2()
			set category="Skills"
			set name="After Image Strike"
			if(usr.MovementCharges>=1 && !usr.AfterImageStrike && !src.Using)
				usr.SkillStunX("After Image Strike",src)

	Walking
		Level=100
		Cooldown=1
		desc="Move with flawless footwork."
		icon_state="Zanzoken"
		verb/Walking()
			set category="Skills"
			usr.SkillX("Walking",src)
	Blink
		desc="Teleport through space."
		icon_state="SI"
		verb/Blink()
			set category="Utility"
			usr.SkillX("Blink",src)

	Six_Paths_of_Pain
		Cooldown=60
		var/ReturnX
		var/ReturnY
		var/ReturnZ
		var/mob/Tgt
		var/list/arsenal=list()
		var/list/mob/Healees=list()
		verb/Deva_Path()
			set hidden=1
			set category="Skills"
			if(!usr.CanAttack())
				return
			if(!src.Using)
				if(usr.CheckSlotless("Susanoo"))
					src.Cooldown(2)
					usr.UseProjectile(new/obj/Skills/Projectile/Zone_Attacks/Shattered_Heaven)
				else
					var/Distance=20
					if(usr.Target&&usr.Target!=usr)
						Tgt=usr.Target
					if(Tgt&&Tgt in view(16, usr))
						src.Cooldown(1/12)
						Tgt.Knockbacked=1
						while(Using&&Distance>0)
							Tgt.icon_state="KB"
							step_to(Tgt,usr)
							if(get_dist(usr,Tgt)==1)
								Distance=0
							Distance-=1
							sleep(1)
						Tgt.Knockbacked=0
						Tgt.icon_state=""
				 // else
				 // 	src.Cooldown(1/12)
				 // 	var/Wave=5
				 // 	for(var/wav=Wave, wav>0, wav--)
				 // 		KenShockwave(usr, icon='KenShockwave.dmi', Size=Wave)
				 // 		Wave/=2
				 // 	for(var/mob/m in view(16, usr))
				 // 		if(m==usr)
				 // 			continue
				 // 		usr.Knockback(30,m,Direction=get_dir(usr,m),Forced=1)
				 // 		m.Frozen=0
				 // 		m.Flying=0
		verb/Asura_Path()
			set hidden=1
			set category="Skills"
			if(!usr.CanAttack())
				return
			if(!src.Using)
				arsenal = general_weaponry_database
				var/obj/Skills/weapon
				weapon = text2path(pick(arsenal))
				weapon = new weapon
				if(istype(weapon, /obj/Skills/Queue))
					usr.SetQueue(weapon)
					src.Cooldown(1/12)
				else if(istype(weapon, /obj/Skills/AutoHit))
					usr.Activate(weapon)
					src.Cooldown(1/12)
				else if(istype(weapon, /obj/Skills/Projectile))
					usr.UseProjectile(weapon)
					src.Cooldown(1/12)
		verb/Human_Path()
			set hidden=1
			set category="Skills"
			if(!usr.CanAttack())
				return
			if(!src.Using)
				if(usr.Target&&usr.Target!=usr)
					Tgt=usr.Target
				if(Tgt&&Tgt.IsGrabbed()==usr)
					src.Cooldown()
					usr.Grab_Release()
					 // Tgt.Leave_Body(ForceVoid=1)
				OMsg(usr, "[usr] tears [Tgt]'s soul out of their body!")
		verb/Beast_Path()
			set hidden=1
			set category="Skills"
			var/list/beasts=list()
			var/mob/Player/AI/summoned_beast
			if(!usr.CanAttack())
				return
			if(!src.Using)
				if(usr.Target&&usr.Target!=usr)
					Tgt=usr.Target
				if(Tgt)
					for(var/mob/Player/AI/M in world)
						beasts.Add(M)
					summoned_beast=pick(beasts)
					summoned_beast.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Godly_Empowerment)
					summoned_beast.loc=locate(usr.x+pick(-1,1), usr.y+pick(-1,1), usr.z)
					summoned_beast.SetTarget(Tgt)
					summoned_beast.ai_alliances += usr.ckey
					Dust(summoned_beast.loc, 3)
					Dust(summoned_beast.loc, 3)
					Dust(summoned_beast.loc, 3)
					src.Cooldown()
		verb/Preta_Path()
			set hidden=1
			set category="Skills"
			if(!usr.CanAttack())
				return
			if(!src.Using)
				src.Cooldown(1/2)
				usr.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Absorbtion_Shield)
		verb/Outer_Path()
			set hidden=1
			set category="Skills"
			if(!usr.CanAttack())
				return
			if(!src.Using)
				var/summon=0
				if(usr.Alert("You sure you want to mass revive? It'll cost your own soul."))
					src.Cooldown()
					switch(input("Summon them?", "", text) in list ("No", "Yes",))
						if("No") summon=0
						if("Yes") summon=1
					for(var/mob/M)
						if(M.Dead)
							M.Revive()
							M.DeathKilled=1
						if(summon)
							M.z=usr.z
					usr.Savable=0
					if(istype(usr, /mob/Players))
						fdel("Saves/Players/[usr.ckey]")
					OMsg(usr, "[src] fades away slowly, sacrificing their entire existence for salvation of others...", "[src] exited the cycle of Samsara.")
					Log("Admin","<font color=blue>[ExtractInfo(usr)] used the power of the Outer Path!")
					animate(usr,alpha=0,time=150)
					sleep(150)
					del(usr)

mob
	var/counterpart = null
/*
/obj/Skills/Counterpart
	verb/Set_Counterpart()
		if(usr.counterpart) return
		var/mob/Player/choice = list()
		for(var/mob/x in oview(2,usr))
			if(x.client)
				var/sameIP = x.client.address == usr.client.address ? TRUE : FALSE
				if(sameIP && !(x.soIgnore && usr.soIgnore)) return
				if(x.isRace(NAMEKIAN) && !x.counterpart)
					choice+=x
		if(length(choice) < 1) return
		 //sloppy but better than before
		choice = input(usr, "what person?") in choice  // should work
		if((input(choice, "Do you want to be [usr]'s counterpart?", "Request") in list("Yes", "No")) == "No" )
			return
		choice.counterpart = usr.ckey
		usr.counterpart = choice.ckey
		choice << "You are now counterparts with [usr]."
		usr << "[choice] accepted being your counterpart"
		AdminMessage("([time2text(world.realtime,"hh:mm")])[usr] is now counterparts with [choice] ")
*/
obj/Turfs/Click(obj/Turfs/T)
	if(usr.Target && usr.Mapper && usr.client.macros.IsPressed("Ctrl"))
		..(src)


turf/Click(turf/T)

	if(usr.Target&&istype(usr.Target,/obj/Others/Build) || usr.client.macros.IsPressed("Ctrl"))
		..()

	else if(usr.Move_Requirements()&&!usr.KO)

		if(locate(/obj/Skills/Teleport/Instant_Transmission,usr.contents))
			if(T) if(T.icon)
				for(var/turf/A in view(0,usr))
					if(A==src)
						return
				if(!T.density&&usr.icon_state!="Meditate"&&!usr.Observing&&(usr.Beaming!=2))
					VanishImage(usr)
					var/formerdir=usr.dir
					usr.Move(src)
					usr.dir=formerdir
					if(usr.Energy<1)
						usr.Energy=1

		else if(locate(/obj/Skills/Blink,usr.contents))
			for(var/obj/Skills/Blink/W in usr.contents)
				if(W.BuffUsing==1&&!usr.Knockbacked&&!usr.Observing&&(!usr.Beaming && !usr.BusterTech))
					if(T) if(T.icon)
						for(var/turf/A in view(0,usr))
							if(A==src)
								return
						if(usr.ManaAmount<((usr.ManaMax-usr.TotalCapacity)*usr.GetManaCapMult()*0.8))
							return
						if(usr.Health<100)
							return
						if(usr.Energy<100)
							return
						if(usr.client.eye!=usr)
							return
						if(!T.density)
							VanishImage(usr)
							var/formerdir=usr.dir
							usr.Move(src)
							usr.LoseMana(glob.BLINK_COST)
							usr.dir=formerdir
							if(usr.ManaAmount<1)
								usr.ManaAmount=0

