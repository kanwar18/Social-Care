/********************************************************************************************************
*    Author :     Arun Ramachandran
*    Requirement: To assign case ownerships to user when a new/updated case gets assigned to a Queue.
*    Version:     1.0
*    Created Date: 6th November 2013.
*    Updated Date : 7th June 2015
*    Requirement : ITS 1513 and ITS 1545
*    Updated By : Ashween Kaur
*    Release 15th July 2015: ITS-1545,Do not override new case with customer reply
*    Release 19th August : Updated by Ashween to include Manager field null check to prevent exception emails on event insert
*********************************************************************************************************/
public class Social_BusinessRoundRobin{
    /**
    * < businessCaseAssignment() - Method to assign Case via Round Robin method>
    * @param:
    *     Map<Id,List<Case>> businessCaseMap - List of cases which need to be reassigned.        
    *     Boolean flag - To identify if update operations are required. (Technical purposes only)
    *       
    * @return - void
    * @see - Social_validateCaseQueue (trigger)
    */
    
     public static Set<Id> caseDuplicateCheck = new Set<Id>(); 
     public static Set<Id> slaDupeCaseIdSet = new Set<Id>();
     public Static Boolean doNotChangeStatus = true; //added on 052615 by Ashween   
     public Static Boolean isNewCase = true; //added on 070115 by Ashween to differentiate update reason on New case or reopen scenario
          
