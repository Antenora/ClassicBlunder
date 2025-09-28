/globalTracker/var/RANKINGTEXT = "ranking_tier ranking_number DIVER."
/globalTracker/var/TITLETEXT = "Also Known As... "
/globalTracker/var/TITLEFORMAT = " '_title_', "

//TODO: prob remove as well, dunno if this is being kept
characterInformation
    var/rankingTier = ""
    var/rankingNumber = ""
    var/list/title = list()

    //ranking tier = "Top Ranker", "Ranker" , "Rookie"
    //ranking number = "1-100+""
    //title = "Heavenly Demonic Beast", "Demon King", "The Unkillable Demon", etc.

    proc/resetRanking()
        setRankingTier("")
        setRankingNumber("")

    proc/addTitle(newTitle,hex)
        title += "<font color=[hex]>[newTitle]</font>"

    proc/getInfo()
        if(rankingTier != "" || rankingNumber != "")
            var/content = "[glob.RANKINGTEXT]\n"
            content = replacetext(content, "ranking_tier", rankingTier )
            content = replacetext(content, "ranking_number", rankingNumber )
            if(length(title)>0)
                content += "[glob.TITLETEXT]"
                var/xLimit = 4
                var/curX = 0
                for(var/x in title)
                    x = replacetext(glob.TITLEFORMAT, "_title_" , x)
                    if(curX < xLimit)
                        content += "[x]"
                        curX++
                    else
                        content += "\n"
                        curX = 0
                        content += "[x]"
            return content

    proc/setRankingTier(newRankingTier)
        rankingTier = newRankingTier

    proc/setRankingNumber(newRankingNumber)
        rankingNumber = newRankingNumber

    proc/setTitle(newTitle)
        title = list(newTitle)