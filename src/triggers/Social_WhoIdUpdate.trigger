trigger Social_WhoIdUpdate on TIMBASURVEYS__Survey_Summary__c (before Insert) {
    Map<Id,Id> surveyCaseMap = new Map<Id,Id>();
    Map<Id,Case> caseMap = new Map<Id,Case>();
    List<Forsee_Survey__c> forseeList = new List<Forsee_Survey__c >();
    
    for(TIMBASURVEYS__Survey_Summary__c singleSummary: trigger.New){
        surveyCaseMap.put(singleSummary.Id,singleSummary.TIMBASURVEYS__RelatedCase__c);
    }
    
    for(Case singleCase: [Select Id, OwnerId from Case where Id IN: surveyCaseMap.values()]){
        caseMap.put(singleCase.Id, singleCase);
    }
    for(Forsee_Survey__c fObj : [select Id,Name,Case__c,One_Time_Used__c,URL_Active__c from Forsee_Survey__c where Case__c =: caseMap.keySet()]){
       fObj.One_Time_Used__c = true; 
       fObj.URL_Active__c = false;
       forseeList.add(fObj);
    }
    
    for(TIMBASURVEYS__Survey_Summary__c singleSummary: trigger.New){
        if(caseMap.containsKey(singleSummary.TIMBASURVEYS__RelatedCase__c)){
            singleSummary.TIMBASURVEYS__Who_Id__c = caseMap.get(singleSummary.TIMBASURVEYS__RelatedCase__c).OwnerId;
        }
    }
    if(!forseeList.isEmpty()){
        try{
            update forseeList;
        }
        catch(DMLException exc){
         system.debug('Exception in updating Business foresee record' + exc);
        }
    }

}