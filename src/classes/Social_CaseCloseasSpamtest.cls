@istest
public class Social_CaseCloseasSpamtest{
    
    public Profile careProfile;
    static User testUser;
    static QueueSobject spanishQueue;
    static Assignment_Group_Name__c spanishGroupName;
    static Case testCase;
    static Case testCase1;
    static Case testCase2;
    public static List<Case> testCaseList = new List<Case>();    
    public static List<User> testUserList= new List<User>();
    static Account testAccount;
    static Contact testContact;
    static Assignment_Group_Name__c ag;
    static Profile careProfile;
    
    static{
        
                careProfile = new Profile();
                careProfile = [select id, name from profile where name='Care Manager'];
                testUser = new User(alias = 's128', email='standarduser128@testorg.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = careProfile.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available', username='standarduser128@accenture.com', Case_Counter__c = 10); 
                testUserList.add(testUser);
                insert testUserList; 
                
                ag =  new Assignment_Group_Name__c();
                ag.Name = 'Spanish';
                ag.Type__c = 'Cases';
                insert ag;
                                
                // Query Queue(Mobility/U-Verse)        
                spanishQueue = [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name = 'Spanish' limit 1];
                
                // Query Assignment Group(Mobility/U-Verse)        
                spanishGroupName = [Select a.Name, a.Id From Assignment_Group_Name__c a where a.Name='Spanish' limit 1];
                
                
                testAccount=new Account();
                testAccount.Name='testAccount';
                insert testAccount;                
                
                testContact=new Contact();        
                testContact.AccountId=testAccount.Id;        
                testContact.LastName='testName';        
                testContact.email='testemail@abc.com';        
                testContact.Account = testAccount;        
                insert testContact; 
                
                
                // Insert Case        
                testCase = new Case();
                testCase.ContactId = testContact.Id;
                testCase.Status = 'New';
                testCase.Origin = 'Social Hub';
                testCase.case_posttag__c = '';
                testCase.ContactId = testContact.Id;
                testCase.OwnerId = testUserList[0].Id;
                testCaseList.add(testCase);
                
                testCase1 = new Case();
                testCase1.ContactId = testContact.Id;
                testCase1.Status = 'New';
                testCase1.Origin = 'Social Hub';
                testCase1.case_posttag__c = '';
                testCase1.ContactId = testContact.Id;
                testCase1.OwnerId = testUserList[0].Id;
                testCaseList.add(testCase1);
                
                testCase2 = new Case();
                testCase2.ContactId = testContact.Id;
                testCase2.Status = 'New';
                testCase2.Origin = 'Social Hub';
                testCase2.case_posttag__c = 'General';
                testCase2.ContactId = testContact.Id;
                testCase2.OwnerId = testUserList[0].Id;
                testCaseList.add(testCase2);
                
                insert testCaseList;   
                
                          
         }


    static testmethod void Social_CaseCloseasSpamtestMethod1(){
        
        ApexPages.currentPage().getParameters().put('id' ,  testCase.id);
        ApexPages.currentPage().getParameters().put('pid' , careProfile.id);
        
        Apexpages.standardcontroller controller = new Apexpages.standardcontroller(testCase);
        Social_CaseCloseasSpam testObj =  new Social_CaseCloseasSpam(controller);
        testObj.Closeasspam();
        
        
        testCase.ownerId = testUser.id;
        testCase.Current_SLA_Phase__c = 'SLA1 - Initiated';
        testCase.case_posttag__c = 'WIRELESS';
        update testCase;
       
        Event slaEvent = new Event();
        slaEvent.WhatId = testCase.Id;
        slaEvent.Event_Type__c='SLA - 1';
        slaEvent.Event_Status__c = 'Open';
        slaEvent.Description = 'SLA-1 Event';
        slaEvent.StartDateTime = System.now();
        slaEvent.DurationInMinutes = 15;
        slaEvent.IsReminderSet = true;
        slaEvent.ReminderDateTime = System.now().addMinutes(5);
        slaEvent.Subject = 'SLA-1 Type Event';
        insert slaEvent;
       
        // Update SLA-3 Event Closed
        slaEvent.Event_Status__c='Closed';
        update slaEvent;
        
        ApexPages.currentPage().getParameters().put('pid' , null);
        testObj.Closeasspam();
        
    }

    static testmethod void Social_CaseCloseasSpamtestMethod2(){
        
        ApexPages.currentPage().getParameters().put('id' ,  testCase.id);
        ApexPages.currentPage().getParameters().put('pid' , '');
        
        Apexpages.standardcontroller controller = new Apexpages.standardcontroller(testCase);
        Social_CaseCloseasSpam testObj =  new Social_CaseCloseasSpam(controller);
        testObj.Closeasspam();
        
        
        testCase.ownerId = testUser.id;
        testCase.Current_SLA_Phase__c = 'SLA2 - Initiated';
        update testCase;
       
        Event slaEvent = new Event();
        slaEvent.WhatId = testCase.Id;
        slaEvent.Event_Type__c='SLA - 2';
        slaEvent.Event_Status__c = 'Open';
        slaEvent.Description = 'SLA-2 Event';
        slaEvent.StartDateTime = System.now();
        slaEvent.DurationInMinutes = 60;
        slaEvent.IsReminderSet = true;
        slaEvent.ReminderDateTime = System.now().addMinutes(5);
        slaEvent.Subject = 'SLA-2 Type Event';
        insert slaEvent;
       
        // Update SLA-3 Event Closed
        slaEvent.Event_Status__c='Closed';
        update slaEvent;
        
        ApexPages.currentPage().getParameters().put('pid' , null);
        testObj.Closeasspam();
        
    }
    
    static testmethod void Social_CaseCloseasSpamtestMethod3(){
        
        ApexPages.currentPage().getParameters().put('id' ,  testCase.id);
        ApexPages.currentPage().getParameters().put('pid' , '');
        
        Apexpages.standardcontroller controller = new Apexpages.standardcontroller(testCase);
        Social_CaseCloseasSpam testObj =  new Social_CaseCloseasSpam(controller);
        testObj.Closeasspam();
        
        
        testCase.ownerId = testUser.id;
        testCase.Current_SLA_Phase__c = 'SLA3 - Initiated';
        testCase.case_posttag__c = 'U-VERSE';
        update testCase;
       
        Event slaEvent = new Event();
        slaEvent.WhatId = testCase.Id;
        slaEvent.Event_Type__c='SLA - 3';
        slaEvent.Event_Status__c = 'Open';
        slaEvent.Description = 'SLA-3 Event';
        slaEvent.StartDateTime = System.now();
        slaEvent.DurationInMinutes = 10;
        slaEvent.IsReminderSet = true;
        slaEvent.ReminderDateTime = System.now().addMinutes(5);
        slaEvent.Subject = 'SLA-3 Type Event';
        insert slaEvent;
       
        // Update SLA-3 Event Closed
        slaEvent.Event_Status__c='Closed';
        update slaEvent;
        
        ApexPages.currentPage().getParameters().put('pid' , null);
        testObj.Closeasspam();
        
    }
}