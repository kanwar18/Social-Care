/*** 
 * Class Name: Social_socialPostSCSHandler
 * Author: Accenture
 * Date: 4-Mar-2015
 * Requirement/Project Name: Consumer/Business - Social Care
 * Requirement Description: This class will handle static helper for SCS related functionalities.  
 * Version History: Debasis(5/June/2015) - Release 17June2015 - ITS1504; Users were forced to reply using the comment option for Facebook reply post. 
 * Version History: Ashween(5/June/2015) - Release 17June2015 - ITS1509: Case status change to Investigating from Reopen
 * Version History: Hamen(15/July/2015) - Release 15July2015 - ITS1545
 * Version History: Haemen(7/10/2015) - Release 21stOctober2015 - ITS1657 : Case Reassigned time Blanked out when moving case back to Queue.
 * Version History: Haemen(10/Dec/2015) - Release 20th January2016 - ITS1188 : To blank out the reassignment reason, Auto Reassignment Tag and update the Case post tag accoerding to the Reassignment tag
**/

public class Social_SocialPostSCSHandler {
    
    /**
    * < caseUpdateOnOutboundPostAndEventClosure () - Method to end SLAs and closed events>
    * @param:
    *     caseIdSet: contains cases to be updated.
    *     socialPostMap: social post based on which event closure take place.  
    * @return - void
    * @see -  (same class)   
    */
    
