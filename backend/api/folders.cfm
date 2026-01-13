<cfset contentType = "application/json">
<cfcontent type="#contentType#" reset="true">

<cfheader name="Access-Control-Allow-Origin" value="*">
<cfheader name="Access-Control-Allow-Methods" value="GET, POST, PUT, DELETE, OPTIONS">
<cfheader name="Access-Control-Allow-Headers" value="Content-Type, Authorization">

<cfif cgi.REQUEST_METHOD eq "OPTIONS">
  <cfabort>
</cfif>

<cftry>
  <cfset datasourceName = "lessonplanner">
  
  <cfif cgi.REQUEST_METHOD eq "GET">
    <!--- Check for ID parameter --->
    <cfif isDefined("url.id") and isNumeric(url.id)>
      <!--- Get single folder by ID --->
      <cfset folderId = url.id>
      
      <cfquery name="qFolder" datasource="#datasourceName#">
        SELECT *
        FROM lessonFolders
        WHERE id = <cfqueryparam value="#folderId#" cfsqltype="cf_sql_integer">
      </cfquery>
      
      <cfif qFolder.recordCount eq 0>
        <cfheader statuscode="404">
        <cfoutput>#serializeJSON({"success": false, "error": "Folder not found"})#</cfoutput>
        <cfabort>
      </cfif>
      
      <!--- Get lessons in this folder --->
      <cfquery name="qLessons" datasource="#datasourceName#">
        SELECT id, title, description, difficulty, language, duration
        FROM lessonPlans
        WHERE folderId = <cfqueryparam value="#folderId#" cfsqltype="cf_sql_integer">
        ORDER BY createdAt DESC
      </cfquery>
      
      <cfset lessons = []>
      <cfloop query="qLessons">
        <cfset arrayAppend(lessons, {
          "id" = qLessons.id,
          "title" = qLessons.title,
          "description" = qLessons.description,
          "difficulty" = qLessons.difficulty,
          "language" = qLessons.language,
          "duration" = qLessons.duration
        })>
      </cfloop>
      
      <cfset folderResult = {
        "id" = qFolder.id,
        "name" = qFolder.name,
        "description" = qFolder.description,
        "color" = qFolder.color,
        "orderIndex" = qFolder.orderIndex,
        "lessonCount" = arrayLen(lessons),
        "lessons" = lessons,
        "createdAt" = dateFormat(qFolder.createdAt, "yyyy-mm-dd") & " " & timeFormat(qFolder.createdAt, "HH:mm:ss"),
        "updatedAt" = dateFormat(qFolder.updatedAt, "yyyy-mm-dd") & " " & timeFormat(qFolder.updatedAt, "HH:mm:ss")
      }>
      
      <cfoutput>#serializeJSON(folderResult)#</cfoutput>
    <cfelse>
      <!--- Get all folders with lesson counts --->
      <cfquery name="qFolders" datasource="#datasourceName#">
        SELECT 
          f.id,
          f.name,
          f.description,
          f.color,
          f.orderIndex,
          f.createdAt,
          f.updatedAt,
          COUNT(lp.id) as lessonCount
        FROM lessonFolders f
        LEFT JOIN lessonPlans lp ON f.id = lp.folderId
        GROUP BY f.id, f.name, f.description, f.color, f.orderIndex, f.createdAt, f.updatedAt
        ORDER BY f.orderIndex, f.name
      </cfquery>
      
      <cfset folders = []>
      <cfloop query="qFolders">
        <cfset folder = {
          "id" = qFolders.id,
          "name" = qFolders.name,
          "description" = qFolders.description,
          "color" = qFolders.color,
          "orderIndex" = qFolders.orderIndex,
          "lessonCount" = qFolders.lessonCount,
          "createdAt" = dateFormat(qFolders.createdAt, "yyyy-mm-dd") & " " & timeFormat(qFolders.createdAt, "HH:mm:ss"),
          "updatedAt" = dateFormat(qFolders.updatedAt, "yyyy-mm-dd") & " " & timeFormat(qFolders.updatedAt, "HH:mm:ss")
        }>
        <cfset arrayAppend(folders, folder)>
      </cfloop>
      
      <cfoutput>#serializeJSON(folders)#</cfoutput>
    </cfif>
    
  <cfelseif cgi.REQUEST_METHOD eq "POST">
    <!--- Create new folder --->
    <cfset requestBody = toString(getHttpRequestData().content)>
    <cfset folderData = deserializeJSON(requestBody)>
    
    <!--- Validate required fields --->
    <cfif not structKeyExists(folderData, "name") or folderData.name eq "">
      <cfheader statuscode="400">
      <cfoutput>#serializeJSON({"success": false, "error": "Folder name is required"})#</cfoutput>
      <cfabort>
    </cfif>
    
    <cfquery datasource="#datasourceName#" result="insertResult">
      INSERT INTO lessonFolders (name, description, color, orderIndex)
      VALUES (
        <cfqueryparam value="#folderData.name#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#structKeyExists(folderData, 'description') ? folderData.description : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(folderData, 'description') or folderData.description eq ''#">,
        <cfqueryparam value="#structKeyExists(folderData, 'color') ? folderData.color : '##1A237E'#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#structKeyExists(folderData, 'orderIndex') ? folderData.orderIndex : 0#" cfsqltype="cf_sql_integer">
      )
    </cfquery>
    
    <cfset newId = insertResult.IDENTITYCOL>
    <cfheader statuscode="201">
    <cfoutput>#serializeJSON({"success": true, "id": newId})#</cfoutput>
    
  <cfelseif cgi.REQUEST_METHOD eq "PUT">
    <!--- Update folder --->
    <cfif not isDefined("url.id") or not isNumeric(url.id)>
      <cfheader statuscode="400">
      <cfoutput>#serializeJSON({"success": false, "error": "Folder ID is required"})#</cfoutput>
      <cfabort>
    </cfif>
    
    <cfset folderId = url.id>
    <cfset requestBody = toString(getHttpRequestData().content)>
    <cfset folderData = deserializeJSON(requestBody)>
    
    <cfquery datasource="#datasourceName#">
      UPDATE lessonFolders
      SET 
        name = <cfqueryparam value="#folderData.name#" cfsqltype="cf_sql_varchar">,
        description = <cfqueryparam value="#structKeyExists(folderData, 'description') ? folderData.description : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(folderData, 'description') or folderData.description eq ''#">,
        color = <cfqueryparam value="#structKeyExists(folderData, 'color') ? folderData.color : '##1A237E'#" cfsqltype="cf_sql_varchar">,
        orderIndex = <cfqueryparam value="#structKeyExists(folderData, 'orderIndex') ? folderData.orderIndex : 0#" cfsqltype="cf_sql_integer">,
        updatedAt = GETDATE()
      WHERE id = <cfqueryparam value="#folderId#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfoutput>#serializeJSON({"success": true})#</cfoutput>
    
  <cfelseif cgi.REQUEST_METHOD eq "DELETE">
    <!--- Delete folder --->
    <cfif not isDefined("url.id") or not isNumeric(url.id)>
      <cfheader statuscode="400">
      <cfoutput>#serializeJSON({"success": false, "error": "Folder ID is required"})#</cfoutput>
      <cfabort>
    </cfif>
    
    <cfset folderId = url.id>
    
    <!--- Set all lessons in this folder to NULL (uncategorized) --->
    <cfquery datasource="#datasourceName#">
      UPDATE lessonPlans
      SET folderId = NULL
      WHERE folderId = <cfqueryparam value="#folderId#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <!--- Delete the folder --->
    <cfquery datasource="#datasourceName#">
      DELETE FROM lessonFolders
      WHERE id = <cfqueryparam value="#folderId#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfoutput>#serializeJSON({"success": true})#</cfoutput>
    
  <cfelse>
    <cfheader statuscode="405">
    <cfoutput>#serializeJSON({"success": false, "error": "Method not allowed"})#</cfoutput>
  </cfif>
  
  <cfcatch>
    <cfheader statuscode="500">
    <cfoutput>#serializeJSON({"success": false, "error": cfcatch.message, "detail": cfcatch.detail})#</cfoutput>
  </cfcatch>
</cftry>
