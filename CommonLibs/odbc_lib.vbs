Option Explicit

'*************************** MAINTAIN THIS HEADER! *********************************
'     Library Name:     odbc_lib.vbs
'     Purpose:          Contains functions for accessing data.
'---------------------------------------------------------------------------------
'
'    Copyright (c) 2007-2012 by Moody's Corp.
'    Confidential - All Rights Reserved
'
'********************************************************************************** 

 
'**********************************************************************************
'                           PRIVATE CONSTANTS and VARIABLES
'**********************************************************************************

'**********************************************************************************
'                           PUBLIC CONSTANTS and VARIABLES
'**********************************************************************************

'Cursor types
Public Const adOpenForwardOnly = 0
Public Const adOpenKeyset = 1
Public Const adOpenDynamic = 2
Public Const adOpenStatic = 3

'Lock types
Public Const adLockReadOnly = 1
Public Const adLockPessimistic = 2
Public Const adLockOptimistic = 3
Public Const adLockBatchOptimistic = 4

'**********************************************************************************
'                             PRIVATE FUNCTIONS
'**********************************************************************************



'**********************************************************************************
'                                PUBLIC FUNCTIONS
'**********************************************************************************

'**********************************************************************
'   Name: odbcConnectionOpen
'   Purpose: This Function creates an ADODB.Connection object.
'   Creator: Mark Clemens & Michael J. Nohai
'
'		Param: sServer|required
'		AllowedRange: 
'		Description: The server the database resides on. For Jet connections, this should
'			be passed as an empty string.
'
'		Param: sDataBase|required
'		AllowedRange: 
'		Description: The database to access. For Access, this should be the full path to the .mdb file.
'			For Jet, this should be the full path to the Excel file.
'
'		Param: sUser|optional|AssumedValue="" 
'		AllowedRange: 
'		Description: The user to use for the connection. If the connection doesn't need a user,
'			pass an empty string..
'
'		Param: sPassword|optional|AssumedValue="" 
'		AllowedRange: 
'		Description: The password for the user. If the connection doesn't need a user or a 
'			password, pass an empty string.
'
'		Param: sType|required
'		AllowedRange: "Access", "SQL", "Jet", "Excel"
'		Description: The type of connection.
'
'   Returns: ADODB.Connection object.  
'**********************************************************************'
Public Function odbcConnectionOpen(sServer, sDataBase, sUser, sPassword, sType)
	
	
	Dim objConn, sConnStr

	Set objConn = CreateObject("ADODB.Connection")

	Select Case LCase(sType)
		Case "access"
			sConnStr = "DRIVER=Microsoft Access Driver (*.mdb, *.accdb);" & _
					   "DBQ=" & sDataBase &";" & _
					   "UID=" & sUser & ";" & _
					   "Password=" & sPassword & ";"
		Case "sql"
			sConnStr = "DRIVER=SQL Server;SERVER="& sServer & _
					   ";User ID=" & sUser & _
					   ";Password=" & sPassword & _
					   ";database=" & sDataBase &";"
		Case "jet"
			sConnStr = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & sDataBase & _
					   ";Extended Properties=""Excel 8.0;HDR=Yes;IMEX=1"";"
		Case "excel"
			sConnStr = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" & sDataBase & _
					   ";Extended Properties=""Excel 12.0 Xml;HDR=YES;IMEX=1"";"	
		Case "db2"
				sConnStr = "Driver={IBM DB2 ODBC DRIVER};" & _
				"Database=" & sDataBase & ";" & _
				"Hostname=" & sServer & ";" & _
				"Port=60004;" & _ 
				"Protocol=TCPIP;" & _
				"Uid="& sUser & ";" & _
				"Pwd="& sPassword & ";"  	
				
		Case "sybase"
				sPort = 12306
				sConnStr = "Provider=ASEOLEDB ;Server Name=" & sServer &_
				";Server Port Address=" & sPort &"; Initial Catalog=" & sDataBase & _
				"; User Id=" & sUser & "; Password=" & sPassword
					   
		Case Else
			Err.Number = g_iOUT_OF_RANGE
			Err.Description = sType & " is not a valid type."
			errHandler Err, "odbcConnectionOpen", g_iSeverity
			Exit Function
	End Select

	objConn.Open(sConnStr)
	errHandler Err, "odbcConnectionOpen", g_iSeverity

	Set odbcConnectionOpen = objConn

