datum/saga_skill_tree
	var/id
	var/title
	var/required_saga = null

	var/background_icon = 'HUD/SagaSkillTree/srw_background.dmi'
	var/background_state = "Background"
	var/background_width = 1344
	var/background_color = "#000000"


	var/font_file = null // null is monospace
	var/font_size = 14
	var/node_font_size = 12
	var/title_font_size = 18

	var/text_color = "#ffffff"
	var/muted_color = "#ccd4ed"
	var/accent_color = "#91caff"

	var/panel_color = "#111322"
	var/panel_border_color = "#6674a7"

	var/node_color = "#131321"
	var/node_border_color = "#788099"
	var/node_available_border_color = "#e1e6ff"
	var/node_learned_color = "#3c51af"

	var/line_color = "#77809e"
	var/line_learned_color = "#9eb4ff"

	var/button_color = "#344993"
	var/button_border_color = "#9aacec"
	var/refund_button_color = "#49334c"

mob/var/list/SagaSkillTreeHistory = list()

obj/Skills/var/SagaTreePurchased = FALSE


datum/saga_skill_tree_node
	var/id
	var/tree_id
	var/title
	var/skill_path
	var/description = ""
	var/cost = 1
	var/max_rank = 1
	var/list/rank_costs = list()
	var/list/requires = list()
	var/required_saga = null
	var/required_saga_level = 0
	var/tree_x = 0
	var/tree_y = 0
	var/visible_if_var = null // show only if this var exists and is above null/0 on player
	var/visible_if_value = null // show only if the previous var exists and is this Exact value

	//note you can also configure visibility by overriding VisibilityCondition! check srwmain.dm for examples for the time being

	proc/IsConfigured()
		return ispath(skill_path, /obj/Skills)

	proc/RankLimit()
		return 1

	proc/GetHistory(mob/M, create = FALSE)
		if(!M) return null

		if(!islist(M.SagaSkillTreeHistory))
			if(!create) return null
			M.SagaSkillTreeHistory = list()

		var/list/tree_history = M.SagaSkillTreeHistory[tree_id]
		if(!islist(tree_history))
			if(!create) return null
			tree_history = list()
			M.SagaSkillTreeHistory[tree_id] = tree_history

		var/list/history = tree_history[id]
		if(!islist(history))
			if(!create) return null
			history = list()
			tree_history[id] = history

		return history

	proc/GetRank(mob/M)
		if(!M) return 0
		var/list/history = GetHistory(M)
		if(history && history.len) return 1

		return M.FindSkill(skill_path) ? 1 : 0

	proc/IsLearned(mob/M)
		return GetRank(M) > 0

	proc/NextCost(mob/M)
		var/next_rank = GetRank(M) + 1
		if(next_rank <= rank_costs.len)
			return max(0, rank_costs[next_rank])
		return max(0, cost)

	proc/RequiredRank(required_id)
		var/value = requires[required_id]
		if(isnum(value))
			return max(1, round(value))
		return 1

	proc/GrantRank(mob/M, list/record)
		if(!M || M.FindSkill(skill_path)) return FALSE

		M.findOrAddSkill(skill_path)

		var/obj/Skills/S = M.FindSkill(skill_path)
		if(!S) return FALSE

		S.SagaTreePurchased = TRUE
		record["skill"] = S
		record["skill_path"] = skill_path
		return TRUE

	proc/RemoveRank(mob/M, list/record)
		var/obj/Skills/S = record["skill"]
		if(!S) return TRUE
		if(S.loc != M) return FALSE
		if(istype(S, /obj/Skills/Buffs))
			var/obj/Skills/Buffs/B = S
			if(M.BuffOn(B))
				B.Trigger(M, Override = 1)

		if(istype(S, /obj/Skills/Buffs/SpiritCommands/Instant))
			M.ClearSpiritCommands()

		if(S.name in M.SkillsLocked)
			M.SkillsLocked -= S.name

		del S

		for(var/obj/Skills/Buffs/NuStyle/style in M)
			M.StyleUnlock(style)

		return TRUE

	proc/RefundBlock(mob/M)
		var/list/history = GetHistory(M)
		if(!history || !history.len)
			return "No recorded purchase to refund."

		var/remaining_rank = GetRank(M) - 1
		var/list/nodes = SagaSkillTreeNodes[tree_id]

		for(var/other_id in nodes)
			var/datum/saga_skill_tree_node/N = nodes[other_id]
			if(N == src || !N.IsLearned(M)) continue

			if(id in N.requires)
				if(remaining_rank < N.RequiredRank(id))
					return "[N.title] requires [title] rank [N.RequiredRank(id)]."

		return ""


	proc/VisibilityCondition(mob/M)
		if(!M) return FALSE
		if(!visible_if_var) return TRUE
		if(!(visible_if_var in M.vars)) return FALSE

		var/value = M.vars[visible_if_var]

		if(!isnull(visible_if_value))
			return value == visible_if_value

		return value ? TRUE : FALSE

	proc/IsVisible(mob/M, list/checking = null)
		if(!VisibilityCondition(M)) return FALSE

		if(!checking)
			checking = list()

		if(id in checking) return FALSE

		var/list/branch = checking.Copy()
		branch += id

		var/list/nodes = SagaSkillTreeNodes[tree_id]
		if(!islist(nodes)) return FALSE

		for(var/required_id in requires)
			var/datum/saga_skill_tree_node/N = nodes[required_id]
			if(!N || !N.IsVisible(M, branch))
				return FALSE

		return TRUE

