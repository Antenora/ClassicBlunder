/obj/Items/Sword/Light/Nox
	LegendaryItem = 1
	Ascended = 5
	Destructable = 0
	Unobtainable = 1

/obj/Items/Sword/Light/Nox/Ouroboros
	name = "Geminus Anguium: Ouroboros"
	desc = {"The Snake Pair: Ouroboros (蛇双・ウロボロス Jasō: Uroborosu, localized as Geminus Anguium: Ouroboros) is an Arch-Enemy Event Weapon in the shape of a black snake head attached to a never-ending chain.
Ouroboros is summoned from a special space, and can directly attack the soul or mind of the target."}
	passives = list("SwordPunching" = 1, "Extend" = 1, "Grippy" = 3, "CalmAnger" = 1, "AngerThreshold" = 1.5, "RenameMana" = "HEAT")
	NoSaga=1
	CalmAnger=1
	MagicSword=1
	icon = 'ouroboros (1).dmi'
	pixel_x = -32
	pixel_y = -32
	// Element="Void"
	// void offense would have 2 do something
	Techniques=list("/obj/Skills/Utility/Ouroboros", "/obj/Skills/AutoHit/Ouroboros/Devouring_Fang", "/obj/Skills/AutoHit/Ouroboros/Rising_Fang", "/obj/Skills/AutoHit/Ouroboros/Falling_Fang", \
					"/obj/Skills/Projectile/Ouroboros/Hungry_Coils", "/obj/Skills/Ouroboros/Serpents_Redemption", "/obj/Skills/Ouroboros/Serpents_Pull", "/obj/Skills/Buffs/SlotlessBuffs/Ouroboros/Serpents_Haste", \
					 "/obj/Skills/AutoHit/Ouroboros/Snake_Bite", "/obj/Skills/Buffs/SlotlessBuffs/Ouroboros/Venomous_Bite", \
					"/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Nox/The_Unholy_Wrath_of_the_Basilisk", "/obj/Skills/Buffs/SlotlessBuffs/Grimoire/OverDrive/Jormungandr")


/*
we have an ouroboros skill that is needed to be activated in order to use other moves
each move it calls out to  has its own seperate cooldown

idea: if you use x y z in order you cast a, which consumes mana
ech move's dammage and etc scales with potential
crisis buff probably, might as well fuck it right ?

each ouro skill is like 30-45 cd

grab skillshot proj will snare the enemy
make a skill that reqs them to be snared in order to use
thsi way we can make it seem like a 'reactionary' skill activation, but its only really looking for them to be in that state annd not technically hit by that move specifically


the utility skill holds if it is in use as well as the last used, and the last input
when the last three inputs are a combo is will result in a super (?)


*/
// DEBUG //

/mob/Admin4/verb/giveOuroboros()
	src.contents += new/obj/Items/Sword/Light/Nox/Ouroboros
	AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Nox/The_Unholy_Wrath_of_the_Basilisk)


/obj/orohud
	icon = 'orohud.dmi'
	screen_loc = "1:1,1:128"