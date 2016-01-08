/*
* Version 17th June Release: Ashween added clause in email to case section to change status to Investigating from Reopen *
* when care manager responds to customer post SLA2 ended *
* Release 15th July: ITS-1545
* Release 19th August : ITS - 1472 - update the customer response time for email inserted/updated
*/
public class SocialStreamingAPIUpdate{
    
    /*********************
    *
    * Method to update the case when a case comment is added
    *
    **********************/
    
    public static void CaseCommentUpdate(Set<Id> parentCaseIdSet){
    List<Case> caseUpdateList = new List<Case>();
        for(Case singleCase: [Select Id, Update_Reason__c, ReadUnreadCheck__c, OwnerId, CM_Last_Modified_Date__c, CM_Last_Modified_Section__c from Case where Id IN: parentCaseIdSet]){
            //Dont track changes made by Owner
            if(Userinfo.getUserId()!=null && singleCase.OwnerId!=null && !Userinfo.getUserId().equals(singleCase.OwnerId)){
                singleCase.ReadUnreadCheck__c = TRUE;
                singleCase.Update_Reason__c = 'Comment Added';
                Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                Social_StreamingUtil.processed.add(singleCase.Id);
                caseUpdateList.add(singleCase);
            }
            else if(Userinfo.getUserId()!=null && singleCase.OwnerId!=null && Userinfo.getUserId().equals(singleCase.OwnerId)){
                
                singleCase.CM_Last_Modified_Date__c = Datetime.now().addSeconds(-2);
                singleCase.CM_Last_Modified_Section__c = 'Case Comment';
                //singleCase.CM_Response_check__c = FALSE;                
                if(singleCase.ReadUnreadCheck__c){
                    singleCase.ReadUnreadCheck__c = FALSE;
                    Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                    Social_StreamingUtil.processed.add(singleCase.Id);
                }
                caseUpdateList.add(singleCase);                  
            }
        }
        
        if(caseUpdateList.size()>0){
            try{
                Social_CaseAssignmentUtility.executeTriggerCode = false;
                update caseUpdateList;
            }
            catch(DMLException e){
                system.debug('Error thrown while updating Case comment: '+e );
            }
        }
    }
    /*********************
    *
    * Method to update the case when a Case Social Post is added or Updated
    *
    **********************/
    public static void caseSocialPostInsertUpdate(Map<Id, String> caseMap){
        List<Case> caseUpdateList = new List<Case>();
        List<Case> caseCareManagerUpdateList = new List<Case>();
        if(caseMap!=null && !caseMap.isEmpty()){
            for(Case singleCase: [Select Id, Update_Reason__c, ReadUnreadCheck__c, OwnerId, CM_Last_Modified_Date__c, CM_Last_Modified_Section__c from Case where Id IN: caseMap.KeySet()]){
                //Dont track changes made by Owner
                if(Userinfo.getUserId()!=null && singleCase.OwnerId!=null && !Userinfo.getUserId().equals(singleCase.OwnerId)){
                    if(caseMap.get(singleCase.id)!=null && caseMap.get(singleCase.id).equalsIgnoreCase('Insert')){
                        singleCase.Update_Reason__c = 'New Social Post';
                        singleCase.ReadUnreadCheck__c = TRUE;
                    }
                    Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                    Social_StreamingUtil.processed.add(singleCase.Id);
                    caseUpdateList.add(singleCase);
                }
                else if(Userinfo.getUserId()!=null && singleCase.OwnerId!=null && Userinfo.getUserId().equals(singleCase.OwnerId)){
                    
                    singleCase.CM_Last_Modified_Date__c = Datetime.now().addSeconds(-2);                
                    singleCase.CM_Last_Modified_Section__c = 'Social Post';
                    //singleCase.CM_Response_check__c = FALSE;                    
                    if(singleCase.ReadUnreadCheck__c){
                        singleCase.ReadUnreadCheck__c = FALSE;
                        Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                        Social_StreamingUtil.processed.add(singleCase.Id);
                    }
                    caseCareManagerUpdateList.add(singleCase);                                    
                }
            }
            if(caseUpdateList.size()>0){
                try{
                    Social_CaseAssignmentUtility.executeTriggerCode = false;
                    if(String.ValueOf(System.label.Enable_Social_post_updates)!=null && String.ValueOf(System.label.Enable_Social_post_updates).equalsIgnoreCase('True')){
                        update caseUpdateList;
                    }
                }
                catch(DMLException e){
                    system.debug('Error thrown while updating Case in caseSocialPostInsertUpdate method: '+e );
                }
            }
            if(caseCareManagerUpdateList.size()>0){
                try{
                    //Social_CaseAssignmentUtility.executeTriggerCode = false;
                    if(String.ValueOf(System.label.Enable_Social_post_updates)!=null && String.ValueOf(System.label.Enable_Social_post_updates).equalsIgnoreCase('True')){
                        update caseCareManagerUpdateList;
                    }
                }
                catch(DMLException e){
                    system.debug('Error thrown while updating Case in caseSocialPostInsertUpdate method at 1: '+e );
                }
            }
        }
    }
    
