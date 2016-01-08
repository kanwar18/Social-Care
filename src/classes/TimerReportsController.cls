public class TimerReportsController {
    public static Map<Id, SObject> caseMap {get; set;}
    public static Map<String, TimerReportsHandler.CaseHandlingReportWrapper> cmMapCtrl {get; set;}
    
    //method leveraged by the GUI - for Avg Case handling time
    public List<TimerReportsHandler.CaseHandlingReportWrapper> getAvgCaseHandleTimePerCM() {
            return TimerReportsHandler.calAvgCaseHandleTimePerCM();
    }
    
    //method leveraged by the GUI - for Avg Case handling time
    public Map<String, List<TimerReportsHandler.CaseHandlingReportWrapper>> getTransactionsByUser() {
        return TimerReportsHandler.calHandleTimeByActivityPerCM();
    }
    
    //method leveraged by the GUI - for Avg Case handling time for Operations team
    public Map<String, List<TimerReportsHandler.CaseHandlingReportWrapper>> getCaseHandlingPerTeam() {
        return TimerReportsHandler.calHandleTimePerOM();
    }    
    
    //method leveraged by the GUI - for Avg Case handling time for Operations team
    public static Map<String, Map<String, Map<String,TimerReportsHandler.CaseHandlingReportWrapper>>>
        getCaseHandlingByTimePeriod() {
        return TimerReportsHandler.calHandleTimePerTimePeriod();
    } 
    
    //method to populate the report names on the GUI
    public static List<ReportNameWrapper> getReportNames() {
        List<ReportNameWrapper> reportWrapperList = new List<ReportNameWrapper>();
        try {
            for(Integer reportCount = 0; reportCount < TimeTrackConstants.REPORT_NAMES.size(); reportCount++) {
                reportWrapperList.add(new ReportNameWrapper(
                        (reportCount + 1), 
                        TimeTrackConstants.REPORT_NAMES[reportCount],
                        TimeTrackConstants.REPORT_PAGE_NAMES[reportCount]
                ));
            }
        } catch(Exception excep) {
                TimeTrackUtility.doPrintExceptionMsg(excep);
        }
        
        return reportWrapperList;
    }
    
    public class ReportNameWrapper {
        public Integer reportNumber {get; set;}
        public String reportName {get; set;}
        public String reportPage {get; set;}
        
        public ReportNameWrapper(Integer reportNumber, String reportName, String reportPage) {
                this.reportNumber = reportNumber;
                this.reportName = reportName;
                this.reportPage = reportPage;
        }
        
        override
        public String toString() {
                return reportName +' ' + reportPage;
        }
    }
}