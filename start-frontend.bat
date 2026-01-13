@echo off
echo Starting Coding Lesson Planner Frontend...
echo.

REM Add Node.js to PATH for this session
set PATH=%PATH%;C:\Program Files\nodejs

REM Navigate to frontend directory
cd /d "%~dp0frontend"

REM Check if node_modules exists
if not exist "node_modules\" (
    echo Installing dependencies...
    call npm install
    echo.
)

REM Start development server
echo Starting development server...
echo The app will open at http://localhost:3000
echo Press Ctrl+C to stop the server
echo.
call npm run dev

pause