    /*********************
    *
    * Method to update the case when a Case Task is added or Updated
    *
    **********************/
    public static void caseTaskInsertUpdate(Map<Id, String> caseMap){        
        List<Case> caseUpdateList = new List<Case>();
        if(caseMap!=null && !caseMap.isEmpty()){
            for(Case singleCase: [Select Id, Update_Reason__c, ReadUnreadCheck__c, OwnerId, CM_Last_Modified_Date__c, CM_Last_Modified_Section__c from Case where Id IN: caseMap.KeySet()]){
                //Dont track changes made by Owner
                if(Userinfo.getUserId()!=null && singleCase.OwnerId!=null && !Userinfo.getUserId().equals(singleCase.OwnerId)){
                    singleCase.ReadUnreadCheck__c = TRUE;
                    if(caseMap.get(singleCase.id)!=null && caseMap.get(singleCase.id).equalsIgnoreCase('Insert')){
                        singleCase.Update_Reason__c = 'New Task';
                    }
                    else if(caseMap.get(singleCase.id)!=null && caseMap.get(singleCase.id).equalsIgnoreCase('Update')){
                        singleCase.Update_Reason__c = 'Task Updated';
                    }
                    Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                    Social_StreamingUtil.processed.add(singleCase.Id);
                    caseUpdateList.add(singleCase);                    
                }
                else if(Userinfo.getUserId()!=null && singleCase.OwnerId!=null && Userinfo.getUserId().equals(singleCase.OwnerId)){                    
                    singleCase.CM_Last_Modified_Date__c = Datetime.now().addSeconds(-2);
                    //singleCase.CM_Response_check__c = FALSE;                    
                    singleCase.CM_Last_Modified_Section__c = 'Task';
                    if(singleCase.ReadUnreadCheck__c){
                        if(singleCase.Update_Reason__c!=null && (singleCase.Update_Reason__c).equalsIgnoreCase('Availability Assignment')){
                            singleCase.ReadUnreadCheck__c = true;
                        }
                        else{
                            singleCase.ReadUnreadCheck__c = false;
                        }
                        Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                        Social_StreamingUtil.processed.add(singleCase.Id);
                     }
                     caseUpdateList.add(singleCase);  
                     System.debug('Case List size: '+caseUpdateList.size()); 
                }
            }
            if(caseUpdateList.size()>0){
                try{
                    Social_CaseAssignmentUtility.executeTriggerCode = false;
                    if(String.ValueOf(System.label.Enable_Task_updates)!=null && String.ValueOf(System.label.Enable_Task_updates).equalsIgnoreCase('True')){
                        update caseUpdateList;
                    }
                }
                catch(DMLException e){
                    system.debug('Error thrown while updating Case in caseTaskInsertUpdate method: '+e );
                }
            }
        }
    }
   
