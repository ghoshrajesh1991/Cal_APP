Option Explicit
'*************************** MAINTAIN THIS HEADER! *********************************
'     Library Name:     Err_Handler_Lib.vbs
'     Purpose:          Contains functions related to error handling.
'
'--------------------------------------------------------------------------------
'
'********************************************************************************** 
  

'**********************************************************************************
'                           PRIVATE CONSTANTS and VARIABLES
'**********************************************************************************

' Boolean flag to clear the Console when the script starts.
Private bClearPrintWindow
bClearPrintWindow = True

'**********************************************************************************
'                           PUBLIC CONSTANTS and VARIABLES
'**********************************************************************************
'MJN
Extern.Declare micHwnd, "FindWindowEx", "user32.dll", "FindWindowEx", micHwnd, micHwnd, micString, micString
Extern.Declare micInteger, "SetWindowPos", "user32.dll", "SetWindowPos", micHwnd, micHwnd, micInteger, micInteger, micInteger, micInteger, micInteger
Extern.Declare micLong, "SendMessage", "user32.dll", "SendMessageA", micHwnd, micLong, micLong, micLong

' The following is a list of user-defined error codes.  All user-defined error
'codes should be greater than the vbObjectError (-2147221504) so that is
'used as the starting point.

Public g_lDATE_TIME_ERR
g_lDATE_TIME_ERR = vbObjectError + 1

Public g_lOBJ_NOT_FOUND_ERR
g_lOBJ_NOT_FOUND_ERR = vbObjectError + 2
' Excel error codes
' Error for column not found
Public g_lCOL_NOT_FOUND_ERR
g_lCOL_NOT_FOUND_ERR = vbObjectError + 3
'Error codes for column and rows out of range
Public g_lROW_COL_OUT_OF_RANGE
g_lROW_COL_OUT_OF_RANGE = vbObjectError + 4
'Error code for object not found
Public g_lOBJ_NOT_FOUND
g_lOBJ_NOT_FOUND = vbObjectError + 5
' Invalid state - e.g., navigation not valid
Public g_iINVALID_STATE
g_iINVALID_STATE = vbObjectError + 6
'  Error code for invalid logon for vsc
Public g_iINVALID_LOGON
g_iINVALID_LOGON= vbObjectError + 7
'  Error code for verification failure
Public g_iVERIFICATION_FAILED
g_iVERIFICATION_FAILED= vbObjectError + 8

Public g_iITEM_NOT_FOUND
g_iITEM_NOT_FOUND = vbObjectError + 9

Public g_iINVALID_INPUT
g_iINVALID_INPUT = vbObjectError + 10

Public g_iUNAUTHORIZED_AGNT
g_iUNAUTHORIZED_AGNT = vbObjectError + 11

Public g_iOUT_OF_RANGE
g_iOUT_OF_RANGE = vbObjectError + 12

Public g_lTIME_OUT
g_lTIME_OUT = vbObjectError + 13

Public g_lINVALID_ARG
g_lINVALID_ARG = vbObjectError + 14

Public g_lSECURITY_ALERT_WINDOW
g_lSECURITY_ALERT_WINDOW = vbObjectError + 15

Public g_iACTION_FAILED
g_iACTION_FAILED = vbObjectError + 16

Public g_iNOT_SERVICABLE
g_iNOT_SERVICABLE = vbObjectError + 17

Public g_iPAGE_NOT_LOADED
g_iPAGE_NOT_LOADED =  vbObjectError + 18

Public g_iNB21_APP_ERR
g_iNB21_APP_ERR =  vbObjectError + 19

Public g_iNO_DATA
g_iNO_DATA =  vbObjectError + 20

Public g_iINSUFFICIENT_DATA
g_iINSUFFICIENT_DATA =  vbObjectError + 21

Public g_iMISMATCH_DATA
g_iMISMATCH_DATA =  vbObjectError + 22

Public g_iDATABASECONNECTION_ERROR
g_iDATABASECONNECTION_ERROR =  vbObjectError + 23

Public g_iSYS_COL_VALUE_NOTMATCH_ERROR
g_iSYS_COL_VALUE_NOTMATCH_ERROR =  vbObjectError + 24

Public g_iDATASHEETCONNECTION_ERROR
g_iDATASHEETCONNECTION_ERROR =  vbObjectError + 25

Public g_iNORECORDSFOUND_ERROR
g_iNORECORDSFOUND_ERROR =  vbObjectError + 26

Public g_iWARNING_MESSAGE
g_iNORECORDSFOUND_ERROR =  vbObjectError + 27

Public g_iCV_VIEWS_NOT_REFRESHED
g_iCV_VIEWS_NOT_REFRESHED =  vbObjectError + 28

Public g_iSORT_ORDER_NOTMATCHING
g_iSORT_ORDER_NOTMATCHING =  vbObjectError + 29
 
' Global variable to hold the severity.  If set to = micFail,
' error handler function will stop on all errors.  If set to equal micWarning,
' error handler function will log errors and continue.
Public g_iSeverity
g_iSeverity = micWarning

' Boolean flag telling whether or not to log errors to the print window.
Public g_bLogToPrintWindow
g_bLogToPrintWindow = False

' Global variable to run the on fail function
'MJN - Setting to true will call GenerateResults during micFail.
Public g_bOnFailFunc
g_bOnFailFunc = True
' Global variable to be used in conjunction with Scenario Generator.
' If this file is set and exists, the error handler will pause until it is gone.
Public g_sPauseFile
' If this is set to True, the error handler function will print the memory info
' to the log.
'Public g_bPrintMemInfo

' This is a global variable for the set of processes to print memory info to the log for.
Public g_sProcesses

' This is a global variable for the random input for arguments passed into functions, 
' usually for a random list selection
Public g_iRandom
 g_iRandom = -1

' This is a global flag that defaults to 0.  It is called in the error handler
Public g_iWaitTime
g_iWaitTime = 0
' This is a function prefix.  If it is set (e.g., "vgn") the wait time will occur only
' for functions that begin with
Public g_sFuncPrefix 
g_sFuncPrefix = ""

