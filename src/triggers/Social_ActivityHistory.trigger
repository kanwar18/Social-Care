/*** 
 * Name: Social_ActivityHistory
 * Author: Accenture
 * Updated Date: 25-June-2015
 * Requirement/Project Name: Consumer/Business Care
 * Version history: Haemen (15/July/2015) -ITS 1545
**/
trigger Social_ActivityHistory on Task (before insert, after insert, after update, before delete) {
    Map<Id,Task> caseIdMap = new Map<Id,Task>();
    List<Id> relatedCaseIdList = new List<Id>();
    List<Id> updateCaseIdList = new List<Id>();
    //Logic to stop deletion.
    if(trigger.isDelete){
        for(Task task:Trigger.old){  
           // Check For Delete Flag
           if(!Social_caseActivityDeleteControl.deleteActivity){
                task.addError('Case Activity History Cannot Be Deleted.');
           }    
        }
    }
    
    //Logic to close SLA's
    if(trigger.isInsert){
        for(Task newTask: Trigger.new){          
            if(!newTask.Ignore_Case_Activity__c){
                if(trigger.isAfter){                  
                    caseIdMap.put(newTask.WhatId,newTask);
                }
                relatedCaseIdList.add(newTask.WhatId);
            }
        } 
    }
    
    if(trigger.isUpdate && trigger.isAfter){
        for(Task newTask: Trigger.new){
            updateCaseIdList.add(newTask.WhatId);
        }
    }
    
    if(!updateCaseIdList.isEmpty() && Social_StreamingUtil.doNotFireUpdateReason){
        Social_SocialPostSCSHandler.UpdateCaseOnTaskUpdate(updateCaseIdList);
    }
    
    // Check To Proceed
    if(relatedCaseIdList.isEmpty()){
    return;
    }
    // Instantiate Case Activity Handler Class
    Social_caseActivityHandler activityHandler = new Social_caseActivityHandler(relatedCaseIdList);
      
    // Update Cases With SLA Response Time Stamps
    for(Task newTask: Trigger.new){
        activityHandler.processTaskRecords(newTask);
    }
      
    activityHandler.performDatabaseTransactions();
        
    if(!caseIdMap.IsEmpty()){
        Social_SocialPostSCSHandler.UpdateCaseOnTaskInsert(caseIdMap);
    }
}