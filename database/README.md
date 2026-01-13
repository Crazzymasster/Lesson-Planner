# Database Setup Instructions

## Option 1: SQL Server (Recommended for Windows with ColdFusion)

### 1. Install SQL Server Express (if not installed)
- Download from: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
- Choose "Express" edition (free)
- Install SQL Server Management Studio (SSMS) for easier management

### 2. Create Database
Open SQL Server Management Studio and run:

```sql
CREATE DATABASE lessonplanner;
GO

USE lessonplanner;
GO
```

### 3. Run Schema
Execute the `schema.sql` file in SSMS or via command line:

```bash
sqlcmd -S localhost -d lessonplanner -i schema.sql
```

### 4. Configure ColdFusion Data Source

#### Option A: Using ColdFusion Administrator
1. Navigate to: `http://localhost:8500/CFIDE/administrator/` (or your CF admin URL)
2. Go to "Data & Services" → "Data Sources"
3. Add new data source:
   - **Data Source Name**: `lessonplanner`
   - **Driver**: Microsoft SQL Server
   - **Server**: `localhost` or `127.0.0.1`
   - **Port**: `1433`
   - **Database**: `lessonplanner`
   - **Username**: (your SQL Server username, or use Windows authentication)
   - **Password**: (your SQL Server password)
4. Click "Submit" and verify connection

#### Option B: Using Application.cfc (programmatic)
Add to Application.cfc:

```coldfusion
<cfset this.datasources["lessonplanner"] = {
  class: 'com.microsoft.sqlserver.jdbc.SQLServerDriver',
  connectionString: 'jdbc:sqlserver://localhost:1433;databaseName=lessonplanner;',
  username: 'your_username',
  password: 'your_password'
}>
```

---

## Option 2: MySQL

### 1. Install MySQL
- Download from: https://dev.mysql.com/downloads/mysql/
- Or use XAMPP/MAMP which includes MySQL

### 2. Create Database
```sql
CREATE DATABASE lessonplanner;
USE lessonplanner;
```

### 3. Modify Schema for MySQL
Change the following in `schema.sql`:
- Replace `IDENTITY(1,1)` with `AUTO_INCREMENT`
- Replace `GETDATE()` with `NOW()`
- Replace `TEXT` with `LONGTEXT` for larger text fields

### 4. Run Schema
```bash
mysql -u root -p lessonplanner < schema.sql
```

### 5. Configure ColdFusion Data Source
Use driver: **MySQL (DataDirect)** or **MySQL (JDBC)**
- Server: `localhost`
- Port: `3306`
- Database: `lessonplanner`

---

## Testing the Database

After setup, test with a simple query in ColdFusion:

```coldfusion
<cfquery name="test" datasource="lessonplanner">
  SELECT COUNT(*) as count FROM lessonPlans
</cfquery>

<cfoutput>
  Lesson Plans in Database: #test.count#
</cfoutput>
```

---

## Database Connection String

The application expects a datasource named: **lessonplanner**

This is configured in `Application.cfc`:
```coldfusion
<cfset this.datasource = "lessonplanner">
```

---

## Troubleshooting

### Connection Failed
- Verify SQL Server/MySQL is running
- Check firewall settings allow connections
- Verify credentials are correct
- Ensure JDBC drivers are installed in ColdFusion

### ColdFusion Can't Find Datasource
- Restart ColdFusion service after creating datasource
- Check datasource name matches exactly (case-sensitive on some systems)

### Permission Errors
- Ensure database user has CREATE, SELECT, INSERT, UPDATE, DELETE permissions
- For SQL Server, user should be in db_owner or db_datareader/db_datawriter roles
