@isTest

public class Social_NotificationOfChangeTest{
    static Case testCase;
    static Contact testContact;
    static Contact testContact1;
    static Account testAccount;
    static User user1;
    static User opsManager;
    static Task t;
    static Event e;
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
        
        testContact1=new Contact();
        testContact1.AccountId=testAccount.Id;
        testContact1.LastName='testName1';
        testContact1.email='testemai1l@abc.com';
        testContact1.Account = testAccount;
        insert testContact1;  
        
    
        
        Profile profile1 = [select id, name from profile where name='Care Manager'];
        
        opsManager = new User(alias = 'o144', email='manageruser144@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profile1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Available', 
        username='manageruser144@accenture.com', Case_Counter__c=0);
        insert opsManager;
        
        user1 = new User(alias = 's145', email='standarduser145@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profile1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Available', 
        username='standarduser145@accenture.com',Case_Counter__c=0, ManagerId=opsManager.Id);
        insert user1;
        
        
        System.runAs(user1){
            testCase = new Case();
            testCase.ContactId = testContact.Id;
            testCase.Status='New';
            testCase.Origin='email';
            testCase.Contact=testContact;
            insert testCase;
            
            testContact.email='testemail@abc.com';
            
            update testContact;
             try{
                 delete testContact1;
             }
            catch(Exception e1){
                Boolean expectedExceptionThrown =  e1.getMessage().contains('You do not have the sufficient privilege to delete this record. Please contact your System Administrator') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            } 
        }
     }
    public static testMethod void NotificationofChangePart1(){
        Test.startTest();
        testCase.OwnerId = user1.id;
        testCase.Reassignment_Reason__c = 'SLA Callback Missed Not Checked';
        update testCase;
        
        t =  new Task();
        t.subject = 'Call';
        t.WhatId = testCase.id;
        insert t;
        
        update t;
        
  
        Test.stopTest();
    }
    public static testMethod void NotificationofChangePart2(){
        Test.startTest();
        testCase.OwnerId = user1.id;
        testCase.Reassignment_Reason__c = 'SLA Callback Missed Not Checked';
        testCase.Current_SLA_Phase__c = 'SLA3 - Ended';
        update testCase;
    
        e =  new Event();
        e.WhatId = testCase.id;
        e.DurationInMinutes = 1;

        e.ActivityDateTime = System.now();
        e.Event_Status__c = 'Open';
        insert e;
     
        e.DurationInMinutes = 1;
        e.Event_Type__c = 'SLA - 3';
        e.Event_Status__c = 'Open';
        update e;
        
        
        
        Test.stopTest();
        
    }
    public static testMethod void NotificationofChangePart3(){
        
        
        testCase.OwnerId = user1.id;
        testCase.Reassignment_Reason__c = 'SLA Callback Missed Not Checked';
        update testCase;
        
        Test.startTest();
        Attachment attach =  new Attachment();
        attach.ParentId = testCase.id;
        attach.Name = 'a';
        Blob b = Blob.valueOf('Test Data');
        attach.Body = b;
        insert attach;
        
        update attach;
        
        SocialPost post =  new SocialPost();
        post.ParentId = testCase.id;
        post.Name = 'TestName';
        post.HeadLine = 'TestHeadline';
        insert post;
        
        post.HeadLine = 'TestHeadline';
        update post;
        
        SocialPersona spersona =  new SocialPersona();
        spersona.ParentId = post.id;
        spersona.Name = 'Test Name';
        spersona.Provider = 'Twitter';
        insert spersona;
        
        
        
        Test.stopTest();
    }
     public static testMethod void NotificationofChangePart4(){
        Test.startTest();
        
        testCase.OwnerId = user1.id;
        testCase.Reassignment_Reason__c = 'SLA Callback Missed Not Checked';
        update testCase;
        
        EmailMessage email =  new EmailMessage();
        email.ParentId = testCase.id;
        email.Fromaddress = 'test@idc.com' ;
        insert email;
      
        CaseComment cc =  new CaseComment();
        cc.ParentId = testCase.id;
        insert cc;
        
        System.runAs(user1){
            ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
            Social_CaseUpdateStreamCtrl testObj =  new Social_CaseUpdateStreamCtrl(stdController);
            testObj.itemId = testCase.id;
            testObj.getCases();
            testObj.runCasesStream();
            testObj.getCount();
            testObj.markCaseRead();
        }
        Test.stopTest();
    }
    public static testMethod void NotificationofChangePart5(){
        
        Contact testContact9 = new Contact();     
        testContact9.LastName='testContact';     
        testContact9.Account = testAccount;     
        testContact9.email='d.mitt@accenture.com';     
        insert testContact9;
       
        Case caseObji=new Case();    
        caseObji.Status='New';    
        caseObji.Origin='email';    
        caseObji.ContactId=testContact9.Id;    
        caseObji.contact=testContact9;  
        insert caseObji;
        
        SocialPost socialPostOutgoing = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseObji.Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'HYPERLINK "https://test.com/"https://test.com', StatusMessage = 'Sent');
        insert socialPostOutgoing;

        string url = 'www.testsopo.com/postId=' + socialPostOutgoing.id;
        ApexPages.currentPage().getParameters().put('url', url);
        Social_CaseUpdateStreamCtrl testCtrl = new Social_CaseUpdateStreamCtrl(new ApexPages.StandardController(caseObji));
        ApexPages.currentPage().getParameters().put('url', url);       
    
    }
}