    Public Static void caseUpdateOnOutboundPostAndEventClosure (Map<Id,SocialPost> socialPostMap) {
        List<Case> caseListToUpdate = new List<Case>();//List to update the case
        Map<Id,Id> caseTeamMemberMap = new Map<Id,Id>();//Map key as case owner and value as case id
        Set<Id> caseOwnerIdSet = new Set<Id>();
        Set<String> consumerRTList = new Set<String>();
        Set<Id> whatIdSetForEventClose = new Set<Id> ();
        Set<Id> duplicateCaseIdSet = new Set<Id>(); // Avoid duplicate addition to caseListToUpdate list
        Set<String> TraineeProfileIdsSet = new Set<String>();//Set to store profile ids specified in custom label.
        TraineeProfileIdsSet.addAll(label.HS_REP_PROFILE_ID_15_DIGIT.split(';')); //Set for getting ids of trainee profile from custom label
        consumerRTList.addAll(System.Label.Consumer_RT.split(','));     
        //Query the case and update it.
        for (Case caseObj: [select id,Business_Case_Post_Tag__c,Auto_Reassignment_Tag__c,Do_Not_Reassign_Timeframe__c,Customer_Response_Received__c,Case_Reassigned_Time__c,Case_Assigned_Time__c,Customer_Response_Received_Time__c,count__c,RecordTypeId,Last_Outreach_Time__c,Initial_OutReach_Manager__c,Reason,ownerId,status,Current_SLA_Phase__c,First_SLA_Response_Time__c,Do_Not_Reassign__c,First_SLA_Scheduled_Time__c,Second_SLA_Scheduled_Time__c,Second_SLA_Response_Time__c,Social_Media_Source__c from case where Id IN:socialPostMap.KeySet() limit 50000]) {
            //Logic to populate social persona name on social post record for consumer cases
            if (!Boolean.valueOf(System.Label.EnableSCSSocialHandle)) {
                if (Social_StreamingUtil.MEDIA_PROVIDER_TWITTER.equalsIgnoreCase(caseObj.Social_Media_Source__c)) {
                    socialPostMap.get(caseObj.Id).Social_Persona__c = System.Label.PersonaNameTwitterConsumer;
                } else if (Social_StreamingUtil.MEDIA_PROVIDER_FACEBOOK.equalsIgnoreCase(caseObj.Social_Media_Source__c)) {
                    socialPostMap.get(caseObj.Id).Social_Persona__c = System.Label.PersonaNameFacebookConsumer;
                }
            } else {
                SCSHandles__c scsHandle = new SCSHandles__c();
                Map<String, SCSHandles__c> scsSocialHandleAccountMap = SCSHandles__c.getAll();
                if (socialPostMap.containsKey(caseObj.Id) && socialPostMap.get(caseObj.Id).OutboundSocialAccountId != Null) {
                    String manageSocialAccount = string.valueOf(socialPostMap.get(caseObj.Id).OutboundSocialAccountId).subString(0,15);
                    if (socialPostMap.get(caseObj.Id).Social_Persona__c == Null && manageSocialAccount != Null && manageSocialAccount != '' && scsSocialHandleAccountMap.containsKey(manageSocialAccount)) {
                        socialPostMap.get(caseObj.Id).Social_Persona__c = String.valueOf(scsSocialHandleAccountMap.get(manageSocialAccount).Social_Handle_Name__c);
                    }
                }
            }
            
            String caseOwnerString = caseObj.ownerId;
            /************ LOGIC TO DISPLAY ERROR MESSAGE IN CASE CASE OWNER IS A QUEUE ************/
            if (caseOwnerString.startsWith(Social_StreamingUtil.QUEUE_ID) && socialPostMap.containsKey(caseObj.Id)) {
                socialPostMap.get(caseObj.Id).addError(Social_StreamingUtil.ERROR_MSG_ACCEPT_THE_CASE);
            //Error message to be displayed on UI incase users replies to customer with case owner as queue
            /************ LOGIC TO UPDATE CASE ON OUTREACH AND ASIGN NEW CASE TO USER ************/
            /************ CONSUMER/BUSINESS ************/
            } else if (socialPostMap.containsKey(caseObj.Id) && socialPostMap.get(caseObj.Id).StatusMessage != null &&  Social_StreamingUtil.SOCIALPOST_STATUS_SENT.equalsIgnoreCase(socialPostMap.get(caseObj.Id).StatusMessage) && socialPostMap.get(caseObj.Id).OwnerId == caseObj.OwnerId) {                                             
                //Logic to populate outreach time on social post record and to distinguish the follow up post
                if (Social_CaseOutreachTimeCtrl.calculateOutreachTime(socialPostMap.get(caseObj.Id),caseObj).SubStringBefore('-') != 'null' && Social_CaseOutreachTimeCtrl.calculateOutreachTime(socialPostMap.get(caseObj.Id),caseObj).SubStringBefore('-') != '') {
                    String socialPostCalculations = Social_CaseOutreachTimeCtrl.calculateOutreachTime(socialPostMap.get(caseObj.Id),caseObj);
                    socialPostMap.get(caseObj.Id).Outreach_Time__c = decimal.ValueOf(socialPostCalculations.SubStringBefore('-')); 
                    socialPostMap.get(caseObj.Id).Is_Follow_Up_Post__c = Boolean.valueOf(socialPostCalculations.substringBetween('-','^'));
                    socialPostMap.get(caseObj.Id).Calculated_of__c = socialPostCalculations.substringBetween('^','$');
                    socialPostMap.get(caseObj.Id).Value_in_field__c = DateTime.ValueOf(socialPostCalculations.substringBetween('$','/'));
                    socialPostMap.get(caseObj.Id).Value_in_field_Text__c = socialPostCalculations.substringAfter('/');                                 
                }
                if (consumerRTList.contains(caseObj.RecordtypeId)) {
                    caseOwnerIdSet.add(caseObj.ownerId);
                }
                if(caseObj.RecordTypeId == SYSTEM.LABEL.Business_Open_RT){
                   if(caseObj.count__c!=NULL){
                       caseObj.count__c += 1;
                   }
                   else{
                       caseObj.count__c = 0;
                       caseObj.count__c += 1;
                   }                    
                }
                if(caseObj.Initial_Outreach_Manager__c == NULL && socialPostMap.containsKey(caseObj.Id)){
                    caseObj.Initial_Outreach_Manager__c = socialPostMap.get(caseObj.Id).createdById;
                }                
                //Change case status to Investigating when care manager responds to customer.
                // Ashween added reopen clause for business cases ITS1509
                if (Social_StreamingUtil.CASE_STATUS_NEW.equalsIgnoreCase(caseObj.Status) || ('Reopen'.equalsIgnoreCase(caseObj.Status) && caseObj.RecordtypeId == SYSTEM.LABEL.Business_Open_RT )) {
                    caseObj.Status = Social_StreamingUtil.CASE_STATUS_INVESTIGATING;
                }
                //Do not reassign case back to pending queue if case reason is completed and record type is not consumer and DNR is checked on the case
                if (!Social_StreamingUtil.CASE_REASON_COMPLETED.equalsIgnoreCase(caseObj.Reason) && consumerRTList.contains(caseObj.RecordtypeId) && !caseObj.Do_Not_Reassign__c) {
                    //Logic to decrement case counter if case is assigned to pending queue
                    //Check if case owner is not a queue
                    if (!caseOwnerString.startsWith(Social_StreamingUtil.QUEUE_ID)) {
                        Social_StreamingUtil.ownerIdSetForCaseCounter.add(caseObj.ownerId);    
                        //add case owner to case team member list
                        caseTeamMemberMap.put(caseObj.ownerId,caseObj.Id);
                    }
                    caseObj.Prior_Care_Manager__c = caseObj.ownerId;
                    caseObj.ownerId = System.Label.PendingClouseQueueId;
                    //If cases status is not hold for call back
                    if (!Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK.equalsIgnoreCase(caseObj.Status)){
                        caseObj.Status = Social_StreamingUtil.CASE_STATUS_PENDINGCLOSURE;
                    }
                }
                //SLA logic 
                if (Social_StreamingUtil.SLA1_INITIATED.equalsIgnoreCase(caseObj.Current_SLA_Phase__c) && caseObj.First_SLA_Scheduled_Time__c != Null && caseOwnerString.startsWith('005')) {
                    caseObj.Current_SLA_Phase__c = Social_StreamingUtil.SLA1_ENDED;
                    caseObj.First_SLA_Response_Time__c = dateTime.now();
                    whatIdSetForEventClose.add(caseObj.Id);                  
                } else if (Social_StreamingUtil.SLA2_INITIATED.equalsIgnoreCase(caseObj.Current_SLA_Phase__c) && caseObj.Second_SLA_Scheduled_Time__c != Null && caseOwnerString.startsWith('005')) {
                    caseObj.Current_SLA_Phase__c = Social_StreamingUtil.SLA2_ENDED;
                    caseObj.Second_SLA_Response_Time__c = dateTime.now();
                    whatIdSetForEventClose.add(caseObj.Id);                   
                }
                //making customer response check as false
                caseObj.Customer_Response_Received__c = false;
                caseObj.Update_Reason__c = '';
                caseObj.Last_Outreach_Time__c = system.now();
                
                //Flipping the Record type of the case to HS Care Rep record type if social post is inserted by a trainee profile
                if(!TraineeProfileIdsSet.isEmpty() && socialPostMap.containsKey(caseObj.Id) && TraineeProfileIdsSet.Contains(socialPostMap.get(caseObj.Id).Post_Owner_Profile_Id__c)){
                    Social_SocialPostSCSHandler.updateCustomPostforTraineeProfile(caseObj);
                    //Logic to flip case record type to HS care rep if nesting user makes an outreach with case marked as DNR
                    if (caseObj.Do_Not_Reassign__c && caseObj.RecordTypeId == System.Label.ConsumerCareCase) {
                        caseObj.RecordTypeId = System.Label.HS_Care_Rep_RT;
                    }
                }
                
                //adding case to list to update the case                
                caseListToUpdate.add(caseObj);
            /************ LOGIC TO DISPLAY ERROR MESSAGE IN CASE NON CASE OWNER MAKES AN OUTREACH FROM SCS PUBLISHER **********/
            }else if (socialPostMap.containsKey(caseObj.Id) && socialPostMap.get(caseObj.Id).OwnerId != caseObj.OwnerId && consumerRTList.contains(caseObj.RecordtypeId)) {
                socialPostMap.get(caseObj.Id).addError(Social_StreamingUtil.NONCASEOWNER_NO_OUTREACH_ERROR); 
            /************ LOGIC TO POPULATE FEW DETAILS ON CASE WHEN NON CASE OWNER MAKES AN OUTREACH ************/
            /************ BUSINESS ONLY ************/
            } else if (socialPostMap.containsKey(caseObj.Id) && socialPostMap.get(caseObj.Id).StatusMessage != null &&  Social_StreamingUtil.SOCIALPOST_STATUS_SENT.equalsIgnoreCase(socialPostMap.get(caseObj.Id).StatusMessage) && socialPostMap.get(caseObj.Id).OwnerId != caseObj.OwnerId) {
                if(caseObj.Initial_Outreach_Manager__c == NULL && socialPostMap.containsKey(caseObj.Id)){
                    caseObj.Initial_Outreach_Manager__c = socialPostMap.get(caseObj.Id).createdById;
                    caseListToUpdate.add(caseObj);
                    duplicateCaseIdSet.add(caseObj.Id);
                }
                if(caseObj.RecordTypeId == SYSTEM.LABEL.Business_Open_RT){
                   if(caseObj.count__c!=NULL){
                       caseObj.count__c += 1;
                   }
                   else{
                       caseObj.count__c = 0;
                       caseObj.count__c += 1;
                   }
                   if(!duplicateCaseIdSet.contains(caseObj.Id)){
                       caseListToUpdate.add(caseObj);                                                       
                   }
                    
                }
            }
        }
        
        //query events related to cases been sent to pending closure queue
        if (!whatIdSetForEventClose.isEmpty()) {
            closeOpenEvents(whatIdSetForEventClose);
        }
        //Method to insert case owner in case team member
        if (!caseTeamMemberMap.keySet().isEmpty()) {
            Social_SocialPostSCSHandler.insertCaseTeamMember(caseTeamMemberMap);
        }
        //DML to update cases
        if (!caseListToUpdate.isEmpty()) {            
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            Social_StreamingUtil.updateSObject(caseListToUpdate,'Class:social_socialPostSCSHandler Method:caseDetailsUpdateOnOutboundPost');
        }
        //Assign new Case to user
        if (!caseOwnerIdSet.isEmpty()) {
            Social_GroupMemberHandler.assignCasesToUserBulk(caseOwnerIdSet);
        }
        
        //DML to update case counte field on user record
        if (!Social_StreamingUtil.ownerIdSetForCaseCounter.isEmpty()) {
            social_caseCounterUserUpdate.updateCaseCounterUser(Social_StreamingUtil.ownerIdSetForCaseCounter);
        }
    }
    
  
    /**
    * < caseReopenCheck() - Method to verify if case needs to be reopened>
    * @param:
    *     Case singleCase - case to be verified
    *       
    * @return - boolean
    * @see -  (same class)
    *
    *
    *  *********************WARNING: NOT TO BE USED FOR BULKIFIED METHODS    **********************************
    */
    
