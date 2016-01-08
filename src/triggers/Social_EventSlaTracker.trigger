trigger Social_EventSlaTracker on Event (after insert, after update) 
{
    if (Social_StreamingUtil.doNtFireEmail2CaseRun) {
  // Variable Declaration
  List<Id> caseIdList = new List<Id>();
  List<case> updateCaseList = new List<case>();
  Map<Id,Case> caseIdCaseMap = new Map<Id,Case>();
  Map<Id,List<Event>> eventCaseMap = new Map<Id,List<event>>();
  Set<Id> caseWhatId = new Set<Id>();
  Map<Id,Case> caseEMap = new Map<Id,Case>();
  Id bsCaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Case'); // Stores record type id of Business Care Closed case Record Type
  Id bsCloseCaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Closed Case'); // Stores record type id of Business Care Closed case Record Type
  List<Event> deleteEvent = new List<Event>();  
  
  
  // Get All Related Case Ids
    for(Event caseEvent: Trigger.new){
        
     // Capture Only 3rd SLA Events
        if('SLA - 3'.equalsIgnorecase(caseEvent.Event_Type__c)){
                
            // Event Insert
            if(Trigger.isInsert && 'Open'.equalsignorecase(caseEvent.Event_Status__c)){
                caseIdList.add(caseEvent.WhatId);
            }
            
            
            // Event Update
            if(Trigger.isUpdate){
                
                // Get Old Event Instance
                Event oldEvent = Trigger.oldMap.get(caseEvent.Id);
                
                // Check For Event Status Update
                if(oldEvent!=null && caseEvent.Event_Status__c!=null && caseEvent.Event_Status__c!=oldEvent.Event_Status__c && 'Closed'.equalsignorecase(caseEvent.Event_Status__c)){
                    caseIdList.add(caseEvent.WhatId);
                }
            }
        }
        if(trigger.IsInsert){
            if(eventCaseMap.containsKey(caseEvent.WhatId)){
                eventCaseMap.get(caseEvent.WhatId).add(caseEvent);            
            }
            else{
                eventCaseMap.put(caseEvent.WhatId,new List<Event>{caseEvent});
            }
        }

    }
    
    for(Case singleCase:[Select Id, OwnerId,Current_SLA_phase__c from Case where Id IN: eventCaseMap.keySet() AND (RecordTypeId =: bsCaseRecordTypeId OR RecordTypeId =: bsCloseCaseRecordTypeId)]){
        if((singleCase.OwnerId == System.Label.ESCALATION_BC_QUEUE || singleCase.OwnerId == System.Label.GENERAL_BC_QUEUE) && singleCase.Current_SLA_phase__c == 'SLA1 - Ended' ){
            caseEMap.put(singleCase.Id,singleCase);
        }
    }
    system.debug('EEEEEE'+caseEMap);
    
    for(Id str: caseEMap.keySet()){
        for(Event singleEvent: eventCaseMap.get(str)){
            if(singleEvent.Event_Status__c == 'Open'){
                deleteEvent.add(singleEvent);
                Social_StreamingUtil.deleteSLAsetId.add(singleEvent.Id);
            }
        }
    }
    system.debug('TTTTT'+deleteEvent);
    
    
    if(deleteEvent.size()>0){
        try{
            delete deleteEvent;
        }
        catch(DMLException e){
            system.debug('Error thrown while deleting SLA: '+e);
        }
    }
    //Track Event changes on a case
    Map<Id, String> caseMap =  new Map<Id, String>();
    for(Event caseEvent: Trigger.new){
        if(Trigger.isInsert){
            caseMap.put(caseEvent.WhatId, 'Insert');
        }
        if(Trigger.isUpdate){
            caseMap.put(caseEvent.WhatId, 'Update');            
        }
    }
    if(caseMap!=null && !caseMap.isEmpty()){
        SocialStreamingAPIUpdate.caseEventInsertUpdate(caseMap);
    }
  
  
  
  
  // Check To Proceed
  if(caseIdList.isEmpty())
    return;
  
  // Get The Related Case List
  List<case> relatedCaseList = [Select c.Id, c.Third_SLA_Start_Time__c, c.Third_SLA_Scheduled_Time__c, c.Current_SLA_Phase__c, c.Third_SLA_Response_Time__c 
                                From Case c where c.Id IN: caseIdList];
  
  // Create Case Map
  for(Case request: relatedCaseList){
    caseIdCaseMap.put(request.Id, request);
  }
                     
                     
  // Update The Case With TimeStamp/SLA Status
    for(Event caseEvent: Trigger.new){
    
    // Get Related Case
    Case parentCase = caseIdCaseMap.get(caseEvent.WhatId);
    
        if(parentCase!=null){
            
            // Event Insert (SLA-3 Start)
            if(Trigger.isInsert){
                
                // Update Case
                parentCase.Third_SLA_Start_Time__c = caseEvent.StartDateTime;
                parentCase.Third_SLA_Scheduled_Time__c = caseEvent.EndDateTime;
                parentCase.Current_SLA_Phase__c = 'SLA3 - Initiated';
            }
            
            // Event Update (SLA-3 End)
            if(Trigger.isUpdate){
                
                // Update Case
                parentCase.Third_SLA_Response_Time__c = datetime.now();
                parentCase.Current_SLA_Phase__c = 'SLA3 - Ended';
            }
            
            // Add Case To List
            updateCaseList.add(parentCase);
        }
    }

  // DataBase Operations
    if(!relatedCaseList.isEmpty()){
        try{
            update updateCaseList;
        }
        catch(Exception Exp){
            System.debug('EXCEPTION DURING SLA-3 CASE UPDATE:'+ Exp.getmessage());
        }
    }
    
   } 
}