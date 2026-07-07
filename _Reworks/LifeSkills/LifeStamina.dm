mob/var/LifeStamina = LIFE_STAMINA_MAX
mob/var/LifeStaminaLastRefill = 0
mob/var/LifeCapstoneGemDay = -1   // DaysOfWipe stamp of the last Prospector's Instinct use
mob/var/LifeLegendaryForgeDay = -1   // the anvil answers once a day
mob/var/LifeTrophyDay = -1   // Trophy Extraction stamp (Hunting capstone)
mob/var/tmp/LifeGemArmed = 0

mob/proc/CheckLifeStaminaRefill()
	var/today = DaysOfWipe()
	if(LifeStaminaLastRefill < today)
		LifeStamina = LIFE_STAMINA_MAX
		LifeStaminaLastRefill = today

mob/proc/UseLifeStamina(cost)
	CheckLifeStaminaRefill()
	if(LifeStamina < cost)
		src << "You're too worn out for more life skill work today. ([LifeStamina]/[LIFE_STAMINA_MAX] Life Stamina, refills daily)"
		return FALSE
	LifeStamina -= cost
	if(client) client.RefreshLifeSkillsPage()
	return TRUE
