trigger Social_caseActivityTracker on Task (after insert, after update){
    // Local Variables
    List<Id> relatedCaseIdList = new List<Id>();
  
    // Capture CaseIds(WhatIds) For Active Related Tasks
    for(Task newTask: Trigger.new){
        System.debug('TASK TRIGGER:' + newTask.Ignore_Case_Activity__c);
        if(!newTask.Ignore_Case_Activity__c){
            relatedCaseIdList.add(newTask.WhatId);
        }
    }
  
    // Check To Proceed
    if(relatedCaseIdList.isEmpty())
    return;
  
    // Instantiate Case Activity Handler Class
    Social_caseActivityHandler activityHandler = new Social_caseActivityHandler(relatedCaseIdList);
  
    // Update Cases With SLA Response Time Stamps
    for(Task newTask: Trigger.new){
        activityHandler.processTaskRecords(newTask);
    }
  
    activityHandler.performDatabaseTransactions();
  
    //Track task changes in case
    Map<Id, String> caseMap =  new Map<Id, String>();
    for(Task newTask : Trigger.new){
        if(Trigger.isInsert){
            caseMap.put(newTask.WhatId, 'Insert');          
        }
        if(Trigger.isUpdate){
            caseMap.put(newTask.WhatId, 'Update');    
        }
    }
    if(caseMap!=null && !caseMap.isEmpty()){
        SocialStreamingAPIUpdate.caseTaskInsertUpdate(caseMap);
    } 
}