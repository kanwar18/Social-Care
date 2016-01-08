public class Social_SocialPostTaskCreatorUtil 
{
   // Static Variables
   private static String SLA_STAGE_START = 'SLA1 - Ended';
   private static String SLA_STAGE_RESET = 'SLA2 - Initiated';
   private static String SLA_EVENT_TYPE = 'SLA - 2';
   private static String CASE_REOPEN_STATUS = 'Reopen';
   private static String SLA_TASK_SUBJECT = 'SLA-2 Customer Response Task';
   
   // Class Variables
   List<Task> slaTaskList = new List<Task>();
   List<Case> slaCaseList = new List<Case>();
   List<Case> resetCaseList = new List<Case>();
   List<Task> slaClearTaskList = new List<Task>();
   List<Event> slaClearEventList = new List<Event>();
      
   Map<Id,Case> caseIdMap = new Map<Id,Case>();
   Map<Id,Task> secondSlaTaskMap = new Map<Id,Task>();
   Map<Id,List<Event>> secondSlaEventMap = new Map<Id, List<Event>>();
   Map<Id,List<Event>> firstSlaEventMap = new Map<Id, List<Event>>();
   Map<Id,List<SocialPost>> secondSlaPostMap = new Map<Id,List<SocialPost>>();
   Id bsCaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Case'); // Stores record type id of Business Care case Record Type
   public static Id bsCloseCaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Closed Case'); // Stores record type id of Business Care Closed case Record Type
   Social_CaseUtilHandler businessRR = new Social_CaseUtilHandler(); // To get case owner availability status
   public static Set<Id> ownerId = new Set<Id>();
   public static Map<Id,User> userMap = new Map<Id,User>(); 
   // Class Constructor
   public Social_SocialPostTaskCreatorUtil(Set<Id> newIdSet, Set<Id> oldIdSet){

    List<Id> caseIdList = new List<Id>();
    Set<Id> endUserContactIdSet = new Set<Id>();
    
    // Combine Id List
    caseIdList.addAll(newIdSet);
    caseIdList.addAll(oldIdSet); 
    
    // Create Case Map
    if(!caseIdList.isEmpty()){
        
        List<Case> relatedCaseList = [Select c.ContactId, c.OwnerId,c.Track_Case_Queue__c, c.Owner.Type, c.Id, c.Second_SLA_Start_Time__c, c.Second_SLA_Scheduled_Time__c, c.Second_SLA_Response_Time__c, c.Second_SLA_Queue_Flag__c, c.Second_SLA_Case_Owner_Track__c, 
                                      c.Pending_Second_SLA_Task_Creation__c,c.RecordTypeId,c.BizSecondSLA__c, c.Customer_Response_Received__c, c.Current_SLA_Phase__c, c.Social_Persona_Name__c, c.Status, c.Second_SLA_Pending_Post__c, c.Do_Not_Reassign__c , c.ClosedDate, c.Case_Reopen_Flag__c 
                                      ,c.log__c From Case c where c.Id IN: caseIdList];
        // Create Map
        for(Case request: relatedCaseList){
            caseIdMap.put(request.Id, request);
            ownerId.add(request.OwnerId);
            // Capture Contact Ids For Social Post Update
            if(oldIdSet.contains(request.Id)){
                endUserContactIdSet.add(request.ContactId);
            }
        }                  
     }
     
     // Create Second SLA Event Map
     /*if(!oldIdSet.isEmpty()){
        
        // Create Second SLA Event Map
        createCaseEventMap(oldIdSet);
        
        // Create Case Task Map
        createCaseTaskMap(oldIdSet);
        
        // Get Social Post Count
        countSocialPostRecord(endUserContactIdSet, oldIdSet);
     }
     
     else if(oldIdSet.isEmpty() && !newIdSet.isEmpty()){
        // Create SLA Event Map
        createCaseEventMap(newIdSet);
        
        // Create Case Task Map
        createCaseTaskMap(newIdSet);
     }*/
   }
   /*
   // Method To Check and Start The Second SLA Process
   public void initiateSecondSla(SocialPost customerPost, boolean isInsert){
   
     // Get Related Case
     Case parentCase = caseIdMap.get(customerPost.ParentId);
     if(ownerId.size()>0){
         for(User singleUser: [select Id, Availability__c,Name from User where Id IN: OwnerId]){
             userMap.put(singleUser.Id,singleUser);
         }
     }
     
     // Check For Case Re-Open Scenario (Social Post Re-Assignment)
     if(parentCase!=null && 'Closed'.equalsIgnorecase(parentCase.Status) && !isInsert){
     
        // Check 48 Hour Time Gap
        if(calculateHourDifference(parentCase.ClosedDate, customerPost.CreatedDate) >= 0 && calculateHourDifference(parentCase.ClosedDate, customerPost.CreatedDate) < Integer.valueOf(System.label.Case_Reopen_Duration)){
            // Set DML Option
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            // Update Case Stage/Set Assignment Option
            parentCase.Status = CASE_REOPEN_STATUS;
            parentCase.setOptions(dmo);            
            // Add Case List

            if(parentCase.RecordTypeId != bsCloseCaseRecordTypeId){
                slaCaseList.add(parentCase);
            }
            if(parentCase.RecordTypeId == bsCloseCaseRecordTypeId && 
                'Available'.equalsIgnorecase(userMap.get(parentCase.OwnerId).Availability__c)){
                 slaCaseList.add(parentCase);
                 
            }
            
         }
     }
     
     // Social Post Insert Scenario
     else{
        // Check For Second SLA Trigger
        if(parentCase!=null && SLA_STAGE_START.equalsIgnorecase(parentCase.Current_SLA_Phase__c) && !parentCase.Case_Reopen_Flag__c){
           
            System.debug('CASE REOPEN SOCIAL POST');
            // Case Pending In Queue
            if('Queue'.equalsIgnorecase(parentCase.Owner.Type)){
                System.debug('CASE REOPEN QUEUE WAITING');
                // Update Case Record
                parentCase.Customer_Response_Received__c = true;
                parentCase.Pending_Second_SLA_Task_Creation__c = true;
                
                // Code To Prevent Second SLA Assignment Rule On Radian6 Social Post Insert
                if(isInsert){
                      /*if(parentCase.RecordTypeId != bsCloseCaseRecordTypeId && parentCase.RecordTypeId != bsCaseRecordTypeId ){
                            parentCase.Second_SLA_Queue_Flag__c = true;
                            parentCase.Second_SLA_Case_Owner_Track__c = parentCase.OwnerId;
                      }*/ //Commented out to remove second queue logic Jan 15.
                    /*  if(parentCase.RecordTypeId == bsCloseCaseRecordTypeId || parentCase.RecordTypeId == bsCaseRecordTypeId){
                         if(!parentCase.BizSecondSLA__c){
                             parentCase.BizSecondSLA__c = TRUE; 
                         }
                         else{
                             parentCase.BizSecondSLA__c = FALSE; 
                         }
                      }
                } 
                
                // Add Case List
                if(parentCase.RecordTypeId != bsCloseCaseRecordTypeId){
                    slaCaseList.add(parentCase);
                }
                if(parentCase.RecordTypeId == bsCloseCaseRecordTypeId && 
                    'Available'.equalsIgnorecase(userMap.get(parentCase.OwnerId).Availability__c)){
                    slaCaseList.add(parentCase);
                      
                }
            }
            else if('User'.equalsIgnorecase(parentCase.Owner.Type) && parentCase.Social_Persona_Name__c!=null && customerPost.R6Service__AuthorSocialHandle__c!=null && customerPost.R6Service__AuthorSocialHandle__c.equalsIgnorecase(parentCase.Social_Persona_Name__c)){
                System.debug('CASE REOPEN USER WAITING');
                
                // Create Task Add To List
                System.debug('SECOND SLA SOCIAL POST TASK CREATED for case with ID : '+parentCase.Id+' and owner : '+parentCase.OwnerId);
                Task slaTask = new Task();
                slaTask.WhatId = parentCase.Id; 
                slaTask.OwnerId = parentCase.OwnerId;
                slaTask.Subject = SLA_TASK_SUBJECT;
                slaTask.Description = 'SLA-2 Social Post Customer Response';
                slaTask.Event_Type__c = 'SLA - 2';
                slaTask.Status = 'Completed';
                slaTask.Priority = 'Normal';
                slaTask.ActivityDate = System.now().date();
                
                // Add To List
                //if(parentCase.RecordTypeId != bsCaseRecordTypeId && parentCase.RecordTypeId != bsCloseCaseRecordTypeId){
                    if('Unavailable'.equalsIgnorecase(businessRR.getUserAvailabilty(parentCase.OwnerId)) && parentcase.Do_Not_Reassign__c){
                        slaTaskList.add(slaTask); 
                    }
                    else if('Unavailable'.equalsIgnorecase(businessRR.getUserAvailabilty(parentCase.OwnerId)) && !parentcase.Do_Not_Reassign__c){
                    
                        parentCase.OwnerId = parentCase.Track_Case_Queue__c;                          
                        parentCase.Case_System_Reassign__c = true;
                        parentCase.Pending_Second_SLA_Task_Creation__c = true;
                        parentCase.Case_Reassigned_Time__c = null;
                        parentCase.Status = 'Reassigned';
                        parentCase.Customer_Response_Received__c = true;
                        slaCaseList.add(parentCase); 
                         // added by ashween on 1/22 for launching sla2 when case gets reassigned
                         slaTaskList.add(slaTask);
                    }
                   else if(!'Unavailable'.equalsIgnorecase(businessRR.getUserAvailabilty(parentCase.OwnerId))){                              
                        slaTaskList.add(slaTask); 
                      
                    }
                //}
                if(parentCase.RecordTypeId == bsCloseCaseRecordTypeId && 
                    'Available'.equalsIgnorecase(userMap.get(parentCase.OwnerId).Availability__c)){
                    slaCaseList.add(parentCase);
                }
            }
        }
    else if(parentCase!=null && 'Unavailable'.equalsIgnorecase(businessRR.getUserAvailabilty(parentCase.OwnerId)) && !parentcase.Do_Not_Reassign__c && null!=parentCase.Current_SLA_Phase__c && !customerPost.R6Service__IsOutbound__c){
      
        parentCase.OwnerId = parentCase.Track_Case_Queue__c;  
        parentCase.Case_System_Reassign__c = true;
        parentCase.Case_Reassigned_Time__c = null;
        parentCase.Status = 'Reassigned';
        
        if('SLA1 - Initiated'.equalsIgnoreCase(parentCase.Current_SLA_Phase__c)){
           
            parentCase.Current_SLA_Phase__c = null;
            parentCase.First_SLA_Scheduled_Time__c = null;
            parentCase.Customer_Response_Received__c = true;  //DNR : added to make it true. 
            
            parentCase.log__c = 'Entered at this loop here '+firstSlaEventMap.isEmpty();
            // Delete SLA-1 Events
            if(null!=firstSlaEventMap.get(parentCase.Id)){
                parentCase.log__c = parentCase.log__c + 'Entered at this loop here at 2';
                slaClearEventList.addAll(firstSlaEventMap.get(parentCase.Id));
            }
        }
        else if('SLA2 - Initiated'.equalsIgnoreCase(parentCase.Current_SLA_Phase__c)){
           
            parentCase.Current_SLA_Phase__c = 'SLA1 - Ended';
            parentCase.Customer_Response_Received__c = true;
            parentCase.Second_SLA_Start_Time__c = null;
            parentCase.Second_SLA_Scheduled_Time__c = null;
            parentCase.SLA_2_Initiated_Time__c = null;
            parentCase.Pending_Second_SLA_Task_Creation__c = true;
            
            // Delete SLA-2 Events 
            if(null!=secondSlaEventMap.get(parentCase.Id)){
                slaClearEventList.addAll(secondSlaEventMap.get(parentCase.Id));
            }
            // Delete SLA-2 Task
            if(null!=secondSlaTaskMap.get(parentCase.Id)){
                slaClearTaskList.add(secondSlaTaskMap.get(parentCase.Id));
            }
        }
        Social_StreamingUtil.closedProcessed.add(parentCase.Id);
        slaCaseList.add(parentCase);   
    }
    // added the condition for SLA2 ends and customer responded and when care manager replies to the customer. 
    else if(parentCase!=null && ('SLA2 - Ended'.equalsIgnorecase(parentCase.Current_SLA_Phase__c) || parentCase.Second_SLA_Response_Time__c!=null ) && !customerPost.R6Service__IsOutbound__c){
        parentCase.Customer_Response_Received__c = true;
        Social_StreamingUtil.closedProcessed.add(parentCase.Id);
        slaCaseList.add(parentCase);
    }
    else if(parentCase!=null && ('SLA2 - Ended'.equalsIgnorecase(parentCase.Current_SLA_Phase__c) || parentCase.Second_SLA_Response_Time__c!=null ) && customerPost.R6Service__IsOutbound__c){
        parentCase.Customer_Response_Received__c = false;
        Social_StreamingUtil.closedProcessed.add(parentCase.Id);
        slaCaseList.add(parentCase);
    }
        // Add else if to update case for sla2 ended, when customer responded. 
    else if(Boolean.valueOf(label.SLA2EndReassign) && parentCase!=null && (parentCase.Second_SLA_Response_Time__c!=null || 'SLA2 - Ended'.equalsIgnorecase(parentCase.Current_SLA_Phase__c)) && ('Unavailable'.equalsIgnorecase(businessRR.getUserAvailabilty(parentCase.OwnerId))) && !parentcase.Do_Not_Reassign__c  ){
        Assignment_Groups__c nextCareManager = businessRR.getAvailableCareManager(parentCase.Track_Case_Queue__c, parentCase.Status);
        if(nextCareManager==null){ 
            // Update Case Owner To Queue
            
            parentCase.OwnerId = parentCase.Track_Case_Queue__c;  
            parentCase.Case_System_Reassign__c = true;
            parentCase.Case_Reassigned_Time__c =null;
        } else {
            // Assign The Case Owner and populate the reassign time.
            parentCase.OwnerId = nextCareManager.User__c;
            parentCase.Case_Reassigned_Time__c = datetime.now();           
         }
         Social_StreamingUtil.closedProcessed.add(parentCase.Id);
         slaCaseList.add(parentCase);
         // Calling method and passing the set of cases for which the record needs to be inserted for reassigned time
        } 
    }
   }
   
   // Public Method For SLA Reset/Event Delete
   public void resetSecondSla(Id priorCaseId){
    
    // Get Related Case
    Case slaResetCase = caseIdMap.get(priorCaseId);
    if(slaResetCase!=null){
        
        // Check Social Post Count/SLA Stage for Reset(Old Case with User)
        if(SLA_STAGE_RESET.equalsIgnoreCase(slaResetCase.Current_SLA_Phase__c) && secondSlaPostMap.get(slaResetCase.Id)!=null && secondSlaPostMap.get(slaResetCase.Id).size()<2){
            
            System.debug('OLD CASE POST COUNT:' + secondSlaPostMap.get(slaResetCase.Id).size());
            // Reset Case and Add To List
            slaResetCase.Current_SLA_Phase__c = SLA_STAGE_START;
            slaResetCase.Second_SLA_Start_Time__c = null;
            slaResetCase.Second_SLA_Scheduled_Time__c = null;
            slaResetCase.Second_SLA_Response_Time__c = null;
            //slaResetCase.Customer_Response_Received__c = false; //DNR: updated to avoid uncheck when sla reset sla1 ended. 
            slaResetCase.Pending_Second_SLA_Task_Creation__c = false;
            resetCaseList.add(slaResetCase);
            
            // Delete SLA-2 Events
            if(secondSlaEventMap.get(slaResetCase.Id)!=null){
                slaClearEventList.addAll(secondSlaEventMap.get(slaResetCase.Id));
            }
            
            // Delete SLA-2 Task
            if(secondSlaTaskMap.get(slaResetCase.Id)!=null){
                slaClearTaskList.add(secondSlaTaskMap.get(slaResetCase.Id));
            }
            
        }
        // Check Social Post Count/SLA Stage for Reset(Old Case with Queue)
        else if(SLA_STAGE_START.equalsIgnoreCase(slaResetCase.Current_SLA_Phase__c) && 'Queue'.equalsIgnorecase(slaResetCase.Owner.Type) && secondSlaPostMap.get(slaResetCase.Id)!=null && secondSlaPostMap.get(slaResetCase.Id).size()<2){
            
            System.debug('OLD CASE POST COUNT:' + secondSlaPostMap.get(slaResetCase.Id).size());
            // Reset Case Fields and Add To List
           // slaResetCase.Customer_Response_Received__c = false; //DNR: added to avoid false when sla goes back to sla1 end.
            slaResetCase.Pending_Second_SLA_Task_Creation__c = false;
            resetCaseList.add(slaResetCase);
        }
     }
   }
   
   // Public Method For DataBase Transactions
   public void performDatabaseUpdates(){
     
     // Second SLA Case Update
     if(!slaCaseList.isEmpty()){
        try{
            update slaCaseList;
        }
        catch(Exception Exp){
            System.debug('EXCEPTION DURING SECOND SLA CASE UPDATE:' + Exp.getmessage());
        }
     }
     
     // Delete Events
     if(!slaClearEventList.isEmpty()){
        
        // Enable Static Field For Event/Task Delete
        Social_caseActivityDeleteControl.deleteActivity = true;
        try{
            delete slaClearEventList;
        }
        catch(Exception Exp){
            System.debug('EXCEPTION DURING EVENT DELETE:' + Exp.getmessage());
        }
     }
     
     // Delete Task
     if(!slaClearTaskList.isEmpty()){
        
        // Enable Static Field For Event/Task Delete
        Social_caseActivityDeleteControl.deleteActivity = true;
        try{
            delete slaClearTaskList;
        }
        catch(Exception Exp){
            System.debug('EXCEPTION DURING TASK DELETE:' + Exp.getmessage());
        }
     }
     
     // Second SLA Task Insert
     if(!slaTaskList.isEmpty()){
        try{
            insert slaTaskList;
        }
        catch(Exception Exp){
        
            System.debug('EXCEPTION DURING SECOND SLA TASK INSERT:' + Exp.getmessage());
        }
     }
     
     // Reset Cases
     if(!resetCaseList.isEmpty()){
        try{
            update resetCaseList;
        }
        catch(Exception Exp){
            System.debug('EXCEPTION DURING CASE RESET:' + Exp.getmessage());
        }
     }
   }
   
   
   // Private Method To Calculate DateTime Difference(Hours)
   private Integer calculateHourDifference(Datetime closedDate, Datetime createdDate){
    
    // Calculate Hour Difference
    if(closedDate!=null && createdDate!=null){
        
        Decimal closedHours = closedDate.getTime()/1000/60/60;
        Decimal createdHours = createdDate.getTime()/1000/60/60;
        return Integer.valueOf(createdHours - closedHours);
    }
    return -1;
   }
   
   // Private Method To Create Task Map
   private void createCaseTaskMap(Set<Id> caseIdList){
    
     // Query Related Task (SLA-2 Social Post Task)
     Task[] caseTaskList = [Select t.WhatId, t.Subject, t.Id, t.Event_Type__c From Task t where t.WhatId IN: caseIdList and
                            t.Event_Type__c=:SLA_EVENT_TYPE and t.Subject=:SLA_TASK_SUBJECT];
     
     // Create Map
     for(Integer i=0;i<caseTaskList.size();i++){
        secondSlaTaskMap.put(caseTaskList[i].WhatId, caseTaskList[i]);
     }                       
   }
   
   
   // Private Method To Create Event Map
   private void createCaseEventMap(Set<Id> caseIdList){
    
    // Query Related Events
    Event[] caseEventList = [Select e.WhatId, e.Id, e.Event_Type__c From Event e where e.WhatId IN: caseIdList];
    
    // Create Map
    for(Integer i=0;i<caseEventList.size();i++){
        
        if(firstSlaEventMap.containsKey(caseEventList[i].WhatId) && 'SLA - 1'.equalsIgnoreCase(caseEventList[i].Event_Type__c)){
            List<Event> existingEventList = firstSlaEventMap.get(caseEventList[i].WhatId);
            existingEventList.add(caseEventList[i]);
            firstSlaEventMap.put(caseEventList[i].WhatId, existingEventList);
        }
        else if(!firstSlaEventMap.containsKey(caseEventList[i].WhatId) && 'SLA - 1'.equalsIgnoreCase(caseEventList[i].Event_Type__c)){
            List<Event> newEventList = new List<Event>();
            newEventList.add(caseEventList[i]);
            firstSlaEventMap.put(caseEventList[i].WhatId, newEventList);
        }
        
        else if(secondSlaEventMap.containsKey(caseEventList[i].WhatId) && 'SLA - 2'.equalsIgnoreCase(caseEventList[i].Event_Type__c)){
            List<Event> existingEventList = secondSlaEventMap.get(caseEventList[i].WhatId);
            existingEventList.add(caseEventList[i]);
            secondSlaEventMap.put(caseEventList[i].WhatId, existingEventList);
        }
        else if(!secondSlaEventMap.containsKey(caseEventList[i].WhatId) && 'SLA - 2'.equalsIgnoreCase(caseEventList[i].Event_Type__c)){
            List<Event> newEventList = new List<Event>();
            newEventList.add(caseEventList[i]);
            secondSlaEventMap.put(caseEventList[i].WhatId, newEventList);
        }
     }                         
   }
   
   // Private Method For Social Post Count Calculation
   private void countSocialPostRecord(Set<Id> contactIdSet, Set<Id> caseIdSet){
    
     // Query All Social Post Records By Contact
     List<SocialPost> socialPostList = [Select s.WhoId, s.ParentId, s.Id From SocialPost s where s.ParentId IN: caseIdSet
                                        and s.WhoId IN: contactIdSet];
     System.debug('SOCIAL POST COUNT:' + socialPostList.size());
     // Create CaseId-Social Post Map
     for(SocialPost endPost: socialPostList){
        
        if(secondSlaPostMap.containsKey(endPost.ParentId)){
            List<SocialPost> existingPostList = secondSlaPostMap.get(endPost.ParentId);
            existingPostList.add(endPost);
            secondSlaPostMap.put(endPost.ParentId, existingPostList);
        }
        else{
            List<SocialPost> newPostList = new List<SocialPost>();
            newPostList.add(endPost);
            secondSlaPostMap.put(endPost.ParentId, newPostList);
        }
     }                                   
   }
   */
}