globalTracker/var/GameStarted=0
globalTracker/var/GameEnded=0
globalTracker/var/alist/StarTally=alist()

mob
	proc
		TakeStars(var/Value)
			for(var/obj/Stars/defender in src)
				defender.Level-=Value
				defender.name="[Commas(round(defender.Level))] Stars"
		GiveStars(var/Value,var/Name)
			for(var/obj/Stars/defender in src)
				if(Name)
					defender.StarHolder=Name
				defender.Level+=Value
				defender.name="[Commas(round(defender.Level))] Stars"
			if(Value>1)
				src << "You've gained [Commas(round(Value))] stars."
			else
				src << "You've gained [Commas(round(Value))] star."
		DropStars(var/Value)
			var/obj/Stars/defender=new
			defender.Level=Value
			defender.name="[Commas(round(defender.Level))] Stars"
			defender.loc=get_step(src, src.dir)
			for(var/obj/Stars/m2 in src)
				defender.icon=m2.icon
			src.TakeStars(defender.Level)
		IncreaseTally(var/Amount)
			for(var/obj/Stars/defender in src)
				var/StarLevel=defender.Level+Amount
				var/HolderName=defender.StarHolder
				glob.StarTally.Add("[HolderName]"=StarLevel)
		DecreaseTally(var/Amount)
			for(var/obj/Stars/defender in src)
				var/StarLevel=defender.Level-Amount
				var/HolderName=defender.StarHolder
				glob.StarTally.Add("[HolderName]"=StarLevel)

obj/Stars
	Level=0
	var/StakedStars=0
	var/StarHolder
	icon='star.dmi'
	Stealable=1
	layer=5
	Click()
		if(!(world.time > usr.verb_delay)) return
		usr.verb_delay=world.time+1
		if((src in usr))
			if(glob.GameEnded==1)
				del (locate(/obj/Stars, usr))
			if(glob.GameStarted==0)
				usr << "You cannot stake stars right now."
				return
			if(usr.Health<99*(1-usr.HealthCut))
				usr << "You can only stake stars at [100*(1-usr.HealthCut)]% health."
				return
			var/Stakes=input(usr, "Stake how many? (1-[src.Level])") as num
			Stakes=round(Stakes)
			if(Stakes<1) Stakes=1
			if(Stakes>src.Level) Stakes=src.Level
			src.StakedStars=Stakes
			if(Stakes>1)
				OMsg(usr, "[usr] stakes [Commas(round(Stakes))] stars!")
			else
				OMsg(usr, "[usr] stakes [Commas(round(Stakes))] star!")
		else
			if(ismob(src.loc)&&src.loc:KO)
				if(locate(/obj/Stars, usr))
					if(glob.GameStarted==0)
						usr << "You cannot claim stars right now."
						return
					var/Amount=src.StakedStars
					src.StakedStars=0
					if(Amount>src.Level)
						Amount=src.Level
					if(Amount<1||!Amount)
						usr << "You cannot take any more."
						return
					src.loc:DecreaseTally(Amount)
					src.loc:TakeStars(Amount)
					if(Amount>1)
						OMsg(usr, "[usr] claims [Commas(round(Amount))] stars from [src.loc]!")
					else
						OMsg(usr, "[usr] claims [Commas(round(Amount))] star from [src.loc]!")
					usr.IncreaseTally(Amount)
					usr.GiveStars(Amount)
				else
					usr << "The stars reject you."

/obj/Skills/StarMaster
	var/GiveAmount=0
	var/tallyText
	verb/StarAmount()
		set category="Utility"
		set name="Star Amount"
		GiveAmount=input(usr, "Give how many?") as num
	verb/GiveStars()
		set category="Utility"
		set name="Give Stars"
		for(var/mob/Players/P in get_step(src,usr.dir))
			if(!locate(/obj/Stars, P))
				P.contents+=new/obj/Stars
				P.GiveStars(GiveAmount,P.name)
				glob.StarTally.Add("[P.name]"=GiveAmount)
	verb/RevokeStars()
		set category="Utility"
		set name="Revoke Stars"
		for(var/mob/Players/P in get_step(src,usr.dir))
			if(locate(/obj/Stars, P))
				del (locate(/obj/Stars, P))
				glob.StarTally.Remove("[P.name]")
	verb/StartGame()
		set category="Utility"
		set name="Start Game"
		glob.GameEnded=0
		glob.GameStarted=1
	verb/PauseGame()
		set category="Utility"
		set name="Pause Game"
		glob.GameStarted=0
	verb/EndGame()
		set category="Utility"
		set name="End Game"
		glob.GameStarted=0
		glob.GameEnded=1
	verb/ShowTally()
		set category="Utility"
		set name="Show Tally"
		for(var/name,score in glob.StarTally)
			usr << "[name]: [score] Stars"