/*

First we want to gather everyone who has made a character to a json list. 

in a format 

usr.name
usr.key

then, we want to make the format to write the said json, and then a html template to read it off of.

*/
obj/readPrayers // we hand this out to the dead instead of a typesof(verb) so that they can see them always. 
	verb/seePrayer()
		set name = "Read Pray"
		set category = "Roleplay"
		usr.ReadPrayers(usr)


mob/proc/gatherNames()
	var/fileName = "Saves/everyName.json"
	var/list/fileText = file2text(file(fileName))
	if(!fexists(file(fileName)))
		text2file("[]", fileName)
		fileText = file2text(file(fileName))
	var/list/alreadyExistingNames = json_decode(fileText)
	
	for(var/byondKey in alreadyExistingNames)
		if(byondKey["key"] == src.key)
			return
	var/newAddition = list(
		list(
			key = src.key,
			name = src.name
		),
	)

	alreadyExistingNames += newAddition
	if(fdel(fileName) == 0)
		src<<"Your name wasn't added properly to the prayer list, please contact awwlie."
		return

	if(text2file(json_encode(alreadyExistingNames, JSON_PRETTY_PRINT), fileName)==0 )
		src<<"Your addition to the prayer list gimped somehow, please contact awwlie."
		return

mob/proc/returnPrayers()
	var/fileName = "Saves/everyPrayer.json"
	var/list/fileText = file2text(file(fileName))
	if(!fexists(file(fileName)))
		text2file("{}", fileName)
		fileText = file2text(file(fileName))
	var/list/alreadyExistingPrayers = json_decode(fileText)

	return alreadyExistingPrayers

mob/proc/returnNames()
	var/fileName = "Saves/everyName.json"
	var/list/fileText = file2text(file(fileName))
	if(!fexists(file(fileName)))
		text2file("{}", fileName)
		fileText = file2text(file(fileName))
	var/list/alreadyExistingNames = json_decode(fileText)

	return alreadyExistingNames



/mob/verb/PrayForTheDeath()
	set name = "Pray"
	set category = "Roleplay"
	// files we want to write to the prayers..
	var/fileName = "Saves/everyPrayer.json"
	var/list/fileText = file2text(file(fileName))
	if(!fexists(file(fileName)))
		text2file("{}", fileName)
		fileText = file2text(file(fileName))
	var/list/alreadyExistingPrayers = json_decode(fileText)	
	/// We want to get all the names, so we can add the mto a list, and use that to select who we wish to pray to... (they should be dead, I think?)
	var/list/names = usr.returnNames()

	var/KeyForWhoThePrayerIs = null

	var/list/nameList4Name= list()
	for(var/god in glob.prayerTargetNames)
		nameList4Name += god
	nameList4Name += "------------"


	for(var/name in names)
		nameList4Name += name["name"]

	var/who = input(usr, "Who is it you wish to pray to?", "Select") in nameList4Name + "------------" + "Cancel"
	if(who == "Cancel" || who == "------------" || who == "-----------")
		return

	for(var/key in names)
		if(key["name"] == who)
			KeyForWhoThePrayerIs = key["key"]
	
	if(KeyForWhoThePrayerIs == null)
		KeyForWhoThePrayerIs = "Nolies"
	
	var/prayer = input(usr, "What do you wish to say to [who]?", "Prayer") as message
	if (!prayer) return
	var/newAddition = list(
		list(
			whoMadePrayer = usr.name,
			whoMadePrayerKey = usr.key,
			whoWasThePrayerAt = who,
			WhoWasThePrayerAtKey = KeyForWhoThePrayerIs,
			Prayer = prayer,
			WhenWasThisDone = time2text(world.timeofday,"MM/DD")
		)
	)	
	alreadyExistingPrayers += newAddition
	if(fdel(fileName) == 0)
		usr<<"Your Prayer Wasn't Saved, Please Contact Awwlie!"
		return
	if(text2file(json_encode(alreadyExistingPrayers, JSON_PRETTY_PRINT),fileName) == 0)
		usr<<"Uh oh... something went wrong with saving this prayer.. contact awwlie!"
		return
		
	if(who in glob.prayerTargetNames)
		for(var/mob/m in admins)
			if(!m.PrayerMute&&m.Admin>2)
				if(who =="Other")
					m << "A prayer reaches your eyes from [usr]...<br>[prayer]"
				else 
					m << "A prayer reaches for [who] from [usr]...<br>[prayer]"

