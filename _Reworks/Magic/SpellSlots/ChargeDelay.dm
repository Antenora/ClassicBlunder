mob/var/tmp/ChargeDelay = 0

globalTracker/var/CHARGE_DELAY_CAP = 5
globalTracker/var/CHARGE_DELAY_MULT = 1
globalTracker/var/CHARGE_DELAY_FALLOFF = 0.05

mob/proc/applyChargeDelay(amt)
	if(!amt) return
	amt *= glob.CHARGE_DELAY_MULT
	ChargeDelay = clamp(ChargeDelay+amt, 0, glob.CHARGE_DELAY_CAP)

mob/proc/decreaseChargeDelay()
	if(ChargeDelay == 0) return
	ChargeDelay = clamp(ChargeDelay - glob.CHARGE_DELAY_FALLOFF, 0, glob.CHARGE_DELAY_CAP)