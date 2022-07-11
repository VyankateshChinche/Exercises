/***************************************************************************
*@Name         : MockHttpResponseGenerator
*@Description  : Create fake response for TestMock
*@Created By   : Vyankatesh Chinche
*@Created Date : Jun 14, 2022
*@Modification Log :
****************************************************************************
* Version      Developer                Date        Description
*---------------------------------------------------------------------------
*                                                       
***************************************************************************/
@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('http://api.openweathermap.org/data/2.5/weather?q=Dubai&units=metric&APPID=628b12bbf1f9bd03f0a5440cdb2a0e56', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        HttpResponse res = new HttpResponse();
        res.setBody('{"coord":{"lon":55.3047,"lat":25.2582},"weather":[{"id":801,"main":"Clouds","description":"few clouds","icon":"02d"}],"base":"stations","main":{"temp":37.77,"feels_like":41.62,"temp_min":36.16,"temp_max":37.96,"pressure":998,"humidity":37},"visibility":10000}');
        res.setStatusCode(200);
        return res;
    }
}