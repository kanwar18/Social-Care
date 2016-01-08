/********************************************************************************************************
*    Author :     Accenture
*    Requirement: Test class for inbound social post controller 
*    Version:     1.0
*    Created Date: 5th May 2015.
*********************************************************************************************************/

@isTest (seeAllData = true) 
Public class Social_SocialPostHandlerTest {
    Public static Social_SocialPostHandler handler = new Social_SocialPostHandler();
    public static TestMethod void processNewInboundTweetTest() {
        //New social post
        SocialPost socialPostObj = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', RecipientType = 'Person', TopicType = 'Managed', SpamRating = 'Not Spam', Sentiment = 'Neutral', PostPriority = 'Medium', MessageType = 'Tweet', PostUrl = 'http://twitter.com/TestUser/statuses/596002362369519616', R6PostId = '111111111111', ExternalPostId = '111111111111111111', R6TopicId = '111111', Recipient = '1111111111', R6SourceId = '1111111111', HarvestDate = system.Now(), TopicProfileName = 'SCS Test', PostTags = 'autodir,Unknown', Content = 'Testing my test class for SCS');
        //New social persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter');
        Map<String, Object> data = new Map<String, Object>();
        handler.handleInboundSocialPost(socialPostObj,socialPersonaObj,data);
        Social_SocialPostController socialPostHandler = new Social_SocialPostController();
        Social.InboundSocialPostResult result = socialPostHandler.inboundSocialPost(socialPostObj,socialPersonaObj,data);
    }
    
    /* This method is to cover caseUpdateCustomerResponseReceived method in class Social_SocialPostController */
    public static TestMethod void processExistingInboundTweetTest() {
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<User> userList = new List<User>();
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser1', LastName =  'SCS', Alias = 'SCS1', CommunityNickname = 'scsTone1', Email = 'scsTest12345@gmail.com', Username = 'scsTest12345@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Available');
        userList.add(testOneUser);
        insert userList;
        //insert contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        //Insert a case
        Case caseObj = new Case(Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Customer_Response_Received_Time__c = system.Now(), OwnerId = userInfo.getUserId(), Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Ended');
        caseList.add(caseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //update social persona id on case
        caseList[0].R6Service__SocialPersona__c = socialPersonaList[0].Id;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        update caseList;
        
        //Incoming social post
        SocialPost socialPostIncoming = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', RecipientType = 'Person', TopicType = 'Managed', SpamRating = 'Not Spam', Sentiment = 'Neutral', PostPriority = 'Medium', MessageType = 'Tweet', PostUrl = 'http://twitter.com/TestUser/statuses/596002362369519616', R6PostId = '111111111111', ExternalPostId = '111111111111111111', R6TopicId = '111111', Recipient = '1111111111', R6SourceId = '1111111111', HarvestDate = system.Now(), TopicProfileName = 'SCS Test', PostTags = 'autodir,Unknown', Content = 'Testing my test class for SCS');
        //Incoming social persona
        SocialPersona socialPersonaIncoming = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter');        
        Map<String, Object> data = new Map<String, Object>();
        Social_SocialPostController socialPostHandler = new Social_SocialPostController();
        Social.InboundSocialPostResult result = socialPostHandler.inboundSocialPost(socialPostIncoming,socialPersonaIncoming,data);
    }
    
    /* This method is to cover caseUpdateCustomerResponseReceived method in class Social_SocialPostController */
    public static TestMethod void processExistingInboundTweetWithUserOfflineTest() {
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<User> userList = new List<User>();
        List<Group> groupList = new List<Group>();
        groupList = [Select id from group where type = 'Queue' and name = 'U-Verse Care'];
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser11', LastName =  'SCS1', Alias = 'SCS11', CommunityNickname = 'scsTone11', Email = 'scsTest44@gmail.com', Username = 'scsTest44@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Offline');
        userList.add(testOneUser);
        insert userList;
        
        //insert contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        //Insert a case
        Case caseObj = new Case(ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Customer_Response_Received_Time__c = system.Now(), Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Ended', Track_Case_Queue__c = groupList[0].Id);
        caseList.add(caseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //update social persona id on case
        caseList[0].R6Service__SocialPersona__c = socialPersonaList[0].Id;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        update caseList;
        
        //New social post
        SocialPost socialPostIncoming = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', RecipientType = 'Person', TopicType = 'Managed', SpamRating = 'Not Spam', Sentiment = 'Neutral', PostPriority = 'Medium', MessageType = 'Tweet', PostUrl = 'http://twitter.com/TestUser/statuses/596002362369519616', R6PostId = '111111111111', ExternalPostId = '111111111111111111', R6TopicId = '111111', Recipient = '1111111111', R6SourceId = '1111111111', HarvestDate = system.Now(), PostTags = 'autodir,Unknown', Content = 'Testing my test class for SCS');
        //New social persona
        SocialPersona socialPersonaIncoming = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter');       
        Map<String, Object> data = new Map<String, Object>();
        Social_SocialPostController socialPostHandler = new Social_SocialPostController();
        Social.InboundSocialPostResult result = socialPostHandler.inboundSocialPost(socialPostIncoming,socialPersonaIncoming,data);
    }
    
    /* This method is to cover caseUpdateCustomerResponseReceived method in class Social_SocialPostController */
    public static TestMethod void processExistingInboundTweetWithUserOfflineTest1() {
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<User> userList = new List<User>();
        List<Group> groupList = new List<Group>();
        groupList = [Select id from group where type = 'Queue' and name = 'U-Verse Care'];
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser11', LastName =  'SCS1', Alias = 'SCS11', CommunityNickname = 'scsTone11', Email = 'scsTest44@gmail.com', Username = 'scsTest44@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Offline');
        userList.add(testOneUser);
        insert userList;
        
        //insert contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        //Insert a case
        Case caseObj = new Case(ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Customer_Response_Received_Time__c = system.Now(), Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Initiated', Track_Case_Queue__c = groupList[0].Id);
        caseList.add(caseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //update social persona id on case
        caseList[0].R6Service__SocialPersona__c = socialPersonaList[0].Id;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        update caseList;
        
        //New social post
        SocialPost socialPostIncoming = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', RecipientType = 'Person', TopicType = 'Managed', SpamRating = 'Not Spam', Sentiment = 'Neutral', PostPriority = 'Medium', MessageType = 'Tweet', PostUrl = 'http://twitter.com/TestUser/statuses/596002362369519616', R6PostId = '111111111111', ExternalPostId = '111111111111111111', R6TopicId = '111111', Recipient = '1111111111', R6SourceId = '1111111111', HarvestDate = system.Now(), TopicProfileName = 'SCS Test', PostTags = 'autodir,Unknown', Content = 'Testing my test class for SCS');
        //New social persona
        SocialPersona socialPersonaIncoming = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter');
        
        Map<String, Object> data = new Map<String, Object>();
        Social_SocialPostController socialPostHandler = new Social_SocialPostController();
        Social.InboundSocialPostResult result = socialPostHandler.inboundSocialPost(socialPostIncoming,socialPersonaIncoming,data);
    }
    
    /* This method is to cover caseUpdateCustomerResponseReceived method in class Social_SocialPostController */
    public static TestMethod void processExistingInboundTweetWithUserOfflineTest2() {
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<User> userList = new List<User>();
        List<Group> groupList = new List<Group>();
        groupList = [Select id from group where type = 'Queue' and name = 'U-Verse Care'];
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser11', LastName =  'SCS1', Alias = 'SCS11', CommunityNickname = 'scsTone11', Email = 'scsTest44@gmail.com', Username = 'scsTest44@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Offline');
        userList.add(testOneUser);
        insert userList;
        
        //insert contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        //Insert a case
        Case caseObj = new Case(ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Customer_Response_Received_Time__c = system.Now(), Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA2 - Initiated', Track_Case_Queue__c = groupList[0].Id);
        caseList.add(caseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //update social persona id on case
        caseList[0].R6Service__SocialPersona__c = socialPersonaList[0].Id;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        update caseList;
        
        //New social post
        SocialPost socialPostIncoming = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', RecipientType = 'Person', TopicType = 'Managed', SpamRating = 'Not Spam', Sentiment = 'Neutral', PostPriority = 'Medium', MessageType = 'Tweet', PostUrl = 'http://twitter.com/TestUser/statuses/596002362369519616', R6PostId = '111111111111', ExternalPostId = '111111111111111111', R6TopicId = '111111', Recipient = '1111111111', R6SourceId = '1111111111', HarvestDate = system.Now(), TopicProfileName = 'SCS Test', PostTags = 'autodir,Unknown', Content = 'Testing my test class for SCS');
        //New social persona
        SocialPersona socialPersonaIncoming = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter');
        
        Map<String, Object> data = new Map<String, Object>();
        Social_SocialPostController socialPostHandler = new Social_SocialPostController();
        Social.InboundSocialPostResult result = socialPostHandler.inboundSocialPost(socialPostIncoming,socialPersonaIncoming,data);
    }
    
     /* This method is to cover caseUpdateCustomerResponseReceived method in class Social_SocialPostController */
    public static TestMethod void processExistingInboundTweetWithUserOfflineTest3() {
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<User> userList = new List<User>();
        List<Group> groupList = new List<Group>();
        groupList = [Select id from group where type = 'Queue' and name = 'U-Verse Care'];
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser11', LastName =  'SCS1', Alias = 'SCS11', CommunityNickname = 'scsTone11', Email = 'scsTest44@gmail.com', Username = 'scsTest44@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Offline');
        userList.add(testOneUser);
        insert userList;
        
        //insert contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        //Insert a case
        Case caseObj = new Case(ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Customer_Response_Received_Time__c = system.Now(), Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Ended', Track_Case_Queue__c = groupList[0].Id, Do_Not_Reassign__c = true);
        caseList.add(caseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //update social persona id on case
        caseList[0].R6Service__SocialPersona__c = socialPersonaList[0].Id;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        update caseList;
        
        //New social post
        SocialPost socialPostIncoming = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', RecipientType = 'Person', TopicType = 'Managed', SpamRating = 'Not Spam', Sentiment = 'Neutral', PostPriority = 'Medium', MessageType = 'Tweet', PostUrl = 'http://twitter.com/TestUser/statuses/596002362369519616', R6PostId = '111111111111', ExternalPostId = '111111111111111111', R6TopicId = '111111', Recipient = '1111111111', R6SourceId = '1111111111', HarvestDate = system.Now(), TopicProfileName = 'SCS Test', PostTags = 'autodir,Unknown', Content = 'Testing my test class for SCS');
        //New social persona
        SocialPersona socialPersonaIncoming = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter');
        
        Map<String, Object> data = new Map<String, Object>();
        Social_SocialPostController socialPostHandler = new Social_SocialPostController();
        Social.InboundSocialPostResult result = socialPostHandler.inboundSocialPost(socialPostIncoming,socialPersonaIncoming,data);
    }
    
    /* This method is to cover caseUpdateCustomerResponseReceived method in class Social_SocialPostController */
    public static TestMethod void processExistingInboundTweetWithUserOfflineTest4() {
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<User> userList = new List<User>();
        List<Group> groupList = new List<Group>();
        groupList = [Select id from group where type = 'Queue' and name = 'U-Verse Care'];
        
        //insert contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        //Insert a case
        Case caseObj = new Case(ownerId = System.Label.PendingClouseQueueId, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Customer_Response_Received_Time__c = system.Now(), Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Ended', Track_Case_Queue__c = groupList[0].Id, Do_Not_Reassign__c = false);
        caseList.add(caseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20,Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //update social persona id on case
        caseList[0].R6Service__SocialPersona__c = socialPersonaList[0].Id;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        update caseList;
        
        //New social post
        SocialPost socialPostIncoming = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', RecipientType = 'Person', TopicType = 'Managed', SpamRating = 'Not Spam', Sentiment = 'Neutral', PostPriority = 'Medium', MessageType = 'Tweet', PostUrl = 'http://twitter.com/TestUser/statuses/596002362369519616', R6PostId = '111111111111', ExternalPostId = '111111111111111111', R6TopicId = '111111', Recipient = '1111111111', R6SourceId = '1111111111', HarvestDate = system.Now(), TopicProfileName = 'SCS Test', PostTags = 'autodir,Unknown', Content = 'Testing my test class for SCS');
        //New social persona
        SocialPersona socialPersonaIncoming = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20,Provider = 'Twitter');
        
        Map<String, Object> data = new Map<String, Object>();
        Social_SocialPostController socialPostHandler = new Social_SocialPostController();
        Social.InboundSocialPostResult result = socialPostHandler.inboundSocialPost(socialPostIncoming,socialPersonaIncoming,data);
    }
    
    public static TestMethod void processInboundTweetWithClosedCaseAndUserAvailable() {
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<Assignment_Group_Name__c> assignmentGroupList = new List<Assignment_Group_Name__c>();
        List<Group> groupList = new List<Group>();
        List<User> userList = new List<User>();
        groupList = [Select id from group where type = 'Queue' and name = 'U-Verse Care'];
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser1', LastName =  'SCS', Alias = 'SCS1', CommunityNickname = 'scsTone1', Email = 'scsTest12345@gmail.com', Username = 'scsTest12345@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Available');
        userList.add(testOneUser);
        insert userList;
        
        //Insert new assignment Group
        Assignment_Group_Name__c assignmentGroup = new Assignment_Group_Name__c(Name = 'Test Assignment Group', Type__c = 'Cases', Reopen_Duration_in_Hours__c = Integer.valueOf('-9'));
        assignmentGroupList.add(assignmentGroup);
        insert assignmentGroupList;
        
        //insert contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        //Insert a case
        Case caseObj = new Case(OwnerId = userList[0].Id, Status = 'Closed', Reason = 'Completed', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Customer_Response_Received_Time__c = system.Now(), Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerClosedCase_RT, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Track_Case_Queue__c = groupList[0].Id, Current_SLA_Phase__c = 'SLA1 - Ended');
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        caseList.add(caseObj);
        
        Case caseObj1 = new Case(OwnerId = groupList[0].Id, Status = 'Closed', Reason = 'Completed', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Customer_Response_Received_Time__c = system.Now(), Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerClosedCase_RT, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Track_Case_Queue__c = groupList[0].Id, Current_SLA_Phase__c = 'SLA1 - Ended');
        caseList.add(caseObj1);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20,Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //update social persona id on case
        caseList[0].R6Service__SocialPersona__c = socialPersonaList[0].Id;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        update caseList;
        
        //New social post
        SocialPost socialPostIncoming = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', RecipientType = 'Person', TopicType = 'Managed', SpamRating = 'Not Spam', Sentiment = 'Neutral', PostPriority = 'Medium', MessageType = 'Tweet', PostUrl = 'http://twitter.com/TestUser/statuses/596002362369519616', R6PostId = '111111111111', ExternalPostId = '111111111111111111', R6TopicId = '111111', Recipient = '1111111111', R6SourceId = '1111111111', HarvestDate = system.Now(), TopicProfileName = 'SCS Test', PostTags = 'autodir,Unknown', Content = 'Testing my test class for SCS');
        //New social persona
        SocialPersona socialPersonaIncoming = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20,Provider = 'Twitter');
        
        Map<String, Object> data = new Map<String, Object>();
        Social_SocialPostController socialPostHandler = new Social_SocialPostController();
        Social.InboundSocialPostResult result = socialPostHandler.inboundSocialPost(socialPostIncoming,socialPersonaIncoming,data);
    }
    
    public static TestMethod void processInboundTweetWithClosedCaseAndUserOffline() {
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<Assignment_Group_Name__c> assignmentGroupList = new List<Assignment_Group_Name__c>();
        List<Group> groupList = new List<Group>();
        List<User> userList = new List<User>();
        groupList = [Select id from group where type = 'Queue' and name = 'U-Verse Care'];
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        
        //Insert new user       
        User testOneUser1 = new User(FirstName = 'SCSTestUser2', LastName =  'SCS2', Alias = 'SCS2', CommunityNickname = 'scsTone2', Email = 'scsTest67890@gmail.com', Username = 'scsTest67890@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Offline');
        userList.add(testOneUser1);
        insert userList;
        
        //Insert new assignment Group
        Assignment_Group_Name__c assignmentGroup = new Assignment_Group_Name__c(Name = 'Test Assignment Group', Type__c = 'Cases', Reopen_Duration_in_Hours__c = Integer.valueOf('-9'));
        assignmentGroupList.add(assignmentGroup);
        insert assignmentGroupList;
        
        //insert contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        //Insert a case        
        Case caseObj1 = new Case(Status = 'Closed', Reason = 'Completed', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Customer_Response_Received_Time__c = system.Now(), OwnerId = groupList[0].Id, Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerClosedCase_RT, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Track_Case_Queue__c = groupList[0].Id, Current_SLA_Phase__c = 'SLA1 - Ended');
        caseList.add(caseObj1);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20,Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //update social persona id on case
        caseList[0].R6Service__SocialPersona__c = socialPersonaList[0].Id;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        update caseList;
        
        //New social post
        SocialPost socialPostIncoming = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', RecipientType = 'Person', TopicType = 'Managed', SpamRating = 'Not Spam', Sentiment = 'Neutral', PostPriority = 'Medium', MessageType = 'Tweet', PostUrl = 'http://twitter.com/TestUser/statuses/596002362369519616', R6PostId = '111111111111', ExternalPostId = '111111111111111111', R6TopicId = '111111', Recipient = '1111111111', R6SourceId = '1111111111', HarvestDate = system.Now(), TopicProfileName = 'SCS Test', PostTags = 'autodir,Unknown', Content = 'Testing my test class for SCS');
        //New social persona
        SocialPersona socialPersonaIncoming = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20,Provider = 'Twitter');

        Map<String, Object> data = new Map<String, Object>();
        Social_SocialPostController socialPostHandler = new Social_SocialPostController();
        Social.InboundSocialPostResult result = socialPostHandler.inboundSocialPost(socialPostIncoming,socialPersonaIncoming,data);
    }
    
    public static TestMethod void processExistingInboundTweetWithOutCaseTest() {
        List<Contact> contactList = new List<Contact>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        
        //insert contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20,Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //New social post
        SocialPost socialPostIncoming = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', RecipientType = 'Person', TopicType = 'Managed', SpamRating = 'Not Spam', Sentiment = 'Neutral', PostPriority = 'Medium', MessageType = 'Tweet', PostUrl = 'http://twitter.com/TestUser/statuses/596002362369519616', R6PostId = '111111111111', ExternalPostId = '111111111111111111', R6TopicId = '111111', Recipient = '1111111111', R6SourceId = '1111111111', HarvestDate = system.Now(), TopicProfileName = 'SCS Test', PostTags = 'autodir,Unknown', Content = 'Testing my test class for SCS');
        //New social persona
        SocialPersona socialPersonaIncoming = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20,Provider = 'Twitter');
        
        Map<String, Object> data = new Map<String, Object>();
        Social_SocialPostController socialPostHandler = new Social_SocialPostController();
        Social.InboundSocialPostResult result = socialPostHandler.inboundSocialPost(socialPostIncoming,socialPersonaIncoming,data);
    }
    
    public static TestMethod void processExistingInboundTweetWithCaseBusinessCase() {
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<Assignment_Group_Name__c> assignmentGroupList = new List<Assignment_Group_Name__c>();
        List<Group> groupList = new List<Group>();
        List<User> userList = new List<User>();
        groupList = [Select id from group where type = 'Queue' and name = 'General-bc'];
        Profile p1 = [Select id from profile where name = 'Care Manager Business'];
        
        //Insert new user       
        User testOneUser1 = new User(FirstName = 'SCSTestUser4', LastName =  'SCS4', Alias = 'SCS4', CommunityNickname = 'scsTone4', Email = 'scsTest334433@gmail.com', Username = 'scsTest334433@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Available');
        userList.add(testOneUser1);
        insert userList;
        
        //Insert new assignment Group
        Assignment_Group_Name__c assignmentGroup = new Assignment_Group_Name__c(Name = 'Test Assignment Group', Type__c = 'Cases');
        assignmentGroupList.add(assignmentGroup);
        insert assignmentGroupList;
        
        //insert contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        //Insert a case        
        Case caseObj1 = new Case(Status = 'Closed', Reason = 'Completed', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', OwnerId = userList[0].Id, Case_Post_Tag__c = 'GCS-GEN', Business_Case_Post_Tag__c = 'GCS-GEN', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.Business_Closed_RT, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Track_Case_Queue__c = groupList[0].Id, Current_SLA_Phase__c = 'SLA1 - Ended');
        caseList.add(caseObj1);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20,Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //update social persona id on case
        caseList[0].R6Service__SocialPersona__c = socialPersonaList[0].Id;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        update caseList;
        
        //New social post
        SocialPost socialPostIncoming = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', RecipientType = 'Person', TopicType = 'Managed', SpamRating = 'Not Spam', Sentiment = 'Neutral', PostPriority = 'Medium', MessageType = 'Tweet', PostUrl = 'http://twitter.com/TestUser/statuses/596002362369519616', R6PostId = '111111111111', ExternalPostId = '111111111111111111', R6TopicId = '111111', Recipient = '1111111111', R6SourceId = '1111111111', HarvestDate = system.Now(), TopicProfileName = 'SCS Test', PostTags = 'autodir,Unknown', Content = 'Testing my test class for SCS');
        //New social persona
        SocialPersona socialPersonaIncoming = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20,Provider = 'Twitter');
        
        Map<String, Object> data = new Map<String, Object>();
        Social_SocialPostController socialPostHandler = new Social_SocialPostController();
        Social.InboundSocialPostResult result = socialPostHandler.inboundSocialPost(socialPostIncoming,socialPersonaIncoming,data);
    }
    public static TestMethod void inReplyToTest() {
        //New social post
        SocialPost socialPostObj = new SocialPost(Name = 'Reply From: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Facebook', RecipientType = 'Person', TopicType = 'Managed', SpamRating = 'Not Spam', Sentiment = 'Neutral', PostPriority = 'Medium', MessageType = 'Reply', PostUrl = 'http://www.facebook.com/permalink.php?story_fbid=770747593024377&id=577126789053126&comment_id=770748796357590', R6PostId = '111111111111', ExternalPostId = '111111111111111111', R6TopicId = '111111', Recipient = '1111111111', R6SourceId = '1111111111', HarvestDate = system.Now(), TopicProfileName = 'SCS Test', PostTags = 'General, autodir', Content = 'Replying 1st time', ReplyToId = NULL);
        //New social persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Facebook', ProfileType = 'Person', MediaProvider = 'Facebook', ExternalId = '1111111111', ProfileUrl = 'http://facebook.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0,  Provider = 'Facebook');
        Map<String, Object> data = new Map<String, Object>();
        handler.handleInboundSocialPost(socialPostObj,socialPersonaObj,data);
        Social_SocialPostController socialPostHandler = new Social_SocialPostController();
        Social.InboundSocialPostResult result = socialPostHandler.inboundSocialPost(socialPostObj,socialPersonaObj,data);
    } 
    
    public static TestMethod void inReplyToTestExistingCaseOpen() {
 
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<User> userList = new List<User>();
        List<Group> groupList = new List<Group>();
        groupList = [Select id from group where type = 'Queue' and name = 'U-Verse Care'];
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser11', LastName =  'SCS1', Alias = 'SCS11', CommunityNickname = 'scsTone11', Email = 'scsTest44@gmail.com', Username = 'scsTest44@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Offline');
        userList.add(testOneUser);
        insert userList;
        
        //insert contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        //Insert a case
        Case caseObj = new Case(ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Customer_Response_Received_Time__c = system.Now(), Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Facebook', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Ended', Track_Case_Queue__c = groupList[0].Id);
        caseList.add(caseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(ParentId = contactObj.Id, MediaType = 'Facebook', ProfileType = 'Person', MediaProvider = 'Facebook', ExternalId = '1111111111', ProfileUrl = 'http://facebook.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0,  Provider = 'Facebook');
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //update social persona id on case
        caseList[0].R6Service__SocialPersona__c = socialPersonaList[0].Id;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        update caseList;
        //New social post
        SocialPost socialPostObj = new SocialPost(Name = 'Reply From: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Facebook', RecipientType = 'Person', TopicType = 'Managed', SpamRating = 'Not Spam', Sentiment = 'Neutral', PostPriority = 'Medium', MessageType = 'Reply', PostUrl = 'http://www.facebook.com/permalink.php?story_fbid=770747593024377&id=577126789053126&comment_id=770748796357590', R6PostId = '111111111111', ExternalPostId = '111111111111111111', R6TopicId = '111111', Recipient = '1111111111', R6SourceId = '1111111111', HarvestDate = system.Now(), TopicProfileName = 'SCS Test', PostTags = 'General, autodir', Content = 'Replying 1st time', ReplyToId = NULL);
        //New social persona
        SocialPersona socialPersonaObj1 = new SocialPersona(MediaType = 'Facebook', ProfileType = 'Person', MediaProvider = 'Facebook', ExternalId = '1111111111', ProfileUrl = 'http://facebook.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0,  Provider = 'Facebook');
        Map<String, Object> data = new Map<String, Object>();
        handler.handleInboundSocialPost(socialPostObj,socialPersonaObj,data);
        Social_SocialPostController socialPostHandler = new Social_SocialPostController();
        Social.InboundSocialPostResult result = socialPostHandler.inboundSocialPost(socialPostObj,socialPersonaObj,data);
    }
    public static TestMethod void inReplyToTestExistingCaseClose() {
 
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<User> userList = new List<User>();
        List<Group> groupList = new List<Group>();
        groupList = [Select id from group where type = 'Queue' and name = 'U-Verse Care'];
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser11', LastName =  'SCS1', Alias = 'SCS11', CommunityNickname = 'scsTone11', Email = 'scsTest44@gmail.com', Username = 'scsTest44@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Offline');
        userList.add(testOneUser);
        insert userList;
        
        //insert contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        //Insert a case
        Case caseObj = new Case(ownerId = userList[0].Id, Status = 'Closed', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Customer_Response_Received_Time__c = system.Now(), Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Facebook', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Ended', Track_Case_Queue__c = groupList[0].Id);
        caseList.add(caseObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(ParentId = contactObj.Id, MediaType = 'Facebook', ProfileType = 'Person', MediaProvider = 'Facebook', ExternalId = '1111111111', ProfileUrl = 'http://facebook.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0,  Provider = 'Facebook');
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //update social persona id on case
        caseList[0].R6Service__SocialPersona__c = socialPersonaList[0].Id;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        update caseList;
        //New social post
        SocialPost socialPostObj = new SocialPost(Name = 'Reply From: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Facebook', RecipientType = 'Person', TopicType = 'Managed', SpamRating = 'Not Spam', Sentiment = 'Neutral', PostPriority = 'Medium', MessageType = 'Reply', PostUrl = 'http://www.facebook.com/permalink.php?story_fbid=770747593024377&id=577126789053126&comment_id=770748796357590', R6PostId = '111111111111', ExternalPostId = '111111111111111111', R6TopicId = '111111', Recipient = '1111111111', R6SourceId = '1111111111', HarvestDate = system.Now(), TopicProfileName = 'SCS Test', PostTags = 'General, autodir', Content = 'Replying 1st time', ReplyToId = NULL);
        //New social persona
        SocialPersona socialPersonaObj1 = new SocialPersona(MediaType = 'Facebook', ProfileType = 'Person', MediaProvider = 'Facebook', ExternalId = '1111111111', ProfileUrl = 'http://facebook.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0,  Provider = 'Facebook');
        Map<String, Object> data = new Map<String, Object>();
        handler.handleInboundSocialPost(socialPostObj,socialPersonaObj,data);
        Social_SocialPostController socialPostHandler = new Social_SocialPostController();
        Social.InboundSocialPostResult result = socialPostHandler.inboundSocialPost(socialPostObj,socialPersonaObj,data);
    }
    }