/**************************************************************************
Class Name: SocialClassTest
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: test class for Social_CaseUtilHandler                                
Version History: Abhishek(16/May/2014)
**************************************************************************************************************************/
@isTest(seeAllData=TRUE)
public class SocialClassTest {

    static Account testAccount;
    static Contact testContact;
    static Case testCase;
    static Case testCase1;
    static Case testCase2;
    static Case testCase3;
    static Case testBusinessCase1;
    static User user1;
    static User user2;
    static User opsManager;
    static Event caseEvent;
    // Static Queue
    static QueueSobject dslQueue;
    static QueueSobject uverseQueue;
    static QueueSobject generalBCQueue;
    static QueueSobject caseReopenQueue;
    static QueueSobject secondSLAQueue;
    // Static Assgn Group
    static Assignment_Group_Name__c dslGroupName;
    static Assignment_Group_Name__c uverseGroupName;
    Public static List<Assignment_Group_Name__c> uverseGroupName1= new List<Assignment_Group_Name__c>();
    
    
    Public static List<Case> caseList = new List<Case>();
    Public static List<User> userList = new List<User>();
    
    static {

    
        testAccount=new Account();
        testAccount.Name='testAccount';
        insert testAccount;
        
        testContact=new Contact();
        testContact.AccountId=testAccount.Id;
        testContact.LastName='testName';
        testContact.email='testemail@abc.com';
        testContact.Account = testAccount;
        insert testContact;  

        testCase = new Case();
        testCase.ContactId=testContact.Id;
        testCase.Status='New';
        testCase.Origin='email';
        testCase.Contact=testContact;
        caseList.add(testCase);
        
        testCase1 = new Case();
        testCase1.ContactId=testContact.Id;
        testCase1.Status='New';
        testCase1.Origin='email';
        testCase1.Contact=testContact;
        caseList.add(testCase1);
        
        testCase2 = new Case();
        testCase2.ContactId=testContact.Id;
        testCase2.Status='New';
        testCase2.Origin='email';
        testCase2.Contact=testContact;
        caseList.add(testCase2);
        
        testCase3= new Case();
        testCase3.ContactId=testContact.Id;
        testCase3.Status='New';
        testCase3.Origin='email';
        testCase3.Contact=testContact;
        caseList.add(testCase3);

        //Business Case Test Case Insert
        testBusinessCase1 = new Case();
        testBusinessCase1.ContactId = testContact.Id;
        testBusinessCase1.Status = 'New';
        testBusinessCase1.Origin = 'email';
        testBusinessCase1.Contact = testContact;
        caseList.add(testBusinessCase1);
        
        insert caseList;//Inserting cases

        Profile profile1 = [select id, name from profile where name='Care Manager'];
        
        opsManager = new User(alias = 'opsmng', email='manageruser@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profile1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Available', 
        username='manageruser@accenture.com', Case_Counter__c=0);
        insert opsManager;
        
        user1 = new User(alias = 'standt', email='SocialClassUser@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profile1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Available', 
        username='SocialClassUser1@accenture.com',Case_Counter__c=0, ManagerId=opsManager.Id);
        userList.add(user1);
      
        user2 = new User(alias = 'standt1', email='SocialClassUser11@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profile1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Available', 
        username='SocialClassUser11@accenture.com', Case_Counter__c=0, ManagerId=opsManager.Id);
        userList.add(user2);
        
        insert userList;//Inserting User
        
        // Query Queue(DSL/U-Verse)
        dslQueue = [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name = 'Mobility' limit 1];
        uverseQueue = [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name = 'U-verse Sales & Service' limit 1];
        caseReopenQueue = [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name = 'Case Reopen Queue' limit 1];
        // Query Queue(General-bc)
        generalBCQueue = [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name = 'General-bc' limit 1];
        
        // Query Assignment Group(DSL/U-Verse)
        dslGroupName = [Select a.Name, a.Id From Assignment_Group_Name__c a where a.Name='Mobility' limit 1];
        uverseGroupName = [Select a.Name, a.Id From Assignment_Group_Name__c a where a.Name='U-verse Sales & Service' limit 1];
        secondSLAQueue = [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name = 'Second SLA Queue' limit 1];
    }
        
   
   //Test Method for the trigger Social_validateCaseQueue 
   public static TestMethod void Social_validateCaseQueueTestMethodPart1(){
     
       Test.startTest();
         List<Assignment_Groups__c> assignmentGrpList = new List<Assignment_Groups__c>();
         Social_triggerRunControl.isTriggerFirstRun = true;
         // Add Assignment Members(Care Managers)
         Assignment_Groups__c careMan1 = new Assignment_Groups__c();
         careMan1.User__c = user1.Id;
         careMan1.Group_Name__c = dslGroupName.Id;
         assignmentGrpList.add(careMan1);
         
         Assignment_Groups__c careMan2 = new Assignment_Groups__c();
         careMan2.User__c = user2.Id;
         careMan2.Group_Name__c = uverseGroupName.Id;
         assignmentGrpList.add(careMan2); 
         
         insert assignmentGrpList;
         
         // Update Case Owner To Queue
         testCase2.OwnerId = dslQueue.QueueId;
         testCase2.Case_PostTag__c = 'General';
         update testCase2;
         
        caseEvent = new Event();
        caseEvent.WhatId = testCase2.id;
        caseEvent.Event_Type__c = 'SLA - 1';
        caseEvent.Event_Status__c = 'Open';
        caseEvent.Description = 'Test';
        caseEvent.StartDateTime = System.now();
        caseEvent.DurationInMinutes = 60;

        insert caseEvent;
         
       Test.stopTest();
    }
    
