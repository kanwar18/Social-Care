@isTest(seeAllData = false)
public class Social_logCallTrackerTest{

    static Account testAccount;
    static Contact testContact;
    static Case testCase;
    static Event testEvent;
    static Event testEvent1;
    static task testtask;
    static
    {
        testAccount=new Account();
        testAccount.Name='testAccount';
        insert testAccount;
        
        testContact=new Contact();
        testContact.AccountId=testAccount.Id;
        testContact.LastName='testName';
        testContact.email='testemail@abc.com';
        testContact.Account = testAccount;
        insert testContact;  

        testCase=new Case();
        testCase.ContactId=testContact.Id;
        testCase.Status='New';
        testCase.Origin='email';
        testCase.Contact=testContact;
        insert testCase;
        
        testEvent = new Event();        
        testEvent.Event_Status__c='Open';        
        testEvent.Event_Type__c='SLA - 1';
        testEvent.DurationInMinutes=10;        
        testEvent.ActivityDateTime=System.Today();
        insert testEvent;
        
        testEvent1 = new Event();        
        testEvent1.Event_Status__c='Open';        
        testEvent1.Event_Type__c='SLA - 1';
        testEvent1.DurationInMinutes=10;        
        testEvent1.ActivityDateTime=System.Today();
        insert testEvent1;


        testtask = new task();
        testtask.Event_Type__c='SLA - 1';
        testtask.status='Open';
        insert testtask;
                
}   

public static TestMethod void log_call_trigger() {
        Test.startTest();                                 
            testCase.Current_SLA_Phase__c='SLA1 - Initiated';
            update testCase;
        Test.stopTest();
        
}

public static TestMethod void log_call_trigger9() {
        Test.startTest();                                         
            testEvent.WhatId=testCase.id;
            update testEvent;
        Test.stopTest();
        
}

public static TestMethod void log_call_trigger2() {
        Test.startTest();                                 
        testEvent1.WhatId=testCase.id;
        update testEvent1;


        testtask.WhatId=testCase.id;
        update testtask;
        
        testtask.status='Completed';
        update testtask;
        Test.stopTest();
        
} 
public static TestMethod void log_call_trigger3() {
        Test.startTest();                                 
            testtask.WhatId=testCase.id;
            update testtask;
        Test.stopTest();
}
 
public static TestMethod void log_call_trigger4() {
        Test.startTest();                                 
            testtask.status='Completed';
            update testtask;
        Test.stopTest();
        
} 
public static TestMethod void log_call_trigger1() {
        
        Test.startTest();                                 
        testCase.Current_SLA_Phase__c='SLA2 - Initiated';
        update testCase;

        Test.stopTest();
                
}

    public static TestMethod void log_call_trigger11(){
        
        Test.startTest();
        
        testtask.WhatId=testCase.id;
        testtask.status='Completed';
        testtask.Event_Type__c='SLA - 2';
        update testtask;
        
        Test.stopTest();
    } 
    public static TestMethod void log_call_trigger12(){
        
        testEvent.WhatId=testCase.id;
        update testEvent;
    }
    
    public static TestMethod void log_call_trigger13(){
        
        Test.startTest();
        task testtask1 = new task();
        testtask1.Event_Type__c='SLA - 1';
        testtask1.WhatId=testCase.id;  
        testtask1.status='Completed';
        insert testtask1;
        Test.stopTest();
    }

}