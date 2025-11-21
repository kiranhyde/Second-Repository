import express from 'express';
import cors from 'cors';
import morgan from 'morgan';

import { FirestoreService } from './services/firestoreService.js';
import { TaskService } from './services/taskService.js';
import { GmailIngestionService } from './services/gmailIngestionService.js';
import { WhatsAppIngestionService } from './services/whatsappIngestionService.js';
import { createTaskRouter } from './routes/tasks.js';
import { createIngestionRouter } from './routes/ingest.js';
import { SmsIngestionService } from './services/smsIngestionService.js';

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use(morgan('dev'));

const firestore = new FirestoreService();
const taskService = new TaskService(firestore);
const gmailIngestion = new GmailIngestionService(taskService);
const whatsappIngestion = new WhatsAppIngestionService(taskService);
const smsIngestion = new SmsIngestionService(taskService);

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.use('/tasks', createTaskRouter(taskService));
app.use(
  '/ingest',
  createIngestionRouter(gmailIngestion, whatsappIngestion, smsIngestion),
);

// eslint-disable-next-line @typescript-eslint/no-unused-vars
app.use(
  (
    error: any,
    _req: express.Request,
    res: express.Response,
    _next: express.NextFunction,
  ) => {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  },
);

const port = Number(process.env.PORT ?? 8080);
app.listen(port, () => {
  console.log(`API listening on http://localhost:${port}`);
});
