#define QUINCY_LAST_SKILLS 3
#define QUINCY_FIGHT_IDLE 300

mob/var/tmp/list/QuincyLastSkills
mob/var/tmp/QuincyFightAt = 0

/proc/QuincyLastSkillTypes(mob/m)
	var/list/out = list()
	if(!ismob(m) || !m.QuincyLastSkills)
		return out
	for(var/t in m.QuincyLastSkills)
		out += t
	return out

/proc/QuincyLastSkillType(mob/m)
	if(!ismob(m) || !m.QuincyLastSkills || !m.QuincyLastSkills.len)
		return null
	return m.QuincyLastSkills[1]

/mob/proc/QuincyLastSkillNote(t)
	if(!ispath(t, /obj/Skills))
		return
	if(!src.QuincyLastSkills)
		src.QuincyLastSkills = list()
	if(src.QuincyLastSkills.len && src.QuincyLastSkills[1] == t)
		return
	src.QuincyLastSkills.Insert(1, t)
	if(src.QuincyLastSkills.len > QUINCY_LAST_SKILLS)
		src.QuincyLastSkills.Cut(QUINCY_LAST_SKILLS + 1)

/mob/proc/QuincyFightIdle()
	return !src.QuincyFightAt || world.time - src.QuincyFightAt >= QUINCY_FIGHT_IDLE

/strikeHook/quincyLastSkills
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(a)
			a.QuincyFightAt = world.time
		if(d)
			d.QuincyFightAt = world.time
		if(!a || a == d || !istype(S.skill, /obj/Skills))
			return
		a.QuincyLastSkillNote(S.skill.type)
