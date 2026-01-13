<cfset contentType = "application/json">
<cfcontent type="#contentType#" reset="true">

<cfheader name="Access-Control-Allow-Origin" value="*">

<cftry>
  <cfset datasourceName = "lessonplanner">
  
  <!--- Debug: Check what parameters we're receiving --->
  <cfset debugInfo = {
    "method" = cgi.REQUEST_METHOD,
    "pathInfo" = isDefined("cgi.PATH_INFO") ? cgi.PATH_INFO : "not defined",
    "scriptName" = cgi.SCRIPT_NAME,
    "queryString" = cgi.QUERY_STRING,
    "urlScope" = isDefined("url") ? url : {},
    "formScope" = isDefined("form") ? form : {}
  }>
  
  <!--- Check all lessons in database --->
  <cfquery name="qAllLessons" datasource="#datasourceName#">
    SELECT id, title FROM lessonPlans ORDER BY id
  </cfquery>
  
  <cfset allLessons = []>
  <cfloop query="qAllLessons">
    <cfset arrayAppend(allLessons, {"id" = qAllLessons.id, "title" = qAllLessons.title})>
  </cfloop>
  
  <cfset debugInfo.lessonsInDatabase = allLessons>
  
  <cfoutput>#serializeJSON(debugInfo)#</cfoutput>
  
  <cfcatch>
    <cfheader statuscode="500">
    <cfoutput>#serializeJSON({"error": cfcatch.message, "detail": cfcatch.detail})#</cfoutput>
  </cfcatch>
</cftry>
