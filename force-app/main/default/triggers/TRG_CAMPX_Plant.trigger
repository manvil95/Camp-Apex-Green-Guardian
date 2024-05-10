/**************************************************************************************************
 * @author          manvil95
 * @date            10/05/2024
 * @modifiedBy
 * @version         1.0
 * 
 * @group           Triggers
 * @group-content   ../../ApexDocContent/
 *
 * @description     Trigger on CAMPX__Plant__c.
 * @comments
 **************************************************************************************************/
trigger TRG_CAMPX_Plant on CAMPX__Plant__c (before insert) {
    new TRG_CAMPX_PlantHandler().run();
}