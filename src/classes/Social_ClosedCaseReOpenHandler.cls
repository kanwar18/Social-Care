/********************************************************************************************************
*    Author :     Arun Ramachandran
*    Requirement: To handle the scenario for re-opening a case when a customer sends an email within
*                 48 hours of closing the case
*    Version:     1.0
*    Created Date: 28th May 2013
*    Updated By:  Ashween Kaur
*    Requirement: To handle the scenario for re-opening a case when a customer sends an email within
*                 96 hours of closing the case
*    Version:     1.1
*    Updated Date: 3rd Jan 2014
*********************************************************************************************************/

public class Social_ClosedCaseReOpenHandler{

    /**
    * < reOpenClosedCase() - Method to re-open a case when an email is sent withing 48 hours of case closure>
    * @param:
    *     Set<Id> parentCaseId - Set of Parent case Id's to the Email message record created in Salesforce for a case.
    *       
    * @return - Void     
    * @see - Social_reopenClosedCases trigger 
    */
    
    public void reOpenClosedCase(Set<Id> parentCaseId){
        
    List<Case> caseReOpenList = new List<Case>(); // List of cases to be re-opened
    List<Case> slaInitiateList = new List<Case>();
    Map<Id, List<Case>> countDecCaseUserMap = New Map<Id, List<Case>>();
    Map<Id, List<Case>> countIncCaseUserMap = New Map<Id, List<Case>>();
    Map<Id, List<Case>> countCloseCaseUserMap= New Map<Id, List<Case>>();
    Decimal diff;
    
    decimal hours; // To calculate the number of days from closure and receipt of email 
    List<Case> slaInitiateCaseList = new List<Case>();
    Set<Id> caseOwnerIdSet = new Set<Id>();
    Set<Id> ownerIdSet = new Set<Id>();
    Map<Id,String> ownerAvailabilityMap = new Map<Id,String>();
    Datetime slaScheduledTime = datetime.now();
    Integer slaTimeframe = 60;
    
    // To query the details of the parent case retrieved in the above parentCaseId Set
    if(parentCaseId.size()>0){
       for(Case singleCase: [Select Id, Status,Case_PostTag__c, readunreadcheck__c,Track_Case_Queue__c, Second_SLA_Start_Time__c ,Second_SLA_Scheduled_Time__c, Update_Reason__c, CaseNumber, OwnerId, Current_SLA_Phase__c, ClosedDate, RecordTypeId from Case where Id IN: parentCaseId AND (RecordTypeId =: System.Label.Business_Closed_RT OR RecordTypeId =: System.Label.Business_Case_Audit_Record_Type_ID )]){           
           caseReOpenList.add(singleCase);
           ownerIdSet.add(singleCase.OwnerId);
       }
       
       if(ownerIdSet.size() > 0){
           for(User singleUser: [Select Id, Availability__c from User where Id IN: ownerIdSet]){
               ownerAvailabilityMap.put(singleUser.Id, singleUser.Availability__c);
           }
       }       
       //caseReOpenList = [Select Id, OwnerId, Status, readunreadcheck__c,Track_Case_Queue__c, Second_SLA_Start_Time__c ,Second_SLA_Scheduled_Time__c, Update_Reason__c, CaseNumber, OwnerId, Current_SLA_Phase__c, ClosedDate, RecordTypeId from Case where Id IN: parentCaseId AND RecordTypeId =: bsCloseCaseRecordTypeId]; 
    } 
    
    //Calculate the number of days from closure and re-open if the number of days is less than 96.0
    if(caseReOpenList.size()>0){
        for(Case singleCase: caseReOpenList){
            if(singleCase.Status == 'Closed' && (singleCase.RecordTypeId == System.Label.Business_Closed_RT || singleCase.RecordTypeId == System.Label.Business_Case_Audit_Record_Type_ID)){ 
                    diff= 0.0;
                    hours = 0.0;       
                    diff = decimal.valueof((System.Now().getTime() - singleCase.ClosedDate.getTime())/(60*60));
                    hours =(diff /1000);                    
                   // ashween changed hours from 2.0 to 96.0               
                    if((hours <= Double.ValueOf(SYSTEM.LABEL.Business_Email_Reopen) || Test.isRunningTest())){
                        singleCase.Status = 'Reopen';
                        if(ownerAvailabilityMap.containsKey(singleCase.OwnerId) && (ownerAvailabilityMap.get(singleCase.OwnerId).equalsIgnoreCase('Offline') || ownerAvailabilityMap.get(singleCase.OwnerId).equalsIgnoreCase('Vacation'))){
                            singleCase.OwnerId = SYSTEM.LABEL.GENERAL_BC_QUEUE;
                        }
                        else{
                            if(countDecCaseUserMap.containsKey(singleCase.OwnerId)){
                                countDecCaseUserMap.get(singleCase.OwnerId).add(singleCase);
                            }
                            else{
                                countDecCaseUserMap.put(singleCase.OwnerId,New List<Case>{singleCase});
                            }
                            singleCase.readunreadcheck__c = TRUE;
                            singleCase.Update_Reason__c = 'Case Re-Opened'; 
                            singleCase.Auto_Close_Indicator__c = FALSE; // ADDED for ABS release 7 requirement auto case closure                       
                            if(singleCase.Current_SLA_Phase__c == 'SLA1 - Ended'){
                                singleCase.Current_SLA_Phase__c = 'SLA2 - Initiated';
                                singleCase.Second_SLA_Start_Time__c = System.now();
                                singleCase.Second_SLA_Scheduled_Time__c = slaScheduledTime.addMinutes(slaTimeframe);
                                Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                                Social_StreamingUtil.processed.add(singleCase.Id); 
                                slaInitiateList.add(singleCase); 
                            }
                        }                                          
                    }
              }  
        }   
               
    }
    if(caseReOpenList.size()>0){
            try{
                update caseReOpenList;
            }
            Catch(DMLException e){
                system.debug('Error thrown while updating Case Status : '+e);
            }
    }    
    
    for(Case singleCase: slaInitiateList){
        if(singleCase.Current_SLA_Phase__c == 'SLA2 - Initiated'){
            slaInitiateCaseList.add(singleCase);
            caseOwnerIdSet.add(singleCase.OwnerId);
           }
       }
    if(slaInitiateCaseList.size()>0){
        reOpenCaseSLAInitiation(slaInitiateCaseList,caseOwnerIdSet);        
    }
    
    if(countDecCaseUserMap.size()>0){
        Social_BusinessRoundRobin.countUserCaseUpdate(countIncCaseUserMap ,countDecCaseUserMap,countCloseCaseUserMap);
    }
    
    }
    
