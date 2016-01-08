public class Social_CaseUtilHandler 
{
  // Variables For Round Robin Assignment
  private Map<Id,Id> queueIdAssignmentGroupMap = new Map<Id,Id>();
  private Map<Id,String> queueIdGroupnameMap = new Map<Id,String>();
  private Map<Id,String> userAvailabliltyMap = new Map<Id,String>();
  
  private Map<Id,QueueSobject> caseQueueIdMap = new Map<Id,QueueSobject>();
  private Map<Id, String> caseQueueOwnerMap = new Map<Id, String>();
  private Map<Id,RecordType> caseRecordTypeIdMap = new Map<Id,RecordType>();
  private Map<Id,Integer> assignmentGroupIdIndexMap = new Map<Id,Integer>();
  private Map<String,RecordType> caseRecordTypeNameMap = new Map<String,RecordType>();
  private Map<Id,Assignment_Groups__c> memberIdUserMap = new Map<Id,Assignment_Groups__c>();
  private Map<Id,List<Assignment_Groups__c>> assignmentIdmemberListMap = new Map<Id,List<Assignment_Groups__c>>();
  
  // Local Variables Case Counter
  private Map<Id,User> userstaticCasecountMap = new Map<Id,User>();
  private Map<Id,User> userRunningCasecountMap = new Map<Id,User>();
  
  // Constructor Defined
  public Social_CaseUtilHandler(){
    
    // Query All Available Group Members
    for(Assignment_Groups__c groupMember: [SELECT Group_Name__c, Group_Name__r.Name, User__r.Username, User__c, Last_Assignment__c, Millisecond__c, User_Availability__c FROM 
                                           Assignment_Groups__c ORDER BY Last_Assignment__c, Millisecond__c]){
        
        // Map of (Assgn GroupId - MemberList)
        if(assignmentIdmemberListMap.containsKey(groupMember.Group_Name__c)){
            List<Assignment_Groups__c> existMemberList = assignmentIdmemberListMap.get(groupMember.Group_Name__c);
            existMemberList.add(groupMember);
            assignmentIdmemberListMap.put(groupMember.Group_Name__c, existMemberList);
        }
        else{
            List<Assignment_Groups__c> newMemberList = new List<Assignment_Groups__c>();
            newMemberList.add(groupMember);
            assignmentIdmemberListMap.put(groupMember.Group_Name__c, newMemberList);
        }
    }
    
    // Query Assignment Queue
    for(Assignment_Group_Queues__c caseQueue : [Select a.QueueId__c, a.Name, a.Id, a.Assignment_Group_Name__c, a.Assignment_Group_Name__r.Name, a.Active__c From 
                                                Assignment_Group_Queues__c a where Active__c = 'True']){
        // Map of QueueId-Group Name
        queueIdGroupnameMap.put(caseQueue.QueueId__c, caseQueue.Assignment_Group_Name__r.Name);     
        
        // Map of QueueId-Assign GroupId
        queueIdAssignmentGroupMap.put(caseQueue.QueueId__c , caseQueue.Assignment_Group_Name__c);
    }
    
    // Query User-Case Counter
    for(User careManager: [Select u.Id, u.Case_Counter__c, u.Availability__c From User u where u.IsActive = true limit 10000]){
        
        // Static Case-User Map
        userstaticCasecountMap.put(careManager.Id, careManager);
        
        // Create User Availability Map
        if('Vacation'.equalsIgnorecase(careManager.Availability__c) || 'Offline'.equalsIgnorecase(careManager.Availability__c)){
            userAvailabliltyMap.put(careManager.Id, 'Unavailable');
        }
        else{
            userAvailabliltyMap.put(careManager.Id, 'Available');
        }
    }
    
    // Query All Case Queues (Except Second SLA Queue)
    for(QueueSobject caseQueue: [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name != 'Second SLA Queue']){
        
        // Map of QueueId-Queue
        caseQueueIdMap.put(caseQueue.QueueId, caseQueue);
        caseQueueOwnerMap.put(caseQueue.QueueId, caseQueue.Queue.Name);
    }
    
    // Query Case Record Types
    for(RecordType caseRecordtype: [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType='Case']){
        
        // Map of RecordtypeId - Recordtype
        caseRecordTypeIdMap.put(caseRecordtype.Id, caseRecordtype);
        
        // Map of Recordtype Name-Id Map
        caseRecordTypeNameMap.put(caseRecordtype.Name, caseRecordtype);
    }
    
  }
  
  // Method To Get Available Care Manager
  public Assignment_Groups__c getAvailableCareManager(Id caseOwnerId, String caseStage){
    
    // Local Variables
    Id assignmentGroupId = null;
    Integer careMangerIndex = -2;
    List<Assignment_Groups__c> memberList = new List<Assignment_Groups__c>();
    
    // If Owner Is Queue
    if(queueIdAssignmentGroupMap.get(caseOwnerId)!=null){
        assignmentGroupId = queueIdAssignmentGroupMap.get(caseOwnerId);
        memberList = assignmentIdmemberListMap.get(assignmentGroupId);
    }
    
    // Get Available Care Manager Index
    if(assignmentGroupId!=null && memberList!=null && !memberList.isEmpty()){
        careMangerIndex = generateCareMangerIndex(assignmentGroupId, memberList, caseStage);
    }
    
    // Return The Available Care Manager
    if(careMangerIndex>=0){  
        
        // Mark Index Queue Is Active 
        assignmentGroupIdIndexMap.put(assignmentGroupId, careMangerIndex);
        
        // Mark Assignment TimeStamp
        datetime assignmentTime = datetime.now();
        memberList[careMangerIndex].Last_Assignment__c = assignmentTime;
        memberList[careMangerIndex].Millisecond__c = assignmentTime.millisecondGMT();
        
        // Update Member-Time Map
        if(memberIdUserMap.containsKey(memberList[careMangerIndex].Id) && memberIdUserMap.get(memberList[careMangerIndex].Id).Last_Assignment__c < assignmentTime){
            memberIdUserMap.put(memberList[careMangerIndex].Id, memberList[careMangerIndex]);
        }
        else{
            memberIdUserMap.put(memberList[careMangerIndex].Id, memberList[careMangerIndex]);
        }
        
        // Return The Value      
        return memberList[careMangerIndex];
    }
    else{ 
        // Queue Is Inactive
        return null;
    }
    return null; 
  }
  
  // Method To Return User Status
  public String getUserAvailabilty(Id userId){
    return userAvailabliltyMap.get(userId);
  }
  
  // Method To Check If the Case Owner Is A Round Robin Queue.
  public boolean checkRoundRobinQueue(Id checkId){
    if(queueIdAssignmentGroupMap.get(checkId)!=null)
        return true;
    return false;
  }
  
  // Method To Check If Case Owner Is A User
  public boolean checkCaseOwnerUser(Id checkId){
    if(userstaticCasecountMap.get(checkId)!=null)
        return true;
    return false;
  }
 
  // Method To Check If Case Owner Is A Queue
  public boolean checkCaseOwnerQueue(Id checkId){
    if(caseQueueIdMap.get(checkId)!=null)
        return true;
    return false;
  }
    //Method to check Case owner BSC or CSC
  public String checkQueueOwner(Id checkId){
    System.debug('Entered checkQueueOwner method');
    String strQueue='';
    if(caseQueueOwnerMap!=null && !caseQueueOwnerMap.isEmpty() && caseQueueOwnerMap.get(checkId)!=null){
        String strTemp = '';
        strTemp = caseQueueOwnerMap.get(checkId);
        strTemp = strTemp.substring(strTemp.length() - 3, strTemp.length());
        
        System.debug('Queue Name here::::: '+strTemp); 
        
        if(strTemp.contains('-bc')){
            strQueue = 'Business';
        }
        else{
            strQueue = 'Consumer';
        }
    }
    
    return strQueue;
  } 

  // Method To check If Case Is Business Care/Consumer Care
  public boolean checkCaseConsumerCare(Case request){
    
    // Check Record Type
    //Aditya : Added check for HS Care Rep profile to allow them to create manual cases.
    if(caseRecordTypeIdMap.get(request.RecordTypeId)!=null && caseRecordTypeIdMap.get(request.RecordTypeId).Name.indexOf('Consumer Care')!=-1 || caseRecordTypeIdMap.get(request.RecordTypeId).Name.indexOf('HS Care Rep')!=-1){
        return true;
    }
    return false;
  }
  // Method to return Record Type Id Based On Record Type Name
  public Id generateCaseRecordId(String recordName){
    
    if(caseRecordTypeNameMap.get(recordName)!=null){
        return caseRecordTypeNameMap.get(recordName).Id;
    }
    return null;
  }
  
  
  // Method To Return Related Group Name For a Queue
  public String getRelatedGroupName(Id queueId){
    if(queueIdGroupnameMap.get(queueId)!=null)
        return queueIdGroupnameMap.get(queueId);
    return null;    
  }
  
  // Update Member Case Timestamps
  public void updateCaremanagerTimestamp()
  {
    // Update Care Manager Timestamp
    List<Assignment_Groups__c> updatedMemberList = memberIdUserMap.values();
    if(updatedMemberList!=null && !updatedMemberList.isEmpty()){
        try{
            update updatedMemberList;
        }
        catch(Exception Exp){
            system.debug('EXCEPTION ON CARE MANAGER TIMESTAMP UPDATE:' + Exp.getmessage());
        }
    }
    
    // Update Case Counter On User Records
    List<User> userUpdateList = userRunningCasecountMap.values();
    System.debug('USER COUNTER UPDATES' + userUpdateList);
    if(userUpdateList!=null && !userUpdateList.isEmpty()){
        try{
            update userUpdateList;
        }
        catch(Exception Exp){
            system.debug('EXCEPTION ON USER CASE COUNTER UPDATE:' + Exp.getmessage());
        }
    }
  }
  
  
  // Case Counter Increment Methodo
  public void IncrementCaremanagerCount(Id userId, String caseStatus){
    
    System.debug('INCREMENT COUNTER PARAMETERS:' + userId + caseStatus);
    // Check Running User Map
    if(userRunningCasecountMap.get(userId)!=null){
        
        if(!'Auto Closed'.equalsIgnorecase(caseStatus) && !'Closed'.equalsIgnorecase(caseStatus) && !'Follow Up Hold'.equalsIgnorecase(caseStatus)){
            
            // Decrement Count
            System.debug('RUNNING INCREMENT DONE');
            User caseIncrementUser = userRunningCasecountMap.get(userId);
            caseIncrementUser.Case_Counter__c = caseIncrementUser.Case_Counter__c + 1;
            
            // Add User Running Map
            userRunningCasecountMap.put(caseIncrementUser.Id, caseIncrementUser);
        }
    }
    // Check Static User Map
    else if(userstaticCasecountMap.get(userId)!=null)
    {
        if(!'Auto Closed'.equalsIgnorecase(caseStatus) && !'Closed'.equalsIgnorecase(caseStatus) && !'Follow Up Hold'.equalsIgnorecase(caseStatus)){
            
            // Decrement Count
            System.debug('STATIC INCREMENT DONE');
            User caseIncrementUser = userstaticCasecountMap.get(userId);
            caseIncrementUser.Case_Counter__c = caseIncrementUser.Case_Counter__c + 1;
            
            // Add User Running Map
            userRunningCasecountMap.put(caseIncrementUser.Id, caseIncrementUser);
        }
    }
  }
  
  // Case Counter Decrement Method
  public void DecrementCaremanagerCount(Id userId, String caseStatus){
    
    // Check Running User Map
    if(userRunningCasecountMap.get(userId)!=null && userRunningCasecountMap.get(userId).Case_Counter__c > 0){
            
        // Decrement Count
        User caseDecrementUser = userRunningCasecountMap.get(userId);
        caseDecrementUser.Case_Counter__c = caseDecrementUser.Case_Counter__c - 1;
            
        // Add User Running Map
        userRunningCasecountMap.put(caseDecrementUser.Id, caseDecrementUser);
    }
    // Check Static User Map
    else if(userstaticCasecountMap.get(userId)!=null && userstaticCasecountMap.get(userId).Case_Counter__c > 0)
    {
        // Decrement Count
        User caseDecrementUser = userstaticCasecountMap.get(userId);
        caseDecrementUser.Case_Counter__c = caseDecrementUser.Case_Counter__c - 1;
            
        // Add User Running Map
        userRunningCasecountMap.put(caseDecrementUser.Id, caseDecrementUser);
    }
  }
  
  // Private Method for Round Robin Manager Allocation
  private integer generateCareMangerIndex(Id groupId, List<Assignment_Groups__c> careManagerList, String caseStage){
    
    Integer queueIndex = 0;
    Integer queueMembercount = 0;

    // Get The Index Of Next Available Member From Each Group/Queue.
    if(assignmentGroupIdIndexMap.get(groupId)!=null){
        
        // Increment If Index already Exist
        queueIndex = assignmentGroupIdIndexMap.get(groupId) + 1;
        queueMembercount = queueMembercount + 1;
        
        while(queueIndex>=0)
        {
          // Reset Index When Queue End Reached.
          if(queueIndex == careManagerList.size())
            queueIndex = 0;
            
          // Active Care Manager Available.
          if('Available'.equalsIgnorecase(careManagerList[queueIndex].User_Availability__c)){
            
            // Check Running Case Counter
            if(userRunningCasecountMap.get(careManagerList[queueIndex].User__c)!=null && userRunningCasecountMap.get(careManagerList[queueIndex].User__c).Case_Counter__c < Integer.valueOf(System.label.Case_Cap_Counter)){
                
                // Increase Counter Based On Case Stage
                IncrementCaremanagerCount(careManagerList[queueIndex].User__c, caseStage);
                break;
            }
            else if(userstaticCasecountMap.get(careManagerList[queueIndex].User__c)!=null && userstaticCasecountMap.get(careManagerList[queueIndex].User__c).Case_Counter__c < Integer.valueOf(System.label.Case_Cap_Counter)){
                
                // Increase Counter Based On Case Stage
                IncrementCaremanagerCount(careManagerList[queueIndex].User__c, caseStage);
                break;
            }
          }
            
          // No Active Care Managers In Entire Queue.
          if(queueMembercount == careManagerList.size())
            return -1;
          
          // Increment Counters (Index and Iterate-Index).
          queueIndex++;
          queueMembercount++;
       }
    }
    else{
        
        while(queueIndex>=0)
        {
          // Active Care Manager Available
          if('Available'.equalsIgnorecase(careManagerList[queueIndex].User_Availability__c)){
            
             // Check Running Case Counter
             if(userRunningCasecountMap.get(careManagerList[queueIndex].User__c)!=null && userRunningCasecountMap.get(careManagerList[queueIndex].User__c).Case_Counter__c < Integer.valueOf(System.label.Case_Cap_Counter)){
                
                // Increase Counter Based On Case Stage
                IncrementCaremanagerCount(careManagerList[queueIndex].User__c, caseStage);
                break;
             }
             else if(userstaticCasecountMap.get(careManagerList[queueIndex].User__c)!=null && userstaticCasecountMap.get(careManagerList[queueIndex].User__c).Case_Counter__c < Integer.valueOf(System.label.Case_Cap_Counter)){
                
                // Increase Counter Based On Case Stage
                IncrementCaremanagerCount(careManagerList[queueIndex].User__c, caseStage);
                break;
             }
          }
           
          // No Active Care Managers In Entire Queue
          if(queueMembercount == careManagerList.size()-1){
            return -1;
          }
           
          // Increment Counters (Index and Iterate-Index)
          queueIndex++;
          queueMembercount++;
        }
    }
    return queueIndex;  
  }
  
}