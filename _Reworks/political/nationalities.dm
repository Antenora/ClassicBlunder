#define FILTER_LIST list("http","http://","https","2g1c","2 girls 1 cup","acrotomophilia","alabama hot pocket","alaskan pipeline","anal","anilingus","anus","apeshit","arsehole","ass","asshole","assmunch","auto erotic","autoerotic","babeland","baby batter","baby juice","ball gag","ball gravy","ball kicking","ball licking","ball sack","ball sucking","bangbros","bangbus","bareback","barely legal","barenaked","bastard","bastardo","bastinado","bbw","bdsm","beaner","beaners","beaver cleaver","beaver lips","beastiality","bestiality","big black","big breasts","big knockers","big tits","bimbos","birdlock","bitch","bitches","black cock","blonde action","blonde on blonde action","blowjob","blow job","blow your load","blue waffle","blumpkin","bollocks","bondage","boner","boob","boobs","booty call","brown showers","brunette action","bukkake","bulldyke","bullet vibe","bullshit","bung hole","bunghole","busty","butt","buttcheeks","butthole","camel toe","camgirl","camslut","camwhore","carpet muncher","carpetmuncher","chocolate rosebuds","cialis","circlejerk","cleveland steamer","clit","clitoris","clover clamps","clusterfuck","cock","cocks","coprolagnia","coprophilia","cornhole","coon","coons","creampie","cum","cumming","cumshot","cumshots","cunnilingus","cunt","darkie","date rape","daterape","deep throat","deepthroat","dendrophilia","dick","dildo","dingleberry","dingleberries","dirty pillows","dirty sanchez","doggie style","doggiestyle","doggy style","doggystyle","dog style","dolcett","domination","dominatrix","dommes","donkey punch","double dong","double penetration","dp action","dry hump","dvda","eat my ass","ecchi","ejaculation","erotic","erotism","escort","eunuch","fag","faggot","fecal","felch","fellatio","feltch","female squirting","femdom","figging","fingerbang","fingering","fisting","foot fetish","footjob","frotting","fuck","fuck buttons","fuckin","fucking","fucktards","fudge packer","fudgepacker","futanari","gangbang","gang bang","gay sex","genitals","giant cock","girl on","girl on top","girls gone wild","goatcx","goatse","god damn","gokkun","golden shower","goodpoop","goo girl","goregasm","grope","group sex","g-spot","guro","hand job","handjob","hard core","hardcore","hentai","homoerotic","honkey","hooker","horny","hot carl","hot chick","how to kill","how to murder","huge fat","humping","incest","intercourse","jack off","jail bait","jailbait","jelly donut","jerk off","jigaboo","jiggaboo","jiggerboo","jizz","juggs","kike","kinbaku","kinkster","kinky","knobbing","leather restraint","leather straight jacket","lemon party","livesex","lolita","lovemaking","make me come","male squirting","masturbate","masturbating","masturbation","menage a trois","milf","missionary position","mong","motherfucker","mound of venus","mr hands","muff diver","muffdiving","nambla","nawashi","negro","neonazi","nigga","nigger","nig nog","nimphomania","nipple","nipples","nsfw","nsfw images","nude","nudity","nutten","nympho","nymphomania","octopussy","omorashi","one cup two girls","one guy one jar","orgasm","orgy","paedophile","paki","panties","panty","pedobear","pedophile","pegging","penis","phone sex","piece of shit","pikey","pissing","piss pig","pisspig","playboy","pleasure chest","pole smoker","ponyplay","poof","poon","poontang","punany","poop chute","poopchute","porn","porno","pornography","prince albert piercing","pthc","pubes","pussy","queaf","queef","quim","raghead","raging boner","rape","raping","rapist","rectum","reverse cowgirl","rimjob","rimming","rosy palm","rosy palm and her 5 sisters","rusty trombone","sadism","santorum","scat","schlong","scissoring","semen","sex","sexcam","sexo","sexy","sexual","sexually","sexuality","shaved beaver","shaved pussy","shemale","shibari","shit","shitblimp","shitty","shota","shrimping","skeet","slanteye","slut","s&m","smut","snatch","snowballing","sodomize","sodomy","spastic","spic","splooge","splooge moose","spooge","spread legs","spunk","strap on","strapon","strappado","strip club","style doggy","suck","sucks","suicide girls","sultry women","swastika","swinger","tainted love","taste my","tea bagging","threesome","throating","thumbzilla","tied up","tight white","tit","tits","titties","titty","tongue in a","topless","tosser","towelhead","tranny","tribadism","tub girl","tubgirl","tushy","twat","twink","twinkie","two girls one cup","undressing","upskirt","urethra play","urophilia","vagina","venus mound","viagra","vibrator","violet wand","vorarephilia","voyeur","voyeurweb","voyuer","vulva","wank","wetback","wet dream","white power","whore","worldsex","wrapping men","wrinkled starfish","xx","xxx","yaoi","yellow showers","yiffy","zoophilia")

characterInformation
    var/nationality = "Redian"
    var/secondNationality = FALSE
    proc/setNationality(mob/p)
        nationality = input(p, "What nationality are you?") in glob.NATIONALITIES
        if(glob.ALLOW_OTHER_NATIONALITIES)
            if(nationality == "Other")
                var/tempNationality = input(p, "What nationality?") as text
                nationality = 0
                while(nationality == 0)
                    if(length(tempNationality) >= 20)
                        p << " too long "
                    else
                        nationality = tempNationality
                    if(lowertext(tempNationality) in FILTER_LIST)
                        world<<"[p.ckey] has been booted for using a word found in <a href='https://github.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/blob/master/en'>a bad words list</a>"
                        del usr
                    tempNationality = input(p, "What nationality?") as text

                if(!(nationality in DEDICATED_NATIONALITIES))
                    usr<<"Your nationality has been set to [nationality], however it is not in the dedicated list of nationalities and as such, the admins have been alerted."
                    for(var/mob/admin in admins)
                        admin<<"[p]([p.ckey]) has set their nationality to [nationality], please edit it if it is incorrect."
        if(glob.ALLOW_SECOND_NATIONALITIES)
            var/yesno = input(p, "Do you have a second nationality?") in list("Yes", "No")
            if(yesno == "Yes")
                secondNationality = input(p, "What is your second nationality?") in glob.NATIONALITIES - nationality
                if(glob.ALLOW_OTHER_NATIONALITIES)
                    if(secondNationality == "Other")
                        var/tempsecondNationality = input(p, "What nationality?") as text
                        secondNationality = 0
                        while(secondNationality == 0 )
                            if(lowertext(secondNationality) in FILTER_LIST)
                                world<<"[p.ckey] has been booted for using a word found in <a href='https://github.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/blob/master/en'>a bad words list</a>"
                                del usr
                            if(secondNationality == nationality)
                                secondNationality = 0
                            if(length(tempsecondNationality) >= 20)
                                p << " too long "
                            else
                                secondNationality = tempsecondNationality
                            tempsecondNationality = input(p, "What nationality?") as text
                        if(!(secondNationality in DEDICATED_NATIONALITIES))
                            usr<<"Your nationality has been set to [nationality], however it is not in the dedicated list of nationalities and as such, the admins have been alerted."
                            for(var/mob/admin in admins)
                                admin<<"[usr]([usr.ckey]) has set their second nationality to [secondNationality], please edit it if it is incorrect."
        else
            secondNationality = FALSE


/mob/proc/getNationalityInformation()
    . = "of [information.nationality]"
    if(information.secondNationality != FALSE)
        . += " and [information.secondNationality] descent."
    else
        . += " descent."
