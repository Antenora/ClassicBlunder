globalTracker
	var/list/guilds = list()
	var/guildIDTicker = 0

mob/Players/var/list/inGuilds = list()


/mob/Admin3/verb/CreateGuild()
	var/name = input(usr,"What do you want the guild to be named?") as null|text
	if(!name) return
	var/guild/guild = new()
	guild.name = name
	guild.id = ++glob.guildIDTicker
	glob.guilds += guild
	usr << "[guild] is now created."

/mob/Admin3/verb/assignGuildLeader(mob/Players/player in world)
	var/guild/whatGuild = input(usr, "What guild do you want to make [player.name] the leader of?") as null|anything in glob.guilds
	if(!whatGuild) return
	whatGuild.joinGuild(player)
	whatGuild.ownerID = player.UniqueID
	whatGuild.checkVerbs(player)
	usr << "[player] is now assigned as leader of [whatGuild]!"

/mob/Admin3/verb/toggleGuildGiveRanking()
	var/guild/whatGuild = input(usr, "What guild ") as null|anything in glob.guilds
	if(!whatGuild) return
	whatGuild.givesRanking = !whatGuild.givesRanking
	usr << "[whatGuild] can [whatGuild.givesRanking ? "now":"not"] give rankings"

/mob/Admin3/verb/alterGuildGankTier()
	var/guild/whatGuild = input(usr, "What guild ") as null|anything in glob.guilds
	if(!whatGuild || !whatGuild.givesRanking) return
	var/cancel = FALSE
	while(cancel != TRUE)
		var/i = input(usr, "What tier can they give? Use 'Cancel' to exit.") as text
		if(i == "Cancel" || i == "cancel")
			cancel = TRUE
			break // lol
		else
			if(i in whatGuild.tiersCanGive)
				whatGuild.tiersCanGive += i
		sleep(1)

/mob/Admin3/verb/forceJoinGuild(mob/player in world)
	var/guild/whatGuild = input(usr, "What guild do you want to make [player.name] join?") as null|anything in glob.guilds
	if(!whatGuild) return
	whatGuild.joinGuild(player)
	usr << "[player] has been forced to join [whatGuild]"

/mob/Admin3/verb/forceLeaveGuild(mob/player in world)
	var/guild/whatGuild = input(usr, "What guild` do you want to make [player.name] leave?") as null|anything in glob.guilds
	if(!whatGuild) return
	whatGuild.removeMember(player)
	usr << "[player] has been forced to leave [whatGuild]"

/mob/Admin3/verb/changeGuildPayoutRate()
	var/guild/whatGuild = input(usr, "What guild do you want to change the pay out rate of?") as null|anything in glob.guilds
	if(!whatGuild) return
	var/payoutRateNew = input(usr, "What would you like to change their pay out rate to? 0.25 = 4 fragments to 1 money.", whatGuild.payOutRate) as num|null
	if(!payoutRateNew) return
	whatGuild.payOutRate = payoutRateNew
	usr << "[whatGuild]'s payout rate has been changed to [payoutRateNew]"

proc
	findGuildByID(id)
		for(var/guild/guild in glob.guilds)
			if(guild.id == id)
				return guild

mob
	proc
		checkVerbs()
			for(var/guild/guild in glob.guilds)
				guild.updateListing(src)
				guild.checkVerbs(src)
			if(isRace(MAKYO))
				verbs += /mob/proc/toggle_makyo_boons
			if(isRace(BEASTMAN) && race?:Racial == "Monkey King")
				verbs += /mob/proc/change_nimbus_message

