/*** 
 * Class Name: CSC_CaseHistoryExtension
 * Author: Accenture
 * Date: 20-Feb-2015
 * Requirement/Project Name: Business/consumer Care
 * Requirement Description: Case Time line controller.
 * Release 15th July: ITS-1627,1651
**/

public class CSC_CaseHistoryExtension {
    public String filterId='All';
    public string strprofilename{get;set;}
    public map<id,id> msocpersonaid =new map<id,id>();
    public map<id,SocialPersona> mfinalpersonasocialpost=new map<id,SocialPersona>();
    public map<id,boolean> msocialpostcuspostexist= new map<id,boolean>();
    public Static set<String> traineeProfileSet = new set<String>();//Set to store profile name of trainee.
    public String bgColor{get;set;}
    /* Property value that controls the truncation of case comments */
    public boolean fullComments { get; private set; }
    private String replyLinkHTML;
    private String sopoLinkHTML;
    private String sopeepLinkHTML;
    private String sopoSuccess;
    private String sopoError;
    Public case mCase{get;set;}
    public boolean enableEmailLinkCaseTimeLine{get;set;}//For displaying links in case time line.
    public boolean enablePostLinkCaseTimeLine{get;set;}//For displaying links in case time line.
    public boolean enableReplyLink{get;set;}
    public boolean adminAcct = false;

    public boolean getAdminAcct() {
        return adminAcct;       
    }
    
    public CSC_CaseHistoryExtension(ApexPages.StandardController stdController) {
        if((Case)stdController.getRecord()!=null){
            mCase = (Case)stdController.getRecord();
        }
        enableEmailLinkCaseTimeLine = true;
        enablePostLinkCaseTimeLine =true;
        enableReplyLink = true;
        fullComments           = true;
        truncatedCommentLength = 175;
        bgColor = '';
        //If condition to avoid null pointer exception while creating manual case
        if (mCase.Id != Null) {
            //To enable reply to email and escalate via email links if case is closed or case is owned by a queue or contact email is null.
            //Aditya:Added condition check for non case owner
            if('Auto Closed'.equalsignorecase(mCase.Status) || 'Closed'.equalsignorecase(mCase.Status) || 'Closed As Spam'.equalsignorecase(mCase.Status) || '00G'.equalsignorecase(string.ValueOf(mCase.OwnerId).subString(0,3)) || mCase.Contact.Email == null || mCase.ContactId == Null || userInfo.getUserId() != mCase.ownerId) {
                enableEmailLinkCaseTimeLine = false;
            }
            if('Auto Closed'.equalsignorecase(mCase.Status) || 'Closed'.equalsignorecase(mCase.Status) || 'Closed As Spam'.equalsignorecase(mCase.Status) || '00G'.equalsignorecase(string.ValueOf(mCase.OwnerId).subString(0,3)) || userInfo.getUserId() != mCase.ownerId) {
                enablePostLinkCaseTimeLine = false;
            }
        }
        strProfileName = '';
        if(UserInfo.getProfileId()!=null && !UserInfo.getProfileId().equals('')){
            List<Profile> profileList = [Select Name from Profile where Id=: UserInfo.getProfileId() limit 1];
            if(profileList!=null && profileList.size()>0){
                strProfileName = profileList[0].name;
            }
        }
        if(strProfileName.contains('Business')){
            enableEmailLinkCaseTimeLine = false;
            enablePostLinkCaseTimeLine = false;    
        }
        if(ApexPages.currentPage().getparameters().get('attached') != null) {
            setCheckBoxAttachments(true);
        }
    }
    
    public CSC_CaseHistoryExtension() {  
        fullComments           = true;
        truncatedCommentLength = 175;
        bgColor = '';
    }
    
    /* Action method for toggling the fullComments property */
    public void toggleComments() { fullcomments = !fullcomments; }

    public PageReference updateActivity() {
        return null;
    }
    public boolean CheckBoxAttachments = true;
    public boolean CheckBoxComments = true; // On April 1st 2014, updated by Ramakrishna Yella from false to true
    public boolean CheckBoxEmail = true;
    public boolean CheckBoxEvents = false;
    public boolean CheckBoxHistory = false;
    public boolean CheckBoxSocial = true;
    public boolean CheckBoxSurveys = false;
    public boolean CheckBoxTasks = false;
    
    public boolean getCheckBoxAttachments() {
        return CheckBoxAttachments;
    }
    public boolean getCheckBoxComments() {
        return CheckBoxComments;
    }
    public boolean getCheckBoxEmail() {
        return CheckBoxEmail;
    }
    public boolean getCheckBoxEvents() {
        return CheckBoxEvents;
    }
    public boolean getCheckBoxHistory() {
        return CheckBoxHistory;
    }
    public boolean getCheckBoxSocial() {
        return CheckBoxSocial;
    }
    public boolean getCheckBoxSurveys() {
        return CheckBoxSurveys;
    }
    public boolean getCheckBoxTasks() {
        return CheckBoxTasks;
    }

