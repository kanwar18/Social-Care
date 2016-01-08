/********************************************************************************************************
*    Author: Ashween Kaur
*    Test Class for : Social_BusinessAutoCaseClosure
*    Version: 1.0
*    
********************************************************************************************************/
@isTest(seeAllData = True) 
private class Social_BusinessAutoCaseClosure_Test{
    public static Id caseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Case');    
    static testMethod void autoCloseCaseTest(){    
        List<User> userList = new List<User>();
        List<Case> caseList = new List<Case>();
        List<Event> EventList = new list<Event>(); 
        List<event> updateeventlist = new List<event>();
        List<Case> updatecaseList = new List<Case>();
        Profile p1 = [select id, name from profile where name='Care Manager Business'];
        Profile p2 = [select id, name from profile where name='Senior Operations Manager Business'];
        User u1 = new User(alias = 's114', email='standarduser114@testorg.com',
                  emailencodingkey='UTF-8', lastname='TestUser1', languagelocalekey='en_US',
                  localesidkey='en_US', profileid = p2.Id, isActive=true,
                  timezonesidkey='America/Los_Angeles', 
                  Availability__c= 'Available', 
                  username='standarduser114@accenture.com');   
        userList.add(u1);  
        User u2 = new User(alias = 's115', email='standarduser115@testorg.com',
                  emailencodingkey='UTF-8', lastname='TestUser2', languagelocalekey='en_US',
                  localesidkey='en_US', profileid = p1.Id, ManagerId = u1.Id, isActive=true,
                  timezonesidkey='America/Los_Angeles', 
                  Availability__c= 'Available', 
                  username='standarduser115@accenture.com');
        userList.add(u2);
        insert userList;
        
        Case singleCase3 = new Case();
        singleCase3.Status = 'Closed';
        singleCase3.Clarify_CRM_Verified__c = singleCase3.Clarify_CRM_Verified__c != null ? singleCase3.Clarify_CRM_Verified__c : 'No';
        singleCase3.Customer_Type__c = singleCase3.Customer_Type__c != null ? singleCase3.Customer_Type__c : 'Small Business';
        singleCase3.Root_Cause__c = singleCase3.Root_Cause__c != null ? singleCase3.Root_Cause__c : 'No Response';
        singleCase3.Effort__c = singleCase3.Effort__c != null ? singleCase3.Effort__c : 'Simple';
        singleCase3.Reason = singleCase3.Reason != null ? singleCase3.Reason : 'Never Responded';
        singleCase3.Component_Primary__c = singleCase3.Component_Primary__c != null ? singleCase3.Component_Primary__c : 'Unknown';
        singleCase3.Component_2_Category__c = singleCase3.Component_2_Category__c != null ? singleCase3.Component_2_Category__c : 'Unknown';
        singleCase3.Social_Media_Source__c = singleCase3.Social_Media_Source__c != null ? singleCase3.Social_Media_Source__c : 'Twitter';
        singleCase3.RecordTypeId = System.Label.Business_Closed_RT;
        singleCase3.Current_SLA_Phase__c = 'SLA1 - Initiated' ;
        caseList.add(singleCase3); 
                      
        Case singleCase2 = new Case();         
        singleCase2.OwnerId = u2.Id;
        singleCase2.Business_Case_Post_Tag__c = 'GCS-GEN';
        singleCase2.Social_Media_Source__c = 'ATT Small Biz';
        singleCase2.Component_Primary__c = 'DSL';
        singleCase2.Origin = 'Email Business (BizHelp)';
        singleCase2.RecordTypeId = caseRecordTypeId;
        singleCase2.Current_SLA_Phase__c = 'SLA2 - Initiated' ; 
        singleCase2.Second_SLA_Scheduled_Time__c = datetime.now().addMinutes(15);
        caseList.add(singleCase2);          
        insert caseList;
            
        Event  eventObj = new Event();
        eventObj.whatId = singleCase3.id;       
        eventObj.Event_Status__c = 'Open';
        eventObj.Event_Type__c='SLA - 1';
        eventObj.StartDateTime = System.now();
        eventObj.EndDateTime = System.now().addMinutes(15);
        eventObj.subject = 'Call';
        eventObj.Ownerid = u2.Id;     
        eventList.add(eventObj);
        insert eventList;
                            
        singleCase2.Auto_Close_Indicator__c = TRUE;         
        updatecaseList.add(singleCase2);
        singleCase3.Auto_Close_Indicator__c = TRUE;
        updatecaseList.add(singleCase3);      
        update updatecaseList;
    }
    