    public static TestMethod void Social_validateCaseQueueTestMethodPart2(){
    Test.startTest();
    // Case Owner Re-assignment(User-Queue)
    Social_triggerRunControl.isTriggerFirstRun = true;
    testCase2.OwnerId = uverseQueue.QueueId;
    testCase2.Case_PostTag__c = 'General,U-Verse';
    testCase2.Reassignment_Reason__c = 'SLA Callback Missed Not Checked';
    testCase2.Case_Assigned_Time__c = System.now();
    update testCase2;
    
    Test.stopTest();
    }
  
    // Re-open Scenario - CM Unavailable
    public static TestMethod void Social_validateCaseQueueTestMethod_ReopenCase_Caremanager_UnavailablePart1(){
        
        Test.startTest();
        Social_CaseUtilHandler schandler=new Social_CaseUtilHandler();
        List<Assignment_Groups__c> assgrouplist=new List<Assignment_Groups__c>();
        Assignment_Groups__c assGroup=new Assignment_Groups__c();
        testCase2.Case_PostTag__c = 'General,U-Verse';
        testCase2.ownerid= dslQueue.QueueId;
        update testCase2;
        assgrouplist.add(assGroup);
        assGroup.user__c=user2.id;
        assGroup.user__c=user1.id;
        assGroup=schandler.getAvailableCareManager(testCase2.ownerid, testCase2.Status);
        system.debug('qqqqqqqqqqqqqqqqqqqqqqqqqqqq'+assGroup);
       // integer i=schandler.generateCareMangerIndex(dslGroupName.Id, assgrouplist, testCase2.Status);
        Test.stopTest();
         
    }
    
    public static TestMethod void Social_getAvailableCareManager(){
        Test.startTest();
            Social_triggerRunControl.isTriggerFirstRun = true;
            testCase2.Status = 'Closed';
            testCase2.Current_SLA_Phase__c = 'SLA1 - Initiated';      
            testCase2.Effort__c = 'Complex';
            testCase2.Customer_Type__c = 'Enterprise';
            testCase2.Root_Cause__c = 'Billing Error'; 
            testCase2.Reason = 'Completed';
            testCase2.Clarify_CRM_Verified__c = 'Yes';
            testCase2.RecordTypeId=RecordTypeHelper.GetRecordTypeId('Case','Business Care Closed Case');
            testCase2.Method_of_Contact__c='NA';
            testCase2.Social_Media_Source__c='Blogs';
            update testCase2;
        Test.stopTest();
    }
    
    public static TestMethod void Social_getAvailableCareManager1(){
        Test.startTest();        
            Event testEvent = new Event();        
            testEvent.Event_Status__c='Open';        
            testEvent.Event_Type__c='SLA - 1';
            testEvent.DurationInMinutes=10;        
            testEvent.ActivityDateTime=System.Today();
            insert testEvent;
            testEvent.WhatId=testCase.id;
            update testEvent;
        Test.stopTest();
    }
    
    public static TestMethod void Social_getAvailableCareManager2(){
        Test.startTest();
            // Reopen the Case
            Social_triggerRunControl.isTriggerFirstRun = true;
            testCase2.Current_SLA_Phase__c = 'SLA1 - Ended';
            testCase2.Second_SLA_Pending_Post__c = true;
            testCase2.Status = 'Reopen';
            testCase2.Case_PostTag__c = 'General,U-Verse';
            testCase2.OwnerId = uverseQueue.QueueId;
            update testCase2;
        Test.stopTest();
    }
    
