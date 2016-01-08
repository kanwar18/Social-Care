/**
* A batch handler class
*/
public class SocialCareBatchHandler {
	
	/**
	* method to delete the timer track records for who's there is no transaction end date
	*/
	public void doDeleteTimerTrackWoEndDate(List<SObject> objectsList) {
		delete objectsList;
		Database.emptyRecycleBin(objectsList);
	}
}