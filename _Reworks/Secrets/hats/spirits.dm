/*

let x = demon, y = holy and z = legendary

choice x y z

any choice gives Force + str scaling with pot/tier
	maybe scaling manastat w/ increase
	martial magic
	decreased void chance
	hats have a tier system to them, so its dual scaling


x = hellpower, scaling spirit sword = to tier + pot, sword punching, omnislash but cursed wounds vfx + cursed wounds, ultimate = dividing driver

y = holy power + spirit power, scaling hyprid strike, sword punching, giant aoe that makes space jtiles that fatigue and eat energy of ppl in it + heal u, ultimate = similar to gold cloth power up

z = legendary power, considered a staff, spirit flow, +spiritdamage, special move = homing bombs that manasteal/soulfire, do more dmgf the more mana/battery a person is missing, ultimate = wood golem

notes: p sure arcane beast ai is not functional

tiers:
	1 = path + Gravity ( waterwalk+godspeed+likewater+fluidform )
	2 = element passive + special move
	3 = ?
	4 = hat takeover mode(?) + ultimate
		an install or like symbiote i assume
*/

// use secrets framework since it is tiered

SecretInfomation/Spirits_Of_The_World // when given make them make a choice, this choice will then pick these ones below
// place parent functions here
	givenSkills = list("/obj/Skills/Buffs/SlotlessBuffs/Spirits/Base_Hat_Buff") // TODO: change this typing if wanted
	proc/applyPassives(mob/p)
		return list("MartialMagic" = 1, "Gravity" = 1)
	proc/pickElement(mob/p)
		var/element = input(p, "Pick an attunement", "Elemental Attunement") in list("Pick an element", "Fire", "Water", "Earth", "Wind", "Lightning", "Poison")
		p.Attunement = element
	Goetic_Virtue
		applyPassives(mob/p)
			var/pot = p.Potential
			. = list("Hellpower" = currentTier/4, "SpiritSword" = 0.15 * currentTier + (pot/125), "SwordPunching" = 1, "MartialMagic" = 1, "Gravity" = 1)

		applySecret(mob/p)
			switch(currentTier)
				if(1)
					p << "You have awakened the power of Goetic Virtue!"
					giveSkills(p)
				if(2)
					p << "You have gained an elemental affinity"
					pickElement(p)
					p.AddSkill(new/obj/Skills/Queue/Goetic_Special)
					p<< "You have learned the special move: Goetic Special"
				if(4)
					p << "You have learned the ultimate move: Suffer In Hell With No Hoes"
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Hats/SufferInHellWithNoHoes)
	Stellar_Constellation
		applyPassives(mob/p)
			var/pot = p.Potential
			. = list("HolyMod" = currentTier, "SpiritPower" = 0.25 + (currentTier * 0.25 + (pot/250)), "HybridStrike" = currentTier/4 + pot/100, "SwordPunching" = 1, "MartialMagic" = 1, "Gravity" = 1)
		applySecret(mob/p)
			switch(currentTier)
				if(1)
					p << "You have awakened the power of Stellar Constellation!"
					giveSkills(p)
				if(2)
					p << "You have gained an elemental affinity"
					pickElement(p)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Hats/Liberation)
					p<< "You have learned the special move: Liberation"

				if(4)
					p << "You have learned the ultimate move: Herald of the Constellation"
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Hats/HeraldOfTheConstellation)


	Elven_Sanctuary
		applyPassives(mob/p)
			var/pot = p.Potential
			. = list("Mythical" = currentTier/4, "SpiritFlow" = 1, "SpiritualDamage" = currentTier*1.25 + pot/25, "MartialMagic" = 1, "Gravity" = 1)
		applySecret(mob/p)
			switch(currentTier)
				if(1)
					p << "You have awakened the power of Elven Sanctuary!"
					giveSkills(p)
				if(2)
					p << "You have gained an elemental affinity"
					pickElement(p)