    /**
    * < reOpenCaseSLAInitiation() - Method to create Event/SLA for the case owner and the manager
    *     List<Case> slaInitiateCaseList - List of cases for which SLA/Events needs to be created
    *     Set<Id> caseOwnerIdSet - Id of Case Owners for whome SLA/Events needs to be created
    * @return - Void     
    * @see - Social_ClosedCaseReOpenHandler (same class) 
    */
    
    public void reOpenCaseSLAInitiation(List<Case> slaInitiateCaseList,Set<Id> caseOwnerIdSet){
      
    Map<Id,User> caseOwnerManagerMap = new Map<Id,User>(); //    
    List<Event> eventSLAList = new List<Event>();
    List<Task> taskSLAList = new List<Task>(); 
    
    String eventDescription = 'Second SLA Response Reminder';
    Integer timePeriod = 60;
    Integer reminderTime = 45;
    String eventType = 'SLA - 2';
    Datetime assignmentTime = datetime.now();
    
        if(caseOwnerIdSet.size()>0){
           for(User singleUser:[Select Id, Name, ManagerId from User where Id IN: caseOwnerIdSet]){
                caseOwnerManagerMap.put(singleUser.Id, singleUser);                
            }
        }        
            
        for(Case caseSLAsingle: slaInitiateCaseList){
             Event careEvent = new Event();
              careEvent.WhatId = caseSLAsingle.Id;
              careEvent.Event_Type__c = eventType;
              careEvent.Event_Status__c = 'Open';
              careEvent.Description = eventDescription;
              careEvent.OwnerId = caseSLAsingle.OwnerId;
              careEvent.StartDateTime = assignmentTime;
              careEvent.DurationInMinutes = timePeriod;
              careEvent.IsReminderSet = true;
              careEvent.ReminderDateTime = assignmentTime.addMinutes(reminderTime);
              careEvent.Subject = eventType + ':' + caseOwnerManagerMap.get(caseSLAsingle.OwnerId).Name + ':' + caseSLAsingle.CaseNumber;
              eventSLAList.add(careEvent);
              
              // Operation Manager Event
             Event operationEvent = new Event();
              operationEvent.WhatId = caseSLAsingle.Id;
              operationEvent.Event_Type__c = eventType;
              operationEvent.Event_Status__c = 'Open';
              operationEvent.Description = eventDescription;
              operationEvent.OwnerId = caseOwnerManagerMap.get(caseSLAsingle.OwnerId).ManagerId;
              operationEvent.StartDateTime = assignmentTime;
              operationEvent.DurationInMinutes = timePeriod;
              operationEvent.IsReminderSet = true;
              operationEvent.ReminderDateTime = assignmentTime.addMinutes(reminderTime);
              operationEvent.Subject = eventType + ':' + caseOwnerManagerMap.get(caseSLAsingle.OwnerId).Name + ':' + caseSLAsingle.CaseNumber;
              eventSLAList.add(operationEvent);              
              
             /*Task slaTask = new Task();
              slaTask.WhatId = caseSLAsingle.Id; 
              slaTask.OwnerId = caseSLAsingle.OwnerId;
              slaTask.Subject = 'SLA-2 Customer Response Task';
              slaTask.Description = 'SLA-2 Social Post Customer Response';
              slaTask.Event_Type__c = 'SLA - 2';
              slaTask.Status = 'Completed';
              slaTask.Priority = 'Normal';
              slaTask.Ignore_Case_Activity__c = TRUE;
              slaTask.ActivityDate = System.now().date();
              taskSLAList.add(slaTask);*/
        }
              if(eventSLAList.size()>0){
            try{
                insert eventSLAList;
            }
            catch(DMLException e){
                system.debug('Error thrown while creating SECOND SLA: '+e);
            }
        }   
        /*if(taskSLAList.size()>0){
            try{
                insert taskSLAList;
            }
            catch(DMLException et){
                system.debug('Error thrown while creating SECOND SLA TASK: '+et);
            }
        }  */     
    }
    /**
    * < copySocialPostDetails() - Method to copy Post tag details and to update Recordtype of case if needed to Business
    *     Map<Id,List<SocialPost>> socialPostMap - Map to hold list of Social Posts against its corresponding Parent Case Id
    * @return - Void     
    * @see - Social_SocialPostTaskCreator (trigger) 
    */
    
