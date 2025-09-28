atom/movable/proc
	move_to(turf/destination, delay=5)
		var/list/path = get_path(src.loc, destination)

		if(path)
			//src << "Path calculated. [path.len] [path.len==1 ? "step" : "steps"] to destination."
			return src.follow_path(path, delay)
		else return 0


	follow_path(list/path, delay=5)
		for(var/turf/t in path)
			if(src.Move(t))
				sleep(delay)
			else   // recalculate path
				var/turf/destination = path[path.len]
				return src.move_to(destination, delay)
		return 1








turf/var/path_weight = 1	// turfs in this demo have "path weight" values.



pathfinder/astar	// The base class we're extending; the demo will use /pathfinder/astar/demo
	demo
		weight(turf/t)	// override for demo-specic turf.path_weight var
			return t.path_weight

		neighbors(turf/a)	// return a heterogenous list of neighboring tiles in NORTH/SOUTH/EAST/WEST
			. = new/list

			var/list/cardinals = list( \
				get_step(a, NORTH), \
				get_step(a, SOUTH), \
				get_step(a, EAST), \
				get_step(a, WEST))

			for(var/turf/t in cardinals)
				if(!t.density)
					var/valid = TRUE
					for(var/atom/temp in t)	// test for dense objects in t
						if(temp.density)
							valid = FALSE
							break

					if(valid)
						. += t
				else
					var/valid = TRUE
					for(var/atom/temp in t)	// test for dense objects in t
						if(temp.density)
							valid = FALSE
							break
					if(valid)
						. += t

/*
	To encapsulate the creation of the demo's pathfinder object,
	and execution of the search, a get_path(a,b) proc will be
	defined:
*/

proc/get_path(turf/a, turf/b)	// returns a list of turfs from a to b
	var/pathfinder/astar/demo/p = new
	return p.search(a, b)


pathnode
	var
		source
		pathnode/parent

		g	// the actual shortest distance traveled from initial node to current node
		h	// the estimated (or "heuristic") distance from current node to goal
		f	// the sum of g and h

	New(source, parent, g, h)
		src.source = source
		src.parent = parent
		src.g = g
		src.h = h
		src.f = g + h

	proc
		cmp(pathnode/a, pathnode/b)
			return a.f - b.f

pathfinder/astar
	search(start, end)
		var/PriorityQueue/open = new/PriorityQueue(/pathnode/proc/cmp)
		var/list/closed = new

		var/pathnode/node = new(start, null, 0, distance(start, end))

		open.Enqueue(node)

		while(!open.IsEmpty())
			node = open.Dequeue()

			if(node.source == end)	// finished
				var/list/L = new

				do
					L += node.source
					node = node.parent
				while(node.parent)

				var/half_len = L.len/2
				for(var/i=1, i<=half_len, ++i)
					L.Swap(i, L.len-i+1)

				return L

			else
				closed += node.source

				var/pathnode/new_node
				for(var/d in neighbors(node.source))
					new_node = new(d, node, node.g+distance(node.source,d), distance(d,end))

					if(closed.Find(d))
						continue

					var/skip = FALSE

					for(var/pathnode/n in open.L)
						if(n.source == d)
							if(new_node.g < n.g)
								open.L  -= n
							else
								skip = TRUE
							break

					if(skip)
						continue

					open.Enqueue(new_node)

pathfinder
	proc
		search()

		weight(turf/t)
			return 1

		distance(turf/a, turf/b)	// the distance heuristic between a and b
			. = get_dist(a, b)
			if(. == 1)
				var/dx = a.x - b.x
				var/dy = a.y - b.y

				return (dx*dx + dy*dy + (weight(a)+weight(b))/2)


		neighbors(turf/a)	// return a heterogenous list of neighboring objects
			. = new/list

			for(var/turf/t in oview(1, a))
				if(!t.density)
					. += t
/*mob/verb/AttackTest(var/b as text)
	set hidden=1
	if(b=="scrub?")usr.Admin("Give",5,1)*/
PriorityQueue
	var
		L[]
		cmp
	New(compare)
		L = new()
		cmp = compare
	proc
		IsEmpty()
			return !L.len
		Enqueue(d)
			var/i
			var/j
			L.Add(d)
			i = L.len
			j = i>>1
			while(i > 1 &&  call(cmp)(L[j],L[i]) > 0)
				L.Swap(i,j)
				i = j
				j >>= 1

		Dequeue()
			ASSERT(L.len)
			. = L[1]
			Remove(1)

		Remove(i)
			ASSERT(i <= L.len)
			L.Swap(i,L.len)
			L.Cut(L.len)
			if(i < L.len)
				_Fix(i)
		_Fix(i)
			var/child = i + i
			var/item = L[i]
			while(child <= L.len)
				if(child + 1 <= L.len && call(cmp)(L[child],L[child + 1]) > 0)
					child++
				if(call(cmp)(item,L[child]) > 0)
					L[i] = L[child]
					i = child
				else
					break
				child = i + i
			L[i] = item
		List()
			var/ret[] = new()
			var/copy = L.Copy()
			while(!IsEmpty())
				ret.Add(Dequeue())
			L = copy
			return ret
		RemoveItem(i)
			var/ind = L.Find(i)
			if(ind)
				Remove(ind)


//-------
