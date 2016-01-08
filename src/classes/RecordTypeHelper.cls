/*
*****************************************
* Class/Trigger  Name: RecordTypeHelper 
* Author: Accenture
* Date: 3rd-Jun-2008
* Requirement # R1
* Description: Helper class for fetching RecordTypeIds . Can be referenced anywhere(Classes/triggers ) using ClassName.MethodName('Object Name','RecordTypeName/RecordTypeDevName').It 
* helps in reducing the number of SOQL Consumption against total limit  
* Version History:V1.0
*****************************************
*/

public with sharing class RecordTypeHelper 
{
    // Helper Class - you can't instantiate
    private RecordTypeHelper(){}
    
    //Map for storing Sobject, DeveloperName and Id of Record Type.
    public static Map<String, ID> mAllRecType;
    
    // Method for getting all the record types in one SOQL.
    private static Id recordTypeIdAll (String sType, String sObjAPIName, String name)
    {
        //Executing this code only once in one transaction.
        if(mAllRecType == null){
            mAllRecType = new Map<String, ID>(); // key: Type(Dev, Label) + '.' + objAPIName + '.' + fieldName, example, "Dev.Case.IOG_Incident", value: recordTypeId
            List<RecordType> lAllRecType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where IsActive = true];
            for(RecordType r :lAllRecType){
                mAllRecType.put(('Label.' + r.SobjectType + '.' + r.Name).toUpperCase(), r.id);
                mAllRecType.put(('Dev.' + r.SobjectType + '.' + r.DeveloperName).toUpperCase(), r.id);              
            }
        }
        String key = sType + '.' + sObjAPIName + '.' + name;
        if(key != null){
            return mAllRecType.get(key.toUpperCase());
        }
       return null;
    }
    // GetRecordTypeId gets the record type ID for an object
    public static ID GetRecordTypeId(string objectType, string recordTypeName)
    {
        return recordTypeIdAll('Label', objectType, recordTypeName);
    }

    //GetRecordTypeIdByDevName  gets the record type ID for an object
    public static ID GetRecordTypeIdByDevName(string objectType, string recordTypeDeveloperName)
    {
        return recordTypeIdAll('Dev', objectType, recordTypeDeveloperName);
    }
}