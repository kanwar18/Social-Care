/*** 
 * Class Name: Social_massCaseCloseController
 * Author: Accenture
 * Date: 29-July-2015
 * Requirement/Project Name: Consumer
 * Requirement Description: Class is responsible mass closing the cases. 
**/

public class Social_massCaseCloseController {
    private ApexPages.StandardSetController standardController;
    Set<Id> userIdSet = new Set<Id>();
    
    Public String errorMessage{get;set;}
    Public String returnURL{get;set;}
    Public String confirmationMessage{get;set;}
    Public String severity{get;set;}
    Public String caseReason{get;set;}
    Public String caseStringMsg ='';
    Public String hasHaveText = '';
    
    Public Boolean displayCaseDetails{get;set;}
    Public Boolean enableUIError{get;set;}
    Public Boolean enableDataTableSuccess{get;set;}
    Public Boolean enableDataTableFailed{get;set;}
    Public Boolean enableContinueMassClose{get;set;}
    Public Boolean showConfirmButton{get;set;}
    
    Public List<Case> selectedCases = new List<Case>();
    Public List<Case> doNotMeetMassCloseCriteriaList{get;set;}
    Public List<Case> caseListToMassClose = new List<Case>();
    Public List<Case> meetMassCaseCloseList{get;set;}
    
    /**
    * < Social_massCaseCloseController - CONSTRUCTOR>
    */
    
    public Social_massCaseCloseController(ApexPages.StandardSetController standardController) {
        enableDataTableSuccess = false;
        enableDataTableFailed = false;
        showConfirmButton = true;
        enableContinueMassClose = false;
        String confirmMessageSubString = '';
        this.standardController = standardController;
        selectedCases = (List<Case>) standardController.getSelected();
        List<PermissionSetAssignment> permissionSetAssignmentList = [Select AssigneeId From PermissionSetAssignment where AssigneeId=: userInfo.getUserId() and PermissionSetId=: system.Label.MassCaseClosePermissionSetId];
        returnURL = ApexPages.currentPage().getParameters().get('retURL');
        enableUIError = true;
        if (permissionSetAssignmentList.isEmpty()) {
            errorMessage = 'You do not have permission to Mass Close Cases.';
            displayCaseDetails = false;
        } else if (selectedCases.isEmpty()) {
            errorMessage = 'Please select at least one record from the list.';
            displayCaseDetails = false;
        } else {
            if (selectedCases.size() == 1) {
                confirmMessageSubString = ' case';
            } else {
                confirmMessageSubString = ' cases';
            }
            displayCaseDetails = true;
            severity = 'Confirm';
            confirmationMessage = '<font size="2px"><b>You are about to close ' + selectedCases.size() + confirmMessageSubString + '. Please select appropriate Case Reason value from the dropdown and click on Confirm button to Close the cases.<br/><br/>Once confirmed Cases will be Closed.</b></font>';
        }
    }
    
    /**
    * < massCaseClose() - Method to mass close cases>
    * @param:
    *       
    * @return - void
    * @see - Social_massCaseClose (VisualForce Page)
    */

