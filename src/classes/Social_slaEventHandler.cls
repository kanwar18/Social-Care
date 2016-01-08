public class Social_slaEventHandler {
    // List Variable Declarations
    List<Event> newEventList = new List<Event>();
    List<Task> newTaskList = new List<Task>();
    Map<Id,User> userMap = new Map<Id,User>();
    Map<Id,Id> userManagerMap = new Map<Id,Id>();
    Map<Id,String> userManagerEmailMap = new Map<Id,String>();
    public boolean insertdata{get;set;}//Variable used to insert SLA events during reply of email to case functionality.
    public Id bsCaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Case'); // Stores record type id of Business Care Closed case Record Type
    // Constructor
    public Social_slaEventHandler(){
        insertdata=false;
        // Get All System Users and Managers
        for(User endUser: [Select u.Name, u.ManagerId, u.Manager.Email, u.Id From User u where u.IsActive=true limit 10000]){
            // Map of UserId-User
            userMap.put(endUser.Id, endUser);
            // Map of UserId-ManagerId
            userManagerMap.put(endUser.Id, endUser.ManagerId);
            // Map of UserId-ManagerEmail
            userManageremailMap.put(endUser.Id, endUser.Manager.Email);
        }
    }
  
    // Public Method For Event Creation
    public void createSlaEvents(Case eventCase, Id userId, datetime allocateTime, String eventType){
        // Define Event Description
        String eventDescription = 'SLA - 1'.equalsIgnorecase(eventType)? 'First SLA Response Reminder.' : 'Second SLA Response Reminder.';
        Integer timePeriod = 'SLA - 1'.equalsIgnorecase(eventType)? 15 : 60;
        Integer reminderTime =  'SLA - 1'.equalsIgnorecase(eventType)? 12 : 45;
        boolean IsCaseConsumer = isCaseConsumer(eventCase);
        Event careEvent = new Event();
        careEvent.WhatId = eventCase.Id;
        careEvent.Event_Type__c = eventType;
        careEvent.Event_Status__c = 'Open';
        careEvent.Description = eventDescription;
        careEvent.OwnerId = userId;
        careEvent.StartDateTime = allocateTime;
        careEvent.DurationInMinutes = timePeriod;
        if(!IsCaseConsumer){
            careEvent.IsReminderSet = true;
        } else if(IsCaseConsumer){
            careEvent.IsReminderSet = false;
        }
        careEvent.ReminderDateTime = allocateTime.addMinutes(reminderTime);
        careEvent.Subject = eventType + ':' + userMap.get(userId).Name + ':' + eventCase.CaseNumber;
        // Add Event To List
        newEventList.add(careEvent);
        if(!IsCaseConsumer) {
            // Operation Manager Event
            Event operationEvent = new Event();
            operationEvent.WhatId = eventCase.Id;
            operationEvent.Event_Type__c = eventType;
            operationEvent.Event_Status__c = 'Open';
            operationEvent.Description = eventDescription;
            operationEvent.OwnerId = userManagerMap.get(userId);
            operationEvent.StartDateTime = allocateTime;
            operationEvent.DurationInMinutes = timePeriod;
            operationEvent.IsReminderSet = true;
            operationEvent.ReminderDateTime = allocateTime.addMinutes(reminderTime);
            operationEvent.Subject = eventType + ':' + userMap.get(userId).Name + ':' + eventCase.CaseNumber;
            newEventList.add(operationEvent);       
            } else if(IsCaseConsumer) {
                List<User> operationsManagersList = [Select u.Id From User u where u.Profile.Name = 'Operations Manager' and u.IsActive = True and u.Receive_SLA_Missed_Notification_Email__c = True];
                if(operationsManagersList!=null && operationsManagersList.size()>0) {
                    for(User opsManager: operationsManagersList) {
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
                     /*** Code logic added to insert data during email reply from custom email page ***/
                    if(insertdata && !newEventList.isempty()){
                        insertEventData();
                    }
                     /*** Code logic added to insert data during email reply from custom email page ***/
                }
            }
    }
    
    public Map<String, String> getRecordTypes(){
        Map<String, String> recordTypeMap = new Map<String, String>();
        List<RecordType> recordTypeList = [Select r.Name, r.Id From RecordType r where r.IsActive = True and r.SobjectType = 'Case'];
        if(recordTypeList!=null && recordTypeList.size()>0){
            for(RecordType rt: recordTypeList){
                recordTypeMap.put(rt.id, rt.Name);
            }
        }
        return recordTypeMap;
    }
    
    public boolean isCaseConsumer(Case eventCase){
        boolean returnValue = false;
        Map<String, String> recordTypeMap = getRecordTypes();
        String strRecordTypeId = '';
        strRecordTypeId = eventCase.RecordTypeId;
        if(!recordTypeMap.isEmpty() && strRecordTypeId!=null && !strRecordTypeId.equals('')){
            String strRecordType = recordTypeMap.get(eventCase.RecordTypeId);
            if(strRecordType!=null && !strRecordType.equals('') && strRecordType.contains('Consumer') ){
                returnValue = true;
            }
        }
        else if(eventCase.Case_PostTag__c!=null && !(eventCase.Case_PostTag__c).equals('') && !(eventCase.Case_PostTag__c).contains('GCS-')){
            returnValue = true;
        }
        else if(eventCase.Case_PostTag__c!=null && (eventCase.Case_PostTag__c).equals('')){
            returnValue = true;
        }
        
        return returnValue;
        
    }
    
  // Public Method For Second SLA Task Creation
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
  
  
  // Public Method To Get Related Manager
  public Id getRelatedOperationManager(Id userId){
    if(userManagerMap.get(userId)!=null)
        return userManagerMap.get(userId);
    return null;    
  }
  
  // Public Method To Get Related Manager Email
  public String getRelatedOperationManagerEmail(Id userId){
    if(userManagerEmailMap.get(userId)!=null)
        return userManagerEmailMap.get(userId);
    return null;    
  }
  
  
  // Insert SLA Events/Tasks
  public void insertEventData(){
    
    // Events
    if(!newEventList.isEmpty()){
        try{
            Social_StreamingUtil.doNotFireUpdateReason = false;
            insert newEventList;
        }
        catch(Exception Exp){
            System.debug('EXCEPTION DURING EVENT INSERT:'+ Exp.getmessage());
        }
    }
    
    // Tasks
    if(!newTaskList.isEmpty()){
        try{
            Social_StreamingUtil.doNotFireUpdateReason = false;
            insert newTaskList;
        }
        catch(Exception Exp){
            System.debug('EXCEPTION DURING TASK INSERT:'+ Exp.getmessage());
        }
    }
  }
  
}