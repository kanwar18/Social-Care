/**************************************************************************
Class Name:  Social_AHTReportController
Author: Accenture
Requirement/Project Name: Social Care
Description: Public class act as a controller for Social_AHTReportComponent component. This class will be responsable for getting data from reports
Version History: Aditya(16/December/2014)
Version History: Haemen(11/26/2015) : TO include reports for DTV Care Manager, U-verse Care Manager and U-verse Sales & Service Care Manager
***************************************************************************/

public class Social_AHTReportController {

    public static String ouputCSVString;//String to store results
    public String reportId{get;set;}//String to store Report Id
    public static final string dummyCsv = '"005E0000005O15OIAS","Unavailable ? Monitor","28338","Aimee Pizzi","1/6/2015"'+ '\n' +'"005E0000005O15OIAS","Unavailable ? Monitor","28338","Aimee Pizzi","1/6/2015"'+ '\n' + '"005E0000005O15OIAS","Unavailable ? Monitor","28338","Aimee Pizzi","1/6/2015"';
    
   /**
    * < Social_AHTReportController() - Constructor>
    * @param:
    */
    
    Public Social_AHTReportController () {}
    
   /**
    * < getCSVStream() - Method to read data from report>
    * @param:
    *       
    * @return - String ouputCSVString - This string contains data
    * @see - Social_AHTReportComponent (Component)
    */
    
    public String getCSVStream() {
        if (reportId == Label.dailyhandletimereport) {
            ouputCSVString = new PageReference('/' + reportId + '?csv=1&exp=1').getContent().toString();
            return ouputCSVString;
        } else if(reportId == Label.dailyHandleTimeReportUverseCM){
            ouputCSVString = new PageReference('/' + reportId + '?csv=1&exp=1').getContent().toString();
            return ouputCSVString;
        } else if(reportId == Label.dailyHandleTimeReportUverseS_SCM){
            ouputCSVString = new PageReference('/' + reportId + '?csv=1&exp=1').getContent().toString();
            return ouputCSVString;
        } else if(reportId == Label.dailyHandleTimeReportDTVCM){
            ouputCSVString = new PageReference('/' + reportId + '?csv=1&exp=1').getContent().toString();
            return ouputCSVString;
        } else {
            integer csvLineCount;
            String[] csvFile = new List<String>();// Array of String to store CSV data
            String reportHeader = '"User History: Created Date","Availability","User","Duration In Seconds"' + '\n';//Report header
            Map<String,List<Integer>> csvDataMap = new Map<String,List<Integer>>();//Key will be userId+Availability+username
            Map<String,Integer> csvDataSummizationMap = new Map<String,Integer>();
            List<String> sortedDataList = new List<String>();
            String finalOutputString = '';//String to store final summarized data
            String reportRunDate = '';
            if (Test.IsRunningTest()){
                ouputCSVString = dummyCsv;
                csvLineCount = 1;            
            }else {
                ouputCSVString = new PageReference('/' + reportId + '?csv=1&exp=1').getContent().toString();
                csvLineCount = 410000;
            }
            //Logic to split the string into 2 parts if string lenght is more than 410000
            if (ouputCSVString.length() > csvLineCount ) {
                String[] leftList = new List<String>();
                String[] rightList = new List<String>();
                Integer pivot = ouputCSVString.indexOf( '\n', Integer.valueOf(Math.floor(ouputCSVString.length() / 2)) );
                String leftHalfString = ouputCSVString.substring(0,pivot);
                String rightHalfString = ouputCSVString.substring(pivot+1);
                leftList = leftHalfString.split('\n');
                rightList = rightHalfString.split('\n');
                csvFile.addAll(leftList);
                csvFile.addAll(rightList);
            } else {
                csvFile = ouputCSVString.split('\n');
            }
            //Loop over the data present in CSV
            for (Integer csvLines = 1; csvLines < csvFile.size(); csvLines ++) {
                string[] csvRecordData = csvFile[csvLines].split(',');
                if (String.valueOf(csvRecordData).substringBetween('(',')') != '') {
                    reportRunDate = csvRecordData[4];
                    //csvRecordData[0] - User Id 
                    //csvRecordData[1] - Availability
                    //csvRecordData[3] - User Name
                    //csvRecordData[2] - Duration in seconds
                    if (csvDataMap.containsKey(csvRecordData[0] + ',' + csvRecordData[1] + ',' + csvRecordData[3])) {
                        csvDataMap.get(csvRecordData[0] + ',' + csvRecordData[1] + ',' + csvRecordData[3]).add(Integer.valueOf(csvRecordData[2].substringBetween('"','"')));
                    } else {
                        csvDataMap.put(csvRecordData[0] + ',' + csvRecordData[1] + ',' + csvRecordData[3],new list<Integer>{Integer.valueOf(csvRecordData[2].substringBetween('"','"'))});
                    }
                } else {
                    break;
                }
            }
            // Loop to summarize duration per availability
            for (String userAvailablityString: csvDataMap.keySet()) {
                Integer totalDurationPerAvailability = 0;
                for(Integer durationInt: csvDataMap.get(userAvailablityString)){
                    if (durationInt == Null) {
                        durationInt = 0;
                    }
                    totalDurationPerAvailability = totalDurationPerAvailability + durationInt;
                }
                csvDataSummizationMap.put(userAvailablityString,totalDurationPerAvailability);
            }
            //Sorting the data
            sortedDataList.addAll(csvDataSummizationMap.keySet());
            sortedDataList.sort();
            //Prepare final String 
            for (String summString: sortedDataList) {
                finalOutputString +=  reportRunDate + ','+ summString.substringAfter(',') + ',' + '"' + csvDataSummizationMap.get(summString) + '"' + '\n';
            }
            finalOutputString = reportHeader + finalOutputString;
            return finalOutputString;
        } 
    }
}