public with sharing class Social_UACaseAssignmentHandler {
    
    public Social_UACaseAssignmentHandler(){
        
    }

    private Map<Id, Map<Id, Id>> loadCareManagerAssignmentGroupDetails(List<Id> careManagerIdList){
        //Create a Map of Map<QueueId, Map<UserId, UserId>>
        Map<Id, Map<Id, Id>> returnMap =  new Map<Id, Map<Id, Id>>();
        if(careManagerIdList!=null && careManagerIdList.size()>0){
            List<Assignment_Groups__c> assignmentGroupsList = [Select a.User__c, a.Group_Name__r.Name From Assignment_Groups__c a where a.User_Active__c = 'True' and a.Active__c = 'True' and a.User__c in : careManagerIdList];
            if(assignmentGroupsList!=null && assignmentGroupsList.size()>0){
                List<Assignment_Group_Queues__c> assignmentGroupQueueList =  [Select a.QueueId__c, a.Assignment_Group_Name__r.Name, a.Assignment_Group_Name__c, a.Active__c From Assignment_Group_Queues__c a where a.Active__c = 'True'];
                Map<String, Id> agQueueMap =  new Map<String, Id>();
                if(assignmentGroupQueueList!=null && assignmentGroupQueueList.size()>0){
                    for(Assignment_Group_Queues__c agQ: assignmentGroupQueueList){
                        agQueueMap.put(agQ.Assignment_Group_Name__r.Name, agQ.QueueId__c);
                    }
                }
                for(Assignment_Groups__c ag: assignmentGroupsList){
                    
                    Id queueId = agQueueMap.get(ag.Group_Name__r.Name);
                    if(queueId!=null){
                        if(returnMap.containsKey(queueId)){
                            Map<Id, Id> tempMap =  returnMap.get(queueId);
                            tempMap.put(ag.User__c, ag.User__c);
                            returnMap.put(queueId, tempMap);
                        }
                        else{
                            Map<Id, Id> tempMap =  new Map<Id, Id>();
                            tempMap.put(ag.User__c, ag.User__c);
                            returnMap.put(queueId, tempMap);
                        }
                    }
                }
            }
        }
        return returnMap;
    }
    
    public void assignCasetoCareManagers(List<Id> userIdList){
        if(userIdList!=null && userIdList.size()>0){
            
            Map<Id, Map<Id, Id>> careManagersMap = loadCareManagerAssignmentGroupDetails(userIdList);
            Social_CaseAssignmentHandler handler = new Social_CaseAssignmentHandler();
            List<Case> casestobeAssignedList =  new List<Case>();
            List<String> queueIdList = new List<String>();

            for(Id id: careManagersMap.KeySet()){
                queueIdList.add(String.valueOf(id));    
            }
            
            List<Case> casesToBeAssignedTempList = new List<Case>();
            casesToBeAssignedTempList = Util.getListofCasesToBeAssigned(1, queueIdList); 

            if(!Util.isCollectionEmpty(casesToBeAssignedTempList, 'List')){
                casesToBeAssignedList.clear();
                casesToBeAssignedList.add(casesToBeAssignedTempList[0]);

            }
            List<Assignment_Groups__c> agUpdateList = new List<Assignment_Groups__c>();
            Map<Id,Id> caseMap =  new Map<Id,Id>();
            if(!Util.isCollectionEmpty(casesToBeAssignedList, 'List')){
                for(Id careManagerId: userIdList){
                    for(Case c : casestobeAssignedList){
                        if(c.OwnerId!=null && !careManagersMap.isEmpty() && careManagersMap.containsKey(c.OwnerId)){
                            Map<Id, Id> compareMap = careManagersMap.get(c.OwnerId);
                            if(!compareMap.isEmpty() && compareMap.containsKey(careManagerId)){
                                caseMap.put(c.id, careManagerId);
                                if('New'.equalsIgnorecase(c.Status)){
                                    handler.incrementCareManagerCounter(careManagerId); 
                                }
                                break;
                            }
                            break;
                        }
                    }
                }
                
                List<Assignment_Groups__c> agList = [Select a.User__c, a.User_Active__c, a.Last_Assignment__c From Assignment_Groups__c a where a.User__c IN:userIdList and a.User_Active__c = 'True'];
                if(null!=agList && agList.size()>0){
                    for(Assignment_Groups__c ag: agList){
                        datetime assignmentTime = datetime.now();
                        ag.Last_Assignment__c = assignmentTime;
                        ag.Millisecond__c = assignmentTime.millisecondGMT();
                        agUpdateList.add(ag);
                    }
                }
            }
            if(caseMap!=null && !caseMap.isEmpty()){
                handler.setCaseDetails(caseMap, true); 
                try{                
                    handler.updateCaseDetails();
                    
                    if(null!=agUpdateList && agUpdateList.size()>0){
                        update agUpdateList;
                    }
                }
                catch(Exception e){
                    System.debug('Error in assignCasetoCareManagers '+e.getMessage());                
                }     
            }         
        }
    }
}