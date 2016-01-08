// This class is used to allow users to update their status in the application
public class Social_Activate_User {
    
    // Variable Declarations
    public string user{get;set;}
    public String Status {get;set;}
    public User loggedInUser{get;set;}
        
    // Constructor 
    public Social_Activate_User(){
     
       loggedInUser = [SELECT Name,Availability__c from User WHERE Id =:userInfo.getUserId()];
       if('Available'.equalsIgnoreCase(loggedInUser.Availability__c)){
          user='Available';
       }
       else{
          user='Unavailable';
          Status = loggedInUser.Availability__c;
       }
    }
    
    //  This is a list creating and capturing the Radio values in the page for the 1st section 
    // i.e. Available or Unavailable
    public List<SelectOption> getAvailability() {
        List<SelectOption> Availability = new List<SelectOption>(); 
        Availability.add(new SelectOption('Available','Available')); 
        Availability.add(new SelectOption('Unavailable','Unavailable'));
        return Availability; 
    }
    
    // This is a list creating and capturing the Radio values in the page for the 2nd section if user is Unavailable. 
    // i.e. Break, Lunch, Pause, Vacation and Admin Time.  
    public List<SelectOption> getUnavailability() {
      List<SelectOption> Unavailability = new List<SelectOption>();
        String[] temp = new String[100]; 
        String delimiter =';';
        temp= Label.User_Availability.split(delimiter);
        for (integer i=0; i<temp.size(); i++)
        {
          Unavailability.add(new SelectOption(temp[i], temp[i]));
        }
        return Unavailability; 
    } 
     
     // This method is called when the save button is hit by the user to update his Availability.   
     public PageReference availableMe(){
       if(user!= null)
       {
          // User Available
          if('Available'.equalsIgnoreCase(user)){
              loggedInUser.Availability__c = User;
              loggedInUser.User_Availability_Reset_Time__c= System.now();
              update loggedInUser;
          }
          // User Unavailable
          else if('Unavailable'.equalsIgnoreCase(user)){   
              if(Status!=null && Status!=''){
                 //Status= temp[i]; 
                loggedInUser.Availability__c = Status;
                loggedInUser.User_Availability_Reset_Time__c= System.now();
                update loggedInUser;
              }
              else{
                // Add Error
               ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select Reason of Unavailability');
               ApexPages.addMessage(myMsg);
              }
          } 
       }
       else {
         // Add Error
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select User Status.');
         ApexPages.addMessage(myMsg);
       }
       return null;
    }
}