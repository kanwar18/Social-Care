/*
*                                                                             *
*                                 Version 1.00                                *
*                                                                             *
* Creation Date: 16.Sept.2013                                  Aditya Kumar   *
* Last Modified: 16.Sept.2013                                  Aditya Kumar   *
*                                                                             *
*                             © 2008 - Accenture - All Rights Reserved        *
*/

Global Class SC00_TestClassExecuter implements Schedulable {
    Public static final string SEARCH_ISTEST = '@isTest';
    Public static final string SEARCH_TEST_METHOD = 'testMethod';
    
    global void execute(SchedulableContext SC) {
        enqueueTests(); 
    }
        
// ============================================================================================================================================================================
// = M.E.T.H.O.D.S
// ============================================================================================================================================================================
     
     public void enqueueTests() { // This method is used to enqueue all classes which has "test method" or "@istest" in there body and add to a list and insert a new queue item. 
         list<ApexTestQueueItem> queueItems = new list<ApexTestQueueItem>();
         set<Id> asyncApexJobIdSetRunner = new set<Id>();//Set to store the ParentJobId.
         list<ApexClass> resultsTempClass = new list<ApexClass>();//List of all the classes order by name.
         list<ApexClass> resultsAllClass = new list<ApexClass>();//List of classes which contains @istest or testmethod in their body.
         string compateString = '';//String the store body.
        
         resultsTempClass = [SELECT Id,Name,Body from ApexClass ORDER BY name limit 10000 ];//querying all the classes order by name.
         for(integer i=0 ; i < resultsTempClass.size() ; i++) { //loop to check if class contains "@isTest" or "testMethod" then adding it to list.
             compateString = resultsTempClass[i].body;
             if(compateString.containsIgnoreCase(SEARCH_ISTEST) || compateString.containsIgnoreCase(SEARCH_TEST_METHOD)) {
                 resultsTempClass[i].body = null;
                 resultsAllClass.add(resultsTempClass[i]);   
             }
         }

        if(!resultsAllClass.IsEmpty()) {
            for(ApexClass cls : resultsAllClass) {
                queueItems.add(new ApexTestQueueItem(ApexClassId=cls.Id));
            }
            try {
                insert queueItems;//inserting queueItem for running the test classes.
            } catch(Exception e) {
                mailAnyException('SC00_TestClassExecuter','FailedToInsertQueueItem',e);
            }
            //Get the job ID of the first queue item returned.
            for(ApexTestQueueItem apexQueueItemObj : [SELECT ParentJobId FROM ApexTestQueueItem WHERE Id=:queueItems[0].Id  LIMIT 1]) {
                asyncApexJobIdSetRunner.add(apexQueueItemObj.ParentJobId);//Adding parentjobId to the list and passing the list to TestClassExecutionAutomationResult.
            }
        }
        //Scheduling BC_00TestClassResultGenerator batch class to run after specific time and email the results.
        if(!asyncApexJobIdSetRunner.isEmpty()) {
            try {        
                BC_00TestClassResultGenerator resultClass = new BC_00TestClassResultGenerator();
                resultClass.asyncApexJobIdSet = asyncApexJobIdSetRunner;
                system.scheduleBatch(resultClass,'BC_00TestClassResultGenerator',20);
            } catch(Exception e) {
                mailAnyException('SC00_TestClassExecuter','FailedToSchedule',e);
            }
        }
      }
// =====================================================================================================================================================
// = M.E.T.H.O.D.S
// =====================================================================================================================================================
      public static void mailAnyException(String fileName, String subject, Exception e){//Method to send email in case of any failures.
          User activeUser = [Select Email From User where id = : userInfo.getUserId() limit 1];//Querying email of logged in userid.
          String userEmailId = activeUser.Email;//To store the email id of the user.
          if(userEmailId != null) {
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
              mail.setToAddresses(new string[]{userEmailId});
              mail.setSenderDisplayName('Apex error message');
              mail.setSubject(fileName + ' : ' + subject + ' User Name : ' + UserInfo.getUserName());
              mail.setPlainTextBody(e.getMessage());
              Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
          }    
      }
}
/******************************************************************************************************************
*                     RT LIBRARY – Technical Goods                                                                *
*                                                                                                                 *
*                     © 2008 - Accenture - All Rights Reserved                                                    *
*******************************************************************************************************************/