import { useState, useEffect } from 'react';
import type { LessonFolder, LessonPlan } from '@/types';
import './FolderModal.css';

type FolderFormData = Pick<LessonFolder, 'name' | 'description' | 'color' | 'orderIndex'>;

interface FolderModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (folder: FolderFormData, lessonIds: number[]) => Promise<void>;
  folder?: LessonFolder;
  allLessons: LessonPlan[];
}

const FOLDER_COLORS = [
  { name: 'Blue', value: '#1A237E' },
  { name: 'Red', value: '#c62828' },
  { name: 'Green', value: '#2e7d32' },
  { name: 'Orange', value: '#ef6c00' },
  { name: 'Purple', value: '#6a1b9a' },
  { name: 'Teal', value: '#00695c' },
  { name: 'Pink', value: '#ad1457' },
  { name: 'Indigo', value: '#283593' },
];

export default function FolderModal({ isOpen, onClose, onSave, folder, allLessons }: FolderModalProps) {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [color, setColor] = useState('#1A237E');
  const [saving, setSaving] = useState(false);
  const [selectedLessons, setSelectedLessons] = useState<Set<number>>(new Set());

  useEffect(() => {
    if (folder) {
      setName(folder.name);
      setDescription(folder.description || '');
      setColor(folder.color || '#1A237E');
      // Select lessons that are already in this folder
      const lessonsInFolder = new Set(
        allLessons.filter(l => l.folderId === folder.id).map(l => l.id)
      );
      setSelectedLessons(lessonsInFolder);
    } else {
      setName('');
      setDescription('');
      setColor('#1A237E');
      setSelectedLessons(new Set());
    }
  }, [folder, isOpen, allLessons]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!name.trim()) {
      alert('Please enter a folder name');
      return;
    }

    try {
      setSaving(true);
      await onSave({
        name: name.trim(),
        description: description.trim(),
        color,
        orderIndex: folder?.orderIndex || 0,
      }, Array.from(selectedLessons));
      onClose();
    } catch (err) {
      alert('Failed to save folder');
      console.error('Error saving folder:', err);
    } finally {
      setSaving(false);
    }
  };

  const toggleLesson = (lessonId: number) => {
    setSelectedLessons(prev => {
      const newSet = new Set(prev);
      if (newSet.has(lessonId)) {
        newSet.delete(lessonId);
      } else {
        newSet.add(lessonId);
      }
      return newSet;
    });
  };

  if (!isOpen) return null;

  return (
    <div className="folder-modal-overlay" onClick={onClose}>
      <div className="folder-modal-content" onClick={(e) => e.stopPropagation()}>
        <header className="folder-modal-header">
          <h2>{folder ? 'Edit Folder' : 'Create New Folder'}</h2>
          <button
            onClick={onClose}
            className="folder-modal-close"
            aria-label="Close modal"
          >
            ×
          </button>
        </header>

        <form onSubmit={handleSubmit} className="folder-modal-form">
          <div className="folder-form-group">
            <label htmlFor="folder-name">Folder Name *</label>
            <input
              id="folder-name"
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="e.g., Python Basics, Advanced Topics"
              required
              maxLength={100}
            />
          </div>

          <div className="folder-form-group">
            <label htmlFor="folder-description">Description</label>
            <textarea
              id="folder-description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Optional description for this folder"
              rows={3}
              maxLength={500}
            />
          </div>

          <div className="folder-form-group">
            <label>Folder Color</label>
            <div className="folder-color-grid">
              {FOLDER_COLORS.map((colorOption) => (
                <button
                  key={colorOption.value}
                  type="button"
                  className={`folder-color-option ${color === colorOption.value ? 'selected' : ''}`}
                  style={{ backgroundColor: colorOption.value }}
                  onClick={() => setColor(colorOption.value)}
                  aria-label={`Select ${colorOption.name}`}
                  title={colorOption.name}
                />
              ))}
            </div>
          </div>

          <div className="folder-form-group">
            <label>Lessons in this Folder</label>
            <div className="folder-lessons-grid">
              {allLessons.length === 0 ? (
                <p className="no-lessons-hint">No lessons available yet</p>
              ) : (
                allLessons.map(lesson => (
                  <div
                    key={lesson.id}
                    className={`lesson-folder-box ${selectedLessons.has(lesson.id) ? 'selected' : ''}`}
                    style={{
                      '--box-color': color,
                      '--box-color-light': color + '15'
                    } as React.CSSProperties}
                    onClick={() => toggleLesson(lesson.id)}
                  >
                    <div className="lesson-folder-icon">📄</div>
                    <div className="lesson-folder-content">
                      <h4 className="lesson-folder-title">{lesson.title}</h4>
                      <div className="lesson-folder-meta">
                        <span className="lesson-folder-badge">{lesson.difficulty}</span>
                        <span className="lesson-folder-badge">{lesson.duration}min</span>
                        {lesson.language && (
                          <span className="lesson-folder-badge">{lesson.language}</span>
                        )}
                      </div>
                    </div>
                    <div className="lesson-folder-check">
                      {selectedLessons.has(lesson.id) ? '✓' : ''}
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>

          <div className="folder-modal-actions">
            <button
              type="button"
              onClick={onClose}
              className="folder-btn-cancel"
              disabled={saving}
            >
              Cancel
            </button>
            <button
              type="submit"
              className="folder-btn-save"
              disabled={saving}
            >
              {saving ? 'Saving...' : folder ? 'Save Changes' : 'Create Folder'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
