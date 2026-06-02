mob/var/tmp/mob/painSharedSource
mob/var/tmp/painShared
mob/var/tmp/painSharedHits

//pain shared is a static amt of hits that are shared.
globalTracker/var/PAIN_SHARE_HITS = 5

//amt is the % shared. 1 = 1% 10 = 10%, etc.
mob/proc/applyPainShare(mob/source, amt)
	if(!source) return
	painShared = amt
	painSharedSource = source
	painSharedHits = glob.PAIN_SHARE_HITS
	source.painShared = amt
	source.painSharedSource = src
	source.painSharedHits = glob.PAIN_SHARE_HITS

mob/proc/applyPainSharedDamage(val)
	if(!painShared || !painSharedSource) return
	if(painSharedSource.painSharedSource==src)
		painSharedSource.LoseHealth(val * (painShared / 100))
		painSharedHits--
		if(painSharedHits <= 0)
			turnOffPainShared()

mob/proc/turnOffPainShared()
	if(painSharedSource && painSharedSource == src)
		painSharedSource.painSharedSource=null
		painSharedSource.painShared = null
		painSharedSource.painSharedSource = null
	painShared = null
	painSharedSource = null
	painSharedHits = null