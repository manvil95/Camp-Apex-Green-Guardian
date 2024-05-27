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
     * @date        27/05/2024
     * @modifiedBy
     * @description When a new plant record is deleted, total count must be set.
     * @comments
    **************************************************************************************************/
    @isTest
    static void testAggregateTotalPlantCountWithPlantDeleted() {
        List<CAMPX__Plant__c> plantsToInsert = new List<CAMPX__Plant__c>();
        CAMPX__Garden__c garden = new CAMPX__Garden__c(
            Name = 'Test Garden',
            CAMPX__Sun_Exposure__c = 'Full Sun'
        );
        insert garden;

        CAMPX__Plant__c plant = new CAMPX__Plant__c(
            Name = 'Test Plant',
            CAMPX__Garden__c = garden.Id
        );
        plantsToInsert.add(plant);
        CAMPX__Plant__c plant2 = new CAMPX__Plant__c(
            Name = 'Test Plant2',
            CAMPX__Garden__c = garden.Id
        );
        plantsToInsert.add(plant2);
        insert plantsToInsert;

        Test.startTest();
        delete plant2;
        Test.stopTest();

        CAMPX__Garden__c gardenInserted = [SELECT Id, CAMPX__Total_Plant_Count__c 
                                            FROM CAMPX__Garden__c
                                            LIMIT 1];

        List<CAMPX__Plant__c> plantsCreated = [SELECT Id, CAMPX__Garden__c FROM CAMPX__Plant__c WHERE CAMPX__Garden__c != null];
        
        System.assertEquals(1, plantsCreated.size(), 'Total Plant Count must be one');
        System.assertEquals(1, gardenInserted.CAMPX__Total_Plant_Count__c, 'Total Plant Count not set');
        for (CAMPX__Plant__c plantCreated : plantsCreated) {
            System.assertEquals(gardenInserted.Id, plantCreated.CAMPX__Garden__c, 'Garden Id not set');
        }
    }
    
    /**************************************************************************************************
     * @author      manvil95
     * @date        27/05/2024
     * @modifiedBy
     * @description When a new plant record is updated and not associated with a garden, total count must be
     *              set.
     * @comments
    **************************************************************************************************/
    @isTest
    static void testAggregateTotalPlantCountWithGardenUnset() {
        List<CAMPX__Plant__c> plantsToInsert = new List<CAMPX__Plant__c>();
        CAMPX__Garden__c garden = new CAMPX__Garden__c(
            Name = 'Test Garden',
            CAMPX__Sun_Exposure__c = 'Full Sun'
        );
        insert garden;

        CAMPX__Plant__c plant = new CAMPX__Plant__c(
            Name = 'Test Plant',
            CAMPX__Garden__c = garden.Id
        );
        plantsToInsert.add(plant);
        CAMPX__Plant__c plant2 = new CAMPX__Plant__c(
            Name = 'Test Plant2',
            CAMPX__Garden__c = garden.Id
        );
        plantsToInsert.add(plant2);
        insert plantsToInsert;

        plant2.CAMPX__Garden__c = null;

        Test.startTest();
        update plant2;
        Test.stopTest();

        CAMPX__Garden__c gardenInserted = [SELECT Id, CAMPX__Total_Plant_Count__c 
                                            FROM CAMPX__Garden__c
                                            LIMIT 1];

        List<CAMPX__Plant__c> plantsCreated = [SELECT Id, CAMPX__Garden__c FROM CAMPX__Plant__c WHERE CAMPX__Garden__c != null];
        
        System.assertEquals(1, gardenInserted.CAMPX__Total_Plant_Count__c, 'Total Plant Count not set');
        for (CAMPX__Plant__c plantCreated : plantsCreated) {
            System.assertEquals(gardenInserted.Id, plantCreated.CAMPX__Garden__c, 'Garden Id not set');
        }
    }

    /**************************************************************************************************
     * @author      manvil95
     * @date        25/05/2024
     * @modifiedBy
     * @description When a new plant record is created and associated with a garden, total count must be
     *              set.
     * @comments
    **************************************************************************************************/
    @isTest
    static void testAggregateTotalPlantCount() {
        List<CAMPX__Plant__c> plantsToInsert = new List<CAMPX__Plant__c>();
        CAMPX__Garden__c garden = new CAMPX__Garden__c(
            Name = 'Test Garden',
            CAMPX__Sun_Exposure__c = 'Full Sun'
        );
        insert garden;

        CAMPX__Plant__c plant = new CAMPX__Plant__c(
            Name = 'Test Plant',
            CAMPX__Garden__c = garden.Id
        );
        plantsToInsert.add(plant);
        CAMPX__Plant__c plant2 = new CAMPX__Plant__c(
            Name = 'Test Plant2',
            CAMPX__Garden__c = garden.Id
        );
        plantsToInsert.add(plant2);

        Test.startTest();
        insert plantsToInsert;
        Test.stopTest();

        CAMPX__Garden__c gardenInserted = [SELECT Id, CAMPX__Total_Plant_Count__c 
                                            FROM CAMPX__Garden__c
                                            LIMIT 1];

        List<CAMPX__Plant__c> plantsCreated = [SELECT Id, CAMPX__Garden__c FROM CAMPX__Plant__c];
        
        System.assertEquals(2, gardenInserted.CAMPX__Total_Plant_Count__c, 'Total Plant Count not set');
        for (CAMPX__Plant__c plantCreated : plantsCreated) {
            System.assertEquals(gardenInserted.Id, plantCreated.CAMPX__Garden__c, 'Garden Id not set');
        }
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
    static void createPlantWithoutFields() {
        CAMPX__Garden__c garden = new CAMPX__Garden__c(
            Name = 'Test Garden',
            CAMPX__Sun_Exposure__c = 'Full Sun'
        );
        insert garden;

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