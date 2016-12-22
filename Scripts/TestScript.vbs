
	sExcelPath = "C:\QTP_DevOps_Demo\Cal_APP\Data\cal.xlsx"
	sSheet = "Data"
	Set oFullRecordSet = xclGetSheetRecords("","Execute","Y",sSheet,sExcelPath)
	Set oEmailRecordSet = xclGetSheetRecords("","","","Email",sExcelPath)

	sTOMembers = oEmailRecordSet.Fields("To")
	sCCMembers = oEmailRecordSet.Fields("CC")
	sSubjectLine = oEmailRecordSet.Fields("Subject")
	sBodyLine = oEmailRecordSet.Fields("Body")
	sAttachDoc = oEmailRecordSet.Fields("Attachment")

	'Setup the Result Folder before Running the test
	utFinaCIRunResultsFileSetup  "C:\DevOpsMasterFolder\Results"

	For iIterator = 1 To oFullRecordSet.RecordCount Step 1
	
		sScriptName = oFullRecordSet.Fields("ScriptName")
		sSerialNo = oFullRecordSet.Fields("Sno")

			Execute sScriptName&"("&sSerialNo&")"

		oFullRecordSet.MoveNext
		
	Next

'Send Mail to the Owners of the application
utSendEmailFromOutlook sTOMembers,sCCMembers,sSubjectLine,sBodyLine,sAttachDoc


'Run Integration Testing if all the Modules are working Fine
IntegrationTesting sAttachDoc,sSheet,sExcelPath,oEmailRecordSet

Set oEmailRecordSet = Nothing
Set oFullRecordSet = Nothing
