/**************************************************************************
Class Name:  Social_SocialPostTransfer
Author: Accenture
Requirement/Project Name: Social Care
Description: Batch Apex to moved WhoId from social post 
Version History: Aditya(8/August/2014)
**************************************************************************************************************************/
global class Social_SocialPostTransfer implements database.batchable<sObject> {
     public String query;
     Public String test;
     public String closedRecordType=Label.ConsumerClosedCase_RT;
     public String closedQARecordType=Label.ConsumerQAClosedCase_RT;
     public String caseStatusClosed = 'Closed';//Static string
     public String caseStatusAutoClosed = 'Auto Closed';//Static string
     //public DateTime caseCloseddate = system.now().addMonths(Integer.valueOf(System.Label.CaseClosed)); //Variable to store the datetime in month 
     public DateTime caseCloseddate = system.today().adddays(Integer.valueOf(System.Label.CaseClosed)); //Variable to store the datetime in days
     public DateTime caseCloseddate1 = system.today().adddays(Integer.valueOf(System.Label.CaseClosed)+1); //Variable to store the datetime in days
     String contactIdString = System.Label.ContactIds;
     Public set<String> contactIdSet = new set<String>();//Set to store contact ids.Will be populated from custom label ContactIds
     
     global database.QueryLocator start(database.BatchableContext bc){
         return Database.getQueryLocator(query);
     }
         
     global void execute(database.BatchableContext bc, List<Case> scopeList){
         //Populating values into set
        
         contactIdSet.addAll(contactIdString.split(','));
         Set<Id> caseIdSet = new Set<Id>();//Set contains case ids.
         List<SocialPost> socialPostListUpdate = new List<SocialPost>();//List to update social posts
         //Collecting all closed case Ids
         for (Case caseObj: scopeList) {
             caseIdSet.add(caseObj.Id);    
         }
         //Collecting all social post attached to closed cases, are from twitter or facebook and current contactId is ATTCustomerCare or ATandT
         for (SocialPost socialPostObj: [select id,MediaProvider from socialPost where parentId IN:caseIdSet and R6Service__IsOutbound__c = true and (MediaProvider = 'Twitter' OR MediaProvider = 'Facebook') and WhoId IN: contactIdSet]) {
             system.debug('post tag ids'+ socialPostObj );
             if ('Twitter'.equalsIgnoreCase(socialPostObj.MediaProvider)) {
                 socialPostObj.whoId = System.label.ATTCustomerCare1;
             } else if ('FaceBook'.equalsIgnoreCase(socialPostObj.MediaProvider)) {
                 socialPostObj.whoId = System.label.ATT1;
             }
             socialPostListUpdate.add(socialPostObj);
         }
         //turning off social post trigger dynamically
         Social_StreamingUtil.doNtFireEmail2CaseRun = false;
         //Calling update method to update social post records
         Social_StreamingUtil.updateSObject(socialPostListUpdate, 'Error in Updating the Social Post WhoId');
     }
     
     global void finish(database.BatchableContext bc){
         List<String> sendTo= new List<String>();
         sendTo.addAll(string.valueOf(Label.Email_List_for_Class_Failure).split(','));
         Social_SendAnEmailUtility.sendEmail('Automated Social Post Batch',sendTo,'Social Post Batch Job has updated contact value.', 'Automated Admin');
     }
}