#define TileHeight 32
#define TileWidth 32
/proc/getLowestInList(thing, list, valueofthing)
	var/lowest
	var/lowest_value = 1#INF
	for(thing in list)
		var/value = valueofthing
		if(value < lowest_value)
			lowest = thing
			lowest_value = value
	return lowest


/*
atom/movable
	var
		camera_x = 0
		camera_y = 0

camera
	name = "The Camera"
	density = 0
	invisibility = 101
	parent_type = /mob
	var
		atom/movable/target
		tracking_factor = 1/8
	proc
		Track()
			if(target && loc)
				var/xpos = x*TILE_WIDTH + step_x
				var/ypos = y*TILE_HEIGHT + step_y
				var/dx = target.x*TILE_WIDTH + target:step_x + camera_x + target:camera_x - xpos
				var/dy = target.y*TILE_HEIGHT + target:step_y + camera_y + target:camera_y - ypos

				// Artificially increase tracking factor to ensure at least 1 pixel of movement
				var/maxdist = max(abs(dx), abs(dy))
				var/tf = tracking_factor
				if(maxdist)
					tf = max(min(1, 1/maxdist), tf)
				else
					return

				var/xoff = dx * tf + xpos
				var/yoff = dy * tf + ypos

				loc = locate(xoff/TILE_WIDTH, yoff/TILE_HEIGHT, target.z)
				step_x = xoff - (x * TILE_WIDTH)
				step_y = yoff - (y * TILE_HEIGHT)

		Recenter()
			if(target)
				loc = target.loc
				step_x = target.step_x
				step_y = target.step_y

		Destroy()
			target = null
			loc = null

	New(loc,step_x,step_y)
		src.step_x = step_x
		src.step_y = step_y
		..()

client
	var
		camera/camera
	New()
		. = ..()
		camera = new(mob.loc,mob.step_x,mob.step_y)
		eye = camera
		camera.target = mob
		CameraLoop()

	Del()
		camera.Destroy()
		camera = null
		..()
	verb
		changeTrackingTest(n as num)
			camera.tracking_factor = 1/n
	proc
		CameraLoop()
			set waitfor = 0
			while(camera)
				camera.Track()
				sleep(world.tick_lag)
*/
/* Adds:
	- Pixel position vectors: LowerPosition, CenterPosition
	- Pixel movement helpers: PixelMove, PixelSlide, PixelMoveTo
	- Pixel position setters: SetLowerTo, SetCenterTo
*/

atom/movable
	Move()
		. = ..()
		if(. && standing)
			UpdateStandingLayer()
	proc
		/* Move along a line according to the given pixel offsets.
			Also accepts a vector2.
			Returns Move() and changes step_size.
		*/
		PixelMove(move_x, move_y)
			if(istype(move_x, /vector2))
				var vector2/v = move_x
				move_x = v.x
				move_y = v.y

			if(!(move_x || move_y))
				return 0

			// Enable sliding to anywhere in the world.
			step_size = 1#INF

			// Move without changing dir and return the result.
			. = Move(loc, dir, step_x + move_x, step_y + move_y)

			// Set step_size to the amount actually moved.
			// This tells clients to smoothly interpolate this when using client.fps.
			step_size = 1 + .

		/* Attempt to move along the line. If that fails, try moving in one axis at a time.
			Returns PixelMove().
		*/
		PixelSlide(move_x, move_y)
			if(istype(move_x, /vector2))
				var vector2/v = move_x
				move_x = v.x
				move_y = v.y

			if(!(move_x || move_y))
				return 0

			// Move straight
			. = PixelMove(move_x, move_y)
			if(!.)
				// Or move horizontally
				. = PixelMove(move_x, 0)

				// Then move vertically
				if(.)
					. = max(., PixelMove(0, move_y))

				// Or move vertically, then horizontally
				else
					. = max(PixelMove(0, move_y), PixelMove(move_x, 0))

			// Set step size to the amount actually moved. (See PixelMove)
			step_size = 1 + .

		/* Move in a straight line to a target position on the same z-level.
			Returns PixelMove().
		*/
		PixelMoveTo(target_x, target_y)
			if(istype(target_x, /vector2))
				var vector2/v = target_x
				target_x = v.x
				target_y = v.y
			else if(istype(target_x, /atom))
				var atom/a = target_x
				target_x = a.CenterX()
				target_y = a.CenterY()
			return PixelMove(target_x - CenterX(), target_y - CenterY())

		/* Set the lower position of a movable atom according to a world pixel position.
			Also accepts a vector2 or an atom (aligns lower corners).
		*/
		SetLowerTo(lower_x, lower_y, z)
			if(istype(lower_x, /vector2))
				var vector2/v = lower_x
				z = lower_y
				lower_x = v.x
				lower_y = v.y
			else if(istype(lower_x, /atom))
				var atom/a = lower_x
				lower_x = a.LowerX()
				lower_y = a.LowerY()
				z = a.z

			if(!z) z = src.z

			var/tile_x = 1 + round((lower_x - 1) / TileWidth)
			var/tile_y = 1 + round((lower_y - 1) / TileHeight)
			var/step_x = (lower_x - 1) - (tile_x - 1) * TileWidth
			var/step_y = (lower_y - 1) - (tile_y - 1) * TileHeight

			// Normalize to within the map edges
			if(tile_x < 1)
				step_x += TileWidth * (tile_x - 1)
				tile_x = 1
			if(tile_x > world.maxx)
				step_x += TileWidth * (tile_x - world.maxx)
				tile_x = world.maxx
			if(tile_y < 1)
				step_y += TileHeight * (tile_y - 1)
				tile_y = 1
			if(tile_y > world.maxy)
				step_y += TileHeight * (tile_y - world.maxy)
				tile_y = world.maxy

			loc = locate(tile_x, tile_y, z)
			src.step_x = step_x - bound_x
			src.step_y = step_y - bound_y

		/* Set the center position to a world pixel position.
			Also accepts a vector2 or an atom (aligns centers).
		*/
		SetCenterTo(center_x, center_y, z)
			if(istype(center_x, /vector2))
				var vector2/v = center_x
				z = center_y
				center_x = v.x
				center_y = v.y
			else if(istype(center_x, /atom))
				var atom/a = center_x
				center_x = a.CenterX()
				center_y = a.CenterY()
				z = a.z

			SetLowerTo(
				center_x - bound_width / 2,
				center_y - bound_height / 2,
				z)
