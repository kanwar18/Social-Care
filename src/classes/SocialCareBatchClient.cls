/**
* A Batch Client Class
*/
public class SocialCareBatchClient {
	
	private String batchNameExecute = null;
	
	private static final String POST_SOQL_QUERY = 'Select Id, Posted_Date__c,Harvest_Date__c ,'+
		'(Select Id, Posted, R6Service__HarvestDate__c from Posts Order by CreatedDate Limit 1) '+
		'from Case where (CreatedDate = today or createdDate = yesterday) and Posted_Date__c = null and Harvest_Date__c = null';	
	
	private static final String TIME_TRACK_DEL_QUERY = 'Select Id,CreatedDate from TimerTrack__c Where '+
		'Transaction_End_Date__c = null Order by CreatedDate';				
	
	/**
	* A default cons
	*/
	public SocialCareBatchClient(String batchNameExecute) {
		this.batchNameExecute = batchNameExecute;
	}
	
	/**
	* Method to start the batch
	*/
	public void doStartBatch() {
		String soqlQuery = null;
		boolean isDeleteFlag = false;
		SocialCareBatchProcess batchProcessObj = null;
		
		try {
			if(null != batchNameExecute && batchNameExecute.length() > 0) {
				if(batchNameExecute.equalsIgnoreCase(TimeTrackConstants.CASE_FIELDS_UPDATE)) {
					soqlQuery = POST_SOQL_QUERY;
				} else if(batchNameExecute.equalsIgnoreCase(TimeTrackConstants.TIMER_TRACK_DELETE)) {
					isDeleteFlag = true;
					soqlQuery = TIME_TRACK_DEL_QUERY;
				} else {
					//handle here in near future
				}
				System.debug(batchNameExecute);
				batchProcessObj = new SocialCareBatchProcess(soqlQuery,isDeleteFlag,batchNameExecute);
				Database.executeBatch(batchProcessObj);
			}
		} catch(Exception excep) {
			TimeTrackUtility.doPrintExceptionMsg(excep);
		}
	}
	
}