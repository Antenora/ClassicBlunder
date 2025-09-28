var/list/SkillTreeList=list("BlastT1"=list(),"BlastT2"=list(),"BlastT3"=list(), \
"BlastT4"=list(),"SwordT1"=list(),"SwordT2"=list(),"SwordT3"=list(),"SwordT4"=list(),"SwordT5"=list(),\
"BeamT1"=list(),"BeamT2"=list(),"BeamT3"=list(),"BeamT4"=list(),"BlastT5"=list(),\
"MagicT1"=list(),"MagicT2"=list(),"MagicT3"=list(),"MagicT4"=list(),"MagicT5"=list(),\
"UnarmedT1"=list(),"UnarmedT2"=list(),"UnarmedT3"=list(),"UnarmedT4"=list(), "UnarmedT5" = list(),\
"UnarmedStyles"=list(),"UnarmedStylesT1"=list(), "UnarmedStylesT2"=list(),"UnarmedStylesT3"=list(), "UnarmedStylesT4"=list(), \
"ElementalStyles"=list(),"HybridStyle"=list(),"SwordStyles"=list(), \
"SwordStylesT1"=list(), "SwordStylesT2"=list(),"SwordStylesT3"=list(), "SwordStylesT4"=list(), \
"ElementalStylesT1"=list(), "ElementalStylesT2"=list(),"ElementalStylesT3"=list(), "ElementalStylesT4"=list(),\
"HybridStylesT1"=list(), "HybridStylesT2"=list(), "HybridStylesT3"=list(), "HybridStylesT4"=list() )
proc/MakeSkillTreeList()
	for(var/x in SkillTree)
		var/Tier = null
		if(!(x in list("UnarmedStyles","ElementalStyles", "ElementalStylesT1", "ElementalStylesT2", \
		"ElementalStylesT3","HybridStyle","SwordStyles", "UnarmedStylesT1", "UnarmedStylesT2", \
		"UnarmedStylesT3", "UnarmedStylesT4", "SwordStylesT1", "SwordStylesT2", "SwordStylesT3", "SwordStylesT4",\
		"HybridStylesT1", "HybridStylesT2", "HybridStylesT3", "HybridStylesT4")))
			Tier = copytext(x,length(x), 0)
		for(var/z in SkillTree[x])
			var/obj/SkillTreeObj/s = new
			var/namez=z
			if(copytext("[z]",1,2)=="/")
				var/pos = 1
				while(findtextEx(namez, "/"))
					namez=copytext(namez, pos+1)
			s.path=z
			s.icon_state = lowertext(namez)

			if(Tier)
				switch(Tier)
					if("1")
						s.cost=TIER_1_COST
					if("2")
						s.cost=TIER_2_COST
					if("3")
						s.cost=TIER_3_COST
					if("4")
						s.cost=TIER_4_COST
					if("5")
						s.cost=TIER_5_COST
			else
				s.cost=SkillTree[x][z]
				s.tier = 0
			s.name="[namez] ([s.cost])"
			s.tier = Tier
			SkillTreeList[x]+=s

