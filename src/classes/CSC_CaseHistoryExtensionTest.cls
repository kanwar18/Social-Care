/********************************************************************************************************
*    Author: Accenture/Social Care
*    Test Class for : SocialStreamingAPIUpdate
*    Version: 1.0 Aditya - Increased test class coverage.
*    Version: 1.1 Haemen - Increased test class coverage for CSC_SocialPost
********************************************************************************************************/
@IsTest(SeeAllData=false)
private class CSC_CaseHistoryExtensionTest {
    private static String testFlag = System.Label.CSC_Test_Flag;
    static testmethod void basicTest() {
        List<EmailMessage> emailMsgList = new list<EmailMessage>();
        List<Contact> contactList = new List<Contact>();
        Account testAccount=new Account();
        testAccount.Name='testAccount';
        insert testAccount;
        
        //asdas
        Contact  testContact=new Contact();
        testContact.AccountId=testAccount.Id;
        testContact.LastName='testName';
        testContact.email='testemail@abc.com';
        testContact.Account = testAccount;
        contactList.add(testContact);
        
        Contact  testContactEscalation = new Contact();
        testContactEscalation.AccountId=testAccount.Id;
        testContactEscalation.LastName='testName1';
        testContactEscalation.Exception_Contact__c = true;
        testContactEscalation.email='testemailescalation@abc.com';
        testContactEscalation.Account = testAccount;
        contactList.add(testContactEscalation);
        
        Contact  testContactEscalation1 = new Contact();
        testContactEscalation1.AccountId=testAccount.Id;
        testContactEscalation1.LastName='testName1';
        testContactEscalation1.Exception_Contact__c = true;
        testContactEscalation1.email='escalationContact@rr.com';
        testContactEscalation1.Account = testAccount;
        contactList.add(testContactEscalation1);
        insert contactList; 
        
        Case testCase = new Case();
        testCase.ContactId=testContact.Id;
        testCase.Status='New';
        testCase.Origin='email';
        testCase.Contact=testContact;
        testCase.OwnerId = UserInfo.getUserid();
        insert testCase;
        
        EmailMessage theEmailIncoming = new EmailMessage();
        theEmailIncoming.ParentId = testCase.Id;
        theEmailIncoming.Incoming = true;
        theEmailIncoming.Subject = 'abcd';
        theEmailIncoming.MessageDate = datetime.now();
        theEmailIncoming.HtmlBody = 'abcd<imgsrc=\"cid:@\">'; 
        theEmailIncoming.TextBody = 'abcd';
        theEmailIncoming.FromName = 'abcd';
        theEmailIncoming.FromAddress = 'testemail@abc.com';
        theEmailIncoming.ToAddress ='testemailescalation@abc.com';
        insert theEmailIncoming;
        
        EmailMessage theEmailInc = new EmailMessage();
        
        theEmailInc.ParentId = testCase.Id;
        theEmailInc.Incoming = true;
        theEmailInc.Subject = 'abcdafsd';
        theEmailInc.MessageDate = datetime.now();
        theEmailInc.TextBody = 'abcdsdf';
        theEmailInc.FromAddress = 'escalationContact@rr.com';
        theEmailInc.ToAddress ='xyz@gmail.com;hfjh@gmail.com';
        theEmailInc.ReplyToEmailMessageId = theEmailIncoming.Id;
        emailMsgList.add(theEmailInc);
        
        EmailMessage theEmailOut = new EmailMessage();
        theEmailOut.ParentId = testCase.Id;
        theEmailOut.Incoming = false;
        theEmailOut.Subject = 'abcdafsd';
        theEmailOut.MessageDate = datetime.now();
        theEmailOut.HtmlBody = 'abcddsfs'; 
        theEmailOut.TextBody = 'abcdsdf';
        theEmailOut.FromName = 'abcddsf';
        theEmailOut.ReplyToEmailMessageId = theEmailIncoming.Id;
        theEmailOut.FromAddress = 'testemailescalation@abc.com';
        theEmailOut.ToAddress ='xyz@gmail.com;sys@gmail.com';
        emailMsgList.add(theEmailOut);
        insert emailMsgList;
        
        SocialPost socialPost =  new SocialPost();
        socialPost.R6Service__SourceTags__c = 'Influencer High';
        socialPost.R6Service__IsOutbound__c = true;
        socialPost.Headline = 'Test';
        socialPost.Name = 'Test';
        socialPost.ParentId = testCase.id;
        insert socialPost;
        
        Custom_Post__c cp = new Custom_Post__c();
        cp.Category__c= 'Twitter';
        cp.Body__c= 'Test Body';
        cp.Subject__c= 'Test Subject';
        cp.AdditionalTo__c= 'xxx@accenture.com';
        cp.BCCAddress__c= 'yyy@abc.com';
        cp.CCAddress__c= 'zzz@abc.com';
        cp.Contact__c= testContact.id;
        cp.Send_Notification_Email__c= true;
        cp.Message_Type__c = '@Reply';
        cp.Message__c = 'Test';
        cp.Replied_message__c = 'Test'; 
        cp.Status__c = 'Approved';
        cp.Social_Post__c= socialPost.id;
        cp.Case__c= testCase.id; 
        insert cp;
        
        Profile ps = [select id, name from Profile where  name = 'System Administrator'];
        User u = new User(Alias = 'csct99', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='csctesting', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = ps.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='csctesting@testorg.com');
         
        PageReference p = Page.caseHistory;
        p.getParameters().put('id', testCase.id);
        
        Test.setCurrentPage(p);      
        
        CSC_CaseHistoryExtensionTest testclass = new CSC_CaseHistoryExtensionTest();
        Case casevar= new Case();
        casevar.Status = 'Closed';
        ApexPages.StandardController StdCtrl = new ApexPages.StandardController(casevar);
        Test.startTest();
            CSC_CaseHistoryExtension csccasehist= new CSC_CaseHistoryExtension(StdCtrl);  
            
            csccasehist.getAdminAcct();
            csccasehist.toggleComments();
            csccasehist.updateActivity();
            csccasehist.getcase();
            csccasehist.getHistories();
            
            boolean var1=csccasehist.getCheckBoxAttachments();
            boolean  var2=csccasehist.getCheckBoxComments();  
            boolean var3=csccasehist.getCheckBoxEmail();
            boolean var4=csccasehist.getCheckBoxHistory();
            boolean var5=csccasehist.getCheckBoxSocial();
            boolean var6=csccasehist.getCheckBoxSurveys();
            boolean var7=csccasehist.getCheckBoxTasks();
            boolean var9=csccasehist.getCheckBoxEvents();
            
            csccasehist.setCheckBoxAttachments(true);
            csccasehist.setCheckBoxComments(true);
            csccasehist.setCheckBoxEmail(true);
            csccasehist.setCheckBoxHistory(true);
            csccasehist.setCheckBoxSocial(true);
            csccasehist.setCheckBoxSurveys(true);
            csccasehist.setCheckBoxTasks(true);
            csccasehist.setCheckBoxAdmin(true);
            csccasehist.setCheckBoxEvents(true);
            csccasehist.adminAcct =true;
            csccasehist.getcase();
            List<case> cnumber=  [select casenumber from case where id =:testCase.id limit 1];
            list<Forsee_survey__c> lforseesurv=new list<Forsee_survey__c>();
            
            Forsee_survey__c forseesurv=new Forsee_survey__c();
            forseesurv.Case_Number__c=cnumber[0].casenumber;
            forseesurv.Contact__c=testContact.id;
            forseesurv.Twitter_Direct_Message_Sent__c=true;
            forseesurv.Case__c=testCase.id;    
            forseesurv.Forsee_URL__c='http://bscsit-attsocialcare.cs7.force.com/SocialMediaPage?noc=a0XM0000003rB9rMAE';
            forseesurv.Vanity_URL__c='http://bscsit-attsocialcare.cs7.force.com/SocialMediaPage?noc=a0XM0000003rB9rMAE';
            forseesurv.Twitter_Failure_Reason__c = '' ;
            forseesurv.Email_Sent__c =true;
            forseesurv.URL_Sent_Date__c=system.now();
            
            lforseesurv.add(forseesurv);
            
            Forsee_survey__c forseesurv1=new Forsee_survey__c();
            forseesurv1.Case_Number__c=cnumber[0].casenumber;
            forseesurv1.Contact__c=testContact.id;
            forseesurv1.Twitter_Direct_Message_Sent__c=false;
            forseesurv1.Case__c=testCase.id;    
            forseesurv1.Forsee_URL__c='http://bscsit-attsocialcare.cs7.force.com/SocialMediaPage?noc=a0XM0000003rB9rMAE';
            forseesurv1.Vanity_URL__c='http://bscsit-attsocialcare.cs7.force.com/SocialMediaPage?noc=a0XM0000003rB9rMAE';
            forseesurv1.Twitter_Failure_Reason__c = '' ;
            forseesurv1.Email_Sent__c =true;
            forseesurv1.URL_Sent_Date__c=system.now();
            
            lforseesurv.add(forseesurv1);
            
            Forsee_survey__c forseesurv2=new Forsee_survey__c();
            forseesurv2.Case_Number__c=cnumber[0].casenumber;
            forseesurv2.Contact__c=testContact.id;
            forseesurv2.Twitter_Direct_Message_Sent__c=false;
            forseesurv2.Case__c=testCase.id;    
            forseesurv2.Forsee_URL__c='http://bscsit-attsocialcare.cs7.force.com/SocialMediaPage?noc=a0XM0000003rB9rMAE';
            forseesurv2.Vanity_URL__c='http://bscsit-attsocialcare.cs7.force.com/SocialMediaPage?noc=a0XM0000003rB9rMAE';
            forseesurv2.Twitter_Failure_Reason__c = 'abcd' ;
            forseesurv2.Email_Sent__c =true;
            forseesurv2.URL_Sent_Date__c=system.now();
            
            lforseesurv.add(forseesurv2);
            
            Forsee_survey__c forseesurv3=new Forsee_survey__c();
            forseesurv3.Case_Number__c=cnumber[0].casenumber;
            forseesurv3.Contact__c=testContact.id;
            forseesurv3.Twitter_Direct_Message_Sent__c=false;
            forseesurv3.Case__c=testCase.id;    
            forseesurv3.Forsee_URL__c='http://bscsit-attsocialcare.cs7.force.com/SocialMediaPage?noc=a0XM0000003rB9rMAE';
            forseesurv3.Vanity_URL__c='http://bscsit-attsocialcare.cs7.force.com/SocialMediaPage?noc=a0XM0000003rB9rMAE';
            forseesurv3.Twitter_Failure_Reason__c = 'abcd' ;
            forseesurv3.Email_Sent__c =true;
            forseesurv3.URL_Sent_Date__c=null;
            
            lforseesurv.add(forseesurv3);
            
            Forsee_survey__c forseesurv4=new Forsee_survey__c();
            forseesurv4.Case_Number__c=cnumber[0].casenumber;
            forseesurv4.Contact__c=testContact.id;
            forseesurv4.Twitter_Direct_Message_Sent__c=true;
            forseesurv4.Case__c=testCase.id;    
            forseesurv4.Forsee_URL__c='http://bscsit-attsocialcare.cs7.force.com/SocialMediaPage?noc=a0XM0000003rB9rMAE';
            forseesurv4.Vanity_URL__c='http://bscsit-attsocialcare.cs7.force.com/SocialMediaPage?noc=a0XM0000003rB9rMAE';
            forseesurv4.Twitter_Failure_Reason__c = 'abcd' ;
            forseesurv4.Email_Sent__c =false;
            forseesurv4.URL_Sent_Date__c=null;
            forseesurv4.Email_Failure_Reason__c='asdd';
            
            lforseesurv.add(forseesurv4);
            
            Forsee_survey__c forseesurv5=new Forsee_survey__c();
            forseesurv5.Case_Number__c=cnumber[0].casenumber;
            forseesurv5.Contact__c=testContact.id;
            forseesurv5.Twitter_Direct_Message_Sent__c=false;
            forseesurv5.Case__c=testCase.id;    
            forseesurv5.Twitter_Failure_Reason__c = '' ;
            forseesurv5.Email_Sent__c =false;
            forseesurv5.URL_Sent_Date__c=null;
            forseesurv5.Email_Failure_Reason__c='asdd';
            lforseesurv.add(forseesurv5);
            insert lforseesurv;
            
            CaseComment newCom = new CaseComment();
            newCom.CommentBody = 'fdfsdfsd';
            newCom.IsPublished = TRUE;
            newCom.ParentId = testCase.id;
            insert newCom;
            
            List<socialPost> socialPostList = new List<socialPost>();
            Socialpost socpos= new Socialpost();
            socpos.Headline='Tweet from abcdd';
            socpos.name='Post from Ramasept18';
            socpos.Handle = 'test';
            socpos.posted=system.now()-2;
            socpos.R6Service__PostTags__c='General';
            socpos.parentid=testCase.id;
            socpos.R6Service__IsOutbound__c=true;
            socpos.R6Service__Status__c='dddd';
            socpos.MediaProvider='Twitter';
            socpos.R6Service__Status__c='REPLIED';
            socialPostList.add(socpos);
            
            Socialpost socpos2= new Socialpost();
            socpos2.Headline='Tweet from abcdd';
            socpos2.name='Post from Ramasept18';
            socpos2.posted=system.now()-2;
            socpos2.R6Service__PostTags__c='General';
            socpos2.parentid=testCase.id;
            socpos2.R6Service__Status__c='dddd';
            socpos2.MediaProvider='Twitter';
            socpos2.R6Service__Status__c='REPLIED';
            socialPostList.add(socpos2);
            
            Socialpost socpos1= new Socialpost();
            socpos1.Headline='Tweet from abcdd';
            socpos1.name='Post from Ramasept181';
            socpos1.Handle = 'test';
            socpos1.posted=system.now()-3;
            socpos1.R6Service__PostTags__c='General';
            socpos1.parentid=testCase.id;
            socpos1.R6Service__IsOutbound__c=true;
            socpos1.MediaProvider='Facebook';
            socpos1.R6Service__Status__c='SENT';
            socpos1.R6Service__OriginalAuthorSocialHandle__c='dddd';
            socialPostList.add(socpos1);
            insert socialPostList;
            
            Socialpersona sp= new Socialpersona();
            sp.Name='testbsc_2';
            sp.Provider='Twitter';
            sp.parentid=socpos.id;
            sp.R6Service__MediaProvider__c='TWITTER';
            sp.R6Service__R6SourceId__c='2184206243';
            sp.R6Service__ProfileType__c='Person';
            
            insert sp;
            
            socpos.Personaid=sp.id;
            update socpos;
            
            list<attachment> lattach =new list<attachment>();
            
            Attachment attach=new Attachment();       
            attach.Name='Unit Test Attachment';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=testCase.id;
            attach.description='sss';
            lattach.add(attach);
            
            Attachment attach1=new Attachment();       
            attach1.Name='Unit Test Attachment1';
            Blob bodyBlob1=Blob.valueOf('Unit Test Attachment Body');
            attach1.body=bodyBlob;
            attach1.parentId=testCase.id;
            lattach.add(attach1);
            insert lattach;
            
            ApexPages.StandardController StdCtrl1 = new ApexPages.StandardController(testCase);
            CSC_CaseHistoryExtension csccasehist1= new CSC_CaseHistoryExtension(StdCtrl1); 
            CSC_CaseHistoryExtension csccasehist2= new CSC_CaseHistoryExtension(); 
        test.stopTest();
        system.runas(u){
            csccasehist1.setCheckBoxAttachments(true);
            csccasehist1.setCheckBoxComments(true);
            csccasehist1.setCheckBoxEmail(true);
            csccasehist1.setCheckBoxHistory(true);
            csccasehist1.setCheckBoxSocial(true);
            csccasehist1.setCheckBoxSurveys(true);
            csccasehist1.setCheckBoxTasks(true);
            csccasehist1.setCheckBoxAdmin(true);
            csccasehist1.setCheckBoxEvents(true);
            csccasehist1.adminAcct =true; 
            csccasehist1.getcase();
            csccasehist1.getHistories();
        }
    }
    
