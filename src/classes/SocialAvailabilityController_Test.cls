@istest
public class SocialAvailabilityController_Test {
    
    //test method for SocialAvailabilityController  Class 
    public static TestMethod void SocialAvailabilityController1(){ 
        Profile p1 = [select id, name from profile where name='System Administrator'];
        User u = new User(alias = 's104', email='standarduser104@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', 
        Availability__c= 'Available', 
        username='standarduser104@accenture.com');
        insert u;
    
        ApexPages.currentPage().getParameters().put('id', u.Id);
        system.Runas(u){
        SocialAvailabilityController availabilityUser1= new SocialAvailabilityController();
            availabilityUser1.processSocialStatus();
            availabilityUser1.updateSocialUserStatus();
        }
        update u;
    }
    public static TestMethod void SocialAvailabilityController2(){ 
        Profile p1 = [select id, name from profile where name='System Administrator'];
        User u = new User(alias = 's105', email='standarduser105@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Vacation', 
        username='standarduser105@accenture.com');
        insert u;
    
        ApexPages.currentPage().getParameters().put('id', u.Id);
        system.Runas(u){
        SocialAvailabilityController availabilityUser2= new SocialAvailabilityController ();
            availabilityUser2.processSocialStatus();
            availabilityUser2.updateSocialUserStatus();
        }
        update u;
    }
    public static TestMethod void SocialAvailabilityController3(){ 
        Profile p1 = [select id, name from profile where name='System Administrator'];
        User u = new User(alias = 's106', email='standarduser106@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Unavailable', 
        username='standarduser106@accenture.com');
        insert u;
    
        ApexPages.currentPage().getParameters().put('id', u.Id);
        system.Runas(u){
        SocialAvailabilityController availabilityUser3= new SocialAvailabilityController ();
            availabilityUser3.processSocialStatus();
            availabilityUser3.updateSocialUserStatus();
        }
        update u;
    }
    public static TestMethod void SocialAvailabilityController4(){ 
        Profile p1 = [select id, name from profile where name='System Administrator'];
        User u = new User(alias = 's107', email='standarduser107@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Offline', 
        username='standarduser107@accenture.com');
        insert u;
    
        ApexPages.currentPage().getParameters().put('id', u.Id);
        system.Runas(u){
        SocialAvailabilityController availabilityUser4= new SocialAvailabilityController ();
            availabilityUser4.processSocialStatus();
            availabilityUser4.updateSocialUserStatus();
        }
        update u;
    }
    public static TestMethod void SocialAvailabilityController5(){ 
        Profile p1 = [select id, name from profile where name='System Administrator'];
        User u = new User(alias = 's108', email='standarduser108@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Unavailable - Admin Time', 
        username='standarduser108@accenture.com');
        insert u;
    
        ApexPages.currentPage().getParameters().put('id', u.Id);
        system.Runas(u){
        SocialAvailabilityController availabilityUser5= new SocialAvailabilityController ();
            availabilityUser5.processSocialStatus();
            availabilityUser5.updateSocialUserStatus();
        }
        update u;
    }
}