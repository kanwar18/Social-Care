public class TimeTrackUtility {
	
	//method to get print the exception msg
	public static void doPrintExceptionMsg(Exception excep) {
		System.debug('Exception Caught:'+excep.getMessage()+', @Line#'+excep.getLineNumber());
	}
	
	//method to print the custom msg
	public static void doPrintCustomMessage(String customMsg) {
		System.debug('************ '+ customMsg+' ************');
	}
	
	//method to insert the case timer record
	public static void doInsertTimeRecord(Id userId, Case caseObj, String initialTransaction) {
		TimerTrack__c timeTrackObj = null;
		if(null != userId && null != caseObj) {
            timeTrackObj = new TimerTrack__c(
                Transaction_Performed_By__c = userId,
                Transaction_Start_Date__c = DateTime.now().addSeconds(-2),
                Related_Case__c = caseObj.Id,
                Case_Status__c = caseObj.Status,
                User_Availability_Status__c = TimeTrackHelper.getCurrentUserInfo().Availability__c,
                Transaction_Type__c = initialTransaction
            );
            insert timeTrackObj;
            Social_CaseAssignmentUtility.executeTriggerCode = false;
		}	
	}
	
	//method to get the user availability status
	public static boolean doValidUserAvailabilityStatus() {
		return buildSetFromArray
			(Label.TIMER_START_STATUSES.split(','))
			.contains(TimeTrackHelper.getCurrentUserInfo().Availability__c) 
				? true : false;
	}
	
	// a method to build a set collection by leveraging an array of string's
	public static Set<String> buildSetFromArray(String[] stringArr) {
		Set<String> stringSet = new Set<String>();
		if(stringArr != null && stringArr.size() > 0) {
			for(String itemStr : stringArr) {
				stringSet.add(itemStr);
			}
		}
		return stringSet;
	}
	
	//method used to convert the # of days to readableformat
	public static String doDateReadable(Decimal noOfDaysVal) {
		String readableDate = '';
        Integer noOfDays = (Integer) Math.floor(noOfDaysVal);
        Integer noOfHours = (Integer) Math.floor(24*(noOfDaysVal - Math.floor(noOfDaysVal)));
        Double noOfMinutes = 
            60 * ((24*(noOfDaysVal - Math.floor(noOfDaysVal))) - Math.floor((24*(noOfDaysVal - Math.floor(noOfDaysVal)))) );
		readableDate = noOfDays +' Days, '+noOfHours+' Hours, ' + doConvertMinutesToReadbleString(noOfMinutes);
		return readableDate;
	}
	
	//Method to convert to String
	public static String doConvertMinutesToReadbleString(Double noOfMinutesVal) {
		String minutesStr = String.valueOf(noOfMinutesVal);
		String noOfMinutes = '';
		String noOfSeconds = '';
		
		if(minutesStr.length() > 0) {
			noOfMinutes = minutesStr.subString(0, minutesStr.indexOf('.'));
			noOfSeconds = minutesStr.subString(minutesStr.indexOf('.'), minutesStr.length());
		}
		
		return noOfMinutes +' Minutes, ' +Math.round((Double.valueOf(noOfSeconds) * 60)) + ' Seconds';
	}
	
	
	//A method which converts the calendar year and month to the readable format
	public static String doConvertCalendarMonthAndYear(Integer calMonth, Integer calYear) {
		final String[] monthNamesArr = new String[] {'January','February','March','April',
			'May','June','July','August','September','October','November','December'};
		return monthNamesArr[calMonth - 1] +' '+ calYear;
	}
	
	//A method to convert to Month to the numeric
	public static Integer doConvertCalendarMonth(String calMonthStr) {
        Integer objCounter = -1;
		final String[] monthNamesArr = new String[] {'January','February','March','April',
			'May','June','July','August','September','October','November','December'};
		String[] calMonth = calMonthStr.split(' ');
		for(Integer counter = 0; counter < monthNamesArr.size(); counter++){
			if(monthNamesArr[counter].contains(calMonth[0])) {
				objCounter = counter;
                break;
			}
		}
		return objCounter;
	}
}