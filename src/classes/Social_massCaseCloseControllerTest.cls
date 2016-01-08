@isTest(seeAllData=false)
public class Social_massCaseCloseControllerTest{
    static testMethod void massCaseCloseControllerTest() { 
        test.starttest();
        List<User> userList = new List<User>();
        List<Group> groupList = new List<Group>();
        List<Case> caseList= new List<Case>();
        
        groupList = [Select id from group where type = 'Queue'];
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        user u1 = new User(alias = 's121', email='standarduser121@testorg.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  username='standarduser121@accenture.com');
        userList.add(u1);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert userList;
    
        Case testCaseObj = new Case();
        testCaseObj.Status = 'New';
        testCaseObj.Reason= 'Mass Close';
        testCaseObj.Case_Assigned_Time__c =NULL;            
        testCaseObj.OwnerId =groupList[0].Id;
        testCaseObj.RecordTypeId =system.Label.ConsumerCareCase;
        caseList.add(testCaseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;    
         
        ApexPages.StandardSetController StdCtrl = new ApexPages.StandardSetController(Database.getQueryLocator([Select id from Case  where id = :caseList[0].Id]));
        Social_massCaseCloseController massCaseCloseTest = new Social_massCaseCloseController(StdCtrl);
        massCaseCloseTest.selectedCases.add(testCaseObj);
        massCaseCloseTest.massCaseClose();        
        test.stoptest();
    }    
    static testMethod void massCaseCloseControllerTestA() {
        test.starttest();
        List<User> userList = new List<User>();
        List<Group> groupList = new List<Group>();
        List<Case> caseList= new List<Case>();
        Case emptycaseList= new Case();

        groupList = [Select id from group where type = 'Queue'];
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        user u2 = new User(FirstName = 'SCSTestUser11', LastName =  'SCS1', Alias = 'SCS11', CommunityNickname = 'scsTone11', Email = 'scsTest44@gmail.com', Username = 'scsTest44@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Offline');
        userList.add(u2);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert userList;
     
        Case testCaseObj = new Case();
        testCaseObj.Status = 'New';
        testCaseObj.Reason= 'Mass Close';
        testCaseObj.Case_Assigned_Time__c =NULL;            
        testCaseObj.OwnerId =groupList[0].Id;
        testCaseObj.RecordTypeId =system.Label.ConsumerCareCase;
        caseList.add(testCaseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
                
        ApexPages.StandardSetController StdCtrl = new ApexPages.StandardSetController(new case[]{});
        Social_massCaseCloseController massCaseCloseTest = new Social_massCaseCloseController(StdCtrl);
        massCaseCloseTest.selectedCases.add(emptycaseList);
        massCaseCloseTest.massCaseClose();
        massCaseCloseTest.getCaseReasonValue();         
        massCaseCloseTest.continueMassCaseClose();
        test.stoptest();
    }
    static testMethod void massCaseCloseControllerTestB() { 
        test.starttest();
        List<User> userList = new List<User>();
        List<Group> groupList = new List<Group>();
        List<Case> caseList= new List<Case>();

        groupList = [Select id from group where type = 'Queue'];
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        user u3 = new User(alias = 's121', email='standarduser121@testorg.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  username='standarduser121@accenture.com');
        userList.add(u3);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert userList;
    
        Case testCaseObj = new Case();
        testCaseObj.Status = 'Close';
        testCaseObj.Reason= '';
        testCaseObj.Case_Assigned_Time__c =NULL;            
        testCaseObj.OwnerId =groupList[0].Id;
        testCaseObj.RecordTypeId =system.Label.ConsumerCareCase;
        caseList.add(testCaseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;        
        ApexPages.StandardSetController StdCtrl = new ApexPages.StandardSetController(Database.getQueryLocator([Select id from Case  where id = :caseList[0].Id]));
        Social_massCaseCloseController massCaseCloseTest = new Social_massCaseCloseController(StdCtrl);
        massCaseCloseTest.selectedCases.add(testCaseObj);
        massCaseCloseTest.massCaseClose();      
        test.stoptest();         
    }
    
    static testMethod void massCaseCloseControllerTestC() { 
        test.starttest();
            List<User> userList = new List<User>();        
            List<Case> caseList= new List<Case>();
            List<Group> groupList = new List<Group>();
            
            groupList = [Select id from group where type = 'Queue'];
            Profile p1 = [Select id from profile where name = 'Care Manager'];
            user u = new User(FirstName = 'SCSTestUser11', LastName =  'SCS1', Alias = 'SCS11', CommunityNickname = 'scsTone11', Email = 'scsTest44@gmail.com', Username = 'scsTest44@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Offline');
            userList.add(u);
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            insert userList;
            
            
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = userInfo.getUserId();
            psa.PermissionSetId = system.Label.MassCaseClosePermissionSetId;
            insert psa;

            ApexPages.StandardSetController StdCtrl= new ApexPages.StandardSetController(Database.getQueryLocator([Select id from Case]));
            Social_massCaseCloseController massCaseCloseTest = new Social_massCaseCloseController(StdCtrl);         
        test.stoptest();
    }
    }