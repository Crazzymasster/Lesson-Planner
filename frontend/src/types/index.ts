// TypeScript types for the application

export interface LessonPlan {
  id: number;
  title: string;
  description: string;
  language: string; // python, javascript, java, cpp, csharp, etc.
  category: string; // e.g., 'Variables', 'Loops', 'Functions', 'OOP'
  targetAge: string;
  duration: number; // in minutes
  difficulty: 'Beginner' | 'Intermediate' | 'Advanced';
  points: number; // Points awarded for completing this lesson
  folderId?: number; // Optional folder ID for organization
  prerequisites: string;
  learningOutcomes: string;
  topics: string[];
  objectives: string[];
  materials: string[];
  activities: Activity[];
  steps: LessonStep[];
  challenges: LessonChallenge[];
  project?: LessonProject;
  codeSnippets: CodeSnippet[];
  notes: string;
  createdAt: string;
  updatedAt: string;
}

export interface LessonFolder {
  id: number;
  name: string;
  description?: string;
  color: string;
  orderIndex: number;
  lessonCount: number;
  lessons?: LessonPlan[];
  createdAt?: string;
  updatedAt?: string;
}

export interface LessonStep {
  id: number;
  stepNumber: number;
  title: string;
  instruction: string;
  codeExample?: string;
  expectedOutput?: string;
  explanation: string;
  hints?: string;
}

export interface LessonChallenge {
  id: number;
  order: number;
  title: string;
  description: string;
  starterCode?: string;
  solution: string;
  difficulty: 'Easy' | 'Medium' | 'Hard';
  points: number;
}

export interface LessonProject {
  id: number;
  title: string;
  description: string;
  requirements: string;
  starterCode?: string;
  solutionCode: string;
  extensionIdeas?: string;
}

export interface Activity {
  id: number;
  order: number;
  title: string;
  description: string;
  duration: number;
  type: 'lecture' | 'hands-on' | 'discussion' | 'game' | 'project';
}

export interface CodeSnippet {
  id: number;
  title: string;
  language: string;
  code: string;
  explanation: string;
  difficulty: 'Beginner' | 'Intermediate' | 'Advanced';
}

export interface Student {
  id: number;
  name: string;
  age: number;
  skillLevel: 'Beginner' | 'Intermediate' | 'Advanced';
  groupId?: number;
  groupName?: string;
  email?: string;
  parentEmail?: string;
  notes?: string;
  isActive: boolean;
  languages: StudentLanguage[];
  progress: StudentProgress[];
  languageCount?: number;
  totalLessons?: number;
  completedLessons?: number;
  totalPointsEarned?: number; // Total points earned across all lessons
  createdAt: string;
  updatedAt: string;
}

export interface StudentLanguage {
  id?: number;
  studentId?: number;
  language: string;
  proficiencyLevel: 'Beginner' | 'Intermediate' | 'Advanced' | 'Expert';
  startedAt?: string;
  lastPracticedAt?: string;
  notes?: string;
}

export interface StudentProgress {
  id?: number;
  studentId?: number;
  lessonId: number;
  lessonTitle?: string;
  lessonLanguage?: string;
  lessonDifficulty?: string;
  status: 'Not Started' | 'In Progress' | 'Completed' | 'Mastered';
  completedAt?: string;
  score?: number;
  pointsEarned?: number; // Points earned from this lesson
  timeSpentMinutes?: number;
  notes?: string;
}

export interface StudentGroup {
  id: number;
  name: string;
  description: string;
  studentIds: number[];
  averageAge: number;
  skillLevel: 'Beginner' | 'Intermediate' | 'Advanced';
}

export interface AIGenerateRequest {
  topic: string;
  targetAge: string;
  duration: number;
  difficulty: 'Beginner' | 'Intermediate' | 'Advanced';
  additionalContext?: string;
  includeFinalProject?: boolean;
}

export interface AIGenerateResponse {
  title: string;
  description: string;
  objectives: string[];
  activities: Omit<Activity, 'id'>[];
  materials: string[];
  codeSnippets: Omit<CodeSnippet, 'id'>[];
  tips: string[];
}

export interface Topic {
  id: number;
  name: string;
  category: string;
  description: string;
  prerequisites: string[];
}
