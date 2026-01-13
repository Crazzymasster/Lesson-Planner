import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { studentService, studentGroupService } from '../services/api';
import type { StudentGroup } from '../types';
import './CreateStudent.css';

interface LanguageInput {
  language: string;
  proficiencyLevel: 'Beginner' | 'Intermediate' | 'Advanced' | 'Expert';
}

const CreateStudent: React.FC = () => {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const isEditMode = !!id;
  const [loading, setLoading] = useState(false);
  const [loadingData, setLoadingData] = useState(isEditMode);
  const [groups, setGroups] = useState<StudentGroup[]>([]);
  
  const [formData, setFormData] = useState({
    name: '',
    age: '',
    skillLevel: 'Beginner' as 'Beginner' | 'Intermediate' | 'Advanced',
    groupId: '',
    email: '',
    parentEmail: '',
    notes: ''
  });

  const [languages, setLanguages] = useState<LanguageInput[]>([
    { language: '', proficiencyLevel: 'Beginner' }
  ]);

  useEffect(() => {
    loadGroups();
    if (isEditMode && id) {
      loadStudentData(parseInt(id));
    }
  }, [id]);

  const loadStudentData = async (studentId: number) => {
    try {
      setLoadingData(true);
      const response = await studentService.getById(studentId);
      const student = response.data;
      
      // Populate form data
      setFormData({
        name: student.name || '',
        age: student.age ? student.age.toString() : '',
        skillLevel: student.skillLevel || 'Beginner',
        groupId: student.groupId ? student.groupId.toString() : '',
        email: student.email || '',
        parentEmail: student.parentEmail || '',
        notes: student.notes || ''
      });
      
      // Populate languages
      if (student.languages && student.languages.length > 0) {
        setLanguages(student.languages.map(lang => ({
          language: lang.language,
          proficiencyLevel: lang.proficiencyLevel
        })));
      }
    } catch (error) {
      console.error('Error loading student data:', error);
      alert('Failed to load student data');
      navigate('/students');
    } finally {
      setLoadingData(false);
    }
  };

  const loadGroups = async () => {
    try {
      const response = await studentGroupService.getAll();
      setGroups(response.data || []);
    } catch (error) {
      console.error('Error loading groups:', error);
      setGroups([]);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleLanguageChange = (index: number, field: keyof LanguageInput, value: string) => {
    const updated = [...languages];
    updated[index] = { ...updated[index], [field]: value };
    setLanguages(updated);
  };

  const addLanguage = () => {
    setLanguages([...languages, { language: '', proficiencyLevel: 'Beginner' }]);
  };

  const removeLanguage = (index: number) => {
    if (languages.length > 1) {
      setLanguages(languages.filter((_, i) => i !== index));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const studentData = {
        ...formData,
        age: formData.age ? parseInt(formData.age) : undefined,
        groupId: formData.groupId ? parseInt(formData.groupId) : undefined,
        languages: languages.filter(l => l.language.trim() !== '')
      };

      if (isEditMode && id) {
        await studentService.update(parseInt(id), studentData);
      } else {
        await studentService.create(studentData);
      }
      
      navigate('/students');
    } catch (error) {
      console.error(`Error ${isEditMode ? 'updating' : 'creating'} student:`, error);
      alert(`Failed to ${isEditMode ? 'update' : 'create'} student. Please try again.`);
    } finally {
      setLoading(false);
    }
  };

  if (loadingData) {
    return (
      <div className="create-student-page">
        <div className="loading">Loading student data...</div>
      </div>
    );
  }

  return (
    <div className="create-student-page">
      <div className="page-header">
        <h1>{isEditMode ? 'Edit Student' : 'Add New Student'}</h1>
        <button onClick={() => navigate('/students')} className="btn-secondary">
          Cancel
        </button>
      </div>

      <form onSubmit={handleSubmit} className="student-form">
        <div className="form-section">
          <h2>Basic Information</h2>
          
          <div className="form-group">
            <label htmlFor="name">Student Name *</label>
            <input
              type="text"
              id="name"
              name="name"
              value={formData.name}
              onChange={handleInputChange}
              required
              placeholder="Enter student name"
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label htmlFor="age">Age</label>
              <input
                type="number"
                id="age"
                name="age"
                value={formData.age}
                onChange={handleInputChange}
                min="5"
                max="18"
                placeholder="Age"
              />
            </div>

            <div className="form-group">
              <label htmlFor="skillLevel">Overall Skill Level *</label>
              <select
                id="skillLevel"
                name="skillLevel"
                value={formData.skillLevel}
                onChange={handleInputChange}
                required
              >
                <option value="Beginner">Beginner</option>
                <option value="Intermediate">Intermediate</option>
                <option value="Advanced">Advanced</option>
              </select>
            </div>

            <div className="form-group">
              <label htmlFor="groupId">Group</label>
              <select
                id="groupId"
                name="groupId"
                value={formData.groupId}
                onChange={handleInputChange}
              >
                <option value="">No Group</option>
                {groups.map(group => (
                  <option key={group.id} value={group.id}>
                    {group.name}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </div>

        <div className="form-section">
          <h2>Contact Information</h2>
          
          <div className="form-row">
            <div className="form-group">
              <label htmlFor="email">Student Email</label>
              <input
                type="email"
                id="email"
                name="email"
                value={formData.email}
                onChange={handleInputChange}
                placeholder="student@email.com"
              />
            </div>

            <div className="form-group">
              <label htmlFor="parentEmail">Parent Email</label>
              <input
                type="email"
                id="parentEmail"
                name="parentEmail"
                value={formData.parentEmail}
                onChange={handleInputChange}
                placeholder="parent@email.com"
              />
            </div>
          </div>
        </div>

        <div className="form-section">
          <div className="section-header">
            <h2>Languages & Proficiency</h2>
            <button type="button" onClick={addLanguage} className="btn-add">
              + Add Language
            </button>
          </div>

          <div className="languages-list">
            {languages.map((lang, index) => (
              <div key={index} className="language-input-group">
                <div className="form-group">
                  <label htmlFor={`language-${index}`}>Language</label>
                  <select
                    id={`language-${index}`}
                    value={lang.language}
                    onChange={(e) => handleLanguageChange(index, 'language', e.target.value)}
                  >
                    <option value="">Select Language</option>
                    <option value="Python">Python</option>
                    <option value="JavaScript">JavaScript</option>
                    <option value="Java">Java</option>
                    <option value="C++">C++</option>
                    <option value="C#">C#</option>
                    <option value="HTML/CSS">HTML/CSS</option>
                    <option value="Scratch">Scratch</option>
                    <option value="Ruby">Ruby</option>
                  </select>
                </div>

                <div className="form-group">
                  <label htmlFor={`proficiency-${index}`}>Proficiency Level</label>
                  <select
                    id={`proficiency-${index}`}
                    value={lang.proficiencyLevel}
                    onChange={(e) => handleLanguageChange(index, 'proficiencyLevel', e.target.value)}
                  >
                    <option value="Beginner">Beginner</option>
                    <option value="Intermediate">Intermediate</option>
                    <option value="Advanced">Advanced</option>
                    <option value="Expert">Expert</option>
                  </select>
                </div>

                {languages.length > 1 && (
                  <button
                    type="button"
                    onClick={() => removeLanguage(index)}
                    className="btn-remove"
                    aria-label="Remove language"
                  >
                    ×
                  </button>
                )}
              </div>
            ))}
          </div>
        </div>

        <div className="form-section">
          <h2>Notes</h2>
          <div className="form-group">
            <label htmlFor="notes">Additional Notes</label>
            <textarea
              id="notes"
              name="notes"
              value={formData.notes}
              onChange={handleInputChange}
              rows={4}
              placeholder="Any additional information about the student..."
            />
          </div>
        </div>

        <div className="form-actions">
          <button type="button" onClick={() => navigate('/students')} className="btn-secondary">
            Cancel
          </button>
          <button type="submit" className="btn-primary" disabled={loading}>
            {loading ? (isEditMode ? 'Updating...' : 'Creating...') : (isEditMode ? 'Update Student' : 'Create Student')}
          </button>
        </div>
      </form>
    </div>
  );
};

export default CreateStudent;
