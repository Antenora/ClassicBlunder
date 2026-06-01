			
Boundless_Waltz
			passives = list("DenkoSekka" = 1+user.AscensionsAcquired/2,  "TechniqueMastery" = 1+userAscensionAcquired*2)
	
			TextColor=rgb(230, 230, 100)
			Cooldown=60
			NeedsHealth = 25
            TooMuchHealth=51
			ActiveMessage="refuses to be tied down by anything as aether flows through them!"
			OffMessage="relents in their pursuit of eternal freedom..."
			adjust(mob/user)
		//Would gain Skimming at Asc3