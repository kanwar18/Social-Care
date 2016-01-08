//A Constant class which holds the constants related to the timer app
public class TimeTrackConstants {

    public static final String[] AUDIT_TRANSACTION_TYPE = new String[] {
        'Audit Started',
        'Audit Submitted'
    };
    
    public static final String[] REPORT_NAMES = new String[] {
        'Average Case Handling Time per Care Manager',
        'Show what Care Managers are doing and time per task during Available and unavailable Admin ',
        'Average case handle time per team, that is,average handle time of cases handled by the Social Media Operations Manager’s team',
        'Average Case handling time per time period (Last 90 Days)',
        'Average response time from Customer perspective overall and by product',
        'Average response time from assignment time overall and by product',
        'Average customer response time per care manager',
        'Average customer response time per product'
    };
    
    public static final String[] REPORT_PAGE_NAMES = new String[] {
        'TimerReportsByManager',
        'TimerByActivity',
        'TimerByOM',
        'TimerByTimePeriod',
        'R6AvgResTime',
        'AvgCMResponseTimeFromAssignment',
        'firstCustResponse',
        'AverageResponseTimePerMonth'
    };
    
    public static final String CASE_FIELDS_UPDATE = 'caseFieldUpdate';
    public static final String TIMER_TRACK_DELETE = 'deleteTimeTrack';
    public static final String STATE_EXECUTING = 'EXECUTING';
    public static final String TIMETRACKDELETE = 'TimerTrackDelete';
}