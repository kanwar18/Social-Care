/********************************************************************************************************
*    Author :     Accenture
*    Requirement: Test class for outbound social post controller/trigger
*    Version:     1.0
*    Created Date: 8th May 2015.
*********************************************************************************************************/

@isTest (seeAllData = false)
Public class Social_SocialPostOutboundTest {
    //Social_SocialPostTaskCreatorUtil socialPostCls = new Social_SocialPostTaskCreatorUtil();
     public static TestMethod void processNewOutboundPostTest() {
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<User> userList = new List<User>();
        List<SocialPost> socialPostList = new List<SocialPost>();
        List<SocialPost> socialPostListNonUser = new List<SocialPost>();
        List<Assignment_Group_Name__c> assignmentGroupList = new List<Assignment_Group_Name__c>();
        List<Assignment_Groups__c> groupMemberList = new List<Assignment_Groups__c>();
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        List<Group> groupList = new List<Group>();
        groupList = [Select id from group where type = 'Queue' and name = 'Mobility'];
        //Insert new assignment group
        Assignment_Group_Name__c assignmentGroup = new Assignment_Group_Name__c ();
        assignmentGroup.Name = 'Mobility Test';
        assignmentGroup.Type__c = 'Cases';
        assignmentGroupList.add(assignmentGroup);
        insert assignmentGroupList;
        
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser1', LastName =  'SCS', Case_Counter__c = 0, Alias = 'SCS1', CommunityNickname = 'scsTone1', Email = 'scsTest12345@gmail.com', Username = 'scsTest12345@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Available');
        userList.add(testOneUser);
        insert userList;
        
        //Insert new group member
        Assignment_Groups__c groupMember = new Assignment_Groups__c();
        groupMember.Active__c = 'True';
        groupMember.Group_Name__c = assignmentGroupList[0].Id;
        groupMember.User__c = userList[0].Id;
        groupMember.Last_Assignment__c = system.Now();
        groupMember.User_Queue_Id__c = groupList[0].Id;
        groupMemberList.add(groupMember);
        insert groupMemberList;
        
        //insert new contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        Contact contactObj1 = new Contact(FirstName = 'TestContact', LastName = 'User');
        contactList.add(contactObj1);
        insert contactList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //Insert a case
        Case caseObj = new Case(Case_Assigned_Time__c = system.now(), Customer_Response_Received__c = true, ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Initiated', R6Service__SocialPersona__c = socialPersonaList[0].Id, First_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj);
        Case caseObj1 = new Case(Case_Assigned_Time__c = system.now(), Customer_Response_Received__c = true, ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA2 - Initiated', R6Service__SocialPersona__c = socialPersonaList[0].Id, Second_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj1);
        Case caseObj2 = new Case(Case_Assigned_Time__c = system.now(), Customer_Response_Received__c = true, ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.Business_Open_RT, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA2 - Initiated', R6Service__SocialPersona__c = socialPersonaList[0].Id, Second_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj2);
        Case caseObj3 = new Case(Case_Assigned_Time__c = system.now(), Customer_Response_Received__c = true, ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Facebook', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA2 - Initiated', R6Service__SocialPersona__c = socialPersonaList[0].Id, Second_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj3);
        //Case inserted in a queue
        Case caseObj4 = new Case(Case_Assigned_Time__c = system.now(), Customer_Response_Received__c = true, ownerId = groupList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[1].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', R6Service__SocialPersona__c = socialPersonaList[0].Id);
        caseList.add(caseObj4);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        SocialPost socialPostOutgoing = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing);
        SocialPost socialPostOutgoing1 = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, Status = 'Sent', IsOutbound = false, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com');
        socialPostList.add(socialPostOutgoing1);
        SocialPost socialPostOutgoing2 = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[1].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing2);
        SocialPost socialPostOutgoing3 = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[2].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing3);
        SocialPost socialPostOutgoing4 = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[2].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostListNonUser.add(socialPostOutgoing4);
        SocialPost socialPostOutgoing5 = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[3].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing5);
        system.runAs (userList[0]) {
            insert socialPostList;
        }
        insert socialPostListNonUser;
    }
    
    public static TestMethod void processNewOutboundPostTest1() {
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<User> userList = new List<User>();
        List<SocialPost> socialPostList = new List<SocialPost>();
        List<Assignment_Group_Name__c> assignmentGroupList = new List<Assignment_Group_Name__c>();
        List<Assignment_Groups__c> groupMemberList = new List<Assignment_Groups__c>();
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        List<Group> groupList = new List<Group>();
        groupList = [Select id from group where type = 'Queue' and name = 'Digital Life'];
        //Insert new assignment group
        Assignment_Group_Name__c assignmentGroup = new Assignment_Group_Name__c ();
        assignmentGroup.Name = 'Digital Life Test';
        assignmentGroup.Type__c = 'Cases';
        assignmentGroupList.add(assignmentGroup);
        insert assignmentGroupList;
        
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser8', LastName =  'SCS', Case_Counter__c = 0, Alias = 'SCS8', CommunityNickname = 'scsTone1', Email = 'scsTest88990@gmail.com', Username = 'scsTest88990@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Available');
        userList.add(testOneUser);
        insert userList;
        
        //Insert new group member
        Assignment_Groups__c groupMember = new Assignment_Groups__c();
        groupMember.Active__c = 'True';
        groupMember.Group_Name__c = assignmentGroupList[0].Id;
        groupMember.User__c = userList[0].Id;
        groupMember.Last_Assignment__c = system.Now();
        groupMember.User_Queue_Id__c = groupList[0].Id;
        groupMemberList.add(groupMember);
        insert groupMemberList;
        
        //insert new contact
        Contact contactObj = new Contact(FirstName = 'ContactNumber2', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        Case caseObj = new Case(Case_Assigned_Time__c = system.now(), ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Initiated', R6Service__SocialPersona__c = socialPersonaList[0].Id, First_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj);
        //Case inserted in a queue
        Case caseObj1 = new Case(Case_Assigned_Time__c = system.now(), Customer_Response_Received__c = true, ownerId = groupList[0].Id, First_SLA_Scheduled_Time__c  = system.Now(),Current_SLA_Phase__c = 'SLA1 - Ended', Status = 'Escalated', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Digital Life', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', R6Service__SocialPersona__c = socialPersonaList[0].Id);
        caseList.add(caseObj1);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        SocialPost socialPostOutgoing = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing);
        system.runAs (userList[0]) {
            insert socialPostList;
        }
    }
    
    public static TestMethod void processNewOutboundPostTest3() {
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<User> userList = new List<User>();
        List<SocialPost> socialPostList = new List<SocialPost>();
        List<Assignment_Group_Name__c> assignmentGroupList = new List<Assignment_Group_Name__c>();
        List<Assignment_Groups__c> groupMemberList = new List<Assignment_Groups__c>();
        List<Event> eventList = new List<Event>();
        Profile p1 = [Select id from profile where name = 'HS Care Rep'];
        List<Group> groupList = new List<Group>();
        groupList = [Select id from group where type = 'Queue' and name = 'Forums'];
        //Insert new assignment group
        Assignment_Group_Name__c assignmentGroup = new Assignment_Group_Name__c ();
        assignmentGroup.Name = 'Forums Test';
        assignmentGroup.Type__c = 'Cases';
        assignmentGroupList.add(assignmentGroup);
        insert assignmentGroupList;
        
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser6', LastName =  'SCS', Case_Counter__c = 0, Alias = 'SCS6', CommunityNickname = 'scsTone1', Email = 'scsTest66779@gmail.com', Username = 'scsTest66779@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Available');
        userList.add(testOneUser);
        insert userList;
        
        //Insert new group member
        Assignment_Groups__c groupMember = new Assignment_Groups__c();
        groupMember.Active__c = 'True';
        groupMember.Group_Name__c = assignmentGroupList[0].Id;
        groupMember.User__c = userList[0].Id;
        groupMember.Last_Assignment__c = system.Now();
        groupMember.User_Queue_Id__c = groupList[0].Id;
        groupMemberList.add(groupMember);
        insert groupMemberList;
        
        //insert new contact
        Contact contactObj = new Contact(FirstName = 'ContactNumber1', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
                
        Case caseObj = new Case(Case_Assigned_Time__c = system.now(), ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Initiated', R6Service__SocialPersona__c = socialPersonaList[0].Id, First_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj);
        //Case inserted in a queue
        Case caseObj1 = new Case(Case_Assigned_Time__c = system.now(), ownerId = groupList[0].Id, First_SLA_Scheduled_Time__c  = system.Now(),Current_SLA_Phase__c = 'SLA2 - Ended', Status = 'Investigating', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Digital Life', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', R6Service__SocialPersona__c = socialPersonaList[0].Id);
        caseList.add(caseObj1);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        SocialPost socialPostIncoming = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', RecipientType = 'Person', TopicType = 'Managed', Sentiment = 'Neutral', PostPriority = 'Medium', MessageType = 'Tweet', PostUrl = 'http://twitter.com/TestUser/statuses/596002362369519616', R6PostId = '111111111111', ExternalPostId = '111111111111111111', R6TopicId = '111111', Recipient = '1111111111', R6SourceId = '1111111111', HarvestDate = system.Now(), TopicProfileName = 'SCS Test', PostTags = 'autodisc,Unknown', Content = 'Testing my test class for SCS', ParentId = caseList[1].Id, R6Service__PostTags__c = 'autodir');
        insert socialPostIncoming;
        
        Custom_Post__c customPostObj = new Custom_Post__c(Case__c = caseList[0].Id, Status__c = 'Approved');
        insert customPostObj;
        
        Event eventObj = new Event ();
        eventObj.whatId = caseList[0].Id;
        eventObj.Event_Type__c = 'SLA - 1';
        eventObj.Event_Status__c = 'Open';
        eventObj.Description = 'SLA 1 Events';
        eventObj.OwnerId = userList[0].Id;
        eventObj.StartDateTime = system.Now();
        eventObj.DurationInMinutes = 60;
        eventObj.IsReminderSet = false;
        eventObj.ReminderDateTime = system.Now().addMinutes(45);
        eventObj.Subject = 'SLA - 1:';
        eventList.add(eventObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert eventList;
        
        SocialPost socialPostOutgoing = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent', Post_Owner_Profile_Id__c = String.valueOf(p1.Id).subString(0,15));
        socialPostList.add(socialPostOutgoing);
        system.runAs (userList[0]) {
            insert socialPostList;
        }
        caseList[1].R6Service__InitialPostId__c = socialPostIncoming.Id;
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        update caseList;
    }
    
    public static TestMethod void processNewOutboundPostTest4() {
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        List<User> userList = new List<User>();
        List<Task> taskList = new List<Task>();
        List<Assignment_Group_Name__c> assignmentGroupList = new List<Assignment_Group_Name__c>();
        List<Assignment_Groups__c> groupMemberList = new List<Assignment_Groups__c>();
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        List<Group> groupList = new List<Group>();
        groupList = [Select id from group where type = 'Queue' and name = 'Digital Life'];
        //Insert new assignment group
        Assignment_Group_Name__c assignmentGroup = new Assignment_Group_Name__c ();
        assignmentGroup.Name = 'Digital Life Test';
        assignmentGroup.Type__c = 'Cases';
        assignmentGroupList.add(assignmentGroup);
        insert assignmentGroupList;
        
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser8', LastName =  'SCS', Case_Counter__c = 0, Alias = 'SCS8', CommunityNickname = 'scsTone1', Email = 'scsTest88990@gmail.com', Username = 'scsTest88990@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Available');
        userList.add(testOneUser);
        User testOneUser1 = new User(FirstName = 'SCSTestUser77', LastName =  'SCS', Case_Counter__c = 0, Alias = 'SCS7', CommunityNickname = 'scsTone7', Email = 'scsTest33554@gmail.com', Username = 'scsTest33554@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Available');
        userList.add(testOneUser1);
        insert userList;
        
        //Insert new group member
        Assignment_Groups__c groupMember = new Assignment_Groups__c();
        groupMember.Active__c = 'True';
        groupMember.Group_Name__c = assignmentGroupList[0].Id;
        groupMember.User__c = userList[0].Id;
        groupMember.Last_Assignment__c = system.Now();
        groupMember.User_Queue_Id__c = groupList[0].Id;
        groupMemberList.add(groupMember);
        insert groupMemberList;
        
        //insert new contact
        Contact contactObj = new Contact(FirstName = 'ContactNumber2', LastName = 'User');
        contactList.add(contactObj);
        insert contactList;
        
        Case caseObj = new Case(Case_Assigned_Time__c = system.now(), ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Initiated', First_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj);
        //Case inserted in a queue
        Case caseObj1 = new Case(Case_Assigned_Time__c = system.now(), Customer_Response_Received__c = true, ownerId = groupList[0].Id, First_SLA_Scheduled_Time__c  = system.Now(),Current_SLA_Phase__c = 'SLA1 - Ended', Status = 'Escalated', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Digital Life', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser');
        caseList.add(caseObj1);
        Case caseObj2 = new Case(Case_Assigned_Time__c = system.now(), ownerId = userList[1].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA2 - Initiated', First_SLA_Scheduled_Time__c = system.now(), Second_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj2);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        Task taskObj = new Task(Type='Call', whatId = caseList[0].Id);
        taskList.add(taskObj);
        Task taskObj1 = new Task(Type='Call', whatId = caseList[2].Id);
        taskList.add(taskObj1);
        
        system.runAs (userList[0]) {
            insert taskList;
        }
    }
}