@istest(seealldata=false)
public class Social_EmailmsgRelatedlistControllertest
{
 
 static testmethod void Social_EmailmsgRelatedlistControllertest()
 {
   List<EmailMessage> newList = new List<EmailMessage>();
   Case csc= new case();
   
        Case testCaseObj = new Case();
        testCaseObj.Status = 'New';
        testCaseObj.Origin='email';     
        testCaseObj.priority = 'Low';
        testCaseObj.OwnerId = UserInfo.getUserid();
        insert testCaseObj;
        
        ApexPages.StandardController StdCtrl = new ApexPages.StandardController(testCaseObj);
        Social_EmailmessageRelatedlistController socemgrelistcon=new Social_EmailmessageRelatedlistController(StdCtrl);
  //socemgrelistcon.previous();
        
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
     newList.add(theEmail);
     //insert theemail;  
     
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
     newList.add(theEmail5);
     //insert theEmail5;  
     
     EmailMessage theEmail1 = new EmailMessage();
     theEmail1.ParentId = testCaseObj.Id;
     theEmail1.Incoming = true;
     theEmail1.Subject = 'abcd';
     theEmail1.MessageDate = datetime.now();
     theEmail1.HtmlBody = 'abcd';  
     theEmail1.TextBody = 'abcd';
     theEmail1.FromName = 'abcd';
     theEmail1.FromAddress = 'abcd1@att.com';
     theEmail1.ToAddress ='xyz@gmail.com';
     newList.add(theEmail1);
     //insert theEmail1;  
     
     EmailMessage theEmail2 = new EmailMessage();
     theEmail2.ParentId = testCaseObj.Id;
     theEmail2.Incoming = true;
     theEmail2.Subject = 'abcd';
     theEmail2.MessageDate = datetime.now();
     theEmail2.HtmlBody = 'abcd';  
     theEmail2.TextBody = 'abcd';
     theEmail2.FromName = 'abcd';
     theEmail2.FromAddress = 'abcd1@att.com';
     theEmail2.ToAddress ='xyz@gmail.com';
     newList.add(theEmail2);
     //insert theEmail2;  
     
     EmailMessage theEmail3 = new EmailMessage();
     theEmail3.ParentId = testCaseObj.Id;
     theEmail3.Incoming = true;
     theEmail3.Subject = 'abcd';
     theEmail3.MessageDate = datetime.now();
     theEmail3.HtmlBody = 'abcd';  
     theEmail3.TextBody = 'abcd';
     theEmail3.FromName = 'abcd';
     theEmail3.FromAddress = 'abcd1@att.com';
     theEmail3.ToAddress ='xyz@gmail.com';
     newList.add(theEmail3);
     //insert theEmail3;  
     
     EmailMessage theEmail4 = new EmailMessage();
     theEmail4.ParentId = testCaseObj.Id;
     theEmail4.Incoming = true;
     theEmail4.Subject = 'abcd';
     theEmail4.MessageDate = datetime.now();
     theEmail4.HtmlBody = 'abcd';  
     theEmail4.TextBody = 'abcd';
     theEmail4.FromName = 'abcd';
     theEmail4.FromAddress = 'abcd1@att.com';
     theEmail4.ToAddress ='xyz@gmail.com';
     newList.add(theEmail4);
     insert newList;    

  
      socemgrelistcon.getInitialemailSet();
      socemgrelistcon.next();
      socemgrelistcon.previous();

 } 
}