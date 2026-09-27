#ifndef HOLLOW
#define HOLLOW /race/hollow
#endif

#define HOLLOW_STAGE_BASE "hollow"
#define HOLLOW_STAGE_GILLIAN "gillian"
#define HOLLOW_STAGE_ADJUCHAS "adjuchas"
#define HOLLOW_STAGE_VASTO "vasto"

#define HOLLOW_ARRANCAR_NONE 0
#define HOLLOW_ARRANCAR_NATURAL 1
#define HOLLOW_ARRANCAR_HOGYOKU 2

#define HOLLOW_NEWBORN_SECONDS 600
#define HOLLOW_NEWBORN_MULT 0.75
#define HOLLOW_POINT_CAP 10
#define HOLLOW_VASTO_BASE_CHANCE 2
#define HOLLOW_COUNT_GAP_SECONDS 3600
#define HOLLOW_NO_NEST_DELAY 600
#define HOLLOW_VASTO_MOD_STEP 0.25
#define HOLLOW_VASTO_MOD_ENTRY 0.5
#define HOLLOW_VASTO_POWER 5
#define HOLLOW_VASTO_REGENERATION 3
#define HOLLOW_RES_POWER_MULT 1.10

globalTracker
	var
		VastoLordeCount = 0
		VastoLordeLimit = 3
		list/ResurreccionHolders = list()
		HogyokuExists = 0

proc/HollowStageName(id)
	switch(id)
		if(HOLLOW_STAGE_GILLIAN)
			return "Menos Grande"
		if(HOLLOW_STAGE_ADJUCHAS)
			return "Adjuchas"
		if(HOLLOW_STAGE_VASTO)
			return "Vasto Lorde"
	return "Hollow"

proc/HollowArrancarName(kind)
	switch(kind)
		if(HOLLOW_ARRANCAR_NATURAL)
			return "Natural"
		if(HOLLOW_ARRANCAR_HOGYOKU)
			return "Hogyoku"
	return "None"

proc/HollowEvolutionLadder(potential)
	if(potential >= 90)
		return 4.56
	if(potential >= 80)
		return 2.90
	if(potential >= 65)
		return 1.15
	if(potential >= 55)
		return 0.65
	if(potential >= 25)
		return 0.30
	return 0

proc/HollowClassShare(mob/m)
	if(!m)
		return 0
	switch(m.HollowStage)
		if(HOLLOW_STAGE_VASTO)
			return 1
		if(HOLLOW_STAGE_ADJUCHAS)
			return 0.8
		if(HOLLOW_STAGE_GILLIAN)
			return m.HollowArrancar ? 0.6 : 0.5
	return 0

proc/HollowStageOrder(id)
	switch(id)
		if(HOLLOW_STAGE_GILLIAN)
			return 1
		if(HOLLOW_STAGE_ADJUCHAS)
			return 2
		if(HOLLOW_STAGE_VASTO)
			return 3
	return 0

/mob/proc/HollowStageSkillSet()
	var/list/want = list()
	switch(src.HollowStage)
		if(HOLLOW_STAGE_GILLIAN)
			want += /obj/Skills/AutoHit/Hollow/Trample
			want += /obj/Skills/Projectile/Beams/Big/Hollow/Cero
		if(HOLLOW_STAGE_ADJUCHAS)
			want += /obj/Skills/Projectile/Beams/Big/Hollow/Cero
			want += /obj/Skills/Projectile/Beams/Big/Hollow/Gran_Rey_Cero
		if(HOLLOW_STAGE_VASTO)
			want += /obj/Skills/Projectile/Beams/Big/Hollow/Cero
			want += /obj/Skills/Projectile/Beams/Big/Hollow/Gran_Rey_Cero
			want += /obj/Skills/Projectile/Beams/Big/Hollow/Cero_Oscuras
		else
			var/datum/hollow_shell/S = HollowShellDatum(src.HollowShell)
			if(S && S.skill_path)
				want += S.skill_path
	if(src.HollowStage == HOLLOW_STAGE_GILLIAN && src.HollowArrancar)
		want -= /obj/Skills/Projectile/Beams/Big/Hollow/Gran_Rey_Cero
	want += /obj/Skills/Hollow/Devour
	if(src.HollowDeathRegen && src.AscensionsAcquired >= 2)
		want += /obj/Skills/Hollow/Awaken
	return want
