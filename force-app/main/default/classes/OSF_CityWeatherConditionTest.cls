/***************************************************************************
*@Name         : OSF_CityWeatherConditionTest
*@Description  : Test class for OSF_CityWeatherConditionExtensionClass
*@Created By   : Vyankatesh Chinche
*@Created Date : Jun 14, 2022
*@Modification Log :
****************************************************************************
* Version      Developer                Date        Description
*---------------------------------------------------------------------------
*                                                       
***************************************************************************/
@isTest
public class OSF_CityWeatherConditionTest {
    @isTest static void testCallout() {
         Account ac = new Account();
        ac.Name = 'Test';
        ac.ShippingCity = 'Dubai';
        insert ac;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        OSF_CityWeatherConditionExtensionClass ext = new OSF_CityWeatherConditionExtensionClass(sc);
        Test.stopTest();
       system.assertEquals('Dubai', ac.ShippingCity );
    }
    
}