    /*********************
    *
    * Method to update the case when a Case Event is added or Updated
    *
    **********************/
    public static void caseEventInsertUpdate(Map<Id, String> caseMap){
        List<Case> caseUpdateList = new List<Case>();
        if(caseMap!=null && !caseMap.isEmpty()){
            for(Case singleCase: [Select Id, Update_Reason__c, ReadUnreadCheck__c, OwnerId, CM_Last_Modified_Date__c, CM_Last_Modified_Section__c from Case where Id IN: caseMap.KeySet()]){
                //Dont track changes made by Owner
                if(Userinfo.getUserId()!=null && singleCase.OwnerId!=null && !Userinfo.getUserId().equals(singleCase.OwnerId)){
                    singleCase.ReadUnreadCheck__c = TRUE; 
                    if(caseMap.get(singleCase.id)!=null && caseMap.get(singleCase.id).equalsIgnoreCase('Insert')){
                        singleCase.Update_Reason__c = 'New Event';
                    }
                    else if(caseMap.get(singleCase.id)!=null && caseMap.get(singleCase.id).equalsIgnoreCase('Update')){
                        singleCase.Update_Reason__c = 'Event Updated';
                    }
                    Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                    Social_StreamingUtil.processed.add(singleCase.Id);
                    caseUpdateList.add(singleCase);
                }
                else if(Userinfo.getUserId()!=null && singleCase.OwnerId!=null && Userinfo.getUserId().equals(singleCase.OwnerId)){
                    singleCase.CM_Last_Modified_Date__c = Datetime.now().addSeconds(-2);
                    singleCase.CM_Last_Modified_Section__c = 'Event';
                    //singleCase.CM_Response_check__c = FALSE;
                    if(singleCase.ReadUnreadCheck__c){
                        if(singleCase.Update_Reason__c!=null && (singleCase.Update_Reason__c).equalsIgnoreCase('Availability Assignment')){
                            singleCase.ReadUnreadCheck__c = true;
                        }
                        else{
                            singleCase.ReadUnreadCheck__c = false;
                        }
                        
                        Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                        Social_StreamingUtil.processed.add(singleCase.Id);
                    }
                    if(!Social_StreamingUtil.skipTransaction.contains(singleCase.Id)){
                        caseUpdateList.add(singleCase);  
                    }
                }
            }
            if(caseUpdateList.size()>0){
                try{
                    Social_CaseAssignmentUtility.executeTriggerCode = false;
                    if(String.ValueOf(System.label.Enable_Event_updates)!=null && String.ValueOf(System.label.Enable_Event_updates).equalsIgnoreCase('True')){
                        update caseUpdateList;
                    }
                }
                catch(DMLException e){
                    system.debug('Error thrown while updating Case in caseEventInsertUpdate method: '+e );
                }
            }
        }
    }
    
