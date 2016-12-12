'Option Explicit
'*************************** MAINTAIN THIS HEADER! *********************************
'     Library Name:     ut_lib.vbs
'     Purpose:          Contains utility functions - e.g., string manipulation, etc.
'
'---------------------------------------------------------------------------------

'
'********************************************************************************** 
 

'**********************************************************************************
'                           PRIVATE CONSTANTS and VARIABLES
'**********************************************************************************
Private  m_asTransactions,m_bEnableTrans,m_dtScriptTime

ReDim m_asTransactions(0)


'**********************************************************************************
'                           PUBLIC CONSTANTS and VARIABLES
'**********************************************************************************

Public g_iTransWaitTime,g_sExecutePath
g_iTransWaitTime = 0
g_bFlag=True

Public g_sEnvironmentName
g_sEnvironmentName = ""


'Whether or not to log the connections to the database
Public g_bDBConnections
g_bDBConnections = False

Public g_bDebugMode
Public g_sAppName
Public g_sRunType 
Public g_sTempResultPath
Public g_sDestinationPath
Public g_oRecordset
Public g_sRootPath : g_sRootPath = "C:\QTP_DevOps_Demo\Logs"



Public g_sDBServer, g_sAppDB, g_sAppDBUser, g_sAppDBPwd

'**********************************************************************************
'                             PRIVATE FUNCTIONS
'**********************************************************************************


'**********************************************************************************
'                                PUBLIC FUNCTIONS
'**********************************************************************************

'**********************************************************************
'	Name: utDateFormat
'	Purpose:	This function takes a date and puts it into the requested format.
'	Creator:Mark Clemens
'.
'		Param: sDate| required 
'		AllowedRange: 
'		Description: The date to format.  It can use either the "/" separator or the
'								"-" separator.
'.
'		Param: sFormat| required 
'		AllowedRange: 
'		Description: The format to use.  Example syntax:
'					mm/dd/yyyy or m-d-yyyy
'
'      Returns:  The reformatted date.
'
'**********************************************************************
Public function utDateFormat(sDate, sFormat)
	
	Dim asDate, asFormat, sOrigSeparator, sNewSeparator, iLength, sOrigMonth, sOrigDay, sOrigYear
	Dim sFormatMonth, sFormatDay, sFormatYear, iCounter, iNumZeros, iZeroCounter

	sDate = cStr(sDate)
	If sDate = "" Then
		Exit Function
	End If

	
	' Get the original date separator and split the date into an array
	If InStr(1,sDate,"/") > 0  Then
		sOrigSeparator = "/"
		asDate = Split(sDate,"/")
	ElseIf InStr(1,sDate,"-") > 0 then
		sOrigSeparator = "-"
		asDate = Split(sDate,"-")
	ElseIF Instr(1,sDate," ")> 0 Then		
		sOrigSeparator = " "
		asDate = Split(sDate," ")
	Else
		Err.number = g_iINVALID_INPUT
		Err.Description = "Invalid date passed to utDateFormat function.  Must use either '/' or '-' as separators."
		errHandler Err, "utDateFormat", micWarning
	End if	
	
	sOrigMonth = asDate(0)
	sOrigDay = asDate(1)
	sOrigYear = asDate(2)

	
	For iCounter = LBound(asDate) to UBound(asDate)

		If Len(asDate(iCounter)) < Len(asFormat(iCounter)) Then
			' If this is the year counter, and we were passed a two digit year, then
			' do some calculating to see if we want to put 19 or 20 in front of the year.
			If iCounter = UBound(asDate)  Then
				If asDate(iCounter) > 25  Then
						asDate(iCounter) = "19" & asDate(iCounter)
						
				Else
						asDate(iCounter) = "20" & asDate(iCounter)
											
				End If
			
				utDateFormat = utDateFormat & sNewSeparator & asDate(iCounter)
			

				ElseIf iCounter <> UBound(asDate) Then
					iNumZeros = Len(asFormat(iCounter)) - Len(asDate(iCounter))
					For iZeroCounter = 1 to iNumZeros
						asDate(iCounter) = "0" & asDate(iCounter)
	
					Next
					If iCounter <> 0  Then
						utDateFormat = utDateFormat & sNewSeparator & asDate(iCounter)
					Else
						utDateFormat = asDate(iCounter)
					End If
'			Else
'				If Len(asDate(iCounter)) = 2 And asDate(iCounter) < 10   And Len(asFormat(iCounter)) = 1 Then
'					asDate(iCounter) = Right(asDate(iCounter),1)
'				End If
'				If iCounter <> 0  Then
'					utDateFormat = utDateFormat & sNewSeparator & asDate(iCounter)
'				Else
'					utDateFormat = asDate(iCounter)
'				End If
'			
			
			End If
		Else
			If iCounter <> 0  Then
				utDateFormat = utDateFormat & sNewSeparator & asDate(iCounter)
			Else
				utDateFormat = asDate(iCounter)
			End If
		
		ENd If
	Next


End Function


'**********************************************************************
'	Name: utGetStateOrProv
'	Purpose:	This function takes either a full name for a state or province, or
'		an abbreviation for a state or province, and returns the corresponding 
'		abbreviation of full name.
'	Creator:Mark Clemens
'.
'		Param: sStateOrProv| required 
'		AllowedRange: Either the abbreviation for a state or province, or its full name, in upper, lower or mixed case.
'		Description: The abbreviation or full name for a state or province of the US or Candada.  Also 
'			includes possessions such as the Marshal Islands, Guam, etc..  Can be entered in upper
'			or lower case.
'.
'      Returns:  The correseponding abbeviation or full name. If the state or province is not
'		found, the function will return "NOT FOUND".
'
'**********************************************************************
Public Function utGetStateOrProv(sStateOrProv)

	
	Dim asProvinces(76)
	Dim bFound
	Dim iCounter
	Dim asProvince

	' Build the array for the states and provinces of the US or Canada
	asProvinces(0)="AA=Armed Forces - Americas"
	asProvinces(1)="AE=Armed Forces - Europe"
	asProvinces(2)="AL=Alabama"
	asProvinces(3)="AK=Alaska"
	asProvinces(4)="AP=Armed Forces - Pacific"
	asProvinces(5)="AR=Arkansas"
	asProvinces(6)="AS=American Samoa"
	asProvinces(7)="AZ=Arizona"
	asProvinces(8)="CA=California"
	asProvinces(9)="CI=Caroline Islands "
	asProvinces(10)="CO=Colorado"
	asProvinces(11)="CT=Connecticut"
	asProvinces(12)="CZ=Canal Zone"
	asProvinces(13)="DE=Delaware"
	asProvinces(14)="DC=District Of Columbia"
	asProvinces(15)="FL=Florida"
	asProvinces(16)="FM=Federated States of Micronesia"
	asProvinces(17)="GA=Georgia"
	asProvinces(18)="GU=Guam"
	asProvinces(19)="HI=Hawaii"
	asProvinces(20)="IA=Iowa"
	asProvinces(21)="ID=Idaho"
	asProvinces(22)="IL=Illinois"
	asProvinces(23)="IN=Indiana"
	asProvinces(24)="KS=Kansas"
	asProvinces(25)="KY=Kentucky"
	asProvinces(26)="LA=Louisiana"
	asProvinces(27)="MA=Massachusetts"
	asProvinces(28)="MD=Maryland"
	asProvinces(29)="ME=Maine"
	asProvinces(30)="MH=Marshall Islands"
	asProvinces(31)="MI=Michigan"
	asProvinces(32)="MN=Minnesota"
	asProvinces(33)="MO=Missouri"
	asProvinces(34)="MP=Northern Mariana Islands"
	asProvinces(35)="MS=Mississippi"
	asProvinces(36)="MT=Montana"
	asProvinces(37)="NC=North Carolina"
	asProvinces(38)="ND=North Dakota"
	asProvinces(39)="NE=Nebraska"
	asProvinces(40)="NH=New Hampshire"
	asProvinces(41)="NJ=New Jersey"
	asProvinces(42)="NM=New Mexico"
	asProvinces(43)="NV=Nevada"
	asProvinces(44)="NY=New York"
	asProvinces(45)="OH=Ohio"
	asProvinces(46)="OK=Oklahoma"
	asProvinces(47)="OR=Oregon"
	asProvinces(48)="PA=Pennsylvania"
	asProvinces(49)="PR=Puerto Rico"
	asProvinces(50)="PW=Palau"
	asProvinces(51)="RI=Rhode Island"
	asProvinces(52)="SC=South Carolina"
	asProvinces(53)="SD=South Dakota"
	asProvinces(54)="TN=Tennessee"
	asProvinces(55)="TX=Texas"
	asProvinces(56)="UT=Utah"
	asProvinces(57)="VA=Virginia"
	asProvinces(58)="VI=Virgin Islands"
	asProvinces(59)="VT=Vermont"
	asProvinces(60)="WA=Washington"
	asProvinces(61)="WI=Wisconsin"
	asProvinces(62)="WV=West Virginia"
	asProvinces(63)="WY=Wyoming"
	asProvinces(64)="AB=Alberta"
	asProvinces(65)="BC=British Columbia"
	asProvinces(66)="MB=Manitoba"
	asProvinces(67)="NB=New Brunswick"
	asProvinces(68)="NF=Newfoundland"
	asProvinces(69)="NS=Nova Scotia"
	asProvinces(70)="NT=Northwest Territories"
	asProvinces(71)="NU=Nunavut"
	asProvinces(72)="ON=Ontario"
	asProvinces(73)="PE=Prince Edward Island"
	asProvinces(74)="QC=Quebec"
	asProvinces(75)="SK=Saskatchewan"
	asProvinces(76)="YT=Yukon Territory"

	' Initialize flag to False.  If the state or province is found, this will
	' be set to True.
	bFound = False

	' Iterate through teh array and search for either the abbreviation or full
	' name of the state or province.
	For iCounter = LBound(asProvinces) To UBound(asProvinces)
		' Split the array element on the equal sign
		asProvince = Split(asProvinces(iCounter),"=")

		If Trim(LCase(sStateOrProv)) = LCase(asProvince(0)) Then
			utGetStateOrProv = asProvince(1)
			bFound = True
			Exit For
		ElseIF 	Trim(LCase(sStateOrProv)) = LCase(asProvince(1)) Then
			utGetStateOrProv = asProvince(0)
			bFound = True
			Exit For
		End If

	Next
	' If the state or province wasn't found as either an abbreviation or full name,
	' log an error as an warning.
	If bFound = False Then
		Err.Number =  g_iITEM_NOT_FOUND
		Err.Description = "Unable to find corresponding full name or abbreviation for state - " & sStateOrProv & "."
		errHandler Err, "",micWarning
		utGetStateOrProv = "NOT FOUND"
	End If

   
End Function

'**********************************************************************
'	Name: utExtractHtmlTagValues
'	Purpose:	This function extracts the tag values from a string
'		of html by stripping out all of the html code.  The remaining tag
'		values are returned in an array.
'	Creator: Mark Clemens & Michael J. Nohai
'
'		Param: sHtml| required 
'		AllowedRange: 
'		Description: The Html to use when extracting the tag values.
'
'	Returns: A stripped array of values within the HTML tags.
'
'**********************************************************************
Public Function utExtractHtmlTagValues(sHtml)

	Dim asText, iCounter,  iArrayCounter, sPattern, asTagValues
	Dim regEx, oMatch' Create variable.
	sPattern = "<(.|\n)+?>"
	Set regEx = New RegExp   ' Create regular expression.
	regEx.Pattern = sPattern   ' Set pattern.
	regEx.IgnoreCase = True   ' Set case insensitivity.
	regEx.Global = True   ' Set global applicability.
	' Replace everything between the html tag values with a pipe symbol
	sHtml = regEx.Replace(sHtml,"|")
	' Split the text string on the pipe symbol	
	asText = Split(sHtml, "|")
	' Iterate through the asText array.  If the values of the elements are not
	' empty strings, pass them to the asTags array
	iArrayCounter = 0
	ReDim asTagValues(iArrayCounter)
	For iCounter = 0 To Ubound(asText)
		If asText(iCounter) <> "" Then
			asText(iCounter) = Replace (asText(iCounter), "&nbsp;","")
			ReDim Preserve asTagValues(iArrayCounter)
			asTagValues(iArrayCounter) = asText(iCounter)
			iArrayCounter = iArrayCounter + 1

		End If

	Next

	utExtractHtmlTagValues = asTagValues
   
End Function

''**********************************************************************
'	Name: utCompareStrings 
'	Purpose:This sub compares two strings and writes a warning to
'		the log if the strings don't match.
'	Creator:Mark Clemens
'
'		Param: sString1|required
'		AllowedRange: 
'		Description:   The first string to compare.
'
'		Param: sString2|required
'		AllowedRange: 
'		Description:   The first string to compare.
'
'		Param: sStringInfo|optional|AssumedValue=""
'		AllowedRange: 
'		Description:   Optional description of the strings.  The description
'			of each of the compared strings is delimited by a colon. 
'
'	Returns: True if the two strings match, False if they don't.
''**********************************************************************
Public Function utCompareStrings(sString1, sString2, sStringInfo)
	
	Dim asInfoStrings, sErrMsg

	If sString1 <> sString2  Then
		If sStringInfo <> "" Then
			asInfoStrings = Split(sStringInfo,":")
			sErrMsg = "Verification failure.  " & asInfoString(0) & "  - " & sString1 & " - does not match " & _
				asInfoString(1) & " - " & sString2 & "."
		Else
			sErrMsg = "Verification failure.  The first string:" & vbcrlf & sString1 & vbcrlf & " - does not match " & _
				"the second string: " & vbcrlf & sString2 & "."
		End if
		Err.Number = g_iVERIFICATION_FAILED
		Err.Description = sErrMsg
		utCompareStrings = False
		errHandler Err, "utCompareStrings", micWarning
	Else	
		utCompareStrings = True
	End If
   
End Function


''**********************************************************************
'	Name: utGetRandomNumber
'	Purpose:This function returns a random number based on the range that 
'		is passed in for the lower and upper range, inclusive of the lower and upper..
'	Creator:Mark Clemens
'
'		Param: iLower|required
'		AllowedRange: 
'		Description:   The lower end of the number range..
'
'		Param: iUpper|required
'		AllowedRange: 
'		Description:   The upper end of the number range..
'
'	Returns: A random number.
''**********************************************************************
Public Function utGetRandomNumber(iLower, iUpper)
	

	Randomize
   utGetRandomNumber  = Int((iUpper - iLower + 1) * Rnd + iLower)

End Function

''**********************************************************************
'	Name: utGetRandomListItem
'	Purpose:This function returns a random item from a list (drop-down, web list).
'	Creator:Mark Clemens
'
'		Param: oList|required
'		AllowedRange: 
'		Description:   The list object to get the random item from.
'
'	Returns: A random item from the list.
''**********************************************************************
Public Function utGetRandomListItem(oList)
	

	Dim sItems, asItems, iRandom,bNoneSelected

	sItems = oList.GetROProperty("all items")
	asItems = Split(sItems, ";")
	bNoneSelected = True

	If UBound(asItems) = 0 And (Instr(1, asItems(0), "- None -") > 0  Or asItems(0) = "") Then

		Err.Number = g_iITEM_NOT_FOUND
		Err.Description = "Attempt to select a random list item from list  when there are no items in the list."
		errHandler Err, "utGetRandomListItem", micWarning
		utGetRandomListItem = ""
		Exit Function
	End If

	Do 
		iRandom = utGetRandomNumber(0, UBound(asItems))
		If  InStr(1,asItems(iRandom),"- None -") = 0 And asItems(iRandom) <> "" Then
			bNoneSelected = False
		End If
	Loop While bNoneSelected = True 

	utGetRandomListItem = asItems(iRandom)
   
End Function

''**********************************************************************
'	Name: utParseLRFile
'	Purpose:This Sub parses a loadrunner datafile and retuns an array .
'	Creator:Mark Clemens
'
'		Param: sFile|required
'		AllowedRange: 
'		Description:  The file to parse
'
'		Param: asLines|required
'		AllowedRange: 
'		Description:  An array of data in loadrunner datafile
'
'	Returns: NA
''**********************************************************************

Public sub utParseLRFile( sFile, ByRef asLines )

	
	Dim sFileText,fso,ts
	Set fso = CreateObject("Scripting.FileSystemObject")
	
	If fso.FileExists(sFile) Then
		 
		Set ts = fso.OpenTextFile(sFile, 1, True)
		sFileText = ts.readall()
		 asLines = split(sFileText,vbcrlf)
	   	
	 End If

 
End Sub

''**********************************************************************
'	Name: utGetLRData
'	Purpose:This Sub parses a rloadrunner datafile and retuns an array .
'	Creator:Mark Clemens
'
'		Param: sFile|required
'		AllowedRange: 
'		Description:  The file to parse
'
'		Param: iRow|required
'		AllowedRange: 
'		Description:  Row in datafile. Pass in 0 to get column headers
'
'		Param: iCol|required
'		AllowedRange: 
'		Description:  Index of column to retreive.
'
'	Returns: NA
''**********************************************************************
Public Function utGetLRData(sFile, iRow, iCol)
	Dim asLines, iLineCounter, asLine
	utParseLRFile sFile, asLines 

	asLine = Split(asLines(iRow), ",")

	utGetLRData = Trim(asLine(iCol - 1))
	
End Function


''**********************************************************************
'	Name: utDelimFileGetValue 
'	Purpose:This function returns a value from a delimited text file based on the column 
'		and row that are passed in..
'	Creator:Mark Clemens
'
'		Param: sFile|required
'		AllowedRange: 
'		Description:   The delimited text file.
'
'		Param: iRow|required
'		AllowedRange: 
'		Description:   The row in the file with the desired value.  The row with the columns is row zero.
'
'		Param: vColumn|required
'		AllowedRange: 
'		Description:   The column in the file with the desired value. This can be either the column index (zero based)
'			or the column name.
'
'		Param: sDelimiter|optional|AssumedValue=","
'		AllowedRange: 
'		Description:   The delimter to use for the file.  The default is a comma delimiter.
'
'	Returns: The value at the indicated row and column.
''**********************************************************************
Public Function utDelimFileGetValue(sFile, iRow, vColumn, sDelimiter)
	

	Dim oFS, sFileText, oTS, asLines, asCols, bColFound, iColIndex, asVals

	If sDelimiter = "" Then
		sDelimiter = ","
	End If
	
	Set oFS = CreateObject("Scripting.FileSystemObject")

	Set oTS = oFS.OpenTextFile(sFile)

	sFileText = oTS.ReadAll

	asLines = Split(sFileText, vbcrlf)

	If UBound(asLines) = 0 And asLines(0) = "" Then
		Exit Function
	End If

	asCols = Split(asLines(0), sDelimiter)
	bColFound = False
	If IsNumeric(vColumn) = False Then
		For iCounter = 0 to UBound(asCols)
			If Trim(asCols(iCounter) = Trim(vColumn) )Then
				iColIndex = iCounter
				bColFound = True
				Exit For
			End If
		Next
		If bColFound = False Then
			Err.Number = g_lCOL_NOT_FOUND_ERR
			Err.Description = "Unable to find desired column - " & vColumn & " in file:" & vbcrlf & sFile
			Err.Raise
			Exit Function
		End If
	Else
		iColIndex = vColumn
		If UBound(asCols) < iColIndex Then
			Err.Number = g_lROW_COL_OUT_OF_RANGE
			Err.Description = "Request for column # - " & iColIndex & " - is out of range for file - " & sFile & ". The maximum number of columns is " & UBound(asCols) + 1 & "."
			Err.Raise
			Exit Function
		End If
	End If

	If UBound(asLines)  < iRow Then
		Err.Number = g_lROW_COL_OUT_OF_RANGE
		Err.Description = "Request for row # - " & iRow & " - is out of range for file - " & sFile & ". The maximum number of rows is " & UBound(asLines) & "."
		Err.Raise
		Exit Function
	End If

	asVals = Split(asLines(iRow), sDelimiter)

	utDelimFileGetValue = asVals(iColndex)

End Function


''**********************************************************************
'	Name: utDelimFileGetRowCount 
'	Purpose:This function returns the row count for a delimited text file..
'	Creator:Mark Clemens
'
'		Param: sFile|required
'		AllowedRange: 
'		Description:   The delimited text file.
'
'	Returns: The row count of the delimited text file.
''**********************************************************************
Public Function utDelimFileGetRowCount(sFile)
	

	Dim oFS, sFileText, oTS, asLines

	Set oFS = CreateObject("Scripting.FileSystemObject")

	Set oTS = oFS.OpenTextFile(sFile)

	sFileText = oTS.ReadAll

	asLines = Split(sFileText, vbcrlf)

	utDelimFileGetRowCount = UBound(asLines) + 1

End Function

''**********************************************************************
'	Name: utNumPadZeroes
'	Purpose:This function pads zeroes onto the beginning of a number
'		based on the length..
'	Creator:Mark Clemens
'
'		Param: sNum|required
'		AllowedRange: 
'		Description:   The number to pad.
'
'		Param: iLength|required
'		AllowedRange: 
'		Description:   The desired length.
'
'	Returns: The row count of the delimited text file.
''**********************************************************************
Public Function utNumPadZeroes(sNum, iLength)
	Dim iCounter
	
	For iCounter = iLength To 0 Step -1
		If iLength = Len(sNum)  Then
			Exit for
		Else
			sNum = "0" & sNum
        End If

	Next

   utNumPadZeroes = sNum
   
End Function

'**********************************************************************
'	Name: utEncryptString
'	Purpose: This function returns an encrypted string using the 
'		encryption key that is passed in (this same encryption key must
'		be used to decrypt the encrypted string.
'	Creator: Mark Clemens
'
'		Param: sString|required
'		AllowedRange: 
'		Description:   The string to encrypt.
'
'		Param: sEncryptionKey|required
'		AllowedRange: 
'		Description:   The encryption key to use.  This same key is used to decrypt the string.
'
'	Returns: The encrypted string.
''**********************************************************************
Public Function utEncryptString(ByVal sString, sEncryptionKey)
	
	Dim oEncryptedData, sVal

	If sEncryptionKey <> "" Then
		Set oEncryptedData = CreateObject("CAPICOM.EncryptedData")

		oEncryptedData.Content = sString
		oEncryptedData.SetSecret sEncryptionKey
		oEncryptedData.Algorithm.Name = 1
	        
	    sVal = oEncryptedData.Encrypt
	    sVal = Replace(sVal, vbcrlf, "")

	    Set oEncryptedData = Nothing

	End If

	utEncryptString = sVal
   
