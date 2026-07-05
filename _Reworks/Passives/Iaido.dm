//TODO: This passive is actually not being used. Lmao. Lol.
//Most instances of this should be replaced with Iaijutsu except for Flying Thunder God
globalTracker/var
    IAIDO_EPT = 1;//Accumulates 1 extra IaidoGauge per tick
    IAIDO_MIN = 0;
    IAIDO_MAX = 20;

passiveInfo/Iaido
    setLines()
        lines = list("This passive performs what is essentially a free Zanzoken attack (with possible extra goodies!) once enough time has elapsed to fill the Iaido gauge.",\
"The Iaido attack will happen when the Iaido counter reaches 100. Each tick of this passive makes this gauge fill by (the number of ticks) points, per second.",\
"Minimum number of ticks: [glob.outputVariableInfo("IAIDO_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("IAIDO_MAX")]");
    setBalanceNote()
        balanceNote = "Surprisingly, this passive is distinct from Iaijutsu, which is entirely different."

mob/proc/
    getIaidoValue()
        . = getIaido();
    getIaido()
        . = passive_handler.Get("Iaido");
        . = clamp(., glob.IAIDO_MIN, glob.IAIDO_MAX);
