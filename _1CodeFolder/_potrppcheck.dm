mob
	proc
		checkPot(mob/user)
			if(user.Potential < user.PotentialCap)
				return user.PotentialCap -user.Potential
			else return FALSE

		checkRPP(mob/user)
			var/rpp = user.RPPSpent + user.RPPSpendable

			if(rpp < user.RPPCurrent )
				return  user.RPPCurrent - rpp
			else return FALSE

		giveRPPnPot(mob/user)
			var/potential = checkPot(user)
			var/roleplaypoint = checkRPP(user)
			
			if(potential)
				user.Potential += potential
				usr << "You have been awarded [potential] potential, your new total is [user.Potential]"

			if(roleplaypoint)
				user.RPPSpendable += roleplaypoint
				usr << "You have been awarded [roleplaypoint] RPP, your new total is [user.RPPSpendable]"
			

