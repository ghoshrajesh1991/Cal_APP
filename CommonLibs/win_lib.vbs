Option Explicit

'*************************** MAINTAIN THIS HEADER! *********************************
'     Library Name:     win_lib.vbs
'     Purpose:          Contains windows-related functions.
'
'---------------------------------------------------------------------------------
'
'********************************************************************************** 
 
'**********************************************************************************
'                             REPOSITORY LOAD
'**********************************************************************************

'If RepositoriesCollection.Find("C:\Testware\Common\ObjectRepositories\General.tsr")=-1 Then
'	RepositoriesCollection.Add "C:\Testware\Common\ObjectRepositories\General.tsr"
'End If
'If RepositoriesCollection.Find("C:\Testware\Common\ObjectRepositories\ie.tsr")=-1 Then
'	RepositoriesCollection.Add "C:\Testware\Common\ObjectRepositories\ie.tsr"
'End If



'**********************************************************************************
'                           PRIVATE CONSTANTS and VARIABLES
'**********************************************************************************
Private Const SleepTime_Max = 300 

'**********************************************************************************
'                           PUBLIC CONSTANTS and VARIABLES
'**********************************************************************************


Public g_sTestwarePath
'g_sTestwarePath = winEnviron("TestwarePath")

extern.Declare micHwnd,"GetForegroundWindow","User32.dll",""
'BOOL SetWindowText(          HWND hWnd,   LPCTSTR lpString);

extern.Declare micInteger, "SetWindowText","User32.dll","",micHwnd, micString

extern.Declare micLong,"GetParent","user32.dll","",micLong
extern.Declare micLong,"GetWindow","user32.dll","GetWindow",micLong,micLong
extern.Declare micLong, "FindWindow","user32.dll","FindWindowA", micString, micString
extern.Declare micLong,"GetWindowText","user32.dll","GetWindowTextA",micLong,micString+micByRef,micLong
extern.Declare micLong, "GetWindowThreadProcessId","user32.dll","",micLong, micLong+micByRef 
extern.Declare micLong, "GetDesktopWindow","user32.dll","GetDesktopWindow"
extern.Declare micInteger, "IsWindowVisible","user32.dll","IsWindowVisible",micLong

' If this is set to True, the error handler will print memory info to the log each time
' it is called.
Public g_bPrintMemInfo, g_sScriptName, g_bScreenshot

'Default SSL flag for Email.
Public g_bEmailUseSSL
g_bEmailUseSSL = False

'Default Port Number for Email.
Public g_sEmailPort
g_sEmailPort = 25

'Global variable to store the SMTP server.
Public g_sSMTPServer

Public GW_HWNDNEXT
GW_HWNDNEXT = 2


'**********************************************************************************
'                             PRIVATE FUNCTIONS
'**********************************************************************************

'**********************************************************************************
'                                PUBLIC FUNCTIONS
'**********************************************************************************

Public Function GetHwnd(ByVal ProcessID, ByVal alRetHwnds ) 

    Dim lHwnd , RetHwnd , RetPID 
	Dim GW_CHILD, GW_HWNDNEXT
	Dim iParentProcID, iProcID, iCounter, bHWndFound
    GW_CHILD = 5
	GW_HWNDNEXT = 2

    lHwnd = extern.GetDesktopWindow()
    RetHwnd = extern.GetWindow(lHwnd, GW_CHILD)
    RetPID = 0
    Do While RetHwnd
		bHWndFound = False
		For iCounter = 0 to UBound(alRetHwnds)
			If alRetHWnds(iCounter) = RetHWnd Then
				bHWndFound = True
				print "bHWndFound = True"
				Exit For
			End If
		Next
		If bHWndFound = False Then
			If extern.IsWindowVisible(RetHwnd) Then ' or use IsWindow
				print "WindowVisible"
				iParentProcID = extern.GetWindowThreadProcessId(RetHwnd, RetPID)
				If RetPID = ProcessID Then
					print "ProcID found"
					Exit Do
				End If
			End If
			RetHwnd = extern.GetWindow(RetHwnd, GW_HWNDNEXT)
			print "get next RetHwnd"
		Else
			Exit Do
		End If
    Loop
    
    GetHwnd = RetHwnd
	print "Assign HWnd"
End Function

Public Function GetHwnd2(ByVal ProcessID, byVal colWindows, byVal alRetHwnds) 

    Dim lHwnd , RetHwnd , RetPID 
	Dim GW_CHILD, GW_HWNDNEXT
	Dim iParentProcID, iProcID, iCounter, bHWndFound, iHwndCounter
	RetPID = 0

	For iCounter = 0 to colWindows.Count
		RetHwnd = colWindows(iCounter).GetROProperty("hWnd")
		bHWndFound = False
		For iHwndCounter = 0 to UBound(alRetHwnds)
			If alRetHWnds(iHwndCounter) = RetHWnd Then
				bHWndFound = True
				
				Exit For
			End If
		Next
		If bHWndFound = False Then
			If extern.IsWindowVisible(RetHwnd) Then ' or use IsWindow
				iParentProcID = extern.GetWindowThreadProcessId(RetHwnd, RetPID)
				If RetPID = ProcessID Then
					
					Exit For
				End If
			End If
		End If

	Next
    
    GetHwnd2 = RetHwnd
End Function


Public Function ProcIDFromWnd(ByVal hwnd) 
   Dim idProc, iParentProcID
   idProc = 0
   ' Get PID for this HWnd
   iParentProcID = extern.GetWindowThreadProcessId(hwnd, idProc)
   
   ' Return PID
   ProcIDFromWnd = iParentProcID
End Function
      
Public Function GetWinHandle(hInstance)
   Dim tempHwnd 
   
   ' Grab the first window handle that Windows finds:
   tempHwnd = extern.FindWindow(vbNullString, vbNullString)
   
   ' Loop until you find a match or there are no more window handles:
   Do Until tempHwnd = 0
      ' Check if no parent for this window
      If extern.GetParent(tempHwnd) = 0 Then
         ' Check for PID match
         If hInstance = ProcIDFromWnd(tempHwnd) Then
            ' Return found handle
            GetWinHandle = tempHwnd
            ' Exit search loop
            Exit Do
         End If
      End If
   
      ' Get the next window handle
      tempHwnd = extern.GetWindow(tempHwnd, 2)
   Loop
End Function


'**********************************************************************
'	Name: winCreateFolder
'	Purpose:	This function creates a folder in a specified location.
'	Creator:unknown
'
'		Param: sLocation| required | InitialEntry=sLocation
'		AllowedRange: 
'		Description: The location for the folder.'
'
'		Param: sFolder| required | InitialEntry=sFolder
'		AllowedRange: 
'		Description: The folder to create.
'
'	Returns: N/A
'**********************************************************************
Public Sub winCreateFolder(sLocation, sFolder)
	
	Dim fso, f
	Set fso = CreateObject("Scripting.FileSystemObject")
	errHandler Err, "winCreateFolder", g_iSeverity
	Set f = fso.CreateFolder(sLocation &  sFolder)
	errHandler Err, "winCreateFolder", g_iSeverity
End Sub

''**********************************************************************
'	Name: winBitmapActiveWinCapture
'	Purpose:	This function captures a bitmap of the active window
'							and saves it to the location indicated in the argument - sBMPPath.
'	Creator: Mark Clemens
'
'		Param: sBMPPath| required | InitialEntry=sBMPPath
'		AllowedRange: 
'		Description: The path to save the bitmap to
'
'	Returns: N/A
'**********************************************************************
Public Sub winBitmapActiveWinCapture(sBMPPath)
	Dim hWnd, sMsg

	sBMPPath = Trim(sBMPPath)
	
	hWnd = extern.GetForegroundWindow()
	'on error statement in case resume next is not set in qtp
	On Error Resume Next
	If clng(hWnd)=0 Then
		err.number=123123
		err.description="hWnd=0; no active window exist"
	else
		Window("hWnd:=" & hWnd).CaptureBitmap sBMPPath, True	
	End If
	

	' Within this funciton we can't call the error handler (errHandler) function
	' in order to avoid a recursive call.
	If Err.Number <> 0 Then
		sMsg = "Error capturing bitmap during run. Bitmap name is: " & vbcrlf & _
		sBMPPath & vbcrlf & _
		"Function = winBitmapActiveWinCapture" & vbcrlf & _
		"Error Number = " & Err.Number & vbcrlf & _
		"Error Description = " & Err.Description
		PrintToLog sMsg
	End If

End Sub

'**********************************************************************
'	Name: winEnviron
'	Purpose:	This function retrieves a windows environment variable.
'	Creator:Mark Clemens
'
'		Param: sVariableName| required | InitialEntry=sVariableName
'		AllowedRange: 
'		Description: The name of the variable to retrieve.
'
'	Returns: The value of the environment variable
'**********************************************************************
Public Function winEnviron(sVariableName)
	
	Dim WshShell, WshSysEnv
	Set WshShell = CreateObject("WScript.Shell")
	errHandler Err, "winEnviron",g_iSeverity
	Set WshSysEnv = WshShell.Environment("SYSTEM")
	winEnviron = WshSysEnv(sVariableName)
End Function

'**********************************************************************
'	Name: winIELaunch
'	Purpose:	This function launches Internet Explorer with the URL that is passed in..
'	Creator:Mark Clemens
'
'		Param: sURL| required | InitialEntry=sURL
'		AllowedRange: 
'		Description: The URL to use when opening IE..
'
'	Returns: The value of the environment variable
'**********************************************************************
Public Sub winIELaunch(ByVal sURL)
	

	SystemUtil.Run "iexplore", sURL

	'WinShell.Run substcmd, 1, False
	errHandler Err, "winIELaunch.", g_iSeverity

	' wait 2.5 second for the window to become the foreground window
	wait(2.5)

End Sub

'**********************************************************************
'	Name: winBrowseToFolder
'	Purpose:	This function opens a browse dialog for folders and 
'						  returns the name of the folder that is selected..
'	Creator:Mark Clemens
'
'		Param: sDialogTitle| optional| AssumedValue="Browse to folder"
'		AllowedRange: 
'		Description: The title message for the dialog..
'
'	Returns: The folder that is selected.

'**********************************************************************
Public Function winBrowseToFolder(sDialogTitle)
	
	Dim objShell, objFolder, objFolderItem, iHwnd
	Const NO_OPTIONS = 0
   
	If sDialogTitle = "" Then sDialogTitle = "Browse to folder"

	iHwnd = Window("text:=QuickTest Professional.*").GetROProperty("hwnd") 'get window's handle 
	Set objShell = CreateObject("Shell.Application")
	errHandler Err, "winBrowseToFolder",g_iSeverity
	
	Set objFolder = objShell.BrowseForFolder (iHwnd, sDialogTitle, NO_OPTIONS, "") 
	errHandler Err, "winBrowseToFolder",g_iSeverity

	Set objFolderItem = objFolder.Self
	errHandler Err, "winBrowseToFolder",g_iSeverity

	winBrowseToFolder = objFolderItem.Path
	errHandler Err, "winBrowseToFolder",g_iSeverity
End Function


'**********************************************************************
'	Name: winBrowseToFile
'	Purpose:	This function opens a browse dialog for files and 
'						  returns the name of the file that is selected..
'	Creator:Mark Clemens

'		Param: sFilter
'		AllowedRange: 
'		Description: The title message for the dialog..

'		Param: sDir
'		AllowedRange: 
'		Description: The title message for the dialog..
'
'	Returns: The file that is selected.
'**********************************************************************
Public Function  winBrowseToFile(sFilter, sDir)
	
	Dim oDialog, iResult
	
	Set oDialog = CreateObject("UserAccounts.CommonDialog") 
	oDialog.Filter = sFilter
	oDialog.FilterIndex = 1 
	oDialog.InitialDir = sDir
	iResult = oDialog.ShowOpen 
	If iResult = 0 Then 
		Msgbox "File selection is required!" 
	Else 
		winBrowseToFile = oDialog.FileName 
	End if 
End Function

'**********************************************************************
'	Name: winCompareFiles
'	Purpose:	This function executes the DOS 'fc' command which
'		compares 2 files and creates a diff file. If there are no differences,
'		the diff file will say  "no differences encountered" on the second line.
'		Otherwise, the lines with differences are listed in the diff file surrounded
'		by the lines that aren't different.  If there are no differences, the diff file is deleted.
'	Creator: Mark Clemens
'
'		Param: sFile1| required | 
'		AllowedRange: 
'		Description: The full path and file name of the first file in the comparison.
'
'		Param: sFile2| required | 
'		AllowedRange: 
'		Description: The full path and file name of the second file in the comparison.
'
'		Param: sDiffFile| required | 
'		AllowedRange: 
'		Description: The full path and file name of the file that will contain the differences, if any..
'
'		Param: bLogOnDiff| optional|AssumedValue=True 
'		AllowedRange: 
'		Description: If true, an error log entry is wrtten to the error handler function..
'
'	Returns: 0 if there are no differences, 1 if there are differences.
'**********************************************************************
Public Function winCompareFiles(sFile1, sFile2, sDiffFile, bLogOnDiff)
	
	Dim oShell
	Dim fso, f
	Dim sLines, asLines, iCounter
	Dim dtEndTime, iRet, bFound
	' Create a file system object for working with the diff file
	Set fso = CreateObject("Scripting.FileSystemObject")
	errHandler Err, "winCompareFiles",g_iSeverity
	' IF the diff file exists, delete it
	If fso.FileExists(sDiffFile) Then
		Set f = fso.GetFile(sDiffFile)
		f.Delete
     End If
	' Create a scripting shell
	Set oShell = CreateObject ("WScript.Shell")
	errHandler Err, "winCompareFiles",g_iSeverity
   ' Compare the files with the DOS command - 'fc'
	iRet = oShell.run ("cmd /C fc " + CHr(34) & sFile1 + Chr(34) & " " + Chr(34) & sFile2 + Chr(34) & " > " + Chr(34) & sDiffFile & Chr(34),2,true)
	errHandler Err, "winCompareFiles",g_iSeverity
	' Destroy the shell from memory
	Set oShell = Nothing 

	' Loop until the diff file is created.
	dtEndTime = DateAdd("s",40,Now)
	Do Until bFound = True Or dtEndTime < Now
		If fso.FileExists(sDiffFile) = True Then
			bFound = True
		End If
	Loop
	' wait an extra half second to allow the file to be full created.
	wait 0,500
	' open the diff file
	Set f = fso.OpenTextFile(sDiffFile)
	errHandler Err, "winCompareFiles",g_iSeverity
	' Get all of the text from the file and split the lines into an array
	sLines = f.ReadAll
	errHandler Err, "winCompareFiles",g_iSeverity

	' close the diff file
	f.Close
	errHandler Err, "winCompareFiles",g_iSeverity
	
	asLines = Split(sLines,vbcrlf)
	' Instantiate the CompareFiles function to a value of 1 (meaning there
	' are differences.
	winCompareFiles = 1
	' Loop through each line looking for the phrase - "no differences encountered"
	For iCounter = LBound(asLines) To UBound(asLines)
		If InStr(asLines(iCounter),"no differences encountered") > 0 Then
			' If no diffs, then set the CompareFiles function to 0
			winCompareFiles = 0
			Exit For
		End If
	Next
	If winCompareFiles = 1 Then
	' Commenting out error reporting.  This should be handled by the calling function.
