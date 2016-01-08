public class effortdetails {
    
    double requirement_gathering=0.0;
    double sit=0.0;
    double but=0.0;
    double uat=0.0;
    double design=0.0;
    double traindep=0.0;
    double adapt=0.0;
    double total = 0.0;
    integer count=0;
    List<Request__c> requirements = new List<Request__c>();
    
    String id;
    public effortdetails(ApexPages.StandardController controller) {

    id=System.currentPageReference().getParameters().get('id');
    //creating a list for Request query
    requirements = [Select p.TotEst__c,p.Adapt__c, p.BUT__c, p.Des__c, p.Req__c, p.SIT__c, p.TrnDep__c, p.UAT__c from Request__c p where Release__c=: id];
    
    //for(Request__c Request :[Select p.TotEst__c,p.Adapt__c, p.BUT__c, p.Des__c, p.Req__c, p.SIT__c, p.TrnDep__c, p.UAT__c from Request__c p where Release__c=: id])
        for(Request__c Request :requirements )
        {
        requirement_gathering=requirement_gathering + Request.Req__c;
        sit=sit + Request.SIT__c;
        but=but + Request.BUT__c;
        uat= uat + Request.UAT__c;
        design = design + Request.Des__c;
        traindep = traindep + Request.TrnDep__c;
        adapt = adapt + Request.Adapt__c;
        total= total+ Request.TotEst__c;
    count++;
       }
    }
    
    public List<Request__c> getRequirements(){
        return this.requirements ;
    } 
    public void setRequirements (List<Request__c> req){
        this.requirements  = req;
    }
    
    
    public double getTraindep(){
        return this.traindep ;
    }
    public double getRequirement_gathering(){
        return this.requirement_gathering ;
    }
    public double getSit(){
        return this.sit ;
    }
    public double getBut(){
        return this.but ;
    }
    public double getUat(){
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        sit=0.0;
        
        return this.uat ;
    }
    public double getDesign(){
        return this.design ;
    }
    public double getAdapt(){
        return this.adapt ;
    }
    public double getTotal(){
        return total ;
    }
    public String getId(){
        return id;
    }
    public Integer getCount(){
        return count;
    }
    
    static testmethod void testeffortdetails(){
    ApexPages.StandardController controllerobj;
    effortdetails eft=new effortdetails(controllerobj);
    eft.getTotal();
    eft.getAdapt();
    eft.getdesign();
    eft.getUat();
    eft.getBut();
    eft.getRequirement_gathering();
    eft.getSit();
    eft.getId();
    eft.getCount();
    eft.getRequirements();
 
    
    }
    
    static testmethod void testeffortdetailsRequirements(){
        ApexPages.StandardController controllerobj;
    effortdetails eft=new effortdetails(controllerobj);
    eft.setRequirements(null);
    }
 }