    Public static boolean caseReopenCheck(Case singleCase) {
        boolean reopenCase = false;
        if(singleCase.Track_Case_Queue__c != null && singleCase.Track_Case_Queue__c !=''){
            List<Group> queue = [select id,Name from Group where (id =:singleCase.Track_Case_Queue__c AND Group.Type = 'Queue') ];
            //If track case queue is blank then new case would get created
            if (!queue.isEmpty()) {
                Assignment_Group_Name__c assignGroup = [select id, Name, Reopen_Duration_in_Hours__c from Assignment_Group_Name__c where Name =: queue[0].Name];
                if(assignGroup != Null && assignGroup.Reopen_Duration_in_Hours__c!=null && singleCase.ClosedDate != Null){
                    Double closingHours = Double.ValueOf(assignGroup.Reopen_Duration_in_Hours__c);
                    Double durationHours = 0;
                    durationHours= Double.ValueOf((datetime.now().getTime() - singleCase.ClosedDate.getTime())/3600000);                  
                if(durationHours < closingHours){
                        reopenCase = true;
                    } else {
                        reopenCase = false;
                    }
                }
            } else {
                reopenCase = false;
            }
        }
        return reopenCase;    
    }
     
    /**
    * < caseUpdateToQueue() - Method to update case to queue when social post comes in>
    * @param:
    *     
    *       
    * @return - void
    * @see -  (same class, Social_SocialPostController)    
    */
    
