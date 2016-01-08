@isTest(seeAllData = true)
private class SocialCareMisce {
	static User userObj;
	
	static {
			userObj = [Select Id, Start_Time__c,User_End_Time__c,FirstName,Availability__c,ManagerId from User Where isActive = true Limit 1];
	}
	
	static testMethod void timeCalculationTest() {
		System.assertNotEquals(time_calculation.duration_between_two_date_times(System.now(), System.now() + 2), 0);
		String strLength = Time_Calculation.getTimeField(1000);
		System.assertNotEquals(strLength.length(), 0);
		
		Time_Calculation.createRecord(userObj);
	}	
}