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
  
  <!--- GET - Fetch snippets --->
  <cfif cgi.REQUEST_METHOD eq "GET">
    <!--- Single snippet by ID --->
    <cfif structKeyExists(url, "id")>
      <cfquery name="qSnippet" datasource="#datasourceName#">
        SELECT 
          id,
          title,
          language,
          code,
          explanation,
          difficulty,
          createdAt
        FROM codeSnippets
        WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
      </cfquery>
      
      <cfif qSnippet.recordCount eq 0>
        <cfheader statuscode="404">
        <cfoutput>#serializeJSON({"success": false, "error": "Snippet not found"})#</cfoutput>
        <cfabort>
      </cfif>
      
      <cfset snippet = {
        "id" = qSnippet.id,
        "title" = qSnippet.title,
        "language" = qSnippet.language,
        "code" = qSnippet.code,
        "explanation" = qSnippet.explanation,
        "difficulty" = qSnippet.difficulty,
        "createdAt" = dateFormat(qSnippet.createdAt, "yyyy-mm-dd") & " " & timeFormat(qSnippet.createdAt, "HH:mm:ss")
      }>
      
      <cfoutput>#serializeJSON(snippet, false, false)#</cfoutput>
      
    <!--- All snippets --->
    <cfelse>
      <cfquery name="qSnippets" datasource="#datasourceName#">
        SELECT 
          id,
          title,
          language,
          code,
          explanation,
          difficulty,
          createdAt
        FROM codeSnippets
        ORDER BY createdAt DESC
      </cfquery>
      
      <cfset snippets = []>
      <cfloop query="qSnippets">
        <cfset snippet = {
          "id" = qSnippets.id,
          "title" = qSnippets.title,
          "language" = qSnippets.language,
          "code" = qSnippets.code,
          "explanation" = qSnippets.explanation,
          "difficulty" = qSnippets.difficulty,
          "createdAt" = dateFormat(qSnippets.createdAt, "yyyy-mm-dd") & " " & timeFormat(qSnippets.createdAt, "HH:mm:ss")
        }>
        <cfset arrayAppend(snippets, snippet)>
      </cfloop>
      
      <cfoutput>#serializeJSON(snippets, false, false)#</cfoutput>
    </cfif>
    
  <!--- POST - Create new snippet --->
  <cfelseif cgi.REQUEST_METHOD eq "POST">
    <cfset requestBody = deserializeJSON(toString(getHTTPRequestData().content))>
    
    <cfquery name="qInsert" datasource="#datasourceName#" result="insertResult">
      INSERT INTO codeSnippets (title, language, code, explanation, difficulty)
      VALUES (
        <cfqueryparam value="#requestBody.title#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#requestBody.language#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#requestBody.code#" cfsqltype="cf_sql_longvarchar">,
        <cfqueryparam value="#requestBody.explanation#" cfsqltype="cf_sql_longvarchar" null="#NOT structKeyExists(requestBody, 'explanation') OR NOT len(requestBody.explanation)#">,
        <cfqueryparam value="#requestBody.difficulty#" cfsqltype="cf_sql_varchar">
      )
    </cfquery>
    
    <cfheader statuscode="201">
    <cfoutput>#serializeJSON({"success": true, "id": insertResult.IDENTITYCOL}, false, false)#</cfoutput>
    
  <!--- PUT - Update existing snippet --->
  <cfelseif cgi.REQUEST_METHOD eq "PUT">
    <cfif NOT structKeyExists(url, "id")>
      <cfheader statuscode="400">
      <cfoutput>#serializeJSON({"success": false, "error": "Snippet ID required"})#</cfoutput>
      <cfabort>
    </cfif>
    
    <cfset requestBody = deserializeJSON(toString(getHTTPRequestData().content))>
    
    <cfquery name="qUpdate" datasource="#datasourceName#">
      UPDATE codeSnippets
      SET 
        title = <cfqueryparam value="#requestBody.title#" cfsqltype="cf_sql_varchar">,
        language = <cfqueryparam value="#requestBody.language#" cfsqltype="cf_sql_varchar">,
        code = <cfqueryparam value="#requestBody.code#" cfsqltype="cf_sql_longvarchar">,
        explanation = <cfqueryparam value="#requestBody.explanation#" cfsqltype="cf_sql_longvarchar" null="#NOT structKeyExists(requestBody, 'explanation') OR NOT len(requestBody.explanation)#">,
        difficulty = <cfqueryparam value="#requestBody.difficulty#" cfsqltype="cf_sql_varchar">
      WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfoutput>#serializeJSON({"success": true}, false, false)#</cfoutput>
    
  <!--- DELETE - Delete snippet --->
  <cfelseif cgi.REQUEST_METHOD eq "DELETE">
    <cfif NOT structKeyExists(url, "id")>
      <cfheader statuscode="400">
      <cfoutput>#serializeJSON({"success": false, "error": "Snippet ID required"})#</cfoutput>
      <cfabort>
    </cfif>
    
    <cfquery name="qDelete" datasource="#datasourceName#">
      DELETE FROM codeSnippets
      WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfoutput>#serializeJSON({"success": true}, false, false)#</cfoutput>
    
  </cfif>
  
  <cfcatch>
    <cfheader statuscode="500">
    <cfoutput>#serializeJSON({"success": false, "error": cfcatch.message}, false, false)#</cfoutput>
  </cfcatch>
</cftry>
