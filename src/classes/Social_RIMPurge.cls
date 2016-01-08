/**************************************************************************
Class Name:  Social_RIMPurge
Author: Accenture
Requirement/Project Name: Social Care
Description: Batch Apex to Purge data 
Version History: Haemen(25/September/2014)
***************************************************************************/

global class Social_RIMPurge implements database.batchable<sObject>,Database.Stateful{
    public string query;// Holds dynamic query
    Public DateTime lastModifiedDateCase;// Holds value custom date
    Public Integer objectNumber;// Holds the numerical value for the Object to be fetched from the Custom setting.
    Public String objectName; // Holds the name of the object whos recods are to be purged.
    
    global database.QueryLocator start(database.BatchableContext bc){
        // To increment the count for the variable to fetch the next object from the Custom Setting
        objectNumber = objectNumber + 1;
        return database.getQueryLocator(query);
    }
    
    global void execute(database.BatchableContext bc, List<sObject> scopeList){
        List<sObject> sObjectList = new List<sObject>();
        for (sObject sObj: scopeList) {
            
            //to check if the record to be deleted is an EVENT or a TASK, and setting the value as true to bypass the trigger. 
            if(sObj.getSObjectType()== Task.getSObjectType()||sObj.getSObjectType()== Event.getSObjectType()) {
                Social_caseActivityDeleteControl.deleteActivity = True;
            }
            sObjectList.add(sObj);
        }
        //To purge the records of the object added to the list
         Social_StreamingUtil.doNtFireEmail2CaseRun = false;
         Social_StreamingUtil.deleteSObject(sObjectList, 'Error While Purging records for '+ objectName);
         DataBase.emptyRecycleBin(sObjectList);  
    }
    //Reinitiating the Batch class to purge the next object from the list in Custom setting.
    global void finish(database.BatchableContext bc){
        DateTime lastModifiedDateCase;
        RIM__c rimObj = RIM__c.getValues(String.valueOf(objectNumber));
        if (rimObj != Null) {
            lastModifiedDateCase = system.now().addMonths(Integer.ValueOf(- rimObj.Duration_in_Months__c));
            objectName = rimObj.Object_Name__c;
            Social_RIMPurge rpCls = new Social_RIMPurge();
            //Query to fetch the id of the records of the object to be purged on basis of the last modified date calculated using Custom setting. 
            if (objectName.equalsIgnoreCase('Task') || objectName.equalsIgnoreCase('Event')) {
                rpCls.query = 'Select id from ' +objectName+' where CreatedDate <=:lastModifiedDateCase and isDeleted = false';
            } else {
                rpCls.query = 'Select id from ' +objectName+' where lastModifiedDate <=:lastModifiedDateCase';
            }
            rpCls.objectNumber = objectNumber;
            rpCls.lastModifiedDateCase = lastModifiedDateCase;
            ID batchprocessid = Database.executeBatch(rpCls,200);
        }
    
    }
}