// A Class handles the social media handles in the round-robin fashion
public class SocialMediaRoundRobin {
    
    public static Id emailTemplateId;
    public static String twitterStatusMsg {get; set;}
    private static final String VANITY_URL = Label.Vanity_URL;
    private static final String VANITY_PAGE = VANITY_URL + '/SocialMediaPage?noc=';
    
    //No args Cons
    public SocialMediaRoundRobin() {
    }
    
    //Picks the handle based on the lastmodified date
    public Social_Media_Account__c allocateSocialMediaHandle(String senderHandle) {
       system.debug('senderhandle' + senderHandle);
        List<Social_Media_Account__c> socialMeidaAccountList = new List<Social_Media_Account__c>();
        
        try {
            
            socialMeidaAccountList = [
                Select Consumer_Key__c,Consumer_Secret__c,Access_Secret__c,Access_Token__c,
                Id,Name,Queue_Assigned_Date__c,Social_Media_Handle__c from Social_Media_Account__c
                Where Social_Media_Handle_Name__c = :senderHandle order by LastModifiedDate Asc Limit 1
            ];
            
        } catch(Exception excep) {
            System.debug('Exception Caught :'+excep.getMessage());
            return null;
        }
        
        return socialMeidaAccountList.isEmpty()? null : socialMeidaAccountList.get(0);
    }
    
    //Method to call the twitter utility
    public String sendSocialMediaDM(String vanityURL, 
        String dmReceiverHandle, 
        String dmSenderHandle) {
        
        String statusMessage = '';
        Social_Media_Account__c socialMediaAcct = null;
        SocialMediaTwitterRest socialMediaTwit = null;
        
        
        try {
            
            socialMediaTwit = new SocialMediaTwitterRest();
            socialMediaAcct = allocateSocialMediaHandle(dmSenderHandle);
            
            if(null != socialMediaAcct) {
                socialMediaAcct.Queue_Assigned_Date__c = DateTime.now();
                System.debug('OAuth :'+socialMediaAcct);
                socialMediaTwit.oauthWrap.setOauthTokens(
                    socialMediaAcct.Consumer_Key__c,
                    socialMediaAcct.Consumer_Secret__c,
                    socialMediaAcct.Access_Token__c,
                    socialMediaAcct.Access_Secret__c,
                    dmReceiverHandle,
                    vanityURL
                );
                statusMessage = socialMediaTwit.invokeTwitterRequest();
                //update socialMediaAcct;
            } else {
                statusMessage = 'Configure Social Media Account details for :'+dmSenderHandle;
            }
            
        } catch(Exception excep) {
            System.debug('Exception Caught :'+excep.getMessage());
            statusMessage = excep.getMessage();  
        }
        return statusMessage;
    }
    
    //A method to send a URL via Email
    private String sendURLViaEmail(Forsee_Survey__c forSeeObj) {
        //Here the logic to deal with the email server
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        try {
            mail.setTargetObjectId(forSeeObj.Contact__r.Id);
            mail.setWhatId(forSeeObj.Id);
            mail.setTemplateId(emailTemplateId);
            if(forSeeObj.Case__r.RecordType.Name.contains('Business')){
                //mail.setOrgWideEmailAddressId(Label.Organization_Wide_Email_Addresses);
                mail.setOrgWideEmailAddressId(Label.Business_Organization_Wide_Address);
            }
            else{
                mail.setOrgWideEmailAddressId(Label.Organization_Wide_Email_Addresses);
                //mail.setOrgWideEmailAddressId(Label.Business_Organization_Wide_Address);
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            System.debug('Hello :'+mail);
        } catch(Exception excep) {
            System.debug('Exception Caught:'+excep.getMessage());
            return excep.getMessage();
        }
        return '';
    }
    
    //A method to handle the foresee stuff
    public void handleForeseeObj(Id forseeObjId, String responseString) {
        List<Forsee_Survey__c> forseeSurObjList = 
        [
            Select Id, Contact__r.Id, Contact__r.Email, Contact__r.Name,
            Email_Failure_Reason__c,Email_Sent__c,Forsee_URL__c,Name,One_Time_Used__c,
            Survey_Expired__c,Twitter_Direct_Message_Sent__c,Twitter_Failure_Reason__c,
            URL_Active__c,Case__r.Id, Case__r.Social_Persona_Name__c, 
            Case__r.Social_Care_Handle_Name__c,Case__r.RecordTypeId,Case__r.RecordType.Name
            from Forsee_Survey__c Where Id = :forseeObjId Limit 1
        ];
        
        Forsee_Survey__c forseeObj = forseeSurObjList.get(0);
        
        forseeObj.Vanity_URL__c = VANITY_PAGE + forseeObj.Id;
        
        if(responseString.length() <= 0) {
            forseeObj.Twitter_Direct_Message_Sent__c = true;
            forseeObj.URL_Sent_Date__c = DateTime.now();
            forseeObj.URL_Active__c = true;
            
        } else {
            forseeObj.Twitter_Direct_Message_Sent__c = false;
            forseeObj.Twitter_Failure_Reason__c = responseString.trim();
            
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
        
        update(forSeeObj);
    }
   
    //A future method
    @Future(callout=true)   
    public static void invokeTwitterDM(
        String vanityURL,
        String socialPersonaName,
        String socialCareHandleName,
        Id foreseeObjId, 
        Id rootEmailTemplateId) 
                {
        system.debug('socialCareHandleName'+socialCareHandleName);

        try {
            
            emailTemplateId = rootEmailTemplateId;
            SocialMediaRoundRobin roundRobinObj = new SocialMediaRoundRobin();
            twitterStatusMsg = roundRobinObj.sendSocialMediaDM(
                vanityURL,
                socialPersonaName,
                socialCareHandleName
            );
            System.debug('Msg:'+twitterStatusMsg+':'+socialPersonaName+':'+socialCareHandleName);
            roundRobinObj.handleForeseeObj(foreseeObjId, twitterStatusMsg);
        
        } catch(Exception excep) {
            System.debug('Exception Caught from Callout :'+ excep.getMessage());
        }
    }
}