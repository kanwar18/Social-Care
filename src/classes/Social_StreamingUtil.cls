/**************************************************************************
Class Name:  Social_StreamingUtil
Author: Accenture
Requirement/Project Name: Social Consumer 
Description: class is used for string static variables and methods.
Version History: Aditya(14/March/2014) - Release 19March2014
Version History: Debasis(5/June/2015) - Release 17June2015 - ITS1504; Users were forced to reply using the comment option for Facebook reply post. 
Release 23rdSeptember2015 : ITS1514 - Introduction of flag variables for Business
**************************************************************************************************************************/

public class Social_StreamingUtil{
  
   public static List<String> sendTo= new List<String>();
   public static Set<Id> processed = new Set<Id>();
   public static Set<Id> contactProcessed = new Set<Id>();   
   public static Set<Id> closedProcessed = new Set<Id>();   
   public static Set<Id> deleteSLAsetId = new Set<Id>();
   public static Set<Id> reassignProcessed = new Set<Id>();
   public static Set<Id> caseIdFromTrigger = new Set<Id>();
   public static Set<String> caseOpenBusinessStatus = new Set<String>{'New','Reopen','Investigating'};
   public static Set<String> caseNotOpenBusinessStatus = new Set<String>{'Follow Up Hold','Escalated','Reassigned'};
   public static Set<Id> businessAssignQueue = new Set<Id>();
   public static Set<Id> countProcessed = new Set<Id>();
   public static Set<Id> queueCountProcessed = new Set<Id>();
   public static Set<Id> stopTransaction = new Set<Id>();
   public static Set<Id> skipTransaction = new Set<Id>();
   public static Set<Id> recursiveTransaction = new Set<Id>();
   public static Set<Id> ownerIdSetForCaseCounter = new Set<Id>();
   public static Set<Id> ownerIdSetForBizCaseCounter = new Set<Id>();
   public static set<Id> AutoClosedOwnerSet =new set<Id>();
   public static final string CASE_OBJ = 'Case';
   public static final string CONSUMER_CARE_CASE = 'Consumer Care Case';
   public static final string BUSINESS_CARE_CASE = 'Business Care Case';
   public static final string CONSUMER_CARE_CLOSED_CASE = 'Consumer Care Closed Case';
   public static final string CONSUMER_CASE_AUDIT_RT = 'Consumer Case QA Record Type';
   public static final string HS_CARE_REP = 'HS Care Rep';
   public static final string MANUAL_CONSUMER_CARE_CASE = 'Manual Consumer Care Case';
   public static boolean preventStatusUpdateWhenDNETriggerFires = true;
   public static Set<Id> dneCaseIds = new Set<Id>(); 
   public static boolean preventCaseValidateTriggerToFire = true;
   Public Static Boolean doNtFireEmail2CaseRun = true; // boolean flag will be used to stop trigger execution when custom email2case functionality runs.
   Public Static Boolean stopRecurssionFlagCase = true; //Flag used to stop recurssion on case after workflow runs.
   Public Static Boolean doNtReassignToQueue = true; //Flag used to stop assigning to queue if care manager changes the DNR Timeframe.
   Public Static Boolean doNtFireReassignmentRsnErr = true;
   Public Static Boolean doNotFireSLALogic = true;
   Public Static Boolean doNotFireUpdateReason = true; // Flag used to stop the update on "Update Reason" field on case
   public static Boolean BizSocialSalesFlag = true; // added by Ashween on 1/13 for putting SQL 101 check ITS#1343
   public static Boolean doNotUpdateReasonBizManualAssignment = true; // added by Ashween on 09/10/15 for avoiding exception when CM manually assigns case from queue      
   public static Boolean caseBizAssignedByRR = FALSE; // added by Ashween on 15/09/15 for avoiding multiple SLA and case counter increment(Round Robin)      
   public static Boolean caseBizAssignedByAssignCase = FALSE; // added by Ashween on 17/09/15 for avoiding multiple update reasons and case counter increment(Assign a case)      
   public static Boolean caseCounterZeroAfterVacation = FALSE; // added by Ashween on 17/09/15 for avoiding decrease in case counter when CM marks on vacation      
   Public static Boolean doNotUpdatePersona = true;
   Public static final String SLA1_INITIATED = 'SLA1 - Initiated';
   Public static final String SLA1_ENDED = 'SLA1 - Ended';
   Public static final String SLA2_INITIATED = 'SLA2 - Initiated';
   Public static final String SLA2_ENDED= 'SLA2 - Ended';
   Public static final String EVENT_STATUS_CLOSED = 'Closed';
   Public static final String EVENT_STATUS_OPEN = 'Open';
   Public static final String ERROR_MSG_ACCEPT_THE_CASE = 'Please accept the Case before replying to the Customer.';
   Public static final String QUEUE_ID = '00G';
   Public static final String CASE_STATUS_NEW = 'New';
   Public static final String CASE_STATUS_INVESTIGATING = 'Investigating';
   Public static final String CASE_REASON_COMPLETED = 'Completed';
   Public static final String CASE_STATUS_HOLDFORCALLBACK = 'Hold for Call Back';
   Public static final String CASE_STATUS_PENDINGCLOSURE = 'Pending Closure';
   Public static final String CASE_STATUS_REASSIGNED = 'Reassigned';
   Public static final String CASE_STATUS_ESCALATED = 'Escalated';
   Public static final String PENDINGCLOSURE_ERROR_MSG = 'You cannot assign/update a case to/in Pending Closure Queue.';
   Public static final String EVENT_ERROR = 'Event cannot be created. Parent case has not reached the 3rd SLA stage.';
   Public static final String EVENT_STATUS = 'SLA - 3';
   Public static final String SOCIALPOST_STATUS_SENT = 'Sent';
   Public static final String MEDIA_PROVIDER_TWITTER = 'Twitter';
   Public static final String MEDIA_PROVIDER_FACEBOOK = 'Facebook';
   Public static final String CASE_STATUS_CLOSED = 'Closed';
   Public static final String CASE_STATUS_AUTOCLOSED = 'Auto Closed';
   Public static final String NEW_SOCIAL_POST_STATUS = 'New Social Post';
   Public static final String CASE_STATUS_REOPEN = 'Reopen';
   Public static final String CASE_PRIMARY_COMPONENT_UNKNOWN = 'Unknown';
   Public static final String CASE_CM_VARIFIED_NO = 'No';
   Public static final String CASE_REASON_NO_OUTREACH = 'No Outreach';
   Public static final String CASE_EFFORT_NON_ACTIONABLE = 'Non Actionable';
   Public static final String CASE_ROOT_CAUSE_UNWANTED_SOLICITATION = 'Unwanted Solicitation';
   Public static final String CASE_POSTTAG_GENERAL = 'General';
   Public static final String CASE_CUSTOMER_TYPE_NON_CUSTOMER = 'Non Customer';
   Public static final String EVENT_DESCRIPTION_SLA2 = 'Second SLA Response Reminder.';
   Public static final String USER_ID = '005';
   Public static final String USER_STATUS_VACATION = 'Vacation';
   Public static final String USER_STATUS_OFFLINE = 'Offline';
   Public static final String PRIVATEMESSAGE = 'Private Message';
   Public static final String DIRECTMESSAGE = 'Direct Message';
   Public static final String FBPOST = 'Post';
   Public static final String FBCOMMENT = 'Comment';
   public static final string ASSIGN_A_CASE = 'Self Assigned';
   public static final string MANUAL = 'Manual Assignment';
   public static final string ROUND_ROBIN = 'Round Robin';
   public static final string OUTREACH_ASSIGNMENT = 'Outreach Assignment';
   public static final string INSTANT_ASSIGNMENT = 'Availability Assignment';
   public static final string MONITOR_ADMIN = 'Monitor Users / System Admin';
   Public Static final String APPROVED = 'Approved';
   Public Static final String REASSIGNED = 'Reassigned';
   Public Static final String ASSIGNED = 'Assigned';
   Public static final String CASE_STATUS_FOLLOWUPHOLD = 'Follow Up Hold';
   Public static final String MESSAGE_TYPE_REPLY = 'Reply'; 
   Public static final String PROVIDER_FACEBOOK = 'Facebook';
   Public static final String NONCASEOWNER_NO_OUTREACH_ERROR = 'You cannot respond to this case, only case owner can make an outreach.';
   Public static final String MANUAL_CASE_CREATED = 'Manual Case Created';
   Public static final String CUSTOMER_REPLY = 'Customer Reply';
   Public static final String INTERNAL_EMAIL = 'Internal Email';
   Public static final String BUSINESS_ROUND_ROBIN = 'New Case'; // added by Ashween for July'15 release ITS1545
   Public static final String CASE_REOPENED = 'Case Re-Opened';
   Public static final String NEW_TASK = 'New Task';
   Public static final String TASK_UPDATED = 'Task Updated';
   Public static final String NEW_EVENT = 'New Event';
   Public static final String EVENT_UPDATED = 'Event Updated';
   Public static Boolean fireAssignmentRule = false;
    /**
    * < getRecordTypeId() - Method to return the Business Case Record Type if the Post Tag matches below.
    *     String postTag - The post tag populated on the Case record
    * @return - 'Id' of Business Case Record Type
    * @see - copySocialPostDetails (Social_ClosedCaseReOpenHandler class) 
    */
   public static Id getRecordTypeId(String postTag){
    Id bsCaseRecordTypeId = System.Label.Business_Care_Case_Record_Type_ID;
    boolean flag = FALSE;
        if(postTag.toUpperCase() == 'GCS-GEN'){
            flag = true;
        }
        else if(postTag.toUpperCase() == 'GCS-D-S-L'){
            flag = true;            
        }
        else if(postTag.toUpperCase() == 'GCS-UVERSE'){
            flag = true;
        } 
        else if(postTag.toUpperCase() == 'GCS-IPHONE'){
            flag = true;
        }
        else if(postTag.toUpperCase() == 'GCS-IPAD'){
            flag = true;
        }
        else if(postTag.toUpperCase() == 'GCS-LANDLINE'){
            flag = true;
        }
        else if(postTag.toUpperCase() == 'GCS-WIRELESS'){
            flag = true;
        }
        else if(postTag.toUpperCase() == 'GCS-SALESLEAD'){
            flag = true;
        }
        else if(postTag.toUpperCase() == 'GCS-BLACKLIST'){
            flag = true;
        } 
        else if(postTag.toUpperCase() == 'GCS-AMS'){
            flag = true;
        } 
        else if(postTag.toUpperCase() == 'GCS-HIGHINFLUENCER'){
            flag = true;
        } 
        else if(postTag.toUpperCase() == 'GCS-PRODUCT-OFFERS'){
            flag = true;
        }
        else if(postTag.toUpperCase() == 'GCS-CELEBRITY'){
            flag = true;
        }
        else if(postTag.toUpperCase() == 'GCS-BUSINESSLEADER'){
            flag = true;
        }
        else if(postTag.toUpperCase() == 'GCS-ESCALATION'){
            flag = true;
        }
        else if(postTag.toUpperCase() == 'ABS REVIEW-CARE'){
            flag = true;
        }
        else if(postTag.toUpperCase() == 'ABS CARE'){
            flag = true;
        }
        //------------------------------------------------------------
        if(flag == false){
            return NULL;            
        }
        else{
            return bsCaseRecordTypeId;
        }        
    }
    
