/********************************************************************************************************
*    Author :     Accenture
*    Requirement: To reset DNR on all the cases.
*    Version:     1.0
*    Created Date: 10th September 2015.
*    Updated Date : 10th September 2015.
*    Requirement : ITS 1726
*    Updated By : Aditya Kumar
*********************************************************************************************************/

Public Class Social_DNRRestPageController {
    Public String errorMessage{get;set;}//String to display alert message on page
    Public String returnURL{get;set;}//String to hold return URL
    Public Boolean isBusinessUser;//Boolean to check if login in user is business or consumer
    private ApexPages.StandardSetController standardController;//standard controller
    Public List<Case> selectedCases = new List<Case>();//List to hold selected cases
    Public List<Case> caseListToResetDNR = new List<Case>();//List to update cases
    
    /*************Constructor*************/
    
    public Social_DNRRestPageController(ApexPages.StandardSetController standardController) {
        errorMessage = '';
        returnURL = ApexPages.currentPage().getParameters().get('retURL');
        isBusinessUser = false;
        this.standardController = standardController;
        selectedCases = (List<Case>) standardController.getSelected();
        Profile profileName = [Select Id,Name from Profile where Id =: userInfo.getProfileId()];
        if (profileName.Name.containsIgnoreCase('Business')) {
            errorMessage = 'You do not have permission to access this button.';
            isBusinessUser = true;
        }else if (!returnURL.contains(SYSTEM.LABEL.MassDNRListview)){
            errorMessage = 'Please select "My Do Not Reassign (DNR) Cases" List View to reset DNR on the cases owned by you.';
        }else if (selectedCases.isEmpty()) {
            errorMessage = 'Please select at least one record from the list.';
        }
    }        
    
    /**
    * < resetDNROnCase() - Method to reset DNR on cases>
    * @param:       
    * @return - void
    * @see - Social_DNRRestPage (VF Page)
    */
        
    Public void resetDNROnCase () {
        if (!isBusinessUser) {
            for (Case caseObj: [Select ownerId,Status,Do_Not_Reassign__c,DNR_End_Time__c,Do_Not_Reassign_Time__c,Do_Not_Reassign_Timeframe__c,RecordTypeId from case where Id IN: selectedCases]){
                if(((Social_StreamingUtil.CASE_STATUS_NEW.equalsIgnoreCase(caseObj.Status)) || (Social_StreamingUtil.CASE_STATUS_INVESTIGATING.equalsIgnoreCase(caseObj.Status)) || (Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK.equalsIgnoreCase(caseObj.Status)) || (Social_StreamingUtil.CASE_STATUS_PENDINGCLOSURE.equalsIgnoreCase(caseObj.Status)) || (Social_StreamingUtil.CASE_STATUS_REASSIGNED.equalsIgnoreCase(caseObj.Status)) || (Social_StreamingUtil.CASE_STATUS_ESCALATED.equalsIgnoreCase(caseObj.Status)) || (Social_StreamingUtil.CASE_STATUS_FOLLOWUPHOLD.equalsIgnoreCase(caseObj.Status)) || (Social_StreamingUtil.CASE_STATUS_REOPEN.equalsIgnoreCase(caseObj.Status))) && (caseObj.recordTypeId == system.label.ConsumerCareCase || caseObj.recordTypeId == system.label.Consumer_Care_Email_Case || caseObj.recordTypeId == system.label.ManualCareCaseRT || caseObj.recordTypeId == system.label.HS_Care_Rep_RT) && caseObj.Do_Not_Reassign__c && userinfo.getUserId()==caseobj.OwnerId){
                    caseobj.Update_Reason__c='';
                    caseObj.Do_Not_Reassign_Timeframe__c = null;
                    caseObj.DNR_End_Time__c = null;
                    caseObj.Do_Not_Reassign_Time__c = null;
                    caseObj.Do_Not_Reassign__c = false;
                    caseListToResetDNR.add(caseObj);
                }
            }
        }
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        if (!caseListToResetDNR.isEmpty()) {
            Social_StreamingUtil.updateSObject(caseListToResetDNR , 'Fail to Update DNR on cases, classname-Social_DNRRestPageController');
        }
    }
}