    public static TestMethod void Social_validateCaseQueueTestMethod_ReopenCase_Caremanager_UnavailablePart2(){
        Test.startTest();
        Social_triggerRunControl.isTriggerFirstRun = true;
        testCase2.Status = 'Closed';
        testCase2.OwnerId = user1.Id;
        testCase2.Current_SLA_Phase__c = 'SLA2 - Initiated';      
        testCase2.Effort__c = 'Complex';
        testCase2.Customer_Type__c = 'Enterprise';
        testCase2.Root_Cause__c = 'Billing Error'; 
        testCase2.Effort__c = 'Complex';
        testCase2.Reason = 'Completed'; 
       
        
        
        
        Test.stopTest();
    }
    
    public static TestMethod void Social_validateCaseQueueTestMethod_ReopenCase_Caremanager_UnavailablePart3(){
        Test.startTest();        
        testCase3.Clarify_CRM_Verified__c = 'Yes';
        testCase3.Reassignment_Reason__c = 'SLA Callback Missed Not Checked';   
        testCase3.Method_of_Contact__c='NA';   
        testCase3.check_for_user_owner_change_validation__c = true;
        update testCase3;        
        
        testCase3.Reason = 'Duplicate';
        //update testCase3;
        
        
        // Reopen the Case
        Social_triggerRunControl.isTriggerFirstRun = true;
        
        user1.Availability__c = 'Offline';
        update user1;
        
        user2.Availability__c = 'Offline';
        update user2;
        
        testCase3.Current_SLA_Phase__c = 'SLA1 - Ended';
        testCase3.Second_SLA_Pending_Post__c = true;
        testCase3.Case_Reopen_Flag__c = true;
        testCase3.Status = 'Reopen';
        testCase3.Case_PostTag__c = 'General,U-Verse';
        testCase3.OwnerId = uverseQueue.QueueId;
        update testCase3;
        
        
        
        Test.stopTest();
    }
    
    public static TestMethod void Social_validateCaseQueueTestMethod_BusinessCasePart1(){
            Test.startTest();
             // Update Case Owner To Queue
            Social_triggerRunControl.isTriggerFirstRun = true; 
            testBusinessCase1.OwnerId = generalBCQueue.QueueId;
            testBusinessCase1.Reassignment_Reason__c = 'Not Trained';            
            testBusinessCase1.Case_PostTag__c = 'GCS-IPHONE';
            update testBusinessCase1;
        
            //Case from General-bc Queue to User        
            Social_triggerRunControl.isTriggerFirstRun = true;
            testBusinessCase1.OwnerId = user1.Id;
            update testBusinessCase1;
            
            
         
        Test.stopTest();
    }
  /*  public static TestMethod void Social_validateCaseQueueTestMethod_BusinessCasePart2(){
        Test.startTest();
        
        Social_triggerRunControl.isTriggerFirstRun = true;
        testBusinessCase1.Reassignment_Reason__c = 'Not Trained';            
        testBusinessCase1.OwnerId = user1.Id;
        update testBusinessCase1;
        
        //Case from User to General-bc Queue
        Social_triggerRunControl.isTriggerFirstRun = true;
        testBusinessCase1.OwnerId = generalBCQueue.QueueId;
        testBusinessCase1.Case_PostTag__c = 'GCS-IPHONE';
        testBusinessCase1.Reassignment_Reason__c = 'Not Trained';
        testBusinessCase1.Case_Assigned_Time__c = System.now();
        update testBusinessCase1;

        Social_triggerRunControl.isTriggerFirstRun = true;
        testBusinessCase1.Reassignment_Reason__c = 'Not Trained';
        testBusinessCase1.Case_Assigned_Time__c = System.now();
        testBusinessCase1.OwnerId = user1.Id;
        update testBusinessCase1;
        Test.stopTest();        
    }*/
    public static TestMethod void Social_validateCaseQueueTestMethod_BusinessCaseCloseCase(){
    
            Test.startTest();
            // Update Case Status (Close Case)
            Social_triggerRunControl.isTriggerFirstRun = true;
            testBusinessCase1.OwnerId = user1.Id;
            testBusinessCase1.Reassignment_Reason__c = 'Not Trained';
            testBusinessCase1.Status = 'Closed';
            testBusinessCase1.Root_Cause__c = 'Billing Error';
            testBusinessCase1.Component_Primary__c = 'DSL';
            testBusinessCase1.Effort__c = 'Complex';
            testBusinessCase1.Customer_Type__c = 'Enterprise';
            testBusinessCase1.Reason = 'Resolved';
            testBusinessCase1.Clarify_CRM_Verified__c = 'Yes';
            testBusinessCase1.Social_Media_Source__c = 'Ask and Answer';
            testBusinessCase1.Method_of_Contact__c='NA';
            testBusinessCase1.check_for_user_owner_change_validation__c = true;
            update testBusinessCase1;
            
            Social_triggerRunControl.isTriggerFirstRun = true;
            testBusinessCase1.Status = 'Investigating';
            update testBusinessCase1;
            
            Test.stopTest();
    }
    public static TestMethod void Social_validateCaseQueueTestMethod_BusinessCaseReopenCasePart1(){

            Test.startTest();
            Social_triggerRunControl.isTriggerFirstRun = true;
            RecordType caseRecordtype = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.Name = 'Business Care Case'];
            //Reopen the case
            testBusinessCase1.RecordTypeId = caseRecordtype.id;
            testBusinessCase1.Status = 'Closed';
            testBusinessCase1.Effort__c = 'Complex';
            testBusinessCase1.Customer_Type__c = 'Enterprise';
            testBusinessCase1.Root_Cause__c = 'Billing Error'; 
            testBusinessCase1.Effort__c = 'Complex';
            testBusinessCase1.Reason = 'Resolved'; 
            testBusinessCase1.Clarify_CRM_Verified__c = 'Yes';          
            testBusinessCase1.Current_SLA_Phase__c = 'SLA1 - Initiated';
            testBusinessCase1.Social_Media_Source__c = 'Ask and Answer';
            testBusinessCase1.Method_of_Contact__c='NA';
            update testBusinessCase1;
            Test.stopTest();
            
