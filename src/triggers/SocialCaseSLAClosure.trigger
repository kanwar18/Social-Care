/***********************************************************************************************************
*    Author : Arun Ramachandran
*    Version: 1.0
*    Purpose: To set the reminder off when the corresponding case associated to the SLA is closed
*    Created Date: 10th June 2013
*    Release 15th July: ITS-1545
*************************************************************************************************************/

trigger SocialCaseSLAClosure on Event (before update,before insert) {
    if (Social_StreamingUtil.doNtFireEmail2CaseRun) {
        Map<Id,List<Event>> caseSLAMap = new Map<Id,List<Event>>();
        Map<Id,Event> eventMap = new Map<Id,Event>();
        Map<Id,String> updateReasonCaseMap = new Map<Id, String>();
        if (trigger.isUpdate && trigger.isBefore) {
            for(Event caseEvent: Trigger.New){
                if(caseEvent.Event_Status__c!= Trigger.OldMap.get(caseEvent.ID).Event_Status__c && caseEvent.Event_Status__c=='Closed'){                  
                    if(caseSLAMap.containsKey(caseEvent.WhatId)){
                        caseSLAMap.get(caseEvent.WhatId).add(caseEvent);
                        updateReasonCaseMap.put(caseEvent.WhatId,'Update');
                    } else {
                        caseSLAMap.put(caseEvent.WhatId,new List<Event>{caseEvent});
                        updateReasonCaseMap.put(caseEvent.WhatId,'Update');
                    }
                } else {
                    updateReasonCaseMap.put(caseEvent.WhatId,'Update');
                }
            }      
        }
        if(trigger.isInsert && trigger.isBefore) {
            for (Event eventObj: trigger.New) {
                if (Social_StreamingUtil.EVENT_STATUS.equalsIgnoreCase(eventObj.Event_Type__c) && eventObj.WhatId != Null) {
                    eventMap.put(eventObj.WhatId,eventObj);
                    updateReasonCaseMap.put(eventObj.WhatId,'Insert');
                } else {
                    updateReasonCaseMap.put(eventObj.WhatId,'Insert');
                }
            }
        }
        if(!updateReasonCaseMap.isEmpty() && Social_StreamingUtil.doNotFireUpdateReason){
            Social_SocialPostSCSHandler.caseUpdateReasonEventAction(updateReasonCaseMap);
        }
        if(caseSLAMap.size()>0){
            Social_caseActivityHandler.setReminderOff(caseSLAMap);   
        }
        if (!eventMap.KeySet().isEmpty()) {
            Social_SocialPostSCSHandler.doNotAllowEventCreation(eventMap);
        }
    }
}