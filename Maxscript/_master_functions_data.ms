------------------------------------------------------------------------------------------------------------------------------
-- Data functions - 21/07/2021
-- Script by Trifan Liviu
-- Contact: https://www.linkedin.com/in/liviu-t-94975536/
-- hexAndColor give color value get hex
-- convertTosRGB give value get srgb value
-- writeFileLog writes log text txt filein
-- readLog reads log
-- dateLog adds date to string
-- Cheers 
------------------------------------------------------------------------------------------------------------------------------
(
	/*
	give hex get color, give color get hexe
	*/
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
	/*
	read text file
	*/
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
	/*
	write add date to string
	*/
	fn dateLog dataAdd =
	(
		uniTime = getLocalTime()
		theLogTime = (uniTime[1] as string +"/" + uniTime[2] as string + "/" +uniTime[4] as string + " " + \
			uniTime[5] as string +":" + uniTime[6] as string + ":" +uniTime[7] as string + "=")
		dataAdded = (theLogTime + dataAdd)
		return dataAdded
	)
	
	theFile = @"C:\Users\335\Documents\3dsMax\_script\VrayMtl.txt"
	theFileDeux = @"C:\Users\335\Documents\3dsMax\_script\VrayHdri.txt"
	textReadTest = @"C:\Users\335\Documents\3dsMax\_script\readTest.txt"
	writeLocation = @"C:\Users\335\Documents\3dsMax\_script"
	
	-- read a file test
	data = for readValues in (readLog textReadTest) collect readValues
	-- add data log test
	reData = "" -- empty
	for values in data do reData += ((values) +"\n")
	-- write log
	writeFileLog reData location:writeLocation
	
	--print (convertTosRGB 100)
	--print (hexAndColor "ff0210")
	--print (hexAndColor (color 10 10 50))
)