     public static void businessCaseAssignment(Map<Id,List<Case>> businessCaseMap,Boolean flag, Boolean flagSLA){         
         List<Assignment_Groups__c> generalBcUsers = new List<Assignment_Groups__c>(); // List of General-bc assignment group users.
         List<Assignment_Groups__c> socialSalesUsers = new List<Assignment_Groups__c>();// List of Social Sales Lead assignment group users.
         List<Case> updateCaseList = new List<Case>();// List of cases for which Owners will be updated
         Map<Id, Assignment_Groups__c> updateGroupMembers = new Map<Id, Assignment_Groups__c> (); // Map of Assignment groups members that needs to be updated.
         Integer i = 0; // Used as index for generalBcUsers list
         Integer j = 0; // Used as index for sales Lead Users list
         Set<Id> businessAssignmentGroups = new Set<Id>(); //Id's of General-bc and Social Sales Lead assignment groups.
         Set<Id> caseOwnerIdSet = new Set<Id>(); //Id's of users who own cases. Used to help create SLA's 
         boolean secondSLAFlag = FALSE;    
        // Social_CaseUtilHandler businessRR = new Social_CaseUtilHandler(); // To get case owner availability status        
         
         if(businessCaseMap.keySet().size()>0){
         //Fetching Id's of General-bc and Social Sales Lead assignment groups.
         for(Assignment_Group_Name__c singleGroup: [Select Id from Assignment_Group_Name__c where 
             Name = 'General-bc' OR Name = 'Social Sales Lead']){
             businessAssignmentGroups.add(singleGroup.Id);
         }        
         
         //To identify users who are available in respective queues.
         for(Assignment_Groups__c singleMember : [Select Id,User__c,Group_Name__c,Name, Last_Assignment__c, User_Availability__c,Cases_Owned__c from Assignment_Groups__c where
                                                 User_Availability__c = 'Available' AND User_Active__c = 'True' AND 
                                                 Group_Name__c IN: businessAssignmentGroups ORDER BY Last_Assignment__c]){
             if(singleMember.Group_name__c == System.label.GENERAL_BC_ASGN_GROUP){
                 generalBcUsers.add(singleMember); // General-bc assignment group members
             }
             if(singleMember.Group_name__c == System.label.SOCIAL_SALES_LEAD){
                 socialSalesUsers.add(singleMember);// Social Sales Lead assignment group members
             }                                          
         }       
         
         boolean careIdentifier = FALSE;
         boolean saleIdentifier = FALSE;
         //Updating ownership of the cases.
         for(Id queueId: businessCaseMap.keySet()){         
             for(Case singleCase: businessCaseMap.get(queueId)){
                 //Identify if the Case Post tag is Social Sales Lead
                 if(singleCase.Case_PostTag__c != NULL && singleCase.Case_PostTag__c.containsIgnoreCase('GCS-SALESLEAD')){
                     //Identify if the social sales lead list index is less than list size to continue looping.
                     if(socialSalesUsers.size()>0){                    
                         if(socialSalesUsers.size()>i){
                         //To ensure that the cases owned by the Business care manager is less than Business limit (5 cases)                         
                         if((socialSalesUsers[i].Cases_Owned__c >= Integer.ValueOf(System.Label.SOCIAL_SALES_OWNERSHIP_LIMIT) || test.isRunningTest())) {
                             //To identify the user who has less than 5 open cases assigned to him/her
                             saleIdentifier = TRUE;
                             i = evaluateUserToAssign(i, socialSalesUsers,saleIdentifier);                             
                         }                           
                             if(i != NULL && i < socialSalesUsers.size()){ 
                                 if(!caseDuplicateCheck.contains(singleCase.Id)){
                                     //Updating the case details and the assignment group details for that user.                                    
                                     singleCase.Track_Case_Queue__c = singleCase.OwnerId;                                                                  
                                     singleCase.OwnerId = socialSalesUsers[i].User__c;
                                     singleCase.Group_Member_Name__c = socialSalesUsers[i].Name;
                                     singleCase.Is_Business_Assigned__c = FALSE;
                                     if(isNewCase){
                                         singleCase.Update_reason__c = Social_StreamingUtil.BUSINESS_ROUND_ROBIN;  
                                         Social_StreamingUtil.caseBizAssignedByRR = true;                                   
                                     }
                                     else{
                                          singleCase.Update_reason__c = Social_StreamingUtil.CASE_REOPENED;
                                          Social_StreamingUtil.caseBizAssignedByRR = true;
                                     }
                                     singleCase.NonCaseOwner_LastModifiedDate__c = system.now();                                     
                                     doNotChangeStatus = false ;
                                     Social_StreamingUtil.doNotFireUpdateReason = false;
                                     singleCase.ReadUnreadCheck__c = TRUE;
                                     if(singleCase.BizSecondSLA__c){
                                         singleCase.BizSecondSLA__c = FALSE ;
                                         secondSLAFlag = TRUE;
                                     }
                                     singleCase = updateSLAfields(singleCase);                                 
                                     caseOwnerIdSet.add(singleCase.OwnerId); 
                                     if(socialSalesUsers[i].Cases_Owned__c == NULL){
                                         socialSalesUsers[i].Cases_Owned__c = 0;
                                     }
                                     
                                     if(Social_StreamingUtil.caseOpenBusinessStatus.contains(singleCase.Status) && !Social_StreamingUtil.queueCountProcessed.contains(singleCase.Id)){
                                         socialSalesUsers[i].Cases_Owned__c = socialSalesUsers[i].Cases_Owned__c + 1;
                                         Social_StreamingUtil.caseBizAssignedByRR = true; 
                                         Social_StreamingUtil.queueCountProcessed.add(singleCase.Id);                                         
                                     }
                                     socialSalesUsers[i].Last_Assignment__c = system.now();                                  
                                     updateGroupMembers.put(socialSalesUsers[i].Id, socialSalesUsers[i]);
                                     i++;
                                     
                                     updateCaseList.add(singleCase);
                                     
                                     //Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id); 
                                     Social_StreamingUtil.skipTransaction.add(singleCase.Id);    
                                     caseDuplicateCheck.add(singleCase.Id);  
                                 }     
                             }
                     }
                     else{
                         //To initialize the social sales lead list to start from zero index when index reaches list size - 1.
                         i = 0;    
                         //To ensure that the cases owned by the Business care manager is less than Business limit (5 cases)
                         if(socialSalesUsers[i].Cases_Owned__c >= Integer.ValueOf(System.Label.SOCIAL_SALES_OWNERSHIP_LIMIT)){ 
                         //To identify the user who has less than 5 open cases assigned to him/her
                             saleIdentifier = TRUE;
                             i = evaluateUserToAssign(i, socialSalesUsers,saleIdentifier);
                         }   
                             if(i != NULL && i < socialSalesUsers.size()){ 
                                 if(!caseDuplicateCheck.contains(singleCase.Id)){      
                                 //Updating the case details and the assignment group details for that user.                                      
                                     singleCase.Track_Case_Queue__c = singleCase.OwnerId;                                  
                                     singleCase.OwnerId = socialSalesUsers[i].User__c;
                                     singleCase.Group_Member_Name__c = socialSalesUsers[i].Name;
                                     singleCase.Is_Business_Assigned__c = FALSE;
                                     if(isNewCase){
                                         singleCase.Update_reason__c = Social_StreamingUtil.BUSINESS_ROUND_ROBIN;
                                         Social_StreamingUtil.caseBizAssignedByRR = true;                                     
                                     }
                                     else{
                                          singleCase.Update_reason__c = Social_StreamingUtil.CASE_REOPENED;
                                          Social_StreamingUtil.caseBizAssignedByRR = true;
                                     }
                                     singleCase.NonCaseOwner_LastModifiedDate__c = system.now();                                    
                                     doNotChangeStatus = false ;
                                     Social_StreamingUtil.doNotFireUpdateReason = false;
                                     singleCase.ReadUnreadCheck__c = TRUE;
                                     if(singleCase.BizSecondSLA__c){
                                         singleCase.BizSecondSLA__c = FALSE ;
                                         secondSLAFlag = TRUE;
                                     }                                       
                                     singleCase = updateSLAfields(singleCase);                                                                
                                     caseOwnerIdSet.add(singleCase.OwnerId); 
                                     
                                     if(socialSalesUsers[i].Cases_Owned__c == NULL){
                                         socialSalesUsers[i].Cases_Owned__c = 0;
                                     }
                                     if(Social_StreamingUtil.caseOpenBusinessStatus.contains(singleCase.Status) && !Social_StreamingUtil.queueCountProcessed.contains(singleCase.Id)){
                                         socialSalesUsers[i].Cases_Owned__c = socialSalesUsers[i].Cases_Owned__c + 1;
                                         Social_StreamingUtil.caseBizAssignedByRR = true;
                                         Social_StreamingUtil.queueCountProcessed.add(singleCase.Id);
                                     }
                                     socialSalesUsers[i].Last_Assignment__c = system.now();
                                      
                                     updateGroupMembers.put(socialSalesUsers[i].Id, socialSalesUsers[i]);
                                     i++;
                                     updateCaseList.add(singleCase);                                     
                                     
                                     //Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                                     Social_StreamingUtil.skipTransaction.add(singleCase.Id);
                                     caseDuplicateCheck.add(singleCase.Id); 
                                 }
                             }                       
                         }
                     }
                 }
                 else{
                 if(singleCase.Case_PostTag__c == NULL || !singleCase.Case_PostTag__c.containsIgnoreCase('GCS-SALESLEAD') ){      
                     if(generalBcUsers.size()>0){        
                     //Identify if the sales lead list index is less than list size to continue looping.
                         if(generalBcUsers.size()>j){                     
                         //To ensure that the cases owned by the Business care manager is less than Business limit (10 cases)
                         if((generalBcUsers[j].Cases_Owned__c >= Integer.ValueOf(System.Label.BUSINESS_CASE_OWNERSHIP_LIMIT)) ){
                             //To identify the user who has less than 5 open cases assigned to him/her
                             careIdentifier = FALSE;
                             j = evaluateUserToAssign(j, generalBcUsers,careIdentifier);
                             if(j==NULL){
                                 break;
                             }
                         }  
                             if(j != NULL && j < generalBcUsers.size()){    
                             if(!caseDuplicateCheck.contains(singleCase.Id) && singleCase.Case_PostTag__c!= 'GCS-SALESLEAD'){    
                                 //Updating the case details and the assignment group details for that user.                                    
                                     singleCase.Track_Case_Queue__c = singleCase.OwnerId;                                    
                                     singleCase.OwnerId = generalBcUsers[j].User__c; 
                                     singleCase.Group_Member_Name__c = generalBcUsers[j].Name;
                                     singleCase.Is_Business_Assigned__c = FALSE; 
                                     if(isNewCase){
                                         singleCase.Update_reason__c = Social_StreamingUtil.BUSINESS_ROUND_ROBIN;
                                         Social_StreamingUtil.caseBizAssignedByRR = true;                                     
                                     }
                                     else{
                                          singleCase.Update_reason__c = Social_StreamingUtil.CASE_REOPENED;
                                          Social_StreamingUtil.caseBizAssignedByRR = true;
                                     }
                                     singleCase.NonCaseOwner_LastModifiedDate__c = system.now();                                     
                                     doNotChangeStatus = false ;
                                     Social_StreamingUtil.doNotFireUpdateReason = false;
                                     singleCase.ReadUnreadCheck__c = TRUE;
                                     if(singleCase.BizSecondSLA__c){
                                         singleCase.BizSecondSLA__c = FALSE ;
                                         secondSLAFlag = TRUE;
                                     }                                     
                                     singleCase = updateSLAfields(singleCase);                                                                
                                     caseOwnerIdSet.add(singleCase.OwnerId); 
                                    
                                     if(generalBcUsers[j].Cases_Owned__c == NULL){
                                         generalBcUsers[j].Cases_Owned__c = 0;
                                     }
                                     if(Social_StreamingUtil.caseOpenBusinessStatus.contains(singleCase.Status) && !Social_StreamingUtil.queueCountProcessed.contains(singleCase.Id)){
                                         generalBcUsers[j].Cases_Owned__c = generalBcUsers[j].Cases_Owned__c + 1;                                         
                                         Social_StreamingUtil.caseBizAssignedByRR = true;
                                         Social_StreamingUtil.queueCountProcessed.add(singleCase.Id);
                                     }
                                     generalBcUsers[j].Last_Assignment__c = system.now();                                   
                                     updateGroupMembers.put(generalBcUsers[j].Id, generalBcUsers[j]);
                                     j++;
                                     updateCaseList.add(singleCase);
                                     
                                     //Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id); 
                                     Social_StreamingUtil.skipTransaction.add(singleCase.Id);
                                     caseDuplicateCheck.add(singleCase.Id); 
                                 }
                             }       
                         }
                     else{
                         //To initialize the General-bc list to start from zero index when index reaches list size - 1.
                         j = 0;      
                         //To ensure that the cases owned by the Business care manager is less than Business limit (10 cases)
                         
                         if(((generalBcUsers[j].Cases_Owned__c >= Integer.ValueOf(System.Label.BUSINESS_CASE_OWNERSHIP_LIMIT))) || Test.isRunningTest()){
                         //To identify the user who has less than 5 open cases assigned to him/her
                             careIdentifier = FALSE;
                             j = evaluateUserToAssign(j, generalBcUsers,careIdentifier);
                             if(j==NULL){
                                 break;
                             }
                         }
                             if(j !=NULL && j < generalBcUsers.size()){   
                                 if(!caseDuplicateCheck.contains(singleCase.Id)){
                                 //Updating the case details and the assignment group details for that user.                                     
                                     singleCase.Track_Case_Queue__c = singleCase.OwnerId;                                      
                                     singleCase.OwnerId = generalBcUsers[j].User__c;
                                     singleCase.Group_Member_Name__c = generalBcUsers[j].Name;
                                     singleCase.Is_Business_Assigned__c = FALSE;
                                     if(isNewCase){
                                         singleCase.Update_reason__c = Social_StreamingUtil.BUSINESS_ROUND_ROBIN;
                                         Social_StreamingUtil.caseBizAssignedByRR = true;                                     
                                     }
                                     else{
                                          singleCase.Update_reason__c = Social_StreamingUtil.CASE_REOPENED;
                                          Social_StreamingUtil.caseBizAssignedByRR = true;
                                     }
                                     singleCase.NonCaseOwner_LastModifiedDate__c = system.now();                                    
                                     doNotChangeStatus = false ;
                                     Social_StreamingUtil.doNotFireUpdateReason = false;
                                     singleCase.ReadUnreadCheck__c = TRUE;
                                     if(singleCase.BizSecondSLA__c){
                                         singleCase.BizSecondSLA__c = FALSE ;
                                         secondSLAFlag = TRUE;
                                     }                                     
                                     singleCase = updateSLAfields(singleCase);                                 
                                     caseOwnerIdSet.add(singleCase.OwnerId);    
                                     
                                     if(generalBcUsers[j].Cases_Owned__c == NULL){
                                         generalBcUsers[j].Cases_Owned__c = 0;
                                     }
                                     if(Social_StreamingUtil.caseOpenBusinessStatus.contains(singleCase.Status) && !Social_StreamingUtil.queueCountProcessed.contains(singleCase.Id)){
                                         generalBcUsers[j].Cases_Owned__c = generalBcUsers[j].Cases_Owned__c + 1;
                                         Social_StreamingUtil.caseBizAssignedByRR = true;
                                         Social_StreamingUtil.queueCountProcessed.add(singleCase.Id);
                                     }
                                     generalBcUsers[j].Last_Assignment__c = system.now();
                                     
                                     updateGroupMembers.put(generalBcUsers[j].Id, generalBcUsers[j]);
                                     j++; 
                                     updateCaseList.add(singleCase);
                                     
                                     //Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                                     Social_StreamingUtil.skipTransaction.add(singleCase.Id);
                                     caseDuplicateCheck.add(singleCase.Id); 
                                     }
                                 }
                             }
                         }
                     }
                 }                 
             }
         }
         
         if(updateGroupMembers.size()>0){            
          
             Database.SaveResult[] resultDB = database.update(updateGroupMembers.values(), false);
                try{
                    Integer loopCount = 0;
                    for(Database.SaveResult sr:resultDB)
                    {                
                        if(!sr.isSuccess())
                        {                    
                            Database.Error err = sr.getErrors()[0];                            
                            System.debug('Social_BusinessRoundRobin: Error while updating Assignment Group details. ' +updateGroupMembers.values().get(loopCount).getSObjectType() + err.getMessage());                                            
                        }
                        loopCount++;
                    }
                 }
                 catch(Exception e){
                     System.debug('Social_BusinessRoundRobin: Error handling Response. ' + e.getMessage());                     
                 }             
         }
         if(updateCaseList.size()>0 && flag == true){
            Database.SaveResult[] resultDB = database.update(updateCaseList, false);
            try{
                Integer loopCount = 0;
                for(Database.SaveResult sr:resultDB)
                {                
                    if(!sr.isSuccess())
                    {                    
                        Database.Error err = sr.getErrors()[0];                            
                        System.debug('Social_BusinessRoundRobin: Error while updating case details. ' +updateCaseList.get(loopCount).getSObjectType() + err.getMessage());                                        
                    }
                    loopCount++;
                }
             }
             catch(Exception e){
                 System.debug('Social_BusinessRoundRobin: Error handling Response. ' + e.getMessage());                 
             }
         }
       
         if(updateCaseList.size()>0 && caseOwnerIdSet.size()>0 && !flagSLA){
             //Calling method to initiate SLA's for the cases.
             reassignCaseSLAInitiation(updateCaseList,caseOwnerIdSet);
            }
         if(updateCaseList.size()>0 && caseOwnerIdSet.size()>0 && secondSLAFlag && flagSLA){
             //Calling method to initiate SLA's for the cases.
             reassignCaseSLAInitiation(updateCaseList,caseOwnerIdSet);
         }   
         
        if(updateCaseList.size()>0 && caseOwnerIdSet.size()>0 && !secondSLAFlag && flagSLA){
             //Calling method to initiate SLA's for the cases.
             reassignCaseSLAInitiation(updateCaseList,caseOwnerIdSet);
         } 
            
         }
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
     }        
    
