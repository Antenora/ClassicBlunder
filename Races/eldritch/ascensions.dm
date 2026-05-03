/ascension/sub_ascension/eldritch/hunter//deeps
	passives = list("Duelist" = 1, "Brutalize" = 1, "CheapShot"=1)
/ascension/sub_ascension/eldritch/eternal//tank
	passives = list("Unnerve"=1, "Pressure" = 1, "Deflection" = 1);
/ascension/sub_ascension/eldritch/writhing
	passives = list("Extend" = 1, "Gum Gum" = 1, "GiantSwings"=1);

ascension
	eldritch
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			choices = list("Hunter" = /ascension/sub_ascension/eldritch/hunter, "Eternal" = /ascension/sub_ascension/eldritch/eternal, "Writhing" = /ascension/sub_ascension/eldritch/writhing)
			endurance = 0.25;
			defense = 0.25;
			speed = 0.25;
			anger = 0.2;
			on_ascension_message = "Your dreams are twisted by chaos... but what do you dream of?"
			passives = list("DebuffResistance"=0.2, "PureDamage"=1, "PureReduction"=1, "BuffMastery"=2, "BlockChance"=5, "CriticalChance"=5, "CriticalBlock"=0.1, "CriticalDamage"=0.1);
			onAscension(mob/owner)
				switch(owner.Secret)
					if("Eldritch (Shrouded)")
						passives["Unnerve"] = 1;
						passives["Harden"] = 1;
						passives["HardStyle"] = 1;
					if("Eldritch (Reflected)")
						passives["SoftStyle"] = 1;
						passives["QuickCast"] = 1;
						passives["Soulfire"] = 0.25;
				..()
				
			postAscension(mob/owner)
				owner.secretDatum.tierUp(1, owner)
				..()
		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			strength = 0.25;
			force = 0.25;
			offense = 0.25;
			speed = 0.25;
			anger = 0.2;
			passives = list("Null"=1, "DebuffResistance"=0.2, "PureDamage"=1, "PureReduction"=1, "BuffMastery"=2, "BlockChance"=5, "CriticalChance"=5, "CriticalBlock"=0.1, "CriticalDamage"=0.1);
			on_ascension_message = "You catch a distant glimpse of ᛉᛜꓦᚱᛢᛊᚳᚪ ᛫᛫᛫"
			onAscension(mob/owner)
				switch(owner.Secret)
					if("Eldritch (Shrouded)")
						passives["Unnerve"] = 1;
						passives["Harden"] = 1;
						passives["HardStyle"] = 1;
					if("Eldritch (Reflected)")
						passives["SoftStyle"] = 1;
						passives["QuickCast"] = 1;
						passives["Soulfire"] = 0.25;
				..()
				
			postAscension(mob/owner)
				owner.secretDatum.tierUp(1, owner)
				..()
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			choices = list("Hunter" = /ascension/sub_ascension/eldritch/hunter, "Eternal" = /ascension/sub_ascension/eldritch/eternal, "Writhing" = /ascension/sub_ascension/eldritch/writhing)
			strength = 0.25;
			endurance = 0.25;
			force = 0.25;
			offense = 0.25;
			defense = 0.25;
			speed = 0.25;
			anger = 0.2;
			passives = list("DebuffResistance"=0.2, "PureDamage"=1, "PureReduction"=1, "BuffMastery"=2, "BlockChance"=5, "CriticalChance"=5, "CriticalBlock"=0.1, "CriticalDamage"=0.1);
			on_ascension_message = "Your fantasies are bleeding entropy... But what fantasy do you chase?"
			onAscension(mob/owner)
				switch(owner.Secret)
					if("Eldritch (Shrouded)")
						passives["Unnerve"] = 1;
						passives["Harden"] = 1;
						passives["HardStyle"] = 1;
					if("Eldritch (Reflected)")
						passives["SoftStyle"] = 1;
						passives["QuickCast"] = 1;
						passives["Soulfire"] = 0.5;
				..()
				
			postAscension(mob/owner)
				owner.secretDatum.tierUp(1, owner)
				..()
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			strength = 0.25
			endurance = 0.5
			force = 0.25
			offense = 0.25
			defense = 0.5
			speed = 0.5
			anger = 0.2;
			passives = list("DebuffResistance"=0.2, "PureDamage"=1, "PureReduction"=1, "BuffMastery"=2, "BlockChance"=5, "CriticalChance"=5, "CriticalBlock"=0.1, "CriticalDamage"=0.1);
			on_ascension_message = "Your illusory ᛢᛊᚳᚪ is beginning to ᚪᚱᚣᛉ at the ᛊᚧᛩᛊᛢ.\nYou can't keep manifesting like this ᚪᛜᚱᛊꓦᛊᚱ...Can ᛉᛜꓦ?"
			onAscension(mob/owner)
				switch(owner.Secret)
					if("Eldritch (Shrouded)")
						passives["Unnerve"] = 1;
						passives["Harden"] = 1;
						passives["HardStyle"] = 1;
					if("Eldritch (Reflected)")
						passives["SoftStyle"] = 1;
						passives["QuickCast"] = 1;
						passives["Soulfire"] = 0.5;
				..()
				
			postAscension(mob/owner)
				owner.secretDatum.tierUp(1, owner)
				..()
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			strength = 0.5
			endurance = 0.25
			force = 0.5
			offense = 0.5
			defense = 0.25
			speed = 0.25
			anger = 0.2;
			choices = list("Hunter" = /ascension/sub_ascension/eldritch/hunter, "Eternal" = /ascension/sub_ascension/eldritch/eternal, "Writhing" = /ascension/sub_ascension/eldritch/writhing)
			passives = list("DebuffResistance"=0.2, "PureDamage"=1, "PureReduction"=1, "BuffMastery"=2, "BlockChance"=5, "CriticalChance"=5, "CriticalBlock"=0.1, "CriticalDamage"=0.1);
			on_ascension_message = "ꐞꉻ꒦ ꋬꋪꏂ."
			onAscension(mob/owner)
				switch(owner.Secret)
					if("Eldritch (Shrouded)")
						passives["Unnerve"] = 1;
						passives["Harden"] = 1;
						passives["HardStyle"] = 1;
					if("Eldritch (Reflected)")
						passives["SoftStyle"] = 1;
						passives["QuickCast"] = 1;
						passives["Soulfire"] = 1;
				..()
				
			postAscension(mob/owner)
				owner.secretDatum.tierUp(1, owner)
				..()
		six 
			unlock_potential = ASCENSION_SIX_POTENTIAL
			strength = 0.5
			endurance = 0.5
			force = 0.5
			offense = 0.5
			defense = 0.5
			speed = 0.5
			passives = list("DebuffReversal" = 1, "PureDamage"=5, "BlockChance"=25, "CriticalBlock"=0.25, "BuffMastery"=5, "Duelist"=2, "Brutalize"=2, "CheapShot"=2, "Unnerve"=2, "Pressure" = 2, "Deflection" = 2, "Extend" = 2, "Gum Gum" = 2, "GiantSwings"=2)
			on_ascension_message = {"ꐞꉻ꒦ ꋬꋪꏂ ꓄ꃬꏂ ꉣꋪꉻꍗ꒒ꏂꂵ.
ꐞꉻ꒦ ꋬꋪꏂ ꓄ꃬꏂ ꒐ꑄꑄ꒦ꏂ.
ꐞꉻ꒦ ꋬꋪꏂ ꄟꋪꏂꏂ.
꒐꓄ ꒐ꑄ ꄟꋬꋪ ꓄ꉻꉻ ꒒ꋬ꓄ꏂ."};
			onAscension(mob/owner)
				owner.AngerMax=3;
				switch(owner.Secret)
					if("Eldritch (Shrouded)")
						passives["Unnerve"] = 3;
					if("Eldritch (Reflected)")
						passives["Soulfire"] = 1.5;
				..()
				
			postAscension(mob/owner)
				owner.secretDatum.tierUp(1, owner)
				..()