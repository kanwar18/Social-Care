@isTest(seeAllData = false)
public class TimerTrackTest {
    static Account testAccount;
    static Contact testContact;
    static Case testCase;
    static Case testCase1;
    static Case testCase2;
    static Case testBusinessCase1;
    static Case socialPostCase;
    
    static User user1;
    static User opsManager;
    
    static RecordType recordTypeObj;
    
    static{
        recordTypeObj = [Select Id, Name from RecordType Where name like '%Consumer%' Limit 1];
        testAccount=new Account();
        testAccount.Name='testAccount';
        insert testAccount;
        
        testContact=new Contact();
        testContact.AccountId=testAccount.Id;
        testContact.LastName='testName';
        testContact.email='testemail@abc.com';
        testContact.Account = testAccount;
        insert testContact;  
        
        Profile profile1 = [select id, name from profile where name='Care Manager'];
        Profile opeMgrProf = [select id, name from profile where name='Operations Manager'];
        
        opsManager = new User(alias = 'ops90158', email='manageruseruser158@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = opeMgrProf.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Available', 
        username='manageruser158@accenture.com', Case_Counter__c=0);
        insert opsManager;
        
        user1 = new User(alias = 'std67159', email='standarduseruser159@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profile1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c='Available', 
        username='standarduser159@accenture.com',Case_Counter__c=0);
        insert user1;

        testCase = new Case(
            contactId = testContact.Id,
            status = 'New',
            recordTypeId = recordTypeObj.Id,
            OwnerId = user1.Id,
            Component_Primary__c = 'DSL',
            Origin = 'Social Hub',
            Social_Media_Source__c = 'ATT Small Biz',
            Posted_Date__c = System.now().addDays(-2),
            Case_PostTag__c= 'DSL',
            Harvest_Date__c = System.now()
        );
        
        insert testCase;        
    }
    
    //method to test the time track controller
   static testMethod void testTimeTrackController() {
        ApexPages.StandardController sc = new ApexPages.standardController(testCase);
        TimeTrackController trackController = null;
        List<TimerTrack__c> timeTrackList = null;
        Test.startTest();
        trackController = new TimeTrackController(sc);
        doInsertCaseTimerRecords(UserInfo.getUserId(), testCase.Id);
        trackController.doCaseOpenTime();
        timeTrackList = [Select Id from TimerTrack__c Limit 10];
        System.assertNotEquals(timeTrackList.size(), 0);
        Test.stopTest();
    }
    
     //method to test the time track controller
    static testMethod void testTimeCaseUpdate() {
        ApexPages.StandardController sc = new ApexPages.standardController(testCase);
        TimeTrackController trackController = null;
        Test.startTest();
        trackController = new TimeTrackController(sc);
        trackController.doCaseOpenTime();
        testCase.Status = 'New';
        Test.stopTest();
    }
    
    //method to test the reports functionality
    static testMethod void testCaseTimerReports() {
        TimerReportsController timeReportCtrl = new TimerReportsController();
        Test.startTest();
        doInsertCaseTimerRecords(UserInfo.getUserId(), testCase.Id);
            
        System.assertNotEquals(TimerReportsController.getReportNames().size(), 0);
        System.assertNotEquals(timeReportCtrl.getAvgCaseHandleTimePerCM().size(), 0);
        System.assertNotEquals(timeReportCtrl.getTransactionsByUser().size(), 0);
        System.assertNotEquals(timeReportCtrl.getCaseHandlingPerTeam().size(), 0);
        System.assertNotEquals(TimerReportsController.getCaseHandlingByTimePeriod().size(), 0);
        System.assertNotEquals(TimerReportsController.getReportNames().get(0).toString().length(), 0);
        Set<Id> caseSet = new Set<Id>{testCase.Id, testCase.Id};
        TimeTrackHandler.updateTimerRecords(caseSet, 'Case Comments Insert');
        TimeTrackHandler trackObj = new TimeTrackHandler();
        TimeTrackHandler.doUpdateTimeTracks(new Case[] {testCase}, 'Case Comments Update');
        TimeTrackHandler.doUpdateTimeTracks(null, 'Case Comments Update');
        Test.stopTest();
     }
    
    //method to handle the miscellaneous items
    static testMethod void testCaseTimerMiscellaenous() {
        new TimerReportsHandler();
        Test.startTest();
        TimeTrackUtility.doInsertTimeRecord(UserInfo.getUserId(), testCase, 'Case Update');
        TimeTrackUtility.doPrintCustomMessage('Sample Text');
        TimeTrackUtility.doPrintExceptionMsg(new NullPointerException());
        System.assertNotEquals(TimeTrackUtility.doDateReadable(0.34566).length(), 0);
        System.assertNotEquals(TimeTrackUtility.doConvertCalendarMonthAndYear(4, 2013).length(), 0);
        System.assertEquals(TimeTrackUtility.doConvertCalendarMonth('January'), 0);
        TimerReportsHandler.CaseHandlingWrapper caseHand = new 
            TimerReportsHandler.CaseHandlingWrapper(testCase.Id, Double.valueOf('0.345'));
        System.assertNotEquals(caseHand.toString().length(), 0);
        System.assertNotEquals(TimeTrackUtility.doConvertCalendarMonth('March 2014'), -1);
        Test.stopTest();
    }
    
