@isTest(seeAllData=false)
public class Social_customerAcntDetailsControllerTest{
  static Contact testContact;
 static
 {
    testContact=new Contact();
    testContact.LastName='testContact';
    testContact.email='d.mittal@accenture.com';
    insert testContact; 
    
         List<User> userList = new List<User>();        
                    
         Profile p1 = [Select id from profile where name = 'Care Manager'];
         user u1 = new User(alias = 's121', email='standarduser121@testorg.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  username='standarduser121@accenture.com');
         userList.add(u1);
         insert userList;
    
         Case testCaseObj = new Case();
         testCaseObj.Status = 'New';
         testCaseObj.ownerId = u1.Id;
         testCaseObj.contactid = testContact.id;
         testCaseObj.contact = testContact;
         insert testCaseObj;
    
 }
    static testMethod void Social_customerAccountDetailsControllerTest1() {
          test.starttest();
         
          apexpages.currentpage().getparameters().put('insertrecord',string.valueof(TRUE));
          Customer_Account_Details__c custDetails = new Customer_Account_Details__c();
          custDetails.Account_Type__c='U-Verse(BAN)';
          custDetails.Account_Number__c='232435675123123';
          custDetails.Email_Id__c=NULL;
          custDetails.Phone__c=NULL;
          custDetails.Is_Active__c=TRUE ;
          custDetails.Contact_Id__c=testContact.id;

          insert custDetails;
          
          ApexPages.StandardController StdCtrl = new ApexPages.StandardController(custDetails);
          Social_customerAccountDetailsController customerAccountCon = new Social_customerAccountDetailsController(StdCtrl);
            
          customerAccountCon.contactFirstName='ghh';
          customerAccountCon.contactLastName='bgm';
          customerAccountCon.data='232435675123123';
          customerAccountCon.save();
          customerAccountCon.contactDetail();
       
        }        
    static testMethod void Social_customerAccountDetailsControllerTest2() {
          test.starttest();
         
          apexpages.currentpage().getparameters().put('insertrecord',string.valueof(TRUE));
          Customer_Account_Details__c custDetails1 = new Customer_Account_Details__c();
          custDetails1.Account_Type__c='Email';
          custDetails1.Is_Active__c=TRUE ;
          custDetails1.Contact_Id__c=testContact.id;
          custDetails1.Email_Id__c='dfg@ghat.com';
          insert custDetails1;
          
         
          ApexPages.StandardController StdCtrl = new ApexPages.StandardController(custDetails1);
          Social_customerAccountDetailsController customerAccountCon1 = new Social_customerAccountDetailsController(StdCtrl);
            
          customerAccountCon1.contactFirstName='ghh';
          customerAccountCon1.contactLastName='bgm';
          customerAccountCon1.data='fdg@gjj.com';
          customerAccountCon1.save();
          customerAccountCon1.contactDetail();
       
        }        
     static testMethod void Social_customerAccountDetailsControllerTest3() {
          test.starttest();
         
          Customer_Account_Details__c custDetails2 = new Customer_Account_Details__c();
          custDetails2.Account_Type__c='Home Phone';
          custDetails2.Is_Active__c=TRUE ;
          custDetails2.Contact_Id__c=testContact.id;
          custDetails2.Account_Number__c= NULL;
          custDetails2.Email_Id__c=NULL;   
          custDetails2.Phone__c='890789yh54';
          insert custDetails2;
          
         
          ApexPages.StandardController StdCtr2 = new ApexPages.StandardController(custDetails2);
          Social_customerAccountDetailsController customerAccountCon2 = new Social_customerAccountDetailsController(StdCtr2);
            
          customerAccountCon2.contactFirstName='ghh';
          customerAccountCon2.contactLastName='bgm';
          customerAccountCon2.data='fdg@gjj.com';
          customerAccountCon2.save();
          customerAccountCon2.contactDetail();
       
        }         
    static testMethod void Social_customerAccountDetailsControllerTest4() {
          test.starttest();
         
          Customer_Account_Details__c custDetails3 = new Customer_Account_Details__c();
          custDetails3.Account_Type__c='Email';
          custDetails3.Is_Active__c=TRUE;
          custDetails3.Contact_Id__c=testContact.id;
          custDetails3.Email_Id__c='gdj@123.com';
          custDetails3.Account_Number__c=NULL; 
          custDetails3.Phone__c=NULL;  
          insert custDetails3;
          
          ApexPages.StandardController StdCtr3 = new ApexPages.StandardController(custDetails3);
          Social_customerAccountDetailsController customerAccountCon3 = new Social_customerAccountDetailsController(StdCtr3);
            
          customerAccountCon3.contactFirstName='ghh';
          customerAccountCon3.contactLastName='bgm';
          customerAccountCon3.data='fdg@123.com';
          customerAccountCon3.save();
          customerAccountCon3.contactDetail();
       
        }      
    static testMethod void Social_customerAccountDetailsControllerTest5() {
          test.starttest();
        
          apexpages.currentpage().getparameters().put('isNew',string.valueof(TRUE));

          Customer_Account_Details__c custDetails4 = new Customer_Account_Details__c();
          custDetails4.Account_Type__c='DirectTV';
          custDetails4.Is_Active__c=FALSE ;
          custDetails4.Phone__c='67587890';
          custDetails4.Contact_Id__c=testContact.id;
          custDetails4.Email_Id__c='gdj@123.com';   
          custDetails4.Account_Number__c='232435zc5123123';
          insert custDetails4;
          
          ApexPages.StandardController StdCtr4 = new ApexPages.StandardController(custDetails4);
          Social_customerAccountDetailsController customerAccountCon4 = new Social_customerAccountDetailsController(StdCtr4);
            
          customerAccountCon4.contactFirstName='ghh';
          customerAccountCon4.contactLastName='bgm';
          customerAccountCon4.data='fdg@gjj.com';
          customerAccountCon4.save();
          customerAccountCon4.contactDetail();
       
        } 
     static testMethod void Social_customerAccountDetailsControllerTest6() {
          test.starttest();
        
          apexpages.currentpage().getparameters().put('insertrecord',string.valueof(TRUE));

          Customer_Account_Details__c custDetails5 = new Customer_Account_Details__c();
          custDetails5.Account_Type__c='Home Phone';
          custDetails5.Is_Active__c=TRUE ;
          custDetails5.Phone__c='6758789098';
          custDetails5.Contact_Id__c=testContact.id;
          custDetails5.Email_Id__c=NULL;   
          custDetails5.Account_Number__c=NULL;
          insert custDetails5;
          
          ApexPages.StandardController StdCtr5 = new ApexPages.StandardController(custDetails5);
          Social_customerAccountDetailsController customerAccountCon5 = new Social_customerAccountDetailsController(StdCtr5);
            
          customerAccountCon5.contactFirstName='fzdgz';
          customerAccountCon5.contactLastName='zfg';
          customerAccountCon5.data='6758789098';
          customerAccountCon5.save();
          customerAccountCon5.contactDetail();
       
   } 
    static testMethod void Social_customerAccountDetailsControllerTest7() {
          test.starttest();
        
          apexpages.currentpage().getparameters().put('newRecord',string.valueof(TRUE));  
          apexpages.currentpage().getparameters().put('insertrecord',string.valueof(TRUE));

          Customer_Account_Details__c custDetails6 = new Customer_Account_Details__c();
          custDetails6.Account_Type__c=NULL;
          custDetails6.Is_Active__c=FALSE ;
          custDetails6.Phone__c=NULL;
          custDetails6.Contact_Id__c=testContact.id;
          custDetails6.Email_Id__c=NULL;   
          custDetails6.Account_Number__c=NULL;
          insert custDetails6;
          
          ApexPages.StandardController StdCtr6 = new ApexPages.StandardController(custDetails6);
          Social_customerAccountDetailsController customerAccountCon6 = new Social_customerAccountDetailsController(StdCtr6);
            
          customerAccountCon6.contactFirstName='fgxg';
          customerAccountCon6.contactLastName='regszd';
          customerAccountCon6.data='';
          customerAccountCon6.save();
          customerAccountCon6.contactDetail();
    } 
     static testMethod void Social_customerAccountDetailsControllerTest8() {
          test.starttest();
        
          Customer_Account_Details__c custDetails7 = new Customer_Account_Details__c();
          custDetails7.Account_Type__c='U-Verse(BAN)';
          custDetails7.Is_Active__c=TRUE ;
          custDetails7.Phone__c=NULL;
          custDetails7.Contact_Id__c=testContact.id;
          custDetails7.Email_Id__c=NULL;   
          custDetails7.Account_Number__c='23343c1fg2233';
          insert custDetails7;
          
          ApexPages.StandardController StdCtr7 = new ApexPages.StandardController(custDetails7);
          Social_customerAccountDetailsController customerAccountCon7 = new Social_customerAccountDetailsController(StdCtr7);
            
          customerAccountCon7.contactFirstName='dfzbn';
          customerAccountCon7.contactLastName='hhzxf';
          customerAccountCon7.data='';
          customerAccountCon7.save();
          customerAccountCon7.contactDetail();
       
    } 
    static testMethod void Social_customerAccountDetailsControllerTest9() {
          test.starttest();
        
          apexpages.currentpage().getparameters().put('insertrecord',string.valueof(TRUE));
          
          Customer_Account_Details__c custDetails8 = new Customer_Account_Details__c();
          custDetails8.Account_Type__c='Forums Handle';
          custDetails8.Is_Active__c=TRUE ;
          custDetails8.Phone__c='34267@mj';
          custDetails8.Contact_Id__c=testContact.id;
          insert custDetails8;
          
          ApexPages.StandardController StdCtr8 = new ApexPages.StandardController(custDetails8);
          Social_customerAccountDetailsController customerAccountCon8 = new Social_customerAccountDetailsController(StdCtr8);
            
          customerAccountCon8.contactFirstName='dfzbn';
          customerAccountCon8.contactLastName='hhzxf';
          customerAccountCon8.data='34267@mj';
          customerAccountCon8.save();
          customerAccountCon8.contactDetail();
       
    } 
  }