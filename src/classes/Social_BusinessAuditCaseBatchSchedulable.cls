/*** Class Name: Social_BusinessAuditCaseBatchSchedulable
 * Author: Accenture
 * Date: 15-Mar-2013
 * Requirement/Project Name: Business Care
 * Requirement Description: This is the schedulable apex class and it is using to schedule the Social_AuditCaseBatch.  
 **/
    global class Social_BusinessAuditCaseBatchSchedulable implements Schedulable{
    global void execute(SchedulableContext sc) {
             Social_BusinessAuditSchedulingClass bizaudit= new Social_BusinessAuditSchedulingClass();
             bizaudit.initiateCaseAudit();
     } 
   }