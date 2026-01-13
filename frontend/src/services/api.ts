import axios from 'axios';
import type { 
  LessonPlan, 
  CodeSnippet, 
  Student, 
  StudentGroup, 
  AIGenerateRequest, 
  AIGenerateResponse, 
  Topic,
  LessonFolder 
} from '@/types';

const api = axios.create({
  baseURL: '/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Lesson Plans
export const lessonPlanService = {
  getAll: () => api.get<LessonPlan[]>('/lessons'),
  getById: (id: number) => api.get<LessonPlan>(`/lessons?id=${id}`),
  create: (data: Omit<LessonPlan, 'id' | 'createdAt' | 'updatedAt'>) => 
    api.post<LessonPlan>('/lessons', data),
  update: (id: number, data: Partial<LessonPlan>) => 
    api.put<LessonPlan>(`/lessons?id=${id}`, data),
  delete: (id: number) => api.delete(`/lessons?id=${id}`),
  search: (query: string) => api.get<LessonPlan[]>(`/lessons/search?q=${query}`),
};

// Code Snippets
export const codeSnippetService = {
  getAll: () => api.get<CodeSnippet[]>('/snippets'),
  getById: (id: number) => api.get<CodeSnippet>(`/snippets?id=${id}`),
  create: (data: Omit<CodeSnippet, 'id'>) => api.post<{ success: boolean; id: number }>('/snippets', data),
  update: (id: number, data: Partial<CodeSnippet>) => 
    api.put<{ success: boolean }>(`/snippets?id=${id}`, data),
  delete: (id: number) => api.delete<{ success: boolean }>(`/snippets?id=${id}`),
  getByLanguage: (language: string) => 
    api.get<CodeSnippet[]>(`/snippets/language/${language}`),
};

// Students
export const studentService = {
  getAll: () => api.get<Student[]>('/students'),
  getById: (id: number) => api.get<Student>(`/students?id=${id}`),
  create: (data: Omit<Student, 'id' | 'createdAt' | 'updatedAt' | 'progress' | 'languageCount' | 'totalLessons' | 'completedLessons'>) => 
    api.post<{ success: boolean; id: number }>('/students', data),
  update: (id: number, data: Partial<Student>) => 
    api.put<{ success: boolean }>(`/students?id=${id}`, data),
  delete: (id: number) => api.delete<{ success: boolean }>(`/students?id=${id}`),
};

// Student Groups
export const studentGroupService = {
  getAll: () => api.get<StudentGroup[]>('/groups'),
  getById: (id: number) => api.get<StudentGroup>(`/groups/${id}`),
  create: (data: Omit<StudentGroup, 'id'>) => api.post<StudentGroup>('/groups', data),
  update: (id: number, data: Partial<StudentGroup>) => 
    api.put<StudentGroup>(`/groups/${id}`, data),
  delete: (id: number) => api.delete(`/groups/${id}`),
};

// Topics
export const topicService = {
  getAll: () => api.get<Topic[]>('/topics'),
  getByCategory: (category: string) => api.get<Topic[]>(`/topics/category/${category}`),
};

// AI Service
export const aiService = {
  generateLesson: (request: AIGenerateRequest) => 
    api.post<AIGenerateResponse>('/ai/generate-lesson', request),
  suggestActivities: (topic: string, duration: number) => 
    api.post('/ai/suggest-activities', { topic, duration }),
  improveDescription: (description: string) => 
    api.post('/ai/improve-description', { description }),
};

// Progress Service - Track student lesson completion
export const progressService = {
  markComplete: (studentId: number, lessonId: number) => 
    api.post<{ success: boolean; pointsAwarded: number; message: string }>('/progress', { studentId, lessonId }),
  removeProgress: (studentId: number, lessonId: number) => 
    api.delete(`/progress?studentId=${studentId}&lessonId=${lessonId}`),
};

// Folder Service - Organize lesson plans
export const folderService = {
  getAll: () => api.get<LessonFolder[]>('/folders'),
  getById: (id: number) => api.get<LessonFolder>(`/folders?id=${id}`),
  create: (data: Pick<LessonFolder, 'name' | 'description' | 'color' | 'orderIndex'>) => 
    api.post<{ success: boolean; id: number }>('/folders', data),
  update: (id: number, data: Partial<Pick<LessonFolder, 'name' | 'description' | 'color' | 'orderIndex'>>) => 
    api.put<{ success: boolean }>(`/folders?id=${id}`, data),
  delete: (id: number) => api.delete<{ success: boolean }>(`/folders?id=${id}`),
};

export default api;
