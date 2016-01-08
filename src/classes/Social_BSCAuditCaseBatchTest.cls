@isTest(seeAllData=True)
public class Social_BSCAuditCaseBatchTest
{
    public static TestMethod void Social_BusinessAuditCaseBatchSchedulableReviewedTestMethod()
        { 
        
           String strCronExp = '0 0 20 * * ? 2022';
           Test.startTest();
           
           /////
           
        List<Case> staticCaseInsert =  new List<Case>();
        List<Case> staticCaseUpdate =  new List<Case>();
        List<sObject> ls = Test.loadData(Case.sObjectType, 'BusinessTestCaseData');
        Case staticCase = (Case)ls[0];
        Datetime caseCloseDate= staticCase.ClosedDate;
        Datetime caseCreatedDate= staticCase.createdDate;
        System.debug('BusCaseCloseDate-->'+caseCloseDate);
        System.debug('BusCasecreatedDate-->'+caseCreatedDate);
        
        if(staticCase.get('Id') == null){
        staticCase.Origin='twitter'; 
        //staticCase.contactid=testContact.id;      
        //staticCase.contact=testContact;
        staticCase.status='Closed';
        staticCase.Resolution__c='Complete';
        staticCase.Component_Primary__c='DSL';
        staticCase.Component_Secondary__c = 'Availability - Dish / Direct TV / Satellite';
        staticCase.Component_Tertiary__c='Account Management';
        staticCase.Component_Quaternary__c='Disconnect / No Call Back';
        staticCase.Customer_Type__c='Consumer';
        staticCase.Root_Cause__c='Service performance';
        staticCase.Billing_Account_Number__c='abc';
        staticCase.Effort__c='High';
        staticCase.Case_PostTag__c='dsl';
        staticCase.Reason='Resolved';
        staticCase.Audit_Status__c='Not QA';
        staticCase.Clarify_CRM_Verified__c = 'No';
        staticCaseInsert.add(staticCase);
        }
        else{
         staticCase.Origin='twitter'; 
         //staticCase.contactid=testContact.id;      
        //staticCase.contact=testContact;
        staticCase.status='Closed';
        staticCase.Resolution__c='Complete';
        staticCase.Component_Primary__c='DSL';
        staticCase.Component_Secondary__c = 'Availability - Dish / Direct TV / Satellite';
        staticCase.Component_Tertiary__c='Account Management';
        staticCase.Component_Quaternary__c='Disconnect / No Call Back';
        staticCase.Customer_Type__c='Consumer';
        staticCase.Root_Cause__c='Service performance';
        staticCase.Billing_Account_Number__c='abc';
        staticCase.Effort__c='High';
        staticCase.Case_PostTag__c='dsl';
        staticCase.Reason='Resolved';
        staticCase.Audit_Status__c='Not QA';
        staticCase.Clarify_CRM_Verified__c = 'No';
        staticCaseUpdate.add(staticCase);
       }
        
        if(staticCaseInsert.size() > 0) {
          insert  staticCaseInsert;
        }
        if(staticCaseUpdate.size() > 0) {
          update staticCaseUpdate;
        }
    
           
           
           
           ////
       
             Social_BusinessAuditCaseBatchSchedulable biz_auditld= new Social_BusinessAuditCaseBatchSchedulable();
             String jobId = system.schedule('Business test', strCronExp, biz_auditld);
             CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger where id = :jobId];        
             System.assertEquals(strCronExp, ct.CronExpression);
             
       Test.stopTest(); 
         
        }
}