    public static void copySocialPostDetails(Map<Id,List<SocialPost>> socialPostMap){
    Map<Id, Case> caseMap = new Map<Id, Case>(); // Map of Case with full details.
    Id caseRecordTypeId; // Variable to store the Business Case Record Type Id or NULL.
    List<Case> caseUpdateList = new List<Case>(); // List of Cases to update the Case Post Tag, Initial Post Id and Case Record Type Id.
       
        
        for(Case singleCase : [Select Id,Business_Case_Post_Tag__c, Case_PostTag__c,Is_Business_Assigned__c, Skip_Assignment_Rule__c, R6Service__InitialPostId__c, RecordTypeId from Case where Id IN:socialPostMap.keySet()]){
            caseMap.put(singleCase.Id,singleCase);
        }
        
        for(String str: socialPostMap.keySet()){
            if(caseMap.containsKey(str)){
                for(SocialPost singlePost : socialPostMap.get(str)){
                // When a Case is not attached to any Social Post Records.
                    if(caseMap.get(str).R6Service__InitialPostId__c == NULL){
                        caseMap.get(str).R6Service__InitialPostId__c = singlePost.Id; // To update the Initial Post Id field on the case
                        caseMap.get(str).Case_PostTag__c = singlePost.R6Service__PostTags__c; // To update the Case Post Tag on a particular case.
                        if(caseMap.get(str).Case_PostTag__c!=null && caseMap.get(str).Case_PostTag__c.contains(',')){ // If the Field has more that 1 post tag
                            caseMap.get(str).Business_Case_Post_Tag__c = caseMap.get(str).Case_PostTag__c.replaceAll(',',';'); // Updating the Business Multi select Post Tag field
                        }
                        else{
                            caseMap.get(str).Business_Case_Post_Tag__c = caseMap.get(str).Case_PostTag__c;                        
                        }
                        //caseMap.get(str).Is_Business_Assigned__c = TRUE;
                        // To update the Case Record Type Id by verifying the Post Tag
                        caseRecordTypeId = Social_StreamingUtil.getRecordTypeId(caseMap.get(str).Case_PostTag__c);
                        if(caseRecordTypeId!=NULL){
                            caseMap.get(str).RecordTypeId = caseRecordTypeId;
                            //caseMap.get(str).Skip_Assignment_Rule__c = TRUE;
                            //Adding Debug statement
                            String strTemp = 'Here at one raja caseMap.get(str).Skip_Assignment_Rule__c : '+caseMap.get(str).Skip_Assignment_Rule__c;
                            caseMap.get(str).log__c = caseMap.get(str).log__c + strTemp;
                            Social_CaseUpdateStreamCtrl.caseId.add(caseMap.get(str).Id);
                            Social_StreamingUtil.processed.add(caseMap.get(str).Id);
                            
                        }
                        
                        caseUpdateList.add(caseMap.get(str));
                        break;
                    }
                    // When a Case IS attached to any Social Post Records.
                    else if(caseMap.get(str).R6Service__InitialPostId__c != NULL){
                        if(caseMap.get(str).R6Service__InitialPostId__c == singlePost.Id && caseMap.get(str).Case_PostTag__c == NULL){
                            caseMap.get(str).Case_PostTag__c = singlePost.R6Service__PostTags__c; // To update the Case Post Tag on a particular case.
                            if(caseMap.get(str).Case_PostTag__c!=null && caseMap.get(str).Case_PostTag__c.contains(',')){ // If the Field has more that 1 post tag
                                caseMap.get(str).Business_Case_Post_Tag__c = caseMap.get(str).Case_PostTag__c.replaceAll(',',';'); // Updating the Business Multi select Post Tag field
                            }
                            else{
                                caseMap.get(str).Business_Case_Post_Tag__c = caseMap.get(str).Case_PostTag__c;                        
                            }
                            
                            // To update the Case Record Type Id by verifying the Post Tag
                            caseRecordTypeId = Social_StreamingUtil.getRecordTypeId(caseMap.get(str).Case_PostTag__c);
                            if(caseRecordTypeId!=NULL){
                                caseMap.get(str).RecordTypeId = caseRecordTypeId;
                                //caseMap.get(str).Skip_Assignment_Rule__c = TRUE;
                                
                                //Adding Debug statement
                            String strTemp = 'Here at two raja caseMap.get(str).Skip_Assignment_Rule__c : '+caseMap.get(str).Skip_Assignment_Rule__c;
                            caseMap.get(str).log__c = caseMap.get(str).log__c + strTemp;
                                Social_CaseUpdateStreamCtrl.caseId.add(caseMap.get(str).Id);
                                Social_StreamingUtil.processed.add(caseMap.get(str).Id);
                            }
                            
                            caseUpdateList.add(caseMap.get(str));
                            break;
                        }
                    }
                    
                }
            }
                        
        }
        
        if(caseUpdateList.size()>0){
            try{
                update caseUpdateList;
            }
            catch(DMLException e){
                system.debug('Error thrown while updating Case Post Tag and RecordType: e');
            }
        }
        
    }   
    
