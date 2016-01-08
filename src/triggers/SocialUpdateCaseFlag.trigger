trigger SocialUpdateCaseFlag on CaseComment (after insert, after update) {
 
    Set<Id> parentCaseIdSet = new Set<Id>();
    for(CaseComment newCaseComt: trigger.new){
        parentCaseIdSet.add(newCaseComt.ParentId);      
          
    }
    
    if(Trigger.isInsert) {
	    if(parentCaseIdSet.size()>0){
	    	SocialStreamingAPIUpdate.CaseCommentUpdate(parentCaseIdSet);
	    }
    }
    if(Boolean.valueOf(Label.ACTIVATE_TIMER_APP)) {
    	TimeTrackHandler.updateTimerRecords(parentCaseIdSet, 'Case Comments ' + (Trigger.isInsert ? 'Insert' : 'Update'));
    }
 }