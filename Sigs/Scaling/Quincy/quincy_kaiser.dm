#define QUINCY_ALMIGHTY_TICK 10
#define QUINCY_ALMIGHTY_KNOWN_TIMEOUT 300
#define QUINCY_ALMIGHTY_REWRITE_COOLDOWN 3000
#define QUINCY_ALMIGHTY_REWRITE_PCT 10
#define QUINCY_ALMIGHTY_STRIP_TIME 600
#define QUINCY_ADAPT_BASE 0.25
#define QUINCY_ADAPT_STEP 0.1
#define QUINCY_ADAPT_MAX 0.75
#define QUINCY_ANHABEN_LEVEL 7
#define QUINCY_ANHABEN_SHIELD 50
#define QUINCY_ANHABEN_SECONDS 10
#define QUINCY_ANHABEN_DRAIN 5
#define QUINCY_SURGE_MULT 1.2
#define QUINCY_ALMIGHTY_NEGATE_CD 100
#define QUINCY_ALMIGHTY_BUFF_CD 300
#define QUINCY_ALMIGHTY_BUFF_FLOOR 1
#define QUINCY_ALMIGHTY_CLICK_PAD 4
#define QUINCY_ALMIGHTY_WINDUP_WATCH 300

/strike/var/obj/Skills/skill

mob/var/tmp/AlmightyStrippedUntil = 0
mob/var/tmp/AlmightyRewriteAt = 0
mob/var/tmp/list/AlmightyKnown
mob/var/tmp/AlmightyKnownAt = 0
mob/var/tmp/AlmightySightGen = 0
mob/var/tmp/list/AlmightyMarks
mob/var/tmp/list/AlmightyHits
mob/var/tmp/AlmightyNegateAt = 0
mob/var/tmp/AlmightyWindupNegated = 0

/proc/QuincySeatHolder()
	if(!islist(glob.QuincyKaiser) || !glob.QuincyKaiser.len)
		return null
	return glob.QuincyKaiser[1]

/proc/QuincySeatName()
	if(!islist(glob.QuincyKaiser) || glob.QuincyKaiser.len < 2)
		return "the Kaiser"
	return "[glob.QuincyKaiser[2]] ([glob.QuincyKaiser[1]])"

/proc/QuincyOnlineByKey(k)
	if(!k)
		return null
	for(var/mob/Players/P in players)
		if(P.key == k || P.ckey == k)
			return P
	return null

/proc/QuincySeatOnline()
	return QuincyOnlineByKey(QuincySeatHolder())

/mob/proc/QuincyHoldsSeat()
	var/k = QuincySeatHolder()
	return k && (k == src.key || k == src.ckey)

/mob/proc/QuincyIsKaiser()
	return src.QuincyRank == "Kaiser" && QuincyHoldsSeat()

/mob/proc/QuincyTakeSeat()
	src.QuincyRank = "Kaiser"
	glob.QuincyKaiser = list(src.key, "[src.name]", world.realtime)
	QuincySyncSkills()

/mob/proc/QuincyLeaveSeat(msg)
	if(src.QuincyRank == "Kaiser")
		src.QuincyRank = null
	QuincySyncSkills()
	if(msg)
		src << "<font color=yellow>[msg]</font>"

/proc/QuincyEchtOnline(mob/except)
	var/list/out = list()
	for(var/mob/Players/P in players)
		if(P == except || !P.ckey)
			continue
		if(P.QuincyIsQuincy() && P.QuincyHeritage == "Echt")
			out += P
	return out

/proc/QuincyPickEcht(mob/asker, title, question, mob/except)
	var/list/pool = QuincyEchtOnline(except)
	if(!pool.len)
		asker << "<font color=red>No Echt Quincy are online.</font>"
		return null
	var/list/lab = PromptLabelAtoms(pool, 1)
	var/pick = Ask(asker, question, title, null, "pick", lab, 1)
	if(isnull(pick))
		return null
	return lab[pick]

/mob/Admin4/verb/Seat_Kaiser()
	set category = "Admin"
	set name = "Seat Kaiser"
	if(QuincySeatHolder())
		usr << "<font color=red>[QuincySeatName()] already sits the throne. Use Move Kaiser or Unseat Kaiser.</font>"
		return
	var/mob/Players/P = QuincyPickEcht(usr, "Seat Kaiser", "Who sits the throne of the Quincy?", null)
	if(!P || QuincySeatHolder() || !P.QuincyIsQuincy() || P.QuincyHeritage != "Echt")
		return
	P.QuincyTakeSeat()
	world << "<font color=#9fd8ff><b>[P] sits the throne of the Quincy. The Almighty opens its eyes.</b></font>"
	Log("Admin", "[ExtractInfo(usr)] seated [ExtractInfo(P)] as the Quincy Kaiser.", 1)