    /**
    * < createUpdateBusinessContact() - Method to create/update Contact to case for Email to case Business
    *   
    * @return - Void     
    */
    
    public static void createUpdateBusinessContact(Set<Id> parentCaseId){
    
        Id bsCaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Case');
        List<Contact> contactList = new List<Contact>();
        Map<String,List<Case>> contactCaseMap = new Map<String,List<Case>>();
        Map<String,Id> contactEmailMap = new Map<String,Id>();
        Map<String,Contact> contactCaseEmailMap = new Map<String,Contact>();  
        List<Case> updateCaseList = new List<Case>();
        List<Contact> newContactList = new List<Contact>();
     
        for(Case singleCase : [Select Id, ContactId, Contact.LastName, Contact.Email, SuppliedEmail FROM Case WHERE Id IN: parentCaseId AND RecordTypeId =: bsCaseRecordTypeId]){
            if(singleCase.contactId == NULL){
                if(contactCaseMap.containsKey(String.valueOf(singleCase.SuppliedEmail))){
                    contactCaseMap.get(String.valueOf(singleCase.SuppliedEmail)).add(singleCase);
                }
                else{
                    contactCaseMap.put(String.valueOf(singleCase.SuppliedEmail),new List<Case>{singleCase});
                }                
            }
            if(singleCase.contactId != NULL){
                contactEmailMap.put(singleCase.Contact.Email,singleCase.ContactId);
            }
        }
              
        for(String str: contactCaseMap.keySet()){
            if(contactEmailMap.containsKey(str)){
                for(Case singleCase: contactCaseMap.get(str)){
                    singleCase.ContactId = contactEmailMap.get(str); 
                    updateCaseList.add(singleCase);  
                }
            }                       
        }
                
        for(String str: contactCaseMap.keySet()){
            if(!contactEmailMap.containskey(str)){
                Contact newContact = new Contact();
                newContact.LastName = 'EmailToCaseABS';
                newContact.Email = str;
                newContactList.add(newContact);
            }
        }
        
               
        if(newContactList.size()>0){
            try{
                insert newContactList;
            }
            catch(DMLException e){
                system.debug('Exception thrown while inserting Contacts :'+e);
            }
        }
        
        for(Contact singleContact: newContactList){
            contactCaseEmailMap.put(String.valueOf(singleContact.Email),singleContact);
        }
        
              
        for(String str: contactCaseMap.keySet()){
            if(contactCaseEmailMap.containsKey(str)){
                for(Case singleCase: contactCaseMap.get(str)){
                    singleCase.ContactId = contactCaseEmailMap.get(str).Id; 
                    updateCaseList.add(singleCase);  
                }
            }                       
        }
        
                
        if(updateCaseList.size()>0){
            try{
                update updateCaseList;
            }
            catch(DMLException t){
                system.debug('Error thrown while Updating Case Contact Id : '+t);
            }
        }            
    }    
    
