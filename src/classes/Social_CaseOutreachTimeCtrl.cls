/*** 
 * Class Name: Social_CaseOutreachTimeCtrl
 * Author: Accenture
 * Date: 9-August-2015
 * Requirement/Project Name: Consumer - Social Care
 * Requirement Description: This class will be responsible for calculating outreach time when CM makes an outreach  
**/

Public Class Social_CaseOutreachTimeCtrl {
    Public Social_CaseOutreachTimeCtrl () {}
    
   /**
    * < calculateOutreachTime () - Method to calculate outreach time>
    * @param:
    *     socialPostObj: Social post object
    *     caseObj: Case Object  
    * @return - String : outreachTimeInSec + '-' + isMultipleOutreach
    * @see -  (Social_SocialPostSCSHandler)   
    */
    
    Public Static String calculateOutreachTime(SocialPost socialPostObj,Case caseObj) {
        String outreachTimeInSec;//String to hold outreach time in seconds
        String isMultipleOutreach = 'false';//String to check if response is a multiple response to customer
        String calculatedOfFieldName = '';//String to store field name from which outreach time is getting calculated
        String valueInField;//variable to store field value
        String ValueInFieldtext; // Variable to store field value in GMT
        String dateTimeString = String.valueofGMT(system.now());
        socialPostObj.Time_of_Outreach__c = dateTimeString;
        //CASE NOT MARKED AS DNR
        if (caseObj.Do_Not_Reassign_Timeframe__c == Null) {
            //CASE FIRST ASSIGNMENT
            if (caseObj.Case_Reassigned_Time__c == Null && caseObj.Case_Assigned_Time__c != Null) {
                Double caseAssignedTime = caseObj.Case_Assigned_Time__c.getTime();
                Double currentTime = System.Now().getTime();
                Double milliSeconds = currentTime - caseAssignedTime;
                outreachTimeInSec = String.valueOf(milliSeconds/1000).subStringBefore('.');
                calculatedOfFieldName = 'Case Assigned Time';
                valueInField = string.ValueOf(caseObj.Case_Assigned_Time__c);
                ValueInFieldtext = string.ValueOfGMT(caseObj.Case_Assigned_Time__c);
            } else if (caseObj.Case_Reassigned_Time__c != Null) {
                Double caseReassignedTime = caseObj.Case_Reassigned_Time__c.getTime();
                Double currentTime = System.Now().getTime();
                Double milliSeconds = currentTime - caseReassignedTime;
                outreachTimeInSec = String.valueOf(milliSeconds/1000).subStringBefore('.');
                calculatedOfFieldName = 'Case Reassigned Time';
                valueInField = string.ValueOf(caseObj.Case_Reassigned_Time__c);
                ValueInFieldtext = string.ValueOfGMT(caseObj.Case_Reassigned_Time__c);
            }
        //CASE IS MARKED AS DNR
        } else {
            if (caseObj.Last_Outreach_Time__c == Null) {
                if (caseObj.Case_Reassigned_Time__c == Null && caseObj.Case_Assigned_Time__c != Null) {
                    Double caseAssignedTime = caseObj.Case_Assigned_Time__c.getTime();
                    Double currentTime = System.Now().getTime();
                    Double milliSeconds = currentTime - caseAssignedTime;
                    outreachTimeInSec = String.valueOf(milliSeconds/1000).subStringBefore('.');
                    calculatedOfFieldName = 'Case Assigned Time';
                    valueInField = string.ValueOf(caseObj.Case_Assigned_Time__c);
                    ValueInFieldtext = string.ValueOfGMT(caseObj.Case_Assigned_Time__c);
                } else if (caseObj.Case_Reassigned_Time__c != Null) {
                    Double caseReassignedTime = caseObj.Case_Reassigned_Time__c.getTime();
                    Double currentTime = System.Now().getTime();
                    Double milliSeconds = currentTime - caseReassignedTime;
                    outreachTimeInSec = String.valueOf(milliSeconds/1000).subStringBefore('.');
                    calculatedOfFieldName = 'Case Reassigned Time';
                    valueInField = string.ValueOf(caseObj.Case_Reassigned_Time__c);
                    ValueInFieldtext = string.ValueOfGMT(caseObj.Case_Reassigned_Time__c);
                }
            } else if (caseObj.Last_Outreach_Time__c != Null && caseObj.Customer_Response_Received__c == true) {
                //CHECK IF CASE GOT REASSIGNED TO ANOTHER USER
                if (caseObj.Case_Reassigned_Time__c != Null && caseObj.Case_Reassigned_Time__c.getTime() > caseObj.Customer_Response_Received_Time__c.getTime()) {
                    Double caseReassignedTime = caseObj.Case_Reassigned_Time__c.getTime();
                    Double currentTime = System.Now().getTime();
                    Double milliSeconds = currentTime - caseReassignedTime;
                    outreachTimeInSec = String.valueOf(milliSeconds/1000).subStringBefore('.');
                    calculatedOfFieldName = 'Case Reassigned Time';
                    valueInField = string.ValueOf(caseObj.Case_Reassigned_Time__c);
                    ValueInFieldtext = string.ValueOfGMT(caseObj.Case_Reassigned_Time__c);
                } else {
                    Double customerResponseReceivedTime = caseObj.Customer_Response_Received_Time__c.getTime();
                    Double currentTime = System.Now().getTime();
                    Double milliSeconds = currentTime - customerResponseReceivedTime;
                    outreachTimeInSec = String.valueOf(milliSeconds/1000).subStringBefore('.');
                    calculatedOfFieldName = 'Customer Response Received Time';
                    valueInField = string.ValueOf(caseObj.Customer_Response_Received_Time__c);
                    ValueInFieldtext = string.ValueOfGMT(caseObj.Customer_Response_Received_Time__c);
                } 
            } else if (caseObj.Last_Outreach_Time__c != Null && caseObj.Customer_Response_Received__c == false) {
                //CHECK IF CASE GOT REASSIGNED TO ANOTHER USER
                if (caseObj.Case_Reassigned_Time__c != Null && caseObj.Case_Reassigned_Time__c.getTime() > caseObj.Last_Outreach_Time__c.getTime()) {
                    Double caseReassignedTime = caseObj.Case_Reassigned_Time__c.getTime();
                    Double currentTime = System.Now().getTime();
                    Double milliSeconds = currentTime - caseReassignedTime;
                    outreachTimeInSec = String.valueOf(milliSeconds/1000).subStringBefore('.');
                    if(outreachTimeInSec != null && (integer.ValueOf(outreachTimeInSec) > integer.ValueOf(System.label.FollowUpDurationInSeconds))){
                        isMultipleOutreach = 'true';
                    }
                    calculatedOfFieldName = 'Case Reassigned Time';
                    valueInField = string.ValueOf(caseObj.Case_Reassigned_Time__c);
                    ValueInFieldtext = string.ValueOfGMT(caseObj.Case_Reassigned_Time__c);
                } else {
                    Double lastOutreachTime = caseObj.Last_Outreach_Time__c.getTime();
                    Double currentTime = System.Now().getTime();
                    Double milliSeconds = currentTime - lastOutreachTime;
                    outreachTimeInSec = String.valueOf(milliSeconds/1000).subStringBefore('.');
                    if(outreachTimeInSec != null && (integer.ValueOf(outreachTimeInSec) > integer.ValueOf(System.label.FollowUpDurationInSeconds))){
                        isMultipleOutreach = 'true';
                    }
                    calculatedOfFieldName = 'Last Outreach Time';
                    valueInField = string.ValueOf(caseObj.Last_Outreach_Time__c);
                    ValueInFieldtext = string.ValueOfGMT(caseObj.Last_Outreach_Time__c);
                }
            }
        }
        return outreachTimeInSec + '-' + isMultipleOutreach + '^' + calculatedOfFieldName + '$' + valueInField + '/' + ValueInFieldtext;
    }
}