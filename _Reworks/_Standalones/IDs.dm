globalTracker
	var
		list/IDs = list()
		IDCounter = 0

mob
	var/UniqueID


proc
	findPlayerByUID(uid)
		for(var/mob/Players/p in players)
			if(uid == p.UniqueID)
				return p

	getPlayerNameByUID(uid)
		if(uid > glob.IDs.len || uid < 1)
			return null
		return glob.IDs[uid]