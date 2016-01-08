/*
    Round Robin Case assignment
*/ 
global class Social_RoundRobinCaseAssignment implements DataBase.Batchable<sObject>, Database.Stateful {
 
    private Social_RoundRobinCaseAssignmentHandler rHandler =  new Social_RoundRobinCaseAssignmentHandler();
    private Map<String, Integer> careManagerCapCounter =  new Map<String, Integer>();
    private Map<String, Integer> careManagerDetails =  new Map<String, Integer>();
    global List<Case> start(Database.BatchableContext BC){
        List<Case> caseList =  rHandler.getCaseListToBeProcessed();
        
        rHandler.setCurrentExecutionMap();
        
        //Pre load the Care managers
        Map<String, Integer> careManagerMap = rHandler.preloadCareManagers();         
        try{
            rHandler.captureCareManagerDetails(careManagerMap);
        }
        catch(Exception e){
            System.debug('Error :'+e.getMessage());
        }        
        return caseList;
    }
    global void execute(Database.BatchableContext BC, list<Case> casestobeAssignedList){
                
        
        
        if(!Util.isCollectionEmpty(casestobeAssignedList, 'List')){
                Map<Id,Id> caseMap =  new Map<Id,Id>();
                for(Case c : casestobeAssignedList){
                    //Get the best fit Care Manager
                    String careManagerId = rhandler.getAvailableCaseManagerfromQueue(c.ownerId);
                    System.debug('Care Manager ID :::::'+careManagerId);
                    boolean assign = false;
                    
                    if(null!= careManagerCapCounter && !careManagerCapCounter.isEmpty() && !careManagerCapCounter.containsKey(careManagerId) && null!=careManagerId && !careManagerId.equals('')){
                        
                        Integer capCounter = 0;
                        if(null!=careManagerCapCounter.get(careManagerId)){
                            capCounter = careManagerCapCounter.get(careManagerId);
                        }
                        if(capCounter < Integer.valueOf(System.label.Case_Assignment_Counter)){
                            assign = true;
                            capCounter = capCounter + 1;
                            careManagerCapCounter.put(careManagerId, capCounter);
                        }
                        else{
                            assign = false;
                        }
                    }
                    else if(null!=careManagerId && !careManagerId.equals('')){
                        assign = true;
                        careManagerCapCounter.put(careManagerId, 0);
                    }
                    
                    if(careManagerId!=null && !careManagerId.equals('') && c.Id!=null && assign){
                        
                        caseMap.put(c.Id, caremanagerId);
                        //Nayan's Addition
                        if(('New').equalsignorecase(c.Status)||('Investigating').equalsignorecase(c.Status)||('Reassigned').equalsignorecase(c.Status)||('Reopen').equalsignorecase(c.Status)||('Escalated').equalsignorecase(c.Status)){
                            rHandler.incrementCareManagerCounter(careManagerId);
                        }
                    }
                }
                if(caseMap!=null && !caseMap.isEmpty()){
                    rHandler.setCaseDetails(caseMap, false, false); 
                    try{                
                        rHandler.updateCaseDetails();
                    }
                    catch(Exception e){
                        System.debug('Error in Social_CaseAssignment '+e.getMessage());                
                    }     
                }         
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}