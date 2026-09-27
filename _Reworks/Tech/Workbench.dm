#define TECH_SPECIALIST_NODES 6
#define TECH_SPECIALIST_POINTS 5

/obj/LifeSkills/Station/Workbench
	name = "Workbench"
	icon = 'Icons/LifeSkills/Stations.dmi'
	icon_state = "anvil"
	desc = "A technologist's workbench. Face it and press your Interact key to build."
	density = 1
	station_kind = "workbench"
	craft_skill = "Technology"
	craft_title = "WORKBENCH"
	craft_verb = "BUILD"

mob/Admin4/verb/makeWorkbench()
	set category = "Admin"
	new/obj/LifeSkills/Station/Workbench(get_step(src, src.dir))
	src << "Workbench placed."

mob/proc/TechBenchOwned(bench)
	if(!bench) return 0
	if(length(TechnologyTree) < 1)
		fillOutTechTree()
	if(!knowledgeTracker || !knowledgeTracker.learnedKnowledge) return 0
	var/owned = 0
	for(var/n in knowledgeTracker.learnedKnowledge)
		var/knowledgePaths/tech/t = TechnologyTree[n]
		if(!t) continue
		if(t.bench == bench) owned++
	return owned

mob/LifeQualityPoints(skill)
	. = ..()
	if(skill != "Technology") return
	var/datum/craft_recipe/lifecraft/R = life_craft_current
	if(!R || !R.knowledge_req) return
	if(length(TechnologyTree) < 1)
		fillOutTechTree()
	var/knowledgePaths/tech/t = TechnologyTree[R.knowledge_req]
	if(!t || !t.bench) return
	if(TechBenchOwned(t.bench) >= TECH_SPECIALIST_NODES)
		. += TECH_SPECIALIST_POINTS
