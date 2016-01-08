trigger BizReopenCaseReassignment on Case (after insert, after update) {
    if (Social_StreamingUtil.doNtFireEmail2CaseRun && (Boolean.valueOf(Label.Deactivate_Case_Triggers))) {  
        Set<Id> ownerIdSet = new Set<Id>();//to store the owner id of the user whose case counter should be updated
        Set<String> recordTypeIdSet = new Set<String>(); //to store consumer record type.
        Set<Id> contactClosedCaseSetId = new Set<Id>();
        //consumer logic to update case counter on user when case owner or status of case changes.
        //doNtFireEmail2CaseRun - this flag will be false when custom email2case logic runs
        //stopRecurssionFlag - this flag is used to stop trigger to fire after workflow runs on case
        if (trigger.isUpdate && trigger.isAfter && userInfo.getUserId() != '005E0000002G4RU' && Social_StreamingUtil.stopRecurssionFlagCase) {
            recordTypeIdSet.addAll(Label.Consumer_RT.split(','));
            Social_StreamingUtil.stopRecurssionFlagCase = false;  
            for(case caseObj: trigger.New) {
                String oldCaseOwner = trigger.oldMap.get(caseObj.Id).OwnerId;
                String newCaseOwner = caseObj.ownerId;
                //If owner isChanged and old owner was queue and current owner is a user then update case counter on user.
                if (caseObj.ownerId != trigger.oldMap.get(caseObj.Id).OwnerId && oldCaseOwner.startsWith(social_caseCounterUserUpdateConstants.QUEUE_ID) && newCaseOwner.startsWith(social_caseCounterUserUpdateConstants.USER_ID) && recordTypeIdSet.contains(caseObj.recordTypeId)) {
                    ownerIdSet.add(caseObj.ownerId);
                //If owner isChanged and old owner was a user and current owner is a user then update case counter on user
                } else if (caseObj.ownerId != trigger.oldMap.get(caseObj.Id).OwnerId && oldCaseOwner.startsWith(social_caseCounterUserUpdateConstants.USER_ID) && newCaseOwner.startsWith(social_caseCounterUserUpdateConstants.USER_ID) && recordTypeIdSet.contains(caseObj.recordTypeId)) {
                    ownerIdSet.add(caseObj.ownerId);
                    ownerIdSet.add(trigger.oldMap.get(caseObj.Id).OwnerId);
                //If owner isChanged and case is reassigned from user to a queue.
                } else if (caseObj.ownerId != trigger.oldMap.get(caseObj.Id).OwnerId && oldCaseOwner.startsWith(social_caseCounterUserUpdateConstants.USER_ID) && newCaseOwner.startsWith(social_caseCounterUserUpdateConstants.QUEUE_ID) && recordTypeIdSet.contains(caseObj.recordTypeId)) {
                    ownerIdSet.add(trigger.oldMap.get(caseObj.Id).OwnerId);
                //If status of the case isChanged and current status is new,investigating,reopen,escalated,Reassigned and old status was closed,follow up hold then update case counter on user
                }else if (caseObj.status != trigger.oldMap.get(caseObj.Id).status && (caseObj.status == social_caseCounterUserUpdateConstants.STATUS_NEW || caseObj.status == social_caseCounterUserUpdateConstants.STATUS_REOPEN || caseObj.status == social_caseCounterUserUpdateConstants.STATUS_REASSIGNED || caseObj.status == social_caseCounterUserUpdateConstants.STATUS_INVESTIGATING || caseObj.status == social_caseCounterUserUpdateConstants.STATUS_ESCALATED) && (trigger.oldMap.get(caseObj.id).status == social_caseCounterUserUpdateConstants.STATUS_CLOSED || trigger.oldMap.get(caseObj.id).status == social_caseCounterUserUpdateConstants.STATUS_FOLLOW_UP_HOLD) && recordTypeIdSet.contains(caseObj.recordTypeId)) {
                    ownerIdSet.add(caseObj.ownerId);
                //If status of the case isChanged and old status is new,investigating,reopen,escalated,Reassigned and current status was closed,follow up hold then update case counter on user
                } else if (caseObj.status != trigger.oldMap.get(caseObj.Id).status && (caseObj.status == social_caseCounterUserUpdateConstants.STATUS_CLOSED || caseObj.status == social_caseCounterUserUpdateConstants.STATUS_FOLLOW_UP_HOLD) && (trigger.oldMap.get(caseObj.id).status == social_caseCounterUserUpdateConstants.STATUS_NEW || trigger.oldMap.get(caseObj.id).status == social_caseCounterUserUpdateConstants.STATUS_REOPEN || trigger.oldMap.get(caseObj.id).status == social_caseCounterUserUpdateConstants.STATUS_REASSIGNED || trigger.oldMap.get(caseObj.id).status == social_caseCounterUserUpdateConstants.STATUS_INVESTIGATING || trigger.oldMap.get(caseObj.id).status == social_caseCounterUserUpdateConstants.STATUS_ESCALATED) && recordTypeIdSet.contains(caseObj.recordTypeId)) {
                    ownerIdSet.add(caseObj.ownerId);
                }
                //When case status is changed from closed to open, update Last Case Closed field on contact
                if (caseObj.status != trigger.oldMap.get(caseObj.Id).status && (caseObj.status != 'Closed' || caseObj.status != 'Auto Closed') && (trigger.OldMap.get(caseObj.Id).Status == 'Closed' || trigger.OldMap.get(caseObj.Id).Status == 'Auto Closed') && recordTypeIdSet.contains(caseObj.recordTypeId)){
                    Social_StreamingUtil.contactProcessed.add(caseObj.contactId);
                    contactClosedCaseSetId.add(caseObj.contactId);
                }
            }
        } else if (trigger.isInsert && trigger.isAfter && userInfo.getUserId() != '005E0000002G4RU' && Social_StreamingUtil.stopRecurssionFlagCase) {
            recordTypeIdSet.addAll(Label.Consumer_RT.split(','));
            for (Case caseObjInsert : trigger.New) {
                String newCaseOwner = caseObjInsert.ownerId;
                //For manual cases during insert
                if (newCaseOwner.startsWith(social_caseCounterUserUpdateConstants.USER_ID) && recordTypeIdSet.contains(caseObjInsert.recordTypeId)) {
                    ownerIdSet.add(caseObjInsert.ownerId);
                }
            }
        }
        //If ownerIdSet is not empty
        if(!ownerIdSet.isEmpty()) {
            social_caseCounterUserUpdate.updateCaseCounterUser(ownerIdSet);            
        }
        if (!contactClosedCaseSetId.isEmpty()) {
            Social_ContactLastClosedCaseController.updateContactOnCaseReopen(contactClosedCaseSetId);
        }
    Map<Id,List<Case>> caseMap= new Map<Id,List<Case>>(); // map of Business cases Id's which got reopened 
    
    //Id SYSTEM.LABEL.Business_Open_RT = RecordTypeHelper.GetRecordTypeId('Case','Business Care Case'); // Stores record type id of Business Care Closed case Record Type
    //Id SYSTEM.LABEL.Business_Closed_RT = RecordTypeHelper.GetRecordTypeId('Case','Business Care Closed Case'); // Stores record type id of Business Care Closed case Record Type
    
    Set<Id> caseOwnerIdSet = new Set<Id>();
    Map<Id, List<Case>> countIncCaseUserMap= new Map<Id, List<Case>>();
    Map<Id, List<Case>> countDecCaseUserMap= new Map<Id, List<Case>>();
    Map<Id, List<Case>> countCloseCaseUserMap= new Map<Id, List<Case>>();
    Set<Id> businessQueueSet = new Set<Id>();
    Map<Id, List<Case>> businessCaseMap = new Map<Id, List<Case>>(); 
    Boolean flag = true;
    Boolean flagSLA = false;
    Boolean countReduce = false;
    Set<id> caseIdSet = new Set<Id>();
    Set<Id> contactIdSet = new Set<Id>();
    
    // if(Social_CaseAssignmentUtility.executeTriggerCode){  
      if(Social_StreamingUtil.BizSocialSalesFlag ){  
      
        for(Case singleCase: Trigger.new)
        {
            
            if(singleCase.RecordTypeId == SYSTEM.LABEL.Business_Open_RT && singleCase.ContactId != NULL){
                contactIdSet.add(singleCase.ContactId);
            }
          //  if(!Social_CaseEmailInBoundUtilities.idProcessed.contains(singleCase.id)){
            if(singleCase.Status == 'Reopen' && trigger.oldMap.get(singleCase.Id).Status == 'Closed' && 
                (singleCase.RecordTypeId == SYSTEM.LABEL.Business_Closed_RT 
                 || singleCase.RecordTypeId == SYSTEM.LABEL.Business_Open_RT)){
             if(caseMap.containsKey(singleCase.OwnerId))
                     {
                         caseMap.get(singleCase.OwnerId).add(singleCase);
                     }
                     else{
                         caseMap.put(singleCase.OwnerId, new List<Case>{singleCase});
                     }                      
             } 
           //   Social_CaseEmailInBoundUtilities.idProcessed.add(singlecase.id);
            // }
             if(singleCase.RecordTypeId == SYSTEM.LABEL.Business_Open_RT )
                 {                     
                      caseOwnerIdSet.add(singleCase.OwnerId);
                 }

              //if(!Social_CaseEmailInBoundUtilities.updateProcessed.contains(singleCase.id)){
             if(trigger.IsUpdate && (singleCase.RecordTypeId == SYSTEM.LABEL.Business_Open_RT 
                 || singleCase.RecordTypeId == SYSTEM.LABEL.Business_Closed_RT)){                
               
                
                 
                 if(singleCase.Status != trigger.oldMap.get(singleCase.Id).Status && 
                     (Social_StreamingUtil.caseNotOpenBusinessStatus.contains(singleCase.Status) 
                     && Social_StreamingUtil.caseOpenBusinessStatus.contains(trigger.oldMap.get(singleCase.Id).Status))){
                     if(countIncCaseUserMap.containsKey(singleCase.OwnerId)){
                         countIncCaseUserMap.get(singleCase.OwnerId).add(singleCase);
                         Social_StreamingUtil.BizSocialSalesFlag = FALSE;
                     }        
                     else{
                         countIncCaseUserMap.put(singleCase.OwnerId, new List<Case>{singleCase});
                         Social_StreamingUtil.BizSocialSalesFlag = FALSE;
                     }
                 }
                 
                 if(Social_StreamingUtil.caseOpenBusinessStatus.contains(trigger.oldMap.get(singleCase.Id).Status) 
                     && singleCase.Status == 'Closed' && !Social_StreamingUtil.reassignProcessed.contains(singleCase.Id)){                     
                     if(countCloseCaseUserMap.containsKey(singleCase.OwnerId)){
                         countCloseCaseUserMap.get(singleCase.OwnerId).add(singleCase);
                         Social_StreamingUtil.BizSocialSalesFlag = FALSE;
                     }        
                     else{
                         countCloseCaseUserMap.put(singleCase.OwnerId, new List<Case>{singleCase});
                         Social_StreamingUtil.BizSocialSalesFlag = FALSE;
                     }
                     Social_StreamingUtil.reassignProcessed.add(singleCase.Id);
                 }         
                  
                  if(singleCase.Status != trigger.oldMap.get(singleCase.Id).Status && 
                 (Social_StreamingUtil.caseOpenBusinessStatus.contains(singleCase.Status) && (Social_StreamingUtil.caseNotOpenBusinessStatus.contains(trigger.oldMap.get(singleCase.Id).Status) /*|| trigger.oldMap.get(singleCase.Id).Status == 'Closed'*/)) && !Social_StreamingUtil.countProcessed.contains(singleCase.Id)){
                     if(countDecCaseUserMap.containsKey(singleCase.OwnerId)){
                         countDecCaseUserMap.get(singleCase.OwnerId).add(singleCase);
                     }        
                     else{
                         countDecCaseUserMap.put(singleCase.OwnerId, new List<Case>{singleCase});
                     }
                     Social_StreamingUtil.countProcessed.add(singleCase.Id);
                 }                    
                 }
                 //   Social_CaseEmailInBoundUtilities.updateProcessed.add(singleCase.id); 
             //}       
               
               /*if(trigger.IsUpdate && singleCase.Status == 'Closed' && singleCase.RecordTypeId == SYSTEM.LABEL.Business_Closed_RT && trigger.oldmap.get(singleCase.Id).Business_Survey_Indicator__c != singleCase.Business_Survey_Indicator__c && singleCase.Business_Survey_Indicator__c == TRUE){
                   caseIdSet.add(singleCase.Id);
               } */                  
        }
    }     
    if(caseMap.size()>0){
        Social_CaseReassignment.identifyReopenCases(caseMap);
    }      
    if(countIncCaseUserMap.size()>0 || countDecCaseUserMap.size()>0 || countCloseCaseUserMap.size()>0){
        Social_BusinessRoundRobin.countUserCaseUpdate(countIncCaseUserMap,countDecCaseUserMap,countCloseCaseUserMap);
        countReduce = TRUE;
    }    
    if(countCloseCaseUserMap.size()>0){    
        for(Group singleUser : [Select Id from Group where Type='Queue' AND (Name = 'General-bc' OR Name = 'Social Sales Lead')]){
             businessQueueSet.add(singleUser.Id);
         } 
        for(Case singleCase: [Select Id, Status,Origin, Update_reason__c, CaseNumber,OwnerId,CreatedDate,Case_Assigned_Time__c,Current_SLA_Phase__c,First_SLA_Scheduled_Time__c,
                             Case_PostTag__c,Second_SLA_Start_Time__c,Second_SLA_Scheduled_Time__c,
                             Track_Case_Queue__c from Case where OwnerId IN: businessQueueSet]){
            if(businessCaseMap.containsKey(singleCase.OwnerId))
            {
                businessCaseMap.get(singleCase.OwnerId).add(singleCase);
            }
            else{
                businessCaseMap.put(singleCase.OwnerId, new List<Case>{singleCase});
            }
        }
        
    }    
    if(businessCaseMap.size()>0 && countReduce){    
        Social_BusinessRoundRobin.businessCaseAssignment(businessCaseMap,flag ,flagSLA );
        
    }
    if(contactIdSet.size()>0){
        Social_ClosedCaseReOpenHandler.updateContactAccount(contactIdSet);
    }
    /*if(caseIdSet.size()>0){
        SocialCareForseeHandler socialCareHandler = new SocialCareForseeHandler();
        socialCareHandler.generateForSeeUrls(caseIdSet);
    }*/
    }   
}