    /*********************
    *
    * Method to update the case when a Email is receieved or Updated
    *
    **********************/
    public static void caseEmailInsertUpdate(Map<Id, String> caseMap,Map<Id,EmailMessage> caseEmailMap  ){
        List<Case> caseUpdateList = new List<Case>();
        Map<Id,String> ownerAvailabilityMap = new Map<Id,String>();        
        Set<String> BizInternalFromAddressSet = new Set<String>();
        BizInternalFromAddressSet.addAll(Label.BizInternalEmailFromAddress.split(';'));
        
        if(caseMap!=null && !caseMap.isEmpty()){        
            for(Case singleCase: [Select Id, Status,RecordTypeID, Track_Case_Queue__c,Case_PostTag__c, Update_Reason__c, Current_SLA_Phase__c,ReadUnreadCheck__c, ownerId,  CM_Last_Modified_Date__c, CM_Last_Modified_Section__c from Case where Id IN: caseMap.KeySet()]){                
                for(User singleUser: [Select Id, Availability__c from User where Id =: singleCase.ownerId]){
                    ownerAvailabilityMap.put(singleUser.Id, singleUser.Availability__c);
                }
           String fromaddress = caseEmailMap.get(singleCase.id).FromAddress;
           String trimmedFromAddress = fromaddress.subString(fromaddress.indexOf('@'), fromaddress.length());                
            
           if(Userinfo.getUserId()!=null && singleCase.OwnerId!=null && !Userinfo.getUserId().equals(singleCase.OwnerId)){                    
                    singleCase.ReadUnreadCheck__c = TRUE;
                    singleCase.Customer_Response_Received_Time__c = system.now();
                    singleCase.Posted_Date__c = system.now();
                                                         
                    // updated if loop to exclude overriding of New Case update
                    if(caseMap.get(singleCase.id)!=null && caseMap.get(singleCase.id).equalsIgnoreCase('Insert') && Social_StreamingUtil.doNotFireUpdateReason ){                                      
                        if( singleCase.RecordTypeID == SYSTEM.LABEL.Business_Closed_RT){
                            singleCase.Update_Reason__c = ''; 
                        } 
                         if( singleCase.RecordTypeID == System.Label.Business_Open_RT && BizInternalFromAddressSet.contains(trimmedFromAddress)){
                            singleCase.Update_Reason__c = Social_StreamingUtil.INTERNAL_EMAIL ;
                         }
                        else{
                             singleCase.Update_Reason__c = Social_StreamingUtil.CUSTOMER_REPLY; 
                             if(ownerAvailabilityMap.size()>0 && singleCase.RecordTypeID == System.Label.Business_Open_RT){
                                 if(ownerAvailabilityMap.get(singleCase.OwnerId).equalsIgnoreCase('Offline') ){
                                     if(singleCase.Case_PostTag__c != NULL && singleCase.Case_PostTag__c.containsIgnoreCase('GCS-SALESLEAD')){
                                         singleCase.OwnerId = SYSTEM.LABEL.SOCIAL_SALES_LEAD_QUEUE;
                                     }
                                     else{
                                          singleCase.OwnerId = SYSTEM.LABEL.GENERAL_BC_QUEUE;                                          
                                     }
                                 }
                             }                            
                        }                    
                    }
                    else if(caseMap.get(singleCase.id)!=null && caseMap.get(singleCase.id).equalsIgnoreCase('Update')){
                        singleCase.Update_Reason__c = 'Email Updated';
                    }
                    Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                    Social_StreamingUtil.processed.add(singleCase.Id);
                    caseUpdateList.add(singleCase);
                }
                else if(Userinfo.getUserId()!=null && singleCase.OwnerId!=null && Userinfo.getUserId().equals(singleCase.OwnerId)){
                    singleCase.CM_Last_Modified_Date__c = Datetime.now().addSeconds(-2);
                    singleCase.CM_Last_Modified_Section__c = 'Email';                    
                   // only added for Business : to change status to investigating from reopen; Email to Case
                       if( !Social_StreamingUtil.caseNotOpenBusinessStatus.contains(singleCase.Status) && (singleCase.RecordTypeID == System.Label.Business_Open_RT || singleCase.RecordTypeID == System.Label.Business_Closed_RT )){
                            singleCase.Status = 'Investigating' ;
                       }
                    //singleCase.CM_Response_check__c = FALSE;                   
                    if(singleCase.ReadUnreadCheck__c){                        
                        singleCase.ReadUnreadCheck__c = FALSE;                                             
                        Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                        Social_StreamingUtil.processed.add(singleCase.Id);
                     }
                     caseUpdateList.add(singleCase);  
                }
            }
            if(caseUpdateList.size()>0){
                try{
                    Social_CaseAssignmentUtility.executeTriggerCode = false;
                    update caseUpdateList;
                }
                catch(DMLException e){
                    system.debug('Error thrown while updating Case in caseEmailInsertUpdate method: '+e );
                }
            }
        }
    }