var/list/SkillTree=list(

"UnarmedT1"=list(
			"/obj/Skills/Queue/Ikkotsu"=40,
			"/obj/Skills/Queue/Showstopper"=40,
			"/obj/Skills/Queue/Dempsey_Roll"=40,
			"/obj/Skills/Queue/Corkscrew_Blow"=40,

			"/obj/Skills/Queue/Kinshasa"=40,
			"/obj/Skills/Queue/Piston_Kick"=40,
			"/obj/Skills/Queue/Pin"=40,
			"/obj/Skills/Queue/Cripple"=40
),

"UnarmedT2"=list(
			"/obj/Skills/AutoHit/Force_Palm"=80,
			"/obj/Skills/AutoHit/Force_Stomp"=80,
			"/obj/Skills/AutoHit/Phantom_Strike"=80,
			"/obj/Skills/AutoHit/Dragon_Rush"=80,
			"/obj/Skills/Grapple/Suplex"=120,
			"/obj/Skills/Grapple/Burning_Finger"=120,
			"/obj/Skills/AutoHit/Sweeping_Kick"=80,
			"/obj/Skills/AutoHit/Helicopter_Kick"=80
),

"UnarmedT3"=list(
			"/obj/Skills/Grapple/Judo_Throw"=120,
			"/obj/Skills/Grapple/Izuna_Drop"=120,
			"/obj/Skills/AutoHit/Lightning_Kicks"=80,
			"/obj/Skills/AutoHit/Flying_Kick"=80
),

"UnarmedT4"=list(
			"/obj/Skills/Queue/Curbstomp"=160,
			"/obj/Skills/Queue/Soukotsu"=160,
			"/obj/Skills/Queue/Six_Grand_Openings"=160,
			"/obj/Skills/Queue/Skullcrusher"=160,


			"/obj/Skills/AutoHit/Bullrush"=160,
			"/obj/Skills/AutoHit/Spinning_Clothesline"=160,
			"/obj/Skills/AutoHit/Hyper_Crash"=160,
			"/obj/Skills/AutoHit/Dropkick_Surprise"=160
),
"UnarmedT5"=list(
			"/obj/Skills/Grapple/The_Show_Stopper"=TIER_5_COST

),

"BlastT1"=list(
			"/obj/Skills/Projectile/Warp_Strike"=80,
			"/obj/Skills/Projectile/Flare_Wave"=40,
			"/obj/Skills/Projectile/Death_Beam"=40,
			"/obj/Skills/Projectile/Dragon_Nova"=40,
			"/obj/Skills/Projectile/Kienzan"=40,
			"/obj/Skills/Projectile/Energy_Minefield"=80,
			"/obj/Skills/Queue/Light_Rush"=80,
			"/obj/Skills/Queue/Burst_Combination"=80
),

"BlastT2"=list(

			"/obj/Skills/Projectile/Straight_Siege"=40,

			"/obj/Skills/Projectile/Beams/Eraser_Gun"=120,
			"/obj/Skills/Projectile/Beams/Shine_Ray"=120,
			"/obj/Skills/Projectile/Beams/Gamma_Ray"=120,
			"/obj/Skills/Projectile/Beams/Piercer_Ray"=120,
			"/obj/Skills/Projectile/Stealth_Bomb"=80,
			"/obj/Skills/Projectile/Pillar_Bomb"=80
),

"BlastT3"=list(
			"/obj/Skills/Projectile/Rapid_Barrage"=40,
			"/obj/Skills/Projectile/Sudden_Storm"=80,
			"/obj/Skills/Projectile/Tracking_Bomb"=80,
			"/obj/Skills/Projectile/Spirit_Ball"=40,
			"/obj/Skills/Projectile/Crash_Burst"=40
),

"BlastT4"=list(
			"/obj/Skills/AutoHit/Breaker_Wave"=160,
			"/obj/Skills/AutoHit/Blazing_Storm"=160,
			"/obj/Skills/AutoHit/Ghost_Wave"=160,
			"/obj/Skills/AutoHit/Power_Pillar"=160,

			"/obj/Skills/Projectile/Burst_Buster"=160,
			"/obj/Skills/Projectile/Warp_Buster"=160,
			"/obj/Skills/Projectile/Scatter_Burst"=160,
			"/obj/Skills/Projectile/Counter_Buster"=160
),

"MagicT1"=list(
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Reinforce_Object"=40,
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Broken_Phantasm"=40,
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Reinforce_Self"=40,

			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Magic_Trick"=40,
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Magic_Act"=40,
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Magic_Show"=40,

			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Water_Walk"=40,
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Swift_Walk"=40,
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Wind_Walk"=40
),

"MagicT2"=list(
			"/obj/Skills/Projectile/Magic/Fire"=80,
			"/obj/Skills/Projectile/Magic/Fira"=80,
			"/obj/Skills/Projectile/Magic/Firaga"=80,

			"/obj/Skills/AutoHit/Magic/Blizzard"=80,
			"/obj/Skills/AutoHit/Magic/Blizzara"=80,
			"/obj/Skills/AutoHit/Magic/Blizzaga"=80,

			"/obj/Skills/AutoHit/Magic/Thunder"=80,
			"/obj/Skills/AutoHit/Magic/Thundara"=80,
			"/obj/Skills/AutoHit/Magic/Thundaga"=80
),

"MagicT3"=list(
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Stone_Skin"=120,
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/True_Effort"=120,
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Heroic_Will"=120,

			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Mage_Armor"=120,
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Perfect_Warrior"=120,
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Golem_Form"=120,

			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Binding"=120,
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Infect"=120,
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Curse"=120
),

"MagicT4"=list(
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Shell"=160,
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Barrier"=160,
			"/obj/Skills/Buffs/SlotlessBuffs/Magic/Protect"=160,

			"/obj/Skills/AutoHit/Magic/Magnet"=160,
			"/obj/Skills/AutoHit/Magic/Gravity"=160,
			"/obj/Skills/AutoHit/Magic/Stop"=160,

			"/obj/Skills/Projectile/Magic/Disintegrate"=160,
			"/obj/Skills/Projectile/Magic/Meteor"=160,
			"/obj/Skills/AutoHit/Magic/Flare"=160
),

"SwordT1"=list(
			"/obj/Skills/AutoHit/Stinger"=40,
			"/obj/Skills/AutoHit/Sword_Pressure"=40,
			"/obj/Skills/AutoHit/Light_Step"=40,
			"/obj/Skills/AutoHit/Overhead_Divide"=40,
			"/obj/Skills/Queue/Sword_Clinch"=40,

			"/obj/Skills/AutoHit/Hack_n_Slash"=40,
			"/obj/Skills/AutoHit/Vacuum_Render"=40,
			"/obj/Skills/AutoHit/Hamstring"=40,
			"/obj/Skills/AutoHit/Cross_Slash"=40
),

"SwordT2"=list(
			"/obj/Skills/AutoHit/Drill_Spin"=80,
			"/obj/Skills/AutoHit/Rising_Spire"=80,
			"/obj/Skills/AutoHit/Ark_Brave"=80,
			"/obj/Skills/AutoHit/Judgment"=80,
			"/obj/Skills/AutoHit/Three_Thousand_Worlds"=80,
			"/obj/Skills/Queue/Gravity_Blade"=80,
			"/obj/Skills/Queue/Willow_Dance"=80,
			"/obj/Skills/Queue/Zero_Reversal"=80,
			"/obj/Skills/Queue/Infinity_Trap"=80
),

"SwordT3"=list(
			"/obj/Skills/Grapple/Sword/Eviscerate"=120,
			"/obj/Skills/Queue/Run_Through"=120,
			"/obj/Skills/Grapple/Sword/Hacksaw"=120,
			"/obj/Skills/Grapple/Sword/Form_Ataru"=120
),

"SwordT4"=list(
			"/obj/Skills/Projectile/Sword/Backlash_Wave"=160,
			"/obj/Skills/Projectile/Sword/Wind_Scar"=160,
			"/obj/Skills/Projectile/Sword/Air_Carve"=160,
			"/obj/Skills/Projectile/Sword/Phantom_Howl"=160,

			"/obj/Skills/AutoHit/Crowd_Cutter"=160,
			"/obj/Skills/AutoHit/Jet_Slice"=160,
			"/obj/Skills/AutoHit/Holy_Justice"=160,
			"/obj/Skills/AutoHit/Doom_of_Damocles"=160
),

"UnarmedStyles"=list(
			"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Shaolin_Style"=20,
			"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Shield_Style"=20,
			"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Turtle_Style"=20,
			"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Murim_Style"=20,
			"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Lucha_Libre_Style"=20
),
"UnarmedStylesT1"=list(
	"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Red_Cyclone_Style"=9999,
					"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Wushu_Style"=9999,
					"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Black_Leg_Style"=9999,
					"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Wing_Chun_Style"=9999,
					"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Tai_Chi_Style"=9999
					),
"UnarmedStylesT2"=list(
	"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Ubermensch_Style"=9999,
					"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Mantis_And_Crane_Style"=9999,
					"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Long_Fist_Style"=9999,
					"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Divine_Arts_of_The_Heavenly_Demon"=9999
					),
"UnarmedStylesT3"=list(
	"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Flying_Thunder_God"=9999,
					"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Jeet_Kune_Do"=9999,
					"/obj/Skills/Buffs/NuStyle/UnarmedStyle/All_Star_Wrestling"=9999
					),
"UnarmedStylesT4"=list(
	"/obj/Skills/Buffs/NuStyle/UnarmedStyle/God_Fist"=9999,
					"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Ten_Directions"=9999,
					"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Giga_Galaxy_Wrestling"=9999
					),

"HybridStyles"=list(

),
"HybridStylesT1"=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Circuit_Breaker_Style"=99999

),
"HybridStylesT2"=list("/obj/Skills/Buffs/NuStyle/UnarmedStyle/Divine_Arts_of_The_Heavenly_Demon"=9999, 
"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Ifrit_Jambe"=9999,
"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Psycho_Boxing"=9999,
"/obj/Skills/Buffs/NuStyle/UnarmedStyle/Phoenix_Eye_Fist"=9999,
"/obj/Skills/Buffs/NuStyle/SwordStyle/Art_of_Order"=9999
),
"HybridStylesT3"=list(

),

