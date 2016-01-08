/*************************************************************************************************************************
Class Name:  Social_CareManagerResponseEmail
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: This class is the controller class for custom send email buttonfor consumer HS care Reps and Care Managers
version history : v1.1 - Aditya : Updated the class for release 11th march requirements.
version history : v1.2 - Ramakrishna Yella :  On April 1st 2014- increased the soql limit from 50 to 250 @ List<contact> lcon 
version history : v1.3 - Aditya : Updated the class for enabling rich text when user clicks on "Send An Email" button.
**************************************************************************************************************************/

public class Social_CareManagerResponseEmail {
    public String strTemp{get;set;}
    public String strFromAddress{get;set;}
    public String strToAddress{get;set;}
    public Custom_Post__c customPost{get;set;} 
    public Case newCase{get;set;}
    private Map<Id, EmailTemplate> templateMap = null;
    private Integer count = 0;
    public String myMessages {get;set;}
    public String emailMessages {get;set;}
    public boolean formRenderer{get;set;}
    public boolean noformRenderer{get;set;}
    public string message{get;set;}
    public string flag{get;set;}
    public boolean errorflag{get;set;}
    public boolean richtext{get;set;}
    public boolean excchkbox{get;set;}
    public boolean renderReply{get;set;}
    public boolean renderEscalation{get;set;}
    Public String caseNoContactName{get;set;}
    private Social_CaseEmailInBoundUtilities caseinb=new Social_CaseEmailInBoundUtilities();// Class initialized to call the limit length method.
    public SelectOption[] selectedContacts { get; set; }//Variable is used to store all the selected contacts emails in the multiselect page
    public SelectOption[] allContacts { get; set; }//Variable is used to store all  contacts emails in the multiselect page
    public string Body{get;set;}//variable used to store the body of the mail
    public string subj{get;set;}//variable used to store the subject of the mail
    public string addto{get;set;}//variable used to store the body of the mail
    public string BCC{get;set;}//variable used to store the BCC members of the mail
    public string CC{get;set;}//variable used to store the CC members of the mail
    public string toemail{get;set;}//variable used to store the recipient of the mail
    public string emsgid{get;set;}// Variable used to store the email message id during navigation from email message detail page
    private pagereference pageref;
    public string errorstring{get;set;}//error string for DB insert 
    public Map<Id, Map<String, List<Event>>> caseEventMap = new Map<Id, Map<String, List<Event>>>();//map used to store all the events and the type for a case id
    public string contactid{get;set;}//Contact id used when looking up all contact emails.
    public string cid{get;set;}//Case id used when looking up all contact emails.
    private List<string> toAddress=new list<string>();//List used to store the to address
    private List<string> ccAddress=new list<string>();//List used to store the CC address
    private List<string> bccAddress=new list<string>();//List used to store the BCC address    
    
