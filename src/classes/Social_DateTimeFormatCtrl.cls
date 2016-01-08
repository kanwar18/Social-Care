/********************************************************************************************************
*    Author :     Accenture
*    Requirement: Controller to format date time value on visual force page in user time zone.
*    Version:     1.0
*    Created Date: 21th March, 2015
*********************************************************************************************************/

Public class Social_DateTimeFormatCtrl {
    Public dateTime dateTimeValue{get;set;}//getter setter to get the dateTime value from visual force page.
    
    /**
    * < getTimeZoneValue () - Method get user zones time in hours and minutes>
    * @param:
    *       
    * @return - void
    * @see -  (Apex component - Social_DateTimeFormatComponent)
    * 
    */
    
    Public String getTimeZoneValue () {
        if (dateTimeValue != null) {
            String userZoneDT = string.valueoF(dateTimeValue.format('h:mm:ss a'));
            return userZoneDT ;
        }
        return null;
    }
}