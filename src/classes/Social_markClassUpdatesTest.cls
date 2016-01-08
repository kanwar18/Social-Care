/**************************************************************************
Class Name: Social_markClassUpdatesTest
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: Test class for Social_markClassUpdates
Version History: Haemen Shah (7/31/2014)
****************************************************************************/
@isTest(SeeAllData=true)
public class Social_markClassUpdatesTest{
    
    static testMethod void Social_markClassUpdatesTestA(){
         
        List<User> userList = new List<User>();
        List<Assignment_Groups__c> caseAssignmentList = new List<Assignment_Groups__c>();
        List<Case> CaseList = new List<Case>();
        
        // Query Profile
        Profile sysAdmin = [Select p.Name, p.Id From Profile p where p.Name='System Administrator' limit 1];
        
        // Query Assignment Group
        Assignment_Group_Name__c testAssignmentGroup = [Select a.Name, a.Id From Assignment_Group_Name__c a where a.Name='Spanish' limit 1];
        
        // Query Queue
        QueueSobject testQueue = [Select q.SobjectType, q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name ='Spanish' limit 1];
                
        // Inserting User
        User testOneUser = new User();
        testOneUser.FirstName = 'Test1';
        testOneUser.LastName =  'One1';
        testOneUser.Alias = 'Tone1';
        testOneUser.CommunityNickname = 'Tone';
        testOneUser.Email = 'abc1@gmail.com';
        testOneUser.Username = 'abc1@gmail.com.social';
        testOneUser.emailencodingkey = 'UTF-8';
        testOneUser.languagelocalekey = 'en_US';
        testOneUser.localesidkey = 'en_US';
        testOneUser.ProfileId = sysAdmin.Id;
        testOneUser.TimeZoneSidKey = 'America/Los_Angeles';
        testOneUser.Availability__c = 'Available';
        
        //insert testOneUser;
        userList.add(testOneUser); 
            
        User testTwoUser = new User();
        testTwoUser.FirstName = 'Test';
        testTwoUser.LastName =  'Two';
        testTwoUser.Alias = 'Ttwo';
        testTwoUser.CommunityNickname = 'Ttwo';
        testTwoUser.Email = 'cba@gmail.com';
        testTwoUser.Username = 'cba@gmail.com.social';
        testTwoUser.emailencodingkey = 'UTF-8';
        testTwoUser.languagelocalekey = 'en_US';
        testTwoUser.localesidkey = 'en_US';
        testTwoUser.ProfileId = sysAdmin.Id;
        testTwoUser.TimeZoneSidKey = 'America/Los_Angeles';
        testTwoUser.Availability__c = 'Available';
        //insert testTwoUser;
        userList.add(testTwoUser);
        
        insert userList;
        
        Assignment_Groups__c testMemberOne = new Assignment_Groups__c();
        testMemberOne.Last_Assignment__c =  System.now();
        testMemberOne.User__c = testOneUser.Id;
        testMemberOne.Group_Name__c = testAssignmentGroup.Id;
        //insert testMemberOne;
        caseAssignmentList.add(testMemberOne);
        
        insert caseAssignmentList;
        
        // Insert Test Case
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case';
        testCase.OwnerId = testOneUser.Id;
        testCase.RecordTypeId = system.Label.ConsumerCareCase;
        testCase.Current_SLA_Phase__c = 'SLA1 - Initiated';
        testCase.Social_Media_Source__c = 'Ask Answer';
        testCase.Component_Primary__c = 'Digital Life';
        testCase.Component_Secondary__c = 'Digital Life-Camera';
        caseList.add(testCase);
                
        insert caseList;
        testCase.Reassignment_Reason__c = 'Not trained';
        //testCase.OwnerId = testQueue.id;
        //update caseList;
        
        // Create Events
        Event firstSlaEvent = new Event();
        firstSlaEvent.WhatId = testCase.Id;
        firstSlaEvent.Event_Type__c = 'SLA - 1';
        firstSlaEvent.Event_Status__c = 'Open';
        firstSlaEvent.Description = 'SLA1 Event';
        firstSlaEvent.OwnerId = testOneUser.Id;
        firstSlaEvent.StartDateTime = System.now();
        firstSlaEvent.DurationInMinutes = 15;
        firstSlaEvent.IsReminderSet = true;
        firstSlaEvent.ReminderDateTime = System.now().addMinutes(12);
        firstSlaEvent.Subject = 'SLA - 1' + ':' + testOneUser.Name + ':' + testCase.CaseNumber;
               
        // Insert Event Records
        List<Event> eventList = new List<Event>();
        eventList.add(firstSlaEvent);
        insert eventList;
        
        Social_markCaseUpdates.caseSlaReset(testCase, testCase.OwnerId);
        
        
       
    }
    static testMethod void Social_markClassUpdatesTestB(){
         
        List<User> userList = new List<User>();
        List<Assignment_Groups__c> caseAssignmentList = new List<Assignment_Groups__c>();
        List<Case> CaseList = new List<Case>();
        
        // Query Profile
        Profile sysAdmin = [Select p.Name, p.Id From Profile p where p.Name='System Administrator' limit 1];
        
        // Query Assignment Group
        Assignment_Group_Name__c testAssignmentGroup = [Select a.Name, a.Id From Assignment_Group_Name__c a where a.Name='Spanish' limit 1];
        
        // Query Queue
        QueueSobject testQueue = [Select q.SobjectType, q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name ='Spanish' limit 1];
                
        // Inserting User
        User  testTwoUser = new User();
        testTwoUser.FirstName = 'Test';
        testTwoUser.LastName =  'Two';
        testTwoUser.Alias = 'Ttwo';
        testTwoUser.CommunityNickname = 'Ttwo';
        testTwoUser.Email = 'cba@gmail.com';
        testTwoUser.Username = 'cba@gmail.com.social';
        testTwoUser.emailencodingkey = 'UTF-8';
        testTwoUser.languagelocalekey = 'en_US';
        testTwoUser.localesidkey = 'en_US';
        testTwoUser.ProfileId = sysAdmin.Id;
        testTwoUser.TimeZoneSidKey = 'America/Los_Angeles';
        testTwoUser.Availability__c = 'Available';
        //insert testTwoUser;
        userList.add(testTwoUser); 
        
        insert userList;
        
        Assignment_Groups__c testMemberOne = new Assignment_Groups__c();
        testMemberOne.Last_Assignment__c =  System.now();
        testMemberOne.User__c = testTwoUser.Id;
        testMemberOne.Group_Name__c = testAssignmentGroup.Id;
        //insert testMemberOne;
        caseAssignmentList.add(testMemberOne);
        
        insert caseAssignmentList;
        
        // Insert Test Case
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case';
        testCase.OwnerId = testTwoUser.Id;
        testCase.RecordTypeId = system.Label.ConsumerCareCase;
        testCase.Current_SLA_Phase__c = 'SLA2 - Initiated';
        caseList.add(testCase);
                
        insert caseList;
        testCase.Reassignment_Reason__c = 'Not trained';
        testCase.Social_Media_Source__c = 'Ask Answer';
        testCase.Component_Primary__c = 'Digital Life';
        testCase.Component_Secondary__c = 'Digital Life-Camera';
        update caseList;
        
        Event secondSlaEvent = new Event();
        secondSlaEvent.WhatId = testCase.Id;
        secondSlaEvent.Event_Type__c = 'SLA - 2';
        secondSlaEvent.Event_Status__c = 'Open';
        secondSlaEvent.Description = 'SLA2 Event';
        secondSlaEvent.OwnerId = testTwoUser.Id;
        secondSlaEvent.StartDateTime = System.now();
        secondSlaEvent.DurationInMinutes = 60;
        secondSlaEvent.IsReminderSet = true;
        secondSlaEvent.ReminderDateTime = System.now().addMinutes(45);
        secondSlaEvent.Subject = 'SLA - 2' + ':' + testTwoUser.Name + ':' + testCase.CaseNumber;
               
        // Insert Event Records
        List<Event> eventList = new List<Event>();
        eventList.add(secondSlaEvent);
        insert eventList;
        
        Social_markCaseUpdates.caseSlaReset(testCase, testCase.OwnerId);
        
        
    }
    