    //Method to call methods of CSC_SocialPost
    static testmethod void basicTest2(){
        List<Case> caseList = new List<Case>();
        List<SocialPost> socialPostList = new List<SocialPost>();
        List<Contact> contactList = new List<Contact>();
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        SocialPersona socialPersonaObj1 = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj1);
        SocialPersona socialPersonaObj2 = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj2);
        SocialPersona socialPersonaObj3 = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', Followers = 3, RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj3);
        insert socialPersonaList;
        
        Case testCase = new Case(ContactId=contactList[0].Id, Status='New', Origin='email', OwnerId = UserInfo.getUserid());
        caseList.add(testCase);
        insert caseList;
        
        SocialPost socialPostOutgoing = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing);
        insert socialPostList;
        CSC_SocialPost sp = new CSC_SocialPost();
        sp.socialPeep = socialPersonaList[0];
        sp.socialPeep = socialPersonaList[1];
        sp.socialPeep = socialPersonaList[2];
        sp.socialPeep = socialPersonaList[3];
        sp.getSrcTags();
        sp.setSrcTags('hello');
        sp.getPstTags();
        sp.setPstTags('hello');
        sp.getPostPriority();
        sp.setFormattedAvatar('google');
        sp.srcTags='Influencer High';
        sp.getSrcTags();
        sp.srcTags='non Influencer High';
        sp.getSrcTags();
        sp.pstTags='test data';
        sp.getPstTags();
        sp.postPriority='high';
        sp.getPostPriority();
        sp.setPostPriority('testString');
        sp.getPostedDate();
        sp.getDateTimeSocialURL();
        sp.getFormattedAvatar();
    }
    
    static testmethod void basicTest3() {
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        List<SocialPost> socialPostList = new List<SocialPost>();
        
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        Case testCase = new Case(ContactId=contactList[0].Id, Status='New', Origin='email', OwnerId = UserInfo.getUserid());
        caseList.add(testCase);
        insert caseList;
        
        SocialPost socialPostOutgoing = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing);
        SocialPost socialPostOutgoing1 = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Not Sent');
        socialPostList.add(socialPostOutgoing1);
        SocialPost socialPostOutgoing2 = new SocialPost(Name = 'TWEET FROM: testUser', R6Service__Status__c = 'REPLIED',Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, IsOutbound = false, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Not Sent');
        socialPostList.add(socialPostOutgoing2);
        SocialPost socialPostOutgoing3 = new SocialPost(Name = 'TWEET FROM: testUser', R6Service__Status__c = 'Not REPLIED',Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, IsOutbound = false, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Not Sent');
        socialPostList.add(socialPostOutgoing3);
        SocialPost socialPostOutgoing4 = new SocialPost(Name = 'TWEET FROM: testUser',Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, IsOutbound = false, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Not Sent');
        socialPostList.add(socialPostOutgoing4);
        SocialPost socialPostOutgoing5 = new SocialPost(Name = 'TWEET FROM: testUser',Posted = system.now(), Handle = 'testUser', Provider = 'Facebook', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Not Sent');
        socialPostList.add(socialPostOutgoing5);
        SocialPost socialPostOutgoing6 = new SocialPost(Name = 'TWEET FROM: testUser',Posted = system.now(), Handle = 'testUser', Provider = 'Facebook', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing6);
        SocialPost socialPostOutgoing7 = new SocialPost(Name = 'TWEET FROM: testUser',Posted = system.now(), Handle = 'testUser', Provider = 'Facebook', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, IsOutbound = false, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com');
        socialPostList.add(socialPostOutgoing7);
        SocialPost socialPostOutgoing8 = new SocialPost(Name = 'TWEET FROM: testUser', R6Service__Status__c = 'REPLIED',Posted = system.now(), Handle = 'testUser', Provider = 'Facebook', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, IsOutbound = false, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com');
        socialPostList.add(socialPostOutgoing8);
        SocialPost socialPostOutgoing9 = new SocialPost(Name = 'TWEET FROM: testUser', R6Service__Status__c = 'NOT REPLIED',Posted = system.now(), Handle = 'testUser', Provider = 'Facebook', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, IsOutbound = false, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com');
        socialPostList.add(socialPostOutgoing9);
        SocialPost socialPostOutgoing10 = new SocialPost(Name = 'TWEET FROM: testUser', R6Service__Status__c = 'NOT REPLIED',Posted = system.now(), Handle = null, Provider = 'Facebook', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, IsOutbound = false, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com');
        socialPostList.add(socialPostOutgoing10);
        SocialPost socialPostOutgoing11 = new SocialPost(Name = 'TWEET FROM: testUser', R6Service__Status__c = 'REPLIED',Posted = system.now(), Handle = null, Provider = 'Facebook', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, IsOutbound = false, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com');
        socialPostList.add(socialPostOutgoing11);
        insert socialPostList;
        
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController(caseList[0]);
        CSC_CaseHistoryExtension caseUpdateLog = new CSC_CaseHistoryExtension(standardCtrl);
        PageReference p = Page.caseHistory;
        p.getParameters().put('id', caseList[0].id);
        Test.setCurrentPage(p);
        caseUpdateLog.setCheckBoxAttachments(true);
        caseUpdateLog.setCheckBoxComments(true);
        caseUpdateLog.setCheckBoxEmail(true);
        caseUpdateLog.setCheckBoxHistory(true);
        caseUpdateLog.setCheckBoxSocial(true);
        caseUpdateLog.setCheckBoxSurveys(true);
        caseUpdateLog.setCheckBoxTasks(true);
        caseUpdateLog.setCheckBoxAdmin(true);
        caseUpdateLog.setCheckBoxEvents(true);
        caseUpdateLog.getcase();
        caseUpdateLog.getHistories();
    }
}