'This is global variable to indicate the application that is being executed. (Used in NB21)
Public g_sApplicationName
g_sApplicationName=""

'This global boolean will add HTML tags to the PrintToLog message for validation.
Public g_bIsValidation
g_bIsValidation = False

'This global variable is used to store the path to search for the BuildSuccess flag.
Public g_sBuildSuccessFlagPath
g_sBuildSuccessFlagPath = ""

'This global variable is used to store the path where all the results will be copied to during batch run.
Public g_sBatchResultsCIPath
g_sBatchResultsCIPath = ""

'This global variable will control whether or not we copy the log files during a micFail, which is only used for Batch runs.
Public g_bBatchRunCI
g_bBatchRunCI = False

'The From Address to Send Email
Public g_sFromAddress
g_sFromAddress = ""

'The To Address to send email.
Public g_sToAddress
g_sToAddress = ""

'The encrypted Email Password
Public g_sEmailPwd
g_sEmailPwd = ""

'The KeyPath to the file used for decrypt.
Public g_sKeyPath
g_sKeyPath = ""

'The Browser and URL global variables.
Public g_sBrowser, g_sURL, g_sJenkinsURL
g_sJenkinsURL = ""

'A global flag to indicate debug\developer mode
Public g_bDebug
g_bDebug = True

Public g_sResultsCopyPath : g_sResultsCopyPath = ""

Public g_bCapturePassBitmaps : g_bCapturePassBitmaps = False

Public g_bCaptureErrBitmaps : g_bCaptureErrBitmaps = True


'**********************************************************************************
'                             PRIVATE FUNCTIONS
'**********************************************************************************

'**********************************************************************
'	Name: ehWaitOnPauseFile
'	Purpose:	This sub works in conjunction with the Scenario Generator.
'							and the errHandler function.  When a pause in the run
'							is requested from the scenario generator, a semaphore file is created
'							in the Scenario Generator app path called "pause".  This
'							sub will spinlock until the Scenario Generator stops the 
'							pause (when it will delete the semaphore file).
'	Creator:Mark Clemens
'
'	Returns: N/A
'**********************************************************************
Private Sub ehWaitOnPauseFile()
	Dim fso, f
	Dim dtEndTime
	If CBool(g_bLogToPrintWindow) = True Then
		print "Test paused . . ."
	End If
	'Set an end time flag for 10 minutes
	dtEndTime = DateAdd("n",10,Now)
	Set fso = CreateObject("Scripting.FileSystemObject")
	bFileGone = False
	Do Until bFileGone = True
		If fso.FileExists(g_sPauseFile) Then
			wait 5
		Else
			bFileGone = True
			print "Test resuming . . ."
		End if
	Loop
    
End Sub

'**************************************************************************************************
'	Name: PrintToConsole
'	Purpose: This sub will print the text to the console.
'	Creator:  Michael J. Nohai

'	Param: sLine|required
'	AllowedRange: 
'	Description: The line to print to the log.  
'
'	Returns: N/A
'***************************************************************************************************
Private Sub PrintToConsole(ByVal sLine)
	Dim lHwnd, bSuccess
	bClearPrintWindow = False

	Const flags = &H2
	Const HWND_TOPMOST = -1

	lHwnd = Extern.FindWindowEx(Null, Null, vbNullString, "QuickTest Print Log")
	bSuccess = Extern.SetWindowPos(lHwnd, HWND_TOPMOST, 0, 0, 590, 120, flags)

	' Print the line to the console.
	Print sLine

End Sub

'**************************************************************************************************
'	Name: ClearToConsole
'	Purpose: This sub will clear the text to the console.
'	Creator:  Michael J. Nohai

'	Returns: N/A
'***************************************************************************************************
Private Sub ClearToConsole()
	Dim hwnd, lHwnd

	Const WM_CLEAR = &HC

	lHwnd = Extern.FindWindowEx(Null, Null, vbNullString, "QuickTest Print Log")

	If lHwnd > 0 Then
		hwnd = Window("regexpwndtitle:=QuickTest Print Log").WinEditor("nativeclass:=Edit","index:=0").GetROProperty("hwnd")
		Extern.SendMessage hwnd, WM_CLEAR, 0, 0
	End If

End Sub

'************************************************************************************************************
'                                PUBLIC FUNCTIONS
'************************************************************************************************************
'	Name: GetFSDateTimeStamp
'	Purpose:	This function formats the date and time to use an underscore '_'
'			              between each of the date time components, so that it can be 
'			              used as a file or folder name.
'	Creator:      Mark Clemens

'	Param: 		sDateTimeStamp| required 
'	AllowedRange: 
'	Description: The date time format to build the file system date stamp.
'
'	Returns:  The formatted date/time stamp
'
'************************************************************************************************************
Public Function GetFSDateTimeStamp(sDateTimeStamp)
	Dim sFormattedStamp, bDate, sYear, sMonth, sDay, sHour, sMinute, sSecond
	
	bDate = IsDate(sDateTimeStamp) 'check to see if this is a properly formatted date
	If bDate = False Then
		err.raise g_lUD_DateTimeError, "QTP", "Invalid date time sent to GetFSDateTimeStamp function."
		Exit Function
	End If

	sYear = Year(sDateTimeStamp)
	sMonth = Month(sDateTimeStamp)
			If Len(sMonth) < 2  Then sMonth = "0" & sMonth
	sDay = Day(sDateTimeStamp)
			If Len(sDay) < 2  Then sDay = "0" & sDay
	sHour = Hour(sDateTimeStamp)
			If Len(sHour) < 2  Then sHour = "0" & sHour
	sMinute = Minute(sDateTimeStamp)
			If Len(sMinute) < 2  Then sMinute = "0" & sMinute
	sSecond = Second(sDateTimeStamp)
			If Len(sSecond) < 2  Then sSecond = "0" & sSecond
	
	GetFSDateTimeStamp = sYear & "_" & sMonth & "_" & sDay & "_" & sHour & "_" & sMinute & "_" & sSecond 
End Function

