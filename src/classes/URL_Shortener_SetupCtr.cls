/**
 * @author Altimetrik
 * @description
 *    started on 02/10/2015
 *    
 **/
public class URL_Shortener_SetupCtr{


    //************************************************************************
    // Constants
 

    public bitly_login__c setupObj {get;set;}

    //************************************************************************
    // Methods
    public URL_Shortener_SetupCtr(){ 
        setupObj = bitly_login__c.getInstance('bitly_login');

    }
    
    public void checkCustomSetting(){
        if(setupObj == null){
            setupObj = new bitly_login__c(name = 'bitly_login');
            insert setupObj;
        }
    }
    
    public PageReference save(){
        upsert setupObj;
        return null;
    }

    public static bitly_login__c getSetupObject() {

        return bitly_login__c.getInstance('bitly_login');
    }


}