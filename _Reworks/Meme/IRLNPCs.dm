/mob/irlNPC
    Lat
        icon = 'Icons/irlNPCs/lat.dmi'
        profession = "Street Vendor / Streamer"
        newName = "JustLat"
        sayings = list("im main character", "gets shoved to the ground and cries", "smirks", "are you telling me my limits?", "i can fix her", \
        "ill explain my power in a minute because that only makes it stronger", "I AM THE PROTAGONIST OF MY OWN STORY", "is it wrong to have self-confidence?", \
        "what da hell", "erm what the freak?", "hey lol", "i punch etro through several buildings and follow up by hammering both of my fists into their skull only to blast them into the ground")
        raresaying =list("you silly little gay", "anybody wanna share lunch...", "does things to your body in 0.000284712 seconds...",\
        "look man i ahvent felt the touch of a woman in almost a year im desperate", "WAKE UP ETRO", "I CAN CALL MYSELF WHATEVER I WANT", "you havent seen anything weird just yet", \
        "i love catgirls", "ur tearing this family apart, jordan", "Hey, didn't this happen in a DBR wipe?")
        mugshot = 'Icons/irlNPCs/latMugshot.dmi'


    Etro
        icon = 'Icons/irlNPCs/etro.dmi'
        mugshot = 'Icons/irlNPCs/blankMugshot.dmi' // 'Icons/irlNPCs/etroMugshot.dmi'
        profession = "??? / Entity"
        newName = "Etro"
        sayings = list(, "I don't like to be touched by people who don't have money", \
        "Idk how aggressively gay Ashton is sometimes hits me like one of those gay guys in the closet except another gay guy accused them due to having an experience together and now they gotta be violent with them  to show you their not gay." \
        )
        raresaying = list("I swear Ashton shows up like this talking about something then shoves a pic of a dick or ass in ur face.", \
        "I hate hearing you say this dumb shit, like people don't actually do that already. No. Shut up. Like actually.",  "You don't know wtf ur saying sometimes, youre gonna tell me its a skil lbased game when half of the player base is about abusing players who are weaker while having more skillsa nd shikai shit", \
        )
    Gav
        icon = 'Icons/irlNPCs/gav.dmi'
        profession = "Gremlin"
        newName = "Gav"
        sayings = list("yawn", "hits the griddy", "i miss the old lat", "its 5 am im not here for rhetoric", "i hope silver chips patrick's rock off of a pyramid and drives it over u", "shut up stone dragger", \
        )
        raresaying = list("I WILL MEDITATE ON THIS", "crushes etro's skull in my hands", "its raining.", "grips taco by the throat", "ashton finna be looking like this after the chat is done", \
        "at a certain point your willingness to let a buggy byond game effect you is your fault")
        mugshot = 'Icons/irlNPCs/gavMugshot.dmi'


    Kiril
        icon = 'Icons/irlNPCs/kiril.dmi'
        mugshot = 'Icons/irlNPCs/blankMugshot.dmi'      //'Icons/irlNPCs/kirilMugshot.dmi'
        profession = "Brazilian Hero"
        newName = "Kiril"
        sayings = list("god i hope my future (surely existing) girlfirend never reads these logs oh god oh please... thank god its all in english", \
        "I'll fucking KILL you if you called kaido blue shenron.", "FUCK IT WE BALL", "I'M INVINCIBLE", "i'm killing you", "admins? zap this guy out of this plane of existance in the most excrutiatingly painful way possible", \
        "why would anyone want to learn heroes plot yasa?", "i'm map lead", "its just that i got used to how sr had it (deviously) but if its too fucky wucky i'll make due")
        raresaying = list("look dude as long as i keep existing without recieving a footjob under the pizza hut table from a hatsune miku cosplayer girl i'll literally be aging at 20x speed", \
        "i need a gf that just fucking hates me for no reason at all and is stronger than me so i can not fight back her attempts to kick the shit out of me and--",
        "i'll show you true racism", "kill yourself, you worthless tartless maggot", "i'm not map lead", "Oh ! I cant wait for sr !")

    Silver
        icon = 'Icons/irlNPCs/silver.dmi'
        mugshot = 'Icons/irlNPCs/silverMugshot.dmi'
        profession = "Egyptian Refugee"
        newName = "Silver"
        sayings = list("makes out with u", "my power went out", "that's haram", "i fuckin hate being sweaty!!", \
        "porn is corrupting the youth", "i'm not suicidal sry i'm not a loser", "selling nudes?", "lol slavery is now universal", \
        "imagine getting in a fight with an aligator and the winner gets fed to the loser", "LET ME OUT NIGGA LET ME OUT", \
        "weirdo", "jerks off")
        raresaying = list("i don't have prominent feminine features (lying)", "f**k yourself ******", "there's no difference between slavery and minimum wage jobs", \
        "i hope i die before i get drafted", "etro tries to find a balance between bust size and cuteness lvl", "anal sex is haram", "ur boobs are big jordan")



/mob/irlNPC/Click()
    if(usr.client)
        var/roll = rand(1,100)
        var/theSaying
        if(roll > 90)
            if(roll == 100)
                theSaying = raresaying[raresaying.len]
            else
                theSaying = raresaying[rand(1,raresaying.len)]
        else
            theSaying = sayings[rand(1,sayings.len)]
        usr.client.interfaceHUD.lastUpdate = world.time
        usr?.client.interfaceHUD.displayMugshot(src, usr)
        usr?.client.interfaceHUD.displaySpeechBubble(usr, theSaying)
        usr?.client.interfaceHUD.displayInformationBox(usr, "[newName]<br>[profession]")
        usr?.client.interfaceHUD.setUpVars(src, usr)
        blobLoop += usr.client.interfaceHUD



//** DEBUG VERBS **//

// /mob/verb/testLatNPC()
//     set category = "IRL NPC"
//     var/theType = input(src, "What npc?") in list("Lat", "Silver", "Kiril", "Gav", "Etro")
//     var/path = "/mob/irlNPC/[theType]"
//     new path(src.loc)
//     src << "You have created a [theType] NPC."