    Public static Case caseUpdateCustomerResponseReceived(case pendingInQueueCase) {
        Set<String> consumerRTList = new Set<String>();
        consumerRTList.addAll(System.Label.Consumer_RT.split(','));
        String caseOwnerId = pendingInQueueCase.OwnerId;
        pendingInQueueCase.Customer_Response_Received_Time__c = dateTime.Now();
        /************ IF CASE OWNER IS PENDING CLOSURE WHEN RESPONSE COMES FROM CUSTOMER ************/
        //If case is (SLA 1 Ended or SLA 2 Ended) and case owner is pending closure and case status is closed or Auto Closed
        if((Social_StreamingUtil.SLA1_ENDED.equalsIgnoreCase(pendingInQueueCase.Current_SLA_Phase__c) || Social_StreamingUtil.SLA2_ENDED.equalsIgnoreCase(pendingInQueueCase.Current_SLA_Phase__c)) && pendingInQueueCase.ownerId == System.Label.PendingClouseQueueId && (Social_StreamingUtil.CASE_STATUS_CLOSED.equalsIgnoreCase(pendingInQueueCase.status) || Social_StreamingUtil.CASE_STATUS_AUTOCLOSED.equalsIgnoreCase(pendingInQueueCase.status)) ){
            //to blank out the reassignment reason, Auto Reassignment Tag and update the Case post tag accoerding to the Reassignment tag
            if(pendingInQueueCase.Auto_Reassignment_Tag__c != null && pendingInQueueCase.Do_Not_Reassign__c == false && consumerRTList.contains(pendingInQueueCase.RecordtypeId)){
                Social_StreamingUtil.fireAssignmentRule = true;
                pendingInQueueCase.Reassignment_Reason__c = null;
                pendingInQueueCase.Case_Post_Tag__c = pendingInQueueCase.Auto_Reassignment_Tag__c;
                pendingInQueueCase.Case_PostTag__c = pendingInQueueCase.Auto_Reassignment_Tag__c;
                pendingInQueueCase.Business_Case_Post_Tag__c = pendingInQueueCase.Auto_Reassignment_Tag__c;
                pendingInQueueCase.Auto_Reassignment_Tag__c = null;                  
            } else {
                pendingInQueueCase.ownerid = pendingInQueueCase.Track_Case_Queue__c;
            }
            pendingInQueueCase.Case_Reassigned_Time__c = null;
        }
        //If case is (SLA 1 Ended or SLA 2 Ended) and case owner is pending closure and case status is not closed i.e. status is Pending Closure and awaiting to be Auto Closed
        if((Social_StreamingUtil.SLA1_ENDED.equalsIgnoreCase(pendingInQueueCase.Current_SLA_Phase__c) || Social_StreamingUtil.SLA2_ENDED.equalsIgnoreCase(pendingInQueueCase.Current_SLA_Phase__c)) && pendingInQueueCase.ownerId == System.Label.PendingClouseQueueId && !Social_StreamingUtil.CASE_STATUS_CLOSED.equalsIgnoreCase(pendingInQueueCase.status) && !Social_StreamingUtil.CASE_STATUS_AUTOCLOSED.equalsIgnoreCase(pendingInQueueCase.status) ){
            //to blank out the reassignment reason, Auto Reassignment Tag and update the Case post tag accoerding to the Reassignment tag
            if(pendingInQueueCase.Auto_Reassignment_Tag__c != null && pendingInQueueCase.Do_Not_Reassign__c == false && consumerRTList.contains(pendingInQueueCase.RecordtypeId)){
                Social_StreamingUtil.fireAssignmentRule = true;
                pendingInQueueCase.Reassignment_Reason__c = null;
                pendingInQueueCase.Case_Post_Tag__c = pendingInQueueCase.Auto_Reassignment_Tag__c;
                pendingInQueueCase.Case_PostTag__c = pendingInQueueCase.Auto_Reassignment_Tag__c;
                pendingInQueueCase.Business_Case_Post_Tag__c = pendingInQueueCase.Auto_Reassignment_Tag__c;
                pendingInQueueCase.Auto_Reassignment_Tag__c = null;                    
            } else {
                pendingInQueueCase.ownerid = pendingInQueueCase.Track_Case_Queue__c;
            }
            pendingInQueueCase.Case_Reassigned_Time__c = null;
            //If cases status is not hold for call back
            if (!Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK.equalsIgnoreCase(pendingInQueueCase.Status)){
                pendingInQueueCase.Status =  Social_StreamingUtil.CASE_STATUS_ESCALATED;
            }
        /************ IF CASE OWNER IS USER WHEN RESPONSE COMES FROM CUSTOMER ************/
        // If case is SLA 1 Ended and case owner is a user
        } else if (string.ValueOf(pendingInQueueCase.ownerId).Startswith(Social_StreamingUtil.USER_ID)) {
            /************ IF CASE IS NOT MARKED AS DO NOT REASSIGN ************/
            String caseOwnerAvailability = Social_SocialPostController.ownerDetails(pendingInQueueCase)[0].Availability__c;
            if (!pendingInQueueCase.Do_Not_Reassign__c) {
                //If owner is available
                if (!Social_StreamingUtil.USER_STATUS_VACATION.equalsIgnoreCase(caseOwnerAvailability) && !Social_StreamingUtil.USER_STATUS_OFFLINE.equalsIgnoreCase(caseOwnerAvailability) && Social_StreamingUtil.SLA1_ENDED.equalsIgnoreCase(pendingInQueueCase.Current_SLA_Phase__c) && pendingInQueueCase.Customer_Response_Received__c) {
                    pendingInQueueCase.Current_SLA_Phase__c = Social_StreamingUtil.SLA2_INITIATED;
                    pendingInQueueCase.Second_SLA_Scheduled_Time__c = system.Now().addMinutes(60);
                    pendingInQueueCase.Second_SLA_Start_Time__c  = system.now();                    
                    pendingInQueueCase.NonCaseOwner_LastModifiedDate__c = system.now();
                    pendingInQueueCase.readunreadcheck__c = true;
                    Social_SocialPostController.insertEvents(pendingInQueueCase);
                // If owner is not not available send case back to queue
                } else if((Social_StreamingUtil.USER_STATUS_VACATION.equalsIgnoreCase(caseOwnerAvailability) || Social_StreamingUtil.USER_STATUS_OFFLINE.equalsIgnoreCase(caseOwnerAvailability)) && pendingInQueueCase.Track_Case_Queue__c != null){
                    Set<Id> caseIdSet = new Set<Id>();
                    //Add owner id to static set in order to update case counter on user
                    Social_StreamingUtil.ownerIdSetForCaseCounter.add(pendingInQueueCase.ownerId);
                    pendingInQueueCase.ownerId = pendingInQueueCase.Track_Case_Queue__c;
                    pendingInQueueCase.Case_Reassigned_Time__c = null;
                    //If cases status is not hold for call back
                    if (!Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK.equalsIgnoreCase(pendingInQueueCase.Status)){
                        pendingInQueueCase.status = Social_StreamingUtil.CASE_STATUS_REASSIGNED;
                    }
                    // Reset SLA incase case has open SLA's
                    if (Social_StreamingUtil.SLA1_INITIATED.equalsIgnoreCase(pendingInQueueCase.Current_SLA_Phase__c)) {
                        caseIdSet.add(pendingInQueueCase.Id);
                        pendingInQueueCase.Current_SLA_Phase__c = null;
                        pendingInQueueCase.First_SLA_Scheduled_Time__c = null;
                        closeOpenEvents(caseIdSet);
                    } else if (Social_StreamingUtil.SLA2_INITIATED.equalsIgnoreCase(pendingInQueueCase.Current_SLA_Phase__c)) {
                        caseIdSet.add(pendingInQueueCase.Id);
                        pendingInQueueCase.Current_SLA_Phase__c = Social_StreamingUtil.SLA1_ENDED;
                        pendingInQueueCase.Second_SLA_Scheduled_Time__c = null;
                        pendingInQueueCase.Second_SLA_Start_Time__c = null;
                        caseIdSet.add(pendingInQueueCase.Id);
                        closeOpenEvents(caseIdSet);
                    }
                }
            } else  {
                /************ IF CASE IS MARKED AS DO NOT REASSIGN ************/               
                pendingInQueueCase.NonCaseOwner_LastModifiedDate__c = system.now();
                pendingInQueueCase.readunreadcheck__c = true;
                if (Social_StreamingUtil.SLA1_ENDED.equalsIgnoreCase(pendingInQueueCase.Current_SLA_Phase__c) && pendingInQueueCase.Customer_Response_Received__c) {
                    pendingInQueueCase.Current_SLA_Phase__c = Social_StreamingUtil.SLA2_INITIATED;
                    pendingInQueueCase.Second_SLA_Scheduled_Time__c = system.Now().addMinutes(60);
                    pendingInQueueCase.Second_SLA_Start_Time__c  = system.now();
                    Social_SocialPostController.insertEvents(pendingInQueueCase);
                }
            }
        }
        return pendingInQueueCase;
    }
    
