@isTest
public class Test_Time_Calculations {
    
    //test for the time_calculation methods
    public static testMethod void test_duration() {
     
        Profile p1 = [select id, name from profile where name='Operations Manager'];
        User u2 = new User(alias = 's157', email='standarduser157@testorg.com',Duration__c = 12,
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', 
        profileid =p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  
        username='standarduser157@accenture.com', User_End_Time__c=DateTime.valueOf('2010-09-09 20:57:01'),Start_Time__c = DateTime.valueOf('2010-09-09 20:57:00') );
        insert u2;
    
        u2.Availability__c = 'Unavailable - Lunch';
        u2.Start_Time__c = DateTime.valueOf(System.now());
        
        update u2;
      
     
     
        //validate one second
        DateTime dt1 = DateTime.valueOf('2010-09-09 20:57:00'); //datetime start variable
        DateTime dt2 = DateTime.valueOf('2010-09-09 20:57:01'); //datetime end variable
        System.assertEquals( 1, time_calculation.duration_between_two_date_times(dt1, dt2));
 
        //validate zero seconds
        dt1 = DateTime.valueOf('2010-09-09 20:57:00'); //datetime start variable
        dt2 = DateTime.valueOf('2010-09-09 20:57:00'); //datetime end variable
        System.assertEquals(0, time_calculation.duration_between_two_date_times(dt1, dt2));
  
       
    
        time_calculation C1= new time_calculation();
        time_calculation.createRecord(u2);
    
      
        User_History__c historyRecord = new  User_History__c();
           // if(duration != null){
                historyRecord.Duration__c = u2.Duration__c;
               // historyRecord.Name__c = 'teting';
                        historyRecord.Availability__c ='Available';
              //  historyRecord.Manager__c  = userRecord.ManagerId;
                historyRecord.User_Id__c = U2.Id;
                 // System.debug('UserID::::'+historyRecord.User_Id__c);
               // historyRecord.Duration_Time__c = getTimeField(duration);
                
                insert historyRecord;
              //  }
              
              
    }
    
}