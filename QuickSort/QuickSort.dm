/*

Updates:
Version 3 - 1/14/2009
Fixed a bug in InsertSort should improve speed slightly as well as
handle sorting subsets properly.

Version 2
Tweaked the logic for the cutoff point to check before partitioning
rather than after.  Might have been the source of bugs with lists
smaller than 2.  Plus it looks cleaner.

Usage

QuickSort(L[], cmp, start = 1, end = L.len)

L - The list to be sorted
cmp - The comparision function to be used to compare elements in the list
start - The start of the region in the list to be sorted
end - The end of the region in the list to be sorted

The comparision function should take two parameters.  The parameters
are the two items being compared.  This function should return a negative
number if the first item is less than the second, 0 if the items have
an equal weight for the sorting, and positive if the first item is
larger than the second.


*/

var/const/QS_CUTOFF = 10

proc
	_QSPartition(L[], l, r, cmp)
		var/s
		var/m
		var/pivot
		ASSERT(l != r)
		s = l
		m = (l+r)>>1

		if(call(cmp)(L[l],L[m]) > 0)
			L.Swap(l,m)
		if(call(cmp)(L[l],L[r]) > 0)
			L.Swap(l,r)
		if(call(cmp)(L[m],L[r]) > 0)
			L.Swap(m,r)

		L.Swap(m,r-1)
		pivot = r-1
		r--;
		while(1)
			do
				l++
			while(call(cmp)(L[l],L[pivot]) < 0)
			do
				r--
			while(call(cmp)(L[r],L[pivot]) > 0)
			if(l < r)
				L.Swap(l,r)
			else
				break;
		L.Swap(l,pivot)
		return l - s

	QuickSort(L[], cmp, start = 1, end = L.len)
		if(start < end)
			if(end - start + 1 < QS_CUTOFF)
				InsertSort(L,cmp,start,end)
			else
				var/i = _QSPartition(L, start, end, cmp);
				QuickSort(L, cmp, start, start + i);
				QuickSort(L, cmp, start + i + 1, end);

	InsertSort(L[], cmp, start = 1, end = L.len)
		for(var/i = start; i <= end; i++)
			var/val = L[i]
			var/j = i - 1
			while(j >= start && call(cmp)(L[j],val) > 0)
				L[j+1] = L[j]
				j--
			L[j+1] = val
