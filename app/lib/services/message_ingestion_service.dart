import 'gmail_service.dart';
import 'sms_service.dart';
import 'whatsapp_service.dart';

/// High-level service to orchestrate ingestion triggers.
class MessageIngestionService {
  MessageIngestionService({
    required this.gmailService,
    required this.whatsAppService,
    required this.smsService,
  });

  final GmailService gmailService;
  final WhatsAppService whatsAppService;
  final SmsService smsService;

  Future<void> ingestGmail(String oauthToken) async {
    await gmailService.ingestMessages(oauthToken: oauthToken);
  }

  Future<void> ingestWhatsApp({
    required String businessAccountId,
    required String accessToken,
  }) async {
    await whatsAppService.ingestMessages(
      businessAccountId: businessAccountId,
      accessToken: accessToken,
    );
  }

  Future<void> ingestSms() async {
    await smsService.ingestMessages();
  }
}
