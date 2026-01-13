<cfcomponent rest="true" restpath="lessons">
  
  <!--- Get all lesson plans --->
  <cffunction name="getAllLessons" access="remote" returntype="any" httpmethod="GET" restpath="" produces="application/json">
    <cftry>
      <cfquery name="qLessons" datasource="#application.datasource#">
        SELECT 
          l.id,
          l.title,
          l.description,
          l.targetAge,
          l.duration,
          l.difficulty,
          l.notes,
          l.createdAt,
          l.updatedAt
        FROM lessonPlans l
        ORDER BY l.createdAt DESC
      </cfquery>
      
      <cfset var lessons = []>
      <cfloop query="qLessons">
        <cfset var lesson = {
          "id" = qLessons.id,
          "title" = qLessons.title,
          "description" = qLessons.description,
          "language" = structKeyExists(qLessons, "language") ? qLessons.language : "",
          "category" = structKeyExists(qLessons, "category") ? qLessons.category : "",
          "targetAge" = qLessons.targetAge,
          "duration" = qLessons.duration,
          "difficulty" = qLessons.difficulty,
          "prerequisites" = structKeyExists(qLessons, "prerequisites") ? qLessons.prerequisites : "",
          "learningOutcomes" = structKeyExists(qLessons, "learningOutcomes") ? qLessons.learningOutcomes : "",
          "topics" = getTopicsForLesson(qLessons.id),
          "objectives" = getObjectivesForLesson(qLessons.id),
          "materials" = getMaterialsForLesson(qLessons.id),
          "activities" = getActivitiesForLesson(qLessons.id),
          "steps" = getStepsForLesson(qLessons.id),
          "challenges" = getChallengesForLesson(qLessons.id),
          "project" = getProjectForLesson(qLessons.id),
          "codeSnippets" = getSnippetsForLesson(qLessons.id),
          "notes" = qLessons.notes,
          "createdAt" = qLessons.createdAt,
          "updatedAt" = qLessons.updatedAt
        }>
        <cfset arrayAppend(lessons, lesson)>
      </cfloop>
      
      <cfreturn serializeJSON(lessons)>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfreturn serializeJSON({"success": false, "error": cfcatch.message})>
      </cfcatch>
    </cftry>
  </cffunction>
  
  <!--- Get lesson by ID --->
  <cffunction name="getLessonById" access="remote" returntype="any" httpmethod="GET" restpath="{id}" produces="application/json">
    <cfargument name="id" type="numeric" restargsource="path" required="true">
    
    <cftry>
      <cfquery name="qLesson" datasource="#application.datasource#">
        SELECT *
        FROM lessonPlans
        WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
      </cfquery>
      
      <cfif qLesson.recordCount eq 0>
        <cfheader statuscode="404">
        <cfreturn serializeJSON({"success": false, "error": "Lesson not found"})>
      </cfif>
      
      <cfset var lesson = {
        "id" = qLesson.id,
        "title" = qLesson.title,
        "description" = qLesson.description,
        "language" = structKeyExists(qLesson, "language") ? qLesson.language : "",
        "category" = structKeyExists(qLesson, "category") ? qLesson.category : "",
        "targetAge" = qLesson.targetAge,
        "duration" = qLesson.duration,
        "difficulty" = qLesson.difficulty,
        "prerequisites" = structKeyExists(qLesson, "prerequisites") ? qLesson.prerequisites : "",
        "learningOutcomes" = structKeyExists(qLesson, "learningOutcomes") ? qLesson.learningOutcomes : "",
        "topics" = getTopicsForLesson(qLesson.id),
        "objectives" = getObjectivesForLesson(qLesson.id),
        "materials" = getMaterialsForLesson(qLesson.id),
        "activities" = getActivitiesForLesson(qLesson.id),
        "steps" = getStepsForLesson(qLesson.id),
        "challenges" = getChallengesForLesson(qLesson.id),
        "project" = getProjectForLesson(qLesson.id),
        "codeSnippets" = getSnippetsForLesson(qLesson.id),
        "notes" = qLesson.notes,
        "createdAt" = qLesson.createdAt,
        "updatedAt" = qLesson.updatedAt
      }>
      
      <cfreturn serializeJSON(lesson)>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfreturn serializeJSON({"success": false, "error": cfcatch.message})>
      </cfcatch>
    </cftry>
  </cffunction>
  
  <!--- Create new lesson --->
  <cffunction name="createLesson" access="remote" returntype="any" httpmethod="POST" restpath="" produces="application/json">
    <cftry>
      <cfset var requestBody = deserializeJSON(toString(getHTTPRequestData().content))>
      
      <!--- Insert main lesson plan --->
      <cfquery name="qInsert" datasource="#application.datasource#" result="insertResult">
        INSERT INTO lessonPlans (
          title, description, language, category, targetAge, duration, difficulty, 
          prerequisites, learningOutcomes, notes, createdAt, updatedAt
        ) VALUES (
          <cfqueryparam value="#requestBody.title#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#requestBody.description#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#structKeyExists(requestBody, 'language') ? requestBody.language : 'python'#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#structKeyExists(requestBody, 'category') ? requestBody.category : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(requestBody, 'category') or requestBody.category eq ''#">,
          <cfqueryparam value="#structKeyExists(requestBody, 'targetAge') ? requestBody.targetAge : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(requestBody, 'targetAge') or requestBody.targetAge eq ''#">,
          <cfqueryparam value="#structKeyExists(requestBody, 'duration') ? requestBody.duration : 60#" cfsqltype="cf_sql_integer">,
          <cfqueryparam value="#structKeyExists(requestBody, 'difficulty') ? requestBody.difficulty : 'Beginner'#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#structKeyExists(requestBody, 'prerequisites') ? requestBody.prerequisites : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(requestBody, 'prerequisites') or requestBody.prerequisites eq ''#">,
          <cfqueryparam value="#structKeyExists(requestBody, 'learningOutcomes') ? requestBody.learningOutcomes : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(requestBody, 'learningOutcomes') or requestBody.learningOutcomes eq ''#">,
          <cfqueryparam value="#structKeyExists(requestBody, 'notes') ? requestBody.notes : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(requestBody, 'notes') or requestBody.notes eq ''#">,
          GETDATE(),
          GETDATE()
        )
      </cfquery>
      
      <cfset var newId = insertResult.IDENTITYCOL>
      
      <!--- Insert topics --->
      <cfif structKeyExists(requestBody, "topics") and isArray(requestBody.topics)>
        <cfloop array="#requestBody.topics#" index="topic">
          <cfif len(trim(topic))>
            <cfquery datasource="#application.datasource#">
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
      <cfif structKeyExists(requestBody, "objectives") and isArray(requestBody.objectives)>
        <cfloop array="#requestBody.objectives#" index="objective">
          <cfif len(trim(objective))>
            <cfquery datasource="#application.datasource#">
              INSERT INTO lessonObjectives (lessonId, objective, orderIndex)
              VALUES (
                <cfqueryparam value="#newId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#objective#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arrayFind(requestBody.objectives, objective)#" cfsqltype="cf_sql_integer">
              )
            </cfquery>
          </cfif>
        </cfloop>
      </cfif>
      
      <!--- Insert materials --->
      <cfif structKeyExists(requestBody, "materials") and isArray(requestBody.materials)>
        <cfloop array="#requestBody.materials#" index="material">
          <cfif len(trim(material))>
            <cfquery datasource="#application.datasource#">
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
      <cfif structKeyExists(requestBody, "steps") and isArray(requestBody.steps)>
        <cftry>
          <cfloop array="#requestBody.steps#" index="step">
            <cfif structKeyExists(step, "title") and len(trim(step.title))>
              <cfquery datasource="#application.datasource#">
                INSERT INTO lessonSteps (
                  lessonId, stepNumber, title, instruction, codeExample, 
                  expectedOutput, explanation, hints
                ) VALUES (
                  <cfqueryparam value="#newId#" cfsqltype="cf_sql_integer">,
                  <cfqueryparam value="#structKeyExists(step, 'stepNumber') ? step.stepNumber : arrayFind(requestBody.steps, step)#" cfsqltype="cf_sql_integer">,
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
          <cfcatch>
            <!--- Table might not exist yet, skip --->
          </cfcatch>
        </cftry>
      </cfif>
      
      <!--- Insert challenges --->
      <cfif structKeyExists(requestBody, "challenges") and isArray(requestBody.challenges)>
        <cftry>
          <cfloop array="#requestBody.challenges#" index="challenge">
            <cfif structKeyExists(challenge, "title") and len(trim(challenge.title))>
              <cfquery datasource="#application.datasource#">
                INSERT INTO lessonChallenges (
                  lessonId, orderIndex, title, description, starterCode, 
                  solution, difficulty, points
                ) VALUES (
                  <cfqueryparam value="#newId#" cfsqltype="cf_sql_integer">,
                  <cfqueryparam value="#structKeyExists(challenge, 'order') ? challenge.order : arrayFind(requestBody.challenges, challenge)#" cfsqltype="cf_sql_integer">,
                  <cfqueryparam value="#challenge.title#" cfsqltype="cf_sql_varchar">,
                  <cfqueryparam value="#structKeyExists(challenge, 'description') ? challenge.description : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(challenge, 'description') or challenge.description eq ''#">,
                  <cfqueryparam value="#structKeyExists(challenge, 'starterCode') ? challenge.starterCode : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(challenge, 'starterCode') or challenge.starterCode eq ''#">,
                  <cfqueryparam value="#structKeyExists(challenge, 'solution') ? challenge.solution : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(challenge, 'solution') or challenge.solution eq ''#">,
                  <cfqueryparam value="#structKeyExists(challenge, 'difficulty') ? challenge.difficulty : 'Easy'#" cfsqltype="cf_sql_varchar">,
                  <cfqueryparam value="#structKeyExists(challenge, 'points') ? challenge.points : 10#" cfsqltype="cf_sql_integer">
                )
              </cfquery>
            </cfif>
          </cfloop>
          <cfcatch>
            <!--- Table might not exist yet, skip --->
          </cfcatch>
        </cftry>
      </cfif>
      
      <!--- Insert project --->
      <cfif structKeyExists(requestBody, "project") and isStruct(requestBody.project) and structKeyExists(requestBody.project, "title") and len(trim(requestBody.project.title))>
        <cftry>
          <cfset var project = requestBody.project>
          <cfquery datasource="#application.datasource#">
            INSERT INTO lessonProjects (
              lessonId, title, description, requirements, starterCode, 
              solutionCode, extensionIdeas
            ) VALUES (
              <cfqueryparam value="#newId#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#project.title#" cfsqltype="cf_sql_varchar">,
              <cfqueryparam value="#structKeyExists(project, 'description') ? project.description : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(project, 'description') or project.description eq ''#">,
              <cfqueryparam value="#structKeyExists(project, 'requirements') ? project.requirements : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(project, 'requirements') or project.requirements eq ''#">,
              <cfqueryparam value="#structKeyExists(project, 'starterCode') ? project.starterCode : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(project, 'starterCode') or project.starterCode eq ''#">,
              <cfqueryparam value="#structKeyExists(project, 'solutionCode') ? project.solutionCode : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(project, 'solutionCode') or project.solutionCode eq ''#">,
              <cfqueryparam value="#structKeyExists(project, 'extensionIdeas') ? project.extensionIdeas : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(project, 'extensionIdeas') or project.extensionIdeas eq ''#">
            )
          </cfquery>
          <cfcatch>
            <!--- Table might not exist yet, skip --->
          </cfcatch>
        </cftry>
      </cfif>
      
      <cfheader statuscode="201">
      <cfreturn serializeJSON({"success": true, "id": newId})>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfreturn serializeJSON({"success": false, "error": cfcatch.message, "detail": cfcatch.detail})>
      </cfcatch>
    </cftry>
  </cffunction>
  
  <!--- Delete lesson --->
  <cffunction name="deleteLesson" access="remote" returntype="any" httpmethod="DELETE" restpath="{id}" produces="application/json">
    <cfargument name="id" type="numeric" restargsource="path" required="true">
    
    <cftry>
      <cfquery datasource="#application.datasource#">
        DELETE FROM lessonPlans
        WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
      </cfquery>
      
      <cfreturn serializeJSON({"success": true})>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfreturn serializeJSON({"success": false, "error": cfcatch.message})>
      </cfcatch>
    </cftry>
  </cffunction>
  
  <!--- Helper functions --->
  <cffunction name="getTopicsForLesson" access="private" returntype="array">
    <cfargument name="lessonId" type="numeric" required="true">
    
    <cfquery name="qTopics" datasource="#application.datasource#">
      SELECT topic
      FROM lessonTopics
      WHERE lessonId = <cfqueryparam value="#arguments.lessonId#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfset var topics = []>
    <cfloop query="qTopics">
      <cfset arrayAppend(topics, qTopics.topic)>
    </cfloop>
    
    <cfreturn topics>
  </cffunction>
  
  <cffunction name="getObjectivesForLesson" access="private" returntype="array">
    <cfargument name="lessonId" type="numeric" required="true">
    
    <cfquery name="qObjectives" datasource="#application.datasource#">
      SELECT objective
      FROM lessonObjectives
      WHERE lessonId = <cfqueryparam value="#arguments.lessonId#" cfsqltype="cf_sql_integer">
      ORDER BY orderIndex
    </cfquery>
    
    <cfset var objectives = []>
    <cfloop query="qObjectives">
      <cfset arrayAppend(objectives, qObjectives.objective)>
    </cfloop>
    
    <cfreturn objectives>
  </cffunction>
  
  <cffunction name="getMaterialsForLesson" access="private" returntype="array">
    <cfargument name="lessonId" type="numeric" required="true">
    
    <cfquery name="qMaterials" datasource="#application.datasource#">
      SELECT material
      FROM lessonMaterials
      WHERE lessonId = <cfqueryparam value="#arguments.lessonId#" cfsqltype="cf_sql_integer">
    </cfquery>
    
    <cfset var materials = []>
    <cfloop query="qMaterials">
      <cfset arrayAppend(materials, qMaterials.material)>
    </cfloop>
    
    <cfreturn materials>
  </cffunction>
  
  <cffunction name="getActivitiesForLesson" access="private" returntype="array">
    <cfargument name="lessonId" type="numeric" required="true">
    
    <cfquery name="qActivities" datasource="#application.datasource#">
      SELECT id, orderIndex, title, description, duration, type
      FROM lessonActivities
      WHERE lessonId = <cfqueryparam value="#arguments.lessonId#" cfsqltype="cf_sql_integer">
      ORDER BY orderIndex
    </cfquery>
    
    <cfset var activities = []>
    <cfloop query="qActivities">
      <cfset arrayAppend(activities, {
        "id" = qActivities.id,
        "order" = qActivities.orderIndex,
        "title" = qActivities.title,
        "description" = qActivities.description,
        "duration" = qActivities.duration,
        "type" = qActivities.type
      })>
    </cfloop>
    
    <cfreturn activities>
  </cffunction>
  
  <cffunction name="getSnippetsForLesson" access="private" returntype="array">
    <cfargument name="lessonId" type="numeric" required="true">
    
    <cfquery name="qSnippets" datasource="#application.datasource#">
      SELECT s.id, s.title, s.language, s.code, s.explanation, s.difficulty
      FROM codeSnippets s
      INNER JOIN lessonSnippets ls ON s.id = ls.snippetId
      WHERE ls.lessonId = <cfqueryparam value="#arguments.lessonId#" cfsqltype="cf_sql_integer">
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
    
    <cfreturn snippets>
  </cffunction>
  
  <cffunction name="getStepsForLesson" access="private" returntype="array">
    <cfargument name="lessonId" type="numeric" required="true">
    
    <cftry>
      <cfquery name="qSteps" datasource="#application.datasource#">
        SELECT id, stepNumber, title, instruction, codeExample, expectedOutput, explanation, hints
        FROM lessonSteps
        WHERE lessonId = <cfqueryparam value="#arguments.lessonId#" cfsqltype="cf_sql_integer">
        ORDER BY stepNumber
      </cfquery>
      
      <cfset var steps = []>
      <cfloop query="qSteps">
        <cfset arrayAppend(steps, {
          "id" = qSteps.id,
          "stepNumber" = qSteps.stepNumber,
          "title" = qSteps.title,
          "instruction" = qSteps.instruction,
          "codeExample" = qSteps.codeExample,
          "expectedOutput" = qSteps.expectedOutput,
          "explanation" = qSteps.explanation,
          "hints" = qSteps.hints
        })>
      </cfloop>
      
      <cfreturn steps>
      
      <cfcatch>
        <!--- Table might not exist yet, return empty array --->
        <cfreturn []>
      </cfcatch>
    </cftry>
  </cffunction>
  
  <cffunction name="getChallengesForLesson" access="private" returntype="array">
    <cfargument name="lessonId" type="numeric" required="true">
    
    <cftry>
      <cfquery name="qChallenges" datasource="#application.datasource#">
        SELECT id, orderIndex, title, description, starterCode, solution, difficulty, points
        FROM lessonChallenges
        WHERE lessonId = <cfqueryparam value="#arguments.lessonId#" cfsqltype="cf_sql_integer">
        ORDER BY orderIndex
      </cfquery>
      
      <cfset var challenges = []>
      <cfloop query="qChallenges">
        <cfset arrayAppend(challenges, {
          "id" = qChallenges.id,
          "order" = qChallenges.orderIndex,
          "title" = qChallenges.title,
          "description" = qChallenges.description,
          "starterCode" = qChallenges.starterCode,
          "solution" = qChallenges.solution,
          "difficulty" = qChallenges.difficulty,
          "points" = qChallenges.points
        })>
      </cfloop>
      
      <cfreturn challenges>
      
      <cfcatch>
        <!--- Table might not exist yet, return empty array --->
        <cfreturn []>
      </cfcatch>
    </cftry>
  </cffunction>
  
  <cffunction name="getProjectForLesson" access="private" returntype="any">
    <cfargument name="lessonId" type="numeric" required="true">
    
    <cftry>
      <cfquery name="qProject" datasource="#application.datasource#">
        SELECT id, title, description, requirements, starterCode, solutionCode, extensionIdeas
        FROM lessonProjects
        WHERE lessonId = <cfqueryparam value="#arguments.lessonId#" cfsqltype="cf_sql_integer">
      </cfquery>
      
      <cfif qProject.recordCount gt 0>
        <cfreturn {
          "id" = qProject.id,
          "title" = qProject.title,
          "description" = qProject.description,
          "requirements" = qProject.requirements,
          "starterCode" = qProject.starterCode,
          "solutionCode" = qProject.solutionCode,
          "extensionIdeas" = qProject.extensionIdeas
        }>
      <cfelse>
        <cfreturn {}>
      </cfif>
      
      <cfcatch>
        <!--- Table might not exist yet, return empty object --->
        <cfreturn {}>
      </cfcatch>
    </cftry>
  </cffunction>
  
</cfcomponent>
