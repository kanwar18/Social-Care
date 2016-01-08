/********************************************************************************************************
*    Author: Ashween Kaur
*    Test Class for : Social_ValidateAssignment
*    Version: 1.0
*    
********************************************************************************************************/
@isTest(seeAllData = True) 
private class Social_ValidateAssignment_Test{
    public static Id caseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Case');
    //public static Id caseAuditRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Case QA Record Type');
    static testMethod void validateAssignmentTest(){ 
      //Fetching the assignment rules on case
    Map<String, ID> groupNameMap = new Map<String, ID>();
    String grpName1 = 'Forums';
    String grpName2 = 'Mobility';
    List<Group> queueID = [Select Id, Name from Group where Type='Queue' AND ( Name = 'FORUMS' OR Name = 'Mobility')];
    for(Group grp :queueID ){
       groupNameMap.put(grp.Name, grp.Id);
    }  
        List<User> userList = new List<User>();
        List<Case> caseList = new List<Case>();
        List<Case> updatecaseList = new List<Case>();
        List<Case> secondUpdateList = new List<Case>();
        Profile p1 = [select id, name from profile where name='Care Manager Business'];
        Profile p2 = [select id, name from profile where name='Senior Operations Manager Business'];
        User u1 = new User(alias = 's152', email='standarduser152@testorg.com',
                  emailencodingkey='UTF-8', lastname='TestUser1', languagelocalekey='en_US',
                  localesidkey='en_US', profileid = p2.Id, isActive=true,
                  timezonesidkey='America/Los_Angeles', 
                  Availability__c= 'Available', 
                  username='standarduser152@accenture.com');   
                
        userList.add(u1);  
            
        User u2 = new User(alias = 's153', email='standarduser2153@testorg.com',
                  emailencodingkey='UTF-8', lastname='TestUser2', languagelocalekey='en_US',
                  localesidkey='en_US', profileid = p1.Id, ManagerId = u1.Id, isActive=true,
                  timezonesidkey='America/Los_Angeles', 
                  Availability__c= 'Available', 
                  username='standarduser2153@accenture.com');
                
        userList.add(u2);
        insert userList;
        
        Case singleCase1 = new Case();
            singleCase1.Status = 'New';
            singleCase1.OwnerId = u2.Id;
            singleCase1.Case_PostTag__c = 'GCS-GEN';
            singleCase1.Social_Media_Source__c = 'ATT Small Biz';
            singleCase1.Component_Primary__c = 'DSL';
            singleCase1.RecordTypeId = caseRecordTypeId;                                
            caseList.add(singleCase1);
        Case singleCase2 = new Case();
            singleCase2.Status = 'New';
            singleCase2.OwnerId = u2.Id;
            singleCase2.Case_PostTag__c = 'GCS-GEN';
            singleCase2.Social_Media_Source__c = 'ATT Small Biz';
            singleCase2.Component_Primary__c = 'DSL';
            singleCase2.RecordTypeId = caseRecordTypeId;                            
            caseList.add(singleCase2);
            
            insert caseList;
            
            singleCase1.Case_PostTag__c = 'FORUMS';
            singleCase2.Case_PostTag__c = 'GENERAL';            
            secondUpdateList.add(singleCase1);
            secondUpdateList.add(singleCase2);
            update secondUpdateList;
            
            system.RunAs(u2){
                singleCase1.OwnerId = groupNameMap.get(grpName1);
                updatecaseList.add(singleCase1);
                
                singleCase2.OwnerId = groupNameMap.get(grpName2);
                updatecaseList.add(singleCase2);
            
            update updatecaseList;
            }
    }            
            

}