/* Version History
Aug 15th 2013:ITS-000127: Update the case assignment rules so that only cases with the status of NEW are looked at before new assignments are sent. 
                           -- Addition of the criterias for the Consumer Cases and Business criteria are as in
   Deployment Date: 28th August 2013
   
18th December 2013 Release: ITS-000309
*    Release 19th August - ITS1707 Reopening of Business Case (status field editable)
*/
public class Social_validateCaseQueueUtil{
  // Running User Context
  String contextUserId = Userinfo.getUserId();
  // Static Class Variable
  private static String CASE_CLOSED = 'Closed';
  private static String CASE_AUTO_CLOSED = 'Auto Closed';
  private static String CASE_REOPENED = 'Reopen';
  private static String CASE_ONHOLD = 'Follow Up Hold';
  private static String CASE_INVESTIGATE = 'Investigating';
  private static String CASE_ESCALATED = 'Escalated';
  private static String CASE_REASSIGNED = 'Reassigned';
  public Id bsCaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Case'); // Stores record type id of Business Care Closed case Record Type
  public Id bsQACaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Case QA Record Type'); // Stores record type id of Business Care QA Record Type , added by ashween for ITS#1334
        
  // Local Class Variables
  private boolean isScrubTeamMember;
  private List<Event> updateEventList = new List<Event>();
  private List<Event> updateCustomEventList = new List<Event>();
  private List<Task> updateTaskList =  new List<Task>();
  private Map<String, List<Task>> caseTaskMap = new Map<String, List<Task>>();
  private set<Id> newCaseIdset =  new set<Id>();
  Set<Case> ReassignedCaseSet = new Set<Case>();
  Set<Case> assignedCaseSet = new Set<Case>();
  private Map<Id, Map<String, List<Event>>> caseEventMap = new Map<Id, Map<String, List<Event>>>();
  private Map<String, String> recordTypeMap= new Map<String,String>();
  // Manager Assignment Util Class
  Social_CaseUtilHandler managerUtilClass = new Social_CaseUtilHandler();
  // SLA Event Util Class
  Social_slaEventHandler eventHandler = new Social_slaEventHandler();
  // Case Team Util Class
  Social_caseTeamUtilHandler caseTeamHandler = null;
  // Constructor (Insert)
  public Social_validateCaseQueueUtil(Id userId , set<Id> newIdset){
    newCaseIdset.addAll(newIdset);
    // Check Logged In User For Scrub Team Member
    isScrubTeamMember = checkScrubTeamMember(userId);
    // Initialize Case Team Handler
    List<Id> caseIdList = new List<Id>();
    caseIdList.addAll(newIdset);
    caseTeamHandler = new Social_caseTeamUtilHandler(caseIdList);
    // Create Case Related Event Map
    for(Event caseEvent: [Select e.WhatId, e.OwnerId, e.Id, e.Event_Type__c, e.Event_Status__c From 
                          Event e where e.WhatId IN: newIdset]){
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
    }
      recordTypeMap  = eventHandler.getRecordTypes(); 
  }
  // Method To Process Case Update
  public void processUpdatedCase(Case newCase, Case oldCase){
    // Method Variables
    boolean changeStatus = false;
    boolean caseInitialPostUpdate = false;
    // Check For Initial Post Update (Radian-6 Post Update)
    if(oldCase.R6Service__InitialPostId__c == null && newCase.R6Service__InitialPostId__c != null){
        // Update The Flag
        caseInitialPostUpdate = true;
    }
    //Record type check for the Consumer Cases for Case Counter:
            boolean IsCaseConsumer = false;
            if(!recordTypeMap.isEmpty()){
               String strRecordType = recordTypeMap.get(newCase.RecordTypeId);
               if(strRecordType!=null && !strRecordType.equals('') && strRecordType.contains('Consumer') ){
                 IsCaseConsumer = true;
               }
             }            
    // Prevent Edit On Closed Cases (Exclude SCRUB Team/Batch Audit Updates)
    //Mallaiah: Updated validation condition, do not allow case status to be changed once case is closed
    /***********************CONSUMER VALIDATION******************************/
    if((CASE_CLOSED.equalsIgnorecase(oldCase.Status) || CASE_AUTO_CLOSED.equalsIgnorecase(oldCase.Status)) && !Social_StreamingUtil.AutoClosedOwnerSet.contains(newCase.Id) && !Social_StreamingUtil.closedProcessed.contains(newCase.Id) &&!isScrubTeamMember 
        && newCase.RecordTypeId!=null && managerUtilClass.checkCaseConsumerCare(newCase) && (newCase.Audit_Status__c !=null || newCase.Audit_Status__c !='' )
        && (oldCase.Audit_Status__c == Null || (oldCase.Audit_Status__c != Null && newCase.Audit_Status__c.equalsIgnorecase(oldCase.Audit_Status__c))) && newCase.No_Of_Audit_Responses__c==oldCase.No_Of_Audit_Responses__c 
        && newCase.Total_Audit_Score__c==oldCase.Total_Audit_Score__c && newCase.Audit_Score__c==oldCase.Audit_Score__c 
        && newCase.Possible_Score__c==oldCase.Possible_Score__c && newCase.Final_audit_score__c==oldCase.Final_audit_score__c
        && RecursionController.controller){  
        newCase.adderror('Operation Failed. Closed Cases Can Only Be Updated By SCRUB Team Members.');
    }
    /******Logic to uncheck No contact email available when case is reopened manually**************/
    if((CASE_CLOSED.equalsIgnorecase(oldCase.Status) || CASE_AUTO_CLOSED.equalsIgnorecase(oldCase.Status))&& (newcase.status!='Closed' && newcase.Status!='Auto Closed'))
    {
        newcase.No_Contact_Email_Available__c=false;
    }
    /***********************BUSINESS VALIDATION******************************/
    if(newCase.Closed_Operation_Manager__c != null){
        // Not to allow Care Managers to perform any edit on closed case except case status change
        if((CASE_CLOSED.equalsIgnorecase(oldCase.Status) || CASE_AUTO_CLOSED.equalsIgnorecase(oldCase.Status)) && !Social_StreamingUtil.AutoClosedOwnerSet.contains(newCase.Id) && !Social_StreamingUtil.closedProcessed.contains(newCase.Id) && !isScrubTeamMember
            && newCase.RecordTypeId!=null && !managerUtilClass.checkCaseConsumerCare(newCase) && !contextUserId.equalsIgnoreCase(newCase.Closed_Operation_Manager__c) && newCase.Closed_Operation_Manager__c.equals(oldCase.Closed_Operation_Manager__c) && CASE_CLOSED.equalsIgnorecase(newCase.Status) ){
            newCase.adderror('Operation Failed.You do not have sufficient privilege to edit closed cases.');
        }
     }    
    //Close case and SLA's if any of the Case Reasons are used a. Duplicate b. No outreach c. Not SM owned
    if(newCase.status!=null && !CASE_CLOSED.equalsIgnorecase(oldCase.Status) && !CASE_AUTO_CLOSED.equalsIgnorecase(oldCase.Status) && !CASE_REOPENED.equalsIgnorecase(newCase.Status) /*&& newCase.RecordTypeId!=null*/ && managerUtilClass.checkCaseConsumerCare(newCase) && newCase.Reason!=null && /*Social_triggerRunControl.isTriggerFirstRun &&*/ newCaseIdset!=null && !newCaseIdset.isEmpty()){
      if((newCase.Reason).equalsIgnoreCase('Duplicate') || (newCase.Reason).equalsIgnoreCase('No Outreach') || (newCase.Reason).equalsIgnoreCase('Not SM Owned')){   
        //Create a List of all tasks for the Cases.
        for(Task caseTask: [Select t.WhatId, t.Status from Task t where t.WhatId IN: newCaseIdset and t.status!='Completed']){           
          if(caseTaskMap.containsKey(caseTask.WhatId)){
            List<Task> existingTaskList = caseTaskMap.get(caseTask.WhatId);
            existingTaskList.add(caseTask);
            caseTaskMap.put(caseTask.WhatId, existingTaskList);
          }
          else{
            List<Task> newTaskList =  new List<Task>();
            newTaskList.add(caseTask);
            caseTaskMap.put(caseTask.WhatId, newTaskList);
          }
        }
        if(newCase.status!=null && !(newCase.status).equals('Closed') && !CASE_AUTO_CLOSED.equalsIgnorecase(newCase.Status)){
          newCase.status = 'Closed';
        }
        if(newCase.status!=null && ((newCase.status).equals('Closed') || CASE_AUTO_CLOSED.equalsIgnorecase(newCase.Status))){
            // Private Method For Event Closure
            // Private method for Task Closure
            closeAllCaseCustomTasks(newCase.Id);
            closeSlaEvent(newCase.Id, '', true);
        }
      }
    }
    // Capture Case Status Updates
    if(newCase.Status!=null && oldCase.Status!=null && !newCase.Status.equalsIgnorecase(oldCase.Status) && Social_triggerRunControl.isTriggerFirstRun){
        // Mark Case for Status Update
        changeStatus = true;  
        // Case Re-Opening (Closed -> Reopen)
        if(CASE_REOPENED.equalsIgnorecase(newCase.Status) && (CASE_CLOSED.equalsIgnorecase(oldCase.Status) || CASE_AUTO_CLOSED.equalsIgnorecase(oldCase.Status))){
            // Set Case Re-Open Flag On Case
            newCase.Case_Reopen_Flag__c = true;
            // Closed Care Manager Is Available / Business Care Case - No Round Robin
            if((!managerUtilClass.checkCaseConsumerCare(newCase) && 'false'.equalsIgnorecase(System.Label.Business_Care_Enable_Round_Robin)) || 'Available'.equalsIgnorecase(managerUtilClass.getUserAvailabilty(newCase.OwnerId))){   
                newCase.Skip_Assignment_Rule__c = true;
            }
            // Closed Care Manager Is UnAvailable
            else if(!'Available'.equalsIgnorecase(managerUtilClass.getUserAvailabilty(newCase.OwnerId))){
            // Check For Second SLA Initiation
            if('SLA1 - Ended'.equalsIgnorecase(newCase.Current_SLA_Phase__c)) 
                // Set the Second SLA Post Flag
                newCase.Second_SLA_Pending_Post__c = true;
            }
        }
        // Case Closure (Any Stage -> Closed/On Hold/Escalated/Reassigned)
        if(CASE_CLOSED.equalsIgnorecase(newCase.Status) || CASE_AUTO_CLOSED.equalsIgnorecase(newCase.Status) || CASE_ONHOLD.equalsIgnorecase(newCase.Status) || CASE_ESCALATED.equalsIgnorecase(newCase.Status) || CASE_REASSIGNED.equalsIgnorecase(newCase.Status)){
            // Check if the case Owner is not a Queue before case closure
            if((CASE_CLOSED.equalsIgnorecase(newCase.Status) || CASE_AUTO_CLOSED.equalsIgnorecase(newCase.Status)) && newCase.Is_Auto_Closed__c == false && managerUtilClass.checkCaseOwnerQueue(newCase.OwnerId)){
              if(newCase.ownerid!=Label.SLA1_Transition_Queue_ID){
                newCase.adderror(' Case owner is a Queue. Please assign it to a user for closure.');
                }
            }
            // Check if the case Owner is not a Queue before case closure
            if(CASE_ONHOLD.equalsIgnorecase(newCase.Status) && managerUtilClass.checkCaseOwnerQueue(newCase.OwnerId)){
                newCase.adderror(' Case owner is a Queue. Please assign it to an user for status change.');
            }
            // Closed Operation Manager Update
            if(CASE_CLOSED.equalsIgnorecase(newCase.Status)){ 
                // Update Closed Care Manager Field
                if(newCase.ownerid!=Label.SLA1_Transition_Queue_ID){
                    newCase.Closed_Care_Manager__c = newCase.OwnerId;
                }
                if(Label.SLA1_Transition_Queue_ID.equalsIgnorecase(newCase.ownerid)){
                    newCase.Closed_Care_Manager__c = newCase.Initial_OutReach_Manager__c;
                }
                // Update Closed Operations Manager Field
                newCase.Closed_Operation_Manager__c = eventHandler.getRelatedOperationManager(newCase.OwnerId);
                // Local Variable
                String slaType='';
                newCase.Customer_Response_Received__c = false;//Making customer response received checkbox to false
                // Automated SLA End On Case Closure (SLA-1 Closure)
                if(newCase.Current_SLA_Phase__c == 'SLA1 - Initiated'){
                    newCase.Current_SLA_Phase__c = 'SLA1 - Ended';
              if(newCase.RecordTypeId!=null && managerUtilClass.checkCaseConsumerCare(newCase) && newCase.Reason!=null && Social_triggerRunControl.isTriggerFirstRun && ((newCase.Reason).equalsIgnoreCase('Duplicate') || (newCase.Reason).equalsIgnoreCase('No Outreach') || (newCase.Reason).equalsIgnoreCase('Not SM Owned'))){
                    newCase.First_SLA_Response_Time__c = datetime.now();
                  }
                  else{
                    newCase.First_SLA_Response_Time__c = datetime.now();
                  } 
                  slaType= 'SLA - 1';
                }
                // (SLA-2 Closure)
                else if(newCase.Current_SLA_Phase__c == 'SLA2 - Initiated'){
                  newCase.Current_SLA_Phase__c = 'SLA2 - Ended'; 
                  if(newCase.RecordTypeId!=null && managerUtilClass.checkCaseConsumerCare(newCase) && newCase.Reason!=null && Social_triggerRunControl.isTriggerFirstRun && ((newCase.Reason).equalsIgnoreCase('Duplicate') || (newCase.Reason).equalsIgnoreCase('No Outreach') || (newCase.Reason).equalsIgnoreCase('Not SM Owned'))){
                    newCase.Second_SLA_Response_Time__c = datetime.now();
                  }
                  else{
                    newCase.Second_SLA_Response_Time__c = datetime.now();
                  } 
                  slaType= 'SLA - 2';
                }
                // (SLA-3 Closure)
                else if(newCase.Current_SLA_Phase__c == 'SLA3 - Initiated'){
                  newCase.Current_SLA_Phase__c = 'SLA3 - Ended';   
                  if(newCase.RecordTypeId!=null && managerUtilClass.checkCaseConsumerCare(newCase) && newCase.Reason!=null && Social_triggerRunControl.isTriggerFirstRun && ((newCase.Reason).equalsIgnoreCase('Duplicate') || (newCase.Reason).equalsIgnoreCase('No Outreach') || (newCase.Reason).equalsIgnoreCase('Not SM Owned'))){
                    newCase.Third_SLA_Response_Time__c = datetime.now();
                  }
                  else{
                    newCase.Third_SLA_Response_Time__c = datetime.now();
                  }                   
                  slaType= 'SLA - 3';
                }
                // Private Method For Event Closure
                closeSlaEvent(newCase.Id,slaType, false); 
            }
        }
    }
    
    // Closed Case Re-Open Scenario (Care Manager - Available -> Assign Closed Care Manager Back/ Initiate Second SLA)
    if(String.valueof(newCase.OwnerId).contains(System.Label.Case_Reopen_Queue_Id) && newCase.Case_Reopen_Flag__c && newCase.Skip_Assignment_Rule__c){
        //Removed logic for case reopen queue for consumer and business 
    }
    // Track Owner Change (Social Care - Any User/Any Queue -> Social Care Queue)
    else if(oldCase.OwnerId!=newCase.OwnerId && managerUtilClass.checkRoundRobinQueue(newCase.OwnerId) && (Social_triggerRunControl.isTriggerFirstRun || newCase.Case_Reopen_Flag__c || caseInitialPostUpdate || newCase.Manual_Case_Indicator__c)){
        boolean checkPostTag = checkCaseTags(newCase.OwnerId , newCase.Case_PostTag__c);
        // Check Case Post Tags
        if(!checkPostTag && !Social_StreamingUtil.businessAssignQueue.contains(newCase.Id)){
            newCase.adderror('Wrong Queue Assigned. Please Update Case Post Tags Accordingly.');
        }
        else{
            // Track Case Queue
            //Logic to prevent update on track case queue field if new owner is pending closure queue
            if (newCase.OwnerId != System.Label.PendingClouseQueueId) {
                newCase.Track_Case_Queue__c = newCase.OwnerId;
            }
            String strQueueType = managerUtilClass.checkQueueOwner(newCase.OwnerId);
            // Update Record Type
            if(newCase.RecordTypeId!=null && !managerUtilClass.checkCaseConsumerCare(newCase)){
                // Business Case -> Consumer Queue
                newCase.RecordTypeId = managerUtilClass.generateCaseRecordId('Consumer Care Case');
            }
            // Update Record Type
            if(newCase.RecordTypeId!=null && !managerUtilClass.checkCaseConsumerCare(newCase)){ 
                // Business Case -> Consumer Queue
                //Flipping record type only if case moving from BSC Queue to CSC Queue
                // Business Case -> Consumer Queue
                if(strQueueType!=null && strQueueType.equalsIgnoreCase('Consumer')){
                    newCase.RecordTypeId = managerUtilClass.generateCaseRecordId('Consumer Care Case');
                }
            }
            if(newCase.RecordTypeId!=null && managerUtilClass.checkCaseConsumerCare(newCase)){
                if(strQueueType!=null && strQueueType.equalsIgnoreCase('Business')){
                   newCase.RecordTypeId = managerUtilClass.generateCaseRecordId('Business Care Case');
                }
            }               
            // Track Old Case Owner-Manager/Decrement Case Counter/Add Case Team (After Initial Assignment)
            if(managerUtilClass.checkCaseOwnerUser(oldCase.OwnerId)  && (newCase.Case_Assigned_Time__c!=null || newCase.Manual_Case_Indicator__c)){
                // Case Count Decrement For Prior Owner(Except Initial Assignment/Skip Second SLA System Re-Assign/Skip Closed/Follow Up Cases)
                // Track Old Owner/Manager
                newCase.Prior_Care_Manager__c = oldCase.OwnerId;
                newCase.Prior_Operation_Manager_Email__c = eventHandler.getRelatedOperationManagerEmail(oldCase.OwnerId);
                // Add Old Case Owner To Case Team (If Not Queue)
                caseTeamHandler.addCaseTeamMember(newCase.Id, oldCase.OwnerId);
                // Reset Manual Case FLag
            }
        }
    }
    // Track Owner Change (Business Care - Any User/Any Queue -> Business Care Queue)
    else if(oldCase.OwnerId!=newCase.OwnerId && managerUtilClass.checkCaseOwnerQueue(newCase.OwnerId) && !managerUtilClass.checkRoundRobinQueue(newCase.OwnerId) && Social_triggerRunControl.isTriggerFirstRun ){
            String strQueueType = managerUtilClass.checkQueueOwner(newCase.OwnerId);
            //Change status for a consumer Care Case
            if(newCase.RecordTypeId!=null && managerUtilClass.checkCaseConsumerCare(newCase) && newCase.OwnerId!=null && (String.valueOf(Label.SLA1_Transition_Queue_ID)).contains(String.valueOf(newCase.OwnerId))){
              if(newCase.status!=null && 'New'.equalsIgnorecase(newCase.Status)){
                  newCase.status = CASE_INVESTIGATE;
              }
            }
            //Logic to prevent update on track case queue field if new owner is pending closure queue
            if (newCase.OwnerId != System.Label.PendingClouseQueueId) {
                newCase.Track_Case_Queue__c = newCase.OwnerId;
            }
            // Update Record Type 
            if(newCase.RecordTypeId!=null && managerUtilClass.checkCaseConsumerCare(newCase)){
                // Consumer Case -> Business Queue
                if(strQueueType!=null && strQueueType.equalsIgnoreCase('Business')) {
                    newCase.RecordTypeId = managerUtilClass.generateCaseRecordId('Business Care Case');
                }
            }
            // Track Old Case Owner-Manager/Decrement Case Counter/Add Case Team (After Initial Assignment)
            if(newCase.Case_Assigned_Time__c!=null && managerUtilClass.checkCaseOwnerUser(oldCase.OwnerId)){  
                // Track Old Owner/Manager
                newCase.Prior_Care_Manager__c = oldCase.OwnerId;
                newCase.Prior_Operation_Manager_Email__c = eventHandler.getRelatedOperationManagerEmail(oldCase.OwnerId);
                // Add Old Case Owner To Case Team (If Not Queue)
                caseTeamHandler.addCaseTeamMember(newCase.Id, oldCase.OwnerId);
            }
     }
     // Track Owner Change (Business Care/Consumer Care - Any Queue -> User)
     else if(oldCase.OwnerId!=newCase.OwnerId && managerUtilClass.checkCaseOwnerQueue(oldCase.OwnerId) && managerUtilClass.checkCaseOwnerUser(newCase.OwnerId) && Social_triggerRunControl.isTriggerFirstRun){ 
       // Track Case Queue (Very First Assignment)
       //Logic to prevent update on track case queue field if old owner is pending closure queue
       if(newCase.Case_Assigned_Time__c==null && oldCase.OwnerId != System.Label.PendingClouseQueueId){
            newCase.Track_Case_Queue__c = oldCase.OwnerId;
       }
       // Update Assigned Operations Manager(First Assignment Only)                 
       if(newCase.Assigned_Operation_Manager__c==null){     
              newCase.Assigned_Operation_Manager__c=eventHandler.getRelatedOperationManager(newCase.OwnerID);        
       }    
       // Track New Operation Manager Email(After Initial Assignment)
       if(newCase.Case_Assigned_Time__c!=null){     
            // Flag To Prevent Trigger Recursion / Update Current Owner Manager
            newCase.Track_Case_Owner_Change__c = true;
            newCase.Current_Operation_Manager_Email__c = eventHandler.getRelatedOperationManagerEmail(newCase.OwnerId);
       }
       // Initial Assignment
       datetime assignmentTime = datetime.now();
       if(newCase.First_SLA_Scheduled_Time__c==null ){
            // Create First SLA Event
            eventHandler.createSlaEvents(newCase, newCase.OwnerID, assignmentTime, 'SLA - 1'); 
            // Update SLA on Case
            newCase.Current_SLA_Phase__c = 'SLA1 - Initiated';
            newCase.Update_Reason__c = Social_StreamingUtil.MANUAL;
            newCase.Customer_Response_Received__c = true; //DNR: added to put customer response when sla1 initiate.
            newCase.NonCaseOwner_LastModifiedDate__c = system.now();            
            if(newCase.Case_Assigned_Time__c == null){
                newCase.Case_Assigned_Time__c = assignmentTime;
                assignedCaseSet.add(newCase);
            }else if(newCase.Moved_to_Prior_Care_Manager__c == false) {
                newCase.Case_Reassigned_Time__c = assignmentTime;
                ReassignedCaseSet.add(newCase);
            }
            newCase.First_SLA_Scheduled_Time__c = assignmentTime.addMinutes(15);
            //Aditya: Logic to flip record type to HS Care Rep or vice versa
            newCase = Social_SocialPostSCSHandler.flipCaseRTBasedOnProfile(newCase);
       } else if (newCase.Second_SLA_Scheduled_Time__c==null && newCase.Second_SLA_Response_Time__c==null && newCase.Current_SLA_Phase__c == 'SLA1 - Ended' && userInfo.getName() != 'Automated Admin' && !userInfo.getUserId().contains('005E0000002G4RU') && Boolean.valueOf(Label.ActivateSlaReset) && newCase.Customer_Response_Received__c) {
           // Create First SLA Event
           eventHandler.createSlaEvents(newCase, newCase.OwnerID, assignmentTime, 'SLA - 2'); 
           // Update SLA on Case
           newCase.Current_SLA_Phase__c = 'SLA2 - Initiated'; //DNR: Prod Fix.added to update sla2 initiate. 1/14 release.
           newCase.Update_Reason__c = Social_StreamingUtil.MANUAL;
           newCase.NonCaseOwner_LastModifiedDate__c = system.now();          
           newCase.Second_SLA_Scheduled_Time__c = assignmentTime.addMinutes(60);
           newCase.Second_SLA_Start_Time__c = assignmentTime;
           if(newCase.Moved_to_Prior_Care_Manager__c == false){
               newCase.Case_Reassigned_Time__c = assignmentTime;
           }
           eventHandler.createSlaTasks(newCase.Id, newCase.OwnerId, 'SLA-2 Customer Response Task', 'SLA-2 Social Post Customer Response', 'SLA - 2', true);
           //Aditya: Logic to flip record type to HS Care Rep or vice versa
           newCase = Social_SocialPostSCSHandler.flipCaseRTBasedOnProfile(newCase);
       //Aditya: Logic to flip case record type in case nesting profile assign case with SLA2 - ended stage
       } else if (newCase.Current_SLA_Phase__c == 'SLA2 - Ended' && newCase.Status != 'Auto Closed' && newCase.Status != 'Closed') {
           newCase = Social_SocialPostSCSHandler.flipCaseRTBasedOnProfile(newCase);
       }
       if(!ReassignedCaseSet.isEmpty()){
           Social_markCaseUpdates.CaseReassignments(ReassignedCaseSet, Social_StreamingUtil.MANUAL,Social_StreamingUtil.REASSIGNED);
       }
       if(!assignedCaseSet.isEmpty()){
           Social_markCaseUpdates.CaseReassignments(assignedCaseSet, Social_StreamingUtil.MANUAL,Social_StreamingUtil.ASSIGNED);
       }
    } 
    // Track Owner Change (Business/Consumer -> User to User)
     else if(oldCase.OwnerId!=newCase.OwnerId && managerUtilClass.checkCaseOwnerUser(newCase.OwnerId) && managerUtilClass.checkCaseOwnerUser(oldCase.OwnerId) && !String.valueof(newCase.OwnerId).contains(System.Label.Second_SLA_Queue) && !String.valueof(oldCase.OwnerId).contains(System.Label.R6_Integration_User_Id) && !String.valueof(newCase.OwnerId).contains(System.Label.Default_Case_Owner) && Social_triggerRunControl.isTriggerFirstRun /* && newCase.Manual_Case_Indicator__c */){  
            // Add Old Owner To Case Team
            caseteamHandler.addCaseTeamMember(newCase.Id, oldCase.OwnerId);
            // Track Prior Care Manager/Prior Operations Manager/Current Operations Manager
            newCase.Track_Case_Owner_Change__c = true;
            newCase.Prior_Care_Manager__c = oldCase.OwnerId;
            newCase.Prior_Operation_Manager_Email__c = eventHandler.getRelatedOperationManagerEmail(oldCase.OwnerId);
            newCase.Current_Operation_Manager_Email__c = eventHandler.getRelatedOperationManagerEmail(newCase.OwnerId);
    } 
    String newCaseOwnerId = newCase.OwnerId;    
    if(!changeStatus && (oldCase.Case_Assigned_Time__c!=null || newCase.Manual_Case_Indicator__c) && contextUserId!=null && (contextUserId.equalsIgnoreCase(newCase.OwnerId) || contextUserId.equalsIgnoreCase(oldCase.OwnerId)) && ('New'.equalsIgnorecase(newCase.Status) || 'Reopen'.equalsIgnorecase(newCase.Status)) && Social_StreamingUtil.preventStatusUpdateWhenDNETriggerFires && !newCaseOwnerId.StartsWith('00G')){
        // Care Manager Updates Only
        newCase.Status = CASE_INVESTIGATE;
    }
    // Reset Automated System Re-Assignment Flag
    if(newCase.Case_System_Reassign__c){
        // Second SLA System Re-assignment
        newCase.Case_System_Reassign__c = false;   
    }   
  }
  // Public Method To Process Case Insert
  public void processInsertedCase(Case newCase){
    // Check If Case Is Manually Created (Clone/New)
    if('true'.equalsIgnoreCase(newCase.Is_Case_Cloned__c) || (!'Engagement Console'.equalsIgnoreCase(newCase.Origin) && !'Social Hub'.equalsIgnoreCase(newCase.Origin) && !String.valueOf(newCase.OwnerId).contains(System.label.Automated_Case_UserId))){
        // Flag To Prevent Re-assignment During Manual Case Creation
        Social_triggerRunControl.assignByAssignRules = true; 
    }
    // Clear SLA Fields(Clone)
    newCase.Current_SLA_Phase__c = null;
    newCase.Case_Assigned_Time__c = null;
    newCase.First_SLA_Scheduled_Time__c = null;
    newCase.First_SLA_Response_Time__c =  null;
    newCase.Second_SLA_Start_Time__c = null;
    newCase.Second_SLA_Scheduled_Time__c = null;
    newCase.Second_SLA_Response_Time__c = null;
    newCase.Third_SLA_Start_Time__c = null;
    newCase.Third_SLA_Scheduled_Time__c = null;
    newCase.Third_SLA_Response_Time__c = null;
    newCase.Assigned_Operation_Manager__c = null;
    newCase.Closed_Operation_Manager__c = null;
    newCase.Reassignment_Reason__c = null;
    newCase.First_Post_Resolution__c = false;
    newCase.Reason = null;
  }
  // Static method the update the contact fields in Last Case Close . Created By Mallaiah
 
