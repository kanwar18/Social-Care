@isTest(seeAllData=FALSE)
    public class Social_AuditReportControllerTest{ 
    public static TestMethod void Social_AuditResponsesControllerTestMethod(){
  
        Profile p1 = [select id, name from profile where name='Operations Manager'];
      User u2 = new User(alias = 's112', email='standarduser112@testorg.com', 

emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', 

profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  

username='standarduser112@accenture.com');
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
        caseObji1.Closed_Operation_Manager__c=u2.Id;
        insert caseObji1;
        
       Social_AuditReportController C1= new Social_AuditReportController();
       C1.ViewData();
       C1.allCompletedAuditCases();
       C1.AllClosedCases_CM();
       C1.AllAuditCases_OP();
       C1.AllCompletedAuditCases_OP();
       C1.getSortDirection();
       C1.setSortDirection('ASC');
       C1.getCases();
       C1.getAllAuditedCases();
       C1.getAllClosedCases_CM();
       C1.getAllAuditCases_OP();
       C1.getAllCompletedAuditCases_OP();
       C1.profileSettings();
   }    
  }