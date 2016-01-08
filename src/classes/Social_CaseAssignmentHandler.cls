/**
* Handler Class for Round Robin Case Assignment
*
*/

public class Social_CaseAssignmentHandler {
    
    public List<Case> testCaseList{get;set;} 
    public List<Case> businessHourCaseList{get;set;} 
    public List<Case> nonbusinessHourCaseList{get;set;} 
    public List<Case> highInfluencerCaseList{get;set;} 
    public String strTemp{get;set;} 
    public String strGMTDate {get;set;}
    public String strCSTDate {get;set;}
    public Map<String, Integer> currentExecutionMap;
    private Map<String, List<Assignment_Groups__c>> assignmentGroupsMap;
    private Map<String, Integer> careManagerMap;
    private List<Case> updateCaseList =  new List<Case>();
    private List<Task> insertTaskList =  new List<Task>();
    private List<User> updateUserList =  new List<User>();
    private List<Id> highInfulencerIdList =  new List<Id>();
    Set<Case> ReassignedCaseSet = new Set<Case>();
    Set<Case> assignedCaseSet = new Set<Case>();
    Social_CaseUtility scu;
    
    public Map<String, Integer> getCurrentExecutionMap(){
        return currentExecutionMap;
    }
    public void setCurrentExecutionMap(){
        if(currentExecutionMap!=null){
            currentExecutionMap.clear();
        }
    }
    
    
    public Social_CaseAssignmentHandler(){
        
        //List<Case> updateCaseList =  new List<Case>();
        assignmentGroupsMap = new Map<String, List<Assignment_Groups__c>>();
        careManagerMap = new Map<String, Integer>();
        currentExecutionMap =  new Map<String, Integer>();
        scu =  new Social_CaseUtility();

        //Calling the getOrderedListofCases() method from VF page
        if(ApexPages.currentPage()!=null && ApexPages.currentPage().getParameters()!=null && ApexPages.currentPage().getParameters().get('view')!=null && ApexPages.currentPage().getParameters().get('view').equalsIgnoreCase('browser')){
            testCaseList = getOrderedListofCases();
        }
    }
    /**
        Method to get all the Queues configured in the Assignemnt Groups
    */
    private List<Id> getAssociatedQueues(){
        List<Id> assignmentGroupQueueIdList =  new List<Id>();
        try{
            List<Assignment_Group_Queues__c> listAssignmentGroup = [Select a.QueueId__c, a.Name, a.Id, a.Assignment_Group_Name__c, a.Assignment_Group_Name__r.Name, a.Active__c From 
                                    Assignment_Group_Queues__c a where Active__c = 'True'];
            if(listAssignmentGroup!=null && listAssignmentGroup.size()>0){
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

    /**
        Method returns "Influencer High" type of Cases 
    */
    private List<Case> getHighInfluencerOrderedCasesfromQueue(){
        List<Case> highInfluencerOrderedCaseList = new List<Case>();
        List<Id> queueIdList = getAssociatedQueues();      
        try{

            List<Case> tempcaseList =  new List<Case>();
            if(highInfulencerIdList!=null && highInfulencerIdList.size()>0){
                tempcaseList = [Select c.OwnerId, c.Id, c.mergedDate__c, c.Status, c.priority From Case c where c.Id in : highInfulencerIdList and c.status <> 'Closed' and c.status <> 'Auto Closed' and c.ownerId in : queueIdList order by c.mergedDate__c asc];
            }
            if(tempcaseList!=null && tempcaseList.size() > 0){
                for(Case c : tempcaseList){
                    Case newCase = new Case();
                    newCase.id = c.Id;                
                    newCase.OwnerId = c.OwnerId;
                    newCase.TempDate__c = Datetime.Valueof(c.mergedDate__c.format('yyyy-MM-dd HH:mm:ss', 'CST')); 
                    newCase.Status = c.Status;
                    newCase.Priority = c.priority;  
                    highInfluencerOrderedCaseList.add(newCase);
                }
            }   
            
        }
        catch(Exception e){
            System.debug(' Error in Social_CaseAssignmentHandler.getHighInfluencerOrderedCasesfromQueue '+e.getMessage());
        }
        return highInfluencerOrderedCaseList;
    }
    /*
    
    Method returns the sorted and ordered list of cases
    */
    private List<Case> getListofCases(){ 
        List<Case> resultsetcaseList = new List<Case>();
        List<Case> caseList = new List<Case>();
        List<Id> queueIdList = getAssociatedQueues();
        try{
      List<Case> caseIdList = new List<Case>();
      caseIdList = [Select c.id from Case c where c.status <> 'Closed' and c.status <> 'Auto Closed' and c.ownerId IN: queueIdList];

      List<SocialPost> highInfluencerSocialPostList = new List<SocialPost>();
      if(caseIdList!=null && caseIdList.size()>0){
        //highInfluencerCaseList = [Select c.R6Service__InitialPostId__r.R6Service__SourceTags__c, c.Id From Case c where c.Status <> 'Closed' and c.R6Service__InitialPostId__r.R6Service__SourceTags__c = 'Influencer High' and c.R6Service__InitialPostId__r.ParentId IN: caseIdList];
        highInfluencerSocialPostList = [Select s.R6Service__SourceTags__c, s.ParentId From SocialPost s where s.R6Service__IsOutbound__c = FALSE and s.IsDeleted = FALSE and s.ParentId IN: caseIdList];
      }
            //System.debug('Here highInfluencerSocialPostList size : '+highInfluencerSocialPostList.size());
            if(highInfluencerSocialPostList!=null && highInfluencerSocialPostList.size()>0){
                for(SocialPost sp : highInfluencerSocialPostList){
                    if(sp.ParentId!=null && sp.R6Service__SourceTags__c !=null && !(sp.R6Service__SourceTags__c).equals('') && (sp.R6Service__SourceTags__c).equals('Influencer High')){
                        highInfulencerIdList.add(sp.ParentId);
                    }
                }
                //System.debug('highInfulencerIdList.size : '+highInfulencerIdList.size());
            }
            String businessrectypeid=Label.Business_Care_Case_Record_Type_ID;
            resultsetcaseList = [Select c.OwnerId, c.Id, c.mergedDate__c, c.Status, c.priority From Case c where c.status <> 'Closed' and c.status <> 'Auto Closed' and c.id NOT IN :highInfulencerIdList and c.ownerId in : queueIdList and recordtypeid!=:businessrectypeid order by c.mergedDate__c, c.priority asc];
            //System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>'+resultsetcaseList.size());
            Map<String, List<Case>> caseListMap = new Map<String, List<Case>>();
            if(resultsetcaseList!=null && resultsetcaseList.size() >0){
                 
                for(Case c : resultsetcaseList){
                    if(caseListMap.containsKey(String.Valueof(c.mergedDate__c.Date()))){
                        //System.debug('Entered If loop '+String.Valueof(c.mergedDate__c.Date()));
                        List<Case> tempCaseList = new List<Case>();
                        tempCaseList = caseListMap.get(String.Valueof(c.mergedDate__c.Date()));
                        Case cObj = new Case();
                        cObj.Id = c.id;
                        cObj.OwnerId = c.OwnerId;
                        cObj.priority = c.priority;
                        cObj.TempDate__c = c.mergedDate__c;
                        cObj.Status = c.Status;
                        tempCaseList.add(cObj);
                        //System.debug('tempCaseList size in If loop before sort : '+tempCaseList.size());
                        //tempCaseList = sortList(tempCaseList, 'priority', 'asc');
                        //System.debug('tempCaseList size in If loop after sort : '+tempCaseList.size());
                        caseListMap.put(String.Valueof(c.mergedDate__c.Date()), tempCaseList);
                    }
                    else{
                        //System.debug('Entered Else loop '+String.Valueof(c.mergedDate__c.Date()));
                        List<Case> tempCaseList = new List<Case>();
                        Case cObj = new Case();
                        cObj.Id = c.id;
                        cObj.OwnerId = c.OwnerId;
                        cObj.priority = c.priority;
                        cObj.TempDate__c = c.mergedDate__c;
                        cObj.Status = c.Status;
                        tempCaseList.add(cObj);
                        //System.debug('tempCaseList size in Else loop : '+tempCaseList.size());
                        caseListMap.put(String.Valueof(c.mergedDate__c.Date()), tempCaseList);
                    }
                }
                //System.debug('Finally Check here : '+tempCaseList.size());
                if(!caseListMap.isEmpty()){
                    List<String> caseDateList = new List<String>();
                    caseDateList.addAll(caseListMap.keySet());
                    caseDateList.sort();
                    //System.debug(':::::::::::::::::: Here caseDateList size :: '+caseDateList.size());
                    for(String strDate : caseDateList){
                        List<Case> tempCaseListNew = caseListMap.get(strDate);
                        //System.debug(' And here tempCaseList size: '+tempCaseListNew.size()+' on Date : '+strDate);
                        caseList.addAll(tempCaseListNew); 
                    }
                }
            }
            //System.debug('Finally caseList size  : '+caseList.size());
        }
        catch(Exception e){
            System.debug(' Error in getListofCases method '+e.getMessage());
        }
        return caseList;
    }
    
    /*
    Method returns the case list where in the cases are grouped based on Business hour, Non-business hour and 
    Influencer High type of Cases
    
    */
    public List<Case> getOrderedListofCases(){
        List<Case> returnCaseList =  new List<Case>(); 
        List<Case> caseList = new List<Case>();
        List<Case> highInfluencerCaseListNew = new List<Case>();
        businessHourCaseList = new List<Case>();
        nonbusinessHourCaseList = new List<Case>();
        highInfluencerCaseList =  new List<Case>();
         
        caseList = getListofCases(); 
        //System.debug('Here Size >>>>>getBusinessandNonBusinessHourCases :'+caseList.size());        
        
        
        if(caseList!=null && caseList.size() > 0){
            for(Case c : caseList){
                //System.debug('Date :'+c.TempDate__c+' Priority : '+c.priority+' Owner ID : '+c.OwnerId);
                Case cNew = new Case();
                cNew.TempDate__c =  Datetime.valueof(c.TempDate__c.format('yyyy-MM-dd HH:mm:ss', 'CST'));
                
                //System.debug('Here old datetime  : '+c.TempDate__c+' and new datetime : '+cNew.TempDate__c);
                //cNew.TempDate__c = c.TempDate__c;
                //strTemp = String.Valueof(cNew.TempDate__c);
                String strDayofWeek = '';
                Integer hour = 0;
                Integer minute = 0;
                if(cNew.TempDate__c!=null){
                    strDayofWeek = cNew.TempDate__c.format('EEEE');
                    hour = cNew.TempDate__c.Hour();
                    minute = cNew.TempDate__c.Minute();
                    
                    //System.debug('and here hour : '+hour);
                }
                Time newTime = Time.newInstance(hour, minute, 0, 0);               
                Time officestartTime = Time.newInstance(7,0,0,0);
                Time officeendTime = Time.newInstance(22,0,0,0);
                Time saturdayOfficeendTime = Time.newInstance(16,0,0,0);
                                
                //System.debug('strDayofWeek :'+strDayofWeek+' newTime :'+newTime+' officestartTime :'+officestartTime+' officeendTime '+officeendTime );
                if(strDayofWeek!=null && (strDayofWeek.equalsIgnoreCase('Monday') || strDayofWeek.equalsIgnoreCase('Tuesday') || strDayofWeek.equalsIgnoreCase('Wednesday') || strDayofWeek.equalsIgnoreCase('Thursday') || strDayofWeek.equalsIgnoreCase('Friday')) && newtime >= officestartTime && newtime <= officeendTime ){
                    //System.debug('Entered @ 1 === Weekday ');
                    cNew.id = c.Id;                    
                    cNew.OwnerId = c.OwnerId;
                    cNew.priority = c.priority;  
                    cNew.Status = c.Status;
                    businessHourCaseList.add(cNew);                   
                }
                else if(strDayofWeek!=null && strDayofWeek.equalsIgnoreCase('Saturday') && newtime >= officestartTime && newtime <= saturdayOfficeendTime){
                    //System.debug('Entered @ 2 === Saturday');
                    cNew.id = c.Id;                    
                    cNew.OwnerId = c.OwnerId;
                    cNew.priority = c.priority;    
                    cNew.Status = c.Status;
                    businessHourCaseList.add(cNew);                   
                }
                
                else if(strDayofWeek!=null && (strDayofWeek.equalsIgnoreCase('Monday') || strDayofWeek.equalsIgnoreCase('Tuesday') || strDayofWeek.equalsIgnoreCase('Wednesday') || strDayofWeek.equalsIgnoreCase('Thursday') || strDayofWeek.equalsIgnoreCase('Friday')) && (newtime > officeendTime || newtime < officestartTime) ){
                    //System.debug('Entered @ 3 '+strDayofWeek +' Hour : '+newtime);
                    cNew.id = c.Id;                    
                    cNew.OwnerId = c.OwnerId;
                    cNew.priority = c.priority;
                    cNew.Status = c.Status;
                    nonbusinessHourCaseList.add(cNew);                   
                }
                else if(strDayofWeek!=null && strDayofWeek.equalsIgnoreCase('Saturday') && newtime >= Time.newInstance(00,0,0,0) && newtime < officestartTime){
    
                    //System.debug('Entered @ 4.0 === Saturday non business hour ');
                    cNew.id = c.Id;                    
                    cNew.OwnerId = c.OwnerId;
                    cNew.priority = c.priority;
                    cNew.Status = c.Status;                                    
                    nonbusinessHourCaseList.add(cNew);                   
                }
                
                else if(strDayofWeek!=null && strDayofWeek.equalsIgnoreCase('Saturday') && newtime >= saturdayOfficeendTime && newtime < Time.newInstance(00,0,0,0)){
    
                    //System.debug('Entered @ 4.1 === Saturday non business hour ');
                    cNew.id = c.Id;                    
                    cNew.OwnerId = c.OwnerId;
                    cNew.priority = c.priority;
                    cNew.Status = c.Status;                                    
                    nonbusinessHourCaseList.add(cNew);                   
                }
                else if(strDayofWeek!=null && strDayofWeek.equalsIgnoreCase('Sunday')){
                    //System.debug('Entered @ 5 === Sunday');
                    cNew.id = c.Id;                    
                    cNew.OwnerId = c.OwnerId;
                    cNew.priority = c.priority;
                    cNew.Status = c.Status;                                     
                    nonbusinessHourCaseList.add(cNew);                   
                }
                else if(strDayofWeek!=null && strDayofWeek.equalsIgnoreCase('Monday') && newTime > Time.newInstance(0,0,0,0) && newTime < officestartTime){
                    //System.debug('Entered @ 6 === Monday non business hours');
                    cNew.id = c.Id;                    
                    cNew.OwnerId = c.OwnerId;
                    cNew.priority = c.priority;
                    cNew.Status = c.Status;
                    nonbusinessHourCaseList.add(cNew);                   
                }
                else{
                    //System.debug('Entered @ final non business hour loop hours');
                    cNew.id = c.Id;                    
                    cNew.OwnerId = c.OwnerId;
                    cNew.priority = c.priority;
                    cNew.Status = c.Status;
                    nonbusinessHourCaseList.add(cNew);                   
                }               
            }
        }
        //System.debug('Here at new position : highInfluencerCaseListNew size : '+highInfluencerCaseListNew.size()+' businessHourCaseList size:'+businessHourCaseList.size()+' NBH :'+nonbusinessHourCaseList.size());        
        highInfluencerCaseListNew = getHighInfluencerOrderedCasesfromQueue();
        if(highInfluencerCaseListNew!=null && highInfluencerCaseListNew.size()>0){
            returnCaseList.addAll(highInfluencerCaseListNew);
            highInfluencerCaseList.addAll(highInfluencerCaseListNew);          
        }
        if(businessHourCaseList!=null && businessHourCaseList.size()>0){
            returnCaseList.addAll(businessHourCaseList);            
        }
        if(nonbusinessHourCaseList!=null && nonbusinessHourCaseList.size()>0){
            returnCaseList.addAll(nonbusinessHourCaseList);            
        }    
        //System.debug('Here size :::: @@ 1 '+returnCaseList.size());    
        return returnCaseList;
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
        Method returns the available Care Managers 
    */
    public void preloadCareManagers(){

        List<Assignment_Group_Queues__c> agGroupQueueList = [Select a.QueueId__c, a.Assignment_Group_Name__c From Assignment_Group_Queues__c a where a.Active__c = 'True'];
        if(agGroupQueueList!=null && agGroupQueueList.size()>0){
            List<Assignment_Groups__c> agGroupUserList = new List<Assignment_Groups__c>();
            Map<ID, ID> assignmentGroupQueueMap = new Map<ID, ID>();
            for(Assignment_Group_Queues__c agQueues : agGroupQueueList){
                if(agQueues.QueueId__c!=null && !agQueues.QueueId__c.equals('')){
                    assignmentGroupQueueMap.put(agQueues.QueueId__c, agQueues.Assignment_Group_Name__c);
                }
            }
            //List<ID> queueIdList =  new List<ID>();
            if(assignmentGroupQueueMap!=null && !assignmentGroupQueueMap.isEmpty()){
                agGroupUserList = [SELECT Group_Name__c, Group_Name__r.Name, User__r.Username, User__c, Last_Assignment__c, Millisecond__c, User_Availability__c FROM Assignment_Groups__c where Group_Name__c in : assignmentGroupQueueMap.values() and User_Availability__c = 'Available' ORDER BY Last_Assignment__c, Millisecond__c];
                //System.debug('agGroupUserList size here : '+agGroupUserList.size());
                List<ID> careManagerIdList = new List<ID>();
                if(agGroupUserList!=null && agGroupUserList.size()>0){
                    for (Id id : assignmentGroupQueueMap.keySet()){
                        List<Assignment_Groups__c> agGroupUserListNew =  new List<Assignment_Groups__c>();
                        for(Assignment_Groups__c assignmentGroups : agGroupUserList){
                            
                            if(assignmentGroups.Group_Name__c!=null && String.ValueOf(assignmentGroups.Group_Name__c).equalsIgnoreCase(String.ValueOf(assignmentGroupQueueMap.get(id)))){
                                agGroupUserListNew.add(assignmentGroups);
                            }
                            /*
                            if(assignmentGroups.User__c!=null){
                                careManagerIdList.add(assignmentGroups.User__c);
                                System.debug(' #1'+careManagerIdList.size());
                            }*/
                        }
                        assignmentGroupsMap.put(id, agGroupUserListNew);
                    }
                    for(Assignment_Groups__c assignmentGroups : agGroupUserList){
                        if(assignmentGroups.User__c!=null){
                            careManagerIdList.add(assignmentGroups.User__c);
                        }
                    }
                    //System.debug(' #Number of available Care Managers : '+careManagerIdList.size());
                }
                if(careManagerIdList!=null && careManagerIdList.size() > 0){
                    System.debug('Care Manager ID List Value here @ 1 : '+careManagerIdList.size());
                   // List<AggregateResult> resultList = [Select c.OwnerId, count(c.id) From Case c where c.OwnerId IN :careManagerIdList and c.status <> 'Closed' and c.status <> 'Follow Up Hold' and c.status <> 'Escalated' group by c.OwnerId];
                    List<AggregateResult> resultList = [Select c.OwnerId, count(c.id) From Case c where c.OwnerId IN :careManagerIdList and (c.status = 'New' OR c.status = 'Reassigned' OR c.status = 'Reopen' OR c.status = 'Investigating' OR c.status = 'Escalated') group by c.OwnerId]; 
                    for(AggregateResult ar : resultList){
                        if(ar!=null && ar.get('OwnerId')!=null && !careManagerMap.containsKey(String.Valueof(ar.get('OwnerId'))) && ar.get('expr0')!=null ){
                            System.debug('Here Care Manager ID : '+String.Valueof(ar.get('OwnerId'))+' and Case count : '+Integer.valueOf(ar.get('expr0')));
                            careManagerMap.put(String.Valueof(ar.get('OwnerId')), Integer.valueOf(ar.get('expr0')));
                        }
                    }
                    for(String strId : careManagerIdList){
                        if(careManagerMap!=null && !careManagerMap.containsKey(strId)){
                            careManagerMap.put(strId, 0);
                        }
                    }
                    /*
                    List<User> careManagerList = [Select u.Id, u.Case_Counter__c, u.name From User u where u.IsActive = true and u.Id IN : careManagerIdList];
                    if(careManagerList!=null && careManagerList.size() > 0){
                        for(User careManager : careManagerList){
                            if(careManager!=null && !careManagerMap.containsKey(careManager.Id)){
                                System.debug(' Here CM ID ::::::::::::::::::::::::::::::::'+careManager.Id);
                                careManagerMap.put(careManager.Id, Integer.valueOf(careManager.Case_Counter__c));
                            }
                        }
                    }
                    */
                }
            }
        }
    }
    public String getAvailableCaseManagerfromQueue(Id queueId){
        String careManagerId = ''; 
        List<Assignment_Groups__c> agGroupUserList = new List<Assignment_Groups__c>();
        boolean assignToThisUser = false;
        //Map<String, Integer> currentExecutionMap = new Map<String, Integer>();
        //try{
            if(queueId!=null){
                
                if(assignmentGroupsMap!=null && !assignmentGroupsMap.isEmpty()){
                    
                    agGroupUserList = assignmentGroupsMap.get(queueId);
                    
                    if(agGroupUserList!=null && agGroupUserList.size() > 0){
                        //System.debug('Here agGroupUserList size : '+agGroupUserList.size());
                        
                        for(Assignment_Groups__c ag : agGroupUserList){
                            if(ag.User__c!=null){
                                //System.debug('Here User : '+ag.User__c);

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
                                
                                System.debug(' assignToThisUser :'+assignToThisUser);
                                if(cmcaseCounter!=null && cmcaseCounter < Integer.valueOf(System.label.Case_Cap_Counter) && assignToThisUser){
                                    System.debug('Entered here in this loop ::::::');
                                    careManagerId = ag.User__c;
                                    
                                    Integer currentCounterValue = 0; 
                                    if(currentExecutionMap!=null && !currentExecutionMap.containsKey(ag.User__c)){
                                        System.debug('Entered Loop for Insert');
                                        //insert
                                        currentCounterValue = currentCounterValue + 1;
                                        currentExecutionMap.put(ag.User__c, currentCounterValue);
                                    }
                                    else{
                                        System.debug('Entered Loop for Update @ 1');
                                        //update counter
                                        if(currentExecutionMap!=null){
                                            System.debug('Entered Loop for Update @ 2');
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
        //}
        //catch(Exception e){
            //System.debug();
        //}
        
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
        Care Manager counter update method
    */
    public void incrementCareManagerCounter(Id userId){
        if(userId!=null && careManagerMap!=null && !careManagerMap.isEmpty()){
            Integer caseCounterforCareManager = careManagerMap.get(userId);
            System.debug('Counter before update : '+caseCounterforCareManager);
            caseCounterforCareManager = caseCounterforCareManager + 1;
            System.debug('Counter after update : '+caseCounterforCareManager+' and user Id : '+userId);
            careManagerMap.put(userId, caseCounterforCareManager);
        }
    
        /*
        if(userId!=null && careManagerMap!=null && !careManagerMap.isEmpty()){
            Integer caseCounterforCareManager = careManagerMap.get(userId);
            caseCounterforCareManager = caseCounterforCareManager + 1;
            careManagerMap.put(userId, caseCounterforCareManager);
        }*/
    }
    // SLA Event Util Class
      
    public void setCaseDetails(Map<Id, Id> caseMap, boolean selfAssignment){
        
        if(caseMap!=null && !caseMap.isEmpty()){
            try{
                List<Case> finalCaseList = [Select c.recordTypeID, c.OwnerId, c.Id, c.Track_Case_Queue__c, c.Current_SLA_Phase__c, c.CaseNumber, c.First_SLA_Scheduled_Time__c, c.Case_Assigned_Time__c,c.Moved_to_Prior_Care_Manager__c,c.Case_Reassigned_Time__c, c.Status, c.Customer_Response_Received__c, c.Assigned_Operation_Manager__c, c.Pending_Second_SLA_Task_Creation__c, c.Case_Reopen_Flag__c, c.Second_SLA_Pending_Post__c from Case c where c.id in : caseMap.KeySet()];
                //Get the case 
                //Case newCase = [Select c.OwnerId, c.Id, c.Current_SLA_Phase__c, c.CaseNumber, c.First_SLA_Scheduled_Time__c, c.Case_Assigned_Time__c, c.Status, c.Customer_Response_Received__c, c.Assigned_Operation_Manager__c, c.Pending_Second_SLA_Task_Creation__c, c.Case_Reopen_Flag__c, c.Second_SLA_Pending_Post__c from Case c where c.id =:caseId limit 1];
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
                            System.debug('Entered loop for and Track_Case_Queue__c loaded with '+newCase.OwnerId);                          
                            newCase.Track_Case_Queue__c = newCase.OwnerId;
                            
                        } 
                        newCase.OwnerId = caremanagerId;
                        newCase.NonCaseOwner_LastModifiedDate__c = system.now();
                        if(selfAssignment!=null && selfAssignment){
                          newCase.Update_Reason__c = 'Availability Assignment';
                          
                        }
                        else if(selfAssignment!=null && !selfAssignment){
                          if(newCase.Moved_to_Prior_Care_Manager__c == false){
                              newCase.Update_Reason__c = 'Case Assigned';
                          } 
                        }
                        newCase.ReadUnreadCheck__c = true;
                        if(userInfo.getName()!=null && (userInfo.getName()).equalsIgnoreCase('Automated Admin')){
                            newCase.Round_Robin_Assignment__c = true;
                            newCase.Round_Robin_Case_Assignment_Time__c = datetime.now();
                            newCase.Instant_Assignment__c = false;
                        }
                        else if(userInfo.getName()!=null && (userInfo.getUserId()).contains(newCase.OwnerId)){
                            newCase.Instant_Assignment__c = true;
                            newCase.Instant_Assignment_Time__c = datetime.now();
                            newCase.Round_Robin_Assignment__c = false;
                             
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
                        if(newCase.First_SLA_Scheduled_Time__c==null ){       
                            scu.createSlaEvents(newCase, caremanagerId, assignmentTime, 'SLA - 1');
        
                            // Update SLA on Case
                            newCase.Current_SLA_Phase__c = 'SLA1 - Initiated';
                            // populate case assign time on first assignment
                            if(newCase.Case_Assigned_Time__c==null){
                                newCase.Case_Assigned_Time__c = assignmentTime;
                                newCase.Customer_Response_Received__c = true; //DNR: added for availability assignment.
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
                            if(newCase.Moved_to_Prior_Care_Manager__c == false){
                                newCase.Case_Reassigned_Time__c = datetime.now();
                            }
                            ReassignedCaseSet.add(newCase);
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
                                newCase.Pending_Second_SLA_Task_Creation__c = false;
                                newCase.Case_Reopen_Flag__c = false;
                            }
                        }
                        //Added condition to repopulated Case Assign Time when Case is asigned from queue to user post SLA 2 ends
                        if ('SLA2 - Ended'.equalsIgnorecase(newCase.Current_SLA_Phase__c) && newCase.Case_Reassigned_Time__c == null) {
                            if(newCase.Moved_to_Prior_Care_Manager__c == false){
                                newCase.Case_Reassigned_Time__c = dateTime.Now();
                            }
                            ReassignedCaseSet.add(newCase);
                        }
                        // Adding all Cases to one List for Update by setting field value not to execute before Update Trigger Code
                        updateCaseList.add(newCase);
                    }
                    // Calling method and passing the set of cases for which the record needs to be inserted for reassigned time
                    if(!ReassignedCaseSet.isEmpty()){
                        Social_markCaseUpdates.CaseReassignments(ReassignedCaseSet,Social_StreamingUtil.INSTANT_ASSIGNMENT,Social_StreamingUtil.REASSIGNED);
                    }
                    if(!assignedCaseSet.isEmpty()){
                        Social_markCaseUpdates.CaseReassignments(assignedCaseSet,Social_StreamingUtil.INSTANT_ASSIGNMENT,Social_StreamingUtil.ASSIGNED);
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
        if(careManagerMap!=null && !careManagerMap.isEmpty()){
            userIdList.addAll(careManagerMap.keySet());
            if(userIdList!=null && userIdList.size() > 0){
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
        if(careManagerDetailsList!=null && careManagerDetailsList.size() > 0){
            try{
                update careManagerDetailsList;
            }
            catch(Exception e){
                System.debug('Exception in Social_CaseAssignmentHandler.updateCaseDetails :: careManagerDetailsList' + e.getmessage());
            }
        }
    }
}