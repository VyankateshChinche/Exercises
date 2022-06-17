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
    public static final String Api_Key = '628b12bbf1f9bd03f0a5440cdb2a0e56';
    public static final String Url_Link = 'http://api.openweathermap.org/data/2.5/weather';
    public static final String Acc_City = '?q=';
    public static final String Unit_Metric = '&units=metric';
    public static final String App_Id = '&APPID=';
    public static final String Get_Method = 'GET';
     public static final String Icon_Url = 'http://openweathermap.org/img/wn/';
     public static final String Icon_Png = '.png';
    public decimal temp{get; set;}
    public String description{get; set;}
    public String icon{get; set;}
    public OSF_CheckWeatherExtention(ApexPages.StandardController stdController) {
        try {
            Account account = (Account)stdController.getRecord();
            account = [SELECT Id, ShippingCity
                       FROM Account
                       WHERE Id =: account.Id];
            String accountCity = account.ShippingCity;
            String apiKey = Api_Key;
            String requestEndPoint = Url_Link;
            requestEndPoint += Acc_City+accountCity;
            requestEndPoint += Unit_Metric;
            requestEndPoint += App_Id+apiKey;
            Http http = new Http();
            HttpRequest req = new HttpRequest ();
            req.setEndpoint(requestEndPoint);
            system.debug(requestEndPoint);
            req.setMethod(Get_Method);
            HTTPResponse response = http.send(req);
            system.debug(response.getBody());
            if (response.getStatusCode() == 200) {
                FromJSON data =  (FromJSON) System.JSON.deserialize(response.getBody(), FromJSON.class);
                temp = data.main.temp;
                description = data.weather[0].description;
                icon = data.weather[0].icon;
                String urlLinks = +Icon_Url;
                urlLinks += icon+Icon_Png;
                icon = urlLinks;
            } else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There is error in data.');
                ApexPages.addMessage(myMsg);
            }
        } catch(Exception e) {
            System.debug('Exception :'+e.getMessage());
        }
    }
    public class FromJSON {
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