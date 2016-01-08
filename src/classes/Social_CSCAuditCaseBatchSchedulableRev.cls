/*** Class Name: Social_CSCAuditCaseBatchSchedulableRev
 * Author: Accenture
 * Date: 15-Oct-2012
 * Requirement/Project Name: Social Care
 * Requirement Description: This is the schedulable apex class and it is using to schedule the Social_AuditCaseBatch.  
 **/
global class Social_CSCAuditCaseBatchSchedulableRev implements Schedulable{
     global void execute(SchedulableContext sc) {
      Social_CSCAuditSchedulingClass asc1= new Social_CSCAuditSchedulingClass();
        asc1.initiateCaseAudit();
     } 
   }