    /**
    * < updateSLAfields() - Method to update case fields including Case SLA information section
    * @param:
    *     Case singleCase - Case for which the SLA fields need to be updated.
    *       
    * @return - Case
    * @see - Social_BusinessRoundRobin (same class)
    */
     public static Case updateSLAfields(Case singleCase){
        

         Datetime slaScheduledTime = datetime.now();
         Integer slaTimeframe = 15;
         Integer emailSLATimeframe = 30;
         Integer secondSLATimeframe = 60;
             //Updating the case SLA fields when the case is in SLA 1 stage
             if(singleCase.Current_SLA_Phase__c==NULL){
              
                singleCase.Case_Assigned_Time__c = System.now();
                singleCase.Current_SLA_Phase__c = 'SLA1 - Initiated';
                if(singleCase.Origin=='Email Business (BizHelp)' || singleCase.Origin == 'Email Business (YouTube)'){                            
                    singleCase.First_SLA_Scheduled_Time__c = slaScheduledTime.addMinutes(emailSLATimeframe );
                }
                else{
                    singleCase.First_SLA_Scheduled_Time__c = slaScheduledTime.addMinutes(slaTimeframe);
                }
                Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                Social_StreamingUtil.processed.add(singleCase.Id);  
             }
             //Updating the case SLA fields when the case is in SLA 2 stage
             else if(singleCase.Current_SLA_Phase__c == 'SLA1 - Ended'){
              

                singleCase.Current_SLA_Phase__c = 'SLA2 - Initiated';  
                singleCase.Second_SLA_Start_Time__c = System.Now();
                singleCase.Second_SLA_Scheduled_Time__c = slaScheduledTime.addMinutes(secondSLATimeframe);
                Social_CaseUpdateStreamCtrl.caseId.add(singleCase.Id);
                Social_StreamingUtil.processed.add(singleCase.Id);
                
             }
             else{
                 slaDupeCaseIdSet.add(singleCase.Id);                 
             }
         return(singleCase);           
     }
     
