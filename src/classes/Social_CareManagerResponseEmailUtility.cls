/*** 
 * Class Name: Social_CareManagerResponseEmailUtility
 * Author: Accenture
 * Date: 3-July-2015
 * Requirement/Project Name: Consumer Social Care
 * Requirement Description: This class will handle logic to send email and make necessary updates on case when custom post is approved  
 * Version History: Debasis(5/June/2015) - Release 15July2015 - ITS1651 setting up nesting profiles logic. 
**/

public class Social_CareManagerResponseEmailUtility {

    /**
    * < sendEmailToCustomer() - Method to send email to customer>
    * @param:
    *     String strCustomPostId: case Id.
    *
    * @return - strMessage
    * @see -  (Trigger -  Social_CustomPostEmail)   
    */
    
    public static void sendEmailToCustomer(String strCustomPostId){
        List<Custom_post__c>customPostToUpdate = new List<Custom_post__c>();
        List<EmailMessage> emailMessageToInsert = new List<EmailMessage>();
        String strMessage = '';
        if(strCustomPostId!=null && !strCustomPostId.equalsIgnoreCase('')){
            Custom_post__c customPost = [Select Contact__c, Subject__c, AdditionalTo__c, CCAddress__c, BCCAddress__c, Body__c, Case__c, status__c  from Custom_post__c where id=:strCustomPostId];
            Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // Strings to hold the email addresses to which you are sending the email.
            List<String> toAddressList = new List<String>();
            List<String> ccAddressList = new List<String>();
            List<String> bccAddressList = new List<String>();
            //Create the To Address List
            //Get Contact Email Id
            String contactEmailId='';
            if(customPost.Contact__c!=null){
                contactEmailId = getContactEmailId(customPost.Contact__c);                   
            }
            if(contactEmailId!=null && !contactEmailId.equals('')){
                toAddressList.add(contactEmailId);
            }
            if(customPost.AdditionalTo__c!=null && !(customPost.AdditionalTo__c).equals('')){
                if((customPost.AdditionalTo__c).contains(',')){
                    toAddressList.addAll((customPost.AdditionalTo__c).split(','));
                } else {
                    toAddressList.add(customPost.AdditionalTo__c);
                }
            }                
            if(customPost.CCAddress__c !=null && !(customPost.CCAddress__c).equals('')){
                if((customPost.CCAddress__c).contains(',')){
                    ccAddressList.addAll((customPost.CCAddress__c).split(','));
                } else {
                    ccAddressList.add(customPost.CCAddress__c);
                }
            }
            if(customPost.BCCAddress__c !=null && !(customPost.BCCAddress__c).equals('')){
                if((customPost.BCCAddress__c).contains(',')){
                    bccAddressList.addAll((customPost.BCCAddress__c).split(','));
                } else {
                    bccAddressList.add(customPost.BCCAddress__c);
                }
            }            
            // Assign the addresses for the To and CC lists to the mail object.
            mail.setOrgWideEmailAddressId(Label.E2C_Organisation_Wide_Email_Address);
            mail.setToAddresses(toAddressList);
            mail.setCcAddresses(ccAddressList);
            mail.setBccAddresses(bccAddressList);
            // Set to True if you want to BCC yourself on the email.
            mail.setBccSender(true);
            // The email address of the user executing the Apex Code will be used.
            mail.setUseSignature(false);
            // Specify the subject line for your email address.
            String strSubject = '';
            String strBody = '';
            Case c =  new Case();
            if(customPost.Case__c!=null){
                c = [Select Social_CaseThreadID__c, ownerId,Case_Ref__c from Case where id=: customPost.Case__c]; 
            }
            if(customPost.Subject__c!=null && !(customPost.Subject__c).equals('')){
                strSubject = customPost.Subject__c + ' ' + c.Case_Ref__c;
            }
            if(customPost.Body__c!=null && !(customPost.Body__c).equals('')){
                strBody = Label.Email_Subject_Warning+'<br>'+'<br/>' + customPost.Body__c;
            }
            mail.setSubject(strSubject);
            mail.setHtmlBody(strBody);
            // Send the email you have created.
            strMessage = ''+Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            customPost.Status__c = 'Sent';
            customPostToUpdate.add(customPost);
            Social_CareManagerResponseUtility.executeTriggerCode = false;                    
            Social_StreamingUtil.updateSObject(customPostToUpdate,'Class:Social_CareManagerResponseEmailUtility Method:sendEmailToCustomer:Failed to updated custom post');
                
            //Create Email Message Record and a task    
            EmailMessage em = new EmailMessage();
            em.ParentId = customPost.Case__c;
            em.Status = '3';
            em.FromAddress = 'attcustomercare@att.com';
            em.FromName = 'ATT Email To Case';
            String strTempToAddress = '';
            if(toAddressList!=null && toAddressList.size()>0){
                for(String address: toAddressList){
                    strTempToAddress = strTempToAddress + address + ',';
                }
                strTempToAddress = strTempToAddress.substring(0, strTempToAddress.lastIndexOf(','));
            }
            em.ToAddress = strTempToAddress;
            em.Subject = strSubject;
            em.HtmlBody = strBody;
            emailMessageToInsert.add(em);
            Social_StreamingUtil.insertSObject(emailMessageToInsert,'Class:Social_CareManagerResponseEmailUtility Method:sendEmailToCustomer: Failed to insert email message');                   
            processTaskandEvent(customPost.Case__c);
        }           
    }
    