    public static void updateOperationsManager(Map<Id,List<Case>> operationsUpdateMap){
        Map<Id,Id> managerSet = new Map<Id,Id>();
        Set<Id> caseIdSet = new Set<Id>();
        List<Event> eventList = new List<Event>();
        for(User singleUser: [Select Id, ManagerId from User where Id IN: operationsUpdateMap.keySet()]){
            managerSet.put(singleUser.Id, singleUser.ManagerId);
        }
        
        for(Id str: operationsUpdateMap.keySet()){
            for(Case singleCase: operationsUpdateMap.get(str)){  
                if(managerSet.containsKey(singleCase.OwnerId)){  
                    singleCase.Closed_Operation_Manager__c = managerSet.get(singleCase.OwnerId);
                    if(singleCase.Current_SLA_Phase__c == 'SLA1 - Initiated'){
                        singleCase.Current_SLA_Phase__c = 'SLA1 - Ended';
                        singleCase.First_SLA_Response_Time__c = singleCase.First_SLA_Response_Time__c != null ? singleCase.First_SLA_Response_Time__c : System.now();
                    }
                    if(singleCase.Current_SLA_Phase__c == 'SLA2 - Initiated'){
                        singleCase.Current_SLA_Phase__c = 'SLA2 - Ended';
                        singleCase.Second_SLA_Response_Time__c = singleCase.Second_SLA_Response_Time__c != null ? singleCase.Second_SLA_Response_Time__c : System.now();
                    }
                    if(singleCase.Current_SLA_Phase__c == 'SLA3 - Initiated'){
                        singleCase.Current_SLA_Phase__c = 'SLA3 - Ended';
                        singleCase.Third_SLA_Response_Time__c = singleCase.Third_SLA_Response_Time__c != null ? singleCase.Third_SLA_Response_Time__c : System.now();
                    }  
                    caseIdSet.add(singleCase.Id);                                      
                }
            }
        }
        
        if(caseIdSet.size()>0){
            for(Event singleEvent: [Select Id, Event_Status__c from Event where WhatId IN: caseIdSet AND Event_Status__c = 'Open']){
                singleEvent.Event_Status__c = 'Closed';
                eventList.add(singleEvent);
            }
        }
        
        if(eventList.size()>0){
            try{
                update eventList;
               }
            catch(DMLException e){
                system.debug('Error thrown while closing SLAs' + e);
            }
        }
    }
    
