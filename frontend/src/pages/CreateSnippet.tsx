import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { codeSnippetService } from '@/services/api';
import { ArrowLeft, Code } from 'lucide-react';
import './CreateSnippet.css';

export default function CreateSnippet() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const isEditMode = !!id;
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    language: '',
    code: '',
    explanation: '',
    difficulty: 'Beginner' as 'Beginner' | 'Intermediate' | 'Advanced'
  });

  useEffect(() => {
    if (isEditMode && id) {
      loadSnippet(parseInt(id));
    }
  }, [id, isEditMode]);

  const loadSnippet = async (snippetId: number) => {
    try {
      setLoading(true);
      const response = await codeSnippetService.getById(snippetId);
      const snippet = response.data;
      setFormData({
        title: snippet.title,
        language: snippet.language,
        code: snippet.code,
        explanation: snippet.explanation || '',
        difficulty: snippet.difficulty
      });
    } catch (error) {
      console.error('Error loading snippet:', error);
      alert('Failed to load snippet');
      navigate('/snippets');
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (isEditMode && id) {
        await codeSnippetService.update(parseInt(id), formData);
      } else {
        await codeSnippetService.create(formData);
      }
      navigate('/snippets');
    } catch (error) {
      console.error('Error saving snippet:', error);
      alert(`Failed to ${isEditMode ? 'update' : 'create'} snippet. Please try again.`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="create-snippet-page">
      <div className="page-header">
        <div className="header-content">
          <button className="btn-back" onClick={() => navigate('/snippets')}>
            <ArrowLeft size={20} />
          </button>
          <div className="header-icon">
            <Code size={28} />
          </div>
          <div>
            <h1>{isEditMode ? 'Edit Code Snippet' : 'Create Code Snippet'}</h1>
            <p>{isEditMode ? 'Update your code example' : 'Add a new reusable code example to your library'}</p>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="snippet-form">
        <div className="form-section">
          <h2>Basic Information</h2>
          
          <div className="form-group">
            <label htmlFor="title">Snippet Title *</label>
            <input
              type="text"
              id="title"
              name="title"
              value={formData.title}
              onChange={handleInputChange}
              required
              placeholder="e.g., For Loop Example"
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label htmlFor="language">Programming Language *</label>
              <select
                id="language"
                name="language"
                value={formData.language}
                onChange={handleInputChange}
                required
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
              <label htmlFor="difficulty">Difficulty Level *</label>
              <select
                id="difficulty"
                name="difficulty"
                value={formData.difficulty}
                onChange={handleInputChange}
                required
              >
                <option value="Beginner">Beginner</option>
                <option value="Intermediate">Intermediate</option>
                <option value="Advanced">Advanced</option>
              </select>
            </div>
          </div>
        </div>

        <div className="form-section">
          <h2>Code</h2>
          
          <div className="form-group">
            <label htmlFor="code">Code Content *</label>
            <textarea
              id="code"
              name="code"
              value={formData.code}
              onChange={handleInputChange}
              required
              rows={15}
              placeholder="Paste your code here..."
              className="code-textarea"
            />
          </div>
        </div>

        <div className="form-section">
          <h2>Explanation</h2>
          
          <div className="form-group">
            <label htmlFor="explanation">What does this code do?</label>
            <textarea
              id="explanation"
              name="explanation"
              value={formData.explanation}
              onChange={handleInputChange}
              rows={4}
              placeholder="Explain what this code snippet demonstrates..."
            />
          </div>
        </div>

        <div className="form-actions">
          <button type="button" onClick={() => navigate('/snippets')} className="btn-secondary">
            Cancel
          </button>
          <button type="submit" className="btn-primary" disabled={loading}>
            {loading ? (isEditMode ? 'Updating...' : 'Creating...') : (isEditMode ? 'Update Snippet' : 'Create Snippet')}
          </button>
        </div>
      </form>
    </div>
  );
}
