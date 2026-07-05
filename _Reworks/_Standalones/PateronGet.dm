// so basically, maintain a json of people who donate and their tier
// if i want to, i can make something that contacts the server and updates it when new people pledge
// but for now, i'll just manually update it
var/donationInformation/donationInformation = new/donationInformation
/*
/mob/verb/Donate()
    set category = "Options"
    set name = "Donate"
    usr << "If you want to donate, you can do so at <a href='[PATREON_LINK]'>Patreon</a> or <a href='[KO_FI_LINK]'>Ko-Fi</a>."


/mob/verb/useDonator()
    set name = "Toggle Use Donator"
    set category = "Options"
    client.setPref("useDonator", 1)
    client.setPref("useSupporter",0)
    src << "You will now use your donator benefits instead of your supporter benefits (if you have any)."

/mob/verb/useSupporter()
    set name = "Toggle Use Supporter"
    set category = "Options"
    client.setPref("useDonator", 0)
    client.setPref("useSupporter",1)
    src << "You will now use your supporter benefits instead of your donator benefits (if you have any)."

/mob/verb/toggleLoginMessage()
    set name = "Toggle Login Message"
    set category = "Options"
    if(client.getPref("disableLoginAlert"))
        client.setPref("disableLoginAlert", 0)
        src << "You will no longer make a message upon login (if you could before)."
    else
        client.setPref("disableLoginAlert", 1)
        src << "You will now make a message upon login (if you could before)."


/mob/Admin5/verb/viewDonators()
    var/donators = donationInformation.getDonators()
    for(var/donator/donator in donators)
        usr << "Name: [donator.name] Key: [donator.key] Tier: [donator.tier] Login Message: [donator.loginMessage] Display Key: [donator.displayKey]"

/mob/Admin5/verb/viewSupporters()
    var/supporters = donationInformation.getSupporters()
    for(var/supporter/supporter in supporters)
        usr << "Name: [supporter.name] Key: [supporter.key] Tier: [supporter.tier] Login Message: [supporter.loginMessage] Display Key: [supporter.displayKey]"
*/


donationInformation
    var/list/Supporters = list()
    var/list/Donators = list()
    New()
        Update()
    proc/checkIfAlive()
        if(length(Supporters) == 0)
            world.log << "No supporters found...Updating."
            Update()
        if(length(Donators) == 0)
            world.log << "No donators found...Updating."
            Update()


    proc/addDonator(name, amount, json)
        var/donator/donator = new/donator
        if(!json)
            donator.key = name
            donator.tier = amount
        else
            donator.name = json["name"]
            donator.tier = json["donatorTier"]
            donator.key = json["key"]
            donator.loginMessage = json["loginMessage"]
            donator.displayKey = json["displayKey"]
        Donators += donator

    proc/addSupporter(name, amount, json)
        var/supporter/supporter = new/supporter
        if(!json)
            supporter.key = name
            supporter.tier = amount
        else
            supporter.name = json["name"]
            supporter.key = json["key"]
            supporter.tier = json["supportTier"]
            supporter.loginMessage = json["loginMessage"]
            supporter.displayKey = json["displayKey"]

        Supporters += supporter

    proc/getDonators()
        return Donators

    proc/getSupporters()
        return Supporters

    proc/getDonator(name, key)
        // refresh the donator json
        for(var/donator/donator in Donators)
            if(donator.name == name)
                donator.Update()
                return donator
            if(donator.key == key)
                donator.Update()
                return donator
        return null

    proc/getSupporter(name, key)
        for(var/supporter/supporter in Supporters)
            if(supporter.name == name)
                supporter.Update()
                return supporter
            if(supporter.key == key)
                supporter.Update()
                return supporter
        return null

    proc/findSupporter(key)
        for(var/supporter/supporter in Supporters)
            if(supporter.key == key)
                return supporter
        return null
    proc/findDonor(key)
        for(var/donator/donator in Donators)
            if(donator.key == key)
                return donator
        return null

    Update()/*
        var/info = grabJsonData()
        for(var/tier in info["Donators"])
            for(var/donator in info["Donators"][tier])
                if(!getDonator(key = donator))
                    addDonator(donator, tier, info["Information"][donator])
                else
                    var/donator/donatorr = findDonor(key = donator)
                    donatorr.tier = tier
                    donatorr.loginMessage = info["Information"][donator]["loginMessage"]
                    donatorr.displayKey = info["Information"][donator]["displayKey"]
        for(var/tier in info["Supporters"])
            for(var/supporter in info["Supporters"][tier])
                if(!getSupporter(key = supporter))
                    addSupporter(supporter, tier, info["Information"][supporter])
                else
                    var/supporter/supporterr = findSupporter(key = supporter)
                    supporterr.tier = tier
                    supporterr.loginMessage = info["Information"][supporter]["loginMessage"]
                    supporterr.displayKey = info["Information"][supporter]["displayKey"]
*/
donator
    var/name = ""
    var/byondKey = ""
    var/tier = 0
    var/loginMessage = ""
    var/displayKey = ""
    var/key = ""

    proc/getTier()
        return text2num(tier)

    Update()/*
        var/info = grabJsonData()
        for(var/tier in info["Donators"])
            for(var/donator in info["Donators"][tier])
                if(donator == key)
                    var/json = info["Information"][donator]
                    name = json["name"]
                    tier = json["donatorTier"]
                    loginMessage = json["loginMessage"]
                    displayKey = json["displayKey"]
                    key = donator
                    return*/

supporter
    var/name = ""
    var/byondKey = ""
    var/tier = 0
    var/loginMessage = ""
    var/displayKey = ""
    var/key = ""

    proc/getTier()
        return text2num(tier)

    Update()/*
        var/info = grabJsonData()
        for(var/tier in info["Supporters"])
            for(var/supporter in info["Supporters"][tier])
                if(supporter == key)
                    name = info["Information"][supporter]["name"]
                    tier = info["Information"][supporter]["supportTier"]
                    loginMessage = info["Information"][supporter]["loginMessage"]
                    displayKey = info["Information"][supporter]["displayKey"]
                    key = supporter
                    return*/



/proc/grabJsonData()
    var/jsonData = file('supporterinfo.json')
    jsonData = file2text(jsonData)
    return json_decode(jsonData)





// /mob/Admin4/verb/AddDonator(mob/p in world)
//     vardonator/donator = newdonator
//     donator.name = input(src, "Name of donator?") as text
//     donator.key = p.key
//     donator.tier = tier
//     donator.loginMessage = loginMessage
//     donator.displayKey = displayKey
//     donationInformation.addDonator(name, tier, null)
//     usr << "Added donator [name] with key [key] and tier [tier]."
//     // somehow save the json !!

