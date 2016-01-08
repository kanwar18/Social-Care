@isTest
public class EmailToCaseExtnTest {

    public static Map<String,List<EmailMessage>> emailMessageMap {get;set;}
       
  public static TestMethod void testdoAction(){
   
   Test.startTest();
   EmailToCaseExtn batchObj = new EmailToCaseExtn();
    emailMessageMap = new Map<String,List<EmailMessage>> ();
      EmailMessage email = new EmailMessage(); 
    
 List<EmailMessage> emailList = new List<EmailMessage>();
              
 Profile p1 = [select id, name from profile where name='System Administrator'];
        User u2 = new User(alias = 'st102', email='standarduser102@testorg.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  username='standarduser102@accenture.com');
          insert u2;
        
Contact con = new Contact();
 con.FirstName = 'General-bc';
 con.LastName = 'Test';
 insert con;    
 
   Case csc= new case();
   
        Case testCaseObj = new Case();
        testCaseObj.Status = 'New';
        testCaseObj.Origin='email';     
        testCaseObj.priority = 'Low';
        testCaseObj.OwnerId = UserInfo.getUserid();
        insert testCaseObj;
     
  EmailMessage theEmail = new EmailMessage();
     theEmail.ParentId = testCaseObj.Id;
     theEmail.Incoming = true;
     theEmail.Subject = 'abcd';
     theEmail.MessageDate = datetime.now();
     theEmail.HtmlBody = 'abcd';  
     theEmail.TextBody = 'abcd';
     theEmail.FromName = 'abcd';
     theEmail.FromAddress = 'abcd1@att.com';
     theEmail.ToAddress ='xyz@gmail.com';
     
     insert theemail;  
     
       EmailMessage theEmail5 = new EmailMessage();
     theEmail5.ParentId = testCaseObj.Id;
     theEmail5.Incoming = true;
     theEmail5.Subject = 'abcd';
     theEmail5.MessageDate = datetime.now();
     theEmail5.HtmlBody = 'abcd';  
     theEmail5.TextBody = 'abcd';
     theEmail5.FromName = 'abcd';
     theEmail5.FromAddress = 'abcd1@att.com';
     theEmail5.ToAddress ='xyz@gmail.com';
     
     insert theEmail5;  
 

//emailMessageMap.put(testCaseObj.Id,emailList);
        
   batchObj.doAction();
   batchObj.save();
    Test.stopTest();
  
  }      
      }