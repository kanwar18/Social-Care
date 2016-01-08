/********************************************************************************************************
*    Author :     Accenture
*    Requirement: Test class for Social_CaseOutreachTimeCtrl
*    Version:     1.0
*    Created Date: 10th September 2015.
*********************************************************************************************************/

@istest (SeeAllData = false)
public class Social_CaseOutreachTimeCtrlTest{
    public static testMethod void Social_CaseOutreachTimeCtrlTestA (){
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<User> userList = new List<User>();
        List<SocialPost> socialPostList = new List<SocialPost>();
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser1', LastName =  'SCS', Case_Counter__c = 0, Alias = 'SCS1', CommunityNickname = 'scsTone1', Email = 'scsTest12345@gmail.com', Username = 'scsTest12345@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Available');
        userList.add(testOneUser);
        insert userList;
        
        //insert new contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert contactList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //Insert a case
        Case caseObj = new Case(Case_Assigned_Time__c = system.now(), Customer_Response_Received__c = true, ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Initiated', R6Service__SocialPersona__c = socialPersonaList[0].Id, First_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj);
        Case caseObj1 = new Case(Case_Assigned_Time__c = system.now(),Case_Reassigned_Time__c= system.now().addminutes(50), Customer_Response_Received__c = true, ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA2 - Initiated', R6Service__SocialPersona__c = socialPersonaList[0].Id, Second_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj1);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        SocialPost socialPostOutgoing = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing);
        SocialPost socialPostOutgoing2 = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[1].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing2);
        system.runAs (userList[0]) {
            insert socialPostList;
        }
        Social_CaseOutreachTimeCtrl OutreachTimeCtrl = new Social_CaseOutreachTimeCtrl();
    }
    
    public static testMethod void Social_CaseOutreachTimeCtrlTestB (){
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<User> userList = new List<User>();
        List<SocialPost> socialPostList = new List<SocialPost>();
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser1', LastName =  'SCS', Case_Counter__c = 0, Alias = 'SCS1', CommunityNickname = 'scsTone1', Email = 'scsTest12345@gmail.com', Username = 'scsTest12345@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Available');
        userList.add(testOneUser);
        insert userList;
        
        //insert new contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert contactList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //Insert a case
        Case caseObj = new Case(Case_Assigned_Time__c = system.now(),Do_Not_Reassign_Timeframe__c = 'Do Not Reassign', Customer_Response_Received__c = true, ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Initiated', R6Service__SocialPersona__c = socialPersonaList[0].Id, First_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj);
        Case caseObj1 = new Case(Case_Assigned_Time__c = system.now(),Case_Reassigned_Time__c= system.now().addminutes(50),Do_Not_Reassign_Timeframe__c = 'Do Not Reassign', Customer_Response_Received__c = true, ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA2 - Initiated', R6Service__SocialPersona__c = socialPersonaList[0].Id, Second_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj1);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        SocialPost socialPostOutgoing = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing);
        SocialPost socialPostOutgoing2 = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[1].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing2);
        system.runAs (userList[0]) {
            insert socialPostList;
        }
    }
    
    public static testMethod void Social_CaseOutreachTimeCtrlTestC (){
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<User> userList = new List<User>();
        List<SocialPost> socialPostList = new List<SocialPost>();
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser1', LastName =  'SCS', Case_Counter__c = 0, Alias = 'SCS1', CommunityNickname = 'scsTone1', Email = 'scsTest12345@gmail.com', Username = 'scsTest12345@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Available');
        userList.add(testOneUser);
        insert userList;
        
        //insert new contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert contactList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //Insert a case
        Case caseObj = new Case(Case_Assigned_Time__c = system.now(),Case_Reassigned_Time__c = system.now().addminutes(20),Customer_Response_Received_Time__c = system.now().addminutes(10),Last_Outreach_Time__c = system.now(),Do_Not_Reassign_Timeframe__c = 'Do Not Reassign', Customer_Response_Received__c = true, ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Initiated', R6Service__SocialPersona__c = socialPersonaList[0].Id, First_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj);
        Case caseObj1 = new Case(Case_Assigned_Time__c = system.now(),Customer_Response_Received_Time__c = system.now().addminutes(10),Last_Outreach_Time__c = system.now(),Do_Not_Reassign_Timeframe__c = 'Do Not Reassign', Customer_Response_Received__c = true, ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA2 - Initiated', R6Service__SocialPersona__c = socialPersonaList[0].Id, Second_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj1);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        SocialPost socialPostOutgoing = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing);
        SocialPost socialPostOutgoing2 = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[1].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing2);
        system.runAs (userList[0]) {
            insert socialPostList;
        }
    }
    
    public static testMethod void Social_CaseOutreachTimeCtrlTestD (){
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        List<SocialPersona> socialPersonaList = new List<SocialPersona>();
        List<User> userList = new List<User>();
        List<SocialPost> socialPostList = new List<SocialPost>();
        Profile p1 = [Select id from profile where name = 'Care Manager'];
        
        //Insert new user
        User testOneUser = new User(FirstName = 'SCSTestUser1', LastName =  'SCS', Case_Counter__c = 0, Alias = 'SCS1', CommunityNickname = 'scsTone1', Email = 'scsTest12345@gmail.com', Username = 'scsTest12345@test.com', emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', ProfileId = p1.Id, TimeZoneSidKey = 'America/Los_Angeles', Availability__c = 'Available');
        userList.add(testOneUser);
        insert userList;
        
        //insert new contact
        Contact contactObj = new Contact(FirstName = 'Test', LastName = 'User');
        contactList.add(contactObj);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert contactList;
        
        //Insert new persona
        SocialPersona socialPersonaObj = new SocialPersona(MediaType = 'Twitter', ProfileType = 'Person', MediaProvider = 'TWITTER', ExternalId = '1111111111', ProfileUrl = 'http://twitter.com/TestUser', Followers = 3, ExternalPictureURL = 'http://pbs.twimg.com/profile_images/534375867116310529/JaCY26_L_normal.jpeg', RealName = 'Test User', Name = 'TestUser', R6SourceId = '1111111111', TopicType = 'Managed', ListedCount = 0, Following = 9, NumberOfTweets = 20, Provider = 'Twitter', ParentId = contactList[0].Id);
        socialPersonaList.add(socialPersonaObj);
        insert socialPersonaList;
        
        //Insert a case
        Case caseObj = new Case(Case_Assigned_Time__c = system.now(),Case_Reassigned_Time__c = system.now().addminutes(20),Customer_Response_Received_Time__c = system.now().addhours(-6),Last_Outreach_Time__c = system.now().addHours(-8),Do_Not_Reassign_Timeframe__c = 'Do Not Reassign', Customer_Response_Received__c = false, ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA1 - Initiated', R6Service__SocialPersona__c = socialPersonaList[0].Id, First_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj);
        Case caseObj1 = new Case(Case_Assigned_Time__c = system.now(),Customer_Response_Received_Time__c = system.now().addminutes(10),Last_Outreach_Time__c = system.now().addHours(-6),Do_Not_Reassign_Timeframe__c = 'Do Not Reassign', Customer_Response_Received__c = false, ownerId = userList[0].Id, Status = 'New', Priority = 'Medium', ContactId = contactList[0].Id, Subject = 'TWEET FROM: testUser', Case_Post_Tag__c = 'autodir,Unknown', Social_Media_Source__c = 'Twitter', RecordTypeId = system.Label.ConsumerCareCase, Social_Care_Handle_Name__c = 'Testing my test class for SCS', Social_Persona_Name__c = 'TestUser', Current_SLA_Phase__c = 'SLA2 - Initiated', R6Service__SocialPersona__c = socialPersonaList[0].Id, Second_SLA_Scheduled_Time__c = system.now());
        caseList.add(caseObj1);
        Social_CaseAssignmentUtility.executeTriggerCode = false;
        Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        insert caseList;
        
        SocialPost socialPostOutgoing = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[0].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing);
        SocialPost socialPostOutgoing2 = new SocialPost(Name = 'TWEET FROM: testUser', Posted = system.now(), Handle = 'testUser', Provider = 'Twitter', MessageType = 'Reply', ExternalPostId = '111111111111111111', Content = 'Testing my test class for SCS', ParentId = caseList[1].Id, Status = 'Sent', IsOutbound = true, Attachment_Type__c = 'Unknown', Attachment_URL__c = 'https://test.com', StatusMessage = 'Sent');
        socialPostList.add(socialPostOutgoing2);
        system.runAs (userList[0]) {
            insert socialPostList;
        }
    }
    
}