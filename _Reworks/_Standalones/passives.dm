mob
	var
		passive/passive_handler
/*	verb
		GetAllPassives() //test verb, remove later
			usr << passive_handler.getAll() */

passive
	var
		list/passives //this list will track passives that are intended to stick to the character; racials/things sticking over relogs.
		tmp/list/tmp_passives //this list is for buffs, or things that should fall off naturally/on a relog.
		tmp/list/text_passive_restore_stack

	New()
		passives = list()
		tmp_passives = list()
		text_passive_restore_stack = list()
	proc

		Get(passive) // returns value of passive if it exists/has anything

			return passives[passive] ? passives[passive] : 0
		operator[](passive)
			return Get(passive)
		getAll() //outputs in text, will be used for some sort of psuedo-assess
			var/passiveText="Passives:"
			for(var/p in passives)
				passiveText+= "\n[p] = [passives[p]+tmp_passives[p]]"
			return "[passiveText]"

		Increase(passive, value = 1, temp = FALSE) // Used to specifically increment a passive upwards. If it doesn't exist, then it gets created and set to that value. passive can also be passed in as a list ofto increase.
			if(!isnum(value))
				CRASH("ERROR: [passive] was increased by [value] which is not a number!")
			switch(islist(passive))
				if(FALSE)
					switch(temp)
						if(FALSE)
							passives[passive] += value
						if(TRUE)
							tmp_passives[passive] += value
				if(TRUE)
					increaseList(passive, temp)

		Set(passive, value = 0, temp = FALSE) // directly sets a passive
			if(isnull(value))
				CRASH("ERROR: [passive] was set to [value] which is not a number!")
			switch(islist(passive))
				if(FALSE)
					switch(temp)
						if(FALSE)
							passives[passive] = value
						if(TRUE)
							tmp_passives[passive] = value
				if(TRUE)
					setList(passive, temp)

		Decrease(passive, value = 1, temp = FALSE)
			if(!isnum(value))
				CRASH("ERROR: [passive] was decreased by [value] which is not a number!")
			switch(islist(passive))
				if(FALSE)
					switch(temp)
						if(FALSE)
							passives[passive] -= value
						if(TRUE)
							tmp_passives[passive] -= value
				if(TRUE)
					decreaseList(passive, temp)

		decreaseList(list/settingPassiveList, temp = FALSE)
			switch(temp)
				if(FALSE)
					for(var/settingPassive in settingPassiveList)
						var/value = settingPassiveList[settingPassive]
						if(!isnum(value))
							if(istext(value))
								var/list/restore_stack = text_passive_restore_stack[settingPassive]
								if(islist(restore_stack) && restore_stack.len > 0)
									var/restore_value = restore_stack[restore_stack.len]
									restore_stack.Cut(restore_stack.len, restore_stack.len + 1)
									passives[settingPassive] = restore_value
									if(restore_stack.len <= 0)
										text_passive_restore_stack -= settingPassive
								else
									passives[settingPassive] = null
							else
								CRASH("ERROR: [settingPassive] was increased by [value] which is not a number!")
						else
							passives[settingPassive] -= value // - (-1) is +1 , - 1 is -1
				if(TRUE)
					for(var/settingPassive in settingPassiveList)
						var/value = settingPassiveList[settingPassive]
						if(!isnum(value))
							CRASH("ERROR: [settingPassive] was decreased by [value] which is not a number!")
						tmp_passives[settingPassive] -= value

		increaseList(list/settingPassiveList, temp = FALSE)
			switch(temp)
				if(FALSE)
					for(var/settingPassive in settingPassiveList)
						var/value = settingPassiveList[settingPassive]
						if(!isnum(value))
							if(istext(value))
								if(!islist(text_passive_restore_stack[settingPassive]))
									text_passive_restore_stack[settingPassive] = list()
								var/list/restore_stack = text_passive_restore_stack[settingPassive]
								restore_stack += passives[settingPassive]
								passives[settingPassive] = value
							else
								CRASH("ERROR: [settingPassive] was increased by [value] which is not a number!")
						else
							passives[settingPassive] += value
				if(TRUE)
					for(var/settingPassive in settingPassiveList)
						var/value = settingPassiveList[settingPassive]
						if(!isnum(value))
							CRASH("ERROR: [settingPassive] was increased by [value] which is not a number!")
						tmp_passives[settingPassive] += value

		setList(list/settingPassiveList, temp = FALSE)
			switch(temp)
				if(FALSE)
					for(var/settingPassive in settingPassiveList)
						var/value = settingPassiveList[settingPassive]
						if(!isnum(settingPassiveList[settingPassive]))
							CRASH("ERROR: [settingPassive] was set to [value] which is not a number!")
						passives[settingPassive] = value
				if(TRUE)
					for(var/settingPassive in settingPassiveList)
						var/value = settingPassiveList[settingPassive]
						if(!isnum(value))
							CRASH("ERROR: [settingPassive] was set to [value] which is not a number!")
						tmp_passives[settingPassive] = value
		operator|=(passive) // alternative way of checking passives. shorthand if(passive|="zornhau") returns the value of zornhau
			Get(passive)