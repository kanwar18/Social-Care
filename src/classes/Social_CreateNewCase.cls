/********************************************************************************************************
*    Author :     Arun Ramachandran
*    Requirement: To handle the scenario for creating a new case when customer replies to a case which is closed 
                  for more than 96 hrs
*    Version:     1.0
*    Created Date: 20th June 2014
*    Version:     1.0
*    Version:     1.1 : Added Availability check for Case Owner 10/13/2014 Added SOQL at line 53 and Condition check
                        at line 74
*********************************************************************************************************/

public class Social_CreateNewCase{
    
    public static void renewClosedCase(Map<Id,EmailMessage> caseEmailMap, List<EmailMessage> emailList){
    
        List<Case> caseReOpenList = new List<Case>(); // List of cases to be re-opened
        List<Case> renewCaseList = new List<Case>();
        List<Case> existCaseList = new List<Case>();
        List<Case> slaCreateCaseList = new List<Case>();
        Set<Id> caseOwnerIdSet = new Set<Id>();
        Set<Id> neglectCaseIdSet = new Set<Id>();
        Set<Id> ownerIdSet = new Set<Id>();
        Map<Id, List<Case>> countDecCaseUserMap = New Map<Id, List<Case>>();
        Map<Id, List<Case>> countIncCaseUserMap = New Map<Id, List<Case>>();
        Map<Id, List<Case>> countCloseCaseUserMap= New Map<Id, List<Case>>();        
        Map<Id,Id> caseIdMap = new Map<Id,Id>();
        Map<Id,Case> oldNewCaseMap = new Map<Id,Case>();
        Map<Id,String> ownerAvailability = new Map<Id, String>();        
        Id businessCaseOpenRT = System.Label.BUSINESS_OPEN_RT;
        Decimal diff;        
        decimal hours; // To calculate the number of days from closure and receipt of email 
        Datetime slaScheduledTime = datetime.now();
        Integer slaTimeframe = 15;
        
        // To query the details of the parent case retrieved in the above parentCaseId Set
        if(caseEmailMap.size()>0){
            for(Case singleCase: [Select Id,First_SLA_Scheduled_Time__c,Customer_Response_Received_Time__c, Content_Tag__c,Case_Assigned_Time__c, Status,Component_Primary__c,
                             ContactId,Origin,Subject,Description, readunreadcheck__c,Track_Case_Queue__c, 
                             Second_SLA_Start_Time__c ,Second_SLA_Scheduled_Time__c, Update_Reason__c, CaseNumber, 
                             OwnerId, Current_SLA_Phase__c, ClosedDate, RecordTypeId from Case where 
                             Id IN: caseEmailMap.keySet() AND (RecordTypeId =: System.Label.Business_Closed_RT OR RecordTypeId =: System.Label.Business_Case_Audit_Record_Type_ID)] ){
                      caseReOpenList.add(singleCase);
                      ownerIdSet.add(singleCase.OwnerId);
            }
        } 
        
        if(caseReOpenList.size()>0){
            for(Case dupeCase: [Select Id,ParentId,OwnerId,CaseNumber from Case WHERE ParentId IN: caseEmailMap.keySet() AND RecordTypeId =: businessCaseOpenRT]){
                if(dupeCase.ParentId != NULL){
                    oldNewCaseMap.put(dupeCase.ParentId, dupeCase);
                    neglectCaseIdSet.add(dupeCase.ParentId);
                    ownerIdSet.add(dupeCase.OwnerId);
                }
            }
            //Added Availability check for Case Owner 10/13/2014
            for(User singleUser : [Select Id, Availability__c from User where Id IN: ownerIdSet]){
                ownerAvailability.put(singleUser.Id,singleUser.Availability__c);
            }
        }
        
         //Calculate the number of days from closure and re-open if the number of days is greater than 96.0
        if(caseReOpenList.size()>0){
            for(Case singleCase: caseReOpenList){
                if(singleCase.Status == 'Closed' && (singleCase.RecordTypeId == System.Label.Business_Closed_RT || singleCase.RecordTypeId == System.Label.Business_Case_Audit_Record_Type_ID) && !neglectCaseIdSet.contains(singleCase.Id)){ 
                    diff= 0.0;
                    hours = 0.0;       
                    diff = decimal.valueof((System.Now().getTime() - singleCase.ClosedDate.getTime())/(60*60));
                    hours =(diff /1000);

                    if((hours > Double.ValueOf(SYSTEM.LABEL.Business_Email_Reopen))|| Test.isRunningTest()){
                        Case renewCase = new Case();
                        renewCase.Status = 'New';
                        renewCase.Update_Reason__c  = Social_StreamingUtil.BUSINESS_ROUND_ROBIN;
                        renewCase.NonCaseOwner_LastModifiedDate__c = system.now(); 
                        renewCase.readunreadcheck__c = TRUE;  
                        renewCase.Component_Primary__c = singleCase.Component_Primary__c;
                        renewCase.Origin = singleCase.Origin;
                        renewCase.Subject = singleCase.Subject;
                        renewCase.Description = caseEmailMap.get(singleCase.Id).TextBody ;
                        //Added Availability check for Case Owner 10/13/2014
                        if(ownerAvailability.containsKey(singleCase.OwnerId) && ownerAvailability.get(singleCase.OwnerId).equalsIgnoreCase('Available')){
                            renewCase.OwnerId = singleCase.OwnerId;
                            caseOwnerIdSet.add(renewCase.OwnerId);
                            if(renewCase.Current_SLA_Phase__c==NULL){
                                renewCase.Case_Assigned_Time__c = System.now();
                                renewCase.Current_SLA_Phase__c = 'SLA1 - Initiated';                            
                                renewCase.First_SLA_Scheduled_Time__c = slaScheduledTime.addMinutes(slaTimeframe);    
                                if(countDecCaseUserMap.containsKey(renewCase.OwnerId)){
                                    countDecCaseUserMap.get(renewCase.OwnerId).add(renewCase);
                                }
                                else{
                                    countDecCaseUserMap.put(renewCase.OwnerId,New List<Case>{renewCase});
                                } 
                            }
                        }
                        else{
                            renewCase.OwnerId = SYSTEM.LABEL.GENERAL_BC_QUEUE;
                        }
                        renewCase.ParentId = singleCase.Id;
                        renewCase.ContactId = singleCase.ContactId;
                        renewCase.Track_Case_Queue__c = singleCase.Track_Case_Queue__c;
                        renewCase.RecordTypeId = System.Label.Business_Open_RT; 
                        // Ashween added for ITS1472
                        renewCase.Customer_Response_Received_Time__c = System.now();                        
                        
                        Social_CaseUpdateStreamCtrl.caseId.add(renewCase.Id);
                        Social_StreamingUtil.processed.add(renewCase.Id);  
                        renewCaseList.add(renewCase);                      
                    }                                                         
               }  
               else{
                   existCaseList.add(oldNewCaseMap.get(singleCase.Id));
               }
           } 
       } 
       
       if(renewCaseList.size()>0){
           Database.SaveResult[] resultDB = database.insert(renewCaseList, false);
                try{
                    Integer loopCount = 0;
                    for(Database.SaveResult sr:resultDB)
                    {  
                        if(!sr.isSuccess())
                        {                    
                            Database.Error err = sr.getErrors()[0];                            
                            System.debug('Social_CreateNewCase: Error while creating new renewal case: ' +renewCaseList.get(loopCount).getSObjectType() + err.getMessage());                
                        }
                        loopCount++;
                    }
                 }                 
                 catch(Exception e){
                     System.debug('Social_CreateNewCase: Error while creating new renewal case: ' + e.getMessage());
                 }  
                 
                 for(Case mapCase: renewCaseList){
                     caseIdMap.put(mapCase.ParentId,mapCase.Id);
                 }        
                 for(Case singleCase: [Select Id,First_SLA_Scheduled_Time__c,Case_Assigned_Time__c, Status,Component_Primary__c,
                             ContactId,Origin,Subject,Description, readunreadcheck__c,Track_Case_Queue__c, 
                             Second_SLA_Start_Time__c ,Second_SLA_Scheduled_Time__c, Update_Reason__c, CaseNumber, 
                             OwnerId, Current_SLA_Phase__c, ClosedDate, RecordTypeId from Case where Id IN: caseIdMap.values()]){
                             if(singleCase.OwnerId != SYSTEM.LABEL.GENERAL_BC_QUEUE){
                                 slaCreateCaseList.add(singleCase);
                             }
                             
                 }
                 
                 if(caseOwnerIdSet.size()>0 && slaCreateCaseList.size() > 0){                 
                     Social_BusinessRoundRobin.reassignCaseSLAInitiation(slaCreateCaseList, caseOwnerIdSet);          
                 }
       }
       
         if(existCaseList.size()>0 || existCaseList!= null){
             for(Case mapCase: existCaseList){
                 caseIdMap.put(mapCase.ParentId,mapCase.Id);
             }
         }                 
         for(EmailMessage singleMail: emailList){
             if(caseIdMap.containsKey(singleMail.ParentId) && !neglectCaseIdSet.contains(singleMail.ParentId)){                         
                 singleMail.ParentId = caseIdMap.get(singleMail.ParentId);
             }
             else if(caseIdMap.containsKey(singleMail.ParentId) && neglectCaseIdSet.contains(singleMail.ParentId)){
                 singleMail.ParentId = oldNewCaseMap.get(singleMail.ParentId).Id;
             }
         }  
       
       if(countDecCaseUserMap.size()>0){
           Social_BusinessRoundRobin.countUserCaseUpdate(countIncCaseUserMap ,countDecCaseUserMap,countCloseCaseUserMap);
       }
    }
}