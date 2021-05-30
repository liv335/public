(
	fn pathFile fileCheck: =
	(
		local filterFile = (filterstring fileCheck "\\")
		local fileName = (filterString (filterFile[filterFile.count]) ".")
		--local extension = (substring (filterFile[filterFile.count]) (fileName[1].count+1) fileCheck.count)
		struct theFileStruct
		(
			fullPath,
			parts,
			parent,
			fullName,
			fileName,
			suffix
		)
		theFile = theFileStruct()
		theFile.fullPath = fileCheck
		theFile.parts = filterFile
		theFile.parent = (substring fileCheck 1 (fileCheck.count - (filterFile[filterFile.count]).count - 1))
		theFile.fullName = (substring (filterFile[filterFile.count]) 1 fileCheck.count)
		theFile.fileName = (filterString (filterFile[filterFile.count]) ".")[1]
		theFile.suffix = (substring (filterFile[filterFile.count]) (fileName[1].count+1) fileCheck.count)
		return theFile
	)
	
	pathFile fileCheck:theFile
)