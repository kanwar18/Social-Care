/**************************************************************************
Class Name: Social_TestCaseActivityHandler
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: Test class for Social_CaseActivityHandler
Version History: Abhishek(16/May/2014)
**************************************************************************************************************************/
@isTest(SeeAllData = true)
private class Social_TestCaseActivityHandler {
    static User testOneUser;
    static User testTwoUser;
    static User testThreeUser;
    static Account caseAccount;
    static Contact testContact;
    static Profile sysAdmin;
    static Profile careManager;
    static QueueSobject testQueue;
    static Assignment_Group_Name__c testAssignmentGroup;
    static Assignment_Groups__c testMemberOne;
    static Assignment_Groups__c testMemberTwo;
    static Assignment_Groups__c testMemberThree;
    static Case testCase;
    static Task slaTwoTask;
    static Task slaTaskTwo;
    
    Public static List<Assignment_Groups__c> caseAssignmentList = new List<Assignment_Groups__c>();
    Public static List<User> userList = new List<User>();
    Public static List<Task> TaskList = new List<Task>();
    
    static{
        // Query Profile
        sysAdmin = [Select p.Name, p.Id From Profile p where p.Name='System Administrator' 
                            limit 1];
                            
        careManager = [Select p.Name, p.Id From Profile p where p.Name='Care Manager' 
                            limit 1];                             
        
        // Query Queue
        testQueue = [Select q.SobjectType, q.Queue.Name, q.QueueId, q.Id From QueueSobject q 
                                  where q.Queue.Name ='Spanish' limit 1];
        
        // Query Assignment Group
        testAssignmentGroup = [Select a.Name, a.Id From Assignment_Group_Name__c a 
                                                        where a.Name='Spanish' limit 1];
                                                        
                
        // Insert Group Members
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
        //insert testOneUser;
        userList.add(testOneUser); 
        
        testTwoUser = new User();
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
        
        testThreeUser = new User();
        testThreeUser.FirstName = 'Test1';
        testThreeUser.LastName =  'three';
        testThreeUser.Alias = 'Tone1';
        testThreeUser.CommunityNickname = 'Tone1';
        testThreeUser.Email = 'abc1@gmail.com';
        testThreeUser.Username = 'abc1@gmail.com.social';
        testThreeUser.emailencodingkey = 'UTF-8';
        testThreeUser.languagelocalekey = 'en_US';
        testThreeUser.localesidkey = 'en_US';
        testThreeUser.ProfileId = careManager.Id;
        testThreeUser.TimeZoneSidKey = 'America/Los_Angeles';
        testThreeUser.Availability__c = 'Available';
        //insert testThreeUser;
        userList.add(testThreeUser); 
         
        insert userList;       
        
        // Insert Account
        caseAccount = new Account();
        caseAccount.Name = 'Case Account';
        insert caseAccount;
        
        // Insert Contact
        testContact = new Contact();
        testContact.Email = 'abc@gmail.com';
        testContact.FirstName = 'FirstName';
        testContact.LastName = 'LastName';
        testContact.AccountId = caseAccount.Id;
        insert testContact;
        
        testMemberOne = new Assignment_Groups__c();
        testMemberOne.Last_Assignment__c =  System.now();
        testMemberOne.User__c = testOneUser.Id;
        testMemberOne.Group_Name__c = testAssignmentGroup.Id;
        //insert testMemberOne;
        caseAssignmentList.add(testMemberOne); 
        
        testMemberTwo =  new Assignment_Groups__c();
        testMemberTwo.Last_Assignment__c = System.now();
        testMemberTwo.User__c = testTwoUser.Id;
        testMemberTwo.Group_Name__c = testAssignmentGroup.Id;
        //insert testMemberTwo;
        caseAssignmentList.add(testMemberTwo);
        
        testMemberThree = new Assignment_Groups__c();
        testMemberThree.Last_Assignment__c = System.now();
        testMemberThree.User__c = testThreeUser.Id;
        testMemberThree.Group_Name__c = testAssignmentGroup.Id;
        //insert testMemberThree;
        caseAssignmentList.add(testMemberThree);
        
        insert caseAssignmentList;
        
         // Insert Test Case
        testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case';
        testCase.OwnerId = testOneUser.Id;
        testCase.ContactId = testContact.Id;
        testCase.Case_Post_Tag__c = 'SPANISH';
        insert testCase;
    
        slaTwoTask = new Task();
    }
    
