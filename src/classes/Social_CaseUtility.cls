/********************************************************************************************************
*    Author :     Accenture
*    Requirement: This class will handle events and task creation upon case assignment/reassignment.
*                 This class will have all information related to user record
*    Version:     1.0
*    Created Date: 30th April 2015.
*    Release 15th July 2015: ITS-1545
*********************************************************************************************************/

public class Social_CaseUtility {
    public static List<User> operationsManagersList;
    public Map<Id, User> userMap = new Map<Id, User>();
    public Map<Id, Id> userManagerMap = new Map<Id, Id>();
    public Map<Id, String> userManageremailMap = new Map<Id, String>();
    public List<Event> newEventList = new List<Event>();
    public List<Task> newTaskList = new List<Task>();
    public Social_CaseUtility(){
        
    }
    
    /**
    * < createSlaEventsDefaultsInvocation() - Method to populate information related to user object>
    * @param:
    *     None
    *
    * @return - None
    * 
    */

    public void createSlaEventsDefaultsInvocation(){
        List<String> labelList = (Label.Consumer_Operations_Managers).split(',');
        operationsManagersList = [Select u.Id From User u where u.Profile.Name IN: labelList and u.IsActive = True and u.Receive_SLA_Missed_Notification_Email__c = True];
        for(User endUser: [Select u.Name, u.ManagerId, u.Manager.Email, u.Id, u.Case_Counter__c, u.Availability__c From User u where u.IsActive=true limit 10000]){
            // Map of UserId-User
            userMap.put(endUser.Id, endUser);
            // Map of UserId-ManagerId
            userManagerMap.put(endUser.Id, endUser.ManagerId);
            // Map of UserId-ManagerEmail
            userManageremailMap.put(endUser.Id, endUser.Manager.Email);
        }
    }

    /**
    * < createSlaEvents() - Public Method For event creation>
    * @param:
    *     Case eventCase - Case Id
    *     Id userId - Case Owner Id
    *     datetime allocateTime - current time
    *     String eventType - SLA1/ SLA2
    *
    * @return - None
    * 
    */
    
    public void createSlaEvents(Case eventCase, Id userId, datetime allocateTime, String eventType){
        // Define Event Description
        String eventDescription = 'SLA - 1'.equalsIgnorecase(eventType)? 'First SLA Response Reminder.' : 'Second SLA Response Reminder.';
        Integer timePeriod = 'SLA - 1'.equalsIgnorecase(eventType)? 15 : 60;
        Integer reminderTime =  'SLA - 1'.equalsIgnorecase(eventType)? 12 : 45;
        Event careEvent = new Event();
        careEvent.WhatId = eventCase.Id;
        careEvent.Event_Type__c = eventType;
        careEvent.Event_Status__c = 'Open';
        careEvent.Description = eventDescription;
        careEvent.OwnerId = userId;
        careEvent.StartDateTime = allocateTime;
        careEvent.DurationInMinutes = timePeriod;
        careEvent.IsReminderSet = false;
        careEvent.ReminderDateTime = allocateTime.addMinutes(reminderTime);
        careEvent.Subject = eventType + ':' + userMap.get(userId).Name + ':' + eventCase.CaseNumber;
        // Add Event To List
        newEventList.add(careEvent);
        if(operationsManagersList!=null && operationsManagersList.size()>0){
            for(User opsManager: operationsManagersList){
                // Operation Manager Event
                Event operationEvent = new Event();
                operationEvent.WhatId = eventCase.Id;
                operationEvent.Event_Type__c = eventType;
                operationEvent.Event_Status__c = 'Open';
                operationEvent.Description = eventDescription;
                operationEvent.OwnerId = opsManager.id;
                operationEvent.StartDateTime = allocateTime;
                operationEvent.DurationInMinutes = timePeriod;
                operationEvent.IsReminderSet = true;
                operationEvent.ReminderDateTime = allocateTime.addMinutes(reminderTime);
                operationEvent.Subject = eventType + ':' + userMap.get(userId).Name + ':' + eventCase.CaseNumber;
                newEventList.add(operationEvent);
            }
        }
    }
    
    /**
    * < createSlaTasks() - Public Method For Second SLA Task Creation>
    * @param:
    *     Id taskParent - Case Id
    *     Id taskOwner - Case Owner Id
    *     String taskSubject - Task subject
    *     String taskDetail -  Task description
    *     String taskType -  SLA1 or SLA2
    *     boolean taskIgnore - true/false
    * @return - None
    * 
    */
    
    public void createSlaTasks(Id taskParent, Id taskOwner, String taskSubject, String taskDetail, String taskType, boolean taskIgnore){
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
    }
    
    /**
    * < getRelatedOperationManager() - Method to get care manager's operational manager id>
    * @param:
    *     Id careManagerId - User Id
    * @return - String opsManagerId
    * 
    */
    
    public String getRelatedOperationManager(Id careManagerId){
        String opsManagerId;
        if(userManagerMap!=null && !userManagerMap.isEmpty()){
            opsManagerId = userManagerMap.get(careManagerId);
        }
        return opsManagerId;
    }
    
    /**
    * < getRelatedOperationManagerEmail() - Method to get care manager's operational manager email address>
    * @param:
    *     Id careManagerId - User Id
    * @return - String opsManagerEmailId
    * 
    */
    
    public String getRelatedOperationManagerEmail(Id careManagerId){
        String opsManagerEmailId;
        if(userManageremailMap!=null && !userManageremailMap.isEmpty()){
            opsManagerEmailId = userManageremailMap.get(careManagerId);
        }
        return opsManagerEmailId;
    }
    
   /**
    * < getRelatedCareManagerCounter() - Method to get care manager case counter>
    * @param:
    *     Id careManagerId - User Id
    * @return - Integer caseManagerCounter
    * 
    */
    
    public Integer getRelatedCareManagerCounter(Id careManagerId){
        Integer caseManagerCounter;
        if (userMap.containsKey(careManagerId)) {
            caseManagerCounter = Integer.valueOf(userMap.get(careManagerId).Case_Counter__c);
        }
        return caseManagerCounter;
    }
    
   /**
    * < saveSLAEventsandTasks() - Method to save events and tasks>
    * @param:
    *     None
    * @return - void
    * 
    */
    
    public void saveSLAEventsandTasks(){
        if (!newEventList.isEmpty()) {
            Social_StreamingUtil.doNotFireUpdateReason = false;
            Social_StreamingUtil.insertSObject(newEventList,'Class:Social_CaseUtility Method:saveSLAEventsandTasks: Failed to insert events');
        }
        if (!newTaskList.isEmpty()) {
            Social_StreamingUtil.doNotFireUpdateReason = false;
            Social_StreamingUtil.insertSObject(newTaskList,'Class:Social_CaseUtility Method:saveSLAEventsandTasks: Failed to insert task');
        }
    }
    
    public String getRelatedCareManagerAvailability(Id careManagerId){
        String caseManagerAvailability;
        if (userMap.containsKey(careManagerId)) {
            caseManagerAvailability = userMap.get(careManagerId).Availability__c;
        }
        return caseManagerAvailability;
    }
}