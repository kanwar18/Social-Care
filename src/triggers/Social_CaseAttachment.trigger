trigger Social_CaseAttachment on Attachment (before insert, before update) {
	
	//Declare and Initialize Map
	Map<Id, String> caseMap =  new Map<Id, String>();
	for(Attachment attachFile : Trigger.New){
		if(Trigger.isInsert){
			caseMap.put(attachFile.ParentId, 'Insert');	
		}
		if(Trigger.isUpdate){
			caseMap.put(attachFile.ParentId, 'Update');
		}
	}
	if(caseMap!=null && !caseMap.isEmpty()){
		SocialStreamingAPIUpdate.caseAttachmentInsertUpdate(caseMap);
		if(Boolean.valueOf(Label.ACTIVATE_TIMER_APP)) {
			TimeTrackHandler.updateTimerRecords(caseMap.keySet(),'Case Attachment ' + (Trigger.isInsert ? 'Insert' : 'Update'));
		} 
	}
}