   /**
    * < Social_CareManagerResponseEmail() - Default constructor which has code to fetch emails for contact when lookup page opens or display error message.
    * @param: contact id and case id from url
    * 
    * @return - void.
    * @see - Social_UserEmailLookup(Page),Social_CustomEmailCase(Page)
    */   
    public Social_CareManagerResponseEmail() {
        strFromAddress = 'attcustomercare@att.com';
        flag='';
        emsgid=null;
        contactid='';
        cid='';
        excchkbox=false;
        addto='';
        errorflag=false;
        customPost = new Custom_Post__c(); 
        newcase= new case();
        allContacts = null;
        if(ApexPages.currentPage().getParameters().get('caseId')!=null){
            customPost.case__c = ApexPages.currentPage().getParameters().get('caseId');
            newcase.id=ApexPages.currentPage().getParameters().get('caseId');
        }
        
        templateMap =  new Map<Id, EmailTemplate>();
        selectedContacts = new List<SelectOption>();
        contactid=ApexPages.currentPage().getParameters().get('conid');
        cid=ApexPages.currentPage().getParameters().get('caseid');
        if(string.isnotblank(ApexPages.currentPage().getParameters().get('exmail'))&& 'true'.equalsignorecase(ApexPages.currentPage().getParameters().get('exmail'))){
            excchkbox=true; 
        }
        if(!string.isblank(addto)){
                List<string> laddto = addto.split(';',0);
        }
        if(!string.isblank(contactid) && !excchkbox) {
            renderEscalation = false;
            renderReply = true;
            contact ct=[SELECT All_Contact_Emails__c FROM Contact where id=:contactid limit 1];
            String semails = ct.All_Contact_Emails__c;
            if(!string.isblank(semails)){
                allContacts = new List<SelectOption>();
                List<string> scontacts=semails.split(';',0);
                for ( string c : scontacts ) {
                    allContacts.add(new SelectOption(c, c));
                    //allContacts.add(new SelectOption('AA', 'BB'));
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There are no additional contact Emails to select from.'));
            }
        } else {
            populateescalationemails();
        }
       
        if(string.isnotblank(ApexPages.currentPage().getParameters().get('exmail')) && 'true'.equalsignorecase(ApexPages.currentPage().getParameters().get('exmail'))){
            excchkbox=true; 
            renderEscalation = true;
            renderReply = false;
            if(newcase.Contact.name != Null && newcase.casenumber != Null) {
                caseNoContactName = newcase.casenumber + '' + '(' +newcase.Contact.name + ')';
            }
            if(String.isnotblank(ApexPages.currentPage().getParameters().get('postId'))){
                richtext = true;
            }
        } else {
            excchkbox = false; 
            renderEscalation = false;
            renderReply = true;
            caseNoContactName = newcase.casenumber;
        }
    }


   /**
    * < Social_CareManagerResponseEmail(ApexPages.StandardController controller) - Constructor which has code to fetch emails for contact when lookup page opens or display error message.
    * @param: caseid in url, the flag value to distinguish hs care rep and caremanager email functionality.emsgid stored to tell navigation from emailmessage detail page.
    * 
    * @return - void.
    * @see - Social_CustomEmailCaseList(page), Social_EmailmessageDetailPage(Page),Social_CustomEmailCase(Page)
    */
    public Social_CareManagerResponseEmail(ApexPages.StandardController controller) {
        customPost = new Custom_Post__c(); 
        newcase= new case();
        excchkbox=false;
        errorstring='';
        flag=ApexPages.currentPage().getParameters().get('flag');
            if(ApexPages.currentPage().getParameters().get('caseId')!=null){
                customPost.case__c = ApexPages.currentPage().getParameters().get('caseId');
                customPost.category__c = 'Email';
                Case c = [Select id, Do_Not_Reassign__c,reason,subject, ownerId,Second_SLA_Response_Time__c,Customer_Response_Received__c, recordTypeId, Prior_Care_Manager__c,Initial_OutReach_Manager__c, ContactId,Social_CaseThreadID__c,casenumber,case.contact.name,case.contact.Last_email_used__c,Current_SLA_Phase__c,status , Owner.ProfileId from Case where id=: customPost.case__c limit 1];
                customPost.contact__c = c.ContactId;
                newcase=c;
                if(customPost.contact__c!=null){
                    emailMessages = getContactEmail(customPost.contact__c);
                }                
                customPost.BCCAddress__c = UserInfo.getUserEmail();
                customPost.Subject__c = c.subject;                
            }
            if(!'TRUE'.equalsignorecase(flag)){
                templateMap =  new Map<Id, EmailTemplate>();
                Boolean returnValue = checkCustomPostEmailExists(customPost.Case__c);
                formRenderer = returnValue;
                noformRenderer = !returnValue;
            }
            richtext=false;      
            emsgid = ApexPages.currentPage().getParameters().get('eid');
            if(!string.isblank(emsgid)) {
                List<Emailmessage> lemsg=[select messagedate,fromaddress,subject,TextBody,toaddress,htmlbody from emailmessage where id=:emsgid];
                //Body=lemsg[0].TextBody;
                body = lemsg[0].htmlbody;        
                if(!String.isblank(body)){
                    richtext=true;
                    body = '<br>'+'<br>'+'<br>'+'<br>'+'--------------- Original Message ---------------'+'<br>'+'<br>'+'From:  ['+lemsg[0].fromaddress+']'+'<br>'+'Sent: '+lemsg[0].messagedate+'<br>'+'To: '+lemsg[0].toaddress+'<br>'+'<br>'+
                   'Subject:'+lemsg[0].subject+'<br>'+'<br>'+ Body+'<br>'+'<br>';
                } else if(!String.isblank(lemsg[0].TextBody)){
                    body = lemsg[0].TextBody;
                    if(body.length()>0){
                        body='\n'+'\n'+'\n'+'\n'+'--------------- Original Message ---------------'+'\n'+'\n'+'From:  ['+lemsg[0].fromaddress+']'+'\n'+'Sent: '+lemsg[0].messagedate+'\n'+'To: '+lemsg[0].toaddress+'\n'+'\n'+
                       'Subject:'+lemsg[0].subject+'\n'+'\n'+ Body+'\n'+'\n';
                    }
                }
                subj=lemsg[0].subject;
            } 
            if(!string.isblank(ApexPages.currentPage().getParameters().get('addto'))){  
                if(string.isblank(addto)){
                    addto=ApexPages.currentPage().getParameters().get('addto');
                } else {
                    addto=addto+';'+ApexPages.currentPage().getParameters().get('addto');
                }
            } 
         
            if(string.isnotblank(ApexPages.currentPage().getParameters().get('exmail')) && 'true'.equalsignorecase(ApexPages.currentPage().getParameters().get('exmail'))){
                excchkbox=true; 
                renderEscalation = true;
                renderReply = false;
                populateescalationemails();
                if(String.isnotblank(ApexPages.currentPage().getParameters().get('postId'))){
                    richtext = true;
                }
                if(newcase.Contact.name != Null && newcase.casenumber != Null) {
                    caseNoContactName = newcase.casenumber + ' ' + '(' +newcase.Contact.name + ')';
                }
            } else {
                excchkbox = false; 
                renderEscalation = false;
                renderReply = true;
                caseNoContactName = newcase.casenumber;
            }
            //to email rich text when user clicks on send an email button
            string isSendAnEmail = ApexPages.currentPage().getParameters().get('sendAnEmail');
            if (isSendAnEmail != Null && 'True'.equalsIgnoreCase(isSendAnEmail)) {
                richtext = true;    
            }
    }
    
   /**
    * < getEmailTemplates() - This method is used in the VF page to get the list of email templates
    * @param
    * 
    * @return - SelectOption.
    * @see - Social_CareManagerResponseEmail(Class)
    */
    
    public List<SelectOption> getEmailTemplates(){
        List<SelectOption> optionsList = new List<SelectOption>();
        List<EmailTemplate> emailTemplateList  =  [Select body, HtmlValue, Subject, Name From EmailTemplate where IsActive = true];
        optionsList.add(new SelectOption('',''));
        if(emailTemplateList!=null && emailTemplateList.size()>0){
            for(EmailTemplate template: emailTemplateList){
                optionsList.add(new SelectOption(template.id, template.name));
                templateMap.put(template.id, template);
            }
        }
        return optionsList;
    }
    
   /**
    * < showDetail() - This method is used to show the detail of the email template
    * @param
    * 
    * @return - SelectOption.
    * @see - Social_CareManagerResponseEmail(Class)
    */
   
    public PageReference showDetail() {
        if(customPost.EmailTemplate__c!=null && !templateMap.isEmpty() && !customPost.EmailTemplate__c.equals('')){
            EmailTemplate template = templateMap.get(customPost.EmailTemplate__c);
            customPost.subject__c = template.Subject;             
            customPost.body__c = template.body;
        }
        else if(null == customPost.EmailTemplate__c || customPost.EmailTemplate__c.equals('')){
            customPost.subject__c = '';             
            customPost.body__c = '';
        }
        return null;
    }

   /**
    * < save() -- Method used to send email and close any open SLA's for that mail for caremanager functionality and create custom post for approval for HS Care rep.
    * @param: The parameters entered in the input fields on Send Email page . Also Labels used for setting from address.
    * 
    * @return - PageReference. Returns null. Naviagation is done in javascript on Send Email page.
    * @see - Social_CustomEmailCase(Page)
    */  
    public PageReference save() {
        string  patternString='';//Variable is used to store the pattern reference string from a label
        Pattern thePattern;//compiled version of the pattern 
        Matcher matcher; //to store the matching results after pattern matching
        String  value='';
        Integer maxlength=0;
        errorflag=false;// this flag is used to prevent window closure and main window refresh in case of validation error
        if('TRUE'.equalsignorecase(flag)){
            if(string.isempty(toemail) || '- None -'.equalsignorecase(toemail)&& !excchkbox){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a To Address.'));
                errorflag=TRUE;
                pageref=null;
            } else if(string.isblank(subj)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a value in the Subject Field.'));
                errorflag=TRUE;
                pageref=null;
            } else {
                Messaging.SingleEmailMessage responsemail= new Messaging.SingleEmailMessage();
                strTemp = addto;
                if(!string.isblank(addto)){
                    toAddress=addto.split(';',0);
                } else {
                    if((addto==null || string.isblank(addto)) && excchkbox){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select atleast one Escalation Email Address.'));
                        errorflag=TRUE;
                        pageref=null;
                    }
                }
                if(string.isempty(toemail) || !('- None -'.equalsignorecase(toemail))){
                    toAddress.add(toemail);
                }
                if(!string.isblank(bcc)){
                    bccaddress=bcc.split(';',0);
                }
                if(!string.isblank(cc)){
                    ccaddress=cc.split(';',0);
                }
                String refNumber = newcase.Social_CaseThreadID__c;
                String contactName = newcase.Contact.Name;
                String subRefNumber = refNumber.substring(16,26);
            
                patternString = label.Pattern_Matching;// the pattern string for reference id is stored in a custom label
                thePattern = Pattern.compile(patternString);
                matcher = thePattern.matcher(subj); // do not change to lower case for this test because Id's are case sensitive
                if (!matcher.matches()) {
                    //Added logic to append contact name in subject line.
                    if(contactName.length() <= 5) {
                        subj=subj+'  '+refNumber.substring(16,26)+'-'+contactName;
                    } else {
                        if(contactName != Null) {
                            subj=subj+'  '+refNumber.substring(16,26)+'-'+contactName.substring(0,5);
                        }
                    }
                }
              
                if(subj!=null && !subj.equals('')){
                    responsemail.setSubject(subj);
                } else {
                    responsemail.setSubject('');
                }
                responsemail.setOrgWideEmailAddressId(Label.E2C_Organisation_Wide_Email_Address);
                responsemail.setToAddresses(toAddress);
                if(!excchkbox){
                    //responsemail.targetObjectId=newcase.contactid;// necessary to get bounced email notifications
                }
                if(bccAddress.size()>0){
                    responsemail.setBccAddresses(bccAddress);}
                    if(ccAddress.size()>0) {
                        responsemail.setCcAddresses(ccAddress);
                    }
                    Body=Label.Email_Subject_Warning+'<br>'+'<br/>' +Body;
                    if(richText!=null && richText){
                        responsemail.setHtmlBody(Body);
                    } else {
                        responsemail.setplaintextBody(Body);                   
                    }
                    try { 
                        Messaging.SendEmailResult[] r = 
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {responsemail});
                        if(r.get(0).isSuccess()){
                            EmailMessage theEmail = new EmailMessage();
                            theEmail.ParentId = newcase.Id;
                            Schema.DescribeFieldResult F = EmailMessage.HtmlBody.getDescribe();
                            maxlength = F.getLength();
                            theEmail.Subject = caseinb.limitLength(subj, EmailMessage.Subject.getDescribe().getLength());
                            theEmail.MessageDate = datetime.now();
                            if(richText!=null && richText){
                                theEmail.HtmlBody = caseinb.limitLength(Body,EmailMessage.TextBody.getDescribe().getLength());
                            } else {
                                theEmail.TextBody = caseinb.limitLength(Body,EmailMessage.TextBody.getDescribe().getLength());
                            }
                             
                            /* **** To */
                            value = '';
                            if(toAddress != null) {
                                Boolean seenOne= false;
                                for(String to : toAddress) {
                                    if(seenOne) {
                                        value += ';\n';
                                    }
                                    to  = caseinb.extractAddress(to);
                                    value += to;
                                    seenOne = true;
                                }
                            }
                            theEmail.ToAddress = caseinb.limitLength(value,EmailMessage.ToAddress.getDescribe().getLength());
                            /* **** From */
                            theEmail.FromName = Label.From_Name;
                            theEmail.FromAddress = Label.From_Email_Address;
                
                            if(emsgid!=null && !(emsgid).equals('')){
                                theEmail.ReplyToEmailMessageId = emsgid;
                            }
                 
                            /* **** CC */
                            value = '';
                            if(ccaddress!= null) {
                                Boolean seenOne= false;
                                for(String cc : ccaddress) {
                                    if(seenOne) {
                                        value += ';\n';
                                    }
                                    cc  = caseinb.extractAddress(cc);
                                    value += cc;
                                    seenOne = true;
                                }
                            }
                            theEmail.CcAddress = caseinb.limitLength(value,EmailMessage.CcAddress.getDescribe().getLength());
                            List<EmailMessage> lemailmessage=new List<EmailMessage>();
                            if(theEmail!=null){ 
                                lemailmessage.add(theEmail);
                            }
                            if(lemailmessage.size()>0){
                                dbopmethod(lemailmessage,'Insert');
                            }  
                            // To populate Initial outreach manager field when the first outreach is made to the customer
                            if('SLA1 - Initiated'.equalsIgnoreCase(newcase.Current_SLA_Phase__c) && newCase.Initial_Outreach_Manager__c == null){
                                newCase.Initial_Outreach_Manager__c = UserInfo.getUserId();
                            }   
                            if(!excchkbox && UserInfo.getUserId()!=null && newcase.OwnerId!=null && String.valueOf(UserInfo.getUserId()).contains(String.valueOf(newcase.OwnerId))){
                                caseSLAeventClosure(newcase.id,newcase.Current_SLA_Phase__c);
                            }
                           //Code for updating case status .
                            if(('New'.equalsignorecase(newcase.status) || 'Reopen'.equalsignorecase(newcase.status)) && ((newcase.Initial_OutReach_Manager__c != null && String.valueOf(UserInfo.getUserId()).contains(String.valueOf(newcase.Initial_OutReach_Manager__c))) || String.valueOf(UserInfo.getUserId()).contains(String.valueOf(newcase.ownerId)))){
                                newcase.status = 'Investigating';
                            }
                            List<Case> lcase=new List<Case>();
                            if(!excchkbox){
                                if(newcase!=null){
                                    lcase.add(newcase);
                                }
                                if(lcase.size()>0){
                                    dbopmethod(lcase,'Update');
                                }
                            }
                         }
                    } catch(Exception e) {
                        CreateExceptionObject(e.getMessage());
                    }
                    if(!errorflag && ApexPages.currentPage().getParameters().get('exmail')!=null && 'true'.equalsignorecase(ApexPages.currentPage().getParameters().get('exmail')) && ApexPages.currentPage().getParameters().get('returl')!=null){
                        pageref=new PageReference('/'+ApexPages.currentPage().getParameters().get('returl'));
                    }
                }        
            } else {
                //Aditya: Mapping field to message field 
                customPost.Message__c = customPost.Body__c;
                insert customPost;
                pageref=new PageReference('/'+customPost.id);
            }
            return pageref;
    }
    
