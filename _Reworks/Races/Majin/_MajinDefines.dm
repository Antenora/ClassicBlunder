#define BALANCED_RATE 0.25
#define FULL_RATE 0.5
#define LOW_RATE 0.15
#define MAJIN_MAX_ASCENSION 5
#define MAJIN_BLOB_DROP_THRESHOLD 15 // WHEN 50% OF HEALTH IS TAKEN AWAY, DROP A BLOB THIS IS LOWERED BY ASCEN
#define MAJIN_BLOB_DROP_RATE 0.15 // 10% CHANCE TO DROP A BLOB INCREASED BY ASCEN
#define MAX_BLOBS 2 // MAX BLOBS PER MAJIN INCREASED BY ASCEN

#define MAJIN_ABSORB_LIMIT 2 // MAX NUMBER OF ABSORBTIONS
#define MAJIN_PASSIVE_LIMIT 0.5 // MAX NUMBER OF TICKS ON A PASSIVE
#define MAJIN_ABSORB_TAX 2 // AN ADDITONAL 2 STAT TAX PER ASCENSION

blobDropper
    var/list/blobList = list()
    var/numBlobs = 0
    var/numBlobsMax = MAX_BLOBS
    var/blobDropRate = MAJIN_BLOB_DROP_RATE
    var/dropThreshold = MAJIN_BLOB_DROP_THRESHOLD

    New(mob/Players/p)
        if(!p.isRace(MAJIN))
            del(src)
            p<<"You are not a Majin!"
            return
        var/ascen = p.AscensionsAcquired
        blobList = list()
        numBlobs = 0
        numBlobsMax = MAX_BLOBS + getMaxBlobs(ascen)
        blobDropRate = MAJIN_BLOB_DROP_RATE + getDropRate(ascen)
        dropThreshold = MAJIN_BLOB_DROP_THRESHOLD - getDropThreshold(ascen)
majinAbsorb/New(mob/Players/p)
    if(p)
        if(!p.isRace(MAJIN))
            del(src)
            p<<"You are not a Majin!"
            return
        updateVariables(p)
/**
 * DEBUG VERBS
 * TESTING BLOBDROPPER
 *
 */
/mob/var/tmp/blobDropper/majinPassive = null
/mob/var/majinAbsorb/majinAbsorb = null