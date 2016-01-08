/**************************************************************************
Trigger Name:  Social_ContactDNEUpdate
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: Trigger will update the case related to the contact which is being inserted or updated.
Version History: Aditya(14/March/2014) - Release 19March2014
**************************************************************************************************************************/
trigger Social_ContactDNE on Contact (after insert, before update) {
    if (userInfo.getUserId() != '005E0000002G4RU' && Social_CaseAssignmentUtility.executeTriggerCode && (Boolean.valueOf(Label.DNE_Functionality))) {
        Map<Id,Contact> contactIdMap = new Map<Id,Contact>();//Set to store case ids.
        //Loop to fire during contact insert
        if(trigger.isAfter && trigger.isInsert) {
            for(Contact contactObj : trigger.new) {
                if (contactObj.DNE_Contact__c != Null) { 
                    Social_StreamingUtil.preventStatusUpdateWhenDNETriggerFires = false;//adding flag for disabling status change on update of DNE value on case.   
                    Social_StreamingUtil.preventCaseValidateTriggerToFire = False;// adding flag for disabling social_validatecasequeue trigger.
                    contactIdMap.put(contactObj.Id,contactObj);  
                }     
            }
        }
        //Loop to fire before update
        if(trigger.isBefore && trigger.isUpdate) {
            for(Contact contactObj : trigger.new) {
                if (contactObj.DNE_Contact__c != trigger.oldMap.get(contactObj.Id).DNE_Contact__c) { 
                    Social_StreamingUtil.preventStatusUpdateWhenDNETriggerFires = false;//adding flag for disabling status change on update of DNE value on case.
                    Social_StreamingUtil.preventCaseValidateTriggerToFire = False;// adding flag for disabling social_validatecasequeue trigger.
                    contactIdMap.put(contactObj.Id,contactObj);
                }
            }
        }
        
        if(!contactIdMap.isEmpty()) {
            social_DNEHandler.updateDNEOnCase(contactIdMap);
        }
    }
}