Righteous_Fury
			
			passives = list("AngerMult" = 1+user.AscensionsAcquired/2, "MeatyPaws" = 1+userAscensionAcquired, "GiantForm"= 1)
			TextColor=rgb(230, 230, 100)
			Cooldown=60
			NeedsHealth = 25
            TooMuchHealth=51
			ActiveMessage="becomes fueled by aetheric fury, growing in size and ferocity!"
			OffMessage="lets the aether driven fury die down..."
			adjust(mob/user)
			//Would gain Adrenaline at Asc3