/**************************************************************************
Trigger Name: social_DNEHandler
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: class will update DNE field on conatct when case is updated or vice-versa.
Version History: Aditya(14/March/2014) - Release 19March2014
version History: Haemen(8/June/2015) - Release 17th-June-2015 ITS 1527
**************************************************************************************************************************/
Public Class social_DNEHandler {

    /**
    * < updateDNEOnCase() - Method to update DNE details on case>
    * @param:
    *     Map<Id,Case> ContactDetailMap - map contains the contacts which got updated or created with DNE value .        
    *       
    * @return - void
    * @see - Social_CaseDNE (trigger)
    */
    public static void updateDNEOnCase(Map<Id,Contact> ContactDetailMap) {
        List<Case> updateCasesList= new  List<Case>();
        for (Case caseObj : [Select id,DNE__c,contactId from case where ContactId IN : ContactDetailMap.keySet() and Id NOT IN:Social_StreamingUtil.caseIdFromTrigger limit 50000]) {
            if(ContactDetailMap.containsKey(caseObj.contactId) && caseObj.DNE__c != ContactDetailMap.get(caseObj.contactId).DNE_Contact__c) {
                caseObj.DNE__c = ContactDetailMap.get(caseObj.contactId).DNE_Contact__c;
                updateCasesList.add(caseObj);
                Social_StreamingUtil.dneCaseIds.add(caseObj.Id);
            }
        } 
        if(!updateCasesList.isEmpty()) {
            Social_StreamingUtil.updateSObject(updateCasesList,'Failed to update DNE on Case while contact is updated/inserted.');
        }
    } 
 
    /**
    * < updateDNEDetailsOnContact() - Method to update DNE details on contact>
    * @param:
    *     Map<Id,Case> caseContMap - cases which got updated/inserted with DNE value .        
    *       
    * @return - void
    * @see - Social_CaseDNE (trigger)
    */
    public static void updateDNEDetailsOnContact(Map<Id,Case> caseContMap) {
    List<Contact> contactListToUpdate = new List<Contact>();
        for(Contact contactObj : [select id,DNE_Contact__c from contact where Id IN: caseContMap.keySet() limit 50000]) {
            if(caseContMap.containsKey(contactObj.Id) && contactObj.DNE_Contact__c != caseContMap.get(contactObj.Id).DNE__c) {
                contactObj.DNE_Contact__c = caseContMap.get(contactObj.Id).DNE__c;
                contactListToUpdate.add(contactObj);
            }    
        }  
        //calling database method for updating contact.
        if(!contactListToUpdate.isEmpty()) {
            Social_StreamingUtil.updateSObject(contactListToUpdate,'Failed to update DNE on contact.');
        }  
    }
     /**
    * < customerAcctDetails() - Void Method To Check If Contact contains child record or not>
    * @param:
    *     Map<Id,Case> conIdMp,List<Case> caseListCAD        
    *       
    * @return - Void
    * @see - Social_CaseDNE (trigger)
    */
    
    public static void customerAcctDetails(Map<Id,Case> conIdMp,List<Case> caseListCAD) {              
        Map<Id,List<Customer_Account_Details__c>> CADMap = new Map<Id,List<Customer_Account_Details__c>>();
        List<Customer_Account_Details__c> cust=new List<Customer_Account_Details__c>();       
        for (Customer_Account_Details__c customerAccDetailObj : [select id,name,Contact_Id__c,Account_Type__c,Is_Active__c from Customer_Account_Details__c where Contact_Id__c IN: conIdMp.keyset()]) {
            if(!CADMap.containsKey(customerAccDetailObj.Contact_Id__c) && customerAccDetailObj.Account_Type__c == 'U-Verse(BAN)' && customerAccDetailObj.Is_Active__c==true){
                CADMap.put(customerAccDetailObj.Contact_Id__c, new list<Customer_Account_Details__c>{customerAccDetailObj});
            } else if (CADMap.containsKey(customerAccDetailObj.Contact_Id__c) && customerAccDetailObj.Account_Type__c == 'U-Verse(BAN)') {
                CADMap.get(customerAccDetailObj.Contact_Id__c).add(customerAccDetailObj);
            }
        }    
        for (Case caseObj : caseListCAD) {          
           if (!CADMap.containsKey(caseObj.contactId)) {
               conIdMp.get(caseObj.contactId).addError('Required fields to CLOSE a Consumer case:  "Billing Account Number(BAN)" for the associated Contact on Case');
           } 
        }
     }
    
    /**
    * < checkScrubTeamMember() - Boolean Method To Check If Context User Part Of SCRUB Team>
    * @param:
    *     <id loggedUserId> - id of the logged in user .        
    *       
    * @return - Boolean
    * @see - Social_CaseDNE (trigger)
    */
    public static boolean isScrubTeamMember;
    public static boolean checkScrubTeamMember(id loggedUserId){
         PermissionSetAssignment[] scrubMember = [Select p.PermissionSetId, p.Id, p.AssigneeId From PermissionSetAssignment p where 
                                             p.AssigneeId=: loggedUserId and p.PermissionSetId=: Label.ScrubTeamId limit 1];
         if(scrubMember.size()>0 || (Userinfo.getProfileId()!=null && Userinfo.getProfileId().substring(0,15).equalsIgnoreCase(Label.SystemAdminProfileId))){
             isScrubTeamMember = true;
         } else {
             isScrubTeamMember = false;
         }
         return isScrubTeamMember;
     }
     
    
    /**
    * < Social_DNCHelper1() - Method to update DNE details on case if DNE on case is null and contact has a DNE value>
    * @param:
    *     Map<Id,Case> contactUpdateMap - cases which got updated/inserted with DNE value .        
    *       
    * @return - void
    * @see - Social_CaseDNE (trigger)
    */
    
    public static void updateDNEDetailsOnCase(Map<Id,Case> contactUpdateMap) {
        Map<Id,Contact> contactDetailMap = new Map<Id,Contact>();//Map to store case id and contact object
        List<Case> caseToUpdate = new List<case>();//Case list to update
        for (Contact contactObj : [select id,DNE_Contact__c from contact where Id IN:contactUpdateMap.keySet() limit 50000 ]) {
            if (contactObj.DNE_Contact__c != null && contactObj.DNE_Contact__c != contactUpdateMap.get(contactObj.Id).DNE__c && contactUpdateMap.containsKey(contactObj.Id)) {
                contactDetailMap.put(contactUpdateMap.get(contactObj.Id).Id,contactObj);
            }
        }
        
        if(!contactDetailMap.isEmpty()) {
            for(Case caseObj : [select id from case where id IN: contactDetailMap.keySet() limit 50000 ]) {
                if(contactDetailMap.containsKey(caseObj.Id)) {
                    caseObj.DNE__c = contactDetailMap.get(caseObj.Id).DNE_Contact__c ;
                    caseToUpdate.add(caseObj);
                }
            }
        }
        //calling database method for updating case.
        if(!caseToUpdate.isEmpty()) {
            Social_StreamingUtil.updateSObject(caseToUpdate,'Failed to update DNE on case.');
        } 
    }
    
    /**
    * < updateClosedCaseEmptyFields() - Method to update fields " Status ,Primary Component,Primary Sub Component and Media Source " if empty on Auto Case Closure by Workflow>
    * @param:
    *     List<Case> AutoCloseCaseList - cases which needs to be checked for populating the empty fields on Auto Case closure .        
    *       
    * @return - void
    * @see - Social_CaseDNE (trigger)
    */
    
    public static void updateClosedCaseEmptyFields(List<Case> AutoCloseCaseList,Set<Id> contactIdSet){
        List<Contact> UpdateLastClosedCaseTimeList = new List<Contact>();
        for(Case caseObj: AutoCloseCaseList){                    
            if(caseObj.Status == null){
                caseObj.Status = 'Auto Closed';
            }
            if(caseObj.Component_Primary__c == null){
                caseObj.Component_Primary__c = 'Unknown';
                caseObj.Component_Secondary__c = 'Unknown';
            }
            if(caseObj.Social_Media_Source__c == null){
                if(caseObj.Origin.EqualsIgnoreCase('Twitter')){
                    caseObj.Social_Media_Source__c = 'Twitter';
                }
                else if(caseObj.Origin.EqualsIgnoreCase('Facebook')){
                    caseObj.Social_Media_Source__c = 'Facebook';
                }
                else if(caseObj.Origin.EqualsIgnoreCase('Email')){
                    caseObj.Social_Media_Source__c = 'ATT CustCare Mailbox';
                }
            } 
       }
       if (!contactIdSet.isEmpty()) {
           for (Contact contactObj: [Select Id from Contact where Id IN:contactIdSet]) {
               contactObj.Last_Case_Closed__c = System.Now();
               UpdateLastClosedCaseTimeList.add(contactObj);
           }
       }
       if (!UpdateLastClosedCaseTimeList.isEmpty()) {
           Social_CaseAssignmentUtility.executeTriggerCode = false;
           Social_StreamingUtil.updateSObject(UpdateLastClosedCaseTimeList,'Failed to update Last Case Closed Time on contact.');    
       }
   }   
} // Class close