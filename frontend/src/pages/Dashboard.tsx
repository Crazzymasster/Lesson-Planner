import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { lessonPlanService, codeSnippetService, studentGroupService, studentService } from '@/services/api';
import { BookOpen, Code, Users, Plus, TrendingUp, GraduationCap } from 'lucide-react';
import type { Student, StudentGroup } from '@/types';
import './Dashboard.css';

export default function Dashboard() {
  const [stats, setStats] = useState({
    totalLessons: 0,
    totalSnippets: 0,
    totalGroups: 0,
    totalStudents: 0,
  });
  const [recentLessons, setRecentLessons] = useState<any[]>([]);
  const [groups, setGroups] = useState<StudentGroup[]>([]);
  const [topStudents, setTopStudents] = useState<Student[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      const [lessonsRes, snippetsRes, groupsRes, studentsRes] = await Promise.all([
        lessonPlanService.getAll(),
        codeSnippetService.getAll(),
        studentGroupService.getAll(),
        studentService.getAll(),
      ]);

      setStats({
        totalLessons: lessonsRes.data.length,
        totalSnippets: snippetsRes.data.length,
        totalGroups: groupsRes.data.length,
        totalStudents: studentsRes.data.length,
      });

      // Get 5 most recent lessons
      setRecentLessons(lessonsRes.data.slice(0, 5));
      
      // Get all groups
      setGroups(groupsRes.data);
      
      // Get top 5 students by completed lessons
      const sortedStudents = studentsRes.data
        .sort((a: Student, b: Student) => (b.completedLessons || 0) - (a.completedLessons || 0))
        .slice(0, 5);
      setTopStudents(sortedStudents);
    } catch (error) {
      console.error('Error loading dashboard:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="loading">Loading dashboard...</div>;
  }

  return (
    <div className="dashboard">
      <div className="dashboard-header">
        <h1>Dashboard</h1>
        <Link to="/lessons/new" className="btn btn-primary">
          <Plus size={20} />
          New Lesson Plan
        </Link>
      </div>

      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-icon" style={{ backgroundColor: '#e3f2fd' }}>
            <BookOpen size={24} color="#1a237e" />
          </div>
          <div className="stat-content">
            <h3>{stats.totalLessons}</h3>
            <p>Lesson Plans</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon" style={{ backgroundColor: '#f3e5f5' }}>
            <Code size={24} color="#7b1fa2" />
          </div>
          <div className="stat-content">
            <h3>{stats.totalSnippets}</h3>
            <p>Code Snippets</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon" style={{ backgroundColor: '#e8f5e9' }}>
            <Users size={24} color="#388e3c" />
          </div>
          <div className="stat-content">
            <h3>{stats.totalGroups}</h3>
            <p>Student Groups</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon" style={{ backgroundColor: '#fff3e0' }}>
            <GraduationCap size={24} color="#f57c00" />
          </div>
          <div className="stat-content">
            <h3>{stats.totalStudents}</h3>
            <p>Students</p>
          </div>
        </div>
      </div>

      <div className="recent-section">
        <h2>Recent Lesson Plans</h2>
        {recentLessons.length === 0 ? (
          <div className="empty-state">
            <p>No lesson plans yet. Create your first one!</p>
            <Link to="/lessons/new" className="btn btn-primary">
              Create Lesson Plan
            </Link>
          </div>
        ) : (
          <div className="lessons-list">
            {recentLessons.map((lesson) => (
              <Link
                key={lesson.id}
                to={`/lessons/${lesson.id}`}
                className="lesson-card"
              >
                <h3>{lesson.title}</h3>
                <p>{lesson.description}</p>
                <div className="lesson-meta">
                  <span className="badge">{lesson.difficulty}</span>
                  <span className="badge">{lesson.targetAge}</span>
                  <span>{lesson.duration} min</span>
                </div>
              </Link>
            ))}
          </div>
        )}
      </div>

      <div className="dashboard-grid">
        <div className="recent-section">
          <h2>Student Groups</h2>
          {groups.length === 0 ? (
            <div className="empty-state">
              <p>No student groups yet.</p>
            </div>
          ) : (
            <div className="groups-list">
              {groups.slice(0, 5).map((group) => (
                <Link
                  key={group.id}
                  to="/students"
                  className="group-item"
                >
                  <Users size={20} />
                  <div className="group-info">
                    <h4>{group.name}</h4>
                    <p>{group.description}</p>
                  </div>
                </Link>
              ))}
            </div>
          )}
        </div>

        <div className="recent-section">
          <h2>Top Students</h2>
          {topStudents.length === 0 ? (
            <div className="empty-state">
              <p>No student data available.</p>
            </div>
          ) : (
            <div className="students-list">
              {topStudents.map((student, index) => (
                <Link
                  key={student.id}
                  to={`/students/${student.id}`}
                  className="student-item"
                >
                  <div className="student-rank">#{index + 1}</div>
                  <div className="student-info">
                    <h4>{student.name}</h4>
                    <p>{student.completedLessons || 0} lessons completed</p>
                  </div>
                  <div className="student-badge">{student.skillLevel}</div>
                </Link>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
