/**************************************************************************
Class Name:  Social_CaseEmailInBoundUtilities
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: This class is used to carry out all the processing logic for the
             Custom email to case Functionality DEC-2013.
Version History: Aditya(14/March/2014) - Release 19March2014, added fix for not appending escalated email id to all contact list.
Version History: Aditya(05/May/2014) - Fixing Null pointer exception when email is send with blank/null subject.
Version History: Aditya(14/May/2014) - Fixing 151 DML statement exception issue.
Version History: Aditya(16/May/2014) - Adding recordType check in queries.
                                       Added new boolean flag which will stop execution of triggers on case object.
Version History: Abhishek(01/aug/2014) - Adding SLA2 End Reassignment to reassign the case after SLA2End.
Version History: Aditya(21/10/2014) - Adding Case Assigned Time Field update
Version History: Haemen(21/10/2015) - Blanking out Case reassign time when case moves to Originating Queue
**************************************************************************************************************************/
global with sharing class Social_CaseEmailInBoundUtilities {
    protected Case theCase = null;// this is the main case string
    protected casecomment thecasecomment =null;// this is the case comment object
    protected Contact theContact = null;// this is the contact object
    protected String defaultCaseOwnerId;//this is used to store the default case owner id
    private Static Boolean TRACE = true;
    public boolean commentflag{get;set;}// this is flag used to specifiy if a comment should be inserted or not.
    public List<string> sCommentbody=new list<string>();
    public list<Group> lgroup{get;set;}
    Public List<casecomment> lcasecomment=new list<casecomment>();
    public string errorstring;// this stores the error strings which maybe caused during DB operations.
    public List<case> lrecase=new List<case>();
    public Messaging.InboundEmail email2;
    public boolean reopenflag{get;set;}
    public boolean updateflag{get;set;}
    private AssignmentRule AR = new AssignmentRule();
    Social_slaEventHandler eventhandler=new Social_slaEventHandler();
    public static final Set<Id> idProcessed = new Set<Id>();
    public static final Set<Id> updateProcessed = new Set<Id>();
    public static final Set<Id> queueInsert = new Set<Id>();
    public static final Set<Id> queueUpdate = new Set<Id>();
    public static final Set<Id> foreseeUpdate = new Set<Id>();
    Public Static set<String> recordTypeIdSet = new Set<String>();
    public string caseOwnerId; 
    Public boolean SLA2EndReaasign=false;  //Boolean flag which will be true if a case is reassign after SLA2 Ends. 8/6/2014 release
    Public boolean isOwnerOfficeVacation; //Boolean flag which will be set to false if case owner is offline/Vacation.
    Public Static string userIdString=''; // String to store user id to verify if it is a queue or user
   /**
    * < Social_CaseEmailInBoundUtilities() - Constructor>
    * @param:
    *       
    * @return - void
    * @see - Social_CaseEmailInBoundUtilities (Class)
    */
 
    public Social_CaseEmailInBoundUtilities() {
        commentflag=false;
        reopenflag=false;
        updateflag=false;
        isOwnerOfficeVacation = true;
        recordTypeIdSet.addAll(Label.Consumer_RT.split(','));
        Social_StreamingUtil.doNtFireEmail2CaseRun = false; //do not fire case contact and user trigger
    }

   /**
    * < processInboundEmail() - method which reads the email message and carries out the contact creation/updation and case creation/updation logic>
    * @param:
    *     Messaging.InboundEmail email - Inbound Email.
    *
    * @return - Inbound Email Result
    * @see - Social_CaseEmailInBoundUtilities (Class)
    */

    public Messaging.InboundEmailResult processInboundEmail(Messaging.InboundEmail email) {
        Set<Id> contactIdSet = new Set<Id>();
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        datetime dt=system.now()-2;
        email2 = email;
        result.success=true;
        List<contact> lcon=new list<contact>();
        try {
            String emailSubject = email.subject;
            if (emailSubject == null) {
                emailSubject = '';
            }  
            String caseNumber = extractRef(emailSubject);
            String fromaddress = email.fromaddress;
            if(caseNumber != null){
                this.theCase = locateByCaseNumberAsString(caseNumber);
                                if(this.theCase == null) { 
                                System.debug(Logginglevel.ERROR,'CaseEmailInBoundUtilities.  Create a new case.  Could not find case number: "' + caseNumber + '"'); 
                } else {
                    emailnamedescriptionupd(this.thecase);
                    if(('Closed'.equalsignorecase(theCase.status)|| 'Auto Closed'.equalsignorecase(theCase.status)) && Social_SocialPostSCSHandler.caseReopenCheck(this.thecase)){
                        reopenflag=true;
                    } else if (('Closed'.equalsignorecase(theCase.status)|| 'Auto Closed'.equalsignorecase(theCase.status)) && !Social_SocialPostSCSHandler.caseReopenCheck(this.thecase)){
                        this.theCase = null;
                    }
                    if(!string.isblank(this.thecase.contactid)){
                        list<contact> lContact=[select id,name,Email,Last_Email_Used__c,All_Contact_Emails__c from contact where id=:this.thecase.contactid order by lastmodifieddate desc];
                        this.thecontact = lContact[0]; 
                        updatecontactaddress(this.thecontact.id,fromaddress);                        
                    }  
                }
            }
            String frmaddr='';
            if(fromaddress!=null && !string.isblank(fromaddress)){
                frmaddr='%'+fromaddress+'%';
            }
            list<contact> lContact = [select id,name,Email,Last_Email_Used__c,All_Contact_Emails__c from contact where (All_Contact_Emails__c like :frmaddr or email=:fromaddress) order by lastmodifieddate desc];
            if(lContact.size()>0){
                this.thecontact = lContact[0];
            }
            
            boolean allowmultipleemailCases = true;
            if(fromaddress!=null && !(fromaddress).equals('')){
                String strFromAddressDomain = fromaddress.subString(fromaddress.indexOf('@'), fromaddress.length());
                String strDomainAddress = Label.Multiple_Case_Domain;
                if(strDomainAddress.contains(strFromAddressDomain)){
                    allowmultipleemailCases = false;
                }
            }
            if(this.theCase == null && fromaddress!=null) {           
                if(lContact.size()>1) {
                    commentflag=true;
                    this.thecontact = lContact[0];
                    updatecontactaddress(lContact[0].id,fromaddress);
                    sCommentbody.add('The Incoming Email has multiple contacts associated with it.Creating Case for the most recently Modified Contact');
                    list<case> lcase=[select Id,status,Business_Case_Post_Tag__c,Auto_Reassignment_Tag__c,Reassignment_Reason__c,Case_Post_Tag__c,Case_PostTag__c,CaseNumber,Second_SLA_Response_Time__c,Subject,Current_SLA_Phase__c,Description,closeddate,SuppliedEmail,Suppliedname,lastmodifieddate,case.contact.Last_Email_Used__c,case.contactid,ownerid,Track_Case_Queue__c,recordtypeid,Do_Not_Reassign__c from case where Case.contact.id=:lcontact[0].id and (status !='Closed' and status != 'Auto Closed' ) and recordTypeId IN:recordTypeIdSet order by createddate desc];
                    if(lcase.size()>1 && allowmultipleemailCases) {
                        this.thecase=lcase[0];
                        commentflag=true;
                        emailnamedescriptionupd(this.thecase);
                        sCommentbody.add('The Incoming Email has multiple open cases.Attaching the email with most recently Modified Open Case');
                    } else {
                        if(lcase.size()==1 && allowmultipleemailCases) { 
                            this.thecase=lcase[0];
                        }
                        if(lcase.size()==0) { 
                            list<case> lcaseclosed=[select Id,Business_Case_Post_Tag__c,Auto_Reassignment_Tag__c,Reassignment_Reason__c,Case_Post_Tag__c,Case_PostTag__c,CaseNumber,Second_SLA_Response_Time__c,Subject,Current_SLA_Phase__c,Description,status,closeddate,Customer_Response_Received_Time__c,SuppliedEmail,Suppliedname,lastmodifieddate,case.contact.Last_Email_Used__c,case.contactid,ownerid,Track_Case_Queue__c,recordtypeid,Do_Not_Reassign__c from case where Case.contact.id=:lcontact[0].id and (status ='Closed' OR status='Auto Closed')and recordTypeId IN:recordTypeIdSet order by closeddate desc];
                            if(lcaseclosed.size()>1 && allowmultipleemailCases && Social_SocialPostSCSHandler.caseReopenCheck(lcaseclosed[0])) {
                                this.thecase=lcaseclosed[0];
                                commentflag=true;
                                reopenflag=true;
                                emailnamedescriptionupd(this.thecase);
                                sCommentbody.add('The Incoming Email has multiple cases Closed in the last 24 hrs.Attaching the email with most recently Closed Case');
                            }
                            if(lcaseclosed.size()==1 && allowmultipleemailCases && Social_SocialPostSCSHandler.caseReopenCheck(lcaseclosed[0])) { 
                                this.thecase=lcaseclosed[0];
                                emailnamedescriptionupd(this.thecase);
                                reopenflag=true;
                            }
                        }            
                    }
                }
                if(null==lContact || lContact.size()==0){
                    this.thecontact = new Contact();
                    thecontact.Email = email.fromAddress;
                    thecontact.Last_Email_Used__c= email.fromAddress;
                    thecontact.All_Contact_Emails__c=email.fromAddress;
                    if(!string.isblank(email.fromname)) {
                        if(email.fromname.indexOf(' ')!=0 && email.fromname.indexOf(' ')>0) {
                            thecontact.FirstName = email.fromname.substring(0,email.fromname.indexOf(' '));
                            thecontact.LastName = email.fromname.substring(email.fromname.indexOf(' ')+1);           
                        } else {
                            thecontact.FirstName = '';
                            thecontact.LastName = email.fromname;
                        }           
                    } else {       
                        string chardot = '.';
                        string charat='@';
                        integer indexat=email.fromAddress.lastIndexOfIgnoreCase(charat);
                        integer indexdot=email.fromAddress.lastIndexOfIgnoreCase(chardot,indexat);
                        if(indexdot>0) {
                            thecontact.FirstName=email.fromAddress.substring(0,indexdot);
                            thecontact.LastName=email.fromAddress.substring(indexdot+1,indexat);
                        } else {
                            thecontact.FirstName=email.fromAddress.substring(0,indexat);
                            thecontact.LastName=email.fromAddress.substring(0,indexat);
                        }
                    }
                    lcon.add(this.thecontact);
                    dbopmethod(lcon,'Insert');    
                }
                if(lContact.size()==1) {
                    this.thecontact=lcontact[0];
                    updatecontactaddress(lContact[0].id,fromaddress);
                    list<case> lcase=[select Id,Business_Case_Post_Tag__c,Auto_Reassignment_Tag__c,Case_PostTag__c,Case_Post_Tag__c,Reassignment_Reason__c,CaseNumber,Subject,Second_SLA_Response_Time__c,Current_SLA_Phase__c,Description,status,closeddate,SuppliedEmail,Suppliedname,lastmodifieddate,case.contact.Last_Email_Used__c,case.contactid,ownerid,Track_Case_Queue__c,recordtypeid,Do_Not_Reassign__c from case where Case.contact.id=:lcontact[0].id and (status !='Closed' and status != 'Auto Closed') and recordTypeId IN:recordTypeIdSet order by createddate desc];
                    if(lcase.size()>1 && allowmultipleemailCases) {
                        this.thecase=lcase[0];
                        commentflag=true;
                        emailnamedescriptionupd(this.thecase);
                        sCommentbody.add('The Incoming Email has multiple open cases.Attaching the email with most recently Modified Open Case');
                    } else {
                        if(lcase.size()==1 && allowmultipleemailCases) { 
                            this.thecase=lcase[0];
                        }
                        if(lcase.size()==0) { 
                            list<case> lcaseclosed=[select Id,Business_Case_Post_Tag__c,Auto_Reassignment_Tag__c,Case_PostTag__c,Case_Post_Tag__c,Reassignment_Reason__c,Second_SLA_Response_Time__c,CaseNumber,Subject,Current_SLA_Phase__c,Description,status,closeddate,SuppliedEmail,Customer_Response_Received_Time__c,Suppliedname,lastmodifieddate,case.contact.Last_Email_Used__c,case.contactid,ownerid,Track_Case_Queue__c,recordtypeid,Do_Not_Reassign__c from case where Case.contact.id=:lcontact[0].id and (status ='Closed' OR status='Auto Closed') and recordTypeId IN:recordTypeIdSet order by closeddate desc];
                            if(lcaseclosed.size()>1 && allowmultipleemailCases && Social_SocialPostSCSHandler.caseReopenCheck(lcaseclosed[0])){
                                this.thecase=lcaseclosed[0];
                                commentflag=true;
                                reopenflag=true;
                                emailnamedescriptionupd(this.thecase);
                                sCommentbody.add('The Incoming Email has multiple cases Closed in the last 24 hrs.Attaching the email with most recently Closed Case');
                            }
                            if(lcaseclosed.size()==1 && allowmultipleemailCases && Social_SocialPostSCSHandler.caseReopenCheck(lcaseclosed[0])){ 
                                this.thecase=lcaseclosed[0];
                                emailnamedescriptionupd(this.thecase);
                                reopenflag=true;
                            }
                        }            
                    }
                }
            }
        
            if(this.theCase == null) {
                List<case> lcase=new list<case>();
                this.theCase = new Case();
                theCase.SuppliedEmail = email.fromAddress;
                theCase.SuppliedName = email.fromName;
                theCase.Status = 'New';
                theCase.Priority = 'High';
                //theCase.OwnerId = lgroup[0].id;
                theCase.Case_PostTag__c='Email2Case';
                theCase.Case_Post_Tag__c='Email2Case'; // To update the Case Post Tag(multi select picklist) on a particular case.
                theCase.Social_Media_Source__c='ATT CustCare Mailbox';
                theCase.Origin = 'Email';
                theCase.Subject = email.Subject;
                theCase.Description = email.plainTextBody;
                thecase.contactid = this.thecontact.id;
                this.theCase.Customer_Response_Received_Time__c= dateTime.Now();//Added to track customer's email received.        
                Group groupObj = [select id from group where Name = 'Email' and Type = 'Queue'];
                if (groupObj != Null && thecase.Track_Case_Queue__c == Null) {
                    thecase.Track_Case_Queue__c = groupObj.Id;                   
                }
                thecase.RecordTypeId= getSobjectrecordtypeid('Case','Consumer Care Email Case');
                this.thecase.Customer_Response_Received__c = true;
                AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                thecase.setOptions(dmlOpts);
                boolean escFlag = escalatedEmail(email.fromAddress);
                if(escFlag) {
                    lcase.add(thecase);
                    dbopmethod(lcase,'Insert');
                }
                else if(!escFlag && !allowmultipleemailCases) {
                    lcase.add(thecase);
                    dbopmethod(lcase,'Insert');
                }
            }
        
            if (commentflag) {    
                for(string str:sCommentbody) {
                    this.thecasecomment=new casecomment(CommentBody=str, ParentId= theCase.Id, isPublished=FALSE);
                    lcasecomment.add(this.thecasecomment);
                }
                if(escalatedEmail(email.fromAddress)){   
                    dbopmethod(lcasecomment,'Insert');
                }
            } 
            createEmailMessage(theCase,email);
            if(this.thecase.ownerid!=null){
                userIdString=this.thecase.ownerid;
            }
            if(!'Closed'.equalsignorecase(this.thecase.status) && !'Auto Closed'.equalsignorecase(this.thecase.status)) {
                if (this.thecase.ownerid != null && userIdString.startsWith('005')) {
                    this.thecase.Customer_Response_Received__c = true; //DNR: updated from false to true
                    this.theCase.Customer_Response_Received_Time__c= dateTime.Now();//Added to track customer's email received.                        
                    User userObj = [select id,availability__c from user where id =:this.thecase.ownerid ];
                    //If case owner is offline or vacation and DNR = false push case back to Queue and change case status to Reassigned if a customer email is received
                    if(escalatedEmail(email.fromAddress) && null!= userObj.availability__c && ('Offline'.equalsIgnoreCase(userObj.availability__c) || 'Vacation'.equalsIgnoreCase(userObj.availability__c)) && !this.thecase.Do_Not_Reassign__c && ('SLA1 - Initiated'.equalsignorecase(this.thecase.Current_SLA_Phase__c) || 'SLA2 - Initiated'.equalsignorecase(this.thecase.Current_SLA_Phase__c))){
                        // Update Case Owner To Queue
                        caseOwnerId=this.thecase.OwnerId;
                        this.thecase.OwnerId = this.thecase.Track_Case_Queue__c;  
                        this.thecase.Case_Reassigned_Time__c = null;
                        this.thecase.Case_System_Reassign__c = true;
                        if (!Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK.equalsIgnoreCase(this.thecase.Status)){
                            this.thecase.status =  Social_StreamingUtil.CASE_STATUS_REASSIGNED;
                        }
                        this.theCase.Case_Reassigned_Time__c = null;
                        isOwnerOfficeVacation = false;
                        if('SLA1 - Initiated'.equalsignorecase(this.thecase.Current_SLA_Phase__c)){
                            this.thecase.Current_SLA_Phase__c = null;
                            this.thecase.First_SLA_Scheduled_Time__c = null;
                            clearSLAEventsandTasks(this.thecase.id, 'SLA - 1');
                        }
                        else if('SLA2 - Initiated'.equalsignorecase(this.thecase.Current_SLA_Phase__c)){
                            this.theCase.Current_SLA_Phase__c = 'SLA1 - Ended';
                            this.theCase.Second_SLA_Start_Time__c = null;
                            this.theCase.Second_SLA_Scheduled_Time__c = null;
                            this.theCase.SLA_2_Initiated_Time__c = null;
                            this.theCase.Pending_Second_SLA_Task_Creation__c = true;
                            clearSLAEventsandTasks(this.thecase.id, 'SLA - 2');
                        }
                        updateflag = true;      
                    }
                    
                    if(escalatedEmail(email.fromAddress) && this.thecase.Do_Not_Reassign__c && 'SLA1 - Ended'.equalsignorecase(this.thecase.Current_SLA_Phase__c)) {
                        this.thecase.Current_SLA_Phase__c = 'SLA2 - Initiated';
                        isOwnerOfficeVacation = false;
                        createtasks(true);
                        updateflag = true;
                        isOwnerOfficeVacation = false;
                    }
                    else if(escalatedEmail(email.fromAddress) && !this.thecase.Do_Not_Reassign__c && 'SLA1 - Ended'.equalsignorecase(this.thecase.Current_SLA_Phase__c) && !('Vacation'.equalsignorecase(userObj.availability__c) || 'Offline'.equalsignorecase(userObj.availability__c))) {
                        this.thecase.Current_SLA_Phase__c = 'SLA2 - Initiated';
                        isOwnerOfficeVacation = false;
                        createtasks(true);
                        updateflag = true;
                        isOwnerOfficeVacation = false;
                    }
                    else if(escalatedEmail(email.fromAddress) && !this.thecase.Do_Not_Reassign__c && 'SLA1 - Ended'.equalsignorecase(this.thecase.Current_SLA_Phase__c) && ('Vacation'.equalsignorecase(userObj.availability__c) || 'Offline'.equalsignorecase(userObj.availability__c))) {
                        caseOwnerId=this.thecase.OwnerId;
                        this.thecase.OwnerId = this.thecase.Track_Case_Queue__c;  
                        this.thecase.Case_System_Reassign__c = true;
                        this.thecase.Pending_Second_SLA_Task_Creation__c = true;
                        this.thecase.Case_Reassigned_Time__c = null;
                        if (!Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK.equalsIgnoreCase(this.thecase.Status)){
                            this.thecase.Status = Social_StreamingUtil.CASE_STATUS_REASSIGNED;
                        }
                        updateflag = true;
                        isOwnerOfficeVacation = false;
                    }
                    // Else if condition added for reassign owner after SLA2 ends. 8/6/2014 release. 
                    else if(Boolean.valueOf(label.SLA2EndReassign) && userObj.availability__c != null && ('Vacation'.equalsignorecase(userObj.availability__c) || 'Offline'.equalsignorecase(userObj.availability__c))&& ('SLA2 - Ended'.equalsignorecase(this.thecase.Current_SLA_Phase__c) || this.thecase.Second_SLA_Response_Time__c!=null) && !this.thecase.Do_Not_Reassign__c) {
                        // Update Case Owner To Queue
                        caseOwnerId=this.thecase.OwnerId;
                        this.thecase.OwnerId = this.thecase.Track_Case_Queue__c; 
                        this.thecase.Case_System_Reassign__c = true;
                        updateflag=true;
                        SLA2EndReaasign=true;
                        if (!Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK.equalsIgnoreCase(this.thecase.Status)){
                            this.thecase.Status = Social_StreamingUtil.CASE_STATUS_REASSIGNED;  
                        }
                        updateflag = true;
                        isOwnerOfficeVacation = false;      
                    }
                    else if('SLA2 - Ended'.equalsignorecase(this.thecase.Current_SLA_Phase__c) || this.thecase.Second_SLA_Response_Time__c!=null){
                        updateflag=true;
                    } 
                } 
                else if (this.thecase.ownerid != null && userIdString.startsWith('00G')){
                    if(system.label.PendingClouseQueueId.equalsignorecase(this.thecase.ownerid)){
                        //to blank out the reassignment reason, Auto Reassignment Tag and update the Case post tag accoerding to the Reassignment tag
                        if(this.thecase.Auto_Reassignment_Tag__c != null && this.thecase.Do_Not_Reassign__c == false){
                            Social_StreamingUtil.fireAssignmentRule = true;
                            this.thecase.Reassignment_Reason__c = null;
                            this.thecase.Case_Post_Tag__c = this.thecase.Auto_Reassignment_Tag__c;
                            this.thecase.Case_PostTag__c = this.thecase.Auto_Reassignment_Tag__c;
                            this.thecase.Business_Case_Post_Tag__c = this.thecase.Auto_Reassignment_Tag__c;
                            this.thecase.Auto_Reassignment_Tag__c = null;     
                        } else {
                            this.thecase.OwnerId = this.thecase.Track_Case_Queue__c;
                        }
                        this.thecase.Case_System_Reassign__c = true;
                        this.thecase.Case_Reassigned_Time__c = null;
                        updateflag=true;
                        if (!Social_StreamingUtil.CASE_STATUS_HOLDFORCALLBACK.equalsIgnoreCase(this.thecase.Status)){
                            this.thecase.Status = 'Escalated';  
                        }
                        isOwnerOfficeVacation = false; 
                        this.thecase.Customer_Response_Received__c = true;
                        this.theCase.Customer_Response_Received_Time__c= dateTime.Now();//Added to track customer's email received.    
                  }
              }
            } else {
                if(reopenflag) {
                    isOwnerOfficeVacation = false;
                    this.thecase.status='Reopen';
                    this.thecase.update_reason__c = Social_StreamingUtil.CASE_REOPENED;
                    this.thecase.Customer_Response_Received__c = true;
                    this.thecase.No_Contact_Email_Available__c = false;
                    this.theCase.Customer_Response_Received_Time__c= dateTime.Now();//Added to track customer's email received.    
                    this.thecase.Is_Auto_Closed__c = false;
                    this.thecase.RecordTypeId = SYSTEM.LABEL.Consumer_Care_Email_Case;
                    updateflag=true;
                    if (string.valueof(this.thecase.ownerid).startsWith('005')) {
                        string savailability=[select availability__c from user where id=:this.thecase.ownerid].availability__c ;  
                        if(('Vacation'.equalsignorecase(savailability) ||'Offline'.equalsignorecase(savailability)) && !this.thecase.Do_Not_Reassign__c  ) {
                            caseOwnerId=this.thecase.OwnerId;
                            this.thecase.ownerid=this.thecase.Track_Case_Queue__c; 
                            this.thecase.Case_Reassigned_Time__c = null;
                            this.thecase.Case_System_Reassign__c = true;
                            this.thecase.Second_SLA_Pending_Post__c = true;
                            this.thecase.Case_Reopen_Flag__c = true;
                            //Marking customer response as true so that SLA are launched on case when some user picks case manually
                        } else {
                            if('SLA1 - Ended'.equalsignorecase(this.thecase.Current_SLA_Phase__c)) {
                                datetime assignmentTime = datetime.now();
                                this.thecase.Current_SLA_Phase__c = 'SLA2 - Initiated';
                                this.thecase.Second_SLA_Start_Time__c = assignmentTime;
                                this.thecase.Second_SLA_Scheduled_Time__c = assignmentTime.addMinutes(60);
                                eventHandler.insertdata=true;
                                eventHandler.createSlaEvents(this.thecase, this.thecase.OwnerId, assignmentTime, 'SLA - 2');
                            } 
                        }
                    } else {
                        //to blank out the reassignment reason, Auto Reassignment Tag and update the Case post tag accoerding to the Reassignment tag
                        if(this.thecase.Auto_Reassignment_Tag__c != null && this.thecase.Do_Not_Reassign__c == false){
                            Social_StreamingUtil.fireAssignmentRule = true;
                            this.thecase.Reassignment_Reason__c = null;
                            this.thecase.Case_Post_Tag__c = this.thecase.Auto_Reassignment_Tag__c;
                            this.thecase.Case_PostTag__c = this.thecase.Auto_Reassignment_Tag__c;
                            this.thecase.Business_Case_Post_Tag__c = this.thecase.Auto_Reassignment_Tag__c;
                            this.thecase.Auto_Reassignment_Tag__c = null;     
                        } else if (this.thecase.Track_Case_Queue__c != Null) {
                            this.thecase.ownerid=this.thecase.Track_Case_Queue__c;
                            this.thecase.Case_Reassigned_Time__c = null;
                        }
                    }
                    //Storing contact Id of case been reopened in order to update last case closed field on contact
                    if (this.thecase.contactId != Null) {
                        contactIdSet.add(this.thecase.contactId);
                    }         
                }
            }
            if(this.thecase!=null && updateflag){
                //Logic to get the updated case owner when current owner is offline or on vacation.
                if (isOwnerOfficeVacation && !SLA2EndReaasign) { // SLA2EndReaasign boolean flag becomes true when reassignment happen after SLA2-Ends. 
                    Case caseObj = [select id,ownerId,recordtypeId from case where id =: this.thecase.Id];
                    if (caseObj.ownerId != Null) {
                        this.thecase.ownerId = caseObj.ownerId;
                        if (this.thecase.ownerId != Null) {
                            String caseOwner = this.thecase.ownerId;
                            if (caseOwner.startsWith('005')) {
                                string userAvailability = [select availability__c from user where id=:this.thecase.ownerid].availability__c ;
                                if ('SLA1 - Ended'.equalsignorecase(this.thecase.Current_SLA_Phase__c) && 'Available'.equalsignorecase(userAvailability)) {
                                    this.thecase.Current_SLA_Phase__c = 'SLA2 - Initiated';
                                    this.thecase.Customer_Response_Received__c = true; //DNR: added for when sla2 initiate.
                                    this.theCase.Customer_Response_Received_Time__c= dateTime.Now();//Added to track customer's email received.    
                                }
                            }
                        }
                    }
                 }
                lrecase.add(this.thecase);
            }
            if(lrecase.size()>0 && escalatedEmail(email.fromAddress)){
                if(Social_StreamingUtil.fireAssignmentRule){
                    Database.DMLOptions dmo = new Database.DMLOptions();
                    dmo.assignmentRuleHeader.useDefaultRule = true;
                    Database.update(lrecase, dmo);
                } else {
                    dbopmethod(lrecase,'Update');
                }
                
                //Logic to increment case counter for case owner when case is reopened.
                if (this.thecase.status == Social_StreamingUtil.CASE_STATUS_REASSIGNED && caseOwnerId!=null) {
                    Set<Id> caseOwnerSet = new Set<Id>();
                    caseOwnerSet.add(caseOwnerId);
                    social_caseCounterUserUpdate.updateCaseCounterUser(caseOwnerSet); 
                }       
            }
            //Update Last Case Closed field on contact when a case is reopened
            if (!contactIdSet.isEmpty()) {
                Social_StreamingUtil.doNtFireEmail2CaseRun = false;
                Social_CaseAssignmentUtility.executeTriggerCode = false;
                Social_ContactLastClosedCaseController.updateContactOnCaseReopen(contactIdSet);
            }
        } catch(System.Exception e) {
            CreateExceptionObject(e.getMessage()+e.getStackTraceString()+e.getTypeName());
        }
        return result;
    }

    /**
    * < updatecontactaddress() - method is used to update the last email used and store the latest email in the all emails field on the contact>
    * @param:
    *     Id Conid -- Contact Id.
    *     string fromaddress -- From Address
    *
    * @return - Void
    * @see - Social_CaseEmailInBoundUtilities (Class)
    */

    public void updatecontactaddress(Id Conid,string fromaddress) {
        List<Contact> checkEscalationContact = [select id,Exception_Contact__c from contact where (Email =: fromaddress OR All_Contact_Emails__c like :'%'+fromaddress+'%') order by lastmodifieddate desc limit 50000];
        if(!checkEscalationContact.isEmpty() && !string.isblank(conid)  && !checkEscalationContact[0].Exception_Contact__c){ 
            list<contact> lContact = [select id,name,Email,All_Contact_Emails__c,Last_Email_Used__c from contact where id=:conid order by createddate desc limit 50000];
            if(!lContact.isEmpty()) {
                if(string.isblank(lContact[0].Last_Email_Used__c)) {
                    lContact[0].Last_Email_Used__c = fromaddress;
                } else {
                    if(!lContact[0].Last_Email_Used__c.equalsignorecase(fromaddress)){
                        lContact[0].Last_Email_Used__c = fromaddress;
                    }
                }
                if(string.isblank(lContact[0].Email)){
                    lContact[0].Email=fromaddress;
                }
                if(string.isblank(lContact[0].All_Contact_Emails__c)){
                    lContact[0].All_Contact_Emails__c = fromaddress;
                } else {
                    if(!lContact[0].All_Contact_Emails__c.contains(fromaddress)){
                        lContact[0].All_Contact_Emails__c = lContact[0].All_Contact_Emails__c+';'+fromaddress;
                    }
                }
                if(!lContact[0].All_Contact_Emails__c.contains(lContact[0].Email)){    
                    lContact[0].All_Contact_Emails__c=lContact[0].All_Contact_Emails__c+';'+lContact[0].Email;
                }
                dbopmethod(lContact,'Update');
            }
        }
    }

   /**
    * < limitLength() - This Function is used to limit the data stored in fields of email message so that no exception is thrown>
    * @param:
    *     String input -- Email Subject.
    *     Integer maxLength -- To Address Lenght
    *
    * @return - String Result -- Limited String based on maxlenght.
    * @see - Social_CaseEmailInBoundUtilities (Class)
    */

    public String limitLength(String input, Integer maxLength) {
        String results='';
        if(input != null && input.length() > maxLength) {
            results = input.substring(0,maxLength);
        } else {
            results = input;
        }
        return results;
    }
    
    /**
    * < createEmailMessage() - This Function is used to create the email message for the incoming email>
    * @param:
    *     String input -- Email Subject.
    *     Integer maxLength -- To Address Lenght
    *
    * @return - String Result -- Limited String based on maxlenght.
    * @see - Social_CaseEmailInBoundUtilities (Class)
    */

    private void createEmailMessage(Case theCase, Messaging.InboundEmail email) {
        String value='';
        Integer maxlength=0;
        List<EmailMessage> lemsg=new list<EmailMessage>();
        List<Attachment> lattach=new list<attachment>();
        EmailMessage theEmail = new EmailMessage();
        theEmail.ParentId = theCase.Id;
        theEmail.Incoming = true;
        Schema.DescribeFieldResult F = EmailMessage.HtmlBody.getDescribe();
        maxlength = F.getLength();
        theEmail.Subject = limitLength(email.Subject, EmailMessage.Subject.getDescribe().getLength());
        theEmail.MessageDate = datetime.now();
        theEmail.HtmlBody = limitLength(email.htmlBody,EmailMessage.HtmlBody.getDescribe().getLength());  
        theEmail.TextBody = limitLength(email.plainTextBody,EmailMessage.TextBody.getDescribe().getLength());
        theEmail.Incoming=true;
 
        /* **** To */
        value = '';
        if(email.toAddresses != null) {
            Boolean seenOne= false;
            for(String to : email.toAddresses) {
                if(seenOne) {
                    value += ';\n';
                }
                to  = extractAddress(to);
                value += to;
                seenOne = true;
            }
        }
        theEmail.ToAddress = limitLength(value,EmailMessage.ToAddress.getDescribe().getLength());
 
        /* **** From */
        theEmail.FromName = email.fromName;
        theEmail.FromAddress = email.fromAddress;
        
        /* **** CC */
        value = '';
        if(email.ccAddresses != null) {
            Boolean seenOne= false;
            for(String cc : email.ccAddresses) {
                if(seenOne) {
                    value += ';\n';
                }
                cc  = extractAddress(cc);
                value += cc;
                seenOne = true;
            }
        }
        theEmail.CcAddress = limitLength(value,EmailMessage.CcAddress.getDescribe().getLength()); 
        
        lemsg.add(theEmail);
        if(lemsg.size()>0){
            dbopmethod(lemsg,'Insert');
        }
        Attachment a=null;
        if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
            for (integer i = 0 ; i < email.binaryAttachments.size() ; i++){
                a=new Attachment();
                a.ParentId = thecase.Id;
                a.Name = email.binaryAttachments[i].filename;
                a.Body = email.binaryAttachments[i].body;
                lattach.add(a);
            }
        }
        if (email.TextAttachments != null && email.TextAttachments.size() > 0) {
            for (integer i = 0 ; i < email.TextAttachments.size() ; i++){
                a=new Attachment();
                a.ParentId = thecase.Id;
                a.Name = email.TextAttachments[i].filename;
                a.Body = Blob.valueOf(email.TextAttachments[i].body);
                lattach.add(a);
            }
        }
        if(lattach.size()>0){
            dbopmethod(lattach,'Insert');
        }

    }

    /**
    * < dbopmethod() - This Function is used to insert/Update the database objects>
    * @param:
    *     String input -- Email Subject.
    *     Integer maxLength -- To Address Lenght
    *
    * @return - String Result -- Limited String based on maxlenght.
    * @see - Social_CaseEmailInBoundUtilities (Class)
    */

    private void dbopmethod(List<sObject> obj,string flag) {
        errorstring='';
        Database.SaveResult[] resultDB;
        if(obj.size()>0) {
            if('Update'.equalsignorecase(flag)) {
                resultDB = database.update(obj, false);
            }
            if('Insert'.equalsignorecase(flag)){
                resultDB = database.insert(obj, false);
            }
            try {
                Integer loopCount = 0;
                for(Database.SaveResult sr:resultDB) {               
                    if(!sr.isSuccess()) {                    
                        Database.Error err = sr.getErrors()[0];
                        if('Update'.equalsignorecase(flag)){
                            errorString = errorstring+ 'Error while Updating. ' +obj.get(loopCount).getSObjectType() + ' ' + err + '\n'; 
                        } else if ('Insert'.equalsignorecase(flag)){
                            errorString = errorstring+ 'Error while Inserting. ' +obj.get(loopCount).getSObjectType() + ' ' + err + '\n'; 
                        }                   
                    }
                    loopCount++;
                }
                if(!string.isblank(errorstring)) {
                    CreateExceptionObject(errorString); 
                }               
            } catch(Exception e) {
                System.debug('Error handling Response. ' + e.getMessage());
                CreateExceptionObject(e.getMessage()+e.getStackTraceString()+e.getTypeName());
            }
        }     
    }
    
   /**
    * < extractRef() - Look for the case reference in the email subject line.  First search for a case reference using the
    *                   standard Salesforce method of creating that complicated and non-user-friendly reference.  Do this first
    *                   so it takes precedence.>
    * @param:
    *     String emailSubject -- Email Subject
    *
    * @return - String itemRef -- Case Number.
    * @see - Social_CaseEmailInBoundUtilities (Class)
    */   

    private String extractRef(String emailSubject) {
        String itemRef = null;
        String patternString='';
        Pattern thePattern;
        Matcher matcher;
        patternString = label.Pattern_Matching;// the pattern string for reference id is stored in a custom label
        thePattern = Pattern.compile(patternString);
        matcher = thePattern.matcher(emailSubject); // do not change to lower case for this test because Id's are case sensitive
        
        if (matcher.matches()) {
            String caseId = '500'+ matcher.group(1) + '00000' + matcher.group(2);
            if(TRACE) { 
                system.debug(Logginglevel.ERROR,'extractRef "' + caseId + '"');    
            }
            Case[] matchingCases = [Select Id,Business_Case_Post_Tag__c,Auto_Reassignment_Tag__c,Reassignment_Reason__c,Case_Post_Tag__c,Case_PostTag__c,CaseNumber,Subject,Current_SLA_Phase__c,Description,status,closeddate,SuppliedEmail,Suppliedname,lastmodifieddate,case.contact.Last_Email_Used__c,case.contactid,ownerid,Track_Case_Queue__c,recordtypeid,Do_Not_Reassign__c from Case where Id = :caseId];
            if(matchingCases.size() == 1 ) {
                case theCase1 = matchingCases[0];
                itemRef = theCase1.CaseNumber;
            }      
        }
        return itemRef; 
    }
    
    /**
    * < locateByCaseNumberAsString() - Given a case number such as 8144 find the exact case that use this number. Note that CaseNumber is a string field 
                                       that may have any number of leading zeros.>
    * @param:
    *     String caseNumberStr -- Case Number.
    *
    * @return - String itemRef -- Case Number.
    * @see - Social_CaseEmailInBoundUtilities (Class)
    */  

    private Case locateByCaseNumberAsString(String caseNumberStr) {
        Integer target = Integer.valueOf(caseNumberStr);
        Case theResult = null;
        String caseNumber = '%' + String.valueOf(target);
        Case[] matchingCases = [Select Id,Business_Case_Post_Tag__c,Auto_Reassignment_Tag__c,Reassignment_Reason__c,Case_Post_Tag__c,Case_PostTag__c,CaseNumber,Second_SLA_Response_Time__c,Subject,Customer_Response_Received_Time__c,Current_SLA_Phase__c,Description,status,closeddate,SuppliedEmail,Suppliedname,lastmodifieddate,case.contact.Last_Email_Used__c,case.contactid,ownerid,Track_Case_Queue__c,recordtypeid,Do_Not_Reassign__c from Case where (CaseNumber like :caseNumber)];
        for(Case aCase: matchingCases) {
            Integer cnum = Integer.valueOf(aCase.CaseNumber);
            if(cnum == target) {
                theResult = aCase;
                break;
            }
        }
        return theResult;
    }

   /**
    * < extractAddress() - The method which reads the emails from the incoming string of email addresses.>
    * @param:
    *     String inAddress -- Email Address (To,CC,Bcc).
    *
    * @return - String address 
    * @see - Social_CaseEmailInBoundUtilities (Class)
    */  

    public String extractAddress(String inAddress) {
        String address='';
        String patternString='';
        Pattern thePattern;
        Matcher matcher;
        patternString = '.*<(.*)>.*';
        thePattern = Pattern.compile(patternString);
        matcher = thePattern.matcher(inAddress);
        if (matcher.matches()) {
            address = matcher.group(1); 
        } else {
            address = inAddress;   
        }
        return address;
    }

   /**
    * < getSobjectrecordtypeid() - This Generic function is used to extract the recordtypeid for any object.>
    * @param:
    *     string sObjecttype 
    *     string srecordtype
    *
    * @return - Id recid 
    * @see - Social_CaseEmailInBoundUtilities (Class)
    */  

    private id getSobjectrecordtypeid(string sObjecttype, string srecordtype) {
        id recid=null;
        List<RecordType> lRecordtypeid=[Select SobjectType, Name, Id From RecordType  where SobjectType=:sObjecttype and name=:srecordtype limit 1];
        if(lRecordtypeid.size()>0) {
            recid=lRecordtypeid[0].id;
        }
        return recid;    
    }
    
    /**
    * < CreateExceptionObject() - This  function is used to send the exception mail or insert in to a generic exception object.>
    * @param:
    *     string exceptionmessage -- Exception message
    *
    * @return - Void 
    * @see - Social_CaseEmailInBoundUtilities (Class)
    */  
    
    public void CreateExceptionObject(string exceptionmessage) {
        String value='';
        List<EmailMessage__c> lemsg=new list<EmailMessage__c>(); 
        EmailMessage__c emsg=new EmailMessage__c();
        if(email2.toAddresses != null) {
            Boolean seenOne= false;
            for(String to : email2.toAddresses) {
                if(seenOne) {
                    value += ';\n';
                }
                to  = extractAddress(to);
                value += to;
                seenOne = true;
            }
        }
        emsg.To_Address_New__c = limitLength(value,EmailMessage__C.To_Address_New__c.getDescribe().getLength());
        if(email2.ccAddresses!= null) {
            Boolean seenOne= false;
            value='';
            for(String to : email2.ccAddresses) {
                if(seenOne) {
                value += ';\n';
                }
                to  = extractAddress(to);
                value += to;
                seenOne = true;
            }
        }
        emsg.CC_Address__c = limitLength(value,EmailMessage__C.CC_Address__c.getDescribe().getLength());
        emsg.From_Address_New__c = email2.fromaddress; 
        emsg.Body__c=email2.plainTextBody;
        emsg.Subject__c=email2.subject;
        emsg.From_Name__c=email2.fromName;
        emsg.Status__c='FAILED';
        if(thecase!=null){
            emsg.Case__c=this.thecase.id;
        }
        if(thecontact!=null){
            emsg.Contact__c=this.thecontact.id;
        }
        emsg.type__c='Inbound';
        emsg.Exception_Message__c=exceptionmessage;
        emsg.Message_Date__c=system.NOW();
        lemsg.add(emsg);
        dbopmethod(lemsg,'Insert');
    }
    
   /**
    * < createtasks() - This method is used to create tasks for SLA initiation whenever a email comes in for a case.>
    * @param:
    *     boolean inflag -- Exception message
    *
    * @return - Void 
    * @see - Social_CaseEmailInBoundUtilities (Class)
    */      

    private void createtasks(boolean inflag) {
        List<task> ltask= new list<task>();
        task tsk=new task();
        tsk.Ownerid=[select id from user where name='Automated Admin'].id ;        
        tsk.Whatid=thecase.id;
        if(inflag) {
            tsk.subject='SLA-2 Customer Response Task';
        }
        tsk.status='Not Started';
        tsk.priority='Normal';
        tsk.IsReminderSet=false;
        tsk.Email_to_Case_Task__c=true;
        if(tsk!=null) {
            ltask.add(tsk);
        }
        if(ltask.size()>0) {
            dbopmethod(ltask,'Insert');
        }
    }
    
   /**
    * < emailnamedescriptionupd() - Method used to update the webname, web email and description field on a case which does not have these fields populated.>
    * @param:
    *     Case c -- Case Object
    *
    * @return - Void 
    * @see - Social_CaseEmailInBoundUtilities (Class)
    */  

    private void emailnamedescriptionupd(Case c) {
        if(string.isblank(c.SuppliedEmail)) {
            this.thecase.SuppliedEmail=email2.fromaddress;
            updateflag=true;
        }
        if(string.isblank(c.SuppliedName)) {
            this.thecase.SuppliedName=email2.fromname;
            updateflag=true;
        }
        if(string.isblank(c.Description)) {
            this.thecase.Description=email2.plainTextBody;
            updateflag=true;
        }
    }
    
   /**
    * < escalatedEmail() - If the Inbound Mail Id is an Escalated Email address then dont add to the case Update.>
    * @param:
    *     string fromaddress -- From Address
    *
    * @return - boolean escFlag -- If from address is an escalation contact escFlag is set to false else true.
    * @see - Social_CaseEmailInBoundUtilities (Class)
    */  

    public boolean escalatedEmail(string fromaddress) {
        boolean escFlag = true;
        list<contact> escContact =[select c.Email,c.All_Contact_Emails__c,c.LastName,c.FirstName from contact c where c.Exception_Contact__c=true];
        Set<String> escSet = new Set<String>();
        if(escContact.size()>0) {
            for(Contact ct:escContact) {
                if(!string.isblank(ct.all_contact_emails__c)) {
                    if((ct.all_contact_emails__c).contains(';')){         
                        escSet.addall(ct.all_contact_emails__c.split(';'));
                    } else {
                        escSet.add(ct.all_contact_emails__c);
                    }
                } else {
                    if(!string.isblank(ct.email)) {
                        // lstring.add(ct.email);
                        escSet.add(ct.email);
                    }
                }
            }
        }
        if(escSet.contains(fromaddress)){
            escFlag = false;
        }
        return escFlag;
    }
    
    private void clearSLAEventsandTasks(Id caseId, String caseSLAStage){
        if(null!=caseId && null!=caseSLAStage && 'SLA - 1'.equalsIgnoreCase(caseSLAStage)){
            
            try{
                Event[] caseEventList = [Select e.WhatId, e.Id, e.Event_Type__c From Event e where e.WhatId =:caseId and e.Event_Type__c = 'SLA - 1'];
                
                if(null!=caseEventList && caseEventList.size()>0){
                    // Enable Static Field For Event/Task Delete
                    Social_caseActivityDeleteControl.deleteActivity = true;
                    try{
                        delete caseEventList;
                    }
                    catch(Exception e){
                        System.debug('Error : '+e);
                    }
                }
            }
            catch(Exception e){
                System.debug('Error : '+e);
            }
            
        }
        else if(null!=caseId && null!=caseSLAStage && 'SLA - 2'.equalsIgnoreCase(caseSLAStage)){
            try{
        
                Event[] caseEventList = [Select e.WhatId, e.Id, e.Event_Type__c From Event e where e.WhatId =:caseId and e.Event_Type__c = 'SLA - 2'];
                // Query Related Task (SLA-2 Social Post Task)
                Task[] caseTaskList = [Select t.WhatId, t.Subject, t.Id, t.Event_Type__c From Task t where t.WhatId =:caseId and t.Event_Type__c=:'SLA - 2' and t.Subject=:'SLA-2 Customer Response Task'];
                if(null!=caseEventList && caseEventList.size()>0){
                    // Enable Static Field For Event/Task Delete
                    Social_caseActivityDeleteControl.deleteActivity = true;
                    try{
                        delete caseEventList;
                    }
                    catch(Exception e){
                        System.debug('Error : '+e);
                    }
                }
                if(null!=caseTaskList && caseTaskList.size()>0){
                    // Enable Static Field For Event/Task Delete
                    Social_caseActivityDeleteControl.deleteActivity = true;
                    try{
                        delete caseTaskList;
                    }
                    catch(Exception e){
                        System.debug('Error : '+e);
                    }
                }
            }
            catch(Exception e){
                System.debug('Error : '+e);
            }
        }
    }
    
}