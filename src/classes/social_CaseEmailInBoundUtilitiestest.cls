/**************************************************************************
Test Class Name:  social_CaseEmailInBoundUtilitiestest
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: Test Class for Social_CaseEmailInBoundUtilities.
**************************************************************************************************************************/
@istest(seealldata = false)
public class social_CaseEmailInBoundUtilitiestest {
    public static List<contact> lcon1 = new list<contact>();
    Public static List<User> userList = new List<User>();
    public static Profile p1;
    Public static Profile careManagerProfileId;
    Public static User careManager;
    public static User u2;
    public static social_CaseEmailInBoundUtilities socinb;
    public static Social_CaseEmailInBoundHandler sochand;
    public static Messaging.InboundEmail email;
    public static Messaging.InboundEnvelope env;
    
    static {
        Contact testContact3 = new Contact();     
        testContact3.LastName = 'testContact1244';     
        testContact3.email = 'badoo12@accenture.com'; 
        lcon1.add(testContact3);
        
        Contact testContact9 = new Contact();     
        testContact9.LastName = 'testContact1344';     
        testContact9.email = 'jadoo12@accenture.com'; 
        lcon1.add(testContact9);
        database.insert(lcon1,false);
        
        p1 = [select id, name from profile where name='System Administrator'];
        careManagerProfileId = [select id from profile where name = 'Care Manager'];
        u2 = new User(alias = 's160', email='standarduser160@testorg.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Vacation',  username='standarduser160@accenture.com');
        userList.add(u2);
        careManager = new User(alias = 's161', email='standarduser161@testorg.com',emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US', localesidkey='en_US', profileid = careManagerProfileId.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Vacation',  username='standarduser161@accenture.com');
        userList.add(careManager);
        insert userList;
        
        socinb = new social_CaseEmailInBoundUtilities();
        sochand = new Social_CaseEmailInBoundHandler();
         
        email = new Messaging.InboundEmail();
        env = new Messaging.InboundEnvelope();
    }

