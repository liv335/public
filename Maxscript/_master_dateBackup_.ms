(
	theFile = "C:\\Users\\335\Documents\\3dsMax\\_script\\VrayMtl.txt"
	theFileDeux = "C:\\Users\\335\\Documents\\3dsMax\\_script\\VrayHdri.txt"
	
	fn fileDateNumber fileCheck:undefined yearZero:2018 ignoreM:false ignoreS:f =
	(
		/*
		return an integer based on the date, use to compare to find latest modified file
		*/
		local totalModifiedDate = 0
		local extraValue = 0
		local howManyDays = 0
		
		if fileCheck != undefined then
		(
			local filterFile = (filterstring fileCheck "\\")
			local fileName = (filterString (filterFile[filterFile.count]) ".")
			local extension = (substring (filterFile[filterFile.count]) (fileName[1].count+1) fileCheck.count)
			if (doesFileExist fileCheck) then (
				modifiedDate = (getFileModDate fileCheck)
				
				dateFilter = (filterString modifiedDate " ")
				filterMDY = (filterstring dateFilter[1] "/")
				filterHMS = (filterstring dateFilter[2] ":")
				
				month = filterMDY[1]
				day = filterMDY[2]
				year = filterMDY[3]
				
				hours = filterHMS[1]
				minutes = filterHMS[2]
				seconds =  filterHMS[3]
				
				if dateFilter[3] == "PM" then extraValue = 43200
				totalSecondsDay = (
					((hours as integer) * 60 * 60) + \
					(if not ignoreM then ((minutes as integer) * 60) else (0)) + \
					(if not ignoreS then ((seconds as integer) + extraValue) else (0))
				)
				
				for i = 1 to (month as integer)-1 do (
					daysInMonth = 0
					if (i == 1) or (i == 3) or (i == 5) or (i == 7) or (i == 8) or (i == 10) or (i == 12) then (daysInMonth = 31)
					else if (i == 2) then (if ((mod (year as integer) 4) == 0.0) then (daysInMonth = 29) else (daysInMonth = 28))
					else if (i == 4) or (i == 6) or (i == 9) or (i == 11) then (daysInMonth = 30)
					howManyDays += daysInMonth
				)
				addSecondsYears = (((year as integer) - yearZero) * 31536000)
				totalModifiedDate =  (((howManyDays + (day as integer))*24*60*60) + totalSecondsDay + addSecondsYears)
			)
		)
		return totalModifiedDate
	)
	fn fileDateNumber fileCheck:undefined yearZero:2018 ignoreM:false ignoreS:f =
	(
		/*
		return an integer based on the date, use to compare to find latest modified file
		*/
		local totalModifiedDate = 0
		local extraValue = 0
		local howManyDays = 0
		
		if fileCheck != undefined then
		(
			local filterFile = (filterstring fileCheck "\\")
			local fileName = (filterString (filterFile[filterFile.count]) ".")
			local extension = (substring (filterFile[filterFile.count]) (fileName[1].count+1) fileCheck.count)
			if (doesFileExist fileCheck) then (
				modifiedDate = (getFileModDate fileCheck)
				
				dateFilter = (filterString modifiedDate " ")
				filterMDY = (filterstring dateFilter[1] "/")
				filterHMS = (filterstring dateFilter[2] ":")
				
				month = filterMDY[1]
				day = filterMDY[2]
				year = filterMDY[3]
				
				hours = filterHMS[1]
				minutes = filterHMS[2]
				seconds =  filterHMS[3]
				
				if dateFilter[3] == "PM" then extraValue = 43200
				totalSecondsDay = (
					((filterHMS[1] as integer) * 60 * 60) + \
					(if not ignoreM then ((filterHMS[2] as integer) * 60) else (0)) + \
					(if not ignoreS then ((filterHMS[3] as integer) + extraValue) else (0))
				)
				
				for i = 1 to (month as integer)-1 do (
					daysInMonth = 0
					if (i == 1) or (i == 3) or (i == 5) or (i == 7) or (i == 8) or (i == 10) or (i == 12) then (daysInMonth = 31)
					else if (i == 2) then (if ((mod (year as integer) 4) == 0.0) then (daysInMonth = 29) else (daysInMonth = 28))
					else if (i == 4) or (i == 6) or (i == 9) or (i == 11) then (daysInMonth = 30)
					howManyDays += daysInMonth
				)
				addSecondsYears = (((year as integer) - yearZero) * 31536000)
				totalModifiedDate =  (((howManyDays + (day as integer))*24*60*60) + totalSecondsDay + addSecondsYears)
			)
		)
		return totalModifiedDate
	)
	
	fileDateNumber fileCheck:theFile
)