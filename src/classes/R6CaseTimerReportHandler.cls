/**
 * A Handler class for the tot handle time by customers perspective
 */
public class R6CaseTimerReportHandler {
	
	private static final String CAL_YEAR= 'calYear';
	private static final String CAL_MONTH = 'calMonth';
	private static final String PROD_NAME = 'prodName';
	private static final String OWNER_NAME = 'ownerName';
	private static final String CASE_COUNT = 'caseCount';
	private static final String TOT_RESTIME_DAYS = 'totResponseTimeDays';
	private static final String ZERO_STR = '0.0';
	private static final String SUM_OF_RES = 'sumOfResponse';

	/**
	 * Default Cons
	 */
	public R6CaseTimerReportHandler() {
		
	}
	
	/**
	 * Method used to calculate avg response time from customer perspective - By product,overall and by time
	 */
	public static Map<String, R6CaseTimeComputeWrapper>  calAvgResCustPer() {
		Integer calYear = null;
		Integer calMonth = null;
		String prodName = null;
		Integer caseCount = null;
		Double totResponseTimeDays = 0.0;
		Double sumOfResponse = 0.0;
		
		R6CaseTimeWrapper rwrapObj = null;
		Map<String, Map<String,List<R6CaseTimeWrapper>>> avgCustResMap = new Map<String, Map<String,List<R6CaseTimeWrapper>>>();
		
		try {
			
			AggregateResult[] groupResult = [Select CALENDAR_YEAR(First_SLA_Response_Time__c) calYear, 
				CALENDAR_MONTH(First_SLA_Response_Time__c) calMonth,Component_Primary__c prodName,count(Id) caseCount,
				avg(First_Cust_Response__c) totResponseTimeDays,sum(First_Cust_Response__c) sumOfResponse from Case
				Where First_SLA_Response_Time__c <> NULL and 
				Component_Primary__c <> NULL and
				RecordType.Name like '%Consumer%' and 
				RecordType.Name <> NULL and
				Origin IN ('Social Hub','Engagement Console') and
				Owner.Profile.Name = 'Care Manager' and First_Cust_Response__c > 0 and
				First_SLA_Response_Time__c = LAST_90_DAYS
				Group by CALENDAR_YEAR(First_SLA_Response_Time__c), CALENDAR_MONTH(First_SLA_Response_Time__c),
				Component_Primary__c having avg(First_Cust_Response__c) > 0
				Order by CALENDAR_YEAR(First_SLA_Response_Time__c) Desc
			];
		
			for(AggregateResult aggRes : groupResult) {
				calYear = (Integer) aggRes.get(CAL_YEAR);
				calMonth = (Integer) aggRes.get(CAL_MONTH);
				prodName = (String) aggRes.get(PROD_NAME);
				caseCount = (Integer) aggRes.get(CASE_COUNT);
				totResponseTimeDays = (Double) aggRes.get(TOT_RESTIME_DAYS);
				sumOfResponse = (Double) aggRes.get(SUM_OF_RES);
				
				rwrapObj = new R6CaseTimeWrapper(calYear, calMonth, prodName, caseCount, totResponseTimeDays, sumOfResponse);
				
				if(null == avgCustResMap.get(rwrapObj.calendarMonthYear)) {
					avgCustResMap.put(rwrapObj.calendarMonthYear, new Map<String,List<R6CaseTimeWrapper>>());
				}
				
				if(null == avgCustResMap.get(rwrapObj.calendarMonthYear).get(rwrapObj.productName)) {
					avgCustResMap.get(rwrapObj.calendarMonthYear).put(rwrapObj.productName, new List<R6CaseTimeWrapper>());
				}
				
				avgCustResMap.get(rwrapObj.calendarMonthYear).get(rwrapObj.productName).add(rwrapObj);
			}//end for 'for' loop
			
			if(!avgCustResMap.isEmpty()) {				
				return doProcessAvgCustMap(avgCustResMap);
			}
		} catch(Exception excep) {
			TimeTrackUtility.doPrintExceptionMsg(excep);
		}
		return null;
	}
	
	
	/**
	 * Method used to process the avg cust map
	 */
	public static Map<String, R6CaseTimeComputeWrapper> doProcessAvgCustMap(Map<String, Map<String,List<R6CaseTimeWrapper>>> avgCustResMap) {
		Set<String> monthYearSet = avgCustResMap.keySet();
		Set<String> uniqueProductSet = new Set<String>();
		Double sumOfDurations = 0.0;
		Double avgOfDurations = 0.0;
		Double sumOfDurationLoc = 0.0;
		Integer caseCount = 0; 
		
		List<R6CaseTimeWrapper> timeWrappListBucket = null;
		R6CaseTimeComputeWrapper timeComputeWrap = null;
		
		Map<String, R6CaseTimeComputeWrapper> productYearGridMap = new Map<String, R6CaseTimeComputeWrapper>();
		
		for(String monthYear : monthYearSet) {
			for(String productKey : avgCustResMap.get(monthYear).keySet()) {
				uniqueProductSet.add(productKey);
			}
		}

		for(String productKey : uniqueProductSet) {
			for(String monthKey : monthYearSet) {
				sumOfDurations = 0.0;
				avgOfDurations = 0.0;
				caseCount = 0;
				sumOfDurationLoc = 0;
				timeWrappListBucket = avgCustResMap.get(monthKey).get(productKey);
				
				if(null != timeWrappListBucket) {
					for(R6CaseTimeWrapper timeWrapObj : timeWrappListBucket) {
						sumOfDurations += timeWrapObj.totResponseTimeDays;
						sumOfDurationLoc += timeWrapObj.sumOfRes;
						caseCount = timeWrapObj.caseCount;
						System.debug(caseCount);
					}
				} 
				
				if(null == productYearGridMap.get(productKey)) {
					productYearGridMap.put(productKey, new R6CaseTimeComputeWrapper(productKey));
				}
				if(null == productYearGridMap.get(productKey).monthWiseAverage.get(monthKey)) {
					productYearGridMap.get(productKey).monthWiseAverage.put(monthKey,
							new MonthWiseAvgWrapper(monthKey,sumOfDurations,caseCount,sumOfDurationLoc
						)
					);
				}
				
			}
			((R6CaseTimeComputeWrapper)productYearGridMap.get(productKey)).doComputeOverAllTot();
		}
		
		return productYearGridMap;
	}
	
	
	/**
	 * Wrapper to hold the result
	 */
	public class R6CaseTimeWrapper {
		private Integer calYear = null;
		private Integer calMonth = null;
		private String calendarMonthYear = null;
		private String productName = null;
		private Integer caseCount = null;
		private Double totResponseTimeDays = 0.0;
		private Double avgResPerUserPerProd = 0.0;
		private Double sumOfRes = 0.0;
		
