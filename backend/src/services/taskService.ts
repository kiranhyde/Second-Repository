import { z } from 'zod';
import { FirestoreService } from './firestoreService.js';
import type { Task } from '../types/task.js';

const stepSchema = z.object({
  title: z.string().min(1),
  estimatedMinutes: z.number().int().positive(),
  isCompleted: z.boolean().optional(),
});

const taskSchema = z.object({
  id: z.string().uuid(),
  title: z.string().min(1),
  priority: z.enum([
    'urgentImportant',
    'urgentNotImportant',
    'notUrgentImportant',
    'notUrgentNotImportant',
  ]),
  steps: z.array(stepSchema),
  estimatedMinutes: z.number().int().positive(),
  notes: z.string().optional(),
  isCompleted: z.boolean().optional(),
  source: z.enum(['manual', 'gmail', 'whatsapp', 'sms']).optional(),
  sourceId: z.string().optional(),
});

export class TaskService {
  constructor(private readonly firestore: FirestoreService) {}

  async list(): Promise<Task[]> {
    const records = await this.firestore.listTasks();
    return records as Task[];
  }

  async create(input: z.infer<typeof taskSchema>): Promise<Task> {
    const payload = taskSchema.parse(input);
    const now = new Date().toISOString();
    const task: Task = {
      ...payload,
      createdAt: now,
      updatedAt: now,
    };
    await this.firestore.createTask(task);
    return task;
  }
}
