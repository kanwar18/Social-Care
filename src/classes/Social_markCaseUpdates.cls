/********************************************************************************************************
*    Author :     Accenture-Consumer
*    Requirement: Class to update case
*    Version:     1.0
*    Created Date: 20 June 2014.
*    Version: Aditya(15/July/2015) :ITS- 1651
*********************************************************************************************************/
Public class Social_markCaseUpdates {
    
   /**
    * < markCaseReasonIndicator() - Method to mark case reason indicator as true>
    * @param:
    *     case newCase - List of cases which need to be updated.        
    *     set<String>recordTypeIdSet - List of record type functionality should work for.
    *       
    * @return - void
    * @see - Social_validateCaseQueue (trigger)
    */

    public Static List<String> sendTo= new List<String>();
    
    public static void markCaseReasonIndicator(case newCase,set<String>recordTypeIdSet) {
        if (recordTypeIdSet.contains(newCase.recordTypeId) && ('Duplicate'.equalsIgnoreCase(newCase.Reason) || 'Not SM Owned'.equalsIgnoreCase(newCase.Reason) || 'No Outreach'.equalsIgnoreCase(newCase.Reason))) {
            newCase.Case_Reason_Indicator__c = true;
        }
    }
    
    /**
    * < caseSlaReset() - Method to close events and create new events>
    * @param:
    *     case newCase - List of cases which need to be updated.        
    *     String oldCaseOwnerId - old case owner id.
    *       
    * @return - void
    * @see - Social_validateCaseQueue (trigger)
    */
    
    public static void caseSlaReset(case newCase, String oldCaseOwnerId) {
        List<Event> EventList= new list<Event>();
        Id oldOwnerId = String.valueOf(oldCaseOwnerId);
        String newCaseOwner = newCase.ownerId;
        Map<Id,Boolean> userDingedMap = checkUserInAssignmentGrp(newCase.ownerId,oldOwnerId,newCase);
        if ('SLA1 - Initiated'.equalsIgnoreCase(newCase.Current_SLA_Phase__c)) {
            for(Event eventObjUpdate: [select WhatId from Event where Event_status__c = 'Open' and WhatId =: newCase.id and Event_Type__c = 'SLA - 1']){
                eventObjUpdate.Event_status__c = 'Closed';
                if (userDingedMap.containsKey(newCaseOwner) && userDingedMap.get(newCaseOwner)) {
                    eventObjUpdate.Case_Reassigned__c = True;
                }
                EventList.add(eventObjUpdate);
            }       
        } else if ('SLA2 - Initiated'.equalsIgnoreCase(newCase.Current_SLA_Phase__c)) {
            for(Event eventObjUpdate: [select WhatId from Event where Event_status__c = 'Open' and WhatId =: newCase.id and Event_Type__c = 'SLA - 2']){
                eventObjUpdate.Event_status__c = 'Closed';
                if (userDingedMap.containsKey(newCaseOwner) && userDingedMap.get(newCaseOwner)) {
                    eventObjUpdate.Case_Reassigned__c = True;
                }
                EventList.add(eventObjUpdate);
            }
        //Aditya: Logic to flip record type back to consumer care for case with SLA2 - ended status
        } else if ('SLA2 - Ended'.equalsIgnoreCase(newCase.Current_SLA_Phase__c)) {
            if (newCaseOwner.startsWith('00G') && oldCaseOwnerId.startsWith('005') && newCase.RecordTypeId == System.Label.HS_Care_Rep_RT) {
                //If case origin is email then flip the case back to Consumer Email Record type else flip back to Consumer Care Case
                if (newCase.Origin == 'Email') {
                    newCase.RecordTypeId = System.Label.Consumer_Care_Email_Case;
                } else {
                    newCase.RecordTypeId = System.Label.ConsumerCareCase;
                }
            }
        }
        //To populate the migration time for the case from T1 Queue to T2 Queue(Expert Queue)
        if(system.Label.ExpertQueueIds.contains(newCaseOwner) && newCase.Time_of_Migration_from_T1_to_T2_Queue__c == null && newCase.Migration_Duration_from_T1_to_T2_Queue__c == null){
            newCase.Time_of_Migration_from_T1_to_T2_Queue__c = system.now();
            Double caseCreatedTime = newCase.createdDate.getTime();
            Double currentTime = System.Now().getTime();
            Double milliSeconds = currentTime - caseCreatedTime;
            newCase.Migration_Duration_from_T1_to_T2_Queue__c = String.valueOf(milliSeconds/1000).subStringBefore('.');
        }
        
        if (!EventList.isEmpty()) {
            //update events
            Social_StreamingUtil.updateSObject(EventList,'Class:Social_markCaseUpdates Method:caseSlaReset');
            if(newCaseOwner.startsWith('00G')){
                newCase.Track_Case_Queue__c = newCase.ownerId;
                //Aditya : Logic to flip Case record type when case is pushed back to queue manually
                if (newCase.RecordTypeId == System.Label.HS_Care_Rep_RT) {
                    //If case origin is email then flip the case back to Consumer Email Record type else flip back to Consumer Care Case
                    if (newCase.Origin == 'Email') {
                        newCase.RecordTypeId = System.Label.Consumer_Care_Email_Case;
                    } else {
                        newCase.RecordTypeId = System.Label.ConsumerCareCase;
                    }
                }
                if ('SLA1 - Initiated'.equalsIgnoreCase(newCase.Current_SLA_Phase__c)) {
                    newCase.First_SLA_Scheduled_Time__c = null;
                    newCase.Case_Reassigned_Time__c = null;
                } else if ('SLA2 - Initiated'.equalsIgnoreCase(newCase.Current_SLA_Phase__c)) {
                    newCase.Second_SLA_Scheduled_Time__c = null;
                    newCase.Second_SLA_Start_Time__c = null;
                    newCase.Case_Reassigned_Time__c = null;
                    newCase.Current_SLA_Phase__c = 'SLA1 - Ended';
                }
                if(newCase.Case_Post_Tag__c!=null && ((newCase.Case_Post_Tag__c.contains('GCS')) || (newCase.Case_Post_Tag__c.contains('ABS'))) && ('SLA1 - Initiated'.equalsIgnoreCase(newCase.Current_SLA_Phase__c))){
                    newCase.Current_SLA_Phase__c = null; 
                }    
                if(newCase.Case_Post_Tag__c!=null && ((newCase.Case_Post_Tag__c.contains('GCS')) || (newCase.Case_Post_Tag__c.contains('ABS'))) && ('SLA2 - Initiated'.equalsIgnoreCase(newCase.Current_SLA_Phase__c))){
                    newCase.Current_SLA_Phase__c = 'SLA1 - Ended';
                }
                // On 04082015 Ashween added logic to clear the Current SLA Phase field
                if(newCase.Case_Post_Tag__c!=null && ((!newCase.Case_Post_Tag__c.contains('GCS')) || (!newCase.Case_Post_Tag__c.contains('ABS'))) && ('SLA1 - Initiated'.equalsIgnoreCase(newCase.Current_SLA_Phase__c))){
                    newCase.Current_SLA_Phase__c = null;  
                }    
                if(newCase.Case_Post_Tag__c!=null && ((!newCase.Case_Post_Tag__c.contains('GCS')) || (!newCase.Case_Post_Tag__c.contains('ABS'))) && ('SLA2 - Initiated'.equalsIgnoreCase(newCase.Current_SLA_Phase__c))){
                    newCase.Current_SLA_Phase__c = 'SLA1 - Ended';
                }
                
            } else if (newCaseOwner.startsWith('005')) {  
                Set<Case> ReassignedCaseSet = new Set<Case>();
                if ('SLA1 - Initiated'.equalsIgnoreCase(newCase.Current_SLA_Phase__c)) {
                    newCase.First_SLA_Scheduled_Time__c = dateTime.now().addMinutes(15);
                    //Updating Case reassign time when owner is changed.
                    if(newCase.Moved_to_Prior_Care_Manager__c == false){
                        newCase.Case_Reassigned_Time__c = dateTime.Now();
                    }
                    ReassignedCaseSet.add(newCase);
                    String eventDescription = 'First SLA Response Reminder.';
                    Integer timePeriod = 15;
                    Integer reminderTime = 12;
                    createNewSLA(newCase,eventDescription,timePeriod,reminderTime,'SLA - 1');
                } else if('SLA2 - Initiated'.equalsIgnoreCase(newCase.Current_SLA_Phase__c)){
                    newCase.Second_SLA_Scheduled_Time__c = dateTime.now().addMinutes(60);
                    newCase.Second_SLA_Start_Time__c = dateTime.Now();
                    //Updating Case reassign time when owner is changed.
                    if(newCase.Moved_to_Prior_Care_Manager__c == false){
                        newCase.Case_Reassigned_Time__c = dateTime.Now();
                    }
                    ReassignedCaseSet.add(newCase);
                    String eventDescription = 'Second SLA Response Reminder.';
                    Integer timePeriod = 60;
                    Integer reminderTime = 45;
                    createNewSLA(newCase,eventDescription,timePeriod,reminderTime,'SLA - 2');
                    createSlaTasks(newCase.id,newCase.OwnerId, 'SLA-2 Customer Response Task', 'SLA-2 Social Post Customer Response', 'SLA - 2', true);
                }// Calling method and passing the set of cases for which the record needs to be inserted for reassigned time
            }
        }
   }
   
   /**
    * < checkUserInAssignmentGrp() - Method to check assignment group of user>
    * @param:
    *     Id currentOwner - salesforce id of current case owner        
    *     Id oldOwner - salesforce id of old case owner.
    *     Case newCase - case object
    *       
    * @return - Map<Id,Boolean> userAssignmentMap
    * @see - Social_markCaseUpdates (class)
    */
    
   Public static Map<Id,Boolean> checkUserInAssignmentGrp(Id currentOwner,Id oldOwner,Case newCase) {
       Map<Id,Set<String>> userAGMap= new Map<Id,Set<String>>();
       Map<Id,Boolean> userAssignmentMap = new Map<Id,Boolean>();
       if (String.valueOf(currentOwner).startsWith('005') && String.valueOf(oldOwner).startsWith('005')) {
           for(Assignment_Groups__c groupObj: [select name,User__c,Group_Name__r.Name from Assignment_Groups__c where  Assignment_Groups__c.User__c =: currentOwner or  Assignment_Groups__c.User__c =: oldOwner]){
               if (userAGMap.containsKey(groupObj.User__c)) {
                   userAGMap.get(groupObj.User__c).add(groupObj.Group_Name__r.Name);
               } else {
                   userAGMap.put(groupObj.User__c,new Set<String> {groupObj.Group_Name__r.Name});
               }
           }
           if (userAGMap.containsKey(oldOwner) && !userAGMap.get(oldOwner).isEmpty()) {
               for(String s : userAGMap.get(oldOwner)) {
                   if (userAGMap.containsKey(currentOwner)) {
                       if (userAGMap.get(currentOwner).contains(s)) {
                           userAssignmentMap.put(currentOwner,true);
                           break;
                       } else {
                           userAssignmentMap.put(currentOwner,false);
                       }
                   }
               }
           }
       } else if (String.valueOf(currentOwner).startsWith('00G') && String.valueOf(oldOwner).startsWith('005')) {
           if (newCase.Track_Case_Queue__c != null && newCase.Track_Case_Queue__c == currentOwner) {
               userAssignmentMap.put(currentOwner,true);    
           } else {
               userAssignmentMap.put(currentOwner,false);
           }
       }
       return userAssignmentMap;
   }
   
   /*
   * < createNewSLA() - Method to create new Events depending on the SLAs for Care Managers and Operations Managers>
   * @param:
   *     Case newCase - salesforce current case object    
   *     string eventDescription - salesforce event description.
   *     Integer timePeriod - Duration in minutes for the event
   *     Integer reminderTime - Reminder time for the Event.
   *     string eventType - Type of Event i.e. SLA 1 or SLA 2
   *       
   * @return - void
   * @see - Social_markCaseUpdates (class)
   */
   
   //Creating new Events depending on previous SLA's
   Public static void createNewSLA(Case newCase,string eventDescription, Integer timePeriod, Integer reminderTime, string eventType ) {
        //Inserting events for new User to whom the case is reassigned
        List<Event> newEventList = new List<Event>();
        Event careEvent = new Event();
        careEvent.WhatId = newCase.Id;
        careEvent.Event_Type__c = eventType;
        careEvent.Event_Status__c = 'Open';
        careEvent.Description = eventDescription;
        careEvent.OwnerId = newCase.OwnerId;
        careEvent.StartDateTime = datetime.now();
        careEvent.DurationInMinutes = timePeriod;
        careEvent.IsReminderSet = false;
        careEvent.ReminderDateTime = datetime.now().addMinutes(reminderTime);
        careEvent.Subject = eventType + ':' + newCase.Case_Owner_Name__c + ':' + newCase.CaseNumber;
        
        //Adding Events to list
        newEventList.add(careEvent);
        //To insert Events for the operations manager
            for(User opsManager: [Select u.Id From User u where u.Profile.Name = 'Operations Manager' and u.IsActive = True and u.Receive_SLA_Missed_Notification_Email__c = True]){
                // Operation Manager Event
                Event operationEvent = new Event();
                operationEvent.WhatId = newCase.Id;
                operationEvent.Event_Type__c = eventType;
                operationEvent.Event_Status__c = 'Open';
                operationEvent.Description = eventDescription;
                operationEvent.OwnerId = opsManager.id;
                operationEvent.StartDateTime = dateTime.now();
                operationEvent.DurationInMinutes = timePeriod;
                operationEvent.IsReminderSet = true;
                operationEvent.ReminderDateTime = dateTime.now().addMinutes(reminderTime);
                operationEvent.Subject = eventType + ':' + newCase.Case_Owner_Name__c + ':' + newCase.CaseNumber;
                newEventList.add(operationEvent);
            }
        //Inserting Events
        if (!newEventList.isEmpty()) {
            Social_StreamingUtil.insertSObject(newEventList,'Class:Social_markCaseUpdates Method:createNewSLA');
        }
    }
   /*
   * < createSlaTasks() - Method to create new Tasks on creation of SLA 2>
   * @param:
   *     Id taskParent - salesforce id of Parent task.    
   *     Id taskOwner - salesforce id of Task owner.
   *     String taskSubject - Subject of the task.
   *     String taskDetail - Details of the task created.
   *     String taskType - Type of Task created.
   *     boolean taskIgnore - Boolean value to ignore case activity.
   *       
   * @return - void
   * @see - Social_markCaseUpdates (class)
   */
    
     // Public Method For Second SLA Task Creation
    public static void createSlaTasks(Id taskParent, Id taskOwner, String taskSubject, String taskDetail, String taskType, boolean taskIgnore){
        List<Task> newTaskList = new List<Task>();
        // Create Task Add To List
        Task slaTask = new Task();
        slaTask.WhatId = taskParent; 
        slaTask.OwnerId = taskOwner;
        slaTask.Subject = taskSubject;
        slaTask.Description = taskDetail;
        slaTask.Event_Type__c = taskType;
        slaTask.Status = 'Completed';
        slaTask.Priority = 'Normal';
        slaTask.Ignore_Case_Activity__c = taskIgnore;
        slaTask.ActivityDate = System.now().date();
        
        // Add Task To List
        newTaskList.add(slaTask);
        
        //Inserting Task
        if (!newTaskList.isEmpty()) {
            Social_StreamingUtil.insertSObject(newTaskList,'Class:Social_markCaseUpdates Method:createNewTask');
        }
    }
    
    /**
    * < CaseReassignments() - Method to insert record in the Case Reassgnments object to track the new Case owner and the Reassigned time>
    * @param:
    *     case newCase - List of cases for which the reassignment time neeeds to be captured.        
    *            
    * @return - void
    * @see - Social_validateCaseQueue (trigger)
    */
    
    public static void CaseReassignments(Set<Case> ReassignedCaseSet, String CaseReassignedThrough, String assignReassign){
        List<Case_Reassignment__c> CaseReassignmentList = new List<Case_Reassignment__c>();
        for(Case NewCaseObj : ReassignedCaseSet){
            if((NewCaseObj.Case_Reassigned_Time__c!=null || NewCaseObj.Case_assigned_Time__c!=null ) && NewCaseObj.id!=null && CaseReassignedThrough!=null && assignReassign!=null){
                Case_Reassignment__c CaseReassign = new Case_Reassignment__c();
                CaseReassign.Case__c = NewCaseObj.id;
                CaseReassign.New_Owner__c = NewCaseObj.Ownerid;
                CaseReassign.Case_reassigned_through__c = CaseReassignedThrough;
                if(NewCaseObj.Case_assigned_Time__c!=null && NewCaseObj.Case_Reassigned_Time__c == null){
                    if(NewCaseObj.Moved_to_Prior_Care_Manager__c == false){
                        CaseReassign.Case_Reassigned_Time__c = NewCaseObj.Case_assigned_Time__c;
                    }
                } else if(NewCaseObj.Moved_to_Prior_Care_Manager__c == false) {
                    CaseReassign.Case_Reassigned_Time__c = NewCaseObj.Case_Reassigned_Time__c;
                }
                CaseReassign.Case_status__c = NewCaseObj.status;
                CaseReassign.Assigned_Reassigned__c = assignReassign;
                CaseReassignmentList.add(CaseReassign);
            }
        }
        if (!CaseReassignmentList.isEmpty()) {
            Social_StreamingUtil.insertSObject(CaseReassignmentList,'Class:Social_markCaseUpdates Method:CaseReassignments');
        }
        
    }
     
    /**
    * < CaseDoNotReassignUpdate() - Method to update DNR End Time and Start Time on case>
    * @param:
    *     case newCase - case to be updated with DNR.
    *            
    * @return - void
    * @see - Social_validateCaseQueue (trigger)
    */
    
    public static void CaseDoNotReassignUpdate(Case caseObjUpdate){
         if(caseObjUpdate.Do_Not_Reassign_Timeframe__c!=null && caseObjUpdate.Do_Not_Reassign_Timeframe__c=='24 Hours'){ 
                     caseObjUpdate.Do_Not_Reassign__c=true;
                     caseObjUpdate.DNR_End_Time__c=system.now()+1;
                     caseObjUpdate.Do_Not_Reassign_Time__c=system.now();
             }
             else if(caseObjUpdate.Do_Not_Reassign_Timeframe__c!=null && caseObjUpdate.Do_Not_Reassign_Timeframe__c=='48 Hours'){
                     caseObjUpdate.Do_Not_Reassign__c=true;
                     caseObjUpdate.DNR_End_Time__c=system.now()+2;
                     caseObjUpdate.Do_Not_Reassign_Time__c=system.now();
             }
             else if(caseObjUpdate.Do_Not_Reassign_Timeframe__c!=null &&  caseObjUpdate.Do_Not_Reassign_Timeframe__c=='72 Hours'){
                     caseObjUpdate.Do_Not_Reassign__c=true;
                     caseObjUpdate.DNR_End_Time__c=system.now()+3;
                     caseObjUpdate.Do_Not_Reassign_Time__c=system.now();
             }
             else if(caseObjUpdate.Do_Not_Reassign_Timeframe__c!=null && caseObjUpdate.Do_Not_Reassign_Timeframe__c=='Do Not Reassign'){
                     caseObjUpdate.Do_Not_Reassign__c=true;
                     caseObjUpdate.DNR_End_Time__c=null;
                     caseObjUpdate.Do_Not_Reassign_Time__c=system.now();
             }
             else if(caseObjUpdate.Do_Not_Reassign_Timeframe__c==null){
                     caseObjUpdate.Do_Not_Reassign__c=false;
                     caseObjUpdate.DNR_End_Time__c=null;
                     caseObjUpdate.Do_Not_Reassign_Time__c=null;
                     Social_StreamingUtil.doNtReassignToQueue=false;
             }
    }
    
}