/mob/Admin4/verb/Move_Kaiser()
	set category = "Admin"
	set name = "Move Kaiser"
	if(!QuincySeatHolder())
		usr << "<font color=red>The throne is empty. Use Seat Kaiser.</font>"
		return
	var/mob/Players/P = QuincyPickEcht(usr, "Move Kaiser", "Who takes the throne from [QuincySeatName()]?", QuincySeatOnline())
	if(!P || !P.QuincyIsQuincy() || P.QuincyHeritage != "Echt" || P.QuincyHoldsSeat())
		return
	var/was = QuincySeatName()
	var/mob/Players/old = QuincySeatOnline()
	glob.QuincyKaiser = list()
	if(old)
		old.QuincyLeaveSeat("The throne of the Quincy has passed from you.")
	P.QuincyTakeSeat()
	world << "<font color=#9fd8ff><b>The throne of the Quincy passes to [P]. The Almighty opens its eyes.</b></font>"
	Log("Admin", "[ExtractInfo(usr)] moved the Quincy Kaiser seat from [was] to [ExtractInfo(P)].", 1)

/mob/Admin4/verb/Unseat_Kaiser()
	set category = "Admin"
	set name = "Unseat Kaiser"
	if(!QuincySeatHolder())
		usr << "<font color=red>The throne is already empty.</font>"
		return
	var/who = QuincySeatName()
	var/confirm = Ask(usr, "Unseat [who]? The Almighty leaves with the throne.", "Unseat Kaiser", null, "confirm", null, 1, "Unseat", "Cancel")
	if(confirm != "Unseat" || !QuincySeatHolder())
		return
	var/mob/Players/old = QuincySeatOnline()
	glob.QuincyKaiser = list()
	if(old)
		old.QuincyLeaveSeat("You no longer sit the throne of the Quincy.")
	usr << "<font color=yellow>[who] is unseated.</font>"
	Log("Admin", "[ExtractInfo(usr)] unseated [who] as the Quincy Kaiser.", 1)

/obj/Skills/Buffs/SlotlessBuffs/The_Almighty
	name = "The Almighty"
	BuffName = "The Almighty"
	Slotless = 1
	Copyable = 0
	passives = list("GodKi" = 1, "CriticalDamage" = 0.15)
	OffMessage = "seals their Almighty eyes."
	var/mark_icon = 'Icons/Effects/SparkleArcane.dmi'
	var/mark_layer = FLY_LAYER
	var/mark_text_x = -48
	var/mark_text_y = 34
	var/mark_text_w = 128
	var/mark_text_h = 16
	var/mark_text_color = "#ffd23a"
	var/mark_buff_color = "#7fe0ff"
	var/mark_text_step = 14
	var/mark_buff_max = 5
	var/mark_char_w = 7

	adjust(mob/p)
		CustomActive = "[p]'s eyes split. They see everything."

	Trigger(mob/User, Override = 0)
		var/wasOn = src.SlotlessOn
		. = ..()
		if(!wasOn && src.SlotlessOn)
			User.AlmightySightLoop(src)
		else if(wasOn && !src.SlotlessOn)
			User.AlmightySightStop()

	verb/The_Almighty()
		set name = "The Almighty"
		set category = "Skills"
		if(src.SlotlessOn)
			src.Trigger(usr)
			return
		if(!usr.QuincyIsKaiser())
			usr << "Only the Kaiser holds The Almighty."
			return
		if(usr.AlmightyStrippedUntil > world.time)
			usr << "The Still Silver clots in your blood. The Almighty stays dark for [round((usr.AlmightyStrippedUntil - world.time) / 10)] more seconds."
			return
		src.Trigger(usr)

/mob/proc/AlmightyOnNow()
	if(!src.SlotlessBuffs)
		return 0
	var/obj/Skills/Buffs/B = src.SlotlessBuffs["The Almighty"]
	return istype(B, /obj/Skills/Buffs/SlotlessBuffs/The_Almighty) && B.SlotlessOn