/*
	This library adds procs to /atom that return what's known as
		"world pixel coordinates" or "absolute pixel coordinates"
		of the atom. When not using tile-based movement, it's best
		to think in terms of these coordinates and

			forget that tile movement is a thing.

		(See my Sub-Pixel Movement library for another way
		to avoid tile-based code.)

	* Size()
	* Width()
	* Height()
		The width and height of the atom, in pixels.
		For example, by default, all atoms are 32x32,
			so the Width() and Height() are 32.
		For turfs, this is the same as world.icon_size.
		For movables, this returns bound_width or bound_height.

	* LowerPosition()
	* LowerX()
	* LowerY()
		The lower x and y coordinates of the atom, in pixels.
		The bottom-left corner of the world is (1, 1).

	* CenterPosition()
	* CenterX()
	* CenterY()
		The central x and y coordinates of the atom, in pixels.
		This depends on the position of the atom as well as
			the size of the atom's bounding box, which is defined by
			the bounds variables (bound_width, bound_height).
*/
			
atom
	var/standing = FALSE
	New()
		..()
		if(standing)
			UpdateStandingLayer()
	proc
		UpdateStandingLayer()
			layer = FLY_LAYER - LowerY() / world.maxy*TileHeight * 1e-3
		/*
			Width of the atom, in pixels.
		*/
		Width()
			return TileWidth

		/*
			Height of the atom, in pixels.
		*/
		Height()
			return TileHeight

		/*
			World pixel x-coordinate of the left edge of this atom, in pixels.
		*/
		LowerX()
			return 1 + (x - 1) * TileWidth

		/*
			World pixel y-coordinate of the bottom edge of this atom, in pixels.
		*/
		LowerY()
			return 1 + (y - 1) * TileHeight

		/*
			World pixel x-coordinate of the center of this atom, in pixels.
		*/
		CenterX()
			return LowerX() + Width() / 2

		/*
			World pixel y-coordinate of the center of this atom, in pixels.
		*/
		CenterY()
			return LowerY() + Height() / 2
		TopY()
			return LowerY() + Height() / 1.5
		TopX()
			return LowerX() + Width() / 1.5
		TopPosition()
			return new/vector2(TopX(),TopY())
		/* World pixel coordinates of the lower corner of the bounding box.
		*/
		LowerPosition()
			return new/vector2(LowerX(), LowerY())

		/* World pixel coordinates of the center of the bounding box.
		*/
		CenterPosition()
			return new/vector2(CenterX(), CenterY())

		/* Size of the atom, in pixels.
		*/
		Size()
			return new/vector2(Width(), Height())

	/*
		Movables have finer details, such as different sizes and
			not being aligned with the tile grid,
			so these overrides include that information.
	*/
	movable
		Width()
			return bound_width

		Height()
			return bound_height

		LowerX()
			return ..() + bound_x + step_x

		LowerY()
			return ..() + bound_y + step_y

