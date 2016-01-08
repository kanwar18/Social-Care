/********************************************************************************************************
*    Author :     Accenture
*    Requirement: This class will update queue id on group member record.
*    Version:     1.0
*    Created Date: 30th April 2015.
*    Version History: 5/May/2015(Aditya) : Deployed ITS - 001545
*********************************************************************************************************/

Public Class Social_GroupMemberHandler {
    public static Map<id,User> rtFlipUserMap = new Map<Id,User>();
    /**
    * < updateQueueIdGroupMember() - Method to update queue Id on group member>
    * @param:
    *     List<Assignment_Groups__c> groupMemberList - List of group member
    *     Set<String> assignmentGroupNameSet  - Set of assignment group name
    * @return - void
    * @see -  (Social_GroupMember)
    * 
    */
    
    Public static void updateQueueIdGroupMember(List<Assignment_Groups__c> groupMemberList,Set<String> assignmentGroupNameSet) {
        Map<String,Id> assignmentGroupMap = new Map<String,Id>();//Map to store assignment group name and its Id
        for (Group grp : [select id,Name from group where type = 'Queue' and Name IN: assignmentGroupNameSet]) {
            assignmentGroupMap.put(grp.Name,grp.Id);
        }
        for (Assignment_Groups__c groupMem: groupMemberList) {
            if (assignmentGroupMap.containsKey(groupMem.Assignment_Group_Name__c)) {
                groupMem.User_Queue_Id__c = assignmentGroupMap.get(groupMem.Assignment_Group_Name__c);
            }
        }
    }
    
    /**
    * < assignCasesToUserBulk () - Method to assign cases to user in bulk>
    * @param:
    *     Set<Id> ownerIdSet - Ids of case onwer
    * @return - void
    * @see -  (Social_SocialPostSCSHandler)
    * 
    */
    
    Public static void assignCasesToUserBulk (Set<Id> ownerIdSet) {
        Map<Id,Set<Id>> groupMemberDetailMap = new Map<Id,Set<Id>>();//Map to store queue Id as key and user Id as value
        Map<Id,List<Case>> caseDetailMap = new Map<Id,List<Case>>();//Map to store key as queue Id and case as value
        Map<Id,Id> caseQueueMap = new Map<Id,Id>();
        List<Case> casesToAssignList = new List<Case>();//List of cases to be assigned
        List<Case> casesToUpdateList = new List<Case>();
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> duplicateUserSet = new Set<Id>();
        for (Assignment_Groups__c groupMember : [select User_Queue_Id__c,User__c from Assignment_Groups__c where User__c IN: ownerIdSet]) {
            if (groupMember.User_Queue_Id__c != Null && groupMember.User__c != Null) {
                if (groupMemberDetailMap.containsKey(groupMember.User_Queue_Id__c)) {
                    groupMemberDetailMap.get(groupMember.User_Queue_Id__c).add(groupMember.User__c);
                } else {
                    groupMemberDetailMap.put(groupMember.User_Queue_Id__c, new Set<Id> {groupMember.User__c});
                }
            }
        }
        /******* CHECK FOR ESCALATED AND REOPEN CASES BASED ON CREATED DATE ********/
        for (Case caseObj : [Select id,ownerId from case where OwnerId IN: groupMemberDetailMap.KeySet() and (status =: Social_StreamingUtil.CASE_STATUS_ESCALATED OR status =: Social_StreamingUtil.CASE_STATUS_REOPEN) order by createdDate limit 49000]) {
            if (caseDetailMap.containsKey(caseObj.ownerId)) {
                caseDetailMap.get(caseObj.ownerId).add(caseObj);
            } else {
                caseDetailMap.put(caseObj.ownerId, new List<Case> {caseObj});
            }
            if (caseDetailMap.get(caseObj.ownerId).size() <= groupMemberDetailMap.get(caseObj.ownerId).size()) {
                casesToAssignList.add(caseObj);
                caseIdSet.add(caseObj.Id);
            }
        }
        /******* CHECK FOR DIRECTED CASES WITH STATUS NOT AS CLOSED OR AUTO CLOSED BASED ON CREATED DATE ********/
        if (casesToAssignList.size() < ownerIdSet.size()) {
            for (Case caseObj : [Select id,ownerId from case where OwnerId IN: groupMemberDetailMap.KeySet() and Content_Tag__c like '%DIR' and (Status =: Social_StreamingUtil.CASE_STATUS_FOLLOWUPHOLD OR Status =: Social_StreamingUtil.CASE_STATUS_ESCALATED OR Status =: Social_StreamingUtil.CASE_STATUS_NEW OR Status =: Social_StreamingUtil.CASE_STATUS_INVESTIGATING OR Status =: Social_StreamingUtil.CASE_STATUS_REOPEN OR Status =: Social_StreamingUtil.CASE_STATUS_REASSIGNED OR Status =: Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK OR Status =: Social_StreamingUtil.CASE_STATUS_PENDINGCLOSURE) order by createdDate limit 49000]) {
                if (!caseIdSet.contains(caseObj.Id)) {
                    if (caseDetailMap.containsKey(caseObj.ownerId)) {
                        caseDetailMap.get(caseObj.ownerId).add(caseObj);
                    } else {
                        caseDetailMap.put(caseObj.ownerId, new List<Case> {caseObj});
                    }
                    if (caseDetailMap.get(caseObj.ownerId).size() <= groupMemberDetailMap.get(caseObj.ownerId).size()) {
                        casesToAssignList.add(caseObj);
                        caseIdSet.add(caseObj.Id);
                    }
                }
            }
        }
        /******* CHECK FOR DISCOVERED CASES WITH STATUS NOT AS CLOSED OR AUTO CLOSED BASED ON CREATED DATE ********/
        if (casesToAssignList.size() < ownerIdSet.size()) {
            for (Case caseObj : [Select id,ownerId from case where OwnerId IN: groupMemberDetailMap.KeySet() and (Content_Tag__c like '%DISC' OR Content_Tag__c = '') and (Status =: Social_StreamingUtil.CASE_STATUS_FOLLOWUPHOLD OR Status =: Social_StreamingUtil.CASE_STATUS_ESCALATED OR Status =: Social_StreamingUtil.CASE_STATUS_NEW OR Status =: Social_StreamingUtil.CASE_STATUS_INVESTIGATING OR Status =: Social_StreamingUtil.CASE_STATUS_REOPEN OR Status =: Social_StreamingUtil.CASE_STATUS_REASSIGNED OR Status =: Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK OR Status =: Social_StreamingUtil.CASE_STATUS_PENDINGCLOSURE) order by createdDate limit 49000]) {
                if (!caseIdSet.contains(caseObj.Id)) {
                    if (caseDetailMap.containsKey(caseObj.ownerId)) {
                        caseDetailMap.get(caseObj.ownerId).add(caseObj);
                    } else {
                        caseDetailMap.put(caseObj.ownerId, new List<Case> {caseObj});
                    }
                    if (caseDetailMap.get(caseObj.ownerId).size() <= groupMemberDetailMap.get(caseObj.ownerId).size()) {
                        casesToAssignList.add(caseObj);
                        caseIdSet.add(caseObj.Id);
                    }
                }
            }
        }
    
        if (!casesToAssignList.isEmpty()) {
            //Loop throught the cases added to list order by created date
            for (Case caseAssign : [select id,OwnerId,Customer_Response_Received__c,CaseNumber,Status,Assigned_Operation_Manager__c,RecordTypeId,Case_Reopen_Flag__c,First_SLA_Scheduled_Time__c,Current_SLA_Phase__c,Pending_Second_SLA_Task_Creation__c from case where Id IN:caseIdSet FOR UPDATE]) {
                if (groupMemberDetailMap.containsKey(caseAssign.ownerId)) {
                    //For each case owner get the relevant user and assign
                    for (Id userId : groupMemberDetailMap.get(caseAssign.ownerId)) {
                        if (!duplicateUserSet.contains(userId)) {
                            caseQueueMap.put(caseAssign.Id,caseAssign.ownerId);//Map with key as case Id and value as queue Id 
                            caseAssign.ownerId = userId;
                            duplicateUserSet.add(userId);
                            casesToUpdateList.add(caseAssign);
                        }
                    }
                }
            }
            if(!duplicateUserSet.isEmpty() && rtFlipUserMap.values().isEmpty()){
                rtFlipUserMap = Social_GroupMemberHandler.userDetailMap(duplicateUserSet);
            }
            if (!casesToUpdateList.isEmpty()) {
                Social_GroupMemberHandler.caseSLADetailsOnAssignment(casesToUpdateList,caseQueueMap);
            } else if (!caseIdSet.isEmpty() && casesToUpdateList.isEmpty()) {
                Social_GroupMemberHandler.assignCasesToUserBulk(ownerIdSet);
            }
        }
    }
    
     /**
    * < userDetailMap() - Method to populate user details>
    * @param:
    *     Set<Id> duplicateUserIdSet - Set of user ids
    *   
    * @return - Map<id, User> rtFlipUserMap
    * @see -  (Social_GroupMemberHandler)
    * 
    */
    
    Public Static Map<id, User> userDetailMap(Set<Id> duplicateUserIdSet) {
        Map<Id,User> userMapInternal = new Map<Id,User>();
        for(User userObj : [select id,profileId from user where id IN:duplicateUserIdSet]) {
            userMapInternal.put(userObj.id, userObj);
        }
        return userMapInternal;
    }
    
    
    
    
    /**
    * < caseSLADetailsOnAssignment() - Method to set SLA details on case when case is reassigned/assigned to user>
    * @param:
    *     List<Case> caseList - List of cases
    *     Map<Id,Id> caseQueueMap - Map with key as case id and value as queue id
    * @return - void
    * @see -  (Social_GroupMemberHandler)
    * 
    */
    
    Public Static Void caseSLADetailsOnAssignment(List<Case> caseList,Map<Id,Id> caseQueueMap) {
        Set<String> traineeProfileSet = new Set<String>(System.Label.HS_Care_Rep_Profile_Id.split(';'));
        Set<Case> reassignedCaseSet = new Set<Case> ();//List to hold all reassigned cases
        Set<Case> assignedCaseSet = new Set<Case>();//List to hold all first time assignment cases
        List<Case> finalCaseList = new List<Case>();
        Social_CaseUtility scu =  new Social_CaseUtility();//Class for creating events and populating manager details on case
        scu.createSlaEventsDefaultsInvocation();
        for (Case slaDetailCase: caseList) {
            if (scu.getRelatedCareManagerCounter(slaDetailCase.ownerId) < Integer.valueOf(System.Label.Case_Cap_Counter) && 'Available'.equalsIgnoreCase(scu.getRelatedCareManagerAvailability(slaDetailCase.ownerId)) ) {
                //Logic to flip record type to HS Care rep for trainee profile
                if (rtFlipUserMap.containsKey(slaDetailCase.ownerId) && traineeProfileSet.Contains(rtFlipUserMap.get(slaDetailCase.ownerId).profileId) && slaDetailCase.RecordTypeId != System.Label.HS_Care_Rep_RT) {
                    slaDetailCase.RecordTypeId = System.Label.HS_Care_Rep_RT;
                }
                //populate track case queue details
                if (caseQueueMap.containsKey(slaDetailCase.Id) && slaDetailCase.Track_Case_Queue__c == Null) {
                    slaDetailCase.Track_Case_Queue__c = caseQueueMap.get(slaDetailCase.Id);
                }
                // Update Assigned Operations Manager(First Assignment Only)
                if(slaDetailCase.Assigned_Operation_Manager__c == null){
                    slaDetailCase.Assigned_Operation_Manager__c = scu.getRelatedOperationManager(slaDetailCase.ownerId);
                }
                // Track New Operation Manager Email(After Initial Assignment)
                if(slaDetailCase.Case_Assigned_Time__c != null){
                    slaDetailCase.Track_Case_Owner_Change__c = true;
                    slaDetailCase.Current_Operation_Manager_Email__c = scu.getRelatedOperationManagerEmail(slaDetailCase.ownerId);
                }
                slaDetailCase.NonCaseOwner_LastModifiedDate__c = system.now();
                slaDetailCase.Update_Reason__c = 'Outreach Assignment';
                //Initate first SLA
                if (slaDetailCase.First_SLA_Scheduled_Time__c == Null) {
                    datetime assignmentTime = datetime.now();
                    slaDetailCase.Current_SLA_Phase__c = Social_StreamingUtil.SLA1_INITIATED;
                    slaDetailCase.Customer_Response_Received__c = true; //DNR: customer response received true when SLA1 initiate.
                    slaDetailCase.First_SLA_Scheduled_Time__c = assignmentTime.addMinutes(15);
                    if(slaDetailCase.Case_Assigned_Time__c==null){
                        slaDetailCase.Case_Assigned_Time__c = assignmentTime;
                        assignedCaseSet.add(slaDetailCase);
                    } else if(slaDetailCase.Moved_to_Prior_Care_Manager__c == false){
                        slaDetailCase.Case_Reassigned_Time__c = assignmentTime;
                        reassignedCaseSet.add(slaDetailCase);
                    }
                    //creating events
                    scu.createSlaEvents(slaDetailCase, slaDetailCase.ownerId, assignmentTime, 'SLA - 1');
                } else if (Social_StreamingUtil.SLA1_ENDED.equalsIgnorecase(slaDetailCase.Current_SLA_Phase__c) && slaDetailCase.Customer_Response_Received__c) {
                    datetime assignmentTime = datetime.now();
                    if(slaDetailCase.Moved_to_Prior_Care_Manager__c == false){
                        slaDetailCase.Case_Reassigned_Time__c = assignmentTime;
                    }
                    slaDetailCase.Current_SLA_Phase__c = Social_StreamingUtil.SLA2_INITIATED;
                    slaDetailCase.Second_SLA_Start_Time__c = assignmentTime;
                    slaDetailCase.Second_SLA_Scheduled_Time__c = assignmentTime.addMinutes(60);
                    if(slaDetailCase.Pending_Second_SLA_Task_Creation__c || slaDetailCase.Case_Reopen_Flag__c){
                        //Create SLA Task here
                        scu.createSlaTasks(slaDetailCase.Id, slaDetailCase.OwnerId, 'SLA-2 Customer Response Task', 'SLA-2 Social Post Customer Response', 'SLA - 2', true);
                    }
                    slaDetailCase.Pending_Second_SLA_Task_Creation__c = false;
                    slaDetailCase.Case_Reopen_Flag__c = false;
                    //CREATING EVENTS
                    scu.createSlaEvents(slaDetailCase, slaDetailCase.OwnerId, assignmentTime, 'SLA - 2');
                    //adding case to reassign list
                    reassignedCaseSet.add(slaDetailCase);
                } else if (Social_StreamingUtil.SLA2_ENDED.equalsIgnorecase(slaDetailCase.Current_SLA_Phase__c)) {
                    if(slaDetailCase.Moved_to_Prior_Care_Manager__c == false){
                        slaDetailCase.Case_Reassigned_Time__c = dateTime.Now();
                        //adding case to reassign list
                        reassignedCaseSet.add(slaDetailCase);
                    }
                }
                finalCaseList.add(slaDetailCase);
            }
        }
        /************* LOGIC TO ADD CASE ASSIGNMENT/REASSIGNMENT TO CUSTOM OBJECT FOR REPORTING PURPOSE ***************/
        if (!reassignedCaseSet.isEmpty()) {
            Social_markCaseUpdates.CaseReassignments(reassignedCaseSet, Social_StreamingUtil.OUTREACH_ASSIGNMENT,Social_StreamingUtil.REASSIGNED);
        }
        if (!assignedCaseSet.isEmpty()) {
            Social_markCaseUpdates.CaseReassignments(assignedCaseSet, Social_StreamingUtil.OUTREACH_ASSIGNMENT,Social_StreamingUtil.ASSIGNED);
        }
        //Assign case to care manager
        if (!finalCaseList.isEmpty()) {
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            Social_StreamingUtil.updateSObject(finalCaseList,'Class:Social_GroupMemberHandler Method:caseSLADetailsOnAssignment: Failed to assing new case to care manger');
            //Insert Events
            scu.saveSLAEventsandTasks();
        }
    }
}