End Function

''**********************************************************************
'	Name: utDecryptString
'	Purpose: This function returns a decrypted string using the 
'		encryption key that is passed in.
'	Creator: Mark Clemens
'
'		Param: sString|required
'		AllowedRange: 
'		Description:   The encrypted string to decrypt.
'
'		Param: sEncryptionKey|required
'		AllowedRange: 
'		Description:   The encryption key to use.  This same key must have been used to encrypt the string.
'
'	Returns: The decrypted string.
''**********************************************************************
Public Function utDecryptString(ByVal sString, sEncryptionKey)
	

	Dim oEncryptedData, sVal

	If sEncryptionKey <> "" Then
		Set oEncryptedData = CreateObject("CAPICOM.EncryptedData")
		oEncryptedData.Algorithm.Name = 1
		oEncryptedData.SetSecret sEncryptionKey
		oEncryptedData.Decrypt sString
		
		sVal = oEncryptedData.Content

		Set oEncryptedData = Nothing
	End If

	utDecryptString = sVal

End Function

'**********************************************************************
'	Name: utListGetROProperty
'	Purpose:This function returns value of any property of listbox
'   	Creator: Priya
'
'		Param: sListName | required 
'		AllowedRange: 
'		Description: The name of the listbox
'
'		Param: sTitle |  required 
'		AllowedRange: 
'		Description: The title of the page
'
'		Param: sProperty |  required 
'		AllowedRange: 
'		Description: The property to be retrieved
'
'	Returns: N/A 
'**********************************************************************'
Public Function utListGetROProperty(sListName,sTitle,sProperty)

	utListGetROProperty=Browser("name:=" & sTitle).Page("title:=" & sTitle).WebList("name:=" & sListName).GetROProperty(sProperty)
	errHandler Err, "winListGetROProperty", g_iSeverity
	
End Function

''**********************************************************************
'	Name: utLogAUTName
'	Purpose:This function specifies AUT name (to be printed in Log FIle
'	Creator:unknown
'
'		Param: sAppName|required
'		AllowedRange: 
'		Description:   Application Under Test abbreviated name.
'
'	Returns:  Returns Application Under Test abbreviated name.
''**********************************************************************

Public Sub utLogAUTName(sAppName)

      sAppName = "Application under test: " & sAppName
	  PrintToLog ( sAppName)

End Sub

'**********************************************************************
'	Name: utLogEnvironment
'	Purpose:This function specifies testing environment (to be printed in Log FIle)
'	Creator:unknown
'
'		Param: sAppEnvironment|required
'		AllowedRange: 
'		Description:   Application Environment Under test.
'
'	Returns:  Application Under Test environment name.
''**********************************************************************

Public Sub utLogEnvironment(  sAppEnvironment )
      
	  PrintToLog (  "Testing Environment: " & sAppEnvironment )

End Sub

'**********************************************************************
'	Name: utWebTableGetRandomRow
'	Purpose:	This function returns a random row number for a web table.
'	Creator:Mark Clemens
'.
'		Param: oTable| required 
'		AllowedRange: 
'		Description: The description of the web table. E.g.:
'			Browser("brPCS").Page("pgPCS").WebTable("innertext:=.*Last Name.*", "name:=WebTable")
'.
'		Param: iStartRow|optional|AssumedValue=1
'		AllowedRange: 
'		Description: The row to start at for retrieving the random row number.
'			Browser("brPCS").Page("pgPCS").WebTable("innertext:=.*Last Name.*", "name:=WebTable")
'
'      Returns:  The random row number.
'
'**********************************************************************
Public Function utWebTableGetRandomRow(oTable, iStartRow)
	

	Dim iRowCount

	iRowCount = oTable.RowCount

	utWebTableGetRandomRow = utGetRandomNumber(iStartRow, iRowCount)
   
End Function

'*******************************************************************************************************
'   Name:    utImageClick
'   Purpose:This procedure clicks on the specified tab
'
'   Creator: Lavanya Bathina
'
'		Param: sPageTitle | Required	   
'		 AllowedRange: 
'		Description: Name/Title of the Browser/page
'
'		Param: sAlternateText|Required
'		 AllowedRange: 
'		Description: alt property (tool tip) of the image
'
'		Param: iIndex|Optional
'		 AllowedRange: 
'		Description: Index of the image
'
'		Param: sSyncPageTitle | Required	   
'		 AllowedRange: 
'		Description: Name of the browser, when the image click opens a new browser. 
'
'   Returns:N/A
'**********************************************************************'**********************************
Public sub utImageClick(sPageTitle,sAlternateText,iIndex,sSyncPageTitle)

	

	If iIndex="" Then
		iIndex=0
	End If
	
    Browser("name:="&sPageTitle & ".*").Page("title:="&sPageTitle & ".*").Image("alt:="& sAlternateText,"index:="&iIndex).Click
    errHandler Err,"utImageClick",g_iSeverity
		
   If sSyncPageTitle<>"" Then
		Browser("name:="&sSyncPageTitle & ".*").Page("title:="&sSyncPageTitle & ".*").Sync
		errHandler Err, "utImageClick",g_iSeverity
   Else
   	
	Browser("name:="&sPageTitle & ".*").Page("title:="&sPageTitle & ".*").Sync
   	errHandler Err, "utImageClick",g_iSeverity
   End If		

End Sub

'****************************************************************
'	Name: utLinkClick
'	Purpose: This sub  clicks links on specified page	
'	Creator:unknown
'
'		Param: sTitle| required 
'		AllowedRange: 
'		Description:  . Name/Title of the Browser/Page
'
'		Param: sLink| required 
'		AllowedRange: 
'		Description:  name of the Link
' 
''
'		Param: iIndex| required 
'		AllowedRange: 
'		Description:  Index of the link
'
'		Param: sSyncPageTitle| required 
'		AllowedRange: 
'		Description:  Title of the page expected when the link is clicked.
'
'	Returns: N/A 
'**********************************************************************'
Public sub utLinkClick(sTitle,sLink,iIndex,sSyncPageTitle)

   
   
   If iIndex="" Then
	   iIndex=0
   End If
   
   Browser("name:="& sTitle &".*").Page("title:="& sTitle & ".*").Link("name:=.*" & sLink & ".*","Index:=" & iIndex).click
   errHandler Err, "utLinkClick", g_iSeverity
   
	If sSyncPageTitle<>"" Then
		Browser("name:=" & sSyncPageTitle & ".*").Page("title:=" & sSyncPageTitle & ".*").Sync
		errHandler Err, "utLinkClick",g_iSeverity
   Else
		Browser("name:="& sTitle &".*").Page("title:="& sTitle & ".*").Sync
		errHandler Err, "utLinkClick", g_iSeverity
   End If		
   
End Sub

'*************************************************************************************************************
'   	Name:    utSync
'   	Purpose:This sub will sync the given object
'   	Creator:unknown
'
'		Param: oSyncObject| required 
'		AllowedRange: 
'		Description: The object to be synced
'			eg.  To sync on a link give the following statement before calling thw 'vgnSync' function
'				Set  oSyncObject = Browser("vgnCDAHome").Page("vgnCDAHome").Link("name:=Search")
'				utSync oSyncObject

'
'   Returns:N/A  
'**********************************************************************'***************************************
Public Sub utSync(oSyncObject)

   

    Dim dtEndTime,bSynced

   	'Set a timeout of 60 seconds
		dtEndTime = DateAdd("s",60, Now)
		bSynced = False
	
        'Loop until the page synchronizes
		Do 
			If oSyncObject.Exist Then
				bSynced = True
			End If
		Loop While bSynced = False And dtEndTime > Now
		
	'If sync fails throw an error
		If bSynced = False Then
			Err.Description = "Failed to sync"
			errHandler Err,"utSync",g_iSeverity
		End If

End Sub

'*************************************************************************************************************
'	Name: 			    utReplaceUnwantedCharacters
'	Purpose:     		  To remove any provided unwanted characters
'			                   No separation character is required 
'	Creator:unknown
'						      			 
'	Param: 			  sOriginalString | required
'	AllowedRange:  
'	Description: 		 original string with unwanted characters

'	Param: 			  sUnwantedCharacters | required
'	AllowedRange:    
'	Description: 	    contains list of characters to be removed 

'	Returns:             Original string where specified characters replaced by ""
'****************************************************************************************************************
Public Function utReplaceUnwantedCharacters (sOriginalString, sUnwantedCharacters)

Dim sCharacter, iCounter

   If  Len(sUnwantedCharacters) = 0 or IsNull(sUnwantedCharacters) Then
	   utReplaceUnwantedCharacters = sOriginalString
	   Exit Function
   End If
   
	For iCounter=1 To Len(sUnwantedCharacters)
		sCharacter = Mid(sUnwantedCharacters,iCounter,1)
		If InStr (sOriginalString, sCharacter) > 0 Then
			sOriginalString =Trim(Replace(sOriginalString, sCharacter, ""))
		End If
	Next 'iCounter

	'to remove cents
	If InStr(sOriginalString, ".00") > 0  Then sOriginalString = Mid (sOriginalString, 1, Len(sOriginalString) -3)
	utReplaceUnwantedCharacters = sOriginalString
End Function

'****************************************************************************************************************
'	Name:utArraySort
'	Purpose: To sort supplied array in ascending or descending order
'	Creator: Mark Clemens
'	Param: asArray|required 
'	AllowedRange: 
'	Description: The array to be sorted.
'
'	Param: sSortingOrder|optional|AssumedValue="ascending" 
'	AllowedRange: 	"ascending", "descending"
'	Description: The order to sort the array		    
'
'	Returns: The sorted array.
'***************************************************************************************************************'
Public Function utArraySort(ByRef asArray, sSortingOrder)
	Dim sTemp, i, j
	If sSortingOrder = "" Then
		sSortingOrder = "ascending"
	End If

	 If UBound (asArray)  - LBound (asArray) < 1 Then  
	 	Exit Function' it's only 1 element - there is nothing to sort
	End If
   Select Case LCase(sSortingOrder)
	Case "desc", "descending"
		For i =0 To Ubound (asArray)
			For j = i+1 To Ubound (asArray)
				If asArray(i) < asArray (j)  Then
					sTemp = asArray(i)
					asArray(i) =asArray (j)
					asArray (j) =sTemp
					 sTemp = ""
				End If
			Next
		Next
	Case "asc", "ascending" 
		For i =0 To Ubound (asArray)
			For j = i+1 To Ubound (asArray)
				If asArray(i) > asArray (j)  Then
					sTemp = asArray(i)
					asArray(i) =asArray (j)
					asArray (j) =sTemp
					sTemp = ""
				End If
			Next	'j
		Next	'i    
	End Select
	
	utArraySort = asArray
End Function 

'*******************************************************************************************************************************
'Name: 	  utArraysComparison
'Purpose:	To compare two sorted arrays	
'Returns:  Returns TRUE - if the arrays are Identical
'*******************************************************************************************************************************
Public Function utArraysComparison (asArray1, asArray2)
	
	Dim i
	utArraysComparison = False
	
	 'if # of elements is not the same - exit
	If UBound(asArray1) <> UBound (asArray2) Then Exit Function

	'we expect these arrays to be identical 
	For i = 0 to UBound(asArray1)  ' can be asArray2, since it is the same number of elements
		If StrComp (asArray1(i), asArray2 (i), 1) <> 0 Then Exit Function '1 means that this is not case sensitive comparison
	Next	'i

	utArraysComparison = True 'means the arrays are identical
End Function




''**********************************************************************
'	Name: utRandomTableRowGet
'	Purpose:This function returns a random row from Web Table
'	Creator:unknown
'
'		Param: oObj|required
'		AllowedRange: 
'		Description:   The table object to get the random item 
'
'	Returns: rownumber
''**********************************************************************

Public Function utRandomTableRowGet(oObj)
	
	
	Dim iRowCount,iRandom
	
	'Gets Number of Rows in Table
	iRowCount= oObj.RowCount
	
	If iRowCount= 1  Then
		Err.Number = g_iITEM_NOT_FOUND
		Err.Description = "The table does not contain data"
		errHandler Err, "utRandomTableRowGet", micWarning
		utRandomTableRowGet = -1
		Exit Function
	End If
	
	iRandom = utGetRandomNumber(2, iRowCount)
		
	utRandomTableRowGet = iRandom

End Function

'**********************************************************************
'	Name:     IIF
'	Purpose: VBScript does not support function IIF widely used in VB / VBA
'				IIF returns one of its two parameters based on the evaluation of an expression
'				Example: IIF (2*2 > 4, "Wrong", "Correct")
'         		Here is the function which does exact the same job
'				To make it more natural, "u" is not used as a part of naming convention

'	Creator:Alex Margulis 
'
'	Param: sExpression|required
'	AllowedRange: 
'	Description: Expression to be evaluated

'	Param: sExpressionTrue|required
'	AllowedRange: 
'	Description:   defines what IIF returns if the evaluation of expression returns True. 

'	Param: sExpressionFalse|required
'	AllowedRange: 
'	Description:   defines what IIF returns if the evaluation of expression returns False.
'
'	Returns: sExpressionTrue / sExpressionFalse, based on the evaluation
''**********************************************************************
Public Function IIF (sExpression, sExpressionTrue, sExpressionFalse)
    
	If sExpression Then
		IIF = sExpressionTrue
	Else
		IIF =sExpressionFalse
	End If
End Function

''**********************************************************************
'	Name:     IsNothing
'	Purpose: VBScript does not support IsNothing widely used in VB / VBA
'                    Here is the function which does exact the same job
'    			 To make it more natural, "u" is not used as a part of naming convention
'	Creator: unknown
'
'	Param: obj|required
'	AllowedRange: 
'	Description: 
'
'	Returns: True /False, based on the object existance
''**********************************************************************
Public Function IsNothing (ByVal obj)
    
	If obj Is Nothing Then
		IsNothing = True
	Else
		IsNothing = False
	End If
End Function


'**********************************************************************
'	Name: utTransactionStart
'	Purpose:This sub starts the transaction and records the time when the transaction started
'						If  the transaction is already started it thorws an error indicating that has been alrady started.						
'   	Creator: Mark Clemens	
'
'		Param: sName | Required 
'		AllowedRange: 
'		Description: Name of the transaction to start
'
'
'	Returns: N/A 
'**********************************************************************'
Public Sub utTransactionStart(sName)
	

	Dim asElement, bTransFound, iCounter,sNow

	sNow =DotNetFactory.CreateInstance("System.DateTime").Now.ToString("MM/dd/yyyy hh:mm:ss:fff")
	If m_bEnableTrans = False Then
		Exit Sub
	Else
		If UBound(m_asTransactions) > 0 Or m_asTransactions(0) <> "" Then
			bTransFound = False
			For iCounter = 0 to UBound(m_asTransactions)
				asElement = Split(m_asTransactions(iCounter),"|")
				If sName = asElement(0) Then
					Err.Number = g_lINVALID_ARG
					Err.Description = "Attempt to start a transaction - " & sName & " - that has already been started."
					errHandler Err, "utStartTransaction", micWarning
					asElement(iCounter) = sName & "|" & sNow
					bTransFound = True
				End if
			Next
			If bTransFound = False Then
				ReDim Preserve m_asTransactions(UBound(m_asTransactions) + 1)
				m_asTransactions(UBound(m_asTransactions)) = sName & "|" & sNow
			End If
		Else
			m_asTransactions(0) = sName & "|" & sNow
		End If
	End If
	
End Sub

'**********************************************************************
'	Name: utTransactionEnd
'	Purpose:This sub Ends the transaction and write the duration of the trasaction 
' 						and how long it has been into script execution at that point.						
'   	Creator: Chaitanya
'
'		Param: sName | Required 
'		AllowedRange: 
'		Description: Name of the transaction to end.
'
'		Param: sPath | Required 
'		AllowedRange: 
'		Description: Path to create the file with transaction times. 
'								If path is not passed in then it would put the file int he results directory.
'						
'		Param: sDataTableName | Required 
'		AllowedRange: 
'		Description: Name of the file to write the values.
'
'	Returns: N/A 
'**********************************************************************'
Public Sub utTransactionEnd(sName, sPath, sDataTableName)
	

	Dim sTransName,dtTransDuration,dtTotalDuration,asTransactions,oExcel,oWorkbook
	Dim iRow,sTransFile,oFso, bTransFound, iCounter,sTransStartTime,cnTrConnect,rsTrRecSet
    Dim oFolder,oTable,oSheet,sSql
	
	If m_bEnableTrans = False Then
		Exit Sub
	Else

		'Added variable g_bDBConnections switch if the number of connections should be logged or not.
		If CBool(g_bDBConnections) = True Then

			Set cnTrConnect = CreateObject("Adodb.Connection")
			Set rsTrRecSet = CreateObject("Adodb.Recordset")

			Set cnTrConnect = odbcConnectionOpen(g_sDBServer, g_sAppDB, g_sAppDBUser, g_sAppDBPwd, "SQL")
			
			' Get the number of connections open for the user.
			'sConStr = "DRIVER=SQL Server;SERVER="& g_sDBServer &";User ID=" & g_sAppDBUser &";Password=" & g_sAppDBPwd &";database=" & g_sAppDB &";"
		'	sSql = "select count(dbid) as NumberOfConnections from sys.sysprocesses where dbid > 0 and DB_Name(dbid) = 'ny1501dvciPatchX'"
			sSql =  "SELECT DB_NAME(dbid) as DBName,COUNT(dbid) as NumberOfConnections,loginame as LoginName" &_
						  " FROM Master.sys.sysprocesses WHERE  DB_Name(dbid) = '" & g_sAppDB &"'and dbid != 0 and loginame = '" & g_sAppDB &"' GROUP BY dbid , loginame"
			'cnTrConnect.Open sConStr
			'rsTrRecSet.Open sSql,cnTrConnect,adOpenKeyset
			'rsTrRecSet.MoveFirst

			Set rsTrRecSet = odbcRecordSetOpen(cnTrConnect, sSql, adOpenKeyset, "")
		End If

		If UBound(m_asTransactions) > 0 or m_asTransactions(0) <>"" Then
			' Check for the transaction
			bTransFound = False

			For iCounter = 0 to UBound(m_asTransactions)
				' Calcuate the times for transaction.	
				asTransactions = Split(m_asTransactions(iCounter),"|")
				sTransName = asTransactions(0)

				If sName = sTransName Then
					bTransFound = True
					dtTransDuration = utDateDiffMS(asTransactions(1))
					'dtDuration = DateDiff ("s",asTransactions(1),Now)
					dtTotalDuration = DateDiff("s",m_dtScriptTime,Now)
					' Remove the element now that we have the data from it
					m_asTransactions = utArrayElementDelete (m_asTransactions, iCounter)
					If sPath = "" Then
						sTransFile = Environment("ResultDir") & "\" &sDataTableName
					Else
						sTransFile = sPath & "\" & sDataTableName
					End If

					' Create and excel file in the specified path of if the nothing is mentioned create in under the results directory.
					' Creates the folder in the path if doesn't exist
					If sPath <> "" Then
						sPath = winCreateFolderRecursive(sPath)
					End If

					Set oFso = CreateObject("Scripting.FileSystemObject")
					If Not oFso.FileExists(sTransFile &".xls") Then
						Set oExcel = CreateObject("Excel.Application")
						Set oWorkbook = oExcel.Workbooks.Add
						oWorkbook.ActiveSheet.Name = "Transactions"
						If sPath = "" Then
								If oExcel.Version=12.0 Then
									oWorkBook.SaveAs	Environment("ResultDir") & "\" &sDataTableName ,56
									'DefaultSaveFormat if Excel 2003 is being used
								Elseif oExcel.Version=11.0 Then
									 oWorkBook.SaveAs 	Environment("ResultDir") & "\" &sDataTableName
								End If
								oExcel.Quit
						 Else
								If oExcel.Version=12.0 Then
									oWorkBook.SaveAs	sPath & "\" &sDataTableName ,56
									'DefaultSaveFormat if Excel 2003 is being used
								Elseif oExcel.Version=11.0 Then
									 oWorkBook.SaveAs 	sPath & "\" &sDataTableName
								End If
								oExcel.Quit
								
						End If
						Set oExcel = Nothing
						Set oWorkbook = Nothing
						'MJN Fix
						Set oFolder = Nothing
						Set oFso = Nothing

						' Set Headers in the file.
						xclSetCellValue sTransFile, "Transaction Name", 1,1, "Transactions"
						xclSetCellValue sTransFile, "DateAndTime",1,2,"Transactions"
						xclSetCellValue sTransFile, "Total Transaction Duration (Seconds)", 1,3, "Transactions"						
						xclSetCellValue sTransFile, "Transaction Duration Into Script (Seconds)", 1,4, "Transactions"
					'Added variable g_bDBConnections switch if the number of connections should be logged or not.
						If Cbool(g_bDBConnections) = True Then
							xclSetCellValue sTransFile, "Number of DB Connections for the user " & g_sAppDB , 1,5, "Transactions"
						End If

					End If

					' Determine the path and write the data into the excel file.
					Set oExcel = CreateObject("Excel.Application")

					Set oTable = oExcel.Workbooks.Open(sTransFile)
					errHandler Err, "utTransactionEnd", g_iSeverity

					iRow = oTable.ActiveSheet.UsedRange.Rows.Count				
					'iRow = xclGetRowCount (sTransFile,"Transactions")

					oTable.Sheets(1).Select
					errHandler Err, "utTransactionEnd", g_iSeverity
					Set oSheet = oTable.Sheets(1)
					errHandler Err, "utTransactionEnd", g_iSeverity


					oSheet.Cells(iRow + 1,1) = sTransName
					errHandler Err, "utTransactionEnd", g_iSeverity
					oSheet.Cells(iRow + 1,2) = Now
					errHandler Err, "utTransactionEnd", g_iSeverity
					oSheet.Cells(iRow + 1,3) = dtTransDuration
					errHandler Err, "utTransactionEnd", g_iSeverity
					oSheet.Cells(iRow + 1,4) = dtTotalDuration
					errHandler Err, "utTransactionEnd", g_iSeverity
					'Added variable g_bDBConnections switch if the number of connections should be logged or not.
					If Cbool(g_bDBConnections) = True Then
						oSheet.Cells(iRow + 1,5) = rsTrRecSet.Fields("NumberOfConnections").Value
						errHandler Err, "utTransactionEnd", g_iSeverity
					End If

					oExcel.DisplayAlerts = False
					 errHandler Err, "utTransactionEnd", g_iSeverity
					oExcel.ActiveWorkbook.Save
					errHandler Err, "utTransactionEnd", g_iSeverity
					oExcel.Application.Quit
					errHandler Err, "utTransactionEnd", g_iSeverity
		
					'oTable.Close
					Set oTable = Nothing
					oExcel.Quit
					Set oExcel = Nothing
					errHandler Err, "utTransactionEnd", g_iSeverity
		
					Exit For
				End If
			Next		
		Else
			bTransFound = False
		End If

		If CBool(g_bDBConnections) = True Then

			rsTrRecSet.Close
			Set rsTrRecSet = Nothing

			odbcConnectionClose cnTrConnect
		End If

		If bTransFound = False Then
			Err.Number = g_iITEM_NOT_FOUND
			Err.Description = "End transaction requested when transaction name - " & sName & " - has not been started."
			errHandler Err, "utTransactionEnd", micWarning
		End If

	End If

	If g_iTransWaitTime <> 0 Then
		wait g_iTransWaitTime
	End If

