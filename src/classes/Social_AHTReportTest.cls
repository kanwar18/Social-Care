/**************************************************************************
Class Name:  Social_AHTReportTest
Author: Accenture
Requirement/Project Name: Social Care
Description:Test class for Social_AHTReportController and Social_AHTReportSCheduler 
Version History: Haemen(29/December/2014)
***************************************************************************/

@isTest(seeAllData=False)
public class Social_AHTReportTest{
    static testMethod void Social_AHTReportTestMethod1(){
        List<Automated_Report__c> automatedReportListTest = new List<Automated_Report__c>();
        Automated_Report__c AutomatedReportTestObj1 = new Automated_Report__c();
        AutomatedReportTestObj1.Report_Counter__c = 3;
        AutomatedReportTestObj1.Name = 'Test Report 1';
        automatedReportListTest.Add(AutomatedReportTestObj1);
        
        Automated_Report__c AutomatedReportTestObj2 = new Automated_Report__c();
        AutomatedReportTestObj1.Report_Counter__c = 0;
        AutomatedReportTestObj1.Name = 'Test Report 2';
        automatedReportListTest.Add(AutomatedReportTestObj2);
        insert automatedReportListTest;
        
        Social_AHTReportScheduler socialAHTReportInst = new Social_AHTReportScheduler();
        System.schedule('Automated AHT Reports Daily 2AM CST', '0 21 * * * ?',socialAHTReportInst);  
        
        AutomatedReportTestObj1.Report_Counter__c = 1;
        update AutomatedReportTestObj1;
    }
}