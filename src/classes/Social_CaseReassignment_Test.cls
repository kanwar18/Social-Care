/********************************************************************************************************
*    Author: Arun Ramachandran
*    Test Class for : Social_CaseReassignment
*    Version: 1.0
*    
********************************************************************************************************/
@isTest(seeAllData = false) 
private class Social_CaseReassignment_Test{

    public static Id caseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Case');
    public static Id bsAuditCaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Case QA Record Type'); // Stores record type id of Business Care Closed case Record Type
    
    static testMethod void reassignSLA(){
        List<User> userList = new List<User>();
        List<Event> slaList = new List<Event>();
        List<Case> caseList = new List<Case>();
        Profile p1 = [select id, name from profile where name='Care Manager Business'];
        Profile p2 = [select id, name from profile where name='Senior Operations Manager Business'];        
       
        User u3 = new User(alias = 's129', email='standarduser129@testorg.com',
            emailencodingkey='UTF-8', lastname='Testingf1', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p2.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser11f129@accenture.com'); 
            
        userList.add(u3);      
        
        User u4 = new User(alias = 's129', email='standarduser129@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing4f1', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p2.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser411f129@accenture.com');   
            
        userList.add(u4);  
        
        User u1 = new User(alias = 's130', email='standarduser130@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id, ManagerId = u3.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser130@accenture.com');
            
        userList.add(u1);
         
        User u2 = new User(alias = 's131', email='standarduser131@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id, ManagerId = u4.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser1131@accenture.com'); 
        
        userList.add(u2); 
        insert userList;
        
        Case singleCase = new Case();
            singleCase.Status = 'New';
            singleCase.OwnerId = u1.Id;
            singleCase.Case_PostTag__c= 'GCS-GEN';
            singleCase.Social_Media_Source__c = 'ATT Small Biz';
            singleCase.Component_Primary__c = 'DSL';
            singleCase.RecordTypeId = caseRecordTypeId;
            singleCase.Current_SLA_Phase__c = 'SLA2 - Initiated';
            caseList.add(singleCase);
            
         Case singleCase1 = new Case();
            singleCase1.Status = 'New';
            singleCase1.OwnerId = u2.Id;
            singleCase1.Case_PostTag__c= 'GCS-SALESLEAD';
            singleCase1.Social_Media_Source__c = 'ATT Small Biz';
            singleCase1.Component_Primary__c = 'DSL';
            singleCase1.RecordTypeId = caseRecordTypeId;
            singleCase1.Current_SLA_Phase__c = 'SLA1 - Initiated';
            caseList.add(singleCase1);
            insert caseList;
        
        Event singleEvent = new Event();
            singleEvent.OwnerId = u1.Id;
            singleEvent.Event_Status__c = 'Open';
            singleEvent.WhatId = singleCase.Id;
            singleEvent.StartDateTime = dateTime.now();
            singleEvent.DurationInMinutes = 60;
            singleEvent.IsAllDayEvent = FALSE;
            singleEvent.Event_Type__c = 'SLA - 2'; 
            slaList.add(singleEvent); 
        
        Event singleEvent1 = new Event();
            singleEvent1.OwnerId = u3.Id;
            singleEvent1.Event_Status__c = 'Open';
            singleEvent1.WhatId = singleCase.Id;
            singleEvent1.StartDateTime = dateTime.now();
            singleEvent1.DurationInMinutes = 60;
            singleEvent1.IsAllDayEvent = FALSE;  
            singleEvent.Event_Type__c = 'SLA - 2';     
            slaList.add(singleEvent1); 
            
        Event singleEvent2 = new Event();
            singleEvent2.OwnerId = u2.Id;
            singleEvent2.Event_Status__c = 'Open';
            singleEvent2.WhatId = singleCase.Id;
            singleEvent2.StartDateTime = dateTime.now();
            singleEvent2.DurationInMinutes = 15;
            singleEvent2.IsAllDayEvent = FALSE;
            singleEvent2.Event_Type__c = 'SLA - 1'; 
            slaList.add(singleEvent2); 
        
        Event singleEvent3 = new Event();
            singleEvent3.OwnerId = u4.Id;
            singleEvent3.Event_Status__c = 'Open';
            singleEvent3.WhatId = singleCase.Id;
            singleEvent3.StartDateTime = dateTime.now();
            singleEvent3.DurationInMinutes = 15;
            singleEvent3.IsAllDayEvent = FALSE;  
            singleEvent3.Event_Type__c = 'SLA - 1';     
            slaList.add(singleEvent3); 
            insert slaList; 

     //Using System.runAs to avoid MIXED_DML_OPERATIONS error for inserting records in setup and non-setup objects consecutively. 
        System.runAs ( u4 ){
           // u1.profileid = p2.Id;
            u1.Availability__c = 'Vacation';
            update u1;
            u4.Availability__c = 'Available';
            update u4;
            } 
    } 
       
    static testMethod void reassignSLApromotion(){
        List<User> userList = new List<User>();
        List<Event> slaList = new List<Event>();
        Profile p1 = [select id, name from profile where name='Care Manager Business'];
        Profile p2 = [select id, name from profile where name='Senior Operations Manager Business'];
        Profile p3 = [select id, name from profile where name='Executive Business'];
                      
        User u3 = new User(alias = 's132', email='standarduser132@testorg.com',
            emailencodingkey='UTF-8', lastname='Testingf1', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p2.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser11f132@accenture.com'); 
            
        userList.add(u3);      
        
        User u4 = new User(alias = 's133', email='standarduser133@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing4f1', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p2.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser411f133@accenture.com');   
            
        userList.add(u4); 
            
        User u1 = new User(alias = 's134', email='standarduser134@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id, ManagerId = u3.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser134@accenture.com');
            
        userList.add(u1);
            
        User u2 = new User(alias = 's135', email='standarduser135@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id, ManagerId = u4.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser1135@accenture.com'); 
        
        userList.add(u2); 
  
        insert userList;
        update userList;
        
        Case singleCase = new Case();
            singleCase.Status = 'New';
            singleCase.OwnerId = u1.Id;
            singleCase.Case_PostTag__c= 'GCS-LANDLINE';
            singleCase.Social_Media_Source__c = 'ATT Small Biz';
            singleCase.Component_Primary__c = 'DSL';
            singleCase.RecordTypeId = caseRecordTypeId;
            singleCase.Current_SLA_Phase__c = 'SLA1 - Initiated';
            insert singleCase;
        
        Event singleEvent = new Event();
            singleEvent.OwnerId = u1.Id;
            singleEvent.Event_Status__c = 'Open';
            singleEvent.WhatId = singleCase.Id;
            singleEvent.StartDateTime = dateTime.now();
            singleEvent.DurationInMinutes = 60;
            singleEvent.IsAllDayEvent = FALSE; 
            singleEvent.Event_Type__c = 'SLA - 1';
            slaList.add(singleEvent); 
            
        Event singleEvent1 = new Event();
            singleEvent1.OwnerId = u3.Id;
            singleEvent1.Event_Status__c = 'Open';
            singleEvent1.WhatId = singleCase.Id;
            singleEvent1.StartDateTime = dateTime.now();
            singleEvent1.DurationInMinutes = 60;
            singleEvent1.IsAllDayEvent = FALSE; 
            singleEvent.Event_Type__c = 'SLA - 1';    
            slaList.add(singleEvent1); 
            
        insert slaList;
        
        //Using System.runAs to avoid MIXED_DML_OPERATIONS error for inserting records in setup and non-setup objects consecutively. 
        System.runAs ( u3 ){
            u4.ProfileId = p3.Id;  
            u1.ProfileId = p2.Id; 
            update u4;   
            update u1;  
            }    

    }  
    
    static testMethod void reassignToQueue(){
        List<User> userList = new List<User>();
        List<Event> slaList = new List<Event>();
        Profile p1 = [select id, name from profile where name='Care Manager Business'];
        Profile p2 = [select id, name from profile where name='Senior Operations Manager Business'];
        
        User u3 = new User(alias = 's136', email='standarduser136@testorg.com',
            emailencodingkey='UTF-8', lastname='Testingf1', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p2.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser11f136@accenture.com'); 
            
        userList.add(u3);      
        
        User u1 = new User(alias = 's137', email='standarduser137@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id, ManagerId = u3.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser137@accenture.com');
            
        userList.add(u1);           
        
        insert userList;
        
        Case singleCase = new Case();
            singleCase.Status = 'New';
            singleCase.OwnerId = u1.Id;
            singleCase.Case_PostTag__c= 'GCS-GEN';
            singleCase.Social_Media_Source__c = 'ATT Small Biz';
            singleCase.Component_Primary__c = 'DSL';
            singleCase.RecordTypeId = caseRecordTypeId;
            singleCase.Current_SLA_Phase__c = 'SLA2 - Initiated';
            insert singleCase;
        
        Event singleEvent = new Event();
            singleEvent.OwnerId = u1.Id;
            singleEvent.Event_Status__c = 'Open';
            singleEvent.WhatId = singleCase.Id;
            singleEvent.StartDateTime = dateTime.now();
            singleEvent.DurationInMinutes = 60;
            singleEvent.IsAllDayEvent = FALSE; 
            singleEvent.Event_Type__c = 'SLA - 2';
            slaList.add(singleEvent); 
            
        Event singleEvent1 = new Event();
            singleEvent1.OwnerId = u3.Id;
            singleEvent1.Event_Status__c = 'Open';
            singleEvent1.WhatId = singleCase.Id;
            singleEvent1.StartDateTime = dateTime.now();
            singleEvent1.DurationInMinutes = 60;
            singleEvent1.IsAllDayEvent = FALSE; 
            singleEvent.Event_Type__c = 'SLA - 2';    
            slaList.add(singleEvent1); 
            
        insert slaList;
        test.startTest();
        u1.Availability__c = 'Vacation';
        update u1;    
        test.stopTest();
    } 
    // Added by Ashween 0n 0913
     static testMethod void reassignAuditCases(){
     List<User> userList = new List<User>();
        List<Event> slaList = new List<Event>();
        Profile p1 = [select id, name from profile where name='Care Manager Business'];
        Profile p2 = [select id, name from profile where name='Senior Operations Manager Business'];
        
        User u1 = new User(alias = 's138', email='standarduser1@testorg.com',
            emailencodingkey='UTF-8', lastname='Testingf1', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p2.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser11f138@accenture.com'); 
            userList.add(u1);      
        
        User u2 = new User(alias = 's139', email='standarduser2139@testorg.com',
            emailencodingkey='UTF-8', lastname='Testingf2', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p2.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser139@accenture.com');
            userList.add(u2);      
            
        User u3 = new User(alias = 's140', email='standarduser140@testorg.com',
            emailencodingkey='UTF-8', lastname='Testingf3', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser140@accenture.com');
            userList.add(u3);     
            
        test.starttest();
        insert userList;
        test.stoptest();
         
         Case singleCase = new Case();
            singleCase.Status = 'New';
            singleCase.OwnerId = u3.Id;
            singleCase.Closed_Operation_Manager__c = u1.Id;
            singleCase.Case_PostTag__c= 'GCS-GEN';
            singleCase.Audit_Status__c = 'Not QA';
            // singleCase.Reason_for_Closure__c ='Resolved';
            singleCase.Social_Media_Source__c = 'ATT Small Biz';
            singleCase.Component_Primary__c = 'DSL';
            singleCase.RecordTypeId = bsAuditCaseRecordTypeId ;
            singleCase.Current_SLA_Phase__c = 'SLA2 - Initiated';
            insert singleCase;
            
           // test.startTest();
            singleCase.Status = 'Closed';
            singleCase.Customer_Type__c ='Enterprise';
            singleCase.Root_Cause__c ='No Response';
            singleCase.Effort__c ='Simple';
            singleCase.Method_of_Contact__c = 'NA';
            singleCase.Reason ='Resolved';
            update singleCase;
            singleCase.Audit_Status__c = 'Under QA';
            update singleCase;
            u1.Availability__c = 'Vacation';
            update u1; 
            
            singleCase.Current_SLA_Phase__c = 'SLA3 - Initiated';
            singleCase.Case_PostTag__c= '';  
            update singleCase; 
           // test.stopTest();
           
          
     }
     
     static testMethod void reAssignOpsEvents(){
        List<User> userList = new List<User>();
        List<Event> slaList = new List<Event>();
        Profile p1 = [select id, name from profile where name='Care Manager Business'];
        Profile p2 = [select id, name from profile where name='Senior Operations Manager Business'];
        
        User u3 = new User(alias = 's141', email='standarduser141@testorg.com',
                           emailencodingkey='UTF-8', lastname='Testingf1', languagelocalekey='en_US',
                           localesidkey='en_US', profileid = p2.Id, isActive=true,
                           timezonesidkey='America/Los_Angeles', 
                           Availability__c= 'Available', 
                           username='standarduser11f141@accenture.com'); 
            
        userList.add(u3);      
        
        User u1 = new User (alias = 's142', email='standarduser142@testorg.com',
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                            localesidkey='en_US', profileid = p1.Id, ManagerId = u3.Id, isActive=true,
                            timezonesidkey='America/Los_Angeles', 
                            Availability__c= 'Available', 
                            username='standarduser142@accenture.com');
            
        userList.add(u1);           
        
        insert userList;
        
        Case singleCase = new Case();
        singleCase.Status = 'New';
        singleCase.OwnerId = u1.Id;
        singleCase.Case_PostTag__c= 'GCS-GEN';
        singleCase.Social_Media_Source__c = 'ATT Small Biz';
        singleCase.Component_Primary__c = 'DSL';
        singleCase.RecordTypeId = caseRecordTypeId;
        singleCase.Current_SLA_Phase__c = 'SLA2 - Initiated';
        
        Case singleCase1 = new Case();
        singleCase1.Status = 'New';
        singleCase1.OwnerId = u1.Id;
        singleCase1.Case_PostTag__c= 'GCS-GEN';
        singleCase1.Social_Media_Source__c = 'ATT Small Biz';
        singleCase1.Component_Primary__c = 'DSL';
        singleCase1.RecordTypeId = caseRecordTypeId;
        singleCase1.Current_SLA_Phase__c = 'SLA2 - Initiated';
        
        insert new List<Case> {singleCase,singleCase1};
        
        Event singleEvent = new Event();
        singleEvent.OwnerId = u3.Id;
        singleEvent.Event_Status__c = 'Open';
        singleEvent.WhatId = singleCase.Id;
        singleEvent.StartDateTime = dateTime.now();
        singleEvent.DurationInMinutes = 60;
        singleEvent.IsAllDayEvent = FALSE; 
        singleEvent.Event_Type__c = 'SLA - 1';
        slaList.add(singleEvent); 
            
        Event singleEvent1 = new Event();
        singleEvent1.OwnerId = u3.Id;
        singleEvent1.Event_Status__c = 'Open';
        singleEvent1.WhatId = singleCase1.Id;
        singleEvent1.StartDateTime = dateTime.now();
        singleEvent1.DurationInMinutes = 60;
        singleEvent1.IsAllDayEvent = FALSE; 
        singleEvent.Event_Type__c = 'SLA - 2';    
        slaList.add(singleEvent1); 
            
        insert slaList;
        
        test.startTest();
        
            u1.Availability__c = 'Vacation';
            update u1;    
            
            List<Event> res = Social_CaseReassignment.reAssignOpsEvents(new Map<Id,List<Event>>{singleCase.Id=>new List<Event>{singleEvent1,singleEvent}},u1);
            List<Event> res1 = Social_CaseReassignment.reAssignOpsEvents(new Map<Id,List<Event>>{singleCase.Id=>new List<Event>{singleEvent1,singleEvent}},new User());
            
        test.stopTest();
    } 
}