"ElementalStyles"=list(
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Earth_Moving"=20,
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Wind_Summoning"=20,
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Fire_Weaving"=20,
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Water_Bending"=20,
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Plague_Bringer"=20
),
"ElementalStylesT1"=list(
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Magma_Walker"=9999,
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Ice_Dancing"=9999,
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Stormbringer"=9999,
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Inferno"=9999,
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Bloodmancer"=9999
),
"ElementalStylesT2"=list(
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Hellfire"=9999,
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Plasma_Style"=9999,
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Blizzard_Bringer"=9999,
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Hot_n_Cold"=9999
),
"ElementalStylesT3"=list(
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Oblivion_Storm"=9999,
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Annihilation"=9999,
			"/obj/Skills/Buffs/NuStyle/MysticStyle/Omnimancer"=9999
),
"SwordStyles"=list(
			"/obj/Skills/Buffs/NuStyle/SwordStyle/Ittoryu_Style"=20,
			"/obj/Skills/Buffs/NuStyle/SwordStyle/Fencing_Style"=20,
			"/obj/Skills/Buffs/NuStyle/SwordStyle/Ulfberht_Style"=20,
			"/obj/Skills/Buffs/NuStyle/SwordStyle/Gladiator_Style"=20,
			"/obj/Skills/Buffs/NuStyle/SwordStyle/Chain_Style"=20
),
"SwordStylesT1"=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Fist_of_Khonshu"=9999,
					"/obj/Skills/Buffs/NuStyle/SwordStyle/Nito_Ichi_Style"=9999,
					"/obj/Skills/Buffs/NuStyle/SwordStyle/Iaido_Style"=9999,
					"/obj/Skills/Buffs/NuStyle/SwordStyle/Dardi_Style"=9999,
					"/obj/Skills/Buffs/NuStyle/SwordStyle/Kunst_des_Fechtens"=9999),
