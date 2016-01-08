/*** 
 * Trigger: Social_SocialPostTrigger
 * Author: Accenture
 * Date: 4-Mar-2015
 * Requirement/Project Name: Consumer/Business 
 * Requirement Description: This trigger will take care of all activities (updates to be made on case)when care manager replies to customer. 
**/

trigger Social_SocialPostTrigger on SocialPost (before insert, before update) {
    Map<Id,SocialPost> socialPostMap = new Map<Id,SocialPost>();//Map to store case id as key and social post as value
    Map<Id, String> caseMap =  new Map<Id, String>();   
    if ((trigger.isUpdate || trigger.isInsert) && trigger.isBefore) {
        for (SocialPost socialObj : trigger.new) {
            if (socialObj.parentId != Null && socialObj.isOutbound == true) {
                socialPostMap.put(socialObj.parentId,socialObj);
                if (trigger.isInsert) {
                    caseMap.put(socialObj.ParentId, 'Insert');
                }
            }
        }
    }
    
    if(trigger.isbefore && trigger.isInsert){
        for(SocialPost socialObj : trigger.new){
            if(!socialObj.IsOutbound && socialObj.Attachment_URL__c!=NULL && socialObj.Attachment_Type__c !=NULL){
                socialObj.AttachmentURL = socialObj.Attachment_URL__c;
                socialObj.AttachmentType = socialObj.Attachment_Type__c;                 
            }
            if(!socialObj.IsOutbound && socialObj.Response_Context_External_Id__c != NULL){
                socialObj.ResponseContextExternalId = socialObj.Response_Context_External_Id__c;            
            }
        }
    }    
    if (!socialPostMap.KeySet().isEmpty()) {
        social_socialPostSCSHandler.caseUpdateOnOutboundPostAndEventClosure(socialPostMap);
    }
    if(!caseMap.isEmpty() && Boolean.valueOf(Label.ACTIVATE_TIMER_APP)){
        TimeTrackHandler.updateTimerRecords(caseMap.keySet(), 'Social Post ' + (Trigger.isInsert ? 'Insert' : 'Update'));
    }
}