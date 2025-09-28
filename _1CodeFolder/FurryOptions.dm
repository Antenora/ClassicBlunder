mob
	var
		Neko//Are they a neko?
		Kitsune//Or kitsune?
		Tanuki//Or have huge balls?
		Wolf//Generic furry.tiff
		Lizard//fuccing scalies
		Tengu//itty bitty titty wings
		Bull//HORNY
		FurryTail=1//1 for tail displayed, 0 for tail hidden.
		FurryEars=1//1 for ears displayed, 0 for ears hidden.

obj
	FurryOptions
		verb
			Trait_Options()
				set category="Other"
				set src in usr
				if(!(world.time > usr.verb_delay)) return
				usr.verb_delay=world.time+1
				var/Choice
				Choice=alert("Do you want to hide your traits or adjust their color?", "Trait Options", "Ears", "Other Traits", "Trait Color")
				if(Choice=="Ears")
					if(usr.Lizard||usr.Tengu||usr.Bull)
						Choice="Other"
				switch(Choice)
					if("Ears")
						if(usr.FurryEars)
							usr.FurryEars=0
							usr << "You <font color='red'>hide</font color> your ears."
						else
							usr.FurryEars=1
							usr << "You <font color='green'>display</font color> your ears."
					if("Other Traits")
						if(usr.FurryTail)
							usr.FurryTail=0
							if(usr.Tengu)
								usr << "You <font color='red'>hide</font color> your wings."
							else if(usr.Bull)
								usr << "You <font color='red'>hide</font color> your horns."
							else
								usr << "You <font color='red'>hide</font color> your tail."
						else
							usr.FurryTail=1
							if(usr.Tengu)
								usr << "You <font color='green'>display</font color> your wings."
							else if(usr.Bull)
								usr << "You <font color='green'>display</font color> your horns."
							else
								usr << "You <font color='green'>display</font color> your tail."
					if("Trait Color")
						var/Color=input(usr,"Choose color") as color|null
						usr.Trait_Color=Color

				usr.Hairz("Remove")
				usr.Hairz("Add")