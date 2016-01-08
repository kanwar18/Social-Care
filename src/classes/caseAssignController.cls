public class caseAssignController {

    public String groupName {get; set;}
    public String numberOfCasesToBeAssigned {get;set;}
    public String strMessage{get;set;}
    public boolean FIFO {get;set;}
    public List<String> groupids = new List<String>();
    public List<string> groupnames=new list<string>();
    public  List<Case> casesToBeAssignedList = new List<Case>();
    public caseAssignController (){
    
        FIFO = true;
    }
    public void toggleFifo(){
    
        if(FIFO){
            FIFO = false;
        }else{
            FIFO = true;
        }
    }
    public List<SelectOption> getAssociatedGroupNames() {
        List<SelectOption> optionsList = new List<SelectOption>();
        List<Assignment_Groups__c> assignmentGroupsList = [Select a.User__c, a.Group_Name__r.Name, a.Group_Name__r.Id From Assignment_Groups__c a where  a.User__r.Id=: UserInfo.getUserId()];
        if(!Util.isCollectionEmpty(assignmentGroupsList, 'List')){
            Map<String, String> uniqueRecordsMap =  new Map<String, String>();
            for(Assignment_Groups__c ag: assignmentGroupsList){
                if(null!=uniqueRecordsMap && !uniqueRecordsMap.containsKey(ag.Group_Name__r.Id)){
                    optionsList.add(new SelectOption(ag.Group_Name__r.Name, ag.Group_Name__r.Name));
                    uniqueRecordsMap.put(ag.Group_Name__r.Id, ag.Group_Name__r.Id);
                    groupnames.add(ag.Group_Name__r.Name);
                }
            }
        }
        return optionsList;   
    }
  public List<SelectOption> getNumberOfCases(){
        List<SelectOption> optionsList = new List<SelectOption>();
        String strLabelValue = System.Label.Assign_a_Case;
        if(strLabelValue!=null && !strLabelValue.equals('')){
            List<String> strList = new List<String>();
            strList.addAll(strLabelValue.split(','));
            Map<String, String> uniqueRecordsMap =  new Map<String, String>();
            for(String strValue: strList){
                if(null!=uniqueRecordsMap && !uniqueRecordsMap.containsKey(strValue)){
                    optionsList.add(new SelectOption(strValue, strValue));
                    uniqueRecordsMap.put(strValue, strValue);
                }
            }
        }
        return optionsList;
    }
    private Integer getCareManagerCaseCounter(String strUserId){
        Integer counter =0;
        List<User> userList = [Select Case_Counter__c from User where id=: strUserId];
        if(!Util.isCollectionEmpty(userList, 'List')){
            counter = Integer.ValueOf(userList.get(0).Case_Counter__c);
        }
        return counter;
    }
    public PageReference assignCase() {
        if((FIFO || (null!=groupName && !groupName.equals(''))) && null!=numberOfCasesToBeAssigned && !numberOfCasesToBeAssigned.equals('') && null!=UserInfo.getUserId()){
            Integer caseCapCounter = Integer.ValueOf(System.Label.Case_Cap_Counter);
            Integer careManagerCounter = getCareManagerCaseCounter(UserInfo.getUserId());
            String strQueueId = '';
            List<Case> casesToBeAssignedTempList = new List<Case>();
            if(FIFO){
                for(Assignment_Group_Queues__c agq:[Select a.QueueId__c, a.Name From Assignment_Group_Queues__c a where a.Name=:groupnames and a.Active__c = 'TRUE']){
                    groupids.add(agq.QueueId__c);
                }
            
                casesToBeAssignedTempList = Util.getListofCasesToBeAssigned(Integer.ValueOf(numberOfCasesToBeAssigned), groupids); 
            }
            else if(!FIFO && null!=groupName && !groupName.equals('')){
                
                List<Assignment_Group_Queues__c> agQueueList = [Select a.QueueId__c, a.Name From Assignment_Group_Queues__c a where a.Name=: groupName];
                groupids.clear();
                if(!Util.isCollectionEmpty(agQueueList, 'List')){
                    groupids.add(agQueueList[0].QueueId__c);
                }
                casesToBeAssignedTempList = Util.getListofCasesToBeAssigned(Integer.ValueOf(numberOfCasesToBeAssigned), groupids); 
            }
            if(!Util.isCollectionEmpty(casesToBeAssignedTempList, 'List')){
                casesToBeAssignedList.clear();
                if(casesToBeAssignedTempList.size()>= Integer.ValueOf(numberOfCasesToBeAssigned)){
                    for(integer i=0; i<(Integer.ValueOf(numberOfCasesToBeAssigned)) ;i++){
                        casesToBeAssignedList.add(casesToBeAssignedTempList[i]);
                    }
                }
                else{
                        casesToBeAssignedList.addAll(casesToBeAssignedTempList);
                }    
                Social_RoundRobinCaseAssignmentHandler rhandler =  new Social_RoundRobinCaseAssignmentHandler();
                Map<Id,Id> caseMap =  new Map<Id,Id>();
                if(casesToBeAssignedList!=null && casesToBeAssignedList.size()>0){
                    integer count = 0;
                    integer assignedCaseCount = 0;
                    for(Case c : casestobeAssignedList){
                        count++; 
                        
                        if((careManagerCounter + count)<=caseCapCounter){
                            caseMap.put(c.id, UserInfo.getUserId());
                            rhandler.incrementCareManagerCounter(UserInfo.getUserId()); 
                            assignedCaseCount = assignedCaseCount + 1;
                            strMessage = 'Requested Cases: '+Integer.ValueOf(numberOfCasesToBeAssigned) + '<br></br>Assigned Cases: '+assignedCaseCount;
                        }
                        else{
                            strMessage = 'Note: Please check your case counter';
                        }
                    }
                }
                if(caseMap!=null && !caseMap.isEmpty()){
                    rhandler.setCaseDetails(caseMap, true, false); 
                    try{                
                        rhandler.updateCaseDetails();
                        updateCareManagerLastAssignmentDetails(groupName, UserInfo.getUserId());
                    }
                    catch(Exception e){
                        System.debug('Error in assignCasetoCareManagers '+e.getMessage());                
                    }     
                }   
            }
            else if(Util.isCollectionEmpty(casesToBeAssignedTempList, 'List')){
                strMessage = 'Requested Cases: '+Integer.ValueOf(numberOfCasesToBeAssigned) + '<br></br>Assigned Cases: 0';
            }
        }
    return null;
    }
    private void updateCareManagerLastAssignmentDetails(String strGroupName, String strUserId){
        List<Assignment_Groups__c> assignmentGroupsList =  [Select a.User__c, a.Millisecond__c, a.Last_Assignment__c, a.Group_Name__r.Name, a.Active__c From Assignment_Groups__c a where a.Active__c = 'True' and a.Group_Name__r.Name =: strGroupName and a.User__c =: strUserId ];
        if(!Util.isCollectionEmpty(assignmentGroupsList , 'List')){
            List<Assignment_Groups__c> assignmentGroupsTempList =  new List<Assignment_Groups__c>();
            for(Assignment_Groups__c ag: assignmentGroupsList){
                datetime assignmentTime = datetime.now();
                ag.Last_Assignment__c = assignmentTime;
                ag.Millisecond__c = assignmentTime.millisecondGMT();
                assignmentGroupsTempList.add(ag);
            }
            if(!Util.isCollectionEmpty(assignmentGroupsTempList, 'List')){
                try{
                    update assignmentGroupsTempList;
                }
                catch(Exception e){
                    System.debug('Error in updateCareManagerLastAssignmentDetails method '+e.getMessage());
                }
            }
        }
    }
}