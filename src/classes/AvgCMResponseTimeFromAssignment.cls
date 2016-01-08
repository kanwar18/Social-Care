public class  AvgCMResponseTimeFromAssignment{

Public Map<Id,Map<String,String>> firstCustMap{get;set;} 
public Set<Id> OwnerList{get;set;}
Public Map<Id,String> OwnerNameMap{get;set;} 
Public Map<String,String> GradTotalMap{get;set;}
public List<User> UserList {get;set;}
Double Total=0.0;
String readTotal;
Integer Count=0;
 public AvgCMResponseTimeFromAssignment(){

    getData(); 
}
 

public void getData(){
    firstCustMap =new Map<Id,Map<String,String>>();
    OwnerList = new Set<Id>();
    OwnerNameMap =new Map<Id,String>();
    UserList =new List<User>(); 
    GradTotalMap =new Map<String,String>();
    Id consCaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case','Consumer Care Case'); 
    Integer noOfCases = 0;
    
        List<AggregateResult> aggResultSet =[Select c.OwnerId Owner,AVG(c.First_Response_Time__c) FirstCusRes, Count(Id) cnt From Case c WHERE 
        Component_Primary__c IN: Social_ConsumerReportConstants.productDSLSet AND  
        First_Response_Time__c > 0 AND CreatedDate = LAST_90_DAYS and OwnerId NOT IN (Select Id from Group) GROUP BY OwnerId 
        having AVG(First_Response_Time__c) > 0 LIMIT 49000];
        
        for(AggregateResult aggRes : aggResultSet){

            String i = TimeTrackUtility.doDateReadable((Double)aggRes.get('FirstCusRes'));
            firstCustMap.put((Id)aggRes.get('Owner'), new map<String,String>{'DSL'=>i!=null?i:'0'});
            i='';
            OwnerList.add((Id)aggRes.get('Owner'));
            
            if((Double)aggRes.get('FirstCusRes')!=null){
            	noOfCases = (Integer) aggRes.get('cnt');
                Total=Total + ((Double)aggRes.get('FirstCusRes') * noOfCases);
                Count=Count+noOfCases;
            }
        }
        if(Count!=0){
            Total =Total/Count;
        }
        readTotal = TimeTrackUtility.doDateReadable(Total);
        GradTotalMap.put('DSL',readTotal);
        readTotal = '';
        Total=0.0;
        Count=0;
        noOfCases = 0;
        
        
       List<AggregateResult> aggResultSet1 =[ Select c.OwnerId Owner,AVG(c.First_Response_Time__c) FirstCusRes, Count(Id) cnt From Case c WHERE  
        First_Response_Time__c > 0 and Component_Primary__c IN: Social_ConsumerReportConstants.productUverseSet AND CreatedDate = LAST_90_DAYS  GROUP BY 
        OwnerId having AVG(c.First_Response_Time__c) > 0 LIMIT 49000];
        
        for(AggregateResult aggRes : aggResultSet1){
        
            if(firstCustMap.containsKey((Id)aggRes.get('Owner')))
            {
                String j = TimeTrackUtility.doDateReadable((Double)aggRes.get('FirstCusRes'));
                firstCustMap.get((Id)aggRes.get('Owner')).put('U-verse',j!=null?j:'0');
                j='';
                OwnerList.add((Id)aggRes.get('Owner'));
            }
            else
            {
                String k = TimeTrackUtility.doDateReadable((Double)aggRes.get('FirstCusRes'));
                firstCustMap.put((Id)aggRes.get('Owner'), new map<String,String>{'U-verse'=>k!=null?k:'0'});
                k='';
                OwnerList.add((Id)aggRes.get('Owner'));
            }
            
            if((Double)aggRes.get('FirstCusRes')!=null){
            	noOfCases = (Integer) aggRes.get('cnt');
                Total=Total + ((Double)aggRes.get('FirstCusRes') * noOfCases);
                Count=Count+noOfCases;
            }            
             
        }

        if(Count!=0){
            Total =Total/Count;
        }
        readTotal = TimeTrackUtility.doDateReadable(Total);
        GradTotalMap.put('U-verse',readTotal);
        readTotal = '';
        Count=0;
        noOfCases = 0;
        Total=0.0;
        
        List<AggregateResult> aggResultSet2 =[ Select c.OwnerId Owner,AVG(c.First_Response_Time__c) FirstCusRes, Count(Id) cnt From Case c WHERE  
        First_Response_Time__c > 0 and Component_Primary__c IN: Social_ConsumerReportConstants.productYellowPagesSet 
        AND CreatedDate = LAST_90_DAYS GROUP BY OwnerId having AVG(c.First_Response_Time__c) > 0 LIMIT 49000];
        
        for(AggregateResult aggRes : aggResultSet2){
        
            if(firstCustMap.containsKey((Id)aggRes.get('Owner')))
            {
                String l = TimeTrackUtility.doDateReadable((Double)aggRes.get('FirstCusRes'));
                firstCustMap.get((Id)aggRes.get('Owner')).put('Yellow Pages',l!=null?l:'0');
                l='';
                OwnerList.add((Id)aggRes.get('Owner'));
            }
            else
            {
                string m = TimeTrackUtility.doDateReadable((Double)aggRes.get('FirstCusRes'));
                firstCustMap.put((Id)aggRes.get('Owner'), new map<String,String>{'Yellow Pages'=>m!=null?m:'0'});
                m = '';
                OwnerList.add((Id)aggRes.get('Owner'));
            }
            
            if((Double)aggRes.get('FirstCusRes')!=null){
            	noOfCases = (Integer) aggRes.get('cnt');
                Total=Total + ((Double)aggRes.get('FirstCusRes') * noOfCases);
                Count=Count+noOfCases;
            }    
        }

        if(Count!=0){
            Total =Total/Count;
        }    
        readTotal = TimeTrackUtility.doDateReadable(Total);
        GradTotalMap.put('Yellow Pages',readTotal);
        readTotal = '';
        
        Total=0.0;
        Count=0;
        noOfCases = 0;
        
        List<AggregateResult> aggResultSet3 =[ Select c.OwnerId Owner,AVG(c.First_Response_Time__c) FirstCusRes, Count(Id) cnt From Case c WHERE  
        First_Response_Time__c > 0 and Component_Primary__c IN: Social_ConsumerReportConstants.productLandlineSet 
        AND CreatedDate = LAST_90_DAYS GROUP BY OwnerId having AVG(c.First_Response_Time__c) > 0 LIMIT 49000];
        
        for(AggregateResult aggRes : aggResultSet3){
        
            if(firstCustMap.containsKey((Id)aggRes.get('Owner')))
            {
                string n = TimeTrackUtility.doDateReadable((Double)aggRes.get('FirstCusRes'));
                firstCustMap.get((Id)aggRes.get('Owner')).put('Landline',n!=null?n:'0');
                n = '';
                OwnerList.add((Id)aggRes.get('Owner'));
            }
            else
            {
                string o =TimeTrackUtility.doDateReadable((Double)aggRes.get('FirstCusRes'));
                firstCustMap.put((Id)aggRes.get('Owner'), new map<String,String>{'Landline'=>o!=null?o:'0'});
                o = '';
                OwnerList.add((Id)aggRes.get('Owner'));
            }
            
   			if((Double)aggRes.get('FirstCusRes')!=null){
            	noOfCases = (Integer) aggRes.get('cnt');
                Total=Total + ((Double)aggRes.get('FirstCusRes') * noOfCases);
                Count=Count+noOfCases;
            }  
        }

        if(Count!=0){
            Total =Total/Count;
        }
        
        readTotal = TimeTrackUtility.doDateReadable(Total);
        GradTotalMap.put('Landline',readTotal);
        readTotal = '';
        Count=0;
        noOfCases = 0;
        Total=0.0;
        
        List<AggregateResult> aggResultSet4 =[ Select c.OwnerId Owner,AVG(c.First_Response_Time__c) FirstCusRes, Count(Id) cnt From Case c WHERE  
        First_Response_Time__c > 0 and Component_Primary__c IN: Social_ConsumerReportConstants.productOthersSet AND CreatedDate = LAST_90_DAYS 
        GROUP BY OwnerId having AVG(c.First_Response_Time__c) > 0 LIMIT 49000];
        
        for(AggregateResult aggRes : aggResultSet4){
        
            if(firstCustMap.containsKey((Id)aggRes.get('Owner')))
            {
                string p = TimeTrackUtility.doDateReadable((Double)aggRes.get('FirstCusRes'));
                firstCustMap.get((Id)aggRes.get('Owner')).put('Others',p!=null?p:'0');
                p='';
                OwnerList.add((Id)aggRes.get('Owner'));
            }
            else
            {
                string q = TimeTrackUtility.doDateReadable((Double)aggRes.get('FirstCusRes'));
                firstCustMap.put((Id)aggRes.get('Owner'), new map<String,String>{'Others'=>q!=null?q:'0'});
                q='';
                OwnerList.add((Id)aggRes.get('Owner'));
            }
            
  			if((Double)aggRes.get('FirstCusRes')!=null){
            	noOfCases = (Integer) aggRes.get('cnt');
                Total=Total + ((Double)aggRes.get('FirstCusRes') * noOfCases);
                Count=Count+noOfCases;
            }  
        }

        if(Count!=0){
            Total =Total/Count;
        }
        readTotal = TimeTrackUtility.doDateReadable(Total);
        GradTotalMap.put('Others',readTotal);
        readTotal = '';
        Count=0;
        
        Total=0.0;
        
        UserList=[select Id,Name from User where id =:OwnerList];
        
        for(User U :UserList){
        
            OwnerNameMap.Put(U.Id,U.Name);
            if(firstCustMap.get(U.Id).get('DSL')==NULL){
                firstCustMap.get(U.Id).put('DSL','0.0');
            }
            if(firstCustMap.get(U.Id).get('U-verse')==NULL){
                firstCustMap.get(U.Id).put('U-verse','0.0');
            }
            if(firstCustMap.get(U.Id).get('Yellow Pages')==NULL){
                firstCustMap.get(U.Id).put('Yellow Pages','0.0');
            }
            if(firstCustMap.get(U.Id).get('Landline')==NULL){
                firstCustMap.get(U.Id).put('Landline','0.0');
            }
            if(firstCustMap.get(U.Id).get('Others')==NULL){
                firstCustMap.get(U.Id).put('Others','0.0');
            }
            
        }
        system.debug('----'+UserList);
    
}


}