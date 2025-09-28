#define Swordsmanship list("Hiten Mitsurugi-Ryuu","Unlimited Blade Works", "Weapon Soul")
#define SECRETS list("Spirits of The World","Jagan", "Hamon of the Sun", "Werewolf", "Vampire", "Sage Arts", "Haki", "Eldritch", "Heavenly Restriction")
#define SAGAS list("Ansatsuken","Eight Gates","Cosmo","Spiral","Hero","Hiten Mitsurugi-Ryuu","Kamui","Keyblade","King of Braves","Sharingan","Weapon Soul", "Unlimited Blade Works","Force")
#define RACES list("Android", "Human", "Beastman", "Changeling", "Demon", "Dragon", "Eldritch","Chakardi","Half_Saiyan", "High_Faoroan","Majin","Makyo","Namekian","Saiyan","Shinjin","Yokai")

mob
	proc
		HasPassive(var/Passive, var/BuffsOnly=0, var/SwordBuff=0, var/StaffBuff=0, var/NoMobVar=0, var/NoAttackQueue=0)
			if(src.StanceBuff)
				if(src.StanceBuff.vars["[Passive]"])
					return 1
			if(src.StyleBuff)
				if(src.StyleBuff.vars["[Passive]"])
					return 1
			if(src.ActiveBuff)
				if(src.ActiveBuff.vars["[Passive]"])
					return 1
			if(src.SpecialBuff)
				if(src.SpecialBuff.vars["[Passive]"])
					return 1
			for(var/sb in SlotlessBuffs)
				var/obj/Skills/Buffs/SlotlessBuffs/b = SlotlessBuffs[sb]
				if(b)
					if(b.vars["[Passive]"])
						return 1
			if(!BuffsOnly && !NoAttackQueue)
				if(src.AttackQueue)
					if(src.AttackQueue.vars["[Passive]"])
						return 1
			if(SwordBuff||StaffBuff)
				var/obj/Items/Sword/s=src.EquippedSword()
				var/obj/Items/Enchantment/Staff/st=src.EquippedStaff()
				if(SwordBuff)
					if(s)
						if(s.vars["[Passive]"])
							return 1
				if(StaffBuff)
					if(st)
						if(st.vars["[Passive]"])
							return 1
			else
				if(!NoMobVar)
					if(src.vars["[Passive]"])
						return 1
			return 0
		GetPassive(var/Passive, var/BuffsOnly=0, var/SwordBuff=0, var/StaffBuff=0, var/NoMobVar=0, var/NoAttackQueue=0)
			var/Return=0

			if(SwordBuff)
				var/obj/Items/Sword/s=src.EquippedSword()
				if(s)
					if(s.vars["[Passive]"])
						Return+=s.vars["[Passive]"]
			if(StaffBuff)
				var/obj/Items/Sword/st=src.EquippedStaff()
				if(st)
					if(st.vars["[Passive]"])
						Return+=st.vars["[Passive]"]
			if(!NoMobVar)
				if(src.vars["[Passive]"])
					Return+=src.vars["[Passive]"]
			if(src.StanceBuff)
				if(src.StanceBuff.vars["[Passive]"])
					Return+=src.StanceBuff.vars["[Passive]"]
			if(src.StyleBuff)
				if(src.StyleBuff.vars["[Passive]"])
					Return+=src.StyleBuff.vars["[Passive]"]
			if(src.ActiveBuff)
				if(src.ActiveBuff.vars["[Passive]"])
					Return+=src.ActiveBuff.vars["[Passive]"]
			if(src.SpecialBuff)
				if(src.SpecialBuff.vars["[Passive]"])
					Return+=src.SpecialBuff.vars["[Passive]"]
			for(var/sb in SlotlessBuffs)
				var/obj/Skills/Buffs/SlotlessBuffs/b = SlotlessBuffs[sb]
				if(b)
					if(b.vars["[Passive]"])
						Return+=b.vars["[Passive]"]
			if(!BuffsOnly)
				if(src.AttackQueue && !NoAttackQueue)
					if(src.AttackQueue.vars["[Passive]"])
						Return+=src.AttackQueue.vars["[Passive]"]
			return Return
		GetPassiveCount(var/Passive, var/BuffsOnly=0, var/SwordBuff=0, var/StaffBuff=0, var/NoMobVar=0)
			var/Sources=0
			if(SwordBuff)
				var/obj/Items/Sword/s=src.EquippedSword()
				if(s)
					if(s.vars["[Passive]"])
						Sources+=s.vars["[Passive]"]
			else
				if(!NoMobVar)
					if(src.vars["[Passive]"])
						Sources+=src.vars["[Passive]"]
			if(src.StanceBuff)
				if(src.StanceBuff.vars["[Passive]"])
					Sources+=src.StanceBuff.vars["[Passive]"]
			if(src.StyleBuff)
				if(src.StyleBuff.vars["[Passive]"])
					Sources+=src.StyleBuff.vars["[Passive]"]
			if(src.ActiveBuff)
				if(src.ActiveBuff.vars["[Passive]"])
					Sources+=src.ActiveBuff.vars["[Passive]"]
			if(src.SpecialBuff)
				if(src.SpecialBuff.vars["[Passive]"])
					Sources+=src.SpecialBuff.vars["[Passive]"]
			for(var/sb in SlotlessBuffs)
				var/obj/Skills/Buffs/SlotlessBuffs/b = SlotlessBuffs[sb]
				if(b)
					if(b.vars["[Passive]"])
						Sources+=b.vars["[Passive]"]
			if(!BuffsOnly)
				if(src.AttackQueue)
					if(src.AttackQueue.vars["[Passive]"])
						Sources+=src.AttackQueue.vars["[Passive]"]
			return Sources
		AveragePassive(var/Passive, var/BuffsOnly=0, var/SwordBuff=0, var/StaffBuff=0, var/NoMobVar=0)
			var/Return=0
			var/Sources=0
			if(SwordBuff)
				var/obj/Items/Sword/s=src.EquippedSword()
				if(s)
					if(s.vars["[Passive]"])
						Return+=s.vars["[Passive]"]
						Sources++
			else
				if(!NoMobVar)
					if(src.vars["[Passive]"])
						Return+=src.vars["[Passive]"]
						Sources++
			if(src.StanceBuff)
				if(src.StanceBuff.vars["[Passive]"])
					Return+=src.StanceBuff.vars["[Passive]"]
					Sources++
			if(src.StyleBuff)
				if(src.StyleBuff.vars["[Passive]"])
					Return+=src.StyleBuff.vars["[Passive]"]
					Sources++
			if(src.ActiveBuff)
				if(src.ActiveBuff.vars["[Passive]"])
					Return+=src.ActiveBuff.vars["[Passive]"]
					Sources++
			if(src.SpecialBuff)
				if(src.SpecialBuff.vars["[Passive]"])
					Return+=src.SpecialBuff.vars["[Passive]"]
					Sources++
			for(var/sb in SlotlessBuffs)
				var/obj/Skills/Buffs/SlotlessBuffs/b = SlotlessBuffs[sb]
				if(b)
					if(b.vars["[Passive]"])
						Return+=b.vars["[Passive]"]
						Sources++
			if(!BuffsOnly)
				if(src.AttackQueue)
					if(src.AttackQueue.vars["[Passive]"])
						Return+=src.AttackQueue.vars["[Passive]"]
						Sources++
			Return/=Sources
			Return=round(Return, 0.25)
			return Return
		GetSwordDamage(var/obj/Items/Sword/s)
			var/Total=1
			var/Ascensions=0
			if(s)
				Total=s.DamageEffectiveness
				if(s.InnatelyAscended)
					Ascensions=s.InnatelyAscended
				else
					Ascensions=s.Ascended
				if(src.HasSwordAscension())
					Ascensions+=src.GetSwordAscension()
					// change it to heavy sword damage, fuck it
				if(Ascensions>6)
					Ascensions=6
				if(src.Saga)
					if(src.Saga in Swordsmanship)
						switch(Saga)
							if("Weapon Soul")
								if(src.SagaLevel)
									Ascensions += SagaLevel
							if("Hiten Mitsurugi-Ryuu")
								if(src.SagaLevel)
									Ascensions += SagaLevel
					if(Ascensions>6)
						Ascensions=6
				if(s.Glass)
					Ascensions+=1
				if(s.Conversions=="Sharp")
					Ascensions += (0.1) * s.ShatterTier
			else if(src.CheckSlotless("Excalibur"))
				Total=2
				if(src.HasSwordAscension())
					Ascensions+=src.GetSwordAscension()
					if(Ascensions>6)
						Ascensions=6
			if(src.HasSwordDamageBuff())
				Ascensions+=src.GetSwordDamageBuff()
			Total*=1+(Ascensions*glob.SwordAscDamage)
			return Total
		GetSwordDelay(var/obj/Items/Sword/s)
			var/Total=1
			var/Ascensions=0
			if(s)
				Total=s.SpeedEffectiveness
				Ascensions=s.Ascended
				if(src.HasSwordAscension())
					Ascensions+=src.GetSwordAscension()
					if(Ascensions>6)
						Ascensions=6
				if(src.Saga)
					if(src.Saga in Swordsmanship)
						switch(Saga)
							if("Weapon Soul")
								if(src.SagaLevel)
									Ascensions = SagaLevel
							if("Hiten Mitsurugi-Ryuu")
								if(src.SagaLevel>=3)
									Ascensions += SagaLevel/3
					if(Ascensions>6)
						Ascensions=6
				if(s.Glass)
					Ascensions+=1
				if(s.Conversions=="Light")
					Ascensions+=1
			else if(src.CheckSlotless("Excalibur"))
				Total=0.95
				if(src.HasSwordAscension())
					Ascensions+=src.GetSwordAscension()
					if(Ascensions>6)
						Ascensions=6
			if(src.HasSwordDelayBuff())
				Ascensions+=src.GetSwordDelayBuff()
			Total*=1+(Ascensions*glob.SwordAscDelay)
			return Total
		GetSwordAccuracy(var/obj/Items/Sword/s)
			var/Total=1 - glob.SWORD_GLOBAL_ACCURACY_NERF
			var/Ascensions=0
			if(s)
				Total=s.AccuracyEffectiveness
				Ascensions=s.Ascended
				if(src.HasSwordAscension())
					Ascensions+=src.GetSwordAscension()
					if(Ascensions>6)
						Ascensions=6
				if(src.Saga)
					if(src.Saga in Swordsmanship)
						switch(Saga)
							if("Weapon Soul")
								if(src.SagaLevel)
									Ascensions = SagaLevel
							if("Hiten Mitsurugi-Ryuu")
								if(src.SagaLevel>=3)
									Ascensions += SagaLevel/3
					if(Ascensions>6)
						Ascensions=6
				if(s.Glass)
					Ascensions+=1
				if(s.Conversions=="Hardened")
					Ascensions-=1
			else if(src.CheckSlotless("Excalibur"))
				Total=0.9
				if(src.HasSwordAscension())
					Ascensions+=src.GetSwordAscension()
					if(Ascensions>6)
						Ascensions=6
			if(src.HasSwordAccuracyBuff())
				Ascensions+=src.GetSwordAccuracyBuff()
			Total*=1+(Ascensions*glob.SwordAscAcc)
			return Total
		HasComboMaster()
			if(passive_handler.Get("ComboMaster"))
				return 1
			return 0
		HasSwordAscension()
			if(passive_handler.Get("SwordAscension"))
				return 1
			if(passive_handler.Get("The Way"))
				return 1
			return 0
		GetSwordAscension()
			if(passive_handler.Get("The Way"))
				return glob.MAX_SWORD_ASCENSION
			return passive_handler.Get("SwordAscension")
		HasSwordDamageBuff()
			if(passive_handler.Get("SwordDamage"))
				return 1
			return 0
		GetSwordDamageBuff()
			return passive_handler.Get("SwordDamage")
		HasSwordDelayBuff()
			if(passive_handler.Get("SwordDelay"))
				return 1
			return 0
		GetSwordDelayBuff()
			return passive_handler.Get("SwordDelay")
		HasSwordAccuracyBuff()
			if(passive_handler.Get("SwordAccuracy"))
				return 1
			return 0
		GetSwordAccuracyBuff()
			return passive_handler.Get("SwordAccuracy")
		GetStaffDamage(var/obj/Items/Enchantment/Staff/s)
			var/Total=1
			var/Ascensions=0
			if(s)
				Total=s.DamageEffectiveness
				Ascensions=s.Ascended
				if(src.HasStaffAscension())
					Ascensions+=src.GetStaffAscension()
					if(Ascensions>6)
						Ascensions=6
			Total*=1+(Ascensions*glob.StaffAscDamage)
			return Total
		GetStaffDrain(var/obj/Items/Enchantment/Staff/s)
			var/Total=1
			var/Ascensions=0
			if(s)
				Total=s.SpeedEffectiveness
				Ascensions=s.Ascended
				if(src.HasStaffAscension())
					Ascensions+=src.GetStaffAscension()
					if(Ascensions>4)
						Ascensions=4
			Total*=1+(Ascensions*glob.StaffAscDelay)
			return Total
		GetStaffAccuracy(var/obj/Items/Enchantment/Staff/s)
			var/Total=1 - glob.STAFF_GLOBAL_ACCURACY_NERF
			if(s)
				Total=s.AccuracyEffectiveness
				var/Ascensions=s.Ascended
				if(src.HasStaffAscension())
					Ascensions+=src.GetStaffAscension()
					if(Ascensions>4)
						Ascensions=4
				if(s.Conversions=="Hardened")
					Ascensions-=1
				Total*=1+(Ascensions*glob.StaffAscAcc)
			return Total
		HasStaffAscension()
			if(passive_handler.Get("StaffAscension"))
				return 1
			return 0
		GetStaffAscension()
			return passive_handler.Get("StaffAscension")
		GetArmorDamage(var/obj/Items/Armor/s)
			var/Total=1
			var/Ascensions=0
			if(s)
				Total=s.DamageEffectiveness
				Ascensions=s.Ascended
				if(src.HasArmorAscension())
					Ascensions+=src.GetArmorAscension()
					if(Ascensions>4)
						Ascensions=4
				if(src.HasArmorDamageBuff())
					Ascensions+=src.GetArmorDamageBuff()
			Total*=1+(Ascensions*glob.ArmorAscDamage)
			return Total
		GetArmorDelay(var/obj/Items/Armor/s)
			var/Total=1
			var/Ascensions=0
			if(s)
				Total=s.SpeedEffectiveness
				Ascensions=s.Ascended
				if(src.HasArmorAscension())
					Ascensions+=src.GetArmorAscension()
					if(Ascensions>4)
						Ascensions=4
				if(src.HasArmorDelayBuff())
					Ascensions+=src.GetArmorDelayBuff()
			Total*=1+(Ascensions*glob.ArmorAscDelay)
			return Total
		GetArmorAccuracy(var/obj/Items/Armor/s)
			var/Total=1 - glob.ARMOR_GLOBAL_ACCURACY_NERF
			var/Ascensions=0
			if(s)
				Total=s.AccuracyEffectiveness
				Ascensions=s.Ascended
				if(src.HasArmorAscension())
					Ascensions+=src.GetArmorAscension()
					if(Ascensions>4)
						Ascensions=4
				if(s.Conversions=="Hardened")
					Ascensions-=1
				if(src.HasArmorAccuracyBuff())
					Ascensions+=src.GetArmorAccuracyBuff()
			Total*=1+(Ascensions*glob.ArmorAscAcc)
			return Total
		HasArmorAscension()
			if(passive_handler.Get("ArmorAscension"))
				return 1
			return 0
		GetArmorAscension()
			return passive_handler.Get("ArmorAscension")
		HasArmorDamageBuff()
			if(passive_handler.Get("ArmorDamage"))
				return 1
			return 0
		GetArmorDamageBuff()
			return passive_handler.Get("ArmorDamage")
		HasArmorDelayBuff()
			if(passive_handler.Get("ArmorDelay"))
				return 1
			return 0
		GetArmorDelayBuff()
			return passive_handler.Get("ArmorDelay")
		HasArmorAccuracyBuff()
			if(passive_handler.Get("ArmorAccuracy"))
				return 1
			return 0
		GetArmorAccuracyBuff()
			return passive_handler.Get("ArmorAccuracy")
		HasShatterTier(var/obj/Items/Equip)//this is so fucking stupid, everything should just work off shatter tier
			if(!Equip.Destructable)
				return 0
			if(Equip.ShatterTier)
				return 1
			if(istype(Equip, /obj/Items/Armor))
				return 1
			return 0
		GetShatterTier(var/obj/Items/Equip)//as above
			if(!Equip) return 0
			if(!Equip.Destructable)
				return 0
			var/Total=0
			if(Equip.ShatterTier)
				Total+=Equip.ShatterTier
			if(istype(Equip, /obj/Items/Armor))
				Total+=4-min(Equip.Ascended+src.GetArmorAscension(),4)
			if(Total>4)
				Total=4
			return Total
		HasTensionLock()
			if(passive_handler.Get("TensionLock"))
				return 1
			return 0
		HasEmptyGrimoire()
			if(locate(/obj/Skills/Teleport/Traverse_Void, src))
				return 1
			return 0
		HasElementalDefense(var/ele)
			if(src.ElementalDefense==ele)
				return 1
			if(src.HasArmor())
				var/obj/Items/Armor/a=src.EquippedArmor()
				if(a.Element==ele)
					return 1
			return 0
		HasFakePeace()
			if(passive_handler.Get("FakePeace"))
				return 1
			return 0
		HasDashMaster()
			if(passive_handler.Get("DashMaster"))
				return 1
			return 0
		HasDashCount()
			if(passive_handler.Get("DashCountLimit"))
				return 1
			return 0
		GetDashCount()
			return passive_handler.Get("DashCount")
		IncDashCount()
			if(src.ActiveBuff)
				if(src.ActiveBuff.DashCountLimit)
					src.ActiveBuff.DashCount++
					if(src.ActiveBuff.DashCount>=src.ActiveBuff.DashCountLimit)
						src.ActiveBuff.Trigger()
			if(src.SpecialBuff)
				if(src.SpecialBuff.DashCountLimit)
					src.SpecialBuff.DashCount++
					if(src.SpecialBuff.DashCount>=src.SpecialBuff.DashCountLimit)
						src.SpecialBuff.Trigger()
			for(var/b in SlotlessBuffs)
				var/obj/Skills/Buffs/SlotlessBuffs/sb = SlotlessBuffs[b]
				if(sb)
					if(sb.DashCountLimit)
						sb.DashCount++
						if(sb.DashCount>=sb.DashCountLimit)
							sb.Trigger(src)
			if(!src.HasDashMaster())
				for(var/obj/Skills/Dragon_Dash/dd in src)
					dd.Cooldown=30
				for(var/obj/Skills/Reverse_Dash/rd in src)
					rd.Cooldown=30

		HasAdrenalBoost()
			if(passive_handler.Get("AdrenalBoost"))
				return 1
			return 0
		HasBetterAim()
			if(passive_handler.Get("BetterAim"))
				return 1
			return 0
		GetBetterAim()
			return passive_handler.Get("BetterAim")
		HasMechanized()
			if(isRace(ANDROID))
				return 1
			if(passive_handler.Get("Mechanized"))
				return 1
			if(src.CyberCancel)
				return 1
			return 0
		HasPiloting()
			if(passive_handler.Get("Piloting"))
				return 1
			return 0
		HasPossessive()
			if(passive_handler.Get("Possessive"))
				return 1
			return 0
		TomeSpell(var/obj/Skills/Z)
			if(!Z) return 0
			if(!Z.MagicNeeded) return 0
			var/Streamline=0
			var/obj/Items/Enchantment/Tome/T=src.EquippedTome()
			var/obj/Items/Enchantment/Magic_Crest/MC=src.EquippedCrest()
			if(T)
				for(var/obj/Skills/S in T.Spells)
					if(Z.type==S.type)
						Streamline+=1
			if(is_arcane_beast || CheckSpecial("Wisdom Form") || CheckSpecial("Master Form") || CheckSpecial("Final Form"))
				Streamline+=1
			if(passive_handler.Get("SpiritForm"))
				Streamline+=1
			if(src.UsingMasteredMagicStyle())
				if(Z.ElementalClass)
					if(StyleBuff)
						if(islist(src.StyleBuff.ElementalClass))
							if(Z.ElementalClass in src.StyleBuff.ElementalClass)
								Streamline+=1
						else
							if(src.StyleBuff.ElementalClass==Z.ElementalClass)
								Streamline+=1
				else
					Streamline+=1
			else if(MC)
				for(var/obj/Skills/S in MC.Spells)
					if(Z.type==S.type)
						Streamline+=1
			return Streamline

		CrestSpell(var/obj/Skills/Z)
			var/obj/Items/Enchantment/Magic_Crest/MC=src.EquippedCrest()
			if(MC)
				for(var/obj/Skills/S in MC.Spells)
					if(Z.type==S.type)
						return 1
			return 0

		EquippedTome()
			var/obj/Items/Enchantment/Tome/T
			for(var/obj/Items/Enchantment/Tome/Tomes in src)
				if(Tomes.suffix=="*Equipped*")
					T=Tomes
					return T
			return 0
		EquippedFlyingDevice()
			var/obj/Items/Enchantment/Flying_Device/FD
			for(var/obj/Items/Enchantment/Flying_Device/Fly in src)
				if(Fly.suffix=="*Equipped*")
					FD=Fly
					return FD
			return 0
		EquippedSurfingDevice()
			var/obj/Items/Enchantment/Surfing_Device/SD
			for(var/obj/Items/Enchantment/Surfing_Device/Surf in src)
				if(Surf.suffix=="*Equipped*")
					SD=Surf
					return SD
			return 0
		EquippedCrest()
			var/obj/Items/Enchantment/Magic_Crest/MC
			for(var/obj/Items/Enchantment/Magic_Crest/Crest in src)
				if(Crest.suffix=="*Equipped*")
					MC=Crest
					return MC
			return 0
		ParasiteCrest()
			for(var/obj/Items/Enchantment/Magic_Crest/Crest in src)
				if(Crest==src.EquippedCrest())
					if(Crest.Parasite&&!src.Timeless)
						return 1
			return 0
		HasPlatedWeights()
			var/obj/Items/WeightedClothing/WC=src.EquippedWeights()
			if(WC)
				if(WC.Plated)
					return 1
			return 0
		HasCeramicPlating()
			var/obj/Items/Plating/P=src.EquippedPlating()
			if(istype(P, /obj/Items/Plating/Ceramic_Plating))
				if(P.suffix=="*Broken")
					return 0
				return 1
			return 0
		HasRefractivePlating()
			var/obj/Items/Plating/P=src.EquippedPlating()
			if(istype(P, /obj/Items/Plating/Refractive_Plating))
				return 1
			return 0
		HasBlastShielding()
			var/obj/Items/BlastShielding/B=src.EquippedShielding()
			if(B)
				return 1
			return 0
		EquippedPlating()
			var/obj/Items/Plating/P
			for(var/obj/Items/Plating/Platez in src)
				if(Platez.suffix=="*Equipped*")
					P=Platez
					break
			if(P)
				return P
			return 0
		EquippedShielding()
			var/obj/Items/BlastShielding/B
			for(var/obj/Items/BlastShielding/Shieldz in src)
				if(Shieldz.suffix=="*Equipped*")
					B=Shieldz
					break
			if(B)
				return B
			return 0
		GetProsthetics()
			return equippedProsthetics
