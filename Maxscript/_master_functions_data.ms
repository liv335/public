(
	theFile = "C:\\Users\\335\Documents\\3dsMax\\_script\\VrayMtl.txt"
	theFileDeux = "C:\\Users\\335\\Documents\\3dsMax\\_script\\VrayHdri.txt"
	/*
	return an integer based on the date, use to compare to find latest modified file
	*/
	fn fileDateNumber fileCheck yearZero:2018 ignoreM:false ignoreS:false =
	(
		totalModifiedDate = false
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
	fn uniqueID =
	(
		return ((bit.intAsHex ((substring (timeGetTime() as string) 1 ((timeGetTime() as string).count - 1)) as integer)) as string)
	)
	/*
	give hex get color, give color get hexe
	*/
	-- 
	fn hexAndColor theValue addHash:false =
	(
		returnValue = "invalid input"
		if (classOf theValue) == Color then theValue = #(theValue.red,theValue.green,theValue.blue)
		if theValue[1] == "#" then (theValue = (substituteString theValue "#" ""))
		if theValue.count == 6 then (
			returnValue = color (bit.hexAsInt (substring (theValue as string) 1 2)) (bit.hexAsInt (substring (theValue as string) 3 2)) (bit.hexAsInt (substring (theValue as string) 5 2)) 
		)
		else if theValue.count == 3 then (
			theCheck = for checkValue in theValue where ((checkValue as integer) > 255) or ((checkValue as integer) < 0) collect "invalid input"
			if (findItem theCheck "invalid input") == 0 then (
				try (
					returnValue = for k = 0 to 2 collect (
						if (bit.intAsHex (theValue[k+1] as integer)).count == 1 then ("0" + (bit.intAsHex (theValue[k+1] as integer))) 
						else ((bit.intAsHex (theValue[k+1] as integer)))
					)
					returnValue = (if addHash then ("#") else ("")) + returnValue[1] + returnValue[2] + returnValue[3]
				) catch ()
			) else ()
		)
		return returnValue
	)
	/*
	convert to and from linar rgb and srgb
	*/
	fn convertTosRGB theValue tosRGB:true =
	(
		-- sRGB to liniar and liniar to sRGB
		returnValue = 0
		theValue = theValue as float
		if tosRGB then (
			if (theValue <= 0.00313066844250063) then (theReturn = returnValue*12.92)
			else (returnValue = (1.055*(pow (theValue/255) (1/2.4)) - 0.055)*255)
		)
		else (
			if (theValue <= 0.0404482362771082) then (theReturn = returnValue / 12.92)
			else (returnValue = (pow (((theValue/255)+0.055)/1.055) 2.4)*255)
		)
		return returnValue
	)
	/*
	convert writeText
	*/
	fn writeFileLog theData location: arrayTogle:false fileNameOut:"log" ext:".txt" =
	(
		if theData != undefined and theData.count != 0 and theFile != unsupplied then
		(
			print theData
			theWrite = ""
			theFile = createFile (location + "//" + fileNameOut + ext)
			if arrayTogle then (for values in theData do theWrite += values + "\n") else (theWrite = theData)
			format "%" theWrite to:theFile
			close theFile
		)
	)	
	fn readLog readLogLocation =
	(
		data = #()
		fileToSearch = (openFile readLogLocation)
		if fileToSearch != undefined then
		(
			while not eof fileToSearch do(
				lineToRead = readline fileToSearch
				append data lineToRead
			)
			close fileToSearch
		)
		return data
	)
	fn dateLog dataAdd =
	(
		uniTime = getLocalTime()
		theLogTime = (uniTime[1] as string +"/" + uniTime[2] as string + "/" +uniTime[4] as string + " " + \
			uniTime[5] as string +":" + uniTime[6] as string + ":" +uniTime[7] as string + "=")
		dataAdded = (theLogTime + dataAdd)
		return dataAdded
	)
	-- data values
	data = #()
	reData = ""
	-- read a file test
	for readValues in (readLog "C:\\Users\\335\\Documents\\3dsMax\\_script\\readTest.txt") do append data readValues
	-- add data log test
	for values in data do reData += ((values) +"\n")
	-- write log
	writeFileLog reData location:"C:\\Users\\335\\Documents\\3dsMax\\_script"
	
	--print (convertTosRGB 100)
	--print (hexAndColor "ff0210")
	--print (hexAndColor (color 10 10 50))
	--fileDateNumber fileCheck:theFile
	--print (((pathLibFile theFile).parent) + ((pathLibFile theFile).fname) + ((pathLibFile theFile).suffix) == theFile)
	--print ((pathLibFile theFile).fname)
	--print ((pathLibFile theFile).suffix)
	--print ((pathLibFile theFile).parent + (pathLibFile theFile).fullName == theFile)
	--print (fileDateNumber theFile)
	--pathLibFile fileCheck:123
)