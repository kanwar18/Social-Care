/**************************************************************************
TestClass Name: SocialCareForsee_Test
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: Test class for SocialMediaRoundRobin.
Version History: Aditya(14/March/2014) - Increased test covergae.
**************************************************************************************************************************/
@isTest
public class SocialCareForsee_Test {
    static Account testAccount;
    static Contact testContact;
    static {
        testAccount=new Account();
        testAccount.Name='testAccount1';
        insert testAccount;
        
        testContact=new Contact();
        testContact.LastName='testContact';
        testContact.Account = testAccount;
        testContact.email='d.mittal@accenture.com';
        insert testContact; 
    }

    public static TestMethod void testnotclosedcases() {  
        Case caseObj=new Case();
        caseObj.Status='New';
        caseObj.Origin='email';
        caseObj.contactid=testContact.id;
        caseObj.contact=testContact;
        caseObj.Social_Care_Handle_Name__c='@testhandle2 bnm';
    
        insert caseObj;
            
        caseObj.status='Escalated';
        update caseObj;
    }
    


    public static TestMethod void testforeseehandlerwithoutcontactemail() {
        /* Test block to test the scenario when URL sent to Twitter and Email is false*/
       
        Social_Media_Account__c media = new Social_Media_Account__c();
        media.Consumer_Key__c='QPJXxYRWrT4SAZEkdOVWANBHGG';
        media.Consumer_Secret__c='rrEFTp8Hp02wCkYrYhTTaWWgXtzGsdgdsmhFBsxyjUThmsL0';
        media.Access_Secret__c='MznvfYYKz2wLAP2yFzNkW6XuVegSVzN8dsgdsNvBx9Sz4Y';
        media.Access_Token__c='914061876-aJz4vKxcCG6sQbxJjc2WRSvTH9XuQKZ9SdduSM6vgdsgs';
        media.Social_Media_Handle_Name__c='testhandle2';
        media.Queue_Assigned_Date__c = DateTime.now();
        insert media;
    
        Contact testContact1=new Contact();
        testContact1.LastName='testContact';
        testContact1.Account = testAccount;
        testContact1.email='';
        insert testContact1;
            
        Case caseObj=new Case();
        caseObj.Status='New';
        caseObj.Origin='email';
        caseObj.contactid=testContact1.id;
        caseObj.contact=testContact1;
        caseObj.Social_Care_Handle_Name__c='@testhandle2 bnm';
        caseObj.Effort__c='Simple';
        caseObj.Root_Cause__c='Service Plan';
        caseObj.Reason='Completed';
        caseObj.Component_Primary__c='Landline';
        caseObj.Customer_Type__c='Enterprise';
        caseObj.Method_of_Contact__c='NA';
        caseObj.R6Service__MediaProvider__c = 'Twitter';
    
        insert caseObj;
            
        caseObj.status='Closed';
        caseObj.Clarify_CRM_Verified__c = 'No';
        update caseObj; // trigger will be called on updation of case record
        
        Forsee_Survey__c forseeSurObj =new Forsee_Survey__c();    
        forseeSurObj.Case_Number__c = caseObj.CaseNumber;    
        forseeSurObj.URL_Active__c = True;    
        forseeSurObj.Contact__c=testContact1.id;   
        forseeSurObj.Case__c=caseObj.id;    
        forseeSurObj.One_Time_Used__c=False;    
        forseeSurObj.Survey_Expired__c=False;   
        insert forseeSurObj;
    }

