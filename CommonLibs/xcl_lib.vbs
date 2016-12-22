Option Explicit

'*************************** MAINTAIN THIS HEADER! *********************************
'     Library Name:     xcl_lib.vbs
'     Purpose:          A library for working with excel data tables..
'
'---------------------------------------------------------------------------------
'
'
'********************************************************************************** 


'**********************************************************************************
'                           PRIVATE CONSTANTS and VARIABLES
'**********************************************************************************

 

'**********************************************************************************
'                           PUBLIC CONSTANTS and VARIABLES
'**********************************************************************************






'**********************************************************************************
'                             PRIVATE FUNCTIONS
'**********************************************************************************



'**********************************************************************************
'                                PUBLIC FUNCTIONS
'**********************************************************************************




'**********************************************************************
'	Name: xclGetCellValue
'	Purpose:	This function opens an excel table, retrieves a cell value,
'							and then closes the excel object.
'	
'		Param: sTable | required | InitialEntry=sTable 
'		AllowedRange: 
'		Description: The name of the excel table to close.
'
'		Param: iRow | required | InitialEntry=iRow
'		AllowedRange: 
'		Description: The row of the cell - the first row is the column headers.
'
'		Param: vCol | required | InitialEntry=vCol
'		AllowedRange: 
'		Description: The column of the cell.  If this is a number,
'								the column number is used.  If it's a string,
'								the function searches for the column name and uses it,.
'								If the column name doesn't exist, an error occurs.
'
'		Param: sWS | Optional | AssumedValue=The first worksheet.
'		AllowedRange: 
'		Description: The worksheet to use.
'
'	Returns: The value of the cell.
'
'**********************************************************************
Public Function xclGetCellValue(sTable, iRow, vCol, sWS)
	

	Dim oWS, oApp, oTable, bSheetFound, asHeaders, iCounter, bColFound, iColIndex, iRowCount, iColCount, i
	Dim sLCaseColArg, sLCaseColTable, sCellValue, iCount, sTableSheetName

	iRowCount = xclGetRowCount(sTable, sWS) + 1
	errHandler Err, "xclGetCellValue", g_iSeverity
	If iRow > iRowCount Then

		Err.Number = g_lROW_COL_OUT_OF_RANGE
		Err.Description = "Requested row - " & iRow & " - exceeds row count (" & iRowCount & ") for table - " & sTable & "."
		errHandler Err, "xclGetCellValue", g_iSeverity
		Exit Function
	End If
	
	If IsNumeric(vCol) = False And vCol <> "" then
		bColFound = False
		sLCaseColArg = LCase(vCol)
		asHeaders = xclGetColHeaders (sTable,  sWS)
		errHandler Err, "xclGetCellValue", g_iSeverity
		For iCounter = 0 To UBound(asHeaders)
			sLCaseColTable = Trim(LCase(asHeaders(iCounter)))
			If Trim(sLCaseColTable) = Trim(sLCaseColArg) Then
				bColFound = True
				iColIndex = iCounter + 1
				Exit For
			End If

		Next
		If bColFound = False Then
			Err.Number = g_lCOL_NOT_FOUND_ERR
			Err.Description = "Column not found for table - " & sTable & "."
			errHandler Err, "xclGetCellValue", g_iSeverity
			Exit Function
		End If
	Else
		iColIndex = vCol
		iColCount = xclGetColCount(sTable, sWS)
		If iColIndex > iColCount Then
			Err.Number = g_lROW_COL_OUT_OF_RANGE
			Err.Description = "Requested column - " & iColIndex & " - exceeds column count (" & iColCount & ") for table - " & sTable & "."
			errHandler Err, "xclGetCellValue", g_iSeverity
			Exit Function
			'Err.Raise g_lROW_COL_OUT_OF_RANGE, "xclGetCellValue", "Requested column - " & iColIndex & " - exceeds column count (" & iColCount & ") for table - " & sTable & "."
		End If
	End if
	
	Set oApp = CreateObject("Excel.Application")
	Set oTable = oApp.Workbooks.Open(sTable)		
	
	If sWS = "" Then
		oTable.Sheets(1).Select
	Else
		sWS = LCase(sWS)
		iCount =oTable.Sheets.Count
		FOR i = 1 TO iCount
			sTableSheetName = LCase(oTable.sheets(i).name)
			If sTableSheetName=sWS Then
				oTable.Sheets(i).Select		
				Exit For
			end if
			
		Next 
	End if

	sCellValue = oApp.Cells(iRow, iColIndex).Value
	oApp.DisplayAlerts = False
	Set oTable = Nothing
	oApp.Quit
	Set oApp = Nothing
	
	xclGetCellValue = sCellValue

End Function

'**********************************************************************
'	Name: xclGetRowCount
'	Purpose:	This function returns the row count for an excel table..
'	
'		Param: sTable | required | InitialEntry=sTable 
'		AllowedRange: 
'		Description: The name of the excel table..
'
'		Param: sWS | optional| AssumedValue=The first worksheet
'		AllowedRange: 
'		Description: The worksheet to use..
'
'	Returns: The table's row count.
'
'**********************************************************************
Public Function  xclGetRowCount(sTable, sWS)
	

	Dim  oApp, oTable, sTableSheetName, iRowCount, bSheetFound, i, iCount
   
	bSheetFound = False
	'IF no worksheet was passed in, get the name of the first worksheet
	Set oApp = CreateObject("Excel.Application")
	errHandler Err, "xclGetRowCount", g_iSeverity

	Set oTable = oApp.Workbooks.Open(sTable)
	errHandler Err, "xclGetRowCount", g_iSeverity

	' If the worksheet wasn't passed in, set the first worksheet as active
	If sWS = "" Then
		oTable.Sheets(1).Select
		errHandler Err, "xclGetRowCount", g_iSeverity
	Else
		'Otherwise, find the worksheet and set is as active
		sWS = LCase(sWS)
		iCount =oTable.Sheets.Count
		FOR i = 1 TO iCount
			sTableSheetName = LCase(oTable.sheets(i).name)
			If sTableSheetName=sWS Then
				oTable.Sheets(i).Select		
				bSheetFound = True
				Exit For
			end if
			
		Next 

		'If the sheet wasn't found, throw an error.
		If bSheetFound = False Then
			Err.Number = g_lOBJ_NOT_FOUND_ERR
			Err.Description = "Unable to find worksheet - " & sWS & "."
			errHandler Err,"xclGetRowCount", g_iSeverity
		End If

	End if


	iRowCount = oTable.ActiveSheet.UsedRange.Rows.Count
	errHandler Err, "xclGetRowCount", g_iSeverity

	Set oTable = Nothing
	oApp.DisplayAlerts = False
	oApp.Quit
	Set oApp = Nothing

	xclGetRowCount = iRowCount
End Function

'**********************************************************************
'	Name: xclGetColCount
'	Purpose:	This function returns the column count for an excel table..
'	
'		Param: sTable | required | InitialEntry=sTable 
'		AllowedRange: 
'		Description: The name of the excel table..
'
'		Param: sWS | optional | AssumedValue=The first worksheet 
'		AllowedRange: 
'		Description: The name of the worksheet to use..
'
'	Returns: The table's column count.
'
'**********************************************************************
Public Function  xclGetColCount(sTable, sWS)
	

	Dim  oApp, oTable, sTableSheetName, iRowCount, bSheetFound, iColCount
	Dim i, iCount
	bSheetFound = False
	'IF no worksheet was passed in, get the name of the first worksheet
	Set oApp = CreateObject("Excel.Application")
	errHandler Err, "xclGetColCount", g_iSeverity
	
	If xclCheckExcelOpenstatus(sTable) <> 1 Then
		Set oTable = oApp.Workbooks.Open(sTable)
	Else
		Set oTable = GetObject(sTable) 	
	End If
	oApp.Visible = true
'	Set oTable = oApp.Workbooks.Open(sTable)
    errHandler Err, "xclGetColCount", g_iSeverity

	' If the worksheet wasn't passed in, set the first worksheet as active
	If sWS = "" Then
		oTable.Sheets(1).Select
		errHandler Err, "xclGetColCount", g_iSeverity
	Else
		'Otherwise, find the worksheet and set is as active
		sWS = LCase(sWS)
		iCount =oTable.Sheets.Count
		FOR i = 1 TO iCount
			sTableSheetName = LCase(oTable.sheets(i).name)
			If sTableSheetName=sWS Then
				oTable.Sheets(i).Select		
				errHandler Err, "xclGetColCount", g_iSeverity
				bSheetFound = True
				Exit For
			end if
			
		Next 

		'If the sheet wasn't found, throw an error.
		If bSheetFound = False Then
			Err.Number = g_lOBJ_NOT_FOUND_ERR
			Err.Description = "Unable to find worksheet - " & sWS & "."
			errHandler Err,"xclGetColCount", g_iSeverity
		End If

	End if
	
	iColCount = oTable.ActiveSheet.UsedRange.Columns.Count
	
	oApp.Visible = true	
	
	Set oTable = Nothing
	oApp.DisplayAlerts = False
	oApp.Application.Quit
	Set oApp = Nothing

	xclGetColCount = iColCount

End Function

'**********************************************************************
'	Name: xclGetColHeaders
'	Purpose:	This function returns an array of the column headers..
'	
'		Param: sTable | required | InitialEntry=sTable 
'		AllowedRange: 
'		Description: The name of the excel table..
'
'		Param: sWS | optional | AssumedValue=The first worksheet
'		AllowedRange: 
'		Description: The worksheet to use.
'
'	Returns: An array of the table's column headers.
' 
'**********************************************************************
Public Function xclGetColHeaders(sTable, sWS)
	

	Dim oApp, sVal, iRow, iCol, iCounter, iElementIndex, iColCount, oTable
	Dim asHeaders(),sTableSheetName, iCount, i
	
	Set oApp = CreateObject("Excel.Application")
	errHandler Err, "xclGetColHeaders", g_iSeverity
	
	If xclCheckExcelOpenstatus(sTable) <> 1 Then
		Set oTable = oApp.Workbooks.Open(sTable)
	Else
		Set oTable = GetObject(sTable) 			
	End If
	oApp.Visible = true
'	Set oTable = oApp.Workbooks.Open(sTable)
	errHandler Err, "xclGetColHeaders", g_iSeverity

	 If sWS = "" Then
		oTable.Sheets(1).Select
		errHandler Err, "xclGetColHeaders", g_iSeverity
	Else
		sWS = LCase(sWS)
		iCount =oTable.Sheets.Count
		FOR i = 1 TO iCount
			sTableSheetName = LCase(oTable.sheets(i).name)
			If sTableSheetName=sWS Then
				oTable.Sheets(i).Select		
				errHandler Err, "xclGetColHeaders", g_iSeverity
				Exit For
			end if
			
		Next 
	End if

	iColCount = xclGetColCount(sTable, sWS)
	errHandler Err, "xclGetColHeaders", g_iSeverity

	iElementIndex = 0
	For iCounter = 1 To iColCount  
		ReDim Preserve asHeaders(iElementIndex)
		asHeaders(iElementIndex) =  oApp.Cells(1, iCounter).Value
		errHandler Err, "xclGetColHeaders", g_iSeverity
		iElementIndex = iElementIndex + 1
	Next
	
	oApp.Visible = true
	Set oTable = Nothing
	oApp.DisplayAlerts = False
	errHandler Err, "xclGetColHeaders", g_iSeverity
	oApp.ActiveWorkbook.Save
	errHandler Err, "xclGetColHeaders", g_iSeverity
	oApp.Application.Quit	
	Set oApp = Nothing
	xclGetColHeaders=asHeaders