/*
Direction datum
	This datum's constants support bit flags and uses BYOND's built-in directional constants.

	Name		| Direction		| Value
	============+===============+===================

	Center		N/A				0

	North		+Y (up)			1	(NORTH)
	South		-Y (down)		2	(SOUTH)
	East		+X (right)		4	(EAST)
	West		-X (left)		8	(WEST)

	Northeast	+X, +Y			5	(North | East)
	Northwest	-X, +Y			6	(North | West)
	Southeast	+X, -Y			9	(South | East)
	Southwest	-X, -Y			10	(South | West)

	Up			+Z				16	(UP)
	Down		-Z				32	(DOWN)

	Horizontal	N/A				12	(East  | West)
	Vertical	N/A				3	(North | South)
	Planar		N/A				15	(North | South | East| West)

Direction methods
	This datum has methods in addition to the inherited methods of the /Constants type.

	IsDiagonal(Directions/Direction)
		Returns TRUE if Direction is a diagonal direction
		(i.e. northeast, southeast, northwest, southwest).

	IsCardinal(Directions/Direction)
		Returns TRUE if Direction is a cardinal direction
		(i.e. north, south, east, west, up, down).

	FromOffset(X, Y)
		Returns a Direction that is closest to the direction of (X, Y).

	FromOffsetToCardinal(X, Y)
		Returns a cardinal Direction that is closest to the direction of (X, Y).

	FromOffsetExact(X, Y)
		Returns a Direction that somewhat points in the direction of (X, Y).
		If either X or Y is zero, this results in a cardinal direction.
		If X and Y are non-zero, this results in a diagonal direction.
		This is similar to get_dir() in that it's a pretty
		bad approximation in a realistic sense.

	ToOffsetX(Directions/Direction)
		Returns 1 for directions pointing toward the east.
		Returns -1 for directions pointing toward the west.
		Returns 0 otherwise.

	ToOffsetY(Directions/Direction)
		Returns 1 for directions pointing toward the north.
		Returns -1 for directions pointing toward the south.
		Returns 0 otherwise.

	ToDegrees(Directions/Direction)
		Returns an angle in degrees pointing in the given direction.
		North is 0 degrees.
		East is 90 degrees.
		West is -90 degrees.

	FromDegrees(Degrees)
		Returns the closest Direction in the same direction as the given number of Degrees.

	FromOffsetToDegrees(X, Y)
		Returns an angle in degrees pointing in the direction of a given offset.
		(0, 1) is 0 degrees
		(1, 0) is 90 degrees
		(-1, 0) is -90 degrees.

	CancelOpposing(Directions/directions)
		Cancels out opposing directional flags from a given direction combination.
		e.g. CancelOpposing(North | South | East) == East because North and South cancel out.

*/

var/Directions/Directions = new

