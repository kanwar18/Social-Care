/********************************************************************************************************
*    Author: Arun Ramachandran
*    Test Class for : Social_ClosedCaseReOpenHandler
*    Version: 1.0
*
********************************************************************************************************/
@isTest(SeeALLData = true)
private class Social_ClosedCaseReOpenHandler_Test{ 
    
    public static Id caseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Case');
    public static Id ClosedcaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Closed Case');
    
    static testMethod void createIncomingEmail(){
    
        List<Case> slaInitiateCaseList = new List<Case>();
        Set<Id> caseOwnerIdSet = new Set<Id>();     
        set<Id> parentCaseIdSet = new Set<Id>();  
        
        Social_ClosedCaseReOpenHandler closedClass = new Social_ClosedCaseReOpenHandler();
        
        Profile p1 = [select id, name from profile where name='Care Manager Business'];
        
        User u1 = new User(alias = 's141', email='standarduser141@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', 
        Availability__c= 'Available', 
        username='standarduser141@accenture.com');
        insert u1;
        
        User u2 = new User(alias = 's142', email='standarduser142@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', 
        Availability__c= 'Available', 
        username='standarduser142@accenture.com');
        insert u2;
        
        Case singleCase = new Case();
        singleCase.Status = 'New';
        singleCase.OwnerId = u1.Id;
        singleCase.Social_Media_Source__c = 'ATT Small Biz';
        singleCase.Component_Primary__c = 'DSL';
        singleCase.RecordTypeId = caseRecordTypeId;
        singleCase.Current_SLA_Phase__c = 'SLA1 - Initiated';
        insert singleCase;
        slaInitiateCaseList.add(singleCase);
       
        caseOwnerIdSet.add(singleCase.OwnerId);            
        
        singleCase.Status = 'Closed';
        singleCase.Customer_Type__c = 'Enterprise';
        singleCase.Root_Cause__c = 'Feature';
        singleCase.Effort__c = 'Simple';
        singleCase.Reason = 'Duplicate';
        singleCase.Clarify_CRM_Verified__c = 'No';
        
        system.runAs(u1){
            update singleCase;
         }    
        parentCaseIdSet.add(singleCase.Id) ; 
        

       //insert caseOwnerIdSet;
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'a.x.ramachandran@4-1iys5vi89ovlssbk7euolq3pkrxv3w5994v4qfsfphzn9qfzbi.l-2zgtmaq.l.case.sandbox.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = singleCase.Id)); 
        insert newEmail;
        test.startTest();
            closedClass.reOpenClosedCase(parentCaseIdSet); 
            closedClass.reOpenCaseSLAInitiation(slaInitiateCaseList,caseOwnerIdSet);
          
          test.stopTest();     
    }
    
