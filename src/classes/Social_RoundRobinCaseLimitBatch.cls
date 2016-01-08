/*** Class Name:   Social_RoundRobinCaseLimitBatch
 * Author: Accenture
 * Date: 5-June-2014
 * Requirement Description: Batch to semd an email if the case assign to queue limit exceeded.
 **/
global class Social_RoundRobinCaseLimitBatch implements Database.Batchable<sObject>,Schedulable,database.stateful{
     public String query;
     public String subject;
     public String body='';
     public String setSenderDisplayName;
     public integer caseCount=0;
     
     Public Static List<String> sendTo= new List<String>();
     //sendTo.add(body);
   
     global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
     }
     
     global  void execute(Database.BatchableContext BC, List<sObject> CaseScopeList) {  
         caseCount=CaseScopeList.size()+caseCount ;
     }  
             
     global void finish(Database.BatchableContext BC) {
        if(caseCount> Integer.valueOf(label.RoundRobin_Threshold_Limit)){
            subject='Automated Batch to check Case Limit for Round Robin';
            setSenderDisplayName='Automated Admin';
            body='Hi,<br><br>';
            body+=' The environment has reached the Round Robin limit of Cases in Queue.';
            body+=' Currently there are '+caseCount+ ' Cases in Queue. <br><br>';
            body+='Regards,<br>';
            body+='Admin Team';
            sendTo.addAll(string.valueOf(Label.Email_List_for_Round_Robin_Limit).split(','));
            Social_SendAnEmailUtility.sendEmail(subject,sendTo,body,setSenderDisplayName);
        }
     }
     global void execute(SchedulableContext sc){
     } 
       
    
   
}