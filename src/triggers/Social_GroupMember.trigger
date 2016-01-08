/********************************************************************************************************
*    Author :     Accenture
*    Requirement: This trigger will fire when group member record is added/updated
*    Version:     1.0
*    Created Date: 30th April 2015.
*********************************************************************************************************/

trigger Social_GroupMember on Assignment_Groups__c (before insert) {
    List<Assignment_Groups__c> groupMemberList = new List<Assignment_Groups__c>();//List to store group member info
    Set<String> assignmentGroupNameSet = new Set<String>();// Set to store assignment group name
    if (trigger.isInsert && trigger.isBefore) {
        for (Assignment_Groups__c groupMem : trigger.New) {
            if (groupMem.Assignment_Group_Name__c != Null) {
                groupMemberList.add(groupMem);//adding group member record to a list
                assignmentGroupNameSet.add(groupMem.Assignment_Group_Name__c);//adding assignment group name to set
            }
        }
    } 
    //If group member list is not empty
    if (!groupMemberList.isEmpty() && !assignmentGroupNameSet.isEmpty()) {
        Social_GroupMemberHandler.updateQueueIdGroupMember(groupMemberList,assignmentGroupNameSet);
    }
}