End Function

'**********************************************************************
'	Name: xclGetRowHeaders
'	Purpose:	This function returns an array of the row headers..
'
'		Param: sTable | required | InitialEntry=sTable 
'		AllowedRange: 
'		Description: The name of the excel table..
'
'		Param: sWS | optional | AssumedValue=The first worksheet
'		AllowedRange: 
'		Description: The worksheet to use.
'
'	Returns: The table's row count.
'
'**********************************************************************
Public Function xclGetRowHeaders(sTable, sWS)
	
	Dim oApp, sVal, iRow, iCol, iCounter, iElementIndex, iRowCount, oTable
	Dim asHeaders(),sTableSheetName, iCount, i
	
	Set oApp = CreateObject("Excel.Application")
	errHandler Err, "xclGetRowHeaders", g_iSeverity

	Set oTable = oApp.Workbooks.Open(sTable)
	errHandler Err, "xclGetRowHeaders", g_iSeverity

	 If sWS = "" Then
		oTable.Sheets(1).Select
		errHandler Err, "xclGetRowHeaders", g_iSeverity
	Else
		sWS = LCase(sWS)
		iCount =oTable.Sheets.Count
		FOR i = 1 TO iCount
			sTableSheetName = LCase(oTable.sheets(i).name)
			If sTableSheetName=sWS Then
				oTable.Sheets(i).Select		
				errHandler Err, "xclGetRowHeaders", g_iSeverity
				Exit For
			end if
			
		Next 
	End if

	iRowCount = xclGetRowCount(sTable, sWS)
	errHandler Err, "xclGetRowHeaders", g_iSeverity

	iElementIndex = 0
	For iCounter = 1 To iRowCount  
		ReDim Preserve asHeaders(iElementIndex)
		asHeaders(iElementIndex) =  oApp.Cells( iCounter,1).Value
		errHandler Err, "xclGetRowHeaders", g_iSeverity
		iElementIndex = iElementIndex + 1
	Next
	Set oTable = Nothing
	oApp.DisplayAlerts = False
	 errHandler Err, "xclGetRowHeaders", g_iSeverity
	oApp.ActiveWorkbook.Save
	errHandler Err, "xclGetRowHeaders", g_iSeverity
	oApp.Application.Quit	
	Set oApp = Nothing
	xclGetRowHeaders=asHeaders
End Function

'**********************************************************************
'	Name: xclSetCellValue
'	Purpose:This sub  writes a value to an excel file.
'
'		Param: sTable | required | InitialEntry=sTable 
'		AllowedRange: 
'		Description: The name of the excel table..
'
''		Param: vValue| required
'		AllowedRange:  
'		Description: The value of  to be stored 
'
'		Param: iRow| required
'		AllowedRange:  
'		Description: The row number of the cell to write to. NOTE:  The first row contains the column headers,
'			so passing row 1 will change the name of the column header.
'
'		Param: vColumn| required
'		AllowedRange:  
'		Description: The column to write to.  The column can be either a numeric index (1 based)
'			or the name of the column header. 
'
'		Param: sWS | optional | AssumedValue=The first worksheet
'		AllowedRange: 
'		Description: The worksheet to use.
'
'	Returns: N/A 
''**********************************************************************'
Public Sub xclSetCellValue (sTable, vValue, iRow, vColumn, sWS)
	

	Dim oSheet, oApp, oTable, asHeaders, bColFound, iColIndex, iColCounter
	Dim i, iCount,sTableSheetName
	
	bColFound = False
	If IsNumeric(vColumn) = False Then
        asHeaders = xclGetColHeaders (sTable, sWS)
		For iColCounter = 0 to UBound(asHeaders)
			If LCase(asHeaders(iColCounter)) = LCase(vColumn) Then
				iColIndex = iColCounter + 1
                bColFound = True			
				Exit For
			End If
		Next
	Else
		bColFound = True
		iColIndex = vColumn
	End If

	If bColFound = False Then
		err.number = g_lCOL_NOT_FOUND_ERR
		err.description = "Unable to find the column - " & vColumn & " for updating a cell in an excel table - " & sTable & "."
		errHandler Err, "xclSetCellValue", g_iSeverity
	End If

	Set oApp = CreateObject("Excel.Application")
	errHandler Err, "xclSetCellValue", g_iSeverity
	
	If xclCheckExcelOpenstatus(sTable) <> 1 Then
		Set oTable = oApp.Workbooks.Open(sTable)
	Else
		Set oTable = GetObject(sTable) 			
	End If
	'Set oTable = oApp.Workbooks.Open(sTable)
	errHandler Err, "xclSetCellValue", g_iSeverity

	oApp.Visible=True
	
	 If sWS = "" Then
		oTable.Sheets(1).Select
		errHandler Err, "xclSetCellValue", g_iSeverity
		Set oSheet = oTable.Sheets(1)
		errHandler Err, "xclSetCellValue", g_iSeverity
	Else
		sWS = LCase(sWS)
		iCount =oTable.Sheets.Count
		FOR i = 1 TO iCount
			sTableSheetName = LCase(oTable.sheets(i).name)
			If sTableSheetName=sWS Then
				oTable.Sheets(i).Select		
				errHandler Err, "xclSetCellValue", g_iSeverity
				Set oSheet =oTable.Sheets.Item(i)
				errHandler Err, "xclSetCellValue", g_iSeverity
				Exit For
			end if
			
		Next 
	End if
	oApp.Visible = True
	oSheet.Cells(iRow,iColIndex) = vValue
	errHandler Err, "xclSetCellValue", g_iSeverity
	oApp.DisplayAlerts = False
	errHandler Err, "xclSetCellValue", g_iSeverity
	oApp.ActiveWorkbook.Save
	errHandler Err, "xclSetCellValue", g_iSeverity
	oApp.Application.Quit
	errHandler Err, "xclSetCellValue", g_iSeverity
	Set oApp = Nothing
	errHandler Err, "xclSetCellValue", g_iSeverity
	
End Sub


'**********************************************************************
'	Name: xclSetRangeValue
'	Purpose:This sub  writes a value to range of values in a row in an Excel spreadsheet.
'
'		Param: sWorkbook | required | InitialEntry=sTable 
'		AllowedRange: 
'		Description: The name of the excel table..
'
'		Param: sWorksheet | required | InitialEntry=sTable 
'		AllowedRange: 
'		Description: The name of the excel table..
'
'		Param: iRow| required
'		AllowedRange:  
'		Description: The row number of the cell to write to. NOTE:  The first row contains the column headers,
'			so passing row 1 will change the name of the column header.
'
'		Param: sRangeValue| required
'		AllowedRange:  string value seperated with column names separated by a pipe symbol(sProduct="Annuity"| s)
'		Description: The column range to write to.  
''
'	Returns: N/A 
''**********************************************************************'
Public Sub xclSetRangeValue (sWorkbook, sWorksheet, iRow,sRangeValue)
	

	Dim oSheet, oApp, oTable, asHeaders, bColFound, iColIndex, iColCounter
	Dim i, iCount, iCounter
	Dim oExcel, oWorkbook, oWorkSheet 
	Dim asRowValue,sColumnName,sColumnValue

	asHeaders = xclGetColHeaders (sWorkbook, sWorksheet)
    Set oExcel= createObject("Excel.Application")
	errHandler Err, "xclSetRangeValue", g_iSeverity
	Set oWorkbook= oExcel.Workbooks.Open(sWorkbook)
	errHandler Err, "xclSetRangeValue", g_iSeverity
	Set oWorkSheet = oWorkbook.Sheets(sWorksheet)
    errHandler Err, "xclSetRangeValue", g_iSeverity
	
	asRowValue=split(sRangeValue,"|")
	For iCounter = 0 to UBound(asRowValue)
	sColumnName =Trim(Split(asRowValue(iCounter),"=")(0) )
	sColumnValue= 	Trim(Split(asRowValue(iCounter),"=")(1) )

	bColFound = False
	If IsNumeric(sColumnName) = False Then
        For iColCounter = 0 to UBound(asHeaders)
			If LCase(Trim(asHeaders(iColCounter))) = LCase(Trim(sColumnName)) Then
				iColIndex = iColCounter + 1
                bColFound = True			
				Exit For
			End If
		Next
	Else
		bColFound = True
		iColIndex = vColumn
	End If

	 If bColFound = False Then
		err.number = g_lCOL_NOT_FOUND_ERR
		err.description = "Unable to find the column - " & sColumnName & " for updating a cell in an excel table - " &  sWorksheet & "."
		errHandler Err, "xclSetRangeValue", g_iSeverity
	Else
	 oWorkSheet.Cells(iRow,iColIndex) = sColumnValue
     errHandler Err, "xclSetRangeValue", g_iSeverity
	
   End if
   Next

   'oExcel.visible=True
	
	oExcel.ActiveWorkbook.Save
	errHandler Err, "xclSetRangeValue", g_iSeverity
	oExcel.DisplayAlerts = False
    oExcel.Application.Quit
	errHandler Err, "xclSetRangeValue", g_iSeverity
	Set oApp = Nothing
	errHandler Err, "xclSetRangeValue", g_iSeverity
End Sub

'**********************************************************************
'	Name: xclSetColRangeValue
'	Purpose:This sub  writes a range of  column values to an excel file.
'
'		Param: sWorkbook | required | InitialEntry=sTable 
'		AllowedRange: 
'		Description: The name of the excel table..
'
'		Param: sWorksheet | required | InitialEntry=sTable 
'		AllowedRange: 
'		Description: The name of the excel table..
'
'		Param: iRow| required
'		AllowedRange:  
'		Description: The row number of the cell to write to. NOTE:  The first row contains the column headers,
'			so passing row 1 will change the name of the column header.
'
'		Param: sRangeValue| required
'		AllowedRange:  string value seperated with column name and  column value(sProduct="Annuity"| s)
'		Description: The column range to write to.  
''
'	Returns: N/A 
''**********************************************************************'
Public Sub xclSetColRangeValue (sWorkbook, sWorksheet, iRow,sRangeValue)


	Dim oSheet, oApp, oTable, asHeaders, bRowFound, iRowIndex, iRowCounter
	Dim i, iCount, iCounter
	Dim oExcel, oWorkbook, oWorkSheet 
	Dim asColumnValue,sRowName,sRowValue

	asHeaders = xclGetRowHeaders (sWorkbook, sWorksheet)
	
    Set oExcel= createObject("Excel.Application")
	errHandler Err, "xclSetColRangeValue", g_iSeverity
	Set oWorkbook= oExcel.Workbooks.Open(sWorkbook)
	errHandler Err, "xclSetColRangeValue", g_iSeverity
	Set oWorkSheet = oWorkbook.Sheets(sWorksheet)
    errHandler Err, "xclSetColRangeValue", g_iSeverity
	
	oExcel.Sheets(sWorksheet).Select
	oExcel.visible=True
	asColumnValue=split(sRangeValue,"|")
	
	For iCounter = 0 to UBound(asColumnValue)

	sRowName =Trim(Split(asColumnValue(iCounter),"=")(0) )
	sRowValue= 	Trim(Split(asColumnValue(iCounter),"=")(1) )

	bRowFound = False
	If IsNumeric(sRowName) = False Then
        For iRowCounter = 0 to UBound(asHeaders)
           asHeaders(iRowCounter)=Replace( asHeaders(iRowCounter),":","")
           If LCase(Trim(asHeaders(iRowCounter))) = LCase(Trim(sRowName)) Then
				iRowIndex = iRowCounter + 1
                bRowFound = True			
				Exit For
			End If
		Next
	Else
		bRowFound = True
		iRowIndex = vColumn
	End If

	 If bRowFound = False Then
		err.number = g_lCOL_NOT_FOUND_ERR
		err.description = "Unable to find the column - " & sRowName & " for updating a cell in an excel table - " &  sWorksheet & "."
		errHandler Err, "xclSetColRangeValue", g_iSeverity
	Else
	 oWorkSheet.Cells(iRowIndex,iCol).Select
	 oWorkSheet.Cells(iRowIndex,iCol) = sRowValue
     errHandler Err, "xclSetColRangeValue", g_iSeverity
	
   End if
   Next

	oExcel.visible=True
	
	oExcel.ActiveWorkbook.Save
	errHandler Err, "xclSetColRangeValue", g_iSeverity
	oExcel.DisplayAlerts = False
    	oExcel.Application.Quit
	errHandler Err, "xclSetColRangeValue", g_iSeverity
	Set oExcel = Nothing
	errHandler Err, "xclSetColRangeValue", g_iSeverity