    /**
    * < getContactEmail() -- This method is used to get the contact email id from the contact id.
    * @param: 
    *    Id contactId -- Contact Id
    * @return - String strMessage
    * @see - Social_CustomEmailCase(Page)
    */ 

/*** ***/    
    public String getContactEmail(Id contactId) {
        String strMessage = '';
        if(contactId!=null){
            try{
                Contact c = [Select Email from Contact where id =: contactId];
                if(null == c.Email || c.Email.equals('')){
                    strMessage = 'This contact does not have any Email Id. Please provide an additional Email ID';
                }
            } catch(Exception e){
                CreateExceptionObject(e.getMessage());
            }
        }
        return strMessage;
    }
    
   /**
    * < checkCustomPostEmailExists() -- This method is used to check if a custom post exists for approval for a given case id.
    * @param: 
    *    String caseId -- Case Id
    * @return - Boolean strMessage
    * @see - Social_CustomEmailCase(Page)
    */ 

    public boolean checkCustomPostEmailExists(String caseId){
        boolean returnValue = true;
        List<Custom_Post__c> customPostList = [Select id from Custom_Post__c where category__c = 'Email' and Case__c=: caseId and status__c <> 'Sent' ];
        if(customPostList!=null && customPostList.size()>0){
            returnValue = false;
        }
        return returnValue;
    }
    

