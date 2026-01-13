import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { studentService, studentGroupService } from '@/services/api';
import type { Student, StudentGroup } from '@/types';
import { Users, UserPlus, Search, Book, Code, TrendingUp, ArrowLeft, Award, Clock, Target } from 'lucide-react';
import './StudentGroups.css';

export default function StudentGroups() {
  const navigate = useNavigate();
  const [students, setStudents] = useState<Student[]>([]);
  const [groups, setGroups] = useState<StudentGroup[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedGroup, setSelectedGroup] = useState<StudentGroup | null>(null);
  const [filterLevel, setFilterLevel] = useState<string>('all');

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      const [studentsRes, groupsRes] = await Promise.all([
        studentService.getAll(),
        studentGroupService.getAll()
      ]);
      setStudents(studentsRes.data);
      setGroups(groupsRes.data);
    } catch (err: any) {
      setError(err.response?.data?.error || 'Failed to load students');
      console.error('Error loading students:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: number, name: string) => {
    if (!confirm(`Are you sure you want to remove ${name}? This will not delete their progress data.`)) {
      return;
    }

    try {
      await studentService.delete(id);
      setStudents(students.filter(s => s.id !== id));
    } catch (err: any) {
      alert(err.response?.data?.error || 'Failed to remove student');
    }
  };

  // Get students for the selected group
  const getGroupStudents = () => {
    if (!selectedGroup) return [];
    return students.filter(student => student.groupId === selectedGroup.id);
  };

  // Filter students within the selected group
  const filteredStudents = selectedGroup ? getGroupStudents().filter(student => {
    const matchesSearch = student.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesLevel = filterLevel === 'all' || student.skillLevel === filterLevel;
    return matchesSearch && matchesLevel;
  }) : [];

  const getProgressPercentage = (student: Student) => {
    if (!student.totalLessons || student.totalLessons === 0) return 0;
    return Math.round(((student.completedLessons || 0) / student.totalLessons) * 100);
  };

  // Calculate group analytics
  const getGroupAnalytics = (group: StudentGroup) => {
    const groupStudents = students.filter(s => s.groupId === group.id);
    const totalLessons = groupStudents.reduce((sum, s) => sum + (s.completedLessons || 0), 0);
    const totalLanguages = groupStudents.reduce((sum, s) => sum + (s.languageCount || 0), 0);
    const avgProgress = groupStudents.length > 0
      ? Math.round(groupStudents.reduce((sum, s) => sum + getProgressPercentage(s), 0) / groupStudents.length)
      : 0;
    
    return {
      studentCount: groupStudents.length,
      totalLessons,
      totalLanguages,
      avgProgress
    };
  };

  // Calculate analytics for selected group students
  const getSelectedGroupAnalytics = () => {
    if (!selectedGroup) return null;
    
    const groupStudents = getGroupStudents();
    const totalCompleted = groupStudents.reduce((sum, s) => sum + (s.completedLessons || 0), 0);
    const totalAssigned = groupStudents.reduce((sum, s) => sum + (s.totalLessons || 0), 0);
    const avgProgress = groupStudents.length > 0
      ? Math.round(groupStudents.reduce((sum, s) => sum + getProgressPercentage(s), 0) / groupStudents.length)
      : 0;
    
    const skillBreakdown = {
      beginner: groupStudents.filter(s => s.skillLevel === 'Beginner').length,
      intermediate: groupStudents.filter(s => s.skillLevel === 'Intermediate').length,
      advanced: groupStudents.filter(s => s.skillLevel === 'Advanced').length,
    };

    return {
      totalCompleted,
      totalAssigned,
      avgProgress,
      skillBreakdown,
      studentCount: groupStudents.length
    };
  };

  if (loading) {
    return <div className="loading">Loading data...</div>;
  }

  if (error) {
    return (
      <div className="error-container">
        <h2>Error</h2>
        <p>{error}</p>
        <button className="btn btn-primary" onClick={loadData}>
          Try Again
        </button>
      </div>
    );
  }

  // If a group is selected, show students in that group
  if (selectedGroup) {
    const analytics = getSelectedGroupAnalytics()!;
    
    return (
      <div className="students-container">
        <div className="students-header">
          <div className="header-content">
            <button 
              className="btn btn-secondary back-button"
              onClick={() => {
                setSelectedGroup(null);
                setSearchTerm('');
                setFilterLevel('all');
              }}
            >
              <ArrowLeft size={20} />
              Back to Groups
            </button>
            <div className="header-icon">
              <Users size={40} />
            </div>
            <div>
              <h1>{selectedGroup.name}</h1>
              <p>{selectedGroup.description}</p>
            </div>
          </div>
          <button 
            className="btn btn-primary"
            onClick={() => navigate('/students/new')}
          >
            <UserPlus size={20} />
            Add Student
          </button>
        </div>

        {/* Group Analytics */}
        <div className="stats-grid">
          <div className="stat-card">
            <div className="stat-icon stat-icon-students">
              <Users size={24} />
            </div>
            <div className="stat-content">
              <h3>{analytics.studentCount}</h3>
              <p>Students in Group</p>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-icon stat-icon-lessons">
              <Book size={24} />
            </div>
            <div className="stat-content">
              <h3>{analytics.totalCompleted} / {analytics.totalAssigned}</h3>
              <p>Lessons Completed</p>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-icon stat-icon-groups">
              <TrendingUp size={24} />
            </div>
            <div className="stat-content">
              <h3>{analytics.avgProgress}%</h3>
              <p>Average Progress</p>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-icon stat-icon-languages">
              <Award size={24} />
            </div>
            <div className="stat-content">
              <h3>{analytics.skillBreakdown.beginner}B / {analytics.skillBreakdown.intermediate}I / {analytics.skillBreakdown.advanced}A</h3>
              <p>Skill Distribution</p>
            </div>
          </div>
        </div>

        {/* Filters for students */}
        <div className="filters-section">
          <div className="search-box">
            <Search size={20} />
            <input
              type="text"
              placeholder="Search students..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="search-input"
            />
          </div>
          <div className="filter-group">
            <label htmlFor="levelFilter">Skill Level:</label>
            <select
              id="levelFilter"
              value={filterLevel}
              onChange={(e) => setFilterLevel(e.target.value)}
              className="filter-select"
            >
              <option value="all">All Levels</option>
              <option value="Beginner">Beginner</option>
              <option value="Intermediate">Intermediate</option>
              <option value="Advanced">Advanced</option>
            </select>
          </div>
        </div>

        {/* Students Grid */}
        {filteredStudents.length === 0 ? (
          <div className="empty-state">
            <Users size={64} />
            <h2>No Students Found</h2>
            <p>
              {searchTerm || filterLevel !== 'all'
                ? 'Try adjusting your filters'
                : `No students in ${selectedGroup.name} yet`}
            </p>
            {!searchTerm && filterLevel === 'all' && (
              <button
                className="btn btn-primary"
                onClick={() => navigate('/students/new')}
              >
                <UserPlus size={20} />
                Add Student to Group
              </button>
            )}
          </div>
        ) : (
          <div className="students-grid">
            {filteredStudents.map(student => {
              const progressPercent = getProgressPercentage(student);
              
              return (
                <div key={student.id} className="student-card">
                  <div className="student-card-header">
                    <div className="student-avatar">
                      {student.name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)}
                    </div>
                    <div className="student-info">
                      <h3>{student.name}</h3>
                      <div className="student-meta">
                        <span className={`skill-badge skill-${student.skillLevel.toLowerCase()}`}>
                          {student.skillLevel}
                        </span>
                        {student.age > 0 && (
                          <span className="age-badge">{student.age} years old</span>
                        )}
                      </div>
                    </div>
                  </div>

                  <div className="student-stats">
                    <div className="stat-item">
                      <Code size={16} />
                      <span>{student.languageCount || 0} {student.languageCount === 1 ? 'Language' : 'Languages'}</span>
                    </div>
                    <div className="stat-item">
                      <Book size={16} />
                      <span>{student.completedLessons || 0} / {student.totalLessons || 0} Lessons</span>
                    </div>
                  </div>

                  {student.totalLessons && student.totalLessons > 0 && (
                    <div className="progress-section">
                      <div className="progress-header">
                        <span>Progress</span>
                        <span className="progress-percent">{progressPercent}%</span>
                      </div>
                      <div className="progress-bar">
                        <div 
                          className="progress-fill" 
                          style={{ width: `${progressPercent}%` }}
                        />
                      </div>
                    </div>
                  )}

                  <div className="student-actions">
                    <button
                      className="btn btn-primary btn-sm"
                      onClick={() => navigate(`/students/${student.id}`)}
                    >
                      <TrendingUp size={16} />
                      View Details
                    </button>
                    <button
                      className="btn btn-secondary btn-sm"
                      onClick={() => navigate(`/students/${student.id}/edit`)}
                    >
                      Edit
                    </button>
                    <button
                      className="btn btn-danger btn-sm"
                      onClick={() => handleDelete(student.id, student.name)}
                    >
                      Remove
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    );
  }

  // Default view: Show all groups
  return (
    <div className="students-container">
      <div className="students-header">
        <div className="header-content">
          <div className="header-icon">
            <Users size={40} />
          </div>
          <div>
            <h1>Student Groups</h1>
            <p>Select a group to view and compare students</p>
          </div>
        </div>
        <button 
          className="btn btn-primary"
          onClick={() => navigate('/groups/new')}
        >
          <Users size={20} />
          Create Group
        </button>
      </div>

      {/* Overall Stats */}
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-icon stat-icon-groups">
            <Users size={24} />
          </div>
          <div className="stat-content">
            <h3>{groups.length}</h3>
            <p>Total Groups</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon stat-icon-students">
            <Users size={24} />
          </div>
          <div className="stat-content">
            <h3>{students.length}</h3>
            <p>Total Students</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon stat-icon-languages">
            <Code size={24} />
          </div>
          <div className="stat-content">
            <h3>{students.reduce((sum, s) => sum + (s.languageCount || 0), 0)}</h3>
            <p>Languages Learning</p>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon stat-icon-lessons">
            <Book size={24} />
          </div>
          <div className="stat-content">
            <h3>{students.reduce((sum, s) => sum + (s.completedLessons || 0), 0)}</h3>
            <p>Lessons Completed</p>
          </div>
        </div>
      </div>

      {/* Groups Grid */}
      {groups.length === 0 ? (
        <div className="empty-state">
          <Users size={64} />
          <h2>No Groups Found</h2>
          <p>Create your first student group to get started</p>
        </div>
      ) : (
        <div className="groups-grid">
          {groups.map(group => {
            const analytics = getGroupAnalytics(group);
            
            return (
              <div 
                key={group.id} 
                className="group-card"
                onClick={() => setSelectedGroup(group)}
              >
                <div className="group-card-header">
                  <div className="group-icon">
                    <Users size={32} />
                  </div>
                  <div className="group-info">
                    <h3>{group.name}</h3>
                    <p>{group.description}</p>
                  </div>
                </div>

                <div className="group-stats">
                  <div className="group-stat-item">
                    <Users size={18} />
                    <div>
                      <span className="stat-value">{analytics.studentCount}</span>
                      <span className="stat-label">Students</span>
                    </div>
                  </div>
                  <div className="group-stat-item">
                    <Book size={18} />
                    <div>
                      <span className="stat-value">{analytics.totalLessons}</span>
                      <span className="stat-label">Lessons</span>
                    </div>
                  </div>
                  <div className="group-stat-item">
                    <Code size={18} />
                    <div>
                      <span className="stat-value">{analytics.totalLanguages}</span>
                      <span className="stat-label">Languages</span>
                    </div>
                  </div>
                  <div className="group-stat-item">
                    <TrendingUp size={18} />
                    <div>
                      <span className="stat-value">{analytics.avgProgress}%</span>
                      <span className="stat-label">Avg Progress</span>
                    </div>
                  </div>
                </div>

                <div className="group-footer">
                  <span className={`skill-badge skill-${group.skillLevel.toLowerCase()}`}>
                    {group.skillLevel}
                  </span>
                  <span className="view-link">
                    View Group →
                  </span>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

