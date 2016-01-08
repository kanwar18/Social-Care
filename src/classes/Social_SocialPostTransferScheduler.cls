/**************************************************************************
Class Name:  Social_SocialPostTransferScheduler
Author: Accenture
Requirement/Project Name: Social Care
Description: Scheduler class to collect all closed cases inlast 1 month
Version History: Aditya(8/August/2014)
**************************************************************************************************************************/
global class Social_SocialPostTransferScheduler implements Schedulable {
    global void execute(SchedulableContext SC){
        Social_SocialPostTransfer sopos = new Social_SocialPostTransfer();
        sopos.query = 'select id from case where status =: caseStatusClosed and status=: caseStatusAutoClosed and (ClosedDate > :caseCloseddate and ClosedDate <=:caseCloseddate1)  and (RecordTypeId =:closedRecordType or RecordTypeId =:closedQARecordType) LIMIT ' + System.Label.SocialPostBatchQueryLimit;
        database.executeBatch(sopos,200);
    }
}