Directions
	//parent_type = /Constants
	var/const
		Center = 0
		North = NORTH
		South = SOUTH
		East = EAST
		West = WEST
		Northeast = North | East
		Southeast = South | East
		Northwest = North | West
		Southwest = South | West
		Horizontal = East | West
		Vertical = North | South
		Planar = Horizontal | Vertical
		Up = UP
		Down = DOWN

	proc
		ToDegrees(Directions/Direction)
			var global/dir_to_angle[] = list(
				0, 180, 0, 90, 45, 135, 90, -90, -45, -135, -90, 0, 0, 180, 0)
			return dir_to_angle[Direction]

		FromOffsetToDegrees(X, Y)
			return (X || Y) && \
				(X >= 0 ? arccos(Y / sqrt(X*X + Y*Y)) : -arccos(Y / sqrt(X*X + Y*Y)))

		IsDiagonal(Directions/Direction)
			return !!(Direction & Direction - 1)

		IsCardinal(Directions/Direction)
			return !(Direction & Direction - 1)

		ToOffsetX(Directions/Direction)
			var global/to_offset_x[] = list(0, 0, 0, 1, 1, 1, 1, -1, -1, -1, -1, 0, 0, 0)
			return Direction && to_offset_x[Direction & Planar]

		ToOffsetY(Directions/Direction)
			var global/to_offset_y[] = list(1, -1, 0, 0, 1, -1, 0, 0, 1, -1, 0, 0, 1, -1, 0)
			return Direction && to_offset_y[Direction & Planar]

		FromDegrees(Degrees)
			var global/from_degrees[] = list(
				North, Northeast, East, Southeast, South, Southwest, West, Northwest)
			return from_degrees[1 + round(8 + Degrees * 8 / 360, 1) % 8]

		FromDegreesToCardinal(Degrees)
			var global/from_degrees[] = list(North, East, South, West)
			return from_degrees[1 + round(4 + Degrees * 4 / 360, 1) % 4]

		FromOffsetExact(X, Y)
			return (X ? X > 0 ? East : West : Center) | (Y ? Y > 0 ? North : South : Center)

		FromOffset(X, Y)
			var Directions/direction = FromOffsetExact(X, Y)
			if(IsDiagonal(direction))
				var ax = abs(X)
				var ay = abs(Y)
				if(ax >= ay * 2) return direction & Horizontal
				else if(ay >= ax * 2) return direction & Vertical
			return direction

		FromOffsetToCardinal(X, Y)
			var Directions/direction = FromOffsetExact(X, Y)
			if(IsDiagonal(direction))
				var ax = abs(X)
				var ay = abs(Y)
				if(ax >= ay) return direction & Horizontal
				else if(ay >= ax) return direction & Vertical
			return direction

		CancelOpposing(Directions/directions)
			var global/list/cancellations = list(
				Center, // 0: Center
				North, // 1: North
				South, // 2: South
				Center, // 3: North + South
				East, // 4: East
				Northeast, // 5: North + East
				Southeast, // 6: South + East
				East, // 7: North + South + East
				West, // 8: West
				Northwest, // 9: North + West
				Southwest, // 10: South + West
				West, // 11: North + South + West
				Center, // 12: East + West
				North, // 13: North + East + West
				South, // 14: South + East + West
				Center // 15: North + South + East + West
			)
			return cancellations[directions + 1]


proc
	hypot(x, y)
		if(x || y)
			var t
			x = abs(x)
			y = abs(y)
			if(x <= y)
				t = x
				x = y
			else
				t = y
			t /= x
			return x * sqrt(1 + t * t)
		return 0
/* A 2D vector datum with overloaded operators and other common functions.
*/

vector2
	var/x
	var/y
	/* Takes 2 numbers or a vector2 to copy.
	*/
	New(x = 0, y = 0)
		..()
		if(isnum(x)) if(!isnum(y)) y = x

		else if(istype(x, /vector2))
			var vector2/v = x
			x = v.x
			y = v.y

		else CRASH("Invalid args.")

		src.x = x
		src.y = y

	proc
		/* Equivalence checking. Compares components exactly.
		*/
		operator~=(vector2/v) return v ? x == v.x && y == v.y : FALSE

		/* Vector addition.
		*/
		operator+(vector2/v) return v ? new/vector2(x + v.x, y + v.y) : src

		/* Vector subtraction and negation.
		*/
		operator-(vector2/v) return v ? new/vector2(x - v.x, y - v.y) : new/vector2(-x, -y)

		/* Vector scaling.
		*/
		operator*(s)
			// Scalar
			if(isnum(s)) return new/vector2(x * s, y * s)

			// Transform
			else if(istype(s, /matrix))
				var matrix/m = s
				return new/vector2(x * m.a + y * m.b + m.c, x * m.d + y * m.e + m.f)

			// Component-wise
			else if(istype(s, /vector2))
				var vector2/v = s
				return new/vector2(x * v.x, y * v.y)

			else CRASH("Invalid args.")

		/* Vector inverse scaling.
		*/
		operator/(d)
			// Scalar
			if(isnum(d)) return new/vector2(x / d, y / d)

			// Inverse transform
			else if(istype(d, /matrix)) return src * ~d

			// Component-wise
			else if(istype(d, /vector2))
				var vector2/v = d
				return new/vector2(x / v.x, y / v.y)

			else CRASH("Invalid args.")

		/* Vector dot product.
			Returns the cosine of the angle between the vectors.
		*/
		Dot(vector2/v) return x * v.x + y * v.y

		/* Z-component of the 3D cross product.
			Returns the sine of the angle between the vectors.
		*/
		Cross(vector2/v) return x * v.y - y * v.x

		/* Square of the magnitude of the vector.
			Commonly used for comparing magnitudes more efficiently than with Magnitude.
		*/
		SquareMagnitude() return Dot(src)

		/* Magnitude of the vector.
		*/
		Magnitude() return hypot(x, y)

		/* Get a vector in the same direction but with magnitude m.
			Be careful about dividing by zero. This won't work with the zero vector.
		*/
		ToMagnitude(m)
			if(isnum(m)) return src * (m / Magnitude())
			else CRASH("Invalid args.")

		/* Get a vector in the same direction but with magnitude 1.
		*/
		Normalized() return ToMagnitude(1)

		/* Convert the vector to text with a specified number of significant figures.
		*/
		ToText(SigFig) return "vector2([num2text(x, SigFig)], [num2text(y, SigFig)])"

		/* Get the components via index (1, 2) or name ("x", "y").
		*/
		operator[](index)
			switch(index)
				if(1, "x") return x
				if(2, "y") return y
				else CRASH("Invalid args.")

		/* Get the matrix that rotates north to point in this direction.
			This can be used as the transform of an atom whose icon is drawn pointing north.
		*/
		Rotation() return RotationFrom(Vector2.North)

		/* Get the matrix that rotates from_vector to point in this direction.
			This can be used as the transform of an atom whose icon is drawn pointing in the direction of from_vector.
			Also accepts a dir.
		*/
		RotationFrom(vector2/from_vector = Vector2.North)
			var vector2/to_vector = Normalized()

			if(isnum(from_vector)) from_vector = Vector2.FromDir(from_vector)

			if(istype(from_vector, /vector2))
				from_vector = from_vector.Normalized()
				var/cos_angle = to_vector.Dot(from_vector)
				var/sin_angle = to_vector.Cross(from_vector)
				return matrix(cos_angle, sin_angle, 0, -sin_angle, cos_angle, 0)

			else CRASH("Invalid 'from' vector.")

		/* Get a vector with the same magnitude rotated by a clockwise angle in degrees.
		*/
		Turn(angle) return src * matrix().Turn(angle)