End Sub

'**********************************************************************
'	Name: xclGetRowValues
'	Purpose:	This function opens an excel table, retrieves a row value,
'							and then closes the excel object.
'	
'		Param: iRow | required | InitialEntry=iRow
'		AllowedRange: 
'		Description: The row of the cell - the first row is the column headers.
' 
'		Param: iColumn | required | InitialEntry=iColumn
'		AllowedRange: 
'		Description: The last column to retrieve values for.  If this is a number,
'								the column number is used.  If it's a string,
'								the function searches for the column name and uses it,.
'								If the column name doesn't exist, an error occurs.
'
'		Param: sWbook | Optional | AssumedValue=The workbook.
'		AllowedRange: 
'		Description: The workbook to use.
'								 If the workbook doesn't exist, an error occurs.	
'
'		Param: sSheetName | Optional | AssumedValue=
'		AllowedRange: 
'		Description: The worksheet to use.
'								 If the workSheet doesn't exist, an error occurs.	
'	Returns: The value of  all  all cells upto the column  in that  row in an array
'
'**********************************************************************
Public Function xclGetRowValues(iRow,iColumn, sWbook, sSheetName)


	Dim oExcel, oWorkbook, iColCounter, sRowValue
	
	iColCounter=1
	
	Set oExcel= createObject("Excel.Application")
	Set oWorkbook= oExcel.Workbooks.Open(sWbook)
	oExcel.DisplayAlerts = False
	If sSheetName = "" Then
		sSheetName = 1
	End If
	
	oExcel.Sheets(sSheetName).Select
	oExcel.visible=False
	
	
	Do Until iColCounter > iColumn
	oExcel.Cells(iRow, iColCounter).Select
	If  sRowValue <>""Then
		sRowValue= sRowValue & "|" & oExcel.Cells(1, iColCounter).Value & "="  & oExcel.Cells(iRow, iColCounter).Value
	Else
		sRowValue= oExcel.Cells(1, iColCounter).Value & "="  & oExcel.Cells(iRow, iColCounter).Value	
	End If
	
	iColCounter=iColCounter+1
	Loop
	
	xclGetRowValues=sRowValue
	
	oExcel.DisplayAlerts = False

	oExcel.Quit
	Set oExcel= Nothing

End Function


'**********************************************************************
'	Name: xclGetColValues
'	Purpose:	This function opens an excel table, retrieves all of the values in a given column delimited by a pipe symbol, and then closes the excel object.
'	
'		Param: iStartRow | required | InitialEntry=iRow
'		AllowedRange: 
'		Description: The start row of the column
'
'		Param: iColumn | required | InitialEntry=iColumn
'		AllowedRange: 
'		Description: The column of the cell.  If this is a number,
'								the column number is used.  If it's a string,
'								the function searches for the column name and uses it,.
'								If the column name doesn't exist, an error occurs.
'
'		Param: sWbook | Optional | AssumedValue=The workbook.
'		AllowedRange: 
'		Description: The workbook to use.
'								 If the workbook doesn't exist, an error occurs.	
'
'		Param: sSheetName | Optional | AssumedValue=
'		AllowedRange: 
'		Description: The worksheet to use.
'								 If the workSheet doesn't exist, an error occurs.	
'	Returns: The value of  all cells upto the end row  in a String
'
'**********************************************************************
Public Function xclGetColValues(iStartRow,iColumn, sWbook, sSheetName)


	Dim oExcel, oWorkbook, iRowCounter, sColValue, iEndRow
	
	Set oExcel= createObject("Excel.Application")
	Set oWorkbook= oExcel.Workbooks.Open(sWbook)
	oExcel.DisplayAlerts = False
	oExcel.Sheets(sSheetName).Select
	oExcel.visible=False
	iEndRow=xclGetRowCount(sWbook, sSheetName)
	
	For  iRowCounter= iStartRow to iEndRow
	oExcel.Cells(iRowCounter, iColumn).Select
	If  sColValue <>""Then
		sColValue= sColValue & "|" & oExcel.Cells(iRowCounter, 1).Value & "="  & oExcel.Cells(iRowcounter, iColumn).Value
	Else
		sColValue= oExcel.Cells(iRowCounter, 1).Value & "="  & oExcel.Cells(iRowCounter, iColumn).Value	
	End If
	
	Next
	
	xclGetColValues=sColValue
	
	oExcel.DisplayAlerts = False
	
	oExcel.Quit
	Set oExcel= Nothing

End Function


'***********************************************
'	Name: xclCopyRange
'	Purpose:	This function copies a row value, from source to dest
'	
'		Param: iRow | required | InitialEntry=iRow
'		AllowedRange: 
'		Description: The row of the cell - the first row is the column headers.
'
'		Param: iDestRow 
'		AllowedRange: 
'		Description: 
'
'		Param: iEndColumn | required | InitialEntry=iColumn
'		AllowedRange: 
'		Description: The column of the cell.  If this is a number,
'								the column number is used.  If it's a string,
'								the function searches for the column name and uses it,.
'								If the column name doesn't exist, an error occurs.
'
'		Param: sSrcWbook | Optional | AssumedValue=The workbook.
'		AllowedRange: 
'		Description: The workbook to use.
'								 If the workbook doesn't exist, an error occurs.	
'
'		Param: sSrcSheetName | Optional | AssumedValue=
'		AllowedRange: 
'		Description: The worksheet to use.
'								 If the workSheet doesn't exist, an error occurs.	
'		Param: sDestWbook | Optional | AssumedValue=The workbook.
'		AllowedRange: 
'		Description: The workbook to use.
'								 If the workbook doesn't exist, an error occurs.	
'
'		Param: sDestSheetName | Optional | AssumedValue=
'		AllowedRange: 
'		Description: The worksheet to use.
'								 If the workSheet doesn't exist, an error occurs.	
'	Returns: N/A
'
'**********************************************************************
Public Sub xclCopyRange(iRow,iDestRow,iEndColumn, sSrcWbook, sSrcSheetName, sDestWbook, sDestSheetName)


	Dim oSrcExcel, oSrcWorkbook,oSrcWorkSheet
	Dim oDestExcel, oDestWorkbook,oDestWorkSheet
	Dim oFSO
	Dim iColCounter, sRowValue, i
	
	
	iColCounter=1
	iDestRow=xclGetRowCount (sDestWbook,sDestSheetName )+1
	
	Set oSrcExcel= createObject("Excel.Application")
	Set oSrcWorkbook= oSrcExcel.Workbooks.Open(sSrcWbook)
	Set oSrcWorkSheet = oSrcWorkbook.Sheets(sSrcSheetName)
	
	oSrcExcel.DisplayAlerts = False
	oSrcExcel.Sheets(sSrcSheetName).Select
	oSrcExcel.visible=False
	
	Set oDestExcel= createObject("Excel.Application")
	
	Set oFSO = CreateObject("Scripting.FileSystemObject")
	If oFSO.FileExists(sDestWbook) Then
	   Set oDestWorkbook= oDestExcel.Workbooks.Open(sDestWbook)
	Else
		Set oDestWorkbook= oDestExcel.Workbooks.Add
		oDestWorkbook.WorkSheets("Sheet1" ).Name=sDestSheetName
	End If
	Set oDestWorkSheet = oDestWorkbook.Sheets(sDestSheetName)
	
	oDestExcel.visible=False
	oDestExcel.DisplayAlerts = False
	
	For i=iColCounter to iEndColumn
			oDestWorkSheet.Cells(iDestRow, iColCounter) =oSrcWorkSheet.Cells(iRow,iColCounter).Value
			iColCounter=iColCounter +1
	Next
	
	oSrcExcel.DisplayAlerts = False
	oDestExcel.DisplayAlerts = False
	oDestWorkbook.SaveAs(sDestWbook)
	oDestExcel.DisplayAlerts = False
	'oDestExcel.Visible=True
	
	oSrcExcel.Quit
	oDestExcel.Quit
	Set oSrcExcel= Nothing
	Set oDestExcel= Nothing

End Sub

