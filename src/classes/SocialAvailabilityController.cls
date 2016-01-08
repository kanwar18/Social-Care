//A class handles the social user status

public class SocialAvailabilityController {
        
        //Instance Vars
        public String currentUserStatus {get; set;}
        public String currentUserStatusIcon {get; set;}
        public User loggedInUser{get;set;}
                
        public Map<String, String> socialUserStatusMap {
            get {
                if(null == socialUserStatusMap){
                        socialUserStatusMap = new Map<String, String>();
                }
                return socialUserStatusMap;
            }
            set;
        }
        
        //Constants
        private static final String STAT_AVA = 'Available';
        private static final String STAT_UNUVA = 'Unavailable';
        private static final String STAT_VAC = 'Vacation';
        private static final String STAT_OFFLINE = 'Offline';
        
        private static final String STAT_GREEN = 'status_green.PNG';
        private static final String STAT_YELLOW = 'status_yellow.PNG';
        private static final String STAT_GREY = 'status_grey.PNG';
        
        //Cons
        public SocialAvailabilityController() {
          
            loggedInUser = [SELECT Name,Availability__c, LastLoginDate, User_Availability_Reset_Time__c  from User WHERE Id =:userInfo.getUserId()];
            currentUserStatus = loggedInUser.Availability__c; 
            
            if(loggedInUser.LastLoginDate > loggedInUser.User_Availability_Reset_Time__c){
                loggedInUser.Availability__c = 'Unavailable - Admin Time';
                currentUserStatusIcon = STAT_YELLOW;
            }
            
            if(loggedInUser.Availability__c.startsWith(STAT_UNUVA)){
                currentUserStatusIcon = STAT_YELLOW; 
            }
            
            if(loggedInUser.Availability__c =='Available'){
                currentUserStatusIcon = STAT_GREEN;
            }
            if(loggedInUser.Availability__c =='Offline'){
                currentUserStatusIcon = STAT_GREY; 
            }
            if(loggedInUser.Availability__c =='Vacation'){
                currentUserStatusIcon = STAT_GREY; 
            }
            processSocialStatus();
        }
        
        //Method to get the various status
        public void processSocialStatus() {
                String customLabelVal = '';
                List<String> statusList = null;
                Set<String> statusSet = null;
                String statusIcon = '';
                
                try {
                    customLabelVal = System.Label.User_Availability;
                    statusList = customLabelVal.split(',');
                    statusSet = new Set<String>();
                    statusSet.addAll(statusList);
                    
                    for(String statusStr : statusSet) {
                            statusIcon = '';
                            if(statusStr.startsWith(STAT_AVA)) {
                                    statusIcon = STAT_GREEN;
                            } else if(statusStr.startsWith(STAT_UNUVA)) {
                                    statusIcon = STAT_YELLOW;
                            } else if(statusStr.startsWith(STAT_VAC)) {
                                    statusIcon = STAT_GREY;
                            } 
                            else if(statusStr.startsWith(STAT_OFFLINE)) {
                                    statusIcon = STAT_GREY;
                            }
                            socialUserStatusMap.put(statusStr, statusIcon);
                }//End for 'for' loop
                
        } catch(Exception excep) {
                System.debug('Exception Caught :'+excep.getMessage());
        }
    }
    
    public void updateSocialUserStatus() {
      
        if(currentUserStatus.startsWith(STAT_AVA)) {
           currentUserStatusIcon = STAT_GREEN;
        } else if(currentUserStatus.startsWith(STAT_UNUVA)) {
           currentUserStatusIcon = STAT_YELLOW;
        } else if(currentUserStatus.startsWith(STAT_VAC)) {
          currentUserStatusIcon = STAT_GREY;
        }else if(currentUserStatus.startsWith(STAT_OFFLINE)) {
          currentUserStatusIcon = STAT_GREY;
        } 
        
        loggedInUser.Availability__c =currentUserStatus;
        loggedInUser.User_Availability_Reset_Time__c= System.now();
        update loggedInUser;   
    }
}