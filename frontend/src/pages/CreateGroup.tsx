import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { studentGroupService } from '../services/api';
import { Users, ArrowLeft } from 'lucide-react';
import './CreateGroup.css';

const CreateGroup: React.FC = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    averageAge: '',
    skillLevel: 'Beginner' as 'Beginner' | 'Intermediate' | 'Advanced'
  });

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.name.trim()) {
      alert('Please enter a group name');
      return;
    }

    setLoading(true);

    try {
      const groupData = {
        ...formData,
        averageAge: formData.averageAge ? parseInt(formData.averageAge) : 0,
        studentIds: []
      };

      await studentGroupService.create(groupData);
      navigate('/students');
    } catch (error: any) {
      console.error('Error creating group:', error);
      alert(error.response?.data?.error || 'Failed to create group. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="create-group-page">
      <div className="page-header">
        <div className="header-content">
          <button 
            onClick={() => navigate('/students')} 
            className="btn-back"
            type="button"
          >
            <ArrowLeft size={20} />
          </button>
          <div className="header-icon">
            <Users size={32} />
          </div>
          <div>
            <h1>Create New Group</h1>
            <p>Organize students into learning groups</p>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="group-form">
        <div className="form-section">
          <h2>Group Information</h2>
          
          <div className="form-group">
            <label htmlFor="name">Group Name *</label>
            <input
              type="text"
              id="name"
              name="name"
              value={formData.name}
              onChange={handleInputChange}
              required
              placeholder="e.g., Group A, Morning Class, Advanced Python"
              autoFocus
            />
          </div>

          <div className="form-group">
            <label htmlFor="description">Description</label>
            <textarea
              id="description"
              name="description"
              value={formData.description}
              onChange={handleInputChange}
              rows={3}
              placeholder="Brief description of this group..."
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label htmlFor="averageAge">Average Age</label>
              <input
                type="number"
                id="averageAge"
                name="averageAge"
                value={formData.averageAge}
                onChange={handleInputChange}
                min="5"
                max="18"
                placeholder="e.g., 12"
              />
              <small>Optional - helps with lesson recommendations</small>
            </div>

            <div className="form-group">
              <label htmlFor="skillLevel">Group Skill Level *</label>
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
              <small>General skill level of students in this group</small>
            </div>
          </div>
        </div>

        <div className="form-actions">
          <button 
            type="button" 
            onClick={() => navigate('/students')} 
            className="btn-secondary"
          >
            Cancel
          </button>
          <button 
            type="submit" 
            className="btn-primary" 
            disabled={loading}
          >
            {loading ? 'Creating Group...' : 'Create Group'}
          </button>
        </div>
      </form>
    </div>
  );
};

export default CreateGroup;
