public class Social_RoundRobinCaseAssignmentHandler {
    
    private List<Id> queueIdList =  new List<Id>();
    private Map<String, Integer> careManagerMap =  new Map<String, Integer>();
    private Map<String, Integer> careManagerAssignCaseMap =  new Map<String, Integer>();
    private Map<String, List<Assignment_Groups__c>> assignmentGroupsMap;
    public Map<String, Integer> currentExecutionMap;
    private List<Case> updateCaseList =  new List<Case>();
    private List<User> updateUserList =  new List<User>();
    Social_CaseUtility scu;
    Set<Case> ReassignedCaseSet = new Set<Case>();
    Set<Case> assignedCaseSet = new Set<Case>();
    //Social_RoundRobinCaseAssignment srrca =  new Social_RoundRobinCaseAssignment();
    /*
    
    Constructor
     
    */
    
    public Social_RoundRobinCaseAssignmentHandler(){
        queueIdList = getAssociatedQueues();
        scu =  new Social_CaseUtility();
        assignmentGroupsMap =  new Map<String, List<Assignment_Groups__c>>();
        currentExecutionMap =  new Map<String, Integer>();            
    }
    
    public List<Case> getCaseListToBeProcessed(){
        List<Case> caseList = new List<Case>();
        List<Case> influencerHighCases =  new List<Case>();
        List<Case> remainingCases =  new List<Case>();
        
        
        /*
        STEP 1: Get all reassigned Cases
        */
        List<Case> reassignedCases = getReassignedCaseList();
        caseList.addAll(reassignedCases);   
        
        
        /*
        STEP 2: Get all influencer High Cases exculuding the cases with reassigned status
        */
        influencerHighCases = getInfluencerHighCaseList(reassignedCases);
        if(!Util.isCollectionEmpty(influencerHighCases, 'List')){
            caseList.addAll(influencerHighCases);
        }
        
        /*
        STEP 3: Get all the remaining Cases exculuding the cases with reassigned status and Influencer High cases
        */
        remainingCases = getRemainingCasesList(influencerHighCases);
        if(!Util.isCollectionEmpty(remainingCases, 'List')){
            caseList.addAll(remainingCases);
        }
        
        
        
        return caseList;
    }
    private List<Case> getReassignedCaseList(){
        List<Case> reassignedCaseList = new List<Case>();
        try{
            reassignedCaseList =  [Select c.Id, c.ownerId, c.status From Case c where c.ownerId IN : queueIdList and c.status = 'Reassigned' order by c.createdDate asc];
        }
        catch(Exception e){
            System.debug('Error in Social_RoundRobinCaseAssignmentHandler.getReassignedCaseList() method '+e.getMessage());
            throw e;
        }
        return reassignedCaseList;
    }
    private List<Case> getInfluencerHighCaseList(List<Case> caseList){
        List<Case> influenceHighCaseList =  new List<Case>();
        try{
            /*
            Using below to limit the number of social posts being searched for
            */
            List<Case> caseIdList = new List<Case>();
            if(!Util.isCollectionEmpty(queueIdList, 'List')){
                caseIdList = [Select c.id, c.status from Case c where c.status <> 'Closed' and c.status <> 'Auto Closed' and c.ownerId IN: queueIdList];
            }
            if(!Util.isCollectionEmpty(caseIdList, 'List')){
                if(!Util.isCollectionEmpty(caseList, 'List')){
                    influenceHighCaseList = [Select c.Id, c.ownerId, c.status from Case c where c.id IN (Select s.parentId from SocialPost s where s.R6Service__IsOutbound__c = FALSE and s.IsDeleted = FALSE and R6Service__SourceTags__c = 'Influencer High' and s.parentId IN: caseIdList) and c.id not IN: caseList order by c.createdDate asc];
                }
                else{
                    influenceHighCaseList = [Select c.Id, c.ownerId, c.status from Case c where c.id IN (Select s.parentId from SocialPost s where s.R6Service__IsOutbound__c = FALSE and s.IsDeleted = FALSE and R6Service__SourceTags__c = 'Influencer High' and s.parentId IN: caseIdList) order by c.createdDate asc];
                }
            }
            System.Debug('Influence High List size  '+influenceHighCaseList.size());
        }
        catch(Exception e){
            System.debug('Error in Social_RoundRobinCaseAssignmentHandler.getInfluencerHighCaseList() method '+e.getMessage());
            throw e;
        }
        return influenceHighCaseList;
    }
    private List<Case> getRemainingCasesList(List<Case> caseList){
        List<Case> remainingCasesList =  new List<Case>();
        String businessrectypeid=Label.Business_Care_Case_Record_Type_ID;
        try{
            if(!Util.isCollectionEmpty(caseList, 'List')){
                System.debug('caseList size: '+caseList.size() + ' queueIdList size: '+queueIdList.size());
                remainingCasesList = [Select c.id, c.ownerId, c.status from Case c where c.ownerId IN: queueIdList and c.status <> 'Closed' and c.status <> 'Auto Closed' and c.status <> 'Reassigned' and c.Owner.Type = 'Queue' and c.IsDeleted = false and c.recordtypeid!=:businessrectypeid and c.id not IN: caseList order by c.createdDate asc limit 10000];
            }
            else{
                System.debug('Entered Else ');  
                remainingCasesList = [Select c.id, c.ownerId, c.status from Case c where c.ownerId IN: queueIdList and c.status <> 'Closed' and c.status <> 'Auto Closed' and c.status <> 'Reassigned' and c.Owner.Type = 'Queue' and c.IsDeleted = false and c.recordtypeid!=:businessrectypeid order by c.createdDate asc limit 10000];
            }
        }
        catch(Exception e){
            System.debug('Error in Social_RoundRobinCaseAssignmentHandler.getRemainingCasesList() method '+e.getMessage());
            throw e;
        }
        return remainingCasesList;
    }
    
