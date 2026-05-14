/obj/Skills/Buffs/SlotlessBuffs/Autonomous/
	FaeBuffs //These are jsut concepts right now. Numbers will be adjusted by staff before implimented. Innovation currently does nothing for Fae but it will change how their spells work.
		NeedsHealth = 50
		TooMuchHealth = 75
		//TooLittleMana = 1
		TextColor=rgb(95, 60, 95)
		ActiveMessage="is consumed by magical vigor!"
		OffMessage = "Their mana-enhanced power fades..."
		adjust(mob/p)

		Fury_of_the_Small //Angry Short Person Syndrome
			//TooLittleMana = 1 doesn't turn on the CD.
			ActiveMessage = "channels the fury of short people!"
			OffMessage = "is no longer angry, but still short..."
			adjust(mob/p)
				if(altered) return
				var/asc = p.AscensionsAcquired
				NeedsHealth = 50 + (asc * 5)
				TooMuchHealth = clamp(75 + (asc * 5) ,75,100)
				spdAdd = 0.15 * asc
				passives = list("ManaStats" = (1+(asc/2)), "Innovation" = 1, "BlurringStrikes" = (0.5+(asc/4)), "Brutalize" = (0.5*(asc+1)),\
								"SpiritHand" = (2*(asc+1)), "SpiritSword" = (0.5*(asc+1)), "Afterimages" = 1)
			Trigger(mob/User, Override = FALSE)
				if(!User.BuffOn(src))
					adjust(User)
				..()

		Pixie_Mania // Manic Pixie Dream Girl
			//TooLittleMana = 1 Doesn't turn on the CD
			ActiveMessage = "becomes consumed by a fit of manic laughter!"
			OffMessage = "regains their sanity..."
			adjust(mob/p)
				if(altered) return
				var/asc = p.AscensionsAcquired
				NeedsHealth = 50 + (asc * 5)
				TooMuchHealth = clamp(75 + (asc * 5) ,75,100)
				forAdd = 0.15 * asc
				passives = list("ManaStats" = (1+(asc/2)), "Innovation" = 1, "DebuffResistance" = (0.1*(asc+1)), "Blubber" = (0.5*(asc+1)),\
								"FluidForm" = (1+(0.5*asc)), "Afterimages" = 1) //Pixies are supposed to be annoying to put down once they go into Mania.
			Trigger(mob/User, Override = FALSE)
				if(!User.BuffOn(src))
					adjust(User)
				..()

//Insert Fae-Specific spells here. These should all cost Mana.
//Hideous Laughter: circle-AoE that does little-to-no damage, brief stun from laughing, then applies a debuff. Pixies
//Pack Tactics: Party-wide buff to hitting and dodging. Goblin. Maybe make Goblins have a stronger effect from it. Together... Goblin...strong.