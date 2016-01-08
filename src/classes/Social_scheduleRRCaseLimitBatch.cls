/*** Class Name:   Social_scheduleRRCaseLimitBatch
 * Author: Accenture
 * Date: 5-June-2014
 * Requirement Description: Batch to schedule Social_RoundRobinCaseLimitBatch for round robin limit.
 **/
global class Social_scheduleRRCaseLimitBatch implements Schedulable {
   global void execute(SchedulableContext SC) {
       
       Social_RoundRobinCaseLimitBatch obj1 = new Social_RoundRobinCaseLimitBatch();
       obj1.query = 'Select id from Case Where (RecordType.Name like \'%Consumer%\' or RecordType.Name = \'HS Care rep\') and ownerId IN (Select queueId From QueueSobject)';
       ID batchprocessid1 = Database.executeBatch(obj1,2000);
   }
}