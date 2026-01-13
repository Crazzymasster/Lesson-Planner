<cfcomponent rest="true" restpath="topics">
  
  <!--- Get all topics --->
  <cffunction name="getAllTopics" access="remote" returntype="any" httpmethod="GET" restpath="" produces="application/json">
    <cftry>
      <cfset var topics = [
        {"id": 1, "name": "Variables", "category": "Python Basics", "description": "Understanding variables and data types", "prerequisites": []},
        {"id": 2, "name": "Loops", "category": "Python Basics", "description": "For and while loops", "prerequisites": ["Variables"]},
        {"id": 3, "name": "Functions", "category": "Python Basics", "description": "Creating and using functions", "prerequisites": ["Variables"]},
        {"id": 4, "name": "Lists", "category": "Data Structures", "description": "Working with lists and arrays", "prerequisites": ["Variables", "Loops"]},
        {"id": 5, "name": "HTML Basics", "category": "Web Development", "description": "Basic HTML structure and tags", "prerequisites": []},
        {"id": 6, "name": "CSS Styling", "category": "Web Development", "description": "Styling web pages with CSS", "prerequisites": ["HTML Basics"]},
        {"id": 7, "name": "Conditionals", "category": "Python Basics", "description": "If statements and logic", "prerequisites": ["Variables"]},
        {"id": 8, "name": "Game Development", "category": "Projects", "description": "Creating simple games", "prerequisites": ["Variables", "Loops", "Conditionals"]}
      ]>
      
      <cfreturn serializeJSON(topics)>
      
      <cfcatch>
        <cfheader statuscode="500">
        <cfreturn serializeJSON({"success": false, "error": cfcatch.message})>
      </cfcatch>
    </cftry>
  </cffunction>
  
</cfcomponent>
