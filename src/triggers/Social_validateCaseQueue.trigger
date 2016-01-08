/* Version June 17th Rel: Ashween updated for ITS1509 and ITS-001513 : Status change to Investigating on any update done on a reopened case *
*    Release 19th August : ITS1707 - updated to increment case counter when manually cases are changed from Closed to some open status
*    Release 16th September : ITS1514 - updated to increment/decrement case counters on manual reassignment of cases by Business Care Managers

*/
trigger Social_validateCaseQueue on Case (before insert,before update){
               
  // Variables
     Set<Id> newCaseIdSet = new Set<Id>();
  // Manager Assignment Util Class  
     boolean flag = false;
     Map<Id, List<Case>> countIncCaseUserMap= new Map<Id, List<Case>>(); // added by Ashween on 15th Jan
     Map<Id, List<Case>> countDecCaseUserMap= new Map<Id, List<Case>>(); // added by Ashween on 300615 for July15 rel to increment case counter on manual case ownership
     Map<Id, List<Case>> descDummyMap= new Map<Id, List<Case>>();
     Map<Id, List<Case>> countDummyMap= new Map<Id, List<Case>>();
     Map<Id, List<Case>> caseOwnerQueueMap = new Map<Id, List<Case>>();
     Map<Id,List<Case>> businessCaseMap = new Map<Id,List<Case>>();
     set<id> UpdateConIds = new set<id>(); // Added By Mallaiah
     List<Case> ownerVerificationList = new List<Case>(); //added for ITS#829
     List<Case> autoCloseCaseList = new List<Case>();   
     Set<String> profileIdsCustomLabelSet = new Set<String>();//Set to store profile ids specified in custom label.
     static boolean recursiveflag = FALSE;    
     boolean flag1 = false; //to call round robin when case ownership changes manually to some queue
     Boolean countReduce = false;
     Boolean flagSLA = false;
     Boolean businessFlag = TRUE;
     static Boolean ReassigntoQueue= true;
     Set<id> caseIdSet = new Set<Id>();
     Map<Id,List<Case>> operationsUpdateMap = new Map<Id,List<Case>>();
     String contextUserId = Userinfo.getUserId(); // added for release 7
     String USER_ID = '005';
     Public Static set<String> ConsumerPostTagSet = new Set<String>();
     ConsumerPostTagSet.addAll(Label.Consumer_PostTags.split(';'));
     Public Static set<String> AllBusinessRTSet = new Set<String>();
     AllBusinessRTSet.addAll(Label.All_Business_RT.split(','));
     public Static boolean bizRR = FALSE;
     Set<Case> ReassignedCaseSet = new Set<Case>(); //Set to hold the cases that need to be reassigned
     Set<Id> checkDuplicateCase = new Set<Id>(); //Set to check if duplicate records in set
     Public Static set<String> recordTypeIdSet = new Set<String>();
     recordTypeIdSet.addAll(Label.Consumer_RT.split(','));
     List<string> postTagValueList=new List<string>();
     Boolean callClassMethod = true;
     public static Set<Id> slaDupeCaseIdSet = new Set<Id>();        
     public List<Case> manuallyAssignedCaseList = new List<Case>();
     public List<Case> duplicateCaseCounterList = new List<Case>();
     public List<Event> eventList = new List<Event>(); // List of cases whose events are not deleted(reassignment + vacation )
     
    // Noncase owner update the caserecords on before Insert and Update 
    if(Trigger.isBefore){    
        for(case NonCaseOwnerUpdate: trigger.new) {
            if(NonCaseOwnerUpdate.Moved_to_Prior_Care_Manager__c == true && NonCaseOwnerUpdate.Prior_Care_Manager__c != null && NonCaseOwnerUpdate.Status == 'Auto Closed' && System.Label.PendingClouseQueueId.contains(NonCaseOwnerUpdate.OwnerId)){
                NonCaseOwnerUpdate.ownerid = NonCaseOwnerUpdate.Prior_Care_Manager__c;
                Social_StreamingUtil.AutoClosedOwnerSet.add(NonCaseOwnerUpdate.id);
            }
            if (Trigger.IsUpdate) {           
               //Blank out update reason when a case owner makes any update on the case for consumer cases only.
               if(userinfo.getUserId() == NonCaseOwnerUpdate.ownerId && NonCaseOwnerUpdate.readunreadcheck__c == trigger.oldMap.get(NonCaseOwnerUpdate.Id).readunreadcheck__c && NonCaseOwnerUpdate.readunreadcheck__c == false && Social_StreamingUtil.doNotFireUpdateReason){                   
                   NonCaseOwnerUpdate.update_reason__c = '';                    
               }
               if(userinfo.getuserid()!= NonCaseOwnerUpdate.ownerid && String.valueOf(userInfo.getUserId()).subString(0,15) != System.Label.SocialCustomerServiceUserId) {                                       
                   NonCaseOwnerUpdate.NonCaseOwner_LastModifiedDate__c=system.now();
                   NonCaseOwnerUpdate.readunreadcheck__c = true;
               }
               if(string.ValueOf(NonCaseOwnerUpdate.ownerId).startsWith(Social_StreamingUtil.QUEUE_ID) && NonCaseOwnerUpdate.ownerId != System.Label.PendingClouseQueueId && Social_StreamingUtil.fireAssignmentRule) {
                   NonCaseOwnerUpdate.Track_Case_Queue__c = NonCaseOwnerUpdate.ownerid; 
               }             
            } else if (trigger.isInsert && userinfo.getuserid()== NonCaseOwnerUpdate.ownerid){                            
               NonCaseOwnerUpdate.NonCaseOwner_LastModifiedDate__c=system.now();
               NonCaseOwnerUpdate.readunreadcheck__c = true;
               // ashween added the clause of manual Record Type Id check on 062215
               if (String.valueOf(userInfo.getUserId().subString(0,15)) != system.Label.Email_Case_UserId && String.valueOf(userInfo.getUserId().subString(0,15)) != system.Label.BCS_Email_Case_User_Id  ) {                   
                   NonCaseOwnerUpdate.Update_reason__c = Social_StreamingUtil.MANUAL_CASE_CREATED;
                  
               }             
            }                                                              
        }
                
    }
     
     if(Social_CaseAssignmentUtility.executeTriggerCode!=null && Social_CaseAssignmentUtility.executeTriggerCode && Social_StreamingUtil.preventCaseValidateTriggerToFire && Social_StreamingUtil.doNtFireEmail2CaseRun && (Boolean.valueOf(Label.Deactivate_Case_Triggers))){
     Social_CaseUtilHandler managerUtilClass = new Social_CaseUtilHandler();
     
     /*******
      ABS update. Moved the below block up on purpose to avoid Validation error message in Social_ValidateCaseQueueUtil class.
      Social_StreamingUtil.closedProcessed set helps bypass the validation. 
      Below block needs to be above 'Social_validateCaseQueueUtil validateUtilClass = new Social_validateCaseQueueUtil(Userinfo.getUserId(), newCaseIdSet);'
      DO NOT MOVE BLOCK
      ********/
      for(Case newCase: Trigger.new){      
          if(trigger.IsUpdate){
              // added for ITS#638
              if(trigger.oldmap.get(newCase.Id).QA_Not_Needed__c != newCase.QA_Not_Needed__c && newCase.QA_Not_Needed__c == TRUE 
                  &&  newCase.RecordTypeId == System.Label.Business_Case_Audit_Record_Type_ID && newCase.Audit_Status__c == 'Under QA'){
                  Social_StreamingUtil.closedProcessed.add(newCase.Id);
              } 
              if(newCase.Status == 'Closed' && newCase.RecordTypeId == System.Label.Business_Closed_RT){         
                  if(trigger.oldmap.get(newCase.Id).Business_Survey_Indicator__c != newCase.Business_Survey_Indicator__c && newCase.Business_Survey_Indicator__c == TRUE){
                           caseIdSet.add(newCase.Id);
                           Social_StreamingUtil.closedProcessed.add(newCase.Id);
                  }
                  if(trigger.oldmap.get(newCase.Id).Business_Survey_Email_Indicator__c != newCase.Business_Survey_Email_Indicator__c && newCase.Business_Survey_Email_Indicator__c == TRUE){
                           caseIdSet.add(newCase.Id);
                           Social_StreamingUtil.closedProcessed.add(newCase.Id);
                  }
              }
             // Added for release 7
             
            Datetime slaScheduledTime = datetime.now();        
            Integer socialPostSLATimeframe = 15;        
            Integer emailSLATimeframe = 30;     
            Integer secondSLATimeframe = 60; 
            String newCaseOwner = newCase.ownerId;
            String oldCaseOwner = trigger.oldMap.get(newCase.Id).ownerId;  
            String eventStatus = '' ; 
             if(newCase.RecordTypeID == System.Label.Business_Open_RT || newCase.RecordTypeID == System.Label.Business_Closed_RT){
                 if (('New'.equalsIgnoreCase(newCase.Status) || 'Reopen'.equalsIgnoreCase(newCase.Status))
                     && contextUserId!= NULL && contextUserId.equalsIgnorecase(newCase.OwnerID) && Social_BusinessRoundRobin.doNotChangeStatus)
                     {                        
                         newCase.Status = 'Investigating';                     
                     }               
                 // Code for Manual assignment of case from queue to user other than Ruth and Carmine    
                 if( contextUserId.equalsIgnorecase(newCase.OwnerID) && newCaseOwner.startsWith('005') && oldCaseOwner.startsWith('00G') && !Social_StreamingUtil.caseBizAssignedByRR && !Social_StreamingUtil.caseBizAssignedByAssignCase){
                     newCase.OwnerId = UserInfo.getUserId();   
                     newCase.Track_Case_Queue__c = trigger.oldMap.get(newCase.Id).ownerId;
                     newCase.Update_reason__c = 'Manual Assignment';                    
                     Social_StreamingUtil.doNotUpdateReasonBizManualAssignment = FALSE;        
                     newCase.NonCaseOwner_LastModifiedDate__c = system.now(); 
                     countDecCaseUserMap.put(newCase.OwnerId, new List<Case>{newCase});                     
                                              
                     if(newCase.Contains_Consumer_Post_Tag__c == False){
                         businessFlag = TRUE;                             
                     }      
                     if(newCase.Current_SLA_Phase__c == NULL){                      
                        newCase.Case_Assigned_Time__c = System.now();       
                        newCase.Current_SLA_Phase__c = 'SLA1 - Initiated';                                                                      
                           if(newCase.Origin=='Email Business (BizHelp)' || newCase.Origin == 'Email Business (YouTube)'){                                  
                                newCase.First_SLA_Scheduled_Time__c = slaScheduledTime.addMinutes(emailSLATimeframe );      
                            }       
                            else{       
                                newCase.First_SLA_Scheduled_Time__c = slaScheduledTime.addMinutes(socialPostSLATimeframe );     
                            }       
                    }       
                      else if(newCase.Current_SLA_Phase__c == 'SLA1 - Ended'){                  
                        newCase.Current_SLA_Phase__c = 'SLA2 - Initiated';          
                        newCase.Second_SLA_Start_Time__c = System.Now();        
                        newCase.Second_SLA_Scheduled_Time__c = slaScheduledTime.addMinutes(secondSLATimeframe);         
                      }     
                      else{     
                         slaDupeCaseIdSet.add(newCase.Id);                          
                     }      
                                                
                     Social_StreamingUtil.skipTransaction.add(newCase.Id);      
                     manuallyAssignedCaseList.add(newCase);
                     
                     for(Event singleSLA: [Select Id, OwnerId,Event_Type__c,WhatId,Event_Status__c,StartDateTime,DurationInMinutes,IsAllDayEvent,
                               IsReminderSet,ReminderDateTime from Event where WhatId =: newCase.Id ]){
                         eventList.add( singleSLA );
                         eventStatus = singleSLA.Event_Status__c;
                     } 
                                           
                 /*    if(eventList.size() > 0 && eventStatus == 'Closed'){
                         if( manuallyAssignedCaseList.size() >0 || manuallyAssignedCaseList != null){             
                             String caseOwnerId ;           
                             caseOwnerId = manuallyAssignedCaseList[0].OwnerId ;
                             assignACaseControllerBCS.reassignCaseSLAInitiation(manuallyAssignedCaseList,caseOwnerId );      
        
                         }                     
                     }
                     */
                     if (Trigger.oldMap.get(newCase.Id).Current_SLA_Phase__c != newCase.Current_SLA_Phase__c && newCase.RecordTypeID == System.Label.Business_Open_RT) {
                         if( manuallyAssignedCaseList.size() >0 || manuallyAssignedCaseList != null){             
                             String caseOwnerId ;           
                             caseOwnerId = manuallyAssignedCaseList[0].OwnerId ;
                             assignACaseControllerBCS.reassignCaseSLAInitiation(manuallyAssignedCaseList,caseOwnerId );              
                         }                                       
                     }                                                                        
                 }
                 
                 if(Social_StreamingUtil.doNotUpdateReasonBizManualAssignment && trigger.oldMap.get(newCase.Id).RecordTypeID == System.Label.Business_Manual_RT){ 
                      countDecCaseUserMap.put(newCase.OwnerId, new List<Case>{newCase});
                 } 
                         
                 if(newCase.Auto_Close_Indicator__c != trigger.oldMap.get(newCase.Id).Auto_Close_Indicator__c 
                     && newCase.Auto_Close_Indicator__c){
                         autoCloseCaseList.add(newCase);                      
                 }                
                 if(!String.valueOf(newCase.OwnerId).startsWith(USER_ID) 
                     && newCase.OwnerId != System.Label.GENERAL_BC_QUEUE  && newCase.OwnerId != System.Label.SOCIAL_SALES_LEAD_QUEUE && newCase.Status != 'Closed') {   
                     ownerVerificationList.add(newCase);
                 }       
             
             }             
          }      
      }
      
      if(ownerVerificationList.size()>0){
          Social_ValidateAssignment.checkCaseTags(ownerVerificationList);
      }
      /**********************************************************************************************************************/
      
    // logic to populate a date time when SLA 2 got initated on case
    //logic for resetting SLA on case
    for (Case caseObjUpdate: trigger.New) {
        String currentCaseOwner = caseObjUpdate.ownerid;
        if (trigger.isUpdate && trigger.isBefore) {  
          String oldCaseOwner = trigger.OldMap.get(caseObjUpdate.Id).ownerId;
            if(caseObjUpdate.Do_Not_Reassign__c==false && trigger.oldMap.get(caseObjUpdate.Id).Do_Not_Reassign__c == true && caseObjUpdate.Customer_Response_Received__c==true && Social_StreamingUtil.doNtReassignToQueue){
                if(managerUtilClass.checkCaseOwnerUser(caseObjUpdate.ownerid) && 'Unavailable'.equalsIgnorecase(managerUtilClass.getUserAvailabilty(caseObjUpdate.ownerid)) && caseObjUpdate.Track_Case_Queue__c!=null){
                    Social_StreamingUtil.doNtFireReassignmentRsnErr = false;//Setting this flag as false to deactivate reassignment reason error message during case insert.
                    caseObjUpdate.ownerid=caseObjUpdate.Track_Case_Queue__c;
                    if (!Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK.equalsIgnoreCase(caseObjUpdate.Status)){
                        caseObjUpdate.status='Reassigned';
                    }
                    Social_markCaseUpdates.caseSlaReset(caseObjUpdate, String.valueof(trigger.oldMap.get(caseObjUpdate.Id).ownerId)); // calling method to close events.
                    ReassigntoQueue=false;
                    caseObjUpdate.DNR_to_Queue__c=true;
                 }     
            } 
            else if(trigger.oldMap.get(caseObjUpdate.Id).Do_Not_Reassign_Timeframe__c != caseObjUpdate.Do_Not_Reassign_Timeframe__c  && (currentCaseOwner.startsWith('005') || (currentCaseOwner.startsWith('00G') && (Userinfo.getProfileId()!=null && Userinfo.getProfileId().substring(0,15).equalsIgnoreCase(Label.SystemAdminProfileId))) )){
                Social_markCaseUpdates.CaseDoNotReassignUpdate(caseObjUpdate);        
            }
            else if(trigger.oldMap.get(caseObjUpdate.Id).Do_Not_Reassign_Timeframe__c != caseObjUpdate.Do_Not_Reassign_Timeframe__c  && currentCaseOwner.startsWith('00G') && trigger.oldMap.get(caseObjUpdate.Id).Do_Not_Reassign_Timeframe__c != 'Do Not Reassign' ){
                caseObjUpdate.addError(' Please assign the Case to a user to modify the DNR End time ');
            }
            if (caseObjUpdate.Current_SLA_Phase__c == 'SLA2 - Initiated' && trigger.oldMap.get(caseObjUpdate.Id).Current_SLA_Phase__c == 'SLA1 - Ended' ) {
                 caseObjUpdate.SLA_2_Initiated_Time__c = dateTime.Now();
            }            
            if(((currentCaseOwner != oldCaseOwner && ((currentCaseOwner.startsWith('00G') && oldCaseOwner.startsWith('005')) || (currentCaseOwner.startsWith('005') && oldCaseOwner.startsWith('005')))) || (caseObjUpdate.status =='closed' && trigger.OldMap.get(caseObjUpdate.Id).status!='closed')) && (caseObjUpdate.Do_Not_Reassign_Timeframe__c != '' && caseObjUpdate.Do_Not_Reassign_Timeframe__c=='Do Not Reassign')){
                caseObjUpdate.Do_Not_Reassign_Timeframe__c = null;
                caseObjUpdate.DNR_End_Time__c = null;
                caseObjUpdate.Do_Not_Reassign_Time__c = null;
                caseObjUpdate.Do_Not_Reassign__c = false;
            } 
        }
    }
     
      // Load Set On Update
      if(Trigger.isUpdate){
        newCaseIdSet = Trigger.newMap.keySet();        
      }     
      
      // Initialize Util Class
      Social_validateCaseQueueUtil validateUtilClass = new Social_validateCaseQueueUtil(Userinfo.getUserId(), newCaseIdSet);
      
           
      // Loop Through Cases
      for(case newCase: Trigger.new){            
       /*****
       6/4/14 release
       Consumer: Code for addition of new multiselect picklist case post tag field instead of Text case posttag field.
       ******/
       boolean validPostTag = false; // flag to check if the post tag is relevant to the consumer
        if (Trigger.isInsert && trigger.isBefore){
            Social_StreamingUtil.doNtFireReassignmentRsnErr = false;//Setting this flag as false to deactivate reassignment reason error message during case insert.
             //Logic to populate manual case indicator for manual cases or cloned cases.
            if((newCase.RecordTypeId == System.Label.ManualCareCaseRT && !String.valueOf(newCase.OwnerId).contains(System.label.Automated_Case_UserId)) || 'true'.equalsIgnoreCase(newCase.Is_Case_Cloned__c)){
                newCase.Manual_Case_Indicator__c = true;
            }            
        
            if(newCase.Case_Post_Tag__c!=null){  // during manual case insertion
                newCase.Case_PostTag__c = newCase.Case_Post_Tag__c.replaceAll(';',',');
                newCase.Business_Case_Post_Tag__c = newCase.Case_Post_Tag__c;// Updating the Business Multiselect picklist field
            }
            
            if(newCase.Case_PostTag__c!=null && newCase.Case_Post_Tag__c==null){   //during social post insertion
                if(newCase.Case_PostTag__c!=null && newCase.Case_PostTag__c.contains(',')){  
                    postTagValueList.addAll(newCase.Case_PostTag__c.split(','));
                    newCase.Case_Post_Tag__c='';
                    for(string singlepost : postTagValueList){
                        newCase.Case_Post_Tag__c+=singlepost + ';';
                        newCase.Business_Case_Post_Tag__c = newCase.Case_Post_Tag__c;
                    }
                }
                else {
                    newCase.Case_Post_Tag__c = newCase.Case_PostTag__c;
                    newCase.Business_Case_Post_Tag__c = newCase.Case_PostTag__c;
                }
            }                
        }else if (Trigger.isUpdate && trigger.isBefore){
            //logic to mark case reason indicator as true if case reason is Duplicate,Not SM Owned and No Outreach
            Social_markCaseUpdates.markCaseReasonIndicator(newCase,recordTypeIdSet); 
            // ABS 9 Release
            //Multi-select pick list field update if the user is neither R6 User nor Automated Admin.   
            if(AllBusinessRTSet.contains(newCase.RecordTypeID) && trigger.oldMap.get(newCase.Id).Business_Case_Post_Tag__c != newCase.Business_Case_Post_Tag__c && newCase.Business_Case_Post_Tag__c != Null &&  !userInfo.getUserId().contains('005E0000002G4RU') && userInfo.getName() != 'Automated Admin') {
                List<String> caseTagList = new List<String>(newcase.Business_Case_Post_Tag__c.split(';'));  //List to hold the Picklist values             
                for(String caseTag: caseTagList){
                    if(ConsumerPostTagSet.contains(caseTag.trim().toUpperCase())){
                        validPostTag = true; //Boolean check set to true if the Business Multi-select pick list has a consumer post tag
                        break;
                    }//end of if
                }// end of for  
                // If field Contains Consumer post tag and the check box is checked, update the field.         
                if(validPostTag && newCase.Contains_Consumer_Post_Tag__c == True){
                    newCase.Case_PostTag__c = newCase.Business_Case_Post_Tag__c.replaceAll(';',',');
                    newCase.Case_Post_Tag__c = newCase.Business_Case_Post_Tag__c;
                    newCase.Contains_Consumer_Post_Tag__c = False; // flag set to false for next update.
                }
                //If field contains Consumer post tag and check box is unchecked, Display error.
                else if(businessFlag && validPostTag && !userInfo.getUserId().contains('005E0000002G4RU') && userInfo.getName() != 'Automated Admin'){                     
                    newCase.addError('You have selected a Consumer post tag, Please confirm by selecting the checkbox : Contains Consumer Post Tag ?' );                    
                }
                // if field contains only business post tag 
                else {
                    newCase.Case_PostTag__c = newCase.Business_Case_Post_Tag__c.replaceAll(';',',');
                    newCase.Case_Post_Tag__c = newCase.Business_Case_Post_Tag__c;
                    newCase.Contains_Consumer_Post_Tag__c = False;
                    Social_CaseAssignmentUtility.executeTriggerCode = FALSE; // added by Arun for Feb11th'15 rel so that reopen audit case gets consumer post tag assigned manually                    
                }                
            }// if case is created by Social Post and context user is Radian 6, Update the Multi select pick list.  
            else if (userInfo.getUserId().contains('005E0000002G4RU') && newCase.Case_PostTag__c != Null) {
                newCase.Business_Case_Post_Tag__c = newCase.Case_PostTag__c;
            }//if business post tag field is blanked out
            else if(AllBusinessRTSet.contains(newCase.RecordTypeID) && trigger.oldMap.get(newCase.Id).Business_Case_Post_Tag__c != newCase.Business_Case_Post_Tag__c && newCase.Business_Case_Post_Tag__c == Null &&  !userInfo.getUserId().contains('005E0000002G4RU') && userInfo.getName() != 'Automated Admin'){
                    newCase.Case_PostTag__c = null;
            }
            if(recordTypeIdSet.contains(newCase.RecordtypeId) && trigger.oldMap.get(newCase.Id).Case_Post_Tag__c != newCase.Case_Post_Tag__c) {
                if (newCase.Case_Post_Tag__c != Null) {
                    newCase.Case_PostTag__c = newCase.Case_Post_Tag__c.replaceAll(';',',');
                    newCase.Business_Case_Post_Tag__c = newCase.Case_Post_Tag__c; // Updating the Business Multiselect picklist field
                } else {
                    newCase.Case_PostTag__c = '';
                    newCase.Business_Case_Post_Tag__c = '';
                }
            }
            else if (recordTypeIdSet.contains(newCase.RecordtypeId) && trigger.oldMap.get(newCase.Id).Case_PostTag__c != newCase.Case_PostTag__c){
                if(newCase.Case_PostTag__c!=null && newCase.Case_PostTag__c.contains(',')){  
                    postTagValueList.addAll(newCase.Case_PostTag__c.split(','));
                    newCase.Case_Post_Tag__c='';
                    for(string singlepost : postTagValueList){
                        newCase.Case_Post_Tag__c+=singlepost + ';';
                        newCase.Business_Case_Post_Tag__c+=singlepost + ';';
                    }
                } else {   
                    newCase.Case_Post_Tag__c = newCase.Case_PostTag__c;
                    newCase.Business_Case_Post_Tag__c = newCase.Case_PostTag__c;                   
                }
            } 
            //Auto Reassignment tag validation
            if(newCase.Auto_Reassignment_Tag__c != null && recordTypeIdSet.contains(newCase.RecordtypeId)){
                if(newCase.Do_Not_Reassign__c == true){
                    newCase.addError(' Case cannot have an Auto Reassignment Tag while being marked as DNR. ');
                } else if(newCase.Reassignment_Reason__c == null){
                    newCase.addError(' Please provide an appropriate Reassignment Reason. ');
                }
            }
            
            //Reassignment reason validation.
            if ( trigger.OldMap.get(newCase.Id).RecordTypeId != System.Label.Business_Open_RT && recordTypeIdSet.contains(newCase.RecordtypeId) && newCase.ownerId != trigger.oldMap.get(newCase.id).ownerId && !userInfo.getUserId().contains('005E0000002G4RU') && userInfo.getName() != 'Automated Admin' && Social_StreamingUtil.doNtFireReassignmentRsnErr && Boolean.valueOf(Label.Deactivate_ReassignmentReason_Err)) {
                String newCaseOwner = newCase.ownerId;
                String oldCaseOwner = trigger.oldMap.get(newCase.Id).ownerId;
                Social_StreamingUtil.doNtFireReassignmentRsnErr = false;
                //If case owner is changed from user to queue or user to user and reassignment reason is null.
                if (((newCaseOwner.startsWith('00G') && oldCaseOwner.startsWith('005')) || (newCaseOwner.startsWith('005') && oldCaseOwner.startsWith('005')) || (newCaseOwner.startsWith('00G') && oldCaseOwner.startsWith('00G'))) && newCase.Reassignment_Reason__c == null && newCase.Is_Auto_Closed__c == False) {
                    newCase.addError('Please Provide Appropriate Re-assignment Reason.');
                    callClassMethod = false;
                } else if (((newCaseOwner.startsWith('005') && oldCaseOwner.startsWith('00G')) || (newCaseOwner.startsWith('00G') && oldCaseOwner.startsWith('005')) || (newCaseOwner.startsWith('005') && oldCaseOwner.startsWith('005')) || (newCaseOwner.startsWith('00G') && oldCaseOwner.startsWith('00G'))) && newCase.Reassignment_Reason__c != null){
                    newCase.Reassignment_Reason__c = null;
                    //Logic to blank out case reassign time when SLA are closed either SLA 1 or SLA 2
                    if (newCaseOwner.startsWith('00G')) {
                        newCase.Case_Reassigned_Time__c = null;
                    } else if (newCaseOwner.startsWith('005')) {
                        if(newCase.Moved_to_Prior_Care_Manager__c == false){
                            newCase.Case_Reassigned_Time__c = DateTime.Now();
                        }
                        if (!checkDuplicateCase.contains(newCase.Id)) {
                            checkDuplicateCase.add(newCase.Id);
                            ReassignedCaseSet.add(newCase);
                        }
                    }    
                }
  
                //Case assignment from User to User or User to Queue, then only close events. 
                //Check if case Current SLA Phase is SLA1 Initiated or SLA2 Initiated.
                //Aditya: Removed SLA check condition since we have condition check in class. Now this loop will fire whenever there is a reassignment from user to user or user to queue
                if (((newCaseOwner.startsWith('005') && oldCaseOwner.startsWith('005')) || (newCaseOwner.startsWith('00G') && oldCaseOwner.startsWith('005'))) && callClassMethod && Boolean.valueOf(Label.ActivateSlaReset)) {
                    Social_markCaseUpdates.caseSlaReset(newCase, oldCaseOwner);
                }
                if ((newCase.Current_SLA_Phase__c == 'SLA1 - Ended' || newCase.Current_SLA_Phase__c == 'SLA2 - Ended') && ((newCaseOwner.startsWith('005') && oldCaseOwner.startsWith('00G')) || (newCaseOwner.startsWith('005') && oldCaseOwner.startsWith('005')))) {
                    if(newCase.Moved_to_Prior_Care_Manager__c == false){
                        newCase.Case_reassigned_Time__c = DateTime.Now();
                    }
                    if (!checkDuplicateCase.contains(newCase.Id)) {
                        checkDuplicateCase.add(newCase.Id);
                        ReassignedCaseSet.add(newCase);
                    }
                }
            }                            
        }
        
        if(Trigger.isInsert || Trigger.isUpdate){
            //Code for CSC Feb 11 release to get the User who pushed the case from engagement Console   
            
            if(Trigger.isUpdate && (null == newCase.Engagement_Console_User__c || String.valueOf(newCase.Engagement_Console_User__c).equals('')) && newCase.RecordTypeId!=null && newCase.RecordTypeId!=System.Label.Business_Manual_RT && newCase.RecordTypeId!=System.Label.Business_Closed_RT && newCase.RecordTypeId!=System.Label.Business_Open_RT && newCase.Origin!=null && !(newCase.Origin).equals('') && newCase.Origin == 'Engagement Console'){ 
                String strId = '';
                
                strId = validateUtilClass.getEngagementConsoleUserId(newCase.id, false, null);              
                if(strId!=null && !strId.equals('')){                   
                    newCase.Engagement_Console_User__c = strId;
                }
            } 
            //Case history record would not be loaded at this point so the case owner would be the user pushing the Case from Engagement Console.
            
            if((null == newCase.Engagement_Console_User__c || String.valueOf(newCase.Engagement_Console_User__c).equals('')) && newCase.RecordTypeId!=null && newCase.RecordTypeId!=System.Label.Business_Manual_RT && newCase.RecordTypeId!=System.Label.Business_Closed_RT && newCase.RecordTypeId!=System.Label.Business_Open_RT && newCase.Origin!=null && !(newCase.Origin).equals('') && newCase.Origin == 'Engagement Console'){ 
                
                String strId = '';
                strId = validateUtilClass.getEngagementConsoleUserId(newCase.id, true, newCase.OwnerId);
                newCase.Engagement_Console_User__c = 'Entered at 2 '+newCase.id+ 'oid: '+newCase.OwnerId+' '+strId;
                if(strId!=null && !strId.equals('')){                   
                    newCase.Engagement_Console_User__c = strId;
                }
            }             
        }
        
        // On Update 
        if(Trigger.isUpdate){
        if(recursiveflag == FALSE){
            if(newCase.id!=null && newCase.Is_Case_Cloned__c!=null && Social_CaseUpdateStreamCtrl.caseId!=null && !Social_CaseUpdateStreamCtrl.caseId.contains(newCase.Id) && !newCase.Is_Case_Cloned__c.equalsIgnoreCase('true')){
                if(Userinfo.getUserId()!=null && newCase.OwnerId!=null && Userinfo.getUserId()!=newCase.OwnerId && newCase.Moved_to_Prior_Care_Manager__c == false){
                    if(!Social_StreamingUtil.processed.contains(newCase.Id)){
                        if(!managerUtilClass.checkCaseOwnerQueue(newCase.OwnerId)){
                            // if non case owner makes any update on case, set update reason as "Internal Update"
                            //ignore updates made by SCS user and Automated Admin
                            if(!contextUserId.equalsIgnorecase(newCase.OwnerID) && String.valueOf(userInfo.getUserId()).subString(0,15) != System.Label.SocialCustomerServiceUserId && String.valueOf(userInfo.getUserId().subString(0,15)) != system.Label.Email_Case_UserId && String.valueOf(userInfo.getUserId().subString(0,15)) != system.Label.BCS_Email_Case_User_Id){
                                newCase.Update_Reason__c = 'Internal Update';
                                newCase.ReadUnreadCheck__c = TRUE;
                                // added by Ashween for Carmine's and Ruth's update
                
                Datetime slaScheduledTime = datetime.now();        
                Integer socialPostSLATimeframe = 15;        
                Integer emailSLATimeframe = 30;     
                Integer secondSLATimeframe = 60; 
                String newCaseOwner = newCase.ownerId;
                String oldCaseOwner = trigger.oldMap.get(newCase.Id).ownerId;
                String eventStatus = '' ;
                
                if ((newCaseOwner.startsWith('005') && oldCaseOwner.startsWith('00G')) && !Social_StreamingUtil.caseBizAssignedByRR && !Social_StreamingUtil.caseBizAssignedByAssignCase ){
                     newCase.Update_reason__c = 'Manual Assignment'; 
                      newCase.Track_Case_Queue__c = trigger.oldMap.get(newCase.Id).ownerId;
                     Social_StreamingUtil.doNotUpdateReasonBizManualAssignment = FALSE;       
                     newCase.NonCaseOwner_LastModifiedDate__c = system.now();       
                     countDecCaseUserMap.put(newCase.OwnerId, new List<Case>{newCase});     
                           
                     if(newCase.Current_SLA_Phase__c == NULL){                      
                        newCase.Case_Assigned_Time__c = System.now();       
                        newCase.Current_SLA_Phase__c = 'SLA1 - Initiated';                                                                      
                           if(newCase.Origin=='Email Business (BizHelp)' || newCase.Origin == 'Email Business (YouTube)'){                                  
                                newCase.First_SLA_Scheduled_Time__c = slaScheduledTime.addMinutes(emailSLATimeframe );      
                            }       
                            else{       
                                newCase.First_SLA_Scheduled_Time__c = slaScheduledTime.addMinutes(socialPostSLATimeframe );     
                            }       
                    }       
                      else if(newCase.Current_SLA_Phase__c == 'SLA1 - Ended'){                  
                        newCase.Current_SLA_Phase__c = 'SLA2 - Initiated';          
                        newCase.Second_SLA_Start_Time__c = System.Now();        
                        newCase.Second_SLA_Scheduled_Time__c = slaScheduledTime.addMinutes(secondSLATimeframe);         
                      }     
                      else{     
                         slaDupeCaseIdSet.add(newCase.Id);                          
                     }      
                     manuallyAssignedCaseList.add(newCase); 
                     Social_StreamingUtil.skipTransaction.add(newCase.Id); 
                     for(Event singleSLA: [Select Id, OwnerId,Event_Type__c,WhatId,Event_Status__c,StartDateTime,DurationInMinutes,IsAllDayEvent,
                               IsReminderSet,ReminderDateTime from Event where WhatId =: newCase.Id ]){
                         eventList.add( singleSLA );
                         eventStatus = singleSLA.Event_Status__c;
                     } 
                     /*                      
                     if(eventList.size() > 0 && eventStatus == 'Closed'){
                         if( manuallyAssignedCaseList.size() >0 || manuallyAssignedCaseList != null){             
                             String caseOwnerId ;           
                             caseOwnerId = manuallyAssignedCaseList[0].OwnerId ;
                             assignACaseControllerBCS.reassignCaseSLAInitiation(manuallyAssignedCaseList,caseOwnerId );            
                         }                     
                     }
                     */
                     if (Trigger.oldMap.get(newCase.Id).Current_SLA_Phase__c != newCase.Current_SLA_Phase__c && newCase.RecordTypeID == System.Label.Business_Open_RT) {
                         if( manuallyAssignedCaseList.size() >0 || manuallyAssignedCaseList != null){             
                             String caseOwnerId ;           
                             caseOwnerId = manuallyAssignedCaseList[0].OwnerId ;
                             assignACaseControllerBCS.reassignCaseSLAInitiation(manuallyAssignedCaseList,caseOwnerId );              
                         }                                       
                     }                                           
                }
                    Social_StreamingUtil.doNotFireUpdateReason = False ; // Ashween added to avoid exception when system admin closes out a case with Open events
                }
            }   
            //Queue to User                      
                        if(Trigger.oldMap.get(newCase.Id).OwnerId != newCase.OwnerId 
                            && managerUtilClass.checkCaseOwnerQueue(Trigger.oldMap.get(newCase.Id).OwnerId) && managerUtilClass.checkCaseOwnerUser(newCase.OwnerId) && newCase.Moved_to_Prior_Care_Manager__c == false){
                            newCase.ReadUnreadCheck__c = TRUE;
                            //newCase.Update_Reason__c = 'Case Assigned'; //Commented by ashween to retain the manual case created update reason
                            if(newCase.Case_assigned_time__c!=null && newCase.Case_Reassigned_TIme__c==null){ //populate the reassigned time when case is reassigned from queue to user
                                newCase.Case_Reassigned_TIme__c = dateTime.now();   
                                ReassignedCaseSet.add(newCase);             
                            }
                            
                        }
                        else if(Trigger.oldMap.get(newCase.Id).OwnerId != newCase.OwnerId 
                            && managerUtilClass.checkCaseOwnerUser(Trigger.oldMap.get(newCase.Id).OwnerId) && managerUtilClass.checkCaseOwnerUser(newCase.OwnerId)){                            
                            newCase.ReadUnreadCheck__c = TRUE;
                            newCase.Update_Reason__c = 'Case Re-assigned';
                             if(newCase.RecordTypeId == System.Label.Business_Open_RT && Social_StreamingUtil.caseOpenBusinessStatus.contains(Trigger.oldMap.get(newCase.Id).Status)){     
                                    if(countIncCaseUserMap.containsKey(Trigger.oldMap.get(newCase.Id).OwnerId)){        
                                        countIncCaseUserMap.get(Trigger.oldMap.get(newCase.Id).OwnerId).add(newCase);       
                                    }               
                                    else{       
                                          countIncCaseUserMap.put(Trigger.oldMap.get(newCase.Id).OwnerId, new List<Case>{newCase});                             
                                    }      
                                    if(countDecCaseUserMap.containsKey(newCase.OwnerId)){       
                                        countDecCaseUserMap.get(newCase.OwnerId).add(newCase);      
                                    }               
                                    else{       
                                         countDecCaseUserMap.put(newCase.OwnerId, new List<Case>{newCase});     
                                    }       
                             }                                 
                        }
                     }
                }
                
                /******************** Nayan's additions to the trigger*****************/
                else if(Userinfo.getUserId()!=null && newCase.OwnerId!=null && Userinfo.getUserId().equals(newCase.OwnerId) && Trigger.oldMap.get(newCase.Id).OwnerId == newCase.OwnerId){
                    newCase.CM_Last_Modified_Date__c = System.now();
                    newCase.CM_Last_Modified_Section__c = 'Case';
                    if(newCase.ReadUnreadCheck__c){
                        newCase.ReadUnreadCheck__c = FALSE;
                    }
                }                
                System.debug('Here the values are Userinfo.getUserId(): '+Userinfo.getUserId()+' newCase.Update_Reason__c: '+newCase.Update_Reason__c+' ');
                
                /******************** Nayan's additions to the trigger*****************/
                //Aditya: Added check for General Care Manager profile for marking reason as Completed.
                String profileIds = label.HS_Care_Rep_Profile_Id;//String for getting ids from custom label.
                if(profileIds != Null) {
                    profileIdsCustomLabelSet.addAll(profileIds.split(';'));
                }
                if(UserInfo.getProfileId()!=null && !profileIdsCustomLabelSet.isEmpty() && profileIdsCustomLabelSet.Contains(userInfo.getProfileId())){
                    if(newCase.Case_Reason_HSRep__c!=null && (newCase.Case_Reason_HSRep__c).equalsIgnoreCase('Resolved')){
                        newCase.Reason = 'Completed';
                    }
                    else{
                        newCase.Reason = newCase.Case_Reason_HSRep__c;
                    }
                }
                
            }
            
            if(newCase.RecordTypeId != System.Label.Business_Open_RT && callClassMethod){
                Case oldCase = Trigger.oldMap.get(newCase.Id);
                validateUtilClass.processUpdatedCase(newCase, oldCase);
            }
            }    
        } 
        // On Insert 
        
        else if(Trigger.isInsert){
              
        if(newCase.RecordTypeId == System.Label.Business_Open_RT && (newCase.Origin == 'Email Business (BizHelp)' || newCase.Origin == 'Email Business (YouTube)')){
            Social_StreamingUtil.businessAssignQueue.add(newCase.Id);
        }
          recursiveflag = TRUE; 
        // ABS Rel3
        // if(!Social_CaseEmailInBoundUtilities.queueInsert.contains(newCase.id)){ 
        if(newCase.RecordTypeId == System.Label.Business_Manual_RT && newCase.Business_Case_Post_Tag__c !=null) {
            //ABS 9 Release
            List<String> caseTagList = new List<String>(newcase.Business_Case_Post_Tag__c.split(';'));               
            for(String caseTag: caseTagList){
                if(ConsumerPostTagSet.contains(caseTag.trim().toUpperCase())){
                    validPostTag = true; //Boolean check set to true if the Business Multi-select pick list has a consumer post tag
                    break;
                }
            }
            // If field Contains Consumer post tag and the check box is checked, and context user is not R6 user or Automated Admin update the field.
            if(validPostTag && newCase.Contains_Consumer_Post_Tag__c == True && !userInfo.getUserId().contains('005E0000002G4RU') && userInfo.getName() != 'Automated Admin'){
                newCase.Case_PostTag__c = newCase.Business_Case_Post_Tag__c.replaceAll(';',',');
                newCase.Case_Post_Tag__c = newCase.Business_Case_Post_Tag__c;
                newCase.Contains_Consumer_Post_Tag__c = False;
            } 
            //If field contains Consumer post tag and check box is unchecked, Display error.            
            else if(validPostTag && newCase.Contains_Consumer_Post_Tag__c == False && (contextUserId!='005E0000002G4RU' || contextUserId!='005E0000002GS0N' )){                
                newCase.addError('You have selected a Consumer post tag, Please confirm by selecting the checkbox : Contains Consumer Post Tag ?' );                
            } 
            // if field contains only business post tag 
            else {
                    newCase.Case_PostTag__c = newCase.Business_Case_Post_Tag__c.replaceAll(';',',');
                    newCase.Case_Post_Tag__c = newCase.Business_Case_Post_Tag__c;
                    newCase.Contains_Consumer_Post_Tag__c = False;
            }
        }                     
            if(newCase.RecordTypeId!=null && String.ValueOf(newCase.RecordTypeId).equals(managerUtilClass.generateCaseRecordId('Social Media'))){
                newCase.RecordTypeId = managerUtilClass.generateCaseRecordId('Consumer Care Case');
            }
            //Aditya: Added check for General Care Manager profile for marking reason as Completed.
            String profileIds = label.HS_Care_Rep_Profile_Id;//String for getting ids from custom label.
            if(profileIds != Null) {
                profileIdsCustomLabelSet.addAll(profileIds.split(';'));
            }
            if(UserInfo.getProfileId()!=null && !profileIdsCustomLabelSet.isEmpty() && !profileIdsCustomLabelSet.Contains(userInfo.getProfileId()) ){
                    if(newCase.Case_Reason_HSRep__c!=null && (newCase.Case_Reason_HSRep__c).equalsIgnoreCase('Resolved')){
                        newCase.Reason = 'Completed';
                    }
                    else{
                        newCase.Reason = newCase.Case_Reason_HSRep__c;
                    }            
            }
            if(newCase.RecordTypeId != System.Label.Business_Open_RT){
                validateUtilClass.processInsertedCase(newCase); 
            }
               
        }      

      }// End Of For Loop
      
      // Data Base Operations
      validateUtilClass.performDatabaseSaves();

      // Flag To Prevent Recursion
      if(Social_triggerRunControl.isTriggerFirstRun && !Trigger.isInsert){
          Social_triggerRunControl.isTriggerFirstRun = false;
      }
    } 
      
      for(case newCase: Trigger.new){     
       if(trigger.IsUpdate){   
        // if(!Social_CaseEmailInBoundUtilities.queueUpdate.contains(newCase.id)){  
            if(newCase.Is_Business_Assigned__c != trigger.oldMap.get(newCase.Id).Is_Business_Assigned__c 
                && newCase.Is_Business_Assigned__c == TRUE 
                && (newCase.OwnerId == System.label.GENERAL_BC_QUEUE || newCase.OwnerId == System.label.SOCIAL_SALES_LEAD_QUEUE) 
                &&  newCase.RecordTypeId == System.Label.Business_Open_RT){                   
                if(businessCaseMap.containsKey(newCase.OwnerId)){
                    businessCaseMap.get(newCase.OwnerId).add(newCase);
                }                     
                else{
                    businessCaseMap.put(newCase.OwnerId, new List<Case>{newCase});
                } 
                
            newCase.Update_Reason__c = 'Case Assigned'; //added for ITS#471 on 12th feb       
                   
        }
        // Code  update the contact fields in Last Case Close Added by Mallaiah 
        if(newCase.Status == 'Closed' && Trigger.oldMap.get(newCase.Id).Status!= 'Closed'&& newCase.Status != Trigger.oldMap.get(newCase.Id).Status ) {
            Social_StreamingUtil.contactProcessed.add(newCase.contactId);
            UpdateConIds.add(newCase.contactId); 
        }
          
     //added by Ashween on 15th Jan for round robin to trigger for manual case owner change to queue 
        String newCaseOwner = newCase.ownerId;
        String oldCaseOwner = trigger.oldMap.get(newCase.Id).ownerId;
        if( newCase.OwnerId != Trigger.oldMap.get(newCase.Id).OwnerId && newCaseOwner.startsWith('00G') && oldCaseOwner.startsWith('005')
             && newCase.RecordTypeId == System.Label.Business_Open_RT && Trigger.oldMap.get(newCase.Id).RecordTypeId != System.Label.Business_Manual_RT                       
             ){ 
               if(Social_StreamingUtil.caseOpenBusinessStatus.contains(Trigger.oldMap.get(newCase.Id).Status) && ( newCase.OwnerId == System.label.GENERAL_BC_QUEUE|| newCase.OwnerId == System.label.SOCIAL_SALES_LEAD_QUEUE))
                 { 
                   if(countIncCaseUserMap.containsKey(Trigger.oldMap.get(newCase.Id).OwnerId)){
                        countIncCaseUserMap.get(Trigger.oldMap.get(newCase.Id).OwnerId).add(newCase);
                    }        
                    else{
                         countIncCaseUserMap.put(Trigger.oldMap.get(newCase.Id).OwnerId, new List<Case>{newCase});                        
                        }
                  }
                  
                 if(caseOwnerQueueMap.containsKey(newCase.OwnerId)){
                     caseOwnerQueueMap.get(newCase.OwnerId).add(newCase);
                 }
                 else{
                     caseOwnerQueueMap.put(newCase.OwnerId, new List<Case>{newCase});
                 }  
         } 
               
       // ashween adding case counter decrement logic for business to consumer(user-> queue)assignment on 04062015 
          if(Social_StreamingUtil.caseOpenBusinessStatus.contains(Trigger.oldMap.get(newCase.Id).Status) &&  newCase.OwnerId != Trigger.oldMap.get(newCase.Id).OwnerId 
             && newCase.RecordTypeId == System.Label.ConsumerCareCase  && Trigger.oldMap.get(newCase.Id).RecordTypeId == System.Label.Business_Open_RT  ){               
                if(countIncCaseUserMap.containsKey(Trigger.oldMap.get(newCase.Id).OwnerId)){                 
                   countIncCaseUserMap.get(Trigger.oldMap.get(newCase.Id).OwnerId).add(newCase);                            
                 }        
                 else{                     
                      countIncCaseUserMap.put(Trigger.oldMap.get(newCase.Id).OwnerId, new List<Case>{newCase});                    
                 } 
                // On 04082015 Ashween added logic for closing Business SLA events and updating SLA fields           
                if(newCaseOwner.startsWith('00G') && oldCaseOwner.startsWith('005') && (('SLA1 - Initiated'.equalsIgnoreCase(newCase.Current_SLA_Phase__c) && newCase.First_SLA_Response_Time__c == Null) || ('SLA2 - Initiated'.equalsIgnoreCase(newCase.Current_SLA_Phase__c) && newCase.Second_SLA_Response_Time__c == Null)) ){                   
                    Social_markCaseUpdates.caseSlaReset(newCase, oldCaseOwner);
                }            
            } 
        // ashween adding case counter logic for ITS#1707 when manually case status is changed from Closed to Investigating    
             if(contextUserId.equalsIgnorecase(newCase.OwnerID) && newCase.Status == 'Investigating' && Trigger.oldMap.get(newCase.Id).Status == 'Closed' && !Social_StreamingUtil.countProcessed.contains(newCase.Id)){
                 if(countDecCaseUserMap.containsKey(newCase.OwnerId)){
                     countDecCaseUserMap.get(newCase.OwnerId).add(newCase);
                 }        
                 else{
                     countDecCaseUserMap.put(newCase.OwnerId, new List<Case>{newCase});
                 }
              Social_StreamingUtil.countProcessed.add(newCase.Id);            
             }             
             
             Social_CaseEmailInBoundUtilities.queueUpdate.add(newCase.id);
             
             if(trigger.IsUpdate && newCase.Status == 'Closed' && trigger.oldMap.get(newCase.Id).Status!= newCase.Status && (newCase.RecordTypeId == System.Label.Business_Closed_RT || newCase.RecordTypeId == System.Label.Business_Open_RT)){                          
                       if(operationsUpdateMap.containsKey(newCase.OwnerId)){
                           operationsUpdateMap.get(newCase.OwnerId).add(newCase);
                       }                   
                       else{
                           operationsUpdateMap.put(newCase.OwnerId,new List<Case>{newCase});
                       }                                          
                 }                             
            }
      }      
     //  update  call the method contact fields in Last Case CloseAdded By Mallaiah 
     if(!UpdateConIds.isEmpty()){
         Social_validateCaseQueueUtil.updateConLastCaseClose(UpdateConIds);
     }
     
    if(autoCloseCaseList.size()>0){
       Social_BusinessAutoCaseClosure.autoCloseCase(autoCloseCaseList);    
    } 
    if( countIncCaseUserMap.size()>0 ){
        Social_BusinessRoundRobin.countUserCaseUpdate(countIncCaseUserMap,descDummyMap,countDummyMap);        
        countReduce = TRUE;        
    }
            
    // added by Ashween on 0630 for manual case ownership case counter increment    
    if( countDecCaseUserMap.size()>0 ){        
        Social_BusinessRoundRobin.countUserCaseUpdate(descDummyMap,countDecCaseUserMap,countDummyMap);
        countReduce = TRUE;        
    }
    if(businessCaseMap.size()>0){        
        flagSLA = FALSE;
        Social_BusinessRoundRobin.businessCaseAssignment(businessCaseMap, flag ,flagSLA);       
    }
    // Ashween brought this code piece up for Timba Survey to be sent out ITS1401
    if(caseIdSet.size()>0){    
        SocialCareForseeHandler socialCareHandler = new SocialCareForseeHandler();
        socialCareHandler.generateForSeeUrls(caseIdSet);
    }    
    // Ashween brought this code piece up for closed operation manager field to be populated for ITS1334   
    if(operationsUpdateMap.size()>0){    
        Social_ClosedCaseReOpenHandler.updateOperationsManager(operationsUpdateMap);        
    }
    // Ashween commented out the two blocks of code for Feb 11, 2015 relaese
    if(caseOwnerQueueMap.size()>0 && countReduce){
        flagSLA= TRUE;        
        Social_BusinessRoundRobin.businessCaseAssignment(caseOwnerQueueMap,flag ,flagSLA );       
    }    
    // Calling method and passing the set of cases for which the record needs to be inserted for reassigned time    
    if(!ReassignedCaseSet.isEmpty()){
       Social_markCaseUpdates.CaseReassignments(ReassignedCaseSet,Social_StreamingUtil.MANUAL,Social_StreamingUtil.REASSIGNED);     
    }
    
}