'************************************************************************************************************
'	Name: errHandler
'	Purpose: This sub accepts an error object and, based on the number, 
'		logs the error number, description and the function it occurred in.
'		Based on the severity, the test will stop.
'	Creator: Mark Clemens
'	
'		Param: oError| required | InitialEntry=oError
'		AllowedRange: 
'		Description: The error object from a higher-level function call..
'
'		Param: sFunction| required | InitialEntry=sFunction
'		AllowedRange: 
'		Description: The function, sub or script where the error occurred.  This is 
'			provided for traceability later..
'
'		Param: iSeverity| required | InitialEntry=oError
'		AllowedRange: micPass, micFail, micDone, micWarning (0,1,2,3)
'		Description: The severity of the error.  For micFail or micDone, the test will stop.
'			Use micPass or micWarning to log a message without stopping.
'
'	Returns: N/A
'**********************************************************************
Public Sub errHandler(oError, sFunction, iSeverity)
	Dim oApp, sTestName, iErrNumber, sErrDescription, sMemInfo
	Dim qtResultsOpt, sBitmap, sDesktopBitmap
	Dim fso, f, sLogMsg, sStatus, sBitmapLogString

	' If an error was thrown at the beginning when the object repositories
	' were loaded - "Repository was already associated . . .", 
	' clear the error and exit the sub.
	
	If oError.Number = -2146232832 Then
		oError.Clear
		Exit Sub
	End if
	' Execute a global 'think time' to wait between steps.
	If g_iWaitTime <> 0 Then
		' If a global prefix was set . . .
		If g_sFuncPrefix = "" Then
			wait g_iWaitTime
			print "waiting . . ." & g_iWaitTime
		Else
			If Left(sFunction, 3) = g_sFuncPrefix Then
				wait g_iWaitTime
				print "waiting . . ." & g_iWaitTime
		
			End If
		End If
	End If

	
	If g_bPrintMemInfo = True Then
		sMemInfo = winGetMemInfo(g_sProcesses)
		PrintToLog sFunction & vbcrlf & sMemInfo
	End If


	' Set the error number and description to raise at the end
	iErrNumber = oError.Number
	sErrDescription = oError.Description

   ' Handle the error based on the error number

   	Select Case iErrNumber
		' If there is no error (i.e., error number is 0) then exit the sub
		Case 0
			' If an error description was passed in, log it.
			If sErrDescription = "" or iSeverity <> micPass Then
			
				Exit Sub
			Else
				Reporter.ReportEvent iSeverity, sFunction, "Description: " & sErrDescription 
				PrintToLog sErrDescription
				Set oApp = CreateObject("QuickTest.Application")
				sTestName = Environment("TestName")
				sBitmap = sTestName & "_" & GetFSDateTimeStamp(Now) & ".png"
				sDesktopBitmap = sTestName & "_" &  "Desktop_" & GetFSDateTimeStamp(Now) & ".png"
				If g_bCapturePassBitmaps = True Then
					Err.Clear
					winBitmapActiveWinCapture Environment("ResultDir") & "\" & sBitmap
					winDesktopBMPCapture Environment("ResultDir") & "\" & sDesktopBitmap
					Err.Number = iErrNumber
					Err.Description = sErrDescription
					
				End If

				Set oApp = Nothing
            End if
		' If the error number is other than 0 or those listed above, capture a bitmap.
		Case 500
			' Undeclared variable error
			Reporter.ReportEvent iSeverity, sFunction, "Description: There is an undeclared variable in function - " & sFunction & ". Please contact the library developer and notify them of this error." 
			PrintToLog "There is an undeclared variable in function - " & sFunction & ". Please contact the library developer and notify them of this error." 
			If CBool(g_bBatchRunCI) = False Then
				MsgBox "Description: There is an undeclared variable in function - " & sFunction & ". Please contact the library developer and notify them of this error." 
			End If
		Case Else
			sTestName = Environment("TestName")
			Set oApp = CreateObject("QuickTest.Application")
			sTestName = Environment("TestName")
			sBitmap = sTestName & "_" & GetFSDateTimeStamp(Now) & ".png"
			sDesktopBitmap = sTestName & "_" &  "Desktop_" & GetFSDateTimeStamp(Now) & ".png"
			' Capture the error data so the bitmap capture functions
			' can handler errors.  This error data will be reassigned to the 
			' error object immediately after.
			'iErrNumber = Err.Number
			'sErrDescription = Err.Description
			If g_bCaptureErrBitmaps = True Then
				Err.Clear
				winBitmapActiveWinCapture Environment("ResultDir") & "\" & sBitmap
				winDesktopBMPCapture Environment("ResultDir") & "\" & sDesktopBitmap
				Err.Number = iErrNumber
				Err.Description = sErrDescription
				
			End If
			
			Set oApp = Nothing
	End Select

	'Commented by Lakshmi Varadan. If the statement ExitActionIteration is called within OnFail function, rest of the error handling steps are skipped.
	'In order  to ensure that all the steps are executed for micFail case, the following section of code has been moved to the micFail  block of the if		 
