
/*
races are stored as text macros; this serves two purposes.
If a typo occurs, BYOND will throw errors.
This is also done so we can easily check types.
*/
#define STAT2INDEX list("strength" = 1, "endurance" = 2, "force" = 3, "offense" = 4, "defense" = 5, "speed" = 6)
var/list/races = list()

proc
	//this adds a copy of all races to a global list called races.
	BuildRaceList()
		for(var/a in subtypesof(/race/))
			races += new a
			var/list/male_icons = list()
			var/list/female_icons = list()
			var/list/neuter_icons = list()
			for(var/male_icon in races[races.len]:icon_male)
				var/obj/race_grid_visual/visual = new(male_icon)
				male_icons += visual
			for(var/female_icon in races[races.len]:icon_female)
				var/obj/race_grid_visual/visual = new(female_icon)
				female_icons += visual
			for(var/neuter_icon in races[races.len]:icon_neuter)
				var/obj/race_grid_visual/visual = new(neuter_icon)
				neuter_icons += visual
			races[races.len]:icon_male = male_icons.Copy()
			races[races.len]:icon_female = female_icons.Copy()
			races[races.len]:icon_neuter = neuter_icons.Copy()
	//this will return a list of all race types.
	GetRaceTypes()
		for(var/race/race in races)
			. += race.type

	// if you want to get a global race from a type path, use this.
	//it will return the race instance from the global list; or null if not found.
	GetRaceInstanceFromType(_type)
		for(var/race/race in races)
			if(race.type == _type)
				return race
		return null

	//if you want to get the global race from it's name, use this.
	// this will return a matching race if found, or null if not found.
	GetRaceInstanceFromName(_name)
		for(var/race/race in races)
			if(race.name == _name)
				return race
		return null


/mob/Admin4/verb/forceCuckRace(mob/Players/P in players)
	P.race = new()




world
	New()
		..()
		BuildRaceList()

obj
	race_grid_visual
		New(icon/i)
			icon = i
			name = " "

		Click()
			..()
			usr.icon = icon
			if(istype(usr, /mob/Creation))
				usr.dir = SOUTH
				usr.screen_loc = "IconUpdate:1,1"
				usr.client.screen += usr
mob
	var
		race/race

mob
	proc

		setRace(race/new_race, statRedo = FALSE)
			if(!new_race) throw EXCEPTION("setRace was not supplied a new_race argument!")
			if(!passive_handler) passive_handler = new

			if(race)
				race.onDeselection(src)

			race = new new_race.type
			race.onSelection(src)

		// isRace will accept either a type or a name.
		isRace(raceCheck)
			if(!race)
				throw EXCEPTION("[src] has no race to check!")
				// prob usually impossible
				return 0
			/*
				return:
					1 if match is found
					0 if not found
					throws a exception if no race is supplied for checking.
			*/
			if(!raceCheck) throw EXCEPTION("isRace was not supplied a raceCheck argument!")
			if(race.type == raceCheck || race.name == raceCheck) return 1
			return 0

