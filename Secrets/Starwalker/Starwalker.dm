obj/Skills/Buffs/SlotlessBuffs/Starwalker
	Starwalker
		IconTransform = 'Starwalker.dmi'
		ActiveMessage="will also <font color='FFF200'>join</font color>"
		OffMessage="will no longer <font color='FFF200'>join</font color>"
		verb/The_Original_Starwalker()
			set name="Star                    walker"
			set category="Starwalker"
			if(usr.Target && usr.Target.party && usr.Target.party.members.len < MAX_PARTY_LIMIT)
				if(usr.party)
					usr.party.remove_member(usr)
				usr.Target.party.finalize_join(usr)   
			src.Trigger(usr)