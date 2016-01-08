@istest(seealldata=false)
private class TEST_Social_ResendSurveyCtrl {
    static Account testAccount;
    static Contact testContact;
    static testmethod void Social_ResendSurveyCtrl() {  
        test.starttest();
            testAccount=new Account();
            testAccount.Name='testAccount1';
            insert testAccount;
            
            testContact=new Contact();
            testContact.LastName='testContact';
            testContact.Account = testAccount;
            testContact.email='d.mittal@accenture.com';
            insert testContact;  
            
            Case testCaseObj = new Case();
            testCaseObj.Status = 'New';
            testCaseObj.Origin='email';     
            testCaseObj.priority = 'Low';
            testCaseObj.OwnerId = UserInfo.getUserid();
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            insert testCaseObj;
            testCaseObj.Customer_Type__c='Enterprise';
            testCaseObj.Effort__c='Simple';
            testCaseObj.Root_Cause__c='Service Plan';
            testCaseObj.Reason='Completed';   
            testCaseObj.status='Closed';
            testCaseObj.Clarify_CRM_Verified__c = 'No';
            testCaseObj.Method_of_Contact__c='NA';
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            update testCaseObj; 
            
            List <case> cnumber=  [select casenumber from case where id =:testCaseObj.id limit 1];
            Forsee_Survey__c forseeSurObj =new Forsee_Survey__c();    
            forseeSurObj.Case_Number__c = cnumber[0].CaseNumber;    
            forseeSurObj.URL_Active__c = True;    
            forseeSurObj.Contact__c=testContact.id;   
            forseeSurObj.Case__c=testCaseObj.id;    
            forseeSurObj.One_Time_Used__c=False;    
            forseeSurObj.Survey_Expired__c=False;
            forseeSurObj.Resent_Survey__c=true;
            insert forseeSurObj;
            
            Forsee_Survey__c forseesurvey= new Forsee_Survey__c();
            ApexPages.StandardController StdCtrl = new ApexPages.StandardController(forseeSurObj);
            Social_ResendSurveyCtrl socclasinst=new Social_ResendSurveyCtrl(StdCtrl);
            socclasinst.mforseesur.case_number__c =forseeSurObj.Case_Number__c;
            socclasinst.GenerateForseeURl();
            
            Forsee_Survey__c forseeSurObj1 =new Forsee_Survey__c();    
            forseeSurObj1.Case_Number__c = cnumber[0].CaseNumber;    
            forseeSurObj1.URL_Active__c = True;    
            forseeSurObj1.Contact__c=testContact.id;   
            forseeSurObj1.Case__c=testCaseObj.id;    
            forseeSurObj1.One_Time_Used__c=False;    
            forseeSurObj1.Survey_Expired__c=False;
            forseeSurObj1.Resent_Survey__c=true;
            insert forseeSurObj1;
            
            ApexPages.StandardController StdCtrl1 = new ApexPages.StandardController(forseeSurObj1);
            Social_ResendSurveyCtrl socclasinst1=new Social_ResendSurveyCtrl(StdCtrl1);
            socclasinst1.GenerateForseeURl();
        test.stoptest();
    }
    
    static testmethod void Social_ResendSurveyCtrl1() {  
        test.starttest();
            testAccount=new Account();
            testAccount.Name='testAccount1';
            insert testAccount;
            
            testContact=new Contact();
            testContact.LastName='testContact';
            testContact.Account = testAccount;
            testContact.email='d.mittal@accenture.com';
            insert testContact;  
            
            Case testCaseObj = new Case();
            testCaseObj.Status = 'New';
            testCaseObj.Origin='email';     
            testCaseObj.priority = 'Low';
            testCaseObj.OwnerId = UserInfo.getUserid();
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            insert testCaseObj;
            testCaseObj.Customer_Type__c='Enterprise';
            testCaseObj.Effort__c='Simple';
            testCaseObj.Root_Cause__c='Service Plan';
            testCaseObj.Reason='Completed';   
            testCaseObj.status='Closed';
            testCaseObj.Clarify_CRM_Verified__c = 'No';
            testCaseObj.Method_of_Contact__c='NA';
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            update testCaseObj; 
            
            List <case> cnumber=  [select casenumber from case where id =:testCaseObj.id limit 1];
            Forsee_Survey__c forseeSurObj =new Forsee_Survey__c();    
            forseeSurObj.Case_Number__c = cnumber[0].CaseNumber;    
            forseeSurObj.URL_Active__c = True;    
            forseeSurObj.Contact__c=testContact.id;   
            forseeSurObj.Case__c=testCaseObj.id;    
            forseeSurObj.One_Time_Used__c=False;    
            forseeSurObj.Survey_Expired__c=False;
            forseeSurObj.Resent_Survey__c=true;
            insert forseeSurObj;
            
            Forsee_Survey__c forseesurvey= new Forsee_Survey__c();
            ApexPages.StandardController StdCtrl = new ApexPages.StandardController(forseeSurObj);
            Social_ResendSurveyCtrl socclasinst=new Social_ResendSurveyCtrl(StdCtrl);
            socclasinst.mforseesur.case_number__c =forseeSurObj.Case_Number__c;
            socclasinst.GenerateForseeURl();
            
            Forsee_Survey__c forseeSurObj1 =new Forsee_Survey__c();    
            forseeSurObj1.Case_Number__c = cnumber[0].CaseNumber;    
            forseeSurObj1.URL_Active__c = True;    
            forseeSurObj1.Contact__c=testContact.id;   
            forseeSurObj1.Case__c=testCaseObj.id;    
            forseeSurObj1.One_Time_Used__c=False;    
            forseeSurObj1.Survey_Expired__c=False;
            forseeSurObj1.Resent_Survey__c=false;
            insert forseeSurObj1;
            
            ApexPages.StandardController StdCtrl1 = new ApexPages.StandardController(forseeSurObj1);
            Social_ResendSurveyCtrl socclasinst1=new Social_ResendSurveyCtrl(StdCtrl1);
            socclasinst1.GenerateForseeURl();
            socclasinst1.userId = userInfo.getUserId();
            socclasinst1.errormsg = 'error';
        test.stoptest();
    }
}