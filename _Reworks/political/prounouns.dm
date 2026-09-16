


/mob/proc/subjectpronoun()
	if(!client) return "It"
	if(!information.pronouns[1])
		information.setDefaultPronouns()
	return information.pronouns[1]

/mob/proc/objectpronoun()
	if(!client) return "It"
	if(!information.pronouns[2])
		information.setDefaultPronouns()
	return information.pronouns[2]

/mob/proc/possessivepronoun()
	switch(information.pronouns[1])
		if("He")
			return "His"
		if("She")
			return "Her"
		if("They")
			return "Their"
		if("It")
			return "Its"
/globalTracker/var/MAXCATCHLINELENGTH = 40

characterInformation
	var/list/pronouns = list("He","Him")
	var/seePronouns = TRUE
	var/catchline = "I am not a broke boy..."
	proc/setCatchLine()
		var/max_length = glob.MAXCATCHLINELENGTH
		var/inP = Ask(usr, "What is your catchline?", "", null, "text", null, 1)
		if(length(inP) > max_length)
			usr << "too long, try again"
		else
			catchline = inP
	proc/setDefaultPronouns()
		switch(usr.Gender)
			if("Male")
				pronouns = list(SUBJECT_PRONOUNS[1],OBJECT_PRONOUNS[1])
			if("Female")
				pronouns = list(SUBJECT_PRONOUNS[2],OBJECT_PRONOUNS[2])
			if("neuter")
				pronouns = list("It","It")
	proc/setPronouns(firsttime)
		if(usr.client.getPref("usePronouns") == 1)
			if(firsttime)
				var/yesno = Ask(usr, "Do you want different pronouns than your selected sex?", "", null, "pick", list("Yes", "No", "Never Ask Me"), 0)
				if(yesno == "No")
					switch(usr.Gender)
						if("Male")
							pronouns = list(SUBJECT_PRONOUNS[1],OBJECT_PRONOUNS[1])
						if("Female")
							pronouns = list(SUBJECT_PRONOUNS[2],OBJECT_PRONOUNS[2])
						if("neuter")
							pronouns = list("It","It")
				else
					if(yesno == "Yes")
						var/subject = Ask(usr, "What is your subject pronoun? (He, She, They, It)", "", null, "pick", SUBJECT_PRONOUNS, 0)
						var/object = Ask(usr, "What is your object pronoun? (Him, Her, Them, It)", "", null, "pick", OBJECT_PRONOUNS, 0)
						pronouns = list(subject, object)
					if(yesno == "Never Ask Me")
						usr.client.setPref("usePronouns", 0)
				if(usr.client.getPref("seePronouns") == null)
					yesno = Ask(usr, "Do you want to see other's pronouns?", "", null, "pick", list("Yes", "No"), 0)
					yesno = yesno == "Yes" ? TRUE : FALSE
					usr.client.setPref("seePronouns", yesno)
			else
				var/subject = Ask(usr, "What is your subject pronoun? (He, She, They, It)", "", null, "pick", SUBJECT_PRONOUNS, 0)
				var/object = Ask(usr, "What is your object pronoun? (Him, Her, Them, It)", "", null, "pick", OBJECT_PRONOUNS, 0)
				pronouns = list(subject, object)
		else
			switch(usr.Gender)
				if("Male")
					pronouns = list(SUBJECT_PRONOUNS[1],OBJECT_PRONOUNS[1])
				if("Female")
					pronouns = list(SUBJECT_PRONOUNS[2],OBJECT_PRONOUNS[2])
				if("neuter")
					pronouns = list("It","It")
	proc/seeOthersPronouns()
		usr.client.setPref("seePronouns", !usr.client.prefs.seePronouns)
		usr<<"[usr.client.getPref("seePronouns") ? "You can now see other people's pronouns." : "You can no longer see other people's pronouns."]"


/mob/verb/Toggle_Pronouns()
	set category = "Other"
	set hidden = 1
	information.seeOthersPronouns()
/mob/verb/Toggle_Ask_Pronoun()
	usr.client.setPref("usePronouns", !usr.client.prefs.usePronouns)
/mob/verb/Change_Pronouns()
	set category = "Other"
	set hidden = 1
	information.setPronouns(FALSE)
	usr<<"[information.pronouns[1]]/[information.pronouns[2]] are now your pronouns."

/mob/verb/Set_Catchline()
	set category = "Other"
	set hidden = 1
	information.setCatchLine()
