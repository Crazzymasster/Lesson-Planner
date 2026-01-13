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
  
  <!--- GET requests fetch student data, either one student or all of them --->
  <cfif cgi.REQUEST_METHOD eq "GET">
    <cftry>
      <!--- If there's an ID in the URL, we're looking for one specific student --->
      <cfif structKeyExists(url, "id")>
        <!--- First grab the basic student info --->
        <cfquery name="qStudent" datasource="#datasourceName#">
          SELECT id, name, age, skillLevel, groupId, email, parentEmail, notes, isActive, createdAt, updatedAt
          FROM students
          WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <cfif qStudent.recordCount eq 0>
          <cfheader statuscode="404">
          <cfoutput>#serializeJSON({"success": false, "error": "Student not found"}, false, false)#</cfoutput>
          <cfabort>
        </cfif>
        
        <!--- Now get all the languages this student is learning --->
        <cfquery name="qLanguages" datasource="#datasourceName#">
          SELECT id, language, proficiencyLevel, startedAt, lastPracticedAt, notes
          FROM studentLanguages
          WHERE studentId = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
          ORDER BY language
        </cfquery>
        
        <!--- Pull in their lesson history with all the lesson details --->
        <cftry>
          <cfquery name="qProgress" datasource="#datasourceName#">
            SELECT 
              sp.id,
              sp.lessonId,
              sp.status,
              sp.completedAt,
              sp.score,
              sp.pointsEarned,
              sp.timeSpentMinutes,
              sp.notes,
              lp.title as lessonTitle,
              lp.language as lessonLanguage,
              lp.difficulty as lessonDifficulty
            FROM studentProgress sp
            INNER JOIN lessonPlans lp ON sp.lessonId = lp.id
            WHERE sp.studentId = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
            ORDER BY sp.completedAt DESC
          </cfquery>
          <cfcatch>
            <!--- Fallback if pointsEarned column doesn't exist yet --->
            <cfquery name="qProgress" datasource="#datasourceName#">
              SELECT 
                sp.id,
                sp.lessonId,
                sp.status,
                sp.completedAt,
                sp.score,
                sp.timeSpentMinutes,
                sp.notes,
                lp.title as lessonTitle,
                lp.language as lessonLanguage,
                lp.difficulty as lessonDifficulty
              FROM studentProgress sp
              INNER JOIN lessonPlans lp ON sp.lessonId = lp.id
              WHERE sp.studentId = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
              ORDER BY sp.completedAt DESC
            </cfquery>
          </cfcatch>
        </cftry>
        
        <!--- Turn the languages query into a nice array for JSON --->
        <cfset languagesArray = []>
        <cfif isDefined("qLanguages") and qLanguages.recordCount gt 0>
          <cfloop query="qLanguages">
            <cfset langItem = structNew()>
            <cfset langItem["id"] = qLanguages.id>
            <cfset langItem["language"] = qLanguages.language>
            <cfset langItem["proficiencyLevel"] = qLanguages.proficiencyLevel>
            <cfset langItem["startedAt"] = dateFormat(qLanguages.startedAt, "yyyy-mm-dd") & " " & timeFormat(qLanguages.startedAt, "HH:mm:ss")>
            <cfset langItem["lastPracticedAt"] = dateFormat(qLanguages.lastPracticedAt, "yyyy-mm-dd") & " " & timeFormat(qLanguages.lastPracticedAt, "HH:mm:ss")>
            <cfset langItem["notes"] = structKeyExists(qLanguages, "notes") && len(qLanguages.notes) ? qLanguages.notes : "">
            <cfset arrayAppend(languagesArray, langItem)>
          </cfloop>
        </cfif>
        
        <!--- Do the same for lesson progress --->
        <cfset progressArray = []>
        <cfif isDefined("qProgress") and qProgress.recordCount gt 0>
          <cfloop query="qProgress">
            <cfset progressItem = structNew()>
            <cfset progressItem["id"] = qProgress.id>
            <cfset progressItem["lessonId"] = qProgress.lessonId>
            <cfset progressItem["lessonTitle"] = qProgress.lessonTitle>
            <cfset progressItem["lessonLanguage"] = qProgress.lessonLanguage>
            <cfset progressItem["lessonDifficulty"] = qProgress.lessonDifficulty>
            <cfset progressItem["status"] = qProgress.status>
            <cfset progressItem["completedAt"] = dateFormat(qProgress.completedAt, "yyyy-mm-dd") & " " & timeFormat(qProgress.completedAt, "HH:mm:ss")>
            <cfset progressItem["score"] = structKeyExists(qProgress, "score") && isNumeric(qProgress.score) ? qProgress.score : 0>
            <cfset progressItem["pointsEarned"] = structKeyExists(qProgress, "pointsEarned") && isNumeric(qProgress.pointsEarned) ? qProgress.pointsEarned : 0>
            <cfset progressItem["timeSpentMinutes"] = structKeyExists(qProgress, "timeSpentMinutes") && isNumeric(qProgress.timeSpentMinutes) ? qProgress.timeSpentMinutes : 0>
            <cfset progressItem["notes"] = structKeyExists(qProgress, "notes") && len(qProgress.notes) ? qProgress.notes : "">
            <cfset arrayAppend(progressArray, progressItem)>
          </cfloop>
        </cfif>
        
        <!--- Calculate total points earned --->
        <cftry>
          <cfquery name="qTotalPoints" datasource="#datasourceName#">
            SELECT COALESCE(SUM(pointsEarned), 0) as totalPoints
            FROM studentProgress
            WHERE studentId = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
          </cfquery>
          <cfset totalPointsEarned = qTotalPoints.totalPoints>
          <cfcatch>
            <!--- Fallback if pointsEarned column doesn't exist yet --->
            <cfset totalPointsEarned = 0>
          </cfcatch>
        </cftry>
        
        <!--- Calculate lesson statistics --->
        <cfquery name="qLessonStats" datasource="#datasourceName#">
          SELECT 
            COUNT(*) as totalLessons,
            SUM(CASE WHEN status IN ('Completed', 'Mastered') THEN 1 ELSE 0 END) as completedLessons
          FROM studentProgress
          WHERE studentId = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <!--- Package everything into one student object --->
        <cfset studentResult = structNew()>
        <cfset studentResult["id"] = qStudent.id>
        <cfset studentResult["name"] = qStudent.name>
        <cfset studentResult["age"] = structKeyExists(qStudent, "age") && isNumeric(qStudent.age) ? qStudent.age : 0>
        <cfset studentResult["skillLevel"] = qStudent.skillLevel>
        <cfset studentResult["groupId"] = structKeyExists(qStudent, "groupId") && isNumeric(qStudent.groupId) ? qStudent.groupId : 0>
        <cfset studentResult["email"] = structKeyExists(qStudent, "email") && len(qStudent.email) ? qStudent.email : "">
        <cfset studentResult["parentEmail"] = structKeyExists(qStudent, "parentEmail") && len(qStudent.parentEmail) ? qStudent.parentEmail : "">
        <cfset studentResult["notes"] = structKeyExists(qStudent, "notes") && len(qStudent.notes) ? qStudent.notes : "">
        <cfset studentResult["isActive"] = structKeyExists(qStudent, "isActive") ? qStudent.isActive : true>
        <cfset studentResult["languages"] = languagesArray>
        <cfset studentResult["progress"] = progressArray>
        <cfset studentResult["totalPointsEarned"] = totalPointsEarned>
        <cfset studentResult["totalLessons"] = qLessonStats.recordCount gt 0 ? qLessonStats.totalLessons : 0>
        <cfset studentResult["completedLessons"] = qLessonStats.recordCount gt 0 ? qLessonStats.completedLessons : 0>
        <cfset studentResult["createdAt"] = dateFormat(qStudent.createdAt, "yyyy-mm-dd") & " " & timeFormat(qStudent.createdAt, "HH:mm:ss")>
        <cfset studentResult["updatedAt"] = dateFormat(qStudent.updatedAt, "yyyy-mm-dd") & " " & timeFormat(qStudent.updatedAt, "HH:mm:ss")>
        
        <cfoutput>#serializeJSON(studentResult, false, false)#</cfoutput>
        
      <cfelse>
        <!--- Get all students --->
        <cfquery name="qStudents" datasource="#datasourceName#">
          SELECT s.id, s.name, s.age, s.skillLevel, s.groupId, s.email, s.parentEmail, s.notes, s.isActive, s.createdAt, s.updatedAt,
                 sg.name as groupName
          FROM students s
          LEFT JOIN studentGroups sg ON s.groupId = sg.id
          WHERE s.isActive = 1
          ORDER BY s.name
        </cfquery>
        
        <!--- Count how many languages each student knows --->
        <cfquery name="qLanguageCounts" datasource="#datasourceName#">
          SELECT studentId, COUNT(*) as languageCount
          FROM studentLanguages
          GROUP BY studentId
        </cfquery>
        
        <!--- Count their lesson progress too --->
        <cfquery name="qLessonCounts" datasource="#datasourceName#">
          SELECT studentId, 
                 COUNT(*) as totalLessons,
                 SUM(CASE WHEN status IN ('Completed', 'Mastered') THEN 1 ELSE 0 END) as completedLessons
          FROM studentProgress
          GROUP BY studentId
        </cfquery>
        
        <!--- Build an array with all students and their stats --->
        <cfset studentsArray = []>
        <cfloop query="qStudents">
          <cfset studentItem = structNew()>
          <cfset studentItem["id"] = qStudents.id>
          <cfset studentItem["name"] = qStudents.name>
          <cfset studentItem["age"] = structKeyExists(qStudents, "age") && isNumeric(qStudents.age) ? qStudents.age : 0>
          <cfset studentItem["skillLevel"] = qStudents.skillLevel>
          <cfset studentItem["groupId"] = structKeyExists(qStudents, "groupId") && isNumeric(qStudents.groupId) ? qStudents.groupId : 0>
          <cfset studentItem["groupName"] = structKeyExists(qStudents, "groupName") && len(qStudents.groupName) ? qStudents.groupName : "">
          <cfset studentItem["email"] = structKeyExists(qStudents, "email") && len(qStudents.email) ? qStudents.email : "">
          <cfset studentItem["parentEmail"] = structKeyExists(qStudents, "parentEmail") && len(qStudents.parentEmail) ? qStudents.parentEmail : "">
          <cfset studentItem["notes"] = structKeyExists(qStudents, "notes") && len(qStudents.notes) ? qStudents.notes : "">
          <cfset studentItem["isActive"] = structKeyExists(qStudents, "isActive") ? qStudents.isActive : true>
          
          <!--- Look up how many languages they're learning --->
          <cfquery name="langCount" dbtype="query">
            SELECT languageCount FROM qLanguageCounts WHERE studentId = <cfqueryparam value="#qStudents.id#" cfsqltype="cf_sql_integer">
          </cfquery>
          <cfset studentItem["languageCount"] = langCount.recordCount gt 0 ? langCount.languageCount : 0>
          
          <!--- And their lesson progress --->
          <cfquery name="lessonCount" dbtype="query">
            SELECT totalLessons, completedLessons FROM qLessonCounts WHERE studentId = <cfqueryparam value="#qStudents.id#" cfsqltype="cf_sql_integer">
          </cfquery>
          <cfset studentItem["totalLessons"] = lessonCount.recordCount gt 0 ? lessonCount.totalLessons : 0>
          <cfset studentItem["completedLessons"] = lessonCount.recordCount gt 0 ? lessonCount.completedLessons : 0>
          
          <cfset arrayAppend(studentsArray, studentItem)>
        </cfloop>
        
        <cfoutput>#serializeJSON(studentsArray, false, false)#</cfoutput>
      </cfif>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfoutput>#serializeJSON({"success": false, "error": cfcatch.message, "detail": cfcatch.detail}, false, false)#</cfoutput>
      </cfcatch>
    </cftry>
    
  <!--- POST requests create a brand new student --->
  <cfelseif cgi.REQUEST_METHOD eq "POST">
    <cftry>
      <cfset requestBody = deserializeJSON(toString(getHTTPRequestData().content))>
      
      <!--- Create the student record in the database --->
      <cfquery name="qInsert" datasource="#datasourceName#" result="insertResult">
        INSERT INTO students (name, age, skillLevel, groupId, email, parentEmail, notes, isActive)
        VALUES (
          <cfqueryparam value="#requestBody.name#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#requestBody.age#" cfsqltype="cf_sql_integer" null="#!structKeyExists(requestBody, 'age') || !len(requestBody.age)#">,
          <cfqueryparam value="#requestBody.skillLevel#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#requestBody.groupId#" cfsqltype="cf_sql_integer" null="#!structKeyExists(requestBody, 'groupId') || !len(requestBody.groupId) || requestBody.groupId eq 0#">,
          <cfqueryparam value="#structKeyExists(requestBody, 'email') ? requestBody.email : ''#" cfsqltype="cf_sql_varchar" null="#!structKeyExists(requestBody, 'email') || !len(requestBody.email)#">,
          <cfqueryparam value="#structKeyExists(requestBody, 'parentEmail') ? requestBody.parentEmail : ''#" cfsqltype="cf_sql_varchar" null="#!structKeyExists(requestBody, 'parentEmail') || !len(requestBody.parentEmail)#">,
          <cfqueryparam value="#structKeyExists(requestBody, 'notes') ? requestBody.notes : ''#" cfsqltype="cf_sql_varchar" null="#!structKeyExists(requestBody, 'notes') || !len(requestBody.notes)#">,
          <cfqueryparam value="1" cfsqltype="cf_sql_bit">
        )
      </cfquery>
      
      <!--- Grab the ID that was just created --->
      <cfquery name="qGetId" datasource="#datasourceName#">
        SELECT MAX(id) as newId FROM students
      </cfquery>
      <cfset newStudentId = qGetId.newId>
      
      <!--- If they sent language data, add those too --->
      <cfif structKeyExists(requestBody, "languages") && isArray(requestBody.languages) && arrayLen(requestBody.languages) gt 0>
        <cfloop array="#requestBody.languages#" index="lang">
          <cfquery datasource="#datasourceName#">
            INSERT INTO studentLanguages (studentId, language, proficiencyLevel, notes)
            VALUES (
              <cfqueryparam value="#newStudentId#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#lang.language#" cfsqltype="cf_sql_varchar">,
              <cfqueryparam value="#lang.proficiencyLevel#" cfsqltype="cf_sql_varchar">,
              <cfqueryparam value="#structKeyExists(lang, 'notes') ? lang.notes : ''#" cfsqltype="cf_sql_varchar" null="#!structKeyExists(lang, 'notes') || !len(lang.notes)#">
            )
          </cfquery>
        </cfloop>
      </cfif>
      
      <cfheader statuscode="201">
      <cfoutput>#serializeJSON({"success": true, "id": newStudentId}, false, false)#</cfoutput>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfoutput>#serializeJSON({"success": false, "error": cfcatch.message, "detail": cfcatch.detail}, false, false)#</cfoutput>
      </cfcatch>
    </cftry>
    
  <!--- PUT requests update an existing student --->
  <cfelseif cgi.REQUEST_METHOD eq "PUT">
    <cftry>
      <cfif not structKeyExists(url, "id")>
        <cfheader statuscode="400">
        <cfoutput>#serializeJSON({"success": false, "error": "Student ID required"}, false, false)#</cfoutput>
        <cfabort>
      </cfif>
      
      <cfset requestBody = deserializeJSON(toString(getHTTPRequestData().content))>
      
      <!--- Update the student's basic info --->
      <cfquery datasource="#datasourceName#">
        UPDATE students
        SET 
          name = <cfqueryparam value="#requestBody.name#" cfsqltype="cf_sql_varchar">,
          age = <cfqueryparam value="#requestBody.age#" cfsqltype="cf_sql_integer" null="#!structKeyExists(requestBody, 'age') || !len(requestBody.age)#">,
          skillLevel = <cfqueryparam value="#requestBody.skillLevel#" cfsqltype="cf_sql_varchar">,
          groupId = <cfqueryparam value="#requestBody.groupId#" cfsqltype="cf_sql_integer" null="#!structKeyExists(requestBody, 'groupId') || !len(requestBody.groupId) || requestBody.groupId eq 0#">,
          email = <cfqueryparam value="#structKeyExists(requestBody, 'email') ? requestBody.email : ''#" cfsqltype="cf_sql_varchar" null="#!structKeyExists(requestBody, 'email') || !len(requestBody.email)#">,
          parentEmail = <cfqueryparam value="#structKeyExists(requestBody, 'parentEmail') ? requestBody.parentEmail : ''#" cfsqltype="cf_sql_varchar" null="#!structKeyExists(requestBody, 'parentEmail') || !len(requestBody.parentEmail)#">,
          notes = <cfqueryparam value="#structKeyExists(requestBody, 'notes') ? requestBody.notes : ''#" cfsqltype="cf_sql_varchar" null="#!structKeyExists(requestBody, 'notes') || !len(requestBody.notes)#">,
          updatedAt = GETDATE()
        WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
      </cfquery>
      
      <!--- If they're updating languages, replace all of them --->
      <cfif structKeyExists(requestBody, "languages") && isArray(requestBody.languages)>
        <!--- First clear out the old languages --->
        <cfquery datasource="#datasourceName#">
          DELETE FROM studentLanguages
          WHERE studentId = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <!--- Then add the new ones --->
        <cfloop array="#requestBody.languages#" index="lang">
          <cfquery datasource="#datasourceName#">
            INSERT INTO studentLanguages (studentId, language, proficiencyLevel, notes)
            VALUES (
              <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#lang.language#" cfsqltype="cf_sql_varchar">,
              <cfqueryparam value="#lang.proficiencyLevel#" cfsqltype="cf_sql_varchar">,
              <cfqueryparam value="#structKeyExists(lang, 'notes') ? lang.notes : ''#" cfsqltype="cf_sql_varchar" null="#!structKeyExists(lang, 'notes') || !len(lang.notes)#">
            )
          </cfquery>
        </cfloop>
      </cfif>
      
      <cfoutput>#serializeJSON({"success": true}, false, false)#</cfoutput>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfoutput>#serializeJSON({"success": false, "error": cfcatch.message, "detail": cfcatch.detail}, false, false)#</cfoutput>
      </cfcatch>
    </cftry>
    
  <!--- DELETE requests mark a student as inactive --->
  <cfelseif cgi.REQUEST_METHOD eq "DELETE">
    <cftry>
      <cfif not structKeyExists(url, "id")>
        <cfheader statuscode="400">
        <cfoutput>#serializeJSON({"success": false, "error": "Student ID required"}, false, false)#</cfoutput>
        <cfabort>
      </cfif>
      
      <!--- We don't actually delete, just mark them as inactive --->\n      <cfquery datasource="#datasourceName#">
        UPDATE students
        SET isActive = 0, updatedAt = GETDATE()
        WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
      </cfquery>
      
      <cfoutput>#serializeJSON({"success": true}, false, false)#</cfoutput>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfoutput>#serializeJSON({"success": false, "error": cfcatch.message, "detail": cfcatch.detail}, false, false)#</cfoutput>
      </cfcatch>
    </cftry>
  </cfif>

<cfcatch>
  <cfheader statuscode="500">
  <cfoutput>#serializeJSON({"success": false, "error": cfcatch.message, "detail": cfcatch.detail})#</cfoutput>
</cfcatch>
</cftry>

