/**************************************************************************************************
 * @author          manvil95
 * @date            10/05/2024
 * @modifiedBy
 * @version         1.0
 * 
 * @group           Helpers
 * @group-content   ../../ApexDocContent/
 *
 * @description     Helper class for on TRG_CAMPX_GardenHandler.
 * @comments
 **************************************************************************************************/
public with sharing class TRG_CAMPX_GardenHelper {
    
    /**********************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * 
     * @param       newTriggerList : Trigger.new
     * 
     * @description When a new garden record is created and a manager is assigned, create a new 
     *              Task record and assign it to the manager
     * @comments
    **********************************************************************************************/
    public static void CreateTaskForNewGardeningManagers(List<CAMPX__Garden__c> newTriggerList) { 
        List<Task> taskToInsert = new List<Task>();
        
        for (CAMPX__Garden__c currentGarden : newTriggerList) {
            if (currentGarden.CAMPX__Manager__c != null) {
                Task newTask = new Task(
                    WhatId  = currentGarden.Id,
                    OwnerId = currentGarden.CAMPX__Manager__c,
                    Subject = 'Acquire Plants'
                );
                
                taskToInsert.add(newTask);
            }
        }
        
        try {
            insert taskToInsert;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    /**********************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * 
     * @param       newTriggerList : Trigger.new
     * 
     * @description When a new garden record is created, each field should be populated with its 
     *              predefined default value if it's blank.
     * @comments
    **********************************************************************************************/
    public static void initializeGardenFieldsUponRecordCreation(List<CAMPX__Garden__c> newTriggerList) {
        List<CAMPX__Garden__c> gardensToInsert = new List<CAMPX__Garden__c>();
        
        for (CAMPX__Garden__c currentGarden : newTriggerList) {
            if (currentGarden.CAMPX__Status__c == null || currentGarden.CAMPX__Status__c == '') {
                currentGarden.CAMPX__Status__c = 'Awaiting Resources';
            }
            
            if (currentGarden.CAMPX__Max_Plant_Count__c == null) {
                currentGarden.CAMPX__Max_Plant_Count__c = 100;
            }
            
            if (currentGarden.CAMPX__Minimum_Plant_Count__c == null) {
                currentGarden.CAMPX__Minimum_Plant_Count__c = 1;
            }
            
            if (currentGarden.CAMPX__Total_Plant_Count__c == null) {
                currentGarden.CAMPX__Total_Plant_Count__c = 0;
            }
            
            if (currentGarden.CAMPX__Total_Unhealthy_Plant_Count__c == null) {
                currentGarden.CAMPX__Total_Unhealthy_Plant_Count__c = 0;
            }
            
            gardensToInsert.add(currentGarden);
        }
        
        try {
            insert gardensToInsert;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}