    static testMethod void socialPostTestPart1() {
        
        // Update Case
        testCase.First_SLA_Response_Time__c = System.now();
        testCase.Current_SLA_Phase__c = 'SLA1 - Initiated';
        testCase.Social_Persona_Name__c = 'Att_TestHandle';
        testCase.Track_Case_Queue__c = testQueue.QueueId;
        testCase.Case_Post_Tag__c = 'SPANISH';
        update testCase;
        
        Test.startTest();
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
        
        Event slaOneEvent = new Event();
        slaOneEvent.WhatId = testCase.Id;
        slaOneEvent.Event_Type__c = 'SLA - 1';
        slaOneEvent.Event_Status__c = 'Open';
        slaOneEvent.Description = 'SLA1 Event';
        slaOneEvent.OwnerId = testOneUser.Id;
        slaOneEvent.StartDateTime = System.now();
        slaOneEvent.DurationInMinutes = 15;
        slaOneEvent.IsReminderSet = true;
        slaOneEvent.ReminderDateTime = System.now().addMinutes(12);
        slaOneEvent.Subject = 'SLA - 1' + ':' + testOneUser.Name + ':' + testCase.CaseNumber;
        
        Event secondSlaEvent = new Event();
        secondSlaEvent.WhatId = testCase.Id;
        secondSlaEvent.Event_Type__c = 'SLA - 2';
        secondSlaEvent.Event_Status__c = 'Open';
        secondSlaEvent.Description = 'SLA2 Event';
        secondSlaEvent.OwnerId = testOneUser.Id;
        secondSlaEvent.StartDateTime = System.now();
        secondSlaEvent.DurationInMinutes = 60;
        secondSlaEvent.IsReminderSet = true;
        secondSlaEvent.ReminderDateTime = System.now().addMinutes(45);
        secondSlaEvent.Subject = 'SLA - 2' + ':' + testOneUser.Name + ':' + testCase.CaseNumber;
        
        // Insert Event Records
        List<Event> eventList = new List<Event>();
        eventList.add(firstSlaEvent);
        eventList.add(slaOneEvent);
        eventList.add(secondSlaEvent);
        insert eventList;   

        Test.stopTest();
        
    }
    
        static testMethod void socialPostTestPart1a() {
    
        Test.startTest();
    
       // SLA-1 End Task
        System.runAs(testOneUser){
            
            Task slaOneTask = new Task();
            slaOneTask.WhatId = testCase.Id;
            slaOneTask.ActivityDate = System.now().date();
            slaOneTask.Status = 'Completed';
            slaOneTask.Subject = 'SLA-1 End Task';
            slaOneTask.OwnerId = testOneUser.Id;
            insert slaOneTask;
        }
        
         
        // SLA-2 Start Task
        testCase.Current_SLA_Phase__c = 'SLA1 - Ended';
        update testCase;
        Test.stopTest();
        
        slaTwoTask.WhatId = testCase.Id;
        slaTwoTask.ActivityDate = System.now().date();
        slaTwoTask.Status = 'Completed';
        slaTwoTask.Subject = 'SLA-2 Customer Response Task';
        slaTwoTask.Event_Type__c = 'SLA - 2';
        slaTwoTask.OwnerId = testOneUser.Id;
        insert slaTwoTask; 
        
        
    }
    
