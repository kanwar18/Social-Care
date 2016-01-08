/**
* A Schedulable class to delete the timer tranactions records (transaction date is null)
**/

global class SoicalCareTimerDataScheduler implements Schedulable {
	global void execute(SchedulableContext context) {
		new SocialCareBatchClient(TimeTrackConstants.TIMER_TRACK_DELETE).doStartBatch();
	}
}