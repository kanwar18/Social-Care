//A class handles the social user status

public class Social_OP_TeamStatus{
        
    public List<cUser> userList {get; set;}
    
    //Constants
    private static final String STAT_AVA = 'Available';
    private static final String STAT_UNUVA = 'Unavailable';
    private static final String STAT_VAC = 'Vacation';
    private static final String STAT_OFFLINE = 'Offline';
    private static final String STAT_GREEN = 'status_green.PNG';
    private static final String STAT_YELLOW = 'status_yellow.PNG';
    private static final String STAT_GREY = 'status_grey.PNG';
    
    //Cons
    public  Social_OP_TeamStatus(){
        getUsers();
    }
        
    //This method uses a simple SOQL query to return a List of user
    public List<cUser> getUsers() {
        if(userList == null) {
            userList = new List<cUser>();
            for(User c: [Select ManagerId, Name,Availability__c, Id From User where ManagerId =:userInfo.getUserId()]){           
                userList.add(new cUser(c));
            } 
        }
        return userList;
    }
     
    public List<cUser> getResults(){
     getUsers();
     return userList;
   }
    
   // This is our wrapper/container class. 
    public class cUser {
        public User con {get; set;}
        public String cellcolor {get; set;}
        public String sp {get; set;}
        public String color {get; set;}
        
       
        //This is the contructor method. 
        public cUser(User c) {
            this.con = c;
            if(c.Availability__c !=Null){
                getAvailability(c.Availability__c);
            }
            else{
            this.cellcolor= STAT_YELLOW;
            }  
        }     
        public void getAvailability(String userAvailablity){
            
          if(userAvailablity.startsWith(STAT_AVA)) {
                this.cellcolor  = STAT_GREEN;
          } 
          
          if(userAvailablity.startsWith(STAT_VAC)) {
                this.cellcolor= STAT_GREY;
          }
          if(userAvailablity.startsWith(STAT_OFFLINE)) {
                this.cellcolor= STAT_GREY;
          }
           
          if(userAvailablity.startsWith(STAT_UNUVA)) {
                this.cellcolor= STAT_YELLOW;
          }
       }       
   }
}