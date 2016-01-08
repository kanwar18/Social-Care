/*************************************************************************************************************************
Class Name:  Social_SendAnEmailUtility
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: This class is a generic method to send an email.
**************************************************************************************************************************/

public class Social_SendAnEmailUtility {
  
    public static void sendEmail(string subject,list<String> sendTo,string body , string setSenderDisplayName){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName(setSenderDisplayName);
        mail.setToAddresses(sendTo);
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        mails.add(mail);
        Messaging.sendEmail(mails); 
        
    }

}