     /**
    * < countUserCaseUpdate() - Method to update case count on Assignment group member records
    * @param:
    *     Map<Id, List<Case>> countIncCaseUserMap - Map of cases for which case count needs to be reduced
    *     Map<Id, List<Case>> countDecCaseUserMap - Map of cases for which case count needs to be increased.
    *     Map<Id, List<Case>> countCloseCaseUserMap - Map of closed cases for which case count needs to be reduced.
    *       
    * @return - void.
    * @see - BizReopenCaseReassignment (trigger)
    */
     public static void countUserCaseUpdate(Map<Id, List<Case>> countIncCaseUserMap, Map<Id, List<Case>> countDecCaseUserMap,Map<Id, List<Case>> countCloseCaseUserMap){ 
         List<Assignment_Groups__c> updateCountCaseUser = new List<Assignment_Groups__c>(); // List of assignment group records which needs to be updated
                           
         for(Assignment_Groups__c singleMember :[Select Id,Name,Group_Name__c, User__c, User_Availability__c ,Cases_Owned__c from Assignment_Groups__c where (User__c IN: countIncCaseUserMap.keySet() OR User__c IN: countDecCaseUserMap.keySet() OR User__c IN: countCloseCaseUserMap.keySet())]){          
             //To decrease the case count
             if(singleMember.Cases_Owned__c != NULL ){             
                 if(countIncCaseUserMap.size() >0 && countIncCaseUserMap.containsKey(singleMember.User__c ) /*&& singleMember.User_Availability__c != 'Unavailable'*/){                  
                       
                     for(Case singleCase: countIncCaseUserMap.get(singleMember.User__c)){ 
                         if((singleCase.Case_PostTag__c!= NULL && singleCase.Case_PostTag__c.contains('GCS-SALESLEAD')) && singleMember.Group_Name__c == SYSTEM.LABEL.SOCIAL_SALES_LEAD ){                            
                              singleMember.Cases_Owned__c = singleMember.Cases_Owned__c - 1;                              
                         }
                         else if((singleCase.Case_PostTag__c == NULL || !singleCase.Case_PostTag__c.contains('GCS-SALESLEAD')) && singleMember.Group_Name__c == SYSTEM.LABEL.GENERAL_BC_ASGN_GROUP ){                                                         
                              singleMember.Cases_Owned__c = singleMember.Cases_Owned__c - 1;                                 
                         }                                          
                     }                    
                     //singleMember.Cases_Owned__c = singleMember.Cases_Owned__c - countIncCaseUserMap.get(singleMember.User__c).size();
                     updateCountCaseUser.add(singleMember);
                 }
                 
                 //To increase the case count                 
                 if(countDecCaseUserMap.size() > 0 && countDecCaseUserMap.containsKey(singleMember.User__c)){                
                     for(Case singleCase: countDecCaseUserMap.get(singleMember.User__c)){                         
                         if((singleCase.Case_PostTag__c!= NULL && singleCase.Case_PostTag__c.contains('GCS-SALESLEAD')) && singleMember.Group_Name__c == SYSTEM.LABEL.SOCIAL_SALES_LEAD ){                            
                              singleMember.Cases_Owned__c = singleMember.Cases_Owned__c + 1;                              
                         }
                         else if((singleCase.Case_PostTag__c == NULL || !singleCase.Case_PostTag__c.contains('GCS-SALESLEAD')) && singleMember.Group_Name__c == SYSTEM.LABEL.GENERAL_BC_ASGN_GROUP ){                                                         
                              singleMember.Cases_Owned__c = singleMember.Cases_Owned__c + 1;                                 
                         }                     
                     }                       
                  
                 //singleMember.Cases_Owned__c = singleMember.Cases_Owned__c + countDecCaseUserMap.get(singleMember.User__c).size();
                 updateCountCaseUser.add(singleMember);
                 }
                 //To decrease the case count when case is closed.
                 if(countCloseCaseUserMap.size() >0 && countCloseCaseUserMap.containsKey(singleMember.User__c)){
                     for(Case singleCase: countCloseCaseUserMap.get(singleMember.User__c)){                         
                         if(singleCase.Case_PostTag__c!= NULL && singleCase.Case_PostTag__c.contains('GCS-SALESLEAD') && singleMember.Group_Name__c == SYSTEM.LABEL.SOCIAL_SALES_LEAD){
                             singleMember.Cases_Owned__c = singleMember.Cases_Owned__c - 1;
                         }
                         else if((singleCase.Case_PostTag__c == NULL ||!singleCase.Case_PostTag__c.contains('GCS-SALESLEAD')) && singleMember.Group_Name__c == SYSTEM.LABEL.GENERAL_BC_ASGN_GROUP){
                             singleMember.Cases_Owned__c = singleMember.Cases_Owned__c - 1;
                         }                                
                     }
                 //singleMember.Cases_Owned__c = singleMember.Cases_Owned__c - countCloseCaseUserMap.get(singleMember.User__c).size();
                 updateCountCaseUser.add(singleMember);
                 }
             }
         }
        
         if(updateCountCaseUser.size()>0){
            Database.SaveResult[] resultDB = database.update(updateCountCaseUser, false);
            try{
                Integer loopCount = 0;
                for(Database.SaveResult sr:resultDB)
                {                
                    if(!sr.isSuccess())
                    {                    
                        Database.Error err = sr.getErrors()[0];                            
                        System.debug('Social_BusinessRoundRobin: Error while updating Assignment group details. ' +updateCountCaseUser.get(loopCount).getSObjectType() + err.getMessage());                
                    }
                    loopCount++;
                }
             }
             catch(Exception e){
                 System.debug('Social_BusinessRoundRobin: Error handling Response. ' + e.getMessage());
             }
         }
     } 
    