            Social_triggerRunControl.isTriggerFirstRun = true;
            testBusinessCase1.Status = 'Reopen';
            testBusinessCase1.Current_SLA_Phase__c = 'SLA1 - Ended';
            update testBusinessCase1;
       }
       
    public static TestMethod void Social_validateCaseQueueTestMethod_BusinessCaseReopenCasePart2(){
        Test.startTest();
        Social_triggerRunControl.isTriggerFirstRun = true;
        testBusinessCase1.OwnerId = caseReopenQueue.QueueId;
        update testBusinessCase1;
        
        
        // Make Owner Un Available
        user1.Availability__c = 'Available';
        update user1;
    
        Social_triggerRunControl.isTriggerFirstRun = true;
        testBusinessCase1.OwnerId = secondSLAQueue.QueueId;
        testBusinessCase1.Second_SLA_Queue_Flag__c = true;
        testBusinessCase1.Case_System_Reassign__c = true;
        testBusinessCase1.Second_SLA_Case_Owner_Track__c = secondSLAQueue.QueueId;
        update testBusinessCase1;
        Test.stopTest();
    }
        public static TestMethod void Social_validateCaseQueueTestMethod_BusinessCaseQueueToConsumerQueue(){
            Test.startTest();
            /*Social_triggerRunControl.isTriggerFirstRun = true;
            RecordType caseRecordtypeBusiness = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.Name = 'Business Care Case'];
            testBusinessCase1.RecordTypeId = caseRecordtypeBusiness.id;
            testBusinessCase1.OwnerId = uverseQueue.QueueId;
            testBusinessCase1.Status = 'Investigating';
            testBusinessCase1.Reassignment_Reason__c = 'Not Trained';            
            testBusinessCase1.Case_PostTag__c = 'General,U-Verse';
            update testBusinessCase1;
        
            Social_triggerRunControl.isTriggerFirstRun = true;
            RecordType caseRecordtypeConsumer = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.Name = 'Consumer Care Case'];
            testBusinessCase1.RecordTypeId = caseRecordtypeConsumer.id;
            testBusinessCase1.OwnerId = generalBCQueue.QueueId;
            testBusinessCase1.Reassignment_Reason__c = 'Not Trained';
            testBusinessCase1.Status = 'Investigating';
            testBusinessCase1.Case_PostTag__c = 'GCS-IPHONE';
            update testBusinessCase1;*/
        
            Test.stopTest();
        }
   
}