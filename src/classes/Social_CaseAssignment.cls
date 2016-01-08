public class Social_CaseAssignment {
    public String strCaseId{get;set;}
    public String strCareManager{get;set;}
    
    public Social_CaseAssignment(){
        
    }
    /*
        Class to trigger Round robin Case assignment Manually
    */
    public PageReference assignCase() {
        initiateCaseAssignment();
        PageReference p =  new PageReference('/apex/assignCase');
        return p;
    }
    
    
    /**
    * method to initiate Case Assignment. Checks for the custum lable value "Enable_Case_Assignment_Schedule_Job" and assigns case to care managers
    *
    */
    public void initiateCaseAssignment(){
        Boolean enableCaseAssignment = false;
        try{
            String strCustomLabel = System.label.Enable_Case_Assignment_Schedule_Job;
            if(strCustomLabel!=null && strCustomLabel.equalsIgnoreCase('True')){
                enableCaseAssignment = true;
            }
        }
        catch(Exception e){
            System.debug('Custom Label Enable_Case_Assignment_Schedule_Job missing '+e.getmessage());
        }
        if(enableCaseAssignment){
            Social_CaseAssignmentHandler handler = new Social_CaseAssignmentHandler();
            Social_CaseUtilHandler managerUtilClass =  new Social_CaseUtilHandler();
            handler.setCurrentExecutionMap();
            
            // Prepare the order list of Cases for Assignment
            List<Case> casestobeAssignedList = handler.getOrderedListofCases();
            
            //Pre load the Care managers
            handler.preloadCareManagers();
            if(casestobeAssignedList!=null && casestobeAssignedList.size()>0){
                Map<Id,Id> caseMap =  new Map<Id,Id>();
                for(Case c : casestobeAssignedList){
                    //try{
                    
                        //Get the best fit Care Manager
                        String careManagerId = handler.getAvailableCaseManagerfromQueue(c.ownerId);
                        System.debug('Care Manager ID :::::'+careManagerId);
                        if(careManagerId!=null && !careManagerId.equals('') && c.Id!=null){
                            caseMap.put(c.Id, caremanagerId);
                            //handler.setCaseDetails(c.Id, caremanagerId);
                            //Nayan's Addition
                             if(('New').equalsignorecase(c.Status)||('Investigating').equalsignorecase(c.Status)||('Reassigned').equalsignorecase(c.Status)||('Reopen').equalsignorecase(c.Status)||('Escalated').equalsignorecase(c.Status)){
                            handler.incrementCareManagerCounter(careManagerId); 
                            }
                            System.debug('Care Manager '+careManagerId+' has been assigned the case '+c.Id);                       
                        } 
                    /*}
                    catch(Exception e){ 
                            //Do nothing. Proceed to the next case ;)
                    }   */                            
                }
                if(caseMap!=null && !caseMap.isEmpty()){
                    handler.setCaseDetails(caseMap, false); 
                    try{                
                        handler.updateCaseDetails();
                    }
                    catch(Exception e){
                        System.debug('Error in Social_CaseAssignment '+e.getMessage());                
                    }     
                }         
            }
        }
        else{
            System.debug(' @@@@@@@@@@@@@@------ Case Assignment Disabled ------@@@@@@@@@@@@@@ ');
        }
    }
}