/*Updated by Ramakrishna Yella on March 20th 2014 for code coverage. 
Reason: For code coverage we need to query the existing data for last week closed cases.*/  
     
@isTest(SeeAllData=true)

public class Social_AuditCaseBatchSchedulableTest{
    public static String strCronExp = '0 0 20 * * ? 2022';

    public static testmethod void schedulerAuditcheck(){
        try {
            Test.startTest();
          Social_CaseAssignmentUtility.executeTriggerCode = false;
          System.schedule('QA Job',strCronExp, new Social_AuditCaseBatchSchedulable());        
          Test.stopTest();
        } catch(Exception excep) {
            System.debug('Exception Caught:'+excep.getMessage()+', Line#'+excep.getLineNumber());
        }
    }
}