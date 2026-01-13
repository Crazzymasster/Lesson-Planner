import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { lessonPlanService, folderService } from '@/services/api';
import type { LessonPlan, LessonFolder } from '@/types';
import './FolderDetail.css';

export default function FolderDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [folder, setFolder] = useState<LessonFolder | null>(null);
  const [lessons, setLessons] = useState<LessonPlan[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadFolderData();
  }, [id]);

  const loadFolderData = async () => {
    if (!id) return;
    
    try {
      setLoading(true);
      
      if (id === 'uncategorized') {
        // Handle uncategorized lessons (folderId is null)
        const lessonsResponse = await lessonPlanService.getAll();
        setFolder({
          id: 0,
          name: 'Uncategorized',
          description: 'Lessons not in any folder',
          color: '#757575',
          lessonCount: 0
        });
        setLessons(lessonsResponse.data.filter((l: LessonPlan) => l.folderId === null || l.folderId === undefined));
      } else {
        // Handle regular folders
        const [folderResponse, lessonsResponse] = await Promise.all([
          folderService.getById(parseInt(id)),
          lessonPlanService.getAll()
        ]);
        
        setFolder(folderResponse.data);
        setLessons(lessonsResponse.data.filter((l: LessonPlan) => l.folderId === parseInt(id)));
      }
    } catch (err) {
      console.error('Error loading folder:', err);
      alert('Failed to load folder');
      navigate('/lessons');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (lessonId: number, title: string) => {
    if (!window.confirm(`Are you sure you want to delete "${title}"?`)) {
      return;
    }
    
    try {
      await lessonPlanService.delete(lessonId);
      await loadFolderData();
    } catch (err) {
      alert('Failed to delete lesson plan');
      console.error('Error deleting lesson:', err);
    }
  };

  if (loading) {
    return <div className="folder-detail-loading">Loading folder...</div>;
  }

  if (!folder) {
    return <div className="folder-detail-error">Folder not found</div>;
  }

  return (
    <div className="folder-detail-container">
      <div 
        className="folder-detail-header"
        style={{ 
          '--folder-color': folder.color,
          background: `linear-gradient(135deg, ${folder.color} 0%, ${folder.color}dd 100%)`
        } as React.CSSProperties}
      >
        <button onClick={() => navigate('/lessons')} className="folder-back-btn">
          ← Back to Folders
        </button>
        <div className="folder-detail-info">
          <h1 className="folder-detail-title">{folder.name}</h1>
          {folder.description && (
            <p className="folder-detail-description">{folder.description}</p>
          )}
          <div className="folder-detail-count">{lessons.length} lesson{lessons.length !== 1 ? 's' : ''}</div>
        </div>
      </div>

      <div className="folder-detail-content">
        {lessons.length === 0 ? (
          <div className="folder-detail-empty">
            <p>No lessons in this folder yet</p>
            <button onClick={() => navigate('/lessons/new')} className="btn-add-lesson">
              + Add Lesson
            </button>
          </div>
        ) : (
          <div className="folder-lessons-list">
            {lessons.map((lesson) => (
              <article key={lesson.id} className="folder-lesson-card">
                <div className="lesson-card-header">
                  <h3>{lesson.title}</h3>
                  <div className="lesson-card-meta">
                    {lesson.difficulty && <span className="lesson-badge">{lesson.difficulty}</span>}
                    {lesson.duration && <span className="lesson-badge">{lesson.duration} min</span>}
                    {lesson.targetAge && <span className="lesson-badge">{lesson.targetAge}</span>}
                  </div>
                </div>

                {lesson.description && (
                  <p className="lesson-card-description">{lesson.description}</p>
                )}

                <div className="lesson-card-actions">
                  <button
                    onClick={() => navigate(`/lessons/${lesson.id}`)}
                    className="lesson-btn lesson-btn-primary"
                  >
                    View Details
                  </button>
                  <button
                    onClick={() => navigate(`/lessons/${lesson.id}/edit`)}
                    className="lesson-btn lesson-btn-secondary"
                  >
                    Edit
                  </button>
                  <button
                    onClick={() => handleDelete(lesson.id, lesson.title)}
                    className="lesson-btn lesson-btn-danger"
                  >
                    Delete
                  </button>
                </div>
              </article>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