End Sub

'**********************************************************************
'	Name: utTransactionEnable
'	Purpose:This sub  enables and disables transcations.		
'   Creator: Chaitanya
'
'		Param: bEnable | Required 
'		AllowedRange: True, False, 1, 0
'		Description: This function enables or diables transactions
'	
'	Returns: N/A 
'**********************************************************************'
Public Sub utTransactionEnable(bEnable)

	m_dtScriptTime = Now
	'MJN Fix
	If CBool(bEnable) = True Then
		m_bEnableTrans = True
	Else 
		m_bEnableTrans = False
	End If

End Sub

'**********************************************************************
'	Name: utTimeStamp
'	Purpose: This function returns a timestamp by concatenating the system date and Time. 
'		Format: <Month><Date><Hour><Minute><Seconds>
'	Creator: Priya
'
'	Returns: The timestamp
'**********************************************************************
Public Function utTimeStamp()
	
	Dim sTimeStamp
   
	sTimeStamp=GetFSDateTimeStamp(now)
	
	utTimeStamp=Mid(Replace(sTimeStamp,"_",""),5)
	
End Function

'**********************************************************************
'	Name: utDateDiffMS
'	Purpose:	This function returns the transaction times calculated upto milliseconds.
'	Creator:Chaitanya Katta
'
'		Param: sTransStartTime | Required 
'		AllowedRange: 
'		Description: Start Time of the transactions
'
'	Returns: Transaction Duration in upto milliseconds. 
'**********************************************************************
Public Function utDateDiffMS(sTransStartTime)

	Dim sTransEndTime,dtTransDuration,iSeconds,asTransStartTime,asStartTime,dtStartTime,sStartTime
	Dim  asEndTime,sEndTime,dtEndTime,asTransEndTime,sMilliSecs

'	 Start Time of the transaction from utStartTransaction	
	asTransStartTime = Split (sTransStartTime," ")
	
	asStartTime = Split (asTransStartTime(1),":")
	sStartTime = asStartTime(0) &":" & asStartTime(1) &":" & asStartTime(2)
	dtStartTime = asTransStartTime(0) &" " & sStartTime

	' End Time of the transaction
	sTransEndTime =  DotNetFactory.CreateInstance("System.DateTime").Now.ToString("MM/dd/yyyy hh:mm:ss:fff")
	asTransEndTime = Split (sTransEndTime," ")

	asEndTime = Split (asTransEndTime(1),":")
	sEndTime = asEndTime(0) &":" & asEndTime(1) &":" & asEndTime(2)
	dtEndTime = asTransEndTime(0) &" " & sEndTime
    ' Calculating the total time upto milliseconds.
	iSeconds = dateDiff("s",dtStartTime,dtEndTime)
	sMilliSecs = (asEndTime(3)-asStartTime(3))/1000
	dtTransDuration = iSeconds + sMilliSecs
    utDateDiffMS = dtTransDuration

End Function

'**********************************************************************
'	Name: utArrayElementDelete
'	Purpose:	This sub deletes an element from an array based on the index that is passed in.
'	Creator:Mark Clemens
'
'		Param: avArray | Required 
'		AllowedRange: 
'		Description: Array from which the element has to be deleted
'
'		Param: iElement | Required 
'		AllowedRange: 
'		Description: Index number of element that has to be deleted starts with '0'
'
'	Returns: Transaction Duration in upto milliseconds. 
'**********************************************************************
Public Function utArrayElementDelete(ByRef avArray, ByVal iElement)

	Dim avTemp, iCounter
	ReDim avTemp(0)
	For iCounter = 0 to UBound(avArray)

		If iCounter <>iElement Then
			If UBound(avTemp) <> 0  Then
			
				ReDim Preserve avTemp(UBound(avTemp)+ 1)
				avTemp(UBound(avTemp)) = avArray(iCounter)
			ElseIf UBound(avTemp) = 0 And IsEmpty(avTemp(0)) = True Then
				avTemp(0)= avArray(iCounter)
			Else 
				ReDim Preserve avTemp(UBound(avTemp)+ 1)
				avTemp(UBound(avTemp)) = avArray(iCounter)

			End If
		End If

	Next

	utArrayElementDelete = avTemp
	
End Function

'**********************************************************************
'	Name: utSSNFormat
'	Purpose:	This function formats the SSN number to nnn-nn-nnnn 
'	Creator: unknown
'
'		Param: iSecurityNumber | Required 
'		AllowedRange: 
'		Description: Social Security Number to be formatted
'
'	Returns: SSN number in  nnn-nn-nnnn 
'**********************************************************************

Public Function utSSNFormat(iSecurityNumber )

	

	iSecurityNumber = Trim(Replace(iSecurityNumber,"-",""))
	If Len(iSecurityNumber) < 9 Then
		iSecurityNumber = utNumPadZeroes (iSecurityNumber , 9)
	End If
	
	utSSNFormat =  left(iSecurityNumber,3) & "-" & mid(iSecurityNumber,4,2) & "-" & right(iSecurityNumber,4)

	
End Function

'**********************************************************************
'	Name: utSINFormat
'	Purpose:	This function formats the SIN number to nnn-nnn-nnn 
'	Creator: unknown
'
'		Param: iSecurityNumber | Required 
'		AllowedRange: 
'		Description: Social Insurance Number to be formatted
'
'	Returns: SIN number in  nnn-nnn-nnn 
'**********************************************************************
Public Function utSINFormat(iSecurityNumber )

	
	If  Len(iSecurityNumber) < 9 Then
	iSecurityNumber = utNumPadZeroes (iSecurityNumber , 9)
	End If
	
	utSINFormat =  left(iSecurityNumber,3) & "-" & mid(iSecurityNumber,4,3) & "-" & right(iSecurityNumber,3)

End Function

'**********************************************************************
'	Name: utTINFormat
'	Purpose:	This function formats the TIN number to nn-nnnnnnn 
'	Creator:unknown 
'
'		Param: iSecurityNumber | Required 
'		AllowedRange: 
'		Description: Tax ID Number to be formatted
'
'	Returns: TIN number in  nn-nnnnnnn 
'**********************************************************************
Public Function utTINFormat(iSecurityNumber )

	
	If  Len(iSecurityNumber) < 9 Then
	iSecurityNumber = utNumPadZeroes (iSecurityNumber , 9)
	End If
	
	utTINFormat  =  left(iSecurityNumber , 2) & "-" & right(iSecurityNumber, 7)

End Function

''**********************************************************************
'	Name: utGetMatchingFileCount
'	Purpose: This function returns the number of files that match a regex
'		pattern in a provided folder.
'	Creator: Mark Clemens
'
'		Param: sPath|required
'		AllowedRange: 
'		Description:   The path to the folder with the files.
'
'		Param: sRegExPtn|required
'		AllowedRange: 
'		Description:   The regex pattern to match for the file names.
'
'	Returns: The count of the files that match the regex pattern..
''**********************************************************************
Public Function utGetMatchingFileCount(sPath, sRegExPtn)

	Dim fso, oFolder, colFiles, oFile, re, colMatches, iCount
	iCount = 0

	' Create the regexp object and assign properties
	Set re = New regexp
	re.Pattern = sRegExPtn
	re.IgnoreCase = True
	re.Global = True

	' Create the file system object, and get the collection of files
	' in the provided folder.
   	Set fso = CreateObject("scripting.filesystemobject")
   	If fso.FolderExists(sPath) Then
		Set oFolder = fso.GetFolder(sPath)
		Set colFiles = oFolder.Files

		' Loop through the collection of files and get the count of 
		' the files that match the regex pattern.
		For Each oFile in colFiles
			Set colMatches = re.Execute(oFile.Name)
			If colMatches.Count > 0 Then
				iCount = iCount + 1
			End If
		Next
	End If

	Set fso = Nothing

	utGetMatchingFileCount = iCount

End Function

''**********************************************************************
'	Name: utHoldForFiles
'	Purpose:This function will hold execution of subsequent lines of code (a blocking call)
'		until the indicated number of files are created that match the indicated regex pattern
'		for the file names within the indicated folder.  The function will hold for the indicated
'		timeout.
'	Creator: Mark Clemens
'
'		Param: sPath|required
'		AllowedRange: 
'		Description:   The path to the folder with the files.
'
'		Param: sRegExPtn|required
'		AllowedRange: 
'		Description:   The regex pattern to match for the file names.
'
'		Param: iCount|required
'		AllowedRange: 
'		Description:   The desired count of files with file names that match the above regex pattern.
'
'		Param: iTimeOutSeconds|optional|AssumedValue=600 (10 minutes)
'		AllowedRange: Any positive whole number.
'		Description:   The time to wait in seconds.
'
'	Returns: True if the desired number of files with matching names appeared within the timeout, else False.
''**********************************************************************
Public Function utHoldForFiles(sPath, sRegExPtn, iCount, iTimeOutSeconds)
	

	Dim bAllThere, iCheckCount, dtEndTime, iMaxCount, oFso

	Set oFso = CreateObject("Scripting.FileSystemObject")

	' If no timeout was passed in, set it to the default of 600 seconds (10 minutes)
	If iTimeOutSeconds = "" Then
		iTimeOutSeconds = 600
	End If

	' The variable to track the maximum number of matches that were attained.
	iMaxCount = 0

	' A flag that is set to exit the loop below
	bAllThere = False

	' Set our end time for the time out.
	dtEndTime = DateAdd("s", iTimeOutSeconds, Now())

	If oFso.FolderExists(sPath) Then
		' Loop until the desired number of files exist, or until the timeout.
		Do 
			' Get the number of files with names that match the regex pattern.
	        iCheckCount = utGetMatchingFileCount(sPath, sRegExPtn)
			' Set the maximum number of matched files for logging later if necessary.
			If iCheckCount > iMaxCount Then
				iMaxCount = iCheckCount
			End If
			' IF the number of matched files is obtained or exceeded, set the flag to exit the loop.
			If iCheckCount >= iCount Then
				bAllThere = True
			End If
		Loop While bAllThere = False And Now() < dtEndTime

		' If the number of matched files was not obtained, log the relevant data.
		If bAllThere = False Then
			Err.Number = 0
			Err.Description = "Failed to hold for count of files." & vbcrlf & _ 
				"Desired count = " & iCount & vbcrlf & _
	            "Max count achieved = " & iMaxCount & vbcrlf & _
				"Timeout used in secondes = " & iTimeOutSeconds
			errHandler Err, "utHoldForFiles", micInfo
		End If
	End If

	Set oFso = Nothing

	'Set the function to return the success or failure of obtaining the max number of matched files desired.
	utHoldForFiles = bAllThere

End Function

''*********************************************************************************
'	Name: utDigitsToRandomNumString
'	Purpose:This function generates the string of a random number with given number of digits
'
'	Creator:unknown
'
'		Param: iNumOfDigits|required
'		AllowedRange: 
'		Description:   The number of digits to be in string from numeric. eg 4 digit number or a 3 digit number 
'							  Note: If 'iNumOfDigits=3' ten the function might return 'TwoFourFive' which depends 
'							  on the number that is generated at random.
'
'	Returns: The random number generated with the no of digits passed in string from numeric
''*********************************************************************************
Public Function utDigitsToRandomNumString(iNumOfDigits)

   Dim sString,arrRandomNum(),sNameString,iCounter

	iNumOfDigits = Cint(iNumOfDigits)

	For iCounter = 0 to iNumOfDigits - 1

		ReDim Preserve arrRandomNum(iCounter)

		'Generate a random number between 1 and 9
        arrRandomNum(iCounter) = utGetRandomNumber (1,9)

		'Get the string of the random number
		Select Case arrRandomNum(iCounter) 
			Case 0
				sString = "Zero"
			Case 1
				sString = "One"
			Case 2
				sString = "Two"
			Case 3
				sString = "Three"
			Case 4
				sString = "Four"
			Case 5
				sString = "Five"
			Case 6
				sString = "Six"
			Case 7
				sString = "Seven"
			Case 8
				sString = "Eight"
			Case 9
				sString = "Nine"
		End Select

		sNameString = sNameString & sString

	Next

	'Return the number in string from numeric
	utDigitsToRandomNumString = sNameString

End Function

''*********************************************************************************
'	Name: utNumToString
'	Purpose:This function generates a string with given numbers
'	Creator:unknown
'
'		Param: iNum|required
'		AllowedRange: 
'		Description:   The number to be converted from numeric to string.
'							  Eg: If 'iNum=1234' then the function might return 'OneTwoThreeFour' 
'
'	Returns: The number in string from numeric
''*********************************************************************************
Public Function utNumToString(iNum)

	Dim iLen,iCounter,sGetNum,sNum,sNameString,sString

	'Converting to string
	sNum  = Cstr(iNum)

	'Get the length of string
	iLen  = Len(sNum)

	'Loop to convert each digit in the number from numeric to string
	For iCounter  = 1 to iLen

		sGetNum = Mid(sNum,iCounter,1)

		Select Case sGetNum
			Case 0
				sString = "Zero"
			Case 1
				sString = "One"
			Case 2
				sString = "Two"
			Case 3
				sString = "Three"
			Case 4
				sString = "Four"
			Case 5
				sString = "Five"
			Case 6
				sString = "Six"
			Case 7
				sString = "Seven"
			Case 8
				sString = "Eight"
			Case 9
				sString = "Nine"
		End Select

		sNameString = sNameString & sString

	Next
	
	'Return the number in string from numeric
	utNumToString = sNameString
	
End Function

''**********************************************************************
'	Name: utRegExpExecute
'	Purpose:This function returns whether the pattern is present in the String
'	Creator:unknown
'
'		Param: sPattern|required
'		AllowedRange: 
'		Description:   The pattern of the Regular Expression eg. [0-9],[a-z] etc
'
'		Param: sString|required
'		AllowedRange: 
'		Description:   The string to be checked for the pattern
'
'	Returns: True if pattern is present and False if it is not Present
''**********************************************************************
Public Function utRegExpExecute(sPattern,sString)

		Dim oRegEx,Match,Matches

		utRegExpExecute = False		
		
		Set oRegEx = New RegExp
		oRegEx.Pattern = sPattern
	
		Set Matches = oRegEx.Execute(sString)
	
		For Each Match in Matches
			utRegExpExecute = True
		Next

End Function


'****************************************************************
'	Name: utIsArrayEmpty
'	Purpose: This function will return whether or not an array is empty - i.e., it hasn't been initialized.
'		It does so by checking the UBound of the array.  If it is empty, an error number - 9 or 13 - will
'		be returned.  The function checks the error number.  If it's 0, the Array is not empty and False
'		is returned, if it is 9 or 13, the array is empty and True is returned.
'
'	Creator: Mark Clemens
'
'	Param: oArray | required
'	AllowedRange:  
'	Description:  The array to evaluate for being empty. 
'
'	Returns: True if the array is empty (hasn't been initialized, False if it not empty (has been initialized.
'**********************************************************************' 
Public Function utIsArrayEmpty(oArray)
	
	Dim iNum
	' Get the UBound of the array
	iNum = UBound(oArray)
	' If an error was returned, the array is empty
	If Err.Number = 13 Or Err.Number = 9 Then
		utIsArrayEmpty = True
	Else
		utIsArrayEmpty = False
	End If
	' Clear the error condition
	Err.Clear

End Function

'****************************************************************
'	Name: utArrayValueExists
'	Purpose: This checks to see if an array value exists.  
'		It returns True if it does, and False if it doesn't.
'
'	Creator: Mark Clemens
'
'	Param: avArray| required
'	AllowedRange:  
'	Description:  The array to search for a value. 
'
'	Param: sValue| required
'	AllowedRange:  
'	Description:  The value to search for. 
'
'	Returns: True if the value exists in the array, False if it does not..
'**********************************************************************' 
Public Function utArrayValueExists(avArray, sValue)
	

	Dim bEmpty, iCtr
	' Initialize to False
	utArrayValueExists = False
	' If the array is empty, return False
	If utIsArrayEmpty(avArray) = True Then
		utArrayValueExists = False
		Exit Function
	End If
	' Loop through the array and check for the value
	For iCtr = 0 to UBound(avArray)
		' If the value is present in the array, return True
		If StrComp(avArray(iCtr),sValue,1) = 0 Then
			utArrayValueExists = True
			Exit Function
		End If
	Next

End Function
'****************************************************************
'	Name: utConditionBool
'	Purpose: This function evaluates many possible boolean
'		values and returns either "ON" or "OFF".
'
'	Creator: Mark Clemens
'
'	Param: vBool| required
'	AllowedRange:  
'	Description:  The boolean value to evaluate. 
'
'	Returns: "ON" or "OFF"
'**********************************************************************' 
Public Function utConditionBool(vBool)
	
	
	If isNumeric(vBool) = False Then
		vBool = LCase(vBool)
	ElseIf vBool = 1 Then
		vBool = "true"
	ElseIf vBool = 0 Then
		vBool = "false"
	End If

	Select Case vBool
		Case "true","yes", "on", True
			utConditionBool = "ON"
		Case "false", "no", "off", False
			utConditionBool = "OFF"
		Case Else
			Err.Number = g_iINVALID_INPUT
			Err.Description = vBool & " is not valid."
			errHandler Err, "utConditionBool", g_iSeverity
	End Select

End Function

'****************************************************************
'	Name: utEscapeRegExChars
'	Purpose: This function  adds backslash infront of Regular Expression characters.
'	Creator: Polina Rodov
'
'	Param: sString| required
'	AllowedRange:  Any text
'	Description:  The string to be modified.
'
'	Returns: modified sString
'**********************************************************************' 
Public Function utEscapeRegExChars(ByVal sString)
   

   	If IsNull(sString) Then
   		sString = " "
   	End If

	'+
    sString = Replace(sString,"+","\+")
	errHandler Err,"utEscapeRegExChars",g_iSeverity
	'(
    sString = Replace(sString,"(","\(")
	errHandler Err,"utEscapeRegExChars",g_iSeverity
	')
    sString = Replace(sString,")","\)")
	errHandler Err,"utEscapeRegExChars",g_iSeverity
	'.
	sString = Replace(sString,".","\.")
	errHandler Err,"utEscapeRegExChars",g_iSeverity
	'^
	sString = Replace(sString,"^","\^")
	errHandler Err,"utEscapeRegExChars",g_iSeverity
	'$
    sString = Replace(sString,"$","\$")
	errHandler Err,"utEscapeRegExChars",g_iSeverity
	'*
	sString = Replace(sString,"*","\*")
	errHandler Err,"utEscapeRegExChars",g_iSeverity
	'?
	sString = Replace(sString,"?","\?")
	errHandler Err,"utEscapeRegExChars",g_iSeverity
	'/
	sString = Replace(sString,"/","\/")
	errHandler Err,"utEscapeRegExChars",g_iSeverity

	utEscapeRegExChars = sString
	
End Function

'****************************************************************
'	Name: utGetAge
'	Purpose: This function  calculates the an age based on a DOB that is passed in.
'	Creator: Polina Rodov
'
'	Param: sDOB| required
'	AllowedRange:  "<mm>/<dd>|<yyyy>"
'	Description:  The Date of birth.
'
'	Returns: Age
'**********************************************************************' 
Public Function utGetAge(sDOB)

   Dim iAge
   iAge=DateDiff("d",cDate(sDOB),Now)
   utGetAge=Left(iAge/365,2)
End Function
'****************************************************************
'	Name: utOperatorGet
'	Purpose: This function  returns an operator based on a text string.
'	Creator: Chaitanya Katta
'
'	Param: sOperator| required
'	AllowedRange: EX: GreaterThanOrEqualTo or LessThanOrEqualTo
'	Description: Operator tobe converted to symbols.
'
'	Returns: Age
'**********************************************************************' 
Public Function utOperatorGet (sOperator)


	Select Case LCase(sOperator)

		Case null,"none"
			sOperator = ""

		Case "lessthanorequalto"
			sOperator = "<="

		Case "greaterthanorequalto"
			sOperator = ">="

		Case "greaterthan"
			sOperator = ">"

		Case "lessthan"
			sOperator = "<"
		Case "equalto"
			sOperator = "="
		Case Else
			Err.Description = "The operator: " & sOperator & " is not covered in this function."
			Err.Number = g_iITEM_NOT_FOUND
			errHandler Err,"utOperatorGet",g_iSeverity
	End Select

	utOperatorGet = sOperator
End Function

'**********************************************************************
'	Name: utTimeStampOnly
'	Purpose: This function returns a timestamp by concatenating the system date and Time. 
'		Format: <Hour><Minute>
'	Creator: Michael J. Nohai
'
'	Returns: Hours and Minutes
'**********************************************************************
Public Function utTimeStampOnly()
	
	
	Dim sTimeStamp, sText
   
	sTimeStamp = GetFSDateTimeStamp(now)

	sText = Mid(Replace(sTimeStamp,"_",""), 9, 4)

	utTimeStampOnly = sText
	
End Function

''**********************************************************************
'	Name: utWebTableGetHeaders 
'	Purpose:This function retrieves the column header names from a web table and
'		returns an array of those headers.
'	Creator:Mark Clemens
'
'		Param: oTable|required
'		AllowedRange: 
'		Description:   The web table object.
'
'		Param: iHeaderRow|optional|AssumedValue=1
'		AllowedRange: 
'		Description:   The row in the table that contains the headers. 
'
'	Returns: An array of the column header names.
''**********************************************************************
Public Function  utWebTableGetHeaders(oTable, iHeaderRow)
	
	Dim asHeaders, iCtr, iColCount
	'Redim the array with zero elements . . . (it's a vb thing)
	Redim asHeaders(0)
	'Set the header row to the default if it is empty
	If iHeaderRow = "" Then
		iHeaderRow = 1
	End If
	'Loop through  the columns and add each header to the array
	iColCount = oTable.GetROProperty("cols")
	For iCtr = 1 To iColCount
		ReDim Preserve asHeaders(iCtr - 1)
		asHeaders(Ubound(asHeaders)) = oTable.GetCellData(iHeaderRow, iCtr)
	Next
	'Return the array of header names
	utWebTableGetHeaders = asHeaders
	