'		Err.Number = g_iVERIFICATION_FAILED
'		Err.Description = "Verification of file compare failed for files:" & vbcrlf & _
'			"File 1: " & sFile1 & vbcrlf & _
'			"File 2: " & sFile2 & vbcrlf &  _
'			"Diff file: " & sDiffFile
'		errHandler Err,"winCompareFiles", micWarning
	ElseIf winCompareFiles = 0 Then
		'fso.DeleteFile sDiffFile
	End If

	Set fso = Nothing
	
End Function


'**********************************************************************
'	Name: winBrowserCloseAll
'	Purpose: Closes all IE browsers, including IE message boxes.
'	Creator: Mark Clemens & Michael J. Nohai
'
'	Returns: N/A
'**********************************************************************
Public Function winBrowserCloseAll()
	
	
	Dim dtEndTime, iCtr, oDesc, colBrows
	Dim iIndex, oBrowser, hWnd, bExists
	
	Set oDesc = Description.Create
	oDesc("micclass").Value = "Browser"

	Set colBrows = Desktop.ChildObjects(oDesc)
	errHandler Err, "winBrowserCloseAll",g_iSeverity
	 
	'Loop through the collection and close each browser
	If colBrows.Count > 0 Then
	    For iCtr = 0 To colBrows.Count - 1  	
	    	
	    	hWnd = colBrows(iCtr).GetROProperty("HWND")
			errHandler Err, "winBrowserCloseAll",g_iSeverity

			'Need to check if it exists in case browser(s) had more than one tab.
			If hWnd <> "" Then
				If Browser("hwnd:=" & hWnd).Exist(0) Then

					Window("hwnd:=" & Browser("hwnd:=" & hWnd).Object.hWnd).Activate
					errHandler Err, "winBrowserCloseAll",g_iSeverity

					Window("hwnd:=" & Browser("hwnd:=" & hWnd).Object.hWnd).Close
					errHandler Err, "winBrowserCloseAll",g_iSeverity

					dtEndTime = DateAdd("s", 30, Now())
		        	
		        	' Loop through until there are no dialogs left or 30 seconds has elapsed.
		        	Do

						If Dialog("dlgIEMsgBox").Exist(1) Then
							bExists = True
							Dialog("dlgIEMsgBox").WinButton("text:=OK").Click
						ElseIf Dialog("regexpwndtitle:=Information Bar").Exist(1) Then
							bExists = True
							Dialog("regexpwndtitle:=Information Bar").Close
						ElseIf Dialog("dlgIEConfirm").Exist(1) Then
							bExists = True
							Dialog("dlgIEConfirm").Close
						ElseIf Dialog("dlgIEDownload").Exist(1) Then
							bExists = True
							Dialog("dlgIEDownload").Close
						ElseIf Dialog("dlgFileBrowse").Exist(1) Then
							bExists = True
							Dialog("dlgFileBrowse").Close
						ElseIf Dialog("dlgIEDownloadComplete").Exist(1) Then
							bExists = True
							Dialog("dlgIEDownloadComplete").Close
						Else
							bExists = False
						End If

					Loop Until bExists = False Or Now > dtEndTime
				End If
			End If
	    Next
	End If 

End Function

'**********************************************************************
'	Name: winPrintToFile
'	Purpose: This Sub prints to a UTF-8 Encoded file.
'	Creator: Michael J. Nohai
'
'		Param: sFileName|required 
'		AllowedRange:
'		Description: The File Name to print to.
'
'		Param: sText|required 
'		AllowedRange:
'		Description: The text to print.
'
'		Param: sMode|optional 
'		AllowedRange: Append, Overwrite
'		Description: Whether or not to Append or Overwrite the existing file. Default is Append
'
'	Returns: N/A
'**********************************************************************
Public Sub winPrintToFile(sFileName, ByVal sText, sMode)
	
	
	Dim oFSO, oStream

	sFileName = Trim(sFileName)
	sText = Trim(sText)
	sMode = Trim(sMode)

	Set oFSO = CreateObject("Scripting.FileSystemObject")
	Set oStream = CreateObject("ADODB.Stream")
    oStream.Open
    oStream.Charset = "utf-8"

    If LCase(sMode) = "append" Or sMode = "" Then
	    If oFSO.FileExists(sFileName) Then
	    	oStream.LoadFromFile sFileName
	    	oStream.Position = oStream.Size
	    End If
    End If

    oStream.LineSeparator = -1 'adCRLF
    oStream.WriteText sText, 1
    oStream.SaveToFile sFileName, 2 'OverWrite
    oStream.Close

    Set oStream = Nothing
    Set oFSO = Nothing

End Sub

' **********************************************************************
'	Name:  winCreateUniqueFile
'	Purpose: This function retrieves a unique file name by iterating a counter
'		at the end of the root file name that is passed in with the path.  It checks
'		each number that is iterated until it finds a file name that does not exist.
'		It then creates the file and returns that file name. 
'	Creator:Mark Clemens

  '		Param: sRootFileName| required