'***********************************************
'	Name: xclKillProcess
'	Purpose:	This function  kills an  excel  process  thread.
'	
'  Returns: NA
'
'**********************************************************************
Public Sub xclKillProcess()


	Dim strComputer ,objWMIService, colProcessList, objProcess
	strComputer = "."
	
	Set objWMIService = GetObject("winmgmts:" _
		& "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
	Set colProcessList = objWMIService.ExecQuery("Select * from Win32_Process Where Name = 'Excel.exe'")
	For Each objProcess in colProcessList
	objProcess.Terminate()
	Next

End Sub

'**********************************************************************
'	Name: xclCompareRangeValues
'	Purpose:	This function comapres two rows from start to end column 
'						then HIGHLIGHTS the cell red if  its dIfferent\
'	
'		Param: iRow1 | required | InitialEntry=iRow
'		AllowedRange: 
'		Description: The row of the cell - the first row is the column headers.
'
'		Param: iRow2 | required | InitialEntry=iRow
'		AllowedRange: 
'		Description: The row of the cell - the first row is the column headers.
'
'		Param: iStartCol | required | InitialEntry=iColumn
'		AllowedRange: 
'		Description: The column of the cell.  If this is a number,
'		 the column number is used.  If it's a string,
'		the function searches for the column name and uses it,.
'		If the column name doesn't exist, an error occurs.
'
'		Param: iEndCol | required | InitialEntry=iColumn
'		AllowedRange: 
'		Description: The column of the cell.  If this is a number,
'		the column number is used.  If it's a string,
'		the function searches for the column name and uses it,.
'		If the column name doesn't exist, an error occurs.
'
'		Param: sWbook | Optional | AssumedValue=The workbook.
'		AllowedRange: 
'		Description: The workbook to use.
'		If the workbook doesn't exist, an error occurs.	
'
'		Param: sSheetName | Optional | AssumedValue=
'		AllowedRange: 
'		Description: The worksheet to use.
'		  If the workSheet doesn't exist, an error occurs.	
'
'	Returns: N/A
'
'**********************************************************************
Public Sub xclCompareRangeValues(iRow1,iRow2,iStartCol, iEndCol,sWbook, sSheetName)


	Dim oExcel, oWorkbook,iColCounter, sRowValue, iRow1Value, iRow2Value
	
	iColCounter=iStartCol
	
	Set oExcel= createObject("Excel.Application")
	Set oWorkbook= oExcel.Workbooks.Open(sWbook)
	oExcel.DisplayAlerts = False
	oExcel.Sheets(sSheetName).Select
	oExcel.visible=False
	
	Do Until iColCounter > iEndCol
	iRow1Value=oExcel.Cells(iRow1, iColCounter).Value
	iRow2Value=oExcel.Cells(iRow2, iColCounter).Value
	
	
	If  LCase(Trim(iRow1Value)) <> LCase(Trim(iRow2Value)) Then
		oExcel.Cells(iRow2, iColCounter).Interior.ColorIndex =3
	End If
	
	iColCounter=iColCounter+1
	Loop
	oExcel.DisplayAlerts = False
	oExcel.ActiveWorkbook.Save
	oExcel.Quit
	Set oExcel= Nothing

End Sub

'**********************************************************************
'	Name: xclGetColHeaderPosition
'	Purpose:	This function returns the position of the column headers..
'	
'		Param: sWbook | required 
'		AllowedRange: 
'		Description: The name of the excel book
'
'		Param: sSheetName| optional 
'		AllowedRange: 
'		Description: The worksheet to use.
'
'		Param: sColumnName| required 
'		AllowedRange: 
'		Description: An array of the header names.
'
'
'	Returns: The table's row count.
'
'**********************************************************************
Public Function xclGetColHeaderPosition(sWbook, sSheetName, sColumnName)


	Dim oExcel,oWorkbook,sWbookSheetName 
	Dim  sVal, iRow, iCol, iCounter, iElementIndex, iColCount
	Dim  iCount,i
	
	Set oExcel = CreateObject("Excel.Application")
	errHandler Err, "xclGetColHeaderPosition", g_iSeverity

	Set oWorkbook= oExcel.Workbooks.Open(sWbook)
	errHandler Err, "xclGetColHeaderPosition", g_iSeverity

	 If sSheetName = "" Then
		oWorkbook.Sheets(1).Select
		errHandler Err, "xclGetColHeaderPosition", g_iSeverity
	Else
		sSheetName = LCase(sSheetName)
		iCount =oWorkbook.Sheets.Count
		FOR i = 1 TO iCount
			sWbookSheetName = LCase(oWorkbook.sheets(i).name)
			If sWbookSheetName=sSheetName Then
				oWorkbook.Sheets(i).Select		
				errHandler Err, "xclGetColHeaderPosition", g_iSeverity
				Exit For
			end if
			
		Next 
	End if

	iColCount = xclGetColCount(sWbook, sSheetName)
	errHandler Err, "xclGetColHeaderPosition", g_iSeverity
	
	For iCounter = 1 To iColCount  
       If  sColumnName =  oExcel.Cells(1, iCounter).Value then
			xclGetColHeaderPosition= iCounter 
			Exit For
         End if
		errHandler Err, "xclGetColHeaderPosition", g_iSeverity
    Next
	Set oWorkbook = Nothing
	oExcel.DisplayAlerts = False
	oExcel.Quit
	Set oExcel = Nothing

End Function

'**********************************************************************
'	Name:  xclOpenWSheet
'	Purpose:	This function returns the position of the column headers.
'	
'		Param: sWbook | required 
'		AllowedRange: 
'		Description: The name of the excel book
'
'		Param: sSheetName| optional 
'		AllowedRange: 
'		Description: The worksheet to use.
'
'
'	Returns: The table's row count.
'
'**********************************************************************
Public Function xclOpenWSheet(sWbook, sSheetName)


	Dim oExcel, oWorkbook
	Set oExcel = CreateObject("Excel.Application")
	Set oWorkbook = oExcel.Workbooks.Open(sWbook)
	oExcel.Sheets(sSheetName).Select
	oExcel.DisplayAlerts = False
	'oExcel.Visible = True
	oExcel.Visible = False
	 Set oWorkbook = Nothing
	 oExcel.DisplayAlerts = False
	oExcel.Quit
	Set oExcel = Nothing

End Function

'**********************************************************************
'	Name: xclRunMacro
'	Purpose:This function executes a macro in an excel spreadsheet.
'	
'		Param: sWbook | required 
'		AllowedRange: 
'		Description: The name of the excel book
'
'		Param: sSheetName| optional 
'		AllowedRange: 
'		Description: The worksheet to use.
'
'		Param: sMacroName| required 
'		AllowedRange: 
'		Description: name of the macro to be run
'
'	Returns: The table's row count.
'**********************************************************************
Public Sub xclRunMacro(sWbook, sSheetName,sMacroName)


	Dim oExcel, oWorkbook,sAddInsName, x, oAddin 

	Set oExcel= createObject("Excel.Application")
	oExcel.AddIns("Analysis ToolPak").Installed = False
	oExcel.AddIns("Analysis ToolPak - VBA").Installed = False
	oExcel.AddIns("Solver Add-in").Installed = False
	
	oExcel.AddIns("Analysis ToolPak").Installed = True
	oExcel.AddIns("Analysis ToolPak - VBA").Installed = True
	oExcel.AddIns("Solver Add-in").Installed = True
	
	Set oWorkbook= oExcel.Workbooks.Open(sWbook)
	
	oExcel.DisplayAlerts = False
	oExcel.Sheets(sSheetName).Select
	oExcel.visible=True
	
	oExcel.Run sMacroName
	
	oExcel.ActiveWorkbook.SaveAs(sWbook)
	Set oWorkbook = Nothing
	oExcel.Quit
	Set oExcel = Nothing

End sub


'***********************************************
'	Name:  xclCopyWsheet
'	Purpose:	This function copies an entire worksheet from source to destination.
'	
'		Param: sAddressToCopy | required | InitialEntry=iRow
'		AllowedRange: 
'		Description:  The range of cells to copy  like "A1:D1"
'
'		Param: sDestAddress | required | InitialEntry=iColumn
'		AllowedRange: 
'		Description: The starting Address of the cell
'
'		Param: sSrcWbook | Optional | AssumedValue=The workbook.
'		AllowedRange: 
'		Description: The workbook to use.
'								 If the workbook doesn't exist, an error occurs.	
'
'		Param: sSrcSheetName | Optional | AssumedValue=
'		AllowedRange: 
'		Description: The worksheet to use.
'								 If the workSheet doesn't exist, an error occurs.	
'		Param: sDestWbook | Optional | AssumedValue=The workbook.
'		AllowedRange: 
'		Description: The workbook to use.
'								 If the workbook doesn't exist, an error occurs.	
'
'	Returns: N/A
'
'**********************************************************************
Public Sub xclCopyWsheet (sAddressToCopy ,sDestAddress,  sSrcWbook, sSrcSheetName, sDestWbook)


	Dim oFSO, oSrcExcel, oSrcWorkbook,oSrcWorkSheet,  iRowCount
	Dim oDestExcel, oDestWorkbook,oDestWorkSheet,sDestSheetName

	Set oSrcExcel= createObject("Excel.Application")
	Set oSrcWorkbook= oSrcExcel.Workbooks.Open(sSrcWbook)
	Set oSrcWorkSheet = oSrcWorkbook.Sheets(sSrcSheetName)

	oSrcExcel.DisplayAlerts = False
	oSrcExcel.Sheets(sSrcSheetName).Select
	oSrcExcel.visible=True

	Set oDestExcel= createObject("Excel.Application")

	'Source and Dest Sheet should be the same
	sDestSheetName=sSrcSheetName		
	
	Set oFSO = CreateObject("Scripting.FileSystemObject")
	If oFSO.FileExists(sDestWbook) Then
		 Set oDestWorkbook= oDestExcel.Workbooks.Open(sDestWbook)

		If not  IsWorksheetExist(sDestWbook, sDestSheetName) Then
           oDestWorkbook.Worksheets.Add()
			oDestWorkbook.Worksheets("Sheet1").Name = sDestSheetName
        End If
      Else
		Set oDestWorkbook= oDestExcel.Workbooks.Add
		oDestWorkbook.WorkSheets("Sheet1" ).Name=sDestSheetName
	End If
    Set oDestWorkSheet = oDestWorkbook.Sheets(sDestSheetName)
	oDestExcel.Sheets(sDestSheetName).Select
  
	
	oDestExcel.visible=True
	oDestExcel.DisplayAlerts = False

	oSrcExcel.CutCopyMode=False

  'Copies required chunk of data to the clipboard
	 If  sAddressToCopy <>""Then
		oDestWorkSheet.Range(sAddressToCopy) = oSrcWorkSheet.Range(sAddressToCopy).Value
	else
		iRowCount = oSrcExcel.ActiveSheet.UsedRange.Rows.Count
		oDestWorkSheet.Rows(1& ":" &  iRowCount) = osrcWorkSheet.Range(1& ":" &  iRowCount).Value
	 End If

  'Close source workbook without saving
	oSrcExcel.DisplayAlerts = False
	oSrcExcel.Quit
	
	'Save destination workbook
	oDestExcel.DisplayAlerts = False
	oDestExcel.ActiveWorkbook.SaveAs(sDestWbook)

	'Close updated workbook w
    oDestExcel.Quit

	'Destroy the objects
	Set oSrcExcel = Nothing
	Set oDestExcel = Nothing

 End Sub 

'**********************************************************************
'	Name: xclGetRowData
'	Purpose:	This function uses the result of  'xclGetRowValues' function and returns a
'							dictionary containing the row values..
'
'	
'		Param: sWbook | required 
'		AllowedRange: 
'		Description: The path of the excel table..
'
'		Param: sSheetName | Required
'		AllowedRange: 
'		Description: The worksheet to use..
'
'		Param: iRow | Required
'		AllowedRange: 
'		Description: The row in the worksheet to get data.
'
'	Returns: The dictionary object with the column headers and row values.
'
'**********************************************************************
Public Function xclGetRowData(sWbook,sSheetName,iRow)
   

	Dim dicObject,colCount,asColHeaders,sRowValues,asSplitRowValue
	Dim asHeaders(),k,asDataValue(20),iCount,iCounter,asRowValues

	'Get the column count
	colCount = xclGetColCount(sWbook,sSheetName)
	errHandler Err, "xclGetRowData", g_iSeverity

	'Get the row values as a string
	sRowValues = xclGetRowValues(iRow,colCount,sWbook,sSheetName) 
	errHandler Err, "xclGetRowData", g_iSeverity

	 'Get the column headers
	asColHeaders = xclGetColHeaders(sWbook,sSheetName,asHeaders)
	errHandler Err, "xclGetRowData", g_iSeverity

    'split the row values with delimiter '|'
	asSplitRowValue = Split(sRowValues,"|")
	errHandler Err, "xclGetRowData", g_iSeverity

	For iCount=0 to Ubound(asSplitRowValue)

		'Split the row values further with delimiter '='
		asRowValues = Split(asSplitRowValue(iCount),"=")
		errHandler Err, "xclGetRowData", g_iSeverity

		'assign the data value to asDataValue
		asDataValue(iCount) = asRowValues(1)
		errHandler Err, "xclGetRowData", g_iSeverity
		
	Next 
	
    Set dicObject = CreateObject("Scripting.Dictionary")
	errHandler Err, "xclGetRowData", g_iSeverity
	
	For iCounter=0 to ubound(asColHeaders)

		' Add data values from data table to the dictionary object
		dicObject.Add asColHeaders(iCounter) ,asDataValue(iCounter)
		errHandler Err, "xclGetRowData", g_iSeverity
		
	Next

	Set xclGetRowData = dicObject
	
End Function

'**********************************************************************
'	Name: xclWSGetAllData
'	Purpose:	This sub returns all of the data in a data table in an array.  Each column
'	
'		Param: sTable | required 
'		AllowedRange: 
'		Description: The path and name of the Excel table.
'
'		Param: sWS | required
'		AllowedRange: 
'		Description: The worksheet to use..
'
'		Param: asValues| required
'		AllowedRange: 
'		Description: An array of all of the values.  Each element of the array represents a row, 
'			while within each element, the columns are delimited by the delimter argument below.
'
'		Param: sDelimiter| optional|AssumedValue="|"
'		AllowedRange: 
'		Description: The delimiter to use to separate each column value within an array element, which
'			represents a row in the data table..
'
'	Returns: N/A
'
'**********************************************************************
Public Sub xclWSGetAllData(sTable, sWS, asValues, sDelimiter)


	Dim oWS, oApp, oTable, bSheetFound, asHeaders(), iCounter, bColFound, iColIndex, iRowCount, iColCount, i
	Dim sLCaseColArg, sLCaseColTable, sCellValue, iCount, sTableSheetName, asTempHeaders  

	If sDelimiter = "" Then
		sDelimiter = "|"
	End If
	
	iRowCount = xclGetRowCount(sTable, sWS) + 1
	errHandler Err, "xclGetCellValue", g_iSeverity

	iColCount = xclGetColCount(sTable, sWS)
	errHandler Err, "xclGetCellValue", g_iSeverity
	
	Set oApp = CreateObject("Excel.Application")
	
	Set oTable = oApp.Workbooks.Open(sTable)
    
	If sWS = "" Then
		oTable.Sheets(1).Select
	Else
		sWS = LCase(sWS)
		iCount =oTable.Sheets.Count
		FOR i = 1 TO iCount
			sTableSheetName = LCase(oTable.sheets(i).name)
			If sTableSheetName=sWS Then
				oTable.Sheets(i).Select		
				Exit For
			end if
			
		Next 
	End if

	For iRowCounter = 1 to iRowCount 
		ReDim Preserve asValues(iRowCounter - 1)
		For iColCounter = 1 to iColCount
			If iColCounter = iColCount  Then
				asValues(iRowCounter - 1) = asValues(iRowCounter - 1) & oApp.Cells(iRowCounter, iColCounter).Value
			Else'
				asValues(iRowCounter - 1) = asValues(iRowCounter - 1) & oApp.Cells(iRowCounter, iColCounter).Value & sDelimiter
			End If
		Next

	Next
	
	Set oTable = Nothing
	oApp.Quit
	Set oApp = Nothing
  
End Sub

'***********************************************
'   Name: xclIsWorksheetExist
'   Purpose:    This function checks whether a specified worksheet exists in a given workbook.
'
''      Param: sWBook  | required
'       AllowedRange:
'       Description: The filename of the workbook to check in.
'
'       Param: sSheetName | required
'       AllowedRange: any string
'       Description: The name of the worksheet to look for.
'
'   Returns: True if the specified worksheet exists in the given workbook, false otherwise.
'
'**********************************************************************
Public Function xclIsWorksheetExist(sWBook, sSheetName)
   

	Dim oExl, oWB, oWS, bExist

	Set oExl = CreateObject("Excel.application")
	errHandler Err, "xclIsWorksheetExist", g_iSeverity
	oExl.Application.ScreenUpdating = False
	oExl.Application.EnableEvents = False
	Set oWB= oExl.Workbooks.Open(sWBook)
	errHandler Err, "xclIsWorksheetExist", g_iSeverity

    bExist = False

    For Each oWS In oWB.Worksheets
        If StrComp(oWS.Name, sSheetName, 1) = 0 Then
            bExist = True
            Exit For
        End If
    Next

	oExl.Quit
	Set oWB = Nothing
	Set oExl = Nothing

	xclIsWorksheetExist = bExist

End Function


'***********************************************
'   Name: xclIsWorkBookExist
'   Purpose:    This function checks whether a specified WorkBook exists.
'
''      Param: sWBookPath  | required
'       AllowedRange:
'       Description: The Path of file for which existence need to be checked.
'
'   Returns: True if the specified WorkBook exists, false otherwise.
'
'**********************************************************************
Public Function xclIsWorkBookExist(sWBookPath)
   

	Dim objFso, bExist
	
	Set objFso=CreateObject("Scripting.FileSystemObject")
	errHandler Err, "xclIsWorkBookExist", g_iSeverity

    bExist = False
    
    If objFso.FileExists(sWBookPath)  Then
	   bExist = True	
	End If
	errHandler Err, "xclIsWorkBookExist", g_iSeverity	

	Set objFso = Nothing
	
	xclIsWorkBookExist = bExist

End Function

'*****************************************************************************
'Name:    		xclRetrieveData
'Purpose: 		To collect data from Excel worksheet and to load it into array
'              		Each array's element = a string of the entire row's delimited columns
'              		Later (outside of this function) this string will be split into another data-driven array

'Param: 			sFile | required
'AllowedRange:
'Description: 		Excel file to be used for data-driven test
'
'Param: 			sWS | required
'AllowedRange:
'Description: 		The worksheet containing the data. If not provided "Sheet1" will be used
'
'Param: 			asData| required
'AllowedRange:
'Description: 		a number of the array's elements = number of records + header
'             			All non-data containing rows (regardless of their location) are ignored
'
'Param: 			sDelimiter| optional|
'AllowedRange:
'Description: 		to separate each column value within an array element
					'if not provided, "|" will be used

'*****************************************************************************
Public Sub xclRetrieveData(sFile, sWS, ByRef asData, sDelimiter)


    Dim oExl, oWB, iRowCount, iColumnCount, i, j, sRowValue, iBound
    
    If sWS = "" Then sWS = "Sheet1"
    If sDelimiter = "" Then sDelimiter = "|"
     
    Set oExl = CreateObject("Excel.Application")
    'oExl.Visible = True
    Set oWB = oExl.Workbooks.Open(sFile)
    oWB.Sheets(sWS).Activate
    
    'this line will return a real number of rows/columns - any formatted but not data-containing rows will be ignored
    'outside of VB Editor it works if we replace constansts by their numbers
    'iRowCount = oWB.Sheets(sWS).Cells.Find("*", , xlFormulas, , xlByRows, xlPrevious).Row
    iRowCount = oWB.Sheets(sWS).Cells.Find("*", , -4123, , 1, 2).Row
    errHandler Err, "xlcRetrieveData", g_iSeverity
   
    'iColumnCount = oWB.Sheets(sWS).Cells.Find("*", , xlFormulas, , xlByColumns, xlPrevious).Column
    iColumnCount = oWB.Sheets(sWS).Cells.Find("*", , -4123, , 2, 2).Column
    errHandler Err, "xlcRetrieveData", g_iSeverity

    iBound = 0
    ReDim asData(iBound) 'array initialization - very important to avoid type-mismatch!
    For i = 1 To iRowCount
	   'despite this function ignores all formatted rows below last row with a real data,
	   'there are might be some empty rows inside; we will skip them also
        sRowValue =""
        For j = 1 To iColumnCount
           sRowValue = sRowValue & oWB.Sheets(sWS).Cells(i, j).Value
        Next 'j
        If sRowValue <>"" Then
           ReDim Preserve asData(iBound)
           For j = 1 To iColumnCount
			asData(iBound) = asData(iBound) & oWB.Sheets(sWS).Cells(i, j).Value & sDelimiter
		Next 'j
          asData(iBound) = Left(asData(iBound), Len(asData(iBound)) - 1) 'to drop last character (delimiter)
		iBound = iBound +1
	  End if
    Next 'i
     
	'Deactivate Excel objects
	oWB.Close
	oExl.Quit
	Set oWB = Nothing
	Set oExl = Nothing

End Sub

'*************************************************************************************************************************
'	Name:				 xclCopyWorksheet
'	Purpose: 			to copy the existing worksheet within the same workbook
'							   NOTE: before applying this function another function - IsWorksheetExist - should be used
'							   Example:If IsWorksheetExist (sWB, sWS1) and IsWorksheetExist (sWB, sWS2) Then 
'													xlcCopyWorksheet (sWB, sWS1, sTabName, sWS2)
'											  End If
'	Param: 				  sWB | Required 
'	AllowedRange:	  
'	Description:	    holds a workbook name

'	Param: 				  sWS1 | Required 
'	AllowedRange:	  
'	Description:	     holds a worksheet name to be copied

'	Param: 				  sTabName| Required 
'	AllowedRange:	  
'	Description:	   this variable holds name for a copied worksheet  

'	Param: 				  sWS2 | Required 
'	AllowedRange:	  
'	Description:	     designates a worksheet after which a new (copied) worksheet  will be placed   

'	Returns: 			   N/A
'*************************************************************************************************************************
Public Sub xclCopyWorksheet (sWB, sWS1, sTabName, sWS2)


	Dim oExl,oWB, oWS1, oWS2, iCount
	Set oExl = CreateObject("Excel.Application")
	Set oWB = oExl.Workbooks.Open(sWB)
	'oExl.Visible = True
	oExl.DisplayAlerts = False
	
	If sWS1 ="" Then sWS1 = oWB.Worksheets(1).Name
	If sWS2 ="" Then sWS2 = sWS1
	
	Set oWS1 = oWB.Worksheets(sWS1) 'specifies the worksheet we want to be copied
	Set oWS2 = oWB.Worksheets(sWS2) 'specifies the worksheet after which a copied worksheet will be inserted
	
	'before assigning the porvided name lets make sure that the tab with the same name does not exist
	'if it does exist, delete it before renaming a new Tab
	'Example: to save test's results, we create a new tab every time we run a test
	'                as a naming convention, we use today's trimmed date as Tab's name
	'                if we run the test again within the same date, the existing tab will be replaced
	For iCount =1 To oWB.Worksheets.Count
		If LCase(oWB.Worksheets(iCount).name) = LCase(sTabName) Then
			owb.worksheets(iCount).Delete
			Exit For
		End If
	Next
	'next line copies the specified sWS1 worksheet and inserts it after sWS2
	'if sWS1=sWS2 then new worksheet is inserted right next to it
	oWS1.Copy, oWS2
	
	'a new tab (copied worksheet) will be ActiveSheet automatically
	oWB.ActiveSheet.Name = sTabName
	
	'Deactivate Excel objects
	oWB.Save
	oWB.Close: oExl.Quit
	Set oWB = Nothing
	Set oWS1 = Nothing
	Set oWS2 = Nothing
	Set oExl = Nothing

End Sub

'**********************************************************************
'	Name:  xclSaveFileAs
'	Purpose:  This function will open an Excel document and save it as CSV.
'
'		Param: sWorkbook|required
'		AllowedRange:
'		Description: The path and file name of the Excel sheet.
'
'		Param: sType|required
'		AllowedRange: csv, xml, xls, xlsx
'		Description: The type of file you want to save the workbook as.
'
'	Returns: N/A
'**********************************************************************
Public Function xclSaveFileAs(sWorkbook, sType)
	

	Dim oExl,oWB, oFSO
	Dim sFileName, sNewFileName, iType

	sWorkbook = Trim(sWorkbook)
	sType = Trim(sType)

	sFileName = Left(sWorkbook, InstrRev(sWorkbook, ".") )

	'XlFileFormat Enumeration resource http://msdn.microsoft.com/en-us/library/bb241279(v=office.12).aspx
	Select Case LCase(sType)
		Case "xml"
			iType = 46
			sNewFileName = sFileName & "xml"
		Case "xls"
			iType = 56
			sNewFileName = sFileName & "xls"
		Case "xlsx"
			iType = 51
			sNewFileName = sFileName & "xlsx"
		Case "csv"
			iType = 6
			sNewFileName = sFileName & "csv"
		Case Else
			Err.Number = g_lINVALID_ARG
			Err.Description = "File type " & sType & " not supported." 
			errHandler Err,"xclSaveFileAs",micFail
			Exit Function
	End Select

	Set oFSO = CreateObject("Scripting.FileSystemObject")
	Set oExl = CreateObject("Excel.Application")
	
	If oFSO.FileExists(sWorkbook) Then
		Set oWB = oExl.Workbooks.Open(sWorkbook)
		errHandler Err, "xclSaveFileAs", micFail

		oExl.Visible = False
		errHandler Err, "xclSaveFileAs", g_iSeverity

		oExl.DisplayAlerts = False
		errHandler Err, "xclSaveFileAs", g_iSeverity

		oWB.SaveAs sNewFileName, iType
		errHandler Err, "xclSaveFileAs", micFail

		oWB.Close
		oExl.Quit

	    Set oWB = Nothing
	    Set oExl = Nothing
	Else
		Err.Number=g_iITEM_NOT_FOUND
		Err.Description= sWorkbook & " is not found."
		errHandler Err, "xclSaveFileAs", micFail
		Exit Function
	End If

	Set oExl = Nothing
	Set oFSO = Nothing

	xclSaveFileAs = sNewFileName

End Function

'***********************************************
'   Name: xclODBCConnection
'   Purpose:    This function open ODBC connection with the spedified excel file as data source.
'
'       Param: sDataSource | required
'       AllowedRange: 
'       Description: Excel file path as data source.
'
'		Param: cnConnect| required
'		AllowedRange: 
'		Description:Connection object to connect to excel datasheet
'
'   Returns:  N/A
'**********************************************************************
Public Sub xclODBCConnection(cnConnect, sDataSource)
	
	Dim sConn
	
	Set cnConnect = CreateObject("ADODB.Connection")
	errHandler Err, "xclODBCConnection", g_iSeverity	
	sConn = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & sDataSource & ";Extended Properties=""Excel 8.0;HDR=Yes;IMEX=1"";"		
	cnConnect.Open sConn 	
	errHandler Err, "xclODBCConnection", g_iSeverity
End Sub

'***********************************************
'   Name: xclODBCCSVConnection
'   Purpose:    This function open ODBC connection with the spedified folder containing CSV files as data source.
'
'		Param: sDataSource | required
'		AllowedRange: 
'		Description: Folder path as data source.
'
'		Param: cnConnect| required
'		AllowedRange: 
'		Description:Connection object to connect to excel datasheet
'
'   Returns:  N/A
'**********************************************************************
Public Sub xclODBCCSVConnection(cnConnect, sDataSource)
	
	Dim sConn
	
	Set cnConnect = CreateObject("ADODB.Connection")
	errHandler Err, "xclODBCCSVConnection", g_iSeverity	
	sConn = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & sDataSource & ";Extended Properties=""text;HDR=Yes;FMT=Delimited"";"		
	cnConnect.Open sConn 	
	errHandler Err, "xclODBCCSVConnection", g_iSeverity
End Sub

'***********************************************
'   Name: xclInsertData
'   Purpose:    This sub inserts data in the columns mentioned
'
'       Param: sDataSource | required
'       AllowedRange: 
'       Description: Excel file path as data source.
'
'       Param: sSheetName | required
'       AllowedRange: 
'       Description: The sheetname to insert data into.
'
'       Param: sColumns | required
'       AllowedRange: 
'       Description: Fields or columns of the excelsheet seperated by a comma
'
'		Param: sValues| required
'		AllowedRange: 
'		Description:Values that need to be inserted in to the respective columns
'							seperated by a comma
'
'   Returns:  N/A
'
'**********************************************************************
Public Sub xclInsertData(sDataSource,sSheetName,sColumns,sValues)


	Dim cn, sConStr, sInsSql
   ' Get the connection
	Set cn = CreateObject("ADODB.Connection")
	sConStr = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & sDataSource & ";Extended Properties=""Excel 8.0;HDR=Yes;"";"
	cn.Open sConStr

	sInsSql = "Insert Into [" & sSheetName &"$] " & "(" & sColumns & ") Values (" & sValues & ")"

	cn.Execute sInsSql
	errHandler Err, "xclInsertData", g_iSeverity

    cn.Close
	Set cn = Nothing

End Sub
'***********************************************
'   Name: xclColHeadersVerify
'   Purpose:    This sub verifies columns in specified Excel Worksheet
'
'       Param: sHeaders | required
'       AllowedRange: Exp.: "ID|Name|Age"
'       Description: This is pipe delimited Expected Columns Headers.
'
'       Param: sWS | required
'       AllowedRange: 
'       Description: This is worksheet to check.
'
'       Param: sFileName | required
'       AllowedRange: Ex. "C:\Testware\Apps\RVE\Data\Downloads\Step 17\Blank_Template 2012_08_31.xls"
'       Description: This is File path including file name to the Excel doc to verify columns.
'
'   Returns:  N/A
'
'**********************************************************************
Public Sub xclColHeadersVerify(sHeaders, sWS, sFileName)
	

	Dim asColHeaders,asHeaders, iHCtr, iCHCtr, bFound,sFile, sHeader
	' Resaving the file as xls format.
	sFile =  xclSaveFileAs(sFileName, "xls")
	asHeaders = Split(sHeaders,"|")
	'Get Columns Headers from Excel
	asColHeaders = xclGetColHeaders(sFile, sWS)
	bFound=FALSE
		For iHCtr=0 to Ubound(asHeaders)
			sHeader = Replace(asHeaders(iHCtr)," ","")
			bFound = utArrayValueExists(asColHeaders,sHeader)
			If bFound=TRUE Then
				LogText "VERIFIED: Column """ & asHeaders(iHCtr) & """ is available on the worksheet """ & sWS &""" as expected."
			End If
			If bFound=FALSE Then
				Err.Description="Column """ & asHeaders(iHCtr) & """ is NOT available on the worksheet """ & sWS &"""."
				Err.Number=g_iVERIFICATION_FAILED
				errHandler Err,"xclColHeadersVerify",g_iSeverity
			End If
		Next
	winDeleteAFile sFile
End Sub
'***********************************************
'   Name: xclWorksheetsVerify
'   Purpose:    This sub verifies Worksheets are available in specified Excel Worksheet.
'
'       Param: sWS | required
'       AllowedRange:  Example:"Cover|Analytes"
'       Description: This is pipe delimited names of worksheets to verify in Workbook.
'
'       Param: sFileInZip | required
'       AllowedRange: Ex. "C:\Testware\Apps\RVE\Data\Downloads\Step 17\Blank_Template 2012_08_31.xls"
'       Description: This is File path including file name to the Excel doc to verify columns.
'
'   Returns:  N/A
'
'**********************************************************************
Public Sub xclWorksheetsVerify(sWS,sFileInZip)


	Dim  sText,asText,iCtr,asWS,bFound,sFile

	sFile=xclSaveFileAs(sFileInZip, "xls")

	asWS=split(sWS,"|")
	sText= xclSheetNamesGet(sFile)
	asText=split(sText,"|")
	bFound=False

	For iCtr=0 to Ubound(asWS)
		bFound = utArrayValueExists(asText,asWS(iCtr))
		If bFound=TRUE Then
    		LogText "VERIFIED: """ & asWS(iCtr) & """ is available in the Excel document: "& sFile & " as expected." 
    	Else
			Err.Description=""""& asWS(iCtr) & """ is NOT available in the Excel document: "& sFile
			Err.Number=g_iVERIFICATION_FAILED
			errHandler Err,"xclWorksheetsVerify",g_iSeverity
		End If
	Next

	winDeleteAFile sFile
End Sub

'*********************************************************************************************
'	 Name: xclWorkSheetCompare
'	 Purpose: This sub compares two excel sheets and highlights the differences
'
'	Param: sActual|required
'	AllowedRange: 
'	Description: Path to the workbook with the actual results
'
'	Param: sExpected|required
'	AllowedRange:
'	Description: Path to the workbook with the expected results
'
'	Param: sWs|required
'	AllowedRange:
'	Description: Worksheet in excel workbook to open
' 	Returns: N/A 
'*************************************************************************************************
Public sub xclWorkSheetCompare(sActual, sExpected,sWs)
	
	Dim oExcel, oWorkbookActual, oWorkbookExpected
	Dim iSheet1Value, iSheet2Value

	'Open actual
	Set oExcel = createObject("Excel.Application")
	errHandler Err, "xclWorkSheetCompare", g_iSeverity
	Set oWorkbookActual = oExcel.Workbooks.Open(sActual)
	errHandler Err, "xclWorkSheetCompare", g_iSeverity
			oExcel.DisplayAlerts = False
			oExcel.Sheets(sWs).Select
			oExcel.Sheets(sWs).Columns.AutoFit()
			oExcel.Visible=False
			iColCount = xclGetColCount(sActual, sWs)
			iRowCount = xclGetRowCount(sActual, sWs)
	'Open expected
	Set oExcel2 = createObject("Excel.Application")
	errHandler Err, "xclWorkSheetCompare", g_iSeverity
	Set oWorkbookExpected = oExcel2.Workbooks.Open(sExpected)
	errHandler Err, "xclWorkSheetCompare", g_iSeverity
			oExcel2.DisplayAlerts = False
			oExcel2.Sheets(sWs).Select
			oExcel2.Sheets(sWs).Columns.AutoFit()
			oExcel2.Visible = False
			iColCount2 = xclGetColCount(sExpected, sWs)
			iRowCount2 = xclGetRowCount(sExpected, sWs)

	'Get highest Col and Row counts
		If iColCount > iColCount2 Then
				iColCount = iColCount
			Else
				iColCount = iColCount2
		End If
		If iRowCount > iRowCount2 Then
				iRowCount = iRowCount
			Else
				iRowCount = iRowCount2
		End If


	For iCol = 1 To iColCount
		For iRow = 1 To iRowCount
		 iSheet1Value = Trim(LCase(oExcel.Cells(iRow,iCol)))
		 iSheet2Value = Trim(Lcase(oExcel2.Cells(iRow,iCol)))
				If LCase(Trim(iSheet1Value)) <> LCase(Trim(iSheet2Value)) Then
					oExcel.Cells(iRow,iCol).Interior.ColorIndex=3 'Set background colour of differing cells to RED
					else
					oExcel.Cells(iRow,iCol).Interior.Colorindex=0
				End If
		Next
	Next

	oExcel.DisplayAlerts = False
	oExcel2.DisplayAlerts = False
	oExcel.ActiveWorkbook.Save
	errHandler Err, "xclWorkSheetCompare", g_iSeverity
	oExcel2.ActiveWorkbook.Save
	errHandler Err, "xclWorkSheetCompare", g_iSeverity
	oExcel.Quit
	oExcel2.Quit
End Sub
'***********************************************
'   Name: xclRowCountVerify
'   Purpose:    This sub verifies number of  rows with data on specified Worksheets(excluding Header).
'
'       Param: sWSCount | required
'       AllowedRange:  Example: "Analytes:0|ClinicalSignificanceCodes:>0"
'		Valid Values fot the Count part: any number of ">0" if you are checking that worksheet contains data.
'       Description: This is pipe delimited values of  <Worksheet Name>: <Row Count> to verify in Workbook.
'
'       Param: sFileInZip | required
'       AllowedRange: Ex. "C:\Testware\Apps\RVE\Data\Downloads\Step 17\Blank_Template 2012_08_31.xls"
'       Description: This is File path including file name to the Excel doc to verify row count.
'
'   Returns:  N/A
'
'**********************************************************************
Public Sub xclRowCountVerify(sWSCount, sFileInZip)
	
    Dim asElements, iCtr, sRowCount,sCount,sWS,sFile

	sFile =xclSaveFileAs(sFileInZip, "xls")

	asElements=split(sWSCount,"|")
	For iCtr=0 to Ubound(asElements)
        sWS=split(asElements(iCtr),":")(0)

        If UBound(split(asElements(iCtr),":"))=1 Then
			sCount=split(asElements(iCtr),":")(1)
		Else
			sCount="0"
		End If
		'Get Row count for the specified Worksheet
		sRowCount=Cint(xclGetRowCount(sFile,sWS))

		If sCount=">0" and  sRowCount >1Then
			LogText "VERIFIED: """ & sWS & """ contains some data: " & sRowCount -1 & " rows with data. As expected."
		ElseIf cInt(sCount)=sRowCount-1 Then
			LogText "VERIFIED: """ & sWS & """ contains: " & sRowCount -1 & " rows with data. As expected."
		End If
	Next

	winDeleteAFile sFile
End Sub

'**********************************************************************
'	Name:  xclSheetNamesGet
'	Purpose:This function returns the names of all the existing worksheet of the excel.
'	
'		Param: sXLFileName | required 
'		AllowedRange: 
'		Description: The name of the excel book including the path
'
'	Returns: The table's row count.
'**********************************************************************
Public Function xclSheetNamesGet(sXLFileName)


	Dim oExcel, oWBook ,oWSheet,sFileName, sSheetNames

	sSheetNames = ""

	Set oExcel = CreateObject("Excel.Application")
	errHandler Err, "xclSheetNamesGet", g_iSeverity

	Set oWBook = oExcel.Workbooks.Open(sXLFileName)
	errHandler Err, "xclSheetNamesGet", g_iSeverity
	
	For Each oWSheet In oWBook.Worksheets
 		 If sSheetNames = "" Then
			 sSheetNames = oWSheet.Name
		 Else
   			sSheetNames = sSheetNames & "|" & oWSheet.Name
		 End If
    Next
oExcel.Close(False)
'    oExcel.Quit
	Set oExcel = Nothing

	xclSheetNamesGet = sSheetNames
	
End Function

'***********************************************
'   Name: xclCellValueVerify
'   Purpose:    This sub verifies cell value in Excel file in specified worksheet.
'
'       Param: sFile | required
'       AllowedRange: Ex. "C:\Testware\Apps\RVE\Data\Downloads\Step 17\Blank_Template 2012_08_31.xls"
'       Description: This is File path including file name to the Excel doc to verify row count.
'
' 		Param: iRow | required
' 		AllowedRange:  number
' 		Description: This is Row number for the cell to verify value.
'
' 		Param: vCol | required
' 		AllowedRange:  number or letter.
'					Example: "1" or "A"
' 		Description: This is Column name(number or letter) for the cell to verify value.
'
' 		Param: sWS | required
' 		AllowedRange:  
' 		Description: This is Worsheet name.
'
' 		Param: sExpVal | required
' 		AllowedRange:  
' 		Description: This is Expected cell value.
'
'   Returns:  N/A
'
'**********************************************************************
Public Sub xclCellValueVerify(sFile, iRow, vCol, sWS, sExpVal)
   
	Dim sValue

	iRow=CInt(iRow)

	If IsNumeric(vCol) Then
		vCol=cInt(vCol)
	End If

    sValue=xclGetCellValue(sFile, iRow,vCol,sWS)
	errHandler Err, "xclCellValueVerify", g_iSeverity

	If Lcase(sValue)=Lcase(sExpVal) Then
		LogText "VERIFIED: Cell contains value: """ & sValue & """ as expected."
	Else
		Err.Description="Cell contains value: """ & sValue & """. Expected value is """ & sExpVal &  """."
		Err.Number=g_iVERIFICATION_FAILED
		errHandler Err, "xclCellValueVerify", g_iSeverity
	End If

End Sub

'**********************************************************************
'	Name: xclWorksheetClear
'	Purpose:	This function will clear the content of an Excel worksheet. 
'	
'		Param: sWorkbook
'		AllowedRange: 
'		Description: The filename of the excel workbook.
'
'		Param: sWorksheet
'		AllowedRange: 
'		Description: The name of the worksheet to clear. If empty, the first sheet will be used.
'
'		Param: iHeaderRowsToKeep
'		AllowedRange: 
'		Description: The number of rows at the top of the sheet to preserve when clearing the sheet.
'
'	Returns: N/A
' 
'**********************************************************************
Public Sub xclWorksheetClear(sWorkbook, sWorksheet, iHeaderRowsToKeep)
	

	Dim oApp, oWorkbook, oSheet, oCells
	Dim sTableSheetName, iNumSheets, iCounter
	
	Set oApp = CreateObject("Excel.Application")
	errHandler Err, "xclWorksheetClear", g_iSeverity

	Set oWorkbook = oApp.Workbooks.Open(sWorkbook)
	errHandler Err, "xclWorksheetClear", g_iSeverity

	 If sWorksheet = "" Then
		Set oSheet = oWorkbook.Sheets(1)
		errHandler Err, "xclWorksheetClear", g_iSeverity
	Else
		sWorksheet = LCase(sWorksheet)
		iNumSheets = oWorkbook.Sheets.Count
		FOR iCounter = 1 TO iNumSheets
			sTableSheetName = LCase(oWorkbook.sheets(iCounter).name)
			If sTableSheetName = sWorksheet Then
				Set oSheet = oWorkbook.Sheets(iCounter)	
				errHandler Err, "xclWorksheetClear", g_iSeverity
				Exit For
			end if
		Next 
	End if

	If iHeaderRowsToKeep > 0 Then
		Set oCells = oSheet.Cells.Resize(oSheet.Cells.Rows.Count - iHeaderRowsToKeep).Offset(iHeaderRowsToKeep)
		errHandler Err, "xclWorksheetClear", g_iSeverity
	Else
		Set oCells = oSheet.Cells
		errHandler Err, "xclWorksheetClear", g_iSeverity
	End If

	oCells.Clear
	errHandler Err, "xclWorksheetClear", g_iSeverity

	Set oCells = Nothing
	Set oSheet = Nothing
	oWorkbook.Save
	Set oWorkbook = Nothing
	oApp.Quit
	Set oApp = Nothing
End Sub


'**********************************************************************
'	Name: xclGetNamedRangeValues
'	Purpose:	This function returns a string of the values in a named range in an Excel workbook.
'		The values are returned in the format where the rows are delimited by a 'vbcrlf', and the values
'		within the rows are delimited by a delimiter that is passed in.  If the delimiter argument is 
'		an empty string, the delimiter will default to the pipe ('|') delimiter.
'	
'		Param: oWorkbook|required
'		AllowedRange: 
'		Description: The excel workbook object that has the named range.
'
'		Param: sRange|required
'		AllowedRange: 
'		Description: The named range whose values are to be retrieved.
'
'		Param: sDelim|optional|AssumedValue="|"
'		AllowedRange: 
'		Description: The delimiter to use.
'
'	Returns: N/A
' 
'**********************************************************************
Public Function xclGetNamedRangeValues(oWorkbook, sRange, sDelim)
	Dim colNames, iCtr, oRange, sVals, sRows,sTempVal	
	Dim iRngCtr, iColCtr
	If sDelim = "" Then
		sDelim = "|"
	End If
	
	Set colNames = oWorkbook.Names
	
	For iCtr = 1 To colNames.Count

		If LCase(sRange) = LCase(colNames(iCtr).Name) Then
			Set oRange = oWorkbook.Application.Range(colNames(iCtr).Name)

			'Set oRange = oWorkbook.Range(colNames(iCtr).Name)
			
			sVals = ""	
			For iRngCtr = 1 To oRange.Rows.Count
				For iColCtr = 1 To oRange.Columns.Count
					If sVals = ""  Then
						sVals = utTrimAll(oRange.Cells(iRngCtr, iColCtr).Value2)			
					Else
						sVals = sVals & sDelim & utTrimAll(oRange.Cells(iRngCtr, iColCtr).Value2)
					End If
					If iColCtr > 1000 Then
						print "MORE THAN 1000 COLUMNS!!!!"
						Exit For
					End If
									
				Next
				If iRngCtr > 5000 Then
					print "MORE THAN 5000 ROWS!!!!"
					Exit For
				End If
				If sRows = "" Then
					sRows = sVals
				Else
					sRows = sRows & vbcrlf & sVals
				End If
				sVals = ""
			Next
		End IF		
	Next
	
	xclGetNamedRangeValues = sRows
End Function
'**********************************************************************
'	Name: xclGetColumnLetter
'	Purpose:This function returns Correspodning Column letter for provided column position.
'		
'		Param: intColumnNumber
'		AllowedRange:
'		Description: The column position whose corresponding Column letter is to be retrieved.
'
'	Returns: Column letter 
'**********************************************************************

Public Function xclGetColumnLetter(ByVal intColumnNumber)
    Dim sResult
    
    intColumnNumber = intColumnNumber - 1
    
    If (intColumnNumber >= 0 And intColumnNumber < 26) Then
        sResult = Chr(65 + intColumnNumber)
    ElseIf (intColumnNumber >= 26) Then
        sResult = xclGetColumnLetter(CLng(intColumnNumber \ 26)) _
                & xclGetColumnLetter(CLng(intColumnNumber Mod 26 + 1))
    Else
      Err.Number=g_lINVALID_ARG      
      Err.Description = "Invalid Column #" & CStr(intColumnNumber + 1)
	  errHandler Err,"xclGetColumnLetter",micFail     
    End If
    xclGetColumnLetter = sResult
End Function


'**********************************************************************
'	Name: xclGetColumnPosition
'	Purpose:This function returns Correspodning Column Position for provided column letter .
'		
'		Param: sColumn
'		AllowedRange:
'		Description: The column whose corresponding Column Position is to be retrieved.
'
'	Returns: Column Position
'**********************************************************************

Public Function xclGetColumnPosition(sColumn)
	
	Dim iColumnPos,iCtr      	
	sColumn = UCase(sColumn)
	
	If Len(sColumn)>0 Then 		
		For iCtr = 1 To Len(sColumn) 
			iColumnPos = iColumnPos +((Asc(Mid(sColumn,iCtr,1)) - 64) * (26 ^ (Len(sColumn) - iCtr)))
		Next     
	Else
		Err.Number=g_lINVALID_ARG      
		Err.Description = "Invalid Column" & sColumn
		errHandler Err,"xclGetColumnPosition",micFail 
	End If	
	
	xclGetColumnPosition = iColumnPos
End Function
  
'**********************************************************************
'    Name: xclGetSheetRecords
'    Purpose: This function returns Corresponding records from given sheet
'             for provided conditions.
'
'        Param: sColumnName|Optional|Assumedvalue = All Columns
'        AllowedRange: 
'        Description:column name to retrieve the value from.
'				 multiple columns name are separated by comma "," .
		
'        Param: sCondColName|required 
'        AllowedRange:
'        Description:column name to which conditions applied. 
'				 multiple Condtion columns name are separated by Pipe "|".

'        Param: sCondColValue|required 
'        AllowedRange:
'        Description:column value for column to which conditions applied. 
'				multiple Condtion columns values are separated by Pipe "|".

'        Param: sSheetName|required 
'        AllowedRange:
'        Description:master sheet name to retrieve the value from
'

'        Param: sExcelPath|required 
'        AllowedRange:
'        Description:Excel sheet location  
'
'    Returns: Correspodning records from given sheet
'             for provided conditions .
'**********************************************************************

Public Function xclGetSheetRecords(ByVal sColumnName,ByVal sCondColName,ByVal sCondColValue,ByVal sSheetName,sExcelPath)
	
	Dim oConnection, oRecordSet ,asCondColName,asCondColValue
	Dim sQuery,ictr
	
	Set oConnection = CreateObject("ADODB.Connection")
	Set oRecordSet = CreateObject("ADODB.Recordset")
	
	oConnection.ConnectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" & sExcelPath & ";Extended Properties=""Excel 12.0;IMEX=1"";"
	
	oConnection.Open
	
	If sColumnName="" Then         
		If sCondColValue=""  Then
			sQuery="Select * FROM ["& sSheetName &"$] " 		
		Else
			
			
			asCondColName=Split(sCondColName,"|") 
			asCondColValue=Split(sCondColValue,"|")	    
			
			
			If IsNumeric(asCondColValue(0)) Then  	
				
				sQuery="Select * FROM ["& sSheetName &"$] Where " & asCondColName(0) & "=" & asCondColValue(0)&""  					
			Else	
				sQuery="Select * FROM ["& sSheetName &"$] Where " & asCondColName(0) & "='" & asCondColValue(0)& "'"								
			End If 
			
			
			
			For ictr =1 To Ubound(asCondColName)						
				
				If IsNumeric(asCondColValue(ictr)) Then						
					sQuery=sQuery & " and " &  asCondColName(ictr) & " = "&asCondColValue(ictr) & ""						
				Else					
					sQuery=sQuery & " and " &  asCondColName(ictr) & "='" &asCondColValue(ictr) & " ' "					
				End If
				
			Next
			
		End If 	
		
		oRecordSet.Open sQuery, oConnection,1, 3
		Set xclGetSheetRecords = oRecordSet        
	Else
		If sCondColValue="" Then
			
			sQuery="Select " & sColumnName & " FROM ["& sSheetName &"$]"	        
			
		Else	
			asCondColName=Split(sCondColName,"|") 
			asCondColValue=Split(sCondColValue,"|")	    
			
			If IsNumeric(asCondColValue(0)) Then  	
				
				sQuery="Select " & sColumnName & " FROM ["& sSheetName &"$] Where " & asCondColName(0) & "=" & asCondColValue(0)&""        					
			Else	
				sQuery="Select " & sColumnName & " FROM ["& sSheetName &"$] Where " & asCondColName(0) & "='" & asCondColValue(0)& "'"								
			End If 
			
			
			For ictr =1 To Ubound(asCondColName)						
				
				If IsNumeric(asCondColValue(ictr)) Then						
					sQuery=sQuery & " and " &  asCondColName(ictr) & " = "&asCondColValue(ictr) & ""						
				Else					
					sQuery=sQuery & " and " &  asCondColName(ictr) & "='" &asCondColValue(ictr) & " ' "					
				End If
				
			Next        	
			
		End If
		
		
		oRecordSet.Open sQuery,oConnection,1, 3                     
		
		If oRecordSet.RecordCount>1 Then			
			Set xclGetSheetRecords=	oRecordSet
		ElseIf Instr(sColumnName,",")>1 Then           
			Set xclGetSheetRecords= oRecordSet 
		Else	
			xclGetSheetRecords=oRecordSet(0).Value
		End If
		
	End if 
End Function 

'**********************************************************************
'	Name: xclCreateExcel
'	Purpose: This sub will Create an Excel and Paste the data into the Excel.
'
'		Param:  sData | Required
'		AllowedRange: 
'		Description: Data to be pasted in Excel
'
'		Param:  sExcelPath | Required
'		AllowedRange: 
'		Description: Path of the Excel File to be created
'
'	Returns: N/A
'**********************************************************************

Public Sub xclCreateExcel(ByVal sData,ByRef sExcelPath)
	
	Dim oExcel, oExlSheet,objCB,bExists
	
		Set oExcel = CreateObject("excel.application")
		errHandler Err,"xclCreateExcel",g_iSeverity
		
		Set objCB = DotNetFactory.CreateInstance("System.Windows.Forms.Clipboard","System.Windows.Forms") 
		
'		Set objCB= CreateObject("Mercury.Clipboard")
'		errHandler Err,"xclCreateExcel",g_iSeverity
'		
		objCB.Clear
		errHandler Err,"xclCreateExcel",g_iSeverity	
		
		objCB.SetText sData
		errHandler Err,"xclCreateExcel",g_iSeverity

		bExists =  xclIsWorkBookExist(sExcelPath)
		errHandler Err,"xclCreateExcel",g_iSeverity
		
		If bExists Then
			winDeleteAFile sExcelPath
			errHandler Err,"xclCreateExcel",g_iSeverity
		End If	
			
		oExcel.Application.Visible = true 
		errHandler Err,"xclCreateExcel",g_iSeverity
			
		oExcel.Workbooks.Add
		errHandler Err,"xclCreateExcel",g_iSeverity
		
		Set oExlSheet = oExcel.ActiveWorkbook.Worksheets("Sheet1")
		errHandler Err,"xclCreateExcel",g_iSeverity
		
		
		oExlSheet.Range("A1").Select
		errHandler Err,"xclCreateExcel",g_iSeverity
		
		oExlSheet.Paste
		errHandler Err,"xclCreateExcel",g_iSeverity
			
		oExlSheet.Cells.UnMerge
		errHandler Err,"xclCreateExcel",g_iSeverity
		
		oExlSheet.Cells.WrapText = False
		errHandler Err,"xclCreateExcel",g_iSeverity
			
		oExcel.ActiveWorkbook.SaveAs sExcelPath
		errHandler Err,"xclCreateExcel",g_iSeverity
			   
		oExcel.Application.Quit
		errHandler Err,"xclCreateExcel",g_iSeverity
	
	Set oExlSheet = Nothing
	
	Set objCB = Nothing
	
	Set oExcel = Nothing
	
End Sub


'**********************************************************************
'    Name: xclValidNameRangeCheck
'    Purpose: This sub returns  True/False if the provided Name range is present & valid .
'	
'    Param: oWorkbook | required
'    AllowedRange:  
'    Description:  The excel workbook object to add the name range from.

'    Param: sRangeName  | required
'    AllowedRange:  
'    Description:  name range is to be verified.


'    Returns: returns  True/False if the provided Name range is present & valid . .
'**********************************************************************

Public Function xclValidNameRangeCheck(oWorkBook,sRangeName)


Dim oName,sRange,oWorksheet,bFound
Dim iRowCount,iColcount,iRowCtr,iColCtr
Dim sVal,iGridCtr,sColumn,sRngVal

On Error Resume Next

bFound=False


	For Each oName In oWorkBook.Names

		If Trim(oName.Name) =Trim(sRangeName) Then  

			bFound=true

			Exit For

		End if 
	Next  



	If bFound Then
		sRngVal = oWorkBook.Application.Range(sRangeName).Value
			
			If Err.Number = 1004 Then
				bFound=False
				Err.Clear()
			ElseIf Err.Number = 0 Then
				bFound=True
			End If
	End If

xclValidNameRangeCheck=bFound
End Function 

'**********************************************************************
'	Name: xclGetRowNumber
'	Purpose: This sub will Create an Excel and Paste the data into the Excel.
'
'		Param:  sExcelPath | Required
'		AllowedRange: 
'		Description: Path of the Excel File in which Value to be Searched
'
'		Param:  sWorkSheet | Required
'		AllowedRange: 
'		Description: WorkSheet in which Value to be Searched
'
'		Param:  sValue | Required
'		AllowedRange: 
'		Description: Value to be searched in Excel
'
'		Param:  sRowNum | Required
'		AllowedRange: 
'		Description: Row Number Variable Passed to get the Row Number of Value
'
'	Returns: N/A
'**********************************************************************
Public Sub xclGetRowNumber(sExcelPath,sWorkSheet,sValue,ByRef sRowNum)
	
	
	Dim oExcel, oExlSheet,objCB
	
	Set oExcel = CreateObject("excel.application")
	
	oExcel.Workbooks.Open sExcelPath
		
	oExcel.Application.Visible = False 
		
	Set oExlSheet = oExcel.ActiveWorkbook.Worksheets(sWorkSheet)
	
	sRowNum = oExlSheet.UsedRange.Find(sValue).Row
		
	oExcel.ActiveWorkbook.Save
		   
	oExcel.Application.Quit
	
	Set oExlSheet = Nothing
	Set objCB = Nothing
	Set oExcel = Nothing
	
End Sub


'************************************************************************************
'    Name: xclActivate     
'    Purpose: This Sub will get activate the excel object .
'
'    Returns: N/A.
'************************************************************************************	
Public Sub xclActivate()

	Dim oShell, WMI, wql, process
	Set oShell = CreateObject("WScript.Shell") 

	Set WMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")

	wql = "SELECT ProcessId FROM Win32_Process WHERE Name = 'EXCEL.EXE'"

	For Each process In WMI.ExecQuery(wql)

	oShell.AppActivate (process.ProcessId)

	Next

	Set oShell=Nothing
	Set WMI=Nothing

End Sub
	
	
	

'**********************************************************************
' Name: xclCheckExcelOpenstatus
' Purpose: This Sub will return the status of the excel which is open or not.
'
' Param: sExcelName
' AllowedRange:
' Description: Excel Name
'
' Returns:Status
'**********************************************************************
Public Function xclCheckExcelOpenstatus(sExcelName)
		
	Dim objWord,colTasks,iCnt,sArrFilename,sFilename
	
	Set objWord = CreateObject("Word.Application")
	Set colTasks = objWord.Tasks
	iCnt = 0
	sArrFilename = Split(sExcelName,"\")
	sFilename =sArrFilename(Ubound(sArrFilename)) 
	
	For Each objTask in colTasks
	    strName = LCase(objTask.Name)
	    If Instr(strName, lCase(sFilename)) Then
	        iCnt = 1
	        Exit For
	    End If
	Next
	
	objWord.Quit
	
	xclCheckExcelOpenstatus = iCnt
	
	Set objWord = Nothing
	Set colTasks = Nothing

End Function





Public Sub xclWriteRecordsToCell(sExcelFullPath, sSheetName, sResColHdr, sResConVal, sDesColHdr, sDesColVal)
		Set oExcel = CreateObject("Excel.Application")
		oExcel.Workbooks.Open sExcelFullPath
		oExcel.Application.Visible = True
		
		Set oMysheet = oExcel.ActiveWorkbook.Worksheets(sSheetName)
		
		iRowCount = oMysheet.usedRange.Rows.Count
		iColCount = oMysheet.usedRange.Columns.Count
		
		For iDesCol = 1 To iColCount Step 1
			sVal = oMysheet.Cells(1,iDesCol).Value
			If Ucase(Trim(sVal)) = Ucase(Trim(sDesColHdr)) Then
				Exit For
			End If
		Next
		
		For iResCol = 1 To iColCount Step 1
			sVal = oMysheet.Cells(1,iResCol).Value
			If Ucase(Trim(sVal)) = Ucase(Trim(sResColHdr)) Then
				Exit For
			End If
		Next
		
		For iDesRow = 1 To iRowCount Step 1
			sVal = oMysheet.Cells(iDesRow,iResCol).Value
			If Ucase(Trim(sVal)) = Ucase(Trim(sResConVal)) Then
				Exit For
			End If
		Next
		
		oMysheet.Cells(iDesRow,iDesCol).Value = sDesColVal
		
		oExcel.ActiveWorkbook.Save
		
		oExcel.Quit
		Set oMysheet = Nothing
		Set oExcel = Nothing

End Sub
