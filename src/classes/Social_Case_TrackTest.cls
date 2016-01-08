@isTest

public class Social_Case_TrackTest{
   /* static Account testAccount;
    static Contact testContact;
    static case caseObj;
    
    static{
        testAccount=new Account();       
        testAccount.Name='testAccount1';       
        insert testAccount;     
                    
        testContact=new Contact();       
        testContact.LastName='testContact';       
        testContact.Account = testAccount;     
        testContact.phone = '9768541237';  
        testContact.email='d.mittal@accenture.com';       
        insert testContact;
        
        caseObj=new Case();      
        caseObj.Status='New';      
        caseObj.Origin='email';      
        caseObj.contactid=testContact.id;      
        caseObj.contact=testContact;   
        insert caseObj;    
    }

       
    public static testmethod void Audit_Score_Null(){
        caseObj.status='closed';
        caseObj.Resolution__c='Complete';
        caseObj.Component_Primary__c='DSL';
        caseObj.Component_Secondary__c = 'Availability - Dish / Direct TV / Satellite';
        caseobj.Component_Tertiary__c='Account Management';
        caseObj.Component_Quaternary__c='Disconnect / No Call Back';
        caseObj.Customer_Type__c='Consumer';
        caseObj.Root_Cause__c='Service performance';
        caseObj.Billing_Account_Number__c='abc';
        caseObj.Effort__c='High';
        caseObj.Reason='No Response';
        caseObj.Case_PostTag__c='dsl';
        update caseObj;
    }

      public static testmethod void Audit_Score_Positive(){
    
        Audit_Responses__c response = new Audit_Responses__c();
        response.case__c = caseObj.id;
        response.audit_question__c = 'Did the SMM note CRM/Clarify/JIRA?';
        response.audit_answer__c = 'Yes';
        response.audit_score__c = 25;
        insert response;
        
        Audit_Responses__c response2 = new Audit_Responses__c();
        response2.case__c = caseObj.id;
        response2.audit_question__c = 'Did the SMM note CRM/Clarify/JIRA?';
        response2.audit_answer__c = 'No';
        response2.audit_score__c = 0;
        insert response2;
        
        Audit_Responses__c response1 = new Audit_Responses__c();
        response1.case__c = caseObj.id;
        response1.audit_question__c = 'Was the appropriate resolution given or did the SMM confirm resolution with customer?';
        response1.audit_answer__c = 'Yes';
        response1.audit_score__c = 25;
        
        insert response1;
        
        update caseObj;
        
        system.debug('auditscore'+caseObj.Total_audit_score__c);
    }
  */  
}