/mob/proc/AlmightySightLoop(obj/Skills/Buffs/SlotlessBuffs/The_Almighty/A)
	set waitfor = 0
	var/gen = ++src.AlmightySightGen
	while(src && A && A.SlotlessOn && src.AlmightySightGen == gen)
		AlmightySightTick(A)
		sleep(QUINCY_ALMIGHTY_TICK)
	if(src && src.AlmightySightGen == gen)
		AlmightySightClear()

/mob/proc/AlmightySightStop()
	src.AlmightySightGen++
	AlmightySightClear()

/mob/proc/AlmightySightClear()
	src.AlmightyHits = null
	if(!src.AlmightyMarks)
		return
	if(src.client)
		src.client.images -= src.AlmightyMarks
	src.AlmightyMarks = null

/mob/proc/AlmightyThreat(mob/m)
	if(m.held_skill)
		return list("held", m.held_skill, "[m.held_skill.name]")
	if(m.AttackQueue)
		return list("queue", m.AttackQueue, "[m.AttackQueue.name]")
	if(m.WindingUp)
		if(m.AutoHitting && ispath(m.last_autohit_used, /obj/Skills))
			var/obj/Skills/S = m.last_autohit_used
			return list("windup", m.last_autohit_used, "[initial(S.name)]")
		return list("windup", null, "Windup")
	if(m.Beaming == 1)
		for(var/obj/Skills/Projectile/p in m)
			if(p.Charging)
				return list("beam", p, "[p.name]")
	return null

/mob/proc/AlmightyThreatName(mob/m)
	var/list/t = AlmightyThreat(m)
	return t ? t[3] : null

/mob/proc/AlmightyTimedBuffs()
	var/list/pool = list()
	if(src.ActiveBuff)
		pool |= src.ActiveBuff
	if(src.SpecialBuff)
		pool |= src.SpecialBuff
	if(src.SlotlessBuffs)
		for(var/k in src.SlotlessBuffs)
			var/obj/Skills/Buffs/B = src.SlotlessBuffs[k]
			if(B)
				pool |= B
	var/list/out = list()
	for(var/obj/Skills/Buffs/B in pool)
		if(B.TimerLimit <= 0 || !BuffOn(B))
			continue
		if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff))
			continue
		out += B
	return out

/mob/proc/AlmightySightTargets()
	var/list/out = list()
	for(var/mob/m in view(src.client ? src.client.view : world.view, src))
		if(m == src || !QuincyAreaFoe(m, src))
			continue
		var/label = AlmightyThreatName(m)
		if(label)
			out[m] = label
	return out

/mob/proc/AlmightySightScan(obj/Skills/Buffs/SlotlessBuffs/The_Almighty/A)
	var/list/hits = list()
	for(var/mob/m in view(src.client ? src.client.view : world.view, src))
		if(m == src || !QuincyAreaFoe(m, src))
			continue
		var/slot = 0
		var/list/t = AlmightyThreat(m)
		if(t)
			hits += list(list(m, t[1], t[2], slot, t[3]))
			slot++
		var/shown = 0
		for(var/obj/Skills/Buffs/B in m.AlmightyTimedBuffs())
			if(A && shown >= A.mark_buff_max)
				break
			hits += list(list(m, "buff", B, slot, "[B.name]"))
			slot++
			shown++
	return hits

/mob/proc/AlmightySightTick(obj/Skills/Buffs/SlotlessBuffs/The_Almighty/A)
	AlmightySightClear()
	if(!src.client || !A)
		return
	var/list/hits = AlmightySightScan(A)
	var/list/marks = list()
	var/list/sparked = list()
	for(var/list/h in hits)
		var/mob/m = h[1]
		var/first = !(m in sparked)
		if(first)
			sparked += m
		var/color = h[2] == "buff" ? A.mark_buff_color : A.mark_text_color
		marks += AlmightyMark(A, m, h[5], h[4], color, first)
		if(h[2] != "buff")
			var/mob/t = m.Target
			if(ismob(t) && t.z == m.z)
				var/turf/T = get_turf(t)
				if(T)
					marks += AlmightyMark(A, T, null)
	src.AlmightyHits = hits
	if(marks.len)
		src.AlmightyMarks = marks
		src.client.images += marks

