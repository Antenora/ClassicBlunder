//Credits - Myself
proc/ConvertLists(var/list/z)
	var/list/Blah=new
	for(var/x in z)
		Blah.Add(params2list(x))
	return Blah
proc/ConvertLists2(var/list/z)
	return params2list(dd_file2params(z))



//Credits - Deadron
proc/dd_sortedtextlist(list/incoming, case_sensitive = 0)
	var/list/sorted_text = new()
	var/low_index
	var/high_index
	var/insert_index
	var/midway_calc
	var/current_index
	var/current_item
	var/list/list_bottom
	var/sort_result

	var/current_sort_text
	for (current_sort_text in incoming)
		low_index = 1
		high_index = sorted_text.len
		while (low_index <= high_index)
			midway_calc = (low_index + high_index) / 2
			current_index = round(midway_calc)
			if (midway_calc > current_index)
				current_index++
			current_item = sorted_text[current_index]

			if(case_sensitive)
				sort_result = sorttextEx(current_sort_text, current_item)
			else
				sort_result = sorttext(current_sort_text, current_item)

			switch(sort_result)
				if (1)
					high_index = current_index - 1	// current_sort_text < current_item
				if (-1)
					low_index = current_index + 1	// current_sort_text > current_item
				if (0)
					low_index = current_index		// current_sort_text == current_item
					break

		insert_index = low_index

		if (insert_index > sorted_text.len)
			sorted_text += current_sort_text
			continue

		list_bottom = sorted_text.Copy(insert_index)
		sorted_text.Cut(insert_index)
		sorted_text += current_sort_text
		sorted_text += list_bottom
	return sorted_text


proc/dd_sortedTextList(list/incoming,var/case_sensitive = 0)
	return dd_sortedtextlist(incoming, case_sensitive)




proc
	dd_file2list(file_path, separator = "\n")
		var/file
		if (isfile(file_path))
			file = file_path
		else
			file = file(file_path)
		return dd_text2list(file2text(file), separator)

	dd_text2list(text, separator)
		var/textlength      = length(text)
		var/separatorlength = length(separator)
		var/list/textList   = new /list()
		var/searchPosition  = 1
		var/findPosition    = 1
		var/buggyText
		while (1)
			findPosition = findtext(text, separator, searchPosition, 0)
			buggyText = copytext(text, searchPosition, findPosition)
			textList += "[buggyText]"

			searchPosition = findPosition + separatorlength
			if (findPosition == 0)
				return textList
			else
				if (searchPosition > textlength)
					textList += ""
					return textList
	dd_file2params(file_path, separator = "\n")
		var/file
		if (isfile(file_path))
			file = file_path
		else
			file = file(file_path)
		return dd_text2params(file2text(file), separator)
	dd_text2params(text, separator)
		var/textlength      = length(text)
		var/separatorlength = length(separator)
		var/textList
		var/searchPosition  = 1
		var/findPosition    = 1
		var/buggyText
		while (1)
			findPosition = findtext(text, separator, searchPosition, 0)
			buggyText = copytext(text, searchPosition, findPosition)
			textList += "[buggyText]&"
			searchPosition = findPosition + separatorlength
			if (findPosition == 0)
				return textList
			else
				if (searchPosition > textlength)
					textList += ""
					return textList
	dd_replacetext(text, search_string, replacement_string)
		// A nice way to do this is to split the text into an array based on the search_string,
		// then put it back together into text using replacement_string as the new separator.
		var/list/textList = dd_text2list(text, search_string)
		return dd_list2text(textList, replacement_string)

	dd_replaceText(text, search_string, replacement_string)
		var/list/textList = dd_text2List(text, search_string)
		return dd_list2text(textList, replacement_string)


	dd_list2text(list/the_list, separator)
		var/total = the_list.len
		if (total == 0)														// Nothing to work with.
			return

		var/newText = "[the_list[1]]"										// Treats any object/number as text also.
		var/count
		for (count = 2, count <= total, count++)
			if (separator) newText += separator
			newText += "[the_list[count]]"
		return newText

	dd_text2List(text, separator)
		var/textlength      = length(text)
		var/separatorlength = length(separator)
		var/list/textList   = new /list()
		var/searchPosition  = 1
		var/findPosition    = 1
		var/buggyText
		while (1)															// Loop forever.
			findPosition = findtextEx(text, separator, searchPosition, 0)
			buggyText = copytext(text, searchPosition, findPosition)		// Everything from searchPosition to findPosition goes into a list element.
			textList += "[buggyText]"										// Working around weird problem where "text" != "text" after this copytext().

			searchPosition = findPosition + separatorlength					// Skip over separator.
			if (findPosition == 0)											// Didn't find anything at end of string so stop here.
				return textList
			else
				if (searchPosition > textlength)							// Found separator at very end of string.
					textList += ""											// So add empty element.
					return textList