'	' If the severity is set to fail, run the on fail function if there is one.
'	If iSeverity = micFail And g_bOnFailFunc = True Then
'		OnFail
'	End If
'	
	' If the severity is set to fail
	If iSeverity = micFail Then
		If g_bCaptureErrBitmaps = True THen
			sBitmapLogString = "Bitmap: " & Environment("ResultDir") & "\" & sBitmap
		ELse
			sBitmapLogString = "Capture bitmap flag for error condition set to false."
		End If
		
		' Log to the print log and print window if logging is going to the print window
		PrintToLog "FAIL: Function = " & sFunction & vbcrlf & _
				   "Number: " & iErrNumber & vbcrlf & _
				   "Description: " & sErrDescription & vbcrlf & _
				   sBitmapLogString & vbcrlf & _
				   "LOG ANALYSIS: " & vbcrlf & _
				   "Tester: " & vbcrlf & _
				   "Disposition:"  & vbcrlf & _
				   "DefectId: " & vbcrlf & _
				   "Comments: " 

		' Report the error
		Reporter.ReportEvent iSeverity, sFunction, "Number = " & iErrNumber & vbcrlf & _
				"Description: " & sErrDescription & vbcrlf & _
				sBitmapLogString		
		' stop the test
		ERr.Number = iErrNumber
		Err.Description = sErrDescription
		
		If g_sRunType = "EnvironmentCertification" then
			utCopyRunResults g_sAppName,g_sRunType,g_sRootPath
			ExitTest
		Else
			RecoveryScenario
			ExitTest
		End If
		
	' If the severity is set to warning
	ElseIf iSeverity = micWarning then

		If g_bCaptureErrBitmaps = True THen
			sBitmapLogString = "Bitmap: " & Environment("ResultDir") & "\" & sBitmap
		ELse
			sBitmapLogString = "Capture bitmap flag for error condition set to false."
		End If
		
		' If logging is going to the print window
		' Log to the print log and print window if logging is going to the print window
		PrintToLog "WARNING: Function = " & sFunction & vbcrlf & _
				   "Number: " & iErrNumber & vbcrlf & _
				   "Description: " & sErrDescription & vbcrlf & _ 
				   sBitmapLogString & vbcrlf & _
				   "LOG ANALYSIS: " & vbcrlf & _
				   "Tester: " & vbcrlf & _
				   "Disposition:"  & vbcrlf & _
				   "DefectId: " & vbcrlf & _
				   "Comments: " 
		' Report the warning
		Reporter.ReportEvent iSeverity, sFunction, "Number: " & iErrNumber & vbcrlf & _
				"Description: " & sErrDescription & vbcrlf &_
				sBitmapLogString

	' If the severity is set to 'Pass' 
	ElseIf iSeverity = micPass then
		' Log to the print log and print window if logging is going to the print window

		If g_bCapturePassBitmaps = True Then
			PrintToLog "PASS: Function = " & sFunction & vbcrlf & _
				"Bitmap: " & Environment("ResultDir") & "\" &  sBitmap
		Else
			PrintToLog "PASS: Function = " & sFunction & vbcrlf & _
				"Capture bitmap flag for pass condition set to false."
		End If	
		' Log the message
		Reporter.ReportEvent iSeverity, sFunction, "PASS: Function = " & sFunction

	' If the severity is set to 'Done'
	ElseIf iSeverity = micDone then
		' Log to the print log and print window if logging is going to the print window

		PrintToLog "DONE: Test = " & sTestName
		' Log the message and stop the test
		Reporter.ReportEvent iSeverity, sFunction, "DONE: Test = " & oApp.Test.Name
		ExitTest
	End If
	
	oError.Clear()
	Set oApp = Nothing
	
End Sub

Private Sub EndTheTest()
		
		Dim oApp
		
		Stop
		Stop
		
		
		Set oApp = CreateObject("QuickTest.Application")
		
		oApp.Test.Stop
		
		
		Call ExitIteration()
		
		Call ExitTest(iErrNumber)
		Call ExitTest(iErrNumber)
		Call ExitTest(iErrNumber)
		Call ExitTest(iErrNumber)
		Call ExitTest(iErrNumber)
		Call ExitTest(iErrNumber)
	
	
End Sub

'**************************************************************************************************
'	Name: PrintToLog
'	Purpose: This sub prints to the error log.  It concatenates the current time
'		onto the log statement that is passed in.  If the g_bLogToPrintWindow flag is
'		set to True, this function will also print to the print window.
'	Creator: Mark Clemens

'		Param: sLine|required
'		AllowedRange: 
'		Description: The line to print to the log.  The current time is also concatenated 
'			to the beginning of the log entry.
'
'	Returns: N/A
'
'***************************************************************************************************
Public Sub PrintToLog(ByVal sLine)
	Dim oApp , qtOptions,fso, ts, sLogFile,sHour, sMinute, sSecond, dtTime, oStream
	dtTime = Time() 'get the current time
	' Parse the time into a readable, usable and consistent time string
	sHour = Hour(dtTime)
	sMinute = Minute(dtTime)
	sSecond = Second(dtTime)
	If Len(sHour) < 2  Then sHour = "0" & sHour
	If Len(sMinute) < 2 Then sMinute = "0" & sMinute
	If Len(sSecond) < 2 Then sSecond = "0" & sSecond
	dtTime = sHour & ":" & sMinute & ":" & sSecond

	' Concatenate the time string to the beginning of the line to be logged
	sLine = "(" & dtTime & ") " & sLine

	' Open or create the log file and write the line to the file.
	sLogFile = Environment("ResultDir") & "\Log.txt"
	Set fso = CreateObject("Scripting.FileSystemObject")
	
    Set oStream = CreateObject("ADODB.Stream")
    oStream.Open
    oStream.Charset = "utf-8"

    If fso.FileExists(sLogFile) Then
    	oStream.LoadFromFile sLogFile
    	oStream.Position = oStream.Size
    End If

    oStream.LineSeparator = -1 'adCRLF
    oStream.WriteText sLine, 1
    oStream.SaveToFile sLogFile, 2 'OverWrite
    oStream.Close

    Set oStream = Nothing
    Set fso = Nothing
	
	' If routing to the print window, write the line to the print window.
	If CBool(g_bLogToPrintWindow) = True Then
		'Clear the console in the beginning of Script run.
		If bClearPrintWindow = True Then
			ClearToConsole()
		End If
		' Print to console.
		PrintToConsole sLine
	End If
	
	'RM - Also send the non-verification line statement to the test run results.
	If InStr("Description:", sLine) = 0 Or InStr("DONE:", sLine) = 0 Then
		'Reporter.ReportEvent micDone, sLine, ""
	End If
End Sub