    /**
    * < getContactEmailId() - Method to get contact details>
    * @param:
    *     Id ContactId: Contact Id.
    *
    * @return - strEmailId
    * @see -  (Same Class -  Social_CareManagerResponseEmailUtility)   
    */
    
    public static String getContactEmailId(Id ContactId){
        String strEmailId = '';
        if(ContactId!=null){
            Contact customerContact  = [Select Email from Contact where id=: ContactId];
            if(customerContact.Email!=null && !(customerContact.Email).equals('')){
                strEmailId = customerContact.Email;
            }
        }
        return strEmailId;
    }
    
    /**
    * < processTaskandEvent() - Method to update case,assign new case to nesting user>
    * @param:
    *     Id CaseId: CaseId.
    *
    * @return - void
    * @see -  (Same Class -  Social_CareManagerResponseEmailUtility)   
    */
    
    private static void processTaskandEvent(Id CaseId){
        List<Case>caseListToUpdate = new List<Case>();
        Map<Id,Id>caseTeamMemberMap = new Map<Id,Id>();
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> caseOwnerIdSet = new Set<Id>();
        if(CaseId!=null){                      
            Case parentCase = [Select id, Current_SLA_Phase__c, First_SLA_Response_Time__c,Second_SLA_Response_Time__c,First_SLA_Scheduled_Time__c,Second_SLA_Scheduled_Time__c,Initial_Outreach_Manager__c,Reason, status,OwnerId from Case where id=:CaseId];                
            String caseOwnerString = parentcase.ownerId;
            parentCase.Customer_Response_Received__c = false;
            parentCase.Update_Reason__c = '';
            parentCase.Last_Outreach_Time__c = System.now();
            //adding case owner id to set in order to assign him new case
            if (!caseOwnerString.startsWith(Social_StreamingUtil.QUEUE_ID)){
                caseOwnerIdSet.add(parentCase.ownerId);
            }
            if(Social_StreamingUtil.CASE_STATUS_NEW.equalsIgnoreCase(parentcase.Status)){
                parentCase.status =Social_StreamingUtil.CASE_STATUS_INVESTIGATING;
            }
            if(parentCase.Initial_Outreach_Manager__c == NULL){
                parentCase.Initial_Outreach_Manager__c = parentCase.OwnerId;                                    
            }  
            if (!Social_StreamingUtil.CASE_REASON_COMPLETED.equalsIgnoreCase(parentCase.Reason) && !parentCase.Do_Not_Reassign__c) {                   
                if (!caseOwnerString.startsWith(Social_StreamingUtil.QUEUE_ID)){
                    Social_StreamingUtil.ownerIdSetForCaseCounter.add(parentCase.ownerId);
                    caseTeamMemberMap.put(parentCase.ownerId,parentCase.Id);
                }
                if (!Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK.equalsIgnoreCase(parentCase.Status)){
                    parentCase.status =Social_StreamingUtil.CASE_STATUS_PENDINGCLOSURE;
                }
                parentCase.Prior_Care_Manager__c = parentCase.ownerId;
                parentCase.ownerId = System.Label.PendingClouseQueueId;                
                parentCase.RecordTypeId = System.Label.Consumer_Care_Email_Case;         
            }
            if (Social_StreamingUtil.SLA1_INITIATED.equalsIgnoreCase(parentCase.Current_SLA_Phase__c) && parentCase.First_SLA_Scheduled_Time__c != Null && caseOwnerString.startsWith('005')) {
                parentCase.Current_SLA_Phase__c = Social_StreamingUtil.SLA1_ENDED;
                parentCase.First_SLA_Response_Time__c = dateTime.now();
                closeSlaEvent(parentCase.Id,'SLA - 1'); 
            }                
            else if (Social_StreamingUtil.SLA2_INITIATED.equalsIgnoreCase(parentCase.Current_SLA_Phase__c) && parentCase.Second_SLA_Scheduled_Time__c != Null && caseOwnerString.startsWith('005')) {
                parentCase.Current_SLA_Phase__c = Social_StreamingUtil.SLA2_ENDED;
                parentCase.Second_SLA_Response_Time__c = dateTime.now();
                closeSlaEvent(parentCase.Id,'SLA - 2');                
            }
            caseListToUpdate.add(parentCase);
            Social_CaseAssignmentUtility.executeTriggerCode = false;
            Social_StreamingUtil.doNtFireEmail2CaseRun = false;
            Social_StreamingUtil.updateSObject(caseListToUpdate,'Class:Social_CareManagerResponseEmailUtility Method:processTaskandEvent:Failed to updated case');
            //add case owner to case team member if case is going to queue
            if (!caseTeamMemberMap.values().isEmpty()) {
                Social_SocialPostSCSHandler.insertCaseTeamMember(caseTeamMemberMap);
            }
            //update case counter of user
            if (!Social_StreamingUtil.ownerIdSetForCaseCounter.isEmpty()) {
                social_caseCounterUserUpdate.updateCaseCounterUser(Social_StreamingUtil.ownerIdSetForCaseCounter);
            }
            //Assign new Case to user
            if (!caseOwnerIdSet.isEmpty()) {
                Social_GroupMemberHandler.assignCasesToUserBulk(caseOwnerIdSet);
            }   
        }
    }
    
   /**
    * < closeSlaEvent() - Method to close open events>
    * @param:
    *     Id CaseId
    *     String slaType
    *
    * @return - void
    * @see -  (Same Class -  Social_CareManagerResponseEmailUtility)   
    */
    
    private static void closeSlaEvent(Id CaseId, String slaType){
        if(CaseId!=null && slaType!=null){
            List<Event> eventList = [Select e.WhatId, e.OwnerId, e.Id, e.Event_Type__c, e.Event_Status__c From Event e where e.WhatId =: CaseId and e.Event_Type__c=: slaType];
            if(eventList!=null && eventList.size() > 0){
                for(Event caseEvent: eventList){
                    caseEvent.Event_Status__c = 'Closed';
                }
                Social_StreamingUtil.updateSObject(eventList,'Class:Social_CareManagerResponseEmailUtility Method:processTaskandEvent:Failed to close event');
            }
        }
    }
}