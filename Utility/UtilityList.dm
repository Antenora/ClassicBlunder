/proc/isLastItemInList(var/check, var/list/masterList)//or mistress list, if you're a freak
    if(check == masterList[masterList.len]) return 1;
    return 0;