    public void setCheckBoxAttachments(boolean ckboxattach) {
        this.CheckBoxAttachments = ckboxattach;
    }
    public void setCheckBoxComments(boolean ckboxcomments) {
        this.CheckBoxComments = ckboxcomments;
    }
    public void setCheckBoxEmail(boolean ckboxemail) {
        this.CheckBoxEmail = ckboxemail;
    }
    public void setCheckBoxEvents(boolean ckboxevents) {
        this.CheckBoxEvents = ckboxevents;
    }
    public void setCheckBoxHistory(boolean ckboxhist) {
        this.CheckBoxHistory = ckboxhist;
    }
    public void setCheckBoxSocial(boolean ckboxsoc) {
        this.CheckBoxSocial = ckboxsoc;
    }
    public void setCheckBoxSurveys(boolean ckboxsurv) {
        this.CheckBoxSurveys = ckboxsurv;
    }
    public void setCheckBoxTasks(boolean ckboxtasks) {
        this.CheckBoxTasks = ckboxtasks;
    }
    public void setCheckBoxAdmin(boolean ckboxsurv) {
        this.CheckBoxSurveys = ckboxsurv;
    }

    public Case getcase() {
        try{
            date dt=System.Today();
            if(cid == null) return new Case();
                String tmpQuery = 'SELECT casenumber,Status,OwnerId,Contact.Email,ContactId, Origin,';
                boolean prevQuery = false;
                if(CheckBoxSocial){ 
                    tmpQuery = tmpQuery + '(select id, parentId, Createdby.Name, CreatedDate, MediaProvider, Handle, Headline, Content, R6Service__PostTags__c, Posted, R6Service__Status__c, R6Service__StatusMessage__c, PostPriority, R6Service__SourceTags__c, R6Service__PostLink__c, MessageType, R6Service__IsOutbound__c, PostUrl, PersonaId,Name,Provider,IsOutbound,StatusMessage from Posts ORDER BY CreatedDate DESC Limit 199)';
                    prevQuery = true;                                
                } 
                if(CheckBoxComments){
                    if(prevQuery == true){ 
                        tmpQuery = tmpQuery + ', ';
                    }
                    tmpQuery = tmpQuery + '(SELECT id, CreatedBy.Name, CreatedDate, CommentBody,IsPublished FROM CaseComments ORDER BY CreatedDate DESC Limit 199)';   
                    prevQuery = true;
                } 
                if(CheckBoxAttachments){
                    if(prevQuery == true){ 
                        tmpQuery = tmpQuery + ', ';
                    }
                    tmpQuery = tmpQuery + '(SELECT id, CreatedBy.Name, CreatedDate, Name, BodyLength, Description FROM Attachments  ORDER BY CreatedDate DESC Limit 199)';   
                    prevQuery = true;
                } 
                if(CheckBoxHistory){
                    if(prevQuery == true){ 
                        tmpQuery = tmpQuery + ', ';
                    } 
                    tmpQuery = tmpQuery + '(SELECT id, CreatedBy.Name, CreatedDate, Field, NewValue, OldValue FROM Histories ORDER BY CreatedDate DESC, Id DESC Limit 199)';   
                    prevQuery = true;
                } 
                if(CheckBoxTasks && adminAcct){
                    if(prevQuery == true){ 
                        tmpQuery = tmpQuery + ', ';
                    }
                    tmpQuery = tmpQuery + '(SELECT id, Owner.Name, LastModifiedDate, Subject FROM Tasks WHERE ActivityDate <= :dt AND IsClosed = true ORDER BY LastModifiedDate DESC Limit 199)';   
                    prevQuery = true;
                } 
                if(CheckBoxEvents && adminAcct){
                    if(prevQuery == true){ 
                        tmpQuery = tmpQuery + ', ';
                    }
                    tmpQuery = tmpQuery + '(SELECT id, Owner.Name, ActivityDateTime, Subject FROM Events WHERE ActivityDateTime <= :dt ORDER BY ActivityDateTime DESC Limit 199)';   
                    prevQuery = true;
                } 
                if(CheckBoxSurveys){
                    if(prevQuery == true){ 
                        tmpQuery = tmpQuery + ', ';
                    }
                    tmpQuery = tmpQuery + '(SELECT id, Twitter_Failure_Reason__c, Twitter_Direct_Message_Sent__c, Survey_Expired__c, One_Time_Used__c, Email_Sent__c, CreatedDate, CreatedBy.Name, Email_Failure_Reason__c, URL_Sent_Date__c FROM Forsee_Surveys__r ORDER BY URL_Sent_Date__c DESC Limit 199)';   
                    prevQuery = true;
                 } 
                 if(CheckBoxEmail){
                     if(prevQuery == true){ 
                        tmpQuery = tmpQuery + ', ';
                     }
                     tmpQuery = tmpQuery + '(Select Id, CreatedBy.Name, CreatedDate, TextBody, HtmlBody, Subject, FromAddress, ToAddress, Incoming, Status, parentId, FromName, ReplyToEmailMessageId From EmailMessages ORDER BY CreatedDate DESC Limit 199)';   
                     prevQuery = true;
                 }
                 tmpQuery = tmpQuery + 'FROM case WHERE id = :cid';
                 if(tmpQuery!=null){
                     Case caseObj = DaTabase.query(tmpQuery);
                     return doProcessBulkCase(caseObj);
                 }
                 return null;
           } catch( QueryException e ) {
               System.debug( e.getMessage() );
               return new Case();
           }
     }
  
