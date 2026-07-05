globalTracker/var
    ATTACK_SPEED_EPT = 0.2;//25% attack speed Effect Per Tick
    ATTACK_SPEED_MIN = -4;
    ATTACK_SPEED_MAX = 8;

passiveInfo/AttackSpeed
    setLines()
        lines = list("Adjusts your Attack Delay. Positive numbers mean a faster delay, and negative numbers mean a slower delay.",\
"Each tick of the passive is worth [glob.outputVariableInfo("ATTACK_SPEED_EPT")]% modification of your Attack Delay.",\
"Minimum number of ticks: [glob.outputVariableInfo("ATTACK_SPEED_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("ATTACK_SPEED_MAX")]");

mob/proc/
    getAttackSpeedValue()
        . = 1;
        . /= (1+(getAttackSpeed()*glob.ATTACK_SPEED_EPT));
    getAttackSpeed()
        . = passive_handler.Get("AttackSpeed");
        . = clamp(., glob.ATTACK_SPEED_MIN, glob.ATTACK_SPEED_MAX);
