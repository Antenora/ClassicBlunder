
/*
races are stored as text macros; this serves two purposes.
If a typo occurs, BYOND will throw errors.
This is also done so we can easily check types.
*/
//when you feel like inflicting pain on yourself:
//normalize the order of stats being Strength, Force, Endurance, Speed, Offense, Defense
//... everywhere
#define STAT2INDEX list("strength" = 1, "endurance" = 2, "force" = 3, "offense" = 4, "defense" = 5, "speed" = 6)
#define STAT3INDEX list("anger" = 1, "learning" = 2, "intellect" = 3, "imagination" = 4, "economy" = 5) //here for posterity, not sure if I'm gonna do it this way yet
var/list/races = list()

proc
	//this adds a copy of all races to a global list called races.
	BuildRaceList()
		for(var/a in subtypesof(/race))
			if(!ispath(a)) continue
			var/race/r = new a
			if(!r) continue
			races += r
			var/list/male_icons = list()
			var/list/female_icons = list()
			var/list/neuter_icons = list()
			if(r.icon_male)
				for(var/male_icon in r.icon_male)
					var/obj/race_grid_visual/visual = new(male_icon)
					male_icons += visual
			if(r.icon_female)
				for(var/female_icon in r.icon_female)
					var/obj/race_grid_visual/visual = new(female_icon)
					female_icons += visual
			if(r.icon_neuter)
				for(var/neuter_icon in r.icon_neuter)
					var/obj/race_grid_visual/visual = new(neuter_icon)
					neuter_icons += visual
			r.icon_male = male_icons.Copy()
			r.icon_female = female_icons.Copy()
			r.icon_neuter = neuter_icons.Copy()
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

		// Race CHANGE for already-finalized players. Unlike setRace (which is geared
		// for character creation), this strips the old race's contributions before
		// installing the new one, so passives/skills/ascensions/transformations don't
		// stack across the transition.
		//
		//   new_race_or_path : either a /race type path or a race instance.
		//   redo_stats       : if TRUE, base stats are reset to the new race's values.
		//                      If FALSE (default) the player's earned stats are kept.
		//   keep_ascensions  : if TRUE, AscensionsAcquired/Unlocked are preserved
		//                      (the old race's ascensions are NOT reverted). Use this
		//                      only when the caller has already accounted for ascension
		//                      stat contributions.
		//
		// Returns 1 on success, 0 if no change happened (already that race / bad arg).
		ChangeRace(new_race_or_path, redo_stats = FALSE, keep_ascensions = FALSE)
			if(!new_race_or_path) return 0
			if(!passive_handler) passive_handler = new

			var/race/new_race
			if(ispath(new_race_or_path))
				new_race = new new_race_or_path
			else if(istype(new_race_or_path, /race))
				var/race/incoming = new_race_or_path
				new_race = new incoming.type
			else
				return 0

			if(race && race.type == new_race.type)
				del(new_race)
				return 0

			if(race)
				// Roll back every active transformation tier so trans-stat boosts
				// don't linger after the race swap.
				var/safety = 10
				while(transActive > 0 && safety > 0)
					var/prev = transActive
					Revert()
					if(transActive >= prev) break
					safety--

				// Unwind ascensions in reverse order so each layer's revertAscension
				// sees the same state it was applied on top of.
				if(!keep_ascensions && islist(race.ascensions))
					for(var/i = race.ascensions.len, i >= 1, i--)
						var/ascension/a = race.ascensions[i]
						if(a && a.applied)
							a.revertAscension(src)
					AscensionsAcquired = 0
					AscensionsUnlocked = 0

				if(islist(race.passives) && race.passives.len)
					passive_handler.decreaseList(race.passives)

				// Only racial skills granted via race.skills are stripped. Skills the
				// player learned through tomes / other sources are left alone.
				if(islist(race.skills))
					for(var/skill_path in race.skills)
						if(!ispath(skill_path)) continue
						var/obj/Skills/found = locate(skill_path) in src.contents
						if(found)
							DeleteSkill(found)

				race.onChangeOut(src)
				race.onDeselection(src)

			race = new_race
			new_race.onSelection(src, secondtime = !redo_stats, force_icon = TRUE)
			new_race.onFinalization(src)
			new_race.onChangeIn(src)

			return 1

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

		//races that have been removed or i haven't decided on adding yet. this determines if a race won't show up on the list even for admins, because cycling through a dozen races has always been really annoying.
		removed = FALSE

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
		secondary_stats_per_class = list()
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
		revertAndFixAllAscensions(mob/p)
			if(!p)
				liveDebugMsg("revertAndFixAllAscensions() was called without a mob passed in.");
				return;
			for(var/ascension/a in p.race.ascensions)
				if(a.applied)
					if(istype(a.choiceSelected, /ascension))
						continue;
					if(ispath(a.choiceSelected))//if it is a type and not an ascension...
						var/ascension/newasc = new a.choiceSelected;//make it an actual ascension
						newasc.applied=1;//also mark it as applied !
						a.choiceSelected = newasc;
				a.revertAscension(p)
				p.race.ascensions.Remove(a);
			p << "Ascensions reverted."
			p.race.fixAscensions();
			p << "Ascensions fixed."

		fixAscensions()
			var/name_typed = replacetext("[type]", "/race/", "")
			var/list/ascpaths = subtypesof(text2path(replacetext("/ascension/[name_typed]"," ", "_")))

			for(var/i in ascpaths)
				ascensions += new i
		fixTransformations()
			var/basePath = replacetext("/transformation/[lowertext(src.name)]", " ", "_");
			DEBUGMSG("<font color='red'>looking at base path [basePath]</font color>")
			var/list/transpaths = subtypesof(text2path(basePath))
			transformations=list();
			for(var/i in transpaths)
				transformations += new i
		getChoice(ascLevel)
			return ascensions[ascLevel].choiceSelected
		getClass()
			return classes[current_class]
		getStat(stat)
			if(length(stats_per_class))
				return stats_per_class[getClass()][STAT2INDEX[stat]]
			else
				return vars[stat]
		getSecondStat(stat)
			if(length(secondary_stats_per_class))
				return secondary_stats_per_class[getClass()][STAT3INDEX[stat]]
			else
				return vars[stat]
		onDeselection(mob/user)
			user.overlays -= overlays

		// Hooks for ChangeRace. Default impls are no-ops; races override these
		// to clean up race-specific mob state (e.g. Majin absorb rooms / blob
		// passive datums) on the way out, or to set up race-specific state
		// beyond what onFinalization covers on the way in.
		onChangeOut(mob/user)
			return

		onChangeIn(mob/user)
			return

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
