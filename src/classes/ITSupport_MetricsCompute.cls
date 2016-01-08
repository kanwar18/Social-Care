/**
    @author Sasikala.Murugesan
*/

public  class ITSupport_MetricsCompute {
    public String id {get;set;}
    public String totalResolutionTime;

    public ITSupport_MetricsCompute(ApexPages.StandardController controller){
             
    }
    public String ticketId = System.currentPageReference().getParameters().get('id');
    
    /** This method computes the time taken to resolve a ITSupport ticket.
        That is, how long the ticket has been put in 'InProgress Status' Plus the time at which the ticket is opened
    */ 
    public void doAction(){
     try{
        List<ID> ticketIDS = new List<ID>();
        List<ITSupport_MetricsPojo> historyList = new List<ITSupport_MetricsPojo>();
        List<IT_Support_Ticket__History> ticketHistoryList = new List<IT_Support_Ticket__History>();
        IT_Support_Ticket__c ticketObj = new IT_Support_Ticket__c();
        DateTime progressEntry = null;
        DateTime progressExit = null;
        Integer returnedSeconds;
        Integer seconds = 0;
        Integer singleRecordSecond = 0;
        DateTime ticketOpened = null;
        DateTime openToProgress = null;
        Integer openToProgressSeconds;
        ticketHistoryList= ([SELECT newValue, oldValue, createdDate,field FROM IT_Support_Ticket__History where 
                parentId =:ticketId and field = 'Status__c' order by createdDate]);
        ticketObj = [SELECT Name,CreatedDate FROM IT_Support_Ticket__c where id = :ticketId];
        ticketOpened = ticketObj.CreatedDate;
        if(ticketHistoryList.size() > 0){
            for(IT_Support_Ticket__History ticketHistory : ticketHistoryList){
                if(ticketHistory.NewValue == 'In Progress' && openToProgress == null){
                    openToProgress = ticketHistory.CreatedDate;
                    // Duration between the Status "Open To InProgress"
                    openToProgressSeconds = durationBetweenDate(ticketOpened,openToProgress); 
                }
                if(ticketHistory.newValue == 'In Progress' || ticketHistory.oldValue == 'In Progress'){
                    ITSupport_MetricsPojo helperObj = new ITSupport_MetricsPojo();          
                    helperObj.newValue = (String)ticketHistory.newValue;
                    helperObj.oldValue = (String)ticketHistory.oldValue;
                    helperObj.statusChanged = ticketHistory.createdDate;
                    historyList.add(helperObj);
                }
            }
        }
        if(historyList.size() > 0){
            for( Integer i = 0 ; i< historyList.size(); i++){
                ITSupport_MetricsPojo ticketHistory = (ITSupport_MetricsPojo)historyList.get(i);
                progressEntry = ticketHistory.statusChanged;
                Integer j = i + 1;
                if(historyList.size() == j){
                   // When there is no status change from InProgress
                    returnedSeconds = durationBetweenDate(progressEntry, System.now());
                    if(returnedSeconds == 0 || returnedSeconds > 0){
                        singleRecordSecond = 0 + returnedSeconds;
                    }
                        break;
                }
                ITSupport_MetricsPojo ticketHistoryOne = (ITSupport_MetricsPojo)historyList.get(j);
                progressExit = ticketHistoryOne.statusChanged;
                // When there is a status change from InProgress
                returnedSeconds = durationBetweenDate(progressEntry, progressExit);
                    if(seconds == 0)
                        seconds = 0 + returnedSeconds;
                    else
                        seconds = seconds + returnedSeconds;
                i = i+1;
             } //For Loop ends
        }
            
        if((singleRecordSecond == 0 || singleRecordSecond > 0 ) && seconds == 0){ 
            seconds = singleRecordSecond; 
        }else if(seconds > 1 && singleRecordSecond == 0){ 
            seconds = seconds;
        }else if((singleRecordSecond == 0 || singleRecordSecond > 0) && seconds > 1){ 
            seconds = seconds + singleRecordSecond;
        }
            // InProgress duration + duration when the ticket is put in InProgress from open 
        if(ticketHistoryList.size() != 0){
            seconds = openToProgressSeconds + seconds;
        }
        if(seconds > 0){
            Integer yearValue = math.mod(math.floor(seconds/31556926).intValue(),10000000); //number of years
            Integer dayValue = math.mod(math.floor(seconds/86400).intValue(),365); //number of days
            Integer hourValue = math.mod(math.floor(seconds/3600).intValue(),24); //number of hours
            Integer minuteValue = math.mod(math.floor(seconds/60).intValue(),60); //number of minutes
            Integer secondValue = math.mod(math.floor(seconds/1).intValue(),60); //number of seconds 
            if(dayValue > 0){
                totalResolutionTime = (dayValue + 'day(s)'+ ' ' + hourValue + 'hr(s)'+ ' ' + minuteValue + 'min(s)' + ' ' + secondValue + 'sec(s)') ;
                System.debug('totalResolutionTime===>' + totalResolutionTime);
             }else if(yearValue > 0){
                totalResolutionTime = (yearValue + 'yr(s)' +' '+ dayValue + 'day(s)'+ ' ' + hourValue + 'hr(s)'+ ' ' + minuteValue + 'min(s)' + ' ' + secondValue + 'sec(s)') ;
                System.debug('totalResolutionTime===>' + totalResolutionTime);
             }else if(hourValue > 0){
                totalResolutionTime = (hourValue + 'hr(s)'+ ' ' + minuteValue + 'min(s)' + ' ' + secondValue + 'sec(s)') ;
                System.debug('totalResolutionTime===>' + totalResolutionTime);
             }else{
                totalResolutionTime = (minuteValue + 'min(s)' + ' ' + secondValue + 'sec(s)') ;
                System.debug('totalResolutionTime===>' + totalResolutionTime);
             }
        }
    }catch(Exception excep){
            System.debug('Exception Caught===> :'+excep.getMessage());
     }
    } // Method Ends
    public Integer durationBetweenDate(DateTime entryTime, DateTime exitTime){
        System.debug('EntryTime===>' + entryTime );
        System.debug('ExitTime===>' + exitTime);
        Integer entryYearAsInt = entryTime.year(); // the start year
        Integer entryDayAsInt = entryTime.dayOfYear(); // the start day
        Integer entryHourAsIint = entryTime.hour(); //the start hour
        Integer entryMinuteAsInt = entryTime.minute(); // the start minute
        Integer entrySecondAsInt = entryTime.second(); // the start second
        Integer entryInSeconds = (entryYearAsInt * 31556926) + (entryDayAsInt * 86400)
         + (entryHourAsIint * 3600) + (entryMinuteAsInt * 60) + (entrySecondAsInt * 1); //convert the start date to a value in seconds
        // Exit
        Integer exitYearAsInt = exitTime.year(); // the start year
        Integer exitDayAsInt = exitTime.dayOfYear(); // the start day
        Integer exitHourAsIint = exitTime.hour(); // the start hour
        Integer exitMinuteAsInt = exitTime.minute(); // the start minute
        Integer exitSecondAsInt = exitTime.second(); // the start second
        Integer exitInSeconds = (exitYearAsInt * 31556926) + (exitDayAsInt * 86400)
         + (exitHourAsIint * 3600) + (exitMinuteAsInt * 60) + (exitSecondAsInt * 1); //convert the start date to a value in seconds
        
        Integer totalDurationInSeconds = exitInSeconds - entryInSeconds; //duration in seconds
    return totalDurationInSeconds;
    }
    // totalResolutionTime returned for VF Page
    public string gettotalResTime(){
       return totalResolutionTime;
     }
        
 }