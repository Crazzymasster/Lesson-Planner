import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import LessonPlans from './pages/LessonPlans';
import LessonPlanDetail from './pages/LessonPlanDetail';
import CreateLesson from './pages/CreateLesson';
import FolderDetail from './pages/FolderDetail';
import CodeSnippets from './pages/CodeSnippets';
import CodeSnippetDetail from './pages/CodeSnippetDetail';
import CreateSnippet from './pages/CreateSnippet';
import StudentGroups from './pages/StudentGroups';
import CreateStudent from './pages/CreateStudent';
import CreateGroup from './pages/CreateGroup';
import StudentDetail from './pages/StudentDetail';
import AssignLessons from './pages/AssignLessons';
import AIAssistant from './pages/AIAssistant';

function App() {
  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/lessons" element={<LessonPlans />} />
          <Route path="/lessons/new" element={<CreateLesson />} />
          <Route path="/lessons/:id" element={<LessonPlanDetail />} />
          <Route path="/lessons/:id/edit" element={<CreateLesson />} />
          <Route path="/folders/:id" element={<FolderDetail />} />
          <Route path="/snippets" element={<CodeSnippets />} />
          <Route path="/snippets/new" element={<CreateSnippet />} />
          <Route path="/snippets/edit/:id" element={<CreateSnippet />} />
          <Route path="/snippets/:id" element={<CodeSnippetDetail />} />
          <Route path="/students" element={<StudentGroups />} />
          <Route path="/students/new" element={<CreateStudent />} />
          <Route path="/students/:id" element={<StudentDetail />} />
          <Route path="/students/:id/edit" element={<CreateStudent />} />
          <Route path="/students/:id/lessons" element={<AssignLessons />} />
          <Route path="/groups" element={<StudentGroups />} />
          <Route path="/groups/new" element={<CreateGroup />} />
          <Route path="/ai-assistant" element={<AIAssistant />} />
        </Routes>
      </Layout>
    </Router>
  );
}

export default App;
