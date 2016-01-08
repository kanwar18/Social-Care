@isTest
public class Social_DateTimeFormatCtrlTest{
    static testMethod void Social_DateTimeFormatCtrlTestA(){
        Social_DateTimeFormatCtrl dtCtrl = new Social_DateTimeFormatCtrl();
        dtCtrl.dateTimeValue = system.now();
        dtCtrl.getTimeZoneValue();
        dtCtrl.dateTimeValue = null;
        dtCtrl.getTimeZoneValue();
    }
}