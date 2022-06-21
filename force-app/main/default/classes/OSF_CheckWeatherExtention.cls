/*******************************************************************************
* @Name         : OSF_CheckWeatherExtention
* @Description  : Get the weather of the associated City
* @Created By   : Vyankatesh Chinche
* @Created Date : Jun 14, 2022
* @Modification Log :
********************************************************************************
* Version      Developer                Date        Description
*                                                       
*******************************************************************************/
public with sharing class OSF_CheckWeatherExtention {
    public static final String Wether_Desc = 'description';
    public static final String Icon_Code = 'icon';
    public static final String Main_Result = 'main';
    public static final String Acc_City = '?q=';
    public static final String Unit_Metric = '&units=metric';
    public static final String App_Id = '&APPID=';
    public static final String Get_Method = 'GET';
    public static final String Icon_Url = 'http://openweathermap.org/img/wn/';
    public static final String Icon_Png = '.png';
    public static final String Title_String = 'Weather In: ';
    public Decimal temp{get; set;}
    public String description{get; set;}
    public String icon{get; set;}
    public String title{get; set;}
    public OSF_CheckWeatherExtention(ApexPages.StandardController stdController) {
        try {
            Account account = (Account)stdController.getRecord();
            account = [SELECT Id, ShippingCity
                       FROM Account
                       WHERE Id =: account.Id];
            String accountCity = account.ShippingCity;
            List<Rest_Api__mdt> apidata = [SELECT Label, API_Key__c, End_Point__c
                                           FROM Rest_Api__mdt];
            String ApiKey;
            String EndPoint;
            for (Rest_Api__mdt code : apidata) {
                ApiKey = code.API_Key__c;
                EndPoint = code.End_Point__c;
            }
            EndPoint += Acc_City+accountCity;
            EndPoint += Unit_Metric;
            EndPoint += App_Id+ApiKey;
            Http http = new Http();
            HttpRequest req = new HttpRequest ();
            req.setEndpoint(EndPoint);
            system.debug(EndPoint);
            req.setMethod(Get_Method);
            HTTPResponse response = http.send(req);
            system.debug(response.getBody());
            if (response.getStatusCode() == 200) {
                WeatherConditionResponse data =  (WeatherConditionResponse) System.JSON.deserialize(response.getBody(), WeatherConditionResponse.class);
                temp = data.main.temp;
                description = data.weather[0].description;
                icon = data.weather[0].icon;
                String urlLinks = +Icon_Url;
                urlLinks += icon+Icon_Png;
                icon = urlLinks;
                title  = Title_String+accountCity;
            } else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There is error in data.');
                ApexPages.addMessage(myMsg);
            }
        } catch(Exception e) {
            System.debug('Exception :'+e.getMessage());
        }
    }
    public class WeatherConditionResponse {
        public cls_weather[] weather;
        public cls_main main;
    }
    class cls_weather {
        public String description;
        public String icon;
    }
    class cls_main {
        public Decimal temp;
    }
}