/**************************************************************************************************
 * @author          manvil95
 * @date            10/05/2024
 * @modifiedBy
 * @version         1.0
 * 
 * @group           Test
 * @group-content   ../../ApexDocContent/
 *
 * @description     Test class for on TRG_CAMPX_PlantHelper.
 * @comments
 **************************************************************************************************/
@isTest
public with sharing class TRG_CAMPX_PlantHelper_Test {

    /**************************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * @description When a new plant record is created, each field should be populated with its 
     *              predefined default value if it's blank.
     * @comments
    **************************************************************************************************/
    @isTest
    static void createPlantWithoutFields() {
        CAMPX__Garden__c garden = new CAMPX__Garden__c(
            Name = 'Test Garden',
            CAMPX__Sun_Exposure__c = 'Full Sun'
        );
        insert garden;

        System.debug('GARDEN: ' + garden);

        CAMPX__Plant__c plant = new CAMPX__Plant__c(
            Name = 'Test Plant',
            CAMPX__Garden__c = garden.Id,
            CAMPX__Soil_Type__c = null,
            CAMPX__Water__c = null,
            CAMPX__Sunlight__c = null
        );

        Test.startTest();
        insert plant;
        Test.stopTest();

        plant = [SELECT Id, CAMPX__Soil_Type__c, CAMPX__Water__c, CAMPX__Sunlight__c FROM CAMPX__Plant__c WHERE Id = :plant.Id WITH USER_MODE LIMIT 1];

        System.assertEquals('All Purpose Potting Soil', plant.CAMPX__Soil_Type__c, 'Soil Type not set');
        System.assertEquals('Once Weekly', plant.CAMPX__Water__c, 'Watering Schedule not set');
        System.assertEquals('Full Sun', plant.CAMPX__Sunlight__c, 'Sun Exposure not set');
    }

    /**************************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * @description When a new plant record is created, each field should be populated with its 
     *              predefined default value if it's blank.
     * @comments
    **************************************************************************************************/
    @isTest
    static void createPlantWithoutGarden() {
        CAMPX__Plant__c plant = new CAMPX__Plant__c(
            Name = 'Test Plant',
            CAMPX__Soil_Type__c = 'Sand',
            CAMPX__Water__c = 'Daily',
            CAMPX__Sunlight__c = null
        );

        Test.startTest();
        insert plant;
        Test.stopTest();

        plant = [SELECT Id, CAMPX__Soil_Type__c, CAMPX__Water__c, CAMPX__Sunlight__c FROM CAMPX__Plant__c WHERE Id = :plant.Id WITH USER_MODE LIMIT 1];

        System.assertEquals('Sand', plant.CAMPX__Soil_Type__c, 'Soil Type not set');
        System.assertEquals('Daily', plant.CAMPX__Water__c, 'Watering Schedule not set');
        System.assertEquals('Partial Sun', plant.CAMPX__Sunlight__c, 'Sun Exposure not set');
    }
}