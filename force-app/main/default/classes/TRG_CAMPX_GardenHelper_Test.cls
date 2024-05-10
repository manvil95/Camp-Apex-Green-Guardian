/**************************************************************************************************
 * @author          manvil95
 * @date            10/05/2024
 * @modifiedBy
 * @version         1.0
 * 
 * @group           Test
 * @group-content   ../../ApexDocContent/Accounts.htm
 *
 * @description     Test class for on TRG_CAMPX_GardenHelper.
 * @comments
 **************************************************************************************************/
@isTest
public with sharing class TRG_CAMPX_GardenHelper_Test {
    
    @TestSetup
    static void makeData(){
        
    }

    /**************************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * 
     * @param       newTriggerList : Trigger.new
     * 
     * @description When a new garden record is created, each field should be populated with its 
     *              predefined default value if it's blank.
     * @comments
    **************************************************************************************************/
    @isTest
    static void newRecordWithValues() {

        CAMPX__Garden__c garden = new CAMPX__Garden__c(
            Name = 'Test Garden',
            CAMPX__Status__c = 'Operational',
            CAMPX__Max_Plant_Count__c = 20,
            CAMPX__Minimum_Plant_Count__c = 2,
            CAMPX__Total_Plant_Count__c = 10,
            CAMPX__Total_Unhealthy_Plant_Count__c = 5
        );
        
        Test.startTest();
        insert garden;
        Test.stopTest();

        CAMPX__Garden__c gardenAfter = [SELECT Id, 
                                            Name, 
                                            CAMPX__Status__c, 
                                            CAMPX__Max_Plant_Count__c, 
                                            CAMPX__Minimum_Plant_Count__c,
                                            CAMPX__Total_Plant_Count__c,
                                            CAMPX__Total_Unhealthy_Plant_Count__c
                                        FROM CAMPX__Garden__c 
                                        WHERE Id = :garden.Id];

        System.assertEquals('Operational', gardenAfter.CAMPX__Status__c, 'The expected status is not the same.');
        System.assertEquals(20, gardenAfter.CAMPX__Max_Plant_Count__c, 'The expected Max plant count is not the same.');
        System.assertEquals(2, gardenAfter.CAMPX__Minimum_Plant_Count__c, 'The expected Minimum plant count is not the same.');
        System.assertEquals(10, gardenAfter.CAMPX__Total_Plant_Count__c, 'The expected total plant count is not the same.');
        System.assertEquals(5, gardenAfter.CAMPX__Total_Unhealthy_Plant_Count__c, 'The expected total unhealthy plant is not the same.');
    }

    /**************************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * 
     * @param       newTriggerList : Trigger.new
     * 
     * @description When a new garden record is created, each field should be populated with its 
     *              predefined default value if it's blank.
     * @comments
    **************************************************************************************************/
    @isTest
    static void newRecordWithoutValues() {

        CAMPX__Garden__c garden = new CAMPX__Garden__c(Name = 'Test Garden');
        
        Test.startTest();
        insert garden;
        Test.stopTest();

        CAMPX__Garden__c gardenAfter = [SELECT Id, 
                                            Name, 
                                            CAMPX__Status__c, 
                                            CAMPX__Max_Plant_Count__c, 
                                            CAMPX__Minimum_Plant_Count__c,
                                            CAMPX__Total_Plant_Count__c,
                                            CAMPX__Total_Unhealthy_Plant_Count__c
                                        FROM CAMPX__Garden__c 
                                        WHERE Id = :garden.Id];

        System.assertEquals('Awaiting Resources', gardenAfter.CAMPX__Status__c, 'The expected status is not the same.');
        System.assertEquals(100, gardenAfter.CAMPX__Max_Plant_Count__c, 'The expected Max plant count is not the same.');
        System.assertEquals(1, gardenAfter.CAMPX__Minimum_Plant_Count__c, 'The expected Minimum plant count is not the same.');
        System.assertEquals(0, gardenAfter.CAMPX__Total_Plant_Count__c, 'The expected total plant count is not the same.');
        System.assertEquals(0, gardenAfter.CAMPX__Total_Unhealthy_Plant_Count__c, 'The expected total unhealthy plant is not the same.');
    }
}