"SwordStylesT2"=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Santoryu"=9999,
					"/obj/Skills/Buffs/NuStyle/SwordStyle/Berserk"=9999,
					"/obj/Skills/Buffs/NuStyle/SwordStyle/Witch_Hunter"=9999,
					"/obj/Skills/Buffs/NuStyle/SwordStyle/Phalanx_Style"=9999,),
"SwordStylesT3"=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Two_Heaven_As_One"=9999,
					"/obj/Skills/Buffs/NuStyle/SwordStyle/Acrobat"=9999,
					"/obj/Skills/Buffs/NuStyle/SwordStyle/Fierce_Deity"=9999),
"SwordStylesT4"=list("/obj/Skills/Buffs/NuStyle/SwordStyle/Way_of_the_Kensei"=9999,
					"/obj/Skills/Buffs/NuStyle/SwordStyle/Kyutoryu"=9999,
					"/obj/Skills/Buffs/NuStyle/SwordStyle/War_God"=9999),

)

obj/SkillTreeObj
	var/path
	var/cost
	var/tier
	icon='background.dmi'
	layer=9999
	New()
		. = ..()
		icon_state = lowertext(replacetext(replacetext(path,"/obj/Skills/Buffs/NuStyle/UnarmedStyle", ""), "_Style", ""))
		
	Click()

		var/path=text2path("[src.path]")
		var/obj/Skills/s=new path
		var/obj/s2
		var/obj/s3

		if(locate(s,usr.contents))
			usr<< "You already know this skill!"
			del(s)
			return

		var/SwordSkill
		if(s.NeedsSword)
			SwordSkill=1

		if(s.type in usr.SkillsLocked)
			if(usr.Saga=="Weapon Soul"&&SwordSkill)
				goto Bypass1
			usr << "You cannot buy [s] because it is a prerequisite to a skill that you've already upgraded!"
			del s
			return
		Bypass1

		s.skillDescription()
		var/text = s.description
		text += "\n"
		var/Confirm
		if(length(text)>5)
			Confirm=alert(usr, "[text]Are you sure you wish to buy [src] for [src.cost] RPP?", "Buy [s.name]?", "No", "Yes")
		else
			Confirm=alert(usr, "Are you sure you wish to buy [src] for [src.cost] RPP?", "Buy [s.name]?", "No", "Yes")
		if(Confirm=="No")
			del(s)
			return
		if(s.SignatureTechnique>=1)
			return
		if(locate(s,usr.contents))
			usr << "You've already learned [s]."
			del(s)
			return

		if(s.type in usr.SkillsLocked)
			if(usr.Saga=="Weapon Soul"&&SwordSkill)
				goto Bypass2
			usr << "You cannot buy [s] because it is a prerequisite to a skill that you've already upgraded!"
			del s
			return
		Bypass2

		if(istype(s, /obj/Skills))
			if(s:LockOut.len>0)
				for(var/x=1,x<=s:LockOut.len,x++)
					var/found=0
					var/path3=text2path("[s:LockOut[x]]")
					s3=new path3
					if(locate(s3, usr))
						found=1
					if(found)
						if(usr.Saga=="Weapon Soul"&&SwordSkill)
							goto Bypass3
						usr << "You cannot buy [s] when you already possess [s3]!"
						del s3
						return
			Bypass3
			if(s:PreRequisite.len>0)
				for(var/x=1,x<=s:PreRequisite.len,x++)
					var/found=0
					var/path2=text2path("[s:PreRequisite[x]]")
					s2=new path2
					if(locate(s2, usr))
						found=1
					if(!found)
						usr << "You need to buy [s2] before [s]!"
						del s2
						return

		if(usr.SpendRPP(src.cost, "[s]", Training=1))
			usr.AddSkill(s)
			if(s.type==/obj/Skills/Power_Control)
				if(!locate(/obj/Skills/Buffs/ActiveBuffs/Ki_Control, usr))
					usr.PoweredFormSetup()
		..()


