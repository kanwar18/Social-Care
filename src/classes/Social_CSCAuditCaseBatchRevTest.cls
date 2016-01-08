@isTest(seeAllData=true)
public class Social_CSCAuditCaseBatchRevTest{
    public static String strCronExp = '0 0 20 * * ? 2022';

    //Method for the auditCaseTest
    public static TestMethod void Social_AuditCaseBatchSchedulableReviewedTestMethod(){ 
        Test.startTest();
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_CSCAuditCaseBatchSchedulableRev sld= new Social_CSCAuditCaseBatchSchedulableRev();
        System.schedule('test', strCronExp, sld);
        Test.stopTest();
      }
    
    //Method for the cronTest
    public static testMethod void doSocialCronTest() {
        Test.startTest();
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger Limit 1];        
        System.assertNotEquals(strCronExp, ct.CronExpression);
        Test.stopTest();
    }
 }