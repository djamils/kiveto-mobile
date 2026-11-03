/// Where a new sign-in code is sent: by SMS, or by email (honoured by the
/// server only for an account with a verified email; it answers the same
/// either way).
enum OtpChannel { sms, email }
