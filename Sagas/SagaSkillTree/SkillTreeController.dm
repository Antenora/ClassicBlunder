datum/saga_skill_tree_panel
	var/client/owner
	var/mob/player
	var/tree_id
	var/ready = FALSE

	New(client/C, selected_tree)
		..()
		owner = C
		player = C.mob
		tree_id = selected_tree

	proc/Valid()
		if(!owner || !player) return FALSE
		if(owner.mob != player) return FALSE
		if(owner.sagaSkillTreePanel != src) return FALSE
		return TRUE

	proc/Push(message = "")
		if(!Valid() || !ready) return

		var/datum/saga_skill_tree/T = SagaSkillTrees[tree_id]
		if(!T) return

		var/list/rows = list()
		var/list/nodes = SagaSkillTreeNodes[tree_id]
		var/general_refund_block = player.SagaTreeRefundBlock()

		if(T.CanAccess(player))
			for(var/id in nodes)
				var/datum/saga_skill_tree_node/N = nodes[id]
				if(!N.IsVisible(player)) continue
				var/rank = N.GetRank(player)
				var/limit = N.RankLimit()
				var/price = N.NextCost(player)
				var/list/missing = N.MissingRequirements(player)
				var/refund_block = N.RefundBlock(player)

				if(!refund_block)
					refund_block = general_refund_block

				var/refund_amount = 0
				var/list/history = N.GetHistory(player)
				if(history && history.len)
					var/list/record = history[history.len]
					refund_amount = record["paid"]

				var/list/links = list()
				for(var/required_id in N.requires)
					links += required_id

				rows += list(list(
					"id" = N.id,
					"title" = N.title,
					"description" = N.description,
					"cost" = price,
					"x" = N.tree_x,
					"y" = N.tree_y,
					"requires" = links,
					"missing" = missing,
					"rank" = rank,
					"maxRank" = limit,
					"learned" = rank > 0,
					"maxed" = rank >= limit,
					"canBuy" = rank < limit && !missing.len && player.RPPSpendable >= price,
					"canRefund" = !refund_block,
					"refundAmount" = refund_amount,
					"refundBlock" = refund_block
				))
		else
			message = "You no longer meet this tree's Saga requirement."

		var/list/state = list(
			"title" = T.title,
			"points" = player.RPPSpendable,
			"nodes" = rows,
			"message" = message
		)

		owner << output(list2params(list(json_encode(state))), "sagaskilltree.browser:receiveSagaSkillTree")

	proc/Buy(id)
		if(!Valid() || !ready) return
		if(player.saga_skill_tree_buying || player.refunding) return

		var/datum/saga_skill_tree/T = SagaSkillTrees[tree_id]
		if(!T || !T.CanAccess(player))
			Push("You cannot purchase from this tree.")
			return

		var/list/nodes = SagaSkillTreeNodes[tree_id]
		var/datum/saga_skill_tree_node/N = nodes[id]
		if(!N) return

		if(N.GetRank(player) >= N.RankLimit())
			Push("[N.title] is already at its maximum rank.")
			return

		var/list/missing = N.MissingRequirements(player)
		if(missing.len)
			Push(jointext(missing, "; "))
			return

		var/price = N.NextCost(player)
		if(player.RPPSpendable < price)
			Push("You do not have enough spendable RPP.")
			return

		var/mob/M = player
		M.saga_skill_tree_buying = TRUE
		M.RPPSpendable -= price

		var/list/record = list("paid" = price)
		var/success = FALSE

		try
			success = N.GrantRank(M, record)
		catch(var/exception/E)
			world.log << "Saga Skill Tree purchase failed for [N.id]: [E]"

		if(!M) return

		if(success)
			var/list/history = N.GetHistory(M, TRUE)
			history += list(record)
			M.RPPSpent += price
		else
			M.RPPSpendable += price

		M.saga_skill_tree_buying = FALSE

		if(success)
			Push("Purchased [N.title] rank [N.GetRank(M)] for [price] RPP!")
		else
			Push("Purchase failed. Your RPP was returned.")

	proc/Refund(id)
		if(!Valid() || !ready) return
		if(player.saga_skill_tree_buying) return

		var/datum/saga_skill_tree/T = SagaSkillTrees[tree_id]
		if(!T || !T.CanAccess(player)) return

		var/list/nodes = SagaSkillTreeNodes[tree_id]
		var/datum/saga_skill_tree_node/N = nodes[id]
		if(!N) return

		var/reason = player.SagaTreeRefundBlock()
		if(!reason)
			reason = N.RefundBlock(player)

		if(reason)
			Push(reason)
			return

		var/mob/M = player
		var/list/history = N.GetHistory(M)
		var/list/record = history[history.len]
		var/amount = record["paid"]

		M.saga_skill_tree_buying = TRUE
		M.refunding = TRUE

		var/success = FALSE
		try
			success = N.RemoveRank(M, record)
		catch(var/exception/E)
			world.log << "Saga Skill Tree refund failed for [N.id]: [E]"

		if(!M) return

		if(success)
			history.Cut(history.len, history.len + 1)
			M.RPPSpendable += amount
			M.RPPSpent -= amount
			M.last_refund_pot = M.Potential

		M.refunding = FALSE
		M.saga_skill_tree_buying = FALSE

		if(success)
			Push("Refunded one rank of [N.title] for [amount] RPP.")
		else
			Push("The reward could not be removed. No RPP was refunded.")

	Topic(href, list/href_list)
		if(!Valid()) return
		if(usr != player || usr.client != owner) return

		switch(href_list["action"])
			if("ready")
				ready = TRUE
				Push()
			if("refresh")
				Push()
			if("buy")
				Buy(href_list["id"])
			if("refund")
				Refund(href_list["id"])