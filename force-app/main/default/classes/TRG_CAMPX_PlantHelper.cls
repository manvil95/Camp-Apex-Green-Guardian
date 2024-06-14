/**************************************************************************************************
 * @author          manvil95
 * @date            10/05/2024
 * @modifiedBy
 * @version         1.0
 * 
 * @group           Helpers
 * @group-content   ../../ApexDocContent/
 *
 * @description     Helper class for on TRG_CAMPX_PlantHandler.
 * @comments
 **************************************************************************************************/
public with sharing class TRG_CAMPX_PlantHelper {
    
    private static final String ALL_PURPOSE_POTTING_SOIL    = 'All Purpose Potting Soil';
    private static final String ONCE_WEEKLY                 = 'Once Weekly';
    private static final String PARTIAL_SUN                 = 'Partial Sun';

    /**********************************************************************************************
     * @author      manvil95
     * @date        13/06/2024
     * @modifiedBy
     * 
     * @param       newTriggerList : Trigger.new
     * @param       oldTriggerMap  : Trigger.oldMap
     * 
     * @description Method to calculate the total unhealthy plant count
     * @comments
    **********************************************************************************************/
    public static void calculateUnhealthyPlantCount(List<CAMPX__Plant__c> newTriggerList, Map<Id, CAMPX__Plant__c> oldTriggerMap) {
        Set<Id> uniqueGardenIds                 = new Set<Id>();
        List<CAMPX__Garden__c> gardensToUpdate  = new List<CAMPX__Garden__c>();

        for (CAMPX__Plant__c currentPlant : newTriggerList) {
            if (currentPlant.MV_FOR_IsHealthy__c != true 
                    || (oldTriggerMap != null && currentPlant.MV_FOR_IsHealthy__c != oldTriggerMap.get(currentPlant.Id).MV_FOR_IsHealthy__c)) {
                uniqueGardenIds.add(currentPlant.CAMPX__Garden__c);
            }
            if (oldTriggerMap != null && currentPlant.CAMPX__Garden__c != oldTriggerMap.get(currentPlant.Id).CAMPX__Garden__c) {
                uniqueGardenIds.add(oldTriggerMap.get(currentPlant.Id).CAMPX__Garden__c);
            }
        }

        if (!uniqueGardenIds.isEmpty()) {
            gardensToUpdate = [SELECT Id, 
                                (
                                    SELECT Id 
                                    FROM CAMPX__Plants__r 
                                    WHERE MV_FOR_IsHealthy__c != true
                                )
                            FROM CAMPX__Garden__c 
                            WHERE Id IN :uniqueGardenIds
                            WITH USER_MODE];
                            
            for (CAMPX__Garden__c currentGarden : gardensToUpdate) {
                currentGarden.CAMPX__Total_Unhealthy_Plant_Count__c = currentGarden.CAMPX__Plants__r.size();
                System.debug('MVC count ' + currentGarden.CAMPX__Total_Unhealthy_Plant_Count__c);
            }
        }

        try {
            update gardensToUpdate;
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
     * @param       oldTriggerMap  : Trigger.oldMap
     * 
     * @description When a Plant record is associated with a garden, the total count of the garden
     *              must set to the total count of the plants.
     * @comments
    **********************************************************************************************/
    public static void aggregateTotalPlantCount(List<CAMPX__Plant__c> newTriggerList, Map<Id, CAMPX__Plant__c> oldMap) {
        List<CAMPX__Garden__c> gardensToUpdate;
        Set<Id> gardenIds = new Set<Id>();

        for (CAMPX__Plant__c currentPlant : newTriggerList) {
            gardenIds.add(currentPlant.CAMPX__Garden__c);

            if (oldMap != null && currentPlant.CAMPX__Garden__c != oldMap.get(currentPlant.Id).CAMPX__Garden__c) {
                gardenIds.add(oldMap.get(currentPlant.Id).CAMPX__Garden__c);
            }
        }
        if (!gardenIds.isEmpty()) {
            
            gardensToUpdate = [SELECT Id, 
                                    CAMPX__Total_Plant_Count__c, 
                                    (   
                                        SELECT Id 
                                        FROM CAMPX__Plants__r
                                    )
                            FROM CAMPX__Garden__c
                            WHERE Id IN :gardenIds
                            WITH USER_MODE];
                            
            for (CAMPX__Garden__c currentGarden : gardensToUpdate) {
                currentGarden.CAMPX__Total_Plant_Count__c = currentGarden.CAMPX__Plants__r.size();
            }

            update gardensToUpdate;
        }
    }

    /**********************************************************************************************
     * @author      manvil95
     * @date        10/05/2024
     * @modifiedBy
     * 
     * @param       newTriggerList : Trigger.new
     * 
     * @description When a new Plant record is created, each field should be populated with its 
     *              predefined default value if it's blank.
     * @comments
    **********************************************************************************************/
    public static void initializePlantFields(List<CAMPX__Plant__c> newTriggerList) {
        List<CAMPX__Plant__c> plantsToInsert    = new List<CAMPX__Plant__c>();
        Set<Id> gardenParentsIds                = new Set<Id>();
        
        for (CAMPX__Plant__c currentPlant : newTriggerList) {
            if (currentPlant.CAMPX__Garden__c != null) {
                gardenParentsIds.add(currentPlant.CAMPX__Garden__c);
            }
        }
        
        Map<Id, CAMPX__Garden__c> gardenParents = new Map<Id, CAMPX__Garden__c>([SELECT Id, CAMPX__Sun_Exposure__c 
                                                                                FROM CAMPX__Garden__c 
                                                                                WHERE Id IN :gardenParentsIds 
                                                                                WITH USER_MODE]);
        
        for (CAMPX__Plant__c currentPlant : newTriggerList) {
            if (currentPlant.CAMPX__Soil_Type__c == null) {
                currentPlant.CAMPX__Soil_Type__c = ALL_PURPOSE_POTTING_SOIL;
            }
            
            if (currentPlant.CAMPX__Water__c == null) {
                currentPlant.CAMPX__Water__c = ONCE_WEEKLY;
            }
            
            if (currentPlant.CAMPX__Garden__c != null && gardenParents.get(currentPlant.CAMPX__Garden__c).CAMPX__Sun_Exposure__c != '' && gardenParents.get(currentPlant.CAMPX__Garden__c).CAMPX__Sun_Exposure__c != null) {
                currentPlant.CAMPX__Sunlight__c = gardenParents.get(currentPlant.CAMPX__Garden__c).CAMPX__Sun_Exposure__c;
            }
            else if (currentPlant.CAMPX__Sunlight__c == null) {
                currentPlant.CAMPX__Sunlight__c = PARTIAL_SUN;
            }
            
            plantsToInsert.add(currentPlant);
        }
        
        try {
            insert plantsToInsert;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}