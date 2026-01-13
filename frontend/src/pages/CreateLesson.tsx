import { useState, useEffect } from 'react';
import { useNavigate, useParams, useLocation } from 'react-router-dom';
import { lessonPlanService, folderService } from '@/services/api';
import { Plus, Trash2, Save, X, BookOpen, Target, Package, List, Award, Trophy } from 'lucide-react';
import type { LessonStep, LessonChallenge, LessonPlan, LessonFolder } from '@/types';
import './CreateLesson.css';

export default function CreateLesson() {
  const navigate = useNavigate();
  const location = useLocation();
  const { id } = useParams<{ id: string }>();
  const isEditMode = Boolean(id);
  const [saving, setSaving] = useState(false);
  const [loading, setLoading] = useState(isEditMode);
  const [folders, setFolders] = useState<LessonFolder[]>([]);
  
  // Check if we have AI-generated data
  const aiGenerated = location.state?.aiGenerated;
  
  // Basic Information
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [language, setLanguage] = useState('python');
  const [category, setCategory] = useState('');
  const [difficulty, setDifficulty] = useState<'Beginner' | 'Intermediate' | 'Advanced'>('Beginner');
  const [targetAge, setTargetAge] = useState('');
  const [duration, setDuration] = useState(60);
  const [points, setPoints] = useState(10); // Points awarded for completing this lesson
  const [prerequisites, setPrerequisites] = useState('');
  const [learningOutcomes, setLearningOutcomes] = useState('');
  const [notes, setNotes] = useState('');
  const [folderId, setFolderId] = useState<number | null>(null);
  
  // Lists
  const [topics, setTopics] = useState<string[]>(['']);
  const [objectives, setObjectives] = useState<string[]>(['']);
  const [materials, setMaterials] = useState<string[]>(['']);
  
  // Steps
  const [steps, setSteps] = useState<Partial<LessonStep>[]>([{
    stepNumber: 1,
    title: '',
    instruction: '',
    codeExample: '',
    expectedOutput: '',
    explanation: '',
    hints: ''
  }]);
  
  // Challenges
  const [challenges, setChallenges] = useState<Partial<LessonChallenge>[]>([{
    order: 1,
    title: '',
    description: '',
    starterCode: '',
    solution: '',
    difficulty: 'Easy',
    points: 10
  }]);
  
  // Project
  const [hasProject, setHasProject] = useState(false);
  const [projectTitle, setProjectTitle] = useState('');
  const [projectDescription, setProjectDescription] = useState('');
  const [projectRequirements, setProjectRequirements] = useState('');
  const [projectStarterCode, setProjectStarterCode] = useState('');
  const [projectSolutionCode, setProjectSolutionCode] = useState('');
  const [projectExtensionIdeas, setProjectExtensionIdeas] = useState('');
  // Load lesson data when editing
  useEffect(() => {
    // Load folders
    loadFolders();
    
    console.log('CreateLesson useEffect - isEditMode:', isEditMode, 'id:', id, 'aiGenerated:', aiGenerated);
    if (isEditMode && id) {
      loadLesson(parseInt(id));
    } else if (aiGenerated) {
      // Load AI-generated data
      console.log('Loading AI-generated data:', aiGenerated);
      loadAIGeneratedData(aiGenerated);
    }
  }, [id, isEditMode, aiGenerated]);

  const loadFolders = async () => {
    try {
      const response = await folderService.getAll();
      setFolders(response.data);
    } catch (err) {
      console.error('Error loading folders:', err);
    }
  };

  const loadAIGeneratedData = (data: any) => {
    console.log('loadAIGeneratedData called with:', data);
    setTitle(data.title || '');
    setDescription(data.description || '');
    setLanguage(data.language || 'python');
    setCategory(data.category || '');
    setDifficulty(data.difficulty || 'Beginner');
    setTargetAge(data.targetAge || '');
    setDuration(data.duration || 60);
    setPoints(data.points || 10);
    setPrerequisites(data.prerequisites || '');
    setLearningOutcomes(data.learningOutcomes || '');
    setNotes(data.notes || '');
    
    setTopics(data.topics && data.topics.length > 0 ? data.topics : ['']);
    setObjectives(data.objectives && data.objectives.length > 0 ? data.objectives : ['']);
    setMaterials(data.materials && data.materials.length > 0 ? data.materials : ['']);
    
    if (data.steps && data.steps.length > 0) {
      console.log('Setting steps:', data.steps);
      setSteps(data.steps);
    }
    
    if (data.challenges && data.challenges.length > 0) {
      console.log('Setting challenges:', data.challenges);
      setChallenges(data.challenges);
    }
    
    // Load project data if it exists
    if (data.hasProject && data.project) {
      console.log('Setting project data:', data.project);
      setHasProject(true);
      setProjectTitle(data.project.title || '');
      setProjectDescription(data.project.description || '');
      setProjectRequirements(data.project.requirements || '');
      setProjectStarterCode(data.project.starterCode || '');
      setProjectSolutionCode(data.project.solution || '');
      setProjectExtensionIdeas(data.project.extensionIdeas || '');
    } else {
      setHasProject(false);
    }
    
    console.log('AI data loaded successfully');
  };

  // Auto-suggest points based on difficulty level
  useEffect(() => {
    if (!isEditMode) {
      const suggestedPoints = {
        'Beginner': 10,
        'Intermediate': 20,
        'Advanced': 30
      };
      setPoints(suggestedPoints[difficulty]);
    }
  }, [difficulty, isEditMode]);

  const loadLesson = async (lessonId: number) => {
    try {
      setLoading(true);
      const response = await lessonPlanService.getById(lessonId);
      const lesson: LessonPlan = response.data;
      
      setTitle(lesson.title || '');
      setDescription(lesson.description || '');
      setLanguage(lesson.language || 'python');
      setCategory(lesson.category || '');
      setDifficulty(lesson.difficulty || 'Beginner');
      setTargetAge(lesson.targetAge || '');
      setDuration(lesson.duration || 60);
      setPoints(lesson.points || 10);
      setPrerequisites(lesson.prerequisites || '');
      setLearningOutcomes(lesson.learningOutcomes || '');
      setNotes(lesson.notes || '');
      setFolderId(lesson.folderId || null);
      
      setTopics(lesson.topics && lesson.topics.length > 0 ? lesson.topics : ['']);
      setObjectives(lesson.objectives && lesson.objectives.length > 0 ? lesson.objectives : ['']);
      setMaterials(lesson.materials && lesson.materials.length > 0 ? lesson.materials : ['']);
      
      if (lesson.steps && lesson.steps.length > 0) {
        setSteps(lesson.steps);
      }
      
      if (lesson.challenges && lesson.challenges.length > 0) {
        setChallenges(lesson.challenges);
      }
      
      if (lesson.project) {
        setHasProject(true);
        setProjectTitle(lesson.project.title || '');
        setProjectDescription(lesson.project.description || '');
        setProjectRequirements(lesson.project.requirements || '');
        setProjectStarterCode(lesson.project.starterCode || '');
        setProjectSolutionCode(lesson.project.solutionCode || '');
        setProjectExtensionIdeas(lesson.project.extensionIdeas || '');
      }
    } catch (err) {
      alert('Failed to load lesson plan');
      console.error('Error loading lesson:', err);
      navigate('/lessons');
    } finally {
      setLoading(false);
    }
  };
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!title || !description || !language) {
      alert('Please fill in all required fields (Title, Description, Language)');
      return;
    }

    setSaving(true);
    try {
      const lessonData = {
        title,
        description,
        language,
        category,
        difficulty,
        targetAge,
        duration,
        points,
        prerequisites,
        learningOutcomes,
        notes,
        folderId,
        topics: topics.filter(t => t.trim()),
        objectives: objectives.filter(o => o.trim()),
        materials: materials.filter(m => m.trim()),
        steps: steps.filter(s => s.title?.trim()),
        challenges: challenges.filter(c => c.title?.trim()),
        project: hasProject ? {
          title: projectTitle,
          description: projectDescription,
          requirements: projectRequirements,
          starterCode: projectStarterCode,
          solutionCode: projectSolutionCode,
          extensionIdeas: projectExtensionIdeas
        } : undefined
      };

      console.log('Saving lesson data:', lessonData);
      console.log('Steps count:', lessonData.steps.length);
      console.log('Steps data:', lessonData.steps);
      console.log('Challenges count:', lessonData.challenges.length);
      console.log('Challenges data:', lessonData.challenges);

      if (isEditMode && id) {
        await lessonPlanService.update(parseInt(id), lessonData);
      } else {
        await lessonPlanService.create(lessonData);
      }
      navigate('/lessons');
    } catch (err) {
      alert('Failed to create lesson plan. Please try again.');
      console.error('Error creating lesson:', err);
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <div className="create-lesson-container"><div className="loading">Loading lesson...</div></div>;
  }

  return (
    <div className="create-lesson-container">
      <div className="create-lesson-header">
        <h1 className="create-lesson-title">{isEditMode ? 'Edit Lesson Plan' : 'Create New Lesson Plan'}</h1>
        <button type="button" onClick={() => navigate('/lessons')} className="btn btn-secondary">
          <X size={18} /> Cancel
        </button>
      </div>

      <form onSubmit={handleSubmit} className="lesson-form">
        {/* Basic Information */}
        <section className="lesson-section">
          <div className="section-header">
            <BookOpen className="section-icon" size={24} />
            <h2 className="section-title">Basic Information</h2>
          </div>
          
          <div className="form-grid">
            <div className="form-group">
              <label className="form-label">Title <span className="required">*</span></label>
              <input type="text" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="e.g., Introduction to Python Variables" required className="form-input" />
            </div>

            <div className="form-group">
              <label className="form-label">Programming Language <span className="required">*</span></label>
              <select value={language} onChange={(e) => setLanguage(e.target.value)} required className="form-select">
                <option value="python">Python</option>
                <option value="javascript">JavaScript</option>
                <option value="java">Java</option>
                <option value="cpp">C++</option>
                <option value="csharp">C#</option>
                <option value="scratch">Scratch</option>
                <option value="html-css">HTML/CSS</option>
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Category</label>
              <input type="text" value={category} onChange={(e) => setCategory(e.target.value)} placeholder="e.g., Variables & Data Types, Loops" className="form-input" />
            </div>

            <div className="form-group">
              <label className="form-label">Difficulty</label>
              <select value={difficulty} onChange={(e) => setDifficulty(e.target.value as any)} className="form-select">
                <option value="Beginner">Beginner</option>
                <option value="Intermediate">Intermediate</option>
                <option value="Advanced">Advanced</option>
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Target Age</label>
              <input type="text" value={targetAge} onChange={(e) => setTargetAge(e.target.value)} placeholder="e.g., 8-10, 10-12" className="form-input" />
              <span className="hint-text">Age range for this lesson</span>
            </div>

            <div className="form-group">
              <label className="form-label">Duration (minutes)</label>
              <input type="number" value={duration} onChange={(e) => setDuration(parseInt(e.target.value) || 60)} min="15" max="180" step="15" className="form-input" />
            </div>

            <div className="form-group">
              <label className="form-label">Points <Award size={16} style={{ display: 'inline', marginLeft: '4px', color: '#f59e0b' }} /></label>
              <input 
                type="number" 
                value={points} 
                onChange={(e) => setPoints(parseInt(e.target.value) || 10)} 
                min="5" 
                max="100" 
                step="5" 
                className="form-input" 
              />
              <span className="hint-text">Points awarded when student completes this lesson</span>
            </div>

            <div className="form-group">
              <label className="form-label">Folder</label>
              <select 
                value={folderId || ''} 
                onChange={(e) => setFolderId(e.target.value ? parseInt(e.target.value) : null)} 
                className="form-input"
              >
                <option value="">Uncategorized</option>
                {folders.map(folder => (
                  <option key={folder.id} value={folder.id}>{folder.name}</option>
                ))}
              </select>
              <span className="hint-text">Organize this lesson into a folder</span>
            </div>
          </div>

          <div className="form-group" style={{ marginTop: '1.5rem' }}>
            <label className="form-label">Description <span className="required">*</span></label>
            <textarea value={description} onChange={(e) => setDescription(e.target.value)} placeholder="Brief description of what students will learn" required rows={3} className="form-textarea" />
          </div>

          <div className="form-group" style={{ marginTop: '1rem' }}>
            <label className="form-label">Prerequisites</label>
            <textarea value={prerequisites} onChange={(e) => setPrerequisites(e.target.value)} placeholder="What students should know before this lesson" rows={2} className="form-textarea" />
          </div>

          <div className="form-group" style={{ marginTop: '1rem' }}>
            <label className="form-label">Learning Outcomes</label>
            <textarea value={learningOutcomes} onChange={(e) => setLearningOutcomes(e.target.value)} placeholder="What students will be able to do after this lesson" rows={2} className="form-textarea" />
          </div>
        </section>

        {/* Topics */}
        <section className="lesson-section">
          <div className="section-header">
            <Target className="section-icon" size={24} />
            <h2 className="section-title">Topics</h2>
          </div>
          <div className="list-items">
            {topics.map((topic, index) => (
              <div key={index} className="list-item">
                <input type="text" value={topic} onChange={(e) => { const newTopics = [...topics]; newTopics[index] = e.target.value; setTopics(newTopics); }} placeholder="e.g., Variables, Data Types, Loops" className="form-input" />
                {topics.length > 1 && <button type="button" onClick={() => setTopics(topics.filter((_, i) => i !== index))} className="btn btn-danger btn-icon-only"><Trash2 size={16} /></button>}
              </div>
            ))}
          </div>
          <button type="button" onClick={() => setTopics([...topics, ''])} className="btn btn-secondary" style={{ marginTop: '0.75rem' }}>
            <Plus size={16} /> Add Topic
          </button>
        </section>

        {/* Objectives */}
        <section className="lesson-section">
          <div className="section-header">
            <List className="section-icon" size={24} />
            <h2 className="section-title">Learning Objectives</h2>
          </div>
          <div className="list-items">
            {objectives.map((objective, index) => (
              <div key={index} className="list-item">
                <input type="text" value={objective} onChange={(e) => { const newObjectives = [...objectives]; newObjectives[index] = e.target.value; setObjectives(newObjectives); }} placeholder="e.g., Understand what variables are and how to create them" className="form-input" />
                {objectives.length > 1 && <button type="button" onClick={() => setObjectives(objectives.filter((_, i) => i !== index))} className="btn btn-danger btn-icon-only"><Trash2 size={16} /></button>}
              </div>
            ))}
          </div>
          <button type="button" onClick={() => setObjectives([...objectives, ''])} className="btn btn-secondary" style={{ marginTop: '0.75rem' }}>
            <Plus size={16} /> Add Objective
          </button>
        </section>

        {/* Materials */}
        <section className="lesson-section">
          <div className="section-header">
            <Package className="section-icon" size={24} />
            <h2 className="section-title">Materials Needed</h2>
          </div>
          <div className="list-items">
            {materials.map((material, index) => (
              <div key={index} className="list-item">
                <input type="text" value={material} onChange={(e) => { const newMaterials = [...materials]; newMaterials[index] = e.target.value; setMaterials(newMaterials); }} placeholder="e.g., Computer with Python installed" className="form-input" />
                {materials.length > 1 && <button type="button" onClick={() => setMaterials(materials.filter((_, i) => i !== index))} className="btn btn-danger btn-icon-only"><Trash2 size={16} /></button>}
              </div>
            ))}
          </div>
          <button type="button" onClick={() => setMaterials([...materials, ''])} className="btn btn-secondary" style={{ marginTop: '0.75rem' }}>
            <Plus size={16} /> Add Material
          </button>
        </section>

        {/* Steps */}
        <section className="lesson-section">
          <div className="section-header">
            <BookOpen className="section-icon" size={24} />
            <h2 className="section-title">Step-by-Step Instructions</h2>
          </div>
          {steps.map((step, index) => (
            <div key={index} className="step-card">
              <div className="card-header">
                <h3 className="card-title">Step {index + 1}</h3>
                {steps.length > 1 && <button type="button" onClick={() => setSteps(steps.filter((_, i) => i !== index))} className="btn btn-danger btn-icon-only"><Trash2 size={16} /></button>}
              </div>
              <div className="card-fields">
                <input type="text" value={step.title || ''} onChange={(e) => { const newSteps = [...steps]; newSteps[index] = { ...newSteps[index], title: e.target.value }; setSteps(newSteps); }} placeholder="Step title" className="form-input" />
                <textarea value={step.instruction || ''} onChange={(e) => { const newSteps = [...steps]; newSteps[index] = { ...newSteps[index], instruction: e.target.value }; setSteps(newSteps); }} placeholder="Instructions for this step" rows={3} className="form-textarea" />
                <textarea value={step.codeExample || ''} onChange={(e) => { const newSteps = [...steps]; newSteps[index] = { ...newSteps[index], codeExample: e.target.value }; setSteps(newSteps); }} placeholder="Code example (optional)" rows={4} className="form-textarea code-input" />
                <input type="text" value={step.expectedOutput || ''} onChange={(e) => { const newSteps = [...steps]; newSteps[index] = { ...newSteps[index], expectedOutput: e.target.value }; setSteps(newSteps); }} placeholder="Expected output (optional)" className="form-input code-input" />
                <textarea value={step.explanation || ''} onChange={(e) => { const newSteps = [...steps]; newSteps[index] = { ...newSteps[index], explanation: e.target.value }; setSteps(newSteps); }} placeholder="Explanation" rows={2} className="form-textarea" />
                <textarea value={step.hints || ''} onChange={(e) => { const newSteps = [...steps]; newSteps[index] = { ...newSteps[index], hints: e.target.value }; setSteps(newSteps); }} placeholder="Hints (optional)" rows={2} className="form-textarea" />
              </div>
            </div>
          ))}
          <button type="button" onClick={() => setSteps([...steps, { stepNumber: steps.length + 1, title: '', instruction: '', codeExample: '', expectedOutput: '', explanation: '', hints: '' }])} className="btn btn-secondary">
            <Plus size={16} /> Add Step
          </button>
        </section>

        {/* Challenges */}
        <section className="lesson-section">
          <div className="section-header">
            <Award className="section-icon" size={24} />
            <h2 className="section-title">Practice Challenges</h2>
          </div>
          {challenges.map((challenge, index) => (
            <div key={index} className="challenge-card">
              <div className="card-header">
                <h3 className="card-title">Challenge {index + 1}</h3>
                {challenges.length > 1 && <button type="button" onClick={() => setChallenges(challenges.filter((_, i) => i !== index))} className="btn btn-danger btn-icon-only"><Trash2 size={16} /></button>}
              </div>
              <div className="card-fields">
                <div className="form-grid">
                  <input type="text" value={challenge.title || ''} onChange={(e) => { const newChallenges = [...challenges]; newChallenges[index] = { ...newChallenges[index], title: e.target.value }; setChallenges(newChallenges); }} placeholder="Challenge title" className="form-input" />
                  <select value={challenge.difficulty || 'Easy'} onChange={(e) => { const newChallenges = [...challenges]; newChallenges[index] = { ...newChallenges[index], difficulty: e.target.value as any }; setChallenges(newChallenges); }} className="form-select">
                    <option value="Easy">Easy</option>
                    <option value="Medium">Medium</option>
                    <option value="Hard">Hard</option>
                  </select>
                  <input type="number" value={challenge.points || 10} onChange={(e) => { const newChallenges = [...challenges]; newChallenges[index] = { ...newChallenges[index], points: parseInt(e.target.value) || 10 }; setChallenges(newChallenges); }} placeholder="Points" min="0" className="form-input" />
                </div>
                <textarea value={challenge.description || ''} onChange={(e) => { const newChallenges = [...challenges]; newChallenges[index] = { ...newChallenges[index], description: e.target.value }; setChallenges(newChallenges); }} placeholder="Challenge description and requirements" rows={2} className="form-textarea" />
                <textarea value={challenge.starterCode || ''} onChange={(e) => { const newChallenges = [...challenges]; newChallenges[index] = { ...newChallenges[index], starterCode: e.target.value }; setChallenges(newChallenges); }} placeholder="Starter code (optional)" rows={3} className="form-textarea code-input" />
                <textarea value={challenge.solution || ''} onChange={(e) => { const newChallenges = [...challenges]; newChallenges[index] = { ...newChallenges[index], solution: e.target.value }; setChallenges(newChallenges); }} placeholder="Solution code" rows={4} className="form-textarea code-input" />
              </div>
            </div>
          ))}
          <button type="button" onClick={() => setChallenges([...challenges, { order: challenges.length + 1, title: '', description: '', starterCode: '', solution: '', difficulty: 'Easy', points: 10 }])} className="btn btn-secondary">
            <Plus size={16} /> Add Challenge
          </button>
        </section>

        {/* Final Project */}
        <section className="lesson-section">
          <div className="section-header">
            <Trophy className="section-icon" size={24} />
            <h2 className="section-title">Final Project (Optional)</h2>
            <div className="checkbox-group" style={{ marginLeft: 'auto' }}>
              <input type="checkbox" id="hasProject" checked={hasProject} onChange={(e) => setHasProject(e.target.checked)} />
              <label htmlFor="hasProject">Include final project</label>
            </div>
          </div>
          
          {hasProject && (
            <div className="project-card">
              <div className="card-fields">
                <input type="text" value={projectTitle} onChange={(e) => setProjectTitle(e.target.value)} placeholder="Project title" className="form-input" />
                <textarea value={projectDescription} onChange={(e) => setProjectDescription(e.target.value)} placeholder="Project description" rows={3} className="form-textarea" />
                <textarea value={projectRequirements} onChange={(e) => setProjectRequirements(e.target.value)} placeholder="Requirements (one per line)" rows={4} className="form-textarea" />
                <textarea value={projectStarterCode} onChange={(e) => setProjectStarterCode(e.target.value)} placeholder="Starter code (optional)" rows={5} className="form-textarea code-input" />
                <textarea value={projectSolutionCode} onChange={(e) => setProjectSolutionCode(e.target.value)} placeholder="Solution code" rows={6} className="form-textarea code-input" />
                <textarea value={projectExtensionIdeas} onChange={(e) => setProjectExtensionIdeas(e.target.value)} placeholder="Extension ideas (optional)" rows={3} className="form-textarea" />
              </div>
            </div>
          )}
        </section>

        {/* Teacher Notes */}
        <section className="lesson-section">
          <div className="section-header">
            <span className="section-icon">📝</span>
            <h2 className="section-title">Teacher Notes</h2>
          </div>
          <textarea value={notes} onChange={(e) => setNotes(e.target.value)} placeholder="Tips, common issues, time estimates, etc." rows={4} className="form-textarea" />
        </section>

        {/* Submit Buttons */}
        <div className="form-actions">
          <button type="button" onClick={() => navigate('/lessons')} className="btn btn-secondary">
            Cancel
          </button>
          <button type="submit" disabled={saving} className="btn btn-primary">
            <Save size={16} />
            {saving ? 'Saving...' : (isEditMode ? 'Update Lesson Plan' : 'Create Lesson Plan')}
          </button>
        </div>
      </form>
    </div>
  );
}