    /**
        Method to get all the Queues configured in the Assignemnt Groups
    */
    private List<Id> getAssociatedQueues(){
        List<Id> assignmentGroupQueueIdList =  new List<Id>();
        try{
            List<Assignment_Group_Queues__c> listAssignmentGroup = [Select a.QueueId__c, a.Name, a.Id, a.Assignment_Group_Name__c, a.Assignment_Group_Name__r.Name, a.Active__c From Assignment_Group_Queues__c a where Active__c = 'True'];
            if(!Util.isCollectionEmpty(listAssignmentGroup, 'List')){
                for(Assignment_Group_Queues__c ag : listAssignmentGroup){
                    assignmentGroupQueueIdList.add(ag.QueueId__c);
                }
            }
        }
        catch(Exception e){
            System.debug('Error in Social_CaseAssignmentHandler.getAssociatedQueues method : '+e.getMessage());
        }
    return assignmentGroupQueueIdList;  
    }
    
    public void setCurrentExecutionMap(){
        if(currentExecutionMap!=null){
            currentExecutionMap.clear();
        }
    }
    public Map<String, Integer> preloadCareManagers(){

        List<Assignment_Group_Queues__c> agGroupQueueList = [Select a.QueueId__c, a.Assignment_Group_Name__c From Assignment_Group_Queues__c a where a.Active__c = 'True'];
        if(agGroupQueueList!=null && agGroupQueueList.size()>0){
            List<Assignment_Groups__c> agGroupUserList = new List<Assignment_Groups__c>();
            Map<ID, ID> assignmentGroupQueueMap = new Map<ID, ID>();
            for(Assignment_Group_Queues__c agQueues : agGroupQueueList){
                if(agQueues.QueueId__c!=null && !agQueues.QueueId__c.equals('')){
                    assignmentGroupQueueMap.put(agQueues.QueueId__c, agQueues.Assignment_Group_Name__c);
                }
            }
            if(assignmentGroupQueueMap!=null && !assignmentGroupQueueMap.isEmpty()){
                agGroupUserList = [SELECT Group_Name__c, Group_Name__r.Name, User__r.Username, User__c, Last_Assignment__c, Millisecond__c, User_Availability__c FROM Assignment_Groups__c where Group_Name__c in : assignmentGroupQueueMap.values() and User_Availability__c = 'Available' ORDER BY Last_Assignment__c, Millisecond__c];
                List<ID> careManagerIdList = new List<ID>();
                if(agGroupUserList!=null && agGroupUserList.size()>0){
                    for (Id id : assignmentGroupQueueMap.keySet()){
                        List<Assignment_Groups__c> agGroupUserListNew =  new List<Assignment_Groups__c>();
                        for(Assignment_Groups__c assignmentGroups : agGroupUserList){
                            if(assignmentGroups.Group_Name__c!=null && String.ValueOf(assignmentGroups.Group_Name__c).equalsIgnoreCase(String.ValueOf(assignmentGroupQueueMap.get(id)))){
                                agGroupUserListNew.add(assignmentGroups);
                            }
                        }
                        assignmentGroupsMap.put(id, agGroupUserListNew);
                    }
                    for(Assignment_Groups__c assignmentGroups : agGroupUserList){
                        if(assignmentGroups.User__c!=null){
                            careManagerIdList.add(assignmentGroups.User__c);
                        }
                    }
                }
                if(careManagerIdList!=null && careManagerIdList.size() > 0){
                    List<AggregateResult> resultList = [Select c.OwnerId, count(c.id) From Case c where c.OwnerId IN :careManagerIdList and (c.status = 'New' OR c.status = 'Reassigned' OR c.status = 'Reopen' OR c.status = 'Investigating' OR c.status = 'Escalated') group by c.OwnerId]; 
                    for(AggregateResult ar : resultList){
                        if(ar!=null && ar.get('OwnerId')!=null && !careManagerMap.containsKey(String.Valueof(ar.get('OwnerId'))) && ar.get('expr0')!=null ){
                            careManagerMap.put(String.Valueof(ar.get('OwnerId')), Integer.valueOf(ar.get('expr0')));
                        }
                    }
                    for(String strId : careManagerIdList){
                        if(careManagerMap!=null && !careManagerMap.containsKey(strId)){
                            careManagerMap.put(strId, 0);
                        }
                    }
                }
            }
        }
        return careManagerMap;
    }
    
