/**************************************************************************
Class Name: SocialCareForseeHandler 
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: A handler class which handles the foresee functionality
Version History: Aditya(13/March/2014) - Updated the class for encoding primary component and primary
                                         component sub category for cases for release 19th march 2014.
**************************************************************************************************************************/

global class SocialCareForseeHandler {
    private static final String VANITY_URL = Label.Vanity_URL;
    private static final String EMAIL_TEMPLATE_SOCIAL ='Social_Media_Forsee';
    private static final String EMAIL_ABS_SOCIAL = 'Business_Survey_Email_FoV';
    private Id emailTemplateId = null;
    private Id emailABSTemplateId = null;
    private static final String VANITY_PAGE = VANITY_URL + '/SocialMediaPage?noc=';
    //private static final String ABS_PAGE = Label.BusinessTimbaURL;
    private static final String ABS_PAGE = Label.Timba;
    private static final String ABS_SURVEY_PAGE = Label.BusinessTimbaURL;
    //Forsee Paramters
    private static final String SURVEY_TYPE = '?cid=JxTg9PsUYKor4P5i9ne0Ug=='; //Type of Survey
    private static final String FORSEE_LINK_USED = '&sid=link'; //To tell the forsee system that the link is used
    private static final String CASE_NUM = '&cpp[aid]='; // Case Number, In case legacy its Attensity ID    
    private static final String ENCRYP_CASE_NUM ='&cpp[eid]='; //Encryption value i.e.CASE_NUM*2+288
    private static final String AGENT_CODE = '&cpp[agnt]='; //Agent who has handled the case
    private static final String CAMPA_CODE ='&cpp[mc]=ICcs4CSUB0000000L'; //Internal Campaign code
    private static final String TIME_STAMP = '&cpp[ts]='; //Current Time Stamp
    private static final String OPSMANAGER_CODE = '&cpp[ops]=';//Agent Id of the Ops Manager(User Object field)
    private static final String PRIMARY_COMPONENT = '&cpp[pc]=';// Data from the below list
    private static final String PC_SUBCATEGORY_ONE = '&cpp[pcsc1]=';//Data from the below list
    public  Boolean resend = false;
    Map<String,Foresee_URL_encoding__c> primarySubCompMap = new map<string,Foresee_URL_encoding__c>();

    //Caching Data
       Map<Id, User> userMap = null;
    
    global SocialCareForseeHandler(){
        if(null == emailTemplateId ) {
            List<EmailTemplate> emailTempList = 
            [
             Select Id from EmailTemplate Where DeveloperName = :EMAIL_TEMPLATE_SOCIAL
             LIMIT 1
            ];
            emailTemplateId = emailTempList.get(0).Id;
        }
        if(null == emailABSTemplateId){
            List<EmailTemplate> emailTempABSList = 
            [
             Select Id from EmailTemplate Where DeveloperName = :EMAIL_ABS_SOCIAL
             LIMIT 1
            ];
            emailABSTemplateId = emailTempABSList.get(0).Id;
        }
        
        //Cache userMap
        if(null == userMap) {
            userMap = new Map<Id,User>();
            List<User> userList = [Select Id, Agent_Id__c, IsActive, ManagerId from User Where IsActive = true];
            for(User userObj : userList) {
                 userMap.put(userObj.Id,userObj); 

            }
        }
    }
    
    //Method responsible to generat the Forsee URL's
    global void generateForSeeUrls(Set<Id> caseIdSet) {
      Set<Id> forseeIdSet = new Set<Id>();      
      List<Forsee_Survey__c> forseeSurList = new List<Forsee_Survey__c>();
      List<Case> caseObjList = new list<case>();
      primarySubCompMap = Social_CareHelper.encodingPrimaryAndSubComp();

      if (resend) {
          caseObjList=[Select Id,R6Service__MediaProvider__c,RecordTypeId, Business_Survey_Indicator__c,Business_Survey_Email_Indicator__c,ContactId, CaseNumber, Status, Owner.Id, Component_Primary__c,Component_Secondary__c,Assigned_Operation_Manager__c,RecordType.Name from Case Where Id in :caseIdSet];
      } else  {
          caseObjList =   
          [
           Select Id, ContactId,R6Service__MediaProvider__c,RecordTypeId, Business_Survey_Indicator__c,Business_Survey_Email_Indicator__c,CaseNumber, Status, Owner.Id ,Component_Primary__c,Component_Secondary__c,Assigned_Operation_Manager__c, RecordType.Name from Case Where
           Status = 'Closed' and Id in :caseIdSet and Id not in 
           (Select Case__c from Forsee_Survey__c)   
          ];
      }
      try {
          
          if((null != caseObjList) && !(caseObjList.isEmpty())) {
              for(Case caseObj : caseObjList) {
                  forseeSurList.add(constructForseeUrl(caseObj)); 
              } 
          }
          if(!forseeSurList.isEmpty()) {
              insert forseeSurList;
              for(Forsee_Survey__c forseeSurObj : forseeSurList) {
                forseeIdSet.add(forseeSurObj.Id);
              }
              delegateSources(forseeIdSet);
          }
      } catch(DMLException dml) {
            System.debug('DML Exception Caught:'+dml.getMessage());
      } catch(Exception excep) {
            System.debug('Exception Caught:'+excep.getMessage());
      }
    }

    /**
    * < constructForseeUrl() - Construct a foresee Object.
    * @param:
    *     Object case
    * @return - forseeSurveyObj
    * @see - SocialCareForseeHandler (same class)
    */

    private Forsee_Survey__c constructForseeUrl(Case caseObj) {
        Forsee_Survey__c forseeSurveyObj = new Forsee_Survey__c();
        String forseeUrlLink = '';
        String agentIdStr = '';
        String pcEncoding = '';
        String pcSubCategoryEncoding = '';
        String operationManagerId = '';
        String managerAgentId = '';
        
        forseeSurveyObj.Case_Number__c = caseObj.CaseNumber;
        forseeSurveyObj.Contact__c = caseObj.ContactId;
        forseeSurveyObj.Case__c = caseObj.Id;
        forseeSurveyObj.URL_Active__c = true;        
        if(caseObj.R6Service__MediaProvider__c != 'Twitter' /* && caseObj.RecordTypeId == System.Label.Business_Closed_RT */){
            forseeSurveyObj.Business_Page_Load_Count__c = 1;            
        }
        if(/*caseObj.RecordTypeId == System.Label.Business_Closed_RT && */ caseObj.R6Service__MediaProvider__c == 'Twitter'){
            forseeSurveyObj.Business_Page_Load_Count__c = 0;           
        }       
        if(resend) {
            forseeSurveyObj.Resent_Survey__c=true;
        }
        //Added containsKey check
        if (userMap.containsKey(caseObj.Owner.Id)) {
            agentIdStr = userMap.get(caseObj.Owner.Id).Agent_Id__c;
            //If agentIdStr is null then make it blank
            agentIdStr = agentIdStr != null ? agentIdStr : '';
            //fetching cases owner managers SFDC id.
            operationManagerId = userMap.get(caseObj.Owner.Id).ManagerId;
            if (operationManagerId != Null) {
                managerAgentId = userMap.get(operationManagerId).Agent_Id__c;
                //If Assigned_Operation_Manager__c is null then replcae null
                managerAgentId = managerAgentId != null ? managerAgentId : '';
            }
        }
        
        //Condition for geting encoding for primary component.
        if(caseObj.Component_Secondary__c == Null && primarySubCompMap.containsKey(caseObj.Component_Primary__c + 'NA')) {
            pcEncoding = primarySubCompMap.get(caseObj.Component_Primary__c + 'NA').Encoding_Primary_Component__c;
            pcEncoding = pcEncoding != null ? pcEncoding : '';
        } else {
            if(primarySubCompMap.containsKey(caseObj.Component_Primary__c + caseObj.Component_Secondary__c)) {
                pcEncoding = primarySubCompMap.get(caseObj.Component_Primary__c + caseObj.Component_Secondary__c).Encoding_Primary_Component__c;
                pcEncoding = pcEncoding != null ? pcEncoding : '';
            } 
        }
        //Condition for geting encoding for primary sub component.
        if (caseObj.Component_Secondary__c == Null && primarySubCompMap.containsKey(caseObj.Component_Primary__c + 'NA')) {
            pcSubCategoryEncoding = primarySubCompMap.get(caseObj.Component_Primary__c + 'NA').Encoding_Primary_Component_Sub_Category1__c;
            pcSubCategoryEncoding = pcSubCategoryEncoding != null ? pcSubCategoryEncoding : '';
        } else {
            if(primarySubCompMap.containsKey(caseObj.Component_Primary__c + caseObj.Component_Secondary__c)) {
                pcSubCategoryEncoding = primarySubCompMap.get(caseObj.Component_Primary__c+caseObj.Component_Secondary__c).Encoding_Primary_Component_Sub_Category1__c;
                pcSubCategoryEncoding = pcSubCategoryEncoding != null ? pcSubCategoryEncoding : '';
            }
        }
        if(caseObj.RecordType.Name.contains('Consumer')){
            forseeSurveyObj.Forsee_URL__c  = constructURLWithParameters(caseObj.CaseNumber,(agentIdStr == null ? '' :agentIdStr),pcEncoding,pcSubCategoryEncoding,managerAgentId);
            }
        else{
            forseeSurveyObj.Forsee_URL__c  = ABS_SURVEY_PAGE + 'case_Id=' + caseObj.Id + '&cld='+ caseObj.ContactId + '&id=' + Label.Business_Survey_ID;
        }  
        return forseeSurveyObj;
    }
    
    /**
    * < constructURLWithParameters() - Method used to construct the forsee URL with the query paramters
    * @param:
    *     String caseNumber - String will contain case number.
    *     String agentCode - String will contain agent code.
    *     String encodePrimary - String will contain encoding number for primary component on case.
    *     String encodeSubPrimary - String will contain encoding number for primary component sub category one on case.
    * @return - domainName
    * @see - SocialCareForseeHandler (same class)
    */
    
    private String constructURLWithParameters(String caseNumber, String agentCode, String encodePrimary, String encodeSubPrimary, string managerAgentId) {
        Integer caseNumberInt = Integer.valueOf(caseNumber);
        Integer caseNumberEncry = (caseNumberInt * 2) + 288; //Here 288 value is for IPad
        String domainName = Label.Forsee_URL;
        system.debug('PrimaryComponentEncodingValue' + encodePrimary + 'PC_Secondaryvalue' +encodeSubPrimary );
        domainName += SURVEY_TYPE;
        domainName += FORSEE_LINK_USED;
        domainName += CASE_NUM + caseNumber;
        domainName += ENCRYP_CASE_NUM + caseNumberEncry;
        domainName += AGENT_CODE + EncodingUtil.base64Encode(Blob.valueOf(agentCode));
        domainName += CAMPA_CODE;
        domainName += TIME_STAMP + DateTime.now().getTime();
        domainName += PRIMARY_COMPONENT + encodePrimary;
        domainName += PC_SUBCATEGORY_ONE + encodeSubPrimary;
        domainName += OPSMANAGER_CODE + EncodingUtil.base64Encode(Blob.valueOf(managerAgentId));
        return domainName;
    }

    
    //A delegate method which calls the twitter DM and Email sources
    global void delegateSources(Set<Id> forseeIdSet) {
        String responseString = '';
        List<Forsee_Survey__c> forseeObjsUptList = new List<Forsee_Survey__c>();
        List<Forsee_Survey__c> forseeSurObjList = 
        [
         Select Id, Contact__r.Id,Business_Page_Load_Count__c, Contact__r.Email, Contact__r.Name,
         Email_Failure_Reason__c,Email_Sent__c,Forsee_URL__c,Name,One_Time_Used__c,
         Survey_Expired__c,Twitter_Direct_Message_Sent__c,Twitter_Failure_Reason__c,
         URL_Active__c,Case__r.Social_Persona_Name__c, Case__r.Social_Care_Handle_Name__c,Case__r.RecordType.Name,Case__r.ContactId,Case__r.Id 
         from Forsee_Survey__c Where Id in :forseeIdSet
        ];
        
        try {
            System.debug('forseeSurObjList'+forseeSurObjList.size());
            for(Forsee_Survey__c forseeObj : forseeSurObjList) {
                if(forseeObj.Case__r.RecordType.Name.contains('Consumer')){
                    forseeObj.Vanity_URL__c = VANITY_PAGE + forseeObj.Id;
                }
                else{
                    //forseeObj.Vanity_URL__c = ABS_PAGE + 'case_Id=' + forseeObj.Case__r.Id + '&cid='+ forseeObj.Contact__r.Id + '&id=' + Label.Business_Survey_ID;
                    forseeObj.Vanity_URL__c = ABS_PAGE + '/CustomerSatisfactionSurvey'+ '?noc=' + forseeObj.Id; 
                }
                responseString = sendURLViaTwitter(forseeObj);
                System.debug('hello'+responseString);
                /*if(responseString.length() <= 0) {
                    forseeObj.Twitter_Direct_Message_Sent__c = true;
                    forseeObj.URL_Sent_Date__c = DateTime.now();
                    forseeObj.URL_Active__c = true;
                    
                } else {
                    forseeObj.Twitter_Direct_Message_Sent__c = false;
                    forseeObj.Twitter_Failure_Reason__c = responseString;
                    
                    responseString = sendURLViaEmail(forseeObj);
                    
                    if(responseString.length() <= 0) {
                        forseeObj.Email_Sent__c = true;
                        forseeObj.URL_Sent_Date__c = DateTime.now();
                    } else {
                        forseeObj.Email_Sent__c = false;
                        forseeObj.URL_Active__c = false;
                        forseeObj.Email_Failure_Reason__c = responseString;
                    }
                }
                
                if((forseeObj.Twitter_Direct_Message_Sent__c) || (forseeObj.Email_Sent__c)) {
                    forSeeObj.Sent_In_48_Hours__c = true;
                } else {
                    forSeeObj.Sent_In_48_Hours__c = false;
                }
                forseeObjsUptList.add(forseeObj);*/
            }
            
            /*if((null != forseeObjsUptList) && !(forseeObjsUptList.isEmpty())) {
                update(forseeObjsUptList);
            }*/
            
        } catch(DMLException dml) {
            System.debug('DML Exception Caught'+dml.getMessage());
        } catch(Exception excep) {
            System.debug('Exception Caught'+excep.getMessage());
        }
    }
    
    //A method to send a URL via twitter
    private String sendURLViaTwitter(Forsee_Survey__c forSeeObj) {
        //Here the logic to deal with the twitter API
        SocialMediaRoundRobin mediaRoundRobin = null;
        String twitterResponseMsg = '';
        String socialCareHandleName = '';
        String socialPersonaName = '';
        boolean isConsumer;
        String tritterHandle = '';
        
        // FORESEE CHANGE
        String vanityUrl = Label.Vanity_Message + '\n' + forSeeObj.Vanity_URL__c;
        
        String timbaURL = Label.Vanity_Message + '\n' ;
        
        try {

            socialPersonaName = forseeObj.Case__r.Social_Persona_Name__c != null ?
                forseeObj.Case__r.Social_Persona_Name__c : '';
            socialCareHandleName  = forseeObj.Case__r.Social_Care_Handle_Name__c != null ?
                forseeObj.Case__r.Social_Care_Handle_Name__c : '';
            isConsumer = forseeObj.Case__r.RecordType.Name.contains('Consumer') ? TRUE : FALSE ;
            //socialCareHandleName  = socialCareHandleName.substringBefore(' ').
              //  substringAfter('@');
            tritterHandle = isConsumer != FALSE ? Label.Consumer_DefaultTwitterHandle : Label.Business_DefaultTwitterHandle;
            //vanityUrl = 'Thank you again';
            if(isConsumer == FALSE){
                SocialMediaRoundRobin.invokeTwitterDM(
                    vanityUrl,
                    socialPersonaName,
                    tritterHandle,
                    //Label.Consumer_DefaultTwitterHandle,
                    forSeeObj.Id, 
                    emailABSTemplateId
                );
            }
            else{
            
                SocialMediaRoundRobin.invokeTwitterDM(
                    vanityUrl,
                    socialPersonaName,
                    tritterHandle,
                    //Label.Consumer_DefaultTwitterHandle,
                    forSeeObj.Id, 
                    emailTemplateId 
                );
            }
        
        } catch(Exception excep) {
            System.debug('Exception Caught :'+excep.getMessage());
        }
        return twitterResponseMsg;
    }
    
    //A method to send a URL via Email -- Removed
   /* private String sendURLViaEmail(Forsee_Survey__c forSeeObj) {
        //Here the logic to deal with the email server
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        try {
            mail.setTargetObjectId(forSeeObj.Contact__r.Id);
            mail.setWhatId(forSeeObj.Id);
            mail.setTemplateId(emailTemplateId);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        } catch(Exception excep) {
            System.debug('Exception Caught:'+excep.getMessage());
            return excep.getMessage();
        }
        return '';
    }*/
}