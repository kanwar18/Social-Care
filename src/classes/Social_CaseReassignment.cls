/********************************************************************************************************
*    Author :     Arun Ramachandran
*    Requirement: Reassignment of Cases and SLA's when Care Managers/Senior Ops Manager go on vacation
*                 or get promoted
*    Version:     1.0    
*    Created Date: 19th August 2013    
*    Test Coverage class: Social_CaseReassignment_Test
*    Release 19th August : Updated by Ashween to uncheck checkbox BCS Only Once : for 'New Case' email notification
*    Release 23rd September : ITS1514 Introduced flag for vacation check to prevent twice decrement of case counter 
*********************************************************************************************************/

public class Social_CaseReassignment{    
     /**
    * < reAssignOnVacationBusiness() - Method to reassign cases when a Care Manager goes on vacation>
    * @param:
    *     Set<Id> userListVacationBusiness - Set of Id's of Business Care Managers who have gone on vacation
    *       
    * @return - Void
    * @see - SocialCaseReassignment trigger 
    */          
     @future
     public static void reAssignOnVacationBusiness(Set<Id> userListVacationBusiness){         
     
     Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();  //Map of cases to be reassigned  
     Map<Id, List<Event>> eventMap = new Map<Id, List<Event>>(); // Map of SLA's to be reassigned
     User reassignUser = new User(); // User to be assigned to the cases - care manager
     User reassignOps = new User(); // User to be assigned to the cases - senior ops     
     List<Case> updatedCases = new List<Case>(); // List of cases to be updated
     List<Event> updatedEvent = new List<Event>(); // List of events to be updated     
     Set<Id> careManagerSet = new Set<Id>(); // Id of users who are care managers
     Set<Id> careManagerEscalationBCQSet = new Set<Id>(); //Id of users who are care managers belonging to escalation queue
     Set<Id> seniorOpsManagerSet = new Set<Id>(); //Id of users who are senior ops
     Set<Id> EscalationQueueMembersBusiness = new Set<Id>();
     
     for(GroupMember singleUser : [Select Id, UserOrGroupId From GroupMember where GroupId IN (Select Id from Group where Type='Queue' and Name='Social Sales Lead')]){
         EscalationQueueMembersBusiness.add(singleUser.UserOrGroupId);
     }     
          
     for(User singleUser: [Select Id, ProfileId from User where Id IN: userListVacationBusiness]){
         if(singleUser.ProfileId == System.label.CAREMANAGER_BUSINESS){
             if(EscalationQueueMembersBusiness.contains(singleUser.Id)){
                 // Care Managers handling the Escalation cases
                 careManagerEscalationBCQSet.add(singleUser.Id);             
             }
             else{
                 //Care Managers handling the General queue cases
                 careManagerSet.add(singleUser.Id);             
             }
         }
         else{
             //Senior Ops Managers
            seniorOpsManagerSet.add(singleUser.Id);             
         }         
      }   
      
      if(careManagerEscalationBCQSet.size()>0 || careManagerSet.size()>0){
          updateAssignmentCount(careManagerSet,careManagerEscalationBCQSet);
      }            
      
     //Block of code for Care Managers Business in gen BCQ re-assignment    
        if(careManagerSet.size()>0){ 
         
             // Identify the user from General BCQ to whom the cases and SLA's need to be assigned 
             for(User singleUser: [Select Id, ProfileId, Case_Counter__c from User where Id NOT IN: careManagerSet AND IsActive = TRUE AND ProfileId =: System.label.CAREMANAGER_BUSINESS AND Availability__c = 'Available' ORDER BY Case_Counter__c DESC]){
                 reassignUser = singleUser;         
             }
             //Identify the cases to be reassigned
             caseMap = identifyCases(careManagerSet);             
             //Identify the SLA's to be reassigned
             eventMap = identifySLAs(careManagerSet);
                          
             if(!caseMap.isEmpty()){
                 //Update the ownership of the cases to new user
                 updatedCases = reassignCases(caseMap,reassignUser);
             }
             if(!eventMap.isEmpty()){
                 //Update the ownership of SLA's to new user and reset the time for the SLA's
                 updatedEvent = reAssignEvents(eventMap,reassignUser);
             }        
                      
             if(updatedCases.size()>0){
                 updateCaseOwner(updatedCases);  
             }
             if(updatedEvent.size()>0){
                 updateCaseSLAs(updatedEvent);    
             } 
         
         } 
    // Block of code for reassignment of cases and SLA for users from Esc BCQ 
    if(careManagerEscalationBCQSet.size()>0){ 
         
         // Identify the user from escalation BCQ to whom the cases and SLA's need to be assigned 
         for(User singleUser: [Select Id, ProfileId, Case_Counter__c from User where Id IN: EscalationQueueMembersBusiness AND Id NOT IN:careManagerEscalationBCQSet AND IsActive = TRUE AND ProfileId =: System.label.CAREMANAGER_BUSINESS AND Availability__c = 'Available' ORDER BY Case_Counter__c DESC]){
             reassignUser = singleUser;             
         }
         
         //Identify the cases to be reassigned
         caseMap = identifyCases(careManagerEscalationBCQSet);
         //Identify the SLA's to be reassigned
         eventMap = identifySLAs(careManagerEscalationBCQSet);
         
         if(!caseMap.isEmpty()){
             //Update the ownership of the cases to new user
             updatedCases = reassignCases(caseMap,reassignUser);
         }
         if(!eventMap.isEmpty()){
             //Update the ownership of SLA's to new user and reset the time for the SLA's
             updatedEvent = reAssignEvents(eventMap,reassignUser);
         }        
                  
         if(updatedCases.size()>0){
             updateCaseOwner(updatedCases);  
         }
         if(updatedEvent.size()>0){
             updateCaseSLAs(updatedEvent) ;   
         }         
      } 

         //************************************************************************************************* 
         
         //Block of code for Senior Ops Managers re-assignment in General BCQ
         if(seniorOpsManagerSet.size()>0){ 
         //Identify all the open cases assigned to the Care Manager              
             caseMap = identifyAuditCases(seniorOpsManagerSet);
             
             //Identify the SLA's to be reassigned             
             eventMap = identifySLAs(seniorOpsManagerSet);
            
             // Identify the user to whom the cases and SLA's need to be assigned         
             for(User singleUser: [Select Id, ProfileId, Case_Counter__c from User where Id NOT IN: seniorOpsManagerSet AND IsActive = TRUE AND ProfileId =: System.label.SENIOROPS_BUSINESS AND Availability__c = 'Available']){
                 reassignOps = singleUser;
             }
             
             if(!caseMap.isEmpty()){
                 //Update the ownership of the cases to new user
                 updatedCases = reAssignAuditCases(caseMap,reassignOps);
             }
             if(!eventMap.isEmpty()){
                 //Update the ownership of SLA's to new user and reset the time for the SLA's
                 updatedEvent = reAssignEvents(eventMap,reassignOps);
             }
             
             if(updatedCases.size()>0){
                 updateCaseOwner(updatedCases);  
             }
             if(updatedEvent.size()>0){
                 updateCaseSLAs(updatedEvent);    
             }         
         }    
    
    }
    
