export type TaskPriority =
  | 'urgentImportant'
  | 'urgentNotImportant'
  | 'notUrgentImportant'
  | 'notUrgentNotImportant';

export interface TaskStep {
  title: string;
  estimatedMinutes: number;
  isCompleted?: boolean;
}

export interface Task {
  id: string;
  title: string;
  priority: TaskPriority;
  steps: TaskStep[];
  estimatedMinutes: number;
  notes?: string;
  isCompleted?: boolean;
  createdAt: string;
  updatedAt: string;
  source?: 'manual' | 'gmail' | 'whatsapp' | 'sms';
  sourceId?: string;
}
