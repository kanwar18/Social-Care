@isTest

/* Test class to test the functionality of Socialcare controller */

public class SocialCareABSController_Test { 
      
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

    Case caseObj = new Case();
    caseObj.Status = 'New';
    caseObj.Origin = 'email';
    caseObj.contactid = testContact.id;
    caseObj.contact = testContact;
    insert caseObj;
        

    Forsee_Survey__c forseeSurObj = new Forsee_Survey__c();
    forseeSurObj.Case_Number__c = caseObj.CaseNumber;
    forseeSurObj.URL_Active__c = True;
    forseeSurObj.Contact__c = testContact.id;
    forseeSurObj.Case__c = caseObj.id;
    forseeSurObj.One_Time_Used__c = False;
    forseeSurObj.Survey_Expired__c = False;
    forseeSurObj.URL_Sent_date__c = Date.today();
    insert forseeSurObj;
         
        
    ApexPages.currentPage().getParameters().put('noc',forseeSurObj.id);
    SocialCareABSController scc = new SocialCareABSController();
        
    scc.doValidateUrl();
              
}

public static TestMethod void testSurveySentDate() 
{
/* Test method to test that URL sent to the customer is active and is not used/expired */

    Case caseObj1 = new Case();
    caseObj1.Status = 'New';
    caseObj1.Origin = 'email';
    caseObj1.contactid = testContact.id;
    caseObj1.contact = testContact;
    insert caseObj1;
        
    Datetime myDateTime = Datetime.newInstance(2015, 2, 17);
    
    Forsee_Survey__c forseeSurObj1 = new Forsee_Survey__c();
    forseeSurObj1.Case_Number__c = caseObj1.CaseNumber;
    forseeSurObj1.URL_Active__c = True;
    forseeSurObj1.Contact__c = testContact.id;
    forseeSurObj1.Case__c = caseObj1.id;
    forseeSurObj1.One_Time_Used__c = False;
    forseeSurObj1.Survey_Expired__c = False;
    forseeSurObj1.URL_Sent_date__c = myDateTime;
    insert forseeSurObj1;
         
        
    ApexPages.currentPage().getParameters().put('noc',forseeSurObj1.id);
    SocialCareABSController scc = new SocialCareABSController();
        
    scc.doValidateUrl();
              
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
        

    Forsee_Survey__c forseeSurObj2 = new Forsee_Survey__c();
    forseeSurObj2.Case_Number__c = caseObj2.CaseNumber;
    forseeSurObj2.URL_Active__c = False;
    forseeSurObj2.Contact__c = testContact.id;
    forseeSurObj2.Case__c = caseObj2.id;
    forseeSurObj2.resent_survey__c = true;
    forseeSurObj2.One_Time_Used__c = True;
    forseeSurObj2.Survey_Expired__c = false;
    forseeSurObj2.URL_Sent_date__c = d;
    insert forseeSurObj2;
         
        
    ApexPages.currentPage().getParameters().put('noc',forseeSurObj2.id);
    SocialCareABSController scc = new SocialCareABSController();
        
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
    forseeSurObj3.URL_Active__c = FALSE;
    forseeSurObj3.Contact__c = testContact.id;
    forseeSurObj3.Case__c = caseObj3.id;
    forseeSurObj3.One_Time_Used__c = TRUE;
    forseeSurObj3.Survey_Expired__c = TRUE;
    forseeSurObj3.URL_Sent_date__c = Date.today() - 18;
    insert forseeSurObj3;
    foreseeid = forseeSurObj3.id + 'abs';
                                
    ApexPages.currentPage().getParameters().put('noc',foreseeid);
    SocialCareABSController scc = new SocialCareABSController();
                    
    scc.doValidateUrl();
}

public static TestMethod void testexceptiopartMODIFIEDURL() 
{
/* Test method to test the conditions of MODIFIED URL 
when the foreseeid is modified in the link sent to customer */


    string foreseeid1;
    Case caseObj4 = new Case();
    caseObj4.Status = 'New';
    caseObj4.Origin = 'email';
    caseObj4.contactid = testContact.id;
    caseObj4.contact = testContact;
    insert caseObj4;
        

    Forsee_Survey__c forseeSurObj4 =new Forsee_Survey__c();
    forseeSurObj4.Case_Number__c = caseObj4.CaseNumber;
    forseeSurObj4.URL_Active__c = False;
    forseeSurObj4.Contact__c = testContact.id;
    forseeSurObj4.Case__c = caseObj4.id;
    forseeSurObj4.One_Time_Used__c = False;
    forseeSurObj4.Survey_Expired__c = True;
    insert forseeSurObj4;
    foreseeid1=forseeSurObj4.id;
    foreseeid1 = foreseeid1.replace('000','!!!');                                
         
    ApexPages.currentPage().getParameters().put('noc',foreseeid1);
    SocialCareABSController scc = new SocialCareABSController();
                    
    scc.doValidateUrl();
}
}