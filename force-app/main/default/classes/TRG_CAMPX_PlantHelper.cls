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
                currentPlant.CAMPX__Soil_Type__c = 'All Purpose Potting Soil';
            }
            
            if (currentPlant.CAMPX__Water__c == null) {
                currentPlant.CAMPX__Water__c = 'Once Weekly';
            }
            
            if (currentPlant.CAMPX__Garden__c != null && gardenParents.get(currentPlant.CAMPX__Garden__c).CAMPX__Sun_Exposure__c != '' && gardenParents.get(currentPlant.CAMPX__Garden__c).CAMPX__Sun_Exposure__c != null) {
                currentPlant.CAMPX__Sunlight__c = gardenParents.get(currentPlant.CAMPX__Garden__c).CAMPX__Sun_Exposure__c;
            }
            else if (currentPlant.CAMPX__Sunlight__c == null) {
                currentPlant.CAMPX__Sunlight__c = 'Partial Sun';
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