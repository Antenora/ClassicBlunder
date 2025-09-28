
mob/var/list/killed_AI

mob/Players/verb/CheckAIKills()
	set name = "Check AI Kills"
	set category = "Other"
	usr << "Your current AI kills are:"
	for(var/i in killed_AI)
		usr << "[i] - [killed_AI[i]]"

/mob/Admin3/verb/AdminCheckAIKills(mob/Players/m in players)
	set name = "Admin Check AI Kills"
	usr << "[m]'s current AI kills are:"
	for(var/i in m.killed_AI)
		usr << "[i] - [m.killed_AI[i]]"

update_loop/special_loop/ai_tracker_loop


	New(tick_lag = 0)
		..()
		src.tick_lag = tick_lag
		src.next_tick=world.time+Second(30)
		updaters = new
		for(var/obj/AI_Spot/ais in world)
			if(ais in src.updaters)
				continue
			src.updaters.Add(ais)
		global_loop.Add(src)


	Add(updater)
		if(!(updater in updaters))
			src.updaters.Add(updater)


	Update(var/forced=0)
		if(WorldLoading)
			return
		next_tick = world.time + Second(30)
		for(var/obj/AI_Spot/a in src.updaters)
			if(a.ai_active.len < a.ai_limit)
				a.minute_pass()

/*ai_spawns
	var
		z_plane
		ai_limit
		list/ai_options*/

	/*arcane_traverse
		z_plane = 6
		ai_limit = 15
		ai_options=list("arcane beast")

	demon_island
		z_plane = 8
		ai_limit = 15
		ai_options=list("wild monster")*/

mob/Admin2/verb/ModifyCompanion(obj/Skills/Companion/A in world)
	set category=null
	set name="Modify Companion"
	var/list/options = list("Add Companion Skill")

	if(istype(A, /obj/Skills/Companion/PlayerCompanion/Squad))
		options += "Add Squad Member"
		options += "Remove Squad Member"

	var/choice = input("??") as null|anything in options
	switch(choice)
		if("Add Companion Skill")
			var/blah={"<html><Magic><body bgcolor=#000000 text="white" link="red">"}
			var/list/B=new
			blah+="[A]<br>[A.type]"
			blah+="<table width=10%>"
			if("Skills") B.Add(typesof(/obj/Skills))
			for(var/C in B)
				blah+="<td><a href=byond://?src=\ref[A];action=companionskill;var=[C]>"
				blah+="[C]"
				blah+="<td></td></tr>"
			blah += "</html>"
			usr<<browse(blah,"window=[A];size=450x600")
		if("Add Squad Member")
			for()
				var/index = input("Which AI would you like to grant to the squad?") as null|anything in squad_database
				if(index)
					var/obj/Skills/Companion/PlayerCompanion/Squad/s = A
					s.AddNewMember(index)
				else
					break
		if("Remove Squad Member")
			for()
				var/obj/Skills/Companion/PlayerCompanion/Squad/s = A
				var/index = input("Which AI would you like to grant to the squad?") as null|anything in s.squad
				if(index)
					s.RemoveMember(index)
				else
					break


/* Database ai properties are not up to date.
mob/Admin2/verb/CreateAI()
	set category="Admin"
	set name = "Create AI"
	var/index = input("Which?") in ai_database | null
	if(index)
		var/mob/Player/AI/a = new
		a.loc = locate(x,y,z)
		a.ai_state = null
		a.AI_Database_Sync(index)
		usr << "[a] has been created!"
		sleep(50)
		a.ai_state = "Idle"
*/

var/list/ai_sig_pool = list(
	"/obj/Skills/AutoHit/Cast_Fist",\
	"/obj/Skills/AutoHit/Wolf_Fang_Fist",\
	"/obj/Skills/AutoHit/NovaStrike",\
	"/obj/Skills/AutoHit/One_Inch_Punch",\
	"/obj/Skills/AutoHit/Lariat",\
	"/obj/Skills/AutoHit/Hyper_Tornado",\
	"/obj/Skills/AutoHit/Shining_Sword_Slash",\
	"/obj/Skills/AutoHit/Massacre",\
	"/obj/Skills/AutoHit/Slam_Wave",\
	"/obj/Skills/AutoHit/Shadow_Cut",\
	"/obj/Skills/AutoHit/Ikki_Tousen",\
	"/obj/Skills/AutoHit/Taiyoken",\
	"/obj/Skills/AutoHit/Fire_Breath",\
	"/obj/Skills/Projectile/Makosen",\
	"/obj/Skills/Projectile/Jecht_Shot",\
	"/obj/Skills/Projectile/Spirit_Gun",\
	"/obj/Skills/Projectile/Big_Bang_Attack",\
	"/obj/Skills/Projectile/Death_Ball",\
)
var/list/ai_autohit_pool=list(
	"/obj/Skills/AutoHit/AntennaBeam","/obj/Skills/AutoHit/SweepingKick",\
	"/obj/Skills/AutoHit/HelicopterKick","/obj/Skills/AutoHit/LegSweep",\
	"/obj/Skills/AutoHit/RushStrike","/obj/Skills/AutoHit/PhantomStrike",\
	"/obj/Skills/AutoHit/DragonRush","/obj/Skills/AutoHit/Roundhouse",\
	"/obj/Skills/AutoHit/Lightning_Kicks","/obj/Skills/AutoHit/FlyingKick",\
	"/obj/Skills/AutoHit/FocusPunch","/obj/Skills/AutoHit/ForcePalm",\
	"/obj/Skills/AutoHit/ForceStomp","/obj/Skills/AutoHit/Clothesline",\
	"/obj/Skills/AutoHit/SpinningClothesline","/obj/Skills/AutoHit/Bullrush",\
	"/obj/Skills/AutoHit/Tipper","/obj/Skills/AutoHit/SwordPressure",\
	"/obj/Skills/AutoHit/Stinger","/obj/Skills/AutoHit/ArcSlash",\
	"/obj/Skills/AutoHit/RendingChop","/obj/Skills/AutoHit/HackNSlash",\
	"/obj/Skills/AutoHit/SweepingBlade","/obj/Skills/AutoHit/SweepingRush",\
	"/obj/Skills/AutoHit/SpiralBlade","/obj/Skills/AutoHit/SpinRave",\
	"/obj/Skills/AutoHit/TornadoRave","/obj/Skills/AutoHit/ArkBrave",\
	"/obj/Skills/AutoHit/RecklessCharge","/obj/Skills/AutoHit/BloodRush",\
	"/obj/Skills/AutoHit/SoulCharge","/obj/Skills/AutoHit/Judgment",\
	"/obj/Skills/AutoHit/HolyJudgment","/obj/Skills/AutoHit/DarkPurge",\
	"/obj/Skills/AutoHit/FlashCutter","/obj/Skills/AutoHit/CrowdCutter",\
	"/obj/Skills/AutoHit/JetSlicer","/obj/Skills/AutoHit/Pinpoint_Blast",\
	"/obj/Skills/AutoHit/Destruction_Wave","/obj/Skills/AutoHit/Blazing_Storm",\
)
var/list/ai_projectile_pool = list(
	"/obj/Skills/Projectile/Blast",\
	"/obj/Skills/Projectile/Consecutive_Blast",\
	"/obj/Skills/Projectile/Rapid_Barrage",\
	"/obj/Skills/Projectile/Charge",\
	"/obj/Skills/Projectile/Shine_Shot",\
	"/obj/Skills/Projectile/Feint_Shot",\
	"/obj/Skills/Projectile/Scatter_Shot",\
	"/obj/Skills/Projectile/Scatter_Burst",\
	"/obj/Skills/Projectile/Scatter_Shotgun",\
	"/obj/Skills/Projectile/Shard_Storm",\
	"/obj/Skills/Projectile/Energy_Bomb",\
	"/obj/Skills/Projectile/Energy_Minefield",\
	"/obj/Skills/Projectile/Tracking_Bomb",\
	"/obj/Skills/Projectile/Spirit_Ball",\
	"/obj/Skills/Projectile/Crusher_Ball",\
	"/obj/Skills/Projectile/Chasing_Bullet",\
	"/obj/Skills/Projectile/Dragon_Nova",\
	"/obj/Skills/Projectile/Dragon_Buster",\
	"/obj/Skills/Projectile/Dragon_Cluster",\
	"/obj/Skills/Projectile/Phoenix_Feathers",\
	"/obj/Skills/Projectile/Buster_Barrage",\
	"/obj/Skills/Projectile/Sword/AirRender",\
	"/obj/Skills/Projectile/Sword/UnerringSlice",\
	"/obj/Skills/Projectile/Sword/BoundlessCut",\
	"/obj/Skills/Projectile/Sword/ScathingBreeze",\
	"/obj/Skills/Projectile/Sword/WindScar",\
	"/obj/Skills/Projectile/Sword/BacklashWave",\
	"/obj/Skills/Projectile/Zone_Attacks/Hellzone_Grenade",\
	"/obj/Skills/Projectile/Zone_Attacks/Homing_Finisher",\

)
var/list/ai_buff_pool = list(
	"/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Swell_Up",\
	"/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Round_Two",\
	"/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Metal_Coat",\
	"/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Turns_Red",\
)

var/list/ai_icon_database = list(
	"Green Dragon"='Green Dragon.dmi',\
	"Blue Dragon"='Blue Dragon.dmi',\
	"Crystal"='Crystal1.dmi',\
	"Crystal2"='Crystal2.dmi',\
	"Fairy1"='Fairy1.dmi',\
	"Fairy2"='Fairy2.dmi',\
	"Fairy3"='Fairy3.dmi',\
	"Snake"='Snake.dmi',\
	"Red Dragon"='Red Dragon.dmi',\
	"Black Dragon"='Black Dragon.dmi',\
	"Demon1"='Demon1.dmi',\
	"Demon2"='Demon2.dmi',\
	"Demon3"='Demon3.dmi',\
	"Demon4"='Demon4.dmi',\
	"Demon5"='Demon5.dmi',\
	"Undead"='Undead.dmi',\
	"Zombie"='Zombie.dmi',\
	"Chaos Chosen"='Chaos_Chosen.dmi',\
	"Bat"='Bat.dmi',\
	"Cat"='Cat.dmi',\
	"Chicken"='Chicken.dmi',\
	"Cow"='Cow.dmi',\
	"Frog"='Frog.dmi',\
	"Horse"='Horse.dmi',\
	"Penguin"='Penguin.dmi',\
	"Sheep"='Sheep.dmi',\
	"Turtle"='Turtle.dmi',\
	"Wolf"='Wolf.dmi'\
)



