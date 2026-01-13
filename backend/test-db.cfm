<cfscript>
    writeOutput("<h1>Database Connection Test</h1>");
    
    try {
        // Test connection by querying the lessonPlans table
        query name="testQuery" datasource="lessonplanner" {
            echo("SELECT COUNT(*) as count FROM lessonPlans");
        }
        
        writeOutput("<p style='color: green;'><strong>SUCCESS!</strong> Database connection is working.</p>");
        writeOutput("<p>Lesson Plans in Database: " & testQuery.count & "</p>");
        
        // Test all tables
        writeOutput("<h2>All Tables:</h2><ul>");
        
        query name="topics" datasource="lessonplanner" {
            echo("SELECT COUNT(*) as count FROM topics");
        }
        writeOutput("<li>Topics: " & topics.count & "</li>");
        
        query name="groups" datasource="lessonplanner" {
            echo("SELECT COUNT(*) as count FROM studentGroups");
        }
        writeOutput("<li>Student Groups: " & groups.count & "</li>");
        
        query name="snippets" datasource="lessonplanner" {
            echo("SELECT COUNT(*) as count FROM codeSnippets");
        }
        writeOutput("<li>Code Snippets: " & snippets.count & "</li>");
        
        writeOutput("</ul>");
        
    } catch (any e) {
        writeOutput("<p style='color: red;'><strong>ERROR!</strong> Database connection failed.</p>");
        writeOutput("<p>Error Message: " & e.message & "</p>");
        writeOutput("<p>Detail: " & e.detail & "</p>");
    }
</cfscript>
