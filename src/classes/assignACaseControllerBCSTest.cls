@isTest
public class assignACaseControllerBCSTest{
    static User user1;
    static Assignment_Group_Name__c assignmentGroup;
    static Assignment_Group_Queues__c agQueue;
    static QueueSobject GenBCQueue;
    
    static{        
        Profile profile1 = [select id, name from profile where name = 'Care Manager Business'];
        user1 = new User(alias = 'standt', email ='standarduser@testorg.com',
        emailencodingkey ='UTF-8', lastname ='Testing', languagelocalekey ='en_US',
        localesidkey ='en_US', profileid = profile1.Id, isactive =true,
        timezonesidkey='America/Los_Angeles', Availability__c ='Available', 
        username ='standarduser121@accenture.com',Case_Counter__c = 0);
        insert user1;
        
        GenBCQueue = [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where
                      q.Queue.Name = 'General-bc' limit 1];
            
        assignmentGroup =  new Assignment_Group_Name__c();
        assignmentGroup.Name = 'General-bc';
        insert assignmentGroup;
        
        agQueue =  new Assignment_Group_Queues__c();
        agQueue.Name = 'General-bc';
        agQueue.QueueId__c = GenBCQueue.QueueId;
        agQueue.Assignment_Group_Name__c = assignmentGroup.id;
        agQueue.Active__c = 'true';
        insert agQueue;
        
        Assignment_Groups__c careMan1 = new Assignment_Groups__c();
        careMan1.User__c = user1.Id;
        careMan1.Group_Name__c = assignmentGroup.Id;
        careMan1.Cases_Owned__c =  25;
        insert careMan1;
        
        Case testCaseObj1 = new Case();
        testCaseObj1.Status = 'New';
        testCaseObj1.Origin = 'Email Business (BizHelp)';     
        testCaseObj1.priority = 'Low';
        testCaseObj1.OwnerId = agQueue.QueueId__c;
        testCaseObj1.Track_Case_Queue__c = agQueue.QueueId__c;
        testCaseObj1.Business_Case_Post_Tag__c = 'GCS-GEN';
        testCaseObj1.Component_Primary__c = 'DSL';
        testCaseObj1.NonCaseOwner_LastModifiedDate__c = system.now();
        testCaseObj1.BCS_Self_Assigned__c = TRUE ; 
        testCaseObj1.Current_SLA_Phase__c = NULL ;
        insert testCaseObj1;
        
        Case testCaseObj2 = new Case();
        testCaseObj2.Status = 'Investigating';
        testCaseObj2.Origin = '';     
        testCaseObj2.priority = 'Low';
        testCaseObj2.OwnerId = agQueue.QueueId__c;
        testCaseObj2.Track_Case_Queue__c = agQueue.QueueId__c;
        testCaseObj2.Business_Case_Post_Tag__c = 'GCS-GEN';
        testCaseObj2.Component_Primary__c = 'DSL';
        testCaseObj2.NonCaseOwner_LastModifiedDate__c = system.now();
        testCaseObj2.BCS_Self_Assigned__c = TRUE ; 
        testCaseObj2.Current_SLA_Phase__c = 'SLA1 - Ended' ;
        insert testCaseObj2;
        
        
    }
    
    static testMethod void assignBCSCaseTestMethod(){
        assignACaseControllerBCS assigncaseBCS=  new assignACaseControllerBCS();
        assigncaseBCS.groupName = 'General-bc';
        assigncaseBCS.numberOfCasesToBeAssigned  = '1';
        assigncaseBCS.getNumberOfCases();
        assigncaseBCS.getCareManagerCaseCounter(user1.Id,assignmentGroup.Name);
        assigncaseBCS.getCareManagerAvailability(user1.Id,assignmentGroup.Name);
        
        system.RunAs(user1){
            assigncaseBCS.getAssociatedGroupNames();
            assigncaseBCS.assignCase();
            
        }
    }
}