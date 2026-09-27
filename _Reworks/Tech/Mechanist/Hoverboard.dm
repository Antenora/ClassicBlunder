/obj/Items/Gear/Hoverboard
	name = "Hoverboard"
	TechType = "Military Engineering"
	SubType = "Military Engineering"
	icon = 'Skateboard.dmi'
	Techniques = list("/obj/Skills/Buffs/SlotlessBuffs/Gear/Hoverboard")
	desc = "A humming board that carries its rider faster than they can run. It drops out from under them the moment a fight starts."
	InfiniteUses = 1

/obj/Skills/Buffs/SlotlessBuffs/Gear/Hoverboard
	BuffName = "Hoverboard"
	ActiveMessage = "steps onto a humming Hoverboard!"
	OffMessage = "steps off their Hoverboard."

	verb/Hoverboard()
		set category = "Skills"
		src.Trigger(usr)

	Trigger(mob/User, Override = 0)
		if(User && !Override && !User.BuffOn(src) && User.InCombat())
			User << "You can't ride a Hoverboard in a fight."
			return 0
		. = ..()
		if(!User) return
		if(User.BuffOn(src))
			User.hover_buff = src
		else if(User.hover_buff == src)
			User.hover_buff = null

mob/var/tmp/obj/Skills/Buffs/hover_buff

mob/proc/HoverDrop()
	if(!hover_buff) return
	var/obj/Skills/Buffs/B = hover_buff
	hover_buff = null
	if(BuffOn(B))
		B.Trigger(src, Override = 1)

mob/MoveBudgetMult()
	. = ..()
	if(hover_buff && hover_buff.SlotlessOn)
		. *= HOVERBOARD_SPEED

mob/MarkCombat(mob/other)
	..()
	HoverDrop()
	if(other && other != src)
		other.HoverDrop()

/mob/Melee1(dmgmulti=1, spdmulti=1, iconoverlay, forcewarp, forcedTarget=null, ExtendoAttack=null, SecondStrike, ThirdStrike, AsuraStrike, accmulti=1, SureKB=0, NoKB=0, IgnoreCounter=0, BreakAttackRate=0, hitback = 0, WhipOnly = 0)
	HoverDrop()
	return ..()

mob/Players/UseProjectile(var/obj/Skills/Projectile/Z, noGCD = FALSE)
	HoverDrop()
	return ..()

mob/Players/Activate(var/obj/Skills/AutoHit/Z, ignoreCuck = FALSE, ignoreAttackLock = FALSE, noGCD = FALSE)
	HoverDrop()
	return ..()

mob/Players/SetQueue(var/obj/Skills/Queue/Q, noGCD = FALSE)
	HoverDrop()
	return ..()

/mob/Players/BeginHeldSkill(var/obj/Skills/Z)
	HoverDrop()
	return ..()
