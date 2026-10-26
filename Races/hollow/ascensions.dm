ascension
	hollow
		proc
			HollowAscensionSettle(mob/owner)
				if(!owner)
					return
				owner.HollowSyncPower()
				owner.HollowSyncSkills()

			HollowVastoStep(mob/owner, sign)
				if(!owner || owner.HollowStage != HOLLOW_STAGE_VASTO)
					return
				var/step = HOLLOW_VASTO_MOD_STEP * sign
				owner.StrMod += step
				owner.EndMod += step
				owner.ForMod += step
				owner.OffMod += step
				owner.DefMod += step
				owner.SpdMod += step

		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			strength = 0.25
			force = 0.25
			endurance = 0.25
			onAscension(mob/owner)
				. = ..()
				if(!.)
					return
				if(owner.HollowStage == HOLLOW_STAGE_BASE)
					owner.HollowSetStage(HOLLOW_STAGE_GILLIAN)
				HollowAscensionSettle(owner)

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			anger = 0.25
			strength = 0.25
			force = 0.25
			endurance = 0.25
			offense = 0.25
			defense = 0.25
			onAscension(mob/owner)
				. = ..()
				if(!.)
					return
				HollowAscensionSettle(owner)

		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			anger = 0.25
			strength = 0.5
			force = 0.5
			endurance = 0.5
			onAscension(mob/owner)
				. = ..()
				if(!.)
					return
				HollowAscensionSettle(owner)
				owner.HollowVastoRollCheck()

		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			anger = 0.25
			onAscension(mob/owner)
				. = ..()
				if(!.)
					return
				HollowVastoStep(owner, 1)
				HollowAscensionSettle(owner)
				owner.HollowVastoRollCheck()
			revertAscension(mob/owner)
				if(!applied || pickingChoice)
					return
				HollowVastoStep(owner, -1)
				..()
				HollowAscensionSettle(owner)

		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			anger = 0.25
			onAscension(mob/owner)
				. = ..()
				if(!.)
					return
				HollowVastoStep(owner, 1)
				HollowAscensionSettle(owner)
				owner.HollowVastoRollCheck()
			revertAscension(mob/owner)
				if(!applied || pickingChoice)
					return
				HollowVastoStep(owner, -1)
				..()
				HollowAscensionSettle(owner)

		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			anger = 0.25
			onAscension(mob/owner)
				. = ..()
				if(!.)
					return
				HollowVastoStep(owner, 1)
				HollowAscensionSettle(owner)
				owner.HollowVastoRollCheck()
			revertAscension(mob/owner)
				if(!applied || pickingChoice)
					return
				HollowVastoStep(owner, -1)
				..()
				HollowAscensionSettle(owner)
