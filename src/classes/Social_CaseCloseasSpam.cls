/****
This Class is used as controller to close a case as a spam case.
***/
public class Social_CaseCloseasSpam{

    public case mcase{get;set;}
    public List<case> lcse=new list<Case>();
    public Map<Id, Map<String, List<Event>>> caseEventMap = new Map<Id, Map<String, List<Event>>>();
    public string errorstring{get;set;}
    public pagereference pageref;
    public Id cid{get;set;}
    public List<User> luser=new list<user>();
    Social_CaseEmailInBoundUtilities socinb=new Social_CaseEmailInBoundUtilities();
    public string userProfileId = UserInfo.getProfileId();
    
    /*** The default constructor for the VF page **/
    public Social_CaseCloseasSpam(apexpages.standardcontroller controller){
        mcase=(Case)controller.getrecord();
        cid = ApexPages.currentPage().getParameters().get('id');
    }
    
    /**
        * < Closeasspam() - Method to close cases as spam on the click on custom button on page layouts.
        * @param:
        * Void
        * 
        * @return - Pagereference.
        * @see - Close Case as Spam(Custom Button)
        */
    public pagereference Closeasspam() {
        lcse = [select id, RecordType.Name, Case_Reason_HSRep__c, status, Current_SLA_Phase__c, ownerid, Case_PostTag__c,Customer_Type__c,Root_Cause__c,Effort__c,Reason,Clarify_CRM_Verified__c,Component_Primary__c,Social_Media_Source__c,Component_Secondary__c from case where id=:cid limit 1];
        if(null!=lcse && lcse.size()>0) {
            lcse[0].status = Social_StreamingUtil.CASE_STATUS_CLOSED;
            if(lcse[0].Customer_Type__c == null || (lcse[0].Customer_Type__c).equals('')){
                lcse[0].Customer_Type__c = Social_StreamingUtil.CASE_CUSTOMER_TYPE_NON_CUSTOMER;
            }
            if(lcse[0].Case_PostTag__c == null || (lcse[0].Case_PostTag__c).equals('')){
                lcse[0].Case_Post_Tag__c = Social_StreamingUtil.CASE_POSTTAG_GENERAL;
            }
            if(lcse[0].Root_Cause__c == null || (lcse[0].Root_Cause__c).equals('')){
                lcse[0].Root_Cause__c = Social_StreamingUtil.CASE_ROOT_CAUSE_UNWANTED_SOLICITATION;
            }
            if(lcse[0].Effort__c == null || (lcse[0].Effort__c).equals('')){
                lcse[0].Effort__c = Social_StreamingUtil.CASE_EFFORT_NON_ACTIONABLE;
            }
            if(lcse[0].Clarify_CRM_Verified__c == null || (lcse[0].Clarify_CRM_Verified__c).equals('')){
                lcse[0].Clarify_CRM_Verified__c = Social_StreamingUtil.CASE_CM_VARIFIED_NO;
            }
            lcse[0].Close_Case_as_SPAM_indicator__c = true;
            lcse[0].Closed_Care_Manager__c = Userinfo.Getuserid();
            lcse[0].Closed_Operation_Manager__c = getRelatedOperationManager(lcse[0].OwnerId);
            if(userProfileId!=null && !String.valueOf(userProfileId).equals('') && null!=lcse[0].Case_PostTag__c && ((String.ValueOf(lcse[0].Case_PostTag__c).toUpperCase()).contains('U-VERSE') || (String.ValueOf(lcse[0].Case_PostTag__c).toUpperCase()).contains('WIRELESS'))){
                if(String.ValueOf(lcse[0].Case_PostTag__c).toUpperCase().contains('U-VERSE') && (lcse[0].Component_Primary__c == null || (lcse[0].Component_Primary__c).equals(''))){
                    lcse[0].Component_Primary__c = 'U-verse'; 
                } else if(String.ValueOf(lcse[0].Case_PostTag__c).toUpperCase().contains('WIRELESS') && (lcse[0].Component_Primary__c == null || (lcse[0].Component_Primary__c).equals(''))){
                    lcse[0].Component_Primary__c = 'Wireless';
                }
                if(lcse[0].Component_Secondary__c == null || (lcse[0].Component_Secondary__c).equals('')){
                    lcse[0].Component_Secondary__c = 'Unknown';
                }
            } else {
                if(lcse[0].Component_Primary__c == null || (lcse[0].Component_Primary__c).equals('')){
                    lcse[0].Component_Primary__c = Social_StreamingUtil.CASE_PRIMARY_COMPONENT_UNKNOWN; 
                }
                if(lcse[0].Component_Secondary__c == null || (lcse[0].Component_Secondary__c).equals('')){
                    lcse[0].Component_Secondary__c = Social_StreamingUtil.CASE_PRIMARY_COMPONENT_UNKNOWN; 
                }
            }
            //Logic to populate case reason home solution for DTV users
            if (lcse[0].Reason == null && userInfo.getProfileId().subString(0,15).equalsIgnoreCase(System.Label.DTVProfileId)) {
                lcse[0].Case_Reason_HSRep__c = 'No Outreach';     
            }
            if(lcse[0].Reason == null || (lcse[0].Reason).equals('') && !(lcse[0].RecordType.Name).equalsIgnoreCase('HS Care Rep')){
                lcse[0].Reason = 'No Outreach';
            } else if(lcse[0].Case_Reason_HSRep__c == null || (lcse[0].Case_Reason_HSRep__c).equals('') && (lcse[0].RecordType.Name).equalsIgnoreCase('HS Care Rep')){
                lcse[0].Case_Reason_HSRep__c = 'No Outreach'; 
            }
            for(Event caseEvent: [Select e.WhatId, e.OwnerId, e.Id, e.Event_Type__c, e.Event_Status__c From Event e where e.WhatId =:lcse[0].id]){
                if(caseEventMap.containsKey(caseEvent.WhatId)){
                    // Get Related Event Type:Event List Map
                    Map<String, List<Event>> existMap = caseEventMap.get(caseEvent.WhatId);
                    // Check Event Type Exist
                    if(existMap.containsKey(caseEvent.Event_Type__c)){
                        List<Event> existingEventList = existMap.get(caseEvent.Event_Type__c);  
                        existingEventList.add(caseEvent);
                        existMap.put(caseEvent.Event_Type__c, existingEventList);
                    } else {
                        List<Event> newEventList = new List<Event>();
                        newEventList.add(caseEvent);
                        existMap.put(caseEvent.Event_Type__c, newEventList);
                    }
                    // Set The CaseId:Event Map
                    caseEventMap.put(caseEvent.WhatId, existMap);
                } else {
                    // Create New String:Event List Map
                    Map<String, List<Event>> newMap = new Map<String, List<Event>>();
                    List<Event> newEventList = new List<Event>();
                    // Put The Event Data
                    newEventList.add(caseEvent);
                    newMap.put(caseEvent.Event_Type__c, newEventList);
                    caseEventMap.put(caseEvent.WhatId, newMap);
                }                         
            }
            String slaType='';
            // Automated SLA End On Case Closure (SLA-1 Closure)
            if('SLA1 - Initiated'.equalsignorecase(lcse[0].Current_SLA_Phase__c)){
                lcse[0].Current_SLA_Phase__c = 'SLA1 - Ended';                     
                lcse[0].First_SLA_Response_Time__c = datetime.now();
                slaType= 'SLA - 1';
            }
            // (SLA-2 Closure)
            else if('SLA2 - Initiated'.equalsignorecase(lcse[0].Current_SLA_Phase__c)){
                lcse[0].Current_SLA_Phase__c = 'SLA2 - Ended';                     
                lcse[0].Second_SLA_Response_Time__c = datetime.now();
                slaType= 'SLA - 2';
            }
            // (SLA-3 Closure)
            else if('SLA3 - Initiated'.equalsignorecase(lcse[0].Current_SLA_Phase__c)){
                lcse[0].Current_SLA_Phase__c = 'SLA3 - Ended';                     
                lcse[0].Third_SLA_Response_Time__c = datetime.now();
                slaType= 'SLA - 3';
            }
            // Private Method For Event Closure
            closeSlaEvent(lcse[0].Id,slaType);  
            Social_StreamingUtil.updateSObject(lcse, 'Failed to close case as spam,class : Social_CaseCloseasSpam and method : Closeasspam');
            if(luser[0].Case_Counter__c > 0){
               luser[0].Case_Counter__c=luser[0].Case_Counter__c-1;
            }
            Social_StreamingUtil.updateSObject(luser, 'Failed to update case counter on user while closing case as spam,class : Social_CaseCloseasSpam and method : Closeasspam');
        }
        pageref=new PageReference('/'+cid);
        return pageref;
    }
    