    /**
    * < updateSObject() -Method to update.
    * Database.SaveResult[] dbSaveResult - database result
    * String message - display error msg.
    * @see - social_DNEHandler (social_DNEHandler class) 
    */ 
    public static void updateSObject(List<sObject> objects, String errorMessage) {
        Social_StreamingUtil.doNotFireUpdateReason = false;
        if (!objects.isEmpty()) {
            Database.SaveResult[] dbSaveResult = Database.update(objects, false);
            String errorString = '';
            Integer loopCount = 0;
            for(Database.SaveResult sr : dbSaveResult){                
                if(!sr.isSuccess()){                    
                    Database.Error err = sr.getErrors()[0];
                    errorString += errorMessage + objects.get(loopCount).Id + ' ' + err + '<br/>';                                   
                }
                loopCount++;
            }
            if (errorString != '') {
                sendTo.addAll(string.valueOf(Label.Email_List_for_Class_Failure).split(','));
                Social_SendAnEmailUtility.sendEmail('Exception mail',sendTo,errorString, userInfo.getUserName());
            }
        }
    }
    
    /**
    * < insertSObject() -Method to update.
    * Database.SaveResult[] dbSaveResult - database result
    * String message - display error msg.
    * @see - social_DNEHandler (social_DNEHandler class) 
    */
    
