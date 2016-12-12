


 If RepositoriesCollection.Find("C:\QTP_DevOps_Demo\ObjectRepository\cal.tsr") = -1 Then
 			RepositoriesCollection.Add "C:\QTP_DevOps_Demo\ObjectRepository\cal.tsr"
 End If 


Public Sub calAppOpen(sUrl)

	utCloseBrowser
	systemutil.Run "iexplore.exe",sUrl
	
	Set oPage = Browser("brCal").Page("pgCal")
	
	dateTime = DateAdd("s",60,now)
	While oPage.WebEdit("name:=result").Exist = Flase and dateTime > now
		
	Wend
	oPage.WebEdit("name:=result").highlight
	Set oPage = nothing
End Sub




Public Function calOperationPerform(sOperations, iNum1, iNum2)
	Dim iSum
	
	If iNum1 = "" or iNum1 = "NA" Then
		iNum1 = 0
	End If
	If iNum2 = "" or iNum2 = "NA" Then
		iNum2 = 0
	End If
	
	Select Case UCASE(sOperations)
		Case "MUL"
			iSum = iNum1 * iNum2
			sOper = "\x" 
		Case "SUB"
			iSum = iNum1 - iNum2
			sOper = "\-"
		Case "ADD"
			iSum = iNum1 + iNum2
			sOper = "\+"			
	End Select
	Set oPage = Browser("brCal").Page("pgCal")

	oPage.WebButton("name:=   AC   ").Click
		oPage.Sync
	'Enter First Num
	oPage.WebButton("name:="&iNum1).Click
		oPage.Sync

	oPage.WebButton("name:="&sOper).Click
		oPage.Sync

	oPage.WebButton("name:="&iNum2).Click
		oPage.Sync
		
	oPage.WebButton("name:==").Click
		oPage.Sync
		
	calOperationPerform = iSum
	Set oPage = Nothing
End Function


Public Sub calAppClose()

utCloseBrowser

End Sub



Public Sub calValueAfterOperationVerify(sNo,iVal, iFirstNo, iSecondNo)

Set oPage = Browser("brCal").Page("pgCal")

	iResult = Trim(oPage.WebEdit("name:=result").GetRoProperty("value"))
	
	If CInt(iResult) = CInt(iVal) Then	
		Err.Number = 0
		Err.Description = "Operation Verified: Fuctioning properly"		
		errHandler Err,"calValueAfterOperationVerify",micPass
'		xclWriteRecordsToCell "C:\QTP_DevOps_Demo\Data\cal.xlsx","Data","SNO",sNo,"Status","Pass"
	Else 	
		Err.Number = g_iVERIFICATION_FAILED
		Err.Description = "Operation Failed:Not Fuctioning properly"		
		errHandler Err,"calValueAfterOperationVerify",micWarning
'		xclWriteRecordsToCell "C:\QTP_DevOps_Demo\Data\cal.xlsx","Data","SNO",sNo,"Status","Fail"
	End If

Set oPage = Nothing
End Sub
