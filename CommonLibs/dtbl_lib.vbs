Option Explicit
'*************************** MAINTAIN THIS HEADER! *********************************
'     Library Name:     dtbl_lib.vbs
'     Purpose:          Contains functions related to the data table object.
'
'--------------------------------------------------------------------------------
'
'    Copyright (c) 2011-2016 by Moody's Corp.
'    Confidential - All Rights Reserved
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

'************************************************************************************************************
'                                PUBLIC FUNCTIONS
'************************************************************************************************************

'**********************************************************************
'   Name:    dtblDataImport
'   Purpose:This sub imports the data from Database or excel file to QTP Datatable.
'   Creator: Lavanya Bathina
' 
'		Param: sType| required 
'		AllowedRange: "Access", "SQL Server", "Oracle","excel"
'		Description: The type of connection.
'
'		Param: sServer| required
'		AllowedRange: 
'		Description: The server the database resides on.  For Access connections, this should
'								 be passed as an empty string. Required  when the sType value is other than excel
'
'		Param: sDBName| required 
'		AllowedRange: 
'		Description: The database to access.  For Access, this should be the full path to the .mdb file.
'								Excel file will be created dynamically with the given database name in the Application's 'Data' folder of the Testware.
'								When the sType value is excel,  The Excel file name with full path to be specified.
'
'		Param: sUser| optional|AssumedValue="" 
'		AllowedRange: 
'		Description: The user to use for the connection.  If the connection doesn't need a user,
'								 pass an empty string..
'
'		Param: sPW| optional|AssumedValue="" 
'		AllowedRange: 
'		Description: The password for the user.  If the connection doesn't need a user or a 
'								 password, pass an empty string.
'
'		Param: sSourceSheetName|optional|AssumedValue=""
'		AllowedRange: 
'		Description: Name of the Source sheet. 
'								Required when the sType value is excel, the sSourceSheet can be "All" indicating to import all the sheets.
'								or if specified sheets are to be imported, then corresponding destination sheet name to be specified in sDestinationSheet in the same order. 
'								If the destination sheet does not exist then a sheet of the specified name is created.
'								if more than one sheet are to be imported separate them with ","
'								Blank when sType is not excel.
'
'		Param: sDestinationSheetName| required
'		AllowedRange: 
'		Description: Name of the Destination sheet to which the sheet is to be imported.  
'								required When the sType value is excel  
'                               Optional,If each destination sheet name is same as the its source sheet name 
'								Usage:  dtblExcelToQTPImport( "c:\sample.xls,"sheet1,sheet2,sheet3","") 
'								Required when the destination sheet name is different from the source sheet name.
'								Usage: 	dtblExcelToQTPImport( "c:\sample.xls,"sheet1,sheet2,sheet3","Action1,Dsheet2,Dsheet3")    
'								If one or more sheets have same name for the destination sheet, then it can be specified as 
'								Usage: 	dtblExcelToQTPImport( "c:\sample.xls,"sheet1,sheet2,sheet3","Action1,,")  - sheet2 and sheet3 will be imported with same sheet name.   								
'								If the destination sheet does not exist then a sheet of the specified name is created.
'								if more than one destination separate them with ","
'
'		Param: sQuery| required 
'		AllowedRange: 
'		Description: The SQL query string. Only Select Queries. Required when the sType value is other than excel
'
'		Param: sProcessDataFunc| Optional
'		AllowedRange: 
'		Description: The User defined Excel Data Processing/Formatting Sub  name to be executed. 
'								The Sub routine should have 2 parametersin the order - Excel file name (with full path) and the sheet name
'
'   Returns: N/A
'**********************************************************************'
Public Sub dtblDataImport(sType,sServer,sDBName,sUser,sPW,sSourceSheetName,sDestinationSheetName,sQuery,sProcessDataFunc)

	
	Dim sExecuteStatement,oQtp,oLibraries,sPath,sBasePath,sExcelFile,iCounter,oFso
	
	Select Case ucase(sType)
	Case "ACCESS","SQL SERVER","ORACLE"

		If  Ucase(sType) <> "ACCESS" Then
		
			'Create a reference for QuickTest application
			Set oQtp = CreateObject("QuickTest.Application")
			
					' Get the current Test Libraries collection
			Set oLibraries = oQtp.Test.Settings.Resources.Libraries ' Get the libraries collection object
			
			' Get the Relative path of the Application specfic libraries.
			For iCounter= 1 to oLibraries.Count
				sPath= oLibraries.Item(iCounter)
				If instr(1,sPath,"Automation\Testware\Apps") Then

					Set oFso = CreateObject("Scripting.FileSystemObject")

					'Get the Path of the application folder in the Testware structure
                    sBasePath = oFso.GetParentFolderName(oFso.GetFolder(oFso.GetParentFolderName(sPath))) & "\Data\"
                    Exit for
				End If
			Next

			Set oFso=Nothing
			
			' Release the test's libraries collection
			Set oLibraries = Nothing 
			
			'Release the Application object
			Set oQtp = Nothing 

            sExcelFile=sBasePath  & sDBName & ".xls"
		Else
			sBasePath=mid(sDBName,1,instr(1,sDBName,"Data\")-1+len("Data\"))
			sExcelFile=Replace(sDBName, ".mdb",".xls")
		End If

		'Import data into excel from DB
		dtblDBToExcelExport sType,sServer,sDBName,sUser,sPW,sExcelFile,sDestinationSheetName,sQuery
		
		'Execute the procedure to process the data if any
		If sProcessDataFunc<>"" Then
				sExecuteStatement=sProcessDataFunc & " sExcelFile ,sDestinationSheetName"
				Execute sExecuteStatement
		End if 
		sSourceSheetName=sDestinationSheetName
		'Import data into QTP Datatable from Excel
        dtblExcelToQTPImport sExcelFile,sSourceSheetName,sDestinationSheetName
		
	Case "EXCEL"

		'Import data into QTP Datatable from Excel
		sTempFileName=xclFormulaReplace(sDBName,sSourceSheetName)
		dtblExcelToQTPImport sTempFileName,sSourceSheetName,sDestinationSheetName
		winDeleteAFile sTempFileName
	End Select
	
End Sub

'**********************************************************************
'   Name:    dtblDataSheetExists
'   Purpose: Function to check if a DataTable sheet exists or not
'   Creator:Lavanya Bathina  
'
'		Param: sSheetName| required
'		AllowedRange: 
'		Description: Name of the sheet to be checked for existance
'
'   Returns: True if the sheets exists, otherwise returns false
'**********************************************************************
Public Function dtblDataSheetExists(ByVal sSheetName)

    
	Dim oTest
	Set oTest = DataTable.GetSheet(sSheetName)
    If err.number Then 
		dtblDataSheetExists = False
	Else
		dtblDataSheetExists=True
	End If 
	On error goto 0
End Function
'**********************************************************************
'   Name:    dtblAllSheetsImport
'   Purpose:This sub  imports the all the sheets present in the Excel file
'   Creator:Lavanya Bathina  
'
'		Param: sFileName| required
'		AllowedRange: 
'		Description: Name of the excel file from which the sheets are to be imported.
'
'   Returns: N/A
'**********************************************************************'
Public Sub  dtblAllSheetsImport(ByVal sFileName)

   
	Dim oExcel, oBook,oSheet
 
	'Launch excel
	Set oExcel = CreateObject("Excel.Application")
 
	'Open the file in read only mode
	Set oBook = oExcel.WorkBooks.Open(sFileName,,True)
    If Err.Number<>0 Then
			PrintToLog "Error while creating Excel object. Please try again. "
            ExitTest
	End If
	
	'Enumerate through all the sheets present in the file
	For each oSheet in oBook.WorkSheets
 
		'Add a new sheet to the datatable with the given sheet name if it does not already exists.
		If Not dtblDataSheetExists(oSheet.Name) Then
			'DataTable cannot be imported if the sheet does not exist
			DataTable.AddSheet oSheet.Name
        End If
		'Import the sheet
		DataTable.ImportSheet sFileName, oSheet.Name,oSheet.Name
	Next
	errHandler Err, "dtblAllSheetsImport", g_iSeverity

	'Close the workbook
	oBook.Close
	Set oBook = Nothing
 
	'Quit Excel
	oExcel.Quit
	Set oExcel = Nothing
	
End Sub
'**********************************************************************
'   Name:    dtblExcelToQTPImport
'   Purpose:This sub imports all the sheets or specified no of sheets to the run time datatable
'   Creator:Lavanya Bathina
'
'		Param: sFileName| required
'		AllowedRange: 
'		Description: Name of the excel file from which the sheets are to be imported.
'
'		Param: sSourceSheetName| Required
'		AllowedRange: 
'		Description: Name of the sheets to be Imported to QTP Datatable. Separate by "," for more than one sheet. To import all the sheets, Specify "all" in sSheetName parameter
'
'		Param: sDestinationSheetName| Required
'		AllowedRange: 
'		Description: Name of the Destination sheet to which the sheet is to be imported. 
'								Optional,If each destination sheet name is same as the its source sheet name 
'								Usage:  dtblExcelToQTPImport( "c:\sample.xls,"sheet1,sheet2,sheet3","") 
'								Required when the destination sheet name is different from the source sheet name.
'								Usage: 	dtblExcelToQTPImport( "c:\sample.xls,"sheet1,sheet2,sheet3","Action1,Dsheet2,Dsheet3")    
'								If one or more sheets have same name for the destination sheet, then it can be specified as 
'								Usage: 	dtblExcelToQTPImport( "c:\sample.xls,"sheet1,sheet2,sheet3","Action1,,")  - sheet2 and sheet3 will be imported with same sheet name.   								
'								
'   Returns: N/A
'**********************************************************************'
Public Sub dtblExcelToQTPImport(sFileName,sSourceSheetName,sDestinationSheetName)

   

	Dim asSourceSheets,asDestinationSheets,iCounter
	
   Select Case ucase(sSourceSheetName)
		Case "ALL"
			'Import all the sheets from the specified excel file
			dtblAllSheetsImport sFileName
		Case Else
				'Import  specified sheets from the excel file
			    asSourceSheets=split(sSourceSheetName,",")
				asDestinationSheets=split(sDestinationSheetName,",")
				If ubound(asDestinationSheets)= -1 Then
					asDestinationSheets=asSourceSheets
				End If
				For iCounter = 0 to ubound(asDestinationSheets)
					If Trim(asDestinationSheets(iCounter))="" Then
						asDestinationSheets(iCounter)=asSourceSheets(iCounter)
					End If
					'Add a new sheet to the datatable with the given sheet name if it does not already exists.
					If Not dtblDataSheetExists(asDestinationSheets(iCounter)) Then
                        DataTable.AddSheet asDestinationSheets(iCounter)
					End if 
                    DataTable.ImportSheet sFileName,asSourceSheets(iCounter),asDestinationSheets(iCounter)
				Next
				errHandler Err, "dtblExcelToQTPImport", g_iSeverity
   End Select
   
End Sub
'**********************************************************************
'   Name:    dtblQTPToExcelExport
'   Purpose:This sub exports all the sheets or specified no of sheets from the run time datatable
'   Creator:Lavanya Bathina
'
'		Param: sFileName| required
'		AllowedRange: 
'		Description: Name of the excel file to which the sheets are to be exported. if the specified excel file does not exist new file of the given name will be created.
'
'		Param: sSheetNames| optional|AssumedValue="all"
'		AllowedRange: Any valid sheet name in the Excel file. 
'		Description: Name of the sheets to be exported to excel. Separate by "," for more than one sheet. To Export all sheets, Pass the value 'all' to sSheetName or leave blank.
'
'   Returns: N/A
'**********************************************************************'
Public Sub dtblQTPToExcelExport(sFileName,sSheetNames)

	'
	Dim asSheetNames,iCounter,oFso,oApp,oWorkBook

    Set oFso= CreateObject("Scripting.FileSystemObject")
	'check if the destination file exist. if not create one
	If Not oFso.FileExists(sFileName) Then

		'Create an Excel file with the given name
		Set oApp=CreateObject("Excel.Application")
		  'Disable the Alert messages
		oApp.AlertBeforeOverwriting = False
		oApp.DisplayAlerts = False
		
		Set oWorkBook = oApp.Workbooks.Add()
		errHandler Err, "dtblQTPToExcelExport", g_iSeverity

		'Save the file
		'Use xlExcel8 format to save the file
		If oApp.Version=12.0 Then
			oWorkBook.SaveAs sFileName,56
		'DefaultSaveFormat if Excel 2003 is being used
		Elseif oApp.Version=11.0 Then
			 oWorkBook.SaveAs sFileName	
        End If
        
		errHandler Err, "dtblQTPToExcelExport", g_iSeverity

		'Close the workbook
		oWorkBook.Close
		oApp.Quit
		Set oWorkBook=Nothing
		Set oApp=Nothing
        
	End If
	Set oFso=Nothing

    Select Case ucase(sSheetNames)
		Case "ALL"
			'Export all the sheets from the run time datatable to the specified file
            DataTable.Export sFileName
			errHandler Err, "dtblQTPToExcelExport", g_iSeverity
			
		Case Else 

			'Export sheets mentioned from the run time datatable to the specified file
			asSheetNames=split(sSheetNames,",")
			For iCounter = 0 to ubound(asSheetNames)
				DataTable.ExportSheet  sFileName,asSheetNames(iCounter)
			Next
			errHandler Err, "dtblQTPToExcelExport", g_iSeverity
   End Select
   
End Sub
'**********************************************************************
'   Name:    dtblDBToExcelExport
'   Purpose:This Exports the data from the specied DB Type to Excel.
'   Creator: Lavanya Bathina
'
'		Param: sDBType| required
'		AllowedRange: "Access", "SQL Server", "Oracle"
'		Description: The type of connection.
'
'		Param: sServer| required
'		AllowedRange: 
'		Description: The server the database resides on.  For Access connections, this should
'								 be passed as an empty string.
'
'		Param: sDBName| required
'		AllowedRange: 
'		Description: The database to access.  For Access, this should be the full path to the .mdb file..
'
'		Param: sUser| optional|AssumedValue="" 
'		AllowedRange: 
'		Description: The user to use for the connection.  If the connection doesn't need a user,
'								 pass an empty string..
'
'		Param: sPW| optional|AssumedValue="" 
'		AllowedRange: 
'		Description: The password for the user.  If the connection doesn't need a user or a 
'								 password, pass an empty string.
'
'		Param: sExcelFile| Required
'		AllowedRange: 
'		Description: Name of the excel (with full path) which contains the sheet to which the data is to be exported. 
'								If the file does not 
'
'		Param: sSheetName| required
'		AllowedRange: 
'		Description: Sheet Name to which the queried data to be exported.
'
'		Param: sQuery| required
'		AllowedRange: 
'		Description: The SQL query string. Only Select Queries
'
'   Returns: N/A
'**********************************************************************'
Public Sub dtblDBToExcelExport(sDBType,sServer,sDBName,sUser,sPW,sExcelFile,sSheetName,sQuery)

	'
	Dim sConnectionString,oApp,oWorkBook,oSheet,oFso,oFile,iRowCount
	'Construct the connection string based on the type of the DB .
	Select Case ucase(sDBType)
		Case "ACCESS"

        sConnectionString= "ODBC;Driver={Microsoft Access Driver (*.mdb)};" & _
												"DBQ=" & sDBName &";" & _
												"UID=" & sUser & ";" & _
												"Password=" & sPW & ";" 

       Case "SQL SERVER"

			sConnectionString = "ODBC;Driver={SQL Native Client};" &_
													"Server=" &sServer & ";" &_
													"Database=" & sDBName & ";" &_
													"Uid=" & sUser & ";" &_
													"Pwd=" & sPW & ";" 
                                                    
		Case "ORACLE"

			sConnectionString = "ODBC;Driver={Microsoft ODBC for Oracle};" &_
													 "Server=" &sServer & ";" &_
													 "Uid=" & sUser & ";" &_
													  "Pwd=" & sPW & ";" 
    End Select
	
   'Create a reference to Excel Application
	Set oApp=CreateObject("Excel.Application")

	'Disable the Alert messages
	oApp.AlertBeforeOverwriting = False
	oApp.DisplayAlerts = False
	
	'Check if the specified excel file exists. If not create one
    Set oFso= CreateObject("Scripting.FileSystemObject")
	If Not oFso.FileExists(sExcelFile) Then

		'Create a new file with the given name
        Set oWorkBook = oApp.Workbooks.Add()
		errHandler Err, "dtblDBToExcelExport", g_iSeverity

        'Save the file
		'Use xlExcel8 format to save the file
		If oApp.Version=12.0 Then
			oWorkBook.SaveAs sExcelFile,56
		'DefaultSaveFormat if Excel 2003 is being used
		Elseif oApp.Version=11.0 Then
			 oWorkBook.SaveAs sExcelFile	
        End if
        errHandler Err, "dtblDBToExcelExport", g_iSeverity
		
	Else
	
		'Open the Excel file
		Set oWorkBook= oApp.Workbooks.Open(sExcelFile)
		If Err.Number<>0 Then
			PrintToLog "Error while creating Excel object. Please try again. "
            ExitTest
		End If
		
	End If
	Set oFso=Nothing

    'Delete the existing sheet. if the sheet exists 
	
	oWorkBook.Sheets(sSheetName).Delete
	On Error Goto 0
	
	'Add new sheet to the workbook
	oWorkBook.Sheets.Add
    
	'Rename the newly added sheet name to the name passed in 
	oWorkBook.ActiveSheet.Name= sSheetName
    
	'Create an object referring to the sheet
	Set  oSheet = oWorkBook.Sheets(sSheetName)
    
   'Execute the query and add the query table to the sheet.
    With oSheet.QueryTables.Add (sConnectionString , oSheet.Range("A1"))
		.CommandText = sQuery
		.Name = "Query-39008"
		.Refresh BackgroundQuery=False
	End With
	'Wait unitl the refresh completes.
	wait(2)
	errHandler Err, "dtblDBToExcelExport", g_iSeverity

	'Delete the additional blanks rows if any
	iRowCount =oSheet.UsedRange.Rows.Count
	oSheet.Rows(iRowCount & ":" & iRowCount).Select
 
	  Do Until oSheet.Cells(iRowCount, 1).Value <> ""
		oSheet.Rows(iRowCount & ":" & iRowCount).Delete
		iRowCount = iRowCount - 1
		oSheet.Rows(iRowCount & ":" & iRowCount).Select
	 Loop
	

	'Save the changes
	oWorkBook.Save
	'Close the workbook
    oWorkBook.Close

	'Reset the Alert settings
	oApp.AlertBeforeOverwriting = True
	oApp.DisplayAlerts = True
	'Close the excel application
	oApp.Quit

	'Release the objects used.
	Set oSheet=Nothing
	Set oWorkBook= Nothing
	Set oApp= Nothing
    
End Sub		
'**********************************************************************
'   Name:    xclFormulaReplace
'   Purpose: Function to creates an excel with the formula used in excel sheet replaced with its actual evaluated value. 
'   Creator:Lavanya Bathina  
'
'		Param: sFileName| required
'		AllowedRange: 
'		Description: Name of the Excel File
'
'		Param: sSheetName| required
'		AllowedRange: 
'		Description: Name of the sheet. If more than one sheet, separate each sheet by a ","
'
'   Returns:  The Excel File name.
'**********************************************************************
Public Function xclFormulaReplace(sFileName,sSheetName)
	'
	'Declare Variables
	Dim oSheet,iCount,oRow,oCell,sValue,iRow,iCol,sFormulaInCell,sRange,sReferenceSheet
	Dim oExcel,oWorkBook,sTempFileName,asSheetNames,iCounter,sErrDesc

    asSheetNames  =split(sSheetName,",")

	 'Create an object reference for Excel Application
	Set oExcel= CreateObject("Excel.Application")
	'Disable the Alert messages
	oExcel.AlertBeforeOverwriting = False
	oExcel.DisplayAlerts = False
	
	'Open the workbook
	Set oWorkBook = oExcel.WorkBooks.Open(sFileName)

	If Err.Number<>0 Then
		PrintToLog "Error while creating Excel object. Please try again. "
        ExitTest
	End If
	
	'Create a temporary copy of the workbook
	sTempFileName= Replace(sFileName,".xls","_temp.xls")
	'Save the file
	'Use xlExcel8 format to save the file
	If oExcel.Version=12.0 Then
		oWorkBook.SaveAs sTempFileName,56
	'DefaultSaveFormat if Excel 2003 is being used
	Elseif oExcel.Version=11.0 Then
		 oWorkBook.SaveAs sTempFileName	
	End if
    
	
	'Replace the formulas in each sheet with its evaluated value
	For iCounter=0 to ubound(asSheetNames)

		'Get the reference to the sheet
		set oSheet=oWorkBook.Sheets(asSheetNames(iCounter))
		
		'Count  the no of cells containing formulas
		'xlCellTypeFormulas=-4123
		
		iCount = oSheet.Cells.SpecialCells(-4123).Count
		sErrDesc=Err.Description
		On Error GoTo 0 
		
		'Check if there are cells with formulas 
		If sErrDesc <> "No cells were found." Then
			
			oSheet.Activate
			'Select the cells that contains the formula
			''xlCellTypeFormulas=-4123
			oSheet.Cells.SpecialCells(-4123).Select

			'Iterate through the cells with formulas and replace them with the actual (evaluated) value
            For Each oRow In oExcel.Selection.Rows

				For Each oCell In oRow.Columns

					'Get the formula used in the cell
					sFormulaInCell = oCell.Formula
					
					'Split to get the sheet name and the cell address
					sFormulaInCell = Split(sFormulaInCell, "!")
                    sReferenceSheet = Replace(sFormulaInCell(0), "=", "")
					sRange = sFormulaInCell(1)
					
					'Activate the sheet that has the actual value
					oWorkBook.Sheets(sReferenceSheet).Activate
                    sValue = oWorkBook.Sheets(sReferenceSheet).Range(sRange).Value
                    oSheet.Activate
					
					'Clear the contents of the cell
					oCell.ClearContents
					iRow = oCell.Row
					iCol = oCell.Column
					
					'Update the actual value
                    oSheet.Cells(iRow, iCol) = sValue
					
				Next
			Next
		End If
	Next

	'Save the temporary workbook and close
	oWorkBook.Save
    oWorkBook.Close

	'Release the object used for workbook
	set oWorkBook=Nothing

	'Close the excel application 
	oExcel.Quit
	'Release the object used for Excel application
	set oExcel=Nothing
	xclFormulaReplace = sTempFileName
	
End Function










