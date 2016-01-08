/*** 
 * Class Name: Social_ContactLastClosedCaseController
 * Author: Accenture
 * Date: 29-July-2015
 * Requirement/Project Name: Consumer
 * Requirement Description: Class is responsible for updating contact Last Case Closed when case is reopened. 
**/

Public Class Social_ContactLastClosedCaseController {
    
    /**
    * < updateContactOnCaseReopen() - Method to update Last Case Closed on contact>
    * @param:
    *     Set<Id> contactIdSet - Id of contacts  
    * @return - void
    * @see - Social_SocialPostController (Apex Class)
    */
    
    Public Static void updateContactOnCaseReopen(Set<Id> contactIdSet) {
        Map<Id,Case> contactCaseMap = new Map<Id,Case>();
        List<Contact> contactList = new List<Contact>();
        //Get the recent closed case only 1 for each contact present in the set
        for (Case caseObj: [Select Id,contactId,ClosedDate from case where ContactId IN:contactIdSet and (Status = 'Closed' OR Status = 'Auto Closed') order by ClosedDate desc limit 1]) {
            contactCaseMap.put(caseObj.contactId,caseObj);
        }
        //Get all the contact and assign value to last case closed field
        for (Contact contactObj : [Select id,Last_Case_Closed__c from contact where Id IN:contactIdSet]) {
            if (contactCaseMap.containsKey(contactObj.Id)) {
                contactObj.Last_Case_Closed__c = contactCaseMap.get(contactObj.Id).ClosedDate;
            } else {
                contactObj.Last_Case_Closed__c = Null;
            }
            contactList.add(contactObj);
        }
        //Update contact
        if (!contactList.isEmpty()) {
            Social_StreamingUtil.updateSObject(contactList,'Class:Social_ContactLastClosedCaseController Method:updateContactOnCaseReopen');
        }
    }
}