   /**
    * < getemails() - Method used to Populate all the contact emails for send Email functionality in the to picklist.
    * @param: Void. Uses the case id setup in the constructor
    * 
    * @return - Select List of all the contact emails used to form the picklist.
    * @see - Social_CustomEmailCase(Page)
    */   
    public List<selectOption> getemails() {
        List<selectOption> options = new List<selectOption>(); 
        try{
            if(excchkbox) {
                options.add(new selectOption('', '- None -'));
                toemail='- None -';
            } else {
                List<case> ct1=[SELECT id, email__C,casenumber,case.contact.All_Contact_Emails__c,case.contact.Last_Email_Used__c,case.contact.email,SuppliedEmail,Owner.ProfileId FROM case where id=:newcase.id limit 1];
                if(!string.isempty(ct1[0].contact.All_Contact_Emails__c)) {
                    List<string> lemails=ct1[0].contact.All_Contact_Emails__c.split(';',0);
                    for (string ct: lemails) {
                        if(ct.equalsignorecase(ct1[0].SuppliedEmail)){
                            options.add(new selectOption(ct,ct));
                            toemail=ct; }
                        }
                    for (string ct: lemails) {
                        if(!ct.equalsignorecase(ct1[0].SuppliedEmail)){
                            options.add(new selectOption(ct,ct));}}
                } else {
                    if(!string.isempty(ct1[0].contact.email)){
                        options.add(new selectOption(ct1[0].contact.email, ct1[0].contact.email));  
                        toemail=ct1[0].contact.email;   
                    }
                }
                if(options.size()==0){
                    options.add(new selectOption('', '- None -'));
                    toemail='- None -';
                }
            }
        } catch(Exception e) {
            options.add(new selectOption('', '- None -'));
            CreateExceptionObject(e.getMessage());
        }
        return options;
    }

