@isTest(SeeAllData = True)
public class Social_CaseActivityHandler_Test{

    public static Id caseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Case');     
   
    static testmethod void processTaskRecordsTest(){   
     Social_caseActivityHandler actHandle = new Social_caseActivityHandler(new List<Id>());    
     Map<Id,List<Event>> caseSLAMap = new Map<Id,List<Event>>();
     Map<Id, Map<String, List<Event>>> caseEventMap = new Map<Id, Map<String, List<Event>>>();
     Map<String, List<Event>> existMap = new Map<String, List<Event>>();
     
     List<Event> eveList = new List<Event>();
        Profile p1 = [select id, name from profile where name='Care Manager Business'];      
        
        User u1 = new User(alias = 's141', email='standarduser141@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', 
        Availability__c= 'Available', 
        username='standarduser141@accenture.com');
        insert u1;
        
        User u2 = new User(alias = 's142', email='standarduser142@testorg.com',
        emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p1.Id, isactive=true,
        timezonesidkey='America/Los_Angeles', 
        Availability__c= 'Available', 
        username='standarduser142@accenture.com');
        insert u2;
        
        Case singleCase = new Case();
        singleCase.Status = 'New';
        singleCase.OwnerId = u1.Id;
        singleCase.Social_Media_Source__c = 'ATT Small Biz';
        singleCase.Component_Primary__c = 'DSL';
        singleCase.RecordTypeId = caseRecordTypeId;
        singleCase.Current_SLA_Phase__c = 'SLA1 - Initiated';
        insert singleCase;
        
             
        Event singleEvent2 = new Event();
            singleEvent2.OwnerId = u2.Id;
            singleEvent2.Event_Status__c = 'Open';
            singleEvent2.WhatId = singleCase.Id;
            singleEvent2.StartDateTime = dateTime.now();
            singleEvent2.DurationInMinutes = 15;
            singleEvent2.IsAllDayEvent = FALSE;
            singleEvent2.Event_Type__c = 'SLA - 1';
            eveList.add(singleEvent2);  
            insert eveList ;
            existMap.put(eveList[0].Event_Type__c , eveList );
            caseEventMap.put(eveList[0].WhatId, existMap);
            
            Task task1 = new Task();
            task1.Type='Call';
            task1.WhatId = singleCase.Id;
            task1.Status = 'Completed';
            insert task1;  
            
            caseSLAMap.put(singleCase.Id,eveList);
            actHandle.processTaskRecords(task1);
            Social_caseActivityHandler.setReminderOff(caseSLAMap);
                 
         
    }
    
}