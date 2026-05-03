#define NIGHTMARE_FORM_DEFAULT 'Icons/Eldritch/EldritchNightmareForm.dmi'
#define NIGHTMARE_FORM_DEFAULT_X -48
#define NIGHTMARE_FORM_DEFAULT_Y -48


race
	eldritch
		name = "Eldritch"
		desc = "Distant thoughts, either a dream or a nightmare, made manifest within the soul of a living being. They are chaotic and unstable, only able to imitate mortal life and individuality."
		visual = 'Eldritch.png'

		passives = list("Void" = 1, "DebuffResistance"=0.2, "PureDamage"=1, "PureReduction"=1, "BuffMastery"=5, "Obfuscated Origin" = 1, "Fishman"=1)
		locked = TRUE

		power = 3.5
		strength = 1.5
		endurance = 2
		speed = 2
		force = 1.5
		offense = 2
		defense = 2
		regeneration = 3
		recovery = 2;
		intellect = 2
		imagination = 1
		anger = 1
		skills = list(/obj/Skills/Utility/Telepathy, /obj/Skills/Teleport/Traverse_Depths,/obj/Skills/Buffs/SpecialBuffs/FadeIntoShadows, /obj/Skills/Buffs/SlotlessBuffs/Regeneration)

		onFinalization(mob/user)
			..()
			var/obj/Skills/Buffs/regen = user.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Regeneration);
			regen.RegenerateLimbs=1;
			var/eldType = alert(user, "Is your true eldritch nature Reflected from the Greater Depths, or are you Shrouded in the haze of the Sea of Darkness?", "Eldritch Type", "Reflected", "Shrouded");
			user.Secret="Eldritch ([eldType])"
			user.giveSecret("Eldritch[eldType]")
			user.secretDatum.nextTierUp = 999
			if(eldType == "Shrouded") user.AngerMax=1.5;
			if(eldType == "Reflected")
				user.passive_handler.Increase("MovingCharge", 1);
				user.AddSkill(new /obj/Skills/Utility/Offer_Pact);
				user.AddSkill(new /obj/Skills/Utility/Revoke_Pact);