    /**
        * < getRelatedOperationManager(Id userId) - Method used to get the operation manager id for the case owner closing the case as spam.
        * @param: Userid the case ownerid
        *     * 
        * @return - string . The operation manager id
        * @see - Closeasspam(MEthod same class)
        */ 
    public String getRelatedOperationManager(Id userId){
    
    string managerid=null;
    
       if(!string.isblank(userid)){
        luser= [Select Name, ManagerId, Manager.Email, Id,Case_Counter__c From User where IsActive=true and id=:userId limit 1];
        system.debug('GGGGGGGGGG' + luser);
        if(luser.size()>0){
            managerid=(luser[0].ManagerId);}
       }     
        return managerid;    
      }
      
    /**
        * < closeSlaEvent(Id CaseId, String slaType) - Method used to close the SLA events for the case being closed as spam
        * @param: the case id and the SLA type for closing the events
        *     * 
        * @return - void 
        * @see - Closeasspam(MEthod same class)
        */
     private void closeSlaEvent(Id CaseId, String slaType){
          errorstring='';
     if(caseEventMap.get(CaseId)!=null && caseEventMap.get(CaseId).get(slaType)!=null){
            List<Event> updateEventList = new List<Event>();
            List<Event> closeEventList = caseEventMap.get(CaseId).get(slaType);
            for(Event caseEvent: closeEventList){
                caseEvent.Event_Status__c = 'Closed';
            }
            updateEventList.addAll(closeEventList);
    
       if(updateEventList.size()>0){
           Database.SaveResult[] resultDB = database.update(updateEventList, false);
                   try{
                        Integer loopCount = 0;
                        for(Database.SaveResult sr:resultDB){               
                            if(!sr.isSuccess()){                    
                                Database.Error err = sr.getErrors()[0];
                                errorString = errorstring+ 'Error while Closing Case as Spam. ' +updateEventList.get(loopCount).getSObjectType() + ' ' + err + '\n';                     
                            }
                            loopCount++;
                        }
                        if(!string.isblank(errorstring)){
                        //socinb.CreateExceptionObject(errorString); 
                        }               
                     }
                 catch(Exception e){
                 System.debug('Error handling Response. ' + e.getMessage());
                // socinb.CreateExceptionObject(e.getMessage());
                }
       }     
      }
     }    
}