    /* The ID value of the case that will be used by the getCase() method to query for the related
       objects used to generate the ordered history collection. The value will be based on the request
       parameter, if available. */
    Private Id cid {
        get {
            if(ApexPages.currentPage().getparameters().get('id') != null) {
                cid = ApexPages.currentPage().getparameters().get('id');
            }
            return cid;
        }
        set {
            if(value != null) cid = value;
        }
    }
      
    /* This accessor provides the page with the ordered collection of history (apex) objects for display in the page.
       it also processes the truncation of case comments as specified by the fullComments property value.*/
    public CSC_History[] getHistories() {
        CSC_History[] histories = new CSC_History[]{};
        if(CheckBoxHistory) {
            for (CaseHistory ch:c.histories) {
                String tmpOldValue = ' ';
                if (ch.oldvalue != null) {
                    tmpOldValue = String.valueOf(ch.oldvalue);
                }
                if (!(tmpOldValue.startsWith('0') && tmpOldValue.length() > 1)) {
                    if (ch.field.equals('ownerAssignment')) {
                        addHistory(histories, new CSC_History(ch.id, ch.createdDate, ch.createdby.name, '<b>Case Assignment</b> from ' + String.valueOf(ch.oldvalue) + ' to <b>' + String.valueOf(ch.newvalue) + '</b>', replyLinkHTML, '',sopoSuccess, sopoError, false, false));
                    } else if (ch.field.equals('created') || ch.field.equals('closed')) {
                        addHistory(histories, new CSC_History(ch.id, ch.createdDate, ch.createdby.name, '<b>'+ch.field+' case</b>', replyLinkHTML, '',sopoSuccess, sopoError, false, false));
                    } else if (ch.field.equals('RecordType') && String.valueOf(ch.newvalue).equals('Consumer Care Case')) {
                        addHistory(histories, new CSC_History(ch.id, ch.createdDate, ch.createdby.name, '<b>opened case</b>', replyLinkHTML, '',sopoSuccess, sopoError, false, false));
                    } else if (ch.field.equals('RecordType') && String.valueOf(ch.newvalue).equals('Consumer Care Closed Case')) {
                        addHistory(histories, new CSC_History(ch.id, ch.createdDate, ch.createdby.name, '<b>closed case</b>', replyLinkHTML, '',sopoSuccess, sopoError, false, false));
                    } else if (ch.oldvalue == null || ch.oldvalue == '') {
                        addHistory(histories, new CSC_History(ch.id, ch.createdDate, ch.createdby.name, 'Set <b>' + ch.field + '</b> as <b>' + String.valueOf(ch.newvalue) + '</b>', replyLinkHTML, '',sopoSuccess, sopoError, false, false));
                    } else {
                        addHistory(histories, new CSC_History(ch.id, ch.createdDate, ch.createdby.name, 'Changed <b>' + ch.field + '</b> from ' + String.valueOf(ch.oldvalue) + ' to <b>' + String.valueOf(ch.newvalue) + '</b>', replyLinkHTML, '',sopoSuccess, sopoError, false, false));
                    }
                }
            }
        }
        if(CheckBoxComments){
            for (CaseComment comment:c.casecomments) {
                String casecomments = (comment.commentbody).replaceAll('<','(').replaceAll('>',')').replaceAll('\n','<br/>');
                addHistory(histories, new CSC_History(comment.id, comment.createdDate, comment.createdby.name, '<b>Comment:</b> ' + truncateValue(casecomments), replyLinkHTML, '',sopoSuccess, sopoError, false, false));
            }
        }
        if(CheckBoxEmail){
            List<Custom_Post__c> checkCustomPostExists = new List<Custom_Post__c>();
            Map<String, String> imageIdMap =  new Map<String, String>();
            List<EmailMessage> emailMessagesList = c.emailmessages;
            List<Id> emailMessageIdList = new List<Id>();
            String strTest = '';
            Map<String, Map<String, String>> replyToEmailMessageIdMap =  new Map<String, Map<String, String>>();
            Map<String, String> escalationContacts = getEscalationContacts();
            traineeProfileSet.addAll(Label.Trainee_Profile.split(';'));//Adding it to a set.
            if (!traineeProfileSet.isEmpty() && !strProfileName.equals('') && traineeProfileSet.Contains(strProfileName)) {
                checkCustomPostExists = [Select id from Custom_Post__c where Category__c = 'Email' and (Status__c = 'New' OR Status__c = 'Approved' OR Status__c = 'Rejected' OR Status__c = 'Sent For Approval') and Case__c =: mCase.Id];
            }
            for (EmailMessage email:c.emailmessages) {
                emailMessageIdList.add(email.parentId);
                if(email.ReplyToEmailMessageId!=null && !String.valueOf(email.ReplyToEmailMessageId).equals('') && email.ToAddress!=null && replyToEmailMessageIdMap!=null){
                    if(!replyToEmailMessageIdMap.isEmpty() && replyToEmailMessageIdMap.containsKey(email.ReplyToEmailMessageId)){
                        Map<String, String> emailAddressMapTemp = replyToEmailMessageIdMap.get(email.ReplyToEmailMessageId);
                        if(email.ToAddress!=null && (email.ToAddress).contains(',')){
                            for(String strEmailId: (email.ToAddress).split(',')){
                                emailAddressMapTemp.put(strEmailId, strEmailId);
                            }
                        } else {
                            emailAddressMapTemp.put(email.ToAddress, email.ToAddress);
                        }
                        replyToEmailMessageIdMap.put(email.ReplyToEmailMessageId, emailAddressMapTemp);
                    } else {
                        Map<String, String> emailAddressMap = new Map<String, String>();
                        if(email.ToAddress!=null && (email.ToAddress).contains(',')){
                            for(String strEmailId: (email.ToAddress).split(',')){
                                emailAddressMap.put(strEmailId, strEmailId);
                            }
                        } else {
                            emailAddressMap.put(email.ToAddress, email.ToAddress);
                        }                       
                        replyToEmailMessageIdMap.put(email.ReplyToEmailMessageId, emailAddressMap);
                    }
                }
            }
            strTest = strTest +' LLLLL' + emailMessageIdList.size();
            if(emailMessageIdList!=null && emailMessageIdList.size()>0){
                List<Attachment> attachmentList = [Select a.Name, a.Id From Attachment a where a.ParentId IN: emailMessageIdList];
                if(attachmentList!=null && attachmentList.size()>0){
                    for(Attachment attach: attachmentList){
                        imageIdMap.put(attach.Name, attach.id);
                    }
                }
            }
            for (EmailMessage email: c.emailmessages) {
                String strBody = '';
                sopoError = '';
                sopoSuccess = '';
                if(null != email.HtmlBody && !(email.HtmlBody).equals('')){
                    strBody = email.HtmlBody;
                    if(strBody != null && strBody.contains('<img') && strBody.contains('src="cid:')){
                        integer start = 0;
                        while (true) {
                            integer found = strBody.indexOf('src="cid:', start);
                            if (found != -1) {
                                String strTemp1 = strBody.subString(0, found);
                                String strTemp2 = strBody.subString(found, strBody.length());
                                String strTempToFormat = '', strTemp3 = '';
                                if(strTemp2!=null && strTemp2.contains('">')){
                                    strTempToFormat = strTemp2.subString(0, strTemp2.indexOf('">'));
                                    strTemp3 = strTemp2.subString(strTemp2.indexOf('">'), strTemp2.length());
                                }
                                if(strTempToFormat.contains('src="cid:') && strTempToFormat.contains('@')){
                                    String strImageName = strTempToFormat.subString(Integer.ValueOf(strTempToFormat.indexOf(':')) + 1 , strTempToFormat.indexOf('@'));
                                    strTest = strTest+' ????? Entered '+imageIdMap.get(strImageName);
                                    if(imageIdMap != null && !imageIdMap.IsEmpty() && imageIdMap.containsKey(strImageName)){
                                        strTest = strTemp1 + ' src="/servlet/servlet.FileDownload?file='+imageIdMap.get(strImageName)+' '+ strTemp3;
                                        strBody = strTest;
                                    }
                                }
                            }
                            if (found == -1) break;
                            start = found + 2;
                        }
                    }
                } else if(null!=email.TextBody && !(email.TextBody).equals('')) {
                    strBody = email.TextBody;
                    strBody = strBody.replaceAll('<','(').replaceAll('>',')').replaceAll('\n','<br/>');
                }
                String strToDisplay = '', strFromName = '', strFromEmailAddress, strToName = '';
                if(email.FromName!=null && !(email.FromName).equals('')){
                    strFromName = email.FromName; 
                    strFromEmailAddress = '('+email.FromAddress+')';
                } else if(email.FromAddress!=null){
                    strFromEmailAddress = '('+email.FromAddress+')'; 
                }
                if(email.ToAddress!=null && !(email.ToAddress).equals('')){
                    strToName = email.ToAddress;
                }
                sopoSuccess = ''; sopoError = '';
                //Loop to find if email has an escalated or Replied email
                if(email.id!=null && replyToEmailMessageIdMap!=null && !replyToEmailMessageIdMap.isEmpty() && replyToEmailMessageIdMap.containsKey(email.id)){
                    //Entering this loop means the email has either an Escalated or Replied Email
                    Map<String, String> emailIdsMap = replyToEmailMessageIdMap.get(email.id);
                    Set<String> emailIdSet = emailIdsMap.keySet();
                    if(escalationContacts!=null && !escalationContacts.isEmpty() && emailIdSet!=null && emailIdSet.size()>0){
                        Map<String, String> innerMap = replyToEmailMessageIdMap.get(email.id);
                        sopoSuccess = '';
                        for(String strEmailId: emailIdSet){
                            if(escalationContacts.containsKey(strEmailId) && innerMap!=null && !innerMap.isEmpty() && innerMap.containsKey(strEmailId)){
                                sopoSuccess = 'Escalated';
                            }
                        }
                    }
                    if(emailIdsMap!=null && !emailIdsMap.isEmpty() && email.ToAddress!=null && emailIdsMap.containsKey(email.FromAddress)){
                        sopoError = 'Replied';
                    }
                }
                String strEscalationLink = '', strSubject = '';
                strToDisplay = '';
                replyLinkHTML = '';
                //logic to check if the incoming email is from escalation contact then dont display reply to last email & escalate via email links
                if (escalationContacts.containsKey(email.ToAddress)) {
                    if(email.ToAddress !=null && email.Id !=null) {
                        if ((email.toAddress).contains(';')) {
                            for(String strToEmailAddress: (email.toAddress).split(';')){
                                if(strToEmailAddress!=null && escalationContacts.containsKey(strToEmailAddress) ) {
                                    bgColor = '#FFA319';
                                    if(email.incoming) {// Enable escalation link only on incoming emails, email.incoming
                                        strEscalationLink = 'Reply to Escalated Email';
                                    }
                                    strToName =  '<b>From <font color = "#E60000">'+ email.FromAddress +'</font></b>';
                                    strToDisplay = '<b>Email To SLAM <font color = "#E60000">('+email.ToAddress+')</font></b>';
                                }
                            }
                        } else if(!(email.ToAddress).contains(';')) {
                            if(email.incoming) {// Enable escalation link only on incoming emails
                                strEscalationLink = 'Reply to Escalated Email';
                            } 
                            strToName =  '<b>From <font color = "#E60000">'+ email.FromAddress +'</font></b>';
                            strToDisplay = '<b>Email To SLAM <font color = "#E60000">('+email.ToAddress+')</font></b>';
                        }
                    }
                } else if(escalationContacts.containsKey(email.FromAddress) && email.incoming){
                    strEscalationLink = 'Reply to Escalated Email';
                    strToDisplay = '<b>Email From SLAM <font color = "#E60000">('+email.FromAddress+')</font></b>';
                    strToName =  '<b>To <font color = "#E60000">'+ email.ToAddress +'</font></b>';
                } else {
                    if(email.incoming) {// Enable escalation link only on incoming emails
                        if (!traineeProfileSet.isEmpty() && !strProfileName.equals('') && traineeProfileSet.Contains(strProfileName)) {
                            if (checkCustomPostExists.isEmpty()) {
                                replyLinkHTML = 'Submit Email for Approval';
                            }
                        } else {
                            replyLinkHTML = 'Reply to Email';
                        }
                        strEscalationLink = 'Escalate via Email';
                    }
                    strToDisplay = '<b>Email from <font color = "#E60000">'+strFromEmailAddress+'</font></b>';
                    strToName =  '<b>To <font color = "#E60000">'+ email.ToAddress +'</font></b>';   
                }
                if(email.Subject!=null && !(email.Subject).equals('')) {
                    strSubject = email.Subject;
                    //logic to remove null from subject if body is empty.
                    if(strSubject.contains('null') && strSubject.endsWith('null')) {
                        strSubject = strSubject.replace('null',' ');
                    }
                }
                if(fullComments){
                    addHistory(histories, new CSC_History(email.id, email.createdDate, email.createdby.name, strToDisplay + '<br/>' +strToName + '<br/>'+'<b>Subject:</b> ' + strSubject + '<br/></br>'+strBody , replyLinkHTML, strEscalationLink, sopoSuccess, sopoError, false, false));
                } else if(!fullComments) {
                    addHistory(histories, new CSC_History(email.id, email.createdDate, email.createdby.name, strToDisplay + '<br/>' +strToName + '<br/>'+'<b>Subject:</b> ' + strSubject, replyLinkHTML, strEscalationLink, sopoSuccess, sopoError, false, false));
                    
                }
                strEscalationLink = ''; strSubject = '';
                strToDisplay = '';
                replyLinkHTML = '';
                sopoError = '';
                sopoSuccess = '';
            }
        }
        if(CheckBoxSocial){
            for (SocialPost sopos:c.posts){
                msocpersonaid.put(sopos.id,sopos.PersonaId);
            }
            list<SocialPersona> lsocperson= new list<SocialPersona>();
            lsocperson= [SELECT Id, IsFollowingUs, ExternalPictureURL, AreWeFollowing, Name, RealName, ProfileUrl, R6Service__Avatar__c FROM SocialPersona WHERE id in :msocpersonaid.values()];
            List<Custom_Post__c> customPostList = [Select id,social_post__r.id from Custom_Post__c where (category__c = 'Twitter' OR category__c = 'Facebook') and Social_Post__c in :msocpersonaid.keyset() and status__c <> 'Sent' ];                        
            if(customPostList.size()>0) {
                for(id loopid:msocpersonaid.keyset()) {
                    for(Custom_Post__c custpost:customPostList) {
                        if(custpost.social_post__r.id == loopid) {
                             msocialpostcuspostexist.put(loopid,false);
                        }
                    }
                }             
            } 
            for(socialpersona lsocpers:lsocperson) {
                for(id loopid:msocpersonaid.keyset()) {
                    if(lsocpers.id == msocpersonaid.get(loopid)) {
                        mfinalpersonasocialpost.put(loopid,lsocpers);
                    }
                }
            }                                                                        
            for (SocialPost sopos:c.posts){
                String tmpHandle;
                String sopoResponse;
                String tmpMediaResourceURL;
                String strEscalationLink = '';
                /* Check if *Twitter, Facebook or Other */
                if(sopos.Provider !=null && (sopos.Provider).equalsIgnoreCase('Twitter')) {
                    /* Is Tweet Outbound? */
                    if(sopos.IsOutbound == true) {
                        replyLinkHTML = '';
                        if(sopos.StatusMessage != null) {
                            if('sent'.equalsIgnoreCase(sopos.StatusMessage)) {   //updated to fix case ignore issue. 
                                    sopoResponse = 'ShowSuccess';
                                    sopoSuccess =  sopos.StatusMessage;
                                } else {
                                    sopoResponse = 'ShowError';
                                    sopoError =  sopos.StatusMessage;
                                }                                   
                            } 
                    } else {
                        /*
                            Revantha C: Code added to redirect the new Trainee Care managers to the custum VF page
                        */
                        boolean customPostExists = true;
                        if(sopos.id!=null){
                            if(msocialpostcuspostexist.containskey(sopos.id)) {
                                customPostExists= msocialpostcuspostexist.get(sopos.id);
                            }                    
                        }
                        String customLabelTraineeProfile = Label.Trainee_Profile;//Getting all the profile names mentioned in custom label.
                        traineeProfileSet.addAll(customLabelTraineeProfile.split(';'));//Adding it to a set.
                        if(!traineeProfileSet.isEmpty() && !strProfileName.equals('') && traineeProfileSet.Contains(strProfileName)){
                            //Aditya: Code to disable link for all social posts in case time line if there is even one post pending in approval.
                            if (msocialpostcuspostexist.KeySet().isEmpty()) {
                                replyLinkHTML = 'Submit a Post for Approval';
                                strEscalationLink = 'Escalate via Email';
                            } else {
                                replyLinkHTML = '';
                                strEscalationLink = 'Escalate via Email';
                            }
                        }
                        else{
                            replyLinkHTML = '';
                            strEscalationLink = 'Escalate via Email';
                        }
                        if(sopos.R6Service__Status__c != null) {
                            /* If there is a status, it was replied. Check the Status */
                            if((sopos.R6Service__Status__c.equals('REPLIED'))) {
                                sopoResponse = 'ShowSuccess';
                                sopoSuccess =  sopos.R6Service__StatusMessage__c;
                            } else {
                                sopoResponse = 'ShowError';
                                sopoError = sopos.R6Service__StatusMessage__c;
                            }
                        } else {
                            /* No reply. Show Post a Reply */
                            sopoResponse = 'ShowReply';
                        }
             }
            /* Check if *Twitter, Facebook or Other */
            } else if(sopos.Provider!=null && (sopos.Provider).equalsIgnoreCase('Facebook')) {
                /* Is Facebook Msg Outbound? */
                if(sopos.IsOutbound == true) {
                    replyLinkHTML = '';
                    tmpHandle = 'Facebook (by ' +sopos.createdby.name+')'; 
                    /* Success? */
                    if(sopos.StatusMessage != null) {
                          if(('sent'.equalsIgnoreCase(sopos.StatusMessage))) {    // fixed to remove error message while replying to a tweet.
                            sopoResponse = 'ShowSuccess';
                            sopoSuccess =  sopos.StatusMessage;
                        } else {
                            sopoResponse = 'ShowError';
                            sopoError =  sopos.StatusMessage;
                        }                                   
                    } 
                } else {
                    /*
                        Revantha C: Code added to redirect the new Trainee Care managers to the custum VF page
                     */
                    boolean customPostExists = true;
                    if(sopos.id!=null){
                        if(msocialpostcuspostexist.containskey(sopos.id)){
                            customPostExists= true;
                        } else {
                            customPostExists = false;
                        }                  
                    }
                    String customLabelTraineeProfile = Label.Trainee_Profile;//Getting all the profile names mentioned in custom label.
                    traineeProfileSet.addAll(customLabelTraineeProfile.split(';'));//Adding it to a set.
                    if(!traineeProfileSet.isEmpty() && !strProfileName.equals('') && traineeProfileSet.Contains(strProfileName)){
                        //Aditya: Code to disable link for all social posts in case time line if there is even one post pending in approval.
                        if (msocialpostcuspostexist.KeySet().isEmpty()) {
                            replyLinkHTML = 'Submit a Post for Approval';
                            strEscalationLink = 'Escalate via Email';
                        } else {
                            replyLinkHTML  = '';
                            strEscalationLink = 'Escalate via Email';
                        }
                    } else {
                        //replyLinkHTML = ' <a href="'+System.Label.r_url+'/apex/facebookmessageentryform?postId=' + sopos.id + '" target="_parent" style="font-weight:bold;color:blue">Reply to this Post</a> ';
                        strEscalationLink = 'Escalate via Email';
                    
                    }
                    /* Is Inbound */
                    if(sopos.Handle != null) {
                        tmpHandle = sopos.Handle;
                        /* No Reply? */
                        if(sopos.R6Service__Status__c != null) {
                        /* If there is a status, it was replied. Check the Status */
                            if((sopos.R6Service__Status__c.equals('REPLIED'))) {
                                sopoResponse = 'ShowSuccess';
                                sopoSuccess =  sopos.R6Service__StatusMessage__c;
                            } else {
                                sopoResponse = 'ShowError';
                                 sopoError =  sopos.R6Service__StatusMessage__c;
                            }
                        } else {
                            /* No reply. Show Post a Reply */
                            sopoResponse = 'ShowReply';
                        }
                    } else { 
                        tmpHandle = ' Error CHE-5: Handle or Created By Name is null '; 
                        /* No Reply? */
                        if(sopos.R6Service__Status__c != null) {
                        /* If there is a status, it was replied. Check the Status */
                            if((sopos.R6Service__Status__c.equals('REPLIED'))) {
                                sopoResponse = 'ShowSuccess';
                                sopoSuccess =  sopos.R6Service__StatusMessage__c;
                            } else {
                                sopoResponse = 'ShowError';
                                sopoError =  sopos.R6Service__StatusMessage__c;
                            }
                        } else {
                            /* No reply. Show Post a Reply */
                            sopoResponse = 'ShowReply';
                        }
                    }
                }
            } else {
                tmpHandle = sopos.createdby.name;
                sopoResponse = ' ';
            }
            String postPriority ='';
            String posttg = '';
            String srctg ='';
            sopoLinkHTML = ' <a href="'+System.Label.r_url+'/' + sopos.Id + '" target="_parent" style="font-weight:bold;">Social Post</a> ';
            if(sopos.R6Service__IsOutbound__c){
                sopeepLinkHTML = '';
            } else {
                sopeepLinkHTML = sopos.PersonaId;
                postPriority = sopos.PostPriority;
                srctg = sopos.R6Service__SourceTags__c;
                if (sopos.R6Service__PostTags__c != null){
                    posttg = 'Post Tags ('+sopos.R6Service__PostTags__c+') ';
                }
            }
            SocialPersona sp=new SocialPersona();
            if(mfinalpersonasocialpost.containskey(sopos.id)) {
                sp=mfinalpersonasocialpost.get(sopos.id);
            } else {
                sp=new SocialPersona();
            }
            CSC_SocialPost tmpSP  = new CSC_SocialPost(sopos.Id, postPriority, sopos.MessageType, srctg, posttg, sopos.Provider, sopos.Posted, sopos.PostUrl, sopos.Name, sopos.Content, sp, sopoLinkHTML, sopeepLinkHTML);
            addHistory(histories, new CSC_History(sopos.id, sopos.createdDate, tmpHandle, sopoResponse, replyLinkHTML, strEscalationLink, sopoSuccess, sopoError, false, true, tmpSP));
        }
        }
        if(CheckBoxEvents) {
            for (Event e:c.events) {
                addHistory(histories, new CSC_History(e.id, e.activitydatetime, e.owner.name, '<b>Event:</b> ' + e.subject, replyLinkHTML, '', sopoSuccess, sopoError, false, false));
            }
        }
        if(CheckBoxSurveys) {
            for (Forsee_Survey__c fs:c.Forsee_Surveys__r) {
                String cType = '';
                boolean dType = false;
                boolean eType = false;
                String sentResponse = '';
                boolean dResponse = false;
                boolean eResponse = false;
                String sopoError= '';
                String replyLinkHTML = '';
                String sopoSuccess = '';
                String dynaTxt = '';
                /*DM SUCCESS*/
                if(fs.Twitter_Direct_Message_Sent__c == true){
                    cType = 'Twitter DM ';
                    dType = true;
                    sentResponse = '<span style="color:green">DM Sent</span>';
                    dResponse = true;
                /*DM FAILURE*/
                } else if(fs.Twitter_Failure_Reason__c != null && fs.Twitter_Failure_Reason__c != ''){
                    sentResponse = '<span style="color:orange"><b>DM Failed:</b></span><span style="font-size:x-small"> ' + fs.Twitter_Failure_Reason__c + '</span>';
                    cType = 'Twitter DM ';
                    dType = true;
                    dResponse = true;
                } else if(fs.Twitter_Direct_Message_Sent__c == false && (fs.Twitter_Failure_Reason__c == '' || fs.Twitter_Failure_Reason__c != '')) {
                    dType = false;
                    dResponse = false;
                }
                /*EMAIL SUCCESS*/
                if(fs.Email_Sent__c == true){
                    /*IF DM too*/
                    if(dType == true){
                        cType = cType + ' / Email';
                        eType = true;
                        sentResponse = sentResponse + ' / <span style="color:green">Email Sent</span>';
                    }else{
                        cType = 'Email';
                        eType = true;
                        sentResponse = '<span style="font-weight:bold;color:green">Email Sent</span>';
                    }
                    
                /*EMAIL FAILURE*/
                } else if(fs.Email_Failure_Reason__c != null && fs.Email_Failure_Reason__c != ''){
                    /*IF DM too*/
                    if(dType = true){
                        cType = cType + ' / Email';
                        eType = true;
                        sentResponse = sentResponse + ' / <span style="color:orange"><b>Email Send Failed:</b></span><span style="font-size:x-small"> ' + fs.Email_Failure_Reason__c + '</span>';
                    }else{
                        cType = cType + 'Email';
                        eType = true;
                        sentResponse = '<span style="color:orange"><b>Email Send Failed:</b></span><span style="font-size:x-small"> ' + fs.Email_Failure_Reason__c + '</span>';
                    }
                 } else if(fs.Email_Sent__c == false && fs.Email_Failure_Reason__c == '') {
                    dType = false;
                    dResponse = false;
                }
                /*OVERALL SEND SUCCESS*/
                if (fs.URL_Sent_Date__c != null) {
                    dynaTxt = '<br/><span style="font-size:x-small;font-weight:bold">Sent on ' + (fs.URL_Sent_Date__c).format('MMM d, yyyy hh:mm a') + ' </span> ';
                    dynaTxt += '<span style="font-size:x-small"><u>Customer Viewed?</u> ' + fs.One_Time_Used__c + ' </span> ' ;
                    dynaTxt += '<span style="font-size:x-small"><u>Link Expired?</u>' + fs.Survey_Expired__c + ' </span>' ;
                    dynaTxt += ' &nbsp; <a href="'+System.Label.r_url+'/' + fs.id + '" target="_parent" style="font-weight:bold;font-size:x-small">ForeSee Survey Detail</a> ';
                } else {
                    dynaTxt = '<br/><a href="'+System.Label.r_url+'/' + fs.id + '" target="_parent" style="font-weight:bold;font-size:x-small">ForeSee Survey Detail</a> ';
                }
                addHistory(histories, new CSC_History(fs.id, fs.CreatedDate, cType +' (via '+fs.CreatedBy.Name+')', '<b>ForeSee Survey - '+ cType + '</b> - ' + sentResponse + dynaTxt + '<br />' + replyLinkHTML, replyLinkHTML, '', sopoSuccess, sopoError, false, false));
            }
        }
        if(CheckBoxTasks) {
            for (Task t:c.tasks) {            
                addHistory(histories, new CSC_History(t.id, t.lastmodifieddate, t.owner.name, '<b>Task:</b> ' + t.subject, replyLinkHTML, '', sopoSuccess, sopoError, false, false));
            }
        }
        if(CheckBoxAttachments) {
            for (Attachment a:c.attachments) {
                String tmpDesc;
                if(a.Description != null)
                    tmpDesc = a.Description;
                else
                    tmpDesc = ' ';
                
                addHistory(histories, new CSC_History(a.id, a.createdDate, a.createdby.name, '<b>Attachment:</b> <a href="/servlet/servlet.FileDownload?file=' + a.id + '" target="_new">'+ a.name +'</a> (' + a.BodyLength + ' KB) ' +tmpDesc, replyLinkHTML, '', sopoSuccess, sopoError, true, false));
            }
        }
        return histories;
    }

    
    /* This method adds the newHistory object to the given histories collection in the appropriate order.
       The order provided here places the oldest records at the front of the list, i.e. by date ascending. */
    private void addHistory(CSC_History[] histories, CSC_History newHistory) {
        Integer position = histories.size();
        for (Integer i = 0; i < histories.size(); i++) {
            if (newHistory.historydt > histories[i].historydt) {
                position = i;
                break;
            }
        }
        if (position == histories.size()) {
            histories.add(newHistory);
        } else {
            histories.add(position, newHistory);
        }
    }
    