  public static void updateConLastCaseClose(set<id> ContactIds){
      list<contact> UpdateConlist = new list<contact>();
      if(!ContactIds.isEmpty()){
          for(contact con :[select id,Last_Case_Closed__c from contact where id IN : ContactIds]){
              con.Last_Case_Closed__c = System.Now();
              UpdateConlist.add(con); 
          }
      }
     if(!UpdateConlist .isEmpty()){
         update UpdateConlist ;
     }
 }
  
  // Public Method Database Transactions
  public void performDatabaseSaves(){
      // Update Care Manager TimeStamp
      managerUtilClass.updateCaremanagerTimestamp();
      // Insert Task List
      eventHandler.insertEventData();
      // Insert Case Team Members
      if(caseTeamHandler!=null){
         caseTeamHandler.insertCaseTeamDetails();
      }
      // SLA Event Closure
      if(!updateEventList.isEmpty()){
        try{
            update updateEventList;
        }
        catch(Exception Exp){
            System.debug('EXCEPTION WHILE EVENT CLOSURE:' + Exp.getmessage());
        }
     }
     // SLA Event Closure
     if(!updateCustomEventList.isEmpty()){
        try{
            update updateCustomEventList;
        }
        catch(Exception Exp){
            System.debug('EXCEPTION WHILE EVENT:' + Exp.getmessage());
        }
     }
     if(updateTaskList!=null && updateTaskList.size()>0){
       try{
         update updateTaskList;
      }
      catch(Exception e){
         System.debug('Exception while trying to update the tasks to closed status '+e.getmessage());
      }
     }
  }
  // Private Method To Check If Context User Part Of SCRUB Team
  private boolean checkScrubTeamMember(Id loggedUserId){
    PermissionSetAssignment[] scrubMember = [Select p.PermissionSetId, p.Id, p.AssigneeId From PermissionSetAssignment p where 
                                             p.AssigneeId=: loggedUserId and p.PermissionSetId=: Label.ScrubTeamId limit 1];
    if(scrubMember.size()>0 || (Userinfo.getProfileId()!=null && Userinfo.getProfileId().substring(0,15).equalsIgnoreCase(Label.SystemAdminProfileId))){
        return true;
    }
    return false;              
  }
  // Private Method To Check Case Skill-Queue Skill Tags
  private boolean checkCaseTags(Id caseQueueOwner, String caseTags){
    // Get Group Related Tags
    boolean validPostTag = false;
    String groupName = managerUtilClass.getRelatedGroupName(caseQueueOwner);
    // No Check If General Queue.
    if(groupName!=null && 'Unknown'.equalsIgnorecase(groupName)){
        validPostTag = true;
    }
    // Check Post Tags For Non-General Queues
    else if(groupName!=null){
        // Query Required Custom Setting
        Post_Tags__c queueTag = Post_Tags__c.getInstance(groupName);
        Set<String> queueTagSet = new Set<String>(queueTag.Radian_Tags__c.split(';'));
       // Check If Post Tag Not Null
        if(caseTags!=null && caseTags!=''){
            List<String> caseTagList = new List<String>(caseTags.split(Label.PostTag_Delimiter));
            // Check For Queue Tag
            for(String caseTag: caseTagList){
                if(queueTagSet.contains(caseTag.trim().toUpperCase())){
                    validPostTag = true;
                    break;
                }
            }
        }
    }
    return validPostTag;            
  }
  // Private Method For Event Closure
  private void closeSlaEvent(Id CaseId, String slaType, Boolean allEvents){
      Social_StreamingUtil.doNotFireUpdateReason = false;//flag to deactiavte logic to update the update reason field on case
      if(caseEventMap.get(CaseId)!=null && caseEventMap.get(CaseId).get(slaType)!=null &&!allEvents){
          List<Event> closeEventList = caseEventMap.get(CaseId).get(slaType);
          for(Event caseEvent: closeEventList){
              caseEvent.Event_Status__c = CASE_CLOSED;
              updateEventList.add(caseEvent);
          }
      }
    if(allEvents && caseEventMap.get(CaseId)!=null){
      List<Event> closeAllEvents = new List<Event>();
      for(List<Event> eventList: caseEventMap.get(CaseId).values()){
        closeAllEvents.addAll(eventList);
      }
      for(Event caseEvent: closeAllEvents){
        caseEvent.Event_Status__c = CASE_CLOSED;
        caseEvent.IsReminderSet = false;
        updateCustomEventList.add(caseEvent);
      }
    }
  }
  private void closeAllCaseCustomTasks(Id CaseId){
      Social_StreamingUtil.doNotFireUpdateReason = false;//flag to deactiavte logic to update the update reason field on case
    if(caseTaskMap.get(CaseId)!=null && CaseId!=null){
      List<Task> caseTaskList = caseTaskMap.get(CaseId);
      if(caseTaskList.size()>0){
        for(Task caseTask: caseTaskList){
          caseTask.Status = 'Completed';
          updateTaskList.add(caseTask);
        }
      }
    }
  }
  public String getEngagementConsoleUserId(Id caseId, boolean isInsert, Id userId){
    String strId = '';
    if(caseId!=null && !isInsert){
        try{
            CaseHistory ch = [Select c.OldValue From CaseHistory c where c.CaseId = : caseId and c.Field = 'ownerAssignment' and IsDeleted = false and createdById = : System.label.Radian6forSalesforcedotcom order by createdDate asc limit 1];
            if(ch!=null && ch.OldValue!=null && !String.valueOf(ch.OldValue).equals('')){
                strId = String.valueOf(ch.OldValue);
            }
        }
        catch(Exception e){
            System.debug('Error here : '+e.getMessage());
        }
    }
    else if(isInsert && userId!=null){
        try{
            User u = [Select u.Name From User u where u.id = : userId];
            if(u!=null && u.Name!=null && !String.valueOf(u.Name).equals('')){
                strId = u.Name;
            }
        }
        catch(Exception e){
            System.debug('Error here getEngagementConsoleUserId user loop : '+e.getMessage());
        }
    }
    return strId;  
  }
}