     /**
    * < reAssignOnPromotionBusiness() - Method to reassign cases when a Care Manager gets promoted>
    * @param:
    *     Set<Id> userListPromotionBusiness - Set of Id's of Business Care Managers who have got promoted
    *       
    * @return - Void     
    * @see - SocialCaseReassignment trigger 
    */
    @future
    public static void reAssignOnPromotionBusiness(Set<Id> userListPromotionBusiness){
    
    Set<Id> newOpManagerSet = new Set<Id>(); // Set of Id's of care manager who got promoted to Senior Ops
    Set<Id> newOpManagerESCBCQSet = new Set<Id>(); // Set of Id's of care managers belonging to Escalation queue who got promoted
    Set<Id> exOpsManagerSet = new Set<Id>(); // Set of Id's of Senior Ops managers who got promoted
    Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();  //Map of cases to be reassigned  
    Map<Id, List<Event>> eventMap = new Map<Id, List<Event>>(); // Map of SLA's to be reassigned     
    User reassignOpsUser = new User(); //Care manager to whom the cases needs to be assigned
    User reassignOpsMngr = new User(); // Senior Ops manager to whom cases needs to be assigned
    List<Case> updatedCases = new List<Case>(); // List of cases to be updated
    List<Event> updatedEvent = new List<Event>(); // List of events to be updated.
    //Set<Id> EscalationQueueMembersBusiness = new Set<Id>();
     
    /* for(GroupMember singleUser : [Select UserOrGroupId From GroupMember where GroupId IN (Select Id from Group where Type='Queue' and Name='Escalation-bc')]){
         EscalationQueueMembersBusiness.add(singleUser.UserOrGroupId);
     }*/
        for(User singleUser: [Select Id, ProfileId from User where Id IN: userListPromotionBusiness]){
             if(singleUser.ProfileId == System.label.SENIOROPS_BUSINESS){
                 /*if(EscalationQueueMembersBusiness.contains(singleUser.Id)){
                    // Care Managers handling the Escalation cases who got promoted
                    newOpManagerESCBCQSet.add(singleUser.Id);             
                 }*/
                // else{
                    // Care Managers handling the General cases who got promoted 
                    newOpManagerSet.add(singleUser.Id);             
                // }
             }
             else{
                    //Senior Ops managers who got promoted
                    exOpsManagerSet.add(singleUser.Id);
                }
        }
        
        if(exOpsManagerSet.size()>0){
            //Identify cases which need to be reassigned
            caseMap = identifyAuditCases(exOpsManagerSet);  
            //Identify SLA's that need to be reassigned
            eventMap = identifySLAs(exOpsManagerSet); 
            // Identify the user to whom the cases and SLA's need to be assigned         
             for(User singleUser: [Select Id, ProfileId, Case_Counter__c from User where Id NOT IN:exOpsManagerSet AND IsActive = TRUE AND ProfileId =: System.label.SENIOROPS_BUSINESS AND Availability__c = 'Available' ORDER BY Case_Counter__c DESC]){
                 reassignOpsMngr = singleUser;
             }
            
             if(!caseMap.isEmpty()){
                 //Update ownership of cases to new user
                 updatedCases = reassignAuditCases(caseMap,reassignOpsMngr );
             }
             if(!eventMap.isEmpty()){
                 //Update ownership of SLA's to new user
                 updatedEvent = reAssignOpsEvents(eventMap,reassignOpsMngr );
             }
             
             if(updatedCases.size()>0){
                 updateCaseOwner(updatedCases);  
             }
             if(updatedEvent.size()>0){
                 updateCaseSLAs(updatedEvent);    
             }        
        }
    
    /** Ashween's update **/
    //Block of code for promoted Care Managers case re-assignment specific to General BCQ  
        if(newOpManagerSet.size()>0){ 
            //Identify cases that need to be reassigned
            caseMap = identifyCases(newOpManagerSet); 
            //Identify SLA's that need to be reassigned 
            eventMap = identifySLAs(newOpManagerSet); 
         
             // Identify the user to whom the cases and SLA's need to be assigned         
             for(User singleUser: [Select Id, ProfileId, Case_Counter__c from User where Id NOT IN: newOpManagerSet AND IsActive = TRUE AND ProfileId =: System.label.CAREMANAGER_BUSINESS AND Availability__c = 'Available' ORDER BY Case_Counter__c DESC]){
                 reassignOpsUser = singleUser;
             }
            
             if(!caseMap.isEmpty()){
                 //Update Ownership of cases to new user
                 updatedCases = reassignCases(caseMap,reassignOpsUser);
             }
             if(!eventMap.isEmpty()){
                 //Update ownership of SLA's to new user
                 updatedEvent = reAssignEvents(eventMap,reassignOpsUser);
             }
             
             if(updatedCases.size()>0){
                 updateCaseOwner(updatedCases);  
             }
             if(updatedEvent.size()>0){
                 updateCaseSLAs(updatedEvent);    
             }
        
        }
        //Block of code for promoted Care Managers case re-assignment specific to EscalationBCQ  
        /*if(newOpManagerESCBCQSet.size()>0){ 
            //Identify cases that need to be reassigned
            caseMap = identifyCases(newOpManagerESCBCQSet);  
            //Identify SLA's that need to be reassigned
            eventMap = identifySLAs(newOpManagerESCBCQSet); 
         
             // Identify the user to whom the cases and SLA's need to be assigned         
             for(User singleUser: [Select Id, ProfileId, Case_Counter__c from User where Id IN: EscalationQueueMembersBusiness AND Id NOT IN: newOpManagerESCBCQSet AND IsActive = TRUE AND ProfileId =: System.label.CAREMANAGER_BUSINESS AND Availability__c = 'Available' ORDER BY Case_Counter__c DESC]){
                 reassignOpsUser = singleUser;
             }
            
             if(!caseMap.isEmpty()){
                 //Update Ownership of cases to new user
                 updatedCases = reassignCases(caseMap,reassignOpsUser);
             }
             if(!eventMap.isEmpty()){
                 //Update ownership of SLA's to new User
                 updatedEvent = reAssignEvents(eventMap,reassignOpsUser);
             }
             
             if(updatedCases.size()>0){
                 updateCaseOwner(updatedCases);  
             }
             if(updatedEvent.size()>0){
                 updateCaseSLAs(updatedEvent);    
             }        
         }*/
    }
    