    static testMethod void Social_markClassUpdatesTestC(){
         
        List<User> userList = new List<User>();
        List<Assignment_Groups__c> caseAssignmentList = new List<Assignment_Groups__c>();
        List<Case> CaseList = new List<Case>();
        Set<case> CaseSet= new set<case>();
        
        // Query Profile
        Profile sysAdmin = [Select p.Name, p.Id From Profile p where p.Name='System Administrator' limit 1];
        
        // Query Assignment Group
        Assignment_Group_Name__c testAssignmentGroup = [Select a.Name, a.Id From Assignment_Group_Name__c a where a.Name='Spanish' limit 1];
        
        // Query Queue
        QueueSobject testQueue = [Select q.SobjectType, q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name ='Spanish' limit 1];
                
        // Inserting User
        User  testTwoUser = new User();
        testTwoUser.FirstName = 'Test';
        testTwoUser.LastName =  'Two';
        testTwoUser.Alias = 'Ttwo';
        testTwoUser.CommunityNickname = 'Ttwo';
        testTwoUser.Email = 'cba@gmail.com';
        testTwoUser.Username = 'cba@gmail.com.social';
        testTwoUser.emailencodingkey = 'UTF-8';
        testTwoUser.languagelocalekey = 'en_US';
        testTwoUser.localesidkey = 'en_US';
        testTwoUser.ProfileId = sysAdmin.Id;
        testTwoUser.TimeZoneSidKey = 'America/Los_Angeles';
        testTwoUser.Availability__c = 'Available';
        //insert testTwoUser;
        userList.add(testTwoUser); 
        
        insert userList;
        
        Assignment_Groups__c testMemberOne = new Assignment_Groups__c();
        testMemberOne.Last_Assignment__c =  System.now();
        testMemberOne.User__c = testTwoUser.Id;
        testMemberOne.Group_Name__c = testAssignmentGroup.Id;
        //insert testMemberOne;
        caseAssignmentList.add(testMemberOne);
        
        insert caseAssignmentList;
        
        // Insert Test Case
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case';
        testCase.OwnerId = testTwoUser.Id;
        testCase.RecordTypeId = system.Label.ConsumerCareCase;
        testCase.Current_SLA_Phase__c = 'SLA2 - Initiated';
       
        
        testCase.Reassignment_Reason__c = 'Not trained';
        testCase.Social_Media_Source__c = 'Ask Answer';
        testCase.Component_Primary__c = 'Digital Life';
        testCase.Component_Secondary__c = 'Digital Life-Camera';
        testCase.Case_Reassigned_Time__c=system.now();
        CaseList.add(testCase);
        insert CaseList;
        CaseSet.add(testcase); 
        
        Social_markCaseUpdates.CaseReassignments(CaseSet,'Assign a Case','Assigned');
        
        
    }
    