    /**
    * < evaluateUserToAssign() - Method to identify which user needs to have case assigned.
    * @param:
    *     Integer index - Current index on the list of assignment groups
    *     List<Assignment_Groups__c> groupUsers - List of assignment groups being used for case assignment
    *       
    * @return - void.
    * @see - Social_BusinessRoundRobin(same class)
    */
     public static Integer evaluateUserToAssign(Integer index, List<Assignment_Groups__c> groupUsers, boolean caseIdentifier){
         Integer currentIndex;
         Integer newIndex = NULL;
         //Loop to identify the user beyond the current index who have less than 5 cases.
         for(currentIndex = index; currentIndex < groupUsers.size();currentIndex++){   
             if(!caseIdentifier){          
                 if(groupUsers[currentIndex].Cases_Owned__c < Integer.ValueOf(System.Label.BUSINESS_CASE_OWNERSHIP_LIMIT)){
                     newIndex = currentIndex;
                     break;
                 }
             }
             else{
                 if(groupUsers[currentIndex].Cases_Owned__c < Integer.ValueOf(System.Label.SOCIAL_SALES_OWNERSHIP_LIMIT)){
                     newIndex = currentIndex;
                     break;
                 }
             }
         }
         //Loop to identify the user from 0th index to the current index who have less than 5 cases.
         if(currentIndex == NULL){
             for(currentIndex = 0; currentIndex < Index ;currentIndex++){
                 if(!caseIdentifier){
                     if(groupUsers[currentIndex].Cases_Owned__c < Integer.ValueOf(System.Label.BUSINESS_CASE_OWNERSHIP_LIMIT)){
                         newIndex = currentIndex;
                         break;
                     }
                 }
                 else{
                    if(groupUsers[currentIndex].Cases_Owned__c < Integer.ValueOf(System.Label.SOCIAL_SALES_OWNERSHIP_LIMIT)){
                         newIndex = currentIndex;
                         break;
                     } 
                 }
             }
         } 
         
         if(newIndex!=NULL){
             return newIndex;
         }
         else{
             return newIndex;
         }   
              
     }
    /**
    * < evaluateUserToAssign() - Method to identify which users needs to have case assigned when user marks themselves as Available
    * @param:
    *     Set<Id> userAvailableSet - Users who have marked themselves as available
    *       
    * @return - void.
    * @see - SocialCaseReassignment(User trigger)
    */
     @future
     public static void businessCaseAssignmentAvailability(Set<Id> userAvailableSet){
        Set<Id> businessQueueSet = new Set<Id>(); // Id's of General-bc and social sales lead assignment groups.
        Map<Id, List<Case>> businessCaseMap = new Map<Id, List<Case>>(); // List of cases for which assigment needs to happen
        Boolean flag = true; // To identify if update operations are required. (Technical purposes only)
        Boolean flagSLA = false;
        //Fetching Id's of General-bc and sales lead assignment groups.
        for(Group singleUser : [Select Id from Group where Type='Queue' and (Name='Social Sales Lead' OR Name = 'General-bc')]){
             businessQueueSet.add(singleUser.Id);             
        } 
        
        //To identify cases that are available in respective queues.
        for(Case singleCase: [Select Id, Origin, Status,Update_reason__c,BizSecondSLA__c, CaseNumber,OwnerId,CreatedDate,Case_Assigned_Time__c,Current_SLA_Phase__c,First_SLA_Scheduled_Time__c,
                             Case_PostTag__c,Second_SLA_Start_Time__c,Second_SLA_Scheduled_Time__c,
                             Track_Case_Queue__c from Case where OwnerId IN: businessQueueSet ORDER BY CreatedDate]){
            if(businessCaseMap.containsKey(singleCase.OwnerId)){
                businessCaseMap.get(singleCase.OwnerId).add(singleCase);
            }
            else{
                businessCaseMap.put(singleCase.OwnerId, new List<Case>{singleCase});
            } 
            // Ashween added the below if-else loop to identify the Update Reason if care manager marks available            
            if( singleCase.Status == 'New' ){
                isNewCase = true;  
            }
            else if( singleCase.Status == 'Reopen'){  
                isNewCase = false;
            }      
        }        
        
        if(businessCaseMap.size()>0){
            businessCaseAssignment(businessCaseMap, flag,flagSLA);            
        }
     }
    
