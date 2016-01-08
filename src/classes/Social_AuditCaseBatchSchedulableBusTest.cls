@isTest(SeeAllData=true)
public class Social_AuditCaseBatchSchedulableBusTest{

    static Account testAccount;
    static Contact testContact;
    static Case caseObj;
    
    static User u;
    static User u1;
    static List<Case> caseList = new List<Case>();
    
    static{ 
        Profile p = [select id from profile where name='Operations Manager'];
        u = new User(alias = 'standt', email='standarduser@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', username='standarduser1@accenture.com');
        insert u;
        
        Profile p1 = [select id from profile where name='System Administrator'];
        u1 = new User(alias = 'standt1', email='standarduser1@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles',username='standarduser12@accenture.com');
        insert u1; 
                  
        testAccount=new Account();     
        testAccount.Name='testAccount1';     
        insert testAccount;    
                 
        testContact=new Contact();     
        testContact.LastName='testContact';     
        testContact.Account = testAccount;     
        testContact.email='d.mittal@accenture.com';     
        insert testContact;
       /*
        caseObj = new Case();      
        caseObj.Status='New';      
        caseObj.Origin='twitter'; 
        caseObj.Audit_Status__c='Not QA';     
        caseObj.contactid=testContact.id;      
        caseObj.contact=testContact;
        //caseObj.CreatedDate=System.Now() - 20;
        //caseObj.ClosedDate = System.Now() - 8;
        
        insert caseObj;

       caseObj.status='Closed';
        caseObj.Resolution__c='Complete';
        caseObj.Component_Primary__c='DSL';
        caseObj.Component_Secondary__c = 'Availability - Dish / Direct TV / Satellite';
        caseobj.Component_Tertiary__c='Account Management';
        caseObj.Component_Quaternary__c='Disconnect / No Call Back';
        caseObj.Customer_Type__c='Consumer';
        caseObj.Root_Cause__c='Service performance';
        caseObj.Billing_Account_Number__c='abc';
        caseObj.Effort__c='High';
        caseObj.Case_PostTag__c='dsl';
        caseObj.Reason='Resolved';
        caseObj.Audit_Status__c='Not QA';
        caseObj.Clarify_CRM_Verified__c = 'No';
        update caseObj;     
       */ 
       
       /* caseObj = [select caseNumber, ownerid, Audit_Status__c, ClosedDate, Closed_Operation_Manager__c From Case 
                    where Status='Closed' AND Audit_Status__c != 'Under QA' AND Audit_Status__c != 'QA Completed' AND Reason ='Resolved' AND  ClosedDate = LAST_WEEK Limit 1];
    */
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
        staticCase.contactid=testContact.id;      
        staticCase.contact=testContact;
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
        staticCase.Audit_Status__c='Not Audited';
        staticCase.Clarify_CRM_Verified__c = 'No';
        staticCase.Method_of_Contact__c = 'NA';

            staticCaseInsert.add(staticCase);
         }
        else{
         staticCase.Origin='twitter'; 
         staticCase.contactid=testContact.id;      
        staticCase.contact=testContact;
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
        staticCase.Audit_Status__c='Not Audited';
        staticCase.Clarify_CRM_Verified__c = 'No';
        staticCase.Method_of_Contact__c = 'NA';
        staticCaseUpdate.add(staticCase);
       }
        
        if(staticCaseInsert.size() > 0) {
          insert  staticCaseInsert;
        }
        if(staticCaseUpdate.size() > 0) {
          update staticCaseUpdate;
        }
    }
    
    
    
    
    public static testmethod void schedulerAuditcheckBus(){
        DateTime currTime = DateTime.now();
        Integer min = currTime.minute()+13 >= 60? ((currTime.minute()+13) - 60) : (currTime.minute()+13); 
        Integer hour = currTime.hour()+16 >= 24? ((currTime.hour()+16) - 24) : (currTime.hour()+16);
        String sch;
        
        if(min <= 58)
            sch = '0 '+ (min + 1) + ' ' + hour + ' * * ? '+ currTime.year();
        else          
        sch = '0 0 '+ (hour + 1) + ' * * ? '+ currTime.year();
        
        Test.startTest();
    
        Social_AuditCaseBatchSchedulableBus  obj = new Social_AuditCaseBatchSchedulableBus();                
        String jobId = system.schedule('test', sch, obj);        
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger where id = :jobId];        
        System.assertEquals(sch, ct.CronExpression);                                      
           
        Test.stopTest();
    }
}