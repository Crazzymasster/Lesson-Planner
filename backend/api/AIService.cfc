<cfcomponent rest="true" restpath="ai">
  
  <!--- Generate lesson plan using AI --->
  <cffunction name="generateLesson" access="remote" returntype="any" httpmethod="POST" restpath="generate-lesson" produces="application/json">
    <cftry>
      <cfset var requestBody = deserializeJSON(toString(getHTTPRequestData().content))>
      
      <!--- Build AI prompt --->
      <cfset var prompt = buildLessonPrompt(requestBody)>
      
      <!--- Call AI API --->
      <cfset var aiResponse = callAIAPI(prompt)>
      
      <!--- Parse and structure the response --->
      <cfset var lessonPlan = parseAIResponse(aiResponse)>
      
      <cfreturn serializeJSON(lessonPlan)>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfreturn serializeJSON({"success": false, "error": cfcatch.message})>
      </cfcatch>
    </cftry>
  </cffunction>
  
  <!--- Suggest activities for a topic --->
  <cffunction name="suggestActivities" access="remote" returntype="any" httpmethod="POST" restpath="suggest-activities" produces="application/json">
    <cftry>
      <cfset var requestBody = deserializeJSON(toString(getHTTPRequestData().content))>
      
      <cfset var prompt = "Suggest 3-5 engaging coding activities for teaching #requestBody.topic# that fit in #requestBody.duration# minutes. Include hands-on exercises, games, or projects suitable for kids. Return as JSON array with title, description, duration, and type fields.">
      
      <cfset var aiResponse = callAIAPI(prompt)>
      
      <cfreturn serializeJSON({"activities": deserializeJSON(aiResponse)})>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfreturn serializeJSON({"success": false, "error": cfcatch.message})>
      </cfcatch>
    </cftry>
  </cffunction>
  
  <!--- Improve description using AI --->
  <cffunction name="improveDescription" access="remote" returntype="any" httpmethod="POST" restpath="improve-description" produces="application/json">
    <cftry>
      <cfset var requestBody = deserializeJSON(toString(getHTTPRequestData().content))>
      
      <cfset var prompt = "Improve this lesson description to be more engaging and clear for kids coding education: #requestBody.description#">
      
      <cfset var aiResponse = callAIAPI(prompt)>
      
      <cfreturn serializeJSON({"improved": aiResponse})>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfreturn serializeJSON({"success": false, "error": cfcatch.message})>
      </cfcatch>
    </cftry>
  </cffunction>
  
  <!--- Helper: Build lesson generation prompt --->
  <cffunction name="buildLessonPrompt" access="public" returntype="string">
    <cfargument name="request" type="struct" required="true">
    
    <cfset var prompt = "">
    <cfsavecontent variable="prompt">
Create a detailed coding lesson plan with the following requirements:

Topic: #arguments.request.topic#
Target Age: #arguments.request.targetAge#
Duration: #arguments.request.duration# minutes
Difficulty: #arguments.request.difficulty#
<cfif structKeyExists(arguments.request, "additionalContext") and len(arguments.request.additionalContext)>
Additional Context: #arguments.request.additionalContext#
</cfif>

Please provide a comprehensive lesson plan in JSON format with the following structure:
{
  "title": "Engaging lesson title",
  "description": "Clear, engaging description of what students will learn",
  "objectives": ["Learning objective 1", "Learning objective 2", ...],
  "activities": [
    {
      "title": "Activity name",
      "description": "What students do",
      "duration": duration_in_minutes,
      "type": "lecture|hands-on|discussion|game|project"
    }
  ],
  "materials": ["Material 1", "Material 2", ...],
  "codeSnippets": [
    {
      "title": "Code example title",
      "language": "python|javascript|scratch|etc",
      "code": "actual code here",
      "explanation": "What this code does"
    }
  ],
  "tips": ["Teaching tip 1", "Teaching tip 2", ...]
}

