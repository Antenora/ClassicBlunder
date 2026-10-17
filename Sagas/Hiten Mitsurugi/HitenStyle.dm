#define MAXED_SAGA_STYLE_ADD 4
#define SAGA_TIERS 7

/obj/Skills/Buffs/NuStyle/SwordStyle/Hiten_Mitsurugi_Ryuu
	SagaSignature=1
	SagaStyle = 1
	StyleActive="Hiten Mitsurugi"
	ClassNeeded = list("Light", "Wooden")
	adjust(mob/p)

		passives["SuperDash"] = 1 + round(p.SagaLevel / 4);
		passives["DoubleStrike"] = (2 / SAGA_TIERS * p.SagaLevel);
		passives["TripleStrike"] = (1 / SAGA_TIERS * p.SagaLevel);
		passives["SlayerMod"] = p.SagaLevel/3
		passives["AfterImages"] = (p.SagaLevel>=3) ? p.SagaLevel : 0
		if(p.SagaLevel>=3) passives["AfterImageSkin"] = "Cooler"
		passives["AsuraStrike"] = (p.SagaLevel>=7) ? 1 : 0
		var/tradition = p.SagaLevel>=4 && (locate(/obj/Skills/Buffs/SlotlessBuffs/Dance_Of_The_Full_Moon) in p)
		if(tradition) passives["DoubleStrike"] += 2
		passives["Reversal"] = tradition ? 0.5 : 0
		passives["Deflection"] = tradition ? 3 : 0
		if(p.CheckSlotless("Battosai")) passives["TripleStrike"] += 0.25 * (p.SagaLevel - 3)
	proc/BattosaiRefresh(mob/p)
		if(!p.passive_handler || p.StyleBuff != src)
			return
		if(current_passives)
			p.passive_handler.decreaseList(current_passives)
		adjust(p)
		current_passives = passives
		p.passive_handler.increaseList(passives)
	verb/Hiten_Mitsurugi_Ryuu()
		set hidden=1
		if(!usr.BuffOn(src)) adjust(usr)
		Trigger(usr)