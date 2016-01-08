/**************************************************************************
Class Name:  Social_RIMPurgeTest
Author: Accenture
Requirement/Project Name: Social Care
Description:Test class for Batch Apex to Purge data 
Version History: Haemen(25/September/2014)
***************************************************************************/
@isTest(seeAllData=false)

public class Social_RIMPurgeTest{
    
    static testMethod void testMethod1(){
        List<RIM__c> rimList = new List<RIM__c>();
        
        RIM__c rimObjCS1 = new RIM__c();
        rimObjCS1.Name = '1';
        rimObjCS1.Object_Name__c = 'case';
        rimObjCS1.Duration_in_Months__c = 0;
        rimList.add(rimObjCS1);
        
        RIM__c rimObjCS2 = new RIM__c();
        rimObjCS2.Name = '2';
        rimObjCS2.Object_Name__c = 'Event';
        rimObjCS2.Duration_in_Months__c = 0;
        rimList.add(rimObjCS2);    
        insert rimList;
        
        Case caseObj = new Case();    
        caseObj.Status='New';    
        caseObj.Origin='email';    
        caseObj.Audit_Status__c ='Not QA';
        caseObj.ownerId = userInfo.getUserId();
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseObj;
        
        Event event = new Event();
        event.Type = 'Meeting';
        event.DurationInMinutes = 12;
        event.ActivityDateTime = System.Today();
        insert event;
          
        string query;
        DateTime lastModifiedDateCase;
        Integer objectNumber = 1;
        String objectName;
        RIM__c rimObj = RIM__c.getValues(String.ValueOf(objectNumber));
        if (rimObj.Duration_in_Months__c != Null) {
            lastModifiedDateCase = system.now().addMonths(Integer.ValueOf(- rimObj.Duration_in_Months__c));
            objectName = rimObj.Object_Name__c;
            Social_RIMPurge rpCls = new Social_RIMPurge();
            rpCls.query = 'Select id from ' +objectName+' where lastModifiedDate <=:lastModifiedDateCase';
            rpCls.objectNumber = objectNumber;
            rpCls.lastModifiedDateCase = lastModifiedDateCase;
            ID batchprocessid = Database.executeBatch(rpCls,200);
        }
        Social_RIMPurgeScheduler RIMScobj1 = new Social_RIMPurgeScheduler();
        String strCronExp1 = '0 45 15 * * ? 2022';
        string jobid=system.schedule('RIM',strCronExp1,RIMScobj1); 
    }
}