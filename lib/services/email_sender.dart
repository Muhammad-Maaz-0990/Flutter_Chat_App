import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailSender {
  static final String _username = 'muhammadmaaz0017@gmail.com';
  static final String _appPassword = 'ygwdcwlhszvptevu'; // Use app-specific password

  static final SmtpServer _smtpServer = gmail(_username, _appPassword);

  /// Sends a generic email with the given subject and body
  static Future<bool> sendEmail({
    required String toEmail,
    required String subject,
    required String body,
  }) async {
    final message = Message()
      ..from = Address(_username, 'MS-Intouch')
      ..recipients.add(toEmail)
      ..subject = subject
      ..text = body;

    try {
      print('[EmailSender] Sending email to $toEmail...');
      final sendReport = await send(message, _smtpServer);
      print('[EmailSender] Email sent successfully: $sendReport');
      return true;
    } on MailerException catch (e) {
      print('[EmailSender] Email not sent: $e');
      for (var p in e.problems) {
        print('[EmailSender] Problem: ${p.code}: ${p.msg}');
      }
      return false;
    }
  }

  /// Sends a signup OTP email
  static Future<bool> sendSignupOTP({
    required String toEmail,
    required String otp,
  }) async {
    final subject = 'Welcome to MS-Intouch - Verify Your Email';
    final body = '''
Hello,

Thank you for signing up with MS-Intouch!

To complete your registration, please enter the following One-Time Password (OTP):

🔐 OTP: $otp

This OTP is valid for a short period. Do not share it with anyone.

If you did not initiate this signup, please ignore this email.

Regards,  
MS-Intouch Team
''';

    return await sendEmail(toEmail: toEmail, subject: subject, body: body);
  }

  /// Sends a login OTP email
  static Future<bool> sendLoginOTP({
    required String toEmail,
    required String otp,
  }) async {
    final subject = 'MS-Intouch Login Verification Code';
    final body = '''
Hello,

We noticed a login attempt to your MS-Intouch account.

To verify your identity, please enter the following One-Time Password (OTP):

🔐 OTP: $otp

If this wasn’t you, we recommend changing your password immediately.

Stay safe,  
MS-Intouch Security Team
''';

    return await sendEmail(toEmail: toEmail, subject: subject, body: body);
  }
}
