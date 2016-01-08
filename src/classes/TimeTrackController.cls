public class TimeTrackController {
    Case caseObj = null;
    Public string caseNumberString{get;set;}
    
    //Cons with stdctrl as a param
    public TimeTrackController(ApexPages.StandardController controller) {
        if(caseObj == null && null != controller) {
            caseObj = (Case) controller.getRecord();
        }
    }
   
   //method which starts the transaction 
   public void doCaseOpenTime() {
       if(null != caseObj && (Boolean.valueOf(Label.ACTIVATE_TIMER_APP))) {
           new TimeTrackHelper()
           .doValidateCaseRecord(caseObj,SYSTEM.LABEL.Timertrackaceess, 'Consumer Care', 'Case View');
       }
   }
}