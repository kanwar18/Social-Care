public class TimerReportsHandler {
	
	public TimerReportsHandler() {}
	
	//Method to caluclate the average case handle time per care manager
	public static List<CaseHandlingReportWrapper> calAvgCaseHandleTimePerCM() {
		
		Map<String, List<CaseHandlingWrapper>> handlingTimePerCmMap = new Map<String, List<CaseHandlingWrapper>>();	
		List<CaseHandlingReportWrapper> reportWrapperList = new List<CaseHandlingReportWrapper>();
		
		//For Processing variables
		List<CaseHandlingWrapper> handlingWrapperList = null;
		CaseHandlingWrapper wrapperObj = null;		
		String cmName = '';
		Id caseId = null;
		Double sumOfCaseTrans = 0.0;
		
		Set<Id> caseIdSet = new Set<Id>();
		Double sumOfAllCases = 0.0;
		Integer objectCounter = 0;
		
		try {
			
			AggregateResult[] groupedResult = [
				Select Transaction_Performed_By__r.Name careMgr, Related_Case__c caseId, sum(Transaction_Age__c) sumAvg from TimerTrack__c 
				where Transaction_Age__c <> null and Related_Case__c <> null and CreatedDate = LAST_90_DAYS 
				group by Transaction_Performed_By__r.Name, Related_Case__c 
				order by Transaction_Performed_By__r.Name Limit 499
			];
			
			//For Grouping Results
			if(groupedResult.size() > 0) {
				for(AggregateResult aggRes : groupedResult) {
					cmName = (String) aggRes.get('careMgr');
					caseId = (Id) aggRes.get('caseId');
					sumOfCaseTrans = (Double) aggRes.get('sumAvg');
					if(null == handlingTimePerCmMap.get(cmName)) {
						handlingTimePerCmMap.put(cmName, new List<CaseHandlingWrapper>());
					}
					handlingTimePerCmMap.get(cmName).add(new CaseHandlingWrapper(caseId, sumOfCaseTrans, objectCounter++));
					caseIdSet.add(caseId);
				}
			}
			
			//Get case related information
			Map<Id, SObject> caseMap = TimeTrackHelper.doGetSObjectMap([Select Id, caseNumber from Case Where Id IN :caseIdSet]);
			TimerReportsController.caseMap = caseMap;
			
			//Manipulate the wrapper map and add to the reportwrapper
			for(String cmStr : handlingTimePerCmMap.keySet()) {
				sumOfAllCases = 0.0;
				handlingWrapperList = handlingTimePerCmMap.get(cmStr);
				
				for(CaseHandlingWrapper wrapperObjLoc : handlingWrapperList) {
					wrapperObjLoc.caseObj = (Case) caseMap.get(wrapperObjLoc.caseId);
					sumOfAllCases += wrapperObjLoc.sumOfTrans;
				}
				reportWrapperList.add(new CaseHandlingReportWrapper(cmStr, 
					handlingWrapperList,((Double)(sumOfAllCases/handlingWrapperList.size()))));
			}
			
		} catch(Exception excep) {
			TimeTrackUtility.doPrintExceptionMsg(excep);
		}
		return reportWrapperList;
	}
	
	//Method used to show the care managers productivity while on admin time
	public static Map<String, List<CaseHandlingReportWrapper>> calHandleTimeByActivityPerCM() {
		String cmName = '';
		String transactionType = '';
		Double transSum = 0.0;
		Map<String, List<CaseHandlingReportWrapper>> userActivityMap = new Map<String, List<CaseHandlingReportWrapper>>();
		Integer objectCounter = 0;
		
		try {
			AggregateResult[] groupedResult = [
				Select Transaction_Performed_By__r.Name careMgr, Transaction_Type__c transType, 
				sum(Transaction_Age__c) transSum from TimerTrack__c 
				where Transaction_Age__c <> null and Related_Case__c <> null and CreatedDate = LAST_90_DAYS
				group by Transaction_Performed_By__r.Name, Transaction_Type__c 
				order by Transaction_Performed_By__r.Name, Transaction_Type__c Limit 499			
			];
			
			for(AggregateResult aggRes : groupedResult) {
				cmName = (String) aggRes.get('careMgr');
				transactionType = (String) aggRes.get('transType');
				transSum = (Double) aggRes.get('transSum');
				if(null == userActivityMap.get(cmName)) {
					userActivityMap.put(cmName, new List<CaseHandlingReportWrapper>());
				}
				userActivityMap.get(cmName).add(new CaseHandlingReportWrapper(cmName, transactionType, transSum, objectCounter++));
			}
			
			//For better viewing
			for(String cmStr : userActivityMap.keySet()) {
				userActivityMap.get(cmStr).sort();
			}
			
		} catch(Exception excep) {
			TimeTrackUtility.doPrintExceptionMsg(excep);
		}
		return userActivityMap;
	}

	//Method used to compute the avg of transaciton time per operation manager
	public static Map<String, List<CaseHandlingReportWrapper>> calHandleTimePerOM() {
		String omName = '';
		String cmName = '';
		Id caseId = null;
		Double transSum = 0.0;
		Set<Id> caseIdSet = new Set<Id>();
		Double sumOfAllCases = 0.0;
		Integer objectCounter = 0;
		
		List<CaseHandlingReportWrapper> reportWrapperList = new List<CaseHandlingReportWrapper>();
		Map<String, Map<String, List<CaseHandlingWrapper>>> teamHandlingMap = new Map<String, Map<String, List<CaseHandlingWrapper>>>();
		Map<String, List<CaseHandlingReportWrapper>>  omHandlerMap = new Map<String, List<CaseHandlingReportWrapper>>();
		List<CaseHandlingWrapper> handlingWrapperList = null;
		
		try {
			AggregateResult[] groupedResult = [
				Select CreatedBy.Manager.Name omName, Transaction_Performed_By__r.Name cmName, 
				Related_Case__c caseId, sum(transaction_age__c) transSum from TimerTrack__c
				Where transaction_age__c <> null and Related_Case__c <> null and CreatedDate = LAST_90_DAYS
				group by CreatedBy.Manager.Name, Transaction_Performed_By__r.Name, Related_Case__c Limit 499
			];
			
			for(AggregateResult aggRes : groupedResult) {
				omName = (String) aggRes.get('omName');
				cmName = (String) aggRes.get('cmName');
				caseId = (Id) aggRes.get('caseId');
				transSum = (Double) aggRes.get('transSum');
				caseIdSet.add(caseId);
				
				if(null == teamHandlingMap.get(omName)) {
					teamHandlingMap.put(omName, new Map<String, List<CaseHandlingWrapper>>());
				}
				
				if(null == teamHandlingMap.get(omName).get(cmName)) {
					teamHandlingMap.get(omName).put(cmName, new List<CaseHandlingWrapper>());
				}
				
				teamHandlingMap.get(omName).get(cmName).add(new CaseHandlingWrapper(caseId, transSum));
			}
			
			Map<Id, SObject> caseMap = TimeTrackHelper.doGetSObjectMap([Select Id, caseNumber from Case Where Id IN :caseIdSet]);
			
			for(String omMgr : teamHandlingMap.keySet()) {
				reportWrapperList = new List<CaseHandlingReportWrapper>();
				for(String cmMgr : teamHandlingMap.get(omMgr).keySet()) {
					handlingWrapperList = teamHandlingMap.get(omMgr).get(cmMgr);
					sumOfAllCases = 0.0;
					for(CaseHandlingWrapper caseHandWrapObj : handlingWrapperList) {
						caseHandWrapObj.caseObj = (Case) caseMap.get(caseHandWrapObj.caseId);
						sumOfAllCases += caseHandWrapObj.sumOfTrans;
					}
					reportWrapperList.add(
						new CaseHandlingReportWrapper(omMgr, cmMgr, handlingWrapperList, 
								(sumOfAllCases/handlingWrapperList.size()), objectCounter++)
					);
				}
				omHandlerMap.put(omMgr, reportWrapperList);
			}
			
		} catch(Exception excep) {
			TimeTrackUtility.doPrintExceptionMsg(excep);
		}
		return omHandlerMap;
	}
	
	//a method to display the avg case handling per time period (Last 90 Days) 
	public static Map<String, Map<String, Map<String,CaseHandlingReportWrapper>>> calHandleTimePerTimePeriod() {
		String omName = '';
		String cmName = '';
		Id caseId = null;
		Double transSum = 0.0;
		Set<Id> caseIdSet = new Set<Id>();
		Double sumOfAllCases = 0.0;
		
		Integer calMonth = 0;
		Integer calYear = 0;
		String combinedTimePeriod = '';
		String transactionType = '';
		
		Map<String, Map<String, Map<String,CaseHandlingReportWrapper>>> timePeriodCaseMap = new Map<String, Map<String, Map<String, CaseHandlingReportWrapper>>>();
		
		List<CaseHandlingWrapper> caseHandlingWrapperList =  null;
		CaseHandlingReportWrapper handlingReportWrapObj = null;
		
		Map<String, CaseHandlingReportWrapper> cmMapCtrl = new Map<String, CaseHandlingReportWrapper>();
		Double cmGlobalSumOfTrans = 0.0;
		Integer objectCounter = 0;
		
		try {
			AggregateResult[] groupedResult = [
				Select CALENDAR_MONTH(CreatedDate) calMonth, CALENDAR_YEAR(CreatedDate) calYear,
				CreatedBy.Manager.Name omName, Transaction_Performed_By__r.Name cmName, 
				Related_Case__c caseId,Transaction_Type__c transType, sum(transaction_age__c) transSum from TimerTrack__c
				Where transaction_age__c <> null and CreatedDate = LAST_90_DAYS and Related_Case__c <> null
				group by CALENDAR_MONTH(CreatedDate), CALENDAR_YEAR(CreatedDate), 
				CreatedBy.Manager.Name, Transaction_Performed_By__r.Name, Related_Case__c,Transaction_Type__c Limit 499
			];
			
			
			for(AggregateResult aggRes : groupedResult) {
				calMonth = (Integer) aggRes.get('calMonth');
				calYear = (Integer) aggRes.get('calYear');
				omName = (String) aggRes.get('omName');
				cmName = (String) aggRes.get('cmName');
				caseId = (Id) aggRes.get('caseId');
				transSum = (Double) aggRes.get('transSum');
				transactionType = (String) aggRes.get('transType');
				
				caseIdSet.add(caseId);
				combinedTimePeriod = TimeTrackUtility.doConvertCalendarMonthAndYear(calMonth, calYear);
				
				if(null == timePeriodCaseMap.get(combinedTimePeriod)) {
					timePeriodCaseMap.put(combinedTimePeriod, new Map<String, Map<String, CaseHandlingReportWrapper>>());
				}

				if(null == timePeriodCaseMap.get(combinedTimePeriod).get(cmName)) {
					timePeriodCaseMap.get(combinedTimePeriod).put(cmName, new Map<String, CaseHandlingReportWrapper>());
				}
				
				if(null == timePeriodCaseMap.get(combinedTimePeriod).get(cmName).get(caseId)) {
					caseHandlingWrapperList = new List<CaseHandlingWrapper>();
					timePeriodCaseMap.get(combinedTimePeriod).get(cmName).put(caseId, 
							new CaseHandlingReportWrapper(omName, cmName,caseHandlingWrapperList, sumOfAllCases, objectCounter++));
				}
				
				caseHandlingWrapperList = timePeriodCaseMap.get(combinedTimePeriod).get(cmName).get(caseId).wrapperObjList;
							
				caseHandlingWrapperList.add(new CaseHandlingWrapper(caseId, transSum, transactionType, (caseHandlingWrapperList.size()+1)));
			}
			
 			Map<Id, SObject> caseMap = TimeTrackHelper.doGetSObjectMap([Select Id, caseNumber from Case Where Id IN :caseIdSet]);
			TimerReportsController.caseMap = caseMap;
			Integer noOfCases = 0;
			
			for(String monthKey : timePeriodCaseMap.keySet()) {
				for(String cmNameLoc : timePeriodCaseMap.get(monthKey).keySet()) {
					cmGlobalSumOfTrans = 0.0;
					noOfCases = timePeriodCaseMap.get(monthKey).get(cmNameLoc).keySet().size();
					for(String caseIdObj : timePeriodCaseMap.get(monthKey).get(cmNameLoc).keySet()) {
						sumOfAllCases = 0.0;
						handlingReportWrapObj = (CaseHandlingReportWrapper) timePeriodCaseMap.get(monthKey).get(cmNameLoc).get(caseIdObj);
						for(CaseHandlingWrapper handleObj : handlingReportWrapObj.wrapperObjList) {
							handleObj.caseObj = (Case) caseMap.get(handleObj.caseId);
							sumOfAllCases += handleObj.sumOfTrans;
						}
						handlingReportWrapObj.cmAverage = sumOfAllCases;
						handlingReportWrapObj.averageReadableDate = TimeTrackUtility.doDateReadable(handlingReportWrapObj.cmAverage);	
						cmGlobalSumOfTrans += sumOfAllCases;
						//handlingReportWrapObj.wrapperObjList.sort();			
					}
					cmMapCtrl.put(cmNameLoc, new CaseHandlingReportWrapper(cmNameLoc, (Double)(cmGlobalSumOfTrans/noOfCases), noOfCases));
					System.debug(cmMapCtrl);
				}
			} //end of 'month key'
			
			TimerReportsController.cmMapCtrl = cmMapCtrl;
			
		} catch(Exception excep) {
			TimeTrackUtility.doPrintExceptionMsg(excep);
		}	
		return timePeriodCaseMap;
	}
	
	//A wrapper for the Case Handling
	public class CaseHandlingWrapper implements Comparable {
		public Integer objectCounter {get; set;}
		public Id caseId {get; set;}
		public Double sumOfTrans  {get; set;}
		public Case caseObj {get; set;}
		public String readableDate {get; set;}
		public String transactionType {get; set;}
		
		public CaseHandlingWrapper(Id caseId, Double sumOfTrans) {
			this.caseId = caseId;
			this.sumOfTrans = sumOfTrans;
			this.readableDate = TimeTrackUtility.doDateReadable(sumOfTrans);
		}
		
		public CaseHandlingWrapper(Id caseId, Double sumOfTrans, Integer objectCounter) {
			this.caseId = caseId;
			this.sumOfTrans = sumOfTrans;
			this.objectCounter = objectCounter;
			this.readableDate = TimeTrackUtility.doDateReadable(sumOfTrans);
		}
		
		public CaseHandlingWrapper(Id caseId, Double sumOfTrans, String transactionType, Integer objectCounter) {
			this(caseId, sumOfTrans);
			this.transactionType = transactionType;
			this.objectCounter = objectCounter;
		}		
		
		override
		public String toString() {
			return this.caseObj.caseNumber +'|'+this.sumOfTrans;
		}
		
		public Integer compareTo(Object comparedObject) {
			return this.transactionType.compareTo(((CaseHandlingWrapper) comparedObject).transactionType);
		}		
	}
	
	//A wrapper for rendering the result
	public class CaseHandlingReportWrapper implements Comparable{
		public String opsManager {get; set;}
		public String careMgrName {get; set;}
		public List<CaseHandlingWrapper> wrapperObjList{get; set;}
		public Double cmAverage {get; set;}
		public String averageReadableDate {get; set;}
		
		public String transactionType {get; set;}
		public Integer noOfCases {get; set;}
		public Integer objectCounter {get; set;}
		
		//Per Care Manager		
		public CaseHandlingReportWrapper(String careMgrName, List<CaseHandlingWrapper> wrapperObjList, Double cmAverage) {
			this.careMgrName = careMgrName;
			this.wrapperObjList = wrapperObjList;
			this.cmAverage = cmAverage;
			this.averageReadableDate = TimeTrackUtility.doDateReadable(cmAverage);			
		}
		
		//For Various activities
		public CaseHandlingReportWrapper(String careMgrName, String transactionType, Double sumOfTrans, Integer objectCounter) {
			this.careMgrName = careMgrName;
			this.transactionType = transactionType;
			this.cmAverage = sumOfTrans;  
			this.objectCounter = objectCounter;
			this.averageReadableDate = TimeTrackUtility.doDateReadable(cmAverage);	
		}
		
		//Per Ops Manager
		public CaseHandlingReportWrapper(String opsManager,String careMgrName, 
					List<CaseHandlingWrapper> wrapperObjList, Double cmAverage, Integer objectCounter) {
			this(careMgrName, wrapperObjList, cmAverage);			
			this.opsManager = opsManager;
			this.objectCounter = objectCounter;
		}
		
		//For Time Period
		public CaseHandlingReportWrapper(String careMgrName, Double cmAverage, Integer noOfCases) {
			this.careMgrName = careMgrName;
			this.cmAverage = cmAverage;
			this.noOfCases = noOfCases;
			this.averageReadableDate = TimeTrackUtility.doDateReadable(cmAverage);	
		}		
		
		public Integer compareTo(Object comparedObject) {
			return this.transactionType.compareTo(((CaseHandlingReportWrapper) comparedObject).transactionType);
		}
	}
}