var/list/ai_database = list(
	"arcane beast" = new/ai_sheet(id="arcane beast",properties=list(hostile_randomize=1),\
		techniques=-1,\
		icons=list(
			'Green Dragon.dmi'=list("name"="Arcane Green Dragon"),\
			'Blue Dragon.dmi'=list("name"="Arcane Blue Dragon"),\
			'Crystal1.dmi'=list("name"="Magicite Effigy"),\
			'Crystal2.dmi'=list("name"="Dark Magicite Effigy"),\
			'SpriteCrystal.dmi'=list("name"="Magicite Archons"),\
			'SpriteR.dmi'=list("name"="Arcane Archon"),\
			'SpriteY.dmi'=list("name"="Arcane Archon"),\
			'SpriteC.dmi'=list("name"="Arcane Archon"),\
			'SpriteG.dmi'=list("name"="Arcane Archon"),\
			'Fairy1.dmi'=list("name"="Arcane Fairy"),\
			'Fairy2.dmi'=list("name"="Arcane Fairy"),\
			'Fairy3.dmi'=list("name"="Arcane Fairy"),\
		)
	),
	"hell beast" = new/ai_sheet(id="hell beast",properties=list(hostile_randomize=2),\
		techniques=-1,\
		icons=list(
			'Snake.dmi'=list("name"="Hellspawn Serpent"),\
			'Red Dragon.dmi'=list("name"="Hellspawn Red Dragon"),\
			'Black Dragon.dmi'=list("name"="Hellspawn Black Dragon"),\
			'Demon1.dmi'=list("name"="Red Imp"),\
			'Demon2.dmi'=list("name"="Blue Imp"),\
			'Demon3.dmi'=list("name"="Stone Imp"),\
			'Demon4.dmi'=list("name"="Grand Imp"),\
			'Demon5.dmi'=list("name"="Hell Crawler"),\
			'Undead.dmi'=list("name"="Death Soldier"),\
			'Zombie.dmi'=list("name"="Death Warrior"),\
			'Chaos_Chosen.dmi'=list("name"="Death Knight"),\
		)
	),
	"wild monster" = new/ai_sheet(id="wild monster",properties=list(hostile_randomize=3),\
		techniques=-1,\
		icons=list(
			'Saibaman.dmi'=list("name"="Saibaman"),\
			'WildHound.dmi'=list("name"="Fellhound"),\
			'Phoenix.dmi'=list("name"="Avian"),\
			'WolfBeast.dmi'=list("name"="Beastman"),\
			'Red Dragon.dmi'=list("name"="Red Dragon"),\
			'Black Dragon.dmi'=list("name"="Black Dragon"),\
			'Green Dragon.dmi'=list("name"="Green Dragon"),\
			'Blue Dragon.dmi'=list("name"="Blue Dragon"),\
			'Aquinian.dmi'=list("name"="Squid Monster"),\
			'Kobold.dmi'=list("name"="Kobold"),\
			'Komfty Kobold.dmi'=list("name"="Kobold Warrior"),\
			'Kobold King.dmi'=list("name"="Kobold Hunter"),\
			'Tricera.dmi'=list("name"="Flying Wyvern"),\
		)
	),


	"wolf" = new/ai_sheet(id="wolf",properties=list(icon='Wolf.dmi',name="Wolf",\
		BaseMod=1,ai_adapting_power=0,\
		StrMod=3,EndMod=6,ForMod=0.1,OffMod=6,DefMod=4,SpdMod=3,Potential=-1,\
		ai_hostility=2,ai_wander=1,ai_spammer=0.5),\
		techniques=list("/obj/Skills/AutoHit/RushStrike","/obj/Skills/AutoHit/Howl","/obj/Skills/AutoHit/SweepingKick")),

	"frog" = new/ai_sheet(id="frog",properties=list(icon='Frog.dmi',name="Frog",\
		BaseMod=1.5,ai_adapting_power=0,\
		StrMod=1.5,EndMod=1.5,ForMod=1.5,OffMod=1.5,DefMod=1.5,SpdMod=1.5,Potential=-1,\
		ai_hostility=1,ai_wander=1),\
		techniques=list("/obj/Skills/AutoHit/RushStrike")),

	"xenomorph" = new/ai_sheet(id="xenomorph",properties=list(icon='xenomorph.dmi',name="Xenomorph",\
		BaseMod=3,ai_adapting_power=0,\
		StrMod=4,EndMod=2,ForMod=1.5,OffMod=5,DefMod=3,SpdMod=4,Potential=-1,\
		ai_hostility=2,ai_wander=0,ai_alliances=list("Xenomorph")),\
		techniques=list("/obj/Skills/AutoHit/RushStrike")),

	"xenomorph ravager" = new/ai_sheet(id="xenomorphravager",properties=list(icon='runner.dmi',name="Xenomorph Ravager",\
		BaseMod=7,ai_adapting_power=0.5,\
		StrMod=6,EndMod=5,ForMod=1.5,OffMod=5,DefMod=3,SpdMod=3,Potential=-1,\
		ai_hostility=2,ai_wander=1, ai_alliances=list("Xenomorph")),\
		techniques=list("/obj/Skills/AutoHit/RushStrike")),

	"xenomorph runner" = new/ai_sheet(id="xenomorphrunner",properties=list(icon='runner.dmi',name="Xenomorph Runner",\
		BaseMod=2.5,ai_adapting_power=0.5,\
		StrMod=3,EndMod=3,ForMod=1.5,OffMod=6,DefMod=3,SpdMod=6,Potential=-1,\
		ai_hostility=2,ai_wander=1,ai_alliances=list("Xenomorph")),\
		techniques=list("/obj/Skills/AutoHit/RushStrike")),
	"xenomorph spitter" = new/ai_sheet(id="xenomorphspitter",properties=list(icon='xenomorph.dmi',name="Xenomorph Spitter",\
		BaseMod=4,ai_adapting_power=0.5,\
		StrMod=3,EndMod=3,ForMod=8,OffMod=4,DefMod=3,SpdMod=5,Potential=-1,\
		ai_hostility=2,ai_wander=1,ai_alliances=list("Xenomorph")),\
		techniques=list("/obj/Skills/Projectile/Shine_Shot","/obj/Skills/Projectile/Charge","/obj/Skills/Projectile/Blast")),

	"xenomorph praetorian" = new/ai_sheet(id="xenomorphpraetorian",properties=list(icon='xenomorph.dmi',name="Xenomorph Praetorian",\
		BaseMod=10,ai_adapting_power=1,Mythical=1,\
		StrMod=7,EndMod=5,ForMod=1.5,OffMod=5,DefMod=1.5,SpdMod=4,Potential=100,\
		ai_hostility=2,ai_wander=1,ai_alliances=list("Xenomorph")),\
		techniques=list("/obj/Skills/AutoHit/RushStrike","/obj/Skills/AutoHit/PhantomStrike","/obj/Skills/AutoHit/Knockoff_Wave","/obj/Skills/Projectile/Shine_Shot","/obj/Skills/Projectile/Dragon_Buster")),
)
ai_sheet //need to include icon scale
	parent_type = /datum
	var
		id
		random_techs
		list/properties = list() //List of variables.
		list/icons = list() //associate names with them.
		list/techniques = list() //List of skill paths.

	New(id,list/properties,list/techniques, list/icons)
		src.id = id
		src.properties = properties
		src.techniques = techniques
		src.icons = icons
		src.random_techs = random_techs



//Maybe sparring AI responds to cooldowns whe na player is facing them.
mob/Player/AI
	New()
		..()
		race = new/race/human()
		if(!passive_handler) passive_handler = new()
		MovementCharges = 5
		ai_state = "Idle"
		ticking_ai.Add(src)
		if(!locate(/obj/Skills/Meditate,contents))
			contents+=new/obj/Skills/Meditate
		if(!locate(/obj/Skills/Queue/Heavy_Strike,contents))
			contents+=new/obj/Skills/Queue/Heavy_Strike
			contents+=new/obj/Skills/Reverse_Dash
		if(!locate(/obj/Skills/Grapple/Toss,contents))
			contents+=new/obj/Skills/Aerial_Recovery
			contents+=new/obj/Skills/Grapple/Toss
		if(!locate(/obj/Skills/Dragon_Dash,contents))
			contents+=new/obj/Skills/Dragon_Dash
			contents+=new/obj/Skills/Aerial_Payback
			contents+=new/obj/Skills/Target_Switch
		if(!locate(/obj/Skills/Target_Clear,contents))
			contents+=new/obj/Skills/Target_Clear
