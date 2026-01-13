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
  
  <!--- GET - Fetch all groups --->
  <cfif cgi.REQUEST_METHOD eq "GET">
    <cfquery name="qGroups" datasource="#datasourceName#">
      SELECT 
        id,
        name,
        description,
        averageAge,
        skillLevel,
        createdAt
      FROM studentGroups
      ORDER BY createdAt DESC
    </cfquery>
    
    <cfset groups = []>
    <cfloop query="qGroups">
      <cfset group = {
        "id" = qGroups.id,
        "name" = qGroups.name,
        "description" = qGroups.description,
        "averageAge" = qGroups.averageAge,
        "skillLevel" = qGroups.skillLevel,
        "studentIds" = [],
        "createdAt" = dateFormat(qGroups.createdAt, "yyyy-mm-dd") & " " & timeFormat(qGroups.createdAt, "HH:mm:ss")
      }>
      <cfset arrayAppend(groups, group)>
    </cfloop>
    
    <cfoutput>#serializeJSON(groups)#</cfoutput>
  
  <!--- POST - Create new group --->
  <cfelseif cgi.REQUEST_METHOD eq "POST">
    <cfset requestBody = deserializeJSON(toString(getHTTPRequestData().content))>
    
    <cfquery name="qInsert" datasource="#datasourceName#" result="insertResult">
      INSERT INTO studentGroups (name, description, averageAge, skillLevel)
      VALUES (
        <cfqueryparam value="#requestBody.name#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#requestBody.description#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#requestBody.averageAge#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#requestBody.skillLevel#" cfsqltype="cf_sql_varchar">
      )
    </cfquery>
    
    <cfheader statuscode="201">
    <cfoutput>#serializeJSON({"success": true, "id": insertResult.IDENTITYCOL})#</cfoutput>
  
  <!--- DELETE - Remove a group --->
  <cfelseif cgi.REQUEST_METHOD eq "DELETE">
    <cfset groupId = url.id>
    
    <cfquery datasource="#datasourceName#">
      DELETE FROM studentGroups
      WHERE id = <cfqueryparam value="#groupId#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfoutput>#serializeJSON({"success": true})#</cfoutput>
  
  </cfif>
  
  <cfcatch>
    <cfheader statuscode="500">
    <cfoutput>#serializeJSON({"success": false, "error": cfcatch.message})#</cfoutput>
  </cfcatch>
</cftry>