    public static void insertSObject(List<sObject> objects, String errorMessage) {
        Social_StreamingUtil.doNotFireUpdateReason = false;
        if (!objects.isEmpty()) {
            Database.SaveResult[] dbSaveResult = Database.insert(objects, false);
            String errorString = '';
            for(Database.SaveResult sr : dbSaveResult){                
                if(!sr.isSuccess()){                  
                    Database.Error err = sr.getErrors()[0];
                    errorString = errorString + errorMessage + ' - ' + err + '<br/>' ;
                }
            }
            if (errorString != '') {
                sendTo.addAll(string.valueOf(Label.Email_List_for_Class_Failure).split(','));
                Social_SendAnEmailUtility.sendEmail('Exception mail',sendTo,errorString, userInfo.getUserName());
            }
        }
    }
       
    /**
    * < deleteSObject() -Method to delete.
    * Database.deleteResult[] dbDeleteResult - database result
    * String message - display error msg.
    * @see - social_DNEHandler (social_DNEHandler class) 
    */
    
    public static void deleteSObject(List<sObject> objects, String errorMessage) {
        Social_StreamingUtil.doNotFireUpdateReason = false;
        if (!objects.isEmpty()) {
            Database.DeleteResult[] dbDeleteResult = Database.delete(objects, false);
            Integer loopCount = 0;
            String errorString = '';
            for(Database.DeleteResult dr : dbDeleteResult){                
                if(!dr.isSuccess()){                    
                    Database.Error err = dr.getErrors()[0];
                    errorString = errorString + errorMessage + objects.get(loopCount).Id + ' ' + err + '\n';                                   
                }
                loopCount++;
            }
            if (errorString != '') {
                sendTo.addAll(string.valueOf(Label.Email_List_for_Class_Failure).split(','));
                Social_SendAnEmailUtility.sendEmail('Exception mail',sendTo,errorString, userInfo.getUserName());
            }
        }
    }
}