		/**
		 * Param cons
		 */
		public R6CaseTimeWrapper(Integer calYear, Integer calMonth, String productName, 
			Integer caseCount, Double totResponseTimeDays, Double sumOfRes) {
			this.calYear = calYear;
			this.calMonth = calMonth;
			this.productName = productName;
			this.caseCount = caseCount;
			this.totResponseTimeDays = totResponseTimeDays;
			this.sumOfRes = sumOfRes;
			
			this.calendarMonthYear = TimeTrackUtility.doConvertCalendarMonthAndYear(calMonth, calYear);
		}
		
		override
		/**
		 * Method used to print the object in a readble format
		 */		
		public String toString() {
			return calendarMonthYear +','+','+productName+','+totResponseTimeDays+','+caseCount+','+avgResPerUserPerProd;
		}
	} //end of wrapper
	
	/**
	 * A wrapper to get in the GUI
	 */
	public class R6CaseTimeComputeWrapper {
		public String productName {get; set;}
		public Map<String, MonthWiseAvgWrapper>  monthWiseAverage{get; set;}
		public Double totalProductDuration {get; set;}
		public List<ProductMonthAverage> productMonthList {get; set;}
		public String strTotalProductDuration {get; set;}
		public Integer totProductCases {get; set;}
		
		/**
		 * Params Cons
		 */
		public R6CaseTimeComputeWrapper(String productName) {
			this.productName = productName;
			monthWiseAverage = new Map<String, MonthWiseAvgWrapper>();
		}
		
		/**
		 * Method to compute the overall count of the days
		 */
		public void doComputeOverAllTot() {
			Double totalProductDurationLoc = 0.0;
			MonthWiseAvgWrapper monthWrapper = null;
			totProductCases = 0;
			
			if(!monthWiseAverage.isEmpty()) {
				productMonthList = new List<ProductMonthAverage>();
				for(String monthKey : monthWiseAverage.keySet()) {
					monthWrapper = monthWiseAverage.get(monthKey);
					if(null != monthWrapper) {
						totalProductDurationLoc += monthWrapper.monthSum;
						totProductCases += monthWrapper.noOfCases != null ? monthWrapper.noOfCases : 0;
						this.productMonthList.add(new ProductMonthAverage(monthKey, monthWrapper.monthAvg, monthWrapper.noOfCases));
					}
				}
			}
			
			this.totalProductDuration = totalProductDurationLoc / totProductCases;
			
			if(totalProductDuration > 0) {
				this.strTotalProductDuration = TimeTrackUtility.doDateReadable(totalProductDuration);
			} else {
				this.strTotalProductDuration = ZERO_STR;
			}
			this.productMonthList.sort();
		}
	}
	
	/**
	 * A wrapper to compute the average per month for all the products
	 */
	public class ProductMonthAverage implements Comparable {
		public Integer monthNum {get; set;}
		public String monthName {get; set;}
		public Double monthWiseAverage{get; set;}
		public String strMonthWiseAverage {get; set;}
		public Integer caseCount {get; set;}
		
		/**
		 * Params Cons
		 */
		public ProductMonthAverage(String monthName, Double monthAvg, Integer caseCount) {
			this.monthName = monthName;
			this.monthWiseAverage = monthAvg;
			this.monthNum = TimeTrackUtility.doConvertCalendarMonth(monthName);
			this.caseCount = caseCount;
			if(monthWiseAverage > 0) {
				this.strMonthWiseAverage = TimeTrackUtility.doDateReadable(monthWiseAverage);
			} else {
				this.strMonthWiseAverage = ZERO_STR;
			}
		}
		
		/**
		 * Used to compare the objects
		 */
		public Integer compareTo(Object comparedObject) {
			ProductMonthAverage convertedObj = (ProductMonthAverage) comparedObject;
			if(this.monthNum == convertedObj.monthNum) {
				return 0;
			}
			if(this.monthNum > convertedObj.monthNum) {
				return 1;
			}
			return -1;
		}
	}
	
	/**
	* Month wise average
	**/
	public class MonthWiseAvgWrapper {
		public String monthName {get; set;}
		public Double monthAvg {get; set;}
		public Integer noOfCases {get; set;}
		public Double monthSum {get; set;}
		
		public MonthWiseAvgWrapper(String monthName, Double monthAvg, Integer noOfCases, Double monthSum) {
			this.monthName = monthName;
			this.monthAvg = monthAvg;
			this.noOfCases = noOfCases;
			this.monthSum = monthSum;
		}
	}
}