    static testMethod void socialPostTestPart1b() {
        Test.startTest();
            // SLA-1 End Task
            System.runAs(testThreeUser){
                Task slaOneTask = new Task();
                slaOneTask.WhatId = testCase.Id;
                slaOneTask.ActivityDate = System.now().date();
                slaOneTask.Status = 'Completed';
                slaOneTask.Subject = 'SLA-1 End Task';
                slaOneTask.OwnerId = testThreeUser.Id;
                insert slaOneTask;
            }       
        Test.stopTest();
    }
    
    static testMethod void socialPostTestPart2b() {
        Test.startTest();    
            // SLA-2 Start Task
            testCase.Current_SLA_Phase__c = 'SLA1 - Ended';
            testCase.RecordTypeId=SYSTEM.LABEL.ConsumerCareCase;
            update testCase;         
        Test.stopTest();
    }
    
    static testMethod void socialPostTestPart3b() {
        Test.startTest();
            slaTwoTask.WhatId = testCase.Id;
            slaTwoTask.ActivityDate = System.now().date();
            slaTwoTask.Status = 'Completed';
            slaTwoTask.Subject = 'SLA-2 Customer Response Task';
            slaTwoTask.Event_Type__c = 'SLA - 2';
            slaTwoTask.OwnerId = testThreeUser.Id;
            insert slaTwoTask; 
        Test.stopTest();
    }

    static testMethod void socialPostTestPart1c() {
        Test.startTest();
            // SLA-1 End Task
            System.runAs(testThreeUser){
                Task slaOneTask = new Task();
                slaOneTask.WhatId = testCase.Id;
                slaOneTask.ActivityDate = System.now().date();
                slaOneTask.Status = 'Completed';
                slaOneTask.Subject = 'SLA-1 End Task';
                slaOneTask.OwnerId = testThreeUser.Id;
                insert slaOneTask;
            }    
        Test.stopTest();
    }
    
    static testMethod void socialPostTestPart2c() {
        Test.startTest();
            slaTwoTask.WhatId = testCase.Id;
            slaTwoTask.ActivityDate = System.now().date();
            slaTwoTask.Status = 'Completed';
            slaTwoTask.Subject = 'SLA-2 Customer Response Task';
            slaTwoTask.Event_Type__c = 'SLA - 2';
            slaTwoTask.OwnerId = testThreeUser.Id;
            insert slaTwoTask; 
        Test.stopTest();
    }
    
        static testMethod void socialPostTestPart2() {
        // UPDATE TEST METHOD LIMITS
         Test.startTest();
         Social_CaseAssignmentUtility.executeTriggerCode = false;
         Social_StreamingUtil.doNtFireEmail2CaseRun = false;
        // SLA-2 Start (Owner Unavailable)
        testCase.Current_SLA_Phase__c = 'SLA1 - Ended';
        testCase.OwnerId = testOneUser.Id;
        testCase.Case_Post_Tag__c = 'MOBILITY';
        update testCase;
        
        testOneUser.Availability__c = 'Lunch';
        update testOneUser;
        
        slaTaskTwo = new Task();
        slaTaskTwo.WhatId = testCase.Id;
        slaTaskTwo.ActivityDate = System.now().date();
        slaTaskTwo.Status = 'Completed';
        slaTaskTwo.Subject = 'SLA-2 Customer Response Task';
        slaTwoTask.Event_Type__c = 'SLA - 2';
        slaTaskTwo.OwnerId = testOneUser.Id;
        insert slaTaskTwo;
        
        // SLA-2 End Task
        testCase.Current_SLA_Phase__c = 'SLA2 - Initiated';
        testCase.OwnerId = testOneUser.Id;
        update testCase;      
        
        System.runAs(testOneUser){
            
            Task secondslaTask = new Task();
            secondslaTask.WhatId = testCase.Id;
            secondslaTask.ActivityDate = System.now().date();
            secondslaTask.Status = 'Completed';
            secondslaTask.Subject = 'SLA-2 End Task';
            secondslaTask.OwnerId = testOneUser.Id;
            insert secondslaTask;
        }        
        Test.stopTest();    
    }


    
}