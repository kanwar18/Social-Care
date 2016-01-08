trigger ForeseeResponseTrigger on Foresee_Survey_Respon__c (after insert) {
    if(Trigger.isInsert && Trigger.isAfter) {
        new ForeseeResponseTriggerHandler().doUpdateCaseId(Trigger.New);
    }
}