    /*********************
    *
    * Method to update the case when a Case Attachment is added or Updated
    *
    **********************/
    public static void caseAttachmentInsertUpdate(Map<Id, String> caseMap){
        List<Case> caseUpdateList = new List<Case>();
        if(caseMap!=null && !caseMap.isEmpty()){
            for(Case singleCase: [Select Id, Update_Reason__c, ReadUnreadCheck__c, ownerId, CM_Last_Modified_Date__c, CM_Last_Modified_Section__c from Case where Id IN: caseMap.KeySet()]){
                //Dont track changes made by Owner
                if(Userinfo.getUserId()!=null && singleCase.OwnerId!=null && !Userinfo.getUserId().equals(singleCase.OwnerId)){
                    singleCase.ReadUnreadCheck__c = TRUE;
                    if(caseMap.get(singleCase.id)!=null && caseMap.get(singleCase.id).equalsIgnoreCase('Insert')){
                        // Do not update the if the new attachment comes with an email or when the case owner adds an attachment
                        if(String.valueOf(userInfo.getUserId().subString(0,15)) != system.Label.Email_Case_UserId && userInfo.getUserId()!= caseMap.get(singleCase.ownerId) && String.valueOf(userInfo.getUserId().subString(0,15)) != system.Label.BCS_Email_Case_User_Id) {   
                            singleCase.Update_Reason__c = 'New Attachment';
                        }    
                    }
                    else if(caseMap.get(singleCase.id)!=null && caseMap.get(singleCase.id).equalsIgnoreCase('Update')){
                        if(String.valueOf(userInfo.getUserId().subString(0,15)) != system.Label.Email_Case_UserId && userInfo.getUserId()!= caseMap.get(singleCase.ownerId) && String.valueOf(userInfo.getUserId().subString(0,15)) != system.Label.BCS_Email_Case_User_Id) {   
                            singleCase.Update_Reason__c = 'Attachment Updated';   
                        }
                    }
                    Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                    Social_StreamingUtil.processed.add(singleCase.Id);
                    caseUpdateList.add(singleCase);
                }
                else if(Userinfo.getUserId()!=null && singleCase.OwnerId!=null && Userinfo.getUserId().equals(singleCase.OwnerId)){
                    singleCase.CM_Last_Modified_Date__c = Datetime.now().addSeconds(-2);
                    singleCase.CM_Last_Modified_Section__c = 'Attachment';
                    //singleCase.CM_Response_check__c = FALSE;
                    if(singleCase.ReadUnreadCheck__c){
                        singleCase.ReadUnreadCheck__c = FALSE;
                        Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                        Social_StreamingUtil.processed.add(singleCase.Id);
                    }
                    caseUpdateList.add(singleCase);                     
                }
            }
            if(caseUpdateList.size()>0){
                try{
                    Social_CaseAssignmentUtility.executeTriggerCode = false;
                    update caseUpdateList;
                }
                catch(DMLException e){
                    system.debug('Error thrown while updating Case in caseAttachmentInsertUpdate method: '+e );
                }
            }
        }
    }
    /*********************
    *
    * Method to update the case when a SocialPersona is Inserted or Updated
    *
    **********************/
    public static void caseSocialPersonaInsertUpdate(Map<Id, String> caseMap){
        List<Case> caseUpdateList = new List<Case>();
        if(caseMap!=null && !caseMap.isEmpty()){
            //for(Case singleCase: [Select Id, Update_Reason__c, ReadUnreadCheck__c, OwnerId from Case where Id IN: caseMap.KeySet()]){
            for(Case singleCase: [Select c.Id, c.Update_Reason__c, c.ReadUnreadCheck__c, c.OwnerId, c.Contact.Id, c.ContactId, c.CM_Last_Modified_Date__c, c.CM_Last_Modified_Section__c From Case c where c.contactId IN: caseMap.KeySet() and c.status <> 'Closed']){
                //Dont track changes made by Owner
                System.debug('SocialPersona updated here and values : Userinfo.getUserId() : '+Userinfo.getUserId()+'  singleCase.OwnerId : '+singleCase.OwnerId);

                if(Userinfo.getUserId()!=null && singleCase.OwnerId!=null && !Userinfo.getUserId().equals(singleCase.OwnerId)){
                    singleCase.ReadUnreadCheck__c = TRUE;
                    if(caseMap.get(singleCase.contactId)!=null && caseMap.get(singleCase.contactId).equalsIgnoreCase('Insert')){
                        singleCase.Update_Reason__c = 'New SocialPersona';
                    }
                    else if(caseMap.get(singleCase.contactId)!=null && caseMap.get(singleCase.contactId).equalsIgnoreCase('Update')){
                        singleCase.Update_Reason__c = 'SocialPersona Updated';
                    }
                    Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                    Social_StreamingUtil.processed.add(singleCase.Id);
                    caseUpdateList.add(singleCase);
                }
                else if(Userinfo.getUserId()!=null && singleCase.OwnerId!=null && Userinfo.getUserId().equals(singleCase.OwnerId)){
                    singleCase.CM_Last_Modified_Date__c = Datetime.now().addSeconds(-2);
                    singleCase.CM_Last_Modified_Section__c = 'Social Persona';
                    //singleCase.CM_Response_check__c = FALSE;
                    if(singleCase.ReadUnreadCheck__c){
                        singleCase.ReadUnreadCheck__c = FALSE;
                        Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                        Social_StreamingUtil.processed.add(singleCase.Id);
                    }
                    caseUpdateList.add(singleCase);  
                }
            }
            if(caseUpdateList.size()>0){
                try{
                    Social_CaseAssignmentUtility.executeTriggerCode = false;
                    update caseUpdateList;
                }
                catch(DMLException e){
                    system.debug('Error thrown while updating Case in caseSocialPersonaInsertUpdate method: '+e );
                }
            }
        }
    }
    private Map<Id, Id> getQueueIdfromCaseId(List<Id> caseIdList){
        
        return null;
    }
}