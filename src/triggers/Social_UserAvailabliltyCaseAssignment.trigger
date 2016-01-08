/**
Trigger to Enable Immediate case assignemnt for Consumer Social Care Care Managers
Date Created: 01/25/2014
Release planned: 11/02
Author: Revantha C

**/
trigger Social_UserAvailabliltyCaseAssignment on User (after update) {
    
    List<Id> userIdList =  new List<Id>();
    if(Trigger.isUpdate){
        for(User userRecord: Trigger.new){
            
            User olduserRecord = Trigger.oldMap.get(userRecord.id);
            String strProfileIdsforAssignemnt = System.label.CaseAssignmentProfileIds;
            String strUserProfileId = String.ValueOf(userRecord.ProfileId).subString(0, 15);
            
            System.debug('Here values are >>>>>>> strProfileIdsforAssignemnt: '+strProfileIdsforAssignemnt+' userRecord.ProfileId : '+strUserProfileId+' userRecord.Availability__c: '+userRecord.Availability__c);
            if(userRecord!=null && userRecord.ProfileId!=null && strProfileIdsforAssignemnt!=null && !strProfileIdsforAssignemnt.equals('') && strProfileIdsforAssignemnt.contains(strUserProfileId)
            && userRecord.Case_Counter__c < Integer.valueOf(System.label.Case_Cap_Counter) && 'Available'.equalsignorecase(userRecord.Availability__c) && (olduserRecord.Availability__c!=userRecord.Availability__c)){
                userIdList.add(userRecord.id);
            }
        }
        
        if(userIdList!=null && userIdList.size()>0){
            Social_UACaseAssignmentHandler suca =  new Social_UACaseAssignmentHandler();
            suca.assignCasetoCareManagers(userIdList);
        }
    }
}