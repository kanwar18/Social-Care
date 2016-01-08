public class Social_CSCAuditSchedulingClass {
    // Class Level Variables
      List<case> caseUpdateList = new List<case>();
    //Number of random cases to be returned.
      String s =System.Label.noOfAuditCases;
      Integer numberOfCases =Integer.ValueOf(s); 
      Public Static set<String> recordTypeIdSet = new Set<String>();
      
     
    public void initiateCaseAudit(){  
    // Method Variables
        recordTypeIdSet.addAll(Label.Consumer_RT.split(','));
        System.debug('Case list initiateCaseAudit()start line 10');
        List<Case> cases = [select caseNumber, ownerid, Audit_Status__c, ClosedDate, Closed_Operation_Manager__c, Reason From Case 
                            where (Status='Closed' OR Status='Auto Closed') AND Audit_Status__c !='Under QA' AND Audit_Status__c !='QA Completed' AND Reason =:'Completed' and ClosedDate = THIS_WEEK and recordtypeid IN: recordTypeIdSet];
        Map<Id,List<Case>> ownerCaseMap = new Map<Id,List<Case>>();
        System.debug('Case list initiateCaseAudit()end'+ cases);
        
        // Case Owner-Case List Map
        for(Case auditCases:cases){
            if(ownerCaseMap.containsKey(auditCases.ownerId)){
                System.debug('Case list inside For loop if start line 19');
                List<Case> existCase = ownerCaseMap.get(auditCases.ownerId);
                existCase.add(auditCases);
                ownerCaseMap.put(auditCases.ownerId, existCase);
                System.debug('Case list inside For loop if end'+ existCase);
            }
            else{
                System.debug('Case list inside For loop else start line 26');
                List<Case> newcaseList = new List<Case>();
                newcaseList.add(auditCases);
                ownerCaseMap.put(auditCases.ownerId, newcaseList);
                System.debug('Case list inside For loop else end'+ newcaseList);
            }
        }
        
        // Call Case Random Method
        for(Id ownerId : ownerCaseMap.keyset()){
            System.debug('Case list inside Case Random Method start line 36');
            caseRandomiser(ownerCaseMap.get(ownerId));
            System.debug('Case list inside Case Random Method end line 38');
        }
        
        // Data Base Update
        try{
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            
           System.debug('Case list inside try Method start line 43');
           update caseUpdateList;
           System.debug('Case list inside try Method end line 45');
        }
        catch(Exception e){
            System.debug('Exception foundh in the AuditCaseBatch Batch---'+e);
        }  
    }

    // Method To Pick Two Random Cases/Care Manager
    private void caseRandomiser(List<case> caseList){
      
        System.debug('Case Randomizer Method line 55');
        // Local Variables
        Set<Integer> indexSet = new Set<Integer>();
        
        // If Closed Cases Are Two or Less
        if(caseList.size()<=numberOfCases){
            
            // Update Case Audit Status
            for(case auditCase: caseList){
            System.debug('Case Randomizer Method line 64');
                auditCase.Audit_Status__c = 'Under QA';
            }
            
            // Add all case to list
            caseUpdateList.addAll(caseList);
            System.debug('Case Randomizer Method Case Update line 70');
            return;
        }
        else{
            System.debug('Case Randomizer Method line 74');
            // If Closed Cases Greater Than Two
            while(indexSet.size() < numberOfCases){
            System.debug('Case Randomizer Method line 76');   
            // Get The Random Case Index
            Integer caseIndex = Math.mod(Integer.valueof(math.random() * 100), caseList.size());
                if(!indexSet.contains(caseIndex)){
                 System.debug('Case Randomizer Method update line 81');
                    // Update Case Status
                    caseList[caseIndex].Audit_Status__c = 'Under QA';
                    System.debug('Case Randomizer Method update 84');
                    caseUpdateList.add(caseList[caseIndex]);
                    System.debug('Case Randomizer Method Caseupdate line 86');
                    // Update Index Set
                    indexSet.add(caseIndex);
                }
            }  
        }
    }    
}