End Function

'**********************************************************************
'	Name: odbcConnectionClose
'	Purpose: This sub closes an ADODB.Connection object for SQL Server.
'	Creator: Michael J. Nohai
'
'		Param: objConn
'		AllowedRange:
'		Description: The ADODB.Connection object to close.
'
'	Returns: N/A
'**********************************************************************'
Public Sub odbcConnectionClose(objConn)
	

	If objConn.State = 1 Then
		objConn.Close()
		errHandler Err, "odbcConnectionClose", g_iSeverity
	End If
	
	Set objConn = Nothing

End Sub

'**********************************************************************
'	Name: odbcRecordSetOpen
'	Purpose: This Function creates an ADODB.Recordset object for SQL Server
'		and executes a query.
'	Creator: Michael J. Nohai
'
'		Param: objConn
'		AllowedRange:
'		Description: The ADODB.Connection object.
'
'		Param: sQuery
'		AllowedRange:
'		Description: The SQL Query to execute.
'
'		Param: sCursorType|optional|AssumedValue=adOpenStatic
'		AllowedRange: adOpenDynamic, adOpenKeyset, adOpenForwardOnly, adOpenStatic
'		Description: The CursorType to use. If doing an update or insert SQL, a Dynaset 
'			must be used. If doing a regular query, a Keyset should be used.
'
'		Param: sLockType|optional|AssumedValue=adLockOptimistic
'		AllowedRange: adLockOptimistic, adLockPessimistic, adLockReadOnly, adLockBatchOptimistic
'		Description: The LockType to use.
'
'	Returns: ADODB.Recordset object.
'**********************************************************************'
Public Function odbcRecordSetOpen(objConn, sQuery, sCursorType, sLockType)
	

	Dim objRecSet

	sQuery = Trim(sQuery)

	Set objRecSet = CreateObject("ADODB.Recordset")

	If sCursorType = "" Then
		sCursorType = adOpenStatic
	End If

	If sLockType = "" Then
		sLockType = adLockOptimistic
	End If

	objRecSet.Open sQuery, objConn, sCursorType, sLockType
	errHandler Err, "odbcRecordSetOpen", g_iSeverity

	If objRecSet.RecordCount > 0 Then
		objRecSet.MoveFirst
	End If

	Set odbcRecordSetOpen = objRecSet

End Function

'**********************************************************************
'   Name:    odbcTableExists
'   Purpose:This function checks if a table exists.  If it doesn't, 
'		the function returns False.  If it exists, the function returns True.
'   Creator:Mark Clemens
'
'		Param: cn| required
'		AllowedRange: 
'		Description: The previously created connection to the database..
'
'		Param: sTable| required
'		AllowedRange: 
'		Description: The table to check for.
'
'   Returns: N\A
'**********************************************************************'
Public Function odbcTableExists(cn, sTable)
	Dim sSQL, rs
	
	
	sSQL = "Select * From " & sTable
		
	Set rs = CreateObject("adodb.recordset")

	rs.Open sSQL, cn, adOpenKeyset
	If err.number = -2147217887 Then
		odbcTableExists = False
		err.clear
	ElseIf err.number = 0 THen
		odbcTableExists = True
		rs.close
	End If

End Function

'**********************************************************************
'   Name:    odbcDropTable
'   Purpose:This function deletes a table from a database.
'   Creator:Mark Clemens
'
'		Param: cn| required
'		AllowedRange: 
'		Description: The previously created connection to the database..
'
'		Param: sTable| required
'		AllowedRange: 
'		Description: The table to delete.
'
'   Returns: N\A
'**********************************************************************'
Public Sub odbcDropTable(cn, sTable)
	

	Dim sSQL, rs
	sSQL = "Drop TABLE " & sTable
	Set rs = CreateObject("adodb.recordset")

	rs.Open sSQL, cn, adOpenDynamic

End Sub

