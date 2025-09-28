


var/list/redactedwords = list()

/mob/Admin4/verb/RedactWord()
    var/word = input("Word to redact: ") as text
    if(!length(redactedwords) < 1)
        redactedwords = list()
    if(word in redactedwords)
        redactedwords -= word
        usr << "Removed word from redacted list."
    else
        redactedwords += word
        usr << "Added word to redacted list."

mob/proc/redactBannedWords(text)
    if(length(redactedwords) < 1)
        redactedwords = list()
    for(var/x in redactedwords)
        text = replacetext(text, x, "\[REDACTED\]")
    return text