guild
	verb
		listGuildMembers()
			set name = "List Guild Members"
			set category = "Guild"
			var/guildID = input("What guild would you like to remove someone from?", "Remove Member") as null|anything in usr:inGuilds
			if(!guildID) return
			var/guild/guild = findGuildByID(guildID)
			guild.showMemberList(usr)

		removeGuildMember()
			set name = "Remove Member"
			set category = "Guild"
			var/guildID = input("What guild would you like to remove someone from?", "Remove Member") as null|anything in usr:inGuilds
			if(!guildID) return
			var/guild/guild = findGuildByID(guildID)
			if((usr:UniqueID in guild.officers) || (usr:UniqueID == guild.ownerID))
				guild.removeMemberByID(usr)
			else
				usr << "You aren't an officer or owner of [guild.name]!"



		addGuildMember()
			set name = "Add Member"
			set category = "Guild"
			var/guildID = input("What guild would you like to add someone to?", "Add Member") as null|anything in usr:inGuilds
			if(!guildID) return
			var/guild/guild = findGuildByID(guildID)
			if((usr:UniqueID in guild.officers) || (usr:UniqueID == guild.ownerID))
				var/list/validTargets = list()
				for(var/mob/Players/p in oview(15,usr))
					validTargets += p
				var/mob/Players/pickedTarget = input("Who would you like to add to [guild.name]?") as null|anything in validTargets
				if(!pickedTarget) return
				switch(alert(pickedTarget, "Would you like to join [guild.name] at the request of [usr.name]?",,"Yes","No"))
					if("Yes")
						guild.joinGuild(pickedTarget)
					if("No")
						return
			else
				usr << "You aren't an officer or owner of [guild.name]!"

		addOfficer()
			set name = "Add Officer"
			set category = "Guild"
			var/guildID = input("What guild would you like to make someone an officer in?", "Add Officer") as null|anything in usr:inGuilds
			if(!guildID) return
			var/guild/guild = findGuildByID(guildID)
			if(usr:UniqueID == guild.ownerID)
				guild.addOfficerByID(usr)
			else
				usr << "You aren't the owner of [guild.name]!"

		removeOfficer()
			set name = "Remove Officer"
			set category = "Guild"
			var/guildID = input("What guild would you like to remove an officer from?", "Remove Officer") as null|anything in usr:inGuilds
			if(!guildID) return
			var/guild/guild = findGuildByID(guildID)
			if(usr:UniqueID == guild.ownerID)
				guild.removeOfficerByID(usr)
			else
				usr << "You aren't the owner of [guild.name]!"

		transferOwnershipVerb()
			set name = "Transfer Ownership"
			set category = "Guild"
			var/guildID = input("What guild would you like to transfer ownership of?", "Guild Transfer Ownership") as null|anything in usr:inGuilds
			if(!guildID) return
			var/guild/guild = findGuildByID(guildID)
			if(usr:UniqueID == guild.ownerID)
				guild.transferOwnership(usr)
			else
				usr << "You aren't the owner of [guild.name]!"

		leaveGuild()
			set name = "Leave Guild"
			set category = "Guild"
			var/guildID = input("What guild would you like to leave?", "Leave Guild") as null|anything in usr:inGuilds
			if(!guildID) return
			var/guild/guild = findGuildByID(guildID)
			if(usr:UniqueID == guild.ownerID)
				usr << "Either transfer leadership or contact the admins to leave your guild!"
			else
				guild.removeMember(usr)

		guildExchange()
			set name = "Exchange Money"
			set category = "Guild"
			var/guildID = input("What guild would you like to utilize to exchange?", "Fragment exchange") as null|anything in usr:inGuilds
			var/howManyFragments = input("How many fragements would you like to exchange", "Exchage fragments") as num
			var/guild/guild = findGuildByID(guildID)
			if((usr:UniqueID in guild.officers)||usr:UniqueID==guild.ownerID)
				guild.guildTransaction(howManyFragments)
			else
				usr << "You do not have the right to do deez"
		
		assignRankingTier()
			set name = "Assign Ranking"
			set category = "Guild"
			var/mob/p = input(usr, "Whomstve") in oview(2, src)
			if(!p) return
			p.information.rankingTier = input(usr, "What tier") in tiersCanGive
			p.information.rankingNumber = input(usr, "what number? Your max is [maxNumberCanGive]") as num
			if(p.information.rankingNumber > maxNumberCanGive)
				p.information.rankingNumber = 0
				usr << "try again..."
		
