import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { studentService } from '../services/api';
import type { Student } from '../types';
import { ArrowLeft, Mail, Calendar, BookOpen, Code, TrendingUp, Clock, Award } from 'lucide-react';
import './StudentDetail.css';

const StudentDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [student, setStudent] = useState<Student | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (id) {
      loadStudent(parseInt(id));
    }
  }, [id]);

  const loadStudent = async (studentId: number) => {
    try {
      setLoading(true);
      const response = await studentService.getById(studentId);
      setStudent(response.data);
    } catch (err: any) {
      setError(err.response?.data?.error || 'Failed to load student details');
      console.error('Error loading student:', err);
    } finally {
      setLoading(false);
    }
  };

  const getProficiencyLevel = (level: string): number => {
    const levels: { [key: string]: number } = {
      'Beginner': 25,
      'Intermediate': 50,
      'Advanced': 75,
      'Expert': 100
    };
    return levels[level] || 0;
  };

  const getLanguagePoints = (language: string): number => {
    if (!student?.progress) return 0;
    return student.progress
      .filter(p => p.lessonLanguage?.toLowerCase() === language.toLowerCase() && p.status === 'Completed')
      .reduce((sum, p) => sum + (p.pointsEarned || 0), 0);
  };

  const getProficiencyProgress = (points: number, currentLevel: string): { level: string; percentage: number; nextLevel: string; pointsToNext: number } => {
    // Use the database proficiency level as source of truth
    // Beginner: 0-50 points, Intermediate: 51-150 points, Advanced: 151-300 points, Expert: 301+ points
    
    if (currentLevel === 'Expert') {
      return { level: 'Expert', percentage: 100, nextLevel: '', pointsToNext: 0 };
    } else if (currentLevel === 'Advanced') {
      const progress = ((points - 151) / 150) * 100; // 150 points to reach Expert
      return { level: 'Advanced', percentage: Math.min(Math.max(progress, 0), 100), nextLevel: 'Expert', pointsToNext: Math.max(301 - points, 0) };
    } else if (currentLevel === 'Intermediate') {
      const progress = ((points - 51) / 100) * 100; // 100 points to reach Advanced
      return { level: 'Intermediate', percentage: Math.min(Math.max(progress, 0), 100), nextLevel: 'Advanced', pointsToNext: Math.max(151 - points, 0) };
    } else {
      const progress = (points / 50) * 100; // 50 points to reach Intermediate
      return { level: 'Beginner', percentage: Math.min(Math.max(progress, 0), 100), nextLevel: 'Intermediate', pointsToNext: Math.max(51 - points, 0) };
    }
  };

  const getProficiencyColor = (level: string): string => {
    const colors: { [key: string]: string } = {
      'Beginner': '#4caf50',      // Green
      'Intermediate': '#2196f3',  // Blue
      'Advanced': '#9c27b0',      // Purple
      'Expert': '#ff9800'         // Orange
    };
    return colors[level] || '#4caf50';
  };

  const getStatusColor = (status: string): string => {
    const colors: { [key: string]: string } = {
      'Not Started': '#757575',
      'In Progress': '#2196f3',
      'Completed': '#4caf50',
      'Mastered': '#ff9800'
    };
    return colors[status] || '#757575';
  };

  const formatDate = (dateString: string): string => {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  };

  if (loading) {
    return <div className="loading">Loading student details...</div>;
  }

  if (error || !student) {
    return (
      <div className="error-container">
        <h2>Error</h2>
        <p>{error || 'Student not found'}</p>
        <button className="btn-primary" onClick={() => navigate('/students')}>
          Back to Students
        </button>
      </div>
    );
  }

  return (
    <div className="student-detail-page">
      <div className="detail-header">
        <button className="btn-back" onClick={() => navigate('/students')}>
          <ArrowLeft size={20} />
          Back to Students
        </button>
        <div className="header-actions">
          <button className="btn-secondary" onClick={() => navigate(`/students/${id}/lessons`)}>
            <BookOpen size={20} />
            Assign Lessons
          </button>
          <button className="btn-edit" onClick={() => navigate(`/students/${id}/edit`)}>
            Edit Student
          </button>
        </div>
      </div>

      {/* Student Info Card */}
      <div className="student-info-card">
        <div className="student-avatar-large">
          {student?.name?.charAt(0).toUpperCase() || '?'}
        </div>
        <div className="student-info-content">
          <h1>{student?.name || 'Unknown'}</h1>
          <div className="info-badges">
            <span className={`skill-badge skill-${student?.skillLevel?.toLowerCase() || 'beginner'}`}>
              {student?.skillLevel || 'Unknown'}
            </span>
            {student?.groupName && (
              <span className="group-badge">{student.groupName}</span>
            )}
            {student?.age && (
              <span className="age-badge">{student.age} years old</span>
            )}
          </div>
          <div className="contact-info">
            {student.email && (
              <div className="contact-item">
                <Mail size={16} />
                <a href={`mailto:${student.email}`}>{student.email}</a>
              </div>
            )}
            {student.parentEmail && (
              <div className="contact-item">
                <Mail size={16} />
                <span>Parent: <a href={`mailto:${student.parentEmail}`}>{student.parentEmail}</a></span>
              </div>
            )}
          </div>
          {student.notes && (
            <div className="student-notes">
              <p>{student.notes}</p>
            </div>
          )}
        </div>
      </div>

      {/* Languages & Proficiency */}
      <div className="section-card">
        <div className="section-header">
          <h2>
            <Code size={24} />
            Languages & Proficiency
          </h2>
          <span className="language-count">{student.languages?.length || 0} languages</span>
        </div>
        
        {student.languages && student.languages.length > 0 ? (
          <div className="languages-grid">
            {student.languages.map((lang) => {
              const languagePoints = getLanguagePoints(lang.language);
              const proficiencyData = getProficiencyProgress(languagePoints, lang.proficiencyLevel);
              
              return (
              <div key={lang.id} className="language-card">
                <div className="language-header">
                  <h3>{lang.language}</h3>
                  <span className="proficiency-label">{lang.proficiencyLevel}</span>
                </div>
                
                <div className="proficiency-bar-container">
                  <div 
                    className="proficiency-bar-fill"
                    style={{
                      width: `${proficiencyData.percentage}%`,
                      background: `linear-gradient(90deg, ${getProficiencyColor(lang.proficiencyLevel)}CC, ${getProficiencyColor(lang.proficiencyLevel)})`
                    }}
                  >
                    <span className="proficiency-percentage">
                      {Math.round(proficiencyData.percentage)}%
                    </span>
                  </div>
                </div>
                
                <div className="points-display">
                  <Award size={16} style={{ color: '#f59e0b' }} />
                  <span className="points-text">
                    {languagePoints} points
                    {proficiencyData.nextLevel && proficiencyData.pointsToNext > 0 && (
                      <span className="points-next"> • {proficiencyData.pointsToNext} to {proficiencyData.nextLevel}</span>
                    )}
                  </span>
                </div>
                
                <div className="language-meta">
                  <div className="meta-item">
                    <Calendar size={14} />
                    <span>Started: {formatDate(lang.startedAt)}</span>
                  </div>
                  <div className="meta-item">
                    <Clock size={14} />
                    <span>Last practiced: {formatDate(lang.lastPracticedAt)}</span>
                  </div>
                </div>
                
                {lang.notes && (
                  <div className="language-notes">
                    <p>{lang.notes}</p>
                  </div>
                )}
              </div>
            );
            })}
          </div>
        ) : (
          <div className="empty-state">
            <Code size={48} />
            <p>No languages added yet</p>
          </div>
        )}
      </div>

      {/* Lesson History */}
      <div className="section-card">
        <div className="section-header">
          <h2>
            <BookOpen size={24} />
            Lesson History
          </h2>
          <div className="progress-summary">
            <span className="completed-count">
              {student.completedLessons || 0} / {student.totalLessons || 0} completed
            </span>
            {student.totalLessons > 0 && (
              <span className="completion-percentage">
                ({Math.round(((student.completedLessons || 0) / student.totalLessons) * 100)}%)
              </span>
            )}
          </div>
        </div>
        
        {student.progress && student.progress.length > 0 ? (
          <div className="lesson-history-list">
            {student.progress.map((prog) => (
              <div key={prog.id} className="lesson-history-item">
                <div className="lesson-main-info">
                  <div className="lesson-title-section">
                    <h3>{prog.lessonTitle}</h3>
                    <div className="lesson-meta-tags">
                      <span className="language-tag">{prog.lessonLanguage}</span>
                      <span className="difficulty-tag">{prog.lessonDifficulty}</span>
                      <span 
                        className="status-tag"
                        style={{ 
                          backgroundColor: `${getStatusColor(prog.status)}15`,
                          color: getStatusColor(prog.status),
                          borderColor: getStatusColor(prog.status)
                        }}
                      >
                        {prog.status}
                      </span>
                    </div>
                  </div>
                  
                  <div className="lesson-stats">
                    {prog.pointsEarned !== null && prog.pointsEarned !== undefined && prog.pointsEarned > 0 && (
                      <div className="stat-item">
                        <Award size={18} style={{ color: '#f59e0b' }} />
                        <span className="stat-value">{prog.pointsEarned} pts</span>
                      </div>
                    )}
                    {prog.timeSpentMinutes > 0 && (
                      <div className="stat-item">
                        <Clock size={18} style={{ color: '#2196f3' }} />
                        <span className="stat-value">{prog.timeSpentMinutes} min</span>
                      </div>
                    )}
                    {prog.completedAt && (
                      <div className="stat-item">
                        <Calendar size={18} style={{ color: '#4caf50' }} />
                        <span className="stat-value">{formatDate(prog.completedAt)}</span>
                      </div>
                    )}
                  </div>
                </div>
                
                {prog.notes && (
                  <div className="lesson-notes">
                    <p>{prog.notes}</p>
                  </div>
                )}
                
                {prog.score !== null && prog.score !== undefined && (
                  <div className="score-bar-container">
                    <div 
                      className="score-bar-fill"
                      style={{ 
                        width: `${prog.score}%`,
                        backgroundColor: prog.score >= 90 ? '#4caf50' : prog.score >= 70 ? '#2196f3' : '#ff9800'
                      }}
                    />
                  </div>
                )}
              </div>
            ))}
          </div>
        ) : (
          <div className="empty-state">
            <BookOpen size={48} />
            <p>No lesson history yet</p>
            <small>Completed lessons will appear here</small>
          </div>
        )}
      </div>
    </div>
  );
};

export default StudentDetail;
