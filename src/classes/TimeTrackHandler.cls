public class TimeTrackHandler {
    public TimeTrackHandler() {}
    
    //method which is called in the appropriate trigger places
    public static void doUpdateTimeTracks(SObject[] objectArr, String transactionType) {
        Set<Id> caseIdSet = new Set<Id>();
        try {
            for(SObject sobjectObj : objectArr) {
                caseIdSet.add((Id) sobjectObj.get('Id'));
            }
            if(!caseIdSet.isEmpty()) {
                updateTimerRecords(caseIdSet, transactionType);
            }   
        } catch(DMLException dml) {
            TimeTrackUtility.doPrintExceptionMsg(dml);
        } catch(Exception excep) {
            TimeTrackUtility.doPrintExceptionMsg(excep);
        }
    }
    
    //method used to update the timer records
    public static void updateTimerRecords(Set<Id> caseIdSet, String transactionType) {
        Map<String, TimerTrack__c> trackerMap = new Map<String, TimerTrack__c>();
        String concatedCaseAndUser = '';
        List<TimerTrack__c> timerList = new List<TimerTrack__c>();
        User userObj = null;
        List<Case> caseList = new List<Case>();
        
        try {
            userObj = TimeTrackHelper.getCurrentUserInfo();
            
            if(null != caseIdSet && !caseIdSet.isEmpty() && null != userObj.Id) {
                caseList = 
                    [Select Id, Status, LastModifiedById, CM_Last_Modified_Section__c,Update_Reason__c, LastModifiedBy.Availability__c, (
                        Select Id, Transaction_End_Date__c, Transaction_Type__c,
                        CreatedDate, CreatedById, User_Availability_Status__c from TimerTracks__r 
                        Where CreatedDate = Today and CreatedById = :userObj.Id order by CreatedDate Desc Limit 1) 
                        from Case Where Id IN :caseIdSet];
                        
                        
  
                if(caseList != null && !caseList.isEmpty()) {
                    for(Case caseObj : caseList) 
                    {
                        timerList = caseObj.timerTracks__r;
                        if(timerList != null && !timerList.isEmpty()) {
                            for(TimerTrack__c timerTrackObjLoc : timerList) {
                                concatedCaseAndUser = caseObj.lastModifiedById +'|'+ caseObj.Id;
                                if((timerTrackObjLoc.createdById == caseObj.LastModifiedById) && (null == trackerMap.get(concatedCaseAndUser))) {
                                    timerTrackObjLoc.Transaction_Type__c = transactionType;
                                    timerTrackObjLoc.Transaction_End_Date__c = DateTime.now();
                                    timerTrackObjLoc.User_Availability_Status__c = caseObj.LastModifiedBy.Availability__c;
                                    timerTrackObjLoc.Case_Status__c = caseObj.Status;
                                    trackerMap.put(concatedCaseAndUser, timerTrackObjLoc);
                                    
                                }
                                system.debug('aaaaa'+timerTrackObjLoc.User_Availability_Status__c);                                 
                            }
                        } //end for if  
                    } //end for 'for' loop     
                } //end for if
                
            }
            
            if(TimeTrackUtility.doValidUserAvailabilityStatus() && system.label.Timertrackaceess.containsIgnoreCase(userObj.Profile.Name)) {
                if(!trackerMap.isEmpty()) {
                    Social_CaseAssignmentUtility.executeTriggerCode = false;
                    update trackerMap.values();
                }
            }
        } catch(Exception excep) {
             TimeTrackUtility.doPrintExceptionMsg(excep);
        }
    }
}