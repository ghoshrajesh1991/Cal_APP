
Public Function Addition(sNo)
	g_sAppName = "CAL"
	g_sRunType = "Regression"
	g_bDebugMode = False

	
	sExcelPath = "C:\QTP_DevOps_Demo\Cal_APP\Data\cal.xlsx"
	Set oRecordSet = xclGetSheetRecords("","Sno",sNo,"Data",sExcelPath)
	sIterationTimes = oRecordSet.Fields("IterationTime")
	sScriptName = oRecordSet.Fields("ScriptName")
	
For Iterator = 1 To sIterationTimes Step 1
	Set oScriptRecordSet = xclGetSheetRecords("","","",sScriptName,sExcelPath)

		sOperation = oScriptRecordSet.Fields("Operations")
		sFirstNum = oScriptRecordSet.Fields("FirstNum")
		sSecondNum = oScriptRecordSet.Fields("SecNum")
		sEnvironment = oRecordSet.Fields("Environment")
	
		PrintToLog "Launnching the Addition Script"
			calAppOpen sEnvironment
		
		PrintToLog "Performing calculations"		
			iVal = calOperationPerform(sOperation,sFirstNum,sSecondNum)
			
		PrintToLog "Verify if the Addition Functionality is working fine"
			calValueAfterOperationVerify sNo,iVal,sFirstNum,sSecondNum
		
		PrintToLog "CLose the Browser"		
			calAppClose

		oScriptRecordSet.MoveNext
Next
	utCopyRunResults g_sAppName,g_sRunType,sScriptName,g_sRootPath,sReferenceLogFilePath
	utProcessResults "C:\DevOpsMasterFolder\Results\Run_Results.txt",sReferenceLogFilePath,sScriptName
	
		Set oScriptRecordSet = Nothing
		Set oRecordSet = Nothing
End Function
