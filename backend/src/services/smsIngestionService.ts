import twilio from 'twilio';
import { v4 as uuid } from 'uuid';
import { TaskService } from './taskService.js';

interface SmsConfig {
  accountSid?: string;
  authToken?: string;
  fromNumber?: string;
  limit?: number;
}

export class SmsIngestionService {
  constructor(private readonly taskService: TaskService) {}

  async ingest(config: SmsConfig) {
    const accountSid = config.accountSid ?? process.env.TWILIO_ACCOUNT_SID;
    const authToken = config.authToken ?? process.env.TWILIO_AUTH_TOKEN;
    const fromNumber = config.fromNumber ?? process.env.TWILIO_PHONE_NUMBER;
    if (!accountSid || !authToken || !fromNumber) {
      throw new Error('Missing SMS credentials');
    }
    const limit = config.limit ?? 5;
    const client = twilio(accountSid, authToken);
    const messages = await client.messages.list({
      to: fromNumber,
      limit,
    });

    for (const message of messages) {
      await this.taskService.create({
        id: uuid(),
        title: message.body?.substring(0, 60) ?? 'SMS follow-up',
        priority: 'notUrgentImportant',
        steps: [
          {
            title: 'Respond via SMS',
            estimatedMinutes: 5,
          },
        ],
        estimatedMinutes: 5,
        notes: message.body ?? '',
        source: 'sms',
        sourceId: message.sid,
      });
    }
  }
}
