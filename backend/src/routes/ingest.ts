import { Router } from 'express';
import { GmailIngestionService } from '../services/gmailIngestionService.js';
import { WhatsAppIngestionService } from '../services/whatsappIngestionService.js';
import { SmsIngestionService } from '../services/smsIngestionService.js';

export const createIngestionRouter = (
  gmailService: GmailIngestionService,
  whatsappService: WhatsAppIngestionService,
  smsService: SmsIngestionService,
) => {
  const router = Router();

  router.post('/gmail', async (req, res, next) => {
    try {
      const { oauthToken, maxMessages } = req.body;
      await gmailService.ingest(oauthToken, maxMessages);
      res.status(202).json({ status: 'queued' });
    } catch (error) {
      next(error);
    }
  });

  router.post('/whatsapp', async (req, res, next) => {
    try {
      const body = {
        businessAccountId:
          req.body.businessAccountId || process.env.WHATSAPP_BUSINESS_ACCOUNT_ID,
        accessToken:
          req.body.accessToken || process.env.WHATSAPP_ACCESS_TOKEN,
        since: req.body.since,
      };
      await whatsappService.ingest(body);
      res.status(202).json({ status: 'queued' });
    } catch (error) {
      next(error);
    }
  });

  router.post('/sms', async (req, res, next) => {
    try {
      await smsService.ingest(req.body);
      res.status(202).json({ status: 'queued' });
    } catch (error) {
      next(error);
    }
  });

  return router;
};