'**********************************************************************
'   Name:    odbcCreateAccessDB
'   Purpose:This sub creates an access data base (.mdb) file with the given path and file name.
'   Creator:Mark Clemens
'
'		Param: sDB| required
'		AllowedRange: 
'		Description: The full path and file name of the access database..
'
'   Returns: N\A
'**********************************************************************'
Public Sub odbcCreateAccessDB(sDB)
	
	Dim oApp, fso, iCounter, asFile, sRootFile, sCopyFile, bExists
	Dim sTempDBName

	sTempDBName = sDB
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set oApp = CreateObject("Access.Application")
	asFile = Split(sDB, ".")
	sRootFile = asFile(0)
	
	bExists = False
	iCounter = 1

	If Right(sDB, 4) <> ".mdb"  Then
		sDB = sDB & ".mdb"
	End If

	If fso.FileExists(sDB) Then
		Do 
			sCopyFile = sRootFile & iCounter & ".mdb"
			If fso.FileExists(sCopyFile) = False Then
				fso.CopyFile sDB, sCopyFile
				fso.DeleteFile sDB
				bExists = True
			Else
				iCounter = iCounter + 1
			End If
		Loop Until bExists = True
	End If


	oApp.NewCurrentDatabase sDB
	errHandler Err, "odbcCreateAccessDB", g_iSeverity
	oApp.Quit
	Set oApp = Nothing

ENd Sub
'**********************************************************************
'   Name:    odbcGetSQLQuery
'   Purpose:This Function gets the SQL stored in a given named query
'   Creator:Lavanya Bathina
'
'		Param: sQueryName| required
'		AllowedRange: Name of the existing Named Query in Access DB
'		Description: Name of the Query from which the SQL is to be retrieved.
'
'		Param: sDBPath| required
'		AllowedRange: 
'		Description: Name of the Access DB with full path. This the Database in '	
'		which the named Query exists
'
'   Returns: Returns SQL of the specified Named Query
'**********************************************************************'
Public Function odbcGetSQLQuery(sQueryName,sDBPath)
		

	'Variable Declaration
	Dim oDao,sSQL,oDb,oQDef

	'Create an Object reference to Database 
	If instr(1,sDBPath,".mdb")>0 Then
		'2003 Format (.mdb Extension)
		Set oDao = CreateObject("DAO.DBEngine.36")
		errHandler Err, "odbcGetSQLQuery", g_iSeverity
	Else
		'2007 Format (.accdb format)
		Set oDao = CreateObject("DAO.DBEngine.120")
		errHandler Err, "odbcGetSQLQuery", g_iSeverity
	End If
	'Open the DB
	Set oDb = oDao.OpenDatabase(sDBPath)
	errHandler Err, "odbcGetSQLQuery", g_iSeverity

	'Gets the reference of the specified Named Query Object.
	Set oQDef = oDb.QueryDefs(sQueryName)
	errHandler Err, "odbcGetSQLQuery", g_iSeverity

	'Gets the SQL from the Named Query
	sSQL = oQDef.Sql
	errHandler Err, "odbcGetSQLQuery", g_iSeverity

	'Returns  the SQL statement
	odbcGetSQLQuery	= sSQL 