//		if(!locate(/obj/Skills/Power_Recovery,contents))
//			contents+=new/obj/Skills/Power_Recovery
		if(!src.MobColor)
			src.MobColor=list(1,0,0, 0,1,0, 0,0,1, 0,0,0)
		AppearanceOn()

	Del()
		loc = null
		ai_loop.Remove(src)
		ticking_ai.Remove(src)
		if(senpai)
			senpai.ai_active.Remove(src)
			senpai = null
		ai_state = null
		BreakViewers()
		RemoveTarget()
		for(var/obj/Skills/s in src)
			s.AssociatedLegend = null
			s.AssociatedGear = null
			s.loc = null
			DeleteSkill(s, 1)
		if(active_projectiles.len>0)
			for(var/obj/Skills/Projectile/_Projectile/p in active_projectiles)
				p.endLife()
		for(var/i in vis_contents)
			vis_contents -= i
		companion_ais.Remove(src)
		sleep(100)
		transform = null
		filters = null
		dd = null
		Hair = null
		passive_handler = null
		race = null
		GlobalCooldowns = null
		SkillsLocked = null
		OldLoc = null
		aggro_damage = null
		Splits = null
		information = null
		secretDatum = null
		MonkeySoldiers = null
		knowledgeTracker = null
		equippedSword = null
		equippedArmor = null
		equippedWeights = null
		play_action = null
		overlays = null
		underlays = null
		..()
	icon = 'Makyo1.dmi'

	var/tmp
		obj/AI_Spot/senpai=null//connector to the spot that spawned the ai
		shifts_target=0//looks for a new target every 30 * this value seconds
		targetting=0//counter for when to shift target
		mob/Player/ai_owner = null
		ai_state = "Idle"
		go_home=0
		ai_accuracy = 100
		ai_vision = 3 // Ai's sight range. Tracking is lost at this distance * 2
		ai_hostility = 1 //1 = Responds to attack and countdowns (facing them). 2 = Actively Seeks Targets.
		//Mobs who respond to attacks should flash red in ANGEEER!!!

		ai_facedir //The direction the mob is facing as an angle.

		ai_flickshot = 1 //Ai will make sudden turns to fire projectiles.

		ai_adapting_power = 0
		ai_power_adapted = 0 //Set to true the first time an AI takes damage.
		ai_adapting_max = 0 //Max power an AI may achieve.

		ai_team
		//list/ai_alliances = list()

		stall_probability = 1
		ai_stall = 0 //Causes Update() to sleep.
		ai_turn_stall = 0
		ai_last_dirshift
		ai_movement_type = "melee" //Null = Default. Erratic movements, good for dueling.
		//"Rush". AI will run linearly toward an opponent.
		//"Circle" An AI will run mad circles.
		//"Cricle Owner" An AI will continously rotate around its Owner. This limits attacks to things like blast..

		ai_focus_owner_target
		ai_team_fire = 1

		ai_next_skill = 0
		ai_next_projectile = 0
		ai_next_qeueuable = 0
		ai_next_autohit = 0

		ai_follow = 0 //Follows Owner
		ai_protection = 0 //An AI will respond to attacks against its owner if they're within this amount of tiles. This means they will change targets by force.
		ai_follow_limit = 0 //This is the max range an AI can be from it's owner. They will abandon combat to return.
		ai_follow_teleport = 0 //Beyond this range, an AI will teleport back to its owner. Used for stands.
		ai_wander = 1

		ai_spammer = 1 //Divides into AI cooldown.

		ai_aggression = 0 //An AI will alert a mob/player when they come within range. This is the amount of time before they will attack. 10 seconds - ai_aggression

		ai_techniques_only = 0 //An AI will only fire off techniques. No DDash or Normal Attack. Use in combination with movement type.

		ai_command = 0 //Will not act unless told to.

		next_move

		ai_next_gainloop

		ai_prev_position
		ai_trapped_check

		//Add in movement paths.
		//Circular, Zig Zag, Cardinal Orientation (Barely moves Diags). Strafing
		target_position
		return_position
		hold_position

		prioritize_players
		list/aggro_damage = list()

		max_hold_distance = 3

		difficulty = 0 //difficulty 0 gives no potential on kill; otherwise it is a rating for how much potential is given

		ai_delayed

		team_fire = 1

		ko_death

		hostile_randomize
		ai_play_action/play_action
		list/ai_tmpprops = list()
		ai_type

		last_zanzo
		cloud_yeet_delay
		hostile

		last_loc
		last_loc_tick = 0

	CheckAscensions() //override to do nothing
	proc/
		EndLife(animatedeath=1) //Clear all references in this proc.
			set waitfor=0
			del src

		GenerateAppearance(var/is_monster, include_clothes=1)
			//No arguement = Human. 1 = Picks from all monster icons. If passed as a list, it will choose icon from that list.
			//include_clothes puts attire on the mothafucka
		AI_Database_Sync(var/id, database_override)
			var/ai_sheet/a = database_override ? database_override[id] : ai_database[id]
			if(!a) return
			for(var/v in a.properties)
				vars[v] = a.properties[v]

			if(a.techniques == -1 || hostile_randomize)
				var/minimum_tech = rand(4,12)
				while(minimum_tech>0)
					var/new_type = pick(ai_autohit_pool + ai_projectile_pool)
					if(ispath(text2path(new_type)))
						var/path = text2path(new_type)
						contents += new path
					minimum_tech--

				var/minimum_sig = rand(1,3)
				while(minimum_sig>0)
					var/new_type = pick(ai_sig_pool)
					if(ispath(text2path(new_type)))
						var/path = text2path(new_type)
						contents += new path
					minimum_sig--

				if(prob(25))
					var/new_type = pick(ai_buff_pool)
					if(ispath(text2path(new_type)))
						var/path = text2path(new_type)
						contents += new path



			else
				for(var/t in a.techniques)
					if(ispath(text2path(t)))
						var/path = text2path(t)
						AddSkill(new path)

			AddSkill(new/obj/Skills/Zanzoken)

			for(var/obj/Skills/Projectile/s in src)
				s.Divide=0
				s.MiniDivide=0

			if(a.icons)
				var/list/index = pick(a.icons)
				icon = index
				index = a.icons[index]
				if(index["name"]) name = index["name"]
				if(index["pixel_x"]) pixel_x = index["pixel_x"]
				if(index["pixel_y"]) pixel_y = index["pixel_y"]

			if(Potential == -1)
				Potential = rand(1,100)

			if(hostile_randomize)
				prioritize_players = 1
				Potential = rand(1,100)
				ai_adapting_power = -1
				StrMod = rand(300,600)/100
				ForMod = rand(300,600)/100
				EndMod = rand(300,600)/100
				OffMod = rand(150,300)/100
				DefMod = rand(150,300)/100
				SpdMod = rand(150,300)/100
				RecovMod = rand(2,3)

				if(prob(10)) //fuck with me nigga
					passive_handler.Increase("GiantForm", 1)
					transform*=2
					appearance_flags+=512


				Intimidation = rand(1,15)
				AngerMax+=rand(1,150)/100

				HealthCut = rand(25,50)/100
				if(prob(15))
					HealthCut=0

				ai_hostility=pick(1,1,2,2,2,2,2) // 1x ok, 5x fuck you
				ai_wander=1

				WoundIntent=1 //Fuck you

				difficulty = 1.5 * 1+(Potential/50)
				difficulty += Intimidation/20
				if(Lethal) difficulty+=2

				if(HealthCut) difficulty *= 1 - (HealthCut/2)
				else difficulty += 1

				ai_adapting_power = rand(60,80)/100

				switch(hostile_randomize)
					if(1) //Arcane Beast
						if(prob(25 * difficulty * rand(1,3)))
							contents += new/obj/Money
							for(var/obj/Money/m in src)
								m.Level = round(glob.progress.EconomyCost * min(0.4, (0.1 * difficulty)))
								m.name = "[m.Level] Credits"
						if(prob(10))
							contents += new/obj/Items/Enchantment/PhilosopherStone/Magicite
							for(var/obj/Items/Enchantment/PhilosopherStone/Magicite/m in src)
								m.CurrentCapacity = rand(25,50)
								m.MaxCapacity=m.CurrentCapacity
					if(2) //Hell Beast
						HealthCut=0
						if(prob(50 * difficulty * rand(1,3)))
							contents += new/obj/Money
							for(var/obj/Money/m in src)
								m.Level = round(glob.progress.EconomyCost * min(0.4, (0.15 * difficulty)))
								m.name = "[m.Level] Credits"
						if(prob(5))
							contents += new/obj/Items/Enchantment/PhilosopherStone/Magicite
							for(var/obj/Items/Enchantment/PhilosopherStone/Magicite/m in src)
								m.CurrentCapacity = rand(25,50)
								m.MaxCapacity=m.CurrentCapacity
					if(3) //Wild Monsters
						HealthCut=0
						ai_hostility = 0
						if(prob(50)) ai_hostility=1
						if(prob(50)) ai_hostility=2

						switch(ai_hostility)
							if(0) name = "Friendly [name]"
							if(1) name = "[name]"
							if(2)
								if(prob(5))
									name = "Feral [name]"
									passive_handler.Increase("HellPower", 1)
								else
									name = "[pick("Murderous","Angry","Aggressive","Hungry","Maddened")] [name]"
						if(prob(25 * difficulty * rand(1,3)))
							contents += new/obj/Money
							for(var/obj/Money/m in src)
								m.Level = round(glob.progress.EconomyCost * max(0.05,min(0.4, (0.075* ai_hostility * difficulty))))
								m.name = "[m.Level] Credits"
						if(prob(5) && ai_hostility)
							contents += new/obj/Items/Enchantment/PhilosopherStone/Magicite
							for(var/obj/Items/Enchantment/PhilosopherStone/Magicite/m in src)
								m.CurrentCapacity = rand(25,50)
								m.MaxCapacity=m.CurrentCapacity
			if(ai_adapting_power == -1)
				ai_adapting_power = rand(60, 180)/100

		AllianceCheck(mob/Player/target)
			if(!target) target = Target
			if(ismob(target))
				if(target == ai_owner) return 1
				if(prioritize_players && !target.client) return 1
				for(var/x in src.ai_alliances)
					if(x==target.name)
						return 1
					if(x==target.ckey)
						return 1
					if(target.ai_alliances.len>0)
						for(var/y in target.ai_alliances)
							if(y==x)
								return 1
				if(istype(target, /mob/Player/AI))
					for(var/index in ai_alliances)
						if("[index]" in target:ai_alliances)
							return 1
			return 0

		HitCheck()
			var/list/to_hit = list()
			for(var/mob/m in oview(1, src))
				if(AllianceCheck(m))
					continue
				to_hit += m
			return to_hit

		FindTarget()
			for(var/mob/P in view(ai_vision,src))
				if(prioritize_players && !P.client) continue
				if(P == src) continue
				if(P.invisibility > src.see_invisible)
					continue

				if(AllianceCheck(P)) continue
				if(Target && P==Target) continue

				if(!return_position && !hold_position) return_position = loc
				SetTarget(P)
				return 1
		WalkPosition()
			var direction = angle2dir(ai_facedir)
			var atom/location = get_step(src,direction)
			var atom/prev_location
			for(var/x = 1 to 3 step 1)
				prev_location = location
				location = get_step(location,direction)
				if(location && location.density)
					location = prev_location
					break
			if(location && location.density)
				ai_facedir += pick(180,180,-90,90)
				//attempt escape
			return location



	IdleFire
		New()
			..()
			contents += new/obj/Skills/Projectile/Straight_Siege
		Update()
			TotalFatigue=0
			Energy=100
			dir = WEST
			for(var/obj/Skills/Projectile/Straight_Siege/b in src)
				b.Cooldown=0
				UseProjectile(b)

	Update()
		set waitfor=0
		if(src.Health<=0 && !src.KO)
			Unconscious(null,"?!?!")

		if((src.Health+1 >= 100 - (100*HealthCut)-1) || (src.Energy+1 >= 100 - (100*EnergyCut)-1) || (src.ManaAmount+1 >= 100 - (100*ManaCut)-1))
			if(world.time >= ai_next_gainloop)
				aiGain()
				ai_next_gainloop = world.time + 10
		else
			if(world.time >= ai_next_gainloop)
				aiGain()
				ai_next_gainloop = world.time + 100
		// ??? this makes their next loop 10 seconds instead of 1?


		if(play_action)
			play_action.Update(src)
			return

		if(src.KO)
			if(src.KOTimer > 60)
				KOTimer=60
			return
		if(ai_stall)
			ai_stall--
			return
		if(ai_owner)
			if(ai_owner.PureRPMode)
				ai_state = "Idle"
		AiBehavior()
		// switch(ai_state) // THIS SEEMS TO HANDLE LOGIC FOR AI ACTIONS
		// 	if("Idle")
		// 		if(ai_hostility >= 2)
		// 			src.FindTarget()
		// 			if(Target)
		// 				ai_state = "combat"
		// 				return
		// 		if(return_position || (hold_position && get_dist(src, hold_position) <= max_hold_distance))
		// 			if(hold_position) return_position = null
		// 			if(world.time >= next_move)

		// 				ai_prev_position = loc
		// 				step_to(src, (hold_position ? hold_position : return_position), max_hold_distance)

		// 				next_move = world.time + MovementSpeed()

		// 				if(return_position && get_dist(src, return_position) <=3)
		// 					return return_position = null
		// 		else
		// 			ai_trapped_check = 0

		// 			if(ai_follow && ai_owner && ai_owner.icon_state != "Meditate")
		// 				if(icon_state == "Meditate")
		// 					icon_state = ""
		// 				if(!ai_owner)
		// 					EndLife(0)
		// 					return
		// 				if(world.time >= next_move)
		// 					var prev_loc = loc
		// 					if(ai_owner.z != src.z)
		// 						loc = locate(ai_owner.x, ai_owner.y,ai_owner.z)
		// 					next_move = world.time + 5
		// 					if(get_dist(src, src.ai_owner)>=10)
		// 						src.density=0
		// 						step_towards(src, src.ai_owner, 2)
		// 						src.density=1
		// 						next_move = world.time+2

		// 					var/ai_len = ai_owner.ai_followers.Find(src)

		// 					step_towards(src, src.ai_owner, 2 + round(ai_len/5))
		// 					step_away(src, src.ai_owner, 1 + round(ai_len/5))
		// 					if(loc == prev_loc) dir = src.ai_owner.dir //Make ai nicely face same dir as the owner.


		// 			else if((src.Health < 100 - (100*HealthCut)-1) || (ai_owner && ai_owner.icon_state =="Meditate"))
		// 				icon_state = "Meditate"
		// 				if(ai_stall == 0)
		// 					ai_stall = 10
		// 			else if(ai_wander)
		// 				ai_state = "wander"

		// 	if("combat")
		// 		if(world.time < ai_delayed) return

		// 		if(Launched || Stunned || icon_state=="KB")
		// 			return

		// 		if(icon_state == "Meditate")
		// 			icon_state = ""

		// 		if(src.Target)
		// 			if(src.Target.ai_alliances.len>0)
		// 				for(var/o in src.Target.ai_alliances)
		// 					if(o in src.ai_alliances)
		// 						src.Target=null
		// 						src.ai_state="Idle"


		// 		if(get_dist(src, Target) >= ai_vision * 5)
		// 			Target = null
		// 		if(ai_focus_owner_target && ai_owner)
		// 			Target = ai_owner.Target

		// 		if(src.shifts_target)
		// 			if(world.time > src.targetting+(300*src.shifts_target))
		// 				src.FindTarget()
		// 				src.targetting=world.time

		// 		if(!Target)
		// 			if((ai_hostility >= 2 && !FindTarget()) || 2 > ai_hostility)
		// 				ai_state = "Idle"
		// 				return

		// 		if(prioritize_players && Target && !Target.client)
		// 			Target = null
		// 			ai_state = "Idle"
		// 			return

		// 		if(Target.Flying && get_dist(src, Target) <= 15 && world.time > cloud_yeet_delay)
		// 			var/obj/Items/check = Target.EquippedFlyingDevice()
		// 			if(istype(check))
		// 				check.ObjectUse(Target)
		// 				Target << "[src] throws you off your flying device!"
		// 				cloud_yeet_delay = world.time + 30

		// 		if(Target.KO)
		// 			var prev_target = Target
		// 			if(istype(Target, /mob/Player/AI))
		// 				var/mob/Player/AI/a = Target
		// 				if(a.ai_owner)
		// 					Target = null
		// 					if(prob(40))
		// 						Target = a.ai_owner

		// 					else for(var/mob/m in a.ai_followers)
		// 						if(!m.KO)
		// 							Target=m
		// 							break
		// 					if(!Target)
		// 						Target = a.ai_owner

		// 			if(Target == prev_target)
		// 				Target = null
		// 				ai_state = "Idle"

		// 		dir = angle2cardinal(ai_facedir)

		// 		if(Beaming||BusterTech)
		// 			dir = angle2cardinal(GetAngle(src, Target))
		// 			return

		// 		//Movement
		// 		if(!ai_movement_type)
		// 			var compare = angle_difference(ai_facedir, dir2angle(get_dir(src, Target)))
		// 			var/obj/Skills/use

		// 			if(prob(ai_accuracy))
		// 				if((world.time > ai_next_skill) && world.time >= (next_move))

		// 					if(world.time > ai_next_projectile && Projectiles.len)
		// 						if(get_dist(src, src.Target) >= 4)
		// 							var/obj/Skills/Projectile/p = pick(Projectiles)
		// 							if( (x in (Target.x - 1 to Target.x + 1)) || (y in (Target.y - 1 to Target.y + 1) )   )
		// 								dir = angle2cardinal(GetAngle(src, Target))
		// 								UseProjectile(p)
		// 								use = p
		// 								Projectiles -= p
		// 								ai_next_projectile = (world.time+50)/ai_spammer
		// 								spawn(p.Cooldown*10)
		// 									Projectiles += p
		// 					if(world.time > ai_next_autohit && !use && AutoHits.len)

		// 						var/obj/Skills/AutoHit/a = pick(AutoHits)
		// 						if(a.Area in list("Arc","Circle"))
		// 							if(get_dist(src, Target) <= a.Distance + pick(-1,0,0,1))
		// 								dir = get_dir(src, Target)
		// 								Activate(a)
		// 								ai_next_autohit = (world.time+20)/ai_spammer
		// 						else if(a.Area in list("Strike","Wave", "Wide Wave"))
		// 							if(get_dist(src, Target) <= a.Rush+a.Distance+pick(-1,-1,0,0,0))
		// 								if(prob(ai_accuracy/2))
		// 									step(src, get_dir(src, Target))
		// 								dir = get_dir(src, Target)
		// 								if(prob(ai_accuracy/2))
		// 									if((x in (Target.x - 1 to Target.x + 1)) || (y in (Target.y - 1 to Target.y + 1) )  )
		// 										Activate(a)
		// 										use = a
		// 										ai_next_autohit = (world.time+20)/ai_spammer
		// 								else if(x == Target.x || y == Target.y)
		// 									Activate(a)
		// 									use = a
		// 									ai_next_autohit = (world.time+20)/ai_spammer
		// 						else if(a.Area in list("Target","Around Target"))
		// 							if(get_dist(src,Target) <= a.Distance - pick(0,0,-1,-1,-2))
		// 								Activate(a)
		// 								use = a
		// 								ai_next_autohit = (world.time+20)/ai_spammer
		// 						AutoHits -= a
		// 						spawn(a.Cooldown*10)
		// 							AutoHits += a
		// 					if(use) ai_next_skill = world.time + (use.Copyable ? use.Copyable * 5 : 50)

		// 					else if(locate(/obj/Skills/Dragon_Dash, src) && get_dist(src, Target) > 5)
		// 						use = locate(/obj/Skills/Dragon_Dash) in src.contents
		// 						if(!use.Using)
		// 							if(prob(get_dist(src, Target) * 5))
		// 								SkillX("DragonDash",use)
		// 						else use=null
		// 					//if(world.time > ai_next_queueable && !use)

		// 				var/hit
		// 				for(var/mob/m in HitCheck())
		// 					dir = get_dir(src,m)
		// 					Melee1(GLOBAL_AI_DAMAGE)
		// 					hit=1
		// 				if(!hit && prob(25) && world.time > last_zanzo +250/ai_spammer)
		// 					for(var/obj/Skills/Zanzoken/z in src)
		// 						if(get_dist(src, src.Target) >=3 && prob(50))
		// 							SkillX("Zanzoken",z)
		// 						else
		// 							SkillStunX("After Image Strike",z)
		// 						last_zanzo=world.time

		// 			if(world.time >= next_move && !use && Move_Requirements())
		// 				if(world.time > ai_turn_stall)
		// 					var erratic = 0
		// 					if((angle_difference(ai_facedir, dir2angle(get_dir(src, Target))) in -46 to 46) && prob(ai_accuracy/2)) //snap movement
		// 						ai_facedir = dir2angle(get_dir(src, Target))
		// 						ai_last_dirshift = world.time
		// 						if(get_dist(src,Target)>3)
		// 							erratic = 1
		// 					if(compare != 0)
		// 						if(compare > 0)
		// 							ai_facedir += min(45, compare) //* erratic ? 1+rand() : 1
		// 							if(prob(25)) ai_facedir += 45
		// 						else if(0 > compare)
		// 							ai_facedir += max(-45, compare) //* erratic ? 1+rand() : 1
		// 							if(prob(25)) ai_facedir += -45
		// 						ai_last_dirshift = world.time
		// 					else if(erratic && get_dist(src,Target)>2)
		// 						ai_facedir += pick(-45,45)
		// 						ai_last_dirshift = world.time
		// 						ai_turn_stall = world.time + MovementSpeed()*rand(1,3)

		// 				if(ai_last_dirshift + MovementSpeed()*2 < world.time)
		// 					ai_facedir+=pick(-45,-90,45,90,180,180)
		// 					ai_last_dirshift = world.time
		// 				if(get_dist(src, Target) >= 6)
		// 					step_to(src, Target)
		// 				else
		// 					var turf/walkto = WalkPosition()
		// 					step_to(src, walkto)
		// 				next_move = world.time + MovementSpeed()
		// 			dir = angle2dir(ai_facedir)
		// 			if(dir != get_dir(src, Target))
		// 				ai_facedir += 0


		// 		else
		// 			switch(ai_movement_type)
		// 				if("Circle Owner")
		// 					return

		// 	if("wander")
		// 		if(world.time >= next_move)
		// 			step(src, pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,SOUTHWEST,NORTHEAST,SOUTHEAST))
		// 			next_move = world.time + MovementSpeed()*10
		// 			if(src.ai_hostility>=2)
		// 				src.FindTarget()
		// 				if(src.Target)
		// 					ai_state="combat"
		// if(ai_state_switch) ai_state = ai_state_switch


