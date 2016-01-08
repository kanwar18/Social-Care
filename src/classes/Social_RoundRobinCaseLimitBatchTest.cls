/*** Class Name:  Social_RoundRobinCaseLimitBatchTest
 * Author: Accenture
 * Date: 5-June-2014
 * Requirement Description: To test Batch RoundRobinCaseLimitBatch and Social_SendAnEmailUtility.sendEmail . 
 **/
@isTest(seeAllData=false)
public class Social_RoundRobinCaseLimitBatchTest{
    Public static QueueSobject mobilityQueue;
    Public static Assignment_Group_Name__c mobilityGroupName;
    public static testmethod void test1(){
        Test.startTest();
        mobilityQueue = [Select q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name = 'Mobility' limit 1]; // Query Assignment Group(DSL/U-Verse)
        
        Assignment_Group_Name__c assignmentGrpName = new Assignment_Group_Name__c();
        assignmentGrpName.Type__c = 'Cases';
        assignmentGrpName.Name = 'Mobility';
        insert assignmentGrpName;
        
        Assignment_Group_Queues__c assignmentQueue = new Assignment_Group_Queues__c();
        assignmentQueue.Active__c = 'true';
        assignmentQueue.Assignment_Group_Name__c = assignmentGrpName.id;
        assignmentQueue.Name = 'Mobility';
        assignmentQueue.QueueId__c = mobilityQueue.QueueId;
        insert assignmentQueue;
        
        
        mobilityGroupName = [Select a.Name, a.Id From Assignment_Group_Name__c a where a.Name='Mobility' limit 1];
        List<case> caseList=new list<case>();
            for(integer i=0;i<2000;i++){
                Social_CaseAssignmentUtility.executeTriggerCode=false;
                Social_StreamingUtil.doNtFireEmail2CaseRun=false;
                case singlecase=new case(Status='New',RecordTypeId='012E0000000csej',ownerid=mobilityQueue.QueueId);
                caselist.add(singlecase);
            }
        insert caseList;
  
        Social_scheduleRRCaseLimitBatch obj1 = new Social_scheduleRRCaseLimitBatch();
        String strCronExp1 = '0 0 0 15 3 ? 2022';
        string jobid=system.schedule('Round',strCronExp1, obj1);
        Social_SendAnEmailUtility.sendEmail('subject',new list<String>{'hello@gmail.com','hello1@gmail.com'},'body','testing admin');
        Test.stopTest();
    }   
}