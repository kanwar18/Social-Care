@isTest

/* Test class to test the functionality of Socialcare controller */

public class SocialCareController_Test { 
      
static Account testAccount;
static Contact testContact;
static
{
      
    testAccount=new Account();
    testAccount.Name='testAccount1';
    insert testAccount;
        
    testContact=new Contact();
    testContact.LastName='testContact';
    testContact.Account = testAccount;
    testContact.email='d.mittal@accenture.com';
    insert testContact; 
}
      

public static TestMethod void testURLactiveTrue() 
{
/* Test method to test that URL sent to the customer is active and is not used/expired */

    Case caseObj=new Case();
    caseObj.Status='New';
    caseObj.Origin='email';
    caseObj.contactid=testContact.id;
    caseObj.contact=testContact;
    insert caseObj;
        

    Forsee_Survey__c forseeSurObj =new Forsee_Survey__c();
    forseeSurObj.Case_Number__c = caseObj.CaseNumber;
    forseeSurObj.URL_Active__c = True;
    forseeSurObj.Contact__c=testContact.id;
    forseeSurObj.Case__c=caseObj.id;
    forseeSurObj.One_Time_Used__c=False;
    forseeSurObj.Survey_Expired__c=False;
    forseeSurObj.URL_Sent_date__c = Date.today();
    insert forseeSurObj;
         
        
    ApexPages.currentPage().getParameters().put('noc',forseeSurObj.id);
    SocialCareController scc = new SocialCareController();
        
    scc.doValidateUrl();
              
}

public static TestMethod void testEnglishSurvey() 
{
/* Test method to test that customer has clicked on english survey link */

    Case caseObj=new Case();
    caseObj.Status='New';
    caseObj.Origin='email';
    caseObj.contactid=testContact.id;
    caseObj.contact=testContact;
    insert caseObj;
    list<case> caseList = [Select Id, status,origin,reason,contactId from case where Id =:caseObj.Id];
    case uptCase = new case();
    if(caseList != null && caseList.size()>0){
        uptCase = caseList[0];
        uptCase.reason = 'Auto Closed';
        uptCase.status = 'Auto Closed'; 
        update uptCase;
    }
        
    Forsee_Survey__c forseeSurObj =new Forsee_Survey__c();
    forseeSurObj.Case_Number__c = caseObj.CaseNumber;
    forseeSurObj.URL_Active__c = True;
    forseeSurObj.Contact__c=testContact.id;
    forseeSurObj.Case__c=uptCase != null ? uptCase.Id : null;
    forseeSurObj.One_Time_Used__c=False;
    forseeSurObj.Survey_Expired__c=False;
    forseeSurObj.URL_Sent_date__c = Date.today()+1;
    insert forseeSurObj;
     system.assertNotEquals(forseeSurObj.Id,Null); 
     Test.startTest(); 
     Test.setCurrentPage(Page.SocialMediaPage); 
    ApexPages.currentPage().getParameters().put('noc',forseeSurObj.id);
    SocialCareController scc = new SocialCareController();
     scc.doValidateUrl(); 
      
    scc.EnglishSurvey();
    forseeSurObj.URL_Active__c = False;
    update forseeSurObj;
    ApexPages.currentPage().getParameters().put('noc',forseeSurObj.id);
    SocialCareController scc1 = new SocialCareController();
    scc1.doValidateUrl();   
    scc1.EnglishSurvey();
    Test.stopTest();
              
}

public static TestMethod void testSpanishSurvey() 
{
/* Test method to test that customer has clicked on spanish survey link */

    Case caseObj=new Case();
    caseObj.Status='New';
    caseObj.Origin='email';
    caseObj.contactid=testContact.id;
    caseObj.contact=testContact;
    insert caseObj;
     list<case> caseList = [Select Id, status,origin,reason,contactId from case where Id =:caseObj.Id];
    case uptCase = new case();
    if(caseList != null && caseList.size()>0){
        uptCase = caseList[0];
        uptCase.reason = 'Auto Closed';
        uptCase.status = 'Auto Closed'; 
        update uptCase;
    }   

    Forsee_Survey__c forseeSurObj =new Forsee_Survey__c();
    forseeSurObj.Case_Number__c = caseObj.CaseNumber;
    forseeSurObj.URL_Active__c = True;
    forseeSurObj.Contact__c=testContact.id;
    forseeSurObj.Case__c=uptCase != null ? uptCase.Id : null;
    forseeSurObj.One_Time_Used__c=False;
    forseeSurObj.Survey_Expired__c=False;
    forseeSurObj.URL_Sent_date__c = Date.today()+1;
    insert forseeSurObj;
    system.assertNotEquals(forseeSurObj.Id,Null);  
    ApexPages.currentPage().getParameters().put('noc',forseeSurObj.id);
    SocialCareController scc = new SocialCareController();
    scc.doValidateUrl();   
    scc.SpanishSurvey();
    forseeSurObj.URL_Active__c = False;
    update forseeSurObj;
    ApexPages.currentPage().getParameters().put('noc',forseeSurObj.id);
    SocialCareController scc1 = new SocialCareController();
    scc1.doValidateUrl();   
    scc1.SpanishSurvey();

              
}
  
public static TestMethod void testURLactivefalse() 
{
/* Test method to test that URL sent to the customer has been used and is not expired */

       
    date d=date.today();
          
    Case caseObj2=new Case();
    caseObj2.Status='New';
    caseObj2.Origin='email';
    caseObj2.contactid=testContact.id;
    caseObj2.contact=testContact;
    insert caseObj2;
        

    Forsee_Survey__c forseeSurObj2 =new Forsee_Survey__c();
    forseeSurObj2.Case_Number__c = caseObj2.CaseNumber;
    forseeSurObj2.URL_Active__c = False;
    forseeSurObj2.Contact__c=testContact.id;
    forseeSurObj2.Case__c=caseObj2.id;
    forseeSurObj2.One_Time_Used__c=True;
    forseeSurObj2.Survey_Expired__c=False;
    forseeSurObj2.URL_Sent_date__c= d;
    insert forseeSurObj2;
         
        
    ApexPages.currentPage().getParameters().put('noc',forseeSurObj2.id);
    SocialCareController scc = new SocialCareController();
        
    scc.doValidateUrl();

}
public static TestMethod void testexceptionpartMODIFIEDURL()
{
/* Test method to test the conditions of MODIFIED URL 
when the foreseeid is modified in the link sent to customer */

    string foreseeid;
                 
    Case caseObj3=new Case();
    caseObj3.Status='New';
    caseObj3.Origin='email';
    caseObj3.contactid=testContact.id;
    caseObj3.contact=testContact;
    insert caseObj3;
        

    Forsee_Survey__c forseeSurObj3 =new Forsee_Survey__c();
    forseeSurObj3.Case_Number__c = caseObj3.CaseNumber;
    forseeSurObj3.URL_Active__c = False;
    forseeSurObj3.Contact__c=testContact.id;
    forseeSurObj3.Case__c=caseObj3.id;
    forseeSurObj3.One_Time_Used__c=False;
    forseeSurObj3.Survey_Expired__c=True;
    insert forseeSurObj3;
    foreseeid = forseeSurObj3.id + 'abs';
                                
    ApexPages.currentPage().getParameters().put('noc',foreseeid);
    SocialCareController scc = new SocialCareController();
                    
    scc.doValidateUrl();
}

public static TestMethod void testexceptiopartMODIFIEDURL() 
{
/* Test method to test the conditions of MODIFIED URL 
when the foreseeid is modified in the link sent to customer */


    string foreseeid1;
    Case caseObj4=new Case();
    caseObj4.Status='New';
    caseObj4.Origin='email';
    caseObj4.contactid=testContact.id;
    caseObj4.contact=testContact;
    insert caseObj4;
        

    Forsee_Survey__c forseeSurObj4 =new Forsee_Survey__c();
    forseeSurObj4.Case_Number__c = caseObj4.CaseNumber;
    forseeSurObj4.URL_Active__c = False;
    forseeSurObj4.Contact__c=testContact.id;
    forseeSurObj4.Case__c=caseObj4.id;
    forseeSurObj4.One_Time_Used__c=False;
    forseeSurObj4.Survey_Expired__c=True;
    insert forseeSurObj4;
    foreseeid1=forseeSurObj4.id;
    foreseeid1 = foreseeid1.replace('000','!!!');                                
         
    ApexPages.currentPage().getParameters().put('noc',foreseeid1);
    SocialCareController scc = new SocialCareController();
                    
    scc.doValidateUrl();
}
}