    public String getAvailableCaseManagerfromQueue(Id queueId){
        String careManagerId = ''; 
        List<Assignment_Groups__c> agGroupUserList = new List<Assignment_Groups__c>();
        boolean assignToThisUser = false;
            if(queueId!=null){
                
                if(assignmentGroupsMap!=null && !assignmentGroupsMap.isEmpty()){
                    
                    agGroupUserList = assignmentGroupsMap.get(queueId);
                    
                    if(agGroupUserList!=null && agGroupUserList.size() > 0){
                        for(Assignment_Groups__c ag : agGroupUserList){
                            if(ag.User__c!=null){

                                Integer cmcaseCounter;
                                if(careManagerMap!=null  && !careManagerMap.isEmpty()){
                                    cmcaseCounter = careManagerMap.get(ag.User__c);
                                }
                                if(currentExecutionMap!=null && currentExecutionMap.containsKey(ag.User__c)){
                                    Integer counter = currentExecutionMap.get(ag.User__c);
                                    if(counter < Integer.valueOf(System.label.Case_Assignment_Counter)){
                                        assignToThisUser = true;
                                    }
                                    else{
                                        assignToThisUser = false;
                                    }
                                }
                                else{
                                    assignToThisUser = true;
                                }
                                if(cmcaseCounter!=null && cmcaseCounter < Integer.valueOf(System.label.Case_Cap_Counter) && assignToThisUser){
                                    careManagerId = ag.User__c;
                                    Integer currentCounterValue = 0; 
                                    if(currentExecutionMap!=null && !currentExecutionMap.containsKey(ag.User__c)){
                                        //insert
                                        currentCounterValue = currentCounterValue + 1;
                                        currentExecutionMap.put(ag.User__c, currentCounterValue);
                                    }
                                    else{
                                        //update counter
                                        if(currentExecutionMap!=null){
                                            currentCounterValue = currentExecutionMap.get(ag.User__c);
                                            currentCounterValue = currentCounterValue + 1;
                                            currentExecutionMap.put(ag.User__c, currentCounterValue);
                                        }
                                    }
                                    updateCaremanagerTimestampDetails(ag, queueId);
                                    break;
                                }
                            } 
                        }                                               
                    }
                } 
            }
        return careManagerId;
    }
    /*
        Method to update Care manager Time stamp details
    */
    List<Assignment_Groups__c> careManagerDetailsList =  new List<Assignment_Groups__c>();
    private void updateCaremanagerTimestampDetails(Assignment_Groups__c careManagerDetails, Id newQueueId){
        if(careManagerDetails!=null && careManagerDetails.Id!=null){
            try{
                datetime assignmentTime = datetime.now();
                careManagerDetails.Last_Assignment__c = assignmentTime;
                careManagerDetails.Millisecond__c = assignmentTime.millisecondGMT();
                careManagerDetailsList.add(careManagerDetails);
            }
            catch(Exception e){
                System.debug('>>>>>>>>>> Error in updateCaremanagerTimestampDetails '+e);
            }
        
            if(assignmentGroupsMap!=null && !assignmentGroupsMap.isEmpty()){
                List<Assignment_Groups__c> assignmentGroupsList = new List<Assignment_Groups__c>();         
                List<Assignment_Groups__c> assignmentGroupsTempList = new List<Assignment_Groups__c>();
                assignmentGroupsList = assignmentGroupsMap.get(newQueueId);
                if(assignmentGroupsList!=null && assignmentGroupsList.size()>0){
                    for(Assignment_Groups__c ag : assignmentGroupsList){
                        if(ag.User__c!=null){
                            if(String.Valueof(ag.User__c).equalsIgnoreCase(String.Valueof(careManagerDetails.Id))){
                                datetime assignmentTime = datetime.now();
                                ag.Last_Assignment__c = assignmentTime;
                                ag.Millisecond__c = assignmentTime.millisecondGMT();
                                assignmentGroupsTempList.add(ag);
                            }
                            else{
                                assignmentGroupsTempList.add(ag);
                            }
                        }
                    }
                }
                assignmentGroupsTempList = sortList(assignmentGroupsTempList, 'Last_Assignment__c', 'asc');
                assignmentGroupsMap.put(newQueueId, assignmentGroupsTempList);
            }
        }
    }
    
