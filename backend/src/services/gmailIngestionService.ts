import { google } from 'googleapis';
import { v4 as uuid } from 'uuid';
import { TaskService } from './taskService.js';

export class GmailIngestionService {
  constructor(private readonly taskService: TaskService) {}

  async ingest(oauthToken: string, maxMessages = 10) {
    const auth = new google.auth.OAuth2();
    auth.setCredentials({ access_token: oauthToken });
    const gmail = google.gmail({ version: 'v1', auth });

    const listResponse = await gmail.users.messages.list({
      userId: 'me',
      maxResults: maxMessages,
      q: 'is:unread',
    });

    const messages = listResponse.data.messages ?? [];
    for (const message of messages) {
      if (!message.id) continue;
      const fullMessage = await gmail.users.messages.get({
        userId: 'me',
        id: message.id,
      });
      const snippet = fullMessage.data.snippet ?? '';
      const subjectHeader = fullMessage.data.payload?.headers?.find(
        (header) => header.name?.toLowerCase() === 'subject',
      );
      const title = subjectHeader?.value ?? 'Gmail Task';

      await this.taskService.create({
        id: uuid(),
        title,
        priority: 'urgentImportant',
        steps: [
          {
            title: snippet.substring(0, 80) || 'Review email',
            estimatedMinutes: 5,
          },
        ],
        estimatedMinutes: 5,
        notes: snippet,
        source: 'gmail',
        sourceId: message.id,
      });
    }
  }
}