    static testMethod void Social_markClassUpdatesTestD(){
         
        List<User> userList = new List<User>();
        List<Assignment_Groups__c> caseAssignmentList = new List<Assignment_Groups__c>();
        List<Case> CaseList = new List<Case>();
        Set<case> CaseSet= new set<case>();
        
        // Query Profile
        Profile sysAdmin = [Select p.Name, p.Id From Profile p where p.Name='System Administrator' limit 1];
        
        // Query Assignment Group
        Assignment_Group_Name__c testAssignmentGroup = [Select a.Name, a.Id From Assignment_Group_Name__c a where a.Name='Spanish' limit 1];
        
        // Query Queue
        QueueSobject testQueue = [Select q.SobjectType, q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name ='Spanish' limit 1];
                
        // Inserting User
        User  testTwoUser = new User();
        testTwoUser.FirstName = 'Test';
        testTwoUser.LastName =  'Two';
        testTwoUser.Alias = 'Ttwo';
        testTwoUser.CommunityNickname = 'Ttwo';
        testTwoUser.Email = 'cba@gmail.com';
        testTwoUser.Username = 'cba@gmail.com.social';
        testTwoUser.emailencodingkey = 'UTF-8';
        testTwoUser.languagelocalekey = 'en_US';
        testTwoUser.localesidkey = 'en_US';
        testTwoUser.ProfileId = sysAdmin.Id;
        testTwoUser.TimeZoneSidKey = 'America/Los_Angeles';
        testTwoUser.Availability__c = 'Unavailable';
        //insert testTwoUser;
        userList.add(testTwoUser); 
        
        insert userList;
        
        Assignment_Groups__c testMemberOne = new Assignment_Groups__c();
        testMemberOne.Last_Assignment__c =  System.now();
        testMemberOne.User__c = testTwoUser.Id;
        testMemberOne.Group_Name__c = testAssignmentGroup.Id;
        //insert testMemberOne;
        caseAssignmentList.add(testMemberOne);
        
        insert caseAssignmentList;
        
        // Insert Test Case
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case';
        testCase.OwnerId = testTwoUser.Id;
        testCase.RecordTypeId = system.Label.ConsumerCareCase;
        testCase.Current_SLA_Phase__c = 'SLA2 - Initiated';
        testCase.Track_Case_Queue__c = testQueue.id;
      
        
        testCase.Do_Not_Reassign__c  = true;
        testCase.Customer_Response_Received__c=true;
        testCase.Do_Not_Reassign_Timeframe__c='24 Hours';
        testCase.Component_Primary__c = 'Digital Life';
        testCase.Component_Secondary__c = 'Digital Life-Camera';
        testCase.Case_Reassigned_Time__c=system.now();
        CaseList.add(testCase);
        insert CaseList;
        testCase.Do_Not_Reassign_Timeframe__c='';
        update CaseList;
        testCase.Do_Not_Reassign_Timeframe__c='48 Hours';
        update CaseList;
        testCase.Do_Not_Reassign_Timeframe__c='72 Hours';
        update CaseList;
        
    }
    