/* Adds vector2 support to matrix procs.
*/

matrix
	/* Translate by a vector2.
	*/
	Translate(x, y)
		if(istype(x, /vector2))
			var vector2/v = x
			return ..(v.x, v.y)
		return ..()

	/* Scale by a vector2.
	*/
	Scale(x, y)
		if(istype(x, /vector2))
			var vector2/v = x
			return ..(v.x, v.y)
		return ..()


/* Common vectors.
	Make sure you don't modify these vectors.
	You should treat all vectors as immutable in general.
*/
var/Vector2/Vector2 = new
Vector2
	var/vector2/Zero = new(0, 0)
	var/vector2/One = new(1, 1)
	var/vector2/North = new(0, 1)
	var/vector2/South = new(0, -1)
	var/vector2/East = new(1, 0)
	var/vector2/West = new(-1, 0)
	var/vector2/Northeast = new(0.707106781187, 0.707106781187)
	var/vector2/Northwest = new(-0.707106781187, 0.707106781187)
	var/vector2/Southeast = new(0.707106781187, -0.707106781187)
	var/vector2/Southwest = new(-0.707106781187, -0.707106781187)

	proc
		FromDir(dir)
			switch(dir)
				if(NORTH) return North
				if(SOUTH) return South
				if(EAST) return East
				if(WEST) return West
				if(NORTHEAST) return Northeast
				if(SOUTHEAST) return Southeast
				if(NORTHWEST) return Northwest
				if(SOUTHWEST) return Southwest
				else CRASH("Invalid direction.")

/* Adds client.ViewportToWorldPoint().
*/
client
	proc
		/* Takes a point relative to the viewport (1,1 is the bottom-left pixel of the viewport)
			and an optional transform of the world plane (in case you transform the world plane via plane master).
			Should work in isometric too.
		*/
		ViewportToWorldPoint(vector2/view_point, matrix/world_plane_transform = null)
			var matrix/viewport_matrix
			switch(world.map_format)
				if(ISOMETRIC_MAP)
					viewport_matrix = matrix(
						1, -2, bound_x + bound_height / 2 + 1,
						1,  2, bound_y - bound_width / 2 - 3)
				else
					viewport_matrix = matrix(
						1, 0, bound_x - 1,
						0, 1, bound_y - 1)

			if(world_plane_transform)
				var vector2/to_center = new(bound_width / 2, bound_height / 2)
				return (to_center + (view_point - to_center) / world_plane_transform) * viewport_matrix
			else
				return view_point * viewport_matrix
