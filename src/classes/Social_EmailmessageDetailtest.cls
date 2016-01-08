@isTest
public class Social_EmailmessageDetailtest{
    static TestMethod void Social_EmailmessageDetail(){
        Case c = new Case();
        c.status = 'New';
        c.OwnerId = UserInfo.getUserid();
        insert c;
        
        EmailMessage em = new EmailMessage();
        em.parentId = c.id;
        em.Fromaddress = 'test1@idc.com' ;
        insert em ;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(em);
        Social_EmailmessageDetail sem = new Social_EmailmessageDetail (sc);
    }

    static TestMethod void Social_EmailmessageDetailtest(){
        Case cs = new Case();
        cs.status = 'Closed';
        cs.OwnerId = UserInfo.getUserid();
        insert cs;
        
        EmailMessage emg = new EmailMessage();
        emg.parentId = cs.id;
        emg.Fromaddress = 'test2@idc.com' ;
        insert emg ;
        
        ApexPages.StandardController scs = new ApexPages.StandardController(emg);
        Social_EmailmessageDetail semg = new Social_EmailmessageDetail (scs);
    }
    
    static TestMethod void Social_EmailMessageDeleteTest(){
        Profile p1 = [select id, name from profile where name = 'Care Manager'];
        User u2 = new User(alias = 's4564', email='standarduser143@testorg.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  username='standarduser143777@accenture.com', Receive_SLA_Missed_Notification_Email__c= true, MyLogin_Email_Notification__c= true);
        insert u2;
        system.runAs(u2) { 
            Case cs = new Case();
            cs.status = 'New';
            cs.OwnerId = u2.Id;
            insert cs;
            
            EmailMessage emg = new EmailMessage();
            emg.parentId = cs.id;
            emg.Fromaddress = 'test3@idc.com' ;
            insert emg;
            try {
                delete emg;
            } catch (Exception ex) {
            
            }
        }
    }
}