/**************************************************************************
Class Name: social_caseCounterUpdate
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: class will update Case Counter on user when case owner is changed.
Version History: Aditya(24/April/2014) - Release 19March2014
**************************************************************************************************************************/
Public class social_caseCounterUserUpdate {
    Public Static void updateCaseCounterUser(Set<Id> userIdSet) {
        //Map key as owner id and value as cases assigned to eacj owner id.
        Map<Id,List<Id>> noOfcaseAssignedToUserMap = new Map<Id,List<Id>>();
        List<User> userToUpdate = new List<User>();//
        Set<String> recordTypeIdSet = new Set<String>(); //to store consumer record type.
        recordTypeIdSet.addAll(Label.Consumer_RT.split(','));
        for(Case caseObj : [select Id,ownerId,recordTypeId from case where ownerId IN: userIdSet AND (status =: social_caseCounterUserUpdateConstants.STATUS_NEW OR status =: social_caseCounterUserUpdateConstants.STATUS_REOPEN OR status =: social_caseCounterUserUpdateConstants.STATUS_INVESTIGATING OR status =: social_caseCounterUserUpdateConstants.STATUS_REASSIGNED OR status =: social_caseCounterUserUpdateConstants.STATUS_ESCALATED) limit 50000]) {
            //If the map conatins case owner id then add case,
            // else add case owner id as a key.
            if (recordTypeIdSet.contains(caseObj.recordTypeId)) {
                if(noOfcaseAssignedToUserMap.containsKey(caseObj.ownerId)) {
                    noOfcaseAssignedToUserMap.get(caseObj.ownerId).add(caseObj.Id);    
                } else {
                    noOfcaseAssignedToUserMap.put(caseObj.ownerId,new List<Id>{caseObj.Id});
                } 
            }
        }
        
        //Query on user
        if(!userIdSet.isEmpty()) {
            for(User userObj : [select id,Case_Counter__c from user where Id IN:userIdSet limit 50000]) {
                if(noOfcaseAssignedToUserMap.containsKey(userObj.Id)) {
                    userObj.Case_Counter__c = noOfcaseAssignedToUserMap.get(userObj.Id).size();
                    userToUpdate.add(userObj);
                } else {
                    userObj.Case_Counter__c = 0;
                    userToUpdate.add(userObj);
                }
            }
        } 
        //Database Call out
        if (!userToUpdate.isEmpty()) {
            Social_StreamingUtil.updateSObject(userToUpdate,'Failed to update case counter on user, class social_caseCounterUpdate.');
        }
    }
}