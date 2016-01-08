@isTest(SeeAllData=True)
public class Social_TriggerEvent_Test {
    
    static Account testAccount;
    static Contact testContact;
    static Case testCase;
    static Event testEvent;
    static User user1;
    static User user2;
    
    // Static Queue
    static QueueSobject mobilityQueue;
    
    // Static Assgn Group
    static Assignment_Group_Name__c mobilityGroupName;
    
    static{
        
        testAccount=new Account();
        testAccount.Name='testAccount';
        insert testAccount;
        
        testContact=new Contact();
        testContact.AccountId=testAccount.Id;
        testContact.LastName='testName';
        testContact.email='testemail@abc.com';
        testContact.Account = testAccount;
        insert testContact;  
        
        Profile careProfile = [select id, name from profile where name='Care Manager'];
        
        user1 = new User(alias = 's150', 
        email='standarduser150@testorg.com',    
        emailencodingkey='UTF-8',
        lastname='Testing', 
        languagelocalekey='en_US',  
        localesidkey='en_US',
        profileid = careProfile.Id, 
        isactive=true,    
        timezonesidkey='America/Los_Angeles',
        Availability__c='Pause',  
        username='standarduser150@accenture.com',
        Case_Counter__c=0);      
        insert user1;
        
        // Query Queue(DSL/U-Verse)
        mobilityQueue = [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where
                    q.Queue.Name = 'Mobility' limit 1];
        
        // Query Assignment Group(DSL/U-Verse)
        mobilityGroupName = [Select a.Name, a.Id From Assignment_Group_Name__c a where 
                        a.Name='Mobility' limit 1];
        
        // Insert Case
        testCase = new Case();
        testCase.ContactId=testContact.Id;
        testCase.Status='New';
        testCase.Origin='email';
        testCase.ContactId=testContact.Id;
        testCase.OwnerId = mobilityQueue.QueueId;
        insert testCase;    
    }
    
    // Test Method For Social_EventSlaValidation / Social_EventSlaTracker
    public static testmethod void Test_Social_EventSlaTracker(){
        Test.startTest();
        // Update Case
        testCase.First_SLA_Response_Time__c = System.now();
        testCase.First_SLA_Scheduled_Time__c = System.now().addMinutes(10);
        testCase.Second_SLA_Response_Time__c = System.now().addMinutes(12);
        testCase.Second_SLA_Scheduled_Time__c = System.now().addMinutes(20);
        testCase.Current_SLA_Phase__c = 'SLA2 - Ended';
        update testCase;
        
        // Insert Event(SLA-3)
        Event sla3Event = new Event();
        sla3Event.WhatId = testCase.Id;
        sla3Event.Event_Type__c='SLA - 3';
        sla3Event.Event_Status__c = 'Open';
        sla3Event.Description = 'SLA-3 Event';
        sla3Event.StartDateTime = System.now();
        sla3Event.DurationInMinutes = 15;
        sla3Event.IsReminderSet = true;
        sla3Event.ReminderDateTime = System.now().addMinutes(5);
        sla3Event.Subject = 'SLA-3 Type Event';
        insert sla3Event;
       
        // Update SLA-3 Event Closed
        sla3Event.Event_Status__c='Closed';
        update sla3Event;
        Test.stopTest();
    }
    
    // Test Method For Social_UserAvailabilityCheck
    public static testMethod void Social_UserAvailabilityCheck_TestMethod(){
         
         // Add Assignment Members(Care Managers)
         Assignment_Groups__c careMan1 = new Assignment_Groups__c();
         careMan1.User__c = user1.Id;
         careMan1.Group_Name__c = mobilityGroupName.Id;
         insert careMan1;
         
         // New Case In Queue
         Case queueCase = new Case();
         queueCase.ContactId=testContact.Id;
         queueCase.Status='New';
         queueCase.Origin='email';
         queueCase.ContactId=testContact.Id;
         queueCase.OwnerId = mobilityQueue.QueueId;
         insert queueCase;
         
         queueCase.Case_Assigned_Time__c = System.now();
         queueCase.First_SLA_Scheduled_Time__c = System.now().addMinutes(15);
         queueCase.Current_SLA_Phase__c = 'SLA1 - Ended';
         queueCase.Customer_Response_Received__c = true;
         queueCase.Pending_Second_SLA_Task_Creation__c = true;
         update queueCase;
         
         // Make User Available
         user1.Availability__c = 'Available';
         update user1;
    }
    
    // Test Method For Social_caseEmailValidator
    public static testMethod void Social_caseEmailValidator_TestMethod(){
        
        System.runAs(user1){
            
            EmailMessage caseEmail = new EmailMessage(); 
            caseEmail.FromAddress = 'abc@gmail.com';
            caseEmail.ToAddress = 'def@gmail.com';
            caseEmail.FromName = 'Test Email';
            caseEmail.Subject = 'Test Email Subject';
            caseEmail.TextBody = 'Text Email Body';
            caseEmail.ParentId = testCase.Id; 
            insert caseEmail;  
        }
    }
    
 }