   /**
    * < closeSlaEvent(Id CaseId, String slaType) - Method used to close SLA for a particular case and uses the common DB insert method.
    * @param: Case id for which SLA are to be closed and the SLA type.
    * 
    * @return - Void.
    * @see - caseSLAeventClosure(Method same controller class)
    */  
    private void closeSlaEvent(Id CaseId, String slaType) {
        if(caseEventMap.get(CaseId)!=null && caseEventMap.get(CaseId).get(slaType)!=null) {
            List<Event> updateEventList = new List<Event>();
            List<Event> closeEventList = caseEventMap.get(CaseId).get(slaType);
            for(Event caseEvent: closeEventList){
                caseEvent.Event_Status__c = 'Closed';
            }
            updateEventList.addAll(closeEventList);
            if(updateEventList.size()>0){
                dbopmethod(updateEventList,'Update');}
            }
    }  

   /**
    * < caseSLAeventClosure(Id caseid,string sCurSlaPhase) - Method used to pick up all open SLA events for a particular case. This calls the closeSlaEvent method. 
    * @param: Case id for which SLA are to be closed and the current SLA phase for that case.
    * 
    * @return - Void.
    * @see - save()(Method same controller class)
    */  
    
    public void caseSLAeventClosure(Id caseid,string sCurSlaPhase){
        Set<Id> caseOwnerIdSet = new Set<Id>();
        if(caseid!=null){
            for(Event caseEvent: [Select e.WhatId, e.OwnerId, e.Id, e.Event_Type__c, e.Event_Status__c From Event e where e.WhatId =:caseid]){
                if(caseEventMap.containsKey(caseEvent.WhatId)){
                    // Get Related Event Type:Event List Map
                    Map<String, List<Event>> existMap = caseEventMap.get(caseEvent.WhatId);
                
                    // Check Event Type Exist
                    if(existMap.containsKey(caseEvent.Event_Type__c)){
                        List<Event> existingEventList = existMap.get(caseEvent.Event_Type__c);  
                        existingEventList.add(caseEvent);
                        existMap.put(caseEvent.Event_Type__c, existingEventList);
                    } else {
                        List<Event> newEventList = new List<Event>();
                        newEventList.add(caseEvent);
                        existMap.put(caseEvent.Event_Type__c, newEventList);
                    }
                    // Set The CaseId:Event Map
                    caseEventMap.put(caseEvent.WhatId, existMap);
                } else {        
                    // Create New String:Event List Map
                    Map<String, List<Event>> newMap = new Map<String, List<Event>>();
                    List<Event> newEventList = new List<Event>();
                    // Put The Event Data
                    newEventList.add(caseEvent);
                    newMap.put(caseEvent.Event_Type__c, newEventList);
                    caseEventMap.put(caseEvent.WhatId, newMap);
                }                         
            }
            String slaType='';
            // Automated SLA End On Case Closure (SLA-1 Closure)
            if('SLA1 - Initiated'.equalsignorecase(sCurSlaPhase)){
                newcase.Current_SLA_Phase__c = 'SLA1 - Ended';
                newcase.First_SLA_Response_Time__c = datetime.now();
                newCase.Customer_Response_Received__c = false; //DNR: added for SLA ends
                newCase.Last_Outreach_Time__c = System.now();
                caseOwnerIdSet.add(newCase.ownerId);
                if (!Social_StreamingUtil.CASE_REASON_COMPLETED.equalsIgnoreCase(newCase.Reason) && !newCase.Do_Not_Reassign__c) {
                        newCase.Prior_Care_Manager__c=newCase.ownerId; // Added to track change case Owner. 
                        newCase.ownerId = System.Label.PendingClouseQueueId;                        
                        if (!Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK.equalsIgnoreCase(newCase.Status)) {
                            newCase.Status = Social_StreamingUtil.CASE_STATUS_PENDINGCLOSURE;
                        }
                 } 
                slaType= 'SLA - 1';
            }
            // (SLA-2 Closure)
            else if('SLA2 - Initiated'.equalsignorecase(sCurSlaPhase)){
                newcase.Current_SLA_Phase__c = 'SLA2 - Ended';                     
                newcase.Second_SLA_Response_Time__c = datetime.now();
                newCase.Customer_Response_Received__c = false; //DNR: added for SLA ends
                newCase.Last_Outreach_Time__c = System.now();
                caseOwnerIdSet.add(newCase.ownerId);
                if (!Social_StreamingUtil.CASE_REASON_COMPLETED.equalsIgnoreCase(newCase.Reason) && !newCase.Do_Not_Reassign__c) {
                        newCase.Prior_Care_Manager__c=newCase.ownerId; // Added to track change case Owner. 
                        newCase.ownerId = System.Label.PendingClouseQueueId;                       
                        if (!Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK.equalsIgnoreCase(newCase.Status)) {
                            newCase.Status = Social_StreamingUtil.CASE_STATUS_PENDINGCLOSURE;
                        }
                 } 
                slaType= 'SLA - 2';
            }
            // (SLA-3 Closure)
            else if('SLA3 - Initiated'.equalsignorecase(sCurSlaPhase)){
                newcase.Current_SLA_Phase__c = 'SLA3 - Ended';                     
                newcase.Third_SLA_Response_Time__c = datetime.now();
                slaType= 'SLA - 3';
            }
            else if('SLA2 - Ended'.equalsignorecase(sCurSlaPhase) && newCase.Second_SLA_Response_Time__c!=null){                   
                newCase.Customer_Response_Received__c = false; //DNR: added for SLA2 ends and no events to be closed.
                newCase.Last_Outreach_Time__c = System.now();
                caseOwnerIdSet.add(newCase.ownerId);
                if (!Social_StreamingUtil.CASE_REASON_COMPLETED.equalsIgnoreCase(newCase.Reason) && !newCase.Do_Not_Reassign__c) {  // Added to send the case back to pending closure queue.
                        newCase.Prior_Care_Manager__c=newCase.ownerId; // Added to track change case Owner. 
                        newCase.ownerId = System.Label.PendingClouseQueueId;                        
                        if (!Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK.equalsIgnoreCase(newCase.Status)) {
                            newCase.Status = Social_StreamingUtil.CASE_STATUS_PENDINGCLOSURE;
                        }
                } 
             }
             //Logic to assign new case to care manager
             if (!caseOwnerIdSet.isEmpty()) {
                 Social_GroupMemberHandler.assignCasesToUserBulk(caseOwnerIdSet);
             }
          
            // Private Method For Event Closure
            closeSlaEvent(caseid,slaType);
        }
    }
    