    public void massCaseClose() {
        meetMassCaseCloseList = new List<Case>();
        doNotMeetMassCloseCriteriaList =  new List<Case>();  
        if (caseReason == '--None--') {
            enableUIError = true;
            severity = 'error';
            confirmationMessage = '<font size="2px"><b>Please select appropriate Case Reason to proceed.</b></font>';
        } else {
            for (Case caseObj: [Select Status,OwnerId,Case_Assigned_Time__c,CaseNumber,Reason,RecordTypeId from case where Id IN: selectedCases]) {
                if (caseObj.Status.equalsIgnoreCase('New') && caseObj.Case_Assigned_Time__c == Null && string.ValueOf(caseObj.ownerId).startsWith('00G') &&(caseObj.recordTypeId == system.label.ConsumerCareCase || caseObj.recordTypeId == system.label.Consumer_Care_Email_Case || caseObj.recordTypeId == system.label.ManualCareCaseRT)) {
                    caseObj.Status = 'Closed';
                    caseObj.Reason = caseReason;
                    caseObj.Case_Reason_HSRep__c = caseReason;
                    caseObj.Track_Case_Queue__c = caseObj.ownerId;
                    caseListToMassClose.add(caseObj);
                    meetMassCaseCloseList.add(caseObj);
                } else {
                    doNotMeetMassCloseCriteriaList.add(caseObj);
                }
            }
            if (doNotMeetMassCloseCriteriaList.isEmpty()) {
                if(caseListToMassClose.size() == 1){
                    caseStringMsg = ' Case meeting the mass close criteria has been closed.';  
                     
                } else {
                    caseStringMsg = ' Cases meeting the mass close criteria have been closed.';
                }
                enableUIError = true;
                enableDataTableSuccess = true;
                enableDataTableFailed = false;
                showConfirmButton = false;
                enableContinueMassClose = false;
                severity = 'confirm';
                confirmationMessage = '<font size="2px"><b>Selected '+ selectedCases.size() + caseStringMsg +'<br/><br/> Below tables shows the cases which were Mass Closed.</b></font>';
                Social_CaseAssignmentUtility.executeTriggerCode = false;
                Social_StreamingUtil.doNtFireEmail2CaseRun = false;
                Social_StreamingUtil.updateSObject(caseListToMassClose,'Class:Social_massCaseCloseController Method:massCaseClose');        
            } else {
                enableUIError = true;
                severity = 'error';
                enableDataTableSuccess = false;
                enableDataTableFailed = true;
                showConfirmButton = false;
                enableContinueMassClose = true;
                if(caseListToMassClose.isEmpty()){
                    enableContinueMassClose = false;
                }
                confirmationMessage = '<font size="2px"><b>You cannot Mass Close below mentioned cases because they do not meet Mass Close criteria. Criteria for Mass Close :<br/> &nbsp;&nbsp; - Case Status should be New. <br/> &nbsp;&nbsp; - Case Owner should be a Queue.<br/> &nbsp;&nbsp; - Case should not be assigned to User even once. <br/> &nbsp;&nbsp; - Case should be a Consumer Case.<br/><br/>To continue to Mass Close the remaining Cases, click on the "Mass Close remaining Cases" button.</b></font>';
            }   
        }
    }
    
    public void continueMassCaseClose(){
        if(caseListToMassClose.size() == 1){
            caseStringMsg = ' Case meeting the mass close criteria has been closed';  
                     
        } else {
            caseStringMsg = ' Cases meeting the mass close criteria have been closed';
        }
        enableUIError = true;
        enableDataTableSuccess = true;
        enableDataTableFailed = false;
        showConfirmButton = false;
        enableContinueMassClose = false;
        severity = 'confirm';
        confirmationMessage = '<font size="2px"><b>'+ caseListToMassClose.size() + caseStringMsg + '.<br/><br/> Below tables shows the cases which were Mass Closed.</b></font>';
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        Social_StreamingUtil.updateSObject(caseListToMassClose,'Class:Social_massCaseCloseController Method:massCaseClose');
    }
    
    /**
    * < getCaseReasonValue() - Method to get Mass Close values from case reason picklist>
    * @param:
    *       
    * @return - List<SelectOption> options
    * @see - Social_massCaseClose (VisualForce Page)
    */
    
    public List<SelectOption> getCaseReasonValue() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--','--None--'));
        Schema.DescribeFieldResult fieldResult = Case.Reason.getDescribe();
        for(Schema.PicklistEntry pickListValues : fieldResult.getPicklistValues()) {
            if (pickListValues.getValue().containsIgnoreCase('Mass Close')) {
                options.add(new SelectOption(pickListValues.getValue(),pickListValues.getValue()));
            }
        }    
        return options;
    }
}