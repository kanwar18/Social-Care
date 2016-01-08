trigger Social_ActivityHistoryEvent on Event(before delete) {
    
    for(Event event:Trigger.old){  
       // Check For Delete Flag
       if(!Social_caseActivityDeleteControl.deleteActivity && !Social_StreamingUtil.deleteSLAsetId.contains(event.Id)){
            event.addError('Case Activity History Cannot Be Deleted.');    
       }
    }
}