mob/Players/verb
	Acquire_Skills()
		set category="Other"
		set hidden=1
		if(!(world.time > verb_delay)) return
		verb_delay=world.time+1
		winshow(usr,"skilltree",1)
	skilltreez(var/z as text)
		set hidden=1//interface verb doesnt needa be found out
		if(!(world.time > verb_delay)) return
		verb_delay=world.time+1
		winset(usr,"skilltreegrid","cells=0x0")//clears grid
		usr<<output("RPP: [round(usr.GetRPPSpendable())]","STRewardPoints")
		sleep(1)
		if(copytext(z, length(z)-5, length(z)+1) == "Styles")
			var/x = 1
			var/y = 1
			for(var/obj/SkillTreeObj/s in SkillTreeList[z])
				usr<<output(s,"skilltreegrid:[x],[y]")
				x++
				if(x>2)
					x = 1
					y++
			for(var/tier in 1 to 4)
				var/string = "[z]T[num2text(tier)]" // STYLESTX
				for(var/obj/SkillTreeObj/s in SkillTreeList[string])
					usr<<output(s,"skilltreegrid:[x],[y]")
					x++
					if(x>2)
						x = 1
						y++
		else
			var/x = 1
			var/y = 1
			for(var/obj/SkillTreeObj/s in SkillTreeList[z])
				usr<<output(s,"skilltreegrid:[x],[y]")
				x++
				if(x>2)
					x = 1
					y++



/globalTracker/var/list/KI_CONTROL_PASSIVES = list("Flicker", "Pursuer", "Instinct", )


mob/proc
	PoweredFormSetup()
		src << "Powering up to a certain level will activate your Powered Form which will provide a sharp increase in your fighting prowess!"
		var/obj/Skills/Buffs/ActiveBuffs/Ki_Control/KC=new
		KC.selectedPassive = input(src, "Pick a focus") in glob.KI_CONTROL_PASSIVES
		var/list/stats = list("Str", "For", "Spd", "End", "Off","Def")
		while(length(KC.selectedStats)<3)
			KC.selectedStats += input(src, "Pick a stat") in stats
			stats -= KC.selectedStats[length(KC.selectedStats)]
		KC.init(src)
		if(src.isRace(MAKYO))
			KC.icon=src.ExpandBase
			KC.IconReplace=1
		src.AddSkill(KC)