/mob/proc/AlmightyMark(obj/Skills/Buffs/SlotlessBuffs/The_Almighty/A, atom/at, label, slot = 0, color = null, sparkle = 1)
	var/image/I = image(sparkle ? A.mark_icon : null, at, null, A.mark_layer)
	if(label)
		I.maptext = "<span style='text-align:center;color:[color ? color : A.mark_text_color]'>[label]</span>"
		I.maptext_width = A.mark_text_w
		I.maptext_height = A.mark_text_h
		I.maptext_x = A.mark_text_x
		I.maptext_y = A.mark_text_y + slot * A.mark_text_step
	return I

/mob/proc/AlmightyHitAt(list/h, wx, wy)
	var/obj/Skills/Buffs/SlotlessBuffs/The_Almighty/A = src.SlotlessBuffs ? src.SlotlessBuffs["The Almighty"] : null
	var/mob/m = h[1]
	if(!A || !ismob(m) || m.z != src.z)
		return 0
	var/ox = (m.x - 1) * 32 + m.step_x + m.pixel_x
	var/oy = (m.y - 1) * 32 + m.step_y + m.pixel_y
	var/half = min(A.mark_text_w, length("[h[5]]") * A.mark_char_w + 8) / 2
	var/cx = ox + A.mark_text_x + A.mark_text_w / 2
	var/by = oy + A.mark_text_y + h[4] * A.mark_text_step
	if(wx < cx - half - QUINCY_ALMIGHTY_CLICK_PAD || wx > cx + half + QUINCY_ALMIGHTY_CLICK_PAD)
		return 0
	if(wy < by - QUINCY_ALMIGHTY_CLICK_PAD || wy > by + A.mark_text_h + QUINCY_ALMIGHTY_CLICK_PAD)
		return 0
	return 1

/mob/proc/AlmightyHitFind(atom/object, params)
	if(!src.AlmightyHits || src.KO || !AlmightyOnNow())
		return null
	var/list/p = params2list(params)
	if(p["right"] || p["middle"] || p["ctrl"] || p["alt"] || p["shift"])
		return null
	var/list/w = QuincyClickPoint(object, p)
	if(!w)
		return null
	for(var/list/h in src.AlmightyHits)
		if(AlmightyHitAt(h, w[1], w[2]))
			return h
	return null

/mob/proc/AlmightyClick(atom/object, atom/location, params)
	var/list/h = AlmightyHitFind(object, params)
	if(!h)
		return 0
	AlmightyNegate(h[1], h[2], h[3], h[5])
	return 1

/proc/AlmightyRecool(mob/m, obj/Skills/S, fallback = 0)
	if(!S || S.MaxCharges > 0)
		return
	S.Using = 0
	S.cooldown_remaining = 0
	S.cooldown_start_wt = 0
	var/none_at = fallback > 0 ? QUINCY_ALMIGHTY_BUFF_FLOOR : 0
	if(S.Cooldown > none_at || S.Cooldown == -1)
		S.Cooldown(1, null, m)
	else if(fallback > 0)
		S.Cooldown(1, fallback, m)

/mob/proc/AlmightyWindupWatch()
	set waitfor = 0
	var/until = world.time + QUINCY_ALMIGHTY_WINDUP_WATCH
	while(src && src.WindingUp && world.time < until)
		sleep(1)
	if(src)
		src.AlmightyWindupNegated = 0

/mob/proc/AlmightyNegateDo(mob/m, kind, S)
	switch(kind)
		if("held")
			if(m.held_skill != S)
				return 0
			m.FizzleHeldSkill(S)
			return 1
		if("queue")
			var/obj/Skills/Queue/Q = S
			if(!istype(Q) || m.AttackQueue != Q)
				return 0
			Q.RanOut = 1
			Q.Hit = 0
			Q.Missed = 0
			m.ClearQueue()
			m << "<font color=#ff0000>You drop [Q.name]!</font>"
			AlmightyRecool(m, Q)
			return 1
		if("windup")
			if(!ispath(S) || !m.WindingUp || !m.AutoHitting || m.last_autohit_used != S)
				return 0
			m.AlmightyWindupNegated = 1
			m.AlmightyWindupWatch()
			var/obj/Skills/Z = locate(S) in m
			if(Z)
				AlmightyRecool(m, Z)
			return 1
		if("beam")
			var/obj/Skills/Projectile/P = S
			if(m.Beaming != 1 || !istype(P) || !P.Charging)
				return 0
			m.ForceCancelBeam()
			AlmightyRecool(m, P)
			return 1
		if("buff")
			var/obj/Skills/Buffs/B = S
			if(!istype(B) || !m.BuffOn(B))
				return 0
			B.Trigger(m, 1)
			if(m.BuffOn(B))
				return 0
			AlmightyRecool(m, B, QUINCY_ALMIGHTY_BUFF_CD)
			return 1
	return 0

