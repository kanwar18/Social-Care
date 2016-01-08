trigger Social_CustomPostEmail on Custom_Post__c (after insert, after update) {
    Set<Id> caseIdSet = new Set<Id>();
    List<Custom_Post__c> customPostSet = new List<Custom_Post__c>();
    for(Custom_Post__c c : Trigger.New){
      if (trigger.isUpdate && trigger.isAfter) {
          if(c.Category__c!= null && (c.Category__c).equalsIgnoreCase('Email') && c.Send_Notification_Email__c && Social_CareManagerResponseUtility.executeTriggerCode ){
                Social_CareManagerResponseEmailUtility.sendEmailToCustomer(c.Id);
          }
      }
      caseIdSet.add(c.case__c);
    }
    if(Boolean.valueOf(Label.ACTIVATE_TIMER_APP)) {
        TimeTrackHandler.updateTimerRecords(caseIdSet,'Custom Social Post ' + (Trigger.isInsert ? 'Insert' : 'Update'));
    }    
}