race
	var
		// the formal name for the race
		name = ""
		classes = list("Shonen")
		current_class = 1 // first index
		class_info = list("Generic DBR Character #341")
		//gender options. so far implemented ones are Male, Female & Neuter. Neuter is for namekians or so on.
		gender_options = list("Male", "Female")
		//the icon used for male gender
		list/icon_male = list('frisky-male_black_brown.dmi', 'frisky-male_dark_brown.dmi', 'frisky-male_pale_brown.dmi', 'frisky-male_tan_brown.dmi', 'frisky-male_white_brown.dmi')
		//the icon used for female gender.
		list/icon_female = list('frisky-femmale_black_brown.dmi', 'frisky-femmale_dark_brown.dmi', 'frisky-femmale_pale_brown.dmi', 'frisky-femmale_tan_brown.dmi', 'frisky-femmale_white_brown.dmi')
		//icon used for neuter gender.
		list/icon_neuter = list()

		//this determines if the race is a 'rare' and is only unlocked via someone's key being in the LockedRaces list.
		locked = FALSE

		//a text description for the race; displayed to the user.
		desc
		//a picture used for the racial menu.
		visual

		//default health/energy/mana
		health = 100
		energy = 100
		mana = 100

		power = 2

		statPoints = 10

		//1 = 1 for these.
		strength = 1 // if we change this to class = num, it will break everything
		endurance = 1
		force = 1
		offense = 1
		defense = 1
		speed = 1
		stats_per_class = list() //NIEZAAAAANNNNN 
		anger_message = "becomes angry!"
		anger_point = 50

		//anger. 1 = 100%, 2 = 200%
		anger = 1.5
		regeneration = 1
		recovery = 2

		learning = 1
		intellect = 1
		imagination = 1

		economy = 1

		// a list of overlays; such as saiyan tails, or so on.
		//TODO: Implement better.
		list/overlays = new/list()

		// a list of skills that specific races may need to start with.
		list/skills = new/list()

		//a list of passives a race needs to start with.
		list/passives = new/list()

		//these will be listed in terms of intended accquistion; race_ascension[1] is first asc, and so on.
		//these have their requirements built in as unlock_potential.
		list/ascensions = new/list()
		list/transformations = new/list()

	New()
		/*
			ensure the race's name variable is the same as the ascensions/transformation type.
			if it isn't, you have to manually add them.
			this is so it's very easy and automatic to throw ascensions in and out.
		*/
		var/name_typed = replacetext("[type]", "/race/", "")
		var/list/ascpaths = subtypesof(text2path(replacetext("/ascension/[name_typed]"," ", "_")))
		var/list/transpaths = subtypesof(text2path(replacetext("/transformation/[name_typed]"," ", "_")))
		if(lowertext(name) == "half_saiyan")
			transpaths = list()
		for(var/i in ascpaths)
			ascensions += new i
		for(var/i in transpaths)
			transformations += new i

	proc
		fixAscensions()
			var/name_typed = replacetext(type, "/race/", "")
			var/list/ascpaths = subtypesof(text2path(replacetext("/ascension/[name_typed]"," ", "_")))
			for(var/i in ascpaths)
				ascensions += new i
		getChoice(ascLevel)
			return ascensions[ascLevel].choiceSelected
		getClass()
			return classes[current_class]
		getStat(stat)
			if(length(stats_per_class))
				return stats_per_class[getClass()][STAT2INDEX[stat]]
			else
				return vars[stat]
		onDeselection(mob/user)
			user.overlays -= overlays

		onSelection(mob/user, secondtime = FALSE, force_icon = FALSE)
			if(!user.passive_handler) user.passive_handler = new


			if(force_icon||!user.icon)
				if(user.Gender == "Female")
					var/chosen = rand(1,icon_female.len)
					user.icon = icon_female[chosen]
				else if(user.Gender == "Male")
					var/chosen = rand(1,icon_male.len)
					user.icon = icon_male[chosen]
				else if(user.Gender == "Neuter")
					var/chosen = rand(1,icon_neuter.len)
					user.icon = icon_neuter[chosen]

			user.icon_state = null
			user.overlays += overlays

			user.AngerPoint = anger_point
			user.AngerMessage = anger_message
			if(!secondtime)
				user.SetStatPoints(statPoints)
				user.SetStat("Power", power)
				user.SetStat("Strength", strength)
				user.SetStat("Endurance", endurance)
				user.SetStat("Speed", speed)
				user.SetStat("Force", force)
				user.SetStat("Offense", offense)
				user.SetStat("Defense", defense)
			user.SetStat("Regeneration", regeneration)
			user.SetStat("Recovery", recovery)
			user.SetStat("Anger", anger)
			user.SetStat("Learning", learning)
			user.SetStat("Intellect", intellect)
			user.SetStat("Imagination", imagination)

			user.EconomyMult = economy

		onFinalization(mob/user)
			user.passive_handler.increaseList(passives)
			for(var/s in skills)
				user.AddSkill(new s)

		onAnger(mob/user)

		onCalm(mob/user)