global class SocialCareController {
    private static final String USER_MODIFIED_URL = Label.Social_Url_Modified;
    private static final String LINK_USED = Label.Social_Link_Used;
    private static final String LINK_EXPIRED = Label.Social_Link_Expired;
    
    public Forsee_Survey__c forseeSurveyObj {get; set;}
    public String responseMessage {get; set;}
    public SurveyDetails surveyDet {get; set;}
    public boolean surveyDetailsFlag {get;set;}
    
    public SocialCareController() {}
    
    //A method to validate the Foresee URL
    global PageReference doValidateUrl() {
        String foreseeId = ApexPages.currentPage().getParameters().get('noc');
        List<Forsee_Survey__c> forseeSurveyList = new List<Forsee_Survey__c>();
        PageReference pageForward = null;

        String forseeQuery = '';
        String responseStr = '';
        surveyDetailsFlag = false;
        surveyDet = new SurveyDetails();
        
        try {
        String ReturnValue = '';

        ReturnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');
            
        if (ReturnValue == '') {
            ReturnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        } // get IP address when no caching (sandbox, dev, secure urls)
                
        //system.debug('USER IP ADDRESS: ' + ReturnValue);
        
            if((null != foreseeId) && (foreseeId.length() == 15 || foreseeId.length() == 18)) {
                forseeQuery = 
                'Select Id,Forsee_URL__c,Business_Page_Load_Count__c,User_Machine_details__c,Case_Number__c,URL_Active__c,One_Time_Used__c,URL_Sent_Date__c,'+
                'CreatedDate,Survey_Expired__c,resent_survey__c from Forsee_Survey__c Where Id = \'' + foreseeId + '\' Limit 1';
                forseeSurveyList = Database.query(forseeQuery);
                if((null != forseeSurveyList) && !(forseeSurveyList.isEmpty())) {
                    forseeSurveyObj = forseeSurveyList.get(0);
                    forseeSurveyObj.User_Machine_details__c = forseeSurveyObj.User_Machine_details__c + ReturnValue;
                    //Block for One time Click and Survey Expired
                    if((forseeSurveyObj.URL_Active__c) && !(forseeSurveyObj.One_Time_Used__c) && !(forseeSurveyObj.Survey_Expired__c)) {
                        forseeSurveyObj.Business_Page_Load_Count__c = forseeSurveyObj.Business_Page_Load_Count__c +1;     
                        if(forseeSurveyObj.Business_Page_Load_Count__c == 2){ 
                            forseeSurveyObj.URL_Active__c = false;
                            if(!(DateTime.now() > forseeSurveyObj.URL_Sent_Date__c.adddays(2))) { //need to modify later addDays(14)
                                forseeSurveyObj.One_Time_Used__c = true;
                            }
                            pageForward = new PageReference(forseeSurveyObj.Forsee_URL__c);
                        }
                    } else {
                        if(!(DateTime.now() > forseeSurveyObj.URL_Sent_Date__c.adddays(2))) { //need to modify later addDays(14)
                            if(!forseeSurveyObj.Survey_Expired__c) {
                                responseMessage = LINK_USED;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, responseMessage));
                            }
                        }
                    }//End for one time click

                    //Block to handle the foresee link expiry
                    if(DateTime.now() > forseeSurveyObj.URL_Sent_Date__c.adddays(2)) { //need to modify later addDays(14)
                        forseeSurveyObj.Survey_Expired__c = true;
                        forseeSurveyObj.URL_Active__c = false;
                        responseMessage = LINK_EXPIRED;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, responseMessage));
                        pageForward = null;
                    }
                    //Update the Foresee Object
                    update(forseeSurveyObj);
                    /*ram*/
                    if(forseeSurveyObj.resent_survey__c)
                    {
                    if(forseeSurveyObj.Survey_Expired__c)
                    {
                    responseMessage = LINK_EXPIRED;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, responseMessage));
                    }
                    else if(forseeSurveyObj.One_Time_Used__c)
                    {
                    responseMessage = LINK_USED;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, responseMessage));
                    }
                    }
                    else
                    {
                    if(forseeSurveyObj.Survey_Expired__c)
                    {
                    responseMessage = LINK_EXPIRED;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, responseMessage));
                    }
                    }    
                     /*ram*/          
                } else {
                    responseMessage = USER_MODIFIED_URL;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, responseMessage));
                }
            } else {
                responseMessage = USER_MODIFIED_URL;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, responseMessage));
            }
            
        } catch(Exception excep) {
            System.debug('Exception Caught:'+excep.getMessage());
        }
        
        //Survey Details Block
        if((null != responseMessage) && (responseMessage.length()) > 0 &&
            !USER_MODIFIED_URL.equalsIgnoreCase(responseMessage)) {
            surveyDet = new SurveyDetails(DateTime.now(), forseeSurveyObj.CreatedDate,
                forseeSurveyObj.URL_Sent_Date__c,forseeSurveyObj.One_Time_Used__c);
            surveyDetailsFlag = true;    
        }
        
        return (pageForward == null) ? null : pageForward;
    }
    
    //An inner class which holds the survey details to be rendered when there is a failure
    global class SurveyDetails {
        public DateTime todaysDate {get; set;}
        public DateTime urlCreatedDate {get; set;}
        public DateTime urlSentDate {get; set;}
        public Boolean surveyGiven {get; set;}
        public String surveyGivenStr {get; set;}
        public SurveyDetails() {}

        public SurveyDetails(DateTime todaysDate, DateTime urlCreatedDate,
            DateTime urlSentDate,boolean surveyGiven) {
            this.todaysDate = todaysDate;
            this.urlCreatedDate = urlCreatedDate;
            this.urlSentDate = urlSentDate;
            this.surveyGiven = surveyGiven;
            this.surveyGivenStr = this.surveyGiven ? 'Yes, Customer has given the Survey' 
                : 'No, Customer hasn\'t given the Survey';
        }  
    }
}