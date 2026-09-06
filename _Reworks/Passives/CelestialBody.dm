passiveInfo/CelestialBody
    setLines()
        lines = list("Celestial Body makes it so that when your character's health does not contribute to their BP penalties.",
        "This extends to BP Wounds / BP Poison, as well as Maims.");

mob/proc
    hasCelestialBody()
        if(passive_handler.Get("CelestialBody")) return 1;
        return 0;