    static testMethod void doNotReopenCaseTest(){
    
        List<Case> slaInitiateCaseList = new List<Case>();
        Set<Id> caseOwnerIdSet = new Set<Id>();
        Social_ClosedCaseReOpenHandler test = new Social_ClosedCaseReOpenHandler();
        Profile p1 = [select id, name from profile where name='Care Manager Business'];
        Profile p2 = [select id, name from profile where name='Senior Operations Manager Business'];
        
        User u1 = new User(alias = 's141', email='standarduser141@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', 
        Availability__c= 'Available', 
        username='standarduser141@accenture.com');
        insert u1;
        
        User u2 = new User(alias = 's142', email='standarduser142@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p2.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', 
        Availability__c= 'Available', 
        username='standarduser142@accenture.com');
        insert u2;
        
        Case singleCase = new Case();
        singleCase.Status = 'New';
        singleCase.OwnerId = u1.Id;
        singleCase.Social_Media_Source__c = 'ATT Small Biz';
        singleCase.Component_Primary__c = 'DSL';
        singleCase.RecordTypeId = caseRecordTypeId;
        singleCase.Current_SLA_Phase__c = 'SLA1 - Initiated';
        singleCase.Closed_Operation_Manager__c  = u2.Id;
        slaInitiateCaseList.add(singleCase);
       
        caseOwnerIdSet.add(singleCase.OwnerId);       
            
        insert  slaInitiateCaseList;      
      //caseOwnerIdSet.add(singleCase1.OwnerId);
                       
        Event slaEvent = new Event();
        slaEvent.WhatId = singleCase.Id;
        slaEvent.Event_Type__c='SLA - 1';
        slaEvent.Event_Status__c = 'Open';
        slaEvent.Description = 'SLA-1 Event';
        slaEvent.StartDateTime = System.now();
        slaEvent.DurationInMinutes = 15;
        slaEvent.IsReminderSet = true;
        slaEvent.ReminderDateTime = System.now().addMinutes(5);
        slaEvent.Subject = 'SLA-1 Type Event';
        insert slaEvent;

       //insert caseOwnerIdSet;
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'a.x.ramachandran@4-1iys5vi89ovlssbk7euolq3pkrxv3w5994v4qfsfphzn9qfzbi.l-2zgtmaq.l.case.sandbox.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = singleCase.Id)); 
        insert newEmail;
        
        singleCase.Status = 'Closed';
        singleCase.RecordTypeId = ClosedcaseRecordTypeId ;
        singleCase.Customer_Type__c = 'Enterprise';
        singleCase.Root_Cause__c = 'Feature';
        singleCase.Effort__c = 'Simple';
        singleCase.Reason = 'Duplicate';
        singleCase.Clarify_CRM_Verified__c = 'No';
        singleCase.Current_SLA_Phase__c = 'SLA1 - Ended';
        update singleCase;
    }
    
     public static testmethod void createNewCaseTest(){
     
        Profile p1 = [select id, name from profile where name='Care Manager Business'];
        Profile p2 = [select id, name from profile where name='Senior Operations Manager Business'];
        
        Set<Id> caseIdSet = new Set<Id>();        
        Map<Id,EmailMessage> caseEmailMap = new Map<Id,EmailMessage>();
        List<EmailMessage> emailList = new List<EmailMessage>();
        
        User u1 = new User(alias = 's141', email='standarduser141@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', 
        Availability__c= 'Available', 
        username='standarduser141@accenture.com');
        insert u1;
        
        User u2 = new User(alias = 's142', email='standarduser142@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p2.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', 
        Availability__c= 'Available', 
        username='standarduser142@accenture.com');
        insert u2;
        
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User',email = 'test123@ayahoo.com' );
        insert contactObj; 
               
        Case singleCase1 = new Case();
        singleCase1.Status = 'New';
        singleCase1.OwnerId = u1.Id;
        singleCase1.ContactId = contactObj.Id ;        
        singleCase1.Social_Media_Source__c = 'ATT Small Biz';
        singleCase1.Component_Primary__c = 'DSL';
        singleCase1.RecordTypeId = caseRecordTypeId ;
        singleCase1.Current_SLA_Phase__c = 'SLA1 - Initiated'; 
        singleCase1.Closed_Operation_Manager__c  = u2.Id;
        singleCase1.SuppliedEmail = 'test123@ayahoo.com' ;       
        insert singleCase1; 
        
        caseIdSet.add(singleCase1.id);

        singleCase1.Status = 'Closed';
        singleCase1.Current_SLA_Phase__c = 'SLA1 - Ended';         
        update u1;        
        
        Case singleCase2 = new Case();
        singleCase2.Status = 'New';
        singleCase2.OwnerId = u1.Id;
        singleCase2.ContactId = contactObj.Id ;        
        singleCase2.Social_Media_Source__c = 'ATT Small Biz';
        singleCase2.Component_Primary__c = 'DSL';
        singleCase2.RecordTypeId = caseRecordTypeId ;
        singleCase2.Current_SLA_Phase__c = 'SLA1 - Initiated'; 
        singleCase2.Closed_Operation_Manager__c  = u2.Id;
        singleCase2.SuppliedEmail = 'test123@ayahoo.com' ;
        singleCase2.ParentId = singleCase1.Id;        
        insert singleCase2;    
        
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'a.x.ramachandran@4-1iys5vi89ovlssbk7euolq3pkrxv3w5994v4qfsfphzn9qfzbi.l-2zgtmaq.l.case.sandbox.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = singleCase2.Id)); 
        insert newEmail;
               
        }
        