/*			for(var/obj/Items/Gear/Prosthetic_Limb/PL in src)
				if(PL.suffix=="*Equipped*")
					Return++
			if(Return > 4)
				Return=4
			return Return*/
		HasJagan()
			if(locate(/obj/Skills/Buffs/SpecialBuffs/Cursed/Jagan_Eye, src))
				return 1
			return 0
		HasScouter()
			for(var/obj/Items/Tech/Scouter/Scoutz in src)
				if(Scoutz.suffix=="*Equipped*")
					return 1
			if(src.InternalScouter)
				return 1
			return 0
		HasIntuition()
			if(locate(/obj/Skills/Buffs/SpecialBuffs/Cursed/Jagan_Eye, src))
				return 1
			if(src.Secret=="Haki"&&src.secretDatum.secretVariable["HakiSpecialization"]=="Observation")
				return 1
			if(src.SenseUnlocked>5&&src.SenseUnlocked>src.SenseRobbed)
				return 1
			if(src.GetGodKi()>=0.25)
				return 1
		HasClarity()
			if(passive_handler.Get("Omnipotent")) // so admins can fucking see
				return 1
			if(knowledgeTracker)
				if("Combat Scanning" in src.knowledgeTracker.learnedKnowledge)
					return 1
			if(src.Secret=="Haki"&&src.secretDatum.secretVariable["HakiSpecialization"]=="Observation")
				return 1
			if(src.GetGodKi()>=0.25)
				return 1
			return 0
		HasEnlightenment()
			if(src.Dead)
				if(src.HasGodKi())
					return 1
				if(src.Saga=="Sharingan"&&src.SagaLevel==6)
					return 1
				if(src.Saga=="Cosmo"&&src.SagaLevel>=5)
					return 1
				if(src.HasSpiritPower()>=1)
					return 1
			return 0
		HasTransMimic()
			return passive_handler.Get("TransMimic")
		HasBuffMastery()
			var/Return=0
			Return+=passive_handler.Get("BuffMastery")
			if(Secret=="Haki")
				Return+=round(secretDatum.currentTier/2)
			var/stp=src.SaiyanTransPower()
			if(stp)
				Return+=stp
			return Return
		HasPursuer()
			var/Return=0
			Return+=passive_handler.Get("Pursuer")
			if(Target)
				if(isDominating(Target) && passive_handler.Get("HellRisen"))
					Return += passive_handler.Get("HellRisen") * 2
			if(src.Saga=="Eight Gates")
				Return+=2
			if(src.KamuiBuffLock)
				Return+=3
			var/stp=src.SaiyanTransPower()
			if(stp)
				Return+=stp
			return Return
		HasGodspeed()
			var/Return=0
			var/gk=src.GetGodKi()
			if(gk>=0.25)
				Return+=round(gk/0.25)
			if(passive_handler.Get("Gravity"))
				Return += secretDatum.currentTier
			Return+=passive_handler.Get("Godspeed")
			Return+=passive_handler.Get("GodSpeed") // just in case man
			var/t=src.HighestTrans()
			if(t)
				Return+=t/2
			if(src.KamuiBuffLock)
				Return += 3
			if(Secret == "Vampire")
				var/secretLevel = getSecretLevel()
				Return += 1 + (secretLevel / 4) * (1 + (secretDatum.secretVariable["BloodPower"] * 0.25))
			Return=round(Return)
			Return=min(8,Return)
			return Return
		HasFlicker()
			var/Return=0
			var/gk=src.GetGodKi()
			if(gk>=0.5)
				Return+=round(gk/0.5)
			if(src.Secret=="Haki")
				Return += clamp(secretDatum.currentTier/2, 1, 2)
			Return+=passive_handler.Get("Flicker")
			Return+=src.SaiyanTransPower()
			if(src.KamuiBuffLock)
				Return += 2
			if(Target)
				if(passive_handler.Get("HellRisen")  && isDominating(Target))
					Return += clamp((passive_handler.Get("HellRisen")*2), 1, 2)
			return Return
		HasDeathField()
			if(passive_handler.Get("DeathField"))
				return 1
			if(src.KamuiBuffLock)
				return 1
			return 0
		GetDeathField()
			return passive_handler.Get("DeathField")+(src.KamuiBuffLock*5)
		HasVoidField()
			if(passive_handler.Get("VoidField"))
				return 1
			if(src.CheckSlotless("Drunken Mastery") && src.Drunk)
				return 1
			return 0
		GetVoidField()
			var/Extra=0
			if(src.CheckSlotless("Drunken Mastery") && src.Drunk)
				Extra+=2
			return passive_handler.Get("VoidField")+Extra
		HasMaimStrike()
			return 0
			if(passive_handler.Get("MaimStrike"))
				return 1
		GetMortalStrike()
			. = 0
			. += passive_handler.Get("MortalStrike")
			if(Target)
				if(isDominating(Target) && passive_handler.Get("HellRisen") >= 0.75)
					. += passive_handler.Get("HellRisen")/4
			return .
		GetMaimStrike()
			return 0
			var/Return=0
			Return += passive_handler.Get("MaimStrike")
			// if(src.DemonicPower())
			// 	Return+=0.05 * src.AscensionsAcquired
			if(src.Saga=="Ansatsuken"&&src.AnsatsukenAscension=="Chikara")
				Return-=(Return * (0.25*(src.SagaLevel-4)))
			if(Return<0.001)
				Return=0.001
			return Return
		HasNoMiss()
			if(passive_handler.Get("NoMiss"))
				return 1
			return 0
		HasNoDodge()
			if(passive_handler.Get("NoDodge"))
				return 1
			return 0
		HasVoid()
			if(passive_handler.Get("Void"))
				return 1
			return 0
		HasBleedHit()
			if(passive_handler.Get("BleedHit"))
				return 1
			if(passive_handler.Get("Shameful Display"))
				return 1
			if(src.GatesActive && src.GatesActive<8)
				return 1
			if(src.CheckSpecial("Kaioken"))
				return 1
			if(src.HasHealthPU())
				if(src.PowerControl>100)
					return 1
			return 0
		GetBleedHit()
			var/Return=0
			var/kkmast=0
			Return+=passive_handler.Get("BleedHit")
			if(src.Kaioken)
				for(var/obj/Skills/Buffs/SpecialBuffs/Kaioken/kk in src.Buffs)
					kkmast=kk.Mastery
				Return+=src.Kaioken/kkmast
			if(src.HasHealthPU())
				if(src.PowerControl>100)
					Return*=(src.PowerControl/100)
			if(passive_handler.Get("Shameful Display"))
				var/viewCount = getSenketsuViewers()
				viewCount /= passive_handler.Get("Shameful Display")
				Return += sqrt(viewCount)
			if(src.GatesActive && src.GatesActive<8)
				Return+=(4/src.SagaLevel)
			return Return
		HasEnergyLeak()
			if(passive_handler.Get("EnergyLeak"))
				return 1
			if(src.transActive()&&!src.HasMystic())
				if(race.transformations[transActive].mastery>10&&race.transformations[transActive].mastery<75)
					return 1
			return 0
		GetEnergyLeak()
			var/Total=0
			Total+=passive_handler.Get("EnergyLeak")
			if(src.transActive()&&!src.HasMystic())
				if(race.transformations[transActive].mastery>10&&race.transformations[transActive].mastery<75)
					Total+=src.transActive()*0.25
			return Total
		HasFatigueLeak()
			if(passive_handler.Get("FatigueLeak"))
				return 1
			if(src.GatesActive && src.GatesActive < 8)
				return 1
			return 0
		GetFatigueLeak()
			var/Total=0
			Total+=passive_handler.Get("FatigueLeak")
			if(Total >= 3 && isRace(YOKAI))
				Total -= 0.5 * AscensionsAcquired
			if(src.GatesActive && src.GatesActive < 8)
				return Total +(4/src.SagaLevel)
			return Total
		HasSoftStyle()
			if(passive_handler.Get("SoftStyle"))
				return 1
			return 0
		GetSoftStyle()
			return passive_handler.Get("SoftStyle")
		HasHardStyle()
			if(passive_handler.Get("HardStyle"))
				return 1
			if(src.KamuiBuffLock)
				return 1
			return 0
		GetHardStyle()
			return passive_handler.Get("HardStyle") + (KamuiBuffLock * 4)
		GetDebuffCrash()
			var/list/Debuffs=list()
			for(var/sb in SlotlessBuffs)
				var/obj/Skills/Buffs/SlotlessBuffs/b = SlotlessBuffs[sb]
				if(b)
					if(b.DebuffCrash)
						Debuffs.Add(b.DebuffCrash)
			if(Debuffs.len > 0)
				return Debuffs
			return 0
		HasCyberStigma()
			if(passive_handler.Get("CyberStigma"))
				return 1
			return 0
		GetCyberStigma()
			return passive_handler.Get("CyberStigma")
		HasKiControl()
			if(passive_handler.Get("KiControl"))
				return 1
			return 0
		HasKiControlMastery()
			if(src.GetGodKi()>=0.25 && !isRace(SHINJIN))
				return 1
			if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Power Control"))
				return 1
			if(src.AdaptationCounter&&src.AdaptationTarget)
				return 1
			if(InfinityModule)
				return 1
			if(passive_handler.Get("KiControlMastery"))
				return 1
			if(src.isRace(NAMEKIAN)&&src.transActive())
				return 1
			if(isRace(SHINJIN)&&src.Potential>=25)
				return 1
			if(src.race in list(DEMON, DRAGON))
				return 1
			if(src.race in list(HUMAN, MAKYO)&&src.AscensionsAcquired)
				return 1
			return 0
		GetKiControlMastery()
			var/Total=passive_handler.Get("KiControlMastery")
			if(src.AdaptationCounter&&src.AdaptationTarget)
				Total+=src.AdaptationCounter
			if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Power Control"))
				Total += secretDatum?:getBoon("Power Control") / 8
			if(src.HasGodKi() && src.isRace(SHINJIN))
				Total+=round(src.GetGodKi()/0.25)
			if(src.isRace(NAMEKIAN)&&src.transActive())
				Total+=3
			if(InfinityModule)
				Total += 5
			if(src.isRace(MAKYO)&&src.AscensionsAcquired)
				Total+=src.AscensionsAcquired
			if(isRace(SHINJIN))
				Total+=round(src.Potential/25)
			if(isRace(DRAGON)||isRace(DEMON))
				Total+=1
			if(isRace(HUMAN)&&src.AscensionsAcquired)
				Total+=(0.5*src.AscensionsAcquired)
			// if(src.Race=="Half Saiyan"&&src.AscensionsAcquired)
			// 	Total+=(0.25*src.AscensionsAcquired)
			return min(Total,4)
		HasPULimited()
			if(passive_handler.Get("AllowedPower"))
				return 1
			return 0
		GetPULimited()
			return passive_handler.Get("AllowedPower")
		HasPULock()
			if(passive_handler.Get("PULock"))
				return passive_handler.Get("PULock")
			return 0
		HasPUSpike()
			if(passive_handler.Get("PUSpike"))
				return 1
			return 0
		GetPUSpike()
			return passive_handler.Get("PUSpike")
		HasUnstoppable()
			if(Secret == "Zombie")
				return 1
			if(passive_handler.Get("Unstoppable"))
				return 1
			return 0
		SaiyanTransPower()/*
			if(isRace(SAIYAN) || isRace(HALFSAIYAN))
				var/t = transActive
				var/hastransmimic = HasTransMimic()
				if(hastransmimic > transActive)
					t = hastransmimic
				return t*/
			return 0
		isUnderDog(mob/p)
			if(p.Power > Power || p.passive_handler.Get("GodKi") > p.passive_handler.Get("GodKi"))
				return TRUE
			return FALSE
		missingHealth()
			return 100-Health
		HasPureDamage(changelingIgnore = 0)
			var/Return=0
			if(!changelingIgnore&&isRace(CHANGELING)&&Anger)
				return 0
			Return+=passive_handler.Get("PureDamage")

			if(passive_handler.Get("Shameful Display"))
				var/viewCount = getSenketsuViewers()
				if(passive_handler.Get("Shameful Display") >= 4)
					Return += sqrt(viewCount)
				else
					Return -= sqrt(viewCount)
			if(passive_handler["Rage"] && Health <= 50)
				Return += clamp((missingHealth()) * passive_handler["Rage"]/glob.RAGE_DIVISOR, 0.1, glob.MAX_RAGEPUREDAMAGE)
			if(passive_handler.Get("CursedSheath"))
				Return += cursedSheathValue/100
			if(dainsleifDrawn)
				Return += 1+SagaLevel // i hope someone gets cratered by dainsleif
			if(isRace(MAJIN))
				Return += AscensionsAcquired * getMajinRates("Damage")
			if(passive_handler["Rebel Heart"])
				var/h = ((missingHealth())/glob.REBELHEARTMOD) * passive_handler["Rebel Heart"]
				Return += h
			return Return
		HasPureReduction()
			var/Return=0
			Return += passive_handler.Get("PureReduction")
			Return += passive_handler.Get("Mythical") * glob.MYTHICALPUREREDMULT
			if(src.isRace(MAJIN))
				Return += AscensionsAcquired * getMajinRates("Reduction")
			if(passive_handler["Rage"] && Health <= 50)
				Return -= clamp((missingHealth()) * passive_handler["Rage"]/glob.RAGE_DIVISOR, 0, glob.MAX_RAGEPUREDAMAGE)
			if(src.TarotFate=="The Hanged Man")
				Return-=5
			if(src.TarotFate=="Justice")
				Return+=5
			if(passive_handler["Rebel Heart"])
				var/h = (missingHealth()/glob.REBELHEARTMOD) * passive_handler["Rebel Heart"]
				Return += h
			return Return
		Hustling()
			if(passive_handler.Get("Hustle") || HasMythical() > 0.25 || (passive_handler["Rage"] && Health <= 25))
				return 1
		HasWalking()
			if(locate(/obj/Skills/Walking, src))
				return 1
			return 0
		HasShunkanIdo()
			if(locate(/obj/Skills/Teleport/Instant_Transmission, src))
				return 1
			return 0
		HasVaizard()
			if(locate(/obj/Skills/Buffs/SpecialBuffs/Cursed/Vaizard_Mask, src))
				for(var/obj/Skills/Buffs/SpecialBuffs/Cursed/Vaizard_Mask/vm in src.Buffs)
					if(vm.Mastery==1)
						return 2
				return 1
			return 0
		HasJinchuuriki()
			if(locate(/obj/Skills/Buffs/SpecialBuffs/Cursed/Jinchuuriki, src))
				return 1
			return 0
		HasSweepingStrike()
			if(passive_handler.Get("SweepingStrike"))
				return 1
			if(src.CheckSlotless("Sage Mode")&&src.StyleActive)
				return 1
			return 0
		HasTechniqueMastery()
			if(passive_handler.Get("TechniqueMastery"))
				return 1
			if(usingStyle("UnarmedStyle"))
				return 1
			if(UsingMasteredMartialStyle())
				return 1
			if(src.TarotFate=="The World")
				return 1
			if(Target)
				if(isDominating(Target) && passive_handler.Get("HellRisen"))
					return 1
			return 0
		GetTechniqueMastery()
			var/Return=0
			Return+=passive_handler.Get("TechniqueMastery")
			if(isRace(HUMAN) && passive_handler.Get("Innovation") && StyleBuff)
				if(StyleBuff.SignatureTechnique>=1)
					Return += StyleBuff.SignatureTechnique * 0.25
			if(UsingMasteredMartialStyle())
				Return += 0.5
			if(Target)
				if(isDominating(Target) && passive_handler.Get("HellRisen") >= 0.75)
					Return += passive_handler.Get("HellRisen") * 4
			if(src.TarotFate=="The World")
				Return+=5
			if(Target)
				if(Target.passive_handler.Get("Pressure"))
					Return -= Target.passive_handler.Get("Pressure")
			return Return
		HasUnarmedDamage()
			if(passive_handler.Get("UnarmedDamage"))
				return 1
			return 0
		GetUnarmedDamage()
			return passive_handler.Get("UnarmedDamage")
		HasSpiritualDamage()
			if(passive_handler.Get("SpiritualDamage"))
				return 1
			return 0
		GetSpiritualDamage()
			return passive_handler.Get("SpiritualDamage")

		HasDuelist()
			if(passive_handler.Get("Duelist"))
				return 1
			if(isRace(CHANGELING)&&Anger)
				return HasPureDamage(1)
			return 0
		GetDuelist()
			if(isRace(CHANGELING)&&Anger)
				return HasPureDamage(1)
			return passive_handler.Get("Duelist")
		HasVanish()
			if(passive_handler.Get("Vanishing"))
				return 1
			return 0
		GetVanish()
			return passive_handler.Get("Vanishing")
		HasMovementMastery()
			if(passive_handler.Get("MovementMastery"))
				return 1
			if(InfinityModule)
				return 1
			if(Saga=="Cosmo")
				return 1
			return 0
		GetMovementMastery()
			var/Total=0
			Total+=passive_handler.Get("MovementMastery")
			if(Saga=="Cosmo" && !SpecialBuff)
				Total += SagaLevel * 2.5
			if(InfinityModule)
				Total += round(glob.progress.totalPotentialToDate,5) / 10
			return Total
		HasPhysicalHitsLimit()
			if(passive_handler.Get("PhysicalHitsLimit"))
				return 1
			return 0
		HasSwordHitsLimit()
			if(passive_handler.Get("SwordHitsLimit"))
				return 1
			return 0
		HasUnarmedHitsLimit()
			if(passive_handler.Get("UnarmedHitsLimit"))
				return 1
			return 0
		HasSpiritHitsLimit()
			if(passive_handler.Get("SpiritHitsLimit"))
				return 1
			return 0
		HasAutoReversal()
			if(passive_handler.Get("Reversal"))
				return 1
			if(passive_handler["Magmic"] && SlotlessBuffs["Magmic Shield"])
				return 1
			return 0
		GetAutoReversal()
			if(passive_handler["Magmic"] && SlotlessBuffs["Magmic Shield"])
				return 100
			return passive_handler.Get("Reversal")
		HasAttracting()
			if(passive_handler.Get("Attracting"))
				return 1
			return 0
		GetAttracting()
			return passive_handler.Get("Attracting")
		HasTerrifying()
			if(passive_handler.Get("Terrifying"))
				return 1
			return 0
		GetTerrifying()
			return passive_handler.Get("Terrifying")
		HasNoRevert()
			if(passive_handler.Get("NoRevert"))
				return 1
			return 0
		HasCounterMaster()
			return passive_handler.Get("CounterMaster")
		GetCounterMaster()
			return passive_handler.Get("CounterMaster")
		HasActiveBuffLock()
			if(passive_handler.Get("ActiveBuffLock"))
				return 1
			return 0
		HasSpecialBuffLock()
			if(passive_handler.Get("SpecialBuffLock"))
				return 1
			if(src.InfinityModule)
				return 1
			return 0
		HasInjuryImmune()
			if(passive_handler.Get("InjuryImmune"))
				return 1
			return 0
		GetInjuryImmune()
			return passive_handler.Get("InjuryImmune")
		HasFatigueImmune()
			if(passive_handler.Get("FatigueImmune"))
				return 1
			if(InfinityModule)
				return 1
			return 0
		GetFatigueImmune()
			var/Return = passive_handler.Get("FatigueImmune")
			if(InfinityModule)
				Return += 1
			return Return
		HasDebuffResistance()
			if(passive_handler.Get("DebuffResistance"))
				return 1
			return 0
		GetDebuffResistance()
			return passive_handler.Get("DebuffResistance")
		HasVenomImmune()
			if(passive_handler.Get("VenomImmune"))
				return 1
			return 0
		HasWalkThroughHell()
			if(passive_handler.Get("WalkThroughHell"))
				return 1
			return 0
		HasWaterWalk()
			if(passive_handler.Get("WaterWalk") || passive_handler.Get("Gravity"))
				return 1
			return 0
		HasSuperDash()
			var/Return=0
			Return=passive_handler.Get("SuperDash")
			if(src.SenseUnlocked>5&&src.SenseUnlocked>src.SenseRobbed)
				Return+=1
			if(InfinityModule)
				Return += round(glob.progress.totalPotentialToDate,5) / 25
			Return=round(Return)
			return Return
		GetSuperDash()
			var/Total=0
			Total+=passive_handler.Get("SuperDash")
			if(src.SenseUnlocked>5&&src.SenseUnlocked>src.SenseRobbed)
				Total+=1
				if(src.SenseUnlocked>=7)
					Total+=1
			if(InfinityModule)
				Total += round(glob.progress.totalPotentialToDate,5) / 25
			Total=round(Total)
			return min(Total,2)
		HasDeflection()
			if(passive_handler.Get("Deflection"))
				return 1
			return 0
		GetDeflection()
			return passive_handler.Get("Deflection")
		HasBulletKill()
			if(passive_handler.Get("BulletKill"))
				return 1
			return 0
		HasMovingCharge()
			if(passive_handler.Get("MovingCharge"))
				return 1
			if(src.UBWPath=="Feeble"&&SagaLevel>=4)
				return 1
			return 0
		HasQuickCast()
			if(passive_handler.Get("QuickCast"))
				return 1
			return 0
		GetQuickCast()
			return passive_handler.Get("QuickCast")
		HasDualCast()
			if(passive_handler.Get("DualCast"))
				return 1
			return 0
		HasHealthPU()
			if(passive_handler.Get("HealthPU"))
				return 1
			return 0
		HasShear()
			if(passive_handler.Get("Shearing"))
				return 1
			return 0
		GetShear()
			var/Total=0
			Total+=passive_handler.Get("Shearing")
			return Total
		HasCripple()
			if(passive_handler.Get("Crippling"))
				return 1
			if(src.StyleActive=="Butcher" || src.StyleActive=="Five Rings")
				if(src.AttackQueue||src.AutoHitting)
					return 1
			return 0
		GetCripple()
			var/Total=0
			Total+=passive_handler.Get("Crippling")
			if(src.StyleActive=="Butcher" || src.StyleActive=="Five Rings")
				if(src.AttackQueue||src.AutoHitting)
					Total+=1
			return Total
		HasNoSword()
			if(passive_handler.Get("NoSword"))
				return 1
			return 0
		HasNoStaff()
			if(passive_handler.Get("NoStaff"))
				return 1
			return 0
		HasNeedsStaff()
			if(passive_handler.Get("NeedStaff"))
				return 1
			return 0
		HasNeedsSword()
			if(passive_handler.Get("NeedsSword"))
				return 1
			return 0
		HasRipple()
			if(passive_handler.Get("Ripple"))
				return 1
			if(secretDatum && Secret == "Ripple")
				return 1
			return 0
		HasWitchCraft()
			if(locate(/obj/Items/WitchCraft/WitchesBook, src.contents))
				return 1
			else
				return 0
		GetRipple()
			var/RippleEffectivness=1
			if(src.Slow)
				RippleEffectivness*=0.75
			if(src.Shock)
				RippleEffectivness*=0.75
			if(src.CyberCancel)
				RippleEffectivness*=0.75
			if(src.Swim)
				RippleEffectivness*=1.5
			var/ticks = passive_handler.Get("Ripple")
			if(secretDatum && Secret == "Ripple")
				ticks += secretDatum.secretVariable["Ripple"]
			return (passive_handler.Get("Ripple")*RippleEffectivness)
		HasNoForcedWhiff()
			if(passive_handler.Get("NoForcedWhiff"))
				return 1
			return 0
		HasSpecialStrike()
			if(passive_handler.Get("SpecialStrike"))
				return 1
			return 0
		HasGodKiBuff()
			if(locate(/obj/Skills/Buffs/SlotlessBuffs/God_Ki, src) || CheckSpecial("Sacred Energy") ||CheckSpecial("Final Getsuga Tenshou") || CheckSpecial("Ultra Instinct") || SenseUnlocked >= 7)
				return 1
			return 0
		HasTelepathy()
			if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Senses"))
				return 0
			if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Senses"))
				return 1
			if(locate(/obj/Skills/Utility/Telepathy, src))
				return 1
			return 0
		HasFlow()
			if(src.KO)
				return 0
			if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Senses"))
				return 0
			if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Senses"))
				return 1
			if(passive_handler.Get("Shameful Display"))
				var/viewCount = getSenketsuViewers()
				if(viewCount)
					if(passive_handler.Get("Shameful Display") >= 4)
						return 1
					else
						return 0
			if(passive_handler.Get("Flow"))
				return 1
			if(src.Secret=="Ripple"&&src.StyleActive)
				return 1
			// if(src.Secret=="Vampire"&&src.StyleActive)
			// 	return 1
			if(src.Secret=="Haki"&&src.secretDatum.secretVariable["HakiSpecialization"]=="Observation"&&src.StyleActive)
				return 1
			if(src.CombatCPU)
				return 1
			if(InfinityModule)
				return 1
			if(passive_handler.Get("LikeWater") || passive_handler.Get("Gravity"))
				if(Target.HasInstinct() >= GetFlow())
					return 1
			return 0
		GetFlow()
			var/Extra=0
			var/Base = passive_handler.Get("Flow")
			if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Senses"))
				return 0
			if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Senses"))
				Extra += secretDatum?:getBoon(src, "Senses")
			if(src.Secret=="Ripple"&&src.StyleActive)
				Extra+=1
			if(passive_handler.Get("Shameful Display"))
				var/viewCount = getSenketsuViewers()
				if(passive_handler.Get("Shameful Display") >= 4)
					Extra += sqrt(viewCount)
			// if(src.Secret=="Vampire"&&src.StyleActive)
			// 	Extra+=1
			if(src.Secret=="Haki")
				Extra++
			if(src.CombatCPU)
				Extra+=1
			if(InfinityModule)
				Extra += round(glob.progress.totalPotentialToDate,5) / 25
			if(Target&&Target.passive_handler.Get("Instinct") >= Base+Extra)
				Extra += (passive_handler.Get("LikeWater")) / 2
			return (Base+Extra)
		HasInstinct()
			var/Return=BaseOff()/4
			if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Senses"))
				return 0
			Return+=passive_handler.Get("Instinct")
			if(passive_handler.Get("Shameful Display"))
				var/viewCount = getSenketsuViewers()
				if(passive_handler.Get("Shameful Display") >= 4)
					Return += sqrt(viewCount)
				else
					Return -= sqrt(viewCount)
			if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Senses"))
				Return += secretDatum?:getBoon(src, "Senses")
			if(Target)
				if(isDominating(Target) && passive_handler.Get("HellRisen"))
					Return += passive_handler.Get("HellRisen") * 2
			var/t=src.HighestTrans()
			if(round(t/4))
				Return+=1
			if(InfinityModule)
				Return += round(glob.progress.totalPotentialToDate,5) / 25
			if(Target&&Target.passive_handler.Get("Flow") >= Return)
				Return+=passive_handler.Get("LikeWater") / 2
			if(Return < 0)
				Return = 0
			return Return
		HasSoulSteal()
			if(passive_handler.Get("SoulSteal"))
				return 1
			return 0
		GetSoulSteal()
			return passive_handler.Get("SoulSteal")
		HasLifeSteal()
			if(passive_handler["Rage"] && Health <= 75)
				return 1
			if(passive_handler.Get("LifeSteal"))
				return 1
			if(Secret == "Vampire")
				return 1
			if(isRace(MAJIN) && race.ascensions[1].choiceSelected == /ascension/sub_ascension/majin/unhinged)
				return 1
			return 0
		GetLifeSteal()
			var/extra = 0
			if(passive_handler["Rage"] && Health <= 75)
				extra = 5 * passive_handler["Rage"]
			if(isRace(MAJIN) && race.ascensions[1].choiceSelected == /ascension/sub_ascension/majin/unhinged)
				extra += 5 * AscensionsAcquired
			if(Secret=="Vampire")
				var/secretLevel = getSecretLevel()
				extra += 5 + (secretLevel * 2) * (1 + (secretDatum.secretVariable["BloodPower"] * 0.25))
			return passive_handler.Get("LifeSteal") + extra
		HasEnergySteal()
			if(passive_handler.Get("EnergySteal"))
				return 1
			return 0
		GetEnergySteal()
			return passive_handler.Get("EnergySteal")

		HasManaSteal()
			if(passive_handler.Get("ManaSteal"))
				return 1
			return 0

		GetManaSteal()
			return passive_handler.Get("ManaSteal")

		HasLifeStealTrue()
			if(passive_handler.Get("LifeStealTrue"))
				return 1
			return 0
		HasLifeGeneration()
			if(passive_handler.Get("LifeGeneration"))
				return 1
			return 0
		GetLifeGeneration()
			return passive_handler.Get("LifeGeneration")
		HasEnergyGeneration()
			if(passive_handler.Get("EnergyGeneration"))
				return 1
			return 0
		GetEnergyGeneration()
			return passive_handler.Get("EnergyGeneration")
		HasManaGeneration()
			if(passive_handler.Get("ManaGeneration"))
				return 1
			if(isRace(ELF))
				return 1
			return 0
		GetManaGeneration()
			var/managen = passive_handler.Get("ManaGeneration")
			if(isRace(ELF))
				managen += AscensionsAcquired
			return managen
		HasMystic()
			if(src.passive_handler.Get("Mystic"))
				return 1
			return 0
		HasMaki()
			if(passive_handler.Get("Maki"))
				return 1
			return 0
		HasTaxThreshold()
			if(passive_handler.Get("TaxThreshold"))
				return 1
			return 0
		GetTaxThreshold()
			return passive_handler.Get("TaxThreshold")
		DemonicPower() //Fake Demon.
			if(src.Saga=="Ansatsuken"&&src.SagaLevel>=6&&src.AnsatsukenAscension)
				return 1
			if(src.isRace(DEMON))
				return 1
			if(src.CheckSlotless("Majin"))
				return 1
			return 0
		HasSpiritPower()
			return passive_handler.Get("SpiritPower")
		HasMythical()
			var/Extra=0
			Extra += passive_handler.Get("Mythical")
			return 0
		HasHellPower()
			if(CheckSlotless("Satsui no Hado") && SagaLevel>=6)
				return 1
			if(passive_handler.Get("HellPower"))
				if(isRace(DEMON))
					return 2
				return 1
			return 0
		GetHellPower()
			var/hellpower = passive_handler.Get("HellPower")
			if(CheckSlotless("Satsui no Hado") && SagaLevel>=6)
				hellpower++
			return hellpower
		
		HasPowerReplacement()
			if(src.passive_handler.Get("PowerReplacement"))
				return 1
			return 0
		GetPowerReplacement()
			return src.passive_handler.Get("PowerReplacement")
		GetIntimidationIgnore(var/mob/m)
			var/Return=0
			if(isRace(HUMAN))
				Return+=100

			if(m)
				if(m.isRace(HUMAN))
					Return-=100
				if(m.isRace(MAKYO))
					Return-=(5*m.AscensionsAcquired)
				if(m.HasGodKi())
					if(src.HasMythical())
						Return-=(m.GetGodKi())*(100-(src.HasMythical()*100))
					else
						Return-=m.GetGodKi()*100
			if(src.HasGodKi())
				Return+=src.GetGodKi()*100

			if(src.Saga=="Ansatsuken")
				if(src.AnsatsukenAscension=="Chikara")
					Return+=((src.SagaLevel-4)*25)
			if(m.Saga=="Ansatsuken")
				if(m.AnsatsukenAscension=="Chikara")
					Return-=((m.SagaLevel-4)*25)
			if(isRace(ANDROID))
				Return=100

			if(m)
				if(m.CyberCancel)
					Return-=m.CyberCancel*100
				if(m.Mechanized)
					Return-=100
				if(m.isRace(ANDROID))
					Return=0
			if(Return>100)
				Return=100
			if(Return<0)
				Return=0
			Return/=100
			return Return
		HasIntimidation()
			var/Effective=src.Intimidation
			if(src.ShinjinAscension=="Makai")
				Effective+=1
			if(src.isRace(DEMON)||src.isRace(MAJIN))
				Effective+=1
			Effective *= 1 + passive_handler.Get("Mythical")
			if(src.CheckActive("Mobile Suit")||src.CheckSlotless("Battosai")||src.CheckSlotless("Susanoo"))
				Effective+=1
			if(src.Health<(1-src.HealthCut)&&src.HealthAnnounce10&&src.Saga=="King of Braves"&&src.SpecialBuff)
				if(src.SpecialBuff.BuffName=="Broken Brave")
					Effective*=3
				else if(src.SpecialBuff.BuffName=="Genesic Brave")
					Effective*=2
			if(src.HasHellPower() == 2)
				Effective+=1
			if(src.KaiokenBP>1)
				Effective*=KaiokenBP
			if(Effective>1)
				return 1
			return 0

		GetHellScaling()
			var/Return=1
			var/Mult=GetHellPower() / glob.HELL_SCALING_MULT
			if(HasHellPower() == 2)
				Mult*=glob.HELL_SCALING_MULT
				Mult+=round(src.Potential/100, 0.05)
			var/HealthLost = abs(src.Health-100)
			Return=1+(((glob.BASE_HELL_SCALING_RATIO * HealthLost) * Mult) ** (1/2))
			return Return

		HasGodKi()
			if(passive_handler["DisableGodKi"])
				return 0
			if(glob.T3_STYLES_GODKI_VALUE>0 && StyleBuff?.SignatureTechnique==3)
				return 1
			if(passive_handler.Get("GodKi"))
				return 1
			if(src.SenseUnlocked>6&&(src.SenseUnlocked>src.SenseRobbed))
				return 1
			if(src.CheckSlotless("Saiyan Soul")&&Target&&!src.HasGodKiBuff())
				if(!src.Target.CheckSlotless("Saiyan Soul")&&src.Target.HasGodKi())
					return 1
			if(src.HasSpiritPower()>=1 && FightingSeriously(src, 0))
				if(src.Health<=max(15, (30+src.TotalInjury)*src.HasSpiritPower()) || src.InjuryAnnounce)
					return 1
			if(src.KamuiBuffLock)
				return 1
			return 0
		GetGodKi()
			
			var/Total=passive_handler.Get("GodKi")
			if(glob.T3_STYLES_GODKI_VALUE>0 && StyleBuff?.SignatureTechnique==3)
				Total+=glob.T3_STYLES_GODKI_VALUE
			if(src.HasSpiritPower()>=1 && FightingSeriously(src, 0))
				if(src.Health<=(30+src.TotalInjury)*src.HasSpiritPower())
					if(src.SenseUnlocked<7)//saintz
						Total+=0.25*src.HasSpiritPower()
					else
						Total+=(0.25*src.HasSpiritPower()*0.5)//halved rate for god ki saints
			if(src.SenseUnlocked>6&&(src.SenseUnlocked>src.SenseRobbed))
				if(src.SenseUnlocked>=7)
					Total+=0.25
				if(src.SenseUnlocked>=8)
					Total+=0.75
				if(SenseUnlocked >= 9)
					Total += 1
			if(src.CheckSlotless("Saiyan Soul")&&!src.HasGodKiBuff())
				if(src.Target&&!src.Target.CheckSlotless("Saiyan Soul")&&src.Target.HasGodKi())
					Total+=src.Target.GetGodKi()/3
			if(passive_handler.Get("Hidden Potential") && !HasGodKiBuff())
				if(src.Target)
					if(src.Target.HasGodKi())
						if(Target.GetGodKi() > Total)
							Total=Target.GetGodKi()
					else
						Total+=Potential/100
			if(src.KamuiBuffLock)
				Total+=0.75
			if(src.isRace(DRAGON))
				if(src.AscensionsAcquired==6 && Total<0.5)
					Total=0.5//fully ascended dragon
			return Total
		HasFluidForm()
			if(passive_handler.Get("FluidForm"))
				return passive_handler.Get("FluidForm")
			if( passive_handler.Get("Gravity"))
				return passive_handler.Get("Gravity")
			if(src.HasMythical()>=1)
				return 1
			if(src.HasEmptyGrimoire())
				return 1
			return 0
		HasStunningStrike()
			if(passive_handler.Get("StunningStrike"))
				return 1
			if(src.Secret=="Haki"&&src.secretDatum.secretVariable["HakiSpecialization"]=="Armament"&&src.StyleActive)
				return 1
			return 0
		GetStunningStrike()
			var/Extra=0
			if(src.Secret=="Haki"&&src.secretDatum.secretVariable["HakiSpecialization"]=="Armament"&&src.StyleActive)
				Extra+= clamp(secretDatum.currentTier, 1, 5)
			return (passive_handler.Get("StunningStrike")+Extra)
		HasDrainlessMana()
			if(passive_handler.Get("DrainlessMana"))
				return 1
			return 0
		HasLimitlessMagic()
			if(passive_handler.Get("LimitlessMagic"))
				return 1
			if(passive_handler.Get("MartialMagic"))
				return 2
			if(src.Saga=="Unlimited Blade Works")
				return 1
			return 0
		HasManaCapMult()
			if(passive_handler.Get("ManaCapMult"))
				return 1
			return 0
		HasManaLeak()
			if(passive_handler.Get("ManaLeak"))
				return 1
			return 0
		GetManaLeak()
			var/Return=0
			Return+=passive_handler.Get("ManaLeak")
			return Return
		GetManaCapMult()
			return 1 + passive_handler.Get("ManaCapMult")
		HasManaStats()
			if(passive_handler.Get("ManaStats"))
				return 1
			return 0
		GetManaStats()
			var/Return=0
			Return+=passive_handler.Get("ManaStats")
			return Return
		HasBurning()
			if(passive_handler.Get("Burning"))
				return 1
			if(src.Attunement=="Fire")
				return 1
			if(src.InfusionElement=="Fire")
				return 1
			return 0
		GetBurning()
			return passive_handler.Get("Burning")
		HasScorching()
			if(passive_handler.Get("Scorching"))
				return 1
			return 0
		GetScorching()
			return passive_handler.Get("Scorching")
		HasChilling()
			if(passive_handler.Get("Chilling"))
				return 1
			if(src.Attunement=="Water")
				return 1
			if(Attunement=="Fox Fire")
				return 1
			if(src.InfusionElement=="Water")
				return 1
			return 0
		GetChilling()
			return passive_handler.Get("Chilling")
		HasFreezing()
			if(passive_handler.Get("Freezing"))
				return 1
			return 0
		GetFreezing()
			return passive_handler.Get("Freezing")
		HasHardening()
			if(passive_handler.Get("Hardening"))
				return 1
			return 0
		GetHardening()
			return passive_handler.Get("Hardening")
		HasCrushing()
			if(passive_handler.Get("Crushing"))
				return 1
			if(src.Attunement=="Earth")
				return 1
			if(src.InfusionElement=="Earth")
				return 1
			return 0
		GetCrushing()
			return passive_handler.Get("Crushing")
		HasShattering()
			if(passive_handler.Get("Shattering"))
				return 1
			return 0
		GetShattering()
			return passive_handler.Get("Shattering")
		HasShocking()
			if(passive_handler.Get("Shocking"))
				return 1
			if(src.Attunement=="Wind")
				return 1
			if(src.InfusionElement=="Wind")
				return 1
			return 0
		GetShocking()
			return passive_handler.Get("Shocking")
		HasParalyzing()
			if(passive_handler.Get("Paralyzing"))
				return 1
			return 0
		GetParalyzing()
			return passive_handler.Get("Paralyzing")
		HasPoisoning()
			if(passive_handler.Get("Poisoning"))
				return 1
			return 0
		GetPoisoning()
			return passive_handler.Get("Poisoning")
		HasToxic()
			if(passive_handler.Get("Toxic"))
				return 1
			return 0
		GetToxic()
			return passive_handler.Get("Toxic")
		HasPacifying()
			if(passive_handler.Get("Pacifying"))
				return 1
			return 0
		GetPacifying()
			return passive_handler.Get("Pacifying")
		HasEnraging()
			if(passive_handler.Get("Enraging"))
				return 1
			return 0
		GetEnraging()
			return passive_handler.Get("Enraging")
		HasDoubleStrike()
			if(passive_handler.Get("DoubleStrike"))
				return 1
			return 0
		GetDoubleStrike()
			return passive_handler.Get("DoubleStrike")
		HasTripleStrike()
			if(passive_handler.Get("TripleStrike"))
				return 1
			return 0
		GetTripleStrike()
			return passive_handler.Get("TripleStrike")
		HasDebuffReversal()
			if(passive_handler.Get("DebuffReversal"))
				return 1
			return 0
		HasDisorienting()
			if(passive_handler.Get("Disorienting"))
				return 1
			return 0
		GetDisorienting()
			return passive_handler.Get("Disorienting")
		HasConfusing()
			if(passive_handler.Get("Confusing"))
				return 1
			return 0
		GetConfusing()
			return passive_handler.Get("Confusing")
		HasHolyMod()
			if(passive_handler.Get("HolyMod"))
				return 1
			if(src.TarotFate=="The Lovers")
				return 1
			if(src.TarotFate=="The Hierophant")
				return 1
			return 0
		GetHolyMod()
			var/Reduce=0
			var/Extra=0
			if(src.TarotFate=="The Lovers")
				Extra=2.5
			if(src.TarotFate=="The Hierophant")
				Extra=5
			return (passive_handler.Get("HolyMod")+Extra-Reduce)
		HasAbyssMod()
			if(passive_handler.Get("AbyssMod"))
				return 1
			if(src.TarotFate=="The Devil")
				return 1
			if(src.TarotFate=="The Lovers")
				return 1
			return 0
		GetAbyssMod()
			var/Reduce=0
			var/Extra=0
			if(src.TarotFate=="The Devil")
				Extra=5
			if(src.TarotFate=="The Lovers")
				Extra=2.5
			return (passive_handler.Get("AbyssMod")+Extra-Reduce)
		HasSlayerMod(mob/enemy)
			if(passive_handler.Get("SlayerMod"))
				if(passive_handler["FavoredPrey"] == "All")
					return 1
				if(passive_handler["FavoredPrey"] == "Secrets")
					if(enemy.secretDatum && enemy.secretDatum.name)
						return 1
				else if(passive_handler["FavoredPrey"] == "Sagas")
					if(enemy.Saga)
						return 1
				else if(passive_handler["FavoredPrey"] in SAGAS)
					if(enemy.Saga == passive_handler["FavoredPrey"])
						return 1
				else if(passive_handler["FavoredPrey"] in SECRETS)
					if(enemy.secretDatum && enemy.secretDatum.name == passive_handler["FavoredPrey"])
						return 1
				else if(passive_handler["FavoredPrey"] == "Races")
					if(enemy)
						if(!enemy.secretDatum)
							return 1
				else if(passive_handler["FavoredPrey"] in RACES)
					if(enemy.race.name == passive_handler["FavoredPrey"])
						return 1
				return 0
			return 0
		GetSlayerMod()
			return passive_handler.Get("SlayerMod")
		HasBeyondPurity()
			if(passive_handler.Get("BeyondPurity"))
				return 1
			if(src.PoseEnhancement&&src.HasRipple())//Ripple Pure shenanigans
				return 1
			return 0
		HasPurity()
			if(passive_handler.Get("Purity"))
				return 1
			if(src.PoseEnhancement&&src.HasRipple())//Ripple Pure shenanigans
				return 1
			return 0
		HasNoAnger()
			if(passive_handler.Get("NoAnger"))
				return 1
			if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Anger"))
				return 1
			return 0
		HasAngerThreshold()
			if(passive_handler.Get("AngerThreshold"))
				return 1
			return 0
		GetAngerThreshold()
			return passive_handler.Get("AngerThreshold")
		HasWeaponBreaker()
			if(passive_handler.Get("WeaponBreaker"))
				return 1
			if(src.HasAdaptation()&&src.AdaptationTarget&&istype(src.AdaptationTarget, /mob/Players)&&src.AdaptationTarget.HasSword())
				return 1
			return 0
		GetWeaponBreaker()
			var/Extra=0
			if(src.HasAdaptation()&&src.AdaptationTarget&&istype(src.AdaptationTarget, /mob/Players)&&src.AdaptationTarget.HasSword())
				Extra=1*src.AdaptationCounter
			return passive_handler.Get("WeaponBreaker")+Extra
		HasGiantForm()
			if(passive_handler.Get("GiantForm"))
				return 1
			if(src.HasMythical()>=0.5)
				return 1
			return 0
		HighestTrans()
			var/tm=src.HasTransMimic()
			var/ta=src.transActive()
			if(tm || ta)
				if(tm > ta)
					return tm
				else
					return ta
			else
				return 0
		HasSteady()
			if(passive_handler.Get("Steady"))
				return 1
			if(passive_handler.Get("Zornhau"))
				return 1
			return 0
		GetSteady()
			var/total = passive_handler.Get("Steady") * (glob.STEADY_MODIFIER)
			return total
		HasErosion()
			if(passive_handler.Get("Erosion"))
				return 1
			return 0
		GetErosion()
			return passive_handler.Get("Erosion")
		HasMirrorStats()
			if(passive_handler.Get("MirrorStats"))
				return 1
			return 0
		HasManaPU()
			if(passive_handler.Get("ManaPU"))
				return 1
			return 0
		HasCalmAnger()
			if(passive_handler.Get("CalmAnger"))
				return 1
			if(isRace(SHINJIN) && src.ShinjinAscension=="Makai")
				return 1
			if(src.isRace(NAMEKIAN) && src.transActive())
				return 1
			if(src.TarotFate=="Temperance")
				return 1
			return 0
		HasExtend()
			if(passive_handler.Get("Extend"))
				return 1
			return 0
		GetExtend()
			return passive_handler.Get("Extend")
		HasWarp()
			if(passive_handler.Get("Warp"))
				return 1
			return 0
		HasPridefulRage()
			if(passive_handler.Get("PridefulRage"))
				return 1
			return 0
		HasSpiritHand()//Str*(For**1/2)
			if(passive_handler.Get("SpiritHand"))
				return 1
			if(src.TarotFate=="The Empress")
				return 1
			return 0
		GetSpiritHand()//Str*(For**1/2)
			return passive_handler.Get("SpiritHand")


		HasSpiritFlow()//For*(Str**1/2)
			if(passive_handler.Get("SpiritFlow"))
				return 1
			if(src.TarotFate=="The Emperor")
				return 1
			if(InfinityModule)
				return 1
			return 0
		GetSpiritFlow()
			var/Return = passive_handler.Get("SpiritFlow")
			if(InfinityModule)
				Return += round(glob.progress.totalPotentialToDate,5) / 50
			return Return
		HasSpiritSword()//Str(0.75)+For(0.75)
			if(passive_handler.Get("SpiritSword"))
				return 1
			return 0
		GetSpiritSword()//Str(0.75)+For(0.75)
			return passive_handler.Get("SpiritSword")
		HasHybridStrike()//Str(0.75)+For(0.75)
			if(passive_handler.Get("HybridStrike"))
				return 1
			if(InfinityModule)
				return 1
			return 0
		GetHybridStrike()//Str(0.75)+For(0.75)
			var/Return = passive_handler.Get("HybridStrike")
			if(InfinityModule)
				Return += round(glob.progress.totalPotentialToDate,5) / 50
			return Return
		HasSpiritStrike()//For v.s. End
			if(passive_handler.Get("SpiritStrike"))
				return 1
			return 0
		CheckActive(var/Name)
			if(src.ActiveBuff&&src.ActiveBuff.BuffName=="[Name]")
				return 1
			return 0
		CheckSpecial(var/Name)
			if(src.SpecialBuff&&src.SpecialBuff.BuffName=="[Name]")
				return 1
			return 0
		CheckSlotless(var/Name)
			if(src.SlotlessBuffs.len!=0)
				return SlotlessBuffs["[Name]"]
				/*for(var/obj/Skills/Buffs/SlotlessBuffs/s in src.SlotlessBuffs)
					if(s.BuffName=="[Name]")
						return s*/
			return 0
		GetSlotless(n)
			if(src.SlotlessBuffs.len!=0)
				if(SlotlessBuffs[n])
					return SlotlessBuffs[n]
		HasMaimMastery()
			var/Return=0
			// if(src.Saga=="Ansatsuken" && src.AnsatsukenAscension=="Chikara")
			// 	Return+=(src.SagaLevel-4)*0.25
			if(passive_handler.Get("MaimMastery"))
				Return+=passive_handler.Get("MaimMastery")
			return Return
		CheckKeybladeStyle(var/Style)
			if(src.StyleActive=="[Style]"&&src.CheckActive("Keyblade"))
				return 1
			return 0
		UsingKeybladeStyle()
			if(src.UsingSpeedRave())
				return 1
			if(src.UsingCriticalImpact() && src.StyleActive!="Momentum Shift")
				return 1
			if(src.UsingSpellWeaver())
				return 1
			if(src.UsingFirestorm())
				return 1
			if(src.UsingDiamondDust())
				return 1
			if(src.UsingThunderbolt())
				return 1
			if(src.UsingWingblade())
				return 1
			if(src.UsingCyclone())
				return 1
			if(src.UsingRockBreaker())
				return 1
			if(src.UsingDarkImpulse())
				return 1
			if(src.UsingGhostDrive())
				return 1
			if(src.UsingBladeCharge())
				return 1
			return 0
		UsingSpeedRave()
			if(src.CheckKeybladeStyle("Speed Rave"))
				return 1
			return 0
		UsingCriticalImpact()
			if(src.CheckKeybladeStyle("Critical Impact"))
				return 1
			if(src.StyleActive=="Momentum Shift")
				return 1
			return 0
		UsingSpellWeaver()
			if(src.CheckKeybladeStyle("Spell Weaver"))
				return 1
			return 0
		UsingFirestorm()
			if(src.CheckKeybladeStyle("Firestorm"))
				return 1
			return 0
		UsingDiamondDust()
			if(src.CheckKeybladeStyle("Diamond Dust"))
				return 1
			return 0
		UsingThunderbolt()
			if(src.CheckKeybladeStyle("Thunderbolt"))
				return 1
			return 0
		UsingWingblade()
			if(src.CheckKeybladeStyle("Wing Blade"))
				return 1
			return 0
		UsingCyclone()
			if(src.CheckKeybladeStyle("Cyclone"))
				return 1
			return 0
		UsingRockBreaker()
			if(src.CheckKeybladeStyle("Rock Breaker"))
				return 1
			return 0
		UsingDarkImpulse()
			if(src.CheckKeybladeStyle("Dark Impulse"))
				return 1
			return 0
		UsingGhostDrive()
			if(src.CheckKeybladeStyle("Ghost Drive"))
				return 1
			return 0
		UsingBladeCharge()
			if(src.CheckKeybladeStyle("Blade Charge"))
				return 1
			return 0
		UsingPridefulRage()
			if(src.HasPridefulRage())
				return 1
			return 0
		UsingSpiritHand()
			if(src.HasSpiritHand())
				return 1
			return 0