/mob/proc/AlmightyNegate(mob/m, kind, S, label)
	if(!ismob(m) || !AlmightyOnNow())
		return 0
	var/left = src.AlmightyNegateAt + QUINCY_ALMIGHTY_NEGATE_CD - world.time
	if(src.AlmightyNegateAt && left > 0)
		src << "The Almighty can rewrite the future again in [round(left / 10) + 1] seconds."
		return 0
	if(!QuincyAreaFoe(m, src) || m.z != src.z)
		return 0
	if(!AlmightyNegateDo(m, kind, S))
		src << "That future has already passed."
		return 0
	src.AlmightyNegateAt = world.time
	OMsg(src, "[src] rewrites the future. [m]'s [label] never happens.")
	var/obj/Skills/Buffs/SlotlessBuffs/The_Almighty/A = src.SlotlessBuffs ? src.SlotlessBuffs["The Almighty"] : null
	if(A)
		AlmightySightTick(A)
	return 1

/mob/proc/AlmightyExpire()
	if(src.AlmightyKnown && src.AlmightyKnownAt + QUINCY_ALMIGHTY_KNOWN_TIMEOUT < world.time)
		src.AlmightyKnown = null

/mob/proc/AlmightyLearn(t)
	if(!t)
		return
	AlmightyExpire()
	if(!src.AlmightyKnown)
		src.AlmightyKnown = list()
	if(!(t in src.AlmightyKnown))
		src.AlmightyKnown += t
	src.AlmightyKnownAt = world.time

/mob/proc/QuincyDamageTakenMult(skilltype)
	if(!skilltype || !AlmightyOnNow())
		return 1
	AlmightyExpire()
	if(!src.AlmightyKnown || !(skilltype in src.AlmightyKnown))
		return 1
	return 1 - min(QUINCY_ADAPT_MAX, QUINCY_ADAPT_BASE + QUINCY_ADAPT_STEP * (src.AlmightyKnown.len - 1))

/strikeHook/quincyAlmightyAdapt
	stage = "post"
	fire(strike/S)
		var/mob/d = S.defender
		if(!d || d == S.attacker || S.dealt <= 0 || !istype(S.skill, /obj/Skills))
			return
		if(!d.AlmightyOnNow())
			return
		d.AlmightyLearn(S.skill.type)

/mob/proc/AlmightyCanRewrite(mob/P)
	if(src.KO || !AlmightyOnNow() || !QuincyIsKaiser())
		return 0
	if(!ismob(P) || P == src || P.Lethal || src.NoVoid)
		return 0
	return !src.AlmightyRewriteAt || src.AlmightyRewriteAt + QUINCY_ALMIGHTY_REWRITE_COOLDOWN <= world.time

/mob/proc/AlmightyRewrite(mob/P)
	src.AlmightyRewriteAt = world.time
	src.SetHealthPct(QUINCY_ALMIGHTY_REWRITE_PCT)
	src.MaxHealth()
	src.OMessage(15, "...but [src] rewrites the future to prevent their defeat!", "<font color=red>[src]([src.key]) rewrites the future against [P]([P.key]).")

/mob/Players/Unconscious(mob/P, text)
	if(AlmightyCanRewrite(P))
		AlmightyRewrite(P)
		return
	return ..()

/obj/Skills/Quincy/Blut_Vene_Anhaben
	name = "Blut Vene Anhaben"
	desc = "Spread Blut Vene into a shell of Reishi around your body. Those beside you bleed Mana into it. Once per fight."
	Cooldown = -1
	ManaCost = 15
	Copyable = 0
	var/shield = QUINCY_ANHABEN_SHIELD
	var/seconds = QUINCY_ANHABEN_SECONDS
	var/drain = QUINCY_ANHABEN_DRAIN

	verb/Blut_Vene_Anhaben()
		set name = "Blut Vene Anhaben"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		AnhabenFire(User)

	proc/AnhabenCost(mob/User)
		if(User.HasDrainlessMana())
			return 0
		var/c = src.ManaCost * User.ChakraCostMult(src) * User.SpellCostMult(src)
		if(c <= 0)
			c = 0.5
		return c

	proc/AnhabenFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.QuincyIsKaiser() || User.QuincyLevel < QUINCY_ANHABEN_LEVEL)
			User << "Only the Kaiser at Signature Mastery Level 7 can spread Blut Vene this far."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "<font color=red>[src] is spent until you meditate.</font>"
			return 0
		var/cost = AnhabenCost(User)
		if(cost && User.ManaAmount < cost)
			User << "You don't have enough mana to use [src]."
			return 0
		if(cost)
			User.LoseMana(cost)
		OMsg(User, "[User]'s Blut Vene spreads outward into a shell of Reishi.")
		src.Cooldown(1, null, User)
		User.AlmightyAnhaben(src.shield, src.seconds, src.drain)
		return 1

