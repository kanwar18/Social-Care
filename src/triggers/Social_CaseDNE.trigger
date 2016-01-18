/**************************************************************************
Trigger Name:  Social_CaseDNE
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: Trigger will update the contact related to the case which is being inserted or updated.
Version History: Aditya(14/March/2014) - Release 19March2014
                 Aditya(20/Nov/2014) - Updated the trigger to run for all consumer record types
                 Aditya(18/March/2015) Added error message logic, if case owner is pending closure queue the dont allow
                                       anyone to update the case.
                 Aditya(19th August Release) - Update case closed time on contact
**************************************************************************************************************************/
trigger Social_CaseDNE on Case (after insert,before update) {
     Map<Id,Case> caseContMap = new map<Id,Case>();
     Map<Id,Case> contactUpdateMap = new Map<Id,Case>();
     List<Case> caseList = new List<Case>();
     List<Case> AutoCloseCaseList = new List<Case>();
     Set<Id> contactIdSet = new Set<Id>();
     List<Id> contactIdList = new List<Id>();
     Set<String> recordTypeIdSet1 = new Set<String>();
     recordTypeIdSet1.addAll(Label.Consumer_RT.split(','));
     Set<String> profileTypeIdSet = new Set<String>();
     profileTypeIdSet.addAll(Label.Customer_Account.split(','));
     Map<Id,Case> caseContactIdMap = new Map<Id,Case>();
     List<Case> caseListCAD = new List<Case>();
    //Added check if the logged in user is radian6 user then dont fire the trigger
    if (userInfo.getUserId() != '005E0000002G4RU' && Social_CaseAssignmentUtility.executeTriggerCode && (Boolean.valueOf(Label.DNE_Functionality))) {
        boolean isScrubTeamUser = social_DNEHandler.checkScrubTeamMember(userInfo.getUserId());
        Set<String> recordTypeIdSet = new Set<String>(); //to store consumer record type.
        Set<String> profileIdAccessIdSet = new Set<String>(); //to store profile id who can update case in Pending closure Queue.
        recordTypeIdSet.addAll(Label.Consumer_RT.split(','));
        Set<String> businessRTList = new Set<String>();
        businessRTList.addAll(System.Label.All_Business_RT.split(','));
            //Loop for insert.
            if(trigger.isInsert && trigger.isAfter) {
                for(Case caseObj : trigger.new) {
                    Social_StreamingUtil.preventStatusUpdateWhenDNETriggerFires = false;//adding flag for disabling status change on update of DNE value on case.
                    //if case has a DNE during insert then update DNE value on contact.
                    // else if there is no DNC on case then check DNE value on contact and update same value on case.
                    if(caseObj.contactId != null && caseObj.DNE__c != Null && recordTypeIdSet.contains(caseObj.recordTypeId)) {
                        caseContMap.put(caseObj.contactId,caseObj);//adding contactId and case object
                    } else if (caseObj.contactId != null && caseObj.DNE__c == Null && recordTypeIdSet.contains(caseObj.recordTypeId)) {
                        contactUpdateMap.put(caseObj.contactId,caseObj);//adding contactId and case object
                    }    
                }
            }
            //Loop for update            
            if(trigger.isUpdate && trigger.isBefore) {
                for(Case caseObj : trigger.New) {                    
                    if(!Social_StreamingUtil.dneCaseIds.contains(caseObj.Id)){
                        if(caseObj.DNE__c != trigger.OldMap.get(caseObj.Id).DNE__c && caseObj.contactId != Null && recordTypeIdSet.contains(caseObj.recordTypeId)) {
                            caseContMap.put(caseObj.contactId,caseObj);//adding contactId and case object
                            Social_StreamingUtil.caseIdFromTrigger.add(caseObj.Id);
                            Social_StreamingUtil.preventStatusUpdateWhenDNETriggerFires = false;//adding flag for disabling status change on update of DNE value on case.
                        } 
                    }
                    profileIdAccessIdSet.addAll(System.label.EditAccessToPendingClosure.split(','));
                    if (!profileIdAccessIdSet.contains(userInfo.getProfileId()) && !isScrubTeamUser &&
                       (System.Label.PendingClouseQueueId.contains(caseObj.OwnerId) || 
                        System.Label.PendingClouseQueueId.contains(trigger.oldMap.get(caseObj.Id).OwnerId)) && 
                        !userInfo.getUserId().contains('005E0000002GS0N') && !Social_CaseUpdateStreamCtrl.caseId.contains(caseObj.Id) && 
                        !Social_StreamingUtil.dneCaseIds.contains(caseObj.Id) && caseObj.is_Auto_Closed__c == false ) {
                        caseList.add(caseObj);
                    }
                    //Logic to populate the Status, Media Source, Primary component and Primary Sub component while Auto Case Closure if fields are blank and to update the owner back to the Original Queue
                    if((caseObj.is_Auto_Closed__c == true && trigger.OldMap.get(caseObj.Id).is_Auto_Closed__c == false) && (!(businessRTList.contains(caseObj.RecordTypeId)))) {
                        AutoCloseCaseList.add(caseObj);
                        if (caseObj.contactId != Null) {
                            contactIdSet.add(caseObj.contactId);
                        }                
                    }                                        
                }
            }  
        }    
        if(trigger.isUpdate && trigger.isBefore) {       
            for(Case caseObj : trigger.New){
                if(caseObj.Status != trigger.OldMap.get(caseObj.Id).Status && caseObj.contactId != Null && recordTypeIdSet1.contains(caseObj.recordTypeId) && !profileTypeIdSet.isEmpty() && profileTypeIdSet.Contains(userInfo.getProfileId()) && caseObj.Status=='Closed' && (caseObj.Reason=='Completed' || caseObj.Case_Reason_HSRep__c=='Resolved')) {
                    caseContactIdMap.put(caseObj.ContactId,caseObj);
                    caseListCAD.add(caseObj);
                 }         
            }                         
        }          
             
        //Method to update contact if DNE is not null during case update or insert.
        if(!caseContMap.isEmpty()) {
            social_DNEHandler.updateDNEDetailsOnContact(caseContMap);
        }
        //Method to update case if DNE is null during case insert and contact has DNE.
        if (!contactUpdateMap.isEmpty()) {
            social_DNEHandler.updateDNEDetailsOnCase(contactUpdateMap);
        }
        //Method to display error message
        if (!caseList.isEmpty()) {
            Social_SocialPostSCSHandler.doNotAllowUpdatesOnCase(caseList);
        }
        if(!AutoCloseCaseList.isEmpty()){
            social_DNEHandler.updateClosedCaseEmptyFields(AutoCloseCaseList,contactIdSet);
        }
        //Method to display error message
        if (!caseContactIdMap.KeySet().isEmpty()) {
            social_DNEHandler.customerAcctDetails(caseContactIdMap,caseListCAD);
        }
}