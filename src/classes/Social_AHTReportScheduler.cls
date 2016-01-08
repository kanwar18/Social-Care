/**************************************************************************
Class Name:  Social_AHTReportScheduler
Author: Accenture
Requirement/Project Name: Social Care
Description: Scheduler for AHT Report functionality. This will run at the specified time and will make update to Automated_Report__c object
Version History: Aditya(16/December/2014)
***************************************************************************/

/*
Scheduler Script:
Social_AHTReportScheduler socialAHTReportInst = new Social_AHTReportScheduler();
System.schedule('Automated AHT Reports Daily 2AM CST', '0 21 * * * ?',socialAHTReportInst);

*/
Public class Social_AHTReportScheduler implements Schedulable {
    Public void execute(SchedulableContext ctx) {
        List<Automated_Report__c> automatedReportList = new List<Automated_Report__c>();//List to store automated report records
        for (Automated_Report__c automatedReportObj : [SELECT Id, Report_Counter__c FROM Automated_Report__c limit 50000]) {
            if (automatedReportObj.Report_Counter__c == Null) {
                automatedReportObj.Report_Counter__c = 0;
            }
            automatedReportObj.Report_Counter__c = automatedReportObj.Report_Counter__c + 1;
            automatedReportList.add(automatedReportObj);
        }
        //Check if the list is not empty before making updates
        if (!automatedReportList.isEmpty()) {
            Social_StreamingUtil.updateSObject(automatedReportList,'Updating Automated Report Object');
        }
    }   
}