guild
	var
		name
		indentificationNumber
		ownerID
		exchangeList
		list/officers = list()
		list/members = list()// by UniqueID
		payOutRate = 0.25 // 0.25 = 4 fragments into 1 money
		id
		givesRanking = FALSE
		tiersCanGive = list()
		maxNumberCanGive = 10
	proc
		showMemberList(mob/Players/p)
			p << getMemberList()

		checkMember(mob/Players/p)
			if(p.UniqueID in members)
				return 1
			return 0

		checkVerbs(mob/Players/p)
			p.verbs += /guild/verb/leaveGuild
			if(p.UniqueID == ownerID)
				p.verbs += /guild/verb/addOfficer
				p.verbs += /guild/verb/removeOfficer
				p.verbs += /guild/verb/transferOwnershipVerb
				p.verbs += /guild/verb/guildExchange
				if(givesRanking)
					p.verbs += /guild/verb/assignRankingTier
			if((p.UniqueID == ownerID) || (p.UniqueID in officers))
				p.verbs += /guild/verb/addGuildMember
				p.verbs += /guild/verb/removeGuildMember
				p.verbs += /guild/verb/guildExchange

		removeVerbs(mob/Players/p)
			p.verbs -= /guild/verb/leaveGuild
			if(p.UniqueID == ownerID)
				p.verbs -= /guild/verb/addOfficer
				p.verbs -= /guild/verb/removeOfficer
				p.verbs -= /guild/verb/transferOwnershipVerb
			if((p.UniqueID == ownerID) || (p.UniqueID in officers))
				p.verbs -= /guild/verb/addGuildMember
				p.verbs -= /guild/verb/removeGuildMember

		joinGuild(mob/Players/p)
			updateListing(p)
			if(id in p.inGuilds)
				return
			if(p.UniqueID in members)
				return
			members |= p.UniqueID
			p.inGuilds |= id
			p.checkVerbs()

		removeMember(mob/Players/p)
			if(p.UniqueID in members)
				removeVerbs(p)
				members -= p.UniqueID
				p.inGuilds -= name
				if(p.UniqueID in officers)
					officers -= p.UniqueID

		removeID(id)
			if(id in members)
				members -= id
				for(var/mob/Players/m in players)
					if(m.UniqueID == id)
						m << "You've been removed from [name]!"
						m.inGuilds -= id
						break

		guildTransaction(sum)
			if(!usr.HasFragments(sum))
				usr <<"You can't go in to the negatives."
				return
			else
				usr << "You have exchanged [sum] amount of fragments and..."
				usr.TakeFragments(sum)
				usr.GiveMoney(sum*payOutRate)


		guildMessage(msg)
			for(var/mob/Players/m in players)
				if(m.UniqueID in members)
					usr << "\[GUILD: [name]\] [msg]"

		removeMemberByID(mob/Players/origin)
			if(!(origin.UniqueID in officers) && (origin.UniqueID != ownerID)) return

			var/canRemoveOfficer = FALSE
			if(origin.UniqueID == ownerID)
				canRemoveOfficer = TRUE
			var/removedMember = input(origin,"Who would you like to remove?", "Remove Member") as null|anything in getMemberList()
			if(!removedMember) return
			var/list/r = splittext(removedMember, "-")
			removedMember = text2num(r[1])
			if(removedMember in officers)
				if(!canRemoveOfficer) return
			if(removedMember==ownerID) return
			removeID(removedMember)

		transferOwnership(mob/Players/origin)
			if(origin.UniqueID != ownerID) return
			var/target = input(origin,"Who would you like to transfer ownership to?", "Transfer Ownership") as null|anything in getMemberList()
			if(!target) return
			var/list/r = splittext(target, "-")
			target = text2num(r[1])
			if(target == ownerID) return
			switch(alert(origin, "Are you sure you want to give the guild to [r[2]]?",,"Yes","No"))
				if("No")
					return
			ownerID = target
			checkVerbs(origin)
			for(var/mob/Players/m in players)
				if(m.UniqueID == target)
					m << "You now own [name]."
					checkVerbs(m)
					break

		addOfficerByID(mob/Players/origin)
			if(origin.UniqueID != ownerID) return
			var/officer = input(origin,"Who would you like to add as a officer?", "Add Officer") as null|anything in getMemberList()
			if(!officer) return
			var/list/r = splittext(officer, "-")
			officer = text2num(r[1])
			if(officer in officers) return
			officers |= officer
			for(var/mob/Players/m in players)
				if(m.UniqueID == officer)
					checkVerbs(m)
					break


		removeOfficerByID(mob/Players/origin)
			if(origin.UniqueID != ownerID) return
			var/officer = input(origin,"Who would you like to remove as a officer?", "Remove Officer") as null|anything in getOfficerList()
			if(!officer) return
			var/list/r = splittext(officer, "-")
			officer = text2num(r[1])
			if(!(officer in officers)) return
			officers -= officer
			for(var/mob/Players/m in players)
				if(m.UniqueID == officer)
					checkVerbs(m)
					break

		getMemberList()
			var/list/memberNames = list()
			for(var/id in members)
				memberNames += "[id] - [glob.IDs[id]]"
			return memberNames

		getOfficerList()
			var/list/officerNames = list()
			for(var/id in officers)
				officerNames += "[id] - [glob.IDs[id]]"
			return officerNames

		updateListing(mob/Players/p)
			if(p.UniqueID in members)
				if(!(id in p.inGuilds))
					p.inGuilds |= id
			else
				if(name in p.inGuilds)
					p << "You've been removed from [name]!"
					p.inGuilds -= id


