<cfcomponent rest="true" restpath="groups">
  
  <!--- Get all student groups --->
  <cffunction name="getAllGroups" access="remote" returntype="any" httpmethod="GET" restpath="" produces="application/json">
    <cftry>
      <cfquery name="qGroups" datasource="#application.datasource#">
        SELECT id, name, description, averageAge, skillLevel
        FROM studentGroups
        ORDER BY name
      </cfquery>
      
      <cfset var groups = []>
      <cfloop query="qGroups">
        <cfset arrayAppend(groups, {
          "id" = qGroups.id,
          "name" = qGroups.name,
          "description" = qGroups.description,
          "averageAge" = qGroups.averageAge,
          "skillLevel" = qGroups.skillLevel,
          "studentIds" = []
        })>
      </cfloop>
      
      <cfreturn serializeJSON(groups)>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfreturn serializeJSON({"success": false, "error": cfcatch.message})>
      </cfcatch>
    </cftry>
  </cffunction>
  
  <!--- Create student group --->
  <cffunction name="createGroup" access="remote" returntype="any" httpmethod="POST" restpath="" produces="application/json">
    <cftry>
      <cfset var requestBody = deserializeJSON(toString(getHTTPRequestData().content))>
      
      <cfquery name="qInsert" datasource="#application.datasource#" result="insertResult">
        INSERT INTO studentGroups (name, description, averageAge, skillLevel)
        VALUES (
          <cfqueryparam value="#requestBody.name#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#requestBody.description#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#requestBody.averageAge#" cfsqltype="cf_sql_integer">,
          <cfqueryparam value="#requestBody.skillLevel#" cfsqltype="cf_sql_varchar">
        )
      </cfquery>
      
      <cfheader statuscode="201">
      <cfreturn serializeJSON({"success": true, "id": insertResult.IDENTITYCOL})>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfreturn serializeJSON({"success": false, "error": cfcatch.message})>
      </cfcatch>
    </cftry>
  </cffunction>
  
  <!--- Delete group --->
  <cffunction name="deleteGroup" access="remote" returntype="any" httpmethod="DELETE" restpath="{id}" produces="application/json">
    <cfargument name="id" type="numeric" restargsource="path" required="true">
    
    <cftry>
      <cfquery datasource="#application.datasource#">
        DELETE FROM studentGroups
        WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
      </cfquery>
      
      <cfreturn serializeJSON({"success": true})>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfreturn serializeJSON({"success": false, "error": cfcatch.message})>
      </cfcatch>
    </cftry>
  </cffunction>
  
</cfcomponent>