    static testMethod void Social_markClassUpdatesTestE(){
    
        List<User> userList = new List<User>();
        List<Assignment_Groups__c> caseAssignmentList = new List<Assignment_Groups__c>();
        List<Case> CaseList = new List<Case>();
        
        // Query Profile
        Profile sysAdmin = [Select p.Name, p.Id From Profile p where p.Name='System Administrator' limit 1];
        
        // Query Assignment Group
        Assignment_Group_Name__c testAssignmentGroup = [Select a.Name, a.Id From Assignment_Group_Name__c a where a.Name='Spanish' limit 1];
        
        // Query Queue
        QueueSobject testQueue = [Select q.SobjectType, q.Queue.Name, q.QueueId, q.Id From QueueSobject q where q.Queue.Name ='Spanish' limit 1];
        
        // Query Queue
        Group TestQueue1 = [select Id from Group where Name = 'Spanish' and Type = 'Queue'];
        
                
        // Inserting User
        User  testTwoUser = new User();
        testTwoUser.FirstName = 'Test';
        testTwoUser.LastName =  'Two';
        testTwoUser.Alias = 'Ttwo';
        testTwoUser.CommunityNickname = 'Ttwo';
        testTwoUser.Email = 'cba@gmail.com';
        testTwoUser.Username = 'cba@gmail.com.social';
        testTwoUser.emailencodingkey = 'UTF-8';
        testTwoUser.languagelocalekey = 'en_US';
        testTwoUser.localesidkey = 'en_US';
        testTwoUser.ProfileId = sysAdmin.Id;
        testTwoUser.TimeZoneSidKey = 'America/Los_Angeles';
        testTwoUser.Availability__c = 'Available';
        //insert testTwoUser;
        userList.add(testTwoUser); 
        
        insert userList;
        
        Assignment_Groups__c testMemberOne = new Assignment_Groups__c();
        testMemberOne.Last_Assignment__c =  System.now();
        testMemberOne.User__c = userList[0].Id;
        testMemberOne.Group_Name__c = testAssignmentGroup.Id;
        //insert testMemberOne;
        caseAssignmentList.add(testMemberOne);
        
        insert caseAssignmentList;
        
        // Insert Test Case
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case';
        testCase.OwnerId = TestQueue1.Id;
        testCase.Case_Post_Tag__c = 'GCS-GEN';
        testCase.RecordTypeId = system.Label.ConsumerCareCase;
        testCase.Current_SLA_Phase__c = 'SLA2 - Initiated';
        
        caseList.add(testCase);
                
        insert caseList;
        testCase.Reassignment_Reason__c = 'Not trained';
        testCase.Social_Media_Source__c = 'Ask Answer';
        testCase.Component_Primary__c = 'Digital Life';
        testCase.Component_Secondary__c = 'Digital Life-Camera';
        update caseList;
        
        Event secondSlaEvent = new Event();
        secondSlaEvent.WhatId = testCase.Id;
        secondSlaEvent.Event_Type__c = 'SLA - 2';
        secondSlaEvent.Event_Status__c = 'Open';
        secondSlaEvent.Description = 'SLA2 Event';
        secondSlaEvent.OwnerId = testTwoUser.Id;
        secondSlaEvent.StartDateTime = System.now();
        secondSlaEvent.DurationInMinutes = 60;
        secondSlaEvent.IsReminderSet = true;
        secondSlaEvent.ReminderDateTime = System.now().addMinutes(45);
        secondSlaEvent.Subject = 'SLA - 2' + ':' + testTwoUser.Name + ':' + testCase.CaseNumber;
               
        // Insert Event Records
        List<Event> eventList = new List<Event>();
        eventList.add(secondSlaEvent);
        insert eventList;
        
        Social_markCaseUpdates.caseSlaReset(testCase, testCase.OwnerId);
             
        testCase.Current_SLA_Phase__c = 'SLA1 - Initiated';
        testCase.Case_Post_Tag__c = 'GCS-GEN';   
        testCase.First_SLA_Scheduled_Time__c = null;
        testCase.Case_Reassigned_Time__c = null; 
        update CaseList;
        Social_markCaseUpdates.caseSlaReset(testCase, testCase.OwnerId);
        
    
    }
}