public with sharing class AverageResponseTimePerMonthController {


        Map <String, List<caseResponseTime>> crtMap;
        public List<monthResponseTime> mrtList{get;set;}
        Map<String, Map<String, List<Long>>> mapForAverage;
        Map<string, long> averageProductTime ;
        Map <String, Map<String, List<caseResponseTime>>> monthlyWrapperMap;
        

    public AverageResponseTimePerMonthController() {
                crtMap = new Map<String, List<caseResponseTime>>();
                mrtList = new List<monthResponseTime>();
                mapForAverage = new Map<String, Map<String, List<Long>>>();
                averageProductTime = new Map<string, long>();
                monthlyWrapperMap = new Map <String, Map<String, List<caseResponseTime>>>();
    }

        
        public class monthResponseTime {
                public string sMonth{get; set;}
                public List<productResponseTime> prtList {get;set;}
                
                public monthResponseTime(String sMonth, List<productResponseTime> prtList){
                        this.sMonth = sMonth;
                        this.prtList = prtList;
                }
        }
        
        public class productResponseTime {
                public string sProduct{get;set;}
                public List<caseResponseTime> crtList{get;set;}
                public String averageTime{get;set;}
                
                public productResponseTime(String sProduct, List<caseResponseTime> crtList, String averageTime){
                        this.sProduct = sProduct;
                        this.crtList = crtList;
                        this.averageTime = averageTime; 
                }
                
        }
        
        public class caseResponseTime{
                public Case sCase{get;set;}
                public String respTime{get;set;}
                
                public caseResponseTime(Case sCase, String respTime){
                        this.sCase = sCase;
                        this.respTime = respTime;       
                }
        }

    
    public void retrieveData(){
        DateTime startDate = DateTime.now().addDays(-90);
        for(Case sCase : [Select Id, CaseNumber, Component_Primary__c, First_SLA_Response_Time__c, 
        	(Select Posted from Posts order by createddate limit 1)
                from Case where RecordType.Name like '%Consumer%' AND Origin IN ('Social Hub','Engagement Console') AND 
                First_SLA_Response_Time__c = LAST_90_DAYS limit 100]){
                for(SocialPost sPost : sCase.Posts){
                        if(sPost.Posted != null && sCase.Component_Primary__c != null){
                                Long respTime = sCase.First_SLA_Response_Time__c.getTime() - sCase.Posts[0].Posted.getTime();
                                caseResponseTime crt = new caseResponseTime(sCase, convertMillisecondsToHrs(respTime));
                                String monthStr = getMonthInString(sCase.First_SLA_Response_Time__c.month());
                                if(monthlyWrapperMap.containsKey(monthStr)){
                                        
                                        if(monthlyWrapperMap.get(monthStr).containsKey(sCase.Component_Primary__c)){
                                                monthlyWrapperMap.get(monthStr).get(sCase.Component_Primary__c).add(crt);
                                                mapForAverage.get(monthStr).get(sCase.Component_Primary__c).add(respTime);
                                        }else{
                                                monthlyWrapperMap.get(monthStr).put(sCase.Component_Primary__c, new List<caseResponseTime>{crt});
                                                mapForAverage.get(monthStr).put(sCase.Component_Primary__c, new List<Long>{respTime});
                                        }
                                }else{
                                        monthlyWrapperMap.put(monthStr, new Map<String, List<caseResponseTime>>{sCase.Component_Primary__c => new List<caseResponseTime>{crt}});
                                        mapForAverage.put(monthStr, new Map<String, list<long>>{sCase.Component_Primary__c => new List<Long>{respTime}});
                                }
                        }
                }
        }
        
        for(String monthStr : mapForAverage.keySet()){
                for(String sProduct : mapForAverage.get(monthStr).keySet()){
                        Long counter = 0;
                        Long total = 0;
                        for(Long respTime : mapForAverage.get(monthStr).get(sProduct) ){
                                total += respTime;
                                counter++;
                        }
                        if(total != 0 && counter != 0){
                                averageProductTime.put(monthStr + sProduct, total/counter);
                        }
                }
        }
        
        for(String monthStr : monthlyWrapperMap.keySet()){
                List<productResponseTime> prtList = new List<productResponseTime>();
                for(String sProduct : monthlyWrapperMap.get(monthStr).keySet()){
                        productResponseTime prt = new productResponseTime(sProduct, monthlyWrapperMap.get(monthStr).get(sProduct), convertMillisecondsToHrs(averageProductTime.get(monthStr + sProduct)));
                        prtList.add(prt);
                }
                monthResponseTime mrt = new monthResponseTime(monthStr, prtList);
                mrtList.add(mrt);
        }

    }
    
    
    private static String convertMillisecondsToHrs(Long msLong){
        String timeStr = '';
        
        if(msLong >= 3600000){
                timeStr = timeStr + (msLong/3600000) + ' hr(s) ';
                msLong = Math.mod(msLong, 3600000); 
        }
        
        if(msLong >= 60000){
                timeStr = timeStr + (msLong/60000) + ' min(s) ';
                msLong = Math.mod(msLong, 60000); 
        }
        
        if(msLong >= 1000){
                timeStr = timeStr + (msLong/1000) + ' sec(s) ';
                msLong = Math.mod(msLong, 1000); 
        }
        
        if(msLong != 0){
                timeStr = timeStr + msLong + ' millisec(s)';
        }
        
        return timeStr;
    }
    
        public static String getMonthInString(Integer calMonth) {
                final String[] monthNamesArr = new String[] {'January',' February',' March',' April',
                        ' May',' June',' July',' August',' September',' October',' November',' December'};
                return monthNamesArr[calMonth - 1];
        }
   /*
   Select CALENDAR_YEAR(First_SLA_Response_Time__c), CALENDAR_MONTH(First_SLA_Response_Time__c),Component_Primary__c, Owner.Name,count(id),SUM(First_Cust_Response__c) from Case
Where First_SLA_Response_Time__c <> NULL and 
Component_Primary__c <> NULL
Group by CALENDAR_YEAR(First_SLA_Response_Time__c), CALENDAR_MONTH(First_SLA_Response_Time__c),Component_Primary__c, Owner.Name
Order by CALENDAR_YEAR(First_SLA_Response_Time__c) Desc Limit 2000
   
   
   */

}