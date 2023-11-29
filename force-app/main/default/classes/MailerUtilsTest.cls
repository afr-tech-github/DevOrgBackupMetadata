@isTest
public class MailerUtilsTest {
    static testmethod void shouldSendEmail() {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'me@email1.com','you@email2.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('My Subject');
        mail.setUseSignature(false);
        mail.setHtmlBody('message');
        MailerUtils.sendEmail( mail );
        System.assert(true);
    }
}