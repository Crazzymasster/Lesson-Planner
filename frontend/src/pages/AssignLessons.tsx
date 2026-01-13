import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { studentService, lessonPlanService, progressService } from '@/services/api';
import type { Student, LessonPlan } from '@/types';
import { ArrowLeft, BookOpen, Award, CheckCircle, Circle, Trophy, Star } from 'lucide-react';
import './AssignLessons.css';

export default function AssignLessons() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const [student, setStudent] = useState<Student | null>(null);
  const [lessons, setLessons] = useState<LessonPlan[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'completed' | 'pending'>('all');
  const [languageFilter, setLanguageFilter] = useState<string>('all');
  const [successMessage, setSuccessMessage] = useState<string>('');
  const [errorMessage, setErrorMessage] = useState<string>('');

  useEffect(() => {
    if (id) {
      loadData(parseInt(id));
    }
  }, [id]);

  const loadData = async (studentId: number) => {
    try {
      setLoading(true);
      const [studentRes, lessonsRes] = await Promise.all([
        studentService.getById(studentId),
        lessonPlanService.getAll()
      ]);
      console.log('Loaded lessons:', lessonsRes.data);
      console.log('First lesson points:', lessonsRes.data[0]?.points);
      setStudent(studentRes.data);
      setLessons(lessonsRes.data);
    } catch (err) {
      console.error('Error loading data:', err);
      setErrorMessage('Failed to load data');
    } finally {
      setLoading(false);
    }
  };

  const handleMarkComplete = async (lessonId: number, lessonPoints: number) => {
    if (!student) return;

    try {
      const response = await progressService.markComplete(student.id, lessonId);
      setSuccessMessage(`Lesson completed! +${lessonPoints} points earned`);
      setErrorMessage('');
      
      // Reload student data to reflect changes
      const studentRes = await studentService.getById(student.id);
      setStudent(studentRes.data);
      
      // Auto-dismiss success message after 3 seconds
      setTimeout(() => setSuccessMessage(''), 3000);
    } catch (err: any) {
      console.error('Error marking lesson complete:', err);
      setErrorMessage(err.response?.data?.error || 'Failed to mark lesson as complete');
      setSuccessMessage('');
    }
  };

  const isLessonCompleted = (lessonId: number) => {
    if (!student) return false;
    return student.progress?.some(p => p.lessonId === lessonId && p.status === 'Completed');
  };

  const getPointsEarned = (lessonId: number) => {
    if (!student) return 0;
    const progress = student.progress?.find(p => p.lessonId === lessonId);
    return progress?.pointsEarned || 0;
  };

  const filteredLessons = lessons.filter(lesson => {
    const completed = isLessonCompleted(lesson.id);
    const matchesFilter = 
      filter === 'all' || 
      (filter === 'completed' && completed) ||
      (filter === 'pending' && !completed);
    const matchesLanguage = languageFilter === 'all' || lesson.language === languageFilter;
    return matchesFilter && matchesLanguage;
  });

  const uniqueLanguages = Array.from(new Set(lessons.map(l => l.language)));

  if (loading) {
    return <div className="loading">Loading...</div>;
  }

  if (!student) {
    return <div className="error-container">Student not found</div>;
  }

  const totalPointsEarned = student.totalPointsEarned || 0;
  const completedCount = student.progress?.filter(p => p.status === 'Completed').length || 0;

  return (
    <div className="assign-lessons-container">
      <div className="page-header">
        <button 
          className="btn btn-secondary back-button"
          onClick={() => navigate(`/students/${student.id}`)}
        >
          <ArrowLeft size={20} />
          Back to Student
        </button>
        <div className="header-content">
          <div className="student-avatar-large">
            {student.name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)}
          </div>
          <div>
            <h1>Assign Lessons: {student.name}</h1>
            <p>Track completed lessons and award points</p>
          </div>
        </div>
      </div>

      {/* Success/Error Messages */}
      {successMessage && (
        <div className="message message-success">
          <CheckCircle size={20} />
          {successMessage}
        </div>
      )}
      {errorMessage && (
        <div className="message message-error">
          <Circle size={20} />
          {errorMessage}
        </div>
      )}

      {/* Student Stats */}
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-icon stat-icon-trophy">
            <Trophy size={24} />
          </div>
          <div className="stat-content">
            <h3>{totalPointsEarned}</h3>
            <p>Total Points Earned</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon stat-icon-lessons">
            <BookOpen size={24} />
          </div>
          <div className="stat-content">
            <h3>{completedCount}</h3>
            <p>Lessons Completed</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon stat-icon-skill">
            <Star size={24} />
          </div>
          <div className="stat-content">
            <h3>{student.skillLevel}</h3>
            <p>Skill Level</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon stat-icon-avg">
            <Award size={24} />
          </div>
          <div className="stat-content">
            <h3>{completedCount > 0 ? Math.round(totalPointsEarned / completedCount) : 0}</h3>
            <p>Avg Points/Lesson</p>
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="filters-section">
        <div className="filter-group">
          <label>Status:</label>
          <select value={filter} onChange={(e) => setFilter(e.target.value as any)} className="filter-select">
            <option value="all">All Lessons</option>
            <option value="pending">Pending</option>
            <option value="completed">Completed</option>
          </select>
        </div>
        <div className="filter-group">
          <label>Language:</label>
          <select value={languageFilter} onChange={(e) => setLanguageFilter(e.target.value)} className="filter-select">
            <option value="all">All Languages</option>
            {uniqueLanguages.map(lang => (
              <option key={lang} value={lang}>{lang.charAt(0).toUpperCase() + lang.slice(1)}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Lessons List */}
      <div className="lessons-list">
        {filteredLessons.length === 0 ? (
          <div className="empty-state">
            <BookOpen size={64} />
            <h2>No Lessons Found</h2>
            <p>Try adjusting your filters</p>
          </div>
        ) : (
          filteredLessons.map(lesson => {
            const completed = isLessonCompleted(lesson.id);
            const pointsEarned = getPointsEarned(lesson.id);

            return (
              <div key={lesson.id} className={`lesson-card ${completed ? 'completed' : ''}`}>
                <div className="lesson-header">
                  <div className="lesson-status-icon">
                    {completed ? (
                      <CheckCircle size={32} className="icon-completed" />
                    ) : (
                      <Circle size={32} className="icon-pending" />
                    )}
                  </div>
                  <div className="lesson-info">
                    <h3>{lesson.title}</h3>
                    <p>{lesson.description}</p>
                    <div className="lesson-meta">
                      <span className={`difficulty-badge difficulty-${lesson.difficulty.toLowerCase()}`}>
                        {lesson.difficulty}
                      </span>
                      <span className="language-badge">
                        {lesson.language.charAt(0).toUpperCase() + lesson.language.slice(1)}
                      </span>
                      <span className="duration-badge">
                        {lesson.duration} min
                      </span>
                      <span className="points-badge">
                        <Award size={14} />
                        {lesson.points || 0} pts
                      </span>
                    </div>
                  </div>
                </div>

                <div className="lesson-actions">
                  {completed ? (
                    <>
                      <div className="completed-badge">
                        <CheckCircle size={16} />
                        Completed - {pointsEarned} points earned
                      </div>
                      <button
                        className="btn btn-secondary"
                        onClick={() => navigate(`/lessons/${lesson.id}`)}
                      >
                        View Lesson
                      </button>
                    </>
                  ) : (
                    <>
                      <button
                        className="btn btn-primary"
                        onClick={() => handleMarkComplete(lesson.id, lesson.points || 0)}
                      >
                        <CheckCircle size={16} />
                        Mark as Completed (+{lesson.points || 0} pts)
                      </button>
                      <button
                        className="btn btn-secondary"
                        onClick={() => navigate(`/lessons/${lesson.id}`)}
                      >
                        View Lesson
                      </button>
                    </>
                  )}
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}