    static testmethod void Soc_caseinbemailutil() {
        List<Case> lcase=new list<Case>();
        List<contact> lcon = new list<contact>();
          
            Contact testContact = new Contact();     
            testContact.LastName = 'testContact12';     
            testContact.email = 'jadoo@accenture.com'; 
            testContact.All_Contact_Emails__c = 'jadoo@accenture.com;'; 
            testContact.Exception_Contact__c = true;
            lcon.add(testContact);
       
            Contact testContact1 = new Contact();     
            testContact1.LastName = 'testContact12';     
            testContact1.email = 'jadoo@accenture.com';
            testContact1.All_Contact_Emails__c = 'jadoo@accenture.com;'; 
            lcon.add(testContact1);
            
            database.insert(lcon,false);
      
            email.subject = 'test';
            email.plaintextbody='asfdsdfs';
            email.ccaddresses = new list<String>();
            email.toAddresses = new list<String>();
            email.ccAddresses.add('asdasdas@gmail.com');
            email.ccAddresses.add('xcxvcxc@gmail.com');
            email.ccAddresses.add('cvbvbf@gmail.com');
            env.fromAddress = 'jadoo@accenture.com';
            email.fromAddress ='jadoo@accenture.com'; 
            email.toAddresses.add('att@gmail.com');
            email.fromname='asadas';
            //sochand.handleInboundEmail(email, env );  
           

        Contact testContact3 = new Contact();     
        testContact3.LastName = 'testContact12';     
        testContact3.email = 'jadoo@accenture.com'; 
        testContact3.Exception_Contact__c = true;
        lcon1.add(testContact3);
   
        Contact testContact4=new Contact();     
        testContact4.LastName='testContact12';     
        testContact4.email='jadoo@accenture.com';
        testContact4.All_Contact_Emails__c ='jadoo@accenture.com'; 
        testContact4.Exception_Contact__c = false;
        lcon1.add(testContact4);
         
        database.insert(lcon1,false);

        Case testCaseObj = new Case();
        testCaseObj.Status = 'New';
        testCaseObj.contactid=lcon1[0].id;
        testCaseObj.Origin='email';     
        testCaseObj.priority = 'Low';
        testCaseObj.OwnerId = careManager.Id;
        testCaseObj.Current_SLA_Phase__c='SLA1 - Ended';
        lcase.add(testCaseObj);
        
        Case testCaseObj1 = new Case();
        testCaseObj1.Status = 'New';
        testCaseObj1.contactid=lcon1[1].id;
        testCaseObj1.Origin='email';     
        testCaseObj1.priority = 'Low';
        testCaseObj1.OwnerId = UserInfo.getUserid();
        lcase.add(testCaseObj1);
        
        Case testCaseObj2 = new Case();
        testCaseObj2.Status = 'New';
        testCaseObj2.Origin='email';     
        testCaseObj2.priority = 'Low';
        testCaseObj2.OwnerId = careManager.Id;
        lcase.add(testCaseObj2); 
        
        Case testCaseObj3 = new Case();
        testCaseObj3.Status = 'Closed';
        testCaseObj3.Method_of_Contact__c = 'Forums';
        testCaseObj3.Customer_Type__c = 'Consumer';
        testCaseObj3.Root_Cause__c = 'Billing Proration';
        testCaseObj3.Effort__c = 'Complex';
        testCaseObj3.Reason = 'Completed';
        testCaseObj3.Clarify_CRM_Verified__c = 'Yes';
        testCaseObj3.Origin='email';     
        testCaseObj3.priority = 'Low';
        testCaseObj3.OwnerId = UserInfo.getUserid();
        testCaseObj3.Current_SLA_Phase__c = 'SLA1 - Ended';
        testCaseObj3.First_SLA_Scheduled_Time__c = dateTime.now().addMinutes(60);
        testCaseObj3.First_SLA_Response_Time__c = dateTime.now();
        lcase.add(testCaseObj3); 
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        
        insert lcase;
         test.startTest();
        string caseid=lcase[0].id;
        email.subject='For example in the ref [ref:_00DL07DQ9._'+caseid.substring(0, 4)+caseid.substring(caseid.length()-9, caseid.length())+':ref] '; 
        email.plaintextbody='asfdsdfs';
        email.ccaddresses = new list<String>();
        email.toAddresses = new list<String>();
        email.ccAddresses.add('asdasdas@gmail.com');
        email.ccAddresses.add('xcxvcxc@gmail.com');
        email.ccAddresses.add('cvbvbf@gmail.com');
        env.fromAddress = 'jadoo@accenture.com';
        email.fromAddress ='jadoo@accenture.com'; 
        email.toAddresses.add('att@gmail.com');
        email.fromname='asadas';
        sochand.handleInboundEmail(email, env);

        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();
        inAtt.body = blob.valueOf('test');
        inAtt.fileName = 'my attachment name';
        inAtt.mimeTypeSubType = 'plain/txt';

        Messaging.InboundEmail.TextAttachment inAtt1 = new Messaging.InboundEmail.TextAttachment();
        inAtt1.body = 'testasdasd';
        inAtt1.fileName = 'my attachment name 1';
        inAtt1.mimeTypeSubType = 'plain/txt';
   
        
        
        //New email with no refernce number.
        string caseid4 = lcase[1].id;
        email.subject = 'Testing Email To Case'; 
        email.plaintextbody = 'Test Data';
        email.ccaddresses = new list<String>();
        email.toAddresses = new list<String>();
        email.ccAddresses.add('asdasdas@gmail.com');
        email.ccAddresses.add('xcxvcxc@gmail.com');
        email.ccAddresses.add('cvbvbf@gmail.com');
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt };
        email.TextAttachments= new Messaging.inboundEmail.textAttachment[] {inAtt1 };
        env.fromAddress = 'testEmail@test.com';
        email.fromAddress ='testEmail@test.com'; 
        email.toAddresses.add('att@gmail.com');
        email.fromname = 'Test Data';
        sochand.handleInboundEmail(email, env);
        test.stopTest();
                
       
    }
    
    static testmethod void testExtractAddress() {
        String expected = 'b.g@g.com';
        String target = 'Bryan <'+expected+'>';
        social_CaseEmailInBoundUtilities prutil = new social_CaseEmailInBoundUtilities();
        String results = prutil.extractAddress(target);
        System.assertEquals(expected,results);  
        target = 'Helen W ';
        expected = 'Helen.W@on.com';
        results = prutil.extractAddress(target); 
    }  

    static testmethod void testClosedCases() {
        List<Case> lcase=new list<Case>();
        Case testCaseObj = new Case();
        testCaseObj.Status = 'Closed';
        testCaseObj.contactid= lcon1[0].id;
        testCaseObj.Origin='email';     
        testCaseObj.priority = 'Low';
        testCaseObj.OwnerId = u2.id;
        testCaseObj.Reason='Completed';
        testCaseObj.Component_2_Category__c='Incoming Spam';
        testCaseObj.Component_Primary__c='Email'; 
        testCaseObj.Closed_Care_Manager__c = Userinfo.Getuserid();
        testCaseObj.Clarify_CRM_Verified__c='Yes';
        testCaseObj.Method_of_Contact__c = 'NA';
        testCaseObj.Customer_Type__c='Non Customer';
        testCaseObj.Root_Cause__c='Unwanted Solicitation';
        testCaseObj.Effort__c='Non Actionable';
        testCaseObj.Issue_Type__c='Other';
        testCaseObj.Social_Media_Source__c='ATT CustCare Mailbox';
        lcase.add(testCaseObj);
        
        Case testCaseObj1 = new Case();
        testCaseObj1.Status = 'Closed';
        testCaseObj1.contactid=lcon1[0].id;
        testCaseObj1.Origin='email';     
        testCaseObj1.priority = 'Low';
        testCaseObj1.OwnerId = u2.id;
        testCaseObj1.Reason='Completed';
        testCaseObj1.Component_2_Category__c='Incoming Spam';
        testCaseObj1.Component_Primary__c='Email'; 
        testCaseObj1.Closed_Care_Manager__c = Userinfo.Getuserid();
        testCaseObj1.Clarify_CRM_Verified__c='Yes';
        testCaseObj1.Method_of_Contact__c = 'NA';
        testCaseObj1.Customer_Type__c='Non Customer';
        testCaseObj1.Root_Cause__c='Unwanted Solicitation';
        testCaseObj1.Effort__c='Non Actionable';
        testCaseObj1.Issue_Type__c='Other';
        testCaseObj1.Social_Media_Source__c='ATT CustCare Mailbox';
        lcase.add(testCaseObj1);
        
        Case testCaseObj2 = new Case();
        testCaseObj2.Status = 'Closed';
        testCaseObj2.contactid=lcon1[1].id;
        testCaseObj2.Origin='email';     
        testCaseObj2.priority = 'Low';
        testCaseObj2.OwnerId = u2.id;
        testCaseObj2.Reason='Completed';
        testCaseObj2.Component_2_Category__c='Incoming Spam';
        testCaseObj2.Component_Primary__c='Email'; 
        testCaseObj2.Closed_Care_Manager__c = Userinfo.Getuserid();
        testCaseObj2.Clarify_CRM_Verified__c='Yes';
        testCaseObj2.Method_of_Contact__c = 'NA';
        testCaseObj2.Customer_Type__c='Non Customer';
        testCaseObj2.Root_Cause__c='Unwanted Solicitation';
        testCaseObj2.Effort__c='Non Actionable';
        testCaseObj2.Issue_Type__c='Other';
        testCaseObj2.Social_Media_Source__c='ATT CustCare Mailbox';
        testCaseObj2.Current_SLA_Phase__c='SLA1 - Ended';
        lcase.add(testCaseObj2);    
        
        test.startTest(); 
        database.insert(lcase,false); 
        email.subject='asasad';
        email.plaintextbody='asfdsdfs';
        email.ccaddresses = new list<String>();
        email.toAddresses = new list<String>();
        email.ccAddresses.add('asdasdas@gmail.com');
        email.ccAddresses.add('xcxvcxc@gmail.com');
        email.ccAddresses.add('cvbvbf@gmail.com');
        env.fromAddress = 'badoo12@accenture.com';
        email.fromAddress ='badoo12@accenture.com';
        email.toAddresses.add('att@gmail.com');
        email.fromname='asadas';
        sochand.handleInboundEmail(email, env);
        test.StopTest();
        socinb.reopenflag = true;
    }  

    static testmethod void testEscalationContact() {
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        
        Contact contObj = new Contact();     
        contObj.LastName = 'escalationContact';     
        contObj.email = 'awesome@awesome.com';
        contObj.All_Contact_Emails__c = 'awesome@awesome.com,test@test.com'; 
        contObj.Exception_Contact__c = true;
        contactList.add(contObj);
        
        insert contactList;
        
        Case caseObj = new case();
        caseObj.Status = 'New';
        caseObj.contactid=lcon1[0].id;
        caseObj.Origin='email';     
        caseObj.priority = 'Low';
        caseObj.OwnerId = userInfo.getUserId();
        caseObj.Current_SLA_Phase__c='SLA1 - Ended';
        caseList.add(caseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        insert caseList;
        
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();
        inAtt.body = blob.valueOf('test');
        inAtt.fileName = 'my attachment name';
        inAtt.mimeTypeSubType = 'plain/txt';

        Messaging.InboundEmail.TextAttachment inAtt1 = new Messaging.InboundEmail.TextAttachment();
        inAtt1.body = 'testasdasd';
        inAtt1.fileName = 'my attachment name 1';
        inAtt1.mimeTypeSubType = 'plain/txt';
    
        string caseId = caseList[0].id;
        email.subject = 'For example in the ref [ref:_00DL07DQ9._'+ caseId.substring(0, 4)+caseId.substring(caseId.length()-9, caseId.length())+':ref] '; 
        email.plaintextbody='asfdsdfs';
        email.ccaddresses = new list<String>();
        email.toAddresses = new list<String>();
        email.ccAddresses.add('asdasdas@yahoo.com');
        email.ccAddresses.add('xcxvcxc@yahoo.com');
        email.ccAddresses.add('cvbvbf@yahoo.com');
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt };
        email.TextAttachments= new Messaging.inboundEmail.textAttachment[] {inAtt1 };
        env.fromAddress = 'awesome@yahoo.com';
        email.fromAddress ='awesome@yahoo.com'; 
        email.toAddresses.add('att@yahoo.com');
        email.fromname='asadas';
        sochand.handleInboundEmail(email, env);
    }
    
    static testmethod void testNegativeSenario() { 
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        
        Contact contObj = new Contact();     
        contObj.LastName = 'negativeSenario';     
        contObj.email = 'awesome123@awesome.com';
        contObj.All_Contact_Emails__c = 'awesome123@awesome.com,test123@test.com'; 
        contObj.Exception_Contact__c = true;
        contactList.add(contObj);
        
        Case caseObj = new case();
        caseObj.Status = 'New';
        caseObj.contactid=lcon1[0].id;
        caseObj.Origin='email';     
        caseObj.priority = 'Low';
        caseObj.OwnerId = userInfo.getUserId();
        caseObj.Current_SLA_Phase__c='SLA1 - Ended';
        caseList.add(caseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        insert caseList;
        
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();
        inAtt.body = blob.valueOf('test');
        inAtt.fileName = 'my attachment name';
        inAtt.mimeTypeSubType = 'plain/txt';

        Messaging.InboundEmail.TextAttachment inAtt1 = new Messaging.InboundEmail.TextAttachment();
        inAtt1.body = 'testasdasd';
        inAtt1.fileName = 'my attachment name 1';
        inAtt1.mimeTypeSubType = 'plain/txt';
    
        string caseId = caseList[0].id;
        email.subject = null; 
        email.plaintextbody='asfdsdfs';
        email.ccaddresses = new list<String>();
        email.toAddresses = new list<String>();
        email.ccAddresses.add('asdasdas@yahoo.com');
        email.ccAddresses.add('xcxvcxc@yahoo.com');
        email.ccAddresses.add('cvbvbf@yahoo.com');
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt };
        email.TextAttachments= new Messaging.inboundEmail.textAttachment[] {inAtt1 };
        env.fromAddress = 'awesome123@yahoo.com';
        email.fromAddress ='awesome123@yahoo.com'; 
        email.toAddresses.add('att@yahoo.com');
        email.fromname='asadas';
        sochand.handleInboundEmail(email, env);
    }
    
     static testmethod void Soc_caseinbemailutil2() {
         List<Case> lcase=new list<Case>();
         List<contact> lcon = new list<contact>();
         test.startTest();   
             Contact testContact = new Contact();     
             testContact.LastName = 'testContact12';     
             testContact.email = 'jadoo@accenture.com'; 
             testContact.All_Contact_Emails__c = 'jadoo@accenture.com;'; 
             testContact.Exception_Contact__c = true;
             lcon.add(testContact);
       
             Contact testContact1 = new Contact();     
             testContact1.LastName = 'testContact12';     
             testContact1.email = 'jadoo@accenture.com';
             testContact1.All_Contact_Emails__c = 'jadoo@accenture.com;'; 
             lcon.add(testContact1);
            
             database.insert(lcon,false);
             Case testCaseObj = new Case();
            testCaseObj.Status = 'New';
            testCaseObj.contactid=lcon1[0].id;
            testCaseObj.Origin='email';     
            testCaseObj.priority = 'Low';
            testCaseObj.OwnerId = careManager.Id;
            testCaseObj.Current_SLA_Phase__c='SLA1 - Ended';
            lcase.add(testCaseObj);
            
            Case testCaseObj1 = new Case();
            testCaseObj1.Status = 'New';
            testCaseObj1.contactid=lcon1[1].id;
            testCaseObj1.Origin='email';     
            testCaseObj1.priority = 'Low';
            testCaseObj1.OwnerId = UserInfo.getUserid();
            lcase.add(testCaseObj1);
            
            Case testCaseObj2 = new Case();
            testCaseObj2.Status = 'New';
            testCaseObj2.Origin='email';     
            testCaseObj2.priority = 'Low';
            testCaseObj2.OwnerId = careManager.Id;
            lcase.add(testCaseObj2);
            
            Case testCaseObj3 = new Case();
            testCaseObj3.Status = 'Closed';
            testCaseObj3.Method_of_Contact__c = 'Forums';
            testCaseObj3.Customer_Type__c = 'Consumer';
            testCaseObj3.Root_Cause__c = 'Billing Proration';
            testCaseObj3.Effort__c = 'Complex';
            testCaseObj3.Reason = 'Completed';
            testCaseObj3.Clarify_CRM_Verified__c = 'Yes';
            testCaseObj3.Origin='email';     
            testCaseObj3.priority = 'Low';
            testCaseObj3.OwnerId = UserInfo.getUserid();
            testCaseObj3.Current_SLA_Phase__c = 'SLA1 - Ended';
            testCaseObj3.First_SLA_Scheduled_Time__c = dateTime.now().addMinutes(60);
            testCaseObj3.First_SLA_Response_Time__c = dateTime.now();
            lcase.add(testCaseObj3); 
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            
            insert lcase;
            
            Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();
            inAtt.body = blob.valueOf('test');
            inAtt.fileName = 'my attachment name';
            inAtt.mimeTypeSubType = 'plain/txt';

            Messaging.InboundEmail.TextAttachment inAtt1 = new Messaging.InboundEmail.TextAttachment();
            inAtt1.body = 'testasdasd';
            inAtt1.fileName = 'my attachment name 1';
            inAtt1.mimeTypeSubType = 'plain/txt';
            
            //New email with no refernce number.
            string caseid3 = lcase[1].id;
            email.subject = 'Testing Email To Case'; 
            email.plaintextbody = 'Test Data';
            email.ccaddresses = new list<String>();
            email.toAddresses = new list<String>();
            email.ccAddresses.add('asdasdas@gmail.com');
            email.ccAddresses.add('xcxvcxc@gmail.com');
            email.ccAddresses.add('cvbvbf@gmail.com');
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt };
            email.TextAttachments= new Messaging.inboundEmail.textAttachment[] {inAtt1 };
            env.fromAddress = 'jadoo@accenture.com';
            email.fromAddress ='jadoo@accenture.com'; 
            email.toAddresses.add('att@gmail.com');
            email.fromname = 'asadas';
            sochand.handleInboundEmail(email, env);
        }
        
        static testmethod void Soc_caseinbemailutil3() {
         List<Case> lcase=new list<Case>();
         List<contact> lcon = new list<contact>();
         test.startTest();   
             Contact testContact = new Contact();     
             testContact.LastName = 'testContact12';     
             testContact.email = 'jadoo@accenture.com'; 
             testContact.All_Contact_Emails__c = 'jadoo@accenture.com;'; 
             testContact.Exception_Contact__c = true;
             lcon.add(testContact);
       
             Contact testContact1 = new Contact();     
             testContact1.LastName = 'testContact12';     
             testContact1.email = 'jadoo@accenture.com';
             testContact1.All_Contact_Emails__c = 'jadoo@accenture.com;'; 
             lcon.add(testContact1);
            
             database.insert(lcon,false);
             Case testCaseObj = new Case();
            testCaseObj.Status = 'New';
            testCaseObj.contactid=lcon1[0].id;
            testCaseObj.Origin='email';     
            testCaseObj.priority = 'Low';
            testCaseObj.OwnerId = careManager.Id;
            testCaseObj.Current_SLA_Phase__c='SLA1 - Ended';
            lcase.add(testCaseObj);
            
            Case testCaseObj1 = new Case();
            testCaseObj1.Status = 'New';
            testCaseObj1.contactid=lcon1[1].id;
            testCaseObj1.Origin='email';     
            testCaseObj1.priority = 'Low';
            testCaseObj1.OwnerId = UserInfo.getUserid();
            lcase.add(testCaseObj1);
            
            Case testCaseObj2 = new Case();
            testCaseObj2.Status = 'New';
            testCaseObj2.Origin='email';     
            testCaseObj2.priority = 'Low';
            testCaseObj2.OwnerId = careManager.Id;
            lcase.add(testCaseObj2);
            
            Case testCaseObj3 = new Case();
            testCaseObj3.Status = 'Closed';
            testCaseObj3.Method_of_Contact__c = 'Forums';
            testCaseObj3.Customer_Type__c = 'Consumer';
            testCaseObj3.Root_Cause__c = 'Billing Proration';
            testCaseObj3.Effort__c = 'Complex';
            testCaseObj3.Reason = 'Completed';
            testCaseObj3.Clarify_CRM_Verified__c = 'Yes';
            testCaseObj3.Origin='email';     
            testCaseObj3.priority = 'Low';
            testCaseObj3.OwnerId = UserInfo.getUserid();
            testCaseObj3.Current_SLA_Phase__c = 'SLA1 - Ended';
            testCaseObj3.First_SLA_Scheduled_Time__c = dateTime.now().addMinutes(60);
            testCaseObj3.First_SLA_Response_Time__c = dateTime.now();
            lcase.add(testCaseObj3); 
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            
            insert lcase;
            
            Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();
            inAtt.body = blob.valueOf('test');
            inAtt.fileName = 'my attachment name';
            inAtt.mimeTypeSubType = 'plain/txt';

            Messaging.InboundEmail.TextAttachment inAtt1 = new Messaging.InboundEmail.TextAttachment();
            inAtt1.body = 'testasdasd';
            inAtt1.fileName = 'my attachment name 1';
            inAtt1.mimeTypeSubType = 'plain/txt';
            
            string caseid1 = lcase[3].id;
            email.subject = 'For example in the ref [ref:_00DL07DQ9._'+caseid1.substring(0, 4)+caseid1.substring(caseid1.length()-9, caseid1.length())+':ref] '; 
            email.plaintextbody='asfdsdfs';
            email.ccaddresses = new list<String>();
            email.toAddresses = new list<String>();
            email.ccAddresses.add('asdasdas@gmail.com');
            email.ccAddresses.add('xcxvcxc@gmail.com');
            email.ccAddresses.add('cvbvbf@gmail.com');
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt };
            email.TextAttachments= new Messaging.inboundEmail.textAttachment[] {inAtt1 };
            env.fromAddress = 'jadoo@accenture.com';
            email.fromAddress ='jadoo@accenture.com'; 
            email.toAddresses.add('att@gmail.com');
            email.fromname='asadas';
            sochand.handleInboundEmail(email, env);
        }
        
    static testmethod void Soc_caseinbemailutil4() {
        List<Case> lcase=new list<Case>();
        List<contact> lcon = new list<contact>();
        Contact testContact = new Contact();  
        testContact.LastName = 'testContact1';     
        testContact.email = 'jadoo@accenture.com'; 
        testContact.All_Contact_Emails__c = 'jadoo@accenture.com'; 
        testContact.Exception_Contact__c = false;
        lcon.add(testContact);
        insert lcon;
        
        Case testCaseObj = new Case();
        testCaseObj.Status = 'New';
        testCaseObj.contactid=lcon1[0].id;
        testCaseObj.Origin='email';     
        testCaseObj.priority = 'Low';
        testCaseObj.OwnerId = careManager.Id;
        testCaseObj.Current_SLA_Phase__c='SLA1 - Initiated';
        testCaseObj.recordTypeId = System.Label.ConsumerCareCase;
        lcase.add(testCaseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert lcase;
        
        string caseid1 = lcase[0].id;
        email.subject = 'For example in the ref [ref:_00DL07DQ9._'+caseid1.substring(0, 4)+caseid1.substring(caseid1.length()-9, caseid1.length())+':ref] '; 
        email.plaintextbody = 'Test Email Body';
        email.ccaddresses = new list<String>();
        email.toAddresses = new list<String>();
        email.ccAddresses.add('asdasdas@gmail.com');
        email.ccAddresses.add('xcxvcxc@gmail.com');
        email.ccAddresses.add('cvbvbf@gmail.com');
        env.fromAddress = 'jadoo@accenture.com';
        email.fromAddress ='jadoo@accenture.com'; 
        email.toAddresses.add('att@gmail.com');
        email.fromname='asadas';
        sochand.handleInboundEmail(email, env);
    }
    
    static testmethod void Soc_caseinbemailutil5() {
        List<Case> lcase=new list<Case>();
        List<contact> lcon = new list<contact>();
        Contact testContact = new Contact();  
        testContact.LastName = 'testContact1';     
        testContact.email = 'jadoo@accenture.com'; 
        testContact.All_Contact_Emails__c = 'jadoo@accenture.com'; 
        testContact.Exception_Contact__c = false;
        lcon.add(testContact);
        insert lcon;
        
        Case testCaseObj = new Case();
        testCaseObj.Status = 'New';
        testCaseObj.contactid=lcon1[0].id;
        testCaseObj.Origin='email';     
        testCaseObj.priority = 'Low';
        testCaseObj.OwnerId = careManager.Id;
        testCaseObj.Current_SLA_Phase__c='SLA2 - Initiated';
        testCaseObj.recordTypeId = System.Label.ConsumerCareCase;
        lcase.add(testCaseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert lcase;
        
        string caseid1 = lcase[0].id;
        email.subject = 'For example in the ref [ref:_00DL07DQ9._'+caseid1.substring(0, 4)+caseid1.substring(caseid1.length()-9, caseid1.length())+':ref] '; 
        email.plaintextbody = 'Test Email Body';
        email.ccaddresses = new list<String>();
        email.toAddresses = new list<String>();
        email.ccAddresses.add('asdasdas@gmail.com');
        email.ccAddresses.add('xcxvcxc@gmail.com');
        email.ccAddresses.add('cvbvbf@gmail.com');
        env.fromAddress = 'jadoo@accenture.com';
        email.fromAddress ='jadoo@accenture.com'; 
        email.toAddresses.add('att@gmail.com');
        email.fromname='asadas';
        sochand.handleInboundEmail(email, env);
    }
    
    static testmethod void Soc_caseinbemailutil7() {
        List<Case> lcase=new list<Case>();
        List<contact> lcon = new list<contact>();
        Contact testContact = new Contact();  
        testContact.LastName = 'testContact1';     
        testContact.email = 'jadoo@accenture.com'; 
        testContact.All_Contact_Emails__c = 'jadoo@accenture.com'; 
        testContact.Exception_Contact__c = false;
        lcon.add(testContact);
        insert lcon;
        
        Case testCaseObj = new Case();
        testCaseObj.Status = 'New';
        testCaseObj.contactid=lcon1[0].id;
        testCaseObj.Origin='email';     
        testCaseObj.priority = 'Low';
        testCaseObj.OwnerId = careManager.Id;
        testCaseObj.Current_SLA_Phase__c='SLA1 - Ended';
        testCaseObj.recordTypeId = System.Label.ConsumerCareCase;
        testCaseObj.Do_Not_Reassign__c = true;
        lcase.add(testCaseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert lcase;
        
        string caseid1 = lcase[0].id;
        email.subject = 'For example in the ref [ref:_00DL07DQ9._'+caseid1.substring(0, 4)+caseid1.substring(caseid1.length()-9, caseid1.length())+':ref] '; 
        email.plaintextbody = 'Test Email Body';
        email.ccaddresses = new list<String>();
        email.toAddresses = new list<String>();
        email.ccAddresses.add('asdasdas@gmail.com');
        email.ccAddresses.add('xcxvcxc@gmail.com');
        email.ccAddresses.add('cvbvbf@gmail.com');
        env.fromAddress = 'jadoo@accenture.com';
        email.fromAddress ='jadoo@accenture.com'; 
        email.toAddresses.add('att@gmail.com');
        email.fromname='asadas';
        sochand.handleInboundEmail(email, env);
    }
    
    static testmethod void Soc_caseinbemailutil6() {
        List<Case> lcase=new list<Case>();
        List<contact> lcon = new list<contact>();
        Contact testContact = new Contact();  
        testContact.LastName = 'testContact1';     
        testContact.email = 'jadoo@accenture.com'; 
        testContact.All_Contact_Emails__c = 'jadoo@accenture.com'; 
        testContact.Exception_Contact__c = false;
        lcon.add(testContact);
        insert lcon;
        
        Case testCaseObj = new Case();
        testCaseObj.Status = 'New';
        testCaseObj.contactid=lcon1[0].id;
        testCaseObj.Origin='email';     
        testCaseObj.priority = 'Low';
        testCaseObj.OwnerId = careManager.Id;
        testCaseObj.Current_SLA_Phase__c='SLA2 - Ended';
        testCaseObj.recordTypeId = System.Label.ConsumerCareCase;
        testCaseObj.Do_Not_Reassign__c = false;
        testCaseObj.Second_SLA_Response_Time__c = system.Now();
        lcase.add(testCaseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert lcase;
        
        string caseid1 = lcase[0].id;
        email.subject = 'For example in the ref [ref:_00DL07DQ9._'+caseid1.substring(0, 4)+caseid1.substring(caseid1.length()-9, caseid1.length())+':ref] '; 
        email.plaintextbody = 'Test Email Body';
        email.ccaddresses = new list<String>();
        email.toAddresses = new list<String>();
        email.ccAddresses.add('asdasdas@gmail.com');
        email.ccAddresses.add('xcxvcxc@gmail.com');
        email.ccAddresses.add('cvbvbf@gmail.com');
        env.fromAddress = 'jadoo@accenture.com';
        email.fromAddress ='jadoo@accenture.com'; 
        email.toAddresses.add('att@gmail.com');
        email.fromname='asadas';
        sochand.handleInboundEmail(email, env);
    }
}