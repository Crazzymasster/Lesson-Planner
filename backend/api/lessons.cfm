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
      <!--- Get single lesson by ID --->
      <cfset lessonId = url.id>
      
      <cfquery name="qLesson" datasource="#datasourceName#">
        SELECT *
        FROM lessonPlans
        WHERE id = <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">
      </cfquery>
      
      <cfif qLesson.recordCount eq 0>
        <cfheader statuscode="404">
        <cfoutput>#serializeJSON({"success": false, "error": "Lesson not found"})#</cfoutput>
        <cfabort>
      </cfif>
      
      <!--- Get related data --->
      <cfquery name="qTopics" datasource="#datasourceName#">
        SELECT topic FROM lessonTopics WHERE lessonId = <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">
      </cfquery>
      
      <cfquery name="qObjectives" datasource="#datasourceName#">
        SELECT objective FROM lessonObjectives WHERE lessonId = <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer"> ORDER BY orderIndex
      </cfquery>
      
      <cfquery name="qMaterials" datasource="#datasourceName#">
        SELECT material FROM lessonMaterials WHERE lessonId = <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">
      </cfquery>
      
      <cftry>
        <cfquery name="qSteps" datasource="#datasourceName#">
          SELECT * FROM lessonSteps WHERE lessonId = <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer"> ORDER BY stepNumber
        </cfquery>
        <cfcatch>
          <cfset qSteps = queryNew("")>
        </cfcatch>
      </cftry>
      
      <cftry>
        <cfquery name="qChallenges" datasource="#datasourceName#">
          SELECT * FROM lessonChallenges WHERE lessonId = <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer"> ORDER BY orderIndex
        </cfquery>
        <cfcatch>
          <cfset qChallenges = queryNew("")>
        </cfcatch>
      </cftry>
      
      <cftry>
        <cfquery name="qProject" datasource="#datasourceName#">
          SELECT * FROM lessonProjects WHERE lessonId = <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfcatch>
          <cfset qProject = queryNew("")>
        </cfcatch>
      </cftry>
      
      <!--- Build topics array --->
      <cfset topics = []>
      <cfloop query="qTopics">
        <cfset arrayAppend(topics, qTopics.topic)>
      </cfloop>
      
      <!--- Build objectives array --->
      <cfset objectives = []>
      <cfloop query="qObjectives">
        <cfset arrayAppend(objectives, qObjectives.objective)>
      </cfloop>
      
      <!--- Build materials array --->
      <cfset materials = []>
      <cfloop query="qMaterials">
        <cfset arrayAppend(materials, qMaterials.material)>
      </cfloop>
      
      <!--- Build steps array --->
      <cfset stepsArray = []>
      <cfif isDefined("qSteps") and qSteps.recordCount gt 0>
        <cfloop query="qSteps">
          <cfset stepItem = structNew()>
          <cfset stepItem["id"] = qSteps.id>
          <cfset stepItem["stepNumber"] = qSteps.stepNumber>
          <cfset stepItem["title"] = qSteps.title>
          <cfset stepItem["instruction"] = qSteps.instruction>
          <cfset stepItem["codeExample"] = structKeyExists(qSteps, "codeExample") ? qSteps.codeExample : "">
          <cfset stepItem["expectedOutput"] = structKeyExists(qSteps, "expectedOutput") ? qSteps.expectedOutput : "">
          <cfset stepItem["explanation"] = structKeyExists(qSteps, "explanation") ? qSteps.explanation : "">
          <cfset stepItem["hints"] = structKeyExists(qSteps, "hints") ? qSteps.hints : "">
          <cfset arrayAppend(stepsArray, stepItem)>
        </cfloop>
      </cfif>
      
      <!--- Build challenges array --->
      <cfset challengesArray = []>
      <cfif isDefined("qChallenges") and qChallenges.recordCount gt 0>
        <cfloop query="qChallenges">
          <cfset challengeItem = structNew()>
          <cfset challengeItem["id"] = qChallenges.id>
          <cfset challengeItem["order"] = qChallenges.orderIndex>
          <cfset challengeItem["title"] = qChallenges.title>
          <cfset challengeItem["description"] = qChallenges.description>
          <cfset challengeItem["starterCode"] = structKeyExists(qChallenges, "starterCode") ? qChallenges.starterCode : "">
          <cfset challengeItem["solution"] = structKeyExists(qChallenges, "solution") ? qChallenges.solution : "">
          <cfset challengeItem["difficulty"] = qChallenges.difficulty>
          <cfset challengeItem["points"] = qChallenges.points>
          <cfset arrayAppend(challengesArray, challengeItem)>
        </cfloop>
      </cfif>
      
      <!--- Build complete lesson object with lowercase keys --->
      <cfset lessonResult = structNew()>
      <cfset lessonResult["id"] = qLesson.id>
      <cfset lessonResult["title"] = qLesson.title>
      <cfset lessonResult["description"] = qLesson.description>
      <cfset lessonResult["language"] = structKeyExists(qLesson, "language") ? qLesson.language : "python">
      <cfset lessonResult["category"] = structKeyExists(qLesson, "category") ? qLesson.category : "">
      <cfset lessonResult["targetAge"] = qLesson.targetAge>
      <cfset lessonResult["duration"] = qLesson.duration>
      <cfset lessonResult["difficulty"] = qLesson.difficulty>
      <cfset lessonResult["points"] = structKeyExists(qLesson, "points") && isNumeric(qLesson.points) ? qLesson.points : 10>
      <cfset lessonResult["prerequisites"] = structKeyExists(qLesson, "prerequisites") ? qLesson.prerequisites : "">
      <cfset lessonResult["learningOutcomes"] = structKeyExists(qLesson, "learningOutcomes") ? qLesson.learningOutcomes : "">
      <cfset lessonResult["topics"] = topics>
      <cfset lessonResult["objectives"] = objectives>
      <cfset lessonResult["materials"] = materials>
      <cfset lessonResult["activities"] = []>
      <cfset lessonResult["steps"] = stepsArray>
      <cfset lessonResult["challenges"] = challengesArray>
      <cfset lessonResult["codeSnippets"] = []>
      <cfset lessonResult["notes"] = qLesson.notes>
      <cfset lessonResult["createdAt"] = dateFormat(qLesson.createdAt, "yyyy-mm-dd") & " " & timeFormat(qLesson.createdAt, "HH:mm:ss")>
      <cfset lessonResult["updatedAt"] = dateFormat(qLesson.updatedAt, "yyyy-mm-dd") & " " & timeFormat(qLesson.updatedAt, "HH:mm:ss")>
      
      <!--- Add project if it exists --->
      <cfif isDefined("qProject") and qProject.recordCount gt 0>
        <cfset projectData = structNew()>
        <cfset projectData["id"] = qProject.id>
        <cfset projectData["title"] = qProject.title>
        <cfset projectData["description"] = qProject.description>
        <cfset projectData["requirements"] = structKeyExists(qProject, "requirements") ? qProject.requirements : "">
        <cfset projectData["starterCode"] = structKeyExists(qProject, "starterCode") ? qProject.starterCode : "">
        <cfset projectData["solutionCode"] = structKeyExists(qProject, "solutionCode") ? qProject.solutionCode : "">
        <cfset projectData["extensionIdeas"] = structKeyExists(qProject, "extensionIdeas") ? qProject.extensionIdeas : "">
        <cfset lessonResult["project"] = projectData>
      </cfif>
      
      <cfoutput>#serializeJSON(lessonResult, false, false)#</cfoutput>
      
    <cfelse>
      <!--- Get all lessons --->
      <cfquery name="qLessons" datasource="#datasourceName#">
        SELECT 
          id,
          title,
          description,
          language,
          category,
          targetAge,
          duration,
          difficulty,
          points,
          notes,
          folderId,
          createdAt,
          updatedAt
        FROM lessonPlans
        ORDER BY createdAt DESC
      </cfquery>
      
      <cfset lessons = []>
      <cfloop query="qLessons">
        <cfset lesson = {
          "id" = qLessons.id,
          "title" = qLessons.title,
          "description" = qLessons.description,
          "language" = structKeyExists(qLessons, "language") ? qLessons.language : "python",
          "category" = structKeyExists(qLessons, "category") ? qLessons.category : "",
          "targetAge" = qLessons.targetAge,
          "duration" = qLessons.duration,
          "difficulty" = qLessons.difficulty,
          "points" = structKeyExists(qLessons, "points") && isNumeric(qLessons.points) ? qLessons.points : 10,
          "folderId" = structKeyExists(qLessons, "folderId") && isNumeric(qLessons.folderId) ? qLessons.folderId : javaCast("null", ""),
          "notes" = qLessons.notes,
          "createdAt" = dateFormat(qLessons.createdAt, "yyyy-mm-dd") & " " & timeFormat(qLessons.createdAt, "HH:mm:ss"),
          "updatedAt" = dateFormat(qLessons.updatedAt, "yyyy-mm-dd") & " " & timeFormat(qLessons.updatedAt, "HH:mm:ss")
        }>
        <cfset arrayAppend(lessons, lesson)>
      </cfloop>
      
      <cfoutput>#serializeJSON(lessons, false, false)#</cfoutput>
    </cfif>
    
  <cfelseif cgi.REQUEST_METHOD eq "POST">
    <!--- Create new lesson --->
    <cfset requestBody = toString(getHttpRequestData().content)>
    <cfset lessonData = deserializeJSON(requestBody)>
    
    <!--- Validate required fields --->
    <cfif not structKeyExists(lessonData, "title") or lessonData.title eq "">
      <cfheader statuscode="400">
      <cfoutput>#serializeJSON({"success": false, "error": "Title is required"})#</cfoutput>
      <cfabort>
    </cfif>
    
    <cfif not structKeyExists(lessonData, "description") or lessonData.description eq "">
      <cfheader statuscode="400">
      <cfoutput>#serializeJSON({"success": false, "error": "Description is required"})#</cfoutput>
      <cfabort>
    </cfif>
    
    <cfif not structKeyExists(lessonData, "language") or lessonData.language eq "">
      <cfheader statuscode="400">
      <cfoutput>#serializeJSON({"success": false, "error": "Programming language is required"})#</cfoutput>
      <cfabort>
    </cfif>
    
    <!--- Insert main lesson plan --->
    <cfquery name="qInsert" datasource="#datasourceName#" result="insertResult">
      INSERT INTO lessonPlans (
        title, description, language, category, targetAge, duration, difficulty, points,
        prerequisites, learningOutcomes, notes, createdAt, updatedAt
      ) VALUES (
        <cfqueryparam value="#lessonData.title#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#lessonData.description#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#lessonData.language#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#structKeyExists(lessonData, 'category') ? lessonData.category : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(lessonData, 'category') or lessonData.category eq ''#">,
        <cfqueryparam value="#structKeyExists(lessonData, 'targetAge') ? lessonData.targetAge : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(lessonData, 'targetAge') or lessonData.targetAge eq ''#">,
        <cfqueryparam value="#structKeyExists(lessonData, 'duration') ? lessonData.duration : 60#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#structKeyExists(lessonData, 'difficulty') ? lessonData.difficulty : 'Beginner'#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#structKeyExists(lessonData, 'points') ? lessonData.points : 10#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#structKeyExists(lessonData, 'prerequisites') ? lessonData.prerequisites : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(lessonData, 'prerequisites') or lessonData.prerequisites eq ''#">,
        <cfqueryparam value="#structKeyExists(lessonData, 'learningOutcomes') ? lessonData.learningOutcomes : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(lessonData, 'learningOutcomes') or lessonData.learningOutcomes eq ''#">,
        <cfqueryparam value="#structKeyExists(lessonData, 'notes') ? lessonData.notes : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(lessonData, 'notes') or lessonData.notes eq ''#">,
        GETDATE(),
        GETDATE()
      )
    </cfquery>
    
    <cfset newId = insertResult.IDENTITYCOL>
    
    <!--- Insert topics --->
    <cfif structKeyExists(lessonData, "topics") and isArray(lessonData.topics)>
      <cfloop array="#lessonData.topics#" index="topic">
        <cfif len(trim(topic))>
          <cfquery datasource="#datasourceName#">
            INSERT INTO lessonTopics (lessonId, topic)
            VALUES (
              <cfqueryparam value="#newId#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#topic#" cfsqltype="cf_sql_varchar">
            )
          </cfquery>
        </cfif>
      </cfloop>
    </cfif>
    
    <!--- Insert objectives --->
    <cfif structKeyExists(lessonData, "objectives") and isArray(lessonData.objectives)>
      <cfloop array="#lessonData.objectives#" index="objective">
        <cfif len(trim(objective))>
          <cfquery datasource="#datasourceName#">
            INSERT INTO lessonObjectives (lessonId, objective, orderIndex)
            VALUES (
              <cfqueryparam value="#newId#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#objective#" cfsqltype="cf_sql_varchar">,
              <cfqueryparam value="#arrayFind(lessonData.objectives, objective)#" cfsqltype="cf_sql_integer">
            )
          </cfquery>
        </cfif>
      </cfloop>
    </cfif>
    
    <!--- Insert materials --->
    <cfif structKeyExists(lessonData, "materials") and isArray(lessonData.materials)>
      <cfloop array="#lessonData.materials#" index="material">
        <cfif len(trim(material))>
          <cfquery datasource="#datasourceName#">
            INSERT INTO lessonMaterials (lessonId, material)
            VALUES (
              <cfqueryparam value="#newId#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#material#" cfsqltype="cf_sql_varchar">
            )
          </cfquery>
        </cfif>
      </cfloop>
    </cfif>
    
    <!--- Insert steps --->
    <cfif structKeyExists(lessonData, "steps") and isArray(lessonData.steps)>
      <cfloop array="#lessonData.steps#" index="step">
        <cfif structKeyExists(step, "title") and len(trim(step.title))>
          <cfquery datasource="#datasourceName#">
            INSERT INTO lessonSteps (lessonId, stepNumber, title, instruction, codeExample, expectedOutput, explanation, hints)
            VALUES (
              <cfqueryparam value="#newId#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#structKeyExists(step, 'stepNumber') ? step.stepNumber : arrayFind(lessonData.steps, step)#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#step.title#" cfsqltype="cf_sql_varchar">,
              <cfqueryparam value="#structKeyExists(step, 'instruction') ? step.instruction : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(step, 'instruction') or step.instruction eq ''#">,
              <cfqueryparam value="#structKeyExists(step, 'codeExample') ? step.codeExample : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(step, 'codeExample') or step.codeExample eq ''#">,
              <cfqueryparam value="#structKeyExists(step, 'expectedOutput') ? step.expectedOutput : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(step, 'expectedOutput') or step.expectedOutput eq ''#">,
              <cfqueryparam value="#structKeyExists(step, 'explanation') ? step.explanation : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(step, 'explanation') or step.explanation eq ''#">,
              <cfqueryparam value="#structKeyExists(step, 'hints') ? step.hints : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(step, 'hints') or step.hints eq ''#">
            )
          </cfquery>
        </cfif>
      </cfloop>
    </cfif>
    
    <!--- Insert challenges with weighted point distribution --->
    <cfif structKeyExists(lessonData, "challenges") and isArray(lessonData.challenges) and arrayLen(lessonData.challenges) gt 0>
      <!--- Calculate total weight based on difficulty --->
      <cfset totalWeight = 0>
      <cfset lessonPoints = structKeyExists(lessonData, 'points') ? lessonData.points : 10>
      
      <cfloop array="#lessonData.challenges#" index="challenge">
        <cfset difficulty = structKeyExists(challenge, 'difficulty') ? challenge.difficulty : 'Easy'>
        <cfif difficulty eq 'Hard'>
          <cfset totalWeight = totalWeight + 2>
        <cfelseif difficulty eq 'Medium'>
          <cfset totalWeight = totalWeight + 1.5>
        <cfelse>
          <cfset totalWeight = totalWeight + 1>
        </cfif>
      </cfloop>
      
      <!--- Insert challenges with proportional points --->
      <cfloop array="#lessonData.challenges#" index="challenge">
        <cfif structKeyExists(challenge, "title") and len(trim(challenge.title))>
          <!--- Calculate points based on difficulty weight --->
          <cfset difficulty = structKeyExists(challenge, 'difficulty') ? challenge.difficulty : 'Easy'>
          <cfset weight = 1>
          <cfif difficulty eq 'Hard'>
            <cfset weight = 2>
          <cfelseif difficulty eq 'Medium'>
            <cfset weight = 1.5>
          </cfif>
          <cfset challengePoints = round((lessonPoints * weight) / totalWeight)>
          
          <cfquery datasource="#datasourceName#">
            INSERT INTO lessonChallenges (lessonId, orderIndex, title, description, starterCode, solution, difficulty, points)
            VALUES (
              <cfqueryparam value="#newId#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#structKeyExists(challenge, 'order') ? challenge.order : arrayFind(lessonData.challenges, challenge)#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#challenge.title#" cfsqltype="cf_sql_varchar">,
              <cfqueryparam value="#structKeyExists(challenge, 'description') ? challenge.description : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(challenge, 'description') or challenge.description eq ''#">,
              <cfqueryparam value="#structKeyExists(challenge, 'starterCode') ? challenge.starterCode : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(challenge, 'starterCode') or challenge.starterCode eq ''#">,
              <cfqueryparam value="#structKeyExists(challenge, 'solution') ? challenge.solution : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(challenge, 'solution') or challenge.solution eq ''#">,
              <cfqueryparam value="#difficulty#" cfsqltype="cf_sql_varchar">,
              <cfqueryparam value="#challengePoints#" cfsqltype="cf_sql_integer">
            )
          </cfquery>
        </cfif>
      </cfloop>
    </cfif>
    
    <cfheader statuscode="201">
    <cfoutput>#serializeJSON({"success": true, "id": newId})#</cfoutput>
    
  <cfelseif cgi.REQUEST_METHOD eq "PUT">
    <!--- Update existing lesson --->
    <cfif isDefined("url.id") and isNumeric(url.id)>
      <cfset lessonId = url.id>
      <cfset requestBody = toString(getHttpRequestData().content)>
      <cfset lessonData = deserializeJSON(requestBody)>
      
      <!--- Check if this is a partial update (like just folderId) or full update --->
      <cfset isPartialUpdate = not (structKeyExists(lessonData, "title") and structKeyExists(lessonData, "description") and structKeyExists(lessonData, "language"))>
      
      <cfif isPartialUpdate>
        <!--- Partial update - only update the fields provided --->
        <cfquery datasource="#datasourceName#">
          UPDATE lessonPlans
          SET 
            <cfif structKeyExists(lessonData, "title")>
              title = <cfqueryparam value="#lessonData.title#" cfsqltype="cf_sql_varchar">,
            </cfif>
            <cfif structKeyExists(lessonData, "description")>
              description = <cfqueryparam value="#lessonData.description#" cfsqltype="cf_sql_varchar">,
            </cfif>
            <cfif structKeyExists(lessonData, "language")>
              language = <cfqueryparam value="#lessonData.language#" cfsqltype="cf_sql_varchar">,
            </cfif>
            <cfif structKeyExists(lessonData, "category")>
              category = <cfqueryparam value="#lessonData.category#" cfsqltype="cf_sql_varchar" null="#lessonData.category eq ''#">,
            </cfif>
            <cfif structKeyExists(lessonData, "targetAge")>
              targetAge = <cfqueryparam value="#lessonData.targetAge#" cfsqltype="cf_sql_varchar" null="#lessonData.targetAge eq ''#">,
            </cfif>
            <cfif structKeyExists(lessonData, "duration")>
              duration = <cfqueryparam value="#lessonData.duration#" cfsqltype="cf_sql_integer">,
            </cfif>
            <cfif structKeyExists(lessonData, "difficulty")>
              difficulty = <cfqueryparam value="#lessonData.difficulty#" cfsqltype="cf_sql_varchar">,
            </cfif>
            <cfif structKeyExists(lessonData, "folderId")>
              folderId = <cfqueryparam value="#lessonData.folderId#" cfsqltype="cf_sql_integer" null="#isNull(lessonData.folderId) or not isNumeric(lessonData.folderId)#">,
            </cfif>
            <cfif structKeyExists(lessonData, "prerequisites")>
              prerequisites = <cfqueryparam value="#lessonData.prerequisites#" cfsqltype="cf_sql_varchar" null="#lessonData.prerequisites eq ''#">,
            </cfif>
            <cfif structKeyExists(lessonData, "learningOutcomes")>
              learningOutcomes = <cfqueryparam value="#lessonData.learningOutcomes#" cfsqltype="cf_sql_varchar" null="#lessonData.learningOutcomes eq ''#">,
            </cfif>
            <cfif structKeyExists(lessonData, "notes")>
              notes = <cfqueryparam value="#lessonData.notes#" cfsqltype="cf_sql_varchar" null="#lessonData.notes eq ''#">,
            </cfif>
            updatedAt = GETDATE()
          WHERE id = <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">
        </cfquery>
      <cfelse>
        <!--- Full update - update all fields --->
        <cfquery datasource="#datasourceName#">
          UPDATE lessonPlans
          SET 
            title = <cfqueryparam value="#lessonData.title#" cfsqltype="cf_sql_varchar">,
            description = <cfqueryparam value="#lessonData.description#" cfsqltype="cf_sql_varchar">,
            language = <cfqueryparam value="#lessonData.language#" cfsqltype="cf_sql_varchar">,
            category = <cfqueryparam value="#structKeyExists(lessonData, 'category') ? lessonData.category : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(lessonData, 'category') or lessonData.category eq ''#">,
            targetAge = <cfqueryparam value="#structKeyExists(lessonData, 'targetAge') ? lessonData.targetAge : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(lessonData, 'targetAge') or lessonData.targetAge eq ''#">,
            duration = <cfqueryparam value="#structKeyExists(lessonData, 'duration') ? lessonData.duration : 60#" cfsqltype="cf_sql_integer">,
            difficulty = <cfqueryparam value="#structKeyExists(lessonData, 'difficulty') ? lessonData.difficulty : 'Beginner'#" cfsqltype="cf_sql_varchar">,
            folderId = <cfqueryparam value="#structKeyExists(lessonData, 'folderId') && isNumeric(lessonData.folderId) ? lessonData.folderId : javaCast('null', '')#" cfsqltype="cf_sql_integer" null="#not structKeyExists(lessonData, 'folderId') or not isNumeric(lessonData.folderId)#">,
            prerequisites = <cfqueryparam value="#structKeyExists(lessonData, 'prerequisites') ? lessonData.prerequisites : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(lessonData, 'prerequisites') or lessonData.prerequisites eq ''#">,
            learningOutcomes = <cfqueryparam value="#structKeyExists(lessonData, 'learningOutcomes') ? lessonData.learningOutcomes : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(lessonData, 'learningOutcomes') or lessonData.learningOutcomes eq ''#">,
            notes = <cfqueryparam value="#structKeyExists(lessonData, 'notes') ? lessonData.notes : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(lessonData, 'notes') or lessonData.notes eq ''#">,
            updatedAt = GETDATE()
          WHERE id = <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">
        </cfquery>
        
        <!--- Delete and re-insert related data for full updates --->
        <cfquery datasource="#datasourceName#">
          DELETE FROM lessonTopics WHERE lessonId = <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfquery datasource="#datasourceName#">
          DELETE FROM lessonObjectives WHERE lessonId = <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfquery datasource="#datasourceName#">
          DELETE FROM lessonMaterials WHERE lessonId = <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">
        </cfquery>
      </cfif>
      
      <!--- Re-insert topics, objectives, materials if provided --->
      <cfif structKeyExists(lessonData, "topics") and isArray(lessonData.topics)>
        <cfloop array="#lessonData.topics#" index="topic">
          <cfif len(trim(topic))>
            <cfquery datasource="#datasourceName#">
              INSERT INTO lessonTopics (lessonId, topic)
              VALUES (<cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">, <cfqueryparam value="#topic#" cfsqltype="cf_sql_varchar">)
            </cfquery>
          </cfif>
        </cfloop>
      </cfif>
      
      <cfif structKeyExists(lessonData, "objectives") and isArray(lessonData.objectives)>
        <cfloop array="#lessonData.objectives#" index="objective">
          <cfif len(trim(objective))>
            <cfquery datasource="#datasourceName#">
              INSERT INTO lessonObjectives (lessonId, objective, orderIndex)
              VALUES (<cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">, <cfqueryparam value="#objective#" cfsqltype="cf_sql_varchar">, <cfqueryparam value="#arrayFind(lessonData.objectives, objective)#" cfsqltype="cf_sql_integer">)
            </cfquery>
          </cfif>
        </cfloop>
      </cfif>
      
      <cfif structKeyExists(lessonData, "materials") and isArray(lessonData.materials)>
        <cfloop array="#lessonData.materials#" index="material">
          <cfif len(trim(material))>
            <cfquery datasource="#datasourceName#">
              INSERT INTO lessonMaterials (lessonId, material)
              VALUES (<cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">, <cfqueryparam value="#material#" cfsqltype="cf_sql_varchar">)
            </cfquery>
          </cfif>
        </cfloop>
      </cfif>
      
      <cfoutput>#serializeJSON({"success": true, "id": lessonId})#</cfoutput>
    <cfelse>
      <cfheader statuscode="400">
      <cfoutput>#serializeJSON({"success": false, "error": "Missing lesson ID"})#</cfoutput>
    </cfif>
    
  <cfelseif cgi.REQUEST_METHOD eq "DELETE">
    <!--- Delete lesson --->
    <cfif isDefined("url.id") and isNumeric(url.id)>
      <cfset lessonId = url.id>
      
      <cfquery datasource="#datasourceName#">
        DELETE FROM lessonPlans
        WHERE id = <cfqueryparam value="#lessonId#" cfsqltype="cf_sql_integer">
      </cfquery>
      
      <cfoutput>#serializeJSON({"success": true})#</cfoutput>
    <cfelse>
      <cfheader statuscode="400">
      <cfoutput>#serializeJSON({"success": false, "error": "Missing lesson ID"})#</cfoutput>
    </cfif>
    
  <cfelse>
    <cfheader statuscode="405">
    <cfoutput>#serializeJSON({"success": false, "error": "Method not allowed"})#</cfoutput>
  </cfif>
  
  <cfcatch>
    <cfheader statuscode="500">
    <cfoutput>#serializeJSON({"success": false, "error": cfcatch.message, "detail": cfcatch.detail})#</cfoutput>
  </cfcatch>
</cftry>
