@isTest(seeAllData = false)
public class Social_AuditUpdate_Test{
        
    static Account testAccount;
    static Contact testContact;
    static case caseObj;
    static Audit_Question__c quest1;
    static Audit_Responses__c response;
    
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
        
        //List<Audit_Question__c> questions = new List<Audit_Question__c>();
        
        quest1 = new Audit_Question__c();
        quest1.Name = 'Question1'; 
        quest1.Question__c = 'Did the SMM VID the account?';
        quest1.Coaching__c='Test';
        quest1.Answer__c = 'Yes';
        quest1.Score__c = 0;
        quest1.Component__c='Outreach';
        quest1.Auto_Fail__c = 'Yes';
        //questions.add(quest1);
        insert quest1;
        
        response = new Audit_Responses__c();
        response.audit_question__c = quest1.Question__c;
        response.audit_answer__c = quest1.Answer__c;
        response.audit_score__c = quest1.Score__c;
        response.Case__c = caseObj.Id;
        insert response;
    }
    
    public static testmethod void AuditUpdate1(){
        test.startTest();
        RecursionController.controller=true;
        
        response.audit_question__c = quest1.Question__c;
        response.audit_answer__c = quest1.Answer__c;
        response.audit_score__c = quest1.Score__c;
        update response;
          
        caseObj.Possible_Score__c = 0;
        caseObj.Audit_Score__c = 0;
        update caseObj;
        RecursionController.controller = false;
        test.stopTest();
    }
   
    public static testmethod void AuditUpdate2(){
        test.startTest();
        RecursionController.controller=true;
        
        response.audit_question__c = quest1.Question__c;
        response.audit_answer__c = 'No';
        response.audit_score__c = quest1.Score__c;
        update response;
          
        caseObj.Possible_Score__c = 0;
        caseObj.Audit_Score__c = 0;
        update caseObj;
        RecursionController.controller = false;
        test.stopTest();
    }
    
    public static testmethod void AuditUpdate3(){
        test.startTest();
        RecursionController.controller=true;
        
        response.audit_question__c = quest1.Question__c;
        response.audit_answer__c = 'NA';
        response.audit_score__c = quest1.Score__c;
        update response;
          
        caseObj.Possible_Score__c = 0;
        caseObj.Audit_Score__c = 0;
        update caseObj;
        RecursionController.controller = false;
        test.stopTest();
    }
    
}