    private Map<String, String> getEscalationContacts(){
        Map<String, String> escalationContactMap =  new Map<String, String>();
        List<Contact> escalationContactList = [Select c.id, c.Email, c.All_Contact_Emails__c From Contact c where c.IsDeleted = false and c.Exception_Contact__c = true];
        if(escalationContactList!=null && escalationContactList.size()>0){
            for(Contact c: escalationContactList){
                if(c.Id!=null && c.Email!=null){
                    escalationContactMap.put(c.Email, c.Id);
                }
                if(c.Id!=null && c.All_Contact_Emails__c!=null && !(c.All_Contact_Emails__c).equals('')){
                    if((c.All_Contact_Emails__c).contains(';')){
                        for(String strEmailId: (c.All_Contact_Emails__c).split(';')){
                            escalationContactMap.put(strEmailId, c.Id);
                        }
                    } else {
                        escalationContactMap.put(c.All_Contact_Emails__c, c.Id);
                    }
                }
            }
        }
        return escalationContactMap;
    }
    
    /* The case object set by the getCase method and used by the getHistories method to acquire
       the related records.  */
       
    private Case c {
        get { return getCase(); }
        set;
    }
        
    /* Returns the truncated string value if that is specified in the current state (!fullComments)
        and the current length is greater than the value of the private truncatedCommentLength property. */
    private String truncateValue(String s) {
        if (!fullComments && s.length() > truncatedCommentLength) {
            s = s.substring(0,truncatedCommentLength) + '...';
        }
        return s;
    }

    /* The length of "Short Comments" which is used by the truncateValue method in this class to
       truncate case comments when specified by the user. */
    private Integer truncatedCommentLength { get; set; }
 
    //method to process the case object
    private Case doProcessBulkCase(Case caseObj) {
        Integer count=0;
        for (EmailMessage emailMsg : caseObj.emailMessages) {
            count++;
        }
        return caseObj;
    }
}