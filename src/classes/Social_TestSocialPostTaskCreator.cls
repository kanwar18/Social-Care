@isTest(SeeAllData=true)
private class Social_TestSocialPostTaskCreator {
    static Profile sysAdmin;
    static QueueSobject testQueue;
    static Assignment_Group_Name__c testAssignmentGroup;
    static Account postAccount;
    static Contact testContact;
    static User managerUser;
    static User testOneUser;
    static Assignment_Groups__c testMemberOne;
    static Case testCase;
    static Case closedCase;
    static SocialPost testPost;
    
    static {
         // Query Profile
        sysAdmin = [Select p.Name, p.Id From Profile p where p.Name='System Administrator' limit 1];
        
        // Query Queue
        testQueue = [Select q.SobjectType, q.Queue.Name, q.QueueId, q.Id From QueueSobject q 
                                  where q.Queue.Name ='Mobility' limit 1];
        
        // Query Assignment Group
        testAssignmentGroup = [Select a.Name, a.Id From Assignment_Group_Name__c a 
                                                        where a.Name='Mobility' limit 1];
    
        // Insert Account                          
        postAccount = new Account();
        postAccount.Name = 'Post Account';
        insert postAccount;
        
        // Insert Contact
        testContact = new Contact();
        testContact.Email = 'abc@gmail.com';
        testContact.FirstName = 'FirstName';
        testContact.LastName = 'LastName';
        testContact.AccountId = postAccount.Id;
        insert testContact;
        
        // Insert User/Group Members
        managerUser = new User();
        managerUser.FirstName = 'Test';
        managerUser.LastName =  'Manager';
        managerUser.Alias = 'TMan';
        managerUser.CommunityNickname = 'TMan';
        managerUser.Email = 'def@gmail.com';
        managerUser.Username = 'def@gmail.com.social';
        managerUser.emailencodingkey = 'UTF-8';
        managerUser.languagelocalekey = 'en_US';
        managerUser.localesidkey = 'en_US';
        managerUser.ProfileId = sysAdmin.Id;
        managerUser.TimeZoneSidKey = 'America/Los_Angeles';
        managerUser.Availability__c = 'Available';
        insert managerUser;
        
        testOneUser = new User();
        testOneUser.FirstName = 'Test';
        testOneUser.LastName =  'One';
        testOneUser.Alias = 'Tone';
        testOneUser.CommunityNickname = 'Tone';
        testOneUser.Email = 'abc@gmail.com';
        testOneUser.Username = 'abc@gmail.com.social';
        testOneUser.emailencodingkey = 'UTF-8';
        testOneUser.languagelocalekey = 'en_US';
        testOneUser.localesidkey = 'en_US';
        testOneUser.ProfileId = sysAdmin.Id;
        testOneUser.TimeZoneSidKey = 'America/Los_Angeles';
        testOneUser.Availability__c = 'Available';
        testOneUser.ManagerId = managerUser.Id;
        insert testOneUser;
        
        testMemberOne = new Assignment_Groups__c();
        testMemberOne.Last_Assignment__c =  System.now();
        testMemberOne.User__c = testOneUser.Id;
        testMemberOne.Group_Name__c = testAssignmentGroup.Id;
        insert testMemberOne;
        
         // Insert Test Case(User Owner)
        testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case';
        testCase.OwnerId = testOneUser.Id;
        testCase.ContactId = testContact.Id;
        insert testCase;
        
        // Insert Closed Case
        closedCase = new Case();
        closedCase.Subject = 'Test Case';
        closedCase.Description = 'Test Case';
        closedCase.OwnerId = testOneUser.Id;
        closedCase.ContactId = testContact.Id;
        closedCase.Root_Cause__c = 'Billing Error';
        closedCase.Component_Primary__c = 'DSL';
        closedCase.Effort__c = 'Simple';
        closedCase.Reason = 'Completed';
        closedCase.Customer_Type__c = 'Enterprise';
        closedCase.Method_of_Contact__c='NA'; 
        insert closedCase;
        
        // Insert Social Post
        testPost = new SocialPost();
        testPost.WhoId = testContact.Id;
        testPost.ParentId = testCase.Id;
        testPost.Content = 'Sample Tweet';
        testPost.R6Service__AuthorSocialHandle__c = 'Att_TestHandle';
        testPost.Headline = 'TWEET FROM: Att_TestHandle';
        testPost.Name = 'Att_TestHandle';
        insert testPost;
        
    }
    
    

    // Test Method For Social_SocialPostTaskCreator Trigger
    static testMethod void postTaskCreator() {
        
        
        // Insert The Initial Social Post
        SocialPost initialPost = new SocialPost();
        initialPost.WhoId = testContact.Id;
        initialPost.ParentId = testCase.Id;
        initialPost.Content = 'Initial Tweet';
        initialPost.R6Service__AuthorSocialHandle__c = 'Att_TestHandle';
        initialPost.Headline = 'TWEET FROM: Att_TestHandle';
        initialPost.Name = 'Att_TestHandle';
        insert initialPost;
        
        // Update Case
        testCase.Track_Case_Queue__c = testQueue.QueueId;
        testCase.Current_SLA_Phase__c = 'SLA1 - Ended';
        testCase.Social_Persona_Name__c = 'Att_TestHandle';
        update testCase;
      
        
        
        Test.startTest();
        // Update SLA
        
        closedCase.Case_PostTag__c = 'Mobility';
        closedCase.Current_SLA_Phase__c = 'SLA1 - Ended';
        closedCase.Status = 'Closed';
        closedCase.Clarify_CRM_Verified__c = 'No';
        update closedCase;
        
        // Update Social Post Record
        testPost.ParentId = closedCase.Id;
        update testPost;
        Test.stopTest();     
    }
    
    // Test Method for Social_UserDeactivateController Class
    static testMethod void loginUserDeactivate() {
        
        Social_UserDeactivateController loginController = new Social_UserDeactivateController();
        loginController.makeUserInactive();
        
    }
}