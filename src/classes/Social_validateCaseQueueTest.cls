/********************************************************************************************************
*    Author :     Accenture-Consumer
*    Requirement: Test Class for Social_validateCaseQueue
*    Version:     1.0
*    Created Date: 26 June 2014.
*********************************************************************************************************/
@isTest
Public class Social_validateCaseQueueTest {
    static testMethod void testCaseIndicatorCheckBox1 () {        
        List<contact> contactList = new list<contact>();
        List<Event> EventList = new List<Event>();
        List<Task> TaskList = new List<Task>();
        List<Case> caseList = new List<Case>();
        
        contact testContact = new Contact();
        testContact.LastName = 'testContact';
        testContact.email = 'test@test.com';
        testContact.Last_Case_Closed__c = System.Now();
        contactList.add(testContact);
        insert contactList;  
        
        Case caseObj=new Case();
        caseObj.Status = 'New';
        caseObj.Origin = 'email';
        caseObj.priority = 'Medium';
        caseObj.contactid = contactList[0].id;
        caseObj.contact = contactList[0];
        caseObj.Case_Reopen_Flag__c = true;        
        caseObj.Second_SLA_Pending_Post__c = true;        
        caseObj.recordTypeId = Label.ManualCareCaseRT;
        caseObj.Business_Survey_Indicator__c = TRUE ;
        caseObj.Do_Not_Reassign_Timeframe__c='Do Not Reassign';
        caseObj.Case_PostTag__c= 'hjdgkhfl';
        caseObj.Origin = 'Engagement Console';
        caseObj.Engagement_Console_User__c = '';
        caseList.add(caseObj);
       	        
        Case caseObj1=new Case();
        caseObj1.Status = 'New';
        caseObj1.Origin = 'email';
        caseObj1.priority = 'Medium';
        caseObj1.contactid = contactList[0].id;
        caseObj1.contact = contactList[0];
        caseObj1.Business_Case_Post_Tag__c = 'FORUMS';
        caseObj1.Contains_Consumer_Post_Tag__c = True;
        caseObj1.Case_Reopen_Flag__c = true;        
        caseObj1.Second_SLA_Pending_Post__c = true;         
        caseObj1.recordTypeId = Label.Business_Care_Case_Record_Type_ID;
        caseObj1.Do_Not_Reassign_Timeframe__c='Do Not Reassign';
		caseObj1.Case_PostTag__c= 'hjdgkhfl';
		caseObj1.Origin = 'Engagement Console';
        caseObj1.Engagement_Console_User__c = '';
        caseList.add(caseObj1);
        
        Case caseObj2=new Case();
        caseObj2.Status = 'New';
        caseObj2.Origin = 'email';
        caseObj2.priority = 'Medium';
        caseObj2.contactid = contactList[0].id;
        caseObj2.contact = contactList[0];
        caseObj2.Business_Case_Post_Tag__c = 'FORUMS';
        caseObj2.Contains_Consumer_Post_Tag__c = false;
        caseObj2.Case_Reopen_Flag__c = true;       
        caseObj2.Second_SLA_Pending_Post__c = true;		       
        caseObj2.recordTypeId = Label.Business_Care_Case_Record_Type_ID;
        caseObj2.Do_Not_Reassign_Timeframe__c='Do Not Reassign';
		caseObj2.Case_PostTag__c= 'hjdgkhfl';
        caseObj2.Origin = 'Engagement Console';
        caseObj2.Engagement_Console_User__c = '';
        caseList.add(caseObj2);
        
        Case caseObj3=new Case();
        caseObj3.Status = 'New';
        caseObj3.Origin = 'email';
        caseObj3.priority = 'Medium';
        caseObj3.contactid = contactList[0].id;
        caseObj3.contact = contactList[0];
        caseObj3.Business_Case_Post_Tag__c = 'GCS-LANDLINE';
        caseObj3.Case_Reopen_Flag__c = true;
        caseObj3.Second_SLA_Pending_Post__c = true;         
        caseObj3.recordTypeId = Label.Business_Care_Case_Record_Type_ID;
        caseObj3.Do_Not_Reassign_Timeframe__c='Do Not Reassign';
		caseObj3.Case_PostTag__c= 'hjdgkhfl'; 
        caseObj3.Origin = 'Engagement Console';
        caseObj3.Engagement_Console_User__c = '';
        caseList.add(caseObj3);
        insert caseList;
        
        
        caseList[0].Reason = 'Not SM Owned';
        caseList[0].status = 'Closed';
        caseList[0].Root_Cause__c = 'Billing Error';
        caseList[0].Effort__c = 'Simple';
        caseList[0].Customer_Type__c = 'Consumer';
        caseList[0].Clarify_CRM_Verified__c = 'Yes';
        caseList[0].Method_of_Contact__c = 'Email';
        caseList[1].Business_Case_Post_Tag__c = 'DSL BILLING';
        caseList[1].Contains_Consumer_Post_Tag__c = True;
        caseList[2].Business_Case_Post_Tag__c = 'DSL BILLING';
        
        Event eventObj = new Event();
        eventObj.whatId = caseList[0].id;       
        eventObj.Event_Status__c = 'CASE_CLOSED';
        eventObj.Event_Type__c='sla3';
        eventObj.StartDateTime = System.now();
        eventObj.DurationInMinutes = 15;
        eventObj.IsReminderSet = true;
        eventObj.ReminderDateTime = System.now().addMinutes(5);       
        eventList.add(eventObj);
        insert eventList;              
        eventObj.whatId = caseList[2].id;
        update eventObj;
        
        Task taskobj = new Task();
        taskobj.OwnerId = UserInfo.getUserId();
        taskobj.Status = 'Completed';
        //taskobj.Whatid = '';       
        TaskList.add(taskobj);
        Insert TaskList;
        
        try{
            update caseList;
        }
        catch(Exception e) {
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            System.Assert(e.getMessage().contains('You have selected a Consumer post tag, Please confirm by selecting the checkbox'));
       } 
              
    }
    static testMethod void testCaseIndicatorCheckBox2 () {
        
        List<contact> contactList = new list<contact>();
        List<Case> caseList = new List<Case>();		       
        contact testContact = new Contact();
        testContact.LastName = 'testContact';
        testContact.email = 'test@test.com';
        contactList.add(testContact);
        insert contactList;  
        
        Case caseObj1=new Case();
        caseObj1.Status = 'New';
        caseObj1.Origin = 'email';
        caseObj1.priority = 'Medium';
        caseObj1.contactid = contactList[0].id;
        caseObj1.contact = contactList[0];        
        caseObj1.Business_Case_Post_Tag__c = 'FORUMS';
        caseObj1.Contains_Consumer_Post_Tag__c = True;
        caseObj1.recordTypeId = Label.Business_Manual_RT;        
        caseList.add(caseObj1);
        
        Case caseObj2=new Case();
        caseObj2.Status = 'New';
        caseObj2.Origin = 'email';
        caseObj2.priority = 'Medium';
        caseObj2.contactid = contactList[0].id;
        caseObj2.contact = contactList[0];
        caseObj2.Business_Case_Post_Tag__c = 'FORUMS';
        caseObj2.Contains_Consumer_Post_Tag__c = false;
        caseObj2.recordTypeId = Label.Business_Manual_RT;       
        caseList.add(caseObj2);
        
        Case caseObj3=new Case();
        caseObj3.Status = 'New';
        caseObj3.Origin = 'email';
        caseObj3.priority = 'Medium';
        caseObj3.contactid = contactList[0].id;
        caseObj3.contact = contactList[0];
        caseObj3.Business_Case_Post_Tag__c = 'GCS-LANDLINE';
        caseObj3.recordTypeId = Label.Business_Manual_RT;       
        caseList.add(caseObj3); 
        
       
       try{
            insert caseList;           
        }
        catch(Exception e) {
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            //System.Assert(e.getMessage().contains('You have selected a Consumer post tag, Please confirm by selecting the checkbox'));
       }
    }
    
}