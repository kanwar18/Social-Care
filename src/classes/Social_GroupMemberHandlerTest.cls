/********************************************************************************************************
*    Author :     Accenture
*    Requirement: Test class 
*    Version:     1.0
*    Created Date: 5th May 2015.
*********************************************************************************************************/

@isTest(seeAllData = false)
Public class Social_GroupMemberHandlerTest {
    public static TestMethod void groupMemberCreationLogic () {
        List<Assignment_Group_Name__c> assignmentGroupList = new List<Assignment_Group_Name__c>();
        List<Assignment_Groups__c> groupMemberList = new List<Assignment_Groups__c>();
        List<User> userList = new List<User>();
        Profile careManagerProfile = [select id, name from profile where name = 'Care Manager'];
        
        User userObj = new User(alias = 'standt', email='testEmail@test.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = careManagerProfile.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', Availability__c = 'Available', 
        username='scsTestUser1@accenture.com');
        userList.add(userObj);
        insert userList;
        
        Assignment_Group_Name__c assignmentGroup = new Assignment_Group_Name__c();
        assignmentGroup.Name = 'Test Assignment Group';
        assignmentGroup.Type__c = 'Cases';
        assignmentGroup.Reopen_Duration_in_Hours__c = Integer.valueOf('24');
        assignmentGroupList.add(assignmentGroup);
        insert assignmentGroupList;
        
        Assignment_Groups__c groupMember = new Assignment_Groups__c();
        groupMember.Active__c = 'true';
        groupMember.Group_Name__c = assignmentGroupList[0].Id;
        groupMember.Last_Assignment__c = system.now();
        groupMember.User__c = userList[0].Id;
        groupMemberList.add(groupMember);
        insert groupMemberList;
    }
}