     /**
    * < identifyCases() - Method to Identify cases when a Care Manager goes on vacation>
    * @param:
    *     Set<Id> userIdSet - Set of Id's of Business Care Managers who have gone on vacation
    *       
    * @return - Map<Id, List<Case>>
    * @see - Social_CaseReassignment (same class)
    */    
    public static Map<Id, List<Case>> identifyCases(Set<Id> userIdSet){
        Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();
        Id bsAuditCaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Case QA Record Type'); // Stores record type id of Business Care Closed case Record Type

             for(Case singleCase: [Select Id,BCS_Only_Once__c,Reassignment_Reason__c,Is_First_SLA_Missed__c, Case_Assigned_Time__c,
                                  First_SLA_Scheduled_Time__c,Second_SLA_Start_Time__c,Second_SLA_Scheduled_Time__c,
                                  Second_SLA_Response_Time__c, Current_SLA_Phase__c,
                                  Case_PostTag__c, OwnerId from Case where OwnerId IN: userIdSet AND Status != 'Closed' AND Status != 'Auto Closed']){                 
                 if(caseMap.containsKey(singleCase.OwnerId)){
                     caseMap.get(singleCase.OwnerId).add(singleCase);
                 }
                 else{
                     caseMap.put(singleCase.OwnerId, new List<Case>{singleCase});
                 }
                     
             } 
        return caseMap;   //Map of cases belonging to Care manager who went on vacation or got promoted. 
    }
    
