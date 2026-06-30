var/MAX_PARTY_LIMIT = 4
#define PARTY_INVITE_TIMEOUT 300   // time before an unanswered invite auto-expires

Party
	var/tmp/list/mob/members=list()
	var/highest_potential
	var/tmp/mob/leader
	var/tmp/list/mob/pending_invites=list()      

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
					src.refresh_ui()
				else
					m1 << "You aren't the leader of the party, so you can't pass [m2] leadership."
			else
				m1 << "[m2] isn't in the party, so they can't become the leader."
				return
		add_member(var/mob/m)
			if(!m || !m.client)
				return
			if(src.members.len>=MAX_PARTY_LIMIT)
				if(src.leader) src.leader << "[m] can't join - the party already has [MAX_PARTY_LIMIT] members!"
				return
			if(m.party)
				if(src.leader) src.leader << "[m] already has a party and can't join yours!"
				return
			if(istype(m, /mob/Player/AI))
				if(src.leader) src.leader << "You can't add AI to your party!"
				return
			if(m==src.leader)
				src.finalize_join(m)                 // the leader joins their own party silently, no prompt
				return
			if(m.pending_party)
				if(src.leader) src.leader << "[m] is already weighing a party invite."
				return
			m.pending_party = src
			src.pending_invites |= m
			m.pending_invite_id += 1
			var/this_id = m.pending_invite_id
			m.client.ShowPartyInvite(src)            
			spawn(PARTY_INVITE_TIMEOUT)              // auto-expire the invite if it is ignored
				if(src && m && m.pending_party == src && m.pending_invite_id == this_id)
					src.expire_invite(m)
		finalize_join(var/mob/m)                     // commit the join once accepted (or for the leader)
			if(!m) return
			src.pending_invites -= m
			if(m.party && m.party != src)
				return
			if(src.members.len>=MAX_PARTY_LIMIT)
				if(src.leader) src.leader << "[m] can't join - the party already has [MAX_PARTY_LIMIT] members!"
				return
			if(m in members)
				return
			m.party=src
			m.pending_party = null
			src.members.Add(m)
			if(src.members.len>1)                    
				src.members << "[m] has joined the party!"
			src.highest_potential()
			src.refresh_ui()
		remove_member(var/mob/m)
			if(!(m in src.members))
				return
			src.members << "[m] has been removed from the party!"
			src.members.Remove(m)
			m.party = null
			m.pending_party = null
			if(m.client)
				m.client.RebuildPartyCards()         
			if(src.leader==m)
				if(src.members.len>0)
					src.leader=src.members[1]
					src.members << "[src.leader] has been selected as the new leader of the party!"
				else
					src.cancel_all_invites()         // disbanding
					del src
			if(src)
				src.highest_potential()
				src.refresh_ui()
		cancel_invite(var/mob/m)                     // drop one outstanding invite and close its prompt
			src.pending_invites -= m
			if(m && m.pending_party == src)
				m.pending_party = null
				if(m.client) m.client.HidePartyInvite()
		cancel_all_invites()
			for(var/mob/m in src.pending_invites.Copy())
				src.cancel_invite(m)
		expire_invite(var/mob/m)                     // timed-out invite: tell both sides, then cancel it
			if(!m) return
			m << "<font color=red>The party invite expired.</font>"
			if(src.leader) src.leader << "[m] didn't respond to your party invite in time."
			src.cancel_invite(m)
		refresh_ui()                                 // rebuild every member's ally-card stack after a roster/leader change
			for(var/mob/mm in src.members)
				if(mm.client)
					mm.client.RebuildPartyCards()

		highest_potential()
			var/highest=0
			for(var/mob/m in src.members)
				if(m.Potential>highest)
					highest=m.Potential
			src.highest_potential=highest
