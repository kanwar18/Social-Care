@istest
public class Socialactivationtest
{
//test method for Social_Activate_User Class  
public static TestMethod void Social_Activate_UserTestMethod1()
{
    Profile p1 = [select id, name from profile where name='System Administrator'];
      User u2 = new User(alias = 's155', email='standarduser155@testorg.com',
      emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
      localesidkey='en_US', profileid = p1.Id, isactive=true,
      timezonesidkey='America/Los_Angeles', Availability__c='Available', 
      username='standarduser155@accenture.com');
      insert u2;
      ApexPages.currentPage().getParameters().put('id', u2.Id);
     
      system.Runas(u2)
      {
      Social_Activate_User u1= new Social_Activate_User();
      u1.loggedInUser=u2;
      u1.getAvailability();
      u1.getUnavailability();
      u1.availableMe();
      u1.user='Available'; 
      u1.user= null;
      }
      u2.Availability__c= '';
      update u2;
      
      List<Apexpages.Message> msgs = ApexPages.getMessages();
         boolean b = false;
           for(Apexpages.Message msg:msgs){
          if (msg.getDetail().contains('Please select User Status.')) b = true;
          }
         system.assertNotEquals(null,b);
      }
  public static TestMethod void Social_Activate_UserTestMethod2()
{
    Profile p1 = [select id, name from profile where name='System Administrator'];
      User u = new User(alias = 's156', email='standarduser156@testorg.com',
      emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
      localesidkey='en_US', profileid = p1.Id, isactive=true,
      timezonesidkey='America/Los_Angeles', Availability__c='Lunch', 
      username='standarduser156@accenture.com');
      insert u;
      ApexPages.currentPage().getParameters().put('id', u.Id);
      
      system.Runas(u)
      {
      Social_Activate_User u1= new Social_Activate_User();
      u1.loggedInUser=u;
      u1.getAvailability();
      u1.getUnavailability();
      u1.availableMe();
      u1.user='Unavailable';
      u1.Status='Lunch';
      u1.user=null;
      u1.Status=null;
      
      }
      
      u.Availability__c= '';
      update u; 
      
      List<Apexpages.Message> msgs = ApexPages.getMessages();
         boolean b = false;
           for(Apexpages.Message msg:msgs){
          if (msg.getDetail().contains('Please select Reason of Unavailability')) b = true;
          }
         system.assertNotEquals(null,b);       

   }   
 }