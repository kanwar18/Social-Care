@istest(seealldata=true)
private class SC00_TestClassExecuter_Test{
    public static testMethod void test_TestClassExecutionAutomationRunner () {
        test.startTest();
            SC00_TestClassExecuter classInst = new SC00_TestClassExecuter();
            String sch = '0 0 23 * * ?';
            system.schedule('TestClassExecutionAutomation', sch , classInst ); 
        test.StopTest();
    }
}