'		AllowedRange: 
'		Description: The root file name to use to create a unique file.  Example:
'			'Z:\Testware\Log\BenchmarkTests\Benchmark.txt'
'			The function will attach a number to the end and keep counting until it
'			finds a name that does not exist in that path.
'
'	Returns:  The name of the unique file.
'**********************************************************************'
Public Function winCreateUniqueFile(sRootFileName)
	
	Dim asPath, asFile, iCounter, sFileName, sFileNum, sPathWOFile, fso
	Dim bUnique, bExists
	Set fso = CreateObject("Scripting.FileSystemObject")
	sPathWOFile = ""
	asPath = Split(sRootFileName,"\")
	For iCounter = 0 to UBound(asPath) - 1
			sPathWOFile = sPathWOFile & asPath(iCounter) & "\"

	Next
	
	asFile = Split(asPath(UBound(asPath)), ".")
	bUnique = False
	iCounter = 1
	Do 
		Select Case Len(iCounter)
			Case 1
				sFileNum =  "00" & iCounter
			Case 2
				sFileNum = "0" & iCounter
		End Select

		If Ubound(asFile) = 0 Then
			sFileName = asFile(0) & sFileNum
		Else
			sFileName = asFile(0) & sFileNum & "." & asFile(1)

		End If
		bExists = fso.FileExists(sPathWOFile & sFileName)
		If bExists = False Then
			bUnique = True
		End If
		iCounter = iCounter + 1
	Loop Until bUnique = True

	fso.CreateTextFile (sPathWOFile & sFileName)

	Set fso = Nothing

	winCreateUniqueFile = sPathWOFile & sFileName

   
End Function


' **********************************************************************
'	Name:  winGetLastFile
'	Purpose: This function retrieves either the first or last file in a directory
'		based on the root that is passed in.  It can be used in conjunction with the
'		'winCreateUniqueFile' function to retrieve the last file name that would
'		have been created by that function.		 
'	Creator:Mark Clemens
'
  '		Param: sRootFileName| required
'		AllowedRange: 
'		Description: The root file name to use to retrieve the filename.  Example:
'			'Z:\Testware\Log\BenchmarkTests\Benchmark.txt'
'			The function searches the directory based on  a number at the end. For example,
'			this function, based on the example, might find the file name:
'			'Z:\Testware\Log\BenchmarkTests\Benchmark008.txt'
'
'	Returns:  The name of the unique file.
'**********************************************************************'
Public Function winGetLastFile(sRootFileName)
	
	Dim asPath, asFile, iCounter, sFileName, sFileNum, sPathWOFile, sPrevFileName
	Dim fso, bUnique, bExists
	Set fso = CreateObject("Scripting.FileSystemObject")
	sPrevFileName = sRootFileName
	sPathWOFile = ""
	asPath = Split(sRootFileName,"\")
	For iCounter = 0 to UBound(asPath) - 1
			sPathWOFile = sPathWOFile & asPath(iCounter) & "\"

	Next
	
	asFile = Split(asPath(UBound(asPath)), ".")
	bUnique = False
	iCounter = 1
	Do 
		Select Case Len(iCounter)
			Case 1
				sFileNum =  "00" & iCounter
			Case 2
				sFileNum = "0" & iCounter
		End Select

		If Ubound(asFile) = 0 Then
			sFileName = asFile(0) & sFileNum
		Else
			sFileName = asFile(0) & sFileNum & "." & asFile(1)
		End If
		bExists = fso.FileExists(sPathWOFile & sFileName)
		If bExists = False Then
			bUnique = True
		Else
			sPrevFileName = sFileName
		End If
		iCounter = iCounter + 1
	Loop Until bUnique = True

	Set fso = Nothing

	winGetLastFile = sPathWOFile & sPrevFileName

End Function
' **********************************************************************
'	Name:  winDelFiles
'	Purpose: This function delets all the files in the specified folder.		 
'	Creator:Mark Clemens
'
'		Param: fPath| required
'		AllowedRange: 
'		Description: Path to the folder is given to delete the files.  
'  Example:
'			'Z:\Testware\Log\BenchmarkTests'
'
'	Returns:  N/A.
'**********************************************************************'
Public Sub  winDelFiles(fPath)
  

  Dim  fso,fld,sfile
  Set fso = CreateObject("Scripting.FileSystemObject")
  Set fld = fso.GetFolder(fPath)
	
  For Each sfile In fld.Files
	fso.DeleteFile sfile.path,True
  Next

  Set fso = Nothing

End Sub

'**********************************************************************
'	Name:  winCountFiles
'	Purpose: This function takes folder path as input and returns the number of files at the location.		 
'	Creator:Chaitanya
'
'	Param: fPath| required
'	AllowedRange: 
'	Description: Path to the folder is given to Count the files.  
'  Example:
'			'Z:\Testware\Log\BenchmarkTests'
'
'	Returns:  returns an integer value of the number of files at the location
'**********************************************************************'
Public Function winCountFiles(ByVal fPath)

   	Dim fso,flder,intCount
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set flder = fso.GetFolder(fPath)
	If fso.FolderExists(fPath) Then
	   Set flder = fso.GetFolder(fPath)
	   intCount  = flder.Files.Count
   End If

   Set fso = Nothing

   winCountFiles = intCount

End Function

' **********************************************************************
'	Name: winSendEmail
'	Purpose: This takes in the value of from, to, subject, body and attachment(s) file path 
'		and send an email to the specified email address.
'	Creator: Chaitanya Katta
'   
'		Param: sFrom | required
'		Allowed Range:
'   	Description: Sender email address.
'
'   	Param:  sTo | required
'		Allowed Range:
'   	Description: Receiver(s) email address in comma delimited form.
'
'   	Param: sSub | Required
'   	Allowed Range:
'   	Descrpition: Subject of the email .
'
'   	Param: sBody | required
'   	Allowed Range: 
'   	Description: Body of the email.
'
'		Param: sAttach | Required
'   	Allowed Range:
'   	Description: File(s) with path to be attached in the email in pipe delimited format.
'			Ex 1: C:\Testware\Results\test1\Log.txt|C:\Testware\test2\Results\test2_SummaryLog.txt
'			Ex 2: C:\Testware\Results\test1\*.*
'
'   	Param: sPassword | Required
'   	Allowed Range:
'   	Description: Encrypted password for the stmp server to send 
'
'   	Param: sKeyPath | Required
'   	Allowed Range:
'   	Description: Key that is used to encrypt 
'
'   Returns:  N/A
'**********************************************************************'
Public Sub winSendEmail(sFrom, sTo, sSub, sBody, sAttach, sPassword, sKeyPath)
  

	Dim objMessage, iCtr, asAttach, sKey, oFso, sFolder, sFile, sPath

	Set objMessage = CreateObject("CDO.Message") 
	' Set the subject of the message
	objMessage.Subject = sSub
	' Set from for the email
	objMessage.From = sFrom
	' Set the to email address
	objMessage.To = sTo
	objMessage.TextBody = sBody
	
	If sAttach <> ""  Then

		asAttach = Split(sAttach,"|")
		
		For iCtr = 0 to UBound(asAttach)

			'MJN - Check to see if we want to attach all files in a folder.
			If InStr(1, asAttach(iCtr), "\*", 1) > 0 Then

				'Get the path
				Set oFso = CreateObject("Scripting.FileSystemObject")
				sPath = Left(asAttach(iCtr), InstrRev(asAttach(iCtr), "\") -1)
				
				'Get all the files in the folder.
				Set sFolder = oFso.GetFolder(sPath)

				'Attach each file in the folder.
				For Each sFile In sFolder.Files
					objMessage.AddAttachment(sFile.Path)
				Next
			Else
				objMessage.AddAttachment(asAttach(iCtr))
			End If	
		Next
	End If

	sKey = winGetLocalEncKey(sKeyPath)
	sPassword = utDecryptString(sPassword,sKey)

	objMessage.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
	objMessage.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
	objMessage.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = g_sSMTPServer ' No Default
	objMessage.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = g_sEmailPort 'Default is 25
	objMessage.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = g_bEmailUseSSL 'Default is False
	objMessage.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusername") = sFrom
	objMessage.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendpassword") = sPassword
	objMessage.Configuration.Fields.Update
	objMessage.send
	
	If Err.number <> 0  Then
		errHandler Err,"winSendEmail",g_iSeverity
	End If

	Set objMessage = Nothing
End Sub

' **********************************************************************
'	Name:  winGetMemInfo
'	Purpose: This function returns the memory info for the processes defined in the argument 
'		that is passed in.  The memory info is returned as a delimited string.  The first line of the string
'		are the column headers:
'			"Process", "ProcID","Page Faults","PeakVirtualSize","PeakWorkingSetSize", "ThreadCount","VirtualSize","WorkingSetSize"
'		For each process passed in, another tab delimited line is added with the values for the above items.  If 'all' is passed in for the
'		processes, memory info for all processes will be returned.
'	Creator:Mark Clemens
'
'		Param: sProcesses|required
'		Allowed Range:
'       Description : A string of the processes to retrieve memory info for, with each delimited by the caret '^' symbol.  If 'all' is passed 
'			in the function will return memory info for all current processes..
'
'		Param: bRetrieveWinTitles|required
'		Allowed Range:
'       Description : Indicates whether the titles of the browsers have to retrived or not.
'      
'	Returns:  The memory info for the requested processes as defined in the function and argument descriptions.
'**********************************************************************'
Public Function winGetMemInfo(sProcesses, bRetrieveWinTitles)
	
	Dim sComputer, objWMIService, colItems, objItem, iProcCounter
	Dim asProcesses, sMemString, sProcString, bProcFound
	Dim sWinTitle, iLength, iHwnd, iProcID, iRet, iMaxLength, oProp
	Dim iCode, alHWndsRetrieved(), iHWndCounter
	Dim sWinDesc, colWindows

	If bRetrieveWinTitles = "" Then
		bRetrieveWinTitles = False
	End If

	If bRetrieveWinTitles = True Then
		Set sWinDesc = Description.Create
		sWinDesc("micclass").Value = "window"
		Set colWindows = Desktop.ChildObjects(sWinDesc)
	End If



	iHWndCounter = -1

	iMaxLength = 100
	' Initialize the memory string that will eventually be returned to be the column headers for memory info.
	sMemString = "Process" & vbTab & "ProcID" & vbTab & "Page Faults" & vbTab & "PeakVirtualSize" & vbTab & _
		"PeakWorkingSetSize" & vbTab & "ThreadCount" & vbTab & "VirtualSize" & vbTab & "WorkingSetSize" & vbTab & "Window text"

	' If 'all' was not passed in, split the processes by the caret delimiter
	asProcesses = Split(sProcesses, "^")

	' the period '.' means the local computer.
	sComputer = "." 

	' Loop through the array of processes.

	For iProcCounter = 0 to  UBound(asProcesses)
		bProcFound = False

		'  Get the WMI service object
		Set objWMIService = GetObject("winmgmts:" _
		& "{impersonationLevel=impersonate}!\\" _ 
		& sComputer & "\root\cimv2") 


		'Set objWMIService = GetObject("winmgmts:\\" & sComputer & "\root\cimv2") 
		' Get a collection of all of the processes
		'Set colItems = objWMIService.ExecQuery("Select * from Win32_Process",,48) 
		Set colItems = objWMIService.ExecQuery("Select * from Win32_Process") 
		' Loop through each item in the collection of processes to get the info.
		For Each objItem in colItems 
			' If the process name from the collection matches the process from the array, or if 'all' was passed in, add the 
			' processes memory info to the string to be returned.
			If asProcesses(iProcCounter) = objItem.Name Or LCase(asProcesses(iProcCounter)) = "all" Then
				bProcFound = True

				If bRetrieveWinTitles = True Then

					iProcID = objItem.ProcessId
					iHWndCounter = iHWndCounter + 1
					ReDim Preserve alHwndsRetrieved(iHWndCounter)
					alHwndsRetrieved(iHWndCounter) = 0
					iHwnd = 0
					iHwnd = GetHwnd2(iProcID, colWindows, alHwndsRetrieved)
					alHwndsRetrieved(iHWndCounter) = iHwnd
	
					'iHwnd = GetWinHandle(iProcID)
					'iHwnd = CLng(objItem.handle)
					sWinTitle = ""
					If iHwnd <> 0  Then
						iLength = extern.GetWindowText(iHwnd, sWinTitle, iMaxLength)
					End If
				End if
				sProcString = objItem.Caption & vbTab & objItem.ProcessId & vbTab & objItem.PageFaults & vbTab & _
					objItem.PeakVirtualSize & vbTab & objItem.PeakWorkingSetSize & vbTab & objItem.ThreadCount  & vbTab & _
					objItem.VirtualSize & vbTab & objItem.WorkingSetSize & vbTab & sWinTitle
	
				' Add the info for this process to our memory string that will eventually be returned.
				sMemString = sMemString & vbcrlf & sProcString
			   'If LCase(asProcesses(iProcCounter)) <> "all" Then
				'	Exit For
			   'End If
			End If
		Next
		If bProcFound = False Then
			sProcString = asProcesses(iProcCounter) & ": NOT FOUND"
			sMemString = sMemString & vbcrlf & sProcString

		End If

	Next 
	' Return the memory string
	winGetMemInfo = sMemString	
   
End Function


' **********************************************************************
'	Name:  winSendNotesMail
'	Purpose: This function sends an email from lotus Notes
'	Creator:unknown
'
'		Param: sPassword| required
'		AllowedRange: password of your email 
'
'		Param: sTo| required
'		AllowedRange: any email address
'
'		Param: sSubject| required
'		AllowedRange: subject of the email
'
'		Param: sBody| required
'		AllowedRange: body of the email
'
'		Param: sAttachment| required
'		AllowedRange: path to the attachment

'	Returns:  The size of memory in KB.
'**********************************************************************'
Public Sub winSendNotesMail(sPassword, sTo, sSubject, sBody, sAttachment)
	Dim Maildb 
	Dim UserName 
	Dim MailDoc 
	Dim Session
	Dim EmbedObj
    'Start a session to notes
    Set Session = CreateObject("Lotus.NotesSession")
    'Next line only works with 5.x and above. Replace password with your password
	
	Session.Initialize(sPassword)
	UserName = Session.UserName
	'Open the mail database in notes
	Set Maildb = Session.GETDATABASE("", "c:\notes\data\log.nsf")
	If Not Maildb.IsOpen = True Then
	 Maildb.Open
	End If

    	'Set up the new mail document
	Set MailDoc = Maildb.CREATEDOCUMENT
	MailDoc.ReplaceItemValue "Form", "Memo"
	MailDoc.ReplaceItemValue "SendTo",  sTo
	MailDoc.ReplaceItemValue "Subject", sSubject
	'MailDoc.ReplaceItemValue "Body", sBody
	Dim Body
	Set Body = MailDoc.CREATERICHTEXTITEM("Body")
	Body.APPENDTEXT sBody

	'Create an attachment (optional)
	If sAttachment <> "" Then
	 Body.ADDNEWLINE 2 
	 Body.EMBEDOBJECT 1454, "", sAttachment, "Attachment"
	End if
	MailDoc.SAVEMESSAGEONSEND = True
    'Set up the embedded object and attachment and attach it
    MailDoc.ReplaceItemValue "PostedDate", Now() 'Gets the mail to appear in the sent items folder
    MailDoc.Send 0, sTo
    'Clean Up
    Set Maildb = Nothing
    Set MailDoc = Nothing
    Set Session = Nothing
    Set EmbedObj = Nothing
End Sub

' **********************************************************************
'	Name:    winClearSecurityPopup
'	Purpose: This function clears the security pop ups
'	Creator:unknown
'
'	Returns:  NA
'**********************************************************************'
Public Sub winClearSecurityPopup()

Dim Hwnd,lResult, bDialogBox
bDialogBox=False
wait 2
Do Until bDialogBox
 Hwnd = extern.FindWindowEx(0,0,vbNullString, "Security Alert")
 
        If Hwnd = 0 Then
            Hwnd = extern.FindWindowEx(0,0,vbNullString, "Security Information")
        End If
		If Hwnd = 0 Then
		Hwnd = extern.FindWindowEx(0,0,vbNullString, "Windows Internet Explorer")
		End if
bDialogBox = Not (CBool(Hwnd))
If Hwnd > 0 Then
            lResult = extern.PostMessage(Hwnd, WM_COMMAND, 6, 0)
			Wait 1
End If
 Hwnd = 0
Loop


End Sub


' **********************************************************************
'	Name:  winDesktopBMPCapture
'	Purpose: This function captures a bitmap of the current desktop.
'		NOTE:  The file will be overwritten if it exists!
'	Creator: Mark Clemens
'
'		Param: sFileName| required
'		AllowedRange: Any valid file name. 
'       Description: The file name of the bitmap..
'
'	Returns: N/A
'**********************************************************************'
Public Sub winDesktopBMPCapture(sFileName)

	Dim sImg

	Set sImg=CreateObject("Scripting.FileSystemObject")

	sImg.CreateTextFile sFileName,True

	Window("nativeclass:=progman").CaptureBitmap sFileName,True
   
End Sub



' **********************************************************************
'	Name:  winObjVerifyProp
'	Purpose: This function verifies the propery of an object based on the 
'		property and expected value that are passed in.
'	Creator:Mark Clemens
'
'		Param: oObject| required
'		AllowedRange: Any dot notated object string from QTP. 
'       Description: The object to verify..
'
'		Param: sProp| required
'		AllowedRange: Any valid property for the object. 
'       Description: The property to verify..
'
'		Param: vExpected| required
'		AllowedRange: 
'       Description: The expeted value of the property.
'
'		Param: vActual| required
'		AllowedRange: 
'       Description: The actual value of the requested property.
'
'	Returns:  The size of memory in KB.
'**********************************************************************'
Public Function winObjVerifyProp(oObject, sProp, vExpected, vActual)
	

	Dim oRegex, oMatch, colMatches 

	Set oRegEx = New RegExp   

	oRegEx.Pattern = vExpected
	oRegEx.IgnoreCase = False

	vActual = oObject.GetROProperty(sProp)

	Set colMatches = oRegEx.Execute(vActual)
	If  colMatches.Count > 0 Then
		winObjVerifyProp = True
		PrintToLog  "PASS:  Actual = " & vActual & vbcrlf & "PASS: Expctd = " & vExpected
	Else
		winObjVerifyProp = False
	End If
	'vActual = oObject.GetROProperty(sProp)

	'If  vExpected = vActual Then
	'	winObjVerifyProp = True
	'Else
	'	winObjVerifyProp = False
	'End If

End Function

'**********************************************************************
'	Name:  winSendSMTPMail
'	Purpose: This function sends an email from SMTP Server
'		 (Send Mail dll must be registered for this function to work)
'	Creator:unknown
'
'		Param: sTo| required
'		AllowedRange: any email address
'		Description:
'
'		Param: sToDisplayName| required
'		AllowedRange: any valid string
'		Description:
'
'		Param: sFrom| required
'		AllowedRange: any email address
'		Description:
'
'		Param: sFromDisplayName| required
'		AllowedRange: any valid String 
'		Description:
'
'		Param: sSubject| required
'		AllowedRange: subject of the email
'		Description:
'
'		Param: sBody| required
'		AllowedRange: body of the email
'		Description:
'
'		Param: sAttachment| required
'		AllowedRange: path to the attachment
'		Description:
'
'	Returns: N/A
'**********************************************************************'
Public Sub winSendSMTPMail(sTo, sToDisplayName, sFrom, sFromDisplayName, sSubject , sBody, sAttachment)
	Dim poSendMail 
	Set poSendMail  = CreateObject("vbSendMail.clsSendMail")
	'Set poSendMail = New clsSendMail
	poSendMail.SMTPHost = ""
	poSendMail.From = sFrom
	poSendMail.FromDisplayName = sFromDisplayName
	poSendMail.Recipient = sTo
	poSendMail.RecipientDisplayName =sToDisplayName
	poSendMail.Subject = sSubject
	poSendMail.Message =sBody
	poSendMail.Attachment = sAttachment
	poSendMail.Send

End Sub

'***********************************************
'	Name:  winMaximizeForegroundWindow()
'	Purpose:	This Sub maximizes a foreground  window
'	Creator:unknown
'	
'  	Returns: N/A
'**********************************************************************
Public Sub winMaximizeForegroundWindow()

	hWnd = extern.GetForegroundWindow()
	Window("hwnd:=" & hWnd).Maximize
	errHandler Err, "winMaximizeForegroundWindow", micWarning
   
End Sub

'**********************************************************************
'	Name: winBrowserMaximize
'	Purpose: This sub maximizes a browser window
'	Creator: Michael J. Nohai
'
'		Param: sBrowser|required
'		AllowedRange: 
'		Description: The title message for the Browser
'
'	Returns: N/A
'**********************************************************************
Public Sub winBrowserMaximize(sBrowser)
	
	
	Dim hWnd
    
    If Browser("name:=" & sBrowser).Exist(0) Then

		hWnd = Browser("name:=" & sBrowser).GetROProperty("HWND")
		errHandler Err, " winBrowserMaximize",g_iSeverity
		
		Window("hwnd:=" & Browser("hwnd:=" & hWnd).Object.hWnd).Activate
		errHandler Err, " winBrowserMaximize",g_iSeverity

		Window("hwnd:=" & Browser("hwnd:=" & hWnd).Object.hWnd).Maximize
		errHandler Err, " winBrowserMaximize",g_iSeverity
	End If
End Sub

'**********************************************************************
'	Name: winBrowserMinimize
'	Purpose: This sub minimizes a browser window
'	Creator: Michael J. Nohai
'
'		Param: sBrowser|required
'		AllowedRange: 
'		Description: The title message for the Browser
'
'	Returns: N/A
'**********************************************************************
Public Sub winBrowserMinimize(sBrowser)
	
	Dim hWnd
    
    If Browser("name:=" & sBrowser).Exist(0) Then

		hWnd = Browser("name:=" & sBrowser).GetROProperty("HWND")
		errHandler Err, " winBrowserMinimize",g_iSeverity
		
		Window("hwnd:=" & Browser("hwnd:=" & hWnd).Object.hWnd).Activate
		errHandler Err, " winBrowserMinimize",g_iSeverity

		Window("hwnd:=" & Browser("hwnd:=" & hWnd).Object.hWnd).Minimize
		errHandler Err, " winBrowserMinimize",g_iSeverity
	End If
End Sub

'**********************************************************************
'	Name: winBrowserRestore
'	Purpose: This sub restores a browser window
'	Creator: Michael J. Nohai
'
'		Param: sBrowser|required
'		AllowedRange: 
'		Description: The title message for the Browser
'
'	Returns: N/A
'**********************************************************************
Public Sub  winBrowserRestore(sBrowser)
	
	Dim hWnd
    
    If Browser("name:=" & sBrowser).Exist(0) Then

		hWnd = Browser("name:=" & sBrowser).GetROProperty("HWND")
		errHandler Err, " winBrowserRestore",g_iSeverity
		
		Window("hwnd:=" & Browser("hwnd:=" & hWnd).Object.hWnd).Activate
		errHandler Err, " winBrowserRestore",g_iSeverity

		Window("hwnd:=" & Browser("hwnd:=" & hWnd).Object.hWnd).Restore
		errHandler Err, " winBrowserRestore",g_iSeverity
	End If
End Sub

'**********************************************************************
'	Name: winDismissCertWarning
'	Purpose:This sub dismisses the certification warning band by right clicking on the 
'		band and selecting 'Allow blocked content
'	Creator:unknown
'
'		Param: oBrowser| required
'		AllowedRange: 
'		Description: The browser test object with the cert warning - e.g., Browser("brAgencyPortal")
'
'	Returns: N/A
'**********************************************************************
Public Sub winDismissCertWarning(oBrowser)
	
	If  oBrowser.WinButton("text:=To help protect your security.*").Exist(5) Then
	
		oBrowser.WinButton("text:=To help protect your security.*").Click 58,3,micRightBtn
		errHandler Err, "winDismissCertWarning", micWarning
			
		oBrowser.WinMenu("class:=WinMenu", "menuobjtype:=3").Select "Display Blocked Content"
		errHandler Err, "winDismissCertWarning", micWarning

		oBrowser.Sync
		
	End If

End Sub

'**********************************************************************
'	Name: winBrowserExists
'	Purpose:	This function returns true if a browser with the title passed exists.
'	Creator:unknown
'
'		Param: sTitle| required
'		AllowedRange: 
'		Description: The  Title of the Browser to check.  Accepts regular expressions
'
'	Returns: True or False

'**********************************************************************
Public Function winBrowserExists(sTitle)
	   

	winBrowserExists = Browser("title:= " & sTitle).exist(0)
   
End Function


'**********************************************************************
'	Name: winKillProcess
'	Purpose:This function kills all instances of a process.
'	Creator:unknown
'
'		Param: sProcess| required
'		AllowedRange: 
'		Description: The process to kill.
'
'	Returns: True or False

'**********************************************************************
Public Sub winKillProcess(sProcess)

	Dim oWMI
	Dim ret
	Dim sService
	Dim oWMIServices
	Dim oWMIService
	Dim oServices
	Dim oService
	Dim servicename
	 
	Set oWMI = GetObject("winmgmts:")
	Set oServices = oWMI.InstancesOf("win32_process")
	
	For Each oService In oServices
			 
		servicename = LCase(Trim(CStr(oService.Name) & ""))
			 
		If LCase(servicename) = LCase(sProcess) Then
			ret = oService.Terminate
		End If
	
	Next
	  
	Set oServices = Nothing
	Set oWMI = Nothing
   
End Sub


'**********************************************************************
'   Name:    winBrowserGetSource
'   Purpose:This function returns the source for a given web page.  
'		It returns the same text that would be found using the 'View\Source' 
'		menu command for a web page.
'   Creator: Mark Clemens
'
'		Param: oBrowser| required 
'		AllowedRange: 
'		Description: The browser with the source.  This parameter is passed
'			in as a reference to the object repository browser object or as a programmatic
'			description, as in the following example::
'				Browser("title:=.*CNN.*")
'
'		Param: iXRightClk| optional|AssumedValue=300
'		AllowedRange: 
'		Description: The x coordinate to right click on the browser to bring up the context menu.
'
'		Param: iYRightClk| optional|AssumedValue=300
'		AllowedRange: 
'		Description: The y coordinate to right click on the browser to bring up the context menu.
'
'   Returns: N/A  
'**********************************************************************'
Public Function winBrowserGetSource(oBrowser, iXRightClk, iYRightClk)
	
	Dim sText, oCB, sTitle, dtEndTime, bItemFound

	sTitle = oBrowser.GetROProperty("title")
	If iXRightClk = "" Then
		iXRightClk = 300
	End If

	If iYRightClk = "" Then
		iYRightClk = 300
	End If

	dtEndTime = DateAdd("s",300,Now)
	bItemFound = False
	Do
		' Right click the browser (window)  to get the popup menu to display.  This is being done
		' because the top menu selection - 'View\Source' doesn't return all of the source html in all cases.
		Window("title:=.*" & sTitle & ".*", "regexpwndclass:=IEFrame").Click iXRightClk, iYRightClk, micRightBtn

		If oBrowser.WinMenu("micclass:=WinMenu", "menuobjtype:=3").GetItemProperty("View Source", "Exists") Then
			bItemFound = True
		Else
			iYRightClk = iYRightClk + 30
		End If

	Loop While bItemFound = False And Now < dtEndTime

	' Click the 'View Source' menu item.
	oBrowser.WinMenu("micclass:=WinMenu", "menuobjtype:=3").Select "View Source"
	errHandler Err, "winBrowserGetSource", g_iSeverity
	

	' Create a clipboard object and clear it
	Set oCB = CreateObject("Mercury.Clipboard")
	errHandler Err, "winBrowserGetSource", g_iSeverity
	oCB.Clear
	errHandler Err, "winBrowserGetSource", g_iSeverity

	' sync on the notepad window appearing.
	Do 
		If Window("title:=.*Notepad.*").Exist(0) Then
			  bExists = True
		End If
	Loop While bExists = False And dtEndTime < Now

	' Highlight (select) the text and copy it to the clipboard (Ctrl+C)
	Window("title:=.*Notepad.*").WinEditor("nativeclass:=Edit").Type micCtrlDwn + "a" + micCtrlUp
	errHandler Err, "winBrowserGetSource", g_iSeverity
	' wait a second for the text to highlight
	wait 2
	Window("title:=.*Notepad.*").WinEditor("nativeclass:=Edit").Type micCtrlDwn + "c" + micCtrlUp
	errHandler Err, "winBrowserGetSource", g_iSeverity

	' Get the clipboard text
	winBrowserGetSource = oCB.GetText
	errHandler Err, "winBrowserGetSource", g_iSeverity

	' Close the notepad window
	Window("title:=.*Notepad.*").Close
	errHandler Err, "winBrowserGetSource", g_iSeverity
	
End Function

'**********************************************************************
'   Name:    winGetLocalEncKey
'   Purpose:This function returns the encryption key used in a given environment.
'		Usually, the encryption key is stored in the Config folder. NOTE:  This file should 
'		NEVER be checked into PVCS, but rather, stored in the local Testware repository
'		so only the user on that machine has access to the file with the encryption key.		
'   Creator: Mark Clemens
'
'		Param: sFile| required 
'		AllowedRange: 
'		Description: The file with the encryption key, usually stored in the Config folder.  For example:
'			"C:\Automation\Testware\Apps\dbd\Config\dbd_key.txt"
'
'   Returns: N/A  
'**********************************************************************'
Public Function winGetLocalEncKey(sFile)
	

	Dim fso, ts, sLine

	sLine = ""
	
	Set fso = CreateObject("scripting.filesystemobject")
	errHandler Err, "winGetLocalEncKey", g_iSeverity

	If fso.FileExists(sFile) Then
		Set ts = fso.OpenTextFile(sFile)
		sLine = ts.ReadLine
		errHandler Err, "winGetLocalEncKey", g_iSeverity
	End If

	winGetLocalEncKey = sLine
   
End Function

'**********************************************************************
'   Name:    winCustomOptionDialog
'   Purpose:This function puts up a dialog with desired option buttons and
'		returns the option that was selected..		
'   Creator: Mark Clemens
'
'		Param: sCustomString| required 
'		AllowedRange: 
'		Description: The string that defines the options form.  This is in the following format:
'			<DialogTitle>|<ButtonLabel>|<Option1Label>|<Option2Label|<OptionNLabel>. . .
'			Each item is delimited by the pipe (|) symbol.
'
'   Returns:The caption of the selected option 
'**********************************************************************'
Public Function winCustomOptionDialog(sCustomString)
	
	Dim objShell, oExec, bAppFinished
	Dim sEXE
	Dim oStdOut

	sEXE = g_sTestwarePath & "\Common\Bin\CustomRadioDlg.exe"

	sCustomString = sEXE & " " & sCustomString
	' Create a scripting object
	Set objShell = CreateObject("WScript.Shell")
	errHandler Err, "winCustomOptionDialog", g_iSeverity

	' Create an exec object and launch the custom options app
	Set oExec = objShell.Exec(sCustomString)
	errHandler Err, "winCustomOptionDialog", g_iSeverity

	bAppFinished = False
	Do
		' If the status is not 0 the app is no longer running
		If oExec.Status <> 0 Then
			bAppFinished = True
		End If
	Loop While bAppFinished = False

	' Get the output of the application
	Set oStdOut = oExec.StdOut
	errHandler Err, "winCustomOptionDialog", g_iSeverity

	' Set the value of the function to the output of the application.
	winCustomOptionDialog = oStdOut.ReadAll
	errHandler Err, "winCustomOptionDialog", g_iSeverity

End Function

'********************************************************************************************************
'   Name:    winBrowserBack 
'   Purpose:This sub clicks the Back button in the browser
' 
'   	Creator: Priya
'
'		Param: sTitle | required
'		AllowedRange: N/A
'		Description: Title of the browser
'
'   Returns: N/A  
'**********************************************************************'**********************************

Public Sub winBrowserBack(sTitle)

	
	
	If  Browser("title:="&sTitle).Exist Then
		Browser("title:="&sTitle).Back
		errHandler Err, " winBrowserBack",g_iSeverity
	End If

End Sub


'*******************************************************************************************************
'   Name:    winBrowserClose
'   Purpose:This sub will close the  given browser
' 
'   Creator: Lakshmi Varadan
'
'		Param: sName| required 
'		AllowedRange:
'		Description: The name of the Browser
'
'   Returns: N/A  
'**********************************************************************'**********************************
Public Sub winBrowserClose(sName)

   

   Dim dtEndTime,bSynced

	'Close the browser
	Browser("name:=" & sName).Close
    errHandler Err,"winBrowserClose",g_iSeverity

	Wait(2)
	'Check if the Browser is closed
	If Browser("name:=" & sName).Exist(0) Then
		Err.Description = "Browser " & sName &" was not closed"
        errHandler Err,"winBrowserClose",g_iSeverity
	End If
	
End Sub

'*******************************************************************************************************
'   Name:    winBrowserCloseWindow
'   Purpose:This sub closes a browser with the title substring that is passed in by closing
'		the window object instead of the browser object.
' 
'   Creator: Lakshmi Varadan
'
'		Param: sName| required 
'		AllowedRange:
'		Description: A substring of the browser window's title object.
'
'   Returns: N/A  
'**********************************************************************'**********************************
Public Sub winBrowserCloseWindow(sName)

   

	'Dim iX, iY, iWidth, iHeight
	Dim oBrowser, iHwnd, oWindow, oBrowserObj, colChildren, oDesc, iCounter

	Set oDesc = Description.Create

	oDesc("micclass").Value = "Window" 
	' Get a collection of all of the windows on the desktop.  
	Set colChildren = Desktop.ChildObjects(oDesc)
	' Loop through the collection, when the window with the desired title substring
	' is found, close it.
	For iCounter = 0 to colChildren.Count - 1
		If InStr(1, colChildren(iCounter).GetROProperty("title"),sName) > 0 Then
			Set oWindow = colChildren(iCounter)
			oWindow.Close
			Exit For
		End If
	Next
		
End Sub


'*******************************************************************************************************
'   Name:    winBrowserRefresh
'   Purpose:This sub will Refresh the browser
' 
'   Creator: Priya
'
'	   		 Param: sWinName
'  			AllowedRange: N/A
'			Description: Name of the Browser to be refreshed
'
'   Returns: N/A  
'**********************************************************************'**********************************
Public Sub winBrowserRefresh(sWinName)

	
	
	'Refresh the browser
	Browser("name:="&sWinName).Refresh
	
	'Wait till browser synchronizes
	Browser("name:="&sWinName).Sync

End Sub


''**********************************************************************
'	Name:  winCopyFile
'	Purpose:This function is used to create a copy of a file with unique name
'
'		Creator: Saravanan
'
'		Param: sRootFileName|Required
'		AllowedRange: N/A
'		Description: File name that needs to be copied 
'
'
'	Returns: N/A
'**********************************************************************'
Public Function winCopyFile(sRootFileName)

	
	
	Dim asPath,  oFso,sFilePath,sNow
	
	'Creating a file system object
	Set oFso = CreateObject("Scripting.FileSystemObject")
	errHandler Err,"winCopyFile",g_iSeverity
	
	'splitting the path to get the file name and path and extension
	asPath = Split(sRootFileName,".")
	errHandler Err,"winCopyFile",g_iSeverity
	
	' formats the date and time (calliing GetFSDateTimeStamp function)
	sNow=GetFSDateTimeStamp(now)
	errHandler Err,"winCopyFile",g_iSeverity
	
      'constructing the entire file path
        sFilePath = asPath(0) & sNow &"." & asPath(1)
	errHandler Err,"winCopyFile",g_iSeverity
	
	'creating a copy of  the file passed with a unique name
	oFso.CopyFile sRootFileName,sFilePath,FALSE
	errHandler Err,"winCopyFile",g_iSeverity
        
	'return the new file name
	winCopyFile=sFilePath
	
End Function

''**********************************************************************
'	Name:  winCopyFileToLocation
'	Purpose:This function is used to create a copy of a file.
'	Creator: Dan Hoizner & Michael J. Nohai
'
'		Param: sSourceFile|Required
'		AllowedRange: N/A
'		Description: Source File Path
'
'		Param: sTargetFile|Required
'		AllowedRange: N/A
'		Description: Target File Path
'
'	Returns: N/A
'**********************************************************************'
Public Sub winCopyFileToLocation(sSourceFile, sTargetFile)
	

	Dim oFSO, sPath

	' MJN - Create the path if it doesn't exist.
	sTargetFile = Trim(sTargetFile)
	sPath = Left(sTargetFile, InstrRev(sTargetFile, "\") - 1)

	winCreateFolderRecursive(sPath)

	Set oFSO = CreateObject("Scripting.FileSystemObject")
	errHandler Err, "winCopyFileToLocation", g_iSeverity

	If oFSO.FileExists(sSourceFile) Then
		oFSO.CopyFile sSourceFile, sTargetFile
		errHandler Err, "winCopyFileToLocation", g_iSeverity
	Else
		Err.Number = g_iITEM_NOT_FOUND
		Err.Description = sSourceFile & " is not found."
		errHandler Err, "winCopyFileToLocation", micFail
	End If

	Set oFSO = Nothing
End Sub

''**********************************************************************
'	Name: winDeleteAFile
'	Purpose: This sub is used to delete the specified file
'	Creator: Polina Rodov
'
'		Param: sFilePath|Required
'		AllowedRange: N/A
'		Description: Path along with the file name to be deleted.
'
'	Returns: N/A
'**********************************************************************'
Public Sub winDeleteAFile(sFilePath)
	
	
	Dim oFso

	sFilePath = Trim(sFilePath)
   
	Set oFso = CreateObject("Scripting.FileSystemObject")
	errHandler Err,"winDeleteAFile",g_iSeverity
	
	If oFso.FileExists(sFilePath) Then
		oFso.DeleteFile sFilePath
	Else
		Err.Number = g_iITEM_NOT_FOUND
		Err.Description = sFilePath & " is not found."
		errHandler Err,"winDeleteAFile",g_iSeverity
	End If

	Set oFSO = Nothing
   
End Sub

'****************************************************************************************************************************
'   Name:    winObjectExistVerify
'   Purpose:This sub will verify if the given objects exists or not according to the 'bExist' parameter passed
'						you can also pass an array of objects seperated by ',' at a single time.
' 
'   Creator: Sowjanya
'
'		Param: sObjectType| required 
'		AllowedRange: "link","weblist","webelement","webedit","image","webradiogroup","webcheckbox","webbutton","webtable"
'		Description: The type of the Object to be checked
'
'		Param: sObjectName| required 
'		AllowedRange:
'		Description: The name of the Object to be checked
'
'		Param: iIndex| optional|AssumedValue=0
'		AllowedRange:
'		Description: The index of the object to check, in the event that there is more
'			than one object with the text.
'
'		Param: sTitle| required 
'		AllowedRange:
'		Description: The title of the browser and page.
'
'		Param: bExist | required 
'		AllowedRange:True or False
'		Description: The bExist True to check if the object exists and False  to check if object does not exists.
'
'   Returns: 'True' or 'False' status based on whether the object exists or not
'**********************************************************************'********************************************************

Public Function winObjectExistVerify(sObjectType,sObjectName,iIndex,sTitle,bExist)

	

	Dim bStatus,asobjectsList,iCount,sObject,bGetExist,sObjectVal
	
   	If iIndex = ""  Then
		iIndex = 0
	End If
    
    'Split the object names delimiter as ','
	asobjectsList = Split(sObjectName,",")
	
	For iCount=0 to ubound(asobjectsList)

		bStatus =False
		sObjectVal=trim(asobjectsList(iCount))

		Select Case Lcase(Trim(sObjectType))

			Case "link" 
				bGetExist = Browser("name:=" & sTitle).Page("title:=" & sTitle).Link("text:=" & sObjectVal, "index:=" & iIndex).Exist(0)

			Case "webbutton"
				bGetExist = Browser("name:=" & sTitle).Page("title:=" & sTitle).WebButton("name:=" & sObjectVal, "index:=" & iIndex).Exist(0)

			Case "webelement"
				bGetExist = Browser("name:=" & sTitle).Page("title:=" & sTitle).WebElement("innertext:=" & sObjectVal, "index:=" & iIndex).Exist(0)
				
			Case "webradiogroup"
				bGetExist = Browser("name:=" & sTitle).Page("title:=" & sTitle).WebRadioGroup("name:=" & sObjectVal, "index:=" & iIndex).Exist(0)

			Case "webedit"
				bGetExist = Browser("name:=" & sTitle).Page("title:=" & sTitle).WebEdit("name:=" & sObjectVal, "index:=" & iIndex).Exist(0)

			Case "weblist"
				bGetExist = Browser("name:=" & sTitle).Page("title:=" & sTitle).WebList("name:=" & sObjectVal, "index:=" & iIndex).Exist(0)

			Case "webcheckbox"
				bGetExist = Browser("name:=" & sTitle).Page("title:=" & sTitle).WebCheckBox("name:=" & sObjectVal, "index:=" & iIndex).Exist(0)

			Case "image"
				bGetExist = Browser("name:=" & sTitle).Page("title:=" & sTitle).Image("alt:=" & sObjectVal, "index:=" & iIndex).Exist(0) or Browser("name:=" & sTitle).Page("title:=" & sTitle).Image("file name:="& sObjectVal &".*").Exist(0)
                
			Case "webtable"
			bGetExist = Browser("name:=" & sTitle).Page("title:=" & sTitle).WebTable("name:=" & sObjectVal, "index:=" & iIndex).Exist(0)

			Case Else

				Err.Description = "Invalid Parameter"
				errHandler Err,"winObjectExistVerify",g_iSeverity	
			
		End Select

		'check if the given object exists or not
		If  Trim(cBool(bGetExist)) <>Trim(cBool(bExist)) Then
			Err.Description = "The '" & sObjectVal & "' " &sObjectType &"  was not found in the window"
			errHandler Err, "winObjectExistVerify", g_iSeverity
		Else
			bStatus =True
		End If

	Next

	winObjectExistVerify = bStatus

End Function


'****************************************************************************************************************************
'   Name:    winFileDeleteLines
'   Purpose:This sub will delete all lines in a file (i.e., set the line to an empty string) that begin with the array elements that are passed in. 
'		This is function is used primarily to remove dynamic data that is not needed when doing a file compare.
' 
'   Creator: Mark Clemens
'
'		Param: sFile| required 
'		AllowedRange: 
'		Description: The file to delete lines in.
'
'		Param: asDeleteLines| required 
'		AllowedRange:
'		Description: The array with the characters at the beginning of the lines to set to an empty string.
'
'   Returns: N/A
'**********************************************************************'********************************************************
Public Sub winFileDeleteLines(sFile, asDeleteLines)
	Dim iCounter, iDelLineCounter, sLCaseFileLine, sLCaseDeleteLine
	Dim fso, ts, asFileLines, sFileText

	' Open the file that was passed in.
	Set fso = CreateObject("scripting.filesystemobject")
	Set ts = fso.OpenTextFile(sFile)

	sFileText = ts.ReadAll

	' Split the file's text into an array based on the carriage return line feed.
	asFileLines = Split(sFileText, vbcrlf)
	' loop through all of the lines in the file
	For iCounter = 0 to UBound(asFileLines)
		'  for each line in the file, loop through the desired lines to be deleted.  If there
		'  is a match with the beginning of the line, set the line ot an empty string.
		For iDelLineCounter = 0 to UBound(asDeleteLines)
			sLCaseFileLine = LCase(asFileLines(iCounter))
			sLCaseDeleteLine = LCase(asDeleteLines(iDelLineCounter))
			If Left(sLCaseFileLine, Len( sLCaseDeleteLine)) = sLCaseDeleteLine Then
				asFileLines(iCounter) = ""
			End If
		Next
	Next

	ts.Close
	' Now write the data back to the original file with the lines deleted.
	sFileText = ""
	For iCounter = 0 to UBound(asFileLines)
		If iCounter < UBound(asFileLines) Then
			sFileText = sFileText & asFileLines(iCounter) & vbcrlf
		Else
			sFileText = sFileText & asFileLines(iCounter)
		End If

	Next

	Set ts = fso.OpenTextFile(sFile, 2, True)

	ts.Write sFileText

   ts.Close
   Set ts = Nothing
   
End Sub
'**********************************************************************'
' Name: winKeyFileExists 
' Purpose: This sub checks if the Key file required for Encryption/decryption is available in the expected path.
'  
' Creator: Lavanya Bathina
'
' Param: sAppName| required 
' AllowedRange: 
' Description:  Name of the Application being executed.
' 
' Returns: N/A 
'**********************************************************************'
Public sub winKeyFileExists(sAppName)

	Dim oFso,sFile

	'Set the Key File path appropriate to the application name
	Select case ucase(sAppName)
		Case "NB21"
			sFile="C:\Automation\Testware\Apps\NB21\Configs\nb_key.txt" 
		Case "VGN"
			sFile="C:\Automation\Testware\Apps\VGN\Configs\vgn_key.txt"
		Case "BASIS"
			sFile="C:\Automation\Testware\Apps\BASIS\Configs\basis_key.txt"
		'more cases to be included  
	End Select 
	
	'Check if the key file exists in the expected location.
	Set oFso= CreateObject("Scripting.FileSystemObject")
    If Not(oFso.FileExists(sFile)) Then
		PrintToLog "Key File for Encrption or Decryption does not Exists."
		ExitTest 
	End If
	
End Sub


'**********************************************************************'
' Name: winObjectExists
' Purpose: This function checks if a vb object is instantiated.
'  
' Creator: Mark Clemens
'
' Param: oObject| required 
' AllowedRange: 
' Description:  The object to check..
' 
' Returns: If the object exists, but is not instantiated, returns False.  If the object doesn't exist, returns False, otherwise returns True. 
'**********************************************************************'
Public Function winObjectExists(oObject)

	If (IsObject(oObject) = True And IsNull(oObject) = False) Or (IsObject(oObject) = True And IsEmpty(oObject) = False) Then
		
		winObjectExists = False
	ElseIf (IsObject(oObject) = True And IsNull(oObject) = True) Or (IsObject(oObject) = True And IsEmpty(oObject) = True) Then
		winObjectExists = False
		
	Else
		winObjectExists = False
	
	End If


End Function

'**********************************************************************
'	Name: winGetConfig
'	Purpose: This sub will retrieve the value of the specified key from the nb21 config file
'
'		Creator: Chaitanya Katta
'
'		Param: sKey | required
'		AllowedRange:  
'		Description:  Key for which the value is to be retrieved from the NB21 config file 
'
'		Param: sFilePath | required
'		AllowedRange:  
'		Description:  Path to the config File
'
'	Returns: Returns the value of the specified key
'**********************************************************************
Public Function winGetConfig (sKey,sFilePath)

   'Declare Variables
	Dim oNewFile, sLine,asPropName,sValue,oFso

	'Open NB21 ini file 
	Set oFso = CreateObject ("Scripting.FileSystemObject")
    Set oNewFile=oFso.OpenTextFile(sFilePath,1)

	'Read each line to fetch the specified key's value
	Do Until oNewFile.AtEndOfStream
		sLine = oNewFile.ReadLine
		If sLine<>"" Then
			asPropName = split(sLine,"=")			
			if Trim(asPropName(0)) = sKey Then			
				sValue = asPropName(1)		
				Exit Do
			End If
		End If
	Loop
	oNewFile.close()
	winGetConfig =  (sValue)
End Function

'**********************************************************************
'	Name: winLogFileParse
'	Purpose: This sub parses the logfile and creates a summary log in results folder 
'		or current script.
'	Creator: Chaitanya Katta & Michael J. Nohai
'
'		Param: sLogFile|required
'		AllowedRange:  
'		Description: Path to the log file
'
'		Param: asErrors|required
'		AllowedRange:  
'		Description: Arrays of errors is being passed by reference to access it at script level
'
'		Param: asWarnings|required
'		AllowedRange:  
'		Description: Arrays of warnings is being passed by reference to access it at script level
'
'	Returns: N/A
'**********************************************************************
Public Sub winLogFileParse(sLogFile, ByRef asErrors, ByRef asWarnings)
	

	Dim sText,oFso,asLog,dtStartTime,dtEndTime,sTotalTime,bFound,iTimeCounter,sDate,iUbound,iCounter
	Dim sErrDescription, sErrNumber, sErrBitmap,sErrors,iDesCount,iErrCount,bBitMapFound
	Dim sWarDescription, sWarNumber, sWarBitmap,asErrMes,asWarMes,sWarning,iWarCount, iTestCases, aiTestCases
	Dim sScriptName, asScriptName, asDateTime, sDateTime, oStream, sSumLogFile, sLogFileName
	Dim iTCID, aiTCID, asDate

	sLogFile = Trim(sLogFile)

	'MJN - Updated to support UTF-8 encoding.
	Set oFso = CreateObject("Scripting.FileSystemObject")
	
    If oFso.FileExists(sLogFile) Then

		sLogFileName = Left(sLogFile, InstrRev(sLogFile, ".") - 1)

		'This generates a summary log for each script in the same directory.
		sSumLogFile = sLogFileName & "_SummaryLog.log"

    	Set oStream = CreateObject("ADODB.Stream")
    	oStream.Open
    	oStream.Charset = "utf-8"

    	oStream.LoadFromFile sLogFile
    	sText = oStream.ReadText
    	oStream.Close

    	Set oStream = Nothing
    	
    	asLog = Split(sText,vbcrlf)
    	iUbound = UBound(asLog)
		dtStartTime = Mid(asLog(0),2,8)
	    dtEndTime = Mid(asLog(iUbound),2,8)
   
		iTimeCounter =1
		bFound = False

	    ' The code below is to get to the last valid line with time stamp
		Do
			If IsNumeric (Left(dtEndTime,2)) = False Then
				dtEndTime = Mid(asLog(iUbound-iTimeCounter),2,8)
			Else 
				bFound = True
				Exit Do
			End If
			iTimeCounter = iTimeCounter + 1	
		Loop While bFound =  False

		'MJN - If the time goes past midnight, we need to add a day to calculate it correctly.
		dtStartTime = FormatDateTime(CDate(dtStartTime), 4)
		dtEndTime = FormatDateTime(CDate(dtEndTime), 4)

		If dtStartTime > dtEndTime Then
			dtEndTime = DateAdd("d", 1, dtEndTime)
		End If

		' Get the total script run time.
		sTotalTime = DateDiff("n", dtStartTime, dtEndTime)

		' Get the errors and warnings.
		ReDim asErrors(0)
		ReDim asWarnings(0)

		For iCounter = 0 to iUbound

			' Get the date of script execution.
			If InStr(1, Trim(asLog(iCounter)),"<datetime>", 1) > 0 Then
				asDateTime = utExtractHtmlTagValues(asLog(iCounter))
				sDateTime = Trim(asDateTime(1))
				asDate = Split(sDateTime, " ")
				sDate = asDate(0)
			End If
			If InStr(1, Trim(asLog(iCounter)),"<script name>", 1) > 0 Then
				asScriptName = utExtractHtmlTagValues(asLog(iCounter))
				sScriptName = Trim(asScriptName(1))
			End If
			' Get the number of test cases
			If InStr(1, asLog(iCounter),"test cases executed:", 1) > 0 Then
				aiTestCases = Split(asLog(iCounter),":")
				iTestCases = Trim(aiTestCases(UBound(aiTestCases)))
			End If
			' Get the test case id
			If InStr(1, asLog(iCounter),"test case id:", 1) > 0 Then
				aiTCID = Split(asLog(iCounter),":")
				iTCID = Trim(aiTCID(UBound(aiTCID)))
			End If
			' Get the errors and warnings	
			If InStr(1, asLog(iCounter),"FAIL:") > 0 Then
				' populate an array with the error message and path to the bmp file.
				If UBound(asErrors) = 0 And asErrors(0) = "" Then
					asErrors(0) = asLog(iCounter)
				Else
					ReDim Preserve asErrors(UBound(asErrors) + 1)
					asErrors(UBound(asErrors)) = asLog(iCounter)
				End If
				' Get the error number , error descripition and path to bitmap
				If InStr(1, asLog(iCounter + 1),"number:", 1) > 0 Then
					sErrNumber = asLog(iCounter + 1)
				Else
					sErrNumber = ""
				End If
				If InStr(1, asLog(iCounter + 2),"description:", 1) > 0 Then
					sErrDescription = asLog(iCounter + 2)
				Else
					sErrDescription = ""
				End If
				If InStr(1, asLog(iCounter + 3),"bitmap:", 1) > 0 Then
					sErrBitmap = asLog(iCounter + 3)
				Else
					sErrBitmap = ""
				End If
				If iTCID <> "" Then
					asErrors(UBound(asErrors)) = iTCID & "|" & asErrors(UBound(asErrors)) & "|" & sErrNumber & "|" & sErrDescription & "|" & sErrBitmap
				Else
					asErrors(UBound(asErrors)) = asErrors(UBound(asErrors)) & "|" & sErrNumber & "|" & sErrDescription & "|" & sErrBitmap
				End If
			Elseif InStr(1, asLog(iCounter),"WARNING:") > 0 Then
				' Populate an array with warning message
				If UBound(asWarnings) = 0 And asWarnings(0) = "" Then
					asWarnings(0) = asLog(iCounter)
				Else
					ReDim Preserve asWarnings(UBound(asWarnings) + 1)
					asWarnings(UBound(asWarnings)) = asLog(iCounter)
				End If
				' Get the error number , error descripition and path to bitmap
				If InStr(1, asLog(iCounter + 1),"number:", 1) > 0 Then
					sWarNumber = asLog(iCounter + 1)
				Else
					sWarNumber = ""
				End If
				If InStr(1, asLog(iCounter + 2),"description:", 1) > 0 Then
					sWarDescription = asLog(iCounter + 2)
				Else
					sWarDescription = ""
				End If
				If InStr(1, asLog(iCounter + 3),"bitmap:", 1) > 0 Then
					sWarBitmap = asLog(iCounter + 3)
				Else
					sWarBitmap = ""
				End If
				If iTCID <> "" Then
					asWarnings(UBound(asWarnings)) = iTCID & "|" & asWarnings(UBound(asWarnings)) & "|" & sWarNumber & "|" & sWarDescription  & "|" & sWarBitmap
				Else
					asWarnings(UBound(asWarnings)) = asWarnings(UBound(asWarnings)) & "|" & sWarNumber & "|" & sWarDescription  & "|" & sWarBitmap
				End If
			End If
		Next

		' Write to a summary log file all the collected summary data.
		winPrintToFile sSumLogFile,"Date of Script Execution: " & sDate,"Append"
		winPrintToFile sSumLogFile,"Start Time: " & dtStartTime ,"Append"
		winPrintToFile sSumLogFile,"End Time: " & dtEndTime ,"Append"
		winPrintToFile sSumLogFile,"Script Name: " & sScriptName  ,"Append"
		If iTestCases > 0 Then
			winPrintToFile sSumLogFile,"Total Number of Test Cases Executed: " & iTestCases ,"Append"
		End If
		winPrintToFile sSumLogFile,"Total Lines Executed: " & UBound(asLog)+1 ,"Append"
		winPrintToFile sSumLogFile,"Log File: " & sLogFile ,"Append"
		
		' Print Empty Lines.
		winPrintToFile sSumLogFile,"" ,"Append"
		winPrintToFile sSumLogFile,"" ,"Append"

	    winPrintToFile sSumLogFile,"Total Time Taken for the script to run: " & sTotalTime & " Minutes" ,"Append"
		winPrintToFile sSumLogFile,"Windows User: " & Environment("UserName"),"Append"
		winPrintToFile sSumLogFile,"Machine name: " & Environment("LocalHostName"),"Append"

		' Print Empty Lines.
		winPrintToFile sSumLogFile,"" ,"Append"
		winPrintToFile sSumLogFile,"" ,"Append"


		' Print the details of the error messages
		If asErrors(0) <> "" Then
			winPrintToFile sSumLogFile,"Total Number of Errors during the run: " & UBound(asErrors) + 1,"Append"
			winPrintToFile sSumLogFile,"" ,"Append"
			winPrintToFile sSumLogFile,"Errors:" ,"Append"
			winPrintToFile sSumLogFile,"" ,"Append"
			For iErrCount = 0 to UBound(asErrors)
				asErrMes = Split(asErrors(iErrCount),"|")
				If UBound(asErrMes) > 3 Then
					winPrintToFile sSumLogFile,"--Test Case ID: " & asErrMes(0) ,"Append"
					sErrors = Mid(asErrMes(1),12,Len(asErrMes(1)))
					winPrintToFile sSumLogFile,"--Time: " & Mid(asErrMes(1),2,8),"Append"
					winPrintToFile sSumLogFile,"--" & sErrors,"Append"
					winPrintToFile sSumLogFile,"--" & asErrMes(2),"Append"
					winPrintToFile sSumLogFile,"--" & asErrMes(3),"Append"
					winPrintToFile sSumLogFile,"--" & asErrMes(4),"Append"
				Else
					sErrors = Mid(asErrMes(0),12,Len(asErrMes(0)))
					winPrintToFile sSumLogFile,"--Time: " & Mid(asErrMes(0),2,8),"Append"
					winPrintToFile sSumLogFile,"--" & sErrors,"Append"
					winPrintToFile sSumLogFile,"--" & asErrMes(1),"Append"
					winPrintToFile sSumLogFile,"--" & asErrMes(2),"Append"
					winPrintToFile sSumLogFile,"--" & asErrMes(3),"Append"
				End If
				If iErrCount <= UBound(asErrors) Then
					winPrintToFile sSumLogFile,"" ,"Append"
					winPrintToFile sSumLogFile,"****************************************************************","Append"
				End If
			Next
		Else 
			winPrintToFile sSumLogFile,"Total Number of Errors during the run: 0" ,"Append"
		End If
		
		' Print Empty Lines.
		winPrintToFile sSumLogFile,"" ,"Append"
		winPrintToFile sSumLogFile,"" ,"Append"

		' Print the details of the warning messages
		If asWarnings(0) <> "" Then
			winPrintToFile sSumLogFile,"Total Number of Warnings during the run: " & UBound(asWarnings) + 1,"Append"
			winPrintToFile sSumLogFile,"" ,"Append"
			winPrintToFile sSumLogFile,"Warnings:" ,"Append"
			winPrintToFile sSumLogFile,"" ,"Append"
			For iWarCount = 0 to UBound(asWarnings)
				asWarMes = Split(asWarnings(iWarCount),"|")
				If UBound(asWarMes) > 3 Then
					winPrintToFile sSumLogFile,"--Test Case ID: " & asWarMes(0) ,"Append"
					sWarning = Mid(asWarMes(1),12,Len(asWarMes(1)))
					winPrintToFile sSumLogFile,"--Time: " & Mid(asWarMes(1),2,8)  ,"Append"
					winPrintToFile sSumLogFile,"--" & sWarning,"Append"
					winPrintToFile sSumLogFile,"--" & asWarMes(2),"Append"			
					winPrintToFile sSumLogFile,"--" & asWarMes(3),"Append"			
					winPrintToFile sSumLogFile,"--" & asWarMes(4),"Append"
				Else
					sWarning = Mid(asWarMes(0),12,Len(asWarMes(0)))
					winPrintToFile sSumLogFile,"--Time: " & Mid(asWarMes(0),2,8)  ,"Append"
					winPrintToFile sSumLogFile,"--" & sWarning,"Append"
					winPrintToFile sSumLogFile,"--" & asWarMes(1),"Append"			
					winPrintToFile sSumLogFile,"--" & asWarMes(2),"Append"			
					winPrintToFile sSumLogFile,"--" & asWarMes(3),"Append"
				End If
				If iWarCount <= UBound(asWarnings) Then
					winPrintToFile sSumLogFile,"" ,"Append"
					winPrintToFile sSumLogFile,"****************************************************************","Append"
				End If		
			Next
		Else
			winPrintToFile sSumLogFile,"Total Number of Warnings during the run: 0" ,"Append"
		End If
    End If

    Set oFso = Nothing

End Sub

'**********************************************************************
'	Name: winChromeLaunch
'	Purpose:	This function launches Google Chrome with the URL that is passed in.
'	Creator:Chaitanya Katta
'
'		Param: sURL| required | InitialEntry=sURL
'		AllowedRange: 
'		Description: The URL to use when opening Chrome..
'
'	Returns: N/A
'**********************************************************************
Public sub winChromeLaunch(ByVal sURL)
	

	SystemUtil.Run "chrome.exe", sURL
	errHandler Err, "winChromeLaunch", g_iSeverity
	' wait 2.5 second for the window to become the foreground window
	wait (2.5)
End Sub

'**********************************************************************
'	Name: winFirefoxLaunch
'	Purpose: This function launches Firefox with the URL that is passed in.
'	Creator: Michael J. Nohai
'
'		Param: sURL| required | InitialEntry=sURL
'		AllowedRange: 
'		Description: The URL to use when opening  Firefox..
'
'	Returns: N/A
'**********************************************************************
Public sub winFirefoxLaunch(ByVal sURL)
	

	SystemUtil.Run "firefox", sURL
	errHandler Err, "winFirefoxLaunch", g_iSeverity
	' wait 2.5 second for the window to become the foreground window
	wait (2.5)
End Sub

'**********************************************************************
'	Name: winReadINIFile
'	Purpose: This function returns a value read from an INI file.
'	Creator: Michael J. Nohai
'
'		Param: myFilePath|required
'		AllowedRange: 
'		Description: The path and file name of the INI file.
'
'		Param: mySection|required
'		AllowedRange: 
'		Description: The section in the INI file to be searched.
'
'		Param: myKey|required
'		AllowedRange: 
'		Description: The key whose value is to be returned.
'
'	Returns: The value of the specified key in the specified section
'**********************************************************************
Public Function winReadINIFile(myFilePath, mySection, myKey)
   

    Const ForReading   = 1

    Dim intEqualPos
    Dim objFSO, objIniFile
    Dim strFilePath, strKey, strLeftString, strLine, strSection

    Set objFSO = CreateObject( "Scripting.FileSystemObject" )

    winReadINIFile = ""
    strFilePath = Trim(myFilePath)
    strSection = Trim(mySection)
    strKey = Trim(myKey)

    If objFSO.FileExists( strFilePath ) Then
        Set objIniFile = objFSO.OpenTextFile(strFilePath, ForReading, False)
        
        Do While objIniFile.AtEndOfStream = False
            strLine = Trim(objIniFile.ReadLine)

            ' Check if section is found in the current line
            If LCase(strLine) = "[" & LCase(strSection) & "]" Then
                strLine = Trim(objIniFile.ReadLine)

                ' Parse lines until the next section is reached
                Do While Left(strLine, 1) <> "["
                    ' Find position of equal sign in the line
                    intEqualPos = InStr(1, strLine, "=", 1)
                    If intEqualPos > 0 Then
                        strLeftString = Trim(Left(strLine, intEqualPos - 1))
                        ' Check if item is found in the current line
                        If LCase(strLeftString) = LCase(strKey) Then
                            winReadINIFile = Trim(Mid(strLine, intEqualPos + 1))
                            ' In case the item exists but value is blank
                            If winReadINIFile = "" Then
                                winReadINIFile = " "
                            End If
                            ' Abort loop when item is found
                            Exit Do
                        End If
                    End If

                    ' Abort if the end of the INI file is reached
                    If objIniFile.AtEndOfStream Then Exit Do

                    ' Continue with next line
                    strLine = Trim(objIniFile.ReadLine)
                Loop
            Exit Do
            End If
        Loop
        objIniFile.Close
    Else
		Err.Description = "The file " & strFilePath & " was not found."
		errHandler Err,"winReadINIFile",micFail
    End If
	Set objFSO = Nothing

End Function
'**********************************************************************
'	Name: winZipExtract
'	Purpose: This sub extracts the contents of a Zip file into a specified
'		directory.
'	Creator: Michael J. Nohai
'
'		Param: sZipFile|required
'		AllowedRange: 
'		Description: The path and file name of the .zip file.
'
'		Param: sExtractTo|required
'		AllowedRange: 
'		Description: The folder to extract the contents of the Zip file to.
'
'		Param: sFileInZip|required
'		AllowedRange: 
'		Description: The file name that is in the zip file.
'
'	Returns: N/A
'**********************************************************************
Public Sub winZipExtract(sZipFile, sExtractTo, ByRef sFileInZip)
   

   Dim oShell, oFilesInZip, fso, sFileName, sFileIndex

	'Trim path for spaces.
	sExtractTo = Trim(sExtractTo)
	sZipFile = Trim(sZipFile)

	sExtractTo = winCreateFolderRecursive(sExtractTo)

	'Extract the contents of the zip file and overwrites if file exists.
	Set oShell = CreateObject("Shell.Application")
	Set oFilesInZip=oShell.NameSpace(sZipFile).Items
	oShell.NameSpace(sExtractTo).CopyHere oFilesInZip, 16

	For Each sFileIndex In oFilesInZip
		sFileInZip = sFileIndex.Name
	 Next

	Set fso = Nothing
	Set oShell = Nothing

End Sub

'**********************************************************************
'	Name: winIEFileDownload
'	Purpose:This sub handles the Save routine for File Download dialogs in IE
'	Creator: Michael J. Nohai
'
'		Param: sDialogObj|required
'		AllowedRange: 
'		Description: The name of the Dialog object declared in the Object Repository.
'
'		Param: sButtonText|required
'		AllowedRange: 
'		Description: The name of the Button to click.
'
'	Returns: N/A 
'**********************************************************************'
Public Sub winIEFileDownload(sDialogObj, sButtonText)
	

	Dim oDialog, sFileName, iCtr, bSaved
	bSaved = False
	iCtr=0

	sDialogObj = Trim(sDialogObj)
	sButtonText = Trim(sButtonText)

	Do 
        Dialog(sDialogObj).WinButton("nativeclass:=Button","regexpwndtitle:=.*" & sButtonText & ".*").Click
		errHandler Err,"winIEFileDownload", micWarning
		Wait 0,500

		If Dialog(sDialogObj).WinButton("nativeclass:=Button","regexpwndtitle:=.*" & sButtonText & ".*").Exist(0)  = False Then
			bSaved=True
		Else
			iCtr = iCtr + 1
		End If
	Loop Until bSaved = True Or iCtr > 10

End Sub

'**********************************************************************
'	Name: winIESaveFile
'	Purpose:This sub handles the Save routine for Save As dialogs in IE.
'	Creator: Michael J. Nohai
'
'		Param: bOverwrite|required
'		AllowedRange: 0, 1, True, or False
'		Description: A variable to determine if you want to overwrite the file if it exists.
'
'		Param: sPath|required
'		AllowedRange: 
'		Description: The location of the file you want to save.
'
'		Param: sDraftFilePath|required
'		AllowedRange: 
'		Description: The Draft File Name and Path.
'
'	Returns: N/A
'**********************************************************************'
Public Sub winIESaveFile(bOverwrite, sPath, ByRef sDraftFilePath)
   

   Dim oDialog, sDraftFileName, colChildObj, iCtr, oDesc, fso

   sPath = Trim(sPath)

   'If the sPath location does not exist, create it.
   sPath = winCreateFolderRecursive(sPath)

	Set oDialog = Dialog("dlgFileBrowse").WinEdit("txtFileName")
   sDraftFileName = oDialog.GetROProperty("regexpwndtitle") 'ex: Backup_Globalix_LogTest_Instance38.zip
   errHandler Err,"winIESaveFile", micWarning

   'Concatinate the sPath with the FileName
   sDraftFilePath = sPath &"\" & sDraftFileName

   Dialog("dlgFileBrowse").WinEdit("txtFileName").Set sDraftFilePath
   errHandler Err,"winIESaveFile", micWarning

   Dialog("dlgFileBrowse").WinButton("nativeclass:=Button","regexpwndtitle:=.*Save.*").Click
   errHandler Err,"winIESaveFile",micWarning

	'This handles the confirmation dialog if the file already exists in the same location.
	If Dialog("dlgIEConfirm").Exist(5) Then 
		If CBool(bOverwrite) = True Then
			winIEFileDownload "dlgIEConfirm", "Yes"
		Else
			winIEFileDownload "dlgIEConfirm", "No"
		End If
	End If

	If Dialog("dlgIEDownloadComplete").Exist(5) Then
		Set oDesc = Description.Create
		oDesc("micclass").Value = "Static"

		Set colChildObj = Dialog("dlgIEDownloadComplete").ChildObjects(oDesc)
		errHandler Err,"winIESaveFile", micWarning

		For iCtr = 0 to colChildObj.Count - 1
			If StrComp(colChildObj(iCtr).GetROProperty("regexpwndtitle"), "Download Complete", 1) = 0 Then
				Dialog("dlgIEDownloadComplete").Close
				Exit For
			End If
		Next

	End If

End Sub

'**********************************************************************
'	Name: winIFFileExists
'	Purpose:This Returns True if file exits in given path and false if not.
'	Creator: Chaitanya Katta
'
'		Param: sPath|required
'		AllowedRange: C:\Users\Administrator
'		Description: Path to the file excluding the slash at the end
'
'		Param: sFileName|required
'		AllowedRange: 
'		Description: File name to verify if exists or not with extension.
'
'	Returns: True or False
'**********************************************************************
Public Function winIFFileExists(sPath,sFileName)
	 

	Dim oFso,bFileExists
	Set oFso = CreateObject("Scripting.FileSystemObject")

	bFileExists = oFso.FileExists(sPath & "\" & sFileName)
	errHandler Err,"winIFFileExists",micWarning

	winIFFileExists = bFileExists
End Function
' **********************************************************************
'	Name:  winGetUniqueFileName
'	Purpose: This function generated a unique file name by iterating a counter
'		at the end of the root file name that is passed in with the path.  It checks
'		each number that is iterated until it finds a file name that does not exist.
'		It then creates the file and returns that file name. 
'	Creator:Chaitanya Katta

  '		Param: sRootFileName| required
'		AllowedRange: 
'		Description: The root file name to use to create a unique file.  Example:
'			'Z:\Testware\Log\BenchmarkTests\Benchmark.txt'
'			The function will attach a number to the end and keep counting until it
'			finds a name that does not exist in that path.
'
'	Returns:  The name of the unique file.
'**********************************************************************'
Public Function winGetUniqueFileName(ByVal sRootFileName)
	

	Dim asPath, asFile, iCounter, sFileName, sFileNum, sPathWOFile, fso
	Dim bUnique, bExists, sNewName
	Set fso = CreateObject("Scripting.FileSystemObject")
	sPathWOFile = ""
	sRootFileName = Trim(sRootFileName)
	asPath = Split(sRootFileName,"\")
	
	For iCounter = 0 to UBound(asPath) - 1
		sPathWOFile = sPathWOFile & asPath(iCounter) & "\"
	Next
	
	asFile = Split(asPath(UBound(asPath)), ".")
	bUnique = False
	iCounter = 1
	
	Do 
		Select Case Len(iCounter)
			Case 1
				sFileNum = "00" & iCounter
			Case 2
				sFileNum = "0" & iCounter
		End Select

		If Ubound(asFile) = 0 Then
			sFileName = asFile(0) & "_" & sFileNum
		Else
			sFileName = asFile(0) & "_" & sFileNum & "." & asFile(1)
		End If

		sNewName = sPathWOFile & sFileName
		bExists = fso.FileExists(sNewName)
		
		If bExists = False Then
			bUnique = True
		Else
			iCounter = iCounter + 1
		End If

	Loop Until bUnique = True

	Set fso = Nothing

	winGetUniqueFileName = sNewName
	
End Function

'**********************************************************************
'	Name: winCreateFolderRecursive
'	Purpose:This function creates a directory path if it doesn't exist.
'	Creator: Michael J. Nohai
'
'		Param: sFullPath|required
'		AllowedRange: C:\Users\Administrator
'		Description: Path to the create the directory
'
'	Returns: The directory path
'**********************************************************************
Public Function winCreateFolderRecursive(sFullPath)
   

   Dim objFSO, iCtr, sFolder, asFolders

	Set objFSO = CreateObject("Scripting.FileSystemObject")
	If objFSO.FolderExists(sFullPath) Then
		winCreateFolderRecursive = sFullPath
		Exit Function
	End If
	
	asFolders = Split(sFullPath, "\")
	sFolder = asFolders(0)
	
	For iCtr = 1 To UBound(asFolders)
		sFolder = sFolder & "\" & asFolders(iCtr)
		If Not objFSO.FolderExists(sFolder) Then
			objFSO.CreateFolder(sFolder)
		End If
	Next

	Set objFSO = Nothing

	winCreateFolderRecursive = sFullPath

End Function

'**********************************************************************
'	Name: winClearDirectory
'	Purpose: This function is used to clear a directory of all files and folders.
'	Creator: Michael J. Nohai
'
'		Param: sDirectory|Required
'		AllowedRange: N/A
'		Description: The directory to clear.
'
'	Returns: N/A
'**********************************************************************'
Public Sub winClearDirectory(sDirectory)
	

	Dim oFSO, sPath, sFile, sFolder, oFolder

	sDirectory = Trim(sDirectory)

	Set oFSO = CreateObject("Scripting.FileSystemObject")
	errHandler Err, "winClearDirectory", g_iSeverity

	If oFSO.FolderExists(sDirectory) Then
		Set oFolder = oFSO.GetFolder(sDirectory)

		'Delete all files in root'
		For Each sFile in oFolder.Files
			oFSO.DeleteFile sFile, True
			errHandler Err, "winClearDirectory", g_iSeverity
		Next

		'Delete all subfolders and all files in subfolders'
		For Each sFolder in oFolder.SubFolders
			For Each sFile in sFolder.Files
				oFSO.DeleteFile sFile, True
				errHandler Err, "winClearDirectory", g_iSeverity
			Next
			oFSO.DeleteFolder sFolder, True
			errHandler Err, "winClearDirectory", g_iSeverity
		Next
	End If

	Set oFSO = Nothing
End Sub

'**********************************************************************
'  Name: winDlgBoxTextVerify
'  Purpose:This Sub Verifies the Message in the Pop-up Dialog.
'  Creator: Polina Rodov
'
'		Param: sMsgText | required
'		AllowedRange: Any text	
'		Description: Text to verify in pop-up dialog.
'
'  Returns: N/A
'**********************************************************************
Public Sub winDlgBoxTextVerify(sMsgText)

	Dim sText, objStaticText, objLable, iCtr, bFound

'	sText=sMsgText

     Set objStaticText =Description.Create()
     objStaticText("nativeclass").value ="Static"
'	objStaticText("text").value =utEscapeRegExChars(sMsgText)

	Set  objLable=Dialog("dlgIEMsgBox").ChildObjects(objStaticText)
	errHandler Err,"winDlgBoxTextVerify",g_iSeverity
	bFound = FALSE

	If objLable.Count > 0 Then
        For iCtr=0 to objLable.Count-1
			sText =  objLable(iCtr).GetROProperty("text")
			If InStr(1,sText, sMsgText,1) > 0 Then
				LogText "VERIFIED: Message """ & sMsgText & """ is displayed."
				bFound = TRUE
				Exit For
			End If
		Next
	End If
	If bFound = FALSE Then
			Err.Description="Message """ & sMsgText & """ is NOT displayed."
			Err.Number=g_iVERIFICATION_FAILED
			errHandler Err,"winDlgBoxTextVerify",g_iSeverity
	End If
End Sub

'**********************************************************************
'  Name: winDlgBoxOKorCancel
'  Purpose:This Sub Clicks on "OK" or "Cancel" button  on the message box.
'  Creator: Polina Rodov
'
'		Param: sAction | optional
'		AllowedRange: "OK"|"Cancel"
'							Note: Default- "OK"						
'		Description: Action to perform on the Msg Box.
'
'  Returns: N/A
'**********************************************************************
Public Sub winDlgBoxOKorCancel(sAction)


	Select Case Lcase(Trim(sAction))
	Case "ok",""
		Dialog("dlgIEMsgBox").WinObject("nativeclass:=Button","regexpwndtitle:=OK").Click
		errHandler Err, "winDlgBoxOKorCancel", g_iSeverity
		Browser("brRVE").Sync 
		errHandler Err, "winDlgBoxOKorCancel", g_iSeverity
	Case "cancel"
		Dialog("dlgIEMsgBox").WinObject("nativeclass:=Button","regexpwndtitle:=Cancel").Click
		errHandler Err, "winDlgBoxOKorCancel", g_iSeverity
		Browser("brRVE").Sync 
		errHandler Err, "winDlgBoxOKorCancel", g_iSeverity
	Case Else
		Err.Description="Button " & sAction & " is not available."
		Err.Number=g_iITEM_NOT_FOUND
		errHandler Err, "winDlgBoxOKorCancel", g_iSeverity
	End Select

End Sub

'**********************************************************************
'	Name: winFileRename
'	Purpose:This Sub renames file.
'	Creator: Polina Rodov
'
'		Param: sOldName|required
'		AllowedRange:
'		Description: The path and existing name of the file to be renamed.
'
'		Param: sNewName|optional
'		AllowedRange:
'		Description: The path and new name of the file. Defaiult: sOldName_<Time>
'
'	Returns: N/A
'**********************************************************************'
Public Sub winFileRename(ByRef sOldName,sNewName)
   
   Dim oFSO

   	Set oFSO = CreateObject("Scripting.FileSystemObject")
	errHandler Err, "winFileRename", g_iSeverity

	If  sNewName="" Then
		sNewName=split(sOldName,".")(0) & "_QTP."  & split(sOldName,".")(1)
	 End If

	If oFSO.FileExists(sOldName) Then
		oFSO.MoveFile sOldName,sNewName
		errHandler Err, "winFileRename", g_iSeverity
		sOldName=sNewName
	End If

	set oFSO = Nothing
	errHandler Err, "winFileRename", g_iSeverity

End Sub
'**********************************************************************
'	Name: winDialogFileNameGet
'	Purpose:This Sub gets the File name from "File Download" dialog.
'	Creator: Polina Rodov
'
'		Param: sFileName|required
'		AllowedRange:
'		Description: The Name of the downloaded file.
'
'	Returns: N/A
'**********************************************************************'
Public Sub  winDialogFileNameGet(ByRef sFileName)


	If  Dialog("dlgIEDownload").WinObject("nativeclass:=SysLink","attached text:=Name:").Exist Then
		sFileName= Dialog("dlgIEDownload").WinObject("nativeclass:=SysLink","attached text:=Name:").GetROProperty("text")
	Else
		Err.Description="File Name  is NOT available."
		Err.Number=g_iVERIFICATION_FAILED
		errHandler Err,"winDialogFileNameGet",g_iSeverity
	End If

End Sub
'**********************************************************************
'	Name: winFileNameLanguageVerify
'	Purpose:This Sub verifies if specified file name contain text on specified Language.
'	Example: winFileNameLanguageVerify "C:\R563_LabLoader_001_new\Downloads\Blank_Template 2012_09_06.xls","Blank","English"
'	Creator: Polina Rodov
'
'		Param: sFile|required
'		AllowedRange:
'		Description: The Name to be verified.
'
'		Param: sName|required
'		AllowedRange:
'		Description: This is the part of the name on specified language.
'
'		Param: sLanguage|required
'		AllowedRange:
'		Description: This is language.
'
'	Returns: N/A
'**********************************************************************'
Public Sub winFileNameLanguageVerify(sFile,sName,sLanguage)
	

	If inStr(sFile,sName)>0 Then
		LogText "VERIFIED: File name """ & sFile & """ is in "& sLanguage &" as expected."
	Else
		Err.Description="File name """ & sFile & """ is NOT in "& sLanguage &"."
		Err.Number=g_iVERIFICATION_FAILED
		errHandler Err, "winFileNameLanguageVerify", g_iSeverity
	End If

End Sub
'**********************************************************************
'	Name: winFileContentsRead
'	Purpose:This Funtion returns the contents of a Text file.
'	Creator: Chaitanya Katta
'
'		Param: sFilePath|required
'		AllowedRange:
'		Description: Path to the file including the file name.
'
'	Returns: the contents of a Text file.
'**********************************************************************'
Public Function winFileContentsRead(sFilePath)

	Dim oFso,oFile, oStream
	
	Set oFso = CreateObject("Scripting.FileSystemObject")
	
	If oFso.FileExists(sFilePath) Then
		Set oStream = CreateObject("ADODB.Stream")
    	oStream.Open
    	oStream.Charset = "utf-8"

		oStream.LoadFromFile sFilePath
		winFileContentsRead = oStream.ReadText
		oStream.Close
		 
		Set oStream = Nothing
	Else
		Err.Number=g_iITEM_NOT_FOUND
		Err.Description="File """ & sFilePath & """ is not found "
		errHandler Err, "winFileContentsRead", g_iSeverity				
	End If

	Set oFso = Nothing
	
End Function
'**********************************************************************
'	Name: winFileContentVerify
'	Purpose:This Funtion verifies if specified text is available in the specified file in exact order.
'	Creator: Polina Rodov
'
'		Param: sFile|required
'		AllowedRange:
'		Description: Path to the file including the file name.
'
'		Param: sExpText|required
'		AllowedRange: Example: "-- Upload Started--|3 global data dictionaries saved.||Upload successful.||"
'		Description: This is pipe delimited lines of text that expected to be in the file in exact order..
'
'	Returns: N/A
'**********************************************************************'
Public Sub winFileContentVerify(sFile, sExpText)
	Dim sText, asText, asExpText, iCtr

	sText = Trim(winFileContentsRead(sFile))
	sText = Replace(sText,"* ","")
	asText = Split(sText,vbCrLf)

	asExpText = Split(sExpText,"|") 

	If Ubound(asText) = 0 and Ubound(asExpText) = 0 Then
		LogText "VERIFIED: File " & sFile & " is empty as expected."
	ElseIf Ubound(asText) = 0 and Ubound(asExpText) <> 0 Then
		Err.Description = "File " & sFile & " is empty but should contain data."
		Err.Number=g_iVERIFICATION_FAILED
		errHandler Err, "winFileContentVerify",g_iSeverity
	ElseIf Ubound(asText) <> 0 and Ubound(asExpText) = 0 Then
		Err.Description = "File " & sFile & " is not empty but should not contain data."
		Err.Number=g_iVERIFICATION_FAILED
		errHandler Err, "winFileContentVerify",g_iSeverity
	Else
		For iCtr = 0 to Ubound(asExpText)
			If  StrComp(asText(iCtr),asExpText(iCtr),1) = 0 Then
				LogText "VERIFIED: File " & sFile & " contains: """ & asExpText(iCtr) & """ as expected."
			Else
				Err.Description =  "File : " & sFile & " doesn't match expected result."
				Err.Number=g_iVERIFICATION_FAILED
				errHandler Err, "winFileContentVerify",g_iSeverity
				Exit For
			End If
		Next
	End If
End Sub

'*******************************************************************************************************
'	Name: winHelpBrowserClose
'	Purpose: This sub will close Help window
'	Creator: Polina Rodov
'
'		Param: 
'		AllowedRange:
'		Description: 
'
'	Returns: N/A  
'**********************************************************************'**********************************
Public Sub winHelpBrowserClose()

	

	Dim dtEndTime,bSynced

	'Close the browser
	Browser("openurl:=.*help.*").Close
	errHandler Err,"winHelpBrowserClose",g_iSeverity

	Wait(2)
	'Check if the Browser is closed
	If Browser("openurl:=.*help.*").Exist(0) Then
		Err.Description = "Browser for Help was not closed"
		errHandler Err,"winHelpBrowserClose",g_iSeverity
	End If
	
End Sub

'**********************************************************************
'	Name: winSendKeys
'	Purpose: This function is used to send keystroke events.
'	Creator: Michael J. Nohai
'
'		Param: sKey|Required
'		AllowedRange: N/A
'		Description: The key to send.
'
'	Returns: N/A
'**********************************************************************'
Public Sub winSendKeys(sKey)
	

	Dim objShell

	sKey = Trim(sKey)

	Set objShell = CreateObject("WScript.Shell")
	errHandler Err, "winSendKeys", g_iSeverity

	'objShell.AppActivate
	'Wait(2)

	objShell.SendKeys(sKey)
	Wait(1)

	Set objShell = Nothing
End Sub


'**********************************************************************
'	Name: winCSVArray
'	Purpose: This function is used to read the contents of a CSV file
'			into an array.
''
'	Creator: Marc Paniccia
'
'		Param: sCSVFile|Required
'		AllowedRange: N/A
'		Description: The file name (including path) to the csv source file.
'
'	Returns: Array of sorted csv file data into rows and columns
'**********************************************************************'
Public Function winCSVArray(sCSVFile)

	

	Dim objFSO, objFile
	Dim asAllRows, asOneRow, asAllParsed
	Dim i, j, iMaxCols
	iMaxCols=0

	' open csv file and read each line into the array inRow
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objFile = objFSO.OpenTextFile(sCSVFile,"1",True)

	asAllRows = Array()
	Do While Not objFile.AtEndOfStream
		ReDim Preserve asAllRows(i)
		asAllRows(i) = objFile.ReadLine
		i=i+1
	Loop
	
	objFile.Close

	Redim asAllParsed(Ubound(asAllRows), 0)
	For i=0 to Ubound(asAllRows)
	    asOneRow = split(asAllRows(i),",")
		If iMaxCols <  Ubound(asOneRow) Then
			iMaxCols = Ubound(asOneRow)
		End If
	    ReDim Preserve asAllParsed(Ubound(asAllRows), iMaxCols)
	    For j=0 to Ubound(asOneRow)
	        asAllParsed(i,j) = asOneRow(j)
	    Next
	Next

	Set objFSO = Nothing
	Set objFile = Nothing
	
	winCSVArray =asAllParsed

End Function

'**********************************************************************
'	Name: winZipClose
'	Purpose: This sub closes the Zip application.
'	Creator: Michael J. Nohai
'
'	Returns: N/A
'**********************************************************************
Public Sub winZipClose()
   

	Dim iCtr, oDesc, colWindows, sTitle

	Set oDesc = Description.Create
	oDesc("Class Name").value = "Window"
	
	Set colWindows = Desktop.ChildObjects(oDesc)

	For iCtr = 0 To colWindows.Count - 1

		sTitle = colWindows(iCtr).GetROProperty("regexpwndtitle")

		If Instr(1, sTitle, ".zip", 1) > 0 Then
			colWindows(iCtr).Close
			Exit For
		End If
	Next

End Sub

'**********************************************************************
'	Name: winRunCommand
'	Purpose: Runs the specified command
'	Creator: Jonathan Price
'
'		Param: sCommand
'		AllowedRange:
'		Description: The command to run
'
'		Param: sWaitForExit
'		AllowedRange: True to wait, false to return immediately
'		Description: Whether to wait for the command to complete before continuing
'
'	Returns: The current time, converted to UTC
'**********************************************************************'
Public Sub winRunCommand(sCommand, sWaitForExit)
	
	Dim oShell
	Set oShell = CreateObject("WScript.Shell") 
	errHandler Err, "winRunCommand", g_iSeverity
	oShell.Run "cmd /c " & sCommand, 2, sWaitForExit
	errHandler Err, "winRunCommand", g_iSeverity
	Set oShell = Nothing
End Sub

'**********************************************************************
'	Name: winCloseIEDialogs *Under construction
'	Purpose: This sub will close all IE Dialog windows.  Normally used in
'		a recovery scenario.
'	Creator: Mark Clemens
'
'	Returns: N/A
'**********************************************************************'
Public  Sub winCloseIEDialogs()
	'Put code here to close all IE Dialog windows.
	
	
End Sub

'**********************************************************************
'	Name: winWaitExist
'	Purpose:This Function will wait until object exist.
'	Creator: Shubhank Khare
'
'		Param: objStatementExecute | required
'		AllowedRange:  QTP object statement
'		Description:  QTP executable statement to be existed

'		Param: iWaitTime | required
'		AllowedRange:  
'		Description: Wait Time in seconds

'
'	Returns: It returns boolean value True if object exist otherwise returns false.
'**********************************************************************
Public Function winWaitExist(objStatementExecute,iWaitTime)

	Dim dtEndTime, bSynced
	dtEndTime = DateAdd("s",iWaitTime,Now)
	bSynced = False
	Do
		If objStatementExecute.Exist(0)  Then

		' Set flag to True to exit the loop.
			bSynced = True
			Exit Do
		End If
	Loop While dtEndTime > Now And bSynced = False
	If bSynced<> True Then
		errHandler Err, "winWaitExist", micFail
	End If
	winWaitExist=bSynced
End Function


'**********************************************************************
' Name: winExcelKill
' Purpose:This Sub is used to Kill all Excel processes.
' Creator: Gaurav Gupta

' Returns: N/A
'**********************************************************************	
	
Public Sub winExcelKill()

	Dim sComputer,oWMIService,colProcesses,oProcess
	
	sComputer = "."
	
	Set oWMIService = GetObject("winmgmts:\\" & sComputer & "\root\cimv2")
	Set colProcesses = oWMIService.ExecQuery ("Select * from Win32_Process Where Name = 'Excel.exe'")
	
	'Loop through all process in collection and Kill the process with Name='Excel.exe'
	For Each oProcess in colProcesses	
		oProcess.Terminate()	
	Next


End Sub	


'**********************************************************************
'	Name: WinAntiSleep
'	Purpose:This Sub makes the script periodically moving mouse to avoid breaking of the execution.
'			this sub stop the computer to go on sleep mode .	
'	Creator: Gaurav Gupta

'	Returns:N/A .
'**********************************************************************

Public Sub WinAntiSleep()

Dim ictr,oTimer,oDeviceReplay,iTimeElapsed


 Set oTimer = MercuryTimers("AntiSleep")
 iTimeElapsed = CInt(oTimer.ElapsedTime/1000)

 If iTimeElapsed = 0 Then
  MercuryTimers("AntiSleep").Start
  Exit Sub
 End If

 If iTimeElapsed < SleepTime_Max Then
  Exit Sub
 End If

Set oDeviceReplay = CreateObject("Mercury.DeviceReplay")

 For ictr = 100 To 110
   oDeviceReplay.MouseMove ictr,300
 Next

MercuryTimers("AntiSleep").Start

Set oDeviceReplay = Nothing
End Sub 
