------------------------------------------------------------------------------------------------------------------------------
-- files functions - 21/07/2021
-- Script by Trifan Liviu
-- Contact: https://www.linkedin.com/in/liviu-t-94975536/
-- fileDateNumber checks modified date of file, returns number of seconds since creation
-- pathLibfile works returns parts of a path, parent, suffix, exists
-- uniqueID creates a unique string based on current time
-- Cheers 
------------------------------------------------------------------------------------------------------------------------------

(
	/*
	return an integer based on the date, use to compare to find latest modified file
	*/
	fn fileDateNumber fileCheck yearZero:2018 ignoreM:false ignoreS:false =
	(
		totalModifiedDate = "Not file"
		if fileCheck != undefined and (doesFileExist fileCheck) then
		(
			totalModifiedDate = 0
			howManyDays = 0
			modifiedDate = (getFileModDate fileCheck)
			
			dateFilter = (filterString (getFileModDate fileCheck) " ")
			filterMDY = (filterstring dateFilter[1] "/") -- month, day, year
			filterHMS = (filterstring dateFilter[2] ":") -- hour, minute, second
			
			totalSecondsDay = (
				((filterHMS[1] as integer) * 60 * 60) + \
				(if not ignoreM then ((filterHMS[2] as integer) * 60) else (0)) + \
				(if not ignoreS then ((filterHMS[3] as integer) + (if dateFilter[3] == "PM" then (extraValue = 43200) else (0))) else (0))
			)
			
			for i = 1 to (filterMDY[1] as integer)-1 do (
				daysInMonth = 0
				if (i == 1) or (i == 3) or (i == 5) or (i == 7) or (i == 8) or (i == 10) or (i == 12) then (daysInMonth = 31)
				else if (i == 2) then (if ((mod (filterMDY[1] as integer) 4) == 0.0) then (daysInMonth = 29) else (daysInMonth = 28))
				else if (i == 4) or (i == 6) or (i == 9) or (i == 11) then (daysInMonth = 30)
				howManyDays += daysInMonth
			)
			secondsInYears = (((filterMDY[3] as integer) - yearZero) * 31536000)
			totalModifiedDate =  (((howManyDays + (filterMDY[2] as integer))*24*60*60) + totalSecondsDay + secondsInYears)
		)
		return totalModifiedDate
	)
	
	/*
	works like path lib from python
	*/
	fn pathLibFile fileCheck inverSep:false =
	(
		libPathFile = false
		local parentPaths = ""
		if not inverSep then theSeparator = "\\" else theSeparator = "/"
		
		struct theFileStruct
		(
			fullPath, parts, parent, parents, 
			fullName, fname, suffix,
			exists
		)
		parentPaths = ""
		libPathFile = theFileStruct()
		if classOf fileCheck == string then
		(
			libPathFile.fullPath = fileCheck
			libPathFile.parts = (filterstring fileCheck theSeparator)
			
			libPathFile.parent = (substring fileCheck 1 (fileCheck.count - (libPathFile.parts[libPathFile.parts.count]).count))
			libPathFile.parents = (for part in (filterstring libPathFile.parent theSeparator) collect (parentPaths += part + theSeparator))
				
			libPathFile.fullName = (substring (libPathFile.parts[libPathFile.parts.count]) 1 fileCheck.count)
			libPathFile.fname = (filterString (libPathFile.parts[libPathFile.parts.count]) ".")[1]
				
			libPathFile.suffix = "." + (filterString (libPathFile.parts[libPathFile.parts.count]) ".")[2]
			libPathFile.exists = (doesFileExist fileCheck)
		)
		return libPathFile
	)
	/*
	generate unique name
	*/
	fn uniqueID  =
	(
		return ((bit.intAsHex ((substring (timeGetTime() as string) 1 ((timeGetTime() as string).count - 1)) as integer)) as string)
	)

	--fileDateNumber fileCheck:theFile
	--print (((pathLibFile theFile).parent) + ((pathLibFile theFile).fname) + ((pathLibFile theFile).suffix) == theFile)
	--print ((pathLibFile theFile).fname)
	--print ((pathLibFile theFile).suffix)
	print ((pathLibFile theFile).parent + (pathLibFile theFile).fullName == theFile)
	print (fileDateNumber theFile)
	--pathLibFile fileCheck:123
)