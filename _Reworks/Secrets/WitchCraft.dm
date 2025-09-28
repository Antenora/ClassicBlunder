/**
 * 
 * https://docs.google.com/document/d/1sX9XgPEc-sWZ3RnSV4ujga0DnGVbiYtqQV7S6mkpHLw/edit
 * 
 * 
 */

// Soul for Power
obj/proc/SunderSoul(mob/P, mob/G) // P = Pactee, G = Giver.
	if(!P.client)
		return
	var/yesno = input(P, "You are proposed a trade, for your soul, for power by [G]. Do you accept this trade?", "Sunder your soul") in list("Yes", "No")
	switch(yesno)
		if("Yes")
			if(P.NoSoul)
				view(20)<< output("<font color=yellow>[P] lacks a soul to strike the deal !", "output")
				return
			view(20)<< output("<font color=yellow>[P] has accepted the deal !", "output")
			for(var/obj/Items/WitchCraft/WitchesBook/s in G.contents)
				s.PactedList += P.name
				var/obj/Items/WitchCraft/WitchesBook/NEW = new; NEW.loc = P
				NEW.name = input(P, "You have been granted your very own copy of [s.name]\n It is time you name your own Tome.", "Choose a name") as text
				P.AddSkill(new/obj/Skills/Buffs/NuStyle/FreeStyle/Witch_Style)
				P.AddSkill(new/obj/Skills/AutoHit/Dream_Walk)
				P.AddSkill(new/obj/Skills/AutoHit/Hex)
				P.AddSkill(new/obj/Skills/Queue/Grave_Curse)
				P.AddSkill(new/obj/Skills/Queue/Mirror_Match)
				P.NoSoul = 1
		if("No")
			view(20)<< output("<font color=yellow>[P] has declined the deal !", "output")

obj/proc/checkIfNoPassives(mob/who)
	if(who.passive_handler.Get("Maki"))
		return
	who.passive_handler.Set("Maki", 1)

mob/Admin3/verb/GiveWitchBook()
	var/mob/who = input(usr, "Who do you wish to grant this crack book") in players
	var/obj/Items/WitchCraft/WitchesBook/G = new
	G.loc = who
	G.name = input(who, "You have stumbled upon an tome you do not recognize, it's energy seems inviting yet cruel and twisted\n What is it that you will call this Tome?", "Original Copy Name.") as text
	who.passive_handler.Set("Maki", 1)
	who.NoSoul = 1
	who.AddSkill(new/obj/Skills/Buffs/NuStyle/FreeStyle/Witch_Style)
	who.AddSkill(new/obj/Skills/AutoHit/Dream_Walk)
	who.AddSkill(new/obj/Skills/AutoHit/Hex)
	who.AddSkill(new/obj/Skills/Queue/Grave_Curse)
	who.AddSkill(new/obj/Skills/Queue/Mirror_Match)

