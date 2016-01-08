/********************************************************************************************************
*    Author :     Ashween Kaur Bhatia
*    Requirement: To verify post tag against the assigned queue
*    Version:     1.0
*    Created Date: 5th May, 2014
*********************************************************************************************************/
public class Social_ValidateAssignment{
    
    public static void checkCaseTags(List<Case> ownerVerificationList){    
    Map<Id,String> queueIdGroupnameMap = new Map<Id,String>(); // Stores the active assignment group 
    Map<Id,Id> queueIdAssignmentGroupMap = new Map<Id,Id>();  // Stores the associated queue with active assignment group 
    boolean validPostTag = false; // flag to check if the post tag is relevant to the queue
  
    if(ownerVerificationList.size()>0){
        for(Assignment_Group_Queues__c caseQueue : [Select a.QueueId__c, a.Name, a.Id, a.Assignment_Group_Name__c, a.Assignment_Group_Name__r.Name, a.Active__c From 
                                                Assignment_Group_Queues__c a where Active__c = 'True']){
            // Map of QueueId-Group Name
            queueIdGroupnameMap.put(caseQueue.QueueId__c, caseQueue.Assignment_Group_Name__r.Name);     
            
            // Map of QueueId-Assign GroupId
            queueIdAssignmentGroupMap.put(caseQueue.QueueId__c , caseQueue.Assignment_Group_Name__c);
        }    
    }
    
    for(Case singleCase: ownerVerificationList){
    
    system.debug('!!!!'+singleCase.Case_PostTag__c);
        if(queueIdGroupnameMap.get(singleCase.OwnerId)!=null){
            String groupName = queueIdGroupnameMap.get(singleCase.OwnerId);    
            system.debug('@@@@'+groupName);                    
            if(groupName!=null && ('Unknown'.equalsIgnorecase(groupName) || 'General-bc'.equalsIgnorecase(groupName))){
                validPostTag = TRUE;
                system.debug('####'+validPostTag);
            }
            
            else if(groupName!=null){            
            // Query Required Custom Setting
            Post_Tags__c queueTag = Post_Tags__c.getInstance(groupName);      
            system.debug(queueTag);      
            Set<String> queueTagSet = new Set<String>(queueTag.Radian_Tags__c.split(';'));            
            system.debug('$$$$'+queueTagSet);
            // Check If Post Tag Not Null
                if(singleCase.Case_PostTag__c!=null && singleCase.Case_PostTag__c!=''){
                    
                    List<String> caseTagList = new List<String>(singleCase.Case_PostTag__c.split(Label.PostTag_Delimiter));
                    system.debug('%%%%'+caseTagList );
                    // Check For Queue Tag
                    for(String caseTag: caseTagList){
                        if(queueTagSet.contains(caseTag.trim().toUpperCase())){
                            validPostTag = true;
                            break;
                        }
                    }
                }
            }
            
        }
        if(!validPostTag && !Social_StreamingUtil.businessAssignQueue.contains(singleCase.Id)){
            singleCase.adderror('Wrong Queue Assigned. Please Update Case Post Tags Accordingly.!!!!');
        }
     }
   } 
}