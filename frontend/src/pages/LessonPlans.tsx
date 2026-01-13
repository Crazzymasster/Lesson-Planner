import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { lessonPlanService, folderService } from '@/services/api';
import type { LessonPlan, LessonFolder } from '@/types';
import FolderModal from '@/components/FolderModal';
import './LessonPlans.css';

export default function LessonPlans() {
  const [lessons, setLessons] = useState<LessonPlan[]>([]);
  const [folders, setFolders] = useState<LessonFolder[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showFolderModal, setShowFolderModal] = useState(false);
  const [editingFolder, setEditingFolder] = useState<LessonFolder | undefined>(undefined);
  const navigate = useNavigate();

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Load lessons (critical)
      const lessonsResponse = await lessonPlanService.getAll();
      setLessons(lessonsResponse.data);
      
      // Load folders (optional - won't break if folders table doesn't exist yet)
      try {
        const foldersResponse = await folderService.getAll();
        setFolders(foldersResponse.data);
      } catch (folderErr) {
        console.warn('Folders not available yet. Run database/folders-schema.sql to enable folder organization.', folderErr);
        setFolders([]);
      }
    } catch (err) {
      setError('Failed to load lesson plans. Please check your API connection.');
      console.error('Error loading lessons:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: number, title: string) => {
    if (!window.confirm(`Are you sure you want to delete "${title}"?`)) {
      return;
    }
    
    try {
      await lessonPlanService.delete(id);
      await loadData();
    } catch (err) {
      alert('Failed to delete lesson plan');
      console.error('Error deleting lesson:', err);
    }
  };

  const handleCreateFolder = () => {
    setEditingFolder(undefined);
    setShowFolderModal(true);
  };

  const handleEditFolder = (folder: LessonFolder) => {
    setEditingFolder(folder);
    setShowFolderModal(true);
  };

  const handleSaveFolder = async (folderData: Pick<LessonFolder, 'name' | 'description' | 'color' | 'orderIndex'>, lessonIds: number[]) => {
    try {
      if (editingFolder) {
        await folderService.update(editingFolder.id, folderData);
        // Update lessons to be in this folder
        const currentLessonsInFolder = lessons.filter(l => l.folderId === editingFolder.id).map(l => l.id);
        const toAdd = lessonIds.filter(id => !currentLessonsInFolder.includes(id));
        const toRemove = currentLessonsInFolder.filter(id => !lessonIds.includes(id));
        
        for (const lessonId of toAdd) {
          await lessonPlanService.update(lessonId, { folderId: editingFolder.id });
        }
        for (const lessonId of toRemove) {
          await lessonPlanService.update(lessonId, { folderId: null });
        }
      } else {
        const result = await folderService.create(folderData);
        const newFolderId = result.data.id;
        // Add selected lessons to new folder
        for (const lessonId of lessonIds) {
          await lessonPlanService.update(lessonId, { folderId: newFolderId });
        }
      }
      await loadData();
    } catch (err) {
      console.error('Error saving folder:', err);
      throw err; // Re-throw so FolderModal can handle it
    }
  };

  const handleDeleteFolder = async (folderId: number, folderName: string) => {
    if (!window.confirm(`Delete folder "${folderName}"? Lessons inside will become uncategorized.`)) {
      return;
    }
    
    try {
      await folderService.delete(folderId);
      await loadData();
    } catch (err) {
      alert('Failed to delete folder');
      console.error('Error deleting folder:', err);
    }
  };

  const handleMoveToFolder = async (lessonId: number, folderId: number | null) => {
    try {
      await lessonPlanService.update(lessonId, { folderId });
      await loadData();
    } catch (err) {
      alert('Failed to move lesson');
      console.error('Error moving lesson:', err);
    }
  };

  const getLessonsInFolder = (folderId: number | null) => {
    return lessons.filter(lesson => lesson.folderId === folderId);
  };

  const uncategorizedLessons = getLessonsInFolder(null);

  if (loading) {
    return (
      <div role="status" aria-live="polite" style={{ padding: '2rem' }}>
        <p>Loading lesson plans...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div role="alert" aria-live="assertive" style={{ padding: '2rem', color: '#d32f2f' }}>
        <h2>Error</h2>
        <p>{error}</p>
        <button onClick={loadData} style={{ marginTop: '1rem' }}>
          Try Again
        </button>
      </div>
    );
  }

  return (
    <div className="lesson-plans-container">
      <header className="lesson-plans-header">
        <h1>Lesson Plans</h1>
        <div className="header-actions">
          <button
            onClick={handleCreateFolder}
            className="btn-create-folder"
          >
            + New Folder
          </button>
          <button
            onClick={() => navigate('/lessons/new')}
            className="btn-create-lesson"
          >
            + New Lesson Plan
          </button>
        </div>
      </header>

      {lessons.length === 0 && folders.length === 0 ? (
        <div className="empty-state">
          <p className="empty-message">No lesson plans yet</p>
          <p className="empty-hint">Create your first lesson plan to get started!</p>
        </div>
      ) : (
        <div className="folders-grid">
          {folders.map(folder => {
            const folderLessons = getLessonsInFolder(folder.id);
            
            return (
              <div 
                key={folder.id} 
                className="folder-box"
                onClick={() => navigate(`/folders/${folder.id}`)}
              >
                <div 
                  className="folder-icon"
                  style={{ '--folder-color': folder.color } as React.CSSProperties}
                >
                  <div className="folder-tab"></div>
                  <div className="folder-body"></div>
                </div>
                <div className="folder-box-content">
                  <h2 className="folder-box-name">{folder.name}</h2>
                  {folder.description && (
                    <p className="folder-box-description">{folder.description}</p>
                  )}
                  <div className="folder-box-count">{folderLessons.length} lesson{folderLessons.length !== 1 ? 's' : ''}</div>
                </div>
                <div className="folder-box-actions" onClick={(e) => e.stopPropagation()}>
                  <button
                    onClick={() => handleEditFolder(folder)}
                    className="folder-action-btn"
                    title="Edit"
                  >
                    ✏️
                  </button>
                  <button
                    onClick={() => handleDeleteFolder(folder.id, folder.name)}
                    className="folder-action-btn"
                    title="Delete"
                  >
                    🗑️
                  </button>
                </div>
              </div>
            );
          })}

          {uncategorizedLessons.length > 0 && (
            <div 
              className="folder-box folder-box-uncategorized"
              onClick={() => navigate('/folders/uncategorized')}
            >
              <div 
                className="folder-icon"
                style={{ '--folder-color': '#757575' } as React.CSSProperties}
              >
                <div className="folder-tab"></div>
                <div className="folder-body"></div>
              </div>
              <div className="folder-box-content">
                <h2 className="folder-box-name">Uncategorized</h2>
                <p className="folder-box-description">Lessons not in any folder</p>
                <div className="folder-box-count">{uncategorizedLessons.length} lesson{uncategorizedLessons.length !== 1 ? 's' : ''}</div>
              </div>
            </div>
          )}
        </div>
      )}

      <FolderModal
        isOpen={showFolderModal}
        onClose={() => setShowFolderModal(false)}
        onSave={handleSaveFolder}
        folder={editingFolder}
        allLessons={lessons}
      />
    </div>
  );
}