   /**
    * < dbopmethod() - This Function is used to insert the database objects. 
    * @param: 
    *    
    * 
    * @return - Void.
    * @see - save()(Method same controller class)
    */ 

    private void dbopmethod(List<sObject> obj,string flag) {
        errorstring='';
        Database.SaveResult[] resultDB;
        if(obj.size()>0) {
            if('Update'.equalsignorecase(flag)){
                resultDB = database.update(obj, false);
            }
            if('Insert'.equalsignorecase(flag)){
                resultDB = database.insert(obj, false);
            }
            try {
                Integer loopCount = 0;
                for(Database.SaveResult sr:resultDB){               
                    if(!sr.isSuccess()){                  
                        Database.Error err = sr.getErrors()[0];
                        if('Update'.equalsignorecase(flag)){
                            errorString = errorstring+ 'Error while Updating. ' +obj.get(loopCount).getSObjectType() + ' ' + err + '\n';
                        } 
                        if('Insert'.equalsignorecase(flag)){
                            errorString = errorstring+ 'Error while Inserting. ' +obj.get(loopCount).getSObjectType() + ' ' + err + '\n';
                        }                      
                    }
                    loopCount++;
                }
                if(string.isnotblank(errorstring)){
                    CreateExceptionObject(errorString); 
                }               
            } catch(Exception e){
                System.debug('Error handling Response. ' + e.getMessage());
                CreateExceptionObject(e.getMessage());
            }
        }     
    }   

