/**
 * A Batch class to process the various batch jobs
 */
global class SocialCareBatchProcess implements Database.Batchable<Sobject>{
	private String soqlQuery = null;
	private boolean isDelete = false;
	private String batchProcessType = null;
	

	private static final String EMAIL_SUBJECT = 'Batch Process Status: ';
	
	private SocialCareBatchHandler careBatchHandler = new SocialCareBatchHandler();
	
	/**
	 * Cons
	 */
	global SocialCareBatchProcess(String soqlQuery, boolean isDelete, String batchProcessType) {
		if(null != soqlQuery && null != batchProcessType) {
			this.soqlQuery = soqlQuery;
			this.isDelete = isDelete;
			this.batchProcessType = batchProcessType;
		}
	}
	
	/**
	 * Start of the batch job
	 */
	global Database.Querylocator start(Database.BatchableContext batchContext) {
		return Database.getQueryLocator(soqlQuery);
	}
	
	/**
	 * Batch execute
	 */
	global void execute(Database.BatchableContext batchContext, List<SObject> objectsList) {
		try {
			if(null != batchProcessType && batchProcessType.length() > 0) {
				if(batchProcessType.equalsIgnoreCase(TimeTrackConstants.TIMER_TRACK_DELETE)) {
					careBatchHandler.doDeleteTimerTrackWoEndDate(objectsList);
				}
			}
		} catch(Exception excep) {
			TimeTrackUtility.doPrintExceptionMsg(excep);
		}
	}
	
	/**
	 * A method gets executed after the exceute method is exceuted,this is basically used to notify the submitter
	 */
  	global void finish(Database.BatchableContext batchContext) {
	    String[] emailNotify = Label.BATCH_NOTIFICATION.split('\\,');
	    
	    if(Boolean.valueOf(emailNotify[0])) {
		      AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
		        FROM AsyncApexJob WHERE Id = :batchContext.getJobId() Limit 49999];
		      
		      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		      String[] toAddresses = new String[] {emailNotify[1]};
		      mail.setToAddresses(toAddresses);
		      mail.setSubject(EMAIL_SUBJECT + a.Status);
		      mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
		      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	    }    
  	}
		
}