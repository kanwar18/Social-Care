/********************************************************************************************************
*    Author: Arun Ramachandran
*    Test Class for : Social_BusinessRoundRobin
*    Version: 1.0
*    
********************************************************************************************************/
@isTest(seeAllData = True) 
private class Social_BusinessRoundRobin_Test{

    public static Id caseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Manual Business Care Case');
   
    static testMethod void reassignSLA(){
        
    //Fetching the assignment rules on case
    AssignmentRule AR = new AssignmentRule();
    AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
     
    //Creating the DMLOptions for "Assign using active assignment rules" checkbox
    Database.DMLOptions dmlOpts = new Database.DMLOptions();
    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
    
        List<User> userList = new List<User>();
        List<Event> slaList = new List<Event>();
        Set<Id> userSet = new Set<Id>();
        List<Case> caseList = new List<Case>();
        List<Case> updateCaseList = new List<Case>();
        Profile p1 = [select id, name from profile where name='Care Manager Business'];
        Profile p2 = [select id, name from profile where name='Senior Operations Manager Business'];
       
        User u3 = new User(alias = 's116', email='standarduser116@testorg.com',
            emailencodingkey='UTF-8', lastname='Testingf1', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p2.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser11f116@accenture.com'); 
            
        userList.add(u3);      
        
        User u4 = new User(alias = 's117', email='standarduser117@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing4f1', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p2.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Vacation', 
            username='standarduser411f117@accenture.com');   
            
        userList.add(u4);  
        
        User u1 = new User(alias = 's118', email='standarduser118@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id, ManagerId = u3.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser118@accenture.com');
        userSet.add(u1.Id);     
        userList.add(u1);
            
        User u2 = new User(alias = 's119', email='standarduser119@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id, ManagerId = u4.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser119@accenture.com'); 
        
        userList.add(u2); 
        
         User u5 = new User(alias = 's120', email='standarduser13120@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing3', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id, ManagerId = u4.Id, isActive=true,
            timezonesidkey='America/Los_Angeles', 
            Availability__c= 'Available', 
            username='standarduser33120@accenture.com'); 
        
        userList.add(u5); 
        insert userList;
        
        Case singleCase = new Case();
            singleCase.Status = 'New';
            singleCase.OwnerId = u1.Id;
            singleCase.Origin = 'Email Business (YouTube)' ;
            singleCase.Current_SLA_Phase__c = 'SLA2 - Initiated';
            singleCase.Business_Case_Post_Tag__c = 'GCS-GEN';
            singleCase.Social_Media_Source__c = 'ATT Small Biz';
            singleCase.Component_Primary__c = 'DSL';
            singleCase.RecordTypeId = caseRecordTypeId; 
            singleCase.setOptions(dmlOpts);           
            caseList.add(singleCase);
            
        Case singleCase2 = new Case();
            singleCase2.Status = 'New';
            singleCase2.OwnerId = u1.Id;
            singleCase2.Business_Case_Post_Tag__c = 'GCS-GEN';
            singleCase2.Social_Media_Source__c = 'ATT Small Biz';
            singleCase2.Component_Primary__c = 'DSL';
            singleCase2.RecordTypeId = caseRecordTypeId; 
            singleCase2.setOptions(dmlOpts);           
            caseList.add(singleCase2); 
            
        Case singleCase3 = new Case();
            singleCase3.Status = 'New';
            singleCase3.OwnerId = u1.Id;
            singleCase3.Business_Case_Post_Tag__c = 'GCS-GEN';
            singleCase3.Social_Media_Source__c = 'ATT Small Biz';
            singleCase3.Component_Primary__c = 'DSL';
            singleCase3.RecordTypeId = caseRecordTypeId; 
            singleCase3.setOptions(dmlOpts);           
            caseList.add(singleCase3);        
            
         Case singleCase1 = new Case();
            singleCase1.Status = 'New';
            singleCase1.OwnerId = u2.Id;
            singleCase1.Case_PostTag__c= 'GCS-GEN';
            singleCase1.Social_Media_Source__c = 'ATT Small Biz';
            singleCase1.Component_Primary__c = 'DSL';
            singleCase1.RecordTypeId = caseRecordTypeId;
            singleCase1.setOptions(dmlOpts);
            caseList.add(singleCase1);
         Case singleCase4 = new Case();
            singleCase4.Status = 'New';
            singleCase4.OwnerId = u2.Id;
            singleCase4.Case_PostTag__c= 'GCS-SALESLEAD';
            singleCase4.Social_Media_Source__c = 'ATT Small Biz';
            singleCase4.Component_Primary__c = 'DSL';
            singleCase4.RecordTypeId = caseRecordTypeId;
            singleCase4.setOptions(dmlOpts);
            caseList.add(singleCase4);   
         Case singleCase5 = new Case();
            singleCase5.Status = 'Investigating';
            singleCase5.OwnerId = u1.Id;
            singleCase5.Case_PostTag__c= 'GCS-GEN';
            singleCase5.Social_Media_Source__c = 'ATT Small Biz';
            singleCase5.Component_Primary__c = 'DSL';
            singleCase5.RecordTypeId = caseRecordTypeId;
            singleCase5.Current_SLA_Phase__c = 'SLA1 - Ended';
            singleCase5.setOptions(dmlOpts);
            caseList.add(singleCase5);   
            
           Case singleCase6 = new Case();
            singleCase6.Status = 'Investigating';
            singleCase6.OwnerId = u5.Id;
            singleCase6.Case_PostTag__c= 'GCS-SALESLEAD';
            singleCase6.Social_Media_Source__c = 'ATT Small Biz';
            singleCase6.Component_Primary__c = 'DSL';
            singleCase6.RecordTypeId = caseRecordTypeId;
            singleCase6.Current_SLA_Phase__c = 'SLA2 - Initiated';
            singleCase6.setOptions(dmlOpts);
            caseList.add(singleCase6);    
            insert caseList; 
         
         singleCase.Status = 'Follow Up Hold';
         singleCase1.Status = 'Closed';
         singleCase1.Current_SLA_Phase__c = 'SLA1 - Ended';
         updateCaseList.add(singleCase);
         updateCaseList.add(singleCase1);
         update updateCaseList;
         
         Integer index = 5;
         List<Assignment_Groups__c> groupUsersList = new List<Assignment_Groups__c>();
         Assignment_Group_Name__c testAssignmentGroup;
         boolean caseIdentifier = false ;
         
         testAssignmentGroup = [Select a.Name, a.Id From Assignment_Group_Name__c a 
                       where a.Name='General-bc' limit 1]; 
         Assignment_Groups__c testMemberOne;  
         
        testMemberOne = new Assignment_Groups__c();
        testMemberOne.Last_Assignment__c =  System.now();
        testMemberOne.User__c = u1.Id;
        testMemberOne.Group_Name__c = testAssignmentGroup.Id;
        //insert testMemberOne;
        groupUsersList.add(testMemberOne);             
        
        Social_BusinessRoundRobin.businessCaseAssignmentAvailability(userSet);  
        Social_BusinessRoundRobin.evaluateUserToAssign(index, groupUsersList, caseIdentifier);
            
    } 
}