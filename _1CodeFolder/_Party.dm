var/MAX_PARTY_LIMIT = 10

Party
	var/tmp/list/mob/members=list()
	var/highest_potential
	var/tmp/mob/leader

	proc
		create_party(var/mob/m)
			if(m.party)
				m << "You already are in a party; leave it before you create another one!"
				return
			src.leader=m
			src.add_member(m)
			src.members << "[m] has created a party!"
		pass_leader(var/mob/m1, var/mob/m2)
			if(src.members.Find(m1) && src.members.Find(m2))
				if(src.leader==m1)
					src.leader=m2
					src.members << "[m1] has passed [m2] leadership of the party!"
				else
					m1 << "You aren't the leader of the party, so you can't pass [m2] leadership."
			else
				m1 << "[m2] isn't in the party, so they can't become the leader."
				return
		add_member(var/mob/m)
			if(!m.client)
				return
			if(src.members.len>=MAX_PARTY_LIMIT)
				src.members << "[m] cannot be added to the party because the party already has [MAX_PARTY_LIMIT] members!"
				return
			if(m.party)
				src.members << "[m] already has a party and cannot join your's!"
				return
			if(istype(m, /mob/Player/AI))
				src.members << "You can't add AI to your party!"
				return
			if(m==src.leader||alert(m, "Do you want to join [src.leader]'s party?", "Party Offer", "No", "Yes")=="Yes")
				if(src.members.len>=MAX_PARTY_LIMIT)
					src.members << "[m] cannot be added to the party because the party already has [MAX_PARTY_LIMIT] members!"
					return
				if(m in members)
					return
				m.party=src
				src.members.Add(m)
				if(src.members.len>2)
					src.members << "[m] has joined the party!"
				src.highest_potential()
		remove_member(var/mob/m)
			if((!m in src.members))
				return
			src.members << "[m] has been removed from the party!"
			src.members.Remove(m)
			m.party = null
			if(src.leader==m)
				if(src.members.len>0)
					src.leader=src.members[1]
					src.members << "[src.leader] has been selected as the new leader of the party!"
				else
					del src
			if(src)
				src.highest_potential()

		highest_potential()
			var/highest=0
			for(var/mob/m in src.members)
				if(m.Potential>highest)
					highest=m.Potential
			src.highest_potential=highest