        public static testmethod void createUpdateBusinessContactTest(){
     
        Profile p1 = [select id, name from profile where name='Care Manager Business'];
        Profile p2 = [select id, name from profile where name='Senior Operations Manager Business'];
        
        Set<Id> caseIdSet = new Set<Id>();        
        
        User u1 = new User(alias = 's141', email='standarduser141@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', 
        Availability__c= 'Available', 
        username='standarduser141@accenture.com');
        insert u1;
        
        User u2 = new User(alias = 's142', email='standarduser142@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p2.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', 
        Availability__c= 'Available', 
        username='standarduser142@accenture.com');
        insert u2;
        
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User',email = 'test123@ayahoo.com' );
        insert contactObj; 
               
        Case singleCase1 = new Case();
        singleCase1.Status = 'New';
        singleCase1.OwnerId = u1.Id;
        singleCase1.ContactId = contactObj.Id ;        
        singleCase1.Social_Media_Source__c = 'ATT Small Biz';
        singleCase1.Component_Primary__c = 'DSL';
        singleCase1.RecordTypeId = caseRecordTypeId ;
        singleCase1.Current_SLA_Phase__c = 'SLA1 - Initiated'; 
        singleCase1.Closed_Operation_Manager__c  = u2.Id;
        singleCase1.SuppliedEmail = 'test123@ayahoo.com' ; 
       
        insert singleCase1; 
        
        caseIdSet.add(singleCase1.id);
        singleCase1.Current_SLA_Phase__c = 'SLA1 - Ended'; 
        u1.Availability__c= 'Offline' ;
        update u1;          
        }
        
        public static testmethod void copysocialPostDetailsTest(){
        //Social_ClosedCaseReOpenHandler test = new Social_ClosedCaseReOpenHandler();
        Map<Id,List<SocialPost>> socialPostMap = new Map<Id,List<SocialPost>> ();
        Profile p1 = [select id, name from profile where name='Care Manager Business'];
        Profile p2 = [select id, name from profile where name='Senior Operations Manager Business'];
        
        Set<Id> caseIdSet = new Set<Id>();        
        
        User u1 = new User(alias = 's141', email='standarduser141@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', 
        Availability__c= 'Available', 
        username='standarduser141@accenture.com');
        insert u1;
        
        User u2 = new User(alias = 's142', email='standarduser142@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p2.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', 
        Availability__c= 'Available', 
        username='standarduser142@accenture.com');
        insert u2;
        
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User',email = 'test123@ayahoo.com' );
        insert contactObj; 
               
        Case singleCase1 = new Case();
        singleCase1.Status = 'New';
        singleCase1.OwnerId = u1.Id;
        singleCase1.ContactId = contactObj.Id ;        
        singleCase1.Social_Media_Source__c = 'ATT Small Biz';
        singleCase1.Component_Primary__c = 'DSL';
        singleCase1.RecordTypeId = caseRecordTypeId ;
        singleCase1.Current_SLA_Phase__c = 'SLA1 - Initiated'; 
        singleCase1.Closed_Operation_Manager__c  = u2.Id;
        singleCase1.SuppliedEmail = 'test123@ayahoo.com' ; 
       
        insert singleCase1; 
        
        SocialPost post1 = new SocialPost();
        post1.Name = 'Test';
        post1.Posted = System.now();
        post1.ParentId = singleCase1.Id;
        post1.PostTags = 'GCS-GEN';
        post1.R6Service__PostTags__c = 'GCS-GEN';
        insert post1;
        socialPostMap.put(singleCase1.Id,new List<SocialPost>{post1});
        
        Social_ClosedCaseReOpenHandler.copySocialPostDetails(socialPostMap);
        
        }
}