End Function

''**********************************************************************
'	Name: utArrayGetIndex 
'	Purpose:This function retrieves the index of the first occurence of an
'		an array.
'	Creator:Mark Clemens
'
'		Param: avArray|required
'		AllowedRange: 
'		Description: The array to be searched.
'
'		Param: sVal|required
'		AllowedRange: 
'		Description: The value to search for. 
'
'	Returns: The index of the first occurence of the array element.  If not found, will return -1.
''**********************************************************************
Public Function utArrayGetIndex(avArray, sVal)
	
	Dim iCtr, iIndex
	iIndex = -1
	
	For iCtr = 0 To UBound(avArray)
		If LCase(avArray(iCtr)) = LCase(sVal) Then
			
			iIndex = iCtr
			Exit For
			
		End If
	Next
	utArrayGetIndex = iIndex	
End Function


''**********************************************************************
'	Name: utWebTableGetRows 
'	Purpose:This function retrieves the rows that match the criteria that is passed in (see parameter).
'	Creator:Mark Clemens
'
'		Param: iStartRow|optional|AssumedValue=2
'		AllowedRange: 
'		Description: The row to start the search.  If empty, the search will start at the second row, assuming the first row contains the column headers.
'
'		Param: oTable|required
'		AllowedRange: 
'		Description: The table object to be searched. 
'
'		Param: sCriteria|required
'		AllowedRange: 
'		Description: The criteria to search delimited by the pipe symbol, in the following format:
'			<FirstCol>=<FirstValue>|<SecondCol>=<SecondVal>|<ThirdCol>=<ThirdVal> . . .
'
'	Returns: An array of the row numbers that match.  If an empty array is returned, no rows matched. The returned array can be checked with the utIsArrayEmpty function.
''**********************************************************************
Public Function utWebTableGetRows(iStartRow, oTable, sCriteria)
	
	Dim iCtr, asWheres, asWhere, asHeaders, iHdrCtr, bFound, bNoMatch, aiRows(), iCurElement, iWhereCtr
	'ReDim aiRows(0)
	asHeaders = utWebTableGetHeaders(oTable,1)
	
	asWheres = SPlit(sCriteria,"|")
	
	' Next section, check that all of the column headers in the query exist in the actual table.  If not,
	' throw an error and exit
	' *********************************
	For iCtr = 0 To UBound(asWheres)
		asWhere = Split(asWheres(iCtr),"=")
		bFound = False
		
		For iHdrCtr = 0 To UBound(asHeaders)
			If LCase(asHeaders(iHdrCtr)) = LCase(asWhere(0)) Then
				bFound = True
				Exit For
			End If
			
		Next
		If bFound = False Then
			Err.Number = g_iITEM_NOT_FOUND
			Err.Description = "The column header in the query - " & asWhere(0) & " - does not exist in the web table."
			Err.Raise g_iITEM_NOT_FOUND
			Exit Function
		End If
		
	Next
	'******************************************

' Loop through the table and look for matches . . .
	For iCtr = iStartRow To oTable.GetROProperty("rows")
		bNoMatch = False
		For iWhereCtr = 0 To UBound(asWheres)
			asWhere = Split(asWheres(iWhereCtr),"=")
			
			'If LCase(asWhere(1)) <> LCase(Browser("brCRM").Page("pgCRM").WebTable("class:=listBorder").GetCellData(iCtr, utArrayGetIndex(asHeaders, asWhere(0)) + 1)) Then
			If utRegExpExecute (LCase(asWhere(1)), LCase(Browser("brCRM").Page("pgCRM").WebTable("class:=listBorder").GetCellData(iCtr, utArrayGetIndex(asHeaders, asWhere(0)) + 1))) = False Then
				bNoMatch = True
				Exit For
			End If			
			
			
		Next
		' If a match is found, add the row number to the array
		If bNoMatch =  False Then
			ReDim Preserve aiRows(iCurElement)
			aiRows(UBound(aiRows)) =  iCtr
			iCurElement = iCurElement + 1
			
		End If
		
	Next
		
	utWebTableGetRows = aiRows



End Function

