/**Class Name: Social_DNETestClass
 * Author: Accenture
 * Requirement/Project Name: Social Consumer
 * Requirement Description: Test class for social_DNEHandler, Social_CaseDNE(trigger).
 * Version History: version 1
 */
@isTest(SeeAllData=false)
Public class Social_DNETestClass {
Public static Id consumerCareCaseRT = RecordTypeHelper.GetRecordTypeId(Social_StreamingUtil.CASE_OBJ,Social_StreamingUtil.CONSUMER_CARE_CASE);
    
    static testMethod void social_CaseDNEInsert() {
        List<User> userList = new list<User>();
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        Profile p2 = [select id, name from profile where name='Care Manager'];
        User u1 = new User(alias = 'stanf', email='standarduser1@testorg.com',
                           emailencodingkey='UTF-8', lastname='Testing4f1', languagelocalekey='en_US',
                           localesidkey='en_US', profileid = p2.Id, isActive=true,
                           timezonesidkey='America/Los_Angeles', 
                           Availability__c= 'Vacation', 
                           username='standarduser411f@accenture.com');  
        userList.add(u1);
        insert userList;
        
        Contact contactObj = new Contact();
        contactObj.DNE_Contact__c = 'Sales';
        contactObj.firstName = 'Aditya';
        contactObj.lastName = 'Kumar';
        contactList.add(contactObj);
        insert contactList;
        
        Case singleCase = new Case();
        singleCase.Status = 'New';
        singleCase.OwnerId = u1.Id;
        singleCase.Business_Case_Post_Tag__c = 'DSL';
        singleCase.Social_Media_Source__c = 'ATT Small Biz';
        singleCase.Component_Primary__c = 'DSL';
        singleCase.RecordTypeId = consumerCareCaseRT; 
        singleCase.contactId = contactList[0].Id;
        caseList.add(singleCase);
        
        Case singleCase2 = new Case();
        singleCase2.Status = 'New';
        singleCase2.OwnerId = u1.Id;
        singleCase2.Business_Case_Post_Tag__c = 'DSL';
        singleCase2.Social_Media_Source__c = 'ATT Small Biz';
        singleCase2.Component_Primary__c = 'DSL';
        singleCase2.RecordTypeId = consumerCareCaseRT; 
        singleCase2.contactId = contactList[0].Id;
        caseList.add(singleCase2);
        
        insert caseList;
        
        test.startTest();
        singleCase.DNE__c = 'Checklist';
        update singleCase;
        test.stopTest();
    }
    
    static testMethod void social_CaseDNEInsertC() {
        List<User> userList = new list<User>();
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        Profile p2 = [select id, name from profile where name='Care Manager'];
        User u1 = new User(alias = 'stanf', email='standarduser1@testorg.com',
                           emailencodingkey='UTF-8', lastname='Testing4f1', languagelocalekey='en_US',
                           localesidkey='en_US', profileid = p2.Id, isActive=true,
                           timezonesidkey='America/Los_Angeles', 
                           Availability__c= 'Vacation', 
                           username='standarduser411f@accenture.com');  
        userList.add(u1);
        insert userList;
        
        Contact contactObj = new Contact();
        contactObj.DNE_Contact__c = 'Sales';
        contactObj.firstName = 'Aditya';
        contactObj.lastName = 'Kumar';
        contactList.add(contactObj);
        insert contactList;
        
        Case singleCase = new Case();
        singleCase.Status = 'New';
        singleCase.OwnerId = u1.Id;
        singleCase.Business_Case_Post_Tag__c = 'DSL';
        singleCase.Social_Media_Source__c = 'ATT Small Biz';
        singleCase.Component_Primary__c = 'DSL';
        singleCase.RecordTypeId = consumerCareCaseRT; 
        singleCase.contactId = contactList[0].Id;
        caseList.add(singleCase);
        
        Case singleCase2 = new Case();
        singleCase2.Status = 'New';
        singleCase2.OwnerId = u1.Id;
        singleCase2.Business_Case_Post_Tag__c = 'DSL';
        singleCase2.Social_Media_Source__c = 'ATT Small Biz';
        singleCase2.Component_Primary__c = 'DSL';
        singleCase2.RecordTypeId = consumerCareCaseRT; 
        singleCase2.contactId = contactList[0].Id;
        caseList.add(singleCase2);
        
        insert caseList;
        
        test.startTest();
        contactObj.DNE_Contact__c = 'Sales;CheckList';
        update contactObj;
        test.stopTest();
    }
    
    static testMethod void social_CaseDNEInsertB() {
        List<User> userList = new list<User>();
        List<Case> caseList = new List<Case>();
        List<Case> updateCaseList = new List<case>();
        List<Contact> contactList = new List<Contact>();
        Profile p2 = [select id, name from profile where name='Care Manager'];
        User u1 = new User(alias = 'stan', email='standaerd1@testorg.com',
                           emailencodingkey='UTF-8', lastname='Testing4f1', languagelocalekey='en_US',
                           localesidkey='en_US', profileid = p2.Id, isActive=true,
                           timezonesidkey='America/Los_Angeles', 
                           Availability__c= 'Vacation', 
                           username='standardu1d1f@accenture.com');  
        userList.add(u1);
        insert userList;
        
        Contact contactObj = new Contact();
        contactObj.DNE_Contact__c = 'Sales';
        contactObj.firstName = 'Adi';
        contactObj.lastName = 'Kuma';
        contactList.add(contactObj);
        insert contactList;
    
        Case singleCase = new Case();
        singleCase.Status = 'New';
        singleCase.OwnerId = u1.Id;
        singleCase.Origin = 'twitter';
        singleCase.contactId = contactList[0].Id;
        caseList.add(singleCase);
        
        Case singleCase1 = new Case();
        singleCase1.Status = 'New';
        singleCase1.OwnerId = u1.Id;
        singleCase1.Origin = 'Facebook';
        singleCase1.contactId = contactList[0].Id;
        caseList.add(singleCase1);
        
        Case singleCase3 = new Case();
        singleCase3.Status = 'New';
        singleCase3.OwnerId = u1.Id;
        singleCase3.Origin = 'Twitter';
        singleCase3.contactId = contactList[0].Id;
        caseList.add(singleCase3);
        
        Case singleCase2 = new Case();
        singleCase2.Status = 'New';
        singleCase2.OwnerId = u1.Id;
        singleCase2.Origin = 'Email';
        singleCase2.contactId = contactList[0].Id;
        caseList.add(singleCase2);
        
        insert caseList;
        singleCase1.is_Auto_Closed__c = true;
        updateCaseList.add(singleCase1);
        singleCase2.is_Auto_Closed__c = true;
        updateCaseList.add(singleCase2); 
        singleCase3.is_Auto_Closed__c = true;
        updateCaseList.add(singleCase3);
        update updateCaseList;
    }
}