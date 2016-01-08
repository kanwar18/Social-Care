public class assignACaseControllerBCS{
    public String groupName {get; set;}
    public String numberOfCasesToBeAssigned {get;set;}
    public String strMessage{get;set;}
    public List<String> groupids = new List<String>();
    public List<string> groupnames = new list<string>();
    public List<Case> casesToBeAssignedList = new List<Case>();
    public static Set<Id> slaDupeCaseIdSet = new Set<Id>();
    
    public assignACaseControllerBCS(){    
        strMessage = '';    
    }
    
    public List<SelectOption> getAssociatedGroupNames(){
        List<SelectOption> optionsList = new List<SelectOption>();        
        List<Assignment_Groups__c> assignmentGroupsList = [Select a.User__c, a.Group_Name__r.Name, a.Group_Name__r.Id, a.User_Availability__c, a.Cases_Owned__c From Assignment_Groups__c a where a.User__r.Id =: UserInfo.getUserId()];
        if(!Util.isCollectionEmpty(assignmentGroupsList, 'List')){
            Map<String,String> uniqueRecordsMap = new Map <String,String>();
            for(Assignment_Groups__c ag: assignmentGroupsList){
                if(null != uniqueRecordsMap && !uniqueRecordsMap.containsKey(ag.Group_Name__r.Id)){
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
    
    public Integer getCareManagerCaseCounter(String strUserId, String assignmentGrp){
        Integer counter =0;
        List<Assignment_Groups__c> userCaseCounterList = [Select a.User__c, a.Group_Name__r.Name, a.Group_Name__r.Id, a.User_Availability__c, a.Cases_Owned__c From Assignment_Groups__c a where a.User__r.Id =: strUserId AND a.Group_Name__r.Name =: assignmentGrp ];
        if(!Util.isCollectionEmpty(userCaseCounterList , 'List')){
            counter = Integer.ValueOf(userCaseCounterList.get(0).Cases_Owned__c);
        } 
      
        return counter;
    }
    
    public String getCareManagerAvailability(String strUserId, String assignmentGrp){
        String availability = '';
        List<Assignment_Groups__c> userAvailabilityList = [Select a.User__c, a.Group_Name__r.Name, a.Group_Name__r.Id, a.User_Availability__c, a.Cases_Owned__c From Assignment_Groups__c a where a.User__r.Id =: strUserId AND a.Group_Name__r.Name =: assignmentGrp ];
        if(!Util.isCollectionEmpty(userAvailabilityList, 'List')){
            availability = String.ValueOf(userAvailabilityList.get(0).User_Availability__c);
        } 
        
        return availability ;
    }
    
     public PageReference assignCase(){
         List<Case> updateCaseList = new List<Case>();
         List<Assignment_Groups__c> generalBcUsers = new List<Assignment_Groups__c>(); // List of General-bc assignment group users.
         List<Assignment_Groups__c> socialSalesUsers = new List<Assignment_Groups__c>();// List of Social Sales Lead assignment group users.
         String availabilityCM = getCareManagerAvailability(UserInfo.getUserId(),groupName);
         String grpName ;
         if(availabilityCM.equalsIgnoreCase('Available')){            
            if(((null!= groupName && !groupName.equals(''))) && null != numberOfCasesToBeAssigned && !numberOfCasesToBeAssigned.equals('') && null!= UserInfo.getUserId()){
            Integer caseCapCounterGenBC = Integer.ValueOf(System.Label.BUSINESS_CASE_OWNERSHIP_LIMIT);
            Integer caseCapCounterSSL = Integer.ValueOf(System.Label.SOCIAL_SALES_OWNERSHIP_LIMIT);
            Integer careManagerCounter = getCareManagerCaseCounter(UserInfo.getUserId(),groupName);
            
            String strQueueId = '';
            List<Case> casesToBeAssignedTempList = new List<Case>();            
            List<Assignment_Group_Queues__c> agQueueList = [Select a.QueueId__c, a.Name From Assignment_Group_Queues__c a where a.Name=: groupName];
            groupids.clear();
            if(!Util.isCollectionEmpty(agQueueList,'List')){
                groupids.add(agQueueList[0].QueueId__c);
            }
            
            casesToBeAssignedTempList = Util.getBCSListofCasesToBeAssigned(Integer.ValueOf(numberOfCasesToBeAssigned), groupids); 
            if(!Util.isCollectionEmpty(casesToBeAssignedTempList,'List')){
                casesToBeAssignedList.clear();
                if(casesToBeAssignedTempList.size() >= Integer.ValueOf(numberOfCasesToBeAssigned)){
                    for(integer i=0; i<(Integer.ValueOf(numberOfCasesToBeAssigned)) ;i++){
                        casesToBeAssignedList.add(casesToBeAssignedTempList[i]);
                    }
                }                      
                else{
                     casesToBeAssignedList.addAll(casesToBeAssignedTempList);
                    }             
               strMessage = 'Requested Cases: '+Integer.ValueOf(numberOfCasesToBeAssigned) + '<br></br>Assigned Cases: '+ casesToBeAssignedList.size();
                if(casesToBeAssignedList != null && casesToBeAssignedList.size()>0){
                    Integer count = 0;
                    Integer assignedCaseCount = 0;
                    Datetime slaScheduledTime = datetime.now();
                    Integer socialPostSLATimeframe = 15;
                    Integer emailSLATimeframe = 30;
                    Integer secondSLATimeframe = 60;
                    
                    for(Case caseUpdate : casestobeAssignedList){
                      caseUpdate.OwnerId = UserInfo.getUserId();
                      caseUpdate.Track_Case_Queue__c = groupids[0];
                      caseUpdate.Update_reason__c = Social_StreamingUtil.ASSIGN_A_CASE;                                       
                      Social_StreamingUtil.caseBizAssignedByAssignCase = TRUE ;
                      caseUpdate.BCS_Self_Assigned__c = TRUE ;                      
                      if(caseUpdate.Current_SLA_Phase__c == NULL){ 
                        caseUpdate.Case_Assigned_Time__c = System.now();                                  
                        caseUpdate.Current_SLA_Phase__c = 'SLA1 - Initiated';                                                                
                           if(caseUpdate.Origin=='Email Business (BizHelp)' || caseUpdate.Origin == 'Email Business (YouTube)'){                            
                                caseUpdate.First_SLA_Scheduled_Time__c = slaScheduledTime.addMinutes(emailSLATimeframe );
                            }
                            else{
                                caseUpdate.First_SLA_Scheduled_Time__c = slaScheduledTime.addMinutes(socialPostSLATimeframe );
                            }
                        }
                      else if(caseUpdate.Current_SLA_Phase__c == 'SLA1 - Ended'){             
                        caseUpdate.Current_SLA_Phase__c = 'SLA2 - Initiated';  
                        caseUpdate.Second_SLA_Start_Time__c = System.Now();
                        caseUpdate.Second_SLA_Scheduled_Time__c = slaScheduledTime.addMinutes(secondSLATimeframe);  
                      }
                      else{
                         slaDupeCaseIdSet.add(caseUpdate.Id);                  
                     }
                      
                      Social_StreamingUtil.skipTransaction.add(caseUpdate.Id);   
                      for(Assignment_Groups__c singleMember : [Select a.User__c,a.Name, a.Group_Name__r.Name, a.Group_Name__r.Id, a.User_Availability__c, a.Cases_Owned__c From Assignment_Groups__c a where a.User__r.Id =: UserInfo.getUserId() AND a.Group_Name__r.Name =: groupName ]){
                          if(caseUpdate.Status == 'New' || caseUpdate.Status == 'Reopen' || caseUpdate.Status == 'Investigating'){
                              singleMember.Cases_Owned__c  = singleMember.Cases_Owned__c +1;
                          }
                          singleMember.Last_Assignment__c = system.now();
                          grpName = singleMember.Name ;
                          update singleMember;
                      }
                      caseUpdate.Group_Member_Name__c = grpName ; 
                      updateCaseList.add(caseUpdate); 
                      Social_StreamingUtil.skipTransaction.add(caseUpdate.Id); 
                  }
                  
                 
                 reassignCaseSLAInitiation(casesToBeAssignedList ,UserInfo.getUserId());
                } 
              }            
           else{
                strMessage = 'Note: There are no cases in the queue for assignment';
                }  
         }   
         
         }
         else{
             strMessage = 'Note: Please mark yourself Available before assigning a case ';    
         } 
         if(updateCaseList.size()>0 ){
            Database.SaveResult[] resultDB = database.update(updateCaseList, false);
            try{
                Integer loopCount = 0;
                for(Database.SaveResult sr:resultDB)
                {                
                    if(!sr.isSuccess())
                    {                    
                        Database.Error err = sr.getErrors()[0];                            
                        System.debug('assignACaseControllerBCS: Error while updating case details. ' +updateCaseList.get(loopCount).getSObjectType() + err.getMessage());                                        
                    }
                    loopCount++;
                }
             }
             catch(Exception e){
                 System.debug('assignACaseControllerBCS: Error handling Response. ' + e.getMessage());                 
             }
         }        
         return null;
     }
     
     /**
    * < reassignCaseSLAInitiation() - Method to create SLA's for the cases which have been assigned to users.
    * @param:
    *     List<Case> slaInitiateCaseList - cases for which SLA's need to be created.
    *     Set<Id> caseOwnerIdSet - Id's of the owner of cases.  
    *
    * @return - void.
    * @see - SocialCaseReassignment(User trigger)
    */ 
    public static void reassignCaseSLAInitiation(List<Case> slaInitiateCaseList,Id caseOwnerId){      
        Map<Id,User> caseOwnerManagerMap = new Map<Id,User>(); //Map of case owners and corresponding managers    
        List<Event> eventSLAList = new List<Event>(); // List of Event SLA's
        List<Task> taskSLAList = new List<Task>(); //List of task SLA's        
        String eventDescription = 'First SLA Response Reminder';  
        String eventDescriptionSLA2 = 'Second SLA Response Reminder';  
        Integer timePeriod = 15;
        Integer emailSLATimePeriod = 30;
        Integer reminderTime = 12;
        String eventType = 'SLA - 1';
        Integer timePeriodSLA2 = 60;
        Integer reminderTimeSLA2 = 45;
        String eventTypeSLA2 = 'SLA - 2';
        Datetime assignmentTime = datetime.now();  
           
        for(User singleUser:[Select Id, Name, ManagerId from User where Id =: caseOwnerId]){
            caseOwnerManagerMap.put(singleUser.Id, singleUser);               
        }             
        
        for(Case caseSLAsingle: slaInitiateCaseList){  
            if(caseOwnerManagerMap.containsKey(caseSLAsingle.ownerId) && caseOwnerManagerMap.get(caseSLAsingle.ownerId)!= NULL){           
              if(!slaDupeCaseIdSet.contains(caseSLAsingle.Id)){ 
              Event careEvent = new Event();
              careEvent.WhatId = caseSLAsingle.Id;              
              careEvent.Event_Status__c = 'Open';
              careEvent.OwnerId = caseSLAsingle.OwnerId;              
              careEvent.StartDateTime = assignmentTime;
              careEvent.IsReminderSet = true;
              
              if(caseSLAsingle.Current_SLA_Phase__c == 'SLA1 - Initiated'){
                  careEvent.Description = eventDescription;
                  if(caseSLAsingle.Origin == 'Email Business (YouTube)' || caseSLAsingle.Origin == 'Email Business (BizHelp)'){
                      careEvent.DurationInMinutes = emailSLATimePeriod ;
                  }
                  else{
                       careEvent.DurationInMinutes = timePeriod;
                  }
                  careEvent.Event_Type__c = eventType;
                  careEvent.ReminderDateTime = assignmentTime.addMinutes(reminderTime);
                  careEvent.Subject = eventType + ':' + caseOwnerManagerMap.get(caseSLAsingle.OwnerId).Name + ':' + caseSLAsingle.CaseNumber;
              }
              
              if(caseSLAsingle.Current_SLA_Phase__c == 'SLA2 - Initiated'){
                  careEvent.Description = eventDescriptionSLA2;
                  careEvent.DurationInMinutes = timePeriodSLA2;
                  careEvent.Event_Type__c = eventTypeSLA2;
                  careEvent.ReminderDateTime = assignmentTime.addMinutes(reminderTimeSLA2);
                  careEvent.Subject = eventTypeSLA2 + ':' + caseOwnerManagerMap.get(caseSLAsingle.OwnerId).Name + ':' + caseSLAsingle.CaseNumber;
              }
                            
              eventSLAList.add(careEvent);
              
                  // Operation Manager Event
                  Event operationEvent = new Event();
                  operationEvent.WhatId = caseSLAsingle.Id;              
                  operationEvent.Event_Status__c = 'Open';
                  operationEvent.IsReminderSet = true;
                  operationEvent.OwnerId = caseOwnerManagerMap.get(caseSLAsingle.OwnerId).ManagerId;              
                  operationEvent.StartDateTime = assignmentTime;
                  if(caseSLAsingle.Current_SLA_Phase__c == 'SLA1 - Initiated'){
                      operationEvent.Description = eventDescription;
                      if(caseSLAsingle.Origin == 'Email Business (YouTube)' || caseSLAsingle.Origin == 'Email Business (BizHelp)'){
                          operationEvent.DurationInMinutes = emailSLATimePeriod ;
                      }
                      else{
                           operationEvent.DurationInMinutes = timePeriod;
                      }
                      operationEvent.Event_Type__c = eventType;
                      operationEvent.ReminderDateTime = assignmentTime.addMinutes(reminderTime);
                      operationEvent.Subject = eventType + ':' + caseOwnerManagerMap.get(caseSLAsingle.OwnerId).Name + ':' + caseSLAsingle.CaseNumber;
                  }
                   if(caseSLAsingle.Current_SLA_Phase__c == 'SLA2 - Initiated'){
                      operationEvent.Description = eventDescriptionSLA2;
                      operationEvent.DurationInMinutes = timePeriodSLA2;
                      operationEvent.Event_Type__c = eventTypeSLA2;
                      operationEvent.ReminderDateTime = assignmentTime.addMinutes(reminderTimeSLA2);
                      operationEvent.Subject = eventTypeSLA2 + ':' + caseOwnerManagerMap.get(caseSLAsingle.OwnerId).Name + ':' + caseSLAsingle.CaseNumber;
                  }
                    eventSLAList.add(operationEvent);   
              }
           }
        }
        
        if(eventSLAList.size()>0){
            Database.SaveResult[] resultDB = database.insert(eventSLAList, false);
            try{
                Integer loopCount = 0;
                for(Database.SaveResult sr:resultDB)
                {                
                    if(!sr.isSuccess())
                    {                    
                        Database.Error err = sr.getErrors()[0];                            
                        System.debug('assignACaseControllerBCS: Error while creating SLAs ' +eventSLAList.get(loopCount).getSObjectType() + err.getMessage());                
                    }
                    loopCount++;
                }
             }
             catch(Exception e){
                 System.debug('assignACaseControllerBCS: Error handling Response. ' + e.getMessage());
             }
        }       
    }
}