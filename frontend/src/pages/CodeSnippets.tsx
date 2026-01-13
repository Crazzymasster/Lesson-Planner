import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { codeSnippetService } from '@/services/api';
import type { CodeSnippet } from '@/types';
import { Code, Search, Filter, Plus } from 'lucide-react';
import './CodeSnippets.css';

export default function CodeSnippets() {
  const navigate = useNavigate();
  const [snippets, setSnippets] = useState<CodeSnippet[]>([]);
  const [filteredSnippets, setFilteredSnippets] = useState<CodeSnippet[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedLanguage, setSelectedLanguage] = useState<string>('all');
  const [selectedDifficulty, setSelectedDifficulty] = useState<string>('all');

  useEffect(() => {
    loadSnippets();
  }, []);

  useEffect(() => {
    filterSnippets();
  }, [snippets, searchQuery, selectedLanguage, selectedDifficulty]);

  const loadSnippets = async () => {
    try {
      setLoading(true);
      const response = await codeSnippetService.getAll();
      setSnippets(response.data);
    } catch (error) {
      console.error('Error loading snippets:', error);
    } finally {
      setLoading(false);
    }
  };

  const filterSnippets = () => {
    let filtered = [...snippets];

    // Filter by search query
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(
        (snippet) =>
          snippet.title.toLowerCase().includes(query) ||
          snippet.explanation?.toLowerCase().includes(query) ||
          snippet.code.toLowerCase().includes(query)
      );
    }

    // Filter by language
    if (selectedLanguage !== 'all') {
      filtered = filtered.filter((snippet) => snippet.language.toLowerCase() === selectedLanguage.toLowerCase());
    }

    // Filter by difficulty
    if (selectedDifficulty !== 'all') {
      filtered = filtered.filter((snippet) => snippet.difficulty === selectedDifficulty);
    }

    setFilteredSnippets(filtered);
  };

  const uniqueLanguages = Array.from(new Set(snippets.map((s) => s.language)));

  if (loading) {
    return <div className="loading">Loading code snippets...</div>;
  }

  return (
    <div className="code-snippets-page">
      {/* Header */}
      <div className="page-header">
        <div className="header-content">
          <div className="header-icon">
            <Code size={32} />
          </div>
          <div>
            <h1>Code Snippets Library</h1>
            <p>Reusable code examples for teaching programming concepts</p>
          </div>
        </div>
        <button className="btn-create" onClick={() => navigate('/snippets/new')}>
          <Plus size={20} />
          Create Snippet
        </button>
      </div>

      {/* Filters and Search */}
      <div className="controls-section">
        <div className="search-box">
          <Search size={20} />
          <input
            type="text"
            placeholder="Search snippets by title, language, or code..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>

        <div className="filters">
          <div className="filter-group">
            <Filter size={16} />
            <label>Language:</label>
            <select value={selectedLanguage} onChange={(e) => setSelectedLanguage(e.target.value)}>
              <option value="all">All Languages</option>
              {uniqueLanguages.map((lang) => (
                <option key={lang} value={lang}>
                  {lang}
                </option>
              ))}
            </select>
          </div>

          <div className="filter-group">
            <label>Difficulty:</label>
            <select value={selectedDifficulty} onChange={(e) => setSelectedDifficulty(e.target.value)}>
              <option value="all">All Levels</option>
              <option value="Beginner">Beginner</option>
              <option value="Intermediate">Intermediate</option>
              <option value="Advanced">Advanced</option>
            </select>
          </div>

          <div className="results-count">
            {filteredSnippets.length} {filteredSnippets.length === 1 ? 'snippet' : 'snippets'}
          </div>
        </div>
      </div>

      {/* Snippets Grid */}
      {filteredSnippets.length === 0 ? (
        <div className="empty-state">
          <h2>No Code Snippets Found</h2>
          <p>
            {searchQuery || selectedLanguage !== 'all' || selectedDifficulty !== 'all'
              ? 'Try adjusting your filters'
              : 'No code snippets available yet'}
          </p>
        </div>
      ) : (
        <div className="snippets-grid">
          {filteredSnippets.map((snippet) => (
            <div 
              key={snippet.id} 
              className="snippet-card"
              onClick={() => navigate(`/snippets/${snippet.id}`)}
            >
              <div className="snippet-header">
                <div className="snippet-title">
                  <h3>{snippet.title}</h3>
                  <div className="snippet-badges">
                    <span className="language-badge">{snippet.language}</span>
                    <span className={`difficulty-badge difficulty-${snippet.difficulty.toLowerCase()}`}>
                      {snippet.difficulty}
                    </span>
                  </div>
                </div>
              </div>

              {snippet.explanation && (
                <div className="snippet-explanation">
                  <p>{snippet.explanation}</p>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