    /**
    * < doNotAllowUpdatesOnCase() - Method to display error message if case owner is pending closure queue>
    * @param:
    *        List<case> caseList
    *     
    *       
    * @return - void
    * @see -  (Social_DNETrigger)    
    */
    
    Public static void doNotAllowUpdatesOnCase(List<case> caseList) {
        for (Case caseObj: caseList) {
            caseObj.addError(Social_StreamingUtil.PENDINGCLOSURE_ERROR_MSG);    
        }
    }
    
   /**
    * < doNotAllowEventCreation() - Method to display error message if someone tries to create sla3 events and case sla phase is not sla 2 ended>
    * @param:
    *        Map<Id,Event> eventMap : Id - CaseId, Event- Event object
    *     
    *       
    * @return - void
    * @see -  (SocialCaseSLAClosure - trigger)    
    */
    
    Public static void doNotAllowEventCreation(Map<Id,Event> eventMap){
        for (case caseObj: [select id,Current_SLA_Phase__c from case where Id IN:eventMap.KeySet()]) {
            if (!Social_StreamingUtil.SLA2_ENDED.equalsIgnoreCase(caseObj.Current_SLA_Phase__c)) {
                eventMap.get(caseObj.Id).addError(Social_StreamingUtil.EVENT_ERROR);
            }
        }
    }
    