End Function
'**********************************************************************
'	Name: odbcSPExecute
'	Purpose:This Sub executes specified Stored Procedure against specified DB with specified parameters..
'	Creator: Polina Rodov
'		Param: sServer| required	
'		AllowedRange: 
'		Description: Machine name where the application database resides.
'
'		Param: sDB| required	
'		AllowedRange: 
'		Description:Database name on the server to connect
'
'		Param: sDBUser| required	
'		AllowedRange: 
'		Description: Username for the database.
'
'		Param: sDBPwd| required	
'		AllowedRange: 
'		Description: Password for the user name to login
'
'		Param: sSPName| required	
'		AllowedRange: 
'		Description: Name of the Stored Procedure
'
'		Param: sParameters| required	
'		AllowedRange: "0|1_abc|test"
'		Description: Parameters to be passed into Stored procedure(pipe delimited)
'
'
'	Returns: N/A
'**********************************************************************
Public Sub odbcSPExecute(sServer,sDB,sDBUser,sDBPwd,sSPName,sParameters)

	Dim asParameter,iCtr,sConStr,objCmd

	'Create the connection and command objects.
    Set objCmd = CreateObject("ADODB.Command")
    errHandler Err,"odbcSPExecute",g_iSeverity

	' Connection strings for the databases.
	sConStr = "DRIVER=SQL Server;SERVER="& sServer &";User ID=" & sDBUser &";Password=" & sDBPwd &";database=" & sDB &";"
	
	' Open connection to execute the Stored Proecedure on application db
	objCmd.ActiveConnection = sConStr
	errHandler Err,"odbcSPExecute",g_iSeverity

 	' Set the command type to Stored Procedures
	objCmd.CommandType = 4 ' CommandTypeEnum for SP is 4, adCmdTable For table is 2.
	objCmd.CommandText = sSPName   'testproc is name of stored procedure

	'define Parameters for the stored procedure
	objCmd.Parameters.Refresh
	errHandler Err,"odbcSPExecute",g_iSeverity

	asParameter = split(sParameters,"|")

	'Set parameters for stored procedure
	For iCtr = 0 to Ubound(asParameter)
		objCmd.Parameters(iCtr + 1).Value = asParameter(iCtr)
	Next

	objCmd.Execute()
	errHandler Err,"odbcSPExecute",micFail

	Set objCmd = Nothing
	errHandler Err,"odbcSPExecute",g_iSeverity

End Sub


'**********************************************************************
'    Name: odbcSybaseRecordsGet
'    Purpose: This function returns Corresponding records from given table
'             for provided conditions.
'    Creator: Gaurav Gupta
'
'        Param: sColumnName|Optional|Assumedvalue = All Columns
'        AllowedRange: 
'        Description:column name to retrieve the value from.

'        Param: sCondColName|required 
'        AllowedRange:
'        Description:column name to which conditions applied. 

'        Param: sCondColValue|required 
'        AllowedRange:
'        Description:column value for column to which conditions applied. 

'        Param: sTable|required 
'        AllowedRange:
'        Description:Table name to retrieve the value from
'

'        Param: sConnStr|required 
'        AllowedRange:
'        Description:Connection string to use for Connection object 
'		    	it has following info delimited by pipe i.e."|" 	
'					Server Name|Server Port Address|DB Name|User Id|Password
'
'    Returns: Correspodning records from given sheet
'             for provided conditions .
'**********************************************************************


Public Function odbcSybaseRecordsGet( ByVal sColumnName,ByVal sCondColName,ByVal sCondColValue,ByVal sTable,sConnStr)


	Dim oConnection, oRecordSet 
	Dim sQuery
	
	Set oConnection = CreateObject("ADODB.Connection")
	Set oRecordSet = CreateObject("ADODB.Recordset")
	
	
	asConnStr=Split(sConnStr,"|")
	
'	oConnection.ConnectionString ="Provider=Sybase.ASEOLEDBProvider.2 ;Server Name=" & asConnStr(0) &_
'	";Server Port Address=" & asConnStr(1) &"; Initial Catalog=" & asConnStr(2) & _
'	"; User Id=" & asConnStr(3) & "; Password=" & asConnStr(4) 
'	
	oConnection.ConnectionString ="Provider=ASEOLEDB ;Server Name=" & asConnStr(0) &_
	";Server Port Address=" & asConnStr(1) &"; Initial Catalog=" & asConnStr(2) & _
	"; User Id=" & asConnStr(3) & "; Password=" & asConnStr(4) 
    
	oConnection.CommandTimeout = 500 
	
	oConnection.Open


	
		If sColumnName="" Then         
				If sCondColName=""  Then
					sQuery="Select *  from " & sTable &""             
					
					Else	
					Dim ictr
					asCondColName=Split(sCondColName,"|") 
					asCondColValue=Split(sCondColValue,"|")
					
					sQuery="Select *  from " & sTable & " where " & asCondColName(ictr) & " = " &asCondColValue(ictr) &""
					
					For ictr =1 To Ubound(asCondColName)	         
					
					
					sQuery=sQuery & " and " &  asCondColName(ictr) & " = "&asCondColValue(ictr) & ""
					
					Next
				End If 
		
			oRecordSet.Open sQuery, oConnection,1, 3
			Set odbcSybaseRecordsGet = oRecordSet        
		Else
		
			If sCondColName=""  Then
				sQuery="Select " & sColumnName & " from " & sTable & ""             
				
				Else	
				
				asCondColName=Split(sCondColName,"|") 
				asCondColValue=Split(sCondColValue,"|")
				
				sQuery=" Select " & sColumnName & "  from " & sTable & " where " & asCondColName(ictr) & " = " &asCondColValue(ictr) &""
				For ictr =1 To Ubound(asCondColName)
				
				
				
				sQuery=sQuery & " and " &  asCondColName(ictr) & " = "&asCondColValue(ictr) & ""
				
				Next
			End If 
				oRecordSet.Open sQuery,oConnection,1, 3                     
				odbcSybaseRecordsGet=oRecordSet(0).Value
		End If

