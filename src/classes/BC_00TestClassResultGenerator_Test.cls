@istest(seealldata=true)
private class BC_00TestClassResultGenerator_Test{
    public static testMethod void test_TestClassExecutionAutomationResult () {
         test.startTest();
             list<AsyncApexJob> apexQueueObj = [select id from AsyncApexJob where status ='Completed' order by createddate DESC limit 1];
             set<Id> parentId = new set<Id>();
             if(apexQueueObj.size() > 0)
                 parentId.add(apexQueueObj[0].id);
             BC_00TestClassResultGenerator classInst1 = new BC_00TestClassResultGenerator();
             classInst1.asyncApexJobIdSet = parentId;
             ID batchprocessid = Database.executeBatch(classInst1,1000);
         test.StopTest();
     }
}