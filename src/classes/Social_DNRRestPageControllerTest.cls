/********************************************************************************************************
*    Author :     Accenture
*    Requirement: Test Class for Social_DNRRestPageController
*    Version:     1.0
*    Created Date: 10th September 2015.
*    Updated Date : 10th September 2015.
*    Requirement : ITS 1726
*    Updated By : Aditya Kumar
*********************************************************************************************************/

@isTest(seeAllData=False)
public class Social_DNRRestPageControllerTest{
    static testMethod void DNRRestPageControllerTest() { 
        test.starttest();
            List<User> userList = new List<User>();        
            List<Case> caseList= new List<Case>();
                    
            Profile p1 = [Select id from profile where name = 'Care Manager'];
            user u1 = new User(alias = 's121', email='standarduser121@testorg.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  username='standarduser121@accenture.com');
            userList.add(u1);
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            insert userList;
            
            Case testCaseObj = new Case();
            testCaseObj.Status = 'New';
            testCaseObj.Do_Not_Reassign__c = True;            
            testCaseObj.RecordTypeId =system.Label.ConsumerCareCase;
            testCaseObj.ownerId = u1.Id;
            caseList.add(testCaseObj);
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            insert caseList;    
             
            ApexPages.StandardSetController Ssc = new ApexPages.StandardSetController(Database.getQueryLocator([Select id from Case  where id = :caseList[0].Id]));
            ApexPages.currentPage().getParameters().put('retURL','https://yyy.com');
            system.Runas(u1){
                Social_DNRRestPageController DNRRestPageControllerTest= new Social_DNRRestPageController(Ssc);        
                DNRRestPageControllerTest.selectedCases.add(testCaseObj);
                DNRRestPageControllerTest.resetDNROnCase (); 
            }       
        test.stoptest();
    }    

    static testMethod void DNRRestPageControllerTest1() { 
        test.starttest();
            List<User> userList = new List<User>();        
            List<Case> caseList= new List<Case>();
                    
            Profile p1 = [Select id from profile where name = 'Care Manager Business'];
            user u1 = new User(alias = 's122', email='DNR@testorg.com', emailencodingkey='UTF-8', lastname='TestingDNR', languagelocalekey='en_US', localesidkey='en_US', profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  username='DNR@accenture.com');
            userList.add(u1);
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            insert userList;
            
            Case testCaseObj = new Case();
            testCaseObj.Status = 'New';
            testCaseObj.Do_Not_Reassign__c = True;            
            testCaseObj.RecordTypeId =system.Label.ConsumerCareCase;
            testCaseObj.ownerId = u1.Id;
            caseList.add(testCaseObj);
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            insert caseList;    
             
            ApexPages.StandardSetController Ssc = new ApexPages.StandardSetController(Database.getQueryLocator([Select id from Case  where id = :caseList[0].Id]));
            ApexPages.currentPage().getParameters().put('retURL','https://yyy.com');
            system.Runas(u1){
                Social_DNRRestPageController DNRRestPageControllerTest= new Social_DNRRestPageController(Ssc);        
                DNRRestPageControllerTest.selectedCases.add(testCaseObj);
                DNRRestPageControllerTest.resetDNROnCase ();            
            }       
        test.stoptest();
    }
    
    static testMethod void DNRRestPageControllerTest2() { 
        test.starttest();
            List<User> userList = new List<User>();        
            List<Case> caseList= new List<Case>();  
            ApexPages.currentPage().getParameters().put('retURL',System.Label.MassDNRListview);
            ApexPages.StandardSetController Ssc = new ApexPages.StandardSetController(Database.getQueryLocator([Select id from Case]));
            Social_DNRRestPageController DNRRestPageControllerTest= new Social_DNRRestPageController(Ssc);          
        test.stoptest();
    }
}