    static testMethod void testTotalHandleTimeByCustomersPers() {
        try {
            Test.startTest();
            new SocialCareBatchClient('deleteTimeTrack').doStartBatch();
            String[] primaryCompArr = new String[] {'DSL','U-verse','Yellow Pages','Landline','Digital Life'};
            List<Case> caseList = new List<Case>();
            new FirstCustResponse();
            new AverageResponseTimePerMonthController().retrieveData();
            for(String primaryComp : primaryCompArr) {
                Case caseObj = new Case(
                    contactId = testContact.Id,
                    status = 'New',
                    OwnerId = user1.Id,
                    Component_Primary__c = primaryComp,
                    Origin = 'Social Hub',
                    Social_Media_Source__c = 'ATT Small Biz',
                    Posted_Date__c = System.now().addDays(-2),
                    Case_Assigned_Time__c = System.now().addDays(-2),
                    Case_PostTag__c= 'DSL',
                    Harvest_Date__c = System.now(),
                    RecordTypeId = recordTypeObj.Id
                );
                caseList.add(caseObj);
            }
            insert caseList;
            
            List<SocialPost> socialPostList = new List<SocialPost>();
            for(Integer caseObjCnt = 0; caseObjCnt < caseList.size(); caseObjCnt++) {           
                Socialpost socpos= new Socialpost();
                socpos.Headline='Tweet from abcdd';
                socpos.name='Post from Ramasept18';
                socpos.posted=system.now().addDays(-2);
                socpos.R6Service__PostTags__c= primaryCompArr.get(caseObjCnt);
                socpos.parentid= caseList.get(caseObjCnt).Id;
                socpos.R6Service__Status__c='dddd';
                socpos.MediaProvider='Twitter';
                socpos.R6Service__Status__c='REPLIED';
                socialPostList.add(socpos);
            }
            insert socialPostList;
            
            for(Case caseObj : caseList) {
                caseObj.First_SLA_Response_Time__c=system.today();
                caseObj.Current_SLA_Phase__c='SLA1 - Ended';
                caseObj.ContactId=testContact.Id;
                caseObj.ownerid=user1.id;
            }
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            update caseList;          
        
            Case caseoblLoc = [Select First_Cust_Response__c,First_SLA_Response_Time__c,Posted_Date__c, 
            RecordType.Name,Origin,Component_Primary__c,Owner.Profile.Name from Case Limit 1];
            
            System.debug(caseoblLoc.First_Cust_Response__c +','+caseoblLoc.First_SLA_Response_Time__c+', '+caseoblLoc.Posted_Date__c);
            System.debug(caseoblLoc.RecordType.Name +','+caseoblLoc.Origin+', '+caseoblLoc.Component_Primary__c);

            new R6CaseTimerReportController().getCaseAvgResCustPer();
            new AverageResponseTimePerMonthController().retrieveData();
            new FirstCustResponse();
            new AvgCMResponseTimeFromAssignment().getData();

            new SocialCareBatchHandler().doDeleteTimerTrackWoEndDate(new List<Case>{caseoblLoc});
            Test.stopTest();
        } catch(Exception excep) {
            System.debug('Exception Caught :'+excep.getMessage()+', Line#'+excep.getStackTraceString());
        }
    }
    
    
    static testMethod void testScheduleJobs() {
        Test.startTest();
        String sch = '1 1 1 * * ?';
        system.schedule('Update Case Data', sch, new SocialCarePostDataScheduler());
        system.schedule('Delete Timer App Data', sch, new SoicalCareTimerDataScheduler());  
        system.schedule('TimerTrackDelete', sch , new SocialCareTimerDataKillScheduler()); 
        Test.stopTest();
    }
    
    
    //method used to insert the test data
    private static void doInsertCaseTimerRecords(Id userId, Id caseId) {
        String[] transactionTypeArr = new String[] {
            'Case Update', 'Case Comments Insert', 'Case Comments Update','Social Post Insert',
            'Social Post Update','Case Task Insert','Case Task Update','Case Event Insert','Case Event Update',
            'Case Email Insert', 'Case Email Update'
        };
        
        List<TimerTrack__c> timeTrackList = new List<TimerTrack__c>();
        TimerTrack__c timeTrackObj = null;
        for(String transType : transactionTypeArr) {
            timeTrackObj = new TimerTrack__c(
                Related_Case__c = caseId,
                Transaction_Start_Date__c = DateTime.now(),
                Transaction_End_Date__c = DateTime.now().addSeconds(50),
                Transaction_Type__c = transType,
                Transaction_Performed_By__c = userId,
                Case_Status__c = 'New',
                User_Availability_Status__c = 'Available'
            );
            timeTrackList.add(timeTrackObj);
        }
        insert timeTrackList;
    }
}