/*
*                                                                             *
*                            Version 1.00                                     *
*                                                                             *
* Creation Date: 16.Sept.2013                    Aditya Kumar                 *
* Last Modified: 16.Sept.2013                    Aditya Kumar                 *
*                                                                             *
*                             © 2008 - Accenture - All Rights Reserved        *
*/
Global class BC_00TestClassResultGenerator implements Database.Batchable<sObject>,Database.stateful {
   //outcome of apextestresults are pass,fail,complie fail.
   Public static final string APEXTESTRESULT_OUTCOME_PASS = 'Pass';
   Public static final string APEXTESTRESULT_OUTCOME_FAIL = 'Fail';
   Public static final string APEXTESTRESULT_OUTCOME_COMPLIE_FAIL = 'Compile Fail';
   //status of asyncapexjob object can be completed,aborted,failed,queued,preparing.
   Public static final string ASYNCAPEXJOB_STATUS_COMPLETED = 'Completed';
   Public static final string ASYNCAPEXJOB_STATUS_ABORTED = 'Aborted';
   Public static final string ASYNCAPEXJOB_STATUS_FAILED = 'Failed';
   Public static final string ASYNCAPEXJOB_STATUS_QUEUED = 'Queued';
   Public static final string ASYNCAPEXJOB_STATUS_PROCESSING = 'Processing';
   Public static final string ASYNCAPEXJOB_STATUS_PREPARING = 'Preparing';
   //string to display message if there is no test class failures.
   public static final string NO_TEST_FAILURES = 'There are no unit test failures.';
   public static final string EMAIL_SENDER_NAME = 'Test Class Execution';
   public static final string EMAIL_SUBJECT = 'Salesforce Automated Test Class Execution Notification:';
   public static final string FAILED_MESSAGE = 'The Automated Test Class Execution Batch has ';
   public static final string BATCH_JOB_QUEUED = 'The Automated Test Class Execution Batch is rescheduled due to delay.Current status is ';
   Public set<Id> asyncApexJobIdSet = new set<Id>();//set to store asyncApexJobId.
   Public string query;//dynamic query for query the results from ApexTestResult table.
   Public string statusOfAsyncApexJob;//String to store the status of asyncApexJob object(Completed,Failed,Aborted).
   Public string emailBody = '';//string to combine email header table,fail result table and pass result table.
   
// =====================================================================================================================================================================
// S.T.A.R.T = M.E.T.H.O.D
// =====================================================================================================================================================================

    global database.querylocator start(Database.BatchableContext BC) { //start method will run a dynamic query to get result from apextestresult object.
        list<AsyncApexJob> asyObjList = [select id,JobType,Status from AsyncApexJob where id IN:asyncApexJobIdSet];
        If(!asyObjList.isEmpty()) {
            statusOfAsyncApexJob = asyObjList[0].Status;
        }
        query = 'SELECT id,Outcome,ApexClass.Name,MethodName,Message,StackTrace,ApexClassId,TestTimestamp FROM ApexTestResult WHERE AsyncApexJobId IN: asyncApexJobIdSet';      
        return Database.getQueryLocator(query);
    }
    
// ======================================================================================================================================================================
// E.X.E.C.T.E = M.E.T.H.O.D
// ======================================================================================================================================================================

    
   global void execute(Database.BatchableContext BC, List<sObject> scope) {//this method is used to get the result from apextestresult object,storing the results in string and then emailing the results.
       if(statusOfAsyncApexJob == ASYNCAPEXJOB_STATUS_COMPLETED) {//Execute this block only is the result of AsyncApexJob is "Completed".
           //strings used to store class name,method name,results of test classes executed successfully.
           string passTable = '';
           //strings used to store class name,method name,results of test classes which are failed.
           string failTable = '';
           string displayNoFailMssg = '';//string to display error result.
           string displayEmailHeader = '';//string to display email header.
           string displayEmailFailure = '';//string to display failure table.
           string displayEmailSuccessResult = '';//string to display success table.
           integer testFailureCount = 0;//Integer to store count of unit test failures.
           integer testSuccessCount =0;//Integer to store count of success failures.
           map<Id,List<ApexTestResult>> classIdResultMap = new map<Id,List<ApexTestResult>>();//Map to store class id and ApexTestResult object.
           
           for(sObject s : scope){
               ApexTestResult results = (ApexTestResult)s;
               if(classIdResultMap.ContainsKey(results.ApexClassId)) {//If the class id is present in the map then add result as its value.
                   classIdResultMap.get(results.ApexClassId).add(results);
               } else {//else if classId is not present in map then add the classId as key and result object as value.
                   classIdResultMap.put(results.ApexClassId,new List<ApexTestResult>{results});
               }
           }
           if(!classIdResultMap.isEmpty()) {//checking the size of the map before executing the query.
               for(ApexClass apexClassObj : [select id,Name from ApexClass where Id IN: classIdResultMap.KeySet()]) {
                   for(ApexTestResult apexResultObj : classIdResultMap.get(apexClassObj.id)) {//If the result is pass then binding the results in string.
                       if(APEXTESTRESULT_OUTCOME_PASS.equalsIgnoreCase(apexResultObj.Outcome) ) {
                           passTable += '<tr>' +'<td align="center" width="20%">'+'<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+apexResultObj.ApexClass.Name+'</b>'+
                                            '</td><td align="center" width="20%">'+'<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+apexResultObj.MethodName+'</b>'+
                                            '</td><td align="center" width="20%">'+'<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+'Pass'+'</b>'+
                                            '</td><td align="center" width="20%">'+'<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+'- None -'+'</b>'+
                                        '</td></tr>';                             
                           testSuccessCount++;
                       } else if(APEXTESTRESULT_OUTCOME_FAIL.equalsIgnoreCase(apexResultObj.Outcome) ||  APEXTESTRESULT_OUTCOME_COMPLIE_FAIL.equalsIgnoreCase(apexResultObj.Outcome)) {//else adding the result to fail string.
                           failTable += '<tr> <td align="center" width="20%" height="40">'+'<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+apexResultObj.ApexClass.Name+'</b>'+
                                            '</td><td align="center" width="20%" height="40">'+'<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+apexResultObj.MethodName+'</b>'+
                                            '</td> <td align="center" width="20%" height="40">'+'<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+apexResultObj.Message+'</b>'+
                                            '</td> <td align="center" width="20%" height="40">'+'<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+apexResultObj.StackTrace+'</b>'+
                                        '</td> </tr>' ;  
                           testFailureCount++;
                       } 
                   }
               }
           }
           
           //displayEmailHeader string will contain the success and failure count.
           displayEmailHeader = '<table width="100%" cellpadding="10" cellspacing="1" bgcolor="#A9A9F5">' +
                              '<tr>'+
                                  '<td width="100%" align="center">'+'<b style="font-size: x-large; font-style: italic; font-variant:small-caps;">'+
                                  'Apex Test Execution  '+ '(' +String.valueOf(Date.today())+ ')' +'<br/>' +
                                  '</b>'+
                                  '<table width="10%" cellpadding="5" cellspacing="1" bgcolor="#A9A9F5" >' +
                                  '<tr>' +
                                      '<th align="center" bgcolor="#58ACFA">' +
                                      '<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+'Success '+ '</b>'+
                                      '</th>'+
                                      '<th align="center" bgcolor="#58ACFA">' +
                                      '<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+'Fail'+ '</b>'+
                                      '</th>'+
                                  '</tr>' +
                                  '<tr>' +
                                      '<td align="center" bgcolor="#D8F6CE">' +
                                      '<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+ testSuccessCount + '</b>'+
                                      '</td>'+
                                      '<td align="center" bgcolor="#F5A9A9">' +
                                      '<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+ testFailureCount + '</b>'+
                                      '</td>'+
                                  '</tr>' +
                                  '</table>' +
                                  '</td>'+
                              '</tr>'+
                          '</table>';
           if(testFailureCount > 0) {//If the testFailureCount is greater then 0 then adding the failed classes name.
               displayEmailFailure = '<table width="100%" cellpadding="10" cellspacing="0" bgcolor="#F5A9A9" border="2">' +
                                     '<tr>' +
                                         '<th align="center" bgcolor="#58ACFA" width="20%">' +
                                         '<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+'Class'+ '</b>'+
                                         '</th>'+
                                         '<th align="center" bgcolor="#58ACFA" width="20%">' +
                                         '<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+'Method'+ '</br>' +
                                         '</th>'+ 
                                         '<th align="center" bgcolor="#58ACFA" width="20%">' +
                                         '<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+'Message'+ '</br>' +
                                         '</th>'+ 
                                         '<th align="center" bgcolor="#58ACFA" width="20%">' +
                                         '<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+'Failures'+ '</br>' +
                                         '</th>'+ 
                                     '</tr>'+
                                     failTable +
                                     '</table>';
           } else {//else displaying the error message no test class failure.
               displayEmailFailure = NO_TEST_FAILURES;
           }
           //displayEmailSuccessResult string to displaying the classes that are success.
           displayEmailSuccessResult = '<table width="100%" cellpadding="10" cellspacing="0" bgcolor="#D8F6CE" border="2">' +
                                       '<tr>' +
                                           '<th align="center" bgcolor="#58ACFA" width="20%">' +
                                           '<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+'Class'+ '</b>'+
                                           '</th>'+
                                           '<th align="center" bgcolor="#58ACFA" width="20%">' +
                                           '<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+'Method'+ '</br>' +
                                           '</th>'+ 
                                           '<th align="center" bgcolor="#58ACFA" width="20%">' +
                                           '<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+'Message'+ '</br>' +
                                           '</th>'+ 
                                           '<th align="center" bgcolor="#58ACFA" width="20%">' +
                                           '<b style="font-size = "5"; font-style: oblique; font-variant:normal;">'+'Failures'+ '</br>' +
                                           '</th>'+ 
                                       '</tr>'+
                                       passTable +                                 
                                       '</table>';
           //String for combining all the data together.
           emailBody = '<!DOCTYPE html>' +
                  '<html>' +
                  '<head>'+
                  '</head>' +
                  '<meta http-equiv="Content-Type" content="text/html; charset=us-ascii">' +
                  '<style type="text/css">.table,th,td{border:2px solid black;}' + '</style>' +
                      '<body>'+
                          displayEmailHeader +
                          '<br/>'+
                          '<table width="100%" cellpadding="10" cellspacing="0" border="0" bgcolor="#58ACFA">'+
                              '<tr>'+
                              '<td width="100%" align="center">'+'<b>'+'Fail Unit Test. ' + '</b>' + '<b style="font-size = "5"; font-style: oblique; font-variant:normal; font-color ="red";>' +displayNoFailMssg + '</b>' +
                              '</td> '+        
                              '</tr>'+
                          '</table>'+
                          '<br/>' +
                              displayEmailFailure +
                          '<br/>' +
                          '<table width="100%" cellpadding="10" cellspacing="0" border="0" bgcolor="#58ACFA">'+
                              '<tr>'+
                              '<td width="100%" align="center">'+'<b>'+'Success Unit Test'+'</b>'+
                              '</td> '+ '<br/>' +
                          '</tr>'+
                          '</table>'+
                          '<br/>' +
                              displayEmailSuccessResult+
                          '<br/>'+
                      '</body>'+
                  '</html>';
           sendEmailToAddress(emailBody);//Calling send email method and passing the result as parameter.
       } 
   }
   
// =====================================================================================================================================================
// M.E.T.H.O.D
// @param :String finalEmailBody :String conatins the result of classes.
//         
// =====================================================================================================================================================

   Public void sendEmailToAddress(string finalEmailBody) {
       integer i =0;
       String emailIdCS;
       List<String> splitEmailIds = new List<String>();
       list<TestClassExecutionCS__c> customSettingObj = TestClassExecutionCS__c.getall().values();//Custom setting used to store the email ids to which email should be send.
       string[] emailsAsArray = new string[customSettingObj.size()];
       for(TestClassExecutionCS__c s : customSettingObj) {
           splitEmailIds.add(s.Email__c);
       }
       //Converting the list to array.
       for(String s : splitEmailIds) {
           emailsAsArray[i++] = s;
       }
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       if(emailsAsArray != null ) {
           mail.setSenderDisplayName(EMAIL_SENDER_NAME);
           //mail.setReplyTo(emailsAsArray);
           mail.setToAddresses(emailsAsArray);
           mail.setSubject( EMAIL_SUBJECT + ' '+ String.valueOf(Date.today()));
           mail.setHtmlBody(finalEmailBody);
           Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
       }
   }
   
// ===================================================================================================================================
// = M.E.T.H.O.D.S
// ===================================================================================================================================
      public static void mailAnyException(String fileName, String subject, Exception e) {//Method to send email in case of any failures.
          User activeUser = [Select Email From User where id = : userInfo.getUserId() limit 1];
          String userEmailId = activeUser.Email;
          if(userEmailId != null) {
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
              mail.setToAddresses(new string[]{userEmailId});
              mail.setSenderDisplayName('Apex error message');
              mail.setSubject(fileName + ' : ' + subject + ' User Name : ' + UserInfo.getUserName());
              mail.setPlainTextBody(e.getMessage());
              Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
          }    
    }
   

// ===================================================================================================================
// F.I.N.I.S.H = M.E.T.H.O.D
// ===================================================================================================================

   global void finish(Database.BatchableContext BC) {
       if(statusOfAsyncApexJob == ASYNCAPEXJOB_STATUS_ABORTED || statusOfAsyncApexJob == ASYNCAPEXJOB_STATUS_FAILED) {
           emailBody = FAILED_MESSAGE + statusOfAsyncApexJob;//Setting the string values as failed if asyncapexjob is aborted or failed.
           sendEmailToAddress(emailBody);
       } else if(statusOfAsyncApexJob == ASYNCAPEXJOB_STATUS_QUEUED || statusOfAsyncApexJob == ASYNCAPEXJOB_STATUS_PROCESSING || statusOfAsyncApexJob == ASYNCAPEXJOB_STATUS_PREPARING) {//If the result of AsyncApexJob is "preparing" or "processing" then again reschedule the job.
           emailBody = BATCH_JOB_QUEUED + statusOfAsyncApexJob ;
           sendEmailToAddress(emailBody);
           BC_00TestClassResultGenerator resultClass = new BC_00TestClassResultGenerator();
           resultClass.asyncApexJobIdSet = asyncApexJobIdSet;
           system.scheduleBatch(resultClass,'Rescheduled - BC_00TestClassResultGenerator',30);
       }
   }
}
/******************************************************************************************************************
*                     RT LIBRARY – Technical Goods                                                                *
*                                                                                                                 *
*                     © 2008 - Accenture - All Rights Reserved                                                    *
*******************************************************************************************************************/