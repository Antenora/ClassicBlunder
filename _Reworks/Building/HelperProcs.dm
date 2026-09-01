var/list/CARDINAL_DIRECTIONS = list(NORTH, SOUTH, EAST, WEST)
var/list/ORDINAL_DIRECTIONS = list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)

proc/TurfSquare(x1, y1, x2, y2, z, hollow = 0)
	if(x1 > x2) {.=x1; x1=x2; x2=.}
	if(y1 > y2) {.=y1; y1=y2; y2=.}
	if(hollow)
		if(y2-y1<=1 || x2-x1<=1)
			. = block(locate(x1,y1,z),locate(x2,y2,z))
		else
			. = block(locate(x1,y1,z),locate(x1,y2,z)) + block(locate(x2,y1,z),locate(x2,y2,z)) \
							+ block(locate(x1+1,y1,z),locate(x2-1,y1,z)) + block(locate(x1+1,y2,z),locate(x2-1,y2,z))
	else
		. = PlaneBlock(x1, y1, z, x2, y2)

proc/TurfEllipse(x1, y1, x2, y2, z, filled, mob/M)
	if(x1 > x2) {.=x1; x1=x2; x2=.}
	if(y1 > y2) {.=y1; y1=y2; y2=.}
	. = list()
	var/_x
	var/a=x2-x1, b=y2-y1, x=a*b, y=(b&1)*a
	var/absq = (a+1)*(a+1)*(b+1)*(b+1) - x*x - y*y
	_x = round(b/2)
	y1 += _x; y2 -= _x
	while(x >= 0)
		absq -= 4*a*(y+a)
		y += 2*a
		var/dx = 0
		while(absq < 0 && x >= 0)
			++dx
			absq -= 4*b*(b-x)
			x -= 2*b
		if(filled || x < 0)
			if(y1 != y2)
				for(_x in x1 to x2)
					var/turf/toCheck = locate(_x, y1, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
					toCheck = locate(_x, y2, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
			else
				for(_x in x1 to x2)
					var/turf/toCheck = locate(_x, y1, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
		else
			if(y1 != y2)
				for(_x in x1 to x1+dx)
					var/turf/toCheck = locate(_x, y1, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
					toCheck = locate(_x, y2, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
				for(_x in x2-dx to x2)
					var/turf/toCheck = locate(_x, y1, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
					toCheck = locate(_x, y2, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
			else
				for(_x in x1 to x1+dx)
					var/turf/toCheck = locate(_x, y1, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
				for(_x in x2-dx to x2)
					var/turf/toCheck = locate(_x, y1, z)
					if(toCheck.CanBuildOver(M))
						. += toCheck
		x1 += dx; x2 -= dx; --y1; ++y2

proc/PlaneBlock(x1, y1, z, x2, y2)
	return block(locate(x1, y1, z), locate(x2, y2, z))

proc/TurfLine(x1, y1, x2, y2, z = 1, mob/M)
	. = list()
	var/list/plots = Math.PlotLine(x1, y1, x2, y2)
	for(var/simple_vector/v in plots)
		var/turf/T = locate(v.x, v.y, z)
		if(T.CanBuildOver(M))
			. += T

proc/TurfFloodFill(turf/origin, range = 20, mob/M)
	set background = TRUE
	. = list()
	var/list/turfsToTry = list(origin)
	while(turfsToTry.len)
		var/turf/current = turfsToTry[1]
		turfsToTry.Cut(1, 2)
		if(ValidFillTurf(current, origin, ., M) && get_dist(current, origin) <= range)
			.[current] = TRUE
			for(var/checkDir in CARDINAL_DIRECTIONS)
				turfsToTry.Add(get_step(current, checkDir))

proc/TurfSpanFill(turf/origin, range = 20, mob/M)
	set background = TRUE
	. = list()
	var/list/turfsToTry = list(origin)
	while(turfsToTry.len)
		var/turf/current = turfsToTry[1]
		turfsToTry.Cut(1, 2)
		var/lx = current.x, rx = current.x
		var/turf/checking = current
		while(ValidFillTurf(checking, origin, ., M) && get_dist(checking, origin) <= range)
			lx = checking.x
			.[checking] = TRUE
			turfsToTry.Add(checking)
			checking = get_step(checking, WEST)
		checking = get_step(current, EAST)
		while(ValidFillTurf(checking, origin, ., M) && get_dist(checking, origin) <= range)
			rx = checking.x
			.[checking] = TRUE
			turfsToTry.Add(checking)
			checking = get_step(checking, EAST)
		checking = get_step(current, NORTH)
		for(var/x in lx to rx)
			if(ValidFillTurf(checking, origin, ., M) && get_dist(checking, origin) <= range)
				turfsToTry.Add(checking)
		checking = get_step(current, SOUTH)
		for(var/x in lx to rx)
			if(ValidFillTurf(checking, origin, ., M) && get_dist(checking, origin) <= range)
				turfsToTry.Add(checking)

proc/ValidFillTurf(turf/current, turf/origin, list/selectedTurfs, mob/M)
	return current && isturf(current) && !(current in selectedTurfs) && BuildSameTurf(origin, current) && current.CanBuildOver(M)

proc/BuildSameTurf(turf/A, turf/B)
	return A && B && isturf(A) && isturf(B) && A.name == B.name && A.icon == B.icon && A.type == B.type

turf/proc/DecideTurfStateForSpecialIcons(width = 4, height = 4)
	set waitfor = 0
	set background = 1
	var/X = x % width
	var/Y = y % height
	if(X == 0) X = width
	if(Y == 0) Y = height
	X -= 1
	Y -= 1
	icon_state = "[X],[Y]"

atom/proc/base_loc()
	var/turf/t = src
	var/tries = 5
	while(t && !isturf(t))
		t = t.loc
		tries--
		if(!tries) break
	if(!isturf(t)) return null
	return t

proc/viewable(mob/a, mob/b, max_dist = 5000, seePastDenseObjs = 1)
	if(seePastDenseObjs) return b in range(a, max_dist)
	else return b in view(a, max_dist)
	return (a && a.z) && (b && b.z) && (a.z == b.z) && (getdist(a,b) <= max_dist) && (a != b) && (seePastDenseObjs ? (b in orange(a, max_dist)) : (b in oview(a, max_dist)))
	if(!a.z || !b.z || a.z != b.z) return
	a = a.base_loc()
	b = b.base_loc()
	if(a == b) return 1
	if(getdist(a,b) > max_dist) return
	var/turf/t = a

	while(t && t != b)
		max_dist--
		if(!max_dist) return 1
		t = get_step(t,get_dir(t,b))
		if(!t || t.opacity) return
		else for(var/obj/o in t)
			if(o.opacity) return
			if(!seePastDenseObjs && o.density) return
		sleep(0)

	if(!t || t != b) return
	return 1

proc/getdist(atom/a,atom/b)
	if(!a||!b) return
	return max(abs(a.x-b.x),abs(a.y-b.y))

proc/Circle(n = 5, mob/m, viewable_only = 0)
	if(!m) return
	var/list/l=new
	var/start = locate(m.x - n, m.y - n, m.z)
	var/end = locate(m.x + n, m.y + n, m.z)
	for(var/turf/t in block(start, end))
		if(sqrt((t.x - m.x)**2 + (t.y - m.y)**2) < n)
			if(!viewable_only || viewable(m, t, max_dist = get_dist(m,t)))
				l += t
	return l

proc/CenterIcon(obj/O,Icon,x_only)
	set waitfor = FALSE
	set background = TRUE
	if(!O) return
	if(!Icon) Icon=O.icon
	O.pixel_x = Icon_Center_X(Icon)
	if(!x_only) O.pixel_y = Icon_Center_Y(Icon)

proc/CenterBounds(obj/O,icon/I,x_only)
	if(!O) return
	if(!I) I = icon(O.icon)
	O.bound_x = Icon_Center_X(I)
	O.bound_width = I.Width()
	if(!x_only)
		O.bound_y = Icon_Center_Y(I)
		O.bound_height = I.Height()

proc/Icon_Center_X(O)
	var/icon/I=new(O)
	return -((I.Width()-TILE_WIDTH)*0.5)

proc/Icon_Center_Y(O)
	var/icon/I=new(O)
	return -((I.Height()-TILE_HEIGHT)*0.5)

proc/Scaled_Icon(O,X,Y)
	var/icon/I=new(O)
	if(X && Y) I.Scale(X,Y)
	return I

proc/GetWidth(O)
	var/icon/I=new(O)
	return I.Width()

proc/GetHeight(O)
	var/icon/I=new(O)
	return I.Height()


var/global/math/Math = new
var/global/math/int/MathI = new

math/int
	HandleOutput(x)
		return round(x)

math
	var/const
		E = 2.718281828
		PI = 3.141592653
		HYPOT = 1.414213562

	proc
		HandleOutput(x)
			return x

		Lerp(a, b, t)
			return HandleOutput(a+(b-a)*t)

		Cerp(a, b, t)
			var/f = (1-cos(t*PI)) * 0.5
			return HandleOutput(a*(1-f)+b*f)

		Bias(x, bias)
			var/k = Pow(1-bias, 3)
			var/denominator = (x * k - x + 1)
			if(denominator == 0) return 0
			return HandleOutput((x * k) / denominator)

		Sigmoid(x)
			return Inverse(1 + Exp(-x))

		Falloff(x, r = 0.01)
			return Exp(-r * x)

		Exp(n)
			return HandleOutput(E**n)

		Pow(x, y=2)
			return HandleOutput(x**y)

		Hypot(a, b)
			if(!b) return a * HYPOT
			return Sqrt(Pow(a) + Pow(b))

		Sin(x)
			return HandleOutput(sin(x))

		Arcsin(x)
			return HandleOutput(arcsin(x))

		Cos(x)
			return HandleOutput(cos(x))

		Arccos(x)
			return HandleOutput(arccos(x))

		Tan(x)
			return HandleOutput(tan(x))

		Arctan(x, y)
			return HandleOutput(y ? arctan(x,y) : arctan(x))

		Clamp(num, a, b)
			return HandleOutput(clamp(num, a, b))

		Min(a, b)
			return HandleOutput(min(a, b))

		Max(a, b)
			return HandleOutput(max(a, b))

		Abs(x)
			return HandleOutput(abs(x))

		IsEven(x)
			return x % 2 == 0

		Prob(x)
			return prob(x)

		Rand(a, b)
			if(a)
				if(b)
					return HandleOutput(rand(a, b))
				return HandleOutput(rand(Max(0, a), Min(0, a)))
			return HandleOutput(rand())

		Seed(x)
			rand_seed(x)

		Floor(x)
			return HandleOutput(round(x))

		FloorN(x, N)
			return HandleOutput((round((x)/(N)) * (N)))

		Ceil(x)
			return HandleOutput((-round(-(x))))

		CeilN(x, N)
			return HandleOutput((-round(-(x)/(N)) * (N)))

		Round(x, y)
			return HandleOutput(round(x, y))

		Sqrt(x)
			return HandleOutput(sqrt(x))

		Log(x)
			return HandleOutput(log(x))

		Log10(x)
			return HandleOutput(log(10, x))

		Mean()
			if(!args || !args?.len) return 0
			var/total = 0, n = args?.len
			for(var/x in args)
				if(!isnum(x)) continue
				total += x
			return HandleOutput(total / n)

		Mode()
			var/list/keys = list()
			for(var/x in args)
				if(keys[x]) keys[x]++
				else keys[x] = 1
			var/num
			for(var/x in keys)
				if(!num) num = x
				else if(keys[num] < keys[x]) num = x
			return HandleOutput(num)

		Factorial(n, r=0)
			if(n in list(0, 1, 2)) return n
			switch(r)
				if(0) r = n
				if(1) return n
				if(2) return n * (n - 1)
			var/result = n
			for(var/c in 1 to (r-1))
				result *= (n - c)
			return HandleOutput(result)

		Delta(a1, a2)
			return HandleOutput(a2 - a1)

		Line(slope, x, y_intercept = 0)
			return HandleOutput(slope * x + y_intercept)

		Slope(x1, y1, x2, y2)
			var/deltaX = Delta(x1, x2)
			var/deltaY = Delta(y1, y2)
			return HandleOutput(deltaY / deltaX)

		ValueFromPercentInRange(min, max, percent)
			return HandleOutput((percent * (max - min) / 100) + min)

		PercentFromValueInRange(min, max, value)
			return HandleOutput(((value - min) * 100) / (max - min))

		Inverse(n)
			return HandleOutput(1 / n)

		InRange(val, min, max, inclusive = 1)
			if(inclusive)
				return min <= val && max >= val
			return min < val && max > val

		PlotLine(x1, y1, x2, y2)
			if(Abs(Delta(y1, y2)) < Abs(Delta(x1, x2)))
				if(x1 > x2)
					return PlotLineLow(x2, y2, x1, y1)
				else
					return PlotLineLow(x1, y1, x2, y2)
			else
				if(y1 > y2)
					return PlotLineHigh(x2, y2, x1, y1)
				else
					return PlotLineHigh(x1, y1, x2, y2)

		PlotLineLow(x1, y1, x2, y2)
			var/list/plots = list()
			var/dx = Delta(x1, x2), dy = Delta(y1, y2), yi = 1
			if(dy < 0)
				yi = -1
				dy = -dy
			var/diff = (2 * dy) - dx, y = y1

			for(var/x in x1 to x2)
				plots.Add(new/simple_vector(x, y))
				if(diff > 0)
					y += yi
					diff += (2 * (dy - dx))
				else
					diff += 2 * dy
			return plots

		PlotLineHigh(x1, y1, x2, y2)
			var/list/plots = list()
			var/dx = Delta(x1, x2), dy = Delta(y1, y2), xi = 1
			if(dx < 0)
				xi = -1
				dx = -dx
			var/diff = (2 * dx) - dy, x = x1
			for(var/y in y1 to y2)
				plots.Add(new/simple_vector(x, y))
				if(diff > 0)
					x += xi
					diff += (2 * (dx - dy))
				else
					diff += 2 * dx
			return plots

simple_vector
	var
		x
		y
		z

	New(_x = 1, _y = 1, _z = 1)
		x = _x
		y = _y
		z = _z