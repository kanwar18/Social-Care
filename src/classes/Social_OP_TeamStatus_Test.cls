@istest
public class Social_OP_TeamStatus_Test { 

    //test method for Social_OP_TeamStatus  Class 
    public static TestMethod void Social_OP_TeamStatus1(){ 
        Profile p1 = [select id, name from profile where name='System Administrator'];
        User u = new User(alias = 's146', email='standarduser146@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', 
        Availability__c= 'Available', 
        username='standarduser146@accenture.com');
        insert u;
    
        ApexPages.currentPage().getParameters().put('id', u.Id); 
        system.Runas(u){
        Social_OP_TeamStatus availabilityUser1= new Social_OP_TeamStatus();
        availabilityUser1.getUsers();
        availabilityUser1.getResults();
        Social_OP_TeamStatus.cUser  userStatus = new Social_OP_TeamStatus.cUser(u);
        userStatus.getAvailability(u.Availability__c);
        }
        u.Availability__c= '';
        update u;
    }
    public static TestMethod void SSocial_OP_TeamStatus2(){ 
        Profile p1 = [select id, name from profile where name='System Administrator'];
        User u = new User(alias = 's146', email='standarduser146@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Vacation', 
        username='standarduser146@accenture.com');
        insert u;
    
        ApexPages.currentPage().getParameters().put('id', u.Id);
        system.Runas(u){
            Social_OP_TeamStatus availabilityUser2= new Social_OP_TeamStatus();
            availabilityUser2.getUsers();
            availabilityUser2.getResults();
            Social_OP_TeamStatus.cUser  userStatus = new Social_OP_TeamStatus.cUser(u);
            userStatus.getAvailability(u.Availability__c);
            update u;
        }
    }
     public static TestMethod void SSocial_OP_TeamStatus3(){ 
        Profile p1 = [select id, name from profile where name='System Administrator'];
        User u = new User(alias = 's147', email='standarduser147@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Unavailable', 
        username='standarduser147@accenture.com');
        insert u;
    
        ApexPages.currentPage().getParameters().put('id', u.Id);
        system.Runas(u){
            Social_OP_TeamStatus availabilityUser3= new Social_OP_TeamStatus();
            availabilityUser3.getUsers();
            availabilityUser3.getResults();
            Social_OP_TeamStatus.cUser  userStatus = new Social_OP_TeamStatus.cUser(u);
            userStatus.getAvailability(u.Availability__c);
            update u;
        }
    }
    public static TestMethod void Social_OP_TeamStatus4(){ 
        Profile p1 = [select id, name from profile where name='System Administrator'];
        User u = new User(alias = 's148', email='standarduser148@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Offline', 
        username='standarduser1148@accenture.com');
        insert u;
    
        ApexPages.currentPage().getParameters().put('id', u.Id);
        system.Runas(u){
            Social_OP_TeamStatus availabilityUser4= new Social_OP_TeamStatus();
            availabilityUser4.getUsers();
            availabilityUser4.getResults();
            Social_OP_TeamStatus.cUser  userStatus = new Social_OP_TeamStatus.cUser(u);
            userStatus.getAvailability(u.Availability__c);
            update u;
        }
    }
    public static TestMethod void Social_OP_TeamStatus5(){ 
        Profile p1 = [select id, name from profile where name='System Administrator'];
        User u = new User(alias = 's149', email='standarduser149@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Unavailable - Admin Time', 
        username='standarduser149@accenture.com');
        insert u;
    
        ApexPages.currentPage().getParameters().put('id', u.Id);
        system.Runas(u){
            Social_OP_TeamStatus availabilityUser5= new Social_OP_TeamStatus();
            availabilityUser5.getUsers();
            availabilityUser5.getResults();
            Social_OP_TeamStatus.cUser  userStatus = new Social_OP_TeamStatus.cUser(u);
            userStatus.getAvailability(u.Availability__c);
            update u;
        }
   }
}