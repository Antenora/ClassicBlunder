globalTracker/var
    PUPPETEER_BODY_DRAIN = 0.1;

passiveInfo/PuppeteerBody
    setLines()
        lines = list("PuppeteerBody makes it so that if the user would ever suffer an attack delay that impacts them negatively, they void that negative consequence at the cost of additional energy.",
    "The drain is [glob.outputVariableInfo("PUPPETEER_BODY_DRAIN")]% energy drained per 1 attack delay voided.");

mob/proc
    hasPuppeteerBody()
        if(passive_handler.Get("PuppeteerBody")) return 1;
        return 0;

mob/proc
    getPuppeteerBodyDelay(initialDelay, increasedDelay)
        var/diff = increasedDelay - initialDelay;
        var/cost = diff * glob.PUPPETEER_BODY_DRAIN;
        if(Energy > cost)
            LoseEnergy(cost);
            return initialDelay;
        return increasedDelay;