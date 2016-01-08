trigger Social_EventSlaValidation on Event (before insert, before update) 
{
    if (Social_StreamingUtil.doNtFireEmail2CaseRun) {
      // Variable Declaration
      List<Id> caseIdList = new List<Id>();
      List<case> relatedCaseList = new List<case>();
      Map<Id,Case> caseIdCaseMap = new Map<Id,Case>();
      
      // Get All Related Case Ids
      if(Trigger.isInsert){
        for(Event caseEvent: Trigger.new){
            // Capture Insert Of 3rd SLA Events
             if('SLA - 3'.equalsIgnorecase(caseEvent.Event_Type__c)){
                    caseIdList.add(caseEvent.WhatId);
             }
         }
      }
      
      // Check To Proceed
      if(caseIdList.isEmpty())
        return;
        
      // Get The Related Case List
      relatedCaseList = [Select c.Id, c.Third_SLA_Start_Time__c, c.Third_SLA_Scheduled_Time__c, c.Current_SLA_Phase__c, c.Third_SLA_Response_Time__c, 
                         c.Second_SLA_Response_Time__c, c.First_SLA_Response_Time__c From Case c where c.Id IN: caseIdList];
      // Create CaseId-Case Map
      for(case relatedCase: relatedCaseList){
        caseIdCaseMap.put(relatedCase.Id, relatedCase);
      }
                         
      // Check If Related Case Has Passed 1st and 2nd SLA Process.
      if(Trigger.isInsert){
        for(Event caseEvent: Trigger.new){
            // If Event 3rd SLA
            if('SLA - 3'.equalsIgnorecase(caseEvent.Event_Type__c)){
                
                // Get Related Case and Check SLA Status
                Case parentCase = caseIdCaseMap.get(caseEvent.WhatId);
                if(parentCase.First_SLA_Response_Time__c==null || parentCase.Second_SLA_Response_Time__c==null){
                    caseEvent.addError('Event Cannot Be Created. Parent Case Has Not Reached The 3rd SLA Stage.');
                }
            }
         }
      } // End Of Insert 
    }      
}