    /**
    * < reassignCaseSLAInitiation() - Method to create SLA's for the cases which have been assigned to users.
    * @param:
    *     List<Case> slaInitiateCaseList - cases for which SLA's need to be created.
    *     Set<Id> caseOwnerIdSet - Id's of the owner of cases.  
    *
    * @return - void.
    * @see - SocialCaseReassignment(User trigger)
    */ 
    public static void reassignCaseSLAInitiation(List<Case> slaInitiateCaseList,Set<Id> caseOwnerIdSet){
      
    Map<Id,User> caseOwnerManagerMap = new Map<Id,User>(); //Map of case owners and corresponding managers    
    List<Event> eventSLAList = new List<Event>(); // List of Event SLA's
    List<Task> taskSLAList = new List<Task>(); //List of task SLA's
    
    String eventDescription = 'First SLA Response Reminder';
    String eventDescriptionSLA2 = 'Second SLA Response Reminder';
    Integer timePeriod = 15;
    Integer emailSLATimePeriod = 30;
    Integer reminderTime = 12;
    String eventType = 'SLA - 1';
    Datetime assignmentTime = datetime.now();
    Integer timePeriodSLA2 = 60;
    Integer reminderTimeSLA2 = 45;
    String eventTypeSLA2 = 'SLA - 2';
    
        if(caseOwnerIdSet.size()>0){
            for(User singleUser:[Select Id, Name, ManagerId from User where Id IN: caseOwnerIdSet]){
                caseOwnerManagerMap.put(singleUser.Id, singleUser);                 
            }
        }        
        
        for(Case caseSLAsingle: slaInitiateCaseList){            
              if(!slaDupeCaseIdSet.contains(caseSLAsingle.Id)){ 
              Event careEvent = new Event();
              careEvent.WhatId = caseSLAsingle.Id;              
              careEvent.Event_Status__c = 'Open';
              careEvent.OwnerId = caseSLAsingle.OwnerId;              
              careEvent.StartDateTime = assignmentTime;
              careEvent.IsReminderSet = true;
              if(caseSLAsingle.Current_SLA_Phase__c == 'SLA1 - Initiated'){
                  careEvent.Description = eventDescription;
                  if(caseSLAsingle.Origin == 'Email Business (YouTube)' || caseSLAsingle.Origin == 'Email Business (BizHelp)'){
                      careEvent.DurationInMinutes = emailSLATimePeriod ;
                  }
                  else{
                      careEvent.DurationInMinutes = timePeriod;
                  }
                  careEvent.Event_Type__c = eventType;
                  careEvent.ReminderDateTime = assignmentTime.addMinutes(reminderTime);
                  careEvent.Subject = eventType + ':' + caseOwnerManagerMap.get(caseSLAsingle.OwnerId).Name + ':' + caseSLAsingle.CaseNumber;
              }
              if(caseSLAsingle.Current_SLA_Phase__c == 'SLA2 - Initiated'){
                  careEvent.Description = eventDescriptionSLA2;
                  careEvent.DurationInMinutes = timePeriodSLA2;
                  careEvent.Event_Type__c = eventTypeSLA2;
                  careEvent.ReminderDateTime = assignmentTime.addMinutes(reminderTimeSLA2);
                  careEvent.Subject = eventTypeSLA2 + ':' + caseOwnerManagerMap.get(caseSLAsingle.OwnerId).Name + ':' + caseSLAsingle.CaseNumber;
              }
              eventSLAList.add(careEvent);
              if(caseOwnerManagerMap.containsKey(caseSLAsingle.ownerId) && caseOwnerManagerMap.get(caseSLAsingle.ownerId)!= NULL) {
                  // Operation Manager Event
                  Event operationEvent = new Event();
                  operationEvent.WhatId = caseSLAsingle.Id;              
                  operationEvent.Event_Status__c = 'Open';
                  operationEvent.IsReminderSet = true;
                  operationEvent.OwnerId = caseOwnerManagerMap.get(caseSLAsingle.OwnerId).ManagerId;              
                  operationEvent.StartDateTime = assignmentTime;
                  if(caseSLAsingle.Current_SLA_Phase__c == 'SLA1 - Initiated'){
                      operationEvent.Description = eventDescription;
                      if(caseSLAsingle.Origin == 'Email Business (YouTube)' || caseSLAsingle.Origin == 'Email Business (BizHelp)'){
                          operationEvent.DurationInMinutes = emailSLATimePeriod ;
                      }
                      else{
                          operationEvent.DurationInMinutes = timePeriod;
                      }
                      operationEvent.Event_Type__c = eventType;
                      operationEvent.ReminderDateTime = assignmentTime.addMinutes(reminderTime);
                      operationEvent.Subject = eventType + ':' + caseOwnerManagerMap.get(caseSLAsingle.OwnerId).Name + ':' + caseSLAsingle.CaseNumber;
                  }
                  if(caseSLAsingle.Current_SLA_Phase__c == 'SLA2 - Initiated'){
                      operationEvent.Description = eventDescriptionSLA2;
                      operationEvent.DurationInMinutes = timePeriodSLA2;
                      operationEvent.Event_Type__c = eventTypeSLA2;
                      operationEvent.ReminderDateTime = assignmentTime.addMinutes(reminderTimeSLA2);
                      operationEvent.Subject = eventTypeSLA2 + ':' + caseOwnerManagerMap.get(caseSLAsingle.OwnerId).Name + ':' + caseSLAsingle.CaseNumber;
                  }
                  eventSLAList.add(operationEvent);
                  }                 
              }
        }
        
        if(eventSLAList.size()>0){
            Database.SaveResult[] resultDB = database.insert(eventSLAList, false);
            try{
                Integer loopCount = 0;
                for(Database.SaveResult sr:resultDB)
                {                
                    if(!sr.isSuccess())
                    {                    
                        Database.Error err = sr.getErrors()[0];                            
                        System.debug('Social_BusinessRoundRobin: Error while creating SLAs ' +eventSLAList.get(loopCount).getSObjectType() + err.getMessage());                
                    }
                    loopCount++;
                }
             }
             catch(Exception e){
                 System.debug('Social_BusinessRoundRobin: Error handling Response. ' + e.getMessage());
             }
        }       
    }
}