     /**
    * < identifyAuditCases() - Method to Identify Audit cases when a SeniorOps Manager goes on vacation>
    * @param:
    *     Set<Id> userIdSet - Set of Id's of Business Senior Ops Managers who have gone on vacation
    *       
    * @return - Map<Id, List<Case>>
    * @see - Social_CaseReassignment (same class)
    */ 
    public static Map<Id, List<Case>> identifyAuditCases(Set<Id> userIdSet){
        Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();
        Id bsAuditCaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Case QA Record Type'); // Stores record type id of Business Care Audit case Record Type

             for(Case singleCase: [Select Id,BCS_Only_Once__c, Reassignment_Reason__c,Is_First_SLA_Missed__c, Case_Assigned_Time__c,
                                  First_SLA_Scheduled_Time__c,Second_SLA_Start_Time__c,Second_SLA_Scheduled_Time__c,
                                  Second_SLA_Response_Time__c, Current_SLA_Phase__c,
                                  Case_PostTag__c, Closed_Operation_Manager__c, OwnerId from Case where Closed_Operation_Manager__c IN: userIdSet AND Status = 'Closed' AND Audit_Status__c = 'Under QA' AND RecordTypeId =: bsAuditCaseRecordTypeId ]){
                 if(caseMap.containsKey(singleCase.Closed_Operation_Manager__c)){
                     caseMap.get(singleCase.Closed_Operation_Manager__c).add(singleCase);
                 }
                 else{
                     caseMap.put(singleCase.Closed_Operation_Manager__c, new List<Case>{singleCase});
                 }
                     
             } 
        return caseMap;   //Map of cases belonging to Care manager who went on vacation or got promoted. 
    }
    