    /**
    * < updateContactAccount() - Method to update AccountId on associated Contact for a Case>
    * @param:
    *     Set<Id> contactIdSet - Set of contact Id's to the Business case in Salesforce.
    *       
    * @return - Void     
    * @see - BizReopenCaseReassignment trigger 
    */
    
    public static void updateContactAccount(Set<Id> contactIdSet){
        List<Contact> updateContactList = new List<Contact>(); // List of Business Contacts to be updated
        
        for(Contact singleContact: [Select Id, AccountId from Contact where Id IN: contactIdSet]){
            if(singleContact.AccountId == NULL){
                singleContact.AccountId = SYSTEM.LABEL.DEFAULT_ABS_ACCOUNT;
                updateContactList.add(singleContact);
                Social_StreamingUtil.contactProcessed.add(singleContact.Id);
            }
        }
        
        if(updateContactList.size()>0){
            try{
                update updateContactList;
            }
            catch(DMLException e){
                system.debug('Error while updating Account Details on Business Contact: '+e);
            }
        }
    }
    
    /**
    * < checkSecondSLA() - Method to verify and launch second SLA>
    * @param:
    *     Map<Id,EmailMessage> caseEmailMap - Map of Case Id key and Email Message Value.
    *       
    * @return - Void     
    * @see - Social_reopenClosedCases trigger on EmailMessage Object
    */
    public static void checkSecondSLA(Map<Id,EmailMessage> caseEmailMap){
        Id businessCaseOpenRT = System.Label.BUSINESS_OPEN_RT;
        List<Case> caseList = new List<Case>();
        Datetime slaScheduledTime = datetime.now();
        Integer secondSLATimeframe = 60;
        Set<Id> caseOwnerIdSet = new Set<Id>();
        List<Case> slaInitiateCaseList = new List<Case>();
        
        for(Case singleCase: [Select Id,CaseNumber ,OwnerId,Current_SLA_phase__c,Second_SLA_Scheduled_Time__c,Contact.Email,Second_SLA_Start_Time__c from Case where Id IN: caseEmailMap.keySet() AND RecordTypeId =: businessCaseOpenRT]){
            caseList.add(singleCase);
        }
        
        for(Case singleCase: caseList){
            if(caseEmailMap.containsKey(singleCase.Id) && singleCase.Current_SLA_phase__c == 'SLA1 - Ended'){            
                if(singleCase.Contact.Email == caseEmailMap.get(singleCase.Id).FromAddress && (singleCase.OwnerId != SYSTEM.LABEL.GENERAL_BC_QUEUE  && singleCase.OwnerId != SYSTEM.LABEL.SOCIAL_SALES_LEAD_QUEUE)){
                    singleCase.Current_SLA_phase__c = 'SLA2 - Initiated';
                    singleCase.Second_SLA_Start_Time__c = System.Now();
                    singleCase.Second_SLA_Scheduled_Time__c = slaScheduledTime.addMinutes(secondSLATimeframe);
                    caseOwnerIdSet.add(singleCase.OwnerId);
                    slaInitiateCaseList.add(singleCase);
                }
            }
        }
        
        if(slaInitiateCaseList.size()>0){
            try{
                update slaInitiateCaseList;
            }
            catch(DMLException e){
                system.debug('Exception thrown while verifying Second SLA Launch: '+e);
            }            
            Social_BusinessRoundRobin.reassignCaseSLAInitiation(slaInitiateCaseList,caseOwnerIdSet);
        }
        
    }
}