datum/saga_skill_tree_node/Passive // this node grants a Passive so the Reward process is different
	var/passive_name
	var/passive_amount = 1
	IsConfigured()
		return passive_name && passive_amount > 0 && max_rank >= 1
	RankLimit()
		return max(1, round(max_rank))
	GetRank(mob/M)
		if(!M) return 0

		var/rank = 0

		if(islist(M.SagaSkillTreePurchased))
			var/list/old_purchases = M.SagaSkillTreePurchased[tree_id]
			if(islist(old_purchases) && (id in old_purchases))
				rank = 1

		var/list/history = GetHistory(M)
		if(history)
			rank += history.len

		return rank

	GrantRank(mob/M, list/record)
		if(!M || !M.passive_handler) return FALSE

		M.passive_handler.Increase(passive_name, passive_amount)

		record["passive"] = passive_name
		record["amount"] = passive_amount
		return TRUE

	RemoveRank(mob/M, list/record)
		if(!M || !M.passive_handler) return FALSE

		M.passive_handler.Decrease(record["passive"], record["amount"])
		return TRUE


datum/saga_skill_tree_node/RankedSkill // this node let you purchase extra skills from the same node through different ranks
	var/list/rank_skills = list()

	IsConfigured()
		if(!rank_skills.len) return FALSE

		var/list/seen = list()
		for(var/path in rank_skills)
			if(!ispath(path, /obj/Skills)) return FALSE
			if(path in seen) return FALSE
			seen += path

		return TRUE

	RankLimit()
		return rank_skills.len

	GetRank(mob/M)
		var/list/history = GetHistory(M)
		return history ? history.len : 0

	MissingRequirements(mob/M)
		var/list/missing = ..()
		if(!M) return missing

		var/next_rank = GetRank(M) + 1
		if(next_rank <= rank_skills.len)
			var/path = rank_skills[next_rank]
			if(M.FindSkill(path))
				missing += "You already own the next rank's skill from another source."

		return missing

	GrantRank(mob/M, list/record)
		if(!M) return FALSE

		var/next_rank = GetRank(M) + 1
		if(next_rank > rank_skills.len) return FALSE

		var/path = rank_skills[next_rank]
		if(M.FindSkill(path)) return FALSE

		M.findOrAddSkill(path)

		var/obj/Skills/S = M.FindSkill(path)
		if(!S) return FALSE

		S.SagaTreePurchased = TRUE
		record["skill"] = S
		record["skill_path"] = path
		return TRUE

var/global/list/SagaSkillTrees = list()
var/global/list/SagaSkillTreeNodes = list()
var/global/SagaSkillTreesRegistered = FALSE

mob/var/tmp/saga_skill_tree_buying = FALSE
mob/var/list/SagaSkillTreePurchased = list()

client/var/tmp/datum/saga_skill_tree_panel/sagaSkillTreePanel


proc/RegisterSagaSkillTrees()
	if(SagaSkillTreesRegistered) return

	for(var/path in typesof(/datum/saga_skill_tree))
		if(path == /datum/saga_skill_tree) continue

		var/datum/saga_skill_tree/T = new path
		if(!T.id)
			del T
			continue

		if(SagaSkillTrees[T.id])
			world.log << "Duplicate Saga Skill Tree ID: [T.id]"
			del T
			continue

		if(!T.title) T.title = T.id
		SagaSkillTrees[T.id] = T
		SagaSkillTreeNodes[T.id] = list()

	for(var/path in typesof(/datum/saga_skill_tree_node))
		if(path == /datum/saga_skill_tree_node) continue

		var/datum/saga_skill_tree_node/N = new path
		if(!N.id || !N.tree_id || !N.IsConfigured())
			del N
			continue

		var/list/nodes = SagaSkillTreeNodes[N.tree_id]
		if(!islist(nodes))
			world.log << "Unknown Saga Skill Tree [N.tree_id] for node [N.id]"
			del N
			continue

		if(nodes[N.id])
			world.log << "Duplicate node [N.id] in Saga Skill Tree [N.tree_id]"
			del N
			continue

		if(!N.title) N.title = N.id
		nodes[N.id] = N

	SagaSkillTreesRegistered = TRUE


datum/saga_skill_tree/proc/CanAccess(mob/M)
	if(!M) return FALSE
	if(required_saga && M.Saga != required_saga) return FALSE
	return TRUE


datum/saga_skill_tree_node/proc/MissingRequirements(mob/M)
	var/list/missing = list()
	if(!M)
		missing += "No character."
		return missing

	var/list/nodes = SagaSkillTreeNodes[tree_id]

	for(var/required_id in requires)
		var/datum/saga_skill_tree_node/N
		if(islist(nodes))
			N = nodes[required_id]

		var/needed = RequiredRank(required_id)

		if(!N)
			missing += "Unknown prerequisite: [required_id]"
		else if(N.GetRank(M) < needed)
			missing += "[N.title] rank [needed] required"

	if(required_saga && M.Saga != required_saga)
		missing += "Requires [required_saga]"

	if(required_saga_level > 0 && M.SagaLevel < required_saga_level)
		missing += "Saga level [required_saga_level] required (current: [M.SagaLevel])"

	return missing


mob/proc/SagaTreeRefundBlock()
	if(refund_banned)
		return "You cannot refund right now."

	if(refunding)
		return "You are already refunding something."

	if(last_refund_pot != 0 && Potential > 20)
		if(Potential < last_refund_pot + glob.pot_between_refunds)
			return "You must gain more Potential before refunding again."

	return ""