'**************************************************************************************************
'	Name: PrintToLogResult
'	Purpose: This sub prints to the error log.  It concatenates the current time
'		onto the log statement that is passed in.  If the g_bLogToPrintWindow flag is
'		set to True, this function will also print to the print window.
'
'		It also provides a central location to print the result of a verification check 
'		indicated by the event status to the log.
'	Creator: Rod Maturan
'
'		Param: sLine|required
'		AllowedRange: 
'		Description: The line to print to the log describing the verification check. 
'			The current time is also concatenated to the beginning of the log entry.
'
'		Param: sRoutineName|required
'		AllowedRange: 
'		Description: The function, sub or script where the error occurred.  This is 
'			provided for traceability later..
'
'		Param: sEventStatus|required
'		AllowedRange: {micPass, micFail}
'		Description: The result or outcome of an explicit verification check in code.
'			Matches the relevant EventStatus parameters of the Reporter.ReportEvent() method.
'
'	Returns: N/A
'
'***************************************************************************************************
Public Sub PrintToLogResult(sLine, sRoutineName, sEventStatus)
	
	'Centrally handle and simplify the reporting to log cases through this sub here.
	Select Case sEventStatus
		Case micPass
			Err.Number = 0
			Err.Description = sLine
		Case micFail
			Err.Number = g_iVERIFICATION_FAILED
			Err.Description = sLine
		Case Else 
			Err.Number g_iOUT_OF_RANGE
			Err.Description = "The sEventStatus argument value '" & _
				sEventStatus & "' does not evaluate to either micPass or micFail."
	End Select
	errHandler Err, sRoutineName, sEventStatus
End Sub

'******************************************************************************************************************
'	Name: 			ehCheckSecondArgument
'	Purpose: 	  Error Handling Procedure errHandler has 3 arguments
'				  			2nd argument should be the Procedure's name where this Error Handling routine is placed
'				  			it is important to force, since wrong 2nd argument during debugging - if Procedure fails - 
'				 			will mislead by pointing to wrong Procedure's name.
'	Creator:unknown
'
'	Param: sLibraryFile| required 
'	AllowedRange: 
'	Description:  Library file to be screened. As example, if you need to screen apl_lib.vbs you will pass
'                             ehCheckSecondArgument "C:\Automation\Testware\Apps\APL\Lib\apl_lib.vbs"

'	Returns: Log file with all found discrepancies (if any)
'******************************************************************************************************************'
Public Sub ehCheckSecondArgument(sLibraryFile) 

   'AM - added 07/29/2009
	
	Dim fso, ts, sLibrary, asLibraryLines, sProcedureName, iMistakeCounter, iCounter,bMistakesFound
	bMistakesFound =False 'initializing the flag - we are presuming that there are no mistakes

	Set fso = CreateObject("Scripting.FileSystemObject")
	Set ts = fso.OpenTextFile (sLibraryFile, 1,,True) '1 means "ForReading", True means "Unicode"
	sLibrary = ts.ReadAll  'puts the entire Library in one variable
	ts.Close

	asLibraryLines = Split(sLibrary,vbCrLf) ' creates array of lines using Cartridge Return as a split point
	For iCounter = 0 to UBound(asLibraryLines)
		'because QTP does not force to have just one space between words "Public" and "Sub" (or "Public" and "Function")
		'next line will always catch Procedure's declaration line
	      If Instr(asLibraryLines (iCounter), "Public") > 0 And (Instr(asLibraryLines (iCounter), "Sub") > 0 Or Instr(asLibraryLines (iCounter), "Function") > 0) Then
			asLibraryLines (iCounter) = Trim(Replace(asLibraryLines (iCounter), " ",""))' removing all spaces before and inside the declaration line
			 Select Case UCase(Mid(asLibraryLines (iCounter), 7,1)) '7th character can be "F" (Function) or "S" (Sub)
					Case "F": sProcedureName = Mid (Trim(asLibraryLines (iCounter)), 15) 'length of "PublicFunction" = 14
					Case "S": sProcedureName = Mid (Trim(asLibraryLines (iCounter)), 10) 'length of "PublicSub" = 9
			End Select
			'to retrieve Procedure name without any arguments (if any)
			If Instr(sProcedureName, "(") > 0 Then sProcedureName = Left(sProcedureName, Instr(sProcedureName, "(")-1)
			iMistakeCounter = 0 'it will count how many lines of code should be corrected inside the same procedure
			While InStr(asLibraryLines (iCounter), "End") = 0 Or (InStr(asLibraryLines (iCounter), "Sub") = 0 And InStr(asLibraryLines (iCounter), "Function") = 0)
				iCounter =iCounter +1'move through every line of the Procedure
				If Instr(asLibraryLines (iCounter), "errHandler") > 0 Then 'if Error Handler's line  is found
					If Instr(asLibraryLines (iCounter), sProcedureName) = 0 Then 'if 2nd argument does not match Procedure's name
						iMistakeCounter = iMistakeCounter +1
						If bMistakesFound = False Then bMistakesFound = True    
					End If
				End If
			Wend
			 If iMistakeCounter =1 Then Print sProcedureName & ": " & iMistakeCounter & " occurrence  found" 
			 If iMistakeCounter > 1 Then Print sProcedureName & ": " & iMistakeCounter & " occurrences  found"	
		End If
	Next 'icounter
	 If bMistakesFound = False Then Print "No 2nd Argument mistakes have been detected!"
	Msgbox "Library screening test completed!", vbExclamation
End Sub

'******************************************************************************************************************
'	Name: 	ehCheckHeaderFormat 
'	Purpose: To detect Procedure's headers formatting problems 	  
'	Creator: unknown
'
'	Param: sLibraryFile| required 
'	AllowedRange: 
'	Description:  Library file to be screened. As example, if you need to screen apl_lib.vbs you will pass
'                             ehCheckHeaderFormat  "C:\Automation\Testware\Apps\APL\Lib\apl_lib.vbs"

