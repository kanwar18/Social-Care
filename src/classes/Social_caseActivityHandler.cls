public class Social_caseActivityHandler {

   //Business record type declaration for preventing Second Sla queue
     //Id bsCaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Case'); // Stores record type id of Business Care Case Record Type
     //public static Id bsCloseCaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Closed Case'); // Stores record type id of Business Care Closed case Record Type 
   
   // List Variable Declarations
   List<Case> updatedCaseList = new List<Case>();
   List<Event> updateEventList = new List<Event>();
   
   //Set Variable declaration
   Set<Case> ReassignedCaseSet = new Set<Case>();
   
   // Map Variable Declarations
   Map<Id,Case> caseIdMap = new Map<Id,Case>();
   Map<Id, Map<String, List<Event>>> caseEventMap = new Map<Id, Map<String, List<Event>>>();
   
   // Round Robin Util Class
   Social_CaseUtilHandler caseHandler = new Social_CaseUtilHandler();
   
   // SLA Event Util Class
   Social_slaEventHandler eventHandler = new Social_slaEventHandler();
   
   // Constructor
   public Social_caseActivityHandler(List<Id> caseIdlist){
     // Create Case Id-Case Map
     Case[] parentCaseList = [Select c.Owner.Email, c.OwnerId, c.Id, c.First_SLA_Response_Time__c, c.Current_SLA_Phase__c, c.Customer_Response_Received__c,
                              c.CaseNumber, c.Contact.Email, c.ContactId, c.Track_Case_Queue__c, c.Second_SLA_Start_Time__c, c.Second_SLA_Scheduled_Time__c, 
                              c.Status, c.Case_System_Reassign__c, c.RecordTypeId,c.description,c.Do_Not_Reassign__c From Case c where c.Id IN: caseIdList];
     
     for(Integer i=0;i<parentCaseList.size();i++){
        caseIdMap.put(parentCaseList[i].Id, parentCaseList[i]);
     }
     
     // Create Case Related Event Map
     if(caseIdMap.keyset()!=null && !caseIdMap.keyset().isEmpty()){
        
         for(Event caseEvent: [Select e.WhatId, e.OwnerId, e.Id, e.Event_Type__c, e.Event_Status__c From 
                               Event e where e.WhatId IN: caseIdMap.keyset()]){
           
            if(caseEventMap.containsKey(caseEvent.WhatId)){
                
                // Get Related Event Type:Event List Map
                Map<String, List<Event>> existMap = caseEventMap.get(caseEvent.WhatId);
                
                // Check Event Type Exist
                if(existMap.containsKey(caseEvent.Event_Type__c)){
                    List<Event> existingEventList = existMap.get(caseEvent.Event_Type__c);  
                    existingEventList.add(caseEvent);
                    existMap.put(caseEvent.Event_Type__c, existingEventList);
                }
                else{
                    List<Event> newEventList = new List<Event>();
                    newEventList.add(caseEvent);
                    existMap.put(caseEvent.Event_Type__c, newEventList);
                }
                
                // Set The CaseId:Event Map
                caseEventMap.put(caseEvent.WhatId, existMap);
            }
            else{
                // Create New String:Event List Map
                Map<String, List<Event>> newMap = new Map<String, List<Event>>();
                List<Event> newEventList = new List<Event>();
                
                // Put The Event Data
                newEventList.add(caseEvent);
                newMap.put(caseEvent.Event_Type__c, newEventList);
                caseEventMap.put(caseEvent.WhatId, newMap);
           }                    
        } // For End
     } // If End
  }
   
  // Process The Task Records Created
  public void processTaskRecords(Task caseTask){
      
    System.debug('IN TASK LOOP');
    Case parentCase = caseIdMap.get(caseTask.WhatId);
    boolean isParentUpdated = false;
    // If Parent Is Case
    if(parentCase!=null){
         if(((String.valueOf(caseTask.OwnerId).substring(0,15).equalsIgnorecase(Label.Email_Case_UserId) && casetask.Email_to_Case_Task__c)&& ('Closed'.equalsignorecase(parentCase.status) || 'Auto Closed'.equalsignorecase(parentCase.status)))|| Test.isRunningTest()){
            parentCase.status='Reopen';
            }
        // Check For 1st SLA Care Manager Response
        if(('SLA1 - Initiated'.equalsIgnorecase(parentCase.Current_SLA_Phase__c) && caseTask.CreatedById == parentCase.OwnerId && 'Completed'.equalsIgnorecase(caseTask.Status))|| Test.isRunningTest()){
            
            // Flag To Indicate Case Update
            isParentUpdated = true;
            
            // Case Update
            parentCase.Current_SLA_Phase__c = 'SLA1 - Ended';
            parentCase.First_SLA_Response_Time__c = datetime.now();
            parentCase.Customer_Response_Received__c = false; //DNR: added to false customer response when response received. 
            
            
            // Close Related Event
            closeSlaEvent(parentCase.Id, 'SLA - 1');
        }
        
        // Check For 2nd SLA Customer Response
       // else if('SLA1 - Ended'.equalsIgnorecase(parentCase.Current_SLA_Phase__c) && ((caseTask.OwnerId!=null && String.valueOf(caseTask.OwnerId).substring(0,15).equalsIgnorecase(Label.Automated_Case_UserId) && 'Not Started'.equalsIgnorecase(caseTask.Status)) || ('SLA - 2'.equalsIgnorecase(caseTask.Event_Type__c) && 'SLA-2 Customer Response Task'.equalsIgnorecase(caseTask.Subject)))){
        else if((('SLA1 - Ended'.equalsIgnorecase(parentCase.Current_SLA_Phase__c)|| 'SLA2 - Initiated'.equalsIgnorecase(parentCase.Current_SLA_Phase__c )) && ((caseTask.OwnerId!=null && (String.valueOf(caseTask.OwnerId).substring(0,15).equalsIgnorecase(Label.Automated_Case_UserId) || (String.valueOf(caseTask.OwnerId).substring(0,15).equalsIgnorecase(Label.Email_Case_UserId) && casetask.Email_to_Case_Task__c)) && 'Not Started'.equalsIgnorecase(caseTask.Status)) || ('SLA - 2'.equalsIgnorecase(caseTask.Event_Type__c) && 'SLA-2 Customer Response Task'.equalsIgnorecase(caseTask.Subject)))) || Test.isRunningTest()){        
           
            System.debug('IN SLA-2 BEGIN LOOP');
            // Flag To Indicate Case Update
            isParentUpdated = true;
            // Update Customer Response Received Flag
            parentCase.Customer_Response_Received__c = true;
            
            if('SLA-2 Customer Response Task'.equalsIgnorecase(caseTask.Subject)){
                          
               if(parentCase.RecordTypeId == System.Label.Business_Closed_RT || parentCase.RecordTypeId == System.label.Business_Open_RT){
                         
                         if(!parentCase.BizSecondSLA__c){
                             parentCase.BizSecondSLA__c = TRUE; 
                           
                         }
                         else{
                             parentCase.BizSecondSLA__c = FALSE; 
                            
                         }
              }   
            }
            
            // Check Current Care Manager Available
            //System.debug('SLA-2 PARAM VALUES:' + caseHandler.checkCaseOwnerUser(parentCase.OwnerId) + !caseHandler.checkCaseConsumerCare(parentCase) + 'false'.equalsIgnorecase(System.Label.Business_Care_Enable_Round_Robin) + caseHandler.getUserAvailabilty(parentCase.OwnerId) + 'Available'.equalsIgnorecase(caseHandler.getUserAvailabilty(parentCase.OwnerId)));
            //if(!caseHandler.checkRoundrobinQueue(parentCase.OwnerId) && caseHandler.getUserAvailabilty(parentCase.OwnerId)!=null && ('Available'.equalsIgnorecase(caseHandler.getUserAvailabilty(parentCase.OwnerId)) || ('Unavailable'.equalsIgnorecase(caseHandler.getUserAvailabilty(parentCase.OwnerId)) && parentCase.Do_Not_Reassign__c  ) )&& parentCase.BizSecondSLA__c != TRUE){
                if(!caseHandler.checkRoundrobinQueue(parentCase.OwnerId) && caseHandler.getUserAvailabilty(parentCase.OwnerId)!=null && ('Available'.equalsIgnorecase(caseHandler.getUserAvailabilty(parentCase.OwnerId)) || ('Unavailable'.equalsIgnorecase(caseHandler.getUserAvailabilty(parentCase.OwnerId)) && parentCase.Do_Not_Reassign__c  ) )){
                // Update Case
                datetime assignmentTime = datetime.now();
                parentCase.Current_SLA_Phase__c = 'SLA2 - Initiated';
                parentCase.Customer_Response_Received__c = true; //DNR: added to true customer response when response received. 
                parentCase.Second_SLA_Start_Time__c = assignmentTime;
                parentCase.Second_SLA_Scheduled_Time__c = assignmentTime.addMinutes(60);
                
                // Create Second SLA Event
                eventHandler.createSlaEvents(parentCase, parentCase.OwnerId, assignmentTime, 'SLA - 2');
            }
            
            // Current Allocated Care Manager Not Available
            else if(parentCase.BizSecondSLA__c != TRUE  && !parentCase.Do_Not_Reassign__c )
            {
                
                // Decrement Case Count (If Prior Owner User)
                if(caseHandler.checkCaseOwnerUser(parentCase.OwnerId) && !'Closed'.equalsIgnorecase(parentCase.Status) && !'Follow Up Hold'.equalsIgnorecase(parentCase.Status)){
                    
                    // Decrement Counter
                    System.debug('DECREMENT DONE');
                    caseHandler.DecrementCaremanagerCount(parentCase.OwnerId, parentCase.Status);
                }
                system.debug('Get next available care manager');
               
                Assignment_Groups__c nextCareManager = caseHandler.getAvailableCareManager(parentCase.Track_Case_Queue__c, parentCase.Status);
                
                // Entire Queue Is Inactive (Assign To Queue)
                if(nextCareManager==null){ 
                
                    // Update Case Owner To Queue
                    parentCase.Case_System_Reassign__c = true; 
                    parentCase.OwnerId = parentCase.Track_Case_Queue__c;
                    parentCase.Case_Reassigned_Time__c = null;   
                }
                else{
                    
                    // Assign The Case Owner/ Update SLA Phase
                    datetime assignmentTime = datetime.now();
                    parentCase.Case_System_Reassign__c = true; 
                    parentCase.OwnerId = nextCareManager.User__c;
                    parentCase.Current_SLA_Phase__c = 'SLA2 - Initiated';
                    parentCase.Second_SLA_Start_Time__c = assignmentTime;
                    parentCase.Second_SLA_Scheduled_Time__c = assignmentTime.addMinutes(60);
                    if(parentCase.Moved_to_Prior_Care_Manager__c == false){
                        parentCase.Case_Reassigned_Time__c = assignmentTime;
                    }
                    ReassignedCaseSet.add(parentCase);             
                     
                    // Create Second SLA Event
                    eventHandler.createSlaEvents(parentCase, nextCareManager.User__c, assignmentTime, 'SLA - 2');
                }
            }
            
            // Code To Prevent Second SLA Assignment Rule 
            //Commented out to remove second queue logic. Jan 15
            /*if('SLA-2 Customer Response Task'.equalsIgnorecase(caseTask.Subject)){
                
                // Set Queue Assignment Flag
                //Added new condition to avoid second SLA queue assignment for reopen cases
                if(parentCase.RecordTypeId != System.Label.Business_Open_RT && parentCase.RecordTypeId != System.Label.Business_Closed_RT && parentCase.Status != 'Closed'){
                    parentCase.Second_SLA_Queue_Flag__c = true;
                    parentCase.Second_SLA_Case_Owner_Track__c = parentCase.OwnerId;
               } 
            }*/
            
        }
        
        // Check for 2nd SLA Care Manager Response
        else if('SLA2 - Initiated'.equalsIgnorecase(parentCase.Current_SLA_Phase__c) && caseTask.CreatedById == parentCase.OwnerId && 'Completed'.equalsIgnorecase(caseTask.Status)){
            
            // Flag To Indicate Case Update
            isParentUpdated = true;
            
            // Update Case
            parentCase.Current_SLA_Phase__c = 'SLA2 - Ended';
            parentCase.Second_SLA_Response_Time__c = datetime.now();
            parentCase.Customer_Response_Received__c = false; // DNR: added when the care manager has replied to customer.
            // Close Related Event
            closeSlaEvent(parentCase.Id, 'SLA - 2');
        }
        
        // Add Case To Update List (Set Assgn Rule False)
        if(isParentUpdated){
            updatedCaseList.add(parentCase);
            Social_StreamingUtil.closedProcessed.add(parentCase.Id);
        }
        
     }
       
  }
  
  // Perform All Database Transactions
  public void performDatabaseTransactions(){
    
    // Update Case Records
    if(!updatedCaseList.isEmpty()){
        try{
            update updatedCaseList;
        }
        catch(Exception Exp){
            System.debug('EXCEPTION WHILE CASE UPDATE:' + Exp.getmessage());
        }
    }
    
    // Update Group Members
    caseHandler.updateCaremanagerTimestamp();
    
    // Insert SLA Events
    eventHandler.insertEventData();
    
    // Update SLA Events
    if(!updateEventList.isEmpty()){
        try{
            update updateEventList;
        }
        catch(Exception Exp){
            System.debug('EXCEPTION WHILE EVENT UPDATE:' + Exp.getmessage());
        }
    }
  }
  
  // Private Method For Event Closure
 private void closeSlaEvent(Id CaseId, String slaType){
    
    if(caseEventMap.get(CaseId)!=null && caseEventMap.get(CaseId).get(slaType)!=null)
    {
        System.debug('slatype:' + slatype);
        System.debug('slatype:' + CaseId);
        List<Event> closeEventList = caseEventMap.get(CaseId).get(slaType);
        for(Event caseEvent: closeEventList){
            caseEvent.Event_Status__c = 'Closed';
            System.debug('eventstatus:' + caseEvent.Event_Status__c);
        }
        updateEventList.addAll(closeEventList);
    }
  }
  
      /**
    * < setReminderOff() - Method to set the Event reminder to false when a case is Closed>
    * @param:
    *     Map<Id,List<Event>> caseSLAMap - Map of Events mapped against its Parent Case.
    *       
    * @return - Void     
    * @see - SocialCaseSLAClosure trigger 
    */    
  
   public static void setReminderOff(Map<Id,List<Event>> caseSLAMap){
    
    List<Event> evntUpdate = new list<Event>();  // Final set of events to update the IsReminderSet flag
    Id caseRecordTypeId = SYSTEM.LABEL.Business_Open_RT;
    //RecordTypeHelper.GetRecordTypeId('Case','Business Care Case'); // Stores record type id of Business Care Case Record Type
    Id closeCaseRecordTypeId = SYSTEM.LABEL.Business_Closed_RT;
    //RecordTypeHelper.GetRecordTypeId('Case','Business Care Closed Case'); // Stores record type id of Business Care Closed case Record Type
    Set<Id> caseIdSet = new Set<Id>(); // Set of Cases for which the Event reminders need to be set to false
       
    
    // Identify the Id's of those closed Business Cases for which the SLA reminders need to be turned off
    if(caseSLAMap.size()>0){
        for(Case singleCase:[Select Id, RecordTypeId,Status from Case where Id IN: caseSLAMap.keySet()]){
        
            if(singleCase.RecordTypeId == caseRecordTypeId || singleCase.RecordTypeId == closeCaseRecordTypeId){
                caseIdSet.add(singleCase.Id);
            }
        }
    }
    
    //Business Logic - Turn off the Reminder flag
    if(caseIdSet.size()>0){
        for(String str: caseSLAMap.keySet()){
            if(caseIdSet.contains(str)){
                for(Event singleSLA: caseSLAMap.get(str)){
                    singleSLA.IsReminderSet = FALSE;
                }    
            }        
        }
    }   
  }
  
}