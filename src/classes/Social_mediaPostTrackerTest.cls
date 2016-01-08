@isTest
public class Social_mediaPostTrackerTest
{

static Account testAccount;
static Contact testContact;
static case caseObj;
static Event testEvent;
static Event testEvent1;
static user u1;
static user u2;
static user u3;

static Id queueid;
static Assignment_Groups__c testmember;
static Assignment_Groups__c nextcaremanager1;
static Assignment_Group_Name__c testgroup;
static Assignment_Group_Queues__c testqueue;


static
{     
        
testAccount=new Account();     
testAccount.Name='testAccount1';     
insert testAccount;      
     
testContact=new Contact();     
testContact.LastName='testcontact';     
testContact.Account = testAccount;     
testContact.email='d.mittal@accenture.com';     
insert testContact;  
      
Profile p1 = [select id, name from profile where name='System Administrator'];
u1 = new User(alias = 'standt', email='standarduser@testorg.com',
emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
localesidkey='en_US', profileid = p1.Id, isactive=true,
timezonesidkey='America/Los_Angeles', Availability__c='Available', 
username='socialtest1@accenture.com');
insert u1;

Profile p2 = [select id, name from profile where name='Care Manager'];
u2 = new User(alias = 'standt1', email='standarduser@testorg.com',
emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
localesidkey='en_US', profileid = p1.Id, isactive=true,
timezonesidkey='America/Los_Angeles', Availability__c='Available', 
username='socialtest2@accenture.com');
insert u2;

u3 = new User(alias = 'standt1', email='standarduser@testorg.com',
emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
localesidkey='en_US', profileid = p1.Id, isactive=true,
timezonesidkey='America/Los_Angeles', Availability__c='Available', 
username='socialtest3@accenture.com');
insert u3;



caseObj=new Case();    
caseObj.Status='New';    
caseObj.Origin='email';    
caseObj.contactid=testContact.id;    
caseObj.contact=testContact;
caseObj.ownerid=u1.id; 
insert caseObj;      

testEvent = new Event();                
testEvent.Event_Status__c='Open';                
testEvent.Event_Type__c='SLA - 1';        
testEvent.DurationInMinutes=10;                
testEvent.ActivityDateTime=System.Today();   
testEvent.Whatid=caseObj.id;     
insert testEvent;

testEvent1 = new Event();                
testEvent1.Event_Status__c='Open';                
testEvent1.Event_Type__c='SLA - 1';        
testEvent1.DurationInMinutes=10;                
testEvent1.ActivityDateTime=System.Today(); 
testEvent1.Whatid=caseObj.id;        
insert testEvent1;

}

public static TestMethod void testsocialmediapost()
{
   
caseObj.Current_SLA_Phase__c = 'SLA1 - Initiated'; 
update caseObj;

R6Service__Post__c testpost = new R6Service__Post__c();
//testpost.R6Service__RealName__c='Tweet to '+testcontact.name;
testpost.R6Service__SM_Contact__c = testContact.id;
testpost.R6Service__SM_Case__c= caseObj.id;
insert testpost;

Social_slaEventHandler eventHandler = new Social_slaEventHandler();
eventHandler.getRelatedOperationManager(u1.id);
eventHandler.getRelatedOperationManagerEmail(u1.id);
  
}

public static TestMethod void testsocialmediapost22()
{

caseObj.Current_SLA_Phase__c = 'SLA1 - Ended';
update caseObj;

R6Service__Post__c testpost11 = new R6Service__Post__c();
testpost11.R6Service__SM_Contact__c = testContact.id;
testpost11.R6Service__SM_Case__c= caseObj.id;
insert testpost11;
System.debug('Hello:'+testpost11); 
}

public static TestMethod void Social_emailOnCaseHandlerTestMethod32()
  {
  //'SLA1 - Ended' phase
  id queueidd;
  System.runAs(u1)
{          
Group grp1=new Group(Name='Queue1',Type='Queue');
insert grp1;    

QueueSobject mappingObject1 = new QueueSobject();
mappingObject1.SobjectType = 'Case';
mappingObject1.QueueId=grp1.id;
insert mappingObject1;
       
Assignment_Group_Name__c assignmentGroup=new Assignment_Group_Name__c();
assignmentGroup.Name='Test';
assignmentGroup.Type__c='Case';
//assignmentGroup.Ownerid=u2.id;
insert assignmentGroup;
                 
//Adding Assignment Queues

Assignment_Group_Queues__c AssignmentGroupQueue=new Assignment_Group_Queues__c();
AssignmentGroupQueue.Valid_Queue__c=True;
AssignmentGroupQueue.Assignment_Group_Name__c=assignmentGroup.id;
AssignmentGroupQueue.Active__c='True';
AssignmentGroupQueue.Name='Queue1';
AssignmentGroupQueue.Queueid__c=grp1.id;

insert AssignmentGroupQueue;
System.Debug('Assignment Group Queue here'+AssignmentGroupQueue);
queueidd=AssignmentGroupQueue.Queueid__c;
Assignment_Groups__c relatedGroup=new Assignment_Groups__c();
relatedGroup.User__c=u1.id;
relatedGroup.Group_Name__c = assignmentGroup.id;
insert relatedGroup;  

Assignment_Groups__c relatedGroup1=new Assignment_Groups__c();
relatedGroup1.User__c=u2.id;
relatedGroup1.Group_Name__c = assignmentGroup.id;
insert relatedGroup1;  




}
      caseObj.First_SLA_Response_Time__c=system.today();
      caseObj.Current_SLA_Phase__c='SLA1 - Ended';
      caseObj.Contact.Email=testContact.email;
      caseObj.ContactId=testContact.Id;
      caseObj.ownerid=u1.id;
      caseObj.track_case_queue__c=queueidd;
      update caseObj;
      
         
   R6Service__Post__c testpost11 = new R6Service__Post__c();
testpost11.R6Service__SM_Contact__c = testContact.id;
testpost11.R6Service__SM_Case__c= caseObj.id;
insert testpost11;     
   }


public static TestMethod void Social_emailOnCaseHandlerTestMethod22()
  {
  //'SLA1 - Ended' phase
  id queueid1;
  System.runAs(u1)
{          
Group grp1=new Group(Name='Queue1',Type='Queue');
insert grp1;    

QueueSobject mappingObject1 = new QueueSobject();
mappingObject1.SobjectType = 'Case';
mappingObject1.QueueId=grp1.id;
insert mappingObject1;
       
Assignment_Group_Name__c assignmentGroup=new Assignment_Group_Name__c();
assignmentGroup.Name='Test';
assignmentGroup.Type__c='Case';
//assignmentGroup.Ownerid=u2.id;
insert assignmentGroup;
                 
//Adding Assignment Queues

Assignment_Group_Queues__c AssignmentGroupQueue=new Assignment_Group_Queues__c();
AssignmentGroupQueue.Valid_Queue__c=True;
AssignmentGroupQueue.Assignment_Group_Name__c=assignmentGroup.id;
AssignmentGroupQueue.Active__c='True';
AssignmentGroupQueue.Name='Queue1';
AssignmentGroupQueue.Queueid__c=grp1.id;

insert AssignmentGroupQueue;
System.Debug('Assignment Group Queue here'+AssignmentGroupQueue);
queueid1=AssignmentGroupQueue.Queueid__c;
system.debug('queueidsss'+queueid1);

Assignment_Groups__c relatedGroup=new Assignment_Groups__c();
relatedGroup.User__c=u2.id;
relatedGroup.last_assignment__c=system.today()-1;
relatedGroup.Group_Name__c = assignmentGroup.id;
insert relatedGroup;  

Assignment_Groups__c relatedGroup1=new Assignment_Groups__c();
relatedGroup1.User__c=u3.id;
relatedGroup1.last_assignment__c=system.today();

relatedGroup1.Group_Name__c = assignmentGroup.id;
insert relatedGroup1;  

}
      caseObj.First_SLA_Response_Time__c=system.today();
      caseObj.Current_SLA_Phase__c='SLA1 - Ended';
      caseObj.Contact.Email=testContact.email;
      caseObj.ContactId=testContact.Id;
      caseObj.ownerid=u2.id;
      caseObj.Reassignment_Reason__c = 'Not Trained';
      caseObj.track_case_queue__c=queueid1;
      caseObj.check_for_user_owner_change_validation__c = true;
      update caseObj;
      
      u2.Availability__c='Lunch';
      update u2;
        
   R6Service__Post__c testpost11 = new R6Service__Post__c();
testpost11.R6Service__SM_Contact__c = testContact.id;
testpost11.R6Service__SM_Case__c= caseObj.id;
insert testpost11;     
   }

 
public static TestMethod void testsocialmediapost3()
{
caseObj.Current_SLA_Phase__c = 'SLA2 - Initiated';
update caseObj;

R6Service__Post__c testpost2= new R6Service__Post__c();
testpost2.R6Service__SM_Contact__c = testContact.id;
testpost2.R6Service__SM_Case__c= caseObj.id;

insert testpost2;    
}
}