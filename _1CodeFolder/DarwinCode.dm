client
	verb
		FaceNorth()
			set hidden = 1
			if((src.mob.Beaming>1||src.mob.AutoHitting)&&!src.mob.HasTurningCharge())
				return
			mob.dir = NORTH
		FaceNorthEast()
			set hidden = 1
			if((src.mob.Beaming>1||src.mob.AutoHitting)&&!src.mob.HasTurningCharge())
				return
			mob.dir = NORTHEAST
		FaceNorthWest()
			set hidden = 1
			if((src.mob.Beaming>1||src.mob.AutoHitting)&&!src.mob.HasTurningCharge())
				return
			mob.dir = NORTHWEST
		FaceEast()
			set hidden = 1
			if((src.mob.Beaming>1||src.mob.AutoHitting)&&!src.mob.HasTurningCharge())
				return
			mob.dir = EAST
		FaceWest()
			set hidden = 1
			if((src.mob.Beaming>1||src.mob.AutoHitting)&&!src.mob.HasTurningCharge())
				return
			mob.dir = WEST
		FaceSouth()
			set hidden = 1
			if((src.mob.Beaming>1||src.mob.AutoHitting)&&!src.mob.HasTurningCharge())
				return
			mob.dir = SOUTH
		FaceSouthEast()
			set hidden = 1
			if((src.mob.Beaming>1||src.mob.AutoHitting)&&!src.mob.HasTurningCharge())
				return
			mob.dir = SOUTHEAST
		FaceSouthWest()
			set hidden = 1
			if((src.mob.Beaming>1||src.mob.AutoHitting)&&!src.mob.HasTurningCharge())
				return
			mob.dir = SOUTHWEST