    static testMethod void autoCloseCaseTest1(){    
        List<User> userList = new List<User>();
        List<Case> caseList = new List<Case>();
        List<Event> EventList = new list<Event>(); 
        List<event> updateeventlist = new List<event>();
        List<Case> updatecaseList = new List<Case>();
        Profile p1 = [select id, name from profile where name='Care Manager Business'];
        Profile p2 = [select id, name from profile where name='Senior Operations Manager Business'];
        User u1 = new User(alias = 's114', email='standarduser114@testorg.com',
                  emailencodingkey='UTF-8', lastname='TestUser1', languagelocalekey='en_US',
                  localesidkey='en_US', profileid = p2.Id, isActive=true,
                  timezonesidkey='America/Los_Angeles', 
                  Availability__c= 'Available', 
                  username='standarduser114@accenture.com');   
        userList.add(u1);  
        User u2 = new User(alias = 's115', email='standarduser115@testorg.com',
                  emailencodingkey='UTF-8', lastname='TestUser2', languagelocalekey='en_US',
                  localesidkey='en_US', profileid = p1.Id, ManagerId = u1.Id, isActive=true,
                  timezonesidkey='America/Los_Angeles', 
                  Availability__c= 'Available', 
                  username='standarduser115@accenture.com');
        userList.add(u2);
        insert userList;
        
        Case singleCase3 = new Case();
        singleCase3.Status = 'Closed';
        singleCase3.Clarify_CRM_Verified__c = singleCase3.Clarify_CRM_Verified__c != null ? singleCase3.Clarify_CRM_Verified__c : 'No';
        singleCase3.Customer_Type__c = singleCase3.Customer_Type__c != null ? singleCase3.Customer_Type__c : 'Small Business';
        singleCase3.Root_Cause__c = singleCase3.Root_Cause__c != null ? singleCase3.Root_Cause__c : 'No Response';
        singleCase3.Effort__c = singleCase3.Effort__c != null ? singleCase3.Effort__c : 'Simple';
        singleCase3.Reason = singleCase3.Reason != null ? singleCase3.Reason : 'Never Responded';
        singleCase3.Component_Primary__c = singleCase3.Component_Primary__c != null ? singleCase3.Component_Primary__c : 'Unknown';
        singleCase3.Component_2_Category__c = singleCase3.Component_2_Category__c != null ? singleCase3.Component_2_Category__c : 'Unknown';
        singleCase3.Social_Media_Source__c = singleCase3.Social_Media_Source__c != null ? singleCase3.Social_Media_Source__c : 'Twitter';
        singleCase3.RecordTypeId = System.Label.Business_Closed_RT;
        singleCase3.Current_SLA_Phase__c = 'SLA2 - Initiated' ;
        caseList.add(singleCase3);          
        insert caseList;
            
        Event  eventObj = new Event();
        eventObj.whatId = singleCase3.id;       
        eventObj.Event_Status__c = 'Open';
        eventObj.Event_Type__c='SLA - 2';
        eventObj.StartDateTime = System.now();
        eventObj.EndDateTime = System.now().addMinutes(60);
        eventObj.subject = 'Call';
        eventObj.Ownerid = u2.Id;     
        eventList.add(eventObj);
        insert eventList;
                            
        singleCase3.Auto_Close_Indicator__c = TRUE;
        updatecaseList.add(singleCase3);      
        update updatecaseList;
    }
}