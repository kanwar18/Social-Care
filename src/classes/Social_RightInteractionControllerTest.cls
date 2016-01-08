@isTest(seeAllData=false)
public class Social_RightInteractionControllerTest{
    static testMethod void Social_RightInteractionControllerTestA() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Care Manager']; 
        
        List<Quick_Links__c> quickLinksList = new List<Quick_Links__c>();
        Case testCaseObj = new Case();
        testCaseObj.Status = 'New';
        testCaseObj.Origin='email';     
        testCaseObj.priority = 'Low';
        testCaseObj.OwnerId = UserInfo.getUserid();
        insert testCaseObj;
        
        Quick_Links__c qLink1 = new Quick_Links__c();
        qLink1.Name = 'Test Link';
        qLink1.Profile_Names__c = 'Care Manager';
        qLink1.Quick_Link__c = 'www.testurl.com';
        quickLinksList.add(qLink1);
        
        Quick_Links__c qLink2 = new Quick_Links__c();
        qLink2.Name = 'Test Link2';
        qLink2.Profile_Names__c = 'System Administrator';
        qLink2.Quick_Link__c = 'www.testurl.com';
        quickLinksList.add(qLink2);
        insert quickLinksList;
        
        ApexPages.StandardController StdCtrl = new ApexPages.StandardController(testCaseObj);
        Social_RightInteractionController rightInteractionCon = new Social_RightInteractionController(StdCtrl);
        //Run in context with system admin
        rightInteractionCon.tosearch = '';
        rightInteractionCon.refreshLinkList();
        rightInteractionCon.tosearch = 'Test';
        rightInteractionCon.refreshLinkList();
        
        rightInteractionCon.showHideAll ='Hide All';
        rightInteractionCon.showAllRecords();
        rightInteractionCon.showHideAll ='Show All';
        rightInteractionCon.showAllRecords();
        
        rightInteractionCon.showHideMyLinks = 'My Links';
        rightInteractionCon.MyRecordsQuickLinks();
        rightInteractionCon.showHideMyLinks = 'Hide My Links';
        rightInteractionCon.MyRecordsQuickLinks();
        rightInteractionCon.addNewLinks();
        
        rightInteractionCon.tosearchAttDeal= '';
        rightInteractionCon.refreshListAttDeal(); 
        rightInteractionCon.tosearchAttDeal= 'Test';
        rightInteractionCon.refreshListAttDeal();
        
        rightInteractionCon.showHideAllDeals = 'Hide All';
        rightInteractionCon.showAllRecordsAttDeal();
        rightInteractionCon.showHideAllDeals = 'Show All';
        rightInteractionCon.showAllRecordsAttDeal();
        
        rightInteractionCon.showHideMyDeals = 'Hide My Deals';
        rightInteractionCon.MyRecordsAttDeal();
        rightInteractionCon.showHideMyDeals = 'My Deals';
        rightInteractionCon.MyRecordsAttDeal();
        
        rightInteractionCon.addNewDeals();
        
        //Run in context with Care Manager
        rightInteractionCon.ProfileId = p.Id;
        rightInteractionCon.tosearch = '';
        rightInteractionCon.refreshLinkList();
        rightInteractionCon.tosearch = 'Test';
        rightInteractionCon.refreshLinkList();
        
        rightInteractionCon.showHideAll ='Hide All';
        rightInteractionCon.showAllRecords();
        rightInteractionCon.showHideAll ='Show All';
        rightInteractionCon.showAllRecords();

        rightInteractionCon.showHideMyLinks = 'My Links';
        rightInteractionCon.MyRecordsQuickLinks();
        rightInteractionCon.showHideMyLinks = 'Hide My Links';
        rightInteractionCon.MyRecordsQuickLinks();
        rightInteractionCon.addNewLinks();
        
        rightInteractionCon.tosearchAttDeal= '';
        rightInteractionCon.refreshListAttDeal();
        rightInteractionCon.tosearchAttDeal= 'Test';
        rightInteractionCon.refreshListAttDeal();
        
        rightInteractionCon.showHideAllDeals = 'Hide All';
        rightInteractionCon.showAllRecordsAttDeal();
        rightInteractionCon.showHideAllDeals = 'Show All';
        rightInteractionCon.showAllRecordsAttDeal();
        
