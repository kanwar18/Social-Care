@isTest

public class Social_UACaseAssignmentTriggerTest{

    static User user1;
    static Assignment_Group_Name__c assignmentGroup;
    static Assignment_Group_Queues__c agQueue;
    static QueueSobject dslQueue;
    static Case testCase;
    
    static{
        Profile profile1 = [select id, name from profile where name='Care Manager'];
        user1 = new User(alias = 's151', email='standarduser151@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profile1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Offline', 
        username='standarduser151@accenture.com',Case_Counter__c=0);
        insert user1;
        
        dslQueue = [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where
            q.Queue.Name = 'Mobility' limit 1];
            
        assignmentGroup =  new Assignment_Group_Name__c();
        assignmentGroup.Name = 'Mobility';
        insert assignmentGroup;
        
        agQueue =  new Assignment_Group_Queues__c();
        agQueue.Name = 'Mobility';
        agQueue.QueueId__c = dslQueue.QueueId;
        agQueue.Assignment_Group_Name__c = assignmentGroup.id;
        agQueue.Active__c = 'true';
        insert agQueue;
        
        Assignment_Groups__c careMan1 = new Assignment_Groups__c();
        careMan1.User__c = user1.Id;
        careMan1.Group_Name__c = assignmentGroup.Id;
        insert careMan1;
        
        testCase = new Case();
        testCase.Status='New';
        testCase.OwnerId = dslQueue.QueueId;
        testCase.Case_PostTag__c = 'Mobility';
        testCase.origin = 'Engagement Console';
        RecordType caseRecordtypeConsumer = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.Name = 'Consumer Care Case'];
        testCase.RecordTypeId = caseRecordtypeConsumer.id;
        insert testCase;
        
        testCase.origin = 'Engagement Console';
        testCase.Engagement_Console_User__c = '';
        update testCase;
    }

    public static testMethod void Social_UserAvailabliltyCaseAssignmentTestMethod(){
    
        user1.Availability__c = 'Available';
        update user1;
    }
    
}