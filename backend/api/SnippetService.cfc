<cfcomponent rest="true" restpath="snippets">
  
  <!--- Get all code snippets --->
  <cffunction name="getAllSnippets" access="remote" returntype="any" httpmethod="GET" restpath="" produces="application/json">
    <cftry>
      <cfquery name="qSnippets" datasource="#application.datasource#">
        SELECT id, title, language, code, explanation, difficulty
        FROM codeSnippets
        ORDER BY title
      </cfquery>
      
      <cfset var snippets = []>
      <cfloop query="qSnippets">
        <cfset arrayAppend(snippets, {
          "id" = qSnippets.id,
          "title" = qSnippets.title,
          "language" = qSnippets.language,
          "code" = qSnippets.code,
          "explanation" = qSnippets.explanation,
          "difficulty" = qSnippets.difficulty
        })>
      </cfloop>
      
      <cfreturn serializeJSON(snippets)>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfreturn serializeJSON({"success": false, "error": cfcatch.message})>
      </cfcatch>
    </cftry>
  </cffunction>
  
  <!--- Create code snippet --->
  <cffunction name="createSnippet" access="remote" returntype="any" httpmethod="POST" restpath="" produces="application/json">
    <cftry>
      <cfset var requestBody = deserializeJSON(toString(getHTTPRequestData().content))>
      
      <cfquery name="qInsert" datasource="#application.datasource#" result="insertResult">
        INSERT INTO codeSnippets (title, language, code, explanation, difficulty)
        VALUES (
          <cfqueryparam value="#requestBody.title#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#requestBody.language#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#requestBody.code#" cfsqltype="cf_sql_longvarchar">,
          <cfqueryparam value="#requestBody.explanation#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#requestBody.difficulty#" cfsqltype="cf_sql_varchar">
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
  
  <!--- Delete snippet --->
  <cffunction name="deleteSnippet" access="remote" returntype="any" httpmethod="DELETE" restpath="{id}" produces="application/json">
    <cfargument name="id" type="numeric" restargsource="path" required="true">
    
    <cftry>
      <cfquery datasource="#application.datasource#">
        DELETE FROM codeSnippets
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
