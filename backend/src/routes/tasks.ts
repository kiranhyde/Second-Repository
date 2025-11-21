import { Router } from 'express';
import { TaskService } from '../services/taskService.js';

export const createTaskRouter = (taskService: TaskService) => {
  const router = Router();

  router.get('/', async (_req, res, next) => {
    try {
      const tasks = await taskService.list();
      res.json(tasks);
    } catch (error) {
      next(error);
    }
  });

  router.post('/', async (req, res, next) => {
    try {
      const task = await taskService.create(req.body);
      res.status(201).json(task);
    } catch (error) {
      next(error);
    }
  });

  return router;
};