    /*
        Method to Sort List of Sobject type
    */
    private List<Sobject> sortList(List<Sobject> items, String sortField, String order){
        
        //System.debug(' Items for Sort : '+items.size());
        List<Sobject> resultList = new List<Sobject>();
        //Create a map that can be used for sorting
        Map<object, List<Sobject>> objectMap = new Map<object, List<Sobject>>();
        for(Sobject ob : items){
            if(objectMap.get(ob.get(sortField)) == null){
                    // For non Sobject use obj.ProperyName
                objectMap.put(ob.get(sortField), new List<Sobject>());
            }
            objectMap.get(ob.get(sortField)).add(ob);
        }
        List<object> keys;
        if(sortField!=null && sortField.equalsIgnoreCase('priority')){
            keys =  new List<object>();
            String strHigh = 'High';
            object obj1 = strHigh;
            keys.add(obj1);
            
            String strMedium = 'Medium';
            object obj2 = strMedium;
            keys.add(obj2);
            
            String strLow = 'Low';
            object obj3 = strLow; 
            keys.add(obj3);
        }
        else{
            //Sort the keys
            keys = new List<object>(objectMap.keySet());
            keys.sort(); 
        }        
        //System.debug('Here Map Size : '+objectMap.size());
        for(object key : keys){
            if(objectMap.get(key)!=null){
                resultList.addAll(objectMap.get(key));
            }
        }
        //System.debug('resultList Size here : '+resultList.size());
        //Apply the sorted values to the source list
        items.clear();
        if(order.toLowerCase() == 'asc'){
            for(Sobject ob : resultList){
                items.add(ob);
            }
        }else if(order.toLowerCase() == 'desc'){
            for(integer i = resultList.size()-1; i >= 0; i--){
                items.add(resultList[i]); 
            }
        }
        //System.debug(' Items for Sorted : '+items.size());
        return items;
    }
    /*
        Care Manager counter update method
    */
    public void incrementCareManagerCounter(Id userId){ 
        System.debug('>>>>>>>>> '+careManagerMap);
        
        if(userId!=null && careManagerMap!=null && !careManagerMap.isEmpty()){
            Integer caseCounterforCareManager = careManagerMap.get(userId);
            System.debug('Counter before update : '+caseCounterforCareManager);
            caseCounterforCareManager = caseCounterforCareManager + 1;
            System.debug('Counter after update : '+caseCounterforCareManager+' and user Id : '+userId);
            careManagerMap.put(userId, caseCounterforCareManager);
        }
        else{
            integer counter = 0;
            if(null!=careManagerAssignCaseMap && !careManagerAssignCaseMap.isEmpty()){
                counter = careManagerAssignCaseMap.get(userId);
                counter = counter+1;
                careManagerAssignCaseMap.put(userId, counter);
                System.debug('userId :'+userId+' counter :'+counter);
            }
            else{
                careManagerAssignCaseMap.put(userId, 1);
            }
        }
    }
    