proc
	//	conversions between bearings and directons
	angle2dir(angle) switch(clamp_angle(angle))
		if(0 to 22.5)		return NORTH
		if(22.5 to 67.5)	return NORTHEAST
		if(67.5 to 112.5)	return EAST
		if(112.5 to 157.5)	return SOUTHEAST
		if(157.5 to 202.5)	return SOUTH
		if(202.5 to 247.5)	return SOUTHWEST
		if(247.5 to 292.5)	return WEST
		if(292.5 to 337.5)	return NORTHWEST
		if(337.5 to 360)	return NORTH


	angle2cardinal(angle) switch(clamp_angle(angle))
		if(0 to 45)		return NORTH
		if(45 to 135)	return EAST
		if(135 to 225)	return SOUTH
		if(225 to 315)	return WEST
		if(315 to 360)	return NORTH
	//	difference between angles
	angle_difference(a, b)
		var t = b - a
		return sin(t) >= 0 ? arccos(cos(t)) : -arccos(cos(t))



mob/Player/AI/var/tmp/last_powercheck
mob/Player/AI

	proc/AIYell(var/T)
		if(src.SenseRobbed>=3)
			T="---"

		for(var/mob/E in hearers(24,src))
			if(E.SenseRobbed<4)
				E << output("<font color=[src.Text_Color]>[src][E.Controlz(src)] yells: <b>[html_encode(T)]</b>", "output")
				E << output("<font color=[src.Text_Color]>[src][E.Controlz(src)] yells: <b>[html_encode(T)]</b>", "icchat")
				Log(E.ChatLog(),"<font color=green>[src]([src.key]) yells: <b>[html_encode(T)]</b>")

			if(E.BeingObserved.len>0)
				for(var/mob/m in E.BeingObserved)
					m<<output("<b>(OBSERVE)</b><font color=[src.Text_Color]>[src][E.Controlz(src)] yells: [html_encode(T)]", "icchat")
					m<<output("<b>(OBSERVE)</b><font color=[src.Text_Color]>[src][E.Controlz(src)] yells: [html_encode(T)]", "output")

			for(var/obj/Items/Enchantment/Arcane_Mask/EarCheck in E)
				if(EarCheck.suffix) //Checks to make sure the ear(s) are equipped.
					for(var/mob/Players/OrbCheck in world) //Searches the world for players...
						for(var/obj/Items/Enchantment/ArcanicOrb/FinalCheck in OrbCheck) //Checks for Arcanic Orbs.
							if(EarCheck.LinkTag in FinalCheck.LinkedMasks)
								if(FinalCheck.Active)
									OrbCheck<<output("<b>[FinalCheck](hearing [E]</b><font color=[src.Text_Color]>[src][E.Controlz(src)] yells: [html_encode(T)]", "icchat")
									OrbCheck<<output("<b>[FinalCheck](hearing [E])</b><font color=[src.Text_Color]>[src][E.Controlz(src)] yells: [html_encode(T)]", "output")

		for(var/obj/Items/Tech/Security_Camera/F in view(20,src))
			if(F.Active==1)
				for(var/mob/CC in world)
					for(var/obj/Items/Tech/Scouter/CCS in CC)
						if(F.Frequency==CCS.Frequency)
							if(CC.Timestamp)
								CC << output("<font color=red>[time2text(world.timeofday,"(hh:mm:ss)")]<font color=[src.Text_Color]>*[F.name] transmits: [src.name] yells: [html_encode(T)]", "output")
								CC << output("<font color=red>[time2text(world.timeofday,"(hh:mm:ss)")]<font color=[src.Text_Color]>*[F.name] transmits: [src.name] yells: [html_encode(T)]", "icchat")
							else
								CC << output("<font color=[src.Text_Color]>[F.name] transmits: [src.name] yells: [html_encode(T)]", "output")
								CC << output("<font color=[src.Text_Color]>[F.name] transmits: [src.name] yells: [html_encode(T)]", "icchat")
				for(var/obj/Items/Tech/Security_Display/G in world)
					if(G.Password==F.Password)
						if(G.Active==1)
							for(var/mob/H in hearers(G.AudioRange,G))
								H << output("<font color=red>[time2text(world.timeofday,"(hh:mm:ss)")]<font color=green>[F.name] transmits: [src] yells: [html_encode(T)]", "output")
								H << output("<font color=red>[time2text(world.timeofday,"(hh:mm:ss)")]<font color=green>[F.name] transmits: [src] yells: [html_encode(T)]", "icchat")
								Log(H.ChatLog(),"<font color=green>[F.name](Made by [F.CreatorKey]) transmits: [src] yells: [html_encode(T)]")

		src.Say_Spark(3)

	proc/AISay(var/T)
		for(var/mob/E in hearers(20,src))
			if(E.SenseRobbed<4)
				E << output("<font color=[src.Text_Color]>[src][E.Controlz(src)] says: [html_encode(T)]", "icchat")
				E << output("<font color=[src.Text_Color]>[src][E.Controlz(src)] says: [html_encode(T)]", "output")
			Log(E.ChatLog(),"<font color=green>[src]([src.key]) says: [html_encode(T)]")

			if(E.BeingObserved.len>0)
				for(var/mob/m in E.BeingObserved)
					m<<output("<b>(OBSERVE)</b><font color=[src.Text_Color]>[src][E.Controlz(src)] says: [html_encode(T)]", "icchat")
					m<<output("<b>(OBSERVE)</b><font color=[src.Text_Color]>[src][E.Controlz(src)] says: [html_encode(T)]", "output")


			for(var/obj/Items/Enchantment/Arcane_Mask/EarCheck in E)
				if(EarCheck.suffix) //Checks to make sure the ear(s) are equipped.
					for(var/mob/Players/OrbCheck in world) //Searches the world for players...
						for(var/obj/Items/Enchantment/ArcanicOrb/FinalCheck in OrbCheck) //Checks for Arcanic Orbs.
							if(EarCheck.LinkTag in FinalCheck.LinkedMasks)
								if(FinalCheck.Active)
									OrbCheck << output("[FinalCheck](hearing [E]):<font color=[src.Text_Color]>[src] says: [html_encode(T)]", "output")
									OrbCheck << output("[FinalCheck](hearing [E]):<font color=[src.Text_Color]>[src] says: [html_encode(T)]", "icchat")

			for(var/obj/Items/Tech/Planted_Wiretap/WT in E)
				for(var/mob/Players/M in players)
					for(var/obj/Items/Tech/Scouter/Q in M)
						if(Q.Frequency==WT.Frequency)
							if(!(M in hearers(12, src)))
								M<<"<font color=green><b>([WT.name])</b> [src.name]: [html_encode(T)]"
							Log(M.ChatLog(),"<font color=green>([WT.name])[src]([src.key]) says: [html_encode(T)]")
					for(var/obj/Items/Tech/Communicator/Q in M)
						if(Q.Frequency==WT.Frequency&&Q.toggled_on==1)
							if(!(M in hearers(12, src)))
								M<<"<font color=green><b>([WT.name])</b> [src.name]: [html_encode(T)]"
							Log(M.ChatLog(),"<font color=green>([WT.name])[src]([src.key]) says: [html_encode(T)]")
					for(var/obj/Skills/Utility/Internal_Communicator/B in M)
						if(B.ICFrequency==WT.Frequency)
							if(!(M in hearers(12, src)))
								M<<"<font color=green><b>(Internal Comms (Freq:[B.ICFrequency]))</b> [src.name]: [html_encode(T)]"
							Log(M.ChatLog(),"<font color=green>([WT.name])[src]([src.key]) says: [html_encode(T)]")
						if(B.MonitoringFrequency==WT.Frequency)
							if(!(M in hearers(12, src)))
								M<<"<font color=green><b>(Internal Comms (Monitoring Freq:[B.MonitoringFrequency]))</b> [src.name]: [html_encode(T)]"
							Log(M.ChatLog(),"<font color=green>([WT.name])[src]([src.key]) says: [html_encode(T)]")
				for(var/obj/Items/Tech/Speaker/X in world)
					if(X.Frequency==WT.Frequency&&X.Active==1)
						for(var/mob/Y in hearers(X.AudioRange,X))
							if(!(Y in hearers(12, src)))
								Y<<"<font color=green><b>([X.name])</b> [src.name]: [html_encode(T)]"

		for(var/obj/Items/Tech/Security_Camera/F in view(20,src)) //This for loop detects Security Cameras around those that use the say verb.
			if(F.Active==1)
				for(var/mob/CC in world)
					for(var/obj/Items/Tech/Scouter/CCS in CC)
						if(F.Frequency==CCS.Frequency)
							if(CC.Timestamp)
								CC << output("<font color=red>[time2text(world.timeofday,"(hh:mm:ss)")]<font color=[src.Text_Color]>[F.name] transmits: [src.name] says: [html_encode(T)]", "output")
								CC << output("<font color=red>[time2text(world.timeofday,"(hh:mm:ss)")]<font color=[src.Text_Color]>[F.name] transmits: [src.name] says: [html_encode(T)]", "icchat")
							else
								CC << output("<font color=[src.Text_Color]>[F.name] transmits: [src.name] says: [html_encode(T)]", "output")
								CC << output("<font color=[src.Text_Color]>[F.name] transmits: [src.name] says: [html_encode(T)]", "icchat")

				for(var/obj/Items/Tech/Speaker/S in world)
					if(F.Frequency==S.Frequency)
						if(F.Active==1)
							for(var/mob/H in hearers(F.AudioRange,F))
								H << output("<font color=red>[time2text(world.timeofday,"(hh:mm:ss)")]<font color=green>[F.name] transmits:*[src.name]<font color=yellow> [html_encode(T)]*", "output")
								H << output("<font color=red>[time2text(world.timeofday,"(hh:mm:ss)")]<font color=green>[F.name] transmits:*[src.name]<font color=yellow> [html_encode(T)]*", "icchat")
								Log(H.ChatLog(),"<font color=red>[F.name] transmits:*[src]([src.key]) [html_encode(T)]*")

				for(var/obj/Items/Tech/Security_Display/G in world)
					if(G.Password==F.Password)
						if(G.Active==1)
							for(var/mob/H in hearers(G.AudioRange,G))
								H << output("<font color=red>[time2text(world.timeofday,"(hh:mm:ss)")]<font color=green>[F.name] transmits: [src] says: [html_encode(T)]", "output")
								H << output("<font color=red>[time2text(world.timeofday,"(hh:mm:ss)")]<font color=green>[F.name] transmits: [src] says: [html_encode(T)]", "icchat")
								Log(H.ChatLog(),"<font color=green>[F.name](Made by [F.CreatorKey]) transmits: [src] says: [html_encode(T)]")


		for(var/obj/Items/Tech/Speaker/X in view(6,src)) //This for loop detects Speakers, then determines if they have the Intercom upgrade.
			for(var/obj/Items/Tech/Speaker/Y in world)
				if(X.Frequency==Y.Frequency&&X.Intercom==1&&Y!=X&&X.Active==1&&Y.Active==1)
					for(var/mob/Z in hearers(Y.AudioRange,Y))
						Z << output("<font color=green><b>([Y.name])</b> [src.name]: [html_encode(T)]", "output")
						Z << output("<font color=green><b>([Y.name])</b> [src.name]: [html_encode(T)]", "icchat")
			if(X.Intercom==1)
				for(var/mob/Players/M in players)
					for(var/obj/Items/Tech/Scouter/Q in M)
						if(X.Frequency==Q.Frequency)
							M << output("<font color=green><b>([X.name])</b> [src.name]: [html_encode(T)]", "output")
							M << output("<font color=green><b>([X.name])</b> [src.name]: [html_encode(T)]", "icchat")
							Log(M.ChatLog(),"<font color=green>([X.name])[src]([src.key]) says: [html_encode(T)]")

		src.Say_Spark()

	proc/AIGain()
		set waitfor=0
		if(ai_owner && ai_owner.PureRPMode)
			return
		if(src.KO&&src.icon_state!="KO")
			src.icon_state="KO"
		if(src.KO && ko_death)
			Death(null,"exhausting their life force!")
			return

		if(ai_owner)
			WoundIntent = ai_owner.WoundIntent
			Lethal = ai_owner.Lethal


		TotalFatigue=0
		TotalInjury=0
		Energy+=2

		if(world.time >= last_powercheck+300)
			AIAvailablePower()
			last_powercheck=world.time
		if(icon_state == "Meditate")
			TotalFatigue = max(0, TotalFatigue - 0.1)
			TotalInjury = max(0, TotalFatigue - 0.1)
		if(src.Health < 25*(1-src.HealthCut) && !src.HealthAnnounce25)
			if(src.SpecialBuff&&src.SpecialBuff.BuffName=="Broken Brave")
				src.OMessage(10, "<font color=#00FF55>[src] begins fighting fiercely like a lion!", "[src]([src.key]) has 25% health left.</font>")
			else if(src.SpecialBuff&&src.SpecialBuff.BuffName=="Protect Brave")
				src.OMessage(10, "<font color=#00FF55>[src] begins fighting tenaciously like a machine!", "[src]([src.key]) has 25% health left.</font>")
			else if(src.SpecialBuff&&src.SpecialBuff.BuffName=="Genesic Brave")
				src.OMessage(10, "<font color=#00FF55>[src] begins fighting fiercely and tenaciously with the power of Courage!", "[src]([src.key]) has 25% health left.</font>")
			else if(src.Saga=="Magic Knight")
				src.OMessage(10, "<font color=#FF2222>[src] draws on their conviction!", "[src]([src.key]) has 25% health left.</font>")
			else
				if(src.Secret!="Zombie")
					if(!src.ExhaustedMessage)
						if(!src.ExhaustedColor)
							src.OMessage(10, "[src] looks exhausted!", "[src]([src.key]) has 25% health left.")
						else
							src.OMessage(10, "<font color='[src.ExhaustedColor]'>[src] looks exhausted!</font color>", "[src]([src.key]) has 25% health left.")
					else
						if(!src.ExhaustedColor)
							src.OMessage(10, "[src] [src.ExhaustedMessage]", "[src]([src.key]) has 25% health left.")
						else
							src.OMessage(10, "<font color='[src.ExhaustedColor]'>[src] [src.ExhaustedMessage]</font color>", "[src]([src.key]) has 25% health left.")
			src.HealthAnnounce25=1

		if(src.Health < 10*(1-src.HealthCut) && !src.HealthAnnounce10)
			if(src.SpecialBuff&&src.SpecialBuff.BuffName=="Broken Brave")
				src.OMessage(10, "<b><font color=#00FF55>[src] calls upon the power of Destruction for one final push!", "[src]([src.key]) has 10% health left.</font></b>")
				src.PowerControl=100+25*src.SagaLevel
				src.HealEnergy(15)
			else if(src.SpecialBuff&&src.SpecialBuff.BuffName=="Protect Brave")
				src.OMessage(10, "<b><font color=#00FF55>[src] calls upon the power of Protection for one final push!", "[src]([src.key]) has 10% health left.</font></b>")
				src.VaizardHealth+=5*src.SagaLevel
				src.HealHealth(5)
			else if(src.SpecialBuff&&src.SpecialBuff.BuffName=="Genesic Brave")
				src.OMessage(10, "<b><font color=#00FF55>[src] unites the powers of Destruction and Protection to defy the odds!", "[src]([src.key]) has 10% health left.</font></b>")
				src.PowerControl+=25*src.SagaLevel
				src.VaizardHealth+=5*src.SagaLevel
				src.HealEnergy(15)
				src.HealHealth(5)
			else
				if(src.Secret!="Zombie")
					if(!src.BarelyStandingMessage)
						if(!src.BarelyStandingColor)
							src.OMessage(10, "[src] is barely standing up!", "[src]([src.key]) has 10% health left.")
						else
							src.OMessage(10, "<font color='[src.BarelyStandingColor]'>[src] is barely standing up!</font color>", "[src]([src.key]) has 10% health left.")
					else
						if(!src.BarelyStandingColor)
							src.OMessage(10, "[src] [src.BarelyStandingMessage]", "[src]([src.key]) has 10% health left.")
						else
							src.OMessage(10, "<font color='[src.BarelyStandingColor]'>[src] [src.BarelyStandingMessage]</font color>", "[src]([src.key]) has 10% health left.")
			src.HealthAnnounce10=1
		if(src.TotalInjury > 50 && !src.InjuryAnnounce && src.Secret!="Zombie")
			src.OMessage(10, "[src] looks beaten half to death!", "[src]([src.key]) has 50% injury.")
			src.InjuryAnnounce=1
		if(src.NanoBoost&&src.Health<=25*(1-src.HealthCut)&&!src.NanoAnnounce)
			OMsg(src, "<font color='green'>[src]'s nanites respond to their physical trauma, bolstering their cybernetic power!</font color>")
			src.NanoAnnounce=1

		if(src.Health>=75*(1-src.HealthCut)&&src.icon_state=="Meditate"&&src.Anger!=0)
			calmcounter-=1
		else
			calmcounter=5
		if(calmcounter<=0)
			calmcounter=5
			if(Anger)
				src.Calm()
		if(src.Grab)src.Grab_Update()

		if(src.Stasis||src.StasisFrozen)
			src.Stasis -= 200
			if(src.Stasis<=0)
				src.Stasis=0
				src.RemoveStasis()

		if(src.Dead)
			src.Savable=0
			animate(src,alpha=0,time=30)
			sleep(30)
			del(src)

		if(src.KOTimer)
			src.KOTimer--
			if(src.KOTimer<=0&&!src.MortallyWounded)
				src.Conscious()

		if(src.Beaming==1)
			for(var/obj/Skills/Projectile/Beams/Z in src)
				if(Z.Charging&&Z.ChargeRate)
					if(src.BeamCharging>=0.5&&src.BeamCharging<=Z.ChargeRate)
						src.BeamCharging+=src.GetRecov(0.2)
						if(src.BeamCharging>Z.ChargeRate)
							src.BeamCharging=Z.ChargeRate

						//aesthetics
						if(src.BeamCharging>=(0.5*Z.ChargeRate))
							if(Z.name=="Aurora Execution")
								if(src.BeamCharging<Z.ChargeRate)
									var/image/i=image('Aurora.dmi',icon_state="[rand(1,3)]", layer=EFFECTS_LAYER, loc=src)
									i.blend_mode=BLEND_ADD
									animate(i, alpha=0)
									world << i
									i.transform*=30
									animate(i, alpha=200, time=5)
									src.BeamCharging=Z.ChargeRate
									spawn(150)
										animate(i, alpha=0, time=5)
										sleep(5)
										del i
							else
								for(var/turf/t in Turf_Circle(src, 10))
									if(prob(5))
										spawn(rand(2,6))
											var/icon/i = icon('RisingRocks.dmi')
											t.overlays+=i
											spawn(rand(10, 30))
												t.overlays-=i
								if(src.BeamCharging==Z.ChargeRate)
									src.Quake((14+2*Z.DamageMult))

		src.Debuffs()

		if(src.Harden)
			src.Harden--
			if(src.Harden<=0)
				src.Harden=0

		if(src.CounterMasterTimer)
			src.CounterMasterTimer = max(0, CounterMasterTimer-1) // bruh

		if(src.SureHitTimerLimit)
			if(!src.SureHit)
				src.SureHitTimer--
				if(src.SureHitTimer<=0)
					src.SureHit=1
					src.SureHitTimer=src.SureHitTimerLimit

		if(src.SureDodgeTimerLimit)
			if(!src.SureDodge)
				src.SureDodgeTimer--
				if(src.SureDodgeTimer<=0)
					src.SureDodge=1
					src.SureDodgeTimer=src.SureDodgeTimerLimit

		if(src.UsingKendo())
			src.IaidoCounter++
		if(src.UsingSpeedRave())
			src.IaidoCounter++

		DRAINS_ACTIVE//Label
		if(src.ActiveBuff)
			if(src.ActiveBuff.HealthDrain)
				src.DoDamage(src, TrueDamage(src.ActiveBuff.HealthDrain))
			if(src.ActiveBuff.HealthThreshold&&!src.ActiveBuff.AllOutAttack)
				if(src.Health<src.ActiveBuff.HealthThreshold*(1-src.HealthCut)||src.KO)
					if(src.CheckActive("Eight Gates"))
						src.ActiveBuff:Stop_Cultivation()
					else
						src.ActiveBuff.Trigger(src)
					goto DRAINS_ACTIVE

			if(src.ActiveBuff.WoundDrain)
				src.WoundSelf(src.ActiveBuff.WoundDrain)
			if(src.ActiveBuff.WoundThreshold&&!src.ActiveBuff.AllOutAttack)
				if(src.TotalInjury>=src.ActiveBuff.WoundThreshold)
					src.ActiveBuff.Trigger(src)
					goto DRAINS_ACTIVE

			if(src.ActiveBuff.EnergyDrain)
				src.LoseEnergy(src.ActiveBuff.EnergyDrain)
			if(src.ActiveBuff.EnergyThreshold&&!src.ActiveBuff.AllOutAttack)
				if(src.Energy<src.ActiveBuff.EnergyThreshold*(1-src.EnergyCut))
					src.ActiveBuff.Trigger(src)
					var/KiControl=src.GetKiControlMastery()
					if(KiControl>0)
						src<<"Your energy mastery allows you to recover stamina rapidly."
						src.HealEnergy(10*KiControl)
					goto DRAINS_ACTIVE

			if(src.ActiveBuff.FatigueDrain)
				src.GainFatigue(src.ActiveBuff.FatigueDrain)
			if(src.ActiveBuff.FatigueThreshold&&!src.ActiveBuff.AllOutAttack)
				if(src.TotalFatigue>=src.ActiveBuff.FatigueThreshold)
					if(src.CheckActive("Eight Gates"))
						src.ActiveBuff:Stop_Cultivation()
					else
						src.ActiveBuff.Trigger(src)
					goto DRAINS_ACTIVE

			if(src.ActiveBuff.CapacityDrain)
				src.LoseCapacity(src.ActiveBuff.CapacityDrain)
			if(src.ActiveBuff.CapacityThreshold&&!src.ActiveBuff.AllOutAttack)
				if(src.TotalCapacity>=src.ActiveBuff.CapacityThreshold)
					src.ActiveBuff.Trigger(src)
					goto DRAINS_ACTIVE

			if(src.ActiveBuff.ManaDrain)
				src.LoseMana(src.ActiveBuff.ManaDrain)
			if(src.ActiveBuff.ManaThreshold&&!src.ActiveBuff.AllOutAttack)
				if(src.ManaAmount<src.ActiveBuff.ManaThreshold)
					src.ActiveBuff.Trigger(src)
					goto DRAINS_ACTIVE

			if(src.ActiveBuff.VaizardShatter)
				if(src.VaizardHealth<=0)
					src.ActiveBuff.Trigger(src)
					goto DRAINS_ACTIVE

			if(src.ActiveBuff.TimerLimit)
				if(!isnum(src.ActiveBuff.Timer))//If the timer isn't a number...
					src.ActiveBuff.Timer=0//Make it 0.
				src.ActiveBuff.Timer+=world.tick_lag
				if(src.ActiveBuff.Timer>=src.ActiveBuff.TimerLimit)//If the timer has filled up entirely...
					if(src.CheckActive("Eight Gates"))
						src.ActiveBuff:Stop_Cultivation()
					else
						src.ActiveBuff.Trigger(src)//toggle it off.
					goto DRAINS_ACTIVE

			if(src.ActiveBuff.WaveringAngerLimit)
				if(src.ActiveBuff.WaveringAnger<src.ActiveBuff.WaveringAngerLimit)
					src.ActiveBuff.WaveringAnger++
					if(src.ActiveBuff.WaveringAnger>=src.ActiveBuff.WaveringAngerLimit)
						if(prob(33))
							src.SetNoAnger(src.ActiveBuff, 1)
						else
							src.SetNoAnger(src.ActiveBuff, 0)
						src.ActiveBuff.WaveringAnger=0

			if(src.ActiveBuff.WoundHeal)
				if((src.ActiveBuff.InstantAffect&&!src.ActiveBuff.InstantAffected)||!src.ActiveBuff.InstantAffect)
					src.HealWounds(src.GetRecov(src.ActiveBuff.WoundHeal))
			if(src.ActiveBuff.FatigueHeal)
				if((src.ActiveBuff.InstantAffect&&!src.ActiveBuff.InstantAffected)||!src.ActiveBuff.InstantAffect)
					if(src.ActiveBuff.StableHeal)
						src.HealFatigue(src.ActiveBuff.FatigueHeal,1)
					else
						src.HealFatigue(src.GetRecov(src.ActiveBuff.FatigueHeal))
			if(src.ActiveBuff.CapacityHeal)
				if((src.ActiveBuff.InstantAffect&&!src.ActiveBuff.InstantAffected)||!src.ActiveBuff.InstantAffect)
					src.HealCapacity(src.ActiveBuff.CapacityHeal)
			if(src.ActiveBuff.HealthHeal)
				if((src.Health+src.TotalInjury)>=100||(src.TotalInjury&&src.icon_state=="Meditate"))
					if((src.ActiveBuff.InstantAffect&&!src.ActiveBuff.InstantAffected)||!src.ActiveBuff.InstantAffect)
						src.HealWounds(src.GetRecov(src.ActiveBuff.HealthHeal))
				else
					if((src.ActiveBuff.InstantAffect&&!src.ActiveBuff.InstantAffected)||!src.ActiveBuff.InstantAffect)
						src.HealHealth(src.GetRecov(src.ActiveBuff.HealthHeal))
			if(src.ActiveBuff.EnergyHeal)
				if((src.Energy+src.TotalFatigue)>=100||(src.TotalFatigue&&src.icon_state=="Meditate"))
					if((src.ActiveBuff.InstantAffect&&!src.ActiveBuff.InstantAffected)||!src.ActiveBuff.InstantAffect)
						if(src.ActiveBuff.StableHeal)
							src.HealFatigue(src.ActiveBuff.EnergyHeal,1)
						else
							src.HealFatigue(src.GetRecov(src.ActiveBuff.EnergyHeal))
				else
					if((src.ActiveBuff.InstantAffect&&!src.ActiveBuff.InstantAffected)||!src.ActiveBuff.InstantAffect)
						if(src.ActiveBuff.StableHeal)
							src.HealEnergy(src.ActiveBuff.EnergyHeal,1)
						else
							src.HealEnergy(src.GetRecov(src.ActiveBuff.EnergyHeal))
			if(src.ActiveBuff.ManaHeal)
				if((src.ActiveBuff.InstantAffect&&!src.ActiveBuff.InstantAffected)||!src.ActiveBuff.InstantAffect)
					src.HealMana(src.ActiveBuff.ManaHeal)


		DRAINS_SPECIAL//Label
		if(src.SpecialBuff)
			if(src.SpecialBuff.HealthDrain)
				src.DoDamage(src, TrueDamage(src.SpecialBuff.HealthDrain))
			if(src.SpecialBuff.HealthThreshold&&!src.SpecialBuff.AllOutAttack)
				if(src.Health<src.SpecialBuff.HealthThreshold*(1-src.HealthCut)||src.KO)
					src.SpecialBuff.Trigger(src)
					goto DRAINS_SPECIAL

			if(src.SpecialBuff.WoundDrain)
				src.WoundSelf(src.SpecialBuff.WoundDrain)
			if(src.SpecialBuff.WoundThreshold&&!src.SpecialBuff.AllOutAttack)
				if(src.TotalInjury>=src.SpecialBuff.WoundThreshold)
					src.SpecialBuff.Trigger(src)
					goto DRAINS_SPECIAL

			if(src.SpecialBuff.EnergyDrain)
				src.LoseEnergy(src.SpecialBuff.EnergyDrain)
			if(src.SpecialBuff.EnergyThreshold&&!src.SpecialBuff.AllOutAttack)
				if(src.Energy<src.SpecialBuff.EnergyThreshold*(1-src.EnergyCut))
					src.SpecialBuff.Trigger(src)
					goto DRAINS_SPECIAL

			if(src.SpecialBuff.FatigueDrain)
				src.GainFatigue(src.SpecialBuff.FatigueDrain)
			if(src.SpecialBuff.FatigueThreshold&&!src.SpecialBuff.AllOutAttack)
				if(src.TotalFatigue>=src.SpecialBuff.FatigueThreshold)
					src.SpecialBuff.Trigger(src)
					goto DRAINS_SPECIAL

			if(src.SpecialBuff.CapacityDrain)
				src.LoseCapacity(src.SpecialBuff.CapacityDrain)
			if(src.SpecialBuff.CapacityThreshold&&!src.SpecialBuff.AllOutAttack)
				if(src.TotalCapacity>=src.SpecialBuff.CapacityThreshold)
					src.SpecialBuff.Trigger(src)
					goto DRAINS_SPECIAL

			if(src.SpecialBuff.ManaDrain)
				src.LoseMana(src.SpecialBuff.ManaDrain)
			if(src.SpecialBuff.ManaThreshold&&!src.SpecialBuff.AllOutAttack)
				if(src.ManaAmount<src.SpecialBuff.ManaThreshold)
					src.SpecialBuff.Trigger(src)
					goto DRAINS_SPECIAL

			if(src.SpecialBuff.VaizardShatter)
				if(src.VaizardHealth<=0)
					src.SpecialBuff.Trigger(src)
					goto DRAINS_SPECIAL

			if(src.SpecialBuff.TimerLimit)
				if(!isnum(src.SpecialBuff.Timer))
					src.SpecialBuff.Timer=0
				src.SpecialBuff.Timer+=world.tick_lag
				if(src.SpecialBuff.Timer>=src.SpecialBuff.TimerLimit)
					src.SpecialBuff.Trigger(src)
					goto DRAINS_SPECIAL

			if(src.SpecialBuff.WaveringAngerLimit)
				if(src.SpecialBuff.WaveringAnger<src.SpecialBuff.WaveringAngerLimit)
					src.SpecialBuff.WaveringAnger++
					if(src.SpecialBuff.WaveringAnger>=src.SpecialBuff.WaveringAngerLimit)
						if(prob(33))
							src.SetNoAnger(src.SpecialBuff, 1)
						else
							src.SetNoAnger(src.SpecialBuff, 0)
						src.SpecialBuff.WaveringAnger=0

			if(src.SpecialBuff.WoundHeal)
				src.HealWounds(src.GetRecov(src.SpecialBuff.WoundHeal))
			if(src.SpecialBuff.FatigueHeal)
				src.HealFatigue(src.GetRecov(src.SpecialBuff.FatigueHeal))
			if(src.SpecialBuff.CapacityHeal)
				src.HealCapacity(src.SpecialBuff.CapacityHeal)
			if(src.SpecialBuff.HealthHeal)
				if((src.Health+src.TotalInjury)>=100||(src.TotalInjury&&src.icon_state=="Meditate"))
					if(src.SpecialBuff.StableHeal)
						src.HealWounds(src.SpecialBuff.HealthHeal)
					else
						src.HealWounds(src.GetRecov(src.SpecialBuff.HealthHeal))
				else
					if(src.SpecialBuff.StableHeal)
						src.HealHealth(src.SpecialBuff.HealthHeal)
					else
						src.HealHealth(src.GetRecov(src.SpecialBuff.HealthHeal))
			if(src.SpecialBuff.EnergyHeal)
				if((src.Energy+src.TotalFatigue)>=100||(src.TotalFatigue&&src.icon_state=="Meditate"))
					if(src.SpecialBuff.StableHeal)
						src.HealFatigue(src.SpecialBuff.EnergyHeal)
					else
						src.HealFatigue(src.GetRecov(src.SpecialBuff.EnergyHeal))
				else
					if(src.SpecialBuff.StableHeal)
						src.HealEnergy(src.SpecialBuff.EnergyHeal)
					else
						src.HealEnergy(src.GetRecov(src.ActiveBuff.EnergyHeal))
			if(src.SpecialBuff.ManaHeal)
				src.HealMana(src.SpecialBuff.ManaHeal)


		if(src.SlotlessBuffs.len>0)
			for(var/sb in src.SlotlessBuffs)
				var/obj/Skills/Buffs/b = SlotlessBuffs[sb]
				if(b)
					if(istype(b, /obj/Skills/Buffs/SlotlessBuffs/Autonomous))
						continue
					if(b.HealthDrain)
						src.DoDamage(src, TrueDamage(b.HealthDrain))
					if(b.HealthThreshold&&!b.AllOutAttack)
						if(src.Health<b.HealthThreshold*(1-src.HealthCut)||src.KO)
							b.Trigger(src)

					if(b.WoundDrain)
						src.WoundSelf(b.WoundDrain)
					if(b.WoundThreshold&&!b.AllOutAttack)
						if(src.TotalInjury>=b.WoundThreshold)
							b.Trigger(src)

					if(b.EnergyDrain)
						src.LoseEnergy(b.EnergyDrain)
					if(b.EnergyThreshold&&!b.AllOutAttack)
						if(src.Energy<b.EnergyThreshold*(1-src.EnergyCut))
							b.Trigger(src)

					if(b.FatigueDrain)
						src.GainFatigue(b.FatigueDrain)
					if(b.FatigueThreshold&&!b.AllOutAttack)
						if(src.TotalFatigue>=b.FatigueThreshold)
							b.Trigger(src)

					if(b.CapacityDrain)
						src.LoseCapacity(b.CapacityDrain)
					if(b.CapacityThreshold&&!b.AllOutAttack)
						if(src.TotalCapacity>=b.CapacityThreshold)
							b.Trigger(src)

					if(b.ManaDrain)
						src.LoseMana(b.ManaDrain)
					if(b.ManaThreshold&&!b.AllOutAttack)
						if(src.ManaAmount<b.ManaThreshold)
							b.Trigger(src)

					if(b.WoundHeal)
						src.HealWounds(src.GetRecov(b.WoundHeal))
					if(b.FatigueHeal)
						src.HealFatigue(src.GetRecov(b.FatigueHeal))
					if(b.CapacityHeal)
						src.HealCapacity(b.CapacityHeal)
					if(b.HealthHeal)
						if((src.Health+src.TotalInjury)>=100||(src.TotalInjury&&src.icon_state=="Meditate"))
							if(b.StableHeal)
								src.HealWounds(b.HealthHeal)
							else
								src.HealWounds(src.GetRecov(b.HealthHeal))
						else
							if(b.StableHeal)
								src.HealHealth(b.HealthHeal)
							else
								src.HealHealth(src.GetRecov(b.HealthHeal))
					if(b.EnergyHeal)
						if((src.Energy+src.TotalFatigue)>=100||(src.TotalFatigue&&src.icon_state=="Meditate"))
							if(b.StableHeal)
								src.HealFatigue(b.EnergyHeal)
							else
								src.HealFatigue(src.GetRecov(b.EnergyHeal))
						else
							if(b.StableHeal)
								src.HealEnergy(b.EnergyHeal)
							else
								src.HealEnergy(src.GetRecov(src.ActiveBuff.EnergyHeal))
					if(b.ManaHeal)
						src.HealMana(b.ManaHeal)

					if(b.VaizardShatter)
						if(src.VaizardHealth<=0)
							b.Trigger(src)

					if(b.Connector)
						missile(b.Connector,src,src.Target)

					if(b.WaveringAngerLimit)
						if(b.WaveringAnger<b.WaveringAngerLimit)
							b.WaveringAnger++
							if(b.WaveringAnger>=b.WaveringAngerLimit)
								if(prob(33))
									src.SetNoAnger(b, 1)
								else
									src.SetNoAnger(b, 0)
								b.WaveringAnger=0

					if(b.TimerLimit)
						if(!isnum(b.Timer))
							b.Timer=0
						b.Timer+=world.tick_lag
						if(b.Timer>=b.TimerLimit)
							b.Trigger(src)


		for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/A in src)
			//Activations
			if(!A.SlotlessOn)
				if(A.ABuffNeeded)
					if(!src.ActiveBuff)
						continue
					if(!(src.ActiveBuff.BuffName in A.ABuffNeeded))
						continue
				if(A.SBuffNeeded)
					if(!src.SpecialBuff)
						continue
					if(src.SpecialBuff.BuffName!=A.SBuffNeeded)
						continue
				if(A.NeedsHealth&&!A.SlotlessOn&&!A.Using&&!src.KO)
					if(src.Health<=A.NeedsHealth*(1-src.HealthCut))
						A.Trigger(src)
				if(A.ManaThreshold&&!A.SlotlessOn&&!A.Using&&!src.KO)
					if(src.ManaAmount>=A.ManaThreshold)
						A.Trigger(src)
				if(A.NeedsAnger&&!A.SlotlessOn&&!A.Using&&!src.KO)
					if(src.Anger)
						A.Trigger(src)
				if(A.AlwaysOn)
					if(!A.Using&&!A.SlotlessOn)
						A.Trigger(src)

			//Deactivations
			if(A.SlotlessOn)
				if(A.ABuffNeeded)
					if(A.ABuffNeeded.len>0)
						if(!src.ActiveBuff)
							A.Trigger(src,Override=1)
						if(!(src.ActiveBuff.BuffName in A.ABuffNeeded))
							A.Trigger(src,Override=1)
				if(A.SBuffNeeded)
					if(!src.SpecialBuff)
						A.Trigger(src,Override=1)
					if(src.SpecialBuff.BuffName!=A.SBuffNeeded)
						A.Trigger(src,Override=1)
				if(A.TimerLimit&&A.SlotlessOn)
					if(A.Timer>=A.TimerLimit)
						A.Trigger(src,Override=1)
				if(A.NeedsAnger&&A.SlotlessOn)
					if(!src.Anger)
						A.Trigger(src,Override=1)
				if(src.KO)
					if(A.SlotlessOn)
						A.Trigger(src,Override=1)
				if(A?.TooMuchHealth)
					if(src.Health>=A.TooMuchHealth)
						if(A.SlotlessOn)
							A.Trigger(src,Override=1)
				if(A.TooLittleMana)
					if(src.ManaAmount<=A.TooLittleMana)
						if(A.SlotlessOn)
							A.Trigger(src,Override=1)

			if(A.AlwaysOn)//This only gets run if it has been deactivated
				if(A.Using)
					del A


		if(src.BindingTimer>=1)
			src.BindingTimer--
			if(src.BindingTimer<=0)
				src.BindingTimer=0
				if(src.Binding)
					src.TriggerBinding()

		src.MaxHealth()
		src.MaxEnergy()
		src.MaxMana()
		src.MaxOxygen()

		var/turf/Q=src.loc
		if(!src.loc)
			EndLife(0)
			return
		if(isturf(Q))

			if(!Flying)
				var/hahalol
				var/eqip=0
				for(var/mob/P in range(1,src))
					if(P.Grab==src)
						hahalol=1
				if(passive_handler.Get("Skimming") || is_dashing || src.Flying || src.HasWaterWalk() || src.HasGodspeed() >= 2)
					hahalol=1
					if(src.Swim)
						src.Swim=0
						src.RemoveWaterOverlay()

				if(!hahalol)
					if(Q.Deluged||istype(Q,/turf/Waters)||istype(Q,/turf/Special/Ichor_Water)||istype(Q,/turf/Special/Midgar_Ichor))
						if(Swim==0)
							src.RemoveWaterOverlay()
							spawn()
								if(Q.Deluged)
									src.overlays+=image('WaterOverlay.dmi',"Deluged")
								else if(Q.type==/turf/Waters/Water7/LavaTile)
									src.overlays+=image('LavaTileOverlay.dmi')
								else
									src.overlays+=image('WaterOverlay.dmi',"[Q.icon_state]")
						Swim=1
						if(!src.KO)
							var/amounttaken=1
							if(amounttaken<0)
								amounttaken=0
							if(Q.Shallow==1)
								amounttaken=0
							if(eqip!=0)
								amounttaken=0
							if(Q.Deluged==1)
								amounttaken=4
							src.Oxygen-=amounttaken
							if(src.Oxygen<0)
								src.Oxygen=0
							if(src.Oxygen<10)
								src.LoseEnergy(5)
								if(src.TotalFatigue>=95)
									src.Unconscious(null,"fatigue due to swimming! They will drown if not rescued!")
				else
					if(Swim==1)
						src.RemoveWaterOverlay()
						Swim=0

		if(src.AngerCD>0)
			src.AngerCD--
		if(src.PotionCD>0)
			src.PotionCD--


	proc/AIAvailablePower()
		set waitfor=0
		usr = src

		if(ai_adapting_power && Target) //This is lazy as fuck. I'll fix it later, just wanted an idea.
			PowerBoost = Target.PowerInvisible
			PowerBoost *= Target.RPPower
			if(Target.HasPowerReplacement())
				PowerBoost *=(Target.GetPowerReplacement()*Target.PowerBoost) * ai_adapting_power
			else
				PowerBoost *=(Target.PowerBoost) * ai_adapting_power
		if(src.Kaioken)
			switch(src.Kaioken)
				if(1)
					src.PowerControl=150
					src.KaiokenBP=4/3
				if(2)
					src.PowerControl=150
					src.KaiokenBP=2
				if(3)
					src.PowerControl=200
					src.KaiokenBP=2
				if(4)
					src.PowerControl=250
					src.KaiokenBP=4
				if(5)
					src.PowerControl=300
					src.KaiokenBP=(20/3)
		else
			src.KaiokenBP=1
