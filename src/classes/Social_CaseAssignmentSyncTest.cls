@isTest
public class Social_CaseAssignmentSyncTest{
    static Assignment_Group_Name__c assignmentGroup;
    static Assignment_Group_Queues__c agQueue;
    static QueueSobject dslQueue;
    static User user1;

    static{
        
        Profile profile1 = [select id, name from profile where name='Care Manager'];
        user1 = new User(alias = 's123', email='standarduser123@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profile1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Available', 
        username='standarduser123@accenture.com',Case_Counter__c=0);
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

    }
    static testMethod void caseCounterSyncTestMethod(){
        String strCronExp = '0 0 20 * * ? 2022';
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    
        Case testCaseObj = new Case();
        testCaseObj.Status = 'New';
        testCaseObj.Origin='email';     
        testCaseObj.priority = 'Low';
        testCaseObj.OwnerId = user1.Id;
        insert testCaseObj;
    
        Social_CaseAssignmentSyncScheduler testObj =  new Social_CaseAssignmentSyncScheduler();
        String jobId = system.schedule('test', strCronExp, testObj);        
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger where id = :jobId];        
        System.assertEquals(strCronExp, ct.CronExpression);  
    
    }

}