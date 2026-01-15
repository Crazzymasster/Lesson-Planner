# Coding Lesson Planner 🎓

An AI-powered web application for organizing coding lessons, managing student groups, and generating engaging lesson plans for teaching kids how to code. Now with a comprehensive lesson library organized by programming language!

![Tech Stack](https://img.shields.io/badge/React-TypeScript-blue)
![Tech Stack](https://img.shields.io/badge/ColdFusion-REST_API-orange)
![Tech Stack](https://img.shields.io/badge/AI-Integrated-green)

## 🌟 Features

- **📚 Lesson Plan Management**: Create, organize, and manage comprehensive coding lesson plans
- **🗂️ Language-Based Organization**: Lessons organized by programming language (Python, JavaScript, Java, C++, C#)
- **📖 Step-by-Step Lessons**: Industry-standard lesson format with progressive learning
- **💪 Practice Challenges**: Easy, Medium, and Hard challenges for each lesson
- **🎯 Final Projects**: Comprehensive projects that apply all learned concepts
- **🤖 AI Assistant**: Generate lesson plans, activities, and teaching materials using AI
- **💻 Code Snippet Library**: Store and organize reusable code examples for teaching
- **👥 Student Group Management**: Track different student groups and their skill levels
- **📊 Dashboard**: Quick overview of your teaching resources and recent lessons

## 📁 Project Structure

```
Work Project/
├── frontend/               # React + TypeScript frontend
│   ├── src/
│   │   ├── components/    # Reusable UI components
│   │   ├── pages/        # Application pages
│   │   ├── services/     # API integration
│   │   └── types/        # TypeScript type definitions
│   └── package.json
├── backend/               # ColdFusion REST API
│   ├── api/
│   │   ├── LessonService.cfc    # Lesson CRUD operations
│   │   ├── GroupService.cfc     # Student group management
│   │   ├── SnippetService.cfc   # Code snippet management
│   │   ├── TopicService.cfc     # Topic management
│   │   └── AIService.cfc        # AI integration
│   └── Application.cfc
├── database/              # Database schema and setup
│   ├── schema.sql        # Complete database schema
│   └── README.md         # Database documentation
├── lesson-plans/         # Lesson plan library (NEW!)
│   ├── templates/        # Templates for creating lessons
│   ├── python/          # Python lessons
│   ├── javascript/      # JavaScript lessons
│   ├── java/           # Java lessons
│   ├── cpp/            # C++ lessons
│   ├── csharp/         # C# lessons
│   └── README.md       # Lesson library guide
├── LESSON_PLAN_GUIDE.md # Complete guide to the lesson system
├── QUICKSTART.md        # Quick start guide
└── README.md           # This file
```

### 2. Database Setup

See detailed instructions in [database/README.md](database/README.md)

**Quick Start:**

```sql
-- Create database
CREATE DATABASE lessonplanner;
GO

-- Run schema
USE lessonplanner;
GO
-- Execute database/schema.sql
```

Configure the ColdFusion datasource named `lessonplanner` in CF Administrator.

### 3. Backend Setup (ColdFusion)

1. **Place backend folder in your ColdFusion webroot:**
   ```
   C:\ColdFusion\cfusion\wwwroot\lessonplanner-api\
   ```

2. **Configure REST Services:**
   - Ensure ColdFusion REST is enabled
   - The Application.cfc will auto-configure REST endpoints

3. **Set API Key (Optional for AI features):**
   
   Edit `backend/Application.cfc`:
   ```coldfusion
   <cfset application.apiKey = "your-openai-api-key-here">
   ```

4. **Restart ColdFusion:**
   ```bash
   # Windows
   net stop ColdFusion
   net start ColdFusion
   ```

5. **Test API:**
   Navigate to: `http://localhost:8500/rest/lessons` (adjust port as needed)

### 4. Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

The app will open at `http://localhost:3000`

## 🔧 Configuration

### Frontend API Endpoint

Edit `frontend/vite.config.ts` to change the backend URL:

```typescript
server: {
  port: 3000,
  proxy: {
    '/api': {
      target: 'http://localhost:8500', // Your ColdFusion server
      changeOrigin: true,
    },
  },
}
```

### CORS Configuration

The backend includes CORS headers in `Application.cfc`. Adjust the allowed origin if needed:

```coldfusion
<cfheader name="Access-Control-Allow-Origin" value="http://localhost:3000">
```

### AI Provider

To switch AI providers, edit `backend/api/AIService.cfc`:

```coldfusion
<cfset application.apiKey = "your-api-key">
<cfset application.aiProvider = "openai"> <!-- or 'anthropic', 'groq' -->
```

## 📁 Project Structure

```
Work Project/
├── frontend/                 # React + TypeScript application
│   ├── src/
│   │   ├── components/      # Reusable UI components
│   │   ├── pages/           # Page components
│   │   ├── services/        # API service layer
│   │   ├── types/           # TypeScript type definitions
│   │   ├── App.tsx          # Main app component
│   │   └── main.tsx         # App entry point
│   ├── package.json
│   ├── tsconfig.json
│   └── vite.config.ts
│
├── backend/                  # ColdFusion REST API
│   ├── api/
│   │   ├── LessonService.cfc    # Lesson plan endpoints
│   │   ├── AIService.cfc        # AI generation endpoints
│   │   ├── SnippetService.cfc   # Code snippet endpoints
│   │   ├── GroupService.cfc     # Student group endpoints
│   │   └── TopicService.cfc     # Topic management
│   └── Application.cfc           # App configuration
│
└── database/                 # Database schema and setup
    ├── schema.sql           # Database structure
    └── README.md            # Database setup guide
```

## 🎯 API Endpoints

### Lessons
- `GET /api/lessons` - Get all lesson plans
- `GET /api/lessons/{id}` - Get specific lesson
- `POST /api/lessons` - Create new lesson
- `PUT /api/lessons/{id}` - Update lesson
- `DELETE /api/lessons/{id}` - Delete lesson

### AI Assistant
- `POST /api/ai/generate-lesson` - Generate complete lesson plan
- `POST /api/ai/suggest-activities` - Get activity suggestions
- `POST /api/ai/improve-description` - Improve lesson description

### Code Snippets
- `GET /api/snippets` - Get all code snippets
- `POST /api/snippets` - Create new snippet
- `DELETE /api/snippets/{id}` - Delete snippet

### Student Groups
- `GET /api/groups` - Get all student groups
- `POST /api/groups` - Create new group
- `DELETE /api/groups/{id}` - Delete group

### Topics
- `GET /api/topics` - Get all coding topics

## 💡 Usage Examples

### Creating a Lesson Plan

1. Navigate to "AI Assistant" page
2. Fill in the form:
   - Topic: "Python Loops"
   - Target Age: "10-12"
   - Duration: 60 minutes
   - Difficulty: Beginner
3. Click "Generate Lesson Plan"
4. Review and save the generated content

### Managing Code Snippets

1. Go to "Code Snippets" page
2. Click "Add Snippet"
3. Enter code, explanation, and metadata
4. Link snippets to lesson plans for easy reference

## 🎨 Customization

### Styling

The app uses vanilla CSS with CSS variables for theming. Main styles are in:
- `frontend/src/index.css` - Global styles
- `frontend/src/components/*.css` - Component-specific styles
- `frontend/src/pages/*.css` - Page-specific styles

### Adding New Features

1. **Frontend**: Add new components in `src/components/` or pages in `src/pages/`
2. **Backend**: Create new CFC files in `backend/api/` with REST annotations
3. **Database**: Add new tables in `database/schema.sql`

## 🐛 Troubleshooting

### Frontend can't connect to backend
- Check if ColdFusion is running on the correct port
- Verify proxy configuration in `vite.config.ts`
- Check CORS headers in `Application.cfc`

### Database connection errors
- Verify datasource is configured in CF Administrator
- Check database credentials
- Ensure database server is running

### AI features not working
- Verify API key is set in `Application.cfc`
- Check internet connectivity
- Review API quotas and rate limits

---

**Happy Teaching! 🎉**
