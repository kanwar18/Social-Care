public class Social_CaseAssignmentSync {

    public Map<String, Integer> caseCountCaseObjMap{get;set;}
    public Map<String, User> caseCountUserObjMap{get;set;}

    public Social_CaseAssignmentSync(){
        caseCountCaseObjMap =  new Map<String, Integer>();
        caseCountUserObjMap =  new Map<String, User>();
        
        if(ApexPages.currentPage()!=null && ApexPages.currentPage().getParameters()!=null && ApexPages.currentPage().getParameters().get('view')!=null && ApexPages.currentPage().getParameters().get('view').equalsIgnoreCase('browser')){
            loadCareManagers();
        }
    }
    
    public PageReference resetCounters() {
        List<User> usersList = loadCareManagers();
        if(usersList!=null && usersList.size()>0){
            try{
                update usersList;   
            }
            catch(Exception e){
                System.debug('Error in CaseAssignmentSync.resetCounters '+e.getMessage());
            }
        }
        PageReference p = new PageReference('/apex/caseCounterSync?view=browser');
        return null;
    }    
    public List<User> loadCareManagers(){
        List<User> userCounterUpdateList =  new List<User>();
        List<Assignment_Group_Queues__c> agGroupQueueList = [Select a.Assignment_Group_Name__c From Assignment_Group_Queues__c a where a.Active__c = 'True'];
        List<Id> queueIdList = new List<Id>();
            
        if(agGroupQueueList!=null && agGroupQueueList.size()>0){
            for(Assignment_Group_Queues__c agQueue : agGroupQueueList){
                queueIdList.add(agQueue.Assignment_Group_Name__c);
            }
            List<Assignment_Groups__c> agGroupUserList = new List<Assignment_Groups__c>();
            if(queueIdList!=null && queueIdList.size()>0){
                agGroupUserList = [SELECT User__c FROM Assignment_Groups__c where Group_Name__c in : queueIdList];
            }
            List<Id> userIdList = new List<Id>();
            if(agGroupUserList!=null && agGroupUserList.size()>0){
                for(Assignment_Groups__c ag : agGroupUserList){
                    userIdList.add(ag.User__c);
                }
            }
            if(userIdList!=null && userIdList.size()>0){
                
                List<AggregateResult> resultList = [Select c.OwnerId, count(c.id) From Case c where c.OwnerId IN : userIdList and c.status <> 'Closed' and c.status <> 'Follow Up Hold' and c.status <> 'Escalated' group by c.OwnerId];

                if(resultList!=null && resultList.size()>0){
                    for(AggregateResult ar : resultList){
                        caseCountCaseObjMap.put(String.Valueof(ar.get('OwnerId')), Integer.Valueof(ar.get('expr0')));
                    }               
                }
                List<User> userCounterList = [Select u.Id, u.name ,u.Case_Counter__c From User u where u.IsActive = true and u.Id IN : userIdList];
                if(userCounterList!=null && userCounterList.size()>0){
                    for(User u : userCounterList){
                        //caseCountUserObjMap.put(u.Id, Integer.Valueof(u.Case_Counter__c));
                        caseCountUserObjMap.put(u.Id, u);
                    }
                }
                if(caseCountCaseObjMap!=null && !caseCountCaseObjMap.isEmpty() && caseCountUserObjMap!=null && !caseCountUserObjMap.isEmpty()){
                    for(String strId : caseCountUserObjMap.KeySet()){
                        if(!caseCountCaseObjMap.containsKey(strId)){
                            caseCountCaseObjMap.put(strId, 0);
                        }
                    }
                    for(String strKey : caseCountCaseObjMap.KeySet()){
                        User tempUser = caseCountUserObjMap.get(strKey);
                        
                        if(tempUser!=null && tempUser.Case_Counter__c!=null && caseCountCaseObjMap.get(strKey)!=null && !(tempUser.Case_Counter__c == caseCountCaseObjMap.get(strKey))){
                            User u = new User();
                            u.id = strKey;
                            u.Case_Counter__c = caseCountCaseObjMap.get(strKey);
                            userCounterUpdateList.add(u);
                        }
                    }
                }
            }
        }
        System.debug('Here Final size : '+userCounterUpdateList.size());
        return userCounterUpdateList;
    }
}