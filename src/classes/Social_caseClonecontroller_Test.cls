@istest(seeAllData=True)
public class Social_caseClonecontroller_Test{
   public static TestMethod void Social_caseClonecontrollerTestMethod(){
        Account testAccount1=new Account();     
        testAccount1.Name='testAccount1';     
        insert testAccount1;    
                 
        Contact testContact1=new Contact();     
        testContact1.LastName='testContact';     
        testContact1.Account = testAccount1;     
        testContact1.email='d.mittal@accenture.com';     
        insert testContact1;
       
        Case caseObji=new Case();    
        caseObji.Status='New';    
        caseObji.Origin='email';    
        caseObji.ContactId=testContact1.Id;    
        caseObji.contact=testContact1;  
        caseObji.status = 'Closed';
        caseObji.Audit_Status__c ='Not QA';
        insert caseObji;

        ApexPages.currentPage().getParameters().put('Id',caseObji.Id);
        ApexPages.StandardController S1= new ApexPages.StandardController(caseObji);
        Social_caseClonecontroller C1= new Social_caseClonecontroller(S1);
        C1.cloneCaseRecord();
}
}