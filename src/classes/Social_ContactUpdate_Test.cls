/********************************************************************************************************
*    Author: Arun Ramachandran
*    Test Class for : Social_ContactUpdate_Test
*    Version: 1.0
*    
********************************************************************************************************/

@isTest(seeAllData = FALSE) 
private class Social_ContactUpdate_Test{

     public static Id caseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Case');
     static testMethod void reassignSLA(){
         Profile p1 = [select id, name from profile where name='Care Manager Business'];
         User u3 = new User(alias = 'standef', email='standarduser1@testorg.com',
            emailencodingkey='UTF-8', lastname='Testingf1', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser11f@accenture.com');
            
         insert u3;
         
         Contact singleContact = new Contact();
         singleContact.LastName = 'Test' ;
         singleContact.email = 'abc@accenture.com';
         singleContact.OwnerId = u3.Id;
         
         insert singleContact;         
         
         Case singleCase = new Case();
            singleCase.Status = 'New';
            singleCase.OwnerId = u3.Id;
            singleCase.Business_Case_Post_Tag__c = 'GCS-GEN';
            singleCase.Social_Media_Source__c = 'ATT Small Biz';
            singleCase.Component_Primary__c = 'DSL';
            singleCase.RecordTypeId = caseRecordTypeId;
            singleCase.ContactId = singleContact.Id; 
            
            insert singleCase;
     }
}