    public static TestMethod void testForeseehandlerwithcontactemail() {
        /* Test block to test the scenario when URL has been sent through Email */
     
        Social_Media_Account__c media = new Social_Media_Account__c();
        media.Consumer_Key__c='QPJXxYRWrT4SAZEkdOVWANBHGG';
        media.Consumer_Secret__c='rrEFTp8Hp02wCkYrYhTTaWWgXtzGsdgdsmhFBsxyjUThmsL0';
        media.Access_Secret__c='MznvfYYKz2wLAP2yFzNkW6XuVegSVzN8dsgdsNvBx9Sz4Y';
        media.Access_Token__c='914061876-aJz4vKxcCG6sQbxJjc2WRSvTH9XuQKZ9SdduSM6vgdsgs';
        media.Social_Media_Handle_Name__c='testhandle1';
        media.Queue_Assigned_Date__c = DateTime.now();
        insert media;
       
        Case caseObj1=new Case();
        caseObj1.Status='New';
        caseObj1.Origin='email';
        caseObj1.contactid=testContact.id;
        caseObj1.contact=testContact;
        caseObj1.Social_Care_Handle_Name__c='@testhandle1 Hello';
        caseObj1.Social_Persona_Name__c = 'mvijaysfdc';
        caseObj1.Effort__c='Simple';
        caseObj1.Root_Cause__c='Service Plan';
        caseObj1.Reason='Completed';
        caseObj1.Component_Primary__c='Landline';
        caseObj1.Customer_Type__c='Enterprise';
        caseObj1.Method_of_Contact__c='NA';
        caseObj1.Component_Secondary__c = null;
        
        insert caseObj1;
        caseObj1.Clarify_CRM_Verified__c = 'No';     
        caseObj1.status='Closed';
        update caseObj1; // trigger will be called on updation of case record
        
        
        Forsee_Survey__c forseeSurObj =new Forsee_Survey__c();    
        forseeSurObj.Case_Number__c = caseObj1.CaseNumber;    
        forseeSurObj.URL_Active__c = True;    
        forseeSurObj.Contact__c=testContact.id;   
        forseeSurObj.Case__c=caseObj1.id;    
        forseeSurObj.One_Time_Used__c=False;    
        forseeSurObj.Survey_Expired__c=False;   
        //forseeSurObj.createddate = DateTime.now()-100;
        insert forseeSurObj;
   }  


    public static TestMethod void testForeseehandlerwithcontactemail11() {
        /* Test block to test the scenario when URL has been sent through Email 
     
        Social_Media_Account__c media = new Social_Media_Account__c();
        media.Consumer_Key__c='QPJXxYRWrT4SAZEkdOVWA';
        media.Consumer_Secret__c='rrEFTp8Hp02wCkYrYhTTaWWgXtzGmhFBsxyjUThmsL0';
        media.Access_Secret__c='MznvfYYKz2wLAP2yFzNkW6XuVegSVzN8NvBx9Sz4Y';
        media.Access_Token__c='914061876-aJz4vKxcCG6sQbxJjc2WRSvTH9XuQKZ9SdduSM6v';
        media.Social_Media_Handle_Name__c='testhandle';
        insert media;
       
        Case caseObj1=new Case();
        caseObj1.Status='New';
        caseObj1.Origin='email';
        caseObj1.contactid=testContact.id;
        caseObj1.contact=testContact;
        caseObj1.Social_Care_Handle_Name__c='@testhandle';
        caseObj1.Social_Persona_Name__c = 'mvijaysfdc';
        caseObj1.Effort__c='Simple';
        caseObj1.Root_Cause__c='Service Plan';
        caseObj1.Reason='Completed';
        caseObj1.Component_Primary__c='Landline';
        caseObj1.Customer_Type__c='Enterprise';
        insert caseObj1;
        caseObj1.Clarify_CRM_Verified__c = 'No';    
        caseObj1.status='Closed';
        update caseObj1; // trigger will be called on updation of case record
        
        Forsee_Survey__c forseeSurObj =new Forsee_Survey__c();    
        forseeSurObj.Case_Number__c = caseObj1.CaseNumber;    
        forseeSurObj.URL_Active__c = True;    
        forseeSurObj.Contact__c=testContact.id;   
        forseeSurObj.Case__c=caseObj1.id;    
        forseeSurObj.One_Time_Used__c=False;    
        forseeSurObj.Survey_Expired__c=False;   
        //forseeSurObj.CreatedDate = DateTime.now()-100;    
        insert forseeSurObj;*/
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        SocialMediaTwitterRest mediaTwitter  = new SocialMediaTwitterRest();     
        mediaTwitter.invokeTwitterRequest();
        mediaTwitter.oauthWrap.setOauthTokens(null,null,null,null,null,null);
        System.assertNotEquals(mediaTwitter.oauthWrap.toStringWrapper().size(),0);
        Test.stopTest();
    }  
}