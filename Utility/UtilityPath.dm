//This proc is used in ViewPassives.dm to fetch a name for each datum
/proc/findLastSlash(path)
    var/lastPos;
    var/pos=findtext(path, "/");
    while(pos)
        lastPos=pos;
        pos=findtext(path, "/", pos+1);
    if(lastPos) return (lastPos+1);//we want to skip over that last slash, probably
    return 0;