End Function

'**********************************************************************
'   Name: odbcSqlServerConnectionOpen
'   Purpose: This Function creates an ADODB.Connection object For SQl Server.
'   Creator: Gaurav Gupta
'
'        Param: sServer|required
'        AllowedRange: 
'        Description: The server the database resides on. For Jet connections, this should
'            be passed as an empty string.
'
'        Param: sDataBase|required
'        AllowedRange: 
'        Description: The database to access. 
'
'        Param: sTrusted|required
'        AllowedRange: Yes,No
'        Description: Trusted Connection required. 
'            In case of trusted connection sUser and sPassword will be empty
 
'
'        Param: sUser|optional|AssumedValue="" 
'        AllowedRange: 
'        Description: The user to use for the connection. If the connection doesn't need a user,
'            pass an empty string.
'
'        Param: sPassword|optional|AssumedValue="" 
'        AllowedRange: 
'        Description: The password for the user. If the connection doesn't need a user or a 
'            password, pass an empty string.

'
'   Returns: ADODB.Connection object.  
'**********************************************************************

Public Function odbcSqlServerConnectionOpen(sServer,sDataBase,sTrusted,sUser,sPassword)
    
    Dim oConnection, oRecordSet 
    Dim sQuery
    
    Set oConnection = CreateObject("ADODB.Connection")    

    
    oConnection.ConnectionString ="DRIVER=SQL Server;SERVER="& sServer & _
     ";Trusted_Connection="& sTrusted & _
    ";User ID=" & sUser & _
    ";Password=" & sPassword & _
    ";database=" & sDataBase &";"
    
    oConnection.Open
    
    
    Set odbcSqlServerConnectionOpen = oConnection
    
    
End Function


'**********************************************************************
'   Name: odbcSybaseConnectionOpen
'   Purpose: This Function creates an ADODB.Connection object For Sybase.
'   Creator: Gaurav Gupta
'
'        Param: sServer|required
'        AllowedRange: 
'        Description: The server the database resides on. 


'        Param: sPort|required
'        AllowedRange: 
'        Description: The Port number the database resides on
'
'        Param: sDataBase|required
'        AllowedRange: 
'        Description: The database to access.  
'
'        Param: sUser|optional|AssumedValue="" 
'        AllowedRange: 
'        Description: The user to use for the connection. If the connection doesn't need a user,
'            pass an empty string.
'
'        Param: sPassword|optional|AssumedValue="" 
'        AllowedRange: 
'        Description: The password for the user. If the connection doesn't need a user or a 
'            password, pass an empty string.

'
'   Returns: ADODB.Connection object.  
'**********************************************************************


Public Function odbcSybaseConnectionOpen(sServer,sPort,sDataBase,sUser,sPassword)

	Dim oConnection 
  
    
    Set oConnection = CreateObject("ADODB.Connection")    

    
	oConnection.ConnectionString ="Provider=ASEOLEDB ;Server Name=" & sServer &_
				";Server Port Address=" & sPort &"; Initial Catalog=" & sDataBase & _
				"; User Id=" & sUser & "; Password=" & sPassword
    
	oConnection.CommandTimeout = 500 
	
	oConnection.Open
    
    
    Set odbcSybaseConnectionOpen = oConnection
	
End Function	