     /**
    * < identifySLAs() - Method to Identify events when a Care Manager goes on vacation>
    * @param:
    *     Set<Id> userIdSet - Set of Id's of Business Care Managers who have gone on vacation
    *       
    * @return - Map<Id, List<Event>>
    * @see - Social_CaseReassignment (same class)
    */    
    public static Map<Id, List<Event>> identifySLAs(Set<Id> userIdSet){
    Map<Id, List<Event>> eventMap = new Map<Id, List<Event>>();
        for(Event singleSLA: [Select Id,StartDateTime,WhatId ,Event_Type__c,DurationInMinutes,IsReminderSet,ReminderDateTime, OwnerId, Event_Status__c from Event where OwnerId IN: userIdSet AND Event_Status__c != 'Closed']){
             if(eventMap.containsKey(singleSLA.OwnerId)){
                 eventMap.get(singleSLA.OwnerId).add(singleSLA);
             }
             else{
                 eventMap.put(singleSLA.OwnerId, new List<Event>{singleSLA});
             } 
         }    
         return eventMap;  // Map of SLA's belonging to care manager who went on vacation or got promoted    
    }
    
      /**
    * < reAssignCases() - Method to reassign cases when a Care Manager goes on vacation>
    * @param:
    *     Map<Id, List<Case>> caseMap,User rep - Map of cases and the user to whom the cases need to be assigned
    *       
    * @return - List
    * @see - Social_CaseReassignment (same class)
    */
    public static List<Case> reAssignCases(Map<Id, List<Case>> caseMap,User rep){
    List<Case> updatedCases = new List<Case>(); // List of cases to be updated
    Datetime assignmentTime = datetime.now(); // To set the reassigned SLA's to start afresh
    Integer timePeriod = 15; // Time Interval for SLA1
    Integer timePeriodSLA2 = 60; //Time Interval for SLA2
    String escalationPostTag = 'GCS-SALESLEAD';
        for(String str: caseMap.keySet()){
             for(Case singleCase: caseMap.get(str)){
                 /*if(rep.Id != NULL){
                     singleCase.OwnerId = rep.Id;
                     if(singleCase.Current_SLA_Phase__c == 'SLA1 - Initiated'){                         
                         singleCase.First_SLA_Scheduled_Time__c = assignmentTime.addMinutes(timePeriod);
                     }
                     else if(singleCase.Current_SLA_Phase__c == 'SLA2 - Initiated'){
                         singleCase.Second_SLA_Start_Time__c = assignmentTime;
                         singleCase.First_SLA_Scheduled_Time__c = assignmentTime.addMinutes(timePeriodSLA2);
                     } 
                                         
                 }*/
                 //else{
                     //In case no care managers are available reassign to respective Queue's
                     if(singleCase.Case_PostTag__c==NULL || !singleCase.Case_PostTag__c.containsIgnoreCase(escalationPostTag)){
                         singleCase.OwnerId = System.Label.GENERAL_BC_QUEUE;                                                                                                                        
                     }
                     else{
                         singleCase.OwnerId = System.Label.SOCIAL_SALES_LEAD_QUEUE; 
                     }
                     
                     //----------Reset the SLA information to last status----------
                     if(singleCase.Current_SLA_Phase__c == 'SLA1 - Initiated'){
                             singleCase.Case_Assigned_Time__c = NULL;
                             singleCase.Current_SLA_Phase__c = '';                             
                             singleCase.First_SLA_Scheduled_Time__c = NULL;
                         }
                     
                     else if(singleCase.Current_SLA_Phase__c == 'SLA2 - Initiated'){
                             singleCase.Case_Assigned_Time__c = NULL;
                             singleCase.Current_SLA_Phase__c = 'SLA1 - Ended';                           
                             singleCase.Second_SLA_Start_Time__c = NULL;
                             singleCase.Second_SLA_Scheduled_Time__c = NULL;
                     }  
                     else if(singleCase.Current_SLA_Phase__c == 'SLA3 - Initiated'){
                             singleCase.Case_Assigned_Time__c = NULL;
                             singleCase.Current_SLA_Phase__c = 'SLA2 - Ended';                           
                             singleCase.Third_SLA_Start_Time__c = NULL;
                             singleCase.Third_SLA_Scheduled_Time__c = NULL;
                     }
                     //--------------------------------------------------------------
               // }
                 singleCase.BCS_Only_Once__c = FALSE; 
                 singleCase.Reassignment_Reason__c = 'Social Media Care Agents OOO';                 
                 Social_StreamingUtil.businessAssignQueue.add(singleCase.Id);
                 updatedCases.add(singleCase);
             }
         }   
        return updatedCases;
    }
      /**
    * < reAssignAuditCases() - Method to reassign Audit cases when a Senior Ops Manager goes on vacation>
    * @param:
    *     Map<Id, List<Case>> caseMap,User rep - Map of cases and the user to whom the cases need to be assigned
    *       
    * @return - List
    * @see - Social_CaseReassignment (same class)
    */
    public static List<Case> reAssignAuditCases(Map<Id, List<Case>> caseMap,User rep){
    List<Case> updatedCases = new List<Case>(); // List of cases to be updated
    Datetime assignmentTime = datetime.now(); // To set the reassigned SLA's to start afresh
       
        for(String str: caseMap.keySet()){
             for(Case singleCase: caseMap.get(str)){
                     if(rep.Id != NULL){
                         singleCase.Closed_Operation_Manager__c = rep.Id;
                         Social_StreamingUtil.closedProcessed.add(singleCase.Id); 
                     }
                     updatedCases.add(singleCase);
                 }                 
             }            
        return updatedCases;
    }
    
    
      /**
    * < reAssignEvents() - Method to reassign Events when a Care Manager goes on vacation>
    * @param:
    *     Map<Id, List<Event>> eventMap,User rep - Map of Events and the user to whom the cases need to be assigned
    *       
    * @return - List
    * @see - Social_CaseReassignment (same class)
    */
    public static List<Event> reAssignEvents(Map<Id, List<Event>> eventMap,User rep){
    Map<Id, List<Event>> totalSLAmap = new Map<Id, List<Event>>(); // All the SLA's assigned to a user along with the SLA to his manager
    List<Event> updatedEvent = new List<Event>(); // List of SLA's to be udpated
    List<Event> deleteEvent = new List<Event>(); // List of SLA's to be deleted
    Set<Id> deleteSLAsetId = new Set<Id>(); //ID's of SLA's to be deleted
    Set<Id> totalSLAset = new Set<Id>(); // ID's of SLA's related to all the cases owned by the care manager from whom it needs to be reassigned
    Set<Id> replaceOwnerSet = new Set<Id>(); // ID's of the users who are being replaced
    Integer timePeriod = 15; // Time Interval to reset SLA1
    Integer reminderTime = 13; // Reminder time for SLA1
    Integer timePeriodSLA2 = 60; // Time Interval to reset SLA2
    Integer reminderTimeSLA2 = 45;  //Reminder time for SLA2
    Datetime assignmentTime = datetime.now(); // Required to reset the SLA to start afresh
    List<Task> deleteTaskList = new List<Task>();
      
    for(String str: eventMap.keySet()){
         for(Event singleSLA: eventMap.get(str)){
             if(!totalSLAset.contains(singleSLA.WhatId)){
                 totalSLAset.add(singleSLA.WhatId);
                 replaceOwnerSet.add(singleSLA.OwnerId);
             }
         }
    }
    
    for(Event singleSLA: [Select Id, OwnerId,Event_Type__c,WhatId,StartDateTime,DurationInMinutes,IsAllDayEvent,
                            IsReminderSet,ReminderDateTime from Event where WhatId IN: totalSLAset AND Event_Status__c != 'Closed']){          
              deleteSLAsetId.add(singleSLA.WhatId);           
          } 
         
     if(deleteSLAsetId.size()>0){
         for(Event singleSLA: [Select Id, WhatId, Event_Status__c from Event where WhatId IN: deleteSLAsetId AND Event_Status__c != 'Closed']){
             deleteEvent.add(singleSLA);
             Social_StreamingUtil.deleteSLAsetId.add(singleSLA.Id);
         }
     }
                  
     if(deleteEvent.size()>0){
         try{
             delete deleteEvent;
         }
         catch(DMLException e){
             system.debug('Error thrown while deleting SLAs: '+e);
         }
     }         
         return updatedEvent;                  
    }   
    
    
    /**
    * < reAssignOpsEvents() - Method to reassign Events when a Care Manager goes on vacation>
    * @param:
    *     Map<Id, List<Event>> eventMap,User rep - Map of Events and the user to whom the cases need to be assigned
    *       
    * @return - List
    * @see - Social_CaseReassignment (same class)
    */
    public static List<Event> reAssignOpsEvents(Map<Id, List<Event>> eventMap,User rep){
    Map<Id, List<Event>> totalSLAmap = new Map<Id, List<Event>>(); // All the SLA's assigned to a user along with the SLA to his manager
    List<Event> updatedEvent = new List<Event>(); // List of SLA's to be udpated
    List<Event> deleteEvent = new List<Event>(); // List of SLA's to be deleted
    Set<Id> deleteSLAsetId = new Set<Id>(); //ID's of SLA's to be deleted
    Set<Id> totalSLAset = new Set<Id>(); // ID's of SLA's related to all the cases owned by the care manager from whom it needs to be reassigned
    Set<Id> replaceOwnerSet = new Set<Id>(); // ID's of the users who are being replaced
    Integer timePeriod = 15; // Time Interval to reset SLA1
    Integer reminderTime = 13; // Reminder time for SLA1
    Integer timePeriodSLA2 = 60; // Time Interval to reset SLA2
    Integer reminderTimeSLA2 = 45;  //Reminder time for SLA2
    Datetime assignmentTime = datetime.now(); // Required to reset the SLA to start afresh
      
    for(String str: eventMap.keySet()){
         for(Event singleSLA: eventMap.get(str)){
             if(!totalSLAset.contains(singleSLA.WhatId)){
                 totalSLAset.add(singleSLA.WhatId);
                 replaceOwnerSet.add(singleSLA.OwnerId);
             }
         }
    }
    
    for(Event singleSLA: [Select Id, OwnerId,Event_Type__c,WhatId,StartDateTime,DurationInMinutes,IsAllDayEvent,
                            IsReminderSet,ReminderDateTime from Event where WhatId IN: totalSLAset AND Event_Status__c != 'Closed']){
        if(rep.Id != NULL){
        //To ensure the SLA for the care manager is being reassigned and not his Managers SLA's
            if(replaceOwnerSet.contains(singleSLA.OwnerId)){ 
                singleSLA.OwnerId = rep.Id;
            }
                 if(singleSLA.Event_Type__c == 'SLA - 1'){
                     singleSLA.StartDateTime = assignmentTime;
                     singleSLA.DurationInMinutes = timePeriod;
                     singleSLA.IsAllDayEvent = False;
                     singleSLA.IsReminderSet = true;
                     singleSLA.ReminderDateTime = assignmentTime.addMinutes(reminderTime);
                 }
                 if(singleSLA.Event_Type__c == 'SLA - 2'){
                     singleSLA.StartDateTime = assignmentTime;
                     singleSLA.DurationInMinutes = timePeriodSLA2;
                     singleSLA.IsAllDayEvent = False;
                     singleSLA.IsReminderSet = true;
                     singleSLA.ReminderDateTime = assignmentTime.addMinutes(reminderTimeSLA2);
                 }
                 updatedEvent.add(singleSLA);
        } 
        else{    
            //SLA's to be deleted     
            deleteSLAsetId.add(singleSLA.WhatId);                 
        }                       
     }      
         
     if(deleteSLAsetId.size()>0){
         for(Event singleSLA: [Select Id, WhatId, Event_Status__c from Event where WhatId IN: deleteSLAsetId AND Event_Status__c != 'Closed']){
             deleteEvent.add(singleSLA);
             Social_StreamingUtil.deleteSLAsetId.add(singleSLA.Id);
         }
     }
             
     if(deleteEvent.size()>0){
         try{
             delete deleteEvent;
         }
         catch(DMLException e){
             system.debug('Error thrown while deleting SLAs: '+e);
         }
     }         
         return updatedEvent;
    }  
    