        rightInteractionCon.showHideMyDeals = 'Hide My Deals';
        rightInteractionCon.MyRecordsAttDeal();
        rightInteractionCon.showHideMyDeals = 'My Deals';
        rightInteractionCon.MyRecordsAttDeal();
        rightInteractionCon.addNewDeals();  
    }
    static testMethod void Social_RightInteractionControllerTestB() {
        List<ATT_Deals__c> attdealsList = new List<ATT_Deals__c>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Care Manager'];
        Case testCaseObj = new Case();
        testCaseObj.Status = 'New';
        testCaseObj.Origin='email';     
        testCaseObj.priority = 'Low';
        testCaseObj.OwnerId = UserInfo.getUserid();
        insert testCaseObj;
        
        ATT_Deals__c attDeal1 = new ATT_Deals__c();
        attDeal1.Name = 'Test Link';
        attDeal1.Profile_Names__c = 'Care Manager';
        attDeal1.Link__c = 'www.testdeal.com';
        attdealsList.add(attDeal1);
        
        ATT_Deals__c attDeal2 = new ATT_Deals__c();
        attDeal2.Name = 'Test Link';
        attDeal2.Profile_Names__c = 'System Administrator';
        attDeal2.Link__c = 'www.testdeal.com';
        attdealsList.add(attDeal2);
        insert attdealsList;
        
        ApexPages.StandardController StdCtrl = new ApexPages.StandardController(testCaseObj);
        Social_RightInteractionController rightInteractionCon1 = new Social_RightInteractionController(StdCtrl);
        rightInteractionCon1.tosearchAttDeal= 'Test';
        
        //Run in context with system admin
        rightInteractionCon1.tosearchAttDeal= '';
        rightInteractionCon1.refreshListAttDeal();
        rightInteractionCon1.tosearchAttDeal= 'Test';
        rightInteractionCon1.refreshListAttDeal();
        
        rightInteractionCon1.showHideAllDeals = 'Hide All';
        rightInteractionCon1.showAllRecordsAttDeal();
        rightInteractionCon1.showHideAllDeals = 'Show All';
        rightInteractionCon1.showAllRecordsAttDeal();
        
        rightInteractionCon1.showHideMyDeals = 'Hide My Deals';
        rightInteractionCon1.MyRecordsAttDeal();
        rightInteractionCon1.showHideMyDeals = 'My Deals';
        rightInteractionCon1.MyRecordsAttDeal();
        rightInteractionCon1.addNewDeals();
        
        rightInteractionCon1.tosearch = '';
        rightInteractionCon1.refreshLinkList();
        rightInteractionCon1.tosearch = 'Test';
        rightInteractionCon1.refreshLinkList();
        
        rightInteractionCon1.showHideAll ='Hide All';
        rightInteractionCon1.showAllRecords();
        rightInteractionCon1.showHideAll ='Show All';
        rightInteractionCon1.showAllRecords();

        rightInteractionCon1.showHideMyLinks = 'My Links';
        rightInteractionCon1.MyRecordsQuickLinks();
        rightInteractionCon1.showHideMyLinks = 'Hide My Links';
        rightInteractionCon1.MyRecordsQuickLinks();
        rightInteractionCon1.addNewLinks();
        
        //Run in context with Care manager
        rightInteractionCon1.ProfileId = p.Id;
        rightInteractionCon1.tosearchAttDeal= '';
        rightInteractionCon1.refreshListAttDeal();
        rightInteractionCon1.tosearchAttDeal= 'Test';
        rightInteractionCon1.refreshListAttDeal();
        
        rightInteractionCon1.showHideAllDeals = 'Hide All';
        rightInteractionCon1.showAllRecordsAttDeal();
        rightInteractionCon1.showHideAllDeals = 'Show All';
        rightInteractionCon1.showAllRecordsAttDeal();
        
        rightInteractionCon1.showHideMyDeals = 'Hide My Deals';
        rightInteractionCon1.MyRecordsAttDeal();
        rightInteractionCon1.showHideMyDeals = 'My Deals';
        rightInteractionCon1.MyRecordsAttDeal();
        rightInteractionCon1.addNewDeals();
        
        rightInteractionCon1.tosearch = '';
        rightInteractionCon1.refreshLinkList();
        rightInteractionCon1.tosearch = 'Test';
        rightInteractionCon1.refreshLinkList();
        
        rightInteractionCon1.showHideAll ='Hide All';
        rightInteractionCon1.showAllRecords();
        rightInteractionCon1.showHideAll ='Show All';
        rightInteractionCon1.showAllRecords();

        rightInteractionCon1.showHideMyLinks = 'My Links';
        rightInteractionCon1.MyRecordsQuickLinks();
        rightInteractionCon1.showHideMyLinks = 'Hide My Links';
        rightInteractionCon1.MyRecordsQuickLinks();
        rightInteractionCon1.addNewLinks();
    }
}