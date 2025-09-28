obj/Skills/Buffs/ActiveBuffs/Hero
	var/sagaInfo/sagaInfo
	var/lastSagaTier = 0
	proc/getCurrentBoons(mob/player)
		for(var/i = 1; i <= player.SagaLevel; i++)
			var/index=num2text(i)
			for(var/passiveName in sagaInfo.perLevelPassives)
				if(passiveName in vars)
					vars[passiveName] += sagaInfo.perLevelPassives[passiveName]
				else
					player.vars[passiveName] += sagaInfo.perLevelPassives[passiveName]
			if(index in sagaInfo.specificPassives)
				for(var/passiveName in sagaInfo.specificPassives[index])
					if(passiveName in vars)
						vars[passiveName] += sagaInfo.specificPassives[index][passiveName]
					else
						player.vars[passiveName] += sagaInfo.specificPassives[index][passiveName]
			for(var/level in sagaInfo.chosenChoices)
				if(level == index)
					for(var/passiveName in sagaInfo.chosenChoices[level])
						if(passiveName in vars)
							vars[passiveName] += sagaInfo.chosenChoices[level][passiveName]
						else
							player.vars[passiveName] += sagaInfo.chosenChoices[level][passiveName]
		lastSagaTier = usr.SagaLevel
	proc/removeCurrentBoons(mob/player)
		for(var/i = 1; i <= lastSagaTier; i++)
			var/index=num2text(i)
			for(var/passiveName in sagaInfo.perLevelPassives)
				if(passiveName in vars)
					vars[passiveName] -= sagaInfo.perLevelPassives[passiveName]
				else
					player.vars[passiveName] -= sagaInfo.perLevelPassives[passiveName]
			if(index in sagaInfo.specificPassives)
				for(var/passiveName in sagaInfo.specificPassives[i])
					if(passiveName in vars)
						vars[passiveName] -= sagaInfo.specificPassives[i][passiveName]
					else
						player.vars[passiveName] -= sagaInfo.specificPassives[i][passiveName]
			for(var/level in sagaInfo.chosenChoices)
				if(level == i)
					for(var/passiveName in sagaInfo.chosenChoices[level])
						if(passiveName in vars)
							vars[passiveName] -= sagaInfo.chosenChoices[level][passiveName]
						else
							player.vars[passiveName] -= sagaInfo.chosenChoices[level][passiveName]
	verb/HeroBuff()
		set name = "Heroic Courage"
		set category="Skills"
		if(!usr.BuffOn(src))
			if(lastSagaTier != usr.SagaLevel)
				removeCurrentBoons(usr)
				getCurrentBoons(usr)
		src.Trigger(usr)


/mob/var/HeroLegend




sagaInfo
	var/list/perLevelPassives = list()
	var/list/specificPassives = list()
	var/list/choicePassives = list()
	var/list/chosenChoices = list()
	var/list/skillsPerTier = list()
	var/list/choicesPaths = list()
	var/list/pathsPicked = list()