   /**
    * < ok() - Method used to pickup all the selected contact emails for the user email lookup page on the click of ok button.
    * @param: void .
    * 
    * @return - Void.
    * @see - Social_UserEmailLookup(Page)
    */ 
    public void ok() {
        Boolean first = true;
        for ( selectoption so : selectedContacts ) {
            if (!first){
                message += ';';
            }
            message += so.getvalue();
            first = false;
        }
        if(!string.isempty(message)){   
            addto=message;
        }
    }

   /**
    * < CreateExceptionObject() - Method used to create exception object during processing for debugging later.
    * @param: Exception message.
    * 
    * @return - Void.
    * @see - Same Class
    */ 
    
    public void CreateExceptionObject(string exceptionmessage) {
        String value='';
        List<EmailMessage__c> lemsg=new list<EmailMessage__c>(); 
        EmailMessage__c emsg=new EmailMessage__c();
        if(toAddress!= null) {
            Boolean seenOne= false;
            for(String to : toAddress) {
                if(seenOne) {
                    value += ';\n';
                }
                to  = caseinb.extractAddress(to);
                value += to;
                seenOne = true;
            }
        }
        emsg.To_Address__c= caseinb.limitLength(value,EmailMessage__C.To_Address__c.getDescribe().getLength());
        if(ccAddress!= null) {
            Boolean seenOne= false;
            value='';
            for(String to : ccAddress) {
                if(seenOne) {
                    value += ';\n';
                }
                to  = caseinb.extractAddress(to);
                value += to;
                seenOne = true;
            }
        }
        emsg.CC_Address__c= caseinb.limitLength(value,EmailMessage__C.CC_Address__c.getDescribe().getLength());
        emsg.From_Address_New__c= Label.From_Email_Address;
        emsg.Body__c=Body;
        emsg.Subject__c=subj;
        emsg.From_Name__c=Label.From_Email_Address;
        emsg.Status__c='FAILED';
        if(newcase!=null){
            emsg.Case__c=newcase.id;
        }
        if(newcase.contact.id!=null){
            emsg.Contact__c=newcase.contactid;
        }
        emsg.type__c='Outbound';
        emsg.Exception_Message__c=exceptionmessage;
        emsg.Message_Date__c=system.NOW();
        lemsg.add(emsg);
        if(lemsg.size()>0){ 
            dbopmethod(lemsg,'Insert');
        }
    } 
    
