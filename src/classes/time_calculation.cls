/* Version History
Aug 14th 2013:ITS-000053-- Commented out code and updated new fields 
                           on history object to track user availibility changes individually.
   Deployment Date: 20th August 2013
*/
public with sharing class time_calculation {
    
   
    
    public static Integer duration_between_two_date_times(DateTime start_date_time, DateTime end_date_time) {
      if(start_date_time != null && end_date_time != null) { 
       
        Integer start_year_as_int = start_date_time.year(); //grab the start year

        Integer start_day_as_int = start_date_time.dayOfYear(); //grab the start day
        Integer start_hour_as_int = start_date_time.hour(); //grab the start hour
        Integer start_minute_as_int = start_date_time.minute(); //grab the start minute
        Integer start_second_as_int = start_date_time.second(); //grab the start second
        Integer start_in_seconds = (start_year_as_int * 31556926) + (start_day_as_int * 86400) + (start_hour_as_int * 3600) + (start_minute_as_int * 60) + (start_second_as_int * 1); //convert the start date to a value in seconds
        //there are 31556926 seconds in one year and that is why we are mutiplying the start_year_as_int value by 31556926 > this same logic applies to the days, hours & minutes logic which is why there are weird multipliers in that line of code
        Integer end_year_as_int = end_date_time.year(); //grab the end year
        Integer end_day_as_int = end_date_time.dayOfYear(); //grab the end day
        Integer end_hour_as_int = end_date_time.hour(); //grab the end hour
        Integer end_minute_as_int = end_date_time.minute(); //grab the end minute
        Integer end_second_as_int = end_date_time.second(); //grab the end second
        Integer end_in_seconds = (end_year_as_int * 31556926) + (end_day_as_int * 86400) + (end_hour_as_int * 3600) + (end_minute_as_int * 60) + (end_second_as_int * 1); //convert the end date to a value in seconds
       
        Integer total_duration_in_seconds = end_in_seconds - start_in_seconds; //duration in seconds
        return total_duration_in_seconds ;
        }
         return null;
        

      
    }
    
    /*
      Method to create or update record in User History object
      */
    public static void createRecord(User userRecord ){
        
        
        Integer duration = duration_between_two_date_times(userRecord.Start_Time__c , userRecord.User_End_Time__c );
        /* Begin:Commented out code as part of Requirement number ITS-000053 */
        // List<User_History__c> historyList = [select name__c,Duration__c,Availability__c,Manager__c,Duration_Time__c from User_History__c where User_Id__c =: userRecord.id and Availability__c =:userRecord.Availability__c and createdDate = TODAY];
      /* Begin:Commented out code as part of Requirement number ITS-000053 */
      
       
        List<User_History__c> existingHistoryRecordList = new List<User_History__c>();
       /* Begin:Commented out code as part of Requirement number ITS-000053 */
       /* ram if(historyList.isEmpty() && historyList.size() < 1){
       */ 
       /* Begin:Commented out code as part of Requirement number ITS-000053 */
            User_History__c historyRecord = new  User_History__c();
            if(duration != null){
                historyRecord.Duration__c = duration;
                historyRecord.Name__c = userRecord.FirstName;
                System.debug('Name:::'+ historyRecord.Name__c);
                historyRecord.Availability__c =userRecord.Availability__c;
                historyRecord.Manager__c  = userRecord.ManagerId;
                historyRecord.User_Id__c = userRecord.Id;
                 /* ram*/ historyRecord.Start_Time__c=userRecord.Start_Time__c;
                historyRecord.User__c=userRecord.Id;
                profile p=[select name from profile where id=:userinfo.getProfileId()];
                historyRecord.User_Profile__c = p.name;                
                historyRecord.Duration_Time__c = getTimeField(duration);
                historyRecord.End_Time__c= system.now();
                
                insert historyRecord;
            }
       /* Begin:Commented out code as part of Requirement number ITS-000053 to prevent updation of same rows*/
      /*  
      }else{
            for(User_History__c existingHistoryRecord:historyList){
            system.debug('!!!!!!!!!!!');
                Integer pastDuration = Integer.valueOf(existingHistoryRecord.Duration__c);
                existingHistoryRecord.Duration__c = pastDuration + duration;
                existingHistoryRecord.Duration_Time__c = getTimeField(pastDuration + duration);
                existingHistoryRecord.Manager__c  = userRecord.ManagerId;
                existingHistoryRecord.Availability__c =userRecord.Availability__c;
                existingHistoryRecordList.add(existingHistoryRecord);
            }
                update existingHistoryRecordList;
        }*/
        /* Begin:Commented out code as part of Requirement number ITS-000053 prevent updation of same rows*/
    }
    
    public static String getTimeField(Integer totalSeconds){
        Integer inputValue = totalSeconds; // value of Duration field from User History object
        Integer GET_HOURS= 3600;
        Integer GET_MINUTES=60;
        Integer hours = inputValue/GET_HOURS;
        String strHr;
        String strMn;
        String strSc;
        if(hours < 10){
            strHr = 0+ String.valueOf(hours);
        }else{
            strHr = String.valueOf(hours);
        }
            
        Integer minutes = math.mod(inputValue, GET_HOURS)/GET_MINUTES;
        if(minutes < 10){
            strMn = 0+ String.valueOf(minutes);
        }else{
            strMn = String.valueOf(minutes);
        }
        
        Integer seconds = math.mod(math.mod(inputValue, GET_HOURS), GET_MINUTES);
        if(seconds < 10){
            strSc = 0+ String.valueOf(seconds);
        }else{
            strSc = String.valueOf(seconds);
        }
        List<String> timeValues = new List<String>{strHr,strMn,strSc};
        return String.join(timeValues,':');         
    }

}