/mob/proc/ReadPrayers(mob/M)
	var/prayerHTML = {"<html>
	<title>[M]'s Prayer Cards</title>
	<style>
		@import url('https://fonts.googleapis.com/css2?family=Crimson+Text:wght@400;700&display=swap');

		body {
			font-family: 'Crimson Text', serif;
			background-color: #f3f3f3;
			color: #333;
			margin: 0;
			padding: 20px;
		}
		.card {
			background-color: #fff;
			border: 2px solid #e0e0e0;
			border-radius: 15px;
			box-shadow: 0 4px 8px rgba(0,0,0,0.1);
			padding: 30px;
			max-width: 600px;
			margin: 40px auto;
			text-align: center;
			position: relative;
		}
		.card:before {
			content: '';
			background: url('https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Cross-Pattee-Heraldry.svg/1024px-Cross-Pattee-Heraldry.svg.png') no-repeat center center;
			background-size: 50px 50px;
			position: absolute;
			top: -40px;
			left: 50%;
			transform: translateX(-50%);
			width: 50px;
			height: 50px;
		}
		.card h1 {
			font-size: 28px;
			margin-bottom: 15px;
			color: #555;
		}
		.card p {
			font-size: 18px;
			margin: 10px 0;
		}
		.card .prayer {
			margin-top: 25px;
			font-style: italic;
			color: #666;
		}
		.divider {
			border-bottom: 2px solid #ddd;
			margin: 20px 0;
		}
		.footer-cross {
			margin-top: 20px;
			width: 30px;
			height: 30px;
		}
	</style>
</head>
"}
	var/Prayers = M.returnPrayers()
	for(var/prays in Prayers)
		if(prays["WhoWasThePrayerAtKey"] == M.key)
			prayerHTML += {"<body>
				<div class="card">
					<h2>A prayer for [prays["whoWasThePrayerAt"]]</h2>
					<div class="divider"></div>
					<p><strong>Date:</strong> [prays["WhenWasThisDone"]]</p>
					<p><strong>Who Did the Prayer:</strong> [prays["whoMadePrayer"]]</p>
					<div class="divider"></div>
					<p class="prayer">[prays["Prayer"]]</p>
				</div>
			</body>

		"}

	prayerHTML += "</html>"
	M << browse(prayerHTML ,"size=600x600,window=Title")

/mob/Admin2/verb/ReadAllPlayerPrayers()
	set name = "Read All Prayers"
	set category = "Admin"
	
	var/prayerHTML = {"<html>
	<title>All Prayers</title>
	<style>
		@import url('https://fonts.googleapis.com/css2?family=Crimson+Text:wght@400;700&display=swap');

		body {
			font-family: 'Crimson Text', serif;
			background-color: #f3f3f3;
			color: #333;
			margin: 0;
			padding: 20px;
		}
		.card {
			background-color: #fff;
			border: 2px solid #e0e0e0;
			border-radius: 15px;
			box-shadow: 0 4px 8px rgba(0,0,0,0.1);
			padding: 30px;
			max-width: 600px;
			margin: 40px auto;
			text-align: center;
			position: relative;
		}
		.card:before {
			content: '';
			background: url('https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Cross-Pattee-Heraldry.svg/1024px-Cross-Pattee-Heraldry.svg.png') no-repeat center center;
			background-size: 50px 50px;
			position: absolute;
			top: -40px;
			left: 50%;
			transform: translateX(-50%);
			width: 50px;
			height: 50px;
		}
		.card h1 {
			font-size: 28px;
			margin-bottom: 15px;
			color: #555;
		}
		.card p {
			font-size: 18px;
			margin: 10px 0;
		}
		.card .prayer {
			margin-top: 25px;
			font-style: italic;
			color: #666;
		}
		.divider {
			border-bottom: 2px solid #ddd;
			margin: 20px 0;
		}
		.footer-cross {
			margin-top: 20px;
			width: 30px;
			height: 30px;
		}
	</style>
</head>
"}
	var/Prayers = usr.returnPrayers()
	for(var/prays in Prayers)
		prayerHTML += {"<body>
			<div class="card">
				<h2>A prayer for [prays["whoWasThePrayerAt"]]</h2>
				<div class="divider"></div>
				<p><strong>Date:</strong> [prays["WhenWasThisDone"]]</p>
				<p><strong>Who's prayer is this</strong> [prays["whoMadePrayer"]]</p>
				<div class="divider"></div>
				<p class="prayer">[prays["Prayer"]]</p>
			</div>
		</body>

	"}

	prayerHTML += "</html>"
	usr << browse(prayerHTML ,"size=600x600,window=Title")

/mob/Admin2/verb/CheckOnlyGodPrayers()
	set name = "Read All God Prayers"
	set category = "Admin"
	var/Prayers = usr.returnPrayers()

	var/prayerHTML = {"
	<title>All God Related Prayers</title>
	<style>
		@import url('https://fonts.googleapis.com/css2?family=Crimson+Text:wght@400;700&display=swap');

		body {
			font-family: 'Crimson Text', serif;
			background-color: #f3f3f3;
			color: #333;
			margin: 0;
			padding: 20px;
		}
		.card {
			background-color: #fff;
			border: 2px solid #e0e0e0;
			border-radius: 15px;
			box-shadow: 0 4px 8px rgba(0,0,0,0.1);
			padding: 30px;
			max-width: 600px;
			margin: 40px auto;
			text-align: center;
			position: relative;
		}
		.card:before {
			content: '';
			background: url('https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Cross-Pattee-Heraldry.svg/1024px-Cross-Pattee-Heraldry.svg.png') no-repeat center center;
			background-size: 50px 50px;
			position: absolute;
			top: -40px;
			left: 50%;
			transform: translateX(-50%);
			width: 50px;
			height: 50px;
		}
		.card h1 {
			font-size: 28px;
			margin-bottom: 15px;
			color: #555;
		}
		.card p {
			font-size: 18px;
			margin: 10px 0;
		}
		.card .prayer {
			margin-top: 25px;
			font-style: italic;
			color: #666;
		}
		.divider {
			border-bottom: 2px solid #ddd;
			margin: 20px 0;
		}
		.footer-cross {
			margin-top: 20px;
			width: 30px;
			height: 30px;
		}
	</style>
</head>
"}
	for(var/prays in Prayers)
		if(prays["WhoWasThePrayerAtKey"] == "Nolies")
			prayerHTML += {"<body>
				<div class="card">
					<h2>A prayer for [prays["whoWasThePrayerAt"]]</h2>
					<div class="divider"></div>
					<p><strong>Date:</strong> [prays["WhenWasThisDone"]]</p>
					<p><strong>Who's prayer is this:</strong> [prays["whoMadePrayer"]]</p>
					<div class="divider"></div>
					<p class="prayer">[prays["Prayer"]]</p>
				</div>
			</body>

		"}

	usr << browse(prayerHTML ,"size=600x600,window=Title")