    /**
    * < populateescalationemails() - This method is used to populate all the emails related to the escalation related contacts.
    * @param: 
    * 
    * @return - Void.
    * @see - Same Class
    */  

    private void populateescalationemails(){
        try{
            List<contact> lcon = [select Department, id, all_contact_emails__c,name, email from contact where all_contact_emails__c!='' and Exception_Contact__c = true limit 250];// On April 1st 2014- increased the limit from 50 to 250
            Map<id,list<String>> lconemailmap= new map<id,list<string>>();
            Map<id,string> lconnamemap=new map<id,string>();
            allContacts = new List<SelectOption>();
            if(lcon.size()>0){
                for(Contact ct:lcon){
                    List<string> lstring=new list<string>();
                    if(!string.isblank(ct.all_contact_emails__c)){
                        lstring=ct.all_contact_emails__c.split(';',0);
                        if(!ct.all_contact_emails__c.contains(ct.email)){
                            lstring.add(ct.email);
                        }
                    } else {
                        if(!ct.all_contact_emails__c.contains(ct.email) && string.isnotblank(ct.email)){
                            lstring.add(ct.email);
                        }
                    }
                    if(lstring.size()>0){
                        if(!lconemailmap.containskey(ct.id)){
                            lconemailmap.put(ct.Id,lstring);
                            String departmentLookUp = ct.Department;
                            if(departmentLookUp != Null) {
                                lconnamemap.put(ct.Id,ct.Department + ' : ' + ct.name );
                            } else {
                                lconnamemap.put(ct.Id,ct.name);
                            }
                        }
                    }
                }    
                for(id cid:lconemailmap.keyset()){
                    for(string semail:lconemailmap.get(cid)){
                        allContacts.add(new SelectOption(semail,lconnamemap.get(cid)+' : '+ semail));
                    }
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There are no Escalation Contact Emails to select.'));
            }
        } catch(Exception e){
            CreateExceptionObject(e.getMessage());
        }
    }
}