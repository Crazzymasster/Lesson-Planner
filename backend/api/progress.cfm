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
  
  <!--- POST - Mark a lesson as complete for a student and award points --->
  <cfif cgi.REQUEST_METHOD eq "POST">
    <cfset requestBody = deserializeJSON(toString(getHTTPRequestData().content))>
    
    <!--- Validate required fields --->
    <cfif NOT structKeyExists(requestBody, "studentId") OR NOT structKeyExists(requestBody, "lessonId")>
      <cfheader statuscode="400">
      <cfoutput>#serializeJSON({"success": false, "error": "studentId and lessonId are required"})#</cfoutput>
      <cfabort>
    </cfif>
    
    <cfset studentId = requestBody.studentId>
    <cfset lessonId = requestBody.lessonId>
    
    <!--- Get the lesson points and language --->
    <cfquery name="qLesson" datasource="#datasourceName#">
      SELECT points, language
      FROM lessonPlans
      WHERE id = <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfif qLesson.recordCount eq 0>
      <cfheader statuscode="404">
      <cfoutput>#serializeJSON({"success": false, "error": "Lesson not found"})#</cfoutput>
      <cfabort>
    </cfif>
    
    <cfset pointsToAward = qLesson.points>
    <cfset lessonLanguage = qLesson.language>
    
    <!--- Check if progress already exists --->
    <cfquery name="qExisting" datasource="#datasourceName#">
      SELECT id, status
      FROM studentProgress
      WHERE studentId = <cfqueryparam value="#studentId#" cfsqltype="cf_sql_integer">
        AND lessonId = <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfif qExisting.recordCount gt 0>
      <!--- Update existing progress --->
      <cfquery datasource="#datasourceName#">
        UPDATE studentProgress
        SET status = 'Completed',
            completedAt = GETDATE(),
            pointsEarned = <cfqueryparam value="#pointsToAward#" cfsqltype="cf_sql_integer">
        WHERE id = <cfqueryparam value="#qExisting.id#" cfsqltype="cf_sql_integer">
      </cfquery>
    <cfelse>
      <!--- Insert new progress record --->
      <cfquery datasource="#datasourceName#">
        INSERT INTO studentProgress (studentId, lessonId, status, completedAt, pointsEarned)
        VALUES (
          <cfqueryparam value="#studentId#" cfsqltype="cf_sql_integer">,
          <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">,
          'Completed',
          GETDATE(),
          <cfqueryparam value="#pointsToAward#" cfsqltype="cf_sql_integer">
        )
      </cfquery>
    </cfif>
    
    <!--- Update lastPracticedAt for this language --->
    <cfquery datasource="#datasourceName#">
      UPDATE studentLanguages
      SET lastPracticedAt = GETDATE()
      WHERE studentId = <cfqueryparam value="#studentId#" cfsqltype="cf_sql_integer">
        AND language = <cfqueryparam value="#lessonLanguage#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <!--- Calculate total points for this language and update proficiency --->
    <cfquery name="qLanguagePoints" datasource="#datasourceName#">
      SELECT COALESCE(SUM(sp.pointsEarned), 0) as totalPoints
      FROM studentProgress sp
      INNER JOIN lessonPlans lp ON sp.lessonId = lp.id
      WHERE sp.studentId = <cfqueryparam value="#studentId#" cfsqltype="cf_sql_integer">
        AND lp.language = <cfqueryparam value="#lessonLanguage#" cfsqltype="cf_sql_varchar">
        AND sp.status IN ('Completed', 'Mastered')
    </cfquery>
    
    <cfset totalLanguagePoints = qLanguagePoints.totalPoints>
    
    <!--- Determine proficiency level based on points --->
    <!--- Beginner: 0-50 points, Intermediate: 51-150 points, Advanced: 151-300 points, Expert: 301+ points --->
    <cfif totalLanguagePoints GTE 301>
      <cfset newProficiency = "Expert">
    <cfelseif totalLanguagePoints GTE 151>
      <cfset newProficiency = "Advanced">
    <cfelseif totalLanguagePoints GTE 51>
      <cfset newProficiency = "Intermediate">
    <cfelse>
      <cfset newProficiency = "Beginner">
    </cfif>
    
    <!--- Update proficiency level --->
    <cfquery datasource="#datasourceName#">
      UPDATE studentLanguages
      SET proficiencyLevel = <cfqueryparam value="#newProficiency#" cfsqltype="cf_sql_varchar">
      WHERE studentId = <cfqueryparam value="#studentId#" cfsqltype="cf_sql_integer">
        AND language = <cfqueryparam value="#lessonLanguage#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <!--- Return success with points awarded and new proficiency --->
    <cfheader statuscode="200">
    <cfoutput>#serializeJSON({
      "success": true, 
      "pointsAwarded": pointsToAward,
      "totalLanguagePoints": totalLanguagePoints,
      "newProficiency": newProficiency,
      "message": "Lesson marked as completed! +#pointsToAward# points. #lessonLanguage# proficiency: #newProficiency# (#totalLanguagePoints# pts)"
    })#</cfoutput>
  
  <!--- DELETE - Remove lesson completion (undo) --->
  <cfelseif cgi.REQUEST_METHOD eq "DELETE">
    <cfif NOT structKeyExists(url, "studentId") OR NOT structKeyExists(url, "lessonId")>
      <cfheader statuscode="400">
      <cfoutput>#serializeJSON({"success": false, "error": "studentId and lessonId are required"})#</cfoutput>
      <cfabort>
    </cfif>
    
    <cfquery datasource="#datasourceName#">
      DELETE FROM studentProgress
      WHERE studentId = <cfqueryparam value="#url.studentId#" cfsqltype="cf_sql_integer">
        AND lessonId = <cfqueryparam value="#url.lessonId#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfheader statuscode="200">
    <cfoutput>#serializeJSON({"success": true, "message": "Lesson progress removed"})#</cfoutput>
  
  </cfif>
  
  <cfcatch>
    <cfheader statuscode="500">
    <cfoutput>#serializeJSON({"success": false, "error": cfcatch.message})#</cfoutput>
  </cfcatch>
</cftry>
