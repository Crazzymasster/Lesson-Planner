import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { codeSnippetService } from '@/services/api';
import type { CodeSnippet } from '@/types';
import { ArrowLeft, Copy, Check, Code as CodeIcon, Edit, Trash2 } from 'lucide-react';
import './CodeSnippetDetail.css';

export default function CodeSnippetDetail() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const [snippet, setSnippet] = useState<CodeSnippet | null>(null);
  const [loading, setLoading] = useState(true);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    if (id) {
      loadSnippet(parseInt(id));
    }
  }, [id]);

  const loadSnippet = async (snippetId: number) => {
    try {
      setLoading(true);
      const response = await codeSnippetService.getById(snippetId);
      setSnippet(response.data);
    } catch (error) {
      console.error('Error loading snippet:', error);
      alert('Failed to load snippet');
      navigate('/snippets');
    } finally {
      setLoading(false);
    }
  };

  const copyToClipboard = async () => {
    if (!snippet) return;
    try {
      await navigator.clipboard.writeText(snippet.code);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (error) {
      console.error('Failed to copy:', error);
    }
  };

  const handleDelete = async () => {
    if (!snippet) return;
    if (!confirm(`Are you sure you want to delete "${snippet.title}"? This action cannot be undone.`)) {
      return;
    }

    try {
      await codeSnippetService.delete(snippet.id);
      navigate('/snippets');
    } catch (error) {
      console.error('Error deleting snippet:', error);
      alert('Failed to delete snippet. Please try again.');
    }
  };

  if (loading) {
    return <div className="loading">Loading snippet...</div>;
  }

  if (!snippet) {
    return (
      <div className="error-container">
        <h2>Snippet Not Found</h2>
        <button onClick={() => navigate('/snippets')} className="btn-primary">
          Back to Snippets
        </button>
      </div>
    );
  }

  return (
    <div className="snippet-detail-page">
      <div className="detail-header">
        <button className="btn-back" onClick={() => navigate('/snippets')}>
          <ArrowLeft size={20} />
          Back to Snippets
        </button>
        <div className="action-buttons">
          <button className="btn-edit" onClick={() => navigate(`/snippets/edit/${snippet.id}`)}>
            <Edit size={20} />
            Edit Snippet
          </button>
          <button className="btn-delete" onClick={handleDelete}>
            <Trash2 size={20} />
            Delete
          </button>
        </div>
      </div>

      <div className="snippet-content">
        <div className="snippet-header-card">
          <div className="header-left">
            <div className="snippet-icon">
              <CodeIcon size={32} />
            </div>
            <div>
              <h1>{snippet.title}</h1>
              <div className="snippet-meta">
                <span className="language-badge">{snippet.language}</span>
                <span className={`difficulty-badge difficulty-${snippet.difficulty.toLowerCase()}`}>
                  {snippet.difficulty}
                </span>
              </div>
            </div>
          </div>
          <button className="btn-copy" onClick={copyToClipboard}>
            {copied ? <Check size={20} /> : <Copy size={20} />}
            {copied ? 'Copied!' : 'Copy Code'}
          </button>
        </div>

        {snippet.explanation && (
          <div className="explanation-section">
            <h2>Explanation</h2>
            <p>{snippet.explanation}</p>
          </div>
        )}

        <div className="code-section">
          <h2>Code</h2>
          <div className="code-block">
            <pre>
              <code>{snippet.code}</code>
            </pre>
          </div>
        </div>
      </div>
    </div>
  );
}
