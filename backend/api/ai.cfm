<!--- Groq API Configuration--->
<!--- TODO: Move this to environment variables or Application.cfc for security --->
<cfset GROQ_API_KEY = "YOUR_GROQ_API_KEY_HERE">
<cfset GROQ_MODEL = "llama-3.3-70b-versatile">

<cfsetting enablecfoutputonly="true">

<cfif cgi.request_method EQ "POST">
    <cftry>
        <!--- Get the request body --->
        <cfset requestBody = toString(getHttpRequestData().content)>
        <cfset data = deserializeJSON(requestBody)>
        
        <!--- Determine which endpoint was called --->
        <cfset pathInfo = cgi.path_info>
        
        <!--- Debug logging --->
        <cflog file="ai_debug" text="Path Info: #pathInfo# - Request: #requestBody#">
        
        <cfif findNoCase("/generate-lesson", pathInfo) OR true>
            <!--- Temporarily accepting all POST requests to test --->
            <!--- Build the AI prompt --->
            <cfset prompt = "Create a detailed coding lesson plan with the following requirements:

Topic: #data.topic#
Target Age: #data.targetAge#
Duration: #data.duration# minutes
Difficulty: #data.difficulty#">
            
            <cfif structKeyExists(data, "additionalContext") AND len(trim(data.additionalContext))>
                <cfset prompt = prompt & "
Additional Context: #data.additionalContext#">
            </cfif>
            
            <cfset includeFinalProject = structKeyExists(data, "includeFinalProject") AND data.includeFinalProject>
            
            <cfset prompt = prompt & "

You must respond with ONLY valid JSON (no markdown, no code blocks). Generate:
- title: engaging lesson title
- description: what students will learn
- objectives: array of 3-4 learning objectives
- activities: array of 3-4 teaching steps, each with title, description, duration, type, and codeExample (full working code)
- materials: array of 3 materials needed
- challenges: array of 2-3 practice problems, each with title, description, hints, starterCode (minimal starter), and solution (complete code)
- tips: array of 3 teaching tips">
            
            <cfif includeFinalProject>
                <cfset prompt = prompt & "
- project: a comprehensive final project object with title, description, requirements, starterCode, solution, and extensionIdeas. The project should challenge students to apply everything they learned in the lesson. Make it engaging and appropriately difficult for the target age group.">
            </cfif>
            
            <cfset prompt = prompt & "

Make activities progressive with complete working code examples.
Make challenges actual coding problems with minimal starter code for students to complete.">
            
            <cfif includeFinalProject>
                <cfset prompt = prompt & "
Make the final project comprehensive and creative - it should be the capstone that demonstrates mastery of all lesson concepts.">
            </cfif>
            
            <!--- Call Groq API (FREE!) --->
            <cfhttp url="https://api.groq.com/openai/v1/chat/completions" method="POST" result="httpResult" timeout="30">
                <cfhttpparam type="header" name="Authorization" value="Bearer #GROQ_API_KEY#">
                <cfhttpparam type="header" name="Content-Type" value="application/json">
                <cfhttpparam type="body" value='#serializeJSON({
                    "model": GROQ_MODEL,
                    "messages": [
                        {
                            "role": "system",
                            "content": "You are an expert coding education instructor who creates engaging lesson plans for kids. You must respond with valid JSON only - no markdown, no code blocks, just pure JSON."
                        },
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    "temperature": 0.7,
                    "response_format": {"type": "json_object"}
                })#'>
            </cfhttp>
            
            <cfif httpResult.statusCode CONTAINS "200">
                <cftry>
                    <cfset apiResponse = deserializeJSON(httpResult.fileContent)>
                    <cfset aiContent = apiResponse.choices[1].message.content>
                    
                    <!--- Log what we got from AI --->
                    <cflog file="ai_debug" text="AI Raw Response: #aiContent#">
                    
                    <!--- Clean up any markdown if present --->
                    <cfset aiContent = replaceNoCase(aiContent, "```json", "", "ALL")>
                    <cfset aiContent = replaceNoCase(aiContent, "```", "", "ALL")>
                    <cfset aiContent = trim(aiContent)>
                    
                    <cfset result = deserializeJSON(aiContent)>
                    
                    <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(result)#</cfoutput>
                    
                    <cfcatch>
                        <cflog file="ai_errors" text="Parse Error - Message: #cfcatch.message# - Detail: #cfcatch.detail# - AI Content: #aiContent#">
                        <cfheader statuscode="500">
                        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON({
                            "success": false,
                            "error": "Failed to parse AI response",
                            "message": cfcatch.message,
                            "detail": cfcatch.detail,
                            "aiContent": left(aiContent, 500)
                        })#</cfoutput>
                    </cfcatch>
                </cftry>
            <cfelse>
                <!--- Log the error details --->
                <cflog file="ai_errors" text="Groq API Error - Status: #httpResult.statusCode# - Response: #httpResult.fileContent#">
                <cfheader statuscode="500">
                <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON({
                    "success": false,
                    "error": "Groq API Error",
                    "detail": httpResult.statusCode,
                    "message": httpResult.fileContent
                })#</cfoutput>
            </cfif>
            
        <cfelseif findNoCase("/suggest-activities", pathInfo)>
            <!--- Suggest activities --->
            <cfset result = {
                "success": true,
                "activities": []
            }>
            
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(result)#</cfoutput>
            
        <cfelseif findNoCase("/improve-description", pathInfo)>
            <!--- Improve description --->
            <cfset result = {
                "success": true,
                "improved": data.description
            }>
            
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(result)#</cfoutput>
        </cfif>
        
        <cfcatch>
            <cfheader statuscode="500">
            <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON({"success": false, "error": cfcatch.message, "detail": cfcatch.detail})#</cfoutput>
        </cfcatch>
    </cftry>
    
<cfelse>
    <!--- Method not allowed --->
    <cfheader statuscode="405" statustext="Method Not Allowed">
    <cfcontent type="application/json" reset="true"><cfoutput>{"error": "Method not allowed"}</cfoutput>
</cfif>
