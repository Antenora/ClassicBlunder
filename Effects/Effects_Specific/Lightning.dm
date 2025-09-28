

proc
	LightningStrike(atom/m)
		m.Quake(5)
		var/obj/Effects/fevLightningStrike/S = new
		S.loc=m.loc
		sleep(1)
		S.Strike()
	LightningStrike2(atom/m, var/Offset=0)
		m.Quake(5)
		var/obj/Effects/fevLightningStrike2/S = new
		S.loc=locate(m.x+pick((-2)*Offset,(-1)*Offset, 0, Offset, 2*Offset), m.y+pick((-2)*Offset,(-1)*Offset, 0, Offset, 2*Offset), m.z)
		sleep(1)
		S.Strike()
	LightningStrikeRed(atom/m, var/Offset=0)
		m.Quake(5)
		var/obj/Effects/fevLightningStrikeRed/S = new
		S.loc=locate(m.x+pick((-2)*Offset,(-1)*Offset, 0, Offset, 2*Offset), m.y+pick((-2)*Offset,(-1)*Offset, 0, Offset, 2*Offset), m.z)
		sleep(1)
		S.Strike()
