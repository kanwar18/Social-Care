/**
    *A handler class which is called by the foresee survey 
    responses object during the various DML Operations
    @Author: Vijay Kumar Manchuri
    @Version: 1.1
    @Date: 18/July/2013
**/

public class ForeseeResponseTriggerHandler {

    //Default Cons
    public ForeseeResponseTriggerHandler() {
    
    }
    
    //Method to update the case-lookup
    public void doUpdateCaseId(SObject[] foreseeObjArr) {
        Set<String> foreseeCaseSet = new Set<String>();
        List<SObject> foreseeObjList = new List<SObject>();
        SObject clonedObj = null;
        Map<String, Case> caseMap = new Map<String, Case>();
        Case oldCaseObj = null;
        
        try {

            if(null != foreseeObjArr && foreseeObjArr.size() > 0) {
                for(SObject foreseeObj : foreseeObjArr) {
                    foreseeCaseSet.add((String)foreseeObj.get('AID__c'));
                }
                
                for(Case caseObj : [Select Id,CaseNumber,Component_Primary__c,Component_Secondary__c from Case 
                    Where CaseNumber IN :foreseeCaseSet]) {
                    caseMap.put(caseObj.CaseNumber, caseObj);
                }
                
                for(SObject foreseeObj : foreseeObjArr) {
                    if(foreseeObj.get('AID__c') != null) {
                        oldCaseObj = (Case) caseMap.get((String)foreseeObj.get('AID__c'));                        
                        clonedObj = foreseeObj.clone(true);
                        clonedObj.put('Case__c', oldCaseObj.Id);
                        if (((String)foreseeObj.get('Operations_Manager__c')) != Null) {
                            clonedObj.put('Operations_Manager__c',EncodingUtil.base64Decode
                                (((String)foreseeObj.get('Operations_Manager__c')).replaceAll(',','')).toString());
                        }
                        clonedObj.put('Component_Primary__c', oldCaseObj.Component_Primary__c);
                        clonedObj.put('Component_Secondary__c', oldCaseObj.Component_Secondary__c);
                        foreseeObjList.add(clonedObj);
                    }
                }                
            }
            
            System.debug('Response List :'+foreseeObjList);
            
            if(!foreseeObjList.isEmpty()) {
                update foreseeObjList;
            }
            
        } catch(Exception excep) {
            System.debug('Exception Caught :'+excep.getMessage()+', @Line#'+excep.getLineNumber());
        } finally {
            foreseeCaseSet.clear();
            foreseeObjList.clear();
            caseMap.clear();
        }
    }
}