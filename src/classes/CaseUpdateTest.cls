/**Class Name: CaseUpdateTest
 * Author: Accenture
 * Requirement/Project Name: Social Consumer
 * Requirement Description: Test class for CaseUpdate controller.
 * Version History: version 1 (Aditya 30/April/2014) : Increased code coverage.
 */
@isTest(seeAllData=false)
    public class CaseUpdateTest{
    public static TestMethod void CaseUpdateTestMethod(){ 
        List<User> userList = new List<User>(); 
        Profile p1 = [select id, name from profile where name='System Administrator'];
        User u2 = new User(alias = 's100', email='standarduser100@testorg.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  username='standarduser100@accenture.com');
        userList.add(u2);
          
        User u1 = new User(alias = 's101', email='standarduser101@testorg.com', emailencodingkey='UTF-8', lastname='Testing12', languagelocalekey='en_US', localesidkey='en_US', profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  username='standarduser101@accenture.com');
        userList.add(u1);
        
        insert userList;
        
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
        caseObji1.ReadUnreadCheck__c = true;
        caseObji1.Closed_Operation_Manager__c=u2.Id;
        caseObji1.ownerId = userInfo.getUserId();
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        
        insert caseObji1;
        
        ApexPages.StandardController cup2= new ApexPages.StandardController(caseObji1);  
        CaseUpdate cm = new  CaseUpdate(cup2);
        cm.CaseVisibility();
    }
}