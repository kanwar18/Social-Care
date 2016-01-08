@isTest(seeAllData=True)
    public class Social_AuditResponsesControllerTest{ 
    public static TestMethod void Social_AuditResponsesControllerTestMethod(){
  
        Profile p1 = [select id, name from profile where name='Operations Manager'];
      User u2 = new User(alias = 's113', email='standarduser113@testorg.com', 

emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', 

profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  

username='standarduser113@accenture.com');
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
  
       Audit_Responses__c aR2= new Audit_Responses__c();
       aR2.Case__c= caseObji1.Id;
       aR2.Audit_Answer__c= 'Yes';
       aR2.Audit_Coaching__c= 'Test1';
       aR2.Audit_Question__c = 'Sample Question';
       insert aR2;
        
        ApexPages.currentPage().getParameters().put('Id',caseObji1.Id);
        ApexPages.StandardController c1= new ApexPages.StandardController(aR2);    
        Social_AuditResponsesController audit1 = new Social_AuditResponsesController(c1);
        Boolean hasPrevious= true;
        Boolean hasNext =true;
        audit1.getAuditResponses();
        audit1.previous();
        audit1.next();
        audit1.first();
        audit1.last();  
      }
}