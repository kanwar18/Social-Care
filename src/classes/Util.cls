/* Release 19th August : Updated by Ashween for ITS1472 - new method getBCSListofCasesToBeAssigned() **/

public class Util{
    
    //method to check is object is null
    public static boolean isNull(Object obj){
        return (null == obj) ? true : false;
    }
    
    //method to check is object is not null
    public static boolean isNotNull(Object obj){
        return isNull(obj) ? false : true;
    }
    
    //Method to convert the string to boolean type 
    public static boolean isBoolean(String booleanVal) {
        String decisionValues = 'true false';
        if(Util.isNotNull(booleanVal) && decisionValues.contains(booleanVal)) {
            return Boolean.valueOf(booleanVal);
        }
        return false;
    }
    
    //method to check if the collection is empty/not
    public static boolean isCollectionEmpty(object obj, String colName){
        boolean isCollEmpty = true;
        if(isNotNull(obj) && isNotNull(colName)) {
            if(colName.equalsIgnoreCase('List')) {
                isCollEmpty = ((List<object>) obj).isEmpty() ? true : false;
            } else if(colName.equalsIgnoreCase('Set')){
                isCollEmpty = ((Set<String>) obj).isEmpty() ? true : false;
            } else if(colName.equalsIgnoreCase('Map')){
                isCollEmpty = ((Map<String, String>) obj).isEmpty() ? true : false;
            } else {
                isCollEmpty = true;
            }
        }
        return isCollEmpty;
    }
    
    //Method to check for the sobject null
    public static boolean isSobjNull(SObject sobj) {
        return (null == sobj) ? true : false;
    }
    
    //Method to check for the sobject not null
    public static boolean isSobjNotNull(Sobject sobj) {
        return (null != sobj) ? true : false;
    }

    //Method to check the id collection empty or not - list
    public static boolean isIdListEmpty(List<Id> idList) {
        return (null == idList) ? true : (idList.isEmpty() ? true : false);
    }
    
    //Method to check the id collection empty or not - set
    public static boolean isIdSetEmpty(Set<Id> idSet) {
        return (null == idSet) ? true : (idSet.isEmpty() ? true : false);
    }
        
    //Method to check the sobject collection empty or not - list
    public static boolean isListEmpty(List<SObject> sobjList) {
        return (null == sobjList) ? true : (sobjList.isEmpty() ? true : false);
    }
    
    //Method to check the sobject collection empty or not - set
    public static boolean isSetEmpty(Set<Object> objSet) {
        return (null == objSet) ? true : (objSet.isEmpty() ? true : false);
    }

    //Method to check the sobject collection empty or not - map
    public static boolean isMapEmpty(Map<Id, SObject> sobjMap) {
        return (null == sobjMap) ? true : (sobjMap.isEmpty() ? true : false);
    }
    
    //Method to check the sobject collection empty or not - map(String, Integer etc as a key)
    public static boolean isObjMapEmpty(Map<Object, SObject> sobjMap) {
        return (null == sobjMap) ? true : (sobjMap.isEmpty() ? true : false);
    }
     
    //method to check for the string equality and return the sobject list
    public static Set<Id> equStr(String toCompare, String fieldName, String retrieveField, SObject[] sobjects) {
        Set<Id> idSet = new Set<Id>();
        boolean isToCompare = isBolAndCheck(
            new Boolean[] {
                !isListEmpty(sobjects),
                isnnAndCmp(new Object[]{toCompare, fieldName, retrieveField})
            }
        );
        boolean isEmptyToCompare = isBolAndCheck(
            new Boolean[] {
                isnAndCmp(new Object[]{toCompare, fieldName}),
                isnnAndCmp(new Object[]{retrieveField, !isListEmpty(sobjects)})
            }
        );
        
        if(isToCompare) {
            for(SObject sobjectObj : sobjects) {
                String fieldVal = (String) sobjectObj.get(fieldName);
                if(toCompare.equalsIgnoreCase(fieldVal)) {
                    idSet.add((Id)sobjectObj.get(retrieveField));
                }
            }
        } else if(isEmptyToCompare) {
            for(SObject sobjectObj : sobjects) {
                idSet.add((Id)sobjectObj.get(retrieveField));
            }
        }
        return idSet;
    }
   