    /**
    * < caseUpdateReasonEventAction() - Method to update a case when a task is updated by a non case owner>
    * @param:
    *     Map<Id, String> updateReasonCaseMap - Map of case ids and String for the cases being updated for update reason field.
    *       
    * @return - void
    * @see -  SocialCaseSLAClosure trigger on Event object.
    *    
    */
    
    Public static void caseUpdateReasonEventAction(map<Id, String> updateReasonCaseMap){
        List<Case> UpdateReasonCaseList = new List<Case>(); //List of cases to be updated
        for(Case singleCase: [Select Id, ownerId,update_reason__c  from Case where Id IN:updateReasonCaseMap.keySet()]){
            if (Social_StreamingUtil.doNotUpdateReasonBizManualAssignment && singleCase.ownerId != userInfo.getUserId() && String.valueOf(userInfo.getUserId()).subString(0,15) != System.Label.SocialCustomerServiceUserId && String.valueOf(userInfo.getUserId().subString(0,15)) != system.Label.Email_Case_UserId && String.valueOf(userInfo.getUserId().subString(0,15)) != system.Label.BCS_Email_Case_User_Id ){
                if(updateReasonCaseMap.get(singleCase.id).equalsIgnoreCase('Update')){
                    singleCase.update_reason__c = Social_StreamingUtil.EVENT_UPDATED;
                    UpdateReasonCaseList.add(singleCase);
                } else if(updateReasonCaseMap.get(singleCase.id).equalsIgnoreCase('Insert')){
                    singleCase.update_reason__c = Social_StreamingUtil.NEW_EVENT;
                    UpdateReasonCaseList.add(singleCase);
                }
                Social_CaseAssignmentUtility.executeTriggerCode = false;
                Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            }
        }
        Social_StreamingUtil.updateSObject(UpdateReasonCaseList,'Class:social_socialPostSCSHandler Method:caseUpdateReasonEventAction, Failed to update the Update Reason field on Case');
    }
    
    
    
    
    /**
    * < UpdateCaseOnTaskUpdate() - Method to update a case when a task is updated by a non case owner>
    * @param:
    *     List<Id> updateCaseIdList - List of case ids for the cases being updated for update reason field.
    *       
    * @return - void
    * @see -  Social_ActivityHistory trigger on Task object.
    *    
    */
    Public static void UpdateCaseOnTaskUpdate(List<Id> updateCaseIdList){
        List<Case> UpdateReasonCaseList = new List<Case>(); //List of cases to be updated
        for(Case singleCase: [Select Id, ownerId, update_reason__c  from Case where Id IN:updateCaseIdList]){
            if (singleCase.ownerId != userInfo.getUserId()){
                singleCase.update_reason__c = Social_StreamingUtil.TASK_UPDATED;
                UpdateReasonCaseList.add(singleCase);
                Social_CaseAssignmentUtility.executeTriggerCode = false;
                Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            }
        }
        Social_StreamingUtil.updateSObject(UpdateReasonCaseList,'Class:social_socialPostSCSHandler Method:UpdateCaseOnTaskUpdate, Failed to update the Update Reason field on Case');
    }
     
    
    /**
    * < UpdateCaseOnTaskInsert() - Method to update a case when a call is Logged>
    * @param:
    *     Map<Id,Task> caseIdMap - Map of Task being inserted along with parent case details.
    *       
    * @return - void
    * @see -  Social_ActivityHistory trigger on Task object.
    *    
    */
    
