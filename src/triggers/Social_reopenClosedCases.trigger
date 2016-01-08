/***********************************************************************************
* Author: Arun Ramachandran
* Requirement: To open closed cases when customer responds via email withing 48
*              hours of case closure.
* Version : 1.0
*           Aditya 1.1 - Added validation error before deleting email messages
*
************************************************************************************/

trigger Social_reopenClosedCases on EmailMessage (after Insert, before delete){
    
    Set<Id> parentCaseId = new Set<Id>(); // Set to store the parent cases of the emails.
    Social_ClosedCaseReOpenHandler caseManage = new Social_ClosedCaseReOpenHandler();
    Map<Id, User> userAvailabilityMap = new Map<Id, User>();  
    Map<Id,EmailMessage> caseEmailMap = new Map<Id,EmailMessage>();  
    if (trigger.isDelete && !userInfo.getProfileId().startsWith(Label.SystemAdminProfileId)) {
        for (EmailMessage emailMsgObj : trigger.Old) {
            emailMsgObj.addError('Case Email History Cannot Be Deleted.');
        }
    } 
    if (trigger.isInsert && trigger.isAfter) {
        //To store the parent case Id of the incoming email attachment   
        for(EmailMessage caseMail: Trigger.new){
            if(caseMail.Incoming == TRUE){
                parentCaseId.add(caseMail.ParentId); 
                caseEmailMap.put(caseMail.ParentId,caseMail);                       
            }
        }  
    }
    
    if(parentCaseId.size()>0){
        for(User singleUser: [Select Id, Availability__c from User where Id IN: parentCaseId]){
            userAvailabilityMap.put(singleUser.Id, singleUser);
        }
        caseManage.reOpenClosedCase(parentCaseId);
        Social_ClosedCaseReOpenHandler.createUpdateBusinessContact(parentCaseId);
        
    }
    if(caseEmailMap.size()>0){
        Social_ClosedCaseReOpenHandler.checkSecondSLA(caseEmailMap);
    } 
    
    
}