    //method for checking the "not null" comparision using the "and" operand 
    public static boolean isnnAndCmp(List<Object> objList) {
        if(!isCollectionEmpty(objList, 'list')) {
            for(Object obj : objList) {
                boolean isFalse = isNull(obj) ? true : false;
                if(isFalse) {
                    return false;
                }
            }
        } else {
            return false;
        }
        return true;
    }
    
    //method for checking the "not null" comparision using the "or" operand 
    public static boolean isnnOrCmp(List<Object> objList) {
        if(!isCollectionEmpty(objList, 'list')) {
            for(Object obj : objList) {
                boolean isTrue = isNotNull(obj) ? true : false;
                if(isTrue) {
                    return isTrue;
                }
            }
        }
        return false;
    }
    
    //method to check for null - and operand
    public static boolean isnAndCmp(List<Object> objList) {
        if(!isCollectionEmpty(objList, 'list')) {
            for(Object obj :objList) {
                boolean isFalse = isNull(obj) ? false : true;
                if(isFalse) {
                    return false;
                }
            }
        }
        return true;
    }
    
    //method to check for null - or operand
    public static boolean isnOrCmp(List<Object> objList) {
        if(!isCollectionEmpty(objList, 'list')) {
            for(Object obj : objList) {
                boolean isTrue = isNull(obj) ? true : false;
                if(isTrue) {
                    return isTrue;
                }
            }
        }
        return false;
    }
    
    //Method to put the sobjects into the map
    public static Map<Id,SObject> toMap(List<SObject> objList) {
        Map<Id,SObject> objMap = new Map<Id,SObject>();
        if(!isListEmpty(objList)) {
            for(SObject sobjectObj : objList) {
                objMap.put((Id)sobjectObj.get('Id'), sobjectObj);
            }
        }
        return objMap;
    }

    //Method to check the boolean list - for and
     public static boolean isBolAndCheck(List<Boolean> booleanList) {
         if(!isCollectionEmpty(booleanList,'list')) {
            for(Boolean isBolVal : booleanList) {
                if(isBolOrCheck(new Boolean[]{(isNotNull(isBolVal) && !isBolVal),isNull(isBolVal)})){
                    return false;
                }
            }
          }
         return true;        
     }
     
     //method to check the boolean list - for or
    public static boolean isBolOrCheck(List<Boolean> booleanList) {
         if(!isCollectionEmpty(booleanList,'list')) {
            for(Boolean isBolVal : booleanList) {
                if((isNotNull(isBolVal) && isBolVal)){
                    return true;
                }
            }
          }
         return false;        
     }     
            
    //Method used to check the state of the objects (i.e. old and new maps)
    public static List<SObject> bulkState(Map<Id,SObject> newMap, Map<Id, SObject> oldMap, Set<String> fieldSet) {
        List<SObject> resultList = new List<SObject>();
        boolean isbulkFlag = isBolAndCheck(new Boolean[] {
            !isMapEmpty(newMap), 
            !isMapEmpty(oldMap), 
            !isCollectionEmpty(fieldSet, 'set')}
        );
        if(isbulkFlag){
            for(Id objId : newMap.keySet()) {
                SObject newObj = newMap.get(objId);
                SObject oldObj = oldMap.get(objId);
                if(isnnAndCmp(new Object[] {newObj, oldObj})) {
                    Map<String, boolean> fieldResMap = new Map<String, boolean>();
                    for(String fieldStr : fieldSet) {
                        if(isNotNull(fieldStr)) {
                            Object newFieldVal = newObj.get(fieldStr);
                            Object oldFieldVal = oldObj.get(fieldStr);
                            boolean isResult = false;
                            Object[] operands = new Object[] {newFieldVal, oldFieldVal};
                            boolean isOrFlag = isBolOrCheck(new Boolean[]{isnnAndCmp(operands), isnAndCmp(operands)});
                            if(isOrFlag) {
                                if(oldFieldVal == newFieldVal) {
                                    isResult = true;
                                }
                            }
                            fieldResMap.put(fieldStr, isResult);
                        }
                    } //end FOR
                    if(!isBolAndCheck(fieldResMap.values())) {
                        resultList.add(newObj);
                    }
                } //end IF
            } //end FOR
        } else {
            resultList = newMap.values();
        }  
        return resultList;
    }    
    
    //Method used to compare the object based on the field
    public static Map<Id, SObject> cmpObjectByFields(SObject[] objList ,Map<String, Object> fieldValMap) {
        Map<Id, SObject> objectMap = new Map<Id, SObject>();
        if(isBolAndCheck(new Boolean[] {
            !isListEmpty(objList), 
            !isCollectionEmpty(fieldValMap.keySet(), 'set')})){
            for(SObject objectObj : objList) {
                boolean isFieldCmp = false;
                Map<String, boolean> fieldCmpMap = new Map<String, boolean>();
                for(String fieldName : fieldValMap.keySet()) {
                    if(objectObj.get(fieldName) == fieldValMap.get(fieldName)) {
                        isFieldCmp = true;
                    } else {
                        isFieldCmp = false;
                    }
                    fieldCmpMap.put(fieldName, isFieldCmp);
                }
                if(isBolAndCheck(fieldCmpMap.values())) {
                    objectMap.put((Id)objectObj.get('Id'), objectObj);
                }
            }           
        }
        return objectMap;
    }
    
    //Method used to get the field, which is of form id
    public static Set<Id> getIdSet(SObject[] objList, String fieldToReturn) {
        Set<Id> idSet = new Set<Id>();
        if(isBolAndCheck(new Boolean[] {!isListEmpty(objList), 
            Util.isNotNull(fieldToReturn), fieldToReturn.length() > 0})) {
            for(SObject objectObj : objList) {
                idSet.add((Id) objectObj.get(fieldToReturn));
            }
        }
        return idSet;
    }
        
    //Overloading of debug methods for various logging level - error and debug
    public static void doShowMsg(String toShow) {
        if(isNotNull(toShow)) {
            System.debug(DEBUG_LEVEL,'Printed Msg: '+toShow);
        }   
    }
    
    public static void doShowMsg(Object objToPrint) {
        if(isNotNull(objToPrint)) {
            System.debug(DEBUG_LEVEL,'Object Value: '+objToPrint);
        }       
    }
    
    public static void doShowMsg(String toShow, Object objToPrint) {
        if(isnnAndCmp(new Object[]{toShow, objToPrint})) {
            System.debug(DEBUG_LEVEL,'Printed Msg: '+toShow+' ,Object Value: '+objToPrint);
        }
    }
    
    //Method used to add the charecter to a begin and end of the String
    public static String addSpeChar(String charName, String mainStr) {
        if(Util.isnnAndCmp(new Object[]{charName, mainStr})) {
            return charName + mainStr + charName;
        }
        return '';
    }
    
    //Method add's the braces in the begin and end of the string
    public static String addBraces(String mainStr) {
        if(Util.isNotNull(mainStr)) {
            return '('+mainStr+')';
        }
        return '';  
    }
    
    //Method used to compare the two strings
    public static boolean isEquStr(String compareStr, String variableToCompare) {
        if(isBolAndCheck(new Boolean[]{isNotNull(compareStr), isNotNull(variableToCompare)})) {
            return compareStr.equalsIgnoreCase(variableToCompare);
        }
        return false;
    }
    
    //Method used to check for the object equality
    public static boolean isObjEqu(Object objectObj, Object anotherObjectObj) {
        if(isBolAndCheck(new Boolean[]{isNotNull(objectObj), isNotNull(anotherObjectObj)})) {
            return (objectObj == anotherObjectObj); 
        }
        return false;
    }
    
    //Method used to check if the objects exisits in the map/not
    public static boolean isKeyContain(String key, Set<String> keySet) {
        if(Util.isBolAndCheck(new Boolean[] {Util.isNotNull(key), !Util.isCollectionEmpty(keySet, 'set')})) {
            return keySet.contains(key) ? true : false;
        }
        return false;
    }
    
    //Used to set the object and their parameters
    public static SObject setObjectFields(SObject obj, Map<String, Object> fieldMap) {
        if(isBolAndCheck(new Boolean[] {isSobjNotNull(obj), isNotNull(fieldMap)})) {
            if(!fieldMap.isEmpty()) {
                for(String fieldName : fieldMap.keySet()) {
                    obj.put(fieldName, fieldMap.get(fieldName));
                }
            }
        }
        return obj;
    }
    
    //used to set the values for a collection based on fields
    public static List<SObject> setObjectFieldsOnList(List<SObject> objList, Map<String, Object> fieldMap) {
        if(isBolAndCheck(new Boolean[] {!isListEmpty(objList), isNotNull(fieldMap)})) {
            if(!fieldMap.isEmpty()) {
                for(SObject obj : objList) {
                    for(String fieldKey : fieldMap.keySet()) {
                        obj.put(fieldKey, fieldMap.get(fieldKey));
                    }
                }
            }
        }
        return objList;
    }
    
    /*
    //used to mark for update via unit of work
    public static void doMarkForUpdate(UnitOfWork uowObj, List<SObject> objList) {
        if(isBolAndCheck(new Boolean[] {isNotNull(uowObj), !isListEmpty(objList)})) {
            for(SObject obj : objList) {
                uowObj.registerUpdate(obj.clone(true));
            }
        }
    }
    */
    //Method used to print the exception msgs
    public static void doStackTrace(Exception excep) {
        if(isNotNull(excep)) {
            System.debug(ERROR_LEVEL,'*******************************************');
            System.debug(ERROR_LEVEL,'Stack Trace : '+excep.getStackTraceString());
            System.debug(ERROR_LEVEL,'Exception Message and Line Number : ' + 
            excep.getMessage() + ',#' +excep.getLineNumber());
            System.debug(ERROR_LEVEL,'*******************************************');
        }
    }    
    private static final System.LoggingLevel DEBUG_LEVEL =  LoggingLevel.DEBUG;
    private static final System.LoggingLevel ERROR_LEVEL =  LoggingLevel.ERROR;
    
    public static List<Case> getListofCasesToBeAssigned(integer numberOfCases, List<String> groupNamesList){
        List<Case> casestobeAssignedList = new List<Case>();
        List<Case> casesToBeAssignedTempList = new List<Case>();
    
        List<Case> escalatedandReOpenCaseList = new List<Case>();
        List<Case> directedCaseList =  new List<Case>();
        List<Case> discoveredCaseList =  new List<Case>();
        
        List<ID> idlist =  new List<ID>();
        List<Case> caseIdList = [Select c.id,c.CaseNumber From Case c where (c.status = 'Escalated' OR c.status = 'Reopen') and c.ownerId= : groupNamesList order by c.createdDate asc limit: numberOfCases];
        if(!Util.isCollectionEmpty(caseIdList, 'List')){
            for(Case c: caseIdList){
                idlist.add(c.id);
            }
        }
        if(!Util.isCollectionEmpty(idlist, 'List')){
            escalatedandReOpenCaseList = [Select c.Id, c.ownerId, c.status,c.CaseNumber From Case c where c.ownerId= : groupNamesList and c.id IN: idlist for UPDATE];
        }
        
        //Get all Directed Case based on Content Tag formula field
        caseIdList.clear();
        idlist.clear();
        caseIdList = [Select c.id,c.CaseNumber From Case c where c.ownerId= : groupNamesList and c.Content_Tag__c like '%DIR' and c.status <> 'Closed' and c.status <> 'Auto Closed' and c.id NOT IN: escalatedandReOpenCaseList order by c.createdDate asc limit: numberOfCases];
        if(!Util.isCollectionEmpty(caseIdList, 'List')){
            for(Case c: caseIdList){
                idlist.add(c.id);
            }
        }
        if(!Util.isCollectionEmpty(idlist, 'List')){
            directedCaseList = [Select c.Id, c.ownerId, c.status,c.CaseNumber From Case c where c.ownerId= : groupNamesList and c.id IN: idlist for UPDATE];
        }

        //Get all Discovered and Nulls based on Content Tag formula field
        caseIdList.clear();
        idlist.clear();
        caseIdList = [Select c.id,c.CaseNumber From Case c where (c.Content_Tag__c like '%DISC' OR c.Content_Tag__c = '') and c.ownerId= : groupNamesList and c.status <> 'Closed' and status <> 'Auto Closed' and c.id NOT IN: escalatedandReOpenCaseList and c.id NOT IN: directedCaseList order by c.createdDate asc, c.Content_Tag__c asc NULLS LAST limit: numberOfCases];
        if(!Util.isCollectionEmpty(caseIdList, 'List')){
            for(Case c: caseIdList){
                idlist.add(c.id);
            }
        }
        if(!Util.isCollectionEmpty(idlist, 'List')){
            discoveredCaseList = [Select c.Id, c.ownerId, c.status, c.CaseNumber From Case c where c.ownerId= : groupNamesList and c.id IN: idlist for UPDATE];
        }
        
        if(!Util.isCollectionEmpty(escalatedandReOpenCaseList, 'List')){
            casesToBeAssignedTempList.addAll(escalatedandReOpenCaseList);
        }
        if(!Util.isCollectionEmpty(directedCaseList, 'List')){
            casesToBeAssignedTempList.addAll(directedCaseList);
        }
        if(!Util.isCollectionEmpty(discoveredCaseList, 'List')){
            casesToBeAssignedTempList.addAll(discoveredCaseList);
        }
        
        return casesToBeAssignedTempList;
    }
    
    public static List<Case> getBCSListofCasesToBeAssigned(integer numberOfCases, List<String> groupNamesList){
        List<Case> casestobeAssignedList = new List<Case>();
        List<Case> casesToBeAssignedTempList = new List<Case>();
    
        List<Case> escalatedandReOpenCaseList = new List<Case>();
        List<Case> directedCaseList =  new List<Case>();
        List<Case> discoveredCaseList =  new List<Case>();        
        List<ID> idlist =  new List<ID>();
        List<Case> caseIdList = new List<Case> ();

        
    //Get all Directed Case based on Content Tag formula field
         caseIdList = [Select c.id,c.CaseNumber,c.Current_SLA_Phase__c From Case c where c.ownerId= : groupNamesList and c.Content_Tag__c like '%DIR' and c.status <> 'Closed' and c.status <> 'Auto Closed' order by c.Customer_Response_Received_Time__c asc limit: numberOfCases];
            if(!Util.isCollectionEmpty(caseIdList, 'List')){
            for(Case c: caseIdList){
                idlist.add(c.id);
            }
        }
        if(!Util.isCollectionEmpty(idlist, 'List')){
            directedCaseList = [Select c.Id, c.ownerId, c.status,c.CaseNumber,c.Current_SLA_Phase__c From Case c where c.ownerId= : groupNamesList and c.id IN: idlist for UPDATE];
        }
        caseIdList.clear();
        idlist.clear();

        //Get all Cases based on Status field -'Escalated' or 'Reopen'
         caseIdList = [Select c.id,c.CaseNumber,c.Current_SLA_Phase__c From Case c where (c.status = 'Escalated' OR c.status = 'Reopen') and c.ownerId= : groupNamesList and c.id NOT IN: directedCaseList order by c.Customer_Response_Received_Time__c asc limit: numberOfCases];
            if(!Util.isCollectionEmpty(caseIdList, 'List')){
            for(Case c: caseIdList){
                idlist.add(c.id);
            }
        }
        if(!Util.isCollectionEmpty(idlist, 'List')){
            escalatedandReOpenCaseList = [Select c.Id, c.ownerId, c.status,c.CaseNumber,c.Current_SLA_Phase__c From Case c where c.ownerId= : groupNamesList and c.id IN: idlist for UPDATE];
        } 
          
        //Get all Discovered and Nulls based on Content Tag formula field
        caseIdList.clear();
        idlist.clear();
        caseIdList = [Select c.id,c.CaseNumber,c.Current_SLA_Phase__c From Case c where (c.Content_Tag__c like '%DISC' OR c.Content_Tag__c = '') and c.ownerId= : groupNamesList and c.status <> 'Closed' and status <> 'Auto Closed' and c.id NOT IN: escalatedandReOpenCaseList and c.id NOT IN: directedCaseList order by c.Customer_Response_Received_Time__c asc, c.Content_Tag__c asc NULLS LAST limit: numberOfCases];
        if(!Util.isCollectionEmpty(caseIdList, 'List')){
            for(Case c: caseIdList){
                idlist.add(c.id);
            }
        }
        if(!Util.isCollectionEmpty(idlist, 'List')){
            discoveredCaseList = [Select c.Id, c.ownerId, c.status, c.CaseNumber,c.Current_SLA_Phase__c From Case c where c.ownerId= : groupNamesList and c.id IN: idlist for  UPDATE];
        }
        
        if(!Util.isCollectionEmpty(directedCaseList, 'List')){
            casesToBeAssignedTempList.addAll(directedCaseList);
        }        
        if(!Util.isCollectionEmpty(escalatedandReOpenCaseList, 'List')){
            casesToBeAssignedTempList.addAll(escalatedandReOpenCaseList);
        }        
        if(!Util.isCollectionEmpty(discoveredCaseList, 'List')){
            casesToBeAssignedTempList.addAll(discoveredCaseList);
        }
        
        return casesToBeAssignedTempList;
    }
}