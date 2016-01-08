/**
 * A controller class which is reponsible to compute the handle time by customers perspective
 */
public class R6CaseTimerReportController {
        
        public List<R6CaseTimerReportHandler.ProductMonthAverage> monthList {get; set;}
        public List<R6CaseTimerReportHandler.ProductMonthAverage> monthProdList {get; set;}
        public Map<String, R6CaseTimerReportHandler.R6CaseTimeComputeWrapper> avgCustMapGlobal {get; set;}
        public String grandTotalStr {get; set;}
        
        /**
         * Default Cons
         */
        public R6CaseTimerReportController() {
        }
        
        /**
         * Method used to get the avg response
         */
        public void getCaseAvgResCustPer() {
            try {
                    avgCustMapGlobal = R6CaseTimerReportHandler.calAvgResCustPer();
                    doProcessAvgMap();
            } catch(Exception excep) {
                    TimeTrackUtility.doPrintExceptionMsg(excep);
            }
        }
        
        /**
         * Method used to process the results
         */
        public void doProcessAvgMap() {
            Map<String, R6CaseTimerReportHandler.R6CaseTimeComputeWrapper> avgLocalMap = avgCustMapGlobal;
            Double prodYearTot = 0.0;
            monthProdList = new List<R6CaseTimerReportHandler.ProductMonthAverage>();
            Double grandTotal = 0.0;
            grandTotalStr = null;
            R6CaseTimerReportHandler.MonthWiseAvgWrapper monthWrap = null;
            Integer cumCaseCount = 0;
            
            if(null != avgCustMapGlobal) {
	            for(String productKey : avgCustMapGlobal.keySet()) {
	                monthList = avgCustMapGlobal.get(productKey).productMonthList;
	                break;
	            }
	            
	            Set<String> productKeySet = avgCustMapGlobal.keySet();
	            for(R6CaseTimerReportHandler.ProductMonthAverage monthYearKey : monthList) {
	                prodYearTot = 0.0;
	                cumCaseCount = 0;
	                for(String prodKey :productKeySet) {
	                	monthWrap = avgLocalMap.get(prodKey).monthWiseAverage.get(monthYearKey.monthName);
	                    prodYearTot += monthWrap.monthSum;
	                    cumCaseCount += monthWrap.noOfCases;
	                }
	                prodYearTot = prodYearTot / cumCaseCount;
	                monthProdList.add(new R6CaseTimerReportHandler.ProductMonthAverage(monthYearKey.monthName, prodYearTot, cumCaseCount));
	                grandTotal += prodYearTot;
	            }
	            monthProdList.sort();
	            grandTotalStr = TimeTrackUtility.doDateReadable(grandTotal);
            }
        }
}