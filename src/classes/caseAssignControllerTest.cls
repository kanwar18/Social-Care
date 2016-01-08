@isTest
public class caseAssignControllerTest{
    static User user1;
    static Assignment_Group_Name__c assignmentGroup;
    static Assignment_Group_Queues__c agQueue;
    static QueueSobject dslQueue;
    static{
        
        Profile profile1 = [select id, name from profile where name='Care Manager'];
        user1 = new User(alias = 'standt', email='standarduser@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profile1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Available', 
        username='standarduser121@accenture.com',Case_Counter__c=0);
        insert user1;
        
        dslQueue = [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where
            q.Queue.Name = 'Spanish' limit 1];
            
        assignmentGroup =  new Assignment_Group_Name__c();
        assignmentGroup.Name = 'Spanish';
        insert assignmentGroup;
        
        agQueue =  new Assignment_Group_Queues__c();
        agQueue.Name = 'Spanish';
        agQueue.QueueId__c = dslQueue.QueueId;
        agQueue.Assignment_Group_Name__c = assignmentGroup.id;
        agQueue.Active__c = 'true';
        insert agQueue;
        
        Assignment_Groups__c careMan1 = new Assignment_Groups__c();
        careMan1.User__c = user1.Id;
        careMan1.Group_Name__c = assignmentGroup.Id;
        insert careMan1;
        
        Case testCaseObj = new Case();
        testCaseObj.Status = 'New';
        testCaseObj.Origin='email';     
        testCaseObj.priority = 'Low';
        testCaseObj.OwnerId = agQueue.QueueId__c;
        insert testCaseObj;
    }
    static testMethod void assignCaseTestMethod(){
        caseAssignController cac =  new caseAssignController();
        cac.groupName = 'Spanish';
        cac.numberOfCasesToBeAssigned  = '1';
        cac.getNumberOfCases();
        system.RunAs(user1){
            cac.getAssociatedGroupNames();
            cac.assignCase();
        }
    }
}