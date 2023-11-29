public class MailerUtils {
    public static void sendEmail(Messaging.SingleEmailMessage email) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        emails.add(email);
        try {
        	Messaging.sendEmail(emails);    
        } catch(Exception e) {
        }
    }
}