    public void setCaseDetails(Map<Id, Id> caseMap, boolean selfAssignment, boolean instantAssignment){
        if(caseMap!=null && !caseMap.isEmpty()){
            try{
                List<Case> finalCaseList = [Select c.recordTypeID, c.OwnerId, c.Id, c.Track_Case_Queue__c, c.Current_SLA_Phase__c, c.CaseNumber, c.First_SLA_Scheduled_Time__c, c.Case_Assigned_Time__c,c.Moved_to_Prior_Care_Manager__c,c.Case_Reassigned_Time__c, c.Status, c.Customer_Response_Received__c, c.Assigned_Operation_Manager__c, c.Pending_Second_SLA_Task_Creation__c, c.Case_Reopen_Flag__c, c.Second_SLA_Pending_Post__c from Case c where c.id in : caseMap.KeySet()];
                //Get the case 
                Set<String> traineeProfileSet = new Set<String>(System.Label.HS_Care_Rep_Profile_Id.split(';'));
                if(finalCaseList!=null && finalCaseList.size()>0){
                    scu.createSlaEventsDefaultsInvocation();
                    for(Case newCase : finalCaseList){
                        datetime assignmentTime = datetime.now();
                        // Update Case Owner
                        String caremanagerId = caseMap.get(newCase.id);
                        //Aditya: Logic to flip record type to HS Care Rep or vice versa
                        //Avoid Automated Admin Updates
                        if (userInfo.getUserId().subString(0,15) != System.Label.Email_Case_UserId) {
                            newCase = Social_SocialPostSCSHandler.flipCaseRTBasedOnProfile(newCase);
                        }
                        //Loading the Track Case Queue field value to the current Queue before assignment. Toggle flag "Enable_Code" to turn off this code 
                        if(String.valueOf(System.label.Enable_Code).equalsIgnoreCase('True') && (newCase.Track_Case_Queue__c == null || newCase.Track_Case_Queue__c.equalsIgnoreCase(''))){                     
                            newCase.Track_Case_Queue__c = newCase.OwnerId;
                        } 
                        newCase.OwnerId = caremanagerId;
                        newCase.NonCaseOwner_LastModifiedDate__c = system.now();
                        if(instantAssignment!=null && instantAssignment){
                          newCase.Update_Reason__c = 'Availability Assignment';
                        }
                        else if(selfAssignment!=null && !selfAssignment && null!=instantAssignment && !instantAssignment){
                            if(newCase.Moved_to_Prior_Care_Manager__c == false){  
                                newCase.Update_Reason__c = 'New Case';
                            }
                        }
                        newCase.ReadUnreadCheck__c = true;
                        if(userInfo.getName()!=null && (userInfo.getName()).equalsIgnoreCase('Automated Admin')){
                            newCase.Round_Robin_Assignment__c = true;
                            newCase.Round_Robin_Case_Assignment_Time__c = datetime.now();
                            newCase.Instant_Assignment__c = false;
                            newCase.SelfAssignment__c = false;
                        }
                        else if(userInfo.getName()!=null && (userInfo.getUserId()).contains(newCase.OwnerId)){
                            if(selfAssignment!=null && selfAssignment){
                                newCase.Update_Reason__c = 'Self Assigned';
                                newCase.SelfAssignment__c = true;
                                newCase.SelfAssignmentTime__c = datetime.now();
                                newCase.Instant_Assignment__c = false;
                                newCase.Round_Robin_Assignment__c = false;
                            }
                            else{
                                newCase.Instant_Assignment__c = true;
                                newCase.Instant_Assignment_Time__c = datetime.now();
                                newCase.Round_Robin_Assignment__c = false;
                                newCase.SelfAssignment__c = false;
                            }
                        }
                        
                        // Update Assigned Operations Manager(First Assignment Only)
                        if(newCase.Assigned_Operation_Manager__c==null){
                            newCase.Assigned_Operation_Manager__c = scu.getRelatedOperationManager(caremanagerId);
                        }
                        
                        // Track New Operation Manager Email(After Initial Assignment)
                        if(newCase.Case_Assigned_Time__c!=null){
                            newCase.Track_Case_Owner_Change__c = true;
                            newCase.Current_Operation_Manager_Email__c = scu.getRelatedOperationManagerEmail(caremanagerId);
                        }   
                             
                        // If Case Pending Queue Since Creation(1st SLA)
                        if((newCase.First_SLA_Scheduled_Time__c==null || String.valueOf(newCase.First_SLA_Scheduled_Time__c).equals(''))){
                            scu.createSlaEvents(newCase, caremanagerId, assignmentTime, 'SLA - 1');
                            // Update SLA on Case
                            newCase.Current_SLA_Phase__c = 'SLA1 - Initiated';
                            newCase.Customer_Response_Received__c = true; //DNR: customer response received true when SLA1 initiate.
                            // populate case assign time on first assignment
                            if(newCase.Case_Assigned_Time__c==null){
                                newCase.Case_Assigned_Time__c = assignmentTime;
                                assignedCaseSet.add(newCase);
                            }
                            // to populate case Reassigned time when the case is moved from Queue to user on reassignment
                            else if(newCase.Moved_to_Prior_Care_Manager__c == false){
                                newCase.Case_Reassigned_Time__c = assignmentTime;
                                ReassignedCaseSet.add(newCase);
                            }
                            newCase.First_SLA_Scheduled_Time__c = assignmentTime.addMinutes(15);
                        }
                        if('SLA1 - Ended'.equalsIgnorecase(newCase.Current_SLA_Phase__c)){
                            if(newCase.Moved_to_Prior_Care_Manager__c == false) {
                                newCase.Case_Reassigned_Time__c = assignmentTime;
                                ReassignedCaseSet.add(newCase);
                            }
                            if (newCase.Customer_Response_Received__c) {
                                // Update Case
                                newCase.Current_SLA_Phase__c = 'SLA2 - Initiated';
                                newCase.Second_SLA_Start_Time__c = assignmentTime;
                                newCase.Second_SLA_Scheduled_Time__c = assignmentTime.addMinutes(60);
                                //If Case.Pending_Second_SLA_Task_Creation__c = true then create second SLA task 
                                if(newCase.Pending_Second_SLA_Task_Creation__c || newCase.Case_Reopen_Flag__c){
                                    // Create Second SLA Task
                                    scu.createSlaTasks(newCase.Id, newCase.OwnerId, 'SLA-2 Customer Response Task', 'SLA-2 Social Post Customer Response', 'SLA - 2', true);
                                } 
                                // Create Second SLA Event
                                scu.createSlaEvents(newCase, newCase.OwnerId, assignmentTime, 'SLA - 2');
                                // Reset the Flags
                                //newCase.Customer_Response_Received__c = false;  //DNR: commenting out to avoid unchecking when assigning it to owner from queue.
                                newCase.Pending_Second_SLA_Task_Creation__c = false;
                                newCase.Case_Reopen_Flag__c = false;
                            }
                        }
                        //Added condition to repopulated Case Assign Time when Case is asigned from queue to user post SLA 2 ends
                        if ('SLA2 - Ended'.equalsIgnorecase(newCase.Current_SLA_Phase__c) && newCase.Case_Reassigned_Time__c == null) {
                            if(newCase.Moved_to_Prior_Care_Manager__c == false){
                                newCase.Case_Reassigned_Time__c = dateTime.Now();
                                ReassignedCaseSet.Add(newCase);
                            }
                        } 
                        // Adding all Cases to one List for Update by setting field value not to execute before Update Trigger Code
                        updateCaseList.add(newCase);
                    }
                    // Calling method and passing the set of cases for which the record needs to be inserted for reassigned time
                    if(!ReassignedCaseSet.isEmpty()){
                    // to determine whether a case is assigned through Round Robin or Asign A Case
                        if(userInfo.getName() != 'Automated Admin'){
                             Social_markCaseUpdates.CaseReassignments(ReassignedCaseSet, Social_StreamingUtil.ASSIGN_A_CASE,Social_StreamingUtil.REASSIGNED);
                        } else {
                             Social_markCaseUpdates.CaseReassignments(ReassignedCaseSet, Social_StreamingUtil.ROUND_ROBIN,Social_StreamingUtil.REASSIGNED);
                        }     
                    }
                    if(!assignedCaseSet.isEmpty()){
                    // to determine whether a case is assigned through Round Robin or Asign A Case
                        if(userInfo.getName() != 'Automated Admin'){
                             Social_markCaseUpdates.CaseReassignments(assignedCaseSet, Social_StreamingUtil.ASSIGN_A_CASE,Social_StreamingUtil.ASSIGNED);
                        } else {
                             Social_markCaseUpdates.CaseReassignments(assignedCaseSet, Social_StreamingUtil.ROUND_ROBIN,Social_StreamingUtil.ASSIGNED);
                        }     
                    }
                }
                Social_CaseAssignmentUtility.executeTriggerCode = false;
            }
            catch(Exception e){
                System.debug('Exception in Social_CaseAssignmentHandler.setCaseDetails ' + e.getmessage());
            }
        }
    } 
    
