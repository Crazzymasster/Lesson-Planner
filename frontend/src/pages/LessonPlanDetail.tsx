import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { lessonPlanService } from '@/services/api';
import { ArrowLeft, Edit, Trash2, BookOpen, Clock, Users, Award, Code, Target, Package, List, Trophy } from 'lucide-react';
import type { LessonPlan } from '@/types';
import './LessonPlanDetail.css';

export default function LessonPlanDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [lesson, setLesson] = useState<LessonPlan | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (id) {
      console.log('Route ID param:', id, 'Type:', typeof id);
      const numericId = parseInt(id, 10);
      console.log('Parsed ID:', numericId, 'Type:', typeof numericId);
      loadLesson(numericId);
    }
  }, [id]);

  const loadLesson = async (lessonId: number) => {
    try {
      console.log('Loading lesson with ID:', lessonId);
      setLoading(true);
      setError(null);
      const response = await lessonPlanService.getById(lessonId);
      console.log('Full API response:', response);
      console.log('Lesson data:', response.data);
      
      // Handle both direct object and array response
      const lessonData = Array.isArray(response.data) ? response.data[0] : response.data;
      console.log('Processed lesson data:', lessonData);
      console.log('Lesson steps:', lessonData?.steps);
      console.log('Lesson challenges:', lessonData?.challenges);
      
      setLesson(lessonData);
    } catch (err) {
      console.error('Error loading lesson:', err);
      setError('Failed to load lesson plan');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!lesson || !window.confirm(`Are you sure you want to delete "${lesson.title}"?`)) {
      return;
    }
    
    try {
      await lessonPlanService.delete(lesson.id);
      navigate('/lessons');
    } catch (err) {
      alert('Failed to delete lesson plan');
      console.error('Error deleting lesson:', err);
    }
  };

  if (loading) {
    return <div className="loading">Loading lesson details...</div>;
  }

  if (error || !lesson) {
    return (
      <div className="error-container">
        <h2>Error</h2>
        <p>{error || 'Lesson not found'}</p>
        <button onClick={() => navigate('/lessons')} className="btn btn-primary">
          Back to Lessons
        </button>
      </div>
    );
  }

  return (
    <div className="lesson-detail-container">
      {/* Header */}
      <div className="detail-header">
        <button onClick={() => navigate('/lessons')} className="btn btn-secondary">
          <ArrowLeft size={18} /> Back to Lessons
        </button>
        <div className="header-actions">
          <button onClick={() => navigate(`/lessons/${lesson.id}/edit`)} className="btn btn-primary">
            <Edit size={18} /> Edit Lesson
          </button>
          <button onClick={handleDelete} className="btn btn-danger">
            <Trash2 size={18} /> Delete
          </button>
        </div>
      </div>

      {/* Title and Basic Info */}
      <div className="lesson-header-card">
        <h1 className="lesson-title">{lesson.title}</h1>
        <div className="lesson-badges">
          {lesson.language && (
            <span className="badge badge-language">
              <Code size={14} /> {lesson.language.toUpperCase()}
            </span>
          )}
          {lesson.difficulty && (
            <span className={`badge badge-${lesson.difficulty.toLowerCase()}`}>
              <Award size={14} /> {lesson.difficulty}
            </span>
          )}
          {lesson.category && (
            <span className="badge badge-category">{lesson.category}</span>
          )}
        </div>
        
        <p className="lesson-description">{lesson.description}</p>
        
        <div className="lesson-meta">
          {lesson.duration && (
            <div className="meta-item">
              <Clock size={18} />
              <span>{lesson.duration} minutes</span>
            </div>
          )}
          {lesson.targetAge && (
            <div className="meta-item">
              <Users size={18} />
              <span>Ages {lesson.targetAge}</span>
            </div>
          )}
        </div>
      </div>

      {/* Prerequisites */}
      {lesson.prerequisites && (
        <section className="detail-section">
          <h2 className="section-title">Prerequisites</h2>
          <p className="section-text">{lesson.prerequisites}</p>
        </section>
      )}

      {/* Learning Outcomes */}
      {lesson.learningOutcomes && (
        <section className="detail-section">
          <h2 className="section-title">Learning Outcomes</h2>
          <p className="section-text">{lesson.learningOutcomes}</p>
        </section>
      )}

      {/* Topics */}
      {lesson.topics && lesson.topics.length > 0 && (
        <section className="detail-section">
          <div className="section-header">
            <Target size={20} />
            <h2 className="section-title">Topics Covered</h2>
          </div>
          <div className="tag-list">
            {lesson.topics.map((topic, index) => (
              <span key={index} className="tag">{topic}</span>
            ))}
          </div>
        </section>
      )}

      {/* Objectives */}
      {lesson.objectives && lesson.objectives.length > 0 && (
        <section className="detail-section">
          <div className="section-header">
            <Target size={20} />
            <h2 className="section-title">Learning Objectives</h2>
          </div>
          <ul className="objective-list">
            {lesson.objectives.map((objective, index) => (
              <li key={index}>{objective}</li>
            ))}
          </ul>
        </section>
      )}

      {/* Materials */}
      {lesson.materials && lesson.materials.length > 0 && (
        <section className="detail-section">
          <div className="section-header">
            <Package size={20} />
            <h2 className="section-title">Materials Needed</h2>
          </div>
          <ul className="material-list">
            {lesson.materials.map((material, index) => (
              <li key={index}>{material}</li>
            ))}
          </ul>
        </section>
      )}

      {/* Lesson Steps */}
      {lesson.steps && lesson.steps.length > 0 && (
        <section className="detail-section">
          <div className="section-header">
            <List size={20} />
            <h2 className="section-title">Lesson Steps</h2>
          </div>
          <div className="steps-container">
            {lesson.steps.map((step, index) => (
              <div key={step.id || index} className="step-card">
                <div className="step-number">Step {step.stepNumber}</div>
                <h3 className="step-title">{step.title}</h3>
                {step.instruction && <p className="step-instruction">{step.instruction}</p>}
                {step.explanation && (
                  <div className="step-explanation">
                    <strong>Explanation:</strong> {step.explanation}
                  </div>
                )}
                {step.codeExample && (
                  <div className="code-block">
                    <div className="code-header">Code Example</div>
                    <pre><code>{step.codeExample}</code></pre>
                  </div>
                )}
                {step.expectedOutput && (
                  <div className="output-block">
                    <div className="output-header">Expected Output</div>
                    <pre><code>{step.expectedOutput}</code></pre>
                  </div>
                )}
                {step.hints && (
                  <div className="hints-block">
                    <strong>💡 Hints:</strong> {step.hints}
                  </div>
                )}
              </div>
            ))}
          </div>
        </section>
      )}

      {/* Challenges */}
      {lesson.challenges && lesson.challenges.length > 0 && (
        <section className="detail-section">
          <div className="section-header">
            <Award size={20} />
            <h2 className="section-title">Practice Challenges</h2>
          </div>
          <div className="challenges-container">
            {lesson.challenges.map((challenge, index) => (
              <div key={challenge.id || index} className="challenge-card">
                <div className="challenge-header">
                  <h3 className="challenge-title">{challenge.title}</h3>
                  <div className="challenge-badges">
                    <span className={`badge badge-${challenge.difficulty?.toLowerCase()}`}>
                      {challenge.difficulty}
                    </span>
                    <span className="badge badge-points">{challenge.points} pts</span>
                  </div>
                </div>
                <p className="challenge-description">{challenge.description}</p>
                {challenge.starterCode && (
                  <div className="code-block">
                    <div className="code-header">Starter Code</div>
                    <pre><code>{challenge.starterCode}</code></pre>
                  </div>
                )}
                {challenge.solution && (
                  <details className="solution-details">
                    <summary>View Solution</summary>
                    <div className="code-block">
                      <pre><code>{challenge.solution}</code></pre>
                    </div>
                  </details>
                )}
              </div>
            ))}
          </div>
        </section>
      )}

      {/* Final Project */}
      {lesson.project && (
        <section className="detail-section">
          <div className="section-header">
            <Trophy size={20} />
            <h2 className="section-title">Final Project</h2>
          </div>
          <div className="project-card">
            <h3 className="project-title">{lesson.project.title}</h3>
            <p className="project-description">{lesson.project.description}</p>
            {lesson.project.requirements && (
              <div className="project-requirements">
                <strong>Requirements:</strong>
                <pre>{lesson.project.requirements}</pre>
              </div>
            )}
            {lesson.project.starterCode && (
              <div className="code-block">
                <div className="code-header">Starter Code</div>
                <pre><code>{lesson.project.starterCode}</code></pre>
              </div>
            )}
            {lesson.project.extensionIdeas && (
              <div className="extension-ideas">
                <strong>Extension Ideas:</strong>
                <p>{lesson.project.extensionIdeas}</p>
              </div>
            )}
            {lesson.project.solutionCode && (
              <details className="solution-details">
                <summary>View Solution Code</summary>
                <div className="code-block">
                  <pre><code>{lesson.project.solutionCode}</code></pre>
                </div>
              </details>
            )}
          </div>
        </section>
      )}

      {/* Teacher Notes */}
      {lesson.notes && (
        <section className="detail-section">
          <h2 className="section-title">Teacher Notes</h2>
          <div className="notes-block">
            <p>{lesson.notes}</p>
          </div>
        </section>
      )}
    </div>
  );
}
