sagaTierUpMessages/Rebirth
	messages = list("You embark on the path of a Hero... but which Hero you become remains to be seen. Will you simply choose to be the strongest or defy everything for victory?", \
	"Now you can choose: Are you the hero spoken of in legend, or are you one who has not yet written their story?", \
	"Your legend shifts ever-closer to completion. Your name is starting to be recognized.", \
	"You are experiencing the first glimmers of Seventh Sense- wait this isn't the Saint Seiya Saga.", \
	"You reach the level of a Golden Saint, standing at the summit as a champion of Gods!", \
	"Your Cosmos burns with the power of a god!", \
	)


/mob/tierUpSaga(path)
	..()
/*	if(path == "Rebirth")
		src<<allSagaMessages[path].messages[SagaLevel]
		switch(SagaLevel)
			if(2)
				var/list/Choices=list("Prophesized Hero", "Unsung Hero")
				var/choice
				var/confirm
				while(confirm!="Yes")
					choice=input(src, "Are you the hero spoken of in legends? Or has your story yet to be written?", "Hero Path") in Choices
					switch(choice)
						if("Unsung Hero")
							confirm=alert(src, "You remain the hero nobody knows, but one day, your name will be its own legend.", "The Unsung Hero, a story yet to be written.", "Yes", "No")
						if("Prophesized Hero")
							confirm=alert(src, "A story told in glass, a tragedy written into time and space.", "The Hero of Prophecy, chosen by fate.", "Yes", "No")
				src.SagaLevel=2
				src<<"Unwavering courage wells up within you! You have unlocked the ACT meter!"
				switch(choice)
					if("Unsung Hero")
						src.RebirthHeroPath="Unsung"
						if(src.RebirthHeroType=="Blue")
							src.AddSkill(new/obj/Skills/Queue/NeverKnowsBest)
							src.AddSkill(new/obj/Skills/Projectile/Rude_Buster)
						if(src.RebirthHeroType=="Red")
							src.AddSkill(new/obj/Skills/Utility/NeverTooLate)
							src.passive_handler.Increase("Determination")
							src.passive_handler.Increase("Determination(Red)")
							src<< "Your ACT meter slows, but as it builds, a certain power wells up within you..."
							src<< "You unlock the Red SOUL color, boosting your crit rate as you gain ACT!"
							src.AddSkill(new/obj/Skills/AutoHit/Scream_of_Fury)
						if(src.RebirthHeroType=="Rainbow")
							src.AddSkill(new/obj/Skills/AutoHit/NeverSeeItComing)
							src.AddSkill(new/obj/Skills/Projectile/Beams/TasteTheRainbow)
							src<< "nyoro~n :3c"
						src.AddSkill(new/obj/Skills/Utility/NeverTooEarly)
					if("Prophesized Hero")
						src.RebirthHeroPath="Prophesized"
						if(src.RebirthHeroType=="Blue")
							src.RebirthHeroType="Cyan"
							src<< "You are now the Cyan Hero of Soul, a cage for a human SOUL. Your ACT meter slows, but as it builds, a certain power wells up within you..."
							src.passive_handler.Increase("Determination")
							src.AddSkill(new/obj/Skills/Utility/SoulShift)
							src<<"You unlock the Red SOUL color, boosting your crit rate as you gain ACT!"
							src<<"You unlock the Yellow SOUL color, granting your melee attacks projectiles!!"
							src.AddSkill(new/obj/Skills/Buffs/Rebirth/Spookysword)
						if(src.RebirthHeroType=="Red")
							src.RebirthHeroType="Purple"
							src<< "You are now the Purple Hero of Hope, who attacks with dark energy."
							src<< "You gain the Rude Buster ability, a homing blast that requires 50% ACT and cannot miss. You also gain Red Buster, a stronger version of Rude Buster that can only be used if you have a Cyan Hero of Soul in your party."
							src.AddSkill(new/obj/Skills/Projectile/Rude_Buster)
							src.AddSkill(new/obj/Skills/Projectile/Red_Buster)
							src.AddSkill(new/obj/Skills/Buffs/Rebirth/Devilsknife)
							src.AddSkill(new/obj/Skills/Utility/UltimateHeal)
							src<<"You can also attempt to heal people, but the keyword is attempt."
						if(src.RebirthHeroType=="Rainbow")
							src.RebirthHeroPath="Unsung"
							src<<"Sorry, there is no way in hell that fate could ever account for you. Nice try, though."
							src.AddSkill(new/obj/Skills/AutoHit/NeverSeeItComing)
							src<< "nyoro~n :3c"
							src.AddSkill(new/obj/Skills/Utility/NeverTooEarly)
							src.AddSkill(new/obj/Skills/Projectile/Beams/TasteTheRainbow)
							src.AddSkill(new/obj/Skills/Utility/HoldingOutForAHero)
					/*		src.RebirthHeroType="Yellow"
							src<< "You are now the Yellow Hero of Connection, who can attack with Ice Magic.."
							src.AddSkill(new/obj/Skills/Projectile/Rude_Buster)
							src.AddSkill(new/obj/Skills/Buffs/Rebirth/Devilsknife)
							src<< "..but you could still choose to become the Yellow Hero of Tragedy. After all, this wasn't supposed to be your story."
							src.AddSkill(new/obj/Skills/Buffs/Rebirth/ThornRing)
							src.AddSkill(new/obj/Skills/AutoHit/Snowgrave)*/
			if(3)
				src.SagaLevel=3
				if(src.RebirthHeroType=="Cyan")
					src<< "You have unlocked the green SOUL color, which reduces the damage you take as you build ACT. You also gain the BlackShard, a small weapon that can hardly be considered one, but carries great power..."
					src.AddSkill(new/obj/Skills/Utility/SoulShiftGreen)
					src.AddSkill(new/obj/Skills/Buffs/Rebirth/BlackShard)
					src.AddSkill(new/obj/Skills/AutoHit/Unleash)
				if(src.RebirthHeroType=="Purple")
					src<< "Your story has finally come into its own. You have become the Axe of Justice, with hope crossed on your heart."
					src.AddSkill(new/obj/Skills/Buffs/Rebirth/JusticeAxe)
					src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Axe_of_Justice)
				if(src.RebirthHeroType=="Blue")
					src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Shining_Star)
					src.AddSkill(new/obj/Skills/Utility/TheBlueExperience)
				if(src.RebirthHeroType=="Red")
					src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Unwavering_Soul)
					src.AddSkill(new/obj/Skills/Queue/FistOfTheRedStar)
					src.AddSkill(new/obj/Skills/Projectile/Beams/Unbelievable_Rage)

				if(src.RebirthHeroType=="Rainbow")
					src.AddSkill(new/obj/Skills/AutoHit/PowerWordGenderDysphoria)
					src.AddSkill(new/obj/Skills/Grapple/CHAOS_DUNK)
					src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Hero_Of_Chaos)
			if(4)
				src.SagaLevel=4
				if(src.RebirthHeroType=="Cyan")
					src<<"The special power you wield grows stronger, heightening the strength of your SOUL colors."
					src<<"You have gained the BlackShard, a small yet incredibly powerful weapon that renders it difficult to hit in exchange for being among the ultimate weapons against darkness."
					src<<"You have gained Banish."
					src.AddSkill(new/obj/Skills/Buffs/Rebirth/BlackShard)
					src.AddSkill(new/obj/Skills/AutoHit/Banish)
				if(src.RebirthHeroType=="Purple")
					src<<"<font color='#9BFD4D'><b>I see a story hidden in your eyes.</font></b>" //i literally extracted the mod files for gerson's rude buster to make sure this color was as accurate as possible. praise me.
					src<<"<font color='#9BFD4D'><b>Burnin' bright...</font></b>"
					src.passive_handler.Increase("HolyMod" = 3)
					src.AddSkill(new/obj/Skills/Projectile/Burning_Black)
					src<<"<font color='#9BFD4D'><b>Burnin' black...</font></b>"
					src.AddSkill(new/obj/Skills/AutoHit/Burning_Up_Everything)
					src<<"<font color='#9BFD4D'><b>Burnin' up everything.</font></b>"
				if(src.RebirthHeroType=="Rainbow")
					src<<"Surprise! You're a woman now. RP accordingly."
					if(src.Gender=="Female")
						src<<"Oh, wait, you were before? Well, surprise! You're transfem now and have been all along. Good job on the voice training."
					if(src.Gender=="Neuter")
						src<<"Oh, you didn't have a gender before now? Well, congrats! Now you do! Now go burn down a forest over it."
					src.Gender="Female"
					src.AddSkill(new/obj/Skills/Projectile/Zone_Attacks/Final_Chaos)
				if(src.RebirthHeroType=="Blue")
					src.AddSkill(new/obj/Skills/AutoHit/MakeItCount)
				if(src.RebirthHeroType=="Red")
					src.AddSkill(new/obj/Skills/Utility/Burning_Soul)
			if(5)
			if(6)*/