'	Returns: Log file with all found discrepancies (if any)
'******************************************************************************************************************'
Public Sub ehCheckHeaderFormat(sLibraryFile) 
   'AM - added 08/10/2009
	
	Dim fso, ts, sLibrary, asLibraryLines, sProcedureName, bMistakesFound, iHeaderContent, iCounter

	bMistakesFound = False
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set ts = fso.OpenTextFile (sLibraryFile, 1,,True) '1 means "ForReading", True means "Unicode"
	sLibrary = ts.ReadAll  'puts the entire Library in one variable
	ts.Close

	asLibraryLines = Split(sLibrary,vbCrLf) ' creates array of lines using Cartridge Return as a split point
	For iCounter = 0 To UBound(asLibraryLines)
		If Instr(asLibraryLines (iCounter), "End") > 0 And (Instr(asLibraryLines (iCounter), "Sub") > 0 Or Instr(asLibraryLines (iCounter), "Function") > 0) Then
		      iHeaderExistance = 0: iHeaderContent=0
			While InStr(asLibraryLines (iCounter), "Public ") = 0 And  iCounter <  UBound(asLibraryLines) And _
				   (InStr(asLibraryLines (iCounter), " Sub") = 0 Or InStr(asLibraryLines (iCounter), " Function") = 0) 
				iCounter =iCounter +1'move through every line until we meet the declaration od new procedure
				'we are just looking for some basic things - some other words are also belong to the header, i.e. "Creator", "Param", AllowedRange", "Description" 
				If Instr(asLibraryLines (iCounter), "Name:") > 0 Then iHeaderContent = iHeaderContent+1  
				If Instr(asLibraryLines (iCounter), "Purpose:") > 0 Then iHeaderContent = iHeaderContent+1 
				If Instr(asLibraryLines (iCounter), "Returns:") > 0 Then iHeaderContent = iHeaderContent+1  
			Wend

			If  iHeaderContent <> 3 Then
				If bMistakesFound = False then bMistakesFound = True
				asLibraryLines (iCounter) = Trim(Replace(asLibraryLines (iCounter), " ",""))' removing all spaces before and inside the declaration line
				Select Case UCase(Mid(asLibraryLines (iCounter), 7,1)) '7th character can be "F" (Function) or "S" (Sub)
					Case "F": sProcedureName = Mid (Trim(asLibraryLines (iCounter)), 15) 'length of "PublicFunction" = 14
					Case "S": sProcedureName = Mid (Trim(asLibraryLines (iCounter)), 10) 'length of "PublicSub" = 9
			       End Select
				If Instr(sProcedureName, "(") > 0 Then sProcedureName = Left(sProcedureName, Instr(sProcedureName, "(")-1)'to skip arguments (if any)
				Print "The header of " &  sProcedureName & " is not properly formatted"
			End If
		End If
	Next
	If bMistakesFound = False Then Print "No header's formatting mistakes have been detected!"
	Msgbox "Library screening test completed!", vbExclamation
End Sub

'**************************************************************************************************
'	Name: LogText
'	Purpose: This sub prints to the error log.  It concatenates the current time
'		onto the log statement that is passed in.  If the g_bLogToPrintWindow flag is
'		set to True, this function will also print to the print window. For use within functions and subs
'		only.
'	Creator: Michael J. Nohai

'		Param: sLine|required
'		AllowedRange: 
'		Description: The line to print to the log.  The current time is also concatenated 
'			to the beginning of the log entry.
'
'	Returns: N/A
'***************************************************************************************************
Public Sub LogText(ByVal sLine)
	Dim fso, sLogFile, sHour, sMinute, sSecond, dtTime, oStream
	
	dtTime = Time() 'get the current time
	' Parse the time into a readable, usable and consistent time string
	sHour = Hour(dtTime)
	sMinute = Minute(dtTime)
	sSecond = Second(dtTime)
	If Len(sHour) < 2  Then sHour = "0" & sHour
	If Len(sMinute) < 2 Then sMinute = "0" & sMinute
	If Len(sSecond) < 2 Then sSecond = "0" & sSecond
	dtTime = sHour & ":" & sMinute & ":" & sSecond

	'Concatenate the time string to the beginning of the line to be logged
	'Insert tags if we are validating the log.
	If CBool(g_bIsValidation) = True Then
		sLine = "(" & dtTime & ") <Step> " & sLine & " </Step>"
	Else
		sLine = "(" & dtTime & ") " & sLine
	End If

	' Open or create the log file and write the line to the file.
	sLogFile = Environment("ResultDir") & "\Log.txt"
	Set fso = CreateObject("Scripting.FileSystemObject")
	
    Set oStream = CreateObject("ADODB.Stream")
    oStream.Open
    oStream.Charset = "utf-8"

    If fso.FileExists(sLogFile) Then
    	oStream.LoadFromFile sLogFile
    	oStream.Position = oStream.Size
    End If

    oStream.LineSeparator = -1 'adCRLF
    oStream.WriteText sLine, 1
    oStream.SaveToFile sLogFile, 2 'OverWrite
    oStream.Close

    Set oStream = Nothing
    Set fso = Nothing
	
	' If routing to the print window, write the line to the print window.
	If CBool(g_bLogToPrintWindow) = True Then
		'Clear the console in the beginning of Script run.
		If bClearPrintWindow = True Then
			ClearToConsole()
		End If
		' Print  to console.
		PrintToConsole sLine
	End If
	
End Sub