/mob/proc/AlmightyAnhaben(shield, seconds, drain)
	set waitfor = 0
	var/base = max(0, src.VaizardHealth)
	src.VaizardHealth += shield
	for(var/i = 1 to seconds)
		sleep(10)
		if(!src || src.KO)
			break
		for(var/mob/m in orange(1, src))
			if(m.ManaAmount > 0 && QuincyAreaFoe(m, src))
				m.LoseMana(drain)
	if(!src)
		return
	src.VaizardHealth -= clamp(src.VaizardHealth - base, 0, shield)

/obj/Items/Standspitze
	name = "Standspitze"
	desc = "A silver arrowhead forged from a clot of Still Silver."
	icon = 'Icons/Blasts/LightStrike.dmi'
	Unobtainable = 1
	Stealable = 0
	Savable = 1

/obj/Skills/Projectile/Quincy/Standspitze
	name = "Standspitze"
	desc = "Throw the Still Silver. If it strikes the Kaiser, The Almighty goes dark for a minute and the arrowhead is spent."
	MaxCharges = 1
	Charges = 1
	ChargeRefresh = 10
	DamageMult = 1
	Distance = 12
	Speed = 0.3
	Deflectable = -1
	Copyable = 0
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	IconSize = 1
	LockX = 0
	LockY = 0
	ActiveMessage = "throws a silver arrowhead!"

	verb/Standspitze()
		set name = "Standspitze"
		set category = "Skills"
		if(!(locate(/obj/Items/Standspitze) in usr))
			usr << "You no longer hold the Standspitze."
			return
		usr.UseProjectile(src)

/mob/proc/AlmightyStrip()
	src.AlmightyStrippedUntil = world.time + QUINCY_ALMIGHTY_STRIP_TIME
	var/obj/Skills/Buffs/SlotlessBuffs/The_Almighty/A = locate() in src
	if(A && A.SlotlessOn)
		A.Trigger(src, 1)
	world << "<font color=#9fd8ff><b>The Still Silver touches the Kaiser's blood. The Almighty goes dark.</b></font>"

/mob/proc/QuincyStandspitzeSpend()
	set waitfor = 0
	sleep(1)
	if(!src)
		return
	for(var/obj/Items/Standspitze/I in src)
		del I
	var/obj/Skills/S = QuincyOwnedSkill(/obj/Skills/Projectile/Quincy/Standspitze)
	if(S)
		src.DeleteSkill(S)

/strikeHook/quincyStandspitze
	stage = "post"
	fire(strike/S)
		if(!istype(S.skill, /obj/Skills/Projectile/Quincy/Standspitze))
			return
		var/mob/d = S.defender
		var/mob/a = S.attacker
		if(!d || !a || d == a || !d.QuincyIsKaiser())
			return
		d.AlmightyStrip()
		a.QuincyStandspitzeSpend()

/obj/Skills/Buffs/SlotlessBuffs/Auswahlen_Surge
	name = "Auswahlen"
	BuffName = "Auswahlen Surge"
	Slotless = 1
	Copyable = 0
	TimerLimit = 600
	StrMult = QUINCY_SURGE_MULT
	EndMult = QUINCY_SURGE_MULT
	SpdMult = QUINCY_SURGE_MULT
	ForMult = QUINCY_SURGE_MULT
	OffMult = QUINCY_SURGE_MULT
	DefMult = QUINCY_SURGE_MULT
	ActiveMessage = "drinks in the Reishi of the letter taken back."
	OffMessage = "lets the taken power settle."

/mob/proc/QuincyAuswahlenSurge()
	var/obj/Skills/Buffs/SlotlessBuffs/Auswahlen_Surge/B = src.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Auswahlen_Surge)
	if(B && !B.SlotlessOn)
		B.Trigger(src, 1)
