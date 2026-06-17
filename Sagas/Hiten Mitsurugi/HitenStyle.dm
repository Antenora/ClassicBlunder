#define MAXED_SAGA_STYLE_ADD 4
#define SAGA_TIERS 7

/obj/Skills/Buffs/NuStyle/SwordStyle/Hiten_Mitsurugi_Ryuu
	Copyable=0
	SagaSignature=1
	StyleStr=1
	StyleSpd=1
	StyleOff=1
	StyleActive="Hiten Mitsurugi"
	Mastery=4
	ClassNeeded = list("Light", "Wooden")
	Finisher="/obj/Skills/Queue/Finisher/Flash_Strike"
	adjust(mob/p)
		var/maximumValue = MAXED_SAGA_STYLE_ADD;
		StyleStr = 1 + ((maximumValue / SAGA_TIERS) * p.SagaLevel);
		StyleSpd = 1 + ((maximumValue / SAGA_TIERS) * p.SagaLevel);
		StyleOff = 1 + ((maximumValue / SAGA_TIERS) * p.SagaLevel);

		passives["SuperDash"] = 1 + round(p.SagaLevel / 4);
		passives["DoubleStrike"] = (2 / SAGA_TIERS * p.SagaLevel);
		passives["TripleStrike"] = (1 / SAGA_TIERS * p.SagaLevel);
		passives["BlurringStrikes"] = 2+(p.SagaLevel);
		passives["SlayerMod"] = p.SagaLevel/3
		if(p.SagaLevel>=3) passives["CoolerAfterImages"] = p.SagaLevel
		if(p.SagaLevel>=4) Finisher="/obj/Skills/Queue/Finisher/True_Flash_Strike"
	verb/Hiten_Mitsurugi_Ryuu()
		set hidden=1
		if(!usr.BuffOn(src)) adjust(usr)
		Trigger(usr)