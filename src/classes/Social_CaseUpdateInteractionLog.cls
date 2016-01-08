/********************************************************************************************************
*    Author :     Accenture
*    Requirement: To get list of cases owned by logged in user.
*    Version:     1.0
*    Created Date: 3/20/2015
*    Version History: 5/May/2015(Aditya) : Deployed ITS - 001545
*********************************************************************************************************/
Public class Social_CaseUpdateInteractionLog {
    Public List<Case> casesToDisplay{get;set;}//List to store cases
    Public final Integer limitOfCases{get;set;}//Integer to store number of cases to query.
    public Double DNRTimeExp{get;set;}// to calculate DNR End Time Notification time.
    public Social_CaseUpdateInteractionLog(ApexPages.StandardController controller) {
        casesToDisplay = new List<Case>();
        limitOfCases = 30;
        DNRTimeExp=Decimal.valueOf(label.Do_Not_Reassign_Time_Limit)/86400000;
        queryCases();        
    }
    
   /**
    * < queryCases() - Method to get cases assigned to logged in user>
    * @param:
    *       
    * @return - void
    * @see - Social_CaseUpdateInteractionLog (Class)
    */
    
    Public void queryCases() {
        casesToDisplay = [Select id,readunreadcheck__c,SocialPersonImage__c,NonCaseOwner_LastModifiedDate__c,origin,Timer_Expires_AT__c,DNR_End_Time__c,Second_SLA_Scheduled_Time__c,Billing_Account__c,Wireless_CTN__c,R6Service__MediaProvider__c ,Status,CaseNumber,Social_Care_Handle_Name__c,Contact.Name,Contact.photourl,R6MediaIcon__c,Priority,DNE_Listed_Flag__c,Current_SLA_Phase__c,ReadUnreadFormula__c,Update_Reason__c,SLA_Details__c,First_SLA_Scheduled_Time__c from case where (Status = 'New' OR Status = 'Investigating' OR Status = 'Reassigned' OR Status = 'Reopen' OR Status = 'Escalated' OR Status = 'Follow Up Hold' OR Status = 'Hold for Call Back') and ownerId = : userInfo.getUserId() ORDER BY NonCaseOwner_LastModifiedDate__c  DESC  Nulls last limit :limitOfCases];
    }
}