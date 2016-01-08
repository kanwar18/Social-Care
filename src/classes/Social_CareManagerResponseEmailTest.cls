@isTest(seeAllData=false)
public class Social_CareManagerResponseEmailTest{
    static Profile p1,p2;
    static User u2,u3;
    static Account testAccount1;
    static Contact testContact1;
    static Case caseObji1;
    static EmailMessage theEmail;
    static Custom_Post__c cp;
  
    static {
        p1 = [select id, name from profile where name='System Administrator'];
        u2 = new User(alias = 's121', email='standarduser121@testorg.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  username='standarduser121@accenture.com');
        insert u2;
        p2 = [select id, name from profile where name='Operations Manager'];
        u3 = new User(alias = 's122',Receive_SLA_Missed_Notification_Email__c = True, email='standarduser122@testorg.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = p2.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  username='standarduser122@accenture.com');
        insert u3;
        
        ApexPages.currentPage().getParameters().put('id', u2.Id);
        testAccount1=new Account();     
        testAccount1.Name='testAccount1';     
        insert testAccount1;    
             
        testContact1=new Contact();     
        testContact1.LastName='testContact';     
        testContact1.Account = testAccount1;     
        testContact1.email='d.mittal@accenture.com'; 
        testContact1.All_Contact_Emails__c ='d.mittal@accenture.com;abcd@gmail.com;xyz@gmail.com';   
        insert testContact1;
        
        caseObji1=new Case();    
        caseObji1.Status='New';    
        caseObji1.Origin='email';    
        caseObji1.ContactId=testContact1.Id;    
        caseObji1.contact=testContact1;  
        caseObji1.status = 'Open';
        caseObji1.Audit_Status__c ='Not Audited';
        caseObji1.Closed_Operation_Manager__c=u2.Id;
        insert caseObji1;    
        
        theEmail = new EmailMessage();
        theEmail.ParentId = caseObji1.Id;
        theEmail.Incoming = true;
        theEmail.Subject = 'abcd';
        theEmail.MessageDate = datetime.now();
        theEmail.HtmlBody = 'abcd';  
        theEmail.TextBody = 'abcd';
        theEmail.FromName = 'abcd';
        theEmail.FromAddress = 'abcd1@att.com';
        theEmail.ToAddress ='xyz@gmail.com';
        
        insert theemail;  
        
        cp = new Custom_Post__c();
        cp.Category__c= 'Email';
        cp.Body__c= 'Test Body';
        cp.Subject__c= 'Test Subject';
        cp.AdditionalTo__c= 'xxx@accenture.com';
        cp.BCCAddress__c= 'yyy@accenture.com';
        cp.CCAddress__c= 'zzz@accenture.com';
        cp.Contact__c= testContact1.id;
        cp.Send_Notification_Email__c= true;
        insert cp;
    }  
     
    //test method
    public static TestMethod void Social_CareManagerResponseUtilityTestMethod(){
        test.startTest();
        Social_CareManagerResponseUtility scmru= new Social_CareManagerResponseUtility();
        test.stopTest();
    }
    
    static testMethod void Social_CareManagerResponseEmailTestA(){
        
        caseObji1=new Case();    
        caseObji1.Status='New';    
        caseObji1.Origin='email';    
        caseObji1.ContactId=testContact1.Id;    
        caseObji1.contact=testContact1;  
        caseObji1.status = 'Open';
        caseObji1.Audit_Status__c ='Not Audited';
        caseObji1.Closed_Operation_Manager__c=u2.Id;
        insert caseObji1;
        
        ApexPages.StandardController sCtr1= new ApexPages.StandardController(caseObji1);  
        Social_CareManagerResponseEmail CMResp = new  Social_CareManagerResponseEmail(sCtr1);
        
        CMResp.flag = 'TRUE';
        CMResp.addto = 'test';
        CMResp.flag = 'TRUE';
        CMResp.save();
        CMResp.subj = '';
        CMResp.save();
    }
   
    //test method
    static testMethod void testMultiselectExampleController() {
        // Create some test data
        
        List<Contact> l = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            Contact c = new Contact(firstName = 'User'+i, lastName = 'Name'+i,all_contact_emails__c='assa@gmail.com;dsfsdfsd@gmail.com;xcxcxccx@gmail.com',email='zxxzx@gmail.com');
            l.add(c);
        }
        insert l;
        ApexPages.currentPage().getParameters().put('conid',l[0].Id); 
        Social_CareManagerResponseEmail c = new Social_CareManagerResponseEmail();
        ApexPages.currentPage().getParameters().put('conid',l[0].Id);
        
        
        List<Contact> contacts = [SELECT Name, Id,all_contact_emails__c,email FROM Contact];
        
        System.assertEquals(c.selectedContacts.size(), 0);
        // System.assertEquals(c.allContacts.size(), contacts.size());
        
        c.ok();
        c.message='';
        c.selectedContacts.add(new SelectOption('assa@gmail.com', 'assa@gmail.com'));
        c.selectedContacts.add(new SelectOption('dsfsdfsd@gmail.com', 'dsfsdfsd@gmail.com'));
        
        c.ok();
        l[0].Exception_Contact__c=true;
        update l[0];
        System.assertEquals(c.message,
        'assa@gmail.com;dsfsdfsd@gmail.com');
        
        Boolean result = l[0].all_contact_emails__c.contains(l[0].email);
        System.assertEquals(result, false);
        ApexPages.currentPage().getParameters().put('conid',l[0].Id); 
        ApexPages.currentPage().getParameters().put('exmail','true');  
        Test.startTest();
        Social_CareManagerResponseEmail c1 = new Social_CareManagerResponseEmail();
        ApexPages.currentPage().getParameters().put('conid',l[0].Id); 
        c1.getemails();
        Test.stopTest();
    }
    
    
    //method to enhance the code coverage for the timer app
    public static testMethod void doEmailTest() {
        Test.startTest();
        ApexPages.currentPage().getParameters().put('CaseId',caseObji1.Id);
        ApexPages.currentPage().getParameters().put('flag','TRUE');
        ApexPages.currentPage().getParameters().put('eid',theemail.id);
        ApexPages.StandardController cup1= new ApexPages.StandardController(caseObji1);  
        Social_CareManagerResponseEmail scmre= new  Social_CareManagerResponseEmail(cup1);
        Social_CareManagerResponseEmail scmre_d= new  Social_CareManagerResponseEmail();
        
        ApexPages.StandardController cup2= new ApexPages.StandardController(cp);  
        Social_CareManagerResponseEmail scmre1= new  Social_CareManagerResponseEmail(cup2);
        scmre1.subj='abcdzxzxz';
        scmre1.toemail='abcd@gmail.com';
        scmre1.cc='zxzcz@gmail.com';
        scmre1.bcc='zxzcz12@gmail.com';
        
        scmre_d.getEmailTemplates();
        scmre.showDetail();
        scmre.save();
        scmre.getContactEmail(testContact1.id);
        scmre.checkCustomPostEmailExists(caseObji1.id);
        
        scmre1.save();
        scmre1.getemails();
        Social_CareManagerResponseEmail scmre2= new  Social_CareManagerResponseEmail();
        
        ApexPages.currentPage().getParameters().put('CaseId',caseObji1.Id);
        ApexPages.currentPage().getParameters().put('flag','FALSE');
        ApexPages.StandardController cup3= new ApexPages.StandardController(caseObji1);  
        Social_CareManagerResponseEmail scmre3= new  Social_CareManagerResponseEmail(cup3);
        scmre3.subj=' ';
        scmre3.toemail='abcd@gmail.com';
        scmre3.save();
        
        caseObji1.suppliedemail='d.mittal@accenture.com';
        update caseObji1;
        scmre1.getemails();
        
        testContact1.All_Contact_Emails__c ='';   
        update testContact1;
        scmre1.getemails();
        
        testContact1.All_Contact_Emails__c ='';
        testContact1.email='';   
        update testContact1;
        scmre1.getemails();
        
        testContact1.email='d.mittal@accenture.com'; 
        testContact1.All_Contact_Emails__c ='d.mittal@accenture.com;abcd@gmail.com;xyz@gmail.com';
        update testContact1; 
        
        caseObji1.Current_SLA_Phase__c='SLA1 - Initiated';
        update caseObji1;
        scmre1.caseSLAeventClosure(caseObji1.id,'SLA1 - Initiated');
        
        /* caseObji1.Current_SLA_Phase__c='SLA3 - Initiated';
        update caseObji1;
        scmre1.caseSLAeventClosure(caseObji1.id,'SLA3 - Initiated');
        
        caseObji1.Current_SLA_Phase__c='SLA2 - Initiated';
        update caseObji1;
        scmre1.caseSLAeventClosure(caseObji1.id,'SLA2 - Initiated');*/
        
        List<Event> ltestevent=new list<event>();
        
        Event operationEvent1 = new Event();
        operationEvent1.WhatId = caseObji1.Id;
        operationEvent1.Event_Type__c = 'SLA - 2';
        operationEvent1.Event_Status__c = 'Open';
        operationEvent1.Description = 'asdasdaghfg';
        operationEvent1.OwnerId = u3.id;
        operationEvent1.StartDateTime = system.now();
        operationEvent1.DurationInMinutes = 60;
        operationEvent1.IsReminderSet = true;
        operationEvent1.ReminderDateTime = system.now()+45;
        operationEvent1.Subject = 'SLA - 2'+ ':' + u3.Name + ':' + caseObji1.CaseNumber;     
        //insert operationEvent1;
        ltestevent.add(operationEvent1);
        //scmre1.caseSLAeventClosure(caseObji1.id,'SLA2 - Initiated');   
        
        /*    Event operationEvent = new Event();
        operationEvent.WhatId = caseObji1.Id;
        operationEvent.Event_Type__c = 'SLA - 2';
        operationEvent.Event_Status__c = 'Open';
        operationEvent.Description = 'asdasda';
        operationEvent.OwnerId = u3.id;
        operationEvent.StartDateTime = system.now();
        operationEvent.DurationInMinutes = 60;
        operationEvent.IsReminderSet = true;
        operationEvent.ReminderDateTime = system.now()+45;
        operationEvent.Subject = 'SLA - 2'+ ':' + u3.Name + ':' + caseObji1.CaseNumber;     
        //insert operationEvent;
        ltestevent.add(operationEvent);
        
        Event operationEvent3 = new Event();
        operationEvent3.WhatId = caseObji1.Id;
        operationEvent3.Event_Type__c = 'SLA - 1';
        operationEvent3.Event_Status__c = 'Open';
        operationEvent3.Description = 'asdasdaghfg';
        operationEvent3.OwnerId = u3.id;
        operationEvent3.StartDateTime = system.now();
        operationEvent3.DurationInMinutes = 15;
        operationEvent3.IsReminderSet = true;
        operationEvent3.ReminderDateTime = system.now()+12;
        operationEvent3.Subject = 'SLA - 1'+ ':' + u3.Name + ':' + caseObji1.CaseNumber;     
        //insert operationEvent3;
        ltestevent.add(operationEvent3);*/
        
        database.insert(ltestevent,false);
        
        scmre1.caseSLAeventClosure(caseObji1.id,'SLA2 - Initiated');  
        scmre1.CreateExceptionObject('asdasa');
        Test.stopTest();
    }
}