/*** Class Name:   Social_CareManagerResponseTest
 * Author: Accenture
 * Date: 17-June-2014
 * Requirement Description: test class for Social_CareManagerResponse controller class.
 **/
@isTest(seeAllData=false)
    public class Social_CareManagerResponseTest{
    public static TestMethod void Social_CareManagerResponseTestMethod(){  
        list<case> caselist= new list<case>();
        list<SocialPost> socialPostList= new list<SocialPost>();
        list<Custom_Post__c> customPostList=new list<Custom_Post__c>();
        
        Profile p1 = [select id, name from profile where name='System Administrator'];
        User u2 = new User(alias = 'standt91', email='standarduser91@testorg.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', profileid = p1.Id, isactive=true, timezonesidkey='America/Los_Angeles', Availability__c='Available',  username='test191@test.com');
          insert u2;
          ApexPages.currentPage().getParameters().put('id', u2.Id);
        
        
        Account testAccount1=new Account();     
        testAccount1.Name='testAccount1';     
        insert testAccount1;    
                 
        Contact testContact1=new Contact();     
        testContact1.LastName='testContact';     
        testContact1.Account = testAccount1;     
        testContact1.email='d.mittal@accenture.com';     
        insert testContact1;
       
        Test.startTest();
        Case caseObj=new Case();    
        caseObj.Status='New';    
        caseObj.Origin='email';    
        caseObj.ContactId=testContact1.Id;    
        caseObj.contact=testContact1;  
        caseObj.status = 'Closed';
        caseObj.Audit_Status__c ='Not QA';
        caseObj.Closed_Operation_Manager__c=u2.Id;
        caselist.add(caseObj);
        
         Case caseObji1=new Case();    
        caseObji1.Status='New';    
        caseObji1.Origin='email';    
        caseObji1.ContactId=testContact1.Id;    
        caseObji1.contact=testContact1;  
        caseObji1.status = 'Closed';
        caseObji1.Audit_Status__c ='Not QA';
        caseObji1.Closed_Operation_Manager__c=u2.Id;
        caselist.add(caseObji1);
        insert caselist;
        
        Social_Media_Account__c sMediaAccount = new Social_Media_Account__c();
        sMediaAccount.Access_Secret__c='HfDwOsCWSrMHlFwYiEBXDRkB28rfl2MIGPOVI9I0'; 
        sMediaAccount.Access_Token__c='62643312-oKeowTR0IgPqZfW5OPi7cmJx7TVjJBt3KUi1TLBI'; 
        sMediaAccount.Consumer_Key__c='sHPgtU8dcxBo9cOFQwbQ5A'; 
        sMediaAccount.Consumer_Secret__c='rBGHwmQiukEctkvdhsaLAAST5yFD8Q4M2T8dUcwA'; 
        sMediaAccount.Social_Media_Handle__c='Twitter'; 
        sMediaAccount.Social_Media_Handle_Name__c='ATTCustomer'; 
        
        insert sMediaAccount;
        
        SocialPost sp =  new SocialPost();
        sp.R6Service__SourceTags__c = 'Influencer High';
        sp.Headline = 'Test';
        sp.Name = 'Test';
        sp.ParentId = caseObji1.id;
        //insert sp;
        socialPostList.add(sp);
        
        SocialPost sp1 =  new SocialPost();
        sp1.R6Service__SourceTags__c = 'Influencer High';
        sp1.Headline = 'Test';
        sp1.Name = 'Test';
        sp1.ParentId = caseObj.id;
        socialPostList.add(sp1);
        insert socialPostList;
        
        Custom_Post__c cp = new Custom_Post__c();
        cp.Category__c= 'twitter';
        cp.Body__c= 'Test Body';
        cp.Subject__c= 'Test Subject';
        cp.AdditionalTo__c= 'xxx@accenture.com';
        cp.BCCAddress__c= 'yyy@abc.com';
        cp.CCAddress__c= 'zzz@abc.com';
        cp.Contact__c= testContact1.id;
        cp.Send_Notification_Email__c= true;
        cp.Message_Type__c = '@Reply';
        cp.Message__c = 'Test';
        cp.Replied_message__c = 'Test'; 
        cp.Status__c = 'Approved';
        cp.Social_Post__c= sp1.id;
        cp.Case__c= caseObji1.id; 
        customPostList.add(cp);
        
        Custom_Post__c cp1 = new Custom_Post__c();
        cp1.Category__c= 'facebook';
        cp1.Body__c= 'Test Body';
        cp1.Subject__c= 'Test Subject';
        cp1.AdditionalTo__c= 'xxx@accenture.com';
        cp1.BCCAddress__c= 'yyy@abc.com';
        cp1.CCAddress__c= 'zzz@abc.com';
        cp1.Contact__c= testContact1.id;
        cp1.Send_Notification_Email__c= true;
        cp1.Message_Type__c = '@Reply';
        cp1.Message__c = 'Test';
        cp1.Replied_message__c = 'Test'; 
        cp1.Status__c = 'Approved';
        cp1.Social_Post__c= sp1.id;
        cp1.Case__c= caseObj.id; 
        customPostList.add(cp1);
        insert customPostList;

        Test.stopTest();
        ApexPages.currentPage().getParameters().put('PostId',sp.Id);
        ApexPages.currentPage().getParameters().put('Category','twitter');
       
        ApexPages.StandardController cup2= new ApexPages.StandardController(cp);  
        Social_CareManagerResponse scmr= new  Social_CareManagerResponse(cup2);
        scmr.getCustomPost();
        scmr.getSendAs();
        scmr.getFromEmailAddress();
        scmr.save();
        scmr.checkCustomPostExists(sp.id);
        scmr.updateTraineeCareManagerResponse(sp);
        Social_CareManagerResponse scmr1 = new  Social_CareManagerResponse();
        
        ApexPages.currentPage().getParameters().put('PostId',sp1.Id);
        ApexPages.currentPage().getParameters().put('Category','Facebook');
        
        ApexPages.StandardController cup3= new ApexPages.StandardController(cp1);  
        Social_CareManagerResponse scmr2= new  Social_CareManagerResponse(cup3);
        scmr2.getCustomPost();
        scmr2.getSendAs();
        scmr2.getFromEmailAddress();
        scmr2.save();
        scmr2.checkCustomPostExists(sp1.id);
        scmr2.updateTraineeCareManagerResponse(sp1);
        Social_CareManagerResponse scmr3 = new  Social_CareManagerResponse();
       }
     }