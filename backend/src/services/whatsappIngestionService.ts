import axios from 'axios';
import { v4 as uuid } from 'uuid';
import { TaskService } from './taskService.js';

interface WhatsAppConfig {
  businessAccountId: string;
  accessToken: string;
  since?: string;
}

export class WhatsAppIngestionService {
  constructor(private readonly taskService: TaskService) {}

  async ingest(config: WhatsAppConfig) {
    const { businessAccountId, accessToken, since } = config;
    const url = `https://graph.facebook.com/v21.0/${businessAccountId}/messages`;
    const response = await axios.get(url, {
      params: { limit: 10, since },
      headers: { Authorization: `Bearer ${accessToken}` },
    });

    const messages: Array<Record<string, any>> = response.data.data ?? [];
    for (const message of messages) {
      if (!message.id) continue;
      const text = message.text?.body ?? 'WhatsApp follow-up';
      await this.taskService.create({
        id: uuid(),
        title: text.substring(0, 60),
        priority: 'urgentNotImportant',
        steps: [
          {
            title: 'Reply on WhatsApp',
            estimatedMinutes: 5,
          },
        ],
        estimatedMinutes: 5,
        notes: text,
        source: 'whatsapp',
        sourceId: message.id,
      });
    }
  }
}
