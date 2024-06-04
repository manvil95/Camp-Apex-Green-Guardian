/**************************************************************************************************
 * @author          manvil95
 * @date            10/05/2024
 * @modifiedBy
 * @version         1.0
 * 
 * @group           Test
 * @group-content   ../../ApexDocContent/
 *
 * @description     Test class for on TRG_CAMPX_GardenHelper.
 * @comments
 **************************************************************************************************/
@isTest
public with sharing class TRG_CAMPX_GardenHelper_Test {
    
    @TestSetup
    static void makeData(){
        // Create a profile for Admin
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        // Create a user with the admin profile
        User adminUser = new User(
            FirstName           = 'Test',
            LastName            = 'Admin',
            Alias               = 'tadmin',
            Email               = 'testadmin@example.com',
            Username            = 'manvil95@campapexgreen.com', // Ensure unique username
            EmailEncodingKey    = 'UTF-8',
            TimeZoneSidKey      = 'Europe/Madrid',
            LocaleSidKey        = 'en_US',
            LanguageLocaleKey   = 'en_US',
            ProfileId           = adminProfile.Id
        );
        insert adminUser;
    }

    /**************************************************************************************************
     * @author      manvil95
     * @date        04/06/2024
     * @modifiedBy
     * @description When a garden record is updated the capacity is calculated.
     * @comments
    **************************************************************************************************/
    @isTest
    static void calculateCapacityOnUpdate() {
        List<CAMPX__Garden__c> testGardens = new List<CAMPX__Garden__c>();
        for (Integer i = 0; i < 5; i++) {
            CAMPX__Garden__c currentGarden = new CAMPX__Garden__c(
                Name = 'Garden ' + i,
                CAMPX__Manager__c = UserInfo.getUserId(),
                CAMPX__Total_Plant_Count__c = 50,
                CAMPX__Max_Plant_Count__c = 100
            );
            testGardens.add(currentGarden);
        }
        
        insert testGardens;
        
        for (CAMPX__Garden__c campx : testGardens) {
            campx.CAMPX__Total_Plant_Count__c = 51;
        }
        
        Test.startTest();
        update testGardens;
        Test.stopTest();

        List<CAMPX__Garden__c> gardenInserted = [SELECT Id, CAMPX__Capacity__c FROM CAMPX__Garden__c];

        for (CAMPX__Garden__c currentGarden : gardenInserted) {
            System.assertEquals(51, currentGarden.CAMPX__Capacity__c, 'Capacity is not the expected.');
        }
    }

    /**************************************************************************************************
     * @author      manvil95
     * @date        04/06/2024
     * @modifiedBy
     * @description When a garden record is created the capacity is calculated.
     * @comments
    **************************************************************************************************/
    @isTest
    static void calculateCapacity() {
        List<CAMPX__Garden__c> testGardens = new List<CAMPX__Garden__c>();
        for (Integer i = 0; i < 5; i++) {
            CAMPX__Garden__c currentGarden = new CAMPX__Garden__c(
                Name = 'Garden ' + i,
                CAMPX__Manager__c = UserInfo.getUserId(),
                CAMPX__Total_Plant_Count__c = 50,
                CAMPX__Max_Plant_Count__c = 100
            );
            testGardens.add(currentGarden);
        }
        
        Test.startTest();
        insert testGardens;
        Test.stopTest();

        List<CAMPX__Garden__c> gardenInserted = [SELECT Id, CAMPX__Capacity__c FROM CAMPX__Garden__c];

        for (CAMPX__Garden__c currentGarden : gardenInserted) {
            System.assertEquals(50, currentGarden.CAMPX__Capacity__c, 'Capacity is not the expected.');
        }
    }

    /**************************************************************************************************
     * @author      manvil95
     * @date        25/05/2024
     * @modifiedBy
     * @description When a garden record is updated and a manager is unset, start date must be blank.
     * @comments
    **************************************************************************************************/
    @isTest
    static void testUnsetManagerStartDate() {
        // Create test Garden records
        List<CAMPX__Garden__c> testGardens = new List<CAMPX__Garden__c>();
        for (Integer i = 0; i < 5; i++) {
            CAMPX__Garden__c currentGarden = new CAMPX__Garden__c(
                Name = 'Garden ' + i,
                CAMPX__Manager__c = UserInfo.getUserId() // Use the current user as a sample Garden manager
            );
            testGardens.add(currentGarden);
        }
        insert testGardens;

        for (CAMPX__Garden__c currentGarden : testGardens) {
            currentGarden.CAMPX__Manager__c = null;
        }

        // Call the method being tested
        Test.startTest();
        update testGardens;
        Test.stopTest();

        // Verify that tasks have been created for the Garden managers
        List<CAMPX__Garden__c> gardenInserted = [SELECT Id, CAMPX__Manager__c, CAMPX__Manager_Start_Date__c FROM CAMPX__Garden__c];

        // Verify task ownership and subject
        for (CAMPX__Garden__c currentGarden : gardenInserted) {
            System.assertEquals(null, currentGarden.CAMPX__Manager_Start_Date__c, 'Expected date must be the same as today.');
            System.assertEquals(null, currentGarden.CAMPX__Manager__c, 'The Manager Id must be the same.');
        }
    }

    /**************************************************************************************************
     * @author      manvil95
     * @date        25/05/2024
     * @modifiedBy
     * @description When a new garden record is created and a manager is set, start date must be filled.
     * @comments
    **************************************************************************************************/
    @isTest
    static void testSetManagerStartDate() {
        // Create test Garden records
        List<CAMPX__Garden__c> testGardens = new List<CAMPX__Garden__c>();
        for (Integer i = 0; i < 5; i++) {
            CAMPX__Garden__c currentGarden = new CAMPX__Garden__c(
                Name = 'Garden ' + i,
                CAMPX__Manager__c = UserInfo.getUserId() // Use the current user as a sample Garden manager
            );
            testGardens.add(currentGarden);
        }
        
        // Call the method being tested
        Test.startTest();
        insert testGardens;
        Test.stopTest();

        // Verify that tasks have been created for the Garden managers
        List<CAMPX__Garden__c> gardenInserted = [SELECT Id, CAMPX__Manager__c, CAMPX__Manager_Start_Date__c FROM CAMPX__Garden__c];

        // Verify task ownership and subject
        for (CAMPX__Garden__c currentGarden : gardenInserted) {
            System.assertEquals(Date.today(), currentGarden.CAMPX__Manager_Start_Date__c, 'Expected date must be the same as today.');
            System.assertEquals(UserInfo.getUserId(), currentGarden.CAMPX__Manager__c, 'The Manager Id must be the same.');
        }
    }

    /**************************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
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

    /**************************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * 
     * @description 
     * @comments
    **************************************************************************************************/
    @isTest
    static void testCreateTaskForExistingGardeningManagers() {
        // Create test Garden records
        List<CAMPX__Garden__c> testGardens = new List<CAMPX__Garden__c>();
        for (Integer i = 0; i < 5; i++) {
            CAMPX__Garden__c currentGarden = new CAMPX__Garden__c(
                Name = 'Garden ' + i,
                CAMPX__Manager__c = UserInfo.getUserId() // Use the current user as a sample Garden manager
            );
            testGardens.add(currentGarden);
        }
        
        // Call the method being tested
        Test.startTest();
        insert testGardens;
        Test.stopTest();

        // Verify that tasks have been created for the Garden managers
        List<Task> createdTasks = [SELECT Id, OwnerId, WhatId, Subject FROM Task WHERE WhatId IN :testGardens];
        System.assertEquals(testGardens.size(), createdTasks.size(), 'Number of created tasks should match number of Garden records');

        // Verify task ownership and subject
        for (Task currentTask : createdTasks) {
            System.assertEquals(testGardens[0].CAMPX__Manager__c, currentTask.OwnerId, 'Task owner should match the Garden manager');
            System.assertEquals('Acquire Plants', currentTask.Subject, 'Task subject should match the predefined value');
        }
    }
    
    /**************************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * 
     * @description 
     * @comments
    **************************************************************************************************/
    @isTest
    static void testCreateTaskForExistingGardeningManagersNegative() {
        // Create test Garden records
        List<CAMPX__Garden__c> testGardens = new List<CAMPX__Garden__c>();
        for (Integer i = 0; i < 5; i++) {
            CAMPX__Garden__c currentGarden = new CAMPX__Garden__c(
                Name = 'Garden ' + i
            );
            testGardens.add(currentGarden);
        }
        
        // Call the method being tested
        Test.startTest();
        insert testGardens;
        Test.stopTest();

        // Verify that tasks have been created for the Garden managers
        List<Task> createdTasks = new List<Task>();
        try {
            createdTasks = [SELECT Id, OwnerId, WhatId, Subject FROM Task WHERE WhatId IN :testGardens];
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        System.assertEquals(0, createdTasks.size(), 'Number of created tasks should match number of Garden records');
    }

    /**************************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * 
     * @description 
     * @comments
    **************************************************************************************************/
    @isTest
    static void testCreateTaskAfterUpdateGardenWithManagerFirstTime() {
        // Create test Garden records
        List<CAMPX__Garden__c> testGardens = new List<CAMPX__Garden__c>();
        for (Integer i = 0; i < 5; i++) {
            CAMPX__Garden__c currentGarden = new CAMPX__Garden__c(
                Name = 'Garden ' + i
            );
            testGardens.add(currentGarden);
        }
        insert testGardens;
        
        List<CAMPX__Garden__c> updateGardens = new List<CAMPX__Garden__c>();
        for (CAMPX__Garden__c garden : testGardens) {
            garden.CAMPX__Manager__c = UserInfo.getUserId();
            updateGardens.add(garden);
        }        
        // Call the method being tested
        Test.startTest();
        
        update updateGardens;

        Test.stopTest();

        // Verify that tasks have been created for the Garden managers
        List<Task> createdTasks = [SELECT Id, OwnerId, WhatId, Subject FROM Task WHERE WhatId IN :testGardens];
        System.assertEquals(testGardens.size(), createdTasks.size(), 'Number of created tasks should match number of Garden records');

        // Verify task ownership and subject
        for (Task currentTask : createdTasks) {
            System.assertEquals(testGardens[0].CAMPX__Manager__c, currentTask.OwnerId, 'Task owner should match the Garden manager');
            System.assertEquals('Acquire Plants', currentTask.Subject, 'Task subject should match the predefined value');
        }
    }

    /**************************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * 
     * @description 
     * @comments
    **************************************************************************************************/
    @isTest
    static void testReassignTasks() {
        // Create test Garden records
        List<CAMPX__Garden__c> testGardens = new List<CAMPX__Garden__c>();
        for (Integer i = 0; i < 5; i++) {
            CAMPX__Garden__c currentGarden = new CAMPX__Garden__c(
                Name = 'Garden ' + i,
                CAMPX__Manager__c = UserInfo.getUserId()
            );
            testGardens.add(currentGarden);
        }
        
        User u = [SELECT Id FROM User WHERE Username = 'manvil95@campapexgreen.com' LIMIT 1];
        
        insert testGardens;
        List<CAMPX__Garden__c> updateGardens = new List<CAMPX__Garden__c>();
        for (CAMPX__Garden__c garden : testGardens) {
            garden.CAMPX__Manager__c = u.Id;
            updateGardens.add(garden);
        }        
        // Call the method being tested
        Test.startTest();
        
        update updateGardens;

        Test.stopTest();

        List<CAMPX__Garden__c> updatedGardens = [SELECT Id, CAMPX__Manager__c FROM CAMPX__Garden__c];
        // Verify that tasks have been created for the Garden managers
        List<Task> createdTasks = [SELECT Id, OwnerId, WhatId, Subject FROM Task WHERE WhatId IN :updatedGardens];
        System.assertEquals(updatedGardens.size(), createdTasks.size(), 'Number of created tasks should match number of Garden records');
        
        // Verify task ownership and subject
        for (CAMPX__Garden__c updated : updatedGardens) {
            System.assertEquals(updated.CAMPX__Manager__c, u.Id, 'Task owner should match the Garden manager');
        }
        
        for (Task currentTask : createdTasks) {
            System.assertEquals(updatedGardens[0].CAMPX__Manager__c, currentTask.OwnerId, 'Task owner should match the Garden manager');
            System.assertEquals('Acquire Plants', currentTask.Subject, 'Task subject should match the predefined value');
        }
    }

    /**************************************************************************************************
     * @author      manvil95
     * @date        24/05/2024
     * @modifiedBy
     * 
     * @description 
     * @comments
    **************************************************************************************************/
    @isTest
    static void testDeleteTaskWhenManagerIsUnassigned() {
        // Create test Garden records
        List<CAMPX__Garden__c> testGardens = new List<CAMPX__Garden__c>();
        for (Integer i = 0; i < 5; i++) {
            CAMPX__Garden__c currentGarden = new CAMPX__Garden__c(
                Name = 'Garden ' + i,
                CAMPX__Manager__c = UserInfo.getUserId()
            );
            testGardens.add(currentGarden);
        }
        
        User u = [SELECT Id FROM User WHERE Username = 'manvil95@campapexgreen.com' LIMIT 1];
        
        insert testGardens;
        List<CAMPX__Garden__c> updateGardens = new List<CAMPX__Garden__c>();
        for (CAMPX__Garden__c garden : testGardens) {
            garden.CAMPX__Manager__c = null;
            updateGardens.add(garden);
        }        
        // Call the method being tested
        Test.startTest();
        
        update updateGardens;

        Test.stopTest();

        List<CAMPX__Garden__c> updatedGardens = [SELECT Id, CAMPX__Manager__c FROM CAMPX__Garden__c];
        // Verify that tasks have been created for the Garden managers
        List<Task> createdTasks = new List<Task>();
        try {
            createdTasks = [SELECT Id, OwnerId, WhatId, Subject FROM Task WHERE WhatId IN :updatedGardens];
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        System.assertEquals(true, createdTasks.isEmpty(), 'All task must be deleted');
        
        // Verify task ownership and subject
        for (CAMPX__Garden__c updated : updatedGardens) {
            System.assertEquals(null, updated.CAMPX__Manager__c, 'Task owner should match the Garden manager');
        }
    }
}