//EPM modifications
		var/EPM=1
		EPM+=src.Power_Multiplier-1//effective power multiplier
		if(src.PowerEroded)
			EPM-=src.PowerEroded
		if(src.NanoBoost&&src.Health<25)
			EPM+=0.25
		if(src.isRace(MAKYO))
			if(src.ActiveBuff&&!src.HasMechanized())
				EPM*=1+(0.5*src.AscensionsAcquired)
		if(EPM<=0)
			EPM=0.1
//Ratio
		var/Ratio=1
		Ratio*=EPM
		if(src.HasMythical())
			Ratio*=1.5
		potential_last_checked=-1
		Ratio*=src.Base()
		potential_power(src)//get them potential powers
		Ratio*=src.potential_power_mult


		//BODY CONDITION INFLUENCES
		if(!passive_handler.Get("Piloting"))
			if(!src.HasPossessive())
				if(!src.Timeless&&!src.Dead)
					if((src.EraBody=="Child"||src.EraBody=="Youth")&&src.Aged)
						Ratio*=1
					else if(src.EraBody=="Child"||src.EraBody=="Senile")
						if(src.ParasiteCrest())
							Ratio*=0.5
						Ratio*=0.4
					else if(src.EraBody=="Youth"||src.EraBody=="Elder")
						if(src.ParasiteCrest())
							Ratio*=0.5
						Ratio*=0.8
					else
						Ratio*=1
				if(locate(/obj/Seal/Power_Seal, src))
					Ratio*=0.5
				else if(src.CanLoseVitalBP()||src.passive_handler.Get("Anaerobic"))
					Ratio*=1+(src.GetHealthBPMult()+src.GetEnergyBPMult())
				if(src.JaganPowerNerf)
					Ratio*=src.JaganPowerNerf
				if(src.BPPoison)
					if((src.Secret=="Zombie"||src.Doped)&&src.BPPoison<1)
						Ratio*=1
					else
						Ratio*=src.BPPoison
				if(src.Maimed && !src.HasMaimMastery())
					src.MaimsOutstanding=max(src.Maimed-(0.5*src.GetProsthetics()), 0)
					Ratio*=(1-(0.2*src.MaimsOutstanding))
				if(src.HasWeights()&&src.Saga!="Eight Gates")
					Ratio*=0.8
				if(src.PotionCD)
					Ratio*=0.8
				if(src.Roided)
					Ratio*=1.25
				if(src.OverClockNerf)
					Ratio*=max(1-src.OverClockNerf,0.1)
				if(src.GatesNerfPerc)
					Ratio*=((100-src.GatesNerfPerc)/100)
				if(src.AngerMax)
					var/a=1
					if(src.HasCalmAnger())
						a*=src.AngerMax
					else if(Anger&&!src.HasNoAnger())
						a*=Anger
						if(src.AngerMult>1)
							var/ang=a-1//Usable anger
							var/mult=ang*src.AngerMult
							a=mult+1
						if(src.HasAngerThreshold())
							if(a<src.GetAngerThreshold())
								a=src.GetAngerThreshold()
						if(src.DefianceCounter)
							a+=src.DefianceCounter*0.05
					if(src.CyberCancel>0)
						var/ang=a-1//Usable anger.
						var/cancel=ang*src.CyberCancel//1 Cyber Cancel = all of usable anger.
						a-=cancel
						if(a<1)//Only nerf anger.
							a=1
					if(src.PhylacteryNerf)
						a-=(a*src.PhylacteryNerf)
					if(a<=0)
						a=0.01
					Ratio*=a

			if(src.PowerInvisible)
				Ratio*=src.PowerInvisible
			if(src.PowerBoost)
				Ratio*=src.PowerBoost

			if(src.Target)
				if(ismob(src.Target))
					if(src.HasMirrorStats()&&!src.Target.HasMirrorStats()&&!src.Target.CheckSlotless("Saiyan Soul"))
						Power=src.Target.Power/src.Target.GetPowerUpRatio()

		Power=Ratio*GetPowerUpRatio()

		//HIGH LEVEL FUCKERY
		if(locate(/obj/Skills/Soul_Contract, src)&&src.ContractPowered>0)
			Ratio*=1+(0.1*src.ContractPowered)
		else if(locate(/obj/Skills/Soul_Contract, src)&&src.ContractPowered<=0)
			Ratio*=0.5
		if((src.Dead||(src.z==glob.DEATH_LOCATION[3]&&!src.CheckActive("Cancer Cloth")))&&src.SenseUnlocked<8)
			Ratio*=0.5

		if(src.RPPower)
			Power*=RPPower
		if(src.KO)
			Power*=0.05

		if(prob(99))//Health/Energy Recovery
			if(GetPowerUpRatio()<=1)
				if(icon_state=="Meditate")
					if(Health<(100*(1-src.HealthCut))||src.BioArmor<src.BioArmorMax)
						Recover("Health",1)
						Recover("Injury",1)
						if(passive_handler.Get("Restoration")||src.Secret=="Zombie")
							Recover("Health",1)
							Recover("Injury",1)
							BPPoisonTimer-=15
					if(src.Energy<src.EnergyMax)
						Recover("Energy",2)
						Recover("Fatigue",2)
						if(src.passive_handler.Get("Restoration"))
							Recover("Energy",1)
							Recover("Fatigue",1)
					if(ManaAmount<((src.ManaMax-src.TotalCapacity)*src.GetManaCapMult())||src.Secret=="Senjutsu"&&src.CheckSlotless("Senjutsu Focus"))
						if(!src.HasMechanized())
							Recover("Mana",1)
							if(src.passive_handler.Get("Restoration"))
								Recover("Mana",1)
					Recover("Capacity",2)
				else
					Recover("Energy",1)

			if(src.PowerControl<=25)
				Recover("Fatigue",1)
				if(src.is_arcane_beast)
					Recover("Mana",1)

			if(src.FusionPowered)
				Recover("Energy",1)

			if(src.FusionPowered&&!src.SpecialBuff||src.is_arcane_beast)
				Recover("Mana",1)

			if(src.TotalCapacity>0)
				Recover("Capacity", 1)

		if(prob(100))//PC System
			if(src.PoweringUp==1 && !PureRPMode && src.icon_state!="Meditate")

				var/PUGain=src.PUSpeedModifier
				if(src.HasPULock())
					PUGain=0
				if(!src.HasHealthPU())
					PUGain*=src.GetRecov(10)
				else
					PUGain*=src.GetRecov(10)
				if(src.Kaioken)
					PUGain=0
					src.PoweringUp=0
				src.PowerControl+=PUGain
				var/PUThreshold=150
				if(src.PowerControl>=PUThreshold)
					src.PowerControl=PUThreshold
					src.PoweringUp=0
				if(src.Energy<=src.EnergyMax/10&&!src.PUUnlimited)
					src.Auraz("Remove")
					src<<"You are too tired to power up."
					src.PoweringUp=0
					src.PowerControl=100
					src.Energy=1

			//Beyond 100% Drain
			if(!KO && src.PowerControl>=100 && src.PoweringUp && !src.PureRPMode)
				if(src.Energy<=src.EnergyMax/10&&!src.PUUnlimited)
					src.PoweringUp=0
					src.Auraz("Remove")
					src<<"You are too tired to power up."
					src.PowerControl=100
					src.Energy=1
//				if(src.HighestPU&&!src.PURestrictionRemove)
//					if(src.PowerControl>=src.HighestPU)
//						src.PowerControl=src.HighestPU

				var/PowerDrain=1
				if(src.PowerControl<=src.PUEffortless)
					PowerDrain*=0
				if(!PureRPMode)
					if(!src.PUUnlimited)
						if(passive_handler.Get("ManaPU"))
							src.LoseMana(1*PowerDrain*glob.WorldPUDrain)
						else if(src.HasHealthPU())
							src.DoDamage(src, TrueDamage(1*PowerDrain*glob.WorldPUDrain))
						else
							src.LoseEnergy(2*PowerDrain*glob.WorldPUDrain)