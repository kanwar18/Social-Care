/*** Class Name: Social_AuditCaseBatchSchedulableBus 
 * Author: Accenture
 * Date: 15-Mar-2013
 * Requirement/Project Name: Business Care
 * Requirement Description: This is the schedulable apex class and it is using to schedule the Social_AuditCaseBatch.  
 **/
global class Social_AuditCaseBatchSchedulableBus implements Schedulable{
     // Class Level Variables
    List<case> caseUpdateList = new List<case>();
    //Number of random cases to be returned.
    String s =System.Label.noOfAuditCases;
    Integer numberOfCases =Integer.ValueOf(s); 
    
    global void execute(SchedulableContext sc) {
    
        // Method Variables
        List<Case> cases = [select caseNumber, ownerid, Audit_Status__c, ClosedDate, Closed_Operation_Manager__c From Case 
                            where Status='Closed' AND Audit_Status__c !='Under QA' AND Audit_Status__c !='QA Completed' AND Reason ='Resolved'AND  ClosedDate = LAST_WEEK ];
       
       System.debug('underauditcases'+cases );

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
            
               System.debug('ownerCaseMap'+ownerCaseMap);
            
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
            System.debug('Exception foundh in the QACaseBatch Batch---'+e);
        }  
    }

    // Method To Pick Two Random Cases/Care Manager
    private void caseRandomiser(List<case> caseList){
        
        // Local Variables
        Set<Integer> indexSet = new Set<Integer>();
        
        // If Closed Cases Are Two or Less
        if(caseList.size()<=numberOfCases){
        
            System.debug('size'+caseList.size()); 
                       
            // Update Case Audit Status
            for(case auditCase: caseList){
                auditCase.Audit_Status__c = 'Under QA';
            }
            
            // Add all case to list
            caseUpdateList.addAll(caseList);
            return;
            
                System.debug('caseUpdateListlessthan2'+caseUpdateList);            
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
               System.debug('caseUpdateList1'+caseUpdateList);
 
          }  
        }
    }    
}