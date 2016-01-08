/********************************************************************************************************
*    Author: Accenture/Social Care
*    Test Class for : ForeseeResponseTriggerHandler
*    Version: 1.0 - Aditya - Increased code coverage.
*    
********************************************************************************************************/
@isTest(seeAllData=false)
    public class ForeseeResponseTriggerHandlerTest{
    public static TestMethod void ForeseeResponseTriggerHandlerTestMethod(){  
        case caseObj;
        Profile p1 = [select id, name from profile where name='System Administrator'];
        User u2 = new User(alias = 's103', email='standarduser103@testorg.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  username='standarduser103@accenture.com');
          insert u2;
          ApexPages.currentPage().getParameters().put('id', u2.Id);
  
        Account testAccount1=new Account();     
        testAccount1.Name='testAccount1';     
        insert testAccount1;    
                 
        Contact testContact1=new Contact();     
        testContact1.LastName='testContact';     
        testContact1.Account = testAccount1;     
        testContact1.email='d.mittal@accenture.com';     
        insert testContact1;
       
        Case caseObji1=new Case();    
        caseObji1.Status='New';    
        caseObji1.Origin='email';    
        caseObji1.ContactId=testContact1.Id;    
        caseObji1.contact=testContact1;  
        caseObji1.status = 'Closed';
        caseObji1.Audit_Status__c ='Not QA';
        caseObji1.readunreadcheck__c = false;
        caseObji1.Closed_Operation_Manager__c=u2.Id;
        caseObji1.Component_Primary__c = 'Email';
        caseObji1.Component_Secondary__c = 'Non Customer';
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        insert caseObji1;
        
        if (caseObji1.Id != Null) {
            caseObj = [select caseNumber from case where id =:caseObji1.Id ];
        }
        
        Foresee_Survey_Respon__c fsc1= new Foresee_Survey_Respon__c();
        fsc1.Case__c= caseObji1.Id;
        if (caseObj.caseNumber != Null) {
            fsc1.AID__c= caseObj.caseNumber;
        }
        fsc1.ForeSee_Participant_Id__c= 'abc'; 
        fsc1.ForeSee_Visitor_ID__c= 'bcd';
        fsc1.Survey_Question_Column__c= 'jhagduyg';
        fsc1.Survey_Question_Full_Text__c= 'hvfiudy';
        fsc1.Survey_Question_Group__c= 'hgfduy';
        fsc1.Survey_Question_Label__c= 'iouyiuy';
        fsc1.Survey_Question_Subtype__c= 'rert';
        fsc1.Survey_Question_Type__c= 'asfhgs';
        
        /*
        fsc1.Survey_Response_Timestamp__c= 'fgkjlhdhg';
        fsc1.Survey_Result_Name__c= 'oiyuiut';
        fsc1.Survey_Result_Value__c= 'ewioutyey';
        DateTime dT = System.now();
        fsc1.Completion_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
        */
        
        insert fsc1;
        
        }
      }