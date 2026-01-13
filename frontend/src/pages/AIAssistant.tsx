import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { aiService } from '@/services/api';
import type { AIGenerateRequest } from '@/types';
import { Sparkles, Loader2 } from 'lucide-react';
import './AIAssistant.css';

export default function AIAssistant() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState<AIGenerateRequest>({
    topic: '',
    targetAge: '',
    duration: 60,
    difficulty: 'Beginner',
    additionalContext: '',
    includeFinalProject: false,
  });
  const [generating, setGenerating] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setGenerating(true);
    
    try {
      console.log('Sending AI request with data:', formData);
      const response = await aiService.generateLesson(formData);
      console.log('AI API full response:', response);
      console.log('Response data:', response.data);
      console.log('Response data type:', typeof response.data);
      
      // Check if response contains error
      if (response.data && response.data.error) {
        console.error('Backend error:', response.data);
        alert(`Backend Error: ${response.data.error}\n\nDetails: ${response.data.message || response.data.detail || 'No details'}\n\nAI Content: ${response.data.aiContent || 'N/A'}`);
        return;
      }
      
      // Parse the response if it's a string
      let aiResult = response.data;
      if (typeof aiResult === 'string') {
        console.log('Response is a string, parsing JSON...');
        // Trim whitespace and newlines before parsing
        const trimmedData = aiResult.trim();
        console.log('Trimmed data:', trimmedData);
        console.log('Trimmed data length:', trimmedData.length);
        
        if (!trimmedData) {
          console.error('Trimmed data is empty!');
          alert('AI API returned empty response. Please check the backend logs.');
          return;
        }
        
        try {
          aiResult = JSON.parse(trimmedData);
        } catch (parseError) {
          console.error('JSON parse error:', parseError);
          console.error('Failed to parse:', trimmedData);
          alert('Failed to parse AI response. Check console for details.');
          return;
        }
      }
      
      console.log('Parsed AI result:', aiResult);
      console.log('AI result keys:', aiResult ? Object.keys(aiResult) : 'no data');
      
      // Check if we got actual data
      if (!aiResult || Object.keys(aiResult).length === 0) {
        console.error('AI returned empty data!');
        alert('AI returned empty data. Please check your API key and try again.');
        return;
      }
      
      // Convert AI result to lesson plan format and navigate to create page
      const lessonData = {
        title: aiResult?.title || `Introduction to ${formData.topic}`,
        description: aiResult?.description || '',
        language: 'python',
        category: formData.topic,
        difficulty: formData.difficulty,
        targetAge: formData.targetAge,
        duration: formData.duration,
        points: formData.difficulty === 'Beginner' ? 10 : formData.difficulty === 'Intermediate' ? 20 : 30,
        prerequisites: '',
        learningOutcomes: (aiResult?.objectives && Array.isArray(aiResult.objectives)) ? aiResult.objectives.join('\n') : '',
        topics: [formData.topic],
        materials: (aiResult?.materials && Array.isArray(aiResult.materials)) ? aiResult.materials : [],
        notes: (aiResult?.tips && Array.isArray(aiResult.tips)) ? aiResult.tips.join('\n') : '',
        objectives: (aiResult?.objectives && Array.isArray(aiResult.objectives)) ? aiResult.objectives : [],
        steps: (aiResult?.activities && Array.isArray(aiResult.activities)) ? aiResult.activities.map((activity: any, idx: number) => {
          // Steps contain teaching code examples from the AI
          return {
            stepNumber: idx + 1,
            title: activity?.title || `Step ${idx + 1}`,
            instruction: activity?.description || '',
            codeExample: activity?.codeExample || '',
            expectedOutput: '',
            explanation: `${activity?.type || 'Activity'} - ${activity?.duration || 15} minutes`,
            hints: aiResult?.tips?.[idx] || ''
          };
        }) : [{
          stepNumber: 1,
          title: 'Getting Started',
          instruction: 'Follow along with the lesson',
          codeExample: '',
          expectedOutput: '',
          explanation: '',
          hints: ''
        }],
        challenges: (aiResult?.challenges && Array.isArray(aiResult.challenges)) ? aiResult.challenges.map((challenge: any, idx: number) => {
          // Challenges are practice problems with minimal starter code
          return {
            order: idx + 1,
            title: challenge?.title || `Challenge ${idx + 1}`,
            description: challenge?.description || 'Use what you learned to solve this problem',
            difficulty: formData.difficulty === 'Beginner' ? 'Easy' : formData.difficulty === 'Intermediate' ? 'Medium' : 'Hard',
            starterCode: challenge?.starterCode || '# Write your solution here',
            solution: challenge?.solution || '',
            points: formData.difficulty === 'Beginner' ? 10 : formData.difficulty === 'Intermediate' ? 15 : 20
          };
        }) : [{
          order: 1,
          title: 'Practice Challenge',
          description: 'Apply what you learned',
          difficulty: 'Easy',
          starterCode: '# Write your code here\n',
          solution: '# Solution will be provided',
          points: 10
        }],
        hasProject: formData.includeFinalProject && aiResult?.project ? true : false,
        project: (formData.includeFinalProject && aiResult?.project) ? {
          title: aiResult.project.title || 'Final Project',
          description: aiResult.project.description || '',
          requirements: aiResult.project.requirements || '',
          starterCode: aiResult.project.starterCode || '',
          solution: aiResult.project.solution || '',
          extensionIdeas: aiResult.project.extensionIdeas || ''
        } : undefined
      };
      
      console.log('Final lesson data to navigate with:', lessonData);
      console.log('Has project?', lessonData.hasProject);
      console.log('Project data:', lessonData.project);
      
      // Navigate to create lesson page with AI-generated data
      navigate('/lessons/new', { state: { aiGenerated: lessonData } });
      
    } catch (error: any) {
      console.error('Error generating lesson:', error);
      console.error('Error response:', error.response);
      console.error('Error response data:', error.response?.data);
      
      let errorMessage = 'Failed to generate lesson. ';
      if (error.response?.data) {
        const errorData = error.response.data;
        errorMessage += `\n\nError: ${errorData.error || 'Unknown error'}`;
        if (errorData.message) errorMessage += `\nMessage: ${errorData.message}`;
        if (errorData.detail) errorMessage += `\nDetail: ${errorData.detail}`;
        if (errorData.aiContent) errorMessage += `\n\nAI Response Preview: ${errorData.aiContent.substring(0, 200)}...`;
      } else {
        errorMessage += error.message || 'Unknown error';
      }
      
      alert(errorMessage);
    } finally {
      setGenerating(false);
    }
  };

  return (
    <div className="ai-assistant">
      <div className="ai-header">
        <Sparkles size={32} />
        <h1>AI Lesson Assistant</h1>
        <p>Let AI help you create engaging lesson plans</p>
      </div>

      <div className="ai-content">
        <form onSubmit={handleSubmit} className="ai-form">
          <div className="form-group">
            <label htmlFor="topic">Topic *</label>
            <input
              id="topic"
              type="text"
              value={formData.topic}
              onChange={(e) => setFormData({ ...formData, topic: e.target.value })}
              placeholder="e.g., Python loops, HTML basics, Game development"
              required
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label htmlFor="targetAge">Target Age *</label>
              <input
                id="targetAge"
                type="text"
                value={formData.targetAge}
                onChange={(e) => setFormData({ ...formData, targetAge: e.target.value })}
                placeholder="e.g., 8-10, 12-14"
                required
              />
            </div>

            <div className="form-group">
              <label htmlFor="duration">Duration (minutes) *</label>
              <input
                id="duration"
                type="number"
                value={formData.duration}
                onChange={(e) => setFormData({ ...formData, duration: Number(e.target.value) })}
                min="15"
                max="180"
                required
              />
            </div>

            <div className="form-group">
              <label htmlFor="difficulty">Difficulty *</label>
              <select
                id="difficulty"
                value={formData.difficulty}
                onChange={(e) => setFormData({ ...formData, difficulty: e.target.value as any })}
              >
                <option value="Beginner">Beginner</option>
                <option value="Intermediate">Intermediate</option>
                <option value="Advanced">Advanced</option>
              </select>
            </div>
          </div>

          <div className="form-group">
            <label htmlFor="context">Additional Context (Optional)</label>
            <textarea
              id="context"
              value={formData.additionalContext}
              onChange={(e) => setFormData({ ...formData, additionalContext: e.target.value })}
              placeholder="Any specific requirements, learning objectives, or constraints..."
              rows={4}
            />
          </div>

          <div className="form-group checkbox-group">
            <label className="checkbox-label">
              <input
                type="checkbox"
                checked={formData.includeFinalProject || false}
                onChange={(e) => setFormData({ ...formData, includeFinalProject: e.target.checked })}
              />
              <span>Generate Final Project</span>
            </label>
            <p className="form-hint">Create a comprehensive project that challenges students to apply what they learned</p>
          </div>

          <button type="submit" className="btn btn-primary btn-generate" disabled={generating}>
            {generating ? (
              <>
                <Loader2 size={20} className="spinner" />
                Generating...
              </>
            ) : (
              <>
                <Sparkles size={20} />
                Generate Lesson Plan
              </>
            )}
          </button>
        </form>
      </div>
    </div>
  );
}
