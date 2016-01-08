/**************************************************************************
Class Name:  Social_RIMPurgeScheduler
Author: Accenture
Requirement/Project Name: Social Care
Description: Scheduler to run the batch apex to purge data (Social_RIMPurge) 
Version History: Haemen(25/September/2014)
***************************************************************************/

global class Social_RIMPurgeScheduler implements schedulable{
    
    global void execute(SchedulableContext bc){
         DateTime lastModifiedDateCase;
         Integer objectNumber = 1;
         String objectName;
         RIM__c rimObj = RIM__c.getValues(String.ValueOf(objectNumber));
         if (rimObj.Duration_in_Months__c != Null) {
             lastModifiedDateCase = system.now().addMonths(Integer.ValueOf(- rimObj.Duration_in_Months__c));
             objectName = rimObj.Object_Name__c;
             Social_RIMPurge rpCls = new Social_RIMPurge();
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