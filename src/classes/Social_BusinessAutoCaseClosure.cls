/********************************************************************************************************
*    Author :     Ashween Kaur
*    Requirement: Business Auto Case Closure (48 hours)
*    Version:     1.0
*    Created Date: 5th May, 2014
*********************************************************************************************************/
public class Social_BusinessAutoCaseClosure{
    
    public static void autoCloseCase(List<Case> autoCloseCaseList){ 
    List<Event> EventList= new list<Event>();   
        for(Case singleCase :autoCloseCaseList){
                singleCase.Status = 'Closed';
                singleCase.Clarify_CRM_Verified__c = singleCase.Clarify_CRM_Verified__c != null ? singleCase.Clarify_CRM_Verified__c : 'No';
                singleCase.Customer_Type__c = singleCase.Customer_Type__c != null ? singleCase.Customer_Type__c : 'Small Business';
                singleCase.Root_Cause__c = singleCase.Root_Cause__c != null ? singleCase.Root_Cause__c : 'No Response';
                singleCase.Effort__c = singleCase.Effort__c != null ? singleCase.Effort__c : 'Simple';
                singleCase.Reason = singleCase.Reason != null ? singleCase.Reason : 'Never Responded';
                singleCase.Component_Primary__c = singleCase.Component_Primary__c != null ? singleCase.Component_Primary__c : 'Unknown';
                singleCase.Component_2_Category__c = singleCase.Component_2_Category__c != null ? singleCase.Component_2_Category__c : 'Unknown';
                singleCase.RecordTypeId = System.Label.Business_Closed_RT;
            
            if(singleCase.Origin != NULL && (singleCase.Origin.equalsIgnoreCase('Email Business (BizHelp)') || singleCase.Origin.equalsIgnoreCase('Email Business (YouTube)'))){                
                singleCase.Social_Media_Source__c = singleCase.Social_Media_Source__c != null ? singleCase.Social_Media_Source__c : 'Bizhelp email';
            }
            else{
                 singleCase.Social_Media_Source__c = singleCase.Social_Media_Source__c != null ? singleCase.Social_Media_Source__c : 'Twitter';
            }
             if ('SLA1 - Initiated'.equalsIgnoreCase(singleCase.Current_SLA_Phase__c)) {
                 for(Event eventObjUpdate: [select WhatId from Event where Event_status__c = 'Open' and WhatId =: singleCase.id and Event_Type__c = 'SLA - 1']){
                    eventObjUpdate.Event_status__c = 'Closed';   
                    singleCase.Current_SLA_Phase__c = 'SLA1 - Ended' ; 
                    singleCase.First_SLA_Response_Time__c = datetime.now();           
                    EventList.add(eventObjUpdate);
                }       
            }
            else if ('SLA2 - Initiated'.equalsIgnoreCase(singleCase.Current_SLA_Phase__c)) {
                for(Event eventObjUpdate: [select WhatId from Event where Event_status__c = 'Open' and WhatId =: singleCase.id and Event_Type__c = 'SLA - 2']){
                    eventObjUpdate.Event_status__c = 'Closed'; 
                    singleCase.Current_SLA_Phase__c = 'SLA2 - Ended' ; 
                    singleCase.Second_SLA_Response_Time__c = datetime.now();                    
                    EventList.add(eventObjUpdate);
                }
            }
           if (!EventList.isEmpty()) {
            //update events
            Social_StreamingUtil.updateSObject(EventList,'Class:Social_BusinessAutoCaseClosure');                   
            }        
        }
    }
}