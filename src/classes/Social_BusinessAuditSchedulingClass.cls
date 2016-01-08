public class Social_BusinessAuditSchedulingClass {
    // Class Level Variables
      List<case> caseUpdateList = new List<case>();
    //Number of random cases to be returned.
      String s =System.Label.noOfAuditCases;
      Integer numberOfCases =Integer.ValueOf(s); 
     // adding the record type check on 21st April, so that audit job picks only Business specific closed cases    
      Id bsCloseCaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Business Care Closed Case'); // Stores record type id of Business Care Closed case Record Type
    public void initiateCaseAudit(){  
    // Method Variables
        List<Case> cases = [select caseNumber, ownerid, Audit_Status__c, ClosedDate,RecordTypeId , Closed_Operation_Manager__c, Reason From Case 
                            where Status='Closed' AND Audit_Status__c !='QA Not Needed' AND Audit_Status__c !='Under QA'
                            AND Audit_Status__c !='QA Completed' AND Reason ='Resolved' AND  ClosedDate = LAST_WEEK
                            AND RecordTypeId =: bsCloseCaseRecordTypeId ];
        Map<Id,List<Case>> ownerCaseMap = new Map<Id,List<Case>>();
        
        // Case Owner-Case List Map
        for(Case auditCases:cases){
          
            if(ownerCaseMap.containsKey(auditCases.ownerId)){
                List<Case> existCase = ownerCaseMap.get(auditCases.ownerId);
                existCase.add(auditCases);
                ownerCaseMap.put(auditCases.ownerId, existCase);
                }
            else{
                List<Case> newcaseList = new List<Case>();
                newcaseList.add(auditCases);
                ownerCaseMap.put(auditCases.ownerId, newcaseList);
                }
        }
        
        // Call Case Random Method
        for(Id ownerId : ownerCaseMap.keyset()){
            caseRandomiser(ownerCaseMap.get(ownerId));
            }
        
        // Data Base Update
        try{
               update caseUpdateList;
           }
        catch(Exception e){
            System.debug('Exception found in the AuditCaseBatch Batch---'+e);
        } 
        
    }

    // Method To Pick Two Random Cases/Care Manager
    private void caseRandomiser(List<case> caseList){
      
        // Local Variables
        Set<Integer> indexSet = new Set<Integer>();
        
        // If Closed Cases Are Two or Less
        if(caseList.size()<=numberOfCases){
            
            // Update Case Audit Status
            for(case auditCase: caseList){
            auditCase.Audit_Status__c = 'Under QA';
            }
            
            // Add all case to list
            caseUpdateList.addAll(caseList);
            return;
        }
        else{
             // If Closed Cases Greater Than Two
                while(indexSet.size() < numberOfCases){
            // Get The Random Case Index
            Integer caseIndex = Math.mod(Integer.valueof(math.random() * 100), caseList.size());
                if(!indexSet.contains(caseIndex)){
                    // Update Case Status
                    caseList[caseIndex].Audit_Status__c = 'Under QA';
                    caseUpdateList.add(caseList[caseIndex]);
                   // Update Index Set
                    indexSet.add(caseIndex);
                }
            }  
        }
    }    
}