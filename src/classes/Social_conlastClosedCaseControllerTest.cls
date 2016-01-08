@isTest(seeAllData=false)
public class Social_conlastClosedCaseControllerTest{
    static testMethod void ContactLastClosedCaseControllerTestA() { 
        test.starttest();
        List<User> userList = new List<User>();
        List<Case> caseList= new List<Case>();
        List<Contact> contactList = new List<Contact>();
        insert userList;
        //insert contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        //Insert a case
        Case caseObj = new Case(Status = 'Close', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Customer_Response_Received_Time__c = system.Now(), OwnerId = userInfo.getUserId(), Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Ended');
        caseList.add(caseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
    }
    }