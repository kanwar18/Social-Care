trigger UserAvailability on User (before update) {
     
   public User_History__c h = null;
    User u1 = Trigger.new[0];
    User u2 = Trigger.Old[0];
    User userObj = new User();
    
  
       if(u2.Availability__c <> u1.Availability__c){  
          Integer duration = time_calculation.duration_between_two_date_times(u2.Start_Time__c , DateTime.valueOf(system.now()) );
      
                         userObj.id = u1.id; 
                         userObj.Start_Time__c = u2.Start_Time__c;
                         userObj.User_End_Time__c = DateTime.valueOf(system.now());
                         userObj.Availability__c = u2.Availability__c;
                         userObj.ManagerId = u2.ManagerId;
                         userObj.FirstName = u2.FirstName;                         
                       time_calculation.createRecord(userObj);    
                 u1.Start_Time__c = DateTime.valueOf(system.now()) ;
      
        
    } 
}