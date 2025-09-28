/mob/verb/View_Current_Passives()
    set category = "Other"
    var/html = "<html><body bgcolor=#000000 text=#339999><b>Current Passives:</b><br>"
    for(var/passive in passive_handler.passives)
        if(passive_handler.passives[passive])
            html += "<b>[passive] : [passive_handler.passives[passive]]</b><br>"
    html += "</body></html>"
    src<<browse(html,"window=[src]'s Passives;size=450x600")