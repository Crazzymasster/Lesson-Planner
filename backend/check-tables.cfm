<cfscript>
    writeOutput("<html><head><title>Database Tables Check</title></head><body>");
    writeOutput("<h1>Database Tables Check</h1>");
    
    datasourceName = "lessonplanner";
    tables = ["lessonPlans", "lessonTopics", "lessonObjectives", "lessonMaterials", 
              "lessonActivities", "lessonSteps", "lessonChallenges", "lessonProjects"];
    
    writeOutput("<table border='1' cellpadding='10'><tr><th>Table Name</th><th>Status</th><th>Columns</th></tr>");
    
    for (tableName in tables) {
        try {
            query name="qCheck" datasource="#datasourceName#" {
                echo("SELECT TOP 1 * FROM " & tableName);
            }
            
            columns = qCheck.columnList;
            writeOutput("<tr><td>" & tableName & "</td><td style='color: green;'><strong>✓ EXISTS</strong></td><td>" & columns & "</td></tr>");
        } catch (any e) {
            writeOutput("<tr><td>" & tableName & "</td><td style='color: red;'><strong>✗ MISSING</strong></td><td>" & e.message & "</td></tr>");
        }
    }
    
    writeOutput("</table>");
    writeOutput("<h2>Next Steps:</h2>");
    writeOutput("<p>If any tables are missing, run the SQL script in <code>database/schema.sql</code> in your SQL Server Management Studio or database tool.</p>");
    writeOutput("</body></html>");
</cfscript>
