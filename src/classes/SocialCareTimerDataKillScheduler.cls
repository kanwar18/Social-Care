/* 
Batch Apex: Consumer
Author: Accenture
Purpose:  This schedule job will run at 6AM EST to kill TimerTrackDelete job if it is in executing mode.
Version: 1.0  Date: 9th April 2014  
*/

Global with sharing class SocialCareTimerDataKillScheduler implements Schedulable {
    global void execute(SchedulableContext context) {
        set<String> jobNameSet = new set<String>{TimeTrackConstants.TIMETRACKDELETE};//job name that should be aborted.
        killExecutingBatchJob(jobNameSet);    
    }
    
    /**
    * < killExecutingBatchJob() - Method to kill batch job>
    * @param:
    *     Set<String> jobNameSet - job name.
    *       
    * @return - void
    * @see - SocialCareTimerDataKillScheduler (Batch Class)
    */
    Public static void killExecutingBatchJob(Set<String> jobNameSet) {
        Map<String,cronjobdetail> cronJobDetailMap = new Map<String,cronjobdetail>();
        if(cronJobDetailMap.isEmpty()) {
            for (cronjobdetail cronDetail : [select id,name from CronJobDetail where name IN:jobNameSet  limit 50000]) {
                cronJobDetailMap.put(cronDetail.Id,cronDetail);    
            }
        }
    }    
}