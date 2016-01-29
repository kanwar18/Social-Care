/********************************************************************************************************
*    Author :     Accenture
*    Requirement: Forsee Trigger
*    Version:     1.0 Aditya - Added custom label to specify time limit for forsee resend.
*    Version:     1.1 Haemen - Added Custom label to not not sent forsee if Primary component is  "WIreless"
*********************************************************************************************************/
trigger SocialForseeTrigger on Case (after update) {
    if(Social_StreamingUtil.doNtFireEmail2CaseRun && (Boolean.valueOf(Label.Deactivate_Case_Triggers))) {      
        SocialCareForseeHandler socialCareHandler = null;
        Set<Id> caseIdSet = null;
        boolean isRadianFlag = false;
        Set<String> profileIdsDoNotSendForsee = new Set<String>();//Set to store profile ids specified in custom label.
        String profileIds = label.NonForseeProfileId ;//String for getting ids from custom label.
        if(profileIds != Null) {
            profileIdsDoNotSendForsee.addAll(profileIds.split(';'));
        }
        //If flag value is True then execute Trigger
        //Aditya: Added additional check for not sending the forsee form to general care manager profile users.
        if(String.Valueof(System.label.Enable_Trigger_SocialForseeTrigger)!=null && String.Valueof(System.label.Enable_Trigger_SocialForseeTrigger).equalsIgnoreCase('True') && !profileIdsDoNotSendForsee.isEmpty() && !profileIdsDoNotSendForsee.Contains(userInfo.getProfileId()) ){
            if(Trigger.isUpdate) {
                socialCareHandler = new SocialCareForseeHandler();
                caseIdSet = new Set<Id>();
                for(Case caseObj : Trigger.New) {
                    
                    // Get Old Case 
                    Case oldCase = Trigger.oldMap.get(caseObj.Id);
                    
                    // Check Status
                    if(oldCase!=null && oldCase.Status!=caseObj.Status && CheckCase(Label.Foresee_Case_Reasons,caseObj.Reason) && CheckCase(Label.Foresee_Case_Status,caseObj.Status)){
                        caseIdSet.add(caseObj.Id);
                    }

                     if(!isRadianFlag && (caseObj.LastModifiedById == '005E0000002G4RU')) {
                        isRadianFlag = true;
                    }  
 
                } //end for new
                
                if(caseIdSet.size() != 0){
                    // Fetch All Case Ids (Contact Has No Open Cases/No Foresee Past 48 Hours)
                    caseIdSet = fetchCaseIds(caseIdSet);
                    // Call Util Class Method
                    socialCareHandler.generateForSeeUrls(caseIdSet);
                }                                            
            }
         }
         if(Social_CaseAssignmentUtility.executeTriggerCode && !isRadianFlag && (Boolean.valueOf(Label.ACTIVATE_TIMER_APP)) && String.Valueof(System.label.Enable_Trigger_SocialForseeTrigger)!=null && String.Valueof(System.label.Enable_Trigger_SocialForseeTrigger).equalsIgnoreCase('True')) {
                TimeTrackHandler.doUpdateTimeTracks(Trigger.New, 'Case Update');
         } 
    }
        //A method which handles foresee URL sending at the Contact level
        private Set<Id> fetchCaseIds(Set<Id> caseIdsSet) {
            Set<Id> modifiedCaseObjIdSet = new Set<Id>();
            Set<Id> contactObjIdSet = new Set<Id>();
            
            List<Case> caseList = new List<Case>();
            List<Contact> contactList = new List<Contact>();
            boolean urlSendFlag = false;
            Forsee_Survey__c forseeObj = null;
            List<Contact> modifiedContactList = new List<Contact>();
            
            try {
                System.debug('Hai :'+caseIdsSet);
                //Block to get the contactId's
                for(Case caseObj : [Select Id, Contact.Id from Case Where Id In :caseIdsSet]) {
                    if(null != caseObj.Contact.Id) {
                        contactObjIdSet.add(caseObj.Contact.Id);
                    }
                }
                
                //Block to get the associated Cases and their lastest Foresee URL
                if(!contactObjIdSet.isEmpty()) {
                    contactList = 
                    [
                        Select Id, LastName, 
                        (Select Id, CaseNumber, Status from Cases), 
                        (Select Id, Forsee_URL__c,Sent_In_48_Hours__c, URL_Sent_Date__c,CreatedDate 
                        from Forsee_Surveys__r Order by CreatedDate desc Limit 1) 
                        from Contact Where Id In :contactObjIdSet
                    ];
                    
                    //Check for Contact
                    for(Contact contactObj : contactList) {
                        urlSendFlag = false;
    
                        //Check for foreseeURL
                        forseeObj = (((contactObj.Forsee_Surveys__r) != null)&&(!contactObj.Forsee_Surveys__r.isEmpty()))? 
                            contactObj.Forsee_Surveys__r.get(0) : null; 
                        
                        if(null != forseeObj) {
                            if(forseeObj.CreatedDate.addMinutes(Integer.valueOf(Label.ForseeSurveyTime)) <= DateTime.now()) {
                                urlSendFlag = true; 
                            } else {
                                break;
                            }
                            System.debug('Url send flag :'+urlSendFlag);
                        } else {
                            urlSendFlag = true;
                        }
                        
                        //Check for 'Closed' & 'Auto Closed' cases
                        if(urlSendFlag) {
                            for(Case caseObj : contactObj.Cases) {
                                if(!CheckCase(Label.Foresee_Case_Status,caseObj.Status)) {
                                    urlSendFlag = false;
                                    break;
                                }
                            }
                            if(urlSendFlag) {
                                modifiedContactList.add(contactObj);
                            }
                        }
                    } //End for Contact
                    for(Contact contactObj : modifiedContactList) {
                        for(Case caseObj : contactObj.Cases) {
                            if(caseIdsSet.contains(caseObj.Id)) {
                                modifiedCaseObjIdSet.add(caseObj.Id);
                            }
                        }
                    }
                    System.debug('Hello:'+modifiedCaseObjIdSet);
                }
            } catch(DMLException dmlExcep) {
                System.debug('DML Exception Caught :'+dmlExcep.getMessage());
            } catch(Exception excep) {
                System.debug('Exception Caught :'+excep.getMessage());
            }
            return modifiedCaseObjIdSet;
        }
        
        /*
        // Method To Check Case Closure Reason For ForeSee Generation
        private boolean CheckcaseclosureReason(String closeReason){
            
            //Split Case Reason Label
            if(Label.Foresee_Case_Reasons!=null && closeReason!=null){
                
                Set<String> caseReasonList = new Set<String>(Label.Foresee_Case_Reasons.split(';'));
                if(caseReasonList.contains(closeReason.trim())){
                    return true;
                }
            }
            return false;
        } */

        // Method To Check Case Status
        private boolean CheckCase(String labelValue, String str){
            if(labelValue != null && str != null){
                Set<String> labelValueList = new Set<String>(labelValue.split(';'));
                if(labelValueList.contains(str.trim())){
                    return true;
                }
            }
            return false;
        }
    
}