''**********************************************************************
'	Name: utConditionFileName 
'	Purpose:This function takes a proposed file name and removes all
'		of the illegal characters with a replacement character.
'	Creator:Mark Clemens
'
'		Param: sFileName|required
'		AllowedRange: 
'		Description: The proposed file name.
'
'		Param: sReplace|optional|AssumedValue=""
'		AllowedRange: Any legal file name character.
'		Description: The character to replace the illegal characters with - e.g., "", " ", etc. 
'
'	Returns: The file name with any illegal characters replaced.
''**********************************************************************
Public Function utConditionFileName(sFileName, sReplace)
	
	sFileName = Replace(sFileName,"/",sReplace)
	sFileName = Replace(sFileName,"\",sReplace)
	sFileName = Replace(sFileName,":",sReplace)
	sFileName = Replace(sFileName,"*",sReplace)
	sFileName = Replace(sFileName,"?",sReplace)
	sFileName = Replace(sFileName,CHR(34),sReplace)
	sFileName = Replace(sFileName,"<",sReplace)
	sFileName = Replace(sFileName,">",sReplace)
	sFileName = Replace(sFileName,"|",sReplace)
	utConditionFileName = sFileName
	
End Function


'**********************************************************************
'	   Name: utLogRunData
'	   Purpose:This function logs the application and run details for the script run.
'	   Creator: Amit More
'
'       Param: sApp| required 
'       AllowedRange:   
'       Description: The name of the apllication will be passed as an input
'
'       Param: sTCCovered| required                                   
'       AllowedRange:  "TC_001" OR "TC_001,TC_002,TC_003" Can separate the test cases covered by commas
'       Description: The tesetcase(s) covered in the run script for which the details need to be logged
'
'       Param: sRunType| required                                        
'       AllowedRange:  "Sanity" / "Regression"
'       Description: The type of run for which the details need to be logged
'       
'       Returns: N/A
'**********************************************************************
Public Sub utLogRunData (ByVal sApp, sTCCovered, sRunType)

	Dim sExecBy, sExecDate, sMachine, sScriptName
	
	Dim sReleaseVals,asTemp,sRelease,sBuildNumber
	
	'get the release info from login.ini  
	sReleaseVals=utReleaseInfoGet(sApp)	
	asTemp=Split(sReleaseVals,"|")	
	sRelease=asTemp(0)	
	sBuildNumber=asTemp(1)	
	if sRelease=trim("DryRun") then
		'g_sRootPath = "\\PTC-WGQTPSVN101\Logs\DryRun\"
		 'g_sRootPath = "C:\Users\JannelaS\Desktop\DryRunResults"
	end if
	PrintToLog "**************************************** Script Run Details ***********************************"
	sApp = "Application Name: " & sApp
	sScriptName = "Script Name: " & Environment.Value("TestName")
	PrintToLog sApp
	If sRunType = "EnvironmentCertification" Then
		sScriptName = "Script Name: " & Environment.Value("ActionName")
	Else
		sScriptName = "Script Name: " & Environment.Value("TestName")
	End if
	PrintToLog "Test Cases Covered: " & sTCCovered
	sExecBy = "Executed By: " & Environment.Value("UserName")
	PrintToLog sExecBy
	sExecDate = "Execution Date: " & Now
	PrintToLog sExecDate
	sMachine = "Machine Name: " & Environment.Value("LocalHostName")
	PrintToLog sMachine
	PrintToLog "Run Type: " & sRunType
	PrintToLog "Release: " & sRelease
	PrintToLog "BuildNumber: " & sBuildNumber
	PrintToLog "**************************************** End Run Details ***************************************************"

End Sub


'**********************************************************************
'	   Name: utTrimAll
'	   Purpose:This function removes all leading and trailing crlf's, tabs, and spaces.
'	   Creator: Mark Clemens
'
'       Param: sString| required 
'       AllowedRange:   
'       Description: The string to be trimmed.
'       
'       Returns: The string with the leading and trailing crlf's, tabs and spaces removed.
'**********************************************************************
Public Function utTrimAll(sString)
	
	Dim iCtr

	' Remove all of the trailing crlf's, tabs or spaces
	For iCtr = Len(sString) To 1 Step - 1
		If Mid(sString,iCtr,1) = vbCRLF Or _ 
			Mid(sString,iCtr,1) = vbCR Or _
			Mid(sString,iCtr,1) = vbLF Or _
			Mid(sString,iCtr,1) = vbTab Or _ 
			Mid(sString,iCtr,1) = " " Then
			sString = Mid(sString,1,Len(sString) - 1)
		Else	
			Exit For
		End If
	Next
	
	' Remove all of the leading crlf's, tabs or spaces
	Dim bTrimmed
	bTrimmed = False
	Do
		
		If Mid(sString,1,1) = vbCRLF Or _ 
			Mid(sString,1,1) = vbCR Or _
			Mid(sString,1,1) = vbLF Or _
			Mid(sString,1,1) = vbTab Or _ 
			Mid(sString,1,1) = " " Then
			sString = Mid(sString,2)
		Else
			bTrimmed = True		
			Exit Do
		End If		
	Loop While bTrimmed = False
	
	utTrimAll = sString
	
End Function

  
'**********************************************************************
'   Name: utVerifyResult
'	Purpose:This sub procedure takes information from a verification point
'	and logs it to the Moody's automation framework log file.
'   Creator: Rod Maturan
'
'   Param: micStatus| required 
'   AllowedRange: micPass, micWaring, micFail
'   Description: The outcome of the verification that is to be reported.
'
'   Param: sRoutineName| required                                   
'   AllowedRange:  "", non-empty string
'   Description: The name of the containing function or sub procedure.
'
'   Param: sTestCaseID| required                                        
'   AllowedRange:  "", non-empty string
'   Description: A label which maps to or specifies a unique test case.
'
'	Param: sVerificationDescription| required
'	AllowedRange: "", non-empty string
'	Description: Text which provide more information about the verification details.
'                               
'     Returns: N/A
'**********************************************************************  
Public Sub utVerifyResult(ByVal micStatus, ByVal sRoutineName, _
	ByVal sTestCaseID, ByVal sVerificationDescription)
	
	Dim sTestCaseDelimiter : sTestCaseDelimiter = "::"
	Dim sTestCaseSpecifier : sTestCaseSpecifier = ""
	If sTestCaseID <> "" Then sTestCaseSpecifier = sTestCaseSpecifier & sTestCaseDelimiter
			
	Select Case micStatus
		Case micPass
			Err.Number = 0
		Case micFail
			Err.Number = g_iVERIFICATION_FAILED		
	End Select
	Err.Description = sVerificationDescription
	errHandler Err, sTestCaseSpecifier & sRoutineName, micResult
End Sub  



'**********************************************************************
'	  Name: utCopyRunResults
'	  Purpose:This Sub Copy the run results of current test under desired Location.    
'		    Folder hierarchy will be sRootPath\sApp\sRunType\TimeStamp
'			Result will be copied if flag g_bDebugMode=False.
'	 Creator: Amit More
'
'       Param: sApp| required 
'       AllowedRange:   
'       Description: The name of the apllication will be passed as an input
'
'       Param: sRunType| required                                        
'       AllowedRange:  "Sanity" / "Regression"
'       Description: The type of run for which the details need to be logged

'		Param: sRootPath| required                                        
'       AllowedRange: 
'       Description: Path of Root Folder where results need to be copied.
'              
'       Returns: N/A
'**********************************************************************
Public Sub utCopyRunResults(sApp,sRunType,sScriptName,sRootPath,ByRef sReferenceLogFilePath)
	
	Dim fso, sSourcePath,sSourceFolderPath,sTempPath,sDate,sTime,sDateTime
	Dim oFile,oFolder, strFile, strLine, oFileE, sExecType, sFilePath, sCopyPath
	
	' Updated this function to take care of the copy functionality from local to shared drive in case of bulk execution -- Amit More
	'Get the path of current test result into a string
	sSourceFolderPath = Environment("ResultDir")
	
	Set fso = CreateObject("Scripting.FileSystemObject")    
	'File is created to keep a track of the filepath and the copy path to the destination folder
	strFile = "C:\temp\CopyLog.txt"
	'This condition checks whether file is already created or it is the first run on this machine
	If fso.FileExists(strFile) Then
		Set oFileE = fso.OpenTextFile(strFile, 1)
		Do Until oFileE.AtEndOfStream		    
		    strLine= oFileE.ReadLine	
		Loop
		sFilePath = Split(strLine,"#")(0) ' Contains the folder path of the current run
		sCopyPath = Split(strLine,"#")(1) ' Contains the path of the destination folder of the shared drive
		If sFilePath =  sSourceFolderPath Then ' If this condition is true that means the run is of type bulk
			sExecType = "Bulk"
		Else
			'Storing the path of the run
			Set oFileE = fso.OpenTextFile(strFile, 2, True)			
			oFileE.Write sSourceFolderPath&Minute(now)&Second(now)& "#"
			sExecType = ""
			oFileE.Close
		End If		    
	Else
		'Creating the file and storing the path of the run
		Set oFile = fso.CreateTextFile(strFile,True)
		oFile.Write sSourceFolderPath & "#"
		oFile.Close
	End If
	
	'if g_bDebugMode is empty then make it True	
	If g_bDebugMode="" Then 	
		g_bDebugMode=True	
	End If 
	

	'check if g_bDebugMode=False then copy the run results    
	If g_bDebugMode = False Then
		
		' This condition is used to check whether it is a bulk execution or a single script execution, as for a single run "sExecType" is always empty
		If sExecType = "" Then                
			
			'check if root folder is exist otherwise create the root folder    
			If fso.FolderExists(sRootPath) = False Then    
				fso.CreateFolder (sRootPath)    
			End If    
			
			'check & create the hirrarchy of subfoders 
			'check the subfolders exist if not create the subfolders         
			sTempPath = sRootPath & "\" & sApp
			
			If fso.FolderExists(sTempPath) = False Then
				fso.CreateFolder (sTempPath)
			End If
			
			sTempPath = sRootPath & "\" & sApp & "\" & sRunType
			
			If fso.FolderExists(sTempPath) = False Then
				fso.CreateFolder (sTempPath)
			End If
			
			'create the folder of time stamp inside the above path             
			'Get Current date into yyyy-mm-dd format 
			sDate = DatePart("yyyy", Date) & "_" & Right("0" & DatePart("m", Date), 2) & "_" & Right("0" & DatePart("d", Date), 2)        
			'Get Current Time into hh-mm-ss format
			sTime = Right("0" & Hour(Now), 2) & "_" & Right("0" & Minute(Now), 2) & "_" & Right("0" & Second(Now), 2)        
			
			sDateTime = sDate & "_" & sTime        
			g_sDestinationPath = sTempPath & "\" & sScriptName& sDateTime        
			fso.CreateFolder (g_sDestinationPath)                
						
			'add backslash into end of the destination path 
			g_sDestinationPath = g_sDestinationPath & "\"   
			
			'For the first run of the bulk execution the destination shared drive path is stored in the file 
			
			Set oFileE = fso.OpenTextFile(strFile, 8)			
			oFileE.Write sCopyPath & VbCrLf			
			oFileE.Close
			
			
		End If 
		
		'The g_sDestinationPath is assigned to the bulk execution shared drive folder path 
		If sExecType="Bulk" Then			
			g_sDestinationPath  = sCopyPath
		End If
		
		
		Set oFolder = fso.GetFolder(sSourceFolderPath)
		
		'loop through each files in a folder and 
		'copy all the images into destination folder 
		For Each oFile In oFolder.Files 
			If Instr(oFile.Name,".png")>0 then
				sSourcePath=sSourceFolderPath & "\" & oFile.Name            
				fso.CopyFile  sSourcePath,g_sDestinationPath
			End if 
		Next 
		
		
		'copy log.txt file into destination folder            
		
		sSourcePath = sSourceFolderPath & "\Log.txt"
				
		fso.CopyFile sSourcePath,g_sDestinationPath,True            
		'In case of a bulk execution variable "g_sTempResultPath" is assigned to the source path, 
		'to understand to copy the results to same location(Overwrite the next run result during bulk execution) to avoid duplication of log results.
		'g_sTempResultPath = sSourceFolderPath        
		sExecType = ""

		Set objShell = CreateObject("WScript.Shell")
		Set colUsrEnvVars = objShell.Environment("USER")
		colUsrEnvVars("sDestinationPath") = g_sDestinationPath
		colUsrEnvVars("sSourceFolderPath") = sSourceFolderPath
		
		
		
	End If
		Set fso=createobject("Scripting.FileSystemObject")
		
		fso.DeleteFile sSourceFolderPath&"\Log.txt"
		
		Set fso=nothing
		sReferenceLogFilePath = g_sDestinationPath & "Log.txt"
End Sub





'**********************************************************************
'	 Name: utCheckStringSortDescending
'	 Purpose:This function checks the given list of strings are in descending order 
'	 Creator: Amit More
'
'       Param: aArrayOfString| required 
'       AllowedRange:   
'       Description: An Array contains list of strings.
'       
'    Returns: The boolean result of True or False is returned.
'**********************************************************************
Public Function utCheckStringSortDescending(aArrayOfString)   
  
Dim aIndex   
  
utCheckStringSortDescending=True  
  
For aIndex=0 To UBound(aArrayOfString)-1   
  
 If StrComp(lcase(aArrayOfString(aIndex)),lcase(aArrayOfString(aIndex+1)))<0 Then  
   utCheckStringSortDescending=False  
   Exit Function  
 End If  
Next  
  
End Function



'**********************************************************************
'	   Name: utCheckStringSortAscending
'	   Purpose:This function checks the given list of strings are in ascending order  
'	   Creator: Amit More
'
'       Param: aArrayOfString| required 
'       AllowedRange:   
'       Description: An Array contains list of strings.
'       
'       Returns: The boolean result of True or False is returned.
'**********************************************************************

Public Function utCheckStringSortAscending(aArrayOfString)   
  
Dim aIndex   
  
utCheckStringSortAscending=True  
  
For aIndex=0 To UBound(aArrayOfString)-1   
  
 If StrComp(lCase(aArrayOfString(aIndex)),LCase(aArrayOfString(aIndex+1)))>0 Then  
   utCheckStringSortAscending=False  
   Exit Function  
 End If  
Next    
End Function  
  

'**********************************************************************
'   Name: utRandomNumberGenrate
'   Purpose:This function is used generate the Random Number.
'   Creator: Amit More
'       Param: iLowNumber| required
'       AllowedRange: Any interger value which must be less than iHighNumber number.  
'       Description: 
'
'       Param: iHighNumber| required
'       AllowedRange: Any interger value which must be greator than iLowNumber number.  
'       Description: 

'   Returns: This function value will return the random number between lower value(iLowNumber) and Higer Value(iHighNumber).
'**********************************************************************

Public Function utRandomNumberGenrate( ByVal iLowNumber, ByVal iHighNumber)

Dim iRndNumber
 Randomize

	iRndNumber = (Int((iHighNumber-iLowNumber+1)*Rnd+iLowNumber))
	iRndNumber= Cint(iRndNumber)
	utRandomNumberGenrate = iRndNumber

End Function



'**********************************************************************
'   Name: utGetLoginInfo
'   Purpose:This function get Login info like UserId,OP .
'   Creator: Gaurav Gupta
'   Modified: Ananth Baliga\NileshKumar Patil
'       Param: sApplication| required
'       AllowedRange:  
'       Description:The name of the apllication will be passed as an input 
'
'        Param: sUserID| required
'       AllowedRange:   
'       Description: User Id which is being passed 

'        Param: sPasswd| required
'       AllowedRange:   
'       Description:Password which is being passed 
'
'
'       Param: sURL| required
'       AllowedRange:   
'       Description:Application URL which is being test .

'   Returns: N/A
'**********************************************************************

public sub utGetLoginInfo(sApplication,ByRef sUserID,ByRef sPasswd,ByRef sURL)
Dim sTemp,asCredentials,asUserID,asPasswd,iCtr,sIntPsswrd,iPWDctr,iURLctr,asURL,sCase
Dim sKey : sKey = winGetLocalEncKey ("C:\Testware\Common\Configs\MyKey.txt")
    if sApplication="" then
            Err.Number = g_iITEM_NOT_FOUND
            Err.Description = "Unable to find Application - " & sApplication & " - in login.ini file"
            errHandler Err,"utGetLoginInfo",micFail
    Else
    sTemp=utGetData(sApplication)
        If sTemp="False" then
        PrintToLog "The Application Data Not Found in the Login.ini File"
        Else
            asCredentials=split(sTemp,vbcrlf)
            For iCtr = 1 To uBound(asCredentials)
                if asCredentials(iCtr)<> "" then
                sCase=Split(Trim(asCredentials(iCtr)),"=")(0)
                end if
                Select Case trim(Ucase(sCase))
                    Case "USERNAME"
                        asUserID=Split(Trim(asCredentials(iCtr)),"=")
                        sUserID=asUserID(1)
                    Case "PASSWORD"
                        asPasswd=Split(Trim(asCredentials(iCtr)),"=")
                        For iPWDctr = 1 To Ubound(asPasswd)   
                            If iPWDctr=1 Then       
                                sIntPsswrd=asPasswd(iPWDctr)       
                            Else    
                                sIntPsswrd =sIntPsswrd&"="&asPasswd(iPWDctr)              
                            End If                              
                        Next
                        If sIntPsswrd="" Then
                            sPasswd=sIntPsswrd
                            else
                            sPasswd=utDecryptString(sIntPsswrd,sKey)
                        End If
                        
                    Case "URL"
                        asURL=Split(Trim(asCredentials(iCtr)),"=")
                        For iURLctr = 1 To Ubound(asURL)   
                            If iURLctr=1 Then       
                                sURL=asURL(iURLctr)       
                            Else    
                                sURL =sURL&"="&asURL(iURLctr)              
                            End If                              
                        Next
                    Case else
                                            
                End Select
            Next

        End if
    End if
End sub

'**********************************************************************
'	Name: utUniqueNumberGenerate
'	Purpose:Through this function will generate the unique number.
'	Creator: Francis Reddy Mallareddygari
'
'		
'   Returns: Returns the unique number.
'**********************************************************************
Public Function utUniqueNumberGenerate()
	 
	 Dim iUniNum,tCurrent
	 
	 tCurrent = Replace(TIme,":","")
	 
	 iUniNum = Split(tCurrent)
		
	utUniqueNumberGenerate = iUniNum(0)

End Function







'**********************************************************************
'	Name: utListAllNamedRanges
'	Purpose: This Sub Lists all the named ranges available in an excel file from all the sheets
'	Creator: Amit More
'
'		Param: obook|required 
'		AllowedRange: 
'		Description: The workbook object of the Excel for which we need all the Nameed Ranges
' 
'	Returns: All named ranges from the sheets present 
'**********************************************************************

Public Function utListAllNamedRanges(oBook)

	Dim oName 
	Dim intCount, strNR, sWorksheetName
	
	'set oName = oBook.Name
	
	intCount = 2
	'oBook.ActiveSheet
	For Each oName In oBook.Names 
	
		strNR = strNR  &" "& oName.Name &"," + vbCrLf
		intCount = intCount + 1
	
	Next
	
	oBook.Close False
	sWorksheetName = "------------------------- List of All Named Ranges ------------------------- "	
	utListAllNamedRanges = sWorksheetName & vbCrLf & strNR 
	

End Function



'**********************************************************************
'	Name: utFileCompare
'	Purpose: This Sub compares 2 CSV files and returns whether they are different or identical
'	Creator: Amit More
'
'		Param: sFile1|required 
'		AllowedRange: 
'		Description: The first version of the file that needs to be compared
'
'		Param: sFile2|required 
'		AllowedRange: 
'		Description: The second version of the file that needs to be compared
' 
'	Returns: Different or Identical in a text file at C:\Templates\Result.txt
'**********************************************************************
Public Function utFileCompare(sFile1, sFile2)

	Dim wShell, exec, outStr
	Set wShell = CreateObject( "WScript.Shell" )
	
	Set exec = wShell.Exec( "C:\Testware\Common\Bin\windiff.exe " & chr(34) & sFile1 &chr(34)&" "& chr(34) & sFile2 & chr(34)&" -SDX" &" C:\Templates\Result.txt") 

End Function



'**********************************************************************
'	Name: utGetWorksheetFormulaList
'	Purpose: This Sub Lists all the formulas available in an excel file from all the sheets
'	Creator: Amit More
'
'		Param: obook|required 
'		AllowedRange: 
'		Description: The workbook object of the Excel for which we need all the Formulas

'		Param: sIgnoreSheet|required 
'		AllowedRange: 
'		Description: Sheet name which is to be ignored.

' 
'	Returns: All formulas from the sheets present 
'**********************************************************************
Public Function utGetWorksheetFormulaList(oBook,sIgnoreSheet)

	Dim  oWorksheet , sFormula, iCnt , rngCnt, rngSpecialCell, oWorkBook
	sFormula = ""
		
	For iCnt = 1 To oBook.WorkSheets.Count
	
	 Dim asIgnoreSheet,iSheetCtr,bIgnore
			 
			 bIgnore=False
			 
			 asIgnoreSheet=Split(sIgnoreSheet,"|")			 
			 
			 
			 For iSheetCtr = 0 To UBound(asIgnoreSheet)		
				If Trim(oBook.Worksheets(iCnt).Name)=Trim(asIgnoreSheet(iSheetCtr)) Then 
				
				bIgnore=False
				
				Exit For 
				
				End If 		

			Next
	
		
		If bIgnore=False and oBook.Worksheets(iCnt).visible<>2 Then
		
			Set oWorkbook= oBook.Worksheets(oBook.Worksheets(iCnt).Name) 
			oWorkBook.Activate
			Set oWorksheet = oBook.sheets(iCnt)
			sFormula = sFormula & "==================================" & oWorksheet.name &  "==================================" & vbcrlf & vbcrlf
			Set rngSpecialCell = Nothing
			On Error Resume Next
			Set rngSpecialCell = oWorksheet.Cells.SpecialCells(-4123, 23)
			If Not rngSpecialCell Is Nothing Then
				For Each  rngCnt In rngSpecialCell
		      		sFormula = sFormula &  "  " & oWorksheet.Name & "  " & rngCnt.Address(0, 0) & "  " & rngCnt.Formula & "  " &   vbCrLf 
		     	Next 
		  		Set oWorksheetNew = Nothing
			End If
		
		End If
		
		
	Next
	oBook.Close False
	GetWorksheetFormulaList = sFormula
	
	'clear the error
	Err.Clear
		
End Function

'**********************************************************************
'	Name: utEnvGet
'	Purpose:Through this sub will get the application environment from actual url, Which mentioned in ini file.
'	Creator: Francis Reddy Mallareddygari

'        Param: sEnvironment | required
'       AllowedRange:   
'       Description: Environment which is being passed 
'
'
'       Param: sURL| required
'       AllowedRange:   
'       Description:Application URL which is being test.
'
'		
'   Returns: Returns the unique number.
'**********************************************************************


Public Sub utEnvGet(ByRef sEnvironment,sURL)

If instr(sURL,"e2e3") > 0 Then
	
	sEnvironment = "e2e3"
	
 ElseIf instr(sURL,"psi") > 0 Then
 
    sEnvironment = "psi"
    
 ElseIf instr(sURL,"e2e1") > 0 Then
 
    sEnvironment = "e2e1"
    
 ElseIf instr(sURL,"e2e4") > 0 Then
 
    sEnvironment = "e2e4"
    
 ElseIf instr(sURL,"e2e2") > 0 Then
 
    sEnvironment = "e2e2"
    
 End if

End Sub


'**********************************************************************
'   Name: utReleaseInfoGet
'   Purpose:This function returns Release and Buildnumber for provided application .
'   Creator: Gaurav Gupta
'    Modified:Ananth Baliga\NileshKumar Patil

'       Param: sApplication| required
'       AllowedRange:  
'       Description:The name of the apllication will be passed as an input .


'   Returns: Release and Buildnumber for provided application seprated by Pipe "|"
'**********************************************************************
Public function utReleaseInfoGet(sApplication)    
Dim sTemp,asCredentials,asRelease,asBuild,sBuild,sRelease,iCtr,sCase
	if g_bDebugMode="" then
		g_bDebugMode=True
	End if
    if sApplication="" then
            Err.Number = g_iITEM_NOT_FOUND
            Err.Description = "Unable to find Application - " & sApplication & " - in login.ini file"
            errHandler Err,"utReleaseInfoGet",micFail
    Else
    sTemp=utGetData(sApplication)
    If sTemp=False then
        PrintToLog "The Application Data Not Found in the Login.ini File"
        Else
            asCredentials=split(sTemp,vbcrlf)
            For iCtr = 1 To uBound(asCredentials)
            if asCredentials(iCtr)<> "" then
                sCase=Split(Trim(asCredentials(iCtr)),"=")(0) 
                Select Case trim(Ucase(sCase))
                    Case "RELEASE"
                        asRelease=Split(Trim(asCredentials(iCtr)),"=")
                        sRelease=asRelease(1)
                        
                    Case "BUILDNUMBER"
                        asBuild=Split(Trim(asCredentials(iCtr)),"=")
                        sBuild=asBuild(1)
                    Case else
            
                End Select
            end if
            Next
    End If
    If g_bDebugMode=False Then           
        If sRelease="" or  sBuild="" Then            
            Err.Number = g_iITEM_NOT_FOUND
            Err.Description = "Either release-" &sRelease& " or builde number -" & sBuild & "is blank  in login.ini file"
            errHandler Err,"utReleaseInfoGet",micFail           
        End If 
    End If
    utReleaseInfoGet=sRelease &"|"& sBuild
    End If
End Function
'********************************************************************** 
' Name: utInvalidParam *Ready for review
' Purpose:This sub will log data related to invalid argument passed by user that we are not handling in our code[i.e. case else in select condition]
' Creator: Vishwambhar Borde

' 	Param: sInvalidParam | required
' 	AllowedRange: 
' 	Description: Invalid parameter passed to in calling function

' 	Param: sTC | required
' 	AllowedRange: 
' 	Description: Test case number along with function name where it was observed.

' Returns: N/A
'**********************************************************************

public Sub utInvalidParam(sInvalidParam,sTC)
    Err.Number = g_lINVALID_ARG        
    Err.Description = "Wrong Parameter Passed, value as: " & sInvalidParam
    errHandler Err,sTC, micFail
End Sub

'********************************************************************** 
' Name: utListofFilesGet
' Purpose:This function returns the name of all the files present in the specified folder or path
' Creator: Gaurav Gupta

' Param: sPath | Required
' AllowedRange: 
' Description:Path where required files are present

' Returns: N/A
'**********************************************************************

Public Function utListofFilesGet(sPath)

    Dim oFSO,oFolder,oFiles,icount,oFile,sName
        
    Set oFSO = CreateObject("Scripting.FileSystemObject")
    
    Set oFolder = oFSO.GetFolder(sPath) 
    
    icount=0
    
    For each oFile in oFolder.Files  
    
    icount=icount+1
    
    If icount=1 Then    
    
        sName= oFile.name 
    
    Else
    
        sName=sName & "|" & oFile.name
    
    End If
    
Next 

utListofFilesGet=sName

End Function 

'*****************************************************************
'    Name: utValueSet
'    Purpose: utValueSet sub is used to provide string value to emulation using mercury DeviceReplay
'    Creator: Vishwambhar Borde
'
'        Param: sTextValue| required 
'		 AllowedRange:  
'        Description: Text to emulation using mercury DeviceReplay
'
'    Returns: N/A
'**********************************************************************
Public sub utValueSet (sTextValue)

    Dim myDeviceReplay 
    Set myDeviceReplay = CreateObject("Mercury.DeviceReplay")
    myDeviceReplay.SendString sTextValue 
    errhandler Err,"utValueSet",micFail
	
End Sub

 '*****************************************************************
'    Name: utAsciiSend
'    Purpose: utAsciiSend sub is used to Handle keyboard key emulation using mercury DeviceReplay
'    Creator: Vishwambhar Borde
'
'        Param: sSpecialKey| required 
'		 AllowedRange:  
'        Description: Handle keyboard key emulation using mercury DeviceReplay
'
'    Returns: N/A
'**********************************************************************
   
Public sub utAsciiSend (sSpecialKey) 

	'get upper key code
	sSpecialKey=ucase(sSpecialKey)
	Dim myDeviceReplay, iNum
	'initialize to zero
	iNum=0
	Select Case sSpecialKey
		Case "ENTER"
			iNum = 28
		Case "TAB"
			iNum = 15
		Case "DELETE", "DEL"
			iNum = 211 
		Case "BACKSPACE","BS"
			iNum = 14
		Case "ESC"
			iNum = 1
		Case "UP"
			iNum = 200
		Case "DOWN"
			iNum = 208
		Case "LEFT"
			iNum = 205 
		Case "RIGHT"
			iNum = 203
		Case "SPACE"
			iNum = 57
		Case else
			utInvalidParam sSpecialKey & "utilAsciiSend"

	End Select

	Set myDeviceReplay = CreateObject("Mercury.DeviceReplay")
	myDeviceReplay.Keydown iNum
	myDeviceReplay.Keyup iNum
	errhandler Err,"utAsciiSend",micFail

End Sub



 '*****************************************************************
'    Name: utSplAsciiSend
'    Purpose: utSplAsciiSend sub is used to Handle keyboard key emulation using mercury DeviceReplay with ALT, CTRL, SHIFT
'    Creator: Vishwambhar Borde
'
'        Param: sSpecialKey| required 
'		 AllowedRange:  
'        Description: Handle keyboard key emulation using mercury DeviceReplay with ALT, CTRL, SHIFT
'
'    Returns: N/A
'**********************************************************************
Public sub utSplAsciiSend (sSpecialKey)
	Dim sTemp,myDeviceReplay,iCtr
	Dim asTemp:asTemp= split(sSpecialKey,"+")
	Set myDeviceReplay = CreateObject("Mercury.DeviceReplay")
	For iCtr = 0 To ubound(asTemp)
	sTemp=utAsciiGet(asTemp(iCtr))	
		myDeviceReplay.Keydown sTemp
	Next
	For iCtr = ubound(asTemp) To 0 Step -1
		sTemp=utAsciiGet(asTemp(iCtr))	
		myDeviceReplay.Keyup  sTemp
	Next
	
	errhandler Err,"utSplAsciiSend",micFail
End Sub
'*****************************************************************
'    Name: utAsciiGet
'    Purpose: utAsciiGet private function returns ascii/numeric equivalent of CTRL, SHIFT, ALT, Function keys[F1-F12] and alphabets[A-Z]
'    Creator: Vishwambhar Borde
'
'        Param: sSeachVal| required 
'		 AllowedRange:  
'        Description: search value of CTRL, SHIFT, ALT, Function keys[F1-F12] and alphabets[A-Z]
'
'    Returns: ascii/numeric equivalent CTRL, SHIFT, ALT, Function keys[F1-F12] and alphabets[A-Z]
'**********************************************************************
private function utAsciiGet (sSeachVal)
	Dim iReturnNum
	Select Case ucase(sSeachVal)
		Case "SHIFT"
			iReturnNum = 42
		Case "CTRL"
			iReturnNum = 29
		Case "ALT"
			iReturnNum = 56
		case else
			iReturnNum = utAlphaAsciiGet(sSeachVal)
		
	End Select
	utAsciiGet=iReturnNum
	errhandler Err,"utAsciiGet",micFail
End function
'*****************************************************************
'    Name: utAlphaAsciiGet
'    Purpose: utAlphaAsciiGet private function returns ascii/numeric equivalent of Function keys[F1-F12] and alphabets[A-Z]
'    Creator: Vishwambhar Borde
'
'        Param: sExpVal| required 
'		 AllowedRange:  
'        Description: search value of Function keys[F1-F12] and alphabets[A-Z]
'
'    Returns: ascii/numeric equivalent of Function keys[F1-F12] and alphabets[A-Z]
'**********************************************************************
private function utAlphaAsciiGet(sExpVal)
	Dim iCounter,sAlphaList,asTemp
	Dim iReturnVal:iReturnVal=null
	sAlphaList="A-30|B-48|C-46|D-32|E-18|F-33|G-34|H-35|I-23|J-36|K-37|L-38|M-50|N-49|O-24|P-25|Q-16|R-19|S-31|T-20|U-22|V-47|W-17|X-45|Y-21|Z-44|F1-59|F2-60|F3-61|F4-62|F5-63|F6-64|F7-65|F8-66|F9-67|F10-68|F11-87|F12-88"
	asTemp=split(sAlphaList,"|")
	For iCounter = 0 To ubound(asTemp)
		Dim asAlpha
		asAlpha=split(asTemp(iCounter),"-")
		If asAlpha(0)=ucase(sExpVal) Then
			iReturnVal=asAlpha(1)
			Exit for
		End If
	Next
	utAlphaAsciiGet=iReturnVal
	errhandler Err,"utAlphaAsciiGet",micFail
End function 


'**********************************************************************
'    Name: utFCCompare
'    Purpose: This Sub compares all CSV files in a folder using File Compare tool 
'            and results are stored in given location.
'    Creator: Gaurav Gupta
'
'        Param: sBeforeFolder|required 
'        AllowedRange: 
'        Description: Path of the folder where Report/template have been downloaded before deployment 
'
'        Param: sAfterFolder|required 
'        AllowedRange: 
'        Description: Path of the folder where Report/template have been downloaded after deployment
'
'        Param: sResultPath|required 
'        AllowedRange: 
'        Description: Provide the Result Path
'    Returns: N/A.
'**********************************************************************

Public Sub utFCCompare(sBeforeFolder,sAfterFolder,ByRef sResultPath)
	
	Dim wShell, exec, oFSO, oBeforeFolder, oAfterFolder, bFound, sDate, sTime, sDateTime
	Dim sResultFolder, icount, oFileBefore, oFileAfter, sTemplateBeforeFile, sTemplateAfterFile
	Dim asResultFilName, sResultFilName
	
	Set wShell = CreateObject( "WScript.Shell" )
	
	Set oFSO = CreateObject("Scripting.FileSystemObject")
	
	Set oBeforeFolder = oFSO.GetFolder(sBeforeFolder)
	Set oAfterFolder = oFSO.GetFolder(sAfterFolder)
	
	
	bFound=False
	
	
	'create the folder of time stamp inside the above path             
	'Get Current date into yyyy-mm-dd format 
	sDate = DatePart("yyyy", Date) & "_" & Right("0" & DatePart("m", Date), 2) & "_" & Right("0" & DatePart("d", Date), 2)        
	'Get Current Time into hh-mm-ss format
	sTime = Right("0" & Hour(Now), 2) & "_" & Right("0" & Minute(Now), 2) & "_" & Right("0" & Second(Now), 2)        
	
	sDateTime = sDate & "_" & sTime        
	
	
	sResultFolder="C:\Templates\Reports\Results"
	
	sResultFolder=sResultFolder& "\" & sDateTime            
	
	
	sResultPath=sResultFolder
	
	If oFSO.FolderExists(sResultFolder) = False Then
		oFSO.CreateFolder (sResultFolder)
	End If
	
	
'get the File Count
	
	icount=oBeforeFolder.Files.Count
	
	
	For Each oFileBefore in oBeforeFolder.Files
		
		For Each oFileAfter in oAfterFolder.Files
			
			
			sTemplateBeforeFile = oFileBefore.Name
			sTemplateAfterFile = oFileAfter.Name
			
			
			sTemplateBeforeFile=Replace(sTemplateBeforeFile," ","")
			
			asResultFilName=Split(sTemplateBeforeFile,".")
			sResultFilName=Replace(asResultFilName(0)," ","")        
			
			sTemplateAfterFile=Replace(sTemplateAfterFile," ","")
			
			
			If sTemplateBeforeFile=sTemplateAfterFile Then            
				
				Set exec = wShell.Exec( "cmd /c FC /N " & sBeforeFolder&"\"&sTemplateBeforeFile &" " &sAfterFolder&"\"&sTemplateAfterFile &" > "&sResultFolder&"\" &sResultFilName &".txt") 
				
				Set exec=Nothing                 
				
				bFound=True    
				
				Exit For     
				
			End If
			
		Next 
		
		
		If bFound=False Then    
			Err.Number = g_iITEM_NOT_FOUND
			Err.Description = "Sheet not found in Workbook - " & sTemplateBeforeFile
			errHandler Err, "utFCCompare", micWarning    
		End If
		
	Next 
	
	
	'a sync loop is added here.
	Dim dtEndTime,bSynced,oResultFolder,iResFilesCount    
	
	Set oResultFolder=oFSO.GetFolder(sResultFolder)    
	
	dtEndTime = DateAdd("s",100,Now)
	bSynced = False
	
	Do
		
		iResFilesCount=oResultFolder.Files.count
		
		If iResFilesCount=iCount Then
			errHandler Err, "utFCCompare", micFail
	' Set flag to True to exit the loop.
			bSynced = True
			
		End If
		
	Loop While dtEndTime > Now AND bSynced = False
	
	
End Sub

'**********************************************************************
' Name: utObjectPropertySync
' Purpose:This Function will wait until object property synced within specified time limit.
' Creator: Vishwambhar Borde , Ananth Baliga
' 
' Param: objStatementExecute | required
' AllowedRange:  QTP object statement
' Description:  QTP executable statement to be existed
'
' Param: sPropertyToSync | required
' AllowedRange:  Enabled, Visible , Name, Title,etc..
' Description:  The Property of the Object to be synced
'
' Param: sExpPropVal | required
' AllowedRange:  True, False, <Value>
' Description:  The expected Property Value of the Object
'
' Param: iWaitTime | required
' AllowedRange:  
' Description: Wait Time in seconds
'
' Returns: It returns boolean value True if object property synced otherwise returns false.
'**********************************************************************
Public Function utObjectPropertySync(objStatementExecute,sPropertyToSync, sExpPropVal,iWaitTime)
	
	Dim dtEndTime, bSynced,sTempVal, bIsObjectExist
	
	'To Check  the object existance before checking its property
	bIsObjectExist=WinWaitExist(objStatementExecute, iWaitTime)
	
	'exit function if object does not exist
	If Not bIsObjectExist Then
		utObjectPropertySync=false
		Exit function
	End if
	
	'check object property value
	dtEndTime = DateAdd("s",iWaitTime,Now)
	bSynced = False
	Do
		
		sTempVal=objStatementExecute.getROProperty(sPropertyToSync)
		errHandler Err, "utObjectPropertySync", micFail
	
		If sTempVal=sExpPropVal  Then
			' Set flag to True to exit the loop.
			bSynced = True
			Exit Do
		End if
		
	Loop While dtEndTime > Now And bSynced = False
	'return object sync flag value
	utObjectPropertySync=bSynced
	
End Function

'********************************************************************** 
' Name: utCopyPDFData *Ready for review
' Purpose:This Function will Copy data from PDF file to text file
' Creator: Nilesh Patil
' Modified: PavanKumar Madugula| Loveleen Sharma
'
' 	Param: sDestinationFile | required
' 	AllowedRange: 
' 	Description: path for data to be copy
'
' 	Param: sWinBrObj | required
' 	AllowedRange: Window | Browser
' 	Description: Objects type to be enter
'
' Returns: N/A
'**********************************************************************
Public function utCopyPDFData(sDestinationFile,sWinBrObj)       
	
	Dim clip, strText,fso,strfile,astrText,iStrCntr
	
	Set clip = CreateObject("Mercury.Clipboard" )
	clip.Clear
			
	sWinBrObj.highlight
	errHandler Err, "utCopyPDFData", micFail
	sWinBrObj.WinObject("object class:=AVL_AVView", "text:=AVPageView").Type micCtrlDwn + "a" + micCtrlUp
	errHandler Err, "utCopyPDFData", micFail
	sWinBrObj.highlight
	errHandler Err, "utCopyPDFData", micFail
	sWinBrObj.WinObject("object class:=AVL_AVView", "text:=AVPageView").Type micCtrlDwn + "c" + micCtrlUp
	errHandler Err, "utCopyPDFData", micFail
	sWinBrObj.highlight
	errHandler Err, "utCopyPDFData", micFail
	
	strText = clip.GetText
	clip.Clear
	
	Set fso = CreateObject("Scripting.FileSystemObject")
		
	Set strfile = fso.CreateTextFile(sDestinationFile, True)
	
	astrText = split(strText,vbcrlf)
	
	For iStrCntr = 0 To Ubound(astrText)
		
		strfile.WriteLine(astrText(iStrCntr))
		
	Next
	
	sWinBrObj.highlight
	
	errHandler Err, "utCopyPDFData", micFail
	
	strfile.Close 
	
	Set clip = Nothing
	Set fso = Nothing 
	Set strfile = Nothing
	Set sWinBrObj = Nothing
	
End Function

'**********************************************************************
'    Name: utMonthGet
'    Purpose:This sub is to get the month name depending on the month number provided
'    Creator: Mohammed Tauseef
'
'		Param:  iMonth | Required
'       AllowedRange: 1|2|3|4|5|6|7|8|9|10|11|12
'       Description: Month number
'
'		Param:  sform | Required
'       AllowedRange: half|full
'       Description: type of month name to be returned
'
'    Returns: N/A
'**********************************************************************

Public Function utMonthGet(iMonth,sform)

	Dim sMonthName
	
	'If sform is half then it will return the first three letters for the month else will return the full name
	If LCase(sform) = "half" Then
		Select Case CStr(iMonth)
			
			Case "1"
				sMonthName = "Jan"
			Case "2"
				sMonthName = "Feb"
			Case "3"
				sMonthName = "Mar"
			Case "4"
				sMonthName = "Apr"
			Case "5"
				sMonthName = "May"
			Case "6"
				sMonthName = "Jun"
			Case "7"
				sMonthName = "Jul"
			Case "8"
				sMonthName = "Aug"
			Case "9"
				sMonthName = "Sep"
			Case "10"
				sMonthName = "Oct"
			Case "11"
				sMonthName = "Nov"
			Case "12"
				sMonthName = "Dec"
			End Select
		
	Else
		Select Case CStr(iMonth)
			
			Case "1"
				sMonthName = "January"
			Case "2"
				sMonthName = "February"
			Case "3"
				sMonthName = "March"
			Case "4"
				sMonthName = "April"
			Case "5"
				sMonthName = "May"
			Case "6"
				sMonthName = "June"
			Case "7"
				sMonthName = "July"
			Case "8"
				sMonthName = "August"
			Case "9"
				sMonthName = "September"
			Case "10"
				sMonthName = "October"
			Case "11"
				sMonthName = "November"
			Case "12"
				sMonthName = "December"
			End Select
	
	End IF
	
	utMonthGet = sMonthName
End Function


'**********************************************************************
'   Name: utGetData
'   Purpose:This function will return the specific Login Details of any application from the Login.Ini File
'   Creator: NileshKumar Patil\Ananth Baliga\Balamurugan Gangadharan

'       Param: sApplication| required
'       AllowedRange:  Valid Applcation Name as in the login.ini File.
'       Description:The name of the apllication will be passed as an input 
'   Returns: It Retuns the entire Login & Release Details of the Specific Application Passed
'**********************************************************************
Public Function utGetData(sApplication)
    Dim oFso, oTs,sPath,asTemp,iCtr,sLine,sStatus, asAppData
	
	if g_sEnvironmentName <> "" Then
		sPath="C:\Testware\Common\Configs\" & "Login_" &g_sEnvironmentName & ".ini"
	Else
		sPath="C:\Testware\Common\Configs\Login.ini"
	End If 
    
    sLine = ""
    Set oFso = CreateObject("scripting.filesystemobject")
    If oFso.FileExists(sPath) Then
    Set oTs = oFso.OpenTextFile(sPath)
    sLine = oTs.ReadAll
    End If
    asTemp=split(sLine, "#")
    for iCtr=0 to ubound(asTemp)
		If instr(asTemp(iCtr),sApplication) Then
			asAppData = Split (asTemp(iCtr), vbcrlf)
			if trim(lcase(asAppData(0))) = trim(lcase(sApplication)) then
				sStatus=asTemp(iCtr)
						Exit For
				Else 
					sStatus="False"
			end if
		Else 
					sStatus="False"
		End If
    next
    utGetData=sStatus
    oTs.close
    set oTs=nothing
    Set oFso=Nothing	
End Function


'**********************************************************************
'   Name: utReportDownload
'   Purpose:This Function will download the report from the QA environment to 
'               the specified location and returns the file name.
'               Creator: Pavan kumar Madugula
'				Modified: Sukeshini
'
'                               Param: sPath | required
'                  AllowedRange:  QTP object statement
'               Description:  Location or Path where the file needs to be downloaded.
'   
'   Param: sName | Optional
'   AllowedRange:  
'   Description: Name of the file.
'   
'   Param: bDownloadStatus | Optional
'   AllowedRange:  
'   Description: Flag to check whether report is downloaded successfully or not.
'
'               Returns: It returns the downloaded file name along with the path.
'**********************************************************************

Public Function utReportDownload (sPath,sName,ByRef bDownloadStatus)
	
	Dim sIEVersion,dtEndTime,bSynced,sFileName,sRepName,oDevice,asFileName,bComplete,oMain
	Dim oDesc,oChildObj,iBrCount
	
	 Set oDesc=description.Create
	 oDesc("micclass").value = "Browser"
	 Set oChildObj = desktop.ChildObjects(oDesc)
	 iBrCount=oChildObj.count
	 Set oMain=Browser("creationtime:=iBrCount-1")
		
	sIEVersion = oMain.GetROProperty("application version")
	
	Set oDevice = CreateObject("mercury.devicereplay")
	
	Select Case sIEVersion
		
	Case "internet explorer 8","internet explorer 7"
		
' Loop until the 'Download' dialog appears, which takes some time
		dtEndTime = DateAdd("s",600,Now)
		bSynced = False
		Do    
' This button needs to be clicked repeatedly until the dialog persists.
' Sometimes it takes more than one click.
			If Dialog("text:=File Download").Exist(0) Then
				Dim dtEndTime2, bClicked
				dtEndTime2 = DateAdd("s",200,Now)
				bClicked = False
				Do
					If Dialog("text:=File Download").Exist(0) = False Then
						bClicked = True
						Exit Do
					Else
						Dialog("text:=File Download").WinButton("text:=&Save").Click
						
					End If
					
				Loop while Now < dtEndTime2 AND bClicked = False
				bSynced = True
				Exit Do
			ElseIf oMain.WebElement("innertext:=No data is available.", "visible:=True").Exist(0) Then
' If the 'No data is available' web element appears, log this as a warning and exit.
				Err.Number = 5
				Err.Description = "No data available for sector - "
				bSynced = True
				Exit Do
				
			End If    
			
		Loop while Now < dtEndTime AND bSynced = False
		
	Case "internet explorer 11","internet explorer 9"
		
' Loop until the 'Download' dialog appears, which takes some time
		dtEndTime = DateAdd("s",200,Now)
		bSynced = False
	' oMain.highlight
		Do    
'			bSynced = winWaitExist (oMain.WinObject("text:=Do you want.*","index:=0"),200)
			
			If oMain.WinObject("text:=Do you want.*","index:=0").Exist(1) Then
				bSynced = True
				Exit Do
			ElseIf Dialog("regexpwndtitle:=Internet Explorer","index:=0").WinButton("regexpwndtitle:=Save &as","regexpwndclass:=Button").Exist(1) Then
				bSynced = True
				Exit Do
			ElseIf Dialog("regexpwndtitle:=Internet Explorer","index:=0").WinObject("nativeclass:=window","index:=0").WinButton("object class:=split button").Exist(1) Then
				bSynced = True
				Exit Do
			End If
		Loop while Now < dtEndTime AND bSynced = False
		
		'oMain.highlight
		If oMain.WinObject("text:=Do you want.*","index:=0").WinButton("nativeclass:=drop down button","index:=0").Exist(1) Then
			Set oMainWinbutton = oMain.WinObject("text:=Do you want.*","index:=0").WinButton("nativeclass:=drop down button","index:=0")
					oMainWinbutton.highlight
					errHandler Err, "utReportDownload", micFail
					
					oMainWinbutton.Click
					errHandler Err, "utReportDownload", micFail

					oDevice.PressKey 208
					oDevice.PressKey 28
		ElseIf Dialog("regexpwndtitle:=Internet Explorer","index:=0").WinButton("regexpwndtitle:=Save &as","regexpwndclass:=Button").Exist(1) Then
			Set oMainWinbutton = Dialog("regexpwndtitle:=Internet Explorer","index:=0").WinButton("regexpwndtitle:=Save &as","regexpwndclass:=Button")
					oMainWinbutton.highlight
					errHandler Err, "utReportDownload", micFail
					
					oMainWinbutton.Click
					errHandler Err, "utReportDownload", micFail
		ElseIf Dialog("regexpwndtitle:=Internet Explorer","index:=0").WinObject("nativeclass:=window","index:=0").WinButton("object class:=split button").Exist(1) Then
			Set oMainWinbutton = Dialog("regexpwndtitle:=Internet Explorer","index:=0").WinObject("nativeclass:=window","index:=0").WinButton("nativeclass:=drop down button","index:=0")
					oMainWinbutton.highlight
					errHandler Err, "utReportDownload", micFail
					
					oMainWinbutton.Click
					errHandler Err, "utReportDownload", micFail

					oDevice.PressKey 208
					oDevice.PressKey 28
		End If
		

		
	Case Else
		
' Loop until the 'Download' dialog appears, which takes some time
		dtEndTime = DateAdd("s",200,Now)
		bSynced = False
		Do    
			bSynced = winWaitExist (oMain.WinObject("text:=Do you want to.*"),100)
			
			If bSynced Then
				Exit Do
			End If
		Loop while Now < dtEndTime AND bSynced = False
		
		oMain.WinObject("text:=Do you want to.*").WinButton("nativeclass:=drop down button","index:=0").highlight
		errHandler Err, "utReportDownload", micFail
		
		oMain.WinObject("text:=Do you want to.*").WinButton("nativeclass:=drop down button","index:=0").click
		errHandler Err, "utReportDownload", micFail
		
		oDevice.PressKey 208
		oDevice.PressKey 28
		
	End Select
	
' Loop and sync on the file browser dialog
	dtEndTime = DateAdd("s",30,Now)
	bSynced = False
	bComplete = False
	Do
		
		If Dialog("regexpwndtitle:=Save As","nativeclass:=#32770").Exist(3) Then
			
'Get the file name from the save as window which is highlited
			sFileName = Dialog("regexpwndtitle:=Save As","nativeclass:=#32770").WinEdit("nativeclass:=Edit","window id:=1001").GetROProperty("text")
			PrintToLog "File Name::"&sFileName
			
'If file extension is enabled we need to split the extension to get only the file name without extension                  
			If Instr(sFileName,".xl") > 0 Then
				asFileName = split(sFileName,".xl")
				sFileName = asFileName(0)
			End If
			
' Put the path and name in the file name field and click save.
			If sName <> "" Then
				sRepName = sPath&"\"&sFileName&"_"&sName
			Else
				sRepName = sPath&"\"&sFileName
			End If
			
			Dialog("regexpwndtitle:=Save As","nativeclass:=#32770").WinEdit("nativeclass:=Edit","window id:=1001").Type sRepName
			
			Dialog("regexpwndtitle:=Save As","nativeclass:=#32770").WinButton("text:=&Save").Click
			
			If Dialog("nativeclass:=#32770","regexpwndtitle:=Confirm Save As").WinButton("regexpwndtitle:=&Yes").Exist(0) Then
				
				Dialog("nativeclass:=#32770","regexpwndtitle:=Confirm Save As").WinButton("regexpwndtitle:=&Yes").click
				
			End If
			
'To wait untill the download is complete
			Select Case sIEVersion
				
			Case "internet explorer 8"
				
'To Close the Download Complete  dialog box which appears after few seconds    
				Dim dtEndTime3   
				
				dtEndTime3 = DateAdd("s",300,Now)                                                    
				
				Do
					If Dialog("regexpwndtitle:= Download complete").Exist(0) Then
						Dialog("regexpwndtitle:= Download complete").WinButton("regexpwndtitle:= Close").Click
						errHandler Err, "utReportDownload",micFail
						bComplete = True
						Exit Do
					End If
					
				Loop While Now < dtEndTime3 AND bComplete = False
				
			Case "internet explorer 11","internet explorer 9"    
			
				dtEndTime3 = DateAdd("s",600,Now) 
					Do
					If oMain.WinObject("nativeclass:=window","index:=0").Static("nativeclass:=text","object class:=text","index:=0").Exist(1) Then
						If Instr(oMain.WinObject("nativeclass:=window","index:=0").Static("nativeclass:=text","object class:=text","index:=0").GetROProperty("text"),"download has completed") > 0 Then
							oMain.WinObject("nativeclass:=window","index:=0").WinButton("acc_name:=Close").Click
							errHandler Err, "utReportDownload",micFail
							bComplete = True
							Exit Do
						End If
					ElseIF Dialog("regexpwndtitle:=Internet Explorer","index:=0").WinObject("nativeclass:=window","index:=0").WinButton("object class:=split button","acc_name:=Open").Exist(1) Then
						Dialog("regexpwndtitle:=Internet Explorer","index:=0").WinObject("nativeclass:=window","index:=0").WinButton("acc_name:=Clear list").Click
						Dialog("regexpwndtitle:=Internet Explorer","index:=0").WinObject("nativeclass:=window","index:=0").WinButton("acc_name:=Close").Click
						errHandler Err, "utReportDownload",micFail
							bComplete = True
							Exit Do
					'Else
					'	bComplete = True
					End If
					Loop While Now < dtEndTime3 AND bComplete = False
					
								
			End Select
			
			bSynced = True
			Exit Do
		End If    
		
	Loop while Now < dtEndTime AND bSynced = False
	
	Dim FSO,bReportDownloaded
	Set FSO = CreateObject("Scripting.FileSystemObject") 
	bReportDownloaded = FSO.FileExists(sRepName) 
	Set FSO = Nothing
	If bReportDownloaded = True Then
		bComplete = True
	Else
		bComplete = False
	End If
	
	Set oDevice = Nothing

	Set oMain = Nothing
	
	
	Set oDevice = Nothing

	Set oMain = Nothing
	
'To Ensure download is completed
	
	bDownloadStatus = bComplete
	
	utReportDownload = sRepName
	
End Function




'**********************************************************************
'Name: utReportOpen
'Purpose:This Function will open the report from the QA environment 
'Creator: Pavan kumar Madugula
'
'Returns: N/A
'**********************************************************************

Public Sub utReportOpen()
	
	Dim sIEVersion,dtEndTime,bSynced,sFileName,sRepName,oDevice,asFileName,bComplete,oMain
	
	Set oMain = Browser("name:=Moody's Financial Metrics")

	sIEVersion = oMain.GetROProperty("application version")

	Select Case sIEVersion
		
	Case "internet explorer 8"
		
' Loop until the 'Download' dialog appears, which takes some time
		dtEndTime = DateAdd("s",600,Now)
		bSynced = False
		Do    
' This button needs to be clicked repeatedly until the dialog persists.
' Sometimes it takes more than one click.
			If Dialog("text:=File Download").Exist(0) Then
				Dim dtEndTime2, bClicked
				dtEndTime2 = DateAdd("s",600,Now)
				bClicked = False
				Do
					If Dialog("text:=File Download").Exist(0) = False Then
						bClicked = True
						Exit Do
					Else
						Dialog("text:=File Download").WinButton("text:=&Open").Click
						
					End If
					
				Loop while Now < dtEndTime2 AND bClicked = False
				bSynced = True
				Exit Do
			ElseIf oMain.WebElement("innertext:=No data is available.", "visible:=True").Exist(0) Then
' If the 'No data is available' web element appears, log this as a warning and exit.
				Err.Number = 5
				Err.Description = "No data available for sector - "
				bSynced = True
				Exit Do
				
			End If    
			
		Loop while Now < dtEndTime AND bSynced = False
	

	Case "internet explorer 11"
		' Loop until the 'Download' dialog appears, which takes some time
		
		dtEndTime = DateAdd("s",200,Now)
		bSynced = False
		If oMain.WinObject("text:=Do you want to open or save.*","index:=0").Exist(60) Then
			Set oMainWinObjSave = oMain.WinObject("text:=Do you want to open or save.*","index:=0")
		Else
			Set oMainWinObjSave = oMain.WinObject("text:=Do you want to open or save.*","index:=1")
		End If
'		Do    
'			bSynced = winWaitExist (oMain.WinObject("text:=Do you want to open or save.*","index:=1"),100)
'			
'			If bSynced Then
'				Exit Do
'			End If
'		Loop while Now < dtEndTime AND bSynced = False
		
		oMain.WinObject("nativeclass:=window","text:=Do you want to open or save.*").WinButton("nativeclass:=push button","acc_name:=Open").highlight
		'oMain.WinButton("nativeclass:=push button","acc_name:=Open").highlight
		errHandler Err, "utReportOpen", micFail
		
		'oMain.WinButton("nativeclass:=push button","acc_name:=Open").Click
		oMain.WinObject("nativeclass:=window","text:=Do you want to open or save.*").WinButton("nativeclass:=push button","acc_name:=Open").Click
		errHandler Err, "utReportOpen", micFail
		
	Case Else
		
'		Set oDevice = CreateObject("mercury.devicereplay")
		
' Loop until the 'Download' dialog appears, which takes some time
		
		dtEndTime = DateAdd("s",200,Now)
		bSynced = False
		Do    
			bSynced = winWaitExist (oMain.WinObject("text:=Do you want to open or save.*"),100)
			
			If bSynced Then
				Exit Do
			End If
		Loop while Now < dtEndTime AND bSynced = False
		
		oMain.WinObject("text:=Do you want to open or save.*").WinButton("nativeclass:=push button","acc_name:=Open").highlight
		errHandler Err, "utReportOpen", micFail
		
		oMain.WinObject("text:=Do you want to open or save.*").WinButton("nativeclass:=push button","acc_name:=Open").Click
		errHandler Err, "utReportOpen", micFail
		
	End Select

	Set oMain = Nothing
	
End Sub




'**********************************************************************
'    Name: utCommandlineDBQuery
'    Purpose: This Sub will fire/execute the query to Sybase database using iSQL command line utility
'    Creator: Vishwambhar Borde
'
'        Param: sUserName|required 
'        AllowedRange: 
'        Description: Sybase connectivity Username
'
'        Param: sPwd|required 
'        AllowedRange: 
'        Description: Sybase connectivity Password
'
'        Param: sServername|required 
'        AllowedRange: 
'        Description: Sybase connectivity DB Servername, like QA_Bill5, DEV_Bill5 in case of phoenix
'
'        Param: sDBName|required 
'        AllowedRange: 
'        Description: Sybase connectivity DB Schema name, like newbill, newbillb, newbillc in case of Phoenix application
'
'
'        Param: sQueryFilePath|required 
'        AllowedRange: 
'        Description: Text file path which contains SQL query, it is picked and executed at command prompt
'
'
'        Param: sOutputFilePath|optional 
'        AllowedRange: 
'        Description: Text file path where we need to save the output of query
'
'
'    Returns: N/A.
'**********************************************************************

public sub utCommandlineDBQuery(sUserName,sPwd,sServername,sDBName,sQueryFilePath,sOutputFilePath)
	Dim wShell, exec
	
	Set wShell = CreateObject( "WScript.Shell" )
	If sOutputFilePath="" or isnull(sOutputFilePath) Then
		Set exec = wShell.Exec( "cmd /c isql -S" & sServername & " -U" & sUserName & " -P" & sPwd & " -D " & sDBName & " -i" & sQueryFilePath)	
	else
		Set exec = wShell.Exec( "cmd /c isql -S" & sServername & " -U" & sUserName & " -P" & sPwd & " -D " & sDBName & " -i" & sQueryFilePath & " > " & sOutputFilePath)	
	End If
	
				
	Set exec=Nothing   
	errHandler Err, "utCommandlineDBQuery", micFail
End sub	


'**********************************************************************
'    Name: utTxtFileCreate
'    Purpose: This sub is used to create a plain text file at specified path with specified data 
'    Creator: Vishwambhar Borde
'
'        Param: sFilePath|required 
'        AllowedRange: 
'        Description: full path of text file where we need to create it, assumption is parent folder exist
'
'        Param: sFileData|required 
'        AllowedRange: 
'        Description: It is string that we need to add to text file
'
'
'    Returns: N/A.
'**********************************************************************
Public Sub utTxtFileCreate(sFilePath,sFileData)
	Dim oFso,oFile1
		
	Set oFso=createobject("Scripting.FileSystemObject")
	
	Set oFile1=oFso.CreateTextFile(sFilePath,True,False) 
	
	oFile1.Write sFileData
	
	oFile1.Close
	
	Set oFile1=nothing 
	Set oFso=nothing
	errHandler Err, "utTxtFileCreate", micFail
End Sub			

'**********************************************************************
'	Name: utBrowserNavigate
'	Purpose: This sub will navigate browser page to back, forward or to home page
'	Creator: Vishwambhar Borde
'
'
'        Param: oBrowser|required 
'        AllowedRange: 
'        Description: Browser object 
'
'        Param: sOption|required 
'        AllowedRange: Back|Forward|Home
'        Description: Navigate browser to option , values allowed are back, forward or home.
'
'	Returns: N/A
'**********************************************************************

public sub utBrowserNavigate(oBrowser, sOption)
	oBrowser.WinToolbar("regexpwndclass:=ToolbarWindow.*","index:=0").Press 1
	
	Select Case lcase(sOption)
		
		Case "back"
			oBrowser.WinMenu("menuobjtype:=3").Select "Go To;Back	Alt+Left Arrow"
		Case "forward"
			oBrowser.WinMenu("menuobjtype:=3").Select "Go To;Forward	Alt+Right Arrow"
		Case "home"
			oBrowser.WinMenu("menuobjtype:=3").Select "Go To;Home Page	Alt+Home"
		Case else 
		
		utInvalidParam sOption,"utBrowserNavigate"
		
	End Select
	errHandler Err, "utBrowserNavigate", micFail
	
End sub

'**********************************************************************
'   Name: utMouseClick
'   Purpose: This sub will simulate a mouse click on areas where click method doesn't work or QTP doesn't identify the object exactly
'   Creator: Loveleen Sharma
'
'   Param: oObject|Required 
'   AllowedRange: Valid object hierarchy
'   Description: Object on which click operation to be performed

'   Param: iAddX|Required 
'   AllowedRange: Valid integer
'   Description: X coordinates of the object to be adjusted

'   Param: iAddY|Required 
'   AllowedRange: Valid object hierarchy
'   Description: Y Coordinates of the object to be adjusted

'   Param: sOperation|Required 
'   AllowedRange: Add|Sub
'   Description: Coordinates to be added of substracted

'  Returns: N/A
'**********************************************************************  
Public Sub utMouseClick(oObject, iAddX, iAddY, sOperation)
	Dim iGetX, iGetY, oDeviceReplay, LEFT_MOUSE_BUTTON
	Set oDeviceReplay = CreateObject("Mercury.DeviceReplay")
	iGetX = oObject.GetRoProperty("abs_x")
	iGetY = oObject.GetRoProperty("abs_y")
	If UCase(sOperation) = "ADD" Then
		oDeviceReplay.MouseClick iGetX + iAddX, iGetY + iAddY, LEFT_MOUSE_BUTTON
		ElseIf UCase(sOperation) = "SUB" Then
		oDeviceReplay.MouseClick iGetX - iAddX, iGetY - iAddY, LEFT_MOUSE_BUTTON
		Else
		Err.Number = g_lINVALID_ARG
        Err.Description = "Invalid Parameter Provided- " & sOperation
        errHandler Err,"utMouseClick", micWarning
	End If
	errHandler Err,"utMouseClick", micFail
	
	Set oDeviceReplay = Nothing
End Sub


'****************************************************************
'	Name: utgetRandomString
'	Purpose: Getting a random alphabet string of a specified length
'	Creator: Nilesh Patil
'
'	Param: iLen | required
'	AllowedRange:  
'	Description: The length of the random string required
'
'	Returns:A random string of the specified length
'**********************************************************************' 	
Public Function utgetRandomString(iLen)
 
 Dim returnVal, i
 
 If Not IsNumeric(iLen) Or IsEmpty(iLen) Or iLen = "" Then
  utgetRandomString = ""
  Exit Function
 End If

 returnVal = ""
 For i = 1 To iLen
  returnVal = returnVal & Chr(Int(24*Rnd+97))
 Next
 utgetRandomString = returnVal
 

End Function

'********************************************************************************************************************************************************
'	Name:General_CloseProcess                                                                                                            
'	Purpose:This sub will Close all excel instances.
'	Creator:Piyush Bagdiya

'  	 	Param: strProgramName | required 
'    	AllowedRange:
'   	Description: Program

'	Returns: N/A
'*******************************************************************************************************************************


Public Function General_CloseProcess(strProgramName)
   Dim objshell
   Set objshell=CreateObject("WScript.Shell")
   objshell.Run "TASKKILL /F /IM "& strProgramName
   Set objshell=nothing
End Function

''*************************************************************************
'    Name: appSync
'    Purpose: Synchronisation between two subs
'    Creator:Sonal Agrawal

'      Param: iSec | required
'    AllowedRange:
'    Description: Number of seconds to wait
'
'    Returns: N/A
'***************************************************************************
Public Sub appSync(iSec)
    Dim DateEndTime,iCount
    
    DateEndTime = DateAdd("s",iSec, Now())
    
    Do
    iCount = 1    
    Loop While DateEndTime > Now
        
		
	
End Sub 


''*************************************************************************
'    Name: utLoadTestScript
'    Purpose: This sub loads the vbs script files in the given path to the qtp test
'    Creator:Balamurugan Gangadharan

'    Param: sScriptFolderPath | required
'    AllowedRange:
'    Description: Script folder path
'
'    Returns: N/A
'***************************************************************************
Public Sub utLoadTestScript(ByVal sScriptFolderPath )
	
	Dim sFilesGet, asFiles, asScrFilePaths(), sScriptPath, sScriptPathCol
	ReDim asScrFilePaths(-1)
	Err.Clear
	Set fso = CreateObject("scripting.filesystemobject")
   		errHandler Err,"utLoadTestScript",micFail
	
   	If fso.FolderExists(sScriptFolderPath) Then
	
		' Get all the file names in the given folder
		sFilesGet = utListofFilesGet(sScriptFolderPath)
		errHandler Err,"utLoadTestScript",micFail
		
		'Splitting into individual file names
		asFiles = Split(sFilesGet,"|")
		errHandler Err,"utLoadTestScript",micFail
	
		'Creating object of qtp library
		Set oQtpApp = createobject("QuickTest.Application")
		errHandler Err,"utLoadTestScript",micFail
	
		Set oQtpLib = oQtpApp.Test.Settings.Resources.Libraries
		errHandler Err,"utLoadTestScript",micFail
	
		'Selecting only vbs files non-existing in the qtp library
		For iFile = 0 To Ubound(asFiles) Step 1
			If Lcase(Trim((Split(asFiles(iFile),".",2)(1)))) = "vbs" then
		
				sScriptPath = sScriptFolderPath &"\" &Trim(asFiles(iFile))
				If oQtpLib.Find(sScriptPath) >= -1 Then
			
					ReDim Preserve asScrFilePaths(Ubound(asScrFilePaths)+1)
					asScrFilePaths(Ubound(asScrFilePaths)) = sScriptPath
			
				End If
				
			End If 
		Next
		
		Set oQtpLib = Nothing
		Set oQtpApp = Nothing
		
		'Loading all selected library to the qtp test
		If Ubound(asScrFilePaths) >= -1 Then
			For iScrPath = 0 To Ubound(asScrFilePaths) Step 1
				LoadFunctionLibrary asScrFilePaths(iScrPath)
				errHandler Err,"utLoadTestScript",micFail
			Next
		Else
			Err.Number = g_iITEM_NOT_FOUND
			Err.Description = "There is no valid vbs file exist in the given folder path to load."
			errHandler Err, "utLoadTestScript", micFail
		End If
	Else
		Err.Number = g_iINVALID_INPUT
		Err.Description = "The given folder path doesn't exist."
		errHandler Err, "utLoadTestScript", micFail
	End If	
	Set fso = Nothing

End Sub


'**********************************************************************
'	Name: utWebTableHandler
'	Purpose: This Sub will perform operations on the WebTable
'	Creator: Rajesh Ghosh

'		Param:  oPage | required
'		AllowedRange: 
'		Description: Browser and Page Object 

'		Param:  sTableProp | required
'		AllowedRange: 
'		Description: Whole Property of the Webtable 

'		Param:  sLabelName | required
'		AllowedRange: 
'		Description: Lable name whose ChildItem is to be found

'		Param:  sSearchType | required
'		AllowedRange: 
'		Description: The Class Name of the ChildObject

'		Param:  sAction | required
'		AllowedRange: 
'		Description: Action to be performed

'		Param:  sSetText | required
'		AllowedRange: 
'		Description: Text to be set in WebEdit

'		Param:  sGetText | required
'		AllowedRange: 
'		Description: file Name

'	Returns: NA
'**********************************************************************
Public Sub utWebTableHandler(oPage,sTableProp,sLabelName,sSearchType,sAction,sSetText,ByRef sGetText)	


Select Case sSearchType

			Case "Link"	 ' This is Selected when the Child Type In Link
					Select Case sAction
						Case "Click"
							sGetText = oPage.WebTable(sTableProp).WebElement("innertext:="&sLabelName,"index:=0").Object.nextSibling.innertext
							
							oPage.WebTable(sTableProp).Link("innertext:="&sGetText).Click
								errHandler Err, "utWebTableHandler", micFail
								oPage.Sync
								
						Case "onmouseover"
							oPage.WebTable(sTableProp).WebElement("innertext:="&sLabelName,"index:=0").Object.nextSibling.FireEvent "onmouseover"					
								errHandler Err, "utWebTableHandler", micFail
								oPage.Sync	
							
						Case "GetData"
							sGetText = oPage.WebTable(sTableProp).WebElement("innertext:="&sLabelName,"index:=0").Object.nextSibling.innertext
							
							
						Case else
							Err.Number=1   
							Err.Description ="Check the arguments once"
							errHandler Err, "utWebTableHandler", micFail
							
					End Select
					
			Case "WebElement"	' This is Selected when the Child Type In WebElement
					Select Case sAction
					
						Case "Click"
							sGetText = oPage.WebTable(sTableProp).WebElement("innertext:="&sLabelName,"index:=0").Object.nextSibling.innertext							
							oPage.WebTable(sTableProp).WebElement("innertext:="&sGetText).Click
								errHandler Err, "utWebTableHandler", micFail
								oPage.Sync
								
						Case "onmouseover"
							oPage.WebTable(sTableProp).WebElement("innertext:="&sLabelName,"index:=0").Object.nextSibling.FireEvent "onmouseover"					
								errHandler Err, "utWebTableHandler", micFail
								oPage.Sync
								
						Case "DoubleClick"
							oPage.WebTable(sTableProp).WebElement("innertext:="&sLabelName,"index:=0").Object.nextSibling.FireEvent "onDblClick"
							errHandler Err, "utWebTableHandler", micFail
								oPage.Sync
					
						Case "GetData"
							sGetText = oPage.WebTable(sTableProp).WebElement("innertext:="&sLabelName,"index:=0").Object.nextSibling.innertext
							
							
						Case else
							Err.Number=1   
							Err.Description ="Check the arguments once"
							errHandler Err, "utWebTableHandler", micFail							
					End Select
					
					
			Case "WebEdit"	 ' This is Selected when the Child Type In WebEdit
					Select Case sAction
						Case "Click"
							sGetText = oPage.WebTable(sTableProp).WebElement("innertext:="&sLabelName,"index:=0").Object.nextSibling.innertext							
							oPage.WebTable(sTableProp).WebEdit("innertext:="&sGetText).Click
								errHandler Err, "utWebTableHandler", micFail
								oPage.Sync

						Case "Set"
								Set oWedit = oPage.WebTable(sTableProp).WebElement("innertext:="&sLabelName,"index:=0").Object.nextSibling
									oWedit.innertext = sSetText		
								sGetText = oPage.WebTable(sTableProp).WebElement("innertext:="&sLabelName,"index:=0").Object.nextSibling.innertext									
						Case "GetData"
							sGetText = oPage.WebTable(sTableProp).WebElement("innertext:="&sLabelName,"index:=0").Object.nextSibling.innertext							
						
						Case else
							Err.Number=1   
							Err.Description ="Check the arguments once"
							errHandler Err, "utWebTableHandler", micFail
							
					End Select
					

End Select

Set oPage = nothing
End Sub

'****************************************************************
'	Name: utWebtablePerformAction
'	Purpose: This sub will perform an action with help of fields label in a webtable .
'	Creator:Chinmay Mudholkar
'
'		Param: oPage| required 
'		AllowedRange: 
'		Description: Name/Title of the Browser and Page
'
'		Param: sSection| required 
'		AllowedRange: 
'		Description: Name of the Webtable
' 
'		Param: sFieldLabel| required 
'		AllowedRange: 
'		Description:  Lable of the field
'
'		Param: iColNo| required 
'		AllowedRange: 
'		Description: Column number
'
'		Param: sAction| required 
'		AllowedRange: SET | SELECT | CLICKBUTTON | CLICKLINK | CHECK | UNCHECK
'		Description: Action
'
'		Param: sValue
'		AllowedRange: In case of checkbox value can be ON/OFF
'		Description: Value
'
'	Returns: N/A 
'**********************************************************************'
Public Sub utWebtablePerformAction(oPage, sSection, sFieldLabel, iColNo, sAction, sValue)
Dim sAllItems
Dim iFieldRowNumber
Dim iColumnCount
Set oSectionTable = oPage.WebTable("innertext:=.*" & sSection & ".*")
iSearchCounter = 0

iFieldRowNumber = oSectionTable.GetRowWithCellText(sFieldLabel,,iSearchCounter)
For iColumnCount = 1 To oSectionTable.ColumnCount(1) Step 1
    If InStr(oSectionTable.GetCellData(iFieldRowNumber, iColumnCount), sFieldLabel) Then
        Select Case Trim(UCase(sAction))
            Case "WEBEDIT"
                Set oTempObject = oSectionTable.ChildItem(iFieldRowNumber, iColumnCount+iColNo,"WebEdit",0)
                If Not IsEmpty(oTempObject) Then
                        oTempObject.Set sValue
                        Exit For
                    Else
                        PrintToLog "Webedit is disabled"
                End If                    
                
            Case "WEBLIST"
                Set oTempObject = oSectionTable.ChildItem(iFieldRowNumber, iColumnCount+iColNo,"WebList",0)
                If Not IsEmpty(oTempObject) Then
                        sAllItems = oTempObject.GetROProperty("all items")
                        If InStr(sAllItems, ";"& sValue & ";") Then
                            oTempObject.Select sValue
                            Exit For
                        Else
                            PrintToLog sValue & "does not exist in the weblist" 
                        End If
                    Else
                        PrintToLog "Webedit is disabled"
                End If
                    
            Case "WEBBUTTON"
                Set oTempObject = oSectionTable.ChildItem(iFieldRowNumber, iColumnCount+iColNo,"WebButton",0)
                If Not IsEmpty(oTempObject) Then
                        oTempObject.Click
                        Exit For
                    Else
                        PrintToLog "Button is disabled"
                End If                    
                
            Case "LINK"
                Set oTempObject = oSectionTable.ChildItem(iFieldRowNumber, iColumnCount+iColNo,"Link",0)
                If Not IsEmpty(oTempObject) Then
                        oTempObject.Click
                        Exit For
                    Else
                        PrintToLog "Link is disabled"
                End If                    
                
            Case "WEBCHECKBOX"
                Set oTempObject = oSectionTable.ChildItem(iFieldRowNumber, iColumnCount+iColNo,"WebCheckBox",0)
                If Not IsEmpty(oTempObject) Then
                        oTempObject.Set sValue
                        Exit For
                    Else
                        PrintToLog "CheckBox is disabled"
                End If 
		                                       
        End Select
    
    End If
    errHandler Err,"utWebtablePerformAction", micfail 
Next

End Sub

'**********************************************************************
'	  Name: utEnviCertTestingDriver
'	  Purpose:This Sub execute scenario which is Y in application sheet of EnvCertTesting.xlsx
'	  Creator: Shantinath Patil
'
'       Param: g_MainSheetPath| required 
'       AllowedRange:"C:\Testware\Common\EnvCertTesting\EnvCertTesting.xlsx"
'       Description: EnvCertTesting.xlsx path
'
'       Param: sAppShortName| required                                        
'       AllowedRange:  
'       Description: Short Name of application and there is folder in "C:\Testware\Apps" with this name

'		Param: g_sRootLocalPathApp| required                                        
'       AllowedRange: 
'       Description: Path of Root Folder where results need to be copied.
'              
'       Returns: N/A
'**********************************************************************
Public Sub utEnviCertTestingDriver(g_MainSheetPath,sAppShortName,g_sRootLocalPathApp)
	utCloseBrowser
	g_sAppName=sAppShortName
	g_sRunType = "EnvironmentCertification" 
	g_bCapturePassBitmaps = False 
	g_bDebugMode = False
	
	Set g_oScenarioRecordSet=xclGetSheetRecords("","ExeFlagScenario","Y",sAppShortName,g_MainSheetPath)
	iScenarioCnt=g_oScenarioRecordSet.recordCount
	For j=1 to iScenarioCnt
		sExeFlagScenario=g_oScenarioRecordSet.Fields("ExeFlagScenario").Value
		sScriptName=g_oScenarioRecordSet.Fields("ScriptName").Value
		sScriptPath=g_oScenarioRecordSet.Fields("ScriptPath").Value
		'utLoadTestScript sScriptFldPath
		sScriptFldPathVBS = sScriptPath & "\" & sScriptName & ".vbs"
		LoadFunctionLibrary sScriptFldPathVBS
		Execute sScriptName
		g_oScenarioRecordSet.MoveNext
	Next
	PrintToLog "========================================================="  
	If iScenarioCnt < 1 then
		PrintToLog "For application : " & sAppShortName & " - ExeFlagApp is set to 'Y' but ExeFlagScenario flag for all scenario set to 'N' "
	End If
	utCopyRunResultsLocal g_sAppName,  g_sRunType,  g_sRootLocalPathApp
	Dim fso, folder, f, sSourceFolderPath
	sSourceFolderPath = Environment("ResultDir")
	Set fso = CreateObject("Scripting.FileSystemObject")    
	Set folder = fso.GetFolder(sSourceFolderPath)
	For each f in folder.Files
		f.Delete True		
	Next
	Set fso = Nothing
End Sub

'**********************************************************************
'	  Name: utCopyRunResultsLocal
'	  Purpose:This Sub Copy the run results of current test under desired Location.    
'		    Folder hierarchy will be C:\AutomationTestResult
'			Result will be copied if flag g_bDebugMode=False.
'	  Creator: Shantinath Patil
'
'       Param: sApp| required 
'       AllowedRange:   
'       Description: The name of the apllication will be passed as an input
'
'       Param: sRunType| required                                        
'       AllowedRange:  "EnvironmentCertification"
'       Description: The type of run for which the details need to be logged

'		Param: sRootLocalPath| required                                        
'       AllowedRange: 
'       Description: Path of Root Folder where results need to be copied.
'              
'       Returns: N/A
'**********************************************************************
Public Sub utCopyRunResultsLocal(sApp,sRunType,sRootLocalPath)
	
	Dim fso, sSourcePath,sSourceFolderPath,sTempPath,sDate,sTime,sDateTime
	Dim oFile,oFolder, strFile, strLine, oFileE, sExecType, sFilePath, sCopyPath
	Dim sEmailSubject,sEmailBody,sEmailAttachmentPath
	'Get the path of current test result into a string
	sSourceFolderPath = Environment("ResultDir")
	Set fso = CreateObject("Scripting.FileSystemObject")    
	'if g_bDebugMode is empty then make it True	
	If g_bDebugMode="" Then 	
		g_bDebugMode=True	
	End If 
	If sExecType = "" Then                
		'check if root folder is exist otherwise create the root folder    
		If fso.FolderExists(sRootLocalPath) = False Then    
			fso.CreateFolder (sRootLocalPath)    
		End If    
		'check & create the hirrarchy of subfoders 
		'check the subfolders exist if not create the subfolders         
		sTempPath = sRootLocalPath & "\" & sApp
		If fso.FolderExists(sTempPath) = False Then
			fso.CreateFolder (sTempPath)
		End If
		sTempPath = sRootLocalPath & "\" & sApp & "\" & sRunType
		If fso.FolderExists(sTempPath) = False Then
			fso.CreateFolder (sTempPath)
		End If
		'create the folder of time stamp inside the above path             
		'Get Current date into yyyy-mm-dd format 
		sDate = DatePart("yyyy", Date) & "_" & Right("0" & DatePart("m", Date), 2) & "_" & Right("0" & DatePart("d", Date), 2)        
		'Get Current Time into hh-mm-ss format
		sTime = Right("0" & Hour(Now), 2) & "_" & Right("0" & Minute(Now), 2) & "_" & Right("0" & Second(Now), 2)        
		sDateTime = sDate & "_" & sTime        
		g_sDestinationPath = sTempPath & "\" & sDateTime        
		fso.CreateFolder (g_sDestinationPath)                
		'add backslash into end of the destination path 
		g_sDestinationPath = g_sDestinationPath & "\"   
	End If 
	Set oFolder = fso.GetFolder(sSourceFolderPath)
	'loop through each files in a folder and 
	'copy all the images into destination folder 
	For Each oFile In oFolder.Files 
		If Instr(oFile.Name,".png")>0 then
			sSourcePath=sSourceFolderPath & "\" & oFile.Name            
			fso.CopyFile  sSourcePath,g_sDestinationPath
		End if 
	Next 
	
	'copy log.txt file into destination folder            
	sSourcePath = sSourceFolderPath & "\Log.txt"
	fso.CopyFile sSourcePath,g_sDestinationPath,True            
	sExecType = ""
	
	
	Set objShell = CreateObject("WScript.Shell")
	Set colUsrEnvVars = objShell.Environment("USER")
	colUsrEnvVars("sDestinationPath") = g_sDestinationPath
	colUsrEnvVars("sSourceFolderPath") = sSourceFolderPath
	
End Sub

'**********************************************************************
'	  Name: utCopyCIRunResultsLocal
'	  Purpose:This Sub Copy the run results of current test under desired Location.    
'		    Folder hierarchy will be C:\AutomationTestResult
'			Result will be copied if flag g_bDebugMode=False.
'	  Creator: Shantinath Patil
'
'       Param: sApp| required 
'       AllowedRange:   
'       Description: The name of the apllication will be passed as an input
'
'       Param: sRunType| required                                        
'       AllowedRange:  "EnvironmentCertification"
'       Description: The type of run for which the details need to be logged

'		Param: sRootLocalPath| required                                        
'       AllowedRange: 
'       Description: Path of Root Folder where results need to be copied.
'              
'       Returns: N/A
'**********************************************************************
Public Sub utCopyCIRunResultsLocal(sApp,sEnvironment,sBuildNumber,sRootLocalPath,sDateTimeStamp)
	
	Dim fso, sSourcePath,sSourceFolderPath,sTempPath,sDate,sTime,sDateTime
	Dim oFile,oFolder, strFile, strLine, oFileE, sExecType, sFilePath, sCopyPath
	Dim sEmailSubject,sEmailBody,sEmailAttachmentPath
	'Get the path of current test result into a string
	sSourceFolderPath = Environment("ResultDir")
	Set fso = CreateObject("Scripting.FileSystemObject")    
	'if g_bDebugMode is empty then make it True	
	If g_bDebugMode="" Then 	
		g_bDebugMode=True	
	End If 
	If sExecType = "" Then                
		'check if root folder is exist otherwise create the root folder    
		If fso.FolderExists(sRootLocalPath) = False Then    
			fso.CreateFolder (sRootLocalPath)    
		End If    
		'check & create the hirrarchy of subfoders 
		'check the subfolders exist if not create the subfolders         
		sTempPath = sRootLocalPath & "\" & sApp
		If fso.FolderExists(sTempPath) = False Then
			fso.CreateFolder (sTempPath)
		End If
		sTempPath = sTempPath & "\" & sEnvironment
		If fso.FolderExists(sTempPath) = False Then
			fso.CreateFolder (sTempPath)
		End If
		
		sTempPath = sTempPath & "\" & sBuildNumber
		If fso.FolderExists(sTempPath) = False Then
			fso.CreateFolder (sTempPath)
		End If
		
		sTempPath = sTempPath & "\" & sDateTimeStamp
		If fso.FolderExists(sTempPath) = False Then
			fso.CreateFolder (sTempPath)
		End If
		g_sDestinationPath = sTempPath & "\"      
	End If 
	Set oFolder = fso.GetFolder(sSourceFolderPath)
	'loop through each files in a folder and 
	'copy all the images into destination folder 
	For Each oFile In oFolder.Files 
		If Instr(oFile.Name,".png")>0 then
			sSourcePath=sSourceFolderPath & "\" & oFile.Name            
			fso.CopyFile  sSourcePath,g_sDestinationPath
		End if 
	Next 
	
	'copy log.txt file into destination folder            
	sSourcePath = sSourceFolderPath & "\Log.txt"
	fso.CopyFile sSourcePath,g_sDestinationPath,True            
	sExecType = ""
	
	'Insert results into dgFailApp OR gPassApp depend on PASS OR FAIL

	Set f = fso.OpenTextFile(sSourcePath)
	sLines = f.ReadAll
	If (instr(sLines,"FAIL:") Or instr(sLines,"WARNING:")) then
		If len(Environment("g_FailApp")) = 0 Then
			Environment("g_FailApp") = sApp
		Else
			g_FailApp = Environment("g_FailApp")
			g_FailApp = g_FailApp & " ," & sApp
			Environment("g_FailApp") =g_FailApp
		End If
		sPassFail = "- FAIL:"
		Print "Fail"
	Else
		If len(Environment("g_PassApp")) = 0 Then
			Environment("g_PassApp") = sApp
		Else
			g_PassApp = Environment("g_PassApp")
			g_PassApp = g_PassApp & " ," & sApp
			Environment("g_PassApp") =g_PassApp
		End If
		sPassFail = "- PASS:"
		Print "Pass"
	End if 

End Sub

'**********************************************************************
'	  Name: utCloseBrowser
'	  Purpose:Close all browsers before starting execution
'	  Creator: Shantinath Patil
'
'       Param: N/A 
'       AllowedRange:   
'       Description: 
'     
'       Returns: N/A
'**********************************************************************

Sub utCloseBrowser ()
	Dim iCnt :iCnt = 0
	'Incase Occur occurs move to next step
	On Error Resume Next
	'Using Descriptive Programming in UFT to create the browser object
	Set objBrowser = Description.Create
	objBrowser("micclass").Value = "Browser"
	'Creating the Page Desription
	Set objPage = Description.Create
	objPage("micclass").Value = "Page"
	'Get all browsers which are opened
	Set allBrowser = Desktop.ChildObjects(objBrowser)
	'Taking the count of browsers
	iCntBrowser = allBrowser.Count - 1
	'if no browsers were found, exit
	If iCntBrowser < 0 Then
		Print "No opened Browser found!!!"
	Exit Sub       
	End If
	'Looping untiL the last opened browser
	For iCnt = 0 To iCntBrowser
		'Get the page object from the browser
		Set objPg = allBrowser(iCnt).ChildObjects(objPage)(0)
		'exit if the last open browser is ALM  (as we don't want to close this)
		If iCntBrowser=0 AND InStr(objPg.GetROProperty("title"), "HP Application Lifecycle Management") > 0 Then
			On Error GoTo 0
			Print "Only ALM browser is opened!!!"
			Exit Sub
		End If
		'Close the browser
		If InStr(objPg.GetROProperty("title"), "HP Application Lifecycle Management") = 0 Then
			allBrowser(iCnt).Close  
		End If
	Next  
	'Destroying the objects
	Set objBrowser = Nothing
	Set objPg = Nothing 
	Set objPage = Nothing  
End Sub

'**********************************************************************
'	  Name: utSendEmailFromOutlook
'	  Purpose:This Sub triger email to people added in EnvCertTesting.xlsx TO,CC.    
'
'	 Creator: Ashish Rupanwar
'
'       Param: sEmailTo| required 
'       AllowedRange:   
'       Description: From EnvCertTesting.xlsx Mian sheet SendEmailTo field
'
'       Param: sEmailCC| required                                        
'       AllowedRange:  
'       Description: From EnvCertTesting.xlsx Mian sheet SendEmailCC field
'		
'		Param: sEmailBCC| Optional                                        
'       AllowedRange:  
'       Description: From EnvCertTesting.xlsx Mian sheet SendEmailBCC field
'		
'		Param: sEmailSubject| required                                        
'       AllowedRange: 
'       Description: Subject of Email.
'              
'		Param: sEmailBody| required                                        
'       AllowedRange: 
'       Description: Description of Email with path.
'
'		Param: sEmailAttachmentPath| required                                        
'       AllowedRange: 
'       Description: File path to attach into Email.

'       Returns: N/A
'**********************************************************************
Public sub utSendEmailFromOutlook(sEmailTo,sEmailCC,sEmailBCC,sEmailSubject,sEmailBody,sEmailAttachmentPath)
 	Dim objOutlook,resultEmail
 	Set objOutlook = CreateObject("Outlook.Application")
	Set resultEmail = objOutlook.CreateItem(0)
	
	resultEmail.To = sEmailTo
	resultEmail.CC = sEmailCC
	If sEmailBCC <> "" Then
		resultEmail.BCC = sEmailBCC 
	End If
	resultEmail.Subject = sEmailSubject
	resultEmail.Body= sEmailBody
	If sEmailAttachmentPath <> ""  Then
		resultEmail.Attachments.Add(sEmailAttachmentPath) 	
	End If
	resultEmail.Send
	Wait(5)
	Set resultEmail = Nothing
	Set objOutlook = Nothing
 
End sub

'**********************************************************************
'	  Name: utCITestingDriver
'	  Purpose:This Sub execute CI Test which is Y in application sheet of CITesting.xlsx
'	  Creator: Bhausaheb Shebdale
'
'       Param: g_MainSheetPath| required 
'       AllowedRange:"C:\Testware\Common\CI\CITesting.xlsx"
'       Description: CITesting.xlsx path
'
'       Param: sAppShortName| required                                        
'       AllowedRange:  
'       Description: Short Name of application and there is folder in "C:\Testware\Apps" with this name

'		Param: g_sRootLocalPathApp| required                                        
'       AllowedRange: 
'       Description: Path of Root Folder where results need to be copied.
'
'		Param: strBuildNumber| required                                        
'       AllowedRange: 
'       Description: Application Build number which is buid through Jenkins.

'		Param: strEnvironmentName| required                                        
'       AllowedRange: 
'       Description: Environment Build number which is buid through Jenkins.
'       Returns: N/A
'**********************************************************************
Public Sub utCITestingDriver(g_MainSheetPath,sAppShortName,g_sRootLocalPathApp,strBuildNumber,strEnvironmentName,strDateTimestamp)
	utCloseBrowser
	g_sAppName=sAppShortName
	g_sEnvironmentName = strEnvironmentName
	g_sRunType = "CI" 
	g_bCapturePassBitmaps = False 
	g_bDebugMode = False
	Set g_oScenarioRecordSet=xclGetSheetRecords("","ExeFlagScenario","Y",sAppShortName,g_MainSheetPath)
	iScenarioCnt=g_oScenarioRecordSet.recordCount
	
	For j=1 to iScenarioCnt
		sExeFlagScenario=g_oScenarioRecordSet.Fields("ExeFlagScenario").Value
		sScriptName=g_oScenarioRecordSet.Fields("ScriptName").Value
		sScriptPath=g_oScenarioRecordSet.Fields("ScriptPath").Value
		sScriptFldPathVBS = sScriptPath & "\" & sScriptName & ".vbs"
		LoadFunctionLibrary sScriptFldPathVBS
		Execute sScriptName
		g_oScenarioRecordSet.MoveNext
	Next
	
	PrintToLog "========================================================="  
	If iScenarioCnt < 1 then
		PrintToLog "For application : " & sAppShortName & " - ExeFlagApp is set to 'Y' but ExeFlagScenario flag for all scenario set to 'N' "
	End If
	utCopyCIRunResultsLocal g_sAppName,strEnvironmentName,strBuildNumber,g_sRootLocalPathApp,strDateTimestamp
	
	Dim fso, folder, f, sSourceFolderPath
	sSourceFolderPath = Environment("ResultDir")
	Set fso = CreateObject("Scripting.FileSystemObject")    
	Set folder = fso.GetFolder(sSourceFolderPath)
	For each f in folder.Files
		f.Delete True		
	Next
	Set fso = Nothing
End Sub

'**************************************************************************
'    Name: utBrowserClrCache
'    Purpose: This sub will clear Internet Explorer's browser history and cache
'    Creator:Vishal Pandya
'
'    Returns: N/A
'***************************************************************************
Public Sub utBrowserClrCache()
	
	Dim dteWait
	SystemUtil.Run "Control.exe","inetcpl.cpl"
	Dialog("text:=Internet.*").WinButton("text:=.*Delete.*","Class Name:=WinButton").Click
	Dialog("text:=Delete.*").WinButton("text:=.*Delete.*","Class Name:=WinButton").Click
	dteWait = DateAdd("s", 10, Now())
	Do Until (Now() > dteWait)
	Loop
	Dialog("text:=Internet Properties").WinButton("text:=OK").Click
	
End Sub

'**************************************************************************
'    Name: utSendKeys
'    Purpose: This sub is used to Handle keyboard key strokes
'    Creator:Vishal Pandya
'
'		Param:  sValue | required
'		AllowedRange: 
'		Description: Value to be sent by keyboard
'
'		Param:  bFlag | required
'		AllowedRange: True/False
'		Description: If True: Will Consider sValue as Special Key. ex:Enter,Home,Ctrl
'					 If False: Will Handle keyboard key strokes normally
'    Returns: N/A
'***************************************************************************
Public Sub utSendKeys(sValue, bFlag)
	
	Dim mySendKeys
 	Set mySendKeys = CreateObject("WScript.shell")
 	
 	If bFlag = True Then
 		sValue = UCase(sValue)
 		sValue = "{"&sValue&"}"
 	End If
 	
 	mySendKeys.SendKeys(sValue)
 	
End Sub

'**********************************************************************
'    Name: utPrintRAMUsage
'    Purpose:This sub is to print in log Total/Used/Available Physical Memory
'    Creator: Vishal Pandya
'
'    Returns: N/A
'**********************************************************************
Public Sub utPrintRAMUsage()
	strComputer = "."
	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
	myQuery="Select * from Win32_ComputerSystem"
	Set colItems = objWMIService.ExecQuery(myQuery)
	For each objitem in colItems
	    'msgbox "Total Physical Memory "&Left(CStr(objitem.TotalPhysicalMemory/1073741824), 4)
		iTotalMem = Left(CStr(objitem.TotalPhysicalMemory/1073741824), 4)
	Next
	
	myQuery="Select * from Win32_PerfFormattedData_PerfOS_Memory"
	Set colItems = objWMIService.ExecQuery(myQuery)
	For Each objItem in colItems
	    'msgbox "Available GB: "&Left(CStr(objItem.AvailableKBytes/1073741824), 4)
		iAvailMem = Left(CStr(objItem.AvailableKBytes/1073741824), 4)
	Next
	iUsedMem = CDbl(iTotalMem)-CDbl(iAvailMem)
	PrintToLog "Total Physical Memory "&iTotalMem&" GB"
	PrintToLog "Available Physical Memory: "&iAvailMem&" GB"
	PrintToLog "Currently used Physical Memory is: "&iUsedMem&" GB"
End Sub


'**************************************************************************
'    Name: utRewriteLoginInfo
'    Purpose: This sub is used to rewrite login.ini based on given environment excel path.
'    Creator:Vishal Shah
'
'		Param:  sEnvInfoExlPath | required
'		AllowedRange: 
'		Description: The source env info excel path from which information will be picked up.
'
'		Param:  sLoginInfoFilePath | required
'		AllowedRange: 
'		Description: Path for login.ini.

'		Param:  sAppName | required
'		AllowedRange: 
'		Description: Application name for which login.ini should be rewritten.

'		Param:  sEnv | required
'		AllowedRange: 
'		Description: Environment name for which login.ini should be rewritten.

'    Returns: N/A
'***************************************************************************


Public Sub utRewriteLoginInfo(sEnvInfoExlPath,sLoginInfoFilePath,sAppName,sEnv)


iAppNameEnvDetailsXl = 2
iEnvNameEnvDetailsXl = 3
iUserNameEnvDetailsXl = 4
iPwdEnvDetailsXl = 5
iURLEnvDetailsXl = 6
iReleaseInfoEnvDetailsXl = 7
iBuildInfoEnvDetailsXl = 8


bFound = False

Set xlAppEnvApp = CreateObject("Excel.Application")
xlAppEnvApp.Visible = True
Set xlWorkbook= xlAppEnvApp.Workbooks.Open(sEnvInfoExlPath)
Set xlAppEnvDetailWorksheet= xlWorkbook.Worksheets("AppEnvDetails")
xlAppEnvDetailWorksheet.Activate()
iAppEnvRowCount = xlAppEnvDetailWorksheet.UsedRange.Rows.count
For Iterator = 2 To iAppEnvRowCount Step 1
	
	If Ucase(Trim(xlAppEnvDetailWorksheet.cells(Iterator,iAppNameEnvDetailsXl).value)) =  Ucase(Trim(sAppName)) Then
		If Ucase(Trim(xlAppEnvDetailWorksheet.cells(Iterator,iEnvNameEnvDetailsXl).value)) = Ucase(Trim(sEnv)) Then
			
			sAppUsename = xlAppEnvDetailWorksheet.cells(Iterator,iUserNameEnvDetailsXl).value
			sAppPwd = xlAppEnvDetailWorksheet.cells(Iterator,iPwdEnvDetailsXl).value
			sAppURL = xlAppEnvDetailWorksheet.cells(Iterator,iURLEnvDetailsXl).value
			sAppReleaseInfo = xlAppEnvDetailWorksheet.cells(Iterator,iReleaseInfoEnvDetailsXl).value
			sAppBuildInfo = xlAppEnvDetailWorksheet.cells(Iterator,iBuildInfoEnvDetailsXl).value
			
			sFinalLoginIniStr = sAppName&""&vbCRLF&"UserName="&sAppUsename&""&vbCRLF&"Password="&sAppPwd&""&vbCRLF&"URL="&sAppURL&""&vbcrlf&"Release="&sAppReleaseInfo&""&vbCRLF&"BuildNumber="&sAppBuildInfo&""&vbCRLF
			sTemp=utGetData(sAppName)		
				
			'msgbox sFinalLoginIniStr
			
			Set objFSO = CreateObject("Scripting.FileSystemObject")			
			Set objFile = objFSO.OpenTextFile(sLoginInfoFilePath, 1)
			strText = objFile.ReadAll
			
			strNewText = Replace(strText, sTemp, sFinalLoginIniStr)	
		
			Set objFile1 = objFSO.OpenTextFile(sLoginInfoFilePath, 2)
			objFile1.WriteLine strNewText
			objFile1.Close
			bFound = True
			Exit For			
			
		End If
	End if	
Next

If bFound = False Then
	PrintToLog "App-Env combination is not available"
End if

xlWorkbook.Close
xlAppEnvApp.Quit



Set xlAppEnvDetailWorksheet= Nothing
Set xlWorkbook= Nothing
Set xlAppEnvApp = Nothing
	
End Sub



Public Sub utProcessResults(sResultFilePath,sRunLogFilePath,sScriptName)

Set objFSO = CreateObject("Scripting.FileSystemObject") 
Set objFile = objFSO.OpenTextFile(sRunLogFilePath, 1)
Set oWriteFile = objFSO.OpenTextFile(sResultFilePath, 8)

Do While not objFile.AtEndOfStream 
	Str = objFile.ReadLine	
		If Instr(1,Str,"FAIL: Function",0) <> 0 or Instr(1,Str,"WARNING: Function",0) <> 0 Then
			bFlag = False
			Exit Do
		Else
			bFlag = True
		End If
Loop

		
				If bFlag Then
					oWriteFile.WriteLine sScriptName &":" &vbTab &vbTab &vbTab &vbTab & "Pass" 
				Else
					oWriteFile.WriteLine sScriptName&":" &vbTab &vbTab &vbTab &vbTab & "Fail"
				End If


objFile.Close
oWriteFile.Close
Set objFile = Nothing
Set objFSO = Nothing

'Delete all the Temporary Folders created to store the results
	utDeleteAllFolders "C:\QTP_DevOps_Demo\Logs\CAL\Regression"
	
End Sub


Public Sub utFinaCIRunResultsFileSetup(sFoldername)
Set oResFso = CreateObject("Scripting.FileSystemObject")
	If oResFso.FolderExists(sFoldername) = false Then
	 oResFso.CreateFolder (sFoldername)
	End If
	
	If oResFso.FileExists(sFoldername&"\Run_Results.txt") then
 		oResFso.DeleteFile(sFoldername&"\Run_Results.txt")
 		oResFso.CreateTextFile(sFoldername&"\Run_Results.txt")
	Else
	 	oResFso.CreateTextFile(sFoldername&"\Run_Results.txt")
	End If
	
'Write header to the Text File
	Set oWrite = oResFso.OpenTextFile(sFoldername&"\Run_Results.txt",2)
	
		oWrite.WriteLine "Run Time:" &vbtab & Now 

		oWrite.WriteLine "Run By:"&vbtab &vbtab & Environment("UserName")
		
		oWrite.WriteLine "*********************************************************************************************** "& Vbcrlf
		
		oWrite.WriteLine "Script Name" &vbtab &vbtab &vbtab &vbtab & "Status" &Vbcrlf
		oWrite.Close
Set oResFso = Nothing
End Sub





Public Sub utDeleteAllFolders(sRootFolderPath)

	Set oResFso = CreateObject("Scripting.FileSystemObject")
	
	Set objFolder =  oResFso.GetFolder(sRootFolderPath)
	Set oSubFolders = objFolder.SubFolders
		For each oChildFolder in oSubFolders
			oResFso.DeleteFolder(oChildFolder)
		Next
	
	Set oSubFolders = Nothing
	Set oResFso = Nothing
	Set objFolder = Nothing
End Sub



Public Sub utSendEmailFromOutlook(sTO,sCC,sSubject,sBody,sAttach)
 
'Create an object of type Outlook
Set objOutlook = CreateObject("Outlook.Application")
Set myMail = objOutlook.CreateItem(0)
 
'Set the email properties
myMail.To = sTO
myMail.CC = sCC 'Sending mails to multiple ids
myMail.Subject = sSubject
myMail.Body= sBody
myMail.Attachments.Add(sAttach) 'Path of the file to be attached
 
'Send the mail
myMail.Send
Wait(3)
 
'Clear object reference
Set myMail = Nothing
Set objOutlook = Nothing
 
End Sub



Public Sub IntegrationTesting(sAttachDocInt,sSheetNameInt,sExcelPathInt,oEmailRecordSet)
	Set objFSO = CreateObject("Scripting.FileSystemObject") 
	Set objFile = objFSO.OpenTextFile(sAttachDocInt, 1)
	
	Do While not objFile.AtEndOfStream 
		Str = Ucase(objFile.ReadLine)
			If Instr(1,Str,"FAIL",0) <> 0 Then
				bFlag = False
				Exit Do
			Else
				bFlag = True
			End If
	Loop
	objFile.Close
	
	'Delete the Log File
		objFSO.DeleteFile(sAttachDocInt)
		If bFlag Then
				Set oFullRecordSet = xclGetSheetRecords("","","",sSheetNameInt,sExcelPathInt)
				'Setup the Result Folder before Running the test
					utFinaCIRunResultsFileSetup  "C:\DevOpsMasterFolder\Results"
				
					For iIterator = 1 To oFullRecordSet.RecordCount Step 1
			
						sScriptName = oFullRecordSet.Fields("ScriptName")
						sSerialNo = oFullRecordSet.Fields("Sno")
				
							Execute sScriptName&"("&sSerialNo&")"
				
						oFullRecordSet.MoveNext
						
					Next	
					
			
					sTOMembers = oEmailRecordSet.Fields("To")
					sCCMembers = oEmailRecordSet.Fields("CC")
					sSubjectLine = oEmailRecordSet.Fields("SubjectInteGration")
					sBodyLine = oEmailRecordSet.Fields("BodyIntegration")
					sAttachDoc = oEmailRecordSet.Fields("Attachment")
					
					
					'Send Mail to the Owners of the application
					utSendEmailFromOutlook sTOMembers,sCCMembers,sSubjectLine,sBodyLine,sAttachDoc					
		End If
	
End Sub
 
