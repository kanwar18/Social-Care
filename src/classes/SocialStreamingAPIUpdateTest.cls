/********************************************************************************************************
*    Author: Accenture
*    Test Class for : SocialStreamingAPIUpdate
*    Version: 1.0
*    
********************************************************************************************************/
@isTest
Public class SocialStreamingAPIUpdateTest {

    /*
    * Test Method for trigger SocialUpdateCaseFlag
    * Class : SocialStreamingAPIUpdate
    * Method : CaseCommentUpdate
    */
    Public static testMethod void CaseCommentUpdate_Test() {
        List<CaseComment> caseCommentList = new List<CaseComment>();
        List<Case> caseList = new List<Case>();        
        List<Contact> contactList = new List<Contact>();
        List<User> userList = new List<User>();
        Profile careManagerProfile = [select id, name from profile where name = 'Care Manager'];
        User u1 = new User(alias = 'standt', email='testUser@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = careManagerProfile.Id, isactive=true,
                          timezonesidkey='America/Los_Angeles', 
                          Availability__c= 'Available', 
                          username='testUser133@accenture.com');
        userList.add(u1);
        insert userList;
        
        Contact contactObj = new Contact();
        contactObj.LastName = 'testName';
        contactObj.email = 'testemail@abc.com';
        contactList.add(contactObj);
        
        Contact contactObj1 = new Contact();
        contactObj1.LastName = 'testName1';
        contactObj1.email = 'testemail33@abc.com';
        contactList.add(contactObj1);
        insert contactList;
        
        Case caseObj = new Case();
        caseObj.ContactId = contactList[0].Id;
        caseObj.Status = 'New';
        caseObj.Origin = 'email';
        caseObj.Contact = contactList[0];
        caseObj.OwnerId = UserInfo.getUserid();
        caseObj.ReadUnreadCheck__c = true;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj);
                       
        Case caseObj1 = new Case();
        caseObj1.ContactId = contactList[0].Id;
        caseObj1.Status = 'New';
        caseObj1.Origin = 'email';
        caseObj1.Contact = contactList[0];
        caseObj1.OwnerId = u1.Id;
        caseObj1.ReadUnreadCheck__c = true;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj1);       
        insert caseList;
                        
        CaseComment caseCommentObj = new CaseComment();
        caseCommentObj.CommentBody = 'fdfsdfsd';
        caseCommentObj.IsPublished = TRUE;
        caseCommentObj.ParentId = caseList[0].id;
        caseCommentList.add(caseCommentObj);
        
        CaseComment caseCommentObj1 = new CaseComment();
        caseCommentObj1.CommentBody = 'fdfsdfsd';
        caseCommentObj1.IsPublished = TRUE;
        caseCommentObj1.ParentId = caseList[1].id;
        caseCommentList.add(caseCommentObj1);
        insert caseCommentList;
        
        caseCommentObj1.IsPublished = TRUE;
        update caseCommentObj1;
    }
    
    /*
    * Test Method for trigger SocialUpdateCaseFlag
    * Class : SocialStreamingAPIUpdate
    * Method : caseSocialPostInsertUpdate
    */
    
    Public static testMethod void caseSocialPostInsertUpdate_Test() {
        List<Case> caseList = new List<Case>();
        Map<Id,string> CaseMap = New Map<Id,String>();     
        List<Contact> contactList = new List<Contact>();
        List<SocialPost> socialPostList = new List<SocialPost>();
        List<User> userList = new List<User>();
        Profile careManagerProfile = [select id, name from profile where name = 'Care Manager'];
        User u1 = new User(alias = 'standt', email='testU3ser@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = careManagerProfile.Id, isactive=true,
                          timezonesidkey='America/Los_Angeles', 
                          Availability__c= 'Available', 
                          username='testUser13343@accenture.com');
        userList.add(u1);
        insert userList;
        
        Contact contactObj = new Contact();
        contactObj.LastName = 'testName';
        contactObj.email = 'testemail@abc.com';
        contactList.add(contactObj);
        
        Contact contactObj1 = new Contact();
        contactObj1.LastName = 'testName1';
        contactObj1.email = 'testemail33@abc.com';
        contactList.add(contactObj1);
        insert contactList;
        
        Case caseObj = new Case();
        caseObj.ContactId = contactList[0].Id;
        caseObj.Status = 'New';
        caseObj.Origin = 'email';
        caseObj.Contact = contactList[0];
        caseObj.OwnerId = UserInfo.getUserid();
        caseObj.ReadUnreadCheck__c = false;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj);         
        
        Case caseObj1 = new Case();
        caseObj1.ContactId = contactList[0].Id;
        caseObj1.Status = 'New';
        caseObj1.Origin = 'email';
        caseObj1.Contact = contactList[0];
        caseObj1.OwnerId = u1.Id;
        caseObj1.ReadUnreadCheck__c = false;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj1);
        insert caseList;
                       
       SocialPost socialPostObj = new SocialPost();
        socialPostObj.name = 'Test Social Post';
        socialPostObj.Headline = 'ATT DSL';
        socialPostObj.parentId = caseList[0].Id;        
        socialPostObj.Posted = System.now();        
        socialPostObj.R6Service__HarvestDate__c = System.now();        
        socialPostList.add(socialPostObj);
        
        SocialPost socialPostObj1 = new SocialPost();
        socialPostObj1.name = 'Test Social Post';
        socialPostObj1.Headline = 'ATT DSL';
        socialPostObj1.parentId = caseList[1].Id;        
        socialPostObj1.Posted = System.now();         
        socialPostObj1.R6Service__HarvestDate__c = System.now();
        socialPostList.add(socialPostObj1);
        insert socialPostList;
        socialPostObj1.Posted = System.now();
        update socialPostObj1;
        
        casemap.put(caseObj.id, 'Insert');
        casemap.put(caseObj1.id, 'Insert');        
       SocialStreamingAPIUpdate.caseSocialPostInsertUpdate( casemap );        
       }
    
    /*
    * Test Method for trigger Social_caseActivityTracker
    * Class : SocialStreamingAPIUpdate
    * Method : caseTaskInsertUpdate
    */
    Public static testMethod void caseTaskInsertUpdate_Test() {
        List<Case> caseList = new List<Case>();
        Map<Id,string> CaseMap = New Map<Id,String>();
        List<Contact> contactList = new List<Contact>();
        List<Task> taskList = new List<Task>();
        List<User> userList = new List<User>();
        Profile careManagerProfile = [select id, name from profile where name = 'Care Manager'];
        User u1 = new User(alias = 'standt', email='testU3ser@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = careManagerProfile.Id, isactive=true,
                          timezonesidkey='America/Los_Angeles', 
                          Availability__c= 'Available', 
                          username='testuser678@accenture.com');
        userList.add(u1);
        insert userList;
        
        Contact contactObj = new Contact();
        contactObj.LastName = 'testName';
        contactObj.email = 'testemail@abc.com';
        contactList.add(contactObj);
        
        Contact contactObj1 = new Contact();
        contactObj1.LastName = 'testName1';
        contactObj1.email = 'testemail33@abc.com';
        contactList.add(contactObj1);
        insert contactList;
        
        Case caseObj = new Case();
        caseObj.ContactId = contactList[0].Id;
        caseObj.Status = 'New';
        caseObj.Origin = 'email';
        caseObj.Contact = contactList[0];
        caseObj.OwnerId = UserInfo.getUserid();
        caseObj.ReadUnreadCheck__c = true;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj);
        
        Case caseObj1 = new Case();
        caseObj1.ContactId = contactList[0].Id;
        caseObj1.Status = 'New';
        caseObj1.Origin = 'email';
        caseObj1.Contact = contactList[0];
        caseObj1.OwnerId = u1.Id;
        caseObj1.ReadUnreadCheck__c = true;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj1);
        
        Case caseObj2 = new Case();
        caseObj2.ContactId = contactList[0].Id;
        caseObj2.Status = 'New';
        caseObj2.Origin = 'email';
        caseObj2.Contact = contactList[0];
        caseObj2.OwnerId = u1.Id;
        caseObj2.Update_Reason__c = 'Availability Assignment';
        caseObj2.ReadUnreadCheck__c = true;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj2);
        insert caseList;
        
        Task taskObj = new Task();        
        taskObj.WhatId = caseList[0].id; 
        taskObj.Subject = 'Email:';
        taskList.add(taskObj);
        
        Task taskObj1 = new Task();        
        taskObj1.WhatId = caseList[1].id;
        taskObj1.Subject = 'New Task';
        taskList.add(taskObj1);
        insert taskList;
        
        casemap.put(caseObj.id, 'Insert');
        casemap.put(caseObj1.id, 'Insert');
        casemap.put(caseObj2.id, 'Insert');         
       SocialStreamingAPIUpdate.caseTaskInsertUpdate( casemap );        
    }
    
    /*
    * Test Method for trigger Social_EventSlaTracker
    * Class : SocialStreamingAPIUpdate
    * Method : caseEventInsertUpdate
    */
    
    Public static testMethod void caseEventInsertUpdate_Test() {
        List<Case> caseList = new List<Case>();
        Map<Id,string> CaseMap = New Map<Id,String>();
        List<Contact> contactList = new List<Contact>();
        List<Event> eventList = new List<Event>();
        List<User> userList = new List<User>();
        Profile careManagerProfile = [select id, name from profile where name = 'Care Manager'];
        User u1 = new User(alias = 'standt', email='testU3ser@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = careManagerProfile.Id, isactive=true,
                          timezonesidkey='America/Los_Angeles', 
                          Availability__c= 'Available', 
                          username='testus338@accenture.com');
        userList.add(u1);
        insert userList;
        
        Contact contactObj = new Contact();
        contactObj.LastName = 'testName';
        contactObj.email = 'testemail@abc.com';
        contactList.add(contactObj);
        
        Contact contactObj1 = new Contact();
        contactObj1.LastName = 'testName1';
        contactObj1.email = 'testemail33@abc.com';
        contactList.add(contactObj1);
        insert contactList;
        
        Case caseObj = new Case();
        caseObj.ContactId = contactList[0].Id;
        caseObj.Status = 'New';
        caseObj.Origin = 'email';
        caseObj.Contact = contactList[0];
        caseObj.OwnerId = UserInfo.getUserid();
        caseObj.ReadUnreadCheck__c = true;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj);
        
        Case caseObj1 = new Case();
        caseObj1.ContactId = contactList[0].Id;
        caseObj1.Status = 'New';
        caseObj1.Origin = 'email';
        caseObj1.Contact = contactList[0];
        caseObj1.OwnerId = u1.Id;
        caseObj1.ReadUnreadCheck__c = true;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj1);
        
        Case caseObj2 = new Case();
        caseObj2.ContactId = contactList[0].Id;
        caseObj2.Status = 'New';
        caseObj2.Origin = 'email';
        caseObj2.Contact = contactList[0];
        caseObj2.OwnerId = u1.Id;
        caseObj2.Update_Reason__c = 'Availability Assignment';
        caseObj2.ReadUnreadCheck__c = true;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj2);
        insert caseList;
        
        Event eventObj = new Event();
        eventObj.whatId = caseList[0].id;
        eventObj.Event_Status__c = 'Open';
        eventObj.Description = 'SLA-3 Event';
        eventObj.StartDateTime = System.now();
        eventObj.DurationInMinutes = 15;
        eventObj.IsReminderSet = true;
        eventObj.ReminderDateTime = System.now().addMinutes(5);
        eventObj.Subject = 'SLA-3 Type Event';
        eventList.add(eventObj);
        
        Event eventObj1 = new Event();
        eventObj1.whatId = caseList[1].id;
        eventObj1.Event_Status__c = 'Open';
        eventObj1.Description = 'SLA-3 Event';
        eventObj1.StartDateTime = System.now();
        eventObj1.DurationInMinutes = 15;
        eventObj1.IsReminderSet = true;
        eventObj1.ReminderDateTime = System.now().addMinutes(5);
        eventObj1.Subject = 'SLA-3 Type Event';
        eventList.add(eventObj1);
        insert eventList;
        
        eventObj1.whatId = caseList[2].id;
        update eventObj1;
        casemap.put(caseObj.id, 'Insert');
        casemap.put(caseObj1.id, 'Insert');
        casemap.put(caseObj2.id, 'Insert');       
       SocialStreamingAPIUpdate.caseEventInsertUpdate( casemap );
    }
    
    /*
    * Test Method for trigger Social_caseEmailValidator
    * Class : SocialStreamingAPIUpdate
    * Method : caseEmailInsertUpdate
    */
    
    Public static testMethod void caseEmailInsertUpdate_Test() {
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        List<EmailMessage> emailMessageList = new List<EmailMessage>();
        List<User> userList = new List<User>();
        Profile careManagerProfile = [select id, name from profile where name = 'Care Manager'];
        User u1 = new User(alias = 'standt', email='testU3ser@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = careManagerProfile.Id, isactive=true,
                          timezonesidkey='America/Los_Angeles', 
                          Availability__c= 'Available', 
                          username='testus338@accenture.com');
        userList.add(u1);
        insert userList;
        
        Contact contactObj = new Contact();
        contactObj.LastName = 'testName';
        contactObj.email = 'testemail@abc.com';
        contactList.add(contactObj);
        
        Contact contactObj1 = new Contact();
        contactObj1.LastName = 'testName1';
        contactObj1.email = 'testemail33@abc.com';
        contactList.add(contactObj1);
        insert contactList;
        
        Case caseObj = new Case();
        caseObj.ContactId = contactList[0].Id;               
        caseObj.Status = 'New';
        caseObj.Origin = 'email';       
        caseObj.Contact = contactList[0];
        caseObj.OwnerId = UserInfo.getUserid();
        caseObj.ReadUnreadCheck__c = true;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj);
        
        Case caseObj1 = new Case();
        caseObj1.ContactId = contactList[0].Id;              
        caseObj1.Status = 'New';
        caseObj1.Origin = 'email';
        caseObj1.Contact = contactList[0];
        caseObj1.OwnerId = u1.Id;
        caseObj1.ReadUnreadCheck__c = true;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj1);
        insert caseList;
        
        EmailMessage emailMsgObj = new EmailMessage();
        emailMsgObj.FromAddress = 'abc@gmail.com';
        emailMsgObj.ToAddress = 'def@gmail.com';
        emailMsgObj.FromName = 'Test Email';
        emailMsgObj.Subject = 'Test Email Subject';
        emailMsgObj.TextBody = 'Text Email Body';
        emailMsgObj.ParentId = caseList[0].Id; 
        emailMessageList.add(emailMsgObj);  
        
        EmailMessage emailMsgObj1 = new EmailMessage();
        emailMsgObj1.FromAddress = 'abc@gmail.com';
        emailMsgObj1.ToAddress = 'def@gmail.com';
        emailMsgObj1.FromName = 'Test Email';
        emailMsgObj1.Subject = 'Test Email Subject';
        emailMsgObj1.TextBody = 'Text Email Body';
        emailMsgObj1.ParentId = caseList[1].Id;
        emailMessageList.add(emailMsgObj1);
        insert emailMessageList;               
    }
    
    /*
    * Test Method for trigger Social_SocialPersona
    * Class : SocialStreamingAPIUpdate
    * Method : caseSocialPersonaInsertUpdate
    */
    
    Public static testMethod void caseSocialPersonaInsertUpdate_Test() {
        List<Case> caseList = new List<Case>();
        Map<Id,string> CaseMap = New Map<Id,String>();
        List<Contact> contactList = new List<Contact>();
        List<SocialPersona> socialPersonList = new List<SocialPersona>();
        List<SocialPost> socialPostList = new List<SocialPost>();
        List<User> userList = new List<User>();
        Profile careManagerProfile = [select id, name from profile where name = 'Care Manager'];
        User u1 = new User(alias = 'standt', email='testU3ser@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = careManagerProfile.Id, isactive=true,
                          timezonesidkey='America/Los_Angeles', 
                          Availability__c= 'Available', 
                          username='test448@accenture.com');
        userList.add(u1);
        insert userList;
        
        Contact contactObj = new Contact();
        contactObj.LastName = 'testName';
        contactObj.email = 'testemail@abc.com';
        contactList.add(contactObj);
        
        Contact contactObj1 = new Contact();
        contactObj1.LastName = 'testName1';
        contactObj1.email = 'testemail33@abc.com';
        contactList.add(contactObj1);
        insert contactList;
        
        Case caseObj = new Case();
        caseObj.ContactId = contactList[0].Id;
        caseObj.Status = 'New';        
        caseObj.Origin = 'email';
        caseObj.Contact = contactList[0];
        caseObj.OwnerId = UserInfo.getUserid();        
        caseObj.ReadUnreadCheck__c = True;               
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj);
        
        Case caseObj1 = new Case();
        caseObj1.ContactId = contactList[0].Id;
        caseObj1.Status = 'New';       
        caseObj1.Origin = 'email';                
        caseObj1.Contact = contactList[0];
        caseObj1.OwnerId = u1.Id;
        caseObj1.ReadUnreadCheck__c = True;                
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj1);
        insert caseList;
        
        SocialPost post =  new SocialPost();
        post.ParentId = caseList[0].id;
        post.Name = 'TestName';
        post.Posted = System.now();
        post.HeadLine = 'TestHeadline';
        socialPostList.add(post);
        
        SocialPost post1 =  new SocialPost();
        post1.ParentId = caseList[1].id;
        post1.Name = 'TestNamesdfs';
        post1.Posted = System.now();
        post1.HeadLine = 'TestHeadlinedfs';
        socialPostList.add(post1);        
        insert socialPostList;
        
        SocialPersona socialPersonaObj =  new SocialPersona();
        socialPersonaObj.ParentId = contactList[0].id;                
        socialPersonaObj.Name = 'Test Name';        
        socialPersonaObj.Provider = 'Twitter';
        socialPersonList.add(socialPersonaObj);
        
        SocialPersona socialPersonaObj1 =  new SocialPersona();
        socialPersonaObj1.ParentId = contactList[1].id;       
        socialPersonaObj1.Name = 'Test Name';
        socialPersonaObj1.Provider = 'Twitter';
        socialPersonList.add(socialPersonaObj1);
        insert socialPersonList;
        casemap.put(caseObj.ContactId ,'insert');     
        casemap.put(caseObj.id, 'Insert');
        casemap.put(caseObj1.id, 'Insert');         
       SocialStreamingAPIUpdate.caseSocialPersonaInsertUpdate( casemap );         
    }
    
    
    /*
    * Test Method for trigger Social_CaseAttachment
    * Class : SocialStreamingAPIUpdate
    * Method : caseSocialPersonaInsertUpdate
    */
    
    Public static testMethod void caseAttachmentInsertUpdate_Test() {
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        List<Attachment> attachmentList = new List<Attachment>();
        List<SocialPost> socialPostList = new List<SocialPost>();
        List<User> userList = new List<User>();
        Profile careManagerProfile = [select id, name from profile where name = 'Care Manager'];
        User u1 = new User(alias = 'standt', email='testU3ser@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = careManagerProfile.Id, isactive=true,
                          timezonesidkey='America/Los_Angeles', 
                          Availability__c= 'Available', 
                          username='test44328@accenture.com');
        userList.add(u1);
        insert userList;
        
        Contact contactObj = new Contact();
        contactObj.LastName = 'testName';
        contactObj.email = 'testemail@abc.com';
        contactList.add(contactObj);
        
        Contact contactObj1 = new Contact();
        contactObj1.LastName = 'testName1';
        contactObj1.email = 'testemail33@abc.com';
        contactList.add(contactObj1);
        insert contactList;
        
        Case caseObj = new Case();
        caseObj.ContactId = contactList[0].Id;
        caseObj.Status = 'New';
        caseObj.Origin = 'email';
        caseObj.Contact = contactList[0];
        caseObj.OwnerId = UserInfo.getUserid();
        caseObj.ReadUnreadCheck__c = true;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj);
        
        Case caseObj1 = new Case();
        caseObj1.ContactId = contactList[1].Id;
        caseObj1.Status = 'New';
        caseObj1.Origin = 'email';
        caseObj1.Contact = contactList[1];
        caseObj1.OwnerId = userList[0].Id;
        caseObj1.ReadUnreadCheck__c = true;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        caseList.add(caseObj1);
        insert caseList;
        
        Attachment attachObj =  new Attachment();
        attachObj.ParentId = caseList[0].id;
        attachObj.Name = 'a';
        Blob b = Blob.valueOf('Test Data');
        attachObj.Body = b;
        attachmentList.add(attachObj);
        
        Attachment attachObj1 =  new Attachment();
        attachObj1.ParentId = caseList[1].id;
        attachObj1.Name = 'a1';
        Blob b1 = Blob.valueOf('Test Data1');
        attachObj1.Body = b1;
        attachmentList.add(attachObj1);
        insert attachmentList;
        
        attachObj1.Name = 'tttt';
        update attachObj1;
    }
}