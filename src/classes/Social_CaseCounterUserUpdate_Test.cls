/*******************************************************************************************************************
Class Name: Social_CaseCounterUserUpdate_Test
Covers CLasses : Social_CaseCounterUserUpdate, BizReopenCaseReassignment(Trigger)
Created By: Haemen Shah
Requirement : Test Class
Version : 1.0
*********************************************************************************************************************/
@isTest (SeeAllData= False)
    Public class Social_CaseCounterUserUpdate_Test{
        public static QueueSobject uverseQueue;
        Public static List<User> userList = new List<User>();
        
        Public static testmethod void Social_CaseCounterUserUpdate_Test1() {
            uverseQueue = [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name = 'U-verse Sales & Service' limit 1];
            Profile p1 = [select id, name from profile where name='Care Manager'];
        
            User u1 = new User(alias = 'standt', email='standarduser@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id, isactive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='testCaseCounter@accenture.com');
            insert u1;
                       
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Case c1 = new case();
            c1.Status = 'New';
            c1.OwnerId = uverseQueue.QueueId;
            c1.Social_Media_Source__c = 'ATT Small Biz';
            c1.Component_Primary__c = 'U-verse Sales & Service';

            insert c1;
            c1.OwnerId = u1.id;
            update c1;
                      
        }
        static testmethod void Social_CaseCounterUserUpdate_Test2() {
            
            uverseQueue = [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name = 'U-verse Sales & Service' limit 1];
            Profile p1 = [select id, name from profile where name='Care Manager'];
        
            User u2 = new User(alias = 'standt5', email='standarduser123@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id, isactive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser123@accenture.com');
            userList.add(u2);
      
            User u3 = new User(alias = 'standt1', email='standarduser6@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id, isactive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='testCaseCounter1@accenture.com');
            userList.add(u3);   
            
            insert userList;    
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Case c1 = new case();
            c1.Status = 'New';
            c1.OwnerId = u2.id;
            c1.Social_Media_Source__c = 'ATT Small Biz';
            c1.Component_Primary__c = 'U-verse Sales & Service';
            insert c1;
            c1.Reassignment_Reason__c = 'Not Trained';
            c1.OwnerId = u3.id;
            c1.check_for_user_owner_change_validation__c = true;
            update c1;
        }
        
        static testmethod void Social_CaseCounterUserUpdate_Test3() {
            uverseQueue = [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name = 'U-verse Sales & Service' limit 1];
            Profile p1 = [select id, name from profile where name='Care Manager'];
        
            User u4 = new User(alias = 'standt7', email='standarduser7@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id, isactive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='testCaseCounter3@accenture.com');
            insert u4;
                       
            
            Case c1 = new case();
            c1.Status = 'New';
            c1.OwnerId = u4.id;
            c1.Social_Media_Source__c = 'ATT Small Biz';
            c1.Component_Primary__c = 'U-verse Sales & Service';
            insert c1;
            c1.Reassignment_Reason__c = 'Not Trained';
            c1.OwnerId = uverseQueue.QueueId;
            update c1;
         }
         Public static testmethod void Social_CaseCounterUserUpdate_Test4() {
            
            Profile p1 = [select id, name from profile where name='Care Manager'];
        
            User u6 = new User(alias = 'standt9', email='standarduser13@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id, isactive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='testCaseCounter6@accenture.com');
            Insert u6; 
            
            
            Case c1 = new case();
            c1.Status = 'New';
            c1.OwnerId = u6.Id;
            c1.Social_Media_Source__c = 'ATT Small Biz';
            c1.Component_Primary__c = 'U-verse Sales & Service';
            insert c1;
            c1.DNE__c = 'Sales';
            c1.Customer_Type__c = 'Enterprise';
            c1.Root_Cause__c = 'Billing Proration';
            c1.Effort__c = 'Complex';
            c1.Reason = 'Completed';
            c1.Case_Reason_HSRep__c = 'Resolved';
            c1.Clarify_CRM_Verified__c = 'Yes';
            c1.Method_of_Contact__c = 'Email';
            
            c1.Status = 'Closed';
            update c1;
         }
         Public static testmethod void Social_CaseCounterUserUpdate_Test5() {
            
            uverseQueue = [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name = 'U-verse Sales & Service' limit 1];
            Case c1 = new case();
            c1.Status = 'Follow Up Hold';
            c1.OwnerId = uverseQueue.QueueId;
            c1.Social_Media_Source__c = 'ATT Small Biz';
            c1.Component_Primary__c = 'U-verse Sales & Service';
            insert c1;
            c1.Status = 'New';
            update c1;
         }
    }