'**************************************************************************************************
'	Name: GenerateResults
'	Purpose: This sub generates a success/failure flag and ships flag+log file to results
'					directory.
'	Creator: Dan Hoizner & Michael J. Nohai
'
'	Param: sTestName|required
'	AllowedRange: 
'	Description: Name of currently executing test script.
'
'	Param: sResultsDir|required
'	AllowedRange: 
'	Description: Aggregated results directory.
'
'	Param: sURL|required
'	AllowedRange: 
'	Description: The URL of the site.
'
'	Returns: N/A
'***************************************************************************************************
Public Sub GenerateResults(sTestName, sResultsDir, ByVal sURL)
	Dim bExists
	Dim sFileName, sText, sMode, asErrors, asWarnings

	If CBool(g_bBatchRunCI) = True Then
		bExists = winIFFileExists(Environment("ResultDir"),"Log.txt")
		winCreateFolderRecursive(sResultsDir)
		If bExists = True Then

			'Copy to CI Results directory.
			winCopyFileToLocation Environment("ResultDir") & "\Log.txt", sResultsDir & "\" & sTestName & ".log"

			'Parse the file and generate a summary log.
			winLogFileParse sResultsDir & "\" & sTestName & ".log", asErrors, asWarnings

			If asErrors(0) <> "" Then
				sFileName = sResultsDir & "\" & sTestName & ".failure"
				sText = "Daily " & sTestName & " Run: Failures encountered" & vbCrLf & _
					    "Script Execution Time: " & Now & vbCrLf & _
					    "URL used: " & sURL & vbCrLf & _
					    "SQA needs to look into the errors found."
				sMode = "OverWrite"
				winPrintToFile sFileName, sText, sMode
			ElseIf asWarnings(0) <> "" Then
				sFileName = sResultsDir & "\" & sTestName & ".warning"
				sText = "Daily " & sTestName & " Run: Warnings encountered" & vbCrLf & _
					    "Script Execution Time: " & Now & vbCrLf & _
					    "URL used: " & sURL & vbCrLf & _
					    "SQA needs to look into the warnings found."
				sMode = "OverWrite"
				winPrintToFile sFileName, sText, sMode
			Else
				sFileName = sResultsDir & "\" & sTestName & ".success"
				sText = "Daily " & sTestName & " Run: No Failures or Warnings found." & vbCrLf & _
						"Script Execution Time: " & Now & vbCrLf & _
						"URL used: " & sURL
				sMode = "OverWrite"
				winPrintToFile sFileName, sText, sMode
			End If
		End If
	End If
End Sub

'**************************************************************************************************
'	Name: GenerateRunComplete
'	Purpose:This sub generates a 'run.complete' flag in the results directory.
'	Creator: Dan Hoizner & Michael J. Nohai
'
'	Param: sResultsDir|required
'	AllowedRange: 
'	Description: Aggregated results directory.
'
'	Returns: N/A
'***************************************************************************************************
Public Sub GenerateRunComplete(sResultsDir)
	Dim sFileName, sText, sMode
	
	winCreateFolderRecursive(sResultsDir)
	sFileName = sResultsDir & "\run.complete"
	sText = " "
	sMode = "OverWrite"
	
	winPrintToFile sFileName, sText, sMode
End Sub

'**************************************************************************************************
'	Name: CheckForBuildSuccessFlag
'	Purpose:This sub checks to see if a build flag is present. If it is not found, 
'		the current QTP batch will stop.
'	Creator: Michael J. Nohai
'
'	Param: sResultsDir|required
'	AllowedRange: 
'	Description: Aggregated results directory.
'
'	Param: sFlagDirectory|required
'	AllowedRange: 
'	Description: The directory to look for the SuccessFlag flat file.
'
'	Param: iTimeOut|required
'	AllowedRange: 
'	Description: The allotted time to search for the file in seconds.
'
'	Returns: N/A
'***************************************************************************************************
Public Sub CheckForBuildSuccessFlag(sResultsDir, sFlagDirectory, iTimeOut)

	Dim bFileExists

	sFlagDirectory = Trim(sFlagDirectory)
	sResultsDir = Trim(sResultsDir)

	bFileExists = utHoldForFiles(sFlagDirectory, "deploy.success", 1, CInt(iTimeOut))
	
	If bFileExists = False Then
		PrintToLog "Script Execute Time: " & Now()
		PrintToLog "No build pushed today as there were no new code check-ins"
		winCopyFileToLocation Environment("ResultDir") & "\Log.txt", sResultsDir & "\" & g_sScriptName & ".log"
		GenerateRunSkip sResultsDir
	End If
End Sub

'**************************************************************************************************
'	Name: GenerateRunSkip
'	Purpose: This sub generates a 'run.skip' flag in the results directory.
'	Creator: Michael J. Nohai
'
'	Param: sResultsDir|required
'	AllowedRange: 
'	Description: Aggregated results directory.
'
'	Returns: N/A
'***************************************************************************************************
Public Sub GenerateRunSkip(sResultsDir)
	Dim sFileName, sText, sMode
	
	winCreateFolderRecursive(sResultsDir)
	sFileName = sResultsDir & "\run.skip"
	sText = " "
	sMode = "OverWrite"
	
	winPrintToFile sFileName, sText, sMode
End Sub


'**********************************************************************
'	Name: EmailBatchResults
'	Purpose: This Sub emails the results of the batch run.
'	Creator: Michael J. Nohai
'
'		Param: sFromAddress|required
'		AllowedRange:
'		Description: The address to send the email from.
'
'		Param: sToAddress|required
'		AllowedRange:
'		Description: The address to send the email to.
'
'		Param: sEmailPwd|required
'		AllowedRange:
'		Description: Encrypted Email Password
'
'		Param: sKeyPath|required
'		AllowedRange:
'		Description: Path to the key file to decrypt the password
'
'		Param: sResultsDir|required
'		AllowedRange: 
'		Description: Aggregated results directory.
'
'	Returns: N/A
'**********************************************************************
Public Sub EmailBatchResults(sFromAddress, sToAddress, sEmailPwd, sKeyPath, sResultsDir)
	
	
	Dim sSub, sBody, sAttach, oFso, sFolder, sFile, iWarnCtr, iErrCtr, iPassCtr
	iWarnCtr = 0
	iErrCtr = 0
	iPassCtr = 0

	Set oFso = CreateObject("Scripting.FileSystemObject")

	If oFso.FileExists(sResultsDir & "\run.skip") Then
		sSub = " QTP Status: Batch Run Skipped."
		sBody = " QTP Status: Batch Run Skipped." & Vbcrlf &_
				" Execution Date and Time: " & Now() & Vbcrlf &_
				" URL used: "& g_sURL & Vbcrlf & Vbcrlf &_
				" See attached file(s) for further information."
		sAttach = sResultsDir & "\*.*"

		' Only Send email if we have the correct values.
		If sEmailPwd <> "" And sKeyPath <> "" And _
			sFromAddress <> "" And sToAddress <> "" Then
			winSendEmail sFromAddress, sToAddress, sSub, sBody, sAttach, sEmailPwd, sKeyPath
		End If

	ElseIf oFso.FileExists(sResultsDir & "\run.complete") Then
		
		'Get all the files in the folder.
		Set sFolder = oFso.GetFolder(sResultsDir)

		'Count .warning, .failure, and .success flat files.
		For Each sFile In sFolder.Files
			If Instr(1, sFile.Name, ".warning", 1) > 0 Then
				iWarnCtr = iWarnCtr + 1
			ElseIf Instr(1, sFile.Name, ".failure", 1) > 0 Then
				iErrCtr = iErrCtr + 1
			ElseIf Instr(1, sFile.Name, ".success", 1) > 0 Then
				iPassCtr = iPassCtr + 1
			End If
		Next
				
		sSub = " QTP Status: Batch Run Successfully Completed."
		sBody = " QTP Status: Batch Run Successfully Completed." & Vbcrlf &_
				" Execution Date and Time: " & Now() & Vbcrlf &_
				" URL used: "& g_sURL & Vbcrlf & Vbcrlf &_
				" Total Number of Scripts Executed: " & iPassCtr + iErrCtr + iWarnCtr & Vbcrlf &_
				Vbtab & "Passed: " & iPassCtr & Vbcrlf &_
				Vbtab & "Errors: " & iErrCtr & Vbcrlf &_
				Vbtab & "Warnings: " & iWarnCtr & Vbcrlf & Vbcrlf &_
				" See attached file(s) for detailed and summary logging content."
		sAttach = sResultsDir & "\*.*"

		' Only Send email if we have the correct values.
		If sEmailPwd <> "" And sKeyPath <> "" And _
			sFromAddress <> "" And sToAddress <> "" Then
			winSendEmail sFromAddress, sToAddress, sSub, sBody, sAttach, sEmailPwd, sKeyPath
		End If

	End If

	Set oFso = Nothing

