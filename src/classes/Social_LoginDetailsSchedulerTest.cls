@isTest(seeAllData=True)
public class Social_LoginDetailsSchedulerTest{
    public static TestMethod void Social_LoginDetailsSchedulerTestMethod(){ 
        Profile p1 = [select id, name from profile where name='Operations Manager'];
        User u2 = new User(alias = 's143', email='standarduser143@testorg.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  username='standarduser143@accenture.com', Receive_SLA_Missed_Notification_Email__c= true, MyLogin_Email_Notification__c= true);
          insert u2;
          ApexPages.currentPage().getParameters().put('id', u2.Id);
        
       String strCronExp = '0 0 20 * * ? 2022';
       Test.startTest();
       
             Social_LoginDetailsScheduler sld= new Social_LoginDetailsScheduler();
             String jobId = system.schedule('test', strCronExp, sld);
             CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger where id = :jobId];        
             System.assertEquals(strCronExp, ct.CronExpression);
             
       Test.stopTest(); 
        
                      
        }
    }