/**
* A Schedulable class to update the case fields (fields related to the social post)
**/
global class SocialCarePostDataScheduler implements Schedulable {
	
	/**
	* @param context - a schedulable context 
	**/
	global void execute(SchedulableContext context) {
		new SocialCareBatchClient(TimeTrackConstants.CASE_FIELDS_UPDATE).doStartBatch();
	}
}