Make it engaging, age-appropriate, and hands-on focused.
    </cfsavecontent>
    
    <cfreturn trim(prompt)>
  </cffunction>
  
  <!--- Helper: Call AI API --->
  <cffunction name="callAIAPI" access="public" returntype="string">
    <cfargument name="prompt" type="string" required="true">
    
    <!--- This is a simplified example. In production, you'd call OpenAI, Anthropic, etc. --->
    <cfif NOT structKeyExists(application, "apiKey") OR len(application.apiKey) eq 0>
      <!--- Return mock data for development --->
      <cfreturn getMockResponse(arguments.prompt)>
    </cfif>
    
    <!--- Example OpenAI API call --->
    <cfhttp url="https://api.openai.com/v1/chat/completions" method="POST" result="httpResult">
      <cfhttpparam type="header" name="Authorization" value="Bearer #application.apiKey#">
      <cfhttpparam type="header" name="Content-Type" value="application/json">
      <cfhttpparam type="body" value='#serializeJSON({
        "model": "gpt-4",
        "messages": [
          {"role": "system", "content": "You are an expert coding education instructor who creates engaging lesson plans for kids."},
          {"role": "user", "content": arguments.prompt}
        ],
        "temperature": 0.7,
        "response_format": {"type": "json_object"}
      })#'>
    </cfhttp>
    
    <cfif httpResult.statusCode contains "200">
      <cfset var response = deserializeJSON(httpResult.fileContent)>
      <cfreturn response.choices[1].message.content>
    <cfelse>
      <cfthrow message="AI API Error: #httpResult.statusCode#">
    </cfif>
  </cffunction>
  
  <!--- Helper: Mock response for development --->
  <cffunction name="getMockResponse" access="public" returntype="string">
    <cfargument name="prompt" type="string" required="true">
    
    <cfset var mockResponse = {
      "title": "Introduction to Python Variables and Data Types",
      "description": "Students will learn the fundamentals of variables in Python, including how to create, name, and use different data types like strings, integers, and floats through fun, interactive exercises.",
      "objectives": [
        "Understand what variables are and why they're important in programming",
        "Create and assign values to variables using proper naming conventions",
        "Identify and use different data types (strings, integers, floats)",
        "Perform basic operations with variables"
      ],
      "activities": [
        {
          "title": "Variable Treasure Hunt",
          "description": "Students create variables to store clues and solve a digital treasure hunt",
          "duration": 15,
          "type": "game"
        },
        {
          "title": "Data Type Detective",
          "description": "Interactive exercise where students identify and categorize different data types",
          "duration": 20,
          "type": "hands-on"
        },
        {
          "title": "Build a Mad Libs Game",
          "description": "Students create a simple Mad Libs game using string variables",
          "duration": 20,
          "type": "project"
        },
        {
          "title": "Review and Q&A",
          "description": "Recap key concepts and answer student questions",
          "duration": 5,
          "type": "discussion"
        }
      ],
      "materials": [
        "Computer with Python installed",
        "Code editor (VS Code, Thonny, or online REPL)",
        "Handout with variable naming rules",
        "Mad Libs story template"
      ],
      "codeSnippets": [
        {
          "title": "Creating Basic Variables",
          "language": "python",
          "code": "# String variable\nplayer_name = ""Alex""\n\n# Integer variable\nplayer_score = 100\n\n# Float variable\nplayer_health = 75.5\n\nprint(f""{player_name} has {player_score} points and {player_health}% health!"")",
          "explanation": "This example shows how to create different types of variables and use them in a print statement with f-strings."
        },
        {
          "title": "Variable Operations",
          "language": "python",
          "code": "# Math with variables\ncoins = 10\ncoins = coins + 5  # Collect 5 more coins\nprint(f""You now have {coins} coins!"")\n\n# String concatenation\nfirst_name = ""Super""\nlast_name = ""Coder""\nfull_name = first_name + "" "" + last_name\nprint(full_name)",
          "explanation": "Shows how to perform operations on variables, including math and string concatenation."
        }
      ],
      "tips": [
        "Use relatable examples like game scores, character names, or favorite things to make variables concrete",
        "Emphasize the 'container' or 'box' metaphor for variables to help visual learners",
        "Let students choose their own variable names (following the rules) to increase engagement",
        "Have students work in pairs for the Mad Libs project to encourage collaboration",
        "Keep a 'common mistakes' board to address naming errors and type mismatches as they occur"
      ]
    }>
    
    <cfreturn serializeJSON(mockResponse)>
  </cffunction>
  
  <!--- Helper: Parse AI response --->
  <cffunction name="parseAIResponse" access="public" returntype="struct">
    <cfargument name="aiResponse" type="string" required="true">
    
    <cftry>
      <cfreturn deserializeJSON(arguments.aiResponse)>
      
      <cfcatch>
        <!--- If parsing fails, return basic structure --->
        <cfreturn {
          "title": "Generated Lesson Plan",
          "description": arguments.aiResponse,
          "objectives": [],
          "activities": [],
          "materials": [],
          "codeSnippets": [],
          "tips": []
        }>
      </cfcatch>
    </cftry>
  </cffunction>
  
</cfcomponent>