End Sub

'**************************************************************************************************
'	Name: CheckForBuildSuccessJenkins
'	Purpose: This sub checks the last build status from a Jenkins rss feed.
'	Creator: Michael J. Nohai
'
'		Param: sURL|required
'		AllowedRange: 
'		Description: The URL for the RSS feed.
'
'		Param: sResultsDir|required
'		AllowedRange: 
'		Description: Aggregated results directory.
'
'	Returns: N/A
'***************************************************************************************************
Public Sub CheckForBuildSuccessJenkins(ByVal sURL, sResultsDir)

	Dim oReq, oXML, colNodes, sNode, oStatus, oDateTime, sDateTime

	Set oReq = CreateObject("MSXML2.XMLHTTP.3.0")
	oReq.Open "GET", sURL, False
	oReq.Send

	Set oXML = CreateObject("Msxml2.DOMDocument")
	oXML.loadXml(oReq.responseText)
	Set colNodes = oXML.getElementsByTagName("entry")
	
	For Each sNode in colNodes

		'CI DailyBuild (MAIN JOB) #296 (broken since build #295)
		Set oStatus = sNode.firstChild

		'2013-05-01T15:20:07Z
		Set oDateTime = sNode.lastChild

		sDateTime = oDateTime.Text

		'Replace characters and convert to Date Time.
		sDateTime = Replace(sDateTime, "T"," ")
		sDateTime = Replace(sDateTime, "Z","")
		sDateTime = CDate(sDateTime)

		PrintToLog "Build Name: " & oStatus.Text
		PrintToLog "Build Date: " & sDateTime

		If Instr(1, oStatus.Text, "broken", 1) > 0 Or _
			Instr(1, oStatus.Text, "abort", 1) > 0 Then
			GenerateRunSkip sResultsDir
		End If

		winCopyFileToLocation Environment("ResultDir") & "\Log.txt", sResultsDir & "\" & g_sScriptName & ".log"

		Exit For
	Next

	Set oXML = Nothing
	Set oReq = Nothing

End Sub

'**************************************************************************************************
'	Name: RecoveryScenario
'	Purpose: This sub is empty and is placed in the err_lib.vbs file as a 
'		fail safe in case the script and or library do not contain a sub with this name.  
'		NOTE:  This sub is called by the error handler in the event of an error with the 
'		severity of micFail.  This sub will take no action other than to log that it was
'		called.
'	Creator: Mark Clemens
'
'	Returns: N/A
'***************************************************************************************************
Public Sub RecoveryScenario()
	
		'If the script gets failed then the run result will copy into the rootpath.
		If g_bDebugMode = False Then
			utCopyRunResults g_sAppName, g_sRunType, g_sRootPath
		End If    
		
		PrintToLog "Recovery scenario function in the err_lib.vbs library was called."
		'winBrowserCloseAll
		SystemUtil.CloseProcessByName "iexplore.exe"
	
End Sub

Public Sub ProcessResults()
	Dim fso
	
	Set fso = CreateObject("Scripting.FileSystemObject")
	
	If g_sResultsCopyPath = "" Then
		g_sResultsCopyPath = "\\ftc-wcpertst601\Automation\RunResults\unknown"
	End If
	
	fso.CopyFolder Environment("ResultDir"),g_sResultsCopyPath & "\" & GetFSDateTimeStamp( Now ),False
	
	
	
End Sub

Public Sub RecoveryScenarioEnvCert()
'	g_oAppRecordSet.MoveNext
	PrintToLog "Recovery scenario function EnvCert in the Driver was called."
	SystemUtil.CloseProcessByName "iexplore.exe"
'	winBrowserCloseAll
'	SystemUtil.CloseProcessByName "Moodys.Connect.exe"
'	err.clear
'	PrintToLog "========================================================="  
'	utCopyRunResultsLocal g_sAppName,  g_sRunType,  Environment("g_sRootLocalPathApp")
'	Dim fso, folder, f, sSourceFolderPath
'	sSourceFolderPath = Environment("ResultDir")
'	Set fso = CreateObject("Scripting.FileSystemObject")    
'	Set folder = fso.GetFolder(sSourceFolderPath)
'	For each f in folder.Files
'		f.Delete True		
'	Next
'	Set fso = Nothing
'	MainTestEnviCertTesting
End Sub