    public void updateCaseDetails(){
        //Update Case details
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        if(updateCaseList!=null && updateCaseList.size() > 0){
            try{
                update updateCaseList;
                scu.saveSLAEventsandTasks();
            }
            catch(Exception e){
                System.debug('Exception in Social_CaseAssignmentHandler.updateCaseDetails :: updateCaseList' + e.getmessage());
            }
        }
        //Update User Case Counter
        List<String> userIdList =  new List<String>();
        System.debug('Entered at line 481');
        if(careManagerMap!=null && !careManagerMap.isEmpty()){
            System.debug('Entered inside loop 1');
            userIdList.addAll(careManagerMap.keySet());
            if(userIdList!=null && userIdList.size() > 0){
                System.debug('Entered inside loop 2');
                List<User> userList = [Select u.Id From User u where u.IsActive = true and u.Id IN :userIdList];
                for(User u : userList){
                    u.Case_Counter__c = careManagerMap.get(u.id);
                    updateUserList.add(u);
                }
            }
        }
        if(updateUserList!=null && updateUserList.size()>0){
            try{
                update updateUserList;
            }
            catch(Exception e){
                System.debug('Exception in Social_CaseAssignmentHandler.updateCaseDetails :: updateUserList' + e.getmessage());
            }
        }
        if(null!=careManagerAssignCaseMap && !careManagerAssignCaseMap.isEmpty()){
            List<User> userList = [Select id, Case_Counter__c from User where id IN: careManagerAssignCaseMap.keySet()];
            if(null!=userList && userList.size()>0){
                List<User> newUserList =  new List<User>();
                Integer caseCounter = 0;
                for(User u: userList){
                    System.debug('Here user id : '+u.id+ ' u.Case_Counter__c: '+u.Case_Counter__c + ' careManagerAssignCaseMap.get(u.id) : '+careManagerAssignCaseMap.get(u.id));
                    caseCounter  = Integer.valueOf(u.Case_Counter__c);
                    caseCounter = caseCounter + careManagerAssignCaseMap.get(u.id);
                    u.Case_Counter__c = caseCounter;
                    System.debug('caseCounter Counter value: '+caseCounter);
                    System.debug('u.Case_Counter__c Counter value: '+u.Case_Counter__c);
                    newUserList.add(u);
                }
                System.debug('List size at line 528 : '+newUserList.size());
                if(null!=newUserList && newUserList.size()>0){
                System.debug('newUserList size :'+newUserList.size());
                    try{
                        update newUserList;
                    }
                    catch(Exception e){
                        System.debug('Error in update method');
                    }
                } 
            }
        }
        if(careManagerDetailsList!=null && careManagerDetailsList.size() > 0){
            try{
                update careManagerDetailsList;
            }
            catch(Exception e){
                System.debug('Exception in Social_CaseAssignmentHandler.updateCaseDetails :: careManagerDetailsList' + e.getmessage());
            }
        }
    }
    public void captureCareManagerDetails(Map<String, Integer> careMap){
        if(null!=careMap && !careMap.isEmpty()){
            List<Care_Manager_Availability__c> careManagerList =  new List<Care_Manager_Availability__c>();
            for(String s: careMap.KeySet()){
                Care_Manager_Availability__c cm =  new Care_Manager_Availability__c();
                cm.Care_Manager__c = s;
                cm.Case_Counter__c = careMap.get(s);
                cm.Captured_Time__c = dateTime.now();
                careManagerList.add(cm);
            }
            if(null!=careManagerList && careManagerList.size()>0){
                try{
                    insert careManagerList;
                }
                catch(Exception e){
                    System.debug('Error : '+e.getMessage());
                }
            }
        }
        
    }
}