/*		UsingHybridStrike()
			if(src.HasSpiritSword())
				return 1
			if(src.HasHybridStrike())
				return 1
			return 0*/
		UsingSpiritStrike()
			if(src.HasSpiritStrike())
				return 1
			return 0
		ElementalAttunement()
			if(src.Attunement)
				return 1
			return 0
		HasMilitaryFrame()
			if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Ripper_Mode, src.contents))
				return 1
			if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Armstrong_Augmentation, src.contents))
				return 1
			if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Ray_Gear, src.contents))
				return 1
			if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Overdrive,src.contents))
				return 1
			if(src.InfinityModule)
				return 1
			return 0
		HasConversionModules()
			var/Total=0
			if(src.FusionPowered)
				Total+=2
			if(src.NanoBoost)
				Total+=5
			if(src.CombatCPU)
				Total+=2
			if(src.BladeMode)
				Total+=2
			if(locate(/obj/Skills/Queue/Cyberize/Taser_Strike, src))
				Total+=1
			if(locate(/obj/Skills/AutoHit/Cyberize/Machine_Gun_Flurry, src))
				Total+=1
			if(locate(/obj/Skills/Projectile/Cyberize/Rocket_Punch, src))
				Total+=1
			if(locate(/obj/Skills/Utility/Internal_Communicator, src))
				Total+=1
			if(src.StabilizeModule)
				Total+=1
			if(src.MeditateModule)
				Total+=3
			return Total
		HasEnhancementChips()
			var/Total=0
			if(src.EnhancedStrength)
				Total+=src.EnhancedStrength
			if(src.EnhancedForce)
				Total+=src.EnhancedForce
			if(src.EnhancedEndurance)
				Total+=src.EnhancedEndurance
			if(src.EnhancedAggression)
				Total+=src.EnhancedAggression
			if(src.EnhancedReflexes)
				Total+=src.EnhancedReflexes
			if(src.EnhancedSpeed)
				Total+=src.EnhancedSpeed
			return Total


		CursedWounds()
			if(passive_handler.Get("CursedWounds"))
				return 1
			if(passive_handler.Get("Curse"))
				return 1
			return 0
		SwordWounds()
			for(var/obj/Items/Sword/s in src)
				if(findtext(s.suffix, "Equipped"))
					if(s.Class == "Wooden" || !s.unsheathed)
						return 0
					if(GetSwordDamage(s)>1)
						return 1
			return 0
			/*if(src.HasSword())
				var/obj/Items/Sword/S=src.EquippedSword()
				if(S.Class=="Wooden")
					return 0
				if(GetSwordDamage(S)>1)
					return 1
			return 0*/

		NeedsSecondSword()
			if(src.HasPassive("NeedsSecondSword", BuffsOnly=1, NoMobVar=1))
				return 1
			if(src.HasPassive("MakesSecondSword", BuffsOnly=1, NoMobVar=1))
				return 1
			else return NeedsThirdSword()
		NeedsThirdSword()
			if(src.HasPassive("NeedsThirdSword", BuffsOnly=1, NoMobVar=1))
				return 1
			if(src.HasPassive("MakesThirdSword", BuffsOnly=1, NoMobVar=1))
				return 1
			return 0
		HasArmor()
			var/obj/Items/Armor/ar=src.EquippedArmor()
			if(ar)
				return 1
			return 0
		HasSword()
			var/s=src.EquippedSword()
			if(s)
				return 1
			return 0
		HasStaff()
			var/s=src.EquippedStaff()
			if(s)
				return 1
			else
				var/obj/Items/Sword/s2=src.EquippedSword()
				if(s2)
					if(s2.MagicSword || passive_handler.Get("MagicSword"))
						return 1
			return 0
		NotUsingMagicSword()
			if(src.HasSword())
				var/obj/Items/Sword/s=src.EquippedSword()
				if(s.MagicSword || src.passive_handler.Get("MagicSword"))
					return 0
			return 1
		HasLightSword()
			var/obj/Items/Sword/s=src.EquippedSword()
			if(s)
				if(s.Class=="Light")
					return 1
			return 0

		HasMediumSword()
			var/obj/Items/Sword/s=src.EquippedSword()
			if(s)
				if(s.Class=="Medium")
					return 1
			return 0
		NoMediumSword()
			var/obj/Items/Sword/s=src.EquippedSword()
			if(s)
				if(s.Class=="Medium")
					return 0
			return 1
		HasHeavySword()
			var/obj/Items/Sword/s=src.EquippedSword()
			if(s)
				if(s.Class=="Heavy")
					return 1
			return 0
		HasWeights()
			if(src.EquippedWeights())
				return 1
			return 0
		EquippedWeights()
			if(equippedWeights)
				return equippedWeights
			return 0

		EquippedArmor()
			if(equippedArmor)
				return equippedArmor
			return 0

		EquippedSword()
			if(equippedSword)
				return equippedSword
			return 0

		EquippedSecondSword()
			var/obj/Items/Sword/sord
			for(var/obj/Items/Sword/s in src)
				if(s.suffix=="*Equipped (Second)*")
					sord=s
					break
			if(sord)
				return sord
			return 0
		EquippedThirdSword()
			var/obj/Items/Sword/sord
			for(var/obj/Items/Sword/s in src)
				if(s.suffix=="*Equipped (Third)*")
					sord=s
					break
			if(sord)
				return sord
			return 0
		UsingDarkElementSword()
			var/obj/Items/Sword/s=src.EquippedSword()
			var/obj/Items/Sword/s2=src.EquippedSecondSword()
			var/obj/Items/Sword/s3=src.EquippedThirdSword()
			if(s)
				if(s.Element=="Dark")
					return 1
			if(s2)
				if(s2.Element=="Dark")
					return 1
			if(s3)
				if(s3.Element=="Dark")
					return 1
			return 0
		UsingLightElementSword()
			var/obj/Items/Sword/s=src.EquippedSword()
			var/obj/Items/Sword/s2=src.EquippedSecondSword()
			var/obj/Items/Sword/s3=src.EquippedThirdSword()
			if(s)
				if(s.Element=="Light")
					return 1
			if(s2)
				if(s2.Element=="Light")
					return 1
			if(s3)
				if(s3.Element=="Light")
					return 1
			return 0
		EquippedStaff()
			var/obj/Items/Enchantment/Staff/staf
			for(var/obj/Items/Enchantment/Staff/s in src)
				if(s.suffix=="*Equipped*")
					staf=s
					break
			if(isRace(ANDROID)||src.HasMechanized())
				return null
			else if(staf)
				return staf
			else
				return null
		CanLoseVitalBP()
			if(isRace(ANDROID))
				return 0
			if(src.HasMechanized())
				return 0
			if(src.passive_handler.Get("StableBP")>=1)
				return 0
			if(src.Kaioken)
				return 0
			if(src.AngerMax==1)
				if(!isRace(CHANGELING))
					return 0
			if(src.SenseUnlocked>5&&src.SenseUnlocked>src.SenseRobbed)
				return 0
			return 1
		CanBeSlowed()
			if(src.HasMythical() > 0.75)
				return 0
			if(src.HasGodspeed()>=glob.CAN_BE_SLOWED_GODSPEED)
				return 0
			if(isRace(ANDROID)/* || isRace(MAJIN)  */)
				return 0
			if(src.CheckSlotless("Berserk"))
				return 0
			if(src.SenseUnlocked>5&&src.SenseUnlocked>src.SenseRobbed)
				return 0
			return 1
		SteadyRace()
			if(src.race.type in list(HUMAN, MAJIN, MAKYO, NAMEKIAN, BEASTMAN, YOKAI, ELDRITCH, ELF, DEMON, DRAGON))
				return 1
			return 0
		TransRace()
			if(isRace(SAIYAN))
				return 1
			return 0
		OtherRace()
			if(isRace(SHINJIN))
				return 1
			return 0
		SureHit()
			if(src.SureHit)
				return 1
			return 0
		NoWhiff()
			if(src.passive_handler.Get("NoWhiff"))
				return 1
			return 0
		Afterimages()
			if(passive_handler.Get("Afterimages"))
				return passive_handler.Get("Afterimages")
			if(src.Afterimages)
				return Afterimages
			return 0

		KBFreeze()
			if(src.EdgeOfMap())
				return 1
			if(src.AerialRecovery==1)
				src.AerialRecovery=0
				return 1
			if(src.AerialRecovery==2)
				src.AerialRecovery=1
				return 1
			return 0
		EdgeOfMap()
			var/turf/t=get_step(src, src.Knockbacked)
			if(!t)
				return 1
			if(t.density>=1)
				return 1
			return 0
		HasSpellFocus(var/obj/Skills/Z)
			var/obj/Items/Enchantment/Staff/st=src.EquippedStaff()
			var/obj/Items/Sword/sord=src.EquippedSword()
			var/Pass=0
			if(src.Saga=="Persona"||src.Saga=="Magic Knight")
				Pass=1
			if(src.is_arcane_beast)
				Pass=1
			if(istype(Z, /obj/Skills/Buffs))
				if(Z:MagicFocus)
					Pass=1
			if(Z.ElementalClass)
				if(src.StyleBuff)
					if(src.StyleBuff.ElementalClass==Z.ElementalClass)
						Pass=1
					else if(istype(src.StyleBuff.ElementalClass, /list))
						if(Z.ElementalClass in src.StyleBuff.ElementalClass)
							Pass=1
			if(passive_handler.Get("SpiritForm"))
				Pass = 1
			if(src.UsingMasteredMagicStyle())
				Pass=1
			if(src.CrestSpell(Z))
				Pass=1
			if(sord)
				if(sord.MagicSword || passive_handler.Get("MagicSword"))
					Pass=1
			if(st)
				Pass=1
			if(src.HasLimitlessMagic())
				Pass=1
			if(src.HasMagicFocus())
				Pass=1
			return Pass

		HasMagicFocus()
			if(passive_handler.Get("MagicFocus"))
				return 1
			return 0
		UsingYinYang()
			if(src.StyleActive=="Balance")
				return 1
			if(src.CheckSpecial("Libra Cloth"))
				return 1
			if(src.CheckSpecial("Ultra Instinct"))
				return 1
			if(CheckSpecial("Heavenly Regalia: The Three Treasures"))
				return 1
			return 0
		HasAdaptation()
			if(src.passive_handler.Get("Adaptation"))
				return 1
			if(src.StyleActive in list("Balance", "Metta Sutra", "West Star", "Shaolin"))
				return 1
			if(src.UsingYinYang())
				return 1
			return 0
		UsingMartialStyle()
			if(src.UsingMasteredMartialStyle())
				return 1
			if(src.StyleActive in list("Fire", "Water", "Earth", "Wind", "Battle Mage", "Flow", "Feral", "Blitz", "Breaker", "Spirit", "Yin Yang", "Soul Crushing", "Resonance", "Tranquil Dove", "Circuit Breaker", "Sunlit Sky", "Inverse Poison", "Devil Leg", "Flow Reversal", "Phage", "Entropy", "Moonlit Lake", "Shunko", "Metta Sutra", "Shaolin", "Blade Singing", "Secret Knife", "Champloo", "Swordless", "Imperial", "East Star", "West Star", "Atomic Karate", "Rhythm of War", "South Star"))
				if(!equippedSword)
					return 1
			return 0
		UsingMasteredMartialStyle()
			if(src.StyleActive in list("Turtle", "Crane", "Snake", "Cat","Black Leg", "Strong Fist", "Gentle Fist","Heavenly", "Lightning Kickboxing", "Golden Kirin","Heavenly Dragon Stance", "Drunken Fist", "North Star", "Imperial Devil"))
				if(!equippedSword)
					return 1
			return 0
		UsingMysticStyle()
			if(!StyleBuff)
				return list(FALSE, FALSE)
				
			if(istype(StyleBuff, /obj/Skills/Buffs/NuStyle/MysticStyle))
				return list(TRUE, StyleBuff.SignatureTechnique)
			return list(FALSE, FALSE)
		UsingMasteredMagicStyle()
			if(src.Saga=="Keyblade")
				if(src.SagaLevel>=4)
					return 1
			if(src.StyleActive in list("Moonlight", "Entropy", "Imperial Devil", "Atomic Karate", "East Star"))
				return 1
			if(src.isRace(DRAGON)&&src.AscensionsAcquired>=3)
				return 1
			if(src.isRace(MAJIN))
				return 1
			return 0
		UsingFencing()
			var/Found=0
			var/obj/Items/Sword/S=src.EquippedSword()
			if(!S) return 0
			Found += passive_handler.Get("Iaijutsu")

			if(S.Class=="Light")
				var/asc = 0 
				if(S.InnatelyAscended)
					asc=S.InnatelyAscended
				else
					asc=S.Ascended
				if(src.HasSwordAscension())
					asc+=src.GetSwordAscension()
				if(asc>6)
					asc=6
				Found+=clamp(round(0.16 + (0.16 * asc),0.25),0.16,1)
			if(src.StyleActive=="Hiten Mitsurugi")
				Found+=1
			if(src.StyleActive=="Sword Savant")
				Found+=0.25 + (0.25 * SagaLevel)
			if(S)
				if(S.ExtraClass&&S.Class=="Light")
					Found+=1
			return Found
		UsingGladiator()
			var/Found=0
			if(src.StyleActive=="Sword Savant")
				Found+=0.25 + (0.125 * SagaLevel)
			if(passive_handler["Disarm"])
				Found = passive_handler["Disarm"]
			return Found
		UsingFTG()
			return passive_handler["Flying Thunder God"]


		InDevaPath()
			// i hate this
			if(CheckSlotless("Rinnegan"))
				if(findRinne().activePath == "Deva")
					return 1
			return 0

		HasSwordPunching()
			if(passive_handler.Get("SwordPunching"))
				return 1
			if(isRace(DEMON)|| (CheckSlotless("Satsui no Hado") && SagaLevel>=6))
				return 1
			if(ClothBronze == "Andromeda" && Saga == "Cosmo")
				return 1
			if(src.CheckSpecial("Libra Cloth"))
				return 0
			if(src.CheckSlotless("Libra Armory"))
				return 0
			return 0




		NotUsingLiving()
			if(src.StyleActive=="Living Weapon")
				return 0
			if(src.StyleActive=="Champloo")
				return 0
			if(src.StyleActive=="Secret Knife")
				return 0
			if(src.StyleActive=="Blade Singing")
				return 0
			if(src.StyleActive=="Shaolin")
				return 0
			if(src.StyleActive=="Rhythm of War")
				return 0
			if(src.StyleActive=="West Star")
				return 0
			if(src.isRace(DEMON) || (CheckSlotless("Satsui no Hado") && SagaLevel>=6))
				return 0
			if(src.Saga == "Cosmo" && src.ClothBronze=="Andromeda")
				return 0
			return 1
		UsingDualWield()
			if(src.StyleActive=="Dual Wield")
				return 1
			if(src.StyleActive=="Trinity Style")
				return 1
			if(src.StyleActive=="Five Rings")
				return 1
			return 0
		UsingTrinityStyle()
			if(src.StyleActive=="Trinity Style")
				return 1
			if(src.StyleActive=="Five Rings")
				return 1
			return 0
		UsingKendo()

			return 0
		NotUsingChamploo()
			if(src.StyleActive=="Secret Knife")
				return 0
			if(src.StyleActive=="Champloo")
				return 0
			if(src.StyleActive=="Blade Singing")
				return 0
			if(src.StyleActive=="Butcher")
				return 0
			if(src.StyleActive=="Shaolin")
				return 0
			if(src.StyleActive=="Rhythm of War")
				return 0
			if(src.StyleActive=="Five Rings")
				return 0
			if(src.StyleActive=="West Star")
				return 0
			if(src.CheckSpecial("Libra Cloth"))
				return 0
			if(src.CheckSlotless("Libra Armory"))
				return 0
			if(src.Saga == "Cosmo" && src.ClothBronze=="Andromeda")
				return 0
			if(src.isRace(DEMON) || (CheckSlotless("Satsui no Hado") && SagaLevel>=6))
				return 0
			return 1
		NotUsingBattleMage()
			if(src.StyleActive=="Battle Mage")
				return 0
			return 1
		UsingAnsatsuken()
			if(src.StyleActive=="Ansatsuken")
				return 1
			return 0
		UsingIronFist()
			if(src.StyleActive=="Iron Skin")
				return 1
			return 0
		UsingThunderFist()
			if(src.StyleActive=="Spark Impulse")
				return 1
			return 0
		UsingSunlight()
			if(src.StyleActive=="Sunlight")
				return 1
			if(src.StyleActive=="Moonlight")
				return 1
			if(src.StyleActive=="Atomic Karate")
				return 1
			if(src.StyleActive=="Imperial Devil")
				return 1
			if(src.StyleActive=="Devil Leg")
				return 1
			return 0
		UsingMoonlight()
			if(src.StyleActive=="Moonlight")
				return 1
			if(src.StyleActive=="Atomic Karate")
				return 1
			if(src.StyleActive&&src.Secret=="Werewolf"&&(!src.CheckSlotless("Half Moon Form")))
				return 1
			return 0
		UsingVoidDefense()
			if(src.ElementalDefense=="Void")
				return 1
			return 0
		HasDarknessFlame()
			if(passive_handler.Get("DarknessFlame"))
				return passive_handler.Get("DarknessFlame")
			return 0
		HasAbsoluteZero()
			if(passive_handler.Get("AbsoluteZero"))
				return 1
			return 0
		UsingVortex()
			if(src.StyleActive=="Tide Trap")
				return 1
			return 0
		UsingUltima()
			if(src.StyleActive=="Atomic Karate")
				return 1
			if(src.ElementalDefense=="Ultima")
				return 1
			return 0
		UsingDireFist()
			if(src.StyleActive=="Dire Wolf")
				return 1
			if(src.StyleActive=="Imperial Devil")
				return 1
			return 0
		UsingTranquilFist()
			if(src.StyleActive=="Tranquil Dove")
				return 1
			if(src.StyleActive=="Dire Wolf")
				return 1
			if(src.StyleActive=="Imperial Devil")
				return 1
			if(src.StyleActive=="Moonlight")
				return 1
			return 0
		UsingAtomicFist()
			if(src.StyleActive=="Atomic Karate")
				return 1
			return 0
		UsingBattleMage()
			if(src.StyleActive=="Battle Mage")
				return 1
			return 0
		UsingMuken()
			if(src.StyleActive=="Ansatsuken"&&src.AnsatsukenAscension=="Chikara"&&src.SagaLevel==6)
				return 1
			return 0
		HasLowWeaponSoul()
			if(src.WeaponSoulType=="Holy Blade"||src.WeaponSoulType=="Corrupt Edge"||src.WeaponSoulType=="Weapon Soul")
				return 1
			return 0
		HasUnmasteredWeaponSoul()
			if(src.HasLowWeaponSoul())
				return 1
			return 0
		WSCaledfwlch()
			if(src.WeaponSoulType=="Caledfwlch")
				return 1
			return 0
		WSKusanagi()
			if(src.WeaponSoulType=="Kusanagi")
				return 1
			return 0
		WSDurendal()
			if(src.WeaponSoulType=="Durendal")
				return 1
			return 0
		WSMasamune()
			if(src.WeaponSoulType=="Masamune")
				return 1
			return 0
		WSSoulCalibur()
			if(src.WeaponSoulType=="Soul Calibur")
				return 1
			return 0
		WSSoulEdge()
			if(src.WeaponSoulType=="Soul Edge")
				return 1
			return 0
		WSMuramasa()
			if(src.WeaponSoulType=="Muramasa")
				return 1
			return 0
		WSDainsleif()
			if(src.WeaponSoulType=="Dainsleif")
				return 1
			return 0
		WSGuanYu()
			if(src.WeaponSoulType=="Green Dragon Crescent Blade")
				return 1
			return 0
		WSMoonlight()
			if(src.WeaponSoulType=="Moonlight Greatsword")
				return 1
			return 0
		GetWeaponSoulType()
			var/obj/Items/Sword/s=src.EquippedSword()
			if(!s) return 0
			if(s.type==/obj/Items/Sword/Light/Legendary/WeaponSoul/Bane_of_Blades)
				return "Muramasa"
			if(s.type==/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin)
				return "Dainsleif"
			if(s.type==/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Order)
				return "Soul Calibur"
			if(s.type==/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Blade_of_Chaos)
				return "Soul Edge"
			if(s.type==/obj/Items/Sword/Light/Legendary/WeaponSoul/Sword_of_Purity)
				return "Masamune"
			if(s.type==/obj/Items/Sword/Medium/Legendary/WeaponSoul/Sword_of_Glory)
				return "Caledfwlch"
			if(s.type==/obj/Items/Sword/Medium/Legendary/WeaponSoul/Sword_of_Faith)
				return "Kusanagi"
			if(s.type==/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Sword_of_Hope)
				return "Durendal"
			if(s.type == /obj/Items/Sword/Wooden/Legendary/WeaponSoul/RyuiJinguBang)
				return "Ryui Jingu Bang"
			if(s.type == /obj/Items/Sword/Heavy/Legendary/WeaponSoul/Spear_of_War)
				return "Green Dragon Crescent Blade"
			if(s.type == /obj/Items/Sword/Heavy/Legendary/WeaponSoul/Sword_of_the_Moon)
				return "Moonlight Greatsword"
			return 0
		WSCorrupt()
			var/obj/Items/Sword/s=src.EquippedSword()
			if(s.type==/obj/Items/Sword/Light/Legendary/WeaponSoul/Bane_of_Blades)
				return 1
			if(s.type==/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Ruin)
				return 1
			if(s.type==/obj/Items/Sword/Medium/Legendary/WeaponSoul/Blade_of_Order)
				return 1
			if(s.type==/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Blade_of_Chaos)
				return 1
			return 0
		WSHoly()
			var/obj/Items/Sword/s=src.EquippedSword()
			if(s.type==/obj/Items/Sword/Light/Legendary/WeaponSoul/Sword_of_Purity)
				return 1
			if(s.type==/obj/Items/Sword/Medium/Legendary/WeaponSoul/Sword_of_Glory)
				return 1
			if(s.type==/obj/Items/Sword/Medium/Legendary/WeaponSoul/Sword_of_Faith)
				return 1
			if(s.type==/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Sword_of_Hope)
				return 1
			if(s.type==/obj/Items/Sword/Heavy/Legendary/WeaponSoul/Sword_of_the_Moon)
				return 1
			return 0
		CanDash()
			if(Frozen||is_dashing||!Target||Target&&!ismob(Target)||Target==src||Beaming==2||TimeFrozen||Knockbacked)
				return FALSE
			return TRUE
		HasTarget()
			if(Target && Target.loc && Target != src)
				return TRUE
			if(!Target)
				return FALSE
		TargetInRange(n)
			if(HasTarget() && get_dist(src, Target) <= n)
				return TRUE
			return FALSE
		CanAttack(ModifyAttack=0)
			if(ModifyAttack >= 0 && (NextAttack-ModifyAttack > world.time))
				return 0
			if(src.BusterCharging)
				return 0
			if(src.Beaming)
				return 0
			if(src.icon_state=="Meditate")
				return 0
			if(src.icon_state=="Train")
				return 0
			if(Knockbacked)
				return 0
			if(src.KO)
				return 0
			if(src.Frozen)
				return 0
			if(src.Stunned)
				return 0
			if(src.Stasis)
				return 0
			if(src.WindingUp)
				return 0
			if(src.AutoHitting)
				return 0
			if(src.TimeFrozen)
				return 0
			if(src.PoweringUp)
				return 0
			if(src.EquippedFlyingDevice())
				return 0
			if(istype(src.loc,/mob))
				return 0
			return 1
		HasMana(var/Value)
			if(src.ManaAmount>=Value)
				return 1
			if(src.HasDrainlessMana())
				return 1
			return 0
		GetMoney()
			for(var/obj/Money/m in src)
				return m.Level
		HasMoney(var/Value=null)
			var/Money=src.GetMoney()
			if(Money>=Value)
				return 1
			return 0
		HasManaCapacity(var/Value, ignorePhiloStone = FALSE)
			var/Total=0
			if(!isRace(ANDROID)&&!HasMechanized())
				Total+=(100-src.TotalCapacity)*src.GetManaCapMult()//Personal reserves
			if(!ignorePhiloStone)
				for(var/obj/Items/Enchantment/PhilosopherStone/PS in src)
					if(!PS.ToggleUse) continue
					Total+=PS.CurrentCapacity
				for(var/obj/Magic_Circle/MC in range(3, src))
					if(!MC.Locked)
						Total/=0.9
					else
						if(MC.Creator==src.ckey)
							Total/=0.75
					break
			if(Total>=Value)
				return 1
			return 0

		NeedSpellFocii(var/obj/Skills/b)
			if(!b) return
			if(StyleActive=="Ansatsuken")	return
			if(b.ManaCost)
				if(b.Copyable>0 && b.Copyable < 3) return 0
				else if(HasLimitlessMagic()) return 0
				else if(CrestSpell(b)) return 0
				else return 1
			return 0

		InMagitekRestrictedRegion()
			if(usr.z in ArcaneRealmZ) return 3 //Will eventually use a list to make specific restrictions.
			return 0

		usingStyle(parentType)
			if(!StyleBuff)
				return FALSE
			var/string = "[StyleBuff.type]"
			if((findtext(string,parentType)))
				return TRUE
			if(passive_handler["HybridStyle"] == "[parentType]")
				return TRUE
			return FALSE
		isInnovative(reqRace, path)
			if(!glob.SAGAINNOVATION)
				if(Saga&&Saga!="Keyblade")
					return FALSE
			// if(reqRace == HUMAN) return
			if(isRace(reqRace) || path == "Any" && reqRace == ELF && Saga=="Keyblade")
				if(passive_handler.Get("Innovation"))
					switch(path)
						if("Sword")
							if(usingStyle("SwordStyle"))
								return TRUE
						if("Unarmed")
							if(usingStyle("UnarmedStyle"))
								return TRUE
						if("Universal")
							if(usingStyle("FreeStyle"))
								return TRUE
						if("Mystic")
							if(usingStyle("MysticStyle")) // this is a mystic style
								return TRUE
						if("Any")
							if(StyleBuff)
								return TRUE

atom
	proc
		NoTPZone(var/dead_use=0, var/arc_use=0)
			var/SP=0
			if(istype(src, /mob/Players))
				if(src:HasSpiritPower())
					SP=1
			if(src.z == glob.DEATH_LOCATION[3] && !dead_use && !SP)
				return 1
			else if(src.z == 1)
				return 1
			else if(src.z == global.ArcaneRealmZ && !arc_use)
				return 1
			return 0

proc
	FightingSeriously(var/mob/Offender=0, var/mob/Defender=0)
		if(Offender)
			if(Offender.Lethal)
				return 1
			if(Offender.WoundIntent)
				return 1
			if(Offender.CursedWounds())
				return 1
			if(Offender.SwordWounds())
				return 1
			if(Offender.HasPurity())
				if(Defender&&Defender.IsEvil()||Offender.HasBeyondPurity())
					return 1
		if(Defender)
			if(Defender.Lethal)
				return 1
			if(Defender.WoundIntent)
				return 1
			if(Defender.CursedWounds())
				return 1
			if(Defender.SwordWounds())
				return 1
			if(Defender.HasPurity())
				if(Offender&&Offender.IsEvil()||Defender.HasBeyondPurity())
					return 1
		return 0
