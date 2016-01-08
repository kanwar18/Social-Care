/********************************************************************************************************
*    Author :     Accenture
*    Requirement: Test class for Left side panel 
*    Version:     1.0
*    Created Date: 5th May 2015.
*********************************************************************************************************/

@isTest (seeAllData = false)
Public class Social_CaseUpdateInteractionLogTest {
    public static TestMethod void checkMyOpenCases() {
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        //insert contact
        Contact contactObj = new Contact();
        contactObj.FirstName = 'Test';
        contactObj.LastName = 'User';
        contactList.add(contactObj);
        insert contactList;
        //insert Case
        Case caseObj = new Case();
        caseObj.ownerId = userInfo.getUserId();
        caseObj.Status = 'New';
        caseObj.Priority = 'Medium';
        caseObj.ContactId = contactList[0].Id;
        caseObj.Subject = 'TWEET FROM: testUser';
        caseObj.Customer_Response_Received_Time__c = system.Now();
        caseObj.OwnerId = userInfo.getUserId();
        caseObj.Case_Post_Tag__c = 'autodir,Unknown';
        caseObj.Social_Media_Source__c = 'Twitter';
        caseObj.RecordTypeId = system.Label.ConsumerCareCase;
        caseObj.Social_Care_Handle_Name__c = 'Testing my test class for SCS';
        caseList.add(caseObj);
        insert caseList;
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController(caseObj);
        Social_CaseUpdateInteractionLog caseUpdateLog = new Social_CaseUpdateInteractionLog(standardCtrl);
    }
}