/proc/moveElement(list/L, fromIndex, toIndex)
	if(fromIndex == toIndex || fromIndex+1 == toIndex)	//no need to move
		return
	if(fromIndex > toIndex)
		++fromIndex	//since a null will be inserted before fromIndex, the index needs to be nudged right by one
	L.Insert(toIndex, null)
	L.Swap(fromIndex, toIndex)
	L.Cut(fromIndex, fromIndex+1)

/proc/adjustRankings()
	for(var/x in 1 to length(glob.GUILD_RANKINGS))
		var/index = x // 1 to length, we cant use numericals to index the list that is indexed by text
		var/yindex =0
		for(var/y in glob.GUILD_RANKINGS)
			yindex++ // so we need to loop through this list, but not go over the index, essentially we only want to set something that is = to index
			if(yindex == index)
				glob.GUILD_RANKINGS[y] = x
/proc/getGuildRankings(guild)
	if(!glob.GUILD_RANKINGS[guild])
		return 10
	return glob.GUILD_RANKINGS[guild]

/proc/getExchangeRate(guild)
	var/highest = 1 // 1 is the highest rank
	var/lowest = 1 // 1 is the lowest rank
	for(var/x in glob.GUILD_RANKINGS)
		if(glob.GUILD_RANKINGS[x] < highest)
			highest = glob.GUILD_RANKINGS[x]
		else if(glob.GUILD_RANKINGS[x] > lowest)
			lowest = glob.GUILD_RANKINGS[x]
	if(!glob.GUILD_RANKINGS[guild])
		return 1
	// given the highest and lower, we can calculate the exchange rate
	return PLAYER_EXCHANGE_RATE + clamp(1 - glob.GUILD_RANKINGS[guild], -4 , 0)

/mob/Admin3/verb/AddGuildToRanking()
	set category = "Politics"
	var/guild = input("Guild Name: ") as text
	var/rank = input("Rank: ") as num
	var/previous = glob.GUILD_RANKINGS[guild]
	if(!previous)
		glob.GUILD_RANKINGS[guild] = rank
		moveElement(glob.GUILD_RANKINGS, length(glob.GUILD_RANKINGS), rank)
	else
		glob.GUILD_RANKINGS[guild] = rank
		moveElement(glob.GUILD_RANKINGS, previous, rank)
	adjustRankings()

/mob/Admin3/verb/RemoveGuildFromRanking()
	set category = "Politics"
	var/guild = input("Guild Name: ") in glob.GUILD_RANKINGS
	glob.GUILD_RANKINGS.Remove(guild)

//TODO: prob remove innit ?
/*
/mob/verb/View_Guild_Ranks()
	set category = "Roleplay"
	var/startText = "[SYSTEM]Guild Rankings]"
	for(var/x in glob.GUILD_RANKINGS)
		if(glob.GUILD_RANKINGS[x] > 0)
			startText += "\n[SYSTEM][x] ([glob.GUILD_RANKINGS[x]])]"
	src << "[startText][SYSTEMTEXTEND]"*/