    Public static void UpdateCaseOnTaskInsert(Map<Id,Task> caseIdMap){
        Set<Id> caseOwnerIdSet = new Set<Id>();
        String caseOwnerString; // Store Case Owner Id
        List<Case> slaUpdateCaseList = new List<Case>(); //List of cases to be updated
        Map<Id,Id> caseTeamMemberMap = new Map<Id,Id>();//Map key as case owner and value as case id
        Set<Id> caseIdSet = new Set<Id>();
        Set<String> consumerRT = new Set<String>(system.Label.Consumer_RT.split(','));//Set to store all consumer record types
        //Query related cases
        for(Case singleCase: [Select Id,Do_Not_Reassign__c,Reason,Last_Outreach_Time__c, OwnerId, Status, Current_SLA_Phase__c, First_SLA_Response_Time__c, Second_SLA_Scheduled_Time__c,Second_SLA_Response_Time__c, RecordTypeId, First_SLA_Scheduled_Time__c from Case where Id IN: caseIdMap.keySet()]){            
            if (singleCase.ownerId == userInfo.getUserId()){
                if(consumerRT.contains(singleCase.RecordTypeId )){
                    caseOwnerString = singleCase.OwnerId;
                    //Throw error message if case is in Pending closure status
                    if(singleCase.OwnerId == System.Label.PendingClouseQueueId && !Social_CaseUpdateStreamCtrl.caseId.contains(singleCase.Id)){
                        caseIdMap.get(singleCase.Id).addError(Social_StreamingUtil.PENDINGCLOSURE_ERROR_MSG);
                    }
                    //Update case and associated events 
                    else{
                        //check for case owner before updating SLA's
                        if (caseOwnerString.startsWith('005')) {
                            caseOwnerIdSet.add(singleCase.ownerId);
                        }
                        //Change case status to Investigation when care manager responds to customer.
                        // Ashween added reopen clause for business cases ITS1509
                        if (Social_StreamingUtil.CASE_STATUS_NEW.equalsIgnoreCase(singleCase.Status) || ('Reopen'.equalsIgnoreCase(singleCase.Status) && singleCase.RecordtypeId == SYSTEM.LABEL.Business_Open_RT )){              
                            singleCase.Status = Social_StreamingUtil.CASE_STATUS_INVESTIGATING;
                        }
                        //making customer response check as false
                        singleCase.Customer_Response_Received__c = false;
                        singleCase.Update_Reason__c = '';
                        singleCase.Last_Outreach_Time__c = System.now(); 
                        //Do not reassign case back to pending queue if case reason is completed and record type is not consumer and DNR is checked on the case
                        if (!singleCase.Do_Not_Reassign__c && !Social_StreamingUtil.CASE_REASON_COMPLETED.equalsIgnoreCase(singleCase.Reason)) {
                            Social_StreamingUtil.ownerIdSetForCaseCounter.add(singleCase.ownerId);
                            //add case owner to case team member
                            caseTeamMemberMap.put(singleCase.ownerId,singleCase.Id);
                            singleCase.Prior_Care_Manager__c = singleCase.ownerId;
                            singleCase.OwnerId = System.Label.PendingClouseQueueId;  
                            if (!Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK.equalsIgnoreCase(singleCase.Status)){
                                singleCase.Status = Social_StreamingUtil.CASE_STATUS_PENDINGCLOSURE;
                            }
                        }
                        if (Social_StreamingUtil.SLA1_INITIATED.equalsIgnoreCase(singleCase.Current_SLA_Phase__c) && singleCase.First_SLA_Scheduled_Time__c != Null && caseOwnerString.startsWith('005')) {
                            singleCase.Current_SLA_Phase__c = Social_StreamingUtil.SLA1_ENDED;
                            singleCase.First_SLA_Response_Time__c = dateTime.now();  
                        } else if (Social_StreamingUtil.SLA2_INITIATED.equalsIgnoreCase(singleCase.Current_SLA_Phase__c) && singleCase.Second_SLA_Scheduled_Time__c != Null && caseOwnerString.startsWith('005')) {
                            singleCase.Current_SLA_Phase__c = Social_StreamingUtil.SLA2_ENDED;
                            singleCase.Second_SLA_Response_Time__c = dateTime.now();
                            caseIdSet.add(singleCase.Id);
                        }
                        slaUpdateCaseList.add(singleCase);
                        //Disallow Validation error message for this transaction
                        Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                    } 
                } 
          }  
            //Updating the update reason field when a non-case owner inserts a task
            else {
                //Error message when non case owner makes an outreach  via send an email button
                if (caseIdMap.containsKey(singleCase.Id) && caseIdMap.get(singleCase.Id).Subject != Null  && caseIdMap.get(singleCase.Id).Subject.startsWith('Email:')) {
                    caseIdMap.get(singleCase.Id).addError(Social_StreamingUtil.NONCASEOWNER_NO_OUTREACH_ERROR);
                } else {
                    singleCase.update_reason__c = Social_StreamingUtil.NEW_TASK;
                    slaUpdateCaseList.add(singleCase);
                }
            }                        
        }  
        //Query the events to close them
        if(!caseIdSet.isEmpty()){
            closeOpenEvents(caseIdSet);
        }
        //Method to insert case owner in case team member
        if (!caseTeamMemberMap.keySet().isEmpty()) {
            Social_SocialPostSCSHandler.insertCaseTeamMember(caseTeamMemberMap);
        } 
        if(!slaUpdateCaseList.IsEmpty()){
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;                             
            Social_StreamingUtil.updateSObject(slaUpdateCaseList,'Class:social_socialPostSCSHandler Method:UpdateCaseOnTaskInsert, Failed to update SLA fields on Case');            
        }
        //Assign new Case to user
        if (!caseOwnerIdSet.isEmpty()) {
            Social_GroupMemberHandler.assignCasesToUserBulk(caseOwnerIdSet);
        }
        //DML to update case counte field on user record
        if (!Social_StreamingUtil.ownerIdSetForCaseCounter.isEmpty()) {
            social_caseCounterUserUpdate.updateCaseCounterUser(Social_StreamingUtil.ownerIdSetForCaseCounter);
        }  
    }
    
    /**
    * < closeOpenEvents() - Method to Close open events>
    * @param:
    *     Set<Id> caseIdSet - Id of case
    *       
    * @return - void
    * @see -  (same class)
    *
    */
    
