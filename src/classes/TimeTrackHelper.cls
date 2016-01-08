public class TimeTrackHelper {
    public Map<Id, User> cacheUserMap = new Map<Id, User>();
    
    
    //Cons
    public TimeTrackHelper() {
        
    }
    
    //Method to return the list of users
    public Map<Id, User> getUsersMap(boolean isExecuteQuery) {
        if(cacheUserMap.isEmpty() || isExecuteQuery) {
            for(User userObj : [Select Id, Availability__c,Profile.Name,Name from User 
                Where isActive = true Limit 7000]) {
                cacheUserMap.put(userObj.Id, userObj);
            }
        }
        return cacheUserMap;
    }
    
    //method gives the logged-in user information
    public static User getCurrentUserInfo() {
        return new TimeTrackHelper().getUsersMap(false).get(UserInfo.getUserId());
    }
    
    //method used to validate the case object record
    public void doValidateCaseRecord(Case caseObj, String profileName, 
        String recordTypeName, String transactionType) {
        system.debug('***********Inside validate care record************');
        if(caseObj != null &&
            TimeTrackUtility.doValidUserAvailabilityStatus() && 
            profileName.contains(TimeTrackHelper.getCurrentUserInfo().Profile.Name)) 
        {
            caseObj = [Select Id, Status,RecordType.Name from Case Where Id = : caseObj.Id];
            if(null != caseObj && caseObj.RecordType.Name.contains(recordTypeName)) {
                TimeTrackUtility.doInsertTimeRecord(UserInfo.getUserId(), caseObj, transactionType);
            }       
        }
    }
    
    public static Map<Id, SObject> doGetSObjectMap(List<SObject> sobjectList) {
        Map<Id, SObject> sobjectMap = new Map<Id, SObject>();
        if(null != sobjectList && !sobjectList.isEmpty()) {
            for(SObject sobjectObj : sobjectList) {
                sobjectMap.put((Id)sobjectObj.get('Id'), sobjectObj);
            }
        }
        return sobjectMap;
    }
}