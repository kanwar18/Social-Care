@isTest
public class Social_CaseAssignmentTest{
    
    static Assignment_Group_Name__c assignmentGroup;
    static Assignment_Group_Queues__c agQueue;
    static QueueSobject dslQueue;
    static User user1;
    
    static{
        
        Profile profile1 = [select id, name from profile where name='Care Manager'];
        user1 = new User(alias = 's124', email='standarduser124@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profile1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Available', 
        username='standarduser124@accenture.com',Case_Counter__c=0);
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

    static testMethod void assignCaseTestMethod(){
                            
        String strCronExp = '0 0 20 * * ? 2022';
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        Case testCaseObj = new Case();
        testCaseObj.Status = 'New';
        testCaseObj.Origin='email';     
        testCaseObj.priority = 'Low';
        testCaseObj.OwnerId = agQueue.QueueId__c;
        insert testCaseObj;
   
        testCaseObj.Current_SLA_Phase__c = 'SLA1 - Ended';
        testCaseObj.Customer_Response_Received__c = true;
        update testCaseObj;

        Case testCaseObj2 = new Case();
        testCaseObj2.Status = 'New';
        testCaseObj2.Origin='email';     
        testCaseObj2.priority = 'Investigating';
        testCaseObj2.OwnerId = agQueue.QueueId__c;
        //testCaseObj2.Case_Assigned_Time__c = System.now();
        insert testCaseObj2;
     
        Case testCaseObj1 = new Case();
        testCaseObj1.Status = 'New';
        testCaseObj1.Origin='email';     
        testCaseObj1.priority = 'Low';
        testCaseObj1.OwnerId = agQueue.QueueId__c;
        insert testCaseObj1;
     
        SocialPost sp =  new SocialPost();
        sp.R6Service__SourceTags__c = 'Influencer High';
        sp.Headline = 'Test';
        sp.Name = 'Test';
        sp.ParentId = testCaseObj1.id;
        insert sp;
        
        
        Test.startTest();
        
        Social_CaseAssignmentScheduler testObj =  new Social_CaseAssignmentScheduler();
        String jobId = system.schedule('test', strCronExp, testObj);        
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger where id = :jobId];        
        System.assertEquals(strCronExp, ct.CronExpression);                                      
        
        Social_CaseAssignment sca =  new Social_CaseAssignment();
        sca.assignCase();
        Test.stopTest();
        
    }
    static testMethod void assignCaseTestMethod2(){
        String strCronExp = '0 0 20 * * ? 2022';
        
        Case testCaseObj2 = new Case();
        testCaseObj2.Status = 'New';
        testCaseObj2.Origin='email';     
        testCaseObj2.priority = 'Investigating';
        testCaseObj2.OwnerId = agQueue.QueueId__c;
        testCaseObj2.Case_Assigned_Time__c = System.now();
        insert testCaseObj2;
        
        Test.startTest();
        
        testCaseObj2.Current_SLA_Phase__c = 'SLA1 - Ended';
        testCaseObj2.Customer_Response_Received__c = true;
        testCaseObj2.Case_Reopen_Flag__c = true;
        testCaseObj2.Second_SLA_Pending_Post__c = true;
        update testCaseObj2;
        
        testCaseObj2.Current_SLA_Phase__c = 'SLA1 - Ended';
        testCaseObj2.Case_Reopen_Flag__c = true;
        testCaseObj2.Second_SLA_Pending_Post__c = true;
        update testCaseObj2;
        
        
        Social_CaseAssignmentScheduler testObj =  new Social_CaseAssignmentScheduler();
        String jobId = system.schedule('test', strCronExp, testObj);        
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger where id = :jobId];        
        System.assertEquals(strCronExp, ct.CronExpression);                                      
        
        Social_CaseAssignment sca =  new Social_CaseAssignment();
        sca.assignCase();
        Test.stopTest();
    
    }
    static testMethod void assignCaseTestMethod3(){
        String strCronExp = '0 0 20 * * ? 2022';
        
        Case testCaseObj3 = new Case();
        testCaseObj3.Status = 'New';
        testCaseObj3.Origin='email';     
        testCaseObj3.priority = 'Investigating';
        testCaseObj3.OwnerId = agQueue.QueueId__c;
        testCaseObj3.Case_Assigned_Time__c = System.now();
        insert testCaseObj3;
        
        Test.startTest();

        testCaseObj3.Current_SLA_Phase__c = 'SLA1 - Ended';
        testCaseObj3.Case_Reopen_Flag__c = true;
        testCaseObj3.Second_SLA_Pending_Post__c = true;
        testCaseObj3.Customer_Response_Received__c = false;
        update testCaseObj3;
        
        
        Social_CaseAssignmentScheduler testObj =  new Social_CaseAssignmentScheduler();
        String jobId = system.schedule('test', strCronExp, testObj);        
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger where id = :jobId];        
        System.assertEquals(strCronExp, ct.CronExpression);                                      
        
        Social_CaseAssignment sca =  new Social_CaseAssignment();
        sca.assignCase();
        Test.stopTest();
    
    }
}