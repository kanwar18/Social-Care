@istest(seeAllData=True)
public class Social_AuditClass_Test{
      
 //Test Method for Social_AuditEditController
      public static TestMethod void Social_AuditEditControllerTestMethod()
      {
        Account testAccount=new Account();     
        testAccount.Name='testAccount1';     
        insert testAccount;    
                 
        Contact testContact=new Contact();     
        testContact.LastName='testContact';     
        testContact.Account = testAccount;     
        testContact.email='d.mittal@accenture.com';     
        insert testContact;
       
        Case caseObji=new Case();    
        caseObji.Status='New';    
        caseObji.Origin='email';    
        caseObji.ContactId=testContact.Id;    
        caseObji.contact=testContact;  
        caseObji.status = 'Closed';
        caseObji.Audit_Status__c ='Not QA';
        insert caseObji;
       
       Audit_Responses__c aR1= new Audit_Responses__c();
       aR1.Case__c=caseObji.Id;
       aR1.Audit_Answer__c= 'Yes';
       aR1.Audit_Coaching__c= 'Test';
       aR1.Audit_Question__c = 'Sample Question';
       insert aR1;
       System.debug('**************Case ID'+caseObji.Id);
       
      ApexPages.currentPage().getParameters().put('Id',aR1.Id);
      ApexPages.StandardController S1= new ApexPages.StandardController(aR1);
       Social_AuditEditController A1= new Social_AuditEditController(S1);
       A1.cancel();
       A1.save();
     }

 //Test Method for Social_AuditDetailController
  public static TestMethod void Social_AuditDetailControllerTestMethod(){
  
  Profile p1 = [select id, name from profile where name='Operations Manager'];
      User u2 = new User(alias = 's111', email='standarduser111@testorg.com', 

emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', 

profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  

username='standarduser111@accenture.com');
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
      // aR2.Case__r.Closed_Operation_Manager__c= u2.Id;
       aR2.Audit_Question__c = 'Sample Question';
       insert aR2;
     
     ApexPages.currentPage().getParameters().put('Id',aR2.Id);
      ApexPages.StandardController S1= new ApexPages.StandardController(aR2);
      Social_AuditDetailController A2= new Social_AuditDetailController(S1);
      A2.profileSettings();
}

 //Test Method for RecursionController
  public static TestMethod void RecursionControllerTestMethod(){
      boolean controller= true;      
    }

}