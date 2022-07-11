/***************************************************************************
*@Name         : OSF_CityWeatherConditionExtensionClass
*@Description  : Get the weather information of the associated City
*@Created By   : Vyankatesh Chinche
*@Created Date : Jun 14, 2022
*@Modification Log :
****************************************************************************
* Version      Developer                Date        Description
*---------------------------------------------------------------------------
*                                                       
***************************************************************************/
public with sharing class OSF_CityWeatherConditionExtensionClass {
    public static final String ACC_CITY = '?q='; 
    public static final String UNIT_METRIC = '&units=metric';
    public static final String APP_ID = '&APPID=';
    public static final String GET_METHOD = 'GET';
    public static final String ICON_URL = 'http://openweathermap.org/img/wn/';
    public static final String ICON_PNG = '.png';
    public static final String TITLE_STRING = 'Weather In: ';
    public static final String DEV_NAME = 'OpenWeather';
    public Decimal temp {get; set;}
    public String description {get; set;}
    public String icon {get; set;}
    public String title {get; set;}
    public OSF_CityWeatherConditionExtensionClass(ApexPages.StandardController stdController) {
        try {
            Account account = (Account)stdController.getRecord();
            account = [SELECT Id, ShippingCity
                       FROM Account
                       WHERE Id =: account.Id];
            String accountCity = account.ShippingCity;
            String ApiKey;
            String EndPoint;
            Rest_Api__mdt apiData = Rest_Api__mdt.getInstance(Dev_Name);
            ApiKey =  apiData.API_Key__c;
            EndPoint = apiData.End_Point__c;
            EndPoint += ACC_CITY+accountCity;
            EndPoint += UNIT_METRIC;
            EndPoint += APP_ID+ApiKey;
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(EndPoint);
            system.debug(EndPoint);
            req.setMethod(GET_METHOD);
            HTTPResponse response = http.send(req);
            if (response.getStatusCode() == 200) {
                WeatherConditionResponse data =  (WeatherConditionResponse) System.JSON.deserialize(response.getBody(), WeatherConditionResponse.class);
                temp = data.main.temp;
                description = data.weather[0].description;
                icon = ICON_URL + data.weather[0].icon + ICON_PNG;
                title  = TITLE_STRING+accountCity;
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