    Public static void closeOpenEvents(Set<Id> caseIdSet) {
        List<Event> eventListToUpdate = new List<Event>();//List to update the event
        //Get all the open events related to the case
        for (Event eventsObj: [Select id from event where WhatID IN:caseIdSet and Event_Status__c =: Social_StreamingUtil.EVENT_STATUS_OPEN limit 50000]) {
            eventsObj.Event_Status__c =  Social_StreamingUtil.EVENT_STATUS_CLOSED;
            eventsObj.IsReminderSet = FALSE; // added by Ashween on 0410 2015
            eventListToUpdate.add(eventsObj);
        }
        //DML to update events
        if(!eventListToUpdate.isEmpty()) {
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            Social_StreamingUtil.updateSObject(eventListToUpdate,'Class:social_socialPostSCSHandler Method:caseDetailsUpdateOnOutboundPost, Failed to closed events');
        }
    }
    
   /**
    * < insertCaseTeamMember() - Method to insert case owner into case team member table>
    * @param:
    *     Map<Id,Id> caseMap - Key : Owner Id
    *                          Value : Case Id
    * @return - void
    * @see -  (same class)
    *
    */
    
    Public static void insertCaseTeamMember(Map<Id,Id> caseMap) {
        List<CaseTeamMember> caseTeamMemList = new List<CaseTeamMember>();
        Map<Id,Id> caseTeamMemExistingCheckMap = new Map<Id,Id>();
        //Logic to check if case owner is already added in case team member list
        for (CaseTeamMember existingCase : [select MemberId,ParentId from CaseTeamMember where MemberId IN: caseMap.keySet() and ParentId IN: caseMap.Values()]) {
            caseTeamMemExistingCheckMap.put(existingCase.MemberId,existingCase.ParentId);
        }
        for (Id caseObj: caseMap.keySet()) {
            if (caseMap.containsKey(caseObj) && caseMap.get(caseObj) != null && !caseTeamMemExistingCheckMap.containsKey(caseObj)) {
                CaseTeamMember caseTeamMemberObj = new CaseTeamMember();
                caseTeamMemberObj.MemberId = caseObj;
                caseTeamMemberObj.ParentId = caseMap.get(caseObj);
                caseTeamMemberObj.TeamRoleId = System.Label.CaseTeamMemberRoleId;
                caseTeamMemList.add(caseTeamMemberObj);
            }
        }
        //Insert team member
        Social_StreamingUtil.insertSObject(caseTeamMemList,'Class:social_socialPostSCSHandler Method:insertCaseTeamMember, Failed to insert case team member ');
    }
    
    /**
    * < updateCustomPostforTraineeProfile() - Method to update status of custom post record>
    * @param:
    *     Case caseObj - Case Object
    *
    * @return - void
    * @see -  (same class)
    *
    */
    
    Public static void updateCustomPostforTraineeProfile(Case caseObj) {
        List<Custom_Post__c> customPostList = new List<Custom_Post__c>();
        for (Custom_Post__c customPostObj : [select id,Status__c from Custom_Post__c where Case__c =: caseObj.Id and Status__c =: Social_StreamingUtil.APPROVED]) {
            customPostObj.Status__c = Social_StreamingUtil.SOCIALPOST_STATUS_SENT;
            customPostObj.RecordtypeId = System.Label.Custom_Post_Sent_Record_Type_Id;
            customPostList.add(customPostObj);
        }
        if (!customPostList.isEmpty()) {
            Social_StreamingUtil.updateSObject(customPostList,'Class:social_socialPostSCSHandler Method:updateCustomPostforTraineeProfile, Failed to update custom post while replying to customer ');
        }
    }
    
    /**
    * < inReplyToDetails() - Method to populate inreplyto for social post with message type as Reply>
    * @param:
    *     SocialPost socialPostObj - Social Post Object
    *
    * @return - Id
    * @see -  (Social_SocialPostController)
    *
    */
    
    Public static Id inReplyToDetails(SocialPost socialPostObj) {
        Id socialPostId;
        List <SocialPost> socialCommentList = new List<socialpost>();
        if (socialPostObj.ResponseContextExternalId != null) {
            socialCommentList = [select Id from SocialPost where ExternalPostId =: socialPostObj.ResponseContextExternalId];
            if(!socialCommentList.isEmpty()){
                socialPostId = socialcommentList[0].Id;
            }
        }
        return socialPostId;
    }
    
    /**
    * < flipCaseRTBasedOnProfile() - Method to Flip case record type based on profile>
    * @param:
    *     Case caseObj - Case Object
    *
    * @return - Case
    * @see -  (Social_validateCaseQueueUtil)
    *
    */
    
    Public Static Case flipCaseRTBasedOnProfile (Case caseObj) {
        Set<String> traineeProfileSet = new Set<String>(System.Label.HS_Care_Rep_Profile_Id.split(';'));
        //Logic to flip record type of case for nesting profile user
        if (traineeProfileSet.Contains(userInfo.getProfileId()) && caseObj.RecordTypeId != System.Label.HS_Care_Rep_RT) {
            caseObj.RecordTypeId = System.Label.HS_Care_Rep_RT;
        } else if (!traineeProfileSet.Contains(userInfo.getProfileId()) && caseObj.RecordTypeId != System.Label.ConsumerCareCase && caseObj.RecordTypeId != System.Label.Consumer_Care_Email_Case) {
            if (caseObj.origin != 'Email') {
                caseObj.RecordTypeId = System.Label.ConsumerCareCase;
            } else {
                caseObj.RecordTypeId = System.Label.Consumer_Care_Email_Case;
            }
        }
        return caseObj;
    }
}