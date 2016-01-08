/********************************************************************************************************
*    Author :     Accenture
*    Requirement: Test class for Social_CareManagerResponseEmailUtility and Trigger Social_CustomPostEmail.
*    Version:     1.0
*    Created Date: 12th May 2015.
*********************************************************************************************************/

@isTest (seeAllData = false)
Public class Social_CareManagerResponseEmailUtilityTe {
    Public static testMethod void CareManagerResponseEmailUtilityTest1 () {
        List<Custom_Post__c> customPostList = new List<Custom_Post__c>();
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        
        Contact testContact1=new Contact();     
        testContact1.LastName='testContact';        
        testContact1.email='d.mittal@accenture.com'; 
        testContact1.All_Contact_Emails__c ='d.mittal@accenture.com;abcd@gmail.com;xyz@gmail.com';  
        contactList.add(testContact1);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert contactList;
        
        Case caseObji1=new Case();    
        caseObji1.Status='New';    
        caseObji1.Origin='email';    
        caseObji1.ContactId=contactList[0].Id;    
        caseObji1.status = 'Open';
        caseObji1.Audit_Status__c ='Not Audited';
        caseObji1.Current_SLA_Phase__c = 'SLA1 - Initiated';
        caseObji1.Closed_Operation_Manager__c=userInfo.getUserId();
        caseList.add(caseObji1);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        Custom_Post__c cp = new Custom_Post__c();
        cp.Category__c= 'Email';
        cp.Body__c= 'Test Body';
        cp.Subject__c= 'Test Subject';
        cp.AdditionalTo__c= 'xxx@accenture.com';
        cp.BCCAddress__c= 'yyy@accenture.com';
        cp.CCAddress__c= 'zzz@accenture.com';
        cp.Contact__c= contactList[0].id;
        cp.case__c = caseList[0].Id;
        cp.Send_Notification_Email__c= true;
        Social_CareManagerResponseUtility.executeTriggerCode = true;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        customPostList.add(cp);
        insert customPostList;
        update customPostList;
    }
    
    Public static testMethod void CareManagerResponseEmailUtilityTest2 () {
        List<Custom_Post__c> customPostList = new List<Custom_Post__c>();
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        
        Contact testContact1=new Contact();     
        testContact1.LastName='testContact';        
        testContact1.email='d.mittal@accenture.com'; 
        testContact1.All_Contact_Emails__c ='d.mittal@accenture.com;abcd@gmail.com;xyz@gmail.com';  
        contactList.add(testContact1);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert contactList;
        
        Case caseObji1=new Case();    
        caseObji1.Status='New';    
        caseObji1.Origin='email';    
        caseObji1.ContactId=contactList[0].Id;    
        caseObji1.status = 'Open';
        caseObji1.Audit_Status__c ='Not Audited';
        caseObji1.Current_SLA_Phase__c = 'SLA2 - Initiated';
        caseObji1.Closed_Operation_Manager__c=userInfo.getUserId();
        caseList.add(caseObji1);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        Custom_Post__c cp = new Custom_Post__c();
        cp.Category__c= 'Email';
        cp.Body__c= 'Test Body';
        cp.Subject__c= 'Test Subject';
        cp.AdditionalTo__c= 'xxx@accenture.com';
        cp.BCCAddress__c= 'yyy@accenture.com';
        cp.CCAddress__c= 'zzz@accenture.com';
        cp.Contact__c= contactList[0].id;
        cp.case__c = caseList[0].Id;
        cp.Send_Notification_Email__c= true;
        Social_CareManagerResponseUtility.executeTriggerCode = true;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        customPostList.add(cp);
        insert customPostList;
    }
}