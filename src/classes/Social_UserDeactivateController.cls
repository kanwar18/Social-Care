public class Social_UserDeactivateController {

  // Method To Make User Unavailable
  public void makeUserInactive(){
     User loggedInUser = [Select u.Id, u.Availability__c, u.LastLoginDate, u.User_Availability_Reset_Time__c From User u where 
                          u.Id=: Userinfo.getUserId()];
     
     // Check If User Available
     if(loggedInUser.User_Availability_Reset_Time__c==null || (loggedInUser.User_Availability_Reset_Time__c!=null && loggedInUser.User_Availability_Reset_Time__c < loggedInUser.LastLoginDate)){
        
        loggedInUser.Availability__c = 'Unavailable - Admin Time';
        loggedInUser.Start_Time__c = DateTime.valueOf(system.now()) ;
        try{
            update loggedInUser;
        }
        catch(Exception Exp){
            System.debug('USER LOGIN UPDATE ERROR' + Exp.getmessage());
        }
     }
  }
  
}