     /**
    * < updateCaseOwner() - Method to Update Cases when a User goes on vacation>
    * @param:
    *     List<Case> updatedCases - List of cases for which owner needs to be updated
    *       
    * @return - void
    * @see - Social_CaseReassignment (same class)
    */
    public static void updateCaseOwner(List<Case> updatedCases){            
        Database.SaveResult[] resultDB = database.update(updatedCases, false);
            try{
                Integer loopCount = 0;
                for(Database.SaveResult sr:resultDB)
                {                
                    if(!sr.isSuccess())
                    {                    
                        Database.Error err = sr.getErrors()[0];                            
                        System.debug('Social_CaseReassignment: Error while updating. ' +updatedCases.get(loopCount).getSObjectType() + err.getMessage());                
                    }
                    loopCount++;
                }
             }
             catch(Exception e){
                 System.debug('Social_CaseReassignment: Error handling Response. ' + e.getMessage());
             }
    }
   
     /**
    * < updateCaseSLAs() - Method to Update SLAs when a User goes on vacation>
    * @param:
    *     List<Event> updatedEvent - List of SLAs for which owner needs to be updated
    *       
    * @return - void
    * @see - Social_CaseReassignment (same class)
    */
    public static void updateCaseSLAs(List<Event> updatedEvent){
        Database.SaveResult[] resultDB = database.update(updatedEvent, false);
            try{
                Integer loopCount = 0;
                for(Database.SaveResult sr:resultDB)
                {                
                    if(!sr.isSuccess())
                    {                    
                        Database.Error err = sr.getErrors()[0];                            
                        System.debug('Social_CaseReassignment: Error while updating. ' +updatedEvent.get(loopCount).getSObjectType() + err.getMessage());                
                    }
                    loopCount++;
                }
             }
             catch(Exception e){
                 System.debug('Social_CaseReassignment: Error handling Response. ' + e.getMessage());
             }
    } 
    /**
    * < identifyReopenCases() - Method to assign reopen cases when a Care Manager goes on vacation>
    * @param:
    *     Map<Id,List<Case>> caseMap - Map of Business Cases that got reopened
    *       
    * @return - Void     
    * @see - BizReopenCaseReassignment trigger 
    */
      public static void identifyReopenCases(Map<Id,List<Case>> caseMap){  
      Set<Id> usersOnVacation = new Set<Id>();
       User availUser = new User();      
           for(User singleUser:[Select Id, Availability__c, Case_Counter__c, Name, ManagerId from User where Id IN: caseMap.keySet() AND Availability__c = 'Vacation']){
                    usersOnVacation.add(singleUser.Id);                
           }
           reAssignOnVacationBusiness(usersOnVacation);
           
           
      }   
      
      /**
    * < updateAssignmentCount() - Method to update the Cases Owned count against each user
    * @param:
    *     Set<Id> careManagerSet - General-bc users
    *     Set<Id> careManagerEscalationBCQSet - Escalation-bc users
    *       
    * @return - Void     
    * @see - same class
    */
      public static void updateAssignmentCount(Set<Id> careManagerSet, Set<Id> careManagerEscalationBCQSet){  
      List<Assignment_Groups__c> updatedGroupMember = new List<Assignment_Groups__c>();
          for(Assignment_Groups__c singleMember: [Select Id, User__c, Cases_Owned__c from Assignment_Groups__c where User__c IN: careManagerSet OR User__c IN: careManagerEscalationBCQSet]){
              if(singleMember.Cases_Owned__c != NULL || singleMember.Cases_Owned__c !=0){
                  singleMember.Cases_Owned__c = 0;
                  Social_StreamingUtil.caseCounterZeroAfterVacation = TRUE ;
                  updatedGroupMember.add(singleMember);
              }
          } 
          
          if(updatedGroupMember.size()>0){
              try{
                  update updatedGroupMember;
              }
              catch(DMLException e){
                  system.debug('Error thrown while updating Assignment Group: '+e);
              }
          }
      } 
}