/obj/Items/WitchCraft/WitchesBook
	name = "Unnamed Tome"
	icon = 'Icons/NSE/Icons/Thot_book.dmi'
	var/CurrentEssenceAmount = 0
	var/TakeEssenceCoolDown = 0
	var/canPact = 0
	var/list/PactedList = list()
	verb/Kill_Essence(mob/M in get_step(usr, usr.dir))
		set name = "Drain Essence (Lethal)"
		set category = "Skills"
		if(!M.KO)
			usr << "[M] needs to be KO'd!"		
			return       
		var/kill = input(usr, "You're about to kill [M], by ripping apart their soul from the body, creating nothing but a husk of dust behind, are you sure?") in list("Yes", "No")
		switch(kill)
			if("Yes")
				var/confirm = input(M, "You're about to be killed by [usr], if there has been any rules broken, please hit no, else, hit yes.") in list("Yes","No")
				switch(confirm)
					if("Yes")
						M.NoSoul = 1
						M.Death(usr, "an icy breath upon their soul, their body crumbling to dust!", SuperDead = 1, NoRemains = 1)
						src.CurrentEssenceAmount += 5
						usr << "You feel yourself empowered, your [src.name] now contains [CurrentEssenceAmount] essence!"
	
	verb/Take_Essence(mob/M in get_step(usr, usr.dir))
		set name = "Take Essence"
		set category = "Skills"
		if(!M.KO)
			usr << "[M] needs to be KO'd!"
			return
		if(TakeEssenceCoolDown < world.realtime )
			src.CurrentEssenceAmount += 1
			view(10) << output("<font color=red>[M] feels as if their body decays slightly at the magic of [usr]..!!", "output")
			TakeEssenceCoolDown = world.realtime + 4 HOURS
			usr << "You feel yourself slightly empowered, your [src.name] now contains [CurrentEssenceAmount] essence!"
		else 
			usr << "You're on cooldown till [time2text(TakeEssenceCoolDown, "hh:ss") ]"

	verb/Give_Essence()
		set name = "Give Essence"
		set category = "Skills"
		var/list/PeopleWithBooks = list("Cancel", "----")

		for(var/mob/M in oview(20, src))
			if(locate(/obj/Items/WitchCraft/WitchesBook, M.contents))
				PeopleWithBooks.Add(M)

		var/mob/who = input(usr, "Which of these people do you wish to give your Essence to?") in PeopleWithBooks
		if(who == "----" || "Cancel")
			return
		if(src.CurrentEssenceAmount > 0)
			var/give = input(usr, "You have currently [src.CurrentEssenceAmount], how many of them do you wish to give to [who]?", "Give Essence") as num
			if((src.CurrentEssenceAmount - give) < 0)
				return
			else 
				for(var/obj/Items/WitchCraft/WitchesBook/G in who)
					G.CurrentEssenceAmount += give

	verb/Make_Deal(mob/M in get_step(usr, usr.dir))
		set name = "Witch Apprenticeship"
		set category = "Roleplay"
		if(canPact)
			SunderSoul(M, usr)
			checkIfNoPassives(M)
			canPact = FALSE
		else
			usr << "You can't pact someone as of this moment! You do have enought potent to make the deal."

	verb/FelMasterwork()
		var/cost = 20
		if(src.CurrentEssenceAmount > cost)
			var/list/weapons = list()
			for(var/obj/Items/Sword/Weapon in usr)
				weapons += Weapon
			if(weapons.len == 0)
				usr << "You do not have any sword to enchant"
				return .	
			var/obj/Items/Sword/Weapon = input(usr, "Select which of the weapons you wish to Fel-Masterwork", "Fel Masterwork") in weapons + "Cancel"
			if(Weapon == "Cancel") 
				usr << "You chose to reserve your Essence"
				return .
			Weapon.Element = "Felfire"
			src.CurrentEssenceAmount -= cost
			OMsg(usr, "[usr] weaves their hands upon [Weapon.name] encasing it in their <b>flames</b>!")
		else
			usr << "You do not possess enough essence for this enchantment! [CurrentEssenceAmount] / [cost]"
	Click()
		..()
		usr << "[src.name] holds [CurrentEssenceAmount] amounts of essence"

/obj/Skills/AutoHit/Dream_Walk
	Area="Circle"
	AdaptRate= 1
	DamageMult= 6
	Rounds= 10
	TurfStrike=1
	TurfShift= 'Icons/NSE/spells/tilebuff/corruption.dmi'
	TurfShiftLayer = 5
	Icon = 'Icons/Effects/DarkKiai.dmi'
	PreShockwave= 0
	Cooldown= 120
	Earthshaking= 20
	WindupMessage= "hosts up their hand....!!!"
	ActiveMessage= "slams their hand against the ground, corrupting the ground beneath..!!!"
	ComboMaster = 1
	verb/Dream_Walk()
		set category="Skills"
		var/resource = 0
		var/cost = 0.1
		for(var/obj/Items/WitchCraft/WitchesBook/G in usr)
			resource = G.CurrentEssenceAmount
		if(resource > cost)
			for(var/obj/Items/WitchCraft/WitchesBook/G in usr)
				G.CurrentEssenceAmount -= cost
			usr.Activate(src)
		else
			usr << "Not enough Essence [resource] / [cost]"




/obj/Skills/Queue/Grave_Curse
	ActiveMessage="fills the air with terrible images....!!"
	HitMessage="curses their opponents mind with horrible images...!!"
	DamageMult = 10
	AccuracyMult = 1.175
	Instinct = 1
	Paralyzing=1
	Duration = 5
	KBMult = 0.00001
	Cooldown = 150
	Quaking = 5
	PushOut = 5
	PushOutWaves = 3
	BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Witch/Grave_Curse"
	PushOutIcon = 'Icons/NSE/spells/cast/KrysiaExplosion.dmi'
	verb/Grave_Curse()
		set category="Skills"
		var/resource = 0
		var/cost = 0.5
		for(var/obj/Items/WitchCraft/WitchesBook/G in usr)
			resource = G.CurrentEssenceAmount
		if(resource > 3)
			for(var/obj/Items/WitchCraft/WitchesBook/G in usr)
				G.CurrentEssenceAmount -= cost
			usr.SetQueue(src)
		else
			usr << "Not enough Essence [resource] / [cost]"



/obj/Skills/Queue/Mirror_Match
	ActiveMessage="fills their surroundings with Mirrors!"
	HitMessage="slams back the opponents attack from the Mirrors!!"
	Counter = 1
	NoWhiff = 1
	NoMiss = 1
	DamageMult = 0.1
	AccuracyMult = 1.175
	Instinct = 1
	Duration = 5
	KBMult = 0.00001
	Cooldown = 150
	BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Witch/WitchCounter"
	verb/Mirror_Match()
		set category="Skills"
		var/resource = 0
		var/cost = 0.4
		for(var/obj/Items/WitchCraft/WitchesBook/G in usr)
			resource = G.CurrentEssenceAmount
		if(resource > cost)
			for(var/obj/Items/WitchCraft/WitchesBook/G in usr)
				G.CurrentEssenceAmount -= cost
			usr.SetQueue(src)
		else
			usr << "Not enough Essence [resource] / [cost]"

/obj/Skills/AutoHit/Hex
	Area="Target"
	AdaptRate = 1
	DamageMult = 5
	Distance = 15
	DelayTime = 0
	HitSparkIcon = 'BLANK.dmi'
	TurfDirt = 1
	ShockIcon = 'Icons/NSE/spells/cast/KrysiaHitspark2.dmi'
	Shockwave = 4
	Shockwaves = 1
	PostShockwave = 1
	PreShockwave = 0
	Cooldown= 150
	ManaCost = 50
	WindupMessage = "hosts up their hand....!!!"
	ActiveMessage = "fills their opponents body with a hex..!!!"
	BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Witch/HexDebuff"
	verb/Hex()
		set category="Skills"
		usr.Activate(src)


/obj/Skills/Queue/Finisher/Sundered_Sky
	DamageMult=6.5
	PushOutWaves=0
	PushOut=0
	Combo=4
	Rapid=1
	BuffSelf=0
	HitMessage=0






/// Debuffs / Buffs

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Witch/WitchCounter
	IconLock = 'ExcaliTrail.dmi'
	DefMult = 1.3 
	CounterSpell = 1
	CounterMaster = 2
	BuffName = "WitchCounter"
	NeedsPassword = 1
	TimerLimit = 30
	Cooldown = 4
	AlwaysOn = 1


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Witch/Grave_Curse
	passives = list("Godspeed" = -4, "PureReduction" = -2 )
	IconLock = 'Magicwish.dmi'
	ActiveMessage="begins to fall in to pieces!"
	NeedsPassword = 1
	TimerLimit = 30
	Cooldown = 4
	AlwaysOn = 1


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Witch/HexDebuff
	ActiveMessage="begins to fall apart!"
	StrMult = 0.5
	ForMult = 0.5
	EndMult = 0.75
	SlowAffected = 1
	TimerLimit = 30
	NeedsPassword = 1
	TimerLimit = 30
	Cooldown = 4
	AlwaysOn = 1
	IconLock = 'SweatDrop.dmi'
