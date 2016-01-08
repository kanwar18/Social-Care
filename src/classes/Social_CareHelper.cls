/**
*   A helper class which holds the utilites and common across the classes for ABS/Consumer Care
**/

public class Social_CareHelper{

    /**
    * Method used get the encoding for the primary and secondary components for the case
    **/     
     Public static Map<String,Foresee_URL_encoding__c> encodingPrimaryAndSubComp() {
        Map<String,Foresee_URL_encoding__c> primarySubCompMap = new Map<String,Foresee_URL_encoding__c> ();
        if (primarySubCompMap.isEmpty()) {
            for(Foresee_URL_encoding__c foreseeObj : [select id,Primary_Component__c,Primary_Component_Sub_Category_1__c,Condensed_Group__c,Encoding_Primary_Component_Sub_Category1__c,Encoding_Primary_Component__c from Foresee_URL_encoding__c where Active__c = true limit 50000]) {
                if(foreseeObj.Primary_Component__c != Null && foreseeObj.Primary_Component_Sub_Category_1__c != Null) {
                    primarySubCompMap.put(foreseeObj.